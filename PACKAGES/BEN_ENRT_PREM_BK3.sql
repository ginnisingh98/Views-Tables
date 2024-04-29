--------------------------------------------------------
--  DDL for Package BEN_ENRT_PREM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_PREM_BK3" AUTHID CURRENT_USER as
/* $Header: beeprapi.pkh 120.0 2005/05/28 02:43:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_prem_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_prem_b
  (
   p_enrt_prem_id                   in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_prem_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_prem_a
  (
   p_enrt_prem_id                   in  number
  ,p_object_version_number          in  number
  );
--
end ben_enrt_prem_bk3;

 

/
