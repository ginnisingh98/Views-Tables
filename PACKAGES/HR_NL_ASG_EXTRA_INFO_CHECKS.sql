--------------------------------------------------------
--  DDL for Package HR_NL_ASG_EXTRA_INFO_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ASG_EXTRA_INFO_CHECKS" AUTHID CURRENT_USER AS
  /* $Header: penlaeiv.pkh 120.0.12010000.2 2009/03/18 08:38:26 knadhan ship $ */
  --
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  -- Called from the Create_Assignment_Extra_Info Before Process Hook
  -- and sets the Assignment ID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PROCEDURE set_asg_id (p_assignment_id  in     number);
  FUNCTION  ASG_CHECK_NUMIV_OVERRIDE(
                                  P_ASSIGNMENT_ID in NUMBER
                                 ,P_AEI_INFORMATION1 in VARCHAR2
	                       ) return number;
  PROCEDURE CHECK_NUMIV_OVERRIDE(P_ASSIGNMENT_EXTRA_INFO_ID in NUMBER
                                                 ,P_AEI_INFORMATION1 in VARCHAR2);
END hr_nl_asg_extra_info_checks;

/
