#Creating an AWS Lambda Python Layer
## Introduction
So, recently Amazon released a new feature for their Lambda services, called Layers.
Previously you had to upload your dependencies with every single lambda package, and when working with some more simpler machine learning and data pipelines, this can get quite out of hand.

This tutorial aims to help you create your own layer package with the dependencies you use the most across your Lambdas, so you can take advantage of this feature and reduce the size of your Lambda functions.

First of all, let's talk about limits. Currently AWS sets a limit of 50MB of a zipped package (COMPRESSED DATA) and 250MB of UNCOMPRESSED DATA for any Lambda package. But the first restriction is thrown away if you instead upload the package first to Amazon S3. And this can make a difference of a package fitting in or not into your Lambda.

This tutorial assumes that you know how to start a EC2 instance, and have a IAM user with access to Lambda and S3 and is
somewhat experienced with pip.

## Installation
After creating and connecting to your EC2 instance, just run the script on it, replacing any private information with your own(e.g <MY_ACCESS_KEY>, <MY_BUCKET>, etc).
The script will generate the zip file containing all dependencies installed using pip and stripping them to reduce their size,
in this case, they were:
- Numpy
- Pandas
- Pymysql
- Sqlalchemy
- Requests
- Scipy
- Sklearn
- Xgboost

Furthermore, the script also uploads the package to the specified S3 bucket, and publish a new layer.

The compressed package size, should be around 62MB, making it impossible to upload it directly, but the uncompressed size should 
be around 210MB, so it's possible to upload it via S3 and with reamining 40MB for any extra dependencies that might
need to be added and the actual Lambda function.

And done, the layer should be available to be added to your lambda functions.