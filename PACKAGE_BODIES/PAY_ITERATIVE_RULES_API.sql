--------------------------------------------------------
--  DDL for Package Body PAY_ITERATIVE_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ITERATIVE_RULES_API" as
/* $Header: pyitrapi.pkb 120.0 2005/05/29 06:02:58 appldev noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_iterative_rules_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_iterative_rule
(  p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_result_name                    in     varchar2
  ,p_iterative_rule_type            in     varchar2
  ,p_input_value_id                 in     number   default null
  ,p_severity_level                 in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_iterative_rule_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
) is
 --
  l_proc varchar2(72) := g_package||'create_iterative_rule';
  l_effective_date        date;
  l_iterative_rule_id     pay_iterative_rules_f.iterative_rule_id%TYPE;
  l_object_version_number pay_iterative_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_iterative_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_iterative_rules_f.effective_end_date%TYPE;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_ITERATIVE_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_iterative_rules_bk1.create_iterative_rule_b
      (p_effective_date             =>  l_effective_date
      ,p_element_type_id            =>  p_element_type_id
      ,p_result_name                =>  p_result_name
      ,p_iterative_rule_type        =>  p_iterative_rule_type
      ,p_input_value_id             =>  p_input_value_id
      ,p_severity_level             =>  p_severity_level
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ITERATIVE_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  pay_itr_ins.ins
  (
   p_effective_date        => l_effective_date
  ,p_element_type_id       => p_element_type_id
  ,p_result_name           => p_result_name
  ,p_iterative_rule_type   => p_iterative_rule_type
  ,p_input_value_id        => p_input_value_id
  ,p_severity_level        => p_severity_level
  ,p_business_group_id     => p_business_group_id
  ,p_legislation_code      => p_legislation_code
  ,p_iterative_rule_id     => l_iterative_rule_id
  ,p_object_version_number => l_object_version_number
  ,p_effective_start_date  => l_effective_start_date
  ,p_effective_end_date    => l_effective_end_date
  );
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_iterative_rules_bk1.create_iterative_rule_a
      (p_effective_date             =>  l_effective_date
      ,p_element_type_id            =>  p_element_type_id
      ,p_result_name                =>  p_result_name
      ,p_iterative_rule_type        =>  p_iterative_rule_type
      ,p_input_value_id             =>  p_input_value_id
      ,p_severity_level             =>  p_severity_level
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      ,p_iterative_rule_id	    =>  l_iterative_rule_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ITERATIVE_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- Bug no. 4038593
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_iterative_rule_id     := l_iterative_rule_id;
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;

exception
  --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ITERATIVE_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_iterative_rule_id     := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ITERATIVE_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_iterative_rule_id     := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_iterative_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_iterative_rule
(  p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_iterative_rule_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_result_name                  in     varchar2  default hr_api.g_varchar2
  ,p_iterative_rule_type          in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_severity_level               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_iterative_rule';
  l_effective_date        date;
  l_object_version_number pay_iterative_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_iterative_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_iterative_rules_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ITERATIVE_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_object_version_number := p_object_version_number;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    pay_iterative_rules_bk2.update_iterative_rule_b
      (p_effective_date          => l_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_iterative_rule_id       => p_iterative_rule_id
      ,p_object_version_number   => l_object_version_number
      ,p_element_type_id         => p_element_type_id
      ,p_result_name             => p_result_name
      ,p_iterative_rule_type     => p_iterative_rule_type
      ,p_input_value_id          => p_input_value_id
      ,p_severity_level          => p_severity_level
      ,p_business_group_id       => p_business_group_id
      ,p_legislation_code        => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ITERATIVE_RULE'
        ,p_hook_type   => 'BP'
        );
  end;

  pay_itr_upd.upd
  (
   p_effective_date            => l_effective_date
  ,p_datetrack_mode            => p_datetrack_mode
  ,p_iterative_rule_id         => p_iterative_rule_id
  ,p_object_version_number     => l_object_version_number
  ,p_element_type_id           => p_element_type_id
  ,p_result_name               => p_result_name
  ,p_iterative_rule_type       => p_iterative_rule_type
  ,p_input_value_id            => p_input_value_id
  ,p_severity_level            => p_severity_level
  ,p_business_group_id         => p_business_group_id
  ,p_legislation_code          => p_legislation_code
  ,p_effective_start_date      => l_effective_start_date
  ,p_effective_end_date        => l_effective_end_date
  );
  --
  -- Call After Process User Hook
  --
  begin
    pay_iterative_rules_bk2.update_iterative_rule_a
      (p_effective_date          => l_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_iterative_rule_id       => p_iterative_rule_id
      ,p_object_version_number   => l_object_version_number
      ,p_element_type_id         => p_element_type_id
      ,p_result_name             => p_result_name
      ,p_iterative_rule_type     => p_iterative_rule_type
      ,p_input_value_id          => p_input_value_id
      ,p_severity_level          => p_severity_level
      ,p_business_group_id       => p_business_group_id
      ,p_legislation_code        => p_legislation_code
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ITERATIVE_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Bug no. 4038593
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;

exception
  --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ITERATIVE_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_ITERATIVE_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 50);
    raise;
    --
end update_iterative_rule;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_iterative_rule
(  p_validate                         in     boolean   default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_iterative_rule_id                in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_iterative_rule';
  l_effective_date        date;
  l_object_version_number pay_iterative_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_iterative_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_iterative_rules_f.effective_end_date%TYPE;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ITERATIVE_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
   l_object_version_number:= p_object_version_number;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    pay_iterative_rules_bk3.delete_iterative_rule_b
      (p_effective_date          => l_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_iterative_rule_id       => p_iterative_rule_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ITERATIVE_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  pay_itr_del.del
  (
   p_effective_date           => l_effective_date
  ,p_datetrack_mode           => p_datetrack_mode
  ,p_iterative_rule_id        => p_iterative_rule_id
  ,p_object_version_number    => l_object_version_number
  ,p_effective_start_date     => l_effective_start_date
  ,p_effective_end_date       => l_effective_end_date
  );
  --
  -- Call After Process User Hook
  --
  begin
    pay_iterative_rules_bk3.delete_iterative_rule_a
      (p_effective_date          => l_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_iterative_rule_id       => p_iterative_rule_id
      ,p_object_version_number   => l_object_version_number
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ITERATIVE_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  -- Bug no. 4038593
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
exception
   --
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ITERATIVE_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_ITERATIVE_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 50);
    raise;
    --
end delete_iterative_rule ;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
/*procedure lck_iterative_rule
(
   p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_iterative_rule_id                in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
) is
  --
  --
  -- Declare cursors and local variables
  l_proc                  varchar2(72) := g_package||'lck_iterative_rule.';
  l_validation_start_date  date;
  l_validation_end_date    date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_itr_shd.lck
  (
   p_effective_date         => p_effective_date
  ,p_datetrack_mode         => p_datetrack_mode
  ,p_iterative_rule_id      => p_iterative_rule_id
  ,p_object_version_number  => p_object_version_number
  ,p_validation_start_date  => l_validation_start_date
  ,p_validation_end_date    => l_validation_end_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck_iterative_rule;
*/
--
--
end pay_iterative_rules_api;

/
