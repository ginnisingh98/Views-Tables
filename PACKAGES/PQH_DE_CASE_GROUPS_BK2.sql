--------------------------------------------------------
--  DDL for Package PQH_DE_CASE_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CASE_GROUPS_BK2" AUTHID CURRENT_USER as
/* $Header: pqcgnapi.pkh 120.0 2005/05/29 01:42:49 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_CASE_GROUPS_> >------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_CASE_GROUPS_b
(  p_effective_date                     in  date
  ,p_Case_Group_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_Advanced_Pay_Grade		        IN  Number
  ,p_Entries_in_Minute		        In  Varchar2
  ,p_Period_Of_Prob_Advmnt              IN  Number
  ,p_Period_Of_Time_Advmnt	        IN  Number
  ,p_Advancement_To			IN  Number
  ,p_Advancement_Additional_pyt  	IN  Number
  ,P_CASE_GROUP_ID                      in  Number
  ,p_object_version_number              in  number
   ,p_time_advanced_pay_grade           in  number
  ,p_time_advancement_to                in  number
  ,p_business_group_id                  in  number
  ,p_time_advn_units                    in  varchar2
  ,p_prob_advn_units                    in  varchar2
  ,p_sub_csgrp_description              In  Varchar2) ;


procedure Update_CASE_GROUPS_a
 ( p_effective_date                     in  date
  ,p_Case_Group_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_Advanced_Pay_Grade		        IN  Number
  ,p_Entries_in_Minute		        In  Varchar2
  ,p_Period_Of_Prob_Advmnt              IN  Number
  ,p_Period_Of_Time_Advmnt	        IN  Number
  ,p_Advancement_To			IN  Number
  ,p_Advancement_Additional_pyt  	IN  Number
  ,P_CASE_GROUP_ID                      in  Number
  ,p_object_version_number              in  number
  ,p_time_advanced_pay_grade            in  number
  ,p_time_advancement_to                in  number
  ,p_business_group_id                  in  number
  ,p_time_advn_units                    in  varchar2
  ,p_prob_advn_units                    in  varchar2
  ,p_sub_csgrp_description              In  Varchar2 ) ;

end PQH_DE_CASE_GROUPS_BK2;

 

/
