#!/usr/bin/env bash
# AWS credentials
aws configure set aws_access_key_id <MY_ACCESS_KEY>;
aws configure set aws_secret_access_key <MY_SECRET_ACCESS_KEY>;
aws configure set default.region <MY_REGION>;

# Install dev-tools, libs and python
sudo yum -y update;
sudo yum -y upgrade;
sudo yum -y groupinstall 'Development Tools';
sudo yum -y install python36;
pip install awscli --upgrade --user;

export S3_BUCKET=<MY_BUCKET>;
export S3_KEY=<MY_KEY>;
export S3_PATH="s3://$S3_BUCKET/$S3_KEY";
export LAYER_NAME=<MY_LAYER_NAME>;

# Setup your virtualenv
virtualenv -p python3 ~/base_pkg/base_pkg;
source ~/base_pkg/base_pkg/bin/activate;
sudo $VIRTUAL_ENV/bin/pip install numpy;
sudo $VIRTUAL_ENV/bin/pip install pandas;
sudo $VIRTUAL_ENV/bin/pip install pymysql;
sudo $VIRTUAL_ENV/bin/pip install sqlalchemy;
sudo $VIRTUAL_ENV/bin/pip install scipy;
sudo $VIRTUAL_ENV/bin/pip install requests;
sudo $VIRTUAL_ENV/bin/pip install sklearn;
git clone --recursive https://github.com/dmlc/xgboost;
cd xgboost;make -j4;cd python-package;sudo $VIRTUAL_ENV/bin/python setup.py install;cd;

# Remove unnecessary stuff for deployment
sudo find $VIRTUAL_ENV/ -name "*.so" | xargs strip;
rsync -a --prune-empty-dirs $VIRTUAL_ENV/lib*/python*/site-packages/ ~/base_pkg/python/
pushd ~/base_pkg/;
zip -r -9 -q ~/base_pkg/base_pkg.zip . -x \*.pyc ./python/pip\* ./python/setuptools\* ./python/wheel\* ./base_pkg\*;
popd;

# upload
aws s3 cp ~/base_pkg/base_pkg.zip $S3_PATH;
aws lambda publish-layer-version --layer-name $LAYER_NAME --content S3Bucket=$S3_BUCKET,S3Key=$S3_KEY --compatible-runtimes python3.6