--------------------------------------------------------
--  DDL for Package BEN_EXT_CHG_EVT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CHG_EVT_BK3" AUTHID CURRENT_USER as
/* $Header: bexclapi.pkh 120.1 2005/06/23 15:04:14 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CHG_EVT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CHG_EVT_b
  (
   p_ext_chg_evt_log_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_CHG_EVT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CHG_EVT_a
  (
   p_ext_chg_evt_log_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_CHG_EVT_bk3;

 

/
