--------------------------------------------------------
--  DDL for Package PAY_CNU_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_API_BK2" AUTHID CURRENT_USER as
/* $Header: pycnuapi.pkh 120.1 2005/10/02 02:29:59 aroussel $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_contribution_usage_b >------------------|
-- ----------------------------------------------------------------------------
procedure update_contribution_usage_b
  (p_effective_date                in     date
  ,p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_date_to                       in     date
  ,p_contribution_code            IN      varchar2
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code       in     varchar2
  ,p_code_rate_id                 IN      varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_contribution_usage_a >------------------|
-- ----------------------------------------------------------------------------
procedure update_contribution_usage_a
  (p_effective_date                in     date
  ,p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_date_to                       in     date
  ,p_contribution_code            IN      varchar2
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code       in     varchar2
  ,p_code_rate_id                 IN      varchar2
  );
end pay_cnu_api_bk2;

 

/
