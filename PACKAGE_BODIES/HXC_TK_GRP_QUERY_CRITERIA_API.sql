--------------------------------------------------------
--  DDL for Package Body HXC_TK_GRP_QUERY_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TK_GRP_QUERY_CRITERIA_API" as
/* $Header: hxctkgqcapi.pkb 120.2 2005/09/23 09:27:04 rchennur noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_tk_grp_query_criteria_api.';

g_debug boolean := hr_utility.debug_enabled;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_tk_grp_query_criteria >----------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--             SEE DESCRIPTION IN HEADER
--
--
procedure create_tk_grp_query_criteria
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_criteria_id     in  out nocopy number
  ,p_tk_group_query_id              in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_tk_group_id                    in  number
  ,p_criteria_type                  in  varchar2
  ,p_criteria_id                    in  number
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72) ;
	l_object_version_number     hxc_tk_group_query_criteria.object_version_number%TYPE;
	l_tk_group_query_criteria_id  hxc_tk_group_query_criteria.tk_group_query_criteria_id%TYPE;
	l_tk_group_query_id           hxc_tk_group_queries.tk_group_query_id%TYPE;
  --
begin
  g_debug :=hr_utility.debug_enabled;
  --
--  hr_utility.trace_on(trace_mode=>NULL, session_identifier=>'GAZ');
  --
  if g_debug then
  	l_proc := g_package||' create_tk_grp_query_criteria';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_tk_grp_query_criteria;
  --
  hxc_tk_grp_query_criteria_api.chk_criteria_type
	(    p_criteria_type => p_criteria_type );

  hxc_tk_grp_query_criteria_api.chk_criteria_id
	(    p_criteria_type => p_criteria_type
         ,   p_criteria_id   => p_criteria_id );

hxc_tk_group_query_api.maintain_tk_group_query
  (
   p_tk_group_query_id => l_tk_group_query_id
  ,p_tk_group_id       => p_tk_group_id
  );
if g_debug then
	hr_utility.trace('the tk group query id is '||to_char(l_tk_group_query_id));
end if;

hxc_tk_grp_query_criteria_api.chk_criteria_unique (
                        p_tk_group_query_criteria_id => p_tk_group_query_criteria_id
                      , p_tk_group_query_id          => l_tk_group_query_id
                      , p_criteria_type              => p_criteria_type
                      , p_criteria_id                => p_criteria_id );


  hxc_tk_grp_query_criteria_api.chk_tk_group_query_id ( p_tk_group_query_id => l_tk_group_query_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_tk_grp_query_criteria_BK_1.create_tk_grp_query_criteria_b
  (p_tk_group_query_criteria_id     => p_tk_group_query_criteria_id
  ,p_tk_group_query_id              => l_tk_group_query_id
  ,p_object_version_number          => p_object_version_number
  ,p_criteria_type                  => p_criteria_type
  ,p_criteria_id                    => p_criteria_id );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tk_grp_query_criteria'
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
hxc_tkgqc_ins.ins (
   p_tk_group_query_criteria_id  => l_tk_group_query_criteria_id
  ,p_tk_group_query_id 	=> l_tk_group_query_id
  ,p_criteria_type      => p_criteria_type
  ,p_criteria_id        => p_criteria_id
  ,p_object_version_number => l_object_version_number );
--

  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_tk_grp_query_criteria_BK_1.create_tk_grp_query_criteria_a
	  (p_tk_group_query_criteria_id      => l_tk_group_query_criteria_id
	  ,p_tk_group_query_id               => l_tk_group_query_id
	  ,p_object_version_number           => l_object_version_number
          ,p_criteria_type                   => p_criteria_type
          ,p_criteria_id                     => p_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tk_grp_query_criteria'
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
  p_tk_group_query_criteria_id     := l_tk_group_query_criteria_id;
  p_tk_group_query_id     := l_tk_group_query_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_tk_grp_query_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tk_group_query_criteria_id      := null;
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
    ROLLBACK TO create_tk_grp_query_criteria;
    raise;
    --
END create_tk_grp_query_criteria;



-- ----------------------------------------------------------------------------
-- |-------------------------<update_tk_grp_query_criteria>-------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--             SEE DESCRIPTION IN HEADER
--
procedure update_tk_grp_query_criteria
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_criteria_id     in  number
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  out nocopy number
  ,p_criteria_type                  in  varchar2
  ,p_criteria_id                    in  number )
IS
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72) ;
	l_object_version_number hxc_tk_group_query_criteria.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||' update_tk_grp_query_criteria';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_tk_grp_query_criteria;
  --

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TK_GROUP_QUERY_CRITERIA_ID'
    ,p_argument_value     => p_tk_group_query_criteria_id
    );

  hxc_tk_grp_query_criteria_api.chk_criteria_type
	(    p_criteria_type => p_criteria_type );

  hxc_tk_grp_query_criteria_api.chk_criteria_id
	(    p_criteria_type => p_criteria_type
         ,   p_criteria_id   => p_criteria_id );

  hxc_tk_grp_query_criteria_api.chk_tk_group_query_id ( p_tk_group_query_id => p_tk_group_query_id );

hxc_tk_grp_query_criteria_api.chk_criteria_unique (
                        p_tk_group_query_criteria_id => p_tk_group_query_criteria_id
                      , p_tk_group_query_id          => p_tk_group_query_id
                      , p_criteria_type              => p_criteria_type
                      , p_criteria_id                => p_criteria_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_tk_grp_query_criteria_BK_2.update_tk_grp_query_criteria_b
	  (p_tk_group_query_criteria_id      => p_tk_group_query_criteria_id
	  ,p_tk_group_query_id               => p_tk_group_query_id
	  ,p_object_version_number           => p_object_version_number
          ,p_criteria_type                   => p_criteria_type
          ,p_criteria_id                     => p_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_tk_grp_query_criteria'
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
hxc_tkgqc_upd.upd (
   p_tk_group_query_criteria_id  => p_tk_group_query_criteria_id
  ,p_tk_group_query_id 	=> p_tk_group_query_id
  ,p_criteria_type      => p_criteria_type
  ,p_criteria_id        => p_criteria_id
  ,p_object_version_number => l_object_version_number );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_tk_grp_query_criteria_BK_2.update_tk_grp_query_criteria_a
	  (p_tk_group_query_criteria_id      => p_tk_group_query_criteria_id
	  ,p_tk_group_query_id               => p_tk_group_query_id
	  ,p_object_version_number           => l_object_version_number
          ,p_criteria_type                   => p_criteria_type
          ,p_criteria_id                     => p_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_tk_grp_query_criteria'
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
    ROLLBACK TO update_tk_grp_query_criteria;
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
    ROLLBACK TO update_tk_grp_query_criteria;
    raise;

end update_tk_grp_query_criteria;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_tk_grp_query_criteria >--------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--             SEE DESCRIPTION IN HEADER
--
procedure delete_tk_grp_query_criteria
  (p_validate                       in  boolean  default false
  ,p_tk_group_query_criteria_id     in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  --
begin
  --
  g_debug :=hr_utility.debug_enabled;
--  hr_utility.trace_on(trace_mode=>NULL, session_identifier=>'GAZ');
  if g_debug then
  	l_proc := g_package||'delete_tk_grp_query_criteria';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_tk_grp_query_criteria;
  --
	hxc_tk_grp_query_criteria_api.chk_delete (
				 p_tk_group_query_criteria_id => p_tk_group_query_criteria_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_tk_grp_query_criteria_BK_3.delete_tk_grp_query_criteria_b
	  (p_tk_group_query_criteria_id     => p_tk_group_query_criteria_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tk_grp_query_criteria'
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
  hxc_tkgqc_del.del
    (
     p_tk_group_query_criteria_id     => p_tk_group_query_criteria_id
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
  hxc_tk_grp_query_criteria_BK_3.delete_tk_grp_query_criteria_a
	  (p_tk_group_query_criteria_id     => p_tk_group_query_criteria_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tk_grp_query_criteria'
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
    ROLLBACK TO delete_tk_grp_query_criteria;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_tk_grp_query_criteria;
    raise;
    --
end delete_tk_grp_query_criteria;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_criteria_type >------------------------------|
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
Procedure chk_criteria_type
  (
   p_criteria_type in varchar2
  ) IS

  l_proc  varchar2(72) ;
--
-- cursor to check criteria type valid
--
CURSOR  csr_chk_criteria_type IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hr_lookups h
	WHERE	h.lookup_type = 'HXC_TK_CRITERIA_TYPES'
        AND     h.lookup_code = p_criteria_type
        AND     h.enabled_flag = 'Y'
	AND	sysdate BETWEEN h.start_date_active AND NVL(h.end_date_active, hr_general.end_of_time) );
--
 l_dummy varchar2(5) := NULL;
--
BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'chk_criteria_type';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CRITERIA_TYPE'
    ,p_argument_value     => p_criteria_type
    );

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the criteria type is valid
--
  OPEN  csr_chk_criteria_type;
  FETCH csr_chk_criteria_type INTO l_dummy;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;

  IF csr_chk_criteria_type%NOTFOUND
  THEN
        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 30);
        end if;

        hr_utility.set_message(809, 'HXC_TEGQC_INV_CRITERIA_TYPE');
	hr_utility.raise_error;
  END IF;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  end if;

  CLOSE csr_chk_criteria_type;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 50);
  end if;

END chk_criteria_type;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_criteria_id >---------------------------------|
-- ----------------------------------------------------------------------------

Procedure chk_criteria_id
  (
   p_criteria_type in varchar2
  ,p_criteria_id   in number
  ) IS

l_proc varchar2(32) := 'chk_criteria_id';
l_dummy varchar2(1);

CURSOR  csr_chk_assignment_id IS
SELECT  'x'
FROM    dual
WHERE EXISTS ( select 'x'
               FROM   per_assignments_f asg
               WHERE  asg.assignment_id = p_criteria_id );
               -- GAZ - anymore specific ????

CURSOR  csr_chk_person_id IS
SELECT  'x'
FROM    dual
WHERE EXISTS ( select 'x'
               FROM   per_people_f p
               WHERE  p.person_id = p_criteria_id );
               -- GAZ - anymore specific ????

BEGIN

IF ( p_criteria_type = 'ASSIGNMENT' )
THEN

	OPEN  csr_chk_assignment_id;
	FETCH csr_chk_assignment_id INTO l_dummy;

	IF ( csr_chk_assignment_id%NOTFOUND )
	THEN
		hr_utility.set_message(809, 'HXC_TEGQC_INVALID_CRITERIA_ID');
		hr_utility.raise_error;
	END IF;

	CLOSE csr_chk_assignment_id;

ELSIF ( p_criteria_type = 'PERSON' )
THEN

	OPEN  csr_chk_person_id;
	FETCH csr_chk_person_id INTO l_dummy;

	IF ( csr_chk_person_id%NOTFOUND )
	THEN
		hr_utility.set_message(809, 'HXC_TEGQC_INVALID_CRITERIA_ID');
		hr_utility.raise_error;
	END IF;

	CLOSE csr_chk_person_id;

END IF;

END chk_criteria_id;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tk_group_query_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--             SEE DESCRIPTION IN HEADER
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_group_query_id
  (
   p_tk_group_query_id in number
  ) IS

l_proc varchar2(72) ;
l_dummy varchar2(1) := NULL;

CURSOR  csr_chk_tk_group_query_id IS
SELECT	'x'
FROM 	dual
WHERE EXISTS ( SELECT 'x'
               FROM   hxc_tk_group_queries tkgq
               WHERE  tkgq.tk_group_query_id = p_tk_group_query_id );

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := 'chk_tk_group_query_id';
  	hr_utility.set_location('Processing:'||l_proc, 5);
  end if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TK_GROUP_QUERY_ID'
    ,p_argument_value     => p_tk_group_query_id
    );

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

OPEN  csr_chk_tk_group_query_id;
FETCH csr_chk_tk_group_query_id INTO l_dummy;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;

IF csr_chk_tk_group_query_id%NOTFOUND
THEN
      if g_debug then
      	      hr_utility.set_location('Processing:'||l_proc, 30);
      end if;

      hr_utility.set_message(809, 'HXC_TKGQC_INV_TK_GRP_QUERY_ID');
      hr_utility.raise_error;
END IF;

CLOSE csr_chk_tk_group_query_id;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  end if;

END chk_tk_group_query_id;

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
   p_tk_group_query_criteria_id in number
  ) IS
BEGIN
null;
END chk_delete;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< get_criteria >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
FUNCTION get_criteria ( p_position number
                      , p_criteria_type varchar2
                      , p_criteria_id   number )
RETURN varchar2 IS

l_criteria varchar2(80);

CURSOR  csr_get_assignment_number IS
SELECT  asg.assignment_number
FROM    per_assignments asg
WHERE   asg.assignment_id = p_criteria_id;

CURSOR  csr_get_employee_number IS
SELECT  p.employee_number
FROM    per_people p
WHERE   p.person_id = p_criteria_id;

CURSOR  csr_get_full_name IS
SELECT ppf.full_name
  FROM per_assignments_f asg,fnd_sessions ss,per_people_f ppf
 WHERE asg.effective_start_date <= ss.effective_date
   AND asg.effective_end_date >= ss.effective_date
   AND ss.session_id = USERENV ('sessionid')
   AND ppf.effective_start_date <= ss.effective_date
   AND ppf.effective_end_date >= ss.effective_date
   AND ppf.person_id = asg.person_id
   AND asg.assignment_id = p_criteria_id;



CURSOR  csr_get_person_full_name IS
SELECT  p.full_name
FROM    per_people p
WHERE   p.person_id = p_criteria_id;

BEGIN

IF ( p_criteria_type = 'ASSIGNMENT' AND p_position = 1 )
THEN

	OPEN  csr_get_full_name;
	FETCH csr_get_full_name INTO l_criteria;
	CLOSE csr_get_full_name;

ELSIF ( p_criteria_type = 'ASSIGNMENT' AND p_position = 2 )
THEN

	OPEN  csr_get_assignment_number;
	FETCH csr_get_assignment_number INTO l_criteria;
	CLOSE csr_get_assignment_number;

ELSIF ( p_criteria_type = 'PERSON' AND p_position = 1 )
THEN

	OPEN  csr_get_person_full_name;
	FETCH csr_get_person_full_name INTO l_criteria;
	CLOSE csr_get_person_full_name;


ELSIF ( p_criteria_type = 'PERSON' AND p_position = 2 )
THEN

	OPEN  csr_get_employee_number;
	FETCH csr_get_employee_number INTO l_criteria;
	CLOSE csr_get_employee_number;

ELSE

      hr_utility.set_message(809, 'HXC_TKGQC_INV_PARAMS_CRITERIA');
      hr_utility.raise_error;

END IF;

RETURN l_criteria;

END get_criteria;



-- ----------------------------------------------------------------------------
-- |-----------------------< get_criteria_unique >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------

PROCEDURE chk_criteria_unique (
                        p_tk_group_query_criteria_id in number
                      , p_tk_group_query_id in number
                      , p_criteria_type varchar2
                      , p_criteria_id   number ) IS

CURSOR  csr_chk_unique IS
SELECT 'x'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_tk_group_query_criteria tkgqc
	WHERE	tkgqc.tk_group_query_id = p_tk_group_query_id
        AND     tkgqc.criteria_id       = p_criteria_id
	AND	tkgqc.criteria_type     = p_criteria_type
        AND
	( tkgqc.tk_group_query_criteria_id <> p_tk_group_query_criteria_id OR
	  p_tk_group_query_criteria_id IS NULL ) );

l_dummy VARCHAR2(1);

l_proc varchar2(72) ;

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := 'chk_criteria_unique';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

OPEN  csr_chk_unique;
FETCH csr_chk_unique INTO l_dummy;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

IF ( csr_chk_unique%FOUND )
THEN

      if g_debug then
	      hr_utility.set_location('Processing:'||l_proc, 20);
      end if;

      hr_utility.set_message(809, 'HXC_TKGQC_DUP_CRITERIA');
      hr_utility.raise_error;

END IF;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 30);
  end if;

END chk_criteria_unique;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_tc_period >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
FUNCTION get_tc_period ( p_resource_id number )
RETURN varchar2 IS

l_tc_period hxc_recurring_periods.name%TYPE;
l_pref_tab  hxc_preference_evaluation.t_pref_table;
l_recurring_period_id hxc_pref_hierarchies.attribute1%TYPE;

l_session_date DATE;

CURSOR csr_get_tc_period ( p_rp_id VARCHAR2 ) IS
SELECT rp.name
FROM   hxc_recurring_periods rp
WHERE  rp.recurring_period_id = TO_NUMBER(p_rp_id);

CURSOR csr_get_effective_date IS
SELECT effective_date
FROM   fnd_sessions
WHERE  session_id = USERENV('sessionid');

BEGIN

/*

-- decided not to get the pref for all time
-- get preference as of session date

hxc_preference_evaluation.resource_preferences(
		p_resource_id		=> p_resource_id
,               p_start_evaluation_date => hr_general.start_of_time
,               p_end_evaluation_date   => hr_general.end_of_time
,               p_pref_table		=> l_pref_tab );
*/

OPEN  csr_get_effective_date;
FETCH csr_get_effective_date INTO l_session_date;
CLOSE csr_get_effective_date;

l_recurring_period_id :=
hxc_preference_evaluation.resource_preferences(
			p_resource_id	  => p_resource_id
		,	p_pref_code       => 'TC_W_TCRD_PERIOD'
                ,       p_attribute_n     => 1
                ,       p_evaluation_date => l_session_date );

OPEN  csr_get_tc_period ( l_recurring_period_id );
FETCH csr_get_tc_period INTO l_tc_period;
CLOSE csr_get_tc_period;

IF ( l_tc_period IS NULL )
THEN

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', 'get_tc_period');
    fnd_message.set_token('STEP','no Timecard Period Exists for pref value');
    fnd_message.raise_error;

END IF;

RETURN l_tc_period;

END get_tc_period;

-- ----------------------------------------------------------------------------
-- |-----------------------< check_audit_enabled >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------

FUNCTION  check_audit_enabled ( p_resource_id number )
RETURN VARCHAR2 IS

l_pref_tab  hxc_preference_evaluation.t_pref_table;
l_recurring_period_id hxc_pref_hierarchies.attribute1%TYPE;
l_session_date DATE;

l_audit  VARCHAR2(150);

CURSOR csr_get_effective_date IS
SELECT effective_date
FROM   fnd_sessions
WHERE  session_id = USERENV('SESSIONID');

BEGIN

OPEN  csr_get_effective_date;
FETCH csr_get_effective_date INTO l_session_date;
CLOSE csr_get_effective_date;


IF (hxc_preference_evaluation.resource_preferences(
			p_resource_id	  => p_resource_id
		,	p_pref_code       => 'TS_PER_AUDIT_REQUIREMENTS'
                ,       p_attribute_n     => 1
                ,       p_evaluation_date => l_session_date )IS NOT NULL) THEN

   l_audit := hr_bis.bis_decode_lookup ('YES_NO','Y');
ELSE
   l_audit := hr_bis.bis_decode_lookup ('YES_NO','N');
END IF;

RETURN l_audit;

EXCEPTION

WHEN OTHERS THEN

RETURN NULL;

END CHECK_AUDIT_ENABLED;

-- ----------------------------------------------------------------------------
-- |-----------------------< tc_period_ok >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
FUNCTION tc_period_ok ( p_resource_id      number
		,	p_period_type      varchar2
		,	p_duration_in_days number )
RETURN BOOLEAN IS

l_recurring_period_id hxc_pref_hierarchies.attribute1%TYPE;

l_tc_period_ok BOOLEAN := FALSE;

CURSOR csr_get_tc_period_type ( p_rp_id VARCHAR2 ) IS
SELECT	rp.period_type
,	rp.duration_in_days
FROM  	hxc_recurring_periods rp
WHERE 	rp.recurring_period_id = TO_NUMBER(p_rp_id);

l_period_rec csr_get_tc_period_type%ROWTYPE;


BEGIN

l_recurring_period_id :=
hxc_preference_evaluation.resource_preferences(
			p_resource_id	  => p_resource_id
		,	p_pref_code       => 'TC_W_TCRD_PERIOD'
                ,       p_attribute_n     => 1 );

OPEN  csr_get_tc_period_type ( l_recurring_period_id );
FETCH csr_get_tc_period_type INTO l_period_rec;
CLOSE csr_get_tc_period_type;

IF ( l_period_rec.period_type IS NOT NULL AND ( l_period_rec.period_type = p_period_type ) )
THEN

	l_tc_period_ok := TRUE;

ELSIF ( l_period_rec.period_type IS NULL AND ( l_period_rec.duration_in_days = p_duration_in_days ) AND
        l_period_rec.duration_in_days IS NOT NULL )
THEN

	l_tc_period_ok := TRUE;

END IF;


RETURN l_tc_period_ok;

END tc_period_ok;

END hxc_tk_grp_query_criteria_api;

/
