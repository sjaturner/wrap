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
        call={'name':identifier, 'items':[]}
        for item in items:
            m = re.match(r'char\s*\*\s*(.*)', item)
            if m:
                call['items'].append(['string', m.group(1)])
            else:
                call['items'].append(re.split('\s+', item))
        functions.append(call)
    else:
        bracket = [chunk.strip() for chunk in re.split(r'({[^}]*})', statement) if len(chunk.strip())]
        identifier = bracket[2]
        items=[re.split(r'\s *= \s*', item.strip()) for item in bracket[1][1:-1].split(',') if len(item.strip())]
        enums.append({'name':identifier, 'items':items})

for enum in enums:
    print("static char *value_of_enum_%s(char *str) {"%enum['name']);
    print("    if(0) {}")
    for tag, value in enum['items']:
        print("    else if (!strcmp(str, \"%s\")) return %s;"%(tag, value))
    print("    else return 0;")
    print("}")

print("int handle_argc_argv(int argc, char *argv[]) {")
print("    if(0) {}")
for function in functions:

    pass_through = function['items'][-2]==['int', 'argc'] and function['items'][-1]==['string', 'argv[]']

    if pass_through:
        params = function['items'][0:-2]
    else:
        params = function['items']

    print("    else if (!strcmp(argv[0], \"%s\")) {"%(function['name']))
    for index, type_name in enumerate(params):
        print("        %s %s = parse_%s(argv[%d]);"%(type_name[0], type_name[1], type_name[0], index + 1))
    print("        %s("%function['name'],end='')
    for index, type_name in enumerate(params):
        print(type_name[1],end='')
        if index + 1 != len(params):
            print(",",end='')
    if pass_through:
        print(', argc - %d, argv + %d'%(index + 2, index + 2),end='')
    print(");")

    print("    }")
print("    return -1;")
print("}")
