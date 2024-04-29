--------------------------------------------------------
--  DDL for Package BEN_REGULATIONS_BODY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REGULATIONS_BODY_BK3" AUTHID CURRENT_USER as
/* $Header: berrbapi.pkh 120.0 2005/05/28 11:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_regulations_body_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulations_body_b
  (
   p_regn_for_regy_body_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_regulations_body_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulations_body_a
  (
   p_regn_for_regy_body_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_regulations_body_bk3;

 

/
