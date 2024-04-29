--------------------------------------------------------
--  DDL for Package PAY_IE_PRSI_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PRSI_BK2" AUTHID CURRENT_USER as
/* $Header: pysidapi.pkh 120.1 2005/10/02 02:34:20 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ie_prsi_details_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ie_prsi_details_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_contribution_class            in     varchar2
  ,p_overridden_subclass           in     varchar2
  ,p_soc_ben_flag                  in     varchar2
  ,p_soc_ben_start_date            in     date
  ,p_overridden_ins_weeks          in     number
  ,p_non_standard_ins_weeks        in     number
  ,p_exemption_start_date          in     date
  ,p_exemption_end_date            in     date
  ,p_cert_issued_by                in     varchar2
  ,p_director_flag                 in     varchar2
  ,p_community_flag                in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ie_prsi_details_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ie_prsi_details_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_contribution_class            in     varchar2
  ,p_overridden_subclass           in     varchar2
  ,p_soc_ben_flag                  in     varchar2
  ,p_soc_ben_start_date            in     date
  ,p_overridden_ins_weeks          in     number
  ,p_non_standard_ins_weeks        in     number
  ,p_exemption_start_date          in     date
  ,p_exemption_end_date            in     date
  ,p_cert_issued_by                in     varchar2
  ,p_director_flag                 in     varchar2
  ,p_community_flag                in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_ie_prsi_bk2;

 

/
