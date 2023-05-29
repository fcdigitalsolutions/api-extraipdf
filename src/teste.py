import re


def fval_valor(c_valtxt):

    c_aux    = ""
    c_aux2    = ""
    c_letra   = ""
    c_letra2  = ""
    a_string  = ""
    c_stringfinal = ""

    for c_letra in c_valtxt:
        c_aux += c_letra + " "

    a_string = c_aux.split()
    
    for c_letra2 in a_string:
        ## Verifica se a string informada possui um número.
        c_aux2   = c_letra2
        c_letra2 = re.findall('[a-zA-Z]+', c_letra2)
        c_letra2 = "".join(c_letra2)
        c_stringfinal += c_aux2.replace(c_letra2,"")

    return (c_stringfinal)


valor =  'BBASBBAa0.01fBBGGHhhhhhWWW'
print(fval_valor(valor))
