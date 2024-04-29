--------------------------------------------------------
--  DDL for Package ENG_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: ENGSVATS.pls 115.9 2002/11/22 10:13:55 akumar ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )RETURN BOOLEAN;

FUNCTION Approval_Status_Type
        (  p_approval_status_type       IN  NUMBER
         , x_err_text                   OUT NOCOPY VARCHAR2
         ) RETURN BOOLEAN;

FUNCTION Approval_Date
        (  p_approval_date      IN  DATE
         , x_err_text           OUT NOCOPY VARCHAR2
         ) RETURN BOOLEAN;

FUNCTION Approval_List
         (  p_approval_list_id  IN  NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
         )RETURN BOOLEAN;

FUNCTION Change_Order_Type
         (  p_change_order_type_id      IN  NUMBER
          , x_err_text                  OUT NOCOPY VARCHAR2
          ) RETURN BOOLEAN;

FUNCTION Responsible_Org
         (  p_responsible_org_id        IN  NUMBER
          , p_current_org_id            IN  NUMBER
          , x_err_text                  OUT NOCOPY VARCHAR2
          ) RETURN BOOLEAN;

FUNCTION Approval_Request_Date
        (  p_approval_request_date      IN DATE
         , x_err_text                   OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN;

FUNCTION End_Item_Unit_Number
        ( p_from_end_item_unit_number IN  VARCHAR2
        , p_revised_item_id           IN  NUMBER
        , x_err_text                  OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN;

FUNCTION Status_Type
         (  p_status_type       IN NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
         ) RETURN BOOLEAN;
FUNCTION Initiation_Date
         (  p_initiation_date   IN  DATE
          , x_err_text          OUT NOCOPY VARCHAR2
         )RETURN BOOLEAN;

FUNCTION Implementation_Date
         (  p_implementation_date       IN  DATE
          , x_err_text                  OUT NOCOPY VARCHAR2
          )RETURN BOOLEAN;

FUNCTION Cancellation_Date
         (  p_cancellation_date IN  DATE
          , x_err_text          OUT NOCOPY VARCHAR2
         )RETURN BOOLEAN;

FUNCTION Priority (  p_priority_code IN VARCHAR2
                   , p_organization_id IN NUMBER
                   , x_disable_date OUT NOCOPY DATE
                   , x_err_text OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN;

FUNCTION Reason (  p_reason_code        IN VARCHAR2
                 , p_organization_id    IN NUMBER
                 , x_disable_date       OUT NOCOPY DATE
                 , x_err_text           OUT NOCOPY VARCHAR2
                 )
RETURN BOOLEAN;

FUNCTION Disposition_Type
         (  p_disposition_type  IN  NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
          )RETURN BOOLEAN;

FUNCTION Mrp_Active
         (  p_mrp_active        IN  NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
          )RETURN BOOLEAN;

FUNCTION Update_Wip
         (  p_update_wip        IN NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
         )RETURN BOOLEAN;

FUNCTION Use_Up
         (  p_use_up    IN NUMBER
          , x_err_text OUT NOCOPY VARCHAR2
          )RETURN BOOLEAN;

FUNCTION Use_Up_Plan_Name
         (  p_use_up_plan_name  IN  VARCHAR2
          , p_organization_id   IN  NUMBER
          , x_err_text          OUT NOCOPY VARCHAR2
          )RETURN BOOLEAN;

FUNCTION Supply_Subinventory
         (  p_supply_subinventory       IN  VARCHAR2
          , p_organization_id           IN  NUMBER
          , x_err_text                  OUT NOCOPY VARCHAR2
         ) RETURN BOOLEAN;

FUNCTION Required_For_Revenue
         (  p_required_for_revenue      IN  NUMBER
          , x_err_text                  OUT NOCOPY VARCHAR2
         )RETURN BOOLEAN;

FUNCTION Wip_Supply_Type(  p_wip_supply_type    IN  NUMBER
                         , x_err_text           OUT NOCOPY VARCHAR2
                         )RETURN BOOLEAN;

FUNCTION Item_Num(  p_item_num  IN   NUMBER
                  , x_err_text  OUT NOCOPY  VARCHAR2
                  )RETURN BOOLEAN;

FUNCTION Component_Yield_Factor
         (  p_component_yield_factor    IN  NUMBER
          , x_err_text                  OUT NOCOPY VARCHAR2
          ) RETURN BOOLEAN;

FUNCTION Effectivity_Date(p_effectivity_date IN DATE ,
                          p_revised_item_sequence_id IN NUMBER,
                          x_err_text         OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;

FUNCTION Disable_Date(  p_disable_date     IN  DATE
                      , p_effectivity_date IN  DATE
                      , x_err_text         OUT NOCOPY VARCHAR2
                      )RETURN BOOLEAN;

FUNCTION Quantity_Related(p_quantity_related IN NUMBER ,
                          x_err_text         OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;

FUNCTION So_Basis(p_so_basis    IN  NUMBER
                  , x_err_text  OUT NOCOPY VARCHAR2)RETURN BOOLEAN;

FUNCTION Optional(p_optional IN NUMBER ,
                  x_err_text OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;

FUNCTION Mutually_Exclusive_Opt(p_mutually_exclusive_opt IN NUMBER ,
                                x_err_text               OUT NOCOPY VARCHAR2
                                )RETURN BOOLEAN;

FUNCTION Include_In_Cost_Rollup(p_include_in_cost_rollup IN NUMBER ,
                                x_err_text               OUT NOCOPY VARCHAR2
                                )RETURN BOOLEAN;

FUNCTION Check_Atp(p_check_atp  IN  NUMBER
                   , x_err_text OUT NOCOPY VARCHAR2
                  )RETURN BOOLEAN;

FUNCTION Shipping_Allowed(p_shipping_allowed IN NUMBER ,
                          x_err_text         OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;

FUNCTION Required_To_Ship(p_required_to_ship IN NUMBER ,
                          x_err_text         OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;

FUNCTION Include_On_Ship_Docs(p_include_on_ship_docs IN NUMBER ,
                              x_err_text             OUT NOCOPY VARCHAR2
                              )RETURN BOOLEAN;
FUNCTION Acd_Type(p_acd_type IN NUMBER ,
                  x_err_text OUT NOCOPY VARCHAR2 )RETURN BOOLEAN;


/****************************************************************************
* Added by MK on 09/01/2000 for ECO New Effectivities
*****************************************************************************/
FUNCTION Check_RevCmp_In_ECO_By_WO
             ( p_revised_item_sequence_id IN  NUMBER
             , p_rev_comp_item_id         IN  NUMBER
             , p_operation_seq_num        IN  NUMBER)

RETURN BOOLEAN ;

--  Procedure Entity_Delete
PROCEDURE Check_Entity_Delete
(  x_return_status              OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
);


END ENG_Validate;

 

/
