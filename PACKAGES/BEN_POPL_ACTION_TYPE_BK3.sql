--------------------------------------------------------
--  DDL for Package BEN_POPL_ACTION_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_ACTION_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: bepatapi.pkh 120.1 2007/03/29 07:06:31 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_ACTION_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ACTION_TYPE_b
  (
   p_popl_actn_typ_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_ACTION_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ACTION_TYPE_a
  (
   p_popl_actn_typ_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode              in varchar2
  );
--
end ben_POPL_ACTION_TYPE_bk3;

/
