--------------------------------------------------------
--  DDL for Package PQH_DFLT_FUND_SRCS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_FUND_SRCS_BK3" AUTHID CURRENT_USER as
/* $Header: pqdfsapi.pkh 120.1 2005/10/02 02:26:43 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_fund_src_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_fund_src_b
  (
   p_dflt_fund_src_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_fund_src_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_fund_src_a
  (
   p_dflt_fund_src_id               in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_fund_srcs_bk3;

 

/
