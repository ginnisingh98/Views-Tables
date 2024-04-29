--------------------------------------------------------
--  DDL for Package CN_IMP_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_MAPS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntimmps.pls 115.2 2002/02/05 00:25:57 pkm ship    $*/

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	Insert_row
--   Purpose
--      Main insert procedure
--   Note
--      1. Primary key should be populated from sequence before call
--         this procedure. No refernece to sequence in this procedure.
--      2. All paramaters are IN parameter.
-- * -------------------------------------------------------------------------*
PROCEDURE insert_row
    ( p_imp_maps_rec IN CN_IMP_MAPS_PVT.IMP_MAPS_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	update_row
--   Purpose
--      Main update procedure
--   Note
--      1. No object version checking, overwrite may happen
--      2. Calling lock_update for object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE update_row
    ( p_imp_maps_rec IN CN_IMP_MAPS_PVT.IMP_MAPS_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	lock_update_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. Object version checking is performed before checking
--      2. Calling update_row if you don not want object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE lock_update_row
    ( p_imp_maps_rec IN CN_IMP_MAPS_PVT.IMP_MAPS_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row
    (
      p_imp_map_id	NUMBER
    );

END CN_IMP_MAPS_PKG;

 

/
