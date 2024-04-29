--------------------------------------------------------
--  DDL for Package Body PAY_IE_PRSI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PRSI_API" as
/* $Header: pysidapi.pkb 115.2 2002/12/06 14:46:25 jford noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_ie_prsi_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_update_mode >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION find_update_mode
   (p_period_end_date        in date
   ,p_prsi_details_id        in number) RETURN VARCHAR2 IS
   --
   --
   CURSOR prsi_csr IS
      SELECT hr_api.g_update_change_insert update_mode
      FROM pay_ie_prsi_details_f
      WHERE prsi_details_id = p_prsi_details_id
      AND effective_start_date > p_period_end_date;
   --
   l_mode VARCHAR2(30);
Begin
   --
   OPEN prsi_csr;
   FETCH prsi_csr INTO l_mode;
   --
   IF prsi_csr%notfound THEN
      l_mode := hr_api.g_update;
   END IF;
   CLOSE prsi_csr;
   --
   RETURN l_mode;
End find_update_mode;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ie_prsi_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_prsi_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_contribution_class            in     varchar2
  ,p_overridden_subclass           in     varchar2 default  Null
  ,p_soc_ben_flag                  in     varchar2 default  Null
  ,p_soc_ben_start_date            in     date     default  Null
  ,p_overridden_ins_weeks          in     number   default  Null
  ,p_non_standard_ins_weeks        in     number   default  Null
  ,p_exemption_start_date          in     date     default  Null
  ,p_exemption_end_date            in     date     default  Null
  ,p_cert_issued_by                in     varchar2 default  Null
  ,p_director_flag                 in     varchar2 default  Null
  ,p_community_flag                in     varchar2 default  Null
  ,p_prsi_details_id               out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
    ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR period_csr IS
     SELECT ptp.start_date, ptp.end_Date
     FROM   per_time_periods ptp, per_all_assignments_f paa
     WHERE  paa.assignment_id = p_assignment_id
     AND    paa.payroll_id = ptp.payroll_id
     AND    p_effective_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  period_rec period_csr%ROWTYPE;
  --
  l_flag VARCHAR2(30);
  l_proc                varchar2(72) := g_package||'create_ie_prsi_details';
  l_exemption_start_date date;
  l_exemption_end_date   date;
  l_prsi_details_id        number;
  l_object_version_number  number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_dummy_start_date       date;
  l_dummy_end_date         date;
  l_request_id             number;
  l_program_id             number;
  l_prog_appl_id           number;
  l_business_group_id      number;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = p_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  --
begin
  --
  -- Issue a savepoint
  --
  savepoint create_ie_prsi_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_exemption_start_date := trunc(p_exemption_start_date);
  l_exemption_end_date   := trunc(p_exemption_end_date);
  --
  -- Get business_group_id
  --
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_ie_prsi_bk1.create_ie_prsi_details_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_contribution_class            => p_contribution_class
      ,p_overridden_subclass           => p_overridden_subclass
      ,p_soc_ben_flag                  => p_soc_ben_flag
      ,p_soc_ben_start_date            => p_soc_ben_start_date
      ,p_overridden_ins_weeks          => p_overridden_ins_weeks
      ,p_non_standard_ins_weeks        => p_non_standard_ins_weeks
      ,p_exemption_start_date          => l_exemption_start_date
      ,p_exemption_end_date            => l_exemption_end_date
      ,p_cert_issued_by                => p_cert_issued_by
      ,p_director_flag                 => p_director_flag
      ,p_community_flag                => p_community_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ie_prsi_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set parameter values
  --
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
  --
  -- Insert record in pay_ie_prsi_details_f
  --
  pay_sid_ins.ins
      ( p_effective_date                 =>  p_effective_date
       ,p_assignment_id                  =>  p_assignment_id
       ,p_contribution_class             =>  p_contribution_class
       ,p_overridden_subclass            =>  p_overridden_subclass
       ,p_soc_ben_flag                   =>  p_soc_ben_flag
       ,p_soc_ben_start_date             =>  p_soc_ben_start_date
       ,p_overridden_ins_weeks           =>  p_overridden_ins_weeks
       ,p_non_standard_ins_weeks         =>  p_non_standard_ins_weeks
       ,p_exemption_start_date           =>  l_exemption_start_date
       ,p_exemption_end_date             =>  l_exemption_end_date
       ,p_cert_issued_by                 =>  p_cert_issued_by
       ,p_director_flag                  =>  p_director_flag
       ,p_community_flag                 =>  p_community_flag
       ,p_request_id                     =>  l_request_id
       ,p_program_application_id         =>  l_prog_appl_id
       ,p_program_id                     =>  l_program_id
       ,p_program_update_date            =>  sysdate
       ,p_prsi_details_id                =>  l_prsi_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       );
  --
  -- Get Start and End Date of current period
  OPEN period_csr;
  FETCH period_csr INTO period_rec;
  CLOSE period_csr;
  --
  -- Check if overridden number of insurable weeks need to be updated to null
  IF (p_overridden_ins_weeks IS NOT NULL)
         AND (period_rec.end_date IS NOT NULL)
         AND (l_effective_end_date > period_rec.end_date ) THEN
     --
     -- Lock above inserted row to refresh g_old_rec of row handler
     --
     DECLARE
        l_validation_start_date date;
        l_validation_end_date   date;
     BEGIN
        pay_sid_shd.lck
            ( p_effective_date                 =>  period_rec.end_date+1
             ,p_datetrack_mode                 =>  hr_api.g_update
             ,p_prsi_details_id                =>  l_prsi_details_id
             ,p_object_version_number          =>  l_object_version_number
             ,p_validation_start_date          =>  l_validation_start_date
             ,p_validation_end_date            =>  l_validation_end_date );
     END;
     --
     -- Update prsi details as of the begining of next pay period
     --
     pay_sid_upd.upd
         ( p_effective_date                 =>  period_rec.end_date+1
          ,p_datetrack_mode                 =>  hr_api.g_update
          ,p_prsi_details_id                =>  l_prsi_details_id
          ,p_object_version_number          =>  l_object_version_number
          ,p_assignment_id                  =>  p_assignment_id
          ,p_contribution_class             =>  p_contribution_class
          ,p_overridden_subclass            =>  p_overridden_subclass
          ,p_soc_ben_flag                   =>  p_soc_ben_flag
          ,p_soc_ben_start_date             =>  p_soc_ben_start_date
          ,p_overridden_ins_weeks           =>  NULL
          ,p_non_standard_ins_weeks         =>  p_non_standard_ins_weeks
          ,p_exemption_start_date           =>  l_exemption_start_date
          ,p_exemption_end_date             =>  l_exemption_end_date
          ,p_cert_issued_by                 =>  p_cert_issued_by
          ,p_director_flag                  =>  p_director_flag
          ,p_community_flag                 =>  p_community_flag
          ,p_request_id                     =>  l_request_id
          ,p_program_application_id         =>  l_prog_appl_id
          ,p_program_id                     =>  l_program_id
          ,p_program_update_date            =>  sysdate
          ,p_effective_start_date           =>  l_dummy_start_date
          ,p_effective_end_date             =>  l_dummy_end_date
          );
     -- set out variables
     l_object_version_number := l_object_version_number - 1;
     l_effective_end_date := period_rec.end_date;
  END IF;
  --
  -- Call After Process User Hook
  --
  begin
     pay_ie_prsi_bk1.create_ie_prsi_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_contribution_class            => p_contribution_class
      ,p_overridden_subclass           => p_overridden_subclass
      ,p_soc_ben_flag                  => p_soc_ben_flag
      ,p_soc_ben_start_date            => p_soc_ben_start_date
      ,p_overridden_ins_weeks          => p_overridden_ins_weeks
      ,p_non_standard_ins_weeks        => p_non_standard_ins_weeks
      ,p_exemption_start_date          => l_exemption_start_date
      ,p_exemption_end_date            => l_exemption_end_date
      ,p_cert_issued_by                => p_cert_issued_by
      ,p_director_flag                 => p_director_flag
      ,p_community_flag                => p_community_flag
      ,p_prsi_details_id               => l_prsi_details_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ie_prsi_details'
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
  p_prsi_details_id        := l_prsi_details_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ie_prsi_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prsi_details_id        := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ie_prsi_details;
    p_object_version_number      := l_object_version_number;
    p_effective_start_date       := null;
    p_effective_end_date         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ie_prsi_details;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ie_prsi_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ie_prsi_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_contribution_class            in     varchar2 default hr_api.g_varchar2
  ,p_overridden_subclass           in     varchar2 default hr_api.g_varchar2
  ,p_soc_ben_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_soc_ben_start_date            in     date     default hr_api.g_date
  ,p_overridden_ins_weeks          in     number   default hr_api.g_number
  ,p_non_standard_ins_weeks        in     number   default hr_api.g_number
  ,p_exemption_start_date          in     date     default hr_api.g_date
  ,p_exemption_end_date            in     date     default hr_api.g_date
  ,p_cert_issued_by                in     varchar2 default hr_api.g_varchar2
  ,p_director_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_community_flag                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_ie_prsi_details';
  l_exemption_start_date date;
  l_exemption_end_date   date;
  l_object_version_number  number := p_object_version_number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_dummy_start_date       date;
  l_dummy_end_Date         date;
  l_request_id             number;
  l_program_id             number;
  l_prog_appl_id           number;
  l_p45_effective_date     date;
  l_assignment_id          number;
  l_business_group_id      number;
  l_update_mode            varchar2(30);
  --
  CURSOR asg_csr IS
  SELECT assignment_id
  FROM   pay_ie_prsi_details_f
  WHERE  prsi_details_id = p_prsi_details_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = l_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR period_csr IS
     SELECT ptp.start_date, ptp.end_Date
     FROM   per_time_periods ptp, per_all_assignments_f paa
     WHERE  paa.assignment_id = l_assignment_id
     AND    paa.payroll_id = ptp.payroll_id
     AND    p_effective_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  period_rec period_csr%ROWTYPE;
  --
  --
begin
  --
  -- Issue a savepoint
  --
  savepoint update_ie_prsi_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_exemption_start_date := trunc(p_exemption_start_date);
  l_exemption_end_date := trunc(p_exemption_end_date);
  --
  -- Get assignment_id from the cursor
  OPEN asg_csr;
  FETCH asg_csr INTO l_assignment_id;
  CLOSE asg_csr;
  --
  -- Get Business Group Id
  --
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_ie_prsi_bk2.update_ie_prsi_details_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_business_group_id             => l_business_group_id
      ,p_prsi_details_id               => p_prsi_details_id
      ,p_contribution_class            => p_contribution_class
      ,p_overridden_subclass           => p_overridden_subclass
      ,p_soc_ben_flag                  => p_soc_ben_flag
      ,p_soc_ben_start_date            => p_soc_ben_start_date
      ,p_overridden_ins_weeks          => p_overridden_ins_weeks
      ,p_non_standard_ins_weeks        => p_non_standard_ins_weeks
      ,p_exemption_start_date          => p_exemption_start_date
      ,p_exemption_end_date            => p_exemption_end_date
      ,p_cert_issued_by                => p_cert_issued_by
      ,p_director_flag                 => p_director_flag
      ,p_community_flag                => p_community_flag
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ie_prsi_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set parameter values
  --
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
  --
  -- Call row handler procedure to update prsi details
  --
  pay_sid_upd.upd
      ( p_effective_date                 =>  p_effective_date
       ,p_datetrack_mode                 =>  p_datetrack_update_mode
       ,p_prsi_details_id                =>  p_prsi_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_assignment_id                  =>  l_assignment_id
       ,p_contribution_class             =>  p_contribution_class
       ,p_overridden_subclass            =>  p_overridden_subclass
       ,p_soc_ben_flag                   =>  p_soc_ben_flag
       ,p_soc_ben_start_date             =>  p_soc_ben_start_date
       ,p_overridden_ins_weeks           =>  p_overridden_ins_weeks
       ,p_non_standard_ins_weeks         =>  p_non_standard_ins_weeks
       ,p_exemption_start_date           =>  p_exemption_start_date
       ,p_exemption_end_date             =>  p_exemption_end_date
       ,p_cert_issued_by                 =>  p_cert_issued_by
       ,p_director_flag                  =>  p_director_flag
       ,p_community_flag                 =>  p_community_flag
       ,p_request_id                     =>  l_request_id
       ,p_program_application_id         =>  l_prog_appl_id
       ,p_program_id                     =>  l_program_id
       ,p_program_update_date            =>  sysdate
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       );
  --
  -- Get Start and End Date of current period
  OPEN period_csr;
  FETCH period_csr INTO period_rec;
  CLOSE period_csr;
  --
  -- Check if overridden_ins_weeks needs to be set to null as of next pay period
  IF (p_overridden_ins_weeks IS NOT NULL)
         AND (period_rec.end_date IS NOT NULL)
         AND (l_effective_end_date > period_rec.end_date ) THEN
     --
     -- Set datetrack update mode to UPDATE if future rows don't exist
     -- else set it to UPDATE_CHANGE_INSERT
     --
     l_update_mode := find_update_mode( p_period_end_date => period_rec.end_date
                          ,p_prsi_details_id => p_prsi_details_id );
     --
     -- Lock row to refresh g_old_rec of row handler
     --
     DECLARE
        l_validation_start_date date;
        l_validation_end_date   date;
     BEGIN
        pay_sid_shd.lck
            ( p_effective_date                 =>  period_rec.end_date+1
             ,p_datetrack_mode                 =>  l_update_mode
             ,p_prsi_details_id                =>  p_prsi_details_id
             ,p_object_version_number          =>  l_object_version_number
             ,p_validation_start_date          =>  l_validation_start_date
             ,p_validation_end_date            =>  l_validation_end_date );
     END;
     --
     -- Update record in the table
     pay_sid_upd.upd
         ( p_effective_date                 =>  period_rec.end_date+1
          ,p_datetrack_mode                 =>  l_update_mode
          ,p_prsi_details_id                =>  p_prsi_details_id
          ,p_object_version_number          =>  l_object_version_number
          ,p_assignment_id                  =>  l_assignment_id
          ,p_contribution_class             =>  p_contribution_class
          ,p_overridden_subclass            =>  p_overridden_subclass
          ,p_soc_ben_flag                   =>  p_soc_ben_flag
          ,p_soc_ben_start_date             =>  p_soc_ben_start_date
          ,p_overridden_ins_weeks           =>  NULL
          ,p_non_standard_ins_weeks         =>  p_non_standard_ins_weeks
          ,p_exemption_start_date           =>  p_exemption_start_date
          ,p_exemption_end_date             =>  p_exemption_end_date
          ,p_cert_issued_by                 =>  p_cert_issued_by
          ,p_director_flag                  =>  p_director_flag
          ,p_community_flag                 =>  p_community_flag
          ,p_request_id                     =>  l_request_id
          ,p_program_application_id         =>  l_prog_appl_id
          ,p_program_id                     =>  l_program_id
          ,p_program_update_date            =>  sysdate
          ,p_effective_start_date           =>  l_dummy_start_date
          ,p_effective_end_date             =>  l_dummy_end_date
          );
     --
     -- set out variables
     l_object_version_number := l_object_version_number - 1;
     l_effective_end_date := period_rec.end_date;
  END IF;
  --
  -- Get Start and End Date of current period

  -- Call After Process User Hook
  --
  begin
     pay_ie_prsi_bk2.update_ie_prsi_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_prsi_details_id               => p_prsi_details_id
      ,p_contribution_class            => p_contribution_class
      ,p_overridden_subclass           => p_overridden_subclass
      ,p_soc_ben_flag                  => p_soc_ben_flag
      ,p_soc_ben_start_date            => p_soc_ben_start_date
      ,p_overridden_ins_weeks          => p_overridden_ins_weeks
      ,p_non_standard_ins_weeks        => p_non_standard_ins_weeks
      ,p_exemption_start_date          => p_exemption_start_date
      ,p_exemption_end_date            => p_exemption_end_date
      ,p_cert_issued_by                => p_cert_issued_by
      ,p_director_flag                 => p_director_flag
      ,p_community_flag                => p_community_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ie_prsi_details'
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
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ie_prsi_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value
    -- therefore no need to reset p_object_version_number
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ie_prsi_details;
    p_object_version_number      := l_object_version_number;
    p_effective_start_date       := null;
    p_effective_end_date         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ie_prsi_details;

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ie_prsi_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_prsi_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ) IS
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_ie_prsi_details';
  l_object_version_number  number := p_object_version_number;
  l_effective_start_date   date;
  l_effective_end_Date     date;
  l_p45_effective_date     date;
  l_assignment_id          number;
  l_business_group_id      number;
  --
  CURSOR asg_csr IS
  SELECT assignment_id
  FROM   pay_ie_prsi_details_f
  WHERE  prsi_details_id = p_prsi_details_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = l_assignment_id
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  --
begin
  --
  -- Issue a savepoint
  --
  savepoint delete_ie_prsi_details;
  --
  -- Get assignment_id from the cursor
  OPEN asg_csr;
  FETCH asg_csr INTO l_assignment_id;
  CLOSE asg_csr;
  --
  -- Get Business_group_id
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    pay_ie_prsi_bk3.delete_ie_prsi_details_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_business_group_id             => l_business_group_id
      ,p_prsi_details_id               => p_prsi_details_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ie_prsi_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Call row handler procedure to update prsi details
  --
      pay_sid_del.del
      ( p_effective_date                 =>  p_effective_date
       ,p_datetrack_mode                 =>  p_datetrack_delete_mode
       ,p_prsi_details_id                =>  p_prsi_details_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       );
  --
  --
  -- Call After Process User Hook
  --
  begin
     pay_ie_prsi_bk3.delete_ie_prsi_details_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => l_business_group_id
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_prsi_details_id               => p_prsi_details_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ie_prsi_details'
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
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ie_prsi_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value therefore
    -- no need to set p_object_version_number
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ie_prsi_details;
    p_object_version_number      := l_object_version_number;
    p_effective_start_date       := null;
    p_effective_end_date         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ie_prsi_details;

end pay_ie_prsi_api;

/
