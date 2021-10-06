Bootstrap: docker

From: rocker/rstudio

%files
    init.sh /init.sh

%post
    echo "lock-type=linkbased" > /etc/rstudio/file-locks
    chmod 755 /init.sh
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p /opt/conda



