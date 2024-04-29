--------------------------------------------------------
--  DDL for Package PQP_NL_EXT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_EXT_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pqpextff.pkh 120.2 2005/10/30 21:07 vjhanak noship $ */

  g_proc_name                varchar2(80) := 'pqp_nl_ext_functions.';

-- ----------------------------------------------------------------------------
-- |---------------------< create_org_pt_ins_chg_evt >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pt_ins_chg_evt (p_organization_id         IN number
                                      ,p_org_information1        IN varchar2
                                      ,p_org_information2        IN varchar2
                                      ,p_org_information3        IN varchar2
                                      ,p_org_information6        IN varchar2
                                      ,p_effective_date          IN date
                                      );

-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pt_upd_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pt_upd_chg_evt (p_organization_id         number
                                      ,p_org_information1        varchar2
                                      ,p_org_information2        varchar2
                                      ,p_org_information3        varchar2
                                      ,p_org_information6        varchar2
                                      ,p_org_information1_o      varchar2
                                      ,p_org_information2_o      varchar2
                                      ,p_org_information3_o      varchar2
                                      ,p_org_information6_o      varchar2
                                      ,p_effective_date          date
                                     );

-- ----------------------------------------------------------------------------
-- |------------------< create_asg_info_ins_chg_evt>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_asg_info_ins_chg_evt (p_assignment_id            IN NUMBER
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN VARCHAR2
                                      ,p_aei_information2         IN VARCHAR2
                                      ,p_aei_information3         IN VARCHAR2
                                      ,p_aei_information4         IN VARCHAR2
                                      ,p_effective_date           IN DATE
                                      ,p_abp_reporting_date       IN DATE
                                      ) ;
-- ----------------------------------------------------------------------------
-- |-------------------< create_asg_info_upd_chg_evt>--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_asg_info_upd_chg_evt (p_assignment_id            IN NUMBER
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN VARCHAR2
                                      ,p_aei_information2         IN VARCHAR2
                                      ,p_aei_information3         IN VARCHAR2
                                      ,p_aei_information4         IN VARCHAR2
                                      ,p_aei_information1_o       IN VARCHAR2
                                      ,p_aei_information2_o       IN VARCHAR2
                                      ,p_effective_date           IN DATE
                                      ,p_abp_reporting_date       IN DATE
                                      );

-- ----------------------------------------------------------------------------
-- |---------------------< create_org_pp_ins_chg_evt >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pp_ins_chg_evt (p_organization_id         IN number
                                    ,p_org_information1        IN varchar2
                                    ,p_org_information2        IN varchar2
                                    ,p_org_information3        IN varchar2
                                    ,p_effective_date          IN date
                                    );

-- ----------------------------------------------------------------------------
-- |-------------------< create_org_pp_upd_chg_evt >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_pp_upd_chg_evt (p_organization_id         number
                                    ,p_org_information1        varchar2
                                    ,p_org_information2        varchar2
                                    ,p_org_information3        varchar2
                                    ,p_org_information1_o      varchar2
                                    ,p_org_information2_o      varchar2
                                    ,p_org_information3_o      varchar2
                                    ,p_effective_date          date
                                    );

-- ----------------------------------------------------------------------------
-- |------------------< create_si_info_ins_chg_evt>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_si_info_ins_chg_evt (p_assignment_id            IN number
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information3         IN varchar2
                                      ,p_effective_date           IN date
                                      );

-- ----------------------------------------------------------------------------
-- |------------------< create_si_info_upd_chg_evt>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_si_info_upd_chg_evt (p_assignment_id            IN number
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information3         IN varchar2
                                      ,p_aei_information1_o       IN varchar2
                                      ,p_aei_information2_o       IN varchar2
                                      ,p_aei_information3_o       IN varchar2
                                      ,p_effective_date           IN date
                                      );

-- ----------------------------------------------------------------------------
-- |------------------< create_sal_info_ins_chg_evt>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sal_info_ins_chg_evt (p_assignment_id            IN number
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information4         IN varchar2
                                      ,p_aei_information5         IN varchar2
                                      ,p_aei_information6         IN varchar2
                                      ,p_effective_date           IN date
                                      ,p_abp_reporting_date       IN DATE
                                      );

-- ----------------------------------------------------------------------------
-- |-------------------< create_sal_info_upd_chg_evt>--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sal_info_upd_chg_evt (p_assignment_id            IN number
                                      ,p_assignment_extra_info_id IN NUMBER
                                      ,p_aei_information1         IN varchar2
                                      ,p_aei_information2         IN varchar2
                                      ,p_aei_information4         IN varchar2
                                      ,p_aei_information5         IN varchar2
                                      ,p_aei_information6         IN varchar2
                                      ,p_aei_information1_o       IN varchar2
                                      ,p_aei_information2_o       IN varchar2
                                      ,p_aei_information4_o       IN varchar2
                                      ,p_aei_information5_o       IN varchar2
                                      ,p_aei_information6_o       IN varchar2
                                      ,p_effective_date           IN date
                                      ,p_abp_reporting_date       IN DATE
                                      );

END pqp_nl_ext_functions;
--

 

/
