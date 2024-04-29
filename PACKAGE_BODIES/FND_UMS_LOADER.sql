--------------------------------------------------------
--  DDL for Package Body FND_UMS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_UMS_LOADER" as
/* $Header: AFUMSLDB.pls 115.37 2004/09/20 23:07:15 golgun noship $ */

-- ==================================================
-- Constants and Types.
-- ==================================================

G_STD_DATE_MASK constant varchar2(100) := 'YYYY/MM/DD HH24:MI:SS';

DEBUG_OFF       constant varchar2(10) := 'N';
DEBUG_ON        constant varchar2(10) := 'Y';
DEBUG_STATS     constant varchar2(10) := 'S';
DEBUG_ABORT     constant varchar2(10) := 'A';

g_debug_flag    varchar2(10);
g_newline       varchar2(10);
g_default_date  date;

--
-- lock life and wait times in terms of seconds
--
g_lock_lifetime integer := 1*24*60*60; -- one day
g_lock_waittime integer := 5*60;       -- five minutes

g_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;

-- Prereqs/Includes/Links data level

PIL_LEVEL_NONE             constant integer := 0;
PIL_LEVEL_PREREQS_INCLUDES constant integer := 1;
PIL_LEVEL_LINKS            constant integer := 2;

-- Unknown data

NOT_AVAILABLE constant varchar2(10) := 'N/A';

-- UMS tables will be analyzed if
--  - analyze hasn't been run for more than TABLE_ANALYZE_PERIOD days or
--  - percentage of row count change is more than TABLE_ANALYZE_PERCENTAGE

TABLE_ANALYZE_PERIOD     constant number := 28; -- 28 days (4 weeks)
TABLE_ANALYZE_PERCENTAGE constant number := 5;  -- 5%

-- Error codes

ERROR_UNKNOWN_DOWNLOAD_MODE  constant number := -20001;
ERROR_UNKNOWN_UPLOAD_PHASE   constant number := -20002;
ERROR_UNABLE_TO_LOCK         constant number := -20003;
ERROR_ABORT                  constant number := -20100;

-- Error Messages

MSG_ABORT_OLDER constant varchar2(100) := 'Since file data is older, aborted upload of bug ';
MSG_ABORT_LEVEL constant varchar2(100) := 'Since database data is at least as complete as file data, aborted upload of bug ';

type forced_bugfix_lookup is table of varchar2(1) index by binary_integer;

type data_contents is record
   (download_mode          varchar2(30),
    last_definition_date   date,
    last_update_date       date,
    has_bugfix_replacement boolean,
    pil_level              integer,
    has_files              boolean,
    download_code          varchar2(30));

type upload_controller is record
   (upload_bugfix_replacement     boolean,
    upload_prereqs_includes_links boolean,
    upload_files                  boolean);

type row_counts is record
   (bugfixes              number,
    bugfix_relationships  number,
    files                 number,
    file_versions         number,
    bugfix_file_versions  number);

type ums_table is record
   (owner_name     varchar2(30),
    table_name     varchar2(30),
    last_analyzed  date,
    num_rows       number,
    delta_num_rows number);

type ums_tables is table of ums_table index by binary_integer;

g_uc upload_controller;
g_rc row_counts;
g_forced_bugfixes forced_bugfix_lookup;

--------------------------------------------------------------------------------
procedure debug(p_debug in varchar2)
is
begin
   if (g_debug_flag <> DEBUG_OFF) then
      fnd_file.put_line(fnd_file.Log, p_debug);
   end if;
exception
   when others then
      null;
end debug;

--------------------------------------------------------------------------------
procedure debug(p_func_name in varchar2,
                p_debug     in varchar2)
is
begin
   if (g_debug_flag <> DEBUG_OFF) then
      fnd_file.put_line
         (fnd_file.Log,
         'FUNCTION:' || p_func_name        || g_newline ||
         'DEBUG   :' || p_debug            || g_newline ||
         'SYSDATE :' || To_char(Sysdate, G_STD_DATE_MASK));
   end if;
exception
   when others then
      null;
end debug;

--------------------------------------------------------------------------------
procedure set_debugging(p_debug_flag in varchar2)
is
   l_old_debug_flag varchar2(10);
begin
   l_old_debug_flag := g_debug_flag;
   g_debug_flag := Nvl(Upper(Substr(p_debug_flag, 1, 1)), DEBUG_OFF);
   if ((l_old_debug_flag = DEBUG_OFF) and (g_debug_flag = DEBUG_ON)) then
      debug(' ');
      debug('Update Management System Loader Debugger');
      debug(rpad('-', 77, '-'));
      debug('Sysdate = ' || to_char(sysdate, G_STD_DATE_MASK));
      debug('Legend: DM: Download Mode. LDD: Last definition Date. LUD: Last Update Date.');
      debug(' ');
   end if;
exception
   when others then
      null;
end set_debugging;

--------------------------------------------------------------------------------
-- Locks the entity before insert.
-- p_entity_name - name of the entity
-- p_key1..3 - primary keys of the entity
--------------------------------------------------------------------------------
PROCEDURE lock_entity(p_entity_name in varchar2,
                      p_key1        in varchar2 default null,
                      p_key2        in varchar2 default null,
                      p_key3        in varchar2 default null)
is
   l_entity      varchar2(32000);
   l_hash_value  number;
   l_lock_name   varchar2(128);
   l_lock_handle varchar2(128);
   l_lock_status integer;
begin
   -- Get a unique lock name

   l_entity := 'FND.UMS.' || p_entity_name || '.' ||
               p_key1 || '.' || p_key2 || '.' || p_key3;

   if (lengthb(l_entity) > 128) then
      -- lockname cannot be longer than 128 bytes.
      -- Get a hash value between 1 and 65536.
      l_hash_value := dbms_utility.get_hash_value(l_entity, 1, 65536);
      l_lock_name := 'FND.UMS.HASH.' || p_entity_name || '.' || l_hash_value;
      l_lock_name := substrb(l_lock_name, 1, 128);
   else
      l_lock_name := l_entity;
   end if;

   dbms_lock.allocate_unique(lockname        => l_lock_name,
                             lockhandle      => l_lock_handle,
                             expiration_secs => g_lock_lifetime);

   l_lock_status := dbms_lock.request(lockhandle        => l_lock_handle,
                                      lockmode          => dbms_lock.x_mode,
                                      timeout           => g_lock_waittime,
                                      release_on_commit => TRUE);

   if (l_lock_status <> 0) then
      raise_application_error(ERROR_UNABLE_TO_LOCK,
                              'Unable to lock entity : ' || l_entity ||
                              '. dbms_lock.request(' || l_lock_name ||
                              ') returned : ' || l_lock_status);
   end if;
end lock_entity;

--------------------------------------------------------------------------------
-- Analyzes table stats iff
--  - analyze hasn't been run for more than TABLE_ANALYZE_PERIOD of time
--  - percentage of row count change is more than TABLE_ANALYZE_PERCENTAGE
--
-- p_ums_table - ums table details
--------------------------------------------------------------------------------
procedure analyze_table(p_ums_table in ums_table)
is
   l_analyze_needed boolean;
begin
   if (g_debug_flag = DEBUG_STATS) then
      debug('Owner.Table Name        : ' || p_ums_table.owner_name || '.' || p_ums_table.table_name);
      debug('Number of Data Changes  : ' || p_ums_table.delta_num_rows);
      debug('Last Analyzed Row Count : ' || p_ums_table.num_rows);
      debug('Last Analyzed Date      : ' || to_char(p_ums_table.last_analyzed, G_STD_DATE_MASK));
   end if;

   l_analyze_needed := false;

   if ((p_ums_table.last_analyzed is null) or
       (sysdate - p_ums_table.last_analyzed > TABLE_ANALYZE_PERIOD)) then

      if (g_debug_flag = DEBUG_STATS) then
         debug('Table has not been analyzed for more than TABLE_ANALYZE_PERIOD of ' ||
            TABLE_ANALYZE_PERIOD || ' days');
      end if;

      l_analyze_needed := true;

   elsif ((p_ums_table.num_rows is null) or
          (p_ums_table.delta_num_rows > p_ums_table.num_rows * TABLE_ANALYZE_PERCENTAGE / 100)) then

      if (g_debug_flag = DEBUG_STATS) then
         debug(p_ums_table.delta_num_rows || ' data changes exceeds the TABLE_ANALYZE_PERCENTAGE of ' ||
            TABLE_ANALYZE_PERCENTAGE || '%');
      end if;

      l_analyze_needed := true;

   end if;

   if (l_analyze_needed) then

      fnd_stats.gather_table_stats(p_ums_table.owner_name, p_ums_table.table_name);

      if (g_debug_flag = DEBUG_STATS) then
         debug('Statistics were successfully gathered.');
         debug(' ');
      end if;

   else
      if (g_debug_flag = DEBUG_STATS) then
         debug('There is no need to gather statistics.');
         debug(' ');
      end if;
   end if;

exception
   when others then
      if (g_debug_flag = DEBUG_STATS) then
         debug('analyze_table(''' ||
            p_ums_table.owner_name || ''', ''' || p_ums_table.table_name || ''') failed.');
         debug('SQLERRM : ' || sqlerrm);
      end if;
end analyze_table;

--------------------------------------------------------------------------------
-- Gets UMS table details from dba_tables.
--------------------------------------------------------------------------------
procedure add_table_details(px_ums_tables      in out nocopy ums_tables,
                            px_ums_table_count in out nocopy binary_integer,
                            p_table_name       in varchar2,
                            p_delta_num_rows   in number)
is
   cursor l_applsys_schemas is
      select fou.oracle_username
        from fnd_oracle_userid fou,
             fnd_product_installations fpi
       where fou.oracle_id = fpi.oracle_id
         and fpi.application_id = 0;

   cursor l_ums_tables(p_owner in varchar2, p_table_name in varchar2) is
      select owner, table_name, last_analyzed, num_rows
        from dba_tables
       where owner = p_owner
         and table_name = p_table_name;
begin
   for l_applsys_schema in l_applsys_schemas loop
      for l_ums_table in l_ums_tables(l_applsys_schema.oracle_username, p_table_name) loop

         px_ums_tables(px_ums_table_count).owner_name     := l_ums_table.owner;
         px_ums_tables(px_ums_table_count).table_name     := l_ums_table.table_name;
         px_ums_tables(px_ums_table_count).last_analyzed  := l_ums_table.last_analyzed;
         px_ums_tables(px_ums_table_count).num_rows       := l_ums_table.num_rows;
         px_ums_tables(px_ums_table_count).delta_num_rows := p_delta_num_rows;

         px_ums_table_count := px_ums_table_count + 1;

      end loop;
   end loop;
exception
   when others then
      if (g_debug_flag = DEBUG_STATS) then
         debug('Unable to get table details for ' || p_table_name || '.');
         debug('SQLERRM : ' || sqlerrm);
      end if;
end add_table_details;

--------------------------------------------------------------------------------
-- Analyzes UMS table stats
--------------------------------------------------------------------------------
procedure analyze_ums_tables
is
   l_ums_tables      ums_tables;
   l_ums_table_count binary_integer;
   l_debug_flag      varchar2(10);
begin
   l_debug_flag := g_debug_flag;
   g_debug_flag := DEBUG_STATS;

   l_ums_table_count := 0;

   add_table_details(l_ums_tables, l_ums_table_count, 'FND_UMS_BUGFIXES',             g_rc.bugfixes);
   add_table_details(l_ums_tables, l_ums_table_count, 'FND_UMS_BUGFIX_RELATIONSHIPS', g_rc.bugfix_relationships);
   add_table_details(l_ums_tables, l_ums_table_count, 'FND_UMS_FILES',                g_rc.files);
   add_table_details(l_ums_tables, l_ums_table_count, 'FND_UMS_FILE_VERSIONS',        g_rc.file_versions);
   add_table_details(l_ums_tables, l_ums_table_count, 'FND_UMS_BUGFIX_FILE_VERSIONS', g_rc.bugfix_file_versions);

   if (g_debug_flag = DEBUG_STATS) then
      debug(' ');
      debug('Gathering Statistics for ' || l_ums_table_count || ' UMS table(s):');
      debug(rpad('-', 50, '-'));
   end if;

   for i in 0 .. l_ums_table_count - 1 loop
      analyze_table(l_ums_tables(i));
   end loop;

   g_debug_flag := l_debug_flag;
exception
   when others then
      g_debug_flag := l_debug_flag;
      null;
end analyze_ums_tables;

------------------------------------------------------------------------
-- Maps download_mode to data_contents.
------------------------------------------------------------------------
function get_data_contents(p_download_mode        in varchar2,
                           p_last_definition_date in date,
                           p_last_update_date     in date)
return data_contents
is
   l_data_contents data_contents;
begin
   l_data_contents.download_mode := p_download_mode;
   l_data_contents.last_definition_date := p_last_definition_date;
   l_data_contents.last_update_date := p_last_update_date;

   l_data_contents.has_bugfix_replacement := false;
   l_data_contents.pil_level := PIL_LEVEL_NONE;
   l_data_contents.has_files := false;
   l_data_contents.download_code := '';

   if (p_download_mode = DL_MODE_NONE) then
      l_data_contents.download_code := '';

   elsif (p_download_mode = DL_MODE_FILES_ONLY) then
      l_data_contents.download_code := 'F';

      l_data_contents.has_files := true;

   elsif (p_download_mode = DL_MODE_REPLACEMENTS_ONLY) then
      l_data_contents.download_code := 'BR';
      l_data_contents.has_bugfix_replacement := true;

   elsif (p_download_mode = DL_MODE_REPLACEMENTS_FILES) then
      l_data_contents.download_code := 'BRF';
      l_data_contents.has_bugfix_replacement := true;

      l_data_contents.has_files := true;

   elsif (p_download_mode = DL_MODE_PREREQS_ONLY) then
      l_data_contents.download_code := 'BRP';
      l_data_contents.has_bugfix_replacement := true;

      l_data_contents.pil_level := PIL_LEVEL_PREREQS_INCLUDES;

   elsif (p_download_mode = DL_MODE_PREREQS_FILES) then
      l_data_contents.download_code := 'BRPF';
      l_data_contents.has_bugfix_replacement := true;

      l_data_contents.pil_level := PIL_LEVEL_PREREQS_INCLUDES;
      l_data_contents.has_files := true;

   elsif (p_download_mode = DL_MODE_LINKS_ONLY) then
      l_data_contents.download_code := 'BRPL';
      l_data_contents.has_bugfix_replacement := true;

      l_data_contents.pil_level := PIL_LEVEL_LINKS;

   elsif (p_download_mode = DL_MODE_LINKS_FILES) then
      l_data_contents.download_code := 'BRPLF';
      l_data_contents.has_bugfix_replacement := true;

      l_data_contents.pil_level := PIL_LEVEL_LINKS;
      l_data_contents.has_files := true;

   else
      raise_application_error(ERROR_UNKNOWN_DOWNLOAD_MODE,
         'Unknown DOWNLOAD_MODE: ' || p_download_mode);

   end if;

   return l_data_contents;
end get_data_contents;

------------------------------------------------------------------------
-- Drives download_mode from the has_ flags.
------------------------------------------------------------------------
procedure derive_download_mode(px_data_contents in out nocopy data_contents)
is
   l_download_mode varchar2(30);
   l_download_code varchar2(30);
begin
   l_download_mode := DL_MODE_NONE;
   l_download_code := '';

   if (px_data_contents.has_bugfix_replacement) then
      l_download_mode := DL_MODE_REPLACEMENTS_ONLY;
      l_download_code := 'BR';

      if (px_data_contents.pil_level = PIL_LEVEL_PREREQS_INCLUDES) then
         l_download_mode := DL_MODE_PREREQS_ONLY;
         l_download_code := 'BRP';

         if (px_data_contents.has_files) then
            l_download_mode := DL_MODE_PREREQS_FILES;
            l_download_code := 'BRPF';
         end if;

      elsif (px_data_contents.pil_level = PIL_LEVEL_LINKS) then
         l_download_mode := DL_MODE_LINKS_ONLY;
         l_download_code := 'BRPL';

         if (px_data_contents.has_files) then
            l_download_mode := DL_MODE_LINKS_FILES;
            l_download_code := 'BRPLF';
         end if;

      elsif (px_data_contents.has_files) then
         l_download_mode := DL_MODE_REPLACEMENTS_FILES;
         l_download_code := 'BRF';
      end if;

   elsif (px_data_contents.has_files) then
      l_download_mode := DL_MODE_FILES_ONLY;
      l_download_code := 'F';
   end if;

   px_data_contents.download_mode := l_download_mode;
   px_data_contents.download_code := l_download_code;

end derive_download_mode;

procedure debug_up_fnd_ums_bugfix
  (p_release_name           in varchar2,
   p_bug_number             in varchar2,
   l_forced                 in boolean,
   l_file_dc                in data_contents,
   l_forced_db_dc           in data_contents,
   l_db_dc                  in data_contents,
   l_final_dc               in data_contents)
is
   l_debug varchar2(32000);
begin

   if (g_debug_flag = DEBUG_ON) then
      l_debug := 'Release Name: ' || p_release_name || ', ' ||
		 'Bug Number: ' || p_bug_number;

      if (l_forced) then
	 l_debug := l_debug || '   CUSTOM_MODE = FORCE';
      end if;

      debug(l_debug);

      -- Print Download Mode details.

      l_debug := '  ' || rpad('File DM:', 10) ||
		 rpad(l_file_dc.download_mode || '(' || l_file_dc.download_code || ')', 24);

      l_debug := l_debug || '   ' || rpad('DB DM:', 8) ||
		 rpad(l_db_dc.download_mode || '(' || l_db_dc.download_code || ')', 24);

      if (l_forced) then
	 l_debug := l_debug || ' <- ' || rpad('Old DB DM:', 12) ||
		    rpad(l_forced_db_dc.download_mode || '(' || l_forced_db_dc.download_code || ')', 24);
      end if;

      debug(l_debug);

      -- Print Last Definition Date details.

      l_debug := '  ' || rpad('File LDD:', 10) ||
		 rpad(to_char(l_file_dc.last_definition_date, G_STD_DATE_MASK), 24);

      if (l_file_dc.last_definition_date > l_db_dc.last_definition_date) then
	 l_debug := l_debug || ' > ';
      elsif (l_file_dc.last_definition_date = l_db_dc.last_definition_date) then
	 l_debug := l_debug || ' = ';
      else
	 l_debug := l_debug || ' < ';
      end if;

      l_debug := l_debug || rpad('DB LDD:', 8) ||
		 rpad(to_char(l_db_dc.last_definition_date, G_STD_DATE_MASK), 24);

      if (l_forced) then
	 l_debug := l_debug || ' <- ' || rpad('Old DB LDD:', 12) ||
		    rpad(to_char(l_forced_db_dc.last_definition_date, G_STD_DATE_MASK), 24);
      end if;

      debug(l_debug);

      -- Print Last Update Date details.

      l_debug := '  ' || rpad('File LUD:', 10) ||
		 rpad(to_char(l_file_dc.last_update_date, G_STD_DATE_MASK), 24);

      if (l_file_dc.last_update_date > l_db_dc.last_update_date) then
	 l_debug := l_debug || ' > ';
      elsif (l_file_dc.last_update_date = l_db_dc.last_update_date) then
	 l_debug := l_debug || ' = ';
      else
	 l_debug := l_debug || ' < ';
      end if;

      l_debug := l_debug || rpad('DB LUD:', 8) ||
		 rpad(to_char(l_db_dc.last_update_date, G_STD_DATE_MASK), 24);

      if (l_forced) then
	 l_debug := l_debug || ' <- ' || rpad('Old DB LUD:', 12) ||
		    rpad(to_char(l_forced_db_dc.last_update_date, G_STD_DATE_MASK), 24);
      end if;

      debug(l_debug);
      debug(rpad('  ', 80, '-'));

      -- Print the upload flags.

      if (g_uc.upload_bugfix_replacement) then
	 l_debug := '  up_bugfix_replacement: Y, ';
      else
	 l_debug := '  up_bugfix_replacement: N, ';
      end if;

      if (g_uc.upload_prereqs_includes_links) then
	 l_debug := l_debug || 'up_prereqs_includes_links: Y, ';
      else
	 l_debug := l_debug || 'up_prereqs_includes_links: N, ';
      end if;

      if (g_uc.upload_files) then
	 l_debug := l_debug || 'up_files: Y';
      else
	 l_debug := l_debug || 'up_files: N';
      end if;

      debug(l_debug);

      -- Report final result.

      l_debug := '  ' || rpad('Final DM:', 10) ||
		 rpad(l_final_dc.download_mode || '(' || l_final_dc.download_code || ')', 24);

      debug(l_debug);

      l_debug := '  ' || rpad('Final LDD:',10) ||
		 rpad(to_char(l_final_dc.last_definition_date, G_STD_DATE_MASK), 24);

      debug(l_debug);

      l_debug := '  ' || rpad('Final LUD:',10) ||
		 rpad(to_char(l_final_dc.last_update_date, G_STD_DATE_MASK), 24);

      debug(l_debug);

      debug(' ');
   end if;

end debug_up_fnd_ums_bugfix;

--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix
  (p_upload_phase           in varchar2,
   p_release_name           in varchar2,
   p_bug_number             in varchar2,
   p_download_mode          in varchar2,
   p_application_short_name in varchar2,
   p_release_status         in varchar2,
   p_type                   in varchar2,
   p_abstract               in varchar2,
   p_last_definition_date   in varchar2,
   p_last_update_date       in varchar2,
   p_custom_mode            in varchar2)
is
   l_file_dc  data_contents;
   l_db_dc    data_contents;
   l_final_dc data_contents;

   l_forced       boolean;
   l_forced_db_dc data_contents;
begin
   if (p_upload_phase = 'BEGIN') then
      -- Lock the entity first

      lock_entity('FND_UMS_BUGFIXES', 'TOP_LEVEL', p_release_name, p_bug_number);

      -- Gather LDT file details

      l_file_dc := get_data_contents(p_download_mode,
                                     to_date(nvl(p_last_definition_date, p_last_update_date), G_STD_DATE_MASK),
                                     to_date(p_last_update_date, G_STD_DATE_MASK));

      -- Gather database details

      declare
         l_bugfix fnd_ums_bugfixes%ROWTYPE;
      begin
         select /*+ INDEX(fnd_ums_bugfixes fnd_ums_bugfixes_u2) */ *
         into l_bugfix
         from fnd_ums_bugfixes
         where release_name = p_release_name
         and bug_number = p_bug_number;

         g_bugfix_guid := l_bugfix.bugfix_guid;

         l_db_dc := get_data_contents(l_bugfix.download_mode,
                                      l_bugfix.last_definition_date,
                                      l_bugfix.last_update_date);
      exception
         when no_data_found then
            -- there is no data for this bugfix in the database

            g_bugfix_guid := sys_guid();

            l_db_dc := get_data_contents(DL_MODE_NONE,
                                         g_default_date,
                                         g_default_date);
      end;

      -- determine if any upload is allowed.

      g_uc.upload_bugfix_replacement     := false;
      g_uc.upload_prereqs_includes_links := false;
      g_uc.upload_files                  := false;

      l_forced := false;
      if (p_custom_mode = 'FORCE') then
         -- If the bugfix is not already FORCEd, then FORCE it to be re-uploaded.

         declare
            l_already_forced boolean;
         begin
            declare
               l_vc2 varchar2(1);
            begin
               -- if a collection doesn't have an entry at a given index then
               -- fetching the entry from that index raises no_data_found exception.

               l_vc2 := g_forced_bugfixes(p_bug_number);
               l_already_forced := true;
            exception
               when no_data_found then
                  l_already_forced := false;
            end;

            if (not l_already_forced) then
               -- Force bugfix to be re-uploaded.
               l_forced := true;

               l_forced_db_dc := l_db_dc;

               g_uc.upload_bugfix_replacement     := true;
               g_uc.upload_prereqs_includes_links := true;
               g_uc.upload_files                  := true;

               l_db_dc := get_data_contents(DL_MODE_NONE,
                                            g_default_date,
                                            g_default_date);

               -- Mark this bugfix as forced.

               g_forced_bugfixes(p_bug_number) := 'Y';
            end if;
         end;
      end if;

      l_final_dc := l_db_dc;

      -- Decide whether or not bugfix and replacement (BR) should be uploaded
      --
      --          |                    DB
      --          | no_data_found  files_only  bugfix_replacement_exists
      -- ---------+------------------------------------------------------
      --    files | delete         delete      do nothing
      -- F   only | insert         insert
      -- i        |
      -- l     BR | delete         delete      file.LUD <= db.LUD : do nothing
      -- e exists | insert         insert      file.LUD >  db.LUD : delete/insert
      --

      if (l_file_dc.has_bugfix_replacement) then
         -- File has bugfix and replacement data

         l_final_dc.has_bugfix_replacement := true;

         if (l_db_dc.has_bugfix_replacement) then
            -- DB has bugfix and replacement data

            if (l_file_dc.last_update_date <= l_db_dc.last_update_date) then
               -- File last update date is older or same, do nothing

               null;

            else
               -- File update date is newer

               l_final_dc.last_update_date := l_file_dc.last_update_date;

               g_uc.upload_bugfix_replacement := true;

            end if; -- LUD
         else
            l_final_dc.last_update_date := l_file_dc.last_update_date;

            g_uc.upload_bugfix_replacement := true;

         end if;

      else
         if (l_db_dc.has_bugfix_replacement) then
            -- DB has bugfix and replacement data, do nothing
            null;

         else
            -- Create the dummy/template bugfix definition for foreign
            -- key reference purposes.

            g_uc.upload_bugfix_replacement := true;

            l_final_dc.has_bugfix_replacement := false;
         end if;
      end if;

      -- Decide whether or not PIL (prereqs/includes/links) data should be uploaded

        if (l_file_dc.pil_level > PIL_LEVEL_NONE) then
         -- File has PIL data

         if (l_db_dc.pil_level > PIL_LEVEL_NONE) then
            -- DB has PIL data

            if (l_file_dc.last_definition_date < l_db_dc.last_definition_date) then
               -- File last definition date is older, do nothing
               null;

            elsif (l_file_dc.last_definition_date = l_db_dc.last_definition_date) then
               -- File and DB last definition dates are same, upload the missing
               -- definition data. Links might be missing.
               --
               --       | DB  |
               --       | P L |
               -- ------+-----+------------------------------
               -- F   P | P L | <- 1st row : Final result
               -- i     |     | <- 2nd row : What is uploaded
               -- l   L | L L |
               -- e     | L   |
               --
               --

               if (l_file_dc.pil_level > l_db_dc.pil_level) then
                  -- Upload the link information

                  l_final_dc.last_definition_date := l_file_dc.last_definition_date;

                  g_uc.upload_prereqs_includes_links := true;

                  l_final_dc.pil_level := l_file_dc.pil_level;
               end if;

            else
               -- File definition date is newer

               l_final_dc.last_definition_date := l_file_dc.last_definition_date;

               g_uc.upload_prereqs_includes_links := true;

               l_final_dc.pil_level := l_file_dc.pil_level;
            end if; -- LDD

         else
            -- DB has no definition, insert data from file

            l_final_dc.last_definition_date := l_file_dc.last_definition_date;

            g_uc.upload_prereqs_includes_links := true;

            l_final_dc.pil_level := l_file_dc.pil_level;
         end if; -- l_db_dc.pil_level

      else
         -- File has no PIL data, do nothing
         null;

      end if; -- l_file_dc.pil_level

      -- Decide whether or not files should be uploaded
      --
      --          | DB
      --          | no_files       files exist
      -- ---------+--------------------------------
      -- F     no | do nothing     do nothing
      -- i  files |
      -- l        |
      -- e  files | delete         file.LDD <= db.LDD : do nothing
      --    exist | insert         file.LDD >  db.LDD : delete/insert
      --

      if (l_file_dc.has_files) then
         -- File has files data

         l_final_dc.has_files := true;

         if (l_db_dc.has_files) then
            -- DB has files data

            if (l_file_dc.last_definition_date <= l_db_dc.last_definition_date) then
               -- file.LDD is older than DB.LDD or they are same, do nothing

               null;

            else
               -- file.LDD is newer than DB.LDD
               -- Do not change the final.LDD. In ARU LDD reflects changes in dependency
               -- tree and file contents. New f<bug_number>.ldt file only has file
               -- contents and the LDD in this file does not reflect the correct LDD
               -- of the bugfix dependency information.

               g_uc.upload_files := true;

            end if;

         else
            -- DB has no files data

            g_uc.upload_files := true;

         end if;

      else
         -- File has no files data, do nothing

         null;

      end if;

      -- Derive Final Download Mode

      derive_download_mode(l_final_dc);

      -- Debug

      if (g_debug_flag = DEBUG_ON) then
         debug_up_fnd_ums_bugfix(p_release_name,
                                 p_bug_number,
                                 l_forced,
                                 l_file_dc,
                                 l_forced_db_dc,
                                 l_db_dc,
                                 l_final_dc);
      end if;

      --
      -- Abort the upload if there is nothing new to upload.
      -- Disabled until FNDLOAD implements the abort logic.
      --
      if (g_debug_flag = DEBUG_ABORT) then
         if (g_uc.upload_bugfix_replacement or
             g_uc.upload_prereqs_includes_links or
             g_uc.upload_files) then
            null;

         else
            if ((l_file_dc.last_update_date < l_db_dc.last_update_date) and
                (l_file_dc.last_definition_date < l_db_dc.last_definition_date)) then
               -- File is older and has no more data than DB.

               raise_application_error(ERROR_ABORT,
                                       MSG_ABORT_OLDER || p_bug_number);
            else
               -- Dates are same and file has no more data than DB.

               raise_application_error(ERROR_ABORT,
                                       MSG_ABORT_LEVEL || p_bug_number);
            end if;
         end if;
      end if;

      -- Real UPLOAD ...

      -- Delete children ...

      if (g_uc.upload_files) then
         -- delete files

         delete from fnd_ums_bugfix_file_versions
         where bugfix_guid = g_bugfix_guid;

         g_rc.bugfix_file_versions := g_rc.bugfix_file_versions + sql%rowcount;
      end if;

      if (g_uc.upload_prereqs_includes_links) then
         -- delete prereqs, includes

         delete from fnd_ums_bugfix_relationships
         where bugfix_guid = g_bugfix_guid
         and relation_type in (REL_TYPE_PREREQS,
                               REL_TYPE_INDIRECTLY_PREREQS,
                               REL_TYPE_INCLUDES,
                               REL_TYPE_INDIRECTLY_INCLUDES);

         g_rc.bugfix_relationships := g_rc.bugfix_relationships + sql%rowcount;
      end if;

      -- Insert the bugfix data if necessary

      if (g_uc.upload_bugfix_replacement) then
         -- delete replacement

         delete from fnd_ums_bugfix_relationships
         where bugfix_guid = g_bugfix_guid
         and relation_type = REL_TYPE_REPLACED_BY;

         g_rc.bugfix_relationships := g_rc.bugfix_relationships + sql%rowcount;

         -- delete bugfix

         delete /*+ INDEX(fnd_ums_bugfixes fnd_ums_bugfixes_u1) */
         from fnd_ums_bugfixes
         where bugfix_guid = g_bugfix_guid;

         g_rc.bugfixes := g_rc.bugfixes + sql%rowcount;

         -- insert bugfix

         declare
            l_application_short_name varchar2(32000);
            l_release_status         varchar2(32000);
            l_type                   varchar2(32000);
            l_abstract               varchar2(32000);
         begin
            if (l_file_dc.download_mode = DL_MODE_FILES_ONLY) then
               l_application_short_name := nvl(p_application_short_name, NOT_AVAILABLE);
               l_release_status := nvl(p_release_status, NOT_AVAILABLE);
               l_type := nvl(p_type, NOT_AVAILABLE);
               l_abstract := nvl(p_abstract, NOT_AVAILABLE);
            else
               l_application_short_name := p_application_short_name;
               l_release_status := p_release_status;
               l_type := p_type;
               l_abstract := p_abstract;
            end if;

            insert into fnd_ums_bugfixes
            (bugfix_guid,
             release_name,
             bug_number,
             download_mode,
             application_short_name,
             release_status,
             type,
             abstract,
             last_definition_date,
             last_update_date)
            values
            (g_bugfix_guid,
             p_release_name,
             p_bug_number,
             l_final_dc.download_mode,
             l_application_short_name,
             l_release_status,
             l_type,
             l_abstract,
             l_final_dc.last_definition_date,
             l_final_dc.last_update_date);

            g_rc.bugfixes := g_rc.bugfixes + sql%rowcount;
         end;
      elsif (g_uc.upload_prereqs_includes_links or g_uc.upload_files) then
         -- If PIL (affects DM and LDD) or Files (affects DM) are uploaded,
         -- but bugfix and replacement data is not uploaded
         -- then download_mode and last_definition_date should be updated.
         -- For Example: If database is RO, and ldt is LF, and dates are same
         -- then PIL and Files will be uploaded but bugfix and replacement
         -- data will not.

         update /*+ INDEX(fnd_ums_bugfixes fnd_ums_bugfixes_u1) */ fnd_ums_bugfixes
            set download_mode = l_final_dc.download_mode,
                last_definition_date = l_final_dc.last_definition_date
          where bugfix_guid = g_bugfix_guid;

          g_rc.bugfixes := g_rc.bugfixes + sql%rowcount;
      end if;

   elsif(p_upload_phase = 'END') then
      -- no work to do
      null;
   else
      raise_application_error(ERROR_UNKNOWN_UPLOAD_PHASE,
         'Unknown UPLOAD_PHASE: ' || p_upload_phase);
   end if;

   -- do not catch exceptions here.
end up_fnd_ums_bugfix;

--------------------------------------------------------------------------------
function new_file_guid_at
  (p_application_short_name in fnd_ums_files.application_short_name%type,
   p_location               in fnd_ums_files.location%type,
   p_name                   in fnd_ums_files.name%type)
return raw
is
   pragma autonomous_transaction;
   l_file_guid fnd_ums_files.file_guid%type;
begin
   -- lock the entity first

   lock_entity('FND_UMS_FILES', p_application_short_name, p_location, p_name);

   -- check the existence again

   begin
      select /*+ INDEX(fnd_ums_files fnd_ums_files_u2) */ file_guid
      into l_file_guid
      from fnd_ums_files
      where application_short_name = p_application_short_name
      and location = p_location
      and name = p_name;
   exception
      when no_data_found then
         -- populate FND_UMS_FILES

         insert into fnd_ums_files
         (file_guid,
          application_short_name,
          location,
          name)
         values
         (sys_guid(),
          p_application_short_name,
          p_location,
          p_name)
         returning file_guid
         into l_file_guid;

         g_rc.files := g_rc.files + sql%rowcount;
   end;

   commit;

   return l_file_guid;

exception
   when others then
      rollback;
      raise;
end new_file_guid_at;

--------------------------------------------------------------------------------
function get_file_guid
  (p_application_short_name in fnd_ums_files.application_short_name%type,
   p_location               in fnd_ums_files.location%type,
   p_name                   in fnd_ums_files.name%type)
return raw
is
   l_file_guid fnd_ums_files.file_guid%type;
begin
   begin
      select /*+ INDEX(fnd_ums_files fnd_ums_files_u2) */ file_guid
      into l_file_guid
      from fnd_ums_files
      where application_short_name = p_application_short_name
      and location = p_location
      and name = p_name;
   exception
      when no_data_found then
         l_file_guid := new_file_guid_at(p_application_short_name,
                                         p_location,
                                         p_name);
   end;

   return l_file_guid;
end get_file_guid;

--------------------------------------------------------------------------------
function new_file_version_guid_at
  (p_file_guid in fnd_ums_file_versions.file_guid%type,
   p_version   in fnd_ums_file_versions.version%type)
return raw
is
   pragma autonomous_transaction;
   l_file_version_guid fnd_ums_file_versions.file_version_guid%type;
begin
   -- lock the entity first

   lock_entity('FND_UMS_FILE_VERSIONS', p_file_guid, p_version);

   -- check the existence again

   begin
      select /*+ INDEX(fnd_ums_file_versions fnd_ums_file_versions_u2) */ file_version_guid
      into l_file_version_guid
      from fnd_ums_file_versions
      where file_guid = p_file_guid
      and version = p_version;
   exception
      when no_data_found then
         -- populate FND_UMS_FILE_VERSIONS

         insert into fnd_ums_file_versions
         (file_version_guid,
          file_guid,
          version)
         values
         (sys_guid(),
          p_file_guid,
          p_version)
         returning file_version_guid
         into l_file_version_guid;

         g_rc.file_versions := g_rc.file_versions + sql%rowcount;
   end;

   commit;

   return l_file_version_guid;

exception
   when others then
      rollback;
      raise;
end new_file_version_guid_at;

--------------------------------------------------------------------------------
function get_file_version_guid
  (p_file_guid in fnd_ums_file_versions.file_guid%type,
   p_version   in fnd_ums_file_versions.version%type)
return raw
is
   l_file_version_guid fnd_ums_file_versions.file_version_guid%type;
begin
   begin
      select /*+ INDEX(fnd_ums_file_versions fnd_ums_file_versions_u2) */ file_version_guid
      into l_file_version_guid
      from fnd_ums_file_versions
      where file_guid = p_file_guid
      and version = p_version;
   exception
      when no_data_found then
         l_file_version_guid := new_file_version_guid_at(p_file_guid,
                                                         p_version);
   end;

   return l_file_version_guid;
end get_file_version_guid;

--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix_file
  (p_application_short_name in varchar2,
   p_location               in varchar2,
   p_name                   in varchar2,
   p_version                in varchar2)
is
   l_file_guid         fnd_ums_file_versions.file_guid%type;
   l_file_version_guid fnd_ums_file_versions.file_version_guid%type;
begin
   if (g_uc.upload_files) then
      -- File upload is allowed.

      -- Get file_guid

      l_file_guid := get_file_guid(p_application_short_name,
                                   p_location,
                                   p_name);

      -- Get file_version_guid

      l_file_version_guid := get_file_version_guid(l_file_guid,
                                                   p_version);

      -- populate FND_UMS_BUGFIX_FILE_VERSIONS

      insert into fnd_ums_bugfix_file_versions
      (bugfix_guid,
       file_version_guid)
      values
      (g_bugfix_guid,
       l_file_version_guid);

      g_rc.bugfix_file_versions := g_rc.bugfix_file_versions + sql%rowcount;
   else
      -- File upload is not allowed.
      null;
   end if;
end up_fnd_ums_bugfix_file;

--------------------------------------------------------------------------------
function new_bugfix_guid_at
  (p_release_name in fnd_ums_bugfixes.release_name%type,
   p_bug_number   in fnd_ums_bugfixes.bug_number%type)
return raw
is
   pragma autonomous_transaction;
   l_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
begin
   -- lock the entity first

   lock_entity('FND_UMS_BUGFIXES', p_release_name, p_bug_number);

   -- check the existence again

   begin
      select /*+ INDEX(fnd_ums_bugfixes fnd_ums_bugfixes_u2) */ bugfix_guid
      into l_bugfix_guid
      from fnd_ums_bugfixes
      where release_name = p_release_name
      and bug_number = p_bug_number;
   exception
      when no_data_found then
         -- If bugfix doesn't exist then create a DL_MODE_NONE bugfix.
         -- This happens in these two cases.
         -- - p_download_mode is NONE.
         --     This happens when INCLUDES, INDIRECTLY_INCLUDES relationships
         --     are downloaded under the top level bugfix.
         -- - forward relationship references.
         --     If two entities refer to each other, the first entity will
         --     have a forward relationship reference to the second one.
         --     That second one may not exist in the DB, so a bugfix must
         --     be created to get the bugfix_guid. This bugfix is marked
         --     as DL_MODE_NONE so that its definition will be replaced
         --     with the real definition.

         -- populate FND_UMS_BUGFIXES

         insert into fnd_ums_bugfixes
         (bugfix_guid,
          release_name,
          bug_number,
          download_mode,
          application_short_name,
          release_status,
          type,
          abstract,
          last_definition_date,
          last_update_date)
         values
         (sys_guid(),
          p_release_name,
          p_bug_number,
          DL_MODE_NONE,
          NOT_AVAILABLE,
          NOT_AVAILABLE,
          NOT_AVAILABLE,
          NOT_AVAILABLE,
          g_default_date,
          g_default_date)
         returning bugfix_guid
         into l_bugfix_guid;

         g_rc.bugfixes := g_rc.bugfixes + sql%rowcount;
   end;

   commit;

   return l_bugfix_guid;

exception
   when others then
      rollback;
      raise;
end new_bugfix_guid_at;

--------------------------------------------------------------------------------
function get_bugfix_guid
  (p_release_name in fnd_ums_bugfixes.release_name%type,
   p_bug_number   in fnd_ums_bugfixes.bug_number%type)
return raw
is
   l_bugfix_guid fnd_ums_bugfixes.bugfix_guid%type;
begin
   begin
      select /*+ INDEX(fnd_ums_bugfixes fnd_ums_bugfixes_u2) */ bugfix_guid
      into l_bugfix_guid
      from fnd_ums_bugfixes
      where release_name = p_release_name
      and bug_number = p_bug_number;
   exception
      when no_data_found then
         l_bugfix_guid := new_bugfix_guid_at(p_release_name,
                                             p_bug_number);
   end;

   return l_bugfix_guid;
end get_bugfix_guid;

--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix_relationship
  (p_relation_type                in varchar2,
   p_related_bugfix_release_name  in varchar2,
   p_related_bugfix_bug_number    in varchar2,
   p_related_bugfix_download_mode in varchar2)
is
   l_related_bugfix_guid fnd_ums_bugfix_relationships.related_bugfix_guid%type;
begin
   if (((g_uc.upload_prereqs_includes_links) and
        (p_relation_type in (REL_TYPE_PREREQS,
                             REL_TYPE_INDIRECTLY_PREREQS,
                             REL_TYPE_INCLUDES,
                             REL_TYPE_INDIRECTLY_INCLUDES))) or
       ((g_uc.upload_bugfix_replacement) and
        (p_relation_type = REL_TYPE_REPLACED_BY))) then

      -- Get the related_bugfix_guid

      l_related_bugfix_guid := get_bugfix_guid(p_related_bugfix_release_name,
                                               p_related_bugfix_bug_number);

      -- insert the relationship

      insert into fnd_ums_bugfix_relationships
      (bugfix_guid,
       relation_type,
       related_bugfix_guid)
      values
      (g_bugfix_guid,
       p_relation_type,
       l_related_bugfix_guid);

      g_rc.bugfix_relationships := g_rc.bugfix_relationships + sql%rowcount;
   else
      -- Either relationship upload is not allowed or
      -- REL_TYPE_REPLACES, REL_TYPE_REP_BY_FIRST_NON_OBS and unknown
      -- relationships are discarded.
      null;
   end if;
end up_fnd_ums_bugfix_relationship;

--------------------------------------------------------------------------------
procedure up_fnd_ums_one_bugfix
  (p_upload_phase in varchar2,
   p_release_name in varchar2,
   p_bug_number   in varchar2)
is
begin
   if (p_upload_phase = 'BEGIN') then
      analyze_ums_tables();

   elsif (p_upload_phase = 'END') then
      -- no work to do
      null;
   else
      raise_application_error(ERROR_UNKNOWN_UPLOAD_PHASE,
         'Unknown UPLOAD_PHASE: ' || p_upload_phase);
   end if;
end up_fnd_ums_one_bugfix;

--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfixes
  (p_upload_phase         in varchar2,
   p_entity_download_mode in varchar2,
   p_release_name         in varchar2,
   p_bug_number           in varchar2,
   p_start_date           in varchar2,
   p_end_date             in varchar2)
is
begin
   if (p_upload_phase = 'BEGIN') then
      analyze_ums_tables();

   elsif (p_upload_phase = 'END') then
      -- no work to do
      null;
   else
      raise_application_error(ERROR_UNKNOWN_UPLOAD_PHASE,
         'Unknown UPLOAD_PHASE: ' || p_upload_phase);
   end if;
end up_fnd_ums_bugfixes;

--------------------------------------------------------------------------------
function newline
   return varchar2
is
   l_newline varchar2(100);
   l_plsql   varchar2(2000);
begin
   -- First try fnd_global.newline.
   begin
      --
      -- Use dynamic call not to have compile time dependency
      --
      l_plsql := 'begin :b_newline := fnd_global.newline(); end;';
      execute immediate l_plsql using out l_newline;
   exception
      when others then
         --
         -- Use dynamic call to go around the GSCC. chr() is not allowed.
         --
         l_plsql := 'begin ' ||
                    '   :b_newline := convert(chr(10), ' ||
                    '                         substr(userenv(''LANGUAGE''), ' ||
                    '                                instr(userenv(''LANGUAGE''), ''.'') + 1), ' ||
                    '                         ''US7ASCII''); ' ||
                    'end; ';
         execute immediate l_plsql using out l_newline;
   end;

   return l_newline;
end newline;

begin
   g_debug_flag := DEBUG_OFF;
   g_newline := fnd_ums_loader.newline();

   g_default_date := to_date('1900/01/01 00:00:00', G_STD_DATE_MASK);

   g_rc.bugfixes              := 0;
   g_rc.bugfix_relationships  := 0;
   g_rc.files                 := 0;
   g_rc.file_versions         := 0;
   g_rc.bugfix_file_versions  := 0;

end fnd_ums_loader;

/
