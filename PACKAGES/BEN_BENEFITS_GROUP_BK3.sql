--------------------------------------------------------
--  DDL for Package BEN_BENEFITS_GROUP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFITS_GROUP_BK3" AUTHID CURRENT_USER as
/* $Header: bebngapi.pkh 120.0 2005/05/28 00:45:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefits_Group_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefits_Group_b
  (
   p_benfts_grp_id                  in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefits_Group_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefits_Group_a
  (
   p_benfts_grp_id                  in  number
  ,p_object_version_number          in  number
  );
--
end ben_Benefits_Group_bk3;

 

/
