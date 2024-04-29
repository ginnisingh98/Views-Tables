--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beecrapi.pkh 120.0 2005/05/28 01:52:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrollment_Rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Rate_b
  (
   p_enrt_rt_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrollment_Rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Rate_a
  (
   p_enrt_rt_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Enrollment_Rate_bk3;

 

/
