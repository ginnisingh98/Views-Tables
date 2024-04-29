--------------------------------------------------------
--  DDL for Package PER_SSM_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_API_BK3" AUTHID CURRENT_USER as
/* $Header: pessmapi.pkh 120.1 2005/10/02 02:24:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_mapping_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping_b
  (p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_mapping_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping_a
  (p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  );

--
end per_ssm_api_bk3;

 

/
