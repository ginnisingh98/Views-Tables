--------------------------------------------------------
--  DDL for Package BEN_DESIGN_RQMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DESIGN_RQMT_BK3" AUTHID CURRENT_USER as
/* $Header: beddrapi.pkh 120.0 2005/05/28 01:35:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_design_rqmt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_design_rqmt_b
  (
   p_dsgn_rqmt_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_design_rqmt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_design_rqmt_a
  (
   p_dsgn_rqmt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_design_rqmt_bk3;

 

/
