--------------------------------------------------------
--  DDL for Package Body BIM_TARGET_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_TARGET_SEGMENT_PKG" AS
/* $Header: bimtrgtb.pls 115.3 2000/02/02 10:08:23 pkm ship  $ */

FUNCTION target_segment_fk(p_customer_id number,
                           p_source_code varchar2) RETURN NUMBER AS

/* Since customer_id,p_source_code combinations could occur
   more than once in AMS_LIST_ENTRIES, we just want the
   latest
*/

CURSOR LC_CELL IS
	SELECT CELL_ID
	FROM
		AMS_CELLS_ALL_B CELL,
		AMS_LIST_ENTRIES LIST
	WHERE
		LIST.CUSTOMER_ID = P_CUSTOMER_ID AND
		LIST.SOURCE_CODE = P_SOURCE_CODE AND
		CELL.CELL_CODE = LIST.CELL_CODE AND
		MARKED_AS_DUPLICATE_FLAG = 'N'
	ORDER BY LIST_ENTRY_ID DESC;

ln_cell_id PLS_INTEGER :=  -999;

BEGIN

OPEN LC_CELL;
FETCH LC_CELL INTO ln_cell_id;
RETURN ln_cell_id;

END;

END BIM_TARGET_SEGMENT_PKG;

/
