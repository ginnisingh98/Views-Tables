--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_GROUP_API" as
/* $Header: hxctkgapi.pkb 120.2 2005/09/23 09:38:52 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_timekeeper_group_api.';

g_debug boolean := hr_utility.debug_enabled;

-- ----------------------------------------------------------------------------
-- |--------------------------< create_timekeeper_group >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a timekeeper group with a given name
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new data_approval_rule
--                                                is created. Default is FALSE.
--   p_tk_group_id                  No   number   Primary Key for timekeeper group group
--   p_object_version_number        No   number   Object Version Number
--   p_tk_Group_name                Yes  varchar2 tk group Name for the timekeeper_group
--   p_tk_resource_id               Yes  number   Resource id for the person creating the
--                                                timekeeper group
--   p_business_group_id            Yes  number   Business Group ID
-- Post Success:
--
-- when the timekeeper_group has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_tk_group_id             Number   Primary Key for the new rule
--   p_object_version_number   Number   Object version number for the
--                                      new tk group
--
-- Post Failure:
--
-- The timekeeper group will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_timekeeper_group
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_name                  in     varchar2
  ,p_tk_resource_id                 in     number
  ,p_business_group_id              in     number
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number     hxc_tk_groups.object_version_number%TYPE;
	l_tk_group_id  hxc_tk_groups.tk_group_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  --
  if g_debug then
  	l_proc := g_package||' create_timekeeper_group';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_timekeeper_group;
  --
  hxc_timekeeper_group_api.chk_name
	(    p_tk_group_name	=> p_tk_group_name
	,    p_tk_group_id	=> p_tk_group_id
        ,    p_tk_resource_id      => p_tk_resource_id
        ,   p_business_group_id  =>p_business_group_id
        );

  hxc_timekeeper_group_api.chk_tk_resource_id ( p_tk_resource_id => p_tk_resource_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_timekeeper_group_BK_1.create_timekeeper_group_b
	  (p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_tk_group_name          => p_tk_group_name
          ,p_tk_resource_id            => p_tk_resource_id
          ,p_business_group_id      => p_business_group_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_timekeeper_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
--
-- call row handler
--
hxc_tkg_ins.ins (
   p_tk_group_name	=> p_tk_group_name
  ,p_tk_group_id 	=> l_tk_group_id
  ,p_tk_resource_id        => p_tk_resource_id
  ,p_object_version_number => l_object_version_number
  ,p_business_group_id      => p_business_group_id);
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_timekeeper_group_BK_1.create_timekeeper_group_a
	  (p_tk_group_id            => l_tk_group_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_tk_group_name          => p_tk_group_name
          ,p_tk_resource_id            => p_tk_resource_id
          ,p_business_group_id      => p_business_group_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_timekeeper_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
  -- Set all output arguments
  --
  p_tk_group_id           := l_tk_group_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_timekeeper_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tk_group_id            := null;
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO create_timekeeper_group;
    raise;
    --
END create_timekeeper_group;



-- ----------------------------------------------------------------------------
-- |-------------------------<update_timekeeper_group>------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Timekeeper_Group with a given name
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the data_approval_rule
--                                                is updated. Default is FALSE.
--   p_tk_group_id                  Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_tk_group_name                Yes  varchar2 tk group Name for the timekeeper group
--   p_tk_resource_id                  Yes  number   resource id for the person
--   p_business_group_id            Yes  number    business group id
-- Post Success:
--
-- when the timekeeper group has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The timekeeper_group will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_timekeeper_group
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_name                  in     varchar2
  ,p_tk_resource_id                    in number
  ,p_business_group_id              in  number)
IS
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_tk_groups.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_timekeeper_group';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_timekeeper_group;
  --
  hxc_timekeeper_group_api.chk_name
	(    p_tk_group_name	=> p_tk_group_name
	,    p_tk_group_id	=> p_tk_group_id
        ,    p_tk_resource_id      => p_tk_resource_id
        ,    p_business_group_id  => p_business_group_id
        );

  hxc_timekeeper_group_api.chk_tk_resource_id ( p_tk_resource_id => p_tk_resource_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_timekeeper_group_BK_2.update_timekeeper_group_b
	  (p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_tk_group_name          => p_tk_group_name
          ,p_tk_resource_id            => p_tk_resource_id
          ,p_business_group_id     => p_business_group_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_timekeeper_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
--
-- call row handler
--
hxc_tkg_upd.upd (
   p_tk_group_name         => p_tk_group_name
  ,p_tk_group_id           => p_tk_group_id
  ,p_tk_resource_id           => p_tk_resource_id
  ,p_object_version_number => l_object_version_number
  ,p_business_group_id     => p_business_group_id
  );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_timekeeper_group_BK_2.update_timekeeper_group_a
	  (p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_tk_group_name          => p_tk_group_name
          ,p_tk_resource_id            => p_tk_resource_id
          ,p_business_group_id      => p_business_group_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_timekeeper_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_timekeeper_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO update_timekeeper_group;
    raise;

end update_timekeeper_group;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_timekeeper_group >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Timekeeper_Group
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the timekeeper_group
--                                                is deleted. Default is FALSE.
--   p_timekeeper_group_id          Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the timekeeper group has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The timekeeper_group will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_timekeeper_group
  (p_validate                       in  boolean  default false
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  if g_debug then
  	l_proc := g_package||'delete_timekeeper_group';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_timekeeper_group;
  --
	hxc_timekeeper_group_api.chk_delete (
				 p_tk_group_id => p_tk_group_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_timekeeper_group_BK_3.delete_timekeeper_group_b
	  (p_tk_group_id           => p_tk_group_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_timekeeper_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
  hxc_tkg_del.del
    (
     p_tk_group_id           => p_tk_group_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  --
  hxc_timekeeper_group_BK_3.delete_timekeeper_group_a
	  (p_tk_group_id           => p_tk_group_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_timekeeper_group'
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
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_timekeeper_group;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_timekeeper_group;
    raise;
    --
end delete_timekeeper_group;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- Note:
--      This procedure is called from the client
--
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_tk_group_name   in varchar2
  ,p_tk_group_id     in number
  ,p_tk_resource_id     in number
  ,p_business_group_id in number
  ) IS

  l_proc  varchar2(72);
--
-- cursor to check name is unique
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_tk_groups teg
	WHERE	teg.tk_group_name	= p_tk_group_name
        AND     teg.tk_resource_id         = p_tk_resource_id
        AND
	( teg.tk_group_id <> p_tk_group_id OR
	  p_tk_group_id IS NULL )
	AND teg.business_group_id = p_business_group_id
	  );
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_name';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the name has been entered
--
IF ( p_tk_group_name IS NULL )
THEN
--
      hr_utility.set_message(809, 'HXC_TEG_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_dup_name;
  CLOSE csr_chk_name;
--
IF ( l_dup_name IS NOT NULL )
THEN
--
      hr_utility.set_message(809, 'HXC_TEG_NAME_DUP');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tk_resource_id>---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--              SEE DESCRIPTION IN HEADER
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_resource_id
  (
   p_tk_resource_id     in number
  ) IS

l_proc varchar2(72) := 'chk_tk_resource_id';
L_dummy varchar2(1) := NULL;

CURSOR csr_chk_tk_resource_id IS
SELECT 'x'
FROM   dual
WHERE EXISTS ( select 'x'
               FROM   per_people_f p
               WHERE  p.person_id = p_tk_resource_id );

BEGIN

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TK_RESOURCE_ID'
    ,p_argument_value     => p_tk_resource_id
    );

OPEN  csr_chk_tk_resource_id;
FETCH csr_chk_tk_resource_id INTO l_dummy;

IF csr_chk_tk_resource_id%NOTFOUND
THEN
      hr_utility.set_message(809, 'HXC_TEG_INVALID_TK_RESOURCE_ID');
      hr_utility.raise_error;
END IF;

CLOSE csr_chk_tk_resource_id;

END chk_tk_resource_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_tk_group_id in number
  ) IS
BEGIN
null;
END chk_delete;


-- ----------------------------------------------------------------------------
-- |-------------------------< get_employee >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
PROCEDURE get_employee ( p_employee_id     IN OUT NOCOPY NUMBER
                       , p_full_name       IN OUT NOCOPY VARCHAR2
                       , p_employee_number IN OUT NOCOPY varchar2
                       , p_override        IN OUT NOCOPY VARCHAR2 ) IS

l_proc varchar2(72);

l_user_person_id number(15) := NULL;
l_override varchar2(1) := NULL;

CURSOR csr_get_full_name ( p_person_id NUMBER ) IS
SELECT p.full_name
,      nvl(p.employee_number, p.npw_number) employee_number
FROM   per_people p
WHERE  p.person_id = p_person_id;



l_emp_rec csr_get_full_name%ROWTYPE;

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := 'get_user_profiles';
	hr_utility.set_location('Entering:'||l_proc, 10);
end if;

l_user_person_id := fnd_global.employee_id;

if g_debug then
	hr_utility.trace('gaz - person id is '||to_char(l_user_person_id));
end if;

IF ( l_user_person_id IS NULL OR l_user_person_id = -1 )
THEN
      hr_utility.set_message(809, 'HXC_TEG_NO_PERSON_FOR_USER');
      hr_utility.raise_error;
END IF;

l_override := fnd_profile.value('HXC_TIMEKEEPER_OVERRIDE');

IF ( l_override = 'N' )
THEN
	l_override := NULL;
END IF;

-- now get the full name

OPEN  csr_get_full_name ( l_user_person_id );
FETCH csr_get_full_name INTO l_emp_rec;
CLOSE csr_get_full_name;

p_employee_id     := l_user_person_id;
p_full_name       := l_emp_rec.full_name;
p_employee_number := l_emp_rec.employee_number;
p_override        := l_override;

END get_employee;



FUNCTION get_people ( p_populate_id NUMBER
	,             p_populate_type VARCHAR2
        ,             p_person_type VARCHAR2
	) RETURN t_people
IS

CURSOR  csr_get_asg_people IS
SELECT DISTINCT
       p.person_id
,      p.full_name
,      nvl(p.employee_number, p.npw_number) employee_number
,      SUBSTR(hxc_tk_grp_query_criteria_api.get_tc_period ( p.person_id ),1,80) tc_period_name
,      hr_person_type_usage_info.get_user_person_type(p.effective_start_date, p.person_id)  person_type
FROM
       per_people p
,      per_assignments asg
,      hr_assignment_set_amendments asa
,      hr_assignment_sets ass
,      per_person_types ppt				--added 2943706
,      per_person_type_usages pptu

WHERE ass.assignment_set_id  = p_populate_id
AND   asa.assignment_set_id = ass.assignment_set_id
AND   asa.include_or_exclude = 'I'
AND   asg.assignment_id = asa.assignment_id
AND   p.person_id = asg.person_id
AND   pptu.person_id = p.person_id
AND   ppt.person_type_id = pptu.person_type_id
AND   ppt.system_person_type in ('EMP','EMP_APL','CWK')
AND   ( p_person_type IS NULL OR  (p_person_type IS NOT NULL AND decode(ppt.SYSTEM_PERSON_TYPE,'EMP_APL','EMP',ppt.SYSTEM_PERSON_TYPE)=p_person_type));

CURSOR  csr_get_org_people IS
SELECT DISTINCT
       p.person_id
,      p.full_name
,      nvl(p.employee_number, p.npw_number) employee_number
,      SUBSTR(hxc_tk_grp_query_criteria_api.get_tc_period ( p.person_id ),1,80) tc_period_name
,      hr_person_type_usage_info.get_user_person_type(p.effective_start_date, p.person_id) person_type
FROM
       per_people p
,      per_assignments asg
,      per_person_types ppt				--added 2943706
,      per_person_type_usages pptu
WHERE asg.organization_id = p_populate_id
AND   p.person_id = asg.person_id
AND   pptu.person_id = p.person_id
AND   ppt.person_type_id = pptu.person_type_id
AND   ppt.system_person_type in ('EMP','EMP_APL','CWK')
AND   asg.assignment_type in ('A','E','C')
AND   ( p_person_type IS NULL OR  (p_person_type IS NOT NULL AND decode(ppt.SYSTEM_PERSON_TYPE,'EMP_APL','EMP',ppt.SYSTEM_PERSON_TYPE)=p_person_type));



l_people_rec r_people;
l_people_tab t_people;
l_index BINARY_INTEGER := 1;

l_proc varchar2(72);

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := 'get_people';
	hr_utility.set_location('Entering:'||l_proc, 10);
end if;

IF ( p_populate_type = 'ASG_SET' )
THEN

	if g_debug then
		hr_utility.set_location('Entering:'||l_proc, 20);
	end if;

	OPEN  csr_get_asg_people;
	FETCH csr_get_asg_people INTO l_people_rec;

	WHILE csr_get_asg_people%FOUND
	LOOP

		l_people_tab(l_index) := l_people_rec;

		l_index := l_index + 1;

		FETCH csr_get_asg_people INTO l_people_rec;

	END LOOP;

	CLOSE csr_get_asg_people;

	if g_debug then
		hr_utility.set_location('Entering:'||l_proc, 30);
	end if;

ELSE -- p_populate_type must be ORGANIZATION

	if g_debug then
		hr_utility.set_location('Entering:'||l_proc, 40);
	end if;

	OPEN  csr_get_org_people;
	FETCH csr_get_org_people INTO l_people_rec;


	WHILE csr_get_org_people%FOUND
	LOOP

		l_people_tab(l_index) := l_people_rec;

		l_index := l_index + 1;

		FETCH csr_get_org_people INTO l_people_rec;

	END LOOP;

	CLOSE csr_get_org_people;

	if g_debug then
		hr_utility.set_location('Entering:'||l_proc, 50);
	end if;

END IF; -- p_populate_type

if g_debug then
	hr_utility.set_location('Entering:'||l_proc, 60);
end if;

RETURN l_people_tab;

END get_people;
--
--
END hxc_timekeeper_group_api;

/
