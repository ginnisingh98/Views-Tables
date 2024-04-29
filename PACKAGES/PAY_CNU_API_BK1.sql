--------------------------------------------------------
--  DDL for Package PAY_CNU_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_API_BK1" AUTHID CURRENT_USER as
/* $Header: pycnuapi.pkh 120.1 2005/10/02 02:29:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_contribution usage_b >------------------|
-- ----------------------------------------------------------------------------
Procedure create_contribution_usage_b
  (p_effective_date                in     date
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_group_code                    in     varchar2
  ,p_process_type                  in     varchar2
  ,p_element_name                  in     varchar2
  ,p_contribution_usage_type       in     varchar2
  ,p_rate_type                     in     varchar2
  ,p_rate_category                 in     varchar2
  ,p_contribution_code             in     varchar2
  ,p_contribution_type             in     varchar2
  ,p_retro_contribution_code       in     varchar2
  ,p_business_group_id             in     number
  ,p_code_Rate_id                  in     number
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_contribution usage_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_contribution_usage_a
  (p_effective_date                in     date
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_group_code                    in     varchar2
  ,p_process_type                  in     varchar2
  ,p_element_name                  in     varchar2
  ,p_contribution_usage_type       in     varchar2
  ,p_rate_type                     in     varchar2
  ,p_rate_category                 in     varchar2
  ,p_contribution_code             in     varchar2
  ,p_contribution_type             in     varchar2
  ,p_retro_contribution_code       in     varchar2
  ,p_business_group_id             in     number
  ,p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_code_rate_id                  in     number
  );
end pay_cnu_api_bk1;

 

/
