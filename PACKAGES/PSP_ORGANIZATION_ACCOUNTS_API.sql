--------------------------------------------------------
--  DDL for Package PSP_ORGANIZATION_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ORGANIZATION_ACCOUNTS_API" AUTHID CURRENT_USER AS
/* $Header: PSPOAAIS.pls 120.2 2006/07/06 13:26:34 tbalacha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_organization_account >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Creates an organization account
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No boolean    Identifier for validation of effort report line
--   p_gl_code_combination_id       Yes number    Gl code combiantion identifier
--   p_project_id                   Yes number    Identifier for Projects
--   p_expenditure_organization_id  Yes number	  Identifier for Project Task
--   p_expenditure_type             Yes varchar2  Identifier for award
--   p_task_id                      Yes number	  Identifier for Exp Org
--   p_award_id                     Yes number	  identifier for Expenditure type
--   p_comments                     Yes varchar2  Identifier for information text
--   p_attribute_category           Yes varchar2  Additional Information category
--   p_attribute1                   Yes varchar2  Identifier for Extra information column
--   p_attribute2                   Yes varchar2  Identifier for Extra information column
--   p_attribute3                   Yes varchar2  Identifier for Extra information column
--   p_attribute4                   Yes varchar2  Identifier for Extra information column
--   p_attribute5                   Yes varchar2  Identifier for Extra information column
--   p_attribute6                   Yes varchar2  Identifier for Extra information column
--   p_attribute7                   Yes varchar2  Identifier for Extra information column
--   p_attribute8                   Yes varchar2  Identifier for Extra information column
--   p_attribute9                   Yes varchar2  Identifier for Extra information column
--   p_attribute10                  Yes varchar2  Identifier for Extra information column
--   p_attribute11                  Yes varchar2  Identifier for Extra information column
--   p_attribute12                  Yes varchar2  Identifier for Extra information column
--   p_attribute13                  Yes varchar2  Identifier for Extra information column
--   p_attribute14                  Yes varchar2  Identifier for Extra information column
--   p_attribute15                  Yes varchar2  Identifier for Extra information column
--   p_set_of_books_id              Yes number	  Gl set of books identifier
--   p_account_type_code            Yes varchar2  Account type identifier
--   p_start_date_active            Yes date      Identifier for start date
--   p_business_group_id            Yes number    Identifier for business group
--   p_end_date_active              Yes date      Identifier for End date
--   p_organization_id              Yes number    Identifier for Organization
--   p_poeta_start_date             Yes date      Poeta Start date for the line
--   p_poeta_end_date               Yes date      Potea End date for the line
--   p_funding_source_code          Yes varchar2  Funding source code identifier
--   p_object_version_number        yes number    Objecct version number identifier
--
-- Post Success:
-- Organization account is created
--
--
-- Post Failure:
-- Organization account is not created and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

procedure create_organization_account
  (p_validate                     in     boolean  default false
	, p_gl_code_combination_id     	in	number
	, p_project_id                 	in	number
	, p_expenditure_organization_id	in	number
	, p_expenditure_type           	in	varchar2
	, p_task_id                    	in	number
	, p_award_id                   	in	number
	, p_comments                   	in	varchar2
	, p_attribute_category         	in	varchar2
	, p_attribute1                 	in	varchar2
	, p_attribute2                 	in	varchar2
	, p_attribute3                 	in	varchar2
	, p_attribute4                 	in	varchar2
	, p_attribute5                 	in	varchar2
	, p_attribute6                 	in	varchar2
	, p_attribute7                 	in	varchar2
	, p_attribute8                 	in	varchar2
	, p_attribute9                 	in	varchar2
	, p_attribute10                	in	varchar2
	, p_attribute11                	in	varchar2
	, p_attribute12                	in	varchar2
	, p_attribute13                	in	varchar2
	, p_attribute14                	in	varchar2
	, p_attribute15                	in	varchar2
	, p_set_of_books_id            	in	number
	, p_account_type_code          	in	varchar2
	, p_start_date_active          	in	date
	, p_business_group_id          	in	number
	, p_end_date_active            	in	date
	, p_organization_id            	in	number
	, p_poeta_start_date           	in	date
	, p_poeta_end_date             	in	date
	, p_funding_source_code         in      varchar2
	, p_object_version_number      	in	out nocopy	number
	, p_organization_account_id    	out	nocopy number
  , p_return_status               out	nocopy      boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_organization_account >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Updates an organization account
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No boolean    Identifier for validation of effort report line
--   p_organization_account_id      yes number    Organization identifier for which the update is done
--   p_gl_code_combination_id       Yes number    Gl code combiantion identifier
--   p_project_id                   Yes number    Identifier for Projects
--   p_expenditure_organization_id  Yes number	  Identifier for Project Task
--   p_expenditure_type             Yes varchar2  Identifier for award
--   p_task_id                      Yes number	  Identifier for Exp Org
--   p_award_id                     Yes number	  identifier for Expenditure type
--   p_comments                     Yes varchar2  Identifier for information text
--   p_attribute_category           Yes varchar2  Additional Information category
--   p_attribute1                   Yes varchar2  Identifier for Extra information column
--   p_attribute2                   Yes varchar2  Identifier for Extra information column
--   p_attribute3                   Yes varchar2  Identifier for Extra information column
--   p_attribute4                   Yes varchar2  Identifier for Extra information column
--   p_attribute5                   Yes varchar2  Identifier for Extra information column
--   p_attribute6                   Yes varchar2  Identifier for Extra information column
--   p_attribute7                   Yes varchar2  Identifier for Extra information column
--   p_attribute8                   Yes varchar2  Identifier for Extra information column
--   p_attribute9                   Yes varchar2  Identifier for Extra information column
--   p_attribute10                  Yes varchar2  Identifier for Extra information column
--   p_attribute11                  Yes varchar2  Identifier for Extra information column
--   p_attribute12                  Yes varchar2  Identifier for Extra information column
--   p_attribute13                  Yes varchar2  Identifier for Extra information column
--   p_attribute14                  Yes varchar2  Identifier for Extra information column
--   p_attribute15                  Yes varchar2  Identifier for Extra information column
--   p_set_of_books_id              Yes number	  Gl set of books identifier
--   p_account_type_code            Yes varchar2  Account type identifier
--   p_start_date_active            Yes date      Identifier for start date
--   p_business_group_id            Yes number    Identifier for business group
--   p_end_date_active              Yes date      Identifier for End date
--   p_organization_id              Yes number    Identifier for Organization
--   p_poeta_start_date             Yes date      Poeta Start date for the line
--   p_poeta_end_date               Yes date      Potea End date for the line
--   p_funding_source_code          Yes varchar2  Funding source code identifier
--   p_object_version_number        yes number    Object version number identifier

--
-- Post Success:
-- Organization account is updated
--
--
-- Post Failure:
-- Organization account is not updated and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_organization_account
  (p_validate                     in     boolean  default false
	, p_organization_account_id    	in	number
	, p_gl_code_combination_id     	in	number
	, p_project_id                 	in	number
	, p_expenditure_organization_id	in	number
	, p_expenditure_type           	in	varchar2
	, p_task_id                    	in	number
	, p_award_id                   	in	number
	, p_comments                   	in	varchar2
	, p_attribute_category         	in	varchar2
	, p_attribute1                 	in	varchar2
	, p_attribute2                 	in	varchar2
	, p_attribute3                 	in	varchar2
	, p_attribute4                 	in	varchar2
	, p_attribute5                 	in	varchar2
	, p_attribute6                 	in	varchar2
	, p_attribute7                 	in	varchar2
	, p_attribute8                 	in	varchar2
	, p_attribute9                 	in	varchar2
	, p_attribute10                	in	varchar2
	, p_attribute11                	in	varchar2
	, p_attribute12                	in	varchar2
	, p_attribute13                	in	varchar2
	, p_attribute14                	in	varchar2
	, p_attribute15                	in	varchar2
	, p_set_of_books_id            	in	number
	, p_account_type_code          	in	varchar2
	, p_start_date_active          	in	date
	, p_business_group_id          	in	number
	, p_end_date_active            	in	date
	, p_organization_id            	in	number
	, p_poeta_start_date           	in	date
	, p_poeta_end_date             	in	date
	, p_funding_source_code         in      varchar2
	, p_object_version_number      	in	out nocopy	number
  , p_return_status               out	nocopy      boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_organization_account >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Deletes an organization account
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     no   boolean    Identifier for validation of effort report line
--   p_organization_account_id      yes  number     Identifier for organization account id
--   p_object_version_number        yes  number     Objecct version number identifier
--
-- Post Success:
-- Organization account is deleted
--
--
-- Post Failure:
-- Organization account is not deleted and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_organization_account
  (p_validate                     in     boolean  default false
	, p_organization_account_id    	in	number
	, p_object_version_number      	in	out nocopy	number
  , p_return_status                     out	nocopy      boolean
  );
end psp_organization_accounts_api;

/
