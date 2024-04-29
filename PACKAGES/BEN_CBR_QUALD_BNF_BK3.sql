--------------------------------------------------------
--  DDL for Package BEN_CBR_QUALD_BNF_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_QUALD_BNF_BK3" AUTHID CURRENT_USER as
/* $Header: becqbapi.pkh 120.0 2005/05/28 01:19:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CBR_QUALD_BNF_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_QUALD_BNF_b
  (
   p_cbr_quald_bnf_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CBR_QUALD_BNF_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_QUALD_BNF_a
  (
   p_cbr_quald_bnf_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_CBR_QUALD_BNF_bk3;

 

/
