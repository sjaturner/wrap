import sys
import re

wrap=sys.stdin.read()
statements = [statement for statement in [statement.strip() for statement in re.split('\s*;\s*', wrap) if len(statement)]]

functions = []
enums = []
for statement in statements:
    if statement[-1] == ')':
        bracket = [chunk.strip() for chunk in re.split(r'(\([^\)]*\))', statement) if len(chunk.strip())]
        identifier = bracket[0].split()[1]
        items=[item.strip() for item in bracket[1][1:-1].split(',') if len(item.strip())]
        print(identifier, items);
        call={'name':identifier, 'items':[]}
        for item in items:
            m = re.match(r'char\s*\*\s*(.*)', item)
            if m:
                call['items'].append(['char *', m.group(1)])
            else:
                call['items'].append(re.split('\s+', item))
        functions.append(call)
    else:
        bracket = [chunk.strip() for chunk in re.split(r'({[^}]*})', statement) if len(chunk.strip())]
        identifier = bracket[2]
        items=[re.split(r'\s *= \s*', item.strip()) for item in bracket[1][1:-1].split(',') if len(item.strip())]
        enums.append({'name':identifier, 'items':items})

print(functions)

for enum in enums:
    print("static char *value_of_enum_%s(char *str) {"%enum['name']);
    print("    if(0) {}")
    for tag, value in enum['items']:
        print("    else if (!strcmp(str, \"%s\") return %s;"%(tag, value))
    print("    else return 0;")
    print("}")
