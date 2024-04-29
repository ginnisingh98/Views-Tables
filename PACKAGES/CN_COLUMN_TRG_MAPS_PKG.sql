--------------------------------------------------------
--  DDL for Package CN_COLUMN_TRG_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLUMN_TRG_MAPS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrectms.pls 115.1 99/07/16 07:13:45 porting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_column_trg_maps table.
-- History
--   16-FEB-94		Devesh Khatu		Created
--
PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_column_trg_map_id	cn_column_trg_maps.column_trg_map_id%TYPE,
	X_trigger_id		cn_column_trg_maps.trigger_id%TYPE,
	X_column_id		cn_column_trg_maps.column_id%TYPE);

--
-- Procedure Name
--   select_row
-- Purpose
--   Selects a record from the cn_column_trg_maps table.
-- History
--   16-FEB-94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_column_trg_maps%ROWTYPE);


END cn_column_trg_maps_pkg;

 

/
