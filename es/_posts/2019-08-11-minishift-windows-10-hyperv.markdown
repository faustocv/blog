---
layout: post
title:  "Configura Minishift en Windows 10 soportado por Hyper-V"
date:   2019-08-11 00:00:00 +0000
categories: DevOps
lang: es
lang-ref: minishift-windows-10-hyperv

---

Este post te guiará en la configuración de Minishift sobre Windows 10. El hipervisor será Hyper-V debido aque éste ya viene en Windows 10. Hyper-V solo está disponible para las versiones Pro, Enterprise y Education de Windows.

Minishift es una herramienta que te permite correr un cluster de Openshift de un solo nodo. Esta herramienta generalmente usada para propósitos de desarrollo.

Existe bastante información sobre Minishift, entonces si quieres profundizar ingresa al siguiente [enlace](https://www.okd.io/minishift/).

## Prerequisitos:
- Windows 10 (a partir de la versión Pro) o cualquier otra versión compatible con Hyper-V.
- El administrador de paquetes Chocolatey. Sigue el siguiente [enlace](https://chocolatey.org/) para instalarlo.
- Tener la virtualización habilitada en la BIOS. Mayor información por favor consulta la documentación de tu BIOS.
- Al menos 4GB de memoria RAM.

## Configuración:
La primera tarea a completar es la instalación de Hyper-V. Por favor ve a "Panel de Control", luego a "Programas" y después a "Activar o desactivar características de Windows". Marca la casilla que dice Hyper-V. Luego de un par de minutos cuando la instalación esté lista, reinicia tu máquina.

![Habilitando-HyperV](/public/img/minishift-windows-10-hyperv/enabling-hyperv.png)

Segundo, agrega tu usuario al grupo local "Administradores de Hyper-V". Para lograr esto, ejecuta PowerShell como Administrador y corre esta instrucción:

```bash
([adsi]"WinNT://./Hyper-V Administrators,group").Add("WinNT://$env:UserDomain/$env:Username,user")
```

Tercero, abrir la aplicación de Hyper-V y agregar un switch externo. La forma de hacer esto es a través de una conexión local con Hyper-V y luego buscar switch desde su menú contextual. Éste puede llamarse "External VM Switch". El switch virtual debe estar conectado con la red externa, por lo tanto, asegúrate de escojer de entre las opciones de tipo de conexión a "External Network".

![Switch-Virtual-Externo](/public/img/minishift-windows-10-hyperv/external-virtual-switch.png)

Además, verificar si tu máquina está conectada al switch externo. Para ello, ir a "Panel de Control", "Redes e Internet", "Centro de Redes y Recursos Compartidos". Debería existir una conexión a Internet a través de la interfaz vEthernet "External VM Switch". Debería verse algo similar a la imagen de abajo.  

![Conexion-Externa](/public/img/minishift-windows-10-hyperv/external-connection.png)


Cuarto, instalar el paquete Minishift. Esto debería hacerse desde PowerShell como Administrador.

```bash
choco install minishift
```

Quinto, configurar del driver de la VM y el switch virtual en Hyper-V. Para hacer  esto, abrir PowerShell en modo normal. Escribir las instrucciones que están abajo. Tener en cuenta que el valor "External VM Switch" es el nombre del switch virtual que ya se creó anteriormente.

```bash
minishift config set vm-driver hyperv
minishift config set hyperv-virtual-switch "External VM Switch"
```

Sexto, iniciar Minishift. Desde PowerShell ejecutar "minishift start". Si la configuración fue hecha correctamente entonces un mensaje debería aparecer de que Openshift esta siendo descargado y configurado. Algo similar a la imagen posterior.

![Inicializando-Minishift](/public/img/minishift-windows-10-hyperv/starting-minishift-cluster.png)

Una vez de que Minishift ha empezado, estás habilitado para iniciar sesión en la consola web y lanzar cualquier applicación que tu desees. Para iniciar sesión escribir "developer" en el campo nombre de usuario y cualquier palabra en el campo password.

```bash
The server is accessible via web console at:
   https://192.168.100.34:8443/console
```

![Iniciar-Sesion-Consola-Web](/public/img/minishift-windows-10-hyperv/sign-in-openshift.png)

## En resumen
1. Minishift es una herramienta para configurar un cluster de Openshift de un solo nodo.
2. Minishift es para propósitos experimentales y de desarrollo. No recomendado para producción.
3. Minishift corre sobre una versión de Windows compatible con Hyper-V o VirtualBox, por ejemplo Windows 10.
4. El switch externo permite que el cluster de Openshift conectarse a Internet.

## Preguntas?
Apreciaré cualquier comentario o pregunta. 

Gracias.

Contáctame vía correo <info@faustocv.org>.
