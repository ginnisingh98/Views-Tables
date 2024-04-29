--------------------------------------------------------
--  DDL for Package BOMPBXIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPBXIN" AUTHID CURRENT_USER as
/* $Header: BOMBXINS.pls 120.1 2005/06/21 03:36:07 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMBXINS.pls                                               |
| Description  : This is the bom exploder.				    |
| Parameters:   org_id          organization_id				    |
|               order_by        1 - Op seq, item seq			    |
|                               2 - Item seq, op seq			    |
|               grp_id          unique value to identify current explosion  |
|                               use value from seq bom_small_expl_temp_s    |
|               levels_to_explode					    |
|               bom_or_eng      1 - BOM					    |
|                               2 - ENG					    |
|               impl_flag       1 - implemented only			    |
|                               2 - both impl and unimpl		    |
|               explode_option  1 - All					    |
|                               2 - Current				    |
|                               3 - Current and future			    |
|		incl_oc_flag	1 - include OC and M under standard item    |
|				2 - do not include			    |
|               show_rev        1 - obtain current revision of component    |
|				2 - don't obtain current revision	    |
|		material_ctrl   1 - obtain subinventory locator		    |
|				2 - don't obtain subinventory locator	    |
|		lead_time	1 - calculate offset percent		    |
|				2 - don't calculate offset percent	    |
|               max_level       max bom levels permissible for org	    |
|               rev_date        explosion date                              |
|               err_msg         error message out buffer		    |
|               error_code      error code out.  returns sql error code	    |
|                               if sql error, 9999 if loop detected.	    |
| Revision								    |
|		Shreyas Shah	Creation				    |
| 02/10/94	Shreyas Shah	added common_bill_Seq_id to cursor	    |
|				added multi-org explosion		    |
|  08/03/95	Rob Yee		added parameters for 10SC		    |
|                                                                           |
+==========================================================================*/

-- G_SortWidth constant number := 7; -- no more than 9999999 components per level
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
	max_level		IN NUMBER,
	unit_number_from	IN VARCHAR2,
	unit_number_to		IN VARCHAR2,
	rev_date		IN DATE DEFAULT sysdate,
        show_rev        	IN NUMBER DEFAULT 2,
 	material_ctrl   	IN NUMBER DEFAULT 2,
 	lead_time		IN NUMBER DEFAULT 2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER
);

END BOMPBXIN;

 

/
