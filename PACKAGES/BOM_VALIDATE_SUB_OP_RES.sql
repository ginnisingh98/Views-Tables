--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_SUB_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_SUB_OP_RES" AUTHID CURRENT_USER AS
/* $Header: BOMLSORS.pls 120.1.12000000.2 2007/10/17 13:52:22 jiabraha ship $ */
/*#
 * This API contains Attribute and Entity level validation for the Bill of Materials Sub Operation Resource Records.
 * This contains procedures for
 *	 Checking the existence of the Sub Operation Resource record in case of create,update or delete.
 *       Checking the acces rights of the user to the Assembly Item's BOM Item Type.
 *	 Checking the validity of all Sub Operation Resource Attributes
 * 	 Checking the required fields in the Sub Operation Resource Record.
 * 	 Checking the Business Logic validation for the Sub Operation Resource Entity.
 *  	 Checking the Delete Constraints for Sub Operation Resource.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Sub Operation Resource
 * @rep:compatibility S
 */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMLSORS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Sub_Op_Res
--
--  NOTES
--
--  HISTORY
--  22-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/


/****************************************************************************
*  CHECK EXISTENCE
*****************************************************************************/


-- Check_Existence used by RTG BO
PROCEDURE Check_Existence
(  p_sub_resource_rec        IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , p_sub_res_unexp_rec       IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , x_old_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , x_old_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status           IN OUT NOCOPY VARCHAR2
) ;

-- Check_Existence used by ECO BO and internally called by RTG BO
PROCEDURE Check_Existence
(  p_rev_sub_resource_rec       IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , p_rev_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , x_old_rev_sub_resource_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , x_old_rev_sub_res_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
) ;




/****************************************************************************
*  CHECK ATTRIBUTES
*****************************************************************************/

-- Check_Attributes used by RTG BO
/*#
 * This method as used by Routing BO checks for each of the attribute/field individually for validity.
 * Examples of these checks are: range checks, checks against lookups etc. It checks
 * whether user-entered attributes are valid and it also checks each attribute independently of the others
 * It raises
 *	1 Severe Error IV in case of Create transaction type
 *	2 Standard Error in case of other transaction types.
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param p_sub_resource_rec IN Sub Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param p_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:displayname Check Sub Operation Resource Attributes
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Attributes
(  p_sub_resource_rec   IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , p_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;


-- Check_Attributes used by ECO BO and internally called by RTG BO
/*#
 * This method as used by ECO BO checks for each of the attribute/field individually for validity.
 * Examples of these checks are: range checks, checks against lookups etc. It checks
 * whether user-entered attributes are valid and it also checks each attribute independently of the others
 * It raises
 *	1 Severe Error IV in case of Create transaction type
 *	2 Standard Error in case of other transaction types.
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param p_rev_sub_resource_rec IN Sub Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param p_rev_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:displayname Check Sub Operation Resource Attributes
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Attributes
(  p_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , p_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK ENTITY ATTRIBUTES
*****************************************************************************/

-- Check_Entity used by RTG BO
/*#
 * This as used by Routing BO is where the whole record is checked. The following are checked
 *	Non-updatable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
 *	Business logic: The record must comply with business logic rules.
 * It raises
 *	1 Severe Error IV for Create transaction type.
 *	2 Standard Error for Update transaction type.
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param p_sub_resource_rec IN Sub Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param p_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @param p_old_sub_resource_rec IN Sub Operation Resource Old Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param p_old_sub_res_unexp_rec IN Sub Operation Resource Old Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @param x_sub_resource_rec IN Sub Operation Resource Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param x_sub_res_unexp_rec IN Sub Operation Resource Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:displayname Check Sub Operation Resource Entity
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

PROCEDURE Check_Entity
(  p_sub_resource_rec      IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , p_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , p_old_sub_resource_rec  IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , p_old_sub_res_unexp_rec IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , x_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
 , x_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         IN OUT NOCOPY VARCHAR2
) ;

-- Check_Entity used by ECO BO and internally called by RTG BO
/*#
 * This as used by ECO BO is where the whole record is checked. The following are checked
 *	Non-updatable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
 *	Business logic: The record must comply with business logic rules.
 * It raises
 *	1 Severe Error IV for Create transaction type.
 *	2 Standard Error for Update transaction type.
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param p_rev_sub_resource_rec IN Sub Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param p_rev_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @param p_old_rev_sub_resource_rec IN Sub Operation Resource Old Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param p_old_rev_sub_res_unexp_rec IN Sub Operation Resource Old Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @param p_control_Rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_rev_sub_resource_rec IN Sub Operation Resource Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param x_rev_sub_res_unexp_rec IN Sub Operation Resource Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:displayname Check Component Entity
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */

PROCEDURE Check_Entity
(  p_rev_sub_resource_rec      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , p_rev_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , p_old_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , p_old_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
 , x_rev_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
 , x_rev_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status             IN OUT NOCOPY VARCHAR2
) ;



/****************************************************************************
*  OTHERS
*****************************************************************************/

PROCEDURE   Val_Scheduled_Sub_Resource
( p_op_seq_id     IN  NUMBER
, p_resource_id   IN  NUMBER
, p_sub_group_num IN  NUMBER
, p_schedule_flag IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;


PROCEDURE   Val_Sub_PO_Move
( p_op_seq_id     IN  NUMBER
, p_resource_id   IN  NUMBER
, p_sub_group_num IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;

 /* Fix for bug 6074930 - Added below procedure val_schedule_flag.*/
     PROCEDURE Val_Schedule_Flag
    (  p_op_seq_id     IN  NUMBER
     , p_res_seq_num   IN  NUMBER
     , p_sch_seq_num   IN  NUMBER
     , p_sch_flag      IN  NUMBER
     , p_sub_grp_num   IN  NUMBER
     , p_rep_grp_num   IN  NUMBER
     , p_basis_type    IN  NUMBER
     , p_in_res_id     IN  NUMBER
     , p_ret_res_id    IN OUT NOCOPY NUMBER
     , x_return_status IN OUT NOCOPY VARCHAR2
     );



/****************************************************************************
*  CHECK REQUIRED

-- Check_Required used by RTG BO
PROCEDURE Check_Required
( p_sub_resource_rec     IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Required used by ECO BO
PROCEDURE Check_Required
( p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
, x_return_status         IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


-- Check_Required internally called by RTG BO and by ECO BO
PROCEDURE Check_Required
(  p_com_sub_resource_rec      IN  Bom_Rtg_Pub.Com_op_resource_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

*****************************************************************************/


/****************************************************************************
*  CHECK CONDITIONALLY REQUIRED

-- Check_Conditionally_Required used by RTG BO
PROCEDURE Check_Conditionally_Required
( p_sub_resource_rec       IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
, p_sub_res_unexp_rec        IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required used by ECO BO
PROCEDURE Check_Conditionally_Required
( p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
, p_rev_sub_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required  internally called by RTG BO and ECO BO
PROCEDURE Check_Conditionally_Required
(  p_com_sub_resource_rec        IN  Bom_Rtg_Pub.Com_op_resource_Rec_Type
 , p_com_sub_res_unexp_rec         IN  Bom_Rtg_Pub.Com_Sub_Res_Unexposed_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

*****************************************************************************/


/*



--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
( x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_component_rec       IN  Bom_Rtg_Pub.Bom_Comps_Rec_Type
, p_bom_Comp_Unexp_Rec      IN  Bom_Rtg_Pub.Bom_Comps_Unexposed_Rec_Type
);



*/

/*
** Procedures used by ECO BO and internally called by RTG BO



PROCEDURE Check_Entity_Delete
( x_return_status               IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Rtg_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Rtg_Pub.Rev_Comp_Unexposed_Rec_Type
);




PROCEDURE Check_Access
(  p_revised_item_name          IN  VARCHAR2
 , p_revised_item_id            IN  NUMBER
 , p_organization_id            IN  NUMBER
 , p_change_notice              IN  VARCHAR2
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_component_item_id          IN  NUMBER
 , p_op_resource_seq_num          IN  NUMBER
 , p_bill_sequence_id           IN  NUMBER
 , p_component_name             IN  VARCHAR2
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , p_entity_processed           IN  VARCHAR2 := 'RC'
 , p_rfd_sbc_name               IN  VARCHAR2 := NULL
 , x_mesg_token_tbl             OUT Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT VARCHAR2
);


*/

------------------------------------------------------------------------------



END BOM_Validate_Sub_Op_Res ;

 

/
