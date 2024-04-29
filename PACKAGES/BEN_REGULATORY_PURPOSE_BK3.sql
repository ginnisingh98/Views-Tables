--------------------------------------------------------
--  DDL for Package BEN_REGULATORY_PURPOSE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REGULATORY_PURPOSE_BK3" AUTHID CURRENT_USER as
/* $Header: beprpapi.pkh 120.0 2005/05/28 11:11:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_regulatory_purpose_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulatory_purpose_b
  (
   p_pl_regy_prps_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_regulatory_purpose_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulatory_purpose_a
  (
   p_pl_regy_prps_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_regulatory_purpose_bk3;

 

/
