--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAP_OVERRIDES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAP_OVERRIDES_API" AUTHID CURRENT_USER AS
/* $Header: PSPSOAIS.pls 120.2 2006/07/06 13:27:59 tbalacha noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< create_salary_cap_override >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Creates salary cap override
--
-- Prerequisites:
-- Salary cap must exist for the defined date range
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate			    no  boolean   Identifier for validation of effort report line
--   p_funding_source_code    	    yes varchar2  Funding Source code identifier
--   p_project_id             	    yes number    Identifier for Projects
--   p_start_date             	    yes date      Identifier for the salary cap start date
--   p_end_date               	    yes date      Identifier for the salary cap end date
--   p_currency_code          	    yes varchar2  Currenct code identifier for the overide
--   p_annual_salary_cap      	    yes number    Identifier for annual cap
--   p_object_version_number  	    yes number    Object version number identifier
--
-- Post Success:
--  Salary cap override is created
--
--
-- Post Failure:
-- Salary cap override is not created and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

procedure create_salary_cap_override
  (p_validate                     in     boolean  default false
  , p_funding_source_code    	in	varchar2
  , p_project_id             	in	number
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_object_version_number  	in	out	nocopy  number
  , p_salary_cap_override_id	out     nocopy	number
  , p_return_status           out	nocopy  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_salary_cap_override >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Updates salary cap override
--
-- Prerequisites:
-- Salary cap must exist for the defined date range
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate			    no  boolean   Identifier for validation of effort report line
--   p_salary_cap_override_id	    yes	number    Identifier for salary cap override
--   p_funding_source_code    	    yes varchar2  Funding Source code identifier
--   p_project_id             	    yes number    Identifier for Projects
--   p_start_date             	    yes date      Identifier for the salary cap start date
--   p_end_date               	    yes date      Identifier for the salary cap end date
--   p_currency_code          	    yes varchar2  Currenct code identifier for the overide
--   p_annual_salary_cap      	    yes number    Identifier for annual cap
--   p_object_version_number  	    yes number    Object version number identifier
--
-- Post Success:
--  Salary cap override is updated
--
--
-- Post Failure:
-- Salary cap override is not updated and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_salary_cap_override
  (p_validate                     in     boolean  default false
  , p_salary_cap_override_id	in	number
  , p_funding_source_code    	in	varchar2
  , p_project_id             	in	number
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_object_version_number  	in	out	nocopy  number
  , p_return_status           out	nocopy  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_salary_cap_override >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Delete salary cap override
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate			    no  boolean   Identifier for validation of effort report line
--   p_salary_cap_override_id	    yes	number    Identifier for salary cap override
--   p_object_version_number  	    yes number    Object version number identifier
--
-- Post Success:
--  Salary cap override is deleted
--
-- Post Failure:
-- Salary cap override is not deleted and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_salary_cap_override
  (p_validate                     in  boolean  default false
	, p_salary_cap_override_id    	in	number
	, p_object_version_number      	in	out nocopy	number
  , p_return_status               out	nocopy  boolean
  );
end psp_salary_cap_overrides_api;

/
