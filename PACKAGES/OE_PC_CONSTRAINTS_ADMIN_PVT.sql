--------------------------------------------------------
--  DDL for Package OE_PC_CONSTRAINTS_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_CONSTRAINTS_ADMIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPCAS.pls 120.1 2006/03/29 16:51:23 spooruli noship $ */

--  Start of Comments
--  API name    Make_Validation_Pkg
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

--------------------------------------------------------------
PROCEDURE Make_Validation_Pkg
--------------------------------------------------------------
(
   p_entity_id                      in number,
   p_entity_short_name              in varchar2,
   p_db_object_name                 in varchar2,
   p_validation_entity_id           in number,
   p_validation_entity_short_name   in varchar2,
   p_validation_db_object_name      in varchar2,
   p_validation_tmplt_id            in number,
   p_validation_tmplt_short_name    in varchar2,
   p_record_set_id                  in number,
   p_record_set_short_name          in varchar2,
   p_global_record_name             in varchar2,
x_pkg_name out nocopy varchar2,

x_pkg_spec out nocopy long,

x_pkg_body out nocopy long,

x_control_tbl_sql out nocopy varchar2,

x_return_status out nocopy varchar2,

x_msg_data out nocopy varchar2,

x_msg_count out nocopy number

);

-- Bug 1755817: function introduced to check if any
-- attribute-specific constraints with check_on_insert_flag = 'Y'
-- exist for this entity
--------------------------------------------------------------
FUNCTION Check_On_Insert_Exists
--------------------------------------------------------------
 (
   p_entity_id                   in number
   ,p_responsibility_id          in number
   ,p_application_id             in number  default NULL  --added for bug3631547
  )
RETURN BOOLEAN;

-- Bug 1755817: procedure to clear cached results
-- if validation_entity_id is passed, only results with that
-- validation_entity are cleared else entire cache is cleared
--------------------------------------------------------------
PROCEDURE Clear_Cached_Results
--------------------------------------------------------------
 (
   p_validation_entity_id        in number default null
  );

-- Bug 1755817: introduced p_use_cached_results parameter to
-- indicate whether constraints should use cached results
-- for condition where validation entity is not the same as
-- constrained entity.
--------------------------------------------------------------
PROCEDURE Validate_Constraint
--------------------------------------------------------------
(   p_constraint_id                in  number
   ,p_use_cached_results           in  varchar2 default 'N'
,x_condition_count out nocopy number

,x_valid_condition_group out nocopy number

,x_result out nocopy number

);

--------------------------------------------------------------
FUNCTION Is_Op_Constrained
--------------------------------------------------------------
 (
   p_responsibility_id             in number
   ,p_application_id               in number default NULL   --added for bug3631547
   ,p_operation                    in varchar2
   ,p_entity_id			   in number
   ,p_qualifier_attribute          in varchar2 default NULL
   ,p_column_name                  in varchar2 default NULL
   ,p_check_all_cols_constraint    in varchar2 default 'Y'
   ,p_is_caller_defaulting         in varchar2 default 'N'
   ,p_use_cached_results           in varchar2 default 'N'
,x_constraint_id out nocopy number

,x_constraining_conditions_grp out nocopy number

,x_on_operation_action out nocopy number

 )
RETURN NUMBER;

END Oe_PC_Constraints_Admin_Pvt;

/
