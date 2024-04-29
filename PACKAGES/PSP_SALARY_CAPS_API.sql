--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAPS_API" AUTHID CURRENT_USER AS
/* $Header: PSPSCAIS.pls 120.2 2006/07/06 13:28:33 tbalacha noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< create_salary_cap >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Creates Salary cap for a funding source
--
-- Prerequisites:
-- Funding source must exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                 no  boolean       Identifier for validation of salary cap
--   p_funding_source_code    	yes varchar2      Identifier for funding source code
--   p_start_date             	yes date          Identifier for salary cap start date
--   p_end_date               	yes date          Identifier for salary cap end date
--   p_currency_code          	yes varchar2      Identifier for currency code for salary cap
--   p_annual_salary_cap      	yes number        Identifier for annual salary cap
--   p_seed_flag              	yes varchar2      Seed flag identifier for differentiation
--   p_object_version_number  	yes number        Identifier for object version number
--
-- Post Success:
-- Funding source is created
--
--
-- Post Failure:
-- Funding source is not created and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

procedure create_salary_cap
  ( p_validate                  in     boolean  default false
  , p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
  , p_object_version_number  	in out nocopy number
  , p_salary_cap_id          	out	nocopy  number
  , p_return_status             out	nocopy  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_salary_cap >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Update Salary cap for a funding source
--
-- Prerequisites:
-- Funding source must exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     no  boolean    Identifier for validation of salary cap
--   p_funding_source_code    	    yes varchar2   Identifier for funding source code
--   p_start_date             	    yes date	   Identifier for salary cap start date
--   p_end_date               	    yes date	   Identifier for salary cap end date
--   p_currency_code          	    yes varchar2   Identifier for currency code for salary cap
--   p_annual_salary_cap      	    yes number	   Identifier for annual salary cap
--   p_seed_flag              	    yes varchar2   Seed flag identifier for differentiation
--   p_object_version_number  	    yes number	   Identifier for object version number
--   p_salary_cap_id          	    yes number     Identifier for salary cap id for querying
--
-- Post Success:
-- Funding source is updated
--
--
-- Post Failure:
-- Funding source is not updated and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_salary_cap
  ( p_validate                  in     boolean  default false
  , p_salary_cap_id          	in	number
  , p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
  , p_object_version_number  	in out nocopy number
  , p_return_status             out	nocopy  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_salary_cap >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Delete Salary cap for a funding source
--
-- Prerequisites:
-- none
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     no  boolean    Identifier for validation of salary cap
--   p_object_version_number  	    yes number	   Identifier for object version number
--   p_salary_cap_id          	    yes number     Identifier for salary cap id for querying
--
-- Post Success:
-- Funding source is deleted
--
--
-- Post Failure:
-- Funding source is not deleted and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_salary_cap
  ( p_validate                  in     boolean  default false
  , p_salary_cap_id          	in	number
  , p_object_version_number  	in out nocopy number
  , p_return_status             out	nocopy  boolean
  );
end psp_salary_caps_api;

/
