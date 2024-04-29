--------------------------------------------------------
--  DDL for Package FTP_BR_ROM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_BR_ROM_PVT" AUTHID CURRENT_USER AS
/* $Header: ftproms.pls 120.0.12000000.1 2007/07/27 12:08:22 shishank noship $ */


---------------------------------------------------------------------
-- Deletes all the details records of a Prepayment Rule Definition.
---------------------------------------------------------------------

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);

----------------------------------------------------------------------------
-- Creates all the detail records of a new Prepayment Rule Definition (target)
-- by copying the detail records of another Prepayment Rule Definition (source).

-- IN Parameters
-- p_source_obj_def_id    - Source Object Definition ID.
-- p_target_obj_def_id    - Target Object Definition ID.
-- p_created_by           - FND User ID (optional).
-- p_creation_date        - System Date (optional).
----------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

END FTP_BR_ROM_PVT;


 

/
