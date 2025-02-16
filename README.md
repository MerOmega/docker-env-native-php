# 🚀 NativePHP Docker Environment for Windows using WSL
A fully ready-to-use Docker-based development environment tailored for NativePHP projects. This setup includes:

✅ Pre-configured PHP environment with all necessary extensions.

✅ Zsh + Oh My Zsh for a powerful and customizable shell experience inside the container.

✅ Electron & Wine support for building cross-platform applications.

✅ Optimized Docker setup with efficient package management and minimal image size.

✅ Seamless integration with your NativePHP projects, ensuring a smooth development experience.

Just build and run – everything is set up for you! 🚀

### This was tested for a personal project with Laravel 11, PHP 8.3.7. NativePHP 0.9
Remember to install this in WSL

``` 
sudo apt update && sudo apt install x11-xserver-utils -y
```

and
```
xhost +local:docker
```
