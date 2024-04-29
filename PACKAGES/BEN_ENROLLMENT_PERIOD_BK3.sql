--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_PERIOD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_PERIOD_BK3" AUTHID CURRENT_USER as
/* $Header: beenpapi.pkh 120.1 2007/05/13 22:49:18 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrollment_Period_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Period_b
  (
   p_enrt_perd_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrollment_Period_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Period_a
  (
   p_enrt_perd_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Enrollment_Period_bk3;

/
