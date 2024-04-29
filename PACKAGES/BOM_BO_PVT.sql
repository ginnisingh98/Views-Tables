--------------------------------------------------------
--  DDL for Package BOM_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BO_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMVBOMS.pls 115.4 2002/11/13 20:58:25 rfarook ship $ */
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMVBOMB.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Bo_Pvt
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-1999 Rahul Chitko    Initial Creation
--
--  21-AUG-01   Refai Farook    One To Many support changes
--
--  Global constant holding the package name

PROCEDURE Process_Bom
(   p_api_version_number       IN  NUMBER
,   p_validation_level         IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status            IN OUT NOCOPY VARCHAR2
,   x_msg_count                IN OUT NOCOPY NUMBER
,   p_bom_header_rec           IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
,   p_bom_revision_tbl         IN  Bom_Bo_PUB.Bom_Revision_Tbl_Type :=
                                        Bom_Bo_PUB.G_MISS_BOM_REVISION_TBL
,   p_bom_component_tbl        IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
,   p_bom_ref_designator_tbl    IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
                               :=  Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
,   p_bom_sub_component_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
                                    :=  Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
,   p_bom_comp_ops_tbl          IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
                                    :=  Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
,   x_bom_header_rec            IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
,   x_bom_revision_tbl          IN OUT NOCOPY Bom_Bo_PUB.Bom_Revision_Tbl_Type
,   x_bom_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   x_bom_ref_designator_tbl    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   x_bom_sub_component_tbl     IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_comp_ops_tbl          IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
);


END BOM_Bo_PVT;

 

/
