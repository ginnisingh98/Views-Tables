--------------------------------------------------------
--  DDL for Package FEM_BR_CONDITION_DIMENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_CONDITION_DIMENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVCONDDIMS.pls 120.2.12010000.1 2008/12/11 00:56:28 huli ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);


END FEM_BR_CONDITION_DIMENSION_PVT;

/
