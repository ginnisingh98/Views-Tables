--------------------------------------------------------
--  DDL for Package BEN_SERVICE_AREA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SERVICE_AREA_BK3" AUTHID CURRENT_USER as
/* $Header: besvaapi.pkh 120.0 2005/05/28 11:53:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SERVICE_AREA_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SERVICE_AREA_b
  (
   p_svc_area_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SERVICE_AREA_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SERVICE_AREA_a
  (
   p_svc_area_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_SERVICE_AREA_bk3;

 

/
