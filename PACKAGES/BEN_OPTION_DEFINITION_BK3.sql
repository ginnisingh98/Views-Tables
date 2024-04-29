--------------------------------------------------------
--  DDL for Package BEN_OPTION_DEFINITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_DEFINITION_BK3" AUTHID CURRENT_USER as
/* $Header: beoptapi.pkh 120.0 2005/05/28 09:56:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_option_definition_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_definition_b
  (
   p_opt_id                         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_option_definition_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_definition_a
  (
   p_opt_id                         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_option_definition_bk3;

 

/
