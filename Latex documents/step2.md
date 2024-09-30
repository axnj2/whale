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
hypothèse : $h(t)$ causal et $x(t)=0, t<0$ 
donc $y(t) = 0, t<0$
donc 
$$\int _{-\infty} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt = \int _{t=0} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt$$
qui est presque l'intégrale calculée dans le block gris.
Prenons en comptes la borne supérieure $T$ :

> [!question]+  Comment on prend en compte l'intégrale bornée ?
> 




$$
\begin{align}
Y(f) &= \int _{t=0} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt \\
\exp(-j\phi)Y(f) &= \exp(-j\phi) \int _{t=0} ^{\infty} y(t) \cdot \exp(-j2\pi ft)dt \\
&=\int _{t=0} ^{\infty} y(t) \cdot \exp(-j(2\pi ft+\phi))dt
\end{align}
$$
Donc il suffit de calculer $Y(f)$ pour finir de démontrer.

