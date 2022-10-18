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
AWS_Subred_CIDR_BLOCK=10.22.1XX.0/24

## Crear una VPC (Virtual Private Cloud)
AWS_VPC_ID=$(aws ec2 create-vpc \
--cidr-block $AWS_VPC_CIDR_BLOCK \
--query 'Vpc.{VpcId:VpcId}' \
--output text)

## Habilitar los nombres DNS para la VPC
aws ec2 modify-vpc-attribute \
--vpc-id $AWS_ID_VPC \
--enable-dns-hostnames "{\"Value\":true}"

## Crear una subred publica
AWS_ID_SubredPublica=$(aws ec2 create-subnet \
--vpc-id $AWS_ID_VPC --cidr-block $AWS_Subred_CIDR_BLOCK \
--availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' \
--output text)

## Habilitar la asignación automática de IPs públicas en la subred pública
aws ec2 modify-subnet-attribute \
--subnet-id $AWS_ID_SubredPublica \
--map-public-ip-on-launch

## Crear un Internet Gateway (Puerta de enlace)
AWS_ID_InternetGateway=$(aws ec2 create-internet-gateway \
--query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
--output text)

## Asignar el Internet gateway a la VPC
aws ec2 attach-internet-gateway \
--vpc-id $AWS_ID_VPC \
--internet-gateway-id $AWS_ID_InternetGateway

## Crear una tabla de rutas
AWS_ID_TablaRutas=$(aws ec2 create-route-table \
--vpc-id $AWS_ID_VPC \
--query 'RouteTable.{RouteTableId:RouteTableId}' \
--output text )

## Crear la ruta por defecto a la puerta de enlace (Internet Gateway)
aws ec2 create-route \
--route-table-id $AWS_ID_TablaRutas \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $AWS_ID_InternetGateway

## Asociar la subred pública con la tabla de rutas
AWS_ROUTE_TABLE_ASSOID=$(aws ec2 associate-route-table  \
--subnet-id $AWS_ID_SubredPublica \
--route-table-id $AWS_ID_TablaRutas \
--output text)

## Asignación de etiquetas a los recursos
## Añadir etiqueta a la VPC
aws ec2 create-tags \
--resources $AWS_ID_VPC \
--tags "Key=Name,Value=myvpc"
 
## Añaadir etiqueta a la subred pública
aws ec2 create-tags \
--resources $AWS_ID_SubredPublica \
--tags "Key=Name,Value=SRIXX subred publica"

## Añadir etiqueta a la puerta de enlace
aws ec2 create-tags \
--resources $AWS_ID_InternetGateway \
--tags "Key=Name,Value=SRIXX internet-gateway"

## Añadir etiqueta a la ruta por defecto
AWS_DEFAULT_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
--filters "Name=vpc-id,Values=$AWS_ID_VPC" \
--query 'RouteTables[?Associations[0].Main != `flase`].RouteTableId' \
--output text) &&
aws ec2 create-tags \
--resources $AWS_DEFAULT_ROUTE_TABLE_ID \
--tags "Key=Name,Value=SRIXX ruta por defecto"

## Añadir etiquetas a la tabla de rutas
aws ec2 create-tags \
--resources $AWS_ID_TablaRutas \
--tags "Key=Name,Value=SRIXX tabla de rutas"