--------------------------------------------------------
--  DDL for Package Body PER_SEC_PROFILE_ASG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEC_PROFILE_ASG_API" as
/* $Header: peaspapi.pkb 115.1 2003/09/16 01:13 vkonda noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_sec_profile_asg_api.';

PROCEDURE update_existing_assignment
   (p_sec_profile_assignment_id  IN  NUMBER
   ,p_object_version_number      IN  NUMBER
   ,p_start_date                 IN  DATE
   ,p_end_date                   IN  DATE
   )
IS
--
l_object_version_number  NUMBER;
--
BEGIN
   --
   l_object_version_number := p_object_version_number;
   --
   -- Call the api to update the previous assignment
   --
   per_asp_upd.upd
      (p_sec_profile_assignment_id  => p_sec_profile_assignment_id
      ,p_start_date => p_start_date
      ,p_end_date => p_end_date
      ,p_object_version_number => l_object_version_number
      );
END;

PROCEDURE insert_update
   (p_sec_profile_assignment_id    in number,
    p_user_id                      in number,
    p_security_group_id            in number,
    p_business_group_id            in number,
    p_security_profile_id          in number,
    p_responsibility_id            in number,
    p_responsibility_application_i in number,
    p_start_date                   in date,
    p_end_date                     in date default null,
    p_object_version_number        in number
   )
IS
--
l_security_group_id          NUMBER;
l_sec_profile_assignment_id  NUMBER;
l_object_version_number      NUMBER;
l_assignment_exists          BOOLEAN;
--
l_clashing_start_date        DATE;
l_clashing_end_date          DATE;
l_clashing_id                NUMBER;
l_clashing_ovn               NUMBER;
--
l_exception                  EXCEPTION;
l_response                   NUMBER;
l_check_complete             BOOLEAN := FALSE;
l_proc                       varchar2(72) := g_package|| 'insert_update';
--
BEGIN
   --
   -- Perform some checks on the date to be inserted/updated
   --
   --
   hr_utility.set_location('Entering ' || l_proc ,5);
   hr_utility.trace('Sec Prf Asg Id ' || p_sec_profile_assignment_id);
   hr_utility.trace('p_start_date ' || p_start_date);
   hr_utility.trace('p_end_date' || p_end_date);

	 l_security_group_id := p_security_group_id;
   --
   -- If we are inserting a record, or updating an entry on the form that
   -- has been bought back from the view but is not a record in
   -- per_sec_profile_assignments then make sure that the id and ovn are null.
   --
      l_sec_profile_assignment_id := p_sec_profile_assignment_id;
      l_object_version_number := p_object_version_number;

   --
   -- Ok - lets check if the assignment exists..
   --
   l_assignment_exists :=
      per_asp_bus.chk_assignment_exists
         (p_user_id => p_user_id
         ,p_responsibility_id => p_responsibility_id
         ,p_application_id => p_responsibility_application_i
         ,p_security_group_id => p_security_group_id
         );
   hr_utility.set_location('Entering ' || l_proc ,10);
--
-- Always do the duplicate assignment check even if we are updating
-- a record since it may overlap the assignment for a different
-- security profile!
--
      --
      -- Check that there are no other records for the same
      -- U/R/G combination but for a different security
      -- profile.
      --
      per_asp_bus.chk_duplicate_assignments
         (p_user_id => p_user_id
         ,p_responsibility_id => p_responsibility_id
         ,p_application_id => p_responsibility_application_i
         ,p_security_group_id => p_security_group_id
         ,p_business_group_id => p_business_group_id
         ,p_security_profile_id => p_security_profile_id
         ,p_start_date => p_start_date
         ,p_end_date => p_end_date
         );
   hr_utility.set_location('Entering ' || l_proc ,15);
   --
   -- So now lets check the dates for the assignment
   --
   per_asp_bus.chk_assignment_dates
      (p_user_id => p_user_id
      ,p_responsibility_id => p_responsibility_id
      ,p_application_id => p_responsibility_application_i
      ,p_security_group_id => p_security_group_id
      ,p_start_date => p_start_date
      ,p_end_date => p_end_date
      );
   hr_utility.set_location('Entering ' || l_proc ,20);
   --
   per_asp_bus.chk_invalid_dates
      (p_sec_profile_assignment_id => p_sec_profile_assignment_id
      ,p_user_id => p_user_id
      ,p_responsibility_id => p_responsibility_id
      ,p_application_id => p_responsibility_application_i
      ,p_security_group_id => p_security_group_id
      ,p_business_group_id => p_business_group_id
      ,p_security_profile_id => p_security_profile_id
      ,p_start_date => p_start_date
      ,p_end_date => p_end_date
      );
   hr_utility.set_location('Entering ' || l_proc ,25);
   --
   l_check_complete := FALSE;
   --
   l_sec_profile_assignment_id := p_sec_profile_assignment_id;
   WHILE NOT l_check_complete LOOP
      --
      l_clashing_id := NULL;
      l_clashing_ovn := NULL;
      l_clashing_start_date := NULL;
      l_clashing_end_date := NULL;
      --
         hr_utility.set_location('Entering ' || l_proc ,30);
      per_asp_bus.chk_overlapping_dates
         (p_sec_profile_assignment_id => l_sec_profile_assignment_id
         ,p_user_id => p_user_id
         ,p_responsibility_id => p_responsibility_id
         ,p_application_id => p_responsibility_application_i
         ,p_security_group_id => l_security_group_id
         ,p_business_group_id => p_business_group_id
         ,p_security_profile_id => p_security_profile_id
         ,p_start_date => p_start_date
         ,p_end_date => p_end_date
         ,p_clashing_id => l_clashing_id
         ,p_clashing_ovn => l_clashing_ovn
         ,p_clashing_start_date => l_clashing_start_date
         ,p_clashing_end_date => l_clashing_end_date
         );
	    hr_utility.set_location('Entering ' || l_proc ,35);
      IF l_clashing_id IS NOT NULL THEN
        --
         IF p_start_date >= l_clashing_start_date
            AND p_start_date <= NVL(l_clashing_end_date, hr_general.end_of_time)
         THEN
            --
            -- A previous record exists which has either not been end-dated, or has
            -- an end-date of more than the start date of this record.
            --
            -- Check if moving the end date of the earlier
            -- record would break the start/end date constraint
            --
            IF l_clashing_start_date >= p_start_date - 1 THEN
               hr_utility.set_message
                  (800
                  ,'PER_52549_ASP_START_DATE_ERR'
                  );
               hr_utility.raise_error;
            END IF;
            --
            -- Prompt the user if they want to change the end date of the earlier
            -- record.
            -- If no, then rollback all changes.. if yes then alter record and continue - we
            -- may want to do the check again
            --
	       hr_utility.set_location('Entering ' || l_proc ,40);
               update_existing_assignment
                  (p_sec_profile_assignment_id => l_clashing_id
                  ,p_object_version_number => l_clashing_ovn
                  ,p_start_date => l_clashing_start_date
                  ,p_end_date => p_start_date - 1
                  );
	         hr_utility.set_location('Entering ' || l_proc ,45);
         ELSIF NVL(p_end_date, hr_general.end_of_time) >= l_clashing_start_date
              AND NVL(p_end_date, hr_general.end_of_time) <= NVL(l_clashing_end_date, hr_general.end_of_time)
         THEN
            --
            -- A future record exists with a start date of less than the old date
            -- (The id of the record is in l_id
            --
            -- Check if moving the end date of the earlier
            -- record would break the start/end date constraint
            --
            IF p_end_date IS NULL
              OR p_end_date + 1 >= NVL(l_clashing_end_date, hr_general.end_of_time)
            THEN
               hr_utility.set_message
                  (800
                  ,'PER_52550_ASP_END_DATE_ERR'
                  );
               hr_utility.raise_error;
            END IF;
            --
            -- prompt the user if they want to alter the end date of the future record...
            -- If no, then rollback all changes.. if yes then alter record and continue - we
            -- may want to do the check again
            --
               -- Update the existing row, and then redo the
               -- validation check to make sure that the value
               -- is ok.
               --
	          hr_utility.set_location('Entering ' || l_proc ,50);
               update_existing_assignment
                  (p_sec_profile_assignment_id => l_clashing_id
                  ,p_object_version_number => l_clashing_ovn
                  ,p_start_date => p_end_date + 1
                  ,p_end_date => l_clashing_end_date
                  );
		    hr_utility.set_location('Entering ' || l_proc ,55);
         END IF;
      ELSE
         l_check_complete := TRUE;
      END IF;
   END LOOP;
   --
      hr_utility.set_location('Entering ' || l_proc ,60);
END insert_update;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_security_profile_asg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_security_profile_asg
  (p_validate                     in  boolean default false,
   p_sec_profile_assignment_id    out nocopy number,
   p_user_id                      in number,
   p_security_group_id            in number,
   p_business_group_id            in number,
   p_security_profile_id          in number,
   p_responsibility_id            in number,
   p_responsibility_application_i in number,
   p_start_date                   in date,
   p_end_date                     in date             default null,
   p_object_version_number        out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_sec_profile_assignment_id    number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'create_security_profile_asg';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_security_profile_asg;
/*  --
  -- Call Before Process User Hook
  --
  begin
    per_sec_profile_asg_BK_1.create_security_profile_asg_b
      (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
       p_user_id                      => p_user_id,
       p_security_group_id            => p_security_group_id,
       p_business_group_id            => p_business_group_id,
       p_security_profile_id          => p_security_profile_id,
       p_responsibility_id            => p_responsibility_id,
       p_responsibility_application_i => p_responsibility_application_i,
       p_start_date                   => p_start_date,
       p_end_date                     => p_end_date,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_profile_asg_b'
        ,p_hook_type   => 'BP'
        );
  end; */

  insert_update
   (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
    p_user_id                      => p_user_id,
    p_security_group_id            => p_security_group_id,
    p_business_group_id            => p_business_group_id,
    p_security_profile_id          => p_security_profile_id,
    p_responsibility_id            => p_responsibility_id,
    p_responsibility_application_i => p_responsibility_application_i,
    p_start_date                   => p_start_date,
    p_end_date                     => p_end_date,
    p_object_version_number        => p_object_version_number
   );
  --
  -- Process Logic
  --
   per_asp_ins.ins
     (p_sec_profile_assignment_id    => l_sec_profile_assignment_id,
      p_user_id                      => p_user_id,
      p_security_group_id            => p_security_group_id,
      p_business_group_id            => p_business_group_id,
      p_security_profile_id          => p_security_profile_id,
      p_responsibility_id            => p_responsibility_id,
      p_responsibility_application_i => p_responsibility_application_i,
      p_start_date                   => p_start_date,
      p_end_date                     => p_end_date,
      p_object_version_number        => l_object_version_number
      );


/*   --
  -- Call After Process User Hook
  --
  begin
    per_sec_profile_asg_BK_1.create_security_profile_asg_a
      (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
       p_user_id                      => p_user_id,
       p_security_group_id            => p_security_group_id,
       p_business_group_id            => p_business_group_id,
       p_security_profile_id          => p_security_profile_id,
       p_responsibility_id            => p_responsibility_id,
       p_responsibility_application_i => p_responsibility_application_i,
       p_start_date                   => p_start_date,
       p_end_date                     => p_end_date,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_profile_asg_a'
        ,p_hook_type   => 'AP'
        );
  end; */
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
  p_sec_profile_assignment_id := l_sec_profile_assignment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_security_profile_asg;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_sec_profile_assignment_id := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_security_profile_asg;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_sec_profile_assignment_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_security_profile_asg;

--
-- ----------------------------------------------------------------------------
-- |---------------------< update_security_profile_asg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_profile_asg
  (p_validate                     in  boolean default false,
   p_sec_profile_assignment_id    in number,
   p_user_id                      in number,
   p_security_group_id            in number,
   p_business_group_id            in number,
   p_security_profile_id          in number,
   p_responsibility_id            in number,
   p_responsibility_application_i in number,
   p_start_date                   in date,
   p_end_date                     in date,
   p_object_version_number        in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number := p_object_version_number;
  l_proc                varchar2(72) := g_package||'update_security_profile_asg';
begin
--hr_utility.trace_on(null,'KKK');
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_security_profile_asg;
/*  --
  -- Call Before Process User Hook
  --
  begin
    per_sec_profile_asg_BK_1.update_security_profile_asg_b
      (p_sec_profile_assignment_id    =>p_sec_profile_assignment_id,
       p_start_date                   => p_start_date,
       p_end_date                     => p_end_date,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_profile_asg_b'
        ,p_hook_type   => 'BP'
        );
  end;*/

 insert_update
   (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
    p_user_id                      => p_user_id,
    p_security_group_id            => p_security_group_id,
    p_business_group_id            => p_business_group_id,
    p_security_profile_id          => p_security_profile_id,
    p_responsibility_id            => p_responsibility_id,
    p_responsibility_application_i => p_responsibility_application_i,
    p_start_date                   => p_start_date,
    p_end_date                     => p_end_date,
    p_object_version_number        => p_object_version_number
   );

  --
  -- Process Logic
  --
   per_asp_upd.upd
     (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
      p_start_date                   => p_start_date,
      p_end_date                     => p_end_date,
      p_object_version_number        => l_object_version_number
      );
/*   --
  -- Call After Process User Hook
  --
  begin
    per_sec_profile_asg_BK_1.update_security_profile_asg_a
      (p_sec_profile_assignment_id    => p_sec_profile_assignment_id,
       p_start_date                   => p_start_date,
       p_end_date                     => p_end_date,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_profile_asg_a'
        ,p_hook_type   => 'AP'
        );
  end; */
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
    rollback to update_security_profile_asg;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_security_profile_asg;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_security_profile_asg;
--
end per_sec_profile_asg_api;

/
