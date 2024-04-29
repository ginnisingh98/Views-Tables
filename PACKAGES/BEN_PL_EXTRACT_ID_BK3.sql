--------------------------------------------------------
--  DDL for Package BEN_PL_EXTRACT_ID_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_EXTRACT_ID_BK3" AUTHID CURRENT_USER as
/* $Header: bepeiapi.pkh 120.0 2005/05/28 10:33:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_extract_id_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_extract_id_b
  (
   p_pl_extract_identifier_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pl_extract_id_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_extract_id_a
  (
   p_pl_extract_identifier_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_pl_extract_id_bk3;

 

/
