--------------------------------------------------------
--  DDL for Package Body PAY_IE_SB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_SB_API" as
/* $Header: pyisbapi.pkb 115.4 2002/12/16 17:47:54 dsaxby ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_ie_sb_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_sb_details >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_sb_details
  (p_validate                       in      boolean     default false
  ,p_effective_date                 in      date
  ,p_assignment_id                  in      number
  ,p_absence_start_date             in      date
  ,p_absence_end_date               in      date
  ,p_benefit_amount                 in      number
  ,p_benefit_type                   in      varchar2
  ,p_calculation_option             in      varchar2
  ,p_reduced_tax_credit             in      number      default null
  ,p_reduced_standard_cutoff        in      number      default null
  ,p_incident_id                    in      number      default null
  ,p_social_benefit_id              out     nocopy number
  ,p_object_version_number          out     nocopy number
  ,p_effective_start_date           out     nocopy date
  ,p_effective_end_date             out     nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
    l_flag                      varchar2(30);
    l_object_version_number     number;
    l_effective_start_date      date;
    l_effective_end_Date        date;
    l_dummy_start_date          date;
    l_dummy_end_date            date;
    l_request_id                number;
    l_program_id                number;
    l_prog_appl_id              number;
    l_business_group_id         number;
    l_social_benefit_id         number;
    l_effective_date            date;
    l_absence_start_date        date;
    l_absence_end_date          date;
    l_proc                      varchar2(72) := g_package||'create_ie_sb_details';
    CURSOR business_group_csr IS
        SELECT business_group_id
        FROM   per_all_assignments_f
        WHERE  assignment_id = p_assignment_id
        AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
    --
    l_benefit_amount        pay_ie_social_benefits_f.benefit_amount%type    := p_benefit_amount;
    l_benefit_type          pay_ie_social_benefits_f.benefit_type%type      := p_benefit_type;
    l_incident_id           pay_ie_social_benefits_f.incident_id%type       := p_incident_id;
    --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ie_sb_details;
  --
  -- Truncate the time portion from all IN date parameters
    l_effective_date        :=  trunc(p_effective_date);
    l_absence_start_date    :=  trunc(p_absence_start_date);
    l_absence_end_date      :=  trunc(p_absence_end_date);
  -- Call Before Process User Hook
  --
    OPEN business_group_csr;
    FETCH business_group_csr INTO l_business_group_id;
    CLOSE business_group_csr;
  --
 if p_calculation_option = 'IE_OPTION0' then
    l_absence_start_date    :=  null;
    l_absence_end_date      :=  null;
    l_benefit_amount        :=  0;
    l_benefit_type          :=  null;
    l_benefit_type          :=  null;
    l_incident_id           :=  null;
 end if;

    begin
       pay_ie_sb_api_bk1.create_ie_sb_details_b
         (p_effective_date                  =>  l_effective_date
         ,p_business_group_id               =>  l_business_group_id
          ,p_assignment_id                  =>  p_assignment_id
         ,p_absence_start_date              =>  l_absence_start_date
         ,p_absence_end_date                =>  l_absence_end_date
         ,p_benefit_amount                  =>  l_benefit_amount
         ,p_benefit_type                    =>  l_benefit_type
         ,p_calculation_option              =>  p_calculation_option
         ,p_reduced_tax_credit              =>  p_reduced_tax_credit
         ,p_reduced_standard_cutoff         =>  p_reduced_standard_cutoff
         ,p_incident_id                     =>  l_incident_id
         );
    exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
           (p_module_name => 'create_ie_sb_details_f'
           ,p_hook_type   => 'BP'
           );
    end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
    pay_isb_ins.ins
    (p_effective_date           => l_effective_date
    ,p_assignment_id            => p_assignment_id
    ,p_absence_start_date       => l_absence_start_date
    ,p_absence_end_date         => l_absence_end_date
    ,p_benefit_amount           => l_benefit_amount
    ,p_benefit_type             => l_benefit_type
    ,p_calculation_option       => p_calculation_option
    ,p_incident_id              => l_incident_id
    ,p_request_id               => l_request_id
    ,p_program_application_id   => l_prog_appl_id
    ,p_program_id               => l_program_id
    ,p_program_update_date      => sysdate
    ,p_reduced_tax_credit       => p_reduced_tax_credit
    ,p_reduced_standard_cutoff  => p_reduced_standard_cutoff
    ,p_social_benefit_id        => l_social_benefit_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    );
-- Call After Process User Hook
  --
  begin
    pay_ie_sb_api_bk1.create_ie_sb_details_a
    (p_effective_date           =>  l_effective_date
    ,p_business_group_id        =>  l_business_group_id
    ,p_assignment_id            =>  p_assignment_id
    ,p_absence_start_date       =>  l_absence_start_date
    ,p_absence_end_date         =>  l_absence_end_date
    ,p_benefit_amount           =>  l_benefit_amount
    ,p_benefit_type             =>  l_benefit_type
    ,p_calculation_option       =>  p_calculation_option
    ,p_reduced_tax_credit       =>  p_reduced_tax_credit
    ,p_reduced_standard_cutoff  =>  p_reduced_standard_cutoff
    ,p_incident_id              =>  l_incident_id
    ,p_social_benefit_id        =>  l_social_benefit_id
    ,p_object_version_number    =>  l_object_version_number
    ,p_effective_start_date     =>  l_effective_start_date
    ,p_effective_end_date       =>  l_effective_end_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ie_sb_details_f'
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
  p_social_benefit_id      := l_social_benefit_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_Date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ie_sb_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_social_benefit_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ie_sb_details;
    p_social_benefit_id     := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ie_sb_details;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ie_sb_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ie_sb_details
  (p_validate                       in      boolean     default false
  ,p_effective_date                 in      date
  ,p_datetrack_update_mode          in      varchar2
  ,p_absence_start_date             in      date        default hr_api.g_date
  ,p_absence_end_date               in      date        default hr_api.g_date
  ,p_benefit_amount                 in      number      default hr_api.g_number
  ,p_benefit_type                   in      varchar2    default hr_api.g_varchar2
  ,p_calculation_option             in      varchar2    default hr_api.g_varchar2
  ,p_reduced_tax_credit             in      number      default hr_api.g_number
  ,p_reduced_standard_cutoff        in      number      default hr_api.g_number
  ,p_incident_id                    in      number      default hr_api.g_number
  ,p_social_benefit_id              in      number
  ,p_object_version_number          in out  nocopy number
  ,p_effective_start_date           out     nocopy date
  ,p_effective_end_date             out     nocopy date
  ) is
  l_proc                            varchar2(72) := g_package||'update_ie_sb_details';
  l_effective_date                  date;
  l_datetrack_update_mode           number;
  l_absence_start_date              date;
  l_absence_end_date                date;
  l_calculation_option              varchar2(30);
  l_social_benefit_id               number;
  l_object_version_number           number  :=  p_object_version_number;
  l_effective_start_date            date;
  l_effective_end_date              date;
  l_assignment_id                   number;
  l_business_group_id               number;
  l_update_mode                     varchar2(30);
  l_request_id                      number;
  l_prog_appl_id                    number;
  l_program_id                      number;
  --
        l_benefit_amount            pay_ie_social_benefits_f.benefit_amount%type            := p_benefit_amount;
        l_benefit_type              pay_ie_social_benefits_f.benefit_type%type              := p_benefit_type;
        l_incident_id               pay_ie_social_benefits_f.incident_id%type               := p_incident_id;
        l_reduced_tax_credit        pay_ie_social_benefits_f.reduced_tax_credit%type        := p_reduced_tax_credit;
        l_reduced_standard_cutoff   pay_ie_social_benefits_f.reduced_standard_cutoff%type   := p_reduced_standard_cutoff;

  --
    CURSOR asg_csr IS
        SELECT assignment_id,calculation_option
        FROM   pay_ie_social_benefits_f
        WHERE  social_benefit_id = p_social_benefit_id
        AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
    CURSOR business_group_csr IS
        SELECT business_group_id
        FROM   per_all_assignments_f
        WHERE  assignment_id = l_assignment_id
        AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
    t_calculation_option    pay_ie_social_benefits_f.calculation_option%type;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ie_sb_details;
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_effective_date            :=  trunc(p_effective_date);
    l_absence_start_date        :=  trunc(p_absence_start_date);
    l_absence_end_date          :=  trunc(p_absence_end_date);
    --
    -- Get assignment_id from the cursor
    OPEN asg_csr;
    FETCH asg_csr INTO l_assignment_id,t_calculation_option;
    CLOSE asg_csr;
    --
    -- Get Business Group Id
    --
    OPEN business_group_csr;
    FETCH business_group_csr INTO l_business_group_id;
    CLOSE business_group_csr;
     if p_calculation_option = 'IE_OPTION0' then
        l_absence_start_date        :=  null;
        l_absence_end_date          :=  null;
        l_benefit_amount            :=  0;
        l_benefit_type              :=  null;
        l_incident_id               :=  null;
        l_reduced_tax_credit        :=  0;
        l_reduced_standard_cutoff   :=  0;
     end if;

     if t_calculation_option is not null then
        if      t_calculation_option = 'IE_OPTION1' and
               (p_calculation_option = 'IE_OPTION2' or
                p_calculation_option = 'IE_OPTION3' or
                p_calculation_option = 'IE_OPTION4') then
              fnd_message.set_name('PAY', 'HR_IE_NO_VALID_CALC_OPTION');
              fnd_message.raise_error;
        elsif   t_calculation_option = 'IE_OPTION2' and
               (p_calculation_option = 'IE_OPTION1' or
                p_calculation_option = 'IE_OPTION3' or
                p_calculation_option = 'IE_OPTION4') then
              fnd_message.set_name('PAY', 'HR_IE_NO_VALID_CALC_OPTION');
              fnd_message.raise_error;
        elsif   t_calculation_option = 'IE_OPTION3' and
               (p_calculation_option = 'IE_OPTION1' or
                p_calculation_option = 'IE_OPTION2' or
                p_calculation_option = 'IE_OPTION4') then
              fnd_message.set_name('PAY', 'HR_IE_NO_VALID_CALC_OPTION');
              fnd_message.raise_error;
        elsif   t_calculation_option = 'IE_OPTION4' and
               (p_calculation_option = 'IE_OPTION1' or
                p_calculation_option = 'IE_OPTION2' or
                p_calculation_option = 'IE_OPTION3') then
              fnd_message.set_name('PAY', 'HR_IE_NO_VALID_CALC_OPTION');
              fnd_message.raise_error;
        end if;
     end if;
    --
    -- Call Before Process User Hook
    --
    begin
        pay_ie_sb_api_bk2.update_ie_sb_details_b
            (p_effective_date               =>  l_effective_date
            ,p_business_group_id            =>  l_business_group_id
            ,p_datetrack_update_mode        =>  p_datetrack_update_mode
            ,p_absence_start_date           =>  l_absence_start_date
            ,p_absence_end_date             =>  l_absence_end_date
            ,p_benefit_amount               =>  l_benefit_amount
            ,p_benefit_type                 =>  l_benefit_type
            ,p_calculation_option           =>  p_calculation_option
            ,p_reduced_tax_credit           =>  l_reduced_tax_credit
            ,p_reduced_standard_cutoff      =>  l_reduced_standard_cutoff
            ,p_incident_id                  =>  l_incident_id
            ,p_social_benefit_id            =>  p_social_benefit_id
            ,p_object_version_number        =>  l_object_version_number
            );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'update_ie_sb_details'
          ,p_hook_type   => 'BP'
          );
    end;
  --
  -- Set parameter values
  --
  l_request_id      :=  fnd_global.conc_request_id;
  l_prog_appl_id    :=  fnd_global.prog_appl_id;
  l_program_id      :=  fnd_global.conc_program_id;
  --
  -- Call row handler procedure to update prsi details
  --
  pay_isb_upd.upd
    (p_effective_date               =>  l_effective_date
    ,p_datetrack_mode               =>  p_datetrack_update_mode
    ,p_social_benefit_id            =>  p_social_benefit_id
    ,p_object_version_number        =>  l_object_version_number
    ,p_assignment_id                =>  l_assignment_id
    ,p_absence_start_date           =>  l_absence_start_date
    ,p_absence_end_date             =>  l_absence_end_date
    ,p_benefit_amount               =>  l_benefit_amount
    ,p_benefit_type                 =>  l_benefit_type
    ,p_calculation_option           =>  p_calculation_option
    ,p_incident_id                  =>  l_incident_id
    ,p_request_id                   =>  l_request_id
    ,p_program_application_id       =>  l_prog_appl_id
    ,p_program_id                   =>  l_program_id
    ,p_program_update_date          =>  sysdate
    ,p_reduced_tax_credit           =>  l_reduced_tax_credit
    ,p_reduced_standard_cutoff      =>  l_reduced_standard_cutoff
    ,p_effective_start_date         =>  l_effective_start_date
    ,p_effective_end_date           =>  l_effective_end_date
    );

    begin
        pay_ie_sb_api_bk2.update_ie_sb_details_a
        (p_effective_date               =>  l_effective_date
        ,p_business_group_id            =>  l_business_group_id
        ,p_datetrack_update_mode        =>  p_datetrack_update_mode
        ,p_absence_start_date           =>  l_absence_start_date
        ,p_absence_end_date             =>  l_absence_end_date
        ,p_benefit_amount               =>  l_benefit_amount
        ,p_benefit_type                 =>  l_benefit_type
        ,p_calculation_option           =>  p_calculation_option
        ,p_reduced_tax_credit           =>  l_reduced_tax_credit
        ,p_reduced_standard_cutoff      =>  l_reduced_standard_cutoff
        ,p_incident_id                  =>  l_incident_id
        ,p_social_benefit_id            =>  p_social_benefit_id
        ,p_object_version_number        =>  l_object_version_number
        ,p_effective_start_date         =>  l_effective_start_date
        ,p_effective_end_date           =>  l_effective_end_date
        );
    exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'pay_ie_sb_api_bk2.update_ie_sb_details_a'
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
    --
    -- Set all output arguments
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := l_effective_start_date;
    p_effective_end_date     := l_effective_end_Date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ie_sb_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ie_sb_details;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ie_sb_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ie_social_benefits >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ie_sb_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_social_benefit_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  )
 is
    l_proc                          varchar2(72) := g_package||'delete_ie_social_benefits';
    l_assignment_id                 number;
    l_effective_date                date;
    l_business_group_id             number;
    l_social_benefit_id             number;
    l_object_version_number         number  := p_object_version_number;
    l_effective_start_date          date;
    l_effective_end_date            date;
    --
    CURSOR asg_csr IS
        SELECT assignment_id
        FROM   pay_ie_social_benefits_f
        WHERE  social_benefit_id = p_social_benefit_id
        AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
    --
    CURSOR business_group_csr IS
        SELECT business_group_id
        FROM   per_all_assignments_f
        WHERE  assignment_id = l_assignment_id
        AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ie_sb_details;
  --
  -- Get assignment_id from the cursor
  OPEN asg_csr;
  FETCH asg_csr INTO l_assignment_id;
  CLOSE asg_csr;
  -- Get Business_group_id
  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  --
  -- Call Before Process User Hook
  --
    begin
        pay_ie_sb_api_bk3.delete_ie_sb_details_b
          (p_effective_date                =>   p_effective_date
          ,p_business_group_id             =>   l_business_group_id
          ,p_datetrack_delete_mode         =>   p_datetrack_delete_mode
          ,p_social_benefit_id             =>   p_social_benefit_id
          ,p_object_version_number         =>   l_object_version_number
          );
    exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ie_sb_details'
        ,p_hook_type   => 'BP'
        );
    end;
      --
      -- Process Logic
      --
      -- Call row handler procedure to update prsi details
      --
          pay_isb_del.del
          (P_EFFECTIVE_DATE             =>  p_effective_date
          ,P_DATETRACK_MODE             =>  p_datetrack_delete_mode
          ,P_SOCIAL_BENEFIT_ID          =>  p_social_benefit_id
          ,P_OBJECT_VERSION_NUMBER      =>  l_object_version_number
          ,P_EFFECTIVE_START_DATE       =>  l_effective_start_date
          ,P_EFFECTIVE_END_DATE         =>  l_effective_end_date
          );
  --
  -- Call After Process User Hook
  --
        begin
        pay_ie_sb_api_bk3.delete_ie_sb_details_a
          (p_effective_date             =>  p_effective_date
          ,p_business_group_id          =>  l_business_group_id
          ,p_datetrack_delete_mode      =>  p_datetrack_delete_mode
          ,p_social_benefit_id          =>  p_social_benefit_id
          ,p_object_version_number      =>  l_object_version_number
          ,p_effective_start_date       =>  l_effective_start_date
          ,p_effective_end_date         =>  l_effective_end_date
          );
        exception
            when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
                (p_module_name => 'delete_ie_sb_details'
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
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ie_sb_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_Date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_ie_sb_details;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ie_sb_details;
end pay_ie_sb_api;

/
