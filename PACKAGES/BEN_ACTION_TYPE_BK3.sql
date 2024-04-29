--------------------------------------------------------
--  DDL for Package BEN_ACTION_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTION_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: beeatapi.pkh 120.0 2005/05/28 01:46:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ACTION_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTION_TYPE_b
  (
   p_actn_typ_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ACTION_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTION_TYPE_a
  (
   p_actn_typ_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ACTION_TYPE_bk3;

 

/
