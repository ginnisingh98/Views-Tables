--------------------------------------------------------
--  DDL for Package BEN_EXT_DEFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DEFN_BK3" AUTHID CURRENT_USER as
/* $Header: bexdfapi.pkh 120.2 2006/06/06 21:50:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_DEFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DEFN_b
  (
   p_ext_dfn_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_DEFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DEFN_a
  (
   p_ext_dfn_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_DEFN_bk3;

 

/
