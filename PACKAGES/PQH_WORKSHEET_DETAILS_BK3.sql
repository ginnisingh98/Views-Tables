--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_DETAILS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_DETAILS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwdtapi.pkh 120.1.12000000.1 2007/01/17 00:29:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_DETAIL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_DETAIL_b
  (
   p_worksheet_detail_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_DETAIL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_DETAIL_a
  (
   p_worksheet_detail_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
End pqh_WORKSHEET_DETAILS_bk3;

 

/
