--------------------------------------------------------
--  DDL for Package PAY_IE_SB_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_SB_API_BK3" AUTHID CURRENT_USER as
/* $Header: pyisbapi.pkh 120.0 2005/05/29 06:01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_sb_details_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_sb_details_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_social_benefit_id             in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_sb_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_sb_details_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_delete_mode         in     varchar2
  ,p_social_benefit_id             in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_ie_sb_api_bk3;

 

/
