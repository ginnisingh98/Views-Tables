--------------------------------------------------------
--  DDL for Package BEN_SCHEDD_ENROLLMENT_RL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SCHEDD_ENROLLMENT_RL_BK3" AUTHID CURRENT_USER as
/* $Header: beserapi.pkh 120.0 2005/05/28 11:50:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Schedd_Enrollment_Rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Schedd_Enrollment_Rl_b
  (
   p_schedd_enrt_rl_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Schedd_Enrollment_Rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Schedd_Enrollment_Rl_a
  (
   p_schedd_enrt_rl_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Schedd_Enrollment_Rl_bk3;

 

/
