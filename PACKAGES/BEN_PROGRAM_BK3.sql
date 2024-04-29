--------------------------------------------------------
--  DDL for Package BEN_PROGRAM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROGRAM_BK3" AUTHID CURRENT_USER as
/* $Header: bepgmapi.pkh 120.0 2005/05/28 10:46:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Program_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Program_b
  (
   p_pgm_id                         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Program_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Program_a
  (
   p_pgm_id                         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Program_bk3;

 

/
