--------------------------------------------------------
--  DDL for Package BOMPIINQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPIINQ" AUTHID CURRENT_USER as
/* $Header: BOMIINQS.pls 120.1 2005/06/21 05:08:14 appldev ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMIINQS.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the imploders.
|                This package contains 2 different imploders for the
|                single level and multi level implosion. The package
|                imploders calls the correct imploder based on the
|		 # of levels to implode.
| Parameters:   org_id          organization_id
|               sequence_id     unique value to identify current implosion
|                               use value from sequence bom_small_impl_temp_s
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
|               organization_option
|                               1 - Current Organization
|                               2 - Organization Hierarchy
|                               3 - All Organizations to which access is allowed
|               organization_hierarchy
|                               Organization Hierarchy Name
+==========================================================================*/

PROCEDURE imploder_userexit(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	item_id			IN  NUMBER,
	impl_date		IN  VARCHAR2,
	unit_number_from    	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        organization_option     IN  NUMBER default 1,
        organization_hierarchy  IN VARCHAR2 default NULL,
        serial_number_from      IN VARCHAR2 default NULL,
        serial_number_to        IN VARCHAR2 default NULL);

PROCEDURE implosion (
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	unit_number_from    	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        serial_number_from      IN VARCHAR2 default NULL,
        serial_number_to        IN VARCHAR2 default NULL);

PROCEDURE sl_imploder (
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	impl_date		IN  VARCHAR2,
	unit_number_from    	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        serial_number_from      IN VARCHAR2 default NULL,
        serial_number_to        IN VARCHAR2 default NULL);

PROCEDURE ml_imploder(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	a_levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	unit_number_from    	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        serial_number_from      IN VARCHAR2 default NULL,
        serial_number_to        IN VARCHAR2 default NULL);
--TYPE t_OrgIDtable IS TABLE OF hr_organization_units.organization_id%TYPE
--    INDEX BY BINARY_INTEGER;

END bompiinq;

 

/
