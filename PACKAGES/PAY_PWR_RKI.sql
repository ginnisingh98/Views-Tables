--------------------------------------------------------
--  DDL for Package PAY_PWR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWR_RKI" AUTHID CURRENT_USER as
/* $Header: pypwrrhi.pkh 120.0 2005/05/29 08:09:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_rate_id                        in number
 ,p_business_group_id              in number
 ,p_account_id                     in number
 ,p_code                           in varchar2
 ,p_rate                           in number
 ,p_description                    in varchar2
 ,p_comments                       in long
 ,p_object_version_number          in number
  );
end pay_pwr_rki;

 

/
