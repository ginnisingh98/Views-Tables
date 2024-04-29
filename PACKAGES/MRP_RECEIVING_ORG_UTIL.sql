--------------------------------------------------------
--  DDL for Package MRP_RECEIVING_ORG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RECEIVING_ORG_UTIL" AUTHID CURRENT_USER AS
/* $Header: MRPURCOS.pls 115.1 99/07/16 12:39:54 porting ship $ */

--  Attributes global constants

G_SR_RECEIPT_ID               CONSTANT NUMBER := 1;
G_ATTRIBUTE1                  CONSTANT NUMBER := 2;
G_ATTRIBUTE10                 CONSTANT NUMBER := 3;
G_ATTRIBUTE11                 CONSTANT NUMBER := 4;
G_ATTRIBUTE12                 CONSTANT NUMBER := 5;
G_ATTRIBUTE13                 CONSTANT NUMBER := 6;
G_ATTRIBUTE14                 CONSTANT NUMBER := 7;
G_ATTRIBUTE15                 CONSTANT NUMBER := 8;
G_ATTRIBUTE2                  CONSTANT NUMBER := 9;
G_ATTRIBUTE3                  CONSTANT NUMBER := 10;
G_ATTRIBUTE4                  CONSTANT NUMBER := 11;
G_ATTRIBUTE5                  CONSTANT NUMBER := 12;
G_ATTRIBUTE6                  CONSTANT NUMBER := 13;
G_ATTRIBUTE7                  CONSTANT NUMBER := 14;
G_ATTRIBUTE8                  CONSTANT NUMBER := 15;
G_ATTRIBUTE9                  CONSTANT NUMBER := 16;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_DISABLE_DATE                CONSTANT NUMBER := 20;
G_EFFECTIVE_DATE              CONSTANT NUMBER := 21;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 22;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 23;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 24;
G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER := 25;
G_PROGRAM_ID                  CONSTANT NUMBER := 26;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 27;
G_RECEIPT_ORGANIZATION_ID     CONSTANT NUMBER := 28;
G_REQUEST_ID                  CONSTANT NUMBER := 29;
G_SOURCING_RULE_ID            CONSTANT NUMBER := 30;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 31;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
,   x_Receiving_Org_rec             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
,   x_Receiving_Org_rec             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;

--  Function Get_Values

FUNCTION Get_Values
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_Receiving_Org_val_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Val_Rec_Type
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;

END MRP_Receiving_Org_Util;

 

/
