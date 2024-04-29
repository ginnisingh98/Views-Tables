--------------------------------------------------------
--  DDL for Package Body HR_FLEXFIELD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FLEXFIELD_INFO" as
/* $Header: peffinfo.pkb 120.1 2005/09/23 17:03:39 svittal noship $ */
--
-- Constants.
--
c_newline constant varchar2(1) :=
'
';
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_flexfield_info';
g_psegment_count number := 0;
g_app_col_placeholder VARCHAR2(200) := '&'||hr_api.g_varchar2||'.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< initialize >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure initialize is
begin
      g_psegment_count :=0;
end initialize;
--
-- ----------------------------------------------------------------------------
-- |------------------------< structure_column_name >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure structure_column_name(
                      p_appl_short_name in VARCHAR2
                     ,p_flex_name IN VARCHAR2
                     ,p_column_name OUT NOCOPY VARCHAR2
                     ,p_column_name_prompt OUT NOCOPY VARCHAR2
                     ,p_dcontext_field OUT NOCOPY VARCHAR2
                     ,p_default_context_value OUT NOCOPY VARCHAR2) IS
--
l_flexfield fnd_dflex.dflex_r;
l_flexinfo fnd_dflex.dflex_dr;

BEGIN

--FND_DFLEX.GET_FLEXFIELD(appl_short_name=>p_appl_short_name,
--			flexfield_name=>p_flex_name,
--			flexfield=>l_flexfield,
--			flexinfo=>l_flexinfo);

select context_column_name,form_context_prompt,default_context_field_name,default_context_value
into   p_column_name,p_column_name_prompt,p_dcontext_field,p_default_context_value
from fnd_descriptive_flexs_vl fdf
    ,fnd_application fa
where descriptive_flexfield_name = p_flex_name
and fa.application_id = fdf.application_id
and fa.application_short_name = p_appl_short_name;

END structure_column_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_ak_region_code >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_ak_region_code(p_flex_type in VARCHAR2,
                         p_flexfield_name IN VARCHAR2,
                         p_context_code IN VARCHAR2,
                         p_segment_info IN hr_segments_info,
                         p_segment_number IN BINARY_INTEGER) return varchar2 is
--
-- Cursor for AK data
--
   cursor c_ak_region(p_lookup_code in fnd_common_lookups.lookup_code%type) is
    select meaning
    from   fnd_common_lookups
    where  upper(lookup_code) = upper(p_lookup_code)
    and    lookup_type = 'AK_WEB_REGION_CODES'
    and    application_id = 800
    and    enabled_flag = 'Y';

--
-- Local Variables
--
   l_lookup_code fnd_common_lookups.lookup_code%TYPE;
   l_ak_web_region_code fnd_common_lookups.meaning%TYPE;
   l_proc      varchar2(72);
--
begin
--

IF g_debug THEN
   l_proc := g_package||'get_ak_region_code';
   hr_utility.set_location('Entering:'|| l_proc, 10);
END IF;

--
-- Construct the right look up code for the AK region data based
-- on the flexfield name, the context code and the application
-- column name.
-- ** This should be stored in a table really, and not as a lookup
--
-- Confirmed that this lookup code does not use any translatable
-- information. Also, aware that there is a possibility of clashes
-- because of the substr calls.
l_lookup_code :=
gen_ak_web_region_code
(p_flex_type              => p_flex_type,
 p_flexfield              => p_flexfield_name
,p_context_or_id_flex_num => p_context_code
,p_segment                =>
 p_segment_info.application_column_name(p_segment_number)
);

open c_ak_region(l_lookup_code);
fetch c_ak_region into l_ak_web_region_code;
if c_ak_region%notfound then
  close c_ak_region;
  l_ak_web_region_code := NULL;
else
close c_ak_region;
end if;

--

IF g_debug THEN
   hr_utility.set_location('Leaving:'|| l_proc, 20);
END IF;

--
--return nvl(l_ak_web_region_code,'Not found!');
return l_ak_web_region_code;

exception
  WHEN others then
   return null;

end get_ak_region_code;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_segment_parents >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_segment_parents(
                              p_segment_info IN OUT NOCOPY hr_segments_info,
                              p_segment_number IN BINARY_INTEGER,
                              p_sql_text IN OUT NOCOPY LONG,
                              p_number_parents OUT NOCOPY BINARY_INTEGER) is
  --
  -- Declare local variables
  --
     l_count BINARY_INTEGER;
     l_str_start NUMBER;
     l_parent_loc NUMBER;
     l_end_replace_string NUMBER;
     l_length_rep_string NUMBER;
     l_replace_string VARCHAR2(2000);
     l_segment_or_vs VARCHAR2(2000);
     l_placeholder_identifier VARCHAR2(10) := ':$FLEX$.';
     l_flex_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
     l_token_value   VARCHAR2(2000) := '';
     l_cr_check  NUMBER;
     l_cr_char   NUMBER;
     l_proc      varchar2(72);
--
begin
--

IF g_debug THEN
   l_proc := g_package||'get_segment_parents';
   hr_utility.set_location('Entering:'|| l_proc, 10);
END IF;

--
l_count :=0;
l_parent_loc := 1;
--
-- Find Carriage return character
--
     p_sql_text := replace(p_sql_text,c_newline,' ');
--
--  Loop over the number of segments, looking for parent segments
--  by checking for $FLEX$ strings in the SQL text.  The application
--  column name, segment name, or value set name that follows this
--  place holder identifies the parent segment
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 20);
END IF;

--
  LOOP
      l_parent_loc := INSTR(p_sql_text,l_placeholder_identifier,(l_parent_loc+
                                         length(l_placeholder_identifier)));
      EXIT WHEN l_parent_loc < 1;
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 30);
END IF;

--
      p_segment_info.psegment_pointer(p_segment_number):=g_psegment_count+1;
--
      l_count := l_count+1;
      l_token_value := '';
      l_end_replace_string := INSTR(p_sql_text, ' ',l_parent_loc);
      l_length_rep_string := l_end_replace_string - l_parent_loc;
      if(l_end_replace_string > 0) then
        l_replace_string := substr(p_sql_text, l_parent_loc,
                                               l_length_rep_string);
      else
        l_replace_string := substr(p_sql_text,l_parent_loc);
      end if;
      if(INSTR(l_replace_string,c_newline)) > 0 then
           l_replace_string := substr(l_replace_string,1,INSTR(
                                          l_replace_string,c_newline)-1);
      end if;
      if(INSTR(l_replace_string,',')) > 0 then
           l_replace_string := substr(l_replace_string,1,INSTR(
                                          l_replace_string,',')-1);
      end if;
      l_segment_or_vs := substr(l_replace_string,(length(
                                                l_placeholder_identifier)+1));
      --
      -- Handle cases where the replacement string is in either of the
      -- forms:
      -- :$FLEX$.VALUE_SET.VALUE
      -- :$FLEX$.VALUE_SET.ID
      -- Need to get rid of the suffixes.
      --
      if upper(l_segment_or_vs) like '%.VALUE' then
        l_segment_or_vs :=
        substr(l_segment_or_vs, 1, length(l_segment_or_vs)-length('.VALUE'));
      elsif upper(l_segment_or_vs) like '%.ID' then
        l_segment_or_vs :=
        substr(l_segment_or_vs, 1, length(l_segment_or_vs)-length('.ID'));
      end if;
--
      FOR i in 1..p_segment_info.nsegments LOOP
--
--  Next substitute the $FLEX$ text with the application column name
--  this can be a value set, or a segment name.
--

IF g_debug THEN
         hr_utility.set_location(l_proc, 40);
END IF;

--
         if (p_segment_info.value_set(i) > 0) then
            select flex_value_set_name into l_flex_value_set_name
            from fnd_flex_value_sets
            where flex_value_set_id = p_segment_info.value_set(i);
            if (l_flex_value_set_name = l_segment_or_vs) then
               l_token_value := g_app_col_placeholder||p_segment_info.
                                   application_column_name(i)||' ';
               p_segment_info.parent_segments((l_count+g_psegment_count)) :=
                                   p_segment_info.application_column_name(i);
               --
               -- Set the parent segment number of children component,
               -- so that the flex code will know to include JS onChange event
               -- Note it doesn't matter how many children the parent segment
               -- has only that it has non-zero children.
               --
               p_segment_info.number_children(i) := 1;
               exit;
            end if;
         end if;
--
      END LOOP;
--
--  The text after $FLEX$ was not a value set name, so just check for
--  segment name.  This is not to standards, it ought to be the
--  value set name, but as a secondary check, perform this step
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 50);
END IF;

--
      if(l_token_value is null) then
--
        FOR i in 1..p_segment_info.nsegments LOOP
--

IF g_debug THEN
          hr_utility.set_location(l_proc, 60);
END IF;

--
          if (p_segment_info.segment_name(i) = l_segment_or_vs) then
             l_token_value := g_app_col_placeholder||p_segment_info.
                                      application_column_name(i)||' ';
               p_segment_info.parent_segments((l_count+g_psegment_count)) :=
                                    p_segment_info.application_column_name(i);
               exit;
          end if;
--
        END LOOP;
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 70);
END IF;

--
      end if;
--
-- Replace all occurances of the $FLEX$ placeholder string with the
-- the application column name.  This can be used in build_sql_text
-- to replace this with the value set in by the web (user)
--
      p_sql_text := replace(p_sql_text,l_replace_string,l_token_value);

  END LOOP;
--

IF g_debug THEN
  hr_utility.set_location(l_proc, 80);
END IF;

--
-- Up date the number of parents and segment counts.
--
  p_number_parents := l_count;
  g_psegment_count := g_psegment_count + l_count;
--

IF g_debug THEN
  hr_utility.set_location('Leaving: '||l_proc, 80);
END IF;

--
end get_segment_parents;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< substitute_profiles >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure substitute_profiles
(p_sql_text       in out nocopy long
) is
  l_proc            varchar2(72);
  c_profile         constant varchar2(20) default ':$PROFILES$.';
  l_placeholder     varchar2(32767);
  l_placeholder_len number;
  l_end_char        varchar2(2000);
  l_profile_start   number;
  l_profile_end     number;
  l_profile_name    varchar2(32767) := '';
  l_profile_value   varchar2(32767);
  l_sql_text        varchar2(32767);
  l_sql_text_rep    varchar2(32767);
  l_comma_pos       number;
  l_end             varchar2(32767);
  l_next_name_count number;
  l_next_name_char  varchar2(2);
  l_message         long;

begin

IF g_debug THEN
  l_proc := g_package||'substitute_profiles';
  hr_utility.set_location('Entering:'|| l_proc, 10);
END IF;

  --
  -- Don't strictly need to do this if get_segment_parents is called
  -- before this procedure.
  --
  l_sql_text := replace(p_sql_text, c_newline, ' ');
  --
  loop
    --
    -- Look for next occurrence of :$PROFILE$.profile_name placeholder.
    --
    l_profile_start := instr(l_sql_text, c_profile, 1);
    exit when l_profile_start = 0;
    --
    -- Found a placeholder.
    --

IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
END IF;

/* AR 6/7/99
   Adjust Adnan's code here, to check for any following special character
   profile names can be made up from alpha numeric character, and an
   underscore '_'.  Anything else will terminate the profile name.
*/
   l_next_name_count := l_profile_start+length(c_profile);
   l_sql_text_rep := translate(upper(l_sql_text),
                              '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
                              '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
   l_end := ltrim(substr(l_sql_text_rep,l_next_name_count),'&');

   if l_end is null then
      l_profile_name := substr(l_sql_text,l_next_name_count);
   else
      l_profile_name := substr(l_sql_text,l_next_name_count,
                               instr(l_sql_text_rep,l_end)-l_next_name_count);
   end if;
   l_placeholder := c_profile||l_profile_name;
   l_placeholder_len := length(l_placeholder);
    --
    -- Get the profile value.
    --
    fnd_profile.get(upper(l_profile_name), l_profile_value);
/*
AR 8/7/99
   Profile values can be null.  There is no need to raise an error
   here.  If the profile can not be found, then the above flex
   routine will raise an error

    if l_profile_value is null then

IF g_debug THEN
      hr_utility.set_location('Leaving ' || l_proc, 30);
END IF;

      --
      -- Using an AOL message here!
      --
      hr_utility.set_message(0, 'FLEX-INVALID PROFILE');
      hr_utility.set_message_token('BTOKEN', upper(l_profile_name));
      hr_utility.raise_error;
    end if;
*/
    --
    -- Replace the profile value completely in the string. Note:
    -- cannot do a simple REPLACE call because one placeholder
    -- may be a substring of another placeholder.
    --
    l_profile_value := l_profile_value;

    loop
      --
      -- Find the placeholder in the SQL text.
      --
      l_profile_start := instr(l_sql_text, l_placeholder, l_profile_start);
      exit when l_profile_start = 0;
      --
      -- Only substitute the profile value if the placeholder ends
      -- with a space or a comma.
      --
/* AR 9/7/99
   Alter Adnan's code - the profile can end with any non-alphanumeric
   character, not just space or ,
*/
      l_end_char :=
      substr(l_sql_text, l_profile_start + l_placeholder_len, 1);
        l_sql_text :=
        substr(l_sql_text, 1, l_profile_start - 1) ||
        '''' || l_profile_value || '''' ||
        substr(l_sql_text, l_profile_start + l_placeholder_len);
    end loop;
  end loop;
  p_sql_text := l_sql_text;

IF g_debug THEN
  hr_utility.set_location('Leaving ' || l_proc, 40);
END IF;


EXCEPTION
   WHEN OTHERS THEN
     hr_utility.trace(' Exception in hr_flexfield_info.substitute_profiles ' || SQLERRM );
     raise;

end substitute_profiles;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_contexts >-----------------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE get_contexts
              (p_appl_short_name IN
                    fnd_application.application_short_name%TYPE,
               p_flexfield_name  IN
                    fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
               p_contexts        OUT NOCOPY fnd_dflex.contexts_dr)
is
   --
   -- Declare local variables
   --
   l_flexfield fnd_dflex.dflex_r;
   l_flexinfo  fnd_dflex.dflex_dr;
   l_proc      varchar2(72);
   --
begin
   --

IF g_debug THEN
   l_proc := g_package||'get_contexts';
   hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

   --

   fnd_dflex.get_flexfield(p_appl_short_name,
                           p_flexfield_name,
                           l_flexfield,
                           l_flexinfo);

   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 10);
END IF;

   --
   fnd_dflex.get_contexts(l_flexfield, p_contexts);
   --

IF g_debug THEN
   hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

   --
end get_contexts;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_concatenated_contexts >---------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE get_concatenated_contexts
              (p_appl_short_name   IN
                     fnd_application.application_short_name%TYPE,
               p_flexfield_name    IN
                     fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
               p_enabled_only      IN  BOOLEAN,
               p_concatenation_chr IN  VARCHAR2,
               p_context_list      OUT NOCOPY LONG)
is
   --
   -- Declare local variables
   --
   l_contexts fnd_dflex.contexts_dr;
   l_context_list long;
   i binary_integer;
   l_proc      varchar2(72);
   --
begin
   --
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
   l_proc := g_package||'get_concatenated_contexts';
   hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

   --
   hr_flexfield_info.get_contexts(p_appl_short_name,
                                      p_flexfield_name,
                                      l_contexts);
   --

IF g_debug THEN
   hr_utility.set_location( l_proc, 10);
END IF;

   --
   for i in 1 .. l_contexts.ncontexts
   loop
      if l_contexts.context_code(i) <> 'Global Data Elements' then
         if p_enabled_only then
            if l_contexts.is_enabled(i) then
               l_context_list := l_context_list ||
                                 p_concatenation_chr ||
                                 l_contexts.context_code(i);
            end if;
         else
            l_context_list := l_context_list ||
                              p_concatenation_chr ||
                              l_contexts.context_code(i);
         end if;
      end if;
   end loop;
   --
   p_context_list := ltrim(l_context_list,p_concatenation_chr);
   --

IF g_debug THEN
   hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

   --
end get_concatenated_contexts;

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_dependent_parent_column >----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_dependent_parent_column
              (p_segment_info   IN OUT NOCOPY hr_segments_info,
               p_segment_number IN NUMBER)
         RETURN VARCHAR2 is

cursor c_parent_set(p_value_set_id in fnd_flex_value_sets.flex_value_set_id%TYPE)
       is
  select parent_flex_value_set_id
    from fnd_flex_value_sets
   where flex_value_set_id = p_value_set_id;

l_application_column_name     fnd_columns.column_name%TYPE;
l_dep_value_set_id            fnd_flex_value_sets.flex_value_set_id%TYPE;
l_indep_value_set_id          fnd_flex_value_sets.flex_value_set_id%TYPE;
l_count                       number := 1;

BEGIN

open c_parent_set(p_segment_info.value_set(p_segment_number));
fetch c_parent_set into l_indep_value_set_id;

if c_parent_set%FOUND then
   close c_parent_set;
   WHILE ((p_segment_info.value_set(l_count) <> l_indep_value_set_id)
          AND (l_count < p_segment_info.application_column_name.count)) LOOP
       l_count := l_count +1;
   END LOOP;
   if l_count < p_segment_info.application_column_name.count then
     g_psegment_count := g_psegment_count +1;
--
-- Set the return variable to the parent application column name
--
      l_application_column_name := p_segment_info.application_column_name(l_count);
--
-- Set the parent segment pointer to point at the right segment
--
     p_segment_info.psegment_pointer(p_segment_number):=
                    g_psegment_count;
--
-- Set the parent segment name
--
      p_segment_info.parent_segments(g_psegment_count) :=
                                l_application_column_name;
--
-- Set the parent segment number of children component,
-- so that the flex code will know to include trigger (for forms)
-- or JS onChange event (for self service)
-- Note it doesn't matter how many children the parent segment has,
-- only that it has non-zero children.
--
      p_segment_info.number_children(l_count) := 1;

   else
      l_application_column_name := hr_api.g_varchar2;
   end if;
else
   close c_parent_set;
   l_application_column_name := hr_api.g_varchar2;
end if;


RETURN l_application_column_name;

end get_dependent_parent_column;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_validation_info >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_validation_info
              (p_segment_info   IN OUT NOCOPY hr_segments_info,
               p_session_date   IN     DATE,
               p_context_code IN VARCHAR2,
               p_flexfield_name IN VARCHAR2,
               p_flex_type IN VARCHAR2)
is
   --
   -- Declare local variables
   --
   l_valueset_r  fnd_vset.valueset_r;
   l_valueset_dr fnd_vset.valueset_dr;
   l_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   l_proc      varchar2(72);
   l_order_by_start NUMBER;
   l_from_start NUMBER;
   l_additional_and_clause VARCHAR2(2000);
   l_from_where VARCHAR2(2000);
   l_select_clause VARCHAR2(2000);
   l_dep_parent_column_name fnd_columns.column_name%TYPE;
   --
begin
   --

IF g_debug THEN
   l_proc:= g_package||'get_validation_info';
   hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

   --
for i in 1..p_segment_info.nsegments loop
--
-- Copy the retrieved value set information into the hr structure
-- containing all the information about the segments.
--
if (p_segment_info.value_set(i) is not null) then
--
   l_value_set_id := p_segment_info.value_set(i);
   fnd_vset.get_valueset(l_value_set_id,l_valueset_r,l_valueset_dr);
   --
   p_segment_info.format_type(i) := l_valueset_dr.format_type;
   p_segment_info.alphanumeric_allowed_flag(i)
                               := l_valueset_dr.alphanumeric_allowed_flag;
   p_segment_info.uppercase_only_flag(i)
                               := l_valueset_dr.uppercase_only_flag;
   p_segment_info.numeric_mode_flag(i)
                               := l_valueset_dr.numeric_mode_flag;
   p_segment_info.max_size(i)    := l_valueset_dr.max_size;
   p_segment_info.max_value(i)   := l_valueset_dr.max_value;
   p_segment_info.min_value(i)   := l_valueset_dr.min_value;
   p_segment_info.number_children(i):=0;
   p_segment_info.longlist_enabled(i)
                               := l_valueset_dr.longlist_enabled;
   p_segment_info.has_id(i)      := l_valueset_dr.has_id;
   p_segment_info.has_meaning(i) := l_valueset_dr.has_meaning;
--
-- Initailize the SQL text columns.
--
   p_segment_info.sql_text(i) := '';
   p_segment_info.sql_txt_descr(i) := '';
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 10);
END IF;

   --
--
-- Default validation type to None.
--
   p_segment_info.validation_type(i) := 'NONE';
--
-- Ok next build the SQL text that can be used to build a pop-list
-- for this segment, if this is a table validated or independant
-- validated value set - i.e. it has an associated list of values.
-- We are going to build two versions of the SQL.  One can be used
-- to define the list of values associated with this segment(SQL_TEXT), the
-- other is used to converted a value (ID) stored on the database into a
-- a description (VALUE) (SQL_DESCR_TXT).
--
   if l_valueset_r.validation_type = 'F' then
--
    p_segment_info.validation_type(i) := 'TABLE';
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 20);
END IF;

--
      select 'SELECT ' ||
          l_valueset_r.table_info.value_column_name ||
          decode(l_valueset_r.table_info.meaning_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.meaning_column_name)||
          decode(l_valueset_r.table_info.id_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.id_column_name)||
                 ' FROM ' ||
                 l_valueset_r.table_info.table_name || ' ' ||
                 l_valueset_r.table_info.where_clause
      into p_segment_info.sql_text(i)
      from dual;
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 30);
END IF;

--
      get_segment_parents(p_segment_info,i,p_segment_info.sql_text(i),
                             p_segment_info.number_parents(i));


IF g_debug THEN
  hr_utility.set_location(l_proc, 35);
END IF;

--
      substitute_profiles
      (p_sql_text   => p_segment_info.sql_text(i)
      );
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 40);
END IF;

--
      l_order_by_start := INSTR(upper(p_segment_info.sql_text(i)),'ORDER BY');
      l_from_start := INSTR(upper(p_segment_info.sql_text(i)),'FROM');
--
      if ((l_valueset_r.table_info.meaning_column_name is not null) or
         (l_valueset_r.table_info.id_column_name is not null)) then

      if ((l_valueset_r.table_info.meaning_column_name <>
           l_valueset_r.table_info.value_column_name) or
         (l_valueset_r.table_info.id_column_name <>
          l_valueset_r.table_info.value_column_name)) then

      if ((l_valueset_r.table_info.where_clause is null) or
          (INSTR(upper(p_segment_info.sql_text(i)),'WHERE') = 0)) then
       if l_valueset_r.table_info.id_column_name is null then
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 50);
END IF;

--
         l_additional_and_clause := ' WHERE '||l_valueset_r.table_info.
                                    value_column_name||' = '||g_app_col_placeholder||
                                 p_segment_info.application_column_name(i)||' ';
       else
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 55);
END IF;

--
         l_additional_and_clause := ' WHERE '||l_valueset_r.table_info.
                                    id_column_name||' = '||g_app_col_placeholder||
                                 p_segment_info.application_column_name(i)||' ';
       end if;
      else
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 60);
END IF;

--
       if l_valueset_r.table_info.id_column_name is null then
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 70);
END IF;

--
   l_additional_and_clause := ' AND '||l_valueset_r.table_info.value_column_name
                     ||' = '||g_app_col_placeholder||p_segment_info.application_column_name(i)||' ';
       else
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 75);
END IF;

--
   l_additional_and_clause := ' AND '||l_valueset_r.table_info.id_column_name
                     ||' = '||g_app_col_placeholder||p_segment_info.application_column_name(i)||' ';
       end if;
      end if;
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 80);
END IF;

--
--
-- Build the SQL for the FROM clause
--
      if(l_order_by_start >0) then
          l_from_where := substr(p_segment_info.sql_text(i),l_from_start,(
                                            l_order_by_start-l_from_start));
      else
          l_from_where := substr(p_segment_info.sql_text(i),l_from_start);
      end if;
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 90);
END IF;

--
      if(l_valueset_r.table_info.meaning_column_name is not null) then
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                    meaning_column_name||' ';
      else
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                      value_column_name||' ';
      end if;
--
-- Set the description SQL - i.e. the SQL needed to change the ID or
-- value into a description on the WEB page for example.
--
      p_segment_info.sql_txt_descr(i) := l_select_clause||l_from_where||
                                                     l_additional_and_clause;
--
      else
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 100);
END IF;

--
--
-- OK, we don't need a description SQL (for any one of a number of reasons -
-- see if clause above)
--
        p_segment_info.sql_txt_descr(i) := '';
      end if;
      else
--

IF g_debug THEN
        hr_utility.set_location(l_proc, 110);
END IF;

--
        p_segment_info.sql_txt_descr(i) := '';
      end if;
   elsif l_valueset_r.validation_type = 'I' then
--
   p_segment_info.validation_type(i) := 'INDEPENDENT';
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 120);
END IF;

--
--
-- Now do the same if the segment is independantly validated
--
   p_segment_info.sql_text(i) := 'SELECT FFV.FLEX_VALUE,FFVTL.DESCRIPTION,'||
--                       'FFV.FLEX_VALUE_ID  FROM ' ||
--
-- Bizarre fact: AOL require independent values rather than ids
-- even in validate in 'ID' mode.
--
                       'FFV.FLEX_VALUE  FROM ' ||
                       'FND_FLEX_VALUES FFV, FND_FLEX_VALUES_TL FFVTL'||
                       ' WHERE FFV.FLEX_VALUE_ID = FFVTL.FLEX_VALUE_ID' ||
                       ' AND FFV.FLEX_VALUE_SET_ID = ' || L_VALUE_SET_ID ||
                       ' AND FFV.ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(FFV.START_DATE_ACTIVE,'''||
                       P_SESSION_DATE||''')'||
                     ' AND NVL(FFV.END_DATE_ACTIVE,'''||
                       P_SESSION_DATE||''')'||
                       ' AND FFVTL.LANGUAGE = USERENV(''LANG'')';
--
-- We can hard code the DESC SQL this time, since we know explicitly
-- how independant value sets are built.  This should be changed once
-- we have the procedure from AOL.
--
         p_segment_info.sql_txt_descr(i) := 'SELECT nvl(DESCRIPTION,FLEX_VALUE)'||
                       ' FROM FND_FLEX_VALUES_VL'||
                       ' WHERE FLEX_VALUE_SET_ID =' || l_value_set_id ||
                       ' AND ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND FLEX_VALUE = '||g_app_col_placeholder||
                           p_segment_info.application_column_name(i);

        p_segment_info.number_parents(i) := 0;
--
-- Dependent value sets.  Again, can hard code some stuff.
-- For AOL data model changes must revisit this code.
-- Given time should convert to AOL interface
--
   elsif l_valueset_r.validation_type = 'D' then
--
   p_segment_info.validation_type(i) := 'DEPENDENT';
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 120);
END IF;

--
--
-- Now do the same if the segment is dependantly validated
--
   --
   -- Work out what the parent segment is, for replacing later
   --
      l_dep_parent_column_name := get_dependent_parent_column
                                     (p_segment_info => p_segment_info,
                                      p_segment_number =>i);

      if l_dep_parent_column_name <> hr_api.g_varchar2 then

   p_segment_info.sql_text(i) :=
' SELECT FLEX_VALUE,NVL(DESCRIPTION,FLEX_VALUE),FLEX_VALUE'||
'   FROM FND_FLEX_VALUES_VL'||
'  WHERE FLEX_VALUE_SET_ID = '||l_value_set_id||
 '   AND ENABLED_FLAG = ''Y'''||
 '   AND PARENT_FLEX_VALUE_LOW = '||g_app_col_placeholder||l_dep_parent_column_name||
 '   AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                       P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                       P_SESSION_DATE||''')';

   p_segment_info.sql_txt_descr(i) := 'SELECT nvl(DESCRIPTION,FLEX_VALUE)'||
                       ' FROM FND_FLEX_VALUES_VL'||
                       ' WHERE FLEX_VALUE_SET_ID =' || l_value_set_id ||
                       ' AND ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND FLEX_VALUE = '||g_app_col_placeholder||
                           p_segment_info.application_column_name(i);
      else
--
-- We can't reliably build the SQL list for this column,
-- hence we must pass no dependent information back.
--
    p_segment_info.sql_text(i) := '';
    p_segment_info.sql_txt_descr(i) := '';

      end if;
--
-- We can hard code the DESC SQL this time, since we know explicitly
-- how independant value sets are built.  This should be changed once
-- we have the procedure from AOL.
--

        p_segment_info.number_parents(i) := 1;

   elsif l_valueset_r.validation_type = 'P' then
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 130);
END IF;

        p_segment_info.validation_type(i) := 'PAIR';
--
-- Can't have parents below this line
--
        p_segment_info.number_parents(i) := 0;
        p_segment_info.sql_text(i) := '';
        p_segment_info.sql_txt_descr(i) := '';
   elsif l_valueset_r.validation_type = 'U' then
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 130);
END IF;

        p_segment_info.validation_type(i) := 'SPECIAL';
--
-- Can't have parents below this line
--
        p_segment_info.number_parents(i) := 0;
        p_segment_info.sql_text(i) := '';
        p_segment_info.sql_txt_descr(i) := '';


   end if;
   --
else -- have null value set id
--

IF g_debug THEN
   hr_utility.set_location(l_proc, 140);
END IF;

--
   p_segment_info.number_parents(i) := 0;
   p_segment_info.validation_type(i)           := null;
   p_segment_info.format_type(i)               := null;
   p_segment_info.alphanumeric_allowed_flag(i) := null;
   p_segment_info.uppercase_only_flag(i)       := null;
   p_segment_info.numeric_mode_flag(i)         := null;
   --
   --set default max length
   --
   IF p_flex_type = 'KEY' then
     IF p_flexfield_name = 'PEA' THEN
        p_segment_info.max_size(i) := 150;
     ELSE
        p_segment_info.max_size(i) := 60;
     END IF;
   ELSE
     p_segment_info.max_size(i) := 150;
   END IF;
   p_segment_info.max_value(i)                 := null;
   p_segment_info.min_value(i)                 := null;
   p_segment_info.longlist_enabled(i)          := false;
   p_segment_info.has_id(i)                    := false;
   p_segment_info.has_meaning(i)               := false;
--
-- Slight issue with GENERIC address structure and the web application
-- have to return some SQL text, or descr text for the country segment
-- even though this is unvalidated.
--
   if(((p_segment_info.application_column_name(i)='COUNTRY') and
     (p_context_code = 'GENERIC')) and
     (p_flexfield_name = 'Address Structure'))then
      p_segment_info.sql_text(i) := 'SELECT TERRITORY_SHORT_NAME,NULL,'||
                                    'TERRITORY_CODE FROM FND_TERRITORIES_VL '||
                                    'ORDER BY TERRITORY_SHORT_NAME';
      p_segment_info.sql_txt_descr(i) := 'SELECT TERRITORY_SHORT_NAME '||
                                         'FROM FND_TERRITORIES_VL '||
                                         'WHERE TERRITORY_CODE = '||g_app_col_placeholder||'COUNTRY';
   else
      p_segment_info.sql_text(i) := '';
      p_segment_info.sql_txt_descr(i) := '';
   end if;
end if;
--
end loop;

IF g_debug THEN
   hr_utility.set_location(' Leaving:'||l_proc, 150);
END IF;

   --
end get_validation_info;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_segments >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_segments
              (p_appl_short_name IN
                      fnd_application.application_short_name%TYPE,
               p_flexfield_name  IN
                      fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
               p_context_code    IN  VARCHAR2,
               p_enabled_only    IN  BOOLEAN,
               p_segments        OUT NOCOPY hr_segments_info,
               p_session_date    IN  DATE)
is
   --
   -- Declare local variables
   --
   l_flexfield fnd_dflex.dflex_r;
   l_flexinfo  fnd_dflex.dflex_dr;
   l_segments  fnd_dflex.segments_dr;
   l_hr_segments hr_segments_info;
   l_proc      varchar2(72);
   l_total_parents NUMBER :=0;
   --
begin
   --
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
   l_proc := g_package||'get_segments';
   hr_utility.set_location('Entering:'|| l_proc, 10);
END IF;

   --
   --
   -- Start by finding the flexfield
   --
   fnd_dflex.get_flexfield(p_appl_short_name,
                           p_flexfield_name,
                           l_flexfield,
                           l_flexinfo);
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 20);
END IF;

   --
   -- Now, given the flexfield information returned
   -- above, find the segment information
   --
   fnd_dflex.get_segments(fnd_dflex.make_context(l_flexfield,
                                                 p_context_code),
                          l_segments,
                          p_enabled_only);
   --
   l_hr_segments.nsegments := l_segments.nsegments;
   --
   -- For each of the segments returned, copy the information
   -- returned into the HR structure.
   --
   for i in 1 .. l_hr_segments.nsegments
   loop
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 30);
END IF;

   --
      l_hr_segments.application_column_name(i)
                      := l_segments.application_column_name(i);
      l_hr_segments.segment_name(i)  := l_segments.segment_name(i);
      l_hr_segments.sequence(i)      := l_segments.sequence(i);
      l_hr_segments.is_displayed(i)  := l_segments.is_displayed(i);
      l_hr_segments.display_size(i)  := l_segments.display_size(i);
      l_hr_segments.row_prompt(i)    := l_segments.row_prompt(i);
      l_hr_segments.column_prompt(i) := l_segments.column_prompt(i);
      l_hr_segments.is_enabled(i)    := l_segments.is_enabled(i);
      l_hr_segments.is_required(i)   := l_segments.is_required(i);
      l_hr_segments.description(i)   := l_segments.description(i);
      l_hr_segments.value_set(i)     := l_segments.value_set(i);
      l_hr_segments.default_type(i)  := l_segments.default_type(i);
      l_hr_segments.default_value(i) := l_segments.default_value(i);
      l_hr_segments.number_children(i) := 0;
      l_hr_segments.ak_region_code(i) := get_ak_region_code('DESCRIPTIVE',
                                      p_flexfield_name,
                                      p_context_code,
                                      l_hr_segments,
                                      i);
   end loop;
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 40);
END IF;

   --
   get_validation_info(p_segment_info => l_hr_segments,
                       p_session_date => p_session_date,
                       p_context_code => p_context_code,
                       p_flexfield_name => p_flexfield_name,
                       p_flex_type => 'DESC');
   --
   p_segments := l_hr_segments;
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 50);
END IF;

end get_segments;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< build_sql_text >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE build_sql_text(
			 p_sql_text IN OUT NOCOPY long,
			 p_application_short_name IN fnd_application.application_short_name%TYPE,
			 p_application_table_name IN fnd_tables.table_name%TYPE,
			 p_segment_name_value IN segments) IS


BEGIN

   build_sql_text
              (p_sql_text => p_sql_text,
               p_application_short_name => p_application_short_name,
               p_application_table_name => p_application_table_name,
               p_column_name1   => p_segment_name_value.segment_name(1),
               p_column_value1  => p_segment_name_value.segment_value(1),
               p_column_name2   => p_segment_name_value.segment_name(2),
               p_column_value2  => p_segment_name_value.segment_value(2),
               p_column_name3   => p_segment_name_value.segment_name(3),
               p_column_value3  => p_segment_name_value.segment_value(3),
               p_column_name4   => p_segment_name_value.segment_name(4),
               p_column_value4  => p_segment_name_value.segment_value(4),
               p_column_name5   => p_segment_name_value.segment_name(5),
               p_column_value5  => p_segment_name_value.segment_value(5),
               p_column_name6   => p_segment_name_value.segment_name(6),
               p_column_value6  => p_segment_name_value.segment_value(6),
               p_column_name7   => p_segment_name_value.segment_name(7),
               p_column_value7  => p_segment_name_value.segment_value(7),
               p_column_name8   => p_segment_name_value.segment_name(8),
               p_column_value8  => p_segment_name_value.segment_value(8),
               p_column_name9   => p_segment_name_value.segment_name(9),
               p_column_value9  => p_segment_name_value.segment_value(9),
               p_column_name10  => p_segment_name_value.segment_name(10),
               p_column_value10 => p_segment_name_value.segment_value(10),
               p_column_name11  => p_segment_name_value.segment_name(11),
               p_column_value11 => p_segment_name_value.segment_value(11),
               p_column_name12  => p_segment_name_value.segment_name(12),
               p_column_value12 => p_segment_name_value.segment_value(12),
               p_column_name13  => p_segment_name_value.segment_name(13),
               p_column_value13 => p_segment_name_value.segment_value(13),
               p_column_name14  => p_segment_name_value.segment_name(14),
               p_column_value14 => p_segment_name_value.segment_value(14),
               p_column_name15  => p_segment_name_value.segment_name(15),
               p_column_value15 => p_segment_name_value.segment_value(15),
               p_column_name16  => p_segment_name_value.segment_name(16),
               p_column_value16 => p_segment_name_value.segment_value(16),
               p_column_name17  => p_segment_name_value.segment_name(17),
               p_column_value17 => p_segment_name_value.segment_value(17),
               p_column_name18  => p_segment_name_value.segment_name(18),
               p_column_value18 => p_segment_name_value.segment_value(18),
               p_column_name19  => p_segment_name_value.segment_name(19),
               p_column_value19 => p_segment_name_value.segment_value(19),
               p_column_name20  => p_segment_name_value.segment_name(20),
               p_column_value20 => p_segment_name_value.segment_value(20),
               p_column_name21  => p_segment_name_value.segment_name(21),
               p_column_value21 => p_segment_name_value.segment_value(21),
               p_column_name22  => p_segment_name_value.segment_name(22),
               p_column_value22 => p_segment_name_value.segment_value(22),
               p_column_name23  => p_segment_name_value.segment_name(23),
               p_column_value23 => p_segment_name_value.segment_value(23),
               p_column_name24  => p_segment_name_value.segment_name(24),
               p_column_value24 => p_segment_name_value.segment_value(24),
               p_column_name25  => p_segment_name_value.segment_name(25),
               p_column_value25 => p_segment_name_value.segment_value(25),
               p_column_name26  => p_segment_name_value.segment_name(26),
               p_column_value26 => p_segment_name_value.segment_value(26),
               p_column_name27  => p_segment_name_value.segment_name(27),
               p_column_value27 => p_segment_name_value.segment_value(27),
               p_column_name28  => p_segment_name_value.segment_name(28),
               p_column_value28 => p_segment_name_value.segment_value(28),
               p_column_name29  => p_segment_name_value.segment_name(29),
               p_column_value29 => p_segment_name_value.segment_value(29),
               p_column_name30  => p_segment_name_value.segment_name(30),
               p_column_value30 => p_segment_name_value.segment_value(30));

END build_sql_text;

PROCEDURE build_sql_text
              (p_sql_text       IN OUT NOCOPY long,
               p_application_short_name in
                          fnd_application.application_short_name%TYPE,
               p_application_table_name in fnd_tables.table_name%TYPE,
               p_column_name1   IN VARCHAR2 default null,
               p_column_value1  IN VARCHAR2 default null,
               p_column_name2   IN VARCHAR2 default null,
               p_column_value2  IN VARCHAR2 default null,
               p_column_name3   IN VARCHAR2 default null,
               p_column_value3  IN VARCHAR2 default null,
               p_column_name4   IN VARCHAR2 default null,
               p_column_value4  IN VARCHAR2 default null,
               p_column_name5   IN VARCHAR2 default null,
               p_column_value5  IN VARCHAR2 default null,
               p_column_name6   IN VARCHAR2 default null,
               p_column_value6  IN VARCHAR2 default null,
               p_column_name7   IN VARCHAR2 default null,
               p_column_value7  IN VARCHAR2 default null,
               p_column_name8   IN VARCHAR2 default null,
               p_column_value8  IN VARCHAR2 default null,
               p_column_name9   IN VARCHAR2 default null,
               p_column_value9  IN VARCHAR2 default null,
               p_column_name10   IN VARCHAR2 default null,
               p_column_value10  IN VARCHAR2 default null,
               p_column_name11   IN VARCHAR2 default null,
               p_column_value11  IN VARCHAR2 default null,
               p_column_name12   IN VARCHAR2 default null,
               p_column_value12  IN VARCHAR2 default null,
               p_column_name13   IN VARCHAR2 default null,
               p_column_value13  IN VARCHAR2 default null,
               p_column_name14   IN VARCHAR2 default null,
               p_column_value14  IN VARCHAR2 default null,
               p_column_name15   IN VARCHAR2 default null,
               p_column_value15  IN VARCHAR2 default null,
               p_column_name16   IN VARCHAR2 default null,
               p_column_value16  IN VARCHAR2 default null,
               p_column_name17   IN VARCHAR2 default null,
               p_column_value17  IN VARCHAR2 default null,
               p_column_name18   IN VARCHAR2 default null,
               p_column_value18  IN VARCHAR2 default null,
               p_column_name19   IN VARCHAR2 default null,
               p_column_value19  IN VARCHAR2 default null,
               p_column_name20   IN VARCHAR2 default null,
               p_column_value20  IN VARCHAR2 default null,
               p_column_name21   IN VARCHAR2 default null,
               p_column_value21  IN VARCHAR2 default null,
               p_column_name22   IN VARCHAR2 default null,
               p_column_value22  IN VARCHAR2 default null,
               p_column_name23   IN VARCHAR2 default null,
               p_column_value23  IN VARCHAR2 default null,
               p_column_name24   IN VARCHAR2 default null,
               p_column_value24  IN VARCHAR2 default null,
               p_column_name25   IN VARCHAR2 default null,
               p_column_value25  IN VARCHAR2 default null,
               p_column_name26   IN VARCHAR2 default null,
               p_column_value26  IN VARCHAR2 default null,
               p_column_name27   IN VARCHAR2 default null,
               p_column_value27  IN VARCHAR2 default null,
               p_column_name28   IN VARCHAR2 default null,
               p_column_value28  IN VARCHAR2 default null,
               p_column_name29   IN VARCHAR2 default null,
               p_column_value29  IN VARCHAR2 default null,
               p_column_name30   IN VARCHAR2 default null,
               p_column_value30  IN VARCHAR2 default null) IS
--
-- Declare local variables
--
   l_column_type  fnd_columns.column_type%TYPE;
   l_placeholder_string_length NUMBER := length(g_app_col_placeholder);
   l_placeholder  NUMBER;
   l_end_placeholder NUMBER;
   l_replace_string VARCHAR2(2000);
   l_replace_value VARCHAR2(2000);
   l_application_column_name VARCHAR2(2000);
   l_no_replace_value VARCHAR2(2) :='N';
   l_proc      varchar2(72);
begin
--
-- Start big loop for replacing the values
-- We shouldn't expect any value to appear only once
--
--
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
   l_proc := g_package||'build_sql_text';
   hr_utility.set_location('Entering:'|| l_proc, 10);
END IF;

   --
   if(instr(p_sql_text,g_app_col_placeholder)>0) then

   LOOP
--
-- Find the instance of a placeholder in the text
-- Use this to work out which column name needs replacing
--
      l_placeholder := INSTR(p_sql_text,g_app_col_placeholder);

   EXIT WHEN ((l_placeholder < 1) OR (l_no_replace_value='Y'));
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 20);
END IF;

   --
   -- Need to update this to take account of carriage returns etc.
   --
      l_end_placeholder := INSTR(p_sql_text,' ',l_placeholder);
      if (l_end_placeholder > 0) then
        l_replace_string := substr(p_sql_text,l_placeholder,(l_end_placeholder -
                                 l_placeholder));
      else
        l_replace_string := substr(p_sql_text,l_placeholder);
      end if;

      l_application_column_name := substr(l_replace_string,(l_placeholder_string_length+1));

--
--  Obtain type of application column name.  Do this because in order
--  for the SQL to run correctly, we must change the way we add the
--  value into the string.
--  The default type is taken as varchar2. The package will not generate
--  a when no data found error.
--
    BEGIN
          select c.column_type into l_column_type
          from   fnd_application a,
                 fnd_tables t,
                 fnd_columns c
          where  c.column_name = l_application_column_name
          and    c.table_id = t.table_id
          and    c.application_id = a.application_id
          and    t.application_id = a.application_id
          and    t.table_name = p_application_table_name
          and    a.application_short_name = p_application_short_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           hr_utility.trace(' Exception in hr_flexfield_info.build_sql_text ' || SQLERRM );
           hr_utility.trace(' Table Name ' || p_application_table_name );
           hr_utility.trace(' Column Name ' || l_application_column_name );
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 30);
END IF;

   --
                 p_sql_text := 'FAILURE: Column '||l_application_column_name||
                               ' is not present in FND_COLUMNS. Unknown '||
                               'column type.  Please specify.';

           raise;
    END;
--
-- Test for, and replace the existing bind variable with
-- value sent to procedure
--
   --

IF g_debug THEN
   hr_utility.set_location(l_proc, 40);
END IF;

   --
   if (l_application_column_name = p_column_name1) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value1;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value1||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name2) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value2;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value2||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name3) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value3;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value3||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name4) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value4;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value4||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name5) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value5;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value5||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name6) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value6;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value6||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name7) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value7;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value7||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name8) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value8;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value8||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name9) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value9;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value9||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name10) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value10;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value10||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name11) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value11;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value11||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name12) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value12;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value12||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name13) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value13;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value13||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name14) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value14;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value14||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name15) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value15;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value15||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name16) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value16;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value16||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name17) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value17;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value17||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name18) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value18;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value18||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name19) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value19;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value19||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name20) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value20;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value20||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name21) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value21;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value21||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name22) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value22;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value22||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name23) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value23;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value23||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name24) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value24;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value24||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name25) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value25;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value25||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name26) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value26;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value26||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name27) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value27;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value27||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name28) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value28;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value28||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name29) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value29;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value29||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   elsif (l_application_column_name = p_column_name30) then
      if (l_column_type = 'N') then
         l_replace_value := p_column_value30;
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      else
         l_replace_value := ''''||p_column_value30||'''';
         p_sql_text := replace(p_sql_text,l_replace_string,l_replace_value);
      end if;
   else
     -- There is a missing value - i.e. this procedure can not complete
     -- its task.  Reset the SQL text with this information, and exit
     -- the loop.  This is necessary because the loop will continue
     -- idenfinitely if this flag is not set.
        p_sql_text := 'FAILURE (HR_FLEXFIELD_INFO.BUILD SQL TEXT):'||c_newline||
                      'There was no supplied value for the column'||
                      l_application_column_name;
        l_no_replace_value:='Y';
   end if;

   END LOOP;

   end if;

   --

IF g_debug THEN
   hr_utility.set_location('Leaving:'|| l_proc, 50);
END IF;

   --
end build_sql_text;
-- ----------------------------------------------------------------------------
-- |-------------------< get_kf_concatenated_structures >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_kf_concatenated_structures
(p_appl_short_name   IN     fnd_application.application_short_name%TYPE
,p_id_flex_code      IN     fnd_id_flex_structures_vl.id_flex_code%TYPE
,p_enabled_only      IN     BOOLEAN
,p_concatenation_chr IN     VARCHAR2
,p_structure_list       OUT NOCOPY LONG
) is
  l_flexfield              fnd_flex_key_api.flexfield_type;
  l_nstructures            number;
  l_id_flex_num_list       fnd_flex_key_api.structure_list;
  l_structure_list         long;
  l_structure              fnd_flex_key_api.structure_type;
  --
  i      binary_integer;
  l_proc varchar2(72);
begin
g_debug := hr_utility.debug_enabled;
  p_structure_list := null;
  --
  -- Get the flexfield.
  --

IF g_debug THEN
  l_proc := g_package||'get_kf_concatenated_structures';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  fnd_flex_key_api.set_session_mode(session_mode => 'seed_data');
  l_flexfield :=
  fnd_flex_key_api.find_flexfield
  (appl_short_name => p_appl_short_name
  ,flex_code       => p_id_flex_code
  );
  --
  -- Get the flexfield structures.
  --

IF g_debug THEN
  hr_utility.set_location(l_proc, 10);
END IF;

  fnd_flex_key_api.get_structures
  (flexfield     => l_flexfield
  ,enabled_only  => p_enabled_only
  ,nstructures   => l_nstructures
  ,structures    => l_id_flex_num_list
  );
  --
  -- Concatenate the structures.
  --
  i := l_id_flex_num_list.first;
  loop
    exit when not l_id_flex_num_list.exists(i);
    --
    -- fnd_flex_key_api.get_structures returns a table of id_flex_num
    -- values. These values must be converted to translated structure
    -- names.
    --
    l_structure :=
    fnd_flex_key_api.find_structure
    (flexfield        => l_flexfield
    ,structure_number => l_id_flex_num_list(i)
    );
    --
    -- Add to the the list.
    --
    l_structure_list :=
    l_structure_list || p_concatenation_chr || l_structure.structure_name;
    --
    i := l_id_flex_num_list.next(i);
  end loop;
  --
  p_structure_list := ltrim(l_structure_list,p_concatenation_chr);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end get_kf_concatenated_structures;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_kf_segments >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_kf_segments
(p_appl_short_name IN  fnd_application.application_short_name%TYPE
,p_id_flex_code    IN  fnd_id_flex_structures_vl.id_flex_code%TYPE
,p_id_flex_structure_name IN
 fnd_id_flex_structures_vl.id_flex_structure_name%TYPE
,p_enabled_only    IN  BOOLEAN
,p_segments        OUT NOCOPY hr_segments_info
,p_session_date    IN  DATE
) is
  --
  -- Declare local variables.
  --
  l_segments      hr_segments_info;
  l_flexfield     fnd_flex_key_api.flexfield_type;
  l_segment_list  fnd_flex_key_api.segment_list;
  l_segment_info  fnd_flex_key_api.segment_type;
  l_nsegments     number;
  l_structure     fnd_flex_key_api.structure_type;
  l_structure_code fnd_id_flex_structures.id_flex_structure_code%TYPE;
  l_total_parents number :=0;
  --
  i               number;
  l_proc          varchar2(72);
begin
  --
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package||'get_kf_segments';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  -- Get the flexfield.
  --
  fnd_flex_key_api.set_session_mode(session_mode => 'seed_data');
  l_flexfield :=
  fnd_flex_key_api.find_flexfield
  (appl_short_name => p_appl_short_name
  ,flex_code       => p_id_flex_code
  );
  --
  -- Get the flexfield structure.
  --


IF g_debug THEN
  hr_utility.set_location(l_proc, 10);
END IF;


/*
  l_structure :=
  fnd_flex_key_api.find_structure
  (flexfield       => l_flexfield
  --,structure_title => p_id_flex_structure_name
   ,structure_code  => upper(replace(p_id_flex_structure_name,' ','_'))
  );
*/
  -- fix for bug 1259164
  SELECT id_flex_structure_code
  INTO l_structure_code
  FROM fnd_id_flex_structures_vl
  WHERE application_id = l_flexfield.application_id
  AND id_flex_code = l_flexfield.flex_code
  AND id_flex_structure_name = p_id_flex_structure_name;

  l_structure :=
  fnd_flex_key_api.find_structure
  (flexfield       => l_flexfield
  ,structure_code  => l_structure_code);


  --
  -- Now, given the flexfield information returned
  -- above, find the segment information
  --

IF g_debug THEN
  hr_utility.set_location(l_proc, 20);
END IF;

  fnd_flex_key_api.get_segments
  (flexfield    => l_flexfield
  ,structure    => l_structure
  ,enabled_only => p_enabled_only
  ,nsegments    => l_nsegments
  ,segments     => l_segment_list
  );
  --
  -- For each of the segments returned, copy the information
  -- returned into the HR structure.
  --
  l_segments.nsegments := l_nsegments;
  i := l_segment_list.first;
  loop

IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
END IF;

    exit when not l_segment_list.exists(i);
    --
    -- For each segment get the segment information.
    --

IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
END IF;

    l_segment_info :=
    fnd_flex_key_api.find_segment
    (flexfield    => l_flexfield
    ,structure    => l_structure
    ,segment_name => l_segment_list(i)
    );
    --
    -- Set up the returned segment information.
    --

IF g_debug THEN
    hr_utility.set_location(l_proc, 40);
END IF;

    l_segments.application_column_name(i) := l_segment_info.column_name;
    l_segments.segment_name(i)   := l_segment_list(i);
    l_segments.sequence(i)       := l_segment_info.segment_number;
    l_segments.is_displayed(i)   := upper(l_segment_info.displayed_flag) = 'Y';
    l_segments.display_size(i)   := l_segment_info.display_size;
    l_segments.row_prompt(i)     := l_segment_info.window_prompt;
    l_segments.column_prompt(i)  := l_segment_info.lov_prompt;
    l_segments.is_enabled(i)     := upper(l_segment_info.enabled_flag) = 'Y';
    l_segments.is_required(i)    := upper(l_segment_info.required_flag) = 'Y';
    l_segments.description(i)    := l_segment_info.description;
    l_segments.value_set(i)      := l_segment_info.value_set_id;
    l_segments.default_type(i)   := l_segment_info.default_type;
    l_segments.default_value(i)  := l_segment_info.default_value;
    l_segments.number_children(i) := 0;
    l_segments.ak_region_code(i) :=
    hr_flexfield_info.get_ak_region_code
    (p_flex_type => 'KEY'
    ,p_flexfield_name => p_id_flex_code
    ,p_context_code   => to_char(l_structure.structure_number)
    ,p_segment_info   => l_segments
    ,p_segment_number => i
    );
    --
    i := l_segment_list.next(i);
  end loop;
  --
  -- Pass context_code and flexfield_name as null to get_validation_info
  -- because they're only required for a descriptive flexfield hack.
  --
  -- Exception for Key Flex PEA:
  -- For bug 2462181 we need to pass flex name as that is the only way
  -- to know if it is Personal Analysis flex (PEA)
  --

IF g_debug THEN
  hr_utility.set_location(l_proc, 50);
END IF;

  hr_flexfield_info.get_validation_info
  (p_segment_info   => l_segments
  ,p_session_date   => p_session_date
  ,p_context_code   => null
  ,p_flexfield_name => p_id_flex_code
  ,p_flex_type => 'KEY'
  );
  --
  -- Pass out the segment information.
  --
  p_segments := l_segments;

IF g_debug THEN
  hr_utility.set_location(l_proc, 60);
END IF;

end get_kf_segments;
--
-- ----------------------------------------------------------------------------
-- |------------------------< gen_ak_web_region_code >------------------------|
-- ----------------------------------------------------------------------------
--
function gen_ak_web_region_code
(p_flex_type              in varchar2
,p_flexfield              in varchar2
,p_context_or_id_flex_num in varchar2
,p_segment                in varchar2
) return varchar2 is
l_lookup_code     fnd_common_lookups.lookup_code%type;
begin
if p_flex_type <> 'KEY' then
  return substr(p_flexfield, 1, 5) ||
         substr(p_context_or_id_flex_num, 1, 4) ||
         substr(p_segment, 1, 20);
else
  return p_flexfield||
         substr(p_context_or_id_flex_num, 1, 5) ||
         substr(p_segment, 1, 20);
end if;
end;
--
end hr_flexfield_info;

/
