--------------------------------------------------------
--  DDL for Package FTP_BR_RATE_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_BR_RATE_INDEX_PVT" AUTHID CURRENT_USER AS
/* $Header: ftpbrris.pls 120.0 2005/06/06 19:23:02 appldev noship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

--
-- PROCEDURE
--  DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Rate Index Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);

--
-- PROCEDURE
--  CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Rate Index  Rule Definition (target)
--   by copying the detail records of another Rate Index Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

END FTP_BR_RATE_INDEX_PVT;

 

/
