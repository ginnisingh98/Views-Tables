--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_BK3" AUTHID CURRENT_USER as
/* $Header: beegdapi.pkh 120.3.12010000.3 2009/04/10 04:29:26 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_b
  (
   p_elig_dpnt_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_a
  (
   p_elig_dpnt_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );

 --
end ben_ELIG_DPNT_bk3;

/
