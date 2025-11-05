#!/bin/bash
;;
2)
if ! grep -q "Listen ${PORT_APACHE}" /etc/apache2/ports.conf; then
echo "Listen ${PORT_APACHE}" | sudo tee -a /etc/apache2/ports.conf >/dev/null
fi
sudo tee /etc/apache2/sites-available/codef.conf >/dev/null <<APC
<VirtualHost 0.0.0.0:${PORT_APACHE}>
ServerAdmin admin@localhost
DocumentRoot ${WEB_ROOT}
<Directory ${WEB_ROOT}>
Options Indexes FollowSymLinks
AllowOverride All
Require all granted
</Directory>
ErrorLog \${APACHE_LOG_DIR}/codef_error.log
CustomLog \${APACHE_LOG_DIR}/codef_access.log combined
</VirtualHost>
APC
sudo a2ensite codef.conf >/dev/null || true
sudo systemctl reload apache2 || sudo systemctl restart apache2
sudo systemctl enable apache2 >/dev/null
say "Apache aktif di 0.0.0.0:${PORT_APACHE}"
;;
3)
# jalankan keduanya (panggil case 1 dan 2)
"$0" <<< $'1\n4' >/dev/null || true
"$0" <<< $'2\n4' >/dev/null || true
say "Multi-Server aktif (NGINX & Apache)"
;;
4)
break
;;
*) echo "Pilihan tidak valid";;
esac
done


LAN_IP=$(hostname -I | awk '{print $1}')
PUB_IP=$(curl -s https://api.ipify.org || echo "-")


echo "\n--- Informasi Akses ---"
echo "LAN : http://${LAN_IP}:${PORT_NGINX} (NGINX), http://${LAN_IP}:${PORT_APACHE} (Apache)"
echo "Public: http://${PUB_IP}:${PORT_NGINX} (jika IP publik tersedia)"
