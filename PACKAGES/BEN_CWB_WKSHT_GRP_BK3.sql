--------------------------------------------------------
--  DDL for Package BEN_CWB_WKSHT_GRP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WKSHT_GRP_BK3" AUTHID CURRENT_USER as
/* $Header: becwgapi.pkh 120.0 2005/05/28 01:29:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cwb_wksht_grp_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_wksht_grp_b
  (
   p_cwb_wksht_grp_id                in number
  ,p_object_version_number           in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cwb_wksht_grp_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_wksht_grp_a
  (
   p_cwb_wksht_grp_id                in number
  ,p_object_version_number           in number
  );
--
end ben_cwb_wksht_grp_bk3;

 

/
