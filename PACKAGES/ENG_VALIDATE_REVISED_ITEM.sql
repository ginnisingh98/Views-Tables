--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_REVISED_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_REVISED_ITEM" AUTHID CURRENT_USER AS
/* $Header: ENGLRITS.pls 120.2.12010000.1 2008/07/28 06:24:01 appldev ship $ */

--  Procedure Entity
PROCEDURE Check_Entity
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_old_revised_item_rec       IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_old_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_control_rec                IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

--  Procedure Attributes
PROCEDURE Check_Attributes
(  x_return_status              OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_old_revised_item_rec       IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_old_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
);


--  Procedure Entity_Delete
PROCEDURE Check_Entity_Delete
(  x_return_status              OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
);

PROCEDURE Check_Required
(  x_return_status      OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_Rec   IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 );

PROCEDURE Check_Existence
(  p_revised_item_rec       IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec     IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_old_revised_item_rec   IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
 , x_old_rev_item_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl         OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status          OUT NOCOPY VARCHAR2
 , x_disable_revision       OUT NOCOPY NUMBER --  Bug no:3034642
);

-- Added for bug 5756870
PROCEDURE Check_Access_Scheduled
(  p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type

 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);


PROCEDURE Check_Access
(  p_change_notice              IN  VARCHAR2
 , p_organization_id            IN  NUMBER
 , p_revised_item_id            IN  NUMBER
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_new_routing_revsion        IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_from_end_item_number       IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_revised_item_name          IN  VARCHAR2
 , p_entity_processed           IN  VARCHAR2 := NULL
 , p_operation_seq_num          IN  NUMBER   := NULL
 , p_routing_sequence_id        IN  NUMBER   := NULL
 , p_operation_type             IN  NUMBER   := NULL
 , p_alternate_bom_code         IN  VARCHAR2 := NULL -- Bug 4210718
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                        Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
 , p_check_scheduled_status IN BOOLEAN DEFAULT TRUE  -- Added for bug 5756870
);

-- Fix for bug 3577967
PROCEDURE Get_Where_Clause_For_Subjects
( p_change_notice              IN VARCHAR2
 ,x_item_lifecycle_Phase      IN OUT NOCOPY VARCHAR2
 ,x_item_catalogue_Group      IN OUT NOCOPY VARCHAR2
 ,x_item_type		      IN OUT NOCOPY VARCHAR2
);

-- Fix for bug 3577967
 PROCEDURE validate_rev_items_for_sub
 ( p_change_notice     IN VARCHAR2
  ,p_inventory_item_id IN NUMBER
  ,p_org_id            IN NUMBER
  ,x_ret_Value         OUT NOCOPY BOOLEAN
  );

-- Fix for bug 3311749
FUNCTION Exp_Validate_New_Item_Revision
( p_revised_item_id IN NUMBER
, p_organization_id IN NUMBER
, p_new_item_revision IN VARCHAR2
, p_revised_item_sequence_id IN NUMBER
, x_change_notice OUT NOCOPY VARCHAR2
) RETURN NUMBER ;

-- Bug 4210718
/*****************************************************************************
* Procedure      : Check_Structure_Type_Policy
* Parameters IN  : p_inventory_item_id => Revised item
*                  p_organization_id => Organization Id
*                  p_alternate_bom_code => Alternate_Bom_Designator
* Parameters OUT : x_structure_type_id => Structure Type Id of the bill/alternate
*                  x_strc_cp_not_allowed => 1 if change policy is not allowed
*                                         , 2 otherwise
* Purpose        : To check if the a bill for given revised item with the given
*                  alternate designator has structure policy NOT_ALLOWED
*                  associated with its structure type.
*******************************************************************************/
PROCEDURE Check_Structure_Type_Policy
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
, p_alternate_bom_code  IN VARCHAR2
, x_structure_type_id   OUT NOCOPY NUMBER
, x_strc_cp_not_allowed OUT NOCOPY NUMBER
) ;

PROCEDURE Validate_Revised_Item (
    p_api_version               IN NUMBER := 1.0                         --
  , p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE           --
  , p_commit                    IN VARCHAR2 := FND_API.G_FALSE           --
  , p_validation_level          IN NUMBER  := FND_API.G_VALID_LEVEL_FULL --
  , p_debug                     IN VARCHAR2 := 'N'                       --
  , p_output_dir                IN VARCHAR2 := NULL                      --
  , p_debug_filename            IN VARCHAR2 := 'VALREVITEMS.log'       --
  , x_return_status             OUT NOCOPY VARCHAR2                      --
  , x_msg_count                 OUT NOCOPY NUMBER                        --
  , x_msg_data                  OUT NOCOPY VARCHAR2                      --
  -- Initialization
  , p_bo_identifier             IN VARCHAR2 := 'ECO'
  , p_transaction_type          IN VARCHAR2
  -- Change context
  , p_organization_id           IN NUMBER
  , p_change_id                 IN NUMBER
  , p_change_notice             IN VARCHAR2
  , p_assembly_type             IN NUMBER
  -- revised item
  , p_revised_item_sequence_id  IN NUMBER
  , p_revised_item_id           IN NUMBER
  , p_status_type               IN NUMBER
  , p_status_code               IN NUMBER
  -- new revision
  , p_new_revised_item_revision IN VARCHAR2
  , p_new_revised_item_rev_desc IN VARCHAR2
  , p_from_item_revision_id     IN NUMBER
  , p_new_revision_reason_code  IN VARCHAR2
  , p_new_revision_label        IN VARCHAR2
  , p_updated_revision          IN VARCHAR2
  , p_new_item_revision_id      IN NUMBER
  , p_current_item_revision_id  IN NUMBER
  -- effectivity
  , p_start_effective_date      IN DATE
  , p_new_effective_date        IN DATE
  , p_earliest_effective_date   IN DATE
  -- bill and routing
  , p_alternate_bom_code        IN VARCHAR2
  , p_bill_sequence_id          IN NUMBER
  , p_from_unit_number          IN VARCHAR2
  , p_new_from_unit_number      IN VARCHAR2
  , p_from_end_item_id          IN NUMBER
  , p_from_end_item_revision_id IN NUMBER
  , p_routing_sequence_id       IN NUMBER
  , p_completion_subinventory   IN VARCHAR2
  , p_completion_locator_id     IN NUMBER
  , p_priority                  IN NUMBER
  , p_ctp_flag                  IN NUMBER
  , p_new_routing_revision      IN VARCHAR2
  , p_updated_routing_revision  IN VARCHAR2
  , p_eco_for_production        IN NUMBER
  , p_cfm_routing_flag          IN NUMBER
  -- useup
  , p_use_up_plan_name          IN VARCHAR2
  , p_use_up_item_id            IN NUMBER
  , p_use_up                    IN NUMBER
  -- wip
  , p_disposition_type          IN NUMBER
  , p_update_wip                IN NUMBER
  , p_mrp_active                IN NUMBER
  , p_from_wip_entity_id        IN NUMBER
  , p_to_wip_entity_id          IN NUMBER
  , p_from_cumulative_quantity  IN NUMBER
  , p_lot_number                IN VARCHAR2
);

END ENG_Validate_Revised_Item;

/
