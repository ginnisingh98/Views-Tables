--------------------------------------------------------
--  DDL for Package BEN_SERVICE_AREA_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SERVICE_AREA_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: besarapi.pkh 120.0 2005/05/28 11:47:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_service_area_rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_service_area_rate_b
  (
   p_svc_area_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_service_area_rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_service_area_rate_a
  (
   p_svc_area_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_service_area_rate_bk3;

 

/
