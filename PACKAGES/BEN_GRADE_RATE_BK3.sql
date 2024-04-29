--------------------------------------------------------
--  DDL for Package BEN_GRADE_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GRADE_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: begrrapi.pkh 120.0 2005/05/28 03:09:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GRADE_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GRADE_RATE_b
  (
   p_grade_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GRADE_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GRADE_RATE_a
  (
   p_grade_rt_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_GRADE_RATE_bk3;

 

/
