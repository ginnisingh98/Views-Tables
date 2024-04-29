--------------------------------------------------------
--  DDL for Package MRP_ASSIGNMENT_SET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ASSIGNMENT_SET_UTIL" AUTHID CURRENT_USER AS
/* $Header: MRPUASTS.pls 115.2 99/07/16 12:39:18 porting ship $ */

--  Attributes global constants

G_ASSIGNMENT_SET_ID           CONSTANT NUMBER := 1;
G_ASSIGNMENT_SET_NAME         CONSTANT NUMBER := 2;
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
G_DESCRIPTION                 CONSTANT NUMBER := 21;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 22;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 23;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 24;
G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER := 25;
G_PROGRAM_ID                  CONSTANT NUMBER := 26;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 27;
G_REQUEST_ID                  CONSTANT NUMBER := 28;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 29;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;

--  Function Get_Values

FUNCTION Get_Values
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_Assignment_Set_val_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;

END MRP_Assignment_Set_Util;

 

/
