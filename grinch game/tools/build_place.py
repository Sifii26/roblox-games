#!/usr/bin/env python3
"""Builds StealChristmas.rbxlx from src/ (same layout as default.project.json).

Open the generated file in Roblox Studio (File > Open from File), then
File > Publish to Roblox to save it as a real place. Re-run this script after
editing any .luau file:  python3 tools/build_place.py
"""
import os
from xml.sax.saxutils import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
OUT = os.path.join(ROOT, "StealChristmas.rbxlx")

ref_counter = [0]


def ref():
    ref_counter[0] += 1
    return f"RBX{ref_counter[0]:08X}"


def cdata(text):
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def item(cls, name, props="", children=""):
    return (
        f'<Item class="{cls}" referent="{ref()}"><Properties>'
        f'<string name="Name">{escape(name)}</string>{props}</Properties>{children}</Item>'
    )


def script_item(path, name):
    with open(path, encoding="utf-8") as f:
        source = f.read()
    if name.endswith(".server"):
        cls, name = "Script", name[: -len(".server")]
    elif name.endswith(".client"):
        cls, name = "LocalScript", name[: -len(".client")]
    else:
        cls = "ModuleScript"
    return cls, name, f'<ProtectedString name="Source">{cdata(source)}</ProtectedString>'


def folder(path, name):
    """A directory: a Folder, or a ModuleScript if it has init.luau."""
    children = []
    for entry in sorted(os.listdir(path)):
        full = os.path.join(path, entry)
        if os.path.isdir(full):
            children.append(folder(full, entry))
        elif entry.endswith(".luau") and entry != "init.luau":
            cls, n, props = script_item(full, entry[: -len(".luau")])
            children.append(item(cls, n, props))
    init = os.path.join(path, "init.luau")
    if os.path.exists(init):
        cls, _, props = script_item(init, name)
        return item(cls, name, props, "".join(children))
    return item("Folder", name, "", "".join(children))


def main():
    services = [
        item("Workspace", "Workspace",
             '<bool name="StreamingEnabled">true</bool>'
             '<float name="StreamingTargetRadius">768</float>'
             '<float name="StreamingMinRadius">256</float>'),
        item("Players", "Players", '<bool name="CharacterAutoLoads">false</bool>'),
        item("Lighting", "Lighting"),
        item("ReplicatedStorage", "ReplicatedStorage", "", folder(os.path.join(SRC, "shared"), "Shared")),
        item("ServerScriptService", "ServerScriptService", "", folder(os.path.join(SRC, "server"), "Server")),
        item("StarterPlayer", "StarterPlayer", "",
             item("StarterPlayerScripts", "StarterPlayerScripts", "", folder(os.path.join(SRC, "client"), "Client"))),
        item("SoundService", "SoundService"),
    ]
    xml = '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" version="4">' + "".join(services) + "</roblox>"
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(xml)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
