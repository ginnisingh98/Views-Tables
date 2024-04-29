--------------------------------------------------------
--  DDL for Package BOM_RTG_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_EXP" AUTHID CURRENT_USER AS
/* $Header: BOMREXPS.pls 115.1 2002/11/19 12:48:55 djebar noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMREXPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_EXP
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-02  M V M P Tilak	Initial Creation
--
***************************************************************************/
PROCEDURE Export_Rtg
   ( p_init_msg_list                IN  BOOLEAN := FALSE,
     p_organization_code            IN  VARCHAR2,
     p_assembly_item_name           IN  VARCHAR2,
     p_alternate_routing_designator IN  VARCHAR2,
     p_debug                        IN  VARCHAR2 := 'N',
     p_output_dir                   IN  VARCHAR2 := NULL,
     p_debug_filename               IN  VARCHAR2 := 'RTG_EXP_debug.log',
     x_rtg_header_rec               OUT NOCOPY BOM_RTG_PUB.Rtg_Header_Rec_Type,
     x_rtg_revision_tbl             OUT NOCOPY BOM_RTG_PUB.Rtg_Revision_Tbl_Type,
     x_operation_tbl                OUT NOCOPY BOM_RTG_PUB.Operation_Tbl_Type,
     x_op_resource_tbl              OUT NOCOPY BOM_RTG_PUB.Op_Resource_Tbl_Type,
     x_sub_resource_tbl             OUT NOCOPY BOM_RTG_PUB.Sub_Resource_Tbl_Type,
     x_op_network_tbl               OUT NOCOPY BOM_RTG_PUB.Op_Network_Tbl_Type,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER
   );
END BOM_RTG_EXP;

 

/
