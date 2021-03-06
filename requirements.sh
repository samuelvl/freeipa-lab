#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Global variables
TF_VERSION="0.13.3"
TF_PROVIDERS_DIR="${HOME}/.terraform.d/plugins/registry.terraform.io/hashicorp"
TF_PROVIDER_LIBVIRT_VERSION="0.6.2"
TF_PROVIDER_LIBVIRT_RELEASE="v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64"

# install_libvirt
function install_libvirt {
    libvirt_command="virsh"

    if (which ${libvirt_command} &> /dev/null); then
        echo "Libvirt is already installed."
    else
        echo "Follow the instructions to install libvirt in your linux distribution."
    fi

    return 0
}

# install_terraform <version> <installation_dir>
function install_terraform {
    tf_command="terraform"
    tf_version=${1}
    tf_installation_dir=${2}
    tf_binary="${tf_installation_dir}/${tf_command}"

    # Check if Terraform is already installed
    if (ls "${tf_binary}" &> /dev/null); then
        echo "Terraform v${tf_version} is already installed"
    else
        echo "Installing Terraform v${tf_version}..."

        # Create installation dir
        mkdir -p ${tf_installation_dir}

        # Download Terraform from Hashicorp site
        curl -s -L --output ${tf_binary}.zip \
            https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip

        # Install Terraform
        unzip -d ${tf_installation_dir} ${tf_binary}.zip
        chmod +x ${tf_binary}
        rm -f ${tf_binary}.zip

        echo "Successfully installed!"
    fi

    return 0
}

# install_tf_provider <name> <version> <installation_dir> <url> <tar_additional_opts>
function install_tf_provider {
    provider_name=${1}
    provider_version=${2}
    provider_install_dir="${3}/${provider_name}/${provider_version}/linux_amd64"
    provider_binary="${provider_install_dir}/terraform-provider-${provider_name}"
    provider_url=${4}
    tar_additional_opts=${5:-""}

    # Check if provider is already installed
    if (ls "${provider_binary}_${provider_version}" &> /dev/null); then
        echo "Terraform provider ${provider_name} v${provider_version} is already installed"
    else
        echo "Installing Terraform provider ${provider_name} v${provider_version}..."

        # Create installation folder
        mkdir -p ${provider_install_dir}

        # Download provider from source
        curl -s -L --output ${provider_binary}.tar.gz ${provider_url}

        # Install Provider
        tar -xvf ${provider_binary}.tar.gz ${tar_additional_opts} -C ${provider_install_dir}
        chmod +x ${provider_binary}
        mv ${provider_binary} "${provider_binary}_${provider_version}"
        rm -f ${provider_binary}.tar.gz

        echo "Successfully installed!"
    fi

    return 0
}
# Install libvirt
install_libvirt

# Install terraform
install_terraform ${TF_VERSION} "${HOME}/bin"

# Install libvirt provider for terraform
install_tf_provider \
    "libvirt" \
    ${TF_PROVIDER_LIBVIRT_VERSION} \
    ${TF_PROVIDERS_DIR} \
    "https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/${TF_PROVIDER_LIBVIRT_RELEASE}.tar.gz"
