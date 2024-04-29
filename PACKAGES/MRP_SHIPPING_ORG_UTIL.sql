--------------------------------------------------------
--  DDL for Package MRP_SHIPPING_ORG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SHIPPING_ORG_UTIL" AUTHID CURRENT_USER AS
/* $Header: MRPUSHOS.pls 115.2 99/07/16 12:40:27 porting ship $ */

--  Attributes global constants

G_SR_SOURCE_ID                CONSTANT NUMBER := 1;
G_ALLOCATION_PERCENT          CONSTANT NUMBER := 2;
G_ATTRIBUTE1                  CONSTANT NUMBER := 3;
G_ATTRIBUTE10                 CONSTANT NUMBER := 4;
G_ATTRIBUTE11                 CONSTANT NUMBER := 5;
G_ATTRIBUTE12                 CONSTANT NUMBER := 6;
G_ATTRIBUTE13                 CONSTANT NUMBER := 7;
G_ATTRIBUTE14                 CONSTANT NUMBER := 8;
G_ATTRIBUTE15                 CONSTANT NUMBER := 9;
G_ATTRIBUTE2                  CONSTANT NUMBER := 10;
G_ATTRIBUTE3                  CONSTANT NUMBER := 11;
G_ATTRIBUTE4                  CONSTANT NUMBER := 12;
G_ATTRIBUTE5                  CONSTANT NUMBER := 13;
G_ATTRIBUTE6                  CONSTANT NUMBER := 14;
G_ATTRIBUTE7                  CONSTANT NUMBER := 15;
G_ATTRIBUTE8                  CONSTANT NUMBER := 16;
G_ATTRIBUTE9                  CONSTANT NUMBER := 17;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 21;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 22;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 23;
G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER := 24;
G_PROGRAM_ID                  CONSTANT NUMBER := 25;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 26;
G_RANK                        CONSTANT NUMBER := 28;
G_REQUEST_ID                  CONSTANT NUMBER := 29;
G_SECONDARY_INVENTORY         CONSTANT NUMBER := 30;
G_SHIP_METHOD                 CONSTANT NUMBER := 31;
G_SOURCE_ORGANIZATION_ID      CONSTANT NUMBER := 32;
G_SOURCE_TYPE                 CONSTANT NUMBER := 33;
G_SR_RECEIPT_ID               CONSTANT NUMBER := 34;
G_VENDOR_ID                   CONSTANT NUMBER := 36;
G_VENDOR_SITE_ID              CONSTANT NUMBER := 37;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 38;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   p_old_Shipping_Org_rec          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   p_old_Shipping_Org_rec          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   p_old_Shipping_Org_rec          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;

--  Function Get_Values

FUNCTION Get_Values
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   p_old_Shipping_Org_rec          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   p_Shipping_Org_val_rec          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;

END MRP_Shipping_Org_Util;

 

/
