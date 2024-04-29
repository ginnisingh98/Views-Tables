--------------------------------------------------------
--  DDL for Package BEN_GOOD_SVC_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GOOD_SVC_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: begosapi.pkh 120.0 2005/05/28 03:08:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GOOD_SVC_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GOOD_SVC_TYPE_b
  (
   p_gd_or_svc_typ_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GOOD_SVC_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GOOD_SVC_TYPE_a
  (
   p_gd_or_svc_typ_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_GOOD_SVC_TYPE_bk3;

 

/
