--------------------------------------------------------
--  DDL for Package PAY_CNU_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_API_BK3" AUTHID CURRENT_USER as
/* $Header: pycnuapi.pkh 120.1 2005/10/02 02:29:59 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_contribution_usage_b >------------------|
-- ----------------------------------------------------------------------------
procedure delete_contribution_usage_b
  (p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_contribution_usage_a >------------------|
-- ----------------------------------------------------------------------------
procedure delete_contribution_usage_a
  (p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  );
--
end pay_cnu_api_bk3;

 

/
