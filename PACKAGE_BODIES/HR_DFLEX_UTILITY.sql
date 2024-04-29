--------------------------------------------------------
--  DDL for Package Body HR_DFLEX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DFLEX_UTILITY" as
/* $Header: hrdfutil.pkb 120.1.12000000.1 2007/01/22 14:45:33 appldev ship $ */
--
-- PLSQL table of rows types
--
--   Varchar2 record type
--
Type Var2Rectype      is record
  (col1  varchar2(30)
  ,col2  varchar2(255)
  );
--
Type Var2TabType      is table of Var2Rectype index by binary_integer;
--
--   Package Variables
--
g_package  varchar2(33) := 'hr_dflex_utility.';
g_dfcode_structure l_ignore_dfcode_varray := l_ignore_dfcode_varray();
-- Bug fix 1218702.
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------<     find_error_segment      >-------------------|
-- ----------------------------------------------------------------------------
--
procedure find_error_segment(p_appl_short_name  IN  varchar2,
                             p_flexfield_name   IN  varchar2,
                             p_context_code     IN  varchar2,
                             p_error_seg_num    IN  number,
                             p_application_col_name OUT NOCOPY varchar2,
                             p_form_left_prompt OUT NOCOPY varchar2,
                             p_table_name       OUT NOCOPY varchar2
                            )is
--
-- Cursors
--
cursor c_context_valid(p_appl_short_name in VARCHAR2,
                       p_flexfield_name in VARCHAR2,
                       p_context in VARCHAR2) is
     select 'Y'
       from FND_APPLICATION a,
            FND_DESCR_FLEX_CONTEXTS dfc
      where a.application_short_name = p_appl_short_name
        and a.application_id = dfc.application_id
        and dfc.DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
        and dfc.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context;
--
-- Local Variables
--
-- Procedure Name
l_proc              varchar2(72) := g_package||'find_error_segment';
-- Structure for holding the flexfield information from AOL
l_flexfield         fnd_dflex.dflex_r;
-- Structure for holding information about the flexfield from AOL
l_flexinfo          fnd_dflex.dflex_dr;
-- Structure for holding context information about 'Global Data Elements'
l_global_context    fnd_dflex.context_r;
-- Structure for holding context information about the context
l_context           fnd_dflex.context_r;
-- Structure for holding the segments corresponding to the Global Data
-- Elements
l_global_segments   fnd_dflex.segments_dr;
-- The number of global data element segments
l_global_count      number :=0;
-- Structure for holding the segments corresponding to the passed context
l_segments          fnd_dflex.segments_dr;
-- Structure for holding the composite Global Data Element and passed
-- context information
l_segment_info      var2tabtype;
-- General counter variable
l_counter	    number :=0;
-- A boolean determining whether we need to check for invalid segments
l_check_segments    BOOLEAN := TRUE;
-- General exists variable, used as an 'INTO' variable for the cursor
l_exists            varchar2(2);
-- Variable to hold the actual error segment, discounting the context field
l_error_seg_num       number;
begin

-- Obtain the application column name corresponding to the error segment
-- in an AOL supported way.  It would be much faster to perform a direct
-- access on the table FND_DESCR_FLEX_COLUMN_USAGES but this SQL would
-- not be supported by AOL.
--
-- First get the flexfield information
--
  -- Bug fix 1218702.Debug check added to improve performance.
  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
   fnd_dflex.get_flexfield(appl_short_name => p_appl_short_name,
                           flexfield_name => p_flexfield_name,
                           flexfield => l_flexfield,
                           flexinfo => l_flexinfo);
--
-- Use l_flexfield in calls that follow to identify the flexfield.
-- Next check that the context is valid, otherwise return the context
-- column name and prompt
--
  if g_debug then
  	hr_utility.set_location(l_proc||'>'||to_char(p_error_seg_num)||'<', 20);
  end if;
--
   if (p_error_seg_num is null) then
--
--   The context is in error, and the context is not one of the global
--   data elements.  In this case, we should simply set the application
--   column name and the context prompt to those associated with the
--   context information defined for this flexfield.
--
   if g_debug then
       hr_utility.set_location(l_proc, 30);
   end if;
--
       p_application_col_name := l_flexinfo.context_column_name;
       p_form_left_prompt := l_flexinfo.form_context_prompt;
       p_table_name := l_flexinfo.table_name;
--
--   Since we know that the context was invalid, we don't have to check
--   the segments.
--
       l_check_segments := FALSE;
--
   else
--
-- Now, we could still have an invalid context, but we don't know whether
-- the error segment corresponds to a segment or context.  If the context
-- is not one of the flex field segments, and p_error_seg_num is 1, then
-- we know that the context is in error.  However, the context could be one
-- of the global data elements, in which case segment 1 will be one of the
-- global segments, and the invalid context could be any of the others.
-- This means that we can't rely on p_error_seg_num value of 1 to indicate
-- an incorrect context, because it could correspond to one of the Global
-- data elements.  That in itself is OK, because a context global segment
-- is still a segment, i.e. the segment code which follows will still
-- find the error, however, if p_error_seg_num is 1, it could correspond to
-- a context field that is not one of the segments, in which case, if we
-- just executed the code below we would display an invalid segment error,
-- corresponding to a valid segment.
--
-- This implies that the only way to be sure whether the context is in error,
-- is to check the list of contexts defined for this flex, and see if the
-- passed context is present in this list.  If the context is not present,
-- then it is correct to assume that the context is invalid, otherwise, it
-- must be a segment.
--
-- Fetch the appropriate list of contexts
--
-- Don't bother to check NULL context, as this is always valid - e.g.
-- for Global Data elements, or no segments at all...
--
   if p_context_code is not null then
      open c_context_valid(p_appl_short_name, p_flexfield_name, p_context_code);
      fetch c_context_valid into l_exists;
--
-- If this cursor did not return a record, we have an invalid context.
--
      if c_context_valid%NOTFOUND then
         p_application_col_name := l_flexinfo.context_column_name;
         p_form_left_prompt := l_flexinfo.form_context_prompt;
         p_table_name := l_flexinfo.table_name;
--
-- Since we know we have an invalid context, we need not check the segments.
--
         l_check_segments := FALSE;
      end if;
      close c_context_valid;
   end if; -- Not null context code
   end if;
--
-- Do we have to check for an invalid segment?
--
   if l_check_segments then

--
-- It is an invalid segment (even if that segment is the
-- context driver, e.g. in Global Data Elements).
--
-- The AOL Segments in the server flex engine are set up as follows:
--
--   GLOBAL DATA ELEMENTS (ordered by col seq num)
--   CONTEXT field
--   CONTEXT Specific SEGMENTS (ordered by col seq num)
-- We need to recreate this list, in order to ensure the
-- correct segment is shown in error when the
--
-- The segment in error corresponds to a number based on the complete
-- flex definition, i.e. we must also include the global data elements,
-- and furthermore consider those first, as they appear first in the segment
-- sorted list that the flex engine uses when validation occurs (details
-- from Gursat Olgun, AOL flex team Oct 1999)
--
   if g_debug then
       hr_utility.set_location(l_proc, 32);
   end if;
--
-- First set up the Global Data Elements flexfield context, which is
-- always called 'Global Data Elements', as is not translated.
--
       l_global_context := fnd_dflex.make_context(flexfield => l_flexfield,
                                     context_code => 'Global Data Elements');
   if g_debug then
       hr_utility.set_location(l_proc, 34);
   end if;
--
-- Fetch all enabled segments associated with this context.  The flex server
-- engine will ignore non-enabled segments - see
-- /usr/home/arundell/11bugs/1033593/test_case/test.info
--
       fnd_dflex.get_segments(context => l_global_context,
                              segments => l_global_segments,
                              enabled_only => true);
    if g_debug then
       hr_utility.set_location(l_proc, 36);
    end if;
--
-- Store the global set of segments in a structure for later use.
-- col1 corresponds to the application column name
-- col2 corresponds to the segment prompt
-- We need only do this if there are global data elements for this
-- flexfield.
--

    if (l_global_segments.application_column_name.count > 0) then

       for l_counter in l_global_segments.application_column_name.first..
                         l_global_segments.application_column_name.last loop

       	  -- Bug fix 1218702.
       	  if g_debug then
          	hr_utility.set_location(l_proc||' - '||to_char(l_counter), 37);
          end if;
          l_segment_info(l_counter).col1 :=
                         l_global_segments.application_column_name(l_counter);
          l_segment_info(l_counter).col2 := l_global_segments.row_prompt(l_counter);
          l_global_count := l_global_count+1;

       	  -- Bug fix 1218702.
          if g_debug then
          	hr_utility.set_location(l_global_segments.application_column_name(l_counter)||
                          ' - '||to_char(l_counter), 38);
          end if;
       end loop;
     else
       l_global_count := 0;
     end if;
--
-- Add information about the context column
--
     l_global_count := l_global_count +1;

     l_segment_info(l_global_count).col1 := l_flexinfo.context_column_name;
     l_segment_info(l_global_count).col2 := l_flexinfo.form_context_prompt;
--
-- Next get the specific information if the context is not global data elements
--
       if (p_context_code is not null) then
	  if g_debug then
          	hr_utility.set_location(l_proc, 40);
          end if;
--
          l_context := fnd_dflex.make_context(flexfield => l_flexfield,
                                       context_code => p_context_code);
--
-- Retrieve the segment information for this context
--
          if g_debug then
          	hr_utility.set_location(l_proc, 50);
          end if;
--
          fnd_dflex.get_segments(context => l_context,
                                 segments => l_segments,
                                 enabled_only => true);
--
-- Append the specific context segment information to the Global Segment Information
-- again, checking that there is information to obtain
--
          if (l_segments.application_column_name.count > 0) then
           for l_counter in l_segments.application_column_name.first..
                            l_segments.application_column_name.last loop
               l_segment_info(l_counter+l_global_count).col1 :=
                         l_segments.application_column_name(l_counter);
               l_segment_info(l_counter+l_global_count).col2 :=
                         l_segments.row_prompt(l_counter);
               -- Bug fix 1218702.Debug check added to improve performance.
       	       if g_debug then
               	  hr_utility.set_location(l_segments.application_column_name(l_counter)||' - '||
                         to_char(l_global_count+l_counter), 52);
               end if;
           end loop;
          end if;
        end if;
        if g_debug then
        	hr_utility.set_location(l_proc, 55);
        end if;

--
-- Next retrieve the application column name corresponding to the segment
-- in error.  We know where this is in the table because the sequence is
-- used as the order key.  This should be the same sequence as is used
-- inside the FND_FLEX_DESCVAL procedures.
--
        p_application_col_name := l_segment_info(p_error_seg_num).col1;
        p_form_left_prompt := l_segment_info(p_error_seg_num).col2;
        p_table_name := l_flexinfo.table_name;
--
    end if;
--
if g_debug then
	hr_utility.set_location('Leaving: '||l_proc, 60);
end if;
--
end find_error_segment;
-----------------------------------------------------------------------------
-- ignore validation procedures using varry of flexcodes to ignore.
-------------------------------------------------------------------------------
-- create it
-------------------------------------------------------------------------------
--
procedure create_ignore_df_validation(p_rec in out nocopy l_ignore_dfcode_varray) is
l_proc varchar2(72) := 'create_ignore_df_validation';
begin
   if g_debug then
   	hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   if p_rec.count <> 0
   then
      g_dfcode_structure := p_rec;
   end if;
   if g_debug then
   	hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
end create_ignore_df_validation;
--
-- user calls a population script to populate this array
----------------------------------------------------------------------------
--  check it
----------------------------------------------------------------------------
function check_ignore_df_varray(p_structure in varchar2) return boolean is
l_proc varchar2(72) := 'check_ignore_df_varray';
begin
   if g_debug then
	hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   if g_dfcode_structure.count <> 0
   then
      for l_count in g_dfcode_structure.first..g_dfcode_structure.last
      loop
         if g_dfcode_structure(l_count) = p_structure
         then
            return true;
         end if;
      end loop;
   end if;
   if g_debug then
   	hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
   return false;
end;
--
----------------------------------------------------------------------------
-- delete it
----------------------------------------------------------------------------
procedure remove_ignore_df_validation is
l_proc varchar2(72) := 'remove_ignore_df_validation';
begin
   if g_debug then
   	hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   g_dfcode_structure.delete;
   if g_debug then
   	hr_utility.set_location('Leaving:'|| l_proc, 20);
   end if;
end;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< ins_or_upd_descflex_attribs >-------------------|
-- ----------------------------------------------------------------------------
--
procedure ins_or_upd_descflex_attribs
  (p_appl_short_name               in     varchar2
  ,p_descflex_name                 in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1_name               in     varchar2 default null
  ,p_attribute1_value              in     varchar2 default null
  ,p_attribute2_name               in     varchar2 default null
  ,p_attribute2_value              in     varchar2 default null
  ,p_attribute3_name               in     varchar2 default null
  ,p_attribute3_value              in     varchar2 default null
  ,p_attribute4_name               in     varchar2 default null
  ,p_attribute4_value              in     varchar2 default null
  ,p_attribute5_name               in     varchar2 default null
  ,p_attribute5_value              in     varchar2 default null
  ,p_attribute6_name               in     varchar2 default null
  ,p_attribute6_value              in     varchar2 default null
  ,p_attribute7_name               in     varchar2 default null
  ,p_attribute7_value              in     varchar2 default null
  ,p_attribute8_name               in     varchar2 default null
  ,p_attribute8_value              in     varchar2 default null
  ,p_attribute9_name               in     varchar2 default null
  ,p_attribute9_value              in     varchar2 default null
  ,p_attribute10_name              in     varchar2 default null
  ,p_attribute10_value             in     varchar2 default null
  ,p_attribute11_name              in     varchar2 default null
  ,p_attribute11_value             in     varchar2 default null
  ,p_attribute12_name              in     varchar2 default null
  ,p_attribute12_value             in     varchar2 default null
  ,p_attribute13_name              in     varchar2 default null
  ,p_attribute13_value             in     varchar2 default null
  ,p_attribute14_name              in     varchar2 default null
  ,p_attribute14_value             in     varchar2 default null
  ,p_attribute15_name              in     varchar2 default null
  ,p_attribute15_value             in     varchar2 default null
  ,p_attribute16_name              in     varchar2 default null
  ,p_attribute16_value             in     varchar2 default null
  ,p_attribute17_name              in     varchar2 default null
  ,p_attribute17_value             in     varchar2 default null
  ,p_attribute18_name              in     varchar2 default null
  ,p_attribute18_value             in     varchar2 default null
  ,p_attribute19_name              in     varchar2 default null
  ,p_attribute19_value             in     varchar2 default null
  ,p_attribute20_name              in     varchar2 default null
  ,p_attribute20_value             in     varchar2 default null
  ,p_attribute21_name              in     varchar2 default null
  ,p_attribute21_value             in     varchar2 default null
  ,p_attribute22_name              in     varchar2 default null
  ,p_attribute22_value             in     varchar2 default null
  ,p_attribute23_name              in     varchar2 default null
  ,p_attribute23_value             in     varchar2 default null
  ,p_attribute24_name              in     varchar2 default null
  ,p_attribute24_value             in     varchar2 default null
  ,p_attribute25_name              in     varchar2 default null
  ,p_attribute25_value             in     varchar2 default null
  ,p_attribute26_name              in     varchar2 default null
  ,p_attribute26_value             in     varchar2 default null
  ,p_attribute27_name              in     varchar2 default null
  ,p_attribute27_value             in     varchar2 default null
  ,p_attribute28_name              in     varchar2 default null
  ,p_attribute28_value             in     varchar2 default null
  ,p_attribute29_name              in     varchar2 default null
  ,p_attribute29_value             in     varchar2 default null
  ,p_attribute30_name              in     varchar2 default null
  ,p_attribute30_value             in     varchar2 default null
  )
is
  --
  l_proc              varchar2(72) := g_package||'ins_or_upd_descflex_attribs';
  --
  l_attr_set          Var2TabType;
  l_attr_set_cnt      binary_integer;
  l_segment_set       Var2TabType;
  l_segment_cnt       binary_integer;
  l_seg_tor_cnt       binary_integer;
  l_ne_attr_set       Var2TabType;
  --
  l_seg_column_name   varchar2(30);
  l_seg_value         varchar2(255);
  l_ne_column_name    varchar2(30);
  l_ne_column_value   varchar2(255);
  l_attr_name         varchar2(30);
  l_attr_value        varchar2(255);
  l_enab_seg_count    number;
  l_first_enab_segnum number;
  l_error_seg         number;
  i		      number;
  l_app_col_name      FND_DESCR_FLEX_COLUMN_USAGES.APPLICATION_COLUMN_NAME%TYPE;
  l_table_name        varchar2(60);
  l_flex_code         varchar2(40) := NULL; -- wwb 2256742
  l_error             boolean := false;

  -- l_id_in             varchar2(255);
  -- l_id_out            varchar2(255);
  -- l_context           boolean;
    -- start for fix of 5132936
    l_effective_date   date;

    cursor date_set is
       select EFFECTIVE_DATE from fnd_sessions
       where session_id=userenv('sessionid');
    -- end for fix of 5132936
--
-- ARR: 1999/10/26 Version 110.9
-- Note, no particular column to base this variable on, since it is a generic
-- flex column.  Picked person DF as this is likely to be the one that is increased
-- in line with any others...
-- If PL/SQL value errors reported, look here first!
--
  l_value               PER_ALL_PEOPLE_F.ATTRIBUTE1%TYPE;
  l_flex_seg_error_prompt FND_DESCR_FLEX_COL_USAGE_TL.FORM_LEFT_PROMPT%TYPE;
  --
  --  --------------------------------------------------------------------------
  --  |-----------------------< AttributeSet_AddAttrDets >---------------------|
  --  --------------------------------------------------------------------------
  --
  --  Add attribute details to a attribute set
  --
  procedure AttributeSet_AddAttrDets
    (p_attr_set        in out nocopy Var2TabType
    ,p_attr_set_rw_num in out nocopy number
    ,p_attr_name       in     varchar2
    ,p_attr_value      in     varchar2
    )
  is
    --
    l_proc         varchar2(80)
    := g_package||'AttributeSet_AddAttrDets';
    --
  begin
    --
    -- Check mandatory parameters have been set
    --
    --5132936 start
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
    --5132936 end

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'p_attr_set_rw_num'
      ,p_argument_value => p_attr_set_rw_num
      );
    --
    -- Check if the attribute name is set
    --
    if p_attr_name is not null then
      --
      p_attr_set(p_attr_set_rw_num).col1 := p_attr_name;
      p_attr_set(p_attr_set_rw_num).col2 := p_attr_value;
      --
      p_attr_set_rw_num := p_attr_set_rw_num + 1;
      --
    elsif p_attr_value is not null then
      --
      hr_utility.set_message(800, 'HR_52993_NULL_DF_SEG_NAME');
      hr_utility.raise_error;
      --
    end if;
    --
  end AttributeSet_AddAttrDets;
  --
  --  --------------------------------------------------------------------------
  --  |-----------------------------< GetNonExistRows >------------------------|
  --  --------------------------------------------------------------------------
  --
  --  Get PLSQL TOR rows which exist in TOR1 but not TOR2
  --
  procedure GetNonExistRows
    (p_plsqltor1  in     Var2TabType
    ,p_plsqltor2  in     Var2TabType
    --
    ,p_ne_tor_rws    out nocopy Var2TabType
    )
  is
    --
    -- l_proc           varchar2(80) := g_package||'GetNonExistRows';
    --
    l_tor1_row       Var2Rectype;
    --
    l_tor1_count     binary_integer;
    l_tor2_count     binary_integer;
    l_ne_rw_count    binary_integer;
    l_tor1_ele_value varchar2(255);
    l_tor2_ele_value varchar2(255);
    l_match_count    number;
    --
  begin
    --
    -- Check if TOR 1 contains rows
    --
    if p_plsqltor1.count > 0 then
      --
      -- Loop through TOR rows
      --
      l_ne_rw_count := 0;
      --
      for l_tor1_count in p_plsqltor1.first .. p_plsqltor1.last loop
        --
        l_tor1_ele_value := p_plsqltor1(l_tor1_count).col1;
        --
        -- Check if TOR 2 contains rows
        --
        if p_plsqltor2.count > 0 then
          --
          -- Loop through TOR rows
          --
          l_match_count := 0;
          --
          for l_tor2_count in p_plsqltor2.first .. p_plsqltor2.last loop
            --
            l_tor2_ele_value := p_plsqltor2(l_tor2_count).col1;
            --
            -- Check for a value match
            --
            if l_tor1_ele_value = l_tor2_ele_value then
              --
              l_match_count := l_match_count + 1;
              exit;
              --
            end if;
            --
          end loop;
          --
          -- Check for a non existant value
          --
          if l_match_count = 0 then
            --
            -- Set the NE row to a local row
            --
            l_tor1_row := p_plsqltor1(l_tor1_count);
            --
            -- Add the NE row to the NE TOR
            --
            p_ne_tor_rws(l_ne_rw_count) := l_tor1_row;
            l_ne_rw_count := l_ne_rw_count + 1;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end GetNonExistRows;
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
    ,p_argument       => 'appl_short_name'
    ,p_argument_value => p_appl_short_name
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'descflex_name'
    ,p_argument_value => p_descflex_name
    );
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  --  2256742 ignore desc flex validation if flexcode exists in varray:
  --
  l_flex_code := p_descflex_name;
  --
  if check_ignore_df_varray(l_flex_code)
  then
     if g_debug then
     	hr_utility.set_location(l_proc, 25);
     end if;
     -- 2256742 no validation required, exit procedure
     return;
  else
     -- 2256742 go ahead and validate if flex code is not in varray.
     --
     --
     -- Build the DF Attribute Set
     --
     l_attr_set_cnt := 0;
     --
     -- Add Attributes to the Attribute Set
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute1_name
       ,p_attr_value      => p_attribute1_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute2_name
       ,p_attr_value      => p_attribute2_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute3_name
       ,p_attr_value      => p_attribute3_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute4_name
       ,p_attr_value      => p_attribute4_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute5_name
       ,p_attr_value      => p_attribute5_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute6_name
       ,p_attr_value      => p_attribute6_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute7_name
       ,p_attr_value      => p_attribute7_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute8_name
       ,p_attr_value      => p_attribute8_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute9_name
       ,p_attr_value      => p_attribute9_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute10_name
       ,p_attr_value      => p_attribute10_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute11_name
       ,p_attr_value      => p_attribute11_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute12_name
       ,p_attr_value      => p_attribute12_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute13_name
       ,p_attr_value      => p_attribute13_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute14_name
       ,p_attr_value      => p_attribute14_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute15_name
       ,p_attr_value      => p_attribute15_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute16_name
       ,p_attr_value      => p_attribute16_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute17_name
       ,p_attr_value      => p_attribute17_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute18_name
       ,p_attr_value      => p_attribute18_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute19_name
       ,p_attr_value      => p_attribute19_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute20_name
       ,p_attr_value      => p_attribute20_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute21_name
       ,p_attr_value      => p_attribute21_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute22_name
       ,p_attr_value      => p_attribute22_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute23_name
       ,p_attr_value      => p_attribute23_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute24_name
       ,p_attr_value      => p_attribute24_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute25_name
       ,p_attr_value      => p_attribute25_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute26_name
       ,p_attr_value      => p_attribute26_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute27_name
       ,p_attr_value      => p_attribute27_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute28_name
       ,p_attr_value      => p_attribute28_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute29_name
       ,p_attr_value      => p_attribute29_value
       );
     --
     AttributeSet_AddAttrDets
       (p_attr_set        => l_attr_set
       ,p_attr_set_rw_num => l_attr_set_cnt
       ,p_attr_name       => p_attribute30_name
       ,p_attr_value      => p_attribute30_value
       );
     if g_debug then
     	hr_utility.set_location(l_proc, 30);
     end if;
     --
     -- Populate the AOL details
     --
     --   Set the descriptive flex context value in AOL
     --
     fnd_flex_descval.set_context_value
       (p_attribute_category
       );
     if g_debug then
     	hr_utility.set_location(l_proc, 40);
     end if;
     --
     --   Set the descriptive flex column details
     --
     --     Check if any DF attribute details exist
     --
     if l_attr_set.count > 0 then
       --
       -- Loop through the attribute set
       --
       for l_attr_set_cnt in l_attr_set.first .. l_attr_set.last loop
         --
         l_attr_name  := l_attr_set(l_attr_set_cnt).col1;
         l_attr_value := l_attr_set(l_attr_set_cnt).col2;
         --
         -- Add attribute details to AOL DF column details
         --
         fnd_flex_descval.set_column_value
           (column_name  => l_attr_name
           ,column_value => l_attr_value
           );
         --
       end loop;
       --
     end if;
     if g_debug then
     	hr_utility.set_location(l_proc, 40);
     end if;
     --
     -- Validate DF column details passed to AOL
     --
     if FND_FLEX_DESCVAL.validate_desccols
        (appl_short_name	=> p_appl_short_name
        ,desc_flex_name	=> p_descflex_name
         --5132936 start here
        ,validation_date=>l_effective_date
    	--5132936 ends here
        ,VALUES_OR_IDS	=> 'I'
        )
     then
       --
       -- AOL DF validation succeeds - do nothing
       --
       hr_utility.set_location(l_proc, 50);
       -- Bug fix 1218702.Debug check added to improve performance.
       if g_debug then
       	  FOR i IN 1..20 loop
         	hr_utility.set_location(substr(to_char(i)||'...'
         	||nvl(FND_FLEX_DESCVAL.segment_column_name(i),'NULL VALUE'),1,70),980);
          END LOOP;
       end if;
       --
     else
       -- Bug fix 1218702.Debug check added to improve performance.
       if g_debug then
         hr_utility.set_location(substr('--====== FLEX VALUES =====--',1,70),69);
         hr_utility.set_location(substr('Error segment:'
          ||nvl(to_char(fnd_flex_descval.error_segment),'CONTEXT'),1,70),970);
         FOR i IN 1..20 loop
            hr_utility.set_location(substr(to_char(i)||'...'
            ||nvl(FND_FLEX_DESCVAL.segment_column_name(i),'NULL VALUE'),1,70),980);
         END LOOP;
       end if;
       --
       -- Raise or trap the AOL error
       --
       hr_utility.set_location(l_proc, 60);
       --
       -- The FND FLEX DESCVAL package makes a call to FND MESSAGE
       -- get encoded
       hr_message.parse_encoded(p_encoded_error =>
                                 FND_FLEX_DESCVAL.encoded_error_message);
       hr_utility.set_location(l_proc, 62);
       --
       if ((hr_message.last_message_app = 'FND') and
           (hr_message.last_message_name = 'FLEX-VALUE NOT FOUND')) then
          --
          if g_debug then
             hr_utility.set_location(l_proc, 64);
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
          l_error_seg := FND_FLEX_DESCVAL.error_segment;
          find_error_segment(p_appl_short_name => p_appl_short_name,
                             p_flexfield_name  => p_descflex_name,
                             p_context_code    => p_attribute_category,
                             p_error_seg_num   => l_error_seg,
                             p_application_col_name => l_app_col_name,
                             p_form_left_prompt => l_flex_seg_error_prompt,
                             p_table_name => l_table_name
                             );
          if g_debug then
          	hr_utility.set_location(l_proc || l_flex_seg_error_prompt, 66);
          end if;
          l_value := hr_message.get_token_value(p_token_name => 'VALUE');
          --
          --  Now have the additional error information, raise a different error
          --  using this information.
          --
          fnd_message.set_name('PER','HR_FLEX_VALUE_INVALID');
          fnd_message.set_token('COLUMN',l_app_col_name);
          fnd_message.set_token('VALUE',l_value);
          fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
          hr_multi_message.add
          (p_associated_column1 => l_table_name ||'.'||l_app_col_name);
          l_error := true;
          --
       elsif (hr_message.last_message_app = 'FND') and
              (hr_message.last_message_name = 'FLEX-NULL SEGMENT') then
          if g_debug then
          	hr_utility.set_location(l_proc, 67);
          end if;
          --
          --  In this case, there was a missing mandatory segment
          --  First, work out which segment is in error, and change the
          --  error message to indicate which of these segments is
          --  is incorrect.
          --
          l_error_seg := FND_FLEX_DESCVAL.error_segment;
          find_error_segment(p_appl_short_name => p_appl_short_name,
                             p_flexfield_name  => p_descflex_name,
                             p_context_code    => p_attribute_category,
                             p_error_seg_num   => l_error_seg,
                             p_application_col_name => l_app_col_name,
                             p_form_left_prompt => l_flex_seg_error_prompt,
                             p_table_name       => l_table_name
                             );
          if g_debug then
          	hr_utility.set_location(l_proc, 68);
          end if;
          --
          --  Now have the additional error information, raise a different error
          --  using this information.
          --
          fnd_message.set_name('PER','HR_FLEX_VALUE_MISSING');
          fnd_message.set_token('COLUMN',l_app_col_name);
          fnd_message.set_token('PROMPT',l_flex_seg_error_prompt);
          hr_multi_message.add
            (p_associated_column1 => l_table_name || '.' || l_app_col_name);
          l_error := true;
          --
       else
          --
          -- Some other non-expected error, simply raise the error in the
          -- previous fashion.
          --
          -- Bug fix: 2504004
          hr_utility.set_location(l_proc, 69);
          -- dbms_standard.raise_application_error
          -- (-20001
          -- ,fnd_flex_descval.error_message
          -- );
          fnd_message.set_encoded
            (fnd_flex_descval.encoded_error_message);
          fnd_message.raise_error;
       --
       end if;
       --
     end if;  --  FND_FLEX_DESCVAL.validate_desccols
     if g_debug then
     	hr_utility.set_location(l_proc, 70);
     end if;
     --
     -- Check if error has been added to multi_message, and if so, do not
     -- proceed with following logic
     IF not l_error
     THEN
        --
        -- Build the segment set
        --
        --   Note: We start at segment 2 because AOL store the context value
        --         as segment column 1
        --
        l_seg_tor_cnt := 0;
        --
        --   Check if the attribute category is set
        --
        --
        -- ARR 5/7/99
        -- 110.6 Change, always start counting the enabled segments
        -- from the first one, it doesn't matter if 'ATTRIBUTE_CATEGORY'
        -- appears in the list, as the context, or lack of it, is
        -- correctly validated by the AOL routines.
        --
        l_first_enab_segnum := 1;
        --
        --   Get the enabled segment count
        --
        l_enab_seg_count := fnd_flex_descval.segment_count;
        --
        for l_segment_cnt in l_first_enab_segnum..l_enab_seg_count loop
          --
          -- Get the segment column name
          --
          l_seg_column_name := fnd_flex_descval.segment_column_name(l_segment_cnt);
          --
          -- Check if the column name is set
          --
          if l_seg_column_name is not null then
            /*  Commented out fix 1230951 due to bug 1919660.
            --
            -- fix #1230951
            --
            l_context := FALSE;
            if l_seg_column_name = p_attribute1_name then
              l_id_in := p_attribute1_value;
            elsif l_seg_column_name = p_attribute2_name then
              l_id_in := p_attribute2_value;
            elsif l_seg_column_name = p_attribute3_name then
              l_id_in := p_attribute3_value;
            elsif l_seg_column_name = p_attribute4_name then
              l_id_in := p_attribute4_value;
            elsif l_seg_column_name = p_attribute5_name then
              l_id_in := p_attribute5_value;
            elsif l_seg_column_name = p_attribute6_name then
              l_id_in := p_attribute6_value;
            elsif l_seg_column_name = p_attribute7_name then
              l_id_in := p_attribute7_value;
            elsif l_seg_column_name = p_attribute8_name then
              l_id_in := p_attribute8_value;
            elsif l_seg_column_name = p_attribute9_name then
              l_id_in := p_attribute9_value;
            elsif l_seg_column_name = p_attribute10_name then
              l_id_in := p_attribute10_value;
            elsif l_seg_column_name = p_attribute11_name then
              l_id_in := p_attribute11_value;
            elsif l_seg_column_name = p_attribute12_name then
              l_id_in := p_attribute12_value;
            elsif l_seg_column_name = p_attribute13_name then
              l_id_in := p_attribute13_value;
            elsif l_seg_column_name = p_attribute14_name then
              l_id_in := p_attribute14_value;
            elsif l_seg_column_name = p_attribute15_name then
              l_id_in := p_attribute15_value;
            elsif l_seg_column_name = p_attribute16_name then
              l_id_in := p_attribute16_value;
            elsif l_seg_column_name = p_attribute17_name then
              l_id_in := p_attribute17_value;
            elsif l_seg_column_name = p_attribute18_name then
              l_id_in := p_attribute18_value;
            elsif l_seg_column_name = p_attribute19_name then
              l_id_in := p_attribute19_value;
            elsif l_seg_column_name = p_attribute20_name then
              l_id_in := p_attribute20_value;
            elsif l_seg_column_name = p_attribute21_name then
              l_id_in := p_attribute21_value;
            elsif l_seg_column_name = p_attribute22_name then
              l_id_in := p_attribute22_value;
            elsif l_seg_column_name = p_attribute23_name then
              l_id_in := p_attribute23_value;
            elsif l_seg_column_name = p_attribute24_name then
              l_id_in := p_attribute24_value;
            elsif l_seg_column_name = p_attribute25_name then
              l_id_in := p_attribute25_value;
            elsif l_seg_column_name = p_attribute26_name then
              l_id_in := p_attribute26_value;
            elsif l_seg_column_name = p_attribute27_name then
              l_id_in := p_attribute27_value;
            elsif l_seg_column_name = p_attribute28_name then
              l_id_in := p_attribute28_value;
            elsif l_seg_column_name = p_attribute29_name then
              l_id_in := p_attribute29_value;
            elsif l_seg_column_name = p_attribute30_name then
              l_id_in := p_attribute30_value;
            else
              l_context := TRUE;
            end if;
            --
            if not l_context then
              l_id_out := fnd_flex_descval.segment_id(l_segment_cnt);
              if l_id_in <> l_id_out
              or l_id_in IS NULL and l_id_out IS NOT NULL
              or l_id_in IS NOT NULL and l_id_out IS NULL then
                -- call find_error_segment to find table name
                find_error_segment(p_appl_short_name => p_appl_short_name,
                                   p_flexfield_name  => p_descflex_name,
                                   p_context_code    => p_attribute_category,
                                   p_error_seg_num   => null,
                                   p_application_col_name => l_app_col_name,
                                   p_form_left_prompt => l_flex_seg_error_prompt,
                                   p_table_name => l_table_name
                                  );
              -- raise error
                hr_utility.set_message(800,'HR_52763_INV_FORMAT');
                hr_utility.set_message_token('VALUE_IN',l_id_in);
                hr_utility.set_message_token('VALUE_OUT',l_id_out);
                hr_utility.set_message_token('SEGMENT',l_seg_column_name);
                hr_multi_message.add
                (p_associated_column1 => l_table_name || '.' || l_seg_column_name);
                l_error := true;
              end if;
            end if;
         -- end fix;
        */
            --
            -- Populate the segment TOR
            IF not l_error THEN
              l_segment_set(l_seg_tor_cnt).col1 := l_seg_column_name;
              l_seg_tor_cnt := l_seg_tor_cnt + 1;
            ELSE
              l_error := false;
            END IF;
          end if;
         --
        end loop;
        if g_debug then
        	hr_utility.set_location(l_proc, 80);
        end if;
        --
        -- Get Non Enabled attribute names
        --
        GetNonExistRows
          (p_plsqltor1  => l_attr_set
          ,p_plsqltor2  => l_segment_set
          --
          ,p_ne_tor_rws => l_ne_attr_set
          );
        if g_debug then
        	hr_utility.set_location(l_proc, 90);
        end if;
        --
        -- Check if non enabled attributes have been provided
        --
       if l_ne_attr_set.count > 0 then
        for x in l_ne_attr_set.first..l_ne_attr_set.last loop
          --
          -- Set the non enabled column name
          --
          l_ne_column_name  := l_ne_attr_set(x).col1;
          l_ne_column_value := l_ne_attr_set(x).col2;
          --
          -- Check if the value is set for the non enabled column
          --
          if l_ne_column_value is not null then
            --
            -- Raise the AOL error
            --
            if g_debug then
            	hr_utility.set_location(l_proc, 100);
            end if;
            --
            hr_utility.set_message(800, 'HR_52994_NON_EXIST_SEG_NAME');
            hr_utility.set_message_token('SEGMENT',l_ne_column_name);
            hr_utility.set_message_token('VALUE',l_ne_column_value);
            hr_multi_message.add
              (p_associated_column1 => l_table_name || '.' || l_ne_column_name);
            --
          end if;
          --
         end loop;
       end if;
     end if;
   end if; -- end if descflex code exists in ignore varray
   --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add then
       hr_utility.set_location('Leaving '||l_proc, 110);
       raise;
    end if;
    hr_utility.set_location('Leaving '||l_proc, 120);
end ins_or_upd_descflex_attribs;
--
end hr_dflex_utility;

/
