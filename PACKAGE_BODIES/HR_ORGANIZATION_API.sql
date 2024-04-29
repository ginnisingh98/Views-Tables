--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_API" AS
/* $Header: hrorgapi.pkb 120.10.12010000.8 2009/04/14 09:44:53 sathkris ship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := '  hr_organization_api.';
--
--------------------------------------------------------------------------------
g_dummy  number(1);  -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cost_concat_segs >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure updates the pay_cost_allocation_keyflex table after the
--   flexfield segments have been inserted to keep the concatenated segment
--   field up to date.
--
-- Prerequisites:
--   A row must exist in the pay_cost_allocation_keyflex table for
--   p_cost_allocation_keyflex_id
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cost_allocation_keyflex_id   Yes  number   The primary key
--   p_cost_name                    Yes  varchar2 The concatenated segments
--
-- Post Success:
--   The row is updated
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
--
-- Start of fix 3309164
procedure update_cost_concat_segs
  (p_cost_allocation_keyflex_id   in     number
  ,p_cost_name                    in     varchar2
  ) is
  --
  CURSOR csr_chk_cost is
    SELECT null
      FROM pay_cost_allocation_keyflex
     where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
       and (concatenated_segments <> p_cost_name
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc    varchar2(72) := g_package||'update_cost_concat_segs';
  --
  procedure update_cost_concat_segs_auto
    (p_cost_allocation_keyflex_id   in     number
    ,p_cost_name                    in     varchar2
    ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_cost_lock is
      SELECT null
        FROM pay_cost_allocation_keyflex
       where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
         for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_cost_concat_segs_auto';
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
      update pay_cost_allocation_keyflex
         set concatenated_segments = p_cost_name
       where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
         and (concatenated_segments <> p_cost_name
          or concatenated_segments is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed inside
      -- an autonomous transaction and AOL code has previously
      -- inserted the Key Flexfield combination row in another
      -- autonomous transaction.
      commit;
    else
      close csr_cost_lock;
      rollback; -- Added for bug 3578845.
    end if;
    --
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    --
  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      rollback; -- Added for bug 3578845.
      hr_utility.set_location('Leaving:'|| l_proc, 40);
      --
  end update_cost_concat_segs_auto;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first inserted.
  --
  open csr_chk_cost;
  fetch csr_chk_cost into l_exists;
  if csr_chk_cost%found then
    close csr_chk_cost;
    update_cost_concat_segs_auto
      (p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id
      ,p_cost_name                  => p_cost_name
      );
  else
    close csr_chk_cost;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 40);
  --
end update_cost_concat_segs;
-- End of fix 3309164
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_organization_internal >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is a Business Support Process, and this will be called
--   internally by the published API (create_organization and
--   create_hr_organization)
--
--   This procedure creates a new organization within a scope of existing
--   business group.
--
--   Organizations are stored on the HR_ALL_ORGANIZATION_UNITS table.
--   The translated columns are stored on the
--   HR_ALL_ORGANIZATION_UNITS_TL table.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation and in hr_lookups.
--   p_language_code                No   Varchar2 The language used for the
--                                                initial translation values
--   p_business_group_id            Yes  Number   Business group ID.
--
--   p_date_from                    Yes  Date     The date the organization is
--                                                in effect.
--   p_name                         Yes  Varchar2 Organization name (Translated)
--   p_cost_allocation_keyflex_id   No   Number   Cost Allocation Keyflex id
--   p_location_id                  No   Number   Organization's Location id.
--   p_date_to                      No   Date     The date on which the effect of
--                                                the organization ends.
--   p_internal_external_flag       No   Varchar2 Internal or External Organization Flag.
--   p_internal_address_line        No   Varchar2 Internal Address Line.
--   p_type                         No   Varcahr2 Organization Type.

--   p_attribute_category           No   Varchar2 Flexfield Category
--   p_attribute1                   No   Varchar2 Flexfield
--   ..
--   p_attribute30                  No   Varchar2 Flexfield
--
-- Post Success:
--   When the Organization has been successfully inserted, the following OUT
--   parameters are set:
--
--   Name                                Type     Description
--
--   p_organization_id                   Number   This contains the ID assigned to
--                                                the organization.
--   p_object_version_number             Number   This contains the Object Version
--                                                Number of the newly created row.
--   p_duplicate_org_warning             Boolean  If an organization already
--                                                exists with the same name
--                                                in a different business
--                                                group this will be true
--                                                (if the duplicate is in the
--                                                 same business group, an error
--                                                 will be raised)
-- Post Failure:
--   The procedure does not create the organization, and raises an error
--   through the main API
--
-- Access Status:
--   Internal Developement Use Only.
--
-- {End Of Comments}
--
--
PROCEDURE create_organization_internal
  (   p_effective_date                 in  date
     ,p_language_code                  in  varchar2 default hr_api.userenv_lang
     ,p_business_group_id              in  number
     ,p_date_from                      in  date
     ,p_name                           in  varchar2
     ,p_cost_allocation_keyflex_id     in  number   default null
     ,p_location_id                    in  number   default null
     ,p_date_to                        in  date     default null
     ,p_internal_external_flag         in  varchar2 default null
     ,p_internal_address_line          in  varchar2 default null
     ,p_type                           in  varchar2 default null
     ,p_comments                       in  varchar2 default null
     ,p_attribute_category             in  varchar2 default null
     ,p_attribute1                     in  varchar2 default null
     ,p_attribute2                     in  varchar2 default null
     ,p_attribute3                     in  varchar2 default null
     ,p_attribute4                     in  varchar2 default null
     ,p_attribute5                     in  varchar2 default null
     ,p_attribute6                     in  varchar2 default null
     ,p_attribute7                     in  varchar2 default null
     ,p_attribute8                     in  varchar2 default null
     ,p_attribute9                     in  varchar2 default null
     ,p_attribute10                    in  varchar2 default null
     ,p_attribute11                    in  varchar2 default null
     ,p_attribute12                    in  varchar2 default null
     ,p_attribute13                    in  varchar2 default null
     ,p_attribute14                    in  varchar2 default null
     ,p_attribute15                    in  varchar2 default null
     ,p_attribute16                    in  varchar2 default null
     ,p_attribute17                    in  varchar2 default null
     ,p_attribute18                    in  varchar2 default null
     ,p_attribute19                    in  varchar2 default null
     ,p_attribute20                    in  varchar2 default null
     --Enhancement 4040086
     --Begin of Add 10 additional segments
     ,p_attribute21                    in  varchar2 default null
     ,p_attribute22                    in  varchar2 default null
     ,p_attribute23                    in  varchar2 default null
     ,p_attribute24                    in  varchar2 default null
     ,p_attribute25                    in  varchar2 default null
     ,p_attribute26                    in  varchar2 default null
     ,p_attribute27                    in  varchar2 default null
     ,p_attribute28                    in  varchar2 default null
     ,p_attribute29                    in  varchar2 default null
     ,p_attribute30                    in  varchar2 default null
     --End of Add 10 additional segments
     ,p_organization_id                out nocopy number
     ,p_object_version_number          out nocopy number
     ,p_duplicate_org_warning          out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  -- Added cursor csr_sec_profile
  cursor csr_sec_profile(p_security_profile_id in number) is
         select view_all_organizations_flag
         from   per_security_profiles
         where  security_profile_id = p_security_profile_id;
  --
  l_proc                  varchar2(72) := g_package||'create_organization_internal';
  l_organization_id       hr_all_organization_units.organization_id%type;
  l_object_version_number hr_all_organization_units.object_version_number%type;
  l_language_code         hr_all_organization_units_tl.language%type;
  l_security_profile_id   per_security_profiles.security_profile_id%type;
  l_view_all_orgs         per_security_profiles.view_all_organizations_flag%type;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate the language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Insert non-translatable rows into HR_ALL_ORGANIZATION_UNITS first
  hr_oru_ins.ins
  (   p_effective_date                => p_effective_date
     ,p_business_group_id             => p_business_group_id
     ,p_date_from                     => p_date_from
     ,p_name                          => p_name
     ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
     ,p_location_id                   => p_location_id
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     -- Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     -- End Enhancement 4040086
     ,p_organization_id               => l_organization_id
     ,p_object_version_number         => l_object_version_number
     ,p_duplicate_org_warning         => p_duplicate_org_warning);
  --
  --  Now insert translatable rows in HR_ALL_ORGANIZATION_UNITS_TL table
  --
  hr_ort_ins.ins_tl
    ( p_language_code              => l_language_code,
      p_organization_id            => l_organization_id,
      p_name                       => p_name
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  l_security_profile_id := fnd_profile.value('PER_SECURITY_PROFILE_ID');
-- Bug fix 4329807
/*  open csr_sec_profile( l_security_profile_id );
  fetch csr_sec_profile into l_view_all_orgs;
  close csr_sec_profile;
  if l_view_all_orgs <> 'N' then
     per_org_structure_elements_pkg.maintain_org_lists(
        p_Business_Group_Id
       ,l_security_profile_id
       ,l_organization_id
      );
  end if;
*/
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Set all output arguments
  --
  p_organization_id := l_organization_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
END create_organization_internal;
--
-- --------------------------------------------------------------------------
-- |-----------------------<<create_hr_organization>>-----------------------|
-- --------------------------------------------------------------------------
--
procedure create_hr_organization
    (p_validate                    in  boolean default false
    ,p_effective_date              in  date
    ,p_business_group_id           in  number
    ,p_name                        in  varchar2
    ,p_date_from                   in  date
    ,p_language_code               in  varchar2 default hr_api.userenv_Lang
    ,p_location_id                 in  number   default null
    ,p_date_to                     in  date     default null
    ,p_internal_external_flag      in  varchar2 default null
    ,p_internal_address_line       in  varchar2 default null
    ,p_type                        in  varchar2 default null
    ,p_enabled_flag                in  varchar2 default 'N'
    ,p_segment1                    in  varchar2 default null
    ,p_segment2                    in  varchar2 default null
    ,p_segment3                    in  varchar2 default null
    ,p_segment4                    in  varchar2 default null
    ,p_segment5                    in  varchar2 default null
    ,p_segment6                    in  varchar2 default null
    ,p_segment7                    in  varchar2 default null
    ,p_segment8                    in  varchar2 default null
    ,p_segment9                    in  varchar2 default null
    ,p_segment10                   in  varchar2 default null
    ,p_segment11                   in  varchar2 default null
    ,p_segment12                   in  varchar2 default null
    ,p_segment13                   in  varchar2 default null
    ,p_segment14                   in  varchar2 default null
    ,p_segment15                   in  varchar2 default null
    ,p_segment16                   in  varchar2 default null
    ,p_segment17                   in  varchar2 default null
    ,p_segment18                   in  varchar2 default null
    ,p_segment19                   in  varchar2 default null
    ,p_segment20                   in  varchar2 default null
    ,p_segment21                   in  varchar2 default null
    ,p_segment22                   in  varchar2 default null
    ,p_segment23                   in  varchar2 default null
    ,p_segment24                   in  varchar2 default null
    ,p_segment25                   in  varchar2 default null
    ,p_segment26                   in  varchar2 default null
    ,p_segment27                   in  varchar2 default null
    ,p_segment28                   in  varchar2 default null
    ,p_segment29                   in  varchar2 default null
    ,p_segment30                   in  varchar2 default null
    ,p_concat_segments             in  varchar2 default null
    ,p_object_version_number_inf   out nocopy number
    ,p_object_version_number_org   out nocopy number
    ,p_organization_id             out nocopy number
    ,p_org_information_id          out nocopy number
    ,p_duplicate_org_warning       out nocopy boolean
    ) is
  --
  -- Declare local variables
  --
  l_flex_num                       fnd_id_flex_segments.id_flex_num%Type;
  l_cost_name                      pay_cost_allocation_keyflex.concatenated_segments%Type;
  l_cost_alloc_key_id              hr_all_organization_units.cost_allocation_keyflex_id%Type;
  l_date_from                      date;
  l_effective_date                 date;
  --
  l_proc                           varchar2(72) := g_package||'CREATE_HR_ORGANIZATION';
  --
  -- Declare cursors
  --
  -- Cursor to retrive the Cost Allocation structure id
  -- for the current business group
  --
  cursor csr_cost_idsel is
         select bus.cost_allocation_structure
         from   per_business_groups_perf bus
         where  bus.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_hr_organization;
  --
  --  All date input parameters must be truncated to remove time elements
  --  before passing into user hooks
  --
  l_date_from := trunc (p_date_from);
  l_effective_date := trunc (p_effective_date);
  --
  begin
  hr_organization_bk9.create_hr_organization_b
       (p_effective_date            => l_effective_date
       ,p_business_group_id         => p_business_group_id
       ,p_name                      => p_name
       ,p_date_from                 => l_date_from
       ,p_language_code             => p_language_code
       ,p_location_id               => p_location_id
       ,p_date_to                   => p_date_to
       ,p_internal_external_flag    => p_internal_external_flag
       ,p_internal_address_line     => p_internal_address_line
       ,p_type                      => p_type
       ,p_enabled_flag              => p_enabled_flag
       ,p_segment1                  => p_segment1
       ,p_segment2                  => p_segment2
       ,p_segment3                  => p_segment3
       ,p_segment4                  => p_segment4
       ,p_segment5                  => p_segment5
       ,p_segment6                  => p_segment6
       ,p_segment7                  => p_segment7
       ,p_segment8                  => p_segment8
       ,p_segment9                  => p_segment9
       ,p_segment10                 => p_segment10
       ,p_segment11                 => p_segment11
       ,p_segment12                 => p_segment12
       ,p_segment13                 => p_segment13
       ,p_segment14                 => p_segment14
       ,p_segment15                 => p_segment15
       ,p_segment16                 => p_segment16
       ,p_segment17                 => p_segment17
       ,p_segment18                 => p_segment18
       ,p_segment19                 => p_segment19
       ,p_segment20                 => p_segment20
       ,p_segment21                 => p_segment21
       ,p_segment22                 => p_segment22
       ,p_segment23                 => p_segment23
       ,p_segment24                 => p_segment24
       ,p_segment25                 => p_segment25
       ,p_segment26                 => p_segment26
       ,p_segment27                 => p_segment27
       ,p_segment28                 => p_segment28
       ,p_segment29                 => p_segment29
       ,p_segment30                 => p_segment30
       ,p_concat_segments           => p_concat_segments
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_hr_organization'
          ,p_hook_type   => 'BP'
          );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Getting the structure number for Cost Allocation Flexfield
  --
  open csr_cost_idsel;
  fetch csr_cost_idsel into l_flex_num;
  --
  if csr_cost_idsel%notfound then
     --
     close csr_cost_idsel;
     --
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', l_proc);
     hr_utility.set_message_token('STEP','5');
     hr_utility.raise_error;
     --
  end if;
  --
  close csr_cost_idsel;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Dterminine the Cost Allocation definition by calling ins_or_sel
  --
  hr_kflex_utility.ins_or_sel_keyflex_comb
           (p_appl_short_name       => 'PAY'
           ,p_flex_code             => 'COST'
           ,p_flex_num              => l_flex_num
           ,p_segment1              => p_segment1
           ,p_segment2              => p_segment2
           ,p_segment3              => p_segment3
           ,p_segment4              => p_segment4
           ,p_segment5              => p_segment5
           ,p_segment6              => p_segment6
           ,p_segment7              => p_segment7
           ,p_segment8              => p_segment8
           ,p_segment9              => p_segment9
           ,p_segment10             => p_segment10
           ,p_segment11             => p_segment11
           ,p_segment12             => p_segment12
           ,p_segment13             => p_segment13
           ,p_segment14             => p_segment14
           ,p_segment15             => p_segment15
           ,p_segment16             => p_segment16
           ,p_segment17             => p_segment17
           ,p_segment18             => p_segment18
           ,p_segment19             => p_segment19
           ,p_segment20             => p_segment20
           ,p_segment21             => p_segment21
           ,p_segment22             => p_segment22
           ,p_segment23             => p_segment23
           ,p_segment24             => p_segment24
           ,p_segment25             => p_segment25
           ,p_segment26             => p_segment26
           ,p_segment27             => p_segment27
           ,p_segment28             => p_segment28
           ,p_segment29             => p_segment29
           ,p_segment30             => p_segment30
           ,p_concat_segments_in    => p_concat_segments
           ,p_ccid                  => l_cost_alloc_key_id
           ,p_concat_segments_out   => l_cost_name);
  --
  hr_utility.set_location(l_proc, 40);
  hr_utility.set_location(l_proc ||'l_cost_alloc_key_id '||l_cost_alloc_key_id, 61);
  hr_utility.set_location(l_proc ||'l_cost_name '||l_cost_name, 62);
  --
  update_cost_concat_segs (p_cost_allocation_keyflex_id  => l_cost_alloc_key_id
                          ,p_cost_name                   => l_cost_name);
  --
  hr_utility.set_location(l_proc, 50);
  --
  create_organization_internal
     (p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_business_group_id             => p_business_group_id
     ,p_date_from                     => p_date_from
     ,p_name                          => p_name
     ,p_cost_allocation_keyflex_id    => l_cost_alloc_key_id
     ,p_location_id                   => p_location_id
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
     ,p_attribute_category            => null
     ,p_attribute1                    => null
     ,p_attribute2                    => null
     ,p_attribute3                    => null
     ,p_attribute4                    => null
     ,p_attribute5                    => null
     ,p_attribute6                    => null
     ,p_attribute7                    => null
     ,p_attribute8                    => null
     ,p_attribute9                    => null
     ,p_attribute10                   => null
     ,p_attribute11                   => null
     ,p_attribute12                   => null
     ,p_attribute13                   => null
     ,p_attribute14                   => null
     ,p_attribute15                   => null
     ,p_attribute16                   => null
     ,p_attribute17                   => null
     ,p_attribute18                   => null
     ,p_attribute19                   => null
     ,p_attribute20                   => null
     --Enhancement 4040086
     ,p_attribute21                   => null
     ,p_attribute22                   => null
     ,p_attribute23                   => null
     ,p_attribute24                   => null
     ,p_attribute25                   => null
     ,p_attribute26                   => null
     ,p_attribute27                   => null
     ,p_attribute28                   => null
     ,p_attribute29                   => null
     ,p_attribute30                   => null
     --End Enhancement 4040086
     ,p_organization_id               => p_organization_id
     ,p_object_version_number         => p_object_version_number_org
     ,p_duplicate_org_warning         => p_duplicate_org_warning);
  --
  hr_utility.set_location(l_proc, 60);
  --
  hr_organization_api.create_org_information
   ( p_effective_date              => p_effective_date
    ,p_organization_id             => p_organization_id
    ,p_org_info_type_code          => 'CLASS'
    ,p_org_information1            => 'HR_ORG'
    ,p_org_information2            => p_enabled_flag
    ,p_org_information3            =>  null
    ,p_org_information4            =>  null
    ,p_org_information5            =>  null
    ,p_org_information6            =>  null
    ,p_org_information7            =>  null
    ,p_org_information8            =>  null
    ,p_org_information9            =>  null
    ,p_org_information10           =>  null
    ,p_org_information11           =>  null
    ,p_org_information12           =>  null
    ,p_org_information13           =>  null
    ,p_org_information14           =>  null
    ,p_org_information15           =>  null
    ,p_org_information16           =>  null
    ,p_org_information17           =>  null
    ,p_org_information18           =>  null
    ,p_org_information19           =>  null
    ,p_org_information20           =>  null
    ,p_attribute_category          =>  null
    ,p_attribute1                  =>  null
    ,p_attribute2                  =>  null
    ,p_attribute3                  =>  null
    ,p_attribute4                  =>  null
    ,p_attribute5                  =>  null
    ,p_attribute6                  =>  null
    ,p_attribute7                  =>  null
    ,p_attribute8                  =>  null
    ,p_attribute9                  =>  null
    ,p_attribute10                 =>  null
    ,p_attribute11                 =>  null
    ,p_attribute12                 =>  null
    ,p_attribute13                 =>  null
    ,p_attribute14                 =>  null
    ,p_attribute15                 =>  null
    ,p_attribute16                 =>  null
    ,p_attribute17                 =>  null
    ,p_attribute18                 =>  null
    ,p_attribute19                 =>  null
    ,p_attribute20                 =>  null
    ,p_org_information_id          => p_org_information_id
    ,p_object_version_number       => p_object_version_number_inf
    );
  --
  hr_utility.set_location(l_proc, 70);
  --
  begin
  hr_organization_bk9.create_hr_organization_a
       (p_effective_date            => l_effective_date
       ,p_business_group_id         => p_business_group_id
       ,p_name                      => p_name
       ,p_date_from                 => l_date_from
       ,p_language_code             => p_language_code
       ,p_location_id               => p_location_id
       ,p_date_to                   => p_date_to
       ,p_internal_external_flag    => p_internal_external_flag
       ,p_internal_address_line     => p_internal_address_line
       ,p_type                      => p_type
       ,p_enabled_flag              => p_enabled_flag
       ,p_segment1                  => p_segment1
       ,p_segment2                  => p_segment2
       ,p_segment3                  => p_segment3
       ,p_segment4                  => p_segment4
       ,p_segment5                  => p_segment5
       ,p_segment6                  => p_segment6
       ,p_segment7                  => p_segment7
       ,p_segment8                  => p_segment8
       ,p_segment9                  => p_segment9
       ,p_segment10                 => p_segment10
       ,p_segment11                 => p_segment11
       ,p_segment12                 => p_segment12
       ,p_segment13                 => p_segment13
       ,p_segment14                 => p_segment14
       ,p_segment15                 => p_segment15
       ,p_segment16                 => p_segment16
       ,p_segment17                 => p_segment17
       ,p_segment18                 => p_segment18
       ,p_segment19                 => p_segment19
       ,p_segment20                 => p_segment20
       ,p_segment21                 => p_segment21
       ,p_segment22                 => p_segment22
       ,p_segment23                 => p_segment23
       ,p_segment24                 => p_segment24
       ,p_segment25                 => p_segment25
       ,p_segment26                 => p_segment26
       ,p_segment27                 => p_segment27
       ,p_segment28                 => p_segment28
       ,p_segment29                 => p_segment29
       ,p_segment30                 => p_segment30
       ,p_concat_segments           => p_concat_segments
       ,p_object_version_number_inf => p_object_version_number_inf
       ,p_object_version_number_org => p_object_version_number_org
       ,p_organization_id           => p_organization_id
       ,p_org_information_id        => p_org_information_id
       ,p_duplicate_org_warning     => p_duplicate_org_warning
       );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_hr_organization'
            ,p_hook_type   => 'AP'
            );
  end;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 99);
  --
EXCEPTION

  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location(' Leaving:'||l_proc, 99);

    ROLLBACK TO create_hr_organization;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number_inf := NULL;
    p_object_version_number_org := NULL;
    p_organization_id           := NULL;
    p_org_information_id        := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 99);

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_hr_organization;
    -- Set OUT parameters.
    p_object_version_number_inf := NULL;
    p_object_version_number_org := NULL;
    p_organization_id           := NULL;
    p_org_information_id        := NULL;
    p_duplicate_org_warning     := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 99);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 99);

end create_hr_organization;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_organization >----------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is to allow backwards compatibility with calls that do not
-- include the p_duplicate_organization_warning parameter
--
PROCEDURE create_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_location_id                    in  number   default null
     ,p_date_to                        in  date     default null
     ,p_internal_external_flag         in  varchar2 default null
     ,p_internal_address_line          in  varchar2 default null
     ,p_type                           in  varchar2 default null
     ,p_comments                       in  varchar2 default null
     ,p_attribute_category             in  varchar2 default null
     ,p_attribute1                     in  varchar2 default null
     ,p_attribute2                     in  varchar2 default null
     ,p_attribute3                     in  varchar2 default null
     ,p_attribute4                     in  varchar2 default null
     ,p_attribute5                     in  varchar2 default null
     ,p_attribute6                     in  varchar2 default null
     ,p_attribute7                     in  varchar2 default null
     ,p_attribute8                     in  varchar2 default null
     ,p_attribute9                     in  varchar2 default null
     ,p_attribute10                    in  varchar2 default null
     ,p_attribute11                    in  varchar2 default null
     ,p_attribute12                    in  varchar2 default null
     ,p_attribute13                    in  varchar2 default null
     ,p_attribute14                    in  varchar2 default null
     ,p_attribute15                    in  varchar2 default null
     ,p_attribute16                    in  varchar2 default null
     ,p_attribute17                    in  varchar2 default null
     ,p_attribute18                    in  varchar2 default null
     ,p_attribute19                    in  varchar2 default null
     ,p_attribute20                    in  varchar2 default null
     --Enhancement 4040086
     --Begin of Add 10 additional segments
     ,p_attribute21                   in  varchar2 default null
     ,p_attribute22                   in  varchar2 default null
     ,p_attribute23                   in  varchar2 default null
     ,p_attribute24                   in  varchar2 default null
     ,p_attribute25                   in  varchar2 default null
     ,p_attribute26                   in  varchar2 default null
     ,p_attribute27                   in  varchar2 default null
     ,p_attribute28                   in  varchar2 default null
     ,p_attribute29                   in  varchar2 default null
     ,p_attribute30                   in  varchar2 default null
     --End of Add 10 additional segments
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
     )
IS
l_duplicate_org_warning            boolean;
begin
create_organization
  (   p_validate                      => p_validate
     ,p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_business_group_id             => p_business_group_id
     ,p_date_from                     => p_date_from
     ,p_name                          => p_name
     ,p_location_id                   => p_location_id
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     ,p_organization_id               => p_organization_id
     ,p_object_version_number         => p_object_version_number
     ,p_duplicate_org_warning         => l_duplicate_org_warning);

end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_organization >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_location_id                    in  number   default null
     ,p_date_to                        in  date     default null
     ,p_internal_external_flag         in  varchar2 default null
     ,p_internal_address_line          in  varchar2 default null
     ,p_type                           in  varchar2 default null
     ,p_comments                       in  varchar2 default null
     ,p_attribute_category             in  varchar2 default null
     ,p_attribute1                     in  varchar2 default null
     ,p_attribute2                     in  varchar2 default null
     ,p_attribute3                     in  varchar2 default null
     ,p_attribute4                     in  varchar2 default null
     ,p_attribute5                     in  varchar2 default null
     ,p_attribute6                     in  varchar2 default null
     ,p_attribute7                     in  varchar2 default null
     ,p_attribute8                     in  varchar2 default null
     ,p_attribute9                     in  varchar2 default null
     ,p_attribute10                    in  varchar2 default null
     ,p_attribute11                    in  varchar2 default null
     ,p_attribute12                    in  varchar2 default null
     ,p_attribute13                    in  varchar2 default null
     ,p_attribute14                    in  varchar2 default null
     ,p_attribute15                    in  varchar2 default null
     ,p_attribute16                    in  varchar2 default null
     ,p_attribute17                    in  varchar2 default null
     ,p_attribute18                    in  varchar2 default null
     ,p_attribute19                    in  varchar2 default null
     ,p_attribute20                    in  varchar2 default null
     --Enhancement 4040086
     --Begin of Add 10 additional segments
     ,p_attribute21                   in  varchar2 default null
     ,p_attribute22                   in  varchar2 default null
     ,p_attribute23                   in  varchar2 default null
     ,p_attribute24                   in  varchar2 default null
     ,p_attribute25                   in  varchar2 default null
     ,p_attribute26                   in  varchar2 default null
     ,p_attribute27                   in  varchar2 default null
     ,p_attribute28                   in  varchar2 default null
     ,p_attribute29                   in  varchar2 default null
     ,p_attribute30                   in  varchar2 default null
     --End of Add 10 additional segments
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
     ,p_duplicate_org_warning          OUT NOCOPY BOOLEAN
  ) IS
  --
  l_duplicate_org_warning              boolean;
  l_date_from                          date;
  l_effective_date                     date;
  l_proc                               varchar2(72) := g_package||'create_organization';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_organization;
  --
  --  All date input parameters must be truncated to remove time elements
  --  before passing into user hooks
  --
  l_date_from := trunc (p_date_from);
  l_effective_date := trunc (p_effective_date);
  --
begin
hr_organization_bk3.create_organization_b
     (p_effective_date                => l_effective_date
     ,p_language_code                 => p_language_code
     ,p_business_group_id             => p_business_group_id
     ,p_date_from                     => l_date_from
     ,p_name                          => p_name
     ,p_location_id                   => p_location_id
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_organization'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  hr_utility.set_location(l_proc, 15);
  --
  create_organization_internal
      ( p_effective_date                => p_effective_date
       ,p_language_code                 => p_language_code
       ,p_business_group_id             => p_business_group_id
       ,p_date_from                     => p_date_from
       ,p_name                          => p_name
       ,p_cost_allocation_keyflex_id    => null
       ,p_location_id                   => p_location_id
       ,p_date_to                       => p_date_to
       ,p_internal_external_flag        => p_internal_external_flag
       ,p_internal_address_line         => p_internal_address_line
       ,p_type                          => p_type
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
       --Enhancement 4040086
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       --End Enhancement 4040086
       ,p_organization_id               => p_organization_id
       ,p_object_version_number         => p_object_version_number
       ,p_duplicate_org_warning         => p_duplicate_org_warning);
  --
  hr_utility.set_location(l_proc, 20);
  --

begin
hr_organization_bk3.create_organization_a
     (p_effective_date                => l_effective_date
     ,p_language_code                 => p_language_code
     ,p_business_group_id             => p_business_group_id
     ,p_date_from                     => l_date_from
     ,p_name                          => p_name
     ,p_location_id                   => p_location_id
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     ,p_organization_id               => p_organization_id
     ,p_object_version_number         => p_object_version_number
     ,p_duplicate_org_warning         => p_duplicate_org_warning
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_organization'
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
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --

EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_organization;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    p_duplicate_org_warning := l_duplicate_org_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_organization;
    -- Set OUT parameters.
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    p_duplicate_org_warning := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_organization;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_organization >----------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is to allow backwards compatibility with calls that do not
-- include the p_duplicate_organization_warning parameter
--
PROCEDURE update_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER    DEFAULT hr_api.g_number
     ,p_location_id                    IN  NUMBER    DEFAULT hr_api.g_number
     --Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_date_from                      IN  DATE      DEFAULT hr_api.g_date
     ,p_date_to                        IN  DATE      DEFAULT hr_api.g_date
     ,p_internal_external_flag         IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_internal_address_line          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_type                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_comments                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    --Enhancement 4040086
    --Begin of Add 10 additional segments
     ,p_attribute21                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute22                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute23                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute24                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute25                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute26                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute27                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute28                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute29                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute30                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --End of Enhancement 4040086
     -- Bug 3039046
     ,p_segment1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment4                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment5                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment6                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment7                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment8                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment9                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment10                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment11                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment12                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment13                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment14                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment15                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment16                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment17                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment18                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment19                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment20                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment21                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment22                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment23                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment24                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment25                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment26                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment27                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment28                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment29                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment30                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_concat_segments                IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --
     ,p_object_version_number          IN OUT NOCOPY NUMBER
      )
IS
l_duplicate_org_warning        boolean;

-- Bug fix 3224918.
-- l_name is assgned the default value hr_api.g_varchar2.
-- This will ensure that the old database value for name
-- will be assigned to l_name while updating.
l_name                         varchar2(500) := hr_api.g_varchar2;

begin
update_organization
  (   p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_name                          => l_name
     ,p_organization_id               => p_organization_id
     ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
     ,p_location_id                   => p_location_id
     -- Bug 3040119
     --,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
     ,p_date_from                     => p_date_from
     ,p_date_to                       => p_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     -- Bug 3039046
     ,p_segment1                      => p_segment1
     ,p_segment2                      => p_segment2
     ,p_segment3                      => p_segment3
     ,p_segment4                      => p_segment4
     ,p_segment5                      => p_segment5
     ,p_segment6                      => p_segment6
     ,p_segment7                      => p_segment7
     ,p_segment8                      => p_segment8
     ,p_segment9                      => p_segment9
     ,p_segment10                     => p_segment10
     ,p_segment11                     => p_segment11
     ,p_segment12                     => p_segment12
     ,p_segment13                     => p_segment13
     ,p_segment14                     => p_segment14
     ,p_segment15                     => p_segment15
     ,p_segment16                     => p_segment16
     ,p_segment17                     => p_segment17
     ,p_segment18                     => p_segment18
     ,p_segment19                     => p_segment19
     ,p_segment20                     => p_segment20
     ,p_segment21                     => p_segment21
     ,p_segment22                     => p_segment22
     ,p_segment23                     => p_segment23
     ,p_segment24                     => p_segment24
     ,p_segment25                     => p_segment25
     ,p_segment26                     => p_segment26
     ,p_segment27                     => p_segment27
     ,p_segment28                     => p_segment28
     ,p_segment29                     => p_segment29
     ,p_segment30                     => p_segment30
     ,p_concat_segments               => p_concat_segments
     --
     ,p_object_version_number         => p_object_version_number
     ,p_duplicate_org_warning         => l_duplicate_org_warning);
end;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_organization >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_name                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER    DEFAULT hr_api.g_number
     ,p_location_id                    IN  NUMBER    DEFAULT hr_api.g_number
     -- Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_date_from                      IN  DATE      DEFAULT hr_api.g_date
     ,p_date_to                        IN  DATE      DEFAULT hr_api.g_date
     ,p_internal_external_flag         IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_internal_address_line          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_type                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_comments                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    --Enhancement 4040086
    --Begin of Add 10 additional segments
     ,p_attribute21                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute22                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute23                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute24                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute25                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute26                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute27                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute28                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute29                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute30                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --End of Add 10 additional segments
     -- Bug 3039046
     ,p_segment1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment4                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment5                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment6                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment7                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment8                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment9                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment10                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment11                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment12                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment13                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment14                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment15                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment16                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment17                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment18                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment19                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment20                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment21                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment22                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment23                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment24                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment25                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment26                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment27                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment28                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment29                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment30                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_concat_segments                IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --
     ,p_object_version_number          IN OUT NOCOPY NUMBER
     ,p_duplicate_org_warning          out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_organization';
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  l_date_from         DATE;
  l_date_to           DATE;
  l_duplicate_org_warning boolean;
  l_temp_ovn   number := p_object_version_number;
  --
  -- Bug 3039046 new variable to indicate whether cost allocation key flex
  -- entered with a value.
  --
  l_cost_null_ind               number(1) := 0;
  l_api_updating                boolean;
  l_flex_num                    fnd_id_flex_segments.id_flex_num%Type;
  l_cost_alloc_key_id           hr_all_organization_units.cost_allocation_keyflex_id%Type
                                := p_cost_allocation_keyflex_id;
  l_cost_name                   pay_cost_allocation_keyflex.concatenated_segments%Type;
  l_old_cost_name               pay_cost_allocation_keyflex.concatenated_segments%Type;
  l_business_group_id           per_all_assignments_f.business_group_id%Type;
  --
  -- bug 3039046 new variables for derived values where key flex id is known.
  --
  l_cost_segment1               varchar2(60) := p_segment1;
  l_cost_segment2               varchar2(60) := p_segment2;
  l_cost_segment3               varchar2(60) := p_segment3;
  l_cost_segment4               varchar2(60) := p_segment4;
  l_cost_segment5               varchar2(60) := p_segment5;
  l_cost_segment6               varchar2(60) := p_segment6;
  l_cost_segment7               varchar2(60) := p_segment7;
  l_cost_segment8               varchar2(60) := p_segment8;
  l_cost_segment9               varchar2(60) := p_segment9;
  l_cost_segment10              varchar2(60) := p_segment10;
  l_cost_segment11              varchar2(60) := p_segment11;
  l_cost_segment12              varchar2(60) := p_segment12;
  l_cost_segment13              varchar2(60) := p_segment13;
  l_cost_segment14              varchar2(60) := p_segment14;
  l_cost_segment15              varchar2(60) := p_segment15;
  l_cost_segment16              varchar2(60) := p_segment16;
  l_cost_segment17              varchar2(60) := p_segment17;
  l_cost_segment18              varchar2(60) := p_segment18;
  l_cost_segment19              varchar2(60) := p_segment19;
  l_cost_segment20              varchar2(60) := p_segment20;
  l_cost_segment21              varchar2(60) := p_segment21;
  l_cost_segment22              varchar2(60) := p_segment22;
  l_cost_segment23              varchar2(60) := p_segment23;
  l_cost_segment24              varchar2(60) := p_segment24;
  l_cost_segment25              varchar2(60) := p_segment25;
  l_cost_segment26              varchar2(60) := p_segment26;
  l_cost_segment27              varchar2(60) := p_segment27;
  l_cost_segment28              varchar2(60) := p_segment28;
  l_cost_segment29              varchar2(60) := p_segment29;
  l_cost_segment30              varchar2(60) := p_segment30;
  --
  cursor c_cost_segments is
         select concatenated_segments,  -- Bug 3187772
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
                segment21,
                segment22,
                segment23,
                segment24,
                segment25,
                segment26,
                segment27,
                segment28,
                segment29,
                segment30
         from   pay_cost_allocation_keyflex
         where  cost_allocation_keyflex_id = l_cost_alloc_key_id;
  --
  --
  cursor csr_cost_idsel is
         select bus.cost_allocation_structure
         from  per_business_groups_perf bus
         where bus.business_group_id = l_business_group_id;
  --
  -- Start of 3187772
    l_old_cost_segments   c_cost_segments%rowtype;
    l_old_conc_segs       pay_cost_allocation_keyflex.concatenated_segments%Type;
  -- End of 3187772
  --
BEGIN

  -- Bug 3039046 - if p_cost_allocation_keyflex_id enters with
  -- a value then get segment values from pay_cost_allocation_keyflex.
  --
  hr_utility.set_location(l_proc, 1);

  l_old_cost_name := p_concat_segments;
  --
  if nvl(l_cost_alloc_key_id, hr_api.g_number) = hr_api.g_number then -- Bug 3187772
     l_cost_null_ind := 0;
  else
  -- get segment values
     open c_cost_segments;
     fetch c_cost_segments into l_old_conc_segs, -- Bug 3187772
                                l_cost_segment1,
                                l_cost_segment2,
                                l_cost_segment3,
                                l_cost_segment4,
                                l_cost_segment5,
                                l_cost_segment6,
                                l_cost_segment7,
                                l_cost_segment8,
                                l_cost_segment9,
                                l_cost_segment10,
                                l_cost_segment11,
                                l_cost_segment12,
                                l_cost_segment13,
                                l_cost_segment14,
                                l_cost_segment15,
                                l_cost_segment16,
                                l_cost_segment17,
                                l_cost_segment18,
                                l_cost_segment19,
                                l_cost_segment20,
                                l_cost_segment21,
                                l_cost_segment22,
                                l_cost_segment23,
                                l_cost_segment24,
                                l_cost_segment25,
                                l_cost_segment26,
                                l_cost_segment27,
                                l_cost_segment28,
                                l_cost_segment29,
                                l_cost_segment30;
     close c_cost_segments;
     l_cost_null_ind := 1;
  end if;

  --
  -- Issue a savepoint.
  --
  savepoint update_organization;
  --
  l_date_from := trunc (p_date_from);
  l_date_to   := trunc (p_date_to);
  --
begin
hr_organization_bk4.update_organization_b
    ( p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_name                          => p_name
     ,p_organization_id               => p_organization_id
     ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
     ,p_location_id                   => p_location_id
     -- Bug 3040119
     --,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
     ,p_date_from                     => l_date_from
     ,p_date_to                       => l_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     -- Bug 3039046
     ,p_segment1                      => l_cost_segment1
     ,p_segment2                      => l_cost_segment2
     ,p_segment3                      => l_cost_segment3
     ,p_segment4                      => l_cost_segment4
     ,p_segment5                      => l_cost_segment5
     ,p_segment6                      => l_cost_segment6
     ,p_segment7                      => l_cost_segment7
     ,p_segment8                      => l_cost_segment8
     ,p_segment9                      => l_cost_segment9
     ,p_segment10                     => l_cost_segment10
     ,p_segment11                     => l_cost_segment11
     ,p_segment12                     => l_cost_segment12
     ,p_segment13                     => l_cost_segment13
     ,p_segment14                     => l_cost_segment14
     ,p_segment15                     => l_cost_segment15
     ,p_segment16                     => l_cost_segment16
     ,p_segment17                     => l_cost_segment17
     ,p_segment18                     => l_cost_segment18
     ,p_segment19                     => l_cost_segment19
     ,p_segment20                     => l_cost_segment20
     ,p_segment21                     => l_cost_segment21
     ,p_segment22                     => l_cost_segment22
     ,p_segment23                     => l_cost_segment23
     ,p_segment24                     => l_cost_segment24
     ,p_segment25                     => l_cost_segment25
     ,p_segment26                     => l_cost_segment26
     ,p_segment27                     => l_cost_segment27
     ,p_segment28                     => l_cost_segment28
     ,p_segment29                     => l_cost_segment29
     ,p_segment30                     => l_cost_segment30
     ,p_concat_segments               => l_old_cost_name
     --
     ,p_object_version_number         => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_organization'
        ,p_hook_type   => 'BP'
        );
  end;
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  --
  -- Validate the language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Bug 3039046
  -- Retrieve current organization details from database.
  hr_utility.set_location(l_proc, 21);
  l_api_updating := hr_oru_shd.api_updating
                    (p_organization_id         => p_organization_id
                    ,p_object_version_number   => l_object_version_number);

  -- Maintain the people cost allocation key flexfields.
  --
  -- Only call the flex code if a non-default value(includng null) is passed
  -- to the procedure.
  --
  --
  hr_utility.set_location(l_proc, 22);

  if not l_api_updating then
     hr_utility.set_location(l_proc, 23);
  --
  -- As this is an updating API, the organization should already exist.
  --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;

  -- Populate l_business_group_id from g_old_rec for cursor csr_cost_idsel
  l_business_group_id := hr_oru_shd.g_old_rec.business_group_id;
  open csr_cost_idsel;
    fetch csr_cost_idsel into l_flex_num;
      if csr_cost_idsel%NOTFOUND then
         close csr_cost_idsel;
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP','5');
            hr_utility.raise_error;
      end if;
  close csr_cost_idsel;

  hr_utility.set_location(l_proc, 24);

  if l_cost_null_ind = 0 then
  --
     l_cost_alloc_key_id := hr_oru_shd.g_old_rec.cost_allocation_keyflex_id;
  --
     --
     -- Start of 4176977
     if l_cost_alloc_key_id is not null then
        open c_cost_segments;
        fetch c_cost_segments into l_old_cost_segments;
        close c_cost_segments;
     end if;
     --
     if nvl(l_cost_segment1, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment1, hr_api.g_varchar2)
        or nvl(l_cost_segment2, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment2, hr_api.g_varchar2)
        or nvl(l_cost_segment3, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment3, hr_api.g_varchar2)
        or nvl(l_cost_segment4, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment4, hr_api.g_varchar2)
        or nvl(l_cost_segment5, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment5, hr_api.g_varchar2)
        or nvl(l_cost_segment6, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment6, hr_api.g_varchar2)
        or nvl(l_cost_segment7, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment7, hr_api.g_varchar2)
        or nvl(l_cost_segment8, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment8, hr_api.g_varchar2)
        or nvl(l_cost_segment9, hr_api.g_varchar2)  <> nvl(l_old_cost_segments.segment9, hr_api.g_varchar2)
        or nvl(l_cost_segment10, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment10, hr_api.g_varchar2)
        or nvl(l_cost_segment11, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment11, hr_api.g_varchar2)
        or nvl(l_cost_segment12, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment12, hr_api.g_varchar2)
        or nvl(l_cost_segment13, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment13, hr_api.g_varchar2)
        or nvl(l_cost_segment14, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment14, hr_api.g_varchar2)
        or nvl(l_cost_segment15, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment15, hr_api.g_varchar2)
        or nvl(l_cost_segment16, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment16, hr_api.g_varchar2)
        or nvl(l_cost_segment17, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment17, hr_api.g_varchar2)
        or nvl(l_cost_segment18, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment18, hr_api.g_varchar2)
        or nvl(l_cost_segment19, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment19, hr_api.g_varchar2)
        or nvl(l_cost_segment20, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment20, hr_api.g_varchar2)
        or nvl(l_cost_segment21, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment21, hr_api.g_varchar2)
        or nvl(l_cost_segment22, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment22, hr_api.g_varchar2)
        or nvl(l_cost_segment23, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment23, hr_api.g_varchar2)
        or nvl(l_cost_segment24, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment24, hr_api.g_varchar2)
        or nvl(l_cost_segment25, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment25, hr_api.g_varchar2)
        or nvl(l_cost_segment26, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment26, hr_api.g_varchar2)
        or nvl(l_cost_segment27, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment27, hr_api.g_varchar2)
        or nvl(l_cost_segment28, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment28, hr_api.g_varchar2)
        or nvl(l_cost_segment29, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment29, hr_api.g_varchar2)
        or nvl(l_cost_segment30, hr_api.g_varchar2) <> nvl(l_old_cost_segments.segment30, hr_api.g_varchar2)
        or nvl(l_old_cost_name, hr_api.g_varchar2) <> nvl(l_old_cost_segments.concatenated_segments, hr_api.g_varchar2) then
     -- End of 3187772
        hr_kflex_utility.upd_or_sel_keyflex_comb
        (p_appl_short_name              => 'PAY'
        ,p_flex_code                    => 'COST'
        ,p_flex_num                     => l_flex_num
        ,p_segment1                     => l_cost_segment1
        ,p_segment2                     => l_cost_segment2
        ,p_segment3                     => l_cost_segment3
        ,p_segment4                     => l_cost_segment4
        ,p_segment5                     => l_cost_segment5
        ,p_segment6                     => l_cost_segment6
        ,p_segment7                     => l_cost_segment7
        ,p_segment8                     => l_cost_segment8
        ,p_segment9                     => l_cost_segment9
        ,p_segment10                    => l_cost_segment10
        ,p_segment11                    => l_cost_segment11
        ,p_segment12                    => l_cost_segment12
        ,p_segment13                    => l_cost_segment13
        ,p_segment14                    => l_cost_segment14
        ,p_segment15                    => l_cost_segment15
        ,p_segment16                    => l_cost_segment16
        ,p_segment17                    => l_cost_segment17
        ,p_segment18                    => l_cost_segment18
        ,p_segment19                    => l_cost_segment19
        ,p_segment20                    => l_cost_segment20
        ,p_segment21                    => l_cost_segment21
        ,p_segment22                    => l_cost_segment22
        ,p_segment23                    => l_cost_segment23
        ,p_segment24                    => l_cost_segment24
        ,p_segment25                    => l_cost_segment25
        ,p_segment26                    => l_cost_segment26
        ,p_segment27                    => l_cost_segment27
        ,p_segment28                    => l_cost_segment28
        ,p_segment29                    => l_cost_segment29
        ,p_segment30                    => l_cost_segment30
        ,p_concat_segments_in           => l_old_cost_name
        ,p_ccid                         => l_cost_alloc_key_id
        ,p_concat_segments_out          => l_cost_name
        );
          --
          hr_utility.set_location(l_proc, 25);
          --
     -- update the combinations column
          -- Start of 3187772
          update_cost_concat_segs (p_cost_allocation_keyflex_id  => l_cost_alloc_key_id
                                  ,p_cost_name                   => l_cost_name);
          -- End of 3187772
     end if;
  --
  hr_utility.set_location(l_proc, 26);
  --
  end if;
  --

  --
  --  Update non-translatable rows in HR_ALL_ORGANIZATION_UNITS Table
  --
  hr_oru_upd.upd
    ( p_effective_date                => p_effective_date
     ,p_name                          => p_name
     ,p_organization_id               => p_organization_id
     ,p_cost_allocation_keyflex_id    => l_cost_alloc_key_id -- Bug 3187772
     ,p_location_id                   => p_location_id
     -- Bug 3040119
     --,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
     ,p_date_from                     => l_date_from
     ,p_date_to                       => l_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     ,p_object_version_number         => l_object_version_number
     ,p_duplicate_org_warning         => p_duplicate_org_warning
    );
  --
  hr_utility.set_location(l_proc, 55);
  --
-- update the TL table
 hr_ort_upd.upd_tl(
    p_language_code => p_language_code,
    p_organization_id => p_organization_id,
    p_name => p_name);
--
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --

begin
hr_organization_bk4.update_organization_a
    ( p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_name                          => p_name
     ,p_organization_id               => p_organization_id
     ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
     ,p_location_id                   => p_location_id
     -- Bug 3040119
     --,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
     ,p_date_from                     => l_date_from
     ,p_date_to                       => l_date_to
     ,p_internal_external_flag        => p_internal_external_flag
     ,p_internal_address_line         => p_internal_address_line
     ,p_type                          => p_type
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
     --Enhancement 4040086
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
     --End Enhancement 4040086
     -- Bug 3039046
     ,p_segment1                      => l_cost_segment1
     ,p_segment2                      => l_cost_segment2
     ,p_segment3                      => l_cost_segment3
     ,p_segment4                      => l_cost_segment4
     ,p_segment5                      => l_cost_segment5
     ,p_segment6                      => l_cost_segment6
     ,p_segment7                      => l_cost_segment7
     ,p_segment8                      => l_cost_segment8
     ,p_segment9                      => l_cost_segment9
     ,p_segment10                     => l_cost_segment10
     ,p_segment11                     => l_cost_segment11
     ,p_segment12                     => l_cost_segment12
     ,p_segment13                     => l_cost_segment13
     ,p_segment14                     => l_cost_segment14
     ,p_segment15                     => l_cost_segment15
     ,p_segment16                     => l_cost_segment16
     ,p_segment17                     => l_cost_segment17
     ,p_segment18                     => l_cost_segment18
     ,p_segment19                     => l_cost_segment19
     ,p_segment20                     => l_cost_segment20
     ,p_segment21                     => l_cost_segment21
     ,p_segment22                     => l_cost_segment22
     ,p_segment23                     => l_cost_segment23
     ,p_segment24                     => l_cost_segment24
     ,p_segment25                     => l_cost_segment25
     ,p_segment26                     => l_cost_segment26
     ,p_segment27                     => l_cost_segment27
     ,p_segment28                     => l_cost_segment28
     ,p_segment29                     => l_cost_segment29
     ,p_segment30                     => l_cost_segment30
     ,p_concat_segments               => l_old_cost_name
     ,p_cost_name                     => l_cost_name
     --
     ,p_object_version_number         => l_object_version_number
     ,p_duplicate_org_warning         => p_duplicate_org_warning
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_organization'
        ,p_hook_type   => 'AP'
        );
  end;

EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_organization;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Set IN OUT and OUT parameters.
    p_object_version_number  :=  l_temp_ovn;
    p_duplicate_org_warning  :=  l_duplicate_org_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_organization;
    -- Set IN OUT and OUT parameters.
    p_object_version_number  :=  l_temp_ovn;
    p_duplicate_org_warning  :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_organization;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_organization >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_organization
   (  p_validate                     IN BOOLEAN
     ,p_organization_id              IN hr_all_organization_units.organization_id%TYPE
     ,p_object_version_number        IN hr_all_organization_units.object_version_number%TYPE )

IS
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_organization';
  --
BEGIN

  --
  -- Issue a savepoint
  --
  savepoint delete_organization;
  --
begin
hr_organization_bk5.delete_organization_b
    (p_organization_id             => p_organization_id
    ,p_object_version_number       => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_organization'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  hr_oru_shd.lck (   p_organization_id             => p_organization_id,
                     p_object_version_number       => p_object_version_number );
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);
  hr_ort_del.del_tl ( p_organization_id            => p_organization_id );
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);

  -- bug fix 3571140.Record for the organization deleted from PER_ORGANIZATION_LIST
  -- table.

  delete from per_organization_list
  where organization_id = p_organization_id;

  hr_utility.set_location( l_proc, 45);

  -- bug fix 3571140 ends here.

  hr_oru_del.del   (  p_organization_id            => p_organization_id,
    p_object_version_number       => p_object_version_number );
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
     RAISE hr_api.validate_enabled;
  END IF;
  --
  --
begin
hr_organization_bk5.delete_organization_a
    (p_organization_id              => p_organization_id
    ,p_object_version_number        => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_organization'
        ,p_hook_type   => 'AP'
        );
  end;


EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_organization;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO delete_organization;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
END delete_organization;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cls_mand >---------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that classification does not have mandatory info types in
--    HR_ORG_INFO_TYPES_BY_CLASS table.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_org_classif_code
--    p_parent_call
--    p_legislation_code
--
--  Post Success:
--    If classification does not have mandatory info types then
--    normal processing continues depending on p_parent_call value.
--
--  Post Failure:
--    If classification has mandatory info types which are either
--    global or for the current legislation then an application
--    error will be raised and processing is terminated
--    depending on p_parent_call value.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    From Business Processes
--
-- {End Of Comments}
--
PROCEDURE chk_cls_mand
  (p_org_classif_code IN hr_organization_information.org_information1%TYPE,
   p_parent_call IN VARCHAR2,
   p_organization_id IN NUMBER)
IS
  --
  cursor csr_get_leg_code is
      select legislation_code
        from per_business_groups pbg,
        hr_all_organization_units hou
       where hou.organization_id = p_organization_id
         and pbg.business_group_id = hou.business_group_id;

  l_proc           VARCHAR2(72)  :=  g_package||'chk_cls_mand';
  l_exists         VARCHAR2(1) := 'N';
  l_legislation_code VARCHAR2(5);
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
  open csr_get_leg_code;
  fetch csr_get_leg_code into l_legislation_code;
  close csr_get_leg_code;
--
-- Check classification with mandatory info types presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_org_info_types_by_class class,
           hr_org_information_types type
      WHERE class.org_classification = p_org_classif_code
        AND class.org_information_type = type.org_information_type
   AND (   type.legislation_code is null
        OR type.legislation_code = l_legislation_code)
        AND class.mandatory_flag = 'Y'
      );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'Y'
      AND p_parent_call = 'REGULAR' THEN
     hr_utility.set_message(800, 'HR_289000_CLSF_MAND_INFO_TYPE');
     hr_utility.raise_error;
   END IF;
/*
  What does this do, it makes no sense.
  WWBUG 2557238
   IF l_exists = 'N'
      AND p_parent_call = 'INTERNAL' THEN
     hr_utility.set_message(800, 'HR_289001_CLSF_NO_MAND_INFO');
     hr_utility.raise_error;
   END IF;
*/
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_cls_mand;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_org_classification >----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_classification
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --

  --
  l_proc                  VARCHAR2(72) := g_package||'create_org_classification';
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_classification;
  --
  hr_utility.set_location(l_proc, 15);
  begin
    hr_organization_bk6.create_org_classification_b
      (p_effective_date                => p_effective_date
      ,p_organization_id               => p_organization_id
      ,p_org_classif_code              =>p_org_classif_code);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_classification'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORGANIZATION_ID'
    ,p_argument_value     => p_organization_id );

  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Check if it is proper classification first
  -- by calling Business Support process
  --
  chk_cls_mand(
    p_org_classif_code => p_org_classif_code,
    p_parent_call => 'REGULAR',
    p_organization_id => p_organization_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_ori_ins.ins(
    p_effective_date   => p_effective_date,
    p_org_information_context => 'CLASS',
    p_organization_id   => p_organization_id,
    p_org_information1   => p_org_classif_code,
    p_org_information2  => 'Y',
    p_org_information_id  => l_org_information_id,
    p_object_version_number => l_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_org_information_id := l_org_information_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
begin

hr_organization_bk6.create_org_classification_a
     (p_effective_date                => p_effective_date
     ,p_organization_id               => p_organization_id
     ,p_org_classif_code              => p_org_classif_code
 );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_classification'
        ,p_hook_type   => 'AP'
        );
  end;
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_org_classification;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_org_information_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_org_classification;
    -- Set OUT parameters.
    p_org_information_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_org_classification;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cls_row >----------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that classification does not have mandatory info types in
--    HR_ORG_INFO_TYPES_BY_CLASS table.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_org_information_id
--
--  Post Success:
--    If the row of p_org_information_id has org_information_context
--    value 'CLASS' then normal processing continues.
--
--  Post Failure:
--    If the row of p_org_information_id does not have a value 'CLASS'
--    then an application error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    From Business Processes
--
-- {End Of Comments}
--
PROCEDURE chk_cls_row
  (p_org_information_id IN hr_organization_information.org_information_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_cls_row';
   l_context        VARCHAR2(40);
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check classification with mandatory info types presence
--
  BEGIN
   SELECT org_information_context
   INTO l_context
   FROM hr_organization_information
   WHERE org_information_id = p_org_information_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_context IS NULL OR
      (l_context IS NOT NULL AND l_context <> 'CLASS') THEN
     hr_utility.set_message(800, 'HR_52762_NOT_CLSF_ROW');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_cls_row;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< enable_org_classification >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE enable_org_classification
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'enable_org_classification';
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint enable_org_classification;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that row has org_information_context as 'CLASS'
  --
  chk_cls_row(p_org_information_id  => p_org_information_id);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  --  Update row in HR_ORGANIZATION_INFORMATION Table
  --
  hr_ori_upd.upd
    ( p_effective_date                => p_effective_date
     ,p_org_information_id            => p_org_information_id
     ,p_org_information_context       => p_org_info_type_code
     ,p_org_information2              => 'Y'
     ,p_object_version_number         => l_object_version_number
    );
  --
  --
--
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO enable_org_classification;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO enable_org_classification;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END enable_org_classification;
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |--------------------------< disable_org_classification >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE disable_org_classification
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'disable_org_classification';
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint disable_org_classification;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that row has org_information_context as 'CLASS'
  --
  chk_cls_row(p_org_information_id  => p_org_information_id);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  --  Update row in HR_ORGANIZATION_INFORMATION Table
  --
  hr_ori_upd.upd
    ( p_effective_date                => p_effective_date
     ,p_org_information_id            => p_org_information_id
     ,p_org_information_context       => p_org_info_type_code
     ,p_org_information2              => 'N'
     ,p_object_version_number         => l_object_version_number
    );
  --
  --
--
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO disable_org_classification;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO disable_org_classification;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END disable_org_classification;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_org_information >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_information
  (p_validate                       IN  BOOLEAN   DEFAULT false
  ,p_effective_date                 IN  DATE
  ,p_organization_id                IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2 DEFAULT null
  ,p_org_information2               IN  VARCHAR2 DEFAULT null
  ,p_org_information3               IN  VARCHAR2 DEFAULT null
  ,p_org_information4               IN  VARCHAR2 DEFAULT null
  ,p_org_information5               IN  VARCHAR2 DEFAULT null
  ,p_org_information6               IN  VARCHAR2 DEFAULT null
  ,p_org_information7               IN  VARCHAR2 DEFAULT null
  ,p_org_information8               IN  VARCHAR2 DEFAULT null
  ,p_org_information9               IN  VARCHAR2 DEFAULT null
  ,p_org_information10              IN  VARCHAR2 DEFAULT null
  ,p_org_information11              IN  VARCHAR2 DEFAULT null
  ,p_org_information12              IN  VARCHAR2 DEFAULT null
  ,p_org_information13              IN  VARCHAR2 DEFAULT null
  ,p_org_information14              IN  VARCHAR2 DEFAULT null
  ,p_org_information15              IN  VARCHAR2 DEFAULT null
  ,p_org_information16              IN  VARCHAR2 DEFAULT null
  ,p_org_information17              IN  VARCHAR2 DEFAULT null
  ,p_org_information18              IN  VARCHAR2 DEFAULT null
  ,p_org_information19              IN  VARCHAR2 DEFAULT null
  ,p_org_information20              IN  VARCHAR2 DEFAULT null
  ,p_attribute_category             IN  VARCHAR2 DEFAULT null
  ,p_attribute1                     IN  VARCHAR2 DEFAULT null
  ,p_attribute2                     IN  VARCHAR2 DEFAULT null
  ,p_attribute3                     IN  VARCHAR2 DEFAULT null
  ,p_attribute4                     IN  VARCHAR2 DEFAULT null
  ,p_attribute5                     IN  VARCHAR2 DEFAULT null
  ,p_attribute6                     IN  VARCHAR2 DEFAULT null
  ,p_attribute7                     IN  VARCHAR2 DEFAULT null
  ,p_attribute8                     IN  VARCHAR2 DEFAULT null
  ,p_attribute9                     IN  VARCHAR2 DEFAULT null
  ,p_attribute10                    IN  VARCHAR2 DEFAULT null
  ,p_attribute11                    IN  VARCHAR2 DEFAULT null
  ,p_attribute12                    IN  VARCHAR2 DEFAULT null
  ,p_attribute13                    IN  VARCHAR2 DEFAULT null
  ,p_attribute14                    IN  VARCHAR2 DEFAULT null
  ,p_attribute15                    IN  VARCHAR2 DEFAULT null
  ,p_attribute16                    IN  VARCHAR2 DEFAULT null
  ,p_attribute17                    IN  VARCHAR2 DEFAULT null
  ,p_attribute18                    IN  VARCHAR2 DEFAULT null
  ,p_attribute19                    IN  VARCHAR2 DEFAULT null
  ,p_attribute20                    IN  VARCHAR2 DEFAULT null
  ,p_org_information_id             OUT NOCOPY NUMBER
  ,p_object_version_number          OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_org_information';
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  l_session_id            number;
  l_effective_date        date;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_information;
  --
  hr_utility.set_location(l_proc, 20);

  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_organization_bk1.create_org_information_b
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_organization_id       => p_organization_id
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_information'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 30);

  -- Insert the effective date into fnd_sessions for the flexfield
  -- validation to work  (Bug#3286325)

    hr_kflex_utility.set_session_date
         (p_effective_date => l_effective_date
         ,p_session_id     => l_session_id);
  --
  -- Process Logic
  --
  hr_ori_ins.ins(
    p_effective_date          => p_effective_date,
    p_org_information_context => p_org_info_type_code,
    p_organization_id         => p_organization_id,
    p_org_information1        => p_org_information1,
    p_org_information2        => p_org_information2,
    p_org_information3        => p_org_information3,
    p_org_information4        => p_org_information4,
    p_org_information5        => p_org_information5,
    p_org_information6        => p_org_information6,
    p_org_information7        => p_org_information7,
    p_org_information8        => p_org_information8,
    p_org_information9        => p_org_information9,
    p_org_information10       => p_org_information10,
    p_org_information11       => p_org_information11,
    p_org_information12       => p_org_information12,
    p_org_information13       => p_org_information13,
    p_org_information14       => p_org_information14,
    p_org_information15       => p_org_information15,
    p_org_information16       => p_org_information16,
    p_org_information17       => p_org_information17,
    p_org_information18       => p_org_information18,
    p_org_information19       => p_org_information19,
    p_org_information20       => p_org_information20,
    p_attribute_category      => p_attribute_category,
    p_attribute1              => p_attribute1,
    p_attribute2              => p_attribute2,
    p_attribute3              => p_attribute3,
    p_attribute4              => p_attribute4,
    p_attribute5              => p_attribute5,
    p_attribute6              => p_attribute6,
    p_attribute7              => p_attribute7,
    p_attribute8              => p_attribute8,
    p_attribute9              => p_attribute9,
    p_attribute10             => p_attribute10,
    p_attribute11             => p_attribute11,
    p_attribute12             => p_attribute12,
    p_attribute13             => p_attribute13,
    p_attribute14             => p_attribute14,
    p_attribute15             => p_attribute15,
    p_attribute16             => p_attribute16,
    p_attribute17             => p_attribute17,
    p_attribute18             => p_attribute18,
    p_attribute19             => p_attribute19,
    p_attribute20             => p_attribute20,
    p_org_information_id      => l_org_information_id,
    p_object_version_number   => l_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Call After Process User Hook
  --
  begin
    hr_organization_bk1.create_org_information_a
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_organization_id       => p_organization_id
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_org_information_id    => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_information'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_org_information_id    := l_org_information_id;
  p_object_version_number := l_object_version_number;
  --
  --
  -- remove data from the session table (Bug# 3286325)
  --
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_org_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_org_information_id     := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_org_information;
    -- Set OUT parameters
    p_org_information_id     := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_org_information;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_org_manager >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_manager
  (p_validate                       IN  BOOLEAN   DEFAULT false
  ,p_effective_date                 IN  DATE
  ,p_organization_id                IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2 DEFAULT null
  ,p_org_information2               IN  VARCHAR2 DEFAULT null
  ,p_org_information3               IN  VARCHAR2 DEFAULT null
  ,p_org_information4               IN  VARCHAR2 DEFAULT null
  ,p_org_information5               IN  VARCHAR2 DEFAULT null
  ,p_org_information6               IN  VARCHAR2 DEFAULT null
  ,p_org_information7               IN  VARCHAR2 DEFAULT null
  ,p_org_information8               IN  VARCHAR2 DEFAULT null
  ,p_org_information9               IN  VARCHAR2 DEFAULT null
  ,p_org_information10              IN  VARCHAR2 DEFAULT null
  ,p_org_information11              IN  VARCHAR2 DEFAULT null
  ,p_org_information12              IN  VARCHAR2 DEFAULT null
  ,p_org_information13              IN  VARCHAR2 DEFAULT null
  ,p_org_information14              IN  VARCHAR2 DEFAULT null
  ,p_org_information15              IN  VARCHAR2 DEFAULT null
  ,p_org_information16              IN  VARCHAR2 DEFAULT null
  ,p_org_information17              IN  VARCHAR2 DEFAULT null
  ,p_org_information18              IN  VARCHAR2 DEFAULT null
  ,p_org_information19              IN  VARCHAR2 DEFAULT null
  ,p_org_information20              IN  VARCHAR2 DEFAULT null
  ,p_attribute_category             IN  VARCHAR2 DEFAULT null
  ,p_attribute1                     IN  VARCHAR2 DEFAULT null
  ,p_attribute2                     IN  VARCHAR2 DEFAULT null
  ,p_attribute3                     IN  VARCHAR2 DEFAULT null
  ,p_attribute4                     IN  VARCHAR2 DEFAULT null
  ,p_attribute5                     IN  VARCHAR2 DEFAULT null
  ,p_attribute6                     IN  VARCHAR2 DEFAULT null
  ,p_attribute7                     IN  VARCHAR2 DEFAULT null
  ,p_attribute8                     IN  VARCHAR2 DEFAULT null
  ,p_attribute9                     IN  VARCHAR2 DEFAULT null
  ,p_attribute10                    IN  VARCHAR2 DEFAULT null
  ,p_attribute11                    IN  VARCHAR2 DEFAULT null
  ,p_attribute12                    IN  VARCHAR2 DEFAULT null
  ,p_attribute13                    IN  VARCHAR2 DEFAULT null
  ,p_attribute14                    IN  VARCHAR2 DEFAULT null
  ,p_attribute15                    IN  VARCHAR2 DEFAULT null
  ,p_attribute16                    IN  VARCHAR2 DEFAULT null
  ,p_attribute17                    IN  VARCHAR2 DEFAULT null
  ,p_attribute18                    IN  VARCHAR2 DEFAULT null
  ,p_attribute19                    IN  VARCHAR2 DEFAULT null
  ,p_attribute20                    IN  VARCHAR2 DEFAULT null
  ,p_org_information_id             OUT NOCOPY NUMBER
  ,p_object_version_number          OUT NOCOPY NUMBER
  ,p_warning                        OUT NOCOPY BOOLEAN
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'create_org_manager';
  l_org_information_id hr_organization_information.org_information_id%TYPE;
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  l_warning boolean;
  --
  cursor c1 is
    select business_group_id
    from   hr_all_organization_units
    where  organization_id = p_organization_id;
  --
  l_business_group_id number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open c1;
    --
    fetch c1 into l_business_group_id;
    if c1%found then
      --
      fnd_profile.put('PER_BUSINESS_GROUP_ID',l_business_group_id);
      --
    end if;
    --
  close c1;
  --
  -- Issue a savepoint
  --
  savepoint create_org_information;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  if p_org_info_type_code <> 'Business Group Information' then
  begin
    --
    hr_organization_bk1.create_org_information_b
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_organization_id       => p_organization_id
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_information'
        ,p_hook_type   => 'BP');
    --
  end;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  hr_ori_ins.ins
    (p_effective_date          => p_effective_date
    ,p_org_information_context => p_org_info_type_code
    ,p_organization_id         => p_organization_id
    ,p_org_information1        => p_org_information1
    ,p_org_information2        => p_org_information2
    ,p_org_information3        => p_org_information3
    ,p_org_information4        => p_org_information4
    ,p_org_information5        => p_org_information5
    ,p_org_information6        => p_org_information6
    ,p_org_information7        => p_org_information7
    ,p_org_information8        => p_org_information8
    ,p_org_information9        => p_org_information9
    ,p_org_information10       => p_org_information10
    ,p_org_information11       => p_org_information11
    ,p_org_information12       => p_org_information12
    ,p_org_information13       => p_org_information13
    ,p_org_information14       => p_org_information14
    ,p_org_information15       => p_org_information15
    ,p_org_information16       => p_org_information16
    ,p_org_information17       => p_org_information17
    ,p_org_information18       => p_org_information18
    ,p_org_information19       => p_org_information19
    ,p_org_information20       => p_org_information20
    ,p_attribute_category      => p_attribute_category
    ,p_attribute1              => p_attribute1
    ,p_attribute2              => p_attribute2
    ,p_attribute3              => p_attribute3
    ,p_attribute4              => p_attribute4
    ,p_attribute5              => p_attribute5
    ,p_attribute6              => p_attribute6
    ,p_attribute7              => p_attribute7
    ,p_attribute8              => p_attribute8
    ,p_attribute9              => p_attribute9
    ,p_attribute10             => p_attribute10
    ,p_attribute11             => p_attribute11
    ,p_attribute12             => p_attribute12
    ,p_attribute13             => p_attribute13
    ,p_attribute14             => p_attribute14
    ,p_attribute15             => p_attribute15
    ,p_attribute16             => p_attribute16
    ,p_attribute17             => p_attribute17
    ,p_attribute18             => p_attribute18
    ,p_attribute19             => p_attribute19
    ,p_attribute20             => p_attribute20
    ,p_org_information_id      => l_org_information_id
    ,p_object_version_number   => l_object_version_number);
  --
  -- Set the warning parameter if a gap occurred
  --
  l_warning := false;
  --
  if p_org_info_type_code = 'Organization Name Alias' then
    --
    if hr_ori_bus.chk_cost_center_gap
      (p_organization_id         => p_organization_id,
       p_org_information_id      => l_org_information_id,
       p_org_information_context => p_org_info_type_code,
       p_start_date              => fnd_date.canonical_to_date(p_org_information3),
       p_end_date                => fnd_date.canonical_to_date(p_org_information4)) then
      --
      l_warning := true;
      --
    else
      --
      l_warning := false;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Bug 3617238 START
  --
  IF p_org_info_type_code = 'Business Group Information' THEN
    --
    pay_generic_upgrade.new_business_group( p_bus_grp_id => p_organization_id
                                           ,p_leg_code   => p_org_information9
                                          );
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 45);
  --
  -- Bug 3617238 END
  --
  --
  -- Call After Process User Hook
  --
  begin
    --
    hr_organization_bk1.create_org_information_a
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_organization_id       => p_organization_id
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_org_information_id    => l_org_information_id
      ,p_object_version_number => l_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_information'
        ,p_hook_type   => 'AP');
    --
  end;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_org_information_id    := l_org_information_id;
  p_object_version_number := l_object_version_number;
  p_warning := l_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_org_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_org_information_id     := NULL;
    p_object_version_number  := NULL;
    p_warning  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_org_information;
    --
    p_org_information_id     := NULL;
    p_object_version_number  := NULL;
    p_warning  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
end create_org_manager;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_org_information >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_org_information
  (p_validate                       IN  BOOLEAN   DEFAULT false
  ,p_effective_date                 IN  DATE
  ,p_org_information_id             IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information2               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information3               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information4               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information5               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information6               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information7               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information8               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information9               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information10              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information11              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information12              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information13              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information14              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information15              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information16              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information17              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information18              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information19              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information20              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category             IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_org_information';
  l_object_version_number hr_organization_information.object_version_number%TYPE := p_object_version_number;
  l_temp_ovn   number := p_object_version_number;
  --

    cursor csr_check_ou
         is
         select 1 from hr_organization_information hoi
         where hoi.org_information_id = p_org_information_id
         and hoi.org_information_context = p_org_info_type_code;
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_org_information;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that mandatory info types cannot be updated after
  -- they were created
  --
  IF   p_org_info_type_code = 'Business Group Information'
  --  OR p_org_info_type_code = 'Operating Unit Information'
    OR p_org_info_type_code = 'Canada Employer Identification'
    OR p_org_info_type_code = 'FPT_BRANCH_INFO'
    OR p_org_info_type_code = 'FPT_BANK_INFO' THEN
     hr_utility.set_message(800, 'HR_289005_INFO_TYPE_NONUPD');
     hr_utility.raise_error;
  END IF;
  --
  open csr_check_ou;
    IF csr_check_ou%notfound then
       hr_utility.set_message(800, 'HR_289005_INFO_TYPE_NONUPD');
       hr_utility.raise_error;
    END IF;

  hr_utility.set_location(l_proc, 30);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_organization_bk2.update_org_information_b
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_org_information_id    => p_org_information_id
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_object_version_number => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_information'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 40);
  --
  --  Update row in HR_ORGANIZATION_INFORMATION Table
  --
  hr_ori_upd.upd(
    p_effective_date          => p_effective_date,
    p_org_information_id      => p_org_information_id,
    p_org_information_context => p_org_info_type_code,
    p_org_information1        => p_org_information1,
    p_org_information2        => p_org_information2,
    p_org_information3        => p_org_information3,
    p_org_information4        => p_org_information4,
    p_org_information5        => p_org_information5,
    p_org_information6        => p_org_information6,
    p_org_information7        => p_org_information7,
    p_org_information8        => p_org_information8,
    p_org_information9        => p_org_information9,
    p_org_information10       => p_org_information10,
    p_org_information11       => p_org_information11,
    p_org_information12       => p_org_information12,
    p_org_information13       => p_org_information13,
    p_org_information14       => p_org_information14,
    p_org_information15       => p_org_information15,
    p_org_information16       => p_org_information16,
    p_org_information17       => p_org_information17,
    p_org_information18       => p_org_information18,
    p_org_information19       => p_org_information19,
    p_org_information20       => p_org_information20,
    p_attribute_category      => p_attribute_category,
    p_attribute1              => p_attribute1,
    p_attribute2              => p_attribute2,
    p_attribute3              => p_attribute3,
    p_attribute4              => p_attribute4,
    p_attribute5              => p_attribute5,
    p_attribute6              => p_attribute6,
    p_attribute7              => p_attribute7,
    p_attribute8              => p_attribute8,
    p_attribute9              => p_attribute9,
    p_attribute10             => p_attribute10,
    p_attribute11             => p_attribute11,
    p_attribute12             => p_attribute12,
    p_attribute13             => p_attribute13,
    p_attribute14             => p_attribute14,
    p_attribute15             => p_attribute15,
    p_attribute16             => p_attribute16,
    p_attribute17             => p_attribute17,
    p_attribute18             => p_attribute18,
    p_attribute19             => p_attribute19,
    p_attribute20             => p_attribute20,
    p_object_version_number   => l_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    hr_organization_bk2.update_org_information_a
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_org_information_id    => p_org_information_id
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_object_version_number => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_information'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_org_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_org_information;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_org_information;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_org_manager >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_org_manager
  (p_validate                       IN  BOOLEAN   DEFAULT false
  ,p_effective_date                 IN  DATE
  ,p_organization_id                IN  NUMBER
  ,p_org_information_id             IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information2               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information3               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information4               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information5               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information6               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information7               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information8               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information9               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information10              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information11              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information12              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information13              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information14              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information15              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information16              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information17              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information18              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information19              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information20              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category             IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_warning                        OUT NOCOPY BOOLEAN
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_org_manager';
  l_object_version_number hr_organization_information.object_version_number%TYPE := p_object_version_number;
  l_warning               boolean;
  l_temp_ovn   number := p_object_version_number;
  --
  cursor c1 is
    select business_group_id
    from   hr_all_organization_units
    where  organization_id = p_organization_id;
  --
  l_business_group_id number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  open c1;
    --
    fetch c1 into l_business_group_id;
    if c1%found then
      --
      fnd_profile.put('PER_BUSINESS_GROUP_ID',l_business_group_id);
      --
    end if;
    --
  close c1;
  --
  savepoint update_org_information;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    --
    hr_organization_bk2.update_org_information_b
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_org_information_id    => p_org_information_id
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_object_version_number => l_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_information'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 40);
  --
  --  Update row in HR_ORGANIZATION_INFORMATION Table
  --
  hr_ori_upd.upd
    (p_effective_date          => p_effective_date
    ,p_org_information_id      => p_org_information_id
    ,p_org_information_context => p_org_info_type_code
    ,p_org_information1        => p_org_information1
    ,p_org_information2        => p_org_information2
    ,p_org_information3        => p_org_information3
    ,p_org_information4        => p_org_information4
    ,p_org_information5        => p_org_information5
    ,p_org_information6        => p_org_information6
    ,p_org_information7        => p_org_information7
    ,p_org_information8        => p_org_information8
    ,p_org_information9        => p_org_information9
    ,p_org_information10       => p_org_information10
    ,p_org_information11       => p_org_information11
    ,p_org_information12       => p_org_information12
    ,p_org_information13       => p_org_information13
    ,p_org_information14       => p_org_information14
    ,p_org_information15       => p_org_information15
    ,p_org_information16       => p_org_information16
    ,p_org_information17       => p_org_information17
    ,p_org_information18       => p_org_information18
    ,p_org_information19       => p_org_information19
    ,p_org_information20       => p_org_information20
    ,p_attribute_category      => p_attribute_category
    ,p_attribute1              => p_attribute1
    ,p_attribute2              => p_attribute2
    ,p_attribute3              => p_attribute3
    ,p_attribute4              => p_attribute4
    ,p_attribute5              => p_attribute5
    ,p_attribute6              => p_attribute6
    ,p_attribute7              => p_attribute7
    ,p_attribute8              => p_attribute8
    ,p_attribute9              => p_attribute9
    ,p_attribute10             => p_attribute10
    ,p_attribute11             => p_attribute11
    ,p_attribute12             => p_attribute12
    ,p_attribute13             => p_attribute13
    ,p_attribute14             => p_attribute14
    ,p_attribute15             => p_attribute15
    ,p_attribute16             => p_attribute16
    ,p_attribute17             => p_attribute17
    ,p_attribute18             => p_attribute18
    ,p_attribute19             => p_attribute19
    ,p_attribute20             => p_attribute20
    ,p_object_version_number   => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set the warning parameter if a gap occurred
  --
  l_warning := false;
  --
  if p_org_info_type_code = 'Organization Name Alias' then
    --
    if hr_ori_bus.chk_cost_center_gap
      (p_organization_id         => p_organization_id,
       p_org_information_id      => p_org_information_id,
       p_org_information_context => p_org_info_type_code,
       p_start_date              => fnd_date.canonical_to_date(p_org_information3),
       p_end_date                => fnd_date.canonical_to_date(p_org_information4)) then
      --
      l_warning := true;
      --
    else
      --
      l_warning := false;
      --
    end if;
    --
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    --
    hr_organization_bk2.update_org_information_a
      (p_effective_date        => trunc(p_effective_date)
      ,p_org_info_type_code    => p_org_info_type_code
      ,p_org_information1      => p_org_information1
      ,p_org_information2      => p_org_information2
      ,p_org_information3      => p_org_information3
      ,p_org_information4      => p_org_information4
      ,p_org_information5      => p_org_information5
      ,p_org_information6      => p_org_information6
      ,p_org_information7      => p_org_information7
      ,p_org_information8      => p_org_information8
      ,p_org_information9      => p_org_information9
      ,p_org_information10     => p_org_information10
      ,p_org_information11     => p_org_information11
      ,p_org_information12     => p_org_information12
      ,p_org_information13     => p_org_information13
      ,p_org_information14     => p_org_information14
      ,p_org_information15     => p_org_information15
      ,p_org_information16     => p_org_information16
      ,p_org_information17     => p_org_information17
      ,p_org_information18     => p_org_information18
      ,p_org_information19     => p_org_information19
      ,p_org_information20     => p_org_information20
      ,p_org_information_id    => p_org_information_id
      ,p_attribute_category      => p_attribute_category
      ,p_attribute1              => p_attribute1
      ,p_attribute2              => p_attribute2
      ,p_attribute3              => p_attribute3
      ,p_attribute4              => p_attribute4
      ,p_attribute5              => p_attribute5
      ,p_attribute6              => p_attribute6
      ,p_attribute7              => p_attribute7
      ,p_attribute8              => p_attribute8
      ,p_attribute9              => p_attribute9
      ,p_attribute10             => p_attribute10
      ,p_attribute11             => p_attribute11
      ,p_attribute12             => p_attribute12
      ,p_attribute13             => p_attribute13
      ,p_attribute14             => p_attribute14
      ,p_attribute15             => p_attribute15
      ,p_attribute16             => p_attribute16
      ,p_attribute17             => p_attribute17
      ,p_attribute18             => p_attribute18
      ,p_attribute19             => p_attribute19
      ,p_attribute20             => p_attribute20
      ,p_object_version_number => l_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_information'
        ,p_hook_type   => 'AP');
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  p_warning               := l_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_org_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number := l_temp_ovn;
    p_warning               := l_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_org_information;
    p_object_version_number := l_temp_ovn;
    p_warning               := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
END update_org_manager;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_org_manager >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_org_manager
  (p_validate              in boolean  default false
  ,p_org_information_id    in number
  ,p_object_version_number in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_org_manager';
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_org_manager;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_org_manager
    --
    hr_organization_bk8.delete_org_manager_b
      (p_org_information_id    => p_org_information_id
      ,p_object_version_number => p_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_manager'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_org_manager
    --
  end;
  --
  hr_ori_del.del
    (p_org_information_id    => p_org_information_id
    ,p_object_version_number => l_object_version_number);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_org_manager
    --
    hr_organization_bk8.delete_org_manager_a
      (p_org_information_id    => p_org_information_id
      ,p_object_version_number => l_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_manager'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_org_manager
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_org_manager;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_temp_ovn;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_org_manager;
    p_object_version_number := l_temp_ovn;
    raise;
    --
end delete_org_manager;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_org_class_internal >----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_class_internal
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_classification_enabled         IN  VARCHAR2  DEFAULT 'Y' -- Bug 3456540
     ,p_org_information_id             OUT nocopy NUMBER
     ,p_object_version_number          OUT nocopy NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_org_class_internal';
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_object_version_number hr_organization_information.object_version_number%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_class_internal;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- added the hook for create_org_class_internal
  begin
  hr_organization_bk10.create_org_class_internal_b
  (  p_effective_date    => trunc(p_effective_date)
     ,p_organization_id  => p_organization_id
     ,p_org_classif_code => p_org_classif_code
     ,p_classification_enabled => p_classification_enabled
     ,p_org_information_id => p_org_information_id
     ,p_object_version_number  => p_object_version_number);

         exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_org_class_internal'
          ,p_hook_type   => 'BP'
          );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Check if it is proper classification first
  -- by calling Business Support process
  --
  chk_cls_mand(
    p_org_classif_code => p_org_classif_code,
    p_parent_call => 'INTERNAL',
    p_organization_id => p_organization_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_ori_ins.ins(
    p_effective_date   => p_effective_date,
    p_org_information_context => 'CLASS',
    p_organization_id   => p_organization_id,
    p_org_information1   => p_org_classif_code,
    p_org_information2  => p_classification_enabled, -- Bug 3456540
    p_org_information_id  => l_org_information_id,
    p_object_version_number => l_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
   p_org_information_id := l_org_information_id;
   p_object_version_number := l_object_version_number;
  --
      hr_utility.set_location(l_proc, 70);

   begin

     hr_organization_bk10.create_org_class_internal_a
  (  p_effective_date    => trunc(p_effective_date)
     ,p_organization_id  => p_organization_id
     ,p_org_classif_code => p_org_classif_code
     ,p_classification_enabled => p_classification_enabled
     ,p_org_information_id => l_org_information_id
     ,p_object_version_number  => l_object_version_number);

         exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_org_class_internal'
          ,p_hook_type   => 'AP'
          );
  end;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_org_class_internal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     p_org_information_id := NULL;
     p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_org_class_internal;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_org_class_internal;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_business_group >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_business_group
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_short_name                     IN  VARCHAR2
     ,p_emp_gen_method                 IN  VARCHAR2
     ,p_app_gen_method                 IN  VARCHAR2
     ,p_cwk_gen_method                 IN  VARCHAR2
     ,p_grade_flex_id                  IN  VARCHAR2
     ,p_group_flex_id                  IN  VARCHAR2
     ,p_job_flex_id                    IN  VARCHAR2
     ,p_cost_flex_id                   IN  VARCHAR2
     ,p_position_flex_id               IN  VARCHAR2
     ,p_legislation_code               IN  VARCHAR2
     ,p_currency_code                  IN  VARCHAR2
     ,p_fiscal_year_start              IN  VARCHAR2
     ,p_min_work_age                   IN  VARCHAR2
     ,p_max_work_age                   IN  VARCHAR2
     ,p_sec_group_id                   IN  VARCHAR2
     ,p_competence_flex_id             IN  VARCHAR2
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_business_group';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_date_from             DATE;
  l_ovn_bg                hr_all_organization_units.object_version_number%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_business_group;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_date_from := trunc (p_date_from);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  hr_organization_api.create_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_business_group_id => 0
      ,p_date_from => l_date_from
      ,p_name => p_name
      ,p_organization_id => l_organization_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_organization_api.update_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_organization_id => l_organization_id
      ,p_internal_external_flag => p_internal_external_flag
      ,p_type => p_type
      ,p_location_id => p_location_id
      ,p_object_version_number => l_object_version_number);
  --
  l_ovn_bg := l_object_version_number;
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_classif_code => 'HR_BG'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_info_type_code => 'Business Group Information'
      ,p_org_information1 => p_short_name
      ,p_org_information2 => p_emp_gen_method
      ,p_org_information3 => p_app_gen_method
      ,p_org_information4 => p_grade_flex_id
      ,p_org_information5 => p_group_flex_id
      ,p_org_information6 => p_job_flex_id
      ,p_org_information7 => p_cost_flex_id
      ,p_org_information8 => p_position_flex_id
      ,p_org_information9 => p_legislation_code
      ,p_org_information10 => p_currency_code
      ,p_org_information11 => p_fiscal_year_start
      ,p_org_information12 => p_min_work_age
      ,p_org_information13 => p_max_work_age
      ,p_org_information14 => p_sec_group_id
      ,p_org_information15 => p_competence_flex_id
      ,p_org_information16 => p_cwk_gen_method
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  update hr_all_organization_units
  set business_group_id = l_organization_id
  where organization_id = l_organization_id;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_organization_id := l_organization_id;
  p_object_version_number := l_ovn_bg + 1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_business_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_business_group;
    -- Set OUT parameters
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_business_group;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_operating_unit >--------------------|
-- ----------------------------------------------------------------------------
--
function get_operating_unit
(
   p_effective_date                 IN  DATE
  ,p_person_id                      IN  NUMBER DEFAULT NULL
  ,p_assignment_id                  IN  NUMBER DEFAULT NULL
  ,p_organization_id                IN  NUMBER DEFAULT NULL
 ) return number

 IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'get_operating_unit';
  l_operating_unit_id number;

  cursor ou_person is
    select nvl(org_information1,fnd_profile.value('ORG_ID'))
    from   hr_organization_information HOI
         , per_all_assignments_f PAAF
    where  HOI.organization_id = PAAF.organization_id
    and    PAAF.person_id = p_person_id
    and    p_effective_date between
           PAAF.effective_start_date and PAAF.effective_end_date
    and    PAAF.primary_flag = 'Y'
    and    HOI.org_information_context='Exp Organization Defaults';
  --
  cursor ou_assignment is
    select nvl(org_information1,fnd_profile.value('ORG_ID'))
    from   hr_organization_information HOI
         , per_all_assignments_f PAAF
    where  HOI.organization_id = PAAF.organization_id
    and    PAAF.assignment_id = p_assignment_id
    and    p_effective_date between
           PAAF.effective_start_date and PAAF.effective_end_date
    and    HOI.org_information_context='Exp Organization Defaults';
  --
  cursor ou_organization is
    select nvl(org_information1,fnd_profile.value('ORG_ID'))
    from   hr_organization_information HOI
    where  HOI.organization_id = p_organization_id
    and    HOI.org_information_context='Exp Organization Defaults';
  --

BEGIN

 hr_utility.set_location(' Entering:'||l_proc, 10);

--TO CHECK IF NONE OF THE IN PARAMETERS ARE ENTERED

 if (p_person_id is null
     and p_assignment_id is null
     and p_organization_id is null) then

    hr_utility.set_message(800,'PER_449733_MUST_ENTR_ONE_PAR');
    hr_utility.raise_error;

 end if;

 hr_utility.set_location(l_proc, 20);

--TO CHECK IF MORE THAN ONE PARAMETER HAS BEEN ENTERED

 if (p_person_id is not null
    and p_assignment_id is not null
    or p_person_id is not null
    and p_organization_id is not null
    or p_assignment_id is not null
    and p_organization_id is not null) then
    hr_utility.set_message(800,'PER_449734_ENTR_ONLY_ONE_PAR');
    hr_utility.raise_error;
 end if;

 hr_utility.set_location(l_proc, 30);

 if p_person_id is not null then

 hr_utility.set_location(l_proc, 40);

  open ou_person;
   fetch ou_person into l_operating_unit_id;
    if ou_person%notfound then

     hr_utility.set_location(l_proc, 50);

     l_operating_unit_id := nvl(fnd_profile.value('ORG_ID'),-99);

    end if;
  close ou_person;

  hr_utility.set_location(l_proc, 60);

 elsif p_assignment_id is not null then

  hr_utility.set_location(l_proc, 70);

  open ou_assignment;
   fetch ou_assignment into l_operating_unit_id;
    if ou_assignment%notfound then

     hr_utility.set_location(l_proc, 80);

     l_operating_unit_id := nvl(fnd_profile.value('ORG_ID'),-99);

    end if;
   close ou_assignment;

   hr_utility.set_location(l_proc, 90);
 else

  open ou_organization;
   fetch ou_organization into l_operating_unit_id;
    if ou_organization%notfound then

     hr_utility.set_location(l_proc, 100);

     l_operating_unit_id := nvl(fnd_profile.value('ORG_ID'),-99);

    end if;
  close ou_organization;

  hr_utility.set_location(l_proc, 110);
 end if;

    hr_utility.set_location(l_proc, 120);

 if nvl(l_operating_unit_id,-99) <> -99 then

    hr_utility.set_location(l_proc, 130);

    return l_operating_unit_id;

 else

    hr_utility.set_message(800,'PER_449732_UNABLE_TO_DERI_OU');
    hr_utility.raise_error;

 end if;

 hr_utility.set_location(' Leaving:'||l_proc, 140);

 return l_operating_unit_id;

END get_operating_unit;
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_operating_unit >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_operating_unit
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
-- Added p_legal_entity_id for bug 41281871
     ,p_legal_entity_id                IN  VARCHAR2 DEFAULT null
-- Added p_short_code for bug 4526439
     ,p_short_code                     IN  VARCHAR2 DEFAULT null
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_operating_unit';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_date_from             DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_operating_unit;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_date_from := trunc (p_date_from);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  hr_organization_api.create_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_business_group_id => p_business_group_id
      ,p_date_from => l_date_from
      ,p_name => p_name
      ,p_internal_external_flag => p_internal_external_flag
      ,p_type => p_type
      ,p_location_id => p_location_id
      ,p_organization_id => l_organization_id
      ,p_object_version_number => l_object_version_number);
  --
 -- Changed for the bug 5446483 - Start
  p_object_version_number := l_object_version_number;
  -- Changed for the bug 5446483 - end


 /* hr_organization_api.update_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_organization_id => l_organization_id
      ,p_internal_external_flag => p_internal_external_flag
      ,p_type => p_type
      ,p_location_id => p_location_id
      ,p_object_version_number => l_object_version_number);
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_classif_code => 'HR_LEGAL'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_info_type_code => 'Legal Entity Accounting'
      ,p_org_information1 => p_set_of_books_id
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);  */
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_classif_code => 'OPERATING_UNIT'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_info_type_code => 'Operating Unit Information'
     -- ,p_org_information2 => rtrim(ltrim(to_char(l_organization_id,'999999999999')))
      ,p_org_information2 => p_legal_entity_id
      ,p_org_information3 => p_set_of_books_id
      ,p_org_information5 => p_short_code
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_organization_id := l_organization_id;
  -- Changed for the bug 5446483 - Start
  --p_object_version_number := l_object_version_number;
  -- Changed for the bug 5446483 - end
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_operating_unit;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_operating_unit;
    -- Set OUT parameters
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_operating_unit;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_operating_unit >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_operating_unit
(
    p_validate                          IN  BOOLEAN  DEFAULT false
   ,p_organization_id                   IN  NUMBER
   ,p_effective_date                    IN  DATE
   ,p_language_code                     IN  VARCHAR2 DEFAULT hr_api.userenv_lang
   ,p_date_from                         IN  DATE     DEFAULT hr_api.g_date
   ,p_name                              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_type                              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_internal_external_flag            IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_location_id                       IN  NUMBER   DEFAULT hr_api.g_number
   ,p_set_of_books_id                   IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_usable_flag                       IN  VARCHAR2 DEFAULT hr_api.g_varchar2
-- Added p_short_code for bug 4526439
   ,p_short_code                        IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_legal_entity_id                   IN  VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_object_version_number		IN  OUT NOCOPY NUMBER
   ,p_update_prim_ledger_warning        OUT NOCOPY BOOLEAN
   ,p_duplicate_org_warning             OUT NOCOPY BOOLEAN
 ) IS

    --
    -- Declare cursors and local variables
    --
  l_proc			varchar2(72) := g_package||'update_operating_unit';
  l_legal_entity_id       hr_organization_information.ORG_INFORMATION2%type;
  l_set_of_books_id       hr_organization_information.ORG_INFORMATION3%type;
  l_object_version_number hr_organization_information.object_version_number%type;
  l_update_prim_ledger_warning boolean;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_new_org_information_id hr_organization_information.org_information_id%TYPE;
  l_new_ovn               hr_organization_information.object_version_number%type;
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_duplicate_org_warning boolean;


  cursor csr_check_update (p_organization_id number)
  is
  select ORG_INFORMATION_ID,ORG_INFORMATION2,ORG_INFORMATION3,OBJECT_VERSION_NUMBER
  from   hr_organization_information
  where  ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
  and    organization_id = p_organization_id;

  BEGIN
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_operating_unit;

  --
  -- Call to Update Organization
  --
  hr_organization_api.update_organization(
         p_validate => p_validate
        ,p_effective_date => p_effective_date
        ,p_name=>p_name
        ,p_language_code => p_language_code
        ,p_organization_id => p_organization_id
        ,p_internal_external_flag => p_internal_external_flag
        ,p_type => p_type
        ,p_location_id => p_location_id
        ,p_object_version_number => p_object_version_number
        ,p_duplicate_org_warning =>l_duplicate_org_warning);
  --
  -- Open Cursor
  --

  open csr_check_update(p_organization_id => p_organization_id);

    if csr_check_update%notfound then
  if(p_set_of_books_id is not null and p_legal_entity_id is not null) then
     l_update_prim_ledger_warning := TRUE;
  end if;

    hr_organization_api.create_org_information(
         p_validate           => p_validate
        ,p_effective_date     => p_effective_date
        ,p_organization_id    => p_organization_id
        ,p_org_info_type_code => 'Operating Unit Information'
        ,p_org_information2   => p_legal_entity_id
        ,p_org_information3   => p_set_of_books_id
        ,p_org_information5   => p_short_code
        ,p_org_information6   => p_usable_flag
        ,p_org_information_id => l_org_information_id
        ,p_object_version_number => l_object_version_number);
  else

  fetch csr_check_update into l_new_org_information_id,l_legal_entity_id,
  l_set_of_books_id,l_new_ovn;

  if ((l_legal_entity_id <> p_legal_entity_id) or (l_set_of_books_id <> p_set_of_books_id))
  then
  l_update_prim_ledger_warning := TRUE;
   end if;

       hr_organization_api.update_org_information(
            p_validate           => p_validate
           ,p_effective_date     => p_effective_date
           ,p_org_information_id => l_new_org_information_id
           ,p_org_info_type_code => 'Operating Unit Information'
           ,p_org_information2   => p_legal_entity_id
           ,p_org_information3   => p_set_of_books_id
           ,p_org_information5   => p_short_code
           ,p_org_information6   => p_usable_flag
           ,p_object_version_number => l_new_ovn);



  end if;

  close csr_check_update;

 hr_utility.set_location(l_proc, 20);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --

  -- Changed for the bug 5446483 - Start
  --p_object_version_number := l_object_version_number;  This is set with the out parameter of update_organization call.
  -- Changed for the bug 5446483 - end


  p_update_prim_ledger_warning := l_update_prim_ledger_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_operating_unit;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_object_version_number;
    p_update_prim_ledger_warning :=false;
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_operating_unit;
    -- Set OUT parameters
    -- Reset IN OUT parameters.
    p_object_version_number := l_object_version_number;
    p_update_prim_ledger_warning :=false;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    RAISE;
   --

END update_operating_unit;


--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_legal_entity >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_legal_entity
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_legal_entity';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_date_from             DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_utility.set_message(800, 'HR_449740_LEG_ENT_API_OBSOLETE');
  hr_utility.raise_error;
  /*
  --
  -- Issue a savepoint
  --
  savepoint create_legal_entity;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_date_from := trunc (p_date_from);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  hr_organization_api.create_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_business_group_id => p_business_group_id
      ,p_date_from => l_date_from
      ,p_name => p_name
      ,p_organization_id => l_organization_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_organization_api.update_organization(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_language_code => p_language_code
      ,p_organization_id => l_organization_id
      ,p_internal_external_flag => p_internal_external_flag
      ,p_type => p_type
      ,p_location_id => p_location_id
      ,p_object_version_number => l_object_version_number);
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_classif_code => 'HR_LEGAL'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => l_organization_id
      ,p_org_info_type_code => 'Legal Entity Accounting'
      ,p_org_information1 => p_set_of_books_id
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_organization_id := l_organization_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_legal_entity;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_legal_entity;
    -- Set OUT parameters
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
   */
END create_legal_entity;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_bgr_id >-----------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that business_group is present in PER_BUSINESS_GROUPS
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_bgr_id
--
--  Post Success:
--    If the business_group_id attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the business_group_id attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_bgr_id
  ( p_bgr_id  IN hr_all_organization_units.business_group_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_bgr_id';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check business_group_id presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM PER_BUSINESS_GROUPS
      WHERE business_group_id = p_bgr_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'N' THEN
     hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_bgr_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_bgr_classif >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_bgr_classif
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_business_group_id              IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_bgr_classif';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_bgr_classif;
  --
  -- Check if it is a Business Group
  --
  chk_bgr_id(p_business_group_id);
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_business_group_id
      ,p_org_classif_code => 'HR_LEGAL'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_business_group_id
      ,p_org_info_type_code => 'Legal Entity Accounting'
      ,p_org_information1 => p_set_of_books_id
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_business_group_id
      ,p_org_classif_code => 'OPERATING_UNIT'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_business_group_id
      ,p_org_info_type_code => 'Operating Unit Information'
      ,p_org_information2 => rtrim(ltrim(to_char(p_business_group_id,'999999999999')))
      ,p_org_information3 => p_set_of_books_id
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_bgr_classif;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_bgr_classif;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_bgr_classif;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_organization_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that organization_id of organization unit is present in
--    HR_ALL_ORGANIZATION_UNITS table and valid.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--
--  Post Success:
--    If the organization_id attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the organization_id attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_organization_id
  ( p_organization_id  IN hr_organization_information.organization_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_organization_id';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check organization_id presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_all_organization_units
      WHERE organization_id = p_organization_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'N' THEN
     hr_utility.set_message(800, 'HR_289002_INV_ORG_ID');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_organization_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_legal_entity_classif >--------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_legal_entity_classif
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_legal_entity_classif';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_legal_entity_classif;
  --
  -- Check if it is a valid Organization
  --
  chk_organization_id(p_organization_id);
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_organization_id
      ,p_org_classif_code => 'HR_LEGAL'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_organization_id
      ,p_org_info_type_code => 'Legal Entity Accounting'
      ,p_org_information1 => p_set_of_books_id
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_legal_entity_classif;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_legal_entity_classif;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_legal_entity_classif;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_oper_unit_classif >-----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_oper_unit_classif
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_legal_entity_id                IN  VARCHAR2
     ,p_set_of_books_id                IN  VARCHAR2
     ,p_oper_unit_short_code           IN  VARCHAR2 DEFAULT null  --- Fix For Bug # 7439707
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_oper_unit_classif';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_oper_unit_classif;
  --
  -- Check if it is a valid Organization
  --
  chk_organization_id(p_organization_id);
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  create_org_class_internal(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_organization_id
      ,p_org_classif_code => 'OPERATING_UNIT'
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number
      );
  --
  hr_organization_api.create_org_information(
      p_validate => p_validate
      ,p_effective_date => p_effective_date
      ,p_organization_id => p_organization_id
      ,p_org_info_type_code => 'Operating Unit Information'
      ,p_org_information2 => p_legal_entity_id
      ,p_org_information3 => p_set_of_books_id
      ,p_org_information5 => p_oper_unit_short_code   --- Fix For Bug # 7439707
      ,p_org_information_id => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_oper_unit_classif;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_oper_unit_classif;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_oper_unit_classif;
--
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< trans_org_name >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE trans_org_name
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_organization_id                IN  NUMBER
     ,p_name                           IN  VARCHAR2
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'trans_org_name';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint trans_org_name;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --
  -- Validate the language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language_code
    );
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORGANIZATION_ID'
    ,p_argument_value     => p_organization_id
    );
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'NAME'
    ,p_argument_value     => p_name
    );
  --
  chk_organization_id(
    p_organization_id => p_organization_id);
  --
  -- Process Logic
  --
  --
  hr_ort_upd.upd_tl(
    p_language_code => p_language_code,
    p_organization_id => p_organization_id,
    p_name => p_name);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO trans_org_name;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO trans_org_name;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END trans_org_name;
-- ----------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_company_cost_center >----------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_company_cost_center
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_company_valueset_id            IN  NUMBER DEFAULT null
     ,p_company                        IN  VARCHAR2 DEFAULT null
     ,p_costcenter_valueset_id         IN  NUMBER DEFAULT null
     ,p_costcenter                     IN  VARCHAR2 DEFAULT null
     ,p_ori_org_information_id         OUT NOCOPY NUMBER
     ,p_ori_object_version_number      OUT NOCOPY NUMBER
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
   ) IS

l_org_information1 varchar2(150);
l_proc                  VARCHAR2(72) := g_package||'create_company_cost_center';

BEGIN

  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_company_cost_center;
  --

  l_org_information1 := substr(p_company_valueset_id||'|'||p_company||'|'||p_costcenter_valueset_id||'|'||p_costcenter,0,150);

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin

    hr_organization_bk7.create_company_cost_center_b
        ( p_effective_date                  => p_effective_date
          ,p_organization_id                => p_organization_id
          ,p_company_valueset_id            => p_company_valueset_id
          ,p_company                        => p_company
          ,p_costcenter_valueset_id         => p_costcenter_valueset_id
          ,p_costcenter                     => p_costcenter
         );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_company_cost_center'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 30);
  --
  create_org_classification
    (  p_effective_date        => p_effective_date
       ,p_organization_id       => p_organization_id
       ,p_org_classif_code      => 'CC'
       ,p_org_information_id    => p_ori_org_information_id
       ,p_object_version_number => p_ori_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 40);
  --

  IF ( p_company_valueset_id is NOT NULL ) OR
     ( p_company is NOT NULL ) OR
     ( p_costcenter_valueset_id is NOT NULL ) OR
     ( p_costcenter is NOT NULL ) THEN

    create_org_information
      ( p_effective_date        => p_effective_date
      ,p_organization_id       => p_organization_id
      ,p_org_info_type_code    => 'Company Cost Center'
      ,p_org_information1      => l_org_information1
      ,p_org_information2      => to_char(p_company_valueset_id)
      ,p_org_information3      => p_company
      ,p_org_information4      => to_char(p_costcenter_valueset_id)
      ,p_org_information5      => p_costcenter
      ,p_org_information_id    => p_org_information_id
      ,p_object_version_number => p_object_version_number
        );

  END IF;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin

    hr_organization_bk7.create_company_cost_center_a
       ( p_effective_date                  => p_effective_date
         ,p_organization_id                => p_organization_id
         ,p_company_valueset_id            => p_company_valueset_id
         ,p_company                        => p_company
         ,p_costcenter_valueset_id         => p_costcenter_valueset_id
         ,p_costcenter                     => p_costcenter
         ,p_ori_org_information_id         => p_ori_org_information_id
         ,p_ori_object_version_number      => p_ori_object_version_number
         ,p_org_information_id             => p_org_information_id
         ,p_object_version_number          => p_object_version_number
       );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_company_cost_center'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_company_cost_center;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- Set OUT parameters.
    p_ori_org_information_id      := null;
    p_ori_object_version_number   := null;
    p_org_information_id          := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_company_cost_center;
    -- Set OUT parameters.
    p_ori_org_information_id      := null;
    p_ori_object_version_number   := null;
    p_org_information_id          := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_company_cost_center;
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
              p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_not_usable_ou_internal >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_not_usable_ou_internal
          (p_validate               IN        BOOLEAN  DEFAULT FALSE
          ,p_effective_date         IN        DATE
          ,p_language_code          IN        VARCHAR2 DEFAULT HR_API.userenv_lang
          ,p_business_group_id      IN        NUMBER
          ,p_date_from              IN        DATE
          ,p_name                   IN        VARCHAR2
          ,p_type                   IN        VARCHAR2
          ,p_internal_external_flag IN        VARCHAR2
          ,p_location_id            IN        NUMBER
          ,p_ledger_id              IN        VARCHAR2 DEFAULT NULL
          ,p_default_legal_context  IN        VARCHAR2 DEFAULT NULL
          ,p_short_code             IN        VARCHAR2 DEFAULT NULL
          ,p_organization_id       OUT NOCOPY NUMBER
          ,p_object_version_number OUT NOCOPY NUMBER ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_not_usable_ou_internal';
  l_organization_id       hr_all_organization_units.organization_id%TYPE;
  l_object_version_number hr_all_organization_units.object_version_number%TYPE;
  l_language_code         hr_all_organization_units_tl.language%TYPE;
  l_org_information_id    hr_organization_information.org_information_id%TYPE;
  l_date_from             DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_not_usable_ou_internal;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- All date input parameters must be truncated to remove time elements
  --
  l_date_from := trunc (p_date_from);
  --
  -- Validate language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on to allow IN OUT param to be passed.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  hr_organization_api.create_organization(
      p_validate                => p_validate
      ,p_effective_date         => p_effective_date
      ,p_language_code          => p_language_code
      ,p_business_group_id      => p_business_group_id
      ,p_date_from              => l_date_from
      ,p_name                   => p_name
      ,p_internal_external_flag => p_internal_external_flag
      ,p_type                   => p_type
      ,p_location_id            => p_location_id
      ,p_organization_id        => l_organization_id
      ,p_object_version_number  => l_object_version_number);
  --
  create_org_class_internal(
      p_validate               => p_validate
      ,p_effective_date        => p_effective_date
      ,p_organization_id       => l_organization_id
      ,p_org_classif_code      => 'OPERATING_UNIT'
      ,p_org_information_id    => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_organization_api.create_org_information(
      p_validate               => p_validate
      ,p_effective_date        => p_effective_date
      ,p_organization_id       => l_organization_id
      ,p_org_info_type_code    => 'Operating Unit Information'
      ,p_org_information2      => p_default_legal_context --p_legal_entity_id
      ,p_org_information3      => p_ledger_id             --p_set_of_books_id
      ,p_org_information5      => p_short_code
      ,p_org_information6      => 'N'                     --Usable N=Not Usable
      ,p_org_information_id    => l_org_information_id
      ,p_object_version_number => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_organization_id := l_organization_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_not_usable_ou_internal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_not_usable_ou_internal;
    -- Set OUT parameters
    p_organization_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_not_usable_ou_internal;
--------------------------------------------------------------------------------
--
END hr_organization_api;

/
