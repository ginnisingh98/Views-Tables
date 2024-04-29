--------------------------------------------------------
--  DDL for Package BEN_COMM_DLVRY_MTHDS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMM_DLVRY_MTHDS_BK3" AUTHID CURRENT_USER as
/* $Header: becmtapi.pkh 120.0 2005/05/28 01:07:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Comm_Dlvry_Mthds_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Mthds_b
  (
   p_cm_dlvry_mthd_typ_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Comm_Dlvry_Mthds_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Mthds_a
  (
   p_cm_dlvry_mthd_typ_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Comm_Dlvry_Mthds_bk3;

 

/
