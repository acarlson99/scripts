# Voice Command

Execute scripts based on verbal commands

## Usage

```
pip install -r requirements.txt
./run.py --config-file=config.yaml
```

## Config

see `config.yaml` and `example.yaml` for example

`reg` - regex pattern to match with audio.  Capture groups used in `cmd`

`cmd` - command to be executed when audio matches `reg`.  `{}` substituted for capture groups (in order) in regex match

```yaml
rules:
  - reg: create file (\w+)        # match   "create file test"
    cmd: touch {}                 # execute "touch test"
  - reg: create directory (\w+)   # match   "create directory test"
    cmd: mkdir {}                 # execute "mkdir test"
  - reg: silly ([^ ]+) goose      # NOTE: `silly silly silly silly goose` will match this rule instead of the next
    cmd: echo {}
  - reg: silly ([^ ]+) ([^ ]+) ([^ ]+) goose
    cmd: echo the goose is {} {} and {}
  - reg: list
    cmd: ls
```

Regex rules are matched in order found in config

If rules overlap, the first listed rule will be used

Rules are in the form of regex rules.  Use `--verbose` mode and read abuot regex online if you run into issues with rules

```
$ ./run.py --verbose --config-file=example.yaml
----------------RULES----------------
('create file (\\w+)', 'touch {}')
('create directory (\\w+)', 'mkdir {}')
('silly ([^ ]+) goose', 'echo {}')
('silly ([^ ]+) ([^ ]+) ([^ ]+) goose', 'echo the goose is {} {} and {}')
('list', 'ls')
-----------------MIC-----------------
ALSA lib pcm.c:2642:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.rear
...
JackShmReadWritePtr::~JackShmReadWritePtr - Init not done for -1, skipping unlock
-------------------------------------
AUDIO: list
match: ()
cmd: ls
executing: ls
config.yaml  example.yaml  __pycache__	README.md  requirements.txt  run.py
AUDIO: create file test
match: ('test',)
cmd: touch {}
executing: touch test
AUDIO: create directory pumpkin
match: ('pumpkin',)
cmd: mkdir {}
executing: mkdir pumpkin
AUDIO: list
match: ()
cmd: ls
executing: ls
config.yaml   pumpkin	   README.md	     run.py
example.yaml  __pycache__  requirements.txt  test
AUDIO: silly silly silly silly goose
match: ('silly',)
cmd: echo {}
executing: echo silly
silly
AUDIO: silly stupid dumb gassy goose
match: ('stupid', 'dumb', 'gassy')
cmd: echo the goose is {} {} and {}
executing: echo the goose is stupid dumb and gassy
the goose is stupid dumb and gassy
^CInterrupt...
```
