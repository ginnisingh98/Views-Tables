--------------------------------------------------------
--  DDL for Package PAY_WCI_RATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_RATES_BK2" AUTHID CURRENT_USER as
/* $Header: pypwrapi.pkh 120.1 2005/10/02 02:33:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_rate_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_rate_b
  (p_rate_id                       in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_account_id                    in     number
  ,p_code                          in     varchar2
  ,p_rate                          in     number
  ,p_description                   in     varchar2
  ,p_comments                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_rate_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_rate_a
  (p_rate_id                       in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_account_id                    in     number
  ,p_code                          in     varchar2
  ,p_rate                          in     number
  ,p_description                   in     varchar2
  ,p_comments                      in     varchar2
  );
--
end pay_wci_rates_bk2;

 

/
