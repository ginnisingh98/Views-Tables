--------------------------------------------------------
--  DDL for Package GHR_NOAC_LAS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_LAS_BK3" AUTHID CURRENT_USER as
/* $Header: ghnlaapi.pkh 120.2 2005/10/02 01:57:53 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_noac_las_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_noac_las_b
  (
   p_noac_la_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_noac_las_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_noac_las_a
  (
   p_noac_la_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ghr_noac_las_bk3;

 

/
