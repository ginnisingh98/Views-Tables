--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_BDGT_ELMNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_BDGT_ELMNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwelapi.pkh 120.0 2005/05/29 02:58:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_BDGT_ELMNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_BDGT_ELMNT_b
  (
   p_worksheet_bdgt_elmnt_id        in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_BDGT_ELMNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_BDGT_ELMNT_a
  (
   p_worksheet_bdgt_elmnt_id        in  number
  ,p_object_version_number          in  number
  );
--
end pqh_WORKSHEET_BDGT_ELMNTS_bk3;

 

/
