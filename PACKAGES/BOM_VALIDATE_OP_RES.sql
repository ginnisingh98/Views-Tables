--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_OP_RES" AUTHID CURRENT_USER AS
/* $Header: BOMLRESS.pls 120.7.12010000.2 2008/11/14 16:36:45 snandana ship $ */
/*#
* This API contains the methods to validate Operation Resources.
* @rep:scope private
* @rep:product BOM
* @rep:displayname Validate BOM Operation Resources Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
*/
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRESS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Op_Res
--
--  NOTES
--
--  HISTORY
--  18-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/



/****************************************************************************
*  CHECK EXISTENCE
*****************************************************************************/
/*#
* Check_Existence will perform a query using the primary key information and will return
* success if the operation is CREATE and the record EXISTS or will return an error if the operation
* is UPDATE and the record DOES NOT EXIST.In case of UPDATE if the record exists then the procedure
* will return the old record in the old entity parameters with a success status.
* @param p_op_resource_rec Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_res_Unexp_Rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_old_op_resource_rec Old Operation Resource exposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_old_op_res_unexp_rec Old Operation Resource unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence for Routing BO
*/

-- Check_Existence used by RTG BO
PROCEDURE Check_Existence
(  p_op_resource_rec        IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
 , p_op_res_unexp_rec       IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , x_old_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
 , x_old_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status          IN OUT NOCOPY VARCHAR2
) ;

/*#
* Check_Existence will perform a query using the primary key information and will return
* success if the operation is CREATE and the record EXISTS or will return an error if the operation
* is UPDATE and the record DOES NOT EXIST.In case of UPDATE if the record exists then the procedure
* will return the old record in the old entity parameters with a success status.
* @param p_rev_op_resource_rec Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_rev_op_res_Unexp_Rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_old_rev_op_resource_rec Old Operation Resource exposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_old_rev_op_res_unexp_rec Old Operation Resource unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence for ECO BO
*/

-- Check_Existence used by ECO BO and internally called by RTG BO
PROCEDURE Check_Existence
(  p_rev_op_resource_rec        IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , p_rev_op_res_unexp_rec       IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , x_old_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , x_old_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK NON-REFERENCE ENVENT
*****************************************************************************/

-- Check_NonRefEvent used by RTG BO and by ECO BO
PROCEDURE Check_NonRefEvent
(   p_operation_sequence_id      IN  NUMBER
 ,  p_operation_type             IN  NUMBER
 ,  p_entity_processed           IN  VARCHAR2
 ,  x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status              IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK ATTRIBUTES
*****************************************************************************/
/*#
* Check Attributes convert the BOM Record and will validate individual
* attributes .Any errors will be populated in the x_Mesg_Token_Tbl and returned with a x_return_status
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_op_resource_rec Bom Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_res_unexp_rec Bom Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes for Routing BO
*/
-- Check_Attributes used by RTG BO
PROCEDURE Check_Attributes
(  p_op_resource_rec    IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
 , p_op_res_unexp_rec   IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;


-- Check_Attributes used by ECO BO and internally called by RTG BO
/*#
* Check Attributes convert the BOM Record and will validate individual
* attributes .Any errors will be populated in the x_Mesg_Token_Tbl and returned with a x_return_status
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_rev_op_resource_rec Bom Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_rev_op_res_unexp_rec Bom Operation Resource Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes for ECO BO
*/
PROCEDURE Check_Attributes
(  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         IN OUT NOCOPY VARCHAR2
) ;

/****************************************************************************
*  CHECK ENTITY ATTRIBUTES
*****************************************************************************/
/*#
* Check Entity will execute the business validations for the
* operation resource entity .Any errors are loaded in the x_Mesg_Token_Tbl
* and a return status value is set.
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_op_resource_rec Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param p_old_op_resource_rec Old Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_old_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_op_resource_rec Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity for Routing BO
*/
-- Check_Entity used by RTG BO
PROCEDURE Check_Entity
(  p_op_resource_rec      IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
 , p_op_res_unexp_rec     IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , p_old_op_resource_rec  IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
 , p_old_op_res_unexp_rec IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , x_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
 , x_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status        IN OUT NOCOPY VARCHAR2
) ;

-- Check_Entity used by ECO BO and internally called by RTG BO
/*#
* Check Entity will execute the business validations for the
* operation resource entity .Any errors are loaded in the x_Mesg_Token_Tbl
* and a return status value is set.
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_rev_op_resource_rec Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_rev_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param p_control_Rec IN Control Record
* @paraminfo { @rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
* @param p_old_rev_op_resource_rec Old Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_old_rev_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_rev_op_resource_rec Operation Resource Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_rev_op_res_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity for ECO BO
*/

PROCEDURE Check_Entity
(  p_rev_op_resource_rec      IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , p_rev_op_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , p_old_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , p_old_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
 , x_rev_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
 , x_rev_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;



/****************************************************************************
*  OTHERS
*****************************************************************************/
FUNCTION Get_Rev_Op_ACD (p_op_seq_id IN NUMBER)
RETURN NUMBER ;

/*#
* This method will validate the resource id
* @param p_resource_id  the resource id to be validated
* @param p_op_seq_id the operation sequence id
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Resource Id
*/
PROCEDURE   Val_Resource_Id
   (  p_resource_id             IN  NUMBER
   ,  p_op_seq_id               IN  NUMBER
   ,  x_return_status           IN OUT NOCOPY VARCHAR2
   ) ;

/*#
* This method will validate the Activity  id
* @param p_activity_id  the activity id to be validated
* @param p_op_seq_id the operation sequence id
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Activate Id
*/
PROCEDURE   Val_Activity_Id
   (  p_activity_id             IN  NUMBER
   ,  p_op_seq_id               IN  NUMBER
   ,  x_return_status           IN OUT NOCOPY VARCHAR2
   )  ;
/*#
* This method will validate the setup id
* @param p_setup_id  the setup id to be validated
* @param p_resource_id  the resource
* @param p_organization_id the organization id
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate setup Id
*/

PROCEDURE   Val_Setup_Id
    (  p_setup_id              IN  NUMBER
    ,  p_resource_id           IN  NUMBER
    ,  p_organization_id       IN  NUMBER
    ,  x_return_status         IN OUT NOCOPY VARCHAR2
    )  ;

/*#
* This method will validate the usage rate or amount and inverse
* @param p_usage_rate_or_amount  usage rate or amount
* @param p_usage_rate_or_amount_inverse usage rate or amount and inverse
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate the usage rate or amount and inverse
*/
PROCEDURE   Val_Usage_Rate_or_Amount
  (  p_usage_rate_or_amount          IN  NUMBER
  ,  p_usage_rate_or_amount_inverse  IN  NUMBER
  ,  x_return_status                 IN OUT NOCOPY VARCHAR2
  ) ;

/*#
* This method will validate the Scheduled Resource
* @param p_op_seq_id  the operation sequence id
* @param p_res_seq_num the resource sequence number
* @param p_schedule_flag the schedule flag
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Resource Id
*/
PROCEDURE   Val_Scheduled_Resource
( p_op_seq_id     IN  NUMBER
, p_res_seq_num   IN  NUMBER
, p_schedule_flag IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;
PROCEDURE   Val_Scheduled_Resource
( p_op_seq_id     IN  NUMBER
, p_res_seq_num   IN  NUMBER
, p_sch_seq_num   IN  NUMBER
, p_schedule_flag IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;

PROCEDURE   Val_Autocharge_for_OSP_Res
( p_resource_id     IN  NUMBER
, p_organization_id IN  NUMBER
, x_return_status   IN OUT NOCOPY VARCHAR2
) ;

PROCEDURE   Val_PO_Move
( p_op_seq_id     IN  NUMBER
, p_res_seq_num   IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;

PROCEDURE   Val_Dept_Has_Location
( p_op_seq_id     IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;

PROCEDURE  Get_Resource_Uom
( p_resource_id    IN  NUMBER
, x_hour_uom_code  IN OUT NOCOPY VARCHAR2
, x_hour_uom_class IN OUT NOCOPY VARCHAR2
, x_res_uom_code   IN OUT NOCOPY VARCHAR2
, x_res_uom_class  IN OUT NOCOPY VARCHAR2
) ;

/*#
* This method will validate Resource UOM For Schedule
* @param p_hour_uom_class the hour uom class
* @param p_res_uom_class the resource uom class
* @param p_hour_uom_code the hour uom code
* @param p_res_uom_code the resource uom code
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Resource UOM For Schedule
*/
PROCEDURE   Val_Res_UOM_For_Schedule
( p_hour_uom_class  IN  VARCHAR2
, p_res_uom_class   IN  VARCHAR2
, p_hour_uom_code   IN  VARCHAR2
, p_res_uom_code    IN  VARCHAR2
, x_return_status   IN OUT NOCOPY VARCHAR2
) ;

/*#
* This method will validate Negative Usage Rate
* @param p_autocharge_type the autocharge type
* @param p_schedule_flag the schedule flag
* @param p_hour_uom_class the hour uom class
* @param p_res_uom_class the resource uom class
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Negative Usage Rate
*/
PROCEDURE  Val_Negative_Usage_Rate
( p_autocharge_type  IN  NUMBER
, p_schedule_flag    IN  NUMBER
, p_hour_uom_class   IN  VARCHAR2
, p_res_uom_class    IN  VARCHAR2
, x_return_status    IN OUT NOCOPY VARCHAR2
) ;

/*#
* This method will validate Principal Resource Unique
* @param p_op_seq_id the operation sequence id
* @param p_res_seq_num the resource sequence number
* @param p_sub_group_num the substitute group number
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Principal Resource Unique
*/
PROCEDURE   Val_Principal_Res_Unique
( p_op_seq_id     IN  NUMBER
, p_res_seq_num   IN  NUMBER
, p_sub_group_num IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
) ;
/*#
* This method will validate the substitute group number order
* @param p_op_seq_id the operation sequence id
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate substitute group number order
*/
PROCEDURE Val_Sgn_Order
( p_op_seq_id        IN NUMBER
, x_mesg_token_tbl   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status    IN OUT NOCOPY VARCHAR2
);

/* Fix for bug 4506885 - Added parameter p_sub_grp_num. */
/*#
* This method will validate the Schedule Sequence Number
* @param p_op_seq_id the operation sequence id
* @param p_res_seq_num  the resource sequence number
* @param p_sch_seq_num  the schedule sequence number
* @param p_sub_grp_num  the substitute group number
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Schedule Sequence Number
*/
PROCEDURE Val_Schedule_Seq_Num
( p_op_seq_id     IN NUMBER
, p_res_seq_num   IN  NUMBER
, p_sch_seq_num   IN  NUMBER
, p_sub_grp_num	  IN  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
);

  /* bug:4638695 For an operation do not allow same resource to be added more than once with same SSN */
/*#
* This method will validate the Resource SSN
* @param p_op_seq_id the operation sequence id
* @param p_res_seq_num  the resource sequence number
* @param p_sch_seq_num  the schedule sequence number
* @param p_resource_id  the resource id
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Resource SSN
*/
  PROCEDURE Val_Resource_SSN
  (  p_op_seq_id     IN   NUMBER
  ,  p_res_seq_num   IN   NUMBER
  ,  p_sch_seq_num   IN   NUMBER
  ,  p_resource_id   IN   NUMBER
  ,  x_return_status IN OUT NOCOPY VARCHAR2
  );

/* Fix for bug 6074930-Added below procedure val_schedule_flag. */
     PROCEDURE Val_Schedule_Flag
    (  p_op_seq_id     IN NUMBER
     , p_res_seq_num   IN  NUMBER
     , p_sch_seq_num   IN  NUMBER
     , p_sch_flag      IN  NUMBER
     , p_ret_res_id    IN OUT NOCOPY NUMBER
     , x_return_status IN OUT NOCOPY VARCHAR2
     );

/****************************************************************************
*  CHECK REQUIRED

-- Check_Required used by RTG BO
PROCEDURE Check_Required
( p_op_resource_rec     IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Required used by ECO BO
PROCEDURE Check_Required
( p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
, x_return_status         IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


-- Check_Required internally called by RTG BO and by ECO BO
PROCEDURE Check_Required
(  p_com_op_resource_rec      IN  Bom_Rtg_Pub.Com_op_resource_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

*****************************************************************************/


/****************************************************************************
*  CHECK CONDITIONALLY REQUIRED

-- Check_Conditionally_Required used by RTG BO
PROCEDURE Check_Conditionally_Required
( p_op_resource_rec       IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
, p_op_res_unexp_rec        IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required used by ECO BO
PROCEDURE Check_Conditionally_Required
( p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
, p_rev_op_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required  internally called by RTG BO and ECO BO
PROCEDURE Check_Conditionally_Required
(  p_com_op_resource_rec        IN  Bom_Rtg_Pub.Com_op_resource_Rec_Type
 , p_com_op_res_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Res_Unexposed_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

*****************************************************************************/
G_round_off_val number :=NVL(FND_PROFILE.VALUE('BOM:ROUND_OFF_VALUE'),6); /* Bug 7322996 */

END BOM_Validate_Op_Res ;

/
