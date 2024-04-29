--------------------------------------------------------
--  DDL for Package BOM_RTG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMRPVTS.pls 115.3 2002/11/21 06:01:44 djebar ship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRPVTS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Rtg_Pvt
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-2000 Biao Zhang  Initial Creation
--
--  Global constant holding the package name

PROCEDURE Process_RTG
(   p_api_version_number      IN  NUMBER
  , p_validation_level        IN  NUMBER
  , x_return_status           IN OUT NOCOPY VARCHAR2
  , x_msg_count               IN OUT NOCOPY NUMBER
  , p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
  , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
  , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
  , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
  , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
  , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
  , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
  , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
  , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
  , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
  , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
  , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
);


END Bom_Rtg_Pvt ;

 

/
