--------------------------------------------------------
--  DDL for Package BEN_HRS_WKD_IN_PERD_FCTR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRS_WKD_IN_PERD_FCTR_BK3" AUTHID CURRENT_USER as
/* $Header: behwfapi.pkh 120.0 2005/05/28 03:11:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hrs_wkd_in_perd_fctr_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hrs_wkd_in_perd_fctr_b
  (
   p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hrs_wkd_in_perd_fctr_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hrs_wkd_in_perd_fctr_a
  (
   p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_hrs_wkd_in_perd_fctr_bk3;

 

/
