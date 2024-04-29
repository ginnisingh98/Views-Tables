--------------------------------------------------------
--  DDL for Package BEN_ELIG_OBJ_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_OBJ_BK3" AUTHID CURRENT_USER as
/* $Header: bebeoapi.pkh 120.0 2005/05/28 00:38:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_OBJ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OBJ_b
  (
   p_elig_obj_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_OBJ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OBJ_a
  (
   p_elig_obj_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_elig_obj_bk3;

 

/
