--------------------------------------------------------
--  DDL for Package Body PSP_PERIOD_FREQUENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PERIOD_FREQUENCY_API" as
/* $Header: PSPFBAIB.pls 120.0 2005/06/02 15:59 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  psp_period_frequency_api.';
dup_data Exception;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Period_frequency >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure Create_Period_frequency
 ( p_validate                       in         BOOLEAN default false
  ,p_start_date                     in         date
  ,p_unit_of_measure                in         varchar2
  ,p_period_duration                in         number
  ,p_report_type                    in         varchar2  default null
  ,p_period_frequency               in         varchar2
  ,p_language_code                  in         varchar2 default hr_api.userenv_lang
  ,p_period_frequency_id            out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_api_warning                    out nocopy varchar2
  ) is
l_proc        varchar2(72) := g_package || 'Create_Period_frequency';
--l_period_frequency             psp_report_period_frequency_tl.period_frequency%TYPE;
l_period_frequency_name        psp_report_period_frequency_tl.period_frequency%TYPE;
l_period_frequency_id          psp_report_period_frequency_b.period_frequency_id%TYPE;
l_object_version_number        psp_report_period_frequency_b.object_version_number%TYPE;
l_api_warning                  varchar2(250);
l_language_code                varchar2(30) := p_language_code;
--
-- cursor to check Duplicate  Period Frequency
--
cursor c_period_frequency
is
select distinct period_frequency
from   psp_report_period_frequency_v
where  period_frequency =  p_period_frequency;
--
-- end of cursor
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Create_Period_frequency;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  open    c_period_frequency;
  fetch   c_period_frequency into l_period_frequency_name;
  close   c_period_frequency;
  if (l_period_frequency_name is not NULL ) then
     raise dup_data;
  end if;
--
-- Call Before Process User Hook
--
begin
hr_utility.set_location('Before Calling User Hook Create_period_Frequency_b',20);
PSP_Period_frequency_BK1.Create_Period_frequency_b
( p_start_date               => p_start_date
,p_unit_of_measure          => p_unit_of_measure
,p_period_duration          => p_period_duration
,p_report_type              => p_report_type
,p_period_frequency         => p_period_frequency
);
hr_utility.set_location('After Calling User Hook Create_period_Frequency_b',25);
exception
when hr_api.cannot_find_prog_unit then
hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_PERIOD_FREQUENCY'
,p_hook_type   => 'BP'
);
end;
--
-- Validation in addition to Row Handlers
--
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 -- Base Table insert statement
  psp_pfb_ins.ins
  (p_start_date                => p_start_date
  ,p_unit_of_measure           => p_unit_of_measure
  ,p_period_duration           => p_period_duration
  ,p_report_type               => p_report_type
  ,p_period_frequency_id       => l_period_frequency_id
  ,p_object_version_number     => l_object_version_number
  );
 -- Transaltion table insert Statement
   psp_pft_ins.ins_tl
   ( p_language_code       => l_language_code
    ,p_period_frequency_id => l_period_frequency_id
    ,p_period_frequency    => p_period_frequency
   );
--
-- Call After Process User Hook
--
begin
PSP_Period_frequency_BK1.Create_Period_frequency_a
(p_start_date               => p_start_date
,p_unit_of_measure          => p_unit_of_measure
,p_period_duration          => p_period_duration
,p_report_type              => p_report_type
,p_period_frequency         => p_period_frequency
,p_period_frequency_id      => l_period_frequency_id
,p_object_version_number    => l_object_version_number
,p_api_warning              => l_api_warning
);
exception
when hr_api.cannot_find_prog_unit then
hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_PERIOD_FREQUENCY'
,p_hook_type   => 'AP'
);
end;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- When in validation only mode raise the Validate_Enabled exception
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If p_validate Then
   raise hr_api.validate_enabled;
End If;
--
-- Set all IN OUT and OUT parameters with out values
--
 p_period_frequency_id    := l_period_frequency_id;
 p_object_version_number  := l_object_version_number;
 p_api_warning            := l_api_warning;
exception
when dup_data then
   fnd_message.set_name('PSP','PSP_DUP_PERIOD_FREQUENCY');
   fnd_message.set_token('PERIODFREQUENCY',p_period_frequency);
   fnd_message.raise_error;
when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Create_Period_frequency;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
   p_period_frequency_id    := null;
   p_object_version_number  := null;
   p_api_warning            := l_api_warning;
   hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Create_Period_frequency;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
   p_period_frequency_id    := null;
   p_object_version_number  := null;
   p_api_warning            := l_api_warning;
   hr_utility.set_location('error is : '||SQLERRM,85);
   hr_utility.set_location(' Leaving:'||l_proc, 90);
end Create_Period_frequency;
--
-- -------------------------------------------------------------------------------
-- |--------------------------< Update_Period_Frequency >--------------------------|
-- --------------------------------------------------------------------------------
procedure Update_Period_Frequency
  (p_validate                       in     BOOLEAN default false
  ,p_start_date                     in     date
  ,p_unit_of_measure                in     varchar2
  ,p_period_duration                in     number
  ,p_report_type                    in     varchar2 default null
  ,p_language_code                 in      varchar2 default hr_api.userenv_lang
  ,p_period_frequency               in     varchar2
  ,p_period_frequency_id            in     number
  ,p_object_version_number          in out nocopy number
  ,p_api_warning                    out nocopy varchar2
  ) is
l_proc                   varchar2(150) := g_package||'Update_Period_Frequency';
l_api_warning            varchar2(250);
l_object_version_number  psp_report_period_frequency_b.object_version_number%TYPE;
l_language_code          varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Issue a savepoint
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 savepoint Update_Period_Frequency ;
  l_object_version_number := p_object_version_number;
  l_language_code         := p_language_code;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call Before Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   begin
    hr_utility.set_location('Before Calling User Hook Update_Period_Frequency_b',20);
    PSP_Period_frequency_BK2.Update_Period_Frequency_b
    ( p_start_date                =>   p_start_date
     ,p_unit_of_measure           =>   p_unit_of_measure
     ,p_period_duration           =>   p_period_duration
     ,p_report_type               =>   p_report_type
     ,p_period_frequency          =>   p_period_frequency
     ,p_period_frequency_id       =>   p_period_frequency_id
     ,p_object_version_number     =>   l_object_version_number
   );
    hr_utility.set_location('After Calling User Hook Update_Period_Frequency_b',20);
   exception
    when hr_api.cannot_find_prog_unit then
    hr_utility.set_location('Exception in User Hook Update_Period_Frequency_b',25);
    hr_api.cannot_find_prog_unit_error
    (p_module_name => 'Update_Period_Frequency'
     ,p_hook_type   => 'BP'
    );
   end;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Validation in addition to Row Handlers
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   hr_utility.set_location('Before calling row-handler psp_pfb_upd.upd',30);
   psp_pfb_upd.upd
  (p_period_frequency_id          =>   p_period_frequency_id
  ,p_object_version_number        =>   l_object_version_number
  ,p_start_date                   =>   p_start_date
  ,p_unit_of_measure              =>   p_unit_of_measure
  ,p_period_duration              =>   p_period_duration
  ,p_report_type                  =>   p_report_type
  );
 -- Row Handlers for updating the  _Tl table
   psp_pft_upd.upd_tl
   ( p_language_code                => l_language_code
    ,p_period_frequency_id          => p_period_frequency_id
    ,p_period_frequency             => p_period_frequency
   );
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call After Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  begin
  hr_utility.set_location(' Before Calling User Hook : Update_Period_Frequency_a',20);
  PSP_Period_Frequency_Bk2.Update_Period_Frequency_a
  (p_start_date                    =>    p_start_date
  ,p_unit_of_measure               =>    p_unit_of_measure
  ,p_period_duration               =>    p_period_duration
  ,p_report_type                   =>    p_report_type
  ,p_period_frequency              =>    p_period_frequency
  ,p_period_frequency_id           =>    p_period_frequency_id
  ,p_object_version_number         =>    l_object_version_number
  ,p_api_warning                   =>    l_api_warning
  );
  hr_utility.set_location(' After Calling User Hook :Update_Period_Frequency_a',20);
  exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook :Update_Period_Frequency_a',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Period_Frequency'
        ,p_hook_type   => 'AP'
        );
  end;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- When in validation only mode raise the Validate_Enabled exception
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If p_validate Then
     raise hr_api.validate_enabled;
  End If;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Set all output arguments
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p_object_version_number  := l_object_version_number;
  p_api_warning            := l_api_warning;
 hr_utility.set_location(' Leaving:'||l_proc, 70);
Exception
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To Update_Period_Frequency;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_warning          := l_api_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occured
    --
    Rollback to Update_Period_Frequency;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
End  Update_Period_Frequency ;
--
-- -------------------------------------------------------------------------------
-- |--------------------------< Delete_Period_Frequency >--------------------------|
-- --------------------------------------------------------------------------------
procedure Delete_Period_Frequency
  (p_validate                       in     BOOLEAN default false
  ,p_period_frequency_id            in     number
  ,p_object_version_number          in out nocopy number
  ,p_api_warning                       out nocopy varchar2
  ) is
  l_proc                         varchar2(150) := g_package||'Delete_Period_Frequency';
  l_object_version_number        psp_report_period_frequency_b.object_version_number%TYPE;
  l_api_warning                  varchar2(250);
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Issue a savepoint
    savepoint Delete_Period_Frequency;

  -- Truncate the time portion from all IN date parameters

  l_object_version_number := p_object_version_number;
  -- Call Before Process User Hook
  Begin
    hr_utility.set_location('Before Calling User Hook Delete_Period_Frequency_b',20);
    PSP_Period_frequency_BK3.Delete_Period_Frequency_b
       ( p_period_frequency_id           => p_period_frequency_id
        ,p_object_version_number         => l_object_version_number
       );
    hr_utility.set_location('After Calling User Hook Delete_Period_Frequency_b',20);
  Exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook Delete_Period_Frequency_b',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Period_Frequency'
        ,p_hook_type   => 'BP'
        );
  End;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- call the  procedure to delete from the _tl table
   hr_utility.set_location('Before calling row-handler psp_pft_del.del_tl',30);
    psp_pft_del.del_tl( p_period_frequency_id => p_period_frequency_id) ;
   -- call the  procedure to delete from the Base table

 hr_utility.set_location('Before calling row-handler psp_pft_del.del',35);
    psp_pfb_del.del
    ( p_period_frequency_id   => p_period_frequency_id
     ,p_object_version_number => l_object_version_number) ;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call After Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Begin
    hr_utility.set_location('Before Calling User Hook Delete_Period_Frequency_a',20);
    PSP_Period_frequency_BK3.Delete_Period_Frequency_a
      (p_period_frequency_id     => p_period_frequency_id
       ,p_object_version_number   => l_object_version_number
       ,p_api_warning             => l_api_warning
      );
      hr_utility.set_location('After Calling User Hook Delete_Period_Frequency_a',20);
  Exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook Delete_Period_Frequency_a',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Period_Frequency'
        ,p_hook_type   => 'AP'
        );
  End;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- When in validation only mode raise the Validate_Enabled exception
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If p_validate Then
     raise hr_api.validate_enabled;
  End If;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Set all output arguments
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
Exception
when dup_data then
   fnd_message.set_name('PSP','PSP_DUP_PERIOD_FREQUENCY');
   fnd_message.raise_error;
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To Delete_Period_Frequency;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occured
    --
    Rollback to Delete_Period_Frequency;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
End Delete_Period_Frequency;
end PSP_Period_frequency_API;

/
