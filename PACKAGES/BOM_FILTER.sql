--------------------------------------------------------
--  DDL for Package BOM_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_FILTER" AUTHID CURRENT_USER AS
/* $Header: BOMXRECS.pls 120.1 2005/09/28 04:48:02 earumuga noship $ */
/*==========================================================================+
|   Copyright (c) 2003 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMXRECS.pls                                               |
| DESCRIPTION  : Procedure explores and marks the parent items in 	    |
|		 BOM_EXPLOSION_TEMP table.
| Parameters   :	p_ParamSortOrder  Sort Order Array	            |
|			p_GroupId	  Explosion Group ID		    |
|			x_ResultSortOrder Resultant Sort Order Array 	    |
|									    |
| Revision								    |
| 2003/10/22	Ajay			creation			    |
| 2004/1/16	Ajay			Modified the method to only update  |
|					the row with flag.		    |
|                                                                           |
+==========================================================================*/

   TYPE PARAM_LIST IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

   --sort_order_t sort_order;
   sort_order_t DBMS_SQL.VARCHAR2_TABLE;

   PROCEDURE applyFilter (p_ParamSortOrder DBMS_SQL.VARCHAR2_TABLE, p_GroupId VARCHAR2);

   PROCEDURE addBindParameter(p_bind_parameter VARCHAR2);

   PROCEDURE clearBindParameter;

   PROCEDURE applyFilter( p_FilterQuery IN VARCHAR2
                        , p_GroupId     IN NUMBER
                        , p_TemplateId  IN NUMBER
                         );

END BOM_FILTER;

 

/
