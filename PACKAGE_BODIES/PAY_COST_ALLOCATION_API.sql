--------------------------------------------------------
--  DDL for Package Body PAY_COST_ALLOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COST_ALLOCATION_API" as
/* $Header: pycalapi.pkb 120.5 2006/07/31 09:29:46 susivasu noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_COST_ALLOCATION_API.';
-- bug no 3829293. Local variable to hold segment value
type segment_value is varray(30) of varchar2(150);
l_segment_value  segment_value ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cak_concat_segs >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   When required this procedure updates the pay_cost_allocation_keyflex table
--   after the flexfield segments have been inserted to keep the concatenated
--   segment string up-to-date.
--
-- Prerequisites:
--   A row must exist in the pay_cost_allocation_keyflex table for the
--   given cost_allocation_keyflex_id.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cost_allocation_keyflex_id   Yes  number   The primary key
--   p_concatenated_segments        Yes  varchar2 The concatenated segments
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
procedure update_cak_concat_segs
  (p_cost_allocation_keyflex_id   in     number
  ,p_concatenated_segments        in     varchar2
  ) is
  --
  CURSOR csr_chk_cak is
    SELECT null
      FROM pay_cost_allocation_keyflex
     where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
       and (concatenated_segments <> p_concatenated_segments
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_cak_concat_segs';
  --
  procedure update_cak_concat_segs_auto
    (p_cost_allocation_keyflex_id   in     number
    ,p_concatenated_segments        in     varchar2
    ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_cak_lock is
      SELECT null
        FROM pay_cost_allocation_keyflex
       where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
         for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_cak_concat_segs_auto';
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
    open csr_cak_lock;
    fetch csr_cak_lock into l_exists;
    if csr_cak_lock%found then
      close csr_cak_lock;
      hr_utility.set_location(l_proc, 20);
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
      update pay_cost_allocation_keyflex
         set concatenated_segments = p_concatenated_segments
       where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
         and (concatenated_segments <> p_concatenated_segments
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
      close csr_cak_lock;
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
  end update_cak_concat_segs_auto;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first inserted.
  --
  open csr_chk_cak;
  fetch csr_chk_cak into l_exists;
  if csr_chk_cak%found then
    close csr_chk_cak;
    update_cak_concat_segs_auto
      (p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id
      ,p_concatenated_segments      => p_concatenated_segments
      );
  else
    close csr_chk_cak;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 40);
  --
end update_cak_concat_segs;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_mandatory_segments >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will check any segment which is not required for
--   particular level and have been assigned any value. Procedure will
--   error out in case any extra segment have been assigned value.
--   This procedure will also check the segments which are mandatory and qualified
--   for particular level.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_level                        Yes  varchar2 The Qualifier level.
--   p_cost_id_flex_num             Yes  varchar2 The concatenated flex number.
--   p_segment                      No   segment_value.
--
-- Post Success:
--   If none of required segments are not null then row is inserted or updated
--   successfully.
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
Procedure check_mandatory_segments(
          p_level               IN  VARCHAR2,
          p_cost_id_flex_num    IN  NUMBER,
          p_segment             IN  segment_value,
          p_cost_allocation_keyflex_id IN NUMBER
  ) is
   l_proc  VARCHAR2(72) := g_package||'check_mandatory_segments';
   --

  type segment_no_array          is table
                     of number(2) INDEX BY Binary_integer;
  type application_column_array  is table
                     of fnd_id_flex_segments.application_column_name%type INDEX BY Binary_integer;
  type application_segment_array is table
                     of fnd_id_flex_segments.segment_name%type INDEX BY Binary_integer;
  type required_flag_array       is table
                     of fnd_id_flex_segments.required_flag%type INDEX BY Binary_integer;

  l_segment_no          segment_no_array;
  l_application_column  application_column_array;
  l_application_segment application_segment_array;
  l_required_flag       required_flag_array;
  l_value_passed        varchar2(1);


  cursor csr_segment is
     SELECT substr(fs.application_column_name,8,2) segment_no,
            fs.application_column_name application_column_name,
  	    fs.segment_name application_segment_name,
	    fs.required_flag required_flag
    FROM    FND_ID_FLEX_SEGMENTS         fs,
            FND_SEGMENT_ATTRIBUTE_VALUES sa1
    WHERE   sa1.id_flex_num = p_cost_id_flex_num
    and     sa1.id_flex_code = 'COST'
    and     sa1.attribute_value = 'Y'
    and     sa1.segment_attribute_type <> 'BALANCING'
    and     sa1.segment_attribute_type = p_level
    and     fs.id_flex_num = p_cost_id_flex_num
    and     fs.id_flex_code = 'COST'
    and     fs.enabled_flag  = 'Y'
    and     fs.application_id = 801
    and     fs.application_column_name =
                                       sa1.application_column_name
    order by substr(fs.application_column_name,8,2);



    -- local variable to hold segments needed for the particular level
    -- initialy mark all segment as not required
    l_required_segment Segment_value
                 := segment_value('N','N','N','N','N','N','N','N','N','N',
		 		  'N','N','N','N','N','N','N','N','N','N',
				  'N','N','N','N','N','N','N','N','N','N'
				 );
    --
    v_cal_cost_segs varchar2(3);
    --

Begin

   l_value_passed := 'N';
   for i in 1..30 loop
       if p_segment(i) is not null then
 	   --
 	   l_value_passed := 'Y';
 	   --
       end if;
   end loop;
   --
   if (l_value_passed = 'N'
       and (p_cost_allocation_keyflex_id is null
            or p_cost_allocation_keyflex_id = -1)) then
          fnd_message.set_name('PER','HR_51342_COST_COST_CODE_REQ');
          hr_utility.raise_error;
   end if;
   --

   OPEN csr_segment;
   FETCH csr_segment BULK COLLECT INTO l_Segment_no,l_application_column,
                                    l_application_segment,l_required_flag;
   close csr_segment;

   --
   -- Perform Flexfield Validation: if COST_VAL_SEGS pay_action_parameter = 'Y'
   --
   begin
     select parameter_value
       into v_cal_cost_segs
       from pay_action_parameters
      where parameter_name = 'COST_VAL_SEGS';
   exception
     when others then
       v_cal_cost_segs := 'N';
   end;
   --

   -- Only carry out the mandatory check if the COST_VAL_SEGS is set as 'Y'.
   if ( l_segment_no.COUNT <> 0 and v_cal_cost_segs = 'Y') then

   FOR i IN l_segment_no.FIRST..l_segment_no.LAST
   LOOP
      -- mark those segment which is needed for flexfield
      --
      l_required_segment(l_segment_no(i)) := 'Y';
      --
      -- Check for mandatoy segment
      --
      If (l_required_flag(i) = 'Y' and p_segment(l_segment_no(i)) is null) then
          fnd_message.set_name('PER','HR_FLEX_VALUE_MISSING');
          fnd_message.set_token('COLUMN',l_application_column(i));
          fnd_message.set_token('PROMPT',l_application_segment(i));
          hr_utility.raise_error;
      end if;
   END LOOP;

   end if;

  -- -- check whether any segment is not required for flexfield and value has been
  -- -- assigned for the same.
  -- for i in 1..30 loop
  --     if l_required_segment(i) = 'N' then
  --       if (p_segment(i) is not null or p_segment(i) = hr_api.g_varchar2) then
  --     --
  --     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  --     hr_utility.set_message_token('PROCEDURE', l_proc);
  --     hr_utility.set_message_token('STEP','20');
  --     hr_utility.raise_error;
  --     --
  --     	end if;
  --     end if;
  -- end loop;

end check_mandatory_segments;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_COST_ALLOCATION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_proportion                    in     number
  ,p_business_group_id             in     number
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_combination_name                 out nocopy varchar2
  ,p_cost_allocation_id               out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_cost_allocation_keyflex_id    in out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'CREATE_COST_ALLOCATION';
  l_effective_date              date;
  l_flex_num                    fnd_id_flex_segments.id_flex_num%TYPE;
  -- bug no. 3829293.
  -- l_cost_allocation_keyflex_id  number(15);
  l_cost_allocation_keyflex_id  number(15):= -1;
  --
  --  Initialize segment varray from passed parameter values
  l_new_segment  segment_value
               :=segment_value(p_segment1  ,p_segment2 ,p_segment3  ,p_segment4  ,p_segment5,
                               p_segment6  ,p_segment7 ,p_segment8  ,p_segment9  ,p_segment10,
			       p_segment11 ,p_segment12,p_segment13 ,p_segment14 ,p_segment15,
			       p_segment16 ,p_segment17,p_segment18 ,p_segment19 ,p_segment20,
			       p_segment21 ,p_segment22,p_segment23 ,p_segment24 ,p_segment25,
			       p_segment26 ,p_segment27,p_segment28 ,p_segment29 ,p_segment30
			       );
  --
  l_combination_name            varchar2(240);
  l_cost_allocation_id          pay_cost_allocations_f.cost_allocation_id%TYPE;
  l_object_version_number       pay_cost_allocations_f.object_version_number%TYPE;
  l_effective_start_date        pay_cost_allocations_f.effective_start_date%TYPE;
  l_effective_end_date          pay_cost_allocations_f.effective_end_date%TYPE;
  l_concat_segs                 pay_cost_allocation_keyflex.concatenated_segments%TYPE;
  --
  cursor csr_cost_structure is
    select pbg.cost_allocation_structure
    from   per_business_groups pbg
    where  pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_COST_ALLOCATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK1.create_cost_allocation_b
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_proportion                    => p_proportion
      ,p_business_group_id             => p_business_group_id
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
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_COST_ALLOCATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Need to set CLIENT_INFO as HR_LOOKUPS may be referenced
  -- by SEGMENT Value Sets.
  --
  hr_api.validate_bus_grp_id(p_business_group_id);
  --
  open csr_cost_structure;
  fetch csr_cost_structure into l_flex_num;
  if csr_cost_structure%notfound then
    close csr_cost_structure;
    --
    -- the flex structure has not been found
    --
    fnd_message.set_name('PAY', 'HR_7471_FLEX_PEA_INVALID_ID');
    fnd_message.raise_error;
  end if;
  close csr_cost_structure;
  --
  -- bug no. 3829293. Use hr_entry.maintain_cost_flexfield instead of
  -- below procedure
 /*
  --
  -- Determine the cost allocation definition by calling ins_or_sel
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
    ,p_ccid                  => l_cost_allocation_keyflex_id
    ,p_concat_segments_out   => l_combination_name
    );
  --
  -- Set CONCATENATED_SEGMENTS column in pay_cost_allocation_keyflex
  -- bug 2620309
  --
  -- The update of the concatenated_segments column is executed
  -- in a separate procedure. (Bug #3177656)
  --
  update_cak_concat_segs
    (p_cost_allocation_keyflex_id   => l_cost_allocation_keyflex_id
    ,p_concatenated_segments        => l_combination_name
    );

*/
  -- check mandatory segment
  --
  check_mandatory_segments(
            p_level			 =>'ASSIGNMENT',
            p_cost_id_flex_num		 =>l_flex_num,
            p_segment                    =>l_new_segment,
            p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id
	    );

  -- insert flexfield segment
  --
  l_cost_allocation_keyflex_id :=
	  hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_flex_num,
            p_cost_allocation_keyflex_id => nvl(p_cost_allocation_keyflex_id,l_cost_allocation_keyflex_id),
            p_concatenated_segments      => p_concat_segments,
            p_summary_flag               =>'N',
            p_start_date_active          => NULL,
            p_end_date_active            => NULL,
            p_segment1                   =>p_segment1,
            p_segment2                   =>p_segment2,
            p_segment3                   =>p_segment3,
            p_segment4                   =>p_segment4,
            p_segment5                   =>p_segment5,
            p_segment6                   =>p_segment6,
            p_segment7                   =>p_segment7,
            p_segment8                   =>p_segment8,
            p_segment9                   =>p_segment9,
            p_segment10                  =>p_segment10,
            p_segment11                  =>p_segment11,
            p_segment12                  =>p_segment12,
            p_segment13                  =>p_segment13,
            p_segment14                  =>p_segment14,
            p_segment15                  =>p_segment15,
            p_segment16                  =>p_segment16,
            p_segment17                  =>p_segment17,
            p_segment18                  =>p_segment18,
            p_segment19                  =>p_segment19,
            p_segment20                  =>p_segment20,
            p_segment21                  =>p_segment21,
            p_segment22                  =>p_segment22,
            p_segment23                  =>p_segment23,
            p_segment24                  =>p_segment24,
            p_segment25                  =>p_segment25,
            p_segment26                  =>p_segment26,
            p_segment27                  =>p_segment27,
            p_segment28                  =>p_segment28,
            p_segment29                  =>p_segment29,
            p_segment30                  =>p_segment30);

-- end of bug no. 3829293.
  --
  -- Process Logic
  --
  pay_cal_ins.ins
      (p_effective_date                => l_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
      ,p_assignment_id                 => p_assignment_id
      ,p_proportion                    => p_proportion
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_cost_allocation_id            => l_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK1.create_cost_allocation_a
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_proportion                    => p_proportion
      ,p_business_group_id             => p_business_group_id
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
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_combination_name              => l_combination_name
      ,p_cost_allocation_id            => l_cost_allocation_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_COST_ALLOCATION'
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
  p_combination_name              := l_combination_name;
  p_cost_allocation_id            := l_cost_allocation_id;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  p_cost_allocation_keyflex_id    := l_cost_allocation_keyflex_id;
  p_object_version_number         := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_COST_ALLOCATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_combination_name              := null;
    p_cost_allocation_id            := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_cost_allocation_keyflex_id    := null;
    p_object_version_number         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_COST_ALLOCATION;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_combination_name              := null;
    p_cost_allocation_id            := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_cost_allocation_keyflex_id    := null;
    p_object_version_number         := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_COST_ALLOCATION;
--
-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_COST_ALLOCATION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_proportion                    in     number   default hr_api.g_number
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_combination_name                 out nocopy varchar2
  ,p_cost_allocation_keyflex_id    in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- bug no 3829293.Initialize segment varray to passed parameter value
  --
  l_new_segment  segment_value
                  :=segment_value(p_segment1  ,p_segment2 ,p_segment3  ,p_segment4  ,p_segment5,
                                  p_segment6  ,p_segment7 ,p_segment8  ,p_segment9  ,p_segment10,
		  	          p_segment11 ,p_segment12,p_segment13 ,p_segment14 ,p_segment15,
			          p_segment16 ,p_segment17,p_segment18 ,p_segment19 ,p_segment20,
				  p_segment21 ,p_segment22,p_segment23 ,p_segment24 ,p_segment25,
				  p_segment26 ,p_segment27,p_segment28 ,p_segment29 ,p_segment30
				  );
  l_previous_segment segment_value
                  :=segment_value(null ,null ,null ,null ,null, null ,null ,null ,null ,null,
		  	          null ,null ,null ,null ,null, null ,null ,null ,null ,null,
				  null ,null ,null ,null ,null, null ,null ,null ,null ,null
				  );
  l_concat_segments  varchar2(700);
  l_validate_flex    boolean := FALSE;
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'UPDATE_COST_ALLOCATION';
  l_effective_date              date;
  l_flex_num                    fnd_id_flex_segments.id_flex_num%TYPE;
  l_cost_allocation_keyflex_id  number;
  l_combination_name            varchar2(240);
  l_object_version_number       pay_cost_allocations_f.object_version_number%TYPE;
  l_effective_start_date        pay_cost_allocations_f.effective_start_date%TYPE;
  l_effective_end_date          pay_cost_allocations_f.effective_end_date%TYPE;
  l_business_group_id           pay_cost_allocations_f.business_group_id%TYPE;
  l_concat_segs                 pay_cost_allocation_keyflex.concatenated_segments%TYPE;
  --
  cursor csr_cost_structure(p_bg_id number) is
    select pbg.cost_allocation_structure
    from   per_business_groups pbg
    where  pbg.business_group_id = p_bg_id;
  --
  cursor csr_old_ccid is
    select pca.cost_allocation_keyflex_id
    ,      pca.business_group_id
    from   pay_cost_allocations_f pca
    where  pca.cost_allocation_id = p_cost_Allocation_id
    and    p_effective_date between pca.effective_start_date
                            and     pca.effective_end_date;
 --
 --cursor to hold old segment values from database
   cursor csr_old_values is
    select pca.segment1,
           pca.segment2,
           pca.segment3,
           pca.segment4,
           pca.segment5,
           pca.segment6,
           pca.segment7,
           pca.segment8,
           pca.segment9,
           pca.segment10,
           pca.segment11,
           pca.segment12,
           pca.segment13,
           pca.segment14,
           pca.segment15,
           pca.segment16,
           pca.segment17,
           pca.segment18,
           pca.segment19,
           pca.segment20,
           pca.segment21,
           pca.segment22,
           pca.segment23,
           pca.segment24,
           pca.segment25,
           pca.segment26,
           pca.segment27,
           pca.segment28,
           pca.segment29,
	   pca.segment30
      from pay_cost_allocation_keyflex pca,
           pay_cost_allocations_f pac
     where pac.cost_allocation_id = p_cost_Allocation_id
       and p_effective_date between pac.effective_start_date
                            and     pac.effective_end_date
       and pac.cost_allocation_keyflex_id = pca.cost_allocation_keyflex_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_COST_ALLOCATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Initialise all IN/OUT parameters
  --
  l_object_version_number      := p_object_version_number;
  --
   --
  -- previous value of segment from database
  --
  if p_cost_allocation_id is not null then
     open csr_old_values;
     fetch csr_old_values into l_previous_segment(1) ,l_previous_segment(2),
                               l_previous_segment(3) ,l_previous_segment(4),
                               l_previous_segment(5) ,l_previous_segment(6),
                               l_previous_segment(7) ,l_previous_segment(8),
                               l_previous_segment(9) ,l_previous_segment(10),
                               l_previous_segment(11),l_previous_segment(12),
			       l_previous_segment(13),l_previous_segment(14),
			       l_previous_segment(15),l_previous_segment(16),
			       l_previous_segment(17),l_previous_segment(18),
			       l_previous_segment(19),l_previous_segment(20),
			       l_previous_segment(21),l_previous_segment(22),
			       l_previous_segment(23),l_previous_segment(24),
			       l_previous_segment(25),l_previous_segment(26),
			       l_previous_segment(27),l_previous_segment(28),
			       l_previous_segment(29),l_previous_segment(30);

     close csr_old_values;
  end if;
  --
  -- Make null  to all segment default value
  --
   for i in 1..30 loop
       if (l_new_segment(i) = hr_api.g_varchar2) then
           -- if default value then retain previous value from database
           l_new_segment(i) := nvl(l_previous_segment(i),null);
       else
           -- call the flex code if and only if any one of the segment or the
	   -- concatenated segment is not hr_api.g_varchar2.
	   --
           l_validate_flex := TRUE;
       end if;
   end loop;
   --
   -- Call Before Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK2.update_cost_allocation_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_proportion                    => p_proportion
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
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COST_ALLOCATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Need to return existing ccid and business_group_id for
  -- the row being updated.
  --
  open csr_old_ccid;
  fetch csr_old_ccid into l_cost_allocation_keyflex_id, l_business_group_id;
  if csr_old_ccid%notfound then
    close csr_old_ccid;
    --
    -- The primary key is invalid
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close csr_old_ccid;
  --
  -- Need to set CLIENT_INFO as HR_LOOKUPS may be referenced
  -- by SEGMENT Value Sets.
  --
  hr_api.validate_bus_grp_id(l_business_group_id);
  --
  open csr_cost_structure(l_business_group_id);
  fetch csr_cost_structure into l_flex_num;
  if csr_cost_structure%notfound then
    close csr_cost_structure;
    --
    -- the flex structure has not been found
    --
    fnd_message.set_name('PAY', 'HR_7471_FLEX_PEA_INVALID_ID');
    fnd_message.raise_error;
  end if;
  close csr_cost_structure;
  --
/*  bug no. 3829293. call hr_entry.maintain_cost_flexfield
  -- instead of above procedure
  --
  -- Determine the cost allocation definition by calling upd_or_sel
  --
  hr_kflex_utility.upd_or_sel_keyflex_comb
    (p_appl_short_name       => 'PAY'
    ,p_flex_code             => 'COST'
    ,p_flex_num              => l_flex_num
    ,p_ccid                  => l_cost_allocation_keyflex_id
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
    ,p_concat_segments_out   => l_combination_name
    );
  --
  -- Set CONCATENATED_SEGMENTS column in pay_cost_allocation_keyflex
  -- bug 2620309
  --
  -- The update of the concatenated_segments column is executed
  -- in a separate procedure. (Bug #3177656)
  --
  update_cak_concat_segs
    (p_cost_allocation_keyflex_id   => l_cost_allocation_keyflex_id
    ,p_concatenated_segments        => l_combination_name
    );
*/
      --  Validate the key flex field only if any one of the segment or the
   --  concatenated segment is not hr_api.g_varchar2.

   if (l_validate_flex or (p_concat_segments <> hr_api.g_varchar2)) then

     -- check mandatory segment
      check_mandatory_segments(
            p_level                      =>'ASSIGNMENT',
            p_cost_id_flex_num           =>l_flex_num,
            p_segment                    =>l_new_segment,
            p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id);

     -- if concatenated segment has default value then assign it null
     --
     if p_concat_segments = hr_api.g_varchar2 then
        l_concat_segments := null;
     else
        l_concat_segments := p_concat_segments;
     end if;
   --

    l_cost_allocation_keyflex_id := -1;
 hr_utility.set_location('Entering Update API', 10);
 hr_utility.set_location('p_cost_allocation_keyflex_id:'|| p_cost_allocation_keyflex_id, 10);
 hr_utility.set_location('l_cost_allocation_keyflex_id:'|| l_cost_allocation_keyflex_id, 10);
 hr_utility.set_location('l_flex_num:'|| l_flex_num, 10);
 hr_utility.set_location('l_concat_segments:'|| l_concat_segments, 10);


    l_cost_allocation_keyflex_id :=
	  hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_flex_num,
            p_cost_allocation_keyflex_id => nvl(p_cost_allocation_keyflex_id,l_cost_allocation_keyflex_id),
            p_concatenated_segments      => l_concat_segments,
            p_summary_flag               =>'N',
            p_start_date_active          => NULL,
            p_end_date_active            => NULL,
            p_segment1                   =>l_new_segment(1),
            p_segment2                   =>l_new_segment(2),
            p_segment3                   =>l_new_segment(3),
            p_segment4                   =>l_new_segment(4),
            p_segment5                   =>l_new_segment(5),
            p_segment6                   =>l_new_segment(6),
            p_segment7                   =>l_new_segment(7),
            p_segment8                   =>l_new_segment(8),
            p_segment9                   =>l_new_segment(9),
            p_segment10                  =>l_new_segment(10),
            p_segment11                  =>l_new_segment(11),
            p_segment12                  =>l_new_segment(12),
            p_segment13                  =>l_new_segment(13),
            p_segment14                  =>l_new_segment(14),
            p_segment15                  =>l_new_segment(15),
            p_segment16                  =>l_new_segment(16),
            p_segment17                  =>l_new_segment(17),
            p_segment18                  =>l_new_segment(18),
            p_segment19                  =>l_new_segment(19),
            p_segment20                  =>l_new_segment(20),
            p_segment21                  =>l_new_segment(21),
            p_segment22                  =>l_new_segment(22),
            p_segment23                  =>l_new_segment(23),
            p_segment24                  =>l_new_segment(24),
            p_segment25                  =>l_new_segment(25),
            p_segment26                  =>l_new_segment(26),
            p_segment27                  =>l_new_segment(27),
            p_segment28                  =>l_new_segment(28),
            p_segment29                  =>l_new_segment(29),
            p_segment30                  =>l_new_segment(30));
  end if;
  --
  -- end of bug no. 3829293
  --
  --
   hr_utility.set_location('Entering Update API', 20);
   hr_utility.set_location('l_cost_allocation_keyflex_id:'|| l_cost_allocation_keyflex_id, 20);
  -- Process Logic
  --
  pay_cal_upd.upd
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_update_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
      ,p_proportion                    => p_proportion
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK2.update_cost_allocation_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_proportion                    => p_proportion
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
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_combination_name              => l_combination_name
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COST_ALLOCATION'
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
  p_combination_name              := l_combination_name;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  p_cost_allocation_keyflex_id    := l_cost_allocation_keyflex_id;
  p_object_version_number         := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_COST_ALLOCATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_combination_name              := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_cost_allocation_keyflex_id    := null;
    p_object_version_number         := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_COST_ALLOCATION;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_combination_name              := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_cost_allocation_keyflex_id    := null;
    p_object_version_number         := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_COST_ALLOCATION;
--
-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_COST_ALLOCATION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'DELETE_COST_ALLOCATION';
  l_effective_date              date;
  l_object_version_number       pay_cost_allocations_f.object_version_number%TYPE;
  l_effective_start_date        pay_cost_allocations_f.effective_start_date%TYPE;
  l_effective_end_date          pay_cost_allocations_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_COST_ALLOCATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Initialise all IN/OUT parameters
  --
  l_object_version_number      := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK3.delete_cost_allocation_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COST_ALLOCATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_cal_del.del
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_delete_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_COST_ALLOCATION_BK3.delete_cost_allocation_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_cost_allocation_id            => p_cost_allocation_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COST_ALLOCATION'
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
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  p_object_version_number         := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_COST_ALLOCATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_object_version_number         := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_COST_ALLOCATION;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_effective_start_date          := null;
    p_effective_end_date            := null;
    p_object_version_number         := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_COST_ALLOCATION;
--
end PAY_COST_ALLOCATION_API;

/
