--------------------------------------------------------
--  DDL for Package BOMPIMPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPIMPL" AUTHID CURRENT_USER as
/* $Header: BOMIMPLS.pls 120.1 2005/06/21 01:52:47 appldev ship $ */
/*#
* This API contains methods to implode BOM .It contains two different imploders,
* for single level and multi level implosion The procedure imploders calls the
* correct imploder based on the number of levels to implode.
* @rep:scope public
* @rep:product BOM
* @rep:displayname Item Where Used
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPIMPL.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the imploders.
|                This package contains 2 different imploders for the
|                single level and multi level implosion. The package
|                imploders calls the correct imploder based on the
|		 # of levels to implode.
| Parameters:   org_id          organization_id
|               sequence_id     unique value to identify current implosion
|                               use value from sequence bom_implosion_temp_s
|               levels_to_implode
|               eng_mfg_flag    1 - BOM
|                               2 - ENG
|               impl_flag       1 - implemented only
|                               2 - both impl and unimpl
|               display_option  1 - All
|                               2 - Current
|                               3 - Current and future
|               item_id         item id of asembly to explode
|               impl_date       explosion date dd-mon-yy hh24:mi
|               err_msg         error message out buffer
|               error_code      error code out.  returns sql error code
|                               if sql error, 9999 if loop detected.
+==========================================================================*/

/*#
* Implode BOM Method. This is used for item whereused search.
* @param sequence_id  unique value to identify current implosion use value from sequence
* bom_implosion_temp_s
* @param eng_mfg_flag 1 - BOM , 2 - ENG
* @param org_id organization_id
* @param impl_flag 1 - implemented only, 2 - both impl and unimpl
* @param display_option 1 - All,  2 - Current,3 - Current and future
* @param levels_to_implode number of levels to be imploded
* @param item_id item id of assembly to implode
* @param impl_date implosion date dd-mon-yy hh24:mi
* @param err_msg error message out buffer
* @param err_code  error code out.  returns sql error code if sql error, 9999 if loop detected
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Implode userexit
*/
PROCEDURE imploder_userexit(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	item_id			IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE implosion (
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE sl_imploder (
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE ml_imploder(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	a_levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER);

END bompimpl;

 

/
