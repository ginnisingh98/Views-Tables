--------------------------------------------------------
--  DDL for Package BEN_CRT_ORDERS_CVRD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_ORDERS_CVRD_BK3" AUTHID CURRENT_USER as
/* $Header: becrdapi.pkh 120.0 2005/05/28 01:21:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_crt_orders_cvrd_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_crt_orders_cvrd_b
  (
   p_crt_ordr_cvrd_per_id           in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_crt_orders_cvrd_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_crt_orders_cvrd_a
  (
   p_crt_ordr_cvrd_per_id           in  number
  ,p_object_version_number          in  number
  );
--
end ben_crt_orders_cvrd_bk3;

 

/
