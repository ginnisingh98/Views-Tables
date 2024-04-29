--------------------------------------------------------
--  DDL for Package ENG_FORM_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_FORM_ECO_PVT" AUTHID CURRENT_USER AS
/* $Header: ENGFPVTS.pls 115.9 2003/07/08 13:19:40 akumar ship $ */

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
--  Notes show errors package body ENG_Eco_PUB;

--   show errors package body ENG_Eco_PUB;

--  End of Comments

PROCEDURE Process_Eco
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_msg_count                     IN OUT NOCOPY NUMBER
,   p_control_rec                   IN  BOM_BO_PUB.Control_Rec_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_unexp_eco_rec                 IN  ENG_Eco_PUB.ECO_Unexposed_Rec_Type := NULL
,   p_unexp_rev_item_rec            IN  ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type := NULL
,   p_unexp_rev_comp_rec            IN  BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type := NULL
,   p_unexp_eco_rev_rec             IN  ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type := NULL
,   p_unexp_sub_comp_rec            IN  BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type := NULL
,   p_unexp_ref_desg_rec            IN  BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type := NULL
,   p_unexp_rev_op_rec              IN  BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type := NULL         -- add
,   p_unexp_rev_op_res_rec          IN  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type := NULL     -- add
,   p_unexp_rev_sub_res_rec         IN  BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type := NULL    -- add
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
,   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_Operation_Tbl_Type:=
                                        BOM_RTG_PUB.G_MISS_REV_OPERATION_TBL       --add
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type :=
                                        BOM_RTG_PUB.G_MISS_REV_OP_RESOURCE_TBL     --add
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type:=
                                        BOM_RTG_PUB.G_MISS_REV_SUB_RESOURCE_TBL    --add
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type            --ECO 10dec
,   x_unexp_ECO_rec                 IN OUT NOCOPY ENG_Eco_PUB.ECO_Unexposed_Rec_Type  --ECO 10dec
,   x_unexp_eco_rev_rec             IN OUT NOCOPY ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type
,   x_unexp_revised_item_rec        IN OUT NOCOPY ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   x_unexp_rev_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_unexp_sub_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
,   x_unexp_ref_desg_rec            IN OUT NOCOPY BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
,   x_unexp_rev_op_rec              IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type      --add
,   x_unexp_rev_op_res_rec          IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type  --add
,   x_unexp_rev_sub_res_rec         IN OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type --add
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_Operation_Tbl_Type         --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type       --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type      --add
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
);

/*
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
--  Notes
--
--  End of Comments

PROCEDURE Lock_Eco
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_msg_count                     IN OUT NOCOPY NUMBER
,   x_msg_data                      IN OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  ENG_Eco_PUB.Rev_Component_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  ENG_Eco_PUB.Ref_Designator_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  ENG_Eco_PUB.Sub_Component_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_SUB_COMPONENT_TBL
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY ENG_Eco_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY ENG_Eco_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY ENG_Eco_PUB.Sub_Component_Tbl_Type
,   x_err_text                      IN OUT NOCOPY VARCHAR2
);

*/


END ENG_Form_Eco_PVT;

 

/
