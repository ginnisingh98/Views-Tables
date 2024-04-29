--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_BK2" AUTHID CURRENT_USER as
/* $Header: hrusrapi.pkh 120.4.12010000.2 2008/08/06 08:50:17 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- | ------------------------ update_user_acct_b ---------------------------- |
-- | The update_user_acct api is strictly used for inactivating terminated    |
-- | person's user account.  The caller api does not gather any information   |
-- | from the user hook program.                                              |
-- |                                                                          |
-- | NOTES:                                                                   |
-- |   p_person_id, p_per_effective_start_date, p_per_effective_end_date:     |
-- |     All 3 parameters are used together to uniquely retrieve person       |
-- |     record information from per_all_people_f table when the person       |
-- |     starts to become 'EX_EMP' in the person type.  For example, if an    |
-- |     person is terminated on 31-Jan-2000,then p_per_effective_start_date  |
-- |     will have a value of 01-Feb-2000, that's when the person becomes     |
-- |     ex_person.                                                           |
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
-- |     record information from per_all_assignments_f table when the person  |
-- |     assignment starts to become 'TERM_ASSIGN' in the assignment status   |
-- |     type. For example, if a person is terminated on 31-Jan-2000,then     |
-- |     p_asg_effective_start_date will have a value of 01-Feb-2000, that's  |
-- |     when the person's assignment becomes Terminate Assignment.           |
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
-- |  p_inactivate_date - The termination date.                               |
-- |                                                                          |
-- ----------------------------------------------------------------------------
--
-- api user hooks - update_user_acct_b
--
PROCEDURE update_user_acct_b
  (p_person_id                     in     number
  ,p_per_effective_start_date      in     date
  ,p_per_effective_end_date        in     date
  ,p_assignment_id                 in     number
  ,p_asg_effective_start_date      in     date
  ,p_asg_effective_end_date        in     date
  ,p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_org_structure_id              in     number
  ,p_org_structure_vers_id         in     number
  ,p_parent_org_id                 in     number
  ,p_single_org_id                 in     number
  ,p_run_type                      in     varchar2
  ,p_inactivate_date               in     date
  );

--
-- ----------------------------------------------------------------------------
-- | ------------------------ update_user_acct_a ---------------------------- |
-- | The update_user_acct api is strictly used for inactivating terminated    |
-- | person's user account.  The caller api does not gather any information   |
-- | from the user hook program.                                              |
-- |                                                                          |
-- | NOTES:                                                                   |
-- |   p_person_id, p_per_effective_start_date, p_per_effective_end_date:     |
-- |     All 3 parameters are used together to uniquely retrieve person       |
-- |     record information from per_all_people_f table when the person       |
-- |     starts to become 'EX_EMP' in the person type.  For example, if an    |
-- |     person is terminated on 31-Jan-2000,then p_per_effective_start_date  |
-- |     will have a value of 01-Feb-2000, that's when the person's person    |
-- |     type becomes ex_person.                                              |
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
-- |     record information from per_all_assignments_f table when the person  |
-- |     assignment starts to become 'TERM_ASSIGN' in the assignment status   |
-- |     type. For example, if a person is terminated on 31-Jan-2000,then     |
-- |     p_asg_effective_start_date will have a value of 01-Feb-2000, that's  |
-- |     when the person's assignment becomes Terminate Assignment.           |
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
-- |  p_inactivate_date - The termination date.                               |
-- |                                                                          |
-- ----------------------------------------------------------------------------
-- api user hooks - update_user_acct_a
--
PROCEDURE update_user_acct_a
  (p_person_id                     in     number
  ,p_per_effective_start_date      in     date
  ,p_per_effective_end_date        in     date
  ,p_assignment_id                 in     number
  ,p_asg_effective_start_date      in     date
  ,p_asg_effective_end_date        in     date
  ,p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_org_structure_id              in     number
  ,p_org_structure_vers_id         in     number
  ,p_parent_org_id                 in     number
  ,p_single_org_id                 in     number
  ,p_run_type                      in     varchar2
  ,p_inactivate_date               in     date
  );

--
END hr_user_acct_bk2;

/
