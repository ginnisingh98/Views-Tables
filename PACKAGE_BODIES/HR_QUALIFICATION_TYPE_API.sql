--------------------------------------------------------
--  DDL for Package Body HR_QUALIFICATION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUALIFICATION_TYPE_API" AS
/* $Header: peeqtapi.pkb 115.2 2004/03/17 10:09 ynegoro noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'hr_qualification_type_api.';
--
-- --------------------------------------------------------------------------
-- |--------------------< create_qualification_type >-----------------------|
-- --------------------------------------------------------------------------
--
procedure create_qualification_type
  (p_validate               in  boolean default false
  ,p_effective_date         in date
  ,p_language_code          in varchar2 default hr_api.userenv_lang
  ,p_name                   in varchar2
  ,p_category               in varchar2
  ,p_rank                   in number           default null
  ,p_attribute_category     in varchar2         default null
  ,p_attribute1             in varchar2         default null
  ,p_attribute2             in varchar2         default null
  ,p_attribute3             in varchar2         default null
  ,p_attribute4             in varchar2         default null
  ,p_attribute5             in varchar2         default null
  ,p_attribute6             in varchar2         default null
  ,p_attribute7             in varchar2         default null
  ,p_attribute8             in varchar2         default null
  ,p_attribute9             in varchar2         default null
  ,p_attribute10            in varchar2         default null
  ,p_attribute11            in varchar2         default null
  ,p_attribute12            in varchar2         default null
  ,p_attribute13            in varchar2         default null
  ,p_attribute14            in varchar2         default null
  ,p_attribute15            in varchar2         default null
  ,p_attribute16            in varchar2         default null
  ,p_attribute17            in varchar2         default null
  ,p_attribute18            in varchar2         default null
  ,p_attribute19            in varchar2         default null
  ,p_attribute20            in varchar2         default null
  ,p_information_category   in varchar2         default null
  ,p_information1           in varchar2         default null
  ,p_information2           in varchar2         default null
  ,p_information3           in varchar2         default null
  ,p_information4           in varchar2         default null
  ,p_information5           in varchar2         default null
  ,p_information6           in varchar2         default null
  ,p_information7           in varchar2         default null
  ,p_information8           in varchar2         default null
  ,p_information9           in varchar2         default null
  ,p_information10          in varchar2         default null
  ,p_information11          in varchar2         default null
  ,p_information12          in varchar2         default null
  ,p_information13          in varchar2         default null
  ,p_information14          in varchar2         default null
  ,p_information15          in varchar2         default null
  ,p_information16          in varchar2         default null
  ,p_information17          in varchar2         default null
  ,p_information18          in varchar2         default null
  ,p_information19          in varchar2         default null
  ,p_information20          in varchar2         default null
  ,p_information21          in varchar2         default null
  ,p_information22          in varchar2         default null
  ,p_information23          in varchar2         default null
  ,p_information24          in varchar2         default null
  ,p_information25          in varchar2         default null
  ,p_information26          in varchar2         default null
  ,p_information27          in varchar2         default null
  ,p_information28          in varchar2         default null
  ,p_information29          in varchar2         default null
  ,p_information30          in varchar2         default null
  ,p_qual_framework_id      in number           default null
  ,p_qualification_type     in varchar2         default null
  ,p_credit_type            in varchar2         default null
  ,p_credits                in number           default null
  ,p_level_type             in varchar2         default null
  ,p_level_number           in number           default null
  ,p_field                  in varchar2         default null
  ,p_sub_field              in varchar2         default null
  ,p_provider               in varchar2         default null
  ,p_qa_organization        in varchar2         default null
  ,p_qualification_type_id  out NOCOPY number
  ,p_object_version_number  out NOCOPY number
 ) is

  --
  -- Declare cursors and local variables
  --
   l_proc       varchar2(72) := g_package||'create_qualification_type';
   l_effective_date 	date;

   --
   -- Declare out parameters
   --
   l_object_version_number    per_qualification_types.object_version_number%TYPE;
   l_qualification_type_id    per_qualification_types.qualification_type_id%TYPE;
   l_language_code            per_qualification_types_tl.language%TYPE;
--
 begin
--

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint create_qualification_type;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --

 begin
 hr_qualification_type_bk1.create_qualification_type_b
    (p_effective_date                => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_qualification_type'
        ,p_hook_type   => 'BP'
        );

  --
  -- End of before hook process (create_qualification_type)
  --
  end;


  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  --
  -- Validate the language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Insert qualification type
  --

 per_eqt_ins.ins
    (p_effective_date                => l_effective_date
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
    ,p_qualification_type_id         => l_qualification_type_id
    ,p_object_version_number         => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);

  --
  --  Insert translatable rows in per_qualification_types_tl table
  --
  per_qtt_ins.ins_tl
    (p_qualification_type_id         => l_qualification_type_id
    ,p_language_code                 => l_language_code
    ,p_name                          => p_name
    );
  --
  hr_utility.set_location(l_proc, 60);

  --
  -- Call After Process hook for create_qualification_type
  --
 begin
 hr_qualification_type_bk1.create_qualification_type_a
    (p_effective_date                => l_effective_date
    ,p_qualification_type_id         => l_qualification_type_id
    ,p_object_version_number         => l_object_version_number
    ,p_language_code                 => l_language_code
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_qualification_type'
        ,p_hook_type   => 'AP'
        );

   --
   -- End of after hook process (create_qualification_type)
   --
  end;

  hr_utility.set_location(l_proc, 70);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Set OUT parameters
  --
  p_qualification_type_id := l_qualification_type_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 90);
  --


EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_qualification_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_qualification_type_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_qualification_type;
    -- Set OUT parameters.
    p_qualification_type_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 110);
    RAISE;
   --
end create_qualification_type;

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_qualification_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_qualification_type
  (p_validate                      in     boolean default false
  ,p_qualification_type_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_rank                          in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_qual_framework_id             in     number   default hr_api.g_number
  ,p_qualification_type            in     varchar2 default hr_api.g_varchar2
  ,p_credit_type                   in     varchar2 default hr_api.g_varchar2
  ,p_credits                       in     number   default hr_api.g_number
  ,p_level_type                    in     varchar2 default hr_api.g_varchar2
  ,p_level_number                  in     number   default hr_api.g_number
  ,p_field                         in     varchar2 default hr_api.g_varchar2
  ,p_sub_field                     in     varchar2 default hr_api.g_varchar2
  ,p_provider                      in     varchar2 default hr_api.g_varchar2
  ,p_qa_organization               in     varchar2 default hr_api.g_varchar2
 ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                varchar2(72) := g_package||'update_qualification_type';
   l_effective_date      date;
   lv_object_version_number  per_qualification_types.object_version_number%TYPE;

   --
   -- Declare out parameters
   --
   l_object_version_number   per_qualification_types.object_version_number%TYPE;
   l_language_code           per_qualification_types_tl.language%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;


  --
  -- Issue a savepoint
  --
  savepoint update_qualification_type;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- store object version number passed in
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User hook for update_qualification_type
  --

 begin
 hr_qualification_type_bk2.update_qualification_type_b
    (p_qualification_type_id         => p_qualification_type_id
    ,p_effective_date                => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
    ,p_object_version_number         => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_qualification_type'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_qualification_type)
  --
 end;

 hr_utility.set_location(l_proc, 30);
 --
 -- Process Logic
 --

 l_object_version_number := p_object_version_number;

 --
 -- Validate the language parameter. l_language_code should be passed to functions
 -- instead of p_language_code from now on, to allow an IN OUT parameter to
 -- be passed through.
 --
 l_language_code := p_language_code;
 hr_api.validate_language_code(p_language_code => l_language_code);

 hr_utility.set_location(l_proc, 40);
 --
 --
 -- Update qualification type
 --

 per_eqt_upd.upd
    (p_effective_date                => l_effective_date
    ,p_qualification_type_id         => p_qualification_type_id
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
    ,p_object_version_number         => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);

  --
  -- Update per_qualification_types_tl table
  --
  per_qtt_upd.upd_tl
    (p_qualification_type_id         => p_qualification_type_id
    ,p_language_code                 => p_language_code
    ,p_name                          => p_name
    );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 60);

  -- Call After Process User hook for update_qualification_type
  --

 begin
 hr_qualification_type_bk2.update_qualification_type_a
    (p_qualification_type_id         => p_qualification_type_id
    ,p_effective_date                => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_name                          => p_name
    ,p_category                      => p_category
    ,p_rank                          => p_rank
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
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_qual_framework_id             => p_qual_framework_id
    ,p_qualification_type            => p_qualification_type
    ,p_credit_type                   => p_credit_type
    ,p_credits                       => p_credits
    ,p_level_type                    => p_level_type
    ,p_level_number                  => p_level_number
    ,p_field                         => p_field
    ,p_sub_field                     => p_sub_field
    ,p_provider                      => p_provider
    ,p_qa_organization               => p_qa_organization
    ,p_object_version_number         => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_qualification_type'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of after hook process (update_qualification_type)
  --
  end;

  hr_utility.set_location(l_proc, 70);

  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 90);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     rollback to update_qualification_type;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     -- when validation only mode is being used.)
     --
     p_object_version_number     := p_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     rollback to update_qualification_type;
     --
     p_object_version_number     := lv_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 110);
     --
     raise;
     --
     --
end update_qualification_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_qualification_type >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_qualification_type
  (p_validate                     in     boolean
  ,p_qualification_type_id        in     number
  ,p_object_version_number        in out nocopy number
  )
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_qualification_type';
  lv_object_version_number  per_qualification_types.object_version_number%type;

  --
  -- Declare out parameter
  --
  l_object_version_number  per_qualification_types.object_version_number%type;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint delete_qualification_type;

  l_object_version_number := p_object_version_number;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin

  hr_qualification_type_bk3.delete_qualification_type_b
    (p_qualification_type_id      =>  p_qualification_type_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_QUALIFICATION_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);

  --
  --  Remove all matching translation rows in per_qualification_types_tl
  --
  per_qtt_del.del_tl
    (p_qualification_type_id         => p_qualification_type_id
    );

  hr_utility.set_location(l_proc, 40);

  --
  -- Process Logic
  --
  per_eqt_del.del
     (p_qualification_type_id     => p_qualification_type_id
     ,p_object_version_number     => l_object_version_number
     ,p_validate                  => p_validate
     );

  hr_utility.set_location(l_proc, 50);

  --
  -- Call After Process User Hook
  --
  begin
  hr_qualification_type_bk3.delete_qualification_type_a
    (p_qualification_type_id      =>  p_qualification_type_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_QUALIFICATION_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 60);

  p_object_version_number := l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 80);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_qualification_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 90);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_qualification_type;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := lv_object_version_number;
    --
    raise;
--
end delete_qualification_type;
--
end hr_qualification_type_api;

/
