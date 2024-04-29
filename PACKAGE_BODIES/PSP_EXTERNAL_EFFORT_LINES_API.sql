--------------------------------------------------------
--  DDL for Package Body PSP_EXTERNAL_EFFORT_LINES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EXTERNAL_EFFORT_LINES_API" as
/* $Header: PSPEEAIB.pls 120.2 2006/02/28 05:27:39 dpaudel noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := '  psp_external_effort_lines_api.';
  p_legislation_code  varchar(50):=hr_api.userenv_lang;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_external_effort_line >--------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_external_effort_line
( p_validate                     in             boolean  default false
, p_batch_name                   in             varchar2
, p_distribution_date            in             date
, p_person_id                    in             number
, p_assignment_id                in             number
, p_currency_code                in             varchar2
, p_distribution_amount          in             number
, p_business_group_id            in             number
, p_set_of_books_id              in             number
, p_gl_code_combination_id       in             number   default null
, p_project_id                   in             number	 default null
, p_task_id                      in             number	 default null
, p_award_id                     in             number	 default null
, p_expenditure_organization_id  in             number	 default null
, p_expenditure_type             in             varchar2 default null
, p_attribute_category           in             varchar2 default null
, p_attribute1                   in             varchar2 default null
, p_attribute2                   in             varchar2 default null
, p_attribute3                   in             varchar2 default null
, p_attribute4                   in             varchar2 default null
, p_attribute5                   in             varchar2 default null
, p_attribute6                   in             varchar2 default null
, p_attribute7                   in             varchar2 default null
, p_attribute8                   in             varchar2 default null
, p_attribute9                   in             varchar2 default null
, p_attribute10                  in             varchar2 default null
, p_attribute11                  in             varchar2 default null
, p_attribute12                  in             varchar2 default null
, p_attribute13                  in             varchar2 default null
, p_attribute14                  in             varchar2 default null
, p_attribute15                  in             varchar2 default null
, p_object_version_number        in out nocopy  number
, p_external_effort_line_id         out nocopy  number
, p_return_status                   out	nocopy  boolean
)
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'insert_external_effort_line';
  l_object_version_number  number(9);
  l_external_effort_line_id number;
  l_return_status          boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint insert_external_effort_line;

  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    psp_external_effort_lines_bk1.insert_external_effort_line_b
		( p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_external_effort_line'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	psp_pee_ins.ins
		( p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		, p_object_version_number        =>   l_object_version_number
		, p_external_effort_line_id      =>   l_external_effort_line_id
		);

  --
  -- Call After Process User Hook
  --
  begin
     psp_external_effort_lines_bk1.insert_external_effort_line_a
		( p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		, p_object_version_number        =>   l_object_version_number
		, p_external_effort_line_id      =>   l_external_effort_line_id
		, p_return_status                =>   l_return_status
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_external_effort_line'
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
  p_object_version_number := l_object_version_number;
  p_external_effort_line_id   := l_external_effort_line_id;
  p_return_status         := l_return_status;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to insert_external_effort_line;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_external_effort_line_id   := null;
    p_return_status         := l_return_status;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to insert_external_effort_line;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := null;
    p_external_effort_line_id   := null;
    p_return_status         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end insert_external_effort_line;








--
-- ----------------------------------------------------------------------------
-- |----------------------< update_external_effort_line >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_external_effort_line
( p_validate                     in             boolean  default false
, p_external_effort_line_id      in             number
, p_batch_name                   in             varchar2 default hr_api.g_varchar2
, p_distribution_date            in             date     default hr_api.g_date
, p_person_id                    in             number   default hr_api.g_number
, p_assignment_id                in             number   default hr_api.g_number
, p_currency_code                in             varchar2 default hr_api.g_varchar2
, p_distribution_amount          in             number   default hr_api.g_number
, p_business_group_id            in             number   default hr_api.g_number
, p_set_of_books_id              in             number   default hr_api.g_number
, p_gl_code_combination_id       in             number   default hr_api.g_number
, p_project_id                   in             number   default hr_api.g_number
, p_task_id                      in             number   default hr_api.g_number
, p_award_id                     in             number   default hr_api.g_number
, p_expenditure_organization_id  in             number   default hr_api.g_number
, p_expenditure_type             in             varchar2 default hr_api.g_varchar2
, p_attribute_category           in             varchar2 default hr_api.g_varchar2
, p_attribute1                   in             varchar2 default hr_api.g_varchar2
, p_attribute2                   in             varchar2 default hr_api.g_varchar2
, p_attribute3                   in             varchar2 default hr_api.g_varchar2
, p_attribute4                   in             varchar2 default hr_api.g_varchar2
, p_attribute5                   in             varchar2 default hr_api.g_varchar2
, p_attribute6                   in             varchar2 default hr_api.g_varchar2
, p_attribute7                   in             varchar2 default hr_api.g_varchar2
, p_attribute8                   in             varchar2 default hr_api.g_varchar2
, p_attribute9                   in             varchar2 default hr_api.g_varchar2
, p_attribute10                  in             varchar2 default hr_api.g_varchar2
, p_attribute11                  in             varchar2 default hr_api.g_varchar2
, p_attribute12                  in             varchar2 default hr_api.g_varchar2
, p_attribute13                  in             varchar2 default hr_api.g_varchar2
, p_attribute14                  in             varchar2 default hr_api.g_varchar2
, p_attribute15                  in             varchar2 default hr_api.g_varchar2
, p_object_version_number        in out nocopy  number
, p_return_status                   out	nocopy  boolean
) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_external_effort_line';
  l_object_version_number  number(9);
  l_return_status          boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_external_effort_line;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;

  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    psp_external_effort_lines_bk2.update_external_effort_line_b
		( p_external_effort_line_id      =>   p_external_effort_line_id
		, p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		, p_object_version_number        =>   l_object_version_number
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_external_effort_line'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   psp_pee_upd.upd
		( p_external_effort_line_id      =>   p_external_effort_line_id
		, p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		, p_object_version_number        =>   l_object_version_number
		);



  --
  -- Call After Process User Hook
  --
  begin
    psp_external_effort_lines_bk2.update_external_effort_line_a
		( p_external_effort_line_id      =>   p_external_effort_line_id
		, p_batch_name                   =>   p_batch_name
		, p_distribution_date            =>   p_distribution_date
		, p_person_id                    =>   p_person_id
		, p_assignment_id                =>   p_assignment_id
		, p_currency_code                =>   p_currency_code
		, p_distribution_amount          =>   p_distribution_amount
		, p_business_group_id            =>   p_business_group_id
		, p_set_of_books_id              =>   p_set_of_books_id
		, p_gl_code_combination_id       =>   p_gl_code_combination_id
		, p_project_id                   =>   p_project_id
		, p_task_id                      =>   p_task_id
		, p_award_id                     =>   p_award_id
		, p_expenditure_organization_id  =>   p_expenditure_organization_id
		, p_expenditure_type             =>   p_expenditure_type
		, p_attribute_category           =>   p_attribute_category
		, p_attribute1                   =>   p_attribute1
		, p_attribute2                   =>   p_attribute2
		, p_attribute3                   =>   p_attribute3
		, p_attribute4                   =>   p_attribute4
		, p_attribute5                   =>   p_attribute5
		, p_attribute6                   =>   p_attribute6
		, p_attribute7                   =>   p_attribute7
		, p_attribute8                   =>   p_attribute8
		, p_attribute9                   =>   p_attribute9
		, p_attribute10                  =>   p_attribute10
		, p_attribute11                  =>   p_attribute11
		, p_attribute12                  =>   p_attribute12
		, p_attribute13                  =>   p_attribute13
		, p_attribute14                  =>   p_attribute14
		, p_attribute15                  =>   p_attribute15
		, p_object_version_number        =>   l_object_version_number
		, p_return_status                =>   l_return_status
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_external_effort_line'
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
  p_return_status          := l_return_status;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_external_effort_line;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_return_status          := l_return_status;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_external_effort_line;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_return_status          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_external_effort_line;




--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_external_effort_line >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_external_effort_line
( p_validate                     in             boolean  default false
, p_external_effort_line_id      in             number
, p_object_version_number        in out nocopy  number
)
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_effort_interface_line';
  l_object_version_number  number(9);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_external_effort_line;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
    psp_external_effort_lines_bk3.delete_external_effort_line_b
    ( p_external_effort_line_id	=>	p_external_effort_line_id
    , p_object_version_number   =>   l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_external_effort_line'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  psp_pee_del.del
    ( p_external_effort_line_id	=>   p_external_effort_line_id
    , p_object_version_number   =>   l_object_version_number
    );


  --
  -- Call After Process User Hook
  --
  begin
     psp_external_effort_lines_bk3.delete_external_effort_line_a
    ( p_external_effort_line_id	=>   p_external_effort_line_id
    , p_object_version_number   =>   l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_external_effort_line'
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
    rollback to delete_external_effort_line;
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
    rollback to delete_external_effort_line;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_external_effort_line;

/*
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_external_effort_line_batch >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_external_effort_line_batch
( p_validate                     in             boolean  default false
, p_batch_name                   in             varchar2
, p_person_id                    in             number   default hr_api.g_number
, p_assignment_id                in             number   default hr_api.g_number
, p_return_status                   out	nocopy  boolean
)
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_external_effort_line_batch';
  l_return_status          boolean;
  l_external_effort_line_id number;
  l_object_version_number  number;

  CURSOR effort_interface_csr IS
  SELECT external_effort_line_id, object_version_number
  FROM   psp_external_effort_lines
  WHERE  batch_name = p_batch_name
  AND   (person_id = p_person_id OR p_person_id = hr_api.g_number)
  AND   (assignment_id=  p_assignment_id OR p_assignment_id = hr_api.g_number);


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_external_effort_line_batch;

  OPEN effort_interface_csr;
  LOOP
    FETCH effort_interface_csr into l_external_effort_line_id, l_object_version_number;
    EXIT WHEN effort_interface_csr%NOTFOUND;
    delete_effort_interface
      ( p_external_effort_line_id=>   l_external_effort_line_id
      , p_object_version_number  =>   l_object_version_number
      );

  END LOOP;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_external_effort_line_batch;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_external_effort_line_batch;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_return_status := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_external_effort_line_batch;
*/

end psp_external_effort_lines_api;

/
