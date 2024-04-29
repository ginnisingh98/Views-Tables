--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_BK1" AUTHID CURRENT_USER as
/* $Header: hrusrapi.pkh 120.4.12010000.2 2008/08/06 08:50:17 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_acct_b >--------------------------|
-- |                                                                          |
-- | NOTES:                                                                   |
-- |   p_person_id, p_per_effective_start_date, p_per_effective_end_date:     |
-- |     All 3 parameters are used together to uniquely retrieve person       |
-- |     record information from per_all_people_f table.                      |
-- |     The SELECT statement should be something like:                       |
-- |       *** Use "=" for the date comparision ***                           |
-- |       Select .....                                                       |
-- |       from   per_all_people_f  ppf                                       |
-- |       where  ppf.person_id = p_person_id                                 |
-- |       and    ppf.effective_start_date = p_per_effective_start_date       |
-- |       and    ppf.effective_end_date = p_per_effective_end_date           |
-- |       and    .....                                                       |
-- |                                                                          |
-- |   p_assignment_id, p_asg_effective_start_date, p_asg_effective_end_date: |
-- |     All 3 parameters are used together to uniquely retrieve assignment   |
-- |     record information from per_all_assignments_f table.                 |
-- |     The SELECT statement should be something like:                       |
-- |       *** Use "=" for the date comparision ***                           |
-- |       Select .....                                                       |
-- |       from   per_all_assignments paf                                     |
-- |       where  paf.assignment_id = p_assignment_id                         |
-- |       and    paf.effective_start_date = p_asg_effective_start_date       |
-- |       and    paf.effective_end_date = p_asg_effective_end_date           |
-- |       and    .....                                                       |
-- |                                                                          |
-- |   p_date_from, p_date_to:                                                |
-- |     The date comparison will be different depending on p_run_type.       |
-- |     Normally, in user hook program, the set of p_person_id and           |
-- |     p_assignment_id fields should be sufficient to retrieve person or    |
-- |     assignment record info.  These two fields are provided so that the   |
-- |     user hook program knows what the person extract criteria are.        |
-- |                                                                          |
-- |  p_org_structure_id, p_org_structure_vers_id, p_parent_org_id,           |
-- |  p_single_org_id, p_run_type - these parameters are provided for the     |
-- |     purpose of letting user hook program know what the person extract    |
-- |     criteria are.                                                        |
-- |                                                                          |
-- |  p_hire_date - This date is provided so that the user hook program can   |
-- |     decide what the start date should be for the new user record.        |
-- |     Usually the start date for a new hire's user account should be the   |
-- |     hire date.  However, the user hook program can supply any date but   |
-- |     not before the hire date.                                            |
-- |                                                                          |
-- ----------------------------------------------------------------------------
-- api user hooks - create_user_acct_b
PROCEDURE create_user_acct_b
      (p_person_id                    in number
      ,p_per_effective_start_date     in date
      ,p_per_effective_end_date       in date
      ,p_assignment_id                in number
      ,p_asg_effective_start_date     in date
      ,p_asg_effective_end_date       in date
      ,p_business_group_id            in number
      ,p_date_from                    in date
      ,p_date_to                      in date
      ,p_org_structure_id             in number
      ,p_org_structure_vers_id        in number
      ,p_parent_org_id                in number
      ,p_single_org_id                in number
      ,p_run_type                     in varchar2
      ,p_hire_date                    in date
      );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_acct_a >--------------------------|
-- | This user hook is used for saving automatically generated password       |
-- | information by the user hook program.                                    |
-- |                                                                          |
-- | NOTES:                                                                   |
-- |   p_person_id, p_per_effective_start_date, p_per_effective_end_date:     |
-- |     All 3 parameters are used together to uniquely retrieve person       |
-- |     record information from per_all_people_f table.                      |
-- |     The SELECT statement should be something like:                       |
-- |       *** Use "=" for the date comparision ***                           |
-- |       Select .....                                                       |
-- |       from   per_all_people_f  ppf                                       |
-- |       where  ppf.person_id = p_person_id                                 |
-- |       and    ppf.effective_start_date = p_per_effective_start_date       |
-- |       and    ppf.effective_end_date = p_per_effective_end_date           |
-- |       and    .....                                                       |
-- |                                                                          |
-- |   p_assignment_id, p_asg_effective_start_date, p_asg_effective_end_date: |
-- |     All 3 parameters are used together to uniquely retrieve assignment   |
-- |     record information from per_all_assignments_f table.                 |
-- |     The SELECT statement should be something like:                       |
-- |       *** Use "=" for the date comparision ***                           |
-- |       Select .....                                                       |
-- |       from   per_all_assignments paf                                     |
-- |       where  paf.assignment_id = p_assignment_id                         |
-- |       and    paf.effective_start_date = p_asg_effective_start_date       |
-- |       and    paf.effective_end_date = p_asg_effective_end_date           |
-- |       and    .....                                                       |
-- |                                                                          |
-- |   p_date_from, p_date_to:                                                |
-- |     The date comparison will be different depending on p_run_type.       |
-- |     Normally, in user hook program, the set of p_person_id and           |
-- |     p_assignment_id fields should be sufficient to retrieve person or    |
-- |     assignment record info.  These two fields are provided so that the   |
-- |     user hook program knows what the person extract criteria are.        |
-- |                                                                          |
-- |  p_org_structure_id, p_org_structure_vers_id, p_parent_org_id,           |
-- |  p_single_org_id, p_run_type - these parameters are provided for the     |
-- |     purpose of letting user hook program know what the person extract    |
-- |     criteria are.                                                        |
-- |                                                                          |
-- |  p_hire_date - This date is provided so that the user hook program can   |
-- |     decide what the start date should be for the new user record.        |
-- |     Usually the start date for a new hire's user account should be the   |
-- |     hire date.  However, the user hook program can supply any date but   |
-- |     not before the hire date.                                            |
-- |                                                                          |
-- ----------------------------------------------------------------------------
-- api user hooks - create_user_acct_a
PROCEDURE create_user_acct_a
      (p_person_id                    in number
      ,p_per_effective_start_date     in date
      ,p_per_effective_end_date       in date
      ,p_assignment_id                in number
      ,p_asg_effective_start_date     in date
      ,p_asg_effective_end_date       in date
      ,p_business_group_id            in number
      ,p_date_from                    in date
      ,p_date_to                      in date
      ,p_org_structure_id             in number
      ,p_org_structure_vers_id        in number
      ,p_parent_org_id                in number
      ,p_single_org_id                in number
      ,p_run_type                     in varchar2
      ,p_hire_date                    in date
      );
--
END hr_user_acct_bk1;

/
