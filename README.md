# TP3 Azure

#### 1. Créer deux VPC. L’un contient deux machines et l’autre une seule. Utiliser les
```Voir fichier *.tf```

#### 2. Vérifier avec telnet et netcat que les machines dans un même VPC peuvent communiquer sur n’importe quel port. A l’inverse vérifier que ce n’est pas possible pour des machines qui ne sont pas sur le même VPC.

**Machines dans le même VPC**

Connexion telnet avec le port 80 de l'instance 1 à l'instance 2 en utilisant l'ip privée de l'instance 2 (10.0.1.4)
![](https://i.imgur.com/q3pYz0b.png)

Connexion netcat avec le port 22 de l'instance 1 à l'instance 2 en utilisant l'ip privée de l'instance 2
![](https://i.imgur.com/aXKtGrI.png)

**Machines qui ne sont pas sur le même VPC**
* Connexion Telnet depuis l'instance 1 vers l'instance 3 dans le VPC 2 en utilisant l'ip privé de l'instance 3 (10.0.2.4)

![](https://i.imgur.com/MhhZdeu.png)

* Connexion netcat depuis l'instance 1 vers l'instance 3 dans le VPC 2 en utilisant l'ip privé de l'instance 3 (10.0.2.4)

![](https://i.imgur.com/az8IDnD.png)




#### 3. Avec la commande curl ifconfig.me vérifier l’adresse IP sortante de chacune des machines.

![](https://i.imgur.com/zO4kXgW.png)


#### 4. Utiliser le composant Gateway pour avoir la même adresse IP sortante sur les 3 serveurs dans les deux VPC.

Nous n'arrivons pas à assigner une ip publique à la resource gateway car il y a une limitation de 3 ips maximum par région pour cet abonnement.
Nous avons essayé de créer une resource ip publique en plus pour la gateway, en la mettant dans une région différente.
Cependant, comme tout est lié à la ressource group, la localisation de cette dernière prend le dessus.

```
 Error: creating/updating Public Ip Address: (Name "public-ip-1" / Resource Group "arg-resources"): network.PublicIPAddressesClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="PublicIPCountLimitReached" Message="Cannot create more than 3 public IP addresses for this subscription in this region." Details=[]
```

#### 5. Vérifier avec la commande curl ifconfig.me les adresses IP sortantes.
N/A
