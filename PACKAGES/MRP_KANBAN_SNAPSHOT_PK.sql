--------------------------------------------------------
--  DDL for Package MRP_KANBAN_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_KANBAN_SNAPSHOT_PK" AUTHID CURRENT_USER AS
/* $Header: MRPKSNPS.pls 115.11 2003/05/02 20:16:36 liyma ship $  */

VERSION			CONSTANT CHAR(80) := '1.0';
KANBAN_RELEASE		CONSTANT NUMBER := 6;

-- ========================================================================
--
--  This function will identify the list of items that need to be included
--  in the current kanban plan run.  User can limit thelist of items by
--  specifying an item range or item categroy.  It will select the bill
--  structure of these items and insert them into the table mrp_kanban_ll_code.
--
-- ========================================================================
FUNCTION SNAPSHOT_ITEM_LOCATIONS RETURN BOOLEAN;

-- ========================================================================
--  This procedure builds the where clause for the category range specified
--  The where clause is used in the first select statement while
--  snapshotting kanban items
-- ========================================================================
FUNCTION ITEM_WHERE_CLAUSE (  p_item_lo 	IN 	VARCHAR2,
                              p_item_hi 	IN 	VARCHAR2,
                              p_table_name 	IN 	VARCHAR2,
                              p_where  		OUT 	NOCOPY	VARCHAR2 )
RETURN BOOLEAN;

-- ========================================================================
--  This procedure builds the where clause for the category range specified
--  The where clause is used in the first select statement while
--  snapshotting kanban items
-- ========================================================================

FUNCTION CATEGORY_WHERE_CLAUSE (  p_cat_lo 	IN 	VARCHAR2,
                             	  p_cat_hi 	IN 	VARCHAR2,
                             	  p_table_name 	IN 	VARCHAR2,
                             	  p_where   	OUT 	NOCOPY	VARCHAR2 )
RETURN BOOLEAN;


FUNCTION Check_Min_Priority
( p_assembly_item_id            IN NUMBER,
  p_organization_id             IN NUMBER,
  p_line_id                     IN NUMBER,
  p_alternate_designator        IN VARCHAR2)
RETURN NUMBER;

-- ========================================================================
--  This procedure builds the where clause to filter the rows for which
--  the component is a Model or an Option class and the assembly is
--  a Configured Item
-- ========================================================================

FUNCTION Check_assy_cfgitem
  (p_assembly_item_id           IN NUMBER,
   p_comp_item_id               IN NUMBER,
   p_organization_id            IN NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (Check_Min_Priority,WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (Check_assy_cfgitem,WNDS,WNPS);

END mrp_kanban_snapshot_pk;


 

/
