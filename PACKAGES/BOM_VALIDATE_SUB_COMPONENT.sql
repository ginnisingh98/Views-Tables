--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_SUB_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: BOMLSBCS.pls 120.0 2005/05/25 05:49:50 appldev noship $ */
/*#
* This API contains the methods to validate BOM Sub Components.
* @rep:scope private
* @rep:product BOM
* @rep:displayname Validate BOM Sub Component Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/*****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLSBCS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Sub_Component
--
--  NOTES
--
--  HISTORY
--
--  17-JUL-1999	Rahul Chitko	Initial Creation
--
*****************************************************************************/

/*#
* Log an error if one of the required columns is missing.This can be used with ECO
* @param x_return_status Indicating success or faliure
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Required
*/

PROCEDURE CHECK_REQUIRED(  x_return_status      IN OUT NOCOPY VARCHAR2
                         , p_sub_component_rec   IN
                           Bom_Bo_Pub.Sub_Component_Rec_Type
                         , x_Mesg_Token_tbl     IN OUT NOCOPY
                           Error_Handler.Mesg_Token_Tbl_Type
                         );

--  Procedure Entity

/*#
* Check Entity method will validate the entity record by verfying the business logic for
* Substitute Components.This can be used with ECO
* @param  x_return_status Indicating success or faliure
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param  p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param p_control_rec This is defaulted to BOM_BO_PUB.G_DEFAULT_CONTROL_REC
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.Control_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity
*/

PROCEDURE Check_Entity
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   p_control_rec		    IN  BOM_BO_PUB.Control_Rec_Type
					:= BOM_BO_PUB.G_DEFAULT_CONTROL_REC
);

--  Procedure Attributes

/*#
* Method Check Attributes will verify the validity of all exposed columns to check if the user has given
* values that the columns can actually hold.This can be used with ECO
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param  p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes
*/

PROCEDURE Check_Attributes
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

--  Procedure Entity_Delete

/*#
* Entity_Delete method will verify if the record can be delete without violating
* any dependency rules.This can be used with ECO
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity Delete
*/


PROCEDURE Check_Entity_Delete
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

/*#
* This method will verify if the user given record exists when the operation is Update/Delete
* and does not exist when the operation is Create. If the operation is Update/Delete
* the procedure will query the existing record and return them as old records
* This can be used with ECO
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_old_sub_component_rec Old sub component exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param x_old_sub_comp_unexp_rec Old sub component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence
*/

PROCEDURE Check_Existence
(  p_sub_component_rec		IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec		IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_old_sub_component_rec	IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
 , x_old_sub_comp_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
);

/*#
* This method will verify that the parent-child relationship hold good in the production tables
* based on the data that the user has given.This can be used with ECO
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Lineage
*/

PROCEDURE Check_Lineage
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);


/*#
* If the System Information record values are not already filled the process will query the
* appropriate profile values and verify that the user has access to the Revised Item, the
* parent component item and the item type of the substitute Component. It will also verify that
* the revised item is not already implemented or canceled.This can be used with ECO
* @param p_sub_component_rec Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type }
* @param p_sub_comp_Unexp_Rec Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Access
*/

PROCEDURE Check_Access
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

/*
** Procedures for BOM Business Object
*/

/*#
* Log an error if one of the required columns is missing
* @param x_return_status Indicating success or faliure
* @param p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Required
*/

PROCEDURE Check_Required
(  x_return_status      	IN OUT NOCOPY VARCHAR2
 , p_bom_sub_component_rec	IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , x_Mesg_Token_tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 );

--  Procedure Entity

/*#
* Check Entity method will validate the entity record by verfying the business logic for Bom
* Substitute Components
* @param  x_return_status Indicating success or faliure
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param  p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity
*/

PROCEDURE Check_Entity
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_sub_component_rec         IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   p_bom_Sub_Comp_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
);

--  Procedure Attributes

/*#
* Method Check Attributes will verify the validity of all exposed columns to check if the user has given
* values that the columns can actually hold
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param  p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes
*/


PROCEDURE Check_Attributes
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_sub_component_rec          IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   p_bom_Sub_Comp_Unexp_Rec         IN Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
);

--  Procedure Entity_Delete

/*#
* Entity_Delete method will verify if the record can be delete without violating
* any dependency rules
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param  p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity Delete
*/


PROCEDURE Check_Entity_Delete
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_sub_component_rec          IN Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   p_bom_Sub_Comp_Unexp_Rec         IN Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
);

/*#
* This method will verify if the user given record exists when the operation is Update/Delete
* and does not exist when the operation is Create. If the operation is Update/Delete
* the procedure will query the existing record and return them as old records
* @param p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_old_bom_sub_component_rec Old Bom sub component exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param x_old_bom_sub_comp_unexp_rec Old Bom sub component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence
*/

PROCEDURE Check_Existence
(  p_bom_sub_component_rec          IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_old_bom_sub_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , x_old_bom_sub_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl                 IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status                  IN OUT NOCOPY VARCHAR2
);

/*#
* This method will verify that the parent-child relationship hold good in the production tables
* based on the data that the user has given
* @param p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Lineage
*/

PROCEDURE Check_Lineage
(  p_bom_sub_component_rec      IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

/*#
* If the System Information record values are not already filled the process will query the
* appropriate profile values and verify that the user has access to the Revised Item, the
* parent component item and the item type of the substitute Component. It will also verify that
* the revised item is not already implemented or canceled.
* @param p_bom_sub_component_rec Bom Substitute Component Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type }
* @param p_bom_sub_comp_Unexp_Rec Bom Substitute component Record of Unexposed Columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Access
*/

PROCEDURE Check_Access
(  p_bom_sub_component_rec      IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

END BOM_Validate_Sub_Component;

 

/
