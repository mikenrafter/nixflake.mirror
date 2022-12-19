#!/bin/env python
import os, copy
import pyfribidi as p

print('[] -> RLE/LRE   () -> RLO/LRO   | -> PDF')
print('<> -> RLI/LRI                   - -> PDI')

# lre='\u202a' rle='\u202b' # when are these actually used?
pdf='\u202c'

lro='\u202d'
rlo='\u202e'

lri='\u2066'
rli='\u2067'
pdi='\u2069'

dictionary=[
    #    [']',lre], ['[',rle],
        ['|',pdf], [')',lro], ['(',rlo],
        ['>',lri], ['<',rli], ['-',pdi]
    ]
visual_map=[
        [lri,lro], [rli,rlo], [pdi,pdf]
    ]

while True:
    inp=input(':')
    out=inp
    mid=inp

    for a, b in dictionary:
        out=out.replace(a, b)
        mid=mid.replace(a, '')
#    pre=out
#    for a, b in visual_map:
#        pre=pre.replace(a, b)

    vis=p.log2vis(out, p.LTR)
    siv=p.log2vis(out, p.RTL)
    for a, b in dictionary:
        vis=vis.replace(b, '')
        siv=siv.replace(b, '')

    # attempt preview
#    print(vis, '->', mid)
    print(vis, '-L>', mid)
    print(siv, '-R>', mid)

    with open('/home/v0id/temp', 'w') as f:
        f.write(out)

    # not cross platform, eh!
    os.system("cat /home/v0id/temp | xclip -selection clipboard")


''' homegrown bidi engine, it sucks, but only sometimes
template={'mode': 'l', 'children': [], 'index': 0, 'flipped': False}
mapping={
    lri: 'l',
    rli: 'r',
    pdi: 'n',
    lro: 'L',
    rlo: 'R',
    pdf: 'N'
    }


def parse(mode, text, root=False):
    # output var
    out=copy.deepcopy(template)
    out['mode']=mode
    # text buffer
    buffer=''

    # loop through text
    for i in range(len(text)):

        # if last char initiated a child, catch up
        if out['index']>i: continue
        # increment
        out['index'] +=1

        # get current char
        c=text[i]

        # if current char is a control flow char
        if c in mapping:
            # get mode
            m=mapping[c]
            # append previous buffers, if relevant
            if buffer: out['children'].append(buffer)
            buffer=''

            # if mode is an exit character, then exit the recursion level
            if m in 'nN': break

            # recurse
            node=parse(m, text[out['index']:])
            # adjust index
            out['index']+=node['index']
            # add node to tree
            out['children'].append(node)
            # pretty print-debug
            # out['children'].append(node['mode']+' '+str(node['children']))
        else:
            # add to the buffer
            buffer+=c

    # append lingering buffers, if relevant
    if buffer: out['children'].append(buffer)
    return out
def display(tree, ignore=False):
    #print(tree, '\n\n')
    out=''
    # increment (used for .pop() )
    pop=0-(tree['mode'] in 'Rr')
    # increment (used for str[::])
    inc=1+pop*2

    # inform parent!
    if not tree['flipped'] and tree['mode'] in 'LR':
        return ['', tree['mode'] ]

#    justFlipped=-1

#    loop through children using proper direction
    while tree['children']:
#        print(pop, tree['flipped'], '   ', [x for x in map(lambda x: x['children'] if 'children' in x else x, tree['children'])])
        # get child from the proper end, using the correct mode
        child=tree['children'].pop(pop)
        # if child is a simple string, parse it in the proper order
        if type(child).__name__ == 'str':
            out+=child[::inc]
        # otherwise, parse subtrees aka branches
        else:
            # recurse
            buffer, new = display(child)
            # if the branches mode isn't isolated
            if not child['flipped'] and new in 'LR':
                # in an already RTL environment RTL will do nothing, and the
                # same goes for LTR in an LTR environment
                a = new == 'R' and not tree['mode'] == 'R'
                b = new == 'L' and not tree['mode'] == 'L'
                # flip the order, relative to any changes needed
                # TODO fix this to be fully compliant with the spec
                tree['children'] = tree['children'][::b-a or 1]
                # if it flipped, adjust the current tree's mode
                if a or b:
                    tree['mode'] = new
#                    print('flipped')
#                    justFlipped=
                # do not allow this branch to flip again
                child['flipped']=True
                # resubmit this branch for parsing - relative to the mode
                # TODO fix this to be fully compliant with the spec
                # maybe something to do with [].insert()? (see my unfinished
                # justFlipped thought)
                if pop:
                    tree['children'].append(child)
                else:
                    tree['children'] = [child]+tree['children']
#            print(buffer)
            # an unfinished thought, relative to the justFlipped part
#            out+=[buffer]
            # change the output
            out+=buffer
    return [out, tree['mode']]
'''


