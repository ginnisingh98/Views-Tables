--------------------------------------------------------
--  DDL for Package BEN_PL_PRMRY_CARE_PRVDR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_PRMRY_CARE_PRVDR_BK3" AUTHID CURRENT_USER as
/* $Header: bepcpapi.pkh 120.0 2005/05/28 10:13:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_prmry_care_prvdr_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_prmry_care_prvdr_b
  (
   p_pl_pcp_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_prmry_care_prvdr_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_prmry_care_prvdr_a
  (
   p_pl_pcp_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pl_prmry_care_prvdr_bk3;

 

/
