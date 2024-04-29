--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_FUND_SRCS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_FUND_SRCS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwfsapi.pkh 120.0 2005/05/29 02:59:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_FUND_SRC_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_FUND_SRC_b
  (
   p_worksheet_fund_src_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_FUND_SRC_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_FUND_SRC_a
  (
   p_worksheet_fund_src_id          in  number
  ,p_object_version_number          in  number
  );
--
end pqh_WORKSHEET_FUND_SRCS_bk3;

 

/
