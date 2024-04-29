--------------------------------------------------------
--  DDL for Package Body AME_ANALYZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ANALYZER_PKG" AS
-- $Id: ame_analyzer.sql, 200.28 2023/06/23 12:44:20 siionesc Exp $

----------------------------------
-- Global Variables             --
----------------------------------
g_log_file         UTL_FILE.FILE_TYPE;
g_out_file         UTL_FILE.FILE_TYPE;
g_is_concurrent    BOOLEAN := (to_number(nvl(FND_GLOBAL.CONC_REQUEST_ID,0)) >  0);
g_debug_mode       VARCHAR2(1) := 'N';
g_max_output_rows  NUMBER := 10;
g_family_result    VARCHAR2(1);
g_errbuf           VARCHAR2(1000);
g_retcode          VARCHAR2(1);
g_section_id       VARCHAR2(300);
g_snap_days        NUMBER := 0;
g_dx_printed       dx_pr_type;
g_issues_count     NUMBER := 0;
g_guid             VARCHAR2(40);

g_query_start_time TIMESTAMP;
g_query_elapsed    INTERVAL DAY(2) TO SECOND(3);
g_analyzer_start_time TIMESTAMP;
g_analyzer_elapsed    INTERVAL DAY(2) TO SECOND(3);

g_signatures      SIGNATURE_TBL;
g_sig_stats       sig_stats_tbl; -- EBSAF-177
g_sections        REP_SECTION_TBL;
g_sql_tokens      HASH_TBL_8K;
g_masked_tokens   HASH_TBL_8K; -- EBSAF-275
g_fk_mask_options HASH_TBL_2K; -- EBSAF-275
g_rep_info        HASH_TBL_2K;
g_parameters      parameter_hash := parameter_hash();
g_exec_summary      HASH_TBL_2K;
g_sig_errors      HASH_TBL_2K;
g_item_id         INTEGER := 0;
g_sig_id        INTEGER := 0;
g_parent_sig_id   VARCHAR2(320);
analyzer_title VARCHAR2(255);
g_mos_patch_url   VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?patchId=';
g_mos_doc_url     VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER&sourceId=2332426.1';
g_mos_km_url     VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/DocumentDisplay?id=';
g_mos_sr_url     VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/SrCreate';
g_hidden_xml      XMLDOM.DOMDocument;
g_dx_summary_error VARCHAR2(4000);
g_preserve_trailing_blanks BOOLEAN := false;  -- EBSAF-255 g_preserve_trailing_blanks functionality is obsolete
g_sec_detail   section_record_tbl := section_record_tbl();
g_level            NUMBER := 1;
g_child_sig_html   CLOB;
g_result           resulttype;
g_cloud_flag       BOOLEAN := FALSE;
g_sig_count        NUMBER := 0;
g_hypercount       NUMBER := 1;
g_dest_to_source  destToSourceType;
g_source_to_dest  sourceToDestType;
g_results         results_hash;
g_fam_area_hash   family_area_tbl;
g_params_string   VARCHAR2(500) := '';

g_family_area      VARCHAR2(24) := 'EBS HCM';
g_framework_version VARCHAR(240) := '4.5.9.1';
g_rec_patch_in_dx   VARCHAR2(1) := nvl('A','A'); -- 'A' all rows, change to 'F' for failing rows in DX only
g_g2g_flag          BOOLEAN := nvl('Y','N')='Y'; -- EBSAF-272

g_banner_severity VARCHAR2(1) := 'E';
g_banner_message VARCHAR2(2000) := null;


----------------------------------------------------------------
-- Analyzer-specific code: Global Declarations                --
----------------------------------------------------------------
g_invalids                           number;
g_db_version                    V$INSTANCE.VERSION%TYPE;
 g_DBbanner                     VARCHAR2(255);

----------------------------------------------------------------
-- Debug, log and output procedures                          --
----------------------------------------------------------------

PROCEDURE enable_debug IS
BEGIN
  g_debug_mode := 'Y';
END enable_debug;

PROCEDURE disable_debug IS
BEGIN
  g_debug_mode := 'N';
END disable_debug;

PROCEDURE print_log(p_msg IN VARCHAR2) is
BEGIN
  -- print only when debug flag is 'Y'
    IF g_debug_mode = 'Y' THEN
        IF NOT g_is_concurrent THEN
          utl_file.put_line(g_log_file, p_msg);
          utl_file.fflush(g_log_file);
        ELSE
          fnd_file.put_line(FND_FILE.LOG, p_msg);
        END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN
  dbms_output.put_line(substr('Error in print_log: '||sqlerrm,1,254));
  raise;
END print_log;


PROCEDURE debug(p_msg VARCHAR2) is
 l_time varchar2(25);
BEGIN
  -- print only when debug flag is 'Y'
  IF g_debug_mode = 'Y' THEN
    l_time := to_char(sysdate,'DD-MON-YY HH24:MI:SS');

    IF NOT g_is_concurrent THEN
      utl_file.put_line(g_log_file, l_time||'-'||p_msg);
    ELSE
      fnd_file.put_line(FND_FILE.LOG, l_time||'-'||p_msg);
    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN
  print_log('Error in debug');
  raise;
END debug;


PROCEDURE print_out(
    p_msg IN VARCHAR2,
    p_newline IN VARCHAR  DEFAULT 'Y'
) IS
BEGIN
  IF NOT g_is_concurrent THEN
    IF (p_newline = 'N') THEN
       utl_file.put(g_out_file, p_msg);
    ELSE
       utl_file.put_line(g_out_file, p_msg);
    END IF;
    utl_file.fflush(g_out_file);
  ELSE
     IF (p_newline = 'N') THEN
        fnd_file.put(FND_FILE.OUTPUT, p_msg);
     ELSE
        fnd_file.put_line(FND_FILE.OUTPUT, p_msg);
     END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_out');
  raise;
END print_out;


PROCEDURE print_clob(
    p_clob IN OUT NOCOPY CLOB,
    p_newline IN VARCHAR  DEFAULT 'Y'
) IS
    l_length  NUMBER := dbms_lob.getlength(p_clob);
    l_offset NUMBER := 1;
    l_buffer VARCHAR2(16000);
    l_read   NUMBER := 4000;
BEGIN
    WHILE l_offset < l_length LOOP
        dbms_lob.read(p_clob, l_read, l_offset, l_buffer);
        print_out(l_buffer, 'N');
        l_offset := l_offset + l_read;
    END LOOP;
    IF (p_newline = 'Y') THEN
        print_out(null,'Y');
    END IF;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in print_clob');
    raise;
END print_clob;


PROCEDURE print_buffer(
    p_clob IN OUT NOCOPY CLOB,
    p_msg IN VARCHAR2,
    p_newline IN VARCHAR DEFAULT 'Y'
) IS
BEGIN
    -- Create storage if needed
    if (p_clob is null) then
        dbms_lob.createtemporary(p_clob, true, dbms_lob.session);
    end if;
    -- Append message
    if (p_newline = 'N') then
        dbms_lob.append(p_clob, p_msg);
    else
        dbms_lob.append(p_clob, p_msg || chr(10));
    end if;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in print_buffer');
    raise;
END;


PROCEDURE print_error(
    p_msg VARCHAR2,
    p_sig_id VARCHAR2 DEFAULT '',
    p_section_id VARCHAR2 DEFAULT '')
IS
BEGIN
    -- ER #124 Show in unix session the error if parameter or additional validation failed.
    dbms_output.put_line('**************************************************');
    dbms_output.put_line('**** ERROR  ERROR  ERROR  ERROR  ERROR  ERROR ****');
    dbms_output.put_line('**************************************************');
    dbms_output.put_line('**** The analyzer did not run to completion!');
    dbms_output.put_line('**** '||p_msg);
    IF p_msg LIKE 'INVALID ARGUMENT:%' THEN
        dbms_output.put_line('**** Please rerun the analyzer with proper parameter value.');
    END IF;
    print_out('<br><b>ERROR</b><br>'||p_msg||'<br>');
    print_log('ERROR: '||p_msg);
END print_error;


----------------------------------------------------------------
--- Time Management                                          ---
----------------------------------------------------------------

PROCEDURE get_current_time (p_time IN OUT TIMESTAMP) IS
BEGIN
  SELECT localtimestamp(3) INTO p_time
  FROM   dual;
END get_current_time;

FUNCTION stop_timer(p_start_time IN TIMESTAMP) RETURN INTERVAL DAY TO SECOND IS
  l_elapsed INTERVAL DAY(2) TO SECOND(3);
BEGIN
  SELECT localtimestamp - p_start_time  INTO l_elapsed
  FROM   dual;
  RETURN l_elapsed;
END stop_timer;

FUNCTION format_elapsed (p_elapsed IN INTERVAL DAY TO SECOND, p_mili IN BOOLEAN DEFAULT TRUE) RETURN VARCHAR2 IS
  l_days         VARCHAR2(3);
  l_hours        VARCHAR2(2);
  l_minutes      VARCHAR2(2);
  l_seconds      VARCHAR2(6);
  l_fmt_elapsed  VARCHAR2(80);
BEGIN
  l_days := EXTRACT(DAY FROM p_elapsed);
  IF to_number(l_days) > 0 THEN
    l_fmt_elapsed := l_days||' days';
  END IF;
  l_hours := EXTRACT(HOUR FROM p_elapsed);
  IF to_number(l_hours) > 0 THEN
    IF length(l_fmt_elapsed) > 0 THEN
      l_fmt_elapsed := l_fmt_elapsed||', ';
    END IF;
    l_fmt_elapsed := l_fmt_elapsed || l_hours||' Hrs';
  END IF;
  l_minutes := EXTRACT(MINUTE FROM p_elapsed);
  IF to_number(l_minutes) > 0 THEN
    IF length(l_fmt_elapsed) > 0 THEN
      l_fmt_elapsed := l_fmt_elapsed||', ';
    END IF;
    l_fmt_elapsed := l_fmt_elapsed || l_minutes||' Min';
  END IF;
  l_seconds := EXTRACT(SECOND FROM p_elapsed);
  IF (NOT p_mili) THEN
      l_seconds := TO_CHAR(ROUND(TO_NUMBER(l_seconds)));
  END IF;
  IF length(l_fmt_elapsed) > 0 THEN
    l_fmt_elapsed := l_fmt_elapsed||', ';
  END IF;
  l_fmt_elapsed := l_fmt_elapsed || l_seconds||' Sec';
  RETURN(l_fmt_elapsed);

EXCEPTION WHEN OTHERS THEN
  print_log('There was an exception when trying to calculate elapsed time: ' || SQLERRM);
  RETURN p_elapsed;
END format_elapsed;

--EBSAF-177
function seconds_elapsed(p_elapsed IN INTERVAL DAY TO SECOND) return number is
begin
    return round(
        EXTRACT(DAY FROM p_elapsed)*86400   -- 24*60*60
      + EXTRACT(HOUR FROM p_elapsed)*3600   -- 60*60
      + EXTRACT(MINUTE FROM p_elapsed)*60
      + EXTRACT(SECOND FROM p_elapsed)
    , 3);
end seconds_elapsed;

--EBSAF-177 Start tracking signature step time
procedure sig_time_start(p_sig_id varchar2, p_parent_sig_id varchar2, p_type varchar2) is
    l_stat_id varchar(320);
    l_rec sig_stats_rec;
begin
    l_stat_id := p_sig_id || '|' || p_parent_sig_id;

    -- Initialize record if not present
    if not g_sig_stats.exists(l_stat_id) then
        l_rec.sig_id := p_sig_id;
        l_rec.version := g_signatures(p_sig_id).version;
        l_rec.row_count := 0;
        l_rec.query_time := 0;
        l_rec.process_time := 0;
        g_sig_stats(l_stat_id) := l_rec;
    end if;

    -- Update timestamp
    if p_type = 'Q' then
        g_sig_stats(l_stat_id).query_start := localtimestamp;
    elsif p_type = 'P' then
        g_sig_stats(l_stat_id).process_start := localtimestamp;
    end if;
exception when others then
    print_log('Error in sig_time_start: '||sqlerrm);
end;

--EBSAF-177 Adds seconds since signature step last started
procedure sig_time_add(p_sig_id varchar2, p_parent_sig_id varchar2, p_type varchar2) is
    l_stat_id varchar(320);
    l_seconds number;
begin
    l_stat_id := p_sig_id || '|' || p_parent_sig_id;
    if p_type = 'Q' then
        g_sig_stats(l_stat_id).query_time := g_sig_stats(l_stat_id).query_time +
            seconds_elapsed(localtimestamp - g_sig_stats(l_stat_id).query_start);
    elsif p_type = 'P' then
        g_sig_stats(l_stat_id).process_time := g_sig_stats(l_stat_id).process_time +
            seconds_elapsed(localtimestamp - g_sig_stats(l_stat_id).process_start);
    end if;
exception when others then
    print_log('Error in sig_time_add: '||sqlerrm);
end;



----------------------------------------------------------------
--- Check last snapshot date days and populate the days flag ---
----------------------------------------------------------------

PROCEDURE set_snap_days IS

BEGIN
   select round(sysdate - (select * from (select snapshot_update_date from ad_snapshots
       where snapshot_name like '%_VIEW'
         and appl_top_id in (select appl_top_id from ad_appl_tops where name in ('GLOBAL'))
         and SNAPSHOT_TYPE in ('C','G')
         order by snapshot_update_date desc)
         where rownum = 1),0)+1 into g_snap_days
         from dual;
    print_log ('Snapshot days:' || to_char(g_snap_days));

EXCEPTION WHEN OTHERS THEN
      print_log('Snapshot query errored out');
END set_snap_days;

----------------------------------------------------------------
--- Set Cloud flag                                           ---
----------------------------------------------------------------

PROCEDURE set_cloud_flag IS
    l_response VARCHAR2(2000);
    l_response_compute VARCHAR2(32000);
    l_response_baremetal VARCHAR2(32000);
BEGIN
    BEGIN
        SELECT '1'
           INTO l_response
           FROM dual
           WHERE EXISTS (
             SELECT 1
             FROM (SELECT db_domain AS domain FROM fnd_databases
                          UNION ALL
                          SELECT domain AS domain FROM fnd_nodes) domains
             WHERE UPPER(domains.domain) LIKE '%ORACLECLOUD.%' OR UPPER(domains.domain) LIKE '%ORACLECVCN.%');

        -- If a row is selected we are on the cloud
        IF SQL%ROWCOUNT > 0 THEN
            g_cloud_flag := TRUE;
            RETURN;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            g_cloud_flag := FALSE;
        WHEN OTHERS THEN
            g_cloud_flag := FALSE;
            print_log('Error in set_cloud_flag: '||sqlerrm);
    END;

    BEGIN
       -- set transfertimeout to 15 seconds, we don't want the analyzer waiting more than that
       UTL_HTTP.set_transfer_timeout(15);

       SELECT UTL_HTTP.request('http://192.0.0.192/2007-08-29/meta-data/local-hostname')
       INTO l_response_compute
       FROM dual;

       SELECT UTL_HTTP.request('http://169.254.169.254/opc/v1/instance/')
       INTO l_response_baremetal
       FROM dual;

       -- Check if the response is indeed from an Oracle cloud service
       IF (lower(nvl(l_response_compute,'AAA')) LIKE '%oraclecloud.%' or lower(nvl(l_response_baremetal,'AAA')) LIKE '%oraclevcn.%') THEN
           g_cloud_flag := TRUE;
           RETURN;
       END IF;
    EXCEPTION
        WHEN OTHERS THEN
           -- we are NOT on the cloud
           g_cloud_flag := FALSE;
           RETURN;
    END;

END set_cloud_flag;

PROCEDURE initialize_globals IS
BEGIN
  -- clear tables
  g_sec_detail.delete;
  g_signatures.delete;
  g_sections.delete;
  g_sig_stats.delete;
  g_sql_tokens.delete;
  g_masked_tokens.delete;
  g_fk_mask_options.delete;
  g_rep_info.delete;
  g_parameters.delete;
  g_exec_summary.delete;
  g_sig_errors.delete;
  g_dest_to_source.delete;
  g_source_to_dest.delete;
  g_results.delete;
  g_fam_area_hash.delete;

  -- re-initialize values
  g_sig_id := 0;
  g_item_id := 0;
  g_sig_count := 0 ;

  -- initialize the global results hash
  g_results('S') := 0;
  g_results('W') := 0;
  g_results('E') := 0;
  g_results('I') := 0;
  g_results('P') := 0;    -- for checks that passed, but will not be printed in the report

  -- initialize global hash for converting the family area codes that come from the builder to the anchor format used in Note 1545562.1
  g_fam_area_hash('ATG') := 'EBS';
  g_fam_area_hash('EBS CRM') := 'CRM';
  g_fam_area_hash('Financials') := 'Fin';
  g_fam_area_hash('HCM') := 'HCM';
  g_fam_area_hash('MFG') := 'Man';
  g_fam_area_hash('MFG ON PREM') := 'Man';
  g_fam_area_hash('EBS Defect') := '';

  -- reset banner settings
  g_banner_severity := 'E';
  g_banner_message := null;

  IF g_is_concurrent THEN
     g_rep_info('Calling From'):='Concurrent Program';
     -- Record calling module (EBSAF-265)
     select nvl(max(CONCURRENT_PROGRAM_NAME), 'Unknown')
     into g_rep_info('Calling Module')
     from FND_CONCURRENT_PROGRAMS
     where APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID
     and CONCURRENT_PROGRAM_ID = FND_GLOBAL.CONC_PROGRAM_ID;
  ELSE
     g_rep_info('Calling From'):='SQL Script';
     -- Record calling module (EBSAF-265)
     g_rep_info('Calling Module'):=nvl( sys_context('userenv', 'module'), 'Unknown');
  END IF;

  -- Assign a GUID to this execution
  g_guid := upper(regexp_replace(sys_guid(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5'));

END initialize_globals;

----------------------------------------------------------------
--- File Management                                          ---
----------------------------------------------------------------

PROCEDURE initialize_files is
  l_date_char        VARCHAR2(20);
  l_log_file         VARCHAR2(400);
  l_out_file         VARCHAR2(400);
  l_file_location    V$PARAMETER.VALUE%TYPE;
  l_db_name          VARCHAR2(255);
  l_host             VARCHAR2(255);
  NO_UTL_DIR         EXCEPTION;
  l_step             VARCHAR2(2);
  l_dirs             varchar_tbl;
  l_invalid_paths    number;
BEGIN
  get_current_time(g_analyzer_start_time);
  l_step := '1';

  IF NOT g_is_concurrent THEN
  l_step := '2';

    SELECT to_char(sysdate,'YYYY-MM-DD_hh24_mi') INTO l_date_char from dual;

    SELECT sys_context('USERENV','DB_NAME'), nvl(host_name,sys_context('USERENV','SERVER_HOST'))
    INTO l_db_name, l_host
    FROM v$instance;

    g_params_string := substr(regexp_replace(convert(g_params_string,'US7ASCII'), '\W+', '-'), 1, 64);  -- Filter illegal filename changes
    l_step := '3';

    l_log_file := 'AME_Analyzer_'||l_db_name||'_'||g_params_string||l_date_char||'.log';
    l_out_file := 'AME_Analyzer_'||l_db_name||'_'||g_params_string||l_date_char||'.html';
    l_step := '4';

    -- Get first valid UTL_FILE_DIR entry
    begin
        -- Try to get path using new 19c method
        execute immediate 'select value from apps.v$parameter2 where name = ''utl_file_dir'' order by ordinal asc'
            bulk collect into l_dirs;
    exception when others then
        -- Get path using old method
        execute immediate 'select value from v$parameter2 where name = ''utl_file_dir'' order by ordinal asc'
            bulk collect into l_dirs;
    end;
    l_file_location := null;
    l_invalid_paths := 0;
    for i in 1..l_dirs.count loop
        if (l_file_location is null) then
            begin
                l_file_location := l_dirs(i);
                -- Set maximum line size to 10000 for encoding of base64 icon
                g_out_file := utl_file.fopen(l_file_location, l_out_file, 'w',32000);
                IF g_debug_mode = 'Y' THEN
                    g_log_file := utl_file.fopen(l_file_location, l_log_file, 'w',10000);
                END IF;
            exception when others then
                l_file_location := null;
                l_invalid_paths := l_invalid_paths + 1;
                -- Unable to create either out or log files at specified directory
                if (utl_file.is_open(g_out_file) ) then
                    utl_file.fclose(g_out_file);
                end if;
                if (utl_file.is_open(g_log_file) ) then
                    utl_file.fclose(g_log_file);
                end if;
            end;
        end if;
    end loop;
    l_step := '5';

    -- Verify a valid file location was found
    if l_invalid_paths > 0 then
        -- Log invalid paths for reference
        dbms_output.put_line('Warning: Unable to create files in the following UTL_FILE_DIR locations: ');
        for i in 1..l_invalid_paths loop
            dbms_output.put_line('- ' || l_dirs(i) );
        end loop;
        dbms_output.new_line;
    end if;
    IF l_file_location IS NULL THEN
        RAISE NO_UTL_DIR;
    END IF;
    l_step := '6';

    dbms_output.put_line('Files are located on Host : '||l_host);
    --dbms_output.put_line('Files are located on the database host.'); -- EBSAF-274; reverted by EBSAF-293
    dbms_output.put_line('Output file : '||l_file_location||'/'||l_out_file);
    l_step := '7';
    IF g_debug_mode = 'Y' THEN
       dbms_output.put_line('Log file : '||l_file_location||'/'||l_log_file);
    END IF;
  END IF;
EXCEPTION
  WHEN NO_UTL_DIR THEN
    dbms_output.put_line('Error in initialize_files at step '||l_step||
        ': Unable to identify a valid output directory for UTL_FILE' );
    raise;
  WHEN OTHERS THEN
    dbms_output.put_line('Error in initialize_files at step '||l_step||': '||sqlerrm);
    raise;
END initialize_files;


PROCEDURE close_files IS
BEGIN
  debug('Entered close_files');
  print_out('</BODY></HTML>');
  IF NOT g_is_concurrent THEN
    debug('Closing files');
    IF g_debug_mode = 'Y' THEN
       utl_file.fclose(g_log_file);
    END IF;
    utl_file.fclose(g_out_file);
  END IF;
END close_files;


----------------------------------------------------------------
-- REPORTING PROCEDURES                                       --
----------------------------------------------------------------

----------------------------------------------------------------
-- UTILITIES                                                  --
----------------------------------------------------------------

----------------------------------------------------------------
-- Replace invalid chars in the sig name (so we can use the   --
-- the sig name as CSS class                                  --
----------------------------------------------------------------
FUNCTION replace_chars(p_name VARCHAR2) RETURN VARCHAR2 IS
    l_name         VARCHAR2(512);
BEGIN
    l_name := p_name;
    l_name := REPLACE(l_name, '%', '_PERCENT_');
    l_name := REPLACE(l_name, '*', '_STAR_');  --EBSAF-279
    l_name := REPLACE(l_name, ':', '_COLON_');
    l_name := REPLACE(l_name, '/', '_SLASH_');
    l_name := REPLACE(l_name, '&', '_AMP_');
    l_name := REPLACE(l_name, '<', '_LT_');
    l_name := REPLACE(l_name, '>', '_GT_');
    l_name := REPLACE(l_name, '(', '__');
    l_name := REPLACE(l_name, ')', '__');
    l_name := REPLACE(l_name, ',', '----');
    -- Only replace underscores if needed (EBSAF-279)
    if instr(l_name, ' ') > 0 then
        -- replace existing _ with double _ and spaces with _ (to avoid multi-word section and signature names)
        l_name := REPLACE(l_name, '_', '__');
        l_name := REPLACE(l_name, ' ', '_');
    end if;
    -- Only replace dashes if needed (EBSAF-279)
    if instr(l_name, '.') > 0 then
        -- replace existing - with double - and . with - (as Firefox does not accept . in the css class name)
        l_name := REPLACE(l_name, '-', '--');
        l_name := REPLACE(l_name, '.', '-');
    end if;
    RETURN l_name;

EXCEPTION WHEN OTHERS THEN
    print_log('Error in replace_chars: '||sqlerrm||'.  Text unmodified.');
    return p_name;
END replace_chars;

----------------------------------------------------------------
-- Escape HTML characters (& < >)                             --
----------------------------------------------------------------
FUNCTION escape_html(p_text VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    RETURN REPLACE(REPLACE(REPLACE(p_text,
        '&','&amp;'),
        '>','&gt;'),
        '<','&lt;');
EXCEPTION
    WHEN OTHERS THEN
        print_log('Error in escape_html: '||sqlerrm||'.  Text unmodified.');
        RETURN p_text;
END escape_html;

----------------------------------------------------------------
-- Prints the Cloud image in the page header and              --
-- also in the Execution Details pop-up page,                 --
-- if the domain like "%oraclecloud.internal%"                --
----------------------------------------------------------------
PROCEDURE print_cloud_image IS
BEGIN
  IF (g_cloud_flag = TRUE) THEN
       print_out ('<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAepJREFUeNq01U9IVFEUx/FxHEFNNAPdCEGMKLQJpVwIokYzJYpiCNGqchEIQiBUIu0E/4DgQlwVBq2Cgv4oBQOC/6hAWrQIXAilhC5caCL+qcX4PfJb2HDHec9mLnx478277553z5x7XzAejwcyKRjIcMuKRCLJ7p3FA3SgHL/xDeN47zVAdjgcdv1+EQtoQylCKIB1vo0LOMAfBU7aXCkqwkecxxc0Ig9leIhd3MEHrGAGl/wE6NHgn1GvAfaxhhG0YhoxbKuP9b3qJUA+bum8TylIbDb4NVzXrJ5phq8wpoDOAPfwE5W6/uThP9zBfQU9h27N+C0KjwcYxgRKsIj+JG/vanHcRbOe21JxvLEisjJt4WRSA9qf9/I/S98qbF7p67QZPNKN3jQMbu0HHuv8KEC1Lp6ncQFP6VhlAbJ14cr5rHJ8khnHc3s65gS1/K3dcHTM9/C2rj6XdVy2AC90MYjihI5XbL9KoSZxf8MTnb+zAE9VmhXaGlq0cPymKEt72Gs0YQOjFuCv6vargljJLvlI0RkdB/AdN7GJdgsS0s111KLLSgu5x1IU8LHgfukFh7Ca6ntgbQ51KQa2NDb42U3/+V54ePOcE79o9t10tWg06mtlxWKxU81g7pQLzXOAUMZSlK52KMAAKSLBDAvj51YAAAAASUVORK5CYII=" class="smallimg" title="This is a Cloud instance">');
  END IF;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in print_cloud_image: '||sqlerrm);
END print_cloud_image;


----------------------------------------------------------------
-- Prints HTML page header and auxiliary Javascript functions --
----------------------------------------------------------------
PROCEDURE print_page_header is
    l_html_clob clob;
BEGIN
    dbms_lob.createtemporary(l_html_clob, true);

    ------------------------------------------------------------
    -- Main header
    ------------------------------
    print_out('<HTML>');
    print_out('<HEAD>');
    print_out('  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">');
    print_out('  <meta http-equiv="X-UA-Compatible" content="IE=edge" />');
    print_out('<TITLE>AME Analyzer Report</TITLE>');

    ------------------------------------------------------------
    -- Styles (EBSAF-262)
    ------------------------------
    -- Start with empty CLOB to ensure string literals are concatenated as such
    dbms_lob.trim(l_html_clob, 0);
    l_html_clob := l_html_clob ||
'/* TableSorter Default Theme */

.tablesorter-default .header,
.tablesorter-default .tablesorter-header {
    background-image: url(data:image/gif;base64,R0lGODlhFQAJAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAkAAAIXjI+AywnaYnhUMoqt3gZXPmVg94yJVQAAOw==);
    background-position: center right;
    background-repeat: no-repeat;
    cursor: pointer;
    white-space: normal;
    padding: 4px 20px 4px 4px;
}

.tablesorter-default thead .headerSortUp,
.tablesorter-default thead .tablesorter-headerSortUp,
.tablesorter-default thead .tablesorter-headerAsc {
    background-image: url(data:image/gif;base64,R0lGODlhFQAEAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAQAAAINjI8Bya2wnINUMopZAQA7);
    border-bottom: #CC6666 1px solid;
}

.tablesorter-default thead .headerSortDown,
.tablesorter-default thead .tablesorter-headerSortDown,
.tablesorter-default thead .tablesorter-headerDesc {
    background-image: url(data:image/gif;base64,R0lGODlhFQAEAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAQAAAINjB+gC+jP2ptn0WskLQA7);
    border-bottom: #CC6666 1px solid;
}

.tablesorter-default thead .sorter-false {
    background-image: none;
    cursor: default;
    padding: 4px;
}

/* Analyzer CSS, 2.4.1 2022/12/01 00:00:00 dnhoward */

* {
  font-family: "Segoe UI";
  color: #505050;
  font-size: inherit;
}

a {
    color: #3973ac;
    border: none;
    text-decoration: none;
}

img {
    border: none;
}

pre {
    margin: 0px;
}

a.hypersource {
  color: blue;
  text-decoration: underline;
}

a.nolink {
  color: #505050;
  text-decoration: none;
}

a.tagcount {
  color: blue;
  text-decoration: underline;
}

a.tagcount:hover {
    cursor: pointer;
}

a.hypersource {
  color: blue;
  text-decoration: underline;
}

a.nolink {
  color: #505050;
  text-decoration: none;
}

.successcount {
   color: #76b418;
   font-size: 20px;
   font-weight: bold;
}

.warncount {
   color: #fcce4b;
   font-size: 20px;
   font-weight: bold;
}

.errcount {
   color: #e5001e;
   font-size: 20px;
   font-weight: bold;
}

.infocount {
   color: #000000;
   font-size: 20px;
   font-weight: bold;
}

input[type=checkbox] {
  cursor: pointer;
  border: 0px;
  display:none;
}

.exportcheck {
    margin-bottom: 0px;
    padding-bottom: 0px;
}

.export2Txt {
    padding-left: 2px;
}

.pageheader {
    position: fixed;
    top: 0px;
    width: 100%;
    height: 75px;
    background-color: #F5F5F5;
    color: #505050;
    margin: 0px;
    border: 0px;
    padding: 0px;
    box-shadow: 10px 0px 5px #888888;
    z-index: 1;
}

.header_s1 {
    margin-top: 6px;
}

.header_img {
    float: left;
    margin-top: 8px;
    margin-right: 8px;
}

.header_title {
    display: inline;
    font-weight: 600;
    font-size: 20px;
}

.header_subtitle {
    font-weight: 300;
    font-size: 13px;
}

.menubox_subtitle {
    font-weight: 300;
    font-size: 13px;
}

.header_version {
    height: 16px;
    opacity: 0.85;
}

.floatingHeader {
  position: fixed;
  top: -76px;
  display: none;
}
.floatingHeader[docked] {
  position: static;
  display: table-header-group;
}
.pheader {
  position: static;
}
.pheader[undocked] {
  position: fixed;
  top: 76px;
}

td.hlt {
  padding: inherit;
  font-family: inherit;
  font-size: inherit;
  font-weight: bold;
  color: #333333;
  background-color: #FFE864;
  text-indent: 0px;
}
tr.hlt {
    background-color: #FFFBE5;
}

.blacklink:link, .blacklink:visited, .blacklink:link:active, .blacklink:visited:active {
   color: #505050;

}

.blacklink:hover{
   color: #808080;
}

.error_small, .success_small, .warning_small {
   vertical-align:middle;
   display: inline-block;
   width: 24px;
   height: 24px;
}

.h1 {
    font-size: 20px;
    font-weight: bold;
}

.background {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAAIElEQVQIW2P49evX27dvf4EBhMGAzIEwGNCUQFWRpREAFU9npcsNrzoAAAAASUVORK5CYII=");
}

.body {
    top: 30px;
    width: 100%;
    padding: 0px;
    font-size: 14px;
}

.footerarea {
    height: 35px;
    bottom: 0px;
    position: fixed;
    width: 100%;
    background-color: #F5F5F5;
    border-top: 1px solid #D9DFE3;
    z-index:100;
}

.footer {
    visibility: visible;
    max-height: 29px;
    min-height: 29px;
    background-color: #F5F5F5;
    color: #145c9e;
    font-weight: normal;
    font-size: 14px;
}

.separator {
    border-left: 1px solid #D6DFE6;
    margin-left: 10px;
    margin-right: 10px;
    height: 22px;
    width: 0px;
    vertical-align: middle;
    display: inline-block;
}

body {
    color: #505050;
    margin: 0px;
    padding: 0px;
    background-color: #F5F5F5;
    overflow-y: auto;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAAIElEQVQIW2P49evX27dvf4EBhMGAzIEwGNCUQFWRpREAFU9npcsNrzoAAAAASUVORK5CYII=");
}

.header, .footer { padding: 0px 1em;}

.icon {
    border: none;
    vertical-align:middle;
    width: 32px;
    height: 32px;
    display: inline-block;
}

.table1 {
    vertical-align: middle;
    text-align: left;
    padding: 3px;
    margin: 1px;
    min-width: 1200px;
    font-size: small;
    border-spacing: 1px;
    border-collapse: collapse;
}

.table2 {
    vertical-align: middle;
    text-align: left;
    padding: 3px;
    margin: 1px;
    width: 100%;
    border-spacing: 1px;
}

th.sigdetails {
    background-color: #f2f4f7;
}

th.sigdetails.masked {
    background-color: #d2d4d7;
}

tr.tdata td{
    border: 1px solid #f2f4f7;
    white-space: pre;
}

tr.tdata td.masked{
    background-color: #eeeeee;
}
span.masked{
    background-color: #eeeeee;
}

.topmenu {
    position: absolute;
    right: 50px;
    float: right;
    bottom: 10px;
    font-size: 12px;
    color: #505050;
    font-weight: bold;
    text-shadow: none;
    background-color: #f7f8f9;
    background-image: none;
}

.fullsection {
    padding-right: 5px;
}

.menubutton {
    border: 1px solid;
    cursor: pointer;
    display: inline;
    float: left;
    background-color: #fafafa;
    background-image: none;
    padding: 4px 15px 1px 10px;
    height: 28px;
    border-color: #d9dfe3;
    filter: none;
    border-left-color: rgba(217, 223, 227, 0.7);
    border-right-color: rgba(217, 223, 227, 0.7);
    text-shadow: none;
    vertical-align: middle;
    font-weight: 600;
    font-size: 14px;
}

.menubutton:hover {
    background-color: #EEEEEE;
}

.whatsnew_ico:hover {
    cursor: pointer;
}

.smallimg {
    padding: 0px 2px 1px 0px;
    vertical-align: middle;
    height: 18px;
    width: 18px;
    opacity: 0.75;
}

.menubox {
    border: 1px solid lightblue;
    background-color: #FFFFFF;
    display: inline;
    width: 300px;
    height: 390px;
    float: left;
    padding: 10px;
    border-radius:2px;
    border: 1px solid #E7E7E9;
}

.menuboxitem {
    white-space: nowrap;
    font-size: 16px;
    cursor: pointer;
    padding: 10px 0px 10px 0px;
}

.menuboxitem:hover {
    background-color: #EEEEEE;
}

.menuboxitemt {
    white-space: nowrap;
    font-size: 18px;
    padding: 10px 0px 10px 0px;
}

.mboxelem {
    margin-left:8px;
    text-align:left;
    display:inline-block;
}

.mboxinner {
    margin-left: 15px;
    margin-top: 6px;
}

.mainmenu {
    overflow-y: auto;
    padding: 50px 100px 50px 100px;

}

.maindata {
    display: none;
    width: auto;
    overflow: visible;
    min-height: 600px;
    height: 100%;
}

.leftcell {
   width:200px;
   vertical-align:top;
   padding: 0px;
}

.rightcell {
   vertical-align:top;
   padding: 0px;
}

.floating-box {
    display: inline-block;
    width: 277px;
    height: 120px;
    margin: 5px;
    padding: 10px;
    border: 1px solid #E7E7E9;;
    background-color: #FFFFFF;
    text-align: center;
    border-radius:2px;
    font-size: 16px;
}

.floating-box:hover {
    background-color: #bfdde5;
    font-weight: 600;
}

.textbox {
    text-align: center;
    height: 60px;
    width: 100%;
}

.counternumber {
    padding: 5px;
    vertical-align: top;
    height: 100%;
    display: inline;
    vertical-align:middle;
}

.counterbox {
    padding-top: 10px;
    height: 30px;
    font-size:20px;
    font-weight:bold;
    width: 100%;
    border: none;
}

.backtop {
    position:fixed;
    width: 90px;
    height: 25px;
    bottom: 35px;
    right: 20px;
    background-color: white;
    padding-left:15px;
    border-radius:10px;
    font-size:14px;
    color:#3973ac;
    vertical-align:middle;
}

.backtop:hover {
    background-color: #bfdde5;
}

.popup {
    width:100%;
    height:100%;
    display:none;
    position:fixed;
    top:0px;
    left:0px;
    background:rgba(0,0,0,0.75);
    border: solid 1px #8794A3;
    border-color: #c4ced7;
    color: #333333;
}

.popup-inner {
    max-width:700px;
    width:90%;
    overflow-y:auto;
    max-height: 90%;
    padding: 0px;
    position:absolute;
    top:50%;
    left:50%;
    -webkit-transform:translate(-50%, -50%);
    transform:translate(-50%, -50%);
    box-shadow:0px 2px 6px rgba(0,0,0,1);
    border-radius:3px;
    background:#fff;
    font-size: 14px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAAIElEQVQIW2P49evX27dvf4EBhMGAzIEwGNCUQFWRpREAFU9npcsNrzoAAAAASUVORK5CYII=");
}

.popup-title {
    display: table-cell;
    vertical-align: top;
    top: 10px;
    padding: 10px;
    border-bottom: 1px solid lightblue;
    background-color: #F5F5F5;
}

.close-button {
    display: inline-block;
    padding: 4px 7px 1px 7px;
    margin-right:20px;
    margin-bottom:20px;
    float:right;
    vertical-align: bottom;
    min-height: 18px;
    border: 1px solid #c4ced7;
    border-radius: 2px;
    background-color: #E4E8EA;
    font-size: 12px;
    color: #000000;
    text-shadow: 0px 1px 0px #FFFFFF;
    font-weight: bold;
}

.close-button:hover {
    background-color: #FFFFFF;
}

.popup-paramname {
    display: table-cell;
    width: 50%;
    text-align: left;
    vertical-align: top;
    padding: 10px 5px 5px 10px;
}

.popup-paramval {
    display: table-cell;
    width: 50%;
    text-align: left;
    vertical-align: top;
    padding: 10px 10px 5px 5px;
}

.close-link {
    padding: 0px 12px 10px 10px;
    text-align: right;
    float: right;
    color: blue;
}

.popup-value {
    display: table-cell;
    vertical-align: top;
    top: 10px;
    border-bottom: 1px solid lightblue;
    background-color: #F5F5F5;
}

.sectionmenu {
    border-top: 1px solid #E7E7E9;
    border-radius: 5px 0px 0px 5px;
    margin: 0px 0px 2px 7px;
    left:0px;
    width:200px;
    z-index: 3;
}

.sectionbutton, .subsectionbutton {
    cursor: pointer;
    background-color: #e7ecf0;
    border-left: 1px solid #D6DFE6;
    border-bottom: 1px solid #D6DFE6;
    border-right: 2px solid white;
    font-weight: normal;
    font-size: 14px;
    border-top: 0px;
    border-right: 0px;
    border-radius: 5px 0px 0px 5px;
    padding: 5px;
    display: none;
    margin-right: 0px;
    word-wrap: break-word;
}

.sct-submenu {
    padding-left: 5px;
}

.sct-submenu[sct-root="true"] {
    padding-left: 0px;
}

.sigcontainer {
    font-weight: normal;
    font-size: 12px;
    background-color: #FFFFFF;
    border: 1px solid #D6DFE6;
    border-radius: 3px;
    padding: 5px;
    margin: 5px 5px 5px 5px;
    width: auto;
    display: block;
    z-index:2;
}

.tagarea {
    font-weight: normal;
    font-size: 12px;
    background-color: #FFFFFF;
    border: 1px solid #D6DFE6;
    border-radius: 3px;
    padding: 5px;
    margin: 5px 5px 5px 5px;
    width: 400px;
    display: none;
}

.containertitle {
   font-weight: bold;
   font-size: 25px;
   text-align: center;
   padding-bottom: 10px;
   padding-top: 5px;
}

.searchbox {
   width:100%;
   font-size: 14px;
   display:block;
   padding-left: 5px;
}

.search{
   display:block;
   font-weight: normal;
   font-size: 12px;
   color: #333333;
   border-radius: 2px;
   background-color: #FCFDFE;
   border: 1px solid #DFE4E7;
   padding: 6px 5px 5px 5px;
   height: 28px;
   margin-top: 5px;
}

thead tr .search_match {
    border: 2px dotted #76b418;
}
tr.tdata .search_match {
    border: 2px dotted #76b418;
}

.expcoll {
   display:block;
   padding-left: 0px;
   padding-top:5px;
   padding-bottom:5px;
   margin-left:10px;
   float:left;
   font-size: 12px;
}

.sigtitle {
    font-size: small;

}

.sigdetails {
    font-size: 12px;
    margin-bottom: 2px;
    padding: 2px;
}

.signature {
    border: 1px solid #EAEAEA;
    padding: 6px;
    font-size: 12px;
    font-weight: normal;
}

.divtable {
    overflow-x: hidden;
    width: 100%;
    z-index:3;
    margin: 3px;
    margin-right: 10px;
}

.results {
    z-index:4;
    margin: 5px;
}

.divItemTitle{
    text-align: left;
    font-size: 18px;
    font-weight: 600;

    color: #336699;
    border-bottom-style: dotted;
    border-bottom-width: 1px;
    border-bottom-color: #336699;
    margin-bottom: 9px;
    padding-bottom: 2px;
    margin-left: 3px;
    margin-right: 3px;
}

.divItemTitlet{
    font-size: 16px;
    font-weight: 600;
    color: #336699;
    border-bottom-style: none;
}

.arrowright, .arrowdown {
    display: inline-block;
    cursor: context-menu;
    font-size: 12px;
    color: #336699;
    padding: 2px 0px 10px 2px;
    vertical-align: middle;
    height: 18px;
    width: 18px;
}

.divwarn {
  color: #333333;
  background-color: #FFEF95;
  border: 0px solid #FDC400;
  padding: 9px;
  margin: 0px;
  font-size: small;
  min-width:1200px;
}

.divwarn1 {
  font-size: small;
  font-weight: bold;
  color: #9B7500;
  margin-bottom: 9px;
  padding-bottom: 2px;
  margin-left: 3px;
  margin-right: 3px;
}

.solution {
  font-weight: normal;
  color: #0572ce;
 font-size: small;
  font-weight: bold
}

.detailsmall {
  text-decoration:none;
  font-size: xx-small;
  cursor: pointer;
  display: inline;
}

.divuar {
  border: 1px none #00CC99;
  font-size: small;
  font-weight: normal;
  background-color: #ffd6cc;
  color: #333333;
  padding: 9px;
  margin: 3px;
  min-width:1200px;
}

.divuar1 {
  font-size: small;
  font-weight: bold;
  color: #CC0000;
  margin-bottom: 9px;
  padding-bottom: 2px;
  margin-left: 3px;
  margin-right: 3px;
}

.divok {
  border: 1px none #00CC99;
  font-size: small;
  font-weight: normal;
  background-color: #d9f2d9;
  color: #333333;
  padding: 9px;
  margin: 3px;
  min-width:1200px;
}

.divok1 {
  font-size: small;
  font-weight: bold;
  color: #006600;
  margin-bottom: 9px;
  padding-bottom: 2px;
  margin-left: 3px;
  margin-right: 3px;
}

.divinfo {
  border: 1px none #BCC3C1;
  font-size: small;
  font-weight: normal;
  background-color: #eff3f5;
  color: #333333;
  padding: 9px;
  margin: 3px;
  min-width:1200px;
}

.divinfo1 {
  font-size: small;
  font-weight: bold;
  color: #000000;
  margin-bottom: 9px;
  padding-bottom: 2px;
  margin-left: 3px;
  margin-right: 3px;
}

.anchor{
  padding-top: 100px;
  color: #505050;
}

.tabledata tr[visible="false"],
.no-result{
  display:none;
}

.exportAll {
  display:inline;
}

.exportAllImg {
  display:inline;
}

.tabledata tr[visible="true"]{
  display:table-row;
}

.counter{
  padding:8px;
  color:#ccc;
}

.brokenlink {
    display: inline-block;
    height: 15px;
    width: 10px;
    background-image: url("data:image/false;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAPCAYAAADd/14OAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAABLSURBVChTY/wPBAxEACYoTRCgKrw3h+GTrCrDO+85DH+hQjBApol4AHaFGkoMzFAmDNDaaiUlnDqJNpHMmNlTzvCO0gCndqJgYAAAyhkXWDyo/t0AAAAASUVORK5CYII=");
}

/* Masking buttons */
.mask_enabled {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAATJJREFUeNpi/P//P4OamhoDMohNK4gCUllAbAAVugDE0xbPmrAMWd2tW7cYmBjQAFDzLAFBwaUioqLWzMzM3CAMYoPEgHJz0NUzoWmOFBAQTP3w/v2fN69fF/39+1cYiAWB7EKg2F+gXDJIDbIeFjQDs9jY2UF0M9C5/UjiE4AaBdk52OugXluO1QVAYPj+3VsQPY8BE8x89xYsZ4gsyAgKxMNTY8CcA9+t/oNoB85jjFgMwJC3zV4C8QIXJ8fHb99/8AElYGr/YzMAWR6o5xOQ5gcbANJsZqjBQAo4df4GH7YwQAf/cbkGVyAiA1CIKQKxEhC/w6WIBY8Br4H4ERJbiFQDQIECSzTq5LgABE4SCkx8YfAMiAWg+Bk5LpAC4jOEXABLSJ9g8UosgCYkBoAAAwAan2XYz/UdXgAAAABJRU5ErkJggg==");
}
.mask_disabled {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAANtJREFUeNpi/P//P0NH70QGNBAFxFlAbADlXwDiaUC8DFlRRXE+AwsDJpgFxKloYtZQ7ATEKcgSTGgKI6Ga/wBxERALA7EgEBcC8V8gToaqwWlAFpRuBuJ+IH4HxB+AeAIQt6KpwWqAIZSeh8VrM9HUYDWAG0o/wWLAMzQ1KAYcBuL/SOL/cWBk+cPIBtgwkA5ssHkBHaDbjAHwGfAWiBWBWAkaG1gBCx4DXgPxIyS2EKkGaCAlGnVyXAACJwmFJL4wAMW7ABQ/I8cFUkB8hlgXHCEjHRwFEQABBgBFOS62FueYEgAAAABJRU5ErkJggg==");
}
/*
Default: 242, 244, 247 = #f2f4f7
Hover:   240, 233, 205 = #f0e9cd
Masked:  237, 222, 164 = #eddea4
*/
.mask_target:hover {
    cursor: pointer;
    background-color: #f0e9cd;
}
.mask_header[mask="on"] {
    cursor: default;
    background-color: #eddea4;
}

/* Hidden data */
div[temp-filter-search], div[temp-filter-hidden] {
    display: none;
}

.hidden_data {
    display: none;
}
.hidden_data[hide-type="err"] {
    color: #e5001e;
}
.hidden_data[hide-type="wrn"] {
    background-color: #fcce4b;
    white-space: pre;
}

tr.tdata td.hidden_data_parent_err {
    border: 2px solid #e5001e;
}

tr.tdata td.hidden_data_parent_wrn {
    border: 2px dashed #fcce4b;
}

.hidden_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH4wUJEw4dCglfCAAAAnFJREFUOMuNk0tIVHEUxn/nP46oTVhkFFFBL40WQkRQREEbQYiINhFY0MOKIp2xGfUqyVQ2V51rc61QqYUhiNIiilrUokVBm6AsiEqStBa5M7ScbBzvaeFUCEZ+m3MOnPPxnRfMgVhLgvki609R3F0oQvf0lHesrjo0Ol8C89eVPGCbz28eOo0x+VdBNNo1K56VGIsndonIE4GbCrlAUSZnBOVRemhT5/n2kunqq3doqdg/o+B3v80tbXl1kdBTgQsK5UAZsBVYBaxDsH1r36abHPfy4snhRQB2a2JGwaVYa74/29evqvesSChkO+47YGNG5F4rXHnfjrvLMLITpRf0K8bbZVVVvRc73rYA0bfAtKA7snzZP6d0Kh+PjxmCBORGkORSQY+mJgJX/HkT/cBKRIoMorYiS/zG21wbDo2kpqfaSTOqcGCGQCsg+Qblharsa2gonwzk5mxBdBLVTgOUinrxcFXVGICojmG4XhcO3gYeA75MOytQfQ5w9sypJGoqgd0GtAaRqO24hwDEyBWgzHbcyuSnDyXAt8ySfmDkGkCz424H7UGl3KTS3l2gD+i2422HAwHfoGL2AMdz1hQuF5WSzCy6rHPBATueKPXgGUjPq6GXfQJw1blhvpM8IdABDCBy3Ut5D+qt0DCAHXe7EA4CA0CxKKfH06OdMeuiGoBx892rCwc7wStE+YzqReOXIdtxtclxe61I8AjwBSj2VNfXRoId+aZAZ11ic+IaNaGzzBxIWwGeV4BIHijq09cmbYpU6AduWeHgyXk9SjQanWVtx220HXfcdhKr5/yF/6E+1i6B7NQGPDNoVVd4AL8AVmv8erkAFsYAAAAASUVORK5CYII=");
}
.hidden_ico[shown] {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH4wUKDjQz9T0TcwAAAflJREFUOMvNkj1oU3EUxX/330qoFYKDg5PUpZMfVVDQSWlFXIqDKQ5iS/EDo+lr85LyMpQimKfJi3nvSRBBUawOLipaQSiFzi5W7CAVXFxEENFIK9q865BYEsiuZ7qXy7mce8+Bfw35W0xXKkwnk+uDvBdshqhLECUyP5xsqgpwLFnkaG+MVCrVumCdWArOieoosA3oBiLgG/ARpOLYYw9bFAyNBzwqj+F6/l7gBbAFeCWwpMgvIdqgyG/gALBb4YPAoGNbS1OuV1fgFv0LCBXgGarnMR0n0WgKiAPe13g8W9i3Xa/NL/ZENb2FcFhhOGdbD4zrlfsQKgr3HdsaFCMxNLrcIKOqtwtnRtR9+TamNfPZyVhHEJ4LzOQ9f6cBcw+YydnW6QZhV+P2+o1GbuaL5V7pXHOhNgDgpK3jILOC3ukETKsvsoY29cohEXmnChjmmwafBIkZIzIKnHI9PwDQSF8D39tYXlWVNwBXPb8MDCt6sf5Ez58ASgp3FbJi6JeIsOEIwBcjZGrIrKheAUZUSeQy1hO5vjLAxMY5XC/YA/oU2AosKCwK/ESJYbQblR3Awbq9nHBsa9kthW2CVAyGRPQS0NMUpCqwjFBw0tZc2yiHYciNhVXeP54EwC2Em5CoS41GHSZamRxPrwKcTTv07+8jkUjwf+APzp3C7mJ3tzAAAAAASUVORK5CYII=");
}

.internal:not([data-internal="true"]) {
    display: none !important;
}

.siginfo_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAXNJREFUeNqUU80uA1EYPXNHSliMaJPZ6EITi5LY8ARiUSuPYFOKjXTjISxYo30ADyCxaDyENGLVkJakSYsR/RlFnXvvVCYzpvRLzvzdc858Ofe7BraLCNQCkSXWiTnvW4W4JArEjZ885nuOEUfELuJJgSmLq+N6peem0XbSaFb3+XZG5ImO30CKL2DZa0gkEarYhMa0LWiSw0t93uvwXXiU40hxsOLkWPaq1y2kwSKRQ2I2xO0fLCmESnN3pFaowBJJEzDw/yJXaZCVGWQwaf1OO7yO9lCaakYapH7SDrQ/1EhrUiKyyWF/V3/oY7ALFXy4GLm05l6oCWs7oxt0XuW1JA2KaFQ/2VNkBuGtJFdpUJAhlokTNGp7/kEamkGjBqWhdhBiHk69RNe/W2+S49SvvPMAE8sb8i7bOYfbmsHz4wpM04DJ5oSp0+51gbcn4OH2C93WKbmbhKtHKnyc5WhvqQGTM8KtIu5kYN5xLvvJ3wIMAEduatirqrxIAAAAAElFTkSuQmCC");
}

.whatsnew_ico {
    display: inline-block;
    height: 23px;
    width: 23px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QYTDTErvhkC9wAAAjhJREFUSMfFls9rE0EUxz+psT9StsRmWawePCjWoMHqZfwbbE+i1MbWRcGqf5HtRYyVJgerF/8FsbmIcQSxhx4EjQybGjKYpEklHhxhm+4m2Sr4YA/LfOf75s173/cm1ul0GNSKucwnAOHK6UH3xIlmZyPiGeIfWzGXiQVGYBY+A2+AReHKVkTiYWDDRDl9IALhyg6w6djWDSBvNnTbtvmCyF86KWsOeN0rB7eUp484tnVNeXoNmPcvCleeDgmg4KSsq6qi14F7oQ6EK1vFXOam8vRT4LzvdA+ABeCCgX4A8sCKucpzqqIfA8vClT/9nLFeZVrMZU4CrxzbmplMJhgb/X1rjWaLnWod5el3wJxw5ZcwjlAH5uTFE8eTM1PORCCmrGp8/VYtAUK4cjdqmd53bCuUHGDKmcCxrYvA8mF0kJ1MJvqWp8FkQ5Vs5O9X6JZpBZcTY8N9HRjMJV8r2cc1FFCqkdqHSWE7ZG883qO239YbrSvjiZGeDhrN1p+yDdRJrxzkd6r1vhEYTP4wSV5Vni6VVS0UUFY1lKffA6uRddAttNSxcUZHjgLQ3G1T+f4D5ekSMBtJaEZgBSAtXJk2/w+BRSBtYB+BZ8Aj0162gE3grnDlXqgDQ/bCSVmzqqLXhCtvD9iqC45tzStPPweywpXtsJLcMOR54E6EkbmkPB13bOu68vSeaYz7k2wGzilV0U+Ape6u6BuZB8amOfGC8vQ6cGbgJAdE0DGEsf82k//2VbEd1cEvrVrxKdMN1qwAAAAASUVORK5CYII=");
}

/* Section buttons */
.copysql_ico {
    height: 16px;
    width: 16px;
    display: inline-block;
    background-size: contain;
    background-repeat: no-repeat;
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH5ggeFAMd33sN5AAAAKNJREFUOMudUikSwzAMXGX8rcL8R8DEJWmRiIHf07BOQH6VknjGUa1GzSJrPVqtDoKC5PICMGo+RSbJZUqRny0/4BsjbDwkl+lM4AwHkaHally2KyLBYfswB80Fb8mewxSZrswAniFKa9d6mwIp8r1a3ve/9fo3BX4luAT2qmyJtXHwTLyN9V/PwexcwAwApFRvKfLyzxrJOhLvNdYW3s78VRMfzKVKHhr36QkAAAAASUVORK5CYII=");
}

.export_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2QUVENDk5NjdGMjM2ODExODIyQURBRDlDNkZERTUzMyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpBOTRBQzQzMTQ3NjkxMUU0OTZEMEZDMjFEMDE4Q0VDRiIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpBOTRBQzQzMDQ3NjkxMUU0OTZEMEZDMjFEMDE4Q0VDRiIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NTM0ODVEQ0I0ODIwNjgxMTgyMkFCMTdDQzcxMzg3NzIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NkFFRDQ5OTY3RjIzNjgxMTgyMkFEQUQ5QzZGREU1MzMiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6s1KKrAAAAf0lEQVR42mI07fb79+PvT0YGMgAXM8c/FpBmCRVpcvQzvLjzlImJgUIw8AYw7tix47+trS1Zmg8fPjwIvMCCTzJgey6G2AbPyaS5oNk8H4UmygXINteenIhCEx0GMBthTkZ3OkEDYDbCXIMtPHB6AZdtNEuJ74G0AJn63wAEGACAQStffMHfsAAAAABJRU5ErkJggg==");
}

.export_txt_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADaGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4zLWMwMTEgNjYuMTQ1NjYxLCAyMDEyLzAyLzA2LTE0OjU2OjI3ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjZBRUQ0OTk2N0YyMzY4MTE4MjJBREFEOUM2RkRFNTMzIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkE5NEFDNDMxNDc2OTExRTQ5NkQwRkMyMUQwMThDRUNGIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkE5NEFDNDMwNDc2OTExRTQ5NkQwRkMyMUQwMThDRUNGIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCBDUzYgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo1MzQ4NURDQjQ4MjA2ODExODIyQUIxN0NDNzEzODc3MiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo2QUVENDk5NjdGMjM2ODExODIyQURBRDlDNkZERTUzMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PqzUoqsAAABKSURBVDhPY9yxY8d/BgoA2ICHikZQLmlA/v45BiYom2ww8AaAw8DW1hbKJQ0cPnx4OITBqAGDwQDGPXv2/P/z5w+USxpgY2NjAAAByhXLwOyrWgAAAABJRU5ErkJggg==");
}

.export_html_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAATdJREFUeNpibN39fA8DA4MzA3lgLxMFmkHAmQVIMIJYVS4SZJkAMuA/iNG25wVZBjBhEQMZmAbE7khi9kCcB7OMkAHFQO/MBtIqSGJKQLHJQLqCkAEtQIX9QO+EA9mTkMTnAMUCgHJdQHY7LgOmAhXUAhV6ANmLgJgZSQ7EXgmUcwaqqQKyp8MkGIHpAOSvpUAcC8RWQLwLiLlwhNk3IHYC4lNAvBiIo2EuKIDSM/FoZoDKzUXWAzNgLtSZkUD8EY8Br6FqWIF4HrIBfkC8AIivQKPvGxbNX4HYF6pmHpSNEojRQNwPDKSTQDoUiH8hyYHYflC5KVC1WKMxHxjSlUCF24DsdCTxWKDYPqBcI5CdhawBFgvoIB+IrwLxHijfEogtQC7Elhc2ArE/mvhENP5xHIG6ASDAAPC+UvCkGM89AAAAAElFTkSuQmCC");
}

.sort_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAALhJREFUeNpi/P//PwMMtO15wQikVgMxiA6pcpFASELkwXygOCNMjIkBFdQBcTAQBwFxPQMRgAnJ9AA0TXVAsSCiDAAq1AFSi6BOhwEQeyFQTpcYFywEYl4s8jxAvBifASzQQDHGF1BEhQG5YNQAaCzgA8BYOQukjLAlaSC4SIwLEoD4MxbxL0AcS9AAYHq4DKTigRg5Y4HY8SA5osIAqHA9kGpEEmoCiq0jKgyQNQGxLjSPwA0DCDAAMMM1IrHFpIQAAAAASUVORK5CYII=");
}

.information_ico {
    display: inline-block;
    height: 32px;
    width: 32px;
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAdhJREFUeNrEl70vA3EYx69NK5VSFjpLu0lKLF0s0kXKZmEn5i5qtHmJhD+AmYENsTSWiq2RSzppY2660FKSDvV95Fuheud3516+yWe5l+f53u/tniewvX+oKWoILIA5MA0mwAjvPYNHcA9uwCV4UQkaUngmCfJgBUQNnhknabAOXsEJ2AUVs+BBk3sRsAPKYNUkeT9F+U6ZJiJWDSTAHb98QLMveXeDsZKqBmbALefZKUmsImObGhCX1yCuOa84YyeNDAyCMzCmuSeJfc5cvwxsgSnNfaWY64cBWXQ5i4ECPVhRrjsVXQObIKx5pzBzfhoY5iHjtZYltxjIWjxknJLkzMpRnLEZoOOAiUyQq9IvpULcAVZXv1MjkpARiPk4ArGgzbnvOOVADDR8HIGGGKj6aKAqBnQfDehioOCjgYIYuGIN57VaklsMNMGpjb+g6nUjSdHa7G5DKT7bHn59m8Xq1+9YSucDi+eAESqSZuShX0XkxY7Q+1VEojewBOouJq8zR8uoKpapmAc1F5LXGLvyV19QArMOT4fOmCXVzqjCPm/vn7ujzRhpox7R7G/4ztZsEhx9nzcFyXo65rt5xrLdHct2WWMpvdjTno/ymaee9vxCtT3/EGAAeihgXfXnZOsAAAAASUVORK5CYII=");
}

.warn_ico {
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA15JREFUeNqsV81qFEEQ7umZjbuLgqgg69/Bg+bgQb1kD3qQmFXEJxB8Ah9AxLN4SbyYTR5AyAsoimZzioLJQfAgmlwUwRVNIoG4ycrOTPt9szPLZDI/PZMtqMxmuru+r6q7aqqN3odbIkm63X+D35ZlHldKPFBKTUDP4FUVT8kxwzBcPLbx/A6dNwzx2LadX+XyAZElRhYBAI+7rmq6rnveNKWQUhJwoBQQGSjmCcdxOW9FSuOeZVkLhQjYtn0YBl/BWB1GSETkEUSANgRIL4HoTdjYjJsnE8CvAbiNhXWGMS+4v2WCa2FjjLZgc1yLACbewYKWaZoVer5foQ3ags03tJ1KgCwx8RnYSw2vO9AL0IvQv1nRoE3ajkZChsCPYMJzsJVQHeeaOKSfoB/xezprMm3SNjBeEGsPARy4lxivaO43PZ4M/T+ZFYUgEsAoE2sXAf/QjeXYc3q/FkrXDZ0oBGeCWMFWeASQ57M5wOnpVMx7RmFLlwQwZzwCYFJjkcmRatNh74tFwWTBOkdsieJ1nxUuh/eDvUeeL1JD41O6USAmsUFA3WB5zeH9Ruj/K76Go/BUxxAxPWz8ORXU9AzZipz8JHmiEwViEhuuq6omgaj3SR8wrSj0MVWVZ0BqEEg6+YWj0I+A0N58Le+LZAS8Fy6/40P0XisjiElsRMDYziDAqreeMPYW+i4lCs00AsQ2Ou8nPiMnRxM+QPT+bFzh0RHUiKN4fIUeio45jsOS/IUH8DXbqASZKQqeFQViEtvYWW7U0D61YxrIju/97xQPF32gqxlR+AY9GNNvnkDjYf1EVVplDxeR2TTwcEblzQhiEZPYXlPKTyNetiJROInFbTEEgd1jeKxFvG+AwLz0P48L7F7ZxYbkkhieXA51XvwQLRN8V1vut2Q/kA3lIl2wbquO098FgdMgsL6rJcOLPxi4jQkuU2TY0k87xyVGAL6nK/a34i6YujGHcl+e0yZtR29KMqZdmsPEBkMVORMFwe0g7Dx0c1o3Iz8SNZTLJZ7YItHgGq6lDdpKuiPKlMZxs38vNBuoWis01uv1vL1EQynC34/+pVR5Y5zDuVizyrWlUqmedC/0cDQ8YbqM+tfzhyB1XSmH1/NK5Hq+41/PW5j7iNfzkZHs6/l/AQYA4OEjjlxSJk0AAAAASUVORK5CYII=");
}

.error_ico {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA8BJREFUeNq0V81rE0EUf7PpponWCnoRoSJa0VKoCtKDVuvFkxar9SJePNRDBS3mj1BEeip4MRdBq4cKgiKCIH6hIFoVRYVWCuIH4snSNEmT7Ph7u5O63c7sbmI68JL9mvf7vTfvvXkjvtEGMo0cyYXrFSRWlYkyDsl+h2gT3rRALH4niBxIHvIVD+4JEhfnSf5eyW8ihogiAOBtJZJXKkS7oc5KQCmjWh6wO6QSEKMyrvAvE0Rv8e1gE9FEGAEr5F2qmcS1AsmPUN6DaysFSBsvEj5w5QFXURNPwl2ahMCznfDCa8hd93GNBNoxcbpI8oQNZc3K6riDCSXxy/NA/iD0fIdXOmMRwIRuTHiPy3Vwv2tVvYM9xSRAaA0MmgCJnigCW/DhE0xIJb2JDRlJz4NJ6H4IEh0mAmkF3pxsGPQSEjYC+iljLSGAFMuW4HZ7MTiCn0YhhyAXIKUYWEXIechhyGWVIAskcLMWSq4vSkM83Ipo/8QBF1jzUaTi2eoN8pqJ3HJ16UcBcgRz7vvmMIkhv0WIMYls6YL1H1wPwC1ZXAhNwD0I1AVOqQHIfBxwnY6El64C9SLrLgGsb+UiY+vXfY+mODGJYwESJnAee4MPmoCFJe8G9moLF8Nc4Qx5fk65PUjijo+EERxzj+LvjC71LNcLlBFfqO2NRWKHbQ4qBhlQlgcB+ngFQ8BvmOKl5JZu+U5MUtsfRGdrIjyyjSR0Iwq8GoxI+xmOgRYrThoj+nXLUQ94dRlcbN5SRdxaEkEiLnh1v5Dm2DMO6dUs4yjVWiHZekfG+5YrXL8h1XTZEWkJYzOBnNMA8FpJOB6BHK/BtFMnONZ8IEadMBJgbBAQtyskw9LPCI6/MRWYfbWSYEzGtlCXR8DGMXjhUgR4Usl4CIkRnfUwWTI2x8AMLl6U9F54FQHuT1EtCdI0pYyFwvecsS21OZziTlaTXwdigEeR2O+/KXsekNj8Bkk1shwM3AvcxD593FrcgA5BIXvsMWQXJAOxI4oVkxhRljP4aX/qAYP7xDFY/zl4LkijikxJkuuXoyXzItpd5p/Q347/uWBPmIdpvfikME9yWcChNQ/w3iq4riue4g+qJBpBw/kHPgfX78PtZOi5AM5/iQ+7cPlrDtPK/wHOc/PQgQb/B3Ru12WVaTOahCc2crAgZWTRO+/FHqrx5HTj5vMqlnYze7fWs2GBj2ZQ0AmvPONOtuAq9QBkYGOpqK2QLYbLHWTTI8ztQL6fVG1bfafjGo7ns7iZAvC47bXzs3GO538FGABlYXzRnnOThQAAAABJRU5ErkJggg==");
}
' ||
'
.success_ico {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA4ZJREFUeNqsl8tLFVEcx2fOqHgjKoIyQwyiUqJFi8AbBCWmlhpFG0PoH6igVkW0iSCiZYuK1j0gSFpkDx+ZRYusv0A3QfQgiLCNWXln+nzHuXKdOzN3HO+Bn+c6c8738z2POQ/7/FCDFZf+/vu3+NsxpsGzrIuW53WSN3uet4rHJnjt2rY9a1vWJ8u2R8mvFVz3e11trVUp1VQqALgD2E0EW4wxlgKYxR/LDsp4MuJ5qym30yUoe9bY9lShUDjtOM7LTAaovA7Yc8TyiFh1xsSK+EZkiPBLUV6G0RjD3CTvD6ExE1XXxMDbaclXKubVjU4CPKHnLNVFo01aaHakMkDBAdyP0fqcWr7SJA1poTki7UQDcknBuzWOY7K0Oqk3pCntcE+YEvh6uuoJjo2pInwRhKa0YQyJVWaAyfKMmZtzqgt/S7QTN4o9AaNerCUG/Ennum3VGPOS9IboZi2ZIM7x+0pxTohVHArfAN/v7SrDXxOHAc+WPLtMfCyagHnLN4CTRsalpYpdL3hPCK60jdhUHAqYO8Q2jMeFKk66iSg468EWsjEiVzopfTZ90W1su1rw3gh4E9k40bzkqxBTbFw02eUG5ol3xJ8VwjcH8K1lyzdMsY12tZCB2UBsL/l+4ldG+EYybUTbI/cPGYBtIpbjAcRGgu14kqwzwcSrGPiGAN5acX2KaVHpmeBDjAnB+yLgWuXUgF2pVkgdJkLP7iDiVDAxHgNfSzZM7E45d1yjkwxjUfqwn7iXYOIxcSQCvobsBbEnDVlMsQ3T73PIgNKJOBPE8Qi4jmdPiXzab9Y3AFvnq2G33ECsiXAqge9bzqLhM2GrB66zOcSVSzTB8/pgSA4sd9USU2zDxvCNiTBdSDZxP2yC/+vIBomu5cLFEtNnB4vCKTaGpDr9pSYC+EOt+1nWbLFgnlncjnV0ZnOYTGFiELha/Ig4lhUO6z3M0SXHcsajh4nxhcGpT9iajwaRKanrYczR/b1lRzIc/eRFHw7dhEmZOUlT2mLA+hF5KtZQ0PqT8xQsVNGEtKQp7fBNyUSc4x9QsAvHcxXmROoxl5Y0pZ3qZuRPSttu1LVKF9QsvaE6qisNacXdEU3CjWbG1b0Q557rTklsfqE1VsTS7T9zF7p6Aey606rLhSQfdy9MdTumJfpcWoPr+SUgB4PreS50Pf8dXM/HKHvVv57XVJS3/gswABvS7PkJ4jDUAAAAAElFTkSuQmCC");
}

.proc_success_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAw9JREFUeNq0l19IFFEUxscpw8w0iMzIKNkSjNKKwChfyqhtk8KkMH2u3oJ9KemlnqJ6yYdeeg4yyP7QHylTI4gigoh9CCItggJFIrNWI6ntO/RN3a73zoy7swd+zO69M/c7c+bec88tyGQyjp+d7hv2fpaA3WArWAeqQBn7voB34CV4CO6Cb9JxYnuF7/iznWBbCY6Dg2Ce5Z5yUg+OgDToAmfBoN/gBbYI4M2LcDkFkmCOk539AJ3gJCLxPbQDEI/h0s1QR2HyafbDicFAByC+AZcesNiJ1kZAAk68sDoAcfneT8AiJz82CjarkXAV8bkMe77EHY59jVr/O8AJVxex4G3QDJ4pbbXU+ucAJ10yYnGJZjPCfRPXnZoTSX7uvxHoAIURit8A7eAnk5EkqsNKfyE1HReezGeSicokC7YyBzha6FVrFW2JQMInw83U7oF9ujiEJH1f1O4VzYQ40BiReJ9FfBMut0Cx4ZlG1xAaz4bA55Dij8BeMKm1r2dUSizP1YoDMUPHBVANasCrAPHH3CUntPbV4L6yY5osJg6Uao3XwVHM3F9ghJ/otWWApxRPG3bQ3hBJrdQ1NA5AWN0ghumEvpE8B7vAuNZeyfmwNMy3cw0DdGDirNDaPrIQecv/sqHsYCGiWgULkuUh5864y8mmv8EAnFimtX8A25heRXzMkOd7Gf6wNiQOpAwdVXSiUmt/D/aAT1p7GbfwtTNcuilxoN+nFJO+JQGDFDP7bcwid/S79DxtuaGaTpRb+ouYZLZkIS7LtsfFjP+KH1d8bqyhE/qSkjrxag6ZtEu0vWV4Bkz53LwGPAAL+X8WuASashSfYsX8ZztmiXQ+4KE6ru8WRuxADvtGJzTf6OcCqVLiPnuDwyq5O8dNKzWtImIUJvl2o3msCWXsFmhNmGpC71PEWUJHbTJmXD8bTNsLWLc3WBJULmFv0M8ERgeUSMg571zA6ggz22WMetOpyPdsqFQ0q3A5BtosVY3JZD5dlqXmzfZcTscywCGW7U3a8XwB7xnTjud3vON5kP0WYAATfdz0oKr6+wAAAABJRU5ErkJggg==");
}

.error_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRJREFUeNqcVstLFXEU/uY392ZlZdd7vXZ7mKhBaWjLNgX6J7QoaudGCSKCgjYSFj02QkEQlhEEtuwvSG6LNhLSLh9JaGXm28TMzHn0nXHGZsaZrnbgMO/vO7/vnN85o42hAnH2HdaxBVg3f8I+vQw7bcBO2LyfgGYUQVvYDq13F7T2fdD74jC0KIJfsKsmYL6cgXkiBR0pKBRDQ5Ku8TmJQFIJAJMwUQo1WAr9DI8DBQn4UfMXGF27ofQcwYscyHiz6GOknIVl74feVg79rv+58l8w4o6PMJ4xGr2SQhQC9wAq+O4B6NonGHfGYXZGElDri59hXj3EqPkytmpZflNDEbmaVsp2PSCRaP4Bq8Np6MoFl1w+p3+jt9DTMbjT9KfOIoALgjfFnHAVVhUStXughhLyliSUF8oXeXcvVprl5CSKXvCQd4IM2gS9iT7gU+O8rIQVp2ZgCeZxxaTWSrXkgrJ89U5I9N4FmvoHOJxcu8ZkM+lm3TyxhaA9tbFaWhl5bQxJFHi9K6VjUs5S2ouw2pRsolSwmMRS9NckqYsgaeJ5GLyHXhIE0LEEu1ExwZni6HIUzfNhkhjwsvDH3OGSizLFXakn4+t9A8lmwD2ZBFtJPRbYTpbrYTPdco7uQe5DRSbzd/x7ktDGkCyeRVXXuq0SU7AVO+LMUjSBBz7o3aBU9SG5YkkEk9izisnIzzqrDdhcFLireT6CpJE+7wfgHsBOaG9UCdTtBbItB1fxOATe4Eto1t3ZfpJ+epd3Ia18jgR7oW4IQX8W6t1kcBUVIfBXoWqJIqn0TgSrHKqPBP1Os1thsxtisytjs8v9bXbdbh5awpsoMD6AJ/TD9LNSPGx00iaso0jWMMkj6wOHS7oyAuO+tOvsf7RrL/IxejUSlxn9Qzjj1TWOuwcW9IOjnAkiVm6LJDLVpqk723SHBx4gEMtAv8ZVDo/DeETZ1GZGppSjRM4iMY8geYlV2Vlw6LMKqqfWhn6Df+hvo9vuJlqkS3n/4JF/FW85i88x2tFN/VWEfltukfAUI8wQWNfW+oyxA9o0fwx6KMc9kg/EYfwRYABD0jtDqxO2xwAAAABJRU5ErkJggg==");
}

.warning_small {
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAxVJREFUeNqclktvElEUxy+XGZgGqBQsLdpSibFd2LhRE2NcunLha4MfQvsBjAsXvl9RUxJNdKELbeNr4dKVpjFGbWO0JpJaG7AttbWAlLEwPMb/wdIM41yoPck/XO6Z+zuXO/ecg1QcO8BENpPM7NGKpdMFrbRLK5a9pVLFbrMxXZbsRUniWadDGnXI0rnNQe8rEcNmFYDA6rI2lFPzPR3trczjUpiiyEyWONN1xhCUaVqZLal5NjefZR63Ene1OI4h0JumARIzqTOLafVkMLDBRnDsuKlRkOT8L93ndUV7unwnjD7J+GXq++LTVFo9si0cYK0exYoVgSrQI+NkZ6CVuV1OW2zyx/FKRe8Oh/yHaz5eG8SnU9cJvr0vKIJ/IPDox8RjfI6ZnQjA+vs2sVRGPUSsugB05nAM9G7tYIpTFp3ERcD1lfEFqwecTokRg1jEXA2AF/qQztyDXQjsq+lYnkATVg8Sg1hgDlcDINLepVx+C51jA7uM3Zd37gh9gmIY03u4JHqYWGCGiM1x5U51tjeEJ6F7K+NuqHdlfB+aFQYBk9gcSbQb97hRgGvYccE8iTmNfKJFxCQ2R8K0tSjCF5uBbjUIfhtKWzmISWxeKlfsSHsRIIqd5hoEIN+glYOYxOYNFi9DN0xz09A309xN6LcIIkl2XqYiJst2s+8udr9gOvd+C8ZP6A40YJwEkxGbOxz2zHK+aF5Ugq6YJ3FFX0AjFkGuQnUQYoKd5ii5b3FnzQuGsNu4VfUVnEQCemCcICbY7zjV87mFrHmBZRIh6H5onyBI3S8mJrE5avgI7myCSq7BKuz/TTOWb2ISu1qu0SwiqOevqeS6/9ajcZw1W4/l1EK1NwT8nshqsaNOhGYxiHrO8oUiW68hcxkxiFXrbqt5gE404GtzPfscS7LsUn5dOx//Mkvw58T6p+GQhbv9R9v97rOT8QXd9E6atsyJqXl9o88dRTc7uNamP0wll0ovNX2qLbWSQklE99zQ9BP0HtfU9IV/WzT8bUFtqaY/MpQSFPf8vSxL57uC3pcixh8BBgBX2nwB4HBekwAAAABJRU5ErkJggg==");
}

.success_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNJREFUeNqclstrE1EUxu/cmWTyzjRWK0pbce/CF4qCRRHqRutjUVcuXEtXIoIVilZdCeJj48KVqAWpSOtCdOGL4vMfUPFRbYttSNM0zWTefmdM4jhO0jYXPs5k5s7vzL3nnnMinRptY/XGXE7dbpnOgGVYW2AV27ZFxgRHlASDc6EghsQPkiRcTGWiL+oxpHpgQ7PuaarZmVQiLJ4MMynEGRc5Y44jWJYdNk2nVVfN7vl8uVvXrO8hWTyazkRf+1ncfyOfVQcXCvqYHJU6165XWCoTYbhmosSZIOD7uQBnIovgHj2jOTR3YU4fy8+UrjVcwex0abhU1A+tWB1nkViILXXQKuWIJMxMFk84DmtvWRU7+N8K4P0KwdvaU8uCV0c4IjF6F4weYv3jgPa8VDT6Wtck3L1uYnyFTuLdcWIQi5g1Bwjo3WSLLGCZzcA/Q7ugy1AXGFPEAnPIdVDIqTtwWtbRPjYJ3w39rPz+Br0hFpgdxOY4bv1JRW4G/skHp3Ec6vkTeJkRmyOJtoajoWbge3zwY9BNSHCDDiaxOTK0JfQ3sDp0Grq6THgvdAsSqzeISWyJ0t/N0MpXTHzJu8FBAmVhzgVtC+ZMUIJVxhHothfuBhdMl+0DvKxeAHIe5mwQ3HNvP3SnXslxHWFYtmVXf4/gyzIeJ4MVJx8D4Pug+7TdQWBiEpujMuZNo+ZgE/QkwMlmLxzP98IM14O7uQUm2LMcJfetphreZ+Tkqc9J0QPvgnkIRRsdMx1MsN9xqufzec3/fKPfSQW+E2YUii12jolJbI5m8Qrldhx1vaET2G0wj6DE4vAylfBxYrunCM2id35Wc7SyGeTkGeBnYB9D6cXgxCAWMWvFjjpRLBG6np0sMk/Aq2MDNLgUOL1LDGJVu1stD5SVsb5YIvzg148CK5eMZRcmHV9O74IxQqzAlolOdDieki/kpktOQEwa7nl2asFB774BxoGGTV9pjfYLnI2i3A4VcvkOtx2i/9aafiWJaDswpxbQeDrcG9T0A1O8MrGTupJp2gNaTvX8bXHT36IExTl/n1DkS5j/vN7qfgswAFMPc0H/GzIVAAAAAElFTkSuQmCC");
}
';
    print_out('<STYLE type="text/css">');
    print_clob(l_html_clob);
    print_out('</STYLE>');


    ------------------------------------------------------------
    -- JavaScript (EBSAF-262)
    ------------------------------
    -- Start with empty CLOB to ensure string literals are concatenated as such
    dbms_lob.trim(l_html_clob, 0);
    l_html_clob := l_html_clob ||
q'`/*! jQuery v1.11.1 | (c) 2005, 2014 jQuery Foundation, Inc. | jquery.org/license */
!function(a,b){"object"==typeof module&&"object"==typeof module.exports?module.exports=a.document?b(a,!0):function(a){if(!a.document)throw new Error("jQuery requires a window with a document");return b(a)}:b(a)}("undefined"!=typeof window?window:this,function(a,b){var c=[],d=c.slice,e=c.concat,f=c.push,g=c.indexOf,h={},i=h.toString,j=h.hasOwnProperty,k={},l="1.11.1",m=function(a,b){return new m.fn.init(a,b)},n=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,o=/^-ms-/,p=/-([\da-z])/gi,q=function(a,b){return b.toUpperCase()};m.fn=m.prototype={jquery:l,constructor:m,selector:"",length:0,toArray:function(){return d.call(this)},get:function(a){return null!=a?0>a?this[a+this.length]:this[a]:d.call(this)},pushStack:function(a){var b=m.merge(this.constructor(),a);return b.prevObject=this,b.context=this.context,b},each:function(a,b){return m.each(this,a,b)},map:function(a){return this.pushStack(m.map(this,function(b,c){return a.call(b,c,b)}))},slice:function(){return this.pushStack(d.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(a){var b=this.length,c=+a+(0>a?b:0);return this.pushStack(c>=0&&b>c?[this[c]]:[])},end:function(){return this.prevObject||this.constructor(null)},push:f,sort:c.sort,splice:c.splice},m.extend=m.fn.extend=function(){var a,b,c,d,e,f,g=arguments[0]||{},h=1,i=arguments.length,j=!1;for("boolean"==typeof g&&(j=g,g=arguments[h]||{},h++),"object"==typeof g||m.isFunction(g)||(g={}),h===i&&(g=this,h--);i>h;h++)if(null!=(e=arguments[h]))for(d in e)a=g[d],c=e[d],g!==c&&(j&&c&&(m.isPlainObject(c)||(b=m.isArray(c)))?(b?(b=!1,f=a&&m.isArray(a)?a:[]):f=a&&m.isPlainObject(a)?a:{},g[d]=m.extend(j,f,c)):void 0!==c&&(g[d]=c));return g},m.extend({expando:"jQuery"+(l+Math.random()).replace(/\D/g,""),isReady:!0,error:function(a){throw new Error(a)},noop:function(){},isFunction:function(a){return"function"===m.type(a)},isArray:Array.isArray||function(a){return"array"===m.type(a)},isWindow:function(a){return null!=a&&a==a.window},isNumeric:function(a){return!m.isArray(a)&&a-parseFloat(a)>=0},isEmptyObject:function(a){var b;for(b in a)return!1;return!0},isPlainObject:function(a){var b;if(!a||"object"!==m.type(a)||a.nodeType||m.isWindow(a))return!1;try{if(a.constructor&&!j.call(a,"constructor")&&!j.call(a.constructor.prototype,"isPrototypeOf"))return!1}catch(c){return!1}if(k.ownLast)for(b in a)return j.call(a,b);
for(b in a);return void 0===b||j.call(a,b)},type:function(a){return null==a?a+"":"object"==typeof a||"function"==typeof a?h[i.call(a)]||"object":typeof a},globalEval:function(b){b&&m.trim(b)&&(a.execScript||function(b){a.eval.call(a,b)})(b)},camelCase:function(a){return a.replace(o,"ms-").replace(p,q)},nodeName:function(a,b){return a.nodeName&&a.nodeName.toLowerCase()===b.toLowerCase()},each:function(a,b,c){var d,e=0,f=a.length,g=r(a);if(c){if(g){for(;f>e;e++)if(d=b.apply(a[e],c),d===!1)break}else for(e in a)if(d=b.apply(a[e],c),d===!1)break}else if(g){for(;f>e;e++)if(d=b.call(a[e],e,a[e]),d===!1)break}else for(e in a)if(d=b.call(a[e],e,a[e]),d===!1)break;return a},trim:function(a){return null==a?"":(a+"").replace(n,"")},makeArray:function(a,b){var c=b||[];return null!=a&&(r(Object(a))?m.merge(c,"string"==typeof a?[a]:a):f.call(c,a)),c},inArray:function(a,b,c){var d;if(b){if(g)return g.call(b,a,c);for(d=b.length,c=c?0>c?Math.max(0,d+c):c:0;d>c;c++)if(c in b&&b[c]===a)return c}return-1},merge:function(a,b){var c=+b.length,d=0,e=a.length;while(c>d)a[e++]=b[d++];if(c!==c)while(void 0!==b[d])a[e++]=b[d++];return a.length=e,a},grep:function(a,b,c){for(var d,e=[],f=0,g=a.length,h=!c;g>f;f++)d=!b(a[f],f),d!==h&&e.push(a[f]);return e},map:function(a,b,c){var d,f=0,g=a.length,h=r(a),i=[];if(h)for(;g>f;f++)d=b(a[f],f,c),null!=d&&i.push(d);else for(f in a)d=b(a[f],f,c),null!=d&&i.push(d);return e.apply([],i)},guid:1,proxy:function(a,b){var c,e,f;return"string"==typeof b&&(f=a[b],b=a,a=f),m.isFunction(a)?(c=d.call(arguments,2),e=function(){return a.apply(b||this,c.concat(d.call(arguments)))},e.guid=a.guid=a.guid||m.guid++,e):void 0},now:function(){return+new Date},support:k}),m.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(a,b){h["[object "+b+"]"]=b.toLowerCase()});function r(a){var b=a.length,c=m.type(a);return"function"===c||m.isWindow(a)?!1:1===a.nodeType&&b?!0:"array"===c||0===b||"number"==typeof b&&b>0&&b-1 in a}var s=function(a){var b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u="sizzle"+-new Date,v=a.document,w=0,x=0,y=gb(),z=gb(),A=gb(),B=function(a,b){return a===b&&(l=!0),0},C="undefined",D=1<<31,E={}.hasOwnProperty,F=[],G=F.pop,H=F.push,I=F.push,J=F.slice,K=F.indexOf||function(a){for(var b=0,c=this.length;c>b;b++)
if(this[b]===a)return b;return-1},L="checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",M="[\\x20\\t\\r\\n\\f]",N="(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",O=N.replace("w","w#"),P="\\["+M+"*("+N+")(?:"+M+"*([*^$|!~]?=)"+M+"*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|("+O+"))|)"+M+"*\\]",Q=":("+N+")(?:\\((('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|"+P+")*)|.*)\\)|)",R=new RegExp("^"+M+"+|((?:^|[^\\\\])(?:\\\\.)*)"+M+"+$","g"),S=new RegExp("^"+M+"*,"+M+"*"),T=new RegExp("^"+M+"*([>+~]|"+M+")"+M+"*"),U=new RegExp("="+M+"*([^\\]'\"]*?)"+M+"*\\]","g"),V=new RegExp(Q),W=new RegExp("^"+O+"$"),X={ID:new RegExp("^#("+N+")"),CLASS:new RegExp("^\\.("+N+")"),TAG:new RegExp("^("+N.replace("w","w*")+")"),ATTR:new RegExp("^"+P),PSEUDO:new RegExp("^"+Q),CHILD:new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\("+M+"*(even|odd|(([+-]|)(\\d*)n|)"+M+"*(?:([+-]|)"+M+"*(\\d+)|))"+M+"*\\)|)","i"),bool:new RegExp("^(?:"+L+")$","i"),needsContext:new RegExp("^"+M+"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\("+M+"*((?:-\\d)?\\d*)"+M+"*\\)|)(?=[^-]|$)","i")},Y=/^(?:input|select|textarea|button)$/i,Z=/^h\d$/i,$=/^[^{]+\{\s*\[native \w/,_=/^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,ab=/[+~]/,bb=/'|\\/g,cb=new RegExp("\\\\([\\da-f]{1,6}"+M+"?|("+M+")|.)","ig"),db=function(a,b,c){var d="0x"+b-65536;return d!==d||c?b:0>d?String.fromCharCode(d+65536):String.fromCharCode(d>>10|55296,1023&d|56320)};try{I.apply(F=J.call(v.childNodes),v.childNodes),F[v.childNodes.length].nodeType}catch(eb){I={apply:F.length?function(a,b){H.apply(a,J.call(b))}:function(a,b){var c=a.length,d=0;while(a[c++]=b[d++]);a.length=c-1}}}function fb(a,b,d,e){var f,h,j,k,l,o,r,s,w,x;if((b?b.ownerDocument||b:v)!==n&&m(b),b=b||n,d=d||[],!a||"string"!=typeof a)return d;if(1!==(k=b.nodeType)&&9!==k)return[];if(p&&!e){if(f=_.exec(a))if(j=f[1]){if(9===k){if(h=b.getElementById(j),!h||!h.parentNode)return d;if(h.id===j)return d.push(h),d}else if(b.ownerDocument&&(h=b.ownerDocument.getElementById(j))&&t(b,h)&&h.id===j)return d.push(h),d}else{if(f[2])return I.apply(d,b.getElementsByTagName(a)),d;
if((j=f[3])&&c.getElementsByClassName&&b.getElementsByClassName)return I.apply(d,b.getElementsByClassName(j)),d}if(c.qsa&&(!q||!q.test(a))){if(s=r=u,w=b,x=9===k&&a,1===k&&"object"!==b.nodeName.toLowerCase()){o=g(a),(r=b.getAttribute("id"))?s=r.replace(bb,"\\$&"):b.setAttribute("id",s),s="[id='"+s+"'] ",l=o.length;while(l--)o[l]=s+qb(o[l]);w=ab.test(a)&&ob(b.parentNode)||b,x=o.join(",")}if(x)try{return I.apply(d,w.querySelectorAll(x)),d}catch(y){}finally{r||b.removeAttribute("id")}}}return i(a.replace(R,"$1"),b,d,e)}function gb(){var a=[];function b(c,e){return a.push(c+" ")>d.cacheLength&&delete b[a.shift()],b[c+" "]=e}return b}function hb(a){return a[u]=!0,a}function ib(a){var b=n.createElement("div");try{return!!a(b)}catch(c){return!1}finally{b.parentNode&&b.parentNode.removeChild(b),b=null}}function jb(a,b){var c=a.split("|"),e=a.length;while(e--)d.attrHandle[c[e]]=b}function kb(a,b){var c=b&&a,d=c&&1===a.nodeType&&1===b.nodeType&&(~b.sourceIndex||D)-(~a.sourceIndex||D);if(d)return d;if(c)while(c=c.nextSibling)if(c===b)return-1;return a?1:-1}function lb(a){return function(b){var c=b.nodeName.toLowerCase();return"input"===c&&b.type===a}}function mb(a){return function(b){var c=b.nodeName.toLowerCase();return("input"===c||"button"===c)&&b.type===a}}function nb(a){return hb(function(b){return b=+b,hb(function(c,d){var e,f=a([],c.length,b),g=f.length;while(g--)c[e=f[g]]&&(c[e]=!(d[e]=c[e]))})})}function ob(a){return a&&typeof a.getElementsByTagName!==C&&a}c=fb.support={},f=fb.isXML=function(a){var b=a&&(a.ownerDocument||a).documentElement;return b?"HTML"!==b.nodeName:!1},m=fb.setDocument=function(a){var b,e=a?a.ownerDocument||a:v,g=e.defaultView;return e!==n&&9===e.nodeType&&e.documentElement?(n=e,o=e.documentElement,p=!f(e),g&&g!==g.top&&(g.addEventListener?g.addEventListener("unload",function(){m()},!1):g.attachEvent&&g.attachEvent("onunload",function(){m()})),c.attributes=ib(function(a){return a.className="i",!a.getAttribute("className")}),c.getElementsByTagName=ib(function(a){return a.appendChild(e.createComment("")),!a.getElementsByTagName("*").length}),c.getElementsByClassName=$.test(e.getElementsByClassName)&&ib(
function(a){return a.innerHTML="<div class='a'></div><div class='a i'></div>",a.firstChild.className="i",2===a.getElementsByClassName("i").length}),c.getById=ib(function(a){return o.appendChild(a).id=u,!e.getElementsByName||!e.getElementsByName(u).length}),c.getById?(d.find.ID=function(a,b){if(typeof b.getElementById!==C&&p){var c=b.getElementById(a);return c&&c.parentNode?[c]:[]}},d.filter.ID=function(a){var b=a.replace(cb,db);return function(a){return a.getAttribute("id")===b}}):(delete d.find.ID,d.filter.ID=function(a){var b=a.replace(cb,db);return function(a){var c=typeof a.getAttributeNode!==C&&a.getAttributeNode("id");return c&&c.value===b}}),d.find.TAG=c.getElementsByTagName?function(a,b){return typeof b.getElementsByTagName!==C?b.getElementsByTagName(a):void 0}:function(a,b){var c,d=[],e=0,f=b.getElementsByTagName(a);if("*"===a){while(c=f[e++])1===c.nodeType&&d.push(c);return d}return f},d.find.CLASS=c.getElementsByClassName&&function(a,b){return typeof b.getElementsByClassName!==C&&p?b.getElementsByClassName(a):void 0},r=[],q=[],(c.qsa=$.test(e.querySelectorAll))&&(ib(function(a){a.innerHTML="<select msallowclip=''><option selected=''></option></select>",a.querySelectorAll("[msallowclip^='']").length&&q.push("[*^$]="+M+"*(?:''|\"\")"),a.querySelectorAll("[selected]").length||q.push("\\["+M+"*(?:value|"+L+")"),a.querySelectorAll(":checked").length||q.push(":checked")}),ib(function(a){var b=e.createElement("input");
b.setAttribute("type","hidden"),a.appendChild(b).setAttribute("name","D"),a.querySelectorAll("[name=d]").length&&q.push("name"+M+"*[*^$|!~]?="),a.querySelectorAll(":enabled").length||q.push(":enabled",":disabled"),a.querySelectorAll("*,:x"),q.push(",.*:")})),(c.matchesSelector=$.test(s=o.matches||o.webkitMatchesSelector||o.mozMatchesSelector||o.oMatchesSelector||o.msMatchesSelector))&&ib(function(a){c.disconnectedMatch=s.call(a,"div"),s.call(a,"[s!='']:x"),r.push("!=",Q)}),q=q.length&&new RegExp(q.join("|")),r=r.length&&new RegExp(r.join("|")),b=$.test(o.compareDocumentPosition),t=b||$.test(o.contains)?function(a,b){var c=9===a.nodeType?a.documentElement:a,d=b&&b.parentNode;return a===d||!(!d||1!==d.nodeType||!(c.contains?c.contains(d):a.compareDocumentPosition&&16&a.compareDocumentPosition(d)))}:function(a,b){if(b)while(b=b.parentNode)if(b===a)return!0;return!1},B=b?function(a,b){if(a===b)return l=!0,0;var d=!a.compareDocumentPosition-!b.compareDocumentPosition;return d?d:(d=(a.ownerDocument||a)===(b.ownerDocument||b)?a.compareDocumentPosition(b):1,1&d||!c.sortDetached&&b.compareDocumentPosition(a)===d?a===e||a.ownerDocument===v&&t(v,a)?-1:b===e||b.ownerDocument===v&&t(v,b)?1:k?K.call(k,a)-K.call(k,b):0:4&d?-1:1)}:function(a,b){if(a===b)return l=!0,0;var c,d=0,f=a.parentNode,g=b.parentNode,h=[a],i=[b];if(!f||!g)return a===e?-1:b===e?1:f?-1:g?1:k?K.call(k,a)-K.call(k,b):0;if(f===g)return kb(a,b);c=a;while(c=c.parentNode)h.unshift(c);c=b;while(c=c.parentNode)i.unshift(c);
while(h[d]===i[d])d++;return d?kb(h[d],i[d]):h[d]===v?-1:i[d]===v?1:0},e):n},fb.matches=function(a,b){return fb(a,null,null,b)},fb.matchesSelector=function(a,b){if((a.ownerDocument||a)!==n&&m(a),b=b.replace(U,"='$1']"),!(!c.matchesSelector||!p||r&&r.test(b)||q&&q.test(b)))try{var d=s.call(a,b);if(d||c.disconnectedMatch||a.document&&11!==a.document.nodeType)return d}catch(e){}return fb(b,n,null,[a]).length>0},fb.contains=function(a,b){return(a.ownerDocument||a)!==n&&m(a),t(a,b)},fb.attr=function(a,b){(a.ownerDocument||a)!==n&&m(a);var e=d.attrHandle[b.toLowerCase()],f=e&&E.call(d.attrHandle,b.toLowerCase())?e(a,b,!p):void 0;return void 0!==f?f:c.attributes||!p?a.getAttribute(b):(f=a.getAttributeNode(b))&&f.specified?f.value:null},fb.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)},fb.uniqueSort=function(a){var b,d=[],e=0,f=0;if(l=!c.detectDuplicates,k=!c.sortStable&&a.slice(0),a.sort(B),l){while(b=a[f++])b===a[f]&&(e=d.push(f));while(e--)a.splice(d[e],1)}return k=null,a},e=fb.getText=function(a){var b,c="",d=0,f=a.nodeType;if(f){if(1===f||9===f||11===f){if("string"==typeof a.textContent)return a.textContent;for(a=a.firstChild;a;a=a.nextSibling)c+=e(a)}else if(3===f||4===f)return a.nodeValue}else while(b=a[d++])c+=e(b);return c},d=fb.selectors={cacheLength:50,createPseudo:hb,match:X,attrHandle:{},find:{},relative:{">":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(a){return a[1]=a[1].replace(cb,db),a[3]=(a[3]||a[4]||a[5]||"").replace(cb,db),"~="===a[2]&&(a[3]=" "+a[3]+" "),a.slice(0,4)},CHILD:function(a){return a[1]=a[1].toLowerCase(),"nth"===a[1].slice(0,3)?(a[3]||fb.error(a[0]),a[4]=+(a[4]?a[5]+(a[6]||1):2*("even"===a[3]||"odd"===a[3])),a[5]=+(a[7]+a[8]||"odd"===a[3])):a[3]&&fb.error(a[0]),a},PSEUDO:function(a){var b,c=!a[6]&&a[2];
return X.CHILD.test(a[0])?null:(a[3]?a[2]=a[4]||a[5]||"":c&&V.test(c)&&(b=g(c,!0))&&(b=c.indexOf(")",c.length-b)-c.length)&&(a[0]=a[0].slice(0,b),a[2]=c.slice(0,b)),a.slice(0,3))}},filter:{TAG:function(a){var b=a.replace(cb,db).toLowerCase();return"*"===a?function(){return!0}:function(a){return a.nodeName&&a.nodeName.toLowerCase()===b}},CLASS:function(a){var b=y[a+" "];return b||(b=new RegExp("(^|"+M+")"+a+"("+M+"|$)"))&&y(a,function(a){return b.test("string"==typeof a.className&&a.className||typeof a.getAttribute!==C&&a.getAttribute("class")||"")})},ATTR:function(a,b,c){return function(d){var e=fb.attr(d,a);return null==e?"!="===b:b?(e+="","="===b?e===c:"!="===b?e!==c:"^="===b?c&&0===e.indexOf(c):"*="===b?c&&e.indexOf(c)>-1:"$="===b?c&&e.slice(-c.length)===c:"~="===b?(" "+e+" ").indexOf(c)>-1:"|="===b?e===c||e.slice(0,c.length+1)===c+"-":!1):!0}},CHILD:function(a,b,c,d,e){var f="nth"!==a.slice(0,3),g="last"!==a.slice(-4),h="of-type"===b;return 1===d&&0===e?function(a){return!!a.parentNode}:function(b,c,i){var j,k,l,m,n,o,p=f!==g?"nextSibling":"previousSibling",q=b.parentNode,r=h&&b.nodeName.toLowerCase(),s=!i&&!h;if(q){if(f){while(p){l=b;while(l=l[p])if(h?l.nodeName.toLowerCase()===r:1===l.nodeType)return!1;o=p="only"===a&&!o&&"nextSibling"}return!0}if(o=[g?q.firstChild:q.lastChild],g&&s){k=q[u]||(q[u]={}),j=k[a]||[],n=j[0]===w&&j[1],m=j[0]===w&&j[2],l=n&&q.childNodes[n];while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if(1===l.nodeType&&++m&&l===b){k[a]=[w,n,m];break}}else if(s&&(j=(b[u]||(b[u]={}))[a])&&j[0]===w)m=j[1];else while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if((h?l.nodeName.toLowerCase()===r:1===l.nodeType)&&++m&&(s&&((l[u]||(l[u]={}))[a]=[w,m]),l===b))break;
return m-=e,m===d||m%d===0&&m/d>=0}}},PSEUDO:function(a,b){var c,e=d.pseudos[a]||d.setFilters[a.toLowerCase()]||fb.error("unsupported pseudo: "+a);return e[u]?e(b):e.length>1?(c=[a,a,"",b],d.setFilters.hasOwnProperty(a.toLowerCase())?hb(function(a,c){var d,f=e(a,b),g=f.length;while(g--)d=K.call(a,f[g]),a[d]=!(c[d]=f[g])}):function(a){return e(a,0,c)}):e}},pseudos:{not:hb(function(a){var b=[],c=[],d=h(a.replace(R,"$1"));return d[u]?hb(function(a,b,c,e){var f,g=d(a,null,e,[]),h=a.length;while(h--)(f=g[h])&&(a[h]=!(b[h]=f))}):function(a,e,f){return b[0]=a,d(b,null,f,c),!c.pop()}}),has:hb(function(a){return function(b){return fb(a,b).length>0}}),contains:hb(function(a){return function(b){return(b.textContent||b.innerText||e(b)).indexOf(a)>-1}}),lang:hb(function(a){return W.test(a||"")||fb.error("unsupported lang: "+a),a=a.replace(cb,db).toLowerCase(),function(b){var c;do if(c=p?b.lang:b.getAttribute("xml:lang")||b.getAttribute("lang"))return c=c.toLowerCase(),c===a||0===c.indexOf(a+"-");while((b=b.parentNode)&&1===b.nodeType);return!1}}),target:function(b){var c=a.location&&a.location.hash;return c&&c.slice(1)===b.id},root:function(a){return a===o},focus:function(a){return a===n.activeElement&&(!n.hasFocus||n.hasFocus())&&!!(a.type||a.href||~a.tabIndex)},enabled:function(a){return a.disabled===!1},disabled:function(a){return a.disabled===!0},checked:function(a){var b=a.nodeName.toLowerCase();
return"input"===b&&!!a.checked||"option"===b&&!!a.selected},selected:function(a){return a.parentNode&&a.parentNode.selectedIndex,a.selected===!0},empty:function(a){for(a=a.firstChild;a;a=a.nextSibling)if(a.nodeType<6)return!1;return!0},parent:function(a){return!d.pseudos.empty(a)},header:function(a){return Z.test(a.nodeName)},input:function(a){return Y.test(a.nodeName)},button:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&"button"===a.type||"button"===b},text:function(a){var b;return"input"===a.nodeName.toLowerCase()&&"text"===a.type&&(null==(b=a.getAttribute("type"))||"text"===b.toLowerCase())},first:nb(function(){return[0]}),last:nb(function(a,b){return[b-1]}),eq:nb(function(a,b,c){return[0>c?c+b:c]}),even:nb(function(a,b){for(var c=0;b>c;c+=2)a.push(c);return a}),odd:nb(function(a,b){for(var c=1;b>c;c+=2)a.push(c);return a}),lt:nb(function(a,b,c){for(var d=0>c?c+b:c;--d>=0;)a.push(d);return a}),gt:nb(function(a,b,c){for(var d=0>c?c+b:c;++d<b;)a.push(d);return a})}},d.pseudos.nth=d.pseudos.eq;for(b in{radio:!0,checkbox:!0,file:!0,password:!0,image:!0})d.pseudos[b]=lb(b);for(b in{submit:!0,reset:!0})d.pseudos[b]=mb(b);function pb(){}pb.prototype=d.filters=d.pseudos,d.setFilters=new pb,g=fb.tokenize=function(a,b){var c,e,f,g,h,i,j,k=z[a+" "];if(k)return b?0:k.slice(0);h=a,i=[],j=d.preFilter;while(h){(!c||(e=S.exec(h)))&&(e&&(h=h.slice(e[0].length)||h),i.push(f=[])),c=!1,(e=T.exec(h))&&(c=e.shift(),f.push({value:c,type:e[0].replace(R," ")}),h=h.slice(c.length));for(g in d.filter)!(e=X[g].exec(h))||j[g]&&!(e=j[g](e))||(c=e.shift(),f.push({value:c,type:g,matches:e}),h=h.slice(c.length));if(!c)break}return b?h.length:h?fb.error(a):z(a,i).slice(0)};function qb(a){for(var b=0,c=a.length,d="";c>b;b++)d+=a[b].value;return d}
function rb(a,b,c){var d=b.dir,e=c&&"parentNode"===d,f=x++;return b.first?function(b,c,f){while(b=b[d])if(1===b.nodeType||e)return a(b,c,f)}:function(b,c,g){var h,i,j=[w,f];if(g){while(b=b[d])if((1===b.nodeType||e)&&a(b,c,g))return!0}else while(b=b[d])if(1===b.nodeType||e){if(i=b[u]||(b[u]={}),(h=i[d])&&h[0]===w&&h[1]===f)return j[2]=h[2];if(i[d]=j,j[2]=a(b,c,g))return!0}}}function sb(a){return a.length>1?function(b,c,d){var e=a.length;while(e--)if(!a[e](b,c,d))return!1;return!0}:a[0]}function tb(a,b,c){for(var d=0,e=b.length;e>d;d++)fb(a,b[d],c);return c}function ub(a,b,c,d,e){for(var f,g=[],h=0,i=a.length,j=null!=b;i>h;h++)(f=a[h])&&(!c||c(f,d,e))&&(g.push(f),j&&b.push(h));return g}function vb(a,b,c,d,e,f){return d&&!d[u]&&(d=vb(d)),e&&!e[u]&&(e=vb(e,f)),hb(function(f,g,h,i){var j,k,l,m=[],n=[],o=g.length,p=f||tb(b||"*",h.nodeType?[h]:h,[]),q=!a||!f&&b?p:ub(p,m,a,h,i),r=c?e||(f?a:o||d)?[]:g:q;if(c&&c(q,r,h,i),d){j=ub(r,n),d(j,[],h,i),k=j.length;while(k--)(l=j[k])&&(r[n[k]]=!(q[n[k]]=l))}if(f){if(e||a){if(e){j=[],k=r.length;while(k--)(l=r[k])&&j.push(q[k]=l);e(null,r=[],j,i)}k=r.length;while(k--)(l=r[k])&&(j=e?K.call(f,l):m[k])>-1&&(f[j]=!(g[j]=l))}}else r=ub(r===g?r.splice(o,r.length):r),e?e(null,g,r,i):I.apply(g,r)})}function wb(a){for(var b,c,e,f=a.length,g=d.relative[a[0].type],h=g||d.relative[" "],i=g?1:0,k=rb(function(a){return a===b},h,!0),l=rb(function(a){return K.call(b,a)>-1},h,!0),m=[function(a,c,d){return!g&&(d||c!==j)||((b=c).nodeType?k(a,c,d):l(a,c,d))}];f>i;i++)if(c=d.relative[a[i].type])m=[rb(sb(m),c)];else{if(c=d.filter[a[i].type].apply(null,a[i].matches),c[u]){for(e=++i;f>e;e++)if(d.relative[a[e].type])break;
return vb(i>1&&sb(m),i>1&&qb(a.slice(0,i-1).concat({value:" "===a[i-2].type?"*":""})).replace(R,"$1"),c,e>i&&wb(a.slice(i,e)),f>e&&wb(a=a.slice(e)),f>e&&qb(a))}m.push(c)}return sb(m)}function xb(a,b){var c=b.length>0,e=a.length>0,f=function(f,g,h,i,k){var l,m,o,p=0,q="0",r=f&&[],s=[],t=j,u=f||e&&d.find.TAG("*",k),v=w+=null==t?1:Math.random()||.1,x=u.length;for(k&&(j=g!==n&&g);q!==x&&null!=(l=u[q]);q++){if(e&&l){m=0;while(o=a[m++])if(o(l,g,h)){i.push(l);break}k&&(w=v)}c&&((l=!o&&l)&&p--,f&&r.push(l))}if(p+=q,c&&q!==p){m=0;while(o=b[m++])o(r,s,g,h);if(f){if(p>0)while(q--)r[q]||s[q]||(s[q]=G.call(i));s=ub(s)}I.apply(i,s),k&&!f&&s.length>0&&p+b.length>1&&fb.uniqueSort(i)}return k&&(w=v,j=t),r};return c?hb(f):f}return h=fb.compile=function(a,b){var c,d=[],e=[],f=A[a+" "];if(!f){b||(b=g(a)),c=b.length;while(c--)f=wb(b[c]),f[u]?d.push(f):e.push(f);f=A(a,xb(e,d)),f.selector=a}return f},i=fb.select=function(a,b,e,f){var i,j,k,l,m,n="function"==typeof a&&a,o=!f&&g(a=n.selector||a);if(e=e||[],1===o.length){if(j=o[0]=o[0].slice(0),j.length>2&&"ID"===(k=j[0]).type&&c.getById&&9===b.nodeType&&p&&d.relative[j[1].type]){if(b=(d.find.ID(k.matches[0].replace(cb,db),b)||[])[0],!b)return e;n&&(b=b.parentNode),a=a.slice(j.shift().value.length)}i=X.needsContext.test(a)?0:j.length;while(i--)
{if(k=j[i],d.relative[l=k.type])break;if((m=d.find[l])&&(f=m(k.matches[0].replace(cb,db),ab.test(j[0].type)&&ob(b.parentNode)||b))){if(j.splice(i,1),a=f.length&&qb(j),!a)return I.apply(e,f),e;break}}}return(n||h(a,o))(f,b,!p,e,ab.test(a)&&ob(b.parentNode)||b),e},c.sortStable=u.split("").sort(B).join("")===u,c.detectDuplicates=!!l,m(),c.sortDetached=ib(function(a){return 1&a.compareDocumentPosition(n.createElement("div"))}),ib(function(a){return a.innerHTML="<a href='#'></a>","#"===a.firstChild.getAttribute("href")})||jb("type|href|height|width",function(a,b,c){return c?void 0:a.getAttribute(b,"type"===b.toLowerCase()?1:2)}),c.attributes&&ib(function(a){return a.innerHTML="<input/>",a.firstChild.setAttribute("value",""),""===a.firstChild.getAttribute("value")})||jb("value",function(a,b,c){return c||"input"!==a.nodeName.toLowerCase()?void 0:a.defaultValue}),ib(function(a){return null==a.getAttribute("disabled")})||jb(L,function(a,b,c){var d;return c?void 0:a[b]===!0?b.toLowerCase():(d=a.getAttributeNode(b))&&d.specified?d.value:null}),fb}(a);m.find=s,m.expr=s.selectors,m.expr[":"]=m.expr.pseudos,m.unique=s.uniqueSort,m.text=s.getText,m.isXMLDoc=s.isXML,m.contains=s.contains;var t=m.expr.match.needsContext,u=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,v=/^.[^:#\[\.,]*$/;function w(a,b,c){if(m.isFunction(b))return m.grep(a,function(a,d){return!!b.call(a,d,a)!==c});if(b.nodeType)return m.grep(a,function(a){return a===b!==c});if("string"==typeof b){if(v.test(b))return m.filter(b,a,c);b=m.filter(b,a)}return m.grep(a,function(a){return m.inArray(a,b)>=0!==c})}m.filter=function(a,b,c){var d=b[0];
return c&&(a=":not("+a+")"),1===b.length&&1===d.nodeType?m.find.matchesSelector(d,a)?[d]:[]:m.find.matches(a,m.grep(b,function(a){return 1===a.nodeType}))},m.fn.extend({find:function(a){var b,c=[],d=this,e=d.length;if("string"!=typeof a)return this.pushStack(m(a).filter(function(){for(b=0;e>b;b++)if(m.contains(d[b],this))return!0}));for(b=0;e>b;b++)m.find(a,d[b],c);return c=this.pushStack(e>1?m.unique(c):c),c.selector=this.selector?this.selector+" "+a:a,c},filter:function(a){return this.pushStack(w(this,a||[],!1))},not:function(a){return this.pushStack(w(this,a||[],!0))},is:function(a){return!!w(this,"string"==typeof a&&t.test(a)?m(a):a||[],!1).length}});var x,y=a.document,z=/^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,A=m.fn.init=function(a,b){var c,d;if(!a)return this;if("string"==typeof a){if(c="<"===a.charAt(0)&&">"===a.charAt(a.length-1)&&a.length>=3?[null,a,null]:z.exec(a),!c||!c[1]&&b)return!b||b.jquery?(b||x).find(a):this.constructor(b).find(a);if(c[1]){if(b=b instanceof m?b[0]:b,m.merge(this,m.parseHTML(c[1],b&&b.nodeType?b.ownerDocument||b:y,!0)),u.test(c[1])&&m.isPlainObject(b))for(c in b)m.isFunction(this[c])?this[c](b[c]):this.attr(c,b[c]);return this}if(d=y.getElementById(c[2]),d&&d.parentNode){if(d.id!==c[2])return x.find(a);this.length=1,this[0]=d}return this.context=y,this.selector=a,this}return a.nodeType?(this.context=this[0]=a,this.length=1,this):m.isFunction(a)?"undefined"!=typeof x.ready?x.ready(a):a(m):(void 0!==a.selector&&(this.selector=a.selector,this.context=a.context),m.makeArray(a,this))};A.prototype=m.fn,x=m(y);
var B=/^(?:parents|prev(?:Until|All))/,C={children:!0,contents:!0,next:!0,prev:!0};m.extend({dir:function(a,b,c){var d=[],e=a[b];while(e&&9!==e.nodeType&&(void 0===c||1!==e.nodeType||!m(e).is(c)))1===e.nodeType&&d.push(e),e=e[b];return d},sibling:function(a,b){for(var c=[];a;a=a.nextSibling)1===a.nodeType&&a!==b&&c.push(a);return c}}),m.fn.extend({has:function(a){var b,c=m(a,this),d=c.length;return this.filter(function(){for(b=0;d>b;b++)if(m.contains(this,c[b]))return!0})},closest:function(a,b){for(var c,d=0,e=this.length,f=[],g=t.test(a)||"string"!=typeof a?m(a,b||this.context):0;e>d;d++)for(c=this[d];c&&c!==b;c=c.parentNode)if(c.nodeType<11&&(g?g.index(c)>-1:1===c.nodeType&&m.find.matchesSelector(c,a))){f.push(c);break}return this.pushStack(f.length>1?m.unique(f):f)},index:function(a){return a?"string"==typeof a?m.inArray(this[0],m(a)):m.inArray(a.jquery?a[0]:a,this):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(a,b){return this.pushStack(m.unique(m.merge(this.get(),m(a,b))))},addBack:function(a){return this.add(null==a?this.prevObject:this.prevObject.filter(a))}});function D(a,b){do a=a[b];while(a&&1!==a.nodeType);return a}m.each({parent:function(a){var b=a.parentNode;return b&&11!==b.nodeType?b:null},parents:function(a){return m.dir(a,"parentNode")},parentsUntil:function(a,b,c){return m.dir(a,"parentNode",c)},next:function(a){return D(a,"nextSibling")},prev:function(a){return D(a,"previousSibling")},nextAll:function(a){return m.dir(a,"nextSibling")},prevAll:function(a){return m.dir(a,"previousSibling")},nextUntil:function(a,b,c)
{return m.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return m.dir(a,"previousSibling",c)},siblings:function(a){return m.sibling((a.parentNode||{}).firstChild,a)},children:function(a){return m.sibling(a.firstChild)},contents:function(a){return m.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:m.merge([],a.childNodes)}},function(a,b){m.fn[a]=function(c,d){var e=m.map(this,b,c);return"Until"!==a.slice(-5)&&(d=c),d&&"string"==typeof d&&(e=m.filter(d,e)),this.length>1&&(C[a]||(e=m.unique(e)),B.test(a)&&(e=e.reverse())),this.pushStack(e)}});var E=/\S+/g,F={};function G(a){var b=F[a]={};return m.each(a.match(E)||[],function(a,c){b[c]=!0}),b}m.Callbacks=function(a){a="string"==typeof a?F[a]||G(a):m.extend({},a);var b,c,d,e,f,g,h=[],i=!a.once&&[],j=function(l){for(c=a.memory&&l,d=!0,f=g||0,g=0,e=h.length,b=!0;h&&e>f;f++)if(h[f].apply(l[0],l[1])===!1&&a.stopOnFalse){c=!1;break}b=!1,h&&(i?i.length&&j(i.shift()):c?h=[]:k.disable())},k={add:function(){if(h){var d=h.length;!function f(b){m.each(b,function(b,c){var d=m.type(c);"function"===d?a.unique&&k.has(c)||h.push(c):c&&c.length&&"string"!==d&&f(c)})}(arguments),b?e=h.length:c&&(g=d,j(c))}return this},remove:function(){return h&&m.each(arguments,function(a,c){var d;while((d=m.inArray(c,h,d))>-1)h.splice(d,1),b&&(e>=d&&e--,f>=d&&f--)}),this},has:function(a){return a?m.inArray(a,h)>-1:!(!h||!h.length)},empty:function(){return h=[],e=0,this},disable:function(){return h=i=c=void 0,this},disabled:
function(){return!h},lock:function(){return i=void 0,c||k.disable(),this},locked:function(){return!i},fireWith:function(a,c){return!h||d&&!i||(c=c||[],c=[a,c.slice?c.slice():c],b?i.push(c):j(c)),this},fire:function(){return k.fireWith(this,arguments),this},fired:function(){return!!d}};return k},m.extend({Deferred:function(a){var b=[["resolve","done",m.Callbacks("once memory"),"resolved"],["reject","fail",m.Callbacks("once memory"),"rejected"],["notify","progress",m.Callbacks("memory")]],c="pending",d={state:function(){return c},always:function(){return e.done(arguments).fail(arguments),this},then:function(){var a=arguments;return m.Deferred(function(c){m.each(b,function(b,f){var g=m.isFunction(a[b])&&a[b];e[f[1]](function(){var a=g&&g.apply(this,arguments);a&&m.isFunction(a.promise)?a.promise().done(c.resolve).fail(c.reject).progress(c.notify):c[f[0]+"With"](this===d?c.promise():this,g?[a]:arguments)})}),a=null}).promise()},promise:function(a){return null!=a?m.extend(a,d):d}},e={};return d.pipe=d.then,m.each(b,function(a,f){var g=f[2],h=f[3];d[f[1]]=g.add,h&&g.add(function(){c=h},b[1^a][2].disable,b[2][2].lock),e[f[0]]=function(){return e[f[0]+"With"](this===e?d:this,arguments),this},e[f[0]+"With"]=g.fireWith}),d.promise(e),a&&a.call(e,e),e},when:function(a){var b=0,c=d.call(arguments),e=c.length,f=1!==e||a&&m.isFunction(a.promise)?e:0,g=1===f?a:m.Deferred(),h=function(a,b,c)
{return function(e){b[a]=this,c[a]=arguments.length>1?d.call(arguments):e,c===i?g.notifyWith(b,c):--f||g.resolveWith(b,c)}},i,j,k;if(e>1)for(i=new Array(e),j=new Array(e),k=new Array(e);e>b;b++)c[b]&&m.isFunction(c[b].promise)?c[b].promise().done(h(b,k,c)).fail(g.reject).progress(h(b,j,i)):--f;return f||g.resolveWith(k,c),g.promise()}});var H;m.fn.ready=function(a){return m.ready.promise().done(a),this},m.extend({isReady:!1,readyWait:1,holdReady:function(a){a?m.readyWait++:m.ready(!0)},ready:function(a){if(a===!0?!--m.readyWait:!m.isReady){if(!y.body)return setTimeout(m.ready);m.isReady=!0,a!==!0&&--m.readyWait>0||(H.resolveWith(y,[m]),m.fn.triggerHandler&&(m(y).triggerHandler("ready"),m(y).off("ready")))}}});function I(){y.addEventListener?(y.removeEventListener("DOMContentLoaded",J,!1),a.removeEventListener("load",J,!1)):(y.detachEvent("onreadystatechange",J),a.detachEvent("onload",J))}function J(){(y.addEventListener||"load"===event.type||"complete"===y.readyState)&&(I(),m.ready())}m.ready.promise=function(b){if(!H)if(H=m.Deferred(),"complete"===y.readyState)setTimeout(m.ready);else if(y.addEventListener)y.addEventListener("DOMContentLoaded",J,!1),a.addEventListener("load",J,!1);else{y.attachEvent("onreadystatechange",J),a.attachEvent("onload",J);var c=!1;try{c=null==a.frameElement&&y.documentElement}catch(d){}c&&c.doScroll&&!function e(){if(!m.isReady){try{c.doScroll("left")}catch(a){return setTimeout(e,50)}I(),m.ready()}}()}return H.promise(b)};var K="undefined",L;for(L in m(k))break;k.ownLast="0"!==L,k.inlineBlockNeedsLayout=!1,m(function(){var a,b,c,d;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="display:inline;margin:0;border:0;padding:1px;width:1px;zoom:1",k.inlineBlockNeedsLayout=a=3===b.offsetWidth,a&&(c.style.zoom=1)),c.removeChild(d))}),function(){var a=y.createElement("div");
if(null==k.deleteExpando){k.deleteExpando=!0;try{delete a.test}catch(b){k.deleteExpando=!1}}a=null}(),m.acceptData=function(a){var b=m.noData[(a.nodeName+" ").toLowerCase()],c=+a.nodeType||1;return 1!==c&&9!==c?!1:!b||b!==!0&&a.getAttribute("classid")===b};var M=/^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,N=/([A-Z])/g;function O(a,b,c){if(void 0===c&&1===a.nodeType){var d="data-"+b.replace(N,"-$1").toLowerCase();if(c=a.getAttribute(d),"string"==typeof c){try{c="true"===c?!0:"false"===c?!1:"null"===c?null:+c+""===c?+c:M.test(c)?m.parseJSON(c):c}catch(e){}m.data(a,b,c)}else c=void 0}return c}`' ||
q'`function P(a){var b;for(b in a)if(("data"!==b||!m.isEmptyObject(a[b]))&&"toJSON"!==b)return!1;return!0}function Q(a,b,d,e){if(m.acceptData(a)){var f,g,h=m.expando,i=a.nodeType,j=i?m.cache:a,k=i?a[h]:a[h]&&h;if(k&&j[k]&&(e||j[k].data)||void 0!==d||"string"!=typeof b)return k||(k=i?a[h]=c.pop()||m.guid++:h),j[k]||(j[k]=i?{}:{toJSON:m.noop}),("object"==typeof b||"function"==typeof b)&&(e?j[k]=m.extend(j[k],b):j[k].data=m.extend(j[k].data,b)),g=j[k],e||(g.data||(g.data={}),g=g.data),void 0!==d&&(g[m.camelCase(b)]=d),"string"==typeof b?(f=g[b],null==f&&(f=g[m.camelCase(b)])):f=g,f}}function R(a,b,c){if(m.acceptData(a)){var d,e,f=a.nodeType,g=f?m.cache:a,h=f?a[m.expando]:m.expando;if(g[h]){if(b&&(d=c?g[h]:g[h].data)){m.isArray(b)?b=b.concat(m.map(b,m.camelCase)):b in d?b=[b]:(b=m.camelCase(b),b=b in d?[b]:b.split(" ")),e=b.length;while(e--)delete d[b[e]];if(c?!P(d):!m.isEmptyObject(d))return}(c||(delete g[h].data,P(g[h])))&&(f?m.cleanData([a],!0):k.deleteExpando||g!=g.window?delete g[h]:g[h]=null)}}}m.extend({cache:{},noData:{"applet ":!0,"embed ":!0,"object ":"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"},hasData:function(a)
{return a=a.nodeType?m.cache[a[m.expando]]:a[m.expando],!!a&&!P(a)},data:function(a,b,c){return Q(a,b,c)},removeData:function(a,b){return R(a,b)},_data:function(a,b,c){return Q(a,b,c,!0)},_removeData:function(a,b){return R(a,b,!0)}}),m.fn.extend({data:function(a,b){var c,d,e,f=this[0],g=f&&f.attributes;if(void 0===a){if(this.length&&(e=m.data(f),1===f.nodeType&&!m._data(f,"parsedAttrs"))){c=g.length;while(c--)g[c]&&(d=g[c].name,0===d.indexOf("data-")&&(d=m.camelCase(d.slice(5)),O(f,d,e[d])));m._data(f,"parsedAttrs",!0)}return e}return"object"==typeof a?this.each(function(){m.data(this,a)}):arguments.length>1?this.each(function(){m.data(this,a,b)}):f?O(f,a,m.data(f,a)):void 0},removeData:function(a){return this.each(function(){m.removeData(this,a)})}}),m.extend({queue:function(a,b,c){var d;return a?(b=(b||"fx")+"queue",d=m._data(a,b),c&&(!d||m.isArray(c)?d=m._data(a,b,m.makeArray(c)):d.push(c)),d||[]):void 0},dequeue:function(a,b){b=b||"fx";var c=m.queue(a,b),d=c.length,e=c.shift(),f=m._queueHooks(a,b),g=function(){m.dequeue(a,b)};"inprogress"===e&&(e=c.shift(),d--),e&&("fx"===b&&c.unshift("inprogress"),delete f.stop,e.call(a,g,f)),!d&&f&&f.empty.fire()},_queueHooks:function(a,b){var c=b+"queueHooks";return m._data(a,c)||m._data(a,c,{empty:m.Callbacks("once memory").add(function(){m._removeData(a,b+"queue"),m._removeData(a,c)})})}}),m.fn.extend({queue:function(a,b){var c=2;return"string"!=typeof a&&(b=a,a="fx",c--),arguments.length<c?m.queue(this[0],a):void 0===b?this:this.each(function(){var c=m.queue(this,a,b);
m._queueHooks(this,a),"fx"===a&&"inprogress"!==c[0]&&m.dequeue(this,a)})},dequeue:function(a){return this.each(function(){m.dequeue(this,a)})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,b){var c,d=1,e=m.Deferred(),f=this,g=this.length,h=function(){--d||e.resolveWith(f,[f])};"string"!=typeof a&&(b=a,a=void 0),a=a||"fx";while(g--)c=m._data(f[g],a+"queueHooks"),c&&c.empty&&(d++,c.empty.add(h));return h(),e.promise(b)}});var S=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,T=["Top","Right","Bottom","Left"],U=function(a,b){return a=b||a,"none"===m.css(a,"display")||!m.contains(a.ownerDocument,a)},V=m.access=function(a,b,c,d,e,f,g){var h=0,i=a.length,j=null==c;if("object"===m.type(c)){e=!0;for(h in c)m.access(a,b,h,c[h],!0,f,g)}else if(void 0!==d&&(e=!0,m.isFunction(d)||(g=!0),j&&(g?(b.call(a,d),b=null):(j=b,b=function(a,b,c){return j.call(m(a),c)})),b))for(;i>h;h++)b(a[h],c,g?d:d.call(a[h],h,b(a[h],c)));return e?a:j?b.call(a):i?b(a[0],c):f},W=/^(?:checkbox|radio)$/i;!function(){var a=y.createElement("input"),b=y.createElement("div"),c=y.createDocumentFragment();
if(b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",k.leadingWhitespace=3===b.firstChild.nodeType,k.tbody=!b.getElementsByTagName("tbody").length,k.htmlSerialize=!!b.getElementsByTagName("link").length,k.html5Clone="<:nav></:nav>"!==y.createElement("nav").cloneNode(!0).outerHTML,a.type="checkbox",a.checked=!0,c.appendChild(a),k.appendChecked=a.checked,b.innerHTML="<textarea>x</textarea>",k.noCloneChecked=!!b.cloneNode(!0).lastChild.defaultValue,c.appendChild(b),b.innerHTML="<input type='radio' checked='checked' name='t'/>",k.checkClone=b.cloneNode(!0).cloneNode(!0).lastChild.checked,k.noCloneEvent=!0,b.attachEvent&&(b.attachEvent("onclick",function(){k.noCloneEvent=!1}),b.cloneNode(!0).click()),null==k.deleteExpando){k.deleteExpando=!0;try{delete b.test}catch(d){k.deleteExpando=!1}}}(),function(){var b,c,d=y.createElement("div");for(b in{submit:!0,change:!0,focusin:!0})c="on"+b,(k[b+"Bubbles"]=c in a)||(d.setAttribute(c,"t"),k[b+"Bubbles"]=d.attributes[c].expando===!1);d=null}();var X=/^(?:input|select|textarea)$/i,Y=/^key/,Z=/^(?:mouse|pointer|contextmenu)|click/,$=/^(?:focusinfocus|focusoutblur)$/,_=/^([^.]*)(?:\.(.+)|)$/;function ab(){return!0}
function bb(){return!1}function cb(){try{return y.activeElement}catch(a){}}m.event={global:{},add:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m._data(a);if(r){c.handler&&(i=c,c=i.handler,e=i.selector),c.guid||(c.guid=m.guid++),(g=r.events)||(g=r.events={}),(k=r.handle)||(k=r.handle=function(a){return typeof m===K||a&&m.event.triggered===a.type?void 0:m.event.dispatch.apply(k.elem,arguments)},k.elem=a),b=(b||"").match(E)||[""],h=b.length;while(h--)f=_.exec(b[h])||[],o=q=f[1],p=(f[2]||"").split(".").sort(),o&&(j=m.event.special[o]||{},o=(e?j.delegateType:j.bindType)||o,j=m.event.special[o]||{},l=m.extend({type:o,origType:q,data:d,handler:c,guid:c.guid,selector:e,needsContext:e&&m.expr.match.needsContext.test(e),namespace:p.join(".")},i),(n=g[o])||(n=g[o]=[],n.delegateCount=0,j.setup&&j.setup.call(a,d,p,k)!==!1||(a.addEventListener?a.addEventListener(o,k,!1):a.attachEvent&&a.attachEvent("on"+o,k))),j.add&&(j.add.call(a,l),l.handler.guid||(l.handler.guid=c.guid)),e?n.splice(n.delegateCount++,0,l):n.push(l),m.event.global[o]=!0);a=null}},remove:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m.hasData(a)&&m._data(a);if(r&&(k=r.events)){b=(b||"").match(E)||[""],j=b.length;while(j--)if(h=_.exec(b[j])||[],o=q=h[1],p=(h[2]||"").split(".").sort(),o){l=m.event.special[o]||{},o=(d?l.delegateType:l.bindType)||o,n=k[o]||[],h=h[2]&&new RegExp("(^|\\.)"+p.join("\\.(?:.*\\.|)")+"(\\.|$)"),i=f=n.length;while(f--)g=n[f],!e&&q!==g.origType||c&&c.guid!==g.guid||h&&!h.test(g.namespace)||d&&d!==g.selector&&("**"!==d||!g.selector)||(n.splice(f,1),g.selector&&n.delegateCount--,l.remove&&l.remove.call(a,g));
i&&!n.length&&(l.teardown&&l.teardown.call(a,p,r.handle)!==!1||m.removeEvent(a,o,r.handle),delete k[o])}else for(o in k)m.event.remove(a,o+b[j],c,d,!0);m.isEmptyObject(k)&&(delete r.handle,m._removeData(a,"events"))}},trigger:function(b,c,d,e){var f,g,h,i,k,l,n,o=[d||y],p=j.call(b,"type")?b.type:b,q=j.call(b,"namespace")?b.namespace.split("."):[];if(h=l=d=d||y,3!==d.nodeType&&8!==d.nodeType&&!$.test(p+m.event.triggered)&&(p.indexOf(".")>=0&&(q=p.split("."),p=q.shift(),q.sort()),g=p.indexOf(":")<0&&"on"+p,b=b[m.expando]?b:new m.Event(p,"object"==typeof b&&b),b.isTrigger=e?2:3,b.namespace=q.join("."),b.namespace_re=b.namespace?new RegExp("(^|\\.)"+q.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,b.result=void 0,b.target||(b.target=d),c=null==c?[b]:m.makeArray(c,[b]),k=m.event.special[p]||{},e||!k.trigger||k.trigger.apply(d,c)!==!1)){if(!e&&!k.noBubble&&!m.isWindow(d)){for(i=k.delegateType||p,$.test(i+p)||(h=h.parentNode);h;h=h.parentNode)o.push(h),l=h;l===(d.ownerDocument||y)&&o.push(l.defaultView||l.parentWindow||a)}n=0;while((h=o[n++])&&!b.isPropagationStopped())b.type=n>1?i:k.bindType||p,f=(m._data(h,"events")||{})[b.type]&&m._data(h,"handle"),f&&f.apply(h,c),f=g&&h[g],f&&f.apply&&m.acceptData(h)&&(b.result=f.apply(h,c),b.result===!1&&b.preventDefault());if(b.type=p,!e&&!b.isDefaultPrevented()&&(!k._default||k._default.apply(o.pop(),c)===!1)&&m.acceptData(d)&&g&&d[p]&&!m.isWindow(d)){l=d[g],l&&(d[g]=null),m.event.triggered=p;try{d[p]()}catch(r){}m.event.triggered=void 0,l&&(d[g]=l)}return b.result}},dispatch:function(a){a=m.event.fix(a);
var b,c,e,f,g,h=[],i=d.call(arguments),j=(m._data(this,"events")||{})[a.type]||[],k=m.event.special[a.type]||{};if(i[0]=a,a.delegateTarget=this,!k.preDispatch||k.preDispatch.call(this,a)!==!1){h=m.event.handlers.call(this,a,j),b=0;while((f=h[b++])&&!a.isPropagationStopped()){a.currentTarget=f.elem,g=0;while((e=f.handlers[g++])&&!a.isImmediatePropagationStopped())(!a.namespace_re||a.namespace_re.test(e.namespace))&&(a.handleObj=e,a.data=e.data,c=((m.event.special[e.origType]||{}).handle||e.handler).apply(f.elem,i),void 0!==c&&(a.result=c)===!1&&(a.preventDefault(),a.stopPropagation()))}return k.postDispatch&&k.postDispatch.call(this,a),a.result}},handlers:function(a,b){var c,d,e,f,g=[],h=b.delegateCount,i=a.target;if(h&&i.nodeType&&(!a.button||"click"!==a.type))for(;i!=this;i=i.parentNode||this)if(1===i.nodeType&&(i.disabled!==!0||"click"!==a.type)){for(e=[],f=0;h>f;f++)d=b[f],c=d.selector+" ",void 0===e[c]&&(e[c]=d.needsContext?m(c,this).index(i)>=0:m.find(c,this,null,[i]).length),e[c]&&e.push(d);e.length&&g.push({elem:i,handlers:e})}return h<b.length&&g.push({elem:this,handlers:b.slice(h)}),g},fix:function(a){if(a[m.expando])return a;var b,c,d,e=a.type,f=a,g=this.fixHooks[e];g||(this.fixHooks[e]=g=Z.test(e)?this.mouseHooks:Y.test(e)?this.keyHooks:{}),d=g.props?this.props.concat(g.props):this.props,a=new m.Event(f),b=d.length;while(b--)c=d[b],a[c]=f[c];return a.target||(a.target=f.srcElement||y),3===a.target.nodeType&&(a.target=a.target.parentNode),a.metaKey=!!a.metaKey,g.filter?g.filter(a,f):a},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){return null==a.which&&(a.which=null!=b.charCode?b.charCode:b.keyCode),a}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,b){var c,d,e,f=b.button,g=b.fromElement;
return null==a.pageX&&null!=b.clientX&&(d=a.target.ownerDocument||y,e=d.documentElement,c=d.body,a.pageX=b.clientX+(e&&e.scrollLeft||c&&c.scrollLeft||0)-(e&&e.clientLeft||c&&c.clientLeft||0),a.pageY=b.clientY+(e&&e.scrollTop||c&&c.scrollTop||0)-(e&&e.clientTop||c&&c.clientTop||0)),!a.relatedTarget&&g&&(a.relatedTarget=g===a.target?b.toElement:g),a.which||void 0===f||(a.which=1&f?1:2&f?3:4&f?2:0),a}},special:{load:{noBubble:!0},focus:{trigger:function(){if(this!==cb()&&this.focus)try{return this.focus(),!1}catch(a){}},delegateType:"focusin"},blur:{trigger:function(){return this===cb()&&this.blur?(this.blur(),!1):void 0},delegateType:"focusout"},click:{trigger:function(){return m.nodeName(this,"input")&&"checkbox"===this.type&&this.click?(this.click(),!1):void 0},_default:function(a){return m.nodeName(a.target,"a")}},beforeunload:{postDispatch:function(a){void 0!==a.result&&a.originalEvent&&(a.originalEvent.returnValue=a.result)}}},simulate:function(a,b,c,d){var e=m.extend(new m.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?m.event.trigger(e,null,b):m.event.dispatch.call(b,e),e.isDefaultPrevented()&&c.preventDefault()}},m.removeEvent=y.removeEventListener?function(a,b,c){a.removeEventListener&&a.removeEventListener(b,c,!1)}:function(a,b,c){var d="on"+b;a.detachEvent&&(typeof a[d]===K&&(a[d]=null),a.detachEvent(d,c))},m.Event=function(a,b){return this instanceof m.Event?(a&&a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||void 0===a.defaultPrevented&&a.returnValue===!1?ab:bb):this.type=a,b&&m.extend(this,b),this.timeStamp=a&&a.timeStamp||m.now(),void(this[m.expando]=!0)):new m.Event(a,b)},m.Event.prototype={isDefaultPrevented:bb,isPropagationStopped:bb,isImmediatePropagationStopped:bb,preventDefault:function(){var a=this.originalEvent;this.isDefaultPrevented=ab,a&&(a.preventDefault?a.preventDefault():a.returnValue=!1)},stopPropagation:function(){var a=this.originalEvent;this.isPropagationStopped=ab,a&&(a.stopPropagation&&a.stopPropagation(),a.cancelBubble=!0)},stopImmediatePropagation:function(){var a=this.originalEvent;
this.isImmediatePropagationStopped=ab,a&&a.stopImmediatePropagation&&a.stopImmediatePropagation(),this.stopPropagation()}},m.each({mouseenter:"mouseover",mouseleave:"mouseout",pointerenter:"pointerover",pointerleave:"pointerout"},function(a,b){m.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c,d=this,e=a.relatedTarget,f=a.handleObj;return(!e||e!==d&&!m.contains(d,e))&&(a.type=f.origType,c=f.handler.apply(this,arguments),a.type=b),c}}}),k.submitBubbles||(m.event.special.submit={setup:function(){return m.nodeName(this,"form")?!1:void m.event.add(this,"click._submit keypress._submit",function(a){var b=a.target,c=m.nodeName(b,"input")||m.nodeName(b,"button")?b.form:void 0;c&&!m._data(c,"submitBubbles")&&(m.event.add(c,"submit._submit",function(a){a._submit_bubble=!0}),m._data(c,"submitBubbles",!0))})},postDispatch:function(a){a._submit_bubble&&(delete a._submit_bubble,this.parentNode&&!a.isTrigger&&m.event.simulate("submit",this.parentNode,a,!0))},teardown:
function(){return m.nodeName(this,"form")?!1:void m.event.remove(this,"._submit")}}),k.changeBubbles||(m.event.special.change={setup:function(){return X.test(this.nodeName)?(("checkbox"===this.type||"radio"===this.type)&&(m.event.add(this,"propertychange._change",function(a){"checked"===a.originalEvent.propertyName&&(this._just_changed=!0)}),m.event.add(this,"click._change",function(a){this._just_changed&&!a.isTrigger&&(this._just_changed=!1),m.event.simulate("change",this,a,!0)})),!1):void m.event.add(this,"beforeactivate._change",function(a){var b=a.target;X.test(b.nodeName)&&!m._data(b,"changeBubbles")&&(m.event.add(b,"change._change",function(a){!this.parentNode||a.isSimulated||a.isTrigger||m.event.simulate("change",this.parentNode,a,!0)}),m._data(b,"changeBubbles",!0))})},handle:function(a){var b=a.target;return this!==b||a.isSimulated||a.isTrigger||"radio"!==b.type&&"checkbox"!==b.type?a.handleObj.handler.apply(this,arguments):void 0},teardown:function(){return m.event.remove(this,"._change"),!X.test(this.nodeName)}}),k.focusinBubbles||m.each({focus:"focusin",blur:"focusout"},function(a,b){var c=function(a){m.event.simulate(b,a.target,m.event.fix(a),!0)};
m.event.special[b]={setup:function(){var d=this.ownerDocument||this,e=m._data(d,b);e||d.addEventListener(a,c,!0),m._data(d,b,(e||0)+1)},teardown:function(){var d=this.ownerDocument||this,e=m._data(d,b)-1;e?m._data(d,b,e):(d.removeEventListener(a,c,!0),m._removeData(d,b))}}}),m.fn.extend({on:function(a,b,c,d,e){var f,g;if("object"==typeof a){"string"!=typeof b&&(c=c||b,b=void 0);for(f in a)this.on(f,b,c,a[f],e);return this}if(null==c&&null==d?(d=b,c=b=void 0):null==d&&("string"==typeof b?(d=c,c=void 0):(d=c,c=b,b=void 0)),d===!1)d=bb;else if(!d)return this;return 1===e&&(g=d,d=function(a){return m().off(a),g.apply(this,arguments)},d.guid=g.guid||(g.guid=m.guid++)),this.each(function(){m.event.add(this,a,d,c,b)})},one:function(a,b,c,d){return this.on(a,b,c,d,1)},off:function(a,b,c){var d,e;if(a&&a.preventDefault&&a.handleObj)return d=a.handleObj,m(a.delegateTarget).off(d.namespace?d.origType+"."+d.namespace:d.origType,d.selector,d.handler),this;if("object"==typeof a){for(e in a)this.off(e,b,a[e]);
return this}return(b===!1||"function"==typeof b)&&(c=b,b=void 0),c===!1&&(c=bb),this.each(function(){m.event.remove(this,a,c,b)})},trigger:function(a,b){return this.each(function(){m.event.trigger(a,b,this)})},triggerHandler:function(a,b){var c=this[0];return c?m.event.trigger(a,b,c,!0):void 0}});function db(a){var b=eb.split("|"),c=a.createDocumentFragment();if(c.createElement)while(b.length)c.createElement(b.pop());return c}var eb="abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",fb=/ jQuery\d+="(?:null|\d+)"/g,gb=new RegExp("<(?:"+eb+")[\\s/>]","i"),hb=/^\s+/,ib=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,jb=/<([\w:]+)/,kb=/<tbody/i,lb=/<|&#?\w+;/,mb=/<(?:script|style|link)/i,nb=/checked\s*(?:[^=]|=\s*.checked.)/i,ob=/^$|\/(?:java|ecma)script/i,pb=/^true\/(.*)/,qb=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,rb={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],area:[1,"<map>","</map>"],param:[1,"<object>","</object>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:k.htmlSerialize?[0,"",""]:[1,"X<div>","</div>"]},sb=db(y),tb=sb.appendChild(y.createElement("div"));rb.optgroup=rb.option,rb.tbody=rb.tfoot=rb.colgroup=rb.caption=rb.thead,rb.th=rb.td;function ub(a,b){var c,d,e=0,f=typeof a.getElementsByTagName!==K?a.getElementsByTagName(b||"*"):typeof a.querySelectorAll!==K?a.querySelectorAll(b||"*"):void 0;if(!f)for(f=[],c=a.childNodes||a;null!=(d=c[e]);
e++)!b||m.nodeName(d,b)?f.push(d):m.merge(f,ub(d,b));return void 0===b||b&&m.nodeName(a,b)?m.merge([a],f):f}function vb(a){W.test(a.type)&&(a.defaultChecked=a.checked)}function wb(a,b){return m.nodeName(a,"table")&&m.nodeName(11!==b.nodeType?b:b.firstChild,"tr")?a.getElementsByTagName("tbody")[0]||a.appendChild(a.ownerDocument.createElement("tbody")):a}function xb(a){return a.type=(null!==m.find.attr(a,"type"))+"/"+a.type,a}function yb(a){var b=pb.exec(a.type);return b?a.type=b[1]:a.removeAttribute("type"),a}function zb(a,b){for(var c,d=0;null!=(c=a[d]);d++)m._data(c,"globalEval",!b||m._data(b[d],"globalEval"))}function Ab(a,b){if(1===b.nodeType&&m.hasData(a)){var c,d,e,f=m._data(a),g=m._data(b,f),h=f.events;if(h){delete g.handle,g.events={};for(c in h)for(d=0,e=h[c].length;e>d;d++)m.event.add(b,c,h[c][d])}g.data&&(g.data=m.extend({},g.data))}}function Bb(a,b){var c,d,e;if(1===b.nodeType){if(c=b.nodeName.toLowerCase(),!k.noCloneEvent&&b[m.expando]){e=m._data(b);for(d in e.events)m.removeEvent(b,d,e.handle);b.removeAttribute(m.expando)}"script"===c&&b.text!==a.text?(xb(b).text=a.text,yb(b)):"object"===c?(b.parentNode&&(b.outerHTML=a.outerHTML),k.html5Clone&&a.innerHTML&&!m.trim(b.innerHTML)&&(b.innerHTML=a.innerHTML)):"input"===c&&W.test(a.type)?(b.defaultChecked=b.checked=a.checked,b.value!==a.value&&(b.value=a.value)):"option"===c?b.defaultSelected=b.selected=a.defaultSelected:("input"===c||"textarea"===c)&&(b.defaultValue=a.defaultValue)}}
m.extend({clone:function(a,b,c){var d,e,f,g,h,i=m.contains(a.ownerDocument,a);if(k.html5Clone||m.isXMLDoc(a)||!gb.test("<"+a.nodeName+">")?f=a.cloneNode(!0):(tb.innerHTML=a.outerHTML,tb.removeChild(f=tb.firstChild)),!(k.noCloneEvent&&k.noCloneChecked||1!==a.nodeType&&11!==a.nodeType||m.isXMLDoc(a)))for(d=ub(f),h=ub(a),g=0;null!=(e=h[g]);++g)d[g]&&Bb(e,d[g]);if(b)if(c)for(h=h||ub(a),d=d||ub(f),g=0;null!=(e=h[g]);g++)Ab(e,d[g]);else Ab(a,f);return d=ub(f,"script"),d.length>0&&zb(d,!i&&ub(a,"script")),d=h=e=null,f},buildFragment:function(a,b,c,d){for(var e,f,g,h,i,j,l,n=a.length,o=db(b),p=[],q=0;n>q;q++)if(f=a[q],f||0===f)if("object"===m.type(f))m.merge(p,f.nodeType?[f]:f);else if(lb.test(f)){h=h||o.appendChild(b.createElement("div")),i=(jb.exec(f)||["",""])[1].toLowerCase(),l=rb[i]||rb._default,h.innerHTML=l[1]+f.replace(ib,"<$1></$2>")+l[2],e=l[0];while(e--)h=h.lastChild;if(!k.leadingWhitespace&&hb.test(f)&&p.push(b.createTextNode(hb.exec(f)[0])),!k.tbody){f="table"!==i||kb.test(f)?"<table>"!==l[1]||kb.test(f)?0:h:h.firstChild,e=f&&f.childNodes.length;while(e--)m.nodeName(j=f.childNodes[e],"tbody")&&!j.childNodes.length&&f.removeChild(j)}m.merge(p,h.childNodes),h.textContent="";while(h.firstChild)h.removeChild(h.firstChild);h=o.lastChild}else p.push(b.createTextNode(f));
h&&o.removeChild(h),k.appendChecked||m.grep(ub(p,"input"),vb),q=0;while(f=p[q++])if((!d||-1===m.inArray(f,d))&&(g=m.contains(f.ownerDocument,f),h=ub(o.appendChild(f),"script"),g&&zb(h),c)){e=0;while(f=h[e++])ob.test(f.type||"")&&c.push(f)}return h=null,o},cleanData:function(a,b){for(var d,e,f,g,h=0,i=m.expando,j=m.cache,l=k.deleteExpando,n=m.event.special;null!=(d=a[h]);h++)if((b||m.acceptData(d))&&(f=d[i],g=f&&j[f])){if(g.events)for(e in g.events)n[e]?m.event.remove(d,e):m.removeEvent(d,e,g.handle);j[f]&&(delete j[f],l?delete d[i]:typeof d.removeAttribute!==K?d.removeAttribute(i):d[i]=null,c.push(f))}}}),m.fn.extend({text:function(a){return V(this,function(a){return void 0===a?m.text(this):this.empty().append((this[0]&&this[0].ownerDocument||y).createTextNode(a))},null,a,arguments.length)},append:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wb(this,a);b.appendChild(a)}})},prepend:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wb(this,a);b.insertBefore(a,b.firstChild)}})},before:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this)})},after:function(){return this.domManip(arguments,
function(a){this.parentNode&&this.parentNode.insertBefore(a,this.nextSibling)})},remove:function(a,b){for(var c,d=a?m.filter(a,this):this,e=0;null!=(c=d[e]);e++)b||1!==c.nodeType||m.cleanData(ub(c)),c.parentNode&&(b&&m.contains(c.ownerDocument,c)&&zb(ub(c,"script")),c.parentNode.removeChild(c));return this},empty:function(){for(var a,b=0;null!=(a=this[b]);b++){1===a.nodeType&&m.cleanData(ub(a,!1));while(a.firstChild)a.removeChild(a.firstChild);a.options&&m.nodeName(a,"select")&&(a.options.length=0)}return this},clone:function(a,b){return a=null==a?!1:a,b=null==b?a:b,this.map(function(){return m.clone(this,a,b)})},html:function(a){return V(this,function(a){var b=this[0]||{},c=0,d=this.length;if(void 0===a)return 1===b.nodeType?b.innerHTML.replace(fb,""):void 0;if(!("string"!=typeof a||mb.test(a)||!k.htmlSerialize&&gb.test(a)||!k.leadingWhitespace&&hb.test(a)||rb[(jb.exec(a)||["",""])[1].toLowerCase()])){a=a.replace(ib,"<$1></$2>");try{for(;d>c;c++)b=this[c]||{},1===b.nodeType&&(m.cleanData(ub(b,!1)),b.innerHTML=a);b=0}catch(e){}}b&&this.empty().append(a)},null,a,arguments.length)},replaceWith:function(){var a=arguments[0];
return this.domManip(arguments,function(b){a=this.parentNode,m.cleanData(ub(this)),a&&a.replaceChild(b,this)}),a&&(a.length||a.nodeType)?this:this.remove()},detach:function(a){return this.remove(a,!0)},domManip:function(a,b){a=e.apply([],a);var c,d,f,g,h,i,j=0,l=this.length,n=this,o=l-1,p=a[0],q=m.isFunction(p);if(q||l>1&&"string"==typeof p&&!k.checkClone&&nb.test(p))return this.each(function(c){var d=n.eq(c);q&&(a[0]=p.call(this,c,d.html())),d.domManip(a,b)});if(l&&(i=m.buildFragment(a,this[0].ownerDocument,!1,this),c=i.firstChild,1===i.childNodes.length&&(i=c),c)){for(g=m.map(ub(i,"script"),xb),f=g.length;l>j;j++)d=i,j!==o&&(d=m.clone(d,!0,!0),f&&m.merge(g,ub(d,"script"))),b.call(this[j],d,j);if(f)for(h=g[g.length-1].ownerDocument,m.map(g,yb),j=0;f>j;j++)d=g[j],ob.test(d.type||"")&&!m._data(d,"globalEval")&&m.contains(h,d)&&(d.src?m._evalUrl&&m._evalUrl(d.src):m.globalEval((d.text||d.textContent||d.innerHTML||"").replace(qb,"")));i=c=null}return this}}),m.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){m.fn[a]=function(a){for(var c,d=0,e=[],g=m(a),h=g.length-1;h>=d;d++)c=d===h?this:this.clone(!0),m(g[d])[b](c),f.apply(e,c.get());return this.pushStack(e)}});var Cb,Db={};
function Eb(b,c){var d,e=m(c.createElement(b)).appendTo(c.body),f=a.getDefaultComputedStyle&&(d=a.getDefaultComputedStyle(e[0]))?d.display:m.css(e[0],"display");return e.detach(),f}function Fb(a){var b=y,c=Db[a];return c||(c=Eb(a,b),"none"!==c&&c||(Cb=(Cb||m("<iframe frameborder='0' width='0' height='0'/>")).appendTo(b.documentElement),b=(Cb[0].contentWindow||Cb[0].contentDocument).document,b.write(),b.close(),c=Eb(a,b),Cb.detach()),Db[a]=c),c}!function(){var a;k.shrinkWrapBlocks=function(){if(null!=a)return a;a=!1;var b,c,d;return c=y.getElementsByTagName("body")[0],c&&c.style?(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:1px;width:1px;zoom:1",b.appendChild(y.createElement("div")).style.width="5px",a=3!==b.offsetWidth),c.removeChild(d),a):void 0}}();
var Gb=/^margin/,Hb=new RegExp("^("+S+")(?!px)[a-z%]+$","i"),Ib,Jb,Kb=/^(top|right|bottom|left)$/;a.getComputedStyle?(Ib=function(a){return a.ownerDocument.defaultView.getComputedStyle(a,null)},Jb=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ib(a),g=c?c.getPropertyValue(b)||c[b]:void 0,c&&(""!==g||m.contains(a.ownerDocument,a)||(g=m.style(a,b)),Hb.test(g)&&Gb.test(b)&&(d=h.width,e=h.minWidth,f=h.maxWidth,h.minWidth=h.maxWidth=h.width=g,g=c.width,h.width=d,h.minWidth=e,h.maxWidth=f)),void 0===g?g:g+""}):y.documentElement.currentStyle&&(Ib=function(a){return a.currentStyle},Jb=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ib(a),g=c?c[b]:void 0,null==g&&h&&h[b]&&(g=h[b]),Hb.test(g)&&!Kb.test(b)&&(d=h.left,e=a.runtimeStyle,f=e&&e.left,f&&(e.left=a.currentStyle.left),h.left="fontSize"===b?"1em":g,g=h.pixelLeft+"px",h.left=d,f&&(e.left=f)),void 0===g?g:g+""||"auto"});function Lb(a,b){return{get:
function(){var c=a();if(null!=c)return c?void delete this.get:(this.get=b).apply(this,arguments)}}}!function(){var b,c,d,e,f,g,h;if(b=y.createElement("div"),b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",d=b.getElementsByTagName("a")[0],c=d&&d.style){c.cssText="float:left;opacity:.5",k.opacity="0.5"===c.opacity,k.cssFloat=!!c.cssFloat,b.style.backgroundClip="content-box",b.cloneNode(!0).style.backgroundClip="",k.clearCloneStyle="content-box"===b.style.backgroundClip,k.boxSizing=""===c.boxSizing||""===c.MozBoxSizing||""===c.WebkitBoxSizing,m.extend(k,{reliableHiddenOffsets:function(){return null==g&&i(),g},boxSizingReliable:function(){return null==f&&i(),f},pixelPosition:function(){return null==e&&i(),e},reliableMarginRight:function(){return null==h&&i(),h}});function i(){var b,c,d,i;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),b.style.cssText="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;display:block;margin-top:1%;top:1%;border:1px;padding:1px;width:4px;position:absolute",e=f=!1,h=!0,a.getComputedStyle&&(e="1%"!==(a.getComputedStyle(b,null)||{}).top,f="4px"===(a.getComputedStyle(b,null)||{width:"4px"}).width,i=b.appendChild(y.createElement("div")),i.style.cssText=b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:0",i.style.marginRight=i.style.width="0",b.style.width="1px",h=!parseFloat((a.getComputedStyle(i,null)||{}).marginRight)),b.innerHTML="<table><tr><td></td><td>t</td></tr></table>",i=b.getElementsByTagName("td"),i[0].style.cssText="margin:0;border:0;padding:0;display:none",g=0===i[0].offsetHeight,g&&(i[0].style.display="",i[1].style.display="none",g=0===i[0].offsetHeight),c.removeChild(d))}}}(),m.swap=function(a,b,c,d){var e,f,g={};for(f in b)g[f]=a.style[f],a.style[f]=b[f];e=c.apply(a,d||[]);for(f in b)a.style[f]=g[f];return e};var Mb=/alpha\([^)]*\)/i,Nb=/opacity\s*=\s*([^)]*)/,Ob=/^(none|table(?!-c[ea]).+)/,Pb=new RegExp("^("+S+")(.*)$","i"),Qb=new RegExp("^([+-])=("+S+")","i"),Rb={position:"absolute",visibility:"hidden",display:"block"},Sb={letterSpacing:"0",fontWeight:"400"},Tb=["Webkit","O","Moz","ms"];function Ub(a,b){if(b in a)return b;var c=b.charAt(0).
toUpperCase()+b.slice(1),d=b,e=Tb.length;while(e--)if(b=Tb[e]+c,b in a)return b;return d}function Vb(a,b){for(var c,d,e,f=[],g=0,h=a.length;h>g;g++)d=a[g],d.style&&(f[g]=m._data(d,"olddisplay"),c=d.style.display,b?(f[g]||"none"!==c||(d.style.display=""),""===d.style.display&&U(d)&&(f[g]=m._data(d,"olddisplay",Fb(d.nodeName)))):(e=U(d),(c&&"none"!==c||!e)&&m._data(d,"olddisplay",e?c:m.css(d,"display"))));for(g=0;h>g;g++)d=a[g],d.style&&(b&&"none"!==d.style.display&&""!==d.style.display||(d.style.display=b?f[g]||"":"none"));return a}function Wb(a,b,c){var d=Pb.exec(b);return d?Math.max(0,d[1]-(c||0))+(d[2]||"px"):b}function Xb(a,b,c,d,e){for(var f=c===(d?"border":"content")?4:"width"===b?1:0,g=0;4>f;f+=2)"margin"===c&&(g+=m.css(a,c+T[f],!0,e)),d?("content"===c&&(g-=m.css(a,"padding"+T[f],!0,e)),"margin"!==c&&(g-=m.css(a,"border"+T[f]+"Width",!0,e))):(g+=m.css(a,"padding"+T[f],!0,e),"padding"!==c&&(g+=m.css(a,"border"+T[f]+"Width",!0,e)));return g}function Yb(a,b,c){var d=!0,e="width"===b?a.offsetWidth:a.offsetHeight,f=Ib(a),g=k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,f);if(0>=e||null==e){if(e=Jb(a,b,f),(0>e||null==e)&&(e=a.style[b]),Hb.test(e))return e;d=g&&(k.boxSizingReliable()||e===a.style[b]),e=parseFloat(e)||0}return e+Xb(a,b,c||(g?"border":"content"),d,f)+"px"}m.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=Jb(a,"opacity");return""===c?"1":c}}}},cssNumber:{columnCount:!0,fillOpacity:!0,flexGrow:!0,flexShrink:!0,fontWeight:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":k.cssFloat?"cssFloat":"styleFloat"},style:function(a,b,c,d){if(a&&3!==a.nodeType&&8!==a.nodeType&&a.style){var e,f,g,h=m.camelCase(b),i=a.style;
if(b=m.cssProps[h]||(m.cssProps[h]=Ub(i,h)),g=m.cssHooks[b]||m.cssHooks[h],void 0===c)return g&&"get"in g&&void 0!==(e=g.get(a,!1,d))?e:i[b];if(f=typeof c,"string"===f&&(e=Qb.exec(c))&&(c=(e[1]+1)*e[2]+parseFloat(m.css(a,b)),f="number"),null!=c&&c===c&&("number"!==f||m.cssNumber[h]||(c+="px"),k.clearCloneStyle||""!==c||0!==b.indexOf("background")||(i[b]="inherit"),!(g&&"set"in g&&void 0===(c=g.set(a,c,d)))))try{i[b]=c}catch(j){}}},css:function(a,b,c,d){var e,f,g,h=m.camelCase(b);return b=m.cssProps[h]||(m.cssProps[h]=Ub(a.style,h)),g=m.cssHooks[b]||m.cssHooks[h],g&&"get"in g&&(f=g.get(a,!0,c)),void 0===f&&(f=Jb(a,b,d)),"normal"===f&&b in Sb&&(f=Sb[b]),""===c||c?(e=parseFloat(f),c===!0||m.isNumeric(e)?e||0:f):f}}),m.each(["height","width"],function(a,b){m.cssHooks[b]={get:function(a,c,d){return c?Ob.test(m.css(a,"display"))&&0===a.offsetWidth?m.swap(a,Rb,function(){return Yb(a,b,d)}):Yb(a,b,d):void 0},set:function(a,c,d){var e=d&&Ib(a);return Wb(a,c,d?Xb(a,b,d,k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,e),e):0)}}}),k.opacity||(m.cssHooks.opacity={get:function(a,b){
return Nb.test((b&&a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?.01*parseFloat(RegExp.$1)+"":b?"1":""},set:function(a,b){var c=a.style,d=a.currentStyle,e=m.isNumeric(b)?"alpha(opacity="+100*b+")":"",f=d&&d.filter||c.filter||"";c.zoom=1,(b>=1||""===b)&&""===m.trim(f.replace(Mb,""))&&c.removeAttribute&&(c.removeAttribute("filter"),""===b||d&&!d.filter)||(c.filter=Mb.test(f)?f.replace(Mb,e):f+" "+e)}}),m.cssHooks.marginRight=Lb(k.reliableMarginRight,function(a,b){return b?m.swap(a,{display:"inline-block"},Jb,[a,"marginRight"]):void 0}),m.each({margin:"",padding:"",border:"Width"},function(a,b){m.cssHooks[a+b]={expand:function(c){for(var d=0,e={},f="string"==typeof c?c.split(" "):[c];4>d;d++)e[a+T[d]+b]=f[d]||f[d-2]||f[0];return e}},Gb.test(a)||(m.cssHooks[a+b].set=Wb)}),m.fn.extend({css:function(a,b){return V(this,function(a,b,c){var d,e,f={},g=0;if(m.isArray(b)){for(d=Ib(a),e=b.length;e>g;g++)f[b[g]]=m.css(a,b[g],!1,d);return f}return void 0!==c?m.style(a,b,c):m.css(a,b)},a,b,arguments.length>1)},show:function(){return Vb(this,!0)},hide:function(){return Vb(this)},toggle:function(a){return"boolean"==typeof a?a?this.show():this.hide():this.each(function()`' ||
q'`{U(this)?m(this).show():m(this).hide()})}});function Zb(a,b,c,d,e){return new Zb.prototype.init(a,b,c,d,e)}m.Tween=Zb,Zb.prototype={constructor:Zb,init:function(a,b,c,d,e,f){this.elem=a,this.prop=c,this.easing=e||"swing",this.options=b,this.start=this.now=this.cur(),this.end=d,this.unit=f||(m.cssNumber[c]?"":"px")
},cur:function(){var a=Zb.propHooks[this.prop];return a&&a.get?a.get(this):Zb.propHooks._default.get(this)},run:function(a){var b,c=Zb.propHooks[this.prop];return this.pos=b=this.options.duration?m.easing[this.easing](a,this.options.duration*a,0,1,this.options.duration):a,this.now=(this.end-this.start)*b+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),c&&c.set?c.set(this):Zb.propHooks._default.set(this),this}},Zb.prototype.init.prototype=Zb.prototype,Zb.propHooks={_default:{get:function(a){var b;return null==a.elem[a.prop]||a.elem.style&&null!=a.elem.style[a.prop]?(b=m.css(a.elem,a.prop,""),b&&"auto"!==b?b:0):a.elem[a.prop]},set:function(a){m.fx.step[a.prop]?m.fx.step[a.prop](a):a.elem.style&&(null!=a.elem.style[m.cssProps[a.prop]]||m.cssHooks[a.prop])?m.style(a.elem,a.prop,a.now+a.unit):a.elem[a.prop]=a.now}}},Zb.propHooks.scrollTop=Zb.propHooks.scrollLeft={set:function(a){a.elem.nodeType&&a.elem.parentNode&&(a.elem[a.prop]=a.now)}},m.easing={linear:function(a){return a},swing:function(a){return.5-Math.cos(a*Math.PI)/2}},m.fx=Zb.prototype.init,m.fx.step={};var $b,_b,ac=/^(?:toggle|show|hide)$/,bc=new RegExp("^(?:([+-])=|)("+S+")([a-z%]*)$","i"),cc=/queueHooks$/,dc=[ic],ec={"*":[function(a,b){var c=this.createTween(a,b),d=c.cur(),e=bc.exec(b),f=e&&e[3]||(m.cssNumber[a]?"":"px"),g=(m.cssNumber[a]||"px"!==f&&+d)&&bc.exec(m.css(c.elem,a)),h=1,i=20;if(g&&g[3]!==f){f=f||g[3],e=e||[],g=+d||1;do h=h||".5",g/=h,m.style(c.elem,a,g+f);while(h!==(h=c.cur()/d)&&1!==h&&--i)}return e&&(g=c.start=+g||+d||0,c.unit=f,c.end=e[1]?g+(e[1]+1)*e[2]:+e[2]),c}]};function fc(){return setTimeout(function(){$b=void 0}),$b=m.now()}function gc(a,b){var c,d={height:a},e=0;for(b=b?1:0;4>e;e+=2-b)c=T[e],d["margin"+c]=d["padding"+c]=a;return b&&(d.opacity=d.width=a),d}
function hc(a,b,c){for(var d,e=(ec[b]||[]).concat(ec["*"]),f=0,g=e.length;g>f;f++)if(d=e[f].call(c,b,a))return d}function ic(a,b,c){var d,e,f,g,h,i,j,l,n=this,o={},p=a.style,q=a.nodeType&&U(a),r=m._data(a,"fxshow");c.queue||(h=m._queueHooks(a,"fx"),null==h.unqueued&&(h.unqueued=0,i=h.empty.fire,h.empty.fire=function(){h.unqueued||i()}),h.unqueued++,n.always(function(){n.always(function(){h.unqueued--,m.queue(a,"fx").length||h.empty.fire()})})),1===a.nodeType&&("height"in b||"width"in b)&&(c.overflow=[p.overflow,p.overflowX,p.overflowY],j=m.css(a,"display"),l="none"===j?m._data(a,"olddisplay")||Fb(a.nodeName):j,"inline"===l&&"none"===m.css(a,"float")&&(k.inlineBlockNeedsLayout&&"inline"!==Fb(a.nodeName)?p.zoom=1:p.display="inline-block")),c.overflow&&(p.overflow="hidden",k.shrinkWrapBlocks()||n.always(function(){p.overflow=c.overflow[0],p.overflowX=c.overflow[1],p.overflowY=c.overflow[2]}));for(d in b)if(e=b[d],ac.exec(e)){if(delete b[d],f=f||"toggle"===e,e===(q?"hide":"show")){if("show"!==e||!r||void 0===r[d])continue;q=!0}o[d]=r&&r[d]||m.style(a,d)}else j=void 0;if(m.isEmptyObject(o))"inline"===("none"===j?Fb(a.nodeName):j)&&(p.display=j);else{r?"hidden"in r&&(q=r.hidden):r=m._data(a,"fxshow",{}),f&&(r.hidden=!q),q?m(a).show():n.done(function(){m(a).hide()}),n.done(function(){var b;m._removeData(a,"fxshow");for(b in o)m.style(a,b,o[b])});for(d in o)g=hc(q?r[d]:0,d,n),d in r||(r[d]=g.start,q&&(g.end=g.start,g.start="width"===d||"height"===d?1:0))}}function jc(a,b){var c,d,e,f,g;for(c in a)if(d=m.camelCase(c),e=b[d],f=a[c],m.isArray(f)&&(e=f[1],f=a[c]=f[0]),c!==d&&(a[d]=f,delete a[c]),g=m.cssHooks[d],g&&"expand"in g){f=g.expand(f),delete a[d];for(c in f)c in a||(a[c]=f[c],b[c]=e)}else b[d]=e}function kc(a,b,c){var d,e,f=0,g=dc.length,h=m.Deferred().always(function(){delete i.elem}),i=function()
{if(e)return!1;for(var b=$b||fc(),c=Math.max(0,j.startTime+j.duration-b),d=c/j.duration||0,f=1-d,g=0,i=j.tweens.length;i>g;g++)j.tweens[g].run(f);return h.notifyWith(a,[j,f,c]),1>f&&i?c:(h.resolveWith(a,[j]),!1)},j=h.promise({elem:a,props:m.extend({},b),opts:m.extend(!0,{specialEasing:{}},c),originalProperties:b,originalOptions:c,startTime:$b||fc(),duration:c.duration,tweens:[],createTween:function(b,c){var d=m.Tween(a,j.opts,b,c,j.opts.specialEasing[b]||j.opts.easing);return j.tweens.push(d),d},stop:function(b){var c=0,d=b?j.tweens.length:0;if(e)return this;for(e=!0;d>c;c++)j.tweens[c].run(1);return b?h.resolveWith(a,[j,b]):h.rejectWith(a,[j,b]),this}}),k=j.props;for(jc(k,j.opts.specialEasing);g>f;f++)if(d=dc[f].call(j,a,k,j.opts))return d;return m.map(k,hc,j),m.isFunction(j.opts.start)&&j.opts.start.call(a,j),m.fx.timer(m.extend(i,{elem:a,anim:j,queue:j.opts.queue})),j.progress(j.opts.progress).done(j.opts.done,j.opts.complete).fail(j.opts.fail).always(j.opts.always)}m.Animation=m.extend(kc,{tweener:function(a,b){m.isFunction(a)?(b=a,a=["*"]):a=a.split(" ");for(var c,d=0,e=a.length;e>d;d++)c=a[d],ec[c]=ec[c]||[],ec[c].unshift(b)},prefilter:function(a,b){b?dc.unshift(a):dc.push(a)}}),m.speed=function(a,b,c){var d=a&&"object"==typeof a?m.extend({},a):{complete:c||!c&&b||m.isFunction(a)&&a,duration:a,easing:c&&b||b&&!m.isFunction(b)&&b};return d.duration=m.fx.off?0:"number"==typeof d.duration?d.duration:d.duration in m.fx.speeds?m.fx.speeds[d.duration]:m.fx.speeds._default,(null==d.queue||d.queue===!0)&&(d.queue="fx"),d.old=d.complete,d.complete=function()
{m.isFunction(d.old)&&d.old.call(this),d.queue&&m.dequeue(this,d.queue)},d},m.fn.extend({fadeTo:function(a,b,c,d){return this.filter(U).css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){var e=m.isEmptyObject(a),f=m.speed(b,c,d),g=function(){var b=kc(this,m.extend({},a),f);(e||m._data(this,"finish"))&&b.stop(!0)};return g.finish=g,e||f.queue===!1?this.each(g):this.queue(f.queue,g)},stop:function(a,b,c){var d=function(a){var b=a.stop;delete a.stop,b(c)};return"string"!=typeof a&&(c=b,b=a,a=void 0),b&&a!==!1&&this.queue(a||"fx",[]),this.each(function(){var b=!0,e=null!=a&&a+"queueHooks",f=m.timers,g=m._data(this);if(e)g[e]&&g[e].stop&&d(g[e]);else for(e in g)g[e]&&g[e].stop&&cc.test(e)&&d(g[e]);for(e=f.length;e--;)f[e].elem!==this||null!=a&&f[e].queue!==a||(f[e].anim.stop(c),b=!1,f.splice(e,1));(b||!c)&&m.dequeue(this,a)})},finish:function(a){return a!==!1&&(a=a||"fx"),this.each(function(){var b,c=m._data(this),d=c[a+"queue"],e=c[a+"queueHooks"],f=m.timers,g=d?d.length:0;for(c.finish=!0,m.queue(this,a,[]),e&&e.stop&&e.stop.call(this,!0),b=f.length;b--;)f[b].elem===this&&f[b].queue===a&&(f[b].anim.stop(!0),f.splice(b,1));for(b=0;g>b;b++)d[b]&&d[b].finish&&d[b].finish.call(this);delete c.finish})}}),m.each(["toggle","show","hide"],function(a,b){var c=m.fn[b];m.fn[b]=function(a,d,e){return null==a||"boolean"==typeof a?c.apply(this,arguments):this.animate(gc(b,!0),a,d,e)}}),m.each({slideDown:gc("show"),slideUp:gc("hide"),slideToggle:gc("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){m.fn[a]=
function(a,c,d){return this.animate(b,a,c,d)}}),m.timers=[],m.fx.tick=function(){var a,b=m.timers,c=0;for($b=m.now();c<b.length;c++)a=b[c],a()||b[c]!==a||b.splice(c--,1);b.length||m.fx.stop(),$b=void 0},m.fx.timer=function(a){m.timers.push(a),a()?m.fx.start():m.timers.pop()},m.fx.interval=13,m.fx.start=function(){_b||(_b=setInterval(m.fx.tick,m.fx.interval))},m.fx.stop=function(){clearInterval(_b),_b=null},m.fx.speeds={slow:600,fast:200,_default:400},m.fn.delay=function(a,b){return a=m.fx?m.fx.speeds[a]||a:a,b=b||"fx",this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},function(){var a,b,c,d,e;b=y.createElement("div"),b.setAttribute("className","t"),b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",d=b.getElementsByTagName("a")[0],c=y.createElement("select"),e=c.appendChild(y.createElement("option")),a=b.getElementsByTagName("input")[0],d.style.cssText="top:1px",k.getSetAttribute="t"!==b.className,k.style=/top/.test(d.getAttribute("style")),k.hrefNormalized="/a"===d.getAttribute("href"),k.checkOn=!!a.value,k.optSelected=e.selected,k.enctype=!!y.createElement("form").enctype,c.disabled=!0,k.optDisabled=!e.disabled,a=y.createElement("input"),a.setAttribute("value",""),k.input=""===a.getAttribute("value"),a.value="t",a.setAttribute("type","radio"),k.radioValue="t"===a.value}();var lc=/\r/g;m.fn.extend({val:function(a){var b,c,d,e=this[0];{if(arguments.length)return d=m.isFunction(a),this.each(function(c){var e;1===this.nodeType&&(e=d?a.call(this,c,m(this).val()):a,null==e?e="":"number"==typeof e?e+="":m.isArray(e)&&(e=m.map(e,function(a){return null==a?"":a+""})),b=m.valHooks[this.type]||m.valHooks[this.nodeName.toLowerCase()],b&&"set"in b&&void 0!==b.set(this,e,"value")||(this.value=e))});if(e)return b=m.valHooks[e.type]||m.valHooks[e.nodeName.toLowerCase()],b&&"get"in b&&void 0!==(c=b.get(e,"value"))?c:(c=e.value,"string"==typeof c?c.replace(lc,""):null==c?"":c)}}}),m.extend({valHooks:{option:{get:
function(a){var b=m.find.attr(a,"value");return null!=b?b:m.trim(m.text(a))}},select:{get:function(a){for(var b,c,d=a.options,e=a.selectedIndex,f="select-one"===a.type||0>e,g=f?null:[],h=f?e+1:d.length,i=0>e?h:f?e:0;h>i;i++)if(c=d[i],!(!c.selected&&i!==e||(k.optDisabled?c.disabled:null!==c.getAttribute("disabled"))||c.parentNode.disabled&&m.nodeName(c.parentNode,"optgroup"))){if(b=m(c).val(),f)return b;g.push(b)}return g},set:function(a,b){var c,d,e=a.options,f=m.makeArray(b),g=e.length;while(g--)if(d=e[g],m.inArray(m.valHooks.option.get(d),f)>=0)try{d.selected=c=!0}catch(h){d.scrollHeight}else d.selected=!1;return c||(a.selectedIndex=-1),e}}}}),m.each(["radio","checkbox"],function(){m.valHooks[this]={set:function(a,b){return m.isArray(b)?a.checked=m.inArray(m(a).val(),b)>=0:void 0}},k.checkOn||(m.valHooks[this].get=function(a){return null===a.getAttribute("value")?"on":a.value})});var mc,nc,oc=m.expr.attrHandle,pc=/^(?:checked|selected)$/i,qc=k.getSetAttribute,rc=k.input;m.fn.extend({attr:function(a,b){return V(this,m.attr,a,b,arguments.length>1)},removeAttr:function(a){return this.each(function(){m.removeAttr(this,a)})}}),m.extend({attr:function(a,b,c){var d,e,f=a.nodeType;if(a&&3!==f&&8!==f&&2!==f)return typeof a.getAttribute===K?m.prop(a,b,c):(1===f&&m.isXMLDoc(a)||(b=b.toLowerCase(),d=m.attrHooks[b]||(m.expr.match.bool.test(b)?nc:mc)),void 0===c?d&&"get"in d&&null!==(e=d.get(a,b))?e:(e=m.find.attr(a,b),null==e?void 0:e):null!==c?d&&"set"in d&&void 0!==(e=d.set(a,c,b))?e:(a.setAttribute(b,c+""),c):void m.removeAttr(a,b))},removeAttr:function(a,b){var c,d,e=0,f=b&&b.match(E);if(f&&1===a.nodeType)while(c=f[e++])d=m.propFix[c]||c,m.expr.match.bool.test(c)?rc&&qc||!pc.test(c)?a[d]=!1:a[m.camelCase("default-"+c)]=a[d]=!1:m.attr(a,c,""),a.removeAttribute(qc?c:d)},attrHooks:{type:{set:
function(a,b){if(!k.radioValue&&"radio"===b&&m.nodeName(a,"input")){var c=a.value;return a.setAttribute("type",b),c&&(a.value=c),b}}}}}),nc={set:function(a,b,c){return b===!1?m.removeAttr(a,c):rc&&qc||!pc.test(c)?a.setAttribute(!qc&&m.propFix[c]||c,c):a[m.camelCase("default-"+c)]=a[c]=!0,c}},m.each(m.expr.match.bool.source.match(/\w+/g),function(a,b){var c=oc[b]||m.find.attr;oc[b]=rc&&qc||!pc.test(b)?function(a,b,d){var e,f;return d||(f=oc[b],oc[b]=e,e=null!=c(a,b,d)?b.toLowerCase():null,oc[b]=f),e}:function(a,b,c){return c?void 0:a[m.camelCase("default-"+b)]?b.toLowerCase():null}}),rc&&qc||(m.attrHooks.value={set:function(a,b,c){return m.nodeName(a,"input")?void(a.defaultValue=b):mc&&mc.set(a,b,c)}}),qc||(mc={set:function(a,b,c){var d=a.getAttributeNode(c);return d||a.setAttributeNode(d=a.ownerDocument.createAttribute(c)),d.value=b+="","value"===c||b===a.getAttribute(c)?b:void 0}},oc.id=oc.name=oc.coords=function(a,b,c){var d;return c?void 0:(d=a.getAttributeNode(b))&&""!==d.value?d.value:null},m.valHooks.button={get:function(a,b){var c=a.getAttributeNode(b);return c&&c.specified?c.value:void 0},set:mc.set},m.attrHooks.contenteditable={set:function(a,b,c){mc.set(a,""===b?!1:b,c)}},m.each(["width","height"],function(a,b){m.attrHooks[b]={set:function(a,c){return""===c?(a.setAttribute(b,"auto"),c):void 0}}})),k.style||(m.attrHooks.style={get:function(a){return a.style.cssText||void 0},set:function(a,b){return a.style.cssText=b+""}});var sc=/^(?:input|select|textarea|button|object)$/i,tc=/^(?:a|area)$/i;m.fn.extend({prop:function(a,b){return V(this,m.prop,a,b,arguments.length>1)},removeProp:function(a){return a=m.propFix[a]||a,this.each(function(){try{this[a]=void 0,delete this[a]}catch(b){}})}}),m.extend({propFix:{"for":"htmlFor","class":"className"},prop:function(a,b,c){var d,e,f,g=a.nodeType;if(a&&3!==g&&8!==g&&2!==g)return f=1!==g||!m.isXMLDoc(a),f&&(b=m.propFix[b]||b,e=m.propHooks[b]),void 0!==c?e&&"set"in e&&void 0!==(d=e.set(a,c,b))?d:a[b]=c:e&&"get"in e&&null!==(d=e.get(a,b))?d:a[b]},propHooks:{tabIndex:{get:function(a){var b=m.find.attr(a,"tabindex");
return b?parseInt(b,10):sc.test(a.nodeName)||tc.test(a.nodeName)&&a.href?0:-1}}}}),k.hrefNormalized||m.each(["href","src"],function(a,b){m.propHooks[b]={get:function(a){return a.getAttribute(b,4)}}}),k.optSelected||(m.propHooks.selected={get:function(a){var b=a.parentNode;return b&&(b.selectedIndex,b.parentNode&&b.parentNode.selectedIndex),null}}),m.each(["tabIndex","readOnly","maxLength","cellSpacing","cellPadding","rowSpan","colSpan","useMap","frameBorder","contentEditable"],function(){m.propFix[this.toLowerCase()]=this}),k.enctype||(m.propFix.enctype="encoding");var uc=/[\t\r\n\f]/g;m.fn.extend({addClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j="string"==typeof a&&a;if(m.isFunction(a))
return this.each(function(b){m(this).addClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(uc," "):" ")){f=0;while(e=b[f++])d.indexOf(" "+e+" ")<0&&(d+=e+" ");g=m.trim(d),c.className!==g&&(c.className=g)}return this},removeClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j=0===arguments.length||"string"==typeof a&&a;if(m.isFunction(a))return this.each(function(b){m(this).removeClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(uc," "):"")){f=0;while(e=b[f++])while(d.indexOf(" "+e+" ")>=0)d=d.replace(" "+e+" "," ");g=a?m.trim(d):"",c.className!==g&&(c.className=g)}return this},toggleClass:function(a,b){var c=typeof a;return"boolean"==typeof b&&"string"===c?b?this.addClass(a):this.removeClass(a):this.each(m.isFunction(a)?function(c){m(this).toggleClass(a.call(this,c,this.className,b),b)}:function(){if("string"===c){var b,d=0,e=m(this),f=a.match(E)||[];while(b=f[d++])e.hasClass(b)?e.removeClass(b):e.addClass(b)}else(c===K||"boolean"===c)&&(this.className&&m._data(this,"__className__",this.className),this.className=this.className||a===!1?"":m._data(this,"__className__")||"")})},hasClass:function(a){for(var b=" "+a+" ",c=0,d=this.length;d>c;c++)if(1===this[c].nodeType&&(" "+this[c].className+" ").replace(uc," ").indexOf(b)>=0)return!0;return!1}}),m.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){m.fn[b]=function(a,c){return arguments.length>0?this.on(b,null,a,c):this.trigger(b)}}),m.fn.extend({hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},delegate:
function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return 1===arguments.length?this.off(a,"**"):this.off(b,a||"**",c)}});var vc=m.now(),wc=/\?/,xc=/(,)|(\[|{)|(}|])|"(?:[^"\\\r\n]|\\["\\\/bfnrt]|\\u[\da-fA-F]{4})*"\s*:?|true|false|null|-?(?!0\d)\d+(?:\.\d+|)(?:[eE][+-]?\d+|)/g;m.parseJSON=function(b){if(a.JSON&&a.JSON.parse)return a.JSON.parse(b+"");var c,d=null,e=m.trim(b+"");return e&&!m.trim(e.replace(xc,function(a,b,e,f){return c&&b&&(d=0),0===d?a:(c=e||b,d+=!f-!e,"")}))?Function("return "+e)():m.error("Invalid JSON: "+b)},m.parseXML=function(b){var c,d;if(!b||"string"!=typeof b)return null;try{a.DOMParser?(d=new DOMParser,c=d.parseFromString(b,"text/xml")):(c=new ActiveXObject("Microsoft.XMLDOM"),c.async="false",c.loadXML(b))}catch(e){c=void 0}return c&&c.documentElement&&!c.getElementsByTagName("parsererror").length||m.error("Invalid XML: "+b),c};var yc,zc,Ac=/#.*$/,Bc=/([?&])_=[^&]*/,Cc=/^(.*?):[ \t]*([^\r\n]*)\r?$/gm,Dc=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,Ec=/^(?:GET|HEAD)$/,Fc=/^\/\//,Gc=/^([\w.+-]+:)(?:\/\/(?:[^\/?#]*@|)([^\/?#:]*)(?::(\d+)|)|)/,Hc={},Ic={},Jc="*/".concat("*");try{zc=location.href}catch(Kc){zc=y.createElement("a"),zc.href="",zc=zc.href}yc=Gc.exec(zc.toLowerCase())||[];function Lc(a){return function(b,c){"string"!=typeof b&&(c=b,b="*");var d,e=0,f=b.toLowerCase().match(E)||[];if(m.isFunction(c))while(d=f[e++])"+"===d.charAt(0)?(d=d.slice(1)||"*",(a[d]=a[d]||[]).unshift(c)):(a[d]=a[d]||[]).push(c)}}function Mc(a,b,c,d){var e={},f=a===Ic;function g(h){var i;return e[h]=!0,m.each(a[h]||[],function(a,h){var j=h(b,c,d);return"string"!=typeof j||f||e[j]?f?!(i=j):void 0:(b.dataTypes.unshift(j),g(j),!1)}),i}return g(b.dataTypes[0])||!e["*"]&&g("*")}function Nc(a,b){var c,d,e=m.ajaxSettings.flatOptions||{};for(d in b)void 0!==b[d]&&((e[d]?a:c||(c={}))[d]=b[d]);return c&&m.extend(!0,a,c),a}function Oc(a,b,c){var d,e,f,g,h=a.contents,i=a.dataTypes;while("*"===i[0])i.shift(),void 0===e&&(e=a.mimeType||b.getResponseHeader("Content-Type"));
if(e)for(g in h)if(h[g]&&h[g].test(e)){i.unshift(g);break}if(i[0]in c)f=i[0];else{for(g in c){if(!i[0]||a.converters[g+" "+i[0]]){f=g;break}d||(d=g)}f=f||d}return f?(f!==i[0]&&i.unshift(f),c[f]):void 0}function Pc(a,b,c,d){var e,f,g,h,i,j={},k=a.dataTypes.slice();if(k[1])for(g in a.converters)j[g.toLowerCase()]=a.converters[g];f=k.shift();while(f)if(a.responseFields[f]&&(c[a.responseFields[f]]=b),!i&&d&&a.dataFilter&&(b=a.dataFilter(b,a.dataType)),i=f,f=k.shift())if("*"===f)f=i;else if("*"!==i&&i!==f){if(g=j[i+" "+f]||j["* "+f],!g)for(e in j)if(h=e.split(" "),h[1]===f&&(g=j[i+" "+h[0]]||j["* "+h[0]])){g===!0?g=j[e]:j[e]!==!0&&(f=h[0],k.unshift(h[1]));break}if(g!==!0)if(g&&a["throws"])b=g(b);else try{b=g(b)}catch(l){return{state:"parsererror",error:g?l:"No conversion from "+i+" to "+f}}}return{state:"success",data:b}}m.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:zc,type:"GET",isLocal:Dc.test(yc[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":Jc,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText",json:"responseJSON"},converters:{"* text":String,"text html":!0,"text json":m.parseJSON,"text xml":m.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(a,b){return b?Nc(Nc(a,m.ajaxSettings),b):Nc(m.ajaxSettings,a)},ajaxPrefilter:Lc(Hc),ajaxTransport:Lc(Ic),ajax:
function(a,b){"object"==typeof a&&(b=a,a=void 0),b=b||{};var c,d,e,f,g,h,i,j,k=m.ajaxSetup({},b),l=k.context||k,n=k.context&&(l.nodeType||l.jquery)?m(l):m.event,o=m.Deferred(),p=m.Callbacks("once memory"),q=k.statusCode||{},r={},s={},t=0,u="canceled",v={readyState:0,getResponseHeader:function(a){var b;if(2===t){if(!j){j={};while(b=Cc.exec(f))j[b[1].toLowerCase()]=b[2]}b=j[a.toLowerCase()]}return null==b?null:b},getAllResponseHeaders:function(){return 2===t?f:null},setRequestHeader:function(a,b){var c=a.toLowerCase();return t||(a=s[c]=s[c]||a,r[a]=b),this},overrideMimeType:function(a){return t||(k.mimeType=a),this},statusCode:function(a){var b;if(a)if(2>t)for(b in a)q[b]=[q[b],a[b]];else v.always(a[v.status]);return this},abort:function(a){var b=a||u;return i&&i.abort(b),x(0,b),this}};
if(o.promise(v).complete=p.add,v.success=v.done,v.error=v.fail,k.url=((a||k.url||zc)+"").replace(Ac,"").replace(Fc,yc[1]+"//"),k.type=b.method||b.type||k.method||k.type,k.dataTypes=m.trim(k.dataType||"*").toLowerCase().match(E)||[""],null==k.crossDomain&&(c=Gc.exec(k.url.toLowerCase()),k.crossDomain=!(!c||c[1]===yc[1]&&c[2]===yc[2]&&(c[3]||("http:"===c[1]?"80":"443"))===(yc[3]||("http:"===yc[1]?"80":"443")))),k.data&&k.processData&&"string"!=typeof k.data&&(k.data=m.param(k.data,k.traditional)),Mc(Hc,k,b,v),2===t)return v;h=k.global,h&&0===m.active++&&m.event.trigger("ajaxStart"),k.type=k.type.toUpperCase(),k.hasContent=!Ec.test(k.type),e=k.url,k.hasContent||(k.data&&(e=k.url+=(wc.test(e)?"&":"?")+k.data,delete k.data),k.cache===!1&&(k.url=Bc.test(e)?e.replace(Bc,"$1_="+vc++):e+(wc.test(e)?"&":"?")+"_="+vc++)),k.ifModified&&(m.lastModified[e]&&v.setRequestHeader("If-Modified-Since",m.lastModified[e]),m.etag[e]&&v.setRequestHeader("If-None-Match",m.etag[e])),(k.data&&k.hasContent&&k.contentType!==!1||b.contentType)&&v.setRequestHeader("Content-Type",k.contentType),v.setRequestHeader("Accept",k.dataTypes[0]&&k.accepts[k.dataTypes[0]]?k.accepts[k.dataTypes[0]]+("*"!==k.dataTypes[0]?", "+Jc+"; q=0.01":""):k.accepts["*"]);for(d in k.headers)v.setRequestHeader(d,k.headers[d]);if(k.beforeSend&&(k.beforeSend.call(l,v,k)===!1||2===t))return v.abort();u="abort";for(d in{success:1,error:1,complete:1})v[d](k[d]);if(i=Mc(Ic,k,b,v)){v.readyState=1,h&&n.trigger("ajaxSend",[v,k]),k.async&&k.timeout>0&&(g=setTimeout(function(){v.abort("timeout")},k.timeout));try{t=1,i.send(r,x)}catch(w){if(!(2>t))throw w;x(-1,w)}}else x(-1,"No Transport");
function x(a,b,c,d){var j,r,s,u,w,x=b;2!==t&&(t=2,g&&clearTimeout(g),i=void 0,f=d||"",v.readyState=a>0?4:0,j=a>=200&&300>a||304===a,c&&(u=Oc(k,v,c)),u=Pc(k,u,v,j),j?(k.ifModified&&(w=v.getResponseHeader("Last-Modified"),w&&(m.lastModified[e]=w),w=v.getResponseHeader("etag"),w&&(m.etag[e]=w)),204===a||"HEAD"===k.type?x="nocontent":304===a?x="notmodified":(x=u.state,r=u.data,s=u.error,j=!s)):(s=x,(a||!x)&&(x="error",0>a&&(a=0))),v.status=a,v.statusText=(b||x)+"",j?o.resolveWith(l,[r,x,v]):o.rejectWith(l,[v,x,s]),v.statusCode(q),q=void 0,h&&n.trigger(j?"ajaxSuccess":"ajaxError",[v,k,j?r:s]),p.fireWith(l,[v,x]),h&&(n.trigger("ajaxComplete",[v,k]),--m.active||m.event.trigger("ajaxStop")))}return v},getJSON:function(a,b,c){return m.get(a,b,c,"json")},getScript:function(a,b){return m.get(a,void 0,b,"script")}}),m.each(["get","post"],function(a,b){m[b]=function(a,c,d,e){return m.isFunction(c)&&(e=e||d,d=c,c=void 0),m.ajax({url:a,type:b,dataType:e,data:c,success:d})}}),m.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(a,b){m.fn[b]=function(a){return this.on(b,a)}}),m._evalUrl=function(a){return m.ajax({url:a,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0})},m.fn.extend({wrapAll:function(a){if(m.isFunction(a))return this.each(function(b){m(this).wrapAll(a.call(this,b))});if(this[0]){var b=m(a,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&&b.insertBefore(this[0]),b.map(function(){var a=this;
while(a.firstChild&&1===a.firstChild.nodeType)a=a.firstChild;return a}).append(this)}return this},wrapInner:function(a){return this.each(m.isFunction(a)?function(b){m(this).wrapInner(a.call(this,b))}:function(){var b=m(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=m.isFunction(a);return this.each(function(c){m(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){m.nodeName(this,"body")||m(this).replaceWith(this.childNodes)}).end()}}),m.expr.filters.hidden=function(a){return a.offsetWidth<=0&&a.offsetHeight<=0||!k.reliableHiddenOffsets()&&"none"===(a.style&&a.style.display||m.css(a,"display"))},m.expr.filters.visible=function(a){return!m.expr.filters.hidden(a)};var Qc=/%20/g,Rc=/\[\]$/,Sc=/\r?\n/g,Tc=/^(?:submit|button|image|reset|file)$/i,Uc=/^(?:input|select|textarea|keygen)/i;function Vc(a,b,c,d){var e;if(m.isArray(b))m.each(b,function(b,e){c||Rc.test(a)?d(a,e):Vc(a+"["+("object"==typeof e?b:"")+"]",e,c,d)});else if(c||"object"!==m.type(b))d(a,b);else for(e in b)Vc(a+"["+e+"]",b[e],c,d)}m.param=function(a,b){var c,d=[],e=function(a,b){b=m.isFunction(b)?b():null==b?"":b,d[d.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};if(void 0===b&&(b=m.ajaxSettings&&m.ajaxSettings.traditional),m.isArray(a)||a.jquery&&!m.isPlainObject(a))m.each(a,function(){e(this.name,this.value)});else for(c in a)Vc(c,a[c],b,e);return d.join("&").replace(Qc,"+")},m.fn.extend({serialize:function(){return m.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var a=m.prop(this,"elements");return a?m.makeArray(a):this}).filter(function(){var a=this.type;return this.name&&!m(this).is(":disabled")&&Uc.test(this.nodeName)&&!Tc.test(a)&&(this.checked||!W.test(a))}).map(function(a,b){var c=m(this).val();return null==c?null:m.isArray(c)?m.map(c,
function(a){return{name:b.name,value:a.replace(Sc,"\r\n")}}):{name:b.name,value:c.replace(Sc,"\r\n")}}).get()}}),m.ajaxSettings.xhr=void 0!==a.ActiveXObject?function(){return!this.isLocal&&/^(get|post|head|put|delete|options)$/i.test(this.type)&&Zc()||$c()}:Zc;var Wc=0,Xc={},Yc=m.ajaxSettings.xhr();a.ActiveXObject&&m(a).on("unload",function(){for(var a in Xc)Xc[a](void 0,!0)}),k.cors=!!Yc&&"withCredentials"in Yc,Yc=k.ajax=!!Yc,Yc&&m.ajaxTransport(function(a){if(!a.crossDomain||k.cors){var b;return{send:function(c,d){var e,f=a.xhr(),g=++Wc;if(f.open(a.type,a.url,a.async,a.username,a.password),a.xhrFields)for(e in a.xhrFields)f[e]=a.xhrFields[e];a.mimeType&&f.overrideMimeType&&f.overrideMimeType(a.mimeType),a.crossDomain||c["X-Requested-With"]||(c["X-Requested-With"]="XMLHttpRequest");for(e in c)void 0!==c[e]&&f.setRequestHeader(e,c[e]+"");f.send(a.hasContent&&a.data||null),b=function(c,e){var h,i,j;if(b&&(e||4===f.readyState))if(delete Xc[g],b=void 0,f.onreadystatechange=m.noop,e)4!==f.readyState&&f.abort();else{j={},h=f.status,"string"==typeof f.responseText&&(j.text=f.responseText);try{i=f.statusText}catch(k){i=""}h||!a.isLocal||a.crossDomain?1223===h&&(h=204):h=j.text?200:404}j&&d(h,i,j,f.getAllResponseHeaders())},a.async?4===f.readyState?setTimeout(b):f.onreadystatechange=Xc[g]=b:b()},abort:function(){b&&b(void 0,!0)}}}});
function Zc(){try{return new a.XMLHttpRequest}catch(b){}}function $c(){try{return new a.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}}m.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(a){return m.globalEval(a),a}}}),m.ajaxPrefilter("script",function(a){void 0===a.cache&&(a.cache=!1),a.crossDomain&&(a.type="GET",a.global=!1)}),m.ajaxTransport("script",function(a){if(a.crossDomain){var b,c=y.head||m("head")[0]||y.documentElement;return{send:function(d,e){b=y.createElement("script"),b.async=!0,a.scriptCharset&&(b.charset=a.scriptCharset),b.src=a.url,b.onload=b.onreadystatechange=function(a,c){(c||!b.readyState||/loaded|complete/.test(b.readyState))&&(b.onload=b.onreadystatechange=null,b.parentNode&&b.parentNode.removeChild(b),b=null,c||e(200,"success"))},c.insertBefore(b,c.firstChild)},abort:function(){b&&b.onload(void 0,!0)}}}});var _c=[],ad=/(=)\?(?=&|$)|\?\?/;m.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var a=_c.pop()||m.expando+"_"+vc++;return this[a]=!0,a}}),m.ajaxPrefilter("json jsonp",function(b,c,d){var e,f,g,h=b.jsonp!==!1&&(ad.test(b.url)?"url":"string"==typeof b.data&&!(b.contentType||"").indexOf("application/x-www-form-urlencoded")&&ad.test(b.data)&&"data");return h||"jsonp"===b.dataTypes[0]?(e=b.jsonpCallback=m.isFunction(b.jsonpCallback)?b.jsonpCallback():b.jsonpCallback,h?b[h]=b[h].replace(ad,"$1"+e):b.jsonp!==!1&&(b.url+=(wc.test(b.url)?"&":"?")+b.jsonp+"="+e),b.converters["script json"]=function(){return g||m.error(e+" was not called"),g[0]},b.dataTypes[0]="json",f=a[e],a[e]=function(){g=arguments},d.always(function(){a[e]=f,b[e]&&(b.jsonpCallback=c.jsonpCallback,_c.push(e)),g&&m.isFunction(f)&&f(g[0]),g=f=void 0}),"script"):void 0}),m.parseHTML=function(a,b,c){if(!a||"string"!=typeof a)return null;"boolean"==typeof b&&(c=b,b=!1),b=b||y;var d=u.exec(a),e=!c&&[];
return d?[b.createElement(d[1])]:(d=m.buildFragment([a],b,e),e&&e.length&&m(e).remove(),m.merge([],d.childNodes))};var bd=m.fn.load;m.fn.load=function(a,b,c){if("string"!=typeof a&&bd)return bd.apply(this,arguments);var d,e,f,g=this,h=a.indexOf(" ");return h>=0&&(d=m.trim(a.slice(h,a.length)),a=a.slice(0,h)),m.isFunction(b)?(c=b,b=void 0):b&&"object"==typeof b&&(f="POST"),g.length>0&&m.ajax({url:a,type:f,dataType:"html",data:b}).done(function(a){e=arguments,g.html(d?m("<div>").append(m.parseHTML(a)).find(d):a)}).complete(c&&function(a,b){g.each(c,e||[a.responseText,b,a])}),this},m.expr.filters.animated=function(a){return m.grep(m.timers,function(b){return a===b.elem}).length};var cd=a.document.documentElement;function dd(a){return m.isWindow(a)?a:9===a.nodeType?a.defaultView||a.parentWindow:!1}m.offset={setOffset:function(a,b,c){var d,e,f,g,h,i,j,k=m.css(a,"position"),l=m(a),n={};"static"===k&&(a.style.position="relative"),h=l.offset(),f=m.css(a,"top"),i=m.css(a,"left"),j=("absolute"===k||"fixed"===k)&&m.inArray("auto",[f,i])>-1,j?(d=l.position(),g=d.top,e=d.left):(g=parseFloat(f)||0,e=parseFloat(i)||0),m.isFunction(b)&&(b=b.call(a,c,h)),null!=b.top&&(n.top=b.top-h.top+g),null!=b.left&&(n.left=b.left-h.left+e),"using"in b?b.using.call(a,n):l.css(n)}},m.fn.extend({offset:function(a){if(arguments.length)return void 0===a?this:this.each(function(b){m.offset.setOffset(this,a,b)});
var b,c,d={top:0,left:0},e=this[0],f=e&&e.ownerDocument;if(f)return b=f.documentElement,m.contains(b,e)?(typeof e.getBoundingClientRect!==K&&(d=e.getBoundingClientRect()),c=dd(f),{top:d.top+(c.pageYOffset||b.scrollTop)-(b.clientTop||0),left:d.left+(c.pageXOffset||b.scrollLeft)-(b.clientLeft||0)}):d},position:function(){if(this[0]){var a,b,c={top:0,left:0},d=this[0];return"fixed"===m.css(d,"position")?b=d.getBoundingClientRect():(a=this.offsetParent(),b=this.offset(),m.nodeName(a[0],"html")||(c=a.offset()),c.top+=m.css(a[0],"borderTopWidth",!0),c.left+=m.css(a[0],"borderLeftWidth",!0)),{top:b.top-c.top-m.css(d,"marginTop",!0),left:b.left-c.left-m.css(d,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){var a=this.offsetParent||cd;while(a&&!m.nodeName(a,"html")&&"static"===m.css(a,"position"))a=a.offsetParent;return a||cd})}}),m.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(a,b){var c=/Y/.test(b);m.fn[a]=function(d){return V(this,function(a,d,e){var f=dd(a);return void 0===e?f?b in f?f[b]:f.document.documentElement[d]:a[d]:void(f?f.scrollTo(c?m(f).scrollLeft():e,c?e:m(f).scrollTop()):a[d]=e)},a,d,arguments.length,null)}}),m.each(["top","left"],function(a,b){m.cssHooks[b]=Lb(k.pixelPosition,function(a,c){return c?(c=Jb(a,b),Hb.test(c)?m(a).position()[b]+"px":c):void 0})}),m.each({Height:"height",Width:"width"},function(a,b){m.each({padding:"inner"+a,content:b,"":"outer"+a},function(c,d){m.fn[d]=function(d,e){var f=arguments.length&&(c||"boolean"!=typeof d),g=c||(d===!0||e===!0?"margin":"border");
return V(this,function(b,c,d){var e;return m.isWindow(b)?b.document.documentElement["client"+a]:9===b.nodeType?(e=b.documentElement,Math.max(b.body["scroll"+a],e["scroll"+a],b.body["offset"+a],e["offset"+a],e["client"+a])):void 0===d?m.css(b,c,g):m.style(b,c,d,g)},b,f?d:void 0,f,null)}})}),m.fn.size=function(){return this.length},m.fn.andSelf=m.fn.addBack,"function"==typeof define&&define.amd&&define("jquery",[],function(){return m});var ed=a.jQuery,fd=a.$;return m.noConflict=function(b){return a.$===m&&(a.$=fd),b&&a.jQuery===m&&(a.jQuery=ed),m},typeof b===K&&(a.jQuery=a.$=m),m});
`' ||
q'`
/*!
* TableSorter 2.15.3 min - Client-side table sorting with ease!
* Copyright (c) 2007 Christian Bach
*/
!function(g){g.extend({tablesorter:new function(){function d(){var a=arguments[0],b=1<arguments.length?Array.prototype.slice.call(arguments):a;if("undefined"!==typeof console&&"undefined"!==typeof console.log)console[/error/i.test(a)?"error":/warn/i.test(a)?"warn":"log"](b);else alert(b)}function u(a,b){d(a+" ("+((new Date).getTime()-b.getTime())+"ms)")}function m(a){for(var b in a)return!1;return!0}function p(a,b,c){if(!b)return"";var h=a.config,e=h.textExtraction,f="",f="simple"===e?h.supportsTextContent? b.textContent:g(b).text():"function"===typeof e?e(b,a,c):"object"===typeof e&&e.hasOwnProperty(c)?e[c](b,a,c):h.supportsTextContent?b.textContent:g(b).text();return g.trim(f)}function t(a){var b=a.config,c=b.$tbodies=b.$table.children("tbody:not(."+b.cssInfoBlock+")"),h,e,w,k,n,g,l,z="";if(0===c.length)return b.debug?d("Warning: *Empty table!* Not building a parser cache"):"";b.debug&&(l=new Date,d("Detecting parsers for each column"));c=c[0].rows;if(c[0])for(h=[],e=c[0].cells.length,w=0;w<e;w++){k= b.$headers.filter(":not([colspan])");k=k.add(b.$headers.filter('[colspan="1"]')).filter('[data-column="'+w+'"]:last');n=b.headers[w];g=f.getParserById(f.getData(k,n,"sorter"));b.empties[w]=f.getData(k,n,"empty")||b.emptyTo||(b.emptyToBottom?"bottom":"top");b.strings[w]=f.getData(k,n,"string")||b.stringTo||"max";if(!g)a:{k=a;n=c;g=-1;for(var m=w,y=void 0,x=f.parsers.length,r=!1,t="",y=!0;""===t&&y;)g++,n[g]?(r=n[g].cells[m],t=p(k,r,m),k.config.debug&&d("Checking if value was empty on row "+g+", column: "+ m+': "'+t+'"')):y=!1;for(;0<=--x;)if((y=f.parsers[x])&&"text"!==y.id&&y.is&&y.is(t,k,r)){g=y;break a}g=f.getParserById("text")}b.debug&&(z+="column:"+w+"; parser:"+g.id+"; string:"+b.strings[w]+"; empty: "+b.empties[w]+"\n");h.push(g)}b.debug&&(d(z),u("Completed detecting parsers",l));
b.parsers=h}function v(a){var b=a.tBodies,c=a.config,h,e,w=c.parsers,k,n,q,l,z,m,y,x=[];c.cache={};if(!w)return c.debug?d("Warning: *Empty table!* Not building a cache"):"";c.debug&&(y=new Date);c.showProcessing&&f.isProcessing(a, !0);for(l=0;l<b.length;l++)if(c.cache[l]={row:[],normalized:[]},!g(b[l]).hasClass(c.cssInfoBlock)){h=b[l]&&b[l].rows.length||0;e=b[l].rows[0]&&b[l].rows[0].cells.length||0;for(n=0;n<h;++n)if(z=g(b[l].rows[n]),m=[],z.hasClass(c.cssChildRow))c.cache[l].row[c.cache[l].row.length-1]=c.cache[l].row[c.cache[l].row.length-1].add(z);else{c.cache[l].row.push(z);for(q=0;q<e;++q)k=p(a,z[0].cells[q],q),k=w[q].format(k,a,z[0].cells[q],q),m.push(k),"numeric"===(w[q].type||"").toLowerCase()&&(x[q]=Math.max(Math.abs(k)|| 0,x[q]||0));m.push(c.cache[l].normalized.length);c.cache[l].normalized.push(m)}c.cache[l].colMax=x}c.showProcessing&&f.isProcessing(a);c.debug&&u("Building cache for "+h+" rows",y)}function A(a,b){var c=a.config,h=c.widgetOptions,e=a.tBodies,w=[],k=c.cache,d,q,l,z,p,y,x,r,t,s,v;
if(m(k))return c.appender?c.appender(a,w):"";c.debug&&(v=new Date);for(r=0;r<e.length;r++)if(d=g(e[r]),d.length&&!d.hasClass(c.cssInfoBlock)){p=f.processTbody(a,d,!0);d=k[r].row;q=k[r].normalized;z=(l=q.length)?q[0].length- 1:0;for(y=0;y<l;y++)if(s=q[y][z],w.push(d[s]),!c.appender||c.pager&&!(c.pager.removeRows&&h.pager_removeRows||c.pager.ajax))for(t=d[s].length,x=0;x<t;x++)p.append(d[s][x]);f.processTbody(a,p,!1)}c.appender&&c.appender(a,w);c.debug&&u("Rebuilt table",v);b||c.appender||f.applyWidget(a);g(a).trigger("sortEnd",a);g(a).trigger("updateComplete",a)}function D(a){var b=[],c={},h=0,e=g(a).find("thead:eq(0), tfoot").children("tr"),f,d,n,q,l,m,u,p,s,r;for(f=0;f<e.length;f++)for(l=e[f].cells,d=0;d<l.length;d++){q= l[d];m=q.parentNode.rowIndex;u=m+"-"+q.cellIndex;p=q.rowSpan||1;s=q.colSpan||1;"undefined"===typeof b[m]&&(b[m]=[]);for(n=0;n<b[m].length+1;n++)if("undefined"===typeof b[m][n]){r=n;break}c[u]=r;h=Math.max(r,h);g(q).attr({"data-column":r});for(n=m;n<m+p;n++)for("undefined"===typeof b[n]&&(b[n]=[]),u=b[n],q=r;q<r+s;q++)u[q]="x"}a.config.columns=h+1;return c}function C(a){return/^d/i.test(a)||1===a}function E(a){var b=D(a),c,h,e,w,k,n,q,l=a.config;
l.headerList=[];l.headerContent=[];l.debug&&(q=new Date); w=l.cssIcon?'<i class="'+(l.cssIcon===f.css.icon?f.css.icon:l.cssIcon+" "+f.css.icon)+'"></i>':"";l.$headers=g(a).find(l.selectorHeaders).each(function(a){h=g(this);c=l.headers[a];l.headerContent[a]=g(this).html();k=l.headerTemplate.replace(/\{content\}/g,g(this).html()).replace(/\{icon\}/g,w);l.onRenderTemplate&&(e=l.onRenderTemplate.apply(h,[a,k]))&&"string"===typeof e&&(k=e);g(this).html('<div class="'+f.css.headerIn+'">'+k+"</div>");l.onRenderHeader&&l.onRenderHeader.apply(h,[a]);this.column= b[this.parentNode.rowIndex+"-"+this.cellIndex];this.order=C(f.getData(h,c,"sortInitialOrder")||l.sortInitialOrder)?[1,0,2]:[0,1,2];this.count=-1;this.lockedOrder=!1;n=f.getData(h,c,"lockedOrder")||!1;"undefined"!==typeof n&&!1!==n&&(this.order=this.lockedOrder=C(n)?[1,1,1]:[0,0,0]);h.addClass(f.css.header+" "+l.cssHeader);l.headerList[a]=this;h.parent().addClass(f.css.headerRow+" "+l.cssHeaderRow).attr("role","row");l.tabIndex&&h.attr("tabindex",0)}).attr({scope:"col",role:"columnheader"});G(a);l.debug&& (u("Built headers:",q),d(l.$headers))}function B(a,b,c){var h=a.config;h.$table.find(h.selectorRemove).remove();t(a);v(a);H(h.$table,b,c)}
function G(a){var b,c,h=a.config;h.$headers.each(function(e,d){c=g(d);b="false"===f.getData(d,h.headers[e],"sorter");d.sortDisabled=b;c[b?"addClass":"removeClass"]("sorter-false").attr("aria-disabled",""+b);a.id&&(b?c.removeAttr("aria-controls"):c.attr("aria-controls",a.id))})}function F(a){var b,c,h,e=a.config,d=e.sortList,k=f.css.sortNone+" "+e.cssNone,n=[f.css.sortAsc+ " "+e.cssAsc,f.css.sortDesc+" "+e.cssDesc],q=["ascending","descending"],l=g(a).find("tfoot tr").children().removeClass(n.join(" "));e.$headers.removeClass(n.join(" ")).addClass(k).attr("aria-sort","none");h=d.length;for(b=0;b<h;b++)if(2!==d[b][1]&&(a=e.$headers.not(".sorter-false").filter('[data-column="'+d[b][0]+'"]'+(1===h?":last":"")),a.length))for(c=0;c<a.length;c++)a[c].sortDisabled||(a.eq(c).removeClass(k).addClass(n[d[b][1]]).attr("aria-sort",q[d[b][1]]),l.length&&l.filter('[data-column="'+ d[b][0]+'"]').eq(c).addClass(n[d[b][1]]));e.$headers.not(".sorter-false").each(function(){var a=g(this),b=this.order[(this.count+1)%(e.sortReset?3:2)],b=a.text()+": "+f.language[a.hasClass(f.css.sortAsc)?"sortAsc":a.hasClass(f.css.sortDesc)?"sortDesc":"sortNone"]+f.language[0===b?"nextAsc":1===b?"nextDesc":"nextNone"];a.attr("aria-label",b)})}function L(a){if(a.config.widthFixed&&0===g(a).find("colgroup").length){var b=g("<colgroup>"),c=g(a).width();g(a.tBodies[0]).find("tr:first").children("td:visible").each(function(){b.append(g("<col>").css("width", parseInt(g(this).width()/c*1E3,10)/10+"%"))});
g(a).prepend(b)}}function M(a,b){var c,h,e,f=a.config,d=b||f.sortList;f.sortList=[];g.each(d,function(a,b){c=[parseInt(b[0],10),parseInt(b[1],10)];if(e=f.$headers[c[0]])f.sortList.push(c),h=g.inArray(c[1],e.order),e.count=0<=h?h:c[1]%(f.sortReset?3:2)})}function N(a,b){return a&&a[b]?a[b].type||"":""}function O(a,b,c){var h,e,d,k=a.config,n=!c[k.sortMultiSortKey],q=g(a);q.trigger("sortStart",a);b.count=c[k.sortResetKey]?2:(b.count+1)%(k.sortReset?3:2); k.sortRestart&&(e=b,k.$headers.each(function(){this===e||!n&&g(this).is("."+f.css.sortDesc+",."+f.css.sortAsc)||(this.count=-1)}));e=b.column;if(n){k.sortList=[];if(null!==k.sortForce)for(h=k.sortForce,c=0;c<h.length;c++)h[c][0]!==e&&k.sortList.push(h[c]);h=b.order[b.count];if(2>h&&(k.sortList.push([e,h]),1<b.colSpan))for(c=1;c<b.colSpan;c++)k.sortList.push([e+c,h])}else if(k.sortAppend&&1<k.sortList.length&&f.isValueInArray(k.sortAppend[0][0],k.sortList)&&k.sortList.pop(),f.isValueInArray(e,k.sortList))for(c= 0;c<k.sortList.length;c++)d=k.sortList[c],h=k.$headers[d[0]],d[0]===e&&(d[1]=h.order[b.count],2===d[1]&&(k.sortList.splice(c,1),h.count=-1));else if(h=b.order[b.count],2>h&&(k.sortList.push([e,h]),1<b.colSpan))for(c=1;c<b.colSpan;c++)k.sortList.push([e+c,h]);if(null!==k.sortAppend)for(h=k.sortAppend,c=0;c<h.length;c++)h[c][0]!==e&&k.sortList.push(h[c]);q.trigger("sortBegin",a);
setTimeout(function(){F(a);I(a);A(a)},1)}function I(a){var b,c,h,e,d,k,g,q,l,p,s,t,x=0,r=a.config,v=r.textSorter||"",A=r.sortList, B=A.length,C=a.tBodies.length;if(!r.serverSideSorting&&!m(r.cache)){r.debug&&(l=new Date);for(c=0;c<C;c++)d=r.cache[c].colMax,q=(k=r.cache[c].normalized)&&k[0]?k[0].length-1:0,k.sort(function(c,k){for(b=0;b<B;b++){e=A[b][0];g=A[b][1];x=0===g;if(r.sortStable&&c[e]===k[e]&&1===B)break;(h=/n/i.test(N(r.parsers,e)))&&r.strings[e]?(h="boolean"===typeof r.string[r.strings[e]]?(x?1:-1)*(r.string[r.strings[e]]?-1:1):r.strings[e]?r.string[r.strings[e]]||0:0,p=r.numberSorter?r.numberSorter(s[e],t[e],x,d[e], a):f["sortNumeric"+(x?"Asc":"Desc")](c[e],k[e],h,d[e],e,a)):(s=x?c:k,t=x?k:c,p="function"===typeof v?v(s[e],t[e],x,e,a):"object"===typeof v&&v.hasOwnProperty(e)?v[e](s[e],t[e],x,e,a):f["sortNatural"+(x?"Asc":"Desc")](c[e],k[e],e,a,r));if(p)return p}return c[q]-k[q]});r.debug&&u("Sorting on "+A.toString()+" and dir "+g+" time",l)}}function J(a,b){var c=a[0].config;c.pager&&!c.pager.ajax&&a.trigger("updateComplete");"function"===typeof b&&b(a[0])}function H(a,b,c){!1===b||a[0].isProcessing?J(a,c):a.trigger("sorton", [a[0].config.sortList,function(){J(a,c)}])}function K(a){var b=a.config,c=b.$table;c.unbind("sortReset update updateRows updateCell updateAll addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave ".split(" ").join(".tablesorter ")).bind("sortReset.tablesorter",function(c){c.stopPropagation();
b.sortList=[];F(a);I(a);A(a)}).bind("updateAll.tablesorter",function(c,e,d){c.stopPropagation();f.refreshWidgets(a,!0,!0);f.restoreHeaders(a);E(a);f.bindEvents(a,b.$headers); K(a);B(a,e,d)}).bind("update.tablesorter updateRows.tablesorter",function(b,c,d){b.stopPropagation();G(a);B(a,c,d)}).bind("updateCell.tablesorter",function(h,e,d,f){h.stopPropagation();c.find(b.selectorRemove).remove();var n,q,l;n=c.find("tbody");h=n.index(g(e).parents("tbody").filter(":first"));var m=g(e).parents("tr").filter(":first");e=g(e)[0];n.length&&0<=h&&(q=n.eq(h).find("tr").index(m),l=e.cellIndex,n=b.cache[h].normalized[q].length-1,b.cache[h].row[a.config.cache[h].normalized[q][n]]=m,b.cache[h].normalized[q][l]= b.parsers[l].format(p(a,e,l),a,e,l),H(c,d,f))}).bind("addRows.tablesorter",function(h,e,d,f){h.stopPropagation();if(m(b.cache))G(a),B(a,d,f);else{var g,q=e.filter("tr").length,l=[],u=e[0].cells.length,v=c.find("tbody").index(e.parents("tbody").filter(":first"));b.parsers||t(a);for(h=0;h<q;h++){for(g=0;g<u;g++)l[g]=b.parsers[g].format(p(a,e[h].cells[g],g),a,e[h].cells[g],g);l.push(b.cache[v].row.length);b.cache[v].row.push([e[h]]);b.cache[v].normalized.push(l);l=[]}H(c,d,f)}}).bind("sorton.tablesorter", function(b,e,d,f){var g=a.config;b.stopPropagation();c.trigger("sortStart",this);M(a,e);F(a);g.delayInit&&m(g.cache)&&v(a);c.trigger("sortBegin",this);I(a);A(a,f);"function"===typeof d&&d(a)}).bind("appendCache.tablesorter",function(b,c,d){b.stopPropagation();A(a,d);"function"===typeof c&&c(a)}).bind("applyWidgetId.tablesorter",function(c,e){c.stopPropagation();f.getWidgetById(e).format(a,b,b.widgetOptions)}).bind("applyWidgets.tablesorter",function(b,c){b.stopPropagation();f.applyWidget(a,c)}).bind("refreshWidgets.tablesorter",
function(b,c,d){b.stopPropagation();f.refreshWidgets(a,c,d)}).bind("destroy.tablesorter",function(b,c,d){b.stopPropagation();f.destroy(a,c,d)})}var f=this;f.version="2.15.3";f.parsers=[];f.widgets=[];f.defaults={theme:"default",widthFixed:!1,showProcessing:!1,headerTemplate:"{content}",onRenderTemplate:null,onRenderHeader:null,cancelSelection:!0,tabIndex:!0,dateFormat:"mmddyyyy",sortMultiSortKey:"shiftKey",sortResetKey:"ctrlKey",usNumberFormat:!0,delayInit:!1,serverSideSorting:!1,headers:{},ignoreCase:!0, sortForce:null,sortList:[],sortAppend:null,sortStable:!1,sortInitialOrder:"asc",sortLocaleCompare:!1,sortReset:!1,sortRestart:!1,emptyTo:"bottom",stringTo:"max",textExtraction:"simple",textSorter:null,numberSorter:null,widgets:[],widgetOptions:{zebra:["even","odd"]},initWidgets:!0,initialized:null,tableClass:"",cssAsc:"",cssDesc:"",cssNone:"",cssHeader:"",cssHeaderRow:"",cssProcessing:"",cssChildRow:"tablesorter-childRow",cssIcon:"tablesorter-icon",cssInfoBlock:"tablesorter-infoOnly",selectorHeaders:"> thead th, > thead td", selectorSort:"th, td",selectorRemove:".remove-me",debug:!1,headerList:[],empties:{},strings:{},parsers:[]};f.css={table:"tablesorter",childRow:"tablesorter-childRow",header:"tablesorter-header",headerRow:"tablesorter-headerRow",headerIn:"tablesorter-header-inner",icon:"tablesorter-icon",info:"tablesorter-infoOnly",processing:"tablesorter-processing",sortAsc:"tablesorter-headerAsc",sortDesc:"tablesorter-headerDesc",sortNone:"tablesorter-headerUnSorted"};f.language={sortAsc:"Ascending sort applied, ", sortDesc:"Descending sort applied, ",sortNone:"No sort applied, ",nextAsc:"activate to apply an ascending sort",nextDesc:"activate to apply a descending sort",nextNone:"activate to remove the sort"};f.log=d;f.benchmark=u;f.construct=function(a){return this.each(function(){var b=g.extend(!0,{},f.defaults,a);
!this.hasInitialized&&f.buildTable&&"TABLE"!==this.tagName&&f.buildTable(this,b);f.setup(this,b)})};f.setup=function(a,b){if(!a||!a.tHead||0===a.tBodies.length||!0===a.hasInitialized)return b.debug? d("ERROR: stopping initialization! No table, thead, tbody or tablesorter has already been initialized"):"";var c="",h=g(a),e=g.metadata;a.hasInitialized=!1;a.isProcessing=!0;a.config=b;g.data(a,"tablesorter",b);b.debug&&g.data(a,"startoveralltimer",new Date);b.supportsTextContent="x"===g("<span>x</span>")[0].textContent;b.supportsDataObject=function(a){a[0]=parseInt(a[0],10);return 1<a[0]||1===a[0]&&4<=parseInt(a[1],10)}(g.fn.jquery.split("."));b.string={max:1,min:-1,"max+":1,"max-":-1,zero:0,none:0, "null":0,top:!0,bottom:!1};/tablesorter\-/.test(h.attr("class"))||(c=""!==b.theme?" tablesorter-"+b.theme:"");b.$table=h.addClass(f.css.table+" "+b.tableClass+c).attr({role:"grid"});b.$tbodies=h.children("tbody:not(."+b.cssInfoBlock+")").attr({"aria-live":"polite","aria-relevant":"all"});b.$table.find("caption").length&&b.$table.attr("aria-labelledby","theCaption");b.widgetInit={};E(a);L(a);t(a);b.delayInit||v(a);f.bindEvents(a,b.$headers);K(a);b.supportsDataObject&&"undefined"!==typeof h.data().sortlist? b.sortList=h.data().sortlist:e&&h.metadata()&&h.metadata().sortlist&&(b.sortList=h.metadata().sortlist);
f.applyWidget(a,!0);0<b.sortList.length?h.trigger("sorton",[b.sortList,{},!b.initWidgets]):(F(a),b.initWidgets&&f.applyWidget(a));b.showProcessing&&h.unbind("sortBegin.tablesorter sortEnd.tablesorter").bind("sortBegin.tablesorter sortEnd.tablesorter",function(b){f.isProcessing(a,"sortBegin"===b.type)});a.hasInitialized=!0;a.isProcessing=!1;b.debug&&f.benchmark("Overall initialization time",g.data(a, "startoveralltimer"));h.trigger("tablesorter-initialized",a);"function"===typeof b.initialized&&b.initialized(a)};f.isProcessing=function(a,b,c){a=g(a);var h=a[0].config;a=c||a.find("."+f.css.header);b?("undefined"!==typeof c&&0<h.sortList.length&&(a=a.filter(function(){return this.sortDisabled?!1:f.isValueInArray(parseFloat(g(this).attr("data-column")),h.sortList)})),a.addClass(f.css.processing+" "+h.cssProcessing)):a.removeClass(f.css.processing+" "+h.cssProcessing)};f.processTbody=function(a,b, c){a=g(a)[0];if(c)return a.isProcessing=!0,b.before('<span class="tablesorter-savemyplace"/>'),c=g.fn.detach?b.detach():b.remove();c=g(a).find("span.tablesorter-savemyplace");b.insertAfter(c);c.remove();a.isProcessing=!1};f.clearTableBody=function(a){g(a)[0].config.$tbodies.empty()};f.bindEvents=function(a,b){a=g(a)[0];var c,h=a.config;b.find(h.selectorSort).add(b.filter(h.selectorSort)).unbind("mousedown.tablesorter mouseup.tablesorter sort.tablesorter keyup.tablesorter").bind("mousedown.tablesorter mouseup.tablesorter sort.tablesorter keyup.tablesorter", function(e,d){var f;f=e.type;
if(!(1!==(e.which||e.button)&&!/sort|keyup/.test(f)||"keyup"===f&&13!==e.which||"mouseup"===f&&!0!==d&&250<(new Date).getTime()-c)){if("mousedown"===f)return c=(new Date).getTime(),"INPUT"===e.target.tagName?"":!h.cancelSelection;h.delayInit&&m(h.cache)&&v(a);f=/TH|TD/.test(this.tagName)?this:g(this).parents("th, td")[0];f=h.$headers[b.index(f)];f.sortDisabled||O(a,f,e)}});h.cancelSelection&&b.attr("unselectable","on").bind("selectstart",!1).css({"user-select":"none", MozUserSelect:"none"})};f.restoreHeaders=function(a){var b=g(a)[0].config;b.$table.find(b.selectorHeaders).each(function(a){g(this).find("."+f.css.headerIn).length&&g(this).html(b.headerContent[a])})};f.destroy=function(a,b,c){a=g(a)[0];if(a.hasInitialized){f.refreshWidgets(a,!0,!0);var h=g(a),e=a.config,d=h.find("thead:first"),k=d.find("tr."+f.css.headerRow).removeClass(f.css.headerRow+" "+e.cssHeaderRow),n=h.find("tfoot:first > tr").children("th, td");d.find("tr").not(k).remove();h.removeData("tablesorter").unbind("sortReset update updateAll updateRows updateCell addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave keypress sortBegin sortEnd ".split(" ").join(".tablesorter ")); e.$headers.add(n).removeClass([f.css.header,e.cssHeader,e.cssAsc,e.cssDesc,f.css.sortAsc,f.css.sortDesc,f.css.sortNone].join(" ")).removeAttr("data-column");k.find(e.selectorSort).unbind("mousedown.tablesorter mouseup.tablesorter keypress.tablesorter");f.restoreHeaders(a);!1!==b&&h.removeClass(f.css.table+" "+e.tableClass+" tablesorter-"+e.theme);a.hasInitialized=!1;"function"===typeof c&&c(a)}};
f.regex={chunk:/(^([+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?)?$|^0x[0-9a-f]+$|\d+)/gi,hex:/^0x[0-9a-f]+$/i}; f.sortNatural=function(a,b){if(a===b)return 0;var c,h,e,d,g,n;h=f.regex;if(h.hex.test(b)){c=parseInt(a.match(h.hex),16);e=parseInt(b.match(h.hex),16);if(c<e)return-1;if(c>e)return 1}c=a.replace(h.chunk,"\\0$1\\0").replace(/\\0$/,"").replace(/^\\0/,"").split("\\0");h=b.replace(h.chunk,"\\0$1\\0").replace(/\\0$/,"").replace(/^\\0/,"").split("\\0");n=Math.max(c.length,h.length);for(g=0;g<n;g++){e=isNaN(c[g])?c[g]||0:parseFloat(c[g])||0;d=isNaN(h[g])?h[g]||0:parseFloat(h[g])||0;if(isNaN(e)!==isNaN(d))return isNaN(e)? 1:-1;typeof e!==typeof d&&(e+="",d+="");if(e<d)return-1;if(e>d)return 1}return 0};f.sortNaturalAsc=function(a,b,c,d,e){if(a===b)return 0;c=e.string[e.empties[c]||e.emptyTo];return""===a&&0!==c?"boolean"===typeof c?c?-1:1:-c||-1:""===b&&0!==c?"boolean"===typeof c?c?1:-1:c||1:f.sortNatural(a,b)};f.sortNaturalDesc=function(a,b,c,d,e){if(a===b)return 0;c=e.string[e.empties[c]||e.emptyTo];return""===a&&0!==c?"boolean"===typeof c?c?-1:1:c||1:""===b&&0!==c?"boolean"===typeof c?c?1:-1:-c||-1:f.sortNatural(b, a)};f.sortText=function(a,b){return a>b?1:a<b?-1:0};f.getTextValue=function(a,b,c){if(c){var d=a?a.length:0,e=c+b;for(c=0;c<d;c++)e+=a.charCodeAt(c);return b*e}return 0};f.sortNumericAsc=function(a,b,c,d,e,g){if(a===b)return 0;g=g.config;e=g.string[g.empties[e]||g.emptyTo];
if(""===a&&0!==e)return"boolean"===typeof e?e?-1:1:-e||-1;if(""===b&&0!==e)return"boolean"===typeof e?e?1:-1:e||1;isNaN(a)&&(a=f.getTextValue(a,c,d));isNaN(b)&&(b=f.getTextValue(b,c,d));return a-b};f.sortNumericDesc=function(a, b,c,d,e,g){if(a===b)return 0;g=g.config;e=g.string[g.empties[e]||g.emptyTo];if(""===a&&0!==e)return"boolean"===typeof e?e?-1:1:e||1;if(""===b&&0!==e)return"boolean"===typeof e?e?1:-1:-e||-1;isNaN(a)&&(a=f.getTextValue(a,c,d));isNaN(b)&&(b=f.getTextValue(b,c,d));return b-a};f.sortNumeric=function(a,b){return a-b};f.characterEquivalents={a:"\u00e1\u00e0\u00e2\u00e3\u00e4\u0105\u00e5",A:"\u00c1\u00c0\u00c2\u00c3\u00c4\u0104\u00c5",c:"\u00e7\u0107\u010d",C:"\u00c7\u0106\u010c",e:"\u00e9\u00e8\u00ea\u00eb\u011b\u0119", E:"\u00c9\u00c8\u00ca\u00cb\u011a\u0118",i:"\u00ed\u00ec\u0130\u00ee\u00ef\u0131",I:"\u00cd\u00cc\u0130\u00ce\u00cf",o:"\u00f3\u00f2\u00f4\u00f5\u00f6",O:"\u00d3\u00d2\u00d4\u00d5\u00d6",ss:"\u00df",SS:"\u1e9e",u:"\u00fa\u00f9\u00fb\u00fc\u016f",U:"\u00da\u00d9\u00db\u00dc\u016e"};f.replaceAccents=function(a){var b,c="[",d=f.characterEquivalents;if(!f.characterRegex){f.characterRegexArray={};for(b in d)"string"===typeof b&&(c+=d[b],f.characterRegexArray[b]=RegExp("["+d[b]+"]","g"));f.characterRegex= RegExp(c+"]")}if(f.characterRegex.test(a))for(b in d)"string"===typeof b&&(a=a.replace(f.characterRegexArray[b],b));return a};f.isValueInArray=function(a,b){var c,d=b.length;for(c=0;c<d;c++)if(b[c][0]===a)return!0;return!1};f.addParser=function(a){var b,c=f.parsers.length,d=!0;for(b=0;b<c;b++)f.parsers[b].id.toLowerCase()===a.id.toLowerCase()&&(d=!1);d&&f.parsers.push(a)};f.getParserById=function(a){var b,c=f.parsers.length;for(b=0;b<c;b++)if(f.parsers[b].id.toLowerCase()===a.toString().toLowerCase())return f.parsers[b];
return!1};f.addWidget=function(a){f.widgets.push(a)};f.getWidgetById=function(a){var b,c,d=f.widgets.length;for(b=0;b<d;b++)if((c=f.widgets[b])&&c.hasOwnProperty("id")&&c.id.toLowerCase()===a.toLowerCase())return c};f.applyWidget=function(a,b){a=g(a)[0];var c=a.config,d=c.widgetOptions,e=[],m,k,n;c.debug&&(m=new Date);c.widgets.length&&(c.widgets=g.grep(c.widgets,function(a,b){return g.inArray(a,c.widgets)===b}),g.each(c.widgets||[],function(a,b){(n=f.getWidgetById(b))&&n.id&&(n.priority||(n.priority= 10),e[a]=n)}),e.sort(function(a,b){return a.priority<b.priority?-1:a.priority===b.priority?0:1}),g.each(e,function(e,f){if(f){if(b||!c.widgetInit[f.id])f.hasOwnProperty("options")&&(d=a.config.widgetOptions=g.extend(!0,{},f.options,d)),f.hasOwnProperty("init")&&f.init(a,f,c,d),c.widgetInit[f.id]=!0;!b&&f.hasOwnProperty("format")&&f.format(a,c,d,!1)}}));c.debug&&(k=c.widgets.length,u("Completed "+(!0===b?"initializing ":"applying ")+k+" widget"+(1!==k?"s":""),m))};f.refreshWidgets=function(a,b,c){a= g(a)[0];var h,e=a.config,m=e.widgets,k=f.widgets,n=k.length;for(h=0;h<n;h++)k[h]&&k[h].id&&(b||0>g.inArray(k[h].id,m))&&(e.debug&&d('Refeshing widgets: Removing "'+k[h].id+'"'),k[h].hasOwnProperty("remove")&&e.widgetInit[k[h].id]&&(k[h].remove(a,e,e.widgetOptions),e.widgetInit[k[h].id]=!1));!0!==c&&f.applyWidget(a,b)};f.getData=function(a,b,c){var d="";a=g(a);var e,f;if(!a.length)return"";e=g.metadata?a.metadata():!1;
f=" "+(a.attr("class")||"");"undefined"!==typeof a.data(c)||"undefined"!==typeof a.data(c.toLowerCase())? d+=a.data(c)||a.data(c.toLowerCase()):e&&"undefined"!==typeof e[c]?d+=e[c]:b&&"undefined"!==typeof b[c]?d+=b[c]:" "!==f&&f.match(" "+c+"-")&&(d=f.match(RegExp("\\s"+c+"-([\\w-]+)"))[1]||"");return g.trim(d)};f.formatFloat=function(a,b){if("string"!==typeof a||""===a)return a;var c;a=(b&&b.config?!1!==b.config.usNumberFormat:"undefined"!==typeof b?b:1)?a.replace(/,/g,""):a.replace(/[\s|\.]/g,"").replace(/,/g,".");/^\s*\([.\d]+\)/.test(a)&&(a=a.replace(/^\s*\(([.\d]+)\)/,"-$1"));c=parseFloat(a);return isNaN(c)? g.trim(a):c};f.isDigit=function(a){return isNaN(a)?/^[\-+(]?\d+[)]?$/.test(a.toString().replace(/[,.'"\s]/g,"")):!0}}});var p=g.tablesorter;g.fn.extend({tablesorter:p.construct});p.addParser({id:"text",is:function(){return!0},format:function(d,u){var m=u.config;d&&(d=g.trim(m.ignoreCase?d.toLocaleLowerCase():d),d=m.sortLocaleCompare?p.replaceAccents(d):d);return d},type:"text"});p.addParser({id:"digit",is:function(d){return p.isDigit(d)},format:function(d,u){var m=p.formatFloat((d||"").replace(/[^\w,. \-()]/g, ""),u);return d&&"number"===typeof m?m:d?g.trim(d&&u.config.ignoreCase?d.toLocaleLowerCase():d):d},type:"numeric"});p.addParser({id:"currency",is:function(d){return/^\(?\d+[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]|[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]\d+\)?$/.test((d||"").replace(/[+\-,. ]/g,""))},format:function(d,u){var m=p.formatFloat((d||"").replace(/[^\w,. \-()]/g,""),u);return d&&"number"===typeof m?m:d?g.trim(d&&u.config.ignoreCase?d.toLocaleLowerCase():d):d},type:"numeric"});p.addParser({id:"ipAddress", is:function(d){return/^\d{1,3}[\.]\d{1,3}[\.]\d{1,3}[\.]\d{1,3}$/.test(d)},format:function(d,g){var m,s=d?d.split("."):"",t="",v=s.length;
for(m=0;m<v;m++)t+=("00"+s[m]).slice(-3);return d?p.formatFloat(t,g):d},type:"numeric"});p.addParser({id:"url",is:function(d){return/^(https?|ftp|file):\/\//.test(d)},format:function(d){return d?g.trim(d.replace(/(https?|ftp|file):\/\//,"")):d},type:"text"});p.addParser({id:"isoDate",is:function(d){return/^\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2}/.test(d)},format:function(d, g){return d?p.formatFloat(""!==d?(new Date(d.replace(/-/g,"/"))).getTime()||"":"",g):d},type:"numeric"});p.addParser({id:"percent",is:function(d){return/(\d\s*?%|%\s*?\d)/.test(d)&&15>d.length},format:function(d,g){return d?p.formatFloat(d.replace(/%/g,""),g):d},type:"numeric"});p.addParser({id:"usLongDate",is:function(d){return/^[A-Z]{3,10}\.?\s+\d{1,2},?\s+(\d{4})(\s+\d{1,2}:\d{2}(:\d{2})?(\s+[AP]M)?)?$/i.test(d)||/^\d{1,2}\s+[A-Z]{3,10}\s+\d{4}/i.test(d)},format:function(d,g){return d?p.formatFloat((new Date(d.replace(/(\S)([AP]M)$/i, "$1 $2"))).getTime()||"",g):d},type:"numeric"});p.addParser({id:"shortDate",is:function(d){return/(^\d{1,2}[\/\s]\d{1,2}[\/\s]\d{4})|(^\d{4}[\/\s]\d{1,2}[\/\s]\d{1,2})/.test((d||"").replace(/\s+/g," ").replace(/[\-.,]/g,"/"))},format:function(d,g,m,s){if(d){m=g.config;
var t=m.$headers.filter("[data-column="+s+"]:last");s=t.length&&t[0].dateFormat||p.getData(t,m.headers[s],"dateFormat")||m.dateFormat;d=d.replace(/\s+/g," ").replace(/[\-.,]/g,"/");"mmddyyyy"===s?d=d.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/, "$3/$1/$2"):"ddmmyyyy"===s?d=d.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/,"$3/$2/$1"):"yyyymmdd"===s&&(d=d.replace(/(\d{4})[\/\s](\d{1,2})[\/\s](\d{1,2})/,"$1/$2/$3"))}return d?p.formatFloat((new Date(d)).getTime()||"",g):d},type:"numeric"});p.addParser({id:"time",is:function(d){return/^(([0-2]?\d:[0-5]\d)|([0-1]?\d:[0-5]\d\s?([AP]M)))$/i.test(d)},format:function(d,g){return d?p.formatFloat((new Date("2000/01/01 "+d.replace(/(\S)([AP]M)$/i,"$1 $2"))).getTime()||"",g):d},type:"numeric"});p.addParser({id:"metadata", is:function(){return!1},format:function(d,p,m){d=p.config;d=d.parserMetadataName?d.parserMetadataName:"sortValue";return g(m).metadata()[d]},type:"numeric"});p.addWidget({id:"zebra",priority:90,format:function(d,u,m){var s,t,v,A,D,C,E=RegExp(u.cssChildRow,"i"),B=u.$tbodies;u.debug&&(D=new Date);for(d=0;d<B.length;d++)s=B.eq(d),C=s.children("tr").length,1<C&&(v=0,s=s.children("tr:visible").not(u.selectorRemove),s.each(function(){t=g(this);E.test(this.className)||v++;A=0===v%2;t.removeClass(m.zebra[A? 1:0]).addClass(m.zebra[A?0:1])}));u.debug&&p.benchmark("Applying Zebra widget",D)},remove:function(d,p,m){var s;p=p.$tbodies;var t=(m.zebra||["even","odd"]).join(" ");for(m=0;m<p.length;m++)s=g.tablesorter.processTbody(d,p.eq(m),!0),s.children().removeClass(t),g.tablesorter.processTbody(d,s,!1)}})}(jQuery);

/*! Analyzer JavaScript, 2.4 2022/09/01 00:00:00 dnhoward */

/* ********************************************************
    Global variables
******************************************************** */
var MASK_KEY = "";
var FILTER_STRING = "";
/* EBSAF-202 Improved floating header tracking */
var HEADER_SIZE = 0;
var FOOTER_SIZE = 0;
/* EBSAF-287 Disable export functionality */
var DISABLE_EXPORT = false;

/* ********************************************************
    Main handler for document ready
******************************************************** */
$(document).ready(function(){
    /* Before anything else, verify if the file is complete and alert otherwise    */
    if (! $("#integrityCheck").length ) {
        alert("The file is incomplete or corrupt and will not be displayed correctly!\n" +
            "You might be able to view a partial content using Data View / Full View.");
    }

    /* Build dynamic content areas */
    buildTagsArea();
    buildSectionMenu();
    buildMainMenu();
    showExceptions();

    /* Register event handlers */
    $(window).resize(UpdateHeaderFooter).trigger("resize");
    $(window).scroll(UpdateTableHeaders).trigger("scroll");
    registerPopupHandlers();
    registerViewHandlers();
    registerIconHandlers();
    registerExpColAllHandlers();
    registerSearchHandlers();
    registerSignatureHandlers();
    registerMaskingHandlers();
    registerExportHandlers();
    registerSortHandlers();
    registerHideHandlers();

    /* Update content */
    fixAnchorUrls();
    updateFailRows();
    updateInternalViewer();
});
/* ********************************************************
    End of document ready
******************************************************** */

function UpdateHeaderFooter(){
    HEADER_SIZE = $("div.pageheader").height();
    FOOTER_SIZE = $("div.footerarea").height();
}

/* Maintain the persistent table header positions when scrolling */
function UpdateTableHeaders() {
    $(".parea:visible").each(function() {
        var el             = $(this);
        var offset         = el.offset();
        var scrollTop      = $(window).scrollTop() + HEADER_SIZE;
        var floatingHeader = $(".floatingHeader", this);
        var persistHeader  = $(".pheader", this);
        var undocked = (persistHeader.attr("undocked") == "true");

        if ((scrollTop > offset.top) && (scrollTop < offset.top + el.height())) {
            /* EBSAF-214 Maintain horizontal alignment */
            var offsetLeft = Math.round(offset.left - $(window).scrollLeft() ) + "px";
            if (persistHeader.css("left") != offsetLeft) {
                persistHeader.css("left", offsetLeft);
            }

            /* EBSAF-202 Persistent header is undocked to stay on screen */
            if (!undocked) {
                floatingHeader.attr("docked","true");
                persistHeader.attr("undocked","true");
            }
        } else {
            /* EBSAF-202 Persistent header is docked when table off screen*/
            if (undocked) {
                floatingHeader.removeAttr("docked");
                persistHeader.removeAttr("undocked");
            }
        };
    });
}


/* Build the section for filtering signatures by associated tags */
function buildTagsArea(){
    /* if there is no tags div defined, nothing to do */
    if ($("div.sigtag").size() <= 0) return;

    var myList=[];

    /* gather a list with all the tags */
    $(".sigtag").each(function(){
        var myIA = $(this).attr("tag");
        if (myList.indexOf(myIA) < 0) {
            myList.push(myIA);
        }
    });

    /* no tags, do nothing */
    if (myList.length <= 0) return;

    var iaTable = "<table class='table2'><thead><tr><th bgcolor='#f2f4f7'>Impact Areas</th><th bgcolor='#f2f4f7'>Count</th></tr></thead>\n";

    myList.forEach(function(item){
        var count = $("div.sigtag[tag='" + item + "']").size();
        iaTable += "<tr><td>" + item + "</td><td><div class='tagFilter' filter='" + item + "'><a class='tagcount' show-tag='" + item + "'>" + count + "</a></div></td></tr>\n";
    });
    iaTable += "</table>";
    $("#tags_area").html(iaTable);
    $("#tags_area").addClass("print");

    /* Add click handlers */
    $("a[show-tag]").on("click", function(){
        var tagID = $(this).attr("show-tag");
        $(".sigcontainer.data").hide();
        $(".tags").show();
        $(".sigtag[tag='" + tagID + "']").parent().show();
    });
}

/* Event handlers for pop-up windows */
function registerPopupHandlers() {
    var popupVisible=false;

    /* Show banner */
    $("#banner").show();

    /* Open pop-up window*/
    $("[data-popup-open]").on("click", function()  {
        var targeted_popup_class = jQuery(this).attr("data-popup-open");
        $("[data-popup]").hide();
        $("[data-popup='" + targeted_popup_class + "']").fadeIn(350, function(){
           popupVisible = true;
        });
    });
`' ||
q'`
    /* Close pop-up window*/
    $("[data-popup-close]").on("click", function()  {
        var targeted_popup_class = jQuery(this).attr("data-popup-close");
        $("[data-popup='" + targeted_popup_class + "']").fadeOut(350, function(){
           popupVisible = false;
        });
    });

    /* Close active pop-up window when clicking outside its boundaries*/
    $("body").click(function(e) {
       if (popupVisible == true){
          if (!e) e = window.event;
          if ((!$(e.target).parents().hasClass("popup-inner")) && ($(e.target).attr("id")!="execDetails") && ($(e.target).attr("id")!="execParameters")){
             $("[data-popup-close]").click();
          }
       }
    });

    /* Close active pop-up window when pressing Esc, Space or Enter*/
    $(document).keydown(function(e) {
       if (((e.which == 13) || (e.which == 32) || (e.which == 27)) && popupVisible == true) {
             $("[data-popup-close]").click();
       }
    });
}

/* Event handlers for changing views/sections */
function registerViewHandlers() {

    /* Open home page */
    $("#homeButton").click(function(){
        $(".data").hide();
        $(".maindata").hide();
        $(".mainmenu").show();
        $("#search").val("");
    });

    /* Open section (by section name or by error type)*/
    $("[open-section]").on("click", function()  {
        var sectionID = jQuery(this).attr("open-section");
        var sectionName = jQuery(this).find("div.textbox").text();
        var sectionTitle = {"E": "Error Signatures",
                            "W": "Warning Signatures",
                            "S": "Successful Signatures",
                            "I": "Informational Signatures",
                            "P": "Background Passed Checks"};
        if ((sectionName == null) || (sectionName == "")){
            sectionName = sectionTitle[sectionID];
        }
        FILTER_STRING = sectionID;

        /* if the section is empty, do nothing*/
        if ($("." + sectionID).size() <= 0) {
           return;
        }

        /* Hide banner */
        $("#banner").hide();

        /* Reset indent for section roots */
        $("#sectionmenu .sct-submenu[sct-root='true']").attr("sct-root", "false");
        $("#" + sectionID + "_submenu").attr("sct-root", "true");

        $(".mainmenu").hide();
        $(".data").hide();
        $(".section").show();
        $(".signature").hide();
        $("." + sectionID).show();
        $("#search").val("");
        $("#showhidesection").attr("mode", "show");
        $("span.brokenlink").hide();

        $("#export2TextLink").attr("onClick", "onclick=export2PaddedText('" + sectionID + "', 0);return false;");
        $(".exportAllImg").attr("onClick", "export2CSV('" + sectionID + "', 'section')");

        $(".containertitle").html(sectionName);

        if ((sectionID == 'error') || (sectionID == 'success') || (sectionID == 'information') || (sectionID == 'warning')) {
            $(".sectionview").attr("open-sig-class", sectionID + "sig");
        } else {
            $(".sectionview").attr("open-sig-class", sectionID);
        }
        $("a[siglink]").removeAttr("href");  /* remove links between signature records in section view*/
        $("a[siglink]").removeClass("hypersource");
        $("a[siglink]").addClass("nolink");
        $("#sectionmenu .sectionbutton." + sectionID).filter(":visible").first().click();
    });


    /* Print, Analysis and Full Section view */
    $("[open-sig-class]").on("click", function(){
        var sigClassID = jQuery(this).attr("open-sig-class");

        /* hide everything first*/
        $(".mainmenu").hide();
        $(".data").hide();
        $("#search").val("");
        $("#banner").hide();


        if (sigClassID == "print"){
            $(".containertitle").html("Full View");
            $("#expandall").attr("mode", "print");
            $("#collapseall").attr("mode", "print");

            FILTER_STRING="";
            /* show all divs that have the print class*/
            $(".print").show();
            $("a[siglink]").removeAttr("href");  /* remove links between signature records in print view */
            $("a[siglink]").removeClass("hypersource");
            $("a[siglink]").addClass("nolink");
            $("span.brokenlink").hide();
            $(".exportAllImg").attr("onClick", "export2CSV('ALL')");

        } else if (sigClassID == "analysis") {
            $(".containertitle").html("Data View");
            $("#expandall").attr("mode", "analysis");
            $("#collapseall").attr("mode", "analysis");
            FILTER_STRING="";
            /* show all divs that have the analysis class*/
            $(".analysis").show();

            /* add links to the records that are interconnected (links are saved in a separate attribute named siglink)*/
            $("a[siglink]").each(function(){
               /* if target anchor exists, create the link. Otherwise, display an exclamation mark*/
               if ($("a#" + $(this).attr("siglink") + ".anchor").length > 0){
                   $(this).attr("href", "#" + $(this).attr("siglink"));
                   $(this).addClass("hypersource");
                   $(this).removeClass("nolink");
               } else {
                   $(this).closest('td').find('span.brokenlink').show();
               }
            });

        } else if (sigClassID == "passed"){
            /* Short summary of background passed checks. No search, export, checkboxes, etc. */
            $(".containertitle").html("Background Passed Checks");
            $(".signature").hide();
            $(".P").show();
        } else if (sigClassID == "exception"){
            /* Short summary of signature exceptions. No search, export, checkboxes, etc. */
            $(".containertitle").html("Exceptions Occurred");
            $(".signature").hide();
            $(".X").show();
            $(".maindata").show();
        } else { /* Entire Section view */
            if ($("#showhidesection").attr("mode") == "show") {
                if (/^(E|I|S|W)$/.test(sigClassID)){
                    $(".sigrescode."+sigClassID).parents("div.sigcontainer").show();
                } else {
                    $("." + sigClassID).show();
                }
                $(".fullsection").show();
                FILTER_STRING = sigClassID;
                $("#showhidesection").attr("mode", "hide");
                $("#expandall").attr("mode", "print");
                $("#collapseall").attr("mode", "print");
            } else {
                $(".section").show();
                $(".signature").hide();
                $("#showhidesection").attr("mode", "show");
                $("[open-section='"+sigClassID+"']").click();
            }
        }

        resetHiddenDataSigs();
    });
}

/* Event handlers for all button icons */
function registerIconHandlers() {
    // Add animation to indicate something happened
    $(".divItemTitle .detailsmall").click(function(){
        $(this).fadeTo(200, 0.5, function () {
            $(this).fadeTo(200, 1.0, function () {
                $(this).removeAttr("style");
            });
        })
    });
}

/* Event handlers for Expand/Collapse All buttons */
function registerExpColAllHandlers() {
    var alertOn = true;

    /* Ensure proper view classes on buttons */
    $("#expandall").addClass("fullsection data print analysis");
    $("#collapseall").addClass("fullsection data print analysis");

    $("#expandall").on("click", function(){
        if (alertOn){
            var returnVal = confirm ("This action could lead to performance issues and might even freeze your browser window. Do you want to continue?");
            if (returnVal == false) return;
            alertOn = false;
        }
        if (returnVal == false) return;
        $(".tabledata").show();
        if ($("#expandall").attr("mode") == "print"){
            $(".results").show();
        }
        $(".arrowright").hide();
        $(".arrowdown").show();
        var e = jQuery.Event("keypress");
        e.keyCode = 13;
        $("#search").trigger(e);
        $(".parea").each(function() {
            /* EBSAF-202 Build all floating headers */
            buildFloatingHeader( $(this).attr("id") );
        });
    });
    $("#collapseall").on("click", function(){
        $(".tabledata").hide();
        if ($("#collapseall").attr("mode") == "print"){
            $(".results").show();
        } else {
            $(".results").hide();
        }
        $(".arrowright").show();
        $(".arrowdown").hide();
        $(".parea").each(function() {
            /* EBSAF-202 Remove all floating headers */
            removeFloatingHeader( $(this).attr("id") );
        });
    });
}

/* Event handlers for searching data */
function registerSearchHandlers() {
    var searchFlag = false;
    var isOldBrowser = false;
    var ua = navigator.userAgent;
    var browserDetails = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
    /* if browser is firefox and version is 45 or lower, do not hide rows when filtering. Only highlight those that match.*/
    if ((browserDetails[1] == "Firefox") && (browserDetails[2] <= 45)) {
        isOldBrowser = true;
    }

    /* Dynamic display based on the search string*/
    $("#search").keypress (function(e) {
       if (e.keyCode == 13){
         /* EBSAF-210 Clear all existing matches first */
         $(".search_match").removeClass("search_match");

         var searchTerm = $("#search").val().toLowerCase();
         $.extend($.expr[":"], {
             "containsi": function(elem, i, match, array) {
               return (elem.textContent || elem.innerText || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
             }
         });

         if (!isOldBrowser) { /* if the browser is not old, show only rows that include the string and hide the rest of the rows. */

            if ((searchTerm == null) || (searchTerm == "")) {
               if (!searchFlag){
                  return;
               } else {
                  var rowList = FILTER_STRING ? $(".tdata."+FILTER_STRING+":hidden") : $(".tdata:hidden");
                  rowList.show();
               }
               return;
            }
            var $showRows = FILTER_STRING ? $(".tdata."+FILTER_STRING+":containsi('"+searchTerm+"')") : $(".tdata:containsi('"+searchTerm+"')");
            var $noShow = FILTER_STRING ? $(".tdata."+FILTER_STRING).not(":containsi('"+searchTerm+"')") : $(".tdata").not(":containsi('"+searchTerm+"')");

            $noShow.css("display","none");
            /*$showRows.css("display","table-row");*/
            $showRows.addClass("search_match").css("display","table-row");
            $($showRows.closest(".tabledata")).show();

         } else { /* is old browser, do not repaint, just highlight */
            /* if string is empty, show everything and return*/
            if ((searchTerm == null) || (searchTerm == "")) {

                if (!searchFlag){
                   return;
                } else {
                   searchFlag=false;
                   $(".tdata").css("background-color", "white");
                   return;
                }
            }

            $(".tdata").not(":containsi('" + searchTerm + "')").css("background-color", "white");
            /*$(".tdata:containsi('" + searchTerm + "')").css("background-color", "#ffffe6");*/
            $(".tdata:containsi('" + searchTerm + "')").addClass("search_match").css("background-color", "#ffffe6");  /* EBSAF-210 */

         }

        /* EBSAF-210 Add column headers to search */
        var $headRows = FILTER_STRING ? $(".tdata."+FILTER_STRING).closest(".tabledata").find("thead tr:containsi('"+searchTerm+"')") : $(".tdata").closest(".tabledata").find("thead tr:containsi('"+searchTerm+"')");
        $headRows.addClass("search_match");
        $($headRows.closest(".tabledata")).show();

        /* EBSAF-210 Highlight matching cells */
        var $showCols = $("tr.search_match").children(":containsi('"+searchTerm+"')");
        $showCols.addClass("search_match");
      }
      searchFlag = true;
   });
}

/* Event handlers for showing signatures and their components */
function registerSignatureHandlers() {
    /* Open signature */
    $("[open-sig]").on("click", function()  {
        var sigID = jQuery(this).attr("open-sig");

        $(".signature").hide();
        $(".sectionbutton").css("background-color", "");
        $(".export2Txt").hide();
        $("#SignatureTitle").html("Signature: " + sigID);
        $("." + sigID).show();
        $(".sectionbutton[open-sig='" + sigID + "']").css("background-color","white");
        var e = jQuery.Event("keypress");
        e.keyCode = 13;
        $("#search").focus();
        $("#search").trigger(e);
    });

    /* Open table data for a sig    */
    $("a[toggle-data]").on("click", function(){
        var $tabledataID = $(this).attr("toggle-data");
        var $dataTable = $("#"+$tabledataID);
        $dataTable.toggle();
        $(this).find(".arrowright").toggle();
        if ($(this).find(".arrowdown").css("display") == "none"){
            $(this).find(".arrowdown").show();
            /* EBSAF-202 Build the floating header if missing */
            buildFloatingHeader($tabledataID);
        } else {
            $(this).find(".arrowdown").hide();
            /* EBSAF-202 Remove the floating header if present */
            removeFloatingHeader($tabledataID);
        };
        var e = jQuery.Event("keypress");
        e.keyCode = 13; /* Enter */
        $("#search").trigger(e);
    });

    /* Toggle header information */
    $("a[toggle-info]").on("click", function(){
        var infoID = $(this).attr("toggle-info");
        $("#"+infoID).toggle();
    });
}

/* Event handlers for masking options */
function registerMaskingHandlers() {
    /* if masking is enabled, mask column when user clicks on a column header */
    $("th.sigdetails").on('click', function(){
        var $maskDiv=$(this).closest('div.sigcontainer').find('span.mask');
        var $maskOn = $maskDiv.hasClass('mask_enabled') ? true : false;
        /* if masking is not enabled for the sig, do nothing */
        if (($maskOn != true) || (MASK_KEY.length <= 0)) return;
        /* if masking is already enabled on the column, do nothing */
        if ($(this).attr('mask') == 'on') return;

        /* obtain the column number - starts from 0 */
        var $table = $(this).closest(".table1.tabledata");
        var $colNo = $(this).parent().children().index($(this));
        $colNo++;  /* nth-child starts from 1 */

        /* EBSAF-258 Verify masking allowed first so error only occurs once */
        var validCol = true;
        $table.find("tr.tdata").each(function(){
            if (validCol) {
                var $cell = $(this).find('td:nth-child(' + $colNo + ')');
                if ($cell.find("a").length > 0) {
                   alert ("This column includes a link. It cannot be masked");
                   validCol = false;
                }
            }
        });

        /* Do masking for the column */
        if (validCol) {
            var $sigId=$(this).closest('div.sigcontainer').attr('sigid');
            var $colId=$(this).text();
            var $thCell = $(this);
            var $index = 1;
            /* Copy DX content for update outside DOM */
            var $oldDx = $('#dx-summary');
            var $newDx = $("<div></div>").append($oldDx.html());
            $(this).css('background-color', '#eddea4');
            $(this).attr('mask', 'on');
            /* mask data on all tds on the same column */
            $table.find("tr.tdata").each(function(){
                var $cell = $(this).find('td:nth-child(' + $colNo + ')');
                var $cellVal = $cell.text();
                $thCell.css("background-color", "#eddea4");
                $thCell.attr("mask", "on");
                var $maskedCell = doMask($cellVal);
                $(this).find('td:nth-child(' + $colNo + ')').text($maskedCell);
                $newDx.find('signature[id="' + $sigId + '"]').find('failure[row="' + $index + '"]').find('column[name="' + $colId + '"]').text("***MASKED***");
                $index++;
            });
            /* Update DX content depending on tag type */
            if ($oldDx.is("script")) {
                $oldDx.text($newDx.html());
            } else {
                $oldDx.html($newDx.html());
            }
        }
    });
}



/* Event handlers for exporting data */
function registerExportHandlers() {
    /* Check All / Uncheck All*/
    $("#exportAll").on("click", function(){
        if ($(this).is(":checked")) {
            $(".exportcheck").prop("checked", true);
        } else {
            $(".exportcheck").prop("checked", false);
        }
    });

    /* If parent is checked, check all its children*/
    $(".exportcheck").on("click", function(){
        if ($(this).is(":checked")) {
            $(this).closest(".sigcontainer").find(".exportcheck").prop("checked", true);
        } else {
            $(this).closest(".sigcontainer").find(".exportcheck").prop("checked", false);
        }
    });
}

/* Event handlers for sorting data */
function registerSortHandlers() {
   /* enable sorting (and disable masking if enabled) */
   $(".sort_ico").on('click', function(){
      var tableName = $(this).attr("table-name");
      $("#restable_" + tableName).tablesorter();
      $(this).hide();
      var $maskDiv=$('div#' + tableName).find('span.mask');
      disableMask($maskDiv);

      /* EBSAF-202 Force rebuild of floating header */
      removeFloatingHeader("restable_" + tableName);
      buildFloatingHeader("restable_" + tableName);
   });
}

/* Register event handlers for hidden data within signatures */
function registerHideHandlers() {
    /* Add attributes to data cells */
    var $hiddenDataCells = $("td.hidden_data_parent");
    $hiddenDataCells.each(function() {
        if ($(this).children("span.hidden_data[hide-type='err']").length > 0) {
            /* Error type formatting */
            $(this).attr("hide-type","err");
        } else {
            /* Warning type formatting */
            $(this).attr("hide-type","wrn");
        }
    });

    /* Add attributes to signatures */
    var $hiddenDataSigs = $hiddenDataCells.closest("div.signature");
    $hiddenDataSigs.each(function() {
        $(this).addClass("hidden_data_parent").attr("hide-type","sig");
    });

    /* Add signature level icons */
    var $hiddenDataTitles = $hiddenDataSigs.children("div.divItemTitle");
    $hiddenDataTitles.each(function() {
        var $toggleHideButton = $(this).children("span.hidden_ico");
        if ($toggleHideButton.length == 0) {
            /* Add button if it doesn't already exist */
            $toggleHideButton = $("<span class='detailsmall hidden_ico' title='Toggle Hidden Data' alt='Hidden Data'><span>");
            $(this).append($toggleHideButton);
        }
        $toggleHideButton.click(toggleHiddenData);
    });

    /* Add section level icon */
    var $sectionIcons = $("div.expcoll");
    var $toggleSigsButton = $sectionIcons.children("span.hidden_ico");
    if ($toggleSigsButton.length == 0) {
        /* Add button if it doesn't already exist */
        $toggleSigsButton = $("<a id='hiddensigs' class='detailsmall print data analysis fullsection' href='javascript:;'>" +
            " <span class='hidden_ico' title='Show only tables with hidden data' alt='Signatures with Hidden Data'>" +
            "</span> </a>");
        $sectionIcons.append("&nbsp;&nbsp;",$toggleSigsButton);
    }
    $toggleSigsButton.click(toggleHiddenSigs);
}

/* Event handler to toggle hidden data within a signature */
function toggleHiddenData() {
    $parentSig = $(this).closest("div.sigcontainer");
    if ( $(this).attr("shown") == "true") {
        hideSigHiddenData($parentSig);
    } else {
        showSigHiddenData($parentSig);
    }
}

/* Hide all hidden data within a signature and update icon */
function hideSigHiddenData($sig) {
    if ($sig.hasClass("hidden_data_parent") && $sig.attr("hide-type") == "sig" ) {
        var $hiddenDataCells = $sig.find("td.hidden_data_parent");
        $hiddenDataCells.each(function() {
            $(this).removeClass("hidden_data_parent_err hidden_data_parent_wrn");
            $(this).children("span.hidden_data").hide();
        });
        $sig.find("span.hidden_ico").removeAttr("shown");
    }
}

/* Show all hidden data within a signature and update icon */
function showSigHiddenData($sig) {
    if ($sig.hasClass("hidden_data_parent") && $sig.attr("hide-type") == "sig" ) {
        var $hiddenDataCells = $sig.find("td.hidden_data_parent");
        $hiddenDataCells.each(function() {
            if ($(this).attr("hide-type") == "err") {
                /* Error type hidden data found */
                $(this).addClass("hidden_data_parent_err");
            } else {
                /* Warning type hidden data assumed */
                $(this).addClass("hidden_data_parent_wrn");
            }
            $(this).children("span.hidden_data").show();
        });
        $sig.find("span.hidden_ico").attr("shown","true");
    }
}

/* Event handler to toggle signatures with hidden data */
function toggleHiddenSigs() {
    /* Check if signatures are temporarily hidden */
    var $sectionHideIcon = $("#hiddensigs > span.hidden_ico");
    var $signatureList = $("div.signature[temp-filter-hidden]");
    if ($sectionHideIcon.attr("shown") || $signatureList.length > 0) {
        /* Restore hidden signatures */
        $signatureList.removeAttr("temp-filter-hidden").show();
        $(this).children("span.hidden_ico").removeAttr("shown");
        $sectionHideIcon.attr("title","Show only tables with hidden data");
        /* Disable hidden data */
        $signatureList = $("div.signature[hide-type='sig']:visible");
        $signatureList.each(function() {
            hideSigHiddenData($(this));
        });
    } else {
        /* Hide signatures without hidden data */
        $signatureList = $("div.signature[hide-type!='sig']:visible");
        $signatureList.attr("temp-filter-hidden","true").hide();
        $(this).children("span.hidden_ico").attr("shown","true");
        $sectionHideIcon.attr("title","Restore hidden tables");
        /* Enable hidden data */
        $signatureList = $("div.signature[hide-type='sig']:visible");
        $signatureList.each(function() {
            showSigHiddenData($(this));
        });
    }
}

/* Reset state of all signatures with hidden data and icons */
function resetHiddenDataSigs() {
    /* Restore all hidden signatures */
    $("div.signature[temp-filter-hidden]").removeAttr("temp-filter-hidden").show();

    /* Reset all hidden data icons*/
    $("span.hidden_ico").removeAttr("shown");

    /* Disable all hidden data */
    $("div.signature[hide-type='sig']").each(function() {
        hideSigHiddenData($(this));
    });

    /* Update the section level icon tooltip */
    $("#hiddensigs > span.hidden_ico").attr("title","Show only tables with hidden data");

    /* Hide section level icon if not needed */
    if ( $("div.signature[hide-type='sig']:visible").length == 0 ) {
        $("#hiddensigs").hide();
    }
}

/* EBSAF-202 Build the floating header for a signature.
    The floating header is used to maintain table column widths when the
    persistent header undocks during scrolling.  It gets hidden when the
    persistent header is docked again. */
function buildFloatingHeader(tableId) {
    var $dataTable = $("#"+tableId);
    /* Only build for "parea" tables */
    if ($dataTable.hasClass("parea") ) {
        var $persistHeader = $("thead.pheader", $dataTable);
        /* Only build if persistent header is actually shown */
        if ($persistHeader.width() > 0) {
            var resizeRequired = false;
            var $floatingHeader = $("thead.floatingHeader", $dataTable);
            /* Only build floating if not already present */
            if ($floatingHeader.length == 0) {
                $floatingHeader = $persistHeader.clone();
                $floatingHeader.addClass("floatingHeader");
                $floatingHeader.removeClass("pheader"); /* EBSAF-257 */
                $floatingHeader.width("auto");
                $floatingHeader.find("th").width("auto");
                /* Docking state should be opposite */
                if ($floatingHeader.attr("undocked") == "true") {
                    $floatingHeader.removeAttr("undocked");
                    $floatingHeader.attr("docked", "true");
                }
                $persistHeader.after($floatingHeader);
                resizeRequired = true;
            }

            /* Reset width of persistent header to static values */
            if (resizeRequired) {
                if ($persistHeader.attr("undocked") == "true") {
                    /* Use calculated width of docked floating header */
                    $persistHeader.width( $floatingHeader.width() );
                    $persistHeader.find("th").width(function (i, val) {
                        return $floatingHeader.find("th").eq(i).width();
                    });
                } else {
                    /* Use calculated width of docked persistent header */
                    $persistHeader.width("auto");
                    $persistHeader.find("th").width("auto");
                    $persistHeader.width( $persistHeader.width() );
                    $persistHeader.find("th").width(function (i, val) {
                        return $persistHeader.find("th").eq(i).width();
                    });
                }
            }
        }
    }
}
function removeFloatingHeader(tableId) {
    var $dataTable = $("#"+tableId);
    /* Only built for "parea" tables */
    if ($dataTable.hasClass("parea") ) {
        $("thead.floatingHeader", $dataTable).remove();
    }
}

/* Build the full section menu for signature filtering if not saved */
function buildSectionMenu() {
    if ($("#sectionmenu").children().length == 0) {
        /* Identify all top level named signatures */
        $(".sigcontainer[sigid][level='1']").each(function() {
            /* Get final signature results after checking children */
            var resultClasses = $(this).find("div.sigrescode[level='1']:last-child").attr("class");
            /* Strip out result classes and add the button class */
            var buttonClasses = resultClasses.replace("sigrescode","sectionbutton data");
            /* Get ID for the link */
            var sigId = $(this).attr("id");
            /* Get button title */
            var sigTitle = $(this).find("td.divItemTitlet").html();
            /* EBSAF-251 - add word wrap hints */
            sigTitle = sigTitle.replace(/_/g,"_&#8203;");

            /* Get the icon to show before the title based on result code class */
            /* Information status returns "info_small" class incase an icon is configured later */
            var resultIcon = "info_small";  /* Default value */
            var resultCode = resultClasses.match(/\b\w\b/)
            if (resultCode) {
                switch(resultCode[0]) {
                    case "E": resultIcon = "error_small"; break;
                    case "W": resultIcon = "warning_small"; break;
                    case "S": resultIcon = "success_small"; break;
                    case "I": resultIcon = "info_small"; break;
                    default: resultIcon = "info_small";
                }
            }
            /* Combine results */
            var sectionButton = '<div class="' + buttonClasses +'" open-sig="' + sigId + '">' +
                            '<span class="' + resultIcon +'"></span>' +
                            '<span style="padding:5px;">' + sigTitle + '</span></div>';
            $("#sectionmenu").append(sectionButton);
        });
    }
}

/* Build the main menu if not saved */
function buildMainMenu() {
    if ($("#menu-tiles").length == 0 || $("#menu-tiles td").length > 0) {
        return;
    }

    /* Initialize execution summary counts */
    var summaryCount = {};
    summaryCount.E = 0;
    summaryCount.W = 0;
    summaryCount.S = 0;
    summaryCount.I = 0;
    summaryCount.P = 0;

    /* Gather details */
    var tileDetails = [];
    $(".sectiongroup").each(function() {
        var $section = $(this);
        var tileDetail = {};
        tileDetail.id = $section.attr("section-id");
        tileDetail.title = $section.attr("section-title");
        tileDetail.E = 0;
        tileDetail.W = 0;
        tileDetail.S = 0;
        tileDetail.I = 0;

        /* Count printed signatures */
        $section.find(".sigcontainer.signature[sigid][level='1']").each(function() {
            var $sig = $(this);
            var sigId = $sig.attr("id");
            var resultClasses = $sig.find("div.sigrescode[level='1']:last-child").attr("class").split(" ");
            var resultCode = resultClasses[resultClasses.length - 1];
            tileDetail[resultCode]++;
            summaryCount[resultCode]++;
        });

        /* Count background checks */
        summaryCount.P += $section.find(".sigcontainer.signature.p[level='1']").length;

        /* Build Tile HTML */
        var tileHtml = '<td><a href="#" class="blacklink">';
        tileHtml += ('<div class="floating-box" open-section="' + tileDetail.id + '">');
        tileHtml += ('<div class="textbox">' + tileDetail.title + '</div>');
        tileHtml += ('<div id="' + tileDetail.id + 'Count" class="counterbox">');
        if (tileDetail.E + tileDetail.W + tileDetail.S + tileDetail.I > 0) {
            /* Status counters */
            if (tileDetail.E > 0) {
                tileHtml += ('<div class="counternumber">' + tileDetail.E + '</div>');
                tileHtml += ('<span class="error_ico icon"></span>&nbsp;');
            }
            if (tileDetail.W > 0) {
                tileHtml += ('<div class="counternumber">' + tileDetail.W + '</div>');
                tileHtml += ('<span class="warn_ico icon"></span>&nbsp;');
            }
            if (tileDetail.S > 0) {
                tileHtml += ('<div class="counternumber">' + tileDetail.S + '</div>');
                tileHtml += ('<span class="success_ico icon"></span>&nbsp;');
            }
            if (tileDetail.I > 0) {
                tileHtml += ('<div class="counternumber">' + tileDetail.I + '</div>');
                tileHtml += ('<span class="information_ico icon"></span>&nbsp;');
            }
        } else {
            /* Executed, nothing to report */
            tileHtml += ('<span class="menubox_subtitle">Executed, nothing to report</span>');
        }
        tileHtml += ('</div>');
        tileHtml += ('</div>');
        tileHtml += ('</a></td>');

        tileDetail.element = tileHtml;
        tileDetails.push(tileDetail);
    });
`' ||
q'`
    /* Build Tiles */
    var tileCount = 0;
    var tilesHtml = "<tr>";
    for (t=0; t < tileDetails.length; t++) {
        if (tileCount == 3) {
            tilesHtml += "</tr><tr>";
            tileCount = 0;
        }
        tilesHtml += tileDetails[t].element;
        tileCount++;
    }
    tilesHtml += "</tr>";
    $("#menu-tiles").html(tilesHtml);

    /* Update execution summary counts */
    $("#summary-count-e").html(summaryCount.E);
    $("#summary-count-w").html(summaryCount.W);
    $("#summary-count-s").html(summaryCount.S);
    $("#summary-count-i").html(summaryCount.I);
    $("#summary-count-p").html(summaryCount.P);
}

/* Add Exceptions */
function showExceptions() {
    if ($("#summary-count-x").length > 0) {
        return;
    }

    /* Count root exceptions */
    var exCount = $(".sigcontainer.signature.X[level='1']").length;

    /* Create summary row */
    if (exCount > 0) {
        var entryHtml = '<tr><td><div open-sig-class="exception" class="menuboxitem">';
        entryHtml += ('<span class="error_ico icon"></span>');
        entryHtml += ('<div class="mboxelem" title="List of signatures that failed to execute.">Exceptions Occurred</div>');
        entryHtml += ('</div></td>');
        entryHtml += ('<td align="right"><span id="summary-count-x" class="errcount">'+exCount+'</span></td></tr>');
        $(".menubox").height("auto");
        $(".mboxinner").append(entryHtml);
    }
}

/* EBSAF-260 Fix anchor URLs */
function fixAnchorUrls() {
    var $backTop = $(".backtop a[href*='#']");
    if ($backTop.length > 0) {
        var baseUrl = $backTop.attr("href").replace("#top","");
        if (baseUrl != "") {
            var oldUrl, newUrl;
            $("a[href*='#']").each( function() {
                oldUrl = $(this).attr("href");
                newUrl = oldUrl.replace(baseUrl, "");
                $(this).attr("href", newUrl);
            });
        }
    }
}

/* EBSAF-295 Highlight all cells of failed rows */
function updateFailRows() {
    $("td.hlt").parent().addClass("hlt");
}

/* Updates functionality specific to internal viewer */
function updateInternalViewer() {
    if (window.location.href.indexOf("oracle.com/iss/") >= 0 ||
        window.location.href.indexOf("oracle.com/collectionviewer/") >= 0 ||
        window.location.href.indexOf("oracle.com/ui/broker/viewer/") >= 0
    ) {
        /* EBSAF-298 Redirect feedback */
        $("div#feedback").attr("title", "Provide feedback on this analyzer");
        $("div#feedback").find("a.blacklink").attr("href", "https://mosemp.us.oracle.com/epmos/faces/DocumentDisplay?id=2332426.1#feedback");

        /* EBSAF-287 Disable export if needed */
        var p = window.location.pathname.split("/").slice(-1);
        var h = window.parent.document.getElementsByClassName("af_panelHeader_title-table2");
        for (t=0; t < h.length; t++) {
            var i = h[t].querySelectorAll("img[src$='policyentitlement_qualifier.png']");
            if (i.length > 0) {
                disableExport();
            }
        }

        /* Enable internal items */
        $(".internal").attr("data-internal", "true");
    } else {
        /* Disable internal items */
        $(".internal[data-internal]").removeAttr("data-internal");
    }
}

function enableMask(maskDiv){
   maskDiv.addClass('mask_enabled');
   maskDiv.removeClass('mask_disabled');
}

function disableMask(maskDiv){
   maskDiv.addClass('mask_disabled');
   maskDiv.removeClass('mask_enabled');
}

function switchMask(sig) {
    var $maskDiv=$('div#' + sig).find('span.mask');
    var $enableMasking = $maskDiv.hasClass('mask_disabled') ? true : false;

    if ($enableMasking == true ){
        if ((MASK_KEY == null) || (MASK_KEY == '')){
            /* Get numeric mask key */
            alert ('To enable masking for a particular column, please click on the column header.\n\nPlease note!\nOnce data masking is complete, you must SAVE the file as "Web Page, Complete", otherwise the changes will be lost.');
            var maskKeyEntered;
            do {
                maskKeyEntered = prompt("Please enter a masking key (numeric):");
                if (maskKeyEntered == '' || maskKeyEntered == null) {
                    /* Cancel mask attempt */
                    return;
                } else {
                    maskKeyEntered = parseInt(maskKeyEntered);
                    if ( isNaN(maskKeyEntered) ) {
                        alert('Invalid mask key entered.');
                    } else {
                        MASK_KEY = maskKeyEntered;
                    }
                }
            } while ( isNaN(maskKeyEntered) );
        }
        enableMask($maskDiv);
        /* disable table sorting */
        $('#restable_' + sig).trigger('destroy');
        $('div#' + sig).find('a.enablesort').children('.sort_ico').show();
    } else {
        disableMask($maskDiv);
    }
}

function doMask(text){
    var maskInt = parseInt(MASK_KEY);
    if ( MASK_KEY == null || MASK_KEY == '' || isNaN(maskInt) ) {
        /* Return unmodified text if invalid mask key */
        return text;
    }
    var chars = text.split('');
    for (var i = 0; i < chars.length; i++) {
        var ch = chars[i].charCodeAt(0);
        if (ch <= 126) {
          chars[i] = String.fromCharCode((chars[i].charCodeAt(0) + maskInt) % 126);
        }
    }
    var scrambledText = chars.join('');
    return scrambledText;
}

function copySql(id) {
    let sql = $("#" + id).text().trim();
    copyTextToClipboard(sql);
}

/* Copy to clipboard function from example: https://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript */
function copyTextToClipboard(text) {
    if (!navigator.clipboard) {
        fallbackCopyTextToClipboard(text);
        return;
    }
    navigator.clipboard.writeText(text).then(function () {
        console.log('Async: Copying to clipboard was successful!');
    }, function (err) {
        console.error('Async: Could not copy text: ', err);
    });
}
function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        var successful = document.execCommand('copy');
        var msg = successful ? 'successful' : 'unsuccessful';
        console.log('Fallback: Copying text command was ' + msg);
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
    }

    document.body.removeChild(textArea);
}

/* EBSAF-287 Disable export functionality */
function disableExport() {
    DISABLE_EXPORT = true;
    $("a span[class^='export_']")
        .css("opacity",0.25)
        .removeAttr("title")
        .parent()
            .css("cursor","not-allowed")
            .attr("title","Export is currently disabled");
}

function export2CSV(name, type) {
  if (DISABLE_EXPORT) {return;} /* EBSAF-287 */

  var $records;

  /* if section param has a value, export all section*/
  if (type == "section"){
      if ((name != null) && (name != "")) {
          $records = $(".data.sigcontainer."+name).find(".exportcheck");
      }
  } else {
      /* if no particular table was provided as parameter, export all selected tables on the page*/
      if ((name == "ALL") || (name == null) || (name == "")){
        if ($(".exportcheck:checkbox:checked").length == 0) {
          return;
        } else {
          $records = $(".exportcheck:checkbox:checked");
        }
      } else {
        $records = $(".data.sigcontainer."+name).find(".exportcheck");
      }
  }

  var csv = '"';
  $records.each(function(){

    var $rows = $("tr." + $(this).attr("rowid"));
    var level = $($("#" + $(this).attr("rowid"))).attr("level");

    tmpColDelim = String.fromCharCode(11),
    tmpRowDelim = String.fromCharCode(0),

    colDelim = '","',
    rowDelim = '"\r\n"';

/*CG comment    csv += rowDelim + $($("#" + $(this).attr("rowid")).find("div.sigdescription")).find("td").text() + rowDelim;*/
    csv += $rows.map(function (i, row) {
                            var $row = $(row);
                            if ($row.parent().hasClass("floatingHeader")) return; /* Fix the double headers bug EBSAF-197 */
                            var $cols = $row.find('td,th');

                         return $cols.map(function (j, col) {
                                       var $col = $(col);
                                       var $text = $col.text();
                                       return $text.replace(/"/g, '""').trim(); /* escape double quotes, trim leading and trailing blacks to avoid Excel misreading them  */
            }).get().join(tmpColDelim);
        }).get().join(tmpRowDelim)
            .split(tmpRowDelim).join(rowDelim)
            .split(tmpColDelim).join(colDelim) + rowDelim + rowDelim;

   });

   csv += '"';
   var blob = new Blob([csv], {type: "text/csv;charset=utf-8;"});

   if (window.navigator.msSaveOrOpenBlob)
       window.navigator.msSaveBlob(blob, "Analyzer_export_data.csv");
   else
   {
       var a = window.document.createElement("a");
       a.href = window.URL.createObjectURL(blob, {type: "text/plain"});
       a.download = "Analyzer_export_data.csv";
       document.body.appendChild(a);
       a.click();
       document.body.removeChild(a);
   }

}

/* Function to quickly repeat a string for indenting */
String.prototype.repeat = function(n) {
   return (new Array(n + 1)).join(this);
};

function export2PaddedText(section, level) {
  if (DISABLE_EXPORT) {return;} /* EBSAF-287 */


 /* export a full section - the section id is passed as parameter. If null, then return.*/
   if ((section == null) || (section ==''))
       return;

    var text =  buildExportText(section, level);

    var blob = new Blob([text], {type: "text/csv;charset=utf-8;"});

    if (window.navigator.msSaveOrOpenBlob)
        window.navigator.msSaveBlob(blob, "Analyzer_export_data.txt");
    else
    {
        var a = window.document.createElement("a");
        a.href = window.URL.createObjectURL(blob, {type: "text/plain"});
        a.download = "Analyzer_export_data.txt";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }
}

function buildExportText(section, $level) {
   var text = '';
   var $records = $('.signature.'+section);
   var INDENT = '    ';

   if ($level == null) $level = 0;

   /*if no signatures in the section, nothing to do. Return.*/
   if ($records.length < 0) return;

   /* define array for col max length */
   var maxlen = [];

   /* parse all rows once and gather the max length for each column in each table (first columns, second columns etc). Populate maxlen array.   */
   var $rows = $('tr.'+section);
   $rows.each(function(){
      /* skip if this is a sig title row or if it is a floating header*/
      if (($(this).hasClass('sigtitle')) || ($(this).parent().hasClass('floatingHeader'))) return;
      $currrow = $(this);
      var counter = 0;
      $currrow.find("td,th").each(function(){
          if (($(this).text().length > maxlen[counter]) || (typeof maxlen[counter] == "undefined")) {
              maxlen[counter] = $(this).text().length;
          }
          counter++;
      });
   });

   colDelim = ' ',
   rowDelim = '\r\n' + INDENT.repeat($level-1);

   text = '';

   $rows.each(function(){

      if ($(this).parent().hasClass("floatingHeader")) return;
      if ($(this).hasClass("sigtitle")) {
           var title = $(this).find("td").text();
           text += rowDelim + rowDelim + rowDelim + title + rowDelim + "_".repeat(title.length) + rowDelim + rowDelim;
           return;
      }

      $cols = $(this).find('td,th');

      text += $cols.map(function (j, col) {
         var $col = $(col);
         var text = $col.text() + " ".repeat(maxlen[j] - $col.text().length + 1);
         return text;
      }).get().join(colDelim);

      text += rowDelim;

    });

    /* if this is not a section (level is 1 or more), try to go recursive */
    if ($level > 0){
         $level++;
         var $children = $(".sigcontainer." + section + "[level='" + $level + "']");

         if ($children.length == 0) return text;

         /* if there are children, get their IDs in a unique list and call yourself with the sigid and level */
         var $uniqueChildren = {};

         $children.each(function(){
             $uniqueChildren[$(this).attr("id")] = 1;
         });

         Object.keys($uniqueChildren).forEach(function($child){
               text += buildExportText($child, $level);
         });

    }

    return text;
}

function export2HTML() {
  if (DISABLE_EXPORT) {return;} /* EBSAF-287 */

   var i = 0;
   var $signatures = $("div.signature");

   /*if no signatures return */
   if ($signatures.length < 0) return;

   rowDelim = "\r\n";

   var text = "";
   var header = "<html><head><title>Data export</title></head><body style='background=\"#ffffff\";color:#336699;font-family=arial;'>";

   var params = "<br><br><table align='center' cellspacing='1' cellpadding='1' border='1'><thead><tr bgcolor='#cccc99'><th><i>The test was run with the following parameters </i></th><th></th></tr></thead><tbody>";

   var $paramDiv = $("div.popup[data-popup='popup-2']");
   var $paramRecords = $paramDiv.find("td.popup-paramname");

   $paramRecords.each(function(){
       var paramName = $(this).text();
       var paramValue = $(this).closest("tr").find("td.popup-paramval").text();

       params += "<tr bgcolor='#f4f4e4'><td width='50%'>" + paramName + "</td><td width='50%'>" + paramValue + "</td></tr>";

   });


   params += "</tbody></table><br><br>";

   var indexTbl = "<br><br><table align='center' cellspacing='1' cellpadding='1' border='1'><thead><tr bgcolor='#cccc99'><th colspan=2><i>INDEX FOR MAJOR TABLES DIRECT ACCESS</i></th></tr></thead><tbody><tr bgcolor='#f4f4e4'>";

   $signatures.each(function(){
       var sigId = $(this).attr("id");
       var level = $(this).attr("level");
       var title = $(this).children("div.divItemTitle").find("td.divItemTitlet").text();

       if (level > 1) {
          text += "<blockquote>";
       } else {
           indexTbl += "<td width='50%'><a href='#" + sigId + "'>" + title + "</a></td>";
           i++;
           if (i % 2 == 0) {
               indexTbl += "</tr><tr bgcolor='#f4f4e4'>";
           }
       }
       text += "<br><br><b>";
       text += "<a id='" + sigId + "'>" + title + "</a>";
       text += "</b><br><br><table width='100%' cellspacing='1' cellpadding='1' border='1'>";

       var $rows = $(this).find('table.tabledata').find('tr.' + sigId);

       $rows.each(function(){
          if ($(this).hasClass("tdata")) {
             text += "<tr bgcolor='#f7f7e7'>" + $(this).html() + "</tr>";
          } else {
             /*replace background color for the header*/
             text += "<tr bgcolor='#f7f7e7'>" + $(this).html().replace(/\#f2f4f7/g, "#cccc99") + "</tr>";
          }
       });

      text += "</table>" + rowDelim;
       if (level > 1) {
          text += "</blockquote>";
       }
   });

   if (i % 2 == 1) {
       indexTbl += "</td><td></td></tr>";
   }

   indexTbl += "</tbody></table><br><br>";
   text = header + params + indexTbl + text;
   text += "</body></html>";

   var blob = new Blob([text], {type: "text/csv;charset=utf-8;"});

   if (window.navigator.msSaveOrOpenBlob)
       window.navigator.msSaveBlob(blob, "Analyzer_export_data.htm");
   else
   {
       var a = window.document.createElement("a");
       a.href = window.URL.createObjectURL(blob, {type: "text/plain"});
       a.download = "Analyzer_export_data.htm";
       document.body.appendChild(a);
       a.click();
       document.body.removeChild(a);
   }
}`';
    print_out('<SCRIPT type="text/javascript">');
    print_clob(l_html_clob);
    print_out('</SCRIPT>');

    print_out('<!-- HOTFIX -->');
    print_out('<SCRIPT type="text/javascript" src="https://www.oracle.com/webfolder/s/analyzer/hotfix.js"></SCRIPT>');
    print_out('<LINK rel="stylesheet" href="https://www.oracle.com/webfolder/s/analyzer/hotfix.css">');

    print_out('<!-- FEEDBACK -->');
    print_out('<SCRIPT type="text/javascript" src="https://www.oracle.com/webfolder/s/analyzer/feedback.js"></SCRIPT>');
    print_out('<LINK rel="stylesheet" href="https://www.oracle.com/webfolder/s/analyzer/feedback.css">');

    print_out('</HEAD>');
    print_out('<BODY>');

    dbms_lob.freeTemporary(l_html_clob);
EXCEPTION WHEN OTHERS THEN
    dbms_lob.freeTemporary(l_html_clob);
    print_log('Error in print_page_header: '||sqlerrm);
    raise;
END print_page_header;


----------------------------------------------------------------
-- Prints analyzer header (title and top menu)                --
----------------------------------------------------------------

PROCEDURE print_rep_header(p_analyzer_title varchar2) is
BEGIN

-- page header
    print_out('<!-- page header (always displayed) -->
<div class="pageheader">
    <div class="header_s1">
    ');

    -- Print new logo image (EBSAF-165)
    print_out('        <div class="header_img">');
    print_out('<img src="data:image/png;base64,', 'N');
    print_out('iVBORw0KGgoAAAANSUhEUgAAAJYAAAAkCAYAAABrA8OcAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH4wEDDQwplQ4B4QAAEpxJREFUeNrtnHmUVNWdxz+1dVd30w+KphtkFRUBBaERcCEo4xZNjHFcGBfioM6JGjNWZlzOcTQx6uiJEhPLJVFjZkziQlrcDZrgceuoaDSNjjpsCiJLi9jVXWD3bbqr3vzxvs++PKqqu4DxJJ6+59Sh+r377rv3d7+/3+/7+/1uAf2tv/W3/vb30kJ7aqBMKrE3UAOEgXbgAyeZNv0i7gdWqUCaDJwJnABMLdDtU+CPwBNOMr2oX9z9wCoGqKnA3cBM6/JqYCXQDHQBCWBf4ACgQn0+By5zkum79tTkjWcd3Ti4geshgOD1AmP02reU8fI8F4pDbhfXV/C9xtq7OLjBv/eAbEPCR0H52u8KzjVUIqh+C3xHf74L3Ag84yTTrQX6h4AZwMXAObr8MXCsk0yv2IXFRoBBwEhghECbK6Iw7cBGYD3QFoesNVYtMFnjufqEiihgF7AWWAdkets8zXUGMAH4CFgah44+rDEODAFGAcP8zS2yxs3ACrz1HCgvsUzrLVURosBAyXakh5OdxnBFd2LAZ8ByoBMYD3QDy+JgQn0AU0gWqAkYDXwCnO8k038oEZR1wJ3Aabo0z0mmHyhh0YOAOcDxwEQJINrLY9uBNPA+8AzQGIetGu9Q4BJgf40T6UXRckAL8BqwMA5v96LtXwfOAw4C1gAP6LnuIs/tC3wD+AdgL2BAkTlFBKJFwOPAyVLe1cB1wPJSLKXx9niO5j0RcCSXUB45RIEy4DFgofBxsPq+FIfXon14Z420tEJc6eRdMa1OMr0ZOD2TSpwGNAD3Z1KJ6r64RgODgX8Sp6uXJnXQu+AiQLksx0Sg1kCDLEe1rEm9rFF7L1YrIgs3CagycFfcA2y+Nho4BThOCjBW831X1iTfGqcB84CT1L9TilHIgpbLGv+P5j1Ga4kClaV4IwN1wOmScW/yDQtUG6QwLZqvo/519EHjAf5XoFrgJNNX7K7vdpLpRZlUYqLG/WUmlVjnJNOLiyw6Zmn/dFnMZ/EsxrYiAnS12KnAEcDREtjHBl7Ac4th9X0ZeB7PmkULWKsE8E3NYS7wkcljFWStjpfVGag5RoBDgBMNrIp7fNN+ZrRAda5c8/t4c1xTxNXH1G+p3GBI6+mmBBco13ssMF9rawYWC7D55BuWjDZKbs0CU43evaqvLmyWuFXR1tDYVCpfm5pJJVx9EkUWPtbAIgNdBjYaWGBgqjhMb0KLGZhh4KcGNhnoNvCggWoDcww0Gdhu4IfG0/Lexppv4H3jkeUHDQzN02+SgWfVZ4WBew0s0d+vGjgy0L/cwIUGPlCf1/WeESWAY6zW2K3np/VFPnp2ouTbqTlca7ygqxRuNtDAQcaz5nu+NTQ2tTQ0NrkNjU0/6iO4/lXAeqkQVzFwqoGVBoyBO41n8ksl/ftog7sMtBuYbOAYA29JoNeIY/Q2zigDTwoATxjPNdr3Bxj4iYEtAuz1BkYb+K6BjIFtBu6Wa/efGWng9xrzYwMX7sL69t4VYBmIGDjLwGrJ4XYD++m6YyBhYFCej3+9whTwGOHdAFE48PcsejZnXh/d4u0y90dkUolZBXjNISKyzcCSuBdhldq2AC8Cm8QPDhAPca0oJ2KgTAKrDnyqDFSJX9VpzA4gkycK/IbcwlLgmbjHT19VPq8KOAo4zvS43H0V/aE5PvYlppvi4pkDlQ4apLzkvyj6P1ufefqcrevzFSyMowCAowUsyQhgs5NMdxWZ1PKGxqYaRSATw+HwGeFQiJybw3UZ19DY9AZwDfBt4J+B0+fOrn86zzhnahOu0qYEucRwEdUtQOsuCrBdaY5PNd4odgSoKzK/j8CTDRBnn2OdKALfpjB7YyDIOU8btR74rcg6wAcKWA7QZpwN','N');
    print_out('/MV4SjVYgANYG/c45JcJrFqBo1oc8ngpWiGeFtW9l4F1haLcaB5QjZTQPsykEgfnA1dDY9MFEhDhcPjW1rYM6zdtprVtK3XDh1NZEacqHpsxqDK+2JrdU/mItpNMv55JJZqBExQlbg0AK6uFRHZDgCE976cUcgHBubo2QpHReCsq80nxIG1CFHgUeDruRZPImp2oKDAq8vtiXBYtDh3GU54ngR+I2J8I3Kt35Iop+v9j89fty7lVhD1cJH8Wk2K9otQGvQIrk0oMFaiqpJl/Ebiydr+5s+vvbmhsujkcDjur165j3fpPiETCuK4Lrsv27izbt2Vpa+9kZI1DOBQCuKnIAhdK4N/Ud9tSrJWZHgIMN14mu9TM8gApgu9yVlkC9T8Z4A2BapzyWz6o29RnhaK1h4C/Wtn/CcAZmuNyheDTRWb9SC2uTWnVPM4B/qwEp2+JJxgYH/fe82W0dlnX7Vrn08BzUqoyyxC4loKGBL5VSjkUB1YmlahVvqrMGmyKws6dooRQKLRmQ/OnUz7euJlIJLyDCnyBipzLhs+2MrrWwXV5qsgCH7I02QZWVppxqjbvHxViLytRgOPFHYYqXbFc7jBkWSTisMF4798OXCBw+dWCBr13pVyAb2XqlA45TOM8KGCdKf7krwO5mxp9n6Sc1cPimduVFjnLwE/9RG4JlsdWxk67ylDEDxrjrWmz9niY3PE7UphwILfnf8/2ptxRgWov8YAyae1M4DJxnqMzqcR7TjJ9oOUK6wmFpqz+8CPfGhEKhV4JhUIXx8rKmpVsux2gO5sl095JdUX5FeJb+ZrPRQ4OLNw1Xr7qz0oAHocXXS0SR/q8D5ZqgtzOUdLEh6WlwwMC88G11nhA7xS4Jgs8MWWz1wRyQNME+AEi6U8JSIfLdZZbrjerSkBcObZTBdaXlZicIVfcYaBRwUa2iHtH1rDaAlccLxLdalEIt8gYbaqqjMVLhTQbz2Wvs+QbtFxh00MrtgEtQSBHLY36HFgg9M4ENjnJ9DGZVGKJ+AUNjU2TgV8Cs1paWsm5rg+s9G2Xnvs1a9w7FjzyQpkLt4RCIbaaLpzK8pMaGpteA26ZO7t+UYBntWdSiXZFJ8H2qTjNCCU5z5K2L5MLKZYgHSyrO0V/Pwf8WpwnavGucADQmwSu7Xjh/zQR85gs2gqBZV9ZnXpZqfvFO9pluVYE6pk+wGoF9gMVXf23SjM1sq5JYLae7yqwRp8DrVKy2FeO4bKWG/sY+b8J/EF7fLQiwpkB+YYCcg0pql4vmabzWiyVW2plva62wmmcZPpYq/+RwCyADtNJqMdaPZZn1U+4cAtANuvTGfdQ4GZgUSaVGAzc4CTTF1ngjmgONwO/cJLptXHIGc9iVSozPkea7ZdiyCN41yKaYSnLS8BvgHestUetgmrQTbQYDyhdwPf0zqTc6X1yj18TL4zI6vwJaJelfV5uPJwnUBisd58DfEvAWCIZzAP2s2qGhcpMEa3rd1rbVvWrU2Ugm8e6BeWTljye1X53aI9nSpm687zftUpKjwPP5YsM80UhWy0+EGwrfQBEozsEaRPzmItRXyTLQjuEGO26nALmZVKJ6U4yPUMT3ZZJJR5WoXqyeBFxL6n5lLTzHbm1Yb2ExX6ks1GE+2lghcWN2izLs5E8wpFle0jW/Fxt+EzRhkYpY6sCjPuBD33uEQfjecu8rc14LnmEXPx+KpLfIU57iqxsVRGLXCarslhuaxnwViD6pRfZrABeiXsJ3ae0jrelvIXk63PSFpXBVhfz03ZkeKrM8nVOMn1NgeToJdlsNvXy0r8SjXrYDIfDl6b+ff7PAH7+yAtDurxa4BAAp7KcwQMq1iiX9Zb1rjfFq3xeh5X3mewk0x35ssUSXFRgjOSpp/k49lMGuSAHUA1ygJ7/HDCFCKmIbKU2MyIQdls1u25gW18Ic6CmWEXP0ZRtcW++WG46pvuFisGd1mmNsPpW5CH0+fbcFfA77HVb8o1Z683leb5L','N');
    print_out('z3b1FVjDRBr/5CTTXy8kmEWvvN363ooPBm5psXKWrrtlr1GjmqOx2KSeSy5j6hKEQ5wzd3b97/K8b5m0EysC289JprfT3/5uWzhPwrJZZu64TCoRK/RgLpfLThw3llgsaru/Ia7r7gCqoYkBhD34Li9Q1plKz9mmj4Cx/aD6CgJL7RH9e3IBV3i1CCiHHjyZ4UNryeZyZLNZXBdyrkssGmH4YIeqcj8txm1FaoZTRULHB5OxeThhNEC8/xZalD34wxSLnJfpE/2qAOtW/XtVgfvPWGbq/nH7jFp/1OHTmT7lAEbWDWJM7SBGDXEoj0WedF03Z1kjioDrHCeZ7izSpU75lpfxirUPqeb2ZQu9zuIxfnsM2HsPviOkFESrKgKv+lH731BL5JFDcWA5yfT7wOvAlEwqMT94XwR8EjB47uz675w2a+qonOveUD2gisryMiLh0Mpczi2fO7v+2yK958+dXX/Gbi5knN55isL+51UmWmhpuH+6sdyyIHHldoZZVQW/VSgyG6ZndhCD7tUE5LREiU0/cICemmIkkLoIBeZShndSo64XhfiNvEWt5r8CuCgwpr2HvsX0rXil1jw4MJeY1jzcD6zygGWk/g1Z4/tRZoU17w+BqyWfyl7Ju0Wqx+rhDqDOSaa3Fdv1hsamA4D39OeVc2fX/6Q3pGRSiYp8kV+BdqislQ2O4/F+0DFNeZ8hirS2Kr1QiXfEwz+P/aIswVa8U5sXKEmZ07079f0gpRfGKtfzmFIWhwL3KCm4HO8c+yZZzj8qx3U48CsrZTMf+C+BYZ7KNl2a35PkL928oM08TbkqG0T7Kd3iH+keqXLSK7Ka++u9Rwjw90hu45V3q9C/YbxfWz0nsMzCOxJTp/TLIt2boHJPVOP7J1bvUYrjGbwjTQ/YkWi4iGtag3ckpkL5kaJt7uz695XsO9Mv5/QCqsuBlZlUYtAuuorBSua14eXMblFVwD+/FcM7PXCKNvohWbjz/CkDx1hW70YrP/YL5eYW4JVwvqUNzCj/02F9x+o/XAL3LdlUjVGpTbtYXHMx8CO8wnW+dqFAejNeecyxuNxJwH9afScAP5ZyHSvFGS15tIu77qU1/ErAXKD80xKlXIZqTp3ADQL+rXhHladJMX6Id6xouNIrOfXfRml1zS8A8KxOeb6ZSSX2CFm2To52ZVKJMSVYLBevWH2trMtbAs6+4l83WP1r8HJpR1nXrlOJqFLlo30EsMsEoKsE1g0UPlH6giyl3db7FQm8n0QdLQt1jzR/oCzar5XBP0QbeWeR9R6m59v03HQp1PeVyPTbHFmR4ySXJwNzXyMr9v08ua0tsqJHyvL6bags6o149d13ZeUI5BqvL5W825breLyfPB0MbJKL3B1QPWBFiJOdZLrUE6EDZRHW4f1861G5v2yA30wSuGzXuVTu0pXr/A9lvsdKAyP0/CopXaSUUlZkfvcC/6b5HCvrUCNN9w/5zZOmvyMOla+9BnxXFqtG1iZaIPHpWknhcICDBftXWevolEWaFKgStOOdAnE0bksBrxEpNP8+RVROMn14JpW4D+8k6IeZVOIO4MreeFcAUGdKQxOyGtOcZHp9iaDqklbmE2ywrRI4ugNWYIu4x11yRynde1VgaBEIquip7tcIeH6xtVj0epss2AxxndcF3E3S/Gvlfqo0Xr6yzwxZ4xxe/fE1ud5Kdi6zdLDzD0u7i8zPX1NWCvKO5msDxHePb9NTwgkqWUzry+2SxbLANV9up11mdWsmlXgkk0qckEklavIAKZ5JJaZkUonrM6lEK161PwHc5yTTdbsAqmDEFVxHdUA4GxV83Cr+cwhwqfhJVtroHwu+QqCrk/v8TBZioHjR7+k5kxYTX9lfAPStgB+ZbdB77xM5RqB6SZHeGAH15+x8FNtv35N1nanI9HG8g4VtckEjFWAcIXfpuz6DVxSfr/XdrnsdFphu1nyvlfV+QlGnI6WoFscbp3u+EgRP8L6Jd8SnFu/YUKhP','N');
    print_out('UWERyxMSJ/lxIMxsl1blNJHqAHAfBS51kum1u+hFq8Wvri9w7zBZmzet63sBlytSi0lwi6S1R8latSqiWaNNWCj3cJF4zVopxWI9N12Ev0YbuAy4UgTXP69+oIKEa+TyEIjPF4nv1KbdJQsabPuo7zGyRK9q7mv13gXiPAvxDgbMAX6mjT5GVvIQvecm8btL1OdavOJ+TErzhpTiCMl3lCLe2/XeiSL8S+Vp/FYruQ3BOx1xtW29ditbnEklZmtCJ4hA+z+c/Byv5teofNMSJ5lO7wHeX0Hh///AB3EuD6eo0wZ9zI6F4lEScLMUI265poQ2cZtC/lwAsP55pE597wi4owEWqAjk1Fy9s6OXtQ7Vuj5hx0N3jjY0LcUYqO83CQiX03O6YrPel5T1HipFNOx8tLhWY7VZIIpYcg1SjiF457haCvCw/vYVaSmlEIblufcDAaOqX0z9rdQWKRKQhYtw1D3e/g9CtGBUiSReIQAAAABJRU5ErkJggg==','N');
    print_out('" alt="Proactive Services Banner">');
    print_out('        </div>');

-- page title
    print_out('        <div class="header_title">'||p_analyzer_title|| ' Report <br>
        <span class="header_subtitle"><b>Compiled using version '||g_rep_info('File Version')||'</b></span>
        <span class="whatsnew_ico" title="What''s New" border="none" data-popup-open="popup-3"></span>
        <span class="header_subtitle"> / Latest available for download:</span>
        <a href="https://support.oracle.com/oip/faces/secure/km/DownloadAttachment.jspx?attachid=2332426.1:ame_zip">
        <img class="header_version" src="https://www.oracle.com/webfolder/s/analyzer/ame_latest_version.gif" title="Click here to download the latest version of Analyzer" alt="Latest Version Icon"></a>');
    print_cloud_image;
    print_out('            <a class="detailsmall internal" href="javascript:;" onclick=''postFeedback("up");''><span class="thumb_up_lg" title="Analyzer Feedback: Thumbs Up" alt="Thumbs Up Analyzer"></span></a>');
    print_out('            <a class="detailsmall internal" href="javascript:;" onclick=''postFeedback("dn");''><span class="thumb_dn_lg" title="Analyzer Feedback: Thumbs Down" alt="Thumbs Down Analyzer"></span></a>');
    print_out('            <a class="detailsmall internal" href="javascript:;" onclick=''postIdea();''><span class="af_idea_lg" title="Analyzer Idea" alt="Idea Analyzer"></span></a>');
    print_out('        </div>
    </div>');

-- top right menu
    print_out('<div class="topmenu">
          <div class="menubutton" id="homeButton" title="Open the analyzer''s main page">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAZZJREFUeNrMls8uA1EYxTvaBZEgbLrmAfQNuiFio5SFxLKJnWAhFaJVUiEktk0aElai/m2IaBcaPAsrT0Dr9yWniTCYTlrpJL/c6Z3vO2d67p3JONVqNdDMoy3Q5CO0VXrxVLgyFHadp7/AEIdLaqa+GXi9E4Qchh39TCJWy3YSHJn4jigIB7AkDjEM6tqrRsc1Ig/iHXACY5DRXBp6MZlmHIYi9Pkx6IEriJo4sawrLovHzm8hJpNSvQZhCQyaGOIZhLNa8FVtDjMpw4hMPBsMwB30S2QDwX3GBf2DToZFqCq2J5l4WuQIPErcst6EXE1cx7zmsqqx2geMI38ZWNb3iictgWOYdbkRmzv6ZGI9ZUyiPxnElHm3GrbhFGZ+WSe7VlBtCrpMA5PxrwYJOId2Fe5q98Q9bOMJ1e6p1zTOMEnUDJKQ18OUUubXMFrHK8dqb9hd1rsmrTwmy062+OzW4OsVi4Hz72/TljKY04MZ0nnDDXJk/G7oIWusAcJvbuctuwYVH1qVegwufBi49jjN/mz5EGAAm494BUo6enYAAAAASUVORK5CYII=" class="smallimg">
          Home</div>');

    print_out('<div class="menubutton" id="execDetails" title="Show the analyzer''s execution details" data-popup-open="popup-1">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYBAMAAAASWSDLAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAACFQTFRFJSUlXI2z////XI2zXI2zXI2zIrW9XI2zbKDIhLvm8PT344Mw7gAAAAZ0Uk5TAAAAucPE2PdAKgAAAFJJREFUGNNjUEICDOHlcFDCULUKDpYTwVmWhZ2zLAs7B8TExoEwsXFwuaByJhxMR+WYI/xTzAACglCAhVNejsSpnA7jsJeXd84oLy+EcUAAyAEAU+SE9OHO8IMAAAAASUVORK5CYII=" class="smallimg">
          Execution Details</div>');
    print_out('<div class="menubutton" id="execParameters" title="Shows the analyzer''s execution parameters" data-popup-open="popup-2">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAATVQTFRF////LYa/LYa/LYa/LYa/LYa/LYa/LYa/LIW/LYW/LYW/LYa/LIW/LIW/LIW+LIW+LIS9LIS9LIS9LIS9K4O8K4O8K4O8K4O8K4O8K4O8K4O8K4K7K4K7K4K7KoK7KoK7KoK7KoK6KoG6KoG6KoG5KYG5KYG5KYC5KYG5KYC5KYC5KYC4KYC4KYC4KYC4KH+3KH+3J321J321JnyzJnyzJnuzJnuzJXqyJHmwJHmwJHivJHmvJHmwJHivI3etI3euIXSqIXSrIXWrInWrInasI3atJHivJnuzJnyzJ321J361J362KH62KYC4KYC5KYG5KoG5KoG6K4K7K4O8LIS9LYa/MIrEMIrFMIvFMYzGMYzHMY3IMo3IM4/KNpPPNpPQNpTQN5XSN5bSOJbSOZfUOZjUOZjVtemDjwAAAEB0Uk5TAAIEBggOEBIXGx8hLDAxM11hYmRwcXR2d3l6jJCTlJaYoqiqsbO0tri8vcLExsfQ0+Lj6+zt7vP3+Pr6+vv9/dC+MVIAAAFxSURBVCjPbVLpPxtRFD1v3kgprVKJrWm66RaKkYwlliTP8p6GCbcqwgxpOf//n+BDJvjhfrvn3P0e4M6KxhTxnNU7nfojKJv3AFTJKgAvn+vhMy4KtHqzR9oRpRcj9zWNdwmlvL73lzy1lVCYuG5OPiIZJyRJJjHJow8AAB0IScYHu7sHMUlKoLu1/DDmtSxPDw9PL8s149BPm6tKQpnXAKDnhUnFS4kRy3ao8OrnjyGosE072t23ak/pcni9eXKyNYScY8tWTRH1DkmaDL78IeUzMoYkO3XUblLik5DHH1PipoaF7Z3GOV0WL1eb0coAso4XjZ3tBaB/cLLBdknhRSGfgSq12Zga7AcAeBuXlF8KANSc8HKjN64ux/wvpbG+vrEl+ce4nC6uF4Ukz5wx7uzhSd4dPj5i9B4AkHNXlHDNtsiWXQuFV78nurW+7TcD33trSTvq+UFz/3vvheMF//61ujD+VAy1Z1Uya8zsvXcLH9dhX50/y6MAAAAASUVORK5CYII=" class="smallimg">
          Parameters</div>');
    print_out('<div class="menubutton" id="feedback" title="Opens the Oracle Community feedback thread"><a href="https://community.oracle.com/thread/4122283" class="blacklink" target="new">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAJNQTFRFIXSq////IXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqIXSqInatI3iuJHmvK4O7K4O8LIW+LYbALofBLojCMYzGMo3INZHNNpPPN5XRN5bSOJfUOZjVUpq7wgAAAB90Uk5TAAABAgwODxkgJD5HUlpncn+WoKyyu7zD0Nbq7vf6/POduf8AAAChSURBVCjPddJpE4IgEAbgpdNu7LDDas1QO4n//+vKxIbN5f3EzAPLsgMIT2CFNkICCZoqKFD6QEkPPIk4YIg4UEYyAHxXynbdgPqgHybtBry01gi47P5Bvo8/Acy2Awqnvt15iUcEkt66bEsZczvOKCT18qHmPNzPIVvqepi6pdLAXl7shuTyIv2OBLNNwL4cFx1+JONWNZIISaLfEH3f5w2X1DnbEexn8QAAAABJRU5ErkJggg==" class="smallimg">Feedback</a></div>');
    print_out('<div class="menubutton" id="analysisView" open-sig-class="analysis" title="Displays all data in a single page, without the Errors/Warnings/Passed Checks/Information messages - Click Plus (+) icon to expand all Table Data">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAABjFBMVEVentFhn89in9FjoNFjodNkodFnotJppNNppdRqpdVqptVrptVsptRtptRwuGl0um16rtd7r9d7sdx8r9h8st19r9h9s95+v3ibzZadzpmk0qCp1KWr1qiy0+yz2a++2e7A2+/U7NjV7dnZ7t3i8OHj7fbj7vbj7vfj8eLk7vblPCPl7/bl7/fmRCzmRi7mSjPmSjTmSzTm8Pfm8fnm8uTnSjLnTTbn8Pfn8frn8vrn8vvn8+bn8/7n9Pzn9f3n9f7n9v7oUjzoUz3oVD7oVT/oWEPoWUPoWUToWkXo8Pfo8ffo8fjpWkXpW0bqX0vq8vjraFXrb13rcF7sd2Xs9Pnt9Pnt9Prt9uzwi33w9vrw9+/xlx3xmiPx9vryny7yn5PyojTypZnzojT0qkb2vLT2vbX2xb72xr73wrr3/Pn62NP63Nf74Nz76ef7/fv87dj879z8/f797+7+4tz++Pf/4tz/5uH/6ub/7tf/7tv/79n/79z/8d3/8eH/8u///Pr//fr//vr//vz///8pVMrYAAABOklEQVQYGQXBPWuTURgA0HNvngSbNLQxKCpNBpVWsAUHHXRwcnJzcnLxr/TXODk7OQripHWpVIh1CbTFGKW+356TXh1PAQBwvmsaAAAQ19J4+/EJw1yWoB9w68Ov0Ds4oLocBmiLTD362IUOi4tvT2+Ai/OgutelgO+LnBOQBokWGT+P+hsZACBwtjUA0JVBg8DpBANgspmpEYCd9w31o7vLd4n2NYHZCjuU3YZVmWmQMV2VUNXDTcfroijWCMyqRdPrF3XMtjz5M2WJgNtxtl7Oh1evs1z9pkVImN/818QoYX8fJKH5csIwp7YuANxp2A4AAIhJPPvcA/I86X60QP0gHQL4VBo8BBAA3h71NKcvADKAvTwe5z0A6ZA3X3Mmj7L2b0vb3n9JoEpXoOikgMsKgefHHQBIu/gPPNJqMuZfDkEAAAAASUVORK5CYII=" class="smallimg">
          Data View</div>');
    print_out('<div class="menubutton" id="printView" open-sig-class="print" title="Displays all data in a single page, including the Errors/Warnings/Passed Checks/Information messages - Click Plus (+) icon to expand all Table Data">
          <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAiUlEQVRIx2NgoCdYs2nHYSD+TyE+jM+C/8/efKYIg8wYWAuogekarwzmERMPA/F/GuHDIAv+B5XvoAkGmU2xBT8vtoExjJ983hiMh44FRAWRU+pCqkcwzEwGmAANUiemBdTMaDgtoFZRMfAWNO19RhIeUB8cpqEPjgxchUOpD4ZvlUmNVgVKxAIAsdgxrFcW4/sAAAAASUVORK5CYII=" class="smallimg">
          Full View</div>
        </div>
    </div>
    <div class="backtop sectionview data section fullsection data print analysis" style="display:none;"><a href="#top">Back to top</a></div>
    ');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_rep_header: '||sqlerrm);
  raise;
END print_rep_header;


----------------------------------------------------------------
-- Prints Feedback items                                      --
----------------------------------------------------------------
PROCEDURE print_feedback IS
BEGIN
    print_out('    <!-- print hidden feedback items -->
    <div style="display: none;">
        <span id="feedback-apex">ASEOBS-PROD</span>
        <span id="feedback-azr">1334</span>
        <span id="feedback-guid">' || g_guid || '</span>
    </div>');
END print_feedback;


----------------------------------------------------------------
-- Prints What's New pop-up window                            --
----------------------------------------------------------------
PROCEDURE print_whatsnew IS

BEGIN
    print_out('       <!-- print Whats New pop-up window -->
       <div class="popup" data-popup="popup-3">
            <div class="popup-inner" style="padding:15px">
            <b><br>&nbsp;&nbsp;What''s new in this release:</b><br><br>
<p>200.28 Latest HRMS RUP<br>
200.27 Details on 19c database<br>
200.26 Added new info related to business groups<br>
200.24, 25 Latest patches<br>
200.23 Added PQH packages versions and Rules Using Approval Groups<br>
200.22 Latest patches<br>
200.21 Improved Rules signature<br>
200.20 Lifetime Support Policy<br>
200.19 Latest HRMS RUP<br>
200.18 New checks for invalid approval group<br>
200.17 Lifetime Support Policy<br>
200.16 Added AME_EXCEPTIONS_LOG error<br>
200.15 Latest RUPs: 30066331, 30096069<br>
200.14 Patching warning<br>
200.13 Covert to package<br>
200.11, 12 Mask sensitive data</p><p><span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">The Data Masking feature has been expanded.&nbsp;&nbsp;&nbsp;&nbsp;</span></span><br>
<span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">1.&nbsp;&nbsp;Select data is now pre-masked at the point of collection.&nbsp;</span></span><br>
<span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">2.&nbsp;&nbsp;The masked information displayed will be just enough to permit effective review and troubleshooting of an issue.&nbsp;</span></span><br>
<span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Example:&nbsp; A credit card number <strong>would</strong> be displayed as ****-****-****-1234&nbsp;</span></span><br>
<span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;An employee name would be displayed as D</span><span style="font-family:&quot;Segoe UI&quot;,sans-serif;font-size:10.5pt;">isplay first and last 25% per word (J**n S**w = John Snow)</span></span><br>
<span style="color:black;"><span style="font-family:&quot;Calibri&quot;,sans-serif;font-size:11.0pt;">3.&nbsp;&nbsp;&nbsp;The existing �Lock Icon� still provides customers the manual column scrambling capabilities, which can be used <strong>in addition to</strong> the newly introduced pre-masked data feature.&nbsp;&nbsp;</span></span></p>
            <br><br>
            <div class="close-button" data-popup-close="popup-3"><a class="black-link">OK</a></div>
            </div>
       </div>');

END print_whatsnew;


----------------------------------------------------------------
-- Prints execution details pop-up window                     --
----------------------------------------------------------------
PROCEDURE print_execdetails IS
  l_key  VARCHAR2(255);
  l_time TIMESTAMP;
BEGIN
  g_analyzer_elapsed := stop_timer(g_analyzer_start_time);
  get_current_time(l_time);

  --g_sections.delete;

    print_out('       <!-- print Execution Details pop-up window -->
       <div class="popup" data-popup="popup-1">
            <div class="popup-inner">
                     <table cellpadding="3" cellspacing="0" border="0" width="100%" style="font-size: 14px;">
                        <tbody>
                           <tr>
                              <td colspan="2" class="popup-title"><b>Execution Details</b></td>
                           </tr>');





  -- Loop and print values
  l_key := g_rep_info.first;
  WHILE l_key IS NOT NULL LOOP
    IF ((l_key = 'FullHost') AND (g_cloud_flag)) THEN
        print_out('                       <tr>
                              <td class="popup-paramname"><b>'||l_key||'</b></td>
                              <td class="popup-paramval">
                                 <span title="">'||g_rep_info(l_key));
        print_cloud_image;
        print_out('                                 </span>
                              </td>
                           </tr>');
    ELSE
        print_out('                       <tr>
                              <td class="popup-paramname"><b>'||l_key||'</b></td>
                              <td class="popup-paramval"><span title="">'||g_rep_info(l_key)||'</span></td>
                           </tr>');
    END IF;
    l_key := g_rep_info.next(l_key);
  END LOOP;

  print_out('                       <tr>
                        <td class="popup-paramname"><b>Start time:</b></td>
                        <td class="popup-paramval">
                          <span id="start_time">' || to_char(g_analyzer_start_time,'hh24:mi:ss') ||
                          '</span>
                        </td>
                     </tr>');
  print_out('                       <tr>
                        <td class="popup-paramname"><b>End time:</b></td>
                        <td class="popup-paramval">
                          <span id="end_time">' || to_char(l_time,'hh24:mi:ss') ||
                          '</span>
                        </td>
                     </tr>');
  print_out('                       <tr>
                        <td class="popup-paramname"><b>Execution time:</b></td>
                        <td class="popup-paramval">
                          <span id="exec_time">' || format_elapsed(g_analyzer_elapsed, FALSE) ||
                          '</span>
                        </td>
                     </tr>');
  print_out('                        </tbody>
                     </table>
                <div class="close-button" data-popup-close="popup-1"><a class="black-link">OK</a></div>
            </div>
    </div>
  ');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_execdetails: '||sqlerrm);
  raise;
END print_execdetails;


----------------------------------------------------------------
-- Prints parameters pop-up window                            --
----------------------------------------------------------------
PROCEDURE print_parameters IS
BEGIN

  print_out('    <!-- print Parameters pop-up window -->
      <div class="popup" data-popup="popup-2">
            <div class="popup-inner">
                   <table cellpadding="5" cellspacing="0" border="0" width="100%" style="font-size: 14px;">
                        <tbody>
                           <tr>
                              <td colspan="2" class="popup-title"><b>Parameters</b></td>
                           </tr>');
  FOR i IN 1..g_parameters.COUNT LOOP
    print_out('                           <tr>
                              <td class="popup-paramname"><b>'||to_char(i)||'. '||g_parameters(i).pname||'</b></td>
                              <td class="popup-paramval"><span>'||g_parameters(i).pvalue||'</span></td>
                           </tr>');
  END LOOP;
    print_out('                        </tbody>
                     </table>
                <div class="close-button" data-popup-close="popup-2"><a class="black-link">OK</a></div>
            </div>

    </div>');

EXCEPTION WHEN OTHERS THEN
    print_log('Error in print_parameters: '||sqlerrm);
    raise;
END print_parameters;


PROCEDURE print_mainpage IS

   l_loop_count NUMBER;
   l_section_id  VARCHAR2(320);
   l_counter_str VARCHAR2(2048);
BEGIN

   l_loop_count := g_sections.count;

    print_out('
<!-- main menu with tiles -->

    <div class="mainmenu">
     <table align="center"  id="menutable">
        <tbody>
            <tr>
            <td>
              <div class="menubox">
                <table cellpadding="5" cellspacing="2" class="mboxinner">
                <thead>
                <tr><th><span class="menuboxitemt">Execution Summary</span></th></tr></thead>
                <tbody>
                <tr><td><div open-section="E" class="menuboxitem"><span class=''error_ico icon''></span><div class="mboxelem" title="List of signatures that affect critical business operations and should be addressed right away.">Errors</div></div></td>
                <td align="right"><span class="errcount">'||g_results('E')||'</span></td></tr>
                <tr><td><div open-section="W" class="menuboxitem"><span class=''warn_ico icon''></span><div class="mboxelem" title="List of signatures that do not affect critical business operations, but still could affect your business based on your requirements.">Warnings</div></div></td>
                <td align="right"><span class="warncount">'||g_results('W')||'</span></td></tr>
                <tr><td><div open-section="S" class="menuboxitem"><span class=''success_ico icon''></span><div class="mboxelem" title="List of Error and Warning signatures with no problem(s) identified.">Passed Checks</div></div></td>
                <td align="right"><span class="successcount">'||g_results('S')||'</span></td></tr>
                <tr><td><div open-section="I" class="menuboxitem"><span class=''information_ico icon''></span><div class="mboxelem" title="List of signatures that are data collection only.">Informational</div></div></td>
                <td align="right"><span class="infocount">'||g_results('I')||'</span></td></tr>
                <tr><td><div open-sig-class="passed" class="menuboxitem"><span class=''proc_success_small icon''></span><div class="mboxelem" title="Additional Error and Warning signatures with no problem(s) identified and designed to only display in the main report when they fail.">Background Passed Checks</div></div></td>
                <td align="right"><span class="infocount">'||g_results('P')||'</span></td></tr>
                </tbody></table>
              </div>
            </td>
            <td>');

    print_out('
                <table>
                <tr>');

    FOR i in 1 .. l_loop_count LOOP
        l_section_id := g_sec_detail(i).name;
        l_counter_str := '';

        IF (g_sec_detail(i).results('E') > 0)THEN
            l_counter_str := '<div class=''counternumber''>' || to_char(g_sec_detail(i).results('E')) || '</div><span class=''error_ico icon''></span>&nbsp;';
        END IF;
        IF (g_sec_detail(i).results('W') > 0)THEN
            l_counter_str := l_counter_str || '<div class=''counternumber''>' || to_char(g_sec_detail(i).results('W')) || '</div><span class=''warn_ico icon''></span>&nbsp;';
        END IF;
        IF (g_sec_detail(i).results('S') > 0)THEN
            l_counter_str := l_counter_str || '<div class=''counternumber''>' || to_char(g_sec_detail(i).results('S')) || '</div><span class=''success_ico icon''></span>&nbsp;';
        END IF;
        IF (g_sec_detail(i).results('I') > 0)THEN
            l_counter_str := l_counter_str || '<div class=''counternumber''>' || to_char(g_sec_detail(i).results('I')) || '</div><span class=''information_ico icon''></span>&nbsp;';
        END IF;
        IF (g_sec_detail(i).results('E') + g_sec_detail(i).results('W') + g_sec_detail(i).results('S') + g_sec_detail(i).results('I') = 0) THEN
            l_counter_str := '<span class=''menubox_subtitle''>Executed, nothing to report</span>';
        END IF;
        print_out('
                <td>
                <a href="#" class="blacklink"><div class="floating-box" open-section="'||l_section_id||'"><div class="textbox">'||g_sec_detail(i).title||'</div><div id="'||l_section_id||'Count" class="counterbox">'||l_counter_str||'</div></div></a>
                </td>');
        IF (MOD(i,3)=0 ) THEN
            print_out('                </tr><tr>');
        END IF;
    END LOOP;

    print_out('
                </tr>
            </table>
            </td></tr>
        </tbody>
     </table>
    </div>
<!-- end main menu -->     ');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_mainpage: '||sqlerrm);
  raise;
END print_mainpage;


----------------------------------------------------------------
-- Print footer and end of html page def                      --
----------------------------------------------------------------
PROCEDURE print_footer IS

BEGIN

   print_out('      <!-- footer area -->
       <div class="footerarea">
           <div class="footer">
               <div style="visibility: visible; max-height: 33px; min-height: 33px;">
                  <span><a href="' || g_mos_km_url || '432.1" target="_blank" class="blacklink">About Oracle Proactive Support</a></span>
                  <span class="separator"></span>
                  <span><a href="' || g_mos_sr_url || '" target="_blank" class="blacklink">Log a Service Request</a></span>
                  <span class="separator"></span>');
   -- just to be sure there is no error while getting the family area code
   BEGIN
   print_out('
                  <span><a href="' || g_mos_km_url || '1545562.1#' || nvl(g_fam_area_hash(nvl(g_family_area, 'ATG')), '') || '" target="_blank"');

   EXCEPTION WHEN OTHERS THEN
   print_out('
                  <span><a href="' || g_mos_km_url || '1545562.1" target="_blank"');
   END;
   print_out('
                  class="blacklink">Related Analyzers</a></span>
                  <span class="separator"></span>
                  <span><a href="' || g_mos_km_url || '1939637.1" target="_blank" class="blacklink">Analyzer Bundle Menu Tool</a></span>
                  <span class="separator"></span>
                  <span><a href="https://www.oracle.com/us/legal/privacy/overview/index.html" target="_blank" class="blacklink">Your Privacy Rights</a></span>
                  <span class="separator"></span>
                  <span><a href="' || g_mos_km_url || '2116869.1" target="_blank" class="blacklink">Frequently Asked Questions</a></span>
                  <span class="separator"></span>
                  <span><a href="https://support.oracle.com/epmos/faces/ui/sr/SrInteractionCenter.jspx" target="_blank" class="blacklink">Contact Us</a></span>','N');
   -- EBSAF-272
   if g_g2g_flag then
      print_out('
                  <span style="float:right;color:lightgreen;font-size:8px">&#9679;&#9679;&#9679;</span>','N');
   end if;
   print_out('
               </div>
           </div>
       </div><!-- end footer area -->
   ');
EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_footer: '||sqlerrm);
  raise;
END print_footer;


/* REMOVED TO ELIMINATE INLINE JAVASCRIPT (EBSAF-262)
----------------------------------------------------------------
-- Print execution times in the Execution Details page        --
----------------------------------------------------------------
PROCEDURE print_execution_time (l_time TIMESTAMP) IS
BEGIN

  print_out('        <script>
            $("#start_time").text("'||to_char(g_analyzer_start_time,'hh24:mi:ss')||'");
        </script>');
  print_out('        <script>
            $("#end_time").text("'||to_char(l_time,'hh24:mi:ss')||'");
        </script>');
  print_out('        <script>
            $("#exec_time").text("'||format_elapsed(g_analyzer_elapsed, FALSE)||'");
        </script>');

END print_execution_time;
*/


----------------------------------------------------------------
-- Split text into a varchar2 table (escape delims with \)    --
----------------------------------------------------------------
FUNCTION split_text(p_text varchar2 default null,
    p_delims varchar2 default ',') return varchar_tbl
IS
    l_tokens varchar_tbl := varchar_tbl();
    l_search varchar2(100);
BEGIN
    if p_text is null then
        return l_tokens;
    end if;

    l_search := '(\\[' || nvl(p_delims, ',') || ']|[^' || nvl(p_delims, ',') || '])+';
    select substr(trim(token), 1, 255)
    bulk collect into l_tokens
    from (
        select regexp_replace(
            -- Tokens matching search string
            regexp_substr(p_text, l_search, 1, level),
            -- EBSAF-306 Escaped delimiters must be reverted
            '\\([' || nvl(p_delims, ',') || '])', '\1') token
        from dual
        connect by regexp_substr(p_text, l_search, 1, level) is not null
    )
    where trim(token) is not null;

    return l_tokens;
exception when others then
    print_log('Error in split_text: '||sqlerrm);
    return l_tokens;
END split_text;


------------------------------------------------------
-- Join a varchar2 table into a single string       --
------------------------------------------------------
FUNCTION join_text(p_tokens varchar_tbl default null,
    p_delims varchar2 default ',') return varchar2
IS
    l_token varchar2(255);
    l_text varchar2(32767);
    l_token_count number;
    l_display_count number;
    l_text_size number;
    l_delim_size number;
BEGIN
    if p_tokens is null or p_tokens.count = 0 then
        return null;
    end if;

    l_text_size := 0;
    l_delim_size := length(p_delims);
    l_token_count := p_tokens.count;
    l_display_count := 0;
    for i in 1..l_token_count loop
        l_token := p_tokens(i);
        if l_token is not null then
            l_text_size := l_text_size + l_delim_size + length(l_token);
            exit when l_text_size > 32767;
            l_text := l_text || p_delims || l_token;
            l_display_count := l_display_count + 1;
        end if;
    end loop;

    if l_text_size > 32767 then
        debug('Too many values in join_text');
        debug('Showing '||l_display_count||' of '||l_token_count);
    end if;

    return substr(l_text, l_delim_size + 1);
exception when others then
    print_log('Error in join_text: '||sqlerrm);
    print_log('Showing '||l_display_count||' of '||l_token_count);
    return substr(l_text, l_delim_size + 1);
END join_text;


------------------------------------------------------
-- Filter leading/trailing spaces and invalid       --
-- characters.  Options are:                        --
--  [D]eleted (default), [H]idden, or [I]gnored     --
------------------------------------------------------
FUNCTION filter_html(
    p_text          IN VARCHAR2,
    p_spaces_opt    IN VARCHAR2 DEFAULT NULL,
    p_invalid_opt   IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
IS
    l_html varchar2(32767);
    l_tag_L varchar2(1) := '`';
    l_tag_R varchar2(1) := '~';
BEGIN
    if p_text is null then
        return null;
    end if;

    l_html := p_text;

    -- Handle invalid characters (EBSAF-263)
    -- Workaround needed for partial overlap of [:space:] and [:cntrl:].
    if nvl(p_invalid_opt, 'D') = 'D' then
        -- Deleted
        -- Keep spaces but delete control
        l_html := regexp_replace(l_html,
            '(([[:space:]])|([[:cntrl:]]))',
            '\2'
        );
    elsif p_invalid_opt = 'H' then
        -- Hidden
        -- Tag spaces
        -- Need to be different in case of control between spaces.
        -- Also shouldn't be common/paired characters: {},[], etc.
        l_html := regexp_replace(l_html,
            '([[:space:]])',
            l_tag_L||'\1'||l_tag_R
        );
        -- Replace untagged control
        l_html := regexp_replace(l_html,
            '([^'||l_tag_L||']|^)[[:cntrl:]]([^'||l_tag_R||']|$)',
            '\1&#65533;\2'
        );
        -- Remove tags from spaces
        l_html := regexp_replace(l_html,
            l_tag_L||'([[:space:]])'||l_tag_R,
            '\1'
        );
        -- Wrap groups of entities
        l_html := regexp_replace(l_html,
            '((&#65533;)+)',
            '<span class="hidden_data" hide-type="err">\1</span>'
        );
    elsif p_invalid_opt = 'I' then
        -- Ignored
        null;
    end if;

    -- Handle leading/trailing spaces (EBSAF-255)
    if nvl(p_spaces_opt, 'D') = 'D' then
         -- Deleted
        l_html := regexp_replace(l_html,
            '(^[[:space:]]+|[[:space:]]+$)',
            null
        );
    elsif p_spaces_opt = 'H' then
       -- Hidden
        l_html := regexp_replace(l_html,
            '(^[[:space:]]+|[[:space:]]+$)',
            '<span class="hidden_data" hide-type="wrn">\1</span>'
        );
    elsif p_spaces_opt = 'I' then
        -- Ignored
        null;
    end if;

    return l_html;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in filter_html: '||sqlerrm||'.  Text unmodified.');
    return p_text;
END filter_html;


------------------------------------------------------------------
-- Remove HTML formatting from text (EBSAF-294)     --
------------------------------------------------------------------
FUNCTION plain_text(p_text varchar2 default null) return varchar2
IS
    l_text varchar2(32767);
    l_old_length number;
BEGIN
    l_text := p_text;

    -- Keep text between matching open/close tags (loop for nested tags)
    l_old_length := length(l_text);
    loop
        l_text := regexp_replace(l_text,'<(\w+)(\s[^>]*)?>(.*?)</\1>', '\3', 1, 1, 'im');
        exit when l_old_length = length(l_text);
        l_old_length := length(l_text);
    end loop;

    -- Convert breaks
    l_text := regexp_replace(l_text,'<br[^>]*?/?>', chr(10), 1, 0, 'i');

    -- Remove other standalone tags
    l_text := regexp_replace(l_text,'<(hr|img|input|link|meta|wbr)(>|\W[^>]*>)', null, 1, 0, 'i');

    -- Restore entities
    l_text := regexp_replace(l_text,'&apos;', '''', 1, 0, 'i');
    l_text := regexp_replace(l_text,'&quot;', '"', 1, 0, 'i');
    l_text := regexp_replace(l_text,'&lt;', '<', 1, 0, 'i');
    l_text := regexp_replace(l_text,'&gt;', '>', 1, 0, 'i');
    l_text := regexp_replace(l_text,'&amp;', '&', 1, 0, 'i');

    return l_text;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in plain_text: '||sqlerrm||'.  Text unmodified.');
    return p_text;
END plain_text;


------------------------------------------------------------------
-- Get the masked data according to mask option (EBSAF-269)     --
-- NOTE: This is different than client-side masking             --
------------------------------------------------------------------
FUNCTION mask_text(p_text varchar2 default null,
    p_mask_option varchar2 default null) return varchar2
IS
    l_text_length number;
    l_mask_char varchar2(1) := '*';
    l_masked_text varchar2(32767);
    l_mask_length number;
    l_unmask_length number;
    l_word varchar2(32767);
    l_char varchar2(4);
    l_word_length number;
    l_word_active boolean;
    l_tokens varchar_tbl;
    l_full_mask varchar2(32767);
    l_ip_pattern varchar2(255) := '^[[:digit:]]+[.][[:digit:]]+[.][[:digit:]]+[.][[:digit:]]+$';
BEGIN
    -- Quick exit if masking not necessary or possible
    if (p_mask_option = 'NO_MASK' or p_text is null) then
        return p_text;
    end if;

    -- Get the full masked value as a backup
    l_text_length := length(p_text);
    l_full_mask := rpad(l_mask_char, l_text_length, l_mask_char);

    case(p_mask_option)
    when 'DISPLAY_FIRST_4_CHAR' then
        -- Display first 4 characters of entire text
        l_unmask_length := least(4, l_text_length);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(p_text, 1, l_unmask_length) || substr(l_full_mask, 1, l_mask_length);
    when 'DISPLAY_LAST_4_CHAR' then
        -- Display last 4 characters of entire text
        l_unmask_length := least(4, l_text_length);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(l_full_mask, 1, l_mask_length) || substr(p_text, -1 * l_unmask_length, l_unmask_length);
    when 'DISPLAY_FIRST_25_PCNT' then
        -- Display first 25% of entire text
        l_unmask_length := ceil(0.25 * l_text_length);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(p_text, 1, l_unmask_length) || substr(l_full_mask, 1, l_mask_length);
    when 'DISPLAY_LAST_25_PCNT' then
        -- Display last 25% of entire text
        l_unmask_length := ceil(0.25 * l_text_length);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(l_full_mask, 1, l_mask_length) || substr(p_text, -1 * l_unmask_length, l_unmask_length);
    when 'DISPLAY_FIRST_WORD' then
        -- Display first word of entire text
        l_word := regexp_replace(p_text, '^([^[:alnum:]]*[[:alnum:]]+).*?$', '\1');
        l_unmask_length := length(l_word);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(p_text, 1, l_unmask_length) || substr(l_full_mask, 1, l_mask_length);
    when 'DISPLAY_LAST_WORD' then
        -- Display last word of entire text
        l_word := regexp_replace(p_text, '^.*?([[:alnum:]]+[^[:alnum:]]*)$', '\1');
        l_unmask_length := length(l_word);
        l_mask_length := l_text_length - l_unmask_length;
        l_masked_text := substr(l_full_mask, 1, l_mask_length) || substr(p_text, -1 * l_unmask_length, l_unmask_length);
    when 'DISPLAY_BOTH_25_PCNT_WORD' then
        -- Display first and last 25% of each word
        l_word := null;
        l_word_length := 0;
        l_masked_text := null;
        for i in 1..l_text_length loop
            l_char := substr(p_text, i, 1);
            if regexp_like(l_char, '[[:alnum:]]') then
                -- Letter/number found, keep building word
                l_word_active := true;
                l_word_length := l_word_length + 1;
                l_word := l_word || l_char;
                -- Clear letter to prevent duplication at end
                l_char := null;
            else
                l_word_active := false;
            end if;
            if not l_word_active or i = l_text_length then
                if (l_word_length > 2) then
                    -- Mask captured word
                    l_unmask_length := ceil(0.25 * l_word_length);
                    l_mask_length := l_word_length - 2 * l_unmask_length;
                    l_masked_text := l_masked_text ||
                        substr(l_word, 1, l_unmask_length) ||
                        substr(l_full_mask, 1, l_mask_length) ||
                        substr(l_word, -1 * l_unmask_length, l_unmask_length);
                    l_word := null;
                    l_word_length := 0;
                elsif (l_word_length > 0) then
                    -- Word too short, mask entire thing
                    l_masked_text := l_masked_text || substr(l_full_mask, 1, l_word_length);
                    l_word := null;
                    l_word_length := 0;
                end if;
                l_masked_text := l_masked_text || l_char;
            end if;
        end loop;
    when 'DISPLAY_FIRST_25_PCNT_WORD' then
        -- Display first 25% of each word (EBSAF-281)
        l_word := null;
        l_word_length := 0;
        l_masked_text := null;
        for i in 1..l_text_length loop
            l_char := substr(p_text, i, 1);
            if regexp_like(l_char, '[[:alnum:]]') then
                -- Letter/number found, keep building word
                l_word_active := true;
                l_word_length := l_word_length + 1;
                l_word := l_word || l_char;
                -- Clear letter to prevent duplication at end
                l_char := null;
            else
                l_word_active := false;
            end if;
            if not l_word_active or i = l_text_length then
                if (l_word_length > 2) then
                    -- Mask captured word
                    l_unmask_length := ceil(0.25 * l_word_length);
                    l_mask_length := l_word_length - l_unmask_length;
                    l_masked_text := l_masked_text ||
                        substr(l_word, 1, l_unmask_length) ||
                        substr(l_full_mask, 1, l_mask_length);
                    l_word := null;
                    l_word_length := 0;
                elsif (l_word_length > 0) then
                    -- Word too short, mask entire thing
                    l_masked_text := l_masked_text || substr(l_full_mask, 1, l_word_length);
                    l_word := null;
                    l_word_length := 0;
                end if;
                l_masked_text := l_masked_text || l_char;
            end if;
        end loop;
    when 'DISPLAY_LAST_25_PCNT_WORD' then
        -- Display last 25% of each word (EBSAF-281)
        l_word := null;
        l_word_length := 0;
        l_masked_text := null;
        for i in 1..l_text_length loop
            l_char := substr(p_text, i, 1);
            if regexp_like(l_char, '[[:alnum:]]') then
                -- Letter/number found, keep building word
                l_word_active := true;
                l_word_length := l_word_length + 1;
                l_word := l_word || l_char;
                -- Clear letter to prevent duplication at end
                l_char := null;
            else
                l_word_active := false;
            end if;
            if not l_word_active or i = l_text_length then
                if (l_word_length > 2) then
                    -- Mask captured word
                    l_unmask_length := ceil(0.25 * l_word_length);
                    l_mask_length := l_word_length - l_unmask_length;
                    l_masked_text := l_masked_text ||
                        substr(l_full_mask, 1, l_mask_length) ||
                        substr(l_word, -1 * l_unmask_length, l_unmask_length);
                    l_word := null;
                    l_word_length := 0;
                elsif (l_word_length > 0) then
                    -- Word too short, mask entire thing
                    l_masked_text := l_masked_text || substr(l_full_mask, 1, l_word_length);
                    l_word := null;
                    l_word_length := 0;
                end if;
                l_masked_text := l_masked_text || l_char;
            end if;
        end loop;
    when 'DISPLAY_1_3_OCTET' then
        -- Display 1st and 3rd octet of IP address
        if regexp_like(p_text, l_ip_pattern) then
            l_tokens := split_text(p_text, '.');
            l_masked_text := l_tokens(1) || '.***.' || l_tokens(3) || '.***';
        else
            -- Invalid format, mask everything
            l_masked_text := l_full_mask;
        end if;
    when 'DISPLAY_2_4_OCTET' then
        -- Display 2nd and 4th octet of IP address
        if regexp_like(p_text, l_ip_pattern) then
            l_tokens := split_text(p_text, '.');
            l_masked_text := '***.' || l_tokens(2) || '.***.' || l_tokens(4);
        else
            -- Invalid format, mask everything
            l_masked_text := l_full_mask;
        end if;
    when 'DISPLAY_4_OCTET' then
        -- Display 4th octet of IP address
        if regexp_like(p_text, l_ip_pattern) then
            l_tokens := split_text(p_text, '.');
            l_masked_text := '***.***.***.' || l_tokens(4);
        else
            -- Invalid format, mask everything
            l_masked_text := l_full_mask;
        end if;
    when 'MASK_ALPHANUMERIC' then
        -- Mask all letters and numbers
        l_masked_text := regexp_replace(p_text, '[[:alnum:]]', l_mask_char);
    when 'DISPLAY_NONE' then
        -- Mask everything
        l_masked_text := l_full_mask;
    when 'HASH_VALUE' then
        -- Generate hash of the text
        select ('HASH_' || ora_hash(p_text)) into l_masked_text from dual;
    when 'REMOVE_COLUMN' then
        -- Remove the entire column
        l_masked_text := null;
    else
        -- Invalid option, mask everything
        l_masked_text := l_full_mask;
    end case;

    -- When all or nothing, choose nothing
    if (l_masked_text = p_text) then
        l_masked_text := l_full_mask;
    end if;

    return l_masked_text;
EXCEPTION
   WHEN OTHERS THEN
        print_log('Error in mask_text(' || p_mask_option || '): ' || sqlerrm);
        return l_full_mask;
END mask_text;


----------------------------------------------------------------
-- Evaluates if a rowcol meets desired criteria               --
----------------------------------------------------------------
FUNCTION evaluate_rowcol(p_oper varchar2, p_criteria varchar2, p_value varchar2,
    p_criteria_set varchar_tbl default null) return boolean is
    l_value VARCHAR2(4000);
    l_criteria VARCHAR2(255);   -- SIGNATURES.FAIL_CONDITION is only varchar2(240)
    l_oper VARCHAR2(255);
    l_result boolean := false;
    l_comparing_num   boolean := false;
    l_value_num   NUMBER;
    l_criteria_num   NUMBER;
    l_comparing_date   boolean := false;
    l_value_date date;
    l_criteria_date date;
BEGIN
    -- Expand out SQL Tokens (EBSAF-199)
    IF (p_criteria like '##$$%$$##' and g_sql_tokens.exists(p_criteria) ) THEN
        l_criteria := g_sql_tokens(p_criteria);
    ELSE
        l_criteria := p_criteria;
    END IF;
    l_value := p_value;
    l_oper := trim(upper(regexp_replace(p_oper,'\s+',' ')));

    -- Relative operations require data type conversion
    IF l_oper IN ('<=','<','>','>=') THEN
        -- Attempt to convert to number
        BEGIN
            l_value_num := to_number(l_value);
            l_criteria_num := to_number(l_criteria);
            l_comparing_num := true;
            l_comparing_date := false;
        EXCEPTION WHEN OTHERS THEN
            l_comparing_num := false;
        END;
        -- Otherwise, attempt to convert to sortable date
        IF NOT l_comparing_num THEN
            BEGIN
                l_value_date := to_date(l_value);
                l_criteria_date := to_date(l_criteria);
                l_comparing_date := true;
            EXCEPTION WHEN OTHERS THEN
                l_comparing_date := false;
            END;
        END IF;
        IF l_comparing_date THEN
            l_value := to_char(l_value_date, 'YYYYMMDDHH24MISS');
            l_criteria := to_char(l_criteria_date, 'YYYYMMDDHH24MISS');
        END IF;
    END IF;

    -- Do comparisons
    IF l_oper = '=' THEN
        l_result := l_value = l_criteria;
    ELSIF l_oper = '!=' OR l_oper = '<>' THEN
        l_result := l_value != l_criteria;
    ELSIF l_oper = '>' THEN
        IF l_comparing_num THEN
            l_result := l_value_num > l_criteria_num;
        ELSE
            l_result := l_value > l_criteria;
        END IF;
    ELSIF l_oper = '<' THEN
        IF l_comparing_num THEN
            l_result := l_value_num < l_criteria_num;
        ELSE
            l_result := l_value < l_criteria;
        END IF;
    ELSIF l_oper = '<=' THEN
        IF l_comparing_num THEN
            l_result := l_value_num <= l_criteria_num;
        ELSE
            l_result := l_value <= l_criteria;
        END IF;
    ELSIF l_oper = '>=' THEN
        IF l_comparing_num THEN
            l_result := l_value_num >= l_criteria_num;
        ELSE
            l_result := l_value >= l_criteria;
        END IF;
    -- EBSAF-198
    ELSIF l_oper = 'LIKE' THEN
        l_result := l_value like l_criteria;
    ELSIF l_oper = 'NOT LIKE' THEN
        l_result := l_value not like l_criteria;
    ELSIF l_oper = 'IS NULL' THEN
        l_result := l_value is null;
    ELSIF l_oper = 'IS NOT NULL' THEN
        l_result := l_value is not null;
    ELSIF l_oper = 'IN' OR l_oper = 'NOT IN' THEN
        IF p_criteria_set is null or p_criteria_set.count = 0 THEN
            -- Criteria set is required
            print_log('No fail condition criteria for ' || l_oper || ' operation');
            raise COLLECTION_IS_NULL;
        ELSE
            -- Check value against each criteria in the set
            l_result := false;
            for i in 1..p_criteria_set.count loop
                -- EBSAF-306 Recursive check for at least one match
                if not l_result then
                    l_result := evaluate_rowcol('=', p_criteria_set(i), p_value);
                end if;
            end loop;
            if l_oper = 'NOT IN' then
                l_result := l_value is not null and not l_result;
            end if;
        END IF;
    ELSE
        print_log('Unknown fail condition operation: ' || l_oper);
        raise VALUE_ERROR;
    END IF;
    return l_result;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in evaluate_rowcol');
    raise;
END evaluate_rowcol;

/* CONSOLIDATED INTO expand_html (EBSAF-180)
---------------------------------------------
-- Expand [note] or {patch} tokens         --
---------------------------------------------
FUNCTION expand_links(p_str VARCHAR2, p_sigrepo_id VARCHAR2 DEFAULT '')
    return VARCHAR2
IS
  l_str VARCHAR2(32767);
BEGIN
  -- Assign to working variable
  l_str := p_str;

  -- First deal with patches - add codeline for R12 patches
  l_str := regexp_replace(l_str,'({)([0-9]*)(})',
    '<a target="_blank" href="'||g_mos_patch_url||'\2">\2</a>',1,0);
  -- Same for notes
  l_str := regexp_replace(l_str,'(\[)([0-9]*\.[0-9])(\#[a-zA-Z0-9_]+)*(\])',
    '<a target="_blank" href="'||g_mos_doc_url||'_sigId'||p_sigrepo_id||'&id=\2\3">Doc ID \2</a>',1,0);
  return l_str;
EXCEPTION WHEN OTHERS THEN
     print_log ('Exception in expand_links: ' || SQLERRM);
     return p_str;
END expand_links;
*/

/* CONSOLIDATED INTO expand_html (EBSAF-180)
------------------------------------------------------------------
-- Expand {#TOKEN#} tokens - replace with value from extra_info --
------------------------------------------------------------------
FUNCTION expand_tokens(p_str VARCHAR2, p_extra_info HASH_TBL_4K)
    return VARCHAR2
IS
  l_str VARCHAR2(32767);
  l_key VARCHAR2(256);
  l_regex VARCHAR2(256);
BEGIN
  l_str := p_str;

  -- if there is no token in the text, return
  IF NOT regexp_like(p_str,'{#') THEN
      RETURN p_str;
  END IF;

  IF p_extra_info.count > 0 THEN
    l_key := p_extra_info.first;
    WHILE l_key IS NOT NULL LOOP
      IF regexp_like(l_key,'^#[^#]') THEN
          l_regex := '{' || l_key || '}';
          l_str := regexp_replace(l_str, l_regex, p_extra_info(l_key));
      END IF;
    l_key := p_extra_info.next(l_key);
    END LOOP;
  END IF;

  RETURN l_str;
EXCEPTION WHEN OTHERS THEN
  debug ('Exception when trying to expand tokens: ' || SQLERRM);
  return p_str;
END expand_tokens;
*/

---------------------------------------------------------------------
-- Populate user and respo details when running as conc request    --
---------------------------------------------------------------------
PROCEDURE populate_user_details IS
    l_user_name   fnd_user.user_name%type := fnd_global.user_name ;
    l_resp_name   VARCHAR2(256) := fnd_global.resp_name ;
BEGIN
   g_rep_info('Username') := mask_text(l_user_name, 'DISPLAY_BOTH_25_PCNT_WORD');  --EBSAF-280
   g_rep_info('Responsibility') := l_resp_name;
EXCEPTION WHEN OTHERS THEN
  debug ('Error in populate_user_details: '||sqlerrm);
END populate_user_details;


------------------------------------------------------
-- Expand the SQL tokens (for SQL only)             --
------------------------------------------------------
FUNCTION expand_sql_tokens(
  p_raw_sql IN VARCHAR2,
  p_mask_flag IN VARCHAR2 default null
) RETURN VARCHAR2
IS
  l_formatted_sql  VARCHAR2(32767);
  l_key             VARCHAR2(255);
  l_pattern         VARCHAR2(612);
  l_do_mask BOOLEAN := nvl(p_mask_flag, 'N') = 'Y';
BEGIN
  -- Assign signature to working variable
  l_formatted_sql := p_raw_sql;
  --  Replace SQL tokens inside the SQL (exclude the cases when the SQL token is used as a column alias)
  l_key := g_sql_tokens.first;
  WHILE l_key is not null LOOP
    l_pattern := '([^"])' || l_key;
    l_pattern := replace(l_pattern, '$' , '\$');
    -- Allow tokens to be masked (EBSAF-275)
    if l_do_mask then
        l_formatted_sql := regexp_replace(l_formatted_sql, l_pattern , '\1' || g_masked_tokens(l_key));
    else
        l_formatted_sql := regexp_replace(l_formatted_sql, l_pattern , '\1' || g_sql_tokens(l_key));
    end if;
    l_key := g_sql_tokens.next(l_key);
  END LOOP;
  RETURN l_formatted_sql;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in expand_sql_tokens');
  raise;
END expand_sql_tokens;

/* CONSOLIDATED INTO expand_html (EBSAF-180)
------------------------------------------------------
-- Prepare the text with the substitution values     --
------------------------------------------------------
FUNCTION prepare_text(
  p_raw_text IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_formatted_text  VARCHAR2(32767);
  l_key             VARCHAR2(255);
BEGIN
  -- Assign signature to working variable
  l_formatted_text := p_raw_text;

  -- Allow tokens to be masked (EBSAF-275)
  l_key := g_masked_tokens.first;
  WHILE l_key is not null LOOP
    l_formatted_text := replace(l_formatted_text, l_key, g_masked_tokens(l_key));
    l_key := g_masked_tokens.next(l_key);
  END LOOP;
  RETURN l_formatted_text;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in prepare_text');
  raise;
END prepare_text;
*/

------------------------------------------------------
-- Expand all values in text into HTML (EBSAF-180)  --
------------------------------------------------------
FUNCTION expand_html(
    p_raw_text  IN VARCHAR2,
    p_sig_id    IN VARCHAR2 default null
) RETURN VARCHAR2
IS
    l_step  VARCHAR2(20) := '00';
    l_html  VARCHAR2(32767);
    l_key   VARCHAR2(255);
    l_url   VARCHAR2(4000);
    l_sigrepo_id    VARCHAR2(10);
    l_extra_info    HASH_TBL_4K;
BEGIN
    -- Quick exit test
    if p_raw_text is null then
        return null;
    else
        l_html := p_raw_text;
    end if;

    -- Get signature details
    l_step := '10';
    if p_sig_id is not null and g_signatures.exists(p_sig_id) then
        l_sigrepo_id := g_signatures(p_sig_id).sigrepo_id;
        l_extra_info := g_signatures(p_sig_id).extra_info;
    end if;

    -- Expand masked SQL tokens: ##$$TOKEN$$##
    l_step := '20';
    IF regexp_like(l_html,'##\$\$[^#]+\$\$##') THEN
        l_key := g_masked_tokens.first;
        WHILE l_key is not null LOOP
            l_html := replace(l_html, l_key, g_masked_tokens(l_key));
            l_key := g_masked_tokens.next(l_key);
        END LOOP;
    END IF;

    -- Expand extra info tokens: {#TAG#}
    l_step := '30';
    IF l_extra_info.count > 0 and regexp_like(l_html,'\{#[^#]+#\}') THEN
        l_key := l_extra_info.first;
        WHILE l_key IS NOT NULL LOOP
            IF regexp_like(l_key,'^#[^#]+#') THEN
                l_html := replace(l_html,
                    '{' || l_key || '}', l_extra_info(l_key) );
            END IF;
            l_key := l_extra_info.next(l_key);
        END LOOP;
    END IF;

    -- Expand patch tokens: {123456}
    l_step := '40';
    l_html := regexp_replace(l_html,
        '\{([0-9]+)\}',
        '<a target="_blank" href="' || g_mos_patch_url || '\1">\1</a>'
    );

    -- Expand note tokens: [432.1#HEADER]
    l_step := '50';
    IF l_sigrepo_id is not null THEN
        l_url := g_mos_doc_url || '_sigId' || l_sigrepo_id || '&id=';
    ELSE
        l_url := g_mos_doc_url || '&id=';
    END IF;
    l_html := regexp_replace(l_html,
        -- EBSAF-297 Add space as allowed character in anchor
        '\[([0-9]+\.[0-9])(#[a-zA-Z 0-9_]+)?\]',
        '<a target="_blank" href="' || l_url || '\1\2">Doc ID \1</a>'
    );

    RETURN l_html;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in expand_html at step ' || l_step);
    raise;
END expand_html;


---------------------------------------------
-- Remove [note] or {patch} token brackets --
---------------------------------------------
FUNCTION remove_links(p_text IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_text VARCHAR2(32767);
BEGIN
    -- Quick exit test
    if p_text is null then
        return null;
    else
        l_text := p_text;
    end if;

    -- Strip patch tokens: {123456}
    l_text := regexp_replace(l_text,
        '\{([0-9]+)\}',
        '\1'
    );

    -- Strip note tokens: [432.1#HEADER]
    l_text := regexp_replace(l_text,
        '\[([0-9]+\.[0-9])(#[a-zA-Z 0-9_]+)?\]',
        '\1\2'
    );

    RETURN l_text;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in remove_links: '||sqlerrm||'.  Text unmodified.');
    RETURN p_text;
END remove_links;


----------------------------------------------------------
-- Change text like #ABC_DEF# into Abc Def              --
----------------------------------------------------------
FUNCTION word_to_titlecase(p_text IN VARCHAR2)
   RETURN VARCHAR2
IS
BEGIN
    return initcap(replace(replace(p_text,
        '_', ' '),
        '#', '')
    );
EXCEPTION WHEN OTHERS THEN
   print_log('Error in word_to_titlecase: '||sqlerrm||'.  Text unmodified.');
   return p_text;
END word_to_titlecase;


----------------------------------------------------------
-- Prepare the SQL for display in header and remove     --
-- references to FK strings                             --
----------------------------------------------------------
FUNCTION prepare_SQL(p_raw_SQL IN VARCHAR2)
   RETURN VARCHAR2
IS
   l_modified_SQL  VARCHAR2(32767);
BEGIN
   l_modified_SQL := escape_html(p_raw_SQL);  -- EBSAF-180
   l_modified_SQL := regexp_replace(l_modified_SQL, '\S+\s+"#{2}\${2}FK[0-9]\${2}#{2}"\s*,\s*', ' ');
   l_modified_SQL := regexp_replace(l_modified_SQL, ',\s*\S+\s+"#{2}\${2}FK[0-9]\${2}#{2}"\s*', ' ');
   l_modified_SQL := expand_sql_tokens(l_modified_SQL, 'Y');

   return l_modified_SQL;
EXCEPTION WHEN OTHERS THEN
   print_log('Error in prepare_SQL: '||sqlerrm||'.  Text unmodified.');
   return p_raw_SQL;
END prepare_SQL;


----------------------------------------------------------------
-- Set partial section result                                 --
----------------------------------------------------------------
PROCEDURE set_item_result(result varchar2) is
BEGIN
  IF g_sections(g_sections.last).result in ('U','I') THEN
          g_sections(g_sections.last).result := result;
      ELSIF g_sections(g_sections.last).result = 'S' THEN
        IF result in ('E','W') THEN
          g_sections(g_sections.last).result := result;
        END IF;
      ELSIF g_sections(g_sections.last).result = 'W' THEN
        IF result = 'E' THEN
          g_sections(g_sections.last).result := result;
        END IF;
      END IF;
  -- Set counts
  IF result = 'S' THEN
    g_sections(g_sections.last).success_count :=
       g_sections(g_sections.last).success_count + 1;
  ELSIF result = 'W' THEN
    g_sections(g_sections.last).warn_count :=
       g_sections(g_sections.last).warn_count + 1;
  ELSIF result = 'E' THEN
    g_sections(g_sections.last).error_count :=
       g_sections(g_sections.last).error_count + 1;
  END IF;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in set_item_result: '||sqlerrm);
END set_item_result;


----------------------------------------------------------------------
-- Create associative tables that will keep the links
-- between the signatures that use hyperlinks
----------------------------------------------------------------------
PROCEDURE create_hyperlink_table IS
    TYPE l_split_str_type IS TABLE OF VARCHAR(126);
    l_split_str          l_split_str_type := l_split_str_type();
    l_hyperlink          VARCHAR2(512);
    l_hyperlink_group    VARCHAR2(2048);
    l_count              NUMBER;
    l_key                VARCHAR2(215);
    l_group_flag         BOOLEAN := TRUE;
    l_single_flag        BOOLEAN := TRUE;
BEGIN
    l_key := g_signatures.first;


    WHILE ((l_key IS NOT NULL) AND (g_signatures.EXISTS(l_key))) LOOP
        IF (g_signatures(l_key).extra_info.EXISTS('##HYPERLINK##')) AND (g_signatures(l_key).extra_info('##HYPERLINK##') IS NOT NULL) THEN
            l_hyperlink_group := g_signatures(l_key).extra_info('##HYPERLINK##');
             -- remove the table entry as we won't need it anymore
            g_signatures(l_key).extra_info.DELETE('##HYPERLINK##');

            -- if there are multiple links, push each group one by one (they are split through : )
            WHILE (l_hyperlink_group IS NOT NULL) LOOP
                l_hyperlink := regexp_substr(l_hyperlink_group, '^([^:]+)');
                l_hyperlink_group := regexp_replace(l_hyperlink_group, '^([^:]+)$', '');
                l_hyperlink_group := regexp_replace(l_hyperlink_group, '^([^:]+):(.+)', '\2');
            l_count := 1;

                -- split the string and extract the hyperlink details
                WHILE (l_count < 4) AND (l_hyperlink IS NOT NULL) LOOP
                     l_split_str.extend();
                     l_split_str(l_count) := regexp_substr(l_hyperlink, '^([^,]+)');
                     l_hyperlink := regexp_replace(l_hyperlink, '^([^,]+),(.+)', '\2');
                    l_count := l_count + 1;
                END LOOP;

                 IF (l_count < 3) THEN
                     print_log('Broken hyperlink! ');
                    GOTO go_next2;
                 END IF;

                -- populate dest to source table (anchors)
                g_dest_to_source(UPPER(l_split_str(2))).cols(UPPER(l_split_str(3))) := 'a' || to_char(g_hypercount);
                -- populate source to dest (links) table - sig and column names in upper case
                g_source_to_dest(l_key).cols(UPPER(l_split_str(1))) := 'a' || to_char(g_hypercount);
                g_hypercount := g_hypercount + 1;
            <<go_next2>>
            NULL;
            END LOOP;
        END IF;
    l_key := g_signatures.next(l_key);
    END LOOP;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in create_hyperlink_table: '||sqlerrm);
END create_hyperlink_table;


----------------------------------------------------------------------
-- Runs a single SQL using DBMS_SQL returns filled tables
-- Precursor to future run_signature which will call this and
-- the print api. For now calls are manual.
----------------------------------------------------------------------
FUNCTION run_sig_sql(
   p_sig_id       IN  VARCHAR2 DEFAULT '',  -- We need the sig id for printing it in the output (EBSAF-201)
   p_raw_sql      IN  VARCHAR2,     -- SQL in the signature may require substitution
   p_col_rows     OUT COL_LIST_TBL, -- signature SQL column names
   p_col_headings OUT VARCHAR_TBL,  -- signature SQL row values
   p_limit_rows   IN  VARCHAR2 DEFAULT 'Y',
   p_parent_sig_id IN VARCHAR2 DEFAULT NULL -- Needed for performance tracking (EBSAF-177)
) RETURN BOOLEAN IS
  l_sql            VARCHAR2(32700);
  c                INTEGER;
  l_rows_fetched   NUMBER;
  l_total_rows     NUMBER DEFAULT 0;
  l_step           VARCHAR2(20);
  l_col_rows       COL_LIST_TBL := col_list_tbl();
  l_col_headings   VARCHAR_TBL := varchar_tbl();
  l_col_cnt        INTEGER;
  l_desc_rec_tbl   DBMS_SQL.DESC_TAB2;
BEGIN
  sig_time_start(p_sig_id, p_parent_sig_id, 'Q'); -- EBSAF-177

  -- Prepare the Signature SQL
  l_step := '10';
  l_sql := expand_sql_tokens(p_raw_sql);

  l_step := '20';
  get_current_time(g_query_start_time);
  debug('Query start');
  c := dbms_sql.open_cursor;

  l_step := '30';
  DBMS_SQL.PARSE(c, l_sql, DBMS_SQL.NATIVE);

  -- Get column count and descriptions
  l_step := '40';
  DBMS_SQL.DESCRIBE_COLUMNS2(c, l_col_cnt, l_desc_rec_tbl);

  -- Register arrays to bulk collect results and set headings
  l_step := '50';
  FOR i IN 1..l_col_cnt LOOP
    l_step := '50.1.'||to_char(i);
    l_col_headings.extend();
    l_col_headings(i) := replace(l_desc_rec_tbl(i).col_name,'|','<br>');
    l_col_rows.extend();
    dbms_sql.define_array(c, i, l_col_rows(i), g_max_output_rows, 1);
  END LOOP;

  -- Execute and Fetch
  l_step := '60';
  -- the return value from DBMS_SQL.EXECUTE() will always be 0 for SELECT, so the actual value of l_rows_fetched will come from FETCH
  l_rows_fetched := DBMS_SQL.EXECUTE(c);
  l_rows_fetched := DBMS_SQL.FETCH_ROWS(c);

  l_step := '70';
  IF l_rows_fetched > 0 THEN
    FOR i in 1..l_col_cnt LOOP
      l_step := '70.1.'||to_char(i);
      DBMS_SQL.COLUMN_VALUE(c, i, l_col_rows(i));
    END LOOP;
  l_total_rows := l_rows_fetched;
  END IF;
  IF nvl(p_limit_rows,'Y') = 'N' THEN
    WHILE l_rows_fetched = g_max_output_rows LOOP
      l_rows_fetched := DBMS_SQL.FETCH_ROWS(c);
      l_total_rows := l_total_rows + l_rows_fetched;
      FOR i in 1..l_col_cnt LOOP
        l_step := '70.2.'||to_char(i);
        DBMS_SQL.COLUMN_VALUE(c, i, l_col_rows(i));
      END LOOP;
    END LOOP;
  END IF;
  g_query_elapsed := stop_timer(g_query_start_time);
  debug('Query finish ('||format_elapsed(g_query_elapsed)||')');
  debug(' Rows fetched: '||to_char(l_total_rows));

  -- Close cursor
  l_step := '80';
  IF dbms_sql.is_open(c) THEN
    dbms_sql.close_cursor(c);
  END IF;

  -- Set out parameters
  p_col_headings := l_col_headings;
  p_col_rows := l_col_rows;
  sig_time_add(p_sig_id, p_parent_sig_id, 'Q'); -- EBSAF-177 Time only needed for successful query

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    g_query_elapsed := stop_timer(g_query_start_time);
    debug('Query failed ('||format_elapsed(g_query_elapsed)||')');
    g_errbuf := 'PROGRAM ERROR<br>
      Error in run_sig_sql at step '|| l_step||': '||sqlerrm||'<br>
      See the log file for additional details';
    print_log('Error in run_sig_sql at step '||l_step||' running: '||l_sql);
    print_log('Error: '||sqlerrm);
    IF dbms_sql.is_open(c) THEN
      dbms_sql.close_cursor(c);
    END IF;
    RETURN FALSE;
END run_sig_sql;

FUNCTION get_tags (
  p_sig_id     VARCHAR2) RETURN VARCHAR2
IS
  l_tags_str  VARCHAR2(512);
  l_replace_pattern VARCHAR2(200);
BEGIN
  l_tags_str := '';
  l_replace_pattern := '                    <div class="sigtag"  tag="\1" style="display:none;"></div>
';
  IF (
    g_signatures.EXISTS(p_sig_id)
    AND g_signatures(p_sig_id).extra_info.EXISTS('#IMPACT_AREAS#')
    AND g_signatures(p_sig_id).extra_info('#IMPACT_AREAS#') IS NOT NULL
  ) THEN
        l_tags_str := g_signatures(p_sig_id).extra_info('#IMPACT_AREAS#');
        l_tags_str := regexp_replace(l_tags_str, '([a-zA-Z0-9][^,]+[0-9a-zA-Z])', l_replace_pattern, 1, 0);
        l_tags_str := regexp_replace(l_tags_str, chr(10)||', ', chr(10), 1, 0);
  END IF;
  RETURN l_tags_str;
EXCEPTION
  WHEN OTHERS THEN
  print_log ('Could not get tags / impact areas for sig id: ' || p_sig_id);
  print_log (SQLERRM);
  RETURN '';
END get_tags;

----------------------------------------------------------------------
-- XML functions to simplify DX summary creation
----------------------------------------------------------------------
-- Create XML node with multiple attributes and return it
FUNCTION append_hidden_xml(
    p_parent_node XMLDOM.DOMNode,
    p_tag_name varchar2,
    p_tag_type varchar2 default null,
    p_tag_text varchar2 default null,
    p_attr_list varchar_tbl,
    p_val_list varchar_tbl
) RETURN XMLDOM.DOMNode IS
    l_parent XMLDOM.DOMNode;
    l_elem XMLDOM.DOMElement;
    l_node XMLDOM.DOMNode;
    l_empty varchar2(15) := ' ';  -- Placeholder for empty content
BEGIN
    -- Initialize XML if needed
    if (XMLDOM.isNull(g_hidden_xml) ) then
        g_hidden_xml := XMLDOM.newDOMDocument;
    end if;

    -- Determine parent node
    if ( not XMLDOM.isNull(p_parent_node) ) then
        -- Use specified parent
        l_parent := p_parent_node;
    else
        -- Use root node
        l_parent := XMLDOM.makeNode( XMLDOM.getDocumentElement(g_hidden_xml) );
        if ( XMLDOM.isNull(l_parent) ) then
            -- New node is going to be root node
            l_parent := XMLDOM.makeNode(g_hidden_xml);
        end if;
    end if;

    -- Create the new node
    l_elem := XMLDOM.createElement(g_hidden_xml, p_tag_name);
    l_node := XMLDOM.appendChild(l_parent, XMLDOM.makeNode( l_elem ) );

    -- Add text if needed
    if (p_tag_type = 'TEXT') then
        l_node := XMLDOM.appendChild( l_node,
            XMLDOM.makeNode( XMLDOM.createTextNode(g_hidden_xml, nvl(p_tag_text, l_empty) ) )
        );
    elsif (p_tag_type = 'CDATA') then
        l_node := XMLDOM.appendChild( l_node,
            XMLDOM.makeNode( XMLDOM.createCDATASection(g_hidden_xml, nvl(p_tag_text, l_empty) ) )
        );
    end if;

    -- Add attributes if needed
    if p_attr_list is not null then
        for i in 1..p_attr_list.count loop
            if (p_attr_list(i) is not null) then
                XMLDOM.setAttribute(l_elem, p_attr_list(i), p_val_list(i) );
            end if;
        end loop;
    end if;

    -- Return the new node
    return l_node;
EXCEPTION
    when others then
        print_log('Error in append_hidden_xml: '||SQLERRM);
        raise;
END append_hidden_xml;
-- Overload: Create XML node with one or zero attributes and return it
FUNCTION append_hidden_xml(
    p_parent_node XMLDOM.DOMNode,
    p_tag_name varchar2,
    p_tag_type varchar2 default null,
    p_tag_text varchar2 default null,
    p_attr varchar2 default null,
    p_val varchar2 default null
) RETURN XMLDOM.DOMNode IS
BEGIN
    return append_hidden_xml(p_parent_node, p_tag_name, p_tag_type, p_tag_text, varchar_tbl(p_attr), varchar_tbl(p_val) );
END append_hidden_xml;

-- EBSAF-177 Add performance details for all processed signatures
PROCEDURE generate_stats_xml IS
    l_stat_id varchar2(320);
    l_sig_id varchar2(320);
    l_parent_sig_id varchar2(320);
    l_attr_list varchar_tbl := varchar_tbl();
    l_val_list varchar_tbl := varchar_tbl();
    l_sig_rec sig_stats_rec;
    l_perf_node XMLDOM.DOMNode;
    l_sig_node XMLDOM.DOMNode;
    l_discard_node XMLDOM.DOMNode;
BEGIN
    -- Skip if previous DX error
    if g_dx_summary_error is not null then
        return;
    end if;

    -- Get details
    l_perf_node := append_hidden_xml(
        p_parent_node => null,
        p_tag_name => 'performance',
        p_attr => 'analyzer_time',
        p_val => trim(to_char(seconds_elapsed(g_analyzer_elapsed),'999999999999.000') ) );

    -- Get details for all signatures
    l_attr_list.extend(2);
    l_val_list.extend(2);
    l_stat_id := g_sig_stats.first;
    while l_stat_id is not null loop
        l_sig_rec := g_sig_stats(l_stat_id);
        l_sig_id := regexp_replace(l_stat_id, '(.*)[|](.*)', '\1');
        l_parent_sig_id := regexp_replace(l_stat_id, '(.*)[|](.*)', '\2');

        l_attr_list(1) := 'id';
        l_val_list(1)  := l_sig_id;
        if l_parent_sig_id is null then
            l_attr_list(2) := null;
            l_val_list(2)  := null;
        else
            l_attr_list(2) := 'parent_id';
            l_val_list(2)  := l_parent_sig_id;
        end if;

        l_sig_node := append_hidden_xml(
            p_parent_node => l_perf_node,
            p_tag_name => 'signature',
            p_attr_list => l_attr_list,
            p_val_list => l_val_list );
        l_discard_node := append_hidden_xml(
            p_parent_node => l_sig_node,
            p_tag_name => 'sig_version',
            p_tag_type => 'TEXT',
            p_tag_text => l_sig_rec.version );
        l_discard_node := append_hidden_xml(
            p_parent_node => l_sig_node,
            p_tag_name => 'sig_query_time',
            p_tag_type => 'TEXT',
            p_tag_text => trim(to_char(l_sig_rec.query_time, '999999999999.000') ) );
        l_discard_node := append_hidden_xml(
            p_parent_node => l_sig_node,
            p_tag_name => 'sig_process_time',
            p_tag_type => 'TEXT',
            p_tag_text => trim(to_char(l_sig_rec.process_time, '999999999999.000') ) );
        l_discard_node := append_hidden_xml(
            p_parent_node => l_sig_node,
            p_tag_name => 'sig_row_count',
            p_tag_type => 'TEXT',
            p_tag_text => l_sig_rec.row_count );

        l_stat_id := g_sig_stats.next(l_stat_id);
    end loop;
EXCEPTION
    WHEN OTHERS THEN
        -- Performance details are non-essential
        print_log('Error in generate_stats_xml: '||SQLERRM);
END generate_stats_xml;

PROCEDURE generate_hidden_xml(
  p_sig_id          VARCHAR2,
  p_sig             SIGNATURE_REC, -- Name of signature item
  p_col_rows        COL_LIST_TBL,  -- signature SQL row values
  p_col_headings    VARCHAR_TBL,   -- signature SQL column names
  p_fail_col        NUMBER,         -- Custom fail column ID
  p_fail_flags      VARCHAR_TBL,    -- Rows failed
  p_mask_opts       VARCHAR_TBL,    -- Column masking options
  p_parent_sig_id   VARCHAR2 DEFAULT NULL) -- we need this flag to establish if this is a child sig
IS

l_hidden_xml_doc       XMLDOM.DOMDocument;
l_hidden_xml_node      XMLDOM.DOMNode;
l_diagnostic_element   XMLDOM.DOMElement;
l_diagnostic_node      XMLDOM.DOMNode;
l_issues_node          XMLDOM.DOMNode;
l_signature_node       XMLDOM.DOMNode;
l_signature_element    XMLDOM.DOMElement;
l_node                 XMLDOM.DOMNode;
l_row_node             XMLDOM.DOMNode;
l_failure_node         XMLDOM.DOMNode;
l_run_details_node     XMLDOM.DOMNode;
l_run_detail_data_node XMLDOM.DOMNode;
l_detail_element       XMLDOM.DOMElement;
l_detail_node          XMLDOM.DOMNode;
l_detail_name_attribute XMLDOM.DOMAttr;
l_parameters_node      XMLDOM.DOMNode;
l_parameter_node       XMLDOM.DOMNode;
l_col_node             XMLDOM.DOMNode;
l_parameter_element    XMLDOM.DOMElement;
l_col_element          XMLDOM.DOMElement;
l_param_name_attribute XMLDOM.DOMAttr;
l_failure_element      XMLDOM.DOMElement;
l_sig_id_attribute     XMLDOM.DOMAttr;
l_col_name_attribute   XMLDOM.DOMAttr;
l_row_attribute        XMLDOM.DOMAttr;
l_sigxinfo_element     XMLDOM.DOMElement;
l_sigxinfo_node        XMLDOM.DOMNode;
l_xinfo_element        XMLDOM.DOMElement;
l_xinfo_node           XMLDOM.DOMNode;
l_xinfo_name_attr      XMLDOM.DOMAttr;
l_key                  VARCHAR2(255);
l_match                VARCHAR2(1);
l_rows                 NUMBER;
l_value                VARCHAR2(4000);
l_cmp_val              VARCHAR2(4000);
l_start_flag           BOOLEAN := FALSE;
l_is_sig_empty         BOOLEAN := TRUE;
l_step                 VARCHAR2(3) := '0';

BEGIN
l_step := '10';

IF g_dx_summary_error IS NOT NULL THEN
   return;
END IF;

l_hidden_xml_doc := g_hidden_xml;

l_step := '20';

IF (XMLDOM.isNULL(l_hidden_xml_doc)) THEN
   l_hidden_xml_doc := XMLDOM.newDOMDocument;
   l_hidden_xml_node := XMLDOM.makeNode(l_hidden_xml_doc);
   l_diagnostic_node := XMLDOM.appendChild(l_hidden_xml_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'diagnostic')));

   l_run_details_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'run_details')));
   l_key := g_rep_info.first;
   l_step := '30';
   WHILE l_key IS NOT NULL LOOP

     l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
     l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
     l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
     XMLDOM.setAttribute(l_detail_element, 'name', l_key);

     BEGIN
        IF g_rep_info(l_key) IS NOT NULL THEN
           -- EBSAF-294 Strip HTML formatting from the detail data
           l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc, plain_text( g_rep_info(l_key)) )));
        -- EBSAF-215 (avoid empty, self-closing xml tags)
        ELSE
           l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'')));
        END IF;
      --EBSAF-239
      EXCEPTION
        WHEN OTHERS THEN
           l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,' ')));
     END;
     l_key := g_rep_info.next(l_key);

   END LOOP;
   -- add cloud check

   l_step := '40';
   l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
   l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
   l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
   XMLDOM.setAttribute(l_detail_element, 'name', 'Cloud');
   IF g_cloud_flag THEN
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'Y')));
   ELSE
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'N')));
   END IF;

   -- EBSAF-272
   l_step := '45';
   l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
   l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
   l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
   XMLDOM.setAttribute(l_detail_element, 'name', 'g2g');
   IF g_g2g_flag THEN
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'C')));
   ELSE
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'R')));
   END IF;

   l_step := '48';
   l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
   l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
   l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
   XMLDOM.setAttribute(l_detail_element, 'name', 'GUID');
   l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,g_guid)));

   l_step := '50';
   l_parameters_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'parameters')));
   FOR i IN 1..g_parameters.COUNT LOOP
     l_parameter_element := XMLDOM.createElement(l_hidden_xml_doc,'parameter');
     l_parameter_node := XMLDOM.appendChild(l_parameters_node,XMLDOM.makeNode(l_parameter_element));
     l_param_name_attribute:=XMLDOM.setAttributeNode(l_parameter_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
     XMLDOM.setAttribute(l_parameter_element, 'name', to_char(i) || '. ' ||g_parameters(i).pname);
     BEGIN
         IF g_parameters(i).pvalue IS NOT NULL THEN
            l_node := XMLDOM.appendChild(l_parameter_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,g_parameters(i).pvalue)));
         -- EBSAF-215 (avoid empty, self-closing xml tags)
         ELSE
            l_node := XMLDOM.appendChild(l_parameter_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'')));
         END IF;
     --EBSAF-239
     EXCEPTION
         WHEN OTHERS THEN
            l_node := XMLDOM.appendChild(l_parameter_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,' ')));
     END;
   END LOOP;
   l_step := '60';

   l_issues_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'issues')));

END IF;

 l_step := '70';

 IF p_sig_id IS NOT NULL THEN

   IF (p_parent_sig_id IS NOT NULL) AND (p_sig.include_in_xml='P') THEN
   -- EBSAF-218 -- replace g_dx_printed(p_parent_sig_id) with g_dx_printed(p_sig_id)
       IF ((g_dx_printed.EXISTS(p_sig_id)) AND (nvl(g_dx_printed(p_sig_id), 0) = 1)) THEN  -- if this is a child, has P flag and has been printed before, return
           RETURN;
       ELSE
           g_dx_printed(p_sig_id) := 1;
       END IF;
   END IF;

   g_issues_count := g_issues_count + 1;
   l_issues_node := XMLDOM.getLastChild(XMLDOM.getFirstChild(XMLDOM.makeNode(l_hidden_xml_doc)));

   l_signature_element := XMLDOM.createElement(l_hidden_xml_doc,'signature');
   l_sig_id_attribute := XMLDOM.setAttributeNode(l_signature_element,XMLDOM.createAttribute(l_hidden_xml_doc,'id'));
   l_signature_node := XMLDOM.appendChild(l_issues_node,XMLDOM.makeNode(l_signature_element));
   XMLDOM.setAttribute(l_signature_element, 'id',p_sig_id);

   l_step := '80';
   -- print the extra info, but only if it's not internally used (starts with ##)
   IF p_sig.extra_info.count > 0 THEN
    l_key := p_sig.extra_info.first;
    WHILE l_key IS NOT NULL LOOP
      IF regexp_like(l_key,'^##') THEN
          GOTO go_next;
      ELSE
          IF (NOT l_start_flag) THEN
              l_sigxinfo_element := XMLDOM.createElement(l_hidden_xml_doc,'sigxinfo');
              l_sigxinfo_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(l_sigxinfo_element));
              l_start_flag := TRUE;
              l_is_sig_empty := FALSE;
          END IF;
          l_xinfo_element := XMLDOM.createElement(l_hidden_xml_doc,'info');
          l_xinfo_node := XMLDOM.appendChild(l_sigxinfo_node,XMLDOM.makeNode(l_xinfo_element));
          l_xinfo_name_attr := XMLDOM.setAttributeNode(l_xinfo_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
          XMLDOM.setAttribute(l_xinfo_element, 'name',l_key);
       IF p_sig.extra_info(l_key) IS NOT NULL THEN
          l_node := XMLDOM.appendChild(l_xinfo_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,p_sig.extra_info(l_key))));
       END IF;
      END IF;
      <<go_next>>
      l_key := p_sig.extra_info.next(l_key);
    END LOOP;
   END IF;

   l_step := '90';
   -- if the DX flag is Y or D, print all the details
   IF (p_sig.include_in_xml in ('Y', 'D')) THEN

      IF p_sig.limit_rows='Y' THEN
         l_rows := least(g_max_output_rows,p_col_rows(1).COUNT,50);
      ELSE
         l_rows := least(p_col_rows(1).COUNT,50);
      END IF;

      IF ((l_rows >= 0) AND (l_is_sig_empty)) THEN
           l_is_sig_empty := FALSE;
      END IF;

   -- EBSAF-216 (print only faling rows for complex conditions)
      IF (p_sig.fail_condition NOT IN ('RSGT1','RS','NRS') AND (g_rec_patch_in_dx = 'F')) THEN
--           DECLARE
--                 l_column            VARCHAR2(255) := null;
--                 l_curr_col          VARCHAR2(255);
--                 l_curr_val          VARCHAR2(4000);
--                 l_operand           VARCHAR2(255);
--                 l_row_fail          BOOLEAN := false;
--                 l_cmp_val_set       varchar_tbl;
          BEGIN
--              l_column := upper(substr(ltrim(p_sig.fail_condition),2,instr(p_sig.fail_condition,']') - 2));
--              l_operand := rtrim(ltrim(substr(p_sig.fail_condition, instr(p_sig.fail_condition,']')+1,
--                (instr(p_sig.fail_condition,'[',1,2)-instr(p_sig.fail_condition,']') - 1))));
--              l_cmp_val := substr(p_sig.fail_condition, instr(p_sig.fail_condition,'[',2)+1,
--                (instr(p_sig.fail_condition,']',1,2)-instr(p_sig.fail_condition,'[',1,2)-1));
--              l_cmp_val_set := split_text(l_cmp_val);
             FOR i IN 1..l_rows LOOP
--                 l_row_fail := false;
--                 FOR j IN 1..p_col_headings.count LOOP
--                     l_curr_col := upper(p_col_headings(j));
--                     l_curr_val := p_col_rows(j)(i);
--                     IF nvl(l_column,'&&&') = l_curr_col THEN
--                         l_row_fail := evaluate_rowcol(l_operand, l_cmp_val, l_curr_val, l_cmp_val_set);
--                     END IF;
--                 END LOOP;
--                 IF (l_row_fail) THEN
                -- Use cached fail status
                IF (p_fail_col > 0 and p_fail_flags(i) = 'Y') THEN
                    l_failure_element := XMLDOM.createElement(l_hidden_xml_doc,'failure');
                    l_row_attribute := XMLDOM.setAttributeNode(l_failure_element,XMLDOM.createAttribute(l_hidden_xml_doc,'row'));
                    l_failure_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(l_failure_element));
                    XMLDOM.setAttribute(l_failure_element, 'row', i);

                    -- Data column headings
                    FOR j IN 1..p_col_headings.count LOOP

                        if (p_mask_opts(j) <> 'REMOVE_COLUMN') then -- EBSAF-269

                           l_col_element := XMLDOM.createElement(l_hidden_xml_doc,'column');
                           l_col_name_attribute := XMLDOM.setAttributeNode(l_col_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
                           l_col_node := XMLDOM.appendChild(l_failure_node,XMLDOM.makeNode(l_col_element));
                           XMLDOM.setAttribute(l_col_element, 'name', filter_html(p_col_headings(j),'I','D') );

                       /*
                           BEGIN
                               BEGIN
                                   l_value := p_col_rows(j)(i);
                               END;
                            EXCEPTION -- there might be an exception when the value is too big
                              WHEN VALUE_ERROR THEN
                                   l_value := substr(p_col_rows(j)(i), 1, 4000);
                           END;
                       */
                       -- Delete invalid characters from value (EBSAF-263) and remove links (EBSAF-233)
                       l_value := substr(remove_links(filter_html(p_col_rows(j)(i),'I','D')), 1, 4000);

                           /* EBSAF-255 g_preserve_trailing_blanks functionality is obsolete
                           -- Rtrim the column value if blanks are not to be preserved
                           IF NOT g_preserve_trailing_blanks THEN
                              l_value := RTRIM(l_value, ' ');
                           END IF;
                           */
                           BEGIN
                               IF l_value IS NOT NULL THEN
                                  l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,l_value)));
                               -- EBSAF-215 (avoid empty self-closing nodes)
                               ELSE
                                  l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'')));
                               END IF;
                           --EBSAF-239
                           EXCEPTION
                               WHEN OTHERS THEN
                                  l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,' ')));
                           END;
                        end if;
                     END LOOP;
                 END IF;
             END LOOP;
         END;
     ELSE
     l_step := '95';

      -- Data column rows
      FOR i IN 1..l_rows LOOP

         l_failure_element := XMLDOM.createElement(l_hidden_xml_doc,'failure');
         l_row_attribute := XMLDOM.setAttributeNode(l_failure_element,XMLDOM.createAttribute(l_hidden_xml_doc,'row'));
         l_failure_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(l_failure_element));
         XMLDOM.setAttribute(l_failure_element, 'row', i);

         -- Data column values
         FOR j IN 1..p_col_headings.count LOOP

            if (p_mask_opts(j) <> 'REMOVE_COLUMN') then -- EBSAF-269

                l_col_element := XMLDOM.createElement(l_hidden_xml_doc,'column');
                l_col_name_attribute := XMLDOM.setAttributeNode(l_col_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
                l_col_node := XMLDOM.appendChild(l_failure_node,XMLDOM.makeNode(l_col_element));
                XMLDOM.setAttribute(l_col_element, 'name', filter_html(p_col_headings(j),'I','D') );

            /*
                BEGIN
                    BEGIN
                        l_value := p_col_rows(j)(i);
                    END;
                 EXCEPTION -- there might be an exception when the value is too big
                   WHEN VALUE_ERROR THEN
                        l_value := substr(p_col_rows(j)(i), 1, 4000);
                END;
            */
            -- Delete invalid characters from value (EBSAF-263) and remove links (EBSAF-233)
            l_value := substr(remove_links(filter_html(p_col_rows(j)(i),'I','D')), 1, 4000);


    /* CG can be removed, no longer working
                IF p_sig_id = 'REC_PATCH_CHECK' THEN
                   IF p_col_headings(j) = 'Patch' THEN
                      l_value := replace(replace(p_col_rows(j)(i),'{'),'}');
                   ELSIF p_col_headings(j) = 'Note' THEN
                      l_value := replace(replace(p_col_rows(j)(i),'['),']');
                   END IF;
                END IF;
    */
                -- EBSAF-269
                l_value := mask_text(l_value, p_mask_opts(j) );
                /* EBSAF-255 g_preserve_trailing_blanks functionality is obsolete
                if (p_mask_opts(j) = 'NO_MASK') then
                    -- Rtrim the column value if blanks are not to be preserved
                    IF NOT g_preserve_trailing_blanks THEN
                       l_value := RTRIM(l_value, ' ');
                    END IF;
                end if;
                */

                BEGIN
                    -- Table data stored in CDATA sections instead of text nodes (EBSAF-278)
                    -- Reverted back from createCDATASection to createTextNode (EBSAF-284)
                    IF l_value IS NOT NULL THEN
                      l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,l_value)));
                   -- EBSAF-215 (avoid empty self-closing nodes)
                    ELSE
                      l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'')));
                   END IF;
                --EBSAF-239
                EXCEPTION
                   WHEN OTHERS THEN
                      l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,' ')));
                END;
            end if;
          END LOOP;

       END LOOP;
      END IF;
     END IF;  --p_sig.include_in_xml='Y'
    l_step := '100';

     BEGIN
        -- EBSAF-215 and EBSAF-237
        IF ((l_is_sig_empty) AND (NOT XMLDOM.isNULL(l_signature_node))) THEN
           l_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'')));
        END IF;
      --EBSAF-239
     EXCEPTION
        WHEN OTHERS THEN
           l_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,' ')));
     END;

  END IF;

  g_hidden_xml := l_hidden_xml_doc;

EXCEPTION
   WHEN OTHERS THEN
      -- EBSAF-237
      IF (p_sig_id IS NOT NULL) THEN
          g_dx_summary_error := '<DXSUMMGENERR><![CDATA[Error at step '||l_step||' for sig id '||p_sig_id||': '||SQLERRM||chr(10)||'Exception stack: '||chr(10);
          g_dx_summary_error := g_dx_summary_error || SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 3500);
          g_dx_summary_error := g_dx_summary_error || ']]></DXSUMMGENERR>';
      ELSE
          g_dx_summary_error := '<DXSUMMGENERR><![CDATA[Error at step '||l_step||': '||SQLERRM||chr(10)||'Exception stack: '||chr(10);
          g_dx_summary_error := g_dx_summary_error || SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 3500);
          g_dx_summary_error := g_dx_summary_error || ']]></DXSUMMGENERR>';
      END IF;
      print_log('DX Summary generation error: '||SQLERRM);

END generate_hidden_xml;


PROCEDURE print_hidden_xml
IS
    l_hidden_xml_clob   clob;
    l_issues_nodes      XMLDOM.DOMNodeList;
    l_issues_node       XMLDOM.DOMNode;
    l_node              XMLDOM.DOMNode;
BEGIN

    IF g_dx_summary_error IS NOT NULL THEN
        print_out('<script id="dx-summary" type="application/xml">','Y');
        print_out('<!-- ######BEGIN DX SUMMARY######-->','Y');
        print_out(g_dx_summary_error);
        print_out('<!-- ######END DX SUMMARY######-->','Y');
        print_out('</script>','Y');
        print_out('<div style="display:none;" id="integrityCheck"></div>'); -- this is for integrity check
        g_dx_summary_error:=null;
        return;
    END IF;

    IF XMLDOM.isNULL(g_hidden_xml) THEN
        generate_hidden_xml(p_sig_id => null,
                       p_sig => null,
                       p_col_headings => null,
                       p_col_rows => null,
                       p_fail_col => null,
                       p_mask_opts => null,
                       p_fail_flags => null);

    END IF;

    -- EBSAF-177 Add performance stats to DX summary
    generate_stats_xml;

    /* Replaced by EBSAF-264
    -- EBSAF-215 (avoid empty self-closing nodes)
    IF (g_issues_count = 0) THEN
        l_issues_nodes := XMLDOM.getElementsByTagName(g_hidden_xml,'issues');
        -- EBSAF-237
        IF NOT XMLDOM.isNULL(l_issues_nodes) THEN
            BEGIN
                l_issues_node := XMLDOM.item(l_issues_nodes, 0);
                l_node := XMLDOM.appendChild(l_issues_node,XMLDOM.makeNode(XMLDOM.createTextNode(g_hidden_xml,'')));
            --EBSAF-239
            EXCEPTION
                WHEN OTHERS THEN
                    l_node := XMLDOM.appendChild(l_issues_node,XMLDOM.makeNode(XMLDOM.createTextNode(g_hidden_xml,' ')));
            END;
        END IF;
    END IF;
    */

    dbms_lob.createtemporary(l_hidden_xml_clob, true);

    --print CLOB
    XMLDOM.WRITETOCLOB(g_hidden_xml, l_hidden_xml_clob);
    -- EBSAF-264 - Locate self-closing tags and create matching closing tag
    -- \1 is actual tag
    -- \2 is tag attributes
    l_hidden_xml_clob := regexp_replace(l_hidden_xml_clob, '<(\w+)([^>]*)/>', '<\1\2> </\1>');

    print_out('<script id="dx-summary" type="application/xml">','Y');
    print_out('<!-- ######BEGIN DX SUMMARY######-->','Y');
    print_clob(l_hidden_xml_clob);
    print_out('<!-- ######END DX SUMMARY######-->','Y');
    print_out('</script>','Y');
    print_out('<div style="display:none;" id="integrityCheck"></div>'); -- this is for integrity check

    dbms_lob.freeTemporary(l_hidden_xml_clob);
    XMLDOM.FREEDOCUMENT(g_hidden_xml);

EXCEPTION
   WHEN OTHERS THEN
      print_log('Error in print_hidden_xml: '||SQLERRM);
END print_hidden_xml;


procedure print_sig_exceptions
is
    l_sig_id varchar2(255);
begin
    if (g_sig_errors.count > 0) then
        print_log('Signatures where exception occurred:');
        l_sig_id := g_sig_errors.first;
        while l_sig_id is not null loop
            print_log('- ' || l_sig_id);
            l_sig_id := g_sig_errors.next(l_sig_id);
        end loop;
    end if;
exception
   when others then
      print_log('Error in print_sig_exceptions: '||sqlerrm);
end print_sig_exceptions;


----------------------------------------------------------------
-- Get the cell formatting options from the Sig Repo          --
-- and tranform it into CSS style                             --
----------------------------------------------------------------
FUNCTION get_style(p_style_string VARCHAR2) RETURN VARCHAR2
IS
   l_formatted_style     VARCHAR2(1024) := '';
   l_styles              resultType;
   l_key                 VARCHAR2(32);
   l_count               NUMBER := 0;
BEGIN
   IF (p_style_string is null) THEN
       print_log ('Formatting string is empty');
       return '';
   END IF;

   BEGIN
       l_styles('text-align') := substr(p_style_string, 1, instr(p_style_string, ',', 1, 1) - 1);
       l_styles('color') := substr(p_style_string, instr(p_style_string, ',', 1, 1) + 1, instr(p_style_string, ',', 1, 2) - instr(p_style_string, ',', 1, 1) - 1);
       l_styles('background-color') := substr(p_style_string, instr(p_style_string, ',', 1, 2) + 1, instr(p_style_string, ',', 1, 3) - instr(p_style_string, ',', 1, 2) - 1);
       l_styles('font-weight') := substr(p_style_string, instr(p_style_string, ',', 1, 3) + 1);
   EXCEPTION
      WHEN OTHERS THEN
          print_log('Error in get_style extracting the format details: '|| sqlerrm);
          return '';
   END;

    l_key := l_styles.first;
    l_formatted_style := 'style="';

    WHILE ((l_key IS NOT NULL) AND (l_styles.EXISTS(l_key))) LOOP
        IF (l_styles(l_key) IS NOT NULL) THEN
            l_formatted_style := l_formatted_style || l_key || ':' || l_styles(l_key) || ';';
            l_count := l_count + 1;
        END IF;
    l_key := l_styles.next(l_key);
    END LOOP;

    l_formatted_style := l_formatted_style || '"';

    IF (l_count = 0) THEN   -- if all styles have been empty, return empty string
        return '';
    END IF;
    return l_formatted_style;
EXCEPTION
   WHEN OTHERS THEN
   print_log('Error in get_style formatting the column: ' || sqlerrm);
   return '';
END get_style;


------------------------------------------------------------------
-- Get the mask option for a specified column (EBSAF-269)       --
------------------------------------------------------------------
FUNCTION get_mask_option(p_col_num number,
    p_col_name varchar2,
    p_extra_info HASH_TBL_4K) return varchar2
IS
    l_default varchar2(255) := 'NO_MASK';
    l_col_key varchar2(255);
    l_opt_key varchar2(255);
BEGIN
    if p_extra_info.exists('##MASK##' || p_col_num) then
        -- Check by column number
        return nvl(upper(trim(p_extra_info('##MASK##' || p_col_num))), l_default);
    elsif p_extra_info.exists('##MASK##' || p_col_name) then
        -- Check by exact column name
        return nvl(upper(trim(p_extra_info('##MASK##' || p_col_name))), l_default);
    else
        -- Check by wildcard column name
        l_col_key := '##MASK##' || p_col_name;
        l_opt_key := p_extra_info.first;
        while (l_opt_key is not null) loop
            if (l_col_key like l_opt_key) then
                return nvl(upper(trim(p_extra_info(l_opt_key))), l_default);
            end if;
            l_opt_key := p_extra_info.next(l_opt_key);
        end loop;

        -- Return default
        return l_default;
    end if;
EXCEPTION
    WHEN OTHERS THEN
        print_log('Error in get_mask_option('||p_col_num||','||p_col_name||'): ' || sqlerrm);
        print_log('Using default option: ' || l_default);
        return l_default;
END get_mask_option;


------------------------------------------------------------------
-- For signatures that have print condition set to failure      --
-- and are successful, print partial details on a separate page --
------------------------------------------------------------------
PROCEDURE get_sig_partial(
    p_sig_html  IN OUT NOCOPY CLOB,
    p_sig_id    VARCHAR2,
    p_level NUMBER default null,
    p_class_string VARCHAR2 default null,
    p_error_msg VARCHAR2 default null
) IS
    l_sig           SIGNATURE_REC;
    l_level         NUMBER;
    l_result        VARCHAR2(1);
    l_views         VARCHAR2(255);
    l_current_sig   VARCHAR2(6);
    l_step          VARCHAR(260);
    l_html          VARCHAR2(32767);
    l_i             VARCHAR2(255);
BEGIN
    -- Get sig details
    l_step := '10';
    if (g_signatures.exists(p_sig_id)) then
        l_sig := g_signatures(p_sig_id);
        l_level := nvl(p_level, 1);
        if (p_error_msg is null) then
            l_result := 'P';
            l_views := null;
        else
            l_result := 'X';
            l_views := 'section print analysis';
            g_sig_errors(p_sig_id) := expand_html(l_sig.title);
        end if;
    else
        -- No signature details so nothing to print
        print_log('Error: No details for signature ID ' || p_sig_id);
        raise NO_DATA_FOUND;
    end if;

    -- Clear buffer if needed
    if (p_sig_html is not null) then
        dbms_lob.trim(p_sig_html, 0);
    end if;

    -- Open signature container
    l_step := '20';
    g_sig_count := g_sig_count + 1;
    l_current_sig := 'S'||to_char(g_sig_count);  --build signature class name
    l_html := '
<!-- '||l_current_sig||' -->
               <div class="data sigcontainer signature '||p_class_string||' '||l_current_sig||' '||l_result||' '||l_views||'" sig="'||p_sig_id||'" level="'||l_level||'"  id="'||l_current_sig||'" style="display: none;">
                    <div class="divItemTitle">
                        <div class="sigdescription" style="display:inline;"><table style="display:inline;"><tr class="'||l_current_sig||' '||l_result||' sigtitle"><td class="divItemTitlet">'||expand_html(l_sig.title)||'</td></tr></table></div>';
    -- Show info icon only if needed
    if (l_sig.extra_info.count > 0 OR l_sig.sig_sql is not null) then
        l_html := l_html || '
                        <a class="detailsmall" toggle-info="tbitm_'||l_current_sig||'"><span class="siginfo_ico" title="Show signature information" alt="Show Info"></span></a>';
    end if;
    -- Show copy SQL icon only if needed (SHOW_SQL != 'N' and the SQL string is not null)
    IF ((l_sig.sig_sql is not null) AND ((NOT l_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (l_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(l_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
        l_html := l_html || '
                        <a class="detailsmall" href="javascript:;" onclick=''copySql("sql_'||l_current_sig||'")''><span class="copysql_ico" title="Copy SQL query to clipboard" alt="Copy SQL"></span></a>';
    end if;
    l_html := l_html || '
                    </div>';

    print_buffer(p_sig_html, l_html);
    l_html := null;

    -- Print collapsable/expandable extra info table if there are contents
    l_step := '30';
    IF l_sig.extra_info.count > 0 OR l_sig.sig_sql is not null THEN
        l_step := '40';
        l_html := '
                        <table class="table1 data" id="tbitm_' || l_current_sig || '" style="display:none">
                        <thead>
                           <tr><th bgcolor="#f2f4f7" class="sigdetails">Item Name</th><th bgcolor="#f2f4f7" class="sigdetails">Item Value</th></tr>
                        </thead>
                        <tbody>';
        print_buffer(p_sig_html, l_html);
        l_html := null;
        -- Loop and print values
        l_step := '50';
        l_i := l_sig.extra_info.FIRST;
        WHILE (l_i IS NOT NULL) LOOP
          l_step := '60.'||l_i;
          -- don't print the extra info that starts with ## (these are hidden)
          IF (NOT regexp_like(l_i,'^##')) THEN
               -- if extra info includes keys like #IMPACT_AREAS#, change the display name to IMpact Areas (title case)
              IF (regexp_like(l_i,'^#[0-9a-zA-Z]')) THEN
                  l_html := l_html || '                           <tr><td>' || word_to_titlecase(l_i) || '</td><td>'||
                      l_sig.extra_info(l_i) || '</td></tr>';
              ELSE
                  l_html := l_html || '                           <tr><td>' || l_i || '</td><td>'||
                     l_sig.extra_info(l_i) || '</td></tr>';
              END IF;
          END IF;

          l_step := '60.'||l_i;
          l_i := l_sig.extra_info.next(l_i);
        END LOOP;
        print_buffer(p_sig_html, l_html);
        l_html := null;
        l_step := '65';
        -- print SQL only if SHOW_SQL != 'N' and the SQL string is not null
        IF ((l_sig.sig_sql is not null) AND ((NOT l_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (l_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(l_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
            l_step := '70';
            l_html := l_html || '
                              <tr><td>SQL</td><td id="sql_'||l_current_sig||'"><pre>'||prepare_SQL(l_sig.sig_sql)||'</pre></td></tr>';
        END IF;
        if (l_sig.version is not null) then
            l_html := l_html ||'
                              <tr><td>Version:</td><td>'||l_sig.version||'</td></tr>';
        end if;
        IF (l_result = 'P') THEN
            l_html := l_html || '
                              <tr><td>Elapsed time:</td><td>'||format_elapsed(g_query_elapsed)||'</td></tr>';
        END IF;
        l_html := l_html || '
                        </tbody>
                        </table>';
    END IF;
    print_buffer(p_sig_html, l_html);
    l_html := null;

    -- Show error message
    l_step := '80';
    if (l_result = 'X') then
        print_buffer(p_sig_html, p_error_msg);
    end if;

    -- Show success message
    l_step := '90';
    IF (l_result = 'P' and l_sig.success_msg is not null) THEN
        l_html := '
               <div class="divok data P"><div class="divok1"><span class="check_ico"></span> All checks passed.</div>' ||
            expand_html(l_sig.success_msg, p_sig_id) || '</div> <!-- end results div -->';
    END IF;

    -- Close signature container
    l_step := '100';
    l_html := l_html || '
               </div>  <!-- end of sig container -->
<!-- '||l_current_sig||'-->';
    print_buffer(p_sig_html, l_html);
EXCEPTION WHEN OTHERS THEN
    print_log('Error in get_sig_partial at step ' || l_step);
    print_log('Error: ' || sqlerrm);
    p_sig_html := null;
END get_sig_partial;


----------------------------------------------------------------
-- Once a signature has been run, evaluates and prints it     --
----------------------------------------------------------------
FUNCTION process_signature_results(
  p_sig_id          VARCHAR2,      -- signature id
  p_sig             SIGNATURE_REC, -- Name of signature item
  p_col_rows        COL_LIST_TBL,  -- signature SQL row values
  p_col_headings    VARCHAR_TBL,    -- signature SQL column names
  p_parent_id       VARCHAR2    DEFAULT NULL,
  p_sig_suffix      VARCHAR2    DEFAULT NULL,
  p_class_string    VARCHAR2    DEFAULT NULL,
  p_parent_sig_id   VARCHAR2    DEFAULT NULL -- Needed for performance tracking (EBSAF-177)
) RETURN VARCHAR2 IS             -- returns 'E','W','S','I'

  l_sig_fail      BOOLEAN := false;
  l_row_fail      BOOLEAN := false;
  l_fail_flag     BOOLEAN := false;
  l_html          VARCHAR2(32767) := null;
  l_cell_text     VARCHAR2(4200);
  l_column        VARCHAR2(255) := null;
  l_operand       VARCHAR2(255);
  l_value         VARCHAR2(4000);
  l_step          VARCHAR2(255);
  l_i             VARCHAR2(255);
  l_curr_col      VARCHAR2(255) := NULL;
  l_curr_val      VARCHAR2(4000) := NULL;
  l_value_set     varchar_tbl;
  l_fail_pattern  VARCHAR2(255);
  l_fail_text     VARCHAR2(4000);    -- EBSAF-259
  l_fail_col      number;
  l_fail_flags    varchar_tbl;
  l_print_sql_out BOOLEAN := true;
  l_inv_param     EXCEPTION;
  l_rows_fetched  NUMBER := p_col_rows(1).count;
  l_printing_cols NUMBER := 0;
  l_error_type    VARCHAR2(1);
  l_current_section  VARCHAR2(320);
  l_current_sig      VARCHAR2(320);
  l_sig_suffix       VARCHAR2(100);
  l_class_string     VARCHAR2(1024);
  l_style            VARCHAR2(250);
  l_mask_option     VARCHAR2(255);
  l_mask_opts     varchar_tbl;
  l_removed_cols     VARCHAR2(4000);
  l_masked_cols     VARCHAR2(4000);
  l_hashed_cols     VARCHAR2(4000);
  l_run_result      BOOLEAN;
  l_sig_result      VARCHAR2(1);
  l_tags            VARCHAR2(520) := '';
  l_hidden_data     BOOLEAN := false;
  l_sig_html      CLOB;
  l_process_start_time TIMESTAMP;
  l_process_elapsed INTERVAL DAY(2) TO SECOND(3);
BEGIN
    -- Validate parameters which have fixed values against errors when defining or loading signatures
    IF NOT (
        -- EBSAF-198 Changing fail condition validation to regex for control
        p_sig.fail_condition in ('NRS','RS','RSGT1') -- Standard
        or regexp_like(p_sig.fail_condition, '^\s*\[[^]]+\]\s*(<|<=|=|>|>=|<>|\!=)\s*\[[^]]+\]\s*$') -- Comparisons
        or regexp_like(p_sig.fail_condition, '^\s*\[[^]]+\]\s*(NOT\s+)?(LIKE|IN)\s*\[[^]]+\]\s*$', 'i') -- LIKE or IN
        or regexp_like(p_sig.fail_condition, '^\s*\[[^]]+\]\s*IS\s+(NOT\s+)?NULL\s*$', 'i') -- NULL
    ) THEN
        print_log('Invalid value or format for failure condition: '||p_sig.fail_condition);
        raise l_inv_param;
    ELSIF p_sig.print_condition NOT IN ('SUCCESS','FAILURE','ALWAYS','NEVER') THEN
        print_log('Invalid value for print_condition: '||p_sig.print_condition);
        raise l_inv_param;
    ELSIF p_sig.fail_type NOT IN ('E','W','I') THEN
        print_log('Invalid value for fail_type: '||p_sig.fail_type);
        raise l_inv_param;
    ELSIF p_sig.print_sql_output NOT IN ('Y','N','RS') THEN
        print_log('Invalid value for print_sql_output: '||p_sig.print_sql_output);
        raise l_inv_param;
    ELSIF p_sig.limit_rows NOT IN ('Y','N') THEN
        print_log('Invalid value for limit_rows: '||p_sig.limit_rows);
        raise l_inv_param;
    ELSIF p_sig.print_condition in ('ALWAYS','SUCCESS') AND
            p_sig.success_msg is null AND p_sig.print_sql_output = 'N' THEN
        print_log('Invalid parameter combination.');
        print_log('print_condition/success_msg/print_sql_output: '||
        p_sig.print_condition||'/'||nvl(p_sig.success_msg,'null')||'/'||p_sig.print_sql_output);
        print_log('When printing on success either success msg or SQL output printing should be enabled.');
        raise l_inv_param;
    END IF;

    -- Get signature class names
    g_sig_count := g_sig_count + 1;
    l_current_sig := 'S'||to_char(g_sig_count)||p_sig_suffix; --  Suffix is parent row ID
    l_current_section := replace_chars(g_sec_detail(g_sec_detail.COUNT).name);

    -- Log processing
    sig_time_start(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177
    g_sig_stats(p_sig_id||'|'||p_parent_sig_id).row_count := g_sig_stats(p_sig_id||'|'||p_parent_sig_id).row_count + l_rows_fetched;
    get_current_time(l_process_start_time);
    debug('Process start ['||l_current_sig||']');

    -- Complex signature may not have been registered (EBSAF-221)
    if not g_signatures.exists(p_sig_id) then
        g_signatures(p_sig_id) := p_sig;
    end if;

    l_print_sql_out := (
        nvl(p_sig.print_sql_output,'Y') = 'Y' OR
        (p_sig.print_sql_output = 'RSGT1' AND l_rows_fetched > 1) OR
        (p_sig.print_sql_output = 'RS' AND l_rows_fetched > 0) OR
        (p_sig.child_sigs.count > 0 AND l_rows_fetched > 0)
    );

  -- Determine signature failure status
  l_fail_col := 0;
  l_fail_flags := varchar_tbl();
  IF p_sig.fail_condition NOT IN ('RSGT1','RS','NRS') THEN
    -- Get the column to evaluate, if any
    l_step := '20';

    -- EBSAF-198 Use regex for more control
    l_fail_pattern := '^\s*\[([^]]+)\]\s*([^[]+?)\s*(\[([^]]+)\])?\s*$';
    l_fail_text := expand_sql_tokens(p_sig.fail_condition);  -- EBSAF-259
    l_column := trim(upper(regexp_replace(l_fail_text, l_fail_pattern, '\1')));
    l_operand := trim(upper(regexp_replace(l_fail_text, l_fail_pattern, '\2')));
    l_value := trim(regexp_replace(l_fail_text, l_fail_pattern, '\4'));
    l_value_set := split_text(l_value);
    l_fail_flags.extend(l_rows_fetched);


    l_step := '30';
    -- Process to cache the fail status of each row
    FOR j in 1..p_col_headings.count LOOP
        l_step := '40 col ' || j || ' of ' || p_col_headings.count;
        IF l_column = upper(p_col_headings(j)) THEN
            l_fail_col := j;
            FOR i in 1..l_rows_fetched LOOP
                l_step := '40 col ' || j || ' row ' || i || ' of ' || l_rows_fetched;
                l_curr_val := p_col_rows(j)(i);
                l_row_fail := evaluate_rowcol(l_operand, l_value, l_curr_val, l_value_set);
                IF l_row_fail THEN
                    l_fail_flag := true;
                    l_fail_flags(i) := 'Y';
                ELSE
                    l_fail_flags(i) := 'N';
                END IF;
            END LOOP;
        END IF;
    END LOOP;
  END IF;

    -- Process to cache the mask option of each column (EBSAF-269)
    l_printing_cols := 0;
    l_mask_opts := varchar_tbl();
    l_mask_opts.extend(p_col_headings.count);
    FOR j in 1..p_col_headings.count LOOP
        l_step := '45 col ' || j || ' of ' || p_col_headings.count;
        l_curr_col := upper(p_col_headings(j));
        if l_curr_col not like '##$$FK_$$##' then
            l_mask_opts(j) := get_mask_option(j, l_curr_col, p_sig.extra_info);
            if l_mask_opts(j) = 'REMOVE_COLUMN' then
                l_removed_cols := l_removed_cols || ', ' || l_curr_col;
            elsif l_mask_opts(j) = 'HASH_VALUE' then
                l_hashed_cols := l_hashed_cols || ', ' || l_curr_col;
                l_printing_cols := l_printing_cols + 1;
            elsif l_mask_opts(j) <> 'NO_MASK' then
                l_masked_cols := l_masked_cols || ', ' || l_curr_col;
                l_printing_cols := l_printing_cols + 1;
            else
                l_printing_cols := l_printing_cols + 1;
            end if;
        end if;
    END LOOP;
    -- Don't print output if everything was removed
    if l_printing_cols = 0 then
        l_removed_cols := 'All columns';
        l_hashed_cols := null;
        l_masked_cols := null;
        l_print_sql_out := false;
    else
        l_removed_cols := substr(l_removed_cols, 3);
        l_hashed_cols := substr(l_hashed_cols, 3);
        l_masked_cols := substr(l_masked_cols, 3);
    end if;

    -- Process to mask foreign key tokens (EBSAF-275)
    if p_parent_id is not null or p_sig.child_sigs.count > 0 then
        l_curr_col := g_sql_tokens.first;
        while l_curr_col is not null loop
            if l_curr_col like '##$$FK_$$##' then
                l_curr_val := g_sql_tokens(l_curr_col);
                if (g_fk_mask_options.exists(l_curr_col) ) then
                    -- Analyzer defined setting
                    g_masked_tokens(l_curr_col) := mask_text(l_curr_val, g_fk_mask_options(l_curr_col) );
                else
                    -- Signature defined setting
                    g_masked_tokens(l_curr_col) := mask_text(l_curr_val, get_mask_option(0, l_curr_col, p_sig.extra_info) );
                end if;
            end if;
            l_curr_col := g_sql_tokens.next(l_curr_col);
        end loop;
    end if;

  -- Evaluate this signature
  l_step := '50';
  l_sig_fail := l_fail_flag OR
                (p_sig.fail_condition = 'RSGT1' AND l_rows_fetched > 1) OR
                (p_sig.fail_condition = 'RS' AND l_rows_fetched > 0) OR
                (p_sig.fail_condition = 'NRS' and l_rows_fetched = 0);

  l_step := '55';
  IF (l_sig_fail OR p_sig.fail_type = 'I') THEN
     generate_hidden_xml(p_sig_id => p_sig_id,
                         p_sig => p_sig,
                         p_col_headings => p_col_headings,
                         p_col_rows => p_col_rows,
                         p_fail_col => l_fail_col,
                         p_fail_flags => l_fail_flags,
                         p_mask_opts => l_mask_opts,
                         p_parent_sig_id => p_parent_id);
  END IF;

  -- If success and no print just return
  l_step := '60';
  IF ((NOT l_sig_fail) AND p_sig.print_condition IN ('FAILURE','NEVER')) THEN
    IF p_sig.fail_type = 'I' THEN
      sig_time_add(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177
      l_process_elapsed := stop_timer(l_process_start_time);
      debug('Process finish ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');
      return 'I';
    ELSE
    -- Before returning, populate the processed-successfully data
       IF (p_parent_id IS NULL) THEN
           g_results('P') := g_results('P') + 1;
           get_sig_partial(
              p_sig_html => l_sig_html,
              p_sig_id => p_sig_id
           );
           print_clob(l_sig_html);
       END IF;
       sig_time_add(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177
       l_process_elapsed := stop_timer(l_process_start_time);
       debug('Process finish ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');
       return 'S';
    END IF;
  ELSIF (l_sig_fail AND (p_sig.print_condition IN ('SUCCESS','NEVER'))) THEN
    sig_time_add(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177
    l_process_elapsed := stop_timer(l_process_start_time);
    debug('Process finish ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');
    return p_sig.fail_type;
-- if the sig is set as "Print in DX only" then return
  ELSIF (p_sig.include_in_xml = 'D') THEN
    sig_time_add(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177
    l_process_elapsed := stop_timer(l_process_start_time);
    debug('Process finish ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');
    return p_sig.fail_type;
  END IF;


  -- if p_parent_id is null, this is not a child sig (it's a first level signature)
  IF (p_parent_id IS NULL) THEN
     g_level := 1;
     g_family_result := '';
     -- populate the signature result to the global hash
     l_step := 'Populate result in the structure';
     g_sec_detail(g_sec_detail.LAST).sigs.extend();
     g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_id := l_current_sig;
     g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_name := p_sig_id;
     g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result := p_sig.fail_type;
     IF (NOT l_sig_fail AND (p_sig.fail_type != 'I')) THEN
           g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result := 'S';
     END IF;
   ELSE
     g_level := g_level + 1;
   END IF;

   l_tags := get_tags(p_sig_id);

   -- Print container and title
  l_html := '
<!-- '||l_current_sig||' -->

               <div class="data sigcontainer signature '||l_current_section||' '||l_current_sig||' '|| p_class_string || ' ' || g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||' section print analysis" sigid="'||p_sig_id||'" level="'||to_char(g_level)||'"  id="'||l_current_sig||'" style="display: none;">'
               || l_tags || '
                    <div class="divItemTitle">
                        <input type="checkbox" rowid="'||l_current_sig||'" class="exportcheck data print">';
    -- Add expand/collapse icons only if data
    IF (l_print_sql_out) THEN
        l_html := l_html || '
                        <a class="detail" toggle-data="restable_'||l_current_sig||'">
                           <div class="arrowright data section fullsection print analysis">&#9654;</div><div class="arrowdown data" style="display: none">&#9660;</div>
                           <div class="sigdescription" style="display:inline;"><table style="display:inline;"><tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||' sigtitle"><td class="divItemTitlet">'||expand_html(p_sig.title)||'</td></tr></table></div>
                        </a>';
    ELSE
        l_html := l_html || '
                        <div class="sigdescription" style="display:inline;"><table style="display:inline;"><tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||' sigtitle"><td class="divItemTitlet">'||expand_html(p_sig.title)||'</td></tr></table></div>';
    END IF;
    -- CG Review this condition
    IF p_sig.extra_info.count > 0 OR p_sig.sig_sql is not null THEN
        l_html := l_html || '
                        <a class="detailsmall" toggle-info="tbitm_'||l_current_sig||'"><span class="siginfo_ico" title="Show signature information" alt="Show Info"></span></a>';
    END IF;
    -- Show copy SQL icon only if needed (SHOW_SQL != 'N' and the SQL string is not null)
    IF ((p_sig.sig_sql is not null) AND ((NOT p_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (p_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(p_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
        l_html := l_html || '
                        <a class="detailsmall" href="javascript:;" onclick=''copySql("sql_'||l_current_sig||'")''><span class="copysql_ico" title="Copy SQL query to clipboard" alt="Copy SQL"></span></a>';
    end if;
    -- Add export icons only if data
    IF (l_print_sql_out) THEN
        l_html := l_html || '
                        <a class="detailsmall" href="javascript:;" onclick=''export2PaddedText("'||l_current_sig||'", '||to_char(g_level)||');return false;''><span class="export_txt_ico" title="Export to .txt" alt="Export to .txt"></span></a>
                        <a class="detailsmall" href="javascript:;" onclick=''export2CSV("'||l_current_sig||'")''><span class="export_ico" title="Export to .csv" alt="Export to .csv"></span></a>';
    END IF;
    IF (l_print_sql_out AND (l_rows_fetched > 0)) THEN
       l_html := l_html || '
                       <a class="detailsmall" href="javascript:;" onclick=''switchMask("'||l_current_sig||'")''><span class="mask mask_disabled" title="Mask data" alt="Mask data"></span></a>';
       -- add sort icon for non-parents sigs and only when more than 1 record is retrieved (it doesn't make any sense to sort a single record)
       IF ((p_sig.child_sigs.count = 0) AND (l_rows_fetched > 1)) THEN
           l_html := l_html || '
                       <a class="detailsmall"><span class="sort_ico" table-name='||l_current_sig||' title="Sort table" alt="Sort table"></span></a>';
       END IF;
    END IF;
    -- Add feedback
    l_html := l_html || '
                        <a class="detailsmall internal" href="javascript:;" onclick=''postFeedback("up",'||p_sig.sigrepo_id||');''><span class="thumb_up" title="Signature Feedback: Thumbs Up" alt="Thumbs Up Signature"></span></a>
                        <a class="detailsmall internal" href="javascript:;" onclick=''postFeedback("dn",'||p_sig.sigrepo_id||');''><span class="thumb_dn" title="Signature Feedback: Thumbs Down" alt="Thumbs Down Signature"></span></a>
                        <a class="detailsmall internal" href="javascript:;" onclick=''postIdea('||p_sig.sigrepo_id||');''><span class="af_idea" title="Signature Idea" alt="Idea Signature"></span></a>
                    </div>';

  -- Print collapsable/expandable extra info table if there are contents
  l_step := '80';
  IF p_sig.extra_info.count > 0 OR p_sig.sig_sql is not null THEN
    g_item_id := g_item_id + 1;
    l_step := '90';

    l_html := l_html || '
                    <table class="table1 data" id="tbitm_' || l_current_sig || '" style="display:none">
                    <thead>
                       <tr><th bgcolor="#f2f4f7" class="sigdetails">Item Name</th><th bgcolor="#f2f4f7" class="sigdetails">Item Value</th></tr>
                    </thead>
                    <tbody>';
    -- Loop and print values
    l_step := '110';
    l_i := p_sig.extra_info.FIRST;
    WHILE (l_i IS NOT NULL) LOOP
      l_step := '110.1.'||l_i;
      -- don't print the extra info that starts wiht ## (these are hidden)
      IF (NOT regexp_like(l_i,'^##')) THEN
           -- if extra info includes keys like #IMPACT_AREAS#, change the display name to IMpact Areas (title case)
          IF (regexp_like(l_i,'^#[0-9a-zA-Z]')) THEN
              l_html := l_html || '                           <tr><td>' || word_to_titlecase(l_i) || '</td><td>'||
                  p_sig.extra_info(l_i) || '</td></tr>';
          ELSE
              l_html := l_html || '                           <tr><td>' || l_i || '</td><td>'||
                 p_sig.extra_info(l_i) || '</td></tr>';
          END IF;
      END IF;
      l_step := '110.2.'||l_i;
      l_i := p_sig.extra_info.next(l_i);
    END LOOP;
    -- print SQL only if SHOW_SQL != 'N' and the SQL string is not null
    IF ((p_sig.sig_sql is not null) AND ((NOT p_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (p_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(p_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
      l_step := '120';
      l_html := l_html || '
                        <tr><td>SQL</td><td id="sql_'||l_current_sig||'"><pre>'|| prepare_SQL(p_sig.sig_sql) ||
         '</pre></td></tr>';

        -- Explain if results for query may differ from recorded output (EBSAF-269)
        -- Print if selected columns were masked in output
        if l_masked_cols is not null then
            l_html := l_html || '
                        <tr><td>Columns masked in results:</td><td>' || l_masked_cols ||
                '</td></tr>';
        end if;
        -- Print if selected columns were hashed in output
        if l_hashed_cols is not null then
            l_html := l_html || '
                        <tr><td>Columns hashed in results:</td><td>' || l_hashed_cols ||
                '</td></tr>';
        end if;
        -- Print if selected columns were removed from output
        if l_removed_cols is not null then
            l_html := l_html || '
                        <tr><td>Columns removed from results:</td><td>'||l_removed_cols ||
                '</td></tr>';
        end if;
    END IF;

    -- failure condition (EBSAF-259)
    l_html := l_html ||'<tr><td>Failure condition:</td><td>';
    IF p_sig.fail_condition = 'RSGT1' THEN
        l_html := l_html || 'Multiple rows selected';
    ELSIF p_sig.fail_condition = 'RS' THEN
        l_html := l_html || 'Any rows selected';
    ELSIF p_sig.fail_condition = 'NRS' THEN
        l_html := l_html || 'No rows selected';
    ELSE
        l_fail_text := '"' || l_column || '" ' || l_operand;
        if l_operand like '%NULL' then
            null;
        elsif l_operand like '%IN' then
            l_fail_text := l_fail_text ||
                ' (' || join_text(l_value_set, ',') || ')';
        else
            l_fail_text := l_fail_text || ' ' || l_value;
        end if;
        l_html := l_html || escape_html(l_fail_text);
    END IF;
    l_html := l_html || '</td></tr>';

    -- number of records retrieved and elapsed time
    l_html := l_html ||'<tr><td>Number of rows:</td><td>';
      IF p_sig.limit_rows = 'N' OR l_rows_fetched < g_max_output_rows THEN
        l_html := l_html || l_rows_fetched || ' rows selected';
      ELSE
        l_html := l_html ||'The resultset is limited to '||to_char(g_max_output_rows)||' rows. For a complete list of records, please run the query directly in the database.';
      END IF;
      l_html := l_html ||'</td></tr>';
      if (p_sig.version is not null) then
        l_html := l_html ||'<tr><td>Version:</td><td>'||p_sig.version||'</td></tr>';
      end if;
      l_html := l_html ||'<tr><td>Elapsed time:</td><td>'||format_elapsed(g_query_elapsed)||'</td></tr>';
      l_html := l_html || '
                    </tbody>
                    </table>';
  END IF;

  l_step := '140';

  -- Print the header SQL info table
  --print_out(expand_links(l_html, p_sig.sigrepo_id));
  print_buffer(l_sig_html, expand_html(l_html, p_sig_id));
  l_html := null;

  IF l_print_sql_out THEN
    IF p_sig.child_sigs.count = 0 THEN        -- Signature has no children
      -- Print the actual results table
      -- Table header
      l_step := '150';

      l_html := '
                    <!-- table that includes the SQL results (data) -->
                    <div class="divtable">';
      IF (p_parent_id IS NULL) THEN
           l_html := l_html || '
                    <table class="table1 data tabledata parea" id="restable_'||l_current_sig||'" style="display:none">
                    <thead class="pheader">';
      ELSE
           l_html := l_html || '
                    <table class="table1 data tabledata" id="restable_'||l_current_sig||'" style="display:none">
                    <thead>';
      END IF;

      -- Column headings
      l_html := l_html || '
                        <tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';
      print_buffer(l_sig_html, l_html);
      l_html := '';
      l_step := '160';
      FOR i IN 1..p_col_headings.count LOOP
        l_curr_col := filter_html(p_col_headings(i),'I','D'); -- Delete invalid characters from header (EBSAF-263)
        IF upper(nvl(l_curr_col,'XXX')) not like '##$$FK_$$##' THEN
            l_mask_option := l_mask_opts(i);
            if (l_mask_option <> 'REMOVE_COLUMN') then  -- EBSAF-269

                if (l_mask_option = 'HASH_VALUE') then
                    l_tags := ' masked" title="Data in this column has been hashed and does not show the actual value';
                elsif (l_mask_option <> 'NO_MASK') then
                    l_tags := ' masked" title="Data in this column has been masked and does not show the full value';
                else
                    l_tags := null;
                end if;

                  l_html := l_html || '
                                    <th bgcolor="#f2f4f7" class="sigdetails' || l_tags || '">'||nvl(l_curr_col,'&nbsp;')||'</th>';
                 -- if the html buffer is already larger than the limit, spool the content and reset
                 IF (LENGTH(l_html) > 32000) THEN
                 print_buffer(l_sig_html, expand_html(l_html, p_sig_id));
                     l_html := '';
                 END IF;

            end if;
        END IF;
      END LOOP;
      l_html := l_html || '
                        </tr>
                    </thead>
                    <tbody>';
      -- Print headers
      print_buffer(l_sig_html, expand_html(l_html, p_sig_id));
      -- Row values
      l_step := '170';
      FOR i IN 1..l_rows_fetched LOOP
        l_html := '                        <tr class="tdata '||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';
        l_step := '170.1.'||to_char(i);
        FOR j IN 1..p_col_headings.count LOOP
          -- Evaluate if necessary
          l_step := '170.2.'||to_char(j);
          -- Use cached fail flags
          l_row_fail := (j = l_fail_col AND l_fail_flags(i) = 'Y');
          l_step := '170.3.'||to_char(j);
          l_curr_col := upper(filter_html(p_col_headings(j),'I','D')); -- Delete invalid characters from header (EBSAF-263)
          l_step := '170.4.'||to_char(j);
          l_curr_val := p_col_rows(j)(i);
          l_step := '170.5.'||to_char(j);

          IF (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col)) AND (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col) IS NOT NULL) THEN
              l_style := get_style(p_sig.extra_info('##STYLE##'||l_curr_col));
          ELSE
              l_style := '';
          END IF;

            -- EBSAF-269
            l_mask_option := l_mask_opts(j);
            if (l_mask_option <> 'REMOVE_COLUMN') then

              -- Print
              l_step := '170.7.'||to_char(j);
              IF upper(nvl(p_col_headings(j),'XXX')) not like '##$$FK_$$##' THEN
                 BEGIN
                    l_tags := 'sigdetails';
                    if (l_mask_option = 'NO_MASK') then -- EBSAF-269
                      IF (g_dest_to_source.EXISTS(p_sig_id)) AND (g_dest_to_source(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_dest_to_source(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                            l_cell_text := '<a class="anchor" id="'|| g_dest_to_source(p_sig_id).cols(l_curr_col)||'_'||filter_html(l_curr_val,'D','D')|| '"></a>' || filter_html(l_curr_val,'H','H');
                      ELSIF (g_source_to_dest.EXISTS(p_sig_id)) AND (g_source_to_dest(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_source_to_dest(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                            l_cell_text := '<a href="" siglink="'|| g_source_to_dest(p_sig_id).cols(l_curr_col)||'_'||filter_html(l_curr_val,'D','D')|| '">' || filter_html(l_curr_val,'H','H') || '</a>';
                            l_cell_text := l_cell_text || '<span class="brokenlink" style="display:none;" title="This record does not have a parent"></span>';
                      ELSE
                            l_cell_text := filter_html(l_curr_val,'H','H');
                      END IF;
                    else
                        -- Masking prevents linking (EBSAF-269)
                        l_cell_text := mask_text(l_curr_val, l_mask_option);
                        l_tags := l_tags || ' masked';
                    end if;

                    if l_row_fail then
                        l_tags := l_tags || ' hlt';
                    end if;

                    -- Mark cell as containing hidden data
                    IF instr(lower(l_cell_text),'"hidden_data"') > 0 THEN
                        l_tags := l_tags || ' hidden_data_parent';
                        l_hidden_data := true;
                    END IF;

                    l_html := l_html || '
                                   <td class="' || l_tags || '" ' || l_style || '>'|| l_cell_text || '</td>';
                 EXCEPTION WHEN OTHERS THEN
                      print_log('Error in process_signature_results populating table data for signature: ' || p_sig_id);
                      print_log('Error:' || sqlerrm);
                 END;
              END IF;

            end if;

            -- if the html buffer is already larger than the limit, spool the content and reset
            IF (LENGTH(l_html) > 32000) THEN
                print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
                l_html := '';
            END IF;
        END LOOP;
        l_html := l_html || '
                        </tr>';
        print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
      END LOOP;

      -- End of results and footer
      l_step := '180';
      l_html :=  '
                    </tbody>
                    </table>
                    </div>  <!-- end table data -->';

      -- Add block for hidden data (EBSAF-255)
      if l_hidden_data then
        l_html := l_html || '
                    <div>
                        <b>Attention:</b>
                        This data contains leading/trailing whitespace or invalid characters that are hidden by default.
                        Click the <span class="hidden_ico" alt="Hidden Data"></span> icon to toggle hidden data visibility.
                     </div>';
      end if;

      l_step := '190';
      print_buffer(l_sig_html, l_html);
--
    ELSE -- there are children signatures
      -- Print master rows and call appropriate processes for the children
      -- Table header
      l_html := '
                    <!-- table that includes the SQL results (data) -->
                    <div class="divtable">';
      l_html := l_html || '
                    <table class="table1 data tabledata" id="restable_'||l_current_sig||'" style="display:none">';

      -- Row values
      l_step := '200';
      FOR i IN 1..l_rows_fetched LOOP
        l_step := '200.1'||to_char(i);
        -- Column headings printed for each row
        l_html := l_html || '
                        <tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';
        FOR j IN 1..p_col_headings.count LOOP
          l_step := '200.2'||to_char(j);
            l_mask_option := l_mask_opts(j);
            if (l_mask_option <> 'REMOVE_COLUMN') then  -- EBSAF-269
              IF upper(nvl(p_col_headings(j),'XXX')) not like '##$$FK_$$##' THEN
                if (l_mask_option = 'HASH_VALUE') then
                    l_tags := ' masked" title="Data in this column has been hashed and does not show the actual value';
                elsif (l_mask_option <> 'NO_MASK') then
                    l_tags := ' masked" title="Data in this column has been masked and does not show the full value';
                else
                    l_tags := null;
                end if;
                l_html := l_html || '
                                <th bgcolor="#f2f4f7" class="sigdetails '||l_current_sig||l_tags||'">'||nvl(p_col_headings(j),'&nbsp;')||'</th>';
              END IF;
            end if;
          -- if the html buffer is already larger than the limit, spool the content and reset
          IF (LENGTH(l_html) > 32000) THEN
            print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
            l_html := '';
          END IF;
        END LOOP;
        l_step := '200.3';
        l_html := l_html || '
                        </tr>';
        -- Print headers
        print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
        -- Print a row
        l_html := '
                        <tr class="tdata '||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result||'">';

        l_printing_cols := 0;
        FOR j IN 1..p_col_headings.count LOOP
          l_step := '200.4'||to_char(j);
          l_curr_col := upper(p_col_headings(j));
          l_curr_val := p_col_rows(j)(i);

          -- If the col is a FK set the global replacement vals
          IF l_curr_col like '##$$FK_$$##' THEN
            l_step := '200.5';
            g_sql_tokens(l_curr_col) := l_curr_val;
            -- Allow tokens to be masked (EBSAF-275)
            if (g_fk_mask_options.exists(l_curr_col) ) then
                -- Analyzer defined setting
                g_masked_tokens(l_curr_col) := mask_text(l_curr_val, g_fk_mask_options(l_curr_col) );
            else
                -- Signature defined setting
                g_masked_tokens(l_curr_col) := mask_text(l_curr_val, get_mask_option(0, l_curr_col, p_sig.extra_info) );
            end if;
          ELSE -- printable column
            l_printing_cols := l_printing_cols + 1;

            -- Use cached fail flags
            l_row_fail := (j = l_fail_col AND l_fail_flags(i) = 'Y');

            IF (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col)) AND (p_sig.extra_info('##STYLE##'||l_curr_col) IS NOT NULL) THEN
                l_style := get_style(p_sig.extra_info('##STYLE##'||l_curr_col));
            ELSE
                l_style := '';
            END IF;

            -- EBSAF-269
            l_mask_option := l_mask_opts(j);
            if (l_mask_option <> 'REMOVE_COLUMN') then
                -- Print
              BEGIN
                    l_tags := 'sigdetails';
                    if (l_mask_option = 'NO_MASK') then -- EBSAF-269
                       IF (g_dest_to_source.EXISTS(p_sig_id)) AND (g_dest_to_source(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_dest_to_source(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                             l_cell_text := '<a class="anchor" id="'|| g_dest_to_source(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '"></a>' || l_curr_val;
                       ELSIF (g_source_to_dest.EXISTS(p_sig_id)) AND (g_source_to_dest(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_source_to_dest(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                             l_cell_text := '<a href="" siglink="'|| g_source_to_dest(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '">' || l_curr_val || '</a>';
                             l_cell_text := l_cell_text || '<span class="brokenlink" style="display:none;" title="This record does no have a parent"></span>';
                       ELSE
                             l_cell_text := l_curr_val;
                       END IF;
                    else
                        -- Masking prevents linking (EBSAF-269)
                        l_cell_text := mask_text(l_curr_val, l_mask_option);
                        l_tags := l_tags || ' masked';
                    end if;

                    if l_row_fail then
                        l_tags := l_tags || ' hlt';
                    end if;
                    l_html := l_html || '
                                   <td class="' || l_tags || '" ' || l_style || '>'|| l_cell_text || '</td>';
              EXCEPTION WHEN OTHERS THEN
                   print_log('Error in process_signature_results populating table data for signature: ' || p_sig_id);
              END;

            end if;

          END IF;
          -- if the html buffer is already larger than the limit, spool the content and reset
          IF (LENGTH(l_html) > 32000) THEN
            print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
            l_html := '';
          END IF;
        END LOOP;
        l_html := l_html || '
                        </tr>';
        print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
        l_html := null;
        FOR k IN p_sig.child_sigs.first..p_sig.child_sigs.last LOOP
          print_buffer(l_sig_html, '
                        <tr><td colspan="'||to_char(l_printing_cols)||'"><blockquote>');
          DECLARE
            l_col_rows  COL_LIST_TBL := col_list_tbl();
            l_col_hea   VARCHAR_TBL := varchar_tbl();
            l_child_sig SIGNATURE_REC;
            l_result    VARCHAR2(1);
          BEGIN
           l_child_sig := g_signatures(p_sig.child_sigs(k));
           print_log('Processing child signature: '||p_sig.child_sigs(k));
           l_run_result := run_sig_sql(p_sig.child_sigs(k), l_child_sig.sig_sql, l_col_rows, l_col_hea, l_child_sig.limit_rows, p_sig_id);
           l_class_string := p_class_string || ' ' || l_current_sig;
           g_child_sig_html := null;
           IF (l_run_result) THEN
               l_result := process_signature_results(p_sig.child_sigs(k), l_child_sig, l_col_rows, l_col_hea, l_current_sig, p_sig_suffix || '_' || to_char(i), l_class_string, p_sig_id);
               set_item_result(l_result);
           ELSE
               -- Child signature query failed
               get_sig_partial(
                    p_sig_html => g_child_sig_html,
                    p_sig_id => p_sig.child_sigs(k),
                    p_level => g_level + 1,
                    p_class_string => l_current_section||' '||l_class_string,
                    p_error_msg => g_errbuf
               );
           END IF;
           IF (g_child_sig_html is not null) THEN
               dbms_lob.append(l_sig_html, g_child_sig_html);
               dbms_lob.freetemporary(g_child_sig_html);
           END IF;

           -- show parent signature failure based on result from child signature(s)
         IF l_result in ('W','E') THEN
             l_fail_flag := true;
           IF l_result = 'E' THEN
             l_error_type := 'E';
           ELSIF (l_result = 'W') AND ((l_error_type is NULL) OR (l_error_type != 'E')) THEN
             l_error_type := 'W';
           END IF;
           -- if g_family_result already has a value of 'E', no need to set it again
           IF (g_family_result = 'E') THEN
              NULL;
           ELSIF (g_family_result = 'W' AND l_result = 'E') THEN
              g_family_result := 'E';
           ELSE
              g_family_result := l_result;
           END IF;
         END IF;

          EXCEPTION WHEN OTHERS THEN
            print_log('Error in process_signature_results processing child signature: '||p_sig.child_sigs(k));
            print_log('Error: '||sqlerrm);
          END;
          print_buffer(l_sig_html, '
                        </blockquote></td></tr>');
        END LOOP;
      END LOOP;

      -- End of results and footer
      l_step := '210';
      l_html := l_html || '
                     <div style="display:none" class="sigrescode '||l_current_section||' '||l_current_sig||' '|| p_class_string || ' ' || l_sig_result||'" level="'||to_char(g_level)||'"></div>
      ';
      l_html := l_html ||  '
                    </tbody>
                    </table>
                    </div>  <!-- end table data -->';

      print_buffer(l_sig_html, l_html);
    END IF; -- master or child

  END IF; -- print output is true

  -------------------------------------
  -- Print actions for each signature
  -------------------------------------
  l_sig_result := 'S';
  IF l_sig_fail THEN
    l_step := '230';
    IF p_sig.fail_type = 'E' THEN
      l_html := '
                    <div class="divuar results data print section fullsection">
                        <span class="divuar1">Error: </span>' || p_sig.problem_descr; --||prepare_text(expand_tokens(p_sig.problem_descr, p_sig.extra_info));
      l_sig_result := 'E';
    ELSIF p_sig.fail_type = 'W' THEN
      l_html := '
                    <div class="divwarn results data print section fullsection">
                        <span class="divwarn1">Warning: </span>' || p_sig.problem_descr; --||prepare_text(expand_tokens(p_sig.problem_descr, p_sig.extra_info));
      l_sig_result := 'W';
    ELSE
      l_html := '
                    <div class="divinfo results data print section fullsection">
                        <span class="divinfo1">Information: </span>' || p_sig.problem_descr; --||prepare_text(expand_tokens(p_sig.problem_descr, p_sig.extra_info));
      l_sig_result := 'I';
    END IF;

    -----------------------------------------------------
    -- Print solution part of the action - only if passed
    -----------------------------------------------------
    l_step := '240';
    IF p_sig.solution is not null THEN
      l_html := l_html || '
                     <br><br><span class="solution">Findings and Recommendations:</span><br>
        ' || p_sig.solution;
    END IF;

    -- Close div here cause success div is conditional
    l_html := l_html || '
                    </div> <!-- end results div -->';
  ELSE
    IF p_sig.fail_type = 'I' THEN
         l_sig_result := 'I';
    END IF;
    l_step := '250';
    IF p_sig.success_msg is not null THEN
      IF p_sig.fail_type = 'I' THEN
        l_html := '
          <div class="divinfo results data print section fullsection"><div class="divinfo1">Information:</div>'||
          nvl(p_sig.success_msg, 'No instances of this problem found') ||
          '</div> <!-- end results div -->';
      ELSE
        l_html := '
          <div class="divok results data print section fullsection"><div class="divok1"><span class="check_ico"></span> All checks passed.</div>'||
          nvl(p_sig.success_msg, 'No instances of this problem found') ||
          '</div> <!-- end results div -->';
      END IF;
    ELSE
      l_html := null;
    END IF;
  END IF;
  l_html := expand_html(l_html, p_sig_id); -- EBSAF-180


  -- DIV for parent

     IF p_sig.child_sigs.count > 0 and (p_parent_id IS NULL) THEN
        IF g_family_result = 'E' THEN
           l_html := l_html || '
             <div class="divuar results data print section fullsection"><span class="divuar1">Error:</span> Error(s) and/or warning(s) are reported in this section. Please expand section for more information.</div>';
        ELSIF g_family_result = 'W' THEN
           l_html := l_html || '
             <div class="divwarn results data print section fullsection"><span class="divwarn1">Warning:</span> Warning(s) are reported in this section. Please expand section for more information. </div>';
        END IF;
      END IF;

    -- if p_parent_id is null, this is not a child sig (it's a first level signature)
    IF (p_parent_id IS NULL)  THEN
        IF (g_family_result = 'E' or g_family_result = 'W') THEN
            g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result := g_family_result;
            l_sig_result := g_family_result;
        END IF;
        -- increment the global counter and the section counter for the fail_type
        DECLARE
           l_result VARCHAR2(1);
        BEGIN
           l_result := g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result;
           g_results(l_result) := g_results(l_result) + 1;
           g_sec_detail(g_sec_detail.LAST).results(l_result) := g_sec_detail(g_sec_detail.LAST).results(l_result) + 1;
        END;
    END IF;


   -- print the result div of the sig container

    l_html := l_html || '
                     <div style="display:none" class="sigrescode '||l_current_section||' '||l_current_sig||' '|| p_class_string || ' ' || l_sig_result||'" level="'||to_char(g_level)||'"></div>
    ';


    l_html := l_html || '
                </div> <!-- end of sig container -->
<!-- '||l_current_sig||'-->';

  l_step := '260';
  g_sections(g_sections.last).print_count := g_sections(g_sections.last).print_count + 1;

  -- Print or return HTML
  l_step := '270';
  print_buffer(l_sig_html, expand_html(l_html, p_sig_id) );
  if (p_parent_id is null) then
    print_clob(l_sig_html, 'N');
  else
    g_child_sig_html := l_sig_html;
  end if;

  g_level := g_level - 1;

  sig_time_add(p_sig_id, p_parent_sig_id, 'P'); -- EBSAF-177 Time only needed for successful process
  l_process_elapsed := stop_timer(l_process_start_time);
  debug('Process finish ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');

  IF l_sig_fail THEN
    l_step := '280';
    return p_sig.fail_type;
  ELSE
    l_step := '290';
    IF p_sig.fail_type = 'I' THEN
      return 'I';
    ELSE
      return 'S';
    END IF;
  END IF;

EXCEPTION
  WHEN L_INV_PARAM THEN
    print_log('Invalid parameter error in process_signature_results at step '||l_step);
    return 'X';
  WHEN OTHERS THEN
    l_process_elapsed := stop_timer(l_process_start_time);
    debug('Process failed ['||l_current_sig||'] ('||format_elapsed(l_process_elapsed)||')');
    print_log('Error in process_signature_results at step '||l_step);
    print_log(SQLERRM);

    -- Print or return HTML
    g_errbuf := 'PROGRAM ERROR<br>
      Error in process_signature_results at step '|| l_step||': '||sqlerrm||'<br>
      See the log file for additional details';
    get_sig_partial(
        p_sig_html => l_sig_html,
        p_sig_id => p_sig_id,
        p_level => g_level,
        p_class_string => l_current_section||' '||p_class_string,
        p_error_msg => g_errbuf
    );
    if (p_parent_id is null) then
        print_clob(l_sig_html, 'N');
    else
        g_child_sig_html := l_sig_html;
    end if;
    return 'X';
END process_signature_results;


----------------------------------------------------------------
-- Start the main section                                     --
-- (where the sections and signatures reside)                 --
----------------------------------------------------------------
PROCEDURE start_main_section is
    l_banner_code varchar2(3000);
    l_banner_bg varchar2(20);
    l_banner_fg varchar2(20);
    l_banner_lbl varchar2(20);
BEGIN
  -- Start main body and spacer under header
  print_out('
<!-- start body -->
    <div class="body background">
    <div style="min-height:75px;"></div>');

    -- Build custom banner message if needed
    if (g_banner_message is not null) then
        l_banner_code := '    <div id="banner" class="#99#BANNER_BG#99#" style="text-align:center; overflow:hidden; min-width:initial;" data-popup="banner">
        <span class="#99#BANNER_FG#99#">#99#BANNER_LBL#99#:</span> #99#BANNER_MSG#99#
        <div class="close-button" style="margin:0px;" data-popup-close="banner"><a class="black-link">OK</a></div>
    </div>';
        case g_banner_severity
            when 'S' then
                l_banner_bg := 'divok';
                l_banner_fg := 'divok1';
                l_banner_lbl := 'Success';
            when 'I' then
                l_banner_bg := 'divinfo';
                l_banner_fg := 'divinfo1';
                l_banner_lbl := 'Information';
            when 'W' then
                l_banner_bg := 'divwarn';
                l_banner_fg := 'divwarn1';
                l_banner_lbl := 'Warning';
            else -- assume 'E'
                l_banner_bg := 'divuar';
                l_banner_fg := 'divuar1';
                l_banner_lbl := 'Error';
        end case;
        l_banner_code := replace(l_banner_code, '#99#BANNER_BG#99#', l_banner_bg);
        l_banner_code := replace(l_banner_code, '#99#BANNER_FG#99#', l_banner_fg);
        l_banner_code := replace(l_banner_code, '#99#BANNER_LBL#99#', l_banner_lbl);
        l_banner_code := replace(l_banner_code, '#99#BANNER_MSG#99#', g_banner_message);
        print_out(expand_html(filter_html(l_banner_code, 'I', 'D')));
    end if;

  -- Main page
  print_out('<!-- main data screen (showing section and signatures) -->
    <div class="maindata print analysis section fullsection P">
    <div style="min-height:10px;"></div>
    <div class="sigcontainer background">
       <div style="width:100%;">
           <div style="float:left;padding-left:10px;padding-top:15px;display:inline-block" id ="showhidesection" mode="show">
               <a href="#" class="detailsmall data section sectionview" mode="show" id="showAll" open-sig-class=""><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAARCAYAAAA/mJfHAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH4gMcDiQnlEv7GQAAACtJREFUOMtj/P//PwO1AGNAQADVTGNioCKgqmGM1AyzQezN0dgcjc0RHZsAwIQR3X8SrOYAAAAASUVORK5CYII=" alt="show_all" title="Show entire section"></a>
               <a href="#" class= "detailsmall data fullsection sectionview" mode="hide" id="hideAll" open-sig-class=""><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAARCAYAAAA/mJfHAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH4gMcDiQnlEv7GQAAACtJREFUOMtj/P//PwO1AGNAQADVTGNioCKgqmGM1AyzQezN0dgcjc0RHZsAwIQR3X8SrOYAAAAASUVORK5CYII=" alt="hide_all" title="Show Single Signature"></a>
          </div>
          <div class="containertitle" style="display:inline-block;vertical-align:middle;float:right;width:95%;"></div>
       </div>
       <table class="background" style="width:100%;border-spacing:0;border-collapse:collapse;">
        <tr>
            <td class="leftcell data section background">   <!-- Start menu on the left hand side -->
            <div class="sectionmenu background" id="sectionmenu">
            </div>
            </td>
            <!-- Cell that includes the signature details -->
            <td class="rightcell analysis print section fullsection P">
                 <div class="sigcontainer" style="padding:20px;margin:0;">
                   <div class="searchbox data analysis print section fullsection">
                       <div style="float:left"><b>Search within tables:</b></div><br>
                       <div style="float:left"><input type="text" class="search" placeholder="Enter search string and press <enter>" id="search" size="96" maxlength="96"></div><br>
                   </div><br><br>
                   <div class="expcoll data analysis print section fullsection">
                       <a class="detailsmall export2Txt data fullsection" id="export2TextLink" href="javascript:;" onclick=''export2PaddedText("")''><span class="export_txt_ico" title="Export to .txt" alt="Export to .txt"></span></a>
                       &nbsp;&nbsp;
                       <input type="checkbox" class="data print" id="exportAll">
                       <a class="detailsmall print data exportAllImg fullsection" href="javascript:;" onclick=''export2CSV("ALL")''><span class="export_ico" title="Export to Excel (.csv)" alt="Export to .csv"></span></a>
                       &nbsp;&nbsp;
                       <a class="detailsmall export2HTML data analysis" id="export2HTMLLink" href="javascript:;" onclick=''export2HTML()''><span class="export_html_ico" title="Development view (Export to .html)" alt="Export to .htm"></span></a>
                       &nbsp;&nbsp;
                       <a href="#" class="detailsmall fullsection data print analysis" id="expandall" mode="analysis"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABcAAAASCAYAAACw50UTAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH4QcDCAcI/tBeNAAAAHxJREFUOMtj/P//PwMMMC4zvMvAwMDwP+q8MgMVABMDDQFNDWdkWGpwF58CSoKIhaDtReeqyHY5vgilxGCIt///h2OGpQZ3GZYa3IXzC89WIcuTKkbTCGWhVuQRDHNqRiZGmFMSvnQPc9rm0NEwH2xhfraYgYGRncwA/wkAE9bkVHL11nAAAAAASUVORK5CYII=" alt="expand_all" title="Expand All Tables"></a>&nbsp;
                       <a href="#" class="detailsmall fullsection data print analysis" id="collapseall"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAARCAYAAAAyhueAAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH4QcDCA4nhMPYJAAAAFRJREFUOMtjfM3A+ZgBBxD5/02WgQzAxEADwPj//3+qG8qC1aaic1WUGEoT7zP8//8fAzMUnq2iRIwmLqVf7FMaUaNhOhqm9AnTs8UMDIzsZAboTwAjVcX2TISAoAAAAABJRU5ErkJggg==" alt="collapse_all" title="Collapse All Tables"></a>
                   </div>
            <br><br>
                   <div class="data tags tagarea" id="tags_area"></div>
            ');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in start_main_section: '||sqlerrm);
  raise;
END start_main_section;


PROCEDURE end_main_section IS
   l_html           VARCHAR2(32767) := '';
BEGIN

print_out('
      </div> <!-- end of inner container -->
            </td>
        </tr>
      </table>
    </div>  <!-- end of outer container -->
    <div style="min-height: 35;"></div>
  </div> <!-- end of main data -->
 </div> <!-- end of body -->');

/* REMOVED TO ELIMINATE INLINE JAVASCRIPT (EBSAF-262)
-- Populate the sectionmenu details here, because we need the signature results
    print_out('<script>');
    print_out('if ($("#sectionmenu").children().length == 0) {');  -- EBSAF-211
    FOR i IN 1 .. g_sec_detail.COUNT LOOP
        FOR j IN 1 .. g_sec_detail(i).sigs.COUNT LOOP
            -- in case of customizations, the global signatures table might not be populated correctly, so we might encounter a "no data found" exception.
            BEGIN
                l_html := ' <div class="sectionbutton data '||g_sec_detail(i).name||' '||nvl(g_sec_detail(i).sigs(j).sig_id, 'null')||' '||nvl(g_sec_detail(i).sigs(j).sig_result, 'I')||'" open-sig="'||g_sec_detail(i).sigs(j).sig_id||'"> <span class="'||g_result(nvl(g_sec_detail(i).sigs(j).sig_result, 'I'))||'_small"></span><span style="padding:5px;">'||prepare_text(g_signatures(g_sec_detail(i).sigs(j).sig_name).title)||'</span> </div>';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_html := ' <div class="sectionbutton data '||g_sec_detail(i).name||' '||nvl(g_sec_detail(i).sigs(j).sig_id, 'null')||' '||nvl(g_sec_detail(i).sigs(j).sig_result, 'I')||'" open-sig="'||g_sec_detail(i).sigs(j).sig_id||'"> <span class="'||g_result(nvl(g_sec_detail(i).sigs(j).sig_result, 'I'))||'_small"></span><span style="padding:5px;">' || g_sec_detail(i).sigs(j).sig_name || '</span> </div>';
                WHEN OTHERS THEN
                raise;
            END;
            print_out('
                  $("#sectionmenu").append('''||l_html||''');');
        END LOOP;
    END LOOP;
    print_out('}');  -- EBSAF-211
    print_out('</script>');
*/

EXCEPTION WHEN OTHERS THEN
  print_log('Error in end_main_section: '||sqlerrm);
  raise;
END end_main_section;



----------------------------------------------------------------
-- Creates a report section                                   --
-- For now it just prints html, in future it could be         --
-- smarter by having the definition of the section logic,     --
-- signatures etc....                                         --
----------------------------------------------------------------

PROCEDURE start_section(p_sect_title VARCHAR2, p_sect_name VARCHAR2 DEFAULT null) IS
  lsect section_rec;
  l_sig_array signatures_tbl := signatures_tbl();

BEGIN
  print_out('<div class="sectiongroup" section-id="' || replace_chars(nvl(p_sect_name, p_sect_title)) || ' " section-title="' || htf.escape_sc(p_sect_title) || '">' || chr(10));

  g_sections(g_sections.count + 1) := lsect;

  -- add element in the sections table
  g_sec_detail.extend();
  -- Fix section names (EBSAF-279)
  IF (p_sect_name is not null) THEN
      g_sec_detail(g_sec_detail.LAST).name := replace_chars(p_sect_name);
  ELSE
      g_sec_detail(g_sec_detail.LAST).name := replace_chars(p_sect_title);
  END IF;
  g_sec_detail(g_sec_detail.LAST).title := p_sect_title;

  g_sec_detail(g_sec_detail.LAST).sigs := l_sig_array;
  -- initialize the results hash for section
  g_sec_detail(g_sec_detail.LAST).results('E') := 0;
  g_sec_detail(g_sec_detail.LAST).results('W') := 0;
  g_sec_detail(g_sec_detail.LAST).results('S') := 0;
  g_sec_detail(g_sec_detail.LAST).results('I') := 0;

EXCEPTION WHEN OTHERS THEN
  print_log('Error in start_section: '||sqlerrm);
  raise;
END start_section;


----------------------------------------------------------------
-- Finalizes a report section                                 --
-- Finalizes the html                                         --
----------------------------------------------------------------
PROCEDURE end_section (p_success_msg IN VARCHAR2 DEFAULT null) IS
  -- p_success_message is no longer used (EBSAB-498)
BEGIN
  print_out('</div>' || chr(10));
END end_section;

----------------------------------------------------------------
-- Analyzer-specific code: Function and Procedures (Body)     --
----------------------------------------------------------------
---------------------------------
-- Get list of AME rules
---------------------------------
FUNCTION get_ame_rules_for_trxn(p_trxn_id VARCHAR2) RETURN VARCHAR2 IS

   l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
   l_hdr        VARCHAR_TBL := varchar_tbl(); -- Column headings

   l_sig        SIGNATURE_REC;
   l_ame_rules  ame_rules_list;
   l_error      VARCHAR2(100);
   l_step       VARCHAR2(10);

BEGIN

   -- Column headings
   l_step := '10';
   l_hdr.extend(12);
   l_hdr(1) := 'Rule ID';
   l_hdr(2) := 'Name';
   l_hdr(3) := 'Item Class ID';
   l_hdr(4) := 'Item Class';
   l_hdr(5) := 'Item ID';
   l_hdr(6) := 'Rule Type';
   l_hdr(7) := 'Rule Type ID';
   l_hdr(8) := 'Category';
   l_hdr(9) := 'Usage Start Date';
   l_hdr(10) := 'Usage End Date';
   l_hdr(11) := 'Conditions List';
   l_hdr(12) := 'Actions List';

   l_step := '20';
   BEGIN
       ame_test_utility_pkg.getApplicableRules(
            applicationIdIn    => to_number(g_sql_tokens('##$$AMEAPPID$$##')),
            transactionIdIn    => p_trxn_id,
            isRealTransaction  => 'Y',
            processPriorities  => 'Y',
            rulesOut           => l_ame_rules,
            errString          => l_error);
   EXCEPTION WHEN OTHERS THEN
        print_log('get_ame_rules_for_trxn: Error calling getApplicableRules API!');
        RETURN null;
   END;

   l_step := '30';
   l_col_rows.extend(12);

   IF l_ame_rules.COUNT > 0 THEN
       FOR i IN l_ame_rules.FIRST .. l_ame_rules.LAST
       LOOP
           print_log(l_ame_rules(i).name);
           l_step := '30.1';
           l_col_rows(1)(i) := l_ame_rules(i).rule_id;
           l_col_rows(2)(i) := l_ame_rules(i).name;
           l_col_rows(3)(i) := l_ame_rules(i).item_class_id;
           l_col_rows(4)(i) := l_ame_rules(i).item_class;
           l_col_rows(5)(i) := l_ame_rules(i).item_id;
           l_col_rows(6)(i) := l_ame_rules(i).rule_type;
           l_col_rows(7)(i) := l_ame_rules(i).rule_type_id;
           l_col_rows(8)(i) := l_ame_rules(i).category;
           l_col_rows(9)(i) := l_ame_rules(i).usageStartDate;
           l_col_rows(10)(i) := l_ame_rules(i).usageEndDate;
           l_col_rows(11)(i) := l_ame_rules(i).conditionsList;
           l_col_rows(12)(i) := l_ame_rules(i).actionsList;
        END LOOP;
    ELSE
        print_log('get_ame_rules_for_trxn: No rules found!');
    END IF;

    l_sig.title := 'Rules for Transaction ' || p_trxn_id;
    l_sig.fail_condition := 'NRS';
    l_sig.problem_descr := 'No rules found. '||l_sig.problem_descr;
    l_sig.solution := 'Review the AME configuration information to determine why there are no available rules.<br> For further details review [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.success_msg := 'This is a data collection of rules for this transaction.<br>[434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.print_condition := 'ALWAYS';
    l_sig.fail_type := 'I';
    l_sig.print_sql_output := 'RS';
    l_sig.limit_rows := 'N';

    RETURN process_signature_results(
      'Rules_for_transaction',      -- sig ID
      l_sig,                 -- signature information
      l_col_rows,            -- data
      l_hdr);                -- headers

EXCEPTION WHEN OTHERS THEN
   print_log ('Exception in get_ame_rules_for_trxn at step '||l_step);
   RETURN null;
END get_ame_rules_for_trxn;


---------------------------------------------------------
-- Get list of AME approvers for a specific transaction -
---------------------------------------------------------
FUNCTION get_ame_approvers_for_trxn(p_trxn_id VARCHAR2) RETURN VARCHAR2 IS

   l_col_rows       COL_LIST_TBL := col_list_tbl(); -- Row values
   l_hdr            VARCHAR_TBL := varchar_tbl(); -- Column headings

   l_sig            SIGNATURE_REC;
   l_ame_approvers  ame_approvers_list;
   l_error          VARCHAR2(100);
   l_step           VARCHAR2(10);

BEGIN

   -- Column headings
   l_step := '10';
   l_hdr.extend(13);
   l_hdr(1) := 'Approver Order Number';
   l_hdr(2) := 'Approver Type';
   l_hdr(3) := 'Approver';
   l_hdr(4) := 'Category';
   l_hdr(5) := 'Item Class';
   l_hdr(6) := 'Item ID';
   l_hdr(7) := 'Chain Number';
   l_hdr(8) := 'Sub List';
   l_hdr(9) := 'Action Type';
   l_hdr(10) := 'Source';
   l_hdr(11) := 'Source Rules';
   l_hdr(12) := 'Productions';
   l_hdr(13) := 'Status';

   l_step := '20';

   BEGIN
       ame_test_utility_pkg.getApprovers(
           applicationIdIn     => to_number(g_sql_tokens('##$$AMEAPPID$$##')),
           transactionIdIn     => p_trxn_id,
           isRealTransaction   => 'Y',
           approverListStageIn => 6,
           approversOut        => l_ame_approvers,
           errString           => l_error);
   EXCEPTION WHEN OTHERS THEN
        print_log('get_ame_approvers_for_trxn: Error calling getApprovers API!');
        RETURN null;
   END;

   l_step := '30';
   l_col_rows.extend(13);

   IF l_ame_approvers.COUNT > 0 THEN
       FOR i IN l_ame_approvers.FIRST .. l_ame_approvers.LAST
       LOOP
           print_log(l_ame_approvers(i).name);
           l_step := '30.1';

           l_col_rows(1)(i) := l_ame_approvers(i).approver_order_number     ;
           l_col_rows(2)(i) := l_ame_approvers(i).orig_system_name          ;
           l_col_rows(3)(i) := l_ame_approvers(i).group_name                ;
           l_col_rows(4)(i) := l_ame_approvers(i).approver_category_desc    ;
           l_col_rows(5)(i) := l_ame_approvers(i).item_class                ;
           l_col_rows(6)(i) := l_ame_approvers(i).item_id                   ;
           l_col_rows(7)(i) := l_ame_approvers(i).group_or_chain_id         ;
           l_col_rows(8)(i) := l_ame_approvers(i).authority_desc            ;
           l_col_rows(9)(i) := l_ame_approvers(i).action_type_name          ;
           l_col_rows(10)(i) := l_ame_approvers(i).source                    ;
           l_col_rows(11)(i) := l_ame_approvers(i).source_Desc               ;
           l_col_rows(12)(i) := l_ame_approvers(i).productionsList           ;
           l_col_rows(13)(i) := l_ame_approvers(i).productionsList           ;

        END LOOP;
    ELSE
        print_log('get_ame_approvers_for_trxn: No rules found!');
    END IF;
    l_sig.title := 'Approvers for Transaction ' || p_trxn_id;
    l_sig.fail_condition := 'NRS';
    l_sig.problem_descr := 'No approvers found. '||l_sig.problem_descr;
    l_sig.solution := 'Review the AME configuration information to determine why there are no approvers.<br> [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.success_msg := 'This is a data collection of approvers found for this transaction.<br> For further details review [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.print_condition := 'ALWAYS';
    l_sig.fail_type := 'I';
    l_sig.print_sql_output := 'RS';
    l_sig.limit_rows := 'N';

    RETURN process_signature_results(
      'Approvers_for_transaction',  -- sig ID
      l_sig,                 -- signature information
      l_col_rows,            -- data
      l_hdr);                -- headers

EXCEPTION WHEN OTHERS THEN
   print_log ('Exception in get_ame_approvers_for_trxn at step '||l_step);
   RETURN null;
END get_ame_approvers_for_trxn;



FUNCTION get_ame_approvers_invalid RETURN VARCHAR2 IS
type invalidApprRec is record(
                  roleName  varchar2(200),
                  origsystem varchar2(75),
                  source     varchar2(1000)
                  );
 type invApprList is table of invalidApprRec index by binary_integer;
 ame_invalappr invApprList;
 cursor getLMconditions is
    select condition_id,parameter_two
      from ame_conditions
     where condition_type ='post'
       and sysdate between start_date and nvl(end_date-(1/86400),sysdate);
  conditionIdList ame_util.idList;
  param_twoList   ame_util.stringList;
  inval_index   integer;
  cursor approvalGroupItemCursor is
  SELECT agr.approval_group_id, agi.parameter
    FROM ame_approval_group_config agf,
         ame_approval_groups agr,
         ame_approval_group_items agi
    WHERE agf.application_id = to_number(g_sql_tokens('##$$AMEAPPID$$##'))
    AND   agr.approval_group_id = agf.approval_group_id
    AND agi.approval_group_id = agr.approval_group_id
    AND   sysdate BETWEEN agr.start_date AND nvl(agr.end_date - (1/86400),sysdate)
    AND   sysdate BETWEEN agf.start_date AND nvl(agf.end_date - (1/86400),sysdate)
    AND   sysdate BETWEEN agi.start_date AND nvl(agi.end_date - (1/86400),sysdate)
	AND agi.parameter_name<>'OAM_group_id';

  groupIdList   ame_util.idList;
  groupParamsList    ame_util.longStringList;

  cursor configVarCursor is
  select cfg.variable_name
            ,cfg.variable_value "Value"
        from ame_config_vars cfg
       where cfg.application_id in (0, to_number(g_sql_tokens('##$$AMEAPPID$$##')))
         and sysdate between cfg.start_date and nvl(cfg.end_date - (1/86400),sysdate)
         and cfg.variable_name='adminApprover';
	variableNameList  ame_util.stringList;
    variableValueList ame_util.longStringList;

	wNameList ame_util.stringList;
	objectList      ame_util.stringList;
	objectIdTypeList    ame_util.stringList;
	objectIdList    ame_util.stringList;
	descrList      ame_util.stringList;
	wNameListIndex number;

	l_col_rows       COL_LIST_TBL := col_list_tbl(); -- Row values
   l_hdr            VARCHAR_TBL := varchar_tbl(); -- Column headings

   l_sig            SIGNATURE_REC;
   l_ame_approvers  ame_approvers_list;
   l_error          VARCHAR2(100);
   l_step           VARCHAR2(10);


function isexist(approverList in ame_util.stringList
                ,nameIn in varchar2)  return boolean as
begin
  for i in 1..approverList.count loop
    if approverList(i)= nameIn then
      return true;
    end if;
  end loop;
  return false;
end isexist;

 function checkDuplicate(expressionIn in varchar2) return boolean is
   inval_index number;
  begin
    inval_index := ame_invalappr.count;
    for i in  1..inval_index loop
      if trim(expressionIn)=trim(ame_invalappr(i).source)then
        return true;
      end if;
    end loop;
    return false;
  end ;

  function getActionDescription(actionIdIn in number)return varchar2 as
  actionTypeId  number;
  tempActionDescr varchar2(800);
  beforeColon   varchar2(800);
  afterColon    varchar2(800);
  wf_role_name  varchar2(200);
  inval_index   integer;
  begin
    tempActionDescr :=  ame_action_pkg.getDescription(actionIdIn);
    actionTypeId := ame_action_pkg.getActionTypeIdById(actionIdIn =>actionIdIn);
        if ame_action_pkg.getActionTypeName(actionTypeId) =ame_util.substitutionTypeName  then
          wf_role_name := ame_action_pkg.getParameter(actionIdIn);
          if ame_approver_type_pkg.validateApprover(wf_role_name) then
            null;
          else
           if checkDuplicate('actionId:'||actionIdIn)<> true then
            inval_index := ame_invalappr.count;
            ame_invalappr(inval_index+1).roleName := wf_role_name;
            ame_invalappr(inval_index+1).source   := 'actionId:'||actionIdIn;
            end if;
          end if;
        end if;
    return tempActionDescr;
    exception
      when others then
        return to_char(actionIdIn);
  end getActionDescription;

  procedure approverSource(approverNameIn in varchar2
                        ,objectOut      out ame_util.stringList
                        ,objectIdType   out ame_util.stringList
                        ,objectIdOut    out ame_util.stringList
                        ,descrOut       out ame_util.stringList)  is


appr_source varchar2(300);
before_colon varchar2(50);
after_colon  varchar2(50);
total_count  integer;
loc_count     integer;
tempDesc     varchar2(30);
descr        varchar2(100);
begin

  total_count := ame_invalappr.count;
  for i in 1..total_count loop
    if approverNameIn = ame_invalappr(i).roleName then
       appr_source := ame_invalappr(i).source;
       before_colon := substr(appr_source,1,instrb(appr_source,':')-1);
       after_colon := substr(appr_source,instrb(appr_source,':')+1,length(appr_source));
       loc_count := objectIdOut.count;
       loc_count := loc_count+1;
       if before_colon ='actionId' then
          objectOut(loc_count)    := ame_action_pkg.getActionTypeNameByActionId(to_number(after_colon))||' Action';
          objectIdType(loc_count) := 'Action Id';
          objectIdOut(loc_count)  := after_colon;
          descrOut(loc_count)     := ame_action_pkg.getDescription(actionIdIn =>to_number(after_colon));
       elsif before_colon ='APG' then
          objectOut(loc_count)    := 'Approval group';
          objectIdType(loc_count) := 'Approval Group Id';
          objectIdOut(loc_count)  := after_colon;
          descrOut(loc_count) := ame_approval_group_pkg.getName(approvalGroupIdIn => to_number(after_colon));

       elsif before_colon ='ADM'  then

         objectOut(loc_count)    := 'Configuration variable';
         objectIdType(loc_count) := 'Configuration variable Name';
         objectIdOut(loc_count)  :=  'Admin Approver';
         descrOut(loc_count)     := 'invalid : '||approverNameIn;

       elsif before_colon ='COND'  then
          descr := trim(ame_condition_pkg.getConditionType(to_number(after_colon)));
          if trim(descr) ='post' then
            tempDesc := 'List Modification';
          end if;
          objectOut(loc_count)    := 'Conditions:'||tempDesc;
          objectIdType(loc_count) := 'Condition Id';
          objectIdOut(loc_count)  := after_colon;
           descrOut(loc_count)    := ame_condition_pkg.getDescription(conditionIdIn =>to_number(after_colon));

       end if;
    end if;
    loc_count:=0;
  end loop;
end approverSource;

begin

  open getLMconditions;
  fetch getLMconditions bulk collect into conditionIdList,param_twoList;
  close getLMconditions;
  for i in 1..conditionIdList.count loop
	  if NOT ame_approver_type_pkg.validateApprover(param_twoList(i)) then
		  inval_index := ame_invalappr.count;
		  ame_invalappr(inval_index+1).roleName :=param_twoList(i);
		  ame_invalappr(inval_index+1).source :='COND: List Modification conditions:'||conditionIdList(i);

	  end if;
  end loop;


  open approvalGroupItemCursor;
        fetch approvalGroupItemCursor bulk collect
          into
            groupIdList
           ,groupParamsList;
        close approvalGroupItemCursor;
	for i in 1 .. groupIdList.count loop
            if NOT ame_approver_type_pkg.validateApprover(groupParamsList(i)) then
                inval_index := ame_invalappr.count;
                ame_invalappr(inval_index+1).roleName := groupParamsList(i);
                ame_invalappr(inval_index+1).source := 'APG: Approval Group:'||groupIdList(i);
				dbms_output.put_line(groupParamsList(i));
				dbms_output.put_line('Approval Group:'||groupIdList(i));
           end if;

     end loop;

	open configVarCursor;
    fetch configVarCursor bulk collect
      into
        variableNameList
       ,variableValueList;
    close configVarCursor;
	for i in 1 .. variableNameList.count loop
      if NOT ame_approver_type_pkg.validateApprover(variableValueList(i)) then
          inval_index := ame_invalappr.count;
          ame_invalappr(inval_index+1).roleName :=variableValueList(i);
          ame_invalappr(inval_index+1).source :='ADM:CONFIG';
       end if;
	end loop;

 for i in 1..ame_invalappr.count loop
    if  isexist(approverList => wNameList
                ,nameIn => ame_invalappr(i).roleName) <> true then
      wNameListIndex := wNameList.count;
      wNameList(wNameListIndex+1) :=  ame_invalappr(i).roleName;
    end if;
  end loop;

  -- Column headings
   l_step := '10';
   l_hdr.extend(4);
   l_hdr(1) := 'Object';
   l_hdr(2) := 'Object Key';
   l_hdr(3) := 'Object Id';
   l_hdr(4) := 'Object Description';

   l_step := '20';

  l_col_rows.extend(4);
   IF wNameList.COUNT > 0 THEN

			  for i in 1..wNameList.count loop
					approverSource(approverNameIn       => wNameList(i)
					,objectOut      => objectList
					,objectIdType   => objectIdTypeList
					,objectIdOut    => objectIdList
					,descrOut       => descrList);
					for j in 1..objectIdList.count loop
					   l_col_rows(1)(i) := objectList(j);
					   l_col_rows(2)(i) := objectIdTypeList(j);
					   l_col_rows(3)(i) := objectIdList(j);
					   l_col_rows(4)(i) := descrList(j);
					end loop;
			  end loop;
    ELSE
        print_log('get_ame_approvers_invalid: No invalid found!');
    END IF;


    l_sig.title := 'List of Invalid Approvers Existing in Current Setup ';
    l_sig.fail_condition := 'RS';
    l_sig.problem_descr := 'Invalid approvers found. '||l_sig.problem_descr;
    l_sig.solution := 'Review the AME configuration information to determine why there are invalid approvers.<br> Review [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.success_msg := 'No invalid approvers found. <br> For further details consult [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.print_condition := 'ALWAYS';
    l_sig.fail_type := 'W';
    l_sig.print_sql_output := 'Y';
    l_sig.limit_rows := 'Y';

    RETURN process_signature_results(
      'Invalid_approvers',  -- sig ID
      l_sig,                 -- signature information
      l_col_rows,            -- data
      l_hdr);                -- headers

EXCEPTION WHEN OTHERS THEN
   print_log ('Exception in get_ame_approvers_invalid at step '||l_step);
   RETURN null;
END get_ame_approvers_invalid;


---------------------------------------------------------
-- Get list of AME approvers (getAllApprovers7.sql) for a specific transaction -
---------------------------------------------------------
FUNCTION get_ame_approvers_for_trxn_2(p_trxn_id VARCHAR2) RETURN VARCHAR2 IS

   l_col_rows       COL_LIST_TBL := col_list_tbl(); -- Row values
   l_hdr            VARCHAR_TBL := varchar_tbl(); -- Column headings

   l_sig            SIGNATURE_REC;
   l_ame_approvers  ame_util.approversTable2;
   l_error          VARCHAR2(100);
   l_step           VARCHAR2(10);
   transactionTypeId varchar2(100);
   finish varchar2(20) := ame_util.booleanFalse;
   fndApplicationId integer ;

BEGIN

   -- Column headings
   l_step := '10';
   l_hdr.extend(12);
   l_hdr(1) := 'ID';
   l_hdr(2) := 'Approver';
   l_hdr(3) := 'Approver Order Number';
   l_hdr(4) := 'Item Class';
   l_hdr(5) := 'Item ID';
   l_hdr(6) := 'SL';
   l_hdr(7) := 'Action Type ID';
   l_hdr(8) := 'Group or Chain ID';
   l_hdr(9) := 'Approval Status';
   l_hdr(10) := 'Occurrence';
   l_hdr(11) := 'Member Order';
   l_hdr(12) := 'API insertion';


   l_step := '20';

   BEGIN

	   select aca.transaction_type_id into transactionTypeId
      from ame_calling_apps aca
       where aca.application_id = to_number(g_sql_tokens('##$$AMEAPPID$$##'))
         and sysdate between aca.start_date and nvl(aca.end_date - (1/86400),sysdate)
         and rownum<2;
	  select fnd_application_id
		   into  fndApplicationId
		   from ame_calling_apps
		  where transaction_type_id = transactionTypeId
			and sysdate between start_date and
					 nvl(end_date, sysdate);
	EXCEPTION WHEN OTHERS THEN
        print_log('get_ame_approvers_for_trxn: Error finding transaction type!');
        RETURN null;
   END;

   BEGIN

	   ame_api2.getAllApprovers7
			(applicationIdIn                => fndApplicationId
			,transactionTypeIn              => transactionTypeId
			,transactionIdIn                => p_trxn_id
			,approvalProcessCompleteYNOut   => finish
			,approversOut                   => l_ame_approvers);

   EXCEPTION WHEN OTHERS THEN
        print_log('get_ame_approvers_for_trxn: Error calling getAllApprovers7 API!');
        RETURN null;
   END;

   l_step := '30';
   l_col_rows.extend(12);

   IF l_ame_approvers.COUNT > 0 THEN
       FOR i IN l_ame_approvers.FIRST .. l_ame_approvers.LAST
       LOOP
           print_log(l_ame_approvers(i).name);
           l_step := '30.1';

		   l_col_rows(1)(i) := i;
           l_col_rows(2)(i) := l_ame_approvers(i).name    ;
           l_col_rows(3)(i) := l_ame_approvers(i).approver_order_number          ;
           l_col_rows(4)(i) := l_ame_approvers(i).item_class                ;
           l_col_rows(5)(i) := l_ame_approvers(i).item_id    ;
           l_col_rows(6)(i) := l_ame_approvers(i).authority                ;
           l_col_rows(7)(i) := l_ame_approvers(i).action_type_id                   ;
           l_col_rows(8)(i) := l_ame_approvers(i).group_or_chain_id         ;
           l_col_rows(9)(i) := l_ame_approvers(i).approval_status            ;
           l_col_rows(10)(i) := l_ame_approvers(i).occurrence          ;
           l_col_rows(11)(i) := l_ame_approvers(i).member_order_number                    ;
           l_col_rows(12)(i) := l_ame_approvers(i).api_insertion               ;


        END LOOP;
    ELSE
        print_log('get_ame_approvers_for_trxn: No rules found!');
    END IF;
    l_sig.title := 'Approvers (getAllApprovers7.sql) for Transaction ' || p_trxn_id;
    l_sig.fail_condition := 'NRS';
    l_sig.problem_descr := 'No approvers found. '||l_sig.problem_descr;
    l_sig.solution := 'Review the AME configuration information to determine why there are no approvers.<br> [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.success_msg := 'This is a data collection of approvers found for this transaction.<br> For further details review [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups';
    l_sig.print_condition := 'ALWAYS';
    l_sig.fail_type := 'I';
    l_sig.print_sql_output := 'RS';
    l_sig.limit_rows := 'N';

    RETURN process_signature_results(
      'Approvers_for_transaction_Development',  -- sig ID
      l_sig,                 -- signature information
      l_col_rows,            -- data
      l_hdr);                -- headers

EXCEPTION WHEN OTHERS THEN
   print_log ('Exception in get_ame_approvers_for_trxn_2 at step '||l_step);
   RETURN null;
END get_ame_approvers_for_trxn_2;


-------------------------
-- Recommended Patches
-------------------------

FUNCTION check_rec_patches_1 RETURN VARCHAR2 IS
  /* Signature AMEPATCH */
  l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
  l_rel_rows   COL_LIST_TBL := col_list_tbl(); -- Row release
  l_hdr        VARCHAR_TBL  := varchar_tbl(); -- Column headings
  l_app_date   DATE;         -- Patch applied date
  l_extra_info HASH_TBL_4K;  -- Extra information
  l_step       VARCHAR2(10);
  l_sig        SIGNATURE_REC;
  l_rel        VARCHAR2(3);
  l_rows       NUMBER := 0;

  CURSOR get_app_date(p_ptch VARCHAR2, p_rel VARCHAR2) IS
   SELECT min(Last_Update_Date) as date_applied
    FROM Ad_Bugs Adb
    WHERE Adb.Bug_Number like p_ptch
    AND ad_patch.is_patch_applied(p_rel, -1, adb.bug_number)!='NOT_APPLIED';

BEGIN

  print_log('Processing recommended patches signature: AMEPATCH (check_rec_patches_1)');

  -- Column headings
  l_step := '10';
  l_hdr.extend(5);
  l_hdr(1) := 'Patch';
  l_hdr(2) := 'Applied';
  l_hdr(3) := 'Date';
  l_hdr(4) := 'Name';
  l_hdr(5) := 'Note';
  l_col_rows.extend(5);
  l_rel_rows.extend(1);

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3962268';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.AME.A';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4433707';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.AME.A.RUP1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4428060';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.AME.B';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4873179';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.AME.B.RUP1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5708576';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.AME.B.RUP2';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5348050';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5889626';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5997203';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6196260';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6506440';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6835789';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7291407';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7644754';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '9349996';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.A.delta.8';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6658013';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.B';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7457049';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.B.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '8496475';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.B.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '9244273';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.B.delta.3';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10192272';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '16169916';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '14237507';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17028726';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17940182';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '18121271';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '19675586';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20030495';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.AME.C.delta.7';
   l_col_rows(5)(l_rows) := NULL;

END IF;

   l_extra_info('##SHOW_SQL##'):= 'Y';

   l_sig.sigrepo_id := '5535';
   l_sig.title := 'Approval Management Engine Patches';
   l_sig.fail_condition := '[Applied] = [No]';
   l_sig.problem_descr := 'Patches not applied.';
   l_sig.solution := 'Please review list above and schedule to apply any unappplied patches as soon as possible.<br>
For the most current recommendations, use the Patch Wizard or the Updates & Patches Tab in My Oracle Support.<br>
Further guidance can be found in the following documents:<br>
<ul>
<li>[1633974.2] How to Find EBS Patches and EBS Technology Patches</li>
<li>[976188.1] R11i / R12 : Patch Wizard Utility</li>
<li>[976688.2] Patch Wizard FAQ</li>
</ul>
Best Practice: Always ensure that you are on the latest code with all recommended patches applied. This will help avoid known issues, prevent potential data corruption and provide the latest
features and functionality. Having a proactive patching plan and periodic proactive patching process in place are the best ways to stay current.
';
   l_sig.success_msg := 'All verified patches are applied.<br>
For the most current recommendations, use the Patch Wizard or the Updates & Patches Tab in My Oracle Support.<br>
Further guidance can be found in the following documents:<br>
<ul>
<li>[1633974.2] How to Find EBS Patches and EBS Technology Patches</li>
<li>[976188.1] R11i / R12 : Patch Wizard Utility</li>
<li>[976688.2] Patch Wizard FAQ</li>
</ul>
Best Practice: Always ensure that you are on the latest code with all recommended patches applied. This will help avoid known issues, prevent potential data corruption and provide the latest
features and functionality. Having a proactive patching plan and periodic proactive patching process in place are the best ways to stay current.
';
   l_sig.print_condition := 'ALWAYS';
   l_sig.fail_type := 'W';
   l_sig.print_sql_output := 'Y';
   l_sig.limit_rows := 'Y';
   l_sig.extra_info := l_extra_info;
   l_sig.include_in_xml :='P';
   l_sig.version := '4';

   -- if snapshot is old, add message to the solution
   IF nvl(g_snap_days, 10) > 30 THEN
       l_sig.solution := l_sig.solution || '<br><br><b>ADADMIN</b>: Maintain Snapshot Information was executed more than 30 days ago.<br>It is recommended that AD Utilities (Adadmin) "Maintain Snapshot Information" is run periodically as key tools (Patch Wizard, ADPatch,etc) rely on this information being accurate and up-to-date.';
   END IF;

  -- Check if applied
  get_current_time(g_query_start_time);
  FOR i in 1..l_rows loop
    l_step := '40';
    OPEN get_app_date(l_col_rows(1)(i),l_rel_rows(1)(i));
    FETCH get_app_date INTO l_app_date;
    CLOSE get_app_date;
    l_col_rows(1)(i) := '{'||l_col_rows(1)(i)||'}';
    IF l_app_date is not null THEN
      l_step := '50';
      l_col_rows(2)(i) := 'Yes';
      l_col_rows(3)(i) := to_char(l_app_date);
    END IF;
  END LOOP;
  g_query_elapsed := stop_timer(g_query_start_time);
  debug(' Rows fetched: '||to_char(l_rows));

  -- Register
  l_step := '60';
  g_signatures('AMEPATCH') := l_sig;

  --Render
  l_step := '70';
  RETURN process_signature_results(
    'AMEPATCH',     -- sig ID
    l_sig,                              -- signature information
    l_col_rows,                         -- data
    l_hdr);                             -- headers

EXCEPTION WHEN OTHERS THEN
  print_log('Error in check_rec_patches_1 at step '||l_step);
  raise;
END check_rec_patches_1;

FUNCTION check_rec_patches_2 RETURN VARCHAR2 IS
  /* Signature RUP */
  l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
  l_rel_rows   COL_LIST_TBL := col_list_tbl(); -- Row release
  l_hdr        VARCHAR_TBL  := varchar_tbl(); -- Column headings
  l_app_date   DATE;         -- Patch applied date
  l_extra_info HASH_TBL_4K;  -- Extra information
  l_step       VARCHAR2(10);
  l_sig        SIGNATURE_REC;
  l_rel        VARCHAR2(3);
  l_rows       NUMBER := 0;

  CURSOR get_app_date(p_ptch VARCHAR2, p_rel VARCHAR2) IS
   SELECT min(Last_Update_Date) as date_applied
    FROM Ad_Bugs Adb
    WHERE Adb.Bug_Number like p_ptch
    AND ad_patch.is_patch_applied(p_rel, -1, adb.bug_number)!='NOT_APPLIED';

BEGIN

  print_log('Processing recommended patches signature: RUP (check_rec_patches_2)');

  -- Column headings
  l_step := '10';
  l_hdr.extend(5);
  l_hdr(1) := 'Patch';
  l_hdr(2) := 'Applied';
  l_hdr(3) := 'Date';
  l_hdr(4) := 'Name';
  l_hdr(5) := 'Note';
  l_col_rows.extend(5);
  l_rel_rows.extend(1);

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10124646';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6603330';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4719824';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '2803988';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.E';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '14040707';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.1';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7446767';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.1';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5881943';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.1';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '2968701';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.F';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '16169935';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.2';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '8337373';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.2';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5997278';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.2';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3116666';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.G';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17001123';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.3';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '9114911';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.3';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6196269';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.3';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3233333';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.H';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17050005';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.4';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10281212';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.4';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6494646';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.4';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3127777';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.I';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17909898';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.5';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3333633';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.J';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '13418800';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.5';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6610000';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.5';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '19193000';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.6';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '16000686';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.6';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7004477';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.6';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3500000';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HRMS_PF.K';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20000400';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.7';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '18004477';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.7';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7577660';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.7';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5055050';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.1';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21507777';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.8';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20000288';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.8';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '9301208';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.8';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5337777';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.2';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '22559919';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.9';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10281209';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.9';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6699770';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.3';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21980909';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.Delta.9';
   l_col_rows(5)(l_rows) := '[2113189.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7666111';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '9062727';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10015566';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '12807777';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '14488556';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.8';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24007222';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.delta.10';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '25026041';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.Delta.10';
   l_col_rows(5)(l_rows) := '[2233906.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17774746';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'HR_PF.K.RUP.9';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '25251133';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.11';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '27115060';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.delta.11';
   l_col_rows(5)(l_rows) := '[2372289.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '26787667';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.12';
   l_col_rows(5)(l_rows) := '[2181865.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '28669292';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.Delta.12';
   l_col_rows(5)(l_rows) := '[2526650.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '28862999';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.13';
   l_col_rows(5)(l_rows) := '[2495078.1]';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30096069';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.14';
   l_col_rows(5)(l_rows) := '[2656548.1]';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '31800665';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.15';
   l_col_rows(5)(l_rows) := '[2750056.1]';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '33527653';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.16';
   l_col_rows(5)(l_rows) := '[2862919.1]';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '34444470';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.C.Delta.17';
   l_col_rows(5)(l_rows) := '[2935957.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30066331';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.Delta.13';
   l_col_rows(5)(l_rows) := '[2656549.1]';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '32105001';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.B.Delta.14';
   l_col_rows(5)(l_rows) := '[2750077.1]';

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '13774477';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.10';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '16077077';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.HR_PF.A.delta.11';
   l_col_rows(5)(l_rows) := NULL;

END IF;

   l_extra_info('##SHOW_SQL##'):= 'Y';

   l_sig.sigrepo_id := '1329';
   l_sig.title := 'RUP Patches';
   l_sig.fail_condition := '[Applied] = [No]';
   l_sig.problem_descr := 'RUP patches not applied in this instance. <br>
HR_PF are cumulative patches.<br>
If you applied a higher version of HR_PF, you can ignore previous HR_PF patches. There is no need to apply previous patches.<br>
Oracle recommend you to be at latest version of HR_PF.';
   l_sig.solution := 'Note! If a patch was applied and the analyzer shows it as not applied, this can be caused by snapshot out of sync (run AD Utilities (Adadmin) "Maintain Snapshot Information" -> Update a current view snapshot -> Update Complete APPL_TOP).<br>
[1160507.1] Oracle E-Business Suite HCM Information Center - Consolidated HRMS Mandatory Patch List';
   l_sig.success_msg := 'Latest RUP patch applied.<br>
Please review known issues for latest RUP in:<br>
- 12.2: [2935950.1] Known Issues on Top of Patch 34444470 - R12.hr_pf.C.DELTA.17
- 12.2: [2862918.1] Known Issues on Top of Patch 33527653 - R12.hr_pf.C.DELTA.16
- 12.2: [2750035.1]  Known Issues on Top of Patch 31800665 - R12.hr_pf.C.DELTA.15<br>
- 12.2: [2656623.1] Known Issues on Top of Patch 30096069 - R12.HR_PF.C.DELTA.14 <br>
- 12.1: [2750078.1] Known Issues on Top of Patch 32105001 - R12.HR_PF.B.DELTA.14<br>
- 12.1: [2656621.1] Known Issues on Top of Patch 30066331 - R12.HR_PF.B.DELTA.13 <br>
- 12.0: [1538635.1] Known Issues on Top of Patch 16077077 - R12.hr_pf.A.DELTA.11<br>
- 11.5: [1636768.1] Known Issues on Top of Patch 17774746 - 11i.hr_pf.K.DELTA.9';
   l_sig.print_condition := 'ALWAYS';
   l_sig.fail_type := 'W';
   l_sig.print_sql_output := 'Y';
   l_sig.limit_rows := 'N';
   l_sig.extra_info := l_extra_info;
   l_sig.include_in_xml :='P';
   l_sig.version := '31';

   -- if snapshot is old, add message to the solution
   IF nvl(g_snap_days, 10) > 30 THEN
       l_sig.solution := l_sig.solution || '<br><br><b>ADADMIN</b>: Maintain Snapshot Information was executed more than 30 days ago.<br>It is recommended that AD Utilities (Adadmin) "Maintain Snapshot Information" is run periodically as key tools (Patch Wizard, ADPatch,etc) rely on this information being accurate and up-to-date.';
   END IF;

  -- Check if applied
  get_current_time(g_query_start_time);
  FOR i in 1..l_rows loop
    l_step := '40';
    OPEN get_app_date(l_col_rows(1)(i),l_rel_rows(1)(i));
    FETCH get_app_date INTO l_app_date;
    CLOSE get_app_date;
    l_col_rows(1)(i) := '{'||l_col_rows(1)(i)||'}';
    IF l_app_date is not null THEN
      l_step := '50';
      l_col_rows(2)(i) := 'Yes';
      l_col_rows(3)(i) := to_char(l_app_date);
    END IF;
  END LOOP;
  g_query_elapsed := stop_timer(g_query_start_time);
  debug(' Rows fetched: '||to_char(l_rows));

  -- Register
  l_step := '60';
  g_signatures('RUP') := l_sig;

  --Render
  l_step := '70';
  RETURN process_signature_results(
    'RUP',     -- sig ID
    l_sig,                              -- signature information
    l_col_rows,                         -- data
    l_hdr);                             -- headers

EXCEPTION WHEN OTHERS THEN
  print_log('Error in check_rec_patches_2 at step '||l_step);
  raise;
END check_rec_patches_2;

FUNCTION check_rec_patches_3 RETURN VARCHAR2 IS
  /* Signature ATGFORHCM */
  l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
  l_rel_rows   COL_LIST_TBL := col_list_tbl(); -- Row release
  l_hdr        VARCHAR_TBL  := varchar_tbl(); -- Column headings
  l_app_date   DATE;         -- Patch applied date
  l_extra_info HASH_TBL_4K;  -- Extra information
  l_step       VARCHAR2(10);
  l_sig        SIGNATURE_REC;
  l_rel        VARCHAR2(3);
  l_rows       NUMBER := 0;

  CURSOR get_app_date(p_ptch VARCHAR2, p_rel VARCHAR2) IS
   SELECT min(Last_Update_Date) as date_applied
    FROM Ad_Bugs Adb
    WHERE Adb.Bug_Number like p_ptch
    AND ad_patch.is_patch_applied(p_rel, -1, adb.bug_number)!='NOT_APPLIED';

BEGIN

  print_log('Processing recommended patches signature: ATGFORHCM (check_rec_patches_3)');

  -- Column headings
  l_step := '10';
  l_hdr.extend(5);
  l_hdr(1) := 'Patch';
  l_hdr(2) := 'Applied';
  l_hdr(3) := 'Date';
  l_hdr(4) := 'Name';
  l_hdr(5) := 'Note';
  l_col_rows.extend(5);
  l_rel_rows.extend(1);

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '19245366';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17909318';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '17007206';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '15890638';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '14222219';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '10110982';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '8919491';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.B.delta.3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7651091';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.B.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7307198';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.B.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6430106';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.B';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.0' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '7237006';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6594849';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6272680';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6077669';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5917344';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5907545';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A.delta.1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4461237';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.A';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '11.5' THEN
   l_rel := '11i';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '6241631';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5903765';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '5473858';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4676589';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP4';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4334965';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP3';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4125550';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP2';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '4017300';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H RUP1';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '3438354';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '11i.ATG_PF.H';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21900895';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.6';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24690680';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.DELTA.7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '28840844';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.Delta.8';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30399994';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.9';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '31856779';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'R12.ATG_PF.C.delta.10';
   l_col_rows(5)(l_rows) := NULL;

END IF;

   l_extra_info('##SHOW_SQL##'):= 'Y';

   l_sig.sigrepo_id := '1469';
   l_sig.title := 'ATG Patches';
   l_sig.fail_condition := '[Applied] = [No]';
   l_sig.problem_descr := 'ATG patches not applied in this instance.';
   l_sig.solution := 'Note! If a patch was applied and the analyzer shows it as not applied, this can be caused by snapshot out of sync (run AD Utilities (Adadmin) "Maintain Snapshot Information" -> Update a current view snapshot -> Update Complete APPL_TOP).<br>
Please review list above and schedule to apply unappplied patches as soon as possible.<br>
For the most current recommendations, use the Patch Wizard or the Updates & Patches Tab in My Oracle Support.<br>
Further guidance can be found in the following documents:<br>
<ul>
<li>[1633974.2] How to Find EBS Patches and EBS Technology Patches</li>
<li>[976188.1] R11i / R12 : Patch Wizard Utility</li>
<li>[976688.2] Patch Wizard FAQ</li>
</ul>
Best Practice: Always ensure that you are on the latest code with all recommended patches applied. This will help avoid known issues, prevent potential data corruption and provide the latest
features and functionality. Having a proactive patching plan and periodic proactive patching process in place are the best ways to stay current.
';
   l_sig.success_msg := 'All ATG verified patches applied.
For the most current recommendations, use the Patch Wizard or the Updates & Patches Tab in My Oracle Support.<br>
Further guidance can be found in the following documents:<br>
<ul>
<li>[1633974.2] How to Find EBS Patches and EBS Technology Patches</li>
<li>[976188.1] R11i / R12 : Patch Wizard Utility</li>
<li>[976688.2] Patch Wizard FAQ</li>
</ul>
Best Practice: Always ensure that you are on the latest code with all recommended patches applied. This will help avoid known issues, prevent potential data corruption and provide the latest
features and functionality. Having a proactive patching plan and periodic proactive patching process in place are the best ways to stay current.
';
   l_sig.print_condition := 'ALWAYS';
   l_sig.fail_type := 'W';
   l_sig.print_sql_output := 'Y';
   l_sig.limit_rows := 'N';
   l_sig.extra_info := l_extra_info;
   l_sig.include_in_xml :='P';
   l_sig.version := '12';

   -- if snapshot is old, add message to the solution
   IF nvl(g_snap_days, 10) > 30 THEN
       l_sig.solution := l_sig.solution || '<br><br><b>ADADMIN</b>: Maintain Snapshot Information was executed more than 30 days ago.<br>It is recommended that AD Utilities (Adadmin) "Maintain Snapshot Information" is run periodically as key tools (Patch Wizard, ADPatch,etc) rely on this information being accurate and up-to-date.';
   END IF;

  -- Check if applied
  get_current_time(g_query_start_time);
  FOR i in 1..l_rows loop
    l_step := '40';
    OPEN get_app_date(l_col_rows(1)(i),l_rel_rows(1)(i));
    FETCH get_app_date INTO l_app_date;
    CLOSE get_app_date;
    l_col_rows(1)(i) := '{'||l_col_rows(1)(i)||'}';
    IF l_app_date is not null THEN
      l_step := '50';
      l_col_rows(2)(i) := 'Yes';
      l_col_rows(3)(i) := to_char(l_app_date);
    END IF;
  END LOOP;
  g_query_elapsed := stop_timer(g_query_start_time);
  debug(' Rows fetched: '||to_char(l_rows));

  -- Register
  l_step := '60';
  g_signatures('ATGFORHCM') := l_sig;

  --Render
  l_step := '70';
  RETURN process_signature_results(
    'ATGFORHCM',     -- sig ID
    l_sig,                              -- signature information
    l_col_rows,                         -- data
    l_hdr);                             -- headers

EXCEPTION WHEN OTHERS THEN
  print_log('Error in check_rec_patches_3 at step '||l_step);
  raise;
END check_rec_patches_3;

FUNCTION check_rec_patches_4 RETURN VARCHAR2 IS
  /* Signature MOBILE_PATCH */
  l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
  l_rel_rows   COL_LIST_TBL := col_list_tbl(); -- Row release
  l_hdr        VARCHAR_TBL  := varchar_tbl(); -- Column headings
  l_app_date   DATE;         -- Patch applied date
  l_extra_info HASH_TBL_4K;  -- Extra information
  l_step       VARCHAR2(10);
  l_sig        SIGNATURE_REC;
  l_rel        VARCHAR2(3);
  l_rows       NUMBER := 0;

  CURSOR get_app_date(p_ptch VARCHAR2, p_rel VARCHAR2) IS
   SELECT min(Last_Update_Date) as date_applied
    FROM Ad_Bugs Adb
    WHERE Adb.Bug_Number like p_ptch
    AND ad_patch.is_patch_applied(p_rel, -1, adb.bug_number)!='NOT_APPLIED';

BEGIN

  print_log('Processing recommended patches signature: MOBILE_PATCH (check_rec_patches_4)');

  -- Column headings
  l_step := '10';
  l_hdr.extend(5);
  l_hdr(1) := 'Patch';
  l_hdr(2) := 'Applied';
  l_hdr(3) := 'Date';
  l_hdr(4) := 'Name';
  l_hdr(5) := 'Note';
  l_col_rows.extend(5);
  l_rel_rows.extend(1);

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '22465468';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 6.0: HRMS - 12.1 Consolidated Patch For Mobile Applications Foundation Release 6';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '22466221';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 6.0: HRMS - 12.2 Consolidated Patch For Mobile Applications Foundation Release 6';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24432372';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 6.0: EBS 12.26 SV8-OOW SDE: SMARTPHONE APPS DISAPPEAR DURING 12.2.6 UPGRADE';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '23634170';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 6.0: Oracle E-Business Suite Mobile Foundation Release 6.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24432372';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 6.0: EBS 12.26 SV8-OOW SDE: SMARTPHONE APPS DISAPPEAR DURING 12.2.6 UPGRADE';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '23634170';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 6.0: Oracle E-Business Suite Mobile Foundation Release 6.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21271187';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 5.0: HRMS - 12.1 Consolidated Patch For Mobile Applications Foundation RELEASE 5';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21270749';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 5.0: HRMS - 12.2 Consolidated Patch For Mobile Applications Foundation Release 5';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '22659481';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 5.0: Oracle E-Business Suite Mobile Foundation Release 5.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '22659481';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 5.0: Oracle E-Business Suite Mobile Foundation Release 5.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20518387';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 4.0: HR - 12.1 Consolidated Patch For Mobile Applications Foundation V4';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20843806';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 4.0: Install oneoff fix for Mobile 4.0 merge application';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '20518464';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 4.0:  HR - 12.2 Consolidated Patch For Mobile Applications Foundation V4';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21275035';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 4.0: Oracle E-Business Suite Mobile Foundation Release 4.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21275035';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 4.0: Oracle E-Business Suite Mobile Foundation Release 4.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21881376';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 4.0: CONSOLIDATED POST INSTALL PATCH FOR EBS MOBILE RELEASE 4.0';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '21881376';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 4.0: HR - 12.1 Consolidated Patch For Mobile Applications Foundation V5';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24383330';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 7.0: HRMS - 12.1 Consolidated Patch For Mobile Applications Foundation Release 7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '25486920';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 7.0: Oracle E-Business Suite 12.1 Consolidated Patch for Mobile release 7.0';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '26000442';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 7.0: ORACLE E-BUSINESS SUITE MOBILE FOUNDATION RELEASE 7.0 ONLINE HELP';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '26000442';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 7.0: ORACLE E-BUSINESS SUITE MOBILE FOUNDATION RELEASE 7.0 ONLINE HELP';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '24383538';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 7.0: HRMS - 12.2 Consolidated Patch For Mobile Applications Foundation Release 7';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '25486940';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 7.0: Oracle E-Business Suite 12.2 Consolidated Patch for Mobile release 7.0';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '26728771';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 8.0: HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '27678444';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.1 Release 8.0: Oracle E-Business Suite Mobile Foundation Release 8.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '28278350';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'CONFIGURING NEW JACKSON LIBRARIES FOR MOBILE PUSH NOTIFICATIONS';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '26728887';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 8.0: HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '27678444';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'Mobile Foundation 12.2 Release 8.0: Oracle E-Business Suite Mobile Foundation Release 8.0 Online Help';
   l_col_rows(5)(l_rows) := NULL;

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '28278350';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := 'CONFIGURING NEW JACKSON LIBRARIES FOR MOBILE PUSH NOTIFICATIONS';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30143992';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '9.1  HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30143992';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '9.1  HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.1' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30144049';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '9.0 HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

END IF;

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN
   l_rel := 'R12';

   l_rows := l_rows + 1;
   l_rel_rows(1)(l_rows) := l_rel;
   l_col_rows(1)(l_rows) := '30144049';
   l_col_rows(2)(l_rows) := 'No';
   l_col_rows(3)(l_rows) := NULL;
   l_col_rows(4)(l_rows) := '9.0 HR Container patch';
   l_col_rows(5)(l_rows) := NULL;

END IF;

   l_extra_info('##SHOW_SQL##'):= 'Y';

   l_sig.sigrepo_id := '5537';
   l_sig.title := 'Mobile Apps Patches';
   l_sig.fail_condition := '[Applied] = [No]';
   l_sig.problem_descr := 'Several patches are not available in ad tables.';
   l_sig.solution := 'Note! If a patch was applied and the analyzer shows it as not applied, this can be caused by snapshot out of sync (run AD Utilities (Adadmin) "Maintain Snapshot Information" -> Update a current view snapshot -> Update Complete APPL_TOP).<br>
If you are at latest patch, you can ignore the warning.<br>
Review [2018177.1] Oracle Mobile Person Directory for Oracle E-Business Suite Release Notes<br>
[1669224.1] Oracle Mobile Timecards for Oracle E-Business Suite Release Notes';
   l_sig.success_msg := 'All verified patches are applied as per [2105189.1] Oracle Mobile Self-Service Human Resources for Oracle E-Business Suite Release Notes<br>
[1669224.1] Oracle Mobile Timecards for Oracle E-Business Suite Release Notes';
   l_sig.print_condition := 'ALWAYS';
   l_sig.fail_type := 'W';
   l_sig.print_sql_output := 'Y';
   l_sig.limit_rows := 'Y';
   l_sig.extra_info := l_extra_info;
   l_sig.include_in_xml :='P';
   l_sig.version := '11';

   -- if snapshot is old, add message to the solution
   IF nvl(g_snap_days, 10) > 30 THEN
       l_sig.solution := l_sig.solution || '<br><br><b>ADADMIN</b>: Maintain Snapshot Information was executed more than 30 days ago.<br>It is recommended that AD Utilities (Adadmin) "Maintain Snapshot Information" is run periodically as key tools (Patch Wizard, ADPatch,etc) rely on this information being accurate and up-to-date.';
   END IF;

  -- Check if applied
  get_current_time(g_query_start_time);
  FOR i in 1..l_rows loop
    l_step := '40';
    OPEN get_app_date(l_col_rows(1)(i),l_rel_rows(1)(i));
    FETCH get_app_date INTO l_app_date;
    CLOSE get_app_date;
    l_col_rows(1)(i) := '{'||l_col_rows(1)(i)||'}';
    IF l_app_date is not null THEN
      l_step := '50';
      l_col_rows(2)(i) := 'Yes';
      l_col_rows(3)(i) := to_char(l_app_date);
    END IF;
  END LOOP;
  g_query_elapsed := stop_timer(g_query_start_time);
  debug(' Rows fetched: '||to_char(l_rows));

  -- Register
  l_step := '60';
  g_signatures('MOBILE_PATCH') := l_sig;

  --Render
  l_step := '70';
  RETURN process_signature_results(
    'MOBILE_PATCH',     -- sig ID
    l_sig,                              -- signature information
    l_col_rows,                         -- data
    l_hdr);                             -- headers

EXCEPTION WHEN OTHERS THEN
  print_log('Error in check_rec_patches_4 at step '||l_step);
  raise;
END check_rec_patches_4;




-------------------------
-- Signatures
-------------------------


PROCEDURE add_signature(
  p_sig_repo_id      VARCHAR2    DEFAULT '',        -- IF of the signature in Sig Repo
  p_sig_id           VARCHAR2,     -- Unique Signature identifier
  p_sig_sql          VARCHAR2,     -- The text of the signature query
  p_title            VARCHAR2,     -- Signature title
  p_fail_condition   VARCHAR2,     -- 'RSGT1' (RS greater than 1), 'RS' (row selected), 'NRS' (no row selected), '[count(*)] > [0]'
  p_problem_descr    VARCHAR2,     -- Problem description
  p_solution         VARCHAR2,     -- Problem solution
  p_success_msg      VARCHAR2    DEFAULT null,      -- Message on success
  p_print_condition  VARCHAR2    DEFAULT 'ALWAYS',  -- ALWAYS, SUCCESS, FAILURE, NEVER
  p_fail_type        VARCHAR2    DEFAULT 'W',       -- Warning(W), Error(E), Informational(I) is for use of data dump so no validation
  p_print_sql_output VARCHAR2    DEFAULT 'RS',      -- Y/N/RS - when to print data
  p_limit_rows       VARCHAR2    DEFAULT 'Y',       -- Y/N
  p_extra_info       HASH_TBL_4K DEFAULT CAST(null AS HASH_TBL_4K), -- Additional info
  p_child_sigs       VARCHAR_TBL DEFAULT VARCHAR_TBL(),
  p_include_in_dx_summary   VARCHAR2    DEFAULT 'N', -- This is for AT use so internal only. Set to Y if want signature result to be printed at end of output file in DX Summary section
  p_version          VARCHAR2    DEFAULT null)  -- Used for performance tracking over time
IS
    l_rec signature_rec;
    l_key varchar2(255);
    l_new_key varchar2(255);
BEGIN
    l_rec.sigrepo_id       := p_sig_repo_id;
    l_rec.sig_sql          := p_sig_sql;
    l_rec.title            := p_title;
    l_rec.fail_condition   := p_fail_condition;
    l_rec.problem_descr    := p_problem_descr;
    l_rec.solution         := p_solution;
    l_rec.success_msg      := p_success_msg;
    l_rec.print_condition  := p_print_condition;
    l_rec.fail_type        := p_fail_type;
    l_rec.print_sql_output := p_print_sql_output;
    l_rec.limit_rows       := p_limit_rows;
    l_rec.extra_info       := p_extra_info;
    l_rec.child_sigs       := p_child_sigs;
    l_rec.include_in_xml   := p_include_in_dx_summary;
    l_rec.version          := p_version;

    -- EBSAF-285 Internal key names must match resulting column names
    l_key := l_rec.extra_info.first;
    while l_key is not null loop
        if l_key like '##%' then
            l_new_key := substr( upper( replace(l_key, '|', '<br>') ), 1, 255);
            if l_new_key <> l_key then
                -- Create a copy of existing key
                l_rec.extra_info(l_new_key) := l_rec.extra_info(l_key);
            end if;
        end if;
        l_key :=  l_rec.extra_info.next(l_key);
    end loop;

    g_signatures(p_sig_id) := l_rec;
EXCEPTION WHEN OTHERS THEN
    print_log('Error in add_signature: '||p_sig_id);
    raise;
END add_signature;


FUNCTION run_stored_sig(p_sig_id varchar2) RETURN VARCHAR2 IS

  l_col_rows COL_LIST_TBL := col_list_tbl();
  l_col_hea  VARCHAR_TBL := varchar_tbl();
  l_sig      signature_rec;
  l_key      VARCHAR2(255);
  l_row_num  NUMBER;
  l_run_res  BOOLEAN;

BEGIN
  print_log('Processing signature: '||p_sig_id);
  -- Get the signature record from the signature table
  BEGIN
    l_sig := g_signatures(p_sig_id);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    print_log('No such signature '||p_sig_id||' error in run_stored_sig');
return 'E';
  END;

  -- Clear FK values if the sig has children
  IF l_sig.child_sigs.count > 0 THEN
    l_key := g_sql_tokens.first;
    WHILE l_key is not null LOOP
      IF l_key like '##$$FK_$$##' THEN
        g_sql_tokens.delete(l_key);
        g_masked_tokens.delete(l_key);  -- EBSAF-275
      END IF;
      l_key := g_sql_tokens.next(l_key);
    END LOOP;
  END IF;

  -- Run SQL
  l_run_res := run_sig_sql(p_sig_id, l_sig.sig_sql, l_col_rows, l_col_hea, l_sig.limit_rows);

  IF (l_run_res) THEN
      -- Evaluate and print
      RETURN process_signature_results(
           p_sig_id,               -- signature id
           l_sig,                  -- Name/title of signature item
           l_col_rows,             -- signature SQL row values
           l_col_hea);             -- signature SQL column names
   END IF;

   return 'E';
EXCEPTION WHEN OTHERS THEN
  print_log('Error in run_stored_sig procedure for sig_id: '||p_sig_id);
  print_log('Error: '||sqlerrm);
  print_error('PROGRAM ERROR<br>
    Error for sig '||p_sig_id||' '||sqlerrm||'<br>
    See the log file for additional details');
  return 'E';
END run_stored_sig;

--------------------------------------
-- Print argument validation errors --
--------------------------------------

PROCEDURE print_error_args(
  p_message      VARCHAR2 DEFAULT '',
  l_step         VARCHAR2 DEFAULT '')
IS
  l_key   VARCHAR2(255);
BEGIN
    print_log(p_message);
    print_log('Error in validate_parameters at step: ' || l_step);
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***');
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** '||p_message);
    dbms_output.put_line('Parameter Values');
    print_out('<div>');
    print_out('<br>'||p_message);
    print_out('<br>Error in validate_parameters at step: ' || l_step);
    print_out('<br><br><b>Parameter Values:</b><br><ul>');
    l_key := g_parameters.first;
    FOR i IN 1..g_parameters.COUNT LOOP
       dbms_output.put_line(to_char(i) || '. ' || g_parameters(i).pname || ': ' || g_parameters(i).pvalue);
       print_out('<li>' || to_char(i) || '. ' || g_parameters(i).pname || ': ' || g_parameters(i).pvalue || '</li>');
    END LOOP;
    dbms_output.put_line('Error in validate_parameters at step: ' || l_step);
    print_out('</ul>');
    print_out('<br><br><b>Execution Details:</b><br><ul>');
    l_key := g_rep_info.first;
    WHILE l_key IS NOT NULL LOOP
       print_out('<li>' || l_key || ': ' || g_rep_info(l_key) || '</li>');
       l_key := g_rep_info.next(l_key);
    END LOOP;
    print_out('</ul>');
    print_out('</div>');
END print_error_args;


--########################################################################################
--     Beginning of specific code of this ANALYZER
--########################################################################################

----------------------------------------------------------------
--- Validate Parameters                                      ---
----------------------------------------------------------------
PROCEDURE validate_parameters(
            p_AMEAPPID                     IN NUMBER      DEFAULT -1
           ,p_trxn_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 2000
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y')

IS

  l_revision                  VARCHAR2(25);
  l_date_char                 VARCHAR2(30);
  l_instance                  VARCHAR2(255);
  l_apps_version              VARCHAR2(255);
  l_host                      VARCHAR2(255);
  l_full_hostname             VARCHAR2(255);
  l_key                       VARCHAR2(255);
  l_system_function_var       VARCHAR2(2000);
  l_exists_val                VARCHAR2(2000);
  l_index                     NUMBER:=1;
  l_dbversion                 VARCHAR2(255);
  l_db_name                   VARCHAR2(255);
  l_step                      VARCHAR2(10);
  invalid_parameters EXCEPTION;
  invalid_escape EXCEPTION;

----------------------------------------------------------------
-- Analyzer-specific code: Validation Declarations            --
----------------------------------------------------------------
v_exists                             number;
l_date                                varchar2(30);
l_DBbanner                      VARCHAR2(255);



FUNCTION get_purged6
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: purged6');
select count(1)
     into v_exists
FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
AND PT.LANGUAGE = 'US' and
STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE 'PURGE CONCURRENT REQUEST%'
and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
and ACTUAL_COMPLETION_DATE>sysdate-180;
return v_exists;
debug('end sql token function: purged6');
END get_purged6;

FUNCTION get_security_check
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: security_check');
SELECT count(1) into v_exists
  FROM user_tab_columns
 WHERE lower(table_name) = 'per_security_profiles_v'
 and lower(column_name) = 'view_all_candidates_flag';
return v_exists;
debug('end sql token function: security_check');
END get_security_check;

FUNCTION get_purged1
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: purged1');
select count(1)
     into v_exists
FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
AND PT.LANGUAGE = 'US' and
STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE 'PURGE CONCURRENT REQUEST%'
and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
and ACTUAL_COMPLETION_DATE>sysdate-30;
return v_exists;
debug('end sql token function: purged1');
END get_purged1;

FUNCTION get_profile_defer
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: profile_defer');
select count(1) into v_exists from fnd_profile_options po, fnd_profile_option_values pov
where po.profile_option_name ='HR_DEFER_UPDATE' and pov.level_id='10001'
and pov.application_id = po.application_id and pov.profile_option_id = po.profile_option_id
and pov.profile_option_value='Y';
return v_exists;
debug('end sql token function: profile_defer');
END get_profile_defer;

FUNCTION get_LDATE
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: LDATE');
 SELECT  LAST_UPDATE_DATE into l_date from
(select '12.2' release , LAST_UPDATE_DATE
                  FROM ad_bugs
                  WHERE BUG_NUMBER =(SELECT to_char(max(to_number(adb.bug_number)))  FROM ad_bugs adb
WHERE adb.bug_number in ('34444470','33527653','31800665','30096069','28862999','26787667','25251133','24007222','22559919','21507777','20000400','19193000','17909898','17050005','17001123','16169935','14040707','10124646'))
and rownum < 2
union
select '12.1' release , LAST_UPDATE_DATE
                  FROM ad_bugs
                  WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN ('32105001','30066331','28669292','27115060','25026041','21980909','20000288','18004477','16000686','13418800','10281212','9114911','8337373', '7446767', '6603330'))
and rownum < 2
union
SELECT '12.0' release , LAST_UPDATE_DATE
                  FROM ad_bugs
                  WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN ('16077077','13774477','10281209','9301208','7577660', '7004477', '6610000', '6494646', '6196269', '5997278', '5881943', '4719824'))
and rownum < 2
union
SELECT '11.5' release ,LAST_UPDATE_DATE
                          FROM ad_bugs
                          WHERE BUG_NUMBER = (select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN ('2803988','2968701','3116666','3233333','3127777','3333633','3500000','5055050','5337777','6699770','7666111','9062727','10015566','12807777','14488556','17774746'))
and rownum < 2
)
where release in (select substr(release_name,1,4) from fnd_product_groups);
return l_date;
EXCEPTION WHEN others THEN
return null;
debug('end sql token function: LDATE');
END get_LDATE;

FUNCTION get_security_check3
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: security_check3');
SELECT count(1) into v_exists
  FROM user_tab_columns
 WHERE lower(table_name) = 'per_security_profiles_v'
 and lower(column_name) = 'profile_type';
return v_exists;
debug('end sql token function: security_check3');
END get_security_check3;



BEGIN

  l_step := '1';

  print_log(analyzer_title || ' Log File');
  print_log('***************************************************************');

  -- Create global hash for parameters. Numbers required for the output order
debug('begin populate parameters hash table');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Application ID';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_AMEAPPID,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Transaction ID';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_trxn_id,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Maximum Rows to Display';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_max_output_rows,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Debug Mode';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_debug_mode,'NO_MASK');
debug('end populate parameters hash table');



  l_key := g_parameters.first;
  -- Print parameters to the log
  print_log(chr(10)||'Parameter Values before validation:');
  print_log('---------------------------');

  FOR i IN 1..g_parameters.COUNT LOOP
    print_log(to_char(i) || '. ' || g_parameters(i).pname || ': ' || g_parameters(i).pvalue);
  END LOOP;
  print_log('---------------------------');

  BEGIN

    SELECT max(release_name) INTO l_apps_version
    FROM fnd_product_groups;

    begin
        -- Try to get version using new 19c method
        execute immediate 'select instance_name, host_name, version_full, sys_context(''USERENV'',''DB_NAME'') FROM v$instance'
            into l_instance, l_host, l_dbversion, l_db_name;
    exception when others then
        -- Get version using old method
        SELECT instance_name, host_name, version, sys_context('USERENV','DB_NAME')
        INTO l_instance, l_host, l_dbversion, l_db_name
        FROM v$instance;
    end;
    l_host := nvl(l_host, sys_context('USERENV','SERVER_HOST'));
    l_instance := nvl(l_instance, sys_context('USERENV','INSTANCE_NAME'));

  EXCEPTION WHEN OTHERS THEN
    print_log('Error in validate_parameters gathering instance information: '
      ||sqlerrm);
    raise;
  END;

  l_step := '2';
  BEGIN
    SELECT distinct domain
    INTO l_full_hostname
    FROM (SELECT db_domain AS domain
            FROM fnd_databases
          UNION ALL
          SELECT domain AS domain
          FROM fnd_nodes) domains WHERE domains.domain IS NOT NULL and rownum = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_full_hostname := NULL;
        WHEN OTHERS    THEN
          print_log('Error in validate_parameters gathering instance information: '
          ||sqlerrm);
    END;

  l_step := '3';
-- Revision and date values can be populated by RCS
  l_revision := rtrim(replace('$Revision: 200.28  $','$',''));
  l_revision := ltrim(replace(l_revision,'Revision:',''));
  l_date_char := rtrim(replace('$Date: 2023/06/23 12:44:18 $','$',''));
  l_date_char := ltrim(replace(l_date_char,'Date:',''));
  l_date_char := to_char(to_date(l_date_char,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');

  l_step := '4';
-- Create global hash for mapping internal result codes (E, W, S, I) to user friendly result codes (error, warning, successful, information)
  g_result('E') := 'error';
  g_result('W') := 'warning';
  g_result('S') := 'success';
  g_result('I') := 'info';

  l_step := '5';
-- Create global hash for report information
-- Do not report host details (EBSAF-274); reverted by EBSAF-293
  g_rep_info('Host') := regexp_substr(l_host, '^[^.]+');
  -- the host name might already be fully qualified, need to check if it includes the domain before appending it
  IF (l_host LIKE '%.%') THEN
       g_rep_info('FullHost') := l_host;
  ELSE
       g_rep_info('FullHost') := l_host || '.' || l_full_hostname;
  END IF;
  l_step := '6';
  g_rep_info('Instance') := l_instance;
  g_rep_info('DB Name') := l_db_name;
  g_rep_info('DB Version') := l_dbversion;
  g_rep_info('Apps Version') := l_apps_version;
  g_rep_info('File Name') := 'ame_analyzer.sql';
  g_rep_info('File Version') := l_revision;
  g_rep_info('Framework Version') := RTRIM(g_framework_version, ' ');
  g_rep_info('Execution Date') := to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
  g_rep_info('Description') := ('The ' || analyzer_title || ' <a href="' || g_mos_km_url || '2332426.1" target="_blank">(Note 2332426.1)</a> ' || ' is a self-service health-check script that reviews the overall footprint, analyzes current configurations and settings for the environment and provides feedback and recommendations on best practices. Your application data is not altered in any way when you run this analyzer.');

  l_step := '7';
  IF (g_is_concurrent) THEN
     populate_user_details();
  END IF;

  ------------------------------------------------------------------------------
  -- NOTE: Add code here for validation to the parameters of your diagnostic
  ------------------------------------------------------------------------------
  l_step := '8';


  g_max_output_rows := nvl(p_max_output_rows,20);
  g_debug_mode := nvl(p_debug_mode, 'Y');

debug('begin parameter validation: p_AMEAPPID');
IF p_AMEAPPID IS NULL THEN
   print_error('INVALID ARGUMENT: Parameter Application ID is required.');
   raise invalid_parameters;
END IF;
IF p_AMEAPPID IS NOT NULL THEN
BEGIN
SELECT APPLICATION_ID
INTO l_exists_val
FROM AME_CALLING_APPS
WHERE APPLICATION_ID = p_AMEAPPID
 AND sysdate between start_date and nvl(end_date, sysdate)
 and rownum < 2;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   print_error('INVALID ARGUMENT: Incorrect application_ID. Please note that the AME Internal ID (Application ID) is usually a negative integer. Review instructions in Note 2332426.1 to take the application id.
');
   raise invalid_parameters;
   WHEN OTHERS THEN
   print_error('INVALID ARGUMENT: Validation query for p_AMEAPPID failed with '||sqlerrm||'.');
   raise invalid_parameters;
END;
END IF;
debug('end parameter validation: p_AMEAPPID');



debug('begin parameter validation: p_debug_mode');
IF p_debug_mode IS NOT NULL AND p_debug_mode NOT IN ( 'N','Y') THEN
   print_error('INVALID ARGUMENT: Debug Mode is invalid.  Valid values are Y or N');
   raise invalid_parameters;
END IF;
debug('end parameter validation: p_debug_mode');



-- Validation to verify analyzer is run on proper e-Business application version
-- In case validation at the beginning is updated/removed, adding validation here also so execution fails

  IF substr(l_apps_version,1,4) NOT IN ('11.5','12.0','12.1','12.2') THEN
    print_log('eBusiness Suite version = '||l_apps_version);
    print_log('ERROR: This Analyzer script is compatible for following version(s): 11i,12.0,12.1,12.2');
    raise invalid_parameters;
  END IF;

-- .log enhancements (ER # 140)
  print_log(chr(10)||'Instance Information:');
  print_log('---------------------------');
  -- Do not report host details (EBSAF-274); reverted by EBSAF-293
  print_log('Host: '||g_rep_info('Host'));
  print_log('FullHost: '||g_rep_info('FullHost'));
  print_log('Instance: '||g_rep_info('Instance'));
  print_log('Database name: '||g_rep_info('DB Name'));
  print_log('Database version: '||g_rep_info('DB Version'));
  print_log('Applications version: '||g_rep_info('Apps Version'));
  print_log('Analyzer version: '||g_rep_info('File Version'));
  -- Report call details for troubleshooting (EBSAF-265)
  print_log('Calling method: '||g_rep_info('Calling From') );
  print_log('Calling module: '||g_rep_info('Calling Module') );
  print_log('---------------------------');

  -- Log session details (EBSAF-308)
  l_step := '8.5';
  print_log(chr(10)||'Session Information:');
  print_log('---------------------------');
  print_log('Language Code: '||sys_context('USERENV', 'LANG'));
  print_log('Region: '||sys_context('USERENV', 'NLS_TERRITORY'));
  print_log('Locale: '||sys_context('USERENV', 'LANGUAGE'));
  print_log('Date Format: '||sys_context('USERENV', 'NLS_DATE_FORMAT'));
  -- Get number characters
  select max(value) into l_system_function_var from v$parameter where name = 'nls_numeric_characters';
  print_log('Number Characters: '||l_system_function_var);
  -- Check for language installation
  begin
    execute immediate 'select max(installed_flag) from FND_LANGUAGES where language_code = sys_context(''USERENV'', ''LANG'')' into l_system_function_var;
    if (l_system_function_var is null or l_system_function_var not in ('B', 'I')) then
      print_log('WARNING: FND_LANGUAGES shows the session language is not installed.');
      print_log('Signatures relying on translation information may have incorrect results.');
    end if;
  exception when others then
    print_log('WARNING: Failed to check FND_LANGUAGES if session language is installed.');
  end;
  print_log('---------------------------');

  -- Verify escape character is set properly (EBSAF-265)
  l_step := '9';
  IF regexp_replace('Replace Test', '\s', '*') <>
     regexp_replace('Replace Test', chr(92) || 's', '*') THEN
    print_log('Invalid Escape:  Expected "' || chr(92) || 's' ||'" Received "\s"');
    print_log('Backslash character was not escaped properly during installation or execution.');
    raise invalid_escape;
  END IF;

  l_step := '10';
----------------------------------------------------------------
-- Analyzer-specific code: Additional Validation              --
----------------------------------------------------------------
debug('begin Additional Code: Additional Validation');
execute immediate 'alter session set NLS_DATE_FORMAT = ''DD-MON-YYYY HH24:MI''';
select count(*) into g_invalids
FROM dba_objects
WHERE status = 'INVALID' and object_type != 'UNDEFINED';

    /* SEEDED EBS BANNER BEGIN */

    -- Premier Support Checks by priority
    select min(error_type) into l_system_function_var from (
        -- Database in Sustaining Support
        select 1 error_type from V$VERSION WHERE banner like '%11.2%' or banner like '%11.1%' or banner like '%10.%'
        union
        -- Application Version 11.5
        select 2 error_type from fnd_product_groups where release_name like '11.5%'
        union
        -- Application Version 12.1
        select 3 error_type from fnd_product_groups where release_name like '12.1%'
        union
        -- Database in Extended Support
        select 4 error_type from V$VERSION WHERE banner like '%12.1%'
        union
        -- Application Version 12.0
        select 5 error_type from fnd_product_groups where release_name like '12.0%'
    );

    -- Set banner message by error type
    case l_system_function_var
        when 1 then
            -- Database in Sustaining Support
            g_banner_severity := 'W';
            g_banner_message := 'The database version running on this instance is in Sustaining Support. Please refer to Oracle''s Lifetime Support Policy in [2655839.2#supportp].<br>Ignore this warning if you have upgraded since this analyzer output was generated.';
        when 2 then
            -- Application Version 11.5
            g_banner_severity := 'W';
            g_banner_message := 'Premier Support for the application version on this instance ended on November 2010. Please refer to Oracle''s Lifetime Support Policy in [2655839.2#supportp].<br> Ignore this warning if you have upgraded since this analyzer output was generated.';
        when 3 then
            -- Application Version 12.1
            g_banner_severity := 'W';
            g_banner_message := 'Premier Support End for the application version on this instance is on December 2021. Please refer to Oracle''s Lifetime Support Policy in [2655839.2#supportp]. <br>Ignore this warning if you have upgraded since this analyzer output was generated.';
        when 4 then
            -- Database in Extended Support
            g_banner_severity := 'W';
            g_banner_message := 'The database version running on this instance is in Extended Support. Please refer to Oracle''s Lifetime Support Policy in [2655839.2#supportp].<br>Ignore this warning if you have upgraded since this analyzer output was generated.';
        when 5 then
            -- Application Version 12.0
            g_banner_severity := 'W';
            g_banner_message := 'Premier Support for the application version on this instance ended on January 2012. Please refer to Oracle''s Lifetime Support Policy in [2655839.2#supportp].<br>Ignore this warning if you have upgraded since this analyzer output was generated.';
        else
            -- No banner required
            g_banner_message := null;
    end case;
    /* SEEDED EBS BANNER END */

--Accomodations for 19C DB
g_db_version    := l_dbversion;

select CASE
WHEN g_db_version > '18'
THEN 'banner_full'
Else 'banner'
END into l_DBbanner from dual where rownum=1;

g_DBbanner := l_DBbanner;
--Accomodations for 19C DBdebug('end Additional Code: Additional Validation');



  g_parameters.DELETE;

  -- Recreate global hash for parameters after validation (includes the modifiers)
debug('begin populate parameters hash table');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Application ID';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_AMEAPPID,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Transaction ID';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_trxn_id,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Maximum Rows to Display';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_max_output_rows,'NO_MASK');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Debug Mode';
   g_parameters(g_parameters.LAST).pvalue := mask_text(p_debug_mode,'NO_MASK');
debug('end populate parameters hash table');



  l_key := g_parameters.first;
  -- Print parameters to the log
  l_step := '11';
  print_log(chr(10)||'Parameter Values after validation:');
  print_log('---------------------------');

  FOR i IN 1..g_parameters.COUNT LOOP
    print_log(to_char(i) || '. ' || g_parameters(i).pname || ': ' || g_parameters(i).pvalue);
  END LOOP;
  print_log('---------------------------');

  -- Create global hash of SQL token values
debug('begin populate sql tokens hash table');
   g_sql_tokens('##$$AMEAPPID$$##') := p_AMEAPPID;
   g_masked_tokens('##$$AMEAPPID$$##') := mask_text( g_sql_tokens('##$$AMEAPPID$$##'), 'NO_MASK');
   g_sql_tokens('##$$TRID$$##') := p_trxn_id;
   g_masked_tokens('##$$TRID$$##') := mask_text( g_sql_tokens('##$$TRID$$##'), 'NO_MASK');
   g_sql_tokens('##$$purged6$$##') := get_purged6();
   l_system_function_var := null;
   g_masked_tokens('##$$purged6$$##') := mask_text( g_sql_tokens('##$$purged6$$##'), 'NO_MASK');
   g_sql_tokens('##$$security_check$$##') := get_security_check();
   l_system_function_var := null;
   g_masked_tokens('##$$security_check$$##') := mask_text( g_sql_tokens('##$$security_check$$##'), 'NO_MASK');
   g_sql_tokens('##$$purged1$$##') := get_purged1();
   l_system_function_var := null;
   g_masked_tokens('##$$purged1$$##') := mask_text( g_sql_tokens('##$$purged1$$##'), 'NO_MASK');
   g_sql_tokens('##$$profile_defer$$##') := get_profile_defer();
   l_system_function_var := null;
   g_masked_tokens('##$$profile_defer$$##') := mask_text( g_sql_tokens('##$$profile_defer$$##'), 'NO_MASK');
   g_sql_tokens('##$$LDATE$$##') := get_LDATE();
   l_system_function_var := null;
   g_masked_tokens('##$$LDATE$$##') := mask_text( g_sql_tokens('##$$LDATE$$##'), 'NO_MASK');
   g_sql_tokens('##$$security_check3$$##') := get_security_check3();
   l_system_function_var := null;
   g_masked_tokens('##$$security_check3$$##') := mask_text( g_sql_tokens('##$$security_check3$$##'), 'NO_MASK');
debug('end populate sql tokens hash table');



  l_key := g_masked_tokens.first;
  -- Print token values to the log

  -- if max rows param is not set and does not have a default, g_max_output_rows might end up being -1. We don't want that.
  IF (g_max_output_rows <= 0) THEN
     print_log ('Max rows was not set and there is no default value for it. Defaulting to 20.');
     g_max_output_rows := 20;
  END IF;

  l_step := '12';
  print_log('SQL Token Values');

  WHILE l_key IS NOT NULL LOOP
    -- Ensure tokens do not contain invalid characters (EBSAF-263)
    g_sql_tokens(l_key) := filter_html(g_sql_tokens(l_key), 'I', 'D' );
    g_masked_tokens(l_key) := filter_html(g_masked_tokens(l_key), 'I', 'D' );

    -- Allow tokens to be masked in log (EBSAF-275)
    print_log(l_key||': '|| g_masked_tokens(l_key));
    l_key := g_masked_tokens.next(l_key);
  END LOOP;

EXCEPTION
  WHEN INVALID_PARAMETERS THEN
    print_error_args('Invalid parameters provided. Process cannot continue.', l_step);
    raise;
  WHEN INVALID_ESCAPE THEN
    print_error('INVALID ESCAPE: Regular expression search results are incorrect.' ||
        ' Calling method "' || g_rep_info('Calling From') || '" module "' || g_rep_info('Calling Module') || '".' );
    raise;
  WHEN OTHERS THEN
    print_error_args('Error validating parameters: '||sqlerrm, l_step);
    raise;
END validate_parameters;


---------------------------------------------
-- Load signatures for this ANALYZER       --
---------------------------------------------
PROCEDURE load_signatures IS
  l_info  HASH_TBL_4K;
BEGIN

null;

   -----------------------------------------
  -- Add definition of signatures here ....
  ------------------------------------------


debug('begin add_signature: OVERVIEWHCM');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1661',
      p_sig_id                 => 'OVERVIEWHCM',
      p_sig_sql                => 'select ''Instance Name = ''|| upper(instance_name)||''  ''|| sys_context(''USERENV'',''DB_NAME'') "Instance Summary" from v$instance
                                union
                    select ''Workflow version           = ''|| TEXT FROM WF_RESOURCES WHERE TYPE = ''WFTKN'' AND NAME = ''WF_VERSION''
        AND LANGUAGE = ''US''
                  union
                                select ''Applications           = ''|| release_name from fnd_product_groups
                                union
                                select ''Instance Creation Date = '' || created from v$database
                                union
                                select ''Database               = '' || '||mask_text(g_DBbanner, nvl( upper(''), 'NO_MASK') )||' db_version from v$version where rownum = 1
                                union
                                                                                select ''Platform               = '' || SUBSTR(REPLACE(REPLACE(pcv1.product, ''TNS for ''), '':'' )||pcv2.status, 1, 80)
                    FROM product_component_version pcv1,product_component_version pcv2  WHERE UPPER(pcv1.product) LIKE ''%TNS%'' AND UPPER(pcv2.product) LIKE ''%ORACLE%'' AND ROWNUM = 1
                    union
                    select ''Language               = '' || VALUE FROM V$NLS_PARAMETERS WHERE parameter = ''NLS_LANGUAGE''
                    union
                    select ''Character Set          = '' || VALUE FROM V$NLS_PARAMETERS WHERE parameter = ''NLS_CHARACTERSET''
                                union
                                SELECT ''Product status: PER/HR = '' || L.MEANING
                  FROM   fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
                  WHERE (b.APPLICATION_ID = I.APPLICATION_ID) AND b.application_id = t.application_id
                                AND (b.APPLICATION_ID = ''800'')
                                AND (L.LOOKUP_TYPE = ''FND_PRODUCT_STATUS'')
                                AND (L.LOOKUP_CODE = I.Status)
                                AND t.language = ''US''    AND l.language = ''US''
                                union
                  SELECT ''Product status: PAY    = '' || L.MEANING
                  FROM   fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
                  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)
                    AND b.application_id = t.application_id
                                AND (b.APPLICATION_ID = ''801'')
                                AND (L.LOOKUP_TYPE = ''FND_PRODUCT_STATUS'')
                                AND (L.LOOKUP_CODE = I.Status)
                                AND t.language = ''US''    AND l.language = ''US''
                                union
                  SELECT ''Multi Org              = '' || MULTI_ORG_FLAG FROM FND_PRODUCT_GROUPS
                                union
                  SELECT ''Multi Currency         = '' || MULTI_CURRENCY_FLAG FROM FND_PRODUCT_GROUPS
                  union
                  SELECT ''RUP Level = ''|| RUP_LEVEL || '' applied on '' || LAST_UPDATE_DATE from
(select ''12.2'' release , DECODE(bug_number
,''17001123'', ''17001123 R12.HR_PF.C.delta.3''
, ''16169935'', ''16169935 R12.HR_PF.C.delta.2''
,''14040707'', ''14040707 R12.HR_PF.C.delta.1''
,''10124646'', ''10124646 R12.HR_PF.C''
,''17050005'', ''17050005 R12.HR_PF.C.Delta.4''
,''17909898'', ''17909898 R12.HR_PF.C.delta.5''
,''19193000'', ''19193000 R12.HR_PF.C.Delta.6''
,''20000400'', ''20000400 R12.HR_PF.C.Delta.7''
,''21507777'', ''21507777 R12.HR_PF.C.Delta.8''
,''22559919'', ''22559919 R12.HR_PF.C.Delta.9''
,''24007222'', ''24007222 R12.HR_PF.C.Delta.10''
,''25251133'', ''25251133 R12.HR_PF.C.Delta.11''
,''26787667'', ''26787667 R12.HR_PF.C.Delta.12''
,''28862999'', ''28862999 R12.HR_PF.C.Delta.13''
,''30096069'', ''30096069 R12.HR_PF.C.Delta.14''
,''31800665'' , ''31800665 R12.HR_PF.C.Delta.15''
,''33527653'', ''33527653 R12.HR_PF.C.Delta.16''
,''34444470'', ''34444470 R12.HR_PF.C.Delta.17''
) RUP_LEVEL , LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(SELECT to_char(max(to_number(adb.bug_number))) FROM ad_bugs adb
WHERE adb.bug_number in (''34444470'', ''33527653'',''31800665'', ''30096069'',''28862999'',''26787667'',''25251133'',''24007222'',''22559919'',''21507777'',''20000400'',''19193000'',''17909898'',''17050005'',''17001123'',''16169935'',''14040707'',''10124646''))
and rownum < 2
union
select ''12.1'' release ,DECODE(BUG_NUMBER
,''32105001'',''32105001 R12.HR_PF.B.Delta.14''
,''30066331'',''30066331 R12.HR_PF.B.Delta.13''
,''28669292'',''28669292 R12.HR_PF.B.Delta.12''
,''27115060'',''27115060 R12.HR_PF.B.Delta.11''
,''25026041'',''25026041 R12.HR_PF.B.Delta.10''
,''21980909'',''21980909 R12.HR_PF.B.Delta.9''
,''20000288'',''20000288 R12.HR_PF.B.delta.8''
,''18004477'', ''18004477 R12.HR_PF.B.delta.7''
,''16000686'', ''16000686 R12.HR_PF.B.delta.6''
, ''13418800'', ''13418800 R12.HR_PF.B.delta.5''
,''10281212'', ''10281212 R12.HR_PF.B.delta.4''
,''9114911'', ''9114911 R12.HR_PF.B.delta.3''
,''8337373'', ''8337373 R12.HR_PF.B.delta.2''
,''7446767'', ''7446767 R12.HR_PF.B.delta.1''
,''6603330'', ''6603330 R12.HR_PF.B''
) RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''32105001'',''30066331'',''28669292'',''27115060'',''25026041'',''21980909'',''20000288'',''18004477'',''16000686'',''13418800'',''10281212'',''9114911'',''8337373'', ''7446767'', ''6603330''))
and rownum < 2
union
SELECT ''12.0'' release ,DECODE(BUG_NUMBER
, ''16077077'', ''16077077 R12.HR_PF.A.delta.11''
, ''13774477'', ''13774477 R12.HR_PF.A.delta.10''
, ''10281209'', ''10281209 R12.HR_PF.A.delta.9''
, ''9301208'', ''9301208 R12.HR_PF.A.delta.8''
, ''7577660'', ''7577660 R12.HR_PF.A.delta.7''
, ''7004477'', ''7004477 R12.HR_PF.A.delta.6''
, ''6610000'', ''6610000 R12.HR_PF.A.delta.5''
, ''6494646'', ''6494646 R12.HR_PF.A.delta.4''
, ''6196269'', ''6196269 R12.HR_PF.A.delta.3''
, ''5997278'', ''5997278 R12.HR_PF.A.delta.2''
, ''5881943'', ''5881943 R12.HR_PF.A.delta.1''
, ''4719824'', ''4719824 R12.HR_PF.A'') RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''16077077'',''13774477'',''10281209'',''9301208'',''7577660'', ''7004477'', ''6610000'', ''6494646'', ''6196269'', ''5997278'', ''5881943'', ''4719824''))
and rownum < 2
union
SELECT ''11.5'' release ,DECODE(BUG_NUMBER
, ''2803988'', ''2803988 HRMS_PF.E''
, ''2968701'', ''2968701 HRMS_PF.F''
, ''3116666'', ''3116666 HRMS_PF.G''
, ''3233333'', ''3233333 HRMS_PF.H''
, ''3127777'', ''3127777 HRMS_PF.I''
, ''3333633'', ''3333633 HRMS_PF.J''
, ''3500000'', ''3500000 HRMS_PF.K''
, ''5055050'', ''5055050 HR_PF.K.RUP.1''
, ''5337777'', ''5337777 HR_PF.K.RUP.2''
, ''6699770'', ''6699770 HR_PF.K.RUP.3''
, ''7666111'', ''7666111 HR_PF.K.RUP.4''
, ''9062727'', ''9062727 HR_PF.K.RUP.5''
, ''10015566'', ''10015566 HR_PF.K.RUP.6''
, ''12807777'', ''12807777 HR_PF.K.RUP.7''
, ''14488556'', ''14488556 HR_PF.K.RUP.8''
,''17774746'', ''17774746 HR_PF.K.RUP.9''
) RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER = (select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''2803988'',''2968701'',''3116666'',''3233333'',''3127777'',''3333633'',''3500000'',''5055050'',''5337777'',''6699770'',''7666111'',''9062727'',''10015566'',''12807777'',''14488556'',''17774746''))
and rownum < 2
)
where release in (select substr(release_name,1,4) from fnd_product_groups)
union
SELECT ''ATG Patch Code = ''|| RUP_LEVEL || '' applied on '' || LAST_UPDATE_DATE from
(select ''12.2'' release , DECODE(bug_number
,''19245366'', ''19245366  R12.ATG_PF.C.delta.5''
, ''10110982'', ''10110982	 R12.ATG_PF.C''
,''14222219'', ''14222219	 R12.ATG_PF.C.delta.1''
,''15890638'', ''15890638	 R12.ATG_PF.C.delta.2''
,''17007206'', ''17007206	 R12.ATG_PF.C.delta.3''
,''17909318'', ''17909318	 R12.ATG_PF.C.delta.4''
,''21900895'', ''21900895	 R12.ATG_PF.C.delta.6''
,''24690680'', ''24690680 	 R12.ATG_PF.C.DELTA.7''
,''28840844'', ''28840844 	 R12.ATG_PF.C.Delta.8''
,''30399994'', ''30399994   R12.ATG_PF.C.delta.9''
,''31856779'', ''31856779  R12.ATG_PF.C.DELTA.10''
) RUP_LEVEL , LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(SELECT to_char(max(to_number(adb.bug_number))) FROM ad_bugs adb
WHERE adb.bug_number in (''31856779'',''30399994'',''19245366'',''10110982'',''14222219'',''15890638'',''17007206'',''17909318'',''21900895'',''24690680'',''28840844''))
and rownum < 2
union
select ''12.1'' release ,DECODE(BUG_NUMBER
,''8919491'',''8919491 	R12.ATG_PF.B.delta.3''
,''7651091'',''7651091	 R12.ATG_PF.B.delta.2''
,''7307198'',''7307198 	R12.ATG_PF.B.delta.1''
,''6430106'',''6430106 	R12.ATG_PF.B''
) RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''8919491'',''7651091'',''7307198'',''6430106''))
and rownum < 2
union
SELECT ''12.0'' release ,DECODE(BUG_NUMBER
, ''4461237'', ''4461237	R12.ATG_PF.A''
, ''5907545'', ''5907545	R12.ATG_PF.A.delta.1''
, ''5917344'', ''5917344	R12.ATG_PF.A.delta.2''
, ''6077669'', ''6077669	R12.ATG_PF.A.delta.3''
, ''6272680'', ''6272680	R12.ATG_PF.A.delta.4''
, ''6594849'', ''6594849	R12.ATG_PF.A.delta.5''
, ''7237006'', ''7237006	R12.ATG_PF.A.delta.6''
) RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN
(''4461237'',''5907545'',''5917344'',''6077669'',''6272680'', ''6594849'', ''7237006''))
and rownum < 2
union
SELECT ''11.5'' release ,DECODE(BUG_NUMBER
, ''6241631'', ''6241631	11i.ATG_PF.H RUP7''
, ''5903765'', ''5903765	11i.ATG_PF.H RUP6''
, ''5473858'', ''5473858	11i.ATG_PF.H RUP5''
, ''34676589'', ''34676589	11i.ATG_PF.H RUP4''
, ''4334965'', ''4334965	11i.ATG_PF.H RUP3''
, ''4125550'', ''4125550	11i.ATG_PF.H RUP2''
, ''4017300'', ''4017300	11i.ATG_PF.H RUP1''
, ''3438354'', ''3438354	11i.ATG_PF.H''
) RUP_LEVEL
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER = (select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN
(''6241631'',''5903765'',''5473858'',''34676589'',''4334965'',''4125550'',''4017300'',''3438354''))
and rownum < 2
)
where release in (select substr(release_name,1,4) from fnd_product_groups)
union
SELECT OA_Framework || '' applied on '' || LAST_UPDATE_DATE "Version" from
(select ''12.2'' release , decode(bug_number,''10110982'',''OA Framework 12.2 10110982'',
''14222219'',''OA Framework 12.2.1 14222219'',
''15890638'',''OA Framework 12.2.2 15890638'' ,
''17007206'',''OA Framework 12.2.3 17007206'',
''17909318'',''OA Framework 12.2.4 17909318'',
''17903753'',''OA Framework R12.FWK.C.DELTA.4 17903753'',
''19244764'',''OA Framework R12.FWK.C.DELTA.5 19244764'',
''21921755'',''OA Framework R12.FWK.C.DELTA.6 21921755'',
''31947046'',''FWK RELEASE 12.2.10 (C.9) BUNDLE 1'',
''32130969'',''FWK RELEASE 12.2.10 (C.9) BUNDLE 2'',
''32642176'',''FWK RELEASE 12.2.10 (C.9) BUNDLE 3'',
''32996407'',''FWK RELEASE 12.2.10 (C.9) BUNDLE 4'',
''34521952'',''ORACLE APPLICATION FRAMEWORK (FWK) POST-12.2.12 CONSOLIDATED PATCH'',
''34608422'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.11 BUNDLE 4'',
''34617585'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.10 BUNDLE 12'',
''34459670'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.9 BUNDLE 14'',
''34416999'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE18'',
''31445005'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE10'',
''31154508'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE9'',
''30720143'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE8'',
''30369165'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE7'',
''30139276'',''FWK:ORACLE APPLICATIONS FRAMEWORK(FWK) RELEASE 12.2.7 BUNDLE6'',
''29880879'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE5'',
''29679229'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE4'',
''29232729'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE3'',
''28963259'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE2'',
''28830603'',''FWK:ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.7 BUNDLE1'',
''34500373'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE  12.2.6 BUNDLE32'',
''33279929'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.5 BUNDLE 26'',
''33650745'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.4 BUNDLE 24'',
''30543303'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.3 BUNDLE 23'',
''30339377'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.2 BUNDLE 22'',
''30095623'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.1 BUNDLE 21'',
''29679234'',''ORACLE APPLICATION FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 20'',
''29438310'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 19 29438310'',
''28970079'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 18 28970079'',
''28805689'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 17 28805689'',
''28649181'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 16 28649181'',
''28739010'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 15 28739010'',
''28183913'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 14 28183913'',
''27948803'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 13 27948803'',
''27529582'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 11 27529582'',
''27308923'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 10 27308923'',
''27113797'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 9 27113797'',
''26953578'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 8 26953578'',
''26792877'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 7 26792877'',
''26543378'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 6 26543378'',
''26382210'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 5 26382210'',
''26127158'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 4 26127158'',
''25958203'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 3 25958203'',
''25805360'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 2 25805360'',
''24301236'', ''OA FRAMEWORK (FWK) RELEASE 12.2.6 BUNDLE 1 24301236'',''OA Framework 12.2'') OA_Framework , LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(SELECT to_char(max(to_number(adb.bug_number))) FROM ad_bugs adb
WHERE adb.bug_number in (''10110982'', ''14222219'',''15890638'', ''17007206'', ''17909318'',''17903753'',''19244764'',''21921755'',
''26543378'',''26382210'',''26127158'',''25958203'',''25805360'',''24301236'',
''29438310'',''28970079'',''28805689'',''28649181'',''28739010'',''28183913'',''27948803'',''27529582'',''27308923'',''27113797'',''26953578'',''26792877'',
''29679234'',''30095623'',''30339377'',''30543303'',''28830603'',''28963259'',''29232729'',''29679229'',''29880879'',''30139276'',''30369165'',''30720143'',''31154508'',''31445005'',
''31947046'',''32130969'',''32642176'',''32996407'',''33650745'',''33279929'',''34416999'',''34459670'',''34617585'',''34608422'',''34521952''))
and rownum < 2
union
select ''12.1'' release ,DECODE(BUG_NUMBER
,''17774755'',''OA Framework 12.1.3.2 RPC1 17774755'',
''15880118'',''OA Framework 12.1.3.2 15880118'',
''11894708'',''OA Framework 12.1.3.1 11894708'' ,
''9239090'',''OA Framework 12.1.3 9239090'',
''8919491'',''OA Framework 12.1.3 8919491'',
''18936791'',''OA Framework R12.FWK.B.DELTA.4 18936791'',
''22284589'',''OA Framework R12.FWK.B.DELTA.5 22284589'') OA_Framework
, LAST_UPDATE_DATE
FROM ad_bugs
WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''17774755'',''15880118'',''11894708'',''9239090'',''8919491'',''18936791'',''22284589''))
and rownum < 2
union
SELECT ''12.0'' release ,DECODE(BUG_NUMBER
                  , ''6728000'',''OA Framework 12.0.6'',''6435000'',''OA Framework 12.0.4'',''6141000'',''OA Framework 12.0.3'' ,''5484000'',''OA Framework 12.0.2'',''5082400'',''OA Framework 12.0.1'') OA_Framework, LAST_UPDATE_DATE
                  FROM ad_bugs
                  WHERE BUG_NUMBER =(select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''5082400'', ''5484000'' ,''6141000'',''6435000'',''6728000''))
and rownum < 2
union
SELECT ''11.5'' release ,DECODE(BUG_NUMBER,''2085104'',''OA Framework 5.5.2C'',''2227335'',''OA Framework 5.5.2E'',''2278688'',''OA Framework 5.6.0E'' ,''2771817'',''OA Framework 5.7.0H'',''3875569'',''OA Framework 11.5.10'',
			 ''4017300'', ''OA Framework 11.5.10 ATG_PF.H RUP1'',
			 ''4125550'', ''OA Framework 11.5.10 ATG_PF.H RUP2'',
			 ''4334965'', ''OA Framework 11.5.10 ATG_PF.H RUP3'',
			 ''4676589'', ''OA Framework 11.5.10 ATG_PF.H RUP4'',
			 ''5473858'', ''OA Framework 11.5.10 ATG_PF.H RUP5'',
			 ''5903765'', ''OA Framework 11.5.10 ATG_PF.H RUP6'',
			 ''6241631'', ''OA Framework 11.5.10 ATG_PF.H RUP7'') OA_Framework, LAST_UPDATE_DATE
                          FROM ad_bugs
                          WHERE BUG_NUMBER = (select to_char(max(to_number(bug_number))) from ad_bugs WHERE BUG_NUMBER IN (''2085104'',''2227335'',''2278688'',''2771817'',''3061106'',''3875569'',''4017300'', ''4125550'',''4334965'', ''4676589'',''5473858'',''5903765'',''6241631''))
and rownum < 2
)
where release in (select substr(release_name,1,4) from fnd_product_groups)
union
SELECT ''HRGlobal Last Executed  = ''|| to_char(pr.end_date,''DD-MON-YY HH24:MI:SS'' ) || '' applied with options '' || pr.PATCH_ACTION_OPTIONS
FROM ad_patch_runs pr
WHERE pr.PATCH_TOP LIKE (SELECT (CASE WHEN RELEASE_NAME like ''12%'' THEN ''%per%12.0.0%patch%115%driver''
WHEN RELEASE_NAME like ''11.5%'' THEN ''%per%11.5.0%patch%115%driver'' else ''none'' end) patch
from FND_PRODUCT_GROUPS) AND pr.SUCCESS_FLAG = ''Y'' AND pr.end_date =( SELECT MAX(pr.end_date)
FROM ad_patch_runs pr WHERE pr.PATCH_TOP LIKE
(SELECT (CASE WHEN RELEASE_NAME like ''12%'' THEN ''%per%12.0.0%patch%115%driver''
WHEN RELEASE_NAME like ''11.5%'' THEN ''%per%11.5.0%patch%115%driver'' else ''none'' end) patch
from FND_PRODUCT_GROUPS) AND pr.SUCCESS_FLAG = ''Y'')',
      p_title                  => 'Instance Summary',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'This is a data collection related to application and database details.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N'),
      p_version                => '59'
      );
   l_info.delete;
debug('end add_signature: OVERVIEWHCM');



debug('begin add_signature: HCM_DB_CHECK');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5654',
      p_sig_id                 => 'HCM_DB_CHECK',
      p_sig_sql                => 'SELECT banner from V$VERSION WHERE ROWNUM = 1
and (banner like ''%11.1%'' or banner like ''%10.%'')',
      p_title                  => 'Database in Sustaining Support',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Your database version is in Sustaining Support. ',
      p_solution               => 'We recommend you upgrade your database version.<br>
Refer [1072409.1] Database Documentation Resources for E-Business Suite',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: HCM_DB_CHECK');



debug('begin add_signature: PRODUCTS_ALL');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9628',
      p_sig_id                 => 'PRODUCTS_ALL',
      p_sig_sql                => 'select b.application_short_name "Short Name"
, to_char(t.application_id) "Application ID"
,t.application_name application
, l.meaning Status
, decode(i.patch_level, null, ''11i.'' || b.application_short_name || ''.?'', i.patch_level) "Patch Level"
		  from fnd_application b, fnd_application_tl t, fnd_product_installations i,  fnd_lookup_values l
		  where (t.application_id = i.application_id)
		  AND b.application_id = t.application_id
		  and (l.lookup_type = ''FND_PRODUCT_STATUS'')
		  and (l.lookup_code = i.status )
		  AND t.language = ''US'' AND l.language = ''US''
      order by b.application_short_name',
      p_title                  => 'Products Installed Details',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No product installed.',
      p_solution               => '',
      p_success_msg            => 'This section is a data collection of products status (Installed / Shared / Not installed) and patching level.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: PRODUCTS_ALL');



debug('begin add_signature: Legislations');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1328',
      p_sig_id                 => 'Legislations',
      p_sig_sql                => 'select decode(legislation_code,null,''global'',legislation_code) "Legislation code"
, decode(application_short_name
, ''PER'', ''Human Resources''
, ''PAY'', ''Payroll''
, ''GHR'', ''Federal Human Resources''
, ''CM'', ''College Data''
, application_short_name)  "Application"
, application_short_name "Application Short Name"
, decode(action,''F'',''Force Install'',''C'',''Clear'',''U'',''Upgrade'',''I'',''Install'') "Action"
, to_char(last_update_date,''DD-MON-YY HH24:MI:SS'' ) "Last update"
from hr_legislation_installations
where status = ''I''
order by legislation_code',
      p_title                  => 'Legislations Installed',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Legislations installed as per <br>
12.1: [140511.1] How to Install HRMS Legislative Data Using Data Installer and hrglobal.drv 12.1 Specifics<br>
12.2: [1469456.1] DataInstall and HRGLOBAL Application: 12.2 Specifics
',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: Legislations');



debug('begin add_signature: LANGUAGES_INSTALLED_DETAILS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '362',
      p_sig_id                 => 'LANGUAGES_INSTALLED_DETAILS',
      p_sig_sql                => 'SELECT language_code,
decode(INSTALLED_FLAG ,''B'',''Base Installed Language'',''I'',''Additional Installed Language'',''D'',''Not Installed'') "Type",
nls_language "Language",
nls_territory "Territory"
FROM FND_LANGUAGES
where INSTALLED_FLAG in (''B'',''I'')
order by LANGUAGE_CODE',
      p_title                  => 'Languages Installed',
      p_fail_condition         => 'RSGT1',
      p_problem_descr          => 'This is a data collection of languages installed.<br>
Useful documentation: [399789.1] NLS Frequently Asked Questions<br>
Advice: If you have untranslated issues, follow [252422.1] Requesting Translation Synchronization Patches<br>
-> this will synchronize your languages with actual US level<br>
Note! This is just an advice. This does not mean your NLS is not synchronized! Follow this step ONLY if you have translation issues.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of languages installed.
',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: LANGUAGES_INSTALLED_DETAILS');



debug('begin add_signature: Discrepancies');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '368',
      p_sig_id                 => 'Discrepancies',
      p_sig_sql                => 'select count(1) "Discrepancies"
     from sys.obj$ do, sys.dependency$ d, sys.obj$ po
     where p_obj#=po.obj#(+)
     and d_obj#=do.obj#
     and do.status=1
     and po.status=1
     and po.stime!=p_timestamp
     and do.type# not in (28,29,30)
     and po.type# not in (28,29,30)',
      p_title                  => 'Potential Database Errors ORA-03113 / ORA-01041 / ORA-04065 / ORA-06508',
      p_fail_condition         => '[Discrepancies] > [0]',
      p_problem_descr          => 'You have dependency timestamp discrepancies between the database objects.<br>
This may cause intermittent errors like:<br>
<ul>
<li>ORA-03113: end-of-file on communication channel;</li>
<li>ORA-04065: not executed, altered or dropped stored procedure</li>
<li>ORA-06508: PL/SQL: could not find program unit being called</li>
<li>ORA-01041: internal error</li>
</ul>',
      p_solution               => 'Review<br>
[1303973.1]  ORA-03113: end-of-file on communication channel<br>
[370137.1] After Upgrade, Some Packages Intermittently Fail with ORA-04065 ORA-06508',
      p_success_msg            => 'No discrepancy found.',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: Discrepancies');



debug('begin add_signature: INVALID_HCM');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '623',
      p_sig_id                 => 'INVALID_HCM',
      p_sig_sql                => 'SELECT a.object_name,
decode(a.object_type,
''PACKAGE'', ''Package Spec'',
''PACKAGE BODY'', ''Package Body'',
a.object_type) type,
(
SELECT ltrim(rtrim(substr(substr(text, instr(text,''Header: '')),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 1),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2) -
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 1)
               ))) || '' - '' ||
               ltrim(rtrim(substr(substr(text, instr(text,''Header: '')),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 3) -
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2)
               )))
FROM dba_source c
WHERE c.owner = a.owner
AND c.name = a.object_name
AND c.type = a.object_type
AND c.line = 2
AND c.text like ''%$Header%''
) "File Version",
b.text "Error Text"
FROM dba_objects a,
dba_errors b
WHERE a.object_name = b.name(+)
AND a.object_type = b.type(+)
AND a.owner = ''APPS''
AND a.status = ''INVALID''
order by 1',
      p_title                  => 'Invalid Objects',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'You have '||mask_text(g_invalids, nvl( upper(''), 'NO_MASK') )||' invalid objects. ',
      p_solution               => 'The invalid objects are listed for information only. They may not impact your task, but it is advisable to review and address them as follows:
<ul>
<li>Review any error message provided</li>
<li>Recompile the individual objects manually or recompile the entire APPS schema using the adadmin utility.</li>
<li>If you still have invalid objects, please review steps from [1325394.1]  Troubleshooting Guide - invalid objects in the E-Business Suite Environment 11i and 12
</ul>',
      p_success_msg            => 'No invalid object.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '12'
      );
   l_info.delete;
debug('end add_signature: INVALID_HCM');



debug('begin add_signature: ONEOFF');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1456',
      p_sig_id                 => 'ONEOFF',
      p_sig_sql                => 'select distinct PATCH_TYPE,PATCH_NAME,max(trunc(LAST_UPDATE_DATE)) "Applied date"
from ad_applied_patches where last_update_date> to_date(''##$$LDATE$$##'') group by PATCH_TYPE,PATCH_NAME order by max(trunc(LAST_UPDATE_DATE))',
      p_title                  => 'List of applied patches after latest HRMS RUP',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No patch applied after RUP.',
      p_solution               => '',
      p_success_msg            => 'Patches applied after latest RUP patch.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '2'
      );
   l_info.delete;
debug('end add_signature: ONEOFF');



debug('begin add_signature: AME PACKAGES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8494',
      p_sig_id                 => 'AME PACKAGES',
      p_sig_sql                => 'SELECT name,decode(type,''PACKAGE'', ''PACKAGE SPEC'',type) "Type",
ltrim(rtrim(substr(substr(text, instr(text,''Header: '')),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 1),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2) -
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 1)
               ))) "File",
               ltrim(rtrim(substr(substr(text, instr(text,''Header: '')),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2),
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 3) -
               instr(substr(text, instr(text,''Header: '')), '' '', 1, 2)
               ))) "Version"
				 FROM dba_source c
				 WHERE  (upper(name) like (''AME%''))
				AND   type in (''PACKAGE BODY'',''PACKAGE'')
				AND   line = 2
				AND   text like ''%$Header%''
				order by name',
      p_title                  => 'AME Packages Versions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No settings.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of AME packages versions.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: AME PACKAGES');



debug('begin add_signature: TABLESPACE_CHECK');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '185',
      p_sig_id                 => 'TABLESPACE_CHECK',
      p_sig_sql                => 'SELECT a.TABLESPACE_NAME "TableSpace Name",
           round(a.BYTES / 1024 / 1024) "MB Allocated",
           round((a.BYTES-nvl(b.BYTES, 0)) / 1024 / 1024) "MB Used",
           nvl(round(b.BYTES / 1024 / 1024), 0) "MB Free",
           round(((a.BYTES-nvl(b.BYTES, 0))/a.BYTES)*100,2) "Pct Used",
           round((1-((a.BYTES-nvl(b.BYTES,0))/a.BYTES))*100,2) "Pct Free"
    FROM   (select   TABLESPACE_NAME,
                     sum(BYTES) BYTES
            from     sys.dba_data_files
            group by TABLESPACE_NAME) a,
           (select   TABLESPACE_NAME,
                     sum(BYTES) BYTES
            from     sys.dba_free_space
            group by TABLESPACE_NAME) b
  WHERE  a.TABLESPACE_NAME = b.TABLESPACE_NAME (+)
  AND (round((1-((a.BYTES-nvl(b.BYTES,0))/a.BYTES))*100,2) < 3)
  order  by ((a.BYTES-b.BYTES)/a.BYTES) desc',
      p_title                  => 'Potential Tablespace Issues',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The objects listed above have 3% or less tablespace free.</P>

Some operating systems set a limit on the number of files that can be open simultaneously. Such limits can affect the number of tablespaces that can be simultaneously online. To avoid exceeding your operating system limit, plan your tablespaces efficiently. Create only enough tablespaces to fulfill your needs, and create these tablespaces with as few files as possible. If you need to increase the size of a tablespace, add one or two large datafiles, or create datafiles with autoextension enabled, rather than creating many small datafiles.
',
      p_solution               => '<p>Review items indicated and add additional data files to the tablespace as required.</p>
See [1493350.1#aref_section218]- Overview of Oracle Tablespace Management.
',
      p_success_msg            => '<p>No Potential tablespace issues detected.</p>
',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '9'
      );
   l_info.delete;
debug('end add_signature: TABLESPACE_CHECK');



debug('begin add_signature: ATTRIBUTES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8484',
      p_sig_id                 => 'ATTRIBUTES',
      p_sig_sql                => 'select atr.attribute_id
            ,atr.name
            ,atu.query_string
            ,atr.description
            ,atu.is_static
            ,atu.use_count
        from ame_attributes atr
            ,ame_attribute_usages atu
       where atr.attribute_id = atu.attribute_id
         and atu.application_id = ##$$AMEAPPID$$##
         and atr.item_class_id  = ##$$FK1$$##
         and sysdate between atr.start_date and nvl(atr.end_date - (1/86400),sysdate)
         and sysdate between atu.start_date and nvl(atu.end_date - (1/86400),sysdate)
         and atr.attribute_id not in
            (select attribute_id
               from ame_mandatory_attributes man
              where man.action_type_id = -1
                and sysdate between man.start_date and nvl(man.end_date - (1/86400),sysdate)
            )
       order by atr.name',
      p_title                  => 'Attributes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Attributes found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: ATTRIBUTES');



debug('begin add_signature: ITEM CLASSES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8472',
      p_sig_id                 => 'ITEM CLASSES',
      p_sig_sql                => 'select ic.item_class_id "ID"
,ic.item_class_id "##$$FK1$$##"
            ,ic.name "Name"
            ,icu.item_id_query "QueryString"
            ,icu.item_class_order_number "Order Number"
            ,decode(icu.item_class_par_mode
                   ,''S''
                   ,''Serial''
                   ,''P''
                   ,''Parallel''
                   ,icu.item_class_par_mode) "Parallelisation Mode"
            ,decode(icu.item_class_sublist_mode
                   ,''S''
                   ,''Serial''
                   ,''P''
                   ,''Parallel''
                   ,''R''
                   ,''pre-approvers first, then authority and post-approvers''
                   ,''A''
                   ,''pre-approvers and authority approvers first, then post-approvers''
                   ,icu.item_class_sublist_mode) "Sub List Mode"
        from ame_item_classes ic
            ,ame_item_class_usages icu
       where ic.item_class_id = icu.item_class_id
         and icu.application_id = ##$$AMEAPPID$$##
         and sysdate between ic.start_date and nvl(ic.end_date - (1/86400),sysdate)
         and sysdate between icu.start_date and nvl(icu.end_date - (1/86400),sysdate)
       order by icu.item_class_order_number',
      p_title                  => 'Item Classes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No item classes found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of item classes.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('ATTRIBUTES'),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: ITEM CLASSES');



debug('begin add_signature: MANDATORY ATTRIBUTES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8476',
      p_sig_id                 => 'MANDATORY ATTRIBUTES',
      p_sig_sql                => 'select atr.attribute_id ID
            ,atr.name
            ,atu.query_string
            ,atr.description
            ,atu.is_static
        from ame_attributes atr
            ,ame_attribute_usages atu
       where atr.attribute_id = atu.attribute_id
         and atu.application_id = ##$$AMEAPPID$$##
         and sysdate between atr.start_date and nvl(atr.end_date - (1/86400),sysdate)
         and sysdate between atu.start_date and nvl(atu.end_date - (1/86400),sysdate)
         and atr.attribute_id in
            (select attribute_id
               from ame_mandatory_attributes man
              where man.action_type_id = -1
                and sysdate between man.start_date and nvl(man.end_date - (1/86400),sysdate)
            )
       order by atr.name',
      p_title                  => 'Mandatory Attributes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No mandatory attributes found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of mandatory attributes.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '2'
      );
   l_info.delete;
debug('end add_signature: MANDATORY ATTRIBUTES');



debug('begin add_signature: AME_CONDITIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8483',
      p_sig_id                 => 'AME_CONDITIONS',
      p_sig_sql                => 'SELECT aco.condition_key ,
  aco.condition_id ,
  ame_condition_pkg.getAttributeName(aco.condition_id) "Attribute Name",
  ame_condition_pkg.getDescription(aco.condition_id) "Description"
FROM ame_attribute_usages atu ,
  ame_conditions aco
WHERE atu.application_id = ##$$AMEAPPID$$##
AND aco.attribute_id     = atu.attribute_id
AND sysdate BETWEEN atu.start_date AND NVL(atu.end_date-(1/86400),sysdate)
AND sysdate BETWEEN aco.start_date AND NVL(aco.end_date-(1/86400),sysdate)
ORDER BY condition_id',
      p_title                  => 'Regular Conditions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No conditions found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of regular conditions.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: AME_CONDITIONS');



debug('begin add_signature: LIST MODIFICATION USED');
   l_info('##MASK##APPROVER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8489',
      p_sig_id                 => 'LIST MODIFICATION USED',
      p_sig_sql                => 'select condition_key
          ,condition_id
          ,parameter_one "Type"
          ,parameter_two "Approver"
          , ''Y'' "Used in current Transaction"
      from ame_conditions
     where condition_type =''post''
       and sysdate between start_date and nvl(end_date-(1/86400),sysdate)
       and condition_id in(select condition_id
     from ame_condition_usages
    where rule_id in (select rule_id
                       from ame_rule_usages
                      where item_id = ##$$AMEAPPID$$##
                        and sysdate between start_date
                               and nvl(end_date-(1/86400),sysdate)))',
      p_title                  => 'Modification Conditions Used in Current Transaction Type',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No modification conditions used in current transaction type.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of available modification conditions used in the current transaction type.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: LIST MODIFICATION USED');



debug('begin add_signature: LIST MODIFICATION NOT USED');
   l_info('##MASK##APPROVER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8490',
      p_sig_id                 => 'LIST MODIFICATION NOT USED',
      p_sig_sql                => 'select condition_key
          ,condition_id
          ,parameter_one "Type"
          ,parameter_two Approver
          , ''N'' "Used in current Transaction"
      from ame_conditions
     where condition_type =''post''
       and sysdate between start_date and nvl(end_date-(1/86400),sysdate)
       and condition_id not in (select condition_id
     from ame_condition_usages
    where rule_id in (select rule_id
                       from ame_rule_usages
                      where item_id = ##$$AMEAPPID$$##
                        and sysdate between start_date
                               and nvl(end_date-(1/86400),sysdate)))',
      p_title                  => 'Modification Conditions NOT Used in Current Transaction Type',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No modification conditions available.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of available modification conditions not used in the current transaction type.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: LIST MODIFICATION NOT USED');



debug('begin add_signature: RULE_CONDITIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8478',
      p_sig_id                 => 'RULE_CONDITIONS',
      p_sig_sql                => 'SELECT c.condition_id,
           decode(c.condition_type,
             ''auth'','' '',
             ''pre'', ''Exception : '',
             ''post'', ''List-Modification : '') "Condition Type",
             ame_condition_pkg.getDescription(c.condition_id) Description
    FROM ame_condition_usages cu,
         ame_conditions c
    WHERE cu.rule_id = ##$$FK1$$##
    AND   c.condition_id = cu.condition_id
    AND   sysdate between c.start_date AND nvl(c.end_date - (1/86400),sysdate)
    AND   (sysdate between cu.start_date AND nvl(cu.end_date - (1/86400),sysdate) OR
           (cu.start_date > sysdate AND
            (cu.end_date is null OR cu.end_date > cu.start_date)))',
      p_title                  => 'Conditions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Rules Conditions found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('SUCCESS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: RULE_CONDITIONS');



debug('begin add_signature: RULE_ACTIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8479',
      p_sig_id                 => 'RULE_ACTIONS',
      p_sig_sql                => 'SELECT a.action_id,
           ame_action_pkg.getDescription(a.action_id) "Description"
    FROM ame_action_usages au,
         ame_actions a
    WHERE au.rule_id = ##$$FK1$$##
    AND   a.action_id = au.action_id
    AND   sysdate between a.start_date AND nvl(a.end_date - (1/86400),sysdate)
    AND   (sysdate between au.start_date AND nvl(au.end_date - (1/86400),sysdate) OR
           (au.start_date > sysdate AND
            (au.end_date is null OR au.end_date > au.start_date)))',
      p_title                  => 'Actions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Rules Actions found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('SUCCESS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '2'
      );
   l_info.delete;
debug('end add_signature: RULE_ACTIONS');



debug('begin add_signature: RULES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8477',
      p_sig_id                 => 'RULES',
      p_sig_sql                => 'SELECT ic.name item_class,
           ic.name "##$$FK2$$##",
           decode(r.rule_type,
             0, ''Combination'',
             1, ''List Creation'',
             2, ''List Creation Exception'',
             3, ''List Modification'',
             4, ''Substitution'',
             5, ''Pre-list'',
             6, ''Post-list'',
             7, ''Production'',
             r.rule_type) "Rule Type",
           r.rule_id, r.rule_id "##$$FK1$$##",
           r.rule_key,
           r.description,
           r.start_date,
           r.end_date,
           nvl(to_char(ru.priority),''Disabled'') "Priority",
           decode(ru.approver_category,
             ''A'', ''Action'',
             ''F'', ''FYI'',
             ru.approver_category) "Category"
    FROM ame_rules r,
         ame_rule_usages ru,
         (
           SELECT ic.name, ic.item_class_id,
                  icu.item_class_order_number, icu.item_class_id item_clsid
            FROM ame_item_classes ic,
                 ame_item_class_usages icu
            WHERE ic.item_class_id = icu.item_class_id
            AND   icu.application_id = ##$$AMEAPPID$$##
            AND   sysdate BETWEEN ic.start_date AND
                    nvl(ic.end_date - (1/86400),sysdate)
            AND   sysdate BETWEEN icu.start_date AND
                    nvl(icu.end_date - (1/86400),sysdate)
         ) ic
    WHERE
-- r.rule_type BETWEEN 1 and 8
    ic.item_class_id (+) = r.item_class_id
    AND   (r.rule_type IN (3, 4) OR
           ic.item_class_id is not null)
    AND   r.rule_id = ru.rule_id
    AND   ru.item_id = ##$$AMEAPPID$$##
    AND   (sysdate between r.start_date AND nvl(r.end_date - (1/86400),sysdate) OR
           (r.start_date > sysdate AND
             (r.end_date is null OR r.end_date > r.start_date)))
    AND   (sysdate between ru.start_date AND nvl(ru.end_date - (1/86400),sysdate) OR
           (ru.start_date > sysdate AND
             (ru.end_date is null OR ru.end_date > ru.start_date)))
    ORDER BY ic.item_class_order_number,
    item_clsid,
    r.rule_type,
    r.rule_id',
      p_title                  => 'Rules',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No rules found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of rules used for this application.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('RULE_CONDITIONS','RULE_ACTIONS'),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: RULES');



debug('begin add_signature: REQUIRED ATTRIBUTES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8486',
      p_sig_id                 => 'REQUIRED ATTRIBUTES',
      p_sig_sql                => 'select atr.name
            ,atr.attribute_type
        from ame_attributes atr
       where sysdate between atr.start_date and nvl(atr.end_date - (1/86400),sysdate)
         and atr.attribute_id in
            (select attribute_id
               from ame_mandatory_attributes man
              where man.action_type_id =  ##$$FK1$$##
                and sysdate between man.start_date and nvl(man.end_date - (1/86400),sysdate)
            )',
      p_title                  => 'Required Attributes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Required Attributes found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: REQUIRED ATTRIBUTES');



debug('begin add_signature: ACTIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8487',
      p_sig_id                 => 'ACTIONS',
      p_sig_sql                => 'select act.action_id
            ,act.parameter
            ,act.parameter_two
            ,act.description
        from ame_actions act
       where act.action_type_id = ##$$FK1$$##
         and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
         and act.created_by not in (1,120)',
      p_title                  => 'Actions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No actions found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: ACTIONS');



debug('begin add_signature: ACTION TYPES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8485',
      p_sig_id                 => 'ACTION TYPES',
      p_sig_sql                => 'select aty.action_type_id "ID"
,aty.action_type_id "##$$FK1$$##"
            ,aty.name
            ,acf.order_number "Order Number"
            ,decode(acf.voting_regime
                   ,''S''
                   ,''Serial''
                   ,''C''
                   ,''Consensus''
                   ,''F''
                   ,''First Responder Wins''
                   ,acf.voting_regime) "Voting Regime"
            ,decode(acf.chain_ordering_mode
                   ,''S''
                   ,''Serial''
                   ,''P''
                   ,''Parallel''
                   ,acf.chain_ordering_mode) "COA Ordering Mode",
          aty.procedure_name as handler_name
        from ame_action_type_config acf
            ,ame_action_types aty
            ,ame_action_type_usages atu
       where acf.application_id = ##$$AMEAPPID$$##
         and aty.action_type_id = acf.action_type_id
         and aty.action_type_id = atu.action_type_id
         and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
         and sysdate between atu.start_date and nvl(atu.end_date - (1/86400),sysdate)
         and sysdate between acf.start_date and nvl(acf.end_date - (1/86400),sysdate)
       order by atu.rule_type,acf.order_number',
      p_title                  => 'Action Types Used in Current Transaction Type',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No action types found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of action types used in current transaction type.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('REQUIRED ATTRIBUTES','ACTIONS'),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '10'
      );
   l_info.delete;
debug('end add_signature: ACTION TYPES');



debug('begin add_signature: GROUP ITEMS');
   l_info('##MASK##PARAMETER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8481',
      p_sig_id                 => 'GROUP ITEMS',
      p_sig_sql                => 'SELECT agi.order_number,
           agi.approval_group_item_id "Item ID",
           decode(agi.parameter_name,
             ''OAM_group_id'', ''AME Group'',
             ''wf_roles_name'', ''WF Role'',
             agi.parameter_name) "Parameter Name",
           agi.parameter
    FROM ame_approval_group_items agi
    WHERE agi.approval_group_id = ##$$FK1$$##
    AND   sysdate BETWEEN agi.start_date AND nvl(agi.end_date - (1/86400),sysdate)
    ORDER BY agi.order_number',
      p_title                  => 'Approval Group Items',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No items found for this approval group.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: GROUP ITEMS');



debug('begin add_signature: RULES_USING_APPROVER_GROUPS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '22366',
      p_sig_id                 => 'RULES_USING_APPROVER_GROUPS',
      p_sig_sql                => 'SELECT
    *
FROM
    (
        SELECT
            rul.description         AS rule_name,
            apps.application_name   transaction_type,
            rlu.start_date          start_date,
            rlu.end_date            end_date
        FROM
            ame_rules_vl          rul,
            ame_rule_usages       rlu,
            ame_action_usages     acu,
            ame_actions           act,
            ame_action_types      aty,
            ame_calling_apps_vl   apps
        WHERE
            sysdate BETWEEN apps.start_date AND nvl(apps.end_date -(1 / 86400), sysdate)
            AND sysdate BETWEEN aty.start_date AND nvl(aty.end_date -(1 / 86400), sysdate)
            AND sysdate BETWEEN act.start_date AND nvl(act.end_date -(1 / 86400), sysdate)
            AND ( sysdate BETWEEN acu.start_date AND nvl(acu.end_date -(1 / 86400), sysdate)
                  OR ( acu.start_date > sysdate
                       AND acu.end_date > acu.start_date ) )
            AND ( sysdate BETWEEN rul.start_date AND nvl(rul.end_date -(1 / 86400), sysdate)
                  OR ( rul.start_date > sysdate
                       AND rul.end_date > rul.start_date ) )
            AND ( sysdate BETWEEN rlu.start_date AND nvl(rlu.end_date -(1 / 86400), sysdate)
                  OR ( rlu.start_date > sysdate
                       AND rlu.end_date > rlu.start_date ) )
            AND rlu.item_id = apps.application_id
            AND rul.rule_id = rlu.rule_id
            AND acu.rule_id = rul.rule_id
            AND acu.action_id = act.action_id
            AND act.action_type_id = aty.action_type_id
            AND aty.name IN (
                ''post-chain-of-authority approvals'',
                ''pre-chain-of-authority approvals'',
                ''approval-group chain of authority''
            )
            AND act.parameter = ''##$$FK1$$##''
    ) qrslt
ORDER BY
    rule_name,
    transaction_type',
      p_title                  => 'Rules Using This Approver Group',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No items found for this approval group.',
      p_solution               => 'This is an Information associated with the APPROVAL GROUP',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: RULES_USING_APPROVER_GROUPS');



debug('begin add_signature: APPROVAL_GROUPS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8482',
      p_sig_id                 => 'APPROVAL_GROUPS',
      p_sig_sql                => 'SELECT agr.approval_group_id, agr.approval_group_id "##$$FK1$$##",
agr.name,
agf.order_number,
           decode(agf.voting_regime,
             ''S'',''Serial'',
             ''C'', ''Consensus'',
             ''F'', ''First Responder Wins'',
             ''O'', ''Order Number'',
             agf.voting_regime) "Voting Regime",
           agr.description,
           agr.query_string,
           agr.is_static "Static"
    FROM ame_approval_group_config agf,
         ame_approval_groups agr
    WHERE agf.application_id = ##$$AMEAPPID$$##
    AND   agr.approval_group_id = agf.approval_group_id
    AND   sysdate BETWEEN agr.start_date AND nvl(agr.end_date - (1/86400),sysdate)
    AND   sysdate BETWEEN agf.start_date AND nvl(agf.end_date - (1/86400),sysdate)
    ORDER BY agf.order_number, agr.approval_group_id',
      p_title                  => 'Approval Groups',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No approval groups found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of approval groups.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('GROUP ITEMS','RULES_USING_APPROVER_GROUPS'),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: APPROVAL_GROUPS');



debug('begin add_signature: CONFIGURATION VARIABLES1');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8491',
      p_sig_id                 => 'CONFIGURATION VARIABLES1',
      p_sig_sql                => 'select cfg.variable_name
            ,cfg.variable_value "Value"
        from ame_config_vars cfg
       where cfg.application_id = ##$$AMEAPPID$$##
         and sysdate between cfg.start_date and nvl(cfg.end_date - (1/86400),sysdate)',
      p_title                  => 'Configuration Variables Transaction Type Level',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No configuration variables at transaction type level.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of transaction type level configuration variables.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: CONFIGURATION VARIABLES1');



debug('begin add_signature: CONFIGURATION VARIABLES2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8492',
      p_sig_id                 => 'CONFIGURATION VARIABLES2',
      p_sig_sql                => 'select cfg.variable_name
            ,cfg.variable_value "Value"
        from ame_config_vars cfg
       where cfg.application_id = 0
         and sysdate between cfg.start_date and nvl(cfg.end_date - (1/86400),sysdate)',
      p_title                  => 'Configuration Variables Default',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No default configuration variables.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of default configuration variables.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: CONFIGURATION VARIABLES2');



debug('begin add_signature: APPROVER TYPE DETAILS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8493',
      p_sig_id                 => 'APPROVER TYPE DETAILS',
      p_sig_sql                => 'select  apt.approver_type_id
            ,apt.orig_system
            ,fnd_lookups.description
      from ame_approver_types apt
          ,fnd_lookups
     where lookup_code = apt.orig_system
       and lookup_type = ''FND_WF_ORIG_SYSTEMS''
       and sysdate between apt.start_date
                and nvl(apt.end_date-(1/86400),sysdate)
       order by approver_type_id',
      p_title                  => 'Approver Types',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No approver type found.',
      p_solution               => '',
      p_success_msg            => 'This is a data collection of approver type details.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '2'
      );
   l_info.delete;
debug('end add_signature: APPROVER TYPE DETAILS');



debug('begin add_signature: INCORRECT_DEFAULT_CONFIG');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8480',
      p_sig_id                 => 'INCORRECT_DEFAULT_CONFIG',
      p_sig_sql                => 'select variable_name "Default Config Variable",
     variable_value  "VALUE"
      from apps.AME_CONFIG_VARS
     where nvl(application_id, 0) = 0
       and sysdate < nvl(end_date,sysdate + 1)
       and variable_name in (''allowAllApproverTypes'',''allowAllItemClassRules'',''allowFyiNotifications'',''productionFunctionality'')
       and variable_value not in (''no'',''none'')
       and not exists (select null from apps.AME_CONFIG_VARS B
	   					where application_id = ##$$AMEAPPID$$##
                         and sysdate < nvl(B.end_date,sysdate + 1)
                         and variable_name = B.variable_name)',
      p_title                  => 'Incorrect Value for Default Configuration Variable',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above configuration variable values have been set to ''YES'' or ''ALL'' at Transaction Type Level.',
      p_solution               => 'You may hit the error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#incorrect_value] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"<br>
Incorrect value for Default Configuration Variable.
',
      p_success_msg            => 'No configuration variables with incorrect values found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '14'
      );
   l_info.delete;
debug('end add_signature: INCORRECT_DEFAULT_CONFIG');



debug('begin add_signature: NON SERIAL VOTING REGIME');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8500',
      p_sig_id                 => 'NON SERIAL VOTING REGIME',
      p_sig_sql                => 'select name "Action Type"
	from apps.AME_ACTION_TYPE_CONFIG atc
	    ,apps.AME_ACTION_TYPES atyp
	where application_id = ##$$AMEAPPID$$##
	  and voting_regime <> ''S''
	  and sysdate between atc.start_date and nvl(atc.end_date,sysdate + 1)
	  and sysdate between atyp.start_date and nvl(atyp.end_date,sysdate + 1)
	  and atc.action_type_id = atyp.action_type_id',
      p_title                  => 'Non Serial Voting Regimes for Action Type',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above action types do not have a serial voting regime.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue2] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"
',
      p_success_msg            => 'No issues found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: NON SERIAL VOTING REGIME');



debug('begin add_signature: NON UNIQUE ORDER NUMBERS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8501',
      p_sig_id                 => 'NON UNIQUE ORDER NUMBERS',
      p_sig_sql                => 'select name "Action Type"
from apps.AME_ACTION_TYPE_CONFIG atc
    ,apps.AME_ACTION_TYPES atyp
    ,apps.AME_ACTION_TYPE_USAGES atu
where application_id = ''##$$AMEAPPID$$##''
  and sysdate between atu.start_date and nvl(atu.end_date,sysdate + 1)
  and sysdate between atc.start_date and nvl(atc.end_date,sysdate + 1)
  and sysdate between atyp.start_date and nvl(atyp.end_date,sysdate + 1)
  and atc.action_type_id = atyp.action_type_id
  and atu.action_type_id = atyp.action_type_id
  and (atu.rule_type, atc.order_number) in (select rule_type,order_number
          from apps.ame_action_type_config B,apps.ame_action_type_usages C
          where B.action_type_id = C.action_type_id
          and application_id = ''##$$AMEAPPID$$##''
          and sysdate between C.start_date and nvl(C.end_date,sysdate + 1)
          and sysdate between B.start_date and nvl(B.end_date,sysdate + 1)
          group by rule_type,order_number
          having count(*) > 1)',
      p_title                  => 'Non Unique Order Numbers  for Action Type',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above action types have non unique order numbers.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue3] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"
',
      p_success_msg            => 'No issues found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: NON UNIQUE ORDER NUMBERS');



debug('begin add_signature: NON SERIAL OR ORDER NUMBER VOTING REGIME');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8502',
      p_sig_id                 => 'NON SERIAL OR ORDER NUMBER VOTING REGIME',
      p_sig_sql                => 'select name "Approval Group"
  from apps.AME_APPROVAL_GROUPS apg
       ,apps.AME_APPROVAL_GROUP_CONFIG apgc
 where apg.approval_group_id = apgc.approval_group_id
   and apgc.application_id = ##$$AMEAPPID$$##
   and apgc.voting_regime not in (''S'',''O'')
   and sysdate between apgc.start_date and nvl(apgc.end_date,sysdate + 1)
   and sysdate between apg.start_date and nvl(apg.end_date,sysdate + 1)',
      p_title                  => 'Non Serial or Order Number Voting Regime for Approval Group',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above approval groups have non serial or order number voting regime.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue4] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"
',
      p_success_msg            => 'No issue found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: NON SERIAL OR ORDER NUMBER VOTING REGIME');



debug('begin add_signature: NON UNIQUE ORDER NUMBERS FOR APPROVAL GROUP CONFIG');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8503',
      p_sig_id                 => 'NON UNIQUE ORDER NUMBERS FOR APPROVAL GROUP CONFIG',
      p_sig_sql                => 'select name "Approval Group Config"
  from apps.AME_APPROVAL_GROUPS apg
       ,apps.AME_APPROVAL_GROUP_CONFIG apgc
 where apg.approval_group_id = apgc.approval_group_id
   and apgc.application_id = ''##$$AMEAPPID$$##''
   and sysdate between apgc.start_date and nvl(apgc.end_date,sysdate + 1)
   and sysdate between apg.start_date and nvl(apg.end_date,sysdate + 1)
   and order_number in (select order_number
                           from apps.AME_APPROVAL_GROUP_CONFIG apgc
                          where sysdate between apgc.start_date and nvl(apgc.end_date,sysdate + 1)
                            and apgc.application_id = ''##$$AMEAPPID$$##''
                        group by order_number
                          having count(*) > 1)',
      p_title                  => 'Non Unique Order Numbers for Approval Group Config',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above approval group configs have non unique order numbers.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue5] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"
',
      p_success_msg            => 'No issue found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: NON UNIQUE ORDER NUMBERS FOR APPROVAL GROUP CONFIG');



debug('begin add_signature: NON UNIQUE ORDER NUMBERS FOR ITEMS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8504',
      p_sig_id                 => 'NON UNIQUE ORDER NUMBERS FOR ITEMS',
      p_sig_sql                => 'select name "Approval Group"
from AME_APPROVAL_GROUPS apg
where sysdate between apg.start_date and nvl(apg.end_date,sysdate + 1)
  and apg.approval_group_id in (  select apgi.approval_group_id
                           from AME_APPROVAL_GROUP_ITEMS apgi
                                ,AME_APPROVAL_GROUP_CONFIG apgc
                          where sysdate between apgi.start_date and nvl(apgi.end_date,sysdate + 1)
                            and sysdate between apgc.start_date and nvl(apgc.end_date,sysdate + 1)
                            and apgc.application_id = ''##$$AMEAPPID$$##''
                            and apgi.approval_group_id = apgc.approval_group_id
                       group by apgi.approval_group_id,apgi.order_number
                         having count(*) > 1 )',
      p_title                  => 'Non Unique Order Numbers for Items of Approval Group',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above approval groups have non unique order numbers for items.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue1] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"
',
      p_success_msg            => 'No issue found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: NON UNIQUE ORDER NUMBERS FOR ITEMS');



debug('begin add_signature: NON SERIAL SUBLIST MODES FOR ITEM CLASS USAGES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8505',
      p_sig_id                 => 'NON SERIAL SUBLIST MODES FOR ITEM CLASS USAGES',
      p_sig_sql                => 'select  itc.name "Item Class Usages"
  from ame_item_classes itc
  where sysdate between itc.start_date and nvl(itc.end_date,sysdate+1)
    and itc.item_class_id in (select itu.item_class_id
        from ame_item_class_usages itu
       where itu.application_id = ''##$$AMEAPPID$$##''
         and sysdate between itu.start_date and nvl(itu.end_date,sysdate+1)
         and item_class_sublist_mode <> ''S'')',
      p_title                  => 'Non Serial Sublist Modes for Item Class Usages',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Non serial sublist modes for item class usages.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details.<br>
Review [338508.1#issue6] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"',
      p_success_msg            => 'No issue found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '9'
      );
   l_info.delete;
debug('end add_signature: NON SERIAL SUBLIST MODES FOR ITEM CLASS USAGES');



debug('begin add_signature: TRANSACTION_SUMMARY');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8895',
      p_sig_id                 => 'TRANSACTION_SUMMARY',
      p_sig_sql                => 'select fnd.application_name "Product Name"
            ,aca.application_name "Transaction Type Name"
            ,aca.transaction_type_id "TransactionType ID"
            ,aca.application_id "Application ID"
            ,aca.start_date "Start Date"
            ,aca.end_date "End Date"
        from fnd_application_vl fnd
            ,ame_calling_apps aca
       where aca.fnd_application_id = fnd.application_id
         and aca.application_id = ''##$$AMEAPPID$$##''
         and sysdate between aca.start_date and nvl(aca.end_date - (1/86400),sysdate)',
      p_title                  => 'Application Setup Details',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No information found about this application ID',
      p_solution               => 'Review [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME)  Responsibilities and Setups in AME.B ',
      p_success_msg            => 'This is a data collection of application details.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: TRANSACTION_SUMMARY');



debug('begin add_signature: INVALID_SUPERVISOR_GENERIC');
   l_info('##MASK##EMPLOYEE_NAME'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##EMPLOYEE_NUMBER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##SUPERVISOR_EMPLOYEE_NUMBER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##SUPERVISOR_NAME'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9286',
      p_sig_id                 => 'INVALID_SUPERVISOR_GENERIC',
      p_sig_sql                => 'SELECT
psn.person_id "Employee Person ID"
, psn.employee_number
, psn.business_group_id "Employee Business Group"
, asg.assignment_id  "Employee Assigment ID"
, psn.full_name  Employee_Name
,sup.PERSON_ID "Supervisor Person ID"
,sup.full_name Supervisor_Name
,(select employee_number from per_all_people_f where person_id = sup.person_id AND TRUNC(sysdate)
BETWEEN effective_start_date
AND effective_end_date ) Supervisor_Employee_Number
,Sup.person_type_id "Supervisor Person Type ID"
,(select user_person_type from per_person_types where person_type_id = sup.person_type_id) "Supervisor Person Type"
FROM
per_all_assignments_f         asg
, per_assignment_status_types   ast
, per_all_people_f              psn
, per_all_people_f              sup
WHERE
asg.person_id = psn.person_id
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND asg.supervisor_id = sup.person_id(+)
and psn.CURRENT_EMPLOYEE_FLAG =''Y''
AND  asg.assignment_type = ''E''
AND TRUNC(sysdate) BETWEEN psn.effective_start_date AND psn.effective_end_date
AND TRUNC(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
AND TRUNC(sysdate) BETWEEN sup.effective_start_date AND sup.effective_end_date
AND TRUNC(sysdate) BETWEEN sup.effective_start_date AND sup.effective_end_date
And asg.supervisor_id IS NOT NULL
AND sup.current_employee_flag IS NULL
AND sup.current_npw_flag IS NULL
AND sup.current_applicant_flag IS NULL',
      p_title                  => 'Employees With Invalid Supervisors (All Persons)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The supervisors for these employees are invalid. This could be due to terminated supervisor.',
      p_solution               => 'Review [2253893.1] How to Navigate and check Employee Supervisor/Manager in the Application?',
      p_success_msg            => 'OK! No issue found',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: INVALID_SUPERVISOR_GENERIC');



debug('begin add_signature: INCORRECT_VALUE_CONFIGURATION_VARIABLE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9663',
      p_sig_id                 => 'INCORRECT_VALUE_CONFIGURATION_VARIABLE',
      p_sig_sql                => 'select variable_name "Transaction Config Variable",
       variable_value "VALUE"
      from apps.AME_CONFIG_VARS
     where application_id = ##$$AMEAPPID$$##
       and sysdate < nvl(end_date,sysdate + 1)
       and variable_name in (''allowAllApproverTypes'',''allowAllItemClassRules'',''allowFyiNotifications'',''productionFunctionality'')
       and variable_value not in (''no'',''none'')',
      p_title                  => 'Incorrect value for Transaction Type Configuration Variable',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above configuration variables value have set to ''YES'' or ''ALL'' at transaction type Level.',
      p_solution               => 'You may hit error ORA-20001: Oracle Approvals Management has found parallelization configuration details<br>
Review [338508.1#incorrect_trans] Approvals Management (AME) Error "Oracle Approvals Management has Found Parallelisation Configuration whereas the Context in which AME invoked Using AME_API Does Not Support Parallelisation"<br>
Incorrect value for Transaction Type Configuration Variable
',
      p_success_msg            => 'No configuration variables with incorrect values found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: INCORRECT_VALUE_CONFIGURATION_VARIABLE');



debug('begin add_signature: APPROVER GROUPS WITH INVALID OR TERMINATED EMPLOYEES');
   l_info('##MASK##EMAIL_ADDRESS'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##WF_LOCAL_ROLES_DISP_NAME'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '18397',
      p_sig_id                 => 'APPROVER GROUPS WITH INVALID OR TERMINATED EMPLOYEES',
      p_sig_sql                => 'SELECT a.* FROM (SELECT
   agr.name AS approver_group,
   agf.order_number,
   DECODE(agf.voting_regime, ''S'', ''Serial'', ''C'', ''Consensus'',
          ''F'', ''First Responder Wins'', ''O'', ''Order Number'', agf.voting_regime) "Voting Regime",
   agr.is_static      "Static",
   agi.order_number   AS approver_order_number,
   DECODE(agi.parameter_name, ''OAM_group_id'', ''AME Group'', ''wf_roles_name'', ''WF Role'',
          agi.parameter_name) "Parameter Name",
   agi.parameter,
   wlr.display_name   wf_local_roles_disp_name,
   wlr.email_address,
   wlr.orig_system,
   wlr.orig_system_id,
   wlr.start_date,
   wlr.status,
   wlr.expiration_date,
   wlr.parent_orig_system,
   wlr.parent_orig_system_id,
   DECODE (wlr.orig_system,''PER'',(SELECT papf.current_employee_flag
   FROM per_all_people_f papf
   WHERE 1=1
   AND trunc(sysdate) BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND papf.person_id=wlr.orig_system_id)) AS current_employee_flag,
   fu.user_name AS fnd_user_name,
   fu.start_date AS user_start_date,
   fu.end_date AS user_end_date
FROM
   fnd_user fu,
   wf_local_roles              wlr,
   ame_approval_group_items    agi,
   ame_approval_group_config   agf,
   ame_approval_groups         agr
WHERE 1 = 1
   AND fu.employee_id(+)=wlr.orig_system_id
   AND wlr.name = agi.parameter
   AND SYSDATE BETWEEN agi.start_date AND NVL(agi.end_date -(1 / 86400), SYSDATE)
   AND agi.approval_group_id = agr.approval_group_id
   AND SYSDATE BETWEEN agf.start_date AND NVL(agf.end_date -(1 / 86400), SYSDATE)
   AND agf.application_id = ##$$AMEAPPID$$##
   AND SYSDATE BETWEEN agr.start_date AND NVL(agr.end_date -(1 / 86400), SYSDATE)
   AND agf.approval_group_id = agr.approval_group_id) a
WHERE 1=1
AND a.orig_system IN (''FND_USR'',''PER'',''WF_LOCAL_ROLES'')
AND ((a.current_employee_flag IS NULL) OR
     (a.fnd_user_name IS NULL) OR
     (a.fnd_user_name IS NOT NULL AND a.user_end_date IS NOT NULL))
ORDER BY
   a.order_number,
   a.approver_order_number',
      p_title                  => 'Approver Groups with Invalid or Terminated Employees',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The above approver groups have invalid and/or terminated employees',
      p_solution               => 'You may encounter error "An Invalid Setup has been detected for the current Transaction Type in Approvals Management. Please contact your System Administrator."<br>
Review [2754862.1] Encounter the Error "An Invalid Setup has been detected for the current Transaction Type in Approvals Management. Please contact your System Administrator." For Any Transaction That Involves Approval',
      p_success_msg            => 'No approver groups with invalid and/or terminated employees found.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: APPROVER GROUPS WITH INVALID OR TERMINATED EMPLOYEES');



debug('begin add_signature: LOOP_SUPERVISOR_HIERARCHY');
   l_info('##MASK##EMPLOYEE_NUMBER'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##FULL_NAME'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##MASK##SUPERVISOR'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8856',
      p_sig_id                 => 'LOOP_SUPERVISOR_HIERARCHY',
      p_sig_sql                => 'SELECT
a.business_group_id, a."PERSON_ID",a.assignment_id, a."EMPLOYEE_NUMBER", a."FULL_NAME",
a."SUPERVISOR_ID", a."SUPERVISOR_EMP_NO", a."SUPERVISOR",
a."ORGANIZATION_ID",a."POSITION",
LEVEL level1,
CONNECT_BY_ROOT supervisor_emp_no top_supervisor,
CONNECT_BY_ISCYCLE loopback,
CONNECT_BY_ROOT supervisor_id as top_supervisor_id,
SYS_CONNECT_BY_PATH (supervisor_emp_no, ''/'') PATH
FROM (SELECT
papf.business_group_id,
papf.person_id,
paaf.assignment_id,
papf.employee_number,
papf.full_name,
paaf.supervisor_id,
papf1.employee_number supervisor_emp_no,
papf1.full_name supervisor,
paaf.organization_id,
hr_general.DECODE_POSITION(paaf.position_id) position
FROM per_all_people_f papf,
per_all_assignments_f paaf,
per_all_people_f papf1
WHERE papf.person_id = paaf.person_id
AND papf1.person_id = paaf.supervisor_id
and papf.CURRENT_EMPLOYEE_FLAG = ''Y''
AND paaf.primary_flag = ''Y''
AND papf.business_group_id = paaf.business_group_id
AND papf1.business_group_id = papf.business_group_id
AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date
AND papf.effective_end_date
AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date
AND paaf.effective_end_date
AND TRUNC(SYSDATE) BETWEEN papf1.effective_start_date
AND papf1.effective_end_date
) a
where CONNECT_BY_ISCYCLE > 0
CONNECT BY NOCYCLE PRIOR a.person_id = a.supervisor_id
ORDER SIBLINGS BY a.person_id',
      p_title                  => 'Loop in the Supervisor Hierarchy',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Loop identified in the supervisor hierarchy.',
      p_solution               => 'You may encounter issues in approval process.<br>
Review [1627030.1] How to Identify a Loop in the Supervisor Hierarchy?',
      p_success_msg            => 'No loop identified in the supervisor hierarchy.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: LOOP_SUPERVISOR_HIERARCHY');



debug('begin add_signature: AME_APPROVERS_REGION_APPEND_TO_LIST');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8498',
      p_sig_id                 => 'AME_APPROVERS_REGION_APPEND_TO_LIST',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''AME_APPROVERS_REGION_APPEND_TO_LIST''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'AME: Append to List option on Approvers region (AME_APPROVERS_REGION_APPEND_TO_LIST)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Useful documentation [431815.1#profile1] Oracle Approvals Management (AME) Frequently asked Questions (FAQ) - section When using dynamic approvals, the user is allowed to insert any approver into any part of the list. This can break the requirement of always want a specific person to be the last approver.',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [431815.1] Oracle Approvals Management (AME) Frequently asked Questions (FAQ) ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: AME_APPROVERS_REGION_APPEND_TO_LIST');



debug('begin add_signature: AME_INSTALLATION_LEVEL2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9358',
      p_sig_id                 => 'AME_INSTALLATION_LEVEL2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
decode(to_char(pov.level_id),''10001'', ''Site'',
''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
from fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
where po.profile_option_name =''AME_INSTALLATION_LEVEL''
and pov.application_id = po.application_id
and po.profile_option_name = n.profile_option_name
and pov.profile_option_id = po.profile_option_id
and usr.user_id (+) = pov.level_value
and rsp.application_id (+) = pov.level_value_application_id
and rsp.responsibility_id (+) = pov.level_value
and app.application_id (+) = pov.level_value
and svr.node_id (+) = pov.level_value
and svr.node_id (+) = pov.level_value2
and org.organization_id (+) = pov.level_value
and n.language=''US''
and pov.level_id in (10001,10002,10005,10003,10006,10007)
order by pov.level_id,"Context"',
      p_title                  => 'AME:Installation Level (AME_INSTALLATION_LEVEL)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.',
      p_solution               => 'Useful documentation: [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups in AME.B
',
      p_success_msg            => 'Useful documentation: [434567.1] How to Access Oracle Approvals Management? HRMS Approvals Management (AME) Responsibilities and Setups in AME.B ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: AME_INSTALLATION_LEVEL2');



debug('begin add_signature: AME_INSTALLED_FLAG2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9359',
      p_sig_id                 => 'AME_INSTALLED_FLAG2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
decode(to_char(pov.level_id),''10001'', ''Site'',
''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
from fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
where po.profile_option_name =''AME_INSTALLED_FLAG''
and pov.application_id = po.application_id
and po.profile_option_name = n.profile_option_name
and pov.profile_option_id = po.profile_option_id
and usr.user_id (+) = pov.level_value
and rsp.application_id (+) = pov.level_value_application_id
and rsp.responsibility_id (+) = pov.level_value
and app.application_id (+) = pov.level_value
and svr.node_id (+) = pov.level_value
and svr.node_id (+) = pov.level_value2
and org.organization_id (+) = pov.level_value
and n.language=''US''
and pov.level_id in (10001,10002,10005,10003,10006,10007)
order by pov.level_id,"Context"',
      p_title                  => 'AME:Installed (AME_INSTALLED_FLAG)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.',
      p_solution               => 'In order to collect information for a particular application_id use [287255.1] HRMS Approvals Management (AME) Reporting Utility Support Tool<br>
Troubleshooting steps available in [883338.1] Help Documentation on Supporting AME Issues and Different Diagnostic Steps',
      p_success_msg            => 'In order to collect information for a particular application_id use [287255.1] HRMS Approvals Management (AME) Reporting Utility Support Tool<br>
Troubleshooting steps available in [883338.1] Help Documentation on Supporting AME Issues and Different Diagnostic Steps',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: AME_INSTALLED_FLAG2');



debug('begin add_signature: PER_EX_SECURITY_PROFILE2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9363',
      p_sig_id                 => 'PER_EX_SECURITY_PROFILE2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_EX_SECURITY_PROFILE''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Access Non-Current Employee Data (PER_EX_SECURITY_PROFILE)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in <br>
[848518.1] How To View Ex-Employee and Future Dated Employee Records Data When Security Profile Is Enabled<br>
[1253694.1] Enabling Access to Ex-Employee and Future Dated Employee Records<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_solution               => '',
      p_success_msg            => 'Details in <br>
[848518.1] How To View Ex-Employee and Future Dated Employee Records Data When Security Profile Is Enabled<br>
[1253694.1] Enabling Access to Ex-Employee and Future Dated Employee Records<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: PER_EX_SECURITY_PROFILE2');



debug('begin add_signature: HR_DM_BG_LOCKOUT2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9365',
      p_sig_id                 => 'HR_DM_BG_LOCKOUT2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''HR_DM_BG_LOCKOUT''
        and    pov.application_id (+) = po.application_id
        and    po.profile_option_name (+) = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Data Migrator Business Group Lockout (HR_DM_BG_LOCKOUT)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Security profile is configured by organization hierarchy and when querying Employees the Search returns employees within a organization which is not defined in the Security Profile configuration.',
      p_solution               => 'The functionality of the profile "HR: Data Migrator Business Group Lockout" is to null the profile options for business group and security profile for those Business Group which is set as value to the profile "HR: Data Migrator Business Group Lockout".<br>
So when you set a particular Business Group value against the profile "HR: Data Migrator Business Group Lockout", the profile options values set for business group and security profile for that business group are nullified and cleared allowing the system to work as Open security profile configuration. Hence bringing all the data.<br>
Details in [2170727.1] HR Security Profile Not Working',
      p_success_msg            => 'No value setup for the profile "HR: Data Migrator Business Group Lockout". This is the correct setup as per [2170727.1] HR Security Profile Not Working',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: HR_DM_BG_LOCKOUT2');



debug('begin add_signature: HR_DEFER_UPDATE FOR AME');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8496',
      p_sig_id                 => 'HR_DEFER_UPDATE FOR AME',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''HR_DEFER_UPDATE''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR:Defer Update After Approval (HR_DEFER_UPDATE)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Useful documentation [431815.1#profile2] Oracle Approvals Management (AME) Frequently asked Questions (FAQ) - section When a transaction is approved the status still remains as ''Pending Approval''',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [431815.1] Oracle Approvals Management (AME) Frequently asked Questions (FAQ) ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: HR_DEFER_UPDATE FOR AME');



debug('begin add_signature: PER_RTM_SECURITY_PROFILE2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9366',
      p_sig_id                 => 'PER_RTM_SECURITY_PROFILE2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_RTM_SECURITY_PROFILE''
        and    pov.application_id (+) = po.application_id
        and    po.profile_option_name (+) = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Enable RTM Security (PER_RTM_SECURITY_PROFILE)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The Applicants, Ex-Applicants, Employee.Ex-Applicants records cannot restrict via security profile. ',
      p_solution               => 'The functionality was created and delivered in a new profile called ''HR: Enable RTM Security''. If this profile is set to ''Yes'' and logged in person is an recruiting team member of the vacancy, application will give access to all the applicants of that vacancy despite of HR Security.<br>
Details in [2301785.1] The Applicants, Ex-Applicants, Employee.Ex-Applicants cannot restrict via Security Profiles.',
      p_success_msg            => 'If you have security profile attached to a responsibility and if you do want to access the applicant (Applicants, Ex-Applicants, Employee.Ex-Applicants) records then profile ''HR: Enable RTM Security'' should be set to ''No''.<br>
Details in [2301785.1] The Applicants, Ex-Applicants, Employee.Ex-Applicants cannot restrict via Security Profiles.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: PER_RTM_SECURITY_PROFILE2');



debug('begin add_signature: HR_VIEW_TERM_PEOPLE_INSRCH2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9360',
      p_sig_id                 => 'HR_VIEW_TERM_PEOPLE_INSRCH2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''HR_VIEW_TERM_PEOPLE_INSRCH''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Include Terminated People in Search (HR_VIEW_TERM_PEOPLE_INSRCH)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile level defined.<br>
Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: HR_VIEW_TERM_PEOPLE_INSRCH2');



debug('begin add_signature: PER_SECURITY_PROFILE_ID2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9364',
      p_sig_id                 => 'PER_SECURITY_PROFILE_ID2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_SECURITY_PROFILE_ID''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Security Profile (PER_SECURITY_PROFILE_ID)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[468932.1] Employee Directory Search Displaying All Employees Ignoring the Security Profile<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications',
      p_solution               => '',
      p_success_msg            => 'Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[468932.1] Employee Directory Search Displaying All Employees Ignoring the Security Profile<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: PER_SECURITY_PROFILE_ID2');



debug('begin add_signature: ENABLE_SECURITY_GROUPS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5522',
      p_sig_id                 => 'ENABLE_SECURITY_GROUPS',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''ENABLE_SECURITY_GROUPS''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile Enable Security Groups (ENABLE_SECURITY_GROUPS)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Review [412152.1] How Can I Know if I am Working on Enable Security Group or Standard Security Model?<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications<br>
[412152.1] How Can I Know if I�m Working on Enable Security Group or Standard Security Model?<br>',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N'),
      p_version                => '15'
      );
   l_info.delete;
debug('end add_signature: ENABLE_SECURITY_GROUPS');



debug('begin add_signature: ENABLE_SECURITY_GROUPS2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9361',
      p_sig_id                 => 'ENABLE_SECURITY_GROUPS2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name ,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''ENABLE_SECURITY_GROUPS''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
and pov.profile_option_value = ''Y''
        order by pov.level_id,"Context"',
      p_title                  => 'Profile Enable Security Groups (ENABLE_SECURITY_GROUPS) Set to Yes',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'It appears that the System Profile "Enable Security Groups" has been enabled in your instance. With this enabled for any application in the HCM suite, making any change to the System Administrator > Profile > System > HR: Security Profile will have no effect. You must use the (N)->Security->Assign Security Profiles form under the HRMS Manager responsibility you normally use for the security profile to have any effect.
',
      p_solution               => 'Review [412152.1] How Can I Know if Working on Enable Security Group or Standard Security Model?<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: ENABLE_SECURITY_GROUPS2');



debug('begin add_signature: ProfileENABLE_SECURITY_GROUPS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1468',
      p_sig_id                 => 'ProfileENABLE_SECURITY_GROUPS',
      p_sig_sql                => 'select  po.profile_option_name "Profile",
decode(pov.level_id, 10001, ''Site'',
        10002, ''Application'',
        10003, ''Responsibility'',
        10004, ''User'') "Level",
pov.profile_option_value "Value" from   fnd_profile_options po,  fnd_profile_option_values pov
WHERE   po.profile_option_name = ''ENABLE_SECURITY_GROUPS''
         AND     po.application_id = 0
         AND     po.profile_option_id = pov.profile_option_id
         AND     po.application_id = pov.application_id
         AND     (pov.level_id = 10002  AND  hr_general.chk_application_id (pov.level_value) = ''TRUE'')
         AND     pov.profile_option_value = ''Y''',
      p_title                  => 'Multiple Security Group',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Multiple Security Group is enabled.
Details in<br>
[758275.1] Is There a Datafix To Rollback when Process Enable Multiple Security Groups Is Run? <br>
[1680048.1] Can Multiple Security Groups be used outside of the HRMS Application? <br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications
',
      p_solution               => '',
      p_success_msg            => 'Multiple Security Group is NOT enabled.
Details in<br>
[758275.1] Is There a Datafix To Rollback when Process Enable Multiple Security Groups Is Run? <br>
[1680048.1] Can Multiple Security Groups be used outside of the HRMS Application? <br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: ProfileENABLE_SECURITY_GROUPS');



debug('begin add_signature: ORG_ID2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9362',
      p_sig_id                 => 'ORG_ID2',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''ORG_ID''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'MO: Operating Unit (ORG_ID)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications
',
      p_solution               => '',
      p_success_msg            => 'Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: ORG_ID2');



debug('begin add_signature: AME_EXCEPTIONS_LOG');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8656',
      p_sig_id                 => 'AME_EXCEPTIONS_LOG',
      p_sig_sql                => 'SELECT *
  FROM AME_EXCEPTIONS_LOG
WHERE TRANSACTION_ID = ''##$$TRID$$##''
     AND APPLICATION_ID = ''##$$AMEAPPID$$##''
ORDER BY LOG_ID',
      p_title                  => 'AME Exception Log',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Log messages from AME_EXCEPTIONS_LOG for this transaction.',
      p_solution               => '[2318305.1] Steps to collect AME exception log',
      p_success_msg            => 'No log message for this transaction.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: AME_EXCEPTIONS_LOG');



debug('begin add_signature: AME_EXCE_STR_BUFFER_TOO_SMALL');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '15200',
      p_sig_id                 => 'AME_EXCE_STR_BUFFER_TOO_SMALL',
      p_sig_sql                => 'SELECT LOG_ID, PACKAGE_NAME, ROUTINE_NAME, EXCEPTION_NUMBER, EXCEPTION_STRING, SECURITY_GROUP_ID
FROM AME_EXCEPTIONS_LOG
WHERE UPPER(EXCEPTION_STRING) LIKE UPPER(''ORA-06502:%PL/SQL: numeric or value error: character string buffer too small%'')
AND TRANSACTION_ID = ''##$$TRID$$##''',
      p_title                  => 'AME Exceptions Character String Buffer Too Small',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'TransactionID fails with ORA-06502:PL/SQL: numeric or value error: character string buffer too small in AME Exceptions Log.',
      p_solution               => 'Please follow instructions to debug and resolve the issue:<br>
[430232.1] - Testing A Real Transaction Fails With ORA-06502',
      p_success_msg            => 'No AME Exceptions ORA-06502: PL/SQL for this transaction.',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: AME_EXCE_STR_BUFFER_TOO_SMALL');



debug('begin add_signature: WORKFLOW');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5434',
      p_sig_id                 => 'WORKFLOW',
      p_sig_sql                => 'SELECT TEXT Workflow_Version
      FROM WF_RESOURCES
      WHERE TYPE = ''WFTKN''
        AND NAME = ''WF_VERSION''
        AND LANGUAGE = ''US''',
      p_title                  => 'Workflow Version',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Workflow version',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: WORKFLOW');



debug('begin add_signature: EBS_HCM_HR_HRTECHNICAL_BUSINESS_GROUP_INFO_KFF');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '24503',
      p_sig_id                 => 'EBS_HCM_HR_HRTECHNICAL_BUSINESS_GROUP_INFO_KFF',
      p_sig_sql                => 'SELECT
    fifs.id_flex_structure_code,
    fifs.freeze_flex_definition_flag,
    fifs.enabled_flag,
    fifs.dynamic_inserts_allowed_flag,
    seg.segment_num,
    seg.segment_name,
    seg.application_column_name,
    seg.enabled_flag   AS segments_enabled_flag,
    seg.required_flag,
    vs.flex_value_set_name,
    frmt.meaning       AS format_type,
    vdn.meaning        AS validation_type
FROM
    fnd_lookup_values             vdn,
    fnd_lookup_values             frmt,
    fnd_flex_value_sets           vs,
    fnd_id_flex_segments          seg,
    fnd_id_flex_structures        fifs,
    hr_organization_information   clas,
    hr_all_organization_units     org
WHERE
    1 = 1
    AND vdn.lookup_code (+) = vs.validation_type
    AND vdn.lookup_type (+) = ''SEG_VAL_TYPES''
    AND vdn.language (+) = ''US''
    AND frmt.lookup_code (+) = vs.format_type
    AND frmt.lookup_type (+) = ''FIELD_TYPE''
    AND frmt.language (+) = ''US''
    AND vs.flex_value_set_id (+) = seg.flex_value_set_id
    AND seg.id_flex_code (+) = fifs.id_flex_code
    AND seg.id_flex_num (+) = fifs.id_flex_num
    AND ( ( fifs.id_flex_num = clas.org_information4 AND fifs.id_flex_code = ''GRD'' )
          OR ( fifs.id_flex_num = clas.org_information5 AND fifs.id_flex_code = ''GRP'' )
          OR ( fifs.id_flex_num = clas.org_information6 AND fifs.id_flex_code = ''JOB'' )
          OR ( fifs.id_flex_num = clas.org_information7 AND fifs.id_flex_code = ''COST'' )
          OR ( fifs.id_flex_num = clas.org_information8 AND fifs.id_flex_code = ''POS'' )
          OR ( fifs.id_flex_num = clas.org_information15 AND fifs.id_flex_code = ''CMP'' ) )
    AND clas.org_information_context = ''Business Group Information''
    AND clas.organization_id = org.organization_id
	AND org.business_group_id = ##$$FK1$$##
ORDER BY fifs.id_flex_structure_code, application_column_name',
      p_title                  => 'Business Group KFF Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'This displays all Key FlexField (KFF) Structure Segments for the Business Group.',
      p_solution               => 'Please check if any of the KFF segments are not frozen and compiled. If so, please compile them.

Reference Note:
[451949.1] - Changing Job on Employee Assignment, error''s: APP-FND-00690: Program error: The data that defines the flexfield on this field may be inconsistent',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '2'
      );
   l_info.delete;
debug('end add_signature: EBS_HCM_HR_HRTECHNICAL_BUSINESS_GROUP_INFO_KFF');



debug('begin add_signature: BUSINESS_GROUPS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '3463',
      p_sig_id                 => 'BUSINESS_GROUPS',
      p_sig_sql                => 'SELECT org.organization_id as "Bus Grp ID",org.organization_id as "##$$FK1$$##", org.NAME as "Organization Name",hoi.org_information2 as "Enabled",
       org.date_from as "Date From", org.date_to as "Date To",
       hr_general.decode_lookup(''EMP_NUM_GEN_METHOD'',clas.org_information2) as "Emp No. Generation",
       hr_general.decode_lookup(''APL_NUM_GEN_METHOD'',clas.org_information3) as "Appl No. Generation",
       hr_general.decode_lookup(''CWK_NUM_GEN_METHOD'',clas.org_information16) as "CWK No. Generation",
       grd.id_flex_structure_name as "Grade KFF",
       grp.id_flex_structure_name as "People Group KFF",
       job.id_flex_structure_name as "Job KFF",
       cost.id_flex_structure_name as "Cost KFF",
       pos.id_flex_structure_name as "Position KFF",
       comp.id_flex_structure_name as "Competance KFF",
       ter.territory_short_name as "Leg Code",
       clas.org_information10 as "Currency"
  FROM fnd_territories_vl ter,
       fnd_id_flex_structures_vl comp,
       fnd_id_flex_structures_vl pos,
       fnd_id_flex_structures_vl cost,
       fnd_id_flex_structures_vl job,
       fnd_id_flex_structures_vl grp,
       fnd_id_flex_structures_vl grd,
       hr_organization_information clas,
       hr_organization_information hoi,
       hr_all_organization_units org
 WHERE 1 = 1
   AND ter.territory_code = clas.org_information9
   AND comp.id_flex_num = clas.org_information15
   AND comp.id_flex_code = ''CMP''
   AND pos.id_flex_num = clas.org_information8
   AND pos.id_flex_code = ''POS''
   AND cost.id_flex_num = clas.org_information7
   AND cost.id_flex_code = ''COST''
   AND job.id_flex_num = clas.org_information6
   AND job.id_flex_code = ''JOB''
   AND grp.id_flex_num = clas.org_information5
   AND grp.id_flex_code = ''GRP''
   AND grd.id_flex_num = clas.org_information4
   AND grd.id_flex_code = ''GRD''
   AND clas.org_information_context = ''Business Group Information''
   AND clas.organization_id = hoi.organization_id
   AND hoi.org_information_context = ''CLASS''
   AND hoi.org_information1 = ''HR_BG''
   AND hoi.organization_id = org.organization_id
order by org.organization_id',
      p_title                  => 'Business Group Details (HR_ALL_ORGANIZATION_UNITS )',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'This is a data collection of all business group details.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('EBS_HCM_HR_HRTECHNICAL_BUSINESS_GROUP_INFO_KFF'),
      p_include_in_dx_summary  => nvl('Y','N'),
      p_version                => '12'
      );
   l_info.delete;
debug('end add_signature: BUSINESS_GROUPS');



debug('begin add_signature: Currency_not_USD');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1368',
      p_sig_id                 => 'Currency_not_USD',
      p_sig_sql                => 'select o3.ORG_INFORMATION10 currency
            FROM HR_ALL_ORGANIZATION_UNITS O ,
				HR_ALL_ORGANIZATION_UNITS_TL OTL ,
				HR_ORGANIZATION_INFORMATION O2 ,
				HR_ORGANIZATION_INFORMATION O3 ,
				HR_ORGANIZATION_INFORMATION O4
				WHERE O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O2.ORGANIZATION_ID (+)
				AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O4.ORGANIZATION_ID
				AND O3.ORG_INFORMATION_CONTEXT = ''Business Group Information''
				AND O2.ORG_INFORMATION_CONTEXT (+) = ''Work Day Information''
				AND O4.ORG_INFORMATION_CONTEXT = ''CLASS''
				AND O4.ORG_INFORMATION1 = ''HR_BG'' AND O4.ORG_INFORMATION2 = ''Y''
				AND OTL.LANGUAGE = ''US''
				and O.ORGANIZATION_ID=0',
      p_title                  => 'Currency of the Setup Business Group',
      p_fail_condition         => '[currency]<>[USD]',
      p_problem_descr          => 'Current currency is not USD. Changing the Currency of the Setup Business Group is never allowed under any condition!',
      p_solution               => 'Please review: [815934.1] After Upgrade - Setup Business Group Name Reverts Back To Setup Business Group<br>
[796593.1]Can the Setup Business Group name be Changed?',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: Currency_not_USD');



debug('begin add_signature: Legislation_not_US');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1367',
      p_sig_id                 => 'Legislation_not_US',
      p_sig_sql                => 'select o3.ORG_INFORMATION9 legislation FROM HR_ALL_ORGANIZATION_UNITS O ,
				HR_ALL_ORGANIZATION_UNITS_TL OTL ,
				HR_ORGANIZATION_INFORMATION O2 ,
				HR_ORGANIZATION_INFORMATION O3 ,
				HR_ORGANIZATION_INFORMATION O4
				WHERE O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O2.ORGANIZATION_ID (+)
				AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O4.ORGANIZATION_ID
				AND O3.ORG_INFORMATION_CONTEXT = ''Business Group Information''
				AND O2.ORG_INFORMATION_CONTEXT (+) = ''Work Day Information''
				AND O4.ORG_INFORMATION_CONTEXT = ''CLASS''
				AND O4.ORG_INFORMATION1 = ''HR_BG'' AND O4.ORG_INFORMATION2 = ''Y''
				AND OTL.LANGUAGE = ''US''
				and O.ORGANIZATION_ID=0',
      p_title                  => 'Legislation of the Setup Business Group',
      p_fail_condition         => '[legislation] <> [US]',
      p_problem_descr          => 'Legislation of the Setup Business Group is not US. Changing the Legislation of the Setup Business Group is never allowed under any condition!',
      p_solution               => 'Please review: [815934.1] After Upgrade - Setup Business Group Name Reverts Back To Setup Business Group<br>
[796593.1]Can the Setup Business Group name be Changed? ',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: Legislation_not_US');



debug('begin add_signature: Setup_Name');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1369',
      p_sig_id                 => 'Setup_Name',
      p_sig_sql                => 'select otl.name name,
             o3.ORG_INFORMATION9 legislation,
             o3.ORG_INFORMATION10 currency
            FROM HR_ALL_ORGANIZATION_UNITS O ,
				HR_ALL_ORGANIZATION_UNITS_TL OTL ,
				HR_ORGANIZATION_INFORMATION O2 ,
				HR_ORGANIZATION_INFORMATION O3 ,
				HR_ORGANIZATION_INFORMATION O4
				WHERE O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O2.ORGANIZATION_ID (+)
				AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
				AND O.ORGANIZATION_ID = O4.ORGANIZATION_ID
				AND O3.ORG_INFORMATION_CONTEXT = ''Business Group Information''
				AND O2.ORG_INFORMATION_CONTEXT (+) = ''Work Day Information''
				AND O4.ORG_INFORMATION_CONTEXT = ''CLASS''
				AND O4.ORG_INFORMATION1 = ''HR_BG'' AND O4.ORG_INFORMATION2 = ''Y''
				AND OTL.LANGUAGE = ''US''
				and O.ORGANIZATION_ID=0',
      p_title                  => 'Setup Business Group Name',
      p_fail_condition         => '[name] <> [Setup Business Group]',
      p_problem_descr          => 'Current organization name for Setup Business Group is not Setup Business Group.',
      p_solution               => 'Please review: [815934.1] After Upgrade - Setup Business Group Name Reverts Back To Setup Business Group<br>
[796593.1]Can the Setup Business Group name be Changed?',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: Setup_Name');



debug('begin add_signature: CLASSIFICATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5437',
      p_sig_id                 => 'CLASSIFICATION',
      p_sig_sql                => 'select hou.BUSINESS_GROUP_ID,
             hou.ORGANIZATION_ID,
             substr(hou.NAME,1,30) Name,
             hoiv.ORG_INFORMATION1_MEANING Organization_Classifications,
             hoiv.ORG_INFORMATION2_MEANING Enabled
      from HR_ALL_ORGANIZATION_UNITS hou,
           HR_ORGANIZATION_INFORMATION_V hoiv
      where hou.ORGANIZATION_ID = hoiv.ORGANIZATION_ID
      and hoiv.ORG_INFORMATION1_MEANING IS NOT NULL
      order by hou.BUSINESS_GROUP_ID, hou.ORGANIZATION_ID, hoiv.ORG_INFORMATION1_MEANING',
      p_title                  => 'Business Group Sub-Organizations and Classification Details',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'This is a data collection of the business groups and the attached sub-organizations and their classifications and statuses.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '6'
      );
   l_info.delete;
debug('end add_signature: CLASSIFICATION');



debug('begin add_signature: HR_VIEW_TERM_PEOPLE_INSRCH');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5521',
      p_sig_id                 => 'HR_VIEW_TERM_PEOPLE_INSRCH',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''HR_VIEW_TERM_PEOPLE_INSRCH''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile HR: Include Terminated People in Search',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile level defined.<br>
Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: HR_VIEW_TERM_PEOPLE_INSRCH');



debug('begin add_signature: ORG_ID');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5523',
      p_sig_id                 => 'ORG_ID',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''ORG_ID''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile MO: Operating Unit',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications
',
      p_solution               => '',
      p_success_msg            => 'Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '9'
      );
   l_info.delete;
debug('end add_signature: ORG_ID');



debug('begin add_signature: PER_EX_SECURITY_PROFILE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5524',
      p_sig_id                 => 'PER_EX_SECURITY_PROFILE',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_EX_SECURITY_PROFILE''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile HR: Access Non-Current Employee Data',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in <br>
[848518.1] How To View Ex-Employee and Future Dated Employee Records Data When Security Profile Is Enabled<br>
[1253694.1] Enabling Access to Ex-Employee and Future Dated Employee Records<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_solution               => '',
      p_success_msg            => 'Details in <br>
[848518.1] How To View Ex-Employee and Future Dated Employee Records Data When Security Profile Is Enabled<br>
[1253694.1] Enabling Access to Ex-Employee and Future Dated Employee Records<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '9'
      );
   l_info.delete;
debug('end add_signature: PER_EX_SECURITY_PROFILE');



debug('begin add_signature: PER_SECURITY_PROFILE_ID');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5525',
      p_sig_id                 => 'PER_SECURITY_PROFILE_ID',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_SECURITY_PROFILE_ID''
        and    pov.application_id = po.application_id
        and    po.profile_option_name = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
       and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile HR: Security Profile',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No profile values defined.<br>
Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[468932.1] Employee Directory Search Displaying All Employees Ignoring the Security Profile<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications',
      p_solution               => '',
      p_success_msg            => 'Details in<br>
[394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[468932.1] Employee Directory Search Displaying All Employees Ignoring the Security Profile<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security,MultiOrg,Multi Org Access Control(MOAC),Operating Unit,Operating Unit Information,Inventory Organization,and Accounting Information Support in Relation to Oracle Human Resources Applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '10'
      );
   l_info.delete;
debug('end add_signature: PER_SECURITY_PROFILE_ID');



debug('begin add_signature: DATA MIGRATOR BUSINESS GROUP LOCKOUT PROFILE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8254',
      p_sig_id                 => 'DATA MIGRATOR BUSINESS GROUP LOCKOUT PROFILE',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''HR_DM_BG_LOCKOUT''
        and    pov.application_id (+) = po.application_id
        and    po.profile_option_name (+) = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'Profile HR: Data Migrator Business Group Lockout (HR_DM_BG_LOCKOUT)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Security profile is configured by organization hierarchy and when querying Employees the Search returns employees within a organization which is not defined in the Security Profile configuration.',
      p_solution               => 'The functionality of the profile "HR: Data Migrator Business Group Lockout" is to null the profile options for business group and security profile for those Business Group which is set as value to the profile "HR: Data Migrator Business Group Lockout".<br>
So when you set a particular Business Group value against the profile "HR: Data Migrator Business Group Lockout", the profile options values set for business group and security profile for that business group are nullified and cleared allowing the system to work as Open security profile configuration. Hence bringing all the data.<br>
Details in [2170727.1] HR Security Profile Not Working',
      p_success_msg            => 'OK! No value setup for the profile "HR: Data Migrator Business Group Lockout". ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '8'
      );
   l_info.delete;
debug('end add_signature: DATA MIGRATOR BUSINESS GROUP LOCKOUT PROFILE');



debug('begin add_signature: ENABLE RTM SECURITY PROFILE VALUES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8253',
      p_sig_id                 => 'ENABLE RTM SECURITY PROFILE VALUES',
      p_sig_sql                => 'select decode(to_char(pov.level_id),''10001'', ''Site'',''10002'', ''Application'',''10003'', ''Responsibility'',''10005'', ''Server'',''10006'', ''Org'',''10007'', ''Servresp'', ''???'') "Level" ,
       decode(to_char(pov.level_id),''10001'', ''Site'',
              ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),
              ''10005'', svr.node_name,''10006'', org.name,''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,''???'') "Context", pov.profile_option_value "Profile Value"
        from   fnd_profile_options po,fnd_profile_option_values pov,fnd_profile_options_tl n,
               fnd_user usr,fnd_application app,fnd_responsibility_vl rsp,fnd_nodes svr,hr_operating_units org
        where  po.profile_option_name =''PER_RTM_SECURITY_PROFILE''
        and    pov.application_id (+) = po.application_id
        and    po.profile_option_name (+) = n.profile_option_name
        and    pov.profile_option_id = po.profile_option_id
        and    usr.user_id (+) = pov.level_value
        and    rsp.application_id (+) = pov.level_value_application_id
        and    rsp.responsibility_id (+) = pov.level_value
        and    app.application_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value
        and    svr.node_id (+) = pov.level_value2
        and    org.organization_id (+) = pov.level_value
	and    n.language=''US''
        and (pov.level_id in (10001,10002,10005,10006,10007) or ( pov.level_id=10003 and rsp.APPLICATION_ID in (453,805,8301,800,8403,801,8401,8302,8303,809,808,810)))
        order by pov.level_id,"Context"',
      p_title                  => 'HR: Enable RTM Security (PER_RTM_SECURITY_PROFILE)',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The Applicants, Ex-Applicants, Employee.Ex-Applicants records cannot restrict via security profile. ',
      p_solution               => 'The functionality was created and delivered in a new profile called ''HR: Enable RTM Security''. If this profile is set to ''Yes'' and logged in person is an recruiting team member of the vacancy, application will give access to all the applicants of that vacancy despite of HR Security.<br>
Details in [2301785.1] The Applicants, Ex-Applicants, Employee.Ex-Applicants cannot restrict via Security Profiles.',
      p_success_msg            => 'If you have security profile attached to a responsibility and if you do want to access the applicant (Applicants, Ex-Applicants, Employee.Ex-Applicants) records then profile ''HR: Enable RTM Security'' should be set to ''No''.<br>
Details in [2301785.1] The Applicants, Ex-Applicants, Employee.Ex-Applicants cannot restrict via Security Profiles.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: ENABLE RTM SECURITY PROFILE VALUES');



debug('begin add_signature: MOBILE_USERS');
   l_info('##MASK##USER_NAME'):= 'DISPLAY_BOTH_25_PCNT_WORD';
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5538',
      p_sig_id                 => 'MOBILE_USERS',
      p_sig_sql                => 'select
furg.USER_ID,
furg.RESPONSIBILITY_ID,
fuser.USER_NAME,
frtl.RESPONSIBILITY_NAME,
fuser.start_date,
fuser.end_date
from FND_USER_RESP_GROUPS furg,
FND_USER fuser,
FND_RESPONSIBILITY_TL frtl
where furg.USER_ID = fuser.USER_ID
and furg.RESPONSIBILITY_ID = frtl.RESPONSIBILITY_ID
and frtl.RESPONSIBILITY_NAME like ''%Mobile Applications Manager%''
order by fuser.USER_NAME',
      p_title                  => 'Users with Mobile Applications Manager Responsibility',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No user with Mobile Applications Manager responsibility.',
      p_solution               => '',
      p_success_msg            => 'This section displays all users with Mobile Applications Manager responsibility.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: MOBILE_USERS');



debug('begin add_signature: PREMIER_SUPPORT_11.5');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '17951',
      p_sig_id                 => 'PREMIER_SUPPORT_11.5',
      p_sig_sql                => 'select release_name from fnd_product_groups
where release_name like ''11.5%''',
      p_title                  => 'Application Version 11.5',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Premier Support for the application version on this instance ended on November 2010. Please refer to  Oracle''s Lifetime Support Policy<br>
Ignore this warning if you have upgraded since this analyzer output was generated.',
      p_solution               => 'Please consider these timelines for upgrade planning. Updating the application version will ensure you have access to major product releases.<br>
Review [2655839.2#supportp] Applications Lifetime Support Policy',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '10'
      );
   l_info.delete;
debug('end add_signature: PREMIER_SUPPORT_11.5');



debug('begin add_signature: PREMIER_SUPPORT_12.0');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '17602',
      p_sig_id                 => 'PREMIER_SUPPORT_12.0',
      p_sig_sql                => 'select release_name from fnd_product_groups
where release_name like ''12.0%''',
      p_title                  => 'Application Version 12.0',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Premier Support for the application version on this instance ended on January 2012. Please refer to Oracle''s Lifetime Support Policy.<br>Ignore this warning if you have upgraded since this analyzer output was generated.',
      p_solution               => 'Please consider these timelines for upgrade planning. Updating the application version will ensure you have access to major product releases.<br>
Refer [2655839.2#supportp] Applications Lifetime Support Policy',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '13'
      );
   l_info.delete;
debug('end add_signature: PREMIER_SUPPORT_12.0');



debug('begin add_signature: PREMIER_SUPPORT_12.1');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '17952',
      p_sig_id                 => 'PREMIER_SUPPORT_12.1',
      p_sig_sql                => 'select release_name from fnd_product_groups
where release_name like ''12.1%''',
      p_title                  => 'Application Version 12.1',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Premier Support End for the application version on this instance: December 2021. Please refer to Oracle''s Lifetime Support Policy. <br>Ignore this warning if you have upgraded since this analyzer output was generated.',
      p_solution               => 'Updating the application version will ensure you have access to major product releases.<br>
Refer [2655839.2#supportp] Applications Lifetime Support Policy<br>
If you are an Oracle-E-Business Suite Release 12.1.3 customer that is planning to upgrade to EBS 12.2 or move to Oracle SaaS, but are not able to complete the transition prior to January 1, 2022, you may use Oracle Market Driven Support (MDS) to bridge the support gap.  Additional details regarding MDS for EBS 12.1.3 are available here<br>
[2829137.1] ANNOUNCEMENT: Additional Coverage Options for 12.1.3 E-Business Suite Sustaining Support',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '11'
      );
   l_info.delete;
debug('end add_signature: PREMIER_SUPPORT_12.1');



debug('begin add_signature: PREMIER_SUPPORT_DB_CHECK_11');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '17954',
      p_sig_id                 => 'PREMIER_SUPPORT_DB_CHECK_11',
      p_sig_sql                => 'SELECT banner from V$VERSION WHERE ROWNUM = 1
and (banner like ''%11.2%'' or banner like ''%11.1%'' or banner like ''%10.%'')',
      p_title                  => 'Database in Sustaining Support',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The database version running on this instance is in Sustaining Support. Please refer to Lifetime Support Policy: Oracle Technology Products (PDF) - Oracle Database Releases.<br>Ignore this warning if you have upgraded since this analyzer output was generated.',
      p_solution               => 'We recommend upgrading the database version. Refer to [2655839.2#supportp] Applications Lifetime Support Policy',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: PREMIER_SUPPORT_DB_CHECK_11');



debug('begin add_signature: PREMIER_SUPPORT_DB_CHECK_12.1');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '17955',
      p_sig_id                 => 'PREMIER_SUPPORT_DB_CHECK_12.1',
      p_sig_sql                => 'SELECT banner from V$VERSION WHERE ROWNUM = 1
and (banner like ''%12.1%'')',
      p_title                  => 'Database in Extended Support',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'The database version running on this instance is in Extended Support. Please refer to Lifetime Support Policy: Oracle Technology Products (PDF) - Oracle Database Releases.<br>Ignore this warning if you have upgraded since this analyzer output was generated.',
      p_solution               => 'We recommend upgrading the database version. Refer to [2655839.2#supportp] Applications Lifetime Support Policy',
      p_success_msg            => '',
      p_print_condition        => nvl('FAILURE','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: PREMIER_SUPPORT_DB_CHECK_12.1');



debug('begin add_signature: GATHER_GENERIC_2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9629',
      p_sig_id                 => 'GATHER_GENERIC_2',
      p_sig_sql                => 'SELECT substr(UPPER(ARGUMENT_TEXT),1,3) "Schema", PHAS.MEANING "Completion", STAT.MEANING "Status", ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
AND PT.LANGUAGE = ''US'' and
STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''%GATHER SCHEMA%''
AND ACTUAL_COMPLETION_DATE>sysdate-30
ORDER BY 4 desc',
      p_title                  => 'Gather Schema Statistics in Last Month',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No records available in concurrent requests table related to Gather schema statistics process.',
      p_solution               => 'Purge Concurrent Request and/or Manager Data process was performed, so information was purged from concurrent requests table.<br>
We cannot determine if Gather schema statistics process was performed in last month.<br>
In order to gather schema statistics schedule use [419728.1] Concurrent Processing - How To Gather Statistics On Oracle Applications Release 11i and/or Release 12 - Concurrent Process,Temp Tables, Manually.<br>
Note! You can ignore the warning if you are manually gathering statistics using FND_STATS.GATHER_SCHEMA_STATS.
',
      p_success_msg            => 'OK! Gather schema statistics was performed in the last month.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: GATHER_GENERIC_2');



debug('begin add_signature: GATHER_GENERIC');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8495',
      p_sig_id                 => 'GATHER_GENERIC',
      p_sig_sql                => 'SELECT substr(UPPER(ARGUMENT_TEXT),1,3) "Schema", PHAS.MEANING "Completion", STAT.MEANING "Status", ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
AND PT.LANGUAGE = ''US'' and
STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''%GATHER SCHEMA%''
AND ACTUAL_COMPLETION_DATE>sysdate-30
ORDER BY 4 desc',
      p_title                  => 'Gather Schema Statistics in Last Month',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Gather schema statistics was never performed in the last month.',
      p_solution               => 'In order to gather schema statistics schedule use [419728.1] Concurrent Processing - How To Gather Statistics On Oracle Applications Release 11i and/or Release 12 - Concurrent Process,Temp Tables, Manually.<br>
Note! You can ignore the warning if you are manually gathering statistics using FND_STATS.GATHER_SCHEMA_STATS.
',
      p_success_msg            => 'OK! Gather schema statistics was performed in the last month.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: GATHER_GENERIC');



debug('begin add_signature: AME_WORKFLOW');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '9754',
      p_sig_id                 => 'AME_WORKFLOW',
      p_sig_sql                => 'select Completion_Date, ARGUMENT_TEXT from
(
SELECT ACTUAL_COMPLETION_DATE Completion_Date, ARGUMENT_TEXT
FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
AND PT.LANGUAGE = ''US'' and
STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''%WORKFLOW BACKGROUND%''
and PHAS.MEANING=''Completed'' and STAT.MEANING=''Normal''
ORDER BY 1 desc)
where rownum<5',
      p_title                  => 'Lastest Workflow Background Process Completed Normal',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Workflow Background Process never completed normal.<br>
You can ignore this warning if Workflow Background Process was performed before Purge Concurrent Request and/or Manager Data process (so information was purged from concurrent requests table).
',
      p_solution               => 'Review [317002.1] Approval Is Delayed In Defer Thread Activity ',
      p_success_msg            => 'This is a data collection of latest Workflow Background Process completing normal. <br>
Review [317002.1] Approval Is Delayed In Defer Thread Activity ',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: AME_WORKFLOW');



debug('begin add_signature: COMPLETE_DEFUNCT_HR2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8419',
      p_sig_id                 => 'COMPLETE_DEFUNCT_HR2',
      p_sig_sql                => 'SELECT substr(UPPER(ARGUMENT_TEXT),1,3) "Schema", ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
	FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
	WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
	AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
	AND PT.LANGUAGE = ''US'' and
	STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
	AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
	AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''COMPLETE DEFUNCT HR WORKFLOW%''
	and PHAS.MEANING=''Completed'' and STAT.MEANING=''Normal'' and ACTUAL_COMPLETION_DATE>sysdate-180
	ORDER BY 2 desc',
      p_title                  => 'Complete Defunct HR Workflow Processes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No records available in concurrent requests table related to Complete Defunct HR Workflow Processes process.
',
      p_solution               => 'Purge Concurrent Request and/or Manager Data process was performed, so information was purged from concurrent requests table.<br>
We cannot determine if Complete Defunct HR Workflow process was performed in last 6 months.<br>
Review [370095.1] How To Cancel / Delete HR Workflow Transactions / Notifications.',
      p_success_msg            => 'Complete Defunct HR Workflow process was performed in last 6 months.<br>
Useful documentation [370095.1] How To Cancel / Delete HR Workflow Transactions / Notifications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '5'
      );
   l_info.delete;
debug('end add_signature: COMPLETE_DEFUNCT_HR2');



debug('begin add_signature: Complete_defunct_HR');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '1386',
      p_sig_id                 => 'Complete_defunct_HR',
      p_sig_sql                => 'SELECT substr(UPPER(ARGUMENT_TEXT),1,3) "Schema", ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
	FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
	WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
	AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
	AND PT.LANGUAGE = ''US'' and
	STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
	AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
	AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''COMPLETE DEFUNCT HR WORKFLOW%''
	and PHAS.MEANING=''Completed'' and STAT.MEANING=''Normal'' and ACTUAL_COMPLETION_DATE>sysdate-180
	ORDER BY 2 desc',
      p_title                  => 'Complete Defunct HR Workflow Processes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Complete Defunct HR Workflow process not performed in last 6 months.',
      p_solution               => 'Review [370095.1] How To Cancel / Delete HR Workflow Transactions / Notifications.',
      p_success_msg            => 'Complete Defunct HR Workflow process was performed in last 6 months.<br>
Useful documentation [370095.1] How To Cancel / Delete HR Workflow Transactions / Notifications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '7'
      );
   l_info.delete;
debug('end add_signature: Complete_defunct_HR');



debug('begin add_signature: SECURITY1');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '6017',
      p_sig_id                 => 'SECURITY1',
      p_sig_sql                => 'SELECT security_profile_name "Security Profile Name"
,      security_profile_id "Security Profile Id"
,      NVL(business_group_name, ''Global'') "Business Group Name"
,      view_all_flag "View All Records"
,      decode(instr(view_all_organizations_flag||view_all_positions_flag||custom_restriction_flag, ''U''), 0, ''No'', ''Yes'') "User Based"
,      decode(view_all_employees_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Employees"
,      decode(view_all_cwk_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Contingent Workers"
,      decode(view_all_applicants_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Applicants"
,      decode(view_all_contacts_flag, ''Y'' , ''All'', ''N'', ''Restricted'',''Unknown'') "View Contacts"
,      decode(view_all_candidates_flag, ''Y'' , ''All'', ''X'',  ''None'', ''Unknown'') "View Candidates"
,      decode(view_all_organizations_flag, ''Y'' , ''No'', ''Yes'') "Organization Security"
,      decode(view_all_positions_flag, ''Y'' , ''No'', ''Yes'') "Position Security"
,      decode(view_all_payrolls_flag, ''Y'' , ''No'', ''Yes'') "Payroll Security"
,      decode(restrict_by_supervisor_flag, ''N'' , ''No'', ''Y'', ''Person Based'', ''A'', ''Assignment Based'',null, ''None'', ''Unknown'') "Supervisor Security"
,      custom_restriction_flag "Custom Security"
FROM  per_security_profiles_v
ORDER BY NVL(business_group_name, ''Global''), security_profile_name',
      p_title                  => 'Security Profiles (PER_SECURITY_PROFILES)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No security profile defined',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: SECURITY1');



debug('begin add_signature: SECURITY2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '6018',
      p_sig_id                 => 'SECURITY2',
      p_sig_sql                => 'SELECT security_profile_name "Security Profile Name"
,      security_profile_id "Security Profile Id"
,      NVL(business_group_name, ''Global'') "Business Group Name"
,      view_all_flag "View All Records"
,      decode(instr(view_all_organizations_flag||view_all_positions_flag||custom_restriction_flag, ''U''), 0, ''No'', ''Yes'') "User Based"
,      decode(view_all_employees_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Employees"
,      decode(view_all_cwk_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Contingent Workers"
,      decode(view_all_applicants_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Applicants"
,      decode(view_all_contacts_flag, ''Y'' , ''All'', ''N'', ''Restricted'',''Unknown'') "View Contacts"
,      decode(view_all_organizations_flag, ''Y'' , ''No'', ''Yes'') "Organization Security"
,      decode(view_all_positions_flag, ''Y'' , ''No'', ''Yes'') "Position Security"
,      decode(view_all_payrolls_flag, ''Y'' , ''No'', ''Yes'') "Payroll Security"
,      decode(restrict_by_supervisor_flag, ''N'' , ''No'', ''Y'', ''Person Based'', ''A'', ''Assignment Based'',null, ''None'', ''Unknown'') "Supervisor Security"
,      custom_restriction_flag "Custom Security"
FROM  per_security_profiles_v
ORDER BY NVL(business_group_name, ''Global''), security_profile_name',
      p_title                  => 'Security Profiles (PER_SECURITY_PROFILES)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No security profile defined',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '1'
      );
   l_info.delete;
debug('end add_signature: SECURITY2');



debug('begin add_signature: SECURITY3');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '11107',
      p_sig_id                 => 'SECURITY3',
      p_sig_sql                => 'SELECT security_profile_name "Security Profile Name"
,      security_profile_id "Security Profile Id"
,      NVL(business_group_name, ''Global'') "Business Group Name"
,      view_all_flag "View All Records"
,      decode(instr(view_all_organizations_flag||view_all_positions_flag||custom_restriction_flag, ''U''), 0, ''No'', ''Yes'') "User Based"
,      decode(view_all_employees_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Employees"
,      decode(view_all_cwk_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Contingent Workers"
,      decode(view_all_applicants_flag, ''Y'' , ''All'', ''N'', ''Restricted'', ''X'',  ''None'', ''Unknown'') "View Applicants"
,      decode(view_all_contacts_flag, ''Y'' , ''All'', ''N'', ''Restricted'',''Unknown'') "View Contacts"
,      decode(view_all_candidates_flag, ''Y'' , ''All'', ''X'',  ''None'', ''Unknown'') "View Candidates"
,      decode(view_all_organizations_flag, ''Y'' , ''No'', ''Yes'') "Organization Security"
,      decode(view_all_positions_flag, ''Y'' , ''No'', ''Yes'') "Position Security"
,      decode(view_all_payrolls_flag, ''Y'' , ''No'', ''Yes'') "Payroll Security"
,      decode(restrict_by_supervisor_flag, ''N'' , ''No'', ''Y'', ''Person Based'', ''A'', ''Assignment Based'',null, ''None'', ''Unknown'') "Supervisor Security"
,      custom_restriction_flag "Custom Security"
, decode(profile_type, ''4'', ''MOBILE'', ''N'') "Mobile Extension"
, decode(profile_type, ''1'', ''ENDECA or ECC'', ''N'') "ECC Extension"
FROM  per_security_profiles_v
ORDER BY NVL(business_group_name, ''Global''), security_profile_name',
      p_title                  => 'Security Profiles (PER_SECURITY_PROFILES)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No security profile defined',
      p_solution               => '',
      p_success_msg            => 'Useful documentation [394083.1] Understanding and Using HRMS Security in Oracle HRMS<br>
[1266051.1] Troubleshooting eBusiness Suite HRMS Security Issues<br>
[1385633.1] Security, MultiOrg, and Multi Org Access Control(MOAC) support in relation to Oracle Human Resources applications',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: SECURITY3');



debug('begin add_signature: SECURITY LIST MAINTENANCE2');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8421',
      p_sig_id                 => 'SECURITY LIST MAINTENANCE2',
      p_sig_sql                => 'SELECT * FROM (SELECT ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
	FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
	WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
	AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
	AND PT.LANGUAGE = ''US'' and
	STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
	AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
	AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''SECURITY LIST MAINTENANCE%''
	and PHAS.MEANING=''Completed'' and STAT.MEANING=''Normal''
	ORDER BY 1 desc) WHERE ROWNUM = 1',
      p_title                  => 'Security List Maintenance Process',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No records available in concurrent requests table related to Security List Maintenance process.


',
      p_solution               => 'Purge Concurrent Request and/or Manager Data process was performed, so information was purged from concurrent requests table.<br>
We cannot determine if Security List Maintenance process was performed.<br>
Please ensure that Security List Maintenance process was performed in this instance.<br>
Details in [1962912.1] Where Can Information Regarding The Parameters For Running Security List Maintenance Process Be Found?
',
      p_success_msg            => 'This section is a data collector for last successful run of Security List Maintenance process.<br>
Details in [1962912.1] Where Can Information Regarding The Parameters For Running Security List Maintenance Process Be Found?',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '3'
      );
   l_info.delete;
debug('end add_signature: SECURITY LIST MAINTENANCE2');



debug('begin add_signature: SECURITY LIST MAINTENANCE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5541',
      p_sig_id                 => 'SECURITY LIST MAINTENANCE',
      p_sig_sql                => 'SELECT * FROM (SELECT ACTUAL_COMPLETION_DATE "Completion Date", ARGUMENT_TEXT
	FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R, FND_LOOKUP_VALUES STAT, FND_LOOKUP_VALUES PHAS
	WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
	AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID
	AND PT.LANGUAGE = ''US'' and
	STAT.LOOKUP_CODE = R.STATUS_CODE AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE'' AND PHAS.LOOKUP_CODE = R.PHASE_CODE
	AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE'' and PHAS.language=''US'' and STAT.language=''US'' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
	AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE ''SECURITY LIST MAINTENANCE%''
	and PHAS.MEANING=''Completed'' and STAT.MEANING=''Normal''
	ORDER BY 1 desc) WHERE ROWNUM = 1',
      p_title                  => 'Security List Maintenance Process',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Security List Maintenance process was never performed in this instance.

',
      p_solution               => 'Details in [1962912.1] Where Can Information Regarding The Parameters For Running Security List Maintenance Process Be Found?',
      p_success_msg            => 'This section is a data collector for last successful run of Security List Maintenance process.<br>
Details in [1962912.1] Where Can Information Regarding The Parameters For Running Security List Maintenance Process Be Found?',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N'),
      p_version                => '4'
      );
   l_info.delete;
debug('end add_signature: SECURITY LIST MAINTENANCE');



EXCEPTION WHEN OTHERS THEN
  print_log('Error in load_signatures');
  raise;
END load_signatures;


---------------------------------
-- MAIN ENTRY POINT
---------------------------------
PROCEDURE main(
            p_AMEAPPID                     IN NUMBER      DEFAULT -1
           ,p_trxn_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 2000
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y')

 IS

  l_sql_result VARCHAR2(1);
  l_step       VARCHAR2(5);
  --l_analyzer_end_time   TIMESTAMP;

BEGIN

  l_step := '1';
  initialize_globals;

  -- Workaround for handling debugging before file init
  g_debug_mode := nvl(p_debug_mode, 'Y');
  g_params_string := '';

  IF (p_AMEAPPID IS NOT NULL) THEN
    g_params_string := g_params_string || to_char(p_AMEAPPID) || '_';
  END IF;


  l_step := '10';
  initialize_files;

  analyzer_title := 'Approvals Management Analyzer';
  analyzer_title := regexp_replace('EBS ' || analyzer_title, '(\S+\s)\1', '\1', 1, 0, 'i');  -- EBSAF-243

  l_step := '15';
   validate_parameters(
     p_AMEAPPID                     => p_AMEAPPID
    ,p_trxn_id                      => p_trxn_id
    ,p_max_output_rows              => p_max_output_rows
    ,p_debug_mode                   => p_debug_mode
  );


  l_step := '20';
  set_cloud_flag;

  l_step := '23';
  set_snap_days;

  l_step := '25';
  print_page_header;

  l_step := '30';
  print_rep_header(analyzer_title);
  --print_execdetails;
  print_feedback;
  print_parameters;
  print_whatsnew;

  l_step := '40';
  load_signatures;

  l_step := '45';
  create_hyperlink_table;

  l_step := '50';

  -- Start of Sections and signatures
  l_step := '60';
  debug('begin section: Main Section');
  -- Print the menu of the section screen
  start_main_section;

debug('begin section: Overview');
start_section('Instance Summary', 'Overview');
   set_item_result(run_stored_sig('OVERVIEWHCM'));
   set_item_result(run_stored_sig('HCM_DB_CHECK'));
   set_item_result(run_stored_sig('PRODUCTS_ALL'));
   set_item_result(run_stored_sig('Legislations'));
   set_item_result(run_stored_sig('LANGUAGES_INSTALLED_DETAILS'));
   set_item_result(run_stored_sig('Discrepancies'));
   set_item_result(run_stored_sig('INVALID_HCM'));
   IF g_sql_tokens('##$$purged1$$##') >0 THEN
      set_item_result(run_stored_sig('GATHER_GENERIC_2'));
   END IF;
   IF g_sql_tokens('##$$purged1$$##') = 0 THEN
      set_item_result(run_stored_sig('GATHER_GENERIC'));
   END IF;
   set_item_result(check_rec_patches_1); /* Signature AMEPATCH */
   set_item_result(check_rec_patches_2); /* Signature RUP */
   set_item_result(run_stored_sig('ONEOFF'));
   set_item_result(check_rec_patches_3); /* Signature ATGFORHCM */
   set_item_result(run_stored_sig('AME PACKAGES'));
   set_item_result(run_stored_sig('TABLESPACE_CHECK'));
end_section;
debug('end section: Overview');

debug('begin section: Setup2');
start_section('Setup', 'Setup');
   set_item_result(run_stored_sig('TRANSACTION_SUMMARY'));
   set_item_result(run_stored_sig('ITEM CLASSES'));
   set_item_result(run_stored_sig('MANDATORY ATTRIBUTES'));
   set_item_result(run_stored_sig('AME_CONDITIONS'));
   set_item_result(run_stored_sig('LIST MODIFICATION USED'));
   set_item_result(run_stored_sig('LIST MODIFICATION NOT USED'));
   set_item_result(run_stored_sig('RULES'));
   set_item_result(run_stored_sig('ACTION TYPES'));
   set_item_result(run_stored_sig('APPROVAL_GROUPS'));
 set_item_result(run_stored_sig('RULES_USING_APPROVER_GROUPS'));
   set_item_result(run_stored_sig('CONFIGURATION VARIABLES1'));
   set_item_result(run_stored_sig('INCORRECT_VALUE_CONFIGURATION_VARIABLE'));
   set_item_result(run_stored_sig('CONFIGURATION VARIABLES2'));
   set_item_result(run_stored_sig('INCORRECT_DEFAULT_CONFIG'));
   set_item_result(run_stored_sig('APPROVER TYPE DETAILS'));
   set_item_result(run_stored_sig('NON SERIAL VOTING REGIME'));
   set_item_result(run_stored_sig('NON UNIQUE ORDER NUMBERS'));
   set_item_result(run_stored_sig('NON SERIAL OR ORDER NUMBER VOTING REGIME'));
   set_item_result(run_stored_sig('NON UNIQUE ORDER NUMBERS FOR APPROVAL GROUP CONFIG'));
   set_item_result(run_stored_sig('NON UNIQUE ORDER NUMBERS FOR ITEMS'));
   set_item_result(run_stored_sig('NON SERIAL SUBLIST MODES FOR ITEM CLASS USAGES'));
   set_item_result(run_stored_sig('LOOP_SUPERVISOR_HIERARCHY'));
   set_item_result(get_ame_approvers_invalid());
   set_item_result(run_stored_sig('INVALID_SUPERVISOR_GENERIC'));
 set_item_result(run_stored_sig('APPROVER GROUPS WITH INVALID OR TERMINATED EMPLOYEES'));

end_section;
debug('end section: Setup2');

debug('begin section: Profiles');
start_section('Profiles', 'Profiles');
   set_item_result(run_stored_sig('AME_APPROVERS_REGION_APPEND_TO_LIST'));
   set_item_result(run_stored_sig('AME_INSTALLATION_LEVEL2'));
   set_item_result(run_stored_sig('AME_INSTALLED_FLAG2'));
   set_item_result(run_stored_sig('PER_EX_SECURITY_PROFILE2'));
   set_item_result(run_stored_sig('HR_DM_BG_LOCKOUT2'));
   set_item_result(run_stored_sig('HR_DEFER_UPDATE FOR AME'));
   IF g_sql_tokens('##$$profile_defer$$##') >0 THEN
      set_item_result(run_stored_sig('AME_WORKFLOW'));
   END IF;
   set_item_result(run_stored_sig('PER_RTM_SECURITY_PROFILE2'));
   set_item_result(run_stored_sig('HR_VIEW_TERM_PEOPLE_INSRCH2'));
   set_item_result(run_stored_sig('PER_SECURITY_PROFILE_ID2'));
   set_item_result(run_stored_sig('ENABLE_SECURITY_GROUPS'));
   set_item_result(run_stored_sig('ENABLE_SECURITY_GROUPS2'));
   set_item_result(run_stored_sig('ProfileENABLE_SECURITY_GROUPS'));
   set_item_result(run_stored_sig('ORG_ID2'));
end_section;
debug('end section: Profiles');

debug('begin section: Transaction');
if (g_sql_tokens('##$$TRID$$##') IS NOT NULL) then
      start_section('Transaction Specific');

           set_item_result(get_ame_rules_for_trxn(g_sql_tokens('##$$TRID$$##')));
           set_item_result(get_ame_approvers_for_trxn(g_sql_tokens('##$$TRID$$##')));
           set_item_result(get_ame_approvers_for_trxn_2(g_sql_tokens('##$$TRID$$##')));
           set_item_result(run_stored_sig('AME_EXCEPTIONS_LOG'));
           set_item_result(run_stored_sig('AME_EXCE_STR_BUFFER_TOO_SMALL'));


      end_section;
end if;
debug('end section: Transaction');

debug('begin section: WORKFLOW');
start_section('Workflow', 'WORKFLOW');
   set_item_result(run_stored_sig('WORKFLOW'));
   IF g_sql_tokens('##$$purged6$$##') >0 THEN
      set_item_result(run_stored_sig('COMPLETE_DEFUNCT_HR2'));
   END IF;
   IF g_sql_tokens('##$$purged6$$##') = 0 THEN
      set_item_result(run_stored_sig('Complete_defunct_HR'));
   END IF;
end_section;
debug('end section: WORKFLOW');

debug('begin section: Organizations');
start_section('Organizations', 'Organizations');
   set_item_result(run_stored_sig('BUSINESS_GROUPS'));
   set_item_result(run_stored_sig('Currency_not_USD'));
   set_item_result(run_stored_sig('Legislation_not_US'));
   set_item_result(run_stored_sig('Setup_Name'));
   set_item_result(run_stored_sig('CLASSIFICATION'));
end_section;
debug('end section: Organizations');

debug('begin section: Security');
start_section('Security', 'Security');
   IF g_sql_tokens('##$$security_check$$##') >0
and g_sql_tokens('##$$security_check3$$##') = 0 THEN
      set_item_result(run_stored_sig('SECURITY1'));
   END IF;
   IF g_sql_tokens('##$$security_check$$##') = 0 and
g_sql_tokens('##$$security_check3$$##') = 0 THEN
      set_item_result(run_stored_sig('SECURITY2'));
   END IF;
   IF g_sql_tokens('##$$security_check$$##') > 0 and
g_sql_tokens('##$$security_check3$$##') > 0 THEN
      set_item_result(run_stored_sig('SECURITY3'));
   END IF;
   IF g_sql_tokens('##$$purged6$$##') > 0 THEN
      set_item_result(run_stored_sig('SECURITY LIST MAINTENANCE2'));
   END IF;
   IF g_sql_tokens('##$$purged6$$##') = 0 THEN
      set_item_result(run_stored_sig('SECURITY LIST MAINTENANCE'));
   END IF;
   set_item_result(run_stored_sig('HR_VIEW_TERM_PEOPLE_INSRCH'));
   set_item_result(run_stored_sig('ENABLE_SECURITY_GROUPS'));
   set_item_result(run_stored_sig('ProfileENABLE_SECURITY_GROUPS'));
   set_item_result(run_stored_sig('ENABLE_SECURITY_GROUPS2'));
   set_item_result(run_stored_sig('ORG_ID'));
   set_item_result(run_stored_sig('PER_EX_SECURITY_PROFILE'));
   set_item_result(run_stored_sig('PER_SECURITY_PROFILE_ID'));
   set_item_result(run_stored_sig('DATA MIGRATOR BUSINESS GROUP LOCKOUT PROFILE'));
   set_item_result(run_stored_sig('ENABLE RTM SECURITY PROFILE VALUES'));
end_section;
debug('end section: Security');

debug('begin section: MOBILE');
start_section('Mobile Apps', 'MOBILE');
   IF g_rep_info('Apps Version') like '12.1%' or g_rep_info('Apps Version') like '12.2%' THEN
      set_item_result(check_rec_patches_4); /* Signature MOBILE_PATCH */
   END IF;
   set_item_result(run_stored_sig('MOBILE_USERS'));
end_section;
debug('end section: MOBILE');

debug('begin section: LifetimeSupportPolicy');
start_section('Lifetime Support Policy', 'LifetimeSupportPolicy');
   set_item_result(run_stored_sig('PREMIER_SUPPORT_11.5'));
   set_item_result(run_stored_sig('PREMIER_SUPPORT_12.0'));
   set_item_result(run_stored_sig('PREMIER_SUPPORT_12.1'));
   set_item_result(run_stored_sig('PREMIER_SUPPORT_DB_CHECK_11'));
   set_item_result(run_stored_sig('PREMIER_SUPPORT_DB_CHECK_12.1'));
end_section;
debug('end section: LifetimeSupportPolicy');



  -- End of Sections and signatures
  end_main_section;
  debug('end section: Main Section');

  l_step := '140';
  --g_analyzer_elapsed := stop_timer(g_analyzer_start_time);
  --get_current_time(l_analyzer_end_time);
  --print_execution_time (l_analyzer_end_time);
  print_execdetails;

  print_mainpage;

  print_footer;

  print_hidden_xml;

  print_sig_exceptions;

  close_files;

EXCEPTION WHEN others THEN
  g_retcode := 2;
  g_errbuf := 'Error in main at step '||l_step||': '||sqlerrm;
  print_log(g_errbuf);

END main;


PROCEDURE main_cp(
            errbuf                         OUT VARCHAR2
           ,retcode                        OUT VARCHAR2
           ,p_AMEAPPID                     IN NUMBER      DEFAULT -1
           ,p_trxn_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 2000
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y'
)
 IS

BEGIN
  g_retcode := 0;
  g_errbuf := null;

   main(
     p_AMEAPPID                     => p_AMEAPPID
    ,p_trxn_id                      => p_trxn_id
    ,p_max_output_rows              => p_max_output_rows
    ,p_debug_mode                   => p_debug_mode
  );


  retcode := g_retcode;
  errbuf  := g_errbuf;
EXCEPTION WHEN OTHERS THEN
  retcode := '2';
  errbuf := 'Error in main_cp: '||sqlerrm||' : '||g_errbuf;
END main_cp;


END ame_analyzer_pkg;

/