--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_ELEMENT_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_ELEMENT_LINK_PKG" AS
/* $Header: pybel.pkb 120.1 2006/09/26 15:01:02 thabara noship $ */

--------------------------------------------------------------------------------
procedure insert_row
  (p_rowid                        in out nocopy varchar2
  ,p_batch_element_link_id        in out nocopy number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_status                in     varchar2
  )
is
  cursor csr_new_rowid is
        select  rowid
        from    pay_batch_element_links
        where   batch_element_link_id   = p_batch_element_link_id
        ;
--
  cursor csr_next_ID is
        select  pay_element_links_s.nextval
        from sys.dual;
--
  l_proc varchar2(72):= 'pay_batch_element_link_pkg.insert_row';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  if p_batch_element_link_id is null then
    open csr_next_ID;
    fetch csr_next_ID into p_batch_element_link_id;
    close csr_next_ID;
  end if;
  --
  insert into pay_batch_element_links(
  --
          batch_element_link_id,
          effective_date,
          element_link_id,
          payroll_id,
          job_id,
          position_id,
          people_group_id,
          cost_allocation_keyflex_id,
          organization_id,
          element_type_id,
          location_id,
          grade_id,
          balancing_keyflex_id,
          business_group_id,
          element_set_id,
          pay_basis_id,
          costable_type,
          link_to_all_payrolls_flag,
          multiply_value_flag,
          standard_link_flag,
          transfer_to_gl_flag,
          comment_id,
          employment_category,
          qualifying_age,
          qualifying_length_of_service,
          qualifying_units,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20)
  values (
          p_batch_element_link_id,
          p_effective_date,
          p_element_link_id,
          p_payroll_id,
          p_job_id,
          p_position_id,
          p_people_group_id,
          p_cost_allocation_keyflex_id,
          p_organization_id,
          p_element_type_id,
          p_location_id,
          p_grade_id,
          p_balancing_keyflex_id,
          p_business_group_id,
          p_element_set_id,
          p_pay_basis_id,
          p_costable_type,
          p_link_to_all_payrolls_flag,
          p_multiply_value_flag,
          p_standard_link_flag,
          p_transfer_to_gl_flag,
          p_comment_id,
          p_employment_category,
          p_qualifying_age,
          p_qualifying_length_of_service,
          p_qualifying_units,
          p_attribute_category,
          p_attribute1,
          p_attribute2,
          p_attribute3,
          p_attribute4,
          p_attribute5,
          p_attribute6,
          p_attribute7,
          p_attribute8,
          p_attribute9,
          p_attribute10,
          p_attribute11,
          p_attribute12,
          p_attribute13,
          p_attribute14,
          p_attribute15,
          p_attribute16,
          p_attribute17,
          p_attribute18,
          p_attribute19,
          p_attribute20);
  --
  open csr_new_rowid;
  fetch csr_new_rowid into p_rowid;
  if (csr_new_rowid%notfound) then
    close csr_new_rowid;
    raise no_data_found;
  end if;
  --
  pay_batch_object_status_pkg.set_status
    (p_object_type       => 'BEL'
    ,p_object_id         => p_batch_element_link_id
    ,p_object_status     => p_object_status
    ,p_payroll_action_id => null
    );
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end insert_row;
--
-------------------------------------------------------------------------------
procedure lock_row
  (p_rowid                        in     varchar2
  ,p_batch_element_link_id        in     number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_status                in     varchar2
  )
is
  --
  cursor csr_locked_row is
        select  *
        from    pay_batch_element_links
        where   rowid = p_rowid
        for update NOWAIT;
  --
  locked_row csr_locked_row%rowtype;
  --
  l_proc varchar2(72):= 'pay_batch_element_link_pkg.lock_row';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  --
  open csr_locked_row;
  fetch csr_locked_row into locked_row;
  if csr_locked_row%notfound then
    close csr_locked_row;
    raise no_data_found;
  end if;
  close csr_locked_row;
  --
  if (    (   (locked_row.batch_element_link_id = p_batch_element_link_id)
           or ((locked_row.batch_element_link_id is null)
               and (p_batch_element_link_id is null)))
      and (   (locked_row.element_link_id = p_element_link_id)
           or ((locked_row.element_link_id is null)
               and (p_element_link_id is null)))
      and (   (locked_row.effective_date = p_effective_date)
           or ((locked_row.effective_date is null)
               and (p_effective_date is null)))
      and (   (locked_row.payroll_id = p_payroll_id)
           or ((locked_row.payroll_id is null)
               and (p_payroll_id is null)))
      and (   (locked_row.job_id = p_job_id)
           or ((locked_row.job_id is null)
               and (p_job_id is null)))
      and (   (locked_row.position_id = p_position_id)
           or ((locked_row.position_id is null)
               and (p_position_id is null)))
      and (   (locked_row.people_group_id = p_people_group_id)
           or ((locked_row.people_group_id is null)
               and (p_people_group_id is null)))
      and (   (locked_row.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id)
           or ((locked_row.cost_allocation_keyflex_id is null)
               and (p_cost_allocation_keyflex_id is null)))
      and (   (locked_row.organization_id = p_organization_id)
           or ((locked_row.organization_id is null)
               and (p_organization_id is null)))
      and (   (locked_row.element_type_id = p_element_type_id)
           or ((locked_row.element_type_id is null)
               and (p_element_type_id is null)))
      and (   (locked_row.location_id = p_location_id)
           or ((locked_row.location_id is null)
               and (p_location_id is null)))
      and (   (locked_row.grade_id = p_grade_id)
           or ((locked_row.grade_id is null)
               and (p_grade_id is null)))
      and (   (locked_row.balancing_keyflex_id = p_balancing_keyflex_id)
           or ((locked_row.balancing_keyflex_id is null)
               and (p_balancing_keyflex_id is null)))
      and (   (locked_row.business_group_id = p_business_group_id)
           or ((locked_row.business_group_id is null)
               and (p_business_group_id is null)))
      and (   (locked_row.element_set_id = p_element_set_id)
           or ((locked_row.element_set_id is null)
               and (p_element_set_id is null)))
      and (   (locked_row.pay_basis_id = p_pay_basis_id)
           or ((locked_row.pay_basis_id is null)
               and (p_pay_basis_id is null)))
      and (   (locked_row.costable_type = p_costable_type)
           or ((locked_row.costable_type is null)
               and (p_costable_type is null)))
      and (   (locked_row.link_to_all_payrolls_flag = p_link_to_all_payrolls_flag)
           or ((locked_row.link_to_all_payrolls_flag is null)
               and (p_link_to_all_payrolls_flag is null)))
      and (   (locked_row.multiply_value_flag = p_multiply_value_flag)
           or ((locked_row.multiply_value_flag is null)
               and (p_multiply_value_flag is null)))
      and (   (locked_row.standard_link_flag = p_standard_link_flag)
           or ((locked_row.standard_link_flag is null)
               and (p_standard_link_flag is null)))
      and (   (locked_row.transfer_to_gl_flag = p_transfer_to_gl_flag)
           or ((locked_row.transfer_to_gl_flag is null)
               and (p_transfer_to_gl_flag is null)))
      and (   (locked_row.comment_id = p_comment_id)
           or ((locked_row.comment_id is null)
               and (p_comment_id is null)))
      and (   (locked_row.employment_category = p_employment_category)
           or ((locked_row.employment_category is null)
               and (p_employment_category is null)))
      and (   (locked_row.qualifying_age = p_qualifying_age)
           or ((locked_row.qualifying_age is null)
               and (p_qualifying_age is null)))
      and (   (locked_row.qualifying_length_of_service = p_qualifying_length_of_service)
           or ((locked_row.qualifying_length_of_service is null)
               and (p_qualifying_length_of_service is null)))
      and (   (locked_row.qualifying_units = p_qualifying_units)
           or ((locked_row.qualifying_units is null)
               and (p_qualifying_units is null)))
      and (   (locked_row.attribute_category = p_attribute_category)
           or ((locked_row.attribute_category is null)
               and (p_attribute_category is null)))
      and (   (locked_row.attribute1 = p_attribute1)
           or ((locked_row.attribute1 is null)
               and (p_attribute1 is null)))
      and (   (locked_row.attribute2 = p_attribute2)
           or ((locked_row.attribute2 is null)
               and (p_attribute2 is null)))
      and (   (locked_row.attribute3 = p_attribute3)
           or ((locked_row.attribute3 is null)
               and (p_attribute3 is null)))
      and (   (locked_row.attribute4 = p_attribute4)
           or ((locked_row.attribute4 is null)
               and (p_attribute4 is null)))
      and (   (locked_row.attribute5 = p_attribute5)
           or ((locked_row.attribute5 is null)
               and (p_attribute5 is null)))
      and (   (locked_row.attribute6 = p_attribute6)
           or ((locked_row.attribute6 is null)
               and (p_attribute6 is null)))
      and (   (locked_row.attribute7 = p_attribute7)
           or ((locked_row.attribute7 is null)
               and (p_attribute7 is null)))
      and (   (locked_row.attribute8 = p_attribute8)
           or ((locked_row.attribute8 is null)
               and (p_attribute8 is null)))
      and (   (locked_row.attribute9 = p_attribute9)
           or ((locked_row.attribute9 is null)
               and (p_attribute9 is null)))
      and (   (locked_row.attribute10 = p_attribute10)
           or ((locked_row.attribute10 is null)
               and (p_attribute10 is null)))
      and (   (locked_row.attribute11 = p_attribute11)
           or ((locked_row.attribute11 is null)
               and (p_attribute11 is null)))
      and (   (locked_row.attribute12 = p_attribute12)
           or ((locked_row.attribute12 is null)
               and (p_attribute12 is null)))
      and (   (locked_row.attribute13 = p_attribute13)
           or ((locked_row.attribute13 is null)
               and (p_attribute13 is null)))
      and (   (locked_row.attribute14 = p_attribute14)
           or ((locked_row.attribute14 is null)
               and (p_attribute14 is null)))
      and (   (locked_row.attribute15 = p_attribute15)
           or ((locked_row.attribute15 is null)
               and (p_attribute15 is null)))
      and (   (locked_row.attribute16 = p_attribute16)
           or ((locked_row.attribute16 is null)
               and (p_attribute16 is null)))
      and (   (locked_row.attribute17 = p_attribute17)
           or ((locked_row.attribute17 is null)
               and (p_attribute17 is null)))
      and (   (locked_row.attribute18 = p_attribute18)
           or ((locked_row.attribute18 is null)
               and (p_attribute18 is null)))
      and (   (locked_row.attribute19 = p_attribute19)
           or ((locked_row.attribute19 is null)
               and (p_attribute19 is null)))
      and (   (locked_row.attribute20 = p_attribute20)
           or ((locked_row.attribute20 is null)
               and (p_attribute20 is null)))
          ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  --
  -- Lock the object status.
  --
  pay_batch_object_status_pkg.lock_batch_object
    (p_object_type         => 'BEL'
    ,p_object_id           => p_batch_element_link_id
    ,p_object_status       => p_object_status
    ,p_default_status      => 'U'
    );
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end lock_row;
--
--------------------------------------------------------------------------------
procedure update_row
  (p_rowid                        in     varchar2
  ,p_batch_element_link_id        in     number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  )
is
  --
  l_proc varchar2(72):= 'pay_batch_element_link_pkg.update_row';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  update pay_batch_element_links
  set
     batch_element_link_id          = p_batch_element_link_id
    ,element_link_id                = p_element_link_id
    ,effective_date                 = p_effective_date
    ,payroll_id                     = p_payroll_id
    ,job_id                         = p_job_id
    ,position_id                    = p_position_id
    ,people_group_id                = p_people_group_id
    ,cost_allocation_keyflex_id     = p_cost_allocation_keyflex_id
    ,organization_id                = p_organization_id
    ,element_type_id                = p_element_type_id
    ,location_id                    = p_location_id
    ,grade_id                       = p_grade_id
    ,balancing_keyflex_id           = p_balancing_keyflex_id
    ,business_group_id              = p_business_group_id
    ,element_set_id                 = p_element_set_id
    ,pay_basis_id                   = p_pay_basis_id
    ,costable_type                  = p_costable_type
    ,link_to_all_payrolls_flag      = p_link_to_all_payrolls_flag
    ,multiply_value_flag            = p_multiply_value_flag
    ,standard_link_flag             = p_standard_link_flag
    ,transfer_to_gl_flag            = p_transfer_to_gl_flag
    ,comment_id                     = p_comment_id
    ,employment_category            = p_employment_category
    ,qualifying_age                 = p_qualifying_age
    ,qualifying_length_of_service   = p_qualifying_length_of_service
    ,qualifying_units               = p_qualifying_units
    ,attribute_category             = p_attribute_category
    ,attribute1                     = p_attribute1
    ,attribute2                     = p_attribute2
    ,attribute3                     = p_attribute3
    ,attribute4                     = p_attribute4
    ,attribute5                     = p_attribute5
    ,attribute6                     = p_attribute6
    ,attribute7                     = p_attribute7
    ,attribute8                     = p_attribute8
    ,attribute9                     = p_attribute9
    ,attribute10                    = p_attribute10
    ,attribute11                    = p_attribute11
    ,attribute12                    = p_attribute12
    ,attribute13                    = p_attribute13
    ,attribute14                    = p_attribute14
    ,attribute15                    = p_attribute15
    ,attribute16                    = p_attribute16
    ,attribute17                    = p_attribute17
    ,attribute18                    = p_attribute18
    ,attribute19                    = p_attribute19
    ,attribute20                    = p_attribute20
  where rowid = p_rowid;
  --
  if sql%notfound then
    raise no_data_found;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end update_row;
--------------------------------------------------------------------------------
procedure delete_row
  (p_rowid 		          in     varchar2
  )
is
  --
  l_batch_element_link_id number;
  l_proc varchar2(72):= 'pay_batch_element_link_pkg.delete_row';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  select batch_element_link_id into l_batch_element_link_id
  from pay_batch_element_links
  where rowid = p_rowid;
  --
  pay_batch_object_status_pkg.delete_object_status
    (p_object_type       => 'BEL'
    ,p_object_id         => l_batch_element_link_id
    ,p_payroll_action_id => null
    );
  --
  delete from pay_batch_element_links
  where  rowid = p_rowid;
  --
  if sql%notfound then
    raise no_data_found;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end delete_row;
--------------------------------------------------------------------------------

end pay_batch_element_link_pkg;

/
