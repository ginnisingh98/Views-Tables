--------------------------------------------------------
--  DDL for Package BOM_SUB_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SUB_COMPONENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUSBCS.pls 120.0.12010000.2 2010/02/03 17:25:58 umajumde ship $ */
/*#
* This API contains entity utility methods for the Bill of Materials Sub
* Components
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Sub Component Util Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUSBCS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Sub_Component_Util
--
--  NOTES
--
--  HISTORY
--
--  17-JUL-1999	Rahul Chitko	Initial Creation
--
****************************************************************************/
--  Attributes global constants

G_SUBSTITUTE_COMPONENT        CONSTANT NUMBER := 1;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 2;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 3;
G_CREATION_DATE               CONSTANT NUMBER := 4;
G_CREATED_BY                  CONSTANT NUMBER := 5;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 6;
G_SUBSTITUTE_ITEM_QUANTITY    CONSTANT NUMBER := 7;
G_COMPONENT_SEQUENCE          CONSTANT NUMBER := 8;
G_ACD_TYPE                    CONSTANT NUMBER := 9;
G_CHANGE_NOTICE               CONSTANT NUMBER := 10;
G_REQUEST                     CONSTANT NUMBER := 11;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 12;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 13;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 14;
G_ATTRIBUTE1                  CONSTANT NUMBER := 15;
G_ATTRIBUTE2                  CONSTANT NUMBER := 16;
G_ATTRIBUTE4                  CONSTANT NUMBER := 17;
G_ATTRIBUTE5                  CONSTANT NUMBER := 18;
G_ATTRIBUTE6                  CONSTANT NUMBER := 19;
G_ATTRIBUTE8                  CONSTANT NUMBER := 20;
G_ATTRIBUTE9                  CONSTANT NUMBER := 21;
G_ATTRIBUTE10                 CONSTANT NUMBER := 22;
G_ATTRIBUTE12                 CONSTANT NUMBER := 23;
G_ATTRIBUTE13                 CONSTANT NUMBER := 24;
G_ATTRIBUTE14                 CONSTANT NUMBER := 25;
G_ATTRIBUTE15                 CONSTANT NUMBER := 26;
G_PROGRAM                     CONSTANT NUMBER := 27;
G_ATTRIBUTE3                  CONSTANT NUMBER := 28;
G_ATTRIBUTE7                  CONSTANT NUMBER := 29;
G_ATTRIBUTE11                 CONSTANT NUMBER := 30;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 31;

--  Function Convert_Miss_To_Null

/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* This can be used with ECO
* @param p_sub_component_rec the record that need to be converted
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @return the converted record
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/


FUNCTION Convert_Miss_To_Null
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
) RETURN Bom_Bo_Pub.Sub_Component_Rec_Type;

--added for bug 7713832
FUNCTION Common_CompSeqIdSC( p_comp_seq_id NUMBER)
RETURN NUMBER;

--  Function Query_Row

/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.This can be used with ECO
* @param p_substitute_component_id The IN parameters form the Substitute Component primary key
* @param p_component_sequence_id componenet sequence id
* @param p_acd_type acd type
* @param x_Sub_Component_Rec Substitute Component Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param x_Sub_Comp_Unexp_Rec Substitute Component record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/

PROCEDURE Query_Row
(   p_substitute_component_id       IN  NUMBER
,   p_component_sequence_id         IN  NUMBER
,   p_acd_type                      IN  NUMBER
,   x_Sub_Component_Rec		    IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_Sub_Comp_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

/*#
* Locks the row
* @param x_return_status Indicating success or faliure
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param x_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param x_err_text error text
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Lock Row
*/



PROCEDURE Lock_Row
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   p_sub_component_rec             IN Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,  x_err_text			    IN OUT NOCOPY VARCHAR2
);

/*#
* Perform Writes is the only exposed method that the user will have access to
* perform any insert/update/deletes to corresponding database tables.This can be used with ECO
* @param p_Sub_Component_Rec Substitute Component Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param p_Sub_Comp_Unexp_Rec Substitute Component record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/


PROCEDURE Perform_Writes
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

/*
** Procedures for BOM Business Object
*/

/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* @param p_bom_sub_component_rec  the record that need to be converted
* @rep:paraminfo { @rep:innertype  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @return the converted record
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/

FUNCTION Convert_Miss_To_Null
(   p_bom_sub_component_rec         IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
) RETURN Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;

--  Function Query_Row

/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records
* @param p_substitute_component_id The IN parameters form the Substitute Component primary key
* @param p_component_sequence_id componenet sequence id
* @param p_acd_type acd type
* @param x_bom_Sub_Component_Rec Bom Substitute Component Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param x_bom_Sub_Comp_Unexp_Rec Bom Substitute Component record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/


PROCEDURE Query_Row
(   p_substitute_component_id  IN  NUMBER
,   p_component_sequence_id    IN  NUMBER
,   p_acd_type                 IN  NUMBER
,   x_bom_Sub_Component_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   x_bom_Sub_Comp_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_return_status            IN OUT NOCOPY VARCHAR2
);

/*#
* Perform Writes is the only exposed method that the user will have access to perform any
* insert/update/deletes to corresponding database tables
* @param p_bom_Sub_Component_Rec Bom Substitute Component Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param p_bom_Sub_Comp_Unexp_Rec Bom Substitute Component record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/


PROCEDURE Perform_Writes
(  p_bom_sub_component_rec      IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

END BOM_Sub_Component_Util;

/
