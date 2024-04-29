--------------------------------------------------------
--  DDL for Package PAY_WCI_OCCUPATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_OCCUPATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pypwoapi.pkh 120.1 2005/10/02 02:33:51 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_occupation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_occupation_b
  (p_effective_date                in     date
  ,p_occupation_id                 in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_rate_id                       in     number
  ,p_job_id                        in     number
  ,p_comments                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_wci_occupation_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_occupation_a
  (p_effective_date                in     date
  ,p_occupation_id                 in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_rate_id                       in     number
  ,p_job_id                        in     number
  ,p_comments                      in     varchar2
  );
--
end pay_wci_occupations_bk2;

 

/
