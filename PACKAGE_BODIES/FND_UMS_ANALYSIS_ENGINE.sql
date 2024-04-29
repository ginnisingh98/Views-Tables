--------------------------------------------------------
--  DDL for Package Body FND_UMS_ANALYSIS_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_UMS_ANALYSIS_ENGINE" as
/* $Header: AFUMSAEB.pls 120.1 2005/07/02 04:20:36 appldev noship $ */

-- define the newline character

NEWLINE varchar2(3);

-- initial engine mode

MODE_NOT_CALLED                constant varchar2(30) := 'ENGINE_NOT_CALLED';

-- Global APPL_TOP Id. Should be replaced with AD_PATCH.GLOBAL_APPL_TOP_ID

GLOBAL_APPL_TOP_ID             constant number := -1;

-- bugfix release statuses:

RSTATUS_IN_PROGRESS            constant varchar2(30) := 'IN_PROGRESS';
RSTATUS_RELEASED               constant varchar2(30) := 'RELEASED';
RSTATUS_RELEASED_HIGH_PRIORITY constant varchar2(30) := 'RELEASED_HIGH_PRIORITY';
RSTATUS_SUPERSEDED             constant varchar2(30) := 'SUPERSEDED';
RSTATUS_OBSOLETED              constant varchar2(30) := 'OBSOLETED';

-- patch types:

-- US patch with UMS metadata

PATCH_TYPE_US_UMS              constant varchar2(30) := 'US_UMS';

-- US patch without UMS metadata

PATCH_TYPE_US_NON_UMS          constant varchar2(30) := 'US_NON_UMS';

-- NLS patch (no UMS metadata)
-- Implicitly prereqs the US patch of the same bug number.

PATCH_TYPE_NLS_PATCH           constant varchar2(30) := 'NLS_PATCH';

-- NLS bugfix (no UMS metadata)
-- NLS bugfix is a fix for translation bug. There is no US patch for
-- the same bug number. Language code is prefixed with 'NLS_'.

PATCH_TYPE_NLS_BUGFIX          constant varchar2(30) := 'NLS_BUGFIX';

-- replacement types:
-- see get_replacement_bugfix_guid() for more details.

REPLACEMENT_ORIGINAL           constant varchar2(30) := 'ORIGINAL_REPLACEMENT';
REPLACEMENT_FIRST_NON_OBSOLETE constant varchar2(30) := 'FIRST_NON_OBSOLETE_REPLACEMENT';
REPLACEMENT_LAST_NON_OBSOLETE  constant varchar2(30) := 'LAST_NON_OBSOLETE_REPLACEMENT';

-- bugfix application statuses:

-- bugfix has not been applied

APP_STATUS_NOT_APPLIED         constant varchar2(30) := 'NOT_APPLIED';

-- bugfix is implicitly applied; all its files and all its prereqs
-- (or their equivalent) are applied

APP_STATUS_IMPLICITLY_APPLIED  constant varchar2(30) := 'IMPLICITLY_APPLIED';

-- bugfix has been explicitly applied

APP_STATUS_EXPLICITLY_APPLIED  constant varchar2(30) := 'EXPLICITLY_APPLIED';

-- bugfix has been effectively applied

APP_STATUS_EFFECTIVELY_APPLIED constant varchar2(30) := 'EFFECTIVELY_APPLIED';

-- Equivalency Results for Post Processing Algorithm

EQUIVALENCY_TERMINATED         constant varchar2(30) := 'EQUIVALENCY_TERMINATED';
EQUIVALENCY_IN_PROGRESS        constant varchar2(30) := 'EQUIVALENCY_IN_PROGRESS';
EQUIVALENCY_COMPLETED_NONE     constant varchar2(30) := 'EQUIVALENCY_COMPLETED_NONE';
EQUIVALENCY_COMPLETED_REQUIRED constant varchar2(30) := 'EQUIVALENCY_COMPLETED_REQUIRED';
EQUIVALENCY_COMPLETED_MERGED   constant varchar2(30) := 'EQUIVALENCY_COMPLETED_MERGED';
EQUIVALENCY_COMPLETED_APPLIED  constant varchar2(30) := 'EQUIVALENCY_COMPLETED_APPLIED';

-- maximum number of calls to get_equivalency_result() function

MAX_GET_EQUIVALENCY_CALL_COUNT constant number := 5000;

-- Report symbols

SYMBOL_OBSOLETED               constant varchar2(10) := '*';
SYMBOL_MISSING                 constant varchar2(10) := '!';
SYMBOL_APPLIED                 constant varchar2(10) := '+';
SYMBOL_NO_INFORMATION          constant varchar2(10) := '?';
SYMBOL_NOT_APPLIED             constant varchar2(10) := '-';

-- raise_application_error codes

ERROR_AD_IS_PATCH_APPLIED      constant number := -20001;
ERROR_AD_IS_FILE_COPIED        constant number := -20002;
ERROR_AD_SET_PATCH_STATUS      constant number := -20003;

ERROR_UMS_OTHERS               constant number := -20100;
ERROR_UMS_REPLACEMENT_TYPE     constant number := -20101;
ERROR_UMS_PATCH_TYPE           constant number := -20104;
ERROR_UMS_ARRAY_NAME           constant number := -20105;
ERROR_UMS_ENGINE_NOT_CALLED    constant number := -20107;
ERROR_UMS_ILLEGAL_STATE        constant number := -20108;
ERROR_UMS_MISSING_DATA         constant number := -20111;
ERROR_UMS_INVALID_ENGINE_MODE  constant number := -20113;
ERROR_UMS_INVALID_BUG_LIST     constant number := -20114;
ERROR_UMS_INVALID_APPL_TOP_ID  constant number := -20115;

-- the maximum size of a piece of the report

MAX_REPORT_SIZE                constant number := 32000;

-- Generic use array types

type BINARY_INTEGER_ARRAY      is table of binary_integer index by binary_integer;
type VARCHAR2_ARRAY            is table of varchar2(32000) index by binary_integer;

-- Arrays for bulk fetching

type BUGFIX_GUID_ARRAY         is table of fnd_ums_bugfixes.bugfix_guid%TYPE index by binary_integer;
type RELATION_TYPE_ARRAY       is table of fnd_ums_bugfix_relationships.relation_type%TYPE index by binary_integer;

-- a bugfix in the dependency graph

type bugfix is record
    (-- primary key
     bugfix_index                   binary_integer,

     -- attributes from FND_UMS_BUGFIXES
     bugfix_guid                    fnd_ums_bugfixes.bugfix_guid%type,
     release_name                   fnd_ums_bugfixes.release_name%type,
     bug_number                     fnd_ums_bugfixes.bug_number%type,
     download_mode                  fnd_ums_bugfixes.download_mode%type,
     application_short_name         fnd_ums_bugfixes.application_short_name%type,
     release_status                 fnd_ums_bugfixes.release_status%type,
     type                           fnd_ums_bugfixes.type%type,
     abstract                       fnd_ums_bugfixes.abstract%type,

     -- attributes passed in
     language_code                  varchar2(30),

     -- derived attributes
     patch_type                     varchar2(30),
     ad_application_status          varchar2(30),
     bugfix_id                      varchar2(60),
     merged                         boolean,

     -- attributes used during prereq check
     replacement_chain_tag          number,
     application_status             varchar2(30),
     required                       boolean,

     -- post processing equivalency properties,
     equivalency_result             varchar2(30),
     equivalency_path               varchar2(32000),
     equivalent_bugfix_index        binary_integer);

type BUGFIX_ARRAY              is table of bugfix index by binary_integer;

-- Input passed to Analysis Engine.

type input_bug is record
    (bug_number                     number,
     language_code                  varchar2(30));

type INPUT_BUG_ARRAY           is table of input_bug index by binary_integer;

type replacement_chain is record
    (bugfix_count                   number,
     bugfix_indexes                 binary_integer_array);

type globals_record is record
    (-- the one-based array of report pieces
     report_count                   number,
     report                         VARCHAR2_ARRAY,

     -- the number of top-level bugfixes
     top_level_bugfix_count         number,
     top_level_bugfix_indexes       BINARY_INTEGER_ARRAY,

     -- obsolete top-level bugfix exists flag
     obs_top_level_bugfix_exists    boolean,

     -- the number of bugfixes
     bugfix_count                   number,

     -- the required bugfixes
     required_bugfix_count          number,
     required_bugfix_indexes        BINARY_INTEGER_ARRAY,

     -- the prereq list
     prereq_list                    varchar2(32000),

     -- the depth of the recursion used for indenting the debug output
     indent_level                   number,

     -- the mode
     engine_mode                    varchar2(30),

     -- the root cause error message
     root_cause_error_message       varchar2(32000),

     -- the unhandled exception depth
     exception_depth                number,

     -- the APPL_TOP id
     appl_top_id                    number,

     -- the debug flag
     debug_on                       boolean,

     -- replacement chain cycle detection counter
     replacement_chain_tag_counter  number,

     -- number of calls to get_equivalency_result() function
     get_equivalency_call_count     number,

     -- engine return status
     status                         varchar2(30));

-- Global Variables

g_globals           globals_record;

g_bugfixes          BUGFIX_ARRAY;

g_arcs_revision     varchar2(32000);

--------------------------------------------------------------------------------
-- Returns TRUE iff analyze_dependencies (engine) is called.
--
-- return: TRUE iff analyze_dependencies (engine) is called; FALSE otherwise.
--------------------------------------------------------------------------------
function is_engine_called
   return boolean
is
   l_return boolean;
begin
   if (g_globals.engine_mode = MODE_NOT_CALLED) then
      l_return := false;
   else
      l_return := true;
   end if;

   return l_return;
end is_engine_called;

--------------------------------------------------------------------------------
-- Gets the relation type as text.
--
-- p_relation_type - the relation type
--
-- return: the relation type as text
--------------------------------------------------------------------------------
function get_relation_type_as_text(p_relation_type in varchar2)
   return varchar2
is
   l_text varchar2(30);
begin
   if (p_relation_type = fnd_ums_loader.REL_TYPE_PREREQS) then
      l_text := 'Prereqs';
   elsif (p_relation_type = fnd_ums_loader.REL_TYPE_INDIRECTLY_PREREQS) then
      l_text := 'Indirectly Prereqs';
   elsif (p_relation_type = fnd_ums_loader.REL_TYPE_INCLUDES) then
      l_text := 'Includes';
   elsif (p_relation_type = fnd_ums_loader.REL_TYPE_INDIRECTLY_INCLUDES) then
      l_text := 'Indirectly Includes';
   elsif (p_relation_type = fnd_ums_loader.REL_TYPE_REPLACED_BY) then
      l_text := 'Replaced by';
   else
      l_text := p_relation_type;
   end if;

   return l_text;
end get_relation_type_as_text;

--------------------------------------------------------------------------------
-- Appends a line to the report.
--
-- p_text - the text to append to the report
--------------------------------------------------------------------------------
procedure append_to_report(p_text in varchar2)
is
begin
   if (lengthb(g_globals.report(g_globals.report_count)) +
       lengthb(p_text) + lengthb(NEWLINE) > MAX_REPORT_SIZE) then
      -- appending the text to the current piece of the report would exceed its
      -- maximum allowed size so initialize the next piece of the report

      g_globals.report_count := g_globals.report_count + 1;
      g_globals.report(g_globals.report_count) := '';
   end if;

   g_globals.report(g_globals.report_count) := g_globals.report(g_globals.report_count) ||
      rtrim(p_text, NEWLINE) || NEWLINE;
end append_to_report;

--------------------------------------------------------------------------------
-- Logs a message to the global report if in DEBUG mode.  Indents the line
-- according to the value of g_globals.indent_level.
--
-- p_text - the text to log
--------------------------------------------------------------------------------
procedure debug_to_report(p_text in varchar2)
is
   l_text varchar2(2000);
begin
   if (g_globals.debug_on) then
      -- indent the line according to indent_level

      l_text := lpad(p_text, length(p_text) + 3*g_globals.indent_level);

      append_to_report(l_text);
   end if;
exception
   when others then
      null;
end debug_to_report;

--------------------------------------------------------------------------------
-- Logs unhandled exception info to the report.
--
-- p_method - name of the method reporting exception
--------------------------------------------------------------------------------
procedure exception_to_report
is
begin
   append_to_report(' ');
   append_to_report(rpad('=', 80, '='));

   -- Root cause of the problem
   append_to_report(g_globals.root_cause_error_message);

   append_to_report(' ');
   append_to_report('----- Error Message Stack -----');
   append_to_report(dbms_utility.format_error_stack());

   if (g_globals.debug_on) then
      append_to_report(' ');
      append_to_report(dbms_utility.format_call_stack());
   end if;

   append_to_report(rpad('=', 80, '='));
exception
   when others then
      null;
end exception_to_report;

--------------------------------------------------------------------------------
-- Converts boolean to char.
--
-- p_boolean - boolean variable
--
-- return: Char representation of boolean variable.
--------------------------------------------------------------------------------
function boolean_to_char(p_boolean in boolean)
   return varchar2
is
   l_return varchar2(100);
begin
   if (p_boolean is null) then
      l_return := 'NULL';
   elsif (p_boolean) then
      l_return := 'TRUE';
   else
      l_return := 'FALSE';
   end if;

   return l_return;

end boolean_to_char;

--------------------------------------------------------------------------------
-- Returns formatted method call
--
-- p_method - name of the method
-- p_arg1..5 - method arguments
--
-- return: formatted method call
--------------------------------------------------------------------------------
function get_formatted_method_call(p_method in varchar2,
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

--------------------------------------------------------------------------------
-- Returns formatted error.
--
-- p_line0 - The first line that goes after ORA error number
-- p_line1..5 - optional lines to be indented
--
-- return: formatted error message
--------------------------------------------------------------------------------
function get_formatted_error(p_line0 in varchar2,
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
   --
   -- 12345678901
   -- ORA-xxxxx: <p_line0>
   --            <p_line1>
   --            <p_line2>
   --

   l_newline_indent := NEWLINE || rpad(' ', 11, ' ');

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

end get_formatted_error;

--------------------------------------------------------------------------------
-- Raises formatted application error.
--
-- p_error_code - error code
-- p_error_text - error text
--------------------------------------------------------------------------------
procedure raise_formatted_error(p_error_code in number,
                                p_error_text in varchar2)
is
   l_error_text varchar2(32000);
begin
   l_error_text := p_error_text || NEWLINE || dbms_utility.format_error_stack();

   raise_application_error(p_error_code, l_error_text);

exception
   when others then
      --
      -- Store the root cause of the problem. This will be presented to
      -- user as the main cause of the exception. Rest of the exception is
      -- basically the call stack trace.
      --
      if (g_globals.exception_depth = 0) then
         g_globals.root_cause_error_message := dbms_utility.format_error_stack();
      end if;

      g_globals.exception_depth := g_globals.exception_depth + 1;

      if (g_globals.debug_on) then
         exception_to_report();
      end if;

      raise;
end raise_formatted_error;

--------------------------------------------------------------------------------
-- Raises formatted error for 'when others then' block
--
-- p_method - name of the method
-- p_arg1..5 - method arguments
--------------------------------------------------------------------------------
procedure raise_others_error(p_method in varchar2,
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

   raise_formatted_error(ERROR_UMS_OTHERS, l_error_text);

   -- No exception handling here
end raise_others_error;

--------------------------------------------------------------------------------
-- Sorts required bugfixes
--------------------------------------------------------------------------------
procedure sort_required_bugfixes
is
   l_tmp_index      binary_integer;
   l_min_index      binary_integer;
   l_min_bug_number number;
begin
   -- use selection sort algorithm

   for i in 0 .. g_globals.required_bugfix_count - 1 loop
      l_min_index := i;
      l_min_bug_number := g_bugfixes(g_globals.required_bugfix_indexes(i)).bug_number;

      for j in i + 1 .. g_globals.required_bugfix_count - 1 loop

         if (g_bugfixes(g_globals.required_bugfix_indexes(j)).bug_number < l_min_bug_number) then
            l_min_index := j;
            l_min_bug_number := g_bugfixes(g_globals.required_bugfix_indexes(j)).bug_number;
         end if;

      end loop;

      if (l_min_index <> i) then
         l_tmp_index := g_globals.required_bugfix_indexes(i);
         g_globals.required_bugfix_indexes(i) := g_globals.required_bugfix_indexes(l_min_index);
         g_globals.required_bugfix_indexes(l_min_index) := l_tmp_index;
      end if;
   end loop;

exception
   when others then
      raise_others_error('sort_required_bugfixes');
end sort_required_bugfixes;

--------------------------------------------------------------------------------
-- Generates a comma seperated list of required bugfixes.
--------------------------------------------------------------------------------
function compute_prereq_list
   return varchar2
is
   l_prereq_list varchar2(32000);
begin
   l_prereq_list := '';

   -- sort required bugfixes

   sort_required_bugfixes();

   for i in 0 .. g_globals.required_bugfix_count - 1 loop

      if (i > 0) then
         l_prereq_list := l_prereq_list || ',';
      end if;

      l_prereq_list := l_prereq_list || g_bugfixes(g_globals.required_bugfix_indexes(i)).bug_number;
   end loop;

   return l_prereq_list;

exception
   when others then
      raise_others_error('compute_prereq_list');
end compute_prereq_list;

--------------------------------------------------------------------------------
-- Prints array details.
--
-- p_array_name - the array name 'Potenatial Prereqs', 'Required Bugfixes', etc.
-- p_arg1 - optional argument, used for title, prompt etc.
--------------------------------------------------------------------------------
procedure debug_array_to_report(p_array_name in varchar2,
                                p_arg1       in varchar2 default null)
is
   l_heading varchar2(2000);

   procedure debug_bugfix_to_report(p_bugfix_index             in binary_integer,
                                    p_debug_application_status in boolean,
                                    p_debug_top_level          in boolean)
   is
      l_bugfix bugfix;
      l_debug  varchar2(32000);
   begin
      l_bugfix := g_bugfixes(p_bugfix_index);

      l_debug := lpad(l_bugfix.bugfix_id, 13) ||
         ' ' || rpad(l_bugfix.release_status, 18);

      if (p_debug_application_status) then
         l_debug := l_debug || ' ' || rpad(l_bugfix.application_status, 18);
      end if;

      if (p_debug_top_level) then
         if (l_bugfix.merged) then
            l_debug := l_debug || ' MERGED';
         else
            l_debug := l_debug || ' NOT_MERGED';
         end if;
      end if;

      debug_to_report(l_debug);

   exception
      when others then
         raise_others_error('debug_bugfix_to_report',
            g_bugfixes(p_bugfix_index).bug_number,
            boolean_to_char(p_debug_application_status),
            boolean_to_char(p_debug_top_level));
   end debug_bugfix_to_report;

begin
   if (p_arg1 is null) then
      l_heading := p_array_name || ': ';
   else
      l_heading := p_array_name || ' (' || p_arg1 || '): ';
   end if;

   if (p_array_name = 'Top Level Bugfixes') then
      debug_to_report(' ');
      debug_to_report(l_heading || g_globals.top_level_bugfix_count);
      debug_to_report('--------------------------------------------------');

      for i in 0..g_globals.top_level_bugfix_count - 1 loop
         debug_bugfix_to_report(p_bugfix_index             => i,
                                p_debug_application_status => true,
                                p_debug_top_level          => false);

      end loop; -- top level bugfixes

   elsif (p_array_name = 'Required Bugfixes') then

      debug_to_report(' ');
      debug_to_report(l_heading || g_globals.required_bugfix_count);
      debug_to_report('--------------------------------------------------');

      for i in 0 .. g_globals.required_bugfix_count - 1 loop
         debug_bugfix_to_report(p_bugfix_index             => g_globals.required_bugfix_indexes(i),
                                p_debug_application_status => true,
                                p_debug_top_level          => true);
      end loop; -- required bugfixes

   else
      raise_formatted_error(ERROR_UMS_ARRAY_NAME,
         get_formatted_error('UMS Code Error in debug_array_to_report()',
            'Unexpected array name: ' || p_array_name));
   end if;

exception
   when others then
      raise_others_error('debug_array_to_report',
         p_array_name,
         p_arg1);
end debug_array_to_report;

--------------------------------------------------------------------------------
-- Creates the bugfix in cache.
--
-- p_release_name - the release name
-- p_bug_number - the bug number
-- p_language_code - the language code
--
-- return: the bugfix index
--------------------------------------------------------------------------------
function create_bugfix(p_release_name  in varchar2,
                       p_bug_number    in number,
                       p_language_code in varchar2)
   return binary_integer
is
   l_bugfix       bugfix;
   l_bugfix_index binary_integer;
begin
   if (p_language_code <> 'US') then

      -- NLS patch or NLS bugfix

      l_bugfix.bugfix_guid := null;
      l_bugfix.release_name := p_release_name;
      l_bugfix.bug_number := p_bug_number;
      l_bugfix.download_mode := fnd_ums_loader.DL_MODE_NONE;
      l_bugfix.application_short_name := null;
      l_bugfix.release_status := RSTATUS_RELEASED;
      l_bugfix.type := fnd_ums_loader.BUGFIX_TYPE_BUGFIX;
      l_bugfix.bugfix_id := p_bug_number || ':' || p_language_code;

      if (p_language_code like 'NLS_%') then
         l_bugfix.patch_type := PATCH_TYPE_NLS_BUGFIX;
         l_bugfix.abstract := '<NLS Bugfix for language: ' ||
            substr(p_language_code,5) || '>';
      else
         l_bugfix.patch_type := PATCH_TYPE_NLS_PATCH;
         l_bugfix.abstract := '<NLS Patch for language: ' ||
            p_language_code || '>';
      end if;

   else
      -- a 'US' bugfix
      l_bugfix.bugfix_id := p_bug_number;

      begin
         select 'AFUMSAEB.pls : $Revision: 120.1 $ : create_bugfix' arcs_revision,
                bugfix_guid,
                release_name,
                bug_number,
                download_mode,
                application_short_name,
                release_status,
                type,
                abstract
           into g_arcs_revision,
                l_bugfix.bugfix_guid,
                l_bugfix.release_name,
                l_bugfix.bug_number,
                l_bugfix.download_mode,
                l_bugfix.application_short_name,
                l_bugfix.release_status,
                l_bugfix.type,
                l_bugfix.abstract
           from fnd_ums_bugfixes
          where release_name = p_release_name
            and bug_number = p_bug_number
            and download_mode <> fnd_ums_loader.DL_MODE_NONE;

         l_bugfix.patch_type := PATCH_TYPE_US_UMS;
      exception
         when no_data_found then

            -- non-UMS US bugfix.

            l_bugfix.patch_type := PATCH_TYPE_US_NON_UMS;

            l_bugfix.bugfix_guid := null;
            l_bugfix.release_name := p_release_name;
            l_bugfix.bug_number := p_bug_number;
            l_bugfix.download_mode := fnd_ums_loader.DL_MODE_NONE;
            l_bugfix.application_short_name := null;
            l_bugfix.release_status := RSTATUS_RELEASED;
            l_bugfix.type := fnd_ums_loader.BUGFIX_TYPE_BUGFIX;
            l_bugfix.abstract := '<Patch for language: US>';
      end;
   end if;

   -- get ad_application_status
   begin
      if (l_bugfix.patch_type in (PATCH_TYPE_NLS_PATCH,
                                  PATCH_TYPE_NLS_BUGFIX)) then

         l_bugfix.ad_application_status := ad_patch.NOT_APPLIED;
      else
         -- a 'US' bugfix
         -- get bugfix application status from AD

         begin
            l_bugfix.ad_application_status := ad_patch.is_patch_applied(
               p_appl_top_id  => g_globals.appl_top_id,
               p_release_name => l_bugfix.release_name,
               p_bug_number   => l_bugfix.bug_number);
         exception
            when others then
               raise_formatted_error(ERROR_AD_IS_PATCH_APPLIED,
                  get_formatted_error('Error in AD_PATCH',
                     'ad_patch.is_patch_applied(p_appl_top_id  => ' ||
                        g_globals.appl_top_id || ',',
                     '                          p_release_name => ''' ||
                        l_bugfix.release_name || ''',',
                     '                          p_bug_number   => ' ||
                        l_bugfix.bug_number || ')'));
         end;
      end if;
   end;

   if (l_bugfix.ad_application_status = ad_patch.EXPLICITLY_APPLIED) then
      l_bugfix.application_status := APP_STATUS_EXPLICITLY_APPLIED;

   elsif (l_bugfix.ad_application_status = ad_patch.IMPLICITLY_APPLIED) then
      l_bugfix.application_status := APP_STATUS_IMPLICITLY_APPLIED;

   else
      l_bugfix.application_status := APP_STATUS_NOT_APPLIED;

   end if;

   -- Common initialization

   l_bugfix.language_code := p_language_code;
   l_bugfix.required := false;
   l_bugfix.merged := false;
   l_bugfix.replacement_chain_tag := null;
   l_bugfix.equivalency_result := null;
   l_bugfix.equivalency_path := null;
   l_bugfix.equivalent_bugfix_index := null;

   -- Bugfix record is ready, assign the primary key.

   l_bugfix_index := g_globals.bugfix_count;

   g_globals.bugfix_count := g_globals.bugfix_count + 1;

   l_bugfix.bugfix_index := l_bugfix_index;

   g_bugfixes(l_bugfix_index) := l_bugfix;

   return l_bugfix.bugfix_index;

exception
   when others then
      raise_others_error('create_bugfix',
         p_release_name,
         p_bug_number,
         p_language_code);
end create_bugfix;

--------------------------------------------------------------------------------
-- Gets the bugfix.  If the bugfix does not exist, a new one is created.  This
-- function is useful if you only need a handle to the bugfix for read access.
-- Since the returned bugfix is a copy of the one in the global array, it is
-- not useful for write access.
--
-- p_release_name - the release name
-- p_bug_number - the bug number
-- p_language_code - the language code
--
-- return: the bugfix
--------------------------------------------------------------------------------
function get_bugfix(p_release_name  in varchar2,
                    p_bug_number    in number,
                    p_language_code in varchar2)
   return bugfix
is
   l_bugfix       bugfix;
   l_bugfix_index binary_integer;
   l_found        boolean;
begin
   l_found := false;

   for i in reverse 0 .. g_globals.bugfix_count - 1 loop
      if (g_bugfixes(i).release_name = p_release_name and
          g_bugfixes(i).bug_number = p_bug_number and
          g_bugfixes(i).language_code = p_language_code) then
         l_bugfix := g_bugfixes(i);
         l_found := true;

         exit;
      end if;
   end loop;

   if (not l_found) then
      l_bugfix_index := create_bugfix(p_release_name,
                                      p_bug_number,
                                      p_language_code);
      l_bugfix := g_bugfixes(l_bugfix_index);
   end if;

   return l_bugfix;

exception
   when others then
      raise_others_error('get_bugfix',
         p_release_name,
         p_bug_number,
         p_language_code);
end get_bugfix;

--------------------------------------------------------------------------------
-- Gets the bugfix for UMS bugfixes.
--
-- p_bugfix_guid - the bugfix guid
--
-- return: the bugfix
--------------------------------------------------------------------------------
function get_bugfix(p_bugfix_guid in fnd_ums_bugfixes.bugfix_guid%type)
   return bugfix
is
   l_release_name fnd_ums_bugfixes.release_name%type;
   l_bug_number   fnd_ums_bugfixes.bug_number%type;
   l_bugfix_index binary_integer;
   l_bugfix       bugfix;
   l_found        boolean;
begin
   l_found := false;

   for i in reverse 0 .. g_globals.bugfix_count - 1 loop
      if (g_bugfixes(i).bugfix_guid = p_bugfix_guid) then
         l_bugfix := g_bugfixes(i);
         l_found := true;

         exit;
      end if;
   end loop;

   if (not l_found) then
      -- Check UMS table
      begin
         select 'AFUMSAEB.pls : $Revision: 120.1 $ : get_bugfix' arcs_revision,
                release_name,
                bug_number
           into g_arcs_revision,
                l_release_name,
                l_bug_number
           from fnd_ums_bugfixes
          where bugfix_guid = p_bugfix_guid;
      exception
         when no_data_found then
            raise_formatted_error(ERROR_UMS_MISSING_DATA,
               get_formatted_error('No data found in FND_UMS_BUGFIXES',
                  'for bugfix guid ' || p_bugfix_guid));
      end;

      l_bugfix_index := create_bugfix(l_release_name,
                                      l_bug_number,
                                      'US');
      l_bugfix := g_bugfixes(l_bugfix_index);

   end if;

   return l_bugfix;

exception
   when others then
      raise_others_error('get_bugfix',
         p_bugfix_guid);
end get_bugfix;

--------------------------------------------------------------------------------
-- Sets/unsets required state of a bugfix
--
-- p_bugfix_index - bugfix index
-- p_required - required state of a bugfix
--------------------------------------------------------------------------------
procedure set_bugfix_required(p_bugfix_index in binary_integer,
                              p_required     in boolean)
is
   l_required boolean;
begin
   l_required := g_bugfixes(p_bugfix_index).required;

   if (l_required) then
      if (not p_required) then
         --
         -- REQUIRED --> NOT REQUIRED
         --
         -- remove it from required bugfixes
         for i in 0 .. g_globals.required_bugfix_count - 1 loop
            if (g_globals.required_bugfix_indexes(i) = p_bugfix_index) then

               g_globals.required_bugfix_indexes(i) :=
                  g_globals.required_bugfix_indexes(g_globals.required_bugfix_count - 1);
               g_globals.required_bugfix_count := g_globals.required_bugfix_count - 1;

               exit; -- from the loop
            end if;
         end loop;
      end if;
   else
      if (p_required) then
         --
         -- NOT REQUIRED --> REQUIRED
         --
         -- add it to required bugfixes
         g_globals.required_bugfix_indexes(g_globals.required_bugfix_count) := p_bugfix_index;
         g_globals.required_bugfix_count := g_globals.required_bugfix_count + 1;
      end if;
   end if;

   g_bugfixes(p_bugfix_index).required := p_required;

exception
   when others then
      raise_others_error('set_bugfix_required',
         g_bugfixes(p_bugfix_index).bug_number,
         boolean_to_char(p_required));
end set_bugfix_required;

--------------------------------------------------------------------------------
-- Gets the replacement bugfix guid.
--
-- p_bugfix_guid - the bugfix guid
--
-- return: the replacement bugfix guid or null if there is no replacement
--------------------------------------------------------------------------------
function get_replacement_bugfix_guid(p_bugfix_guid in fnd_ums_bugfixes.bugfix_guid%type)
   return fnd_ums_bugfixes.bugfix_guid%type
is
   l_replacement_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
begin
   begin
      select 'AFUMSAEB.pls : $Revision: 120.1 $ : get_replacement_bugfix_guid' arcs_revision,
             related_bugfix_guid
        into g_arcs_revision,
             l_replacement_bugfix_guid
        from fnd_ums_bugfix_relationships
       where bugfix_guid = p_bugfix_guid
         and relation_type = fnd_ums_loader.REL_TYPE_REPLACED_BY;
   exception
      when no_data_found then
         -- there is no replacement

         l_replacement_bugfix_guid := null;
   end;

   return l_replacement_bugfix_guid;

exception
   when others then
      raise_others_error('get_replacement_bugfix_guid',
         get_bugfix(p_bugfix_guid).bug_number);
end get_replacement_bugfix_guid;

--------------------------------------------------------------------------------
-- Returns the replacement chain of a bugfix up to
--    the end of the chain
--
-- p_bugfix_index - the bugfix index
-- px_replacement_chain - the replacement chain
--------------------------------------------------------------------------------
procedure get_full_replacement_chain(p_bugfix_index       in binary_integer,
                                     px_replacement_chain in out nocopy replacement_chain)
is
   l_bugfix      bugfix;
   l_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
begin
   px_replacement_chain.bugfix_count := 0;

   g_globals.replacement_chain_tag_counter := g_globals.replacement_chain_tag_counter + 1;

   l_bugfix := g_bugfixes(p_bugfix_index);
   l_bugfix_guid := l_bugfix.bugfix_guid;

   loop
      px_replacement_chain.bugfix_indexes(px_replacement_chain.bugfix_count) := l_bugfix.bugfix_index;
      px_replacement_chain.bugfix_count := px_replacement_chain.bugfix_count + 1;

      -- check for cyclic replacement chain

      if (l_bugfix.replacement_chain_tag = g_globals.replacement_chain_tag_counter) then
         px_replacement_chain.bugfix_count := px_replacement_chain.bugfix_count - 1;
         exit;  -- from chain loop
      else
         -- tag it
         g_bugfixes(l_bugfix.bugfix_index).replacement_chain_tag := g_globals.replacement_chain_tag_counter;
      end if;

      l_bugfix_guid := get_replacement_bugfix_guid(l_bugfix_guid);

      if (l_bugfix_guid is null) then
         -- the end of the replacement chain has been reached

         exit;  -- from chain loop
      end if;

      -- next bugfix in the chain

      l_bugfix := get_bugfix(l_bugfix_guid);
   end loop;

exception
   when others then
      raise_others_error('get_full_replacement_chain',
         g_bugfixes(p_bugfix_index).bug_number);
end get_full_replacement_chain;

--------------------------------------------------------------------------------
-- Gets the replacement bugfix guid.
--
-- p_bugfix_guid - the bugfix guid
-- p_replacement_type - type of the replacement.
--
-- return: the replacement bugfix guid or null if there is no replacement
--
--          OR         OR            OR         OR
--   Aobs ------> A1 ------> A2obs ------> A3 ------> A4obs
--
--  p_bugfix_guid p_replacement_type              return
--  ------------- ------------------------------- --------
--  Aobs          REPLACEMENT_ORIGINAL            A1
--  Aobs          REPLACEMENT_FIRST_NON_OBSOLETE  A1
--  Aobs          REPLACEMENT_LAST_NON_OBSOLETE   A3
--
--  A1            REPLACEMENT_ORIGINAL            A2obs
--  A1            REPLACEMENT_FIRST_NON_OBSOLETE  A3
--  A1            REPLACEMENT_LAST_NON_OBSOLETE   A3
--
--  A2obs         REPLACEMENT_ORIGINAL            A3
--  A2obs         REPLACEMENT_FIRST_NON_OBSOLETE  A3
--  A2obs         REPLACEMENT_LAST_NON_OBSOLETE   A3
--
--  A3            REPLACEMENT_ORIGINAL            A4obs
--  A3            REPLACEMENT_FIRST_NON_OBSOLETE  null
--  A3            REPLACEMENT_LAST_NON_OBSOLETE   null
--
--  A4obs         REPLACEMENT_ORIGINAL            null
--  A4obs         REPLACEMENT_FIRST_NON_OBSOLETE  null
--  A4obs         REPLACEMENT_LAST_NON_OBSOLETE   null
--
--------------------------------------------------------------------------------
function get_replacement_bugfix_guid(p_bugfix_guid      in fnd_ums_bugfixes.bugfix_guid%type,
                                     p_replacement_type in varchar2)
   return fnd_ums_bugfixes.bugfix_guid%type
is
   l_replacement_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
   l_bugfix                  bugfix;
   l_replacement_chain       replacement_chain;
begin
   l_replacement_bugfix_guid := null;

   l_bugfix := get_bugfix(p_bugfix_guid);

   get_full_replacement_chain(l_bugfix.bugfix_index, l_replacement_chain);

   if (p_replacement_type = REPLACEMENT_ORIGINAL) then

      for i in 1 .. l_replacement_chain.bugfix_count - 1 loop
         if (i = 1) then
            l_replacement_bugfix_guid := g_bugfixes(l_replacement_chain.bugfix_indexes(i)).bugfix_guid;
            exit;
         end if;
      end loop;

   elsif (p_replacement_type = REPLACEMENT_FIRST_NON_OBSOLETE) then

      for i in 1 .. l_replacement_chain.bugfix_count - 1 loop
         if (g_bugfixes(l_replacement_chain.bugfix_indexes(i)).release_status <> RSTATUS_OBSOLETED) then
            l_replacement_bugfix_guid := g_bugfixes(l_replacement_chain.bugfix_indexes(i)).bugfix_guid;
            exit;
         end if;
      end loop;

   elsif (p_replacement_type = REPLACEMENT_LAST_NON_OBSOLETE) then

      for i in reverse 1 .. l_replacement_chain.bugfix_count - 1 loop
         if (g_bugfixes(l_replacement_chain.bugfix_indexes(i)).release_status <> RSTATUS_OBSOLETED) then
            l_replacement_bugfix_guid := g_bugfixes(l_replacement_chain.bugfix_indexes(i)).bugfix_guid;
            exit;
         end if;
      end loop;

   else
      raise_formatted_error(ERROR_UMS_REPLACEMENT_TYPE,
         get_formatted_error('UMS Code Error in get_replacement_bugfix_guid()',
            'Unexpected replacement type: ' || p_replacement_type));
   end if;

   return l_replacement_bugfix_guid;

exception
   when others then
      raise_others_error('get_replacement_bugfix_guid',
         get_bugfix(p_bugfix_guid).bug_number,
         p_replacement_type);
end get_replacement_bugfix_guid;

--------------------------------------------------------------------------------
procedure check_bugfix_required(p_bugfix_index         in binary_integer,
                                p_relation_type        in varchar2,
                                p_related_bugfix_index in binary_integer)
is
   l_debug_bugfix   bugfix;
   l_related_bugfix bugfix;
begin
   l_related_bugfix := g_bugfixes(p_related_bugfix_index);

   if (g_globals.debug_on) then
      l_debug_bugfix := g_bugfixes(p_bugfix_index);

      debug_to_report('Checking (' || l_debug_bugfix.bugfix_id || ' ' ||
         p_relation_type || ' ' ||
         l_related_bugfix.bugfix_id || ')');
      g_globals.indent_level := g_globals.indent_level + 1;
   end if;

   if (l_related_bugfix.application_status in (APP_STATUS_EXPLICITLY_APPLIED,
                                               APP_STATUS_IMPLICITLY_APPLIED)) then
      if (g_globals.debug_on) then
         debug_to_report('Bugfix ' ||
            l_related_bugfix.bug_number ||
            ' is ' || l_related_bugfix.application_status || ', so it is not required.');
      end if;
   else
      if (g_globals.debug_on) then
         debug_to_report('Bugfix ' ||
            l_related_bugfix.bug_number ||
            ' is not applied, so it is required.');
      end if;

      --
      -- This bugfix is required.
      --
      set_bugfix_required(p_related_bugfix_index, true);
   end if;

   if (g_globals.debug_on) then
      g_globals.indent_level := g_globals.indent_level - 1;
   end if;

exception
   when others then
      raise_others_error('check_bugfix_required',
         g_bugfixes(p_bugfix_index).bug_number,
         p_relation_type,
         g_bugfixes(p_related_bugfix_index).bug_number);
end check_bugfix_required;

--------------------------------------------------------------------------------
procedure check_bugfix_prereqs(p_bugfix_index in binary_integer)
is
   --
   -- order by is added to get reproducible results in RT.
   --
   cursor l_prereqs(p_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type) is
      select 'AFUMSAEB.pls : $Revision: 120.1 $ : check_bugfix_prereqs' arcs_revision,
             fubr.related_bugfix_guid,
             fubr.relation_type
        from fnd_ums_bugfix_relationships fubr,
             fnd_ums_bugfixes fub
       where fubr.bugfix_guid = p_bugfix_guid
        --
        -- - Direct/Indirect Prereq links are followed
        --
        --   fubr.related_bugfix
        --    /|\
        --     |
        --     |P/P'
        --     |
        --     |
        --   fubr.bugfix
        --
         and fubr.relation_type in (fnd_ums_loader.REL_TYPE_PREREQS,
                                    fnd_ums_loader.REL_TYPE_INDIRECTLY_PREREQS)
         and fub.bugfix_guid = fubr.related_bugfix_guid
       order by decode(fubr.relation_type,
                       fnd_ums_loader.REL_TYPE_INDIRECTLY_PREREQS,  1,
                       fnd_ums_loader.REL_TYPE_PREREQS,             2,
                       99),
                fub.bug_number;

   l_bugfix         bugfix;
   l_related_bugfix bugfix;
begin
   l_bugfix := g_bugfixes(p_bugfix_index);

   if (g_globals.debug_on) then
      debug_to_report('BEGIN bugfix ' || l_bugfix.bugfix_id);

      g_globals.indent_level := g_globals.indent_level + 1;

      debug_to_report('release status = ' || l_bugfix.release_status);
      debug_to_report('AD application status = ' || l_bugfix.ad_application_status);
   end if;

   if (l_bugfix.patch_type = PATCH_TYPE_NLS_PATCH) then
      -- NLS Patch. Create a Prereq link on the fly to the 'US' version of
      -- the same bugfix.

      l_related_bugfix := get_bugfix(p_release_name  => l_bugfix.release_name,
                                     p_bug_number    => l_bugfix.bug_number,
                                     p_language_code => 'US');

      if (g_globals.debug_on) then
         debug_to_report('NLS Patch: need to check US patch and its prereqs.');
      end if;

      check_bugfix_required(l_bugfix.bugfix_index,
                            fnd_ums_loader.REL_TYPE_PREREQS,
                            l_related_bugfix.bugfix_index);

      if (g_bugfixes(l_related_bugfix.bugfix_index).required) then
         check_bugfix_prereqs(l_related_bugfix.bugfix_index);
      end if;

   elsif (l_bugfix.patch_type = PATCH_TYPE_NLS_BUGFIX) then
      -- NLS bugfix

      if (g_globals.debug_on) then
         debug_to_report('NLS Bugfix: there is nothing to do.');
      end if;

   elsif (l_bugfix.patch_type = PATCH_TYPE_US_NON_UMS) then
      -- US patch without metadata

      if (g_globals.debug_on) then
         debug_to_report('US, Non-UMS Patch: there is nothing to do.');
      end if;

   elsif (l_bugfix.patch_type = PATCH_TYPE_US_UMS) then
      -- US patch with metadata

      if (g_globals.debug_on) then
         debug_to_report('US Patch: need to check prereqs.');
      end if;

      for l_prereq in l_prereqs(l_bugfix.bugfix_guid) loop
         l_related_bugfix := get_bugfix(l_prereq.related_bugfix_guid);

         check_bugfix_required(l_bugfix.bugfix_index,
                               l_prereq.relation_type,
                               l_related_bugfix.bugfix_index);
      end loop;
   else
      raise_formatted_error(ERROR_UMS_PATCH_TYPE,
         get_formatted_error('UMS Code Error: ',
            'Unexpected patch type: ' || l_bugfix.patch_type));
   end if;

   if (g_globals.debug_on) then
      g_globals.indent_level := g_globals.indent_level - 1;
      debug_to_report('END bugfix ' || l_bugfix.bugfix_id);
   end if;

exception
   when others then
      raise_others_error('check_bugfix_prereqs',
         g_bugfixes(p_bugfix_index).bug_number);
end check_bugfix_prereqs;

--------------------------------------------------------------------------------
function get_equivalency_result(p_bugfix_index  in binary_integer,
                                p_incoming_path in varchar2)
   return varchar2
is
   cursor l_equivalents(p_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type) is
      select alias_bugfix_guid,
             alias_relation_type
        from (select fubr.related_bugfix_guid alias_bugfix_guid,
                     fubr.relation_type alias_relation_type
                from fnd_ums_bugfix_relationships fubr
               where fubr.bugfix_guid = p_bugfix_guid
                 and fubr.relation_type = fnd_ums_loader.REL_TYPE_REPLACED_BY
              union
              select fubr.bugfix_guid alias_bugfix_guid,
                     fubr.relation_type alias_relation_type
                from fnd_ums_bugfix_relationships fubr
               where fubr.related_bugfix_guid = p_bugfix_guid
                 and fubr.relation_type in (fnd_ums_loader.REL_TYPE_INCLUDES,
                                            fnd_ums_loader.REL_TYPE_INDIRECTLY_INCLUDES)) rels,
             fnd_ums_bugfixes fub
       where 'AFUMSAEB.pls : $Revision: 120.1 $ : get_equivalency_result' is not null
         and rels.alias_bugfix_guid = fub.bugfix_guid
       order by decode(alias_relation_type,
                       fnd_ums_loader.REL_TYPE_REPLACED_BY, 1,
                       fnd_ums_loader.REL_TYPE_INDIRECTLY_INCLUDES, 2,
                       fnd_ums_loader.REL_TYPE_INCLUDES, 3,
                       99),
                fub.bug_number;

   l_bugfix_guids       BUGFIX_GUID_ARRAY;
   l_relation_types     RELATION_TYPE_ARRAY;

   l_bugfix             bugfix;
   l_equivalent_bugfix  bugfix;
   l_vc2                varchar2(32000);
   l_equivalency_result varchar2(30);
begin
   -- Since this function is called, increment the call count

   g_globals.get_equivalency_call_count := g_globals.get_equivalency_call_count + 1;

   if (g_globals.get_equivalency_call_count > MAX_GET_EQUIVALENCY_CALL_COUNT) then
      g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_TERMINATED;
      g_bugfixes(p_bugfix_index).equivalency_path := null;
      g_bugfixes(p_bugfix_index).equivalent_bugfix_index := null;

      goto done;
   end if;

   l_bugfix := g_bugfixes(p_bugfix_index);

   if (l_bugfix.equivalency_result is null) then
      -- This is the first time this bugfix is visited.

      null;
   elsif (l_bugfix.equivalency_result = EQUIVALENCY_TERMINATED) then
      -- This bugfix was terminated, it needs to be re-visited.

      null;
   elsif (l_bugfix.equivalency_result = EQUIVALENCY_IN_PROGRESS) then
      -- An equivalency cycle exists.

      goto done;
   elsif (l_bugfix.equivalency_result in (EQUIVALENCY_COMPLETED_NONE,
                                          EQUIVALENCY_COMPLETED_REQUIRED,
                                          EQUIVALENCY_COMPLETED_MERGED,
                                          EQUIVALENCY_COMPLETED_APPLIED)) then
      -- Equivalency visitation was complete for this bugfix.

      goto done;
   end if;

   if (g_globals.debug_on) then
      debug_to_report(p_incoming_path ||
         ', ' || g_bugfixes(p_bugfix_index).equivalency_result);
   end if;

   -- This bugfix needs to be processed for equivalency check

   if (l_bugfix.application_status in (APP_STATUS_EXPLICITLY_APPLIED,
                                       APP_STATUS_IMPLICITLY_APPLIED)) then
      g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_COMPLETED_APPLIED;
      g_bugfixes(p_bugfix_index).equivalency_path := null;
      g_bugfixes(p_bugfix_index).equivalent_bugfix_index := p_bugfix_index;

      goto done;
   end if;

   if (l_bugfix.merged) then
      g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_COMPLETED_MERGED;
      g_bugfixes(p_bugfix_index).equivalency_path := null;
      g_bugfixes(p_bugfix_index).equivalent_bugfix_index := p_bugfix_index;

      goto done;
   end if;

   g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_IN_PROGRESS;

   open l_equivalents(l_bugfix.bugfix_guid);

   fetch l_equivalents bulk collect into l_bugfix_guids, l_relation_types
      limit MAX_GET_EQUIVALENCY_CALL_COUNT + 1 - g_globals.get_equivalency_call_count;

   close l_equivalents;

   for i in 1 .. l_bugfix_guids.count loop
      l_equivalent_bugfix := get_bugfix(l_bugfix_guids(i));

      if (l_relation_types(i) = fnd_ums_loader.REL_TYPE_REPLACED_BY) then
         l_vc2 := ' -OR-> ';
      elsif (l_relation_types(i) = fnd_ums_loader.REL_TYPE_INCLUDES) then
         l_vc2 := ' <-I- ';
      elsif (l_relation_types(i) = fnd_ums_loader.REL_TYPE_INDIRECTLY_INCLUDES) then
         l_vc2 := ' <-I''- ';
      end if;
      l_vc2 := l_vc2 || l_equivalent_bugfix.bug_number;

      l_equivalency_result := get_equivalency_result(l_equivalent_bugfix.bugfix_index,
                                                     p_incoming_path || l_vc2);

      if (l_equivalency_result = EQUIVALENCY_TERMINATED) then
         g_bugfixes(p_bugfix_index).equivalency_result := l_equivalency_result;
         g_bugfixes(p_bugfix_index).equivalency_path := null;
         g_bugfixes(p_bugfix_index).equivalent_bugfix_index := null;

         goto done;
      elsif (l_equivalency_result in (EQUIVALENCY_COMPLETED_REQUIRED,
                                      EQUIVALENCY_COMPLETED_MERGED,
                                      EQUIVALENCY_COMPLETED_APPLIED)) then

         g_bugfixes(p_bugfix_index).equivalency_result := l_equivalency_result;
         g_bugfixes(p_bugfix_index).equivalency_path :=
            l_vc2 || g_bugfixes(l_equivalent_bugfix.bugfix_index).equivalency_path;
         g_bugfixes(p_bugfix_index).equivalent_bugfix_index :=
            g_bugfixes(l_equivalent_bugfix.bugfix_index).equivalent_bugfix_index;

         goto done;
      end if;
   end loop;

   if (l_bugfix.required) then
      g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_COMPLETED_REQUIRED;
      g_bugfixes(p_bugfix_index).equivalency_path := null;
      g_bugfixes(p_bugfix_index).equivalent_bugfix_index := p_bugfix_index;

      goto done;
   end if;

   g_bugfixes(p_bugfix_index).equivalency_result := EQUIVALENCY_COMPLETED_NONE;
   g_bugfixes(p_bugfix_index).equivalency_path := null;
   g_bugfixes(p_bugfix_index).equivalent_bugfix_index := null;

   goto done;

   <<done>>
   if (g_globals.debug_on) then
      debug_to_report(p_incoming_path ||
         ', ' || g_bugfixes(p_bugfix_index).equivalency_result);
   end if;

   return g_bugfixes(p_bugfix_index).equivalency_result;
exception
   when others then
      raise_others_error('get_equivalency_result',
         g_bugfixes(p_bugfix_index).bug_number,
         p_incoming_path);
end get_equivalency_result;

--------------------------------------------------------------------------------
-- Equivalency Removal
--    A required bugfix can be removed if
--    -- it or one of its equivalents is applied, or
--    -- it or one of its equivalents is merged, or
--    --       one of its equivalents is also a required bugfix.
--
-- Equivalency: Bugfix 2 is equivalent to Bugfix 1 if
--    -- Bugfix 2 replaces Bugfix 1 or one of its equivalents, or
--    -- Bugfix 2 includes Bugfix 1 or one of its equivalents
--
--
-- In following pictures Bugfix 2 is equivalent to Bugfix 1.
--
--    -- Bugfix 2 replaces Bugfix 1
--
--               1 -----> 2
--
--    -- Bugfix 2 includes Bugfix 1
--
--               1
--              /|\
--               |
--             I |
--               |
--               2
--
--    -- Bugfix 2 replaces one of Bugfix 1's equivalents
--
--               1 -----> 3 -----> 2
--
--
--               1
--              /|\
--               |
--             I |
--               |
--               3 -----> 2
--
--
--               1
--                \_
--                  \_
--                    \_
--                      \
--                       3 -----> 2
--
--    -- Bugfix 2 includes one of Bugfix 1's equivalents
--
--               1 -----> 3
--                       /|\
--                        |
--                        | I
--                        |
--                        2
--
--
--               1
--              /|\
--               |
--             I |
--               |
--               3
--              /|\
--               |
--             I |
--               |
--               2
--
--
--               1
--                \_
--                  \_
--                    \_
--                      \
--                       3
--                      /|\
--                       |
--                     I |
--                       |
--                       2
--
--------------------------------------------------------------------------------
procedure do_equivalency_removal
is
   l_required_bugfix_count   binary_integer;
   l_required_bugfix_indexes BINARY_INTEGER_ARRAY;

   l_bugfix_index       binary_integer;
   l_equivalency_result varchar2(30);
begin
   -- Copy current required bugfix indexes to a local array

   l_required_bugfix_count := g_globals.required_bugfix_count;
   for i in 0 .. g_globals.required_bugfix_count - 1 loop
      l_required_bugfix_indexes(i) := g_globals.required_bugfix_indexes(i);
   end loop;

   for i in 0 .. l_required_bugfix_count - 1 loop

      l_bugfix_index := l_required_bugfix_indexes(i);

      if (g_globals.debug_on) then
         if (i > 0) then
            debug_to_report('');
         end if;
         debug_to_report('Post processing ' || g_bugfixes(l_bugfix_index).bug_number);
         g_globals.indent_level := g_globals.indent_level + 1;
      end if;

      -- Get equivalency result of this bugfix

      g_globals.get_equivalency_call_count := 0;

      l_equivalency_result := get_equivalency_result(l_bugfix_index,
                                                     g_bugfixes(l_bugfix_index).bug_number);

      if (g_globals.debug_on) then
         debug_to_report('Number of get_equivalency_result() calls : ' || g_globals.get_equivalency_call_count);
      end if;

      if (((l_equivalency_result = EQUIVALENCY_COMPLETED_REQUIRED) and
           (g_bugfixes(l_bugfix_index).equivalent_bugfix_index <> l_bugfix_index)) or
          (l_equivalency_result in (EQUIVALENCY_COMPLETED_MERGED,
                                    EQUIVALENCY_COMPLETED_APPLIED))) then

         set_bugfix_required(l_bugfix_index, false);

         if (g_globals.debug_on) then
            debug_to_report('Equivalency Removal: ' ||
               g_bugfixes(l_bugfix_index).bugfix_id ||
               ' is not required since it has an ' ||
               l_equivalency_result || ' equivalent bugfix.');
            debug_to_report('Equivalency Path : ' ||
               g_bugfixes(l_bugfix_index).bug_number ||
               g_bugfixes(l_bugfix_index).equivalency_path);
         end if; -- debug
      end if;

      if (g_globals.debug_on) then
         g_globals.indent_level := g_globals.indent_level - 1;
      end if;
   end loop; -- init_required_bugfix_indexes

exception
   when others then
      raise_others_error('do_equivalency_removal');
end do_equivalency_removal;

--------------------------------------------------------------------------------
procedure post_process_required_bugfixes
is
   l_count number;
begin
   if (g_globals.required_bugfix_count > 0) then
      if (g_globals.debug_on) then
         l_count := g_globals.required_bugfix_count;
         debug_to_report(' ');
         debug_to_report('Post processing required bugfixes');
         debug_to_report('--------------------------------------------------');
      end if;

      do_equivalency_removal();

      if (g_globals.debug_on) then
         l_count := l_count - g_globals.required_bugfix_count;

         debug_to_report('--------------------------------------------------');
         if (l_count = 0) then
            debug_to_report('Nothing was removed from the required bugfixes list.');
         else
            if (l_count = 1) then
               debug_to_report('1 bugfix was removed from the required bugfixes list.');
            else
               debug_to_report(l_count || ' bugfixes were removed from the required bugfixes list.');
            end if;
            debug_array_to_report('Required Bugfixes');
         end if;
      end if;
   end if;
exception
   when others then
      raise_others_error('post_process_required_bugfixes');
end post_process_required_bugfixes;

--------------------------------------------------------------------------------
-- Gets the return status.
--
-- return: the return status
--------------------------------------------------------------------------------
function get_return_status
   return varchar2
is
   l_status                     varchar2(30);
   l_all_top_level_bugs_applied boolean;
   l_missing_top_level_bug_info boolean;
begin
   l_status := null;

   -- STATUS_ERROR
   -- Code doesn't come here in case of error.

   -- STATUS_OBSOLETED

   if (g_globals.obs_top_level_bugfix_exists) then
      -- there is an obsolete top-level bugfix

      l_status := STATUS_OBSOLETED;
      goto done;
   end if;

   -- STATUS_MISSING

   if (g_globals.required_bugfix_count > 0) then
      -- there is a missing prereq

      l_status := STATUS_MISSING;
      goto done;
   end if;

   -- STATUS_APPLIED

   l_all_top_level_bugs_applied := true;

   for i in 0 .. g_globals.top_level_bugfix_count - 1 loop
      if (g_bugfixes(i).application_status <> APP_STATUS_EXPLICITLY_APPLIED) then
         l_all_top_level_bugs_applied := false;
         exit;
      end if;
   end loop;

   if (l_all_top_level_bugs_applied) then
      -- all top-level bugfixes are already applied

      l_status := STATUS_APPLIED;
      goto done;
   end if;

   -- STATUS_NO_INFORMATION

   l_missing_top_level_bug_info := false;

   for i in 0 .. g_globals.top_level_bugfix_count - 1 loop
      if ((g_bugfixes(i).application_status <> APP_STATUS_EXPLICITLY_APPLIED) and
          (g_bugfixes(i).patch_type = PATCH_TYPE_US_NON_UMS)) then
         l_missing_top_level_bug_info := true;
         exit;
      end if;
   end loop;

   if (l_missing_top_level_bug_info) then
      -- at least one un-applied top-level bugfix is a US_NON_UMS bugfix

      l_status := STATUS_NO_INFORMATION;
      goto done;
   end if;

   -- STATUS_READY;

   -- none of the top-level bugfixes is obsolete
   -- nothing is missing
   -- at least one bugfix is unapplied
   -- none of the unapplied top-level bugfixes is US_NON_UMS

   l_status := STATUS_READY;

<<done>>
   return l_status;

exception
   when others then
      raise_others_error('get_return_status');
end get_return_status;

--------------------------------------------------------------------------------
-- Prints information about the bugfix.
--
-- p_symbol - symbol
-- p_bugfix_index - bugfix index
--------------------------------------------------------------------------------
procedure report_one_bugfix(p_symbol       in varchar2,
                            p_bugfix_index in binary_integer)
is
   l_bugfix                  bugfix;
   l_replacement_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
   l_replacement_bugfix      bugfix;
begin
   l_bugfix := g_bugfixes(p_bugfix_index);

   -- write the symbol, bugfix id, application short name, and abstract
   append_to_report('');
   append_to_report(p_symbol || ' ' || l_bugfix.bugfix_id || ' ' ||
      l_bugfix.application_short_name || ': ' || l_bugfix.abstract);

   if (l_bugfix.release_status = RSTATUS_OBSOLETED) then
      append_to_report('   Action required: This patch is obsoleted, please use a replacement patch instead.');

      l_replacement_bugfix_guid := get_replacement_bugfix_guid(l_bugfix.bugfix_guid,
                                                               REPLACEMENT_LAST_NON_OBSOLETE);

      if (l_replacement_bugfix_guid is not null) then
         l_replacement_bugfix := get_bugfix(l_replacement_bugfix_guid);

         append_to_report('   Latest replacement: ' ||
            l_replacement_bugfix.bugfix_id || ' ' ||
            l_replacement_bugfix.application_short_name || ': ' ||
            l_replacement_bugfix.abstract);
      end if;
   end if;

   if (g_globals.debug_on) then
      append_to_report('   Release status: ' || l_bugfix.release_status);
      append_to_report('   Application status: ' || l_bugfix.application_status);
   end if;

exception
   when others then
      raise_others_error('report_one_bugfix',
         p_symbol,
         g_bugfixes(p_bugfix_index).bug_number);
end report_one_bugfix;

--------------------------------------------------------------------------------
-- Produces the report
--------------------------------------------------------------------------------
procedure produce_report
is
   l_bugfix                     bugfix;
   l_symbol                     varchar2(10);
   l_symbol_obsoleted_used      boolean := false;
   l_symbol_missing_used        boolean := false;
   l_symbol_applied_used        boolean := false;
   l_symbol_no_information_used boolean := false;
   l_symbol_not_applied_used    boolean := false;
begin
   -- Output the facts about analyzed bugfixes

   -- obsoleted top level bugfixes (UMS)
   -- required bugfixes (UMS)
   -- applied top level bugfixes (UMS or non-UMS)
   -- not applied, no information top level bugfixes (non-UMS)
   -- not applied top level bugfixes (UMS)

   for i in 0 .. g_globals.required_bugfix_count - 1 loop

      l_symbol := SYMBOL_MISSING;
      l_symbol_missing_used := true;

      report_one_bugfix(l_symbol, g_globals.required_bugfix_indexes(i));
   end loop;

   -- top level bugfixes (obsoleted, applied or not applied)

   for i in 0 .. g_globals.top_level_bugfix_count - 1 loop
      l_bugfix := g_bugfixes(i);

      if (not l_bugfix.required) then

         if (l_bugfix.release_status = RSTATUS_OBSOLETED) then
            -- flag the bugfix as obsoleted

            l_symbol := SYMBOL_OBSOLETED;
            l_symbol_obsoleted_used := true;

         elsif (l_bugfix.application_status = APP_STATUS_EXPLICITLY_APPLIED) then
            -- flag the bugfix as being already applied

            l_symbol := SYMBOL_APPLIED;
            l_symbol_applied_used := true;

         elsif (l_bugfix.patch_type = PATCH_TYPE_US_NON_UMS) then
            -- flag the bugfix as not having UMS metadata

            l_symbol := SYMBOL_NO_INFORMATION;
            l_symbol_no_information_used := true;

         else
            -- flag the bugfix as not applied

            l_symbol := SYMBOL_NOT_APPLIED;
            l_symbol_not_applied_used := true;

         end if;

         report_one_bugfix(l_symbol, l_bugfix.bugfix_index);
      end if;
   end loop;

   -- print the legend

   if (l_symbol_missing_used or
       l_symbol_obsoleted_used or
       l_symbol_applied_used or
       l_symbol_no_information_used or
       l_symbol_not_applied_used) then

      append_to_report('');
      append_to_report('Symbol Legend');
      append_to_report('-------------');

      if (l_symbol_missing_used) then
         append_to_report(SYMBOL_MISSING || ': Unapplied prerequisite patch.');
         append_to_report('   This prerequisite patch must be applied together with the current patch(es).');
         append_to_report('   Please merge this patch with the current patch(es) and apply them together.');
      end if;

      if (l_symbol_obsoleted_used) then
         append_to_report(SYMBOL_OBSOLETED || ': Obsoleted patch.');
         append_to_report('   An obsoleted patch cannot be applied.');
         append_to_report('   Please apply its replacement instead.');
      end if;

      if (l_symbol_applied_used) then
         append_to_report(SYMBOL_APPLIED || ': Applied patch.');
         append_to_report('   This patch is already applied and is about to be re-applied.');
      end if;

      if (l_symbol_no_information_used) then
         append_to_report(SYMBOL_NO_INFORMATION || ': Patch without prerequisite check information.');
         append_to_report('   This patch is about to be applied. However, it does not have a prerequisite');
         append_to_report('   check information file. Please check its README for any prerequisites.');
         append_to_report('   If there are any that have not been applied, please apply them first.');
      end if;

      if (l_symbol_not_applied_used) then
         append_to_report(SYMBOL_NOT_APPLIED || ': Patch with prerequisite check information.');
         append_to_report('   This patch is about to be applied.');
      end if;

      append_to_report('');
   end if;

exception
   when others then
      raise_others_error('produce_report');
end produce_report;

--------------------------------------------------------------------------------
-- Parses the comma-separated list of bug numbers and language codes
-- and extracts them into an array.
--
-- p_bug_list - the comma-separated list of bug numbers and language codes
-- x_bug_count - the number of bugs
-- x_bug_array - the array of bug numbers and language codes
--------------------------------------------------------------------------------
procedure parse_bug_numbers(p_bug_list  in  varchar2,
                            x_bug_count out nocopy number,
                            x_bug_array out nocopy input_bug_array)
is
   l_pos           number;
   l_bug_count     number;
   l_bug_list      varchar2(32000);
   l_vc2           varchar2(2000);
   l_bug_number    number;
   l_language_code varchar2(2000);
   l_error_message varchar2(2000);
begin
   l_bug_count := 0;
   l_bug_list := Ltrim(Rtrim(p_bug_list,' '),' ');

   if (l_bug_list is null) then
      l_error_message := 'Empty bug number and language code list.';
      goto return_error;
   end if;

   --
   -- In case of trailing comma ',', adding space will force loop to go one
   -- more iteration and ':' is missing error will be displayed.
   --
   l_bug_list := l_bug_list || ' ';

   while l_bug_list is not null loop
      l_pos := instr(l_bug_list, ',');

      if (l_pos = 0) then
         l_pos := length(l_bug_list) + 1;
      end if;

      l_vc2 := substr(l_bug_list, 1, l_pos - 1);
      l_vc2 := ltrim(rtrim(l_vc2, ' '), ' ');
      l_bug_list := substr(l_bug_list, l_pos + 1);

      -- now we have '<bug_number>:<language_code>'

      l_pos := nvl(instr(l_vc2, ':'), 0);

      if (l_pos = 0) then
         l_error_message := 'Incorrect syntax in ''' || l_vc2 ||
            '''. '':'' is missing.';
         goto return_error;
      end if;

      -- get the bug_number.

      declare
         l_tmp varchar2(2000);
      begin
         l_tmp := substr(l_vc2, 1, l_pos - 1);
         l_bug_number := to_number(l_tmp);
         if l_bug_number is null then
            l_error_message := 'Incorrect syntax in ''' || l_vc2 ||
               '''. <bug_number> is missing.';
            goto return_error;
         end if;
      exception
         when others then
            l_error_message := 'Incorrect syntax in ''' || l_vc2 ||
               '''. <bug_number> is not a number.';
            goto return_error;
      end;

      -- get the language_code.

      begin
         l_language_code := substr(l_vc2, l_pos + 1);
         l_language_code := ltrim(l_language_code, ' ');

         if l_language_code is null then
            l_error_message := 'Incorrect syntax in ''' || l_vc2 ||
               '''. Language code is missing.';
            goto return_error;
         end if;
      end;

      x_bug_array(l_bug_count).bug_number := l_bug_number;
      x_bug_array(l_bug_count).language_code := l_language_code;
      l_bug_count := l_bug_count + 1;
   end loop;

   x_bug_count := l_bug_count;
   return;

<<return_error>>
   raise_formatted_error(ERROR_UMS_INVALID_BUG_LIST,
      get_formatted_error('Syntax error in p_bug_numbers argument of UMS analysis engine call.',
         l_error_message,
         'The correct syntax is ' || '''<bug_number>:<language_code>[,<bug_number>:<language_code>]'''));
exception
   when others then
      raise_others_error('parse_bug_numbers', p_bug_list);
end parse_bug_numbers;

--------------------------------------------------------------------------------
-- Initializes the globals
--
-- p_appl_top_id - APPL_TOP id
-- p_release_name - release name
-- p_bug_numbers - bug numbers
-- p_mode - engine mode
--------------------------------------------------------------------------------
procedure init_globals(p_appl_top_id  in  number,
                       p_release_name in  varchar2,
                       p_bug_numbers  in  varchar2,
                       p_mode         in  varchar2)
is
begin
   g_globals.appl_top_id := p_appl_top_id;
   g_globals.indent_level := 0;
   g_globals.top_level_bugfix_count := 0;
   g_globals.bugfix_count := 0;
   g_globals.required_bugfix_count := 0;
   g_globals.report_count := 1;
   g_globals.report(1) := '';
   g_globals.replacement_chain_tag_counter := 0;
   g_globals.obs_top_level_bugfix_exists := false;
   g_globals.status := null;
   g_globals.exception_depth := 0;
   g_globals.prereq_list := null;

   if (p_mode = MODE_NORMAL) then
      g_globals.debug_on := false;
   elsif (p_mode = MODE_DEBUG) then
      g_globals.debug_on := true;
   else
      raise_formatted_error(ERROR_UMS_INVALID_ENGINE_MODE,
         get_formatted_error('UMS analysis engine was not called properly.',
            p_mode || ' is not a valid UMS analysis engine mode.',
            'Valid modes are: ' || MODE_NORMAL || ', ' || MODE_DEBUG));
   end if;

   g_globals.engine_mode := p_mode;

   -- get APPL_TOP info, and report it

   declare
      l_appl_top_name varchar2(100);
      l_applications_system_name varchar2(100);
   begin
      begin
         select 'AFUMSAEB.pls : $Revision: 120.1 $ : init_globals' arcs_revision,
                name, applications_system_name
           into g_arcs_revision,
                l_appl_top_name, l_applications_system_name
           from ad_appl_tops
          where appl_top_id = p_appl_top_id;
      exception
         when no_data_found then
            if (p_appl_top_id = GLOBAL_APPL_TOP_ID) then
               l_appl_top_name := 'GLOBAL APPL_TOP';
            else
               l_appl_top_name := 'APPL_TOP_ID ' || p_appl_top_id || ' does not exist.';
            end if;
            l_applications_system_name := l_appl_top_name;
      end;

      append_to_report('Running UMS analysis engine with the following parameters:');
      append_to_report('');
      append_to_report('p_appl_top_id = ' || p_appl_top_id);
      append_to_report('   appl_top_name = ' || l_appl_top_name);
      append_to_report('   applications_system_name = ' || l_applications_system_name);
      append_to_report('p_release_name = ' || p_release_name);
      append_to_report('p_bug_numbers = ' || p_bug_numbers);
      append_to_report('p_mode = ' || p_mode);
   exception
      when no_data_found then
         raise_formatted_error(ERROR_UMS_INVALID_APPL_TOP_ID,
            get_formatted_error('UMS analysis engine was called with an invalid appl_top_id.',
               'The appl_top_id ' || p_appl_top_id || ' does not exist.'));
   end;

   -- parse the bug numbers and the language codes

   declare
      l_bugfix          bugfix;

      l_input_bug_count number;
      l_input_bug_array input_bug_array;
   begin
      parse_bug_numbers(p_bug_numbers, l_input_bug_count, l_input_bug_array);

      -- create top-level bugfixes in the global cache.

      for i in 0 .. l_input_bug_count - 1 loop
         l_bugfix := get_bugfix(p_release_name,
                                l_input_bug_array(i).bug_number,
                                l_input_bug_array(i).language_code);

         g_bugfixes(l_bugfix.bugfix_index).merged := true;

         if (l_bugfix.release_status = RSTATUS_OBSOLETED) then
            g_globals.obs_top_level_bugfix_exists := true;
         end if;
      end loop;

      g_globals.top_level_bugfix_count := g_globals.bugfix_count;

      for i in 0 .. g_globals.top_level_bugfix_count - 1 loop
         g_globals.top_level_bugfix_indexes(i) := i;
      end loop;

      if (g_globals.debug_on) then
         debug_array_to_report('Top Level Bugfixes');
      end if;
   end;

exception
   when others then
      raise_others_error('init_globals',
         p_appl_top_id,
         p_release_name,
         p_bug_numbers,
         p_mode);
end init_globals;

--------------------------------------------------------------------------------
procedure get_removable_obs_required(px_obs_required_bugfix_index in out nocopy binary_integer,
                                     px_replacement_bugfix_index  in out nocopy binary_integer)
is
   l_bugfix                  bugfix;
   l_replacement_bugfix      bugfix;
   l_replacement_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
begin
   px_obs_required_bugfix_index := null;
   px_replacement_bugfix_index := null;

   -- Loop over required bugfixes

   for i in 0 .. g_globals.required_bugfix_count - 1 loop

      l_bugfix := g_bugfixes(g_globals.required_bugfix_indexes(i));

      if (l_bugfix.release_status = RSTATUS_OBSOLETED) then

         -- See if this bugfix has a first non obsolete bugfix

         l_replacement_bugfix_guid := get_replacement_bugfix_guid(l_bugfix.bugfix_guid,
                                                                  REPLACEMENT_FIRST_NON_OBSOLETE);

         if (l_replacement_bugfix_guid is not null) then

            l_replacement_bugfix := get_bugfix(l_replacement_bugfix_guid);

            -- This obsolete required bugfix is removable.

            px_obs_required_bugfix_index := l_bugfix.bugfix_index;
            px_replacement_bugfix_index := l_replacement_bugfix.bugfix_index;

            exit; -- from the required bugfix loop
         end if;
      end if;
   end loop;

exception
   when others then
      raise_others_error('get_removable_obs_required');
end get_removable_obs_required;

--------------------------------------------------------------------------------
procedure get_rid_of_obsolete_prereqs
is
   l_obs_required_bugfix_index binary_integer;
   l_replacement_bugfix_index  binary_integer;
begin
   if (g_globals.required_bugfix_count > 0) then
      -- Try to get rid of obsolete prereqs

      get_removable_obs_required(l_obs_required_bugfix_index,
                                 l_replacement_bugfix_index);

      if (l_obs_required_bugfix_index is not null) then
         if (g_globals.debug_on) then
            debug_to_report(' ');
            debug_to_report('Trying to get rid of obsolete prereqs:');
            debug_to_report('--------------------------------------------------');
         end if;
      end if;

      while (l_obs_required_bugfix_index is not null) loop

         -- We have a removable obsolete required bugfix

         if (g_globals.debug_on) then
            debug_to_report('Obsolete Prereq:' || g_bugfixes(l_obs_required_bugfix_index).bugfix_id);
            debug_to_report('Replacement    :' || g_bugfixes(l_replacement_bugfix_index).bugfix_id);
            debug_to_report(' ');
         end if;

         -- perform the dependency analysis

         check_bugfix_prereqs(l_replacement_bugfix_index);

         set_bugfix_required(l_replacement_bugfix_index, true);

         set_bugfix_required(l_obs_required_bugfix_index, false);

         if (g_globals.debug_on) then
            debug_array_to_report('Required Bugfixes');
         end if;

         get_removable_obs_required(l_obs_required_bugfix_index,
                                    l_replacement_bugfix_index);
      end loop;
   end if;
exception
   when others then
      raise_others_error('get_rid_of_obsolete_prereqs');
end get_rid_of_obsolete_prereqs;

--------------------------------------------------------------------------------
procedure check_top_level_bugfix_prereqs
is
begin
   if (g_globals.debug_on) then
      debug_to_report(' ');
      debug_to_report('Checking prereqs of top level bugfixes:');
      debug_to_report('--------------------------------------------------');
   end if;

   for i in 0 .. g_globals.top_level_bugfix_count - 1 loop
      check_bugfix_prereqs(g_globals.top_level_bugfix_indexes(i));
   end loop;

   if (g_globals.debug_on) then
      debug_array_to_report('Required Bugfixes');
   end if;
exception
   when others then
      raise_others_error('check_top_level_bugfix_prereqs');
end check_top_level_bugfix_prereqs;

--------------------------------------------------------------------------------
procedure analyze_dependencies(p_appl_top_id  in  number,
                               p_release_name in  varchar2,
                               p_bug_numbers  in  varchar2,
                               p_mode         in  varchar2,
                               x_status       out nocopy varchar2)
is
begin
   init_globals(p_appl_top_id, p_release_name, p_bug_numbers, p_mode);

   -- check for top-level obsoleted bugfixes

   if (g_globals.obs_top_level_bugfix_exists) then
      goto done;
   end if;

   -- check prereqs of top level bugfixes

   check_top_level_bugfix_prereqs();

   -- get rid of obsolete prereqs

   get_rid_of_obsolete_prereqs();

   -- post process required bugfixes

   post_process_required_bugfixes();

<<done>>
   -- get the return status

   g_globals.status := get_return_status();
   g_globals.prereq_list := compute_prereq_list();

   -- produce the report

   produce_report();

   x_status := g_globals.status;
exception
   when others then
      begin
         raise_others_error('analyze_dependencies',
            p_appl_top_id,
            p_release_name,
            p_bug_numbers,
            p_mode);
      exception
         when others then
            g_globals.status := STATUS_ERROR;
            x_status := g_globals.status;
            exception_to_report();
      end;
end analyze_dependencies;

--------------------------------------------------------------------------------
function get_prereq_list
   return varchar2
is
begin
   if (not is_engine_called()) then

      raise_formatted_error(ERROR_UMS_ENGINE_NOT_CALLED,
         get_formatted_error('State error in get_prereq_list()',
            'analyze_dependencies() must be called first.'));

   elsif (g_globals.status in (STATUS_OBSOLETED, STATUS_ERROR)) then

      raise_formatted_error(ERROR_UMS_ILLEGAL_STATE,
         get_formatted_error('State error in get_prereq_list()',
            'Prereq list is not defined in ' || STATUS_OBSOLETED ||
            ' and ' || STATUS_ERROR || ' statuses.'));

   end if;

   return g_globals.prereq_list;
exception
   when others then
      begin
         raise_others_error('get_prereq_list');
      exception
         when others then
            exception_to_report();
            raise;
      end;
end get_prereq_list;

--------------------------------------------------------------------------------
function get_report_count return number
is
begin
   return g_globals.report_count;
end get_report_count;

--------------------------------------------------------------------------------
function get_report(i in number) return varchar2
is
begin
   return g_globals.report(i);
end get_report;

begin
   NEWLINE := fnd_ums_loader.newline();
   g_globals.engine_mode := MODE_NOT_CALLED;
end fnd_ums_analysis_engine;

/
