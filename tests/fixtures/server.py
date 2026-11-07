"""Synthetic stdio peer. Never launches Codex, reads credentials, or uses a network."""
import json, os, signal, sys, time
mode = sys.argv[1]
def send(value):
    data = json.dumps(value) + '\n'
    if mode == 'fragmented':
        for part in [data[:7], data[7:]]:
            sys.stdout.write(part); sys.stdout.flush(); time.sleep(.01)
    else:
        sys.stdout.write(data); sys.stdout.flush()
if mode == 'closed': sys.exit(0)
if mode == 'stalled':
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    time.sleep(60)
    sys.exit(0)
first = json.loads(sys.stdin.readline())
assert first['method'] == 'initialize'
if mode == 'init-error':
    send({'id':1,'error':{'message':'SYNTHETIC_PRIVATE_ERROR'}}); sys.exit(0)
send({'id':1,'result':{'userAgent':'synthetic-test'}})
assert json.loads(sys.stdin.readline())['method'] == 'initialized'
assert json.loads(sys.stdin.readline())['method'] == 'account/rateLimits/read'
if mode == 'error':
    send({'id':2,'error':{'message':'SYNTHETIC_PRIVATE_ERROR'}})
elif mode == 'oversized':
    sys.stdout.write('x' * 2_000_001); sys.stdout.flush()
elif mode == 'malformed':
    print('{invalid json}', flush=True)
elif mode == 'unsupported':
    send({'id':2,'result':{'rateLimitsByLimitId':{'codex':{'primary':{'usedPercent':10,'windowDurationMins':15}}}}})
else:
    send({'method':'unrelated/notice','params':{}})
    send({'id':2,'result':{'rateLimitsByLimitId':{'codex':{'primary':{'usedPercent':28,'windowDurationMins':300},'secondary':{'usedPercent':59,'windowDurationMins':10080}}}}})
# Closing only after the parent sends EOF also exercises process cleanup.
sys.stdin.read()
