"""Herramienta de verificación para dependencias funcionales (Práctica 6).
Sirve para COMPROBAR lo que se hizo a mano; la práctica pide el paso a paso en normalizacion.md.
Uso:  python3 fd_tools.py
"""
from itertools import combinations

def cierre(attrs, F):
    """Cierre de un conjunto de atributos bajo F (F = lista de (izq, der) con conjuntos)."""
    c = set(attrs)
    cambio = True
    while cambio:
        cambio = False
        for izq, der in F:
            if izq <= c and not der <= c:
                c |= der
                cambio = True
    return c

def claves_candidatas(R, F):
    R = set(R)
    # atributos que nunca aparecen a la derecha deben estar en toda clave
    der_all = set().union(*[d for _, d in F]) if F else set()
    base = R - der_all
    claves = []
    resto = sorted(R - base)
    for n in range(len(resto) + 1):
        for extra in combinations(resto, n):
            cand = base | set(extra)
            if any(k <= cand for k in claves):
                continue
            if cierre(cand, F) == R:
                claves.append(cand)
    return claves

def cobertura_minima(F):
    # 1) lados derechos simples
    G = [(set(i), {a}) for i, d in F for a in d]
    # 2) quitar atributos sobrantes del lado izquierdo
    cambio = True
    while cambio:
        cambio = False
        for idx, (izq, der) in enumerate(G):
            for a in sorted(izq):
                if len(izq) > 1:
                    menor = izq - {a}
                    if der <= cierre(menor, G):
                        G[idx] = (menor, der)
                        izq = menor
                        cambio = True
    # 3) quitar dependencias redundantes
    i = 0
    while i < len(G):
        sin = G[:i] + G[i+1:]
        if G[i][1] <= cierre(G[i][0], sin):
            G = sin
        else:
            i += 1
    return G

def equivalentes(F, G):
    return (all(d <= cierre(i, G) for i, d in F) and
            all(d <= cierre(i, F) for i, d in G))

def fd(txt):
    izq, der = txt.split('->')
    return (set(izq.split()), set(der.split()))

def mostrar(F):
    return ['{%s} -> {%s}' % (', '.join(sorted(i)), ', '.join(sorted(d))) for i, d in F]

if __name__ == '__main__':
    ESQUEMA = {
        'dueno': ('cd n a co t di', ['cd -> n a co t di', 'co -> cd']),
        'mascota': ('cm n e r ed s no cl p cd', ['cm -> n e r ed s no cl p cd']),
        'veterinario': ('cv n a ce esD np esC nc', ['cv -> n a ce esD np esC nc', 'ce -> cv']),
        'cita': ('cm cc f h no dx cv', ['cm cc -> f h no dx cv', 'cv f h -> cm cc']),
        'tratamiento': ('ct de ft fv cm cc', ['ct -> de ft fv cm cc']),
    }
    for t, (R, F) in ESQUEMA.items():
        F = [fd(x) for x in F]
        print('==', t)
        print('claves candidatas:', [sorted(k) for k in claves_candidatas(R.split(), F)])
        print('cobertura mínima :', mostrar(cobertura_minima(F)))
    print('== ficha_cita (desnormalizada)')
    R = 'cm cc f h dx nm es sx cd nd ad co te di cv nv av ce'.split()
    F = [fd(x) for x in [
        'cm cc -> f h dx cv',
        'cm -> nm es sx cd',
        'cd -> nd ad co te di',
        'co -> cd',
        'cv -> nv av ce',
        'ce -> cv',
        'cv f h -> cm cc']]
    print('claves candidatas:', [sorted(k) for k in claves_candidatas(R, F)])
    for x in mostrar(cobertura_minima(F)): print('  ', x)
    print('cierre {cm,cc}+ =', sorted(cierre({'cm','cc'}, F)))
    print('cierre {cm}+    =', sorted(cierre({'cm'}, F)))
    print('cierre {cd}+    =', sorted(cierre({'cd'}, F)))
    print('cierre {cv}+    =', sorted(cierre({'cv'}, F)))
