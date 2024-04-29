--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_API" as
/* $Header: pyprlapi.pkb 120.7 2008/02/05 05:34:12 salogana noship $ */
/*
  NOTES
*/

/*---------------------------------------------------------------------------*/
/*-------------------------- constant definitions ---------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*---------------------------- Payroll API types ----------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*--------------------------- Payroll API globals ---------------------------*/
/*---------------------------------------------------------------------------*/
--g_package varchar2(33) := '  pay_payroll_api.';
g_exists  varchar2(1);
g_legislation_code fnd_territories.territory_code%type;
-- The following global variable is to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_payroll_id_i  number   default null;


--
/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

--
-- ------------------------------------------------------------------
-- |------------------< update_cost_concat_segs >--------------------|
-- ------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   When required this procedure updates the PAY_COST_ALLOCATION_KEYFLEX
--   table after the flexfield segments have been inserted to keep
--   the concatenated segment string up-to-date.
--
-- Prerequisites:
--   A row must exist in the PAY_COST_ALLOCATION_KEYFLEX table for the
--   given cost_allocation_keyflex_id.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cost_alloc_keyflex_id        Yes  number   The primary key
--   p_concat_segments              Yes  varchar2 Concatenated String
--
-- Post Success:
--   If required the row is updated and committed.
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
procedure update_cost_concat_segs
  (p_cost_alloc_keyflex_id              in     number
  ,p_concat_segments                   in     varchar2
  ) is
  --
  CURSOR csr_chk_cost is
    SELECT null
      FROM PAY_COST_ALLOCATION_KEYFLEX
     where cost_allocation_keyflex_id = p_cost_alloc_keyflex_id
       and (concatenated_segments     <> p_concat_segments
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_cost_concat_segs';
  --
  procedure update_cost_concat_segs_auto
    (p_cost_alloc_keyflex_id              in     number
    ,p_concat_segments                   in     varchar2
    ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_cost_lock is
      SELECT null
        FROM PAY_COST_ALLOCATION_KEYFLEX
       where cost_allocation_keyflex_id = p_cost_alloc_keyflex_id
         for update nowait;
    --
    l_exists varchar2(30);
    l_proc   varchar2(72) :=g_package||'update_cost_concat_segs_auto';
    --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- The outer procedure has already establish that an update is
    -- required. This sub-procedure uses an autonomous transaction
    -- to ensure that any commits do not impact the main transaction.
    -- If the row is successfully locked then continue and update the
    -- row. If the row cannot be locked then another transaction must
    -- be performing the update. So it is acceptable for this
    -- transaction to silently trap the error and continue.
    --
    -- Note: It is necessary to perform the lock test because in
    -- a batch data upload scenario multiple sessions could be
    -- attempting to insert or update the same Key Flexfield
    -- combination at the same time. Just directly updating the row,
    -- without first locking, can cause sessions to hang and reduce
    -- batch throughput.
    --
    open csr_cost_lock;
    fetch csr_cost_lock into l_exists;
    if csr_cost_lock%found then
      close csr_cost_lock;
      hr_utility.set_location(l_proc, 20);
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
      update PAY_COST_ALLOCATION_KEYFLEX
         set concatenated_segments      = p_concat_segments
       where cost_allocation_keyflex_id = p_cost_alloc_keyflex_id
         and (concatenated_segments     <> p_concat_segments
          or concatenated_segments is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed
      -- inside an autonomous transaction and AOL code has
      -- previously inserted the Key Flexfield combination row in
      -- another autonomous transaction.
      commit;
    else
      close csr_cost_lock;
    end if;
    --
    hr_utility.set_location('Leaving:'|| l_proc, 30);
  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_cost_concat_segs_auto;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first
  -- inserted.
  --
  open csr_chk_cost;
  fetch csr_chk_cost into l_exists;
  if csr_chk_cost%found then
    close csr_chk_cost;
    update_cost_concat_segs_auto
      (p_cost_alloc_keyflex_id => p_cost_alloc_keyflex_id
      ,p_concat_segments      => p_concat_segments
      );
else
    close csr_chk_cost;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 40);
  --
end update_cost_concat_segs;


--We are not using this procedure. But it may be useful in the future.
--
-- ------------------------------------------------------------------
-- |------------------< update_soft_concat_segs >--------------------|
-- ------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   When required this procedure updates the HR_SOFT_CODING_KEYFLEX
--   table after the flexfield segments have been inserted to keep
--   the concatenated segment string up-to-date.
--
-- Prerequisites:
--   A row must exist in the HR_SOFT_CODING_KEYFLEX table for the
--   given soft_coding_keyflex_id.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_soft_coding_keyflex_id       Yes  number   The primary key
--   p_concat_segments              Yes  varchar2 Concatenated String
--
-- Post Success:
--   If required the row is updated and committed.
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
procedure update_soft_concat_segs
  (p_soft_coding_keyflex_id            in     number
  ,p_concat_segments                   in     varchar2
  ) is
  --
  CURSOR csr_chk_soft is
    SELECT null
      FROM HR_SOFT_CODING_KEYFLEX
     where soft_coding_keyflex_id = p_soft_coding_keyflex_id
       and (concatenated_segments     <> p_concat_segments
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_soft_concat_segs';
  --
  procedure update_soft_concat_segs_auto
    (p_soft_coding_keyflex_id            in     number
    ,p_concat_segments                   in     varchar2
    ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_soft_lock is
      SELECT null
        FROM HR_SOFT_CODING_KEYFLEX
       where soft_coding_keyflex_id = p_soft_coding_keyflex_id
         for update nowait;
    --
    l_exists varchar2(30);
    l_proc   varchar2(72) :=g_package||'update_soft_concat_segs_auto';
    --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- The outer procedure has already establish that an update is
    -- required. This sub-procedure uses an autonomous transaction
    -- to ensure that any commits do not impact the main transaction.
    -- If the row is successfully locked then continue and update the
    -- row. If the row cannot be locked then another transaction must
    -- be performing the update. So it is acceptable for this
    -- transaction to silently trap the error and continue.
    --
    -- Note: It is necessary to perform the lock test because in
    -- a batch data upload scenario multiple sessions could be
    -- attempting to insert or update the same Key Flexfield
    -- combination at the same time. Just directly updating the row,
    -- without first locking, can cause sessions to hang and reduce
    -- batch throughput.
    --
    open csr_soft_lock;
    fetch csr_soft_lock into l_exists;
    if csr_soft_lock%found then
      close csr_soft_lock;
      hr_utility.set_location(l_proc, 20);
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
      update HR_SOFT_CODING_KEYFLEX
         set concatenated_segments      = p_concat_segments
       where soft_coding_keyflex_id = p_soft_coding_keyflex_id
         and (concatenated_segments     <> p_concat_segments
          or concatenated_segments is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed
      -- inside an autonomous transaction and AOL code has
      -- previously inserted the Key Flexfield combination row in
      -- another autonomous transaction.
      commit;
    else
      close csr_soft_lock;
    end if;
    --
    hr_utility.set_location('Leaving:'|| l_proc, 30);
  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_soft_concat_segs_auto;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first
  -- inserted.
  --
  open csr_chk_soft;
  fetch csr_chk_soft into l_exists;
  if csr_chk_soft%found then
    close csr_chk_soft;
    update_soft_concat_segs_auto
      (p_soft_coding_keyflex_id => p_soft_coding_keyflex_id
      ,p_concat_segments      => p_concat_segments
      );
else
    close csr_chk_soft;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 40);
  --
end update_soft_concat_segs;

procedure create_payroll
(
   p_validate                     in   boolean   default false,
   p_effective_date               in   date,
   p_payroll_name                 in   varchar2,
   p_consolidation_set_id         in   number,
   p_period_type                  in   varchar2,
   p_first_period_end_date        in   date,
   p_number_of_years              in   number,
   p_payroll_type                 in   varchar2  default null,
   p_pay_date_offset              in   number    default 0,
   p_direct_deposit_date_offset   in   number    default 0,
   p_pay_advice_date_offset       in   number    default 0,
   p_cut_off_date_offset          in   number    default 0,
   p_midpoint_offset              in   number    default null,
   p_default_payment_method_id    in   number    default null,
   p_cost_alloc_keyflex_id_in     in   number    default null,
   p_susp_account_keyflex_id_in   in   number    default null,
   p_negative_pay_allowed_flag    in   varchar2  default 'N',
   p_gl_set_of_books_id           in   number    default null,
   p_soft_coding_keyflex_id_in    in   number    default null,
   p_comments                     in   varchar2  default null,
   p_attribute_category           in   varchar2  default null,
   p_attribute1                   in   varchar2  default null,
   p_attribute2                   in   varchar2  default null,
   p_attribute3                   in   varchar2  default null,
   p_attribute4                   in   varchar2  default null,
   p_attribute5                   in   varchar2  default null,
   p_attribute6                   in   varchar2  default null,
   p_attribute7                   in   varchar2  default null,
   p_attribute8                   in   varchar2  default null,
   p_attribute9                   in   varchar2  default null,
   p_attribute10                  in   varchar2  default null,
   p_attribute11                  in   varchar2  default null,
   p_attribute12                  in   varchar2  default null,
   p_attribute13                  in   varchar2  default null,
   p_attribute14                  in   varchar2  default null,
   p_attribute15                  in   varchar2  default null,
   p_attribute16                  in   varchar2  default null,
   p_attribute17                  in   varchar2  default null,
   p_attribute18                  in   varchar2  default null,
   p_attribute19                  in   varchar2  default null,
   p_attribute20                  in   varchar2  default null,
   p_arrears_flag                 in   varchar2  default 'N',
   p_period_reset_years           in   varchar2  default null,
   p_multi_assignments_flag       in   varchar2  default null,
   p_organization_id              in   number    default null,
   p_prl_information1         	  in   varchar2  default null,
   p_prl_information2         	  in   varchar2  default null,
   p_prl_information3         	  in   varchar2  default null,
   p_prl_information4         	  in   varchar2  default null,
   p_prl_information5         	  in   varchar2  default null,
   p_prl_information6         	  in   varchar2  default null,
   p_prl_information7         	  in   varchar2  default null,
   p_prl_information8         	  in   varchar2  default null,
   p_prl_information9         	  in   varchar2  default null,
   p_prl_information10        	  in   varchar2  default null,
   p_prl_information11            in   varchar2  default null,
   p_prl_information12        	  in   varchar2  default null,
   p_prl_information13        	  in   varchar2  default null,
   p_prl_information14        	  in   varchar2  default null,
   p_prl_information15        	  in   varchar2  default null,
   p_prl_information16        	  in   varchar2  default null,
   p_prl_information17        	  in   varchar2  default null,
   p_prl_information18        	  in   varchar2  default null,
   p_prl_information19        	  in   varchar2  default null,
   p_prl_information20        	  in   varchar2  default null,
   p_prl_information21        	  in   varchar2  default null,
   p_prl_information22            in   varchar2  default null,
   p_prl_information23        	  in   varchar2  default null,
   p_prl_information24        	  in   varchar2  default null,
   p_prl_information25        	  in   varchar2  default null,
   p_prl_information26        	  in   varchar2  default null,
   p_prl_information27        	  in   varchar2  default null,
   p_prl_information28        	  in   varchar2  default null,
   p_prl_information29        	  in   varchar2  default null,
   p_prl_information30            in   varchar2  default null,

   p_cost_segment1                 in  varchar2 default null,
   p_cost_segment2                 in  varchar2 default null,
   p_cost_segment3                 in  varchar2 default null,
   p_cost_segment4                 in  varchar2 default null,
   p_cost_segment5                 in  varchar2 default null,
   p_cost_segment6                 in  varchar2 default null,
   p_cost_segment7                 in  varchar2 default null,
   p_cost_segment8                 in  varchar2 default null,
   p_cost_segment9                 in  varchar2 default null,
   p_cost_segment10                in  varchar2 default null,
   p_cost_segment11                in  varchar2 default null,
   p_cost_segment12                in  varchar2 default null,
   p_cost_segment13                in  varchar2 default null,
   p_cost_segment14                in  varchar2 default null,
   p_cost_segment15                in  varchar2 default null,
   p_cost_segment16                in  varchar2 default null,
   p_cost_segment17                in  varchar2 default null,
   p_cost_segment18                in  varchar2 default null,
   p_cost_segment19                in  varchar2 default null,
   p_cost_segment20                in  varchar2 default null,
   p_cost_segment21                in  varchar2 default null,
   p_cost_segment22                in  varchar2 default null,
   p_cost_segment23                in  varchar2 default null,
   p_cost_segment24                in  varchar2 default null,
   p_cost_segment25                in  varchar2 default null,
   p_cost_segment26                in  varchar2 default null,
   p_cost_segment27                in  varchar2 default null,
   p_cost_segment28                in  varchar2 default null,
   p_cost_segment29                in  varchar2 default null,
   p_cost_segment30                in  varchar2 default null,
   p_cost_concat_segments_in       in  varchar2 default null,

   p_susp_segment1                 in  varchar2 default null,
   p_susp_segment2                 in  varchar2 default null,
   p_susp_segment3                 in  varchar2 default null,
   p_susp_segment4                 in  varchar2 default null,
   p_susp_segment5                 in  varchar2 default null,
   p_susp_segment6                 in  varchar2 default null,
   p_susp_segment7                 in  varchar2 default null,
   p_susp_segment8                 in  varchar2 default null,
   p_susp_segment9                 in  varchar2 default null,
   p_susp_segment10                in  varchar2 default null,
   p_susp_segment11                in  varchar2 default null,
   p_susp_segment12                in  varchar2 default null,
   p_susp_segment13                in  varchar2 default null,
   p_susp_segment14                in  varchar2 default null,
   p_susp_segment15                in  varchar2 default null,
   p_susp_segment16                in  varchar2 default null,
   p_susp_segment17                in  varchar2 default null,
   p_susp_segment18                in  varchar2 default null,
   p_susp_segment19                in  varchar2 default null,
   p_susp_segment20                in  varchar2 default null,
   p_susp_segment21                in  varchar2 default null,
   p_susp_segment22                in  varchar2 default null,
   p_susp_segment23                in  varchar2 default null,
   p_susp_segment24                in  varchar2 default null,
   p_susp_segment25                in  varchar2 default null,
   p_susp_segment26                in  varchar2 default null,
   p_susp_segment27                in  varchar2 default null,
   p_susp_segment28                in  varchar2 default null,
   p_susp_segment29                in  varchar2 default null,
   p_susp_segment30                in  varchar2 default null,
   p_susp_concat_segments_in       in  varchar2 default null,

   p_scl_segment1                 in  varchar2 default null,
   p_scl_segment2                 in  varchar2 default null,
   p_scl_segment3                 in  varchar2 default null,
   p_scl_segment4                 in  varchar2 default null,
   p_scl_segment5                 in  varchar2 default null,
   p_scl_segment6                 in  varchar2 default null,
   p_scl_segment7                 in  varchar2 default null,
   p_scl_segment8                 in  varchar2 default null,
   p_scl_segment9                 in  varchar2 default null,
   p_scl_segment10                in  varchar2 default null,
   p_scl_segment11                in  varchar2 default null,
   p_scl_segment12                in  varchar2 default null,
   p_scl_segment13                in  varchar2 default null,
   p_scl_segment14                in  varchar2 default null,
   p_scl_segment15                in  varchar2 default null,
   p_scl_segment16                in  varchar2 default null,
   p_scl_segment17                in  varchar2 default null,
   p_scl_segment18                in  varchar2 default null,
   p_scl_segment19                in  varchar2 default null,
   p_scl_segment20                in  varchar2 default null,
   p_scl_segment21                in  varchar2 default null,
   p_scl_segment22                in  varchar2 default null,
   p_scl_segment23                in  varchar2 default null,
   p_scl_segment24                in  varchar2 default null,
   p_scl_segment25                in  varchar2 default null,
   p_scl_segment26                in  varchar2 default null,
   p_scl_segment27                in  varchar2 default null,
   p_scl_segment28                in  varchar2 default null,
   p_scl_segment29                in  varchar2 default null,
   p_scl_segment30                in  varchar2 default null,
   p_scl_concat_segments_in       in  varchar2 default null,

   p_workload_shifting_level      in  varchar2 default 'N',
   p_payslip_view_date_offset     in  number   default null,

   p_payroll_id                   out  nocopy number,
   p_org_pay_method_usage_id      out  nocopy number,
   p_prl_object_version_number    out  nocopy number,
   p_opm_object_version_number    out  nocopy number,
   p_prl_effective_start_date     out  nocopy date,
   p_prl_effective_end_date       out  nocopy date,
   p_opm_effective_start_date     out  nocopy date,
   p_opm_effective_end_date       out  nocopy date,
   p_comment_id                   out  nocopy number,

   p_cost_alloc_keyflex_id_out    out  nocopy number,
   p_susp_account_keyflex_id_out  out  nocopy number,
   p_soft_coding_keyflex_id_out   out  nocopy number,

   p_cost_concat_segments_out     out nocopy varchar2,
   p_susp_concat_segments_out     out nocopy varchar2,
   p_scl_concat_segments_out      out nocopy varchar2

   ) is

  l_effective_date          date;
  l_first_period_end_date   date;

  l_payroll_id  pay_all_payrolls_f.payroll_id%type;
  l_object_version_number pay_all_payrolls_f.object_version_number%type;
  l_effective_start_date  pay_all_payrolls_f.effective_start_date%type;
  l_effective_end_date pay_all_payrolls_f.effective_end_date%type;
  c_eot constant date := to_date('4712/12/31','YYYY/MM/DD');
  l_opm_object_version_number  number;
  l_created_by          pay_all_payrolls_f.created_by%TYPE;
  l_creation_date       pay_all_payrolls_f.creation_date%TYPE;
  l_last_update_date    pay_all_payrolls_f.last_update_date%TYPE := sysdate;
  l_last_updated_by     pay_all_payrolls_f.last_updated_by%TYPE := fnd_global.user_id;
  l_last_update_login   pay_all_payrolls_f.last_update_login%TYPE := fnd_global.login_id;
  l_comment_id          pay_all_payrolls_f.comment_id%TYPE := p_comment_id;
  l_prl_information_category pay_all_payrolls_f.prl_information_category%TYPE := null;
  l_org_pay_method_usage_id number;
  l_workload_shifting_level varchar2(30) :='N';
  l_dummy  number(15);



  l_proc                    varchar2(72)  :=  g_package||'create_payroll';

  l_cost_id_flex_num  fnd_id_flex_segments.id_flex_num%TYPE;
  l_susp_id_flex_num  fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_id_flex_num   fnd_id_flex_segments.id_flex_num%TYPE;
  l_business_group_id pay_all_payrolls_f.business_group_id%TYPE;
  l_legislation_code  varchar2(150);

  l_cost_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE := p_cost_concat_segments_in;
  l_susp_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE := p_susp_concat_segments_in;
  l_scl_concat_segments  HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE      := p_scl_concat_segments_in;

  l_cost_allocation_keyflex_id   PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE  := p_cost_alloc_keyflex_id_in;
  l_suspense_account_keyflex_id  PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE := p_susp_account_keyflex_id_in;
  l_soft_coding_keyflex_id       PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE      := p_soft_coding_keyflex_id_in;


   --Cursor for fetching the Cost allocation structure id from the business group.
   cursor csr_cost_id_flex_num(c_business_group_id PER_BUSINESS_GROUPS_PERF.business_group_id%TYPE) is
     select bg.cost_allocation_structure
     from   PER_BUSINESS_GROUPS_PERF bg
     where  bg.business_group_id = c_business_group_id;


   --Cursor for fetching the Soft coding structure id from the business group.
   cursor csr_soft_id_flex_num(c_legislation_code pay_legislation_rules.legislation_code%TYPE) is
     select lr.rule_mode
     from   pay_legislation_rules lr
     where  lr.legislation_code = c_legislation_code
     and    upper(lr.rule_type) = 'S';

   --Cursor for checking whether the given Cost Keyflex id is there or not
   cursor csr_cost_alloc_exists(c_cost_allocation_keyflex_id  PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE) is
     select pca.cost_allocation_keyflex_id
     from   pay_cost_allocation_keyflex pca
     where  pca.cost_allocation_keyflex_id = c_cost_allocation_keyflex_id;

   --Cursor for checking whether the given Soft coding Keyflex id is there or not.
   cursor csr_soft_coding_exists(c_soft_coding_keyflex_id HR_SOFT_CODING_KEYFLEX.SOFT_CODING_KEYFLEX_ID%TYPE) is
     select scl.soft_coding_keyflex_id
     from HR_SOFT_CODING_KEYFLEX scl
     where scl.soft_coding_keyflex_id = c_soft_coding_keyflex_id;

begin

  hr_utility.set_location(' Entering:'||l_proc, 10);

  --Truncate the time component from the date field.

  l_effective_date        := trunc(p_effective_date);
  l_first_period_end_date := trunc(p_first_period_end_date);

  l_effective_start_date  := l_effective_date;
  l_effective_end_date    := c_eot;

  l_created_by := l_last_updated_by;
  l_creation_date := l_last_update_date;

  --
  -- Standard savepoint.
  --
  savepoint create_payroll;

  --
  --Get the business group id.
  --
  pay_pay_bus.chk_consolidation_set_id(p_consolidation_set_id,l_business_group_id);

  --
  --Get the Legislation code.
  --
  l_legislation_code := hr_api.return_legislation_code(l_business_group_id);

  --
  -- Validate the business group and set the CLIENT_INFO.
  --
    hr_api.validate_bus_grp_id
    (p_business_group_id => l_business_group_id
    ,p_associated_column1 => 'PAY_ALL_PAYROLLS_F'
                              || '.BUSINESS_GROUP_ID');

  --
  --Checking whether the specified cost allocation kff ID is there.
  --If it is not there, it will raise an error.
  --
  if(p_cost_alloc_keyflex_id_in is not null) then
  --
	open csr_cost_alloc_exists(p_cost_alloc_keyflex_id_in);
	fetch csr_cost_alloc_exists into l_dummy;
	if (csr_cost_alloc_exists%NOTFOUND) then
	--
		close csr_cost_alloc_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','COST_ALLOCATION_KEYFLEX_ID');
		fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
		fnd_message.raise_error;
	--
   	end if;
	close csr_cost_alloc_exists;
  --
  end if;

  --
  --Checking whether the specified suspence account kff ID is there.
  --If it is not there, it will raise an error.
  --
  if (p_susp_account_keyflex_id_in is not null) then
  --
	open csr_cost_alloc_exists(p_susp_account_keyflex_id_in);
	fetch csr_cost_alloc_exists into l_dummy;
	if (csr_cost_alloc_exists%NOTFOUND) then
	--
		close csr_cost_alloc_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','SUSPENSE_ACCOUNT_KEYFLEX_ID');
		fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
		fnd_message.raise_error;
	--
   	end if;
	close csr_cost_alloc_exists;
  --
  end if;

  --
  --Checking whether the specified soft coding kff ID is there.
  --If it is not there, it will raise an error.
  --
  if(p_soft_coding_keyflex_id_in is not null) then
  --
	open csr_soft_coding_exists(p_soft_coding_keyflex_id_in);
	fetch csr_soft_coding_exists into l_dummy;
	if (csr_soft_coding_exists%NOTFOUND) then
	--
		close csr_soft_coding_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','SOFT_CODING_KEYFLEX_ID');
		fnd_message.set_token('TABLE','HR_SOFT_CODING_KEYFLEX');
		fnd_message.raise_error;
	--
   	end if;
	close csr_soft_coding_exists;
  --
  end if;

  --
  -- Call Before Process User Hook
  --
  begin
	pay_payroll_bk1.create_payroll_b
	(p_effective_date                => l_effective_date
	,p_payroll_name                  => p_payroll_name
	,p_payroll_type                  => p_payroll_type
	,p_period_type                   => p_period_type
	,p_first_period_end_date         => l_first_period_end_date
	,p_number_of_years               => p_number_of_years
	,p_pay_date_offset               => p_pay_date_offset
	,p_direct_deposit_date_offset    => p_direct_deposit_date_offset
	,p_pay_advice_date_offset        => p_pay_advice_date_offset
	,p_cut_off_date_offset           => p_cut_off_date_offset
	,p_midpoint_offset               => p_midpoint_offset
	,p_default_payment_method_id     => p_default_payment_method_id
	,p_consolidation_set_id          => p_consolidation_set_id
	,p_cost_alloc_keyflex_id_in      => p_cost_alloc_keyflex_id_in
	,p_susp_account_keyflex_id_in    => p_susp_account_keyflex_id_in
	,p_negative_pay_allowed_flag     => p_negative_pay_allowed_flag
	,p_gl_set_of_books_id            => p_gl_set_of_books_id
	,p_soft_coding_keyflex_id_in     => p_soft_coding_keyflex_id_in
	,p_comments                      => p_comments
	,p_attribute_category            => p_attribute_category
	,p_attribute1                    => p_attribute1
        ,p_attribute2                    => p_attribute2
	,p_attribute3                    => p_attribute3
	,p_attribute4                    => p_attribute4
	,p_attribute5                    => p_attribute5
	,p_attribute6                    => p_attribute6
	,p_attribute7                    => p_attribute7
	,p_attribute8                    => p_attribute8
	,p_attribute9                    => p_attribute9
	,p_attribute10                   => p_attribute10
	,p_attribute11                   => p_attribute11
        ,p_attribute12                   => p_attribute12
	,p_attribute13                   => p_attribute13
	,p_attribute14                   => p_attribute14
	,p_attribute15                   => p_attribute15
	,p_attribute16                   => p_attribute16
	,p_attribute17                   => p_attribute17
	,p_attribute18                   => p_attribute18
	,p_attribute19                   => p_attribute19
	,p_attribute20                   => p_attribute20
	,p_arrears_flag                  => p_arrears_flag
	,p_period_reset_years            => p_period_reset_years
        ,p_multi_assignments_flag        => p_multi_assignments_flag
	,p_organization_id               => p_organization_id
	,p_prl_information1         	 => p_prl_information1
	,p_prl_information2         	 => p_prl_information2
	,p_prl_information3         	 => p_prl_information3
	,p_prl_information4         	 => p_prl_information4
	,p_prl_information5         	 => p_prl_information5
	,p_prl_information6         	 => p_prl_information6
	,p_prl_information7         	 => p_prl_information7
	,p_prl_information8         	 => p_prl_information8
	,p_prl_information9         	 => p_prl_information9
	,p_prl_information10         	 => p_prl_information10
	,p_prl_information11         	 => p_prl_information11
	,p_prl_information12         	 => p_prl_information12
	,p_prl_information13         	 => p_prl_information13
	,p_prl_information14         	 => p_prl_information14
	,p_prl_information15         	 => p_prl_information15
	,p_prl_information16         	 => p_prl_information16
	,p_prl_information17         	 => p_prl_information17
	,p_prl_information18         	 => p_prl_information18
	,p_prl_information19         	 => p_prl_information19
	,p_prl_information20         	 => p_prl_information20
	,p_prl_information21         	 => p_prl_information21
	,p_prl_information22         	 => p_prl_information22
	,p_prl_information23         	 => p_prl_information23
	,p_prl_information24         	 => p_prl_information24
	,p_prl_information25         	 => p_prl_information25
	,p_prl_information26         	 => p_prl_information26
	,p_prl_information27         	 => p_prl_information27
	,p_prl_information28         	 => p_prl_information28
	,p_prl_information29         	 => p_prl_information29
	,p_prl_information30         	 => p_prl_information30

 	,p_cost_segment1                 => p_cost_segment1
        ,p_cost_segment2                 => p_cost_segment2
	,p_cost_segment3                 => p_cost_segment3
	,p_cost_segment4                 => p_cost_segment4
	,p_cost_segment5                 => p_cost_segment5
	,p_cost_segment6                 => p_cost_segment6
	,p_cost_segment7                 => p_cost_segment7
	,p_cost_segment8                 => p_cost_segment8
	,p_cost_segment9                 => p_cost_segment9
	,p_cost_segment10                => p_cost_segment10
	,p_cost_segment11                => p_cost_segment11
	,p_cost_segment12                => p_cost_segment12
	,p_cost_segment13                => p_cost_segment13
	,p_cost_segment14                => p_cost_segment14
	,p_cost_segment15                => p_cost_segment15
	,p_cost_segment16                => p_cost_segment16
	,p_cost_segment17                => p_cost_segment17
	,p_cost_segment18                => p_cost_segment18
	,p_cost_segment19                => p_cost_segment19
	,p_cost_segment20                => p_cost_segment20
	,p_cost_segment21                => p_cost_segment21
	,p_cost_segment22                => p_cost_segment22
	,p_cost_segment23                => p_cost_segment23
	,p_cost_segment24                => p_cost_segment24
	,p_cost_segment25                => p_cost_segment25
	,p_cost_segment26                => p_cost_segment26
	,p_cost_segment27                => p_cost_segment27
	,p_cost_segment28                => p_cost_segment28
	,p_cost_segment29                => p_cost_segment29
	,p_cost_segment30                => p_cost_segment30
	,p_cost_concat_segments_in       => p_cost_concat_segments_in

        ,p_susp_segment1                 => p_susp_segment1
        ,p_susp_segment2                 => p_susp_segment2
	,p_susp_segment3                 => p_susp_segment3
	,p_susp_segment4                 => p_susp_segment4
	,p_susp_segment5                 => p_susp_segment5
	,p_susp_segment6                 => p_susp_segment6
	,p_susp_segment7                 => p_susp_segment7
	,p_susp_segment8                 => p_susp_segment8
	,p_susp_segment9                 => p_susp_segment9
	,p_susp_segment10                => p_susp_segment10
	,p_susp_segment11                => p_susp_segment11
	,p_susp_segment12                => p_susp_segment12
	,p_susp_segment13                => p_susp_segment13
	,p_susp_segment14                => p_susp_segment14
	,p_susp_segment15                => p_susp_segment15
	,p_susp_segment16                => p_susp_segment16
	,p_susp_segment17                => p_susp_segment17
	,p_susp_segment18                => p_susp_segment18
	,p_susp_segment19                => p_susp_segment19
	,p_susp_segment20                => p_susp_segment20
	,p_susp_segment21                => p_susp_segment21
	,p_susp_segment22                => p_susp_segment22
	,p_susp_segment23                => p_susp_segment23
	,p_susp_segment24                => p_susp_segment24
	,p_susp_segment25                => p_susp_segment25
	,p_susp_segment26                => p_susp_segment26
	,p_susp_segment27                => p_susp_segment27
	,p_susp_segment28                => p_susp_segment28
	,p_susp_segment29                => p_susp_segment29
	,p_susp_segment30                => p_susp_segment30
	,p_susp_concat_segments_in       => p_susp_concat_segments_in

        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
	,p_scl_segment3                 => p_scl_segment3
	,p_scl_segment4                 => p_scl_segment4
	,p_scl_segment5                 => p_scl_segment5
	,p_scl_segment6                 => p_scl_segment6
	,p_scl_segment7                 => p_scl_segment7
	,p_scl_segment8                 => p_scl_segment8
	,p_scl_segment9                 => p_scl_segment9
	,p_scl_segment10                => p_scl_segment10
	,p_scl_segment11                => p_scl_segment11
	,p_scl_segment12                => p_scl_segment12
	,p_scl_segment13                => p_scl_segment13
	,p_scl_segment14                => p_scl_segment14
	,p_scl_segment15                => p_scl_segment15
	,p_scl_segment16                => p_scl_segment16
	,p_scl_segment17                => p_scl_segment17
	,p_scl_segment18                => p_scl_segment18
	,p_scl_segment19                => p_scl_segment19
	,p_scl_segment20                => p_scl_segment20
	,p_scl_segment21                => p_scl_segment21
	,p_scl_segment22                => p_scl_segment22
	,p_scl_segment23                => p_scl_segment23
	,p_scl_segment24                => p_scl_segment24
	,p_scl_segment25                => p_scl_segment25
	,p_scl_segment26                => p_scl_segment26
	,p_scl_segment27                => p_scl_segment27
	,p_scl_segment28                => p_scl_segment28
	,p_scl_segment29                => p_scl_segment29
	,p_scl_segment30                => p_scl_segment30
	,p_scl_concat_segments_in       => p_scl_concat_segments_in
        ,p_business_group_id            => l_business_group_id
	,p_workload_shifting_level      => p_workload_shifting_level
        ,p_payslip_view_date_offset     => p_payslip_view_date_offset
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_payroll'
        ,p_hook_type   => 'BP'
        );
end;

    --
    --Insert the segment values in to the respective KeyFlexFields table
    --and get the Combination_id of the inserted row.
    --
    if  (p_cost_alloc_keyflex_id_in is null)
      and (p_cost_segment1 is not null or
      p_cost_segment2 is not null  or p_cost_segment3 is not null or
      p_cost_segment4 is not null  or p_cost_segment5 is not null or
      p_cost_segment6 is not null  or p_cost_segment7 is not null or
      p_cost_segment8 is not null  or p_cost_segment9 is not null or
      p_cost_segment10 is not null or p_cost_segment11 is not null or
      p_cost_segment12 is not null or p_cost_segment13 is not null or
      p_cost_segment14 is not null or p_cost_segment15 is not null or
      p_cost_segment16 is not null or p_cost_segment17 is not null or
      p_cost_segment18 is not null or p_cost_segment19 is not null or
      p_cost_segment20 is not null or p_cost_segment21 is not null or
      p_cost_segment22 is not null or p_cost_segment23 is not null or
      p_cost_segment24 is not null or p_cost_segment25 is not null or
      p_cost_segment26 is not null or p_cost_segment27 is not null or
      p_cost_segment28 is not null or p_cost_segment29 is not null or
      p_cost_segment30 is not null or
      p_cost_concat_segments_in is not null)  then
   --
    --
    -- Fetch the ID_FLEX_NUM from the specified business group.
    --
    open csr_cost_id_flex_num(l_business_group_id);
    fetch csr_cost_id_flex_num into l_cost_id_flex_num;
    close csr_cost_id_flex_num;

    hr_kflex_utility.ins_or_sel_keyflex_comb(
	p_appl_short_name        => 'PAY'
	,p_flex_code             => 'COST'
	,p_flex_num              => l_cost_id_flex_num
	,p_segment1              => p_cost_segment1
	,p_segment2              => p_cost_segment2
	,p_segment3              => p_cost_segment3
	,p_segment4              => p_cost_segment4
	,p_segment5              => p_cost_segment5
	,p_segment6              => p_cost_segment6
	,p_segment7              => p_cost_segment7
	,p_segment8              => p_cost_segment8
	,p_segment9              => p_cost_segment9
	,p_segment10             => p_cost_segment10
	,p_segment11             => p_cost_segment11
	,p_segment12             => p_cost_segment12
	,p_segment13             => p_cost_segment13
    	,p_segment14             => p_cost_segment14
	,p_segment15             => p_cost_segment15
	,p_segment16             => p_cost_segment16
	,p_segment17             => p_cost_segment17
	,p_segment18             => p_cost_segment18
	,p_segment19             => p_cost_segment19
	,p_segment20             => p_cost_segment20
	,p_segment21             => p_cost_segment21
	,p_segment22             => p_cost_segment22
	,p_segment23             => p_cost_segment23
	,p_segment24             => p_cost_segment24
	,p_segment25             => p_cost_segment25
	,p_segment26             => p_cost_segment26
	,p_segment27             => p_cost_segment27
	,p_segment28             => p_cost_segment28
	,p_segment29             => p_cost_segment29
	,p_segment30             => p_cost_segment30
	,p_concat_segments_in    => p_cost_concat_segments_in
	,p_ccid                  => l_cost_allocation_keyflex_id
	,p_concat_segments_out   => l_cost_concat_segments
	);

	--Calling the update_cost_concat_segs to update the concat segments into the row.
	update_cost_concat_segs(p_cost_alloc_keyflex_id => l_cost_allocation_keyflex_id
		               ,p_concat_segments       => l_cost_concat_segments);
      --
    end if;
    --
    --Insert the segment values in to the respective KeyFlexFields table
    --and get the Combination_id of the inserted row.
    --
    if  (p_susp_account_keyflex_id_in is null)
    and (p_susp_segment1 is not null  or p_susp_segment2 is not null  or
         p_susp_segment3 is not null  or p_susp_segment4 is not null  or
	 p_susp_segment5 is not null  or p_susp_segment6 is not null  or
         p_susp_segment7 is not null  or p_susp_segment8 is not null  or
         p_susp_segment9 is not null  or p_susp_segment10 is not null or
         p_susp_segment11 is not null or p_susp_segment12 is not null or
         p_susp_segment13 is not null or p_susp_segment14 is not null or
         p_susp_segment15 is not null or p_susp_segment16 is not null or
         p_susp_segment17 is not null or p_susp_segment18 is not null or
         p_susp_segment19 is not null or p_susp_segment20 is not null or
         p_susp_segment21 is not null or p_susp_segment22 is not null or
         p_susp_segment23 is not null or p_susp_segment24 is not null or
         p_susp_segment25 is not null or p_susp_segment26 is not null or
         p_susp_segment27 is not null or p_susp_segment28 is not null or
         p_susp_segment29 is not null or p_susp_segment30 is not null or
         p_susp_concat_segments_in is not null)  then
     --
     --
     -- Fetch the ID_FLEX_NUM from the specified business group.
     --
     open csr_cost_id_flex_num(l_business_group_id);
     fetch csr_cost_id_flex_num into l_susp_id_flex_num;
     close csr_cost_id_flex_num;

    hr_kflex_utility.ins_or_sel_keyflex_comb(
	p_appl_short_name        => 'PAY'
	,p_flex_code             => 'COST'
	,p_flex_num              => l_susp_id_flex_num
	,p_segment1              => p_susp_segment1
	,p_segment2              => p_susp_segment2
	,p_segment3              => p_susp_segment3
	,p_segment4              => p_susp_segment4
	,p_segment5              => p_susp_segment5
	,p_segment6              => p_susp_segment6
	,p_segment7              => p_susp_segment7
	,p_segment8              => p_susp_segment8
	,p_segment9              => p_susp_segment9
	,p_segment10             => p_susp_segment10
	,p_segment11             => p_susp_segment11
	,p_segment12             => p_susp_segment12
	,p_segment13             => p_susp_segment13
    	,p_segment14             => p_susp_segment14
	,p_segment15             => p_susp_segment15
	,p_segment16             => p_susp_segment16
	,p_segment17             => p_susp_segment17
	,p_segment18             => p_susp_segment18
	,p_segment19             => p_susp_segment19
	,p_segment20             => p_susp_segment20
	,p_segment21             => p_susp_segment21
	,p_segment22             => p_susp_segment22
	,p_segment23             => p_susp_segment23
	,p_segment24             => p_susp_segment24
	,p_segment25             => p_susp_segment25
	,p_segment26             => p_susp_segment26
	,p_segment27             => p_susp_segment27
	,p_segment28             => p_susp_segment28
	,p_segment29             => p_susp_segment29
	,p_segment30             => p_susp_segment30
	,p_concat_segments_in    => p_susp_concat_segments_in
	,p_ccid                  => l_suspense_account_keyflex_id
	,p_concat_segments_out   => l_susp_concat_segments
	);
        update_cost_concat_segs(p_cost_alloc_keyflex_id => l_suspense_account_keyflex_id
		               ,p_concat_segments       => l_susp_concat_segments);
    --
    end if;
    --
    if (p_soft_coding_keyflex_id_in is null)
    and(p_scl_segment1 is not null  or p_scl_segment2 is not null  or
        p_scl_segment3 is not null  or p_scl_segment4 is not null  or
        p_scl_segment5 is not null  or p_scl_segment6 is not null  or
        p_scl_segment7 is not null  or p_scl_segment8 is not null  or
        p_scl_segment9 is not null  or p_scl_segment10 is not null or
        p_scl_segment11 is not null or p_scl_segment12 is not null or
        p_scl_segment13 is not null or p_scl_segment14 is not null or
        p_scl_segment15 is not null or p_scl_segment16 is not null or
        p_scl_segment17 is not null or p_scl_segment18 is not null or
        p_scl_segment19 is not null or p_scl_segment20 is not null or
        p_scl_segment21 is not null or p_scl_segment22 is not null or
        p_scl_segment23 is not null or p_scl_segment24 is not null or
        p_scl_segment25 is not null or p_scl_segment26 is not null or
        p_scl_segment27 is not null or p_scl_segment28 is not null or
        p_scl_segment29 is not null or p_scl_segment30 is not null or
        p_scl_concat_segments_in is not null )  then
    --
    --
    -- Fetch the ID_FLEX_NUM from the legislation code.
    --
     open csr_soft_id_flex_num(l_legislation_code);
     fetch csr_soft_id_flex_num into l_scl_id_flex_num;
     close csr_soft_id_flex_num;

     hr_kflex_utility.ins_or_sel_keyflex_comb(
	p_appl_short_name        => 'PER'
	,p_flex_code             => 'SCL'
	,p_flex_num              => l_scl_id_flex_num
	,p_segment1              => p_scl_segment1
	,p_segment2              => p_scl_segment2
	,p_segment3              => p_scl_segment3
	,p_segment4              => p_scl_segment4
	,p_segment5              => p_scl_segment5
	,p_segment6              => p_scl_segment6
	,p_segment7              => p_scl_segment7
	,p_segment8              => p_scl_segment8
	,p_segment9              => p_scl_segment9
	,p_segment10             => p_scl_segment10
	,p_segment11             => p_scl_segment11
	,p_segment12             => p_scl_segment12
	,p_segment13             => p_scl_segment13
    	,p_segment14             => p_scl_segment14
	,p_segment15             => p_scl_segment15
	,p_segment16             => p_scl_segment16
	,p_segment17             => p_scl_segment17
	,p_segment18             => p_scl_segment18
	,p_segment19             => p_scl_segment19
	,p_segment20             => p_scl_segment20
	,p_segment21             => p_scl_segment21
	,p_segment22             => p_scl_segment22
	,p_segment23             => p_scl_segment23
	,p_segment24             => p_scl_segment24
	,p_segment25             => p_scl_segment25
	,p_segment26             => p_scl_segment26
	,p_segment27             => p_scl_segment27
	,p_segment28             => p_scl_segment28
	,p_segment29             => p_scl_segment29
	,p_segment30             => p_scl_segment30
	,p_concat_segments_in    => p_scl_concat_segments_in
	,p_ccid                  => l_soft_coding_keyflex_id
	,p_concat_segments_out   => l_scl_concat_segments
	);
	--Need to call this procedure in the future if it's required to populate the
	--concatenated segments when the individual segments are given.
	--update_soft_concat_segs(p_soft_coding_keyflex_id => l_soft_coding_keyflex_id
	--	               ,p_concat_segments        => l_scl_concat_segments);

    --
    end if;

   -- Checking whether the user is passed any value to any
   -- one of the segment values.If any value is there then need to
   -- derive the information category.
   if ((p_prl_information1 is not null)  or (p_prl_information2 is not null)  or
       (p_prl_information3 is not null)  or (p_prl_information4 is not null)  or
       (p_prl_information5 is not null)  or (p_prl_information6 is not null)  or
       (p_prl_information7 is not null)  or (p_prl_information8 is not null)  or
       (p_prl_information9 is not null)  or (p_prl_information10 is not null) or
       (p_prl_information11 is not null) or (p_prl_information12 is not null) or
       (p_prl_information13 is not null) or (p_prl_information14 is not null) or
       (p_prl_information15 is not null) or (p_prl_information16 is not null) or
       (p_prl_information17 is not null) or (p_prl_information18 is not null) or
       (p_prl_information19 is not null) or (p_prl_information20 is not null) or
       (p_prl_information21 is not null) or (p_prl_information22 is not null) or
       (p_prl_information23 is not null) or (p_prl_information24 is not null) or
       (p_prl_information25 is not null) or (p_prl_information26 is not null) or
       (p_prl_information27 is not null) or (p_prl_information28 is not null) or
       (p_prl_information29 is not null) or (p_prl_information30 is not null)) then
    --
       l_prl_information_category := l_legislation_code;
    --
    end if;

    pay_pay_ins.ins(
    p_effective_date		 => l_effective_date,
    p_consolidation_set_id	 => p_consolidation_set_id,
    p_period_type		 => p_period_type,
    p_cut_off_date_offset	 => p_cut_off_date_offset,
    p_direct_deposit_date_offset => p_direct_deposit_date_offset,
    p_first_period_end_date	 => l_first_period_end_date,
    p_negative_pay_allowed_flag	 => p_negative_pay_allowed_flag,
    p_number_of_years		 => p_number_of_years,
    p_pay_advice_date_offset	 => p_pay_advice_date_offset,
    p_pay_date_offset		 => p_pay_date_offset,
    p_payroll_name		 => p_payroll_name,
    p_workload_shifting_level	 => p_workload_shifting_level,
    p_default_payment_method_id	 => p_default_payment_method_id,
    p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id,
    p_suspense_account_keyflex_id=> l_suspense_account_keyflex_id,
    p_gl_set_of_books_id	 => p_gl_set_of_books_id,
    p_soft_coding_keyflex_id	 => l_soft_coding_keyflex_id,
    p_organization_id		 => p_organization_id,
    p_comments			 => p_comments,
    p_midpoint_offset		 => p_midpoint_offset,
    p_attribute_category	 => p_attribute_category,
    p_attribute1		 => p_attribute1,
    p_attribute2                 => p_attribute2,
    p_attribute3                 => p_attribute3,
    p_attribute4                 => p_attribute4,
    p_attribute5                 => p_attribute5,
    p_attribute6                 => p_attribute6,
    p_attribute7                 => p_attribute7,
    p_attribute8                 => p_attribute8,
    p_attribute9                 => p_attribute9,
    p_attribute10                => p_attribute10,
    p_attribute11                => p_attribute11,
    p_attribute12                => p_attribute12,
    p_attribute13                => p_attribute13,
    p_attribute14                => p_attribute14,
    p_attribute15                => p_attribute15,
    p_attribute16                => p_attribute16,
    p_attribute17                => p_attribute17,
    p_attribute18                => p_attribute18,
    p_attribute19                => p_attribute19,
    p_attribute20                => p_attribute20,
    p_arrears_flag		 => p_arrears_flag,
    p_payroll_type		 => p_payroll_type,
    p_prl_information_category	 => l_prl_information_category,
    p_prl_information1           => p_prl_information1,
    p_prl_information2           => p_prl_information2,
    p_prl_information3           => p_prl_information3,
    p_prl_information4           => p_prl_information4,
    p_prl_information5           => p_prl_information5,
    p_prl_information6           => p_prl_information6,
    p_prl_information7           => p_prl_information7,
    p_prl_information8           => p_prl_information8,
    p_prl_information9           => p_prl_information9,
    p_prl_information10          => p_prl_information10,
    p_prl_information11          => p_prl_information11,
    p_prl_information12          => p_prl_information12,
    p_prl_information13          => p_prl_information13,
    p_prl_information14          => p_prl_information14,
    p_prl_information15          => p_prl_information15,
    p_prl_information16          => p_prl_information16,
    p_prl_information17          => p_prl_information17,
    p_prl_information18          => p_prl_information18,
    p_prl_information19          => p_prl_information19,
    p_prl_information20          => p_prl_information20,
    p_prl_information21          => p_prl_information21,
    p_prl_information22          => p_prl_information22,
    p_prl_information23          => p_prl_information23,
    p_prl_information24          => p_prl_information24,
    p_prl_information25          => p_prl_information25,
    p_prl_information26          => p_prl_information26,
    p_prl_information27          => p_prl_information27,
    p_prl_information28          => p_prl_information28,
    p_prl_information29          => p_prl_information29,
    p_prl_information30          => p_prl_information30,
    p_multi_assignments_flag	 => p_multi_assignments_flag,
    p_period_reset_years	 => p_period_reset_years,

    p_payslip_view_date_offset   => p_payslip_view_date_offset,

    p_payroll_id		 => l_payroll_id,
    p_object_version_number	 => l_object_version_number,
    p_effective_start_date	 => l_effective_start_date,
    p_effective_end_date	 => l_effective_end_date,
    p_comment_id		 => l_comment_id
    );

    --Added to insert the payroll_id along with the payment method into the
    --pay_org_payment_methods_f table.

    if(p_default_payment_method_id is not null) then
    --
      hr_utility.set_location(l_proc, 90);
      l_org_pay_method_usage_id := hr_ppvol.ins_pmu(
                                    l_effective_start_date,
                                    l_effective_end_date,
                                    l_payroll_id,
                                    p_default_payment_method_id);
    --
    end if;

    begin
    --
	hr_utility.trace('The value of p_cost_alloc_keyflex_id_in Before user-hook : '||p_cost_alloc_keyflex_id_in);
         pay_payroll_bk1.create_payroll_a
	(p_effective_date                => l_effective_date
	,p_payroll_name                  => p_payroll_name
	,p_payroll_type                  => p_payroll_type
	,p_period_type                   => p_period_type
	,p_first_period_end_date         => l_first_period_end_date
	,p_number_of_years               => p_number_of_years
	,p_pay_date_offset               => p_pay_date_offset
	,p_direct_deposit_date_offset    => p_direct_deposit_date_offset
	,p_pay_advice_date_offset        => p_pay_advice_date_offset
	,p_cut_off_date_offset           => p_cut_off_date_offset
	,p_midpoint_offset               => p_midpoint_offset
	,p_default_payment_method_id     => p_default_payment_method_id
	,p_consolidation_set_id          => p_consolidation_set_id
	,p_cost_alloc_keyflex_id_in      => l_cost_allocation_keyflex_id
	,p_susp_account_keyflex_id_in    => l_suspense_account_keyflex_id
	,p_negative_pay_allowed_flag     => p_negative_pay_allowed_flag
	,p_gl_set_of_books_id            => p_gl_set_of_books_id
	,p_soft_coding_keyflex_id_in     => l_soft_coding_keyflex_id
	,p_comments                      => p_comments
	,p_attribute_category            => p_attribute_category
	,p_attribute1                    => p_attribute1
        ,p_attribute2                    => p_attribute2
	,p_attribute3                    => p_attribute3
	,p_attribute4                    => p_attribute4
	,p_attribute5                    => p_attribute5
	,p_attribute6                    => p_attribute6
	,p_attribute7                    => p_attribute7
	,p_attribute8                    => p_attribute8
	,p_attribute9                    => p_attribute9
	,p_attribute10                   => p_attribute10
	,p_attribute11                   => p_attribute11
        ,p_attribute12                   => p_attribute12
	,p_attribute13                   => p_attribute13
	,p_attribute14                   => p_attribute14
	,p_attribute15                   => p_attribute15
	,p_attribute16                   => p_attribute16
	,p_attribute17                   => p_attribute17
	,p_attribute18                   => p_attribute18
	,p_attribute19                   => p_attribute19
	,p_attribute20                   => p_attribute20
	,p_arrears_flag                  => p_arrears_flag
	,p_period_reset_years            => p_period_reset_years
        ,p_multi_assignments_flag        => p_multi_assignments_flag
	,p_organization_id               => p_organization_id
	,p_prl_information1         	 => p_prl_information1
	,p_prl_information2         	 => p_prl_information2
	,p_prl_information3         	 => p_prl_information3
	,p_prl_information4         	 => p_prl_information4
	,p_prl_information5         	 => p_prl_information5
	,p_prl_information6         	 => p_prl_information6
	,p_prl_information7         	 => p_prl_information7
	,p_prl_information8         	 => p_prl_information8
	,p_prl_information9         	 => p_prl_information9
	,p_prl_information10         	 => p_prl_information10
	,p_prl_information11         	 => p_prl_information11
	,p_prl_information12         	 => p_prl_information12
	,p_prl_information13         	 => p_prl_information13
	,p_prl_information14         	 => p_prl_information14
	,p_prl_information15         	 => p_prl_information15
	,p_prl_information16         	 => p_prl_information16
	,p_prl_information17         	 => p_prl_information17
	,p_prl_information18         	 => p_prl_information18
	,p_prl_information19         	 => p_prl_information19
	,p_prl_information20         	 => p_prl_information20
	,p_prl_information21         	 => p_prl_information21
	,p_prl_information22         	 => p_prl_information22
	,p_prl_information23         	 => p_prl_information23
	,p_prl_information24         	 => p_prl_information24
	,p_prl_information25         	 => p_prl_information25
	,p_prl_information26         	 => p_prl_information26
	,p_prl_information27         	 => p_prl_information27
	,p_prl_information28         	 => p_prl_information28
	,p_prl_information29         	 => p_prl_information29
	,p_prl_information30         	 => p_prl_information30

	,p_cost_segment1                 => p_cost_segment1
        ,p_cost_segment2                 => p_cost_segment2
	,p_cost_segment3                 => p_cost_segment3
	,p_cost_segment4                 => p_cost_segment4
	,p_cost_segment5                 => p_cost_segment5
	,p_cost_segment6                 => p_cost_segment6
	,p_cost_segment7                 => p_cost_segment7
	,p_cost_segment8                 => p_cost_segment8
	,p_cost_segment9                 => p_cost_segment9
	,p_cost_segment10                => p_cost_segment10
	,p_cost_segment11                => p_cost_segment11
	,p_cost_segment12                => p_cost_segment12
	,p_cost_segment13                => p_cost_segment13
	,p_cost_segment14                => p_cost_segment14
	,p_cost_segment15                => p_cost_segment15
	,p_cost_segment16                => p_cost_segment16
	,p_cost_segment17                => p_cost_segment17
	,p_cost_segment18                => p_cost_segment18
	,p_cost_segment19                => p_cost_segment19
	,p_cost_segment20                => p_cost_segment20
	,p_cost_segment21                => p_cost_segment21
	,p_cost_segment22                => p_cost_segment22
	,p_cost_segment23                => p_cost_segment23
	,p_cost_segment24                => p_cost_segment24
	,p_cost_segment25                => p_cost_segment25
	,p_cost_segment26                => p_cost_segment26
	,p_cost_segment27                => p_cost_segment27
	,p_cost_segment28                => p_cost_segment28
	,p_cost_segment29                => p_cost_segment29
	,p_cost_segment30                => p_cost_segment30
	,p_cost_concat_segments_in       => p_cost_concat_segments_in

        ,p_susp_segment1                 => p_susp_segment1
        ,p_susp_segment2                 => p_susp_segment2
	,p_susp_segment3                 => p_susp_segment3
	,p_susp_segment4                 => p_susp_segment4
	,p_susp_segment5                 => p_susp_segment5
	,p_susp_segment6                 => p_susp_segment6
	,p_susp_segment7                 => p_susp_segment7
	,p_susp_segment8                 => p_susp_segment8
	,p_susp_segment9                 => p_susp_segment9
	,p_susp_segment10                => p_susp_segment10
	,p_susp_segment11                => p_susp_segment11
	,p_susp_segment12                => p_susp_segment12
	,p_susp_segment13                => p_susp_segment13
	,p_susp_segment14                => p_susp_segment14
	,p_susp_segment15                => p_susp_segment15
	,p_susp_segment16                => p_susp_segment16
	,p_susp_segment17                => p_susp_segment17
	,p_susp_segment18                => p_susp_segment18
	,p_susp_segment19                => p_susp_segment19
	,p_susp_segment20                => p_susp_segment20
	,p_susp_segment21                => p_susp_segment21
	,p_susp_segment22                => p_susp_segment22
	,p_susp_segment23                => p_susp_segment23
	,p_susp_segment24                => p_susp_segment24
	,p_susp_segment25                => p_susp_segment25
	,p_susp_segment26                => p_susp_segment26
	,p_susp_segment27                => p_susp_segment27
	,p_susp_segment28                => p_susp_segment28
	,p_susp_segment29                => p_susp_segment29
	,p_susp_segment30                => p_susp_segment30
	,p_susp_concat_segments_in       => p_susp_concat_segments_in

        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
	,p_scl_segment3                 => p_scl_segment3
	,p_scl_segment4                 => p_scl_segment4
	,p_scl_segment5                 => p_scl_segment5
	,p_scl_segment6                 => p_scl_segment6
	,p_scl_segment7                 => p_scl_segment7
	,p_scl_segment8                 => p_scl_segment8
	,p_scl_segment9                 => p_scl_segment9
	,p_scl_segment10                => p_scl_segment10
	,p_scl_segment11                => p_scl_segment11
	,p_scl_segment12                => p_scl_segment12
	,p_scl_segment13                => p_scl_segment13
	,p_scl_segment14                => p_scl_segment14
	,p_scl_segment15                => p_scl_segment15
	,p_scl_segment16                => p_scl_segment16
	,p_scl_segment17                => p_scl_segment17
	,p_scl_segment18                => p_scl_segment18
	,p_scl_segment19                => p_scl_segment19
	,p_scl_segment20                => p_scl_segment20
	,p_scl_segment21                => p_scl_segment21
	,p_scl_segment22                => p_scl_segment22
	,p_scl_segment23                => p_scl_segment23
	,p_scl_segment24                => p_scl_segment24
	,p_scl_segment25                => p_scl_segment25
	,p_scl_segment26                => p_scl_segment26
	,p_scl_segment27                => p_scl_segment27
	,p_scl_segment28                => p_scl_segment28
	,p_scl_segment29                => p_scl_segment29
	,p_scl_segment30                => p_scl_segment30
	,p_scl_concat_segments_in       => p_scl_concat_segments_in

	,p_workload_shifting_level      => p_workload_shifting_level
        ,p_payslip_view_date_offset     => p_payslip_view_date_offset

        ,p_cost_concat_segments_out	 => p_cost_concat_segments_out
        ,p_susp_concat_segments_out      => p_susp_concat_segments_out
	,p_scl_concat_segments_out       => p_scl_concat_segments_out

	,p_cost_alloc_keyflex_id_out     => p_cost_alloc_keyflex_id_out
        ,p_susp_account_keyflex_id_out   => p_susp_account_keyflex_id_out
        ,p_soft_coding_keyflex_id_out    => p_soft_coding_keyflex_id_out

	,p_business_group_id             => l_business_group_id

	,p_payroll_id                    => l_payroll_id
	,p_org_pay_method_usage_id       => l_org_pay_method_usage_id
	,p_prl_object_version_number     => l_object_version_number
	,p_opm_object_version_number     => l_object_version_number
	,p_prl_effective_start_date      => l_effective_start_date
        ,p_prl_effective_end_date        => l_effective_end_date
	,p_opm_effective_start_date      => l_effective_start_date
	,p_opm_effective_end_date        => l_effective_end_date
	,p_comment_id                    => p_comment_id
	);
	exception
	    when hr_api.cannot_find_prog_unit then
	      hr_api.cannot_find_prog_unit_error
		(p_module_name => 'create_payroll'
		,p_hook_type   => 'AP'
		);
    --
    end;

    if(p_validate) then
    --
      raise hr_api.validate_enabled;
    --
    end if;
    --
    -- Create time periods for the created payroll.
    --
    hr_utility.set_location(l_proc, 20);
    hr_payrolls.create_payroll_proc_periods(l_payroll_id,
                                           l_last_update_date,
                                           l_last_updated_by,
                                           l_last_update_login,
                                           l_created_by,
                                           l_creation_date,
					   l_effective_date);

    --
    -- Note that we are returning dummy object version id values
    -- because we don't currently have these columns on these
    -- tables.
    --
    hr_utility.set_location(l_proc, 100);

    p_payroll_id                :=  l_payroll_id;
    p_comment_id		:=  l_comment_id;
    p_org_pay_method_usage_id   :=  l_org_pay_method_usage_id;
    p_opm_object_version_number :=  l_object_version_number;
    p_prl_effective_start_date  :=  l_effective_start_date;
    p_prl_effective_end_date    :=  l_effective_end_date;
    p_opm_effective_start_date  :=  l_effective_start_date;
    p_opm_effective_end_date    :=  l_effective_end_date;
    p_prl_object_version_number :=  l_object_version_number;

    --
    --Setting the out parameters
    --
    if(p_cost_alloc_keyflex_id_in is not null) then
    --
	 p_cost_alloc_keyflex_id_out := p_cost_alloc_keyflex_id_in;
	 p_cost_concat_segments_out  := null;
    else
	 p_cost_alloc_keyflex_id_out := l_cost_allocation_keyflex_id;
	 p_cost_concat_segments_out  := l_cost_concat_segments;
    --
    end if;
    --
    if(p_susp_account_keyflex_id_in is not null) then
    --
	 p_susp_account_keyflex_id_out := p_susp_account_keyflex_id_in;
	 p_susp_concat_segments_out    := null;
    else
	 p_susp_account_keyflex_id_out  := l_suspense_account_keyflex_id;
	 p_susp_concat_segments_out     := l_susp_concat_segments;
    --
    end if;
    --
    if(p_soft_coding_keyflex_id_in is not null) then
    --
	 p_soft_coding_keyflex_id_out := p_soft_coding_keyflex_id_in;
	 p_scl_concat_segments_out   := null;
    else
	 p_soft_coding_keyflex_id_out := l_soft_coding_keyflex_id;
	 p_scl_concat_segments_out    := l_scl_concat_segments;
    --
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    --
    exception
    when hr_api.validate_enabled then
    --
    --Must remove all work done by this procedure.
    --
      rollback to create_payroll;

      p_payroll_id                 :=  null;
      p_org_pay_method_usage_id    :=  null;
      p_prl_object_version_number  :=  null;
      p_opm_object_version_number  :=  null;
      p_prl_effective_start_date   :=  null;
      p_prl_effective_end_date     :=  null;
      p_opm_effective_start_date   :=  null;
      p_opm_effective_end_date     :=  null;
      p_comment_id                 :=  null;

      p_cost_concat_segments_out       := null;
      p_susp_concat_segments_out       := null;
      p_scl_concat_segments_out        := null;
      p_cost_alloc_keyflex_id_out      := null;
      p_susp_account_keyflex_id_out    := null;
      p_soft_coding_keyflex_id_out     := null;


    when others then
    --
    -- Must remove all work done by this procedure.
    --
      rollback to create_payroll;

      p_payroll_id                 :=  null;
      p_org_pay_method_usage_id    :=  null;
      p_prl_object_version_number  :=  null;
      p_opm_object_version_number  :=  null;
      p_prl_effective_start_date   :=  null;
      p_prl_effective_end_date     :=  null;
      p_opm_effective_start_date   :=  null;
      p_opm_effective_end_date     :=  null;
      p_comment_id                 :=  null;

      p_cost_concat_segments_out       := null;
      p_susp_concat_segments_out       := null;
      p_scl_concat_segments_out        := null;
      p_cost_alloc_keyflex_id_out      := null;
      p_susp_account_keyflex_id_out    := null;
      p_soft_coding_keyflex_id_out     := null;

      raise;

end create_payroll;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_payroll >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_payroll
(
   p_validate                       in     boolean   default false,
   p_effective_date                 in     date,
   p_datetrack_mode                 in     varchar2,
   p_payroll_name                   in     varchar2  default hr_api.g_varchar2,
   p_number_of_years                in     number    default hr_api.g_number,
   p_default_payment_method_id      in     number    default hr_api.g_number,
   p_consolidation_set_id           in     number    default hr_api.g_number,
   p_cost_alloc_keyflex_id_in       in    number    default hr_api.g_number,
   p_susp_account_keyflex_id_in     in    number    default hr_api.g_number,
   p_negative_pay_allowed_flag      in     varchar2  default hr_api.g_varchar2,
   p_soft_coding_keyflex_id_in      in     number    default hr_api.g_number,
   p_comments                       in     varchar2  default hr_api.g_varchar2,
   p_attribute_category           in     varchar2  default hr_api.g_varchar2,
   p_attribute1                   in     varchar2  default hr_api.g_varchar2,
   p_attribute2                   in     varchar2  default hr_api.g_varchar2,
   p_attribute3                   in     varchar2  default hr_api.g_varchar2,
   p_attribute4                   in     varchar2  default hr_api.g_varchar2,
   p_attribute5                   in     varchar2  default hr_api.g_varchar2,
   p_attribute6                   in     varchar2  default hr_api.g_varchar2,
   p_attribute7                   in     varchar2  default hr_api.g_varchar2,
   p_attribute8                   in     varchar2  default hr_api.g_varchar2,
   p_attribute9                   in     varchar2  default hr_api.g_varchar2,
   p_attribute10                  in     varchar2  default hr_api.g_varchar2,
   p_attribute11                  in     varchar2  default hr_api.g_varchar2,
   p_attribute12                  in     varchar2  default hr_api.g_varchar2,
   p_attribute13                  in     varchar2  default hr_api.g_varchar2,
   p_attribute14                  in     varchar2  default hr_api.g_varchar2,
   p_attribute15                  in     varchar2  default hr_api.g_varchar2,
   p_attribute16                  in     varchar2  default hr_api.g_varchar2,
   p_attribute17                  in     varchar2  default hr_api.g_varchar2,
   p_attribute18                  in     varchar2  default hr_api.g_varchar2,
   p_attribute19                  in     varchar2  default hr_api.g_varchar2,
   p_attribute20                  in     varchar2  default hr_api.g_varchar2,
   p_arrears_flag                 in     varchar2  default hr_api.g_varchar2,
   p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2,
   p_prl_information1         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information2         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information3         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information4         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information5         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information6         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information7         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information8         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information9         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information10        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information11            in     varchar2  default hr_api.g_varchar2,
   p_prl_information12        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information13        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information14        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information15        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information16        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information17        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information18        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information19        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information20        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information21        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information22            in     varchar2  default hr_api.g_varchar2,
   p_prl_information23        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information24        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information25        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information26        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information27        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information28        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information29        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information30            in     varchar2  default hr_api.g_varchar2,

   p_cost_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment10                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment11                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment12                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment13                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment14                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment15                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment16                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment17                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment18                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment19                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment20                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment21                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment22                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment23                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment24                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment25                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment26                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment27                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment28                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment29                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment30                in  varchar2 default hr_api.g_varchar2,
   p_cost_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_susp_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment10                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment11                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment12                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment13                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment14                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment15                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment16                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment17                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment18                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment19                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment20                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment21                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment22                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment23                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment24                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment25                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment26                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment27                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment28                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment29                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment30                in  varchar2 default hr_api.g_varchar2,
   p_susp_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_scl_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment10                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment11                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment12                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment13                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment14                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment15                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment16                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment17                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment18                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment19                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment20                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment21                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment22                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment23                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment24                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment25                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment26                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment27                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment28                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment29                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment30                in  varchar2 default hr_api.g_varchar2,
   p_scl_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_workload_shifting_level      in  varchar2 default hr_api.g_varchar2,
   p_payslip_view_date_offset     in  number   default hr_api.g_number,

   p_payroll_id                    in out nocopy number,
   p_object_version_number         in out nocopy number,

   p_effective_start_date         out  nocopy date,
   p_effective_end_date           out  nocopy date,
   p_cost_alloc_keyflex_id_out    out  nocopy number,
   p_susp_account_keyflex_id_out  out  nocopy number,
   p_soft_coding_keyflex_id_out   out  nocopy number,

   p_comment_id                    out  nocopy number,
   p_cost_concat_segments_out      out  nocopy varchar2,
   p_susp_concat_segments_out      out  nocopy varchar2,
   p_scl_concat_segments_out       out  nocopy varchar2

   ) is

   l_effective_date date;
   l_object_version_number pay_all_payrolls_f.object_version_number%type;
   l_payroll_id pay_all_payrolls_f.payroll_id%type;
   l_proc                    varchar2(72)  :=  g_package||'update_payroll';
   l_effective_start_date pay_all_payrolls_f.effective_start_date%type;
   l_effective_end_date pay_all_payrolls_f.effective_end_date%type;
   l_dummy  number(15);
   l_dummy_char varchar2(1);

   l_cost_id_flex_num  fnd_id_flex_segments.id_flex_num%TYPE;
   l_susp_id_flex_num  fnd_id_flex_segments.id_flex_num%TYPE;
   l_scl_id_flex_num   fnd_id_flex_segments.id_flex_num%TYPE;
   l_business_group_id pay_all_payrolls_f.business_group_id%TYPE;
   l_prl_information_category pay_all_payrolls_f.prl_information_category%TYPE := hr_api.g_varchar2;
   l_legislation_code  varchar2(150);

   l_cost_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_susp_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_scl_concat_segments  HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE;

   l_cost_allocation_keyflex_id   PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE  := p_cost_alloc_keyflex_id_in;
   l_suspense_account_keyflex_id  PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE := p_susp_account_keyflex_id_in;
   l_soft_coding_keyflex_id       PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE      := p_soft_coding_keyflex_id_in;

   l_cost_flag boolean := false;
   l_susp_flag boolean := false;
   l_soft_flag boolean := false;

   --
   --Cursor for getting the Cost allocation structure id from business group id.
   --
   cursor csr_cost_id_flex_num(c_business_group_id PER_BUSINESS_GROUPS_PERF.business_group_id%TYPE ) is
     select bg.cost_allocation_structure
     from   PER_BUSINESS_GROUPS_PERF bg
     where  bg.business_group_id = c_business_group_id;

   --
   --Cursor for getting the Soft coding structure id from business group id.
   --
   cursor csr_soft_id_flex_num(c_legislation_code pay_legislation_rules.legislation_code%TYPE ) is
     select lr.rule_mode
     from   pay_legislation_rules lr
     where  lr.legislation_code = c_legislation_code
     and    upper(lr.rule_type) = 'S';

   --
   --Cursor for checking whether the given Cost Keyflex id is there or not.
   --
   cursor csr_cost_alloc_exists(c_cost_allocation_keyflex_id  PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE) is
     select pca.cost_allocation_keyflex_id
     from   pay_cost_allocation_keyflex pca
     where  pca.cost_allocation_keyflex_id = c_cost_allocation_keyflex_id;

   --
   --Cursor for checking whether the given Soft coding Keyflex id is there or not.
   --
   cursor csr_soft_coding_exists(c_soft_coding_keyflex_id HR_SOFT_CODING_KEYFLEX.SOFT_CODING_KEYFLEX_ID%TYPE) is
     select scl.soft_coding_keyflex_id
     from   HR_SOFT_CODING_KEYFLEX scl
     where  scl.soft_coding_keyflex_id = c_soft_coding_keyflex_id;

   --
   --Cursor for getting the business group id from the payroll id.
   --
   cursor csr_get_bg_grp(c_payroll_id PAY_ALL_PAYROLLS_F.payroll_id%TYPE) is
      select prl.business_group_id
      from   PAY_ALL_PAYROLLS_F prl
      where  prl.payroll_id = c_payroll_id
      and    trunc(p_effective_date)
      between prl.effective_start_date and prl.effective_end_date;

   --
   --Cursor for checking the payroll is valid or not
   --
   cursor csr_chk_payroll is
      select null
      from   pay_all_payrolls_f prl
      where  prl.payroll_id = p_payroll_id
      and    trunc(p_effective_date)
      between prl.effective_start_date and prl.effective_end_date;

   --
   --Cursor for getting the cost allocation keyflex id from the PAY_ALL_PAYROLLS_F
   --
   cursor csr_get_costKFF is
      select cost_allocation_keyflex_id
      from   PAY_ALL_PAYROLLS_F prl
      where  prl.payroll_id = p_payroll_id
      and    trunc(p_effective_date)
      between prl.effective_start_date and prl.effective_end_date;

   --
   --Cursor for getting the suspense account keyflex id from the PAY_ALL_PAYROLLS_F
   --
   cursor csr_get_suspenseKFF is
      select suspense_account_keyflex_id
      from   PAY_ALL_PAYROLLS_F prl
      where  prl.payroll_id = p_payroll_id
      and    trunc(p_effective_date)
      between prl.effective_start_date and prl.effective_end_date;

   --
   --Cursor for getting the soft coding keyflex id from the PAY_ALL_PAYROLLS_F
   --
   cursor csr_get_softKFF is
      select soft_coding_keyflex_id
      from   PAY_ALL_PAYROLLS_F prl
      where  prl.payroll_id = p_payroll_id
      and    trunc(p_effective_date)
      between prl.effective_start_date and prl.effective_end_date;

begin
--
    hr_utility.set_location(' Entering:'||l_proc, 10);
    --
    -- Truncate the date parameters.
    --
    l_effective_date        := trunc(p_effective_date);
    l_object_version_number := p_object_version_number;
    l_payroll_id            := p_payroll_id;

    --
    -- Standard savepoint.
    --
    savepoint update_payroll;

    --
    --check whether the payroll is existing or not.
    --
    open csr_chk_payroll;
    fetch csr_chk_payroll into l_dummy_char;
    if(csr_chk_payroll%NOTFOUND)then
    --
	 close csr_chk_payroll;
	 fnd_message.set_name('PAY', 'HR_51043_PRL_DOES_NOT_EXIST');
	 fnd_message.raise_error;
    --
    end if;
    close csr_chk_payroll;

    --
    --Get the Business Group id from the payroll id.
    --
    if(p_consolidation_set_id = hr_api.g_number) then
    --
        open csr_get_bg_grp(l_payroll_id);
	fetch csr_get_bg_grp into l_business_group_id;
	close csr_get_bg_grp;
    else
	pay_pay_bus.chk_consolidation_set_id(p_consolidation_set_id,l_business_group_id);
    --
    end if;

    --
    --Get the Legislation code.
    --
    l_legislation_code := hr_api.return_legislation_code(l_business_group_id);

    --
    -- Validate the business group id.
    --
    hr_api.validate_bus_grp_id
    (p_business_group_id => L_business_group_id
    ,p_associated_column1 => 'PAY_ALL_PAYROLLS_F'
                              || '.BUSINESS_GROUP_ID');

    hr_multi_message.end_validation_set;

    --
    --Checking whether the specified cost allocation kff ID is there.
    --If it is not there, it will raise an error.
    --
    if (( p_cost_alloc_keyflex_id_in is not null )
    and (p_cost_alloc_keyflex_id_in <> hr_api.g_number)) then
    --
	open csr_cost_alloc_exists(p_cost_alloc_keyflex_id_in);
	fetch csr_cost_alloc_exists into l_dummy;
	if (csr_cost_alloc_exists%NOTFOUND) then
	--
		close csr_cost_alloc_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','COST_ALLOCATION_KEYFLEX_ID');
		fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
		fnd_message.raise_error;
   	--
	end if;
	close csr_cost_alloc_exists;
    --
    end if;
    --
    --Checking whether the specified suspence account kff ID is there.
    --If it is not there, it will raise an error.
    --
    if((p_susp_account_keyflex_id_in is not null)
    and (p_susp_account_keyflex_id_in <> hr_api.g_number)) then
	open csr_cost_alloc_exists(p_susp_account_keyflex_id_in);
	fetch csr_cost_alloc_exists into l_dummy;
	if (csr_cost_alloc_exists%NOTFOUND) then
	--
		close csr_cost_alloc_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','SUSPENSE_ACCOUNT_KEYFLEX_ID');
		fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
		fnd_message.raise_error;
   	--
	end if;
	close csr_cost_alloc_exists;
    --
    end if;

    --
    --Checking whether the specified soft coding kff ID is there.
    --If it is not there, it will raise an error.
    --
    if((p_soft_coding_keyflex_id_in is not null)
    and (p_soft_coding_keyflex_id_in <>hr_api.g_number))then
    --
	open csr_soft_coding_exists(p_soft_coding_keyflex_id_in);
	fetch csr_soft_coding_exists into l_dummy;
	if (csr_soft_coding_exists%NOTFOUND) then
	--
		close csr_soft_coding_exists;
		fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
		fnd_message.set_token('COLUMN','SOFT_CODING_KEYFLEX_ID');
		fnd_message.set_token('TABLE','HR_SOFT_CODING_KEYFLEX');
		fnd_message.raise_error;
   	--
	end if;
	close csr_soft_coding_exists;
    --
    end if;

    begin
    --
	pay_payroll_bk2.update_payroll_b
	(p_effective_date                => l_effective_date
	,p_datetrack_mode                => p_datetrack_mode
	,p_payroll_id                    => l_payroll_id
	,p_object_version_number         => l_object_version_number
	,p_payroll_name                  => p_payroll_name
	,p_number_of_years               => p_number_of_years
	,p_default_payment_method_id     => p_default_payment_method_id
	,p_consolidation_set_id          => p_consolidation_set_id
	,p_cost_alloc_keyflex_id_in      => p_cost_alloc_keyflex_id_in
	,p_susp_account_keyflex_id_in    => p_susp_account_keyflex_id_in
	,p_negative_pay_allowed_flag     => p_negative_pay_allowed_flag
	,p_soft_coding_keyflex_id_in     => p_soft_coding_keyflex_id_in
	,p_comments                      => p_comments
	,p_attribute_category            => p_attribute_category
	,p_attribute1                    => p_attribute1
        ,p_attribute2                    => p_attribute2
	,p_attribute3                    => p_attribute3
	,p_attribute4                    => p_attribute4
	,p_attribute5                    => p_attribute5
	,p_attribute6                    => p_attribute6
	,p_attribute7                    => p_attribute7
	,p_attribute8                    => p_attribute8
	,p_attribute9                    => p_attribute9
	,p_attribute10                   => p_attribute10
	,p_attribute11                   => p_attribute11
        ,p_attribute12                   => p_attribute12
	,p_attribute13                   => p_attribute13
	,p_attribute14                   => p_attribute14
	,p_attribute15                   => p_attribute15
	,p_attribute16                   => p_attribute16
	,p_attribute17                   => p_attribute17
	,p_attribute18                   => p_attribute18
	,p_attribute19                   => p_attribute19
	,p_attribute20                   => p_attribute20
	,p_arrears_flag                  => p_arrears_flag
	,p_multi_assignments_flag        => p_multi_assignments_flag
	,p_prl_information1         	 => p_prl_information1
	,p_prl_information2         	 => p_prl_information2
	,p_prl_information3         	 => p_prl_information3
	,p_prl_information4         	 => p_prl_information4
	,p_prl_information5         	 => p_prl_information5
	,p_prl_information6         	 => p_prl_information6
	,p_prl_information7         	 => p_prl_information7
	,p_prl_information8         	 => p_prl_information8
	,p_prl_information9         	 => p_prl_information9
	,p_prl_information10         	 => p_prl_information10
	,p_prl_information11         	 => p_prl_information11
	,p_prl_information12         	 => p_prl_information12
	,p_prl_information13         	 => p_prl_information13
	,p_prl_information14         	 => p_prl_information14
	,p_prl_information15         	 => p_prl_information15
	,p_prl_information16         	 => p_prl_information16
	,p_prl_information17         	 => p_prl_information17
	,p_prl_information18         	 => p_prl_information18
	,p_prl_information19         	 => p_prl_information19
	,p_prl_information20         	 => p_prl_information20
	,p_prl_information21         	 => p_prl_information21
	,p_prl_information22         	 => p_prl_information22
	,p_prl_information23         	 => p_prl_information23
	,p_prl_information24         	 => p_prl_information24
	,p_prl_information25         	 => p_prl_information25
	,p_prl_information26         	 => p_prl_information26
	,p_prl_information27         	 => p_prl_information27
	,p_prl_information28         	 => p_prl_information28
	,p_prl_information29         	 => p_prl_information29
	,p_prl_information30         	 => p_prl_information30

	,p_cost_segment1                 => p_cost_segment1
        ,p_cost_segment2                 => p_cost_segment2
	,p_cost_segment3                 => p_cost_segment3
	,p_cost_segment4                 => p_cost_segment4
	,p_cost_segment5                 => p_cost_segment5
	,p_cost_segment6                 => p_cost_segment6
	,p_cost_segment7                 => p_cost_segment7
	,p_cost_segment8                 => p_cost_segment8
	,p_cost_segment9                 => p_cost_segment9
	,p_cost_segment10                => p_cost_segment10
	,p_cost_segment11                => p_cost_segment11
	,p_cost_segment12                => p_cost_segment12
	,p_cost_segment13                => p_cost_segment13
	,p_cost_segment14                => p_cost_segment14
	,p_cost_segment15                => p_cost_segment15
	,p_cost_segment16                => p_cost_segment16
	,p_cost_segment17                => p_cost_segment17
	,p_cost_segment18                => p_cost_segment18
	,p_cost_segment19                => p_cost_segment19
	,p_cost_segment20                => p_cost_segment20
	,p_cost_segment21                => p_cost_segment21
	,p_cost_segment22                => p_cost_segment22
	,p_cost_segment23                => p_cost_segment23
	,p_cost_segment24                => p_cost_segment24
	,p_cost_segment25                => p_cost_segment25
	,p_cost_segment26                => p_cost_segment26
	,p_cost_segment27                => p_cost_segment27
	,p_cost_segment28                => p_cost_segment28
	,p_cost_segment29                => p_cost_segment29
	,p_cost_segment30                => p_cost_segment30
	,p_cost_concat_segments_in       => p_cost_concat_segments_in

        ,p_susp_segment1                 => p_susp_segment1
        ,p_susp_segment2                 => p_susp_segment2
	,p_susp_segment3                 => p_susp_segment3
	,p_susp_segment4                 => p_susp_segment4
	,p_susp_segment5                 => p_susp_segment5
	,p_susp_segment6                 => p_susp_segment6
	,p_susp_segment7                 => p_susp_segment7
	,p_susp_segment8                 => p_susp_segment8
	,p_susp_segment9                 => p_susp_segment9
	,p_susp_segment10                => p_susp_segment10
	,p_susp_segment11                => p_susp_segment11
	,p_susp_segment12                => p_susp_segment12
	,p_susp_segment13                => p_susp_segment13
	,p_susp_segment14                => p_susp_segment14
	,p_susp_segment15                => p_susp_segment15
	,p_susp_segment16                => p_susp_segment16
	,p_susp_segment17                => p_susp_segment17
	,p_susp_segment18                => p_susp_segment18
	,p_susp_segment19                => p_susp_segment19
	,p_susp_segment20                => p_susp_segment20
	,p_susp_segment21                => p_susp_segment21
	,p_susp_segment22                => p_susp_segment22
	,p_susp_segment23                => p_susp_segment23
	,p_susp_segment24                => p_susp_segment24
	,p_susp_segment25                => p_susp_segment25
	,p_susp_segment26                => p_susp_segment26
	,p_susp_segment27                => p_susp_segment27
	,p_susp_segment28                => p_susp_segment28
	,p_susp_segment29                => p_susp_segment29
	,p_susp_segment30                => p_susp_segment30
	,p_susp_concat_segments_in       => p_susp_concat_segments_in

        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
	,p_scl_segment3                 => p_scl_segment3
	,p_scl_segment4                 => p_scl_segment4
	,p_scl_segment5                 => p_scl_segment5
	,p_scl_segment6                 => p_scl_segment6
	,p_scl_segment7                 => p_scl_segment7
	,p_scl_segment8                 => p_scl_segment8
	,p_scl_segment9                 => p_scl_segment9
	,p_scl_segment10                => p_scl_segment10
	,p_scl_segment11                => p_scl_segment11
	,p_scl_segment12                => p_scl_segment12
	,p_scl_segment13                => p_scl_segment13
	,p_scl_segment14                => p_scl_segment14
	,p_scl_segment15                => p_scl_segment15
	,p_scl_segment16                => p_scl_segment16
	,p_scl_segment17                => p_scl_segment17
	,p_scl_segment18                => p_scl_segment18
	,p_scl_segment19                => p_scl_segment19
	,p_scl_segment20                => p_scl_segment20
	,p_scl_segment21                => p_scl_segment21
	,p_scl_segment22                => p_scl_segment22
	,p_scl_segment23                => p_scl_segment23
	,p_scl_segment24                => p_scl_segment24
	,p_scl_segment25                => p_scl_segment25
	,p_scl_segment26                => p_scl_segment26
	,p_scl_segment27                => p_scl_segment27
	,p_scl_segment28                => p_scl_segment28
	,p_scl_segment29                => p_scl_segment29
	,p_scl_segment30                => p_scl_segment30
	,p_scl_concat_segments_in       => p_scl_concat_segments_in

	,p_business_group_id            => l_business_group_id

	,p_workload_shifting_level      => p_workload_shifting_level
        ,p_payslip_view_date_offset     => p_payslip_view_date_offset

	);

    exception
         when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
              (p_module_name => 'update_payroll'
              ,p_hook_type   => 'BP');
    --
    end;

    if  (p_cost_alloc_keyflex_id_in = hr_api.g_number) and
     (p_cost_segment1  <> hr_api.g_varchar2 or p_cost_segment2  <> hr_api.g_varchar2 or
      p_cost_segment3  <> hr_api.g_varchar2 or p_cost_segment4  <> hr_api.g_varchar2 or
      p_cost_segment5  <> hr_api.g_varchar2 or p_cost_segment6  <> hr_api.g_varchar2 or
      p_cost_segment7  <> hr_api.g_varchar2 or p_cost_segment8  <> hr_api.g_varchar2 or
      p_cost_segment9  <> hr_api.g_varchar2 or p_cost_segment10 <> hr_api.g_varchar2 or
      p_cost_segment11 <> hr_api.g_varchar2 or p_cost_segment12 <> hr_api.g_varchar2 or
      p_cost_segment13 <> hr_api.g_varchar2 or p_cost_segment14 <> hr_api.g_varchar2 or
      p_cost_segment15 <> hr_api.g_varchar2 or p_cost_segment16 <> hr_api.g_varchar2 or
      p_cost_segment17 <> hr_api.g_varchar2 or p_cost_segment18 <> hr_api.g_varchar2 or
      p_cost_segment19 <> hr_api.g_varchar2 or p_cost_segment20 <> hr_api.g_varchar2 or
      p_cost_segment21 <> hr_api.g_varchar2 or p_cost_segment22 <> hr_api.g_varchar2 or
      p_cost_segment23 <> hr_api.g_varchar2 or p_cost_segment24 <> hr_api.g_varchar2 or
      p_cost_segment25 <> hr_api.g_varchar2 or p_cost_segment26 <> hr_api.g_varchar2 or
      p_cost_segment27 <> hr_api.g_varchar2 or p_cost_segment28 <> hr_api.g_varchar2 or
      p_cost_segment29 <> hr_api.g_varchar2 or p_cost_segment30 <> hr_api.g_varchar2 or
      p_cost_concat_segments_in <> hr_api.g_varchar2)
   then
   --
       --
       --Retrieve the COSTING  keyflex ID and structure identifier.
       --

   	open csr_get_costKFF;
	fetch csr_get_costKFF into l_cost_allocation_keyflex_id;
	if(csr_get_costKFF%NOTFOUND) then
	--
		close csr_get_costKFF;
		fnd_message.set_name('PAY', 'HR_INVALID_PAYROLL_ID');
	        fnd_message.raise_error;
	--
	end if;
	close csr_get_costKFF;

	open csr_cost_id_flex_num(l_business_group_id);
	fetch csr_cost_id_flex_num into l_cost_id_flex_num;
	close csr_cost_id_flex_num;

	--
	--Make the flag true
	--
        l_cost_flag := true;

        hr_kflex_utility.upd_or_sel_keyflex_comb(
	p_appl_short_name        => 'PAY'
	,p_flex_code             => 'COST'
	,p_flex_num              => l_cost_id_flex_num
	,p_ccid                  => l_cost_allocation_keyflex_id
	,p_segment1              => p_cost_segment1
	,p_segment2              => p_cost_segment2
	,p_segment3              => p_cost_segment3
	,p_segment4              => p_cost_segment4
	,p_segment5              => p_cost_segment5
	,p_segment6              => p_cost_segment6
	,p_segment7              => p_cost_segment7
	,p_segment8              => p_cost_segment8
	,p_segment9              => p_cost_segment9
	,p_segment10             => p_cost_segment10
	,p_segment11             => p_cost_segment11
	,p_segment12             => p_cost_segment12
	,p_segment13             => p_cost_segment13
    	,p_segment14             => p_cost_segment14
	,p_segment15             => p_cost_segment15
	,p_segment16             => p_cost_segment16
	,p_segment17             => p_cost_segment17
	,p_segment18             => p_cost_segment18
	,p_segment19             => p_cost_segment19
	,p_segment20             => p_cost_segment20
	,p_segment21             => p_cost_segment21
	,p_segment22             => p_cost_segment22
	,p_segment23             => p_cost_segment23
	,p_segment24             => p_cost_segment24
	,p_segment25             => p_cost_segment25
	,p_segment26             => p_cost_segment26
	,p_segment27             => p_cost_segment27
	,p_segment28             => p_cost_segment28
	,p_segment29             => p_cost_segment29
	,p_segment30             => p_cost_segment30
	,p_concat_segments_in    => p_cost_concat_segments_in
	,p_concat_segments_out   => p_cost_concat_segments_out
	);
	--Calling the update_cost_concat_segs to update the concat segments into the row.
	update_cost_concat_segs(p_cost_alloc_keyflex_id => l_cost_allocation_keyflex_id
		               ,p_concat_segments       => p_cost_concat_segments_out);
	p_cost_alloc_keyflex_id_out  := l_cost_allocation_keyflex_id;
    --
    end if;

    if (p_susp_account_keyflex_id_in = hr_api.g_number) and
     (p_susp_segment1  <> hr_api.g_varchar2 or  p_susp_segment2  <> hr_api.g_varchar2 or
      p_susp_segment3  <> hr_api.g_varchar2 or  p_susp_segment4  <> hr_api.g_varchar2 or
      p_susp_segment5  <> hr_api.g_varchar2 or  p_susp_segment6  <> hr_api.g_varchar2 or
      p_susp_segment7  <> hr_api.g_varchar2 or  p_susp_segment8  <> hr_api.g_varchar2 or
      p_susp_segment9  <> hr_api.g_varchar2 or  p_susp_segment10 <> hr_api.g_varchar2 or
      p_susp_segment11 <> hr_api.g_varchar2 or  p_susp_segment12 <> hr_api.g_varchar2 or
      p_susp_segment13 <> hr_api.g_varchar2 or  p_susp_segment14 <> hr_api.g_varchar2 or
      p_susp_segment15 <> hr_api.g_varchar2 or  p_susp_segment16 <> hr_api.g_varchar2 or
      p_susp_segment17 <> hr_api.g_varchar2 or  p_susp_segment18 <> hr_api.g_varchar2 or
      p_susp_segment19 <> hr_api.g_varchar2 or  p_susp_segment20 <> hr_api.g_varchar2 or
      p_susp_segment21 <> hr_api.g_varchar2 or  p_susp_segment22 <> hr_api.g_varchar2 or
      p_susp_segment23 <> hr_api.g_varchar2 or  p_susp_segment24 <> hr_api.g_varchar2 or
      p_susp_segment25 <> hr_api.g_varchar2 or  p_susp_segment26 <> hr_api.g_varchar2 or
      p_susp_segment27 <> hr_api.g_varchar2 or  p_susp_segment28 <> hr_api.g_varchar2 or
      p_susp_segment29 <> hr_api.g_varchar2 or  p_susp_segment30 <> hr_api.g_varchar2 or
      p_susp_concat_segments_in <> hr_api.g_varchar2)
   then
    --
	--
	--Retrieve the suspense account keyflex ID and structure identifier.
	--
	open csr_get_suspenseKFF;
	fetch csr_get_suspenseKFF into l_suspense_account_keyflex_id;
	if(csr_get_suspenseKFF%NOTFOUND) then
	--
		close csr_get_suspenseKFF;
		fnd_message.set_name('PAY', 'HR_INVALID_PAYROLL_ID');
		fnd_message.raise_error;
	--
	end if;
	close csr_get_suspenseKFF;

    	open csr_cost_id_flex_num(l_business_group_id);
	fetch csr_cost_id_flex_num into l_susp_id_flex_num;
	Close csr_cost_id_flex_num;

        --
	--Make the flag true.
	--
        l_susp_flag := true;

        hr_kflex_utility.upd_or_sel_keyflex_comb(
	p_appl_short_name        => 'PAY'
	,p_flex_code             => 'COST'
	,p_flex_num              => l_susp_id_flex_num
	,p_ccid                  => l_suspense_account_keyflex_id
	,p_segment1              => p_susp_segment1
	,p_segment2              => p_susp_segment2
	,p_segment3              => p_susp_segment3
	,p_segment4              => p_susp_segment4
	,p_segment5              => p_susp_segment5
	,p_segment6              => p_susp_segment6
	,p_segment7              => p_susp_segment7
	,p_segment8              => p_susp_segment8
	,p_segment9              => p_susp_segment9
	,p_segment10             => p_susp_segment10
	,p_segment11             => p_susp_segment11
	,p_segment12             => p_susp_segment12
	,p_segment13             => p_susp_segment13
    	,p_segment14             => p_susp_segment14
	,p_segment15             => p_susp_segment15
	,p_segment16             => p_susp_segment16
	,p_segment17             => p_susp_segment17
	,p_segment18             => p_susp_segment18
	,p_segment19             => p_susp_segment19
	,p_segment20             => p_susp_segment20
	,p_segment21             => p_susp_segment21
	,p_segment22             => p_susp_segment22
	,p_segment23             => p_susp_segment23
	,p_segment24             => p_susp_segment24
	,p_segment25             => p_susp_segment25
	,p_segment26             => p_susp_segment26
	,p_segment27             => p_susp_segment27
	,p_segment28             => p_susp_segment28
	,p_segment29             => p_susp_segment29
	,p_segment30             => p_susp_segment30
	,p_concat_segments_in    => p_susp_concat_segments_in
	,p_concat_segments_out   => p_susp_concat_segments_out
	);
        update_cost_concat_segs(p_cost_alloc_keyflex_id => l_suspense_account_keyflex_id
		               ,p_concat_segments       => p_susp_concat_segments_out);
	p_susp_account_keyflex_id_out  := l_suspense_account_keyflex_id;

    --
    end if;

    if (p_soft_coding_keyflex_id_in = hr_api.g_number) and
     (p_scl_segment1  <> hr_api.g_varchar2 or p_scl_segment2  <> hr_api.g_varchar2 or
      p_scl_segment3  <> hr_api.g_varchar2 or p_scl_segment4  <> hr_api.g_varchar2 or
      p_scl_segment5  <> hr_api.g_varchar2 or p_scl_segment6  <> hr_api.g_varchar2 or
      p_scl_segment7  <> hr_api.g_varchar2 or p_scl_segment8  <> hr_api.g_varchar2 or
      p_scl_segment9  <> hr_api.g_varchar2 or p_scl_segment10 <> hr_api.g_varchar2 or
      p_scl_segment11 <> hr_api.g_varchar2 or p_scl_segment12 <> hr_api.g_varchar2 or
      p_scl_segment13 <> hr_api.g_varchar2 or p_scl_segment14 <> hr_api.g_varchar2 or
      p_scl_segment15 <> hr_api.g_varchar2 or p_scl_segment16 <> hr_api.g_varchar2 or
      p_scl_segment17 <> hr_api.g_varchar2 or p_scl_segment18 <> hr_api.g_varchar2 or
      p_scl_segment19 <> hr_api.g_varchar2 or p_scl_segment20 <> hr_api.g_varchar2 or
      p_scl_segment21 <> hr_api.g_varchar2 or p_scl_segment22 <> hr_api.g_varchar2 or
      p_scl_segment23 <> hr_api.g_varchar2 or p_scl_segment24 <> hr_api.g_varchar2 or
      p_scl_segment25 <> hr_api.g_varchar2 or p_scl_segment26 <> hr_api.g_varchar2 or
      p_scl_segment27 <> hr_api.g_varchar2 or p_scl_segment28 <> hr_api.g_varchar2 or
      p_scl_segment29 <> hr_api.g_varchar2 or p_scl_segment30 <> hr_api.g_varchar2 or
      p_scl_concat_segments_in <> hr_api.g_varchar2)
    then
    --
        --
	--Retrieve the soft account keyflex ID and structure identifier.
	--
   	open csr_get_softKFF;
	fetch csr_get_softKFF into l_soft_coding_keyflex_id;
	if(csr_get_softKFF%NOTFOUND) then
	--
		close csr_get_softKFF;
		fnd_message.set_name('PAY', 'HR_INVALID_PAYROLL_ID');
	        fnd_message.raise_error;
	--
	end if;
        close csr_get_softKFF;

        open csr_soft_id_flex_num(l_legislation_code);
	fetch csr_soft_id_flex_num into l_scl_id_flex_num;
	close csr_soft_id_flex_num;

        --
	--Make the flag true.
	--
        l_soft_flag := true;

        hr_kflex_utility.upd_or_sel_keyflex_comb(
	p_appl_short_name        => 'PER'
	,p_flex_code             => 'SCL'
	,p_flex_num              => l_scl_id_flex_num
	,p_ccid                  => l_soft_coding_keyflex_id
	,p_segment1              => p_scl_segment1
	,p_segment2              => p_scl_segment2
	,p_segment3              => p_scl_segment3
	,p_segment4              => p_scl_segment4
	,p_segment5              => p_scl_segment5
	,p_segment6              => p_scl_segment6
	,p_segment7              => p_scl_segment7
	,p_segment8              => p_scl_segment8
	,p_segment9              => p_scl_segment9
	,p_segment10             => p_scl_segment10
	,p_segment11             => p_scl_segment11
	,p_segment12             => p_scl_segment12
	,p_segment13             => p_scl_segment13
    	,p_segment14             => p_scl_segment14
	,p_segment15             => p_scl_segment15
	,p_segment16             => p_scl_segment16
	,p_segment17             => p_scl_segment17
	,p_segment18             => p_scl_segment18
	,p_segment19             => p_scl_segment19
	,p_segment20             => p_scl_segment20
	,p_segment21             => p_scl_segment21
	,p_segment22             => p_scl_segment22
	,p_segment23             => p_scl_segment23
	,p_segment24             => p_scl_segment24
	,p_segment25             => p_scl_segment25
	,p_segment26             => p_scl_segment26
	,p_segment27             => p_scl_segment27
	,p_segment28             => p_scl_segment28
	,p_segment29             => p_scl_segment29
	,p_segment30             => p_scl_segment30
	,p_concat_segments_in    => p_scl_concat_segments_in
	,p_concat_segments_out   => p_scl_concat_segments_out
	);
	--Need to call this procedure in the future if it's required to update the
	--concatenated segments when the individual segments are given.

	--update_soft_concat_segs(p_soft_coding_keyflex_id => l_soft_coding_keyflex_id
	--	               ,p_concat_segments        => p_scl_concat_segments_out);
	p_soft_coding_keyflex_id_out := l_soft_coding_keyflex_id;

    --
    end if;
    if ((p_prl_information1  <> hr_api.g_varchar2) or (p_prl_information2  <> hr_api.g_varchar2)  or
       (p_prl_information3  <> hr_api.g_varchar2) or (p_prl_information4  <> hr_api.g_varchar2)  or
       (p_prl_information5  <> hr_api.g_varchar2) or (p_prl_information6  <> hr_api.g_varchar2)  or
       (p_prl_information7  <> hr_api.g_varchar2) or (p_prl_information8  <> hr_api.g_varchar2)  or
       (p_prl_information9  <> hr_api.g_varchar2) or (p_prl_information10 <> hr_api.g_varchar2)  or
       (p_prl_information11 <> hr_api.g_varchar2) or (p_prl_information12 <> hr_api.g_varchar2)  or
       (p_prl_information13 <> hr_api.g_varchar2) or (p_prl_information14 <> hr_api.g_varchar2)  or
       (p_prl_information15 <> hr_api.g_varchar2) or (p_prl_information16 <> hr_api.g_varchar2)  or
       (p_prl_information17 <> hr_api.g_varchar2) or (p_prl_information18 <> hr_api.g_varchar2)  or
       (p_prl_information19 <> hr_api.g_varchar2) or (p_prl_information20 <> hr_api.g_varchar2)  or
       (p_prl_information21 <> hr_api.g_varchar2) or (p_prl_information22 <> hr_api.g_varchar2)  or
       (p_prl_information23 <> hr_api.g_varchar2) or (p_prl_information24 <> hr_api.g_varchar2)  or
       (p_prl_information25 <> hr_api.g_varchar2) or (p_prl_information26 <> hr_api.g_varchar2)  or
       (p_prl_information27 <> hr_api.g_varchar2) or (p_prl_information28 <> hr_api.g_varchar2)  or
       (p_prl_information29 <> hr_api.g_varchar2) or (p_prl_information30 <> hr_api.g_varchar2)) then
    --
       l_prl_information_category := l_legislation_code;
    --
    end if;

pay_pay_upd.upd
  (p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_mode
  ,p_payroll_id                   => l_payroll_id
  ,p_object_version_number        => l_object_version_number
  ,p_consolidation_set_id         => p_consolidation_set_id
  ,p_negative_pay_allowed_flag    => p_negative_pay_allowed_flag
  ,p_number_of_years              => p_number_of_years
  ,p_payroll_name                 => p_payroll_name
  ,p_default_payment_method_id    => p_default_payment_method_id
  ,p_cost_allocation_keyflex_id   => l_cost_allocation_keyflex_id
  ,p_suspense_account_keyflex_id  => l_suspense_account_keyflex_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_comments                     => p_comments
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_arrears_flag                 => p_arrears_flag
  ,p_prl_information_category     => l_prl_information_category
  ,p_prl_information1             => p_prl_information1
  ,p_prl_information2             => p_prl_information2
  ,p_prl_information3             => p_prl_information3
  ,p_prl_information4             => p_prl_information4
  ,p_prl_information5             => p_prl_information5
  ,p_prl_information6             => p_prl_information6
  ,p_prl_information7             => p_prl_information7
  ,p_prl_information8             => p_prl_information8
  ,p_prl_information9             => p_prl_information9
  ,p_prl_information10            => p_prl_information10
  ,p_prl_information11            => p_prl_information11
  ,p_prl_information12            => p_prl_information12
  ,p_prl_information13            => p_prl_information13
  ,p_prl_information14            => p_prl_information14
  ,p_prl_information15            => p_prl_information15
  ,p_prl_information16            => p_prl_information16
  ,p_prl_information17            => p_prl_information17
  ,p_prl_information18            => p_prl_information18
  ,p_prl_information19            => p_prl_information19
  ,p_prl_information20            => p_prl_information20
  ,p_prl_information21            => p_prl_information21
  ,p_prl_information22            => p_prl_information22
  ,p_prl_information23            => p_prl_information23
  ,p_prl_information24            => p_prl_information24
  ,p_prl_information25            => p_prl_information25
  ,p_prl_information26            => p_prl_information26
  ,p_prl_information27            => p_prl_information27
  ,p_prl_information28            => p_prl_information28
  ,p_prl_information29            => p_prl_information29
  ,p_prl_information30            => p_prl_information30
  /* Added multi_assignment_flag field to update the value of that flag */
  ,p_multi_assignments_flag       => p_multi_assignments_flag
  ,p_workload_shifting_level      => p_workload_shifting_level
  ,p_payslip_view_date_offset     => p_payslip_view_date_offset

  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_comment_id                   => p_comment_id);

  hr_payrolls.create_payroll_proc_periods
      (l_payroll_id,
       null,  -- last_update_date
       null,  -- last_updated_by
       null,  -- last_update_login
       null,  -- created_by
       null,  -- creation_date
       l_effective_date -- effective_date
      );

begin
	pay_payroll_bk2.update_payroll_a
	(p_effective_date                => l_effective_date
	,p_datetrack_mode                => p_datetrack_mode
	,p_payroll_id                    => l_payroll_id
	,p_object_version_number         => l_object_version_number
	,p_payroll_name                  => p_payroll_name
	,p_number_of_years               => p_number_of_years
	,p_default_payment_method_id     => p_default_payment_method_id
	,p_consolidation_set_id          => p_consolidation_set_id
	,p_cost_alloc_keyflex_id_in      => l_cost_allocation_keyflex_id
	,p_susp_account_keyflex_id_in    => l_suspense_account_keyflex_id
	,p_negative_pay_allowed_flag     => p_negative_pay_allowed_flag
	,p_soft_coding_keyflex_id_in     => l_soft_coding_keyflex_id
	,p_comments                      => p_comments
	,p_attribute_category            => p_attribute_category
	,p_attribute1                    => p_attribute1
        ,p_attribute2                    => p_attribute2
	,p_attribute3                    => p_attribute3
	,p_attribute4                    => p_attribute4
	,p_attribute5                    => p_attribute5
	,p_attribute6                    => p_attribute6
	,p_attribute7                    => p_attribute7
	,p_attribute8                    => p_attribute8
	,p_attribute9                    => p_attribute9
	,p_attribute10                   => p_attribute10
	,p_attribute11                   => p_attribute11
        ,p_attribute12                   => p_attribute12
	,p_attribute13                   => p_attribute13
	,p_attribute14                   => p_attribute14
	,p_attribute15                   => p_attribute15
	,p_attribute16                   => p_attribute16
	,p_attribute17                   => p_attribute17
	,p_attribute18                   => p_attribute18
	,p_attribute19                   => p_attribute19
	,p_attribute20                   => p_attribute20
	,p_arrears_flag                  => p_arrears_flag
	,p_multi_assignments_flag        => p_multi_assignments_flag
	,p_prl_information1         	 => p_prl_information1
	,p_prl_information2         	 => p_prl_information2
	,p_prl_information3         	 => p_prl_information3
	,p_prl_information4         	 => p_prl_information4
	,p_prl_information5         	 => p_prl_information5
	,p_prl_information6         	 => p_prl_information6
	,p_prl_information7         	 => p_prl_information7
	,p_prl_information8         	 => p_prl_information8
	,p_prl_information9         	 => p_prl_information9
	,p_prl_information10         	 => p_prl_information10
	,p_prl_information11         	 => p_prl_information11
	,p_prl_information12         	 => p_prl_information12
	,p_prl_information13         	 => p_prl_information13
	,p_prl_information14         	 => p_prl_information14
	,p_prl_information15         	 => p_prl_information15
	,p_prl_information16         	 => p_prl_information16
	,p_prl_information17         	 => p_prl_information17
	,p_prl_information18         	 => p_prl_information18
	,p_prl_information19         	 => p_prl_information19
	,p_prl_information20         	 => p_prl_information20
	,p_prl_information21         	 => p_prl_information21
	,p_prl_information22         	 => p_prl_information22
	,p_prl_information23         	 => p_prl_information23
	,p_prl_information24         	 => p_prl_information24
	,p_prl_information25         	 => p_prl_information25
	,p_prl_information26         	 => p_prl_information26
	,p_prl_information27         	 => p_prl_information27
	,p_prl_information28         	 => p_prl_information28
	,p_prl_information29         	 => p_prl_information29
	,p_prl_information30         	 => p_prl_information30

        ,p_cost_segment1                 => p_cost_segment1
        ,p_cost_segment2                 => p_cost_segment2
	,p_cost_segment3                 => p_cost_segment3
	,p_cost_segment4                 => p_cost_segment4
	,p_cost_segment5                 => p_cost_segment5
	,p_cost_segment6                 => p_cost_segment6
	,p_cost_segment7                 => p_cost_segment7
	,p_cost_segment8                 => p_cost_segment8
	,p_cost_segment9                 => p_cost_segment9
	,p_cost_segment10                => p_cost_segment10
	,p_cost_segment11                => p_cost_segment11
	,p_cost_segment12                => p_cost_segment12
	,p_cost_segment13                => p_cost_segment13
	,p_cost_segment14                => p_cost_segment14
	,p_cost_segment15                => p_cost_segment15
	,p_cost_segment16                => p_cost_segment16
	,p_cost_segment17                => p_cost_segment17
	,p_cost_segment18                => p_cost_segment18
	,p_cost_segment19                => p_cost_segment19
	,p_cost_segment20                => p_cost_segment20
	,p_cost_segment21                => p_cost_segment21
	,p_cost_segment22                => p_cost_segment22
	,p_cost_segment23                => p_cost_segment23
	,p_cost_segment24                => p_cost_segment24
	,p_cost_segment25                => p_cost_segment25
	,p_cost_segment26                => p_cost_segment26
	,p_cost_segment27                => p_cost_segment27
	,p_cost_segment28                => p_cost_segment28
	,p_cost_segment29                => p_cost_segment29
	,p_cost_segment30                => p_cost_segment30
	,p_cost_concat_segments_in	 => p_cost_concat_segments_in

        ,p_susp_segment1                 => p_susp_segment1
        ,p_susp_segment2                 => p_susp_segment2
	,p_susp_segment3                 => p_susp_segment3
	,p_susp_segment4                 => p_susp_segment4
	,p_susp_segment5                 => p_susp_segment5
	,p_susp_segment6                 => p_susp_segment6
	,p_susp_segment7                 => p_susp_segment7
	,p_susp_segment8                 => p_susp_segment8
	,p_susp_segment9                 => p_susp_segment9
	,p_susp_segment10                => p_susp_segment10
	,p_susp_segment11                => p_susp_segment11
	,p_susp_segment12                => p_susp_segment12
	,p_susp_segment13                => p_susp_segment13
	,p_susp_segment14                => p_susp_segment14
	,p_susp_segment15                => p_susp_segment15
	,p_susp_segment16                => p_susp_segment16
	,p_susp_segment17                => p_susp_segment17
	,p_susp_segment18                => p_susp_segment18
	,p_susp_segment19                => p_susp_segment19
	,p_susp_segment20                => p_susp_segment20
	,p_susp_segment21                => p_susp_segment21
	,p_susp_segment22                => p_susp_segment22
	,p_susp_segment23                => p_susp_segment23
	,p_susp_segment24                => p_susp_segment24
	,p_susp_segment25                => p_susp_segment25
	,p_susp_segment26                => p_susp_segment26
	,p_susp_segment27                => p_susp_segment27
	,p_susp_segment28                => p_susp_segment28
	,p_susp_segment29                => p_susp_segment29
	,p_susp_segment30                => p_susp_segment30
	,p_susp_concat_segments_in	 => p_susp_concat_segments_in

        ,p_scl_segment1                 => p_scl_segment1
        ,p_scl_segment2                 => p_scl_segment2
	,p_scl_segment3                 => p_scl_segment3
	,p_scl_segment4                 => p_scl_segment4
	,p_scl_segment5                 => p_scl_segment5
	,p_scl_segment6                 => p_scl_segment6
	,p_scl_segment7                 => p_scl_segment7
	,p_scl_segment8                 => p_scl_segment8
	,p_scl_segment9                 => p_scl_segment9
	,p_scl_segment10                => p_scl_segment10
	,p_scl_segment11                => p_scl_segment11
	,p_scl_segment12                => p_scl_segment12
	,p_scl_segment13                => p_scl_segment13
	,p_scl_segment14                => p_scl_segment14
	,p_scl_segment15                => p_scl_segment15
	,p_scl_segment16                => p_scl_segment16
	,p_scl_segment17                => p_scl_segment17
	,p_scl_segment18                => p_scl_segment18
	,p_scl_segment19                => p_scl_segment19
	,p_scl_segment20                => p_scl_segment20
	,p_scl_segment21                => p_scl_segment21
	,p_scl_segment22                => p_scl_segment22
	,p_scl_segment23                => p_scl_segment23
	,p_scl_segment24                => p_scl_segment24
	,p_scl_segment25                => p_scl_segment25
	,p_scl_segment26                => p_scl_segment26
	,p_scl_segment27                => p_scl_segment27
	,p_scl_segment28                => p_scl_segment28
	,p_scl_segment29                => p_scl_segment29
	,p_scl_segment30                => p_scl_segment30
	,p_scl_concat_segments_in	=> p_scl_concat_segments_in

	,p_workload_shifting_level      => p_workload_shifting_level
        ,p_payslip_view_date_offset     => p_payslip_view_date_offset

	,p_cost_concat_segments_out	 => p_cost_concat_segments_out
        ,p_susp_concat_segments_out      => p_susp_concat_segments_out
	,p_scl_concat_segments_out       => p_scl_concat_segments_out

	,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
	,p_comment_id                    => p_comment_id
	,p_cost_alloc_keyflex_id_out     => p_cost_alloc_keyflex_id_out
        ,p_susp_account_keyflex_id_out   => p_susp_account_keyflex_id_out
        ,p_soft_coding_keyflex_id_out    => p_soft_coding_keyflex_id_out
	,p_business_group_id             => l_business_group_id

	);

    exception
	    when hr_api.cannot_find_prog_unit then
	      hr_api.cannot_find_prog_unit_error
		(p_module_name => 'update_payroll'
		,p_hook_type   => 'AP'
		);
    --
    end;

    if(p_validate) then
    --
      raise hr_api.validate_enabled;
    --
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values
    --
    p_object_version_number     :=  l_object_version_number;
    p_effective_start_date      :=  l_effective_start_date;
    p_effective_end_date        :=  l_effective_end_date;
    p_comment_id                :=  p_comment_id;
    p_payroll_id                :=  l_payroll_id;

    --
    --If  the user doesn't specify any id then to return to the user
    --need to query from the table
    --
    if ((p_cost_alloc_keyflex_id_in = hr_api.g_number) and (l_cost_flag = false)) then
    --
	    open csr_get_costKFF;
	    fetch csr_get_costKFF into p_cost_alloc_keyflex_id_out;
	    close csr_get_costKFF;
    --
    end if;
    --
    if ((p_susp_account_keyflex_id_in = hr_api.g_number) and (l_susp_flag = false))then
    --
	    open csr_get_suspenseKFF;
	    fetch csr_get_suspenseKFF into p_susp_account_keyflex_id_out;
	    close csr_get_suspenseKFF;
    --
    end if;
    --
    if ((p_soft_coding_keyflex_id_in = hr_api.g_number) and (l_soft_flag = false))then
    --
	    open csr_get_softKFF;
	    fetch csr_get_softKFF into p_soft_coding_keyflex_id_out;
	    close csr_get_softKFF;
    --
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    exception
      when hr_api.validate_enabled then
      --
      -- Must remove all work done by this procedure.
      --
      rollback to update_payroll;

      p_object_version_number  :=  l_object_version_number;
      p_effective_start_date   :=  null;
      p_effective_end_date     :=  null;
      p_comment_id             :=  null;
      p_payroll_id             :=  l_payroll_id;

      p_cost_concat_segments_out   := null;
      p_susp_concat_segments_out   := null;
      p_scl_concat_segments_out    := null;
      p_cost_alloc_keyflex_id_out  := null;
      p_susp_account_keyflex_id_out:= null;
      p_soft_coding_keyflex_id_out := null;

      when others then
      --
      -- Must remove all work done by this procedure.
      --
      rollback to update_payroll;
      p_object_version_number      :=  l_object_version_number;
      p_effective_start_date       :=  null;
      p_effective_end_date         :=  null;
      p_comment_id                 :=  null;
      p_payroll_id                 :=  l_payroll_id;

      p_cost_concat_segments_out   := null;
      p_susp_concat_segments_out   := null;
      p_scl_concat_segments_out    := null;
      p_cost_alloc_keyflex_id_out  := null;
      p_susp_account_keyflex_id_out:= null;
      p_soft_coding_keyflex_id_out := null;

      raise;
--
end update_payroll;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_payroll >-----------------------------|
-- ----------------------------------------------------------------------------

 Procedure delete_payroll
  (p_validate                     in     boolean   default false,
   p_effective_date               in     date,
   p_datetrack_mode               in     varchar2,
   p_payroll_id                   in     number,
   p_object_version_number        in out nocopy number,
   p_effective_start_date            out nocopy date,
   p_effective_end_date              out nocopy date
  ) is

  l_effective_date date;
  l_object_version_number pay_all_payrolls_f.object_version_number%type;
  l_effective_start_date pay_all_payrolls_f.effective_start_date%TYPE;
  l_effective_end_date  pay_all_payrolls_f.effective_end_date%TYPE;
  l_proc                    varchar2(72)  :=  g_package||'delete_payroll';

  begin
  --

	hr_utility.set_location(' Entering:'||l_proc, 10);

	l_effective_date := trunc(p_effective_date);
	l_object_version_number := p_object_version_number;

	savepoint delete_payroll;
	begin
	--
		pay_payroll_bk3.delete_payroll_b
		(  p_effective_date           => l_effective_date
		  ,p_datetrack_mode           => p_datetrack_mode
		  ,p_payroll_id               => p_payroll_id
		  ,p_object_version_number    => l_object_version_number
		 );
        exception
	when hr_api.cannot_find_prog_unit then
		hr_api.cannot_find_prog_unit_error
		(p_module_name => 'delete_payroll'
		,p_hook_type   => 'BP'
		);
	--
	end;
	pay_pay_del.del(
	 p_effective_date                   => l_effective_date
	,p_datetrack_mode                   => p_datetrack_mode
	,p_payroll_id                       => p_payroll_id
	,p_object_version_number            => l_object_version_number
	,p_effective_start_date             => l_effective_start_date
	,p_effective_end_date               => l_effective_end_date
	);

	begin
	--
		pay_payroll_bk3.delete_payroll_a
		(p_effective_date               => l_effective_date
		 ,p_datetrack_mode               => p_datetrack_mode
		 ,p_payroll_id                   => p_payroll_id
		 ,p_object_version_number        => l_object_version_number
		 ,p_effective_start_date         => l_effective_start_date
		 ,p_effective_end_date           => l_effective_end_date
		);
	exception
	when hr_api.cannot_find_prog_unit then
		hr_api.cannot_find_prog_unit_error
		(p_module_name => 'delete_payroll'
		,p_hook_type   => 'AP'
		);
	--
	end;
	--
	  -- When in validation only mode raise the Validate_Enabled exception
	  --
	  if p_validate then
	    raise hr_api.validate_enabled;
	  end if;
	  --

	 --populate the out parameters.
	 p_object_version_number := l_object_version_number;
	 p_effective_start_date  := l_effective_start_date;
	 p_effective_end_date    := l_effective_end_date;

	 hr_utility.set_location(' Leaving:'||l_proc, 70);

	exception
	   when hr_api.validate_enabled then
	      --
	      -- Must remove all work done by this procedure.
              --
	      rollback to delete_payroll;
	      p_effective_start_date   :=  null;
	      p_effective_end_date     :=  null;

	   when others then
	      --
	      -- Must remove all work done by this procedure.
	      --
	      rollback to delete_payroll;
	      p_effective_start_date   :=  null;
	      p_effective_end_date     :=  null;
	      raise;

--
  end delete_payroll;
--

-------------------------------- create_payroll -------------------------------
/*
  NAME
    create_payroll
  DESCRIPTION
    Creates a Payroll and associated time periods.
  NOTES
    <none>
*/

procedure create_payroll
(
   p_validate                     in   boolean   default false,
   p_effective_date               in   date,
   p_payroll_name                 in   varchar2,
   p_payroll_type                 in   varchar2  default null,
   p_period_type                  in   varchar2,
   p_first_period_end_date        in   date,
   p_number_of_years              in   number,
   p_pay_date_offset              in   number    default 0,
   p_direct_deposit_date_offset   in   number    default 0,
   p_pay_advice_date_offset       in   number    default 0,
   p_cut_off_date_offset          in   number    default 0,
   p_midpoint_offset              in   number    default null,
   p_default_payment_method_id    in   number    default null,
   p_consolidation_set_id         in   number,
   p_cost_allocation_keyflex_id   in   number    default null,
   p_suspense_account_keyflex_id  in   number    default null,
   p_negative_pay_allowed_flag    in   varchar2  default 'N',
   p_gl_set_of_books_id           in   number    default null,
   p_soft_coding_keyflex_id       in   number    default null,
   p_comments                     in   varchar2  default null,
   p_attribute_category           in   varchar2  default null,
   p_attribute1                   in   varchar2  default null,
   p_attribute2                   in   varchar2  default null,
   p_attribute3                   in   varchar2  default null,
   p_attribute4                   in   varchar2  default null,
   p_attribute5                   in   varchar2  default null,
   p_attribute6                   in   varchar2  default null,
   p_attribute7                   in   varchar2  default null,
   p_attribute8                   in   varchar2  default null,
   p_attribute9                   in   varchar2  default null,
   p_attribute10                  in   varchar2  default null,
   p_attribute11                  in   varchar2  default null,
   p_attribute12                  in   varchar2  default null,
   p_attribute13                  in   varchar2  default null,
   p_attribute14                  in   varchar2  default null,
   p_attribute15                  in   varchar2  default null,
   p_attribute16                  in   varchar2  default null,
   p_attribute17                  in   varchar2  default null,
   p_attribute18                  in   varchar2  default null,
   p_attribute19                  in   varchar2  default null,
   p_attribute20                  in   varchar2  default null,
   p_arrears_flag                 in   varchar2  default 'N',
   p_period_reset_years           in   varchar2  default null,
   p_multi_assignments_flag       in   varchar2  default null,
   p_organization_id              in   number    default null,
   p_prl_information_category     in   varchar2  default null,
   p_prl_information1         	  in   varchar2  default null,
   p_prl_information2         	  in   varchar2  default null,
   p_prl_information3         	  in   varchar2  default null,
   p_prl_information4         	  in   varchar2  default null,
   p_prl_information5         	  in   varchar2  default null,
   p_prl_information6         	  in   varchar2  default null,
   p_prl_information7         	  in   varchar2  default null,
   p_prl_information8         	  in   varchar2  default null,
   p_prl_information9         	  in   varchar2  default null,
   p_prl_information10        	  in   varchar2  default null,
   p_prl_information11            in   varchar2  default null,
   p_prl_information12        	  in   varchar2  default null,
   p_prl_information13        	  in   varchar2  default null,
   p_prl_information14        	  in   varchar2  default null,
   p_prl_information15        	  in   varchar2  default null,
   p_prl_information16        	  in   varchar2  default null,
   p_prl_information17        	  in   varchar2  default null,
   p_prl_information18        	  in   varchar2  default null,
   p_prl_information19        	  in   varchar2  default null,
   p_prl_information20        	  in   varchar2  default null,
   p_prl_information21        	  in   varchar2  default null,
   p_prl_information22            in   varchar2  default null,
   p_prl_information23        	  in   varchar2  default null,
   p_prl_information24        	  in   varchar2  default null,
   p_prl_information25        	  in   varchar2  default null,
   p_prl_information26        	  in   varchar2  default null,
   p_prl_information27        	  in   varchar2  default null,
   p_prl_information28        	  in   varchar2  default null,
   p_prl_information29        	  in   varchar2  default null,
   p_prl_information30            in   varchar2  default null,

   p_payroll_id                   out  nocopy number,
   p_org_pay_method_usage_id      out  nocopy number,
   p_prl_object_version_number    out  nocopy number,
   p_opm_object_version_number    out  nocopy number,
   p_prl_effective_start_date     out  nocopy date,
   p_prl_effective_end_date       out  nocopy date,
   p_opm_effective_start_date     out  nocopy date,
   p_opm_effective_end_date       out  nocopy date,
   p_comment_id                   out  nocopy number
) is

   l_payroll_id                    number;
   l_org_pay_method_usage_id       number;
   l_prl_object_version_number     number;
   l_opm_object_version_number     number;
   l_prl_effective_start_date      date;
   l_prl_effective_end_date        date;
   l_opm_effective_start_date      date;
   l_opm_effective_end_date        date;
   l_comment_id                    number;

   l_business_group_id PAY_ALL_PAYROLLS_F.business_group_id%TYPE;
   l_legislation_code  varchar2(150);

   l_cost_allocation_keyflex_id   PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE ;
   l_suspense_account_keyflex_id  PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE ;
   l_soft_coding_keyflex_id       PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE ;

   l_cost_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_susp_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_scl_concat_segments  HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE;

begin

   --Get the business group id from the consolidation set id.
   pay_pay_bus.chk_consolidation_set_id(p_consolidation_set_id,l_business_group_id);

   --Get the Legislation code.
   l_legislation_code := hr_api.return_legislation_code(l_business_group_id);
   if(l_legislation_code <> p_prl_information_category) then
	fnd_message.set_name('PAY', 'PAY_33275_INFOCATEGORY_INVALID');
	fnd_message.raise_error;
   end if;

   pay_payroll_api.create_payroll(

    p_validate				=> p_validate
   ,p_effective_date			=> p_effective_date
   ,p_payroll_name			=> p_payroll_name
   ,p_consolidation_set_id		=> p_consolidation_set_id
   ,p_period_type			=> p_period_type
   ,p_first_period_end_date		=> p_first_period_end_date
   ,p_number_of_years			=> p_number_of_years
   ,p_payroll_type			=> p_payroll_type
   ,p_pay_date_offset			=> p_pay_date_offset
   ,p_direct_deposit_date_offset	=> p_direct_deposit_date_offset
   ,p_pay_advice_date_offset		=> p_pay_advice_date_offset
   ,p_cut_off_date_offset		=> p_cut_off_date_offset
   ,p_midpoint_offset			=> p_midpoint_offset
   ,p_default_payment_method_id		=> p_default_payment_method_id
   ,p_cost_alloc_keyflex_id_in   	=> p_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_in 	=> p_suspense_account_keyflex_id
   ,p_negative_pay_allowed_flag		=> p_negative_pay_allowed_flag
   ,p_gl_set_of_books_id                => p_gl_set_of_books_id
   ,p_soft_coding_keyflex_id_in		=> p_soft_coding_keyflex_id
   ,p_comments				=> p_comments
   ,p_attribute_category                => p_attribute_category
   ,p_attribute1			=> p_attribute1
   ,p_attribute2			=> p_attribute2
   ,p_attribute3			=> p_attribute3
   ,p_attribute4			=> p_attribute4
   ,p_attribute5			=> p_attribute5
   ,p_attribute6			=> p_attribute6
   ,p_attribute7			=> p_attribute7
   ,p_attribute8			=> p_attribute8
   ,p_attribute9			=> p_attribute9
   ,p_attribute10			=> p_attribute10
   ,p_attribute11			=> p_attribute11
   ,p_attribute12			=> p_attribute12
   ,p_attribute13			=> p_attribute13
   ,p_attribute14			=> p_attribute14
   ,p_attribute15			=> p_attribute15
   ,p_attribute16			=> p_attribute16
   ,p_attribute17			=> p_attribute17
   ,p_attribute18			=> p_attribute18
   ,p_attribute19			=> p_attribute19
   ,p_attribute20			=> p_attribute20
   ,p_arrears_flag			=> p_arrears_flag
   ,p_period_reset_years		=> p_period_reset_years
   ,p_multi_assignments_flag		=> p_multi_assignments_flag
   ,p_organization_id			=> p_organization_id
   ,p_prl_information1			=> p_prl_information1
   ,p_prl_information2			=> p_prl_information2
   ,p_prl_information3			=> p_prl_information3
   ,p_prl_information4			=> p_prl_information4
   ,p_prl_information5			=> p_prl_information5
   ,p_prl_information6			=> p_prl_information6
   ,p_prl_information7			=> p_prl_information7
   ,p_prl_information8			=> p_prl_information8
   ,p_prl_information9			=> p_prl_information9
   ,p_prl_information10			=> p_prl_information10
   ,p_prl_information11			=> p_prl_information11
   ,p_prl_information12			=> p_prl_information12
   ,p_prl_information13			=> p_prl_information13
   ,p_prl_information14			=> p_prl_information14
   ,p_prl_information15			=> p_prl_information15
   ,p_prl_information16			=> p_prl_information16
   ,p_prl_information17			=> p_prl_information17
   ,p_prl_information18			=> p_prl_information18
   ,p_prl_information19			=> p_prl_information19
   ,p_prl_information20			=> p_prl_information20
   ,p_prl_information21			=> p_prl_information21
   ,p_prl_information22			=> p_prl_information22
   ,p_prl_information23			=> p_prl_information23
   ,p_prl_information24			=> p_prl_information24
   ,p_prl_information25			=> p_prl_information25
   ,p_prl_information26			=> p_prl_information26
   ,p_prl_information27			=> p_prl_information27
   ,p_prl_information28			=> p_prl_information28
   ,p_prl_information29			=> p_prl_information29
   ,p_prl_information30			=> p_prl_information30

   ,p_payroll_id			=> l_payroll_id
   ,p_org_pay_method_usage_id		=> l_org_pay_method_usage_id
   ,p_prl_object_version_number		=> l_prl_object_version_number
   ,p_opm_object_version_number		=> l_opm_object_version_number
   ,p_prl_effective_start_date		=> l_prl_effective_start_date
   ,p_prl_effective_end_date		=> l_prl_effective_end_date
   ,p_opm_effective_start_date		=> l_opm_effective_start_date
   ,p_opm_effective_end_date		=> l_opm_effective_end_date
   ,p_comment_id			=> l_comment_id

   ,p_cost_alloc_keyflex_id_out         => l_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_out	=> l_suspense_account_keyflex_id
   ,p_soft_coding_keyflex_id_out	=> l_soft_coding_keyflex_id

   ,p_cost_concat_segments_out		=> l_cost_concat_segments
   ,p_susp_concat_segments_out		=> l_susp_concat_segments
   ,p_scl_concat_segments_out		=> l_scl_concat_segments

   );
   p_payroll_id := l_payroll_id;
   p_org_pay_method_usage_id   := l_org_pay_method_usage_id;
   p_prl_object_version_number := l_prl_object_version_number;
   p_opm_object_version_number := l_opm_object_version_number;
   p_prl_effective_start_date  := l_prl_effective_start_date;
   p_prl_effective_end_date    := l_prl_effective_end_date;
   p_opm_effective_start_date  := l_opm_effective_start_date;
   p_opm_effective_end_date    := p_opm_effective_end_date;
   p_comment_id                := p_comment_id;

end create_payroll;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_payroll >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure updates a payroll and the associated tables.
-------------------------------------------------------------------------------
procedure update_payroll
(
   p_validate                     in     boolean   default false,
   p_effective_date               in     date,
   p_datetrack_mode               in     varchar2,
   p_payroll_id                   in out nocopy number,
   p_object_version_number        in out nocopy number,
   p_payroll_name                 in     varchar2  default hr_api.g_varchar2,
   p_number_of_years              in     number    default hr_api.g_number,
   p_default_payment_method_id    in     number    default hr_api.g_number,
   p_consolidation_set_id         in     number    default hr_api.g_number,
   p_cost_allocation_keyflex_id   in     number    default hr_api.g_number,
   p_suspense_account_keyflex_id  in     number    default hr_api.g_number,
   p_negative_pay_allowed_flag    in     varchar2  default hr_api.g_varchar2,
   p_soft_coding_keyflex_id       in     number    default hr_api.g_number,
   p_comments                     in     varchar2  default hr_api.g_varchar2,
   p_attribute_category           in     varchar2  default hr_api.g_varchar2,
   p_attribute1                   in     varchar2  default hr_api.g_varchar2,
   p_attribute2                   in     varchar2  default hr_api.g_varchar2,
   p_attribute3                   in     varchar2  default hr_api.g_varchar2,
   p_attribute4                   in     varchar2  default hr_api.g_varchar2,
   p_attribute5                   in     varchar2  default hr_api.g_varchar2,
   p_attribute6                   in     varchar2  default hr_api.g_varchar2,
   p_attribute7                   in     varchar2  default hr_api.g_varchar2,
   p_attribute8                   in     varchar2  default hr_api.g_varchar2,
   p_attribute9                   in     varchar2  default hr_api.g_varchar2,
   p_attribute10                  in     varchar2  default hr_api.g_varchar2,
   p_attribute11                  in     varchar2  default hr_api.g_varchar2,
   p_attribute12                  in     varchar2  default hr_api.g_varchar2,
   p_attribute13                  in     varchar2  default hr_api.g_varchar2,
   p_attribute14                  in     varchar2  default hr_api.g_varchar2,
   p_attribute15                  in     varchar2  default hr_api.g_varchar2,
   p_attribute16                  in     varchar2  default hr_api.g_varchar2,
   p_attribute17                  in     varchar2  default hr_api.g_varchar2,
   p_attribute18                  in     varchar2  default hr_api.g_varchar2,
   p_attribute19                  in     varchar2  default hr_api.g_varchar2,
   p_attribute20                  in     varchar2  default hr_api.g_varchar2,
   p_arrears_flag                 in     varchar2  default hr_api.g_varchar2,
   p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2,
   p_prl_information_category     in     varchar2  default hr_api.g_varchar2,
   p_prl_information1         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information2         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information3         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information4         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information5         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information6         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information7         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information8         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information9         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information10        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information11            in     varchar2  default hr_api.g_varchar2,
   p_prl_information12        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information13        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information14        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information15        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information16        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information17        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information18        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information19        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information20        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information21        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information22            in     varchar2  default hr_api.g_varchar2,
   p_prl_information23        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information24        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information25        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information26        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information27        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information28        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information29        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information30            in     varchar2  default hr_api.g_varchar2,
   p_prl_effective_start_date        out nocopy date,
   p_prl_effective_end_date          out nocopy date,
   p_comment_id                      out nocopy number
) is
  --
   l_proc                    varchar2(72)  :=  g_package||'update_payroll';

   l_payroll_id               PAY_ALL_PAYROLLS_F.payroll_id%TYPE := p_payroll_id;
   l_object_version_number    PAY_ALL_PAYROLLS_F.object_version_number%TYPE := p_object_version_number;
   l_prl_effective_start_date date;
   l_prl_effective_end_date   date;
   l_comment_id               number;

   l_business_group_id PAY_ALL_PAYROLLS_F.business_group_id%TYPE;
   l_legislation_code  varchar2(150);

   l_cost_allocation_keyflex_id   PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE ;
   l_suspense_account_keyflex_id  PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE ;
   l_soft_coding_keyflex_id       PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE ;

   l_cost_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_susp_concat_segments PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_scl_concat_segments  HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE;

   cursor csr_get_BG is
   select business_group_id
	from PAY_ALL_PAYROLLS_F
	where payroll_id = p_payroll_id;
begin
--
   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.trace('p_effective_date : '||to_char(p_effective_date));
   --Get the business group id from the payroll id.
   if (p_consolidation_set_id = hr_api.g_number) then
       	    open csr_get_BG;
	    fetch csr_get_BG into l_business_group_id;
	    if (csr_get_BG % NOTFOUND) then
	        close csr_get_BG;
		fnd_message.set_name('PAY', 'PAY_KR_INV_CS_BG');
		fnd_message.raise_error;
	    end if;
	    close csr_get_BG;
    else
       pay_pay_bus.chk_consolidation_set_id(p_consolidation_set_id, l_business_group_id);
    end if;

   --Get the Legislation code.
   l_legislation_code := hr_api.return_legislation_code(l_business_group_id);

   if(l_legislation_code         <> p_prl_information_category and
      p_prl_information_category <> hr_api.g_varchar2) then
	fnd_message.set_name('PAY', 'PAY_33275_INFOCATEGORY_INVALID');
	fnd_message.raise_error;
   end if;

   pay_payroll_api.update_payroll(
    p_validate				=> p_validate
   ,p_effective_date			=> p_effective_date
   ,p_datetrack_mode                    => p_datetrack_mode
   ,p_payroll_name			=> p_payroll_name
   ,p_consolidation_set_id		=> p_consolidation_set_id
   ,p_number_of_years			=> p_number_of_years
   ,p_default_payment_method_id		=> p_default_payment_method_id
   ,p_cost_alloc_keyflex_id_in   	=> p_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_in 	=> p_suspense_account_keyflex_id
   ,p_negative_pay_allowed_flag		=> p_negative_pay_allowed_flag
   ,p_soft_coding_keyflex_id_in		=> p_soft_coding_keyflex_id
   ,p_comments				=> p_comments
   ,p_attribute_category                => p_attribute_category
   ,p_attribute1			=> p_attribute1
   ,p_attribute2			=> p_attribute2
   ,p_attribute3			=> p_attribute3
   ,p_attribute4			=> p_attribute4
   ,p_attribute5			=> p_attribute5
   ,p_attribute6			=> p_attribute6
   ,p_attribute7			=> p_attribute7
   ,p_attribute8			=> p_attribute8
   ,p_attribute9			=> p_attribute9
   ,p_attribute10			=> p_attribute10
   ,p_attribute11			=> p_attribute11
   ,p_attribute12			=> p_attribute12
   ,p_attribute13			=> p_attribute13
   ,p_attribute14			=> p_attribute14
   ,p_attribute15			=> p_attribute15
   ,p_attribute16			=> p_attribute16
   ,p_attribute17			=> p_attribute17
   ,p_attribute18			=> p_attribute18
   ,p_attribute19			=> p_attribute19
   ,p_attribute20			=> p_attribute20
   ,p_arrears_flag			=> p_arrears_flag
   ,p_multi_assignments_flag		=> p_multi_assignments_flag
   ,p_prl_information1			=> p_prl_information1
   ,p_prl_information2			=> p_prl_information2
   ,p_prl_information3			=> p_prl_information3
   ,p_prl_information4			=> p_prl_information4
   ,p_prl_information5			=> p_prl_information5
   ,p_prl_information6			=> p_prl_information6
   ,p_prl_information7			=> p_prl_information7
   ,p_prl_information8			=> p_prl_information8
   ,p_prl_information9			=> p_prl_information9
   ,p_prl_information10			=> p_prl_information10
   ,p_prl_information11			=> p_prl_information11
   ,p_prl_information12			=> p_prl_information12
   ,p_prl_information13			=> p_prl_information13
   ,p_prl_information14			=> p_prl_information14
   ,p_prl_information15			=> p_prl_information15
   ,p_prl_information16			=> p_prl_information16
   ,p_prl_information17			=> p_prl_information17
   ,p_prl_information18			=> p_prl_information18
   ,p_prl_information19			=> p_prl_information19
   ,p_prl_information20			=> p_prl_information20
   ,p_prl_information21			=> p_prl_information21
   ,p_prl_information22			=> p_prl_information22
   ,p_prl_information23			=> p_prl_information23
   ,p_prl_information24			=> p_prl_information24
   ,p_prl_information25			=> p_prl_information25
   ,p_prl_information26			=> p_prl_information26
   ,p_prl_information27			=> p_prl_information27
   ,p_prl_information28			=> p_prl_information28
   ,p_prl_information29			=> p_prl_information29
   ,p_prl_information30			=> p_prl_information30

   ,p_payroll_id			=> l_payroll_id
   ,p_object_version_number		=> l_object_version_number
   ,p_effective_start_date		=> l_prl_effective_start_date
   ,p_effective_end_date		=> l_prl_effective_end_date
   ,p_comment_id			=> l_comment_id

   ,p_cost_alloc_keyflex_id_out         => l_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_out	=> l_suspense_account_keyflex_id
   ,p_soft_coding_keyflex_id_out	=> l_soft_coding_keyflex_id

   ,p_cost_concat_segments_out		=> l_cost_concat_segments
   ,p_susp_concat_segments_out		=> l_susp_concat_segments
   ,p_scl_concat_segments_out		=> l_scl_concat_segments

   );
   p_payroll_id := l_payroll_id;
   p_object_version_number := l_object_version_number;
   p_prl_effective_start_date := l_prl_effective_start_date;
   p_prl_effective_end_date := l_prl_effective_end_date;
   p_comment_id := l_comment_id;

   hr_utility.set_location('Leaving:'||l_proc, 5);
--
end update_payroll;
-- ----------------------------------------------------------------------------
-- |---------------------------< lock_payroll >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure locks a payroll while update and delete.
-------------------------------------------------------------------------------
Procedure lock_payroll
(
  p_effective_date                   in date
 ,p_datetrack_mode                   in varchar2
 ,p_payroll_id                       in number
 ,p_object_version_number            in number
 ,p_validation_start_date            out nocopy date
 ,p_validation_end_date              out nocopy date
) is
--

  l_proc                  varchar2(72) := g_package||'lock_payroll';
  l_validation_start_date date;
  l_validation_end_date   date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  pay_pay_shd.lck(
  p_effective_date
 ,p_datetrack_mode
 ,p_payroll_id
 ,p_object_version_number
 ,l_validation_start_date
 ,l_validation_end_date
 );
 p_validation_start_date := l_validation_start_date;
 p_validation_end_date := l_validation_end_date;

End lock_payroll;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_payroll_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --g_payroll_id_i := p_payroll_id;
  pay_pay_ins.set_base_key_value(p_payroll_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
-------------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  hr_utility.trace('entered return_api_dml_status');
  return pay_pay_shd.return_api_dml_status;
  --
End return_api_dml_status;
--
--
end pay_payroll_api;


/
