--------------------------------------------------------
--  DDL for Package PAY_WCI_OCCUPATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_OCCUPATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pypwoapi.pkh 120.1 2005/10/02 02:33:51 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_occupation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_occupation_b
  (p_occupation_id                 in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_wci_occupation_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_occupation_a
  (p_occupation_id                 in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  );
--
end pay_wci_occupations_bk3;

 

/
