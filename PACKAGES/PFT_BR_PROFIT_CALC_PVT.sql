--------------------------------------------------------
--  DDL for Package PFT_BR_PROFIT_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PFT_BR_PROFIT_CALC_PVT" AUTHID CURRENT_USER AS
/* $Header: PFTVPCAS.pls 120.1 2005/06/20 08:39:48 appldev noship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Profit Calculation Rule Definition (target)
--   by copying the detail records of another Profit Calculation Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
PROCEDURE CopyObjectDefinition(
   p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id   IN          NUMBER
  ,p_created_by          IN          NUMBER
  ,p_creation_date       IN          DATE
);

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Profit Calculation Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
);


END PFT_BR_PROFIT_CALC_PVT;
 

/
