--------------------------------------------------------
--  DDL for Package Body PAY_RUN_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_TYPE_API" as
/* $Header: pyprtapi.pkb 115.6 2003/02/01 13:41:18 prsundar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_run_type_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_run_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_run_type_name                 in     varchar2
  ,p_run_method                    in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_shortname                     in     varchar2 default null
  ,p_srs_flag                      in     varchar2 default 'Y'
  ,p_run_information_category	   in     varchar2 default null
  ,p_run_information1		   in     varchar2 default null
  ,p_run_information2		   in     varchar2 default null
  ,p_run_information3		   in     varchar2 default null
  ,p_run_information4		   in	  varchar2 default null
  ,p_run_information5		   in     varchar2 default null
  ,p_run_information6		   in     varchar2 default null
  ,p_run_information7		   in     varchar2 default null
  ,p_run_information8		   in     varchar2 default null
  ,p_run_information9		   in	  varchar2 default null
  ,p_run_information10		   in     varchar2 default null
  ,p_run_information11		   in     varchar2 default null
  ,p_run_information12		   in     varchar2 default null
  ,p_run_information13		   in     varchar2 default null
  ,p_run_information14		   in	  varchar2 default null
  ,p_run_information15		   in     varchar2 default null
  ,p_run_information16		   in     varchar2 default null
  ,p_run_information17		   in     varchar2 default null
  ,p_run_information18		   in     varchar2 default null
  ,p_run_information19		   in	  varchar2 default null
  ,p_run_information20		   in     varchar2 default null
  ,p_run_information21		   in     varchar2 default null
  ,p_run_information22		   in     varchar2 default null
  ,p_run_information23		   in     varchar2 default null
  ,p_run_information24		   in	  varchar2 default null
  ,p_run_information25		   in     varchar2 default null
  ,p_run_information26		   in     varchar2 default null
  ,p_run_information27		   in     varchar2 default null
  ,p_run_information28		   in     varchar2 default null
  ,p_run_information29		   in	  varchar2 default null
  ,p_run_information30		   in     varchar2 default null
  ,p_run_type_id                      out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_run_type';
  l_effective_date      date;
  l_language_code       varchar2(4);
  --
  -- Declare OUT variables
  --
  l_run_type_id              pay_run_types_f.run_type_id%TYPE;
  l_object_version_number    pay_run_types_f.object_version_number%TYPE;
  l_effective_start_date     pay_run_types_f.effective_start_date%TYPE;
  l_effective_end_date       pay_run_types_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_run_type;
  --
  -- Validate the language provided
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_bk1.create_run_type_b
      (p_effective_date                => l_effective_date
      ,p_language_code                 => l_language_code
      ,p_run_type_name                 => p_run_type_name
      ,p_run_method                    => p_run_method
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_shortname                     => p_shortname
      ,p_srs_flag                      => p_srs_flag
      ,p_run_information_category      => p_run_information_category
      ,p_run_information1	       => p_run_information1
      ,p_run_information2	       => p_run_information2
      ,p_run_information3	       => p_run_information3
      ,p_run_information4	       => p_run_information4
      ,p_run_information5	       => p_run_information5
      ,p_run_information6	       => p_run_information6
      ,p_run_information7	       => p_run_information7
      ,p_run_information8	       => p_run_information8
      ,p_run_information9	       => p_run_information9
      ,p_run_information10	       => p_run_information10
      ,p_run_information11	       => p_run_information11
      ,p_run_information12	       => p_run_information12
      ,p_run_information13	       => p_run_information13
      ,p_run_information14	       => p_run_information14
      ,p_run_information15	       => p_run_information15
      ,p_run_information16	       => p_run_information16
      ,p_run_information17	       => p_run_information17
      ,p_run_information18	       => p_run_information18
      ,p_run_information19	       => p_run_information19
      ,p_run_information20	       => p_run_information20
      ,p_run_information21	       => p_run_information21
      ,p_run_information22	       => p_run_information22
      ,p_run_information23	       => p_run_information23
      ,p_run_information24	       => p_run_information24
      ,p_run_information25	       => p_run_information25
      ,p_run_information26	       => p_run_information26
      ,p_run_information27	       => p_run_information27
      ,p_run_information28	       => p_run_information28
      ,p_run_information29	       => p_run_information29
      ,p_run_information30	       => p_run_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_prt_ins.ins
       (p_effective_date              => l_effective_date
       ,p_run_type_name               => p_run_type_name
       ,p_run_method                  => p_run_method
       ,p_business_group_id           => p_business_group_id
       ,p_legislation_code            => p_legislation_code
       ,p_shortname                   => p_shortname
       ,p_srs_flag                    => p_srs_flag
       ,p_run_information_category    => p_run_information_category
       ,p_run_information1	      => p_run_information1
       ,p_run_information2	      => p_run_information2
       ,p_run_information3	      => p_run_information3
       ,p_run_information4	      => p_run_information4
       ,p_run_information5	      => p_run_information5
       ,p_run_information6	      => p_run_information6
       ,p_run_information7	      => p_run_information7
       ,p_run_information8	      => p_run_information8
       ,p_run_information9	      => p_run_information9
       ,p_run_information10	      => p_run_information10
       ,p_run_information11	      => p_run_information11
       ,p_run_information12	      => p_run_information12
       ,p_run_information13	      => p_run_information13
       ,p_run_information14	      => p_run_information14
       ,p_run_information15	      => p_run_information15
       ,p_run_information16	      => p_run_information16
       ,p_run_information17	      => p_run_information17
       ,p_run_information18	      => p_run_information18
       ,p_run_information19	      => p_run_information19
       ,p_run_information20	      => p_run_information20
       ,p_run_information21	      => p_run_information21
       ,p_run_information22	      => p_run_information22
       ,p_run_information23	      => p_run_information23
       ,p_run_information24	      => p_run_information24
       ,p_run_information25	      => p_run_information25
       ,p_run_information26	      => p_run_information26
       ,p_run_information27	      => p_run_information27
       ,p_run_information28	      => p_run_information28
       ,p_run_information29	      => p_run_information29
       ,p_run_information30	      => p_run_information30
       ,p_run_type_id                 => l_run_type_id
       ,p_object_version_number       => l_object_version_number
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Create the translation rows
  --
    pay_rtt_ins.ins_tl(p_language_code => l_language_code
                      ,p_run_type_id   => l_run_type_id
                      ,p_run_type_name => p_run_type_name
                      ,p_shortname     => p_shortname
                      );
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_bk1.create_run_type_a
      (p_effective_date                => l_effective_date
      ,p_language_code                 => l_language_code
      ,p_run_type_name                 => p_run_type_name
      ,p_run_method                    => p_run_method
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_shortname                     => p_shortname
      ,p_srs_flag                      => p_srs_flag
      ,p_run_information_category      => p_run_information_category
      ,p_run_information1	       => p_run_information1
      ,p_run_information2	       => p_run_information2
      ,p_run_information3	       => p_run_information3
      ,p_run_information4	       => p_run_information4
      ,p_run_information5	       => p_run_information5
      ,p_run_information6	       => p_run_information6
      ,p_run_information7	       => p_run_information7
      ,p_run_information8	       => p_run_information8
      ,p_run_information9	       => p_run_information9
      ,p_run_information10	       => p_run_information10
      ,p_run_information11	       => p_run_information11
      ,p_run_information12	       => p_run_information12
      ,p_run_information13	       => p_run_information13
      ,p_run_information14	       => p_run_information14
      ,p_run_information15	       => p_run_information15
      ,p_run_information16	       => p_run_information16
      ,p_run_information17	       => p_run_information17
      ,p_run_information18	       => p_run_information18
      ,p_run_information19	       => p_run_information19
      ,p_run_information20	       => p_run_information20
      ,p_run_information21	       => p_run_information21
      ,p_run_information22	       => p_run_information22
      ,p_run_information23	       => p_run_information23
      ,p_run_information24	       => p_run_information24
      ,p_run_information25	       => p_run_information25
      ,p_run_information26	       => p_run_information26
      ,p_run_information27	       => p_run_information27
      ,p_run_information28	       => p_run_information28
      ,p_run_information29	       => p_run_information29
      ,p_run_information30	       => p_run_information30
      ,p_run_type_id                   => l_run_type_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type_a'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_run_type_id            := l_run_type_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_run_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_run_type_id            := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_run_type;
    raise;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
end create_run_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_run_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_run_type_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_shortname                     in     varchar2 default hr_api.g_varchar2
  ,p_srs_flag                      in     varchar2 default hr_api.g_varchar2
  ,p_run_information_category	   in     varchar2 default hr_api.g_varchar2
  ,p_run_information1		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information2		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information3		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information4		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information5		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information6		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information7		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information8		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information9		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information10		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information11		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information12		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information13		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information14		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information15		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information16		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information17		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information18		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information19		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information20		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information21		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information22		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information23		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information24		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information25		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information26		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information27		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information28		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information29		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information30		   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_run_type';
  l_effective_date      date;
  l_language_code       varchar2(4);
  --
  -- Declare OUT variables
  --
  l_effective_start_date     pay_run_types_f.effective_start_date%TYPE;
  l_effective_end_date       pay_run_types_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variable
  --
  l_object_version_number    pay_run_types_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --
  l_object_version_number := p_object_version_number;
  savepoint update_run_type;
  --
  -- Validate language code
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_bk2.update_run_type_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_language_code                 => l_language_code
      ,p_run_type_id                   => p_run_type_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_shortname                     => p_shortname
      ,p_srs_flag                      => p_srs_flag
      ,p_run_information_category      => p_run_information_category
      ,p_run_information1	       => p_run_information1
      ,p_run_information2	       => p_run_information2
      ,p_run_information3	       => p_run_information3
      ,p_run_information4	       => p_run_information4
      ,p_run_information5	       => p_run_information5
      ,p_run_information6	       => p_run_information6
      ,p_run_information7	       => p_run_information7
      ,p_run_information8	       => p_run_information8
      ,p_run_information9	       => p_run_information9
      ,p_run_information10	       => p_run_information10
      ,p_run_information11	       => p_run_information11
      ,p_run_information12	       => p_run_information12
      ,p_run_information13	       => p_run_information13
      ,p_run_information14	       => p_run_information14
      ,p_run_information15	       => p_run_information15
      ,p_run_information16	       => p_run_information16
      ,p_run_information17	       => p_run_information17
      ,p_run_information18	       => p_run_information18
      ,p_run_information19	       => p_run_information19
      ,p_run_information20	       => p_run_information20
      ,p_run_information21	       => p_run_information21
      ,p_run_information22	       => p_run_information22
      ,p_run_information23	       => p_run_information23
      ,p_run_information24	       => p_run_information24
      ,p_run_information25	       => p_run_information25
      ,p_run_information26	       => p_run_information26
      ,p_run_information27	       => p_run_information27
      ,p_run_information28	       => p_run_information28
      ,p_run_information29	       => p_run_information29
      ,p_run_information30	       => p_run_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_prt_upd.upd
       (p_effective_date              => l_effective_date
       ,p_datetrack_mode              => p_datetrack_update_mode
       ,p_run_type_id                 => p_run_type_id
       ,p_object_version_number       => p_object_version_number
       ,p_shortname                   => p_shortname
       ,p_srs_flag                    => p_srs_flag
       ,p_run_information_category    => p_run_information_category
       ,p_run_information1	      => p_run_information1
       ,p_run_information2	      => p_run_information2
       ,p_run_information3	      => p_run_information3
       ,p_run_information4	      => p_run_information4
       ,p_run_information5	      => p_run_information5
       ,p_run_information6	      => p_run_information6
       ,p_run_information7	      => p_run_information7
       ,p_run_information8	      => p_run_information8
       ,p_run_information9	      => p_run_information9
       ,p_run_information10	      => p_run_information10
       ,p_run_information11	      => p_run_information11
       ,p_run_information12	      => p_run_information12
       ,p_run_information13	      => p_run_information13
       ,p_run_information14	      => p_run_information14
       ,p_run_information15	      => p_run_information15
       ,p_run_information16	      => p_run_information16
       ,p_run_information17	      => p_run_information17
       ,p_run_information18	      => p_run_information18
       ,p_run_information19	      => p_run_information19
       ,p_run_information20	      => p_run_information20
       ,p_run_information21	      => p_run_information21
       ,p_run_information22	      => p_run_information22
       ,p_run_information23	      => p_run_information23
       ,p_run_information24	      => p_run_information24
       ,p_run_information25	      => p_run_information25
       ,p_run_information26	      => p_run_information26
       ,p_run_information27	      => p_run_information27
       ,p_run_information28	      => p_run_information28
       ,p_run_information29	      => p_run_information29
       ,p_run_information30	      => p_run_information30
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call the upd tl table
  --
    pay_rtt_upd.upd_tl
        (p_language_code => l_language_code
        ,p_run_type_id   => p_run_type_id
        ,p_shortname     => p_shortname
        );
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_bk2.update_run_type_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_language_code                 => l_language_code
      ,p_run_type_id                   => p_run_type_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_shortname                     => p_shortname
      ,p_srs_flag                      => p_srs_flag
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_run_information_category      => p_run_information_category
      ,p_run_information1	       => p_run_information1
      ,p_run_information2	       => p_run_information2
      ,p_run_information3	       => p_run_information3
      ,p_run_information4	       => p_run_information4
      ,p_run_information5	       => p_run_information5
      ,p_run_information6	       => p_run_information6
      ,p_run_information7	       => p_run_information7
      ,p_run_information8	       => p_run_information8
      ,p_run_information9	       => p_run_information9
      ,p_run_information10	       => p_run_information10
      ,p_run_information11	       => p_run_information11
      ,p_run_information12	       => p_run_information12
      ,p_run_information13	       => p_run_information13
      ,p_run_information14	       => p_run_information14
      ,p_run_information15	       => p_run_information15
      ,p_run_information16	       => p_run_information16
      ,p_run_information17	       => p_run_information17
      ,p_run_information18	       => p_run_information18
      ,p_run_information19	       => p_run_information19
      ,p_run_information20	       => p_run_information20
      ,p_run_information21	       => p_run_information21
      ,p_run_information22	       => p_run_information22
      ,p_run_information23	       => p_run_information23
      ,p_run_information24	       => p_run_information24
      ,p_run_information25	       => p_run_information25
      ,p_run_information26	       => p_run_information26
      ,p_run_information27	       => p_run_information27
      ,p_run_information28	       => p_run_information28
      ,p_run_information29	       => p_run_information29
      ,p_run_information30	       => p_run_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type_a'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_run_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_run_type;
    raise;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
end update_run_type;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_run_type >---------------------------|
-- ----------------------------------------------------------------------------
procedure delete_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := g_package||'delete_run_type';
  l_effective_date     date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date  pay_run_types_f.effective_start_date%type;
  l_effective_end_date    pay_run_types_f.effective_end_date%type;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_version_number pay_run_types_f.object_version_number%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --
  savepoint delete_run_type;
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
    l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_bk3.delete_run_type_b
      (p_effective_date            => l_effective_date
      ,p_datetrack_delete_mode     => p_datetrack_delete_mode
      ,p_run_type_id               => p_run_type_id
      ,p_object_version_number     => p_object_version_number
      ,p_business_group_id         => p_business_group_id
      ,p_legislation_code          => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_run_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
    hr_utility.set_location(l_proc, 30);
  --
  -- Lock the non-translated table row handler for ZAP datetrack delete mode
  --
  if p_datetrack_delete_mode = hr_api.g_zap then
  --
    pay_prt_shd.lck(p_effective_date        => l_effective_date
                   ,p_datetrack_mode        => p_datetrack_delete_mode
                   ,p_run_type_id           => p_run_type_id
                   ,p_object_version_number => p_object_version_number
                   ,p_validation_start_date => l_validation_start_date
                   ,p_validation_end_date   => l_validation_end_date
                   );
  --
  -- Call tl table delete row handler
  --
    pay_rtt_del.del_tl(p_run_type_id => p_run_type_id);
    --
  end if; -- mode = ZAP
  --
  -- Call the row handler to delete the run_type
  --
    pay_prt_del.del
      (p_effective_date               => l_effective_date
      ,p_datetrack_mode               => p_datetrack_delete_mode
      ,p_run_type_id                  => p_run_type_id
      ,p_object_version_number        => p_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_bk3.delete_run_type_a
      (p_effective_date            => l_effective_date
      ,p_datetrack_delete_mode     => p_datetrack_delete_mode
      ,p_run_type_id               => p_run_type_id
      ,p_object_version_number     => p_object_version_number
      ,p_business_group_id         => p_business_group_id
      ,p_legislation_code          => p_legislation_code
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
    --
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set out parameters
  --
    p_object_version_number := p_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;
    --
  hr_utility.set_location(l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_run_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO delete_run_type;
    raise;
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
end delete_run_type;
-- ----------------------------------------------------------------------------
end pay_run_type_api;

/
