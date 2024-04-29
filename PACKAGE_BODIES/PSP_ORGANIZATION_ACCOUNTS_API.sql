--------------------------------------------------------
--  DDL for Package Body PSP_ORGANIZATION_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ORGANIZATION_ACCOUNTS_API" as
/* $Header: PSPOAAIB.pls 120.0 2005/11/20 23:57:11 dpaudel noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '   psp_organization_accounts_api.';
  p_legislation_code  varchar(50):=hr_api.userenv_lang;

--
-- ----------------------------------------------------------------------------
-- |-------------------------- create_organization_account --------------------|
-- ----------------------------------------------------------------------------
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
	, p_object_version_number     	in	out nocopy	number
	, p_organization_account_id    	out	nocopy number
  , p_return_status               out	nocopy      boolean
  )
 IS
	--
	-- Declare cursors and local variables
	--
	l_object_version_number  number(9);
	l_proc                varchar2(72) := g_package||'create_organization_account';
	l_poeta_start_date		date;
	l_poeta_end_date		date;
	l_start_date_active		date;
	l_end_date_active		date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_organization_account;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_poeta_start_date := trunc(p_poeta_start_date);
  l_poeta_end_date := trunc(p_poeta_end_date);
  l_start_date_active := trunc(p_start_date_active);
  l_end_date_active := trunc(p_end_date_active);

  --
  -- Call Before Process User Hook
  --
  begin
    psp_organization_accounts_bk1.create_organization_account_b
		( p_gl_code_combination_id     		=>		 p_gl_code_combination_id
		, p_project_id                 		=>		 p_project_id
		, p_expenditure_organization_id		=>		 p_expenditure_organization_id
		, p_expenditure_type           		=>		 p_expenditure_type
		, p_task_id                    		=>		 p_task_id
		, p_award_id                   		=>		 p_award_id
		, p_comments                   		=>		 p_comments
		, p_attribute_category         		=>		 p_attribute_category
		, p_attribute1                 		=>		 p_attribute1
		, p_attribute2                 		=>		 p_attribute2
		, p_attribute3                 		=>		 p_attribute3
		, p_attribute4                 		=>		 p_attribute4
		, p_attribute5                 		=>		 p_attribute5
		, p_attribute6                 		=>		 p_attribute6
		, p_attribute7                 		=>		 p_attribute7
		, p_attribute8                 		=>		 p_attribute8
		, p_attribute9                 		=>		 p_attribute9
		, p_attribute10                		=>		 p_attribute10
		, p_attribute11                		=>		 p_attribute11
		, p_attribute12                		=>		 p_attribute12
		, p_attribute13                		=>		 p_attribute13
		, p_attribute14                		=>		 p_attribute14
		, p_attribute15                		=>		 p_attribute15
		, p_set_of_books_id            		=>		 p_set_of_books_id
		, p_account_type_code          		=>		 p_account_type_code
		, p_start_date_active          		=>		 l_start_date_active
		, p_business_group_id          		=>		 p_business_group_id
		, p_end_date_active            		=>		 l_end_date_active
		, p_organization_id            		=>		 p_organization_id
		, p_poeta_start_date           		=>		 l_poeta_start_date
		, p_poeta_end_date             		=>		 l_poeta_end_date
		, p_funding_source_code        		=>		 p_funding_source_code
	        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_organization_account'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	psp_poa_ins.ins
		( p_organization_account_id	 =>			p_organization_account_id
		, p_set_of_books_id              =>  			p_set_of_books_id
		, p_account_type_code            =>  			p_account_type_code
		, p_start_date_active            =>  			l_start_date_active
		, p_business_group_id            =>  			p_business_group_id
		, p_organization_id              =>  			p_organization_id
		, p_gl_code_combination_id       =>  			p_gl_code_combination_id
		, p_project_id                   =>  			p_project_id
		, p_expenditure_organization_id  =>  			p_expenditure_organization_id
		, p_expenditure_type             =>  			p_expenditure_type
		, p_task_id                      =>  			p_task_id
		, p_award_id                     =>  			p_award_id
		, p_comments                     =>  			p_comments
		, p_attribute_category           =>  			p_attribute_category
		, p_attribute1                   =>  			p_attribute1
		, p_attribute2                   =>  			p_attribute2
		, p_attribute3                   =>  			p_attribute3
		, p_attribute4                   =>  			p_attribute4
		, p_attribute5                   =>  			p_attribute5
		, p_attribute6                   =>  			p_attribute6
		, p_attribute7                   =>  			p_attribute7
		, p_attribute8                   =>  			p_attribute8
		, p_attribute9                   =>  			p_attribute9
		, p_attribute10                  =>  			p_attribute10
		, p_attribute11                  =>  			p_attribute11
		, p_attribute12                  =>  			p_attribute12
		, p_attribute13                  =>  			p_attribute13
		, p_attribute14                  =>  			p_attribute14
		, p_attribute15                  =>  			p_attribute15
		, p_end_date_active              =>  			l_end_date_active
		, p_poeta_start_date             =>  			l_poeta_start_date
		, p_poeta_end_date               =>  			l_poeta_end_date
		, p_object_version_number        =>  			p_object_version_number
		, p_funding_source_code 	 =>		        p_funding_source_code
		);

  --
  -- Call After Process User Hook
  --
  begin
     psp_organization_accounts_bk1.create_organization_account_a
		( p_organization_account_id    		=>		 p_organization_account_id
		, p_gl_code_combination_id     		=>		 p_gl_code_combination_id
		, p_project_id                 		=>		 p_project_id
		, p_expenditure_organization_id		=>		 p_expenditure_organization_id
		, p_expenditure_type           		=>		 p_expenditure_type
		, p_task_id                    		=>		 p_task_id
		, p_award_id                   		=>		 p_award_id
		, p_comments                   		=>		 p_comments
		, p_attribute_category         		=>		 p_attribute_category
		, p_attribute1                 		=>		 p_attribute1
		, p_attribute2                 		=>		 p_attribute2
		, p_attribute3                 		=>		 p_attribute3
		, p_attribute4                 		=>		 p_attribute4
		, p_attribute5                 		=>		 p_attribute5
		, p_attribute6                 		=>		 p_attribute6
		, p_attribute7                 		=>		 p_attribute7
		, p_attribute8                 		=>		 p_attribute8
		, p_attribute9                 		=>		 p_attribute9
		, p_attribute10                		=>		 p_attribute10
		, p_attribute11                		=>		 p_attribute11
		, p_attribute12                		=>		 p_attribute12
		, p_attribute13                		=>		 p_attribute13
		, p_attribute14                		=>		 p_attribute14
		, p_attribute15                		=>		 p_attribute15
		, p_set_of_books_id            		=>		 p_set_of_books_id
		, p_account_type_code          		=>		 p_account_type_code
		, p_start_date_active          		=>		 l_start_date_active
		, p_business_group_id          		=>		 p_business_group_id
		, p_end_date_active            		=>		 l_end_date_active
		, p_organization_id            		=>		 p_organization_id
		, p_poeta_start_date           		=>		 l_poeta_start_date
		, p_poeta_end_date             		=>		 l_poeta_end_date
		, p_funding_source_code 	        =>		 p_funding_source_code
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_organization_account'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;

	--
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_organization_account;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_organization_account;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_organization_account;








--
-- ----------------------------------------------------------------------------
-- |---------------------- update_organization_account ------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_organization_account
		( p_validate                     in     boolean  default false
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
) is
  --
  -- Declare cursors and local variables
  --
	l_object_version_number  number(9);
	l_proc                varchar2(72) := g_package||'update_organization_account';
	l_poeta_start_date		date;
	l_poeta_end_date			date;
	l_start_date_active		date;
	l_end_date_active		date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_organization_account;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_poeta_start_date:= trunc(p_poeta_start_date);
  l_poeta_end_date:= trunc(p_poeta_end_date);
  l_start_date_active := trunc(p_start_date_active);
  l_end_date_active := trunc(p_end_date_active);

  --
  -- Call Before Process User Hook
  --
  begin
    psp_organization_accounts_bk2.update_organization_account_b
		( p_organization_account_id    		=>		p_organization_account_id
		, p_gl_code_combination_id     		=>		 p_gl_code_combination_id
		, p_project_id                 		=>		 p_project_id
		, p_expenditure_organization_id		=>		 p_expenditure_organization_id
		, p_expenditure_type           		=>		 p_expenditure_type
		, p_task_id                    		=>		 p_task_id
		, p_award_id                   		=>		 p_award_id
		, p_comments                   		=>		 p_comments
		, p_attribute_category         		=>		 p_attribute_category
		, p_attribute1                 		=>		 p_attribute1
		, p_attribute2                 		=>		 p_attribute2
		, p_attribute3                 		=>		 p_attribute3
		, p_attribute4                 		=>		 p_attribute4
		, p_attribute5                 		=>		 p_attribute5
		, p_attribute6                 		=>		 p_attribute6
		, p_attribute7                 		=>		 p_attribute7
		, p_attribute8                 		=>		 p_attribute8
		, p_attribute9                 		=>		 p_attribute9
		, p_attribute10                		=>		 p_attribute10
		, p_attribute11                		=>		 p_attribute11
		, p_attribute12                		=>		 p_attribute12
		, p_attribute13                		=>		 p_attribute13
		, p_attribute14                		=>		 p_attribute14
		, p_attribute15                		=>		 p_attribute15
		, p_set_of_books_id            		=>		 p_set_of_books_id
		, p_account_type_code          		=>		 p_account_type_code
		, p_start_date_active          		=>		 l_start_date_active
		, p_business_group_id          		=>		 p_business_group_id
		, p_end_date_active            		=>		 l_end_date_active
		, p_organization_id            		=>		 p_organization_id
		, p_poeta_start_date           		=>		 l_poeta_start_date
		, p_poeta_end_date             		=>		 l_poeta_end_date
		, p_funding_source_code 	        =>	         p_funding_source_code
                );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_organization_account'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   psp_poa_upd.upd
		( p_organization_account_id	 =>			p_organization_account_id
		, p_set_of_books_id              =>  			p_set_of_books_id
		, p_account_type_code            =>  			p_account_type_code
		, p_start_date_active            =>  			l_start_date_active
		, p_business_group_id            =>  			p_business_group_id
		, p_organization_id              =>  			p_organization_id
		, p_gl_code_combination_id       =>  			p_gl_code_combination_id
		, p_project_id                   =>  			p_project_id
		, p_expenditure_organization_id  =>  			p_expenditure_organization_id
		, p_expenditure_type             =>  			p_expenditure_type
		, p_task_id                      =>  			p_task_id
		, p_award_id                     =>  			p_award_id
		, p_comments                     =>  			p_comments
		, p_attribute_category           =>  			p_attribute_category
		, p_attribute1                   =>  			p_attribute1
		, p_attribute2                   =>  			p_attribute2
		, p_attribute3                   =>  			p_attribute3
		, p_attribute4                   =>  			p_attribute4
		, p_attribute5                   =>  			p_attribute5
		, p_attribute6                   =>  			p_attribute6
		, p_attribute7                   =>  			p_attribute7
		, p_attribute8                   =>  			p_attribute8
		, p_attribute9                   =>  			p_attribute9
		, p_attribute10                  =>  			p_attribute10
		, p_attribute11                  =>  			p_attribute11
		, p_attribute12                  =>  			p_attribute12
		, p_attribute13                  =>  			p_attribute13
		, p_attribute14                  =>  			p_attribute14
		, p_attribute15                  =>  			p_attribute15
		, p_end_date_active              =>  			l_end_date_active
		, p_poeta_start_date             =>  			l_poeta_start_date
		, p_poeta_end_date               =>  			l_poeta_end_date
		, p_object_version_number        =>  			p_object_version_number
		, p_funding_source_code 	 =>		        p_funding_source_code
                );


  --
  -- Call After Process User Hook
  --
  begin
     psp_organization_accounts_bk2.update_organization_account_a
		( p_organization_account_id    		=>		p_organization_account_id
		, p_gl_code_combination_id     		=>		 p_gl_code_combination_id
		, p_project_id                 		=>		 p_project_id
		, p_expenditure_organization_id		=>		 p_expenditure_organization_id
		, p_expenditure_type           		=>		 p_expenditure_type
		, p_task_id                    		=>		 p_task_id
		, p_award_id                   		=>		 p_award_id
		, p_comments                   		=>		 p_comments
		, p_attribute_category         		=>		 p_attribute_category
		, p_attribute1                 		=>		 p_attribute1
		, p_attribute2                 		=>		 p_attribute2
		, p_attribute3                 		=>		 p_attribute3
		, p_attribute4                 		=>		 p_attribute4
		, p_attribute5                 		=>		 p_attribute5
		, p_attribute6                 		=>		 p_attribute6
		, p_attribute7                 		=>		 p_attribute7
		, p_attribute8                 		=>		 p_attribute8
		, p_attribute9                 		=>		 p_attribute9
		, p_attribute10                		=>		 p_attribute10
		, p_attribute11                		=>		 p_attribute11
		, p_attribute12                		=>		 p_attribute12
		, p_attribute13                		=>		 p_attribute13
		, p_attribute14                		=>		 p_attribute14
		, p_attribute15                		=>		 p_attribute15
		, p_set_of_books_id            		=>		 p_set_of_books_id
		, p_account_type_code          		=>		 p_account_type_code
		, p_start_date_active          		=>		 l_start_date_active
		, p_business_group_id          		=>		 p_business_group_id
		, p_end_date_active            		=>		 l_end_date_active
		, p_organization_id            		=>		 p_organization_id
		, p_poeta_start_date           		=>		 l_poeta_start_date
		, p_poeta_end_date             		=>		 l_poeta_end_date
	 	, p_funding_source_code 	 =>		        p_funding_source_code
	 	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_organization_account'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;

	hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_organization_account;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
		p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_organization_account;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_organization_account;





--
-- ----------------------------------------------------------------------------
-- |--------------------- delete_organization_account -------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_organization_account
  ( p_validate                     in     boolean  default false
  , p_organization_account_id    	in	number
  , p_object_version_number      	in	out nocopy	number
  , p_return_status               out	nocopy      boolean
  ) is
  --
  -- Declare cursors and local variables
  --
	l_object_version_number  number(9);
  l_proc                varchar2(72) := g_package||'delete_organization_account';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_organization_account;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
    psp_organization_accounts_bk3.delete_organization_account_b
    (  	 p_organization_account_id      	=>	p_organization_account_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_organization_account'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  psp_poa_del.del
	( p_organization_account_id   =>  p_organization_account_id
        , p_object_version_number     =>  p_object_version_number
        );


  --
  -- Call After Process User Hook
  --
  begin
     psp_organization_accounts_bk3.delete_organization_account_a
      (	 p_organization_account_id  =>	 p_organization_account_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_organization_account'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_organization_account;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_organization_account;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_organization_account;
--
end psp_organization_accounts_api;

/
