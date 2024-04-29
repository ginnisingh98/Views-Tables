--------------------------------------------------------
--  DDL for Package QP_ITEM_RANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ITEM_RANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXITRGS.pls 120.1 2005/06/14 05:22:02 appldev  $ */

l_tbl_type  DBMS_SQL.VARCHAR2_TABLE;
l_tbl  l_tbl_type%TYPE;

PROCEDURE ITEMS_IN_RANGE
(
 p_segment1_lohi        IN	VARCHAR2,
 p_segment2_lohi        IN	VARCHAR2,
 p_segment3_lohi        IN	VARCHAR2,
 p_segment4_lohi        IN	VARCHAR2,
 p_segment5_lohi        IN	VARCHAR2,
 p_segment6_lohi        IN	VARCHAR2,
 p_segment7_lohi        IN	VARCHAR2,
 p_segment8_lohi        IN	VARCHAR2,
 p_segment9_lohi        IN	VARCHAR2,
 p_segment10_lohi       IN	VARCHAR2,
 p_segment11_lohi       IN	VARCHAR2,
 p_segment12_lohi       IN	VARCHAR2,
 p_segment13_lohi       IN	VARCHAR2,
 p_segment14_lohi       IN	VARCHAR2,
 p_segment15_lohi       IN	VARCHAR2,
 p_segment16_lohi       IN	VARCHAR2,
 p_segment17_lohi       IN	VARCHAR2,
 p_segment18_lohi       IN	VARCHAR2,
 p_segment19_lohi       IN	VARCHAR2,
 p_segment20_lohi       IN	VARCHAR2,
 p_org_id	              IN	NUMBER,
 p_category_set_id      IN    NUMBER,
 p_category_id		    IN	NUMBER,
 p_status_code 	    IN	VARCHAR2,
 p_item_tbl             OUT NOCOPY /* file.sql.39 change */   l_tbl%TYPE
);

END QP_ITEM_RANGE_PVT;

 

/
