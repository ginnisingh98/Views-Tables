--------------------------------------------------------
--  DDL for Package ENG_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_PVT" AUTHID CURRENT_USER AS
/* $Header: ENGVECOS.pls 120.1.12010000.3 2013/07/03 07:42:05 evwang ship $ */

-- bug 15831337: Add flag to skip NIR explosion in plsql
  G_Skip_NIR_Expl VARCHAR2(1) := chr(0);
--  Start of Comments
--  API name    Process_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--

--  End of Comments
PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER
,   p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec               IN  ENG_GLOBALS.Control_Rec_Type :=
                                    ENG_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                    ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                    ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_change_line_tbl           IN  ENG_Eco_PUB.Change_Line_Tbl_Type :=   -- Eng Change
                                    ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL
,   p_revised_item_tbl          IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                    ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type := --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_change_line_tbl           IN OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   x_disable_revision             OUT NOCOPY NUMBER  -- Bug no:3034642
,   p_skip_nir_expl             IN VARCHAR2 DEFAULT FND_API.G_FALSE  -- bug 15831337: skip nir explosion flag
);

--  Start of Comments
--  API name    Lock_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes: Not Used. Eng Change Enhancement changes are not implemented
--
--  End of Comments

PROCEDURE Lock_Eco
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_SUB_COMPONENT_TBL
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_err_text                      OUT NOCOPY VARCHAR2
);

PROCEDURE Process_Rev_Item
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   I                               IN  NUMBER
,   p_revised_item_rec              IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl           IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl          IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   x_rev_op_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   x_rev_sub_resource_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_revised_item_unexp_rec        OUT NOCOPY ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
);

PROCEDURE Process_Rev_Comp
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_alternate_bom_code            IN  VARCHAR2 := NULL -- Bug 2429272 Change4(cont..of..ENGSVIDB.pls)
,   p_effectivity_date              IN  DATE := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   I                               IN  NUMBER
,   p_rev_component_rec             IN  BOM_BO_PUB.Rev_Component_Rec_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_comp_unexp_rec            OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_bill_sequence_id           IN NUMBER := NULL
);

  -- Ehn 13727612: change order workflow auto explosion and submission
  PROCEDURE Explode_WF_Routing(p_change_notice IN VARCHAR2,
                    p_org_id        IN NUMBER,
                    x_return_status IN  OUT NOCOPY   VARCHAR2,
                    x_Mesg_Token_Tbl  IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
  );

END ENG_Eco_PVT;

/
