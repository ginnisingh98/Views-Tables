--------------------------------------------------------
--  DDL for Package PER_SSM_API_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_API_BK4" AUTHID CURRENT_USER as
/* $Header: pessmapi.pkh 120.1 2005/10/02 02:24:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< mass_update_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_update_b
  (p_effective_date                in     date
  ,p_business_group_id		   in     number
  ,p_job_id                        in     number
  ,p_position_id                   in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< mass_update_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_update_a
  (p_effective_date                in     date
  ,p_business_group_id		   in     number
  ,p_job_id                        in     number
  ,p_position_id                   in     number
  );
--
end per_ssm_api_bk4;

 

/
