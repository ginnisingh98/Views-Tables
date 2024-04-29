--------------------------------------------------------
--  DDL for Package Body FND_FLEX_HIERARCHY_COMPILER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_HIERARCHY_COMPILER" AS
/* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */


-- ======================================================================
--   Compiler Example
-- ======================================================================
--   North America Country, State, City Hierarchy.
--
--   FND_FLEX_VALUE_NORM_HIERARCHY
--   ===========================================
--   PARENT     CHILD_LOW  CHILD_HIGH  RANGE
--   ---------- ---------- ----------- ----------
--   CA         LA         LA          C
--   CA         SF         SF          C
--   CAN        Tor        Tor         C
--   US         Ch         Ch          C
--   NA         CAN        CAN         P
--   NA         US         US          P
--   US         CA         CA          P
--   US         NY         NY          P
--
--   FND_FLEX_VALUE_HIERARCHIES
--   ===========================================
--   PARENT  CHILD_LOW CHILD_HIGH COMMENT
--   ------- --------- ---------- ----------
--   CA      LA        LA         CA:LA-LA
--   CA      SF        SF         CA:SF-SF
--   CAN     Tor       Tor        CAN:Tor-Tor
--   US      Ch        Ch         US:Ch-Ch
--   NA      Tor       Tor        NA:CAN-CAN -> CAN:Tor-Tor
--   NA      Ch        Ch         NA:US-US -> US:Ch-Ch
--   NA      LA        LA         NA:US-US -> US:CA-CA -> CA:LA-LA
--   NA      SF        SF         NA:US-US -> US:CA-CA -> CA:SF-SF
--   US      LA        LA         US:CA-CA -> CA:LA-LA
--   US      SF        SF         US:CA-CA -> CA:SF-SF
--
--   FND_FLEX_VALUE_HIER_ALL
--   ===========================================
--   PARENT  CHILD_LOW CHILD_HIGH RANGE LEVEL COMMENT
--   ------- --------- ---------- ----- ----- ----------
--   CA      LA        LA         C     1     CA:LA-LA
--   CA      SF        SF         C     1     CA:SF-SF
--   CAN     Tor       Tor        C     1     CAN:Tor-Tor
--   US      Ch        Ch         C     1     US:Ch-Ch
--   NA      CAN       CAN        P     1     NA:CAN-CAN
--   NA      Tor       Tor        C     2     NA:CAN-CAN -> CAN:Tor-Tor
--   NA      US        US         P     1     NA:US-US
--   NA      Ch        Ch         C     2     NA:US-US -> US:Ch-Ch
--   NA      CA        CA         P     2     NA:US-US -> US:CA-CA
--   NA      LA        LA         C     3     NA:US-US -> US:CA-CA -> CA:LA-LA
--   NA      SF        SF         C     3     NA:US-US -> US:CA-CA -> CA:SF-SF
--   NA      NY        NY         P     2     NA:US-US -> US:NY-NY
--   US      CA        CA         P     1     US:CA-CA
--   US      LA        LA         C     2     US:CA-CA -> CA:LA-LA
--   US      SF        SF         C     2     US:CA-CA -> CA:SF-SF
--   US      NY        NY         P     1     US:NY-NY
--
-- ======================================================================

-- ======================================================================
-- Package Globals.
-- ======================================================================
TYPE hierarchy_record IS RECORD
  (parent_flex_value     fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE,
   child_flex_value_low  fnd_flex_value_norm_hierarchy.child_flex_value_low%TYPE,
   child_flex_value_high fnd_flex_value_norm_hierarchy.child_flex_value_high%TYPE,
   range_attribute       fnd_flex_value_norm_hierarchy.range_attribute%TYPE);

TYPE hierarchy_array IS TABLE OF hierarchy_record INDEX BY BINARY_INTEGER;

TYPE varchar2_array IS TABLE OF fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE INDEX BY BINARY_INTEGER;

--
-- Cycle Checker
--
g_parent_path_values      varchar2_array;
g_parent_path_value_count NUMBER;

SUBTYPE vset_type IS fnd_flex_value_sets%ROWTYPE;
g_vset                   vset_type;
g_user_id                NUMBER := -1;
g_insert_count           NUMBER := 0;
g_commit_size            NUMBER := 500;
g_message_size           NUMBER := 1950;
g_debug_on               BOOLEAN := FALSE;
g_newline                VARCHAR2(10);
g_exception_depth        NUMBER := 0;
g_error_message          VARCHAR2(32000);
g_api_name               CONSTANT VARCHAR2(10) := 'HIER';
g_date_mask              CONSTANT VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';

--
-- Error Codes
--
error_others                  NUMBER := -20100;
error_no_value_set            NUMBER := -20101;
error_delete_hierarchies      NUMBER := -20102;
error_cyclic_hierarchy        NUMBER := -20103;
error_unknown_range_attribute NUMBER := -20104;
error_update_hierarchies      NUMBER := -20105;


-- ======================================================================
-- PROCEDURE : set_debug
-- ======================================================================
-- Turns debug setting ON/OFF
--
PROCEDURE set_debug(p_debug_flag IN VARCHAR2)
  IS
BEGIN
   IF (Nvl(p_debug_flag, 'N') = 'Y') THEN
      g_debug_on := TRUE;
    ELSE
      g_debug_on := FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      g_debug_on := FALSE;
END set_debug;

-- ======================================================================
-- PROCEDURE : debug
-- ======================================================================
-- Sends debug messages to Log file.
--
PROCEDURE debug(p_debug IN VARCHAR2)
  IS
BEGIN
   IF (g_debug_on) THEN
      fnd_file.put_line(fnd_file.Log, p_debug);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END debug;

-- ======================================================================
-- PROCEDURE : init_parent_path
-- ======================================================================
-- Initializes the parent path array.
--
PROCEDURE init_parent_path
  IS
BEGIN
   g_parent_path_value_count := 0;
END init_parent_path;

-- ======================================================================
-- PROCEDURE : add_to_parent_path
-- ======================================================================
-- Adds a parent value to the end of the parent path array.
--
PROCEDURE add_to_parent_path(p_parent_flex_value IN fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE)
  IS
BEGIN
   g_parent_path_values(g_parent_path_value_count) := p_parent_flex_value;
   g_parent_path_value_count := g_parent_path_value_count + 1;
END add_to_parent_path;

-- ======================================================================
-- PROCEDURE : remove_from_parent_path
-- ======================================================================
-- Removes the last value from the end of the parent path array.
--
PROCEDURE remove_from_parent_path
  IS
BEGIN
   g_parent_path_value_count := g_parent_path_value_count - 1;
END remove_from_parent_path;

-- ======================================================================
-- FUNCTION : exists_in_parent_path
-- ======================================================================
-- Checks if a parent value exists in the parent path array.
--
FUNCTION exists_in_parent_path(p_parent_flex_value IN fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE)
  RETURN BOOLEAN
  IS
     l_exists BOOLEAN;
BEGIN
   l_exists := FALSE;
   FOR i IN 0 .. g_parent_path_value_count - 1 LOOP
      IF (g_parent_path_values(i) = p_parent_flex_value) THEN
         l_exists := TRUE;
         EXIT;
      END IF;
   END LOOP;

   RETURN l_exists;
END exists_in_parent_path;

-- ======================================================================
-- FUNCTION : get_formatted_method_call
-- ======================================================================
-- Returns formatted method call
--
-- p_method - name of the method
-- p_arg1..5 - method arguments
--
-- return: formatted method call
--
FUNCTION get_formatted_method_call(p_method in varchar2,
                                   p_arg1   in varchar2 default null,
                                   p_arg2   in varchar2 default null,
                                   p_arg3   in varchar2 default null,
                                   p_arg4   in varchar2 default null,
                                   p_arg5   in varchar2 default null)
   return varchar2
is
   l_method varchar2(32000);
begin
   l_method := p_method || '(';

   if (p_arg1 is not null) then
      l_method := l_method || p_arg1;
   end if;

   if (p_arg2 is not null) then
      l_method := l_method || ', ' || p_arg2;
   end if;

   if (p_arg3 is not null) then
      l_method := l_method || ', ' || p_arg3;
   end if;

   if (p_arg4 is not null) then
      l_method := l_method || ', ' || p_arg4;
   end if;

   if (p_arg5 is not null) then
      l_method := l_method || ', ' || p_arg5;
   end if;

   l_method := l_method || ')';

   return l_method;

exception
   when others then
      return p_method;
end get_formatted_method_call;

-- ======================================================================
-- FUNCTION : get_formatted_lines
-- ======================================================================
-- Returns formatted error lines.
--
-- p_line0 - The first line that goes after ORA error number
-- p_line1..5 - optional lines to be indented
--
-- return: formatted error message
--
FUNCTION get_formatted_lines(p_line0 in varchar2,
                             p_line1 in varchar2 default null,
                             p_line2 in varchar2 default null,
                             p_line3 in varchar2 default null,
                             p_line4 in varchar2 default null,
                             p_line5 in varchar2 default null)
   return varchar2
is
   l_error_text     varchar2(32000);
   l_newline_indent varchar2(2000);
begin
   l_newline_indent := g_newline || rpad(' ', 11, ' ');

   l_error_text := p_line0;

   if (p_line1 is not null) then
      l_error_text := l_error_text || l_newline_indent || p_line1;
   end if;

   if (p_line2 is not null) then
      l_error_text := l_error_text || l_newline_indent || p_line2;
   end if;

   if (p_line3 is not null) then
      l_error_text := l_error_text || l_newline_indent || p_line3;
   end if;

   if (p_line4 is not null) then
      l_error_text := l_error_text || l_newline_indent || p_line4;
   end if;

   if (p_line5 is not null) then
      l_error_text := l_error_text || l_newline_indent || p_line5;
   end if;

   return l_error_text;

end get_formatted_lines;

-- ======================================================================
-- PROCEDURE : raise_formatted_error
-- ======================================================================
-- Raises formatted application error.
--
-- p_error_code - error code
-- p_error_text - error text
--
PROCEDURE raise_formatted_error(p_error_code in number,
                                p_error_text in varchar2)
is
   l_error_text varchar2(32000);
begin
   l_error_text := p_error_text || g_newline || dbms_utility.format_error_stack();

   raise_application_error(p_error_code, l_error_text);

exception
   when others then
      --
      -- Store the root cause of the problem. This will be presented to
      -- user as the main cause of the exception. Rest of the exception is
      -- basically the call stack trace.
      --
      if (g_exception_depth = 0) then
         g_error_message := dbms_utility.format_error_stack();
      end if;

      g_exception_depth := g_exception_depth + 1;

      raise;
end raise_formatted_error;

-- ======================================================================
-- PROCEDURE : raise_exception_error
-- ======================================================================
-- Raises exception by formatting the error lines.
--
-- p_error_code - error code
-- p_line0 - The first line that goes after ORA error number
-- p_line1..5 - optional lines to be indented
--
PROCEDURE raise_exception_error(p_error_code in number,
                                p_line0 in varchar2,
                                p_line1 in varchar2 default null,
                                p_line2 in varchar2 default null,
                                p_line3 in varchar2 default null,
                                p_line4 in varchar2 default null,
                                p_line5 in varchar2 default null)
  IS
     l_error_text VARCHAR2(32000);
BEGIN
   l_error_text := get_formatted_lines(p_line0,
                                       p_line1,
                                       p_line2,
                                       p_line3,
                                       p_line4,
                                       p_line5);

   raise_formatted_error(p_error_code, l_error_text);

   -- No exception handling here
END raise_exception_error;

-- ======================================================================
-- PROCEDURE : raise_others_error
-- ======================================================================
-- Raises formatted error for 'when others then' block
--
-- p_method - name of the method
-- p_arg1..5 - method arguments
--
PROCEDURE raise_others_error(p_method in varchar2,
                             p_arg1   in varchar2 default null,
                             p_arg2   in varchar2 default null,
                             p_arg3   in varchar2 default null,
                             p_arg4   in varchar2 default null,
                             p_arg5   in varchar2 default null)
is
   l_error_text varchar2(32000);
begin
   l_error_text := get_formatted_method_call(p_method,
                                             p_arg1,
                                             p_arg2,
                                             p_arg3,
                                             p_arg4,
                                             p_arg5);

   l_error_text := l_error_text || ' raised exception.';

   raise_formatted_error(error_others, l_error_text);

   -- No exception handling here
end raise_others_error;

-- ======================================================================
-- FUNCTION : get_vset
-- ======================================================================
-- Gets Value Set
--
PROCEDURE get_vset(p_flex_value_set    IN VARCHAR2,
                   x_vset              OUT nocopy vset_type)
  IS
BEGIN
   --
   -- Try it as FLEX_VALUE_SET_ID.
   --
   SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
     *
     INTO x_vset
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = To_number(p_flex_value_set);

   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      --
      -- ID didn't work, try it as FLEX_VALUE_SET_NAME.
      --
      BEGIN
         SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
           *
           INTO x_vset
           FROM fnd_flex_value_sets
           WHERE flex_value_set_name = p_flex_value_set;

         RETURN;

      EXCEPTION
         WHEN OTHERS THEN
            --
            -- NAME didn't work too.
            --
            raise_exception_error(error_no_value_set,
                                  'No data found in FND_FLEX_VALUE_SETS',
                                  'for flex value set ' || p_flex_value_set);
      END;
END get_vset;

-- ======================================================================
-- PROCEDURE : compile_child
-- ======================================================================
-- Inserts the child range into the de-normalized hierarchy table.
--
PROCEDURE compile_child(p_root_parent_flex_value IN VARCHAR2,
                        p_child_flex_value_low   IN VARCHAR2,
                        p_child_flex_value_high  IN VARCHAR2)
  IS
BEGIN
   INSERT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
     INTO fnd_flex_value_hierarchies
     (flex_value_set_id, parent_flex_value,
      child_flex_value_low, child_flex_value_high,
      last_update_date, last_updated_by,
      creation_date, created_by)
     VALUES
     (g_vset.flex_value_set_id*(-1), p_root_parent_flex_value,
      p_child_flex_value_low, p_child_flex_value_high,
      Sysdate, g_user_id,
      Sysdate, g_user_id);

   g_insert_count := g_insert_count + 1;
   IF (g_insert_count = g_commit_size) THEN
      COMMIT;
      g_insert_count := 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error('compile_child',
                         p_root_parent_flex_value,
                         p_child_flex_value_low,
                         p_child_flex_value_high);
END compile_child;

-- ======================================================================
-- PROCEDURE : compile_parent
-- ======================================================================
-- Recursively compiles the parent ranges.
--
PROCEDURE compile_parent(p_root_parent_flex_value IN VARCHAR2,
                         p_child_flex_value_low   IN VARCHAR2,
                         p_child_flex_value_high  IN VARCHAR2,
                         p_debug                  IN VARCHAR2)
  IS
     CURSOR norm_cur(p_child_flex_value_low  IN VARCHAR2,
                     p_child_flex_value_high IN VARCHAR2) IS
        SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
          parent_flex_value,
          child_flex_value_low,
          child_flex_value_high,
          range_attribute
          FROM fnd_flex_value_norm_hierarchy
          WHERE flex_value_set_id = g_vset.flex_value_set_id
          AND parent_flex_value >= p_child_flex_value_low
          AND parent_flex_value <= p_child_flex_value_high
          ORDER BY range_attribute, parent_flex_value,
          child_flex_value_low, child_flex_value_high;

     l_debug           VARCHAR2(32000);

     l_hierarchies     hierarchy_array;
     l_hierarchy_count BINARY_INTEGER;
BEGIN
   l_hierarchy_count := 0;
   FOR norm_rec IN norm_cur(p_child_flex_value_low,
                            p_child_flex_value_high) LOOP
      l_hierarchies(l_hierarchy_count).parent_flex_value     := norm_rec.parent_flex_value;
      l_hierarchies(l_hierarchy_count).child_flex_value_low  := norm_rec.child_flex_value_low;
      l_hierarchies(l_hierarchy_count).child_flex_value_high := norm_rec.child_flex_value_high;
      l_hierarchies(l_hierarchy_count).range_attribute       := norm_rec.range_attribute;
      l_hierarchy_count := l_hierarchy_count + 1;
   END LOOP;

   FOR i IN 0 .. l_hierarchy_count - 1 LOOP
      IF (g_debug_on) THEN
         l_debug := (p_debug || ' -> ' ||
                     l_hierarchies(i).range_attribute || ':' ||
                     l_hierarchies(i).parent_flex_value || ':' ||
                     l_hierarchies(i).child_flex_value_low || '-' ||
                     l_hierarchies(i).child_flex_value_high);
         debug(l_debug);
      END IF;

      IF (l_hierarchies(i).range_attribute = 'C') THEN
         compile_child(p_root_parent_flex_value,
                       l_hierarchies(i).child_flex_value_low,
                       l_hierarchies(i).child_flex_value_high);

       ELSIF (l_hierarchies(i).range_attribute = 'P') THEN
         --
         -- Cycle check
         --
         IF (exists_in_parent_path(l_hierarchies(i).parent_flex_value)) THEN
            raise_exception_error(error_cyclic_hierarchy,
                                  'Cyclic hierarchy detected.',
                                  'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                                  'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                                  'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                                  'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
         END IF;

         --
         -- Recursive call.
         --
         add_to_parent_path(l_hierarchies(i).parent_flex_value);
         compile_parent(p_root_parent_flex_value,
                        l_hierarchies(i).child_flex_value_low,
                        l_hierarchies(i).child_flex_value_high,
                        l_debug);
         remove_from_parent_path();

       ELSE
         raise_exception_error(error_unknown_range_attribute,
                               'Unknown Range Attribute detected.',
                               'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                               'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                               'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                               'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
      END IF;
  END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error('compile_parent',
                         p_root_parent_flex_value,
                         p_child_flex_value_low,
                         p_child_flex_value_high);
END compile_parent;

-- ======================================================================
-- PROCEDURE : compile_value_hierarchies
-- ======================================================================
-- Compiles the flex value hierarchies in FND_FLEX_VALUE_HIERARCHIES table.
--
PROCEDURE compile_value_hierarchies
  IS
     CURSOR main_norm_cur IS
        SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
          parent_flex_value,
          child_flex_value_low,
          child_flex_value_high,
          range_attribute
          FROM fnd_flex_value_norm_hierarchy
          WHERE flex_value_set_id = g_vset.flex_value_set_id
          ORDER BY range_attribute, parent_flex_value,
          child_flex_value_low, child_flex_value_high;

     l_debug           VARCHAR2(32000);

     l_hierarchies     hierarchy_array;
     l_hierarchy_count BINARY_INTEGER;
BEGIN
   g_insert_count := 0;
   l_hierarchy_count := 0;
   FOR main_norm_rec IN main_norm_cur LOOP
      l_hierarchies(l_hierarchy_count).parent_flex_value     := main_norm_rec.parent_flex_value;
      l_hierarchies(l_hierarchy_count).child_flex_value_low  := main_norm_rec.child_flex_value_low;
      l_hierarchies(l_hierarchy_count).child_flex_value_high := main_norm_rec.child_flex_value_high;
      l_hierarchies(l_hierarchy_count).range_attribute       := main_norm_rec.range_attribute;
      l_hierarchy_count := l_hierarchy_count + 1;
   END LOOP;

   --
   -- Initialize the cycle checking logic
   --
   init_parent_path();

   FOR i IN 0 .. l_hierarchy_count - 1 LOOP
      IF (g_debug_on) THEN
         l_debug := (l_hierarchies(i).range_attribute || ':' ||
                     l_hierarchies(i).parent_flex_value || ':' ||
                     l_hierarchies(i).child_flex_value_low || '-' ||
                     l_hierarchies(i).child_flex_value_high);
         debug(l_debug);
      END IF;

      IF (l_hierarchies(i).range_attribute = 'C') THEN
         compile_child(l_hierarchies(i).parent_flex_value,
                       l_hierarchies(i).child_flex_value_low,
                       l_hierarchies(i).child_flex_value_high);

       ELSIF (l_hierarchies(i).range_attribute = 'P') THEN
         add_to_parent_path(l_hierarchies(i).parent_flex_value);
         compile_parent(l_hierarchies(i).parent_flex_value,
                        l_hierarchies(i).child_flex_value_low,
                        l_hierarchies(i).child_flex_value_high,
                        l_debug);
         remove_from_parent_path();

       ELSE
         raise_exception_error(error_unknown_range_attribute,
                               'Unknown Range Attribute detected.',
                               'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                               'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                               'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                               'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
      END IF;
   END LOOP;

   --
   -- Commit the remaining rows.
   --
   IF (g_insert_count > 0) THEN
      COMMIT;
      g_insert_count := 0;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      --
      -- In case of error, delete the inserted rows (kind of rollback).
      --
      BEGIN
         DELETE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
           FROM fnd_flex_value_hierarchies
           WHERE flex_value_set_id = g_vset.flex_value_set_id;
         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      raise_others_error('compile_value_hierarchies');
END compile_value_hierarchies;

-- ======================================================================
-- PROCEDURE : compile_child_all
-- ======================================================================
-- Inserts the child range into the de-normalized hierarchy table.
--
PROCEDURE compile_child_all(p_root_parent_flex_value IN VARCHAR2,
                            p_range_attribute        IN VARCHAR2,
                            p_child_flex_value_low   IN VARCHAR2,
                            p_child_flex_value_high  IN VARCHAR2,
                            p_hierarchy_level        IN NUMBER)
  IS
BEGIN
   INSERT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
     INTO fnd_flex_value_hier_all
     (flex_value_set_id, parent_flex_value, range_attribute,
      child_flex_value_low, child_flex_value_high, hierarchy_level,
      last_update_date, last_updated_by,
      creation_date, created_by)
     VALUES
     (g_vset.flex_value_set_id*(-1), p_root_parent_flex_value, p_range_attribute,
      p_child_flex_value_low, p_child_flex_value_high, p_hierarchy_level,
      Sysdate, g_user_id,
      Sysdate, g_user_id);

   g_insert_count := g_insert_count + 1;
   IF (g_insert_count = g_commit_size) THEN
      COMMIT;
      g_insert_count := 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error('compile_child_all',
                         p_root_parent_flex_value,
                         p_range_attribute,
                         p_child_flex_value_low,
                         p_child_flex_value_high,
                         p_hierarchy_level);
END compile_child_all;


-- ======================================================================
-- PROCEDURE : compile_parent_all
-- ======================================================================
-- Recursively compiles the parent ranges.
--
PROCEDURE compile_parent_all(p_root_parent_flex_value IN VARCHAR2,
                             p_child_flex_value_low   IN VARCHAR2,
                             p_child_flex_value_high  IN VARCHAR2,
                             p_hierarchy_level        IN NUMBER)
  IS
     CURSOR norm_cur(p_child_flex_value_low  IN VARCHAR2,
                     p_child_flex_value_high IN VARCHAR2) IS
        SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
          parent_flex_value,
          child_flex_value_low,
          child_flex_value_high,
          range_attribute
          FROM fnd_flex_value_norm_hierarchy
          WHERE flex_value_set_id = g_vset.flex_value_set_id
          AND parent_flex_value >= p_child_flex_value_low
          AND parent_flex_value <= p_child_flex_value_high
          ORDER BY range_attribute, parent_flex_value,
          child_flex_value_low, child_flex_value_high;

     l_hierarchies     hierarchy_array;
     l_hierarchy_count BINARY_INTEGER;
BEGIN
   l_hierarchy_count := 0;
   FOR norm_rec IN norm_cur(p_child_flex_value_low,
                            p_child_flex_value_high) LOOP
      l_hierarchies(l_hierarchy_count).parent_flex_value     := norm_rec.parent_flex_value;
      l_hierarchies(l_hierarchy_count).child_flex_value_low  := norm_rec.child_flex_value_low;
      l_hierarchies(l_hierarchy_count).child_flex_value_high := norm_rec.child_flex_value_high;
      l_hierarchies(l_hierarchy_count).range_attribute       := norm_rec.range_attribute;
      l_hierarchy_count := l_hierarchy_count + 1;
   END LOOP;

   FOR i IN 0 .. l_hierarchy_count - 1 LOOP
      IF (l_hierarchies(i).range_attribute = 'C') THEN
         compile_child_all(p_root_parent_flex_value,
                           l_hierarchies(i).range_attribute,
                           l_hierarchies(i).child_flex_value_low,
                           l_hierarchies(i).child_flex_value_high,
                           p_hierarchy_level + 1);

       ELSIF (l_hierarchies(i).range_attribute = 'P') THEN
         compile_child_all(p_root_parent_flex_value,
                           l_hierarchies(i).range_attribute,
                           l_hierarchies(i).child_flex_value_low,
                           l_hierarchies(i).child_flex_value_high,
                           p_hierarchy_level + 1);

         --
         -- Cycle check
         --
         IF (exists_in_parent_path(l_hierarchies(i).parent_flex_value)) THEN
            raise_exception_error(error_cyclic_hierarchy,
                                  'Cyclic hierarchy detected.',
                                  'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                                  'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                                  'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                                  'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
         END IF;

         --
         -- Recursive call.
         --
         add_to_parent_path(l_hierarchies(i).parent_flex_value);
         compile_parent_all(p_root_parent_flex_value,
                            l_hierarchies(i).child_flex_value_low,
                            l_hierarchies(i).child_flex_value_high,
                            p_hierarchy_level + 1);
         remove_from_parent_path();

       ELSE
         raise_exception_error(error_unknown_range_attribute,
                               'Unknown Range Attribute detected.',
                               'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                               'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                               'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                               'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
      END IF;
  END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      raise_others_error('compile_parent_all',
                         p_root_parent_flex_value,
                         p_child_flex_value_low,
                         p_child_flex_value_high,
                         p_hierarchy_level);
END compile_parent_all;

-- ======================================================================
-- PROCEDURE : compile_value_hierarchies_all
-- ======================================================================
-- Compiles the flex value hierarchies in FND_FLEX_VALUE_HIER_ALL table.
--
PROCEDURE compile_value_hierarchies_all
  IS
     CURSOR main_norm_cur IS
        SELECT /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
          parent_flex_value,
          child_flex_value_low,
          child_flex_value_high,
          range_attribute
          FROM fnd_flex_value_norm_hierarchy
          WHERE flex_value_set_id = g_vset.flex_value_set_id
          ORDER BY range_attribute, parent_flex_value,
          child_flex_value_low, child_flex_value_high;

     l_hierarchies     hierarchy_array;
     l_hierarchy_count BINARY_INTEGER;
BEGIN
   g_insert_count := 0;


   IF (g_vset.security_enabled_flag = 'H') THEN
      l_hierarchy_count := 0;
      FOR main_norm_rec IN main_norm_cur LOOP
         l_hierarchies(l_hierarchy_count).parent_flex_value     := main_norm_rec.parent_flex_value;
         l_hierarchies(l_hierarchy_count).child_flex_value_low  := main_norm_rec.child_flex_value_low;
         l_hierarchies(l_hierarchy_count).child_flex_value_high := main_norm_rec.child_flex_value_high;
         l_hierarchies(l_hierarchy_count).range_attribute       := main_norm_rec.range_attribute;
         l_hierarchy_count := l_hierarchy_count + 1;
      END LOOP;

      --
      -- Initialize the cycle checking logic
      --
      init_parent_path();

      FOR i IN 0 .. l_hierarchy_count - 1 LOOP

         IF (l_hierarchies(i).range_attribute = 'C') THEN
            compile_child_all(l_hierarchies(i).parent_flex_value,
                              l_hierarchies(i).range_attribute,
                              l_hierarchies(i).child_flex_value_low,
                              l_hierarchies(i).child_flex_value_high,
                              1);
          ELSIF (l_hierarchies(i).range_attribute = 'P') THEN
            compile_child_all(l_hierarchies(i).parent_flex_value,
                              l_hierarchies(i).range_attribute,
                              l_hierarchies(i).child_flex_value_low,
                              l_hierarchies(i).child_flex_value_high,
                              1);

            add_to_parent_path(l_hierarchies(i).parent_flex_value);
            compile_parent_all(l_hierarchies(i).parent_flex_value,
                               l_hierarchies(i).child_flex_value_low,
                               l_hierarchies(i).child_flex_value_high,
                               1);
            remove_from_parent_path();

          ELSE
            raise_exception_error(error_unknown_range_attribute,
                                  'Unknown Range Attribute detected.',
                                  'Range Attribute  : ' || l_hierarchies(i).range_attribute,
                                  'Parent Flex Value: ' || l_hierarchies(i).parent_flex_value,
                                  'Low Child Value  : ' || l_hierarchies(i).child_flex_value_low,
                                  'High Child Value : ' || l_hierarchies(i).child_flex_value_high);
         END IF;
      END LOOP;
   END IF;

   --
   -- Commit the remaining rows.
   --
   IF (g_insert_count > 0) THEN
      COMMIT;
      g_insert_count := 0;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      --
      -- In case of error, delete the inserted rows (kind of rollback).
      --
      BEGIN
         DELETE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
           FROM fnd_flex_value_hier_all
           WHERE flex_value_set_id = g_vset.flex_value_set_id;
         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      raise_others_error('compile_value_hierarchies_all');
END compile_value_hierarchies_all;


PROCEDURE delete_value_hierarchies
   --
   -- Delete the old data.
   --
IS
   l_row_count NUMBER;
   BEGIN
    l_row_count := 1;
    WHILE (l_row_count > 0) LOOP
     DELETE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
        FROM fnd_flex_value_hierarchies
        WHERE flex_value_set_id = g_vset.flex_value_set_id and
        rownum < 1000;
        l_row_count := SQL%rowcount;
     COMMIT;
   END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         raise_exception_error(error_delete_hierarchies,
              'Unable to delete data in FND_FLEX_VALUE_HIERARCHIES table.');
END delete_value_hierarchies;

PROCEDURE delete_value_hierarchies_all
   --
   -- Delete the old data.
   --
IS
   l_row_count NUMBER;
   BEGIN
    l_row_count := 1;
    WHILE (l_row_count > 0) LOOP
     DELETE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
        FROM fnd_flex_value_hier_all
        WHERE flex_value_set_id = g_vset.flex_value_set_id and
        rownum < 1000;
        l_row_count := SQL%rowcount;
     COMMIT;
   END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         raise_exception_error(error_delete_hierarchies,
             'Unable to delete data in FND_FLEX_VALUE_HIER_ALL table.');
END delete_value_hierarchies_all;


PROCEDURE update_value_hierarchies
   --
   -- Update the newly compiled data with the vset id.
   --
IS
   l_row_count NUMBER;
   BEGIN
    l_row_count := 1;
    WHILE (l_row_count > 0) LOOP
     UPDATE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
        fnd_flex_value_hierarchies
        SET flex_value_set_id = g_vset.flex_value_set_id
        WHERE flex_value_set_id = g_vset.flex_value_set_id*(-1) and
        rownum < 1000;
        l_row_count := SQL%rowcount;
     COMMIT;
   END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         raise_exception_error(error_update_hierarchies,
              'Unable to update data in FND_FLEX_VALUE_HIERARCHIES table.');
END update_value_hierarchies;

PROCEDURE update_value_hierarchies_all
   --
   -- Update the newly compiled data with the vset id.
   --
IS
   l_row_count NUMBER;
   BEGIN
    l_row_count := 1;
    WHILE (l_row_count > 0) LOOP
     UPDATE /* $Header: AFFFCHYB.pls 120.2.12010000.7 2014/08/06 16:43:38 hgeorgi ship $ */
        fnd_flex_value_hier_all
        SET flex_value_set_id=g_vset.flex_value_set_id
        WHERE flex_value_set_id = g_vset.flex_value_set_id*(-1) and
        rownum < 1000;
        l_row_count := SQL%rowcount;
     COMMIT;
   END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         raise_exception_error(error_update_hierarchies,
              'Unable to update data in FND_FLEX_VALUE_HIERARCHIES table.');
END update_value_hierarchies_all;

PROCEDURE request_lock(p_lock_name           IN VARCHAR2,
                       x_lock_handle         OUT nocopy VARCHAR2)
  IS
     l_lock_name   VARCHAR2(128);
     l_lock_handle VARCHAR2(128);
BEGIN
   l_lock_name := 'FND.FLEX.VSET.HIERARCHY_COMPILER.' || p_lock_name;
   l_lock_handle := null;
   fnd_flex_server.request_lock(l_lock_name, l_lock_handle);
   x_lock_handle := l_lock_handle;
END request_lock;


PROCEDURE release_lock(p_lock_name           IN VARCHAR2,
                       p_lock_handle         IN VARCHAR2)
  IS
BEGIN
   IF (p_lock_handle IS NOT NULL) THEN
      fnd_flex_server.release_lock(p_lock_name, p_lock_handle);
   END IF;
END release_lock;


/********************************************************
It is possible to hdave duplicate records in
FND_FLEX_VALUE_HIERARCHIES table based on the
hier setup. These duplicates are not needed and
it only causes performance issues so we will delete
the duplicate records here.
********************************************************/
PROCEDURE delete_duplicate_records
IS
BEGIN
delete /* + rowid(a) use_nl(a) */
   from fnd_flex_value_hierarchies a
   where a.flex_value_set_id = g_vset.flex_value_set_id and
         rowid in
   (select /*+ unnest */ rowid
      from
         (select /*+ parallel(b) cardinality(b,10) */
            rowid, row_number() over (partition by
                flex_value_set_id, parent_flex_value,
                child_flex_value_low, child_flex_value_high
            order by 1
            ) dup
            from fnd_flex_value_hierarchies b
            where b.flex_value_set_id = g_vset.flex_value_set_id)
   where dup > 1);

END delete_duplicate_records;


PROCEDURE finish_hierarchy_processing
IS
     l_lock_name   VARCHAR2(128);
     l_lock_handle VARCHAR2(128);
  BEGIN

     /*
      This lock is to stop value validation (per valueset)
      while data is being processed. We do not want to
      allow values to be validated from a FF or
      anyother place until the values are processed.
     */
     l_lock_name := g_vset.flex_value_set_name;
     request_lock(l_lock_name, l_lock_handle);

     delete_value_hierarchies();
     update_value_hierarchies();
     delete_value_hierarchies_all();
     update_value_hierarchies_all();

     /*
     It is possible to hdave duplicate records in
     FND_FLEX_VALUE_HIERARCHIES table based on the
     hier setup. See bug 4694354. These duplicates
     are not needed and it only causes performance
     issues so we will delete the duplicate records here.
     */
     delete_duplicate_records();

     /*
      Release the lock once the process of normalizing
      the valuset data is complete.
     */
     release_lock(l_lock_name, l_lock_handle);

     COMMIT;

END finish_hierarchy_processing;

-- ======================================================================
-- PROCEDURE : compile_hierarchy
-- ======================================================================
-- Compiles the flex value hierarchy.
--
PROCEDURE compile_hierarchy(p_flex_value_set IN VARCHAR2,
                            p_debug_flag     IN VARCHAR2 DEFAULT 'N',
                            x_result         OUT nocopy VARCHAR2,
                            x_message        OUT nocopy VARCHAR2)
  IS
     l_message     VARCHAR2(32000) := NULL;
     l_bes_message VARCHAR2(32000) := NULL;
     l_lock_name   VARCHAR2(128);
     l_lock_handle VARCHAR2(128);
BEGIN
   --
   -- Set the debug flag
   --
   set_debug(p_debug_flag);

   --
   -- Set the global USER_ID variable.
   --
   BEGIN
      g_user_id := fnd_global.user_id;
   EXCEPTION
      WHEN OTHERS THEN
         g_user_id := -1;
   END;

   --
   -- Set the global g_vset variable.
   --
   get_vset(p_flex_value_set, g_vset);

   --
   -- Debug
   --
   IF (g_debug_on) THEN
      debug('Compiling Hierarchy for Value Set');
      debug('         Name : ' || g_vset.flex_value_set_name);
      debug('           Id : ' || g_vset.flex_value_set_id);
      debug('Security Flag : ' || g_vset.security_enabled_flag);
      debug(' ');
      debug('Flattened hierarchies : ');
      debug(Rpad('=', 80, '='));
   END IF;

   /*
      Request a lock at the beginning of this program so that no
      other instance of this program (updating the same valueset)
      can overwrite each other. Since the lock_name includes the
      valuset name, only other program instances updating the same
      valueset will be locked out. If another pogram instance is
      updating a different valueset, then there is no problem.
   */
   l_lock_name := 'FNDFFCHY.' || g_vset.flex_value_set_name;
   request_lock(l_lock_name, l_lock_handle);

   --
   -- Compile semi-denormalized hierarchies.
   --
   compile_value_hierarchies();

   --
   -- Compile fully denormalized hierarchies.
   --
   compile_value_hierarchies_all();

   /******************************************************************
    Bug 3947152 The code was deleting all the hierarchy rules and then
    reinserting them in a normalized state. Hierarchy value rules
    are checked by security. The problem is that when
    all the hier rules are deleted and before they are reinserted there
    is a time frame where there is a security breach. Values that
    should be secured, will not be sec in that time frame. We recoded
    the logic so that we first insert the hierachy rules with a
    vsetid*(-1). Once done with the insert we create a lock so
    that no one can access the data, and then we delete the rows
    with orig vsetid and then we update the vsetid*(-1) with the
    orig vsetid. After that is done, we release the lock. If another
    process wants to read the hier security data it cannot until the
    lock is released. At this time the only code that is reading the
    hier rules data is fnd_flex_server.check_value_security and
    this is called in FND_FLEX_SERVER1.check_security. In the function
    check_security() we check to see if a lock exists and if there is a
    lock we do not process until the lock is released meaning the data
    is now updated and correct.
   *******************************************************************/
   --
   -- Finish hierarchy processing.
   --
    finish_hierarchy_processing();

   --
   -- SUCCESS message.
   --
   BEGIN
      fnd_message.set_name('FND', 'FLEX-HIERARCHY COMP DONE');
      fnd_message.set_token('VSID', (To_char(g_vset.flex_value_set_id) ||
                                     '/''' ||
                                     g_vset.flex_value_set_name || ''''));
      l_message := fnd_message.get;
   EXCEPTION
      WHEN OTHERS THEN
         l_message := ('The value hierarchy associated with ' ||
                       'value set ' || g_vset.flex_value_set_id ||
                       '/''' || g_vset.flex_value_set_name ||
                       ''' has been compiled successfully.');
   END;

   -- Raise BES Event: oracle.apps.fnd.flex.vst.hierarchy.compiled

   DECLARE
      l_parameters wf_parameter_list_t := wf_parameter_list_t();
   BEGIN
      wf_event.addparametertolist(p_name          => 'FLEX_VALUE_SET_ID',
                                  p_value         => g_vset.flex_value_set_id,
                                  p_parameterlist => l_parameters);

      wf_event.addparametertolist(p_name          => 'FLEX_VALUE_SET_NAME',
                                  p_value         => g_vset.flex_value_set_name,
                                  p_parameterlist => l_parameters);

      wf_event.raise(p_event_name => 'oracle.apps.fnd.flex.vst.hierarchy.compiled',
                     p_event_key  => g_vset.flex_value_set_name,
                     p_event_data => NULL,
                     p_parameters => l_parameters,
                     p_send_date  => Sysdate);
   EXCEPTION
      WHEN OTHERS THEN
         l_bes_message := 'Workflow: Business Event System raised exception.' ||
           g_newline || dbms_utility.format_error_stack();
   END;

   /*
    Release the lock of this program instance.
   */
   release_lock(l_lock_name, l_lock_handle);

   IF (l_bes_message IS NULL) THEN
      --
      -- Return SUCCESS
      --
      x_result := 'SUCCESS';
    ELSE
      --
      -- Return WARNING
      --
      x_result := 'WARNING';
      l_message := l_message || g_newline || g_newline || l_bes_message;
   END IF;

   x_message := Substr(l_message, 1, g_message_size);

EXCEPTION
   WHEN OTHERS THEN
      BEGIN

         release_lock(l_lock_name, l_lock_handle);

         raise_others_error('compile_hierarchy',
                            p_flex_value_set,
                            p_debug_flag,
                            g_vset.flex_value_set_id,
                            g_vset.flex_value_set_name);
      EXCEPTION
         WHEN OTHERS THEN
            --
            -- Present the root cause of the problem
            --
            l_message := g_error_message || g_newline;

            --
            -- Add the error message stack
            --
            l_message := l_message || '----- Error Message Stack -----' || g_newline;
            l_message := l_message || dbms_utility.format_error_stack();

            --
            -- Return FAILURE
            --
            x_result := 'FAILURE';
            x_message := Substr(l_message, 1, g_message_size);

            RETURN;
      END;
END compile_hierarchy;



PROCEDURE compile_hierarchy_all(p_flex_value_set IN VARCHAR2,
                                p_debug_flag     IN VARCHAR2 DEFAULT 'N',
                                x_result         OUT nocopy VARCHAR2,
                                x_message        OUT nocopy VARCHAR2)

  IS
     ----------------------
     -- Local definitions -
     ----------------------
     l_value_set_id_sql    VARCHAR2(1000);
     l_flex_value_set_name VARCHAR2(60);
     l_value_set_id        NUMBER;
     l_result              VARCHAR2(10);
     l_message             VARCHAR2(2000);
     TYPE cursor_type IS   REF CURSOR;
     l_value_set_id_cur    cursor_type;


  BEGIN

   l_value_set_id_sql :=
   ('SELECT  /* Header: AFFFSV2B.pls 120.2.12000000.1 2007/01/18 13:18:43 appldev ship $ */ ' ||
    ' v.flex_value_set_id, v.flex_value_set_name ' ||
    ' FROM  fnd_flex_value_sets v ' ||
    ' WHERE EXISTS ' ||
         ' (SELECT null ' ||
            ' FROM fnd_flex_value_norm_hierarchy h ' ||
           ' WHERE h.flex_value_set_id = v.flex_value_set_id)');


   OPEN l_value_set_id_cur FOR l_value_set_id_sql;

   LOOP
     FETCH l_value_set_id_cur INTO l_value_set_id, l_flex_value_set_name;
     EXIT WHEN l_value_set_id_cur%NOTFOUND;
     compile_hierarchy(l_value_set_id, l_result, l_message);


     --
     -- Debug
     --
     IF (g_debug_on) THEN
        debug('Compiling Hierarchy for Value Set');
        debug('         Name : ' || l_flex_value_set_name);
        debug('           Id : ' || l_value_set_id);
        debug('Security Flag : ' || '');
        debug(' ');
        debug('Compile Value Set Hierarchy ALL : ');
        debug(Rpad('=', 80, '='));
     END IF;


     IF (l_result <> 'SUCCESS') THEN
         EXIT;
     END IF;

   END LOOP;


   IF (l_result = 'SUCCESS') THEN
      l_message := 'Flexfields Hierarchy Compiler completed successfully for all Value Sets';
   END IF;

   x_result := l_result;
   x_message := l_message;


   CLOSE l_value_set_id_cur;

END compile_hierarchy_all;


-- ======================================================================
PROCEDURE compile_hierarchy(p_flex_value_set IN VARCHAR2,
                            x_result         OUT nocopy VARCHAR2,
                            x_message        OUT nocopy VARCHAR2)
  IS
BEGIN
   compile_hierarchy(p_flex_value_set, 'N', x_result, x_message);
END compile_hierarchy;


BEGIN
   g_newline := fnd_global.newline();
END fnd_flex_hierarchy_compiler;

/
