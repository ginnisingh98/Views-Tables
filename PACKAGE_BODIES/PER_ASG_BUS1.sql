--------------------------------------------------------
--  DDL for Package Body PER_ASG_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_BUS1" as
/* $Header: peasgrhi.pkb 120.19.12010000.7 2009/11/20 09:42:17 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_asg_bus1.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_assignment_id            number        default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
  procedure set_security_group_id
   (
    p_assignment_id               in per_all_assignments_f.assignment_id%TYPE
   ,p_associated_column1                   in varchar2 default null
   ) is
  --
  -- Declare cursor
  --
   cursor csr_sec_grp is
    select pbg.security_group_id, pbg.legislation_code
     from per_business_groups_perf  pbg
      where  pbg.business_group_id =  (select distinct asg.business_group_id  from
                                     per_all_assignments_f    asg
                                    where asg.assignment_id  = p_assignment_id);

  --
  -- Local variables
  --
  l_security_group_id number;
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72) := g_package||'set_security_group_id';
  --
  begin
 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'assignment_id',
                             p_argument_value => p_assignment_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id, l_legislation_code;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    /*hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'ASSIGNMENT_ID')
       ); */
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  -- Set the sessions legislation context in HR_SESSION_DATA
  --
  hr_api.set_legislation_context(l_legislation_code);
  --
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 end if;
  --
end set_security_group_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, person_id, assignment_sequence, assignment_type,
--   period_of_service_id, primary_flag, or assignment_id) have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure check_non_updateable_args(p_rec in per_asg_shd.g_rec_type
                                   ,p_effective_date in date) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_asg_shd.api_updating
                (p_assignment_id          => p_rec.assignment_id
                ,p_object_version_number  => p_rec.object_version_number
                ,p_effective_date         => p_effective_date
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 6);
 end if;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_asg_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'BUSINESS_GROUP_ID'
       ,p_base_table => per_asg_shd.g_tab_nam
     );
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 7);
 end if;
  --
  if p_rec.assignment_id <> per_asg_shd.g_old_rec.assignment_id then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'ASSIGNMENT_ID'
       ,p_base_table => per_asg_shd.g_tab_nam
     );
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 8);
 end if;
  --
  if p_rec.person_id <> per_asg_shd.g_old_rec.person_id then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'PERSON_ID'
       ,p_base_table => per_asg_shd.g_tab_nam
     );
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 9);
 end if;
  --
  if p_rec.assignment_sequence <> per_asg_shd.g_old_rec.assignment_sequence then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'ASSIGNMENT_SEQUENCE'
       ,p_base_table => per_asg_shd.g_tab_nam
     );
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Bug fix 3101091 starts. Commenting out the check that makes vendor_id
  -- non updatable
  /* if p_rec.vendor_id <> per_asg_shd.g_old_rec.vendor_id then
    --
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'VENDOR_ID'
      ,p_base_table => per_asg_shd.g_tab_nam);
    --
  end if;  */
  -- End fix 3101091.
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
  --
end check_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec                         in per_asg_shd.g_rec_type,
     p_effective_date              in date,
     p_datetrack_mode              in varchar2,
     p_validation_start_date       in date,
     p_validation_end_date         in date,
     p_org_now_no_manager_warning  out nocopy boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     ---
     p_new_prim_ass_id             OUT nocopy number,
     p_prim_change_flag            OUT nocopy varchar2,
     p_new_end_date                OUT nocopy date,
     p_new_primary_flag            OUT nocopy varchar2,
     p_s_pay_id                    OUT nocopy number,
     p_cancel_atd                  OUT nocopy date,
     p_cancel_lspd                 OUT nocopy date,
     p_reterm_atd                  OUT nocopy date,
     p_reterm_lspd                 OUT nocopy date,
     ---
     p_appl_asg_new_end_date       OUT nocopy date  ) is
  --
  l_proc                   varchar2(72);
  --
  l_temp_flag                  boolean;
  l_org_now_no_manager_warning boolean;
  l_loc_change_tax_issues      boolean; --4888485 , all new declarations below
  l_delete_asg_budgets         boolean;
  l_element_salary_warning     boolean;
  l_element_entries_warning    boolean;
  l_spp_warning                boolean;
  l_cost_warning               boolean;
  l_life_events_exists         boolean;
  l_cobra_coverage_elements    boolean;
  l_assgt_term_elements        boolean;
  --
Begin
 if g_debug then
  l_proc:= g_package||'delete_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
 --
 -- 4888485 starts here
 --
 -- Bug 5012157 : Commented out BEN type assgt checks and moved the logic to API.
/* if per_asg_shd.g_old_rec.assignment_type = 'B' then
    if g_debug then
       hr_utility.set_location('Selected assignment is of type Benifits', 10);
    end if;
    --
    fnd_message.set_name('PER', 'HR_449746_DEL_BEN_ASG');
    fnd_message.raise_error;
 end if;
 -- */
 if g_debug then
    hr_utility.set_location('Before calling pre_delete checks ', 20);
 end if;
 --
 -- Added IF Condition for 5012244.
 if (p_datetrack_mode <> 'DELETE') THEN
 hr_assignment_internal.pre_delete
    (p_rec                        => p_rec,
     p_effective_date             => p_effective_date,
     p_datetrack_mode             => p_datetrack_mode,
     p_validation_start_date      => p_validation_start_date,
     p_validation_end_date        => p_validation_end_date,
     p_org_now_no_manager_warning => p_org_now_no_manager_warning,
     p_loc_change_tax_issues      => l_loc_change_tax_issues,
     p_delete_asg_budgets         => l_delete_asg_budgets,
     p_element_salary_warning     => l_element_salary_warning,
     p_element_entries_warning    => l_element_entries_warning,
     p_spp_warning                => l_spp_warning,
     P_cost_warning               => l_cost_warning,
     p_life_events_exists   	  => l_life_events_exists,
     p_cobra_coverage_elements    => l_cobra_coverage_elements,
     p_assgt_term_elements        => l_assgt_term_elements,
     ---
     p_new_prim_ass_id            => p_new_prim_ass_id,
     p_prim_change_flag           => p_prim_change_flag,
     p_new_end_date               => p_new_end_date,
     p_new_primary_flag           => p_new_primary_flag,
     p_s_pay_id                   => p_s_pay_id,
     p_cancel_atd                 => p_cancel_atd,
     p_cancel_lspd                => p_cancel_lspd,
     p_reterm_atd                 => p_reterm_atd,
     p_reterm_lspd                => p_reterm_lspd,
     ---
     p_appl_asg_new_end_date      => p_appl_asg_new_end_date );

     end if;
--
-- 4888485 Ends here
--
  per_asg_bus2.chk_system_pers_type
    (p_person_id              =>  per_asg_shd.g_old_rec.person_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_datetrack_mode         =>  p_datetrack_mode
    ,p_effective_date         =>  p_effective_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 6);
 end if;
  --
  per_asg_bus2.chk_ref_int_del
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_datetrack_mode         =>  p_datetrack_mode
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 7);
 end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 8);
 end if;
  --
  per_asg_bus1.chk_future_primary
    (p_assignment_id  =>  p_rec.assignment_id
    ,p_primary_flag   =>  per_asg_shd.g_old_rec.primary_flag
    ,p_datetrack_mode =>  p_datetrack_mode
    ,p_effective_date =>  p_effective_date

    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 9);
 end if;
  --
  per_asg_bus2.chk_term_status
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_datetrack_mode         =>  p_datetrack_mode
    ,p_validation_start_date  =>  p_validation_start_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Start changes for bug 8687386
  --
  per_asg_bus2.chk_dup_apl_vacancy
   (p_person_id              => p_rec.person_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_vacancy_id             => p_rec.vacancy_id
   ,p_effective_date         => p_effective_date
   ,p_assignment_type        => p_rec.assignment_type
   ,p_assignment_id          => p_rec.assignment_id
   ,p_validation_start_date  => p_validation_start_date
   ,p_validation_end_date    => p_validation_end_date
   ,p_datetrack_mode         => p_datetrack_mode
   );
  if g_debug then
   hr_utility.set_location(l_proc, 11);
  end if;
  -- End changes for bug 8687386
  --
  per_asg_bus1.dt_delete_validate

    (p_assignment_id        => p_rec.assignment_id
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date    => p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  per_asg_bus2.chk_payroll_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  per_asg_shd.g_old_rec.business_group_id
    ,p_person_id              =>  per_asg_shd.g_old_rec.person_id
    ,p_payroll_id             =>  per_asg_shd.g_old_rec.payroll_id
    ,p_assignment_type        =>  per_asg_shd.g_old_rec.assignment_type
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_datetrack_mode         =>  p_datetrack_mode
    ,p_payroll_id_updated     =>  l_temp_flag
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  per_asg_bus1.chk_del_organization_id
    (p_assignment_id              => p_rec.assignment_id
    ,p_effective_date             => p_effective_date
    ,p_manager_flag               => p_rec.manager_flag

    ,p_organization_id            => p_rec.organization_id
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  per_pqh_shr.per_asg_bus('DELETE_VALIDATE',
                p_rec,
                            p_effective_date,
                            p_validation_start_date,
                            p_validation_end_date,
                            p_datetrack_mode);
   p_org_now_no_manager_warning := l_org_now_no_manager_warning;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 11);
 end if;
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Pre Conditions:
--   This procedure is called from the delete_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_assignment_id        in number,
             p_datetrack_mode        in varchar2,
         p_validation_start_date    in date,
         p_validation_end_date    in date) Is
--
  l_proc    varchar2(72)     := g_package||'dt_delete_validate';
  l_rows_exist    Exception;
  l_table_name    all_tables.table_name%TYPE;
--
Begin
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'assignment_id',
       p_argument_value => p_assignment_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_cost_allocations_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'cost allocations';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_assignment_link_usages_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'assignment link usages';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_personal_payment_methods_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'personal payment methods';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'per_spinal_point_placements_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'spinal point placements';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_element_entries_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'element entries';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_us_emp_fed_tax_rules_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'us emp fed tax rules';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_us_emp_county_tax_rules_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'us emp county tax rules';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_us_emp_state_tax_rules_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'us emp state tax rules';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'pay_us_emp_city_tax_rules_f',
           p_base_key_column => 'assignment_id',
           p_base_key_value  => p_assignment_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'us emp city tax rules';
      Raise l_rows_exist;
    End If;
    --
  End If;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Pre Conditions:
--   This procedure is called from the update_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_payroll_id                    in number default hr_api.g_number,
             p_person_id                     in number default hr_api.g_number,
         p_datetrack_mode             in varchar2,
             p_validation_start_date         in date,
         p_validation_end_date         in date) Is
--
  l_proc        varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name        all_tables.table_name%TYPE;
--
Begin
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  --
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'validation_start_date',
     p_argument_value => p_validation_start_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'validation_end_date',
     p_argument_value => p_validation_end_date);
  --
  -- Start of fix 2535030
  /*
  If ((nvl(p_payroll_id, hr_api.g_number) <> hr_api.g_number) and
    NOT (dt_api.check_min_max_dates
          (p_base_table_name => 'pay_all_payrolls_f',   -- bug fix 2679167
           p_base_key_column => 'payroll_id',
           p_base_key_value  => p_payroll_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)))  Then
    l_table_name := 'payrolls';
    Raise l_integrity_error;
  End If;
  */
  -- End of fix 2535030

  If ((nvl(p_person_id, hr_api.g_number) <> hr_api.g_number) and
    NOT (dt_api.check_min_max_dates
          (p_base_table_name => 'per_all_people_f',
           p_base_key_column => 'person_id',
           p_base_key_value  => p_person_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)))  Then
    l_table_name := 'people';
    Raise l_integrity_error;
  End If;
  --
 if g_debug then
hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ---------------------------------------------------------------------------
procedure chk_df
  (p_rec              in per_asg_shd.g_rec_type
  ,p_validate_df_flex in boolean default true) is
--
  l_proc     varchar2(72);
--
begin
  --
 if g_debug then
  l_proc := g_package||'chk_df';
    hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
    --
    -- if inserting and not required to validate flex data
    -- then ensure all flex data passed is null
    --
      If ((p_rec.assignment_id is null) and
          (not p_validate_df_flex)) then
           --
           --
             If (not ( (p_rec.ass_attribute_category is null) and
                       (p_rec.ass_attribute1         is null) and
                       (p_rec.ass_attribute2         is null) and
                       (p_rec.ass_attribute3         is null) and
                       (p_rec.ass_attribute4         is null) and
                       (p_rec.ass_attribute5         is null) and
                       (p_rec.ass_attribute6         is null) and
                       (p_rec.ass_attribute7         is null) and
                       (p_rec.ass_attribute8         is null) and
                       (p_rec.ass_attribute9         is null) and
                       (p_rec.ass_attribute10        is null) and
                       (p_rec.ass_attribute11        is null) and
                       (p_rec.ass_attribute12        is null) and
                       (p_rec.ass_attribute13        is null) and
                       (p_rec.ass_attribute14        is null) and
                       (p_rec.ass_attribute15        is null) and
                       (p_rec.ass_attribute16        is null) and
                       (p_rec.ass_attribute17        is null) and
                       (p_rec.ass_attribute18        is null) and
                       (p_rec.ass_attribute19        is null) and
                       (p_rec.ass_attribute20        is null) and
                       (p_rec.ass_attribute21        is null) and
                       (p_rec.ass_attribute22        is null) and
                       (p_rec.ass_attribute23        is null) and
                       (p_rec.ass_attribute24        is null) and
                       (p_rec.ass_attribute25        is null) and
                       (p_rec.ass_attribute26        is null) and
                       (p_rec.ass_attribute27        is null) and
                       (p_rec.ass_attribute28        is null) and
                       (p_rec.ass_attribute29        is null) and
                       (p_rec.ass_attribute30        is null) ) )
                 then
                   hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
                   hr_utility.set_message_token('PROCEDURE','chk_df');
                   hr_utility.set_message_token('STEP',1);
                   hr_utility.raise_error;
             End if;
      End if;
      --
      --
      -- if   (    updating and flex data has changed
      --        OR updating and all flex segments are NULL)
      --   OR ( inserting and required to validate flexdata)
      -- then validate flex data.
      --
      --
      If (  (p_rec.assignment_id is not null)
             and
         (  (nvl(per_asg_shd.g_old_rec.ass_attribute_category, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute_category, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute1, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute1, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute2, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute2, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute3, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute3, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute4, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute4, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute5, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute5, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute6, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute6, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute7, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute7, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute8, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute8, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute9, hr_api.g_varchar2)  <>
             nvl(p_rec.ass_attribute9, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute10, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute10, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute11, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute11, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute12, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute12, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute13, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute13, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute14, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute14, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute15, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute15, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute16, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute16, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute17, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute17, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute18, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute18, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute19, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute19, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute20, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute20, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute21, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute21, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute22, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute22, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute23, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute23, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute24, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute24, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute25, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute25, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute26, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute26, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute27, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute27, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute28, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute28, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute29, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute29, hr_api.g_varchar2) or
             nvl(per_asg_shd.g_old_rec.ass_attribute30, hr_api.g_varchar2) <>
             nvl(p_rec.ass_attribute30, hr_api.g_varchar2)
            )
          or
            (
              (p_rec.ass_attribute_category is null) and
              (p_rec.ass_attribute1         is null) and
              (p_rec.ass_attribute2         is null) and
              (p_rec.ass_attribute3         is null) and
              (p_rec.ass_attribute4         is null) and
              (p_rec.ass_attribute5         is null) and
              (p_rec.ass_attribute6         is null) and
              (p_rec.ass_attribute7         is null) and
              (p_rec.ass_attribute8         is null) and
              (p_rec.ass_attribute9         is null) and
              (p_rec.ass_attribute10        is null) and
              (p_rec.ass_attribute11        is null) and
              (p_rec.ass_attribute12        is null) and
              (p_rec.ass_attribute13        is null) and
              (p_rec.ass_attribute14        is null) and
              (p_rec.ass_attribute15        is null) and
              (p_rec.ass_attribute16        is null) and
              (p_rec.ass_attribute17        is null) and
              (p_rec.ass_attribute18        is null) and
              (p_rec.ass_attribute19        is null) and
              (p_rec.ass_attribute20        is null) and
              (p_rec.ass_attribute21        is null) and
              (p_rec.ass_attribute22        is null) and
              (p_rec.ass_attribute23        is null) and
              (p_rec.ass_attribute24        is null) and
              (p_rec.ass_attribute25        is null) and
              (p_rec.ass_attribute26        is null) and
              (p_rec.ass_attribute27        is null) and
              (p_rec.ass_attribute28        is null) and
              (p_rec.ass_attribute29        is null) and
              (p_rec.ass_attribute30        is null)
            )
          ))
        --  or inserting and required to validate flex
        or
          ((p_rec.assignment_id is null) and
           (p_validate_df_flex))
           then
--
--           validate flex segment values
--
    hr_dflex_utility.ins_or_upd_descflex_attribs(
         p_appl_short_name      => 'PER'
        ,p_descflex_name        => 'PER_ASSIGNMENTS'
        ,p_attribute_category   => p_rec.ass_attribute_category
        ,p_attribute1_name      => 'ASS_ATTRIBUTE1'
        ,p_attribute1_value     => p_rec.ass_attribute1
        ,p_attribute2_name      => 'ASS_ATTRIBUTE2'
        ,p_attribute2_value     => p_rec.ass_attribute2
        ,p_attribute3_name      => 'ASS_ATTRIBUTE3'
        ,p_attribute3_value     => p_rec.ass_attribute3
        ,p_attribute4_name      => 'ASS_ATTRIBUTE4'
        ,p_attribute4_value     => p_rec.ass_attribute4
        ,p_attribute5_name      => 'ASS_ATTRIBUTE5'
        ,p_attribute5_value     => p_rec.ass_attribute5
        ,p_attribute6_name      => 'ASS_ATTRIBUTE6'
        ,p_attribute6_value     => p_rec.ass_attribute6
        ,p_attribute7_name      => 'ASS_ATTRIBUTE7'
        ,p_attribute7_value     => p_rec.ass_attribute7
        ,p_attribute8_name      => 'ASS_ATTRIBUTE8'
        ,p_attribute8_value     => p_rec.ass_attribute8
        ,p_attribute9_name      => 'ASS_ATTRIBUTE9'
        ,p_attribute9_value     => p_rec.ass_attribute9
        ,p_attribute10_name     => 'ASS_ATTRIBUTE10'
        ,p_attribute10_value    => p_rec.ass_attribute10
        ,p_attribute11_name     => 'ASS_ATTRIBUTE11'
        ,p_attribute11_value    => p_rec.ass_attribute11
        ,p_attribute12_name     => 'ASS_ATTRIBUTE12'
        ,p_attribute12_value    => p_rec.ass_attribute12
        ,p_attribute13_name     => 'ASS_ATTRIBUTE13'
        ,p_attribute13_value    => p_rec.ass_attribute13
        ,p_attribute14_name     => 'ASS_ATTRIBUTE14'
        ,p_attribute14_value    => p_rec.ass_attribute14
        ,p_attribute15_name     => 'ASS_ATTRIBUTE15'
        ,p_attribute15_value    => p_rec.ass_attribute15
        ,p_attribute16_name     => 'ASS_ATTRIBUTE16'
        ,p_attribute16_value    => p_rec.ass_attribute16
        ,p_attribute17_name     => 'ASS_ATTRIBUTE17'
        ,p_attribute17_value    => p_rec.ass_attribute17
        ,p_attribute18_name     => 'ASS_ATTRIBUTE18'
        ,p_attribute18_value    => p_rec.ass_attribute18
        ,p_attribute19_name     => 'ASS_ATTRIBUTE19'
        ,p_attribute19_value    => p_rec.ass_attribute19
        ,p_attribute20_name     => 'ASS_ATTRIBUTE20'
        ,p_attribute20_value    => p_rec.ass_attribute20
        ,p_attribute21_name     => 'ASS_ATTRIBUTE21'
        ,p_attribute21_value    => p_rec.ass_attribute21
        ,p_attribute22_name     => 'ASS_ATTRIBUTE22'
        ,p_attribute22_value    => p_rec.ass_attribute22
        ,p_attribute23_name     => 'ASS_ATTRIBUTE23'
        ,p_attribute23_value    => p_rec.ass_attribute23
        ,p_attribute24_name     => 'ASS_ATTRIBUTE24'
        ,p_attribute24_value    => p_rec.ass_attribute24
        ,p_attribute25_name     => 'ASS_ATTRIBUTE25'
        ,p_attribute25_value    => p_rec.ass_attribute25
        ,p_attribute26_name     => 'ASS_ATTRIBUTE26'
        ,p_attribute26_value    => p_rec.ass_attribute26
        ,p_attribute27_name     => 'ASS_ATTRIBUTE27'
        ,p_attribute27_value    => p_rec.ass_attribute27
        ,p_attribute28_name     => 'ASS_ATTRIBUTE28'
        ,p_attribute28_value    => p_rec.ass_attribute28
        ,p_attribute29_name     => 'ASS_ATTRIBUTE29'
        ,p_attribute29_value    => p_rec.ass_attribute29
        ,p_attribute30_name     => 'ASS_ATTRIBUTE30'
        ,p_attribute30_value    => p_rec.ass_attribute30
        );
  End if;
  --
 if g_debug then
  hr_utility.set_location('  Leaving:'||l_proc, 20);
 end if;
--
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
    (p_rec                in out nocopy  per_asg_shd.g_rec_type,
     p_effective_date           in  date,
     p_datetrack_mode           in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date           in  date,
         p_validate_df_flex            in  boolean,
         p_other_manager_warning       out nocopy boolean,
         p_hourly_salaried_warning     out nocopy boolean,
         p_inv_pos_grade_warning       out nocopy boolean
        ) is
  l_proc                    varchar2(72);
  l_temp_flag                   boolean;
  l_other_manager_warning       boolean;
  l_hourly_salaried_warning     boolean;
  L_inv_pos_grade_warning       boolean := false;
  L_inv_job_grade_warning       boolean := false;
  l_source_type per_all_assignments_f.source_type%TYPE default NULL;  --- Fix For Bug #7481310
--
Begin
 if g_debug then
  l_proc := g_package||'insert_validate';
  hr_utility.set_location('Entering: '||l_proc, 10);
 end if;
  --
  -- Validate Important Attributes
  --
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perasg.bru is provided (where
  -- relevant)
  --
  l_other_manager_warning := FALSE;
  l_hourly_salaried_warning := FALSE;
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_asg_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID'
    );
  --
  hr_multi_message.end_validation_set;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 15);
 end if;
  --
  --  per_asg_bus2.chk_title (p_title  =>  p_rec.title);
  --
  per_asg_bus2.chk_dup_apl_vacancy
   (p_person_id              => p_rec.person_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_vacancy_id             => p_rec.vacancy_id
   ,p_effective_date         => p_effective_date
   ,p_assignment_type        => p_rec.assignment_type
   );
 if g_debug then
  hr_utility.set_location(l_proc, 22);
 end if;
  --
  per_asg_bus2.chk_time_finish_formatted --#2734822
    (p_time_normal_finish => p_rec.time_normal_finish
    );
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  per_asg_bus2.chk_time_start_formatted --#2734822
    (p_time_normal_start => p_rec.time_normal_start
    );
 if g_debug then
  hr_utility.set_location(l_proc, 27);
 end if;
  --
  per_asg_bus1.chk_assignment_type
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_person_id             =>  p_rec.person_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  hr_multi_message.end_validation_set;
  --
  per_asg_bus2.chk_probation_unit
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_probation_unit        =>  p_rec.probation_unit
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  per_asg_bus2.chk_probation_period
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_probation_period      =>  p_rec.probation_period
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  per_asg_bus2.chk_prob_unit_prob_period
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_probation_unit                =>  p_rec.probation_unit
    ,p_probation_period              =>  p_rec.probation_period
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
 --- Fix For Bug # 7481310 Starts ---
if p_rec.assignment_type = 'O' then
 hr_utility.set_location(l_proc || 'This is an Offer Assignment', 60);

select source_type into l_source_type from per_all_assignments_f
where person_id = p_rec.person_id and BUSINESS_GROUP_ID = p_rec.business_group_id
and ASSIGNMENT_TYPE = 'A' and VACANCY_ID = p_rec.vacancy_id and
p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

end if;
--- Fix For Bug # 7481310 Ends ---

--- Fix For Bug # 7481310 Starts ---
if NOT (NVL(l_source_type,'IREC') = NVL(p_rec.source_type,'IREC') AND p_rec.assignment_type = 'O') then
  --
  per_asg_bus2.chk_source_type
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_source_type             =>  p_rec.source_type
    ,p_recruitment_activity_id =>  p_rec.recruitment_activity_id
    ,p_effective_date          =>  p_effective_date
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
end if;
--- Fix For Bug # 7481310 Ends ---
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  per_asg_bus1.chk_date_probation_end
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_date_probation_end     =>  p_rec.date_probation_end
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_probation_period       =>  p_rec.probation_period
    ,p_probation_unit         =>  p_rec.probation_unit
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  per_asg_bus2.chk_internal_address_line
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_internal_address_line  =>  p_rec.internal_address_line
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  per_asg_bus1.chk_change_reason
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_change_reason          =>  p_rec.change_reason
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  per_asg_bus1.chk_default_code_comb_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_default_code_comb_id   =>  p_rec.default_code_comb_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  per_asg_bus1.chk_employment_category
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_employment_category   =>  p_rec.employment_category
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
  --
  per_asg_bus2.chk_sal_review_period
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_sal_review_period             =>  p_rec.sal_review_period
    ,p_assignment_type               =>  p_rec.assignment_type
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
  --
  per_asg_bus2.chk_sal_review_period_freq
    (p_assignment_id                =>  p_rec.assignment_id
    ,p_sal_review_period_frequency  =>  p_rec.sal_review_period_frequency
    ,p_assignment_type              =>  p_rec.assignment_type
    ,p_effective_date               =>  p_effective_date
    ,p_validation_start_date        =>  p_validation_start_date
    ,p_validation_end_date          =>  p_validation_end_date
    ,p_object_version_number        =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 140);
 end if;
  --
  per_asg_bus2.chk_sal_rp_freq_sal_rp
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_sal_review_period_frequency   =>  p_rec.sal_review_period_frequency
    ,p_sal_review_period             =>  p_rec.sal_review_period
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 150);
 end if;
  --
  per_asg_bus2.chk_perf_review_period
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_perf_review_period            =>  p_rec.perf_review_period
    ,p_assignment_type               =>  p_rec.assignment_type
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 160);
 end if;
  --
  per_asg_bus2.chk_perf_review_period_freq
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_perf_review_period_frequency  =>  p_rec.perf_review_period_frequency
    ,p_assignment_type               =>  p_rec.assignment_type
    ,p_effective_date                =>  p_effective_date
    ,p_validation_start_date         =>  p_validation_start_date
    ,p_validation_end_date           =>  p_validation_end_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 170);
 end if;
  --
  per_asg_bus2.chk_perf_rp_freq_perf_rp
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_perf_review_period_frequency  =>  p_rec.perf_review_period_frequency
    ,p_perf_review_period            =>  p_rec.perf_review_period
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
  per_asg_bus1.chk_frequency
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_frequency               =>  p_rec.frequency
    ,p_effective_date          =>  p_effective_date
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  per_asg_bus1.chk_frequency_normal_hours
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_frequency               =>  p_rec.frequency
    ,p_normal_hours            =>  p_rec.normal_hours
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 200);
 end if;
  --
  per_asg_bus2.chk_set_of_books_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_set_of_books_id        =>  p_rec.set_of_books_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 210);
 end if;
  --
  per_asg_bus2.chk_source_organization_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_source_organization_id =>  p_rec.source_organization_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 230);
 end if;
  --
  per_asg_bus2.chk_soft_coding_keyflex_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_soft_coding_keyflex_id =>  p_rec.soft_coding_keyflex_id
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_payroll_id             =>  p_rec.payroll_id
    ,p_business_group_id      =>  p_rec.business_group_id
    );
 if g_debug then
  hr_utility.set_location(l_proc, 240);
 end if;
  --
  per_asg_bus2.chk_pay_basis_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_pay_basis_id          =>  p_rec.pay_basis_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 250);
 end if;
  --
  per_asg_bus2.chk_recruitment_activity_id
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_assignment_type         =>  p_rec.assignment_type
    ,p_business_group_id       =>  p_rec.business_group_id
    ,p_recruitment_activity_id =>  p_rec.recruitment_activity_id
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 260);
 end if;
  --
  per_asg_bus2.chk_vacancy_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 270);
 end if;
  --
  per_asg_bus1.chk_location_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_location_id           =>  p_rec.location_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 280);
 end if;
  --
  per_asg_bus2.chk_people_group_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_people_group_id        =>  p_rec.people_group_id
    ,p_vacancy_id             =>  p_rec.vacancy_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 290);
 end if;
  --
 if g_debug then
  hr_utility.set_location(p_validation_start_date, 290);
 end if;
 if g_debug then
  hr_utility.set_location(p_validation_end_date, 290);
 end if;
  per_asg_bus2.chk_position_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id           =>  p_rec.position_id
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 300);
 end if;
  -- fix for 6331872 starts here
  per_asg_bus1.chk_frozen_single_pos
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id           =>  p_rec.position_id
    ,p_effective_date        =>  p_effective_date
    ,p_assignment_type       =>  p_rec.assignment_type  -- parameter added for tbe bug#7685281
    );

 if g_debug then
  hr_utility.set_location(p_validation_end_date, 305);
 end if;
 -- fix for 6331872 ends here
  per_asg_bus1.chk_job_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_job_id                =>  p_rec.job_id
    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 310);
 end if;
  --
  per_asg_bus2.chk_position_id_job_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id           =>  p_rec.position_id
    ,p_job_id                =>  p_rec.job_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 320);
 end if;
  --
  per_asg_bus1.chk_grade_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_assignment_type          =>  p_rec.assignment_type
    ,p_grade_id                 =>  p_rec.grade_id
    ,p_vacancy_id               =>  p_rec.vacancy_id
    ,p_special_ceiling_step_id  =>  p_rec.special_ceiling_step_id
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 330);
 end if;
  --
  per_asg_bus2.chk_special_ceiling_step_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_assignment_type          =>  p_rec.assignment_type
    ,p_special_ceiling_step_id  =>  p_rec.special_ceiling_step_id
    ,p_grade_id                 =>  p_rec.grade_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 340);
 end if;
  --
  per_asg_bus2.chk_position_id_grade_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id           =>  p_rec.position_id
    ,p_grade_id              =>  p_rec.grade_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_inv_pos_grade_warning =>  l_inv_pos_grade_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 350);
 end if;
  --
  per_asg_bus1.chk_job_id_grade_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_job_id                 =>  p_rec.job_id
    ,p_grade_id               =>  p_rec.grade_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_inv_job_grade_warning  =>  l_inv_job_grade_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 360);
 end if;
  --
  per_asg_bus2.chk_person_id
    (p_person_id              =>  p_rec.person_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_effective_date         =>  p_effective_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 370);
 end if;
  --
  per_asg_bus2.chk_supervisor_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_supervisor_id          =>  p_rec.supervisor_id
    ,p_person_id              =>  p_rec.person_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 375);
 end if;
  --
  per_asg_bus2.chk_supervisor_assignment_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_supervisor_id            =>  p_rec.supervisor_id
    ,p_supervisor_assignment_id =>  p_rec.supervisor_assignment_id
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 380);
 end if;
  --
  per_asg_bus2.chk_person_referred_by_id
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_assignment_type         =>  p_rec.assignment_type
    ,p_person_id               =>  p_rec.person_id
    ,p_person_referred_by_id   =>  p_rec.person_referred_by_id
    ,p_business_group_id       =>  p_rec.business_group_id
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 390);
 end if;
  --
  per_asg_bus2.chk_recruiter_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_person_id              =>  p_rec.person_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_recruiter_id           =>  p_rec.recruiter_id
    ,p_vacancy_id             =>  p_rec.vacancy_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 400);
 end if;
  --
  per_asg_bus2.chk_period_of_service_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_person_id              =>  p_rec.person_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_period_of_service_id   =>  p_rec.period_of_service_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 405);
 end if;
  --
  per_asg_bus2.gen_assignment_sequence
    (p_assignment_type      =>  p_rec.assignment_type
    ,p_person_id            =>  p_rec.person_id
    ,p_assignment_sequence  =>  p_rec.assignment_sequence
    );
 if g_debug then
  hr_utility.set_location(l_proc, 410);
 end if;
  --
  per_asg_bus1.gen_chk_assignment_number
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_assignment_number      =>  p_rec.assignment_number
    ,p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 420);
 end if;
  --
  per_asg_bus2.chk_primary_flag
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_primary_flag          =>  p_rec.primary_flag
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_person_id             =>  p_rec.person_id
    ,p_period_of_service_id  =>  p_rec.period_of_service_id
   ,p_pop_date_start        =>  p_rec.period_of_placement_date_start
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 430);
 end if;
  --
per_asg_bus2.chk_applicant_rank
        (p_applicant_rank        =>  p_rec.applicant_rank
        ,p_assignment_type       =>  p_rec.assignment_type
        ,p_assignment_id         =>  p_rec.assignment_id
        ,p_object_version_number =>  p_rec.object_version_number
        ,p_effective_date        =>  p_effective_date);

per_asg_bus2.chk_posting_content_id
        (p_posting_content_id  =>  p_rec.posting_content_id
        ,p_assignment_type     =>  p_rec.assignment_type
        ,p_assignment_id       =>  p_rec.assignment_id
        ,p_object_version_number =>  p_rec.object_version_number
        ,p_effective_date      =>  p_effective_date);

  per_asg_bus1.chk_manager_flag
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_organization_id       =>  p_rec.organization_id
    ,p_manager_flag          =>  p_rec.manager_flag
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_other_manager_warning =>  l_other_manager_warning
    ,p_no_managers_warning   =>  l_temp_flag
    );
 if g_debug then
  hr_utility.set_location(l_proc, 440);
 end if;
  --
  per_asg_bus1.chk_organization_id
    (p_assignment_id               =>  p_rec.assignment_id
    ,p_primary_flag                =>  p_rec.primary_flag
    ,p_organization_id             =>  p_rec.organization_id
    ,p_business_group_id           =>  p_rec.business_group_id
    ,p_assignment_type             =>  p_rec.assignment_type
    ,p_vacancy_id                  =>  p_rec.vacancy_id
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    ,p_manager_flag                =>  p_rec.manager_flag
    ,p_org_now_no_manager_warning  =>  l_temp_flag
    ,p_other_manager_warning       =>  l_other_manager_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 450);
 end if;
  --
  per_asg_bus2.chk_position_id_org_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id           =>  p_rec.position_id
    ,p_organization_id       =>  p_rec.organization_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 460);
 end if;
  --
  per_asg_bus1.chk_application_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_application_id         =>  p_rec.application_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_validation_start_date  =>  p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 470);
 end if;
  --
  per_asg_bus2.chk_payroll_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_person_id              =>  p_rec.person_id
    ,p_payroll_id             =>  p_rec.payroll_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_datetrack_mode         =>  p_datetrack_mode
    ,p_payroll_id_updated     =>  l_temp_flag
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 490);
 end if;
  --
  per_asg_bus1.chk_assignment_status_type_id
    (p_rec                       => p_rec
    ,p_effective_date            => p_effective_date
    ,p_validation_start_date     => p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 500);
 end if;
--
 per_asg_bus1.chk_bargaining_unit_code
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_bargaining_unit_code  =>  p_rec.bargaining_unit_code
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 511);
 end if;
--
 per_asg_bus1.chk_hourly_salaried_code
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_hourly_salaried_code    =>  p_rec.hourly_salaried_code
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    ,p_pay_basis_id            =>  p_rec.pay_basis_id
    ,p_hourly_salaried_warning => l_hourly_salaried_warning
   ,p_assignment_type         => p_rec.assignment_type);
  --
  per_asg_bus1.chk_single_position
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id        =>  p_rec.position_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number => p_rec.object_version_number
    ,p_assignment_type       => p_rec.assignment_type
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 513);
 end if;
  per_asg_bus3.chk_contract_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_contract_id             => p_rec.contract_id
  ,p_person_id               => p_rec.person_id
  ,p_validation_start_date   => p_validation_start_date
  ,p_business_group_id       => p_rec.business_group_id
  ) ;
 if g_debug then
  hr_utility.set_location(l_proc, 515);
 end if;
  --
  per_asg_bus3.chk_establishment_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_establishment_id        => p_rec.establishment_id
  ,p_assignment_type         => p_rec.assignment_type
  ,p_business_group_id       => p_rec.business_group_id
   );
 if g_debug then
  hr_utility.set_location(l_proc, 520);
 end if;
  --
  per_asg_bus3.chk_collective_agreement_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ,p_business_group_id       => p_rec.business_group_id
  ,p_establishment_id        => p_rec.establishment_id
  );
 if g_debug then
  hr_utility.set_location(l_proc, 530);
 end if;
  --
  per_asg_bus3.chk_cagr_id_flex_num
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_cagr_id_flex_num        => p_rec.cagr_id_flex_num
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ) ;
 if g_debug then
  hr_utility.set_location(l_proc, 535);
 end if;
  --
  per_asg_bus3.chk_cagr_grade_def_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_cagr_grade_def_id       => p_rec.cagr_grade_def_id
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ,p_cagr_id_flex_num        => p_rec.cagr_id_flex_num
  );

  per_asg_bus3.chk_notice_period
  (p_assignment_id           => p_rec.assignment_id
  ,p_notice_period           => p_rec.notice_period
  );

  per_asg_bus3.chk_notice_period_uom
  (p_assignment_id           => p_rec.assignment_id
  ,p_notice_period_uom       => p_rec.notice_period_uom
  ,p_notice_period           => p_rec.notice_period
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );

  per_asg_bus3.chk_work_at_home
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_work_at_home      => p_rec.work_at_home
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );

  per_asg_bus3.chk_employee_category
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_employee_category       => p_rec.employee_category
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 600);
 end if;
  --
  per_asg_bus1.chk_assignment_category
    (p_assignment_id           => p_rec.assignment_id
    ,p_assignment_type         => p_rec.assignment_type
    ,p_effective_date          => p_effective_date
    ,p_assignment_category     => p_rec.assignment_category
    ,p_object_version_number   => p_rec.object_version_number
    ,p_validation_start_date   => p_validation_start_date
    ,p_validation_end_date     => p_validation_end_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 610);
 end if;
  --
  per_asg_bus3.chk_vendor_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_vendor_id              => p_rec.vendor_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 620);
 end if;
  --
  per_asg_bus3.chk_vendor_site_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 630);
 end if;
  --
  per_asg_bus3.chk_po_header_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_po_header_id           => p_rec.po_header_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 640);
 end if;
  --
  per_asg_bus3.chk_po_line_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 650);
 end if;
  --
  per_asg_bus3.chk_projected_assignment_end
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_effective_start_date     => p_rec.effective_start_date
    ,p_projected_assignment_end => p_rec.projected_assignment_end
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 660);
 end if;
  --
  per_asg_bus3.chk_vendor_id_site_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_vendor_id              => p_rec.vendor_id
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 670);
 end if;
  --
  per_asg_bus3.chk_po_header_id_line_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_po_header_id           => p_rec.po_header_id
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 680);
 end if;
  --
  per_asg_bus3.chk_vendor_po_match
    (p_assignment_id          => p_rec.assignment_id
    ,p_vendor_id              => p_rec.vendor_id
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_po_header_id           => p_rec.po_header_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 690);
 end if;
  --
  per_asg_bus3.chk_po_job_match
    (p_assignment_id          => p_rec.assignment_id
    ,p_job_id                 => p_rec.job_id
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 700);
 end if;
  --
  per_asg_bus3.chk_vendor_assignment_number
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_vendor_assignment_number => p_rec.vendor_assignment_number
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 710);
 end if;
  --
  per_asg_bus3.chk_vendor_employee_number
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_vendor_employee_number   => p_rec.vendor_employee_number
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 720);
 end if;
  --
  per_asg_bus3.chk_pop_date_start
    (p_assignment_id            => p_rec.assignment_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_person_id                => p_rec.person_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_pop_date_start           => p_rec.period_of_placement_date_start
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date
    ,p_effective_date           => p_effective_date
    ,p_object_version_number    => p_rec.object_version_number);
 --
 if g_debug then
  hr_utility.set_location(l_proc, 730);
 end if;
  --
  per_asg_bus3.chk_grade_ladder_pgm_id
    (p_grade_id               => p_rec.grade_id
    ,p_grade_ladder_pgm_id    => p_rec.grade_ladder_pgm_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_effective_date           => p_effective_date);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_asg_bus1.chk_df(p_rec               => p_rec
                     ,p_validate_df_flex  => p_validate_df_flex);
  --
  p_other_manager_warning := l_other_manager_warning;
  p_hourly_salaried_warning := l_hourly_salaried_warning;
  p_inv_pos_grade_warning := l_inv_pos_grade_warning;
  --
  --
  -- Call to validate Position Control Business Rules
  --
    per_pqh_shr.per_asg_bus('INSERT_VALIDATE',
                p_rec,
                            p_effective_date,
                            p_validation_start_date,
                            p_validation_end_date,
                            p_datetrack_mode);
  --
  -- End of call to Position Control Business Rules
  --
/*
  --
  -- Call to validate Position Control Business Rules
  --
  if (pqh_psf_bus.position_control_enabled
      ( p_organization_id => p_rec.organization_id
      , p_effective_date  => p_effective_date
      ) = 'Y') then
    pqh_psf_bus.per_asg_bus_insert_validate
         (p_position_id    => p_rec.position_id
         ,p_assignment_date   => p_effective_date
         ,p_assignment_grade_id  => p_rec.grade_id
         ,p_assignment_emp_cat   => p_rec.employment_category
         );
  end if;
  --
  -- End of call to Position Control Business Rules
  --
*/
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 740);
 end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
    (p_rec                in out nocopy  per_asg_shd.g_rec_type,

     p_effective_date           in  date,
     p_datetrack_mode           in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date           in   date,
         p_payroll_id_updated          out nocopy  boolean,
         p_other_manager_warning       out nocopy  boolean,
         p_hourly_salaried_warning     out nocopy  boolean,
         p_no_managers_warning         out nocopy  boolean,
         p_org_now_no_manager_warning  out nocopy  boolean,
         p_inv_pos_grade_warning       out nocopy  boolean
         ) is
--
  l_proc                   varchar2(72);
  l_temp_flag                  boolean;

  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  L_inv_pos_grade_warning      boolean := false;
  l_payroll_id_updated         boolean;
--
-- bug 4681211
l_api_updating boolean;
l_assignment_sequence number;
-- bug 4681211
--
Begin
 if g_debug then
  l_proc := g_package||'update_validate';
  hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perasg.bru is provided (where relevant).
  --
  l_other_manager_warning      := FALSE;
  l_hourly_salaried_warning    := FALSE;
  l_no_managers_warning        := FALSE;

  l_org_now_no_manager_warning := FALSE;
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_asg_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID'
    ); -- chk business group id
  --
  hr_multi_message.end_validation_set;
  --
  -- Check that the columns which cannot be updated
  -- have not changed
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID / c
  -- CHK_PERSON_ID / c
  -- GEN_ASSIGNMENT_SEQUENCE / c
  -- CHK_ASSIGNMENT_ID / e
  --
  per_asg_bus1.check_non_updateable_args
    (p_rec            => p_rec
    ,p_effective_date => p_effective_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  per_asg_bus2.chk_system_pers_type
    (p_person_id             =>  p_rec.person_id
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_datetrack_mode        =>  p_datetrack_mode
    ,p_effective_date        =>  p_effective_date

    );
 if g_debug then
  hr_utility.set_location(l_proc, 21);
 end if;
  --
  per_asg_bus2.chk_term_status
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_datetrack_mode        =>  p_datetrack_mode
    ,p_validation_start_date =>  p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 22);
 end if;
  --
  -- per_asg_bus2.chk_title(p_title  =>  p_rec.title);
  --
  per_asg_bus2.chk_time_finish_formatted --#2734822
    (p_time_normal_finish => p_rec.time_normal_finish
    );
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  -- Start changes for bug 8672114
  --
  per_asg_bus2.chk_dup_apl_vacancy
   (p_person_id              => p_rec.person_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_vacancy_id             => p_rec.vacancy_id
   ,p_effective_date         => p_effective_date
   ,p_assignment_type        => p_rec.assignment_type
   -- Start changes for bug 8687386
   ,p_assignment_id          => p_rec.assignment_id
   ,p_validation_start_date  => p_validation_start_date
   ,p_validation_end_date    => p_validation_end_date
   ,p_datetrack_mode         => p_datetrack_mode
   -- End changes for bug 8687386
   );
 if g_debug then
  hr_utility.set_location(l_proc, 26);
 end if;
  --
  -- End changes for bug 8672114
  --
  --
  per_asg_bus2.chk_time_start_formatted --#2734822
    (p_time_normal_start => p_rec.time_normal_start
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  per_asg_bus1.chk_assignment_type
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_person_id             =>  p_rec.person_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  per_asg_bus2.chk_probation_unit
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_probation_unit        =>  p_rec.probation_unit
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date

    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  per_asg_bus2.chk_probation_period
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_probation_period      =>  p_rec.probation_period
     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --

  per_asg_bus2.chk_prob_unit_prob_period
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_probation_unit                =>  p_rec.probation_unit
    ,p_probation_period              =>  p_rec.probation_period
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  per_asg_bus2.chk_source_type
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_source_type             =>  p_rec.source_type
    ,p_recruitment_activity_id =>  p_rec.recruitment_activity_id

    ,p_effective_date          =>  p_effective_date
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  per_asg_bus1.chk_date_probation_end
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_date_probation_end     =>  p_rec.date_probation_end
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_probation_period       =>  p_rec.probation_period
    ,p_probation_unit         =>  p_rec.probation_unit

    ,p_validation_start_date  =>  p_validation_start_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  per_asg_bus2.chk_internal_address_line
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_internal_address_line  =>  p_rec.internal_address_line
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );

 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  per_asg_bus1.chk_change_reason
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_change_reason          =>  p_rec.change_reason
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --

  per_asg_bus1.chk_default_code_comb_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_default_code_comb_id   =>  p_rec.default_code_comb_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  per_asg_bus1.chk_employment_category
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type

    ,p_employment_category   =>  p_rec.employment_category
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
  --
  per_asg_bus2.chk_sal_review_period
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_sal_review_period     =>  p_rec.sal_review_period
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_effective_date        =>  p_effective_date

    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
  --
  per_asg_bus2.chk_sal_review_period_freq
    (p_assignment_id                =>  p_rec.assignment_id
    ,p_sal_review_period_frequency  =>  p_rec.sal_review_period_frequency
    ,p_assignment_type              =>  p_rec.assignment_type
    ,p_effective_date               =>  p_effective_date
    ,p_validation_start_date        =>  p_validation_start_date
    ,p_validation_end_date          =>  p_validation_end_date
    ,p_object_version_number        =>  p_rec.object_version_number
    );

 if g_debug then
  hr_utility.set_location(l_proc, 140);
 end if;
  --
  per_asg_bus2.chk_sal_rp_freq_sal_rp
    (p_assignment_id               =>  p_rec.assignment_id
    ,p_sal_review_period_frequency =>  p_rec.sal_review_period_frequency
    ,p_sal_review_period           =>  p_rec.sal_review_period
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 150);
 end if;
  --
  per_asg_bus2.chk_perf_review_period
    (p_assignment_id                 =>  p_rec.assignment_id

    ,p_perf_review_period            =>  p_rec.perf_review_period
    ,p_assignment_type               =>  p_rec.assignment_type
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 160);
 end if;
  --
  per_asg_bus2.chk_perf_review_period_freq
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_perf_review_period_frequency  =>  p_rec.perf_review_period_frequency
    ,p_assignment_type               =>  p_rec.assignment_type
    ,p_effective_date                =>  p_effective_date
    ,p_validation_start_date         =>  p_validation_start_date

    ,p_validation_end_date           =>  p_validation_end_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 170);
 end if;
  --
  per_asg_bus2.chk_perf_rp_freq_perf_rp
    (p_assignment_id                 =>  p_rec.assignment_id
    ,p_perf_review_period_frequency  =>  p_rec.perf_review_period_frequency
    ,p_perf_review_period            =>  p_rec.perf_review_period
    ,p_effective_date                =>  p_effective_date
    ,p_object_version_number         =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;

  --
  per_asg_bus1.chk_frequency
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_frequency               =>  p_rec.frequency
    ,p_effective_date          =>  p_effective_date
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  per_asg_bus1.chk_frequency_normal_hours
    (p_assignment_id           =>  p_rec.assignment_id

    ,p_frequency               =>  p_rec.frequency
    ,p_normal_hours            =>  p_rec.normal_hours
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 200);
 end if;
  --
  per_asg_bus2.chk_set_of_books_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_set_of_books_id        =>  p_rec.set_of_books_id
    ,p_effective_date         =>  p_effective_date

    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 210);
 end if;
  --
  per_asg_bus2.chk_source_organization_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_source_organization_id =>  p_rec.source_organization_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date

    );
 if g_debug then
  hr_utility.set_location(l_proc, 220);
 end if;
  --
  per_asg_bus2.chk_soft_coding_keyflex_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_soft_coding_keyflex_id =>  p_rec.soft_coding_keyflex_id
    ,p_effective_date         =>  p_effective_date
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_payroll_id             =>  p_rec.payroll_id
    ,p_business_group_id      =>  p_rec.business_group_id
    );
 if g_debug then
  hr_utility.set_location(l_proc, 230);
 end if;
  --

  per_asg_bus2.chk_pay_basis_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_pay_basis_id          =>  p_rec.pay_basis_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 240);
 end if;
  --
  per_asg_bus2.chk_recruitment_activity_id
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_assignment_type         =>  p_rec.assignment_type
    ,p_business_group_id       =>  p_rec.business_group_id
    ,p_recruitment_activity_id =>  p_rec.recruitment_activity_id
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 250);
 end if;
  --
  per_asg_bus2.chk_vacancy_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type

    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 260);
 end if;
  --
  per_asg_bus1.chk_location_id
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_location_id           =>  p_rec.location_id
     ,p_assignment_type       =>  p_rec.assignment_type

     ,p_vacancy_id            =>  p_rec.vacancy_id
     ,p_validation_start_date =>  p_validation_start_date
     ,p_validation_end_date   =>  p_validation_end_date
     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 270);
 end if;
  --
  per_asg_bus2.chk_people_group_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_people_group_id        =>  p_rec.people_group_id

    ,p_vacancy_id             =>  p_rec.vacancy_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 280);
 end if;
  --
 if g_debug then
  hr_utility.set_location(p_validation_start_date, 290);
 end if;
 if g_debug then
  hr_utility.set_location(p_validation_end_date, 290);
 end if;
  per_asg_bus2.chk_position_id
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_position_id           =>  p_rec.position_id
     ,p_business_group_id     =>  p_rec.business_group_id
     ,p_assignment_type       =>  p_rec.assignment_type

     ,p_vacancy_id            =>  p_rec.vacancy_id
     ,p_validation_start_date =>  p_validation_start_date
     ,p_validation_end_date   =>  p_validation_end_date
     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 290);
 end if;
  --
  per_asg_bus1.chk_job_id
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_job_id                =>  p_rec.job_id

    ,p_vacancy_id            =>  p_rec.vacancy_id
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 300);
 end if;
  --
  per_asg_bus2.chk_position_id_job_id
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_position_id           =>  p_rec.position_id
     ,p_job_id                =>  p_rec.job_id
     ,p_validation_start_date =>  p_validation_start_date

     ,p_validation_end_date   =>  p_validation_end_date
     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 310);
 end if;
  --
  per_asg_bus1.chk_grade_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_assignment_type          =>  p_rec.assignment_type
    ,p_grade_id                 =>  p_rec.grade_id
    ,p_vacancy_id               =>  p_rec.vacancy_id
    ,p_special_ceiling_step_id  =>  p_rec.special_ceiling_step_id

    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 320);
 end if;
  --
  per_asg_bus2.chk_special_ceiling_step_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_assignment_type          =>  p_rec.assignment_type
    ,p_special_ceiling_step_id  =>  p_rec.special_ceiling_step_id
    ,p_grade_id                 =>  p_rec.grade_id
    ,p_business_group_id        =>  p_rec.business_group_id

    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 330);
 end if;
  --
  per_asg_bus2.chk_position_id_grade_id
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_position_id           =>  p_rec.position_id
     ,p_grade_id              =>  p_rec.grade_id
     ,p_validation_start_date =>  p_validation_start_date
     ,p_validation_end_date   =>  p_validation_end_date

     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
     ,p_inv_pos_grade_warning =>  l_inv_pos_grade_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 340);
 end if;
  --
  per_asg_bus1.chk_job_id_grade_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_job_id                 =>  p_rec.job_id
    ,p_grade_id               =>  p_rec.grade_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date

    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_inv_job_grade_warning  =>  l_inv_pos_grade_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 350);
 end if;
  --
  per_asg_bus2.chk_supervisor_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_supervisor_id          =>  p_rec.supervisor_id
    ,p_person_id              =>  p_rec.person_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 360);
 end if;
  --
  per_asg_bus2.chk_supervisor_assignment_id
    (p_assignment_id            =>  p_rec.assignment_id
    ,p_supervisor_id            =>  p_rec.supervisor_id
    ,p_supervisor_assignment_id =>  p_rec.supervisor_assignment_id
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 350);
 end if;
  --
  per_asg_bus2.chk_person_referred_by_id
    (p_assignment_id           =>  p_rec.assignment_id
    ,p_assignment_type         =>  p_rec.assignment_type
    ,p_person_id               =>  p_rec.person_id
    ,p_person_referred_by_id   =>  p_rec.person_referred_by_id
    ,p_business_group_id       =>  p_rec.business_group_id
    ,p_effective_date          =>  p_effective_date
    ,p_object_version_number   =>  p_rec.object_version_number
    ,p_validation_start_date   =>  p_validation_start_date
    ,p_validation_end_date     =>  p_validation_end_date

    );
 if g_debug then
  hr_utility.set_location(l_proc, 370);
 end if;
  --
  per_asg_bus2.chk_recruiter_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_person_id              =>  p_rec.person_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_recruiter_id           =>  p_rec.recruiter_id
    ,p_vacancy_id             =>  p_rec.vacancy_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    ,p_validation_start_date  =>  p_validation_start_date

    ,p_validation_end_date    =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 380);
 end if;
  --
  per_asg_bus2.chk_period_of_service_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_person_id              =>  p_rec.person_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_period_of_service_id   =>  p_rec.period_of_service_id
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 385);
 end if;
  --
   -- bug 5404529
   l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_rec.assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_rec.object_version_number
         );

  if(l_api_updating and
   nvl(per_asg_shd.g_old_rec.assignment_type, hr_api.g_varchar2)
	          = 'A' and p_rec.assignment_type = 'E') THEN

   hr_assignment.gen_new_ass_sequence
                          ( p_rec.person_id
                          , 'E'
                          , l_assignment_sequence
                         );

   end if;
  if ( l_assignment_sequence =1 )  then
  hr_utility.set_location(l_proc, 386);
  p_rec.assignment_sequence:=1;
  per_asg_bus1.gen_chk_assignment_number
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_assignment_number      =>  p_rec.assignment_number
    ,p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
    hr_utility.set_location(l_proc, 387);
    else
    hr_utility.set_location(l_proc, 388);
    per_asg_bus1.gen_chk_assignment_number
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_assignment_number      =>  p_rec.assignment_number
    ,p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );
    hr_utility.set_location(l_proc, 389);
    end if;

    -- end of bug 5404529

 if g_debug then
  hr_utility.set_location(l_proc, 390);
 end if;
  --
  per_asg_bus2.chk_primary_flag
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_primary_flag          =>  p_rec.primary_flag
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_person_id             =>  p_rec.person_id
    ,p_period_of_service_id  =>  p_rec.period_of_service_id
   ,p_pop_date_start        =>  p_rec.period_of_placement_date_start
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 430);
 end if;
  --
  per_asg_bus1.chk_manager_flag
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_assignment_type       =>  p_rec.assignment_type
    ,p_organization_id       =>  p_rec.organization_id
    ,p_manager_flag          =>  p_rec.manager_flag
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_other_manager_warning =>  l_other_manager_warning
    ,p_no_managers_warning   =>  l_no_managers_warning
    );

 if g_debug then
  hr_utility.set_location(l_proc, 400);
 end if;
  --
  per_asg_bus1.chk_organization_id
    (p_assignment_id               =>  p_rec.assignment_id
    ,p_primary_flag                =>  p_rec.primary_flag
    ,p_organization_id             =>  p_rec.organization_id
    ,p_business_group_id           =>  p_rec.business_group_id
    ,p_assignment_type             =>  p_rec.assignment_type
    ,p_vacancy_id                  =>  p_rec.vacancy_id
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_effective_date              =>  p_effective_date

    ,p_object_version_number       =>  p_rec.object_version_number
    ,p_manager_flag                =>  p_rec.manager_flag
    ,p_org_now_no_manager_warning  =>  l_temp_flag
    ,p_other_manager_warning       =>  l_other_manager_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 410);
 end if;
  --
  per_asg_bus2.chk_position_id_org_id
    (p_assignment_id          =>  p_rec.assignment_id
     ,p_position_id           =>  p_rec.position_id
     ,p_organization_id       =>  p_rec.organization_id
     ,p_validation_start_date =>  p_validation_start_date
     ,p_validation_end_date   =>  p_validation_end_date

     ,p_effective_date        =>  p_effective_date
     ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 420);
 end if;
  --
  per_asg_bus1.chk_application_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_application_id         =>  p_rec.application_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number

    ,p_validation_start_date  =>  p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 430);
 end if;
  --
  per_asg_bus2.chk_payroll_id
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_person_id              =>  p_rec.person_id
    ,p_payroll_id             =>  p_rec.payroll_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_validation_start_date  =>  p_validation_start_date
    ,p_validation_end_date    =>  p_validation_end_date
    ,p_effective_date         =>  p_effective_date

    ,p_datetrack_mode         =>  p_datetrack_mode
    ,p_payroll_id_updated     =>  l_payroll_id_updated
    ,p_object_version_number  =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 440);
 end if;
  --
  per_asg_bus1.chk_assignment_status_type_id
    (p_rec                       => p_rec
    ,p_effective_date            => p_effective_date
    ,p_validation_start_date     => p_validation_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 450);
 end if;
  --
  per_asg_bus1.chk_bargaining_unit_code
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_bargaining_unit_code  =>  p_rec.bargaining_unit_code
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 451);
 end if;
--
 per_asg_bus1.chk_hourly_salaried_code
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_hourly_salaried_code  =>  p_rec.hourly_salaried_code
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_pay_basis_id          =>  p_rec.pay_basis_id
    ,p_hourly_salaried_warning => l_hourly_salaried_warning
   ,p_assignment_type         => p_rec.assignment_type);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 452);
 end if;
  --
  per_asg_bus1.chk_single_position
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_position_id        =>  p_rec.position_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_assignment_type       =>  p_rec.assignment_type
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 453);
 end if;
  --
  per_asg_bus3.chk_contract_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_contract_id             => p_rec.contract_id
  ,p_person_id               => p_rec.person_id
  ,p_validation_start_date   => p_validation_start_date
  ,p_business_group_id       => p_rec.business_group_id
  ) ;
 if g_debug then
  hr_utility.set_location(l_proc, 510);
 end if;
  --
  per_asg_bus3.chk_establishment_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_establishment_id        => p_rec.establishment_id
  ,p_assignment_type         => p_rec.assignment_type
  ,p_business_group_id       => p_rec.business_group_id
   );
 if g_debug then
  hr_utility.set_location(l_proc, 520);
 end if;
  --
  per_asg_bus3.chk_collective_agreement_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ,p_business_group_id       => p_rec.business_group_id
  ,p_establishment_id        => p_rec.establishment_id
  );
 if g_debug then
  hr_utility.set_location(l_proc, 530);
 end if;
  --
  per_asg_bus3.chk_cagr_id_flex_num
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_cagr_id_flex_num        => p_rec.cagr_id_flex_num
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ) ;
 if g_debug then
  hr_utility.set_location(l_proc, 535);
 end if;
  --
  per_asg_bus3.chk_cagr_grade_def_id
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  ,p_cagr_grade_def_id       => p_rec.cagr_grade_def_id
  ,p_collective_agreement_id => p_rec.collective_agreement_id
  ,p_cagr_id_flex_num        => p_rec.cagr_id_flex_num
  );

  per_asg_bus3.chk_notice_period
  (p_assignment_id           => p_rec.assignment_id
  ,p_notice_period           => p_rec.notice_period
  );

  per_asg_bus3.chk_notice_period_uom
  (p_assignment_id           => p_rec.assignment_id
  ,p_notice_period_uom       => p_rec.notice_period_uom
  ,p_notice_period           => p_rec.notice_period
  ,p_effective_date          => p_effective_date
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );

  per_asg_bus3.chk_work_at_home
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_work_at_home      => p_rec.work_at_home
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );

  per_asg_bus3.chk_employee_category
  (p_assignment_id           => p_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_employee_category       => p_rec.employee_category
  ,p_validation_start_date  =>  p_validation_start_date
  ,p_validation_end_date    =>  p_validation_end_date
  );
    --
 if g_debug then
  hr_utility.set_location(l_proc, 600);
 end if;
  --
  per_asg_bus1.chk_assignment_category
    (p_assignment_id           => p_rec.assignment_id
    ,p_assignment_type         => p_rec.assignment_type
    ,p_effective_date          => p_effective_date
    ,p_assignment_category     => p_rec.assignment_category
    ,p_object_version_number   => p_rec.object_version_number
    ,p_validation_start_date   => p_validation_start_date
    ,p_validation_end_date     => p_validation_end_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 610);
 end if;
  --
  per_asg_bus3.chk_vendor_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_vendor_id              => p_rec.vendor_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 620);
 end if;
  per_asg_bus3.chk_vendor_site_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 630);
 end if;
  --
  per_asg_bus3.chk_po_header_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_po_header_id           => p_rec.po_header_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 640);
 end if;
  --
  per_asg_bus3.chk_po_line_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_assignment_type        => p_rec.assignment_type
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 650);
 end if;
  --
  per_asg_bus3.chk_projected_assignment_end
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_effective_start_date     => p_rec.effective_start_date
    ,p_projected_assignment_end => p_rec.projected_assignment_end
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 660);
 end if;
  --
  per_asg_bus3.chk_vendor_id_site_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_vendor_id              => p_rec.vendor_id
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 670);
 end if;
  --
  per_asg_bus3.chk_po_header_id_line_id
    (p_assignment_id          => p_rec.assignment_id
    ,p_po_header_id           => p_rec.po_header_id
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 680);
 end if;
  --
  per_asg_bus3.chk_vendor_po_match
    (p_assignment_id          => p_rec.assignment_id
    ,p_vendor_id              => p_rec.vendor_id
    ,p_vendor_site_id         => p_rec.vendor_site_id
    ,p_po_header_id           => p_rec.po_header_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 690);
 end if;
  --
  per_asg_bus3.chk_po_job_match
    (p_assignment_id          => p_rec.assignment_id
    ,p_job_id                 => p_rec.job_id
    ,p_po_line_id             => p_rec.po_line_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 700);
  end if;
  --
  per_asg_bus3.chk_vendor_assignment_number
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_vendor_assignment_number => p_rec.vendor_assignment_number
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 710);
 end if;
  --
  per_asg_bus3.chk_vendor_employee_number
    (p_assignment_id            => p_rec.assignment_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_vendor_employee_number   => p_rec.vendor_employee_number
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 720);
 end if;
  --
  per_asg_bus3.chk_pop_date_start
    (p_assignment_id            => p_rec.assignment_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_person_id                => p_rec.person_id
    ,p_assignment_type          => p_rec.assignment_type
    ,p_pop_date_start           => p_rec.period_of_placement_date_start
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date
    ,p_effective_date           => p_effective_date
    ,p_object_version_number    => p_rec.object_version_number);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 730);
 end if;
  --
per_asg_bus2.chk_applicant_rank
        (p_applicant_rank        =>  p_rec.applicant_rank
        ,p_assignment_type       =>  p_rec.assignment_type
        ,p_assignment_id         =>  p_rec.assignment_id
        ,p_object_version_number =>  p_rec.object_version_number
        ,p_effective_date        =>  p_effective_date);

per_asg_bus2.chk_posting_content_id
        (p_posting_content_id    =>  p_rec.posting_content_id
        ,p_assignment_type       =>  p_rec.assignment_type
        ,p_assignment_id         =>  p_rec.assignment_id
        ,p_object_version_number =>  p_rec.object_version_number
        ,p_effective_date        =>  p_effective_date);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 740);
 end if;
  --
  per_asg_bus3.chk_grade_ladder_pgm_id
    (p_grade_id                 => p_rec.grade_id
    ,p_grade_ladder_pgm_id      => p_rec.grade_ladder_pgm_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_effective_date           => p_effective_date);

  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_asg_bus1.chk_df(p_rec => p_rec);

 if g_debug then
  hr_utility.set_location(l_proc, 750);
 end if;
  --
  -- Call the datetrack update integrity operation
  --
  per_asg_bus1.dt_update_validate
    (p_payroll_id                    => p_rec.payroll_id,
     p_person_id                     => p_rec.person_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date         => p_validation_end_date);
  --
  p_other_manager_warning      := l_other_manager_warning;
  p_hourly_salaried_warning    := l_hourly_salaried_warning;
  p_no_managers_warning        := l_no_managers_warning;

  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  p_inv_pos_grade_warning      := l_inv_pos_grade_warning;
  p_payroll_id_updated         := l_payroll_id_updated;
  --
  --
  --
  -- Call to validate Position Control Business Rules
  --
    per_pqh_shr.per_asg_bus('UPDATE_VALIDATE',
                p_rec,
                            p_effective_date,
                            p_validation_start_date,
                            p_validation_end_date,
                            p_datetrack_mode);
  --
  -- End of call to Position Control Business Rules
  --
/*
  --
  -- Call to validate Position Control Business Rules
  --
  if (pqh_psf_bus.position_control_enabled
      ( p_organization_id => p_rec.organization_id
      , p_effective_date  => p_effective_date
      ) = 'Y') then
    pqh_psf_bus.per_asg_bus_update_validate
         (p_position_id    => p_rec.position_id
         ,p_assignment_id  => p_rec.assignment_id
         ,p_assignment_date   => p_rec.effective_start_date
         ,p_assignment_grade_id  => p_rec.grade_id
         ,p_assignment_emp_cat   => p_rec.employment_category
         );
  end if;
  --
  -- End of call to Position Control Business Rules
  --
*/
  --
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
End update_validate;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_application_id >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_application_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_sequence      in per_all_assignments_f.assignment_sequence%TYPE
  ,p_application_id           in per_all_assignments_f.application_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date    in date
  )
  is
--
  l_proc              varchar2(72)  :=  g_package||'chk_application_id';
  l_exists            varchar2(1);
  l_api_updating      boolean;
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_valid_apl_1 is
    select   business_group_id
    from     per_applications
    where    application_id = p_application_id
    and      date_received = p_validation_start_date;
  --
  cursor csr_valid_apl_2 is
    select   business_group_id
    from     per_applications
    where    application_id = p_application_id
    and      p_validation_start_date
      between date_received
      and     nvl(date_end,hr_api.g_eot);
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
    --
    -- Check mandatory parameters have been set
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective_date'
      ,p_argument_value => p_effective_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
 if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    -- Check if the assignment is being updated.
    --
    l_api_updating := per_asg_shd.api_updating
          (p_assignment_id          => p_assignment_id
          ,p_effective_date         => p_effective_date
          ,p_object_version_number  => p_object_version_number);
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    -- Check if the assignment is being inserted or updated.
    --
    if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.application_id, hr_api.g_number)
       <> nvl(p_application_id, hr_api.g_number))
      or (NOT l_api_updating))
    then
 if g_debug then
      hr_utility.set_location(l_proc, 40);
 end if;
      --
      -- Check if the assignment is an applicant assignment or
      -- offer assignment or an employee assignment which is being updated.
      --
      if p_assignment_type = 'A'
        or p_assignment_type = 'O'
        or (p_assignment_type = 'E' and l_api_updating)
        then
        --
        -- Check if the application is null
        --
        if p_application_id is null then
          --
          -- Check if the assignment is an applicant or offer assignment
          --
          if  p_assignment_type = 'A'
           or p_assignment_type = 'O' then
            --
            hr_utility.set_message(801, 'HR_51212_ASG_INV_APL_ASG_APL');
            hr_utility.raise_error;
           /* hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
         );*/
            --
          end if;
 if g_debug then
          hr_utility.set_location(l_proc, 50);
 end if;
          --
          -- Check if the existing application is set
          --
          If per_asg_shd.g_old_rec.application_id is not null then
            --
            hr_utility.set_message(801, 'HR_51213_ASG_INV_UPD_APL');
            hr_utility.raise_error;
           /*hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
         );  */          --
            --
          end if;
if g_debug then
          hr_utility.set_location(l_proc, 60);
 end if;
          --
        end if;
        --
        -- Check if the assignment is the first applicant assignment.
        --
        IF   p_assignment_sequence = 1
         and (not l_api_updating)
         and p_assignment_type <> 'O'
        then
          --
          -- Check if the application exists in PER_APPLICATIONS
          -- and the application date received is the same as the
          -- assignment effective start date.
          --
          open csr_valid_apl_1;
          fetch csr_valid_apl_1 into l_business_group_id;
          if csr_valid_apl_1%notfound then
            close csr_valid_apl_1;
            hr_utility.set_message(801, 'HR_51210_ASG_INV_APL');
            hr_utility.raise_error;
           /* hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
         ,p_associated_column2 =>
         'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
         ,p_associated_column3 =>
         'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_SEQUENCE'
         ); */
            --
          else
       close csr_valid_apl_1;
     end if;
        else -- not the first applicant assignment
          --
          -- Check if the application exists in PER_APPLICATIONS
          -- and the assignment effective start date is between the
          -- date received and the date end of the application when
          -- the application date end is set.
          --
          open csr_valid_apl_2;
          fetch csr_valid_apl_2 into l_business_group_id;
          if csr_valid_apl_2%notfound then
            close csr_valid_apl_2;
            hr_utility.set_message(801, 'HR_51375_ASG_INV_APL_NOT_1_ASG');
            hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
         ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
              ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_SEQUENCE'
         );
            --
          else
       close csr_valid_apl_2;
       --
            -- Check that the application is in the same business group
            -- as the business group of the assignment.
            --
if g_debug then
            hr_utility.set_location(l_proc, 90);
 end if;
       If p_business_group_id <> l_business_group_id then
              --
              hr_utility.set_message(801, 'HR_51214_ASG_INV_APL_BUS_GRP');
              hr_multi_message.add
                (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
      );
              --
             end if;
          end if;
if g_debug then
     hr_utility.set_location(l_proc, 100);
 end if;
          --
        end if;
        --
      else -- inserted an employee assignment
        --
        -- Check that application is null
        --
        If p_application_id is not null then
          --
          hr_utility.set_message(801, 'HR_51211_ASG_INV_E_ASG_APL_ID');
          hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.APPLICATION_ID'
         );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 110);
 end if;
        --
      end if;
      --
    end if;
    --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 120);
 end if;
end chk_application_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< gen_chk_assignment_number >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure gen_chk_assignment_number
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_assignment_sequence   in per_all_assignments_f.assignment_sequence%TYPE
  ,p_assignment_number     in out nocopy per_all_assignments_f.assignment_number%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc            varchar2(72)  :=  g_package||'gen_chk_assignment_number';
   l_api_updating    boolean;
   l_worker_number varchar2(30);
   --
   cursor csr_get_work_no is
     select   decode(p_assignment_type,'E',employee_number,'C',npw_number)
     from     per_all_people_f --#3663845 per_people_f
     where    person_id = p_person_id
     and      p_effective_date between effective_start_date
                               and     effective_end_date;
   --
begin
  --
if g_debug then
  hr_utility.set_location('Entering: '|| l_proc, 10);
 end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_sequence'
    ,p_argument_value => p_assignment_sequence
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for assignment number has changed
  --    to a not null value
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Amended for bug 942142
  -- Removed p_assignment_number is not null from the check condition
  -- of the top level if statement
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.assignment_number, hr_api.g_varchar2) <>
       nvl(p_assignment_number, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    --
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- For applicant and offer assignments ensure the assignment_number
    -- is null
    -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
    --
    if p_assignment_type in ('A','B','O') then
      --
      -- Check if the assignment number is set.
      --
      if p_assignment_number is not null then
       --
        -- Raise an error: Assignment Number must be null for
        -- applicant, offer and benefit assignments
        hr_utility.set_message(801, 'HR_51017_ASG_NUM_NULL_FOR_APL');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER');
        --
      end if;
     --
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
   --
   -- For Employee and Contingent Labour assignments derive the
   -- assignment number.
   --
    elsif p_assignment_type In ('E','C') then
      --
      if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID') then
        --
        -- For worker assignments validate or generate the assignment number
        --
        open csr_get_work_no;
        fetch csr_get_work_no into l_worker_number;
      --
        if csr_get_work_no%found then
        --
          close csr_get_work_no;
if g_debug then
          hr_utility.set_location(l_proc, 60);
 end if;
          --
           hr_assignment.gen_new_ass_number
            (p_assignment_id       => p_assignment_id
            ,p_business_group_id   => p_business_group_id
            ,p_worker_number       => l_worker_number
            ,p_assignment_type     => p_assignment_type
            ,p_assignment_sequence => p_assignment_sequence
            ,p_assignment_number   => p_assignment_number);
          --
if g_debug then
          hr_utility.set_location(l_proc, 70);
 end if;
          --
        else
          --
          -- No worker number found for assignment
          --
          close csr_get_work_no;
          hr_utility.set_message(801, 'HR_7390_ASG_NO_EMP_NO');
          hr_multi_message.add
           (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
      ,p_associated_column2 =>
      'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE');
          --
        end if;
        --
      end if; -- no exclusive error
     --
if g_debug then
      hr_utility.set_location(l_proc, 90);
 end if;
     --
    end if;
  --
  -- Check if the applicant assignment is being converted to an employee
  -- assignment.
  --
  elsif (l_api_updating and
         nvl(per_asg_shd.g_old_rec.assignment_type, hr_api.g_varchar2)
         = 'A' and p_assignment_type = 'E') then
    --
    if hr_multi_message.no_exclusive_error
      (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID') then
      --
      -- For employee assignments validate or generate the assignment number
      --
      open csr_get_work_no;
      fetch csr_get_work_no into l_worker_number;
      --
      if csr_get_work_no%found then
       --
        close csr_get_work_no;
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
        hr_assignment.gen_new_ass_number
          (p_assignment_id       => p_assignment_id
          ,p_business_group_id   => p_business_group_id
          ,p_worker_number       => l_worker_number
          ,p_assignment_type     => p_assignment_type
          ,p_assignment_sequence => p_assignment_sequence
          ,p_assignment_number   => p_assignment_number);
        --
if g_debug then
        hr_utility.set_location(l_proc, 70);
 end if;
        --
      else
        --
        -- No employee number found for assignment
        --
        close csr_get_work_no;
      --
        hr_utility.set_message(801, 'HR_7390_ASG_NO_EMP_NO');
        hr_multi_message.add
         (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
        ,p_associated_column2 =>
        'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE');
        --
      end if;
     --
    end if; -- no exclusive error
   --
if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
   --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 91);
 end if;
  --
end gen_chk_assignment_number;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_assignment_category >------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_assignment_category
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date        in     date
  ,p_assignment_category   in     per_assignments_f.assignment_category%TYPE
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date) IS
  --
  l_proc          varchar2(72);
  l_api_updating  boolean;
  --
BEGIN
  --
if g_debug then
  l_proc :=  g_package||'chk_assignment_category';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check if inserting or updating the assignment
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Check if inserting or assignment type has changed
  --
  IF ((l_api_updating AND
       nvl(per_asg_shd.g_old_rec.assignment_category, hr_api.g_varchar2) <>
       nvl(p_assignment_category, hr_api.g_varchar2)) OR
      (NOT l_api_updating)) THEN
    --
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check that assignment type is 'C' (Contingent Worker) and
   -- that the value entered exists in the CWK_ASG_CATEOGRY lookup
    --
    IF p_assignment_type = 'C' AND
      p_assignment_category IS NOT NULL THEN
      --
      IF hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date         => p_effective_date
        ,p_validation_start_date  => p_validation_start_date
        ,p_validation_end_date    => p_validation_end_date
        ,p_lookup_type            => 'CWK_ASG_CATEGORY'
        ,p_lookup_code            => p_assignment_category) THEN
        --
        hr_utility.set_message(800,'HR_289642_INV_CWK_ASG_CAT');
        hr_utility.raise_error;
        --
      END IF;
    --
   -- Check that if the assignment type is not a CWK assignment that
   -- the assignment cateogory is blank.
   --
   ELSIF p_assignment_type <> 'C' AND
         p_assignment_category IS NOT NULL THEN
      --
      hr_utility.set_message(800,'HR_289643_CWK_ASG_CAT_NULL');
      hr_utility.raise_error;
      --
    END IF;
   --
  END IF;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 997);
 end if;
  --
EXCEPTION
  --
  WHEN app_exception.application_exception THEN
    --
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_CATEGORY') THEN
      --
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 998);
 end if;
      --
      RAISE;
      --
    END IF;
    --
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
 end if;
    --
END chk_assignment_category;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_assignment_status_type >----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    If the assignment status type id is passed in, then it is validated
--    against the expected system status and business group, otherwise the
--    default assignment status type id for the specified system status,
--    business group and legislation code is returned.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_status_type_id
--    p_business_group_id
--    p_legislation_code
--    p_expected_system_status
--
--  Post Success:
--    If assignment_status_type_id is valid or can be derived then processing
--    continues
--
--  Post Failure:
--    If assignment_status_type_id is not valid or cannot be derived then an
--    application error is raised and processing is terminated
--
--  Access Status:
--    HR Development Use Only.
--
--
procedure chk_assignment_status_type
  (p_assignment_status_type_id in out nocopy number
  ,p_business_group_id         in     number
  ,p_legislation_code          in     varchar2
  ,p_expected_system_status    in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_ast_business_group_id per_all_assignments_f.business_group_id%TYPE;
  l_per_system_status     per_assignment_status_types.per_system_status%TYPE;
  l_proc                  varchar2(72);
  --
  cursor csr_get_ast_details is
    select ast.per_system_status
         , ast.business_group_id
      from per_assignment_status_types ast
     where ast.assignment_status_type_id = p_assignment_status_type_id;
  --
begin
if g_debug then
  l_proc := g_package || 'chk_assignment_status_type';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
       ) then
  --
  -- If p_assignment_status_type_id is g_number then derive it's default value.
  --
  if nvl(p_assignment_status_type_id, hr_api.g_number) = hr_api.g_number then
    --
if g_debug then
    hr_utility.set_location(l_proc, 10);
 end if;
    --
    -- Derive default value.
    --
if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    per_people3_pkg.get_default_person_type
      (p_required_type     => p_expected_system_status
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_person_type       => p_assignment_status_type_id
      );
  else
    --
if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    -- Validate that assignment status type id is for the expected system
    -- status in the assignment's business group.
    --
    open  csr_get_ast_details;
    fetch csr_get_ast_details
     into l_per_system_status
        , l_ast_business_group_id;
    --
    if csr_get_ast_details%NOTFOUND then
      --
if g_debug then
      hr_utility.set_location(l_proc, 40);
 end if;
      --
      close csr_get_ast_details;
      --
      hr_utility.set_message(801,'HR_7940_ASG_INV_ASG_STAT_TYPE');
      hr_utility.raise_error;
      --
    elsif l_per_system_status <> p_expected_system_status
    then
      --
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      close csr_get_ast_details;
      --
      hr_utility.set_message(801,'HR_7949_ASG_DIF_SYSTEM_TYPES');
      hr_utility.set_message_token('SYSTYPE', p_expected_system_status);
      hr_utility.raise_error;
      --
      --
    elsif nvl(l_ast_business_group_id, p_business_group_id) <>
          p_business_group_id
    then
      --
if g_debug then
      hr_utility.set_location(l_proc, 60);
 end if;
      --
      close csr_get_ast_details;
      --
      hr_utility.set_message(801,'HR_7372_ASG_INV_BG_ASS_STATUS');
      hr_utility.raise_error;
    else
      --
if g_debug then
      hr_utility.set_location(l_proc, 70);
 end if;
      --
      -- No error.
      --
      close csr_get_ast_details;
    end if;
    --
if g_debug then
    hr_utility.set_location(l_proc, 80);
 end if;
  end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 200);
 end if;
end chk_assignment_status_type;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_assignment_status_type_id >--------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_assignment_status_type_id
  (p_rec                       in per_asg_shd.g_rec_type
  ,p_effective_date            in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_start_date     in per_all_assignments_f.effective_start_date%TYPE
  )
  is
--
  l_api_updating          boolean;
  l_proc                  varchar2(72) :=
                                     g_package||'chk_assignment_status_type_id';
  l_exists            varchar2(1);
  --
  l_ast_legislation_code  per_business_groups.legislation_code%TYPE;
  l_bus_legislation_code  per_business_groups.legislation_code%TYPE;
  l_active_flag           per_assignment_status_types.active_flag%TYPE;
  l_ast_active_flag       per_assignment_status_types.active_flag%TYPE;
  l_business_group_id     per_all_assignments_f.business_group_id%TYPE;
  l_per_system_status     per_assignment_status_types.per_system_status%TYPE;
  l_ast_per_system_status per_assignment_status_types.per_system_status%TYPE;
  l_ast_business_group_id per_all_assignments_f.business_group_id%TYPE;
  l_old_per_system_status per_assignment_status_types.per_system_status%TYPE;
  l_initial_ins_date      per_all_assignments_f.effective_start_date%TYPE;
  l_apl_asg_min_esd       per_all_assignments_f.effective_start_date%TYPE;
  l_fir_dt_ast_pss        per_assignment_status_types.per_system_status%TYPE;
  --
  --  Cursor to check that a assignment status type exists in
  --  PER_ASSIGNMENT_STATUS_TYPES.
  --
  cursor csr_valid_ast is
    select   legislation_code, active_flag, business_group_id, per_system_status
    from     per_assignment_status_types
    where    assignment_status_type_id = p_rec.assignment_status_type_id;
  --
  --  Cursor to retrieve the legislation code of the assignment's
  --  business group.
  --
  cursor csr_get_bus_legislation_code is
    select legislation_code
    from   per_business_groups_perf
    where  business_group_id = p_rec.business_group_id;
  --
  --  Cursor to check if the assignment status type exists in
  --  PER_ASS_STATUS_TYPE_AMENDS for the assignment business group.
  --
  cursor csr_chk_amends is
    select   active_flag, per_system_status
    from     per_ass_status_type_amends
    where    assignment_status_type_id = p_rec.assignment_status_type_id
    and      business_group_id = p_rec.business_group_id;
  --
  --  Cursor to retrieve the existing PER_SYSTEM_STATUS for the
  --  assignment status type of the assignment.
  --
  cursor csr_get_old_per_system_type is
    select per_system_status
    from   per_assignment_status_types
    where  assignment_status_type_id =
           per_asg_shd.g_old_rec.assignment_status_type_id;
  --
  --  Cursor to retrieve the effective start date of
  --  the first assignment datetracked instance with assignment
  --  status type PER_SYSTEM_STATUS of 'ACTIVE_ASSIGN'
  --
  cursor csr_get_initial_ins_date is
    select nvl(min(asg.effective_start_date), hr_api.g_eot)
    from   per_all_assignments_f           asg
          ,per_assignment_status_types ast
    where asg.assignment_id             = p_rec.assignment_id
    and   ast.assignment_status_type_id = asg.assignment_status_type_id
    and   ast.per_system_status         = 'ACTIVE_ASSIGN';
  --
  -- Cursor to retrieve the earliest effective start date for an applicant
  -- assignment
  --
  cursor csr_get_apl_asg_min_esd is
    select min(effective_start_date)
    from per_all_assignments_f
    where assignment_id = p_rec.assignment_id
    and   assignment_type = 'A';
  --
  -- Cursor to retrieve the PER SYSTEM STATUS for the first datetracked
  -- instance of an applicant assignment.
  --
  cursor csr_get_fir_dt_inst_ast_pss
    (c_effective_start_date     per_all_assignments_f.effective_start_date%TYPE)
  is
    select ast.per_system_status
    from   per_all_assignments_f           asg
          ,per_assignment_status_types ast
    where asg.assignment_id             = p_rec.assignment_id
    and   asg.effective_start_date      = c_effective_start_date
    and   ast.assignment_status_type_id = asg.assignment_status_type_id;
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_status_type_id'
    ,p_argument_value => p_rec.assignment_status_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_rec.business_group_id
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id         => p_rec.assignment_id
         ,p_effective_date        => p_effective_date
         ,p_object_version_number => p_rec.object_version_number);
if g_debug then
  hr_utility.set_location(l_proc, 15);
 end if;
  --
  --  Check if the assignment is being updated.
  --
  if l_api_updating then
    --
    -- Retrieve existing PER_SYSTEM_STATUS for the assignment status type
    -- of the assignment.
    --
    open  csr_get_old_per_system_type;
    fetch csr_get_old_per_system_type into l_old_per_system_status;
    close csr_get_old_per_system_type;
if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    --  Check if the assignment is an employee assignment
    --
    If p_rec.assignment_type = 'E' then
      --
      -- Check if the existing PER_SYSTEM_STATUS of the assignment status
      -- type is 'TERM_ASSIGN'.
      --
      if l_old_per_system_status = 'TERM_ASSIGN'
      then
        --
        -- Check that no other attributes have been changed.
        -- Note that the if ... statement has to be split because of server
        -- parser limitations.
        --
        if (p_rec.recruiter_id                                       <>
            per_asg_shd.g_old_rec.recruiter_id
          or  p_rec.grade_id                                         <>
            per_asg_shd.g_old_rec.grade_id
          or  p_rec.position_id                                      <>
            per_asg_shd.g_old_rec.position_id
          or  p_rec.job_id                                           <>
            per_asg_shd.g_old_rec.job_id
          or  p_rec.payroll_id                                       <>
            per_asg_shd.g_old_rec.payroll_id
          or  p_rec.location_id                                      <>
            per_asg_shd.g_old_rec.location_id
          or  p_rec.person_referred_by_id                            <>
            per_asg_shd.g_old_rec.person_referred_by_id
         --
         -- Fix for bug 3499996 starts here. coment out code.
         --
        --  or  p_rec.supervisor_id                                    <>
        --    per_asg_shd.g_old_rec.supervisor_id
         --
         -- Fix for bug 3499996 ends here.
         --
          or  p_rec.special_ceiling_step_id                          <>
            per_asg_shd.g_old_rec.special_ceiling_step_id
          or  p_rec.recruitment_activity_id                          <>
            per_asg_shd.g_old_rec.recruitment_activity_id
          or  p_rec.source_organization_id                           <>
            per_asg_shd.g_old_rec.source_organization_id
          or  p_rec.organization_id                                  <>
            per_asg_shd.g_old_rec.organization_id
          or  p_rec.people_group_id                                  <>
            per_asg_shd.g_old_rec.people_group_id
          -- Bug 4190473
          --or  p_rec.soft_coding_keyflex_id                         <>
          --  per_asg_shd.g_old_rec.soft_coding_keyflex_id
          or  p_rec.vacancy_id                                       <>
            per_asg_shd.g_old_rec.vacancy_id
          or  p_rec.pay_basis_id                                     <>
            per_asg_shd.g_old_rec.pay_basis_id
          or  p_rec.application_id                                   <>
            per_asg_shd.g_old_rec.application_id
          or  p_rec.assignment_number                                <>
            per_asg_shd.g_old_rec.assignment_number
          or  p_rec.change_reason                                    <>
            per_asg_shd.g_old_rec.change_reason
          or  p_rec.comment_text                                     <>
            per_asg_shd.g_old_rec.comment_text
          or  p_rec.date_probation_end                               <>
            per_asg_shd.g_old_rec.date_probation_end
          or  p_rec.default_code_comb_id                             <>
            per_asg_shd.g_old_rec.default_code_comb_id
          or  p_rec.employment_category                              <>
            per_asg_shd.g_old_rec.employment_category
          or  p_rec.frequency                                        <>
            per_asg_shd.g_old_rec.frequency
          or  p_rec.internal_address_line                            <>
            per_asg_shd.g_old_rec.internal_address_line
          or  p_rec.manager_flag                                     <>
            per_asg_shd.g_old_rec.manager_flag
          or  p_rec.normal_hours                                     <>
            per_asg_shd.g_old_rec.normal_hours
          or  p_rec.perf_review_period                               <>
            per_asg_shd.g_old_rec.perf_review_period
          or  p_rec.perf_review_period_frequency                     <>
            per_asg_shd.g_old_rec.perf_review_period_frequency
          or  p_rec.probation_period                                 <>
            per_asg_shd.g_old_rec.probation_period
          or  p_rec.probation_unit                                   <>
            per_asg_shd.g_old_rec.probation_unit
          or  p_rec.sal_review_period                                <>
            per_asg_shd.g_old_rec.sal_review_period
          or  p_rec.sal_review_period_frequency                      <>
            per_asg_shd.g_old_rec.sal_review_period_frequency
          or  p_rec.set_of_books_id                                  <>
            per_asg_shd.g_old_rec.set_of_books_id
          or  p_rec.source_type                                      <>
            per_asg_shd.g_old_rec.source_type
          or  p_rec.time_normal_finish                               <>
            per_asg_shd.g_old_rec.time_normal_finish
          or  p_rec.time_normal_start                                <>
            per_asg_shd.g_old_rec.time_normal_start
          or  p_rec.bargaining_unit_code                             <>
            per_asg_shd.g_old_rec.bargaining_unit_code
          or  p_rec.labour_union_member_flag                         <>
            per_asg_shd.g_old_rec.labour_union_member_flag
          or  p_rec.hourly_salaried_code                             <>
            per_asg_shd.g_old_rec.hourly_salaried_code
          or  p_rec.request_id                                       <>
            per_asg_shd.g_old_rec.request_id
          or  p_rec.program_application_id                           <>
            per_asg_shd.g_old_rec.program_application_id
          or  p_rec.program_id                                       <>
            per_asg_shd.g_old_rec.program_id
          or  p_rec.program_update_date                              <>
            per_asg_shd.g_old_rec.program_update_date
          or  p_rec.ass_attribute_category                           <>
            per_asg_shd.g_old_rec.ass_attribute_category
          )
          then
          --
          hr_utility.set_message(801, 'HR_7946_ASG_INV_TERM_ASS_UPD');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
     );
          --
	-- fix for bug  4557189. Commented out code.
        elsif (
	/*p_rec.ass_attribute1  <> per_asg_shd.g_old_rec.ass_attribute1
           or  p_rec.ass_attribute2  <> per_asg_shd.g_old_rec.ass_attribute2
           or  p_rec.ass_attribute3  <> per_asg_shd.g_old_rec.ass_attribute3
           or  p_rec.ass_attribute4  <> per_asg_shd.g_old_rec.ass_attribute4
           or  p_rec.ass_attribute5  <> per_asg_shd.g_old_rec.ass_attribute5
           or  p_rec.ass_attribute6  <> per_asg_shd.g_old_rec.ass_attribute6
           or  p_rec.ass_attribute7  <> per_asg_shd.g_old_rec.ass_attribute7
           or  p_rec.ass_attribute8  <> per_asg_shd.g_old_rec.ass_attribute8
           or  p_rec.ass_attribute9  <> per_asg_shd.g_old_rec.ass_attribute9
           or  p_rec.ass_attribute10 <> per_asg_shd.g_old_rec.ass_attribute10
           or  p_rec.ass_attribute11 <> per_asg_shd.g_old_rec.ass_attribute11
           or  p_rec.ass_attribute12 <> per_asg_shd.g_old_rec.ass_attribute12
           or  p_rec.ass_attribute13 <> per_asg_shd.g_old_rec.ass_attribute13
           or  p_rec.ass_attribute14 <> per_asg_shd.g_old_rec.ass_attribute14
           or  p_rec.ass_attribute15 <> per_asg_shd.g_old_rec.ass_attribute15
           or  p_rec.ass_attribute16 <> per_asg_shd.g_old_rec.ass_attribute16
           or  p_rec.ass_attribute17 <> per_asg_shd.g_old_rec.ass_attribute17
           or  p_rec.ass_attribute18 <> per_asg_shd.g_old_rec.ass_attribute18
           or  p_rec.ass_attribute19 <> per_asg_shd.g_old_rec.ass_attribute19
           or  p_rec.ass_attribute20 <> per_asg_shd.g_old_rec.ass_attribute20
           or  p_rec.ass_attribute21 <> per_asg_shd.g_old_rec.ass_attribute21
           or  p_rec.ass_attribute22 <> per_asg_shd.g_old_rec.ass_attribute22
           or  p_rec.ass_attribute23 <> per_asg_shd.g_old_rec.ass_attribute23
           or  p_rec.ass_attribute24 <> per_asg_shd.g_old_rec.ass_attribute24
           or  p_rec.ass_attribute25 <> per_asg_shd.g_old_rec.ass_attribute25
           or  p_rec.ass_attribute26 <> per_asg_shd.g_old_rec.ass_attribute26
           or  p_rec.ass_attribute27 <> per_asg_shd.g_old_rec.ass_attribute27
           or  p_rec.ass_attribute28 <> per_asg_shd.g_old_rec.ass_attribute28
           or  p_rec.ass_attribute29 <> per_asg_shd.g_old_rec.ass_attribute29
           or  p_rec.ass_attribute30 <> per_asg_shd.g_old_rec.ass_attribute30
           or */
	 p_rec.title           <> per_asg_shd.g_old_rec.title
          )
          then
          --
          hr_utility.set_message(801, 'HR_7946_ASG_INV_TERM_ASS_UPD');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
     );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 25);
 end if;
        --
      end if;
      --
    else -- Applicant assignments
      --
      -- Retrieve the earliest effective start date of the applicant assignment
      --
      open csr_get_apl_asg_min_esd;
      fetch csr_get_apl_asg_min_esd into l_apl_asg_min_esd;
      close csr_get_apl_asg_min_esd;
if g_debug then
      hr_utility.set_location(l_proc, 160);
 end if;
      --
      -- Check if the first dt instance of an applicant assignment has an
      -- assignment status type PER SYSTEM STATUS of 'TERM_APL'
      --
      open csr_get_fir_dt_inst_ast_pss(l_apl_asg_min_esd);
      fetch csr_get_fir_dt_inst_ast_pss into l_fir_dt_ast_pss;
      close csr_get_fir_dt_inst_ast_pss;
if g_debug then
      hr_utility.set_location(l_proc, 170);
 end if;
      --
      If l_fir_dt_ast_pss = 'TERM_APL' then
        --
        hr_utility.set_message(801, 'HR_51275_ASG_INV_F_DT_AST_PSS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
   );
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 180);
 end if;
      --
    end if;
    --
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for assignment status type has changed
  --
  if  (l_api_updating
    and  nvl(per_asg_shd.g_old_rec.assignment_status_type_id, hr_api.g_number)
         <> nvl(p_rec.assignment_status_type_id, hr_api.g_number)
      )
    or  not l_api_updating
  then
if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    -- Check if the assignment status type exists in
    -- PER_ASSIGNMENT_STATUS_TYPES.
    --
    open csr_valid_ast;
    fetch csr_valid_ast
    into l_ast_legislation_code
        ,l_ast_active_flag
        ,l_business_group_id
        ,l_ast_per_system_status;
    --
    if csr_valid_ast%notfound then
      close csr_valid_ast;
      hr_utility.set_message(801, 'HR_7940_ASG_INV_ASG_STAT_TYPE');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
   );
    else
      close csr_valid_ast;
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check that when set the business group for the assignment status type
    -- is the same as the business group of the assignment.
    --
    If l_business_group_id is not null
      and l_business_group_id <> p_rec.business_group_id then
      --
      hr_utility.set_message(801, 'HR_51207_ASG_INV_AST_BUS_GRP');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
   );
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    -- Retrieve the legislation code for the business group of the assignment.
    --
    open  csr_get_bus_legislation_code;
    fetch csr_get_bus_legislation_code into l_bus_legislation_code;
    close csr_get_bus_legislation_code;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
    if  l_ast_legislation_code is not null
    and (nvl(l_bus_legislation_code, l_ast_legislation_code) <>
             l_ast_legislation_code)
    then
      --
      hr_utility.set_message(801, 'HR_7964_ASG_INV_BUS_ATT_LEG');
      hr_multi_message.add;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    -- Check if the assignment status type exists in
    -- PER_ASS_STATUS_TYPE_AMENDS for the assignment business group.
    --
    open csr_chk_amends;
    fetch csr_chk_amends into l_active_flag, l_per_system_status;
    if csr_chk_amends%notfound then
      --
      --  Use active flag and business group values from
      --  PER_ASSIGNMENT_STATUS_TYPES for the assignment status type.
      --
      l_active_flag       := l_ast_active_flag;
      l_per_system_status := l_ast_per_system_status;
      --
    end if;
    close csr_chk_amends;
if g_debug then
    hr_utility.set_location(l_proc, 80);
 end if;
    --
    -- Check that active flag for the assignment status type is set to 'Y'
    --
    If l_active_flag <> 'Y' then
      --
      hr_utility.set_message(801, 'HR_51206_ASG_INV_AST_ACT_FLG');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
   );
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    --  Check if the assignment is an employee assignment
    --
    If p_rec.assignment_type = 'E' then
      --
      -- Check if updating the employee assignment
      --
      if l_api_updating then
        --
        -- Check that the PER_SYSTEM_STATUS is one of the following:
        --   'ACTIVE_ASSIGN', 'SUSP_ASSIGN' and 'TERM_ASSIGN'.
        --
        if  l_per_system_status <> 'ACTIVE_ASSIGN'
          and l_per_system_status <> 'SUSP_ASSIGN'
          and l_per_system_status <> 'TERM_ASSIGN'
        then
          --
          hr_utility.set_message(801, 'HR_7917_ASG_INV_STAT_TYPE');
          hr_multi_message.add
          (p_associated_column1 =>
     'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
     );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 100);
 end if;
        --
        -- Check that the new PER_SYSTEM_STATUS for the assignment status type
        -- of the employee assignment is also 'TERM_ASSIGN' when the existing
        -- PER_SYSTEM_STATUS is 'TERM_ASSIGN'.
        --
        if  l_old_per_system_status  = 'TERM_ASSIGN'
          and l_per_system_status     <> 'TERM_ASSIGN'
          then
            --
            hr_utility.set_message(801, 'HR_7942_ASG_INV_STAT_NOT_TERM');
            hr_multi_message.add
            (p_associated_column1 =>
       'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
       );
            --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 110);
 end if;
        --
        -- Check that the change of assignment_status_type_id to represent a
        -- per_system_status other than ACTIVE_ASSIGN is not effective as of the
        -- date of the initial insert.
        --
        if l_per_system_status <> 'ACTIVE_ASSIGN'
          then
          --
          --  Retrieve the effective start date of the first assignment
          --  datetracked instance with assignment status type PER_SYSTEM_STATUS
          --  of 'ACTIVE_ASSIGN'.
          --
          open  csr_get_initial_ins_date;
          fetch csr_get_initial_ins_date into  l_initial_ins_date;
          close csr_get_initial_ins_date;
if g_debug then
          hr_utility.set_location(l_proc, 120);
 end if;
          --
          if p_validation_start_date <= l_initial_ins_date
          then
            --
            hr_utility.set_message(800,'HR_7915_ASG_INV_STAT_UPD_DATE');
            hr_multi_message.add
            (p_associated_column1 =>
       'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
       ,p_associated_column2 =>
       'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
       );
            --
          end if;
if g_debug then
          hr_utility.set_location(l_proc, 130);
 end if;
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 150);
 end if;
        --
      else  -- Inserting Employee assignment
        --
        -- Check that the per_system_status is 'ACTIVE_ASSIGN'
        --
        if l_per_system_status <> 'ACTIVE_ASSIGN'
          then
          --
          hr_utility.set_message(801, 'HR_7941_ASG_INV_STAT_NOT_ACT');
          hr_multi_message.add
            (p_associated_column1 =>
       'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
       );
          --
        end if;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 160);
 end if;
    elsif p_rec.assignment_type = 'B' then
      --
      -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
      --                NB For 'B' assignments no validation is performed on
      --                assignment status type.
      null;
    --
   -- If the assigment type is a non payrolled worker then
   -- check to see if the assignment_status is valid
   --
    ELSIF p_rec.assignment_type = 'C' THEN
     --
if g_debug then
      hr_utility.set_location(l_proc, 170);
 end if;
     --
     -- If Updating then check that the assignment status type id
     -- is set to either ACTIVE_NPW_ASG or SUSP_NPW_ASG
     --
     IF l_api_updating THEN
       --
if g_debug then
      hr_utility.set_location(l_proc, 180);
 end if;
      --
      IF l_per_system_status NOT IN ('ACTIVE_CWK','SUSP_CWK_ASG') AND
           l_old_per_system_status  = 'ACTIVE_CWK' THEN
          --
        hr_utility.set_message(801, 'HR_289644_CWL_INV_ASS_STAT_TYP');
          hr_utility.raise_error;
        --
      END IF;
      --
     ELSE -- Inserting
       --
if g_debug then
      hr_utility.set_location(l_proc, 190);
 end if;
      --
      IF l_per_system_status <> 'ACTIVE_CWK' THEN
        --
        hr_utility.set_message(801, 'HR_289645_CWK_INV_INS_ASS_TYPE');
          hr_utility.raise_error;
        --
      END IF;
      --
     END IF;
     --
    else  -- Applicant assignments
      --
      -- Check if updating
      --
      If l_api_updating then
        --
        -- Check that assignment status type is either 'ACTIVE_APL', 'OFFER'
        -- or 'ACCEPTED'.
    -- New functionality means that assignment status types of
    -- 'INTERVIEW1' and 'INTERVIEW2' are also allowed
        --
        if  l_per_system_status <> 'ACTIVE_APL'
          and l_per_system_status <> 'OFFER'
          and l_per_system_status <> 'ACCEPTED'
      and l_per_system_status <> 'INTERVIEW1'
      and l_per_system_status <> 'INTERVIEW2'
          then
          hr_utility.set_message(801, 'HR_51232_ASG_INV_AASG_AST');
          hr_multi_message.add
            (p_associated_column1 =>
       'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID'
       );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 170);
 end if;
        --
      end if;
      --
    end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 220);
 end if;
  --
end chk_assignment_status_type_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_assignment_type >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_assignment_type
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in     per_all_assignments_f.person_id%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in     date
  )
is
  --
  l_proc                varchar2(72)  :=  g_package||'chk_assignment_type';
  l_api_updating        boolean;
  l_system_person_type  per_person_types.system_person_type%TYPE;
  --
  cursor csr_get_sys_per_typ is
    select   pet.system_person_type
    from     per_people_f per,
             per_person_types pet
    where    per.person_id      = p_person_id
    and      per.person_type_id = pet.person_type_id
    and      p_validation_start_date
      between  effective_start_date
        and    effective_end_date;
  --
begin
  --
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'

    ,p_argument_value => p_assignment_type
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check if inserting or updating the assignment
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Check if inserting or assignment type has changed
  --
  if ((l_api_updating and
     nvl(per_asg_shd.g_old_rec.assignment_type, hr_api.g_varchar2) <>
     nvl(p_assignment_type, hr_api.g_varchar2))
   or
     (NOT l_api_updating))
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check that assignment type is either 'E' or 'A'
    --
    --
    -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
    -- Extend restriction to allow assignment type 'O' (Offers)
    --
    If p_assignment_type not in('E','A','B','C','O') then
      --
      per_asg_shd.constraint_error
        (p_constraint_name => 'PER_ASS_ASSIGNMENT_TYPE_CHK');
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    open csr_get_sys_per_typ;
    fetch csr_get_sys_per_typ into l_system_person_type;
    close csr_get_sys_per_typ;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
    -- Check for an applicant or offer assignment
    --
    if   p_assignment_type = 'A'
      or p_assignment_type = 'O' then
      --
      -- Check the system person type of the person of the applicant
      -- assignment.
      --
      if l_system_person_type
        not in ('APL', 'APL_EX_APL', 'EMP_APL', 'EX_EMP_APL')
      then
        --
        hr_utility.set_message(801, 'HR_51294_ASG_INV_AASG_PET');
        hr_utility.raise_error;
        --

      end if;
if g_debug then
      hr_utility.set_location(l_proc, 70);
 end if;
      --
    elsif p_assignment_type = 'B' then -- benefit assignments
      --
      -- <OAB_CHANGE> - No person type validation required
      --
      null;
    --
   -- When assignment is for contingent labour, check that the
    -- person type usage of the person on the assignment is 'CWK'.
      --
   ELSIF p_assignment_type = 'C' THEN
      --
if g_debug then
     hr_utility.set_location(l_proc, 75);
 end if;
      --
      -- If the person is not a contractor then raise an error
      --
      IF NOT hr_general2.is_person_type(p_person_id,'CWK',p_effective_date) THEN
       --
      hr_utility.set_message(801, 'HR_289646_PER_TYPE_NOT_CWK');
        hr_utility.raise_error;
      --
     END IF;
     --
    else -- employee assignments
      --
      -- Check the system person type of the person of the employee
      -- assignment.
      --
      if l_system_person_type
        not in ('EMP', 'EMP_APL', 'EX_EMP')
      then
        --
        hr_utility.set_message(801, 'HR_51329_ASG_INV_EASG_PET');

        hr_utility.raise_error;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 80);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      =>
    'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
    ,p_associated_column2      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 120);
 end if;
--
end chk_assignment_type;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_change_reason >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_change_reason
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_change_reason          in     per_all_assignments_f.change_reason%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
   l_api_updating   boolean;
   l_proc           varchar2(72)  :=  g_package||'chk_change_reason';
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and
     nvl(per_asg_shd.g_old_rec.change_reason, hr_api.g_varchar2) <>
     nvl(p_change_reason, hr_api.g_varchar2))
   or
     (NOT l_api_updating))
   then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if the change reason is set
    --
    if p_change_reason is not null then
      --
      -- Check if the assignment is an employee or benefits assignment.
      --
      if p_assignment_type in ('E','B') then
        --
        -- Check that the change reason exists in hr_lookups for the
        -- lookup type 'EMP_ASSIGN_REASON' with an enabled flag set to 'Y'
        -- and that the effective strt date of the assignment is between
        -- start date active and end date active in hr_lookups.
        --
        if hr_api.not_exists_in_dt_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_lookup_type           => 'EMP_ASSIGN_REASON'
          ,p_lookup_code           => p_change_reason
          )
        then
          --
          hr_utility.set_message(801, 'HR_51228_ASG_INV_EASG_CH_REAS');
          hr_utility.raise_error;
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 50);
 end if;
        --
      ELSIF p_assignment_type = 'C' THEN
       --
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      -- Check that the change reason exists in hr_lookups for the
        -- lookup type 'CWK_ASSIGN_REASON' with an enabled flag set to 'Y'
        -- and that the effective start date of the assignment is between
        -- start date active and end date active in hr_lookups.
        --
        IF hr_api.not_exists_in_dt_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_lookup_type           => 'CWK_ASSIGN_REASON'
          ,p_lookup_code           => p_change_reason) THEN
          --
if g_debug then
        hr_utility.set_location(l_proc, 52);
 end if;
        --
        hr_utility.set_message(800, 'HR_289647_INV_CWK_CH_REASON');
          hr_utility.raise_error;
          --
        END IF;
      --
      else -- applicant assignment
        --
        -- Check that the change reason exists in hr_lookups for the
        -- lookup type 'APL_ASSIGN_REASON' with an enabled flag set to 'Y'
        -- and that the effective strt date of the assignment is between
        -- start date active and end date active in hr_lookups.
        --
        if hr_api.not_exists_in_dt_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_lookup_type           => 'APL_ASSIGN_REASON'
          ,p_lookup_code           => p_change_reason
          )
        then
          --
          hr_utility.set_message(801, 'HR_51229_ASG_INV_AASG_CH_REAS');
           hr_utility.raise_error;
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 70);
 end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.CHANGE_REASON'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 90);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
--
end chk_change_reason;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_contig_ass >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that if an attempt is made to date effectively delete
--    a primary assignment, another contiguous non-primary assignment must
--    exist in order to be converted to a primary assignment.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_primary_flag
--    p_person_id
--    p_effective_date
--    p_datetrack_mode
--
--  Post Success:
--    If a contiguous non-primary assignment can be found then processing
--    continues.
--
--  Post Failure:
--    If no contiguous non-primary assignments can be found then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_contig_ass
  (p_primary_flag   in per_all_assignments_f.primary_flag%TYPE
  ,p_person_id      in per_all_assignments_f.person_id%TYPE
  ,p_effective_date in date
  ,p_datetrack_mode in varchar2
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_contig_ass';
--
   cursor csr_chk_contig_ass is

     select   null
     from     sys.dual
     where exists(select  null
                  from    per_all_assignments_f pas
                  ,       per_periods_of_service ppos
                  where   pas.effective_start_date <= p_effective_date
                  and     ppos.period_of_service_id = pas.period_of_service_id
                  and     pas.person_id = p_person_id
                  and     pas.primary_flag = 'N'
                  and (exists(select null
                              from   per_all_assignments_f pas2
                              ,      per_periods_of_service ppos2
                              where  pas2.effective_end_date =
                                nvl(ppos2.actual_termination_date, hr_api.g_eot)
                              and    pas.assignment_id = pas2.assignment_id
                              and    pas2.period_of_service_id = ppos2.period_of_service_id )));  -- Added this last filter for Bug 4300591.
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'primary_flag'
    ,p_argument_value => p_primary_flag
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 2);
 end if;
  --
  -- Check that contiguous non-primary assignment exists
  --
  if p_datetrack_mode = 'DELETE' and p_primary_flag = 'Y' then
    open csr_chk_contig_ass;
    fetch csr_chk_contig_ass into l_exists;
    if csr_chk_contig_ass%notfound then
      close csr_chk_contig_ass;
      hr_utility.set_message(801, 'HR_7392_ASG_INV_DEL_OF_ASS');
      hr_utility.raise_error;
    end if;
    close csr_chk_contig_ass;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
    ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 5);
 end if;
end chk_contig_ass;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_date_probation_end >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_date_probation_end
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_date_probation_end    in     per_all_assignments_f.date_probation_end%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_probation_period      in     per_all_assignments_f.probation_period%TYPE
  ,p_probation_unit        in     per_all_assignments_f.probation_unit%TYPE
  ,p_validation_start_date in     date
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  )
is
  --
  l_proc               varchar2(72)  :=  g_package||'chk_date_probation_end';
  l_api_updating       boolean;
  --
  l_min_effective_start_date   date;
  --
  cursor csr_get_min_asg_esd is
    select   min(effective_start_date)
    from     per_all_assignments_f
    where    assignment_id = p_assignment_id;
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for date probation end has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.date_probation_end, hr_api.g_date)
       <> nvl(p_date_probation_end, hr_api.g_date))
    or
      (NOT l_api_updating))
    then
if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    -- Check if date probation end is not null
    --
    if p_date_probation_end is not null then
      --
      -- Check if the assignment is being inserted or updated
      --
      If l_api_updating then
        --
        -- Check that date probation end is the same as or after the
        -- earliest effective start date for all date tracked instances
        -- of the assignment being updated.
        --
        open csr_get_min_asg_esd;
        fetch csr_get_min_asg_esd into l_min_effective_start_date;
        close csr_get_min_asg_esd;
if g_debug then
        hr_utility.set_location(l_proc, 40);
 end if;
        --
        if p_date_probation_end < l_min_effective_start_date then
          --
          hr_utility.set_message(801, 'HR_51147_ASG_DPE_BEF_MIN_ESD');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END'
     );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 50);
 end if;
        --
      else
        --
        -- Checks that the date probation end is the same as or after the
        -- validation start date on insert.
        --
        if p_date_probation_end < p_validation_start_date then
          --
          hr_utility.set_message(801, 'HR_51147_ASG_DPE_BEF_MIN_ESD');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
     );
          --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 70);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 80);
 end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 90);
 end if;
--
end chk_date_probation_end;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_default_code_comb_id >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_default_code_comb_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_default_code_comb_id    in     per_all_assignments_f.default_code_comb_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  )
is
  --
  l_api_updating   boolean;
  l_proc           varchar2(72)  :=  g_package||'chk_default_code_comb_id';
  l_exists         varchar2(1);
  --
  cursor csr_valid_def_cod_comb is
    select   null
    from     gl_code_combinations
    where    code_combination_id = p_default_code_comb_id
    and      enabled_flag = 'Y'
    and      p_validation_start_date
      between nvl(start_date_active,hr_api.g_sot)
        and     nvl(end_date_active,hr_api.g_eot);
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for default code comb has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.default_code_comb_id, hr_api.g_number) <>
       nvl(p_default_code_comb_id, hr_api.g_number)) or
      (NOT l_api_updating))
    then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if default code comb is not null
    --
    if p_default_code_comb_id is not null then
      --
      -- Check that the assignment is an employee assignment.
      -- modified to allow applicant to have this set.
      --
      -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
      --
      -- Added 'C' for Contingent Worker
      -- modified to allow offer to have this set
      --
      if p_assignment_type not in ('E','A','B','C','O') then
        --
        hr_utility.set_message(801, 'HR_51177_ASG_INV_ASG_TYP_DCC');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DEFAULT_CODE_COMB_ID'
   );
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      -- Check that the default code comb exists in GL_CODE_COMBINATIONS
      --
      open csr_valid_def_cod_comb;
      fetch csr_valid_def_cod_comb into l_exists;
      if csr_valid_def_cod_comb%notfound then
        close csr_valid_def_cod_comb;
        hr_utility.set_message(801, 'HR_51148_ASG_INV_DEF_COD_COM');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DEFAULT_CODE_COMB_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
        --
      else
        close csr_valid_def_cod_comb;
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 60);
 end if;
      --
    end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
end chk_default_code_comb_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_del_organization_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks to see if manager_flag is set to 'Y' on delete whether another
--    assignment also has the manager_flag set within the same organization.
--
--  Pre-conditions:
--    A valid Organization ID
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_manager_flag
--    p_organization_id
--
--  Post Success:
--    Boolean flags set as approrpiate.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--    of the following cases are found :
--      - The organization_id is does not exists or is not date effective
--      - The business group of the organization is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_del_organization_id
  (p_assignment_id              in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date             in date
  ,p_manager_flag               in per_all_assignments_f.manager_flag%TYPE
  ,p_organization_id            in per_all_assignments_f.organization_id%TYPE
  ,p_org_now_no_manager_warning in out nocopy boolean
  )
  is
--
   l_proc           varchar2(72);
   l_api_updating   boolean;
--
begin
if g_debug then
   l_proc :=  g_package||'chk_del_organization_id';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  if p_manager_flag = 'Y' then
    --
    -- Check whether another current assignment exists in the same
    -- organization with manager flag set to 'Y'.
    --
    if not per_asg_bus2.other_managers_in_org
             (p_organization_id => p_organization_id
             ,p_assignment_id   => p_assignment_id
             ,p_effective_date  => p_effective_date
             )
    then
      --
if g_debug then
      hr_utility.set_location(l_proc, 3);
 end if;
      --
      p_org_now_no_manager_warning := TRUE;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
end chk_del_organization_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_employment_category >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_employment_category
 (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
 ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
 ,p_employment_category    in     per_all_assignments_f.employment_category%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_employment_category';
   l_exists         varchar2(1);
   l_api_updating   boolean;
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.employment_category, hr_api.g_varchar2) <>
       nvl(p_employment_category, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    if p_employment_category is not null then
      --
      -- Check that the assignment is of a valid type.
      --
      if p_assignment_type not in ('E','A','B','C','O') then
        --
        hr_utility.set_message(801, 'HR_51217_ASG_INV_ASG_TYP_ECAT');
        hr_utility.raise_error;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      -- Check that the employment category exists in hr_lookups for the
      -- lookup type 'EMP_CAT' with an enabled flag set to 'Y' and that
      -- the effective start date of the assignment is between start date
      -- active and end date active in hr_lookups.
      --
      -- Bug 1472162.
      --
/*
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'EMP_CAT'
        ,p_lookup_code           => p_employment_category
        )
*/

      if p_assignment_type <> 'C' then
        --
        -- Use the employment category for non-contingent worker assignments.
        --
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;

        if hr_api.not_exists_in_leg_lookups
          (p_effective_date        => p_effective_date
            ,p_lookup_type           => 'EMP_CAT'
          ,p_lookup_code           => p_employment_category
          )
        then
          --
          hr_utility.set_message(801, 'HR_51028_ASG_INV_EMP_CATEGORY');
          hr_utility.raise_error;
          --
        end if;

      elsif p_assignment_type = 'C' then
        --
        -- Use the contingent worker lookup. Originally this information
        -- was to be stored in the assignment category column only but
        -- is now stored in employment category. The assignment_category
        -- column itself is redundant.
        --
        -- Here the assignment category chk procedure is called to validate
        -- for contingent workers.
        --
if g_debug then
        hr_utility.set_location(l_proc, 65);
 end if;

        per_asg_bus1.chk_assignment_category
          (p_assignment_id          => p_assignment_id
          ,p_assignment_type        => p_assignment_type
          ,p_effective_date         => p_effective_date
          ,p_assignment_category    => p_employment_category
          ,p_object_version_number  => p_object_version_number
          ,p_validation_start_date  => p_validation_start_date
          ,p_validation_end_date    => p_validation_end_date);

      end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.EMPLOYMENT_CATEGORY'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 90);
 end if;
      raise;
    end if;
if g_debug then
   hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
end chk_employment_category;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_frequency >-------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_frequency
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_frequency             in     per_all_assignments_f.frequency%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  )
is
  --
  l_api_updating   boolean;
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_frequency';
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for frequency has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.frequency, hr_api.g_varchar2) <>
       nvl(p_frequency, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
if g_debug then
    hr_utility.set_location(l_proc||' '||p_frequency, 40);
 end if;
    --
    -- Check if frequency is set.
    --
    if p_frequency is not null then
      --
      -- Check that the frequency exists in hr_lookups for the lookup
      -- type 'FREQUENCY' with an enabled flag set to 'Y' and that the
      -- effective start date of the assignment is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'FREQUENCY'
        ,p_lookup_code           => p_frequency
        )
      then
        --
        hr_utility.set_message(801, 'HR_7388_ASG_INVALID_FREQUENCY');
        hr_utility.raise_error;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 60);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.FREQUENCY'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 90);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
end chk_frequency;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_future_primary >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a non-primary assignment cannot be date effectively
--    deleted if it is update to a primary assignment in the future.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_primary_flag
--    p_effective_date
--
--  Post Success:
--    If the non-primary assignment does not become primary in the future
--    then processing continues.
--
--  Post Failure:
--    If the non-primary assignment becomes primary in the future then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_future_primary
  (p_assignment_id     in per_all_assignments_f.assignment_id%TYPE
  ,p_primary_flag      in per_all_assignments_f.primary_flag%TYPE
  ,p_datetrack_mode    in varchar2
  ,p_effective_date    in date
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_future_primary';
--
   cursor csr_chk_fut_prim is
     select   null
     from     per_all_assignments_f
     where    assignment_id = p_assignment_id
     and      effective_start_date >= p_effective_date
     and      primary_flag = 'Y';
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'primary flag'
    ,p_argument_value => p_primary_flag
    );
  --
if g_debug then
  hr_utility.set_location(l_proc, 2);
 end if;
  --
  if p_datetrack_mode = 'DELETE' and
     p_primary_flag = 'N' then
    open csr_chk_fut_prim;
    fetch csr_chk_fut_prim into l_exists;
    if csr_chk_fut_prim%found then
      close csr_chk_fut_prim;
      hr_utility.set_message(801, 'HR_7399_ASG_NO_DEL_NON_PRIM');
      hr_utility.raise_error;
    end if;
    close csr_chk_fut_prim;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 5);
 end if;
end chk_future_primary;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_grade_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_grade_id
  (p_assignment_id            in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id        in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
  ,p_grade_id                 in     per_all_assignments_f.grade_id%TYPE
  ,p_vacancy_id               in     per_all_assignments_f.vacancy_id%TYPE
  ,p_special_ceiling_step_id  in     per_all_assignments_f.special_ceiling_step_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date      in     per_all_assignments_f.effective_end_date%TYPE
  ,p_object_version_number    in     per_all_assignments_f.object_version_number%TYPE
  )
  is
--
  l_exists                        varchar2(1);
  l_api_updating                  boolean;
  l_business_group_id             number(15);
  l_proc                          varchar2(72)  :=  g_package||'chk_grade_id';
  l_vac_grade_id                  per_all_assignments_f.grade_id%TYPE;
  --
  cursor csr_valid_grade is
    select   business_group_id
    from     per_grades
    where    grade_id = p_grade_id
    and      p_validation_start_date
      between date_from and nvl(date_to, hr_api.g_eot);
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
    --
    -- Check mandatory parameters have been set
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective_date'
      ,p_argument_value => p_effective_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business_group_id'
      ,p_argument_value => p_business_group_id
      );
if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    -- Only proceed with validation if :
    -- a) The current  g_old_rec is current and
    -- b) The value for grade has changed
    --
    l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.grade_id, hr_api.g_number) <>
       nvl(p_grade_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
if g_debug then
      hr_utility.set_location(l_proc, 40);
 end if;
      --
      -- Check if the grade is set.
      --
      if p_grade_id is not null then
        --
        -- Check that the grade exists between date from and date to in
        -- PER_GRADES.
        --
        open csr_valid_grade;
        fetch csr_valid_grade into l_business_group_id;
        if csr_valid_grade%notfound then
         close csr_valid_grade;
         hr_utility.set_message(801, 'HR_7393_ASG_INVALID_GRADE');
         hr_multi_message.add
           (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
      ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
      );
         --
        else
         close csr_valid_grade;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 50);
 end if;
        --
        -- Check that the business group for the grade is the same
        -- as that of the assignment
        --
        if l_business_group_id <> p_business_group_id then
         --
         hr_utility.set_message(801, 'HR_7371_ASG_INVALID_BG_GRADE');
         hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
     );
         --
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
      elsif p_special_ceiling_step_id is not null then
        -- When grade is null special ceiling step should be null
         --
         hr_utility.set_message(801, 'HR_7434_ASG_GRADE_REQUIRED');
         hr_multi_message.add
         (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
    ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
    );
       --
   end if;
if g_debug then
   hr_utility.set_location(l_proc, 80);
 end if;
   --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 110);
 end if;
  --
end chk_grade_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_job_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_job_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_job_id                  in     per_all_assignments_f.job_id%TYPE
  ,p_vacancy_id              in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc                     varchar2(72)  :=  g_package||'chk_job_id';
  l_exists                   varchar2(1);
  l_api_updating             boolean;
  l_business_group_id        per_all_assignments_f.business_group_id%TYPE;
  l_vac_job_id               per_all_assignments_f.job_id%TYPE;
  --
--
-- Bug 33552211 Start Here
-- Description : Changed the cursor sql query to improve the performance
--
/*  cursor csr_valid_job is
    select   business_group_id
    from     per_jobs_v
    where    job_id = p_job_id
    and      p_validation_start_date
      between  date_from
      and      nvl(date_to, hr_api.g_eot);
*/
  cursor csr_valid_job is
    select  job.business_group_id
    from     per_jobs job
           , per_job_groups jgr
    where    job.job_id = p_job_id
    and      (p_validation_start_date
       between  job.date_from
       and      nvl(job.date_to, hr_api.g_eot))
    and     job.job_group_id = jgr.job_group_id
    and jgr.internal_name = 'HR_'||jgr.business_group_id
    and (jgr.business_group_id = job.business_group_id
         or jgr.business_group_id is null);

-- Bug 33552211 End Here
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for job has changed
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.job_id,
       hr_api.g_number) <> nvl(p_job_id, hr_api.g_number))
    or
      NOT l_api_updating) then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if job is set
    --
    if p_job_id is not null then
      --
      -- Check if the job exists in PER_JOBS where the effective start
      -- date of the assignment is between the job date from and date to.
      --
      open csr_valid_job;
      fetch csr_valid_job into l_business_group_id;
      if csr_valid_job%notfound then
        close csr_valid_job;
        hr_utility.set_message(801, 'HR_51172_ASG_INV_DT_JOB');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
        --
      else
        close csr_valid_job;
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      -- Check that the job is in the same business group as the job of the
      -- assignment date effectively.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51173_ASG_INV_DT_JOB_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
   );
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 60);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
  --
end chk_job_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_job_id_grade_id >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_job_id_grade_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_job_id                 in     per_all_assignments_f.job_id%TYPE
  ,p_grade_id               in     per_all_assignments_f.grade_id%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_inv_job_grade_warning     out nocopy boolean
  )
  is
  --
   l_proc                   varchar2(72)  :=  g_package||'chk_job_id_grade_id';
   l_api_updating           boolean;
   l_exists                 varchar2(1);
   l_exists1                varchar2(1); -- Bug 3566686
   l_inv_job_grade_warning  boolean := false;
--
-- Bug 3566686 Starts Here
-- Description : The cursor checks whether ther are any grades defined as
--               the valid grades for the selected JOB.
--
  cursor csr_val_job_grade_exists is
    select   null
    from     per_valid_grades
    where    job_id = p_job_id
    and      p_validation_start_date
      between  date_from
      and      nvl(date_to, hr_api.g_eot);
--
-- Bug 3566686 Ends Here
--
  cursor csr_val_job_grade is
    select   null
    from     per_valid_grades
    where    job_id = p_job_id
    and      grade_id = p_grade_id
    and      p_validation_start_date
      between  date_from
      and      nvl(date_to, hr_api.g_eot);
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
   if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
       ) then
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for job or grade has changed.
  --
  if (l_api_updating
    and
      ((nvl(per_asg_shd.g_old_rec.job_id, hr_api.g_number)
      <> nvl(p_job_id, hr_api.g_number))
      or
      (nvl(per_asg_shd.g_old_rec.grade_id, hr_api.g_number)
      <> nvl(p_grade_id, hr_api.g_number))))
    or
      NOT l_api_updating then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check that both job and grade are set.
    --
    if p_job_id is not null and p_grade_id is not null then
      --
      -- Check if the job and grade exists date effectively in
      -- PER_VALID_GRADES.
      --
      -- Bug 3566686 Starts Here
      -- Description : The first if condition checks whether there are any
      --               grades defined as the valid grades for the selected
      --               JOB, if atleast one such grade exists then only it
      --               will check for the validity of the grade selected
      --               for the JOB.
      --
      open csr_val_job_grade_exists;
      fetch csr_val_job_grade_exists into l_exists1;
      if csr_val_job_grade_exists%found then
          close csr_val_job_grade_exists;
          open csr_val_job_grade;
          fetch csr_val_job_grade into l_exists;
          if csr_val_job_grade%notfound then
            p_inv_job_grade_warning := true;
          end if;
          close csr_val_job_grade;
      else
      close csr_val_job_grade_exists;
      end if;
      --
      -- Bug 3566686 Ends Here
      --
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
  end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
end chk_job_id_grade_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_location_id >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_location_id
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_location_id           in per_all_assignments_f.location_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_vacancy_id            in per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date        in date
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_exists          varchar2(1);
   l_api_updating    boolean;
   l_proc            varchar2(72)  :=  g_package||'chk_location_id';
   l_inactive_date   date;
   l_vac_location_id per_all_assignments_f.location_id%TYPE;
-- Bug 4116879 Starts
-- Desc : The fix made for the bug 3895708, not considerd the INSERT scenario.
--        While creating the Assignment per_all_assignments_f is not populated
--        so the sub query fails. Re-write the cursor to implement INSERT too.
--        Also, fix for the bug 4105698 is modified to make the cursor
--        compatible with 8i.
cursor csr_valid_location_upd is
       select inactive_date
       from  hr_locations_all
       where  location_id =  p_location_id
       and (business_group_id= (
               select distinct business_group_id
               from per_all_assignments_f
               where assignment_id= p_assignment_id)
       or business_group_id is null);

-- bug 4318990 added an nvl in the where condition for relaxing the validation
cursor csr_valid_location_ins is
       select inactive_date
       from  hr_locations_all
       where  location_id =  p_location_id
       and (business_group_id= nvl(hr_general.get_business_group_id,business_group_id)
       or business_group_id is null);
-- Bug 4116879 Ends
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for location_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 30);
 end if;
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.location_id, hr_api.g_number) <>
       nvl(p_location_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    --
if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 40);
 end if;
    --
    if p_location_id is not null then
--
-- Bug 4116879 Starts
-- Desc: On update p_assignment_id is not null. On insert p_assignment_id
--       will be null.
       if p_assignment_id is not null then
          open csr_valid_location_upd;
          fetch csr_valid_location_upd into l_inactive_date;
          if csr_valid_location_upd%notfound then
             close csr_valid_location_upd;
             hr_utility.set_message(801, 'HR_7382_ASG_NON_EXIST_LOCATION');
             hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.LOCATION_ID');
          --
          else
             close csr_valid_location_upd;
          end if;
       else
          open csr_valid_location_ins;
          fetch csr_valid_location_ins into l_inactive_date;
          if csr_valid_location_ins%notfound then
             close csr_valid_location_ins;
             hr_utility.set_message(801, 'HR_7382_ASG_NON_EXIST_LOCATION');
             hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.LOCATION_ID');
          --
          else
             close csr_valid_location_ins;
          end if;
       end if;
-- Bug 4116879 Ends
--
if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 50);
 end if;
      --
      -- Check if the assignment ESD is before the location inactive date
      -- on insert
      --
      if p_validation_start_date >= nvl(l_inactive_date,hr_api.g_eot)
      then
        --
        hr_utility.set_message(801, 'HR_51215_ASG_INACT_LOCATION');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.LOCATION_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
        --
      end if;
if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 60);
 end if;
      --
    end if;
    --
  end if;
  --
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 90);
 end if;
end chk_location_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_manager_flag >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_manager_flag
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_organization_id       in     per_all_assignments_f.organization_id%TYPE
  ,p_manager_flag          in     per_all_assignments_f.manager_flag%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_other_manager_warning in out nocopy boolean
  ,p_no_managers_warning   in out nocopy boolean
  )
  is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_manager_flag';
   l_api_updating   boolean;
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_id'
    ,p_argument_value => p_organization_id
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for manager flag has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.manager_flag, hr_api.g_varchar2) <>
       nvl(p_manager_flag, hr_api.g_varchar2))
    or
      (NOT l_api_updating))
    then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if manager flag is set and is either 'Y' or 'N'.
    --
    If p_manager_flag is not null
      and p_manager_flag not in('Y','N')
    then
      --
      per_asg_shd.constraint_error
      (p_constraint_name => 'PER_ASS_MANAGER_FLAG_CHK');
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
    -- Check if the assignment is an employee assignment.
    --
    --
    -- Remainder of procedure modidied as part of bug 892583. Changes
    -- made have effected the call to the per_asg_bus2.other_managers_in_org
    -- function. Previously ALL new employees, regardless of their
    -- manager flag, called this function. Now only NEW MANAGERS will call
    -- this function.
    --
    --
    -- Check if the assignment is an employee assignment.
    --
    if p_assignment_type = 'E' then
      --
      -- Check to see if adding a NEW employee only.
      --
      if NOT l_api_updating then
        --
        -- Check to see if new employee is a manager
        --
        if p_manager_flag = 'Y' then
          --
          -- Check whether another current assignment exists in the same
          -- organization with manager flag set to 'Y'.
          --
          if per_asg_bus2.other_managers_in_org
            (p_organization_id => p_organization_id
            ,p_assignment_id   => p_assignment_id
            ,p_effective_date  => p_effective_date) then
            --
            p_other_manager_warning := TRUE;
            --
          end if;
          --
        end if; -- Employee is a Manager check
      --
      -- Check if UPDATING employee
      --
      elsif l_api_updating then
        --
        -- Check whether another current assignment exists in the
        -- same organization with manager flag set to 'Y'
        --
        if per_asg_bus2.other_managers_in_org
            (p_organization_id => p_organization_id
            ,p_assignment_id   => p_assignment_id
            ,p_effective_date  => p_effective_date) then
          --
          -- If the new employee is a manager then
          -- set the warning flag to true
          --
          if p_manager_flag = 'Y' then
            --
            p_other_manager_warning := TRUE;
            --
          end if;
        --
        -- No other current assignments exists in the same
        -- organization with a manager flag set to 'Y''
        --
        else
          --
          -- Check if employee is being changed from
          -- a manager to a non-manager
          --
          if p_manager_flag = 'N' and
             per_asg_shd.g_old_rec.manager_flag = 'Y' then
            --
            p_no_managers_warning := TRUE;
            --
          end if;
          --
        end if; -- Manager check in same organization
        --
      end if; -- New or Updating employee
      --
    end if; -- Check if assignment is an employee assignment
    --
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 110);
 end if;
--
end chk_manager_flag;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_frequency_normal_hours >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_frequency_normal_hours
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_frequency              in     per_all_assignments_f.frequency%TYPE
  ,p_normal_hours           in     per_all_assignments_f.normal_hours%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_api_updating   boolean;
   l_proc           varchar2(72)  :=  g_package||'chk_frequency_normal_hours';
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.FREQUENCY'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for normal hours has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if (l_api_updating and
       ((nvl(per_asg_shd.g_old_rec.frequency, hr_api.g_varchar2) <>
       nvl(p_frequency, hr_api.g_varchar2))
         or
       (nvl(per_asg_shd.g_old_rec.normal_hours, hr_api.g_number) <>
       nvl(p_normal_hours, hr_api.g_number))))
    or
       (NOT l_api_updating)
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
      --
      -- Check if normal hours is set
      --
      If p_frequency is not null and p_normal_hours is null then
        --
        hr_utility.set_message(801, 'HR_7387_ASG_NORMAL_HOURS_REQD');
        hr_utility.raise_error;
        --
      elsif p_normal_hours is not null and p_frequency is null then
        --
        hr_utility.set_message(801, 'HR_7396_ASG_FREQUENCY_REQD');
        hr_utility.raise_error;
        --
      elsif p_frequency is not null and p_normal_hours is not null then
        --
        -- Check that value for working_hours does not
        -- exceed the frequency
        --
        hr_assignment.check_hours
          (p_frequency     =>  p_frequency
          ,p_normal_hours  =>  p_normal_hours
          );
if g_debug then
        hr_utility.set_location(l_proc, 50);
 end if;
        --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
  end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
   exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.FREQUENCY'
         ,p_associated_column2      => 'PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
 end if;
end chk_frequency_normal_hours;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_organization_id >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_organization_id
  (p_primary_flag            in  per_all_assignments_f.primary_flag%TYPE
  ,p_assignment_id           in  per_all_assignments_f.assignment_id%TYPE
  ,p_organization_id         in  per_all_assignments_f.organization_id%TYPE
  ,p_business_group_id       in  per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in  per_all_assignments_f.assignment_type%TYPE
  ,p_vacancy_id              in  per_all_assignments_f.vacancy_id%TYPE
  ,p_validation_start_date   in  per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date     in  per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date          in  date
  ,p_object_version_number   in  per_all_assignments_f.object_version_number%TYPE
  ,p_manager_flag               in  per_all_assignments_f.manager_flag%TYPE
  ,p_org_now_no_manager_warning in out nocopy boolean
  ,p_other_manager_warning      in out nocopy boolean
  )
is
  --
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_proc                 varchar2(72)  :=  g_package||'chk_organization_id';
  l_vac_organization_id  per_all_assignments_f.organization_id%TYPE;
  l_business_group_id    per_all_assignments_f.business_group_id%TYPE;
  --
  -- bugfix 2452613: use full table not secure view for validation
  --
  cursor csr_valid_int_hr_org is
    select   business_group_id
    from     hr_all_organization_units
    where    organization_id     = p_organization_id
    and      internal_external_flag = 'INT';
   --
  cursor csr_valid_per_org is
    select   null
    from     per_organization_units
    where    organization_id     = p_organization_id;
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_id'
    ,p_argument_value => p_organization_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for organization_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if (l_api_updating and
     per_asg_shd.g_old_rec.organization_id <> p_organization_id)
    or
      NOT l_api_updating
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;

    --
    -- Check that organization exists and is date effective
    -- on hr_organization_units for an internal organization.
    --
    open csr_valid_int_hr_org;
    fetch csr_valid_int_hr_org into l_business_group_id;
    --
    if csr_valid_int_hr_org%notfound then
      close csr_valid_int_hr_org;
      hr_utility.set_message(801, 'HR_34983_ASG_INVALID_ORG');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID'
   );
      --
    else
      close csr_valid_int_hr_org;
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    -- Check that the organization is in the same business group
    -- as the business group of the assignment.
    --
    If p_business_group_id <> l_business_group_id then
      --
      hr_utility.set_message(801, 'HR_7376_ASG_INVALID_BG_ORG');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID'
   );
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
    -- Check if an insert is taking place.
    --
    if NOT l_api_updating and p_primary_flag = 'Y' then
      --
      null;
      --
    else
      -- Check for a primary assignment
      --
      if p_primary_flag = 'Y' then
        --
        -- Check that the organization exists in PER_ORGANIZATION_UNITS.
        --
        open csr_valid_per_org;
        fetch csr_valid_per_org into l_exists;
        if csr_valid_per_org%notfound then
          close csr_valid_per_org;
          hr_utility.set_message(801, 'HR_51277_ASG_INV_HR_ORG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID'
     );
          --
        else
          close csr_valid_per_org;
        end if;
if g_debug then
   hr_utility.set_location(l_proc, 70);
 end if;
        --
      end if;
      --
    end if;
    --
    -- Check if the assignment is an employee assignment
    --
    If p_assignment_type = 'E' then
      --
      if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.MANAGER_FLAG'
       ) then
      --
      -- Check if manager flag is 'Y'
      --
      if p_manager_flag = 'Y' then
        --
        -- Check whether another current assignment exists in the same
        -- organization with manager flag set to 'Y'.
        --
        if per_asg_bus2.other_managers_in_org
          (p_organization_id => p_organization_id
          ,p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          )
          then
          --
if g_debug then
          hr_utility.set_location(l_proc, 100);
 end if;
          --
          p_other_manager_warning := TRUE;
        else
          --
if g_debug then
          hr_utility.set_location(l_proc, 110);
 end if;
          --
          p_org_now_no_manager_warning := TRUE;
        end if;
        --
      end if;
      end if; -- no exclusive error
      --
    end if; -- p_assignment_type = 'E'
if g_debug then
        hr_utility.set_location(l_proc, 130);
 end if;
        --
    end if;
    --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
 end if;
end chk_organization_id;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_bargaining_unit_code >------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--     Validates that the bargaining_unit_code entered exists in fnd_common_lookups
--     on the effective date.
--
--  Pre-conditions:
--    A valid bargaining_unit_code
--
--  In Arguments:
--    p_assignment_id
--    p_bargaining_unit_code
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if :
--      - the bargaining_unit_code is valid
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the bargaining_unit_code does not exist in fnd_common_lookups on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_bargaining_unit_code
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_bargaining_unit_code   in     per_all_assignments_f.bargaining_unit_code%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  )
  is
--
  l_proc           varchar2(72)  :=  g_package||'chk_bargaining_unit_code';
  l_bargaining_unit_code varchar2(72);
  --
  begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if p_bargaining_unit_code is NOT NULL then
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date   => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'BARGAINING_UNIT_CODE'
      ,p_lookup_code           => p_bargaining_unit_code
      )
    then
      hr_utility.set_message(800, 'PER_52383_ASG_BARG_UNIT_CODE');
      hr_utility.raise_error;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
   exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.BARGAINING_UNIT_CODE'
         ) then
if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
 end if;
      raise;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
 end if;
--
end chk_bargaining_unit_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_hourly_salaried_code >------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--     Validates that the hourly_salaried_code entered exists in fnd_common_lookups
--     on the effective date.
--
--  Pre-conditions:
--    A valid hourly_salaried_code
--
--  In Arguments:
--    p_assignment_id
--    p_hourly_salaried_code
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--    p_pay_basis_id
--  Out Argument
--    p_hourly_salaried_warning
--
--  Post Success:
--    Processing continues if :
--      - the hourly_salaried_code is valid
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the hourly_salaried_code does not exist in fnd_common_lookups on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_hourly_salaried_code
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_hourly_salaried_code   in     per_all_assignments_f.hourly_salaried_code%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_pay_basis_id           in     per_all_assignments_f.pay_basis_id%TYPE
  ,p_hourly_salaried_warning in out nocopy boolean
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE)
  is
--
  l_proc           varchar2(72)  :=  g_package||'chk_hourly_salaried_code';
  l_hourly_salaried_code varchar2(72);
  l_pay_basis      varchar2(72);
  --
  cursor csr_hourly_salaried is
  select pay.pay_basis
  from per_pay_bases pay
  where pay.pay_basis_id = p_pay_basis_id;

  begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- If the assignment is a CWK and the hourly salary
  -- code has been set then raise an error.
  --
  IF p_assignment_type = 'C' AND
     p_hourly_salaried_code IS NOT NULL THEN
    --
   hr_utility.set_message(800,'HR_289648_CWK_HR_CODE_NOT_NULL');
    hr_utility.raise_error;
   --
  END IF;
  --
  if p_hourly_salaried_code is NOT NULL then
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date   => p_effective_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_lookup_type            => 'HOURLY_SALARIED_CODE'
      ,p_lookup_code            => p_hourly_salaried_code
      )
    then
      hr_utility.set_message(800,'PER_52407_HOUR_SAL_CODE');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.HOURLY_SALARIED_CODE'
   );
    else
      --
      if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID'
       ) then
      open csr_hourly_salaried;
      fetch csr_hourly_salaried into l_pay_basis;
      if csr_hourly_salaried%FOUND then
        if (p_hourly_salaried_code = 'H' and
           l_pay_basis <> 'HOURLY')
           or (p_hourly_salaried_code = 'S' and
           l_pay_basis = 'HOURLY')
        then

   p_hourly_salaried_warning := TRUE;
-- updated for bug 2033513

--           hr_utility.set_message(800,'PER_6997_HOUR_SAL_BASIS');
--           hr_utility.raise_error;

        else null;
        end if;
      end if;
      close csr_hourly_salaried;
     end if;
   end if; -- no exclusive error
   end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
--
end chk_hourly_salaried_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_assignment_id           in number
  ) return varchar2 is
  --
  -- Declare cursor
  -- -- --Bug fix 3604024. modified cursor to improve performance
  --
  cursor csr_leg_code is
  select pbg.legislation_code
      from per_business_groups_perf  pbg
      where  pbg.business_group_id =  (select distinct asg.business_group_id  from
                                     per_all_assignments_f    asg
                                    where asg.assignment_id  = p_assignment_id);

  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'assignment_id',
                             p_argument_value => p_assignment_id);
  --
 --
  if nvl(g_assignment_id, hr_api.g_number) = p_assignment_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 end if;
  --
    g_assignment_id    := p_assignment_id;
    g_legislation_code := l_legislation_code;
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
 end if;
  return l_legislation_code;
end return_legislation_code;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   chk_overlap_dates   >--------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Checks the overlap_dates of the position.
--
function chk_overlap_dates
         (p_position_id  in number, p_assignment_start_date date) return boolean is
l_dummy         varchar2(30);
l_position_id   number(10);
l_proc          varchar2(72)  :=  g_package||'chk_overlap_dates ';

/*- This cursor added for the bug 5840410 --*/

cursor c1 is
 select 'x'
 from per_position_extra_info
 where position_id= p_position_id
   and information_type = 'PER_OVERLAP';

cursor c2(l_position_id number) is
select 'x'
from per_position_extra_info
where p_assignment_start_date
      between fnd_date.canonical_to_date(poei_information3)
      and fnd_date.canonical_to_date(poei_information4)
      and position_id= p_position_id -- l_position_id -- for bug 7129787
      and information_type = 'PER_OVERLAP';
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
   if p_position_id is not null and p_assignment_start_date is not null then

    /*- Start Change open cursor c1 added for the bug 5840410 --*/
     hr_utility.set_location('Pos id and assg start date is not null ', 20);
     open c1;
     fetch c1 into l_dummy;--l_position_id; commented for 6331872
     if c1%found then
     hr_utility.set_location('Records found for cursor c1 ', 20);

     open c2(l_position_id);
     /*- End changes for the bug 5840410 --*/
     fetch c2 into l_dummy;
     if c2%found then
      hr_utility.set_location('Records found for cursor c2 ', 30);
       close c2;
       return(true);
      else
       hr_utility.set_location('No Records found for cursor c2 ', 40);
       close c2;
       return(false);
     end if;  -- c2
   /*- Start Change open cursor c1 added for the bug 5840410 --*/
   else
    hr_utility.set_location('No Records found for cursor c1 ', 50);
    close c1;
    return(false);
   end if; -- c1
  /*- End changes for the bug 5840410 --*/
  end if; -- position id not null
   return(false);
end;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_frozen_single_pos >------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--     Validates that the whether Position attached is Frozen or another assignment
--     exists for a Single Position as on the effective date.
--
--  Pre-conditions:
--    A valid position_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_effective_date
--
--  Post Success:
--    Processing continues if :
--      - Position is not Frozen or the no assignment exist if the position
--   is Single position
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the position attached is Frozen or an assignment exists and the position
--        is Single position as of effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_frozen_single_pos
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_position_id      in     per_all_assignments_f.position_id%TYPE
  ,p_effective_date         in     date
  ,p_assignment_type        in     varchar2 default 'E'
  )
  is
--
  l_proc                varchar2(72)  :=  g_package||'chk_frozen_single_pos';
  l_position_type       varchar2(72);
  l_availability_status_id number;
  l_business_group_id      number;
  l_asg_in_overlap_dates        boolean;
  --
  cursor c_position_type(p_position_id number, p_effective_date date) is
  select position_type, availability_status_id, business_group_id
  from hr_all_positions_f
  where position_id = p_position_id
  and p_effective_date between effective_start_date and effective_end_date;
  --
  begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if p_position_id is NOT NULL then
    open c_position_type(p_position_id, p_effective_date);
    fetch c_position_type into l_position_type, l_availability_status_id, l_business_group_id;
    close c_position_type;
    -- Check that the currne position is not Frozen
    if hr_psf_shd.get_availability_status(l_availability_status_id,l_business_group_id) ='FROZEN'
    then
      hr_utility.set_message(800, 'PER_NO_ASG_FOR_FROZEN_POS');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
    end if;
    if (l_position_type = 'SINGLE') then
     l_asg_in_overlap_dates := chk_overlap_dates(p_position_id, p_effective_date);
     if not l_asg_in_overlap_dates then
      -- Check whether there are any assignments attached to a Single Position
      if (p_assignment_type = 'E' or p_assignment_type = 'C') then -- 6397484(forward port of 6356978)
      /*---- Start change for the bug 5854568  ----(modified for the bug 6331872)*/
      if (per_asg_bus1.pos_assignments_exists(p_position_id, p_effective_date, p_assignment_id) and p_assignment_type in ('E','C'))
      /*---- End change for the bug 5854568  ----(modified for the bug 6331872)*/
      then
        hr_utility.set_message(800, 'PER_ASG_EXISTS_FOR_SINGLE_POS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
      end if;
     end if; -- 6397484(forward port of 6356978)
     end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
--
end chk_frozen_single_pos;
--
procedure chk_single_position
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_position_id      in     per_all_assignments_f.position_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE default 'E'
  )
  is
--
  l_proc                varchar2(72)  :=  g_package||'chk_single_position';
  l_api_updating     boolean;
  --
  begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if (l_api_updating and
       (nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number)))
    or
       (NOT l_api_updating)
  then
    per_asg_bus1.chk_frozen_single_pos
    (p_assignment_id         =>  p_assignment_id
    ,p_position_id        =>  p_position_id
    ,p_effective_date        =>  p_effective_date
    ,p_assignment_type       =>  p_assignment_type
    );
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;

  end if;
--
end chk_single_position;
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< pos_assignments_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--     Returns whether the assignment exists for the position passed or not as of
--       effective_date
--
--  Pre-conditions:
--    A valid position_id
--
--  In Arguments:
--    p_position_id
--    p_effective_date
--
--  Post Success:
--    Returns true is assignment exists otherwise false
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      No failure
--
--  Access Status:
--    Internal Table Handler Use Only
--
function pos_assignments_exists(
   p_position_id number,
   p_effective_date date,
   p_except_assignment_id number) return boolean is
l_dummy   varchar2(1);
cursor c1 is
select 'x'
from per_all_assignments_f asg, per_assignment_status_types ast
where position_id = p_position_id
and assignment_id <> nvl(p_except_assignment_id, -1)
and ( assignment_type = 'E' /*or assignment_type = 'A'*/)  -- change for the bug 5854568(modified for 6331872)
and p_effective_date between effective_start_date and effective_end_date
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
begin
  open c1;
  fetch c1 into l_dummy;
  close c1;
  if l_dummy is not null then
     return(true);
  else
     return(false);
  end if;
end;
--
end per_asg_bus1;

/
