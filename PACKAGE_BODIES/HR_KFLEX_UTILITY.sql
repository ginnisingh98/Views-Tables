--------------------------------------------------------
--  DDL for Package Body HR_KFLEX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KFLEX_UTILITY" as
/* $Header: hrkfutil.pkb 120.0.12010000.3 2009/03/25 09:06:15 ktithy ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_kflex_utility';
g_kfcode_structure l_ignore_kfcode_varray := l_ignore_kfcode_varray();
g_delimiter_escape varchar2(1) := '\';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- get_application_id ---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Bug fix 2148839
-- Description:
--   This private function returns the application id for the application short
--   name passed.
--
-- Prerequisites:
--   A valid application short name.
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_appl_short_name     Yes  Varchar  Application short name.
--
-- Post Success:
--   Application Is will be retunred.
--
-- Post Failure:
--   No error.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
--
Function get_application_id(
            p_appl_short_name  in  fnd_application.application_short_name%TYPE)
            return number is
  cursor get_appln_id is
    select application_id
    from   fnd_application
    where  application_short_name = p_appl_short_name;
  l_application_id fnd_application.application_id%type;

begin
  open get_appln_id;
  fetch get_appln_id into l_application_id;
  close get_appln_id;
  return l_application_id;
end get_application_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- get_no_segments -----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private function returns the number of enabled segments within a
--   given flexfield structure.
--
-- Prerequisites:
--   A valid id_flex_code (flex structure code)
--   A valid id_flex_num  (flex structure number)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_flex_num            Yes  number   The structure number for the Bank
--                                       Details key flexfield.
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--
-- Post Success:
--   The number of valid segments for a given flex structure is returned.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
--
FUNCTION get_no_segments
  (p_flex_num   number
  ,p_flex_code  fnd_id_flex_segments.id_flex_code%TYPE
  -- Bug fix 2148839.
  ,p_application_id IN number
  )
  RETURN NUMBER
is
  --
  l_no_segments number;
  l_proc        varchar2(72);
  --
  -- Bug fix 2148839.
  -- Application id added to the cursor to improve
  -- performance.

  cursor number_of_segments is
    select count(*)
    from   fnd_id_flex_segments
    where  id_flex_code = p_flex_code
    and    id_flex_num  = p_flex_num
    and    application_id = p_application_id
    and    enabled_flag = 'Y';
  --
begin
  if g_debug then
     l_proc := 'get_no_segments';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
    --
  -- Fetch number of segments in KF structure
  --
  open number_of_segments;
  fetch number_of_segments into l_no_segments;
  -- bug fix 2148839.
  -- If condition below is commented. Since the
  -- count will always return a row.
 /* if number_of_segments%NOTFOUND then
    close number_of_segments;
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
    --
  end if;*/
  close number_of_segments;
  RETURN l_no_segments;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 30);
  end if;
    --
end get_no_segments;
--
-- ----------------------------------------------------------------------------
-- |------------------------<     find_error_segment      >-------------------|
-- ----------------------------------------------------------------------------
--
procedure find_error_segment(p_appl_short_name      IN  varchar2,
                             p_flex_code            IN  varchar2,
                             p_flex_num             IN  number,
                             p_error_seg_num        IN  number,
                             p_application_col_name OUT NOCOPY varchar2,
                             p_form_left_prompt     OUT NOCOPY varchar2,
                             p_table_name           OUT NOCOPY varchar2
                            )is
l_proc              varchar2(72);
l_flexfield         fnd_flex_key_api.flexfield_type;
l_structure         fnd_flex_key_api.structure_type;
l_segment           fnd_flex_key_api.segment_type;
l_segment_list      fnd_flex_key_api.segment_list;
l_nsegments         number;
l_error_segment_name fnd_id_flex_segments.segment_name%TYPE;

begin

-- Obtain the application column name corresponding to the error segment
-- in an AOL supported way.  It would be much faster to perform a direct
-- access on the table FND_DESCR_FLEX_COLUMN_USAGES but this SQL would
-- not be supported by AOL.
--
-- First get the flexfield information
--
  if g_debug then
   l_proc  := 'hr_kflex_utility.find_error_segment';
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
   l_flexfield := fnd_flex_key_api.find_flexfield(
                         appl_short_name => p_appl_short_name,
                         flex_code => p_flex_code);

--
-- Use l_flexfield in calls that follow to identify the flexfield.
-- Next check that the context is valid, otherwise return the context
-- column name and prompt
--
  if g_debug then
   hr_utility.set_location(l_proc, 20);
  end if;
--
   if (p_error_seg_num = 0) then
--
--   The context is in error.  We should return the context column
--   and prompt.
--
  if g_debug then
   hr_utility.set_location(l_proc, 30);
  end if;
--
     p_application_col_name := l_flexfield.structure_column;
     p_form_left_prompt := p_flex_code||' - '||to_char(p_flex_num);
     p_table_name := l_flexfield.table_name;
--
   else
--
-- We have a valid context, so get the context information
--
  if g_debug then
   hr_utility.set_location(l_proc, 40);
  end if;
  --
     l_structure := fnd_flex_key_api.find_structure(
                             flexfield => l_flexfield,
                             structure_number => p_flex_num);
--
-- Finally retrieve the segment information for this context
--
    if g_debug then
     hr_utility.set_location(l_proc, 50);
    end if;
--
-- Get the list of segments for this structure
--
     fnd_flex_key_api.get_segments(
                                flexfield => l_flexfield,
                                structure => l_structure,
                                enabled_only => TRUE,
                                nsegments => l_nsegments,
                                segments =>  l_segment_list);
--
    if g_debug then
     hr_utility.set_location(l_proc, 55);
    end if;
--
-- Use the error segment number passed in, to work out
-- which segment is in error.
--
    l_error_segment_name := l_segment_list(p_error_seg_num);
--
-- Use that name to find out information about the segment
--
     l_segment:= fnd_flex_key_api.find_segment(
                          flexfield => l_flexfield,
                          structure => l_structure,
                          segment_name => l_error_segment_name);
--
-- Next retrieve the application column name corresponding to the segment
-- in error.  We know where this is in the table because the sequence is
-- used as the order key.  This should be the same sequence as is used
-- inside the FND_FLEX_DESCVAL procedures.
--
     p_application_col_name := l_segment.column_name;
     p_form_left_prompt := l_segment.window_prompt;
     p_table_name := l_flexfield.table_name;
--
   end if;
--
  if g_debug then
   hr_utility.set_location('Leaving: '||l_proc, 60);
  end if;
end find_error_segment;
--
-- ----------------------------------------------------------------------------
-- |------------------------ Check_segment_combination -----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Concatenated string interface
--
--   This private procedure ensures that either a new flex combination is
--   created for the key flexfield selected or the relevant code combination
--   is found if the combination already exists.
--
-- Prerequisites:
--   A valid application short name
--   A valid id_flex_code (flex structure code)
--   A valid id_flex_num  (flex structure number)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_appl_short_name     Yes  varchar2 The application shortname for the
--                                       application a key flexfield belongs
--                                       to (i.e. PER/PAY).
--   p_flex_num            Yes  number   The id_flex_num of the relevant key
--                                       flexfield structure
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--   p_concat_segments     Yes  varchar2 Contains concatenated string of key
--                                       flexfield segment values in segment
--                                       display order
--
-- Post Success:
--   The procedure create a new code combination and passes back the new
--   CCID or finds an existing code combination and passes back the CCID.
--
-- Post Failure:
--   The process raises an AOL error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure check_segment_combination
  (p_appl_short_name     in     fnd_application.application_short_name%TYPE
  ,p_flex_num            in     number
  ,p_flex_code           in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_concat_segments_in  in     varchar2
  ,p_ccid                   out nocopy number
  ,p_concat_segments_out    out nocopy varchar2
  ) is
  --
  l_proc            varchar2(72);
  error_seg           number;
  app_col_name        fnd_columns.column_name%TYPE;
  l_flex_seg_error_prompt  fnd_id_flex_segments_vl.form_left_prompt%type;
  value               VARCHAR2(2000); -- Note: PL/SQL value errors may occur if
                                    -- we increase the db size of key flex
                                    -- segments.
  l_table_name        VARCHAR2(60);
  -- start for fix of 3171225
  l_effective_date   date;

  cursor date_set is
     select EFFECTIVE_DATE from fnd_sessions
     where session_id=userenv('sessionid');
  -- end for fix of 3171225
  --
begin
  if g_debug then
    l_proc := 'check_segment_combination';
    hr_utility.set_location('Entering:'|| l_proc, 11);
  end if;
--
--3171225 start
  l_effective_date:=to_date(null);
  open date_set;
  fetch date_set into l_effective_date;
  if date_set%notfound then
    if g_debug then
     hr_utility.set_location(l_proc,13);
    end if;
    l_effective_date := trunc(sysdate);
    close date_set;
  else
    if g_debug then
     hr_utility.set_location(l_proc,15);
    end if;
   close date_set;
  end if;
--3171225 end
if fnd_flex_keyval.validate_segs
       (operation        => 'CREATE_COMBINATION'
       ,appl_short_name  => p_appl_short_name
       ,key_flex_code    => p_flex_code
       ,structure_number => p_flex_num
       ,concat_segments  => p_concat_segments_in
       ,values_or_ids    => 'V'
       ,validation_date    => nvl(l_effective_date,trunc(sysdate)) --3171225
       )
  then
    if g_debug then
    hr_utility.set_location(l_proc, 20);
    end if;
--
    -- Flex routine succeeds - fetch relevant ccid
    -- and concatenated segment string
    --
    p_ccid                := fnd_flex_keyval.combination_id;
    p_concat_segments_out := fnd_flex_keyval.concatenated_values;
    --
    if g_debug then
     hr_utility.set_location(l_proc, 30);
    end if;
else
    if g_debug then
     hr_utility.set_location(l_proc, 40);
    end if;
--
     -- Raise or trap the AOL error
     --
     if g_debug then
      hr_utility.set_location(l_proc, 41);
     end if;
--
     -- The FND FLEX KEYVAL package makes a call to FND MESSAGE
     -- get encoded
     hr_message.parse_encoded(p_encoded_error =>
                               FND_FLEX_KEYVAL.encoded_error_message);
     if g_debug then
      hr_utility.set_location(l_proc, 42);
     end if;
--
     if ((hr_message.last_message_app = 'FND') and
         (hr_message.last_message_name = 'FLEX-VALUE NOT FOUND')) then
     --
     if g_debug then
      hr_utility.set_location(l_proc, 44);
     end if;
--
     --  In this case, there was an invalid segment, or context.
     --  We must allow for the possibility that the context value
     --  was not valid.
     --  Should trap this error
     --  and replace with a more user friendly message
     --  First, work out which segment is in error, and change the
     --  error message to indicate which of these segments is
     --  is incorrect.
     --
         error_seg := FND_FLEX_KEYVAL.error_segment;
         find_error_segment(p_appl_short_name => p_appl_short_name,
                            p_flex_code => p_flex_code,
                            p_flex_num    => p_flex_num,
                            p_error_seg_num   => error_seg,
                            p_application_col_name => app_col_name,
                            p_form_left_prompt => l_flex_seg_error_prompt,
                            p_table_name       => l_table_name
                            );
     if g_debug then
       hr_utility.set_location(l_proc, 46);
     end if;
          value := hr_message.get_token_value(p_token_name => 'VALUE');
     --
     --  Now have the additional error information, raise a different error
     --  using this information.
     --
         fnd_message.set_name('PER','HR_FLEX_VALUE_INVALID');
         fnd_message.set_token('COLUMN',app_col_name);
         fnd_message.set_token('VALUE',value);
         fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
         hr_multi_message.add
           (p_associated_column1 => l_table_name || '.' || app_col_name);
     elsif hr_message.last_message_app = 'FND' and
           hr_message.last_message_name = 'FLEX-NULL SEGMENT' then
       if g_debug then
         hr_utility.set_location(l_proc, 50);
       end if;
--
       -- Work out which segment is in error. Replace the error message
       -- by a more useful one.
       --
       error_seg := FND_FLEX_KEYVAL.error_segment;
       find_error_segment
       (p_appl_short_name      => p_appl_short_name
       ,p_flex_code            => p_flex_code
       ,p_flex_num             => p_flex_num
       ,p_error_seg_num        => error_seg
       ,p_application_col_name => app_col_name
       ,p_form_left_prompt     => l_flex_seg_error_prompt
       ,p_table_name           => l_table_name
       );
       --
       -- Raise the  alternative error.
       --
       if g_debug then
         hr_utility.set_location(l_proc, 55);
       end if;
       fnd_message.set_name('PER','HR_FLEX_VALUE_MISSING');
       fnd_message.set_token('COLUMN',app_col_name);
       fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
       hr_multi_message.add
         (p_associated_column1 => l_table_name || '.' || app_col_name);
     else
       --
       -- Some other non-expected error, simply raise the error in the
       -- previous fashion.
       --
       if g_debug then
         hr_utility.set_location(l_proc, 60);
       end if;
--
       -- Raise the AOL error
       --
      fnd_message.set_name('FND',hr_message.last_message_name);
      fnd_message.raise_error;
      --
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving '||l_proc, 100);
  end if;
--
end check_segment_combination;
--
-- ----------------------------------------------------------------------------
-- |------------------------ Check_segment_combination -----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Parameter interface Version
--
--   This private procedure ensures that either a new flex combination is
--   created for the key flexfield selected or the relevant code combination
--   is found if the combination already exists.
--
-- Prerequisites:
--   A valid application short name
--   A valid id_flex_code (flex structure code)
--   A valid id_flex_num  (flex structure number)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_appl_short_name     Yes  varchar2 The application shortname for the
--                                       application a key flexfield belongs
--                                       to (i.e. PER/PAY).
--   p_flex_num            Yes  number   The id_flex_num of the relevant key
--                                       flexfield structure
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--   p_parameter           Yes  PL*SQL   The PLSQL table which stores the
--                              table    segment array for the flex segment
--                                       values
--   p_too_many_segs       Yes  boolean  Used to verify whether too many segments
--                                       have been passed in through the
--                                       parameter interface
--
--
-- Post Success:
--   The procedure create a new code combination and passes back the new
--   CCID or finds an existing code combination and passes back the CCID.
--
-- Post Failure:
--   The process raises an AOL error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure check_segment_combination
  (p_appl_short_name     in     fnd_application.application_short_name%TYPE
  ,p_flex_num            in     number
  ,p_flex_code           in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_parameter           in     fnd_flex_ext.SegmentArray
  ,p_too_many_segs       in     boolean
  ,p_ccid                   out nocopy number
  ,p_concat_segments_out    out nocopy varchar2
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc              varchar2(72);
  --
  l_seg_plsql_row_num binary_integer;
  l_parameter_temp    fnd_flex_ext.SegmentArray;
  l_delimiter         varchar2(1);
  l_concat_string     varchar2(2000);
  l_segment_value     varchar2(2000);
  l_first_seg         boolean;
  error_seg           number;
  app_col_name        fnd_columns.column_name%TYPE;
  l_flex_seg_error_prompt  fnd_id_flex_segments_vl.form_left_prompt%type;
  value               VARCHAR2(2000); -- Note: PL/SQL value errors may occur if
                                    -- we increase the db size of key flex
                                    -- segments.
  l_table_name        VARCHAR2(60);
  -- start for fix of 3171225
  l_effective_date   date;

  cursor date_set is
     select EFFECTIVE_DATE from fnd_sessions
     where session_id=userenv('sessionid');
  -- end for fix of 3171225
  --
  -- Bug 3897294 Starts
  l_no_segments number;
  l_application_id number;
  -- Bug 3897294 Ends
begin
  if g_debug then
     l_proc := 'check_segment_combination';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
--
  -- Calls function to return delimeter for relevant flexfield
  -- structure
  --
  l_delimiter := fnd_flex_ext.get_delimiter
                   (p_appl_short_name
                   ,p_flex_code
                   ,p_flex_num
                   );
  --
  -- Bug 3897294 Starts
  l_application_id := get_application_id( p_appl_short_name => p_appl_short_name );
  --
  l_no_segments := get_no_segments
                     (p_flex_num
                     ,p_flex_code
                     ,l_application_id
                     );
  -- Bug 3897294 Ends
--
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
--
  -- Convert segment array structure into concatenated string
  --
  --   Check if any segment values are populated
  --
  if p_parameter.count > 0 then
    if g_debug then
     hr_utility.set_location(l_proc, 30);
    end if;

    -- Initialize the concatenated sring
    --
    l_concat_string := null;
    l_first_seg := TRUE;
    --
    -- Loop through all segment values
    --
    for l_seg_plsql_row_num in p_parameter.first .. p_parameter.last loop
      --
      -- Assign the segment value to a local
      --
      l_segment_value := p_parameter(l_seg_plsql_row_num);
      --
      if g_debug then
        hr_utility.set_location('This is the seg val'||length(l_segment_value),100);
      end if;
      if l_segment_value <> hr_api.g_varchar2
        or l_segment_value is null
      then
        --
        -- Check if the segment value is not set
        --
        if l_segment_value is null then

          -- Set segment value to null indicator
          --
          l_segment_value := '';
          --
        end if;

/* Fix For Bug # 8357649 Starts*/

l_segment_value := replace(l_segment_value,g_delimiter_escape,g_delimiter_escape||g_delimiter_escape);

/* Fix For Bug # 8357649 Ends*/

        --
        -- Check for the first segment value
        --
-- 3897294 Starts
       --
        -- Check for the first segment value
        --
        if l_first_seg then
           If l_no_segments = 1 then
              l_concat_string := l_segment_value;
           else
              l_concat_string := replace(l_segment_value,l_delimiter,
                            g_delimiter_escape||l_delimiter);
           end if;
          l_first_seg := FALSE;
          --
        else
              l_concat_string := l_concat_string||l_delimiter||
	                     replace(l_segment_value,l_delimiter,
			             g_delimiter_escape||l_delimiter);
        end if;
-- 3897294 Ends
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 45);
  end if;
--
  -- Check for too many segments in segment structure.
  -- If too many exist, force AOL to produce appropriate
  -- error message
  --
  if p_too_many_segs then

    l_concat_string := l_concat_string||l_delimiter;
  end if;
  --
  -- Stop overflow of hr_utility by restricting using substr.
  -- WWBUG 1812106.
  --
  if g_debug then
     hr_utility.set_location('=>'||substr(l_concat_string,1,80),48);
  end if;

  if g_debug then
     hr_utility.set_location(l_proc,50);
  end if;
--
--3171225 start
  l_effective_date:=to_date(null);
  open date_set;
  fetch date_set into l_effective_date;
  if date_set%found then
    if g_debug then
     hr_utility.set_location(l_proc,53);
    end if;
    close date_set;
  else
    if g_debug then
     hr_utility.set_location(l_proc,55);
    end if;
    close date_set;
    l_effective_date := trunc(sysdate);
  end if;
--3171225 end
  -- Call AOL flex validation routine
  --;

  if fnd_flex_keyval.validate_segs
       (operation        => 'CREATE_COMBINATION'
       ,appl_short_name  => p_appl_short_name
       ,key_flex_code    => p_flex_code
       ,structure_number => p_flex_num
       ,concat_segments  => l_concat_string
       ,values_or_ids    => 'I'
       ,validation_date    => nvl(l_effective_date,trunc(sysdate)) --3171225
       )
  then
    if g_debug then
     hr_utility.set_location(l_proc, 60);
    end if;
--
    -- Flex routine succeeds - fetch relevant ccid
    -- and concatenated segment string
    --
    p_ccid                := fnd_flex_keyval.combination_id;
    p_concat_segments_out := fnd_flex_keyval.concatenated_values;
    --
    if g_debug then
     hr_utility.set_location(l_proc, 70);
    end if;
--
  else
    if g_debug then
     hr_utility.set_location(l_proc, 80);
     end if;
--
     -- Raise or trap the AOL error
     --
     if g_debug then
     hr_utility.set_location(l_proc, 81);
     end if;
--
     -- The FND FLEX KEYVAL package makes a call to FND MESSAGE
     -- get encoded
     hr_message.parse_encoded(p_encoded_error =>
                               FND_FLEX_KEYVAL.encoded_error_message);
     if g_debug then
     hr_utility.set_location(l_proc, 82);
     end if;
--
     if ((hr_message.last_message_app = 'FND') and
         (hr_message.last_message_name = 'FLEX-VALUE NOT FOUND')) then
     --
     if g_debug then
     hr_utility.set_location(l_proc, 84);
     end if;
--
     --  In this case, there was an invalid segment, or context.
     --  We must allow for the possibility that the context value
     --  was not valid.
     --  Should trap this error
     --  and replace with a more user friendly message
     --  First, work out which segment is in error, and change the
     --  error message to indicate which of these segments is
     --  is incorrect.
     --
         error_seg := FND_FLEX_KEYVAL.error_segment;
         find_error_segment(p_appl_short_name => p_appl_short_name,
                            p_flex_code => p_flex_code,
                            p_flex_num    => p_flex_num,
                            p_error_seg_num   => error_seg,
                            p_application_col_name => app_col_name,
                            p_form_left_prompt => l_flex_seg_error_prompt,
                            p_table_name => l_table_name
                            );
     if g_debug then
      hr_utility.set_location(l_proc, 86);
     end if;
     --
     value := hr_message.get_token_value(p_token_name => 'VALUE');
     --
     --  Now have the additional error information, raise a different error
     --  using this information.
     --
         fnd_message.set_name('PER','HR_FLEX_VALUE_INVALID');
         fnd_message.set_token('COLUMN',app_col_name);
         fnd_message.set_token('VALUE',value);
         fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
         hr_multi_message.add
           (p_associated_column1 => l_table_name || '.' || app_col_name);
     elsif hr_message.last_message_app = 'FND' and
           hr_message.last_message_name = 'FLEX-NULL SEGMENT' then
       if g_debug then
         hr_utility.set_location(l_proc, 90);
       end if;
--
       -- Work out which segment is in error. Replace the error message
       -- by a more useful one.
       --
       error_seg := FND_FLEX_KEYVAL.error_segment;
       find_error_segment
       (p_appl_short_name      => p_appl_short_name
       ,p_flex_code            => p_flex_code
       ,p_flex_num             => p_flex_num
       ,p_error_seg_num        => error_seg
       ,p_application_col_name => app_col_name
       ,p_form_left_prompt     => l_flex_seg_error_prompt
       ,p_table_name           => l_table_name
       );
       --
       -- Raise the  alternative error.
       --
       if g_debug then
        hr_utility.set_location(l_proc, 95);
       end if;
       fnd_message.set_name('PER','HR_FLEX_VALUE_MISSING');
       fnd_message.set_token('COLUMN',app_col_name);
       fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
       hr_multi_message.add
         (p_associated_column1 => l_table_name || '.' || app_col_name);
     else
     --
     -- Some other non-expected error, simply raise the error in the
     -- previous fashion.
     --

    -- Raise the AOL error
    --
     if g_debug then
     hr_utility.set_location(l_proc, 100);
     end if;
     fnd_message.set_name('FND',hr_message.last_message_name);
     fnd_message.raise_error;
    --
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 200);
  end if;
--
   end check_segment_combination;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- sort_segment_order --------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure sorts the flexfield segments into DISPLAY order
--   for the relevant flexfield structure definition.
--
-- Prerequisites:
--   A valid id_flex_code (flex structure code)
--   A valid id_flex_num  (flex structure number)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_segment1 - 30       Yes  varchar2 Flex segments for 'Bank Details'
--                                       in SEGMENT order
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--   p_flex_num            Yes  number   The id_flex_num of the 'Bank Details'
--                                       flexfield structure
--
-- Post Success:
--   The procedure creates a PLSQL table containing a segment array of
--   flex segment values in DISPLAY order.
--
-- Post Failure:
--   The process raises an AOL error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure sort_segment_order
  (p_segment1                      in     varchar2 default null
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
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
  -- Bug fix 2148839. Application id passed.
  ,p_application_id		   in 	  number
  ,p_parameter                     out nocopy    fnd_flex_ext.SegmentArray
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  --
  l_parameter_temp      fnd_flex_ext.SegmentArray;
  l_parameter_sorted    fnd_flex_ext.SegmentArray;
  l_disp_no             number;
  l_seg_no              number;
  l_seg_count           number := 0;

  -- Bug fix 2148839.
  Type NumberArray is table of number index by binary_integer;
  l_seg_no_array NumberArray;
  l_disp_no_array NumberArray;
  --
  -- Bug fix 2148339.
  -- Application id condition added to cursor to increase the
  -- performance.

  cursor get_pop_segs is
    select substr(application_column_name,8,2)
    from   fnd_id_flex_segments_vl
    where  id_flex_code = p_flex_code
    and    id_flex_num  = p_flex_num
    and    enabled_flag='Y'
    and    application_id = p_application_id
    order by to_number(substr(application_column_name,8,2));
  --
  cursor get_seg_order is
    select substr(application_column_name,8,2)
    from   fnd_id_flex_segments_vl
    where  id_flex_code = p_flex_code
    and    id_flex_num  = p_flex_num
    and    enabled_flag = 'Y'
    and    application_id = p_application_id
    order by segment_num;
  --
begin

  if g_debug then
     l_proc := 'sort_segment_order';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Assign all segments values to a temporary PLSQL
  -- table or Segment Array
  --
  l_parameter_temp(1)  := p_segment1;
  l_parameter_temp(2)  := p_segment2;
  l_parameter_temp(3)  := p_segment3;
  l_parameter_temp(4)  := p_segment4;
  l_parameter_temp(5)  := p_segment5;
  l_parameter_temp(6)  := p_segment6;
  l_parameter_temp(7)  := p_segment7;
  l_parameter_temp(8)  := p_segment8;
  l_parameter_temp(9)  := p_segment9;
  l_parameter_temp(10) := p_segment10;
  l_parameter_temp(11) := p_segment11;
  l_parameter_temp(12) := p_segment12;
  l_parameter_temp(13) := p_segment13;
  l_parameter_temp(14) := p_segment14;
  l_parameter_temp(15) := p_segment15;
  l_parameter_temp(16) := p_segment16;
  l_parameter_temp(17) := p_segment17;
  l_parameter_temp(18) := p_segment18;
  l_parameter_temp(19) := p_segment19;
  l_parameter_temp(20) := p_segment20;
  l_parameter_temp(21) := p_segment21;
  l_parameter_temp(22) := p_segment22;
  l_parameter_temp(23) := p_segment23;
  l_parameter_temp(24) := p_segment24;
  l_parameter_temp(25) := p_segment25;
  l_parameter_temp(26) := p_segment26;
  l_parameter_temp(27) := p_segment27;
  l_parameter_temp(28) := p_segment28;
  l_parameter_temp(29) := p_segment29;
  l_parameter_temp(30) := p_segment30;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
   --
  -- Check if any segments exist
  --
  if l_parameter_temp.count > 0 then
    --
    -- Create sorted segment array (l_parameter_sorted)
    --
    -- Initailize l_parameter_sorted to hr_api.g_varchar2 to
    -- ensure that no empty cells exist in the segment array
    --
    for i in 1..30
    loop
       l_parameter_sorted(i) := hr_api.g_varchar2;
    end loop;
    if g_debug then
     hr_utility.set_location(l_proc, 30);
    end if;
    --
    -- Populate SORTED segment array
    -- Bug fix 2148839
    -- Bulk collect used to improve performance.
    open get_pop_segs;
    fetch get_pop_segs  BULK COLLECT into l_seg_no_array;

    open get_seg_order;
    fetch get_seg_order BULK COLLECT into l_disp_no_array;

    for j in 1..l_seg_no_array.count
    loop
      -- fetch get_seg_order into l_disp_no; -- The list of column order required by AOL
      -- fetch get_pop_segs  into l_seg_no;  -- A list of segments in column order
      -- exit when get_pop_segs%NOTFOUND;
         --
         -- Pass user defined segment values into sorted
         -- segment array
         --
         l_parameter_sorted(l_seg_no_array(j)) := l_parameter_temp(l_disp_no_array(j));
         l_seg_count := l_seg_count + 1;
         --
    end loop;
    close get_seg_order;
    close get_pop_segs;
    if g_debug then
     hr_utility.set_location(l_proc, 40);
    end if;
    --
    -- Verify whether sorted array has been created
    --
    if l_seg_count = 0 then
      --
      -- Error in creation
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','40');
      hr_utility.raise_error;
      --
    end if;
    if g_debug then
     hr_utility.set_location(l_proc, 50);
    end if;
    --
    -- Pass back sorted segment array to calling procedure
    --
    p_parameter := l_parameter_sorted;
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 60);
  end if;
end sort_segment_order;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- check_pop_segments --------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private function checks that the user does not pass in values for
--   segments that do not exist in the relevant flexfield structure. If too
--   many segments have been passed via the parameter interface the function
--   sets too_many_segments to TRUE otherwise FALSE is returned.
--
--   This function is only called when using the parameter interface.
--
-- Prerequisites:
--   A valid id_flex_code (flex structure code)
--   A valid id_flex_num  (flex structure number)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_parameter           Yes  PL*SQL   Flex segments for the key flexfield
--                              table    stored in a PL*SQL table structure
--   p_flex_num            Yes  number   The structure number for the relevant
--                                       key flexfield.
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--
-- Post Success:
--   N/A
--
-- Post Failure:
--   N/A
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
--
function check_pop_segments
  (p_parameter                     in     fnd_flex_ext.SegmentArray
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
  -- Bug fix 2148839.parameter p_application_id added.
  ,p_application_id 		   in     number
  ) RETURN boolean
is
  --
  l_proc               varchar2(72);
  --
  l_parameter_temp     fnd_flex_ext.SegmentArray;
  l_no_segments        number;
  l_no_pop_segments    number := 0;
  --
begin
  if g_debug then
     l_proc := 'check_pop_segments';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Fetch number of enabled segments in flex structure
  --
  l_no_segments := get_no_segments
                     (p_flex_num
                     ,p_flex_code
		     ,p_application_id
                     );
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Put segment values into a PL*SQL table
  --
  l_parameter_temp := p_parameter;
  --
  -- Loop for number of segments on flex combination table
  --
  for i in 1..30
  loop
     if l_parameter_temp(i) <> hr_api.g_varchar2 then
        --
        -- Increase count of populated segments
        --
        l_no_pop_segments := l_no_pop_segments + 1;
        --
     end if;
  end loop;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  if l_no_pop_segments > l_no_segments then
    --
     -- Number of populated segments exceeds
     -- number of segments in relevant flexfield structure
     --
     return TRUE;
  else
     --
     -- Correct number of segments in structure
     --
     return FALSE;
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 40);
  end if;
end check_pop_segments;
-----------------------------------------------------------------------------
-- ignore validation procedures using varry of flexcodes to ignore.
-------------------------------------------------------------------------------
-- create it
-------------------------------------------------------------------------------
--
procedure create_ignore_kf_validation(p_rec in l_ignore_kfcode_varray) is
l_proc varchar2(72);
begin
  g_debug := hr_utility.debug_enabled;
   if g_debug then
     l_proc :=  'create_ignore_kf_validation';
     hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   if p_rec.count <> 0
   then
      g_kfcode_structure := p_rec;
   end if;
   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
End create_ignore_kf_validation;
--
-- user calls a population script to populate this array
----------------------------------------------------------------------------
--  check it
----------------------------------------------------------------------------
function check_ignore_varray(p_structure in varchar2) return boolean is
l_proc varchar2(72);
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
     l_proc :=  'check_ignore_varray';
     hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   if g_kfcode_structure.count <> 0
   then
      for l_count in g_kfcode_structure.first..g_kfcode_structure.last
      loop
         if g_kfcode_structure(l_count) = p_structure
         then
            return true;
         end if;
      end loop;
   end if;
   return false;
   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
end;
--
----------------------------------------------------------------------------
-- delete it
----------------------------------------------------------------------------
procedure remove_ignore_kf_validation is
l_proc varchar2(72);
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
     l_proc  := 'remove_ignore_kf_validation';
     hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   g_kfcode_structure.delete;
   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------ ins_or_sel_keyflex_comb -------------------------|
-- ----------------------------------------------------------------------------
--
procedure ins_or_sel_keyflex_comb
  (p_appl_short_name               in     fnd_application.application_short_name%TYPE
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
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
  ,p_concat_segments_in            in     varchar2 default null
  ,p_ccid                          out nocopy    number
  ,p_concat_segments_out           out nocopy    varchar2
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := 'ins_or_sel_keyflex_comb';
  --
  l_parameter_sorted    fnd_flex_ext.SegmentArray;
  l_parameter_temp      fnd_flex_ext.SegmentArray;
  l_too_many_segs       boolean default FALSE;
  --
  l_flex_code varchar2(30) := NULL;
  -- Bug fix 2148839.
  l_application_id 	number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Set up KF session mode
  --
  fnd_flex_key_api.set_session_mode('customer_data');
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'appl_short_name'
    ,p_argument_value => p_appl_short_name
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'flex_code'
    ,p_argument_value => p_flex_code
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'flex_num'
    ,p_argument_value => p_flex_num
    );
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  --  2252580 ignore key flex validation if flexcode exists in varray:
  --
  l_flex_code := p_flex_code;
  --
  if check_ignore_varray(l_flex_code)
  then
     if g_debug then
      hr_utility.set_location(l_proc, 25);
     end if;
      -- 2252580 no validation required, exit procedure
     return;
  else
     -- 2252580 go ahead and validate if flex code is not in varray.
     --
     -- Check to see whether key flex segments as individual parameters
     -- have been passed in or a concatenated string of segments
     --
     if p_concat_segments_in is null then
       if g_debug then
        hr_utility.set_location(l_proc, 30);
       end if;
       -- Bug fix 2148839.
       -- function call to get application id.
       l_application_id := get_application_id( p_appl_short_name => p_appl_short_name );
       --
       -- Call sort_segment_order to format segment interface
       -- into segment DISPLAY order
       --
       sort_segment_order
         (p_segment1    =>   p_segment1
         ,p_segment2    =>   p_segment2
         ,p_segment3    =>   p_segment3
         ,p_segment4    =>   p_segment4
         ,p_segment5    =>   p_segment5
         ,p_segment6    =>   p_segment6
         ,p_segment7    =>   p_segment7
         ,p_segment8    =>   p_segment8
         ,p_segment9    =>   p_segment9
         ,p_segment10   =>   p_segment10
         ,p_segment11   =>   p_segment11
         ,p_segment12   =>   p_segment12
         ,p_segment13   =>   p_segment13
         ,p_segment14   =>   p_segment14
         ,p_segment15   =>   p_segment15
         ,p_segment16   =>   p_segment16
         ,p_segment17   =>   p_segment17
         ,p_segment18   =>   p_segment18
         ,p_segment19   =>   p_segment19
         ,p_segment20   =>   p_segment20
         ,p_segment21   =>   p_segment21
         ,p_segment22   =>   p_segment22
         ,p_segment23   =>   p_segment23
         ,p_segment24   =>   p_segment24
         ,p_segment25   =>   p_segment25
         ,p_segment26   =>   p_segment26
         ,p_segment27   =>   p_segment27
         ,p_segment28   =>   p_segment28
         ,p_segment29   =>   p_segment29
         ,p_segment30   =>   p_segment30
         ,p_flex_num    =>   p_flex_num
         ,p_flex_code   =>   p_flex_code
	 -- bug fix 2148839.
	 -- Application id is paased to improve performance.
         ,p_application_id => l_application_id
         ,p_parameter   =>   l_parameter_sorted
         );
       if g_debug then
        hr_utility.set_location(l_proc, 40);
       end if;
       --
       -- Verify that number of populated segments
       -- passed in does exceed number of segments in
       -- flexfield structure
       --
       l_parameter_temp(1)  := p_segment1;
       l_parameter_temp(2)  := p_segment2;
       l_parameter_temp(3)  := p_segment3;
       l_parameter_temp(4)  := p_segment4;
       l_parameter_temp(5)  := p_segment5;
       l_parameter_temp(6)  := p_segment6;
       l_parameter_temp(7)  := p_segment7;
       l_parameter_temp(8)  := p_segment8;
       l_parameter_temp(9)  := p_segment9;
       l_parameter_temp(10) := p_segment10;
       l_parameter_temp(11) := p_segment11;
       l_parameter_temp(12) := p_segment12;
       l_parameter_temp(13) := p_segment13;
       l_parameter_temp(14) := p_segment14;
       l_parameter_temp(15) := p_segment15;
       l_parameter_temp(16) := p_segment16;
       l_parameter_temp(17) := p_segment17;
       l_parameter_temp(18) := p_segment18;
       l_parameter_temp(19) := p_segment19;
       l_parameter_temp(20) := p_segment20;
       l_parameter_temp(21) := p_segment21;
       l_parameter_temp(22) := p_segment22;
       l_parameter_temp(23) := p_segment23;
       l_parameter_temp(24) := p_segment24;
       l_parameter_temp(25) := p_segment25;
       l_parameter_temp(26) := p_segment26;
       l_parameter_temp(27) := p_segment27;
       l_parameter_temp(28) := p_segment28;
       l_parameter_temp(29) := p_segment29;
       l_parameter_temp(30) := p_segment30;
       --
       if g_debug then
         hr_utility.set_location(l_proc, 50);
       end if;
       --
       l_too_many_segs := check_pop_segments
                            (p_parameter   =>   l_parameter_temp
                            ,p_flex_code   =>   p_flex_code
                            ,p_flex_num    =>   p_flex_num
			    -- Bug fix 2148839.
                            ,p_application_id => l_application_id
                            );
       --
       if g_debug then
        hr_utility.set_location(l_proc, 60);
       end if;
       --
       -- Call Wrapper flex handler to bring back CCID value
       --
       check_segment_combination
         (p_flex_num            =>  p_flex_num
         ,p_flex_code           =>  p_flex_code
         ,p_appl_short_name     =>  p_appl_short_name
         ,p_parameter           =>  l_parameter_sorted
         ,p_too_many_segs       =>  l_too_many_segs
         ,p_ccid                =>  p_ccid
         ,p_concat_segments_out =>  p_concat_segments_out
         );
       --
       if g_debug then
        hr_utility.set_location(l_proc, 70);
       end if;
      --
     else
       --
       if g_debug then
        hr_utility.set_location(l_proc, 80);
       end if;
        --
       check_segment_combination
         (p_flex_num            =>  p_flex_num
         ,p_flex_code           =>  p_flex_code
         ,p_appl_short_name     =>  p_appl_short_name
         ,p_concat_segments_in  =>  p_concat_segments_in
         ,p_ccid                =>  p_ccid
         ,p_concat_segments_out =>  p_concat_segments_out
         );
       --
      if g_debug then
        hr_utility.set_location(l_proc, 90);
      end if;
      --
     end if;
     --
  end if; -- end if keyflex code exists in ignore varray
  if g_debug then
    hr_utility.set_location('Leaving '|| l_proc, 100);
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add then
       if g_debug then
         hr_utility.set_location(l_proc, 100);
       end if;
    raise;
    end if;
    if g_debug then
     hr_utility.set_location(l_proc, 110);
    end if;
end ins_or_sel_keyflex_comb;
--
-- ----------------------------------------------------------------------------
-- |------------------------- upd_or_sel_keyflex_comb ------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd_or_sel_keyflex_comb
  (p_appl_short_name               in     fnd_application.application_short_name%TYPE
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
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
  ,p_concat_segments_in            in     varchar2 default null
  ,p_ccid                          in out nocopy number
  ,p_concat_segments_out           out nocopy    varchar2
  )
is
  --  Local Variables for the upd_or_sel_kflex_comb
  --  when calling ins_or_sel_kflex_comb, This allows
  --  this call to be made and changes the default values to null values
 l_segment1         varchar2(150);
 l_segment2         varchar2(150);
 l_segment3         varchar2(150);
 l_segment4         varchar2(150);
 l_segment5         varchar2(150);
 l_segment6         varchar2(150);
 l_segment7         varchar2(150);
 l_segment8         varchar2(150);
 l_segment9         varchar2(150);
 l_segment10        varchar2(150);
 l_segment11        varchar2(150);
 l_segment12        varchar2(150);
 l_segment13        varchar2(150);
 l_segment14        varchar2(150);
 l_segment15        varchar2(150);
 l_segment16        varchar2(150);
 l_segment17        varchar2(150);
 l_segment18        varchar2(150);
 l_segment19        varchar2(150);
 l_segment20        varchar2(150);
 l_segment21        varchar2(150);
 l_segment22        varchar2(150);
 l_segment23        varchar2(150);
 l_segment24        varchar2(150);
 l_segment25        varchar2(150);
 l_segment26        varchar2(150);
 l_segment27        varchar2(150);
 l_segment28        varchar2(150);
 l_segment29        varchar2(150);
 l_segment30        varchar2(150);
 l_concat_segments_in  varchar2(700);
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := 'upd_or_sel_keyflex_comb';
  --
  l_flex_code varchar2(30) := NULL;  -- 2252580
  --
  array_counter        number;
  l_no_segments        number;
  l_seg_num            number;
  l_too_many_segs      boolean default FALSE;
  l_concat_string      varchar2(2000);
  l_delimiter          varchar2(1);
  --
  -- l_parameter_temp
  --
  -- Holds complete seg array containing all new
  -- values passed in by the user plus the values
  -- retrieved from the exisiting combination
  -- details stored on the database. This array is
  -- different to l_parameter_updated in that it
  -- will store ALL the values passed in by the user,
  -- even if they are linked to segments which are not
  -- set for the KF structure
  --
  l_parameter_temp     fnd_flex_ext.SegmentArray;
  --
  -- Holds original inserted seg array
  --
  l_parameter_original fnd_flex_ext.SegmentArray;
  --
  -- holds new seg array containing updated
  -- segment details
  --
  l_parameter_new      fnd_flex_ext.SegmentArray;
  --
  -- holds complete seg array ready to send
  -- to AOL Validation
  --
  l_parameter_updated  fnd_flex_ext.SegmentArray;
  -- Bug fix 2148839.
  l_application_id number;
  --
  -- 1141260 : Corrected order by of following cursor.
  cursor get_seg_num is
    select substr(application_column_name,8,2)
    from   fnd_id_flex_segments_vl
    where  id_flex_code = p_flex_code
    and    id_flex_num  = p_flex_num
    and    enabled_flag='Y'
    and    application_id = l_application_id  --3456567 to avoid FTS
    order by to_number(substr(application_column_name,8,2));
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
   --
  -- Set up KF session mode
  --
  fnd_flex_key_api.set_session_mode('customer_data');
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'appl_short_name'
    ,p_argument_value => p_appl_short_name
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'flex_code'
    ,p_argument_value => p_flex_code
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'flex_num'
    ,p_argument_value => p_flex_num
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  --
  --  2252580  ignore key flex validation if flexcode exists in varray:
  --
  l_flex_code := p_flex_code;
  --
  if check_ignore_varray(l_flex_code)
  then
     if g_debug then
     hr_utility.set_location(l_proc, 25);
     end if;
     -- no validation required, exit procedure
     return;
  else
     -- flex code was not in varray so go ahead and validate procedure
     --
     -- Check to see whether key flex segments as individual parameters
     -- have been passed in or a concatenated string of segments
     --
     if p_ccid is not null then
       if (p_concat_segments_in = hr_api.g_varchar2
         or p_concat_segments_in is null)
       then
         --
         -- Initialize l_parameter_temp for use within call to
         -- check_pop_segs procedure. Segment array is populated
         -- with updated segment values prior to call.
         --
         l_parameter_temp(1)  := p_segment1;
         l_parameter_temp(2)  := p_segment2;
         l_parameter_temp(3)  := p_segment3;
         l_parameter_temp(4)  := p_segment4;
         l_parameter_temp(5)  := p_segment5;
         l_parameter_temp(6)  := p_segment6;
         l_parameter_temp(7)  := p_segment7;
         l_parameter_temp(8)  := p_segment8;
         l_parameter_temp(9)  := p_segment9;
         l_parameter_temp(10) := p_segment10;
         l_parameter_temp(11) := p_segment11;
         l_parameter_temp(12) := p_segment12;
         l_parameter_temp(13) := p_segment13;
         l_parameter_temp(14) := p_segment14;
         l_parameter_temp(15) := p_segment15;
         l_parameter_temp(16) := p_segment16;
         l_parameter_temp(17) := p_segment17;
         l_parameter_temp(18) := p_segment18;
         l_parameter_temp(19) := p_segment19;
         l_parameter_temp(20) := p_segment20;
         l_parameter_temp(21) := p_segment21;
         l_parameter_temp(22) := p_segment22;
         l_parameter_temp(23) := p_segment23;
         l_parameter_temp(24) := p_segment24;
         l_parameter_temp(25) := p_segment25;
         l_parameter_temp(26) := p_segment26;
         l_parameter_temp(27) := p_segment27;
         l_parameter_temp(28) := p_segment28;
         l_parameter_temp(29) := p_segment29;
         l_parameter_temp(30) := p_segment30;
         --
         if g_debug then
           hr_utility.set_location(l_proc, 30);
         end if;
         -- Bug fix 2148839.
         -- function call to get application id.
         l_application_id := get_application_id( p_appl_short_name => p_appl_short_name );
         --
         -- Call sort_segment_order to format segment interface
         -- into segment DISPLAY order
         --
         sort_segment_order
           (p_segment1    =>   p_segment1
           ,p_segment2    =>   p_segment2
           ,p_segment3    =>   p_segment3
           ,p_segment4    =>   p_segment4
           ,p_segment5    =>   p_segment5
           ,p_segment6    =>   p_segment6
           ,p_segment7    =>   p_segment7
           ,p_segment8    =>   p_segment8
           ,p_segment9    =>   p_segment9
           ,p_segment10   =>   p_segment10
           ,p_segment11   =>   p_segment11
           ,p_segment12   =>   p_segment12
           ,p_segment13   =>   p_segment13
           ,p_segment14   =>   p_segment14
           ,p_segment15   =>   p_segment15
           ,p_segment16   =>   p_segment16
           ,p_segment17   =>   p_segment17
           ,p_segment18   =>   p_segment18
           ,p_segment19   =>   p_segment19
           ,p_segment20   =>   p_segment20
           ,p_segment21   =>   p_segment21
           ,p_segment22   =>   p_segment22
           ,p_segment23   =>   p_segment23
           ,p_segment24   =>   p_segment24
           ,p_segment25   =>   p_segment25
           ,p_segment26   =>   p_segment26
           ,p_segment27   =>   p_segment27
           ,p_segment28   =>   p_segment28
           ,p_segment29   =>   p_segment29
           ,p_segment30   =>   p_segment30
           ,p_flex_code   =>   p_flex_code
           ,p_flex_num    =>   p_flex_num
            -- Bug fix 2148839. Application id is passed.
           ,p_application_id => l_application_id
           ,p_parameter   =>   l_parameter_new
           );
         --
         if g_debug then
          hr_utility.set_location(l_proc, 40);
         end if;
         --
         -- Initialize l_parameter_updated so that each cell in
         -- the segment array contains the hr_api.g_varchar2 default
         --
         for i in 1..30
         loop
            l_parameter_updated(i) := hr_api.g_varchar2;
         end loop;
         --
         if g_debug then
          hr_utility.set_location(l_proc, 50);
         end if;
         --
         -- Fetch the existing segment array for the CCID passed in
         --
         if fnd_flex_keyval.validate_ccid
              (appl_short_name  => p_appl_short_name
              ,key_flex_code    => p_flex_code
              ,structure_number => p_flex_num
              ,combination_id   => p_ccid
              )
         then
           if g_debug then
             hr_utility.set_location(l_proc, 60);
           end if;

           -- Retrieve concatenated id segment string
           --
           l_concat_string := fnd_flex_keyval.concatenated_ids;

           -- Retrieve delimiter used in segment structure
           --
           l_delimiter := fnd_flex_keyval.segment_delimiter;

           -- Convert concatenated string returned into a PL*SQL
           -- table segment array
           --
           l_no_segments := fnd_flex_ext.breakup_segments
                              (concatenated_segs  => l_concat_string
                              ,delimiter          => l_delimiter
                              ,segments           => l_parameter_original
                              );
           --
           -- The flexfield has some segments but breakup_segments has not
           -- counted them properly nor has it initialised the
           -- l_parameter_original array
           -- in the situation where the flexfield has one segment defined and
           -- the record currently references the null combination, so get the
           -- correct segment count and also initialise the array to null.
           --
           l_no_segments:=fnd_flex_keyval.segment_count;
           if g_debug then
             hr_utility.set_location(l_proc, 70);
           end if;
           --
           if l_no_segments > 0 and l_parameter_original.count = 0 then
             for i in 1..l_no_segments loop
               l_parameter_original(i) := null;
             end loop;
           end if;
           --
           -- Create PL*SQL table l_parameter_updated with ORIGINAL and UPDATED
           -- key flexfield segment values.
           --
           open get_seg_num;
           array_counter:=1;
           --
           for i in 1..l_no_segments loop
             fetch get_seg_num into l_seg_num;
             exit when get_seg_num%NOTFOUND;
           --
             if l_parameter_new(l_seg_num) = hr_api.g_varchar2 then
               --
               -- Segment value has not changed - reset to old value
               --
             l_parameter_updated(l_seg_num) :=
             l_parameter_original(array_counter);
             l_parameter_temp(l_seg_num) := l_parameter_original(array_counter);
             --
             -- Otherwise set segment to new value
             --
             else
               --
               l_parameter_updated(l_seg_num) := nvl(l_parameter_new(l_seg_num), NULL);
               l_parameter_temp(l_seg_num)    := nvl(l_parameter_new(l_seg_num), NULL);
               --
            end if;
             --
               array_counter:=array_counter+1;

             end loop;
           close get_seg_num;
         else
           fnd_message.raise_error;
         end if;
         --
         if g_debug then
           hr_utility.set_location(l_proc, 80);
         end if;
         --
         -- Verify that number of populated segments passed in does exceed
         -- number of segments in flexfield structure.
         --
         -- Note : This check cannot be performed until the Update segment
         --        array is populated with both existing and updated values
         --        as only then do we have a complete update interface.
         --
         l_too_many_segs := check_pop_segments
                         (p_parameter   =>   l_parameter_temp
                         ,p_flex_code   =>   p_flex_code
                         ,p_flex_num    =>   p_flex_num
			 -- Bug fix 2148839.
			 ,p_application_id => l_application_id
                         );
         --
         if g_debug then
           hr_utility.set_location(l_proc, 90);
         end if;
         --
         -- Call Wrapper flex handler to bring back new CCID value

         check_segment_combination
           (p_appl_short_name     => p_appl_short_name
           ,p_flex_code           => p_flex_code
           ,p_flex_num            => p_flex_num
           ,p_parameter           => l_parameter_updated
           ,p_too_many_segs       => l_too_many_segs
           ,p_ccid                => p_ccid
           ,p_concat_segments_out => p_concat_segments_out
           );
         if g_debug then
          hr_utility.set_location(l_proc, 100);
         end if;
         --
       else
         if g_debug then
           hr_utility.set_location(l_proc, 110);
         end if;
         --
         check_segment_combination
           (p_appl_short_name     => p_appl_short_name
           ,p_flex_code           => p_flex_code
           ,p_flex_num            => p_flex_num
           ,p_concat_segments_in  => p_concat_segments_in
           ,p_ccid                => p_ccid
           ,p_concat_segments_out => p_concat_segments_out
           );
         if g_debug then
          hr_utility.set_location(l_proc, 120);
         end if;
         --
       end if;
     else
       --
       -- No combination ID on update so nothing saved when record as inserted
       -- so although an update to the assignment we are inserting the keyflex
       -- so just call ins_or_sel_keyflex_comb.
       --
      if g_debug then
        hr_utility.set_location(' Seg3 '||p_segment3,101);
      end if;
       --
     if p_segment1 = hr_api.g_varchar2 then
        l_segment1 := null;
      else
        l_segment1 := p_segment1;
      end if;

      if p_segment2 = hr_api.g_varchar2 then
        l_segment2 := null;
      else
        l_segment2 := p_segment2;
      end if;

      if p_segment3 = hr_api.g_varchar2 then
        l_segment3 := null;
      else
        l_segment3 := p_segment3;
      end if;

      if p_segment4 = hr_api.g_varchar2 then
        l_segment4 := null;
      else
        l_segment4 := p_segment4;
      end if;

      if p_segment5 = hr_api.g_varchar2 then
        l_segment5 := null;
      else
        l_segment5 := p_segment5;
      end if;

      if p_segment6 = hr_api.g_varchar2 then
        l_segment6 := null;
      else
        l_segment6 := p_segment6;
      end if;

      if p_segment7 = hr_api.g_varchar2 then
        l_segment7 := null;
      else
        l_segment7 := p_segment7;
      end if;

      if p_segment8 = hr_api.g_varchar2 then
        l_segment8 := null;
      else
        l_segment8 := p_segment8;
      end if;

      if p_segment9 = hr_api.g_varchar2 then
        l_segment9 := null;
      else
        l_segment9 := p_segment9;
      end if;

      if p_segment10 = hr_api.g_varchar2 then
        l_segment10 := null;
      else
        l_segment10 := p_segment10;
      end if;

      if p_segment11 = hr_api.g_varchar2 then
        l_segment11 := null;
      else
        l_segment11 := p_segment11;
      end if;

      if p_segment12 = hr_api.g_varchar2 then
        l_segment12 := null;
      else
        l_segment12 := p_segment12;
      end if;

      if p_segment13 = hr_api.g_varchar2 then
        l_segment13 := null;
      else
        l_segment13 := p_segment13;
      end if;

      if p_segment14 = hr_api.g_varchar2 then
        l_segment14 := null;
      else
        l_segment14 := p_segment14;
      end if;

      if p_segment15 = hr_api.g_varchar2 then
        l_segment15 := null;
      else
        l_segment15 := p_segment15;
      end if;

      if p_segment16 = hr_api.g_varchar2 then
        l_segment16 := null;
      else
        l_segment16 := p_segment16;
      end if;

      if p_segment17 = hr_api.g_varchar2 then
        l_segment17 := null;
      else
        l_segment17 := p_segment17;
      end if;

      if p_segment18 = hr_api.g_varchar2 then
        l_segment18 := null;
      else
        l_segment18 := p_segment18;
      end if;

      if p_segment19 = hr_api.g_varchar2 then
        l_segment19 := null;
      else
        l_segment19 := p_segment19;
      end if;

      if p_segment20 = hr_api.g_varchar2 then
        l_segment20:= null;
      else
        l_segment20 := p_segment20;
      end if;

      if p_segment21 = hr_api.g_varchar2 then
        l_segment21 := null;
      else
        l_segment21 := p_segment21;
      end if;

      if p_segment22 = hr_api.g_varchar2 then
        l_segment22 := null;
      else
        l_segment22 := p_segment22;
      end if;

      if p_segment23 = hr_api.g_varchar2 then
        l_segment23 := null;
      else
        l_segment23 := p_segment23;
      end if;

      if p_segment24 = hr_api.g_varchar2 then
        l_segment24 := null;
      else
        l_segment24 := p_segment24;
      end if;

      if p_segment25 = hr_api.g_varchar2 then
        l_segment25 := null;
      else
        l_segment25 := p_segment25;
      end if;

      if p_segment26 = hr_api.g_varchar2 then
        l_segment26 := null;
      else
        l_segment26 := p_segment26;
      end if;

      if p_segment27 = hr_api.g_varchar2 then
        l_segment27 := null;
      else
        l_segment27 := p_segment27;
      end if;

      if p_segment28  = hr_api.g_varchar2 then
        l_segment28 := null;
      else
        l_segment28 := p_segment28;
      end if;

      if p_segment29 = hr_api.g_varchar2 then
        l_segment29 := null;
      else
        l_segment29 := p_segment29;
      end if;

      if p_segment30 = hr_api.g_varchar2 then
        l_segment30 := null;
      else
        l_segment30 := p_segment30;
      end if;

      if p_concat_segments_in = hr_api.g_varchar2 then
        l_concat_segments_in := null;
      else
        l_concat_segments_in := p_concat_segments_in;
      end if;
      --
      --
      ins_or_sel_keyflex_comb
       (p_appl_short_name             => p_appl_short_name
       ,p_flex_code                   => p_flex_code
       ,p_flex_num                    => p_flex_num
       ,p_segment1                    => l_segment1
       ,p_segment2                    => l_segment2
       ,p_segment3                    => l_segment3
       ,p_segment4                    => l_segment4
       ,p_segment5                    => l_segment5
       ,p_segment6                    => l_segment6
       ,p_segment7                    => l_segment7
       ,p_segment8                    => l_segment8
       ,p_segment9                    => l_segment9
       ,p_segment10                   => l_segment10
       ,p_segment11                   => l_segment11
       ,p_segment12                   => l_segment12
       ,p_segment13                   => l_segment13
       ,p_segment14                   => l_segment14
       ,p_segment15                   => l_segment15
       ,p_segment16                   => l_segment16
       ,p_segment17                   => l_segment17
       ,p_segment18                   => l_segment18
       ,p_segment19                   => l_segment19
       ,p_segment20                   => l_segment20
       ,p_segment21                   => l_segment21
       ,p_segment22                   => l_segment22
       ,p_segment23                   => l_segment23
       ,p_segment24                   => l_segment24
       ,p_segment25                   => l_segment25
       ,p_segment26                   => l_segment26
       ,p_segment27                   => l_segment27
       ,p_segment28                   => l_segment28
       ,p_segment29                   => l_segment29
       ,p_segment30                   => l_segment30
       ,p_concat_segments_in          => l_concat_segments_in
       ,p_ccid                        => p_ccid
       ,p_concat_segments_out         => p_concat_segments_out
       );
    end if;
    --
     if g_debug then
      hr_utility.set_location('Leaving '|| l_proc, 130);
     end if;
    end if; -- if flex code in varray
exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add then
           if g_debug then
            hr_utility.set_location('Leaving '|| l_proc, 140);
           end if;
    raise;
      end if;
      if g_debug then
        hr_utility.set_location('Leaving '|| l_proc, 150);
      end if;
    when others then
      if hr_multi_message.exception_add then
          if g_debug then
            hr_utility.set_location('Leaving '|| l_proc, 160);
          end if;
    fnd_message.raise_error;
      end if;
       if g_debug then
         hr_utility.set_location('Leaving '|| l_proc, 170);
       end if;
    --reset out vaiables
      -- added for NOCOPY compliance
      p_ccid:=null;
      p_concat_segments_out:=null;
end upd_or_sel_keyflex_comb;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------- set_profiles -----------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_profiles
(p_business_group_id in     per_all_assignments_f.business_group_id%type default hr_api.g_number
,p_assignment_id     in     per_all_assignments_f.assignment_id%type     default null
,p_organization_id   in     per_all_assignments_f.organization_id%type   default null
,p_location_id       in     per_all_assignments_f.location_id%type       default null
,p_person_id         in     per_all_assignments_f.person_id%type         default null
) is
  --
  l_proc               varchar2(72):=' hr_kflex_utility.set_profiles ';
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||' set_profiles';
     hr_utility.set_location('Entering '||l_proc,5);
  end if;
  --
  fnd_profile.put('PER_ASSIGNMENT_ID',p_assignment_id);
  if g_debug then
     hr_utility.set_location(l_proc,10);
  end if;
  --
  if nvl(p_business_group_id,-1) <> hr_api.g_number then
    fnd_profile.put('PER_BUSINESS_GROUP_ID',p_business_group_id);
    if g_debug then
     hr_utility.set_location(l_proc,20);
    end if;
  end if;
  --
  fnd_profile.put('PER_ORGANIZATION_ID',p_organization_id);
  if g_debug then
     hr_utility.set_location(l_proc,30);
  end if;
  --
  fnd_profile.put('PER_LOCATION_ID',p_location_id);
  if g_debug then
     hr_utility.set_location(l_proc,40);
  end if;
  --
  fnd_profile.put('PER_PERSON_ID',P_PERSON_ID);
  if g_debug then
     hr_utility.set_location(l_proc,50);
  end if;

  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,100);
  end if;
  --
end set_profiles;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------- set_session_date ---------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_session_date
(p_effective_date        in     date
,p_session_id               out nocopy number
) is
  l_proc               varchar2(72);
  --
  cursor date_set is
  select 1 from fnd_sessions
  where session_id=userenv('sessionid');
  --
  l_dummy number;
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||' set_session_date';
     hr_utility.set_location('Entering '||l_proc,5);
  end if;
  --
  open date_set;
  fetch date_set into l_dummy;
  if date_set%found then
    if g_debug then
     hr_utility.set_location(l_proc,20);
    end if;
    p_session_id:=-1;
  else
    if g_debug then
     hr_utility.set_location(l_proc,30);
    end if;
    dt_fndate.set_effective_date(trunc(p_effective_Date));
    -- insert into fnd_sessions
    -- values
    -- (userenv('sessionid')
    -- ,trunc(p_effective_date));
    p_session_id:=userenv('sessionid');
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,100);
  end if;
  --
end set_session_date;
--
-- ----------------------------------------------------------------------------
-- |------------------------- unset_session_date -----------------------------|
-- ----------------------------------------------------------------------------
--
procedure unset_session_date
(p_session_id            in      number
) is
  l_proc               varchar2(72);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||' unset_session_date';
     hr_utility.set_location('Entering '||l_proc,5);
  end if;
  --
  if nvl(p_session_id,-1)<>-1 then
    if g_debug then
     hr_utility.set_location(l_proc,10);
    end if;
    delete from fnd_sessions
    where session_id=p_session_id;
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,100);
  end if;
  --
end unset_session_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- set_session_language_code--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the language code and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_language_code       Yes  varchar2 the Two digit language code
--
-- Post Success:
-- userenv('LANG') is set to language code
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_language_code
  ( p_language_code      in     fnd_languages.language_code%TYPE
  ) IS
  l_proc               varchar2(72) := g_package||' set_session_language_code';
begin
  set_session_nls_language( pay_core_mls.get_nls_language( p_language_code ) );
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------- set_session_nls_language --------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the nls language and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_nls_language        Yes  varchar2 The nls language (NOT the 2 letter language code)
--
-- Post Success:
-- userev('LANG') is set to language code derived from nls language
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_nls_language
  ( p_nls_language       in     fnd_languages.nls_language%TYPE
  ) IS
  l_proc               varchar2(72) := g_package||' set_session_nls_language';
begin
  -- dbms_session will raise an error is nls_language is invalid
  dbms_session.set_nls('NLS_LANGUAGE', ''''||p_nls_language||'''');       -- Bug #2958520
  fnd_flex_ext.clear_ccid_cache;
exception
  when others then
    hr_utility.set_location('Error in '||l_proc, 99);
    raise;
end;
--
--
end hr_kflex_utility;

/
