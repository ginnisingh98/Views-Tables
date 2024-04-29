--------------------------------------------------------
--  DDL for Package BEN_REGULATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REGULATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: beregapi.pkh 120.0 2005/05/28 11:36:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Regulations_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Regulations_b
  (
   p_regn_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Regulations_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Regulations_a
  (
   p_regn_id                        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Regulations_bk3;

 

/
