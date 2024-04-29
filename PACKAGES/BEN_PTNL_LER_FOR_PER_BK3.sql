--------------------------------------------------------
--  DDL for Package BEN_PTNL_LER_FOR_PER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTNL_LER_FOR_PER_BK3" AUTHID CURRENT_USER as
/* $Header: bepplapi.pkh 120.0 2005/05/28 10:58:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptnl_ler_for_per_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptnl_ler_for_per_b
  (p_ptnl_ler_for_per_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptnl_ler_for_per_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptnl_ler_for_per_a
  (p_ptnl_ler_for_per_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_ptnl_ler_for_per_bk3;

 

/
