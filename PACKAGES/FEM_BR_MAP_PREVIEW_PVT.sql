--------------------------------------------------------
--  DDL for Package FEM_BR_MAP_PREVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_MAP_PREVIEW_PVT" AUTHID CURRENT_USER AS
/* $Header: fem_br_map_preview_pvt.pls 120.1 2008/02/20 06:56:26 jcliving ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);


END FEM_BR_MAP_PREVIEW_PVT;

/
