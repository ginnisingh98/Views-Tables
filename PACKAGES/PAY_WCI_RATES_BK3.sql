--------------------------------------------------------
--  DDL for Package PAY_WCI_RATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_RATES_BK3" AUTHID CURRENT_USER as
/* $Header: pypwrapi.pkh 120.1 2005/10/02 02:33:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_rate_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_rate_b
  (p_rate_id                       in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_rate_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_rate_a
  (p_rate_id                       in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
end pay_wci_rates_bk3;

 

/
