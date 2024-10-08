# Développements de l'étape 2


## Estimation de la réponse de canal à 1 fréquence


![bla](./images/image.png)

$$
\cos(2\pi ft) \otimes h(t) = y(t)
$$
$$
Y(f) = \int _{-\infty} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt
$$
$$
Y(f) = X(f)H(f)
$$
hypothèse : $h(t)$ causal et $x(t)=0, t<0$  et $x(t) = 0, t\geq T$
donc $y(t) = 0, t<0$ et $t>T$
donc 
$$\int _{-\infty} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt = \int _{t=0} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt$$
qui est presque l'intégrale calculée dans le block gris.
Prenons en comptes la borne supérieure $T$ :

avec
1. les hypothèse plus haut
2. que $fT=n \in\mathbb{N}$ donc on intègre sur un nombre de période entier $\sin(4\pi n)$ et $\cos(4\pi n)$
$$
\begin{align}
X(f) &= \int _{-\infty}^{\infty} \cos(2\pi ft)\exp(-j2\pi ft)dt \\
&\underbrace{ = }_{ 1 } \int _{0}^{T} \cos(2\pi ft) (\cos(-2\pi ft)-j\sin(2\pi ft))dt \\
&=\int _{0}^{T} \cos ^{2}(2\pi ft) - j\sin(2\pi ft)\cos(2\pi ft)dt \\
&=\int _{0}^{T} \frac{1+\cos(4\pi ft)}{2} -j \frac{\sin(4\pi ft)}{2}dt \\
&\underbrace{ = }_{ 2 } \int _{0}^{T} \frac{1}{2} dt = \frac{T}{2}
\end{align}
$$
avec les hypothèse plus haut (notamment = 0 si $t>T$) on a
$$
\begin{align}
Y(f) &= \int _{t=0} ^{T} y(t) \cdot \exp(-j2\pi ft)dt \\
\exp(-j\phi)Y(f) &= \exp(-j\phi) \int _{t=0} ^{T} y(t) \cdot \exp(-j2\pi ft)dt \\
&=\int _{t=0} ^{T} y(t) \cdot \exp(-j(2\pi ft+\phi))dt
\end{align}
$$
Donc il suffit de calculer $Y(f)$ pour finir de démontrer.
$$
\begin{align}
Y(f) &= X(f)H(f) \\
&= \frac{T}{2}H(f)
\end{align}
$$
enfin :
$$
\exp(-j\phi)Y(f) = \frac{T}{2}H(f)\exp(-j\phi)
$$


## Extension de la démo à n fréquences
![](./images/multi-frequencies-in-channel.png)

Q : est-ce que c'est bon juste principe de superposition ça ?
R : non il faut montrer que quand on multiplie par un cos ça annule les autres et garde juste celui qui 

avec les fréquences assez espacées que pour ne pas se chevaucher en fréquentiel.

à creuser sur la partie du cours sur les signaux périodiques.


hypothèse : $h(t)$ causal et $x(t)=0, t<0$  et $x(t) = 0, t\geq T$
donc $y(t) = 0, t<0$ et $t>T$
donc on a à nouveau que les 2 branches évalue la FT de la sortie $y(t)$ du canal cette fois ci à 2 fréquences, $f_{0}$ et $f_{1}$ avec un déphasage qui ne change pas le canal
$$
\begin{align}
y(t)&=\overbrace{ (\cos(2\pi f_{0}t) + \cos(2\pi f_{1}t)) }^{ x(t) } \otimes h(t) \\
%&= (\cos(2\pi f_{0}t) \otimes h(t) ) + (\cos(2\pi f_{1}t)\otimes h(t))
\end{align}
$$
$$
Y(f) = X(f)H(f)
$$
il rest à calculer $X$ en $f_{0}$ et $f_{1}$
$$
\begin{align}
X(f_{0}) &= \int _{0}^{T} (\cos(2\pi f_{0}t) + \cos(2\pi f_{1}t)) \exp(-j2\pi f_{0}t)dt \\
&=\int _{0}^{T}     (\cos(2\pi f_{0}t) + \cos(2\pi f_{1}t)) \cdot \\&\qquad \quad(\cos(-2\pi f_{0}t)-j\sin(2\pi f_{0}t))dt \\
&=\int _{0}^{T} [\cos ^{2}(2\pi f_{0}t) - j\sin(2\pi f_{0}t)\cos(2\pi f_{0}t)  \\
&\qquad \quad + \cos(2\pi f_{1}t)\cos(2\pi f_{0}t) - j\cos(2\pi f_{1}t)\sin(2\pi f_{0}t)]dt \\
&=\int _{0}^{T} [ \frac{1+\cancel{ \cos(4\pi f_{0}t) }}{2} \cancel{ - j \frac{\sin(4\pi f_{0}t)}{2} }  \\
&\qquad \quad+ \frac{1}{2}[\cos(2\pi (f_{1}-f_{0})t) + \cos(2\pi(f_{1}+f_{2})t)]  \\
&\qquad\quad - j \frac{1}{2}[\sin(2\pi(f_{1}-f_{0})t)+ \sin(2\pi(f_{1}+f_{0})t)] ]dt
\end{align}
$$
s'annule car fonction périodique de moyenne nulle sur 1 période (en effet $f_{0}$ et $f_{1}$ multiples entier de $\frac{1}{T}$) *(on aurait pu séparer l'intégrale et directement utiliser le résultat précédent)* et en utilisant les formules de simpsons.
On a que $f_{0}-f_{1} = \frac{n}{T},\ f_{0}+f_{1} = m\ | \ n,m\in\mathbb{Z}_{0}$ donc ce sont aussi des intégrales sur une période de fonction périodique de moyenne nulle.
finalement :
$$
= \int _{0}^{T} \frac{1}{2} dt = \frac{T}{2}
$$
donc $Y(f_{0})=\frac{T}{2}H(f_{0})$ *+ ajouter le déphasage*
## partie 3

Déterminer le paramètre d'écart $T$, mesurer l'étalement fréquentiel d'une sinusoide pour avoir
 un écart suppérieur à cet étalement.