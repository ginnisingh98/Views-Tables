--------------------------------------------------------
--  DDL for Package BEN_CBR_PER_IN_LER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_PER_IN_LER_BK3" AUTHID CURRENT_USER as
/* $Header: becrpapi.pkh 120.0 2005/05/28 01:21:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CBR_PER_IN_LER_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_PER_IN_LER_b
  (
   p_cbr_per_in_ler_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CBR_PER_IN_LER_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_PER_IN_LER_a
  (
   p_cbr_per_in_ler_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_CBR_PER_IN_LER_bk3;

 

/
