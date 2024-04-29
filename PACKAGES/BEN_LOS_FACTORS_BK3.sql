--------------------------------------------------------
--  DDL for Package BEN_LOS_FACTORS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOS_FACTORS_BK3" AUTHID CURRENT_USER as
/* $Header: belsfapi.pkh 120.0 2005/05/28 03:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LOS_FACTORS_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LOS_FACTORS_b
  (
   p_los_fctr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LOS_FACTORS_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LOS_FACTORS_a
  (
   p_los_fctr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_LOS_FACTORS_bk3;

 

/
