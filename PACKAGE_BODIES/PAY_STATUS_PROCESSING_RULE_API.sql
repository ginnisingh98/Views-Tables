--------------------------------------------------------
--  DDL for Package Body PAY_STATUS_PROCESSING_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STATUS_PROCESSING_RULE_API" as
/* $Header: pypprapi.pkb 115.3 2004/02/27 01:12:21 adkumar noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_status_processing_rule_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_status_process_rule >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_status_process_rule
(  p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_formula_id                     in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_legislation_subgroup           in     varchar2 default null
  ,p_status_processing_rule_id         out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
  ,p_formula_mismatch_warning          out nocopy boolean
) is
 --
  l_proc varchar2(72)          := g_package||'create_status_process_rule';
  l_effective_date             date;
  l_effective_start_date       pay_status_processing_rules_f.effective_start_date%type;
  l_effective_end_date         pay_status_processing_rules_f.effective_end_date%type;
  l_status_processing_rule_id  pay_status_processing_rules_f.status_processing_rule_id%type;
  l_object_version_number      pay_status_processing_rules_f.object_version_number%type;
  l_comment_id                 pay_status_processing_rules_f.comment_id%type;
  l_formula_mismatch_warning boolean;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue the savepoint.
  --
    savepoint create_status_process_rule;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_status_processing_rule_bk1.create_status_process_rule_b
      (p_effective_date             =>  l_effective_date
      ,p_element_type_id            =>  p_element_type_id
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      ,p_assignment_status_type_id  =>  p_assignment_status_type_id
      ,p_formula_id                 =>  p_formula_id
      ,p_comments                   =>  p_comments
      ,p_legislation_subgroup       =>  p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  -- Process Logic
  --
  pay_ppr_ins.ins
  ( p_effective_date                 => l_effective_date
   ,p_element_type_id                => p_element_type_id
   ,p_business_group_id              => p_business_group_id
   ,p_legislation_code               => p_legislation_code
   ,p_assignment_status_type_id      => p_assignment_status_type_id
   ,p_formula_id                     => p_formula_id
   ,p_comments                       => p_comments
   ,p_legislation_subgroup           => p_legislation_subgroup
   ,p_status_processing_rule_id      => l_status_processing_rule_id
   ,p_object_version_number          => l_object_version_number
   ,p_effective_start_date           => l_effective_start_date
   ,p_effective_end_date             => l_effective_end_date
   ,p_comment_id                     => l_comment_id
   ,p_formula_mismatch_warning       => l_formula_mismatch_warning
  );
  --
  -- Call After Process User Hook
    hr_utility.set_location('Entering:'||l_proc, 30);
  --
  begin
    pay_status_processing_rule_bk1.create_status_process_rule_a
      (p_effective_date             =>  l_effective_date
      ,p_element_type_id            =>  p_element_type_id
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      ,p_assignment_status_type_id  =>  p_assignment_status_type_id
      ,p_formula_id                 =>  p_formula_id
      ,p_comments                   =>  p_comments
      ,p_legislation_subgroup       =>  p_legislation_subgroup
      ,p_status_processing_rule_id  =>  l_status_processing_rule_id
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      ,p_object_version_number      =>  l_object_version_number
     ,p_formula_mismatch_warning    => l_formula_mismatch_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
 --
 -- When in validation only mode raise the Validate_Enabled exception
 --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  -- set all OUT parameter for message
    p_status_processing_rule_id := l_status_processing_rule_id;
    p_effective_start_date      := l_effective_start_date;
    p_effective_end_date        := l_effective_end_date;
    p_object_version_number     := l_object_version_number;
    p_formula_mismatch_warning  := l_formula_mismatch_warning;
--
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
      ROLLBACK TO create_status_process_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      p_object_version_number         := null;
      p_status_processing_rule_id     := null;
      p_effective_start_date          := null;
      p_effective_end_date            := null;
    --
      p_formula_mismatch_warning   := l_formula_mismatch_warning ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_status_process_rule;
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    raise;
end create_status_process_rule;

-- ----------------------------------------------------------------------------
-- |------------------------< update_status_process_rule >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_status_process_rule
(  p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_status_processing_rule_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_formula_mismatch_warning        out nocopy boolean
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_status_process_rule';
  l_object_version_number pay_status_processing_rules_f.object_version_number%type;
  l_effective_date        date;
  l_effective_start_date  pay_status_processing_rules_f.effective_start_date%type;
  l_effective_end_date    pay_status_processing_rules_f.effective_end_date%type;
  l_temp_ovn              pay_status_processing_rules_f.object_version_number%type;
  l_formula_mismatch_warning boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue the savepoint.
   --
    savepoint update_status_process_rule;
 --
  l_temp_ovn   := p_object_version_number;
  l_object_version_number := p_object_version_number;

  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_status_processing_rule_bk2.update_status_process_rule_b
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_mode             =>  p_datetrack_mode
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_formula_id                 =>  p_formula_id
      ,p_comments                   =>  p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- call business process
  --
    hr_utility.set_location(l_proc, 20);
  --
 pay_ppr_upd.upd
 ( p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_mode
  ,p_status_processing_rule_id    => p_status_processing_rule_id
  ,p_object_version_number        => l_object_version_number
  ,p_formula_id                   => p_formula_id
  ,p_comments                     => p_comments
  ,p_effective_start_date	  => l_effective_start_date
  ,p_effective_end_date		  => l_effective_end_date
  ,p_formula_mismatch_warning     => l_formula_mismatch_warning
  );

   -- Call After Process User Hook
  --
    hr_utility.set_location(l_proc, 30);
  --
  begin
    pay_status_processing_rule_bk2.update_status_process_rule_a
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_mode             =>  p_datetrack_mode
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_formula_id                 =>  p_formula_id
      ,p_comments                   =>  p_comments
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      ,p_formula_mismatch_warning   =>  l_formula_mismatch_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --

  hr_utility.set_location(l_proc, 40);
--
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
   --
  -- Set all output arguments
  --
  p_object_version_number      := l_object_version_number;
  p_effective_start_date       := l_effective_start_date;
  p_effective_end_date         := l_effective_end_date;
  p_formula_mismatch_warning   := l_formula_mismatch_warning ;
--
  hr_utility.set_location('Leaving :'||l_proc, 50);
exception
 WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO update_status_process_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_effective_start_date       := l_effective_start_date;
    p_effective_end_date         := l_effective_end_date;
    p_object_version_number      := l_temp_ovn;
    p_formula_mismatch_warning   := l_formula_mismatch_warning ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_status_process_rule;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    RAISE;
    --
end update_status_process_rule;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_status_process_rule >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_status_process_rule
  (p_validate                       in    boolean  default false
  ,p_effective_date                 in    date
  ,p_datetrack_mode                 in    varchar2
  ,p_status_processing_rule_id      in    number
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_status_process_rule';
  l_object_version_number pay_status_processing_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_status_processing_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_status_processing_rules_f.effective_end_date%TYPE;
  l_effective_date        date;
  l_temp_ovn              number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT delete_status_process_rule;
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_status_processing_rule_bk3.delete_status_process_rule_b
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_mode             =>  p_datetrack_mode
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_object_version_number      =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  pay_ppr_del.del
  ( p_effective_date               => l_effective_date
  ,p_datetrack_mode                => p_datetrack_mode
  ,p_status_processing_rule_id     => p_status_processing_rule_id
  ,p_object_version_number         => l_object_version_number
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  hr_utility.set_location(l_proc, 30);
  --
  begin
    pay_status_processing_rule_bk3.delete_status_process_rule_a
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_mode             =>  p_datetrack_mode
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STATUS_PROCESS_RULE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISED
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO delete_status_process_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;
    p_object_version_number := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_status_process_rule;
    -- Reset IN OUT parameters and set OUT parameters.
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    RAISE;
    --
END delete_status_process_rule;
--

END pay_status_processing_rule_api;

/
