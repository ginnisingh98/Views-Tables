--------------------------------------------------------
--  DDL for Package Body PER_CANCEL_APPLICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CANCEL_APPLICATION_API" as
/* $Header: pecapapi.pkb 115.2 2004/01/23 06:43:52 njaladi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'per_cancel_application_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< cancel_application >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_application
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_application_id                in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor date_received is
    select pa.date_received
    from   per_applications pa
    where  pa.person_id = p_person_id
    and    pa.application_id = p_application_id;
  --
  cursor get_person_type(p_received_date DATE) is
    select pt.system_person_type,
	   p.effective_start_date
    from   per_all_people_f p,
           per_person_types pt
    where  p.person_id      = p_person_id
    and    p.person_type_id = pt.person_type_id
    and    p_received_date between
           p.effective_start_date and p.effective_end_date ;
  --
  l_proc                VARCHAR2(72) := g_package||'cancel_application';
  l_system_person_type  per_person_types.system_person_type%TYPE;
  l_primary_date        DATE;
  l_date_received       DATE;
  l_cancel_type         VARCHAR2(10)  :=  'APL';
  l_where               VARCHAR2(10)  :=  'BEGIN';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint cancel_application;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Initialise local variables
  --
  open date_received;
  fetch date_received into l_date_received;
  if date_received%notfound then
    hr_utility.set_message(800,'PER_289080_APL_NON_EXIST');
    hr_utility.raise_error;
  end if;
  close date_received;
  --
  open get_person_type(l_date_received);
  fetch get_person_type into l_system_person_type, l_primary_date;
  close get_person_type;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    per_cancel_application_bk1.cancel_application_b
      (p_business_group_id             => p_business_group_id
      ,p_person_id                     => p_person_id
      ,p_application_id                => p_application_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_application'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- changed from l_system_person_type to 'APL' for fix of #3285486
  --
  per_cancel_hire_or_apl_pkg.pre_cancel_checks
    (
     p_person_id           =>  p_person_id
    ,p_where               =>  l_where
    ,p_business_group_id   =>  p_business_group_id
    ,p_system_person_type  =>  'APL' --l_system_person_type
    ,p_primary_id          =>  null
    ,p_primary_date        =>  l_primary_date
    ,p_cancel_type         =>  l_cancel_type
    );
  --
  -- Process Logic
  --
  per_cancel_hire_or_apl_pkg.do_cancel_appl
    (
     p_person_id           =>  p_person_id
    ,p_date_received       =>  l_date_received
    ,p_end_of_time         =>  hr_api.g_eot
    ,p_business_group_id   =>  p_business_group_id
    ,p_application_id      =>  p_application_id
    );

  --
  -- Call After Process User Hook
  --
  begin
    per_cancel_application_bk1.cancel_application_a
      (p_business_group_id             => p_business_group_id
      ,p_person_id                     => p_person_id
      ,p_application_id                => p_application_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_application'
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
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to cancel_application;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to cancel_application;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end cancel_application;
--
end per_cancel_application_api;

/
