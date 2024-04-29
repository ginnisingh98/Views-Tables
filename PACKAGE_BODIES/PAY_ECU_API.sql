--------------------------------------------------------
--  DDL for Package Body PAY_ECU_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ECU_API" as
/* $Header: pyecuapi.pkb 120.1 2005/10/20 02:50:13 pgongada noship $ */
--
procedure CREATE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in	  number
  ,p_classification_id             in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_element_class_usage_id        out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ) is
--
  l_element_class_usage_id         PAY_ELEMENT_CLASS_USAGES_F.ELEMENT_CLASS_USAGE_ID%TYPE;
  l_object_version_number          PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
  l_effective_start_date           PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date             PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_END_DATE%TYPE;
  l_proc		           varchar2(72) :=  g_package||'.create_ele_class_usages';
--
begin
--
	hr_utility.set_location(' Entering : '||l_proc,10);
	--
	-- Standard savepoint.
	--
	savepoint create_ele_class_usages;
	--
	begin
	--
		hr_utility.set_location('Calling create_ele_class_b'||l_proc,15);
		pay_ecu_bk1.create_ele_class_usages_b(
		 p_effective_date	=> p_effective_date
		,p_run_type_id          => p_run_type_id
	        ,p_classification_id    => p_classification_id
		,p_business_group_id    => p_business_group_id
		,p_legislation_code     => p_legislation_code
		);
		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'create_ele_class_usages'
			,p_hook_type   => 'BP');
	--
	end;
	hr_utility.set_location('Calling pay_ecu_ins.ins :'||l_proc,20);
	pay_ecu_ins.ins(
	 p_effective_date                 => p_effective_date
	,p_run_type_id                    => p_run_type_id
	,p_classification_id              => p_classification_id
	,p_business_group_id              => p_business_group_id
	,p_legislation_code               => p_legislation_code
	,p_element_class_usage_id         => l_element_class_usage_id
	,p_object_version_number          => l_object_version_number
	,p_effective_start_date           => l_effective_start_date
	,p_effective_end_date             => l_effective_end_date
	);
	begin
		hr_utility.set_location('Calling create_ele_class_a'||l_proc,25);
		pay_ecu_bk1.create_ele_class_usages_a(
		p_effective_date                => p_effective_date
		,p_element_class_usage_id       => l_element_class_usage_id
		,p_run_type_id                  => p_run_type_id
		,p_classification_id		=> p_classification_id
		,p_business_group_id            => p_business_group_id
		,p_legislation_code             => p_legislation_code
		,p_object_version_number	=> l_object_version_number
		,p_effective_start_date		=> l_effective_start_date
		,p_effective_end_date		=> l_effective_end_date);
		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'create_ele_class_usages'
			,p_hook_type   => 'AP');
	end;
	if(p_validate) then
	--
		raise hr_api.validate_enabled;
	--
	end if;

	hr_utility.set_location(l_proc,30);
	--
	p_element_class_usage_id       := l_element_class_usage_id;
	p_object_version_number	       := l_object_version_number;
	p_effective_start_date	       := l_effective_start_date;
	p_effective_end_date	       := l_effective_end_date;
	--
	hr_utility.set_location(' Leaving:'||l_proc, 70);
	EXCEPTION
		WHEN hr_api.validate_enabled then
		--
			ROLLBACK TO create_ele_class_usages;
			p_element_class_usage_id       := null;
			p_object_version_number	       := null;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
		--
		WHEN OTHERS then
		--
			ROLLBACK TO create_ele_class_usages;
			--
			p_element_class_usage_id       := null;
			p_object_version_number	       := null;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
			--
			RAISE;
		--
end CREATE_ELE_CLASS_USAGES;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< UPDATE_ELE_CLASS_USAGES >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_run_type_id                   in	  number   default hr_api.g_number
  ,p_classification_id             in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_element_class_usage_id        in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out    nocopy   date
  ,p_effective_end_date            out    nocopy   date
  ) is
--
  l_proc		varchar2(72) :=g_package || '.update_ele_class_usages';
--
  l_element_class_usage_id         PAY_ELEMENT_CLASS_USAGES_F.ELEMENT_CLASS_USAGE_ID%TYPE;
  l_in_out_ele_class_usage_id      PAY_ELEMENT_CLASS_USAGES_F.ELEMENT_CLASS_USAGE_ID%TYPE;
  l_object_version_number          PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
  l_in_out_object_version_number   PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
  l_effective_start_date           PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date             PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_END_DATE%TYPE;
--
begin
	hr_utility.set_location(' Entering : '||l_proc,10);
	l_element_class_usage_id	:= p_element_class_usage_id;
	l_in_out_ele_class_usage_id     := p_element_class_usage_id;
	l_object_version_number		:= p_object_version_number;
	l_in_out_object_version_number	:= p_object_version_number;
	--
	-- Standard savepoint.
	--
	savepoint update_ele_class_usages;
	--
	begin
	--
		hr_utility.set_location('Calling update_ele_class_b'||l_proc,15);
		pay_ecu_bk2.update_ele_class_usages_b(
		 p_effective_date		=> p_effective_date
		,p_datetrack_mode		=> p_datetrack_mode
		,p_element_class_usage_id       => p_element_class_usage_id
		,p_run_type_id			=> p_run_type_id
	        ,p_classification_id		=> p_classification_id
		,p_business_group_id		=> p_business_group_id
		,p_legislation_code		=> p_legislation_code
		,p_object_version_number        => p_object_version_number
		);
		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'update_ele_class_usages'
			,p_hook_type   => 'BP');
	--
	end;
		hr_utility.set_location('Calling pay_ecu_upd.upd'||l_proc,25);
		--
		pay_ecu_upd.upd(
	        p_effective_date                => p_effective_date
	       ,p_datetrack_mode                => p_datetrack_mode
	       ,p_run_type_id                   => p_run_type_id
	       ,p_classification_id             => p_classification_id
	       ,p_business_group_id             => p_business_group_id
               ,p_legislation_code              => p_legislation_code
               ,p_element_class_usage_id        => l_element_class_usage_id
	       ,p_object_version_number         => l_object_version_number
               ,p_effective_start_date          => l_effective_start_date
               ,p_effective_end_date            => l_effective_end_date);

	begin
	--
		hr_utility.set_location('update_ele_class_a'||l_proc,25);
		pay_ecu_bk2.update_ele_class_usages_a(
		 p_effective_date                => p_effective_date
                ,p_datetrack_mode                => p_datetrack_mode
		,p_element_class_usage_id        => l_element_class_usage_id
		,p_run_type_id                   => p_run_type_id
		,p_classification_id		 => p_classification_id
		,p_business_group_id             => p_business_group_id
		,p_legislation_code              => p_legislation_code
		,p_object_version_number	 => l_object_version_number
		,p_effective_start_date		 => l_effective_start_date
		,p_effective_end_date		 => l_effective_end_date);

		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'update_ele_class_usages'
			,p_hook_type   => 'AP');
	--
	end;
	--
	if(p_validate) then
	--
		raise hr_api.validate_enabled;
	--
	end if;

	hr_utility.set_location(l_proc,30);
	--
	p_element_class_usage_id       := l_element_class_usage_id;
	p_object_version_number	       := l_object_version_number;
	p_effective_start_date	       := l_effective_start_date;
	p_effective_end_date	       := l_effective_end_date;
	--
        hr_utility.set_location(' Leaving:'||l_proc, 70);
	EXCEPTION
		WHEN hr_api.validate_enabled then
		--
			ROLLBACK TO update_ele_class_usages;
			p_element_class_usage_id       := l_in_out_ele_class_usage_id;
			p_object_version_number	       := l_in_out_object_version_number;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
		--
		WHEN OTHERS then
		--
			ROLLBACK TO update_ele_class_usages;
			--
			p_element_class_usage_id       := l_in_out_ele_class_usage_id;
			p_object_version_number	       := l_in_out_object_version_number;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
			--
			RAISE;
		--
end UPDATE_ELE_CLASS_USAGES;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ELE_CLASS_USAGES >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_element_class_usage_id        in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out    nocopy   date
  ,p_effective_end_date            out    nocopy   date
  ) is
--
  l_proc		varchar2(72) :=g_package || '.delete_ele_class_usages';
--
  l_object_version_number          PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
  l_in_out_object_version_number   PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
  l_effective_start_date           PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date             PAY_ELEMENT_CLASS_USAGES_F.EFFECTIVE_END_DATE%TYPE;
--
begin
--
	hr_utility.set_location(' Entering : '||l_proc,10);
	l_object_version_number		:= p_object_version_number;
	l_in_out_object_version_number  := p_object_version_number;
	--
	-- Standard savepoint.
	--
	savepoint delete_ele_class_usages;
	--
	begin
	--
		hr_utility.set_location('Calling delete_ele_class_b'||l_proc,15);
		pay_ecu_bk3.delete_ele_class_usages_b(
		 p_effective_date		=> p_effective_date
		,p_datetrack_mode		=> p_datetrack_mode
		,p_element_class_usage_id       => p_element_class_usage_id
		,p_object_version_number        => p_object_version_number
		);
		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'delete_ele_class_usages'
			,p_hook_type   => 'BP');
	--
	end;
		hr_utility.set_location('Calling pay_ecu_del'||l_proc,10);
		--
		pay_ecu_del.del(
		p_effective_date                => p_effective_date
	       ,p_datetrack_mode                => p_datetrack_mode
	       ,p_element_class_usage_id        => p_element_class_usage_id
	       ,p_object_version_number         => l_object_version_number
               ,p_effective_start_date          => l_effective_start_date
               ,p_effective_end_date            => l_effective_end_date);
	begin
	--
		hr_utility.set_location('Calling delete_ele_class_a'||l_proc,25);
		pay_ecu_bk3.delete_ele_class_usages_a(
		 p_effective_date                => p_effective_date
                ,p_datetrack_mode                => p_datetrack_mode
		,p_element_class_usage_id        => p_element_class_usage_id
		,p_object_version_number	 => l_object_version_number
		,p_effective_start_date		 => l_effective_start_date
		,p_effective_end_date		 => l_effective_end_date);

		exception
			when hr_api.cannot_find_prog_unit then
			hr_api.cannot_find_prog_unit_error
			(p_module_name => 'delete_ele_class_usages'
			,p_hook_type   => 'AP');
	--
	end;
	--
	if(p_validate) then
	--
		raise hr_api.validate_enabled;
	--
	end if;

	hr_utility.set_location(l_proc,30);
	p_object_version_number	       := l_object_version_number;
	p_effective_start_date	       := l_effective_start_date;
	p_effective_end_date	       := l_effective_end_date;

	hr_utility.set_location(' Leaving:'||l_proc, 70);
	EXCEPTION
		WHEN hr_api.validate_enabled then
		--
			ROLLBACK TO delete_ele_class_usages;
			p_object_version_number	       := l_in_out_object_version_number;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
		--
		WHEN OTHERS then
		--
			ROLLBACK TO delete_ele_class_usages;
			--
			p_object_version_number	       := l_in_out_object_version_number;
			p_effective_start_date	       := null;
			p_effective_end_date	       := null;
			--
			RAISE;
		--
end delete_ele_class_usages;
--
end PAY_ECU_API;


/
