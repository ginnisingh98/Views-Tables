--------------------------------------------------------
--  DDL for Package BOM_IMPLODER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_IMPLODER_PUB" AUTHID CURRENT_USER as
/* $Header: BOMPIMPS.pls 120.2 2006/02/07 04:31:16 bbpatel noship $ */

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
|    # of levels to implode.
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
|                               3 - All Organizations to which access allowed
|               organization_hierarchy
|                               Organization Hierarchy Name
| HISTORY
| 09-NOV-05   Bhavnesh Patel    Added Revision Filter
| 07-FEB-06   Bhavnesh Patel     Removed sl_imploder_cad procedure
+==========================================================================*/

PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
        obj_name                IN  VARCHAR2  DEFAULT 'EGO_ITEM',
        pk1_value               IN  VARCHAR2,
        pk2_value               IN  VARCHAR2,
        pk3_value               IN  VARCHAR2  DEFAULT NULL,
        pk4_value               IN  VARCHAR2  DEFAULT NULL,
        pk5_value               IN  VARCHAR2  DEFAULT NULL,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE
  );

PROCEDURE implosion_cad (
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY  VARCHAR2,
  err_code    OUT NOCOPY  NUMBER,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision                IN  VARCHAR2);

PROCEDURE ml_imploder_cad(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  a_levels_to_implode IN  NUMBER,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY  VARCHAR2,
  error_code    OUT NOCOPY  NUMBER,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision                IN  VARCHAR2);
--TYPE t_OrgIDtable IS TABLE OF hr_organization_units.organization_id%TYPE
--    INDEX BY BINARY_INTEGER;

FUNCTION Check_User_View_priv (Itemid varchar2, OrgId varchar2)
  RETURN Varchar2;

FUNCTION CALCULATE_COMP_COUNT
( PK_VALUE1 IN VARCHAR2,
  PK_VALUE2 IN VARCHAR2,
  IMPL_DATE IN VARCHAR2)
RETURN NUMBER;

/* This is an overloaded procedure that will narrow down the where used to the
 * provided structure type. It will simply call the existing imploder_userexit
 * without regard to structure type and then delete the rows from bom_small_impl_temp
 * which do not conform to the user entered structure type.
 * One of the out parameters will contain the count of parents of the given item.
 * Extra parameters:
 *		struct_type    : structure type name
 *		preferred_only : flag to check indicate only whether
 *		                 implosion should be caried out only
 *				 for preferred structures.
 *				 1 for true/ 2 for false
 *		used_count     : Out parameter to indicate no of structures
 *				 of this structure type where this item
 *				 has been used.
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER ,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2  DEFAULT null,
  pk4_value   IN  VARCHAR2  DEFAULT null,
  pk5_value   IN  VARCHAR2  DEFAULT null,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  struct_type             IN  VARCHAR2,
  preferred_only          IN NUMBER DEFAULT 2,
  used_in_structure   OUT NOCOPY VARCHAR2
  );

/*
 * Overloaded procedure to take revision of component to search in first level
 * parent
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
        obj_name                IN  VARCHAR2  DEFAULT 'EGO_ITEM',
        pk1_value               IN  VARCHAR2,
        pk2_value               IN  VARCHAR2,
        pk3_value               IN  VARCHAR2  DEFAULT NULL,
        pk4_value               IN  VARCHAR2  DEFAULT NULL,
        pk5_value               IN  VARCHAR2  DEFAULT NULL,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision                IN  VARCHAR2
  );

/*
 * Overloaded procedure to take revision of component to search in first level
 * parent. This is an overloaded procedure that will narrow down the where used to the
 * provided structure type.
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER ,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2  DEFAULT null,
  pk4_value   IN  VARCHAR2  DEFAULT null,
  pk5_value   IN  VARCHAR2  DEFAULT null,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  struct_type             IN  VARCHAR2,
  preferred_only          IN NUMBER DEFAULT 2,
  used_in_structure   OUT NOCOPY VARCHAR2,
  revision            IN  VARCHAR2
  );
END bom_imploder_pub;

 

/
