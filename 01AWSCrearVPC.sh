###########################################################
#       Creación de una VPC, subredes, 
#       internet gateway y tabla de rutas
#      en AWS con AWS CLI
#
# Utilizado para AWS Academy Learning Lab
#
# Autor: Javier Terán González
# Fecha: 18/10/2022
###########################################################

## Definición de variables
AWS_VPC_CIDR_BLOCK=10.22.0.0/16
AWS_SUBNET_CIDR_BLOCK=10.22.1XX.0/24

## Crear una VPC (Virtual Private Cloud)
AWS_VPC_ID=$(aws ec2 create-vpc \
--cidr-block $AWS_VPC_CIDR_BLOCK \
--query 'Vpc.{VpcId:VpcId}' \
--output text)

## Habilitar los nombres DNS para la VPC
aws ec2 modify-vpc-attribute \
--vpc-id $AWS_VPC_ID \
--enable-dns-hostnames "{\"Value\":true}"

## Crear una subred publica
AWS_SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
--vpc-id $AWS_VPC_ID --cidr-block $AWS_SUBNET_CIDR_BLOCK \
--availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' \
--output text)

## Habilitar la asignación automática de IPs públicas en la subred pública
aws ec2 modify-subnet-attribute \
--subnet-id $AWS_SUBNET_PUBLIC_ID \
--map-public-ip-on-launch

## Crear un Internet Gateway (Puerta de enlace)
AWS_INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
--query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
--output text)

## Asignar el Internet gateway a la VPC
aws ec2 attach-internet-gateway \
--vpc-id $AWS_VPC_ID \
--internet-gateway-id $AWS_INTERNET_GATEWAY_ID

## Crear una tabla de rutas
AWS_CUSTOM_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
--vpc-id $AWS_VPC_ID \
--query 'RouteTable.{RouteTableId:RouteTableId}' \
--output text )

## Crear la ruta por defecto a la puerta de enlace (Internet Gateway)
aws ec2 create-route \
--route-table-id $AWS_CUSTOM_ROUTE_TABLE_ID \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $AWS_INTERNET_GATEWAY_ID

## Asociar la subred pública con la tabla de rutas
AWS_ROUTE_TABLE_ASSOID=$(aws ec2 associate-route-table  \
--subnet-id $AWS_SUBNET_PUBLIC_ID \
--route-table-id $AWS_CUSTOM_ROUTE_TABLE_ID \
--output text)