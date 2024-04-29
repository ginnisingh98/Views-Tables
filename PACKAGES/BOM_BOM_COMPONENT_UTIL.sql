--------------------------------------------------------
--  DDL for Package BOM_BOM_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOM_COMPONENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUCMPS.pls 120.0.12010000.2 2010/02/03 17:53:06 umajumde ship $ */
/*#
* This API contains entity utility method for the Bill of Materials Components.
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Component Util Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/

--  PROCEDURE Convert_Miss_To_Null

/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* @param p_bom_component_rec Bom Component exposed column record
* @rep:paraminfo { @rep:innertype  Bom_Bo_Pub.Bom_Comps_Rec_Type}
* @param p_bom_comp_unexp_rec Bom component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type }
* @param x_bom_component_rec Bom Component exposed column record
* @rep:paraminfo { @rep:innertype  Bom_Bo_Pub.Bom_Comps_Rec_Type}
* @param x_bom_comp_unexp_rec Bom component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/


PROCEDURE Convert_Miss_To_Null
( p_bom_component_rec           IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
, p_bom_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
, x_bom_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
, x_bom_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
);

/*#
* Perform Writes is the only exposed method that the user will have access, to perform
* any insert/update/deletes to the Inventory Components table
* @param p_bom_component_rec Bom Component exposed column record
* @rep:paraminfo { @rep:innertype  Bom_Bo_Pub.Bom_Comps_Rec_Type}
* @param p_bom_comp_unexp_rec Bom component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/


PROCEDURE Perform_Writes
(  p_bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
 , p_bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
);

/*#
* Procedure will query the database record, seperate the  values into exposed columns
* and unexposed columns and return those records
* @param p_Component_Item_Id Component item id
* @param p_Operation_Sequence_Number  Operation Sequence number
* @param p_Effectivity_Date Effectivity date
* @param p_Bill_Sequence_Id Bill sequence id
* @param p_from_end_item_number from end item number
* @param x_Bom_Component_Rec Bom component Exposed column Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
* @param x_Bom_Comp_Unexp_Rec Bom component Unexposed column Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type }
* @param x_Return_status Return Status
* @param p_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/


PROCEDURE Query_Row
( p_Component_Item_Id           IN  NUMBER
, p_Operation_Sequence_Number   IN  NUMBER
, p_Effectivity_Date            IN  DATE
, p_Bill_Sequence_Id            IN  NUMBER
, p_from_end_item_number        IN  VARCHAR2 := NULL
, x_Bom_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
, x_Bom_Comp_Unexp_Rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
, x_Return_Status            IN OUT NOCOPY VARCHAR2
, p_Mesg_Token_Tbl              IN  Error_Handler.Mesg_Token_Tbl_Type
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);


/** ECO BO Routine definitions **/
/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.This can be used with ECO
* @param p_Component_Item_Id Component item id
* @param p_Operation_Sequence_Number  Operation Sequence number
* @param p_Effectivity_Date Effectivity date
* @param p_Bill_Sequence_Id Bill sequence id
* @param x_Rev_Component_Rec Revision component Exposed column Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
* @param x_Rev_Comp_Unexp_Rec Revision component Unexposed column Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type }
* @param x_Return_status Return Status
* @param p_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/

PROCEDURE Query_Row
( p_Component_Item_Id           IN  NUMBER
, p_Operation_Sequence_Number   IN  NUMBER
, p_Effectivity_Date            IN  DATE
, p_Bill_Sequence_Id            IN  NUMBER
, p_from_end_item_number        IN  VARCHAR2 := NULL
, x_Rev_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Return_Status               IN OUT NOCOPY VARCHAR2
, p_Mesg_Token_Tbl		IN Error_Handler.Mesg_Token_Tbl_Type
, x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);


/*#
* Perform Writes is the only exposed method that the user will have access, to perform
* any insert/update/deletes to the Inventory Components table.This can be used with ECO
* @param p_rev_component_rec Revision Component exposed column record
* @rep:paraminfo { @rep:innertype  Bom_Bo_Pub.Rev_Component_Rec_Type}
* @param p_rev_comp_unexp_rec Revision component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type }
* @param  p_control_rec control record.This is defaulted as  BOM_BO_PUB.G_DEFAULT_CONTROL_REC
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Control_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/

PROCEDURE Perform_Writes(  p_rev_component_rec  IN
                           Bom_Bo_Pub.Rev_Component_Rec_Type
                         , p_rev_comp_unexp_rec IN
                           Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
                         , p_control_rec        IN
                           Bom_Bo_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
                        , x_Mesg_Token_Tbl     IN OUT NOCOPY
                           Error_Handler.Mesg_Token_Tbl_Type
                         , x_Return_Status      IN OUT NOCOPY VARCHAR2
                         );


/*#
* Cancel component
* @param p_component_sequence_id component sequence id
* @param p_cancel_comments comments for cancelling
* @param p_user_id  user id
* @param p_login_id login id
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Cancel component
*/


PROCEDURE Cancel_Component(  p_component_sequence_id    IN  NUMBER
                           , p_cancel_comments          IN  VARCHAR2
                           , p_user_id                  IN  NUMBER
                           , p_login_id                 IN  NUMBER
                           );
/*#
* This method will be called when a revised component is the first component being added on a
* revised item. This method will create a Bill and update the revised item information indicating
* that bill for this revised item now exists.
* @param p_assembly_item_id Assembly Item ID
* @param p_organization_id Organization ID
* @param p_pending_from_ecn Pending from ECN
* @param p_bill_sequence_id bill sequence id
* @param p_common_bill_sequence_id common bill sequence id
* @param p_assembly_type assembly type
* @param p_last_update_date WHO column
* @param p_last_updated_by WHO column
* @param p_creation_date WHO column
* @param p_created_by  WHO column
* @param p_revised_item_seq_id revised item sequence id
* @param p_original_system_reference Legacy system form which the original data has come from.
* @param p_alternate_bom_code alternate bom designator
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Create New Bill
*/


PROCEDURE Create_New_Bill(  p_assembly_item_id           IN NUMBER
                          , p_organization_id            IN NUMBER
                          , p_pending_from_ecn           IN VARCHAR2
                          , p_bill_sequence_id           IN NUMBER
                          , p_common_bill_sequence_id    IN NUMBER
                          , p_assembly_type              IN NUMBER
                          , p_last_update_date           IN DATE
                          , p_last_updated_by            IN NUMBER
                          , p_creation_date              IN DATE
                          , p_created_by                 IN NUMBER
                          , p_revised_item_seq_id        IN NUMBER
			  , p_original_system_reference  IN VARCHAR2
			  , p_alternate_bom_code	 IN VARCHAR2 := null
                          );

/*#
* This method will convert the missing values of some attributes that the user wishes to NULL
* @param p_rev_component_rec Revision Component exposed column record.This can be used with ECO
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type }
* @param p_rev_comp_unexp_rec Revision component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type }
* @param x_Rev_component_rec Revision Component exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
* @param x_Rev_comp_unexp_rec Revision component unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Miss To Null
*/

PROCEDURE Convert_Miss_To_Null
( p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

--added this function for Bug 7713832
FUNCTION Get_Src_Comp_Seq_Id(p_component_item_id   IN  NUMBER
                              , p_start_effective_date  IN  DATE
                              , p_op_seq_num      IN  NUMBER
                              , p_bill_sequence_id    IN  NUMBER
                             ) RETURN NUMBER;

END Bom_Bom_Component_Util;

-- SHOW ERRORS PACKAGE Bom_Bom_Component_Util;

/
