--------------------------------------------------------
--  DDL for Package BEN_POPL_YR_PERD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_YR_PERD_BK3" AUTHID CURRENT_USER as
/* $Header: becpyapi.pkh 120.0 2005/05/28 01:18:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_YR_PERD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_YR_PERD_b
  (
   p_popl_yr_perd_id                in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_YR_PERD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_YR_PERD_a
  (
   p_popl_yr_perd_id                in  number
  ,p_object_version_number          in  number
  );
--
end ben_POPL_YR_PERD_bk3;

 

/
