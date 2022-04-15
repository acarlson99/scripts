import re
import sys
from functools import reduce

argv = sys.argv[1:]
goodLetters, badLetters, goodPattern, badPattern = argv + [None]*(4-len(argv))

if not goodLetters:
    print('usage: python3 '+sys.argv[0]+' include exclude includeRE excludeRE')
    print('example: python3 '+sys.argv[0]+' sam orligcpt s.am. ....[as]')
    exit(1)

F_compose = lambda *fns: lambda x: reduce(lambda y, f: f(y), reversed(fns), x)
F_map = lambda f: lambda step: lambda a, c: step(a, f(c))
F_filter = lambda p: lambda step: lambda a, c: step(a, c) if p(c) else a
F_id = lambda x: x
F_const = lambda x: lambda _: F_id(x)


setAdd = lambda a, c: a.add(c) or a
arrayAppend = lambda a, c: a.append(c) or a


selectLetters = lambda ls: lambda x: reduce(
    F_filter(lambda y: y in ls)(setAdd), x, set()) == set(ls)


removeLetters = lambda ls: lambda x: re.match(('[^' + ls + ']')*5, x)
selectPattern = lambda ptn: lambda x: re.match(ptn, x)
removePattern = lambda ptn: lambda x: not selectPattern(ptn)(x)


f = F_compose(
    F_map(lambda x: x.strip().lower()),
    F_filter(lambda x: len(x) == 5),
    F_filter(lambda x: x.isalpha()),
    F_filter(selectLetters(goodLetters) if goodLetters else F_const(True)),
    F_filter(removeLetters(badLetters) if badLetters else F_const(True)),
    F_filter(selectPattern(goodPattern) if goodPattern else F_const(True)),
    F_filter(removePattern(badPattern) if badPattern else F_const(True)),
)

xform = f(setAdd)


def main():
    with open('/usr/share/dict/words', 'r') as f:
        ftxts = f.readlines()
    if goodLetters:
        print('including letters ----- "'+goodLetters+'"')
    if badLetters:
        print('excluding letters ----- "'+badLetters+'"')
    if goodPattern:
        print('filtering for pattern - "'+goodPattern+'"')
    if badPattern:
        print('excluding pattern ----- "'+badPattern+'"')

    ws = reduce(xform, set(ftxts), set())
    reduce(F_map(print)(lambda _a, _b: None), ws, None)


if __name__ == '__main__':
    main()
