--------------------------------------------------------
--  DDL for Package PAY_IE_PAYE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYE_BK3" AUTHID CURRENT_USER as
/* $Header: pyipdapi.pkh 120.9 2008/01/11 06:59:21 rrajaman noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_paye_details_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_paye_details_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ie_paye_details_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_paye_details_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_ie_paye_bk3;

/
