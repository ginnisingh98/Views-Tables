--------------------------------------------------------
--  DDL for Package Body HR_PARTICIPANTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PARTICIPANTS_API" as
/* $Header: peparapi.pkb 120.1 2007/06/20 07:48:12 rapandi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_participants_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_participant> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_participant
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_questionnaire_template_id    in     number default null,
  p_participation_in_table       in 	varchar2,
  p_participation_in_column      in 	varchar2,
  p_participation_in_id          in 	number,
  p_participation_status         in     varchar2         default 'OPEN',
  p_participation_type           in     varchar2         default null,
  p_last_notified_date           in     date             default null,
  p_date_completed               in 	date             default null,
  p_comments                     in 	varchar2         default null,
  p_person_id                    in 	number,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_participant_usage_status	   in 	varchar2		 default null,
  p_participant_id               out nocopy    number,
  p_object_version_number        out nocopy 	number
 )
 is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'create_participant';
  l_participant_id		per_participants.participant_id%TYPE;
  l_object_version_number	per_participants.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_participant;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_participants_bk1.create_participant_b	(
         p_effective_date               =>     p_effective_date,
         p_questionnaire_template_id    =>     p_questionnaire_template_id,
         p_business_group_id	        =>     p_business_group_id,
         p_participation_in_table       =>     p_participation_in_table,
         p_participation_in_column      =>     p_participation_in_column,
         p_participation_in_id          =>     p_participation_in_id,
         p_participation_status         =>     p_participation_status,
         p_participation_type           =>     p_participation_type,
         p_last_notified_date           =>     p_last_notified_date,
         p_date_completed               =>     p_date_completed,
         p_comments                     =>     p_comments,
         p_person_id                    =>     p_person_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_participant_usage_status		=>	   p_participant_usage_status
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_participant',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_par_ins.ins
 (p_validate                    =>	p_validate,
  p_effective_date              =>	p_effective_date,
  p_questionnaire_template_id   =>      p_questionnaire_template_id,
  p_business_group_id		=>	p_business_group_id,
  p_participation_in_table      =>	p_participation_in_table,
  p_participation_in_column     =>	p_participation_in_column,
  p_participation_in_id         =>	p_participation_in_id,
  p_participation_status        =>      p_participation_status,
  p_participation_type          =>      p_participation_type,
  p_last_notified_date          =>      p_last_notified_date,
  p_date_completed              =>	p_date_completed,
  p_comments                    =>	p_comments,
  p_person_id                    =>	p_person_id,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_participant_usage_status	   =>		p_participant_usage_status,
  p_participant_id                 =>	l_participant_id,
  p_object_version_number        =>	l_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_participants_bk1.create_participant_a	(
         p_participant_id               =>     l_participant_id,
         p_object_version_number        =>     l_object_version_number,
         p_questionnaire_template_id    =>     p_questionnaire_template_id,
         p_effective_date               =>     p_effective_date,
         p_business_group_id	          =>     p_business_group_id,
         p_participation_in_table       =>     p_participation_in_table,
         p_participation_in_column      =>     p_participation_in_column,
         p_participation_in_id          =>     p_participation_in_id,
         p_participation_status         =>     p_participation_status,
         p_participation_type           =>     p_participation_type,
         p_last_notified_date           =>     p_last_notified_date,
         p_date_completed               =>     p_date_completed,
         p_comments                     =>     p_comments,
         p_person_id                    =>     p_person_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_participant_usage_status	  	=>	   p_participant_usage_status
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_participant',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_participant_id         := l_participant_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_participant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_participant_id         := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_participant;
    --
    -- set in out parameters and set out parameters
    --
    p_participant_id         := null;
    p_object_version_number  := null;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_participant;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_participant> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_participant
 (p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_participant_id               in number,
  p_object_version_number        in out nocopy number,
  p_questionnaire_template_id    in number           default hr_api.g_number,
  p_participation_status         in varchar2         default hr_api.g_varchar2,
  p_participation_type           in varchar2         default hr_api.g_varchar2,
  p_last_notified_date           in date             default hr_api.g_date,
  p_date_completed               in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_participant_usage_status	   in varchar2		     default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                	varchar2(72) := g_package||'update_participant';
  l_object_version_number	per_participants.object_version_number%TYPE;
  l_ovn per_participants.object_version_number%TYPE := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_participant;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_participants_bk2.update_participant_b	(
         p_participant_id               =>     p_participant_id,
         p_object_version_number        =>     p_object_version_number,
         p_questionnaire_template_id    =>     p_questionnaire_template_id,
         p_effective_date               =>     p_effective_date,
         p_participation_status         =>     p_participation_status,
         p_participation_type           =>     p_participation_type,
         p_last_notified_date           =>     p_last_notified_date,
         p_date_completed               =>     p_date_completed,
         p_comments                     =>     p_comments,
         p_person_id                    =>     p_person_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_participant_usage_status		  =>	   p_participant_usage_status
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_participant',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_par_upd.upd
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_participant_id               =>     p_participant_id,
  p_object_version_number        =>     l_object_version_number,
  p_questionnaire_template_id    =>     p_questionnaire_template_id,
  p_participation_status         =>     p_participation_status,
  p_participation_type           =>     p_participation_type,
  p_last_notified_date           =>     p_last_notified_date,
  p_date_completed               =>     p_date_completed,
  p_comments                     =>     p_comments,
  -- p_person_id                 =>     p_person_id, -- bug 4046867
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_participant_usage_status	   =>	  	p_participant_usage_status
  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_participants_bk2.update_participant_a	(
         p_participant_id               =>     p_participant_id,
         p_object_version_number        =>     l_object_version_number,
         p_questionnaire_template_id    =>     p_questionnaire_template_id,
         p_effective_date               =>     p_effective_date,
         p_participation_status         =>     p_participation_status,
         p_participation_type           =>     p_participation_type,
         p_last_notified_date           =>     p_last_notified_date,
         p_date_completed               =>     p_date_completed,
         p_comments                     =>     p_comments,
         p_person_id                    =>     p_person_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_participant_usage_status		  =>	   p_participant_usage_status
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_participant',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_participant;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO update_participant;
    --
    -- set in out parameters and set out parameters
    --
       p_object_version_number  := l_ovn;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_participant;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_participant> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_participant
(p_validate                           in boolean default false,
 p_participant_id                     in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  --
  --
  l_proc                varchar2(72) := g_package||'delete_participant';

  cursor c_quest_ans_id
    is
    select questionnaire_answer_id
    from hr_quest_answers
    where hr_quest_answers.type = 'PARTICIPANT' and
    hr_quest_answers.type_object_id = p_participant_id;
  -- Update in lines of Bug No.1386826 . Now from Appraisals V5, participant can have a Qnr.
  l_quest_ans_id       hr_quest_answers.questionnaire_answer_id%type;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_participant;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_participants_bk3.delete_participant_b
		(
		p_participant_id         =>   p_participant_id,
		p_object_version_number  =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_participant',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);

  open c_quest_ans_id;
    fetch c_quest_ans_id into l_quest_ans_id;
    if c_quest_ans_id%found then
    -- deleting answers and answer values.
    hr_quest_perform_web.delete_quest_answer(p_questionnaire_answer_id => l_quest_ans_id);
    end if;
  close c_quest_ans_id;


  --
  -- Process Logic
  --
  --
  -- now delete the participant itself
  --
     per_par_del.del
     (p_validate                    => FALSE
     ,p_participant_id			=> p_participant_id
     ,p_object_version_number 	=> p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_participants_bk3.delete_participant_a	(
		p_participant_id         =>    p_participant_id,
		p_object_version_number  =>    p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_participant',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_participant;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_participant;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_participant;
--
end hr_participants_api;

/
