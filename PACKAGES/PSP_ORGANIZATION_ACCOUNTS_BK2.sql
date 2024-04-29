--------------------------------------------------------
--  DDL for Package PSP_ORGANIZATION_ACCOUNTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ORGANIZATION_ACCOUNTS_BK2" AUTHID CURRENT_USER AS
/* $Header: PSPOAAIS.pls 120.2 2006/07/06 13:26:34 tbalacha noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_organization_account_b >-----------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_organization_account_b
  ( p_organization_account_id    	in	number
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
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_organization_account_a >-------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_organization_account_a
  ( p_organization_account_id    	in	number
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
  );
END psp_organization_accounts_bk2;

/
