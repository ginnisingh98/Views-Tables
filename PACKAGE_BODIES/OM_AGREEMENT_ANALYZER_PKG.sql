--------------------------------------------------------
--  DDL for Package Body OM_AGREEMENT_ANALYZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OM_AGREEMENT_ANALYZER_PKG" AS
-- $Id: om_agreement_analyzer.sql, 200.5 2018/08/02 20:13:07 CHRISTINE.SCHMEHL@ORACLE.COM Exp $

----------------------------------
-- Global Variables             --
----------------------------------
g_log_file         UTL_FILE.FILE_TYPE;
g_out_file         UTL_FILE.FILE_TYPE;
g_is_concurrent    BOOLEAN := (to_number(nvl(FND_GLOBAL.CONC_REQUEST_ID,0)) >  0);
g_debug_mode       VARCHAR2(1);
g_max_output_rows  NUMBER := 10;
g_family_result    VARCHAR2(1);
g_errbuf           VARCHAR2(1000);
g_retcode          VARCHAR2(1);
g_section_id       VARCHAR2(300);
g_snap_days        NUMBER := 0;
g_dx_printed      dx_pr_type;


g_query_start_time TIMESTAMP;
g_query_elapsed    INTERVAL DAY(2) TO SECOND(3);
g_analyzer_start_time TIMESTAMP;
g_analyzer_elapsed    INTERVAL DAY(2) TO SECOND(3);

g_signatures      SIGNATURE_TBL;
g_sections        REP_SECTION_TBL;
g_sql_tokens      HASH_TBL_8K;
g_rep_info        HASH_TBL_2K;
g_parameters      parameter_hash := parameter_hash();
g_exec_summary      HASH_TBL_2K;
g_item_id         INTEGER := 0;
g_sig_id        INTEGER := 0;
g_parent_sig_id   VARCHAR2(320);
analyzer_title VARCHAR2(255);
g_mos_patch_url   VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?patchId=';
g_mos_doc_url     VARCHAR2(500) :=
  'https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER&sourceId=2295096.1';
g_hidden_xml      XMLDOM.DOMDocument;
g_dx_summary_error VARCHAR2(4000);
g_preserve_trailing_blanks BOOLEAN := false;
g_sec_detail   section_record_tbl := section_record_tbl();
g_level            NUMBER := 1;
g_result           resulttype;
g_cloud_flag       BOOLEAN := FALSE;
g_sig_count        NUMBER := 0;
g_hypercount       NUMBER := 1;
g_dest_to_source  destToSourceType;
g_source_to_dest  sourceToDestType;
g_results         results_hash;
g_fam_area_hash   family_area_tbl;
g_params_string   VARCHAR2(500) := '';

g_family_area      VARCHAR2(24) := 'MFG';



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
  IF (g_debug_mode = 'Y') THEN
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


PROCEDURE print_out(p_msg IN VARCHAR2
                   ,p_newline IN VARCHAR  DEFAULT 'Y' ) is
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


PROCEDURE print_error
         (p_msg             VARCHAR2,
          p_sig_id          VARCHAR2 DEFAULT '',
          p_section_id      VARCHAR2 DEFAULT '')
IS
BEGIN
  print_out('<div class="data sigcontainer signature E section print analysis" level="1"  id="'||p_sig_id||'" style="display: none;">'||p_msg);
  print_out('</div>');

  -- ER #124 Show in unix session the error if parameter or additional validation failed.
  IF NOT g_is_concurrent THEN
    IF p_msg LIKE 'INVALID ARGUMENT:%' THEN
        -- from Parameters validations if exist
        dbms_output.put_line('**************************************************');
        dbms_output.put_line('**** ERROR  ERROR  ERROR  ERROR  ERROR  ERROR ****');
        dbms_output.put_line('**************************************************');
        dbms_output.put_line('**** The analyzer did not run to completion!');
        dbms_output.put_line('**** '||p_msg);
        dbms_output.put_line('**** Please rerun the analyzer with proper parameter value.');
    ELSIF p_msg LIKE 'PROGRAM ERROR%' THEN
        -- from calls in run_sig_sql and run_stored_sig which are seen in output only
        null;
    ELSE
        -- from Additional Validation if exist
        dbms_output.put_line('**************************************************');
        dbms_output.put_line('**** ERROR  ERROR  ERROR  ERROR  ERROR  ERROR ****');
        dbms_output.put_line('**************************************************');
        dbms_output.put_line('**** The analyzer did not run to completion!');
        dbms_output.put_line('**** '||p_msg);
    END IF;
   END IF;
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

FUNCTION format_elapsed (p_elapsed IN INTERVAL DAY TO SECOND) RETURN VARCHAR2 IS
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
  IF length(l_fmt_elapsed) > 0 THEN
    l_fmt_elapsed := l_fmt_elapsed||', ';
  END IF;
  l_fmt_elapsed := l_fmt_elapsed || l_seconds||' Sec';
  RETURN(l_fmt_elapsed);
END format_elapsed;


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
            dbms_output.put_line('Exception: '||sqlerrm||' in set_cloud_flag');
    END;

    BEGIN
       -- set transfertimeout to 15 seconds, we don’t want the analyzer waiting more than that
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

  -- re-initialize values
  g_sig_id := 0;
  g_item_id := 0;
  g_sig_count := 0 ;
  g_sec_detail.delete;
  -- initialize the global results hash
  g_results('S') := 0;
  g_results('W') := 0;
  g_results('E') := 0;
  g_results('I') := 0;
  g_results('P') := 0;    -- for checks that passed, but will not be printed in the report
  g_parameters.DELETE;

  -- initialize global hash for converting the family area codes that come from the builder to the anchor format used in Note 1545562.1
  g_fam_area_hash('ATG') := 'EBS';
  g_fam_area_hash('EBS CRM') := 'CRM';
  g_fam_area_hash('Financials') := 'Fin';
  g_fam_area_hash('HCM') := 'HCM';
  g_fam_area_hash('MFG') := 'Man';
  g_fam_area_hash('EBS Defect') := '';

  IF g_is_concurrent THEN
     g_rep_info('Calling From'):='Concurrent Program';
  ELSE
     g_rep_info('Calling From'):='SQL Script';
  END IF;

END initialize_globals;

----------------------------------------------------------------
--- File Management                                          ---
----------------------------------------------------------------

PROCEDURE initialize_files is
  l_date_char        VARCHAR2(20);
  l_log_file         VARCHAR2(400);
  l_out_file         VARCHAR2(400);
  l_file_location    V$PARAMETER.VALUE%TYPE;
  l_instance         VARCHAR2(100);
  l_host             VARCHAR2(200);
  NO_UTL_DIR         EXCEPTION;
  l_step             VARCHAR2(2);
BEGIN
  get_current_time(g_analyzer_start_time);
  l_step := '1';

  IF NOT g_is_concurrent THEN
  l_step := '2';

    SELECT to_char(sysdate,'YYYY-MM-DD_hh_mi') INTO l_date_char from dual;

    SELECT instance_name, host_name
    INTO l_instance, l_host
    FROM v$instance;
    l_step := '3';

    l_log_file := 'ONTBLSO_Analyzer_'||l_instance||'_'||g_params_string||l_date_char||'.log';
    l_out_file := 'ONTBLSO_Analyzer_'||l_instance||'_'||g_params_string||l_date_char||'.html';
    l_step := '4';

    SELECT decode(instr(value,','),0,value,
           SUBSTR (value,1,instr(value,',') - 1))
    INTO   l_file_location
    FROM   v$parameter
    WHERE  name = 'utl_file_dir';
    l_step := '5';

    -- Set maximum line size to 10000 for encoding of base64 icon
    IF l_file_location IS NULL THEN
      RAISE NO_UTL_DIR;
    ELSE
      g_out_file := utl_file.fopen(l_file_location, l_out_file, 'w',32000);
      IF g_debug_mode = 'Y' THEN
         g_log_file := utl_file.fopen(l_file_location, l_log_file, 'w',10000);
      END IF;
    END IF;
    l_step := '6';

    dbms_output.put_line('Files are located on Host : '||l_host);
    dbms_output.put_line('Output file : '||l_file_location||'/'||l_out_file);
    l_step := '7';
    IF g_debug_mode = 'Y' THEN
       dbms_output.put_line('Log file : '||l_file_location||'/'||l_log_file);
    END IF;
  END IF;
EXCEPTION
  WHEN NO_UTL_DIR THEN
    dbms_output.put_line('Exception: Unable to identify a valid output '||
      'directory for UTL_FILE in initialize_files at step ' || l_step);
    raise;
  WHEN OTHERS THEN
    dbms_output.put_line('Exception: '||sqlerrm||' in initialize_files at step ' || l_step);
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
-- replace existing _ with double _ and spaces with _ (to avoid multi-word section and signature names)
-- replace also existing - with double - and . with _ (as Firefox does not accept . in the css class name)
    l_name := REPLACE(p_name, '%', '_PERCENT_');
    l_name := REPLACE(l_name, ':', '_COLON_');
    l_name := REPLACE(l_name, '/', '_SLASH_');
    l_name := REPLACE(l_name, '&', '_AMP_');
    l_name := REPLACE(l_name, '<', '_LT_');
    l_name := REPLACE(l_name, '>', '_GT_');
    l_name := REPLACE(l_name, '(', '__');
    l_name := REPLACE(l_name, ')', '__');
    l_name := REPLACE(l_name, '_', '__');
    l_name := REPLACE(l_name, '-', '--');
    l_name := REPLACE(l_name, '.', '-');
    l_name := REPLACE(l_name, ',', '----');
    RETURN REPLACE(l_name, ' ', '_');

EXCEPTION WHEN OTHERS THEN
    print_log('Error in print_page_header: '||sqlerrm);
    return p_name;
END replace_chars;

----------------------------------------------------------------
--- Escape HTML characters (< , > )                          ---
----------------------------------------------------------------
FUNCTION escape_html_chars(p_text VARCHAR2) RETURN VARCHAR2 IS
    l_out_text   VARCHAR2(32767);
BEGIN
    l_out_text := REPLACE(REPLACE(p_text, '>', '&gt;'), '<', '&lt;');
    RETURN l_out_text;

EXCEPTION
  WHEN OTHERS THEN
    print_log('Exception: '||sqlerrm||' in escape_html_chars');
END escape_html_chars;

----------------------------------------------------------------
-- Prints the Cloud image in the page header and              --
-- also in the Execution Details pop-up page,                 --
-- if the domain like “%oraclecloud.internal%”                --
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
-- Notes:                                                     --
-- Looknfeel styles for the o/p must be changed here          --
----------------------------------------------------------------

PROCEDURE print_page_header is
BEGIN
  -- HTML header
  print_out('
<HTML><HEAD>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />');

  -- Page Title
  print_out('<TITLE>ONTBLSO Analyzer Report</TITLE>');

  -- Styles
  print_out('
<STYLE type="text/css">

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
    margin: 0;
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
  border: 0;
  display:none;
}

.exportcheck {
    margin-bottom: 0;
    padding-bottom: 0;
}

.export2Txt {
    padding-left: 2px;
}

.pageheader {
    position: fixed;
    top: 0;
    width: 100%;
    height: 75px;
    background-color: #F5F5F5;
    color: #505050;
    margin: 0px;
    border: 0;
    padding: 0;
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

td.hlt {
  padding: inherit;
  font-family: inherit;
  font-size: inherit;
  font-weight: bold;
  color: #333333;
  background-color: #FFE864;
  text-indent: 0px;
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
    padding: 0;
    font-size: 14px;
}

.footerarea {
    height: 35px;
    bottom: 0;
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
    margin: 0;
    padding: 0;
    background-color: #F5F5F5;
    overflow-y: auto;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAAIElEQVQIW2P49evX27dvf4EBhMGAzIEwGNCUQFWRpREAFU9npcsNrzoAAAAASUVORK5CYII=");
}

.header, .footer { padding: 0 1em;}

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

tr.tdata td{
    border: 1px solid #f2f4f7;
}

.topmenu {
    position: absolute;
    right: 50px;
    float: right;
    bottom: 10;
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
    width: 250px;
    height: 390px;
    float: left;
    padding: 10px;
    border-radius:2px;
    border: 1px solid #E7E7E9;
}

.menuboxitem {
    white-space: nowrap;
    font-size: 18px;
    cursor: pointer;
    padding: 10px 0 10px 0;
}

.menuboxitem:hover {
    background-color: #EEEEEE;
}

.menuboxitemt {
    white-space: nowrap;
    font-size: 18px;
    padding: 10px 0 10px 0;
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
   padding: 0;
}

.rightcell {
   vertical-align:top;
   padding: 0;
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
    padding:0;
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
');

print_out('
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
    padding: 0 12px 10px 10px;
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
    border-radius: 5px 0 0 5px;
    margin: 0 0 2px 7px;
    left:0px;
    width:200px;
    z-index: 3;
}

.sectionbutton {
    cursor: pointer;
    background-color: #e7ecf0;
    border-left: 1px solid #D6DFE6;
    border-bottom: 1px solid #D6DFE6;
    border-right: 2px solid white;
    font-weight: normal;
    font-size: 14px;
    border-top: 0;
    border-right: 0;
    border-radius: 5px 0 0 5px;
    padding: 5px;
    display: none;
    margin-right: 0;
    word-wrap: break-word;
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

.expcoll {
   display:block;
   padding-left:0;
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
    padding: 6px;
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

.divitemtitle{
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

.divitemtitlet{
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

.tabledata tr[visible=''false''],
.no-result{
  display:none;
}

.exportAll {
  display:inline;
}

.exportAllImg {
  display:inline;
}

.tabledata tr[visible=''true'']{
  display:table-row;
}

.counter{
  padding:8px;
  color:#ccc;
}

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
');

print_out('
.brokenlink {
    display: inline-block;
    height: 15px;
    width: 10px;
    background-image: url("data:image/false;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAPCAYAAADd/14OAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAABLSURBVChTY/wPBAxEACYoTRCgKrw3h+GTrCrDO+85DH+hQjBApol4AHaFGkoMzFAmDNDaaiUlnDqJNpHMmNlTzvCO0gCndqJgYAAAyhkXWDyo/t0AAAAASUVORK5CYII=");
}
');

print_out('
.siginfo_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAXNJREFUeNqUU80uA1EYPXNHSliMaJPZ6EITi5LY8ARiUSuPYFOKjXTjISxYo30ADyCxaDyENGLVkJakSYsR/RlFnXvvVCYzpvRLzvzdc858Ofe7BraLCNQCkSXWiTnvW4W4JArEjZ885nuOEUfELuJJgSmLq+N6peem0XbSaFb3+XZG5ImO30CKL2DZa0gkEarYhMa0LWiSw0t93uvwXXiU40hxsOLkWPaq1y2kwSKRQ2I2xO0fLCmESnN3pFaowBJJEzDw/yJXaZCVGWQwaf1OO7yO9lCaakYapH7SDrQ/1EhrUiKyyWF/V3/oY7ALFXy4GLm05l6oCWs7oxt0XuW1JA2KaFQ/2VNkBuGtJFdpUJAhlokTNGp7/kEamkGjBqWhdhBiHk69RNe/W2+S49SvvPMAE8sb8i7bOYfbmsHz4wpM04DJ5oSp0+51gbcn4OH2C93WKbmbhKtHKnyc5WhvqQGTM8KtIu5kYN5xLvvJ3wIMAEduatirqrxIAAAAAElFTkSuQmCC");
}
');

print_out('
.whatsnew_ico {
    display: inline-block;
    height: 23px;
    width: 23px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QYTDTErvhkC9wAAAjhJREFUSMfFls9rE0EUxz+psT9StsRmWawePCjWoMHqZfwbbE+i1MbWRcGqf5HtRYyVJgerF/8FsbmIcQSxhx4EjQybGjKYpEklHhxhm+4m2Sr4YA/LfOf75s173/cm1ul0GNSKucwnAOHK6UH3xIlmZyPiGeIfWzGXiQVGYBY+A2+AReHKVkTiYWDDRDl9IALhyg6w6djWDSBvNnTbtvmCyF86KWsOeN0rB7eUp484tnVNeXoNmPcvCleeDgmg4KSsq6qi14F7oQ6EK1vFXOam8vRT4LzvdA+ABeCCgX4A8sCKucpzqqIfA8vClT/9nLFeZVrMZU4CrxzbmplMJhgb/X1rjWaLnWod5el3wJxw5ZcwjlAH5uTFE8eTM1PORCCmrGp8/VYtAUK4cjdqmd53bCuUHGDKmcCxrYvA8mF0kJ1MJvqWp8FkQ5Vs5O9X6JZpBZcTY8N9HRjMJV8r2cc1FFCqkdqHSWE7ZG883qO239YbrSvjiZGeDhrN1p+yDdRJrxzkd6r1vhEYTP4wSV5Vni6VVS0UUFY1lKffA6uRddAttNSxcUZHjgLQ3G1T+f4D5ekSMBtJaEZgBSAtXJk2/w+BRSBtYB+BZ8Aj0162gE3grnDlXqgDQ/bCSVmzqqLXhCtvD9iqC45tzStPPweywpXtsJLcMOR54E6EkbmkPB13bOu68vSeaYz7k2wGzilV0U+Ape6u6BuZB8amOfGC8vQ6cGbgJAdE0DGEsf82k//2VbEd1cEvrVrxKdMN1qwAAAAASUVORK5CYII=");
}
');

print_out('
.export_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2QUVENDk5NjdGMjM2ODExODIyQURBRDlDNkZERTUzMyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpBOTRBQzQzMTQ3NjkxMUU0OTZEMEZDMjFEMDE4Q0VDRiIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpBOTRBQzQzMDQ3NjkxMUU0OTZEMEZDMjFEMDE4Q0VDRiIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NTM0ODVEQ0I0ODIwNjgxMTgyMkFCMTdDQzcxMzg3NzIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NkFFRDQ5OTY3RjIzNjgxMTgyMkFEQUQ5QzZGREU1MzMiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6s1KKrAAAAf0lEQVR42mI07fb79+PvT0YGMgAXM8c/FpBmCRVpcvQzvLjzlImJgUIw8AYw7tix47+trS1Zmg8fPjwIvMCCTzJgey6G2AbPyaS5oNk8H4UmygXINteenIhCEx0GMBthTkZ3OkEDYDbCXIMtPHB6AZdtNEuJ74G0AJn63wAEGACAQStffMHfsAAAAABJRU5ErkJggg==");
}
');

print_out('
.export_txt_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADaGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4zLWMwMTEgNjYuMTQ1NjYxLCAyMDEyLzAyLzA2LTE0OjU2OjI3ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjZBRUQ0OTk2N0YyMzY4MTE4MjJBREFEOUM2RkRFNTMzIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkE5NEFDNDMxNDc2OTExRTQ5NkQwRkMyMUQwMThDRUNGIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkE5NEFDNDMwNDc2OTExRTQ5NkQwRkMyMUQwMThDRUNGIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCBDUzYgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo1MzQ4NURDQjQ4MjA2ODExODIyQUIxN0NDNzEzODc3MiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo2QUVENDk5NjdGMjM2ODExODIyQURBRDlDNkZERTUzMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PqzUoqsAAABKSURBVDhPY9yxY8d/BgoA2ICHikZQLmlA/v45BiYom2ww8AaAw8DW1hbKJQ0cPnx4OITBqAGDwQDGPXv2/P/z5w+USxpgY2NjAAAByhXLwOyrWgAAAABJRU5ErkJggg==");
}
');

print_out('
.export_html_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAATdJREFUeNpibN39fA8DA4MzA3lgLxMFmkHAmQVIMIJYVS4SZJkAMuA/iNG25wVZBjBhEQMZmAbE7khi9kCcB7OMkAHFQO/MBtIqSGJKQLHJQLqCkAEtQIX9QO+EA9mTkMTnAMUCgHJdQHY7LgOmAhXUAhV6ANmLgJgZSQ7EXgmUcwaqqQKyp8MkGIHpAOSvpUAcC8RWQLwLiLlwhNk3IHYC4lNAvBiIo2EuKIDSM/FoZoDKzUXWAzNgLtSZkUD8EY8Br6FqWIF4HrIBfkC8AIivQKPvGxbNX4HYF6pmHpSNEojRQNwPDKSTQDoUiH8hyYHYflC5KVC1WKMxHxjSlUCF24DsdCTxWKDYPqBcI5CdhawBFgvoIB+IrwLxHijfEogtQC7Elhc2ArE/mvhENP5xHIG6ASDAAPC+UvCkGM89AAAAAElFTkSuQmCC");
}
');

print_out('
.sort_ico {
    display: inline-block;
    height: 16px;
    width: 16px;
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAALhJREFUeNpi/P//PwMMtO15wQikVgMxiA6pcpFASELkwXygOCNMjIkBFdQBcTAQBwFxPQMRgAnJ9AA0TXVAsSCiDAAq1AFSi6BOhwEQeyFQTpcYFywEYl4s8jxAvBifASzQQDHGF1BEhQG5YNQAaCzgA8BYOQukjLAlaSC4SIwLEoD4MxbxL0AcS9AAYHq4DKTigRg5Y4HY8SA5osIAqHA9kGpEEmoCiq0jKgyQNQGxLjSPwA0DCDAAMMM1IrHFpIQAAAAASUVORK5CYII=");
}
');

print_out('
.information_ico {
    display: inline-block;
    height: 32px;
    width: 32px;
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAdhJREFUeNrEl70vA3EYx69NK5VSFjpLu0lKLF0s0kXKZmEn5i5qtHmJhD+AmYENsTSWiq2RSzppY2660FKSDvV95Fuheud3516+yWe5l+f53u/tniewvX+oKWoILIA5MA0mwAjvPYNHcA9uwCV4UQkaUngmCfJgBUQNnhknabAOXsEJ2AUVs+BBk3sRsAPKYNUkeT9F+U6ZJiJWDSTAHb98QLMveXeDsZKqBmbALefZKUmsImObGhCX1yCuOa84YyeNDAyCMzCmuSeJfc5cvwxsgSnNfaWY64cBWXQ5i4ECPVhRrjsVXQObIKx5pzBzfhoY5iHjtZYltxjIWjxknJLkzMpRnLEZoOOAiUyQq9IvpULcAVZXv1MjkpARiPk4ArGgzbnvOOVADDR8HIGGGKj6aKAqBnQfDehioOCjgYIYuGIN57VaklsMNMGpjb+g6nUjSdHa7G5DKT7bHn59m8Xq1+9YSucDi+eAESqSZuShX0XkxY7Q+1VEojewBOouJq8zR8uoKpapmAc1F5LXGLvyV19QArMOT4fOmCXVzqjCPm/vn7ujzRhpox7R7G/4ztZsEhx9nzcFyXo65rt5xrLdHct2WWMpvdjTno/ymaee9vxCtT3/EGAAeihgXfXnZOsAAAAASUVORK5CYII=");
}
');

print_out('
.warn_ico {
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA15JREFUeNqsV81qFEEQ7umZjbuLgqgg69/Bg+bgQb1kD3qQmFXEJxB8Ah9AxLN4SbyYTR5AyAsoimZzioLJQfAgmlwUwRVNIoG4ycrOTPt9szPLZDI/PZMtqMxmuru+r6q7aqqN3odbIkm63X+D35ZlHldKPFBKTUDP4FUVT8kxwzBcPLbx/A6dNwzx2LadX+XyAZElRhYBAI+7rmq6rnveNKWQUhJwoBQQGSjmCcdxOW9FSuOeZVkLhQjYtn0YBl/BWB1GSETkEUSANgRIL4HoTdjYjJsnE8CvAbiNhXWGMS+4v2WCa2FjjLZgc1yLACbewYKWaZoVer5foQ3ags03tJ1KgCwx8RnYSw2vO9AL0IvQv1nRoE3ajkZChsCPYMJzsJVQHeeaOKSfoB/xezprMm3SNjBeEGsPARy4lxivaO43PZ4M/T+ZFYUgEsAoE2sXAf/QjeXYc3q/FkrXDZ0oBGeCWMFWeASQ57M5wOnpVMx7RmFLlwQwZzwCYFJjkcmRatNh74tFwWTBOkdsieJ1nxUuh/eDvUeeL1JD41O6USAmsUFA3WB5zeH9Ruj/K76Go/BUxxAxPWz8ORXU9AzZipz8JHmiEwViEhuuq6omgaj3SR8wrSj0MVWVZ0BqEEg6+YWj0I+A0N58Le+LZAS8Fy6/40P0XisjiElsRMDYziDAqreeMPYW+i4lCs00AsQ2Ou8nPiMnRxM+QPT+bFzh0RHUiKN4fIUeio45jsOS/IUH8DXbqASZKQqeFQViEtvYWW7U0D61YxrIju/97xQPF32gqxlR+AY9GNNvnkDjYf1EVVplDxeR2TTwcEblzQhiEZPYXlPKTyNetiJROInFbTEEgd1jeKxFvG+AwLz0P48L7F7ZxYbkkhieXA51XvwQLRN8V1vut2Q/kA3lIl2wbquO098FgdMgsL6rJcOLPxi4jQkuU2TY0k87xyVGAL6nK/a34i6YujGHcl+e0yZtR29KMqZdmsPEBkMVORMFwe0g7Dx0c1o3Iz8SNZTLJZ7YItHgGq6lDdpKuiPKlMZxs38vNBuoWis01uv1vL1EQynC34/+pVR5Y5zDuVizyrWlUqmedC/0cDQ8YbqM+tfzhyB1XSmH1/NK5Hq+41/PW5j7iNfzkZHs6/l/AQYA4OEjjlxSJk0AAAAASUVORK5CYII=");
}
');

print_out('
.error_ico {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA8BJREFUeNq0V81rE0EUf7PpponWCnoRoSJa0VKoCtKDVuvFkxar9SJePNRDBS3mj1BEeip4MRdBq4cKgiKCIH6hIFoVRYVWCuIH4snSNEmT7Ph7u5O63c7sbmI68JL9mvf7vTfvvXkjvtEGMo0cyYXrFSRWlYkyDsl+h2gT3rRALH4niBxIHvIVD+4JEhfnSf5eyW8ihogiAOBtJZJXKkS7oc5KQCmjWh6wO6QSEKMyrvAvE0Rv8e1gE9FEGAEr5F2qmcS1AsmPUN6DaysFSBsvEj5w5QFXURNPwl2ahMCznfDCa8hd93GNBNoxcbpI8oQNZc3K6riDCSXxy/NA/iD0fIdXOmMRwIRuTHiPy3Vwv2tVvYM9xSRAaA0MmgCJnigCW/DhE0xIJb2JDRlJz4NJ6H4IEh0mAmkF3pxsGPQSEjYC+iljLSGAFMuW4HZ7MTiCn0YhhyAXIKUYWEXIechhyGWVIAskcLMWSq4vSkM83Ipo/8QBF1jzUaTi2eoN8pqJ3HJ16UcBcgRz7vvmMIkhv0WIMYls6YL1H1wPwC1ZXAhNwD0I1AVOqQHIfBxwnY6El64C9SLrLgGsb+UiY+vXfY+mODGJYwESJnAee4MPmoCFJe8G9moLF8Nc4Qx5fk65PUjijo+EERxzj+LvjC71LNcLlBFfqO2NRWKHbQ4qBhlQlgcB+ngFQ8BvmOKl5JZu+U5MUtsfRGdrIjyyjSR0Iwq8GoxI+xmOgRYrThoj+nXLUQ94dRlcbN5SRdxaEkEiLnh1v5Dm2DMO6dUs4yjVWiHZekfG+5YrXL8h1XTZEWkJYzOBnNMA8FpJOB6BHK/BtFMnONZ8IEadMBJgbBAQtyskw9LPCI6/MRWYfbWSYEzGtlCXR8DGMXjhUgR4Usl4CIkRnfUwWTI2x8AMLl6U9F54FQHuT1EtCdI0pYyFwvecsS21OZziTlaTXwdigEeR2O+/KXsekNj8Bkk1shwM3AvcxD593FrcgA5BIXvsMWQXJAOxI4oVkxhRljP4aX/qAYP7xDFY/zl4LkijikxJkuuXoyXzItpd5p/Q347/uWBPmIdpvfikME9yWcChNQ/w3iq4riue4g+qJBpBw/kHPgfX78PtZOi5AM5/iQ+7cPlrDtPK/wHOc/PQgQb/B3Ru12WVaTOahCc2crAgZWTRO+/FHqrx5HTj5vMqlnYze7fWs2GBj2ZQ0AmvPONOtuAq9QBkYGOpqK2QLYbLHWTTI8ztQL6fVG1bfafjGo7ns7iZAvC47bXzs3GO538FGABlYXzRnnOThQAAAABJRU5ErkJggg==");
}
');

print_out('
.success_ico {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA4ZJREFUeNqsl8tLFVEcx2fOqHgjKoIyQwyiUqJFi8AbBCWmlhpFG0PoH6igVkW0iSCiZYuK1j0gSFpkDx+ZRYusv0A3QfQgiLCNWXln+nzHuXKdOzN3HO+Bn+c6c8738z2POQ/7/FCDFZf+/vu3+NsxpsGzrIuW53WSN3uet4rHJnjt2rY9a1vWJ8u2R8mvFVz3e11trVUp1VQqALgD2E0EW4wxlgKYxR/LDsp4MuJ5qym30yUoe9bY9lShUDjtOM7LTAaovA7Yc8TyiFh1xsSK+EZkiPBLUV6G0RjD3CTvD6ExE1XXxMDbaclXKubVjU4CPKHnLNVFo01aaHakMkDBAdyP0fqcWr7SJA1poTki7UQDcknBuzWOY7K0Oqk3pCntcE+YEvh6uuoJjo2pInwRhKa0YQyJVWaAyfKMmZtzqgt/S7QTN4o9AaNerCUG/Ennum3VGPOS9IboZi2ZIM7x+0pxTohVHArfAN/v7SrDXxOHAc+WPLtMfCyagHnLN4CTRsalpYpdL3hPCK60jdhUHAqYO8Q2jMeFKk66iSg468EWsjEiVzopfTZ90W1su1rw3gh4E9k40bzkqxBTbFw02eUG5ol3xJ8VwjcH8K1lyzdMsY12tZCB2UBsL/l+4ldG+EYybUTbI/cPGYBtIpbjAcRGgu14kqwzwcSrGPiGAN5acX2KaVHpmeBDjAnB+yLgWuXUgF2pVkgdJkLP7iDiVDAxHgNfSzZM7E45d1yjkwxjUfqwn7iXYOIxcSQCvobsBbEnDVlMsQ3T73PIgNKJOBPE8Qi4jmdPiXzab9Y3AFvnq2G33ECsiXAqge9bzqLhM2GrB66zOcSVSzTB8/pgSA4sd9USU2zDxvCNiTBdSDZxP2yC/+vIBomu5cLFEtNnB4vCKTaGpDr9pSYC+EOt+1nWbLFgnlncjnV0ZnOYTGFiELha/Ig4lhUO6z3M0SXHcsajh4nxhcGpT9iajwaRKanrYczR/b1lRzIc/eRFHw7dhEmZOUlT2mLA+hF5KtZQ0PqT8xQsVNGEtKQp7fBNyUSc4x9QsAvHcxXmROoxl5Y0pZ3qZuRPSttu1LVKF9QsvaE6qisNacXdEU3CjWbG1b0Q557rTklsfqE1VsTS7T9zF7p6Aey606rLhSQfdy9MdTumJfpcWoPr+SUgB4PreS50Pf8dXM/HKHvVv57XVJS3/gswABvS7PkJ4jDUAAAAAElFTkSuQmCC");
}
');

print_out('
.proc_success_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAw9JREFUeNq0l19IFFEUxscpw8w0iMzIKNkSjNKKwChfyqhtk8KkMH2u3oJ9KemlnqJ6yYdeeg4yyP7QHylTI4gigoh9CCItggJFIrNWI6ntO/RN3a73zoy7swd+zO69M/c7c+bec88tyGQyjp+d7hv2fpaA3WArWAeqQBn7voB34CV4CO6Cb9JxYnuF7/iznWBbCY6Dg2Ce5Z5yUg+OgDToAmfBoN/gBbYI4M2LcDkFkmCOk539AJ3gJCLxPbQDEI/h0s1QR2HyafbDicFAByC+AZcesNiJ1kZAAk68sDoAcfneT8AiJz82CjarkXAV8bkMe77EHY59jVr/O8AJVxex4G3QDJ4pbbXU+ucAJ10yYnGJZjPCfRPXnZoTSX7uvxHoAIURit8A7eAnk5EkqsNKfyE1HReezGeSicokC7YyBzha6FVrFW2JQMInw83U7oF9ujiEJH1f1O4VzYQ40BiReJ9FfBMut0Cx4ZlG1xAaz4bA55Dij8BeMKm1r2dUSizP1YoDMUPHBVANasCrAPHH3CUntPbV4L6yY5osJg6Uao3XwVHM3F9ghJ/otWWApxRPG3bQ3hBJrdQ1NA5AWN0ghumEvpE8B7vAuNZeyfmwNMy3cw0DdGDirNDaPrIQecv/sqHsYCGiWgULkuUh5864y8mmv8EAnFimtX8A25heRXzMkOd7Gf6wNiQOpAwdVXSiUmt/D/aAT1p7GbfwtTNcuilxoN+nFJO+JQGDFDP7bcwid/S79DxtuaGaTpRb+ouYZLZkIS7LtsfFjP+KH1d8bqyhE/qSkjrxag6ZtEu0vWV4Bkz53LwGPAAL+X8WuASashSfYsX8ZztmiXQ+4KE6ru8WRuxADvtGJzTf6OcCqVLiPnuDwyq5O8dNKzWtImIUJvl2o3msCWXsFmhNmGpC71PEWUJHbTJmXD8bTNsLWLc3WBJULmFv0M8ERgeUSMg571zA6ggz22WMetOpyPdsqFQ0q3A5BtosVY3JZD5dlqXmzfZcTscywCGW7U3a8XwB7xnTjud3vON5kP0WYAATfdz0oKr6+wAAAABJRU5ErkJggg==");
}
');

print_out('
.error_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRJREFUeNqcVstLFXEU/uY392ZlZdd7vXZ7mKhBaWjLNgX6J7QoaudGCSKCgjYSFj02QkEQlhEEtuwvSG6LNhLSLh9JaGXm28TMzHn0nXHGZsaZrnbgMO/vO7/vnN85o42hAnH2HdaxBVg3f8I+vQw7bcBO2LyfgGYUQVvYDq13F7T2fdD74jC0KIJfsKsmYL6cgXkiBR0pKBRDQ5Ku8TmJQFIJAJMwUQo1WAr9DI8DBQn4UfMXGF27ofQcwYscyHiz6GOknIVl74feVg79rv+58l8w4o6PMJ4xGr2SQhQC9wAq+O4B6NonGHfGYXZGElDri59hXj3EqPkytmpZflNDEbmaVsp2PSCRaP4Bq8Np6MoFl1w+p3+jt9DTMbjT9KfOIoALgjfFnHAVVhUStXughhLyliSUF8oXeXcvVprl5CSKXvCQd4IM2gS9iT7gU+O8rIQVp2ZgCeZxxaTWSrXkgrJ89U5I9N4FmvoHOJxcu8ZkM+lm3TyxhaA9tbFaWhl5bQxJFHi9K6VjUs5S2ouw2pRsolSwmMRS9NckqYsgaeJ5GLyHXhIE0LEEu1ExwZni6HIUzfNhkhjwsvDH3OGSizLFXakn4+t9A8lmwD2ZBFtJPRbYTpbrYTPdco7uQe5DRSbzd/x7ktDGkCyeRVXXuq0SU7AVO+LMUjSBBz7o3aBU9SG5YkkEk9izisnIzzqrDdhcFLireT6CpJE+7wfgHsBOaG9UCdTtBbItB1fxOATe4Eto1t3ZfpJ+epd3Ia18jgR7oW4IQX8W6t1kcBUVIfBXoWqJIqn0TgSrHKqPBP1Os1thsxtisytjs8v9bXbdbh5awpsoMD6AJ/TD9LNSPGx00iaso0jWMMkj6wOHS7oyAuO+tOvsf7RrL/IxejUSlxn9Qzjj1TWOuwcW9IOjnAkiVm6LJDLVpqk723SHBx4gEMtAv8ZVDo/DeETZ1GZGppSjRM4iMY8geYlV2Vlw6LMKqqfWhn6Df+hvo9vuJlqkS3n/4JF/FW85i88x2tFN/VWEfltukfAUI8wQWNfW+oyxA9o0fwx6KMc9kg/EYfwRYABD0jtDqxO2xwAAAABJRU5ErkJggg==");
}
');

print_out('
.warning_small {
    background-image:  url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAxVJREFUeNqclktvElEUxy+XGZgGqBQsLdpSibFd2LhRE2NcunLha4MfQvsBjAsXvl9RUxJNdKELbeNr4dKVpjFGbWO0JpJaG7AttbWAlLEwPMb/wdIM41yoPck/XO6Z+zuXO/ecg1QcO8BENpPM7NGKpdMFrbRLK5a9pVLFbrMxXZbsRUniWadDGnXI0rnNQe8rEcNmFYDA6rI2lFPzPR3trczjUpiiyEyWONN1xhCUaVqZLal5NjefZR63Ene1OI4h0JumARIzqTOLafVkMLDBRnDsuKlRkOT8L93ndUV7unwnjD7J+GXq++LTVFo9si0cYK0exYoVgSrQI+NkZ6CVuV1OW2zyx/FKRe8Oh/yHaz5eG8SnU9cJvr0vKIJ/IPDox8RjfI6ZnQjA+vs2sVRGPUSsugB05nAM9G7tYIpTFp3ERcD1lfEFqwecTokRg1jEXA2AF/qQztyDXQjsq+lYnkATVg8Sg1hgDlcDINLepVx+C51jA7uM3Zd37gh9gmIY03u4JHqYWGCGiM1x5U51tjeEJ6F7K+NuqHdlfB+aFQYBk9gcSbQb97hRgGvYccE8iTmNfKJFxCQ2R8K0tSjCF5uBbjUIfhtKWzmISWxeKlfsSHsRIIqd5hoEIN+glYOYxOYNFi9DN0xz09A309xN6LcIIkl2XqYiJst2s+8udr9gOvd+C8ZP6A40YJwEkxGbOxz2zHK+aF5Ugq6YJ3FFX0AjFkGuQnUQYoKd5ii5b3FnzQuGsNu4VfUVnEQCemCcICbY7zjV87mFrHmBZRIh6H5onyBI3S8mJrE5avgI7myCSq7BKuz/TTOWb2ISu1qu0SwiqOevqeS6/9ajcZw1W4/l1EK1NwT8nshqsaNOhGYxiHrO8oUiW68hcxkxiFXrbqt5gE404GtzPfscS7LsUn5dOx//Mkvw58T6p+GQhbv9R9v97rOT8QXd9E6atsyJqXl9o88dRTc7uNamP0wll0ovNX2qLbWSQklE99zQ9BP0HtfU9IV/WzT8bUFtqaY/MpQSFPf8vSxL57uC3pcixh8BBgBX2nwB4HBekwAAAABJRU5ErkJggg==");
}
');

print_out('
.success_small {
    background-image:   url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNJREFUeNqclstrE1EUxu/cmWTyzjRWK0pbce/CF4qCRRHqRutjUVcuXEtXIoIVilZdCeJj48KVqAWpSOtCdOGL4vMfUPFRbYttSNM0zWTefmdM4jhO0jYXPs5k5s7vzL3nnnMinRptY/XGXE7dbpnOgGVYW2AV27ZFxgRHlASDc6EghsQPkiRcTGWiL+oxpHpgQ7PuaarZmVQiLJ4MMynEGRc5Y44jWJYdNk2nVVfN7vl8uVvXrO8hWTyazkRf+1ncfyOfVQcXCvqYHJU6165XWCoTYbhmosSZIOD7uQBnIovgHj2jOTR3YU4fy8+UrjVcwex0abhU1A+tWB1nkViILXXQKuWIJMxMFk84DmtvWRU7+N8K4P0KwdvaU8uCV0c4IjF6F4weYv3jgPa8VDT6Wtck3L1uYnyFTuLdcWIQi5g1Bwjo3WSLLGCZzcA/Q7ugy1AXGFPEAnPIdVDIqTtwWtbRPjYJ3w39rPz+Br0hFpgdxOY4bv1JRW4G/skHp3Ec6vkTeJkRmyOJtoajoWbge3zwY9BNSHCDDiaxOTK0JfQ3sDp0Grq6THgvdAsSqzeISWyJ0t/N0MpXTHzJu8FBAmVhzgVtC+ZMUIJVxhHothfuBhdMl+0DvKxeAHIe5mwQ3HNvP3SnXslxHWFYtmVXf4/gyzIeJ4MVJx8D4Pug+7TdQWBiEpujMuZNo+ZgE/QkwMlmLxzP98IM14O7uQUm2LMcJfetphreZ+Tkqc9J0QPvgnkIRRsdMx1MsN9xqufzec3/fKPfSQW+E2YUii12jolJbI5m8Qrldhx1vaET2G0wj6DE4vAylfBxYrunCM2id35Wc7SyGeTkGeBnYB9D6cXgxCAWMWvFjjpRLBG6np0sMk/Aq2MDNLgUOL1LDGJVu1stD5SVsb5YIvzg148CK5eMZRcmHV9O74IxQqzAlolOdDieki/kpktOQEwa7nl2asFB774BxoGGTV9pjfYLnI2i3A4VcvkOtx2i/9aafiWJaDswpxbQeDrcG9T0A1O8MrGTupJp2gNaTvX8bXHT36IExTl/n1DkS5j/vN7qfgswAFMPc0H/GzIVAAAAAElFTkSuQmCC");
}

</STYLE>');
  -- JS and end of header
print_out('<script type="text/javascript">
/*! jQuery v1.11.1 | (c) 2005, 2014 jQuery Foundation, Inc. | jquery.org/license */');
print_out('!function(a,b){"object"==typeof module&&"object"==typeof module.exports?module.exports=a.document?b(a,!0):function(a){if(!a.document)throw new Error("jQuery requires a window with a document");return b(a)}:b(a)}("undefined"!=typeof window?window:this,function(a,b){var c=[],d=c.slice,e=c.concat,f=c.push,g=c.indexOf,h={},i=h.toString,j=h.hasOwnProperty,k={},l="1.11.1",m=function(a,b){return new m.fn.init(a,b)},n=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,o=/^-ms-/,p=/-([\da-z])/gi,q=function(a,b){return b.toUpperCase()};m.fn=m.prototype={jquery:l,constructor:m,selector:"",length:0,toArray:function(){return d.call(this)},get:function(a){return null!=a?0>a?this[a+this.length]:this[a]:d.call(this)},pushStack:function(a){var b=m.merge(this.constructor(),a);return b.prevObject=this,b.context=this.context,b},each:function(a,b){return m.each(this,a,b)},map:function(a){return this.pushStack(m.map(this,function(b,c){return a.call(b,c,b)}))},slice:function(){return this.pushStack(d.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(a){var b=this.length,c=+a+(0>a?b:0);return this.pushStack(c>=0&&b>c?[this[c]]:[])},end:function(){return this.prevObject||this.constructor(null)},push:f,sort:c.sort,splice:c.splice},m.extend=m.fn.extend=function(){var a,b,c,d,e,f,g=arguments[0]||{},h=1,i=arguments.length,j=!1;for("boolean"==typeof g&&(j=g,g=arguments[h]||{},h++),"object"==typeof g||m.isFunction(g)||(g={}),h===i&&(g=this,h--);i>h;h++)if(null!=(e=arguments[h]))for(d in e)a=g[d],c=e[d],g!==c&&(j&&c&&(m.isPlainObject(c)||(b=m.isArray(c)))?(b?(b=!1,f=a&&m.isArray(a)?a:[]):f=a&&m.isPlainObject(a)?a:{},g[d]=m.extend(j,f,c)):void 0!==c&&(g[d]=c));return g},m.extend({expando:"jQuery"+(l+Math.random()).replace(/\D/g,""),isReady:!0,error:function(a){throw new Error(a)},noop:function(){},isFunction:function(a){return"function"===m.type(a)},isArray:Array.isArray||function(a){return"array"===m.type(a)},isWindow:function(a){return null!=a&&a==a.window},isNumeric:function(a){return!m.isArray(a)&&a-parseFloat(a)>=0},isEmptyObject:function(a){var b;for(b in a)return!1;return!0},isPlainObject:function(a){var b;if(!a||"object"!==m.type(a)||a.nodeType||m.isWindow(a))return!1;try{if(a.constructor&&!j.call(a,"constructor")&&!j.call(a.constructor.prototype,"isPrototypeOf"))return!1}catch(c){return!1}if(k.ownLast)for(b in a)return j.call(a,b);');
print_out('for(b in a);return void 0===b||j.call(a,b)},type:function(a){return null==a?a+"":"object"==typeof a||"function"==typeof a?h[i.call(a)]||"object":typeof a},globalEval:function(b){b&&m.trim(b)&&(a.execScript||function(b){a.eval.call(a,b)})(b)},camelCase:function(a){return a.replace(o,"ms-").replace(p,q)},nodeName:function(a,b){return a.nodeName&&a.nodeName.toLowerCase()===b.toLowerCase()},each:function(a,b,c){var d,e=0,f=a.length,g=r(a);if(c){if(g){for(;f>e;e++)if(d=b.apply(a[e],c),d===!1)break}else for(e in a)if(d=b.apply(a[e],c),d===!1)break}else if(g){for(;f>e;e++)if(d=b.call(a[e],e,a[e]),d===!1)break}else for(e in a)if(d=b.call(a[e],e,a[e]),d===!1)break;return a},trim:function(a){return null==a?"":(a+"").replace(n,"")},makeArray:function(a,b){var c=b||[];return null!=a&&(r(Object(a))?m.merge(c,"string"==typeof a?[a]:a):f.call(c,a)),c},inArray:function(a,b,c){var d;if(b){if(g)return g.call(b,a,c);for(d=b.length,c=c?0>c?Math.max(0,d+c):c:0;d>c;c++)if(c in b&&b[c]===a)return c}return-1},merge:function(a,b){var c=+b.length,d=0,e=a.length;while(c>d)a[e++]=b[d++];if(c!==c)while(void 0!==b[d])a[e++]=b[d++];return a.length=e,a},grep:function(a,b,c){for(var d,e=[],f=0,g=a.length,h=!c;g>f;f++)d=!b(a[f],f),d!==h&&e.push(a[f]);return e},map:function(a,b,c){var d,f=0,g=a.length,h=r(a),i=[];if(h)for(;g>f;f++)d=b(a[f],f,c),null!=d&&i.push(d);else for(f in a)d=b(a[f],f,c),null!=d&&i.push(d);return e.apply([],i)},guid:1,proxy:function(a,b){var c,e,f;return"string"==typeof b&&(f=a[b],b=a,a=f),m.isFunction(a)?(c=d.call(arguments,2),e=function(){return a.apply(b||this,c.concat(d.call(arguments)))},e.guid=a.guid=a.guid||m.guid++,e):void 0},now:function(){return+new Date},support:k}),m.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(a,b){h["[object "+b+"]"]=b.toLowerCase()});function r(a){var b=a.length,c=m.type(a);return"function"===c||m.isWindow(a)?!1:1===a.nodeType&&b?!0:"array"===c||0===b||"number"==typeof b&&b>0&&b-1 in a}var s=function(a){var b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u="sizzle"+-new Date,v=a.document,w=0,x=0,y=gb(),z=gb(),A=gb(),B=function(a,b){return a===b&&(l=!0),0},C="undefined",D=1<<31,E={}.hasOwnProperty,F=[],G=F.pop,H=F.push,I=F.push,J=F.slice,K=F.indexOf||function(a){for(var b=0,c=this.length;c>b;b++)');
print_out('if(this[b]===a)return b;return-1},L="checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",M="[\\x20\\t\\r\\n\\f]",N="(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",O=N.replace("w","w#"),P="\\["+M+"*("+N+")(?:"+M+"*([*^$|!~]?=)"+M+"*(?:''((?:\\\\.|[^\\\\''])*)''|\"((?:\\\\.|[^\\\\\"])*)\"|("+O+"))|)"+M+"*\\]",Q=":("+N+")(?:\\(((''((?:\\\\.|[^\\\\''])*)''|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|"+P+")*)|.*)\\)|)",R=new RegExp("^"+M+"+|((?:^|[^\\\\])(?:\\\\.)*)"+M+"+$","g"),S=new RegExp("^"+M+"*,"+M+"*"),T=new RegExp("^"+M+"*([>+~]|"+M+")"+M+"*"),U=new RegExp("="+M+"*([^\\]''\"]*?)"+M+"*\\]","g"),V=new RegExp(Q),W=new RegExp("^"+O+"$"),X={ID:new RegExp("^#("+N+")"),CLASS:new RegExp("^\\.("+N+")"),TAG:new RegExp("^("+N.replace("w","w*")+")"),ATTR:new RegExp("^"+P),PSEUDO:new RegExp("^"+Q),CHILD:new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\("+M+"*(even|odd|(([+-]|)(\\d*)n|)"+M+"*(?:([+-]|)"+M+"*(\\d+)|))"+M+"*\\)|)","i"),bool:new RegExp("^(?:"+L+")$","i"),needsContext:new RegExp("^"+M+"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\("+M+"*((?:-\\d)?\\d*)"+M+"*\\)|)(?=[^-]|$)","i")},Y=/^(?:input|select|textarea|button)$/i,Z=/^h\d$/i,$=/^[^{]+\{\s*\[native \w/,_=/^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,ab=/[+~]/,bb=/''|\\/g,cb=new RegExp("\\\\([\\da-f]{1,6}"+M+"?|("+M+")|.)","ig"),db=function(a,b,c){var d="0x"+b-65536;return d!==d||c?b:0>d?String.fromCharCode(d+65536):String.fromCharCode(d>>10|55296,1023&d|56320)};try{I.apply(F=J.call(v.childNodes),v.childNodes),F[v.childNodes.length].nodeType}catch(eb){I={apply:F.length?function(a,b){H.apply(a,J.call(b))}:function(a,b){var c=a.length,d=0;while(a[c++]=b[d++]);a.length=c-1}}}function fb(a,b,d,e){var f,h,j,k,l,o,r,s,w,x;if((b?b.ownerDocument||b:v)!==n&&m(b),b=b||n,d=d||[],!a||"string"!=typeof a)return d;if(1!==(k=b.nodeType)&&9!==k)return[];if(p&&!e){if(f=_.exec(a))if(j=f[1]){if(9===k){if(h=b.getElementById(j),!h||!h.parentNode)return d;if(h.id===j)return d.push(h),d}else if(b.ownerDocument&&(h=b.ownerDocument.getElementById(j))&&t(b,h)&&h.id===j)return d.push(h),d}else{if(f[2])return I.apply(d,b.getElementsByTagName(a)),d;');
print_out('if((j=f[3])&&c.getElementsByClassName&&b.getElementsByClassName)return I.apply(d,b.getElementsByClassName(j)),d}if(c.qsa&&(!q||!q.test(a))){if(s=r=u,w=b,x=9===k&&a,1===k&&"object"!==b.nodeName.toLowerCase()){o=g(a),(r=b.getAttribute("id"))?s=r.replace(bb,"\\$&"):b.setAttribute("id",s),s="[id=''"+s+"''] ",l=o.length;while(l--)o[l]=s+qb(o[l]);w=ab.test(a)&&ob(b.parentNode)||b,x=o.join(",")}if(x)try{return I.apply(d,w.querySelectorAll(x)),d}catch(y){}finally{r||b.removeAttribute("id")}}}return i(a.replace(R,"$1"),b,d,e)}function gb(){var a=[];function b(c,e){return a.push(c+" ")>d.cacheLength&&delete b[a.shift()],b[c+" "]=e}return b}function hb(a){return a[u]=!0,a}function ib(a){var b=n.createElement("div");try{return!!a(b)}catch(c){return!1}finally{b.parentNode&&b.parentNode.removeChild(b),b=null}}function jb(a,b){var c=a.split("|"),e=a.length;while(e--)d.attrHandle[c[e]]=b}function kb(a,b){var c=b&&a,d=c&&1===a.nodeType&&1===b.nodeType&&(~b.sourceIndex||D)-(~a.sourceIndex||D);if(d)return d;if(c)while(c=c.nextSibling)if(c===b)return-1;return a?1:-1}function lb(a){return function(b){var c=b.nodeName.toLowerCase();return"input"===c&&b.type===a}}function mb(a){return function(b){var c=b.nodeName.toLowerCase();return("input"===c||"button"===c)&&b.type===a}}function nb(a){return hb(function(b){return b=+b,hb(function(c,d){var e,f=a([],c.length,b),g=f.length;while(g--)c[e=f[g]]&&(c[e]=!(d[e]=c[e]))})})}function ob(a){return a&&typeof a.getElementsByTagName!==C&&a}c=fb.support={},f=fb.isXML=function(a){var b=a&&(a.ownerDocument||a).documentElement;return b?"HTML"!==b.nodeName:!1},m=fb.setDocument=function(a){var b,e=a?a.ownerDocument||a:v,g=e.defaultView;return e!==n&&9===e.nodeType&&e.documentElement?(n=e,o=e.documentElement,p=!f(e),g&&g!==g.top&&(g.addEventListener?g.addEventListener("unload",function(){m()},!1):g.attachEvent&&g.attachEvent("onunload",function(){m()})),c.attributes=ib(function(a){return a.className="i",!a.getAttribute("className")}),c.getElementsByTagName=ib(function(a){return a.appendChild(e.createComment("")),!a.getElementsByTagName("*").length}),c.getElementsByClassName=$.test(e.getElementsByClassName)&&ib(');
print_out('function(a){return a.innerHTML="<div class=''a''></div><div class=''a i''></div>",a.firstChild.className="i",2===a.getElementsByClassName("i").length}),c.getById=ib(function(a){return o.appendChild(a).id=u,!e.getElementsByName||!e.getElementsByName(u).length}),c.getById?(d.find.ID=function(a,b){if(typeof b.getElementById!==C&&p){var c=b.getElementById(a);return c&&c.parentNode?[c]:[]}},d.filter.ID=function(a){var b=a.replace(cb,db);return function(a){return a.getAttribute("id")===b}}):(delete d.find.ID,d.filter.ID=function(a){var b=a.replace(cb,db);return function(a){var c=typeof a.getAttributeNode!==C&&a.getAttributeNode("id");return c&&c.value===b}}),d.find.TAG=c.getElementsByTagName?function(a,b){return typeof b.getElementsByTagName!==C?b.getElementsByTagName(a):void 0}:function(a,b){var c,d=[],e=0,f=b.getElementsByTagName(a);if("*"===a){while(c=f[e++])1===c.nodeType&&d.push(c);return d}return f},d.find.CLASS=c.getElementsByClassName&&function(a,b){return typeof b.getElementsByClassName!==C&&p?b.getElementsByClassName(a):void 0},r=[],q=[],(c.qsa=$.test(e.querySelectorAll))&&(ib(function(a){a.innerHTML="<select msallowclip=''''><option selected=''''></option></select>",a.querySelectorAll("[msallowclip^='''']").length&&q.push("[*^$]="+M+"*(?:''''|\"\")"),a.querySelectorAll("[selected]").length||q.push("\\["+M+"*(?:value|"+L+")"),a.querySelectorAll(":checked").length||q.push(":checked")}),ib(function(a){var b=e.createElement("input");');
print_out('b.setAttribute("type","hidden"),a.appendChild(b).setAttribute("name","D"),a.querySelectorAll("[name=d]").length&&q.push("name"+M+"*[*^$|!~]?="),a.querySelectorAll(":enabled").length||q.push(":enabled",":disabled"),a.querySelectorAll("*,:x"),q.push(",.*:")})),(c.matchesSelector=$.test(s=o.matches||o.webkitMatchesSelector||o.mozMatchesSelector||o.oMatchesSelector||o.msMatchesSelector))&&ib(function(a){c.disconnectedMatch=s.call(a,"div"),s.call(a,"[s!='''']:x"),r.push("!=",Q)}),q=q.length&&new RegExp(q.join("|")),r=r.length&&new RegExp(r.join("|")),b=$.test(o.compareDocumentPosition),t=b||$.test(o.contains)?function(a,b){var c=9===a.nodeType?a.documentElement:a,d=b&&b.parentNode;return a===d||!(!d||1!==d.nodeType||!(c.contains?c.contains(d):a.compareDocumentPosition&&16&a.compareDocumentPosition(d)))}:function(a,b){if(b)while(b=b.parentNode)if(b===a)return!0;return!1},B=b?function(a,b){if(a===b)return l=!0,0;var d=!a.compareDocumentPosition-!b.compareDocumentPosition;return d?d:(d=(a.ownerDocument||a)===(b.ownerDocument||b)?a.compareDocumentPosition(b):1,1&d||!c.sortDetached&&b.compareDocumentPosition(a)===d?a===e||a.ownerDocument===v&&t(v,a)?-1:b===e||b.ownerDocument===v&&t(v,b)?1:k?K.call(k,a)-K.call(k,b):0:4&d?-1:1)}:function(a,b){if(a===b)return l=!0,0;var c,d=0,f=a.parentNode,g=b.parentNode,h=[a],i=[b];if(!f||!g)return a===e?-1:b===e?1:f?-1:g?1:k?K.call(k,a)-K.call(k,b):0;if(f===g)return kb(a,b);c=a;while(c=c.parentNode)h.unshift(c);c=b;while(c=c.parentNode)i.unshift(c);');
print_out('while(h[d]===i[d])d++;return d?kb(h[d],i[d]):h[d]===v?-1:i[d]===v?1:0},e):n},fb.matches=function(a,b){return fb(a,null,null,b)},fb.matchesSelector=function(a,b){if((a.ownerDocument||a)!==n&&m(a),b=b.replace(U,"=''$1'']"),!(!c.matchesSelector||!p||r&&r.test(b)||q&&q.test(b)))try{var d=s.call(a,b);if(d||c.disconnectedMatch||a.document&&11!==a.document.nodeType)return d}catch(e){}return fb(b,n,null,[a]).length>0},fb.contains=function(a,b){return(a.ownerDocument||a)!==n&&m(a),t(a,b)},fb.attr=function(a,b){(a.ownerDocument||a)!==n&&m(a);var e=d.attrHandle[b.toLowerCase()],f=e&&E.call(d.attrHandle,b.toLowerCase())?e(a,b,!p):void 0;return void 0!==f?f:c.attributes||!p?a.getAttribute(b):(f=a.getAttributeNode(b))&&f.specified?f.value:null},fb.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)},fb.uniqueSort=function(a){var b,d=[],e=0,f=0;if(l=!c.detectDuplicates,k=!c.sortStable&&a.slice(0),a.sort(B),l){while(b=a[f++])b===a[f]&&(e=d.push(f));while(e--)a.splice(d[e],1)}return k=null,a},e=fb.getText=function(a){var b,c="",d=0,f=a.nodeType;if(f){if(1===f||9===f||11===f){if("string"==typeof a.textContent)return a.textContent;for(a=a.firstChild;a;a=a.nextSibling)c+=e(a)}else if(3===f||4===f)return a.nodeValue}else while(b=a[d++])c+=e(b);return c},d=fb.selectors={cacheLength:50,createPseudo:hb,match:X,attrHandle:{},find:{},relative:{">":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(a){return a[1]=a[1].replace(cb,db),a[3]=(a[3]||a[4]||a[5]||"").replace(cb,db),"~="===a[2]&&(a[3]=" "+a[3]+" "),a.slice(0,4)},CHILD:function(a){return a[1]=a[1].toLowerCase(),"nth"===a[1].slice(0,3)?(a[3]||fb.error(a[0]),a[4]=+(a[4]?a[5]+(a[6]||1):2*("even"===a[3]||"odd"===a[3])),a[5]=+(a[7]+a[8]||"odd"===a[3])):a[3]&&fb.error(a[0]),a},PSEUDO:function(a){var b,c=!a[6]&&a[2];');
print_out('return X.CHILD.test(a[0])?null:(a[3]?a[2]=a[4]||a[5]||"":c&&V.test(c)&&(b=g(c,!0))&&(b=c.indexOf(")",c.length-b)-c.length)&&(a[0]=a[0].slice(0,b),a[2]=c.slice(0,b)),a.slice(0,3))}},filter:{TAG:function(a){var b=a.replace(cb,db).toLowerCase();return"*"===a?function(){return!0}:function(a){return a.nodeName&&a.nodeName.toLowerCase()===b}},CLASS:function(a){var b=y[a+" "];return b||(b=new RegExp("(^|"+M+")"+a+"("+M+"|$)"))&&y(a,function(a){return b.test("string"==typeof a.className&&a.className||typeof a.getAttribute!==C&&a.getAttribute("class")||"")})},ATTR:function(a,b,c){return function(d){var e=fb.attr(d,a);return null==e?"!="===b:b?(e+="","="===b?e===c:"!="===b?e!==c:"^="===b?c&&0===e.indexOf(c):"*="===b?c&&e.indexOf(c)>-1:"$="===b?c&&e.slice(-c.length)===c:"~="===b?(" "+e+" ").indexOf(c)>-1:"|="===b?e===c||e.slice(0,c.length+1)===c+"-":!1):!0}},CHILD:function(a,b,c,d,e){var f="nth"!==a.slice(0,3),g="last"!==a.slice(-4),h="of-type"===b;return 1===d&&0===e?function(a){return!!a.parentNode}:function(b,c,i){var j,k,l,m,n,o,p=f!==g?"nextSibling":"previousSibling",q=b.parentNode,r=h&&b.nodeName.toLowerCase(),s=!i&&!h;if(q){if(f){while(p){l=b;while(l=l[p])if(h?l.nodeName.toLowerCase()===r:1===l.nodeType)return!1;o=p="only"===a&&!o&&"nextSibling"}return!0}if(o=[g?q.firstChild:q.lastChild],g&&s){k=q[u]||(q[u]={}),j=k[a]||[],n=j[0]===w&&j[1],m=j[0]===w&&j[2],l=n&&q.childNodes[n];while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if(1===l.nodeType&&++m&&l===b){k[a]=[w,n,m];break}}else if(s&&(j=(b[u]||(b[u]={}))[a])&&j[0]===w)m=j[1];else while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if((h?l.nodeName.toLowerCase()===r:1===l.nodeType)&&++m&&(s&&((l[u]||(l[u]={}))[a]=[w,m]),l===b))break;');
print_out('return m-=e,m===d||m%d===0&&m/d>=0}}},PSEUDO:function(a,b){var c,e=d.pseudos[a]||d.setFilters[a.toLowerCase()]||fb.error("unsupported pseudo: "+a);return e[u]?e(b):e.length>1?(c=[a,a,"",b],d.setFilters.hasOwnProperty(a.toLowerCase())?hb(function(a,c){var d,f=e(a,b),g=f.length;while(g--)d=K.call(a,f[g]),a[d]=!(c[d]=f[g])}):function(a){return e(a,0,c)}):e}},pseudos:{not:hb(function(a){var b=[],c=[],d=h(a.replace(R,"$1"));return d[u]?hb(function(a,b,c,e){var f,g=d(a,null,e,[]),h=a.length;while(h--)(f=g[h])&&(a[h]=!(b[h]=f))}):function(a,e,f){return b[0]=a,d(b,null,f,c),!c.pop()}}),has:hb(function(a){return function(b){return fb(a,b).length>0}}),contains:hb(function(a){return function(b){return(b.textContent||b.innerText||e(b)).indexOf(a)>-1}}),lang:hb(function(a){return W.test(a||"")||fb.error("unsupported lang: "+a),a=a.replace(cb,db).toLowerCase(),function(b){var c;do if(c=p?b.lang:b.getAttribute("xml:lang")||b.getAttribute("lang"))return c=c.toLowerCase(),c===a||0===c.indexOf(a+"-");while((b=b.parentNode)&&1===b.nodeType);return!1}}),target:function(b){var c=a.location&&a.location.hash;return c&&c.slice(1)===b.id},root:function(a){return a===o},focus:function(a){return a===n.activeElement&&(!n.hasFocus||n.hasFocus())&&!!(a.type||a.href||~a.tabIndex)},enabled:function(a){return a.disabled===!1},disabled:function(a){return a.disabled===!0},checked:function(a){var b=a.nodeName.toLowerCase();');
print_out('return"input"===b&&!!a.checked||"option"===b&&!!a.selected},selected:function(a){return a.parentNode&&a.parentNode.selectedIndex,a.selected===!0},empty:function(a){for(a=a.firstChild;a;a=a.nextSibling)if(a.nodeType<6)return!1;return!0},parent:function(a){return!d.pseudos.empty(a)},header:function(a){return Z.test(a.nodeName)},input:function(a){return Y.test(a.nodeName)},button:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&"button"===a.type||"button"===b},text:function(a){var b;return"input"===a.nodeName.toLowerCase()&&"text"===a.type&&(null==(b=a.getAttribute("type"))||"text"===b.toLowerCase())},first:nb(function(){return[0]}),last:nb(function(a,b){return[b-1]}),eq:nb(function(a,b,c){return[0>c?c+b:c]}),even:nb(function(a,b){for(var c=0;b>c;c+=2)a.push(c);return a}),odd:nb(function(a,b){for(var c=1;b>c;c+=2)a.push(c);return a}),lt:nb(function(a,b,c){for(var d=0>c?c+b:c;--d>=0;)a.push(d);return a}),gt:nb(function(a,b,c){for(var d=0>c?c+b:c;++d<b;)a.push(d);return a})}},d.pseudos.nth=d.pseudos.eq;for(b in{radio:!0,checkbox:!0,file:!0,password:!0,image:!0})d.pseudos[b]=lb(b);for(b in{submit:!0,reset:!0})d.pseudos[b]=mb(b);function pb(){}pb.prototype=d.filters=d.pseudos,d.setFilters=new pb,g=fb.tokenize=function(a,b){var c,e,f,g,h,i,j,k=z[a+" "];if(k)return b?0:k.slice(0);h=a,i=[],j=d.preFilter;while(h){(!c||(e=S.exec(h)))&&(e&&(h=h.slice(e[0].length)||h),i.push(f=[])),c=!1,(e=T.exec(h))&&(c=e.shift(),f.push({value:c,type:e[0].replace(R," ")}),h=h.slice(c.length));for(g in d.filter)!(e=X[g].exec(h))||j[g]&&!(e=j[g](e))||(c=e.shift(),f.push({value:c,type:g,matches:e}),h=h.slice(c.length));if(!c)break}return b?h.length:h?fb.error(a):z(a,i).slice(0)};function qb(a){for(var b=0,c=a.length,d="";c>b;b++)d+=a[b].value;return d}');
print_out('function rb(a,b,c){var d=b.dir,e=c&&"parentNode"===d,f=x++;return b.first?function(b,c,f){while(b=b[d])if(1===b.nodeType||e)return a(b,c,f)}:function(b,c,g){var h,i,j=[w,f];if(g){while(b=b[d])if((1===b.nodeType||e)&&a(b,c,g))return!0}else while(b=b[d])if(1===b.nodeType||e){if(i=b[u]||(b[u]={}),(h=i[d])&&h[0]===w&&h[1]===f)return j[2]=h[2];if(i[d]=j,j[2]=a(b,c,g))return!0}}}function sb(a){return a.length>1?function(b,c,d){var e=a.length;while(e--)if(!a[e](b,c,d))return!1;return!0}:a[0]}function tb(a,b,c){for(var d=0,e=b.length;e>d;d++)fb(a,b[d],c);return c}function ub(a,b,c,d,e){for(var f,g=[],h=0,i=a.length,j=null!=b;i>h;h++)(f=a[h])&&(!c||c(f,d,e))&&(g.push(f),j&&b.push(h));return g}function vb(a,b,c,d,e,f){return d&&!d[u]&&(d=vb(d)),e&&!e[u]&&(e=vb(e,f)),hb(function(f,g,h,i){var j,k,l,m=[],n=[],o=g.length,p=f||tb(b||"*",h.nodeType?[h]:h,[]),q=!a||!f&&b?p:ub(p,m,a,h,i),r=c?e||(f?a:o||d)?[]:g:q;if(c&&c(q,r,h,i),d){j=ub(r,n),d(j,[],h,i),k=j.length;while(k--)(l=j[k])&&(r[n[k]]=!(q[n[k]]=l))}if(f){if(e||a){if(e){j=[],k=r.length;while(k--)(l=r[k])&&j.push(q[k]=l);e(null,r=[],j,i)}k=r.length;while(k--)(l=r[k])&&(j=e?K.call(f,l):m[k])>-1&&(f[j]=!(g[j]=l))}}else r=ub(r===g?r.splice(o,r.length):r),e?e(null,g,r,i):I.apply(g,r)})}function wb(a){for(var b,c,e,f=a.length,g=d.relative[a[0].type],h=g||d.relative[" "],i=g?1:0,k=rb(function(a){return a===b},h,!0),l=rb(function(a){return K.call(b,a)>-1},h,!0),m=[function(a,c,d){return!g&&(d||c!==j)||((b=c).nodeType?k(a,c,d):l(a,c,d))}];f>i;i++)if(c=d.relative[a[i].type])m=[rb(sb(m),c)];else{if(c=d.filter[a[i].type].apply(null,a[i].matches),c[u]){for(e=++i;f>e;e++)if(d.relative[a[e].type])break;');
print_out('return vb(i>1&&sb(m),i>1&&qb(a.slice(0,i-1).concat({value:" "===a[i-2].type?"*":""})).replace(R,"$1"),c,e>i&&wb(a.slice(i,e)),f>e&&wb(a=a.slice(e)),f>e&&qb(a))}m.push(c)}return sb(m)}function xb(a,b){var c=b.length>0,e=a.length>0,f=function(f,g,h,i,k){var l,m,o,p=0,q="0",r=f&&[],s=[],t=j,u=f||e&&d.find.TAG("*",k),v=w+=null==t?1:Math.random()||.1,x=u.length;for(k&&(j=g!==n&&g);q!==x&&null!=(l=u[q]);q++){if(e&&l){m=0;while(o=a[m++])if(o(l,g,h)){i.push(l);break}k&&(w=v)}c&&((l=!o&&l)&&p--,f&&r.push(l))}if(p+=q,c&&q!==p){m=0;while(o=b[m++])o(r,s,g,h);if(f){if(p>0)while(q--)r[q]||s[q]||(s[q]=G.call(i));s=ub(s)}I.apply(i,s),k&&!f&&s.length>0&&p+b.length>1&&fb.uniqueSort(i)}return k&&(w=v,j=t),r};return c?hb(f):f}return h=fb.compile=function(a,b){var c,d=[],e=[],f=A[a+" "];if(!f){b||(b=g(a)),c=b.length;while(c--)f=wb(b[c]),f[u]?d.push(f):e.push(f);f=A(a,xb(e,d)),f.selector=a}return f},i=fb.select=function(a,b,e,f){var i,j,k,l,m,n="function"==typeof a&&a,o=!f&&g(a=n.selector||a);if(e=e||[],1===o.length){if(j=o[0]=o[0].slice(0),j.length>2&&"ID"===(k=j[0]).type&&c.getById&&9===b.nodeType&&p&&d.relative[j[1].type]){if(b=(d.find.ID(k.matches[0].replace(cb,db),b)||[])[0],!b)return e;n&&(b=b.parentNode),a=a.slice(j.shift().value.length)}i=X.needsContext.test(a)?0:j.length;while(i--)');
print_out('{if(k=j[i],d.relative[l=k.type])break;if((m=d.find[l])&&(f=m(k.matches[0].replace(cb,db),ab.test(j[0].type)&&ob(b.parentNode)||b))){if(j.splice(i,1),a=f.length&&qb(j),!a)return I.apply(e,f),e;break}}}return(n||h(a,o))(f,b,!p,e,ab.test(a)&&ob(b.parentNode)||b),e},c.sortStable=u.split("").sort(B).join("")===u,c.detectDuplicates=!!l,m(),c.sortDetached=ib(function(a){return 1&a.compareDocumentPosition(n.createElement("div"))}),ib(function(a){return a.innerHTML="<a href=''#''></a>","#"===a.firstChild.getAttribute("href")})||jb("type|href|height|width",function(a,b,c){return c?void 0:a.getAttribute(b,"type"===b.toLowerCase()?1:2)}),c.attributes&&ib(function(a){return a.innerHTML="<input/>",a.firstChild.setAttribute("value",""),""===a.firstChild.getAttribute("value")})||jb("value",function(a,b,c){return c||"input"!==a.nodeName.toLowerCase()?void 0:a.defaultValue}),ib(function(a){return null==a.getAttribute("disabled")})||jb(L,function(a,b,c){var d;return c?void 0:a[b]===!0?b.toLowerCase():(d=a.getAttributeNode(b))&&d.specified?d.value:null}),fb}(a);m.find=s,m.expr=s.selectors,m.expr[":"]=m.expr.pseudos,m.unique=s.uniqueSort,m.text=s.getText,m.isXMLDoc=s.isXML,m.contains=s.contains;var t=m.expr.match.needsContext,u=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,v=/^.[^:#\[\.,]*$/;function w(a,b,c){if(m.isFunction(b))return m.grep(a,function(a,d){return!!b.call(a,d,a)!==c});if(b.nodeType)return m.grep(a,function(a){return a===b!==c});if("string"==typeof b){if(v.test(b))return m.filter(b,a,c);b=m.filter(b,a)}return m.grep(a,function(a){return m.inArray(a,b)>=0!==c})}m.filter=function(a,b,c){var d=b[0];');
print_out('return c&&(a=":not("+a+")"),1===b.length&&1===d.nodeType?m.find.matchesSelector(d,a)?[d]:[]:m.find.matches(a,m.grep(b,function(a){return 1===a.nodeType}))},m.fn.extend({find:function(a){var b,c=[],d=this,e=d.length;if("string"!=typeof a)return this.pushStack(m(a).filter(function(){for(b=0;e>b;b++)if(m.contains(d[b],this))return!0}));for(b=0;e>b;b++)m.find(a,d[b],c);return c=this.pushStack(e>1?m.unique(c):c),c.selector=this.selector?this.selector+" "+a:a,c},filter:function(a){return this.pushStack(w(this,a||[],!1))},not:function(a){return this.pushStack(w(this,a||[],!0))},is:function(a){return!!w(this,"string"==typeof a&&t.test(a)?m(a):a||[],!1).length}});var x,y=a.document,z=/^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,A=m.fn.init=function(a,b){var c,d;if(!a)return this;if("string"==typeof a){if(c="<"===a.charAt(0)&&">"===a.charAt(a.length-1)&&a.length>=3?[null,a,null]:z.exec(a),!c||!c[1]&&b)return!b||b.jquery?(b||x).find(a):this.constructor(b).find(a);if(c[1]){if(b=b instanceof m?b[0]:b,m.merge(this,m.parseHTML(c[1],b&&b.nodeType?b.ownerDocument||b:y,!0)),u.test(c[1])&&m.isPlainObject(b))for(c in b)m.isFunction(this[c])?this[c](b[c]):this.attr(c,b[c]);return this}if(d=y.getElementById(c[2]),d&&d.parentNode){if(d.id!==c[2])return x.find(a);this.length=1,this[0]=d}return this.context=y,this.selector=a,this}return a.nodeType?(this.context=this[0]=a,this.length=1,this):m.isFunction(a)?"undefined"!=typeof x.ready?x.ready(a):a(m):(void 0!==a.selector&&(this.selector=a.selector,this.context=a.context),m.makeArray(a,this))};A.prototype=m.fn,x=m(y);');
print_out('var B=/^(?:parents|prev(?:Until|All))/,C={children:!0,contents:!0,next:!0,prev:!0};m.extend({dir:function(a,b,c){var d=[],e=a[b];while(e&&9!==e.nodeType&&(void 0===c||1!==e.nodeType||!m(e).is(c)))1===e.nodeType&&d.push(e),e=e[b];return d},sibling:function(a,b){for(var c=[];a;a=a.nextSibling)1===a.nodeType&&a!==b&&c.push(a);return c}}),m.fn.extend({has:function(a){var b,c=m(a,this),d=c.length;return this.filter(function(){for(b=0;d>b;b++)if(m.contains(this,c[b]))return!0})},closest:function(a,b){for(var c,d=0,e=this.length,f=[],g=t.test(a)||"string"!=typeof a?m(a,b||this.context):0;e>d;d++)for(c=this[d];c&&c!==b;c=c.parentNode)if(c.nodeType<11&&(g?g.index(c)>-1:1===c.nodeType&&m.find.matchesSelector(c,a))){f.push(c);break}return this.pushStack(f.length>1?m.unique(f):f)},index:function(a){return a?"string"==typeof a?m.inArray(this[0],m(a)):m.inArray(a.jquery?a[0]:a,this):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(a,b){return this.pushStack(m.unique(m.merge(this.get(),m(a,b))))},addBack:function(a){return this.add(null==a?this.prevObject:this.prevObject.filter(a))}});function D(a,b){do a=a[b];while(a&&1!==a.nodeType);return a}m.each({parent:function(a){var b=a.parentNode;return b&&11!==b.nodeType?b:null},parents:function(a){return m.dir(a,"parentNode")},parentsUntil:function(a,b,c){return m.dir(a,"parentNode",c)},next:function(a){return D(a,"nextSibling")},prev:function(a){return D(a,"previousSibling")},nextAll:function(a){return m.dir(a,"nextSibling")},prevAll:function(a){return m.dir(a,"previousSibling")},nextUntil:function(a,b,c)');
print_out('{return m.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return m.dir(a,"previousSibling",c)},siblings:function(a){return m.sibling((a.parentNode||{}).firstChild,a)},children:function(a){return m.sibling(a.firstChild)},contents:function(a){return m.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:m.merge([],a.childNodes)}},function(a,b){m.fn[a]=function(c,d){var e=m.map(this,b,c);return"Until"!==a.slice(-5)&&(d=c),d&&"string"==typeof d&&(e=m.filter(d,e)),this.length>1&&(C[a]||(e=m.unique(e)),B.test(a)&&(e=e.reverse())),this.pushStack(e)}});var E=/\S+/g,F={};function G(a){var b=F[a]={};return m.each(a.match(E)||[],function(a,c){b[c]=!0}),b}m.Callbacks=function(a){a="string"==typeof a?F[a]||G(a):m.extend({},a);var b,c,d,e,f,g,h=[],i=!a.once&&[],j=function(l){for(c=a.memory&&l,d=!0,f=g||0,g=0,e=h.length,b=!0;h&&e>f;f++)if(h[f].apply(l[0],l[1])===!1&&a.stopOnFalse){c=!1;break}b=!1,h&&(i?i.length&&j(i.shift()):c?h=[]:k.disable())},k={add:function(){if(h){var d=h.length;!function f(b){m.each(b,function(b,c){var d=m.type(c);"function"===d?a.unique&&k.has(c)||h.push(c):c&&c.length&&"string"!==d&&f(c)})}(arguments),b?e=h.length:c&&(g=d,j(c))}return this},remove:function(){return h&&m.each(arguments,function(a,c){var d;while((d=m.inArray(c,h,d))>-1)h.splice(d,1),b&&(e>=d&&e--,f>=d&&f--)}),this},has:function(a){return a?m.inArray(a,h)>-1:!(!h||!h.length)},empty:function(){return h=[],e=0,this},disable:function(){return h=i=c=void 0,this},disabled:');
print_out('function(){return!h},lock:function(){return i=void 0,c||k.disable(),this},locked:function(){return!i},fireWith:function(a,c){return!h||d&&!i||(c=c||[],c=[a,c.slice?c.slice():c],b?i.push(c):j(c)),this},fire:function(){return k.fireWith(this,arguments),this},fired:function(){return!!d}};return k},m.extend({Deferred:function(a){var b=[["resolve","done",m.Callbacks("once memory"),"resolved"],["reject","fail",m.Callbacks("once memory"),"rejected"],["notify","progress",m.Callbacks("memory")]],c="pending",d={state:function(){return c},always:function(){return e.done(arguments).fail(arguments),this},then:function(){var a=arguments;return m.Deferred(function(c){m.each(b,function(b,f){var g=m.isFunction(a[b])&&a[b];e[f[1]](function(){var a=g&&g.apply(this,arguments);a&&m.isFunction(a.promise)?a.promise().done(c.resolve).fail(c.reject).progress(c.notify):c[f[0]+"With"](this===d?c.promise():this,g?[a]:arguments)})}),a=null}).promise()},promise:function(a){return null!=a?m.extend(a,d):d}},e={};return d.pipe=d.then,m.each(b,function(a,f){var g=f[2],h=f[3];d[f[1]]=g.add,h&&g.add(function(){c=h},b[1^a][2].disable,b[2][2].lock),e[f[0]]=function(){return e[f[0]+"With"](this===e?d:this,arguments),this},e[f[0]+"With"]=g.fireWith}),d.promise(e),a&&a.call(e,e),e},when:function(a){var b=0,c=d.call(arguments),e=c.length,f=1!==e||a&&m.isFunction(a.promise)?e:0,g=1===f?a:m.Deferred(),h=function(a,b,c)');
print_out('{return function(e){b[a]=this,c[a]=arguments.length>1?d.call(arguments):e,c===i?g.notifyWith(b,c):--f||g.resolveWith(b,c)}},i,j,k;if(e>1)for(i=new Array(e),j=new Array(e),k=new Array(e);e>b;b++)c[b]&&m.isFunction(c[b].promise)?c[b].promise().done(h(b,k,c)).fail(g.reject).progress(h(b,j,i)):--f;return f||g.resolveWith(k,c),g.promise()}});var H;m.fn.ready=function(a){return m.ready.promise().done(a),this},m.extend({isReady:!1,readyWait:1,holdReady:function(a){a?m.readyWait++:m.ready(!0)},ready:function(a){if(a===!0?!--m.readyWait:!m.isReady){if(!y.body)return setTimeout(m.ready);m.isReady=!0,a!==!0&&--m.readyWait>0||(H.resolveWith(y,[m]),m.fn.triggerHandler&&(m(y).triggerHandler("ready"),m(y).off("ready")))}}});function I(){y.addEventListener?(y.removeEventListener("DOMContentLoaded",J,!1),a.removeEventListener("load",J,!1)):(y.detachEvent("onreadystatechange",J),a.detachEvent("onload",J))}function J(){(y.addEventListener||"load"===event.type||"complete"===y.readyState)&&(I(),m.ready())}m.ready.promise=function(b){if(!H)if(H=m.Deferred(),"complete"===y.readyState)setTimeout(m.ready);else if(y.addEventListener)y.addEventListener("DOMContentLoaded",J,!1),a.addEventListener("load",J,!1);else{y.attachEvent("onreadystatechange",J),a.attachEvent("onload",J);var c=!1;try{c=null==a.frameElement&&y.documentElement}catch(d){}c&&c.doScroll&&!function e(){if(!m.isReady){try{c.doScroll("left")}catch(a){return setTimeout(e,50)}I(),m.ready()}}()}return H.promise(b)};var K="undefined",L;for(L in m(k))break;k.ownLast="0"!==L,k.inlineBlockNeedsLayout=!1,m(function(){var a,b,c,d;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="display:inline;margin:0;border:0;padding:1px;width:1px;zoom:1",k.inlineBlockNeedsLayout=a=3===b.offsetWidth,a&&(c.style.zoom=1)),c.removeChild(d))}),function(){var a=y.createElement("div");');
print_out('if(null==k.deleteExpando){k.deleteExpando=!0;try{delete a.test}catch(b){k.deleteExpando=!1}}a=null}(),m.acceptData=function(a){var b=m.noData[(a.nodeName+" ").toLowerCase()],c=+a.nodeType||1;return 1!==c&&9!==c?!1:!b||b!==!0&&a.getAttribute("classid")===b};var M=/^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,N=/([A-Z])/g;function O(a,b,c){if(void 0===c&&1===a.nodeType){var d="data-"+b.replace(N,"-$1").toLowerCase();if(c=a.getAttribute(d),"string"==typeof c){try{c="true"===c?!0:"false"===c?!1:"null"===c?null:+c+""===c?+c:M.test(c)?m.parseJSON(c):c}catch(e){}m.data(a,b,c)}else c=void 0}return c}function P(a){var b;for(b in a)if(("data"!==b||!m.isEmptyObject(a[b]))&&"toJSON"!==b)return!1;return!0}function Q(a,b,d,e){if(m.acceptData(a)){var f,g,h=m.expando,i=a.nodeType,j=i?m.cache:a,k=i?a[h]:a[h]&&h;if(k&&j[k]&&(e||j[k].data)||void 0!==d||"string"!=typeof b)return k||(k=i?a[h]=c.pop()||m.guid++:h),j[k]||(j[k]=i?{}:{toJSON:m.noop}),("object"==typeof b||"function"==typeof b)&&(e?j[k]=m.extend(j[k],b):j[k].data=m.extend(j[k].data,b)),g=j[k],e||(g.data||(g.data={}),g=g.data),void 0!==d&&(g[m.camelCase(b)]=d),"string"==typeof b?(f=g[b],null==f&&(f=g[m.camelCase(b)])):f=g,f}}function R(a,b,c){if(m.acceptData(a)){var d,e,f=a.nodeType,g=f?m.cache:a,h=f?a[m.expando]:m.expando;if(g[h]){if(b&&(d=c?g[h]:g[h].data)){m.isArray(b)?b=b.concat(m.map(b,m.camelCase)):b in d?b=[b]:(b=m.camelCase(b),b=b in d?[b]:b.split(" ")),e=b.length;while(e--)delete d[b[e]];if(c?!P(d):!m.isEmptyObject(d))return}(c||(delete g[h].data,P(g[h])))&&(f?m.cleanData([a],!0):k.deleteExpando||g!=g.window?delete g[h]:g[h]=null)}}}m.extend({cache:{},noData:{"applet ":!0,"embed ":!0,"object ":"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"},hasData:function(a)');
print_out('{return a=a.nodeType?m.cache[a[m.expando]]:a[m.expando],!!a&&!P(a)},data:function(a,b,c){return Q(a,b,c)},removeData:function(a,b){return R(a,b)},_data:function(a,b,c){return Q(a,b,c,!0)},_removeData:function(a,b){return R(a,b,!0)}}),m.fn.extend({data:function(a,b){var c,d,e,f=this[0],g=f&&f.attributes;if(void 0===a){if(this.length&&(e=m.data(f),1===f.nodeType&&!m._data(f,"parsedAttrs"))){c=g.length;while(c--)g[c]&&(d=g[c].name,0===d.indexOf("data-")&&(d=m.camelCase(d.slice(5)),O(f,d,e[d])));m._data(f,"parsedAttrs",!0)}return e}return"object"==typeof a?this.each(function(){m.data(this,a)}):arguments.length>1?this.each(function(){m.data(this,a,b)}):f?O(f,a,m.data(f,a)):void 0},removeData:function(a){return this.each(function(){m.removeData(this,a)})}}),m.extend({queue:function(a,b,c){var d;return a?(b=(b||"fx")+"queue",d=m._data(a,b),c&&(!d||m.isArray(c)?d=m._data(a,b,m.makeArray(c)):d.push(c)),d||[]):void 0},dequeue:function(a,b){b=b||"fx";var c=m.queue(a,b),d=c.length,e=c.shift(),f=m._queueHooks(a,b),g=function(){m.dequeue(a,b)};"inprogress"===e&&(e=c.shift(),d--),e&&("fx"===b&&c.unshift("inprogress"),delete f.stop,e.call(a,g,f)),!d&&f&&f.empty.fire()},_queueHooks:function(a,b){var c=b+"queueHooks";return m._data(a,c)||m._data(a,c,{empty:m.Callbacks("once memory").add(function(){m._removeData(a,b+"queue"),m._removeData(a,c)})})}}),m.fn.extend({queue:function(a,b){var c=2;return"string"!=typeof a&&(b=a,a="fx",c--),arguments.length<c?m.queue(this[0],a):void 0===b?this:this.each(function(){var c=m.queue(this,a,b);');
print_out('m._queueHooks(this,a),"fx"===a&&"inprogress"!==c[0]&&m.dequeue(this,a)})},dequeue:function(a){return this.each(function(){m.dequeue(this,a)})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,b){var c,d=1,e=m.Deferred(),f=this,g=this.length,h=function(){--d||e.resolveWith(f,[f])};"string"!=typeof a&&(b=a,a=void 0),a=a||"fx";while(g--)c=m._data(f[g],a+"queueHooks"),c&&c.empty&&(d++,c.empty.add(h));return h(),e.promise(b)}});var S=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,T=["Top","Right","Bottom","Left"],U=function(a,b){return a=b||a,"none"===m.css(a,"display")||!m.contains(a.ownerDocument,a)},V=m.access=function(a,b,c,d,e,f,g){var h=0,i=a.length,j=null==c;if("object"===m.type(c)){e=!0;for(h in c)m.access(a,b,h,c[h],!0,f,g)}else if(void 0!==d&&(e=!0,m.isFunction(d)||(g=!0),j&&(g?(b.call(a,d),b=null):(j=b,b=function(a,b,c){return j.call(m(a),c)})),b))for(;i>h;h++)b(a[h],c,g?d:d.call(a[h],h,b(a[h],c)));return e?a:j?b.call(a):i?b(a[0],c):f},W=/^(?:checkbox|radio)$/i;!function(){var a=y.createElement("input"),b=y.createElement("div"),c=y.createDocumentFragment();');
print_out('if(b.innerHTML="  <link/><table></table><a href=''/a''>a</a><input type=''checkbox''/>",k.leadingWhitespace=3===b.firstChild.nodeType,k.tbody=!b.getElementsByTagName("tbody").length,k.htmlSerialize=!!b.getElementsByTagName("link").length,k.html5Clone="<:nav></:nav>"!==y.createElement("nav").cloneNode(!0).outerHTML,a.type="checkbox",a.checked=!0,c.appendChild(a),k.appendChecked=a.checked,b.innerHTML="<textarea>x</textarea>",k.noCloneChecked=!!b.cloneNode(!0).lastChild.defaultValue,c.appendChild(b),b.innerHTML="<input type=''radio'' checked=''checked'' name=''t''/>",k.checkClone=b.cloneNode(!0).cloneNode(!0).lastChild.checked,k.noCloneEvent=!0,b.attachEvent&&(b.attachEvent("onclick",function(){k.noCloneEvent=!1}),b.cloneNode(!0).click()),null==k.deleteExpando){k.deleteExpando=!0;try{delete b.test}catch(d){k.deleteExpando=!1}}}(),function(){var b,c,d=y.createElement("div");for(b in{submit:!0,change:!0,focusin:!0})c="on"+b,(k[b+"Bubbles"]=c in a)||(d.setAttribute(c,"t"),k[b+"Bubbles"]=d.attributes[c].expando===!1);d=null}();var X=/^(?:input|select|textarea)$/i,Y=/^key/,Z=/^(?:mouse|pointer|contextmenu)|click/,$=/^(?:focusinfocus|focusoutblur)$/,_=/^([^.]*)(?:\.(.+)|)$/;function ab(){return!0}');
print_out('function bb(){return!1}function cb(){try{return y.activeElement}catch(a){}}m.event={global:{},add:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m._data(a);if(r){c.handler&&(i=c,c=i.handler,e=i.selector),c.guid||(c.guid=m.guid++),(g=r.events)||(g=r.events={}),(k=r.handle)||(k=r.handle=function(a){return typeof m===K||a&&m.event.triggered===a.type?void 0:m.event.dispatch.apply(k.elem,arguments)},k.elem=a),b=(b||"").match(E)||[""],h=b.length;while(h--)f=_.exec(b[h])||[],o=q=f[1],p=(f[2]||"").split(".").sort(),o&&(j=m.event.special[o]||{},o=(e?j.delegateType:j.bindType)||o,j=m.event.special[o]||{},l=m.extend({type:o,origType:q,data:d,handler:c,guid:c.guid,selector:e,needsContext:e&&m.expr.match.needsContext.test(e),namespace:p.join(".")},i),(n=g[o])||(n=g[o]=[],n.delegateCount=0,j.setup&&j.setup.call(a,d,p,k)!==!1||(a.addEventListener?a.addEventListener(o,k,!1):a.attachEvent&&a.attachEvent("on"+o,k))),j.add&&(j.add.call(a,l),l.handler.guid||(l.handler.guid=c.guid)),e?n.splice(n.delegateCount++,0,l):n.push(l),m.event.global[o]=!0);a=null}},remove:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m.hasData(a)&&m._data(a);if(r&&(k=r.events)){b=(b||"").match(E)||[""],j=b.length;while(j--)if(h=_.exec(b[j])||[],o=q=h[1],p=(h[2]||"").split(".").sort(),o){l=m.event.special[o]||{},o=(d?l.delegateType:l.bindType)||o,n=k[o]||[],h=h[2]&&new RegExp("(^|\\.)"+p.join("\\.(?:.*\\.|)")+"(\\.|$)"),i=f=n.length;while(f--)g=n[f],!e&&q!==g.origType||c&&c.guid!==g.guid||h&&!h.test(g.namespace)||d&&d!==g.selector&&("**"!==d||!g.selector)||(n.splice(f,1),g.selector&&n.delegateCount--,l.remove&&l.remove.call(a,g));');
print_out('i&&!n.length&&(l.teardown&&l.teardown.call(a,p,r.handle)!==!1||m.removeEvent(a,o,r.handle),delete k[o])}else for(o in k)m.event.remove(a,o+b[j],c,d,!0);m.isEmptyObject(k)&&(delete r.handle,m._removeData(a,"events"))}},trigger:function(b,c,d,e){var f,g,h,i,k,l,n,o=[d||y],p=j.call(b,"type")?b.type:b,q=j.call(b,"namespace")?b.namespace.split("."):[];if(h=l=d=d||y,3!==d.nodeType&&8!==d.nodeType&&!$.test(p+m.event.triggered)&&(p.indexOf(".")>=0&&(q=p.split("."),p=q.shift(),q.sort()),g=p.indexOf(":")<0&&"on"+p,b=b[m.expando]?b:new m.Event(p,"object"==typeof b&&b),b.isTrigger=e?2:3,b.namespace=q.join("."),b.namespace_re=b.namespace?new RegExp("(^|\\.)"+q.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,b.result=void 0,b.target||(b.target=d),c=null==c?[b]:m.makeArray(c,[b]),k=m.event.special[p]||{},e||!k.trigger||k.trigger.apply(d,c)!==!1)){if(!e&&!k.noBubble&&!m.isWindow(d)){for(i=k.delegateType||p,$.test(i+p)||(h=h.parentNode);h;h=h.parentNode)o.push(h),l=h;l===(d.ownerDocument||y)&&o.push(l.defaultView||l.parentWindow||a)}n=0;while((h=o[n++])&&!b.isPropagationStopped())b.type=n>1?i:k.bindType||p,f=(m._data(h,"events")||{})[b.type]&&m._data(h,"handle"),f&&f.apply(h,c),f=g&&h[g],f&&f.apply&&m.acceptData(h)&&(b.result=f.apply(h,c),b.result===!1&&b.preventDefault());if(b.type=p,!e&&!b.isDefaultPrevented()&&(!k._default||k._default.apply(o.pop(),c)===!1)&&m.acceptData(d)&&g&&d[p]&&!m.isWindow(d)){l=d[g],l&&(d[g]=null),m.event.triggered=p;try{d[p]()}catch(r){}m.event.triggered=void 0,l&&(d[g]=l)}return b.result}},dispatch:function(a){a=m.event.fix(a);');
print_out('var b,c,e,f,g,h=[],i=d.call(arguments),j=(m._data(this,"events")||{})[a.type]||[],k=m.event.special[a.type]||{};if(i[0]=a,a.delegateTarget=this,!k.preDispatch||k.preDispatch.call(this,a)!==!1){h=m.event.handlers.call(this,a,j),b=0;while((f=h[b++])&&!a.isPropagationStopped()){a.currentTarget=f.elem,g=0;while((e=f.handlers[g++])&&!a.isImmediatePropagationStopped())(!a.namespace_re||a.namespace_re.test(e.namespace))&&(a.handleObj=e,a.data=e.data,c=((m.event.special[e.origType]||{}).handle||e.handler).apply(f.elem,i),void 0!==c&&(a.result=c)===!1&&(a.preventDefault(),a.stopPropagation()))}return k.postDispatch&&k.postDispatch.call(this,a),a.result}},handlers:function(a,b){var c,d,e,f,g=[],h=b.delegateCount,i=a.target;if(h&&i.nodeType&&(!a.button||"click"!==a.type))for(;i!=this;i=i.parentNode||this)if(1===i.nodeType&&(i.disabled!==!0||"click"!==a.type)){for(e=[],f=0;h>f;f++)d=b[f],c=d.selector+" ",void 0===e[c]&&(e[c]=d.needsContext?m(c,this).index(i)>=0:m.find(c,this,null,[i]).length),e[c]&&e.push(d);e.length&&g.push({elem:i,handlers:e})}return h<b.length&&g.push({elem:this,handlers:b.slice(h)}),g},fix:function(a){if(a[m.expando])return a;var b,c,d,e=a.type,f=a,g=this.fixHooks[e];g||(this.fixHooks[e]=g=Z.test(e)?this.mouseHooks:Y.test(e)?this.keyHooks:{}),d=g.props?this.props.concat(g.props):this.props,a=new m.Event(f),b=d.length;while(b--)c=d[b],a[c]=f[c];return a.target||(a.target=f.srcElement||y),3===a.target.nodeType&&(a.target=a.target.parentNode),a.metaKey=!!a.metaKey,g.filter?g.filter(a,f):a},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){return null==a.which&&(a.which=null!=b.charCode?b.charCode:b.keyCode),a}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,b){var c,d,e,f=b.button,g=b.fromElement;');
print_out('return null==a.pageX&&null!=b.clientX&&(d=a.target.ownerDocument||y,e=d.documentElement,c=d.body,a.pageX=b.clientX+(e&&e.scrollLeft||c&&c.scrollLeft||0)-(e&&e.clientLeft||c&&c.clientLeft||0),a.pageY=b.clientY+(e&&e.scrollTop||c&&c.scrollTop||0)-(e&&e.clientTop||c&&c.clientTop||0)),!a.relatedTarget&&g&&(a.relatedTarget=g===a.target?b.toElement:g),a.which||void 0===f||(a.which=1&f?1:2&f?3:4&f?2:0),a}},special:{load:{noBubble:!0},focus:{trigger:function(){if(this!==cb()&&this.focus)try{return this.focus(),!1}catch(a){}},delegateType:"focusin"},blur:{trigger:function(){return this===cb()&&this.blur?(this.blur(),!1):void 0},delegateType:"focusout"},click:{trigger:function(){return m.nodeName(this,"input")&&"checkbox"===this.type&&this.click?(this.click(),!1):void 0},_default:function(a){return m.nodeName(a.target,"a")}},beforeunload:{postDispatch:function(a){void 0!==a.result&&a.originalEvent&&(a.originalEvent.returnValue=a.result)}}},simulate:function(a,b,c,d){var e=m.extend(new m.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?m.event.trigger(e,null,b):m.event.dispatch.call(b,e),e.isDefaultPrevented()&&c.preventDefault()}},m.removeEvent=y.removeEventListener?function(a,b,c){a.removeEventListener&&a.removeEventListener(b,c,!1)}:function(a,b,c){var d="on"+b;a.detachEvent&&(typeof a[d]===K&&(a[d]=null),a.detachEvent(d,c))},m.Event=function(a,b){return this instanceof m.Event?(a&&a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||void 0===a.defaultPrevented&&a.returnValue===!1?ab:bb):this.type=a,b&&m.extend(this,b),this.timeStamp=a&&a.timeStamp||m.now(),void(this[m.expando]=!0)):new m.Event(a,b)},m.Event.prototype={isDefaultPrevented:bb,isPropagationStopped:bb,isImmediatePropagationStopped:bb,preventDefault:function(){var a=this.originalEvent;this.isDefaultPrevented=ab,a&&(a.preventDefault?a.preventDefault():a.returnValue=!1)},stopPropagation:function(){var a=this.originalEvent;this.isPropagationStopped=ab,a&&(a.stopPropagation&&a.stopPropagation(),a.cancelBubble=!0)},stopImmediatePropagation:function(){var a=this.originalEvent;');
print_out('this.isImmediatePropagationStopped=ab,a&&a.stopImmediatePropagation&&a.stopImmediatePropagation(),this.stopPropagation()}},m.each({mouseenter:"mouseover",mouseleave:"mouseout",pointerenter:"pointerover",pointerleave:"pointerout"},function(a,b){m.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c,d=this,e=a.relatedTarget,f=a.handleObj;return(!e||e!==d&&!m.contains(d,e))&&(a.type=f.origType,c=f.handler.apply(this,arguments),a.type=b),c}}}),k.submitBubbles||(m.event.special.submit={setup:function(){return m.nodeName(this,"form")?!1:void m.event.add(this,"click._submit keypress._submit",function(a){var b=a.target,c=m.nodeName(b,"input")||m.nodeName(b,"button")?b.form:void 0;c&&!m._data(c,"submitBubbles")&&(m.event.add(c,"submit._submit",function(a){a._submit_bubble=!0}),m._data(c,"submitBubbles",!0))})},postDispatch:function(a){a._submit_bubble&&(delete a._submit_bubble,this.parentNode&&!a.isTrigger&&m.event.simulate("submit",this.parentNode,a,!0))},teardown:');
print_out('function(){return m.nodeName(this,"form")?!1:void m.event.remove(this,"._submit")}}),k.changeBubbles||(m.event.special.change={setup:function(){return X.test(this.nodeName)?(("checkbox"===this.type||"radio"===this.type)&&(m.event.add(this,"propertychange._change",function(a){"checked"===a.originalEvent.propertyName&&(this._just_changed=!0)}),m.event.add(this,"click._change",function(a){this._just_changed&&!a.isTrigger&&(this._just_changed=!1),m.event.simulate("change",this,a,!0)})),!1):void m.event.add(this,"beforeactivate._change",function(a){var b=a.target;X.test(b.nodeName)&&!m._data(b,"changeBubbles")&&(m.event.add(b,"change._change",function(a){!this.parentNode||a.isSimulated||a.isTrigger||m.event.simulate("change",this.parentNode,a,!0)}),m._data(b,"changeBubbles",!0))})},handle:function(a){var b=a.target;return this!==b||a.isSimulated||a.isTrigger||"radio"!==b.type&&"checkbox"!==b.type?a.handleObj.handler.apply(this,arguments):void 0},teardown:function(){return m.event.remove(this,"._change"),!X.test(this.nodeName)}}),k.focusinBubbles||m.each({focus:"focusin",blur:"focusout"},function(a,b){var c=function(a){m.event.simulate(b,a.target,m.event.fix(a),!0)};');
print_out('m.event.special[b]={setup:function(){var d=this.ownerDocument||this,e=m._data(d,b);e||d.addEventListener(a,c,!0),m._data(d,b,(e||0)+1)},teardown:function(){var d=this.ownerDocument||this,e=m._data(d,b)-1;e?m._data(d,b,e):(d.removeEventListener(a,c,!0),m._removeData(d,b))}}}),m.fn.extend({on:function(a,b,c,d,e){var f,g;if("object"==typeof a){"string"!=typeof b&&(c=c||b,b=void 0);for(f in a)this.on(f,b,c,a[f],e);return this}if(null==c&&null==d?(d=b,c=b=void 0):null==d&&("string"==typeof b?(d=c,c=void 0):(d=c,c=b,b=void 0)),d===!1)d=bb;else if(!d)return this;return 1===e&&(g=d,d=function(a){return m().off(a),g.apply(this,arguments)},d.guid=g.guid||(g.guid=m.guid++)),this.each(function(){m.event.add(this,a,d,c,b)})},one:function(a,b,c,d){return this.on(a,b,c,d,1)},off:function(a,b,c){var d,e;if(a&&a.preventDefault&&a.handleObj)return d=a.handleObj,m(a.delegateTarget).off(d.namespace?d.origType+"."+d.namespace:d.origType,d.selector,d.handler),this;if("object"==typeof a){for(e in a)this.off(e,b,a[e]);');
print_out('return this}return(b===!1||"function"==typeof b)&&(c=b,b=void 0),c===!1&&(c=bb),this.each(function(){m.event.remove(this,a,c,b)})},trigger:function(a,b){return this.each(function(){m.event.trigger(a,b,this)})},triggerHandler:function(a,b){var c=this[0];return c?m.event.trigger(a,b,c,!0):void 0}});function db(a){var b=eb.split("|"),c=a.createDocumentFragment();if(c.createElement)while(b.length)c.createElement(b.pop());return c}var eb="abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",fb=/ jQuery\d+="(?:null|\d+)"/g,gb=new RegExp("<(?:"+eb+")[\\s/>]","i"),hb=/^\s+/,ib=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,jb=/<([\w:]+)/,kb=/<tbody/i,lb=/<|&#?\w+;/,mb=/<(?:script|style|link)/i,nb=/checked\s*(?:[^=]|=\s*.checked.)/i,ob=/^$|\/(?:java|ecma)script/i,pb=/^true\/(.*)/,qb=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,rb={option:[1,"<select multiple=''multiple''>","</select>"],legend:[1,"<fieldset>","</fieldset>"],area:[1,"<map>","</map>"],param:[1,"<object>","</object>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:k.htmlSerialize?[0,"",""]:[1,"X<div>","</div>"]},sb=db(y),tb=sb.appendChild(y.createElement("div"));rb.optgroup=rb.option,rb.tbody=rb.tfoot=rb.colgroup=rb.caption=rb.thead,rb.th=rb.td;function ub(a,b){var c,d,e=0,f=typeof a.getElementsByTagName!==K?a.getElementsByTagName(b||"*"):typeof a.querySelectorAll!==K?a.querySelectorAll(b||"*"):void 0;if(!f)for(f=[],c=a.childNodes||a;null!=(d=c[e]);');
print_out('e++)!b||m.nodeName(d,b)?f.push(d):m.merge(f,ub(d,b));return void 0===b||b&&m.nodeName(a,b)?m.merge([a],f):f}function vb(a){W.test(a.type)&&(a.defaultChecked=a.checked)}function wb(a,b){return m.nodeName(a,"table")&&m.nodeName(11!==b.nodeType?b:b.firstChild,"tr")?a.getElementsByTagName("tbody")[0]||a.appendChild(a.ownerDocument.createElement("tbody")):a}function xb(a){return a.type=(null!==m.find.attr(a,"type"))+"/"+a.type,a}function yb(a){var b=pb.exec(a.type);return b?a.type=b[1]:a.removeAttribute("type"),a}function zb(a,b){for(var c,d=0;null!=(c=a[d]);d++)m._data(c,"globalEval",!b||m._data(b[d],"globalEval"))}function Ab(a,b){if(1===b.nodeType&&m.hasData(a)){var c,d,e,f=m._data(a),g=m._data(b,f),h=f.events;if(h){delete g.handle,g.events={};for(c in h)for(d=0,e=h[c].length;e>d;d++)m.event.add(b,c,h[c][d])}g.data&&(g.data=m.extend({},g.data))}}function Bb(a,b){var c,d,e;if(1===b.nodeType){if(c=b.nodeName.toLowerCase(),!k.noCloneEvent&&b[m.expando]){e=m._data(b);for(d in e.events)m.removeEvent(b,d,e.handle);b.removeAttribute(m.expando)}"script"===c&&b.text!==a.text?(xb(b).text=a.text,yb(b)):"object"===c?(b.parentNode&&(b.outerHTML=a.outerHTML),k.html5Clone&&a.innerHTML&&!m.trim(b.innerHTML)&&(b.innerHTML=a.innerHTML)):"input"===c&&W.test(a.type)?(b.defaultChecked=b.checked=a.checked,b.value!==a.value&&(b.value=a.value)):"option"===c?b.defaultSelected=b.selected=a.defaultSelected:("input"===c||"textarea"===c)&&(b.defaultValue=a.defaultValue)}}');
print_out('m.extend({clone:function(a,b,c){var d,e,f,g,h,i=m.contains(a.ownerDocument,a);if(k.html5Clone||m.isXMLDoc(a)||!gb.test("<"+a.nodeName+">")?f=a.cloneNode(!0):(tb.innerHTML=a.outerHTML,tb.removeChild(f=tb.firstChild)),!(k.noCloneEvent&&k.noCloneChecked||1!==a.nodeType&&11!==a.nodeType||m.isXMLDoc(a)))for(d=ub(f),h=ub(a),g=0;null!=(e=h[g]);++g)d[g]&&Bb(e,d[g]);if(b)if(c)for(h=h||ub(a),d=d||ub(f),g=0;null!=(e=h[g]);g++)Ab(e,d[g]);else Ab(a,f);return d=ub(f,"script"),d.length>0&&zb(d,!i&&ub(a,"script")),d=h=e=null,f},buildFragment:function(a,b,c,d){for(var e,f,g,h,i,j,l,n=a.length,o=db(b),p=[],q=0;n>q;q++)if(f=a[q],f||0===f)if("object"===m.type(f))m.merge(p,f.nodeType?[f]:f);else if(lb.test(f)){h=h||o.appendChild(b.createElement("div")),i=(jb.exec(f)||["",""])[1].toLowerCase(),l=rb[i]||rb._default,h.innerHTML=l[1]+f.replace(ib,"<$1></$2>")+l[2],e=l[0];while(e--)h=h.lastChild;if(!k.leadingWhitespace&&hb.test(f)&&p.push(b.createTextNode(hb.exec(f)[0])),!k.tbody){f="table"!==i||kb.test(f)?"<table>"!==l[1]||kb.test(f)?0:h:h.firstChild,e=f&&f.childNodes.length;while(e--)m.nodeName(j=f.childNodes[e],"tbody")&&!j.childNodes.length&&f.removeChild(j)}m.merge(p,h.childNodes),h.textContent="";while(h.firstChild)h.removeChild(h.firstChild);h=o.lastChild}else p.push(b.createTextNode(f));');
print_out('h&&o.removeChild(h),k.appendChecked||m.grep(ub(p,"input"),vb),q=0;while(f=p[q++])if((!d||-1===m.inArray(f,d))&&(g=m.contains(f.ownerDocument,f),h=ub(o.appendChild(f),"script"),g&&zb(h),c)){e=0;while(f=h[e++])ob.test(f.type||"")&&c.push(f)}return h=null,o},cleanData:function(a,b){for(var d,e,f,g,h=0,i=m.expando,j=m.cache,l=k.deleteExpando,n=m.event.special;null!=(d=a[h]);h++)if((b||m.acceptData(d))&&(f=d[i],g=f&&j[f])){if(g.events)for(e in g.events)n[e]?m.event.remove(d,e):m.removeEvent(d,e,g.handle);j[f]&&(delete j[f],l?delete d[i]:typeof d.removeAttribute!==K?d.removeAttribute(i):d[i]=null,c.push(f))}}}),m.fn.extend({text:function(a){return V(this,function(a){return void 0===a?m.text(this):this.empty().append((this[0]&&this[0].ownerDocument||y).createTextNode(a))},null,a,arguments.length)},append:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wb(this,a);b.appendChild(a)}})},prepend:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wb(this,a);b.insertBefore(a,b.firstChild)}})},before:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this)})},after:function(){return this.domManip(arguments,');
print_out('function(a){this.parentNode&&this.parentNode.insertBefore(a,this.nextSibling)})},remove:function(a,b){for(var c,d=a?m.filter(a,this):this,e=0;null!=(c=d[e]);e++)b||1!==c.nodeType||m.cleanData(ub(c)),c.parentNode&&(b&&m.contains(c.ownerDocument,c)&&zb(ub(c,"script")),c.parentNode.removeChild(c));return this},empty:function(){for(var a,b=0;null!=(a=this[b]);b++){1===a.nodeType&&m.cleanData(ub(a,!1));while(a.firstChild)a.removeChild(a.firstChild);a.options&&m.nodeName(a,"select")&&(a.options.length=0)}return this},clone:function(a,b){return a=null==a?!1:a,b=null==b?a:b,this.map(function(){return m.clone(this,a,b)})},html:function(a){return V(this,function(a){var b=this[0]||{},c=0,d=this.length;if(void 0===a)return 1===b.nodeType?b.innerHTML.replace(fb,""):void 0;if(!("string"!=typeof a||mb.test(a)||!k.htmlSerialize&&gb.test(a)||!k.leadingWhitespace&&hb.test(a)||rb[(jb.exec(a)||["",""])[1].toLowerCase()])){a=a.replace(ib,"<$1></$2>");try{for(;d>c;c++)b=this[c]||{},1===b.nodeType&&(m.cleanData(ub(b,!1)),b.innerHTML=a);b=0}catch(e){}}b&&this.empty().append(a)},null,a,arguments.length)},replaceWith:function(){var a=arguments[0];');
print_out('return this.domManip(arguments,function(b){a=this.parentNode,m.cleanData(ub(this)),a&&a.replaceChild(b,this)}),a&&(a.length||a.nodeType)?this:this.remove()},detach:function(a){return this.remove(a,!0)},domManip:function(a,b){a=e.apply([],a);var c,d,f,g,h,i,j=0,l=this.length,n=this,o=l-1,p=a[0],q=m.isFunction(p);if(q||l>1&&"string"==typeof p&&!k.checkClone&&nb.test(p))return this.each(function(c){var d=n.eq(c);q&&(a[0]=p.call(this,c,d.html())),d.domManip(a,b)});if(l&&(i=m.buildFragment(a,this[0].ownerDocument,!1,this),c=i.firstChild,1===i.childNodes.length&&(i=c),c)){for(g=m.map(ub(i,"script"),xb),f=g.length;l>j;j++)d=i,j!==o&&(d=m.clone(d,!0,!0),f&&m.merge(g,ub(d,"script"))),b.call(this[j],d,j);if(f)for(h=g[g.length-1].ownerDocument,m.map(g,yb),j=0;f>j;j++)d=g[j],ob.test(d.type||"")&&!m._data(d,"globalEval")&&m.contains(h,d)&&(d.src?m._evalUrl&&m._evalUrl(d.src):m.globalEval((d.text||d.textContent||d.innerHTML||"").replace(qb,"")));i=c=null}return this}}),m.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){m.fn[a]=function(a){for(var c,d=0,e=[],g=m(a),h=g.length-1;h>=d;d++)c=d===h?this:this.clone(!0),m(g[d])[b](c),f.apply(e,c.get());return this.pushStack(e)}});var Cb,Db={};');
print_out('function Eb(b,c){var d,e=m(c.createElement(b)).appendTo(c.body),f=a.getDefaultComputedStyle&&(d=a.getDefaultComputedStyle(e[0]))?d.display:m.css(e[0],"display");return e.detach(),f}function Fb(a){var b=y,c=Db[a];return c||(c=Eb(a,b),"none"!==c&&c||(Cb=(Cb||m("<iframe frameborder=''0'' width=''0'' height=''0''/>")).appendTo(b.documentElement),b=(Cb[0].contentWindow||Cb[0].contentDocument).document,b.write(),b.close(),c=Eb(a,b),Cb.detach()),Db[a]=c),c}!function(){var a;k.shrinkWrapBlocks=function(){if(null!=a)return a;a=!1;var b,c,d;return c=y.getElementsByTagName("body")[0],c&&c.style?(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:1px;width:1px;zoom:1",b.appendChild(y.createElement("div")).style.width="5px",a=3!==b.offsetWidth),c.removeChild(d),a):void 0}}();');
print_out('var Gb=/^margin/,Hb=new RegExp("^("+S+")(?!px)[a-z%]+$","i"),Ib,Jb,Kb=/^(top|right|bottom|left)$/;a.getComputedStyle?(Ib=function(a){return a.ownerDocument.defaultView.getComputedStyle(a,null)},Jb=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ib(a),g=c?c.getPropertyValue(b)||c[b]:void 0,c&&(""!==g||m.contains(a.ownerDocument,a)||(g=m.style(a,b)),Hb.test(g)&&Gb.test(b)&&(d=h.width,e=h.minWidth,f=h.maxWidth,h.minWidth=h.maxWidth=h.width=g,g=c.width,h.width=d,h.minWidth=e,h.maxWidth=f)),void 0===g?g:g+""}):y.documentElement.currentStyle&&(Ib=function(a){return a.currentStyle},Jb=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ib(a),g=c?c[b]:void 0,null==g&&h&&h[b]&&(g=h[b]),Hb.test(g)&&!Kb.test(b)&&(d=h.left,e=a.runtimeStyle,f=e&&e.left,f&&(e.left=a.currentStyle.left),h.left="fontSize"===b?"1em":g,g=h.pixelLeft+"px",h.left=d,f&&(e.left=f)),void 0===g?g:g+""||"auto"});function Lb(a,b){return{get:');
print_out('function(){var c=a();if(null!=c)return c?void delete this.get:(this.get=b).apply(this,arguments)}}}!function(){var b,c,d,e,f,g,h;if(b=y.createElement("div"),b.innerHTML="  <link/><table></table><a href=''/a''>a</a><input type=''checkbox''/>",d=b.getElementsByTagName("a")[0],c=d&&d.style){c.cssText="float:left;opacity:.5",k.opacity="0.5"===c.opacity,k.cssFloat=!!c.cssFloat,b.style.backgroundClip="content-box",b.cloneNode(!0).style.backgroundClip="",k.clearCloneStyle="content-box"===b.style.backgroundClip,k.boxSizing=""===c.boxSizing||""===c.MozBoxSizing||""===c.WebkitBoxSizing,m.extend(k,{reliableHiddenOffsets:function(){return null==g&&i(),g},boxSizingReliable:function(){return null==f&&i(),f},pixelPosition:function(){return null==e&&i(),e},reliableMarginRight:function(){return null==h&&i(),h}});function i(){var b,c,d,i;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),b.style.cssText="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;display:block;margin-top:1%;top:1%;border:1px;padding:1px;width:4px;position:absolute",e=f=!1,h=!0,a.getComputedStyle&&(e="1%"!==(a.getComputedStyle(b,null)||{}).top,f="4px"===(a.getComputedStyle(b,null)||{width:"4px"}).width,i=b.appendChild(y.createElement("div")),i.style.cssText=b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:0",i.style.marginRight=i.style.width="0",b.style.width="1px",h=!parseFloat((a.getComputedStyle(i,null)||{}).marginRight)),b.innerHTML="<table><tr><td></td><td>t</td></tr></table>",i=b.getElementsByTagName("td"),i[0].style.cssText="margin:0;border:0;padding:0;display:none",g=0===i[0].offsetHeight,g&&(i[0].style.display="",i[1].style.display="none",g=0===i[0].offsetHeight),c.removeChild(d))}}}(),m.swap=function(a,b,c,d){var e,f,g={};for(f in b)g[f]=a.style[f],a.style[f]=b[f];e=c.apply(a,d||[]);for(f in b)a.style[f]=g[f];return e};var Mb=/alpha\([^)]*\)/i,Nb=/opacity\s*=\s*([^)]*)/,Ob=/^(none|table(?!-c[ea]).+)/,Pb=new RegExp("^("+S+")(.*)$","i"),Qb=new RegExp("^([+-])=("+S+")","i"),Rb={position:"absolute",visibility:"hidden",display:"block"},Sb={letterSpacing:"0",fontWeight:"400"},Tb=["Webkit","O","Moz","ms"];function Ub(a,b){if(b in a)return b;var c=b.charAt(0).');
print_out('toUpperCase()+b.slice(1),d=b,e=Tb.length;while(e--)if(b=Tb[e]+c,b in a)return b;return d}function Vb(a,b){for(var c,d,e,f=[],g=0,h=a.length;h>g;g++)d=a[g],d.style&&(f[g]=m._data(d,"olddisplay"),c=d.style.display,b?(f[g]||"none"!==c||(d.style.display=""),""===d.style.display&&U(d)&&(f[g]=m._data(d,"olddisplay",Fb(d.nodeName)))):(e=U(d),(c&&"none"!==c||!e)&&m._data(d,"olddisplay",e?c:m.css(d,"display"))));for(g=0;h>g;g++)d=a[g],d.style&&(b&&"none"!==d.style.display&&""!==d.style.display||(d.style.display=b?f[g]||"":"none"));return a}function Wb(a,b,c){var d=Pb.exec(b);return d?Math.max(0,d[1]-(c||0))+(d[2]||"px"):b}function Xb(a,b,c,d,e){for(var f=c===(d?"border":"content")?4:"width"===b?1:0,g=0;4>f;f+=2)"margin"===c&&(g+=m.css(a,c+T[f],!0,e)),d?("content"===c&&(g-=m.css(a,"padding"+T[f],!0,e)),"margin"!==c&&(g-=m.css(a,"border"+T[f]+"Width",!0,e))):(g+=m.css(a,"padding"+T[f],!0,e),"padding"!==c&&(g+=m.css(a,"border"+T[f]+"Width",!0,e)));return g}function Yb(a,b,c){var d=!0,e="width"===b?a.offsetWidth:a.offsetHeight,f=Ib(a),g=k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,f);if(0>=e||null==e){if(e=Jb(a,b,f),(0>e||null==e)&&(e=a.style[b]),Hb.test(e))return e;d=g&&(k.boxSizingReliable()||e===a.style[b]),e=parseFloat(e)||0}return e+Xb(a,b,c||(g?"border":"content"),d,f)+"px"}m.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=Jb(a,"opacity");return""===c?"1":c}}}},cssNumber:{columnCount:!0,fillOpacity:!0,flexGrow:!0,flexShrink:!0,fontWeight:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":k.cssFloat?"cssFloat":"styleFloat"},style:function(a,b,c,d){if(a&&3!==a.nodeType&&8!==a.nodeType&&a.style){var e,f,g,h=m.camelCase(b),i=a.style;');
print_out('if(b=m.cssProps[h]||(m.cssProps[h]=Ub(i,h)),g=m.cssHooks[b]||m.cssHooks[h],void 0===c)return g&&"get"in g&&void 0!==(e=g.get(a,!1,d))?e:i[b];if(f=typeof c,"string"===f&&(e=Qb.exec(c))&&(c=(e[1]+1)*e[2]+parseFloat(m.css(a,b)),f="number"),null!=c&&c===c&&("number"!==f||m.cssNumber[h]||(c+="px"),k.clearCloneStyle||""!==c||0!==b.indexOf("background")||(i[b]="inherit"),!(g&&"set"in g&&void 0===(c=g.set(a,c,d)))))try{i[b]=c}catch(j){}}},css:function(a,b,c,d){var e,f,g,h=m.camelCase(b);return b=m.cssProps[h]||(m.cssProps[h]=Ub(a.style,h)),g=m.cssHooks[b]||m.cssHooks[h],g&&"get"in g&&(f=g.get(a,!0,c)),void 0===f&&(f=Jb(a,b,d)),"normal"===f&&b in Sb&&(f=Sb[b]),""===c||c?(e=parseFloat(f),c===!0||m.isNumeric(e)?e||0:f):f}}),m.each(["height","width"],function(a,b){m.cssHooks[b]={get:function(a,c,d){return c?Ob.test(m.css(a,"display"))&&0===a.offsetWidth?m.swap(a,Rb,function(){return Yb(a,b,d)}):Yb(a,b,d):void 0},set:function(a,c,d){var e=d&&Ib(a);return Wb(a,c,d?Xb(a,b,d,k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,e),e):0)}}}),k.opacity||(m.cssHooks.opacity={get:function(a,b){');
print_out('return Nb.test((b&&a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?.01*parseFloat(RegExp.$1)+"":b?"1":""},set:function(a,b){var c=a.style,d=a.currentStyle,e=m.isNumeric(b)?"alpha(opacity="+100*b+")":"",f=d&&d.filter||c.filter||"";c.zoom=1,(b>=1||""===b)&&""===m.trim(f.replace(Mb,""))&&c.removeAttribute&&(c.removeAttribute("filter"),""===b||d&&!d.filter)||(c.filter=Mb.test(f)?f.replace(Mb,e):f+" "+e)}}),m.cssHooks.marginRight=Lb(k.reliableMarginRight,function(a,b){return b?m.swap(a,{display:"inline-block"},Jb,[a,"marginRight"]):void 0}),m.each({margin:"",padding:"",border:"Width"},function(a,b){m.cssHooks[a+b]={expand:function(c){for(var d=0,e={},f="string"==typeof c?c.split(" "):[c];4>d;d++)e[a+T[d]+b]=f[d]||f[d-2]||f[0];return e}},Gb.test(a)||(m.cssHooks[a+b].set=Wb)}),m.fn.extend({css:function(a,b){return V(this,function(a,b,c){var d,e,f={},g=0;if(m.isArray(b)){for(d=Ib(a),e=b.length;e>g;g++)f[b[g]]=m.css(a,b[g],!1,d);return f}return void 0!==c?m.style(a,b,c):m.css(a,b)},a,b,arguments.length>1)},show:function(){return Vb(this,!0)},hide:function(){return Vb(this)},toggle:function(a){return"boolean"==typeof a?a?this.show():this.hide():this.each(function(){U(this)?m(this).show():m(this).hide()})}});function Zb(a,b,c,d,e){return new Zb.prototype.init(a,b,c,d,e)}m.Tween=Zb,Zb.prototype={constructor:Zb,init:function(a,b,c,d,e,f){this.elem=a,this.prop=c,this.easing=e||"swing",this.options=b,this.start=this.now=this.cur(),this.end=d,this.unit=f||(m.cssNumber[c]?"":"px")');
print_out('},cur:function(){var a=Zb.propHooks[this.prop];return a&&a.get?a.get(this):Zb.propHooks._default.get(this)},run:function(a){var b,c=Zb.propHooks[this.prop];return this.pos=b=this.options.duration?m.easing[this.easing](a,this.options.duration*a,0,1,this.options.duration):a,this.now=(this.end-this.start)*b+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),c&&c.set?c.set(this):Zb.propHooks._default.set(this),this}},Zb.prototype.init.prototype=Zb.prototype,Zb.propHooks={_default:{get:function(a){var b;return null==a.elem[a.prop]||a.elem.style&&null!=a.elem.style[a.prop]?(b=m.css(a.elem,a.prop,""),b&&"auto"!==b?b:0):a.elem[a.prop]},set:function(a){m.fx.step[a.prop]?m.fx.step[a.prop](a):a.elem.style&&(null!=a.elem.style[m.cssProps[a.prop]]||m.cssHooks[a.prop])?m.style(a.elem,a.prop,a.now+a.unit):a.elem[a.prop]=a.now}}},Zb.propHooks.scrollTop=Zb.propHooks.scrollLeft={set:function(a){a.elem.nodeType&&a.elem.parentNode&&(a.elem[a.prop]=a.now)}},m.easing={linear:function(a){return a},swing:function(a){return.5-Math.cos(a*Math.PI)/2}},m.fx=Zb.prototype.init,m.fx.step={};var $b,_b,ac=/^(?:toggle|show|hide)$/,bc=new RegExp("^(?:([+-])=|)("+S+")([a-z%]*)$","i"),cc=/queueHooks$/,dc=[ic],ec={"*":[function(a,b){var c=this.createTween(a,b),d=c.cur(),e=bc.exec(b),f=e&&e[3]||(m.cssNumber[a]?"":"px"),g=(m.cssNumber[a]||"px"!==f&&+d)&&bc.exec(m.css(c.elem,a)),h=1,i=20;if(g&&g[3]!==f){f=f||g[3],e=e||[],g=+d||1;do h=h||".5",g/=h,m.style(c.elem,a,g+f);while(h!==(h=c.cur()/d)&&1!==h&&--i)}return e&&(g=c.start=+g||+d||0,c.unit=f,c.end=e[1]?g+(e[1]+1)*e[2]:+e[2]),c}]};function fc(){return setTimeout(function(){$b=void 0}),$b=m.now()}function gc(a,b){var c,d={height:a},e=0;for(b=b?1:0;4>e;e+=2-b)c=T[e],d["margin"+c]=d["padding"+c]=a;return b&&(d.opacity=d.width=a),d}');
print_out('function hc(a,b,c){for(var d,e=(ec[b]||[]).concat(ec["*"]),f=0,g=e.length;g>f;f++)if(d=e[f].call(c,b,a))return d}function ic(a,b,c){var d,e,f,g,h,i,j,l,n=this,o={},p=a.style,q=a.nodeType&&U(a),r=m._data(a,"fxshow");c.queue||(h=m._queueHooks(a,"fx"),null==h.unqueued&&(h.unqueued=0,i=h.empty.fire,h.empty.fire=function(){h.unqueued||i()}),h.unqueued++,n.always(function(){n.always(function(){h.unqueued--,m.queue(a,"fx").length||h.empty.fire()})})),1===a.nodeType&&("height"in b||"width"in b)&&(c.overflow=[p.overflow,p.overflowX,p.overflowY],j=m.css(a,"display"),l="none"===j?m._data(a,"olddisplay")||Fb(a.nodeName):j,"inline"===l&&"none"===m.css(a,"float")&&(k.inlineBlockNeedsLayout&&"inline"!==Fb(a.nodeName)?p.zoom=1:p.display="inline-block")),c.overflow&&(p.overflow="hidden",k.shrinkWrapBlocks()||n.always(function(){p.overflow=c.overflow[0],p.overflowX=c.overflow[1],p.overflowY=c.overflow[2]}));for(d in b)if(e=b[d],ac.exec(e)){if(delete b[d],f=f||"toggle"===e,e===(q?"hide":"show")){if("show"!==e||!r||void 0===r[d])continue;q=!0}o[d]=r&&r[d]||m.style(a,d)}else j=void 0;if(m.isEmptyObject(o))"inline"===("none"===j?Fb(a.nodeName):j)&&(p.display=j);else{r?"hidden"in r&&(q=r.hidden):r=m._data(a,"fxshow",{}),f&&(r.hidden=!q),q?m(a).show():n.done(function(){m(a).hide()}),n.done(function(){var b;m._removeData(a,"fxshow");for(b in o)m.style(a,b,o[b])});for(d in o)g=hc(q?r[d]:0,d,n),d in r||(r[d]=g.start,q&&(g.end=g.start,g.start="width"===d||"height"===d?1:0))}}function jc(a,b){var c,d,e,f,g;for(c in a)if(d=m.camelCase(c),e=b[d],f=a[c],m.isArray(f)&&(e=f[1],f=a[c]=f[0]),c!==d&&(a[d]=f,delete a[c]),g=m.cssHooks[d],g&&"expand"in g){f=g.expand(f),delete a[d];for(c in f)c in a||(a[c]=f[c],b[c]=e)}else b[d]=e}function kc(a,b,c){var d,e,f=0,g=dc.length,h=m.Deferred().always(function(){delete i.elem}),i=function()');
print_out('{if(e)return!1;for(var b=$b||fc(),c=Math.max(0,j.startTime+j.duration-b),d=c/j.duration||0,f=1-d,g=0,i=j.tweens.length;i>g;g++)j.tweens[g].run(f);return h.notifyWith(a,[j,f,c]),1>f&&i?c:(h.resolveWith(a,[j]),!1)},j=h.promise({elem:a,props:m.extend({},b),opts:m.extend(!0,{specialEasing:{}},c),originalProperties:b,originalOptions:c,startTime:$b||fc(),duration:c.duration,tweens:[],createTween:function(b,c){var d=m.Tween(a,j.opts,b,c,j.opts.specialEasing[b]||j.opts.easing);return j.tweens.push(d),d},stop:function(b){var c=0,d=b?j.tweens.length:0;if(e)return this;for(e=!0;d>c;c++)j.tweens[c].run(1);return b?h.resolveWith(a,[j,b]):h.rejectWith(a,[j,b]),this}}),k=j.props;for(jc(k,j.opts.specialEasing);g>f;f++)if(d=dc[f].call(j,a,k,j.opts))return d;return m.map(k,hc,j),m.isFunction(j.opts.start)&&j.opts.start.call(a,j),m.fx.timer(m.extend(i,{elem:a,anim:j,queue:j.opts.queue})),j.progress(j.opts.progress).done(j.opts.done,j.opts.complete).fail(j.opts.fail).always(j.opts.always)}m.Animation=m.extend(kc,{tweener:function(a,b){m.isFunction(a)?(b=a,a=["*"]):a=a.split(" ");for(var c,d=0,e=a.length;e>d;d++)c=a[d],ec[c]=ec[c]||[],ec[c].unshift(b)},prefilter:function(a,b){b?dc.unshift(a):dc.push(a)}}),m.speed=function(a,b,c){var d=a&&"object"==typeof a?m.extend({},a):{complete:c||!c&&b||m.isFunction(a)&&a,duration:a,easing:c&&b||b&&!m.isFunction(b)&&b};return d.duration=m.fx.off?0:"number"==typeof d.duration?d.duration:d.duration in m.fx.speeds?m.fx.speeds[d.duration]:m.fx.speeds._default,(null==d.queue||d.queue===!0)&&(d.queue="fx"),d.old=d.complete,d.complete=function()');
print_out('{m.isFunction(d.old)&&d.old.call(this),d.queue&&m.dequeue(this,d.queue)},d},m.fn.extend({fadeTo:function(a,b,c,d){return this.filter(U).css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){var e=m.isEmptyObject(a),f=m.speed(b,c,d),g=function(){var b=kc(this,m.extend({},a),f);(e||m._data(this,"finish"))&&b.stop(!0)};return g.finish=g,e||f.queue===!1?this.each(g):this.queue(f.queue,g)},stop:function(a,b,c){var d=function(a){var b=a.stop;delete a.stop,b(c)};return"string"!=typeof a&&(c=b,b=a,a=void 0),b&&a!==!1&&this.queue(a||"fx",[]),this.each(function(){var b=!0,e=null!=a&&a+"queueHooks",f=m.timers,g=m._data(this);if(e)g[e]&&g[e].stop&&d(g[e]);else for(e in g)g[e]&&g[e].stop&&cc.test(e)&&d(g[e]);for(e=f.length;e--;)f[e].elem!==this||null!=a&&f[e].queue!==a||(f[e].anim.stop(c),b=!1,f.splice(e,1));(b||!c)&&m.dequeue(this,a)})},finish:function(a){return a!==!1&&(a=a||"fx"),this.each(function(){var b,c=m._data(this),d=c[a+"queue"],e=c[a+"queueHooks"],f=m.timers,g=d?d.length:0;for(c.finish=!0,m.queue(this,a,[]),e&&e.stop&&e.stop.call(this,!0),b=f.length;b--;)f[b].elem===this&&f[b].queue===a&&(f[b].anim.stop(!0),f.splice(b,1));for(b=0;g>b;b++)d[b]&&d[b].finish&&d[b].finish.call(this);delete c.finish})}}),m.each(["toggle","show","hide"],function(a,b){var c=m.fn[b];m.fn[b]=function(a,d,e){return null==a||"boolean"==typeof a?c.apply(this,arguments):this.animate(gc(b,!0),a,d,e)}}),m.each({slideDown:gc("show"),slideUp:gc("hide"),slideToggle:gc("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){m.fn[a]=');
print_out('function(a,c,d){return this.animate(b,a,c,d)}}),m.timers=[],m.fx.tick=function(){var a,b=m.timers,c=0;for($b=m.now();c<b.length;c++)a=b[c],a()||b[c]!==a||b.splice(c--,1);b.length||m.fx.stop(),$b=void 0},m.fx.timer=function(a){m.timers.push(a),a()?m.fx.start():m.timers.pop()},m.fx.interval=13,m.fx.start=function(){_b||(_b=setInterval(m.fx.tick,m.fx.interval))},m.fx.stop=function(){clearInterval(_b),_b=null},m.fx.speeds={slow:600,fast:200,_default:400},m.fn.delay=function(a,b){return a=m.fx?m.fx.speeds[a]||a:a,b=b||"fx",this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},function(){var a,b,c,d,e;b=y.createElement("div"),b.setAttribute("className","t"),b.innerHTML="  <link/><table></table><a href=''/a''>a</a><input type=''checkbox''/>",d=b.getElementsByTagName("a")[0],c=y.createElement("select"),e=c.appendChild(y.createElement("option")),a=b.getElementsByTagName("input")[0],d.style.cssText="top:1px",k.getSetAttribute="t"!==b.className,k.style=/top/.test(d.getAttribute("style")),k.hrefNormalized="/a"===d.getAttribute("href"),k.checkOn=!!a.value,k.optSelected=e.selected,k.enctype=!!y.createElement("form").enctype,c.disabled=!0,k.optDisabled=!e.disabled,a=y.createElement("input"),a.setAttribute("value",""),k.input=""===a.getAttribute("value"),a.value="t",a.setAttribute("type","radio"),k.radioValue="t"===a.value}();var lc=/\r/g;m.fn.extend({val:function(a){var b,c,d,e=this[0];{if(arguments.length)return d=m.isFunction(a),this.each(function(c){var e;1===this.nodeType&&(e=d?a.call(this,c,m(this).val()):a,null==e?e="":"number"==typeof e?e+="":m.isArray(e)&&(e=m.map(e,function(a){return null==a?"":a+""})),b=m.valHooks[this.type]||m.valHooks[this.nodeName.toLowerCase()],b&&"set"in b&&void 0!==b.set(this,e,"value")||(this.value=e))});if(e)return b=m.valHooks[e.type]||m.valHooks[e.nodeName.toLowerCase()],b&&"get"in b&&void 0!==(c=b.get(e,"value"))?c:(c=e.value,"string"==typeof c?c.replace(lc,""):null==c?"":c)}}}),m.extend({valHooks:{option:{get:');
print_out('function(a){var b=m.find.attr(a,"value");return null!=b?b:m.trim(m.text(a))}},select:{get:function(a){for(var b,c,d=a.options,e=a.selectedIndex,f="select-one"===a.type||0>e,g=f?null:[],h=f?e+1:d.length,i=0>e?h:f?e:0;h>i;i++)if(c=d[i],!(!c.selected&&i!==e||(k.optDisabled?c.disabled:null!==c.getAttribute("disabled"))||c.parentNode.disabled&&m.nodeName(c.parentNode,"optgroup"))){if(b=m(c).val(),f)return b;g.push(b)}return g},set:function(a,b){var c,d,e=a.options,f=m.makeArray(b),g=e.length;while(g--)if(d=e[g],m.inArray(m.valHooks.option.get(d),f)>=0)try{d.selected=c=!0}catch(h){d.scrollHeight}else d.selected=!1;return c||(a.selectedIndex=-1),e}}}}),m.each(["radio","checkbox"],function(){m.valHooks[this]={set:function(a,b){return m.isArray(b)?a.checked=m.inArray(m(a).val(),b)>=0:void 0}},k.checkOn||(m.valHooks[this].get=function(a){return null===a.getAttribute("value")?"on":a.value})});var mc,nc,oc=m.expr.attrHandle,pc=/^(?:checked|selected)$/i,qc=k.getSetAttribute,rc=k.input;m.fn.extend({attr:function(a,b){return V(this,m.attr,a,b,arguments.length>1)},removeAttr:function(a){return this.each(function(){m.removeAttr(this,a)})}}),m.extend({attr:function(a,b,c){var d,e,f=a.nodeType;if(a&&3!==f&&8!==f&&2!==f)return typeof a.getAttribute===K?m.prop(a,b,c):(1===f&&m.isXMLDoc(a)||(b=b.toLowerCase(),d=m.attrHooks[b]||(m.expr.match.bool.test(b)?nc:mc)),void 0===c?d&&"get"in d&&null!==(e=d.get(a,b))?e:(e=m.find.attr(a,b),null==e?void 0:e):null!==c?d&&"set"in d&&void 0!==(e=d.set(a,c,b))?e:(a.setAttribute(b,c+""),c):void m.removeAttr(a,b))},removeAttr:function(a,b){var c,d,e=0,f=b&&b.match(E);if(f&&1===a.nodeType)while(c=f[e++])d=m.propFix[c]||c,m.expr.match.bool.test(c)?rc&&qc||!pc.test(c)?a[d]=!1:a[m.camelCase("default-"+c)]=a[d]=!1:m.attr(a,c,""),a.removeAttribute(qc?c:d)},attrHooks:{type:{set:');
print_out('function(a,b){if(!k.radioValue&&"radio"===b&&m.nodeName(a,"input")){var c=a.value;return a.setAttribute("type",b),c&&(a.value=c),b}}}}}),nc={set:function(a,b,c){return b===!1?m.removeAttr(a,c):rc&&qc||!pc.test(c)?a.setAttribute(!qc&&m.propFix[c]||c,c):a[m.camelCase("default-"+c)]=a[c]=!0,c}},m.each(m.expr.match.bool.source.match(/\w+/g),function(a,b){var c=oc[b]||m.find.attr;oc[b]=rc&&qc||!pc.test(b)?function(a,b,d){var e,f;return d||(f=oc[b],oc[b]=e,e=null!=c(a,b,d)?b.toLowerCase():null,oc[b]=f),e}:function(a,b,c){return c?void 0:a[m.camelCase("default-"+b)]?b.toLowerCase():null}}),rc&&qc||(m.attrHooks.value={set:function(a,b,c){return m.nodeName(a,"input")?void(a.defaultValue=b):mc&&mc.set(a,b,c)}}),qc||(mc={set:function(a,b,c){var d=a.getAttributeNode(c);return d||a.setAttributeNode(d=a.ownerDocument.createAttribute(c)),d.value=b+="","value"===c||b===a.getAttribute(c)?b:void 0}},oc.id=oc.name=oc.coords=function(a,b,c){var d;return c?void 0:(d=a.getAttributeNode(b))&&""!==d.value?d.value:null},m.valHooks.button={get:function(a,b){var c=a.getAttributeNode(b);return c&&c.specified?c.value:void 0},set:mc.set},m.attrHooks.contenteditable={set:function(a,b,c){mc.set(a,""===b?!1:b,c)}},m.each(["width","height"],function(a,b){m.attrHooks[b]={set:function(a,c){return""===c?(a.setAttribute(b,"auto"),c):void 0}}})),k.style||(m.attrHooks.style={get:function(a){return a.style.cssText||void 0},set:function(a,b){return a.style.cssText=b+""}});var sc=/^(?:input|select|textarea|button|object)$/i,tc=/^(?:a|area)$/i;m.fn.extend({prop:function(a,b){return V(this,m.prop,a,b,arguments.length>1)},removeProp:function(a){return a=m.propFix[a]||a,this.each(function(){try{this[a]=void 0,delete this[a]}catch(b){}})}}),m.extend({propFix:{"for":"htmlFor","class":"className"},prop:function(a,b,c){var d,e,f,g=a.nodeType;if(a&&3!==g&&8!==g&&2!==g)return f=1!==g||!m.isXMLDoc(a),f&&(b=m.propFix[b]||b,e=m.propHooks[b]),void 0!==c?e&&"set"in e&&void 0!==(d=e.set(a,c,b))?d:a[b]=c:e&&"get"in e&&null!==(d=e.get(a,b))?d:a[b]},propHooks:{tabIndex:{get:function(a){var b=m.find.attr(a,"tabindex");');
print_out('return b?parseInt(b,10):sc.test(a.nodeName)||tc.test(a.nodeName)&&a.href?0:-1}}}}),k.hrefNormalized||m.each(["href","src"],function(a,b){m.propHooks[b]={get:function(a){return a.getAttribute(b,4)}}}),k.optSelected||(m.propHooks.selected={get:function(a){var b=a.parentNode;return b&&(b.selectedIndex,b.parentNode&&b.parentNode.selectedIndex),null}}),m.each(["tabIndex","readOnly","maxLength","cellSpacing","cellPadding","rowSpan","colSpan","useMap","frameBorder","contentEditable"],function(){m.propFix[this.toLowerCase()]=this}),k.enctype||(m.propFix.enctype="encoding");var uc=/[\t\r\n\f]/g;m.fn.extend({addClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j="string"==typeof a&&a;if(m.isFunction(a))');
print_out('return this.each(function(b){m(this).addClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(uc," "):" ")){f=0;while(e=b[f++])d.indexOf(" "+e+" ")<0&&(d+=e+" ");g=m.trim(d),c.className!==g&&(c.className=g)}return this},removeClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j=0===arguments.length||"string"==typeof a&&a;if(m.isFunction(a))return this.each(function(b){m(this).removeClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(uc," "):"")){f=0;while(e=b[f++])while(d.indexOf(" "+e+" ")>=0)d=d.replace(" "+e+" "," ");g=a?m.trim(d):"",c.className!==g&&(c.className=g)}return this},toggleClass:function(a,b){var c=typeof a;return"boolean"==typeof b&&"string"===c?b?this.addClass(a):this.removeClass(a):this.each(m.isFunction(a)?function(c){m(this).toggleClass(a.call(this,c,this.className,b),b)}:function(){if("string"===c){var b,d=0,e=m(this),f=a.match(E)||[];while(b=f[d++])e.hasClass(b)?e.removeClass(b):e.addClass(b)}else(c===K||"boolean"===c)&&(this.className&&m._data(this,"__className__",this.className),this.className=this.className||a===!1?"":m._data(this,"__className__")||"")})},hasClass:function(a){for(var b=" "+a+" ",c=0,d=this.length;d>c;c++)if(1===this[c].nodeType&&(" "+this[c].className+" ").replace(uc," ").indexOf(b)>=0)return!0;return!1}}),m.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){m.fn[b]=function(a,c){return arguments.length>0?this.on(b,null,a,c):this.trigger(b)}}),m.fn.extend({hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},delegate:');
print_out('function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return 1===arguments.length?this.off(a,"**"):this.off(b,a||"**",c)}});var vc=m.now(),wc=/\?/,xc=/(,)|(\[|{)|(}|])|"(?:[^"\\\r\n]|\\["\\\/bfnrt]|\\u[\da-fA-F]{4})*"\s*:?|true|false|null|-?(?!0\d)\d+(?:\.\d+|)(?:[eE][+-]?\d+|)/g;m.parseJSON=function(b){if(a.JSON&&a.JSON.parse)return a.JSON.parse(b+"");var c,d=null,e=m.trim(b+"");return e&&!m.trim(e.replace(xc,function(a,b,e,f){return c&&b&&(d=0),0===d?a:(c=e||b,d+=!f-!e,"")}))?Function("return "+e)():m.error("Invalid JSON: "+b)},m.parseXML=function(b){var c,d;if(!b||"string"!=typeof b)return null;try{a.DOMParser?(d=new DOMParser,c=d.parseFromString(b,"text/xml")):(c=new ActiveXObject("Microsoft.XMLDOM"),c.async="false",c.loadXML(b))}catch(e){c=void 0}return c&&c.documentElement&&!c.getElementsByTagName("parsererror").length||m.error("Invalid XML: "+b),c};var yc,zc,Ac=/#.*$/,Bc=/([?&])_=[^&]*/,Cc=/^(.*?):[ \t]*([^\r\n]*)\r?$/gm,Dc=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,Ec=/^(?:GET|HEAD)$/,Fc=/^\/\//,Gc=/^([\w.+-]+:)(?:\/\/(?:[^\/?#]*@|)([^\/?#:]*)(?::(\d+)|)|)/,Hc={},Ic={},Jc="*/".concat("*");try{zc=location.href}catch(Kc){zc=y.createElement("a"),zc.href="",zc=zc.href}yc=Gc.exec(zc.toLowerCase())||[];function Lc(a){return function(b,c){"string"!=typeof b&&(c=b,b="*");var d,e=0,f=b.toLowerCase().match(E)||[];if(m.isFunction(c))while(d=f[e++])"+"===d.charAt(0)?(d=d.slice(1)||"*",(a[d]=a[d]||[]).unshift(c)):(a[d]=a[d]||[]).push(c)}}function Mc(a,b,c,d){var e={},f=a===Ic;function g(h){var i;return e[h]=!0,m.each(a[h]||[],function(a,h){var j=h(b,c,d);return"string"!=typeof j||f||e[j]?f?!(i=j):void 0:(b.dataTypes.unshift(j),g(j),!1)}),i}return g(b.dataTypes[0])||!e["*"]&&g("*")}function Nc(a,b){var c,d,e=m.ajaxSettings.flatOptions||{};for(d in b)void 0!==b[d]&&((e[d]?a:c||(c={}))[d]=b[d]);return c&&m.extend(!0,a,c),a}function Oc(a,b,c){var d,e,f,g,h=a.contents,i=a.dataTypes;while("*"===i[0])i.shift(),void 0===e&&(e=a.mimeType||b.getResponseHeader("Content-Type"));');
print_out('if(e)for(g in h)if(h[g]&&h[g].test(e)){i.unshift(g);break}if(i[0]in c)f=i[0];else{for(g in c){if(!i[0]||a.converters[g+" "+i[0]]){f=g;break}d||(d=g)}f=f||d}return f?(f!==i[0]&&i.unshift(f),c[f]):void 0}function Pc(a,b,c,d){var e,f,g,h,i,j={},k=a.dataTypes.slice();if(k[1])for(g in a.converters)j[g.toLowerCase()]=a.converters[g];f=k.shift();while(f)if(a.responseFields[f]&&(c[a.responseFields[f]]=b),!i&&d&&a.dataFilter&&(b=a.dataFilter(b,a.dataType)),i=f,f=k.shift())if("*"===f)f=i;else if("*"!==i&&i!==f){if(g=j[i+" "+f]||j["* "+f],!g)for(e in j)if(h=e.split(" "),h[1]===f&&(g=j[i+" "+h[0]]||j["* "+h[0]])){g===!0?g=j[e]:j[e]!==!0&&(f=h[0],k.unshift(h[1]));break}if(g!==!0)if(g&&a["throws"])b=g(b);else try{b=g(b)}catch(l){return{state:"parsererror",error:g?l:"No conversion from "+i+" to "+f}}}return{state:"success",data:b}}m.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:zc,type:"GET",isLocal:Dc.test(yc[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":Jc,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText",json:"responseJSON"},converters:{"* text":String,"text html":!0,"text json":m.parseJSON,"text xml":m.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(a,b){return b?Nc(Nc(a,m.ajaxSettings),b):Nc(m.ajaxSettings,a)},ajaxPrefilter:Lc(Hc),ajaxTransport:Lc(Ic),ajax:');
print_out('function(a,b){"object"==typeof a&&(b=a,a=void 0),b=b||{};var c,d,e,f,g,h,i,j,k=m.ajaxSetup({},b),l=k.context||k,n=k.context&&(l.nodeType||l.jquery)?m(l):m.event,o=m.Deferred(),p=m.Callbacks("once memory"),q=k.statusCode||{},r={},s={},t=0,u="canceled",v={readyState:0,getResponseHeader:function(a){var b;if(2===t){if(!j){j={};while(b=Cc.exec(f))j[b[1].toLowerCase()]=b[2]}b=j[a.toLowerCase()]}return null==b?null:b},getAllResponseHeaders:function(){return 2===t?f:null},setRequestHeader:function(a,b){var c=a.toLowerCase();return t||(a=s[c]=s[c]||a,r[a]=b),this},overrideMimeType:function(a){return t||(k.mimeType=a),this},statusCode:function(a){var b;if(a)if(2>t)for(b in a)q[b]=[q[b],a[b]];else v.always(a[v.status]);return this},abort:function(a){var b=a||u;return i&&i.abort(b),x(0,b),this}};');
print_out('if(o.promise(v).complete=p.add,v.success=v.done,v.error=v.fail,k.url=((a||k.url||zc)+"").replace(Ac,"").replace(Fc,yc[1]+"//"),k.type=b.method||b.type||k.method||k.type,k.dataTypes=m.trim(k.dataType||"*").toLowerCase().match(E)||[""],null==k.crossDomain&&(c=Gc.exec(k.url.toLowerCase()),k.crossDomain=!(!c||c[1]===yc[1]&&c[2]===yc[2]&&(c[3]||("http:"===c[1]?"80":"443"))===(yc[3]||("http:"===yc[1]?"80":"443")))),k.data&&k.processData&&"string"!=typeof k.data&&(k.data=m.param(k.data,k.traditional)),Mc(Hc,k,b,v),2===t)return v;h=k.global,h&&0===m.active++&&m.event.trigger("ajaxStart"),k.type=k.type.toUpperCase(),k.hasContent=!Ec.test(k.type),e=k.url,k.hasContent||(k.data&&(e=k.url+=(wc.test(e)?"&":"?")+k.data,delete k.data),k.cache===!1&&(k.url=Bc.test(e)?e.replace(Bc,"$1_="+vc++):e+(wc.test(e)?"&":"?")+"_="+vc++)),k.ifModified&&(m.lastModified[e]&&v.setRequestHeader("If-Modified-Since",m.lastModified[e]),m.etag[e]&&v.setRequestHeader("If-None-Match",m.etag[e])),(k.data&&k.hasContent&&k.contentType!==!1||b.contentType)&&v.setRequestHeader("Content-Type",k.contentType),v.setRequestHeader("Accept",k.dataTypes[0]&&k.accepts[k.dataTypes[0]]?k.accepts[k.dataTypes[0]]+("*"!==k.dataTypes[0]?", "+Jc+"; q=0.01":""):k.accepts["*"]);for(d in k.headers)v.setRequestHeader(d,k.headers[d]);if(k.beforeSend&&(k.beforeSend.call(l,v,k)===!1||2===t))return v.abort();u="abort";for(d in{success:1,error:1,complete:1})v[d](k[d]);if(i=Mc(Ic,k,b,v)){v.readyState=1,h&&n.trigger("ajaxSend",[v,k]),k.async&&k.timeout>0&&(g=setTimeout(function(){v.abort("timeout")},k.timeout));try{t=1,i.send(r,x)}catch(w){if(!(2>t))throw w;x(-1,w)}}else x(-1,"No Transport");');
print_out('function x(a,b,c,d){var j,r,s,u,w,x=b;2!==t&&(t=2,g&&clearTimeout(g),i=void 0,f=d||"",v.readyState=a>0?4:0,j=a>=200&&300>a||304===a,c&&(u=Oc(k,v,c)),u=Pc(k,u,v,j),j?(k.ifModified&&(w=v.getResponseHeader("Last-Modified"),w&&(m.lastModified[e]=w),w=v.getResponseHeader("etag"),w&&(m.etag[e]=w)),204===a||"HEAD"===k.type?x="nocontent":304===a?x="notmodified":(x=u.state,r=u.data,s=u.error,j=!s)):(s=x,(a||!x)&&(x="error",0>a&&(a=0))),v.status=a,v.statusText=(b||x)+"",j?o.resolveWith(l,[r,x,v]):o.rejectWith(l,[v,x,s]),v.statusCode(q),q=void 0,h&&n.trigger(j?"ajaxSuccess":"ajaxError",[v,k,j?r:s]),p.fireWith(l,[v,x]),h&&(n.trigger("ajaxComplete",[v,k]),--m.active||m.event.trigger("ajaxStop")))}return v},getJSON:function(a,b,c){return m.get(a,b,c,"json")},getScript:function(a,b){return m.get(a,void 0,b,"script")}}),m.each(["get","post"],function(a,b){m[b]=function(a,c,d,e){return m.isFunction(c)&&(e=e||d,d=c,c=void 0),m.ajax({url:a,type:b,dataType:e,data:c,success:d})}}),m.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(a,b){m.fn[b]=function(a){return this.on(b,a)}}),m._evalUrl=function(a){return m.ajax({url:a,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0})},m.fn.extend({wrapAll:function(a){if(m.isFunction(a))return this.each(function(b){m(this).wrapAll(a.call(this,b))});if(this[0]){var b=m(a,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&&b.insertBefore(this[0]),b.map(function(){var a=this;');
print_out('while(a.firstChild&&1===a.firstChild.nodeType)a=a.firstChild;return a}).append(this)}return this},wrapInner:function(a){return this.each(m.isFunction(a)?function(b){m(this).wrapInner(a.call(this,b))}:function(){var b=m(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=m.isFunction(a);return this.each(function(c){m(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){m.nodeName(this,"body")||m(this).replaceWith(this.childNodes)}).end()}}),m.expr.filters.hidden=function(a){return a.offsetWidth<=0&&a.offsetHeight<=0||!k.reliableHiddenOffsets()&&"none"===(a.style&&a.style.display||m.css(a,"display"))},m.expr.filters.visible=function(a){return!m.expr.filters.hidden(a)};var Qc=/%20/g,Rc=/\[\]$/,Sc=/\r?\n/g,Tc=/^(?:submit|button|image|reset|file)$/i,Uc=/^(?:input|select|textarea|keygen)/i;function Vc(a,b,c,d){var e;if(m.isArray(b))m.each(b,function(b,e){c||Rc.test(a)?d(a,e):Vc(a+"["+("object"==typeof e?b:"")+"]",e,c,d)});else if(c||"object"!==m.type(b))d(a,b);else for(e in b)Vc(a+"["+e+"]",b[e],c,d)}m.param=function(a,b){var c,d=[],e=function(a,b){b=m.isFunction(b)?b():null==b?"":b,d[d.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};if(void 0===b&&(b=m.ajaxSettings&&m.ajaxSettings.traditional),m.isArray(a)||a.jquery&&!m.isPlainObject(a))m.each(a,function(){e(this.name,this.value)});else for(c in a)Vc(c,a[c],b,e);return d.join("&").replace(Qc,"+")},m.fn.extend({serialize:function(){return m.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var a=m.prop(this,"elements");return a?m.makeArray(a):this}).filter(function(){var a=this.type;return this.name&&!m(this).is(":disabled")&&Uc.test(this.nodeName)&&!Tc.test(a)&&(this.checked||!W.test(a))}).map(function(a,b){var c=m(this).val();return null==c?null:m.isArray(c)?m.map(c,');
print_out('function(a){return{name:b.name,value:a.replace(Sc,"\r\n")}}):{name:b.name,value:c.replace(Sc,"\r\n")}}).get()}}),m.ajaxSettings.xhr=void 0!==a.ActiveXObject?function(){return!this.isLocal&&/^(get|post|head|put|delete|options)$/i.test(this.type)&&Zc()||$c()}:Zc;var Wc=0,Xc={},Yc=m.ajaxSettings.xhr();a.ActiveXObject&&m(a).on("unload",function(){for(var a in Xc)Xc[a](void 0,!0)}),k.cors=!!Yc&&"withCredentials"in Yc,Yc=k.ajax=!!Yc,Yc&&m.ajaxTransport(function(a){if(!a.crossDomain||k.cors){var b;return{send:function(c,d){var e,f=a.xhr(),g=++Wc;if(f.open(a.type,a.url,a.async,a.username,a.password),a.xhrFields)for(e in a.xhrFields)f[e]=a.xhrFields[e];a.mimeType&&f.overrideMimeType&&f.overrideMimeType(a.mimeType),a.crossDomain||c["X-Requested-With"]||(c["X-Requested-With"]="XMLHttpRequest");for(e in c)void 0!==c[e]&&f.setRequestHeader(e,c[e]+"");f.send(a.hasContent&&a.data||null),b=function(c,e){var h,i,j;if(b&&(e||4===f.readyState))if(delete Xc[g],b=void 0,f.onreadystatechange=m.noop,e)4!==f.readyState&&f.abort();else{j={},h=f.status,"string"==typeof f.responseText&&(j.text=f.responseText);try{i=f.statusText}catch(k){i=""}h||!a.isLocal||a.crossDomain?1223===h&&(h=204):h=j.text?200:404}j&&d(h,i,j,f.getAllResponseHeaders())},a.async?4===f.readyState?setTimeout(b):f.onreadystatechange=Xc[g]=b:b()},abort:function(){b&&b(void 0,!0)}}}});');
print_out('function Zc(){try{return new a.XMLHttpRequest}catch(b){}}function $c(){try{return new a.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}}m.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(a){return m.globalEval(a),a}}}),m.ajaxPrefilter("script",function(a){void 0===a.cache&&(a.cache=!1),a.crossDomain&&(a.type="GET",a.global=!1)}),m.ajaxTransport("script",function(a){if(a.crossDomain){var b,c=y.head||m("head")[0]||y.documentElement;return{send:function(d,e){b=y.createElement("script"),b.async=!0,a.scriptCharset&&(b.charset=a.scriptCharset),b.src=a.url,b.onload=b.onreadystatechange=function(a,c){(c||!b.readyState||/loaded|complete/.test(b.readyState))&&(b.onload=b.onreadystatechange=null,b.parentNode&&b.parentNode.removeChild(b),b=null,c||e(200,"success"))},c.insertBefore(b,c.firstChild)},abort:function(){b&&b.onload(void 0,!0)}}}});var _c=[],ad=/(=)\?(?=&|$)|\?\?/;m.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var a=_c.pop()||m.expando+"_"+vc++;return this[a]=!0,a}}),m.ajaxPrefilter("json jsonp",function(b,c,d){var e,f,g,h=b.jsonp!==!1&&(ad.test(b.url)?"url":"string"==typeof b.data&&!(b.contentType||"").indexOf("application/x-www-form-urlencoded")&&ad.test(b.data)&&"data");return h||"jsonp"===b.dataTypes[0]?(e=b.jsonpCallback=m.isFunction(b.jsonpCallback)?b.jsonpCallback():b.jsonpCallback,h?b[h]=b[h].replace(ad,"$1"+e):b.jsonp!==!1&&(b.url+=(wc.test(b.url)?"&":"?")+b.jsonp+"="+e),b.converters["script json"]=function(){return g||m.error(e+" was not called"),g[0]},b.dataTypes[0]="json",f=a[e],a[e]=function(){g=arguments},d.always(function(){a[e]=f,b[e]&&(b.jsonpCallback=c.jsonpCallback,_c.push(e)),g&&m.isFunction(f)&&f(g[0]),g=f=void 0}),"script"):void 0}),m.parseHTML=function(a,b,c){if(!a||"string"!=typeof a)return null;"boolean"==typeof b&&(c=b,b=!1),b=b||y;var d=u.exec(a),e=!c&&[];');
print_out('return d?[b.createElement(d[1])]:(d=m.buildFragment([a],b,e),e&&e.length&&m(e).remove(),m.merge([],d.childNodes))};var bd=m.fn.load;m.fn.load=function(a,b,c){if("string"!=typeof a&&bd)return bd.apply(this,arguments);var d,e,f,g=this,h=a.indexOf(" ");return h>=0&&(d=m.trim(a.slice(h,a.length)),a=a.slice(0,h)),m.isFunction(b)?(c=b,b=void 0):b&&"object"==typeof b&&(f="POST"),g.length>0&&m.ajax({url:a,type:f,dataType:"html",data:b}).done(function(a){e=arguments,g.html(d?m("<div>").append(m.parseHTML(a)).find(d):a)}).complete(c&&function(a,b){g.each(c,e||[a.responseText,b,a])}),this},m.expr.filters.animated=function(a){return m.grep(m.timers,function(b){return a===b.elem}).length};var cd=a.document.documentElement;function dd(a){return m.isWindow(a)?a:9===a.nodeType?a.defaultView||a.parentWindow:!1}m.offset={setOffset:function(a,b,c){var d,e,f,g,h,i,j,k=m.css(a,"position"),l=m(a),n={};"static"===k&&(a.style.position="relative"),h=l.offset(),f=m.css(a,"top"),i=m.css(a,"left"),j=("absolute"===k||"fixed"===k)&&m.inArray("auto",[f,i])>-1,j?(d=l.position(),g=d.top,e=d.left):(g=parseFloat(f)||0,e=parseFloat(i)||0),m.isFunction(b)&&(b=b.call(a,c,h)),null!=b.top&&(n.top=b.top-h.top+g),null!=b.left&&(n.left=b.left-h.left+e),"using"in b?b.using.call(a,n):l.css(n)}},m.fn.extend({offset:function(a){if(arguments.length)return void 0===a?this:this.each(function(b){m.offset.setOffset(this,a,b)});');
print_out('var b,c,d={top:0,left:0},e=this[0],f=e&&e.ownerDocument;if(f)return b=f.documentElement,m.contains(b,e)?(typeof e.getBoundingClientRect!==K&&(d=e.getBoundingClientRect()),c=dd(f),{top:d.top+(c.pageYOffset||b.scrollTop)-(b.clientTop||0),left:d.left+(c.pageXOffset||b.scrollLeft)-(b.clientLeft||0)}):d},position:function(){if(this[0]){var a,b,c={top:0,left:0},d=this[0];return"fixed"===m.css(d,"position")?b=d.getBoundingClientRect():(a=this.offsetParent(),b=this.offset(),m.nodeName(a[0],"html")||(c=a.offset()),c.top+=m.css(a[0],"borderTopWidth",!0),c.left+=m.css(a[0],"borderLeftWidth",!0)),{top:b.top-c.top-m.css(d,"marginTop",!0),left:b.left-c.left-m.css(d,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){var a=this.offsetParent||cd;while(a&&!m.nodeName(a,"html")&&"static"===m.css(a,"position"))a=a.offsetParent;return a||cd})}}),m.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(a,b){var c=/Y/.test(b);m.fn[a]=function(d){return V(this,function(a,d,e){var f=dd(a);return void 0===e?f?b in f?f[b]:f.document.documentElement[d]:a[d]:void(f?f.scrollTo(c?m(f).scrollLeft():e,c?e:m(f).scrollTop()):a[d]=e)},a,d,arguments.length,null)}}),m.each(["top","left"],function(a,b){m.cssHooks[b]=Lb(k.pixelPosition,function(a,c){return c?(c=Jb(a,b),Hb.test(c)?m(a).position()[b]+"px":c):void 0})}),m.each({Height:"height",Width:"width"},function(a,b){m.each({padding:"inner"+a,content:b,"":"outer"+a},function(c,d){m.fn[d]=function(d,e){var f=arguments.length&&(c||"boolean"!=typeof d),g=c||(d===!0||e===!0?"margin":"border");');
print_out('return V(this,function(b,c,d){var e;return m.isWindow(b)?b.document.documentElement["client"+a]:9===b.nodeType?(e=b.documentElement,Math.max(b.body["scroll"+a],e["scroll"+a],b.body["offset"+a],e["offset"+a],e["client"+a])):void 0===d?m.css(b,c,g):m.style(b,c,d,g)},b,f?d:void 0,f,null)}})}),m.fn.size=function(){return this.length},m.fn.andSelf=m.fn.addBack,"function"==typeof define&&define.amd&&define("jquery",[],function(){return m});var ed=a.jQuery,fd=a.$;return m.noConflict=function(b){return a.$===m&&(a.$=fd),b&&a.jQuery===m&&(a.jQuery=ed),m},typeof b===K&&(a.jQuery=a.$=m),m});');
print_out('</script>');

print_out('<script type="text/javascript">
/*!
* TableSorter 2.15.3 min - Client-side table sorting with ease!
* Copyright (c) 2007 Christian Bach
*/');
print_out('!function(g){g.extend({tablesorter:new function(){function d(){var a=arguments[0],b=1<arguments.length?Array.prototype.slice.call(arguments):a;if("undefined"!==typeof console&&"undefined"!==typeof console.log)console[/error/i.test(a)?"error":/warn/i.test(a)?"warn":"log"](b);else alert(b)}function u(a,b){d(a+" ("+((new Date).getTime()-b.getTime())+"ms)")}function m(a){for(var b in a)return!1;return!0}function p(a,b,c){if(!b)return"";var h=a.config,e=h.textExtraction,f="",f="simple"===e?h.supportsTextContent? b.textContent:g(b).text():"function"===typeof e?e(b,a,c):"object"===typeof e&&e.hasOwnProperty(c)?e[c](b,a,c):h.supportsTextContent?b.textContent:g(b).text();return g.trim(f)}function t(a){var b=a.config,c=b.$tbodies=b.$table.children("tbody:not(."+b.cssInfoBlock+")"),h,e,w,k,n,g,l,z="";if(0===c.length)return b.debug?d("Warning: *Empty table!* Not building a parser cache"):"";b.debug&&(l=new Date,d("Detecting parsers for each column"));c=c[0].rows;if(c[0])for(h=[],e=c[0].cells.length,w=0;w<e;w++){k= b.$headers.filter(":not([colspan])");k=k.add(b.$headers.filter(''[colspan="1"]'')).filter(''[data-column="''+w+''"]:last'');n=b.headers[w];g=f.getParserById(f.getData(k,n,"sorter"));b.empties[w]=f.getData(k,n,"empty")||b.emptyTo||(b.emptyToBottom?"bottom":"top");b.strings[w]=f.getData(k,n,"string")||b.stringTo||"max";if(!g)a:{k=a;n=c;g=-1;for(var m=w,y=void 0,x=f.parsers.length,r=!1,t="",y=!0;""===t&&y;)g++,n[g]?(r=n[g].cells[m],t=p(k,r,m),k.config.debug&&d("Checking if value was empty on row "+g+", column: "+ m+'': "''+t+''"'')):y=!1;for(;0<=--x;)if((y=f.parsers[x])&&"text"!==y.id&&y.is&&y.is(t,k,r)){g=y;break a}g=f.getParserById("text")}b.debug&&(z+="column:"+w+"; parser:"+g.id+"; string:"+b.strings[w]+"; empty: "+b.empties[w]+"\n");h.push(g)}b.debug&&(d(z),u("Completed detecting parsers",l));');
print_out('b.parsers=h}function v(a){var b=a.tBodies,c=a.config,h,e,w=c.parsers,k,n,q,l,z,m,y,x=[];c.cache={};if(!w)return c.debug?d("Warning: *Empty table!* Not building a cache"):"";c.debug&&(y=new Date);c.showProcessing&&f.isProcessing(a, !0);for(l=0;l<b.length;l++)if(c.cache[l]={row:[],normalized:[]},!g(b[l]).hasClass(c.cssInfoBlock)){h=b[l]&&b[l].rows.length||0;e=b[l].rows[0]&&b[l].rows[0].cells.length||0;for(n=0;n<h;++n)if(z=g(b[l].rows[n]),m=[],z.hasClass(c.cssChildRow))c.cache[l].row[c.cache[l].row.length-1]=c.cache[l].row[c.cache[l].row.length-1].add(z);else{c.cache[l].row.push(z);for(q=0;q<e;++q)k=p(a,z[0].cells[q],q),k=w[q].format(k,a,z[0].cells[q],q),m.push(k),"numeric"===(w[q].type||"").toLowerCase()&&(x[q]=Math.max(Math.abs(k)|| 0,x[q]||0));m.push(c.cache[l].normalized.length);c.cache[l].normalized.push(m)}c.cache[l].colMax=x}c.showProcessing&&f.isProcessing(a);c.debug&&u("Building cache for "+h+" rows",y)}function A(a,b){var c=a.config,h=c.widgetOptions,e=a.tBodies,w=[],k=c.cache,d,q,l,z,p,y,x,r,t,s,v;');
print_out('if(m(k))return c.appender?c.appender(a,w):"";c.debug&&(v=new Date);for(r=0;r<e.length;r++)if(d=g(e[r]),d.length&&!d.hasClass(c.cssInfoBlock)){p=f.processTbody(a,d,!0);d=k[r].row;q=k[r].normalized;z=(l=q.length)?q[0].length- 1:0;for(y=0;y<l;y++)if(s=q[y][z],w.push(d[s]),!c.appender||c.pager&&!(c.pager.removeRows&&h.pager_removeRows||c.pager.ajax))for(t=d[s].length,x=0;x<t;x++)p.append(d[s][x]);f.processTbody(a,p,!1)}c.appender&&c.appender(a,w);c.debug&&u("Rebuilt table",v);b||c.appender||f.applyWidget(a);g(a).trigger("sortEnd",a);g(a).trigger("updateComplete",a)}function D(a){var b=[],c={},h=0,e=g(a).find("thead:eq(0), tfoot").children("tr"),f,d,n,q,l,m,u,p,s,r;for(f=0;f<e.length;f++)for(l=e[f].cells,d=0;d<l.length;d++){q= l[d];m=q.parentNode.rowIndex;u=m+"-"+q.cellIndex;p=q.rowSpan||1;s=q.colSpan||1;"undefined"===typeof b[m]&&(b[m]=[]);for(n=0;n<b[m].length+1;n++)if("undefined"===typeof b[m][n]){r=n;break}c[u]=r;h=Math.max(r,h);g(q).attr({"data-column":r});for(n=m;n<m+p;n++)for("undefined"===typeof b[n]&&(b[n]=[]),u=b[n],q=r;q<r+s;q++)u[q]="x"}a.config.columns=h+1;return c}function C(a){return/^d/i.test(a)||1===a}function E(a){var b=D(a),c,h,e,w,k,n,q,l=a.config;');
print_out('l.headerList=[];l.headerContent=[];l.debug&&(q=new Date); w=l.cssIcon?''<i class="''+(l.cssIcon===f.css.icon?f.css.icon:l.cssIcon+" "+f.css.icon)+''"></i>'':"";l.$headers=g(a).find(l.selectorHeaders).each(function(a){h=g(this);c=l.headers[a];l.headerContent[a]=g(this).html();k=l.headerTemplate.replace(/\{content\}/g,g(this).html()).replace(/\{icon\}/g,w);l.onRenderTemplate&&(e=l.onRenderTemplate.apply(h,[a,k]))&&"string"===typeof e&&(k=e);g(this).html(''<div class="''+f.css.headerIn+''">''+k+"</div>");l.onRenderHeader&&l.onRenderHeader.apply(h,[a]);this.column= b[this.parentNode.rowIndex+"-"+this.cellIndex];this.order=C(f.getData(h,c,"sortInitialOrder")||l.sortInitialOrder)?[1,0,2]:[0,1,2];this.count=-1;this.lockedOrder=!1;n=f.getData(h,c,"lockedOrder")||!1;"undefined"!==typeof n&&!1!==n&&(this.order=this.lockedOrder=C(n)?[1,1,1]:[0,0,0]);h.addClass(f.css.header+" "+l.cssHeader);l.headerList[a]=this;h.parent().addClass(f.css.headerRow+" "+l.cssHeaderRow).attr("role","row");l.tabIndex&&h.attr("tabindex",0)}).attr({scope:"col",role:"columnheader"});G(a);l.debug&& (u("Built headers:",q),d(l.$headers))}function B(a,b,c){var h=a.config;h.$table.find(h.selectorRemove).remove();t(a);v(a);H(h.$table,b,c)}');
print_out('function G(a){var b,c,h=a.config;h.$headers.each(function(e,d){c=g(d);b="false"===f.getData(d,h.headers[e],"sorter");d.sortDisabled=b;c[b?"addClass":"removeClass"]("sorter-false").attr("aria-disabled",""+b);a.id&&(b?c.removeAttr("aria-controls"):c.attr("aria-controls",a.id))})}function F(a){var b,c,h,e=a.config,d=e.sortList,k=f.css.sortNone+" "+e.cssNone,n=[f.css.sortAsc+ " "+e.cssAsc,f.css.sortDesc+" "+e.cssDesc],q=["ascending","descending"],l=g(a).find("tfoot tr").children().removeClass(n.join(" "));e.$headers.removeClass(n.join(" ")).addClass(k).attr("aria-sort","none");h=d.length;for(b=0;b<h;b++)if(2!==d[b][1]&&(a=e.$headers.not(".sorter-false").filter(''[data-column="''+d[b][0]+''"]''+(1===h?":last":"")),a.length))for(c=0;c<a.length;c++)a[c].sortDisabled||(a.eq(c).removeClass(k).addClass(n[d[b][1]]).attr("aria-sort",q[d[b][1]]),l.length&&l.filter(''[data-column="''+ d[b][0]+''"]'').eq(c).addClass(n[d[b][1]]));e.$headers.not(".sorter-false").each(function(){var a=g(this),b=this.order[(this.count+1)%(e.sortReset?3:2)],b=a.text()+": "+f.language[a.hasClass(f.css.sortAsc)?"sortAsc":a.hasClass(f.css.sortDesc)?"sortDesc":"sortNone"]+f.language[0===b?"nextAsc":1===b?"nextDesc":"nextNone"];a.attr("aria-label",b)})}function L(a){if(a.config.widthFixed&&0===g(a).find("colgroup").length){var b=g("<colgroup>"),c=g(a).width();g(a.tBodies[0]).find("tr:first").children("td:visible").each(function(){b.append(g("<col>").css("width", parseInt(g(this).width()/c*1E3,10)/10+"%"))});');
print_out('g(a).prepend(b)}}function M(a,b){var c,h,e,f=a.config,d=b||f.sortList;f.sortList=[];g.each(d,function(a,b){c=[parseInt(b[0],10),parseInt(b[1],10)];if(e=f.$headers[c[0]])f.sortList.push(c),h=g.inArray(c[1],e.order),e.count=0<=h?h:c[1]%(f.sortReset?3:2)})}function N(a,b){return a&&a[b]?a[b].type||"":""}function O(a,b,c){var h,e,d,k=a.config,n=!c[k.sortMultiSortKey],q=g(a);q.trigger("sortStart",a);b.count=c[k.sortResetKey]?2:(b.count+1)%(k.sortReset?3:2); k.sortRestart&&(e=b,k.$headers.each(function(){this===e||!n&&g(this).is("."+f.css.sortDesc+",."+f.css.sortAsc)||(this.count=-1)}));e=b.column;if(n){k.sortList=[];if(null!==k.sortForce)for(h=k.sortForce,c=0;c<h.length;c++)h[c][0]!==e&&k.sortList.push(h[c]);h=b.order[b.count];if(2>h&&(k.sortList.push([e,h]),1<b.colSpan))for(c=1;c<b.colSpan;c++)k.sortList.push([e+c,h])}else if(k.sortAppend&&1<k.sortList.length&&f.isValueInArray(k.sortAppend[0][0],k.sortList)&&k.sortList.pop(),f.isValueInArray(e,k.sortList))for(c= 0;c<k.sortList.length;c++)d=k.sortList[c],h=k.$headers[d[0]],d[0]===e&&(d[1]=h.order[b.count],2===d[1]&&(k.sortList.splice(c,1),h.count=-1));else if(h=b.order[b.count],2>h&&(k.sortList.push([e,h]),1<b.colSpan))for(c=1;c<b.colSpan;c++)k.sortList.push([e+c,h]);if(null!==k.sortAppend)for(h=k.sortAppend,c=0;c<h.length;c++)h[c][0]!==e&&k.sortList.push(h[c]);q.trigger("sortBegin",a);');
print_out('setTimeout(function(){F(a);I(a);A(a)},1)}function I(a){var b,c,h,e,d,k,g,q,l,p,s,t,x=0,r=a.config,v=r.textSorter||"",A=r.sortList, B=A.length,C=a.tBodies.length;if(!r.serverSideSorting&&!m(r.cache)){r.debug&&(l=new Date);for(c=0;c<C;c++)d=r.cache[c].colMax,q=(k=r.cache[c].normalized)&&k[0]?k[0].length-1:0,k.sort(function(c,k){for(b=0;b<B;b++){e=A[b][0];g=A[b][1];x=0===g;if(r.sortStable&&c[e]===k[e]&&1===B)break;(h=/n/i.test(N(r.parsers,e)))&&r.strings[e]?(h="boolean"===typeof r.string[r.strings[e]]?(x?1:-1)*(r.string[r.strings[e]]?-1:1):r.strings[e]?r.string[r.strings[e]]||0:0,p=r.numberSorter?r.numberSorter(s[e],t[e],x,d[e], a):f["sortNumeric"+(x?"Asc":"Desc")](c[e],k[e],h,d[e],e,a)):(s=x?c:k,t=x?k:c,p="function"===typeof v?v(s[e],t[e],x,e,a):"object"===typeof v&&v.hasOwnProperty(e)?v[e](s[e],t[e],x,e,a):f["sortNatural"+(x?"Asc":"Desc")](c[e],k[e],e,a,r));if(p)return p}return c[q]-k[q]});r.debug&&u("Sorting on "+A.toString()+" and dir "+g+" time",l)}}function J(a,b){var c=a[0].config;c.pager&&!c.pager.ajax&&a.trigger("updateComplete");"function"===typeof b&&b(a[0])}function H(a,b,c){!1===b||a[0].isProcessing?J(a,c):a.trigger("sorton", [a[0].config.sortList,function(){J(a,c)}])}function K(a){var b=a.config,c=b.$table;c.unbind("sortReset update updateRows updateCell updateAll addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave ".split(" ").join(".tablesorter ")).bind("sortReset.tablesorter",function(c){c.stopPropagation();');
print_out('b.sortList=[];F(a);I(a);A(a)}).bind("updateAll.tablesorter",function(c,e,d){c.stopPropagation();f.refreshWidgets(a,!0,!0);f.restoreHeaders(a);E(a);f.bindEvents(a,b.$headers); K(a);B(a,e,d)}).bind("update.tablesorter updateRows.tablesorter",function(b,c,d){b.stopPropagation();G(a);B(a,c,d)}).bind("updateCell.tablesorter",function(h,e,d,f){h.stopPropagation();c.find(b.selectorRemove).remove();var n,q,l;n=c.find("tbody");h=n.index(g(e).parents("tbody").filter(":first"));var m=g(e).parents("tr").filter(":first");e=g(e)[0];n.length&&0<=h&&(q=n.eq(h).find("tr").index(m),l=e.cellIndex,n=b.cache[h].normalized[q].length-1,b.cache[h].row[a.config.cache[h].normalized[q][n]]=m,b.cache[h].normalized[q][l]= b.parsers[l].format(p(a,e,l),a,e,l),H(c,d,f))}).bind("addRows.tablesorter",function(h,e,d,f){h.stopPropagation();if(m(b.cache))G(a),B(a,d,f);else{var g,q=e.filter("tr").length,l=[],u=e[0].cells.length,v=c.find("tbody").index(e.parents("tbody").filter(":first"));b.parsers||t(a);for(h=0;h<q;h++){for(g=0;g<u;g++)l[g]=b.parsers[g].format(p(a,e[h].cells[g],g),a,e[h].cells[g],g);l.push(b.cache[v].row.length);b.cache[v].row.push([e[h]]);b.cache[v].normalized.push(l);l=[]}H(c,d,f)}}).bind("sorton.tablesorter", function(b,e,d,f){var g=a.config;b.stopPropagation();c.trigger("sortStart",this);M(a,e);F(a);g.delayInit&&m(g.cache)&&v(a);c.trigger("sortBegin",this);I(a);A(a,f);"function"===typeof d&&d(a)}).bind("appendCache.tablesorter",function(b,c,d){b.stopPropagation();A(a,d);"function"===typeof c&&c(a)}).bind("applyWidgetId.tablesorter",function(c,e){c.stopPropagation();f.getWidgetById(e).format(a,b,b.widgetOptions)}).bind("applyWidgets.tablesorter",function(b,c){b.stopPropagation();f.applyWidget(a,c)}).bind("refreshWidgets.tablesorter", ');
print_out('function(b,c,d){b.stopPropagation();f.refreshWidgets(a,c,d)}).bind("destroy.tablesorter",function(b,c,d){b.stopPropagation();f.destroy(a,c,d)})}var f=this;f.version="2.15.3";f.parsers=[];f.widgets=[];f.defaults={theme:"default",widthFixed:!1,showProcessing:!1,headerTemplate:"{content}",onRenderTemplate:null,onRenderHeader:null,cancelSelection:!0,tabIndex:!0,dateFormat:"mmddyyyy",sortMultiSortKey:"shiftKey",sortResetKey:"ctrlKey",usNumberFormat:!0,delayInit:!1,serverSideSorting:!1,headers:{},ignoreCase:!0, sortForce:null,sortList:[],sortAppend:null,sortStable:!1,sortInitialOrder:"asc",sortLocaleCompare:!1,sortReset:!1,sortRestart:!1,emptyTo:"bottom",stringTo:"max",textExtraction:"simple",textSorter:null,numberSorter:null,widgets:[],widgetOptions:{zebra:["even","odd"]},initWidgets:!0,initialized:null,tableClass:"",cssAsc:"",cssDesc:"",cssNone:"",cssHeader:"",cssHeaderRow:"",cssProcessing:"",cssChildRow:"tablesorter-childRow",cssIcon:"tablesorter-icon",cssInfoBlock:"tablesorter-infoOnly",selectorHeaders:"> thead th, > thead td", selectorSort:"th, td",selectorRemove:".remove-me",debug:!1,headerList:[],empties:{},strings:{},parsers:[]};f.css={table:"tablesorter",childRow:"tablesorter-childRow",header:"tablesorter-header",headerRow:"tablesorter-headerRow",headerIn:"tablesorter-header-inner",icon:"tablesorter-icon",info:"tablesorter-infoOnly",processing:"tablesorter-processing",sortAsc:"tablesorter-headerAsc",sortDesc:"tablesorter-headerDesc",sortNone:"tablesorter-headerUnSorted"};f.language={sortAsc:"Ascending sort applied, ", sortDesc:"Descending sort applied, ",sortNone:"No sort applied, ",nextAsc:"activate to apply an ascending sort",nextDesc:"activate to apply a descending sort",nextNone:"activate to remove the sort"};f.log=d;f.benchmark=u;f.construct=function(a){return this.each(function(){var b=g.extend(!0,{},f.defaults,a);');
print_out('!this.hasInitialized&&f.buildTable&&"TABLE"!==this.tagName&&f.buildTable(this,b);f.setup(this,b)})};f.setup=function(a,b){if(!a||!a.tHead||0===a.tBodies.length||!0===a.hasInitialized)return b.debug? d("ERROR: stopping initialization! No table, thead, tbody or tablesorter has already been initialized"):"";var c="",h=g(a),e=g.metadata;a.hasInitialized=!1;a.isProcessing=!0;a.config=b;g.data(a,"tablesorter",b);b.debug&&g.data(a,"startoveralltimer",new Date);b.supportsTextContent="x"===g("<span>x</span>")[0].textContent;b.supportsDataObject=function(a){a[0]=parseInt(a[0],10);return 1<a[0]||1===a[0]&&4<=parseInt(a[1],10)}(g.fn.jquery.split("."));b.string={max:1,min:-1,"max+":1,"max-":-1,zero:0,none:0, "null":0,top:!0,bottom:!1};/tablesorter\-/.test(h.attr("class"))||(c=""!==b.theme?" tablesorter-"+b.theme:"");b.$table=h.addClass(f.css.table+" "+b.tableClass+c).attr({role:"grid"});b.$tbodies=h.children("tbody:not(."+b.cssInfoBlock+")").attr({"aria-live":"polite","aria-relevant":"all"});b.$table.find("caption").length&&b.$table.attr("aria-labelledby","theCaption");b.widgetInit={};E(a);L(a);t(a);b.delayInit||v(a);f.bindEvents(a,b.$headers);K(a);b.supportsDataObject&&"undefined"!==typeof h.data().sortlist? b.sortList=h.data().sortlist:e&&h.metadata()&&h.metadata().sortlist&&(b.sortList=h.metadata().sortlist);');
print_out('f.applyWidget(a,!0);0<b.sortList.length?h.trigger("sorton",[b.sortList,{},!b.initWidgets]):(F(a),b.initWidgets&&f.applyWidget(a));b.showProcessing&&h.unbind("sortBegin.tablesorter sortEnd.tablesorter").bind("sortBegin.tablesorter sortEnd.tablesorter",function(b){f.isProcessing(a,"sortBegin"===b.type)});a.hasInitialized=!0;a.isProcessing=!1;b.debug&&f.benchmark("Overall initialization time",g.data(a, "startoveralltimer"));h.trigger("tablesorter-initialized",a);"function"===typeof b.initialized&&b.initialized(a)};f.isProcessing=function(a,b,c){a=g(a);var h=a[0].config;a=c||a.find("."+f.css.header);b?("undefined"!==typeof c&&0<h.sortList.length&&(a=a.filter(function(){return this.sortDisabled?!1:f.isValueInArray(parseFloat(g(this).attr("data-column")),h.sortList)})),a.addClass(f.css.processing+" "+h.cssProcessing)):a.removeClass(f.css.processing+" "+h.cssProcessing)};f.processTbody=function(a,b, c){a=g(a)[0];if(c)return a.isProcessing=!0,b.before(''<span class="tablesorter-savemyplace"/>''),c=g.fn.detach?b.detach():b.remove();c=g(a).find("span.tablesorter-savemyplace");b.insertAfter(c);c.remove();a.isProcessing=!1};f.clearTableBody=function(a){g(a)[0].config.$tbodies.empty()};f.bindEvents=function(a,b){a=g(a)[0];var c,h=a.config;b.find(h.selectorSort).add(b.filter(h.selectorSort)).unbind("mousedown.tablesorter mouseup.tablesorter sort.tablesorter keyup.tablesorter").bind("mousedown.tablesorter mouseup.tablesorter sort.tablesorter keyup.tablesorter", function(e,d){var f;f=e.type;');
print_out('if(!(1!==(e.which||e.button)&&!/sort|keyup/.test(f)||"keyup"===f&&13!==e.which||"mouseup"===f&&!0!==d&&250<(new Date).getTime()-c)){if("mousedown"===f)return c=(new Date).getTime(),"INPUT"===e.target.tagName?"":!h.cancelSelection;h.delayInit&&m(h.cache)&&v(a);f=/TH|TD/.test(this.tagName)?this:g(this).parents("th, td")[0];f=h.$headers[b.index(f)];f.sortDisabled||O(a,f,e)}});h.cancelSelection&&b.attr("unselectable","on").bind("selectstart",!1).css({"user-select":"none", MozUserSelect:"none"})};f.restoreHeaders=function(a){var b=g(a)[0].config;b.$table.find(b.selectorHeaders).each(function(a){g(this).find("."+f.css.headerIn).length&&g(this).html(b.headerContent[a])})};f.destroy=function(a,b,c){a=g(a)[0];if(a.hasInitialized){f.refreshWidgets(a,!0,!0);var h=g(a),e=a.config,d=h.find("thead:first"),k=d.find("tr."+f.css.headerRow).removeClass(f.css.headerRow+" "+e.cssHeaderRow),n=h.find("tfoot:first > tr").children("th, td");d.find("tr").not(k).remove();h.removeData("tablesorter").unbind("sortReset update updateAll updateRows updateCell addRows sorton appendCache applyWidgetId applyWidgets refreshWidgets destroy mouseup mouseleave keypress sortBegin sortEnd ".split(" ").join(".tablesorter ")); e.$headers.add(n).removeClass([f.css.header,e.cssHeader,e.cssAsc,e.cssDesc,f.css.sortAsc,f.css.sortDesc,f.css.sortNone].join(" ")).removeAttr("data-column");k.find(e.selectorSort).unbind("mousedown.tablesorter mouseup.tablesorter keypress.tablesorter");f.restoreHeaders(a);!1!==b&&h.removeClass(f.css.table+" "+e.tableClass+" tablesorter-"+e.theme);a.hasInitialized=!1;"function"===typeof c&&c(a)}};');
print_out('f.regex={chunk:/(^([+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?)?$|^0x[0-9a-f]+$|\d+)/gi,hex:/^0x[0-9a-f]+$/i}; f.sortNatural=function(a,b){if(a===b)return 0;var c,h,e,d,g,n;h=f.regex;if(h.hex.test(b)){c=parseInt(a.match(h.hex),16);e=parseInt(b.match(h.hex),16);if(c<e)return-1;if(c>e)return 1}c=a.replace(h.chunk,"\\0$1\\0").replace(/\\0$/,"").replace(/^\\0/,"").split("\\0");h=b.replace(h.chunk,"\\0$1\\0").replace(/\\0$/,"").replace(/^\\0/,"").split("\\0");n=Math.max(c.length,h.length);for(g=0;g<n;g++){e=isNaN(c[g])?c[g]||0:parseFloat(c[g])||0;d=isNaN(h[g])?h[g]||0:parseFloat(h[g])||0;if(isNaN(e)!==isNaN(d))return isNaN(e)? 1:-1;typeof e!==typeof d&&(e+="",d+="");if(e<d)return-1;if(e>d)return 1}return 0};f.sortNaturalAsc=function(a,b,c,d,e){if(a===b)return 0;c=e.string[e.empties[c]||e.emptyTo];return""===a&&0!==c?"boolean"===typeof c?c?-1:1:-c||-1:""===b&&0!==c?"boolean"===typeof c?c?1:-1:c||1:f.sortNatural(a,b)};f.sortNaturalDesc=function(a,b,c,d,e){if(a===b)return 0;c=e.string[e.empties[c]||e.emptyTo];return""===a&&0!==c?"boolean"===typeof c?c?-1:1:c||1:""===b&&0!==c?"boolean"===typeof c?c?1:-1:-c||-1:f.sortNatural(b, a)};f.sortText=function(a,b){return a>b?1:a<b?-1:0};f.getTextValue=function(a,b,c){if(c){var d=a?a.length:0,e=c+b;for(c=0;c<d;c++)e+=a.charCodeAt(c);return b*e}return 0};f.sortNumericAsc=function(a,b,c,d,e,g){if(a===b)return 0;g=g.config;e=g.string[g.empties[e]||g.emptyTo];');
print_out('if(""===a&&0!==e)return"boolean"===typeof e?e?-1:1:-e||-1;if(""===b&&0!==e)return"boolean"===typeof e?e?1:-1:e||1;isNaN(a)&&(a=f.getTextValue(a,c,d));isNaN(b)&&(b=f.getTextValue(b,c,d));return a-b};f.sortNumericDesc=function(a, b,c,d,e,g){if(a===b)return 0;g=g.config;e=g.string[g.empties[e]||g.emptyTo];if(""===a&&0!==e)return"boolean"===typeof e?e?-1:1:e||1;if(""===b&&0!==e)return"boolean"===typeof e?e?1:-1:-e||-1;isNaN(a)&&(a=f.getTextValue(a,c,d));isNaN(b)&&(b=f.getTextValue(b,c,d));return b-a};f.sortNumeric=function(a,b){return a-b};f.characterEquivalents={a:"\u00e1\u00e0\u00e2\u00e3\u00e4\u0105\u00e5",A:"\u00c1\u00c0\u00c2\u00c3\u00c4\u0104\u00c5",c:"\u00e7\u0107\u010d",C:"\u00c7\u0106\u010c",e:"\u00e9\u00e8\u00ea\u00eb\u011b\u0119", E:"\u00c9\u00c8\u00ca\u00cb\u011a\u0118",i:"\u00ed\u00ec\u0130\u00ee\u00ef\u0131",I:"\u00cd\u00cc\u0130\u00ce\u00cf",o:"\u00f3\u00f2\u00f4\u00f5\u00f6",O:"\u00d3\u00d2\u00d4\u00d5\u00d6",ss:"\u00df",SS:"\u1e9e",u:"\u00fa\u00f9\u00fb\u00fc\u016f",U:"\u00da\u00d9\u00db\u00dc\u016e"};f.replaceAccents=function(a){var b,c="[",d=f.characterEquivalents;if(!f.characterRegex){f.characterRegexArray={};for(b in d)"string"===typeof b&&(c+=d[b],f.characterRegexArray[b]=RegExp("["+d[b]+"]","g"));f.characterRegex= RegExp(c+"]")}if(f.characterRegex.test(a))for(b in d)"string"===typeof b&&(a=a.replace(f.characterRegexArray[b],b));return a};f.isValueInArray=function(a,b){var c,d=b.length;for(c=0;c<d;c++)if(b[c][0]===a)return!0;return!1};f.addParser=function(a){var b,c=f.parsers.length,d=!0;for(b=0;b<c;b++)f.parsers[b].id.toLowerCase()===a.id.toLowerCase()&&(d=!1);d&&f.parsers.push(a)};f.getParserById=function(a){var b,c=f.parsers.length;for(b=0;b<c;b++)if(f.parsers[b].id.toLowerCase()===a.toString().toLowerCase())return f.parsers[b]; ');
print_out('return!1};f.addWidget=function(a){f.widgets.push(a)};f.getWidgetById=function(a){var b,c,d=f.widgets.length;for(b=0;b<d;b++)if((c=f.widgets[b])&&c.hasOwnProperty("id")&&c.id.toLowerCase()===a.toLowerCase())return c};f.applyWidget=function(a,b){a=g(a)[0];var c=a.config,d=c.widgetOptions,e=[],m,k,n;c.debug&&(m=new Date);c.widgets.length&&(c.widgets=g.grep(c.widgets,function(a,b){return g.inArray(a,c.widgets)===b}),g.each(c.widgets||[],function(a,b){(n=f.getWidgetById(b))&&n.id&&(n.priority||(n.priority= 10),e[a]=n)}),e.sort(function(a,b){return a.priority<b.priority?-1:a.priority===b.priority?0:1}),g.each(e,function(e,f){if(f){if(b||!c.widgetInit[f.id])f.hasOwnProperty("options")&&(d=a.config.widgetOptions=g.extend(!0,{},f.options,d)),f.hasOwnProperty("init")&&f.init(a,f,c,d),c.widgetInit[f.id]=!0;!b&&f.hasOwnProperty("format")&&f.format(a,c,d,!1)}}));c.debug&&(k=c.widgets.length,u("Completed "+(!0===b?"initializing ":"applying ")+k+" widget"+(1!==k?"s":""),m))};f.refreshWidgets=function(a,b,c){a= g(a)[0];var h,e=a.config,m=e.widgets,k=f.widgets,n=k.length;for(h=0;h<n;h++)k[h]&&k[h].id&&(b||0>g.inArray(k[h].id,m))&&(e.debug&&d(''Refeshing widgets: Removing "''+k[h].id+''"''),k[h].hasOwnProperty("remove")&&e.widgetInit[k[h].id]&&(k[h].remove(a,e,e.widgetOptions),e.widgetInit[k[h].id]=!1));!0!==c&&f.applyWidget(a,b)};f.getData=function(a,b,c){var d="";a=g(a);var e,f;if(!a.length)return"";e=g.metadata?a.metadata():!1;');
print_out('f=" "+(a.attr("class")||"");"undefined"!==typeof a.data(c)||"undefined"!==typeof a.data(c.toLowerCase())? d+=a.data(c)||a.data(c.toLowerCase()):e&&"undefined"!==typeof e[c]?d+=e[c]:b&&"undefined"!==typeof b[c]?d+=b[c]:" "!==f&&f.match(" "+c+"-")&&(d=f.match(RegExp("\\s"+c+"-([\\w-]+)"))[1]||"");return g.trim(d)};f.formatFloat=function(a,b){if("string"!==typeof a||""===a)return a;var c;a=(b&&b.config?!1!==b.config.usNumberFormat:"undefined"!==typeof b?b:1)?a.replace(/,/g,""):a.replace(/[\s|\.]/g,"").replace(/,/g,".");/^\s*\([.\d]+\)/.test(a)&&(a=a.replace(/^\s*\(([.\d]+)\)/,"-$1"));c=parseFloat(a);return isNaN(c)? g.trim(a):c};f.isDigit=function(a){return isNaN(a)?/^[\-+(]?\d+[)]?$/.test(a.toString().replace(/[,.''"\s]/g,"")):!0}}});var p=g.tablesorter;g.fn.extend({tablesorter:p.construct});p.addParser({id:"text",is:function(){return!0},format:function(d,u){var m=u.config;d&&(d=g.trim(m.ignoreCase?d.toLocaleLowerCase():d),d=m.sortLocaleCompare?p.replaceAccents(d):d);return d},type:"text"});p.addParser({id:"digit",is:function(d){return p.isDigit(d)},format:function(d,u){var m=p.formatFloat((d||"").replace(/[^\w,. \-()]/g, ""),u);return d&&"number"===typeof m?m:d?g.trim(d&&u.config.ignoreCase?d.toLocaleLowerCase():d):d},type:"numeric"});p.addParser({id:"currency",is:function(d){return/^\(?\d+[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]|[\u00a3$\u20ac\u00a4\u00a5\u00a2?.]\d+\)?$/.test((d||"").replace(/[+\-,. ]/g,""))},format:function(d,u){var m=p.formatFloat((d||"").replace(/[^\w,. \-()]/g,""),u);return d&&"number"===typeof m?m:d?g.trim(d&&u.config.ignoreCase?d.toLocaleLowerCase():d):d},type:"numeric"});p.addParser({id:"ipAddress", is:function(d){return/^\d{1,3}[\.]\d{1,3}[\.]\d{1,3}[\.]\d{1,3}$/.test(d)},format:function(d,g){var m,s=d?d.split("."):"",t="",v=s.length;');
print_out('for(m=0;m<v;m++)t+=("00"+s[m]).slice(-3);return d?p.formatFloat(t,g):d},type:"numeric"});p.addParser({id:"url",is:function(d){return/^(https?|ftp|file):\/\//.test(d)},format:function(d){return d?g.trim(d.replace(/(https?|ftp|file):\/\//,"")):d},type:"text"});p.addParser({id:"isoDate",is:function(d){return/^\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2}/.test(d)},format:function(d, g){return d?p.formatFloat(""!==d?(new Date(d.replace(/-/g,"/"))).getTime()||"":"",g):d},type:"numeric"});p.addParser({id:"percent",is:function(d){return/(\d\s*?%|%\s*?\d)/.test(d)&&15>d.length},format:function(d,g){return d?p.formatFloat(d.replace(/%/g,""),g):d},type:"numeric"});p.addParser({id:"usLongDate",is:function(d){return/^[A-Z]{3,10}\.?\s+\d{1,2},?\s+(\d{4})(\s+\d{1,2}:\d{2}(:\d{2})?(\s+[AP]M)?)?$/i.test(d)||/^\d{1,2}\s+[A-Z]{3,10}\s+\d{4}/i.test(d)},format:function(d,g){return d?p.formatFloat((new Date(d.replace(/(\S)([AP]M)$/i, "$1 $2"))).getTime()||"",g):d},type:"numeric"});p.addParser({id:"shortDate",is:function(d){return/(^\d{1,2}[\/\s]\d{1,2}[\/\s]\d{4})|(^\d{4}[\/\s]\d{1,2}[\/\s]\d{1,2})/.test((d||"").replace(/\s+/g," ").replace(/[\-.,]/g,"/"))},format:function(d,g,m,s){if(d){m=g.config;');
print_out('var t=m.$headers.filter("[data-column="+s+"]:last");s=t.length&&t[0].dateFormat||p.getData(t,m.headers[s],"dateFormat")||m.dateFormat;d=d.replace(/\s+/g," ").replace(/[\-.,]/g,"/");"mmddyyyy"===s?d=d.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/, "$3/$1/$2"):"ddmmyyyy"===s?d=d.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{4})/,"$3/$2/$1"):"yyyymmdd"===s&&(d=d.replace(/(\d{4})[\/\s](\d{1,2})[\/\s](\d{1,2})/,"$1/$2/$3"))}return d?p.formatFloat((new Date(d)).getTime()||"",g):d},type:"numeric"});p.addParser({id:"time",is:function(d){return/^(([0-2]?\d:[0-5]\d)|([0-1]?\d:[0-5]\d\s?([AP]M)))$/i.test(d)},format:function(d,g){return d?p.formatFloat((new Date("2000/01/01 "+d.replace(/(\S)([AP]M)$/i,"$1 $2"))).getTime()||"",g):d},type:"numeric"});p.addParser({id:"metadata", is:function(){return!1},format:function(d,p,m){d=p.config;d=d.parserMetadataName?d.parserMetadataName:"sortValue";return g(m).metadata()[d]},type:"numeric"});p.addWidget({id:"zebra",priority:90,format:function(d,u,m){var s,t,v,A,D,C,E=RegExp(u.cssChildRow,"i"),B=u.$tbodies;u.debug&&(D=new Date);for(d=0;d<B.length;d++)s=B.eq(d),C=s.children("tr").length,1<C&&(v=0,s=s.children("tr:visible").not(u.selectorRemove),s.each(function(){t=g(this);E.test(this.className)||v++;A=0===v%2;t.removeClass(m.zebra[A? 1:0]).addClass(m.zebra[A?0:1])}));u.debug&&p.benchmark("Applying Zebra widget",D)},remove:function(d,p,m){var s;p=p.$tbodies;var t=(m.zebra||["even","odd"]).join(" ");for(m=0;m<p.length;m++)s=g.tablesorter.processTbody(d,p.eq(m),!0),s.children().removeClass(t),g.tablesorter.processTbody(d,s,!1)}})}(jQuery);');
print_out('</script>');

print_out('

<script>
$(document).ready(function(){
    var alertOn = true;
    var filterString="";
    var sectionTitle = {"E": "Error Signatures",
                        "W": "Warning Signatures",
                        "S": "Successful Signatures",
                        "I": "Informational Signatures",
                        "P": "Passed Checks (not shown in main report"};
    var searchFlag=false;
    var popupVisible=false;
    var expcolview=false;

    var ua=navigator.userAgent;
    var browserDetails=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
    var isOldBrowser = false;
    /* if browser is firefox and version is 45 or lower, do not hide rows when filtering. Only highlight those that match.*/
    if ((browserDetails[1] == "Firefox") && (browserDetails[2] <= 45)) {
        isOldBrowser = true;
    }

    /* before antyhing else, verify if the file is complete and alert otherwise    */
    if (! $("#integrityCheck").length ) {
        alert("The file is incomplete or corrupt and will not be displayed correctly!\nYou might be able to view a partial content using Data View / Full View.");
    }

    $("#homeButton").click(function(){
        $(".data").hide();
        $(".maindata").hide();
        $(".mainmenu").show();
        $("#search").val("");
    });

    /* Open pop-up window*/
    $("[data-popup-open]").on("click", function()  {
        var targeted_popup_class = jQuery(this).attr("data-popup-open");
        $("[data-popup]").hide();
        $("[data-popup=''" + targeted_popup_class + "'']").fadeIn(350, function(){
           popupVisible = true;
        });
    });

    /* Close pop-up window*/
    $("[data-popup-close]").on("click", function()  {
        var targeted_popup_class = jQuery(this).attr("data-popup-close");
        $("[data-popup=''" + targeted_popup_class + "'']").fadeOut(350, function(){
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

    /* Open section (by section name or by error type)*/
    $("[open-section]").on("click", function()  {
        var sectionID = jQuery(this).attr("open-section");
        var sectionName = jQuery(this).find("div.textbox").text();
        if ((sectionName == null) || (sectionName == "")){
            sectionName = sectionTitle[sectionID];
        }
        filterString = sectionID;
        expcolview = false;

        /* if the section is empty, do nothing*/
        if ($("." + sectionID).size() <= 0) {
           return;
        }
        $(".mainmenu").hide();
        $(".data").hide();
        $(".section").show();
        $(".signature").hide();
        $("." + sectionID).show();
        $("#search").val("");
        $("#showhidesection").attr("mode", "show");
        $("span.brokenlink").hide();

        $("#export2TextLink").attr("onClick", "onclick=export2PaddedText(''" + sectionID + "'');return false;");
        $(".exportAllImg").attr("onClick", "export2CSV(''" + sectionID + "'', ''section'')");

        $(".containertitle").html(sectionName);

        if ((sectionID == ''error'') || (sectionID == ''success'') || (sectionID == ''information'') || (sectionID == ''warning'')) {
            $(".sectionview").attr("open-sig-class", sectionID + "sig");
        } else {
            $(".sectionview").attr("open-sig-class", sectionID);
        }
        $("a[siglink]").removeAttr("href");  /* remove links between signature records in section view*/
        $("a[siglink]").removeClass("hypersource");
        $("a[siglink]").addClass("nolink");
        $("." + sectionID).first().click();
    });

    /* Open signature */
    $("[open-sig]").on("click", function()  {
        var sigID = jQuery(this).attr("open-sig");

        $(".signature").hide();
        $(".sectionbutton").css("background-color", "#e7ecf0");
        $(".export2Txt").hide();
        $("#SignatureTitle").html("Signature: " + sigID);
        $("." + sigID).show();
        $(".sectionbutton[open-sig=''" + sigID + "'']").css("background-color","white");
        var e = jQuery.Event("keypress");
        e.keyCode = 13;
        $("#search").focus();
        $("#search").trigger(e);
    });

    /* Print, Analysis and Full Section view */
    $("[open-sig-class]").on("click", function(){
        var sigClassID = jQuery(this).attr("open-sig-class");
        expcolview = true;

        /* hide everything first*/
        $(".mainmenu").hide();
        $(".data").hide();
        $("#search").val("");

        if (sigClassID == "print"){
            $(".containertitle").html("Full View");
            $("#expandall").attr("mode", "print");
            filterString="";
            /* show all divs that have the print class*/
            $(".print").show();
            $("a[siglink]").removeAttr("href");  /* remove links between signature records in print view */
            $("a[siglink]").removeClass("hypersource");
            $("a[siglink]").addClass("nolink");
            $("span.brokenlink").hide();
            $(".exportAllImg").attr("onClick", "export2CSV(''ALL'')");

        } else if (sigClassID == "analysis") {
            $(".containertitle").html("Data View");
            $("#expandall").attr("mode", "analysis");
            filterString="";
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
                   $(this).closest(''td'').find(''span.brokenlink'').show();
               }
            });

        } else if (sigClassID == "passed"){  /* for a short summary of passed checks. No export links, no checkboxes, no bling bling */
            $(".containertitle").html("Passed Checks (not shown in main report)");
            $(".signature").hide();
            $(".P").show();
        } else { /* Entire Section view */
            if ($("#showhidesection").attr("mode") == "show") {
                if (/^(E|I|S|W)$/.test(sigClassID)){
                    $(".sigrescode."+sigClassID).parents("div.sigcontainer").show();
                } else {
                    $("." + sigClassID).show();
                }
                $(".fullsection").show();
                filterString = sigClassID;
                $("#showhidesection").attr("mode", "hide");
                $("#expandall").attr("mode", "print");
            } else {
                $(".section").show();
                $(".signature").hide();
                $("#showhidesection").attr("mode", "show");
                $("[open-section=''"+sigClassID+"'']").click();
            }
        }
    });



    /* Open table data (for a sig)    */
    $("a[toggle-data]").on("click", function(){
        var $tabledataID = $(this).attr("toggle-data");
        var $dataTable = $("#"+$tabledataID);
        $dataTable.toggle();
        $(this).find(".arrowright").toggle();
        if ($(this).find(".arrowdown").css("display") == "none"){
            $(this).find(".arrowdown").show();
            if (expcolview) {
                $("#collapseall").show();
            }
        } else {
            $(this).find(".arrowdown").hide();
            if (expcolview) {
                $("#expandall").show();
            }
        };
        var e = jQuery.Event("keypress");
        e.keyCode = 13; /* Enter */
        $("#search").trigger(e);
    });


    $("a[toggle-info]").on("click", function(){
        var infoID = $(this).attr("toggle-info");
        $("#"+infoID).toggle();

    });

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


    $("#expandall").on("click", function(){
        if (alertOn){
            var returnVal = confirm ("This action could lead to performance issues and might even freeze your browser window. Do you want to continue?");
            if (returnVal == false) return;
            alertOn = false;
        }
        if (returnVal == false) return;
        $(".tabledata").show();
        if ($(this).attr("mode") == "print"){
            $(".results").show();
        }
        $(".arrowright").hide();
        $(".arrowdown").show();
        $("#expandall").hide();
        $("#collapseall").show();
        var e = jQuery.Event("keypress");
        e.keyCode = 13;
        $("#search").trigger(e);
    });
    $("#collapseall").on("click", function(){
        $(".tabledata").hide();
        if ($("#expandall").attr("mode") == "print"){
            $(".results").show();
        } else {
            $(".results").hide();
        }
        $(".arrowright").show();
        $(".arrowdown").hide();
        $("#collapseall").hide();
        $("#expandall").show();
    });

    /* Dynamic display based on the search string*/
    $("#search").keypress (function(e) {
       if (e.keyCode == 13){
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
                  var rowList = filterString ? $(".tdata."+filterString+":hidden") : $(".tdata:hidden");
                  rowList.show();
               }
               return;
            }
            var $showRows = filterString ? $(".tdata."+filterString+":containsi(''"+searchTerm+"'')") : $(".tdata:containsi(''"+searchTerm+"'')");
            var $noShow = filterString ? $(".tdata."+filterString).not(":containsi(''"+searchTerm+"'')") : $(".tdata").not(":containsi(''"+searchTerm+"'')");
            $noShow.css("display","none");
            $showRows.css("display","table-row");
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

            $(".tdata").not(":containsi(''" + searchTerm + "'')").css("background-color", "white");
            $(".tdata:containsi(''" + searchTerm + "'')").css("background-color", "#ffffe6");

         }
      }
      searchFlag = true;
   });


   $(".sort_ico").on(''click'', function(){
      var tableName = $(this).attr("table-name");
      $("#restable_" + tableName).tablesorter();
      $(this).hide();
   });
});


function export2CSV(name, type) {
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
        $records = $(".exportcheck:checkbox[rowid=''"+name+"'']");
      }
  }

  var csv = ''"'';
  $records.each(function(){

    var $rows = $("tr." + $(this).attr("rowid"));
    var level = $($("#" + $(this).attr("rowid"))).attr("level");

    tmpColDelim = String.fromCharCode(11),
    tmpRowDelim = String.fromCharCode(0),

    colDelim = ''","'',
    rowDelim = ''"\r\n"'';

/*CG comment    csv += rowDelim + $($("#" + $(this).attr("rowid")).find("div.sigdescription")).find("td").text() + rowDelim;*/
    csv += $rows.map(function (i, row) {
                            var $row = $(row);
                            var $cols = $row.find(''td,th'');

                         return $cols.map(function (j, col) {
                                       var $col = $(col);
                                       var $text = $col.text();
                                       return $text.replace(/"/g, ''""'').trim(); /* escape double quotes, trim leading and trailing blacks to avoid Excel misreading them  */
            }).get().join(tmpColDelim);
        }).get().join(tmpRowDelim)
            .split(tmpRowDelim).join(rowDelim)
            .split(tmpColDelim).join(colDelim) + rowDelim + rowDelim;

   });

   csv += ''"'';
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

String.prototype.repeat = function(n) {
   return (new Array(n + 1)).join(this);
};

function export2PaddedText(section) {
   /* export a full section - the section id is passed as parameter. If null, then return.*/
   if ((section == null) || (section ==''''))
       return;

   var $records = $(''.signature.''+section);

   /*if no signatures in the section, nothing to do. Return.*/
   if ($records.length < 0) return;

   /* define array for col max length */
   var maxlen = [];

   /* parse all rows once and gather the max length for each column in each table (first columns, second columns etc). Populate maxlen array.   */
   var $rows = $(''tr.''+section);
   $rows.each(function(){
      /* skip if this is a sig title row*/
      if ($(this).hasClass(''sigtitle'')) return;
      $currrow = $(this);
      var counter = 0;
      $currrow.find("td,th").each(function(){
          if (($(this).text().length > maxlen[counter]) || (typeof maxlen[counter] == "undefined")) {
              maxlen[counter] = $(this).text().length;
          }
          counter++;
      });
   });

   colDelim = '' '',
   rowDelim = ''\r\n'';

   text = '''';

   $rows.each(function(){

      if ($(this).hasClass("sigtitle")) {
           var title = $(this).find(''td'').text();
           text += rowDelim + rowDelim + rowDelim + title + rowDelim + "_".repeat(title.length) + rowDelim + rowDelim;
           return;
      }

      $cols = $(this).find(''td,th'');

      text += $cols.map(function (j, col) {
         var $col = $(col);
         var text = $col.text() + " ".repeat(maxlen[j] - $col.text().length + 1);
         return text;
      }).get().join(colDelim);

      text += rowDelim;

    });

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

function export2HTML() {
   var i = 0;
   var $signatures = $("div.signature");

   /*if no signatures return */
   if ($signatures.length < 0) return;

   rowDelim = "\r\n";

   var text = "";
   var header = "<html><head><title>Data export</title></head><body style=''background=\"#ffffff\";color:#336699;font-family=arial;''>";

   var params = "<br><br><table align=''center'' cellspacing=''1'' cellpadding=''1'' border=''1''><thead><tr bgcolor=''#cccc99''><th><i>The test was run with the following parameters </i></th><th></th></tr></thead><tbody>";

   var $paramDiv = $("div.popup[data-popup=''popup-2'']");
   var $paramRecords = $paramDiv.find("td.popup-paramname");

   $paramRecords.each(function(){
       var paramName = $(this).text();
       var paramValue = $(this).closest("tr").find("td.popup-paramval").text();

       params += "<tr bgcolor=''#f4f4e4''><td width=''50%''>" + paramName + "</td><td width=''50%''>" + paramValue + "</td></tr>";

   });


   params += "</tbody></table><br><br>";

   var indexTbl = "<br><br><table align=''center'' cellspacing=''1'' cellpadding=''1'' border=''1''><thead><tr bgcolor=''#cccc99''><th colspan=2><i>INDEX FOR MAJOR TABLES DIRECT ACCESS</i></th></tr></thead><tbody><tr bgcolor=''#f4f4e4''>";

   $signatures.each(function(){
       var sigId = $(this).attr("id");
       var level = $(this).attr("level");
       var title = $(this).children("div.divItemTitle").find("td.divItemTitlet").text();

       if (level > 1) {
          text += "<blockquote>";
       } else {
           indexTbl += "<td width=''50%''><a href=''#" + sigId + "''>" + title + "</a></td>";
           i++;
           if (i % 2 == 0) {
               indexTbl += "</tr><tr bgcolor=''#f4f4e4''>";
           }
       }
       text += "<br><br><b>";
       text += "<a id=''" + sigId + "''>" + title + "</a>";
       text += "</b><br><br><table width=''100%'' cellspacing=''1'' cellpadding=''1'' border=''1''>";

       var $rows = $(this).find(''table.tabledata'').find(''tr.'' + sigId);

       $rows.each(function(){
          if ($(this).hasClass("tdata")) {
             text += "<tr bgcolor=''#f7f7e7''>" + $(this).html() + "</tr>";
          } else {
             /*replace background color for the header*/
             text += "<tr bgcolor=''#f7f7e7''>" + $(this).html().replace(/\#f2f4f7/g, "#cccc99") + "</tr>";
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
}

</script>

');
     print_out('</HEAD><BODY>');

EXCEPTION WHEN OTHERS THEN
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

    -- Print logo image
    print_out('        <div class="header_img">
        ');
    print_out('<img src="data:image/png;base64,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', 'N');
    print_out('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', 'N');
    print_out('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', 'N');
    print_out('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', 'N');
    print_out('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', 'N');
    print_out('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', 'N');
    print_out('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', 'N');
    print_out('PHcYE8z3McX78t1cnJCXYXQm1AAORPdCD/Tp0rGGN1xa+NCDWZDatEkWC32eGw22AAQBwHOwAdzzFpl7D7gjufjmFiRUUFvLy8VzcIsicRFVZUaDZb6+qovLwcAoCq6uq/hep/Cf0XtNFmA3zXn6gAAAAASUVORK5CYII=" title="Click here to see other helpful Oracle Proactive Tools" alt="Proactive Services Banner">');
    print_out('        </div>', 'Y');

-- page title
    print_out('        <div class="header_title">EBS '||p_analyzer_title|| ' Analyzer Report <br>
        <span class="header_subtitle">Compiled using version '||g_rep_info('File Version')||'
        <span class="whatsnew_ico" title="What''s New" border="none" data-popup-open="popup-3"></span>
        <span class="header_subtitle"> / Latest version:</span>
        <a href="https://support.oracle.com/oip/faces/secure/km/DownloadAttachment.jspx?attachid=2295096.1:SCRIPT">
        <img class="header_version" src="https://www.oracle.com/webfolder/s/analyzer/om_agreement_latest_version.gif" title="Click here to download the latest version of Analyzer" alt="Latest Version Icon"></a>');
    print_cloud_image;
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
    print_out('<div class="menubutton" id="feedback" title="Opens the Oracle Community feedback thread"><a href="https://community.oracle.com/thread/4090561" class="blacklink" target="new">
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
-- Prints What's New pop-up window                            --
----------------------------------------------------------------
PROCEDURE print_whatsnew IS

BEGIN
    print_out('       <!-- print Whats New pop-up window -->
       <div class="popup" data-popup="popup-3">
            <div class="popup-inner" style="padding:15px">
            <b><br>&nbsp;&nbsp;What''s new in this release:</b><br><br>
<div>
<div>We&rsquo;re listening to your feedback and made the following changes:</div>

<ul>
	<li>Template Changes (4.2.3): Includes bug fixes for:<br />
	&nbsp;&nbsp; Broken output when NO_DATA_FOUND in process_signature_results()<br />
	&nbsp;&nbsp; Change dynamic SQL counting<br />
	&nbsp;&nbsp;&nbsp;Should shorten analyzer running time, as we have dropped the record counting when the result set is limited.</li>
</ul>
</div>

<div>&nbsp;</div>

<ul>
</ul>

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
BEGIN
  g_sections.delete;

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
                          <span id="start_time"></span>
                        </td>
                     </tr>');
  print_out('                       <tr>
                        <td class="popup-paramname"><b>End time:</b></td>
                        <td class="popup-paramval">
                          <span id="end_time"></span>
                        </td>
                     </tr>');
  print_out('                       <tr>
                        <td class="popup-paramname"><b>Execution time:</b></td>
                        <td class="popup-paramval">
                          <span id="exec_time"></span>
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
                <tr><td><div open-section="E" class="menuboxitem"><span class=''error_ico icon''></span><div class="mboxelem">Errors</div></div></td>
                <td align="right"><span class="errcount">'||g_results('E')||'</span></td></tr>
                <tr><td><div open-section="W" class="menuboxitem"><span class=''warn_ico icon''></span><div class="mboxelem">Warnings</div></div></td>
                <td align="right"><span class="warncount">'||g_results('W')||'</span></td></tr>
                <tr><td><div open-section="S" class="menuboxitem"><span class=''success_ico icon''></span><div class="mboxelem">Passed Checks</div></div></td>
                <td align="right"><span class="successcount">'||g_results('S')||'</span></td></tr>
                <tr><td><div open-section="I" class="menuboxitem"><span class=''information_ico icon''></span><div class="mboxelem">Informational</div></div></td>
                <td align="right"><span class="infocount">'||g_results('I')||'</span></td></tr>
                <tr><td><div open-sig-class="passed" class="menuboxitem"><span class=''proc_success_small icon''></span><div class="mboxelem">Passed Checks</div><br><div style="font-size:small;">(not shown in main report)</div></div></td>
                <td align="right"><span class="infocount">'||g_results('P')||'</span></td></tr>
                </tbody></table>
              </div>
            </td>
            <td>');

    print_out('
                <table>
                <tr>');

    FOR i in 1 .. l_loop_count LOOP
        l_section_id := replace_chars(g_sec_detail(i).name);
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
                  <span><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=1549983.1" target="_blank" class="blacklink">About Oracle Proactive Support</a></span>
                  <span class="separator"></span>
                  <span><a href="https://support.oracle.com/epmos/faces/SrCreate" target="_blank" class="blacklink">Log a Service Request</a></span>
                  <span class="separator"></span>');
   -- just to be sure there is no error while getting the family area code
   BEGIN
   print_out('
                  <span><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=1545562.1#' || nvl(g_fam_area_hash(nvl(g_family_area, 'ATG')), '') || '" target="_blank"');

   EXCEPTION WHEN OTHERS THEN
   print_out('
                  <span><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=1545562.1" target="_blank"');
   END;
   print_out('
                  class="blacklink">Related Analyzers</a></span>
                  <span class="separator"></span>
                  <span><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=1939637.1" target="_blank" class="blacklink">Analyzer Bundle Menu Tool</a></span>
                  <span class="separator"></span>
                  <span><a href="http://www.oracle.com/us/legal/privacy/overview/index.html" target="_blank" class="blacklink">Your Privacy Rights</a></span>
                  <span class="separator"></span>
                  <span><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=2116869.1" target="_blank" class="blacklink">Frequently Asked Questions</a></span>
               </div>
           </div>
       </div><!-- end footer area -->
     </div><!-- end main div -->
   ');
EXCEPTION WHEN OTHERS THEN
  print_log('Error in print_footer: '||sqlerrm);
  raise;
END print_footer;

----------------------------------------------------------------
-- Print execution times in the Execution Details page        --
----------------------------------------------------------------

PROCEDURE print_execution_time (l_time TIMESTAMP) IS
BEGIN

  print_out('        <script>
            $("#start_time").text("'||to_char(g_analyzer_start_time,'hh24:mi:ss.ff3')||'");
        </script>');
  print_out('        <script>
            $("#end_time").text("'||to_char(l_time,'hh24:mi:ss.ff3')||'");
        </script>');
  print_out('        <script>
            $("#exec_time").text("'||format_elapsed(g_analyzer_elapsed)||'");
        </script>');


END print_execution_time;

----------------------------------------------------------------
-- Evaluates if a rowcol meets desired criteria               --
----------------------------------------------------------------

FUNCTION evaluate_rowcol(p_oper varchar2, p_val varchar2, p_colv varchar2) return boolean is
  x   NUMBER;
  y   NUMBER;
  n   boolean := true;
BEGIN
  -- Attempt to convert to number the column value, otherwise proceed as string
  BEGIN
    x := to_number(p_colv);
    y := to_number(p_val);
  EXCEPTION WHEN OTHERS THEN
    n := false;
  END;
  -- Compare
  IF p_oper = '=' THEN
    IF n THEN
      return x = y;
    ELSE
      return p_val = p_colv;
    END IF;
  ELSIF p_oper = '>' THEN
    IF n THEN
      return x > y;
    ELSE
      return p_colv > p_val;
    END IF;
  ELSIF p_oper = '<' THEN
    IF n THEN
      return x < y;
    ELSE
      return p_colv < p_val;
    END IF;
  ELSIF p_oper = '<=' THEN
    IF n THEN
      return x <= y;
    ELSE
      return p_colv <= p_val;
    END IF;
  ELSIF p_oper = '>=' THEN
    IF n THEN
      return x >= y;
    ELSE
      return p_colv >= p_val;
    END IF;
  ELSIF p_oper = '!=' OR p_oper = '<>' THEN
    IF n THEN
      return x != y;
    ELSE
      return p_colv != p_val;
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in evaluate_rowcol');
  raise;
END evaluate_rowcol;


---------------------------------------------
-- Expand [note] or {patch} tokens         --
---------------------------------------------

FUNCTION expand_links(p_str VARCHAR2, p_sigrepo_id VARCHAR2 DEFAULT '') return VARCHAR2 IS
  l_str VARCHAR2(32767);
  l_substr VARCHAR2(16);
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

---------------------------------------------------------------------
-- Populate user and respo details when running as conc request    --
---------------------------------------------------------------------

PROCEDURE populate_user_details IS
    l_user_name   fnd_user.user_name%type := fnd_global.user_name ;
    l_resp_name   VARCHAR2(256) := fnd_global.resp_name ;
BEGIN

   g_rep_info('Username') := l_user_name;
   g_rep_info('Responsibility') := l_resp_name;

EXCEPTION WHEN OTHERS THEN
  debug ('Exception in populate_user_details: '||SQLERRM);
END populate_user_details;


------------------------------------------------------
-- Prepare the SQL with the substitution values     --
------------------------------------------------------

FUNCTION prepare_text(
  p_raw_text IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_formatted_text  VARCHAR2(32767);
  l_key             VARCHAR2(255);
BEGIN
  -- Assign signature to working variable
  l_formatted_text := p_raw_text;
  --  Build the appropriate SQL replacing all applicable values
  --  with the appropriate parameters
  l_key := g_sql_tokens.first;
  WHILE l_key is not null LOOP
    l_formatted_text := replace(l_formatted_text, l_key, g_sql_tokens(l_key));
    l_key := g_sql_tokens.next(l_key);
  END LOOP;
  RETURN l_formatted_text;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in prepare_text');
  raise;
END prepare_text;


----------------------------------------------------------
-- Prepare the SQL and remove references to FK strings  --
----------------------------------------------------------

FUNCTION prepare_SQL(p_raw_SQL IN VARCHAR2)
   RETURN VARCHAR2
   IS
   l_modified_SQL  VARCHAR2(32767);
BEGIN
   l_modified_SQL := p_raw_SQL;
   l_modified_SQL := regexp_replace(l_modified_SQL, '\S+\s+"#{2}\${2}FK[0-9]\${2}#{2}"\s*,\s*', ' ');
   l_modified_SQL := regexp_replace(l_modified_SQL, ',\s*\S+\s+"#{2}\${2}FK[0-9]\${2}#{2}"\s*', ' ');
   return prepare_text(l_modified_SQL);
EXCEPTION WHEN OTHERS THEN
   print_log('Error in print_SQL');
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
   p_raw_sql      IN  VARCHAR2,     -- SQL in the signature may require substitution
   p_col_rows     OUT COL_LIST_TBL, -- signature SQL column names
   p_col_headings OUT VARCHAR_TBL,  -- signature SQL row values
   p_limit_rows   IN  VARCHAR2 DEFAULT 'Y') RETURN BOOLEAN IS

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
  -- Prepare the Signature SQL
  l_step := '10';
  l_sql := prepare_text(p_raw_sql);
  -- Add SQL with substitution to attributes table
  l_step := '20';
  get_current_time(g_query_start_time);

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
	-- removed initCap per Standardization team in 3.0.35
    l_col_headings(i) := replace(l_desc_rec_tbl(i).col_name,'|','<br>');
    l_col_rows.extend();
    dbms_sql.define_array(c, i, l_col_rows(i), g_max_output_rows, 1);
  END LOOP;
  -- Execute and Fetch
  l_step := '60';
  get_current_time(g_query_start_time);

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
  debug(' Rows fetched: '||to_char(l_total_rows));
  g_query_elapsed := stop_timer(g_query_start_time);
  -- Close cursor
  l_step := '80';
  IF dbms_sql.is_open(c) THEN
    dbms_sql.close_cursor(c);
  END IF;
  -- Set out parameters
  p_col_headings := l_col_headings;
  p_col_rows := l_col_rows;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    print_error('PROGRAM ERROR<br />
      Error in run_sig_sql at step '||
      l_step||': '||sqlerrm||'<br/>
      See the log file for additional details<br/>');
    print_log('Error at step '||l_step||' in run_sig_sql running: '||l_sql);
    print_log('Error: '||sqlerrm);
    l_col_cnt := -1;
    IF dbms_sql.is_open(c) THEN
      dbms_sql.close_cursor(c);
    END IF;
    g_errbuf := 'toto '||l_step;
    RETURN FALSE;
END run_sig_sql;

PROCEDURE generate_hidden_xml(
  p_sig_id          VARCHAR2,
  p_sig             SIGNATURE_REC, -- Name of signature item
  p_col_rows        COL_LIST_TBL,  -- signature SQL row values
  p_col_headings    VARCHAR_TBL,   -- signature SQL column names
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
l_start_flag           BOOLEAN := FALSE;


BEGIN

IF g_dx_summary_error IS NOT NULL THEN
   return;
END IF;

l_hidden_xml_doc := g_hidden_xml;

IF (XMLDOM.isNULL(l_hidden_xml_doc)) THEN
   l_hidden_xml_doc := XMLDOM.newDOMDocument;
   l_hidden_xml_node := XMLDOM.makeNode(l_hidden_xml_doc);
   l_diagnostic_node := XMLDOM.appendChild(l_hidden_xml_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'diagnostic')));

   l_run_details_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'run_details')));
   l_key := g_rep_info.first;
   WHILE l_key IS NOT NULL LOOP

     l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
     l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
     l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
     XMLDOM.setAttribute(l_detail_element, 'name', l_key);
     IF g_rep_info(l_key) IS NOT NULL THEN
        l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,g_rep_info(l_key))));
     END IF;

     l_key := g_rep_info.next(l_key);

   END LOOP;
   -- add cloud check
   l_detail_element := XMLDOM.createElement(l_hidden_xml_doc,'detail');
   l_detail_node := XMLDOM.appendChild(l_run_details_node,XMLDOM.makeNode(l_detail_element));
   l_detail_name_attribute:=XMLDOM.setAttributeNode(l_detail_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
   XMLDOM.setAttribute(l_detail_element, 'name', 'Cloud');
   IF g_cloud_flag THEN
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'Y')));
   ELSE
      l_node := XMLDOM.appendChild(l_detail_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,'N')));
   END IF;

   l_parameters_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'parameters')));
   FOR i IN 1..g_parameters.COUNT LOOP
     l_parameter_element := XMLDOM.createElement(l_hidden_xml_doc,'parameter');
     l_parameter_node := XMLDOM.appendChild(l_parameters_node,XMLDOM.makeNode(l_parameter_element));
     l_param_name_attribute:=XMLDOM.setAttributeNode(l_parameter_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
     XMLDOM.setAttribute(l_parameter_element, 'name', to_char(i) || '. ' ||g_parameters(i).pname);

     IF g_parameters(i).pvalue IS NOT NULL THEN
        l_node := XMLDOM.appendChild(l_parameter_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,g_parameters(i).pvalue)));
     END IF;

   END LOOP;

   l_issues_node := XMLDOM.appendChild(l_diagnostic_node,XMLDOM.makeNode(XMLDOM.createElement(l_hidden_xml_doc,'issues')));

END IF;


 IF p_sig_id IS NOT NULL THEN

   IF (p_parent_sig_id IS NOT NULL) AND (p_sig.include_in_xml='P') THEN
       IF ((g_dx_printed.EXISTS(p_parent_sig_id)) AND (nvl(g_dx_printed(p_parent_sig_id), 0) = 1)) THEN  -- if this is a child, has P flag and has been printed before, return
           RETURN;
       ELSE
           g_dx_printed(p_parent_sig_id) := 1;
       END IF;
   END IF;

   l_issues_node := XMLDOM.getLastChild(XMLDOM.getFirstChild(XMLDOM.makeNode(l_hidden_xml_doc)));

   l_signature_element := XMLDOM.createElement(l_hidden_xml_doc,'signature');
   l_sig_id_attribute := XMLDOM.setAttributeNode(l_signature_element,XMLDOM.createAttribute(l_hidden_xml_doc,'id'));
   l_signature_node := XMLDOM.appendChild(l_issues_node,XMLDOM.makeNode(l_signature_element));
   XMLDOM.setAttribute(l_signature_element, 'id',p_sig_id);

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

   -- if the DX flag is Y or D, print all the details
   IF (p_sig.include_in_xml in ('Y', 'D')) THEN

      IF p_sig.limit_rows='Y' THEN
         l_rows := least(g_max_output_rows,p_col_rows(1).COUNT,50);
      ELSE
         l_rows := least(p_col_rows(1).COUNT,50);
      END IF;

      FOR i IN 1..l_rows LOOP

         l_failure_element := XMLDOM.createElement(l_hidden_xml_doc,'failure');
         l_row_attribute := XMLDOM.setAttributeNode(l_failure_element,XMLDOM.createAttribute(l_hidden_xml_doc,'row'));
         l_failure_node := XMLDOM.appendChild(l_signature_node,XMLDOM.makeNode(l_failure_element));
         XMLDOM.setAttribute(l_failure_element, 'row', i);

         FOR j IN 1..p_col_headings.count LOOP

            l_col_element := XMLDOM.createElement(l_hidden_xml_doc,'column');
            l_col_name_attribute := XMLDOM.setAttributeNode(l_col_element,XMLDOM.createAttribute(l_hidden_xml_doc,'name'));
            l_col_node := XMLDOM.appendChild(l_failure_node,XMLDOM.makeNode(l_col_element));
            XMLDOM.setAttribute(l_col_element, 'name',p_col_headings(j));

            BEGIN
                BEGIN
                    l_value := p_col_rows(j)(i);
                END;
             EXCEPTION -- there might be an exception when the value is too big
               WHEN VALUE_ERROR THEN
                    l_value := substr(p_col_rows(j)(i), 1, 4000);
            END;

            IF p_sig_id = 'REC_PATCH_CHECK' THEN
               IF p_col_headings(j) = 'Patch' THEN
                  l_value := replace(replace(p_col_rows(j)(i),'{'),'}');
               ELSIF p_col_headings(j) = 'Note' THEN
                  l_value := replace(replace(p_col_rows(j)(i),'['),']');
               END IF;
            END IF;

            -- Rtrim the column value if blanks are not to be preserved
            IF NOT g_preserve_trailing_blanks THEN
               l_value := RTRIM(l_value, ' ');
            END IF;

            IF l_value IS NOT NULL THEN
               l_node := XMLDOM.appendChild(l_col_node,XMLDOM.makeNode(XMLDOM.createTextNode(l_hidden_xml_doc,l_value)));
            END IF;

          END LOOP;

       END LOOP;

     END IF;  --p_sig.include_in_xml='Y'

  END IF;

  g_hidden_xml := l_hidden_xml_doc;

EXCEPTION
   WHEN OTHERS THEN
      g_dx_summary_error := '<DXSUMMGENERR><![CDATA['||SQLERRM||']]></DXSUMMGENERR>';
      print_log('DX Summary generation error: '||SQLERRM);

END generate_hidden_xml;


PROCEDURE print_hidden_xml
IS

l_hidden_xml_clob      clob;
l_offset               NUMBER := 1;
l_length               NUMBER;

l_node_list            XMLDOM.DOMNodeList;
l_node_length          NUMBER;

BEGIN

IF g_dx_summary_error IS NOT NULL THEN
   print_out('<!-- ######BEGIN DX SUMMARY######','Y');
   print_out(g_dx_summary_error);
   print_out('######END DX SUMMARY######-->','Y');
   print_out('<div style="display:none;" id="integrityCheck"></div>'); -- this is for integrity check
   g_dx_summary_error:=null;
   return;
END IF;

IF XMLDOM.isNULL(g_hidden_xml) THEN

   generate_hidden_xml(p_sig_id => null,
                       p_sig => null,
                       p_col_headings => null,
                       p_col_rows => null);

END IF;

dbms_lob.createtemporary(l_hidden_xml_clob, true);

--print CLOB
XMLDOM.WRITETOCLOB(g_hidden_xml, l_hidden_xml_clob);

print_out('<!-- ######BEGIN DX SUMMARY######','Y');

LOOP
   EXIT WHEN (l_offset > dbms_lob.getlength(l_hidden_xml_clob) OR dbms_lob.getlength(l_hidden_xml_clob)=0);

      print_out(dbms_lob.substr(l_hidden_xml_clob,2000, l_offset),'N');

      l_offset := l_offset + 2000;

   END LOOP;

print_out('######END DX SUMMARY######-->','Y');  --should be a newline here
print_out('<div style="display:none;" id="integrityCheck"></div>'); -- this is for integrity check

dbms_lob.freeTemporary(l_hidden_xml_clob);
XMLDOM.FREEDOCUMENT(g_hidden_xml);

EXCEPTION
   WHEN OTHERS THEN
      print_log('Error in print_hidden_xml: '||SQLERRM);

END print_hidden_xml;

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
   IF (p_style_string = '') THEN
       print_log ('Formatting string is empty!');
       return '';
   END IF;

   BEGIN
       l_styles('text-align') := substr(p_style_string, 1, instr(p_style_string, ',', 1, 1) - 1);
       l_styles('color') := substr(p_style_string, instr(p_style_string, ',', 1, 1) + 1, instr(p_style_string, ',', 1, 2) - instr(p_style_string, ',', 1, 1) - 1);
       l_styles('background-color') := substr(p_style_string, instr(p_style_string, ',', 1, 2) + 1, instr(p_style_string, ',', 1, 3) - instr(p_style_string, ',', 1, 2) - 1);
       l_styles('font-weight') := substr(p_style_string, instr(p_style_string, ',', 1, 3) + 1);
   EXCEPTION
      WHEN OTHERS THEN
          print_log('Exception while extracting the format details!'|| SQLERRM);
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
   print_log('Exception when formatting the column!' || SQLERRM);
   return '';
END get_style;


------------------------------------------------------------------
-- For signatures that have print condition set to failure      --
-- and are successful, print partial details on a separate page --
------------------------------------------------------------------
PROCEDURE print_partial(
  p_sig_id          VARCHAR2,      -- signature id
  p_sig             SIGNATURE_REC  -- Name of signature item
  ) IS

  l_current_sig   VARCHAR2(6) := '';
  l_html          VARCHAR2(32767) := '';
  l_i             VARCHAR2(255);
  l_step          VARCHAR(260) := '';
BEGIN
    -- generate internal sig id
    l_current_sig := 'S'||to_char(g_sig_count);  --build signature class name
    l_step := '10';
    l_html := '
<!-- '||l_current_sig||' -->
               <div class="data sigcontainer signature P '||l_current_sig||'" level="1"  id="'||l_current_sig||'" style="display: none;">
                    <div class="divItemTitle">
                        <div class="sigdescription" style="display:inline;"><table style="display:inline;"><tr class="P '||l_current_sig||' sigtitle"><td class="divItemTitlet">'||prepare_text(p_sig.title)||'</td></tr></table></div>
                        <a class="detailsmall" toggle-info="tbitm_'||l_current_sig||'"><span class="siginfo_ico" title="Show signature information" alt="Show Info"></span></a>
                    </div>';

    print_out(l_html);
    l_html := '';
    l_step := '30';

  -- Print collapsable/expandable extra info table if there are contents
    IF p_sig.extra_info.count > 0 OR p_sig.sig_sql is not null THEN
        l_step := '40';
        l_html := '
                        <table class="table1 data" id="tbitm_' || l_current_sig || '" style="display:none">
                        <thead>
                           <tr><th bgcolor="#f2f4f7" class="sigdetails">Item Name</th><th bgcolor="#f2f4f7" class="sigdetails">Item Value</th></tr>
                        </thead>
                        <tbody>';
        print_out(l_html);
        l_html := '';
        -- Loop and print values
        l_step := '50';
        l_i := p_sig.extra_info.FIRST;
        WHILE (l_i IS NOT NULL) LOOP
          l_step := '60.'||l_i;
          -- don't print the extra info that starts wiht ## (these are hidden)
          IF (NOT regexp_like(l_i,'^##')) THEN
              l_html := l_html || '                           <tr><td>' || l_i || '</td><td>'||
                 p_sig.extra_info(l_i) || '</td></tr>';
          END IF;
          l_step := '60.'||l_i;
          l_i := p_sig.extra_info.next(l_i);
        END LOOP;
        print_out(l_html);
        l_html := '';
        l_step := '65';
        -- print SQL only if SHOW_SQL != 'N' and the SQL string is not null
        IF ((p_sig.sig_sql is not null) AND ((NOT p_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (p_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(p_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
            l_step := '70';
            l_html := l_html || '
                              <tr><td>SQL</td><td><pre>'|| prepare_SQL(escape_html_chars(p_sig.sig_sql)) ||
               '</pre></td></tr>';
        END IF;
        l_html := l_html || '
                    </tbody>
                    </table>';
    END IF;

      l_html := l_html || '
                </div>';
      l_step := '90';
      print_out(l_html);
      l_html := '';

      l_step := '100';
      IF p_sig.success_msg is not null THEN
          l_html := '
            <div class="divok data P"><div class="divok1"><span class="check_ico"></span> All checks passed.</div>' ||
             prepare_text(expand_links(p_sig.success_msg,p_sig.sigrepo_id));
          l_html := l_html || '
                      </div> <!-- end results div -->';
          print_out(l_html);
      END IF;

      return;
  EXCEPTION
     WHEN OTHERS THEN
          print_log('Exception in print_partial at step ' || l_step);
          print_log('Exception details: ' ||SQLERRM);
END print_partial;


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
  p_class_string    VARCHAR2    DEFAULT NULL
  ) RETURN VARCHAR2 IS             -- returns 'E','W','S','I'

  l_sig_fail      BOOLEAN := false;
  l_row_fail      BOOLEAN := false;
  l_fail_flag     BOOLEAN := false;
  l_html          VARCHAR2(32767) := null;
  l_column        VARCHAR2(255) := null;
  l_operand       VARCHAR2(3);
  l_value         VARCHAR2(4000);
  l_step          VARCHAR2(255);
  l_i             VARCHAR2(255);
  l_curr_col      VARCHAR2(255) := NULL;
  l_curr_val      VARCHAR2(4000) := NULL;
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
  l_run_result      BOOLEAN;
  l_sig_result      VARCHAR2(1);
BEGIN
  -- Validate parameters which have fixed values against errors when
  -- defining or loading signatures

    l_current_section := replace_chars(g_sec_detail(g_sec_detail.COUNT).name);
    g_sig_count := g_sig_count + 1;
    l_current_sig := 'S'||to_char(g_sig_count);  --build signature class name

  -- if p_sig_suffix is not null, then this ia a child signature and we should append the id with the parent row count, so it will be unique
  IF (p_sig_suffix IS NOT NULL) THEN
      l_current_sig := l_current_sig || to_char(p_sig_suffix);
  END IF;

  IF (p_sig.fail_condition NOT IN ('RSGT1','RS','NRS')) AND
     ((instr(p_sig.fail_condition,'[') = 0) OR
      (instr(p_sig.fail_condition,'[',1,2) = 0) OR
      (instr(p_sig.fail_condition,']') = 0) OR
      (instr(p_sig.fail_condition,']',1,2) = 0))  THEN
    print_log('Invalid value or format for failure condition: '||
      p_sig.fail_condition);
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
      p_sig.print_condition||'/'||nvl(p_sig.success_msg,'null')||
      '/'||p_sig.print_sql_output);
    print_log('When printing on success either success msg or SQL output '||
        'printing should be enabled.');
    raise l_inv_param;
  END IF;

  l_print_sql_out := (nvl(p_sig.print_sql_output,'Y') = 'Y' OR
                     (p_sig.print_sql_output = 'RSGT1' AND l_rows_fetched > 1) OR
                     (p_sig.print_sql_output = 'RS' AND l_rows_fetched > 0) OR
                      p_sig.child_sigs.count > 0 AND l_rows_fetched > 0);

  -- Determine signature failure status
  IF p_sig.fail_condition NOT IN ('RSGT1','RS','NRS') THEN
    -- Get the column to evaluate, if any
    l_step := '20';
    l_column := upper(substr(ltrim(p_sig.fail_condition),2,instr(p_sig.fail_condition,']') - 2));
    l_operand := rtrim(ltrim(substr(p_sig.fail_condition, instr(p_sig.fail_condition,']')+1,
      (instr(p_sig.fail_condition,'[',1,2)-instr(p_sig.fail_condition,']') - 1))));
    l_value := substr(p_sig.fail_condition, instr(p_sig.fail_condition,'[',2)+1,
      (instr(p_sig.fail_condition,']',1,2)-instr(p_sig.fail_condition,'[',1,2)-1));

    l_step := '30';
    FOR i IN 1..least(l_rows_fetched, g_max_output_rows) LOOP
      l_step := '40';
      FOR j IN 1..p_col_headings.count LOOP
        l_step := '40.1.'||to_char(j);
        l_row_fail := false;
        l_curr_col := upper(p_col_headings(j));
        l_curr_val := p_col_rows(j)(i);
        IF nvl(l_column,'&&&') = l_curr_col THEN
          l_step := '40.2.'||to_char(j);
          l_row_fail := evaluate_rowcol(l_operand, l_value, l_curr_val);
          IF l_row_fail THEN
            l_fail_flag := true;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  END IF;

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
                         p_parent_sig_id => p_parent_id);
  END IF;

  -- If success and no print just return
  l_step := '60';
  IF ((NOT l_sig_fail) AND p_sig.print_condition IN ('FAILURE','NEVER')) THEN
    IF p_sig.fail_type = 'I' THEN
      return 'I';
    ELSE
    -- Before returning, populate the processed-successfully data
       IF (p_parent_id IS NULL) THEN
           g_results('P') := g_results('P') + 1;
           print_partial(p_sig_id, p_sig);
       END IF;
       return 'S';
    END IF;
  ELSIF (l_sig_fail AND (p_sig.print_condition IN ('SUCCESS','NEVER'))) THEN
    return p_sig.fail_type;
-- if the sig is set as "Print in DX only" then return
  ELSIF (p_sig.include_in_xml = 'D') THEN
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

   -- Print container and title
  l_html := '
<!-- '||l_current_sig||' -->
               <div class="data sigcontainer signature '||l_current_section||' '||l_current_sig||' '|| p_class_string || ' ' || g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||' section print analysis" level="'||to_char(g_level)||'"  id="'||l_current_sig||'" style="display: none;">
                    <div class="divItemTitle">
                        <input type="checkbox" rowid="'||l_current_sig||'" class="exportcheck data print">';

   l_html := l_html || '
                        <a class="detail" toggle-data="restable_'||l_current_sig||'">
                           <div class="arrowright data section fullsection print analysis">&#9654;</div><div class="arrowdown data" style="display: none">&#9660;</div>
                           <div class="sigdescription" style="display:inline;"><table style="display:inline;"><tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||' sigtitle"><td class="divItemTitlet">'||prepare_text(p_sig.title)||'</td></tr></table></div>
                        </a>';
    -- CG Review this condition
    IF p_sig.extra_info.count > 0 OR p_sig.sig_sql is not null THEN
        l_html := l_html || '
                        <a class="detailsmall" toggle-info="tbitm_'||l_current_sig||'"><span class="siginfo_ico" title="Show signature information" alt="Show Info"></span></a>';
    END IF;
    l_html := l_html || '
                        <a class="detailsmall" href="javascript:;" onclick=''export2PaddedText("'||l_current_sig||'");return false;''><span class="export_txt_ico" title="Export to .txt" alt="Export to .txt"></span></a>
                        <a class="detailsmall" href="javascript:;" onclick=''export2CSV("'||l_current_sig||'")''><span class="export_ico" title="Export to .csv" alt="Export to .csv"></span></a>';
    -- add sort icon for non-parents sigs and only when more than 1 record is retrieved (it doesn't make any sense to sort a single record)
    IF ((p_sig.child_sigs.count = 0) AND (l_rows_fetched > 1) AND (l_print_sql_out)) THEN
        l_html := l_html || '
                        <a class="detailsmall"><span class="sort_ico" table-name='||l_current_sig||' title="Sort table" alt="Sort table"></span></a>';
    END IF;
    l_html := l_html || '
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
          l_html := l_html || '                           <tr><td>' || l_i || '</td><td>'||
             p_sig.extra_info(l_i) || '</td></tr>';
      END IF;
      l_step := '110.2.'||l_i;
      l_i := p_sig.extra_info.next(l_i);
    END LOOP;
    -- print SQL only if SHOW_SQL != 'N' and the SQL string is not null
    IF ((p_sig.sig_sql is not null) AND ((NOT p_sig.extra_info.EXISTS('##SHOW_SQL##')) OR (p_sig.extra_info.EXISTS('##SHOW_SQL##')) AND (nvl(p_sig.extra_info('##SHOW_SQL##'), 'Y') != 'N'))) THEN
      l_step := '120';
      l_html := l_html || '
                        <tr><td>SQL</td><td><pre>'|| prepare_SQL(escape_html_chars(p_sig.sig_sql)) ||
         '</pre></td></tr>';
    END IF;

    -- number of records retrieved and elapsed time
    l_html := l_html ||'<tr><td>Number of rows:</td><td>';
      IF p_sig.limit_rows = 'N' OR l_rows_fetched < g_max_output_rows THEN
        l_html := l_html || l_rows_fetched || ' rows selected';
      ELSE
        l_html := l_html ||'The resultset is limited to '||to_char(g_max_output_rows)||' rows. For a complete list of records, please run the query directly in the database.';
      END IF;
      l_html := l_html ||'</td></tr><tr><td>';
      l_html := l_html ||'Elapsed time:</td><td>' || format_elapsed(g_query_elapsed) || '</td></tr>';
      l_html := l_html || '
                    </tbody>
                    </table>';
  END IF;

  l_step := '140';

  -- Print the header SQL info table
  print_out(expand_links(l_html, p_sig.sigrepo_id));
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
                    <table class="table1 data tabledata" id="restable_'||l_current_sig||'" style="display:none">
                    <thead>';
      ELSE
           l_html := l_html || '
                    <table class="table1 data tabledata" id="restable_'||l_current_sig||'" style="display:none">
                    <thead>';
      END IF;

      -- Column headings
      l_html := l_html || '
                        <tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';

      print_out(l_html);
      l_html := '';
      l_step := '160';
      FOR i IN 1..p_col_headings.count LOOP
         IF upper(nvl(p_col_headings(i),'XXX')) not like '##$$FK_$$##' THEN
            -- Encode blanks as HTML space if this analyzer is set so by g_preserve_trailing_blanks
            -- this ensures trailing blanks added for padding are honored by browsers
            -- affects only printing, DX summary handled separately
             IF g_preserve_trailing_blanks THEN
               l_html := l_html ||'
                                 <th bgcolor="#f2f4f7" class="sigdetails">'||RPAD(RTRIM(p_col_headings(i),' '),
            -- pad length is the number of spaces existing times the length of &nbsp; => 6
             (length(p_col_headings(i)) - length(RTRIM(p_col_headings(i),' '))) * 6
             + length(RTRIM(p_col_headings(i),' ')),'&nbsp;') ||'</th>';
             ELSE
               l_html := l_html || '
                                 <th bgcolor="#f2f4f7" class="sigdetails">'||nvl(p_col_headings(i),'&nbsp;')||'</th>';
             END IF;
             -- if the html buffer is already larger than the limit, spool the content and reset
             IF (LENGTH(l_html) > 32000) THEN
                 print_out(expand_links(l_html, p_sig.sigrepo_id));
                 l_html := '';
             END IF;
         END IF;
      END LOOP;
      l_html := l_html || '
                        </tr>
                    </thead>
                    <tbody>';
      -- Print headers
      print_out(expand_links(l_html, p_sig.sigrepo_id));
      -- Row values
      l_step := '170';
      FOR i IN 1..l_rows_fetched LOOP
        l_html := '                        <tr class="tdata '||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';
        l_step := '170.1.'||to_char(i);
        FOR j IN 1..p_col_headings.count LOOP
          -- Evaluate if necessary
          l_step := '170.2.'||to_char(j);
          l_row_fail := false;
          l_step := '170.3.'||to_char(j);
          l_curr_col := upper(p_col_headings(j));
          l_step := '170.4.'||to_char(j);
          l_curr_val := p_col_rows(j)(i);
          l_step := '170.5.'||to_char(j);
          IF nvl(l_column,'&&&') = l_curr_col THEN
            l_step := '170.6.'||
              substr('['||l_operand||']['||l_value||']['||l_curr_val||']',1,96);
            l_row_fail := evaluate_rowcol(l_operand, l_value, l_curr_val);
          END IF;

          IF (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col)) AND (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col) IS NOT NULL) THEN
              l_style := get_style(p_sig.extra_info('##STYLE##'||l_curr_col));
          ELSE
              l_style := '';
          END IF;

          -- Encode blanks as HTML space if this analyzer is set so by g_preserve_trailing_blanks
          -- this ensures trailing blanks added for padding are honored by browsers
          -- affects only printing, DX summary handled separately
          IF g_preserve_trailing_blanks THEN
            l_curr_Val := RPAD(RTRIM(l_curr_Val,' '),
             -- pad length is the number of spaces existing times the length of &nbsp; => 6
            (length(l_curr_Val) - length(RTRIM(l_curr_Val,' '))) * 6 + length(RTRIM(l_curr_Val,' ')),
            '&nbsp;');
          ELSE
            l_curr_Val := RTRIM(l_curr_Val, ' ');
          END IF;

          -- Print
          l_step := '170.7.'||to_char(j);
          IF upper(nvl(p_col_headings(j),'XXX')) not like '##$$FK_$$##' THEN
             DECLARE
                l_cell_text VARCHAR2(4200) := '';
             BEGIN

                  IF (g_dest_to_source.EXISTS(p_sig_id)) AND (g_dest_to_source(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_dest_to_source(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                        l_cell_text := '<a class="anchor" id="'|| g_dest_to_source(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '">' || l_curr_val || '</a>';
                  ELSIF (g_source_to_dest.EXISTS(p_sig_id)) AND (g_source_to_dest(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_source_to_dest(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                        l_cell_text := '<a href="" siglink="'|| g_source_to_dest(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '">' || l_curr_val || '</a>';
                        l_cell_text := l_cell_text || '<span class="brokenlink" style="display:none;" title="This record does no have a parent"></span>';
                  ELSE
                        l_cell_text := l_curr_val;
                  END IF;

                  IF l_row_fail THEN
                    l_html := l_html || '
                                   <td class="hlt sigdetails" ' || l_style || '>'|| l_cell_text || '</td>';
                  ELSE
                    l_html := l_html || '
                                   <td class="sigdetails" ' || l_style || '>'|| l_cell_text || '</td>';
                  END IF;
             EXCEPTION WHEN OTHERS THEN
                  print_log('Error when populating table data for signature: ' || p_sig_id);
                  print_log('Exception details:' || SQLERRM);
             END;
          END IF;
          -- if the html buffer is already larger than the limit, spool the content and reset
          IF (LENGTH(l_html) > 32000) THEN
              print_out(expand_links(l_html, p_sig.sigrepo_id));
              l_html := '';
          END IF;
        END LOOP;
        l_html := l_html || '
                        </tr>';
        print_out(expand_links(l_html, p_sig.sigrepo_id));
      END LOOP;

      -- End of results and footer
      l_step := '180';
      l_html :=  '
                    </tbody>
                    </table>
                    </div>  <!-- end table data -->';
      l_step := '190';
      print_out(l_html);
--
    ELSE -- there are children signatures
      -- Print master rows and call appropriate processes for the children
      -- Table header
      l_html := '
                    <!-- table that includes the SQL results (data) -->
                    <div class="divtable">';
      l_html := l_html || '
                    <table class="table1 data tabledata" id="restable_'||l_current_sig||'" style="display:none">';

      -- Keep the id of the parent signature to use as anchor in the table of contents
--      g_parent_sig_id := l_current_sig;

      -- Row values
      l_step := '200';
      FOR i IN 1..l_rows_fetched LOOP
        l_step := '200.1'||to_char(i);
        -- Column headings printed for each row
        l_html := l_html || '
                        <tr class="'||l_current_section||' '||l_current_sig||' '||g_sec_detail(g_sec_detail.LAST).sigs(g_sec_detail(g_sec_detail.LAST).sigs.LAST).sig_result ||'">';
        FOR j IN 1..p_col_headings.count LOOP
          l_step := '200.2'||to_char(j);
          IF upper(nvl(p_col_headings(j),'XXX')) not like '##$$FK_$$##' THEN
            l_html := l_html || '
                            <th bgcolor="#f2f4f7" class="sigdetails '||l_current_sig||'">'||nvl(p_col_headings(j),'&nbsp;')||'</th>';
          END IF;
          -- if the html buffer is already larger than the limit, spool the content and reset
          IF (LENGTH(l_html) > 32000) THEN
              print_out(expand_links(l_html, p_sig.sigrepo_id));
              l_html := '';
          END IF;
        END LOOP;
        l_step := '200.3';
        l_html := l_html || '
                        </tr>';
        -- Print headers
        print_out(expand_links(l_html, p_sig.sigrepo_id));
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
          ELSE -- printable column
            l_printing_cols := l_printing_cols + 1;
            -- Evaluate if necessary
            l_row_fail := false;
            IF nvl(l_column,'&&&') = l_curr_col THEN
              l_step := '200.6'||
                substr('['||l_operand||']['||l_value||']['||l_curr_val||']',1,96);
              l_row_fail := evaluate_rowcol(l_operand, l_value, l_curr_val);
            END IF;

            IF (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col)) AND (p_sig.extra_info.EXISTS('##STYLE##'||l_curr_col) IS NOT NULL) THEN
                l_style := get_style(p_sig.extra_info('##STYLE##'||l_curr_col));
            ELSE
                l_style := '';
            END IF;

            -- Encode blanks as HTML space if this analyzer is set so by g_preserve_trailing_blanks
            -- this ensures trailing blanks added for padding are honored by browsers
            -- affects only printing, DX summary handled separately
            IF g_preserve_trailing_blanks THEN
              l_curr_Val := RPAD(RTRIM(l_curr_Val,' '),
               -- pad length is the number of spaces existing times the length of &nbsp; => 6
              (length(l_curr_Val) - length(RTRIM(l_curr_Val,' '))) * 6 + length(RTRIM(l_curr_Val,' ')),
              '&nbsp;');
            ELSE
              l_curr_Val := RTRIM(l_curr_Val, ' ');
            END IF;

            -- Print
          DECLARE
             l_cell_text VARCHAR2(1024) := '';
          BEGIN
               IF (g_dest_to_source.EXISTS(p_sig_id)) AND (g_dest_to_source(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_dest_to_source(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                     l_cell_text := '<a class="anchor" id="'|| g_dest_to_source(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '">' || l_curr_val || '</a>';
               ELSIF (g_source_to_dest.EXISTS(p_sig_id)) AND (g_source_to_dest(p_sig_id).cols.EXISTS(l_curr_col)) AND (g_source_to_dest(p_sig_id).cols(l_curr_col) IS NOT NULL) THEN
                     l_cell_text := '<a href="" siglink="'|| g_source_to_dest(p_sig_id).cols(l_curr_col)||'_'||to_char(l_curr_val)|| '">' || l_curr_val || '</a>';
                     l_cell_text := l_cell_text || '<span class="brokenlink" style="display:none;" title="This record does no have a parent"></span>';
               ELSE
                     l_cell_text := l_curr_val;
               END IF;
               IF l_row_fail THEN
                 l_html := l_html || '
                                <td class="hlt sigdetails" ' || l_style || '>'|| l_cell_text || '</td>';
               ELSE
                 l_html := l_html || '
                                <td class="sigdetails" ' || l_style || '>'|| l_cell_text || '</td>';
               END IF;
          EXCEPTION WHEN OTHERS THEN
               print_log('Error when populating table data for signature: ' || p_sig_id);
          END;
          END IF;
          -- if the html buffer is already larger than the limit, spool the content and reset
          IF (LENGTH(l_html) > 32000) THEN
             print_out(expand_links(l_html, p_sig.sigrepo_id));
             l_html := '';
          END IF;
        END LOOP;

        l_html := l_html || '
                        </tr>';
        print_out(expand_links(l_html, p_sig.sigrepo_id));
        l_html := null;
        FOR k IN p_sig.child_sigs.first..p_sig.child_sigs.last LOOP
          print_out('
                        <tr><td colspan="'||to_char(l_printing_cols)||'"><blockquote>');
          DECLARE
            l_col_rows  COL_LIST_TBL := col_list_tbl();
            l_col_hea   VARCHAR_TBL := varchar_tbl();
            l_child_sig SIGNATURE_REC;
            l_result    VARCHAR2(1);
          BEGIN
           l_child_sig := g_signatures(p_sig.child_sigs(k));
           print_log('Processing child signature: '||p_sig.child_sigs(k));
           l_run_result := run_sig_sql(l_child_sig.sig_sql, l_col_rows, l_col_hea, l_child_sig.limit_rows);
           l_class_string := p_class_string || ' ' || l_current_sig;
           IF (l_run_result) THEN
               l_result := process_signature_results(p_sig.child_sigs(k), l_child_sig, l_col_rows, l_col_hea, l_current_sig, p_sig_suffix || '_' || to_char(i), l_class_string);
               set_item_result(l_result);
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
            print_log('Error processing child signature: '||p_sig.child_sigs(k));
            print_log('Error: '||sqlerrm);
          END;
          print_out('
                        </blockquote></td></tr>');
        END LOOP;
      END LOOP;


      --l_sig_fail := (l_sig_fail OR l_fail_flag);
      -- End of results and footer
      l_step := '210';
      l_html := l_html || '
                     <div style="display:none" class="sigrescode '||l_current_section||' '||l_current_sig||' '|| p_class_string || ' ' || l_sig_result||'" level="'||to_char(g_level)||'"></div>
      ';
      l_html := l_html ||  '
                    </tbody>
                    </table>
                    </div>  <!-- end table data -->';

      print_out(l_html);
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
                        <span class="divuar1">Error: </span>'||prepare_text(p_sig.problem_descr);
      l_sig_result := 'E';
    ELSIF p_sig.fail_type = 'W' THEN
      l_html := '
                    <div class="divwarn results data print section fullsection">
                        <span class="divwarn1">Warning: </span>'||prepare_text(p_sig.problem_descr);
      l_sig_result := 'W';
    ELSE
      l_html := '
                    <div class="divinfo results data print section fullsection">
                        <span class="divinfo1">Information: </span>'||prepare_text(p_sig.problem_descr);
      l_sig_result := 'I';
    END IF;

    -----------------------------------------------------
    -- Print solution part of the action - only if passed
    -----------------------------------------------------
    l_step := '240';
    IF p_sig.solution is not null THEN
      l_html := l_html || '
                     <br><br><span class="solution">Findings and Recommendations:</span><br>
        ' || prepare_text(p_sig.solution);
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
          prepare_text(nvl(p_sig.success_msg, 'No instances of this problem found')) ||
          '</div> <!-- end results div -->';
      ELSE
        l_html := '
          <div class="divok results data print section fullsection"><div class="divok1"><span class="check_ico"></span> All checks passed.</div>'||
          prepare_text(nvl(p_sig.success_msg,
          'No instances of this problem found')) ||
          '</div> <!-- end results div -->';
      END IF;
    ELSE
      l_html := null;
    END IF;
  END IF;

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

  -- Print
  l_step := '270';
  print_out(expand_links(l_html, p_sig.sigrepo_id));

  g_level := g_level - 1;

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
    print_log('Invalid parameter error in process_signature_results at step '
      ||l_step);
    return 'E';
  WHEN OTHERS THEN
    print_log('Error in process_signature_results at step '||l_step);
    g_errbuf := l_step;
    return 'E';
END process_signature_results;

----------------------------------------------------------------
-- Start the main section                                     --
-- (where the sections and signatures reside)                 --
----------------------------------------------------------------

PROCEDURE start_main_section is

BEGIN

  print_out('
<!-- start body --->
    <div class="body background">
    <div style="min-height:75px;">
    </div>
<!-- main data screen (showing section and signatures) -->
    <div class="maindata print analysis section fullsection P">
    <div style="min-height:10px;">
    </div>
    <div class="sigcontainer background">
    <div class="containertitle"></div>
       <div style="float:left;padding-left:10px;padding-bottom:10px;" id ="showhidesection" mode="show">
          <a href="#" class="detailsmall data section sectionview" mode="show" id="showAll" open-sig-class=""><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAARCAYAAAA/mJfHAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH4QcMDDcT9JkZoQAAACxJREFUOMtj/P//PwO1ACMDA4MNtQxjYqAioKphjNQMs0HszdHYHI3NER2bAHk1DMQAgUpBAAAAAElFTkSuQmCC" alt="show_all" title="Show entire section"></a>
          <a href="#" class= "detailsmall data fullsection sectionview" mode="hide" id="hideAll" open-sig-class=""><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAARCAYAAAA/mJfHAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH4QcMDDcT9JkZoQAAACxJREFUOMtj/P//PwO1ACMDA4MNtQxjYqAioKphjNQMs0HszdHYHI3NER2bAHk1DMQAgUpBAAAAAElFTkSuQmCC" alt="hide_all" title="Show Single Signature"></a>
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
                       <a href="#" class="detailsmall collapseall data" id="collapseall"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAARCAYAAAAyhueAAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH4QcDCA4nhMPYJAAAAFRJREFUOMtjfM3A+ZgBBxD5/02WgQzAxEADwPj//3+qG8qC1aaic1WUGEoT7zP8//8fAzMUnq2iRIwmLqVf7FMaUaNhOhqm9AnTs8UMDIzsZAboTwAjVcX2TISAoAAAAABJRU5ErkJggg==" alt="collapse_all" title="Collapse All Tables"></a>
                   </div>
            <br><br>');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in start_main_section: '||sqlerrm);
  raise;
END start_main_section;


PROCEDURE end_main_section IS
   l_html           VARCHAR2(32767) := '';
   l_append_check   BOOLEAN := FALSE;
BEGIN

print_out('
      </div> <!-- end of inner container -->
            </td>
        </tr>
      </table>
    </div>  <!-- end of outer container -->
    <div style="min-height: 35;"></div>

 </div>');

-- Populate the sectionmenu details here, because we need the signature results
    print_out('<script>');
    FOR i IN 1 .. g_sec_detail.COUNT LOOP
        FOR j IN 1 .. g_sec_detail(i).sigs.COUNT LOOP
            -- in case of customizations, the global signatures table might not be populated correctly, so we might encounter a "no data found" exception.
            BEGIN
                l_html := ' <div class="sectionbutton data '||replace_chars(g_sec_detail(i).name)||' '||nvl(g_sec_detail(i).sigs(j).sig_id, 'null')||' '||nvl(g_sec_detail(i).sigs(j).sig_result, 'I')||'" open-sig="'||g_sec_detail(i).sigs(j).sig_id||'"> <span class="'||g_result(nvl(g_sec_detail(i).sigs(j).sig_result, 'I'))||'_small"></span><span style="padding:5px;">'||prepare_text(g_signatures(g_sec_detail(i).sigs(j).sig_name).title)||'</span> </div>';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_html := ' <div class="sectionbutton data '||replace_chars(g_sec_detail(i).name)||' '||nvl(g_sec_detail(i).sigs(j).sig_id, 'null')||' '||nvl(g_sec_detail(i).sigs(j).sig_result, 'I')||'" open-sig="'||g_sec_detail(i).sigs(j).sig_id||'"> <span class="'||g_result(nvl(g_sec_detail(i).sigs(j).sig_result, 'I'))||'_small"></span><span style="padding:5px;">' || g_sec_detail(i).sigs(j).sig_name || '</span> </div>';
                WHEN OTHERS THEN
                raise;
            END;
            print_out('
                  $("#sectionmenu").append('''||l_html||''');');
        END LOOP;
    END LOOP;
    print_out('</script>');


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

PROCEDURE start_section(p_sect_title VARCHAR2, p_sect_name VARCHAR2 DEFAULT '') IS
  lsect section_rec;
  l_sig_array signatures_tbl := signatures_tbl();

BEGIN
  g_sections(g_sections.count + 1) := lsect;

  -- add element in the sections table
  g_sec_detail.extend();
  IF (p_sect_name != '') THEN
      g_sec_detail(g_sec_detail.LAST).name := p_sect_name;
  ELSE
      g_sec_detail(g_sec_detail.LAST).name := p_sect_title;
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
-- CG to be removed (from the AB)
PROCEDURE end_section (
  p_success_msg IN VARCHAR2 DEFAULT 'All checks passed.') IS
  l_loop_count NUMBER;
BEGIN
  print_log ('End Section');

END end_section;

-----------------------------------------------
-- Diagnostic specific functions and procedures
-----------------------------------------------
--------------------------------------------------
-- Custom function to return the file version   --
--------------------------------------------------

FUNCTION get_file_ver (p_fileid NUMBER) return VARCHAR2 IS

   CURSOR file_ver_c (p_file_id NUMBER) IS
         select version, to_number(version_segment1) vs1, to_number(version_segment2) vs2, to_number(version_segment3) vs3, to_number(version_segment4) vs4,
                to_number(version_segment5) vs5, to_number(version_segment6) vs6, to_number(version_segment7) vs7, to_number(version_segment2) vs8,
                to_number(version_segment9) vs9, to_number(version_segment10) vs10
           from ad_file_versions where file_id = p_file_id
          order by vs1 desc, vs2 desc, vs3 desc, vs4 desc, vs5 desc, vs6 desc, vs7 desc, vs8 desc, vs9 desc, vs10 desc;

    l_version VARCHAR2(150);
    l_vs1 NUMBER;
    l_vs2 NUMBER;
    l_vs3 NUMBER;
    l_vs4 NUMBER;
    l_vs5 NUMBER;
    l_vs6 NUMBER;
    l_vs7 NUMBER;
    l_vs8 NUMBER;
    l_vs9 NUMBER;
    l_vs10 NUMBER;

BEGIN

    OPEN file_ver_c (p_fileid);

    FETCH file_ver_c INTO
          l_version, l_vs1, l_vs2, l_vs3, l_vs4, l_vs5, l_vs6, l_vs7, l_vs8, l_vs9, l_vs10;

    CLOSE file_ver_c;
    RETURN l_version;

END get_file_ver;


-------------------------
-- Recommended Patches
-------------------------

FUNCTION check_rec_patches_1 RETURN VARCHAR2 IS

  l_col_rows   COL_LIST_TBL := col_list_tbl(); -- Row values
  l_hdr        VARCHAR_TBL  := varchar_tbl(); -- Column headings
  l_app_date   DATE;         -- Patch applied date
  l_extra_info HASH_TBL_4K;  -- Extra information
  l_step       VARCHAR2(10);
  l_sig        SIGNATURE_REC;
  l_rel        VARCHAR2(3);

  CURSOR get_app_date(p_ptch VARCHAR2, p_rel VARCHAR2) IS
   SELECT min(Last_Update_Date) as date_applied
    FROM Ad_Bugs Adb
    WHERE Adb.Bug_Number like p_ptch
    AND ad_patch.is_patch_applied(p_rel, -1, adb.bug_number)!='NOT_APPLIED';

BEGIN

debug('Begin recommended patches signature: check_rec_patches_1');

  -- Column headings
  l_step := '10';
  l_hdr.extend(5);
  l_hdr(1) := 'Patch';
  l_hdr(2) := 'Applied';
  l_hdr(3) := 'Date';
  l_hdr(4) := 'Name';
  l_hdr(5) := 'Note';
  l_col_rows.extend(5);

IF substr(g_rep_info('Apps Version'),1,4) = '12.2' THEN

   l_rel := 'R12';
   l_col_rows(1)(1) := '27283051';
   l_col_rows(2)(1) := 'No';
   l_col_rows(3)(1) := NULL;
   l_col_rows(4)(1) := '1OFF:12.2.4:WORKFLOW PROCESS GETTING STUCK (superseded by 27911576)';
   l_col_rows(5)(1) := '[2367572.1]';

   l_col_rows(1)(2) := '27911576';
   l_col_rows(2)(2) := 'No';
   l_col_rows(3)(2) := NULL;
   l_col_rows(4)(2) := '1OFF:12.2.4:PREVENTING STUCK WF PROCESSES WHEN USING ADOP TOOL';
   l_col_rows(5)(2) := '[2367541.1]';

END IF;

   l_sig.title := 'Recommended Critical Workflow Patch 27911576 is missing';
   l_sig.fail_condition := '[Applied] = [No]';
   l_sig.problem_descr := 'Recommended 1OFF CRITICAL patch 27911576-1OFF:12.2.4:PREVENTING STUCK WF PROCESSES WHEN USING ADOP TOOL is not applied to this environment. ';
   l_sig.solution := 'When upgrading an item type while not in the patch edition, a DDL is registered with ADOP cutover phase to execute a "date fix" that could result in a process activities date/time of creation to be later than when it was launched. That could ultimately result in the launched process and its activities getting stuck.<br><br>

<b>Please apply Development recommended critical patch {27911576}.</b><br><br>

Patch 27911576 released on June 22, 2018 includes patch 27283051, and limits DDL registration of a "date fix" only when in the patch edition during ADOP online patching to ensure the continued (unstuck) execution of launched processes.
Please follow the steps in [2367572.1] - 12.2 E-Business Suite Background Engine Workflows Are Not Processed And Get Corrupted With An Incorrect Date Stamp After Applying A Patch In Hotpatch Mode.<br><br>

Apply Patch {27911576} - 1OFF:12.2.4:PREVENTING STUCK WF PROCESSES WHEN USING ADOP TOOL to get the fix for stuck workflow processes issue found in :<br>
<table>
<tr class="tdata Connection_Leaks S7 W">
<td class="sigdetails">$FND_TOP/patch/115/sql/wfldrb.pls</td>
<td class="sigdetails">120.8.12020000.5</td>
</tr>
<tr class="tdata Connection_Leaks S7 W">
<td class="sigdetails">$FND_TOP/patch/115/sql/wfldrs.pls</td>
<td class="sigdetails">120.6.12020000.2</td>
</tr>
</table><br><br>

For the most current recommendations, use the Patch Wizard or the Updates & Patches Tab in My Oracle Support. Further guidance can be found in the following documents:
<ul>
<li>[1633974.2] How to Find EBS Patches and EBS Technology Patches</li>
<li>[976188.1] Patch Wizard Utility</li>
<li>[976688.2] Patch Wizard FAQ</li>
</ul>
';
   l_sig.success_msg := '';
   l_sig.print_condition := 'FAILURE';
   l_sig.fail_type := 'E';
   l_sig.print_sql_output := 'Y';
   l_sig.limit_rows := 'Y';
   l_sig.include_in_xml :='P';
   -- if snapshot is old, add message to the solution
   IF nvl(g_snap_days, 10) > 30 THEN
       l_sig.solution := l_sig.solution || '<br><br><b>ADADMIN</b>: Maintain Snapshot Information was executed more than 30 days ago.<br>It is recommended that AD Utilities (Adadmin) "Maintain Snapshot Information" is run periodically as key tools (Patch Wizard, ADPatch,etc) rely on this information being accurate and up-to-date.';
   END IF;

  -- Check if applied
  IF l_col_rows.exists(1) THEN
    FOR i in 1..l_col_rows(1).count loop
      l_step := '40';
      OPEN get_app_date(l_col_rows(1)(i),l_rel);
      FETCH get_app_date INTO l_app_date;
      CLOSE get_app_date;
      l_col_rows(1)(i) := '{'||l_col_rows(1)(i)||'}';
      IF l_app_date is not null THEN
        l_step := '50';
        l_col_rows(2)(i) := 'Yes';
        l_col_rows(3)(i) := to_char(l_app_date);
      END IF;
    END LOOP;
  END IF;

--Render
  l_step := '60';

  g_signatures('CHECK_WF_CRITICAL_PATCH_27911576') := l_sig;

  l_step := '70';
  RETURN process_signature_results(
    'CHECK_WF_CRITICAL_PATCH_27911576',     -- sig ID
    l_sig,                              -- signature information
    l_col_rows,                         -- data
    l_hdr);                             -- headers

debug('End recommended patches signature: check_rec_patches_1');

EXCEPTION WHEN OTHERS THEN
  print_log('Error in check_rec_patches_1 at step '||l_step);
  raise;
END check_rec_patches_1;




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
  p_include_in_dx_summary   VARCHAR2    DEFAULT 'N') -- This is for AT use so internal only. Set to Y if want signature result to be printed at end of output file in DX Summary section
 IS

  l_rec signature_rec;
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
  g_signatures(p_sig_id) := l_rec;
EXCEPTION WHEN OTHERS THEN
  print_log('Error in add_signature procedure: '||p_sig_id);
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
      END IF;
      l_key := g_sql_tokens.next(l_key);
    END LOOP;
  END IF;

  -- Run SQL
  l_run_res := run_sig_sql(l_sig.sig_sql, l_col_rows, l_col_hea, l_sig.limit_rows);

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
  print_error('PROGRAM ERROR<br/>
    Error for sig '||p_sig_id||' '||sqlerrm||'<br/>
    See the log file for additional details');
    return 'E';
END run_stored_sig;


--########################################################################################
--     Beginning of specific code of this ANALYZER
--########################################################################################

----------------------------------------------------------------
--- Validate Parameters                                      ---
----------------------------------------------------------------
PROCEDURE validate_parameters(
            p_header_id                    IN NUMBER      DEFAULT NULL
           ,p_line_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 20
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y')

IS

  l_revision                  VARCHAR2(25);
  l_date_char                 VARCHAR2(30);
  l_instance                  V$INSTANCE.INSTANCE_NAME%TYPE;
  l_apps_version              FND_PRODUCT_GROUPS.RELEASE_NAME%TYPE;
  l_host                      V$INSTANCE.HOST_NAME%TYPE;
  l_full_hostname             VARCHAR2(255);
  l_key                       VARCHAR2(255);
  l_system_function_var       VARCHAR2(2000);
  l_index                     NUMBER:=1;
  l_dbversion                 V$INSTANCE.VERSION%TYPE;
  l_step                      VARCHAR2(10);
  invalid_parameters EXCEPTION;



l_exists_val       VARCHAR2(2000);



FUNCTION get_ORDERNUMBER
   return VARCHAR2 IS
BEGIN
debug('begin sql token function: ORDERNUMBER');
BEGIN
   select distinct BLA.ORDER_NUMBER
   into l_system_function_var
    from OE_BLANKET_HEADERS_ALL BLA,
         OE_TRANSACTION_TYPES_TL TYP
   where BLA.HEADER_ID                 = p_header_id
   and BLA.ORDER_TYPE_ID               = TYP.TRANSACTION_TYPE_ID;
   return l_system_function_var;
EXCEPTION WHEN NO_DATA_FOUND THEN
      return null;
END;
debug('end sql token function: ORDERNUMBER');
END get_ORDERNUMBER;



BEGIN

  -- Determine instance info
  l_step := '1';
  BEGIN

    SELECT max(release_name) INTO l_apps_version
    FROM fnd_product_groups;

    SELECT instance_name, host_name, version
    INTO l_instance, l_host, l_dbversion
    FROM v$instance;

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
  l_revision := rtrim(replace('$Revision: 200.5  $','$',''));
  l_revision := ltrim(replace(l_revision,'Revision:',''));
  l_date_char := rtrim(replace('$Date: 2018/08/02 20:13:05 $','$',''));
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
  g_rep_info('Host') := l_host;
  -- the host name might already be fully qualified, need to check if it includes the domain before appending it
  IF (l_host LIKE '%.%') THEN
       g_rep_info('FullHost') := l_host;
  ELSE
       g_rep_info('FullHost') := l_host || '.' || l_full_hostname;
  END IF;
  l_step := '6';
  g_rep_info('Instance') := l_instance;
  g_rep_info('DB Version') := l_dbversion;
  g_rep_info('Apps Version') := l_apps_version;
  g_rep_info('File Name') := 'om_agreement_analyzer.sql';
  g_rep_info('File Version') := l_revision;
  g_rep_info('Execution Date') := to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
  g_rep_info('Description') := ('The ' || analyzer_title ||' Analyzer ' || '<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?id=2295096.1" target="_blank">(Note 2295096.1)</a> ' || ' is a self-service health-check script that reviews the overall footprint, analyzes current configurations and settings for the environment and provides feedback and recommendations on best practices. Your application data is not altered in any way when you run this analyzer.');

  l_step := '7';
  IF (g_is_concurrent) THEN
     populate_user_details();
  END IF;

  ------------------------------------------------------------------------------
  -- NOTE: Add code here for validation to the parameters of your diagnostic
  ------------------------------------------------------------------------------


  g_max_output_rows := nvl(p_max_output_rows,20);
  g_debug_mode := nvl(p_debug_mode, 'Y');

debug('begin parameter validation: p_header_id');
IF p_header_id IS NULL OR p_header_id = '' THEN
   print_error('INVALID ARGUMENT: Parameter Header ID is required.');
   raise invalid_parameters;
END IF;
IF p_header_id IS NOT NULL THEN
BEGIN
SELECT HEADER_ID
INTO l_exists_val
FROM OE_BLANKET_HEADERS_ALL H
WHERE HEADER_ID = p_header_id and rownum < 2 ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
         print_error('INVALID ARGUMENT: Invalid Header ID parameter provided.  Process cannot continue.');
   raise invalid_parameters;
END;
END IF;
debug('end parameter validation: p_header_id');

debug('begin parameter validation: p_line_id');
IF p_line_id IS NOT NULL THEN
BEGIN
SELECT LINE_ID
INTO l_exists_val
FROM OE_BLANKET_LINES_ALL LIN
WHERE LINE_ID = p_line_id
AND LIN.HEADER_ID = p_header_id

 and rownum < 2 ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
         print_error('INVALID ARGUMENT: Invalid Line ID parameter provided.  Process cannot continue.');
   raise invalid_parameters;
END;
END IF;
debug('end parameter validation: p_line_id');




-- Validation to verify analyzer is run on proper e-Business application version
-- In case validation at the beginning is updated/removed, adding validation here also so execution fails

  IF substr(l_apps_version,1,4) NOT IN ('12.0','12.1','12.2') THEN
    print_log('eBusiness Suite version = '||l_apps_version);
    print_log('ERROR: This Analyzer script is compatible for following version(s): 12.0,12.1,12.2');
    raise invalid_parameters;
  END IF;

-- .log enhancements (ER # 140)
  IF NOT g_is_concurrent THEN
    print_log('EBS '||'Sales Agreement'|| ' Analyzer Log File');
    print_log('***************************************************************');
    print_log('Host: '||g_rep_info('Host'));
    print_log('FullHost: '||g_rep_info('FullHost'));
    print_log('Instance: '||g_rep_info('Instance'));
    print_log('Database version: '||g_rep_info('DB Version'));
    print_log('Applications version: '||g_rep_info('Apps Version'));
    print_log('Analyzer version: '||g_rep_info('File Version'));
  ELSE
    print_log('Host: '||g_rep_info('Host'));
    print_log('FullHost: '||g_rep_info('FullHost'));
    print_log('Instance: '||g_rep_info('Instance'));
    print_log('Database version: '||g_rep_info('DB Version'));
    print_log('Applications version: '||g_rep_info('Apps Version'));
    print_log('Analyzer version: '||g_rep_info('File Version'));
  END IF;




  -- Create global hash for parameters. Numbers required for the output order
debug('begin populate parameters hash table');
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Header ID';
   g_parameters(g_parameters.LAST).pvalue := p_header_id;
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Line ID';
   g_parameters(g_parameters.LAST).pvalue := p_line_id;
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Maximum Rows to Display';
   g_parameters(g_parameters.LAST).pvalue := p_max_output_rows;
   g_parameters.extend();
   g_parameters(g_parameters.LAST).pname := 'Debug Mode';
   g_parameters(g_parameters.LAST).pvalue := p_debug_mode;
debug('end populate parameters hash table');



  l_key := g_parameters.first;
  -- Print parameters to the log
  print_log('Parameter Values');

  FOR i IN 1..g_parameters.COUNT LOOP
    print_log(to_char(i) || '. ' || g_parameters(i).pname || ': ' || g_parameters(i).pvalue);
  END LOOP;

  -- Create global hash of SQL token values
debug('begin populate sql tokens hash table');
   g_sql_tokens('##$$HEADERID$$##') := p_header_id;
   g_sql_tokens('##$$LINEID$$##') := p_line_id;
   g_sql_tokens('##$$ORDERNUMBER$$##') := get_ORDERNUMBER();
   l_system_function_var := null;
debug('end populate sql tokens hash table');



  l_key := g_sql_tokens.first;
  -- Print token values to the log

  -- if max rows param is not set and does not have a default, g_max_output_rows might end up being -1. We don't want that.
  IF (g_max_output_rows <= 0) THEN
     print_log ('Max rows was not set and there is no default value for it. Defaulting to 20.');
     g_max_output_rows := 20;
  END IF;


  print_log('SQL Token Values');

  WHILE l_key IS NOT NULL LOOP
    print_log(l_key||': '|| g_sql_tokens(l_key));
    l_key := g_sql_tokens.next(l_key);
  END LOOP;

EXCEPTION
  WHEN INVALID_PARAMETERS THEN
    print_log('Invalid parameters provided. Process cannot continue.');
    print_log('Error in validate_parameters at step: ' || l_step);
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***');
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** Invalid parameters provided. Process cannot continue.');
    dbms_output.put_line('Error in validate_parameters at step: ' || l_step);
    raise;
  WHEN OTHERS THEN
    print_log('Error validating parameters: '||sqlerrm);
    print_log('Error in validate_parameters at step: ' || l_step);
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***');
    dbms_output.put_line('***************************************************************');
    dbms_output.put_line('*** Error validating parameters: '||sqlerrm);
    dbms_output.put_line('Error in validate_parameters at step: ' || l_step);
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


debug('begin add_signature: ONT_DB_RELEASE_INFO');
  add_signature(
      p_sig_repo_id            => '5397',
      p_sig_id                 => 'ONT_DB_RELEASE_INFO',
      p_sig_sql                => 'select ''Hostname = '' || host_name "Details" FROM v$instance
union
SELECT ''Platform = '' ||SUBSTR(REPLACE(REPLACE(pcv1.product, ''TNS for ''), '':'' )||pcv2.status, 1, 80)
FROM product_component_version pcv1,
product_component_version pcv2
WHERE UPPER(pcv1.product) LIKE ''%TNS%''
AND UPPER(pcv2.product) LIKE ''%ORACLE%''
AND ROWNUM = 1
union
SELECT ''DB Name = '' ||instance_name from v$instance
union
SELECT banner from v$version
union
SELECT ''Language = ''||value FROM V$NLS_PARAMETERS WHERE parameter in (''NLS_LANGUAGE'',''NLS_CHARACTERSET'')
union
SELECT ''Creation Date = '' ||to_char(created, ''DD-MON-YYYY HH:MI:SS'') created from v$database
union
select ''EBS Release = '' ||OE_CODE_CONTROL.Get_Code_Release_Level from dual',
      p_title                  => 'Database / Release / Tools Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Database / Release / Tools Details found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_DB_RELEASE_INFO');



debug('begin add_signature: AGREEMENT_LINES_INFORMATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7647',
      p_sig_id                 => 'AGREEMENT_LINES_INFORMATION',
      p_sig_sql                => 'select
BLN.LINE_NUMBER	"Line Number",
BLN.HEADER_ID	"Header ID",
BLN.LINE_ID	"Line ID",
BLN.ORG_ID	"Org ID",
BLN.ORDERED_ITEM	"Ordered Item",
BLN.ITEM_IDENTIFIER_TYPE	"Item Identifier",
BLN.ORDERED_QUANTITY	"Ordered Qty",
BLN.ORDER_QUANTITY_UOM	"Ordered UOM",
BLN.FULFILLED_QUANTITY	"Fulfilled Qty",
BLN.SHIP_FROM_ORG_ID	"Ship From Org ID",
BLN.SHIP_TO_ORG_ID	"Ship To Org ID",
BLN.INVOICE_TO_ORG_ID	"Invoice To Org ID",
BLN.DELIVER_TO_ORG_ID	"Deliver To Org ID",
BLN.SOLD_TO_ORG_ID	"Sold To Org ID",
BLN.CUST_PO_NUMBER	"Customer PO",
BLN.PRICE_LIST_ID	"Price List ID",
BLN.SHIPMENT_NUMBER	"Shipment Number",
BLN.SHIPPING_METHOD_CODE	"Shipping Method Code",
BLN.FREIGHT_TERMS_CODE	"Freight Terms",
BLN.PAYMENT_TERM_ID	"Payment Terms",
BLN.INVOICING_RULE_ID	"Invoicing Rule",
BLN.ACCOUNTING_RULE_ID	"Accounting Rule",
BLN.SOURCE_DOCUMENT_TYPE_ID	"Source Doc Type ID",
BLN.SOURCE_DOCUMENT_ID	"Source Doc ID",
BLN.SOURCE_DOCUMENT_LINE_ID	"Source Doc Line ID",
BLN.LINE_CATEGORY_CODE	"Category Code",
BLN.SALESREP_ID	"Salesrep",
BLN.SHIPPING_INSTRUCTIONS	"Shipping Instructions",
BLN.PACKING_INSTRUCTIONS	"Packing Instructions",
BLN.FLOW_STATUS_CODE	"Flow Status Code",
BLN.FULFILLMENT_METHOD_CODE	"Fulfillment Method Code",
BLN.TRANSACTION_PHASE_CODE	"Trans Phase Code",
BLN.ORDER_FIRMED_DATE	"Order Firmed Date",
BLN.ACTUAL_FULFILLMENT_DATE "Actual Fulfillment Date"
from
OE_BLANKET_LINES_ALL BLN
where
BLN.HEADER_ID = ##$$HEADERID$$##
and NVL(''##$$LINEID$$##'',0) in (0,BLN.LINE_ID)
order by "Line Number"',
      p_title                  => 'Agreement Line(s)',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No lines on this Agreement.',
      p_solution               => 'No lines are associated with this Agreement.  ',
      p_success_msg            => 'Line(s) Agreement information',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_INFORMATION');



debug('begin add_signature: AGREEMENT_HEADER_NEGOTIATION_WORKFLOW_ACTIVITY');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7544',
      p_sig_id                 => 'AGREEMENT_HEADER_NEGOTIATION_WORKFLOW_ACTIVITY',
      p_sig_sql                => 'select substr(WFS.ITEM_KEY,1,45)  "Item Key",
       substr(WFA.DISPLAY_NAME,1,45)  "PROCESS",
       substr(WFA1.DISPLAY_NAME,1,45)     "ACTIVITY",
       substr(WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE),1,15) "RESULT",
       substr(LKP.MEANING,1,30)          "ACT STATUS",
       WFS.NOTIFICATION_ID   "NOTIFICATION ID",
       WFP.PROCESS_NAME      "PROCESS NAME",
       WFP.ACTIVITY_NAME     "ACTIVITY NAME",
       WFS.ACTIVITY_RESULT_CODE   "RESULT CODE",
       to_char(WFS.BEGIN_DATE,''DD-MON-RR_HH24:MI:SS'') "BEGIN DATE",
       to_char(WFS.END_DATE,''DD-MON-RR_HH24:MI:SS'')   "END DATE",
       WFS.ERROR_NAME        "ERROR NAME"
from WF_ITEM_ACTIVITY_STATUSES WFS,
     WF_PROCESS_ACTIVITIES     WFP,
     WF_ACTIVITIES_VL          WFA,
     WF_ACTIVITIES_VL          WFA1,
     WF_LOOKUPS                LKP
where
     WFS.ITEM_TYPE          = ''OENH''
and  WFS.item_key           = to_char((''##$$HEADERID$$##''))
and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID
and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE
and  WFP.PROCESS_NAME       = WFA.NAME
and  WFP.PROCESS_VERSION    = WFA.VERSION
and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE
and  WFP.ACTIVITY_NAME      = WFA1.NAME
and  WFA1.VERSION           =
                             (select max(VERSION)
                              from WF_ACTIVITIES WF2
                              where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE
                              and   WF2.NAME = WFP.ACTIVITY_NAME)
and  LKP.LOOKUP_TYPE        = ''WFENG_STATUS''
and  LKP.LOOKUP_CODE        = WFS.ACTIVITY_STATUS
order by WFS.ITEM_KEY,
        WFS.BEGIN_DATE,
        EXECUTION_TIME',
      p_title                  => 'Agreement Header Negotiation Workflow Activity',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Negotiation Workflow Information',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_NEGOTIATION_WORKFLOW_ACTIVITY');



debug('begin add_signature: AGREEMENT_HEADER_APPROVALS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7545',
      p_sig_id                 => 'AGREEMENT_HEADER_APPROVALS',
      p_sig_sql                => 'Select
   BLA.FLOW_STATUS_CODE              "Agreement Status",
   BLA.DRAFT_SUBMITTED_FLAG          "Draft Submitted",
   BLA.CUSTOMER_SIGNATURE            "Customer Signature",
   BLA.CUSTOMER_SIGNATURE_DATE       "Customer Signature Date",
   BLA.SUPPLIER_SIGNATURE            "Supplier Signature",
   BLA.SUPPLIER_SIGNATURE_Date       "Supplier Signature Date"
from
   OE_BLANKET_HEADERS_ALL        BLA,
   OE_TRANSACTION_TYPES_TL       TYP
where
     BLA.HEADER_ID              =  ##$$HEADERID$$##
and  BLA.ORDER_TYPE_ID          = TYP.TRANSACTION_TYPE_ID
and  BLA.FLOW_STATUS_CODE       = ''ACTIVE''',
      p_title                  => 'Agreement Header Approvals',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Approval Information',
      p_solution               => 'No Approval information located.  <BR> <BR>
Verify that the Agreement has a status of Active.  If Agreement is Active, then verify Approval setups by reviewing [363517.1].',
      p_success_msg            => 'Agreement is Active.  <BR> <BR>
If there are no Customer or Supplier approval information returned, then verify Approval setups by reviewing [363517.1].',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_APPROVALS');



debug('begin add_signature: AGREEMENT_HEADER_RELEASES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8278',
      p_sig_id                 => 'AGREEMENT_HEADER_RELEASES',
      p_sig_sql                => 'select
TO_CHAR(BLE.BLANKET_MAX_AMOUNT,''$999G999G999G999D99'') "Max Amount",
TO_CHAR(BLE.BLANKET_MIN_AMOUNT,''$999G999G999G999D99'') "Min Amount",
BLE.ENFORCE_PRICE_LIST_FLAG "Enforce Price List",
BLE.OVERRIDE_AMOUNT_FLAG    "Override Amount",
TO_CHAR(BLE.RELEASED_AMOUNT,''$999G999G999G999D99'')    "Released Amount",
TO_CHAR(BLE.FULFILLED_AMOUNT,''$999G999G999G999D99'')    "Fulfilled Amount",
TO_CHAR(BLE.RETURNED_AMOUNT,''$999G999G999G999D99'')    "Returned Amount"
from
OE_BLANKET_HEADERS_EXT BLE
where
BLE.ORDER_NUMBER = ##$$ORDERNUMBER$$##',
      p_title                  => 'Agreement Header Release Amounts',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Release Amounts',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_RELEASES');





debug('begin add_signature: AGREEMENT_LINES_RELEASED_CHILD');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7662',
      p_sig_id                 => 'AGREEMENT_LINES_RELEASED_CHILD',
      p_sig_sql                => 'select distinct
oeh.order_number "Sales Order Number",
    substr(to_char(oel.line_number) ||
          decode(oel.shipment_number, null, null, ''.'' || to_char(oel.shipment_number))||
          decode(oel.option_number, null, null, ''.'' || to_char(oel.option_number)) ||
          decode(oel.component_number, null, null,
                 decode(oel.option_number, null, ''.'',null)||
                 ''.''||to_char(oel.component_number))||
          decode(oel.service_number,null,null,
                 decode(oel.component_number, null, ''.'' , null) ||
                        decode(oel.option_number, null, ''.'', null ) ||
                        ''.''|| to_char(oel.service_number)),1,10)  "SO Line",
oel.org_id "Org ID",
oel.ordered_item "Ordered Item",
oel.ordered_quantity "Ordered Qty",
oel.shipped_quantity "Shipped Qty",
oel.fulfilled_quantity "Fulfilled Qty",
oel.cancelled_quantity "Cancelled Qty"
from oe_blanket_lines_ext bl, oe_order_lines_all oel, oe_order_headers_all oeh
where oel.blanket_number = ##$$FK1$$##
and oel.blanket_line_number = ##$$FK2$$##
and oel.header_id = oeh.header_id
order by "Sales Order Number"',
      p_title                  => 'Agreement Line Release Activity',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Line Released Information',
      p_solution               => 'No release information found for this line. Verify Agreement Defaulting Rules have been defined as outlined in [353964.1]',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_RELEASED_CHILD');

debug('begin add_signature: AGREEMENT_LINES_RELEASED');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7658',
      p_sig_id                 => 'AGREEMENT_LINES_RELEASED',
      p_sig_sql                => 'select
BLH.order_number "Agreement Number",
BLN.LINE_NUMBER "Line Number",
BLN.LINE_ID "Line ID",
BLN.ORDERED_ITEM "Ordered Item",
BLE.RELEASED_QUANTITY "Released Qty",
BLE.FULFILLED_QUANTITY "Fulfilled Qty",
BLE.RETURNED_QUANTITY "Returned Qty",
BLH.order_number "##$$FK1$$##",
BLN.line_number "##$$FK2$$##"
from
OE_BLANKET_LINES_ALL BLN,
OE_BLANKET_HEADERS_ALL BLH,
OE_BLANKET_LINES_EXT BLE
where
BLN.HEADER_ID = ##$$HEADERID$$##
and BLE.ORDER_NUMBER = BLH.order_number
and NVL(''##$$LINEID$$##'',0) in (0,BLN.LINE_ID)
and BLH.HEADER_ID = BLN.HEADER_ID
and BLE.LINE_NUMBER = BLN.LINE_NUMBER
order by "Line Number"',
      p_title                  => 'Agreement Releases',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Lines released on this Agreement.',
      p_solution               => 'No lines released on this Agreement.',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('AGREEMENT_LINES_RELEASED_CHILD'),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_RELEASED');



debug('begin add_signature: AGREEMENT_INLINE_PRICE_LIST');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8413',
      p_sig_id                 => 'AGREEMENT_INLINE_PRICE_LIST',
      p_sig_sql                => 'SELECT
BLE.ORDER_NUMBER "Order Number",
BLE.LINE_NUMBER "Line Number",
BLN.ORDERED_ITEM "Ordered Item",
QPL.OPERAND "Operand",
QPL.START_DATE_ACTIVE "Active Start Date",
QPL.END_DATE_ACTIVE "Active End Date",
QPH.NAME "Price List Name"
FROM OE_BLANKET_LINES_ALL BLN
, OE_BLANKET_HEADERS_ALL BLH
, OE_BLANKET_LINES_EXT BLE
, QP_LIST_LINES QPL
, QP_SECU_LIST_HEADERS_V QPH
WHERE BLE.ORDER_NUMBER = ##$$ORDERNUMBER$$##
and NVL(''##$$LINEID$$##'',0) in (0,BLE.line_id)
AND BLH.HEADER_ID=BLN.HEADER_ID
AND BLE.LINE_NUMBER = BLN.LINE_NUMBER
AND BLE.ORDER_NUMBER = BLH.ORDER_NUMBER
AND BLE.QP_LIST_LINE_ID=QPL.LIST_LINE_ID
AND QPL.LIST_HEADER_ID=QPH.LIST_HEADER_ID',
      p_title                  => 'Agreement Inline Price List',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Reporting Inline Price List created for Sales Agreement line(s).',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('SUCCESS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_INLINE_PRICE_LIST');



debug('begin add_signature: AGREEMENT_HEADER_EXPIRED');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7648',
      p_sig_id                 => 'AGREEMENT_HEADER_EXPIRED',
      p_sig_sql                => 'SELECT DISTINCT
     wias.item_key "Workflow",
     obha.order_number "Agreement Number",
     obha.org_id "Org ID",
     obha.expiration_date "Expiration Date"
 FROM
     wf_item_activity_statuses wias,
     wf_process_activities wpa,
     oe_blanket_headers_all obha
 WHERE item_type = ''OEBH''
 AND wias.process_activity = wpa.instance_id
 and wias.item_key = to_char((''##$$HEADERID$$##''))
 AND trunc(obha.expiration_date) < trunc(sysdate)
 AND obha.flow_status_code=''ACTIVE''',
      p_title                  => 'Agreement Header Expired',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Agreement Header has expired but Workflow is Active.',
      p_solution               => 'Agreement Header has expired.  <BR><BR>

Agreement will close at the end of this month and then the Workflow Background Process with progress it Closed. <BR><BR>

If the Workflow background is not running for Blanket Workflows, then progress the Workflow manually:<BR>
Sales Agreement form, right click > workflow > progress workflow to close the expired Agreement.<BR><BR>

If Agreement does not expire at the end of this month or does not progress to Close, refer to [2140916.1].',
      p_success_msg            => 'Agreement is Active and has not Expired.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_EXPIRED');



debug('begin add_signature: AGREEMENT_HEADER_BLANKET_WORKFLOW_ACTIVITY');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '10066',
      p_sig_id                 => 'AGREEMENT_HEADER_BLANKET_WORKFLOW_ACTIVITY',
      p_sig_sql                => 'select substr(WFS.ITEM_KEY,1,45)  "Item Key",
       substr(WFA.DISPLAY_NAME,1,45)  "PROCESS",
       substr(WFA1.DISPLAY_NAME,1,45)     "ACTIVITY",
       substr(WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE),1,15) "RESULT",
       substr(LKP.MEANING,1,30)          "ACT STATUS",
       WFS.NOTIFICATION_ID   "NOTIFICATION ID",
       WFP.PROCESS_NAME      "PROCESS NAME",
       WFP.ACTIVITY_NAME     "ACTIVITY NAME",
       WFS.ACTIVITY_RESULT_CODE   "RESULT CODE",
       to_char(WFS.BEGIN_DATE,''DD-MON-RR_HH24:MI:SS'') "BEGIN DATE",
       to_char(WFS.END_DATE,''DD-MON-RR_HH24:MI:SS'')   "END DATE",
       WFS.ERROR_NAME        "ERROR NAME"
from WF_ITEM_ACTIVITY_STATUSES WFS,
     WF_PROCESS_ACTIVITIES     WFP,
     WF_ACTIVITIES_VL          WFA,
     WF_ACTIVITIES_VL          WFA1,
     WF_LOOKUPS                LKP
where
     WFS.ITEM_TYPE          = ''OEBH''
and  WFS.item_key           = to_char((''##$$HEADERID$$##''))
and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID
and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE
and  WFP.PROCESS_NAME       = WFA.NAME
and  WFP.PROCESS_VERSION    = WFA.VERSION
and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE
and  WFP.ACTIVITY_NAME      = WFA1.NAME
and  WFA1.VERSION           =
                             (select max(VERSION)
                              from WF_ACTIVITIES WF2
                              where WF2.ITEM_TYPE = WFP.ACTIVITY_ITEM_TYPE
                              and   WF2.NAME = WFP.ACTIVITY_NAME)
and  LKP.LOOKUP_TYPE        = ''WFENG_STATUS''
and  LKP.LOOKUP_CODE        = WFS.ACTIVITY_STATUS
order by WFS.ITEM_KEY,
        WFS.BEGIN_DATE,
        EXECUTION_TIME',
      p_title                  => 'Agreement Header Workflow Activity',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Workflow Information once the Agreement has been approved.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_BLANKET_WORKFLOW_ACTIVITY');



debug('begin add_signature: ONT_DB_PARAMETERS');
  add_signature(
      p_sig_repo_id            => '5401',
      p_sig_id                 => 'ONT_DB_PARAMETERS',
      p_sig_sql                => 'select
  name "Parameter Name"
, value "Currently Set Value"
from v$parameter
where name in (
''shared_pool_size'',
''shared_pool_reserved_size'',
''large_pool_size'',
''pre_page_sga'',
''use_indirect_data_buffers'',
''nls_language'',
''nls_date_format'',
''nls_time_format'',
''nls_numeric_characters'',
''db_block_buffers'',
''db_block_checksum'',
''db_block_size'',
''db_block_lru_latches'',
''db_writer_processes'',
''db_block_max_dirty_target'',
''buffer_pool_keep'',
''buffer_pool_recycle'',
''optimizer_features_enable'',
''sort_area_size'',
''sort_area_retained_size'',
''sort_multiblock_read_count'',
''open_cursors'',
''sql_trace'',
''_optimizer_undo_changes'',
''optimizer_mode'',
''_optimizer_mode_force'',
''_sort_elimination_cost_ratio'',
''blank_trimming'',
''always_anti_join'',
''_complex_view_merging'',
''_push_join_predicate'',
''_push_join_union_view'',
''_fast_full_scan_enabled'',
''always_semi_join'',
''_ordered_nested_loop'',
''optimizer_max_permutations'',
''optimizer_index_cost_adj'',
''optimizer_index_caching'',
''query_rewrite_enabled'',
''query_rewrite_integrity'',
''_or_expand_nvl_predicate'',
''_like_with_bind_as_equality'',
''_table_scan_cost_plus_one'',
''_new_initial_join_orders'',
''utl_file_dir'',
''optimizer_percent_parallel'',
''cursor_sharing'',
''hash_join_enabled'',
''hash_area_size'',
''hash_multiblock_io_count'')
order by name',
      p_title                  => 'Database Parameter Settings',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Database Parameter Settings.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_DB_PARAMETERS');



debug('begin add_signature: ONT_APPLICATION_DETAILS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5254',
      p_sig_id                 => 'ONT_APPLICATION_DETAILS',
      p_sig_sql                => 'SELECT fav.application_name app_name,
           fav.application_short_name app_s_name,
           decode(fpi.status, ''I'', ''Yes'',
                     ''S'', ''Shared'',
                     ''N'', ''No'', fpi.status) inst_status,
           fpi.product_version,
           nvl(fpi.patch_level, ''Not Available'') patchset,
           fav.application_id app_id
    FROM fnd_application_vl fav, fnd_product_installations fpi
    WHERE fav.application_id = fpi.application_id
    order by 3',
      p_title                  => 'Application Details',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Application Details found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_APPLICATION_DETAILS');



debug('begin add_signature: AGREEMENT_HEADER_INFORMATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7551',
      p_sig_id                 => 'AGREEMENT_HEADER_INFORMATION',
      p_sig_sql                => 'select
   BLA.HEADER_ID                 "Header ID",
   BLA.ORDER_NUMBER              "Agreement Number",
   BLA.FLOW_STATUS_CODE          "Flow Status",
   EXT.START_DATE_ACTIVE         "Start Date Active",
   EXT.END_DATE_ACTIVE           "End Date Active",
   TYP.NAME                      "Order Type Name",
   BLA.ORDER_CATEGORY_CODE       "Category",
   BLA.ORG_ID                    "Org ID",
   (select name
      from hr_operating_units
     where organization_id = nvl(BLA.ORG_ID,-99)) "Organization Name",
  BLA.CUST_PO_NUMBER		"Customer PO Number",
  BLA.DRAFT_SUBMITTED_FLAG	"Draft Submitted",
  BLA.LOCK_CONTROL    		"Lock Control",
  BLA.ORDER_FIRMED_DATE 	"Order Firm Date",
  BLA.ORDER_NUMBER  		"Order Number",
  BLA.ORDER_TYPE_ID		"Order Type ID",
  BLA.ORDERED_DATE		"Ordered Date",
  BLA.ORIG_SYS_DOCUMENT_REF	"Orig Sys Doc Ref",
  BLA.PROGRAM_APPLICATION_ID 	"Program App ID",
  BLA.PROGRAM_ID 		"Program ID",
  BLA.PROGRAM_UPDATE_DATE	"Program Update Date",
  BLA.QUOTE_DATE  		"Quote Date",
  BLA.QUOTE_NUMBER      	"Quote Number",
  BLA.SALESREP_ID    		"Sales ID",
  BLA.SHIP_FROM_ORG_ID		"Ship From Org",
  BLA.SHIP_TO_ORG_ID		"Ship To Org",
  BLA.SOLD_TO_CONTACT_ID	"Sold To Contact",
  BLA.SOLD_TO_ORG_ID 		"Sold To Org",
  BLA.SOLD_TO_SITE_USE_ID	"Sold To Site",
  BLA.SOURCE_DOCUMENT_VERSION_NUMBER 		"Source Doc Version",
  BLA.VERSION_NUMBER 		"Version"
from
   OE_BLANKET_HEADERS_ALL        BLA,
   OE_BLANKET_HEADERS_EXT        EXT,
   OE_TRANSACTION_TYPES_TL       TYP,
   FND_LANGUAGES                 FLA
where
     BLA.HEADER_ID              = ##$$HEADERID$$##
and  TYP.LANGUAGE                  = FLA.LANGUAGE_CODE
and  FLA.INSTALLED_FLAG            = ''B''
and  BLA.ORDER_TYPE_ID             = TYP.TRANSACTION_TYPE_ID
and  BLA.ORDER_NUMBER           = EXT.ORDER_NUMBER',
      p_title                  => 'Agreement Header Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Information',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_INFORMATION');



debug('begin add_signature: AGREEMENT_LINE_HISTORY');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7739',
      p_sig_id                 => 'AGREEMENT_LINE_HISTORY',
      p_sig_sql                => 'SELECT
LINE_ID	"Line ID"
,      ORG_ID	"Org ID"
,      HEADER_ID	"Header ID"
,      LINE_NUMBER	"Line Number"
,      ORDER_QUANTITY_UOM "Ordered Qty UOM"
,      FULFILLED_QUANTITY	"Fulfilled Qty"
,      SHIP_FROM_ORG_ID	"Ship From Org ID"
,      SHIP_TO_ORG_ID	"Ship To Org ID"
,      INVOICE_TO_ORG_ID	"Invoice To Org ID"
,      DELIVER_TO_ORG_ID	"Deliver To Org ID"
,      SOLD_TO_ORG_ID	"Sold To Org ID"
,      CUST_PO_NUMBER	"Cust PO Number"
,      INVENTORY_ITEM_ID	"Inventory Item ID"
,      PRICE_LIST_ID		"Price List ID"
,      SHIPMENT_NUMBER	"Shipment Number"
,      SHIPPING_METHOD_CODE "Ship Method Code"
,      FREIGHT_TERMS_CODE	"Freight Terms Code"
,      PAYMENT_TERM_ID	"Payment Term ID"
,      INVOICING_RULE_ID	"Invoice Rule ID"
,      ACCOUNTING_RULE_ID	"Accounting Rule ID"
,      SOURCE_DOCUMENT_TYPE_ID	"Source Doc Type ID"
,      SOURCE_DOCUMENT_ID		"Source Doc ID"
,      SOURCE_DOCUMENT_LINE_ID	"Source Doc Line ID"
,      ITEM_TYPE_CODE	"Item Type Code"
,      LINE_CATEGORY_CODE	"Line Category Code"
,      SALESREP_ID	"Salesrep ID"
,      ITEM_IDENTIFIER_TYPE	"Item Identifier Type"
,      FULFILLMENT_METHOD_CODE	"Fulfillment Method Code"
,      ORDERED_ITEM_ID	"Ordered Item ID"
,      FLOW_STATUS_CODE	"Flow Status Code"
,      SHIPPING_INSTRUCTIONS	"Shipping Instructions"
,      PACKING_INSTRUCTIONS	"Packing Instructions"
,      VERSION_NUMBER	"Version Number"
,      START_DATE_ACTIVE	"Active Start Date"
,      END_DATE_ACTIVE	"Active End Date"
,      BLANKET_LINE_MAX_AMOUNT	"Agreement Line Max"
,      BLANKET_LINE_MIN_AMOUNT	"Agreement Line Min"
,      ENFORCE_PRICE_LIST_FLAG	"Enforce Price List"
,      RELEASED_AMOUNT	"Released Amount"
,      RETURNED_AMOUNT	"Returned Amount"
,      MAX_RELEASE_AMOUNT	"Max Release"
,      MIN_RELEASE_AMOUNT	"Min Release"
,      BLANKET_MAX_QUANTITY 	"Agreement Max Qty"
,      BLANKET_MIN_QUANTITY		"Agreement Min Qty"
,      MAX_RELEASE_QUANTITY	"Max Release Qty"
,      MIN_RELEASE_QUANTITY		"Min Release Qty"
,      OVERRIDE_RELEASE_CONTROLS_FLAG 	"Override Release Controls"
,      OVERRIDE_BLANKET_CONTROLS_FLAG 	"Override Blanket Controls"
,      RETURNED_QUANTITY	 "Returned Qty"
,      RELEASED_QUANTITY	"Released Qty"
,      QP_LIST_LINE_ID	"QP List Line ID"
,      MODIFIER_LIST_LINE_ID	"Modifier List Line ID"
,      ORDER_NUMBER	"Order Number"
,      ENFORCE_ACCOUNTING_RULE_FLAG	"Enforce Accounting Rule"
,      ENFORCE_INVOICING_RULE_FLAG	"Enforce Invoice Rule"
,      ENFORCE_SHIP_TO_FLAG		"Enforce Ship To"
,      ENFORCE_INVOICE_TO_FLAG	"Enforce Invoice To"
,      ENFORCE_FREIGHT_TERM_FLAG	"Enforce Freight Term"
,      ENFORCE_SHIPPING_METHOD_FLAG	"Enforce Shipping Method"
,      ENFORCE_PAYMENT_TERM_FLAG	"Enforce Payment Term"
,      FULFILLED_AMOUNT	"Fulffilled Amount"
,      TRANSACTION_PHASE_CODE 	"Transaction Phase"
,      AUDIT_FLAG	"Audit Flag"
,      VERSION_FLAG	"Version Flag"
,      PHASE_CHANGE_FLAG 	"Phase Change Flag"
,      REASON_ID	"Reason ID"
,      ORDER_FIRMED_DATE	"Ordered Firmed Date"
,      ACTUAL_FULFILLMENT_DATE	"Actual Fulfillment Date"
FROM  OE_BLANKET_LINES_HIST
where header_id =  ##$$HEADERID$$##',
      p_title                  => 'Agreement Line(s) History',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Reporting History of Sales Agreement line(s), needed when versioning is on during negotiations.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('SUCCESS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINE_HISTORY');



debug('begin add_signature: AGREEMENT_LINES_RELEASED_CHECKED');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7664',
      p_sig_id                 => 'AGREEMENT_LINES_RELEASED_CHECKED',
      p_sig_sql                => 'select
bl.order_number "Agreement Number",
bl.line_number "Line Number",
bl.released_quantity "Released (Ordered) Qty",
sum(ol.ordered_quantity) "Actual Ordered Qty",
(sum(ol.ordered_quantity) - bl.released_quantity) "Difference",
ol.blanket_number "##$$FK1$$##",
ol.blanket_line_number "##$$FK2$$##"
from oe_blanket_lines_ext bl, oe_order_lines_all ol
where bl.order_number = ##$$ORDERNUMBER$$##
and NVL(''##$$LINEID$$##'',0) in (0,bl.line_id)
and bl.order_number = ol.blanket_number
and bl.line_number = ol.blanket_line_number
group by bl.order_number, bl.line_number, bl.released_quantity, ol.blanket_number, ol.blanket_line_number
having bl.released_quantity <> sum(ol.ordered_quantity)',
      p_title                  => 'Agreement Release Totals',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Agreement Released (ordered) quantity on Sales Agreement does not match with the total quantity released on the associated sales order releases.',
      p_solution               => 'Agreement ##$$ORDERNUMBER$$## Released (ordered) quantity should match the actual ordered quantity on its associated releases.<br><br>
Review returned output to determine discrepancy, a Datafix may be required.  Refer to [1353041.1]',
      p_success_msg            => 'Agreement released quantity equals sales order releases.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('AGREEMENT_LINES_RELEASED_CHILD'),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_RELEASED_CHECKED');



debug('begin add_signature: AGREEMENT_LINES_FULFILLMENT_CHECKED');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8279',
      p_sig_id                 => 'AGREEMENT_LINES_FULFILLMENT_CHECKED',
      p_sig_sql                => 'select
bl.order_number "Agreement Number",
bl.line_number "Line Number",
bl.fulfilled_quantity "Agreement Fulfilled",
sum(nvl(ol.fulfilled_quantity,0)) "Releases Fulfilled",
ol.blanket_number "##$$FK1$$##",
ol.blanket_line_number "##$$FK2$$##"
from
oe_blanket_lines_ext bl,
oe_order_lines_all ol
where bl.order_number = ##$$ORDERNUMBER$$##
and NVL(''##$$LINEID$$##'',0) in (0,bl.line_id)
and bl.order_number = ol.blanket_number
and bl.line_number = ol.blanket_line_number
and ol.fulfilled_quantity > 0
and ol.fulfilled_flag= ''Y''
and ol.line_category_code = ''ORDER''
group by bl.order_number, bl.line_number, bl.fulfilled_quantity, ol.blanket_number, ol.blanket_line_number
having bl.fulfilled_quantity <> sum(nvl(ol.fulfilled_quantity,0))',
      p_title                  => 'Agreement Fulfillment Totals',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Fulfilled quantity on Sales Agreement does not match with the total quantity released.',
      p_solution               => 'The fulfilled quantity for the Agreement should match with the actual releases created.<br><br>
Review returned output to determine discrepancy, a Datafix may be required.  Refer to [2221988.1]',
      p_success_msg            => 'Agreement Fulfilled quantity equals the fulfilled releases.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('AGREEMENT_LINES_RELEASED_CHILD'),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_FULFILLMENT_CHECKED');





debug('begin add_signature: ONT_PROFILE_VALUES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5262',
      p_sig_id                 => 'ONT_PROFILE_VALUES',
      p_sig_sql                => 'SELECT user_profile_option_name "Profile Option",
             a.profile_option_value "Profile Value",
             DECODE(a.level_id, 10001, ''Site'',
                                10002, ''Application'',
                                10003, ''Responsibility'',
                                10004, ''User'') "Level",
             DECODE(a.level_id, 10001, ''Site'', 10002, b.application_short_name, 10003, c.responsibility_name, 10004, d.user_name) "Level Value",
             c.responsibility_id
      FROM fnd_profile_option_values a,
           fnd_application b,
           fnd_responsibility_tl c,
           fnd_user d,
           fnd_profile_options e,
           fnd_profile_options_tl t
      WHERE e.application_id like ##$$FK3$$##
        AND a.profile_option_id  = e.profile_option_id
        AND a.level_value          = b.application_id(+)
        AND a.level_value          = c.responsibility_id(+)
        AND a.level_value          = d.user_id(+)
        AND t.profile_option_name  = e.profile_option_name
        AND t.LANGUAGE             = ''US''
        AND nvl(c.LANGUAGE,''US'') = ''US''
     ORDER BY e.profile_option_name',
      p_title                  => 'Profile Values',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Profile Values found for ONT, WSH, QP, RLM, INV',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_PROFILE_VALUES');

debug('begin add_signature: ONT_PROFILE_OPTIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5253',
      p_sig_id                 => 'ONT_PROFILE_OPTIONS',
      p_sig_sql                => 'SELECT tl.Application_name, b.application_short_name,
            b.application_id "##$$FK3$$##",
            b.product_code "##$$FK4$$##"
      FROM fnd_application_tl tl, fnd_application b
      WHERE b.application_id in (660,665,661,662,401)
        AND tl.application_id = b.application_id
        AND tl.language = ''US''',
      p_title                  => 'Profile Options',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Profile Options found for ONT, WSH, QP, RLM, INV',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('ONT_PROFILE_VALUES'),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_PROFILE_OPTIONS');



debug('begin add_signature: AGREEMENT_HEADER_PRICING_INFORMATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7609',
      p_sig_id                 => 'AGREEMENT_HEADER_PRICING_INFORMATION',
      p_sig_sql                => 'select
     BLA.CONVERSION_TYPE_CODE	"Conversion Type Code",
     BLA.PRICE_LIST_ID			"Price List ID",
     (select distinct q.name price_list_name
       FROM qp_list_headers_vl q
       WHERE BLA.PRICE_LIST_ID = q.list_header_id) "Price List Name",
     BLA.TRANSACTIONAL_CURR_CODE 	"Transaction Currency"
from
   OE_BLANKET_HEADERS_ALL        BLA,
   OE_TRANSACTION_TYPES_TL       TYP,
   FND_LANGUAGES                 FLA
where
     BLA.HEADER_ID              = ##$$HEADERID$$##
and  TYP.LANGUAGE                  = FLA.LANGUAGE_CODE
and  FLA.INSTALLED_FLAG            = ''B''
and  BLA.ORDER_TYPE_ID             = TYP.TRANSACTION_TYPE_ID',
      p_title                  => 'Agreement Header Pricing Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Pricing Information',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_PRICING_INFORMATION');





debug('begin add_signature: ONT_PLSQL_FILE_VERSIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5251',
      p_sig_id                 => 'ONT_PLSQL_FILE_VERSIONS',
      p_sig_sql                => 'select
       o.object_name
     , substr(ltrim(rtrim(substr(substr(s.text, instr(s.text,''Header: '')),
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 1),
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 2) -
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 1) ))), 1, 25) "File Name"
     , substr(ltrim(rtrim(substr(substr(s.text, instr(s.text,''Header: '')),
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 2),
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 3) -
                                    instr(substr(s.text, instr(s.text,''Header: '')), '' '', 1, 2) ))), 1, 30) "File version"
     , decode(o.object_type, ''PACKAGE'' , ''SPEC'', ''PACKAGE BODY'', ''BODY'') type
     , o.object_type pkg_type
     , o.status status
     from  user_objects o , user_source s
     where s.name = o.object_name
     and   s.type = o.object_type
     and   o.object_type  in (''PACKAGE'' , ''PACKAGE BODY'')
     and   (o.object_name like ''##$$FK2$$##\_%'' escape ''\'')
     and   s.line between 2 and 3
     and   s.text like ''%Header: %''
     order by 1, 3 desc, 5 desc',
      p_title                  => 'PL SQL File Versions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No files found for ONT, WSH, QP, RLM, INV',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_PLSQL_FILE_VERSIONS');



debug('begin add_signature: ONT_OTHER_FILE_VERSIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5252',
      p_sig_id                 => 'ONT_OTHER_FILE_VERSIONS',
      p_sig_sql                => 'select distinct

           af.filename,
           substr(af.filename, instr(af.filename, ''.'')+1) ext
         , af.app_short_name
         , af.subdir
         , om_order_analyzer_pkg.get_file_ver(af.file_id)
      from   ad_files af, fnd_application fa
      where  af.app_short_name = fa.application_short_name
      and    fa.application_id = ##$$FK1$$##
      and    af.subdir not like ''admin%''
      and    af.subdir not like ''help%''
      and    af.subdir not like ''%driver%''
      and    af.subdir not like ''%readme%''
      and    substr(af.subdir, instr(af.subdir, ''/'', -1)+1) not in (select language_code
                                                                    from   fnd_languages
                                                                    where  installed_flag <> ''B'')
      and    af.filename not like ''%.txt''
      and    af.filename not like ''%.a''
      and    af.filename not like ''%.gif''
      and    af.filename not like ''%.htm''
      and    af.filename not like ''%.html''
      order by af.filename',
      p_title                  => 'Other File Versions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No files found for ONT, WSH, QP, RLM, INV',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_OTHER_FILE_VERSIONS');

debug('begin add_signature: ONT_FILE_VERSIONS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5243',
      p_sig_id                 => 'ONT_FILE_VERSIONS',
      p_sig_sql                => 'SELECT tl.Application_name, b.application_short_name,
            b.application_id "##$$FK1$$##",
            b.product_code "##$$FK2$$##"
       FROM fnd_application_tl tl, fnd_application b
      WHERE b.application_id in (660,665,661,662,401)
        AND tl.application_id = b.application_id
        AND tl.language = ''US''',
      p_title                  => 'File Versions',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No files found for ONT, WSH, QP, RLM, INV',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('ONT_PLSQL_FILE_VERSIONS','ONT_OTHER_FILE_VERSIONS'),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_FILE_VERSIONS');



debug('begin add_signature: AGREEMENT_HEADER_SHIPMENT_INFORMATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7610',
      p_sig_id                 => 'AGREEMENT_HEADER_SHIPMENT_INFORMATION',
      p_sig_sql                => 'select
     BLA.DELIVER_TO_ORG_ID 	"Deliver To Org ID",
     BLA.FREIGHT_TERMS_CODE	"Freight Terms Code",
     BLA.SHIPPING_METHOD_CODE	"Shipping Method Code"
from
   OE_BLANKET_HEADERS_ALL        BLA,
   OE_TRANSACTION_TYPES_TL       TYP,
   FND_LANGUAGES                 FLA
where
     BLA.HEADER_ID              = ##$$HEADERID$$##
and  TYP.LANGUAGE                  = FLA.LANGUAGE_CODE
and  FLA.INSTALLED_FLAG            = ''B''
and  BLA.ORDER_TYPE_ID             = TYP.TRANSACTION_TYPE_ID',
      p_title                  => 'Agreement Header Shipping Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Header Shipping Information',
      p_solution               => 'No Shipping Information entered for this Agreement',
      p_success_msg            => 'Agreement Header Shipping Information',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_SHIPMENT_INFORMATION');



debug('begin add_signature: AGREEMENT_LINES_RETURNED_CHECKED');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8280',
      p_sig_id                 => 'AGREEMENT_LINES_RETURNED_CHECKED',
      p_sig_sql                => 'select
bl.order_number "Agreement Number",
bl.line_number "Line Number",
bl.returned_quantity "Agreement Returned",
sum(nvl(ol.ordered_quantity,0)) "Releases Returned",
ol.blanket_number "##$$FK1$$##",
ol.blanket_line_number "##$$FK2$$##"
from
oe_blanket_lines_ext bl,
oe_order_lines_all ol
where bl.order_number = ##$$ORDERNUMBER$$##
and NVL(''##$$LINEID$$##'',0) in (0,bl.line_id)
and bl.order_number = ol.blanket_number
and bl.line_number = ol.blanket_line_number
and ol.fulfilled_quantity > 0
and ol.fulfilled_flag= ''Y''
and ol.line_category_code = ''RETURN''
group by bl.order_number, bl.line_number, bl.returned_quantity, ol.blanket_number, ol.blanket_line_number
having bl.returned_quantity <> sum(nvl(ol.ordered_quantity,0))',
      p_title                  => 'Agreement Return Totals',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Agreement return quantity on Sales Agreement does not match with the Release(s) return total.',
      p_solution               => 'The returned quantity on the Agreement should match with the actual returned releases total.<br><br>
Review returned output to determine discrepancy, a Datafix may be required.  Refer to [2221988.1]',
      p_success_msg            => 'Agreement returned quantity equals the releases returned.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL('AGREEMENT_LINES_RELEASED_CHILD'),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_RETURNED_CHECKED');



debug('begin add_signature: ONT_INVALID_OBJECTS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5278',
      p_sig_id                 => 'ONT_INVALID_OBJECTS',
      p_sig_sql                => 'SELECT a.object_name "Object Name",
           decode(a.object_type,
             ''PACKAGE'', ''Package Spec'',
             ''PACKAGE BODY'', ''Package Body'',
             a.object_type) type,
           (
             SELECT ltrim(rtrim(substr(substr(c.text, instr(c.text,''Header: '')),
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 1),
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 2) -
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 1)
               ))) || '' - '' ||
               ltrim(rtrim(substr(substr(c.text, instr(c.text,''Header: '')),
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 2),
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 3) -
               instr(substr(c.text, instr(c.text,''Header: '')), '' '', 1, 2)
               )))
             FROM dba_source c
             WHERE c.owner = a.owner
             AND   c.name = a.object_name
             AND   c.type = a.object_type
             AND   c.line = 2
             AND   c.text like ''%$Header%''
           ) "File Version",
           b.text "Error Text"
    FROM dba_objects a,
         dba_errors b
    WHERE a.object_name = b.name(+)
    AND a.object_type = b.type(+)
    AND a.owner = ''APPS''
    AND (a.object_name like ''ONT%'' OR
         a.object_name like ''WSH%'' OR
         a.object_name like ''QP%'' OR
         a.object_name like ''RLM%'' OR
         a.object_name like ''MTL%'' OR
         a.object_name like ''INV%'' OR
         a.object_name like ''FND%'')
    AND a.status = ''INVALID''
Order by 1, 2 desc',
      p_title                  => 'Invalid Objects',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Invalid objects exist that are related to Order Management',
      p_solution               => 'Recompile the individual objects or recompile the entire APPS schema using the adadmin utility.
Review any error messages provided and see [1363561.1] for details on compiling these invalid objects.',
      p_success_msg            => 'No invalid objects detected.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: ONT_INVALID_OBJECTS');



debug('begin add_signature: AGREEMENT_LINES_OPEN_PAST_EXPIRE_DATE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7649',
      p_sig_id                 => 'AGREEMENT_LINES_OPEN_PAST_EXPIRE_DATE',
      p_sig_sql                => 'select
oeh.order_number "Sales Order Number",
substr(to_char(oel.line_number) ||
decode(oel.shipment_number, null, null, ''.'' || to_char(oel.shipment_number))||
decode(oel.option_number, null, null, ''.'' || to_char(oel.option_number)) ||
decode(oel.component_number, null, null,
decode(oel.option_number, null, ''.'',null)||
''.''||to_char(oel.component_number))||
decode(oel.service_number,null,null,
decode(oel.component_number, null, ''.'' , null) ||
decode(oel.option_number, null, ''.'', null ) ||
''.''|| to_char(oel.service_number)),1,10) "SO Line",
oel.org_id "Org ID",
oel.ordered_item "Ordered Item",
oel.request_date "Request Date",
oel.ordered_quantity "Ordered Qty",
blx.line_number "Agreement Line Number",
blh.expiration_date "Agreement Expiration Date"
from oe_blanket_lines_ext blx,
oe_blanket_lines_all bll,
oe_blanket_headers_all blh,
oe_order_lines_all oel,
oe_order_headers_all oeh
where oel.blanket_number = ##$$ORDERNUMBER$$##
and oel.header_id = oeh.header_id
and blh.header_id = ##$$HEADERID$$##
and blh.header_id = bll.header_id
and bll.line_id = blx.line_id
and oel.request_date > blh.expiration_date',
      p_title                  => 'Sales Order Release Lines Open Past Agreement Header Expired Date',
      p_fail_condition         => '[Request Date] <> [Agreement Expiration Date]',
      p_problem_descr          => 'Agreement Releases exist past Expired Date.  Agreement will not Expire when expected.',
      p_solution               => 'Cancel or close listed sales order lines <BR><BR>
or<BR><BR>
Set the "Expiration Date" on the Agreement as same or later than date of the query output.<BR><BR>

Refer to [2067610.1] for additional details.',
      p_success_msg            => 'Agreement Release Lines are closed or will be closed prior to Agreement Header Expiration Date.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_OPEN_PAST_EXPIRE_DATE');



debug('begin add_signature: AGREEMENT_HEADER_INVOICE_INFORMATION');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7608',
      p_sig_id                 => 'AGREEMENT_HEADER_INVOICE_INFORMATION',
      p_sig_sql                => 'select
     BLA.ACCOUNTING_RULE_ID 			"Accounting Rule ID",
     BLA.INVOICE_TO_ORG_ID  			"Invoice To Org ID",
     (select name
      from hr_operating_units
      where organization_id = nvl(BLA.INVOICE_TO_ORG_ID,-99)) "Invoice To",
     BLA.INVOICING_RULE_ID			"Invoicing Rule ID",
     BLA.PAYMENT_TERM_ID			"Payment Term ID"
from
   OE_BLANKET_HEADERS_ALL        BLA,
   OE_TRANSACTION_TYPES_TL       TYP,
   FND_LANGUAGES                 FLA
where
     BLA.HEADER_ID              = ##$$HEADERID$$##
and  TYP.LANGUAGE                  = FLA.LANGUAGE_CODE
and  FLA.INSTALLED_FLAG            = ''B''
and  BLA.ORDER_TYPE_ID             = TYP.TRANSACTION_TYPE_ID',
      p_title                  => 'Agreement Header Invoice Information',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Agreement Invoice Information',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_INVOICE_INFORMATION');



debug('begin add_signature: AGREEMENT_HEADER_HISTORY');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '7715',
      p_sig_id                 => 'AGREEMENT_HEADER_HISTORY',
      p_sig_sql                => 'SELECT
HEADER_ID	"Header ID"
,ORG_ID		"Org ID"
,ORDER_TYPE_ID	"Order Type"
,      ORDER_NUMBER	"Agreement Number"
,      VERSION_NUMBER	"Version Number"
,      PRICE_LIST_ID	"Price List ID"
,      CONVERSION_TYPE_CODE	"Conversion Type"
,      TRANSACTIONAL_CURR_CODE	"Trans Curr Code"
,      CUST_PO_NUMBER	"Cust PO Number"
,      INVOICING_RULE_ID	"Invoicing Rule"
,      ACCOUNTING_RULE_ID	"Accounting Rule"
,      PAYMENT_TERM_ID	"Payment Term ID"
,      SHIPPING_METHOD_CODE	"Ship Method Code"
,      FREIGHT_TERMS_CODE	"Freight Terms Code"
,      SOLD_TO_ORG_ID	"Sold To Org ID"
,      SHIP_FROM_ORG_ID	"Ship From Org ID"
,      SHIP_TO_ORG_ID	"Ship To Org ID"
,      INVOICE_TO_ORG_ID	"Invoice To Org ID"
,      DELIVER_TO_ORG_ID	"Deliver To Org ID"
,      SOLD_TO_CONTACT_ID	"Sold To Contact"
,      SALESREP_ID		"Sales Rep"
,      ORDER_CATEGORY_CODE	"Order Category"
,      SHIPPING_INSTRUCTIONS	"Shipping Instruction"
,      PACKING_INSTRUCTIONS		"Packing Instruction"
,      FLOW_STATUS_CODE	"Flow Status"
,      START_DATE_ACTIVE	"Start Date Active"
,      END_DATE_ACTIVE	"End Date Active"
,      ON_HOLD_FLAG		"On Hold"
,      BLANKET_MAX_AMOUNT	"Agreement Max Amount"
,      BLANKET_MIN_AMOUNT	"Agreement Min Amount"
,      ENFORCE_PRICE_LIST_FLAG	"Enforce Price List"
,      OVERRIDE_AMOUNT_FLAG	"Override Amount"
,      RELEASED_AMOUNT	"Released Amount"
,      RETURNED_AMOUNT	"Returned Amount"
,      REVISION_CHANGE_REASON_CODE "Rev Change Reason Code"
,      REVISION_CHANGE_COMMENTS	"Rev Change Comments"
,      REVISION_CHANGE_DATE	"Rev Change Date"
,      ENFORCE_ACCOUNTING_RULE_FLAG	"Enforce Accounting Rule"
,      ENFORCE_INVOICING_RULE_FLAG	"Enforce Invoice Rule"
,      ENFORCE_SHIP_TO_FLAG		"Enforce Ship To"
,      ENFORCE_INVOICE_TO_FLAG	"Enforce Invoice To"
,      ENFORCE_FREIGHT_TERM_FLAG		"Enforce Freight Terms"
,      ENFORCE_SHIPPING_METHOD_FLAG	"Enforce Shipping Method"
,      ENFORCE_PAYMENT_TERM_FLAG	"Enforce Payment Term"
,      FULFILLED_AMOUNT 	"Fulfilled Amount"
,      SUPPLIER_SIGNATURE	"Supplier Signature"
,      SUPPLIER_SIGNATURE_DATE	"Supplier Signature Date"
,      CUSTOMER_SIGNATURE	"Customer Signature"
,      CUSTOMER_SIGNATURE_DATE	"Customer Signature Date"
,      QUOTE_NUMBER	"Quote Number"
,      QUOTE_DATE		"Quote Date"
,      NEW_PRICE_LIST_ID	"New Price List ID"
,      NEW_MODIFIER_LIST_ID	"New Modifier List ID"
,      AUDIT_FLAG	"Audit Flag"
,      VERSION_FLAG	"Version Flag"
,      PHASE_CHANGE_FLAG	"Phase Change Flag"
,      REASON_ID	"Reason ID"
,      ORDER_FIRMED_DATE	"Order Firmed Date"
FROM OE_BLANKET_HEADERS_HIST
where header_id = ##$$HEADERID$$##',
      p_title                  => 'Agreement Header History',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Reporting History of Sales Agreement, needed when versioning is on during negotiations.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('SUCCESS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('Y','RS'),
      p_limit_rows             => nvl('Y','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_HEADER_HISTORY');



debug('begin add_signature: ONT_DATABASE_TRIGGERS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5255',
      p_sig_id                 => 'ONT_DATABASE_TRIGGERS',
      p_sig_sql                => 'SELECT  atrg.table_owner,
            atrg.table_name,
            atrg.trigger_name,
            atrg.trigger_type,
            atrg.triggering_event,
            atrg.status
    FROM  all_triggers atrg, fnd_application fa
    WHERE fa.application_id in (660,665,661,662,401)
    AND   atrg.table_owner  = fa.application_short_name
    ORDER BY atrg.table_owner, atrg.table_name, atrg.trigger_type',
      p_title                  => 'Database Triggers',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Application Details found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_DATABASE_TRIGGERS');



debug('begin add_signature: AGREEMENT_LINES_RELEASED_PAST_LINE_EXPIRED_DATE');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '8499',
      p_sig_id                 => 'AGREEMENT_LINES_RELEASED_PAST_LINE_EXPIRED_DATE',
      p_sig_sql                => 'select
oeh.order_number "Sales Order Number",
    substr(to_char(oel.line_number) ||
          decode(oel.shipment_number, null, null, ''.'' || to_char(oel.shipment_number))||
          decode(oel.option_number, null, null, ''.'' || to_char(oel.option_number)) ||
          decode(oel.component_number, null, null,
                 decode(oel.option_number, null, ''.'',null)||
                 ''.''||to_char(oel.component_number))||
          decode(oel.service_number,null,null,
                 decode(oel.component_number, null, ''.'' , null) ||
                        decode(oel.option_number, null, ''.'', null ) ||
                        ''.''|| to_char(oel.service_number)),1,10)  "SO Line",
oel.org_id "Org ID",
oel.ordered_item "Ordered Item",
oel.request_date "Request Date",
oel.ordered_quantity "Ordered Qty",
blx.line_number "Agreement Line Number",
blx.end_date_active "Agreement Line End Date"
from oe_blanket_lines_ext blx,
oe_blanket_lines_all bll,
oe_blanket_headers_all blh,
oe_order_lines_all oel,
oe_order_headers_all oeh
where oel.blanket_number = ##$$ORDERNUMBER$$##
and oel.header_id = oeh.header_id
and blh.header_id = ##$$HEADERID$$##
and blh.header_id = bll.header_id
and bll.line_id = blx.line_id
and oel.request_date > blx.end_date_active',
      p_title                  => 'Sales Order Release Lines Open Past Agreement Line Expired Date',
      p_fail_condition         => '[Request Date] <> [Agreement Line End Date]',
      p_problem_descr          => 'Agreement Releases exist past Line Expired Date.  Open Release Line will not be able to progress to close.',
      p_solution               => 'Cancel listed sales order lines <BR><BR>
or<BR><BR>
Set the "Expiration Date" on the Agreement Line as same or later than date of the query output.<BR><BR>

Refer to [2067610.1] for additional details.',
      p_success_msg            => 'Agreement Release Lines are closed or will be closed prior to Agreement Line Expiration Date.',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('E','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: AGREEMENT_LINES_RELEASED_PAST_LINE_EXPIRED_DATE');



debug('begin add_signature: ONT_CUSTOM_DATABASE_TRIGGERS');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5258',
      p_sig_id                 => 'ONT_CUSTOM_DATABASE_TRIGGERS',
      p_sig_sql                => 'SELECT atrg.table_owner,
       atrg.table_name,
       atrg.trigger_name,
       atrg.trigger_type,
       atrg.triggering_event,
       atrg.status
FROM all_triggers atrg, fnd_application fa
WHERE fa.application_id in (660,665,661,662,401)
AND atrg.table_owner = fa.application_short_name
AND atrg.trigger_name like ''XX%''
AND atrg.status <> ''DISABLED''
ORDER BY atrg.table_owner, atrg.table_name, atrg.trigger_type',
      p_title                  => 'Custom Database Triggers',
      p_fail_condition         => 'RS',
      p_problem_descr          => 'Potential Custom Database Triggers',
      p_solution               => 'Disable custom database triggers.

For assistance, see the following <a href="https://docs.oracle.com/cd/B28359_01/server.111/b28310/general004.htm" target="_blank">Oracle documentation</a>',
      p_success_msg            => 'No custom database triggers detected',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('W','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('P','N')
      );
   l_info.delete;
debug('end add_signature: ONT_CUSTOM_DATABASE_TRIGGERS');



debug('begin add_signature: ONT_TABLE_INDEXES');
   l_info('##SHOW_SQL##'):= 'Y';
  add_signature(
      p_sig_repo_id            => '5256',
      p_sig_id                 => 'ONT_TABLE_INDEXES',
      p_sig_sql                => 'SELECT iu.name table_owner,
           io.name table_name,
           o.name index_name,
     decode(bitand(i.property, 16), 0, '''', ''FUNCTION-BASED '') ||
     decode(i.type#, 1, ''NORMAL''||
     decode(bitand(i.property, 4), 0, '''', 4, ''/REV''),
                      2, ''BITMAP'', 3, ''CLUSTER'', 4, ''IOT - TOP'',
                      5, ''IOT - NESTED'', 6, ''SECONDARY'', 7, ''ANSI'', 8, ''LOB'',
                      9, ''DOMAIN'') index_type,
           to_char(i.analyzetime, ''DD-MON-RR HH:MI:SS'') last_analyzed,
           decode(bitand(i.property, 2), 2, ''N/A'',
           decode(bitand(i.flags, 1), 1, ''UNUSABLE'',
           decode(bitand(i.flags, 8), 8, ''INRPOGRS'', ''VALID''))) status
    FROM sys.user$ iu,
         sys.obj$ io,
         sys.user$ u,
         sys.ind$ i,
         sys.obj$ o,
         fnd_application fa
    WHERE u.user# = o.owner#
    AND o.obj# = i.obj#
    AND i.bo# = io.obj#
    AND io.owner# = iu.user#
    AND io.type# = 2 -- tables
    AND i.type# in (1, 2, 3, 4, 6, 7, 9)
    AND fa.application_id in (660,665,661,662,401)
    And Iu.Name = Fa.Application_Short_Name
    ORDER BY iu.name, io.name, o.name',
      p_title                  => 'Table Indexes',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'No Table Indexes found.',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_TABLE_INDEXES');



debug('begin add_signature: ONT_SYSTEM_PARAMETERS');
  add_signature(
      p_sig_repo_id            => '5409',
      p_sig_id                 => 'ONT_SYSTEM_PARAMETERS',
      p_sig_sql                => 'select decode(t1.seeded_flag, ''Y'', ''Yes'', ''N'', ''No'', NULL) "Seeded Flag",
decode(t1.enabled_flag, ''Y'', ''Yes'', ''N'', ''No'', NULL) "Enabled Flag",
decode(t1.open_orders_check_flag, ''W'', ''Give Warning'', ''E'', ''Error'', ''N'', ''Allow'', NULL) "Open Orders Check Flag",
t1.category_code "Category Code",
t2.name "Name"
from OE_SYS_PARAMETER_DEF_TL t2,
OE_SYS_PARAMETER_DEF_B t1
where t2.parameter_code = t1.parameter_code
and t2.language = USERENV(''LANG'')
order by  t1.category_code , t2.Name',
      p_title                  => 'System Parameters',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'System Parameters',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_SYSTEM_PARAMETERS');



debug('begin add_signature: ONT_SYSTEM_PARAMETERS_VALUES');
  add_signature(
      p_sig_repo_id            => '5410',
      p_sig_id                 => 'ONT_SYSTEM_PARAMETERS_VALUES',
      p_sig_sql                => 'select t3.org_id "Org ID",
t2.name "Name",
OE_SYS_PARAMETERS_UTIL.Get_Value(t1.value_set_id, t3.parameter_value) "Parameter Value"
from	OE_SYS_PARAMETERS_ALL t3,
	OE_SYS_PARAMETER_DEF_TL t2,
	OE_SYS_PARAMETER_DEF_B t1
where	t2.parameter_code = t1.parameter_code
and	t2.language = USERENV(''LANG'')
and	t3.parameter_code = t2.parameter_code
order by t3.org_id, t1.category_code, t2.name',
      p_title                  => 'OM System Parameters - Values',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'OM System Parameters - Values',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_SYSTEM_PARAMETERS_VALUES');



debug('begin add_signature: ONT_PATCHES_APPLIED');
  add_signature(
      p_sig_repo_id            => '5413',
      p_sig_id                 => 'ONT_PATCHES_APPLIED',
      p_sig_sql                => 'select
    distinct
    aap.patch_name
  , substr(aap.patch_type, 1, 8) patch_type
  , aap.creation_date
  , ab.application_short_name
  from  ad_applied_patches aap,
        ad_patch_run_bugs ab
  where ab.application_short_name in (''QP'',''RLM'',''ONT'',''INV'',''WSH'' )
   and   ab.orig_bug_number        = aap.patch_name
  order by ab.application_short_name, aap.creation_date desc',
      p_title                  => 'Patches Applied',
      p_fail_condition         => 'NRS',
      p_problem_descr          => 'Patches Applied',
      p_solution               => '',
      p_success_msg            => '',
      p_print_condition        => nvl('ALWAYS','ALWAYS'),
      p_fail_type              => nvl('I','W'),
      p_print_sql_output       => nvl('RS','RS'),
      p_limit_rows             => nvl('N','Y'),
      p_extra_info             => l_info,
      p_child_sigs             => VARCHAR_TBL(),
      p_include_in_dx_summary  => nvl('Y','N')
      );
   l_info.delete;
debug('end add_signature: ONT_PATCHES_APPLIED');



EXCEPTION WHEN OTHERS THEN
  print_log('Error in load_signatures');
  raise;
END load_signatures;


---------------------------------
-- MAIN ENTRY POINT
---------------------------------
PROCEDURE main(
            p_header_id                    IN NUMBER      DEFAULT NULL
           ,p_line_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 20
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y')

 IS

  l_sql_result VARCHAR2(1);
  l_step       VARCHAR2(5);
  l_analyzer_end_time   TIMESTAMP;

BEGIN

  l_step := '1';
  initialize_globals;
  -- Workaround for handling debugging before file init
  g_debug_mode := nvl(p_debug_mode, 'Y');
  g_params_string := '';



  l_step := '10';
  initialize_files;

  analyzer_title := 'Sales Agreement';

  l_step := '15';

   validate_parameters(
     p_header_id                    => p_header_id
    ,p_line_id                      => p_line_id
    ,p_max_output_rows              => p_max_output_rows
    ,p_debug_mode                   => p_debug_mode  );


  l_step := '20';
  set_cloud_flag;

  l_step := '23';
  set_snap_days;

  l_step := '25';
  print_page_header;
  l_step := '30';
  print_rep_header(analyzer_title);
  print_execdetails;
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

debug('begin section: Header');
start_section('Header Information', 'Header');
   set_item_result(run_stored_sig('AGREEMENT_HEADER_NEGOTIATION_WORKFLOW_ACTIVITY'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_BLANKET_WORKFLOW_ACTIVITY'));
   IF (substr(g_rep_info('Apps Version'),1,4) = '12.2') THEN
      set_item_result(check_rec_patches_1);
   END IF;
   set_item_result(run_stored_sig('AGREEMENT_HEADER_INFORMATION'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_PRICING_INFORMATION'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_SHIPMENT_INFORMATION'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_INVOICE_INFORMATION'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_HISTORY'));
end_section;
debug('end section: Header');

debug('begin section: Lines');
start_section('Line Information', 'Lines');
   set_item_result(run_stored_sig('AGREEMENT_LINES_INFORMATION'));
   set_item_result(run_stored_sig('AGREEMENT_INLINE_PRICE_LIST'));
   set_item_result(run_stored_sig('AGREEMENT_LINE_HISTORY'));
end_section;
debug('end section: Lines');

debug('begin section: Releases');
start_section('Sales Order Release Information', 'Releases');
   set_item_result(run_stored_sig('AGREEMENT_HEADER_RELEASES'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_RELEASED'));
end_section;
debug('end section: Releases');

debug('begin section: Validations');
start_section('Agreement Validations', 'Validations');
   set_item_result(run_stored_sig('AGREEMENT_HEADER_APPROVALS'));
   set_item_result(run_stored_sig('AGREEMENT_HEADER_EXPIRED'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_RELEASED_CHECKED'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_FULFILLMENT_CHECKED'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_RETURNED_CHECKED'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_OPEN_PAST_EXPIRE_DATE'));
   set_item_result(run_stored_sig('AGREEMENT_LINES_RELEASED_PAST_LINE_EXPIRED_DATE'));
end_section;
debug('end section: Validations');

debug('begin section: Apps_Check');
start_section('Apps Check', 'Apps_Check');
   set_item_result(run_stored_sig('ONT_DB_RELEASE_INFO'));
   set_item_result(run_stored_sig('ONT_DB_PARAMETERS'));
   set_item_result(run_stored_sig('ONT_APPLICATION_DETAILS'));
   set_item_result(run_stored_sig('ONT_PROFILE_OPTIONS'));
   set_item_result(run_stored_sig('ONT_FILE_VERSIONS'));
   set_item_result(run_stored_sig('ONT_INVALID_OBJECTS'));
   set_item_result(run_stored_sig('ONT_DATABASE_TRIGGERS'));
   set_item_result(run_stored_sig('ONT_CUSTOM_DATABASE_TRIGGERS'));
   set_item_result(run_stored_sig('ONT_TABLE_INDEXES'));
   set_item_result(run_stored_sig('ONT_SYSTEM_PARAMETERS'));
   set_item_result(run_stored_sig('ONT_SYSTEM_PARAMETERS_VALUES'));
   set_item_result(run_stored_sig('ONT_PATCHES_APPLIED'));
end_section;
debug('end section: Apps_Check');



  -- End of Sections and signatures

  end_main_section;

  l_step := '140';


  g_analyzer_elapsed := stop_timer(g_analyzer_start_time);
  get_current_time(l_analyzer_end_time);

  print_execution_time (l_analyzer_end_time);

  print_mainpage;

  print_footer;


  print_hidden_xml;

  close_files;

EXCEPTION WHEN others THEN
  g_retcode := 2;
  g_errbuf := 'Error in main at step '||l_step||': '||sqlerrm;
  print_log(g_errbuf);

END main;


PROCEDURE main_cp(
            errbuf                         OUT VARCHAR2
           ,retcode                        OUT VARCHAR2
           ,p_header_id                    IN NUMBER      DEFAULT NULL
           ,p_line_id                      IN NUMBER      DEFAULT NULL
           ,p_max_output_rows              IN NUMBER      DEFAULT 20
           ,p_debug_mode                   IN VARCHAR2    DEFAULT 'Y'
)
 IS

BEGIN
  g_retcode := 0;
  g_errbuf := null;


   main(
     p_header_id                    => p_header_id
    ,p_line_id                      => p_line_id
    ,p_max_output_rows              => p_max_output_rows
    ,p_debug_mode                   => p_debug_mode  );


  retcode := g_retcode;
  errbuf  := g_errbuf;
EXCEPTION WHEN OTHERS THEN
  retcode := '2';
  errbuf := 'Error in main_cp: '||sqlerrm||' : '||g_errbuf;
END main_cp;


END om_agreement_analyzer_pkg;

/
