---
layout: post
title:  "Setup Minishift on Windows 10 backed by Hyper-V"
date:   2019-08-11 00:00:00 +0000
categories: DevOps
lang: en
lang-ref: minishift-windows-10-hyperv

---

This post will address you into Minishift configuration over Windows 10.  The hypervisor will be Hyper-V due to this one already comes in Windows 10. Hyper-V is only available for Pro, Enterprise and Education Windows versions.

Minishift is a tool that allows you to run OpenShift in a single node cluster. The cluster is built around Kubernetes. This tool is typically used for developing purposes.

There is a bunch of information around Minishift, so if you want to deep dive hit this [link](https://www.okd.io/minishift/).

## Prerequisites:
- Windows 10 (Pro version at least) or any other version compatible with Hyper-V.
- Chocolatey package manager. Follow the [link](https://chocolatey.org/) to install it.
- Virtualization support enabled from your BIOS. More info please to your BIOS documentation.
- Al least 4GB of RAM.

## Setup:
The first task to get done is the Hyper-V installation. Please go to "Control Panel", then "Programs", and "Turn Windows Features on or off.".  Mark the Hyper-V checkbox. After a couple of minutes when the installation is done, reboot your machine.

![Enabling-HyperV](/public/img/minishift-windows-10-hyperv/enabling-hyperv.png)

Second, add your user to the local Hyper-V Administrator group. To achieve that, execute PowerShell as Administrator, and run this instruction:

```bash
([adsi]"WinNT://./Hyper-V Administrators,group").Add("WinNT://$env:UserDomain/$env:Username,user")
```
Third, open Hyper-V application and add an external switch. The way for doing this is through a local connection with Hyper-V and then look for a switch from the contextual menu. It might be called "External VM Switch". This virtual switch should be connected with the external network, so, be sure to choose the "External Network" among the connection type options.

![External-Virtual-Switch](/public/img/minishift-windows-10-hyperv/external-virtual-switch.png)

Furthermore, check if your machine is already connected to the external switch. Go to "Control Panel", "Network and Internet", and "Network and Sharing Center". There should be an Internet connection through "External VM Switch" vEthernet interface. It should look similar to the image below.

![External-Connection](/public/img/minishift-windows-10-hyperv/external-connection.png)


Fourth, install Minishift package. This should be made from PowerShell as Administrator.

```bash
choco install minishift
```

Fifth, set VM driver and virtual switch in Hyper-V. For doing this, open PowerShell with no-privileges mode. Type the commands that are below. Be conscious that "External VM Switch" value is the name of the virtual switch already created previously.

```bash
minishift config set vm-driver hyperv
minishift config set hyperv-virtual-switch "External VM Switch"
```

Sixth, start off Minishift. From PowerShell run "minishift start". If the configuration was done correctly, a message that OpenShift is being downloaded and configured should appear. Something like the below image.

![Starting-Minishift-Cluster](/public/img/minishift-windows-10-hyperv/starting-minishift-cluster.png)

Once Minishift has started, you are allowed to sign in at the web console and launch any application you want. To sign in type "developer" at the username field and any character at password field. 

```bash
The server is accessible via web console at:
   https://192.168.100.34:8443/console
```

![Sign-in-web-console](/public/img/minishift-windows-10-hyperv/sign-in-openshift.png)

## Wrap it up
1. Minishift is a tool for setting up a single node Openshift cluster.
2. Minishift is for development and experimental purposes. It's not recommended for production.
3. Minishift runs over any Windows version that supports Hyper-V or VirtualBox.
4. The external virtual switch allows Openshift cluster to connect Internet.

## Questions?
I'll appreciate any comment or question.

Thanks for reading.

Reach me out at <info@faustocv.org>
