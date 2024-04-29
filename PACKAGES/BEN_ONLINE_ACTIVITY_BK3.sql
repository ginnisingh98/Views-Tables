--------------------------------------------------------
--  DDL for Package BEN_ONLINE_ACTIVITY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ONLINE_ACTIVITY_BK3" AUTHID CURRENT_USER as
/* $Header: beolaapi.pkh 120.0 2005/05/28 09:50:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_online_activity_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_online_activity_b
  (
   p_csr_activities_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_online_activity_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_online_activity_a
  (
   p_csr_activities_id              in  number
  ,p_object_version_number          in  number
  );
--
end ben_online_activity_bk3;

 

/
