--------------------------------------------------------
--  DDL for Package HR_PERF_REVIEW_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_REVIEW_BK3" AUTHID CURRENT_USER as
/* $Header: peprvapi.pkh 120.1 2005/10/02 02:22:23 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_perf_review_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_perf_review_b
  (
   p_performance_review_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_perf_review_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_perf_review_a
  (
   p_performance_review_id          in  number
  ,p_object_version_number          in  number
  );
--
end hr_perf_review_bk3;

 

/
