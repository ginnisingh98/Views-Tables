--------------------------------------------------------
--  DDL for Package Body GHR_PDC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_API" AS
/* $Header: ghpdcapi.pkb 120.1.12010000.1 2009/05/25 12:01:00 utokachi noship $ */

-- PAckage Variables

g_package varchar2(100) := 'ghr_pdc_api';
l_pd_classification_id  number;
l_position_description_id number;
l_pdc_object_version_number number;

PROCEDURE create_pdc
             (p_validate IN BOOLEAN default false,
	p_pd_classification_id OUT NOCOPY ghr_pd_classifications.pd_classification_id%TYPE,
	p_position_description_id IN number,
	p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
        p_official_title  IN ghr_pd_classifications.official_title%TYPE,
	p_pay_plan   IN  ghr_pd_classifications.pay_plan%TYPE,
	p_occupational_code IN ghr_pd_classifications.occupational_code%TYPE,
	p_grade_level	IN   ghr_pd_classifications.grade_level%TYPE,
	p_pdc_object_version_number out NOCOPY number)
IS
l_proc	varchar2(72);
l_pdc_object_version_number number;
l_position_description_id number;
l_pd_classification_id number;
BEGIN
l_proc := g_package||' create_pdc';
hr_utility.set_location('Entering:'||l_proc,5);
--
-- Issue a savepoint if operating in validation only mode
--
-- IF p_validate THEN
-- Bug# 671537
-- END IF;
SAVEPOINT create_pdc;
  -- Call Before Process User Hook
  --
  begin
	ghr_pdc_bk1.create_pdc_b (
             p_position_description_id =>  p_position_description_id,
             p_class_grade_by          =>  p_class_grade_by,
             p_official_title          =>  p_official_title,
             p_pay_plan                =>  p_pay_plan,
             p_occupational_code       =>  p_occupational_code,
             p_grade_level             =>  p_grade_level
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pdc',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  --


hr_utility.set_location(l_proc,6);

-- Validation in Addition to Row Handlers:

IF p_position_description_id is NULL  THEN

	hr_utility.set_message(8301,'GHR_POS_DESC_ID_INVALID');
	hr_utility.raise_error;
END IF;

-- Process Logic
-- Insert a row into GHR_PD_CLASSIFICATIONS using the row handler.

ghr_pdc_ins.ins
(p_pd_classification_id	=> l_pd_classification_id,
  p_position_description_id      => p_position_description_id,
  p_class_grade_by	    => p_class_grade_by,
  p_official_title               => p_official_title,
  p_pay_plan                     => p_pay_plan,
  p_occupational_code	=> p_occupational_code,
  p_grade_level                  => p_grade_level,
  p_object_version_number  => l_pdc_object_version_number);

p_pd_classification_id := l_pd_classification_id;

  --
  -- Call After Process User Hook
  --
  begin
	ghr_pdc_bk1.create_pdc_a	(
             p_pd_classification_id      =>  l_pd_classification_id,
             p_position_description_id   =>  p_position_description_id,
             p_class_grade_by            =>  p_class_grade_by,
             p_official_title            =>  p_official_title,
             p_pay_plan                  =>  p_pay_plan,
             p_occupational_code         =>  p_occupational_code,
             p_grade_level               =>  p_grade_level,
             p_pdc_object_version_number =>  l_pdc_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pdc',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
  --
IF p_validate THEN

	RAISE hr_api.validate_enabled;

END IF;

--
-- Set All output Arguments
--

p_pdc_object_version_number := l_pdc_object_version_number;
p_pd_classification_id := l_pd_classification_id;


hr_utility.set_location ('Leaving:'|| l_proc,11);

EXCEPTION

	WHEN hr_api.validate_enabled THEN

	-- As the validation exception has been raised
	-- We must rollback to the Savepoint set.

	ROLLBACK TO create_pdc;


--	Only Set Output warning arguments.
--  	(Any key or derived arguments must be set to NULL
--	When validation only mode is being used.)
--

	p_pdc_object_version_number := NULL;
	p_pd_classification_id := NULL;
      --
	when others then
           rollback to create_pdc;
	   p_pdc_object_version_number := NULL;
	   p_pd_classification_id := NULL;
           raise;
	hr_utility.set_location('Leaving:' || l_proc,12);
      --
END create_pdc;


PROCEDURE
update_pdc(p_validate IN BOOLEAN default false,
	p_pd_classification_id  IN ghr_pd_classifications.pd_classification_id%TYPE,
	p_position_description_id IN ghr_position_descriptions.position_description_id%TYPE,
	p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
        p_official_title  IN ghr_pd_classifications.official_title%TYPE,
	p_pay_plan   IN  ghr_pd_classifications.pay_plan%TYPE,
	p_occupational_code IN ghr_pd_classifications.occupational_code%TYPE,
	p_grade_level	IN   ghr_pd_classifications.grade_level%TYPE,
	p_pdc_object_version_number IN out NOCOPY number)

IS
l_proc varchar2(72);
l_object_version_number number;
l_pd_classification_id ghr_pd_classifications.pd_classification_id%TYPE;
l_pdc_object_version_number NUMBER;

BEGIN
l_proc := g_package||'Update_pdc';
hr_utility.set_location('Entering:'||l_proc,5);
l_pdc_object_version_number := p_pdc_object_version_number;
--
-- Issue a savepoint if operating in validation only mode
-- Bug # 671537
-- IF p_validate THEN
-- END IF;
   SAVEPOINT update_pdc;
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_pdc_bk2.update_pdc_b (
             p_pd_classification_id      =>  p_pd_classification_id,
             p_position_description_id   =>  p_position_description_id,
             p_class_grade_by            =>  p_class_grade_by,
             p_official_title            =>  p_official_title,
             p_pay_plan                  =>  p_pay_plan,
             p_occupational_code         =>  p_occupational_code,
             p_grade_level               =>  p_grade_level,
             p_pdc_object_version_number =>  p_pdc_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		p_pdc_object_version_number := l_pdc_object_version_number; -- Nocopy changes
		hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pdc',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  --

hr_utility.set_location(l_proc,6);

-- Validation in Addition to Row Handlers:

IF (p_pd_classification_id is NULL )
AND (p_position_description_id is NULL OR p_class_grade_by is NULL)
THEN

	hr_utility.set_message(8301,'GHR_INSUFFICIENT_INFORMATION');
END IF;

-- Process Logic

l_object_version_number := p_pdc_object_version_number;

ghr_pdc_upd.upd
( p_pd_classification_id	=> p_pd_classification_id,
  p_position_description_id     => p_position_description_id,
  p_class_grade_by	        => p_class_grade_by,
  p_official_title              => p_official_title,
  p_pay_plan                    => p_pay_plan,
  p_occupational_code	        => p_occupational_code,
  p_grade_level                 => p_grade_level,
  p_object_version_number       => l_object_version_number);


hr_utility.set_location(l_proc,8);

--When in validation only mode raise the Validate_Enabled exception.
--

  --
  -- Call After Process User Hook
  --
  begin
	ghr_pdc_bk2.update_pdc_a	(
             p_pd_classification_id      =>  p_pd_classification_id,
             p_position_description_id   =>  p_position_description_id,
             p_class_grade_by            =>  p_class_grade_by,
             p_official_title            =>  p_official_title,
             p_pay_plan                  =>  p_pay_plan,
             p_occupational_code         =>  p_occupational_code,
             p_grade_level               =>  p_grade_level,
             p_pdc_object_version_number =>  l_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
   		p_pdc_object_version_number := l_pdc_object_version_number; -- Nocopy changes
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pdc',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
IF p_validate THEN

	RAISE hr_api.validate_enabled;

END IF;

--
-- Set all output arguments
--

p_pdc_object_version_number := l_object_version_number;

--
hr_utility.set_location('Leaving:'|| l_proc,11);

EXCEPTION

	WHEN hr_api.validate_enabled THEN

	--
	-- As the Validate_Enabled exception has been raised
	-- We must rollback to the savepoint
	--
	ROLLBACK to update_pdc;
	p_pdc_object_version_number := l_pdc_object_version_number; -- Nocopy changes
	--
	when others then
           rollback to update_pdc;
  	   p_pdc_object_version_number := l_pdc_object_version_number; -- Nocopy changes
           raise;
	hr_utility.set_location('Leaving:' || l_proc,12);
      --
hr_utility.set_location('Leaving:'||l_proc,12);
end update_pdc;

PROCEDURE delete_pdc
(       p_validate IN BOOLEAN default false,
	p_pd_classification_id  IN ghr_pd_classifications.pd_classification_id%TYPE,
	p_pdc_object_version_number in  number)
IS

l_proc varchar2(72) ;
l_object_version_number number;
l_pd_classification_id ghr_pd_classifications.pd_classification_id%TYPE;


BEGIN
l_proc := g_package||'Delete_pdc';
hr_utility.set_location('Entering:'||l_proc,5);

   SAVEPOINT delete_pdc;
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_pdc_bk3.delete_pdc_b	(
             p_pd_classification_id      =>  p_pd_classification_id,
             p_pdc_object_version_number =>  l_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_pdc',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --

hr_utility.set_location(l_proc,6);

-- Validation in Addition to Row Handlers:

IF (p_pd_classification_id is NULL )
AND (p_pdc_object_version_number is NULL)
THEN

	hr_utility.set_message(8301,'GHR_INSUFFICIENT_INFORMATION');
END IF;

-- Process Logic

l_object_version_number := p_pdc_object_version_number;

ghr_pdc_del.del
( p_pd_classification_id	=> p_pd_classification_id,
  p_object_version_number       => l_object_version_number);


hr_utility.set_location(l_proc,8);

--When in validation only mode raise the Validate_Enabled exception.
--

  --
  -- Call After Process User Hook
  --
  begin
	ghr_pdc_bk3.delete_pdc_a	(
             p_pd_classification_id      =>  p_pd_classification_id,
             p_pdc_object_version_number =>  l_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_pdc',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
IF p_validate THEN

	RAISE hr_api.validate_enabled;

END IF;


--
hr_utility.set_location('Leaving:'|| l_proc,11);

EXCEPTION

	WHEN hr_api.validate_enabled THEN
	--
	-- As the Validate_Enabled exception has been raised
	-- We must rollback to the savepoint
	--
	ROLLBACK to delete_pdc;
	--
	when others then
           rollback to delete_pdc;
           raise;
	hr_utility.set_location('Leaving:' || l_proc,12);
      --
hr_utility.set_location('Leaving:'||l_proc,12);
end delete_pdc;

end ghr_pdc_api;

/
