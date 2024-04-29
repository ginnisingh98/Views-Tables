--------------------------------------------------------
--  DDL for Package AHL_UMP_PROCESSUNIT_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_PROCESSUNIT_EXTN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUMES.pls 115.0 2002/07/14 19:34:39 sracha noship $ */

------------------------
-- Declare Procedures --
------------------------

-- To flush the unit effectivities from the temporary table to ahl_unit_effectivities/ahl_ue_relationships.
PROCEDURE Flush_From_Temp_Table(p_config_node_tbl  IN  AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type);

END AHL_UMP_ProcessUnit_EXTN_PVT;

 

/
