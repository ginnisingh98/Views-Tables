--------------------------------------------------------
--  DDL for Package PAY_PWA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWA_RKI" AUTHID CURRENT_USER as
/* $Header: pypwarhi.pkh 120.0 2005/05/29 08:06:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_account_id                     in number
 ,p_business_group_id              in number
 ,p_carrier_id                     in number
 ,p_location_id                    in number
 ,p_name                           in varchar2
 ,p_account_number                 in varchar2
 ,p_comments                       in long
 ,p_object_version_number          in number
  );
end pay_pwa_rki;

 

/
