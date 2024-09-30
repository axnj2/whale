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
principe de superposition et bon ?

avec les fréquences assez espacées que pour ne pas se chevaucher en fréquenciel.

à creuser sur la partie du cours sur les signaux périodiques.