--------------------------------------------------------
--  DDL for Package PAY_NL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_RULES" AUTHID CURRENT_USER as
/* $Header: pynlrule.pkh 120.3 2006/11/07 06:05:06 vbattu noship $ */


-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+

---------------------------------------------------------------------------
-- Procedure: get_override_ctx_value
-- Procedure returns current system effective date in canonical format
---------------------------------------------------------------------------

PROCEDURE  get_override_ctx_value (p_retro_asg_action_id   IN     Number,
                                   p_run_asg_action_id     IN     Number,
                                   p_element_type_id       IN     Number,
                                   p_retro_component_id    IN     Number,
                                   p_override_date         IN OUT NOCOPY varchar2);

-- Added an additional parameter p_element_type_id as a part of 11.5.10 changes
PROCEDURE get_retro_component_id (p_ee_id IN Number,
                                  p_element_type_id IN Number default -1,
				  p_retro_component_id IN OUT NOCOPY Number);


---------------------------------------------------------------------------
-- Procedure : get_asg_process_group
-- This procedure gives the process group name for an assignment
---------------------------------------------------------------------------

Procedure get_asg_process_group(p_assignment_id		IN  Number,
                                p_effective_start_date	IN  Date,
                                p_effective_end_date	IN  Date,
                                p_process_group_name	OUT NOCOPY Varchar2);


---------------------------------------------------------------------------
-- Procedure : get_main_tax_unit_id
-- This procedure gives the tax unit id for an assignment
---------------------------------------------------------------------------

PROCEDURE get_main_tax_unit_id(p_assignment_id   IN     NUMBER,
                               p_effective_date  IN     DATE,
                               p_tax_unit_id     IN OUT NOCOPY NUMBER);
--
---------------------------------------------------------------------------
-- Function : get_object_group_type
-- This Function returns the type, the object group is based on
-- 'PAYROLL' if based on payroll_id
-- 'EMPLOYER' if based on HR Organization
---------------------------------------------------------------------------
FUNCTION get_object_group_type RETURN VARCHAR2 ;

END PAY_NL_RULES;

/
