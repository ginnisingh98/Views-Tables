--------------------------------------------------------
--  DDL for Package BEN_COURT_ORDERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COURT_ORDERS_BK3" AUTHID CURRENT_USER as
/* $Header: becrtapi.pkh 120.0 2005/05/28 01:22:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_court_orders_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_court_orders_b
  (
   p_crt_ordr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_court_orders_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_court_orders_a
  (
   p_crt_ordr_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_court_orders_bk3;

 

/
