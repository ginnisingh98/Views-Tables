--------------------------------------------------------
--  DDL for Package BEN_REPORTING_GROUP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REPORTING_GROUP_BK3" AUTHID CURRENT_USER as
/* $Header: bebnrapi.pkh 120.0 2005/05/28 00:45:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Reporting_Group_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Reporting_Group_b
  (
   p_rptg_grp_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Reporting_Group_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Reporting_Group_a
  (
   p_rptg_grp_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Reporting_Group_bk3;

 

/
