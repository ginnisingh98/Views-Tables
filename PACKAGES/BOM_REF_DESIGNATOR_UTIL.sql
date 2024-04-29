--------------------------------------------------------
--  DDL for Package BOM_REF_DESIGNATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_REF_DESIGNATOR_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMURFDS.pls 120.0.12010000.2 2010/02/03 17:19:56 umajumde ship $ */
/*#
* This API contains entity utility method for the Bill of Materials Reference
* Designators.
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Reference Designator Util Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMURFDS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Ref_Designator_Util
--
--  NOTES
--
--  HISTORY
--
--  19-JUL-1999	Rahul Chitko	Initial Creation
--
*****************************************************************************/
--  Attributes global constants

G_REF_DESIGNATOR              CONSTANT NUMBER := 1;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 2;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 3;
G_CREATION_DATE               CONSTANT NUMBER := 4;
G_CREATED_BY                  CONSTANT NUMBER := 5;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 6;
G_REF_DESIGNATOR_COMMENT      CONSTANT NUMBER := 7;
G_CHANGE_NOTICE               CONSTANT NUMBER := 8;
G_COMPONENT_SEQUENCE          CONSTANT NUMBER := 9;
G_ACD_TYPE                    CONSTANT NUMBER := 10;
G_REQUEST                     CONSTANT NUMBER := 11;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 12;
G_PROGRAM                     CONSTANT NUMBER := 13;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 14;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 15;
G_ATTRIBUTE1                  CONSTANT NUMBER := 16;
G_ATTRIBUTE2                  CONSTANT NUMBER := 17;
G_ATTRIBUTE3                  CONSTANT NUMBER := 18;
G_ATTRIBUTE4                  CONSTANT NUMBER := 19;
G_ATTRIBUTE5                  CONSTANT NUMBER := 20;
G_ATTRIBUTE6                  CONSTANT NUMBER := 21;
G_ATTRIBUTE7                  CONSTANT NUMBER := 22;
G_ATTRIBUTE8                  CONSTANT NUMBER := 23;
G_ATTRIBUTE9                  CONSTANT NUMBER := 24;
G_ATTRIBUTE10                 CONSTANT NUMBER := 25;
G_ATTRIBUTE11                 CONSTANT NUMBER := 26;
G_ATTRIBUTE12                 CONSTANT NUMBER := 27;
G_ATTRIBUTE13                 CONSTANT NUMBER := 28;
G_ATTRIBUTE14                 CONSTANT NUMBER := 29;
G_ATTRIBUTE15                 CONSTANT NUMBER := 30;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 31;

--  Procedure Clear_Dependent_Attr

/*#
* Clear Dependent Attributes
* @param p_attr_id attribute id
* @param p_ref_designator_rec reference designator record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param p_old_ref_designator_rec old reference designator record. This is defaulted to
* Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param x_ref_designator_rec returned reference designator record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Clear Dependent Attributes
*/


PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--added for bug 7713832
FUNCTION Common_CompSeqIdRD( p_comp_seq_id NUMBER)
RETURN NUMBER;

--  Procedure Apply_Attribute_Changes

/*#
* Apply Attribute Changes
* @param p_ref_designator_rec reference designator record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param p_old_ref_designator_rec old reference designator record. This is defaulted to
* Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param x_ref_designator_rec returned reference designator record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Apply Attribute Changes
*/

PROCEDURE Apply_Attribute_Changes
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--  Function Convert_Miss_To_Null

/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* This can be used with ECO
* @param p_ref_designator_rec the record that need to be converted
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @return the converted record
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/


FUNCTION Convert_Miss_To_Null
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
) RETURN Bom_Bo_Pub.Ref_Designator_Rec_Type;

--  Function Query_Row

/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.This can be used with ECO
* @param p_ref_designator This with the next two parameters form Reference Designator Key
* @param p_component_sequence_id component sequence id
* @param p_acd_type acd type
* @param x_Ref_Designator_Rec Reference Designator Record of exposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param x_Ref_Desg_Unexp_Rec Reference Designator Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
* @param x_Return_Status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/


PROCEDURE Query_Row
(   p_ref_designator            IN  VARCHAR2
,   p_component_sequence_id     IN  NUMBER
,   p_acd_type                  IN  NUMBER
,   x_Ref_Designator_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Return_Status		IN OUT NOCOPY VARCHAR2
);

/*#
* Perform Writes is the only exposed method that the user will have access, to perform
* any insert/update/deletes to corresponding database tables . This can be used with ECO
* @param p_ref_designator_rec Reference Designator exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_rec_Type }
* @param p_ref_desg_unexp_rec Reference Designator unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @param  p_control_rec control record.This is defaulted as  BOM_BO_PUB.G_DEFAULT_CONTROL_REC
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Control_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/

PROCEDURE Perform_Writes
(  p_ref_designator_rec         IN  Bom_Bo_Pub.Ref_Designator_rec_Type
 , p_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , p_control_rec        	IN  BOM_BO_PUB.Control_Rec_Type
                            	:= BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
);

/*
** Definitions for the BOM Business Object
*/


/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* @param p_bom_ref_designator_rec the record that need to be converted
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @return the converted record
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/
FUNCTION Convert_Miss_To_Null
(   p_bom_ref_designator_rec       IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
) RETURN Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;

--  Function Query_Row


/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records
* @param p_bom_ref_designator This with the next two parameters form Reference Designator Key
* @param p_component_sequence_id component sequence id
* @param p_acd_type acd type
* @param x_bom_Ref_Designator_Rec Reference Designator Record of exposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @param x_bom_Ref_Desg_Unexp_Rec Reference Designator Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type}
* @param x_Return_Status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/

PROCEDURE Query_Row
(   p_bom_ref_designator        IN  VARCHAR2
,   p_component_sequence_id     IN  NUMBER
,   p_acd_type                  IN  NUMBER
,   x_bom_Ref_Designator_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_Ref_Desg_Unexp_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_Return_Status             IN OUT NOCOPY VARCHAR2
);

/*#
* Perform Writes is the only exposed method that the user will have access to perform any
* insert/update/deletes to corresponding database tables
* @param p_bom_ref_designator_rec BomReference Designator exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_rec_Type }
* @param p_bom_ref_desg_unexp_rec Bom Reference Designator unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/

PROCEDURE Perform_Writes
(  p_bom_ref_designator_rec      IN Bom_Bo_Pub.Bom_Ref_Designator_rec_Type
 , p_bom_ref_desg_unexp_rec      IN Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
);

END BOM_Ref_Designator_Util;

/
