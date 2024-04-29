--------------------------------------------------------
--  DDL for Package PQP_ANALYZED_ALIEN_DET_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ANALYZED_ALIEN_DET_BK3" AUTHID CURRENT_USER as
/* $Header: pqdetapi.pkh 120.0 2005/05/29 01:43:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_analyzed_alien_det_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_det_b
  (
   p_analyzed_data_details_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_analyzed_alien_det_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_det_a
  (
   p_analyzed_data_details_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqp_analyzed_alien_det_bk3;

 

/
