--------------------------------------------------------
--  DDL for Package PAY_IE_PRSI_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PRSI_BK3" AUTHID CURRENT_USER as
/* $Header: pysidapi.pkh 120.1 2005/10/02 02:34:20 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_prsi_details_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_prsi_details_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ie_prsi_details_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_prsi_details_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_ie_prsi_bk3;

 

/
