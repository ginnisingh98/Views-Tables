--------------------------------------------------------
--  DDL for Package BOMPBEXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPBEXP" AUTHID CURRENT_USER as
/* $Header: BOMBEXPS.pls 120.1 2005/06/21 02:46:49 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMBEXPS.pls                                               |
| Description  : This is the bom exploder.                                  |
| Parameters:   org_id          organization_id                             |
|               order_by        1 - Op seq, item seq                        |
|                               2 - Item seq, op seq                        |
|               grp_id          unique value to identify current explosion  |
|                               use value from sequence bom_explosion_temp_s|
|               levels_to_explode                                           |
|               bom_or_eng      1 - BOM                                     |
|                               2 - ENG                                     |
|               impl_flag       1 - implemented only                        |
|                               2 - both impl and unimpl                    |
|               explode_option  1 - All                                     |
|                               2 - Current                                 |
|                               3 - Current and future                      |
|		incl_oc_flag	1 - include OC and M under standard item    |
|				2 - do not include                          |
|		incl_lt_flag	1 - include operation lead time %           |
|				2 - don't include operation lead time %     |
|               max_level       max bom levels permissible for org          |
|               rev_date        explosion date dd-mon-yy hh24:mi            |
|               err_msg         error message out buffer                    |
|               error_code      error code out.  returns sql error code     |
|                               if sql error, 9999 if loop detected.        |
| Revision                                                                  |
|		Shreyas Shah	Creation                                    |
| 02/10/94	Shreyas Shah	added common_bill_Seq_id to cursor          |
|				added multi-org explosion                   |
| 10/19/95      Robert Yee      select operation lead time percent from     |
|                               routing                                     |
| 09/05/96      Robert Yee      Increase Sort Order Width to 4 from 3       |
|				(Bills can have >= 1000 components          |
+==========================================================================*/

-- G_SortWidth constant number := 7; -- 1 to 999,9999 components per level
G_SortWidth constant number := Bom_Common_Definitions.G_Bom_SortCode_Width;

PROCEDURE bom_exploder(
	verify_flag		IN NUMBER DEFAULT 0,
	online_flag		IN NUMBER DEFAULT 1,
	org_id 			IN NUMBER,
	order_by 		IN NUMBER DEFAULT 1,
	grp_id			IN NUMBER,
	levels_to_explode 	IN NUMBER DEFAULT 1,
	bom_or_eng		IN NUMBER DEFAULT 1,
	impl_flag		IN NUMBER DEFAULT 1,
        plan_factor_flag	IN NUMBER DEFAULT 2,
	explode_option 		IN NUMBER DEFAULT 2,
	std_comp_flag		IN NUMBER DEFAULT 2,
	incl_oc_flag		IN NUMBER DEFAULT 1,
	incl_lt_flag		IN NUMBER DEFAULT 2,
	max_level		IN NUMBER,
	module			IN NUMBER DEFAULT 2,
	rev_date		IN VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER
);

END BOMPBEXP;

 

/
