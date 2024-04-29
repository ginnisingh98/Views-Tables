--------------------------------------------------------
--  DDL for Package PAY_WCI_ACCOUNTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_ACCOUNTS_BK1" AUTHID CURRENT_USER as
/* $Header: pypwaapi.pkh 120.1 2005/10/02 02:33:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_wci_account_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_wci_account_b
  (p_effective_date                in     date
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
-- |-------------------------< create_wci_account_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_wci_account_a
  (p_effective_date                in     date
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_carrier_id                    in     number
  ,p_location_id                   in     number
  ,p_name                          in     varchar2
  ,p_account_number                in     varchar2
  ,p_comments                      in     varchar2
  ,p_account_id                    in     number
  );
--
end pay_wci_accounts_bk1;

 

/
