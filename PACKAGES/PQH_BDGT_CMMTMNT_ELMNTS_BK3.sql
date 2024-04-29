--------------------------------------------------------
--  DDL for Package PQH_BDGT_CMMTMNT_ELMNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_CMMTMNT_ELMNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbceapi.pkh 120.1 2005/10/02 02:25:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bdgt_cmmtmnt_elmnt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bdgt_cmmtmnt_elmnt_b
  (
   p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bdgt_cmmtmnt_elmnt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bdgt_cmmtmnt_elmnt_a
  (
   p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_bdgt_cmmtmnt_elmnts_bk3;

 

/
