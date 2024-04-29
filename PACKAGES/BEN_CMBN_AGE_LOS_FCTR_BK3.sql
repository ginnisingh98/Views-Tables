--------------------------------------------------------
--  DDL for Package BEN_CMBN_AGE_LOS_FCTR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_AGE_LOS_FCTR_BK3" AUTHID CURRENT_USER as
/* $Header: beclaapi.pkh 120.0 2005/05/28 01:03:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cmbn_age_los_fctr_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cmbn_age_los_fctr_b
  (
   p_cmbn_age_los_fctr_id           in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cmbn_age_los_fctr_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cmbn_age_los_fctr_a
  (
   p_cmbn_age_los_fctr_id           in  number
  ,p_object_version_number          in  number
  );
--
end ben_cmbn_age_los_fctr_bk3;

 

/
