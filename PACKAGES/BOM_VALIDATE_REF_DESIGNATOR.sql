--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_REF_DESIGNATOR" AUTHID CURRENT_USER AS
/* $Header: BOMLRFDS.pls 120.0 2005/05/25 07:05:01 appldev noship $ */
/*#
* This API contains the methods to validate BOM reference designators.
* @rep:scope private
* @rep:product BOM
* @rep:displayname Validate BOM Reference Designator Package
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
--      BOMLRFDS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Ref_Designator
--
--  NOTES
--
--  HISTORY
--
--  19-JUL-1999	Rahul Chitko	Initial Creation
--  05-JUL-2004 Hari Gelli    Added Check_Quantity procedure
*****************************************************************************/

--  Procedure Entity

/*#
* Check Entity will execute the business validations for the
* referenced designator entity .Any errors are loaded in the x_Mesg_Token_Tbl
* and a return status value is set.This can be used with ECO
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param p_Ref_Desg_Unexp_Rec Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity
*/

PROCEDURE Check_Entity
(   x_return_status		IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);

--  Procedure Attributes

/*#
* Check Attributes will validate individual attributes .Any errors will be populated in the
* x_Mesg_Token_Tbl and returned with a x_return_status.This can be used with ECO
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes
*/

PROCEDURE Check_Attributes
(   x_return_status		IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--  Procedure Entity_Delete
/*#
* Entity Delete method will verify if the entity can be
* deleted without violating any business rules.In case of errors the x_Mesg_token_Tbl is populated
* and process return with a status other than 'S' Warning will not prevent the entity from being
* deleted.This can be used with ECO
* @param x_return_status Indicating success or failure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param p_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity Delete
*/

PROCEDURE Check_Entity_Delete
(   x_return_status		IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);

/*#
* Check_Existence will perform a query using the primary key information and will return
* success if the operation is CREATE and the record EXISTS or will return an error if the operation
* is UPDATE and the record DOES NOT EXIST.In case of UPDATE if the record exists then the procedure
* will return the old record in the old entity parameters with a success status.This can be used with
* ECO
* @param p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param p_Ref_Desg_Unexp_Rec Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @param x_old_ref_designator_rec Old Reference Designator exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param x_old_ref_desg_unexp_rec Old Reference Designator unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence
*/


PROCEDURE Check_Existence
(  p_ref_designator_rec		IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec		IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_old_ref_designator_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
 , x_old_ref_desg_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
);

/*#
* Performs lineage checks for entity records that do not belong to the top-most entity in the hierarchy
* This can be used with ECO
* @param  p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param  p_Ref_Desg_Unexp_Rec Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Lineage
*/

PROCEDURE Check_Lineage
(  p_ref_designator_rec		IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec		IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
);

/*#
* Checks access constraints.This can be used with ECO
* @param  p_ref_designator_rec Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type }
* @param  p_Ref_Desg_Unexp_Rec Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type }
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Access
*/

PROCEDURE CHECK_ACCESS
(  p_ref_designator_rec IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
);

/*#
* This method will take the component_sequence_id and checks if the quantity related is
* set to yes for the component and if it is yes then calculates the number of designators
* by calling another method (Calculate_both_totals) and validates the totals and
* send back the error status or success
* @param  x_return_status Indicating success or faliure
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @param  p_component_sequence_id component sequence id
* @param  p_component_item_name component item name
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Quantity
*/


PROCEDURE Check_Quantity
(   x_return_status		IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_component_sequence_id	IN  NUMBER
,   p_component_item_name	IN  VARCHAR2
);

/*
** BOm Business Object Definitions
*/

/*#
* Check Entity will convert the BOM Record to ECO and execute the business validations for the
* referenced designator entity .Any errors are loaded in the x_Mesg_Token_Tbl
* and a return status value is set
* @param  x_return_status Indicating success or faliure
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  p_bom_ref_designator_rec BomReference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @param  p_bom_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity
*/
PROCEDURE Check_Entity
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
);

--  Procedure Attributes

/*#
* Check Attributes convert the BOM Record to ECO and will validate individual
* attributes .Any errors will be populated in the x_Mesg_Token_Tbl and returned with a x_return_status
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_bom_ref_designator_rec Bom Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes
*/

PROCEDURE Check_Attributes
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_Bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
);

--  Procedure Entity_Delete
/*#
* Entity Delete method will convert the BOM Record to ECO and verify if the entity can be
* deleted without violating any business rules.In case of errors the x_Mesg_token_Tbl is populated
* and process return with a status other than 'S' Warning will not prevent the entity from being
* deleted
* @param x_return_status Indicating success or failure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_bom_ref_designator_rec Bom Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @param p_bom_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity Delete
*/

PROCEDURE Check_Entity_Delete
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
);

/*#
* Check_Existence will convert the BOM Record to ECO and perform a query using the primary key information and will return
* success if the operation is CREATE and the record EXISTS or will return an error if the operation
* is UPDATE and the record DOES NOT EXIST.In case of UPDATE if the record exists then the procedure
* will return the old record in the old entity parameters with a success status.
* @param p_bom_ref_designator_rec Bom Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @param p_bom_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type }
* @param x_old_bom_ref_designator_rec Old Bom Reference Designator exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type }
* @param x_old_bom_ref_desg_unexp_rec Old Bom Reference Designator unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence
*/

PROCEDURE Check_Existence
(  p_bom_ref_designator_rec         IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_old_bom_ref_designator_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , x_old_bom_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

/*#
* Converts the BOM Record to ECO and Performs lineage checks for entity records that do not
* belong to the top-most entity in the hierarchy
* @param  p_bom_ref_designator_rec Bom Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.bom_Ref_Designator_Rec_Type }
* @param  p_bom_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.bom_Ref_Desg_Unexposed_Rec_Type }
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Lineage
*/

PROCEDURE Check_Lineage
(  p_bom_ref_designator_rec         IN  Bom_Bo_Pub.bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec         IN  Bom_Bo_Pub.bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

/*#
* Check Access converts the BOM Record to ECO and checks access constraints
* @param  p_bom_ref_designator_rec Bom Reference Designator Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.bom_Ref_Designator_Rec_Type }
* @param  p_bom_Ref_Desg_Unexp_Rec Bom Reference Designator Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.bom_Ref_Desg_Unexposed_Rec_Type }
* @param  x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param  x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Access
*/

PROCEDURE CHECK_ACCESS
(  p_bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
);

END BOM_Validate_Ref_Designator;

 

/
