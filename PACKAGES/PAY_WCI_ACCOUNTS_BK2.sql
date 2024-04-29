--------------------------------------------------------
--  DDL for Package PAY_WCI_ACCOUNTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_ACCOUNTS_BK2" AUTHID CURRENT_USER as
/* $Header: pypwaapi.pkh 120.1 2005/10/02 02:33:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_account_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_account_b
  (p_effective_date                in     date
  ,p_account_id                    in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_carrier_id                    in     number
  ,p_location_id                   in     number
  ,p_name                          in     varchar2
  ,p_account_number                in     varchar2
  ,p_comments                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_account_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_account_a
  (p_effective_date                in     date
  ,p_account_id                    in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_carrier_id                    in     number
  ,p_location_id                   in     number
  ,p_name                          in     varchar2
  ,p_account_number                in     varchar2
  ,p_comments                      in     varchar2
  );
--
end pay_wci_accounts_bk2;

 

/
