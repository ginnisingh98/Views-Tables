--------------------------------------------------------
--  DDL for Package Body CTO_CUSTOM_MATCH_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CUSTOM_MATCH_PK" as
/* $Header: CTOCUSMB.pls 120.1 2005/06/02 13:53:56 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : CTOCUSMB.pls						      |
|                                                                             |
| DESCRIPTION : This pcakage is a customization hook to facilitate            |
|               development of customized configuration Match logic.          |
|                                                                             |
|               It is CTO equivalent of the old BOMCEDCB.pls. This function   |
|               is used in CTOCCFGB.pls instead of  CTO_MATCH_CONFIG.check    |
|               _config_match whern the BOM:Check Duplicate Configuration     |
|               is set to '2' (Match).                                        |
|                                                                             |
|                                                                             |
| HISTORY :     10/12/99      Usha Arora                                      |
|               06/01/05      Renga Kannan  Added NOCOPY Hint		      |
|                                                                             |
*============================================================================*/

/*---------------------------------------------------------------------------+
   This function tries to find a match for an existing config item
   using the customized logic. The function accepts Model's line_id
   in oe_order_lines_all table and returns the inventory_item_id
   of the matched config item. If  match is not found, XmatchedITemId
   should return null. Function returns 1 if it was successfully executed
   and returns a 0 (Zero), if it encountered errors.
+----------------------------------------------------------------------------*/

function find_matching_config(
        pModelLineId    in		number,      -- Model Line Id in oe_order_lines_all
        xMatchedItemId  out NOCOPY	number,      -- Item ID of Matched Config
        xErrorMessage   out NOCOPY	VARCHAR2,
        xMessageName    out NOCOPY      VARCHAR2,
        xTableName      out NOCOPY      VARCHAR2   )
return integer                             -- 1 = OK, 0 = Error
is
begin
	/*----------------------------------------------------------------+
	   This function can be replaced by custom code that will search
           for an existing configuration that meets the requirements
	   specified by the demand for a new configuration.
        +-----------------------------------------------------------------*/

	xMatchedItemId := NULL;
	return (1);
end;

end CTO_CUSTOM_MATCH_PK;

/
