### Vérifier le status des tunnels VPN
```
sudo systemctl status strongswan
sudo strongswan status
sudo strongswan statusall
```

## Vérifier le status du BGP
```
sudo systemctl status bird
```

### Relancer les tunnels VPN au cas ou pas de routes propagées

```
sudo strongswan restart
```