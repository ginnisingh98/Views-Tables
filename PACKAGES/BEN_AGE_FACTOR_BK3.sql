--------------------------------------------------------
--  DDL for Package BEN_AGE_FACTOR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGE_FACTOR_BK3" AUTHID CURRENT_USER as
/* $Header: beagfapi.pkh 120.0 2005/05/28 00:22:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_age_factor_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_age_factor_b
  (
   p_age_fctr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_age_factor_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_age_factor_a
  (
   p_age_fctr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_age_factor_bk3;

 

/
