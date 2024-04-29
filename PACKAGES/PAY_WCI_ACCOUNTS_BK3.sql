--------------------------------------------------------
--  DDL for Package PAY_WCI_ACCOUNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_ACCOUNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pypwaapi.pkh 120.1 2005/10/02 02:33:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_account_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_account_b
  (p_account_id                    in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_account_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_account_a
  (p_account_id                    in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
end pay_wci_accounts_bk3;

 

/
