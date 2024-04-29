--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_CONFIG_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_CONFIG_NUMBER" AUTHID CURRENT_USER AS
/* $Header: CTOCUCNS.pls 115.0 2003/02/01 02:27:37 ksarkar noship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOCUCNS.pls                                                  |
| DESCRIPTION :                                                               |
|               Package specification for package which enables customers     |
|               to assign customized names to lower level configuration items |
|               created either during pre-configuration process or autocreate |
|		Configuration item process.				      |
|                                                                             |
|               This function is called only when the BOM parameter           |
|               'Item Numbering Method' is set to 'User defined'  and item    |
|		is either pre-configured  or autocreated.	              |
|									      |
|               'user_item_number' function skelton is provided in package    |
|               body which needs to be coded by customer. It accepts          |
|               line id of the model line in so_lines_All or item id of the   |
|		model as input parameter and returns configuration Item name  |
|		as output. Param1 to param5 are dummy parameters which can be |
|		used in future , if need arises.       			      |
|                                                                             |
|               It must be ensured that the length of the returned value      |
|               is not more than the length of config_item_segment.           |
|                                                                             |
|               You should  also make sure that the item number being         |
|               generated is unique ( ATO code will fail if the item number   |
|               already exists in MTL_SYSTEM_ITEMS table.)                    |
|                                                                             |
| HISTORY     : 01/20/03  Kundan Sarkar    Initial Creation                   |
|                                                                             |
*============================================================================*/

g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_CUSTOM_CONFIG_NUMBER';

function user_item_number (
	model_item_id 	IN  	NUMBER,
	model_line_id 	IN  	NUMBER,
	param1		IN	VARCHAR2	DEFAULT NULL,
	param2		IN	VARCHAR2	DEFAULT NULL,
	param3		IN	VARCHAR2	DEFAULT NULL,
	param4		IN	VARCHAR2	DEFAULT NULL,
	param5		IN	VARCHAR2	DEFAULT NULL
        )
return varchar2;

end CTO_CUSTOM_CONFIG_NUMBER;


 

/
