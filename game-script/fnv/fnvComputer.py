# fallout new vegas, not the FNV algorithm lmao

# adapted from https://leetcode.com/problems/guess-the-word/ lmao

from functools import *
import itertools
import collections
import sys
import random

@cache
def similarLetters(a,b):
    if a>b:
        return similarLetters(b,a)
    return sum(i==j for i,j in zip(a,b))
        
class Solver:
    def __init__(self):
        pass
    
    def setS(self, ss):
        global tried
        tried = {}
        global words
        l = len(ss[0])
        if not all(map(lambda x: len(x)==l, ss)):
            raise "lmao dumbass they're not the same length" + str(list(filter(lambda x: len(x)!=l)))
        words = set(ss)

    def findSecretWord(self, wordlist, master) -> None:
        def genCount(perms,n=0):
            count = collections.Counter(w1 for w1, w2 in perms if similarLetters(w1, w2) == n)
            if len(count) > 0 or n>6:
                return count
            return genCount(perms,n+1)
         
        x = 0
        while True:
            count = genCount(list(itertools.permutations(wordlist, 2)))
            guess = min(wordlist, key=lambda w: count[w])
            x = master(guess)
            if x==len(guess): # EOF, or correct guess
                return
            wordlist = [w for w in wordlist if similarLetters(w, guess) == x]

class Solve:
    def __init__(self):
        pass
    
    def masterF(self, s: str) -> int:
        n = None
        while True:
            print(s)
            try:
                line = sys.stdin.readline()
                if len(line)==0:
                    return len(s)
                n = int(line)
                if n>len(s):
                    print("BAD: 0 <= val <= " + str(len(s)))
                else:
                    return n
            except ValueError as e:
                print("gotta give me a number, king :)")

    def solve(self, ws):
        s=Solver()
        s.setS(ws)
        s.findSecretWord(words, self.masterF)

from pprint import pprint

class Test:
    def __init__(self):
        pass
    
    def genS(self,chsl,l):
        chs = 'abcdefghijklmnopqrstuvwxyz'[:chsl]
        return ''.join([random.choice(chs) for _ in range(l)])

    class Master:
        def __init__(self,answer):
            self.guesses = []
            self.scores = []
            self.numCalls = 0
            self.answer = answer

        def guess(self,s):
            self.numCalls+=1
            self.guesses.append(s)
            self.scores.append(similarLetters(s,self.answer))
            return self.scores[-1]

    def test(self, charset, rounds, wordLen, wllen):
        counts = {}
        for _ in range(rounds):
            wlist = [self.genS(charset,wordLen) for _ in range(wllen)]
            ans = random.choice(list(wlist))

            s = Solver()
            s.setS(wlist)
            m = self.Master(ans)
            s.findSecretWord(words, m.guess)

            print("ANS", ans)
            for g,score in zip(m.guesses,m.scores):
                print(">>>",g,score)
            print(m.numCalls)
            counts[m.numCalls] = counts.get(m.numCalls,0) + 1
        pprint(counts)

# ws = ["containing", "scavenging", "decimating", "facilities", "exchangers", "increasing", "recreating", "endorphins", "exchanging", "operations", "recruiting", "descending"]
ws = ["contingent", "toothbrush", "containing", "contending", "cutthroats", "concerning", "conspiring", "downstairs", "confronted", "containers", "crossroads", "constantly"]
if __name__ == '__main__':
    # t=Test()
    # t.test(100,26,10,100)
    s = Solve()
    s.solve(ws)
