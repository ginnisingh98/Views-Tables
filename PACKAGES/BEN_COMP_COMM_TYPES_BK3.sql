--------------------------------------------------------
--  DDL for Package BEN_COMP_COMM_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_COMM_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: becctapi.pkh 120.0 2005/05/28 00:58:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comp_comm_types_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_comm_types_b
  (p_cm_typ_id                   in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comp_comm_types_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_comm_types_a
  (p_cm_typ_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_comp_comm_types_bk3;

 

/
