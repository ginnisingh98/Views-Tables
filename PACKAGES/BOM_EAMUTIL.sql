--------------------------------------------------------
--  DDL for Package BOM_EAMUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_EAMUTIL" AUTHID CURRENT_USER as
/* $Header: BOMPEAMS.pls 115.5 2003/09/15 14:16:41 djebar ship $ */
/*==========================================================================+
|   Copyright (c) 2001 Oracle Corporation, California, USA          	    |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPEAMS.pls						    |
| Description  : EAM utility programs package				    |
| Created By   : Refaitheen Farook					    |
| Creation Date: 11-Apr-01                                                  |
|									    |
|	item_id			Assembly_Item_Id			    |
|	org_id			Organization_id				    |
|                                                                           |
+==========================================================================*/

FUNCTION Enabled RETURN VARCHAR2;
FUNCTION Serial_Effective_Item(item_id NUMBER,
                               org_id NUMBER) RETURN VARCHAR2;

FUNCTION OrgIsEamEnabled(p_org_id NUMBER) RETURN VARCHAR2 ;
FUNCTION Asset_Activity_Item(item_id NUMBER,
                             org_id  NUMBER) RETURN VARCHAR2;
FUNCTION Asset_Group_Item(item_id NUMBER,
                          org_id  NUMBER) RETURN VARCHAR2;
FUNCTION Direct_Item(item_id NUMBER,
                     org_id  NUMBER) RETURN VARCHAR2;

END BOM_EAMUTIL;

 

/
