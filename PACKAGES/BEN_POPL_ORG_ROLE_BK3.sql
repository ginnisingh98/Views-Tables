--------------------------------------------------------
--  DDL for Package BEN_POPL_ORG_ROLE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_ORG_ROLE_BK3" AUTHID CURRENT_USER as
/* $Header: becprapi.pkh 120.0 2005/05/28 01:17:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_ORG_ROLE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ORG_ROLE_b
  (
   p_popl_org_role_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_ORG_ROLE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ORG_ROLE_a
  (
   p_popl_org_role_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_POPL_ORG_ROLE_bk3;

 

/
