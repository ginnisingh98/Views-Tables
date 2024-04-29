--------------------------------------------------------
--  DDL for Package BEN_COMM_DLVRY_MEDIA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMM_DLVRY_MEDIA_BK3" AUTHID CURRENT_USER as
/* $Header: becmdapi.pkh 120.0 2005/05/28 01:06:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Comm_Dlvry_Media_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Media_b
  (
   p_cm_dlvry_med_typ_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Comm_Dlvry_Media_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Media_a
  (
   p_cm_dlvry_med_typ_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Comm_Dlvry_Media_bk3;

 

/
