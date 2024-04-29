--------------------------------------------------------
--  DDL for Package BEN_PL_CARE_PRVDR_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_CARE_PRVDR_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: beptyapi.pkh 120.0 2005/05/28 11:25:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_care_prvdr_typ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_care_prvdr_typ_b
  (
   p_pl_pcp_typ_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_care_prvdr_typ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_care_prvdr_typ_a
  (
   p_pl_pcp_typ_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pl_care_prvdr_typ_bk3;

 

/
