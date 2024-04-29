--------------------------------------------------------
--  DDL for Package CN_COLUMN_IND_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLUMN_IND_MAPS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrecims.pls 115.1 99/07/16 07:13:33 porting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_column_ind_maps table.
-- History
--   2/11/94		Devesh Khatu		Created
--
PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_column_ind_map_id	cn_column_ind_maps.column_ind_map_id%TYPE,
	X_index_id		cn_column_ind_maps.index_id%TYPE,
	X_column_id		cn_column_ind_maps.column_id%TYPE,
	X_column_position	cn_column_ind_maps.column_position%TYPE,
	X_order_flag		cn_column_ind_maps.order_flag%TYPE);

--
-- Procedure Name
--   select_row
-- Purpose
--   Selects a record from the cn_column_ind_maps table.
-- History
--   2/11/94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_column_ind_maps%ROWTYPE);


END cn_column_ind_maps_pkg;

 

/
