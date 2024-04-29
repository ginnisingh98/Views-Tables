--------------------------------------------------------
--  DDL for Package Body FII_AR_FACTS_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_FACTS_AGING_PKG" AS
/* $Header: FIIAR19B.pls 120.16 2007/09/24 17:57:41 mmanasse ship $ */

g_sysdate_time           DATE := SYSDATE;
g_sysdate                DATE := TRUNC(SYSDATE);

g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;
g_exception_msg          VARCHAR2(4000) := NULL;
g_prim_currency          VARCHAR2(15)   := NULL;
g_sec_currency           VARCHAR2(15)   := NULL;
g_prim_rate_type         VARCHAR2(30);
g_sec_rate_type          VARCHAR2(30);
g_state                  VARCHAR2(200);
g_global_start_date      DATE;
g_debug_flag             VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_collection_criteria    VARCHAR2(2) := NVL(FND_PROFILE.value('FII_AR_COLLECTION_CRITERIA'), 'TR');
g_primary_mau            NUMBER;
g_secondary_mau          NUMBER;
g_fii_user_id            NUMBER(15);
g_fii_login_id           NUMBER(15);
g_fii_schema             VARCHAR2(30);

G_TABLE_NOT_EXIST        EXCEPTION;
                         PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
G_MISSING_RATES          EXCEPTION;
G_MISS_GLOBAL_PARAMS     EXCEPTION;
G_NEED_SECONDARY_INFO    EXCEPTION;
G_INVALID_BUCKET_DEF     EXCEPTION;

--Bucket definitions for unapplied receipts
g_rct_bucket_name VARCHAR2(80);
g_rct_bucket_1_low  NUMBER;
g_rct_bucket_1_high NUMBER;
g_rct_bucket_2_low  NUMBER;
g_rct_bucket_2_high NUMBER;
g_rct_bucket_3_low  NUMBER;
 g_rct_bucket_3_high  NUMBER;

--Bucket definitions for current receivables aging
g_current_bucket_name VARCHAR2(80);
g_current_bucket_3_low  NUMBER;
g_current_bucket_3_high NUMBER;
g_current_bucket_2_low  NUMBER;
g_current_bucket_2_high NUMBER;
g_current_bucket_1_low  NUMBER;
  g_current_bucket_1_high  NUMBER;

--Bucket definitions for past due receivables aging
g_past_due_bucket_name VARCHAR2(80);
g_past_due_bucket_1_low  NUMBER;
g_past_due_bucket_1_high NUMBER;
g_past_due_bucket_2_low  NUMBER;
g_past_due_bucket_2_high NUMBER;
g_past_due_bucket_3_low  NUMBER;
g_past_due_bucket_3_high NUMBER;
g_past_due_bucket_4_low  NUMBER;
g_past_due_bucket_4_high NUMBER;
g_past_due_bucket_5_low  NUMBER;
g_past_due_bucket_5_high NUMBER;
g_past_due_bucket_6_low  NUMBER;
g_past_due_bucket_6_high NUMBER;
g_past_due_bucket_7_low  NUMBER;
 g_past_due_bucket_7_high  NUMBER;

-- ===========================================================================
-- AR DBI Incremental Extraction
-- ===========================================================================

G_LAST_UPDATE_DATE DATE;
G_MAX_PAYMENT_SCHEDULE_ID NUMBER(15);
G_MAX_RECEIVABLE_APPL_ID NUMBER(15);

-- ------------------------------------------------------------
-- Private Functions and Procedures
-- ------------------------------------------------------------

---------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
---------------------------------------------------

PROCEDURE Truncate_table (p_table_name VARCHAR2) IS
    l_stmt VARCHAR2(100);
BEGIN
    l_stmt := 'TRUNCATE table '||g_fii_schema||'.'||p_table_name;
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('');
      FII_UTIL.put_line(l_stmt);
    end if;
    EXECUTE IMMEDIATE l_stmt;

EXCEPTION
    WHEN G_TABLE_NOT_EXIST THEN
        null;      -- Oracle 942, table does not exist, no actions
    WHEN OTHERS THEN
        g_errbuf := 'Error in Procedure: TRUNCATE_TABLE  Message: '||sqlerrm;
        RAISE;
END Truncate_Table;


-------------------------------------------------------------------
-- PROCEDURE GET_BUCKET_RANGES
-- Purpose
-- This procedure gets the bucket range definitions for
-- Current Receivables, Past Due Receivables and Unapplied Receipts
-------------------------------------------------------------------
PROCEDURE GET_BUCKET_RANGES is

l_error_bucket_name VARCHAR2 (80);
l_error_bucket_ranges VARCHAR2 (200);
l_error_bucket_start NUMBER;

BEGIN

  --------------------------------------------
  --Unapplied Receipt Bucket
  --------------------------------------------
  g_state := 'Getting unapplied receipts aging bucket ranges';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  select bb.name,
		 bbc.range1_low, bbc.range1_high-1,
         bbc.range2_low, bbc.range2_high-1,
         bbc.range3_low, bbc.range3_high-1
  into g_rct_bucket_name,
	   g_rct_bucket_1_low, g_rct_bucket_1_high,
       g_rct_bucket_2_low, g_rct_bucket_2_high,
       g_rct_bucket_3_low, g_rct_bucket_3_high
  from bis_bucket_customizations bbc,
       bis_bucket_vl bb
  where bb.short_name  = 'FII_DBI_UNAPP_RECEIPT_BUCKET'
  and   bbc.bucket_id  = bb.bucket_id;
/*
    g_rct_bucket_name := 'FII Unapplied Receipts';
    g_rct_bucket_1_low  := 0;
    g_rct_bucket_1_high := 30;
    g_rct_bucket_2_low  := 31;
    g_rct_bucket_2_high := 60;--20;
    g_rct_bucket_3_low  := 61;--21;
      g_rct_bucket_3_high  := null; --always null
*/
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_rct_bucket_name ||' bucket definition:');
     FII_UTIL.put_line(g_rct_bucket_1_low||'-'||g_rct_bucket_1_high||', '||
				       g_rct_bucket_2_low||'-'||g_rct_bucket_2_high||', '||
				       g_rct_bucket_3_low||'-'||g_rct_bucket_3_high);
  end if;
/*
  dbms_output.put_line(g_rct_bucket_name ||' bucket definition:');
  dbms_output.put_line(g_rct_bucket_1_low||'-'||g_rct_bucket_1_high||', '||
				       g_rct_bucket_2_low||'-'||g_rct_bucket_2_high||', '||
				       g_rct_bucket_3_low||'-'||g_rct_bucket_3_high);
*/
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Validating restrictions on '||g_rct_bucket_name||' bucket definition');
  end if;

  IF (g_rct_bucket_1_low is null
      or g_rct_bucket_1_low <> 0
	  or (g_rct_bucket_2_low is not null and g_rct_bucket_2_low <> g_rct_bucket_1_high+1 )
	  or (g_rct_bucket_3_low is not null and g_rct_bucket_3_low <> g_rct_bucket_2_high+1 )
	  or (g_rct_bucket_2_low is null and g_rct_bucket_1_high is not null)
	  or (g_rct_bucket_3_low is null and g_rct_bucket_2_high is not null)
      or g_rct_bucket_3_high is not null
	  or (g_rct_bucket_1_high is null and (g_rct_bucket_2_low is not null or g_rct_bucket_2_high is not null
										   or g_rct_bucket_3_low is not null)))
  THEN
    g_retcode := -1;
    l_error_bucket_name := g_rct_bucket_name;
    l_error_bucket_start := 0;
    l_error_bucket_ranges := g_rct_bucket_1_low||'-'||g_rct_bucket_1_high||', '||
                             g_rct_bucket_2_low||'-'||g_rct_bucket_2_high||', '||
			     g_rct_bucket_3_low||'-'||g_rct_bucket_3_high;
    fnd_message.set_name('FII','FII_INVALID_BUCKET_DEF');
    fnd_message.set_token('BUCKET', g_rct_bucket_name, FALSE);
    fnd_message.set_token('RANGES', l_error_bucket_ranges, FALSE);
    fnd_message.set_token('START', l_error_bucket_start, FALSE);
    g_errbuf := fnd_message.get;
    RAISE G_INVALID_BUCKET_DEF;
  END IF;

  ------------------------------------------------
  --Current receivables bucket
  ------------------------------------------------
  g_state := 'Getting current receivables aging bucket ranges';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  select bb.name,
		 bbc.range1_low, bbc.range1_high-1,
         bbc.range2_low, bbc.range2_high-1,
         bbc.range3_low, bbc.range3_high-1
  into g_current_bucket_name,
	   g_current_bucket_1_low, g_current_bucket_1_high,
       g_current_bucket_2_low, g_current_bucket_2_high,
       g_current_bucket_3_low, g_current_bucket_3_high
  from bis_bucket_customizations bbc,
       bis_bucket_vl bb
  where bb.short_name  = 'FII_DBI_CURRENT_REC_BUCKET'
  and   bbc.bucket_id  = bb.bucket_id;
/*
  g_current_bucket_name := 'FII Current Receivables';
  g_current_bucket_1_low  := 0;
  g_current_bucket_1_high := 30;
  g_current_bucket_2_low  := 31;
  g_current_bucket_2_high := null;--61;
  g_current_bucket_3_low  := null;--61;
   g_current_bucket_3_high  := null; --always null
*/

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('FII Current Receivables bucket definition:');
     FII_UTIL.put_line(g_current_bucket_1_low||'-'||g_current_bucket_1_high||', '||
				       g_current_bucket_2_low||'-'||g_current_bucket_2_high||', '||
				       g_current_bucket_3_low||'-'||g_current_bucket_3_high);
  end if;
/*
  dbms_output.put_line('FII Current Receivables bucket definition:');
  dbms_output.put_line(g_current_bucket_1_low||'-'||g_current_bucket_1_high||', '||
				       g_current_bucket_2_low||'-'||g_current_bucket_2_high||', '||
				       g_current_bucket_3_low||'-'||g_current_bucket_3_high);
*/
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Validating restrictions on '||g_current_bucket_name||' bucket definition');
  end if;

  IF (g_current_bucket_1_low is null
      or g_current_bucket_1_low <> 0
	  or (g_current_bucket_2_low is not null and g_current_bucket_2_low <> g_current_bucket_1_high+1 )
	  or (g_current_bucket_3_low is not null and g_current_bucket_3_low <> g_current_bucket_2_high+1 )
	  or (g_current_bucket_2_low is null and g_current_bucket_1_high is not null)
	  or (g_current_bucket_3_low is null and g_current_bucket_2_high is not null)
      or g_current_bucket_3_high is not null
	  or (g_current_bucket_1_high is null and (g_current_bucket_2_low is not null or g_current_bucket_2_high is not null
										   or g_current_bucket_3_low is not null)))

  THEN
    g_retcode := -1;
    l_error_bucket_name := g_current_bucket_name;
    l_error_bucket_ranges := g_current_bucket_1_low||'-'||g_current_bucket_1_high||', '||
                             g_current_bucket_2_low||'-'||g_current_bucket_2_high||', '||
                             g_current_bucket_3_low||'-'||g_current_bucket_3_high;
    l_error_bucket_start := 0;
    fnd_message.set_name('FII','FII_INVALID_BUCKET_DEF');
    fnd_message.set_token('BUCKET', g_current_bucket_name, FALSE);
    fnd_message.set_token('RANGES', l_error_bucket_ranges, FALSE);
    fnd_message.set_token('START', l_error_bucket_start, FALSE);
    g_errbuf := fnd_message.get;
    RAISE G_INVALID_BUCKET_DEF;
  END IF;

  ------------------------------------------------
  --Past Due receivables bucket
  ------------------------------------------------
  g_state := 'Getting past due receivables aging bucket ranges';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  select bb.name,
		 bbc.range1_low, bbc.range1_high-1,
         bbc.range2_low, bbc.range2_high-1,
         bbc.range3_low, bbc.range3_high-1,
         bbc.range4_low, bbc.range4_high-1,
         bbc.range5_low, bbc.range5_high-1,
         bbc.range6_low, bbc.range6_high-1,
         bbc.range7_low, bbc.range7_high-1
  into g_past_due_bucket_name,
	   g_past_due_bucket_1_low, g_past_due_bucket_1_high,
       g_past_due_bucket_2_low, g_past_due_bucket_2_high,
       g_past_due_bucket_3_low, g_past_due_bucket_3_high,
       g_past_due_bucket_4_low, g_past_due_bucket_4_high,
       g_past_due_bucket_5_low, g_past_due_bucket_5_high,
       g_past_due_bucket_6_low, g_past_due_bucket_6_high,
       g_past_due_bucket_7_low, g_past_due_bucket_7_high
  from bis_bucket_customizations bbc,
       bis_bucket_vl bb
  where bb.short_name  = 'FII_DBI_PAST_DUE_REC_BUCKET'
  and   bbc.bucket_id  = bb.bucket_id;
/*
  g_past_due_bucket_name := 'FII Past Due Receivables';
  g_past_due_bucket_1_low  := 1;
  g_past_due_bucket_1_high := null;--30;
  g_past_due_bucket_2_low  := null;--31;
  g_past_due_bucket_2_high := null;--60;
  g_past_due_bucket_3_low  := null;--61;
  g_past_due_bucket_3_high := null;--90;
  g_past_due_bucket_4_low  := null;--91;
  g_past_due_bucket_4_high := null;--120;
  g_past_due_bucket_5_low  := null;--121;
  g_past_due_bucket_5_high := null;--150;
  g_past_due_bucket_6_low  := null;--151;
  g_past_due_bucket_6_high := null;--180;
  g_past_due_bucket_7_low  := null;--181;
   g_past_due_bucket_7_high := null;--
*/
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('FII Past Due Receivables bucket definition:');
     FII_UTIL.put_line(g_past_due_bucket_1_low||'-'||g_past_due_bucket_1_high||', '||
				       g_past_due_bucket_2_low||'-'||g_past_due_bucket_2_high||', '||
				       g_past_due_bucket_3_low||'-'||g_past_due_bucket_3_high||', '||
				       g_past_due_bucket_4_low||'-'||g_past_due_bucket_4_high||', '||
				       g_past_due_bucket_5_low||'-'||g_past_due_bucket_5_high||', '||
				       g_past_due_bucket_6_low||'-'||g_past_due_bucket_6_high||', '||
				       g_past_due_bucket_7_low||'-'||g_past_due_bucket_7_high);
  end if;
/*
  dbms_output.put_line('FII Past Due Receivables bucket definition:');
  dbms_output.put_line(g_past_due_bucket_1_low||'-'||g_past_due_bucket_1_high||', '||
				       g_past_due_bucket_2_low||'-'||g_past_due_bucket_2_high||', '||
				       g_past_due_bucket_3_low||'-'||g_past_due_bucket_3_high||', '||
				       g_past_due_bucket_4_low||'-'||g_past_due_bucket_4_high||', '||
				       g_past_due_bucket_5_low||'-'||g_past_due_bucket_5_high||', '||
				       g_past_due_bucket_6_low||'-'||g_past_due_bucket_6_high||', '||
				       g_past_due_bucket_7_low||'-'||g_past_due_bucket_7_high);
*/
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Validating restrictions on '||g_past_due_bucket_name||' bucket definition');
  end if;

  IF (g_past_due_bucket_1_low is null
      or g_past_due_bucket_1_low <> 1
	  or (g_past_due_bucket_2_low is not null and g_past_due_bucket_2_low <> g_past_due_bucket_1_high+1)
	  or (g_past_due_bucket_3_low is not null and g_past_due_bucket_3_low <> g_past_due_bucket_2_high+1)
	  or (g_past_due_bucket_4_low is not null and g_past_due_bucket_4_low <> g_past_due_bucket_3_high+1)
	  or (g_past_due_bucket_5_low is not null and g_past_due_bucket_5_low <> g_past_due_bucket_4_high+1)
	  or (g_past_due_bucket_6_low is not null and g_past_due_bucket_6_low <> g_past_due_bucket_5_high+1)
	  or (g_past_due_bucket_7_low is not null and g_past_due_bucket_7_low <> g_past_due_bucket_6_high+1)
	  or (g_past_due_bucket_2_low is null and g_past_due_bucket_1_high is not null)
	  or (g_past_due_bucket_3_low is null and g_past_due_bucket_2_high is not null)
	  or (g_past_due_bucket_4_low is null and g_past_due_bucket_3_high is not null)
	  or (g_past_due_bucket_5_low is null and g_past_due_bucket_4_high is not null)
	  or (g_past_due_bucket_6_low is null and g_past_due_bucket_5_high is not null)
	  or (g_past_due_bucket_7_low is null and g_past_due_bucket_6_high is not null)
      or g_past_due_bucket_7_high is not null
	  or (g_past_due_bucket_1_high is null and (g_past_due_bucket_2_low is not null or g_past_due_bucket_2_high is not null
										        or g_past_due_bucket_3_low is not null or g_past_due_bucket_3_high is not null
												or g_past_due_bucket_4_low is not null or g_past_due_bucket_4_high is not null
												or g_past_due_bucket_5_low is not null or g_past_due_bucket_5_high is not null
												or g_past_due_bucket_6_low is not null or g_past_due_bucket_6_high is not null
												or g_past_due_bucket_7_low is not null))
	  or (g_past_due_bucket_2_high is null and (g_past_due_bucket_3_low is not null or g_past_due_bucket_3_high is not null
												or g_past_due_bucket_4_low is not null or g_past_due_bucket_4_high is not null
												or g_past_due_bucket_5_low is not null or g_past_due_bucket_5_high is not null
												or g_past_due_bucket_6_low is not null or g_past_due_bucket_6_high is not null
												or g_past_due_bucket_7_low is not null))
	  or (g_past_due_bucket_3_high is null and (g_past_due_bucket_4_low is not null or g_past_due_bucket_4_high is not null
												or g_past_due_bucket_5_low is not null or g_past_due_bucket_5_high is not null
												or g_past_due_bucket_6_low is not null or g_past_due_bucket_6_high is not null
												or g_past_due_bucket_7_low is not null))
	  or (g_past_due_bucket_4_high is null and (g_past_due_bucket_5_low is not null or g_past_due_bucket_5_high is not null
												or g_past_due_bucket_6_low is not null or g_past_due_bucket_6_high is not null
												or g_past_due_bucket_7_low is not null))
	  or (g_past_due_bucket_5_high is null and (g_past_due_bucket_6_low is not null or g_past_due_bucket_6_high is not null
												or g_past_due_bucket_7_low is not null)))
  THEN
    g_retcode := -1;
    l_error_bucket_name := g_past_due_bucket_name;
    l_error_bucket_ranges := g_past_due_bucket_1_low||'-'||g_past_due_bucket_1_high||', '||
                             g_past_due_bucket_2_low||'-'||g_past_due_bucket_2_high||', '||
                             g_past_due_bucket_3_low||'-'||g_past_due_bucket_3_high||', '||
                             g_past_due_bucket_4_low||'-'||g_past_due_bucket_4_high||', '||
                             g_past_due_bucket_5_low||'-'||g_past_due_bucket_5_high||', '||
                             g_past_due_bucket_6_low||'-'||g_past_due_bucket_6_high||', '||
                             g_past_due_bucket_7_low||'-'||g_past_due_bucket_7_high;
    l_error_bucket_start := 1;
    fnd_message.set_name('FII','FII_INVALID_BUCKET_DEF');
    fnd_message.set_token('BUCKET', g_past_due_bucket_name, FALSE);
    fnd_message.set_token('RANGES', l_error_bucket_ranges, FALSE);
    fnd_message.set_token('START', l_error_bucket_start, FALSE);
    g_errbuf := fnd_message.get;
    RAISE G_INVALID_BUCKET_DEF;
  END IF;


EXCEPTION
   WHEN G_INVALID_BUCKET_DEF THEN
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      FII_UTIL.write_output(g_errbuf);
      RAISE;
  WHEN OTHERS THEN
       g_retcode := -1;
       g_errbuf := '
---------------------------------
Error in Procedure: GET_BUCKET_RANGES
Message: '||sqlerrm;
       RAISE;

END GET_BUCKET_RANGES;



-------------------------------------------------------------------
-- PROCEDURE Init
-- Purpose
-- This procedure initializes the global variables.
-------------------------------------------------------------------
PROCEDURE Init is

  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);
  l_global_param_list dbms_sql.varchar2_table;

BEGIN

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('g_collection_criteria = '||g_collection_criteria);
  end if;

  g_state := 'Initializing the global variables';

  -- Find the schema owner
  IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema)) THEN
      NULL;
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('g_fii_schema is '||g_fii_schema);
      end if;
  END IF;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing the Global Currency Precision');
  end if;

  g_primary_mau := nvl(fii_currency.get_mau_primary, 0.01 );
  g_secondary_mau:= nvl(fii_currency.get_mau_secondary, 0.01);

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing the Global Currencies');
  end if;

  g_prim_currency := bis_common_parameters.get_currency_code;
  g_sec_currency := bis_common_parameters.get_secondary_currency_code;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing Global Currency Rate Types');
  end if;

  g_prim_rate_type := bis_common_parameters.get_rate_type;
  g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('Initializing the Global Start Date');
  end if;

  g_global_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('g_global_start_date = '||g_global_start_date);
  end if;

  l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
  l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
  l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';
  IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
       RAISE G_MISS_GLOBAL_PARAMS;
  END IF;

  if ((g_sec_currency IS NULL and g_sec_rate_type IS NOT NULL) OR
      (g_sec_currency IS NOT NULL and g_sec_rate_type IS NULL)) THEN
         RAISE G_NEED_SECONDARY_INFO;
  END IF;

  g_fii_user_id :=  FND_GLOBAL.User_Id;
  g_fii_login_id := FND_GLOBAL.Login_Id;

  IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
      RAISE G_LOGIN_INFO_NOT_AVABLE;
  END IF;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
  end if;

EXCEPTION
   WHEN G_LOGIN_INFO_NOT_AVABLE THEN
        g_retcode := -1;
        g_errbuf := 'Can not get User ID and Login ID, program exit';
        RAISE;

   WHEN G_MISS_GLOBAL_PARAMS THEN
        g_retcode := -1;
        g_errbuf := fnd_message.get_string('FII', 'FII_BAD_GLOBAL_PARA');
        RAISE;

   WHEN G_NEED_SECONDARY_INFO THEN
        g_retcode := -1;
        g_errbuf := fnd_message.get_string('FII', 'FII_AP_SEC_MISS');
        RAISE;

  WHEN OTHERS THEN
       g_retcode := -1;
       g_errbuf := '
---------------------------------
Error in Procedure: INIT
Message: '||sqlerrm;
       RAISE;

END Init;


------------------------------------
---- PROCEDURE INSERT_RATES
------------------------------------
PROCEDURE Insert_Rates IS

BEGIN

  g_state := 'Loading data into rates table FII_AR_CURR_RATES_T';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  INSERT /*+ append */ INTO FII_AR_CURR_RATES_T
  (SELECT sob.currency_code fc_code,
	        Decode(NVL(cur.minimum_accountable_unit,
                       power( 10, (-1 * cur.precision))),
                   null, 0.01,
                   0, 1,
                   NVL(cur.minimum_accountable_unit,
                       power( 10, (-1 * cur.precision)))) functional_mau,
	        conversion_date,
	        MAX(FII_CURRENCY.Get_FC_to_PGC_Rate (v.tc_code,
                     sob.currency_code, v.conversion_date)) prim_conversion_rate,
	        MAX(FII_CURRENCY.Get_FC_to_SGC_Rate (v.tc_code,
                     sob.currency_code, v.conversion_date)) sec_conversion_rate,
  		    sysdate,       --CREATION_DATE,
		    g_fii_user_id, --CREATED_BY,
		    sysdate,       --LAST_UPDATE_DATE,
		    g_fii_user_id, --LAST_UPDATED_BY,
		    g_fii_login_id --LAST_UPDATE_LOGIN
	 FROM (--Currency rates for payment schedules and receipts
	       SELECT /*+ no_merge parallel(sch) */ DISTINCT
				  sch.invoice_currency_code tc_code,
	              sch.org_id,
	              trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) conversion_date
	    	   FROM AR_PAYMENT_SCHEDULES_ALL sch
	    	   WHERE sch.class IN ('INV','DM','CB','CM','DEP','BR','PMT')
	    	   AND decode(g_collection_criteria,
                                         'GL', sch.gl_date,
                                         sch.trx_date) >= g_global_start_date

              UNION

              --receipts created prior to GSD and applied after GSD
              SELECT  DISTINCT
                      sch.invoice_currency_code tc_code,
	              sch.org_id,
	              trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) conversion_date
	    	  FROM AR_PAYMENT_SCHEDULES_ALL sch,
                       AR_RECEIVABLE_APPLICATIONS_ALL app,
                       AR_PAYMENT_SCHEDULES_ALL trxsch
                  WHERE sch.class = 'PMT'
                  AND sch.payment_schedule_id = app.payment_schedule_id
                  AND app.applied_customer_trx_id = trxsch.customer_trx_id
                  AND app.status = 'APP'
                  AND decode(g_collection_criteria,
                                         'GL', sch.gl_date,
                                         sch.trx_date) < g_global_start_date
                  AND decode(g_collection_criteria,
                                         'GL', trxsch.gl_date,
                                         trxsch.trx_date) >= g_global_start_date
	       ) v,
	       ar_system_parameters_all par,
	       gl_sets_of_books sob,
	       fnd_currencies cur
	 WHERE v.org_id = par.org_id
	 AND par.set_of_books_id = sob.set_of_books_id
	 AND cur.currency_code = sob.currency_code
     GROUP BY sob.currency_code,
	          cur.minimum_accountable_unit,
              cur.precision,
  	          conversion_date);


  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  COMMIT;
/*
--------------------
--Temporarily added to avoid: missing currency conversion rates error
---------------------
update FII_AR_CURR_RATES_T
set prim_conversion_rate=1
where prim_conversion_rate<=0;

update FII_AR_CURR_RATES_T
set sec_conversion_rate=1
where sec_conversion_rate<=0;
commit;
------------------------
*/

  g_state := 'Analyzing FII_AR_CURR_RATES_T table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_CURR_RATES_T');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Insert_Rates;


----------------------------------------------------------
--  FUNCTION VERIFY_MISSING_RATES
-----------------------------------------------------------
FUNCTION Verify_Missing_Rates RETURN NUMBER IS
  l_miss_rates_prim   NUMBER := 0;
  l_miss_rates_sec    NUMBER := 0;

  --------------------------------------------------------
  -- Cursor declaration required to generate output file
  -- containing rows with MISSING CONVERSION RATES
  --------------------------------------------------------

  CURSOR prim_MissingRate IS
  SELECT DISTINCT fc_code From_Currency,
         decode(prim_conversion_rate,-3,  to_date('01/01/1999','MM/DD/YYYY'),
         conversion_date) Trx_Date
  FROM   FII_AR_CURR_RATES_T RATES
  WHERE  RATES.Prim_Conversion_Rate < 0 ;

  CURSOR sec_MissingRate IS
  SELECT DISTINCT fc_code From_Currency,
         decode(sec_conversion_rate,-3,  to_date('01/01/1999','MM/DD/YYYY'),
         conversion_date) Trx_Date
  FROM   FII_AR_CURR_RATES_T RATES
  WHERE  RATES.Sec_Conversion_Rate < 0 ;


BEGIN
  g_state := 'Checking to see which additional rates need to be defined, if any';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  SELECT COUNT(*)
  INTO   l_miss_rates_prim
  FROM   FII_AR_CURR_RATES_T RATES
  WHERE  RATES.Prim_Conversion_Rate < 0;

  SELECT COUNT(*)
  INTO   l_miss_rates_sec
  FROM   FII_AR_CURR_RATES_T RATES
  WHERE  RATES.Sec_Conversion_Rate < 0;


  --------------------------------------------------------
  -- Print out missing rates report
  --------------------------------------------------------

   IF (l_miss_rates_prim > 0 OR
       l_miss_rates_sec  > 0) THEN
       BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

     FOR rate_record in prim_MissingRate
     LOOP
         BIS_COLLECTION_UTILITIES.writeMissingRate(
                       g_prim_rate_type,
                       rate_record.from_currency,
                       g_prim_currency,
                       rate_record.trx_date);

--		 dbms_output.put_line('Prim Type: '|| g_prim_rate_type||' - From: '|| rate_record.from_currency||' - Prim: '||g_prim_currency||' - Date: '||rate_record.trx_date);

     END LOOP;


     FOR rate_record in sec_MissingRate
     LOOP
         BIS_COLLECTION_UTILITIES.writeMissingRate(
                    g_sec_rate_type,
                    rate_record.from_currency,
                    g_sec_currency,
                    rate_record.trx_date);

--		 dbms_output.put_line('Sec Type: '|| g_sec_rate_type||' - From: '|| rate_record.from_currency||' - Sec: '||g_sec_currency||' - Date: '||rate_record.trx_date);

     END LOOP;
     RETURN -1;

  ELSE
        RETURN 1;
  END IF;  /* IF (l_miss_rates_prim > 0) */

EXCEPTION
  WHEN OTHERS THEN
       g_errbuf:=sqlerrm;
       g_retcode:= -1;
       g_exception_msg  := g_retcode || ':' || g_errbuf;
       FII_UTIL.put_line('Error occured while ' || g_state);
       FII_UTIL.put_line(g_exception_msg);
       RAISE;
END Verify_Missing_Rates;


------------------------------------------------------------------
-- Procedure POPULATE_PAYMENT_SCHEDULES
-- Purpose
--   This procedure inserts records in FII_AR_PMT_SCHEDULES_F
------------------------------------------------------------------
PROCEDURE POPULATE_PAYMENT_SCHEDULES IS

l_max_pmt_schedule_id NUMBER(15);

BEGIN

  g_state := 'Truncating table FII_AR_PMT_SCHEDULES_F';
  TRUNCATE_TABLE('FII_AR_PMT_SCHEDULES_F');

  g_state := 'Populating FII_AR_PMT_SCHEDULES_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


    INSERT /*+ append parallel(F) */ INTO FII_AR_PMT_SCHEDULES_F F
	 (payment_schedule_id,
	  time_id,
	  class,
	  amount_due_original_trx,
	  amount_due_original_func,
	  amount_due_original_prim,
	  amount_due_original_sec,
	  amount_due_remaining_trx,
	  amount_due_remaining_func,
	  amount_due_remaining_prim,
	  amount_due_remaining_sec,
	  trx_date,
	  gl_date,
	  filter_date,
	  due_date,
	  status,
	  customer_trx_id,
	  invoice_currency_code,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id,
	  user_id,
	  cust_trx_type_id,
	  transaction_number,
	  term_id,
	  terms_sequence_number,
	  batch_source_id,
	  earned_discount_amount_trx,
	  earned_discount_amount_func,
	  earned_discount_amount_prim,
	  earned_discount_amount_sec,
	  unearned_discount_amount_trx,
	  unearned_discount_amount_func,
	  unearned_discount_amount_prim,
	  unearned_discount_amount_sec,
	  adjusted_amount_trx,
	  adjusted_amount_func,
	  adjusted_amount_prim,
	  adjusted_amount_sec,
	  disputed_amount_trx,
	  disputed_amount_func,
	  disputed_amount_prim,
	  disputed_amount_sec,
	  order_ref_number,
	  actual_date_closed ,
	  exchange_rate,
	  exchange_date,
	  previous_customer_trx_id,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
    SELECT /*+ parallel(SCH) parallel(TRX) parallel(RT) parallel(SOB) */
          sch.payment_schedule_id,
          to_number(to_char(decode(g_collection_criteria,
                                  'GL', decode(tp.signed_flag, 'Y', h.gl_date, sch.gl_date),
                                  decode(tp.signed_flag, 'Y', h.trx_date, sch.trx_date)) , 'J')) time_id,
          sch.class,
          sch.amount_due_original amount_due_original_trx,
		  NVL(ROUND(sch.amount_due_original * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.amount_due_original,0)) amount_due_original_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) amount_due_original_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_original_sec,
          sch.amount_due_remaining amount_due_remaining_trx,
          NVL(ROUND(sch.amount_due_remaining * nvl(sch.exchange_rate,1) /
			  rt.functional_mau) * rt.functional_mau,
			  nvl(sch.amount_due_remaining,0)) amount_due_remaining_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau ) *
                    g_primary_mau) amount_due_remaining_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_remaining_sec,
          decode(tp.signed_flag, 'Y', trunc(h.trx_date), trunc(sch.trx_date)) trx_date,
          decode(tp.signed_flag, 'Y', trunc(h.gl_date), trunc(sch.gl_date)) gl_date,
	  decode(g_collection_criteria,
                 'GL', decode(tp.signed_flag, 'Y', h.gl_date, sch.gl_date),
                 decode(tp.signed_flag, 'Y', h.trx_date, sch.trx_date)) filter_date,
          trunc(sch.due_date),
          sch.status,
          sch.customer_trx_id,
          sch.invoice_currency_code,
          sch.customer_id bill_to_customer_id,
          sch.customer_site_use_id bill_to_site_use_id,
          sch.org_id,
          sch.created_by user_id,
          sch.cust_trx_type_id cust_trx_type_id,
          sch.trx_number transaction_number,
          sch.term_id,
 		  sch.terms_sequence_number,
          trx.batch_source_id,
          sch.discount_taken_earned earned_discount_amount_trx,
		  NVL(ROUND(sch.discount_taken_earned * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.discount_taken_earned,0))  earned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) earned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) earned_discount_amount_sec,
          nvl(sch.discount_taken_unearned,0)  unearned_discount_amount_trx,
		  NVL(ROUND(sch.discount_taken_unearned * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.discount_taken_unearned,0))  unearned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) unearned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) unearned_discount_amount_sec,
          nvl(sch.amount_adjusted,0) adjusted_amount_trx,
		  NVL(ROUND(sch.amount_adjusted * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.amount_adjusted,0)) adjusted_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) adjusted_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) adjusted_amount_sec,
          nvl(sch.amount_in_dispute,0) disputed_amount_trx,
		  NVL(ROUND(sch.amount_in_dispute * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau ,
				nvl(sch.amount_in_dispute,0)) disputed_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) disputed_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) disputed_amount_sec,
		  decode(trx.batch_source_id,
		   		 -1, trx.ct_reference,
		   		 null) order_ref_number,
		  sch.actual_date_closed,
		  nvl(sch.exchange_rate,1),
		  nvl(sch.exchange_date, sch.trx_date),
		  trx.previous_customer_trx_id,
		  sysdate,       --CREATION_DATE,
		  g_fii_user_id, --CREATED_BY,
		  sysdate,       --LAST_UPDATE_DATE,
		  g_fii_user_id, --LAST_UPDATED_BY,
		  g_fii_login_id --LAST_UPDATE_LOGIN
    FROM AR_PAYMENT_SCHEDULES_ALL sch,
 		 RA_CUSTOMER_TRX_ALL trx,
 		 FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob,
         AR_TRANSACTION_HISTORY_ALL h,
         RA_CUST_TRX_TYPES_ALL tp
    WHERE sch.class IN ('INV','DM','CB','CM','DEP','BR', 'PMT')
    AND decode(g_collection_criteria,
			   'GL', sch.gl_date,
			   sch.trx_date) >= g_global_start_date
    AND sch.customer_trx_id = trx.customer_trx_id (+)
    AND sch.customer_trx_id = h.customer_trx_id (+)
    AND sch.cust_trx_type_id = tp.cust_trx_type_id (+)
    AND sch.org_id = tp.org_id (+)
    AND (sch.class <> 'BR'
         OR (sch.class = 'BR' and tp.signed_flag = 'N' and h.current_record_flag = 'Y')
         OR (sch.class = 'BR' and tp.signed_flag = 'Y' and h.event = 'ACCEPTED'))

    AND sch.org_id = par.org_id
    AND par.set_of_books_id = sob.set_of_books_id
    AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date

    UNION ALL

    --PMT records which are created prior to GSD and applied after GSD
    SELECT DISTINCT
          sch.payment_schedule_id,
          to_number(to_char(decode(g_collection_criteria,
			   					   'GL', sch.gl_date,
			   					   sch.trx_date), 'J')) time_id,
          sch.class,
          sch.amount_due_original amount_due_original_trx,
		  NVL(ROUND(sch.amount_due_original * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.amount_due_original,0)) amount_due_original_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) amount_due_original_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_original_sec,
          sch.amount_due_remaining amount_due_remaining_trx,
          NVL(ROUND(sch.amount_due_remaining * nvl(sch.exchange_rate,1) /
			  rt.functional_mau) * rt.functional_mau,
			  nvl(sch.amount_due_remaining,0)) amount_due_remaining_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau ) *
                    g_primary_mau) amount_due_remaining_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_remaining_sec,
          sch.trx_date,
          sch.gl_date,
		  decode(g_collection_criteria,'GL',sch.gl_date,sch.trx_date) filter_date,
          sch.due_date,
          sch.status,
          sch.customer_trx_id,
          sch.invoice_currency_code,
          sch.customer_id bill_to_customer_id,
          sch.customer_site_use_id bill_to_site_use_id,
          sch.org_id,
          sch.created_by user_id,
          sch.cust_trx_type_id cust_trx_type_id,
          sch.trx_number transaction_number,
          sch.term_id,
 		  sch.terms_sequence_number,
          null batch_source_id,
          sch.discount_taken_earned earned_discount_amount_trx,
		  NVL(ROUND(sch.discount_taken_earned * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.discount_taken_earned,0))  earned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) earned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) earned_discount_amount_sec,
          nvl(sch.discount_taken_unearned,0)  unearned_discount_amount_trx,
		  NVL(ROUND(sch.discount_taken_unearned * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.discount_taken_unearned,0))  unearned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) unearned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) unearned_discount_amount_sec,
          nvl(sch.amount_adjusted,0) adjusted_amount_trx,
		  NVL(ROUND(sch.amount_adjusted * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau,
				nvl(sch.amount_adjusted,0)) adjusted_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) adjusted_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) adjusted_amount_sec,
          nvl(sch.amount_in_dispute,0) disputed_amount_trx,
		  NVL(ROUND(sch.amount_in_dispute * nvl(sch.exchange_rate,1) /
				rt.functional_mau) * rt.functional_mau ,
				nvl(sch.amount_in_dispute,0)) disputed_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) disputed_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) disputed_amount_sec,
		  null order_ref_number,
		  sch.actual_date_closed,
		  nvl(sch.exchange_rate,1),
		  nvl(sch.exchange_date, sch.trx_date),
		  null previous_customer_trx_id,
		  sysdate,       --CREATION_DATE,
		  g_fii_user_id, --CREATED_BY,
		  sysdate,       --LAST_UPDATE_DATE,
		  g_fii_user_id, --LAST_UPDATED_BY,
		  g_fii_login_id --LAST_UPDATE_LOGIN
    FROM AR_PAYMENT_SCHEDULES_ALL sch,
         AR_RECEIVABLE_APPLICATIONS_ALL app,
         AR_PAYMENT_SCHEDULES_ALL trxsch,
 	 FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob
    WHERE sch.class = 'PMT'
    AND sch.payment_schedule_id = app.payment_schedule_id
    AND app.applied_payment_schedule_id = trxsch.payment_schedule_id
    AND app.status = 'APP'
    AND decode(g_collection_criteria,
			   'GL', sch.gl_date,
			   sch.trx_date) < g_global_start_date
    AND decode(g_collection_criteria,
			   'GL', trxsch.gl_date,
			   trxsch.trx_date) >= g_global_start_date

    AND sch.org_id = par.org_id
    AND par.set_of_books_id = sob.set_of_books_id
    AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_PMT_SCHEDULES_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_PMT_SCHEDULES_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_PMT_SCHEDULES_F');

  g_state := 'Logging maximum payment schedule id into fii_change_log table';
  select nvl(max(payment_schedule_id), -999)
  into l_max_pmt_schedule_id
  from fii_ar_pmt_schedules_f;

  INSERT INTO fii_change_log
  (log_item, item_value, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
  (SELECT 'AR_MAX_PAYMENT_SCHEDULE_ID',
		l_max_pmt_schedule_id,
		sysdate,        --CREATION_DATE,
	    g_fii_user_id,  --CREATED_BY,
        sysdate,        --LAST_UPDATE_DATE,
	    g_fii_user_id,  --LAST_UPDATED_BY,
	    g_fii_login_id  --LAST_UPDATE_LOGIN
   FROM DUAL
   WHERE NOT EXISTS
  	  (select 1 from fii_change_log
	   where log_item = 'AR_MAX_PAYMENT_SCHEDULE_ID'));

  IF (SQL%ROWCOUNT = 0) THEN
	  UPDATE fii_change_log
	  SET item_value = l_max_pmt_schedule_id,
	      last_update_date  = g_sysdate_time,
	      last_update_login = g_fii_login_id,
	      last_updated_by   = g_fii_user_id
	  WHERE log_item = 'AR_MAX_PAYMENT_SCHEDULE_ID';
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_PAYMENT_SCHEDULES;


------------------------------------------------------------------
-- Procedure POPULATE_DISPUTES
-- Purpose
--   This procedure inserts records in FII_AR_DISPUTE_HISTORY_F
------------------------------------------------------------------
PROCEDURE POPULATE_DISPUTES IS
BEGIN

  g_state := 'Truncating table FII_AR_DISPUTE_HISTORY_F';
  TRUNCATE_TABLE('FII_AR_DISPUTE_HISTORY_F');

  g_state := 'Populating FII_AR_DISPUTE_HISTORY_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	INSERT INTO FII_AR_DISPUTE_HISTORY_F
     (dispute_history_id,
	  time_id,
	  dispute_amount_trx,
	  dispute_amount_func,
	  dispute_amount_prim,
	  dispute_amount_sec,
	  start_date,
	  end_date,
	  org_id,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  payment_schedule_id,
	  customer_trx_id,
	  due_date,
	  actual_date_closed,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
    SELECT /*+ parallel(DIS) parallel(SCH) parallel(RT) parallel(SOB) */
          dis.dispute_history_id,
	  to_number(to_char(dis.start_date, 'J')), --time_id,
	  dis.dispute_amount, --dis.dispute_amount_trx
	  NVL(ROUND(dis.dispute_amount * sch.exchange_rate / rt.functional_mau)
			* rt.functional_mau, nvl(dis.dispute_amount,0)), --dispute_amount_func
      DECODE(sch.invoice_currency_code,
            g_prim_currency, nvl(dis.dispute_amount,0),
            ROUND((nvl(dis.dispute_amount,0) * sch.exchange_rate *
                rt.prim_conversion_rate) / g_primary_mau) *
                g_primary_mau), --dispute_amount_prim
      DECODE(sch.invoice_currency_code,
            g_sec_currency, nvl(dis.dispute_amount,0),
            ROUND((nvl(dis.dispute_amount,0) * sch.exchange_rate *
                rt.sec_conversion_rate) / g_secondary_mau) *
                g_secondary_mau),  --dispute_amount_sec
	  dis.start_date,
	  dis.end_date,
	  sch.org_id,
	  sch.bill_to_customer_id,
	  sch.bill_to_site_use_id,
	  dis.payment_schedule_id,
	  sch.customer_trx_id,
	  sch.due_date,
	  sch.actual_date_closed,
	  sysdate,       --CREATION_DATE,
	  g_fii_user_id, --CREATED_BY,
	  sysdate,       --LAST_UPDATE_DATE,
	  g_fii_user_id, --LAST_UPDATED_BY,
	  g_fii_login_id --LAST_UPDATE_LOGIN
	FROM AR_DISPUTE_HISTORY dis,
	     FII_AR_PMT_SCHEDULES_F sch,
	     FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
	     GL_SETS_OF_BOOKS sob
	WHERE dis.payment_schedule_id = sch.payment_schedule_id
	AND sch.class <> 'PMT'
	AND dis.start_date <= sch.actual_date_closed
	AND dis.start_date >= g_global_start_date
	AND dis.last_update_date <= g_sysdate_time  --To avoid duplication in incremental

    AND sch.org_id = par.org_id
	AND par.set_of_books_id = sob.set_of_books_id
	AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_DISPUTE_HISTORY_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_DISPUTE_HISTORY_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_DISPUTE_HISTORY_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_DISPUTES;


------------------------------------------------------------------
-- Procedure POPULATE_TRANSACTIONS
-- Purpose
--   This procedure inserts records in FII_AR_TRANSACTIONS_F
------------------------------------------------------------------
PROCEDURE POPULATE_TRANSACTIONS IS
BEGIN

  g_state := 'Truncating table MLOG$_FII_AR_TRANSACTIONS_F';
  TRUNCATE_TABLE('MLOG$_FII_AR_TRANSACTIONS_F');
  g_state := 'Truncating table FII_AR_TRANSACTIONS_F';
  TRUNCATE_TABLE('FII_AR_TRANSACTIONS_F');

  g_state := 'Populating FII_AR_TRANSACTIONS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	INSERT /*+ append parallel(F) */ INTO FII_AR_TRANSACTIONS_F F
	 (customer_trx_id,
	  org_id,
	  time_id,
	  trx_date,
	  gl_date,
	  class,
	  amount_due_original_trx,
	  amount_due_original_func,
	  amount_due_original_prim,
	  amount_due_original_sec,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  transaction_number,
	  cust_trx_type_id,
	  term_id,
	  batch_source_id,
	  filter_date,
	  order_ref_number,
	  invoice_currency_code,
	  exchange_rate,
	  exchange_date,
	  initial_customer_trx_id,
	  previous_customer_trx_id,
	  user_id,
	  ar_creation_date,
	  INV_ba_amount_func,
	  INV_ba_amount_prim,
	  INV_ba_amount_sec,
	  INV_ba_count,
	  DM_ba_amount_func,
	  DM_ba_amount_prim,
	  DM_ba_amount_sec,
	  DM_ba_count,
	  CB_ba_amount_func,
	  CB_ba_amount_prim,
	  CB_ba_amount_sec,
	  CB_ba_count,
	  BR_ba_amount_func,
	  BR_ba_amount_prim,
	  BR_ba_amount_sec,
	  BR_ba_count,
	  DEP_ba_amount_func,
	  DEP_ba_amount_prim,
	  DEP_ba_amount_sec,
	  DEP_ba_count,
	  CM_ba_amount_func,
	  CM_ba_amount_prim,
	  CM_ba_amount_sec,
	  CM_ba_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT /*+ parallel(TRX) parallel(SCH) */
                trx.customer_trx_id,
		trx.org_id,
		to_number(to_char(decode(g_collection_criteria,
			                     'GL', sch.gl_date,
			                     trx.trx_date), 'J')), --time_id
		trunc(trx.trx_date),
		sch.gl_date,
		sch.class, --class
		sum(nvl(sch.amount_due_original_trx,0)),
		sum(nvl(sch.amount_due_original_func,0)),
		sum(nvl(sch.amount_due_original_prim,0)),
		sum(nvl(sch.amount_due_original_sec,0)),
		NVL(trx.bill_to_customer_id, trx.drawee_id), -- drawee_id used for BR
		NVL(trx.bill_to_site_use_id,
			trx.drawee_site_use_id), --drawee_site_use_id used for BR
		trx.trx_number,
		trx.cust_trx_type_id,
		trx.term_id,
		trx.batch_source_id,
		decode(g_collection_criteria,'GL', sch.gl_date, trx.trx_date), --filter_date
		decode(trx.batch_source_id,
			   -1, trx.ct_reference,  --order_ref_number
			   null),   -- -1 indicates that the trx is a manual order entry
		trx.invoice_currency_code,
		nvl(trx.exchange_rate,1),    --exchange_rate
        nvl(trx.exchange_date,trx.trx_date), --exchange_date
	    trx.initial_customer_trx_id,
		trx.previous_customer_trx_id,
		trx.created_by, --user_id
		trx.creation_date, --ar_creation_date
  		decode(sch.class,'INV',sum(nvl(sch.amount_due_original_func,0)),0), --INV_ba_amount_func
  		decode(sch.class,'INV',sum(nvl(sch.amount_due_original_prim,0)),0), --INV_ba_amount_prim
  		decode(sch.class,'INV',sum(nvl(sch.amount_due_original_sec,0)),0),  --INV_ba_amount_sec
  		decode(sch.class,'INV',1,0), --INV_ba_count
  		decode(sch.class,'DM',sum(nvl(sch.amount_due_original_func,0)),0), --DM_ba_amount_func
  		decode(sch.class,'DM',sum(nvl(sch.amount_due_original_prim,0)),0), --DM_ba_amount_prim
  		decode(sch.class,'DM',sum(nvl(sch.amount_due_original_sec,0)),0),  --DM_ba_amount_sec
  		decode(sch.class,'DM',1,0), --DM_ba_count
  		decode(sch.class,'CB',sum(nvl(sch.amount_due_original_func,0)),0), --CB_ba_amount_func
  		decode(sch.class,'CB',sum(nvl(sch.amount_due_original_prim,0)),0), --CB_ba_amount_prim
  		decode(sch.class,'CB',sum(nvl(sch.amount_due_original_sec,0)),0),  --CB_ba_amount_sec
  		decode(sch.class,'CB',1,0), --CB_ba_count
  		decode(sch.class,'BR',sum(nvl(sch.amount_due_original_func,0)),0), --BR_ba_amount_func
  		decode(sch.class,'BR',sum(nvl(sch.amount_due_original_prim,0)),0), --BR_ba_amount_prim
  		decode(sch.class,'BR',sum(nvl(sch.amount_due_original_sec,0)),0),  --BR_ba_amount_sec
  		decode(sch.class,'BR',1,0), --BR_ba_count
  		decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_func,0)),0), --DEP_ba_amount_func
  		decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_prim,0)),0), --DEP_ba_amount_prim
  		decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_sec,0)),0), --DEP_ba_amount_sec
  		decode(sch.class,'DEP',1,0), --DEP_ba_count
  		decode(sch.class,'CM',sum(nvl(sch.amount_due_original_func,0)),0), --CM_ba_amount_func
  		decode(sch.class,'CM',sum(nvl(sch.amount_due_original_prim,0)),0), --CM_ba_amount_prim
  		decode(sch.class,'CM',sum(nvl(sch.amount_due_original_sec,0)),0), --CM_ba_amount_sec
  		decode(sch.class,'CM',1,0), --CM_ba_count
	    sysdate,       --CREATION_DATE,
	    g_fii_user_id, --CREATED_BY,
	    sysdate,       --LAST_UPDATE_DATE,
	    g_fii_user_id, --LAST_UPDATED_BY,
	    g_fii_login_id --LAST_UPDATE_LOGIN
	FROM ra_customer_trx_all trx,
	 	 FII_AR_PMT_SCHEDULES_F sch
	WHERE trx.customer_trx_id = sch.customer_trx_id
	AND sch.class <> 'PMT'
	AND decode(g_collection_criteria,
			   'GL', sch.gl_date,
				trx.trx_date) >= g_global_start_date
	GROUP BY trx.customer_trx_id,
			trx.org_id,
			to_number(to_char(trx.trx_date, 'J')), --time_id,
			trx.trx_date,
			sch.gl_date,
			sch.class,
			NVL(trx.bill_to_customer_id, trx.drawee_id),
			NVL(trx.bill_to_site_use_id, trx.drawee_site_use_id),
			trx.trx_number,
			trx.cust_trx_type_id,
			trx.term_id,
			trx.trx_date, --filter_date
			trx.invoice_currency_code,
		 	trx.exchange_rate,
            trx.exchange_date,
  	        trx.batch_source_id,
			trx.ct_reference,
			trx.initial_customer_trx_id,
		    trx.previous_customer_trx_id,
			trx.created_by,
			trx.creation_date;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_TRANSACTIONS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_TRANSACTIONS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_TRANSACTIONS_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_TRANSACTIONS;


------------------------------------------------------------------
-- Procedure POPULATE_ADJUSTMENTS
-- Purpose
--   This procedure inserts records in FII_AR_ADJUSTMENTS_F
------------------------------------------------------------------
PROCEDURE POPULATE_ADJUSTMENTS IS
BEGIN

  g_state := 'Truncating table FII_AR_ADJUSTMENTS_F';
  TRUNCATE_TABLE('FII_AR_ADJUSTMENTS_F');

  g_state := 'Populating FII_AR_ADJUSTMENTS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	INSERT /*+ append */ INTO FII_AR_ADJUSTMENTS_F
	 (adjustment_id,
	  time_id ,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id,
	  amount_trx,
	  amount_func,
	  amount_prim,
	  amount_sec,
	  apply_date,
	  gl_date,
	  filter_date,
	  customer_trx_id,
	  payment_schedule_id,
	  user_id,
	  ar_creation_date,
	  adj_class,
	  subsequent_trx_id,
	  br_customer_trx_id,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT /*+ parallel(ADJ) parallel(TRX) parallel(TRX2) parallel(LINE) parallel(SOB) parallel(RT) */
          adj.adjustment_id,
          to_number(to_char(decode(g_collection_criteria,
			                       'GL', adj.gl_date,
			                       adj.apply_date), 'J')), --adj.time_id,
          trx.bill_to_customer_id, -- drawee_id only in case of BR
          trx.bill_to_site_use_id, -- drawee_site_use_id only in case of BR
          adj.org_id,
          adj.amount,
          NVL(ROUND(adj.amount * trx.exchange_rate / rt.functional_mau)
				* rt.functional_mau, nvl(adj.amount,0)), --adj.amount_func
          DECODE(trx.invoice_currency_code,
                g_prim_currency, nvl(adj.amount,0),
                ROUND((nvl(adj.amount,0) * trx.exchange_rate *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau),    --adj.amount_prim
          DECODE(trx.invoice_currency_code,
                g_sec_currency, nvl(adj.amount,0),
                ROUND((nvl(adj.amount,0) * trx.exchange_rate *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau),  --adj.amount_sec
          trunc(adj.apply_date),
          trunc(adj.gl_date),
          decode(g_collection_criteria,'GL',adj.gl_date,adj.apply_date), --filter_date
          adj.customer_trx_id,
          adj.payment_schedule_id,
		  adj.created_by, --user_id
		  adj.creation_date, --ar_creation_date
		  decode(line.br_adjustment_id,
			     null, decode(adj.chargeback_customer_trx_id,
							  null, decode(adj.adjustment_type,'C','DEP',null),
							  'CB'),
			     'BR'), --adj_class
          adj.subsequent_trx_id,
          line.customer_trx_id, --br_customer_trx_id
	      sysdate,       --CREATION_DATE,
	      g_fii_user_id, --CREATED_BY,
	      sysdate,       --LAST_UPDATE_DATE,
	      g_fii_user_id, --LAST_UPDATED_BY,
	      g_fii_login_id --LAST_UPDATE_LOGIN
    FROM AR_ADJUSTMENTS_ALL adj,
         FII_AR_TRANSACTIONS_F trx,
		 FII_AR_TRANSACTIONS_F trx2, --makes sure the CM adj does not result from a GUAR
		 RA_CUSTOMER_TRX_LINES_ALL line,
		 FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob
	WHERE adj.status = 'A'
        AND adj.customer_trx_id = trx.customer_trx_id
	/*AND adj.customer_trx_id = decode(trx.class,
									 'CM', trx.previous_customer_trx_id,
									 trx.customer_trx_id)
	AND decode (adj.subsequent_trx_id,
				null, -111, 0, -111,
				adj.subsequent_trx_id) = decode(trx.class,
												  'CM', trx.customer_trx_id,
												  -111)*/
	AND nvl(trx.initial_customer_trx_id, trx.customer_trx_id) =
			trx2.customer_trx_id --makes sure the CM adj does not result from a GUAR
    AND adj.adjustment_id = line.br_adjustment_id (+)
	AND adj.last_update_date <= g_sysdate_time  --To avoid duplication in incremental

    AND trx.org_id = par.org_id
	AND par.set_of_books_id = sob.set_of_books_id
	AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(trx.exchange_date,trx.trx_date),sysdate)) = rt.conversion_date;
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_ADJUSTMENTS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_ADJUSTMENTS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_ADJUSTMENTS_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_ADJUSTMENTS;

------------------------------------------------------------------
-- Procedure POPULATE_RECEIPTS
-- Purpose
--   This procedure inserts records in FII_AR_RECEIPTS_F
------------------------------------------------------------------
PROCEDURE POPULATE_RECEIPTS IS

l_max_rec_application_id NUMBER(15);

BEGIN

  g_state := 'Truncating table MLOG$_FII_AR_RECEIPTS_F';
  TRUNCATE_TABLE('MLOG$_FII_AR_RECEIPTS_F');
  g_state := 'Truncating table FII_AR_RECEIPTS_F';
  TRUNCATE_TABLE('FII_AR_RECEIPTS_F');

  g_state := 'Populating FII_AR_RECEIPTS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	INSERT /*+ append parallel(F) */ INTO FII_AR_RECEIPTS_F F
     (receivable_application_id,
	  time_id,
	  cash_receipt_id,
	  application_status,
	  header_status,
	  amount_applied_rct,
	  amount_applied_trx,
	  amount_applied_rct_func,
	  amount_applied_trx_func,
	  amount_applied_rct_prim,
	  amount_applied_trx_prim,
	  amount_applied_rct_sec,
	  amount_applied_trx_sec,
	  earned_discount_amount_trx,
	  earned_discount_amount_func,
	  earned_discount_amount_prim,
	  earned_discount_amount_sec,
	  unearned_discount_amount_trx,
	  unearned_discount_amount_func,
	  unearned_discount_amount_prim,
	  unearned_discount_amount_sec,
	  apply_date,
	  gl_date,
	  filter_date,
      header_filter_date,
	  application_type,
	  applied_payment_schedule_id,
	  applied_customer_trx_id,
	  customer_trx_id,
	  payment_schedule_id,
	  receipt_number,
	  receipt_type,
	  receipt_date,
	  rct_actual_date_closed,
	  receipt_method_id,
	  currency_code,
	  user_id ,
	  ar_creation_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  collector_bill_to_customer_id,
	  collector_bill_to_site_use_id,
	  org_id,
	  trx_date,
	  due_date,
	  cm_previous_customer_trx_id,
	  total_receipt_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
    SELECT app.RECEIVABLE_APPLICATION_ID,
        to_number(to_char(decode(g_collection_criteria,
							     'GL',app.app_gl_date,
								 app.apply_date), 'J')), --TIME_ID,
        rct.cash_receipt_id,
        decode(app.status,'ACTIVITY','APP',app.status) APPLICATION_STATUS,
        rct.status HEADER_STATUS,
        NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)), --AMOUNT_APPLIED_RCT,
        NVL(app.AMOUNT_APPLIED,0), --AMOUNT_APPLIED_TRX,
        app.acctd_amount_applied_from, --AMOUNT_APPLIED_RCT_FUNC,
        NVL(app.acctd_amount_applied_to,0), --AMOUNT_APPLIED_TRX_FUNC,
        DECODE(rct.cash_receipt_id,
			   null, 0,
			   decode (rct.currency_code,
		               g_prim_currency, NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)),
			           ROUND((NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)) * nvl(rct.exchange_rate,1) *
			                nvl(rct.prim_conversion_rate,1)) / g_primary_mau) *
			                g_primary_mau)),    --AMOUNT_APPLIED_RCT_PRIM,
        DECODE(app.applied_payment_schedule_id,
			   null, 0,
 			   decode (trxsch.invoice_currency_code,
            		   g_prim_currency, nvl(app.AMOUNT_APPLIED,0),
		               ROUND((nvl(app.AMOUNT_APPLIED,0) * nvl(trxsch.exchange_rate,1) *
		                nvl(trxsch.prim_conversion_rate,0)) / g_primary_mau) *
		                g_primary_mau)),    --AMOUNT_APPLIED_TRX_PRIM,
        DECODE(rct.cash_receipt_id,
			   null, 0,
			   decode (rct.currency_code,
		               g_sec_currency, NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)),
		               ROUND((NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)) * nvl(rct.exchange_rate,1) *
			                nvl(rct.sec_conversion_rate,1)) / g_secondary_mau) *
			                g_secondary_mau)),    --AMOUNT_APPLIED_RCT_SEC,
	    DECODE(app.applied_payment_schedule_id,
			   null, 0,
 			   decode (trxsch.invoice_currency_code,
            		   g_sec_currency, nvl(app.AMOUNT_APPLIED,0),
			           ROUND((nvl(app.AMOUNT_APPLIED,0) * nvl(trxsch.exchange_rate,1) *
			                nvl(trxsch.sec_conversion_rate,0)) / g_secondary_mau) *
			                g_secondary_mau)),    --AMOUNT_APPLIED_TRX_SEC,
        nvl(app.EARNED_DISCOUNT_TAKEN,0), --EARNED_DISCOUNT_amount_trx,
        NVL(app.acctd_earned_discount_taken,
				nvl(app.EARNED_DISCOUNT_TAKEN,0)), --EARNED_DISCOUNT_AMOUNT_FUNC,
        DECODE(trxsch.invoice_currency_code,
            g_prim_currency, nvl(app.EARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.EARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.prim_conversion_rate,1)) / g_primary_mau) *
                g_primary_mau),    --EARNED_DISCOUNT_AMOUNT_PRIM,
        DECODE(trxsch.invoice_currency_code,
            g_sec_currency, nvl(app.EARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.EARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.sec_conversion_rate,1)) / g_secondary_mau) *
                g_secondary_mau),  --EARNED_DISCOUNT_AMOUNT_SEC,
        nvl(app.UNEARNED_DISCOUNT_TAKEN,0), --UNEARNED_DISCOUNT_amount_trx,
        NVL(app.acctd_unearned_discount_taken,
			nvl(app.UNEARNED_DISCOUNT_TAKEN,0)), --UNEARNED_DISCOUNT_AMOUNT_FUNC,
        DECODE(trxsch.invoice_currency_code,
            g_prim_currency, nvl(app.UNEARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.UNEARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.prim_conversion_rate,1)) / g_primary_mau) *
                g_primary_mau),   --UNEARNED_DISCOUNT_AMOUNT_PRIM
        DECODE(trxsch.invoice_currency_code,
            g_sec_currency, nvl(app.UNEARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.UNEARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.sec_conversion_rate,1)) / g_secondary_mau) *
                g_secondary_mau),   --UNEARNED_DISCOUNT_AMOUNT_SEC
        trunc(app.APPLY_DATE),
        trunc(app.RCT_GL_DATE),
        decode(g_collection_criteria,
			   'GL',app.app_gl_date,
			   app.apply_date), --FILTER_DATE,
        per.start_date, --decode(g_collection_criteria,'GL',app.rct_gl_date,rct.receipt_date), --HEADER_FILTER_DATE,
        app.APPLICATION_TYPE,
        app.APPLIED_PAYMENT_SCHEDULE_ID,
		app.applied_customer_trx_id,
        app.CUSTOMER_TRX_ID,
        app.PAYMENT_SCHEDULE_ID,
        rct.RECEIPT_NUMBER,
        rct.RECEIPT_TYPE,
        trunc(rct.receipt_date),
		rctsch.actual_date_closed, --rct_actual_date_closed
        rct.receipt_method_id,
        rct.CURRENCY_CODE,
        app.created_by, --USER_ID
  	    app.creation_date, --ar_creation_date
        decode(app.status,
			   'UNID', -2,
               nvl(rctsch.bill_to_customer_id, -2)), --to avoid outer joins in MVs --bill_to_customer_id
        decode(app.status,
			   'UNID', -2,
			   nvl(rctsch.bill_to_site_use_id, -2)), --bill_to_site_use_id
	    case when trxsch.payment_schedule_id is null
				  or app.applied_payment_schedule_id < 0
				then nvl(rctsch.bill_to_customer_id,-2)
			 else nvl(trxsch.bill_to_customer_id,-2) end, --collector_bill_to_customer_id
	    case when trxsch.payment_schedule_id is null
				  or app.applied_payment_schedule_id < 0
				then nvl(rctsch.bill_to_site_use_id,-2)
			 else nvl(trxsch.bill_to_site_use_id,-2) end, --collector_bill_to_site_use_id
		app.org_id,
		trxsch.trx_date,
		trxsch.due_date,
		rctsch.previous_customer_trx_id, --cm_previous_customer_trx_id
		decode (app.receivable_application_id,
				MIN(app.receivable_application_id) over (partition by rct.cash_receipt_id), 1,
                                MAX(app.receivable_application_id) over (partition by rct.cash_receipt_id),
                                      case when rct.status = 'REV' or rct.status = 'NSF' or rct.status = 'STOP'
                                      then -1 else 0 end,
				0), --total_receipt_count
	    sysdate,       --CREATION_DATE,
	    g_fii_user_id, --CREATED_BY,
	    sysdate,       --LAST_UPDATE_DATE,
	    g_fii_user_id, --LAST_UPDATED_BY,
	    g_fii_login_id --LAST_UPDATE_LOGIN
    FROM  (select /*+ parallel(app) */
                                RECEIVABLE_APPLICATION_ID,
				cash_receipt_id,
				case when gl_date >= g_global_start_date then
                                            gl_date
                                     else g_global_start_date end app_gl_date,
				decode (application_type,
						'CM',gl_date,
						MIN(gl_date) over (partition by cash_receipt_id)) rct_gl_date, --to get the receipt creation gl_date instead of appl gl_date
				case when apply_date >= g_global_start_date then
                                            apply_date
                                     else g_global_start_date end apply_date,
				status,
				AMOUNT_APPLIED_FROM,
				AMOUNT_APPLIED,
				acctd_amount_applied_from,
				acctd_amount_applied_to,
				applied_customer_trx_id,
				EARNED_DISCOUNT_TAKEN,
				acctd_earned_discount_taken,
				UNEARNED_DISCOUNT_TAKEN,
				acctd_unearned_discount_taken,
				APPLICATION_TYPE,
				applied_payment_schedule_id,
				CUSTOMER_TRX_ID,
				PAYMENT_SCHEDULE_ID,
				created_by,
				creation_date,
				org_id
		  from AR_RECEIVABLE_APPLICATIONS_ALL app) app,

	     FII_AR_PMT_SCHEDULES_F rctsch,

		 (select /*+ parallel(RCT) parallel(RCTRT) parallel(SOB) */
                rct.cash_receipt_id,
                rct.status,
                rct.currency_code,
        		nvl(rct.exchange_rate,1) exchange_rate,
                rctrt.prim_conversion_rate,
                rctrt.sec_conversion_rate,
                rct.RECEIPT_NUMBER,
                rct.TYPE receipt_type,
                rct.receipt_date,
                rct.receipt_method_id
                --rct.pay_from_customer bill_to_customer_id,
                --NVL(rct.customer_site_use_id,
        		--	-1) bill_to_site_use_id, --(-1 for UNAPP, UNID)
                --rct.customer_site_use_id
         from AR_CASH_RECEIPTS_ALL rct,
              FII_AR_CURR_RATES_T rctrt,
              AR_SYSTEM_PARAMETERS_ALL par,
              GL_SETS_OF_BOOKS sob
         where --rct.receipt_date >= g_global_start_date
	         rct.org_id = par.org_id
         and par.set_of_books_id = sob.set_of_books_id
         and sob.currency_code = rctrt.fc_code
         and rctrt.conversion_date = trunc(least(nvl(rct.exchange_date,
							rct.receipt_date),sysdate))) rct,

		(select /*+ parallel(TRXRT) parallel(TRXSCH) parallel(SOB) */
                trxsch.payment_schedule_id,
                trxsch.invoice_currency_code,
                trxsch.exchange_rate exchange_rate,
                trxrt.prim_conversion_rate,
                trxrt.sec_conversion_rate,
        		trxsch.trx_date, --trx_date
	           	trxsch.due_date, --due_date
				trxsch.bill_to_customer_id,
				trxsch.bill_to_site_use_id
         from FII_AR_PMT_SCHEDULES_F trxsch,
              FII_AR_CURR_RATES_T trxrt,
              AR_SYSTEM_PARAMETERS_ALL par,
              GL_SETS_OF_BOOKS sob
         where trxsch.org_id = par.org_id
         AND par.set_of_books_id = sob.set_of_books_id
         AND sob.currency_code = trxrt.fc_code
         AND trxrt.conversion_date = trunc(least(nvl(trxsch.exchange_date,
							trxsch.trx_date),sysdate))) trxsch,
        gl_periods per,
        ar_system_parameters_all par,
        gl_sets_of_books sob

    WHERE app.payment_schedule_id = rctsch.payment_schedule_id
    AND rctsch.class in ('PMT', 'CM')
	AND app.application_type IN ('CASH','CM')
    --AND (app.status IN ('UNID','UNAPP','APP')
    --     or app.applied_payment_schedule_id IN (-1,-4,-7))
    AND app.cash_receipt_id = rct.cash_receipt_id (+)
    AND app.applied_payment_schedule_id = trxsch.payment_schedule_id (+)
    AND par.org_id = app.org_id
    AND sob.set_of_books_id = par.set_of_books_id
    AND per.period_set_name = sob.period_set_name
    AND per.period_type = sob.accounted_period_type
    AND decode(application_type,
               'CM', app.apply_date,
               decode(g_collection_criteria,
                      'GL',app.rct_gl_date,
                      rct.receipt_date)) between per.start_date and per.end_date
    AND per.adjustment_period_flag = 'N'
    AND (case when decode(g_collection_criteria,
		          'GL', rct_gl_date,
		          rct.receipt_date)  >= g_global_start_date
		   then 1
              when decode(g_collection_criteria,
		          'GL', rct_gl_date,
		          rct.receipt_date)  < g_global_start_date
                      and exists (select 'x' from ar_receivable_applications_all app2
                                  where app2.cash_receipt_id = app.cash_receipt_id
                                  and decode(g_global_start_date,
                                             'GL', app2.gl_date,
                                             app2.apply_date)  >= g_global_start_date
                                  and app2.status in ('APP', 'ACTIVITY'))
                   then 1
	      else trxsch.payment_schedule_id end) is not null;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_RECEIPTS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_RECEIPTS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_RECEIPTS_F');

  g_state := 'Logging maximum receivable_application_id into fii_change_log table';
  select nvl(max(receivable_application_id), -999)
  into l_max_rec_application_id
  from fii_ar_receipts_f;

  INSERT INTO fii_change_log
  (log_item, item_value, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
  (SELECT 'AR_MAX_RECEIVABLE_APPLICATION_ID',
		l_max_rec_application_id,
		sysdate,        --CREATION_DATE,
	    g_fii_user_id,  --CREATED_BY,
        sysdate,        --LAST_UPDATE_DATE,
	    g_fii_user_id,  --LAST_UPDATED_BY,
	    g_fii_login_id  --LAST_UPDATE_LOGIN
   FROM DUAL
   WHERE NOT EXISTS
  	  (select 1 from fii_change_log
	   where log_item = 'AR_MAX_RECEIVABLE_APPLICATION_ID'));

  IF (SQL%ROWCOUNT = 0) THEN
	  UPDATE fii_change_log
	  SET item_value = l_max_rec_application_id,
	      last_update_date  = g_sysdate_time,
	      last_update_login = g_fii_login_id,
	      last_updated_by   = g_fii_user_id
	  WHERE log_item = 'AR_MAX_RECEIVABLE_APPLICATION_ID';
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_RECEIPTS;


------------------------------------------------------------------
-- Procedure POPULATE_SCHEDULED_DISCOUNTS
-- Purpose
--   This procedure inserts records in FII_AR_SCHEDULED_DISC_F
------------------------------------------------------------------
PROCEDURE POPULATE_SCHEDULED_DISCOUNTS IS
BEGIN

  g_state := 'Truncating table FII_AR_SCHEDULED_DISC_F';
  TRUNCATE_TABLE('FII_AR_SCHEDULED_DISC_F');

  g_state := 'Populating FII_AR_SCHEDULED_DISC_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


	INSERT INTO FII_AR_SCHEDULED_DISC_F
     (term_id,
	  sequence_num,
	  discount1_percent,
	  discount1_days,
	  discount1_date,
	  discount1_day_of_month,
	  discount1_months_forward,
	  discount2_percent,
	  discount2_days,
	  discount2_date,
	  discount2_day_of_month,
	  discount2_months_forward,
	  discount3_percent,
	  discount3_days,
	  discount3_date,
	  discount3_day_of_month,
	  discount3_months_forward,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT  term_id,
	        sequence_num,
		    sum(decode(discount_num,
		            1, discount_percent)) discount1_percent,
		    sum(decode(discount_num,
		            1, discount_days)) discount1_days,
		    max(decode(discount_num,
		            1, discount_date)) discount1_date,
		    sum(decode(discount_num,
		            1, discount_day_of_month)) discount1_day_of_month,
		    sum(decode(discount_num,
		            1, discount_months_forward)) discount1_months_forward,
		    sum(decode(discount_num,
		            2, discount_percent)) discount2_percent,
		    sum(decode(discount_num,
		            2, discount_days)) discount2_days,
		    max(decode(discount_num,
		            2, discount_date)) discount2_date,
		    sum(decode(discount_num,
		            2, discount_day_of_month)) discount2_day_of_month,
		    sum(decode(discount_num,
		            2, discount_months_forward)) discount2_months_forward,
		    sum(decode(discount_num,
		            3, discount_percent)) discount3_percent,
		    sum(decode(discount_num,
		            3, discount_days)) discount3_days,
		    max(decode(discount_num,
		            3, discount_date)) discount3_date,
		    sum(decode(discount_num,
		            3, discount_day_of_month)) discount3_day_of_month,
		    sum(decode(discount_num,
		            3, discount_months_forward)) discount3_months_forward,
	        sysdate,       --CREATION_DATE,
	        g_fii_user_id, --CREATED_BY,
	        sysdate,       --LAST_UPDATE_DATE,
	        g_fii_user_id, --LAST_UPDATED_BY,
	        g_fii_login_id --LAST_UPDATE_LOGIN
	FROM (SELECT disc.term_id,
	             disc.sequence_num,
	             disc.discount_percent,
	             disc.discount_days,
		         disc.discount_date,
			 	 disc.discount_day_of_month,
			 	 disc.discount_months_forward,
	             count(*) OVER (partition by disc.term_id, disc.sequence_num
	                    ORDER BY nvl(disc.discount_days,
									 nvl(to_number(to_char(discount_date, 'J')),
									  	 discount_months_forward)),
								 nvl(discount_day_of_month,1)
	                    ROWS UNBOUNDED PRECEDING) discount_num
	      FROM RA_TERMS_LINES_DISCOUNTS disc
	      GROUP BY disc.term_id,
	               disc.sequence_num,
	               disc.discount_percent,
	               disc.discount_days,
	               disc.discount_date,
	 		 	   disc.discount_day_of_month,
	 		 	   disc.discount_months_forward)
	GROUP BY term_id,
	         sequence_num;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_SCHEDULED_DISC_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_SCHEDULED_DISC_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_SCHEDULED_DISC_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_SCHEDULED_DISCOUNTS;


------------------------------------------------------------------
-- Procedure POPULATE_RECEIVABLES_AGING
-- Purpose
--   This procedure inserts records in FII_AR_AGING_RECEIVABLES
------------------------------------------------------------------
PROCEDURE POPULATE_RECEIVABLES_AGING IS

BEGIN

  g_state := 'Truncating table MLOG$_FII_AR_AGING_RECEIVABLES';
  TRUNCATE_TABLE('MLOG$_FII_AR_AGING_RECEIVABLES');
  g_state := 'Truncating table FII_AR_AGING_RECEIVABLES';
  TRUNCATE_TABLE('FII_AR_AGING_RECEIVABLES');

  g_state := 'Truncating table FII_AR_MARKER_GT';
  TRUNCATE_TABLE('FII_AR_MARKER_GT');

  Insert into fii_ar_marker_gt
    (marker)
  (SELECT 1 marker FROM DUAL WHERE g_current_bucket_3_low is not null UNION ALL
   SELECT 2 marker FROM DUAL WHERE g_current_bucket_2_low is not null UNION ALL
   SELECT 3 marker FROM DUAL UNION ALL
   SELECT 4 marker FROM DUAL UNION ALL
   SELECT 5 marker FROM DUAL WHERE g_past_due_bucket_2_low is not null UNION ALL
   SELECT 6 marker FROM DUAL WHERE g_past_due_bucket_3_low is not null UNION ALL
   SELECT 7 marker FROM DUAL WHERE g_past_due_bucket_4_low is not null UNION ALL
   SELECT 8 marker FROM DUAL WHERE g_past_due_bucket_5_low is not null UNION ALL
   SELECT 9 marker FROM DUAL WHERE g_past_due_bucket_6_low is not null UNION ALL
   SELECT 10 marker FROM DUAL WHERE g_past_due_bucket_7_low is not null);

  g_state := 'Populating FII_AR_AGING_RECEIVABLES';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	INSERT /*+ append parallel(F) */ INTO FII_AR_AGING_RECEIVABLES F
	 (time_id,
          time_id_date,
	  event_date,
	  next_aging_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id ,
	  customer_trx_id,
	  payment_schedule_id,
	  adjustment_id,
	  receivable_application_id,
	  appl_trx_date,
	  trx_date,
	  due_date,
	  current_bucket_1_amount_trx,
	  current_bucket_1_amount_func,
	  current_bucket_1_amount_prim,
	  current_bucket_1_amount_sec,
	  current_bucket_1_count,
	  current_bucket_2_amount_trx,
	  current_bucket_2_amount_func,
	  current_bucket_2_amount_prim,
	  current_bucket_2_amount_sec,
	  current_bucket_2_count,
	  current_bucket_3_amount_trx,
	  current_bucket_3_amount_func,
	  current_bucket_3_amount_prim,
	  current_bucket_3_amount_sec,
	  current_bucket_3_count,
	  past_due_bucket_1_amount_trx,
	  past_due_bucket_1_amount_func,
	  past_due_bucket_1_amount_prim,
	  past_due_bucket_1_amount_sec,
	  past_due_bucket_1_count,
	  past_due_bucket_2_amount_trx,
	  past_due_bucket_2_amount_func,
	  past_due_bucket_2_amount_prim,
	  past_due_bucket_2_amount_sec,
	  past_due_bucket_2_count,
	  past_due_bucket_3_amount_trx,
	  past_due_bucket_3_amount_func,
	  past_due_bucket_3_amount_prim,
	  past_due_bucket_3_amount_sec,
	  past_due_bucket_3_count,
	  past_due_bucket_4_amount_trx,
	  past_due_bucket_4_amount_func,
	  past_due_bucket_4_amount_prim,
	  past_due_bucket_4_amount_sec,
	  past_due_bucket_4_count,
	  past_due_bucket_5_amount_trx,
	  past_due_bucket_5_amount_func,
	  past_due_bucket_5_amount_prim,
	  past_due_bucket_5_amount_sec,
	  past_due_bucket_5_count,
	  past_due_bucket_6_amount_trx,
	  past_due_bucket_6_amount_func,
	  past_due_bucket_6_amount_prim,
	  past_due_bucket_6_amount_sec,
	  past_due_bucket_6_count,
	  past_due_bucket_7_amount_trx,
	  past_due_bucket_7_amount_func,
	  past_due_bucket_7_amount_prim,
	  past_due_bucket_7_amount_sec,
	  past_due_bucket_7_count,
	  current_open_count,
	  past_due_count,
	  total_open_count,
	  unaged_amount_trx,
	  unaged_amount_func,
	  unaged_amount_prim,
	  unaged_amount_sec,
 	  on_acct_credit_amount_trx,
	  on_acct_credit_amount_func,
	  on_acct_credit_amount_prim,
	  on_acct_credit_amount_sec,
	  class,
	  billing_activity_flag,
	  billed_amount_flag,
	  on_account_credit_flag,
	  unapplied_deposit_flag,
      billing_activity_count,
	  action,
	  aging_flag,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
        SELECT time_id,
              time_id_date,
	      event_date,
	      next_aging_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      customer_trx_id,
	      payment_schedule_id,
	      adjustment_id,
	      receivable_application_id,
	      appl_trx_date,
		  trx_date,
	      due_date,
	      sum(current_bucket_1_amount_trx),
	      sum(current_bucket_1_amount_func),
	      sum(current_bucket_1_amount_prim),
	      sum(current_bucket_1_amount_sec),
	      sum(current_bucket_1_count),
	      sum(current_bucket_2_amount_trx),
	      sum(current_bucket_2_amount_func),
	      sum(current_bucket_2_amount_prim),
	      sum(current_bucket_2_amount_sec),
	      sum(current_bucket_2_count),
	      sum(current_bucket_3_amount_trx),
	      sum(current_bucket_3_amount_func),
	      sum(current_bucket_3_amount_prim),
	      sum(current_bucket_3_amount_sec),
	      sum(current_bucket_3_count),
	      sum(past_due_bucket_1_amount_trx),
	      sum(past_due_bucket_1_amount_func),
	      sum(past_due_bucket_1_amount_prim),
	      sum(past_due_bucket_1_amount_sec),
	      sum(past_due_bucket_1_count),
	      sum(past_due_bucket_2_amount_trx),
	      sum(past_due_bucket_2_amount_func),
	      sum(past_due_bucket_2_amount_prim),
	      sum(past_due_bucket_2_amount_sec),
	      sum(past_due_bucket_2_count),
	      sum(past_due_bucket_3_amount_trx),
	      sum(past_due_bucket_3_amount_func),
	      sum(past_due_bucket_3_amount_prim),
	      sum(past_due_bucket_3_amount_sec),
	      sum(past_due_bucket_3_count),
	      sum(past_due_bucket_4_amount_trx),
	      sum(past_due_bucket_4_amount_func),
	      sum(past_due_bucket_4_amount_prim),
	      sum(past_due_bucket_4_amount_sec),
	      sum(past_due_bucket_4_count),
	      sum(past_due_bucket_5_amount_trx),
	      sum(past_due_bucket_5_amount_func),
	      sum(past_due_bucket_5_amount_prim),
	      sum(past_due_bucket_5_amount_sec),
	      sum(past_due_bucket_5_count),
	      sum(past_due_bucket_6_amount_trx),
	      sum(past_due_bucket_6_amount_func),
	      sum(past_due_bucket_6_amount_prim),
	      sum(past_due_bucket_6_amount_sec),
	      sum(past_due_bucket_6_count),
	      sum(past_due_bucket_7_amount_trx),
	      sum(past_due_bucket_7_amount_func),
	      sum(past_due_bucket_7_amount_prim),
	      sum(past_due_bucket_7_amount_sec),
	      sum(past_due_bucket_7_count),
	  	  sum(current_open_count),
	  	  sum(past_due_count),
		  sum(total_open_count),
	      unaged_amount_trx,
	      unaged_amount_func,
	      unaged_amount_prim,
	      unaged_amount_sec,
		on_acct_credit_amount_trx,
		on_acct_credit_amount_func,
		on_acct_credit_amount_prim,
		on_acct_credit_amount_sec,
	      class,
	      billing_activity_flag,
	      billed_amount_flag,
	      on_account_credit_flag,
	      unapplied_deposit_flag,
		  sum(billing_activity_count),
          action,
		  aging_flag,
		  sysdate, --CREATION_DATE,
		  g_fii_user_id,       --CREATED_BY,
		  sysdate, --LAST_UPDATE_DATE,
		  g_fii_user_id,       --LAST_UPDATED_BY,
		  g_fii_login_id       --LAST_UPDATE_LOGIN
	FROM (
		SELECT time_id,
                       time_id_date,
		       next_aging_date,
		       bill_to_customer_id,
			   bill_to_site_use_id,
			   org_id,
			   customer_trx_id,
			   payment_schedule_id,
		       adjustment_id,
		       receivable_application_id,
			   appl_trx_date,
			   trx_date,
			   due_date,
		       event_date,
		       current_bucket_1_amount_trx,
		       current_bucket_1_amount_func,
		       current_bucket_1_amount_prim,
		       current_bucket_1_amount_sec,
		       (case when current_bucket_1_amount_func = current_bucket_1_amt_func_cum
							AND current_bucket_1_amount_func <> 0
		                then 1
		             when current_bucket_1_amt_func_cum = 0
		                    AND current_bucket_1_amount_func <>0
		                then -1
		             else 0 end) current_bucket_1_count,
		       current_bucket_2_amount_trx,
		       current_bucket_2_amount_func,
		       current_bucket_2_amount_prim,
		       current_bucket_2_amount_sec,
		       (case when current_bucket_2_amount_func = current_bucket_2_amt_func_cum
		                    AND current_bucket_2_amount_func <>0
		                then 1
		             when current_bucket_2_amt_func_cum = 0
		                    AND current_bucket_2_amount_func <>0
		                then -1
		             else 0 end) current_bucket_2_count,
		       current_bucket_3_amount_trx,
		       current_bucket_3_amount_func,
		       current_bucket_3_amount_prim,
		       current_bucket_3_amount_sec,
		       (case when current_bucket_3_amount_func = current_bucket_3_amt_func_cum
		                    AND current_bucket_3_amount_func <> 0
		                then 1
		             when current_bucket_3_amt_func_cum = 0
		                    AND current_bucket_3_amount_func <> 0
		                then -1
		             else 0 end) current_bucket_3_count,
		       past_due_bucket_1_amount_trx,
		       past_due_bucket_1_amount_func,
		       past_due_bucket_1_amount_prim,
		       past_due_bucket_1_amount_sec,
		       (case when past_due_bucket_1_amount_func = past_due_bucket_1_amt_func_cum
		                    AND past_due_bucket_1_amount_func <> 0
		                then 1
		             when past_due_bucket_1_amt_func_cum = 0
		                    AND past_due_bucket_1_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_1_count,
		       past_due_bucket_2_amount_trx,
		       past_due_bucket_2_amount_func,
		       past_due_bucket_2_amount_prim,
		       past_due_bucket_2_amount_sec,
		       (case when past_due_bucket_2_amount_func = past_due_bucket_2_amt_func_cum
		                    AND past_due_bucket_2_amount_func <> 0
		                then 1
		             when past_due_bucket_2_amt_func_cum = 0
		                    AND past_due_bucket_2_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_2_count,
		       past_due_bucket_3_amount_trx,
		       past_due_bucket_3_amount_func,
		       past_due_bucket_3_amount_prim,
		       past_due_bucket_3_amount_sec,
		       (case when past_due_bucket_3_amount_func = past_due_bucket_3_amt_func_cum
		                    AND past_due_bucket_3_amount_func <> 0
		                then 1
		             when past_due_bucket_3_amt_func_cum = 0
		                    AND past_due_bucket_3_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_3_count,
		       past_due_bucket_4_amount_trx,
		       past_due_bucket_4_amount_func,
		       past_due_bucket_4_amount_prim,
		       past_due_bucket_4_amount_sec,
		       (case when past_due_bucket_4_amount_func = past_due_bucket_4_amt_func_cum
		                    AND past_due_bucket_4_amount_func <> 0
		                then 1
		             when past_due_bucket_4_amt_func_cum = 0
		                    AND past_due_bucket_4_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_4_count,
		       past_due_bucket_5_amount_trx,
		       past_due_bucket_5_amount_func,
		       past_due_bucket_5_amount_prim,
		       past_due_bucket_5_amount_sec,
		       (case when past_due_bucket_5_amount_func = past_due_bucket_5_amt_func_cum
		                    AND past_due_bucket_5_amount_func <> 0
		                then 1
		             when past_due_bucket_5_amt_func_cum = 0
		                    AND past_due_bucket_5_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_5_count,
		       past_due_bucket_6_amount_trx,
		       past_due_bucket_6_amount_func,
		       past_due_bucket_6_amount_prim,
		       past_due_bucket_6_amount_sec,
		       (case when past_due_bucket_6_amount_func = past_due_bucket_6_amt_func_cum
		                    AND past_due_bucket_6_amount_func <> 0
		                then 1
		             when past_due_bucket_6_amt_func_cum = 0
		                    AND past_due_bucket_6_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_6_count,
		       past_due_bucket_7_amount_trx,
		       past_due_bucket_7_amount_func,
		       past_due_bucket_7_amount_prim,
		       past_due_bucket_7_amount_sec,
		       (case when past_due_bucket_7_amount_func = past_due_bucket_7_amt_func_cum
		                    AND past_due_bucket_7_amount_func <> 0
		                then 1
		             when past_due_bucket_7_amt_func_cum = 0
		                    AND past_due_bucket_7_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_7_count,
			   (case when current_open_amount_func = current_open_amt_func_cum
					  and current_open_amount_func <> 0
				   		  then 1
			  	     when current_open_amt_func_cum = 0
					  and current_open_amount_func <> 0
						  then -1
			  	     else 0 end) current_open_count,
			   (case when past_due_amount_func = past_due_amt_func_cum
					  and past_due_amount_func <> 0
				   		  then 1
			  	     when past_due_amt_func_cum = 0
					  and past_due_amount_func <> 0
						  then -1
			  	     else 0 end) past_due_count,
			   (case when total_open_amount_func = total_open_amt_func_cum
					  and total_open_amount_func <> 0
				   		  then 1
			  	     when total_open_amt_func_cum = 0
					  and total_open_amount_func <> 0
						  then -1
			  	     else 0 end) total_open_count,
		       unaged_amount_trx,
		       unaged_amount_func,
		       unaged_amount_prim,
		       unaged_amount_sec,
		       on_acct_credit_amount_trx,
			 on_acct_credit_amount_func,
			 on_acct_credit_amount_prim,
			 on_acct_credit_amount_sec,
		       class,
		  	   billing_activity_flag,
		       billed_amount_flag,
		       on_account_credit_flag,
		 	   unapplied_deposit_flag,
			   (case when billing_activity_flag = 'Y'
						 and payment_schedule_id = min_payment_schedule_id
					   then 1
					 else 0 end) billing_activity_count,
		       action,
		       actual_date_closed,
		       aging_flag
	    FROM (
			SELECT time_id,
                               time_id_date,
			       next_aging_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
			       adjustment_id,
			       receivable_application_id,
				   appl_trx_date,
				   trx_date,
				   due_date,
			       event_date,
				   MIN(payment_schedule_id) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) min_payment_schedule_id,
			       current_bucket_1_amount_trx,
			       current_bucket_1_amount_func,
			       current_bucket_1_amount_prim,
			       current_bucket_1_amount_sec,
			       SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_1_amt_func_cum,
				   current_bucket_2_amount_trx,
			       current_bucket_2_amount_func,
			       current_bucket_2_amount_prim,
			       current_bucket_2_amount_sec,
			       SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_2_amt_func_cum,
			       current_bucket_3_amount_trx,
			       current_bucket_3_amount_func,
			       current_bucket_3_amount_prim,
			       current_bucket_3_amount_sec,
			       SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_3_amt_func_cum,
			       past_due_bucket_1_amount_trx,
			       past_due_bucket_1_amount_func,
			       past_due_bucket_1_amount_prim,
			       past_due_bucket_1_amount_sec,
			       SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_1_amt_func_cum,
			       past_due_bucket_2_amount_trx,
			       past_due_bucket_2_amount_func,
			       past_due_bucket_2_amount_prim,
			       past_due_bucket_2_amount_sec,
			       SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_2_amt_func_cum,
			       past_due_bucket_3_amount_trx,
			       past_due_bucket_3_amount_func,
			       past_due_bucket_3_amount_prim,
			       past_due_bucket_3_amount_sec,
			       SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_3_amt_func_cum,
			       past_due_bucket_4_amount_trx,
			       past_due_bucket_4_amount_func,
			       past_due_bucket_4_amount_prim,
			       past_due_bucket_4_amount_sec,
			       SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_4_amt_func_cum,
				   past_due_bucket_5_amount_trx,
			       past_due_bucket_5_amount_func,
			       past_due_bucket_5_amount_prim,
			       past_due_bucket_5_amount_sec,
			       SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_5_amt_func_cum,
			       past_due_bucket_6_amount_trx,
			       past_due_bucket_6_amount_func,
			       past_due_bucket_6_amount_prim,
			       past_due_bucket_6_amount_sec,
			       SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_6_amt_func_cum,
			       past_due_bucket_7_amount_trx,
			       past_due_bucket_7_amount_func,
			       past_due_bucket_7_amount_prim,
			       past_due_bucket_7_amount_sec,
			       SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_7_amt_func_cum,
				   (current_bucket_1_amount_func+current_bucket_2_amount_func
						+ current_bucket_3_amount_func) current_open_amount_func,
				   (SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) current_open_amt_func_cum,
				   (past_due_bucket_1_amount_func
						+ past_due_bucket_2_amount_func+past_due_bucket_3_amount_func
						+ past_due_bucket_4_amount_func+past_due_bucket_5_amount_func
						+ past_due_bucket_6_amount_func+past_due_bucket_7_amount_func) past_due_amount_func,
				   (SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY event_date ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
				   	 + SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) past_due_amt_func_cum,
				   (current_bucket_1_amount_func+current_bucket_2_amount_func
						+ current_bucket_3_amount_func+past_due_bucket_1_amount_func
						+ past_due_bucket_2_amount_func+past_due_bucket_3_amount_func
						+ past_due_bucket_4_amount_func+past_due_bucket_5_amount_func
						+ past_due_bucket_6_amount_func+past_due_bucket_7_amount_func) total_open_amount_func,
				   (SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
				   	 + SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) total_open_amt_func_cum,
			       unaged_amount_trx,
			       unaged_amount_func,
			       unaged_amount_prim,
			       unaged_amount_sec,
				 on_acct_credit_amount_trx,
				 on_acct_credit_amount_func,
				 on_acct_credit_amount_prim,
				 on_acct_credit_amount_sec,
			       class,
			  	   billing_activity_flag,
			       billed_amount_flag,
			       on_account_credit_flag,
			 	   unapplied_deposit_flag,
			       action,
			       actual_date_closed,
			       aging_flag
			FROM
			   (SELECT
                                  to_number(to_char(decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
													then gl_date
												  else decode(aging_flag, 'N', gl_date, event_date) end,
				                       event_date), 'J')) time_id,
                                   decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
								    then gl_date
							     else decode(aging_flag, 'N', gl_date, event_date) end,
				                       event_date) time_id_date,
			           next_aging_date,
			           bill_to_customer_id,
			    	   bill_to_site_use_id,
			    	   org_id,
			    	   customer_trx_id,
			    	   payment_schedule_id,
			           adjustment_id,
			           receivable_application_id,
			    	   appl_trx_date,
					   trx_date,
			    	   due_date,
			           event_date,
			           (case when marker=1
			                    then bucket_amount_trx
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_3_amount_trx,
			           (case when marker=1
			                    then bucket_amount_func
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_3_amount_func,
			           (case when marker=1
			                    then bucket_amount_prim
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_3_amount_prim,
			           (case when marker=1
			                    then bucket_amount_sec
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_3_amount_sec,
			            ----------------
			           (case when marker=2
			                    then bucket_amount_trx
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_2_amount_trx,
			           (case when marker=2
			                    then bucket_amount_func
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_2_amount_func,
			           (case when marker=2
			                    then bucket_amount_prim
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_2_amount_prim,
			           (case when marker=2
			                    then bucket_amount_sec
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_2_amount_sec,
			            ----------------
			           (case when marker=3
			                    then bucket_amount_trx
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_1_amount_trx,
			           (case when marker=3
			                    then bucket_amount_func
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_1_amount_func,
			           (case when marker=3
			                    then bucket_amount_prim
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_1_amount_prim,
			           (case when marker=3
			                    then bucket_amount_sec
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_1_amount_sec,
			            ----------------
			           (case when marker=4
			                    then bucket_amount_trx
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_1_amount_trx,
			           (case when marker=4
			                    then bucket_amount_func
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_1_amount_func,
			           (case when marker=4
			                    then bucket_amount_prim
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_1_amount_prim,
			           (case when marker=4
			                    then bucket_amount_sec
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_1_amount_sec,
			            ------------------
			           (case when marker=5
			                    then bucket_amount_trx
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_2_amount_trx,
			           (case when marker=5
			                    then bucket_amount_func
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_2_amount_func,
			           (case when marker=5
			                    then bucket_amount_prim
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_2_amount_prim,
			           (case when marker=5
			                    then bucket_amount_sec
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_2_amount_sec,
			            ------------------
			           (case when marker=6
			                    then bucket_amount_trx
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_3_amount_trx,
			           (case when marker=6
			                    then bucket_amount_func
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_3_amount_func,
			           (case when marker=6
			                    then bucket_amount_prim
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_3_amount_prim,
			           (case when marker=6
			                    then bucket_amount_sec
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_3_amount_sec,
			            ------------------
			           (case when marker=7
			                    then bucket_amount_trx
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_4_amount_trx,
			           (case when marker=7
			                    then bucket_amount_func
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_4_amount_func,
			           (case when marker=7
			                    then bucket_amount_prim
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_4_amount_prim,
			           (case when marker=7
			                    then bucket_amount_sec
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_4_amount_sec,
			            ---------------
			           (case when marker=8
			                    then bucket_amount_trx
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_5_amount_trx,
			           (case when marker=8
			                    then bucket_amount_func
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_5_amount_func,
			           (case when marker=8
			                    then bucket_amount_prim
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_5_amount_prim,
			           (case when marker=8
			                    then bucket_amount_sec
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_5_amount_sec,
			            ---------------
			           (case when marker=9
			                    then bucket_amount_trx
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_6_amount_trx,
			           (case when marker=9
			                    then bucket_amount_func
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_6_amount_func,
			           (case when marker=9
			                    then bucket_amount_prim
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_6_amount_prim,
			           (case when marker=9
			                    then bucket_amount_sec
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_6_amount_sec,
			            ---------------
			           (case when marker=10
			                    then bucket_amount_trx
			                 else 0 end) past_due_bucket_7_amount_trx,
			           (case when marker=10
			                    then bucket_amount_func
			                 else 0 end) past_due_bucket_7_amount_func,
			           (case when marker=10
			                    then bucket_amount_prim
			                 else 0 end) past_due_bucket_7_amount_prim,
			           (case when marker=10
			                    then bucket_amount_sec
			                 else 0 end) past_due_bucket_7_amount_sec,
			            ---------------
			           decode(aging_flag,'N',unaged_amount_trx, 0)  unaged_amount_trx,
			           decode(aging_flag,'N',unaged_amount_func, 0) unaged_amount_func,
			           decode(aging_flag,'N',unaged_amount_prim, 0) unaged_amount_prim,
			           decode(aging_flag,'N',unaged_amount_sec, 0)  unaged_amount_sec,
			           decode(aging_flag,'N',on_acct_credit_amount_trx, 0)  on_acct_credit_amount_trx,
			           decode(aging_flag,'N',on_acct_credit_amount_func, 0) on_acct_credit_amount_func,
			           decode(aging_flag,'N',on_acct_credit_amount_prim, 0) on_acct_credit_amount_prim,
			           decode(aging_flag,'N',on_acct_credit_amount_sec, 0)  on_acct_credit_amount_sec,
			           class,
			           decode(aging_flag,'N',billing_activity_flag, 'N') billing_activity_flag,
			           decode(aging_flag,'N',billed_amount_flag, 'N') billed_amount_flag,
			           on_account_credit_flag,
			           decode(aging_flag,'N',unapplied_deposit_flag, 'N') unapplied_deposit_flag,
			           action,
			           actual_date_closed,
			           aging_flag
			    FROM
			       (SELECT /*+ parallel(M) */
                                       m.marker,
			               v.bill_to_customer_id,
			        	   v.bill_to_site_use_id,
			        	   v.org_id,
			        	   v.customer_trx_id,
			        	   v.payment_schedule_id,
			               v.adjustment_id,
			               v.receivable_application_id,
			        	   v.appl_trx_date,
			        	   v.due_date,
						   v.trx_date,
						   v.gl_date,
			               v.bucket_amount_trx,
			               v.bucket_amount_func,
			               v.bucket_amount_prim,
			               v.bucket_amount_sec,
			               v.unaged_amount_trx,
			               v.unaged_amount_func,
			               v.unaged_amount_prim,
			               v.unaged_amount_sec,
					   v.on_acct_credit_amount_trx,
					   v.on_acct_credit_amount_func,
					   v.on_acct_credit_amount_prim,
					   v.on_acct_credit_amount_sec,
			               v.class,
			          	   v.billing_activity_flag,
			    	       v.billed_amount_flag,
			               v.on_account_credit_flag,
			         	   v.unapplied_deposit_flag,
			               v.action,
			               v.actual_date_closed,
			               decode(m.marker,
			                      1, case when trunc(v.appl_trx_date)<=trunc(v.due_date)-g_current_bucket_3_low
			                                then appl_trx_date
			                              else null end,
			                      2, case when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_2_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.due_date)-g_current_bucket_2_high <= g_sysdate
			                                then trunc(v.due_date)-g_current_bucket_2_high
			                              when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.appl_trx_date) <= trunc(v.due_date)-g_current_bucket_2_low
			                                then v.appl_trx_date
			                              when g_current_bucket_2_high is null
												and trunc(v.appl_trx_date) <= trunc(v.due_date)-g_current_bucket_2_low
			                                then v.appl_trx_date
			                              else null end,
			                      3, case when g_current_bucket_1_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_1_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.due_date)-g_current_bucket_1_high <= g_sysdate
			                                then trunc(v.due_date)-g_current_bucket_1_high
			                              when g_current_bucket_1_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.appl_trx_date) <= trunc(v.due_date) - g_current_bucket_1_low
			                                then v.appl_trx_date
			                              when g_current_bucket_1_high is null
												and trunc(v.appl_trx_date) <= trunc(v.due_date) - g_current_bucket_1_low
			                                then v.appl_trx_date
			                              else null end,
			                      4, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_1_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_1_low
												and trunc(v.due_date)+g_past_due_bucket_1_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_1_low
			                              when g_past_due_bucket_1_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_1_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_1_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_1_high is null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_1_low
			                                then v.appl_trx_date
			                              else null end,
			                      5, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_2_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_2_low
												and trunc(v.due_date)+g_past_due_bucket_2_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_2_low
			                              when g_past_due_bucket_2_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_2_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_2_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_2_high is null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_2_low
			                                then v.appl_trx_date
			                              else null end,
			                      6, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_3_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_3_low
												and trunc(v.due_date)+g_past_due_bucket_3_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_3_low
			                              when g_past_due_bucket_3_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_3_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_3_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_3_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_3_low
			                                then v.appl_trx_date
			                              else null end,
			                      7, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_4_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_4_low
												and trunc(v.due_date)+g_past_due_bucket_4_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_4_low
			                              when g_past_due_bucket_4_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_4_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_4_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_4_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_4_low
			                                then v.appl_trx_date
			                              else null end,
			                      8, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_5_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_5_low
												and trunc(v.due_date)+g_past_due_bucket_5_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_5_low
			                              when g_past_due_bucket_5_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_5_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_5_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_5_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_5_low
			                                then v.appl_trx_date
			                              else null end,
			                      9, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_6_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_6_low
												and trunc(v.due_date)+g_past_due_bucket_6_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_6_low
			                              when g_past_due_bucket_6_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_6_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_6_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_6_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_6_low
			                                then v.appl_trx_date
			                              else null end,
			                      10, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_7_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_7_low
												and trunc(v.due_date)+g_past_due_bucket_7_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_7_low
			                              when trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_7_low
			                                then v.appl_trx_date
			                              else null end) event_date,
						   decode(m.marker,
			                      1, case when actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
											then trunc(v.due_date)-g_current_bucket_2_high
										  else null end,
			                      2, case when actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
											then trunc(v.due_date)-g_current_bucket_1_high
										  else null end,
			                      3, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_1_low
											then trunc(v.due_date)+g_past_due_bucket_1_low
										  else null end,
			                      4, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_2_low
											then trunc(v.due_date)+g_past_due_bucket_2_low
										  else null end,
			                      5, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_3_low
											then trunc(v.due_date)+g_past_due_bucket_3_low
										  else null end,
			                      6, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_4_low
											then trunc(v.due_date)+g_past_due_bucket_4_low
										  else null end,
			                      7, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_5_low
											then trunc(v.due_date)+g_past_due_bucket_5_low
										  else null end,
			                      8, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_6_low
											then trunc(v.due_date)+g_past_due_bucket_6_low
										  else null end,
			                      9, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_7_low
											then trunc(v.due_date)+g_past_due_bucket_7_low
										  else null end,
			                      10, null) next_aging_date,
			               decode(m.marker,
			                      1, 'N',
			                      2, case when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_2_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.due_date)-g_current_bucket_2_high <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      3, case when g_current_bucket_1_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_1_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.due_date)-g_current_bucket_1_high <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      4, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_1_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_1_low
												and trunc(v.due_date)+g_past_due_bucket_1_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      5, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_2_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_2_low
												and trunc(v.due_date)+g_past_due_bucket_2_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      6, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_3_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_3_low
												and trunc(v.due_date)+g_past_due_bucket_3_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      7, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_4_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_4_low
												and trunc(v.due_date)+g_past_due_bucket_4_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      8, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_5_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_5_low
												and trunc(v.due_date)+g_past_due_bucket_5_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      9, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_6_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_6_low
												and trunc(v.due_date)+g_past_due_bucket_6_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      10, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_7_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_7_low
												and trunc(v.due_date)+g_past_due_bucket_7_low <= g_sysdate
			                                then 'Y'
			                               else 'N' end) aging_flag
			        FROM (--Payment Schedules
			              select /*+ parallel(SCH) */
                                                 sch.bill_to_customer_id,
			            		 sch.bill_to_site_use_id,
			            		 sch.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     null adjustment_id,
			                     null receivable_application_id,
			            		 sch.trx_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 sch.gl_date,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_trx) bucket_amount_trx,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_func) bucket_amount_func,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_prim) bucket_amount_prim,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_sec) bucket_amount_sec,
					             sch.amount_due_original_trx unaged_amount_trx,
					             sch.amount_due_original_func unaged_amount_func,
					             sch.amount_due_original_prim unaged_amount_prim,
					             sch.amount_due_original_sec unaged_amount_sec,
							 decode (sch.class, 'CM', sch.amount_due_original_trx, 0) on_acct_credit_amount_trx,
							 decode (sch.class, 'CM', sch.amount_due_original_func, 0) on_acct_credit_amount_func,
							 decode (sch.class, 'CM', sch.amount_due_original_prim, 0) on_acct_credit_amount_prim,
							 decode (sch.class, 'CM', sch.amount_due_original_sec, 0) on_acct_credit_amount_sec,
					             sch.class,
			              		 'Y' billing_activity_flag,
                                                  case when sch.class not in ('CB', 'BR')
                                                          and dso.dso_value = 'Y' then
                                                            'Y'
                                                       else 'N' end billed_amount_flag,
				                 null on_account_credit_flag, --no longer used after adding on_acct_credit_amount in bug 6053566
						     decode(sch.class,'DEP','Y','N') unapplied_deposit_flag,
			                     'Transaction' action,
			                     sch.actual_date_closed
			              from fii_ar_pmt_schedules_f sch,
							   fii_ar_dso_setup dso
						  where sch.class <> 'PMT'
						  and dso.dso_group='TC'
						  and dso.dso_type = sch.class

			              union all

			              --Applications
			              select /*+ parallel(RCT) parallel(SCH) */
                                                 rct.collector_bill_to_customer_id,
			            		 rct.collector_bill_to_site_use_id,
			            		 rct.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     null adjustment_id,
			                     rct.receivable_application_id,
			            		 rct.apply_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 decode(g_collection_criteria,
				                        'GL', rct.filter_date,
										null) gl_date,
			                     -1*(rct.amount_applied_trx
								   +nvl(rct.earned_discount_amount_trx,0)
			                       +nvl(rct.unearned_discount_amount_trx,0)) bucket_amount_trx,
			                     -1*(rct.amount_applied_trx_func
								   +nvl(rct.earned_discount_amount_func,0)
			                       +nvl(rct.unearned_discount_amount_func,0)) bucket_amount_func,
			                     -1*(rct.amount_applied_trx_prim
								   +nvl(rct.earned_discount_amount_prim,0)
			                       +nvl(rct.unearned_discount_amount_prim,0)) bucket_amount_prim,
			                     -1*(rct.amount_applied_trx_sec
								   +nvl(rct.earned_discount_amount_sec,0)
			                       +nvl(rct.unearned_discount_amount_sec,0)) bucket_amount_sec,
					            -1*rct.amount_applied_trx unaged_amount_trx,
							-1*rct.amount_applied_trx_func unaged_amount_func,
							-1*rct.amount_applied_trx_prim unaged_amount_prim,
							-1*rct.amount_applied_trx_sec unaged_amount_sec,
                                            --Added for bug 6053566
				            	case when rct.application_type = 'CASH' and sch.class = 'CM'
                                                        then rct.amount_applied_trx
                                                     when rct.application_type = 'CM'
                                                        then -1*rct.amount_applied_rct
                                                     else 0 end on_acct_credit_amount_trx,
                                                case when rct.application_type = 'CASH' and sch.class = 'CM'
                                                        then rct.amount_applied_trx_func
                                                     when rct.application_type = 'CM'
                                                        then -1*rct.amount_applied_rct_func
                                                     else 0 end on_acct_credit_amount_func,
                                                case when rct.application_type = 'CASH' and sch.class = 'CM'
                                                        then rct.amount_applied_trx_prim
                                                     when rct.application_type = 'CM'
                                                        then -1*rct.amount_applied_rct_prim
                                                     else 0 end on_acct_credit_amount_prim,
                                                case when rct.application_type = 'CASH' and sch.class = 'CM'
                                                        then rct.amount_applied_trx_sec
                                                     when rct.application_type = 'CM'
                                                        then -1*rct.amount_applied_rct_sec
                                                     else 0 end on_acct_credit_amount_sec,

					             sch.class,
			              		 'N' billing_activity_flag,
			    		         'N' billed_amount_flag,
				                 null on_account_credit_flag, --this is no longer used after adding on_acct_credit_amount in bug 6053566
				                 case when rct.application_type = 'CM' and sch.class='DEP'
										and rct.cm_previous_customer_trx_id is not null
									  then 'Y'
									  else 'N' end  unapplied_deposit_flag,
			                     'Application' action,
			                     sch.actual_date_closed
			              from fii_ar_receipts_f rct,
			                   fii_ar_pmt_schedules_f sch
			              where rct.application_status = 'APP'
						  and sch.class <> 'PMT'
						  and rct.applied_payment_schedule_id = sch.payment_schedule_id

			              union all

			              --Adjustments
			              select  /*+ parallel(ADJ) parallel(SCH) */
                                                 adj.bill_to_customer_id,
			            		 adj.bill_to_site_use_id,
			            		 adj.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     adj.adjustment_id,
			                     null receivable_application_id,
			            		 adj.apply_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 adj.gl_date,
			                     adj.amount_trx  bucket_amount_trx,
			                     adj.amount_func bucket_amount_func,
			                     adj.amount_prim bucket_amount_prim,
			                     adj.amount_sec  bucket_amount_sec,
					             adj.amount_trx  unaged_amount_trx,
					             adj.amount_func unaged_amount_func,
					             adj.amount_prim unaged_amount_prim,
					             adj.amount_sec  unaged_amount_sec,
				            	 0 on_acct_credit_amount_trx,
							 0 on_acct_credit_amount_func,
							 0 on_acct_credit_amount_prim,
							 0 on_acct_credit_amount_sec,
					             sch.class,
			              		 'N' billing_activity_flag,
                                                 case when sch.class not in ('CB', 'BR')
                                                        and (adj.adj_class not in ('CB', 'BR') or adj.adj_class is null)
                                                        and schdso.dso_value = 'Y'
                                                        and (adjdso.dso_value is null or adjdso.dso_value = 'Y')
                                                        then 'Y'
                                                     else 'N' end  billed_amount_flag,
				                 null on_account_credit_flag,
    						   decode(adj.adj_class,'DEP','Y','N') unapplied_deposit_flag,
			                     'Adjustment' action,
			                     sch.actual_date_closed
			              from fii_ar_adjustments_f adj,
			                   fii_ar_pmt_schedules_f sch,
							   fii_ar_dso_setup schdso,
							   fii_ar_dso_setup adjdso
						  where adj.payment_schedule_id = sch.payment_schedule_id
						  and sch.class <> 'PMT'
						  and schdso.dso_group='TC'
						  and schdso.dso_type = sch.class
						  and nvl(adjdso.dso_group,'TC')='TC'
						  and adj.adj_class = adjdso.dso_type (+)    ) v,
                                     fii_ar_marker_gt m)
			    WHERE event_date is not null)
			GROUP BY time_id,
                               time_id_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
			       adjustment_id,
			       receivable_application_id,
				   appl_trx_date,
				   trx_date,
				   due_date,
			       event_date,
			       current_bucket_1_amount_trx,
			       current_bucket_1_amount_func,
			       current_bucket_1_amount_prim,
			       current_bucket_1_amount_sec,
			       current_bucket_2_amount_trx,
			       current_bucket_2_amount_func,
			       current_bucket_2_amount_prim,
			       current_bucket_2_amount_sec,
			       current_bucket_3_amount_trx,
			       current_bucket_3_amount_func,
			       current_bucket_3_amount_prim,
			       current_bucket_3_amount_sec,
			       past_due_bucket_1_amount_trx,
			       past_due_bucket_1_amount_func,
			       past_due_bucket_1_amount_prim,
			       past_due_bucket_1_amount_sec,
			       past_due_bucket_2_amount_trx,
			       past_due_bucket_2_amount_func,
			       past_due_bucket_2_amount_prim,
			       past_due_bucket_2_amount_sec,
			       past_due_bucket_3_amount_trx,
			       past_due_bucket_3_amount_func,
			       past_due_bucket_3_amount_prim,
			       past_due_bucket_3_amount_sec,
			       past_due_bucket_4_amount_trx,
			       past_due_bucket_4_amount_func,
			       past_due_bucket_4_amount_prim,
			       past_due_bucket_4_amount_sec,
			       past_due_bucket_5_amount_trx,
			       past_due_bucket_5_amount_func,
			       past_due_bucket_5_amount_prim,
			       past_due_bucket_5_amount_sec,
			       past_due_bucket_6_amount_trx,
			       past_due_bucket_6_amount_func,
			       past_due_bucket_6_amount_prim,
			       past_due_bucket_6_amount_sec,
			       past_due_bucket_7_amount_trx,
			       past_due_bucket_7_amount_func,
			       past_due_bucket_7_amount_prim,
			       past_due_bucket_7_amount_sec,
				   next_aging_date,
			       unaged_amount_trx,
			       unaged_amount_func,
			       unaged_amount_prim,
			       unaged_amount_sec,
				 on_acct_credit_amount_trx,
				 on_acct_credit_amount_func,
				 on_acct_credit_amount_prim,
				 on_acct_credit_amount_sec,
			       class,
			  	   billing_activity_flag,
			       billed_amount_flag,
			       on_account_credit_flag,
			 	   unapplied_deposit_flag,
			       action,
			       actual_date_closed,
			       aging_flag

			--order by payment_schedule_id, event_date, receivable_application_id, adjustment_id
			)
		)
	GROUP BY time_id,
              time_id_date,
	      event_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      customer_trx_id,
	      payment_schedule_id,
	      adjustment_id,
	      receivable_application_id,
	      appl_trx_date,
		  trx_date,
	      due_date,
		  next_aging_date,
	      unaged_amount_trx,
	      unaged_amount_func,
	      unaged_amount_prim,
	      unaged_amount_sec,
		on_acct_credit_amount_trx,
		on_acct_credit_amount_func,
		on_acct_credit_amount_prim,
		on_acct_credit_amount_sec,
	      class,
	      billing_activity_flag,
	      billed_amount_flag,
	      on_account_credit_flag,
	      unapplied_deposit_flag,
          action,
		  aging_flag;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_AGING_RECEIVABLES');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_AGING_RECEIVABLES table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_AGING_RECEIVABLES');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_RECEIVABLES_AGING;


------------------------------------------------------------------
-- Procedure POPULATE_RECEIPTS_AGING
-- Purpose
--   This procedure inserts records in FII_AR_AGING_RECEIPTS
------------------------------------------------------------------
PROCEDURE POPULATE_RECEIPTS_AGING IS

BEGIN

  g_state := 'Truncating table MLOG$_FII_AR_AGING_RECEIPTS';
  TRUNCATE_TABLE('MLOG$_FII_AR_AGING_RECEIPTS');
  g_state := 'Truncating table FII_AR_AGING_RECEIPTS';
  TRUNCATE_TABLE('FII_AR_AGING_RECEIPTS');

  g_state := 'Truncating table FII_AR_MARKER_GT';
  TRUNCATE_TABLE('FII_AR_MARKER_GT');

  Insert into fii_ar_marker_gt
    (marker)
  (SELECT 1 marker FROM DUAL UNION ALL
   SELECT 2 marker FROM DUAL WHERE g_rct_bucket_2_low is not null UNION ALL
   SELECT 3 marker FROM DUAL WHERE g_rct_bucket_3_low is not null);

  g_state := 'Populating FII_AR_AGING_RECEIPTS';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


	INSERT /*+ append parallel(F) */ INTO FII_AR_AGING_RECEIPTS F
	 (time_id,
	  event_date,
	  next_aging_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id,
	  cash_receipt_id,
	  aging_bucket_1_amount_func,
	  aging_bucket_1_amount_prim,
	  aging_bucket_1_amount_sec,
	  aging_bucket_1_count,
	  aging_bucket_2_amount_func,
	  aging_bucket_2_amount_prim,
	  aging_bucket_2_amount_sec,
	  aging_bucket_2_count,
	  aging_bucket_3_amount_func,
	  aging_bucket_3_amount_prim,
	  aging_bucket_3_amount_sec,
	  aging_bucket_3_count,
	  total_unapplied_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT time_id,
		  event_date,
	      next_aging_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      cash_receipt_id,
	      sum(aging_bucket_1_amount_func),
	      sum(aging_bucket_1_amount_prim),
	      sum(aging_bucket_1_amount_sec),
	      sum(aging_bucket_1_count),
	      sum(aging_bucket_2_amount_func),
	      sum(aging_bucket_2_amount_prim),
	      sum(aging_bucket_2_amount_sec),
	      sum(aging_bucket_2_count),
	      sum(aging_bucket_3_amount_func),
	      sum(aging_bucket_3_amount_prim),
	      sum(aging_bucket_3_amount_sec),
	      sum(aging_bucket_3_count),
		  sum(total_unapplied_count),
		  sysdate, --CREATION_DATE,
		  g_fii_user_id,       --CREATED_BY,
		  sysdate, --LAST_UPDATE_DATE,
		  g_fii_user_id,       --LAST_UPDATED_BY,
		  g_fii_login_id        --LAST_UPDATE_LOGIN
	FROM
		(SELECT time_id,
  			   next_aging_date,
		       bill_to_customer_id,
			   bill_to_site_use_id,
			   org_id,
			   cash_receipt_id,
		       event_date,
		       aging_bucket_1_amount_func,
		       aging_bucket_1_amount_prim,
		       aging_bucket_1_amount_sec,
		       (case when aging_bucket_1_amount_func = aging_bucket_1_amt_func_cum
		                    AND aging_bucket_1_amount_func <>0
		                then 1
		             when aging_bucket_1_amt_func_cum = 0
		                    AND aging_bucket_1_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_1_count,
		       aging_bucket_2_amount_func,
		       aging_bucket_2_amount_prim,
		       aging_bucket_2_amount_sec,
		       (case when aging_bucket_2_amount_func = aging_bucket_2_amt_func_cum
		                    AND aging_bucket_2_amount_func <>0
		                then 1
		             when aging_bucket_2_amt_func_cum = 0
		                    AND aging_bucket_2_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_2_count,
		       aging_bucket_3_amount_func,
		       aging_bucket_3_amount_prim,
		       aging_bucket_3_amount_sec,
		       (case when aging_bucket_3_amount_func = aging_bucket_3_amt_func_cum
		                    AND aging_bucket_3_amount_func <>0
		                then 1
		             when aging_bucket_3_amt_func_cum = 0
		                    AND aging_bucket_3_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_3_count,
			   (case when total_unapplied_amount_func = total_unapplied_amt_func_cum
		                    AND total_unapplied_amount_func <>0
		                then 1
		             when total_unapplied_amt_func_cum = 0
		                    AND total_unapplied_amount_func <>0
		                then -1
		             else 0 end) total_unapplied_count,
		       aging_flag
		FROM
		   (SELECT time_id,
	  			   next_aging_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   cash_receipt_id,
				   receivable_application_id,
			       event_date,
			       aging_bucket_1_amount_func,
			       aging_bucket_1_amount_prim,
			       aging_bucket_1_amount_sec,
			       SUM(aging_bucket_1_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_1_amt_func_cum,
			       aging_bucket_2_amount_func,
			       aging_bucket_2_amount_prim,
			       aging_bucket_2_amount_sec,
			       SUM(aging_bucket_2_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_2_amt_func_cum,
			       aging_bucket_3_amount_func,
			       aging_bucket_3_amount_prim,
			       aging_bucket_3_amount_sec,
			       SUM(aging_bucket_3_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_3_amt_func_cum,
				   (aging_bucket_1_amount_func
					+ aging_bucket_2_amount_func
					+ aging_bucket_3_amount_func) total_unapplied_amount_func,
					(SUM(aging_bucket_1_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(aging_bucket_2_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
 					 + SUM(aging_bucket_3_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) total_unapplied_amt_func_cum,
 			       aging_flag
			FROM
			   (SELECT --to_number(to_char(event_date, 'J')) time_id,
					   to_number(to_char(decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
													then gl_date
												  else decode(aging_flag,'N',gl_date,event_date) end,
				                       event_date), 'J')) time_id,
	 				   next_aging_date,
			           bill_to_customer_id,
			    	   bill_to_site_use_id,
			    	   org_id,
			    	   cash_receipt_id,
			           receivable_application_id,
			           event_date,
			           (case when marker=1
			                    then bucket_amount_func
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) aging_bucket_1_amount_func,
			           (case when marker=1
			                    then bucket_amount_prim
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) aging_bucket_1_amount_prim,
			           (case when marker=1
			                    then bucket_amount_sec
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) aging_bucket_1_amount_sec,
			            ----------------
			           (case when marker=2
			                    then bucket_amount_func
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) aging_bucket_2_amount_func,
			           (case when marker=2
			                    then bucket_amount_prim
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) aging_bucket_2_amount_prim,
			           (case when marker=2
			                    then bucket_amount_sec
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) aging_bucket_2_amount_sec,
			            ----------------
			           (case when marker=3
			                    then bucket_amount_func
			                 else 0 end) aging_bucket_3_amount_func,
			           (case when marker=3
			                    then bucket_amount_prim
			                 else 0 end) aging_bucket_3_amount_prim,
			           (case when marker=3
			                    then bucket_amount_sec
			                 else 0 end) aging_bucket_3_amount_sec,
			            ---------------
			           aging_flag
			    FROM
			       (SELECT m.marker,
			               v.bill_to_customer_id,
			        	   v.bill_to_site_use_id,
			        	   v.org_id,
			        	   v.cash_receipt_id,
			               v.receivable_application_id,
			         	   v.apply_date,
						   v.gl_date,
			               v.bucket_amount_func,
			               v.bucket_amount_prim,
			               v.bucket_amount_sec,
			               decode(m.marker,
			                      1, case when (g_rct_bucket_1_high is not null AND trunc(v.apply_date) between trunc(v.receipt_date) and trunc(v.receipt_date)+g_rct_bucket_1_high)
			                                then v.apply_date
										  when (g_rct_bucket_1_high is null AND trunc(v.apply_date) >= trunc(v.receipt_date))
			                                then v.apply_date
			                              else null end,
			                      2, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_2_low
			                                and trunc(receipt_date) + g_rct_bucket_2_low <= g_sysdate
											and trunc(receipt_date) + g_rct_bucket_2_low <= trunc(rct_actual_date_closed)
			                                then trunc(receipt_date) + g_rct_bucket_2_low
			                              when (g_rct_bucket_2_high is not null AND trunc(v.apply_date) between trunc(v.receipt_date)+g_rct_bucket_2_low and trunc(v.receipt_date)+g_rct_bucket_2_high)
			                                then trunc(v.apply_date)
			                              when (g_rct_bucket_2_high is null AND trunc(v.apply_date) >= trunc(v.receipt_date)+g_rct_bucket_2_low)
			                                then trunc(v.apply_date)
			                              else null end,
			                      3, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_3_low
			                                and trunc(receipt_date) + g_rct_bucket_3_low <= g_sysdate
											and trunc(receipt_date) + g_rct_bucket_3_low <= trunc(rct_actual_date_closed)
			                                then trunc(receipt_date) + g_rct_bucket_3_low
			                              when trunc(v.apply_date) >= trunc(v.receipt_date)+g_rct_bucket_3_low
			                                then trunc(v.apply_date)
			                              else null end) event_date,
						   decode(m.marker,
			                      1, case when trunc(rct_actual_date_closed) >= trunc(v.receipt_date) + g_rct_bucket_2_low
											then trunc(v.receipt_date) + g_rct_bucket_2_low
									 else null end,
			                      2, case when trunc(rct_actual_date_closed) >= trunc(receipt_date) + g_rct_bucket_3_low
											then trunc(receipt_date) + g_rct_bucket_3_low
									 else null end,
			                      3, null) next_aging_date,
			               decode(m.marker,
			                      1, 'N',
			                      2, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_2_low
			                                and trunc(receipt_date) + g_rct_bucket_2_low <= g_sysdate
			                                then 'Y'
			                              else'N' end,
			                      3, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_3_low
			                                and trunc(receipt_date) + g_rct_bucket_3_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end) aging_flag
			        FROM (--Unapplied Receipts
			              select  /*+ parallel(rct) */ rct.apply_date,
			                      rct.receipt_date,
								  decode(g_collection_criteria,
				                         'GL', rct.filter_date,
								  		 null) gl_date,
								  rct.rct_actual_date_closed,
			            		  rct.bill_to_customer_id,
			            		  rct.bill_to_site_use_id,
			            		  rct.org_id,
			            		  rct.cash_receipt_id,
			                      rct.receivable_application_id,
			            		  rct.amount_applied_rct_func bucket_amount_func,
			            		  rct.amount_applied_rct_prim bucket_amount_prim,
			            		  rct.amount_applied_rct_sec bucket_amount_sec
			              from fii_ar_receipts_f rct
			              where rct.application_status in ('UNAPP','UNID')
						  and rct.header_status not in ('REV', 'NSF', 'STOP')
						  --and nvl(rct.applied_payment_schedule_id,-999) <> -1 --exclude on-account receipts
						  --and nvl(rct.applied_payment_schedule_id,-999) <> -4 --exclude claims
						  --and nvl(rct.applied_payment_schedule_id,-999) <> -7 --exclude prepayments
						  and nvl(rct.applied_payment_schedule_id,1) > 0 --exclude all special applications
			              and rct.application_type = 'CASH'
						  and rct.amount_applied_rct_func <> 0) v,
                                     (select /*+ parallel(t) */ *
                                      from fii_ar_marker_gt t) m)
			    WHERE event_date is not null)
			GROUP BY time_id,
			         bill_to_customer_id,
			    	 bill_to_site_use_id,
			    	 org_id,
			    	 cash_receipt_id,
			         receivable_application_id,
			         event_date,
			         aging_bucket_1_amount_func,
			         aging_bucket_1_amount_prim,
			         aging_bucket_1_amount_sec,
			         aging_bucket_2_amount_func,
			         aging_bucket_2_amount_prim,
			         aging_bucket_2_amount_sec,
			         aging_bucket_3_amount_func,
			         aging_bucket_3_amount_prim,
			         aging_bucket_3_amount_sec,
					 next_aging_date,
			         aging_flag

			order by receivable_application_id, event_date
			)
		)
	GROUP BY time_id,
	      event_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      cash_receipt_id,
	      next_aging_date
	HAVING sum(aging_bucket_1_amount_func) <> 0
		   or
	  	   sum(aging_bucket_2_amount_func) <> 0
		   or
		   sum(aging_bucket_3_amount_func) <>0;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_AGING_RECEIPTS');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_AGING_RECEIPTS table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_AGING_RECEIPTS');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_RECEIPTS_AGING;


PROCEDURE POPULATE_DISPUTES_AGING IS

BEGIN

  g_state := 'Truncating table MLOG$_FII_AR_AGING_DISPUTES';
  TRUNCATE_TABLE('MLOG$_FII_AR_AGING_DISPUTES');
  g_state := 'Truncating table FII_AR_AGING_DISPUTES';
  TRUNCATE_TABLE('FII_AR_AGING_DISPUTES');

  g_state := 'Populating FII_AR_AGING_DISPUTES';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

    INSERT /*+ append parallel(D) */ INTO FII_AR_AGING_DISPUTES D
	 (time_id,
	  event_date,
	  next_aging_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id,
	  customer_trx_id,
	  payment_schedule_id,
	  due_date,
	  current_dispute_amount_func,
	  current_dispute_amount_prim,
	  current_dispute_amount_sec,
	  current_dispute_count,
	  past_due_dispute_amount_func,
	  past_due_dispute_amount_prim,
	  past_due_dispute_amount_sec,
	  past_due_dispute_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT time_id,
		  event_date,
	      next_aging_date,
		  bill_to_customer_id,
		  bill_to_site_use_id,
		  org_id,
		  customer_trx_id,
		  payment_schedule_id,
		  due_date,
		  sum(current_dispute_amount_func),
		  sum(current_dispute_amount_prim),
		  sum(current_dispute_amount_sec),
		  sum(current_dispute_count),
		  sum(past_due_dispute_amount_func),
		  sum(past_due_dispute_amount_prim),
		  sum(past_due_dispute_amount_sec),
		  sum(past_due_dispute_count),
		  sysdate, --CREATION_DATE,
		  g_fii_user_id,       --CREATED_BY,
		  sysdate, --LAST_UPDATE_DATE,
		  g_fii_user_id,       --LAST_UPDATED_BY,
		  g_fii_login_id        --LAST_UPDATE_LOGIN
	FROM (

		SELECT time_id,
			  event_date,
		      next_aging_date,
			  bill_to_customer_id,
			  bill_to_site_use_id,
			  org_id,
			  customer_trx_id,
			  payment_schedule_id,
			  due_date,
			  current_dispute_amount_func,
			  current_dispute_amount_prim,
			  current_dispute_amount_sec,
		      SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_dispute_amount_funcc,
		      (case when current_dispute_amount_func = SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
		                and current_dispute_amount_func <> 0
						then 1
		             when SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) = 0
		                    AND current_dispute_amount_func <> 0
		                then -1
		             else 0 end) current_dispute_count,
			  past_due_dispute_amount_func,
			  past_due_dispute_amount_prim,
			  past_due_dispute_amount_sec,
		      SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_dispute_amount_funcc,
		      (case when past_due_dispute_amount_func = SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
		                and past_due_dispute_amount_func <> 0
						then 1
		             when SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) = 0
		                and past_due_dispute_amount_func <> 0
		                then -1
		             else 0 end) past_due_dispute_count,

		       aging_flag
		FROM
		   (SELECT to_number(to_char(event_date, 'J')) time_id,
				   event_date,
				   next_aging_date,
				   bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
				   due_date,
		           (case when marker=1
		                    then bucket_amount_func
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_func
		                 else 0 end) current_dispute_amount_func,
		           (case when marker=1
		                    then bucket_amount_prim
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_prim
		                 else 0 end) current_dispute_amount_prim,
		           (case when marker=1
		                    then bucket_amount_sec
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_sec
		                 else 0 end) current_dispute_amount_sec,
		            ----------------
		           (case when marker=2
		                    then bucket_amount_func
		                 else 0 end) past_due_dispute_amount_func,
		           (case when marker=2
		                    then bucket_amount_prim
		                 else 0 end) past_due_dispute_amount_prim,
		           (case when marker=2
		                    then bucket_amount_sec
		                 else 0 end) past_due_dispute_amount_sec,
		            ---------------
		            aging_flag
		    FROM
		       (SELECT m.marker,
					   v.time_id,
		               v.bill_to_customer_id,
		        	   v.bill_to_site_use_id,
		        	   v.org_id,
		        	   v.customer_trx_id,
		        	   v.payment_schedule_id,
					   v.due_date,
		               v.bucket_amount_func,
		               v.bucket_amount_prim,
		               v.bucket_amount_sec,
		               decode(m.marker,
		                      1, case when trunc(v.start_date)<=trunc(v.due_date)
		                                then v.start_date
		                              else null end,
		                      2, case when trunc(v.start_date) <= trunc(v.due_date)
											and actual_date_closed >= trunc(v.due_date)+1
											and trunc(v.due_date)+1  <= g_sysdate
		                                then trunc(v.due_date)+1
		                              when trunc(v.start_date) >= trunc(v.due_date)+1
		                                then trunc(v.start_date)
		                              else null end) event_date,
					   decode(m.marker,
		                      1, case when trunc(v.due_date)+1 <= actual_date_closed
										then trunc(v.due_date)+1 end,
		                      2, null) next_aging_date,
		               decode(m.marker,
		                      1, 'N',
		                      2, case when trunc(v.start_date) <= trunc(v.due_date)
											and v.actual_date_closed >= trunc(v.due_date)+1
											and trunc(v.due_date)+1  <= g_sysdate
		                                then 'Y'
		                              else 'N' end) aging_flag
		        FROM (--Disputes
		              select /*+ parallel(dis) */ dis.time_id,
							 dis.start_date,
							 dis.bill_to_customer_id,
							 dis.bill_to_site_use_id,
							 dis.org_id,
							 --dis.dispute_history_id,
							 dis.customer_trx_id,
							 dis.payment_schedule_id,
							 dis.due_date,
							 dis.actual_date_closed,
		                     sum(dis.dispute_amount_func)   bucket_amount_func,
		                     sum(dis.dispute_amount_prim)   bucket_amount_prim,
		                     sum(dis.dispute_amount_sec)    bucket_amount_sec
		              from fii_ar_dispute_history_f dis
					  group by dis.time_id,
							 dis.start_date,
							 dis.bill_to_customer_id,
							 dis.bill_to_site_use_id,
							 dis.org_id,
							 dis.customer_trx_id,
							 dis.payment_schedule_id,
							 dis.due_date,
							 dis.actual_date_closed

					  union --changed from union all to union as sugested by perf. team

					  --Disputes that are ended
					  select to_number(to_char(end_date, 'J')) time_id,
					       least(end_date, actual_date_closed) start_date,
					       bill_to_customer_id,
						   bill_to_site_use_id,
						   org_id,
						   customer_trx_id,
						   payment_schedule_id,
						   due_date,
						   actual_date_closed,
					       -1*bucket_amount_func,
					       -1*bucket_amount_prim,
					       -1*bucket_amount_sec
					  from
					    (select /*+ parallel(dis) */ null time_id,
					         max(nvl(dis.end_date, to_date('12/31/4712','MM/DD/YYYY'))) end_date,
					    	 dis.bill_to_customer_id,
					    	 dis.bill_to_site_use_id,
					    	 dis.org_id,
					    	 dis.customer_trx_id,
					    	 dis.payment_schedule_id,
					    	 dis.due_date,
					    	 dis.actual_date_closed,
					         sum(dis.dispute_amount_func)   bucket_amount_func,
					         sum(dis.dispute_amount_prim)   bucket_amount_prim,
					         sum(dis.dispute_amount_sec)    bucket_amount_sec
					    from fii_ar_dispute_history_f dis
					    group by dis.bill_to_customer_id,
					    	 dis.bill_to_site_use_id,
					    	 dis.org_id,
					    	 dis.customer_trx_id,
					    	 dis.payment_schedule_id,
					    	 dis.due_date,
					    	 dis.actual_date_closed)
					  where least(end_date, actual_date_closed) <> to_date('12/31/4712','MM/DD/YYYY')) v,
		             (SELECT 1 marker FROM DUAL UNION ALL
		              SELECT 2 marker FROM DUAL) m)
		    WHERE event_date is not null)
/*		GROUP BY time_id,
			  event_date,
		      next_aging_date,
			  bill_to_customer_id,
			  bill_to_site_use_id,
			  org_id,
			  --dispute_history_id,
			  customer_trx_id,
			  payment_schedule_id,
			  due_date,
			  current_dispute_amount_func,
			  current_dispute_amount_prim,
			  current_dispute_amount_sec,
			  past_due_dispute_amount_func,
			  past_due_dispute_amount_prim,
			  past_due_dispute_amount_sec,
		      aging_flag
*/
		order by payment_schedule_id, event_date

	)
	GROUP BY time_id,
		  event_date,
	      next_aging_date,
		  bill_to_customer_id,
		  bill_to_site_use_id,
		  org_id,
		  --dispute_history_id,
		  customer_trx_id,
		  payment_schedule_id,
		  due_date
	HAVING sum(current_dispute_amount_func) <> 0
		   or
	  	   sum(past_due_dispute_amount_func) <> 0;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_AGING_DISPUTES');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_AGING_DISPUTES table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_AGING_DISPUTES');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_DISPUTES_AGING;


PROCEDURE POPULATE_HELPER_TABLES IS

 l_class_category VARCHAR2(30) := NVL(fnd_profile.value('BIS_CUST_CLASS_TYPE'),'-1');
 l_unassigned_message VARCHAR2(30) := FND_MESSAGE.get_string('BIS', 'EDW_UNASSIGNED');

BEGIN

  g_state := 'Truncating table: fii_ar_help_mkt_classes';
  TRUNCATE_TABLE('FII_AR_HELP_MKT_CLASSES');

  g_state := 'Populating fii_ar_help_mkt_classes';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT into fii_ar_help_mkt_classes
  (class_category,
   class_code,
   class_name,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login )
  SELECT c.lookup_type class_category,
         c.lookup_code class_code,
         c.meaning name,
         sysdate,       --CREATION_DATE,
         g_fii_user_id, --CREATED_BY,
         sysdate,       --LAST_UPDATE_DATE,
         g_fii_user_id, --LAST_UPDATED_BY,
         g_fii_login_id --LAST_UPDATE_LOGIN
  FROM fnd_lookup_values c
  WHERE c.lookup_type = l_class_category
  AND nvl(c.language, userenv('LANG')) = userenv('LANG')
  AND nvl(view_application_id, 222) = 222
  AND exists (select 'x' from fii_party_mkt_class hz where hz.class_code = c.lookup_code)

  Union ALL
  SELECT l_class_category class_category,
         '-1' class_code,
         l_unassigned_message class_name,
         sysdate,       --CREATION_DATE,
         g_fii_user_id, --CREATED_BY,
         sysdate,       --LAST_UPDATE_DATE,
         g_fii_user_id, --LAST_UPDATED_BY,
         g_fii_login_id --LAST_UPDATE_LOGIN
  FROM dual;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_HELP_MKT_CLASSES');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Truncating table: FII_AR_HELP_COLLECTORS';
  TRUNCATE_TABLE('FII_AR_HELP_COLLECTORS');

  g_state := 'Populating FII_AR_HELP_COLLECTORS';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT into fii_ar_help_collectors
  (collector_id,
   name,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login )
  SELECT c.collector_id,
         c.name,
         sysdate,       --CREATION_DATE,
         g_fii_user_id, --CREATED_BY,
         sysdate,       --LAST_UPDATE_DATE,
         g_fii_user_id, --LAST_UPDATED_BY,
         g_fii_login_id --LAST_UPDATE_LOGIN
  FROM ar_collectors c
  WHERE exists (select 'x' from fii_collectors hz where hz.collector_id = c.collector_id);

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_HELP_COLLECTORS');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_HELP_MKT_CLASSES table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_HELP_MKT_CLASSES');
  g_state := 'Analyzing FII_AR_HELP_COLLECTORS table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_HELP_COLLECTORS');

  commit;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_HELPER_TABLES;


-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

-----------------------------------------------------------
-- Procedure
--   Collect()
-- Purpose
--   This Collect routine handles all procedures involved in populating FII
--   AR fact and aging tables in initial load.

-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2
				 ) IS
  l_dir                VARCHAR2(400);

BEGIN
  g_state := 'Inside the procedure COLLECT';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  Retcode := 0;

  ------------------------------------------------------
  -- Set default directory in case if the profile option
  -- BIS_DEBUG_LOG_DIRECTORY is not set up
  ------------------------------------------------------
  l_dir:=FII_UTIL.get_utl_file_dir;

  ----------------------------------------------------------------
  -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
  -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
  -- the log files and output files are written to
  ----------------------------------------------------------------
  FII_UTIL.initialize('FII_AR_FACTS_AGING_INIT.log','FII_AR_FACTS_AGING_INIT.out',l_dir, 'FII_AR_FACTS_AGING_INIT');

  EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE=UNLIMITED';
  EXECUTE IMMEDIATE 'alter session enable parallel dml';

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Init procedure to initialize the global variables');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INIT;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Populating fii_ar_setup with ''BIS: Party Market Classification Type''');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  UPDATE FII_AR_SETUP
  SET class_category = nvl(fnd_profile.value('BIS_CUST_CLASS_TYPE'),-1),
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = g_fii_user_id,
      LAST_UPDATE_LOGIN	= g_fii_login_id;

  IF SQL%ROWCOUNT = 0 THEN

	  INSERT INTO FII_AR_SETUP
	  (class_category,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN)
	  VALUES (fnd_profile.value('BIS_CUST_CLASS_TYPE'),
	   sysdate,        --CREATION_DATE,
	   g_fii_user_id,  --CREATED_BY,
	   sysdate,        --LAST_UPDATE_DATE,
	   g_fii_user_id,  --LAST_UPDATED_BY,
	   g_fii_login_id);--LAST_UPDATE_LOGIN

  END IF;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Populating dimension helper tables fii_ar_help_mkt_classes and fii_ar_help_collectors');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  POPULATE_HELPER_TABLES;


  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the GET_BUCKET_RANGES procedure to load and validate bucket range definitions');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  GET_BUCKET_RANGES;


  g_state := 'Truncating table FII_AR_CURR_RATES_T';
  TRUNCATE_TABLE('FII_AR_CURR_RATES_T');
  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Insert_Rates procedure to insert the missing rate info');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INSERT_RATES;


  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Verify_Missing_Rates procedure');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  IF (VERIFY_MISSING_RATES = -1) THEN
    g_retcode := -1;
    g_errbuf := fnd_message.get_string('FII', 'FII_MISS_EXCH_RATE_FOUND');

    RAISE G_MISSING_RATES;


  -----------------------------------------------------------------------
  -- If there are no missing exchange rate records, then insert
  -- records into the fact and aging tables
  -----------------------------------------------------------------------
  ELSE


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_PAYMENT_SCHEDULES');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_PAYMENT_SCHEDULES;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_DISPUTES');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_DISPUTES;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_TRANSACTIONS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_TRANSACTIONS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_ADJUSTMENTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_ADJUSTMENTS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_RECEIPTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_RECEIPTS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_SCHEDULED_DISCOUNTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_SCHEDULED_DISCOUNTS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_RECEIVABLES_AGING');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_RECEIVABLES_AGING;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_RECEIPTS_AGING');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_RECEIPTS_AGING;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_DISPUTES_AGING');
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('');
    end if;
    POPULATE_DISPUTES_AGING;

	g_state := 'Logging program sysdate as ar_last_update_date in fii_change_log table';

	INSERT INTO fii_change_log
	(log_item, item_value, CREATION_DATE, CREATED_BY,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
	(SELECT 'AR_LAST_UPDATE_DATE',
			to_char(g_sysdate_time,'MM/DD/YYYY HH24:MI:SS'),
			sysdate,        --CREATION_DATE,
		    g_fii_user_id,  --CREATED_BY,
	        sysdate,        --LAST_UPDATE_DATE,
		    g_fii_user_id,  --LAST_UPDATED_BY,
		    g_fii_login_id  --LAST_UPDATE_LOGIN
	 FROM DUAL
	 WHERE NOT EXISTS
		(select 1 from fii_change_log
		 where log_item = 'AR_LAST_UPDATE_DATE'));

	IF (SQL%ROWCOUNT = 0) THEN
	    UPDATE fii_change_log
    	SET item_value = to_char(g_sysdate_time,'MM/DD/YYYY HH24:MI:SS'),
        	last_update_date  = g_sysdate_time,
        	last_update_login = g_fii_login_id,
        	last_updated_by   = g_fii_user_id
	    WHERE log_item = 'AR_LAST_UPDATE_DATE';
	END IF;


  END IF;

  COMMIT;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('return code is ' || retcode);
  end if;

  g_retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK;
    g_retcode:= -1;
	retcode := g_retcode;
    g_exception_msg  := g_retcode || ':' || g_errbuf;
    if g_debug_flag = 'Y' then
    	FII_UTIL.put_line('Error occured while: ' || g_state);
    end if;
    FII_UTIL.put_line(g_exception_msg);
/*
	dbms_output.put_line('Error occured while: ' || g_state);
	dbms_output.put_line('Error Message: ' || g_exception_msg);
*/
END;

-- ===========================================================================
-- AR DBI Incremental Extraction
-- ===========================================================================

------------------------------------
---- PROCEDURE Inc_Prepare
------------------------------------
PROCEDURE Inc_Prepare IS

BEGIN

  g_state := 'Getting data from fii_change_log';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_line('');
  end if;

  select to_date(item_value,'MM/DD/YYYY HH24:MI:SS') into G_LAST_UPDATE_DATE
  from fii_change_log
  where log_item = 'AR_LAST_UPDATE_DATE';

  select item_value into G_MAX_PAYMENT_SCHEDULE_ID
  from fii_change_log
  where log_item = 'AR_MAX_PAYMENT_SCHEDULE_ID';

  select item_value into G_MAX_RECEIVABLE_APPL_ID
  from fii_change_log
  where log_item = 'AR_MAX_RECEIVABLE_APPLICATION_ID';

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('G_LAST_UPDATE_DATE is ' ||
                        to_char(G_LAST_UPDATE_DATE,'MM/DD/YYYY HH24:MI:SS'));
     FII_UTIL.put_line('G_MAX_PAYMENT_SCHEDULE_ID is ' ||
                        G_MAX_PAYMENT_SCHEDULE_ID);
     FII_UTIL.put_line('G_MAX_RECEIVABLE_APPL_ID is ' ||
                        G_MAX_RECEIVABLE_APPL_ID);
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_PAYSCH_INSERT_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Insert
  insert into FII_AR_PAYSCH_INSERT_GT
  (
  payment_schedule_id,
  customer_trx_id,
  class,
  gl_date,
  trx_date
  )
  select PAYMENT_SCHEDULE_ID
       , CUSTOMER_TRX_ID
       , class
       , gl_date
       , trx_date
  from ar_payment_schedules_all
  where PAYMENT_SCHEDULE_ID > G_MAX_PAYMENT_SCHEDULE_ID
  and class in ('INV', 'DM', 'CB', 'CM', 'DEP', 'BR', 'PMT')
  and decode(g_collection_criteria, 'GL', gl_date, trx_date) >=
      g_global_start_date

  union all

  select distinct sch.PAYMENT_SCHEDULE_ID
       , sch.CUSTOMER_TRX_ID
       , sch.class
       , sch.gl_date
       , sch.trx_date
  from ar_payment_schedules_all sch,
       ar_receivable_applications_all app,
       ar_payment_schedules_all trxsch
  where sch.PAYMENT_SCHEDULE_ID > G_MAX_PAYMENT_SCHEDULE_ID
  and sch.class in ('PMT')
  and decode(g_collection_criteria, 'GL', sch.gl_date, sch.trx_date) <
      g_global_start_date
  and app.status = 'APP'
  and sch.payment_schedule_id = app.payment_schedule_id
  and app.applied_payment_schedule_id = trxsch.payment_schedule_id
  and decode(g_collection_criteria, 'GL', trxsch.gl_date, trxsch.trx_date) >=
      g_global_start_date
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_PAYSCH_INSERT_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_DISP_UPDATE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Update 1
  insert into FII_AR_DISP_UPDATE_GT
  (
  payment_schedule_id,
  dispute_history_id,
  dispute_amount,
  start_date,
  end_date,
  last_update_date
  )
  select PAYMENT_SCHEDULE_ID
       , dispute_history_id
       , dispute_amount
       , start_date
       , end_date
       , last_update_date
  from ar_dispute_history
  -- Update end_date, but not LAST_UPDATE_DATE
  where PAYMENT_SCHEDULE_ID in (
        select PAYMENT_SCHEDULE_ID
        from ar_dispute_history
        where LAST_UPDATE_DATE > G_LAST_UPDATE_DATE
        and   start_date >= g_global_start_date
        and   LAST_UPDATE_DATE <= g_sysdate_time
  )
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_DISP_UPDATE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_ADJ_UPDATE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Update 2
  insert into FII_AR_ADJ_UPDATE_GT
  (
  payment_schedule_id,
  adjustment_id,
  adjustment_type,
  customer_trx_id,
  subsequent_trx_id,
  chargeback_customer_trx_id,
  org_id,
  amount,
  status,
  created_by,
  creation_date,
  gl_date,
  apply_date,
  last_update_date
  )
  select PAYMENT_SCHEDULE_ID
       , adjustment_id
       , adjustment_type
       , customer_trx_id
       , subsequent_trx_id
       , chargeback_customer_trx_id
       , org_id
       , amount
       , status
       , created_by
       , creation_date
       , gl_date
       , apply_date
       , last_update_date
  from ar_adjustments_all
  where LAST_UPDATE_DATE > G_LAST_UPDATE_DATE
  and STATUS = 'A'
  and last_update_date <= g_sysdate_time
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_ADJ_UPDATE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_RECAPP_INSERT_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Update 3
  insert into FII_AR_RECAPP_INSERT_GT
  (
  applied_payment_schedule_id,
  payment_schedule_id,
  applied_customer_trx_id,
  customer_trx_id,
  receivable_application_id,
  application_type,
  cash_receipt_id,
  org_id,
  status,
  created_by,
  creation_date,
  gl_date,
  apply_date,
  amount_applied_from,
  amount_applied,
  acctd_amount_applied_from,
  acctd_amount_applied_to,
  earned_discount_taken,
  acctd_earned_discount_taken,
  unearned_discount_taken,
  acctd_unearned_discount_taken
  )
 select APPLIED_PAYMENT_SCHEDULE_ID
        , payment_schedule_id
        , applied_customer_trx_id
        , CUSTOMER_TRX_ID
        , RECEIVABLE_APPLICATION_ID
        , application_type
        , cash_receipt_id
        , org_id
        , status
        , created_by
        , creation_date
        , gl_date
        , apply_date
        , AMOUNT_APPLIED_FROM
        , AMOUNT_APPLIED
        , acctd_amount_applied_from
        , acctd_amount_applied_to
        , EARNED_DISCOUNT_TAKEN
        , acctd_earned_discount_taken
        , UNEARNED_DISCOUNT_TAKEN
        , acctd_unearned_discount_taken
   from ar_receivable_applications_all app
   -- To calculate rct_gl_date
   where exists (select 'x' from ar_receivable_applications_all app2
                     where app2.RECEIVABLE_APPLICATION_ID > G_MAX_RECEIVABLE_APPL_ID
                     and app2.cash_receipt_id = app.cash_receipt_id

                     and (app2.status in ('APP', 'ACTIVITY')
                          or application_type = 'CASH')  )

 union all

 select APPLIED_PAYMENT_SCHEDULE_ID
        , payment_schedule_id
        , applied_customer_trx_id
        , CUSTOMER_TRX_ID
        , RECEIVABLE_APPLICATION_ID
        , application_type
        , cash_receipt_id
        , org_id
        , status
        , created_by
        , creation_date
        , gl_date
        , apply_date
        , AMOUNT_APPLIED_FROM
        , AMOUNT_APPLIED
        , acctd_amount_applied_from
        , acctd_amount_applied_to
        , EARNED_DISCOUNT_TAKEN
        , acctd_earned_discount_taken
        , UNEARNED_DISCOUNT_TAKEN
        , acctd_unearned_discount_taken
   from ar_receivable_applications_all app
   -- To calculate rct_gl_date
   where exists (select 'x' from ar_receivable_applications_all app2
                     where app2.RECEIVABLE_APPLICATION_ID > G_MAX_RECEIVABLE_APPL_ID
                     and app2.customer_trx_id = app.customer_trx_id
                     and application_type = 'CM')
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_RECAPP_INSERT_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_TRANS_DELETE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Delete 1
  insert into FII_AR_TRANS_DELETE_GT
  (
  customer_trx_id
  )
  select CUSTOMER_TRX_ID
  from ra_customer_trx_all
  where LAST_UPDATE_DATE > G_LAST_UPDATE_DATE
  and COMPLETE_FLAG = 'N'
  and last_update_date <= g_sysdate_time
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_TRANS_DELETE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  -- PaySch Delete 2
  /*
  insert into FII_AR_PAYSCH_DELETE_PAYSCH_GT
  select CUSTOMER_TRX_ID
  from ar_payment_schedules_all
  where PAYMENT_SCHEDULE_ID > G_MAX_PAYMENT_SCHEDULE_ID;
  */

  g_state := 'Populating FII_AR_RECAPP_DELETE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  -- PaySch Delete 3
  insert into FII_AR_RECAPP_DELETE_GT
  (
  receivable_application_id,
  payment_schedule_id,
  CASH_RECEIPT_ID
  )
  select RECEIVABLE_APPLICATION_ID, PAYMENT_SCHEDULE_ID, CASH_RECEIPT_ID
  from fii_ar_receipts_f
  where CASH_RECEIPT_ID in (
    select CASH_RECEIPT_ID from FII_AR_RECEIPTS_DELETE_T
    where CREATION_DATE <= g_sysdate_time
  )
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_RECAPP_DELETE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_PAYSCH_MERGE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  insert into FII_AR_PAYSCH_MERGE_GT
  (
  class,
  org_id,
  invoice_currency_code,
  exchange_rate,
  exchange_date,
  gl_date,
  trx_date,
  due_date,
  actual_date_closed,
  payment_schedule_id,
  trx_number,
  customer_trx_id,
  cust_trx_type_id,
  customer_id,
  customer_site_use_id,
  amount_due_original,
  amount_due_remaining,
  discount_taken_earned,
  discount_taken_unearned,
  amount_adjusted,
  amount_in_dispute,
  status,
  term_id,
  terms_sequence_number,
  created_by
  )
  select class
       , org_id
       , invoice_currency_code
       , exchange_rate
       , exchange_date
       , trunc(gl_date)
       , trunc(trx_date)
       , trunc(due_date)
       , actual_date_closed
       , payment_schedule_id
       , trx_number
       , customer_trx_id
       , cust_trx_type_id
       , customer_id
       , customer_site_use_id
       , amount_due_original
       , amount_due_remaining
       , discount_taken_earned
       , discount_taken_unearned
       , amount_adjusted
       , amount_in_dispute
       , status
       , term_id
       , terms_sequence_number
       , created_by
  from ar_payment_schedules_all
  where PAYMENT_SCHEDULE_ID in (
      -- PaySch Insert
      select PAYMENT_SCHEDULE_ID
      from FII_AR_PAYSCH_INSERT_GT
      union all
      -- PaySch Update 1
      select PAYMENT_SCHEDULE_ID
      from FII_AR_DISP_UPDATE_GT
      union all
      -- PaySch Update 2
      select PAYMENT_SCHEDULE_ID
      from FII_AR_ADJ_UPDATE_GT
      union all
      -- PaySch Update 3
      select APPLIED_PAYMENT_SCHEDULE_ID
      from FII_AR_RECAPP_INSERT_GT
      union all
      -- PaySch Update 3 (receipt rates)
      select PAYMENT_SCHEDULE_ID
      from FII_AR_RECAPP_INSERT_GT
      )
  and CLASS IN ('INV', 'DM', 'CB', 'CM', 'DEP', 'BR', 'PMT');
  --and decode(g_collection_criteria, 'GL', gl_date, trx_date) >= g_global_start_date;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_PAYSCH_MERGE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Populating FII_AR_PAYSCH_DELETE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  insert into FII_AR_PAYSCH_DELETE_GT
  (
  payment_schedule_id
  )
  select PAYMENT_SCHEDULE_ID
  from fii_ar_pmt_schedules_f
  where CUSTOMER_TRX_ID in (
      -- PaySch Delete 1
      select CUSTOMER_TRX_ID
      from FII_AR_TRANS_DELETE_GT
      union all
      -- PaySch Delete 2
      select CUSTOMER_TRX_ID
      from FII_AR_PAYSCH_INSERT_GT -- FII_AR_PAYSCH_DELETE_PAYSCH_GT
  )
  union
  -- PaySch Delete 3
  select PAYMENT_SCHEDULE_ID
  from FII_AR_RECAPP_DELETE_GT
  ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_PAYSCH_DELETE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

EXCEPTION

  WHEN OTHERS THEN
       g_retcode := -1;
       g_errbuf := '
---------------------------------
Error in Procedure: Inc_Prepare
Message: '||sqlerrm;
       g_exception_msg := g_retcode || ':' || g_errbuf;
       FII_UTIL.put_line('Error occured while ' || g_state);
       FII_UTIL.put_line(g_exception_msg);
       RAISE;

END Inc_Prepare;

------------------------------------
---- PROCEDURE Inc_RATES
------------------------------------
PROCEDURE Inc_RATES IS

BEGIN

  g_state := 'Loading data into rates table FII_AR_CURR_RATES_T';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  INSERT /*+ append */ INTO FII_AR_CURR_RATES_T
    (SELECT sob.currency_code fc_code,
            Decode(NVL(cur.minimum_accountable_unit,
                       power( 10, (-1 * cur.precision))),
                   null, 0.01,
                   0, 1,
                   NVL(cur.minimum_accountable_unit,
                       power( 10, (-1 * cur.precision)))) functional_mau,
            conversion_date,
            MAX(FII_CURRENCY.Get_FC_to_PGC_Rate (v.tc_code,
                     sob.currency_code, v.conversion_date)) prim_conversion_rate,
            MAX(FII_CURRENCY.Get_FC_to_SGC_Rate (v.tc_code,
                     sob.currency_code, v.conversion_date)) sec_conversion_rate,
            sysdate,       --CREATION_DATE,
            g_fii_user_id, --CREATED_BY,
            sysdate,       --LAST_UPDATE_DATE,
            g_fii_user_id, --LAST_UPDATED_BY,
            g_fii_login_id --LAST_UPDATE_LOGIN
     FROM (--Currency rates for payment schedules and receipts
           SELECT /*+ no_merge parallel(sch) */ DISTINCT
                  sch.invoice_currency_code tc_code,
                  sch.org_id,
                  trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) conversion_date
               FROM FII_AR_PAYSCH_MERGE_GT sch
               --WHERE sch.class IN ('INV','DM','CB','CM','DEP','BR','PMT')
               --AND sch.trx_date >= g_global_start_date
           ) v,
           ar_system_parameters_all par,
           gl_sets_of_books sob,
           fnd_currencies cur
     WHERE v.org_id = par.org_id
     AND par.set_of_books_id = sob.set_of_books_id
     AND cur.currency_code = sob.currency_code
     GROUP BY sob.currency_code,
              cur.minimum_accountable_unit,
              cur.precision,
              conversion_date);


  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  COMMIT;
/*
--------------------
--Temporarily added to avoid: missing currency conversion rates error
---------------------
update FII_AR_CURR_RATES_T
set prim_conversion_rate=1
where prim_conversion_rate<=0;

update FII_AR_CURR_RATES_T
set sec_conversion_rate=1
where sec_conversion_rate<=0;
commit;
------------------------
*/

  g_state := 'Analyzing FII_AR_CURR_RATES_T table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_CURR_RATES_T');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_RATES;

------------------------------------------------------------------
-- Procedure Inc_PAYMENT_SCHEDULES
-- Purpose
--   This procedure manipulates records in FII_AR_PMT_SCHEDULES_F
------------------------------------------------------------------
PROCEDURE Inc_PAYMENT_SCHEDULES IS

l_max_pmt_schedule_id NUMBER(15);

BEGIN

  /*
  g_state := 'Truncating table FII_AR_PMT_SCHEDULES_F';
  TRUNCATE_TABLE('FII_AR_PMT_SCHEDULES_F');
  */

  g_state := 'Deleting records from FII_AR_PMT_SCHEDULES_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  delete from fii_ar_pmt_schedules_f
  where PAYMENT_SCHEDULE_ID in (
      -- PaySch Delete 1 2 3
      select PAYMENT_SCHEDULE_ID
      from FII_AR_PAYSCH_DELETE_GT
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from FII_AR_PMT_SCHEDULES_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Merging into FII_AR_PMT_SCHEDULES_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  merge into fii_ar_pmt_schedules_f old using (
    -- POPULATE_PAYMENT_SCHEDULES
    SELECT sch.payment_schedule_id,
          to_number(to_char(decode(g_collection_criteria,
                                   'GL', sch.gl_date,
                                   sch.trx_date), 'J')) time_id,
          sch.class,
          sch.amount_due_original amount_due_original_trx,
          NVL(ROUND(sch.amount_due_original * nvl(sch.exchange_rate,1) /
                rt.functional_mau) * rt.functional_mau,
                nvl(sch.amount_due_original,0)) amount_due_original_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) amount_due_original_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_original,0),
                ROUND((nvl(sch.amount_due_original,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_original_sec,
          sch.amount_due_remaining amount_due_remaining_trx,
          NVL(ROUND(sch.amount_due_remaining * nvl(sch.exchange_rate,1) /
              rt.functional_mau) * rt.functional_mau,
              nvl(sch.amount_due_remaining,0)) amount_due_remaining_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau ) *
                    g_primary_mau) amount_due_remaining_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_due_remaining,0),
                ROUND((nvl(sch.amount_due_remaining,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_due_remaining_sec,
          trunc(sch.trx_date) trx_date,
          trunc(sch.gl_date) gl_date,
          decode(g_collection_criteria,'GL',sch.gl_date,sch.trx_date) filter_date,
          trunc(sch.due_date) due_date,
          sch.status,
          sch.customer_trx_id,
          sch.invoice_currency_code,
          sch.customer_id bill_to_customer_id,
          sch.customer_site_use_id bill_to_site_use_id,
          sch.org_id,
          sch.created_by user_id,
          sch.cust_trx_type_id cust_trx_type_id,
          sch.trx_number transaction_number,
          sch.term_id,
          sch.terms_sequence_number,
          trx.batch_source_id,
          sch.discount_taken_earned earned_discount_amount_trx,
          NVL(ROUND(sch.discount_taken_earned * nvl(sch.exchange_rate,1) /
                rt.functional_mau) * rt.functional_mau,
                nvl(sch.discount_taken_earned,0))  earned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) earned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_earned,0),
                ROUND((nvl(sch.discount_taken_earned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) earned_discount_amount_sec,
          nvl(sch.discount_taken_unearned,0)  unearned_discount_amount_trx,
          NVL(ROUND(sch.discount_taken_unearned * nvl(sch.exchange_rate,1) /
                rt.functional_mau) * rt.functional_mau,
                nvl(sch.discount_taken_unearned,0))  unearned_discount_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) unearned_discount_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.discount_taken_unearned,0),
                ROUND((nvl(sch.discount_taken_unearned,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) unearned_discount_amount_sec,
          nvl(sch.amount_adjusted,0) adjusted_amount_trx,
          NVL(ROUND(sch.amount_adjusted * nvl(sch.exchange_rate,1) /
                rt.functional_mau) * rt.functional_mau,
                nvl(sch.amount_adjusted,0)) adjusted_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) adjusted_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_adjusted,0),
                ROUND((nvl(sch.amount_adjusted,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) adjusted_amount_sec,
          nvl(sch.amount_in_dispute,0) disputed_amount_trx,
          NVL(ROUND(sch.amount_in_dispute * nvl(sch.exchange_rate,1) /
                rt.functional_mau) * rt.functional_mau ,
                nvl(sch.amount_in_dispute,0)) disputed_amount_func,
          DECODE(sch.invoice_currency_code,
                g_prim_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) disputed_amount_prim,
          DECODE(sch.invoice_currency_code,
                g_sec_currency, nvl(sch.amount_in_dispute,0),
                ROUND((nvl(sch.amount_in_dispute,0) * nvl(sch.exchange_rate,1) *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) disputed_amount_sec,
          decode(trx.batch_source_id,
                 -1, trx.ct_reference,
                 null) order_ref_number,
          sch.actual_date_closed,
          nvl(sch.exchange_rate,1) EXCHANGE_RATE,
          nvl(sch.exchange_date, sch.trx_date) EXCHANGE_DATE,
          trx.previous_customer_trx_id,
          sysdate        CREATION_DATE,
          g_fii_user_id  CREATED_BY,
          sysdate        LAST_UPDATE_DATE,
          g_fii_user_id  LAST_UPDATED_BY,
          g_fii_login_id LAST_UPDATE_LOGIN
    FROM FII_AR_PAYSCH_MERGE_GT sch,
         RA_CUSTOMER_TRX_ALL trx,
         FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob
    WHERE sch.class IN ('INV','DM','CB','CM','DEP','BR', 'PMT')
    /*AND decode(g_collection_criteria,
               'GL', sch.gl_date,
               sch.trx_date) >= g_global_start_date */
    AND sch.customer_trx_id = trx.customer_trx_id (+)

    AND sch.org_id = par.org_id
    AND par.set_of_books_id = sob.set_of_books_id
    AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date
  ) dlt
  on ( old.PAYMENT_SCHEDULE_ID = dlt.PAYMENT_SCHEDULE_ID )
  when matched then update set
    -- old.PAYMENT_SCHEDULE_ID = dlt.PAYMENT_SCHEDULE_ID,
    -- old.TIME_ID = dlt.TIME_ID,
    -- old.CLASS = dlt.CLASS,
    -- old.AMOUNT_DUE_ORIGINAL_TRX = dlt.AMOUNT_DUE_ORIGINAL_TRX,
    -- old.AMOUNT_DUE_ORIGINAL_FUNC = dlt.AMOUNT_DUE_ORIGINAL_FUNC,
    -- old.AMOUNT_DUE_ORIGINAL_PRIM = dlt.AMOUNT_DUE_ORIGINAL_PRIM,
    -- old.AMOUNT_DUE_ORIGINAL_SEC = dlt.AMOUNT_DUE_ORIGINAL_SEC,
    old.AMOUNT_DUE_REMAINING_TRX = dlt.AMOUNT_DUE_REMAINING_TRX,
    old.AMOUNT_DUE_REMAINING_FUNC = dlt.AMOUNT_DUE_REMAINING_FUNC,
    old.AMOUNT_DUE_REMAINING_PRIM = dlt.AMOUNT_DUE_REMAINING_PRIM,
    old.AMOUNT_DUE_REMAINING_SEC = dlt.AMOUNT_DUE_REMAINING_SEC,
    -- old.TRX_DATE = dlt.TRX_DATE,
    -- old.GL_DATE = dlt.GL_DATE,
    -- old.FILTER_DATE = dlt.FILTER_DATE,
    old.DUE_DATE = dlt.DUE_DATE,
    old.STATUS = dlt.STATUS,
    -- old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID,
    -- old.INVOICE_CURRENCY_CODE = dlt.INVOICE_CURRENCY_CODE,
    -- old.BILL_TO_CUSTOMER_ID = dlt.BILL_TO_CUSTOMER_ID,
    -- old.BILL_TO_SITE_USE_ID = dlt.BILL_TO_SITE_USE_ID,
    -- old.ORG_ID = dlt.ORG_ID,
    -- old.USER_ID = dlt.USER_ID,
    -- old.CUST_TRX_TYPE_ID = dlt.CUST_TRX_TYPE_ID,
    -- old.TRANSACTION_NUMBER = dlt.TRANSACTION_NUMBER,
    old.TERM_ID = dlt.TERM_ID,
    old.terms_sequence_number = dlt.terms_sequence_number,
    -- old.BATCH_SOURCE_ID = dlt.BATCH_SOURCE_ID,
    old.EARNED_DISCOUNT_AMOUNT_TRX = dlt.EARNED_DISCOUNT_AMOUNT_TRX,
    old.EARNED_DISCOUNT_AMOUNT_FUNC = dlt.EARNED_DISCOUNT_AMOUNT_FUNC,
    old.EARNED_DISCOUNT_AMOUNT_PRIM = dlt.EARNED_DISCOUNT_AMOUNT_PRIM,
    old.EARNED_DISCOUNT_AMOUNT_SEC = dlt.EARNED_DISCOUNT_AMOUNT_SEC,
    old.UNEARNED_DISCOUNT_AMOUNT_TRX = dlt.UNEARNED_DISCOUNT_AMOUNT_TRX,
    old.UNEARNED_DISCOUNT_AMOUNT_FUNC = dlt.UNEARNED_DISCOUNT_AMOUNT_FUNC,
    old.UNEARNED_DISCOUNT_AMOUNT_PRIM = dlt.UNEARNED_DISCOUNT_AMOUNT_PRIM,
    old.UNEARNED_DISCOUNT_AMOUNT_SEC = dlt.UNEARNED_DISCOUNT_AMOUNT_SEC,
    old.ADJUSTED_AMOUNT_TRX = dlt.ADJUSTED_AMOUNT_TRX,
    old.ADJUSTED_AMOUNT_FUNC = dlt.ADJUSTED_AMOUNT_FUNC,
    old.ADJUSTED_AMOUNT_PRIM = dlt.ADJUSTED_AMOUNT_PRIM,
    old.ADJUSTED_AMOUNT_SEC = dlt.ADJUSTED_AMOUNT_SEC,
    old.DISPUTED_AMOUNT_TRX = dlt.DISPUTED_AMOUNT_TRX,
    old.DISPUTED_AMOUNT_FUNC = dlt.DISPUTED_AMOUNT_FUNC,
    old.DISPUTED_AMOUNT_PRIM = dlt.DISPUTED_AMOUNT_PRIM,
    old.DISPUTED_AMOUNT_SEC = dlt.DISPUTED_AMOUNT_SEC,
    old.ORDER_REF_NUMBER = dlt.ORDER_REF_NUMBER,
    old.ACTUAL_DATE_CLOSED = dlt.ACTUAL_DATE_CLOSED,
    old.EXCHANGE_RATE = dlt.EXCHANGE_RATE,
    old.EXCHANGE_DATE = dlt.EXCHANGE_DATE,
    old.PREVIOUS_CUSTOMER_TRX_ID = dlt.PREVIOUS_CUSTOMER_TRX_ID,
    -- old.CREATION_DATE = dlt.CREATION_DATE,
    -- old.CREATED_BY = dlt.CREATED_BY,
    old.LAST_UPDATE_DATE = dlt.LAST_UPDATE_DATE,
    old.LAST_UPDATED_BY = dlt.LAST_UPDATED_BY,
    old.LAST_UPDATE_LOGIN = dlt.LAST_UPDATE_LOGIN
  when not matched then insert
  (
    PAYMENT_SCHEDULE_ID,
    TIME_ID,
    CLASS,
    AMOUNT_DUE_ORIGINAL_TRX,
    AMOUNT_DUE_ORIGINAL_FUNC,
    AMOUNT_DUE_ORIGINAL_PRIM,
    AMOUNT_DUE_ORIGINAL_SEC,
    AMOUNT_DUE_REMAINING_TRX,
    AMOUNT_DUE_REMAINING_FUNC,
    AMOUNT_DUE_REMAINING_PRIM,
    AMOUNT_DUE_REMAINING_SEC,
    TRX_DATE,
    GL_DATE,
    FILTER_DATE,
    DUE_DATE,
    STATUS,
    CUSTOMER_TRX_ID,
    INVOICE_CURRENCY_CODE,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    ORG_ID,
    USER_ID,
    CUST_TRX_TYPE_ID,
    TRANSACTION_NUMBER,
    TERM_ID,
    terms_sequence_number,
    BATCH_SOURCE_ID,
    EARNED_DISCOUNT_AMOUNT_TRX,
    EARNED_DISCOUNT_AMOUNT_FUNC,
    EARNED_DISCOUNT_AMOUNT_PRIM,
    EARNED_DISCOUNT_AMOUNT_SEC,
    UNEARNED_DISCOUNT_AMOUNT_TRX,
    UNEARNED_DISCOUNT_AMOUNT_FUNC,
    UNEARNED_DISCOUNT_AMOUNT_PRIM,
    UNEARNED_DISCOUNT_AMOUNT_SEC,
    ADJUSTED_AMOUNT_TRX,
    ADJUSTED_AMOUNT_FUNC,
    ADJUSTED_AMOUNT_PRIM,
    ADJUSTED_AMOUNT_SEC,
    DISPUTED_AMOUNT_TRX,
    DISPUTED_AMOUNT_FUNC,
    DISPUTED_AMOUNT_PRIM,
    DISPUTED_AMOUNT_SEC,
    ORDER_REF_NUMBER,
    ACTUAL_DATE_CLOSED,
    EXCHANGE_RATE,
    EXCHANGE_DATE,
    PREVIOUS_CUSTOMER_TRX_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    dlt.PAYMENT_SCHEDULE_ID,
    dlt.TIME_ID,
    dlt.CLASS,
    dlt.AMOUNT_DUE_ORIGINAL_TRX,
    dlt.AMOUNT_DUE_ORIGINAL_FUNC,
    dlt.AMOUNT_DUE_ORIGINAL_PRIM,
    dlt.AMOUNT_DUE_ORIGINAL_SEC,
    dlt.AMOUNT_DUE_REMAINING_TRX,
    dlt.AMOUNT_DUE_REMAINING_FUNC,
    dlt.AMOUNT_DUE_REMAINING_PRIM,
    dlt.AMOUNT_DUE_REMAINING_SEC,
    dlt.TRX_DATE,
    dlt.GL_DATE,
    dlt.FILTER_DATE,
    dlt.DUE_DATE,
    dlt.STATUS,
    dlt.CUSTOMER_TRX_ID,
    dlt.INVOICE_CURRENCY_CODE,
    dlt.BILL_TO_CUSTOMER_ID,
    dlt.BILL_TO_SITE_USE_ID,
    dlt.ORG_ID,
    dlt.USER_ID,
    dlt.CUST_TRX_TYPE_ID,
    dlt.TRANSACTION_NUMBER,
    dlt.TERM_ID,
    dlt.terms_sequence_number,
    dlt.BATCH_SOURCE_ID,
    dlt.EARNED_DISCOUNT_AMOUNT_TRX,
    dlt.EARNED_DISCOUNT_AMOUNT_FUNC,
    dlt.EARNED_DISCOUNT_AMOUNT_PRIM,
    dlt.EARNED_DISCOUNT_AMOUNT_SEC,
    dlt.UNEARNED_DISCOUNT_AMOUNT_TRX,
    dlt.UNEARNED_DISCOUNT_AMOUNT_FUNC,
    dlt.UNEARNED_DISCOUNT_AMOUNT_PRIM,
    dlt.UNEARNED_DISCOUNT_AMOUNT_SEC,
    dlt.ADJUSTED_AMOUNT_TRX,
    dlt.ADJUSTED_AMOUNT_FUNC,
    dlt.ADJUSTED_AMOUNT_PRIM,
    dlt.ADJUSTED_AMOUNT_SEC,
    dlt.DISPUTED_AMOUNT_TRX,
    dlt.DISPUTED_AMOUNT_FUNC,
    dlt.DISPUTED_AMOUNT_PRIM,
    dlt.DISPUTED_AMOUNT_SEC,
    dlt.ORDER_REF_NUMBER,
    dlt.ACTUAL_DATE_CLOSED,
    dlt.EXCHANGE_RATE,
    dlt.EXCHANGE_DATE,
    dlt.PREVIOUS_CUSTOMER_TRX_ID,
    dlt.CREATION_DATE,
    dlt.CREATED_BY,
    dlt.LAST_UPDATE_DATE,
    dlt.LAST_UPDATED_BY,
    dlt.LAST_UPDATE_LOGIN
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' ||SQL%ROWCOUNT|| ' records into FII_AR_PMT_SCHEDULES_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_PMT_SCHEDULES_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_PMT_SCHEDULES_F');

  g_state := 'Logging maximum payment schedule id into fii_change_log table';
  select nvl(max(payment_schedule_id), -999)
  into l_max_pmt_schedule_id
  from fii_ar_pmt_schedules_f;

  INSERT INTO fii_change_log
  (log_item, item_value, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
  (SELECT 'AR_MAX_PAYMENT_SCHEDULE_ID',
        l_max_pmt_schedule_id,
        sysdate,        --CREATION_DATE,
        g_fii_user_id,  --CREATED_BY,
        sysdate,        --LAST_UPDATE_DATE,
        g_fii_user_id,  --LAST_UPDATED_BY,
        g_fii_login_id  --LAST_UPDATE_LOGIN
   FROM DUAL
   WHERE NOT EXISTS
      (select 1 from fii_change_log
       where log_item = 'AR_MAX_PAYMENT_SCHEDULE_ID'));

  IF (SQL%ROWCOUNT = 0) THEN
      UPDATE fii_change_log
      SET item_value = l_max_pmt_schedule_id,
          last_update_date  = g_sysdate_time,
          last_update_login = g_fii_login_id,
          last_updated_by   = g_fii_user_id
      WHERE log_item = 'AR_MAX_PAYMENT_SCHEDULE_ID';
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_PAYMENT_SCHEDULES;

------------------------------------------------------------------
-- Procedure Inc_DISPUTES
-- Purpose
--   This procedure manipulates records in FII_AR_DISPUTE_HISTORY_F
------------------------------------------------------------------
PROCEDURE Inc_DISPUTES IS
BEGIN

  /*
  g_state := 'Truncating table FII_AR_DISPUTE_HISTORY_F';
  TRUNCATE_TABLE('FII_AR_DISPUTE_HISTORY_F');
  */

  g_state := 'Deleting FII_AR_DISPUTE_HISTORY_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  delete from fii_ar_dispute_history_f
  where PAYMENT_SCHEDULE_ID in (
      -- PaySch Delete 1 2 3
      select PAYMENT_SCHEDULE_ID
      from FII_AR_PAYSCH_DELETE_GT
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from FII_AR_DISPUTE_HISTORY_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Merging into FII_AR_DISPUTE_HISTORY_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  merge into fii_ar_dispute_history_f old using (
    -- POPULATE_DISPUTES
    SELECT dis.dispute_history_id,
      to_number(to_char(dis.start_date, 'J')) time_id,
      dis.dispute_amount dispute_amount_trx,
      NVL(ROUND(dis.dispute_amount * sch.exchange_rate / rt.functional_mau)
            * rt.functional_mau, nvl(dis.dispute_amount,0)) dispute_amount_func,
      DECODE(sch.invoice_currency_code,
            g_prim_currency, nvl(dis.dispute_amount,0),
            ROUND((nvl(dis.dispute_amount,0) * sch.exchange_rate *
                rt.prim_conversion_rate) / g_primary_mau) *
                g_primary_mau) dispute_amount_prim,
      DECODE(sch.invoice_currency_code,
            g_sec_currency, nvl(dis.dispute_amount,0),
            ROUND((nvl(dis.dispute_amount,0) * sch.exchange_rate *
                rt.sec_conversion_rate) / g_secondary_mau) *
                g_secondary_mau) dispute_amount_sec,
      dis.start_date,
      dis.end_date,
      sch.org_id,
      sch.bill_to_customer_id,
      sch.bill_to_site_use_id,
      dis.payment_schedule_id,
      sch.customer_trx_id,
      sch.due_date,
      sch.actual_date_closed,
      sysdate        CREATION_DATE,
      g_fii_user_id  CREATED_BY,
      sysdate        LAST_UPDATE_DATE,
      g_fii_user_id  LAST_UPDATED_BY,
      g_fii_login_id LAST_UPDATE_LOGIN
    FROM /* (
              select * from FII_AR_DISP_UPDATE_GT
              -- where start_date >= g_global_start_date
              -- and last_update_date <= g_sysdate_time
         ) */
         FII_AR_DISP_UPDATE_GT dis,
         -- FII_AR_PMT_SCHEDULES_F sch, --> FII_AR_PAYSCH_MERGE_GT
         ( select
             actual_date_closed,
             sch.customer_id bill_to_customer_id,
             sch.customer_site_use_id bill_to_site_use_id,
             class,
             customer_trx_id,
             due_date,
             nvl(sch.exchange_date, sch.trx_date) exchange_date,
             nvl(sch.exchange_rate,1) exchange_rate,
             invoice_currency_code,
             org_id,
             payment_schedule_id,
             trx_date
           from FII_AR_PAYSCH_MERGE_GT sch
         ) sch,
         FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob
    WHERE dis.payment_schedule_id = sch.payment_schedule_id
    AND sch.class <> 'PMT'
    AND dis.start_date <= sch.actual_date_closed
    AND dis.start_date >= g_global_start_date
    AND dis.last_update_date <= g_sysdate_time  --To avoid duplication in incremental

    AND sch.org_id = par.org_id
    AND par.set_of_books_id = sob.set_of_books_id
    AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date
  ) dlt
  on ( old.DISPUTE_HISTORY_ID = dlt.DISPUTE_HISTORY_ID )
  when matched then update set
    -- old.DISPUTE_HISTORY_ID = dlt.DISPUTE_HISTORY_ID,
    -- old.TIME_ID = dlt.TIME_ID,
    -- old.DISPUTE_AMOUNT_TRX = dlt.DISPUTE_AMOUNT_TRX,
    -- old.DISPUTE_AMOUNT_FUNC = dlt.DISPUTE_AMOUNT_FUNC,
    -- old.DISPUTE_AMOUNT_PRIM = dlt.DISPUTE_AMOUNT_PRIM,
    -- old.DISPUTE_AMOUNT_SEC = dlt.DISPUTE_AMOUNT_SEC,
    -- old.START_DATE = dlt.START_DATE,
    old.END_DATE = dlt.END_DATE,
    -- old.ORG_ID = dlt.ORG_ID,
    -- old.BILL_TO_CUSTOMER_ID = dlt.BILL_TO_CUSTOMER_ID,
    -- old.BILL_TO_SITE_USE_ID = dlt.BILL_TO_SITE_USE_ID,
    -- old.PAYMENT_SCHEDULE_ID = dlt.PAYMENT_SCHEDULE_ID,
    -- old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID,
    old.DUE_DATE = dlt.DUE_DATE,
    old.ACTUAL_DATE_CLOSED = dlt.ACTUAL_DATE_CLOSED,
    -- old.CREATION_DATE = dlt.CREATION_DATE,
    -- old.CREATED_BY = dlt.CREATED_BY,
    old.LAST_UPDATE_DATE = dlt.LAST_UPDATE_DATE,
    old.LAST_UPDATED_BY = dlt.LAST_UPDATED_BY,
    old.LAST_UPDATE_LOGIN = dlt.LAST_UPDATE_LOGIN
  when not matched then insert
  (
    DISPUTE_HISTORY_ID,
    TIME_ID,
    DISPUTE_AMOUNT_TRX,
    DISPUTE_AMOUNT_FUNC,
    DISPUTE_AMOUNT_PRIM,
    DISPUTE_AMOUNT_SEC,
    START_DATE,
    END_DATE,
    ORG_ID,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    PAYMENT_SCHEDULE_ID,
    CUSTOMER_TRX_ID,
    DUE_DATE,
    ACTUAL_DATE_CLOSED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    dlt.DISPUTE_HISTORY_ID,
    dlt.TIME_ID,
    dlt.DISPUTE_AMOUNT_TRX,
    dlt.DISPUTE_AMOUNT_FUNC,
    dlt.DISPUTE_AMOUNT_PRIM,
    dlt.DISPUTE_AMOUNT_SEC,
    dlt.START_DATE,
    dlt.END_DATE,
    dlt.ORG_ID,
    dlt.BILL_TO_CUSTOMER_ID,
    dlt.BILL_TO_SITE_USE_ID,
    dlt.PAYMENT_SCHEDULE_ID,
    dlt.CUSTOMER_TRX_ID,
    dlt.DUE_DATE,
    dlt.ACTUAL_DATE_CLOSED,
    dlt.CREATION_DATE,
    dlt.CREATED_BY,
    dlt.LAST_UPDATE_DATE,
    dlt.LAST_UPDATED_BY,
    dlt.LAST_UPDATE_LOGIN
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' ||SQL%ROWCOUNT|| ' records into FII_AR_DISPUTE_HISTORY_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_DISPUTE_HISTORY_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_DISPUTE_HISTORY_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_DISPUTES;


------------------------------------------------------------------
-- Procedure Inc_TRANSACTIONS
-- Purpose
--   This procedure manipulates records in FII_AR_TRANSACTIONS_F
------------------------------------------------------------------
PROCEDURE Inc_TRANSACTIONS IS
BEGIN

  /*
  g_state := 'Truncating table MLOG$_FII_AR_TRANSACTIONS_F';
  TRUNCATE_TABLE('MLOG$_FII_AR_TRANSACTIONS_F');
  g_state := 'Truncating table FII_AR_TRANSACTIONS_F';
  TRUNCATE_TABLE('FII_AR_TRANSACTIONS_F');
  */

  g_state := 'Deleting FII_AR_TRANSACTIONS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  delete from fii_ar_transactions_f
  where CUSTOMER_TRX_ID in (
      -- Trans Delete
      select CUSTOMER_TRX_ID
      from FII_AR_TRANS_DELETE_GT
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from FII_AR_TRANSACTIONS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Merging into FII_AR_TRANSACTIONS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  merge into fii_ar_transactions_f old using (
    -- POPULATE_TRANSACTIONS
    SELECT trx.customer_trx_id,
        trx.org_id,
        to_number(to_char(decode(g_collection_criteria,
                                 'GL', sch.gl_date,
                                 trx.trx_date), 'J')) time_id,
        trunc(trx.trx_date) trx_date,
        trunc(sch.gl_date) gl_date,
        sch.class, --class
        sum(nvl(sch.amount_due_original_trx,0))  AMOUNT_DUE_ORIGINAL_TRX,
        sum(nvl(sch.amount_due_original_func,0)) AMOUNT_DUE_ORIGINAL_FUNC,
        sum(nvl(sch.amount_due_original_prim,0)) AMOUNT_DUE_ORIGINAL_PRIM,
        sum(nvl(sch.amount_due_original_sec,0))  AMOUNT_DUE_ORIGINAL_SEC,
        NVL(trx.bill_to_customer_id, trx.drawee_id) BILL_TO_CUSTOMER_ID, -- drawee_id used for BR
        NVL(trx.bill_to_site_use_id,
            trx.drawee_site_use_id) BILL_TO_SITE_USE_ID, --drawee_site_use_id used for BR
        trx.trx_number TRANSACTION_NUMBER,
        trx.cust_trx_type_id,
        trx.term_id,
        trx.batch_source_id,
        decode(g_collection_criteria,'GL', sch.gl_date, trx.trx_date) filter_date,
        decode(trx.batch_source_id,
               -1, trx.ct_reference,
               null) order_ref_number, -- -1 indicates that the trx is a manual order entry
        trx.invoice_currency_code,
        nvl(trx.exchange_rate,1) exchange_rate,
        nvl(trx.exchange_date,trx.trx_date) exchange_date,
        trx.initial_customer_trx_id,
        trx.previous_customer_trx_id,
        trx.created_by user_id,
        trx.creation_date ar_creation_date,
        decode(sch.class,'INV',sum(nvl(sch.amount_due_original_func,0)),0) INV_ba_amount_func,
        decode(sch.class,'INV',sum(nvl(sch.amount_due_original_prim,0)),0) INV_ba_amount_prim,
        decode(sch.class,'INV',sum(nvl(sch.amount_due_original_sec,0)),0)  INV_ba_amount_sec,
        decode(sch.class,'INV',1,0) INV_ba_count,
        decode(sch.class,'DM',sum(nvl(sch.amount_due_original_func,0)),0)  DM_ba_amount_func,
        decode(sch.class,'DM',sum(nvl(sch.amount_due_original_prim,0)),0)  DM_ba_amount_prim,
        decode(sch.class,'DM',sum(nvl(sch.amount_due_original_sec,0)),0)   DM_ba_amount_sec,
        decode(sch.class,'DM',1,0) DM_ba_count,
        decode(sch.class,'CB',sum(nvl(sch.amount_due_original_func,0)),0)  CB_ba_amount_func,
        decode(sch.class,'CB',sum(nvl(sch.amount_due_original_prim,0)),0)  CB_ba_amount_prim,
        decode(sch.class,'CB',sum(nvl(sch.amount_due_original_sec,0)),0)   CB_ba_amount_sec,
        decode(sch.class,'CB',1,0) CB_ba_count,
        decode(sch.class,'BR',sum(nvl(sch.amount_due_original_func,0)),0)  BR_ba_amount_func,
        decode(sch.class,'BR',sum(nvl(sch.amount_due_original_prim,0)),0)  BR_ba_amount_prim,
        decode(sch.class,'BR',sum(nvl(sch.amount_due_original_sec,0)),0)   BR_ba_amount_sec,
        decode(sch.class,'BR',1,0) BR_ba_count,
        decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_func,0)),0) DEP_ba_amount_func,
        decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_prim,0)),0) DEP_ba_amount_prim,
        decode(sch.class,'DEP',sum(nvl(sch.amount_due_original_sec,0)),0)  DEP_ba_amount_sec,
        decode(sch.class,'DEP',1,0) DEP_ba_count,
        decode(sch.class,'CM',sum(nvl(sch.amount_due_original_func,0)),0)  CM_ba_amount_func,
        decode(sch.class,'CM',sum(nvl(sch.amount_due_original_prim,0)),0)  CM_ba_amount_prim,
        decode(sch.class,'CM',sum(nvl(sch.amount_due_original_sec,0)),0)   CM_ba_amount_sec,
        decode(sch.class,'CM',1,0) CM_ba_count,
        sysdate        CREATION_DATE,
        g_fii_user_id  CREATED_BY,
        sysdate        LAST_UPDATE_DATE,
        g_fii_user_id  LAST_UPDATED_BY,
        g_fii_login_id LAST_UPDATE_LOGIN
    FROM (
              select * from ra_customer_trx_all
              where CUSTOMER_TRX_ID in (
                  -- Trans Insert, Update
                  select CUSTOMER_TRX_ID
                  from FII_AR_PAYSCH_INSERT_GT
                  where CLASS <> 'PMT'
                  -- and decode(g_collection_criteria, 'GL', gl_date, trx_date) >= g_global_start_date
              )
         ) trx,
         -- FII_AR_PMT_SCHEDULES_F sch --> FII_AR_PAYSCH_MERGE_GT
         ( select
             NVL(ROUND(sch.amount_due_original * nvl(sch.exchange_rate,1) /
               rt.functional_mau) * rt.functional_mau,
               nvl(sch.amount_due_original,0)) amount_due_original_func,
             DECODE(sch.invoice_currency_code,
               g_prim_currency, nvl(sch.amount_due_original,0),
               ROUND((nvl(sch.amount_due_original,0) *
               nvl(sch.exchange_rate,1) *
               rt.prim_conversion_rate) / g_primary_mau) *
               g_primary_mau) amount_due_original_prim,
             DECODE(sch.invoice_currency_code,
               g_sec_currency, nvl(sch.amount_due_original,0),
               ROUND((nvl(sch.amount_due_original,0) *
               nvl(sch.exchange_rate,1) *
               rt.sec_conversion_rate) / g_secondary_mau) *
               g_secondary_mau) amount_due_original_sec,
             sch.amount_due_original amount_due_original_trx,
             class,
             customer_trx_id,
             gl_date
           from FII_AR_PAYSCH_MERGE_GT sch,
                FII_AR_CURR_RATES_T rt,
                AR_SYSTEM_PARAMETERS_ALL par,
                GL_SETS_OF_BOOKS sob
           WHERE sch.org_id = par.org_id
           AND par.set_of_books_id = sob.set_of_books_id
           AND sob.currency_code = rt.fc_code
           AND trunc(least(nvl(sch.exchange_date,sch.trx_date),sysdate)) = rt.conversion_date
         ) sch
    WHERE trx.customer_trx_id = sch.customer_trx_id
    AND sch.class <> 'PMT'
    AND decode(g_collection_criteria,
               'GL', sch.gl_date,
                trx.trx_date) >= g_global_start_date
    GROUP BY trx.customer_trx_id,
            trx.org_id,
            to_number(to_char(trx.trx_date, 'J')), --time_id,
            trx.trx_date,
            sch.gl_date,
            sch.class,
            NVL(trx.bill_to_customer_id, trx.drawee_id),
            NVL(trx.bill_to_site_use_id, trx.drawee_site_use_id),
            trx.trx_number,
            trx.cust_trx_type_id,
            trx.term_id,
            trx.trx_date, --filter_date
            trx.invoice_currency_code,
            trx.exchange_rate,
            trx.exchange_date,
            trx.batch_source_id,
            trx.ct_reference,
            trx.initial_customer_trx_id,
            trx.previous_customer_trx_id,
            trx.created_by,
            trx.creation_date
  ) dlt
  on ( old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID )
  when matched then update set
    -- old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID,
    -- old.ORG_ID = dlt.ORG_ID,
    -- old.TIME_ID = dlt.TIME_ID,
    -- old.TRX_DATE = dlt.TRX_DATE,
    -- old.GL_DATE = dlt.GL_DATE,
    -- old.CLASS = dlt.CLASS,
    old.AMOUNT_DUE_ORIGINAL_TRX = dlt.AMOUNT_DUE_ORIGINAL_TRX,
    old.AMOUNT_DUE_ORIGINAL_FUNC = dlt.AMOUNT_DUE_ORIGINAL_FUNC,
    old.AMOUNT_DUE_ORIGINAL_PRIM = dlt.AMOUNT_DUE_ORIGINAL_PRIM,
    old.AMOUNT_DUE_ORIGINAL_SEC = dlt.AMOUNT_DUE_ORIGINAL_SEC,
    -- old.BILL_TO_CUSTOMER_ID = dlt.BILL_TO_CUSTOMER_ID,
    -- old.BILL_TO_SITE_USE_ID = dlt.BILL_TO_SITE_USE_ID,
    -- old.TRANSACTION_NUMBER = dlt.TRANSACTION_NUMBER,
    -- old.CUST_TRX_TYPE_ID = dlt.CUST_TRX_TYPE_ID,
    -- old.TERM_ID = dlt.TERM_ID,
    -- old.BATCH_SOURCE_ID = dlt.BATCH_SOURCE_ID,
    -- old.FILTER_DATE = dlt.FILTER_DATE,
    old.ORDER_REF_NUMBER = dlt.ORDER_REF_NUMBER,
    -- old.INVOICE_CURRENCY_CODE = dlt.INVOICE_CURRENCY_CODE,
    -- old.EXCHANGE_RATE = dlt.EXCHANGE_RATE,
    -- old.EXCHANGE_DATE = dlt.EXCHANGE_DATE,
    old.INITIAL_CUSTOMER_TRX_ID = dlt.INITIAL_CUSTOMER_TRX_ID,
    -- old.PREVIOUS_CUSTOMER_TRX_ID = dlt.PREVIOUS_CUSTOMER_TRX_ID,
    -- old.USER_ID = dlt.USER_ID,
    -- old.AR_CREATION_DATE = dlt.AR_CREATION_DATE,
    old.INV_BA_AMOUNT_FUNC = dlt.INV_BA_AMOUNT_FUNC,
    old.INV_BA_AMOUNT_PRIM = dlt.INV_BA_AMOUNT_PRIM,
    old.INV_BA_AMOUNT_SEC = dlt.INV_BA_AMOUNT_SEC,
    -- old.INV_BA_COUNT = dlt.INV_BA_COUNT,
    old.DM_BA_AMOUNT_FUNC = dlt.DM_BA_AMOUNT_FUNC,
    old.DM_BA_AMOUNT_PRIM = dlt.DM_BA_AMOUNT_PRIM,
    old.DM_BA_AMOUNT_SEC = dlt.DM_BA_AMOUNT_SEC,
    -- old.DM_BA_COUNT = dlt.DM_BA_COUNT,
    old.CB_BA_AMOUNT_FUNC = dlt.CB_BA_AMOUNT_FUNC,
    old.CB_BA_AMOUNT_PRIM = dlt.CB_BA_AMOUNT_PRIM,
    old.CB_BA_AMOUNT_SEC = dlt.CB_BA_AMOUNT_SEC,
    -- old.CB_BA_COUNT = dlt.CB_BA_COUNT,
    old.BR_BA_AMOUNT_FUNC = dlt.BR_BA_AMOUNT_FUNC,
    old.BR_BA_AMOUNT_PRIM = dlt.BR_BA_AMOUNT_PRIM,
    old.BR_BA_AMOUNT_SEC = dlt.BR_BA_AMOUNT_SEC,
    -- old.BR_BA_COUNT = dlt.BR_BA_COUNT,
    old.DEP_BA_AMOUNT_FUNC = dlt.DEP_BA_AMOUNT_FUNC,
    old.DEP_BA_AMOUNT_PRIM = dlt.DEP_BA_AMOUNT_PRIM,
    old.DEP_BA_AMOUNT_SEC = dlt.DEP_BA_AMOUNT_SEC,
    -- old.DEP_BA_COUNT = dlt.DEP_BA_COUNT,
    old.CM_BA_AMOUNT_FUNC = dlt.CM_BA_AMOUNT_FUNC,
    old.CM_BA_AMOUNT_PRIM = dlt.CM_BA_AMOUNT_PRIM,
    old.CM_BA_AMOUNT_SEC = dlt.CM_BA_AMOUNT_SEC,
    -- old.CM_BA_COUNT = dlt.CM_BA_COUNT,
    -- old.CREATION_DATE = dlt.CREATION_DATE,
    -- old.CREATED_BY = dlt.CREATED_BY,
    old.LAST_UPDATE_DATE = dlt.LAST_UPDATE_DATE,
    old.LAST_UPDATED_BY = dlt.LAST_UPDATED_BY,
    old.LAST_UPDATE_LOGIN = dlt.LAST_UPDATE_LOGIN
  when not matched then insert
  (
    CUSTOMER_TRX_ID,
    ORG_ID,
    TIME_ID,
    TRX_DATE,
    GL_DATE,
    CLASS,
    AMOUNT_DUE_ORIGINAL_TRX,
    AMOUNT_DUE_ORIGINAL_FUNC,
    AMOUNT_DUE_ORIGINAL_PRIM,
    AMOUNT_DUE_ORIGINAL_SEC,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    TRANSACTION_NUMBER,
    CUST_TRX_TYPE_ID,
    TERM_ID,
    BATCH_SOURCE_ID,
    FILTER_DATE,
    ORDER_REF_NUMBER,
    INVOICE_CURRENCY_CODE,
    EXCHANGE_RATE,
    EXCHANGE_DATE,
    INITIAL_CUSTOMER_TRX_ID,
    PREVIOUS_CUSTOMER_TRX_ID,
    USER_ID,
    AR_CREATION_DATE,
    INV_BA_AMOUNT_FUNC,
    INV_BA_AMOUNT_PRIM,
    INV_BA_AMOUNT_SEC,
    INV_BA_COUNT,
    DM_BA_AMOUNT_FUNC,
    DM_BA_AMOUNT_PRIM,
    DM_BA_AMOUNT_SEC,
    DM_BA_COUNT,
    CB_BA_AMOUNT_FUNC,
    CB_BA_AMOUNT_PRIM,
    CB_BA_AMOUNT_SEC,
    CB_BA_COUNT,
    BR_BA_AMOUNT_FUNC,
    BR_BA_AMOUNT_PRIM,
    BR_BA_AMOUNT_SEC,
    BR_BA_COUNT,
    DEP_BA_AMOUNT_FUNC,
    DEP_BA_AMOUNT_PRIM,
    DEP_BA_AMOUNT_SEC,
    DEP_BA_COUNT,
    CM_BA_AMOUNT_FUNC,
    CM_BA_AMOUNT_PRIM,
    CM_BA_AMOUNT_SEC,
    CM_BA_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    dlt.CUSTOMER_TRX_ID,
    dlt.ORG_ID,
    dlt.TIME_ID,
    dlt.TRX_DATE,
    dlt.GL_DATE,
    dlt.CLASS,
    dlt.AMOUNT_DUE_ORIGINAL_TRX,
    dlt.AMOUNT_DUE_ORIGINAL_FUNC,
    dlt.AMOUNT_DUE_ORIGINAL_PRIM,
    dlt.AMOUNT_DUE_ORIGINAL_SEC,
    dlt.BILL_TO_CUSTOMER_ID,
    dlt.BILL_TO_SITE_USE_ID,
    dlt.TRANSACTION_NUMBER,
    dlt.CUST_TRX_TYPE_ID,
    dlt.TERM_ID,
    dlt.BATCH_SOURCE_ID,
    dlt.FILTER_DATE,
    dlt.ORDER_REF_NUMBER,
    dlt.INVOICE_CURRENCY_CODE,
    dlt.EXCHANGE_RATE,
    dlt.EXCHANGE_DATE,
    dlt.INITIAL_CUSTOMER_TRX_ID,
    dlt.PREVIOUS_CUSTOMER_TRX_ID,
    dlt.USER_ID,
    dlt.AR_CREATION_DATE,
    dlt.INV_BA_AMOUNT_FUNC,
    dlt.INV_BA_AMOUNT_PRIM,
    dlt.INV_BA_AMOUNT_SEC,
    dlt.INV_BA_COUNT,
    dlt.DM_BA_AMOUNT_FUNC,
    dlt.DM_BA_AMOUNT_PRIM,
    dlt.DM_BA_AMOUNT_SEC,
    dlt.DM_BA_COUNT,
    dlt.CB_BA_AMOUNT_FUNC,
    dlt.CB_BA_AMOUNT_PRIM,
    dlt.CB_BA_AMOUNT_SEC,
    dlt.CB_BA_COUNT,
    dlt.BR_BA_AMOUNT_FUNC,
    dlt.BR_BA_AMOUNT_PRIM,
    dlt.BR_BA_AMOUNT_SEC,
    dlt.BR_BA_COUNT,
    dlt.DEP_BA_AMOUNT_FUNC,
    dlt.DEP_BA_AMOUNT_PRIM,
    dlt.DEP_BA_AMOUNT_SEC,
    dlt.DEP_BA_COUNT,
    dlt.CM_BA_AMOUNT_FUNC,
    dlt.CM_BA_AMOUNT_PRIM,
    dlt.CM_BA_AMOUNT_SEC,
    dlt.CM_BA_COUNT,
    dlt.CREATION_DATE,
    dlt.CREATED_BY,
    dlt.LAST_UPDATE_DATE,
    dlt.LAST_UPDATED_BY,
    dlt.LAST_UPDATE_LOGIN
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' ||SQL%ROWCOUNT|| ' records into FII_AR_TRANSACTIONS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_TRANSACTIONS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_TRANSACTIONS_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_TRANSACTIONS;


------------------------------------------------------------------
-- Procedure Inc_ADJUSTMENTS
-- Purpose
--   This procedure manipulates records in FII_AR_ADJUSTMENTS_F
------------------------------------------------------------------
PROCEDURE Inc_ADJUSTMENTS IS
BEGIN

  /*
  g_state := 'Truncating table FII_AR_ADJUSTMENTS_F';
  TRUNCATE_TABLE('FII_AR_ADJUSTMENTS_F');
  */

  g_state := 'Merging into FII_AR_ADJUSTMENTS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  merge into fii_ar_adjustments_f old using (
/*  insert into fii_ar_adjustments_f
  (
    ADJUSTMENT_ID,
    TIME_ID,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    ORG_ID,
    AMOUNT_TRX,
    AMOUNT_FUNC,
    AMOUNT_PRIM,
    AMOUNT_SEC,
    APPLY_DATE,
    GL_DATE,
    FILTER_DATE,
    CUSTOMER_TRX_ID,
    PAYMENT_SCHEDULE_ID,
    USER_ID,
    AR_CREATION_DATE,
    ADJ_CLASS,
    SUBSEQUENT_TRX_ID,
    BR_CUSTOMER_TRX_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )*/
    -- POPULATE_ADJUSTMENTS
    SELECT adj.adjustment_id,
          to_number(to_char(decode(g_collection_criteria,
                                   'GL', adj.gl_date,
                                   adj.apply_date), 'J')) time_id,
          trx.bill_to_customer_id, -- drawee_id only in case of BR
          trx.bill_to_site_use_id, -- drawee_site_use_id only in case of BR
          adj.org_id,
          adj.amount AMOUNT_TRX,
          NVL(ROUND(adj.amount * trx.exchange_rate / rt.functional_mau)
                * rt.functional_mau, nvl(adj.amount,0)) amount_func,
          DECODE(trx.invoice_currency_code,
                g_prim_currency, nvl(adj.amount,0),
                ROUND((nvl(adj.amount,0) * trx.exchange_rate *
                    rt.prim_conversion_rate) / g_primary_mau) *
                    g_primary_mau) amount_prim,
          DECODE(trx.invoice_currency_code,
                g_sec_currency, nvl(adj.amount,0),
                ROUND((nvl(adj.amount,0) * trx.exchange_rate *
                    rt.sec_conversion_rate) / g_secondary_mau) *
                    g_secondary_mau) amount_sec,
          trunc(adj.apply_date) apply_date,
          trunc(adj.gl_date) gl_date,
          decode(g_collection_criteria,'GL',adj.gl_date,adj.apply_date) filter_date,
          adj.customer_trx_id,
          adj.payment_schedule_id,
          adj.created_by user_id,
          adj.creation_date ar_creation_date,
          decode(line.br_adjustment_id,
                 null, decode(adj.chargeback_customer_trx_id,
                              null, decode(adj.adjustment_type,'C','DEP',null),
                              'CB'),
                 'BR') adj_class,
          adj.subsequent_trx_id,
          line.customer_trx_id br_customer_trx_id,
          sysdate              CREATION_DATE,
          g_fii_user_id        CREATED_BY,
          sysdate              LAST_UPDATE_DATE,
          g_fii_user_id        LAST_UPDATED_BY,
          g_fii_login_id       LAST_UPDATE_LOGIN
    FROM /* (
              select * from FII_AR_ADJ_UPDATE_GT
              -- where last_update_date <= g_sysdate_time
         ) */
         FII_AR_ADJ_UPDATE_GT adj,
         FII_AR_TRANSACTIONS_F trx,
         FII_AR_TRANSACTIONS_F trx2, --makes sure the CM adj does not result from a GUAR
         RA_CUSTOMER_TRX_LINES_ALL line,
         FII_AR_CURR_RATES_T rt,
         AR_SYSTEM_PARAMETERS_ALL par,
         GL_SETS_OF_BOOKS sob
    WHERE adj.status = 'A'
    AND adj.customer_trx_id = trx.customer_trx_id
    /*AND adj.customer_trx_id = decode(trx.class,
                                     'CM', trx.previous_customer_trx_id,
                                     trx.customer_trx_id)
    AND decode (adj.subsequent_trx_id,
                null, -111, 0, -111,
                adj.subsequent_trx_id) = decode(trx.class,
                                                  'CM', trx.customer_trx_id,
                                                  -111) */
    AND nvl(trx.initial_customer_trx_id, trx.customer_trx_id) =
            trx2.customer_trx_id --makes sure the CM adj does not result from a GUAR
    AND adj.adjustment_id = line.br_adjustment_id (+)
    AND adj.last_update_date <= g_sysdate_time  --To avoid duplication in incremental

    AND trx.org_id = par.org_id
    AND par.set_of_books_id = sob.set_of_books_id
    AND sob.currency_code = rt.fc_code
    AND trunc(least(nvl(trx.exchange_date,trx.trx_date),sysdate)) = rt.conversion_date

  ) dlt
  on ( old.ADJUSTMENT_ID = dlt.ADJUSTMENT_ID )
  when matched then update set
    -- old.ADJUSTMENT_ID = dlt.ADJUSTMENT_ID,
    old.TIME_ID = dlt.TIME_ID,
    old.BILL_TO_CUSTOMER_ID = dlt.BILL_TO_CUSTOMER_ID,
    old.BILL_TO_SITE_USE_ID = dlt.BILL_TO_SITE_USE_ID,
    old.ORG_ID = dlt.ORG_ID,
    old.AMOUNT_TRX = dlt.AMOUNT_TRX,
    old.AMOUNT_FUNC = dlt.AMOUNT_FUNC,
    old.AMOUNT_PRIM = dlt.AMOUNT_PRIM,
    old.AMOUNT_SEC = dlt.AMOUNT_SEC,
    old.APPLY_DATE = dlt.APPLY_DATE,
     old.GL_DATE = dlt.GL_DATE,
     old.FILTER_DATE = dlt.FILTER_DATE,
     old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID,
     old.PAYMENT_SCHEDULE_ID = dlt.PAYMENT_SCHEDULE_ID,
     old.USER_ID = dlt.USER_ID,
    -- old.AR_CREATION_DATE = dlt.AR_CREATION_DATE,
     old.ADJ_CLASS = dlt.ADJ_CLASS,
     old.SUBSEQUENT_TRX_ID = dlt.SUBSEQUENT_TRX_ID,
     old.BR_CUSTOMER_TRX_ID = dlt.BR_CUSTOMER_TRX_ID,
    -- old.CREATION_DATE = dlt.CREATION_DATE,
    -- old.CREATED_BY = dlt.CREATED_BY,
    old.LAST_UPDATE_DATE = dlt.LAST_UPDATE_DATE,
    old.LAST_UPDATED_BY = dlt.LAST_UPDATED_BY,
    old.LAST_UPDATE_LOGIN = dlt.LAST_UPDATE_LOGIN
  when not matched then insert
  (
    ADJUSTMENT_ID,
    TIME_ID,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    ORG_ID,
    AMOUNT_TRX,
    AMOUNT_FUNC,
    AMOUNT_PRIM,
    AMOUNT_SEC,
    APPLY_DATE,
    GL_DATE,
    FILTER_DATE,
    CUSTOMER_TRX_ID,
    PAYMENT_SCHEDULE_ID,
    USER_ID,
    AR_CREATION_DATE,
    ADJ_CLASS,
    SUBSEQUENT_TRX_ID,
    BR_CUSTOMER_TRX_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    dlt.ADJUSTMENT_ID,
    dlt.TIME_ID,
    dlt.BILL_TO_CUSTOMER_ID,
    dlt.BILL_TO_SITE_USE_ID,
    dlt.ORG_ID,
    dlt.AMOUNT_TRX,
    dlt.AMOUNT_FUNC,
    dlt.AMOUNT_PRIM,
    dlt.AMOUNT_SEC,
    dlt.APPLY_DATE,
    dlt.GL_DATE,
    dlt.FILTER_DATE,
    dlt.CUSTOMER_TRX_ID,
    dlt.PAYMENT_SCHEDULE_ID,
    dlt.USER_ID,
    dlt.AR_CREATION_DATE,
    dlt.ADJ_CLASS,
    dlt.SUBSEQUENT_TRX_ID,
    dlt.BR_CUSTOMER_TRX_ID,
    dlt.CREATION_DATE,
    dlt.CREATED_BY,
    dlt.LAST_UPDATE_DATE,
    dlt.LAST_UPDATED_BY,
    dlt.LAST_UPDATE_LOGIN
  );


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' ||SQL%ROWCOUNT|| ' records into FII_AR_ADJUSTMENTS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_ADJUSTMENTS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_ADJUSTMENTS_F');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_ADJUSTMENTS;

------------------------------------------------------------------
-- Procedure Inc_RECEIPTS
-- Purpose
--   This procedure manipulates records in FII_AR_RECEIPTS_F
------------------------------------------------------------------
PROCEDURE Inc_RECEIPTS IS

l_max_rec_application_id NUMBER(15);

BEGIN

  /*
  g_state := 'Truncating table MLOG$_FII_AR_RECEIPTS_F';
  TRUNCATE_TABLE('MLOG$_FII_AR_RECEIPTS_F');
  g_state := 'Truncating table FII_AR_RECEIPTS_F';
  TRUNCATE_TABLE('FII_AR_RECEIPTS_F');
  */

  g_state := 'Populating FII_AR_RECAPP_MERGE_GT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  insert into FII_AR_RECAPP_MERGE_GT
  (
  receivable_application_id,
  time_id,
  cash_receipt_id,
  application_status,
  header_status,
  amount_applied_rct,
  amount_applied_trx,
  amount_applied_rct_func,
  amount_applied_trx_func,
  amount_applied_rct_prim,
  amount_applied_trx_prim,
  amount_applied_rct_sec,
  amount_applied_trx_sec,
  earned_discount_amount_trx,
  earned_discount_amount_func,
  earned_discount_amount_prim,
  earned_discount_amount_sec,
  unearned_discount_amount_trx,
  unearned_discount_amount_func,
  unearned_discount_amount_prim,
  unearned_discount_amount_sec,
  apply_date,
  gl_date,
  filter_date,
  header_filter_date,
  application_type,
  applied_payment_schedule_id,
  applied_customer_trx_id,
  customer_trx_id,
  payment_schedule_id,
  receipt_number,
  receipt_type,
  receipt_date,
  rct_actual_date_closed,
  receipt_method_id,
  currency_code,
  user_id,
  ar_creation_date,
  bill_to_customer_id,
  bill_to_site_use_id,
  collector_bill_to_customer_id,
  collector_bill_to_site_use_id,
  org_id,
  trx_date,
  due_date,
  cm_previous_customer_trx_id,
  total_receipt_count,
  creation_date,
  created_by,
  last_update_date,
  last_updated_by,
  last_update_login,
  trxsch_payment_schedule_id
  )
    -- POPULATE_RECEIPTS
    SELECT app.RECEIVABLE_APPLICATION_ID,
        to_number(to_char(decode(g_collection_criteria,
                                 'GL',app.app_gl_date,
                                 app.apply_date), 'J')) TIME_ID,
        rct.cash_receipt_id,
        decode(app.status,'ACTIVITY','APP',app.status) APPLICATION_STATUS,
        rct.status HEADER_STATUS,
        NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)) AMOUNT_APPLIED_RCT,
        NVL(app.AMOUNT_APPLIED,0) AMOUNT_APPLIED_TRX,
        app.acctd_amount_applied_from AMOUNT_APPLIED_RCT_FUNC,
        NVL(app.acctd_amount_applied_to,0) AMOUNT_APPLIED_TRX_FUNC,
        DECODE(rct.cash_receipt_id,
               null, 0,
               decode (rct.currency_code,
                       g_prim_currency, NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)),
                       ROUND((NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)) * nvl(rct.exchange_rate,1) *
                            nvl(rct.prim_conversion_rate,1)) / g_primary_mau) *
                            g_primary_mau)) AMOUNT_APPLIED_RCT_PRIM,
        DECODE(app.applied_payment_schedule_id,
               null, 0,
               decode (trxsch.invoice_currency_code,
                       g_prim_currency, nvl(app.AMOUNT_APPLIED,0),
                       ROUND((nvl(app.AMOUNT_APPLIED,0) * nvl(trxsch.exchange_rate,1) *
                        nvl(trxsch.prim_conversion_rate,0)) / g_primary_mau) *
                        g_primary_mau)) AMOUNT_APPLIED_TRX_PRIM,
        DECODE(rct.cash_receipt_id,
               null, 0,
               decode (rct.currency_code,
                       g_sec_currency, NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)),
                       ROUND((NVL(app.AMOUNT_APPLIED_FROM, nvl(app.AMOUNT_APPLIED,0)) * nvl(rct.exchange_rate,1) *
                            nvl(rct.sec_conversion_rate,1)) / g_secondary_mau) *
                            g_secondary_mau)) AMOUNT_APPLIED_RCT_SEC,
        DECODE(app.applied_payment_schedule_id,
               null, 0,
               decode (trxsch.invoice_currency_code,
                       g_sec_currency, nvl(app.AMOUNT_APPLIED,0),
                       ROUND((nvl(app.AMOUNT_APPLIED,0) * nvl(trxsch.exchange_rate,1) *
                            nvl(trxsch.sec_conversion_rate,0)) / g_secondary_mau) *
                            g_secondary_mau)) AMOUNT_APPLIED_TRX_SEC,
        nvl(app.EARNED_DISCOUNT_TAKEN,0) EARNED_DISCOUNT_amount_trx,
        NVL(app.acctd_earned_discount_taken,
                nvl(app.EARNED_DISCOUNT_TAKEN,0)) EARNED_DISCOUNT_AMOUNT_FUNC,
        DECODE(trxsch.invoice_currency_code,
            g_prim_currency, nvl(app.EARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.EARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.prim_conversion_rate,1)) / g_primary_mau) *
                g_primary_mau) EARNED_DISCOUNT_AMOUNT_PRIM,
        DECODE(trxsch.invoice_currency_code,
            g_sec_currency, nvl(app.EARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.EARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.sec_conversion_rate,1)) / g_secondary_mau) *
                g_secondary_mau) EARNED_DISCOUNT_AMOUNT_SEC,
        nvl(app.UNEARNED_DISCOUNT_TAKEN,0) UNEARNED_DISCOUNT_amount_trx,
        NVL(app.acctd_unearned_discount_taken,
            nvl(app.UNEARNED_DISCOUNT_TAKEN,0)) UNEARNED_DISCOUNT_AMOUNT_FUNC,
        DECODE(trxsch.invoice_currency_code,
            g_prim_currency, nvl(app.UNEARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.UNEARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.prim_conversion_rate,1)) / g_primary_mau) *
                g_primary_mau) UNEARNED_DISCOUNT_AMOUNT_PRIM,
        DECODE(trxsch.invoice_currency_code,
            g_sec_currency, nvl(app.UNEARNED_DISCOUNT_TAKEN,0),
            ROUND((nvl(app.UNEARNED_DISCOUNT_TAKEN,0) * nvl(trxsch.exchange_rate,1) *
                nvl(trxsch.sec_conversion_rate,1)) / g_secondary_mau) *
                g_secondary_mau) UNEARNED_DISCOUNT_AMOUNT_SEC,
        trunc(app.APPLY_DATE),
        trunc(app.RCT_GL_DATE),
        decode(g_collection_criteria,
               'GL',app.app_gl_date,
               app.apply_date) FILTER_DATE,
        per.start_date, --decode(g_collection_criteria,'GL',app.rct_gl_date,rct.receipt_date), --HEADER_FILTER_DATE,
        app.APPLICATION_TYPE,
        app.APPLIED_PAYMENT_SCHEDULE_ID,
        app.applied_customer_trx_id,
        app.CUSTOMER_TRX_ID,
        app.PAYMENT_SCHEDULE_ID,
        rct.RECEIPT_NUMBER,
        rct.RECEIPT_TYPE,
        trunc(rct.receipt_date),
        rctsch.actual_date_closed rct_actual_date_closed,
        rct.receipt_method_id,
        rct.CURRENCY_CODE,
        app.created_by USER_ID,
        app.creation_date ar_creation_date,
        decode(app.status,
               'UNID', -2,
               nvl(rctsch.bill_to_customer_id, -2)) bill_to_customer_id, --to avoid outer joins in MVs
        decode(app.status,
               'UNID', -2,
               nvl(rctsch.bill_to_site_use_id, -2)) bill_to_site_use_id,
	    case when trxsch.payment_schedule_id is null
				  or app.applied_payment_schedule_id < 0
				then nvl(rctsch.bill_to_customer_id,-2)
			 else nvl(trxsch.bill_to_customer_id,-2) end collector_bill_to_customer_id,
	    case when trxsch.payment_schedule_id is null
				  or app.applied_payment_schedule_id < 0
				then nvl(rctsch.bill_to_site_use_id,-2)
			 else nvl(trxsch.bill_to_site_use_id,-2) end COLLECTOR_BILL_TO_SITE_USE_ID,
        app.org_id,
        trxsch.trx_date,
        trxsch.due_date,
        rctsch.previous_customer_trx_id cm_previous_customer_trx_id,
        decode (app.receivable_application_id,
                MIN(app.receivable_application_id) over (partition by rct.cash_receipt_id), 1,
                MAX(app.receivable_application_id) over (partition by rct.cash_receipt_id),
                    case when rct.status = 'REV' or rct.status = 'NSF' or rct.status = 'STOP'
                    then -1 else 0 end,
                0) total_receipt_count,
        sysdate        CREATION_DATE,
        g_fii_user_id  CREATED_BY,
        sysdate        LAST_UPDATE_DATE,
        g_fii_user_id  LAST_UPDATED_BY,
        g_fii_login_id LAST_UPDATE_LOGIN,
        trxsch.payment_schedule_id trxsch_payment_schedule_id
    FROM (select RECEIVABLE_APPLICATION_ID,
                cash_receipt_id,
                case when gl_date >= g_global_start_date then
                        gl_date
                else g_global_start_date end app_gl_date,
				decode (application_type,
						'CM',gl_date,
						MIN(gl_date) over (partition by cash_receipt_id)) rct_gl_date, --to get the receipt creation gl_date instead of appl gl_date
                case when apply_date >= g_global_start_date then
                        apply_date
                else g_global_start_date end apply_date,
                status,
                AMOUNT_APPLIED_FROM,
                AMOUNT_APPLIED,
                acctd_amount_applied_from,
                acctd_amount_applied_to,
                applied_customer_trx_id,
                EARNED_DISCOUNT_TAKEN,
                acctd_earned_discount_taken,
                UNEARNED_DISCOUNT_TAKEN,
                acctd_unearned_discount_taken,
                APPLICATION_TYPE,
                applied_payment_schedule_id,
                CUSTOMER_TRX_ID,
                PAYMENT_SCHEDULE_ID,
                created_by,
                creation_date,
                org_id
          from FII_AR_RECAPP_INSERT_GT) app,
         FII_AR_PMT_SCHEDULES_F rctsch, --> FII_AR_PAYSCH_MERGE_GT
                                        --  previous_customer_trx_id needs
                                        --  a join to AR_PAYMENT_SCHEDULES_ALL
        (select rct.cash_receipt_id,
                rct.status,
                rct.currency_code,
                nvl(rct.exchange_rate,1) exchange_rate,
                rctrt.prim_conversion_rate,
                rctrt.sec_conversion_rate,
                rct.RECEIPT_NUMBER,
                rct.TYPE receipt_type,
                rct.receipt_date,
                rct.receipt_method_id
                --rct.pay_from_customer bill_to_customer_id,
                --NVL(rct.customer_site_use_id,
                --  -1) bill_to_site_use_id, --(-1 for UNAPP, UNID)
                --rct.customer_site_use_id
         from AR_CASH_RECEIPTS_ALL rct,
              FII_AR_CURR_RATES_T rctrt,
              AR_SYSTEM_PARAMETERS_ALL par,
              GL_SETS_OF_BOOKS sob
         where --rct.receipt_date >= g_global_start_date
             rct.org_id = par.org_id
         and par.set_of_books_id = sob.set_of_books_id
         and sob.currency_code = rctrt.fc_code
         and rctrt.conversion_date = trunc(least(nvl(rct.exchange_date,
                            rct.receipt_date),sysdate))) rct,

        (select trxsch.payment_schedule_id,
                trxsch.invoice_currency_code,
                trxsch.exchange_rate exchange_rate,
                trxrt.prim_conversion_rate,
                trxrt.sec_conversion_rate,
                trxsch.trx_date, --trx_date
                trxsch.due_date, --due_date
                trxsch.bill_to_customer_id,
                trxsch.bill_to_site_use_id
         from -- FII_AR_PMT_SCHEDULES_F trxsch, --> FII_AR_PAYSCH_MERGE_GT
              ( select
                  sch.customer_id bill_to_customer_id,
                  sch.customer_site_use_id bill_to_site_use_id,
                  due_date,
                  nvl(sch.exchange_rate,1) exchange_rate,
                  invoice_currency_code,
                  payment_schedule_id,
                  trx_date,
                  org_id,
                  nvl(sch.exchange_date, sch.trx_date) exchange_date
                from FII_AR_PAYSCH_MERGE_GT sch
              ) trxsch,
              FII_AR_CURR_RATES_T trxrt,
              AR_SYSTEM_PARAMETERS_ALL par,
              GL_SETS_OF_BOOKS sob
         where trxsch.org_id = par.org_id
         AND par.set_of_books_id = sob.set_of_books_id
         AND sob.currency_code = trxrt.fc_code
         AND trxrt.conversion_date = trunc(least(nvl(trxsch.exchange_date,
                            trxsch.trx_date),sysdate))) trxsch,

         gl_periods per,
         ar_system_parameters_all par,
         gl_sets_of_books sob

    WHERE app.payment_schedule_id = rctsch.payment_schedule_id
    AND rctsch.class in ('PMT', 'CM')
    AND app.application_type IN ('CASH','CM')
    --AND (app.status IN ('UNID','UNAPP','APP')
    --     or app.applied_payment_schedule_id IN (-1,-4,-7))
    AND app.cash_receipt_id = rct.cash_receipt_id (+)
    AND app.applied_payment_schedule_id = trxsch.payment_schedule_id (+)
    AND par.org_id = app.org_id
    AND sob.set_of_books_id = par.set_of_books_id
    AND per.period_set_name = sob.period_set_name
    AND per.period_type = sob.accounted_period_type
    AND decode(application_type,
               'CM', app.apply_date,
               decode(g_collection_criteria,
                      'GL',app.rct_gl_date,
                      rct.receipt_date)) between per.start_date and per.end_date
    AND per.adjustment_period_flag = 'N'
    /*
    AND (case when app.applied_payment_schedule_id is null
                   or app.applied_payment_schedule_id < 0
                then case when --rct.receipt_date >= g_global_start_date
                               decode(g_collection_criteria,
                                      'GL', rct_gl_date,
                                      rct.receipt_date)  >= g_global_start_date
                             then 1
                     else null end
              else trxsch.payment_schedule_id end) is not null
    */
    ;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AR_RECAPP_MERGE_GT');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Deleting FII_AR_RECEIPTS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  delete from fii_ar_receipts_f
  where RECEIVABLE_APPLICATION_ID in (
    select RECEIVABLE_APPLICATION_ID
    from FII_AR_RECAPP_MERGE_GT
    where (case when applied_payment_schedule_id is null
                  or applied_payment_schedule_id < 0
                then case when --receipt_date >= g_global_start_date
                               decode(g_collection_criteria,
                                      'GL', gl_date,
                                      receipt_date)  >= g_global_start_date
                             then 1
                     else null end
              else trxsch_payment_schedule_id end) is null
    union all
    select RECEIVABLE_APPLICATION_ID
    from FII_AR_RECAPP_DELETE_GT
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from FII_AR_RECEIPTS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Merging into FII_AR_RECEIPTS_F';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  merge into fii_ar_receipts_f old using (
    select
      RECEIVABLE_APPLICATION_ID,
      TIME_ID,
      CASH_RECEIPT_ID,
      APPLICATION_STATUS,
      HEADER_STATUS,
      AMOUNT_APPLIED_RCT,
      AMOUNT_APPLIED_TRX,
      AMOUNT_APPLIED_RCT_FUNC,
      AMOUNT_APPLIED_TRX_FUNC,
      AMOUNT_APPLIED_RCT_PRIM,
      AMOUNT_APPLIED_TRX_PRIM,
      AMOUNT_APPLIED_RCT_SEC,
      AMOUNT_APPLIED_TRX_SEC,
      EARNED_DISCOUNT_AMOUNT_TRX,
      EARNED_DISCOUNT_AMOUNT_FUNC,
      EARNED_DISCOUNT_AMOUNT_PRIM,
      EARNED_DISCOUNT_AMOUNT_SEC,
      UNEARNED_DISCOUNT_AMOUNT_TRX,
      UNEARNED_DISCOUNT_AMOUNT_FUNC,
      UNEARNED_DISCOUNT_AMOUNT_PRIM,
      UNEARNED_DISCOUNT_AMOUNT_SEC,
      APPLY_DATE,
      GL_DATE,
      FILTER_DATE,
      HEADER_FILTER_DATE,
      APPLICATION_TYPE,
      APPLIED_PAYMENT_SCHEDULE_ID,
      APPLIED_CUSTOMER_TRX_ID,
      CUSTOMER_TRX_ID,
      PAYMENT_SCHEDULE_ID,
      RECEIPT_NUMBER,
      RECEIPT_TYPE,
      RECEIPT_DATE,
      RCT_ACTUAL_DATE_CLOSED,
      RECEIPT_METHOD_ID,
      CURRENCY_CODE,
      USER_ID,
      AR_CREATION_DATE,
      BILL_TO_CUSTOMER_ID,
      BILL_TO_SITE_USE_ID,
      COLLECTOR_BILL_TO_CUSTOMER_ID,
      COLLECTOR_BILL_TO_SITE_USE_ID,
      ORG_ID,
      TRX_DATE,
      DUE_DATE,
      CM_PREVIOUS_CUSTOMER_TRX_ID,
      TOTAL_RECEIPT_COUNT,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    from FII_AR_RECAPP_MERGE_GT
/*    where (case when applied_payment_schedule_id is null
                  or applied_payment_schedule_id < 0
                then case when --receipt_date >= g_global_start_date
                               decode(g_collection_criteria,
                                      'GL', gl_date,
                                      receipt_date)  >= g_global_start_date
                             then 1
                     else null end
              else trxsch_payment_schedule_id end) is not null
*/
  ) dlt
  on ( old.RECEIVABLE_APPLICATION_ID = dlt.RECEIVABLE_APPLICATION_ID )
  when matched then update set
    -- old.RECEIVABLE_APPLICATION_ID = dlt.RECEIVABLE_APPLICATION_ID,
    -- old.TIME_ID = dlt.TIME_ID,
    -- old.CASH_RECEIPT_ID = dlt.CASH_RECEIPT_ID,
    -- old.APPLICATION_STATUS = dlt.APPLICATION_STATUS,
    old.HEADER_STATUS = dlt.HEADER_STATUS,
    -- old.AMOUNT_APPLIED_RCT = dlt.AMOUNT_APPLIED_RCT,
    -- old.AMOUNT_APPLIED_TRX = dlt.AMOUNT_APPLIED_TRX,
    -- old.AMOUNT_APPLIED_RCT_FUNC = dlt.AMOUNT_APPLIED_RCT_FUNC,
    -- old.AMOUNT_APPLIED_TRX_FUNC = dlt.AMOUNT_APPLIED_TRX_FUNC,
    -- old.AMOUNT_APPLIED_RCT_PRIM = dlt.AMOUNT_APPLIED_RCT_PRIM,
    -- old.AMOUNT_APPLIED_TRX_PRIM = dlt.AMOUNT_APPLIED_TRX_PRIM,
    -- old.AMOUNT_APPLIED_RCT_SEC = dlt.AMOUNT_APPLIED_RCT_SEC,
    -- old.AMOUNT_APPLIED_TRX_SEC = dlt.AMOUNT_APPLIED_TRX_SEC,
    -- old.EARNED_DISCOUNT_AMOUNT_TRX = dlt.EARNED_DISCOUNT_AMOUNT_TRX,
    -- old.EARNED_DISCOUNT_AMOUNT_FUNC = dlt.EARNED_DISCOUNT_AMOUNT_FUNC,
    -- old.EARNED_DISCOUNT_AMOUNT_PRIM = dlt.EARNED_DISCOUNT_AMOUNT_PRIM,
    -- old.EARNED_DISCOUNT_AMOUNT_SEC = dlt.EARNED_DISCOUNT_AMOUNT_SEC,
    -- old.UNEARNED_DISCOUNT_AMOUNT_TRX = dlt.UNEARNED_DISCOUNT_AMOUNT_TRX,
    -- old.UNEARNED_DISCOUNT_AMOUNT_FUNC = dlt.UNEARNED_DISCOUNT_AMOUNT_FUNC,
    -- old.UNEARNED_DISCOUNT_AMOUNT_PRIM = dlt.UNEARNED_DISCOUNT_AMOUNT_PRIM,
    -- old.UNEARNED_DISCOUNT_AMOUNT_SEC = dlt.UNEARNED_DISCOUNT_AMOUNT_SEC,
    -- old.APPLY_DATE = dlt.APPLY_DATE,
    -- old.GL_DATE = dlt.GL_DATE,
    -- old.FILTER_DATE = dlt.FILTER_DATE,
    -- old.HEADER_FILTER_DATE = dlt.HEADER_FILTER_DATE,
    -- old.APPLICATION_TYPE = dlt.APPLICATION_TYPE,
    -- old.APPLIED_PAYMENT_SCHEDULE_ID = dlt.APPLIED_PAYMENT_SCHEDULE_ID,
    -- old.APPLIED_CUSTOMER_TRX_ID = dlt.APPLIED_CUSTOMER_TRX_ID,
    -- old.CUSTOMER_TRX_ID = dlt.CUSTOMER_TRX_ID,
    -- old.PAYMENT_SCHEDULE_ID = dlt.PAYMENT_SCHEDULE_ID,
    -- old.RECEIPT_NUMBER = dlt.RECEIPT_NUMBER,
    -- old.RECEIPT_TYPE = dlt.RECEIPT_TYPE,
    -- old.RECEIPT_DATE = dlt.RECEIPT_DATE,
    old.RCT_ACTUAL_DATE_CLOSED = dlt.RCT_ACTUAL_DATE_CLOSED,
    -- old.RECEIPT_METHOD_ID = dlt.RECEIPT_METHOD_ID,
    -- old.CURRENCY_CODE = dlt.CURRENCY_CODE,
    -- old.USER_ID = dlt.USER_ID,
    -- old.AR_CREATION_DATE = dlt.AR_CREATION_DATE,
    old.BILL_TO_CUSTOMER_ID = dlt.BILL_TO_CUSTOMER_ID,
    old.BILL_TO_SITE_USE_ID = dlt.BILL_TO_SITE_USE_ID,
    old.COLLECTOR_BILL_TO_CUSTOMER_ID = dlt.COLLECTOR_BILL_TO_CUSTOMER_ID,
    old.COLLECTOR_BILL_TO_SITE_USE_ID = dlt.COLLECTOR_BILL_TO_SITE_USE_ID,
    -- old.ORG_ID = dlt.ORG_ID,
    -- old.TRX_DATE = dlt.TRX_DATE,
    old.DUE_DATE = dlt.DUE_DATE,
    -- old.CM_PREVIOUS_CUSTOMER_TRX_ID = dlt.CM_PREVIOUS_CUSTOMER_TRX_ID,
    -- old.TOTAL_RECEIPT_COUNT = dlt.TOTAL_RECEIPT_COUNT,
    -- old.CREATION_DATE = dlt.CREATION_DATE,
    -- old.CREATED_BY = dlt.CREATED_BY,
    old.LAST_UPDATE_DATE = dlt.LAST_UPDATE_DATE,
    old.LAST_UPDATED_BY = dlt.LAST_UPDATED_BY,
    old.LAST_UPDATE_LOGIN = dlt.LAST_UPDATE_LOGIN
  when not matched then insert
  (
    RECEIVABLE_APPLICATION_ID,
    TIME_ID,
    CASH_RECEIPT_ID,
    APPLICATION_STATUS,
    HEADER_STATUS,
    AMOUNT_APPLIED_RCT,
    AMOUNT_APPLIED_TRX,
    AMOUNT_APPLIED_RCT_FUNC,
    AMOUNT_APPLIED_TRX_FUNC,
    AMOUNT_APPLIED_RCT_PRIM,
    AMOUNT_APPLIED_TRX_PRIM,
    AMOUNT_APPLIED_RCT_SEC,
    AMOUNT_APPLIED_TRX_SEC,
    EARNED_DISCOUNT_AMOUNT_TRX,
    EARNED_DISCOUNT_AMOUNT_FUNC,
    EARNED_DISCOUNT_AMOUNT_PRIM,
    EARNED_DISCOUNT_AMOUNT_SEC,
    UNEARNED_DISCOUNT_AMOUNT_TRX,
    UNEARNED_DISCOUNT_AMOUNT_FUNC,
    UNEARNED_DISCOUNT_AMOUNT_PRIM,
    UNEARNED_DISCOUNT_AMOUNT_SEC,
    APPLY_DATE,
    GL_DATE,
    FILTER_DATE,
    HEADER_FILTER_DATE,
    APPLICATION_TYPE,
    APPLIED_PAYMENT_SCHEDULE_ID,
    APPLIED_CUSTOMER_TRX_ID,
    CUSTOMER_TRX_ID,
    PAYMENT_SCHEDULE_ID,
    RECEIPT_NUMBER,
    RECEIPT_TYPE,
    RECEIPT_DATE,
    RCT_ACTUAL_DATE_CLOSED,
    RECEIPT_METHOD_ID,
    CURRENCY_CODE,
    USER_ID,
    AR_CREATION_DATE,
    BILL_TO_CUSTOMER_ID,
    BILL_TO_SITE_USE_ID,
    COLLECTOR_BILL_TO_CUSTOMER_ID,
    COLLECTOR_BILL_TO_SITE_USE_ID,
    ORG_ID,
    TRX_DATE,
    DUE_DATE,
    CM_PREVIOUS_CUSTOMER_TRX_ID,
    TOTAL_RECEIPT_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    dlt.RECEIVABLE_APPLICATION_ID,
    dlt.TIME_ID,
    dlt.CASH_RECEIPT_ID,
    dlt.APPLICATION_STATUS,
    dlt.HEADER_STATUS,
    dlt.AMOUNT_APPLIED_RCT,
    dlt.AMOUNT_APPLIED_TRX,
    dlt.AMOUNT_APPLIED_RCT_FUNC,
    dlt.AMOUNT_APPLIED_TRX_FUNC,
    dlt.AMOUNT_APPLIED_RCT_PRIM,
    dlt.AMOUNT_APPLIED_TRX_PRIM,
    dlt.AMOUNT_APPLIED_RCT_SEC,
    dlt.AMOUNT_APPLIED_TRX_SEC,
    dlt.EARNED_DISCOUNT_AMOUNT_TRX,
    dlt.EARNED_DISCOUNT_AMOUNT_FUNC,
    dlt.EARNED_DISCOUNT_AMOUNT_PRIM,
    dlt.EARNED_DISCOUNT_AMOUNT_SEC,
    dlt.UNEARNED_DISCOUNT_AMOUNT_TRX,
    dlt.UNEARNED_DISCOUNT_AMOUNT_FUNC,
    dlt.UNEARNED_DISCOUNT_AMOUNT_PRIM,
    dlt.UNEARNED_DISCOUNT_AMOUNT_SEC,
    dlt.APPLY_DATE,
    dlt.GL_DATE,
    dlt.FILTER_DATE,
    dlt.HEADER_FILTER_DATE,
    dlt.APPLICATION_TYPE,
    dlt.APPLIED_PAYMENT_SCHEDULE_ID,
    dlt.APPLIED_CUSTOMER_TRX_ID,
    dlt.CUSTOMER_TRX_ID,
    dlt.PAYMENT_SCHEDULE_ID,
    dlt.RECEIPT_NUMBER,
    dlt.RECEIPT_TYPE,
    dlt.RECEIPT_DATE,
    dlt.RCT_ACTUAL_DATE_CLOSED,
    dlt.RECEIPT_METHOD_ID,
    dlt.CURRENCY_CODE,
    dlt.USER_ID,
    dlt.AR_CREATION_DATE,
    dlt.BILL_TO_CUSTOMER_ID,
    dlt.BILL_TO_SITE_USE_ID,
    dlt.COLLECTOR_BILL_TO_CUSTOMER_ID,
    dlt.COLLECTOR_BILL_TO_SITE_USE_ID,
    dlt.ORG_ID,
    dlt.TRX_DATE,
    dlt.DUE_DATE,
    dlt.CM_PREVIOUS_CUSTOMER_TRX_ID,
    dlt.TOTAL_RECEIPT_COUNT,
    dlt.CREATION_DATE,
    dlt.CREATED_BY,
    dlt.LAST_UPDATE_DATE,
    dlt.LAST_UPDATED_BY,
    dlt.LAST_UPDATE_LOGIN
  );

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' ||SQL%ROWCOUNT|| ' records into FII_AR_RECEIPTS_F');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing FII_AR_RECEIPTS_F table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AR_RECEIPTS_F');

  g_state := 'Logging maximum receivable_application_id into fii_change_log table';
  select nvl(max(receivable_application_id), -999)
  into l_max_rec_application_id
  from fii_ar_receipts_f;

  INSERT INTO fii_change_log
  (log_item, item_value, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
  (SELECT 'AR_MAX_RECEIVABLE_APPLICATION_ID',
        l_max_rec_application_id,
        sysdate,        --CREATION_DATE,
        g_fii_user_id,  --CREATED_BY,
        sysdate,        --LAST_UPDATE_DATE,
        g_fii_user_id,  --LAST_UPDATED_BY,
        g_fii_login_id  --LAST_UPDATE_LOGIN
   FROM DUAL
   WHERE NOT EXISTS
      (select 1 from fii_change_log
       where log_item = 'AR_MAX_RECEIVABLE_APPLICATION_ID'));

  IF (SQL%ROWCOUNT = 0) THEN
      UPDATE fii_change_log
      SET item_value = l_max_rec_application_id,
          last_update_date  = g_sysdate_time,
          last_update_login = g_fii_login_id,
          last_updated_by   = g_fii_user_id
      WHERE log_item = 'AR_MAX_RECEIVABLE_APPLICATION_ID';
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_RECEIPTS;


------------------------------------------------------------------
-- Procedure Inc_RECEIVABLES_AGING
-- Purpose
--   This procedure inserts records in fii_ar_aging_receivables
--   for incremental load
------------------------------------------------------------------
PROCEDURE Inc_RECEIVABLES_AGING IS
BEGIN

  g_state := 'Populating fii_ar_aging_receivables in incremental mode';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	--Remove 3
	INSERT INTO  fii_ar_aging_receivables
	 (time_id,
          time_id_date,
	  event_date,
	  next_aging_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id ,
	  customer_trx_id,
	  payment_schedule_id,
	  adjustment_id,
	  receivable_application_id,
	  appl_trx_date,
	  trx_date,
	  due_date,
	  current_bucket_1_amount_trx,
	  current_bucket_1_amount_func,
	  current_bucket_1_amount_prim,
	  current_bucket_1_amount_sec,
	  current_bucket_1_count,
	  current_bucket_2_amount_trx,
	  current_bucket_2_amount_func,
	  current_bucket_2_amount_prim,
	  current_bucket_2_amount_sec,
	  current_bucket_2_count,
	  current_bucket_3_amount_trx,
	  current_bucket_3_amount_func,
	  current_bucket_3_amount_prim,
	  current_bucket_3_amount_sec,
	  current_bucket_3_count,
	  past_due_bucket_1_amount_trx,
	  past_due_bucket_1_amount_func,
	  past_due_bucket_1_amount_prim,
	  past_due_bucket_1_amount_sec,
	  past_due_bucket_1_count,
	  past_due_bucket_2_amount_trx,
	  past_due_bucket_2_amount_func,
	  past_due_bucket_2_amount_prim,
	  past_due_bucket_2_amount_sec,
	  past_due_bucket_2_count,
	  past_due_bucket_3_amount_trx,
	  past_due_bucket_3_amount_func,
	  past_due_bucket_3_amount_prim,
	  past_due_bucket_3_amount_sec,
	  past_due_bucket_3_count,
	  past_due_bucket_4_amount_trx,
	  past_due_bucket_4_amount_func,
	  past_due_bucket_4_amount_prim,
	  past_due_bucket_4_amount_sec,
	  past_due_bucket_4_count,
	  past_due_bucket_5_amount_trx,
	  past_due_bucket_5_amount_func,
	  past_due_bucket_5_amount_prim,
	  past_due_bucket_5_amount_sec,
	  past_due_bucket_5_count,
	  past_due_bucket_6_amount_trx,
	  past_due_bucket_6_amount_func,
	  past_due_bucket_6_amount_prim,
	  past_due_bucket_6_amount_sec,
	  past_due_bucket_6_count,
	  past_due_bucket_7_amount_trx,
	  past_due_bucket_7_amount_func,
	  past_due_bucket_7_amount_prim,
	  past_due_bucket_7_amount_sec,
	  past_due_bucket_7_count,
	  current_open_count,
	  past_due_count,
	  total_open_count,
	  unaged_amount_trx,
	  unaged_amount_func,
	  unaged_amount_prim,
	  unaged_amount_sec,
 	  on_acct_credit_amount_trx,
	  on_acct_credit_amount_func,
	  on_acct_credit_amount_prim,
	  on_acct_credit_amount_sec,
	  class,
	  billing_activity_flag,
	  billed_amount_flag,
	  on_account_credit_flag,
	  unapplied_deposit_flag,
	  billing_activity_count,
	  action,
	  aging_flag,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
  SELECT time_id,
         time_id_date,
	      event_date,
	      next_aging_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      customer_trx_id,
	      payment_schedule_id,
	      adjustment_id,
	      receivable_application_id,
	      appl_trx_date,
		  trx_date,
	      due_date,
	      sum(current_bucket_1_amount_trx),
	      sum(current_bucket_1_amount_func),
	      sum(current_bucket_1_amount_prim),
	      sum(current_bucket_1_amount_sec),
	      sum(current_bucket_1_count),
	      sum(current_bucket_2_amount_trx),
	      sum(current_bucket_2_amount_func),
	      sum(current_bucket_2_amount_prim),
	      sum(current_bucket_2_amount_sec),
	      sum(current_bucket_2_count),
	      sum(current_bucket_3_amount_trx),
	      sum(current_bucket_3_amount_func),
	      sum(current_bucket_3_amount_prim),
	      sum(current_bucket_3_amount_sec),
	      sum(current_bucket_3_count),
	      sum(past_due_bucket_1_amount_trx),
	      sum(past_due_bucket_1_amount_func),
	      sum(past_due_bucket_1_amount_prim),
	      sum(past_due_bucket_1_amount_sec),
	      sum(past_due_bucket_1_count),
	      sum(past_due_bucket_2_amount_trx),
	      sum(past_due_bucket_2_amount_func),
	      sum(past_due_bucket_2_amount_prim),
	      sum(past_due_bucket_2_amount_sec),
	      sum(past_due_bucket_2_count),
	      sum(past_due_bucket_3_amount_trx),
	      sum(past_due_bucket_3_amount_func),
	      sum(past_due_bucket_3_amount_prim),
	      sum(past_due_bucket_3_amount_sec),
	      sum(past_due_bucket_3_count),
	      sum(past_due_bucket_4_amount_trx),
	      sum(past_due_bucket_4_amount_func),
	      sum(past_due_bucket_4_amount_prim),
	      sum(past_due_bucket_4_amount_sec),
	      sum(past_due_bucket_4_count),
	      sum(past_due_bucket_5_amount_trx),
	      sum(past_due_bucket_5_amount_func),
	      sum(past_due_bucket_5_amount_prim),
	      sum(past_due_bucket_5_amount_sec),
	      sum(past_due_bucket_5_count),
	      sum(past_due_bucket_6_amount_trx),
	      sum(past_due_bucket_6_amount_func),
	      sum(past_due_bucket_6_amount_prim),
	      sum(past_due_bucket_6_amount_sec),
	      sum(past_due_bucket_6_count),
	      sum(past_due_bucket_7_amount_trx),
	      sum(past_due_bucket_7_amount_func),
	      sum(past_due_bucket_7_amount_prim),
	      sum(past_due_bucket_7_amount_sec),
	      sum(past_due_bucket_7_count),
	      sum(current_open_count),
		  sum(past_due_count),
		  sum(total_open_count),
	      unaged_amount_trx,
	      unaged_amount_func,
	      unaged_amount_prim,
	      unaged_amount_sec,
 	  	on_acct_credit_amount_trx,
	  	on_acct_credit_amount_func,
	  	on_acct_credit_amount_prim,
	  	on_acct_credit_amount_sec,
	      class,
	      billing_activity_flag,
	      billed_amount_flag,
	      on_account_credit_flag,
	      unapplied_deposit_flag,
          sum(billing_activity_count),
          action,
		  aging_flag,
		  sysdate, --CREATION_DATE,
		  g_fii_user_id,       --CREATED_BY,
		  sysdate, --LAST_UPDATE_DATE,
		  g_fii_user_id,       --LAST_UPDATED_BY,
		  g_fii_login_id       --LAST_UPDATE_LOGIN
	FROM (
		SELECT time_id,
                       time_id_date,
		       next_aging_date,
		       bill_to_customer_id,
			   bill_to_site_use_id,
			   org_id,
			   customer_trx_id,
			   payment_schedule_id,
		       adjustment_id,
		       receivable_application_id,
			   appl_trx_date,
			   trx_date,
			   due_date,
		       event_date,
		       current_bucket_1_amount_trx,
		       current_bucket_1_amount_func,
		       current_bucket_1_amount_prim,
		       current_bucket_1_amount_sec,
		       (case when current_bucket_1_amount_func = current_bucket_1_amt_func_cum
							AND current_bucket_1_amount_func <> 0
		                then 1
		             when current_bucket_1_amt_func_cum = 0
		                    AND current_bucket_1_amount_func <>0
		                then -1
		             else 0 end) current_bucket_1_count,
		       current_bucket_2_amount_trx,
		       current_bucket_2_amount_func,
		       current_bucket_2_amount_prim,
		       current_bucket_2_amount_sec,
		       (case when current_bucket_2_amount_func = current_bucket_2_amt_func_cum
		                    AND current_bucket_2_amount_func <>0
		                then 1
		             when current_bucket_2_amt_func_cum = 0
		                    AND current_bucket_2_amount_func <>0
		                then -1
		             else 0 end) current_bucket_2_count,
		       current_bucket_3_amount_trx,
		       current_bucket_3_amount_func,
		       current_bucket_3_amount_prim,
		       current_bucket_3_amount_sec,
		       (case when current_bucket_3_amount_func = current_bucket_3_amt_func_cum
		                    AND current_bucket_3_amount_func <> 0
		                then 1
		             when current_bucket_3_amt_func_cum = 0
		                    AND current_bucket_3_amount_func <> 0
		                then -1
		             else 0 end) current_bucket_3_count,
		       past_due_bucket_1_amount_trx,
		       past_due_bucket_1_amount_func,
		       past_due_bucket_1_amount_prim,
		       past_due_bucket_1_amount_sec,
		       (case when past_due_bucket_1_amount_func = past_due_bucket_1_amt_func_cum
		                    AND past_due_bucket_1_amount_func <> 0
		                then 1
		             when past_due_bucket_1_amt_func_cum = 0
		                    AND past_due_bucket_1_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_1_count,
		       past_due_bucket_2_amount_trx,
		       past_due_bucket_2_amount_func,
		       past_due_bucket_2_amount_prim,
		       past_due_bucket_2_amount_sec,
		       (case when past_due_bucket_2_amount_func = past_due_bucket_2_amt_func_cum
		                    AND past_due_bucket_2_amount_func <> 0
		                then 1
		             when past_due_bucket_2_amt_func_cum = 0
		                    AND past_due_bucket_2_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_2_count,
		       past_due_bucket_3_amount_trx,
		       past_due_bucket_3_amount_func,
		       past_due_bucket_3_amount_prim,
		       past_due_bucket_3_amount_sec,
		       (case when past_due_bucket_3_amount_func = past_due_bucket_3_amt_func_cum
		                    AND past_due_bucket_3_amount_func <> 0
		                then 1
		             when past_due_bucket_3_amt_func_cum = 0
		                    AND past_due_bucket_3_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_3_count,
		       past_due_bucket_4_amount_trx,
		       past_due_bucket_4_amount_func,
		       past_due_bucket_4_amount_prim,
		       past_due_bucket_4_amount_sec,
		       (case when past_due_bucket_4_amount_func = past_due_bucket_4_amt_func_cum
		                    AND past_due_bucket_4_amount_func <> 0
		                then 1
		             when past_due_bucket_4_amt_func_cum = 0
		                    AND past_due_bucket_4_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_4_count,
		       past_due_bucket_5_amount_trx,
		       past_due_bucket_5_amount_func,
		       past_due_bucket_5_amount_prim,
		       past_due_bucket_5_amount_sec,
		       (case when past_due_bucket_5_amount_func = past_due_bucket_5_amt_func_cum
		                    AND past_due_bucket_5_amount_func <> 0
		                then 1
		             when past_due_bucket_5_amt_func_cum = 0
		                    AND past_due_bucket_5_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_5_count,
		       past_due_bucket_6_amount_trx,
		       past_due_bucket_6_amount_func,
		       past_due_bucket_6_amount_prim,
		       past_due_bucket_6_amount_sec,
		       (case when past_due_bucket_6_amount_func = past_due_bucket_6_amt_func_cum
		                    AND past_due_bucket_6_amount_func <> 0
		                then 1
		             when past_due_bucket_6_amt_func_cum = 0
		                    AND past_due_bucket_6_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_6_count,
		       past_due_bucket_7_amount_trx,
		       past_due_bucket_7_amount_func,
		       past_due_bucket_7_amount_prim,
		       past_due_bucket_7_amount_sec,
		       (case when past_due_bucket_7_amount_func = past_due_bucket_7_amt_func_cum
		                    AND past_due_bucket_7_amount_func <> 0
		                then 1
		             when past_due_bucket_7_amt_func_cum = 0
		                    AND past_due_bucket_7_amount_func <> 0
		                then -1
		             else 0 end) past_due_bucket_7_count,
			   (case when current_open_amount_func = current_open_amt_func_cum
					  and current_open_amount_func <> 0
				   		  then 1
			  	     when current_open_amt_func_cum = 0
					  and current_open_amount_func <> 0
						  then -1
			  	     else 0 end) current_open_count,
			   (case when past_due_amount_func = past_due_amt_func_cum
					  and past_due_amount_func <> 0
				   		  then 1
			  	     when past_due_amt_func_cum = 0
					  and past_due_amount_func <> 0
						  then -1
			  	     else 0 end) past_due_count,
			   (case when total_open_amount_func = total_open_amt_func_cum
					  and total_open_amount_func <> 0
				   		  then 1
			  	     when total_open_amt_func_cum = 0
					  and total_open_amount_func <>0
						  then -1
			  	     else 0 end) total_open_count,
		       unaged_amount_trx,
		       unaged_amount_func,
		       unaged_amount_prim,
		       unaged_amount_sec,
 	  		 on_acct_credit_amount_trx,
	  		 on_acct_credit_amount_func,
	  		 on_acct_credit_amount_prim,
	  		 on_acct_credit_amount_sec,
		       class,
		  	   billing_activity_flag,
		       billed_amount_flag,
		       on_account_credit_flag,
		 	   unapplied_deposit_flag,
			   (case when billing_activity_flag = 'Y'
						 and payment_schedule_id = min_payment_schedule_id
					   then 1
					 else 0 end) billing_activity_count,
		       action,
		       actual_date_closed,
		       aging_flag
	    FROM (
			SELECT time_id,
                               time_id_date,
			       next_aging_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
			       adjustment_id,
			       receivable_application_id,
				   appl_trx_date,
				   trx_date,
				   due_date,
			       event_date,
				   MIN(payment_schedule_id) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) min_payment_schedule_id,
			       current_bucket_1_amount_trx,
			       current_bucket_1_amount_func,
			       current_bucket_1_amount_prim,
			       current_bucket_1_amount_sec,
			       SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_1_amt_func_cum,
				   current_bucket_2_amount_trx,
			       current_bucket_2_amount_func,
			       current_bucket_2_amount_prim,
			       current_bucket_2_amount_sec,
			       SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_2_amt_func_cum,
			       current_bucket_3_amount_trx,
			       current_bucket_3_amount_func,
			       current_bucket_3_amount_prim,
			       current_bucket_3_amount_sec,
			       SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_bucket_3_amt_func_cum,
			       past_due_bucket_1_amount_trx,
			       past_due_bucket_1_amount_func,
			       past_due_bucket_1_amount_prim,
			       past_due_bucket_1_amount_sec,
			       SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_1_amt_func_cum,
			       past_due_bucket_2_amount_trx,
			       past_due_bucket_2_amount_func,
			       past_due_bucket_2_amount_prim,
			       past_due_bucket_2_amount_sec,
			       SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_2_amt_func_cum,
			       past_due_bucket_3_amount_trx,
			       past_due_bucket_3_amount_func,
			       past_due_bucket_3_amount_prim,
			       past_due_bucket_3_amount_sec,
			       SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_3_amt_func_cum,
			       past_due_bucket_4_amount_trx,
			       past_due_bucket_4_amount_func,
			       past_due_bucket_4_amount_prim,
			       past_due_bucket_4_amount_sec,
			       SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_4_amt_func_cum,
				   past_due_bucket_5_amount_trx,
			       past_due_bucket_5_amount_func,
			       past_due_bucket_5_amount_prim,
			       past_due_bucket_5_amount_sec,
			       SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_5_amt_func_cum,
			       past_due_bucket_6_amount_trx,
			       past_due_bucket_6_amount_func,
			       past_due_bucket_6_amount_prim,
			       past_due_bucket_6_amount_sec,
			       SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_6_amt_func_cum,
			       past_due_bucket_7_amount_trx,
			       past_due_bucket_7_amount_func,
			       past_due_bucket_7_amount_prim,
			       past_due_bucket_7_amount_sec,
			       SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_bucket_7_amt_func_cum,
				   (current_bucket_1_amount_func+current_bucket_2_amount_func
						+ current_bucket_3_amount_func) current_open_amount_func,
				   (SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) current_open_amt_func_cum,
				   (past_due_bucket_1_amount_func
						+ past_due_bucket_2_amount_func+past_due_bucket_3_amount_func
						+ past_due_bucket_4_amount_func+past_due_bucket_5_amount_func
						+ past_due_bucket_6_amount_func+past_due_bucket_7_amount_func) past_due_amount_func,
				   (SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
				   	 + SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) past_due_amt_func_cum,
				   (current_bucket_1_amount_func+current_bucket_2_amount_func
						+ current_bucket_3_amount_func+past_due_bucket_1_amount_func
						+ past_due_bucket_2_amount_func+past_due_bucket_3_amount_func
						+ past_due_bucket_4_amount_func+past_due_bucket_5_amount_func
						+ past_due_bucket_6_amount_func+past_due_bucket_7_amount_func) total_open_amount_func,
				   (SUM(current_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(current_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
			         + SUM(past_due_bucket_1_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_2_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_3_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_4_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_5_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(past_due_bucket_6_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
				   	 + SUM(past_due_bucket_7_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) total_open_amt_func_cum,
			       unaged_amount_trx,
			       unaged_amount_func,
			       unaged_amount_prim,
			       unaged_amount_sec,
 	 			 on_acct_credit_amount_trx,
	 			 on_acct_credit_amount_func,
	 			 on_acct_credit_amount_prim,
	 			 on_acct_credit_amount_sec,
			       class,
			  	   billing_activity_flag,
			       billed_amount_flag,
			       on_account_credit_flag,
			 	   unapplied_deposit_flag,
			       action,
			       actual_date_closed,
			       aging_flag
			FROM
			   (SELECT to_number(to_char(decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
													then gl_date
												  else decode(aging_flag, 'N', gl_date, event_date) end,
				                       event_date), 'J')) time_id,
                                   decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
								     then gl_date
                                                             else decode(aging_flag, 'N', gl_date, event_date) end,
				                       event_date) time_id_date,
			           next_aging_date,
			           bill_to_customer_id,
			    	   bill_to_site_use_id,
			    	   org_id,
			    	   customer_trx_id,
			    	   payment_schedule_id,
			           adjustment_id,
			           receivable_application_id,
			    	   appl_trx_date,
					   trx_date,
			    	   due_date,
			           event_date,
			           (case when marker=1
			                    then bucket_amount_trx
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_3_amount_trx,
			           (case when marker=1
			                    then bucket_amount_func
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_3_amount_func,
			           (case when marker=1
			                    then bucket_amount_prim
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_3_amount_prim,
			           (case when marker=1
			                    then bucket_amount_sec
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_3_amount_sec,
			            ----------------
			           (case when marker=2
			                    then bucket_amount_trx
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_2_amount_trx,
			           (case when marker=2
			                    then bucket_amount_func
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_2_amount_func,
			           (case when marker=2
			                    then bucket_amount_prim
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_2_amount_prim,
			           (case when marker=2
			                    then bucket_amount_sec
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_2_amount_sec,
			            ----------------
			           (case when marker=3
			                    then bucket_amount_trx
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) current_bucket_1_amount_trx,
			           (case when marker=3
			                    then bucket_amount_func
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) current_bucket_1_amount_func,
			           (case when marker=3
			                    then bucket_amount_prim
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) current_bucket_1_amount_prim,
			           (case when marker=3
			                    then bucket_amount_sec
			                 when marker=4 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) current_bucket_1_amount_sec,
			            ----------------
			           (case when marker=4
			                    then bucket_amount_trx
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_1_amount_trx,
			           (case when marker=4
			                    then bucket_amount_func
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_1_amount_func,
			           (case when marker=4
			                    then bucket_amount_prim
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_1_amount_prim,
			           (case when marker=4
			                    then bucket_amount_sec
			                 when marker=5 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_1_amount_sec,
			            ------------------
			           (case when marker=5
			                    then bucket_amount_trx
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_2_amount_trx,
			           (case when marker=5
			                    then bucket_amount_func
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_2_amount_func,
			           (case when marker=5
			                    then bucket_amount_prim
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_2_amount_prim,
			           (case when marker=5
			                    then bucket_amount_sec
			                 when marker=6 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_2_amount_sec,
			            ------------------
			           (case when marker=6
			                    then bucket_amount_trx
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_3_amount_trx,
			           (case when marker=6
			                    then bucket_amount_func
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_3_amount_func,
			           (case when marker=6
			                    then bucket_amount_prim
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_3_amount_prim,
			           (case when marker=6
			                    then bucket_amount_sec
			                 when marker=7 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_3_amount_sec,
			            ------------------
			           (case when marker=7
			                    then bucket_amount_trx
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_4_amount_trx,
			           (case when marker=7
			                    then bucket_amount_func
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_4_amount_func,
			           (case when marker=7
			                    then bucket_amount_prim
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_4_amount_prim,
			           (case when marker=7
			                    then bucket_amount_sec
			                 when marker=8 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_4_amount_sec,
			            ---------------
			           (case when marker=8
			                    then bucket_amount_trx
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_5_amount_trx,
			           (case when marker=8
			                    then bucket_amount_func
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_5_amount_func,
			           (case when marker=8
			                    then bucket_amount_prim
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_5_amount_prim,
			           (case when marker=8
			                    then bucket_amount_sec
			                 when marker=9 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_5_amount_sec,
			            ---------------
			           (case when marker=9
			                    then bucket_amount_trx
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_trx
			                 else 0 end) past_due_bucket_6_amount_trx,
			           (case when marker=9
			                    then bucket_amount_func
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) past_due_bucket_6_amount_func,
			           (case when marker=9
			                    then bucket_amount_prim
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) past_due_bucket_6_amount_prim,
			           (case when marker=9
			                    then bucket_amount_sec
			                 when marker=10 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) past_due_bucket_6_amount_sec,
			            ---------------
			           (case when marker=10
			                    then bucket_amount_trx
			                 else 0 end) past_due_bucket_7_amount_trx,
			           (case when marker=10
			                    then bucket_amount_func
			                 else 0 end) past_due_bucket_7_amount_func,
			           (case when marker=10
			                    then bucket_amount_prim
			                 else 0 end) past_due_bucket_7_amount_prim,
			           (case when marker=10
			                    then bucket_amount_sec
			                 else 0 end) past_due_bucket_7_amount_sec,
			            ---------------
			           decode(aging_flag,'N',unaged_amount_trx, 0)  unaged_amount_trx,
			           decode(aging_flag,'N',unaged_amount_func, 0) unaged_amount_func,
			           decode(aging_flag,'N',unaged_amount_prim, 0) unaged_amount_prim,
			           decode(aging_flag,'N',unaged_amount_sec, 0)  unaged_amount_sec,
			           decode(aging_flag,'N',on_acct_credit_amount_trx, 0)  on_acct_credit_amount_trx,
			           decode(aging_flag,'N',on_acct_credit_amount_func, 0) on_acct_credit_amount_func,
			           decode(aging_flag,'N',on_acct_credit_amount_prim, 0) on_acct_credit_amount_prim,
			           decode(aging_flag,'N',on_acct_credit_amount_sec, 0)  on_acct_credit_amount_sec,
			           class,
			           decode(aging_flag,'N',billing_activity_flag, 'N') billing_activity_flag,
			           decode(aging_flag,'N',billed_amount_flag, 'N') billed_amount_flag,
			           null on_account_credit_flag,
			           decode(aging_flag,'N',unapplied_deposit_flag, 'N') unapplied_deposit_flag,
			           action,
			           actual_date_closed,
			           aging_flag
			    FROM
			       (SELECT m.marker,
			               v.bill_to_customer_id,
			        	   v.bill_to_site_use_id,
			        	   v.org_id,
			        	   v.customer_trx_id,
			        	   v.payment_schedule_id,
			               v.adjustment_id,
			               v.receivable_application_id,
			        	   v.appl_trx_date,
			        	   v.due_date,
						   v.trx_date,
						   v.gl_date,
			               v.bucket_amount_trx,
			               v.bucket_amount_func,
			               v.bucket_amount_prim,
			               v.bucket_amount_sec,
			               v.unaged_amount_trx,
			               v.unaged_amount_func,
			               v.unaged_amount_prim,
			               v.unaged_amount_sec,
 	  				   v.on_acct_credit_amount_trx,
	 				   v.on_acct_credit_amount_func,
	 				   v.on_acct_credit_amount_prim,
	 				   v.on_acct_credit_amount_sec,
			               v.class,
			          	   v.billing_activity_flag,
			    	       v.billed_amount_flag,
			               v.on_account_credit_flag,
			         	   v.unapplied_deposit_flag,
			               v.action,
			               v.actual_date_closed,
			               decode(m.marker,
			                      1, case when trunc(v.appl_trx_date)<=trunc(v.due_date)-g_current_bucket_3_low
			                                then appl_trx_date
			                              else null end,
			                      2, case when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_2_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.due_date)-g_current_bucket_2_high <= g_sysdate
			                                then trunc(v.due_date)-g_current_bucket_2_high
			                              when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.appl_trx_date) <= trunc(v.due_date)-g_current_bucket_2_low
			                                then v.appl_trx_date
			                              when g_current_bucket_2_high is null
												and trunc(v.appl_trx_date) <= trunc(v.due_date)-g_current_bucket_2_low
			                                then v.appl_trx_date
			                              else null end,
			                      3, case when g_current_bucket_1_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_1_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.due_date)-g_current_bucket_1_high <= g_sysdate
			                                then trunc(v.due_date)-g_current_bucket_1_high
			                              when g_current_bucket_1_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.appl_trx_date) <= trunc(v.due_date) - g_current_bucket_1_low
			                                then v.appl_trx_date
			                              when g_current_bucket_1_high is null
												and trunc(v.appl_trx_date) <= trunc(v.due_date) - g_current_bucket_1_low
			                                then v.appl_trx_date
			                              else null end,
			                      4, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_1_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_1_low
												and trunc(v.due_date)+g_past_due_bucket_1_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_1_low
			                              when g_past_due_bucket_1_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_1_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_1_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_1_high is null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_1_low
			                                then v.appl_trx_date
			                              else null end,
			                      5, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_2_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_2_low
												and trunc(v.due_date)+g_past_due_bucket_2_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_2_low
			                              when g_past_due_bucket_2_high is not null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_2_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_2_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_2_high is null
											    and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_2_low
			                                then v.appl_trx_date
			                              else null end,
			                      6, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_3_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_3_low
												and trunc(v.due_date)+g_past_due_bucket_3_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_3_low
			                              when g_past_due_bucket_3_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_3_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_3_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_3_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_3_low
			                                then v.appl_trx_date
			                              else null end,
			                      7, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_4_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_4_low
												and trunc(v.due_date)+g_past_due_bucket_4_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_4_low
			                              when g_past_due_bucket_4_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_4_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_4_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_4_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_4_low
			                                then v.appl_trx_date
			                              else null end,
			                      8, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_5_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_5_low
												and trunc(v.due_date)+g_past_due_bucket_5_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_5_low
			                              when g_past_due_bucket_5_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_5_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_5_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_5_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_5_low
			                                then v.appl_trx_date
			                              else null end,
			                      9, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_6_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_6_low
												and trunc(v.due_date)+g_past_due_bucket_6_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_6_low
			                              when g_past_due_bucket_6_high is not null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_6_low
			                                    and trunc(v.appl_trx_date)<=trunc(v.due_date)+ g_past_due_bucket_6_high
			                                then v.appl_trx_date
			                              when g_past_due_bucket_6_high is null
												and trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_6_low
			                                then v.appl_trx_date
			                              else null end,
			                      10, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_7_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_7_low
												and trunc(v.due_date)+g_past_due_bucket_7_low <= g_sysdate
			                                then trunc(v.due_date) + g_past_due_bucket_7_low
			                              when trunc(v.appl_trx_date) >= trunc(v.due_date) + g_past_due_bucket_7_low
			                                then v.appl_trx_date
			                              else null end) event_date,
						   decode(m.marker,
			                      1, case when actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
											then trunc(v.due_date)-g_current_bucket_2_high
										  else null end,
			                      2, case when actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
											then trunc(v.due_date)-g_current_bucket_1_high
										  else null end,
			                      3, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_1_low
											then trunc(v.due_date)+g_past_due_bucket_1_low
										  else null end,
			                      4, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_2_low
											then trunc(v.due_date)+g_past_due_bucket_2_low
										  else null end,
			                      5, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_3_low
											then trunc(v.due_date)+g_past_due_bucket_3_low
										  else null end,
			                      6, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_4_low
											then trunc(v.due_date)+g_past_due_bucket_4_low
										  else null end,
			                      7, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_5_low
											then trunc(v.due_date)+g_past_due_bucket_5_low
										  else null end,
			                      8, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_6_low
											then trunc(v.due_date)+g_past_due_bucket_6_low
										  else null end,
			                      9, case when actual_date_closed >= trunc(v.due_date)+g_past_due_bucket_7_low
											then trunc(v.due_date)+g_past_due_bucket_7_low
										  else null end,
			                      10, null) next_aging_date,
			               decode(m.marker,
			                      1, 'N',
			                      2, case when g_current_bucket_2_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_2_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_2_high
												and trunc(v.due_date)-g_current_bucket_2_high <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      3, case when g_current_bucket_1_high is not null
												and trunc(v.appl_trx_date) < trunc(v.due_date)-g_current_bucket_1_high
												and actual_date_closed >= trunc(v.due_date)-g_current_bucket_1_high
												and trunc(v.due_date)-g_current_bucket_1_high <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      4, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_1_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_1_low
												and trunc(v.due_date)+g_past_due_bucket_1_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      5, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_2_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_2_low
												and trunc(v.due_date)+g_past_due_bucket_2_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      6, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_3_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_3_low
												and trunc(v.due_date)+g_past_due_bucket_3_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      7, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_4_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_4_low
												and trunc(v.due_date)+g_past_due_bucket_4_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      8, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_5_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_5_low
												and trunc(v.due_date)+g_past_due_bucket_5_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      9, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_6_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_6_low
												and trunc(v.due_date)+g_past_due_bucket_6_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end,
			                      10, case when trunc(v.appl_trx_date) < trunc(v.due_date) + g_past_due_bucket_7_low
												and actual_date_closed >= trunc(v.due_date) + g_past_due_bucket_7_low
												and trunc(v.due_date)+g_past_due_bucket_7_low <= g_sysdate
			                                then 'Y'
			                               else 'N' end) aging_flag
			        FROM (--Payment Schedules
			              select sch.bill_to_customer_id,
			            		 sch.bill_to_site_use_id,
			            		 sch.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     null adjustment_id,
			                     null receivable_application_id,
			            		 sch.trx_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 sch.gl_date,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_trx) bucket_amount_trx,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_func) bucket_amount_func,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_prim) bucket_amount_prim,
			                     decode(sch.class,
										'CM',0,
										sch.amount_due_original_sec) bucket_amount_sec,
					             sch.amount_due_original_trx unaged_amount_trx,
					             sch.amount_due_original_func unaged_amount_func,
					             sch.amount_due_original_prim unaged_amount_prim,
					             sch.amount_due_original_sec unaged_amount_sec,
							 decode (sch.class, 'CM', sch.amount_due_original_trx, 0) on_acct_credit_amount_trx,
							 decode (sch.class, 'CM', sch.amount_due_original_func, 0) on_acct_credit_amount_func,
							 decode (sch.class, 'CM', sch.amount_due_original_prim, 0) on_acct_credit_amount_prim,
							 decode (sch.class, 'CM', sch.amount_due_original_sec, 0) on_acct_credit_amount_sec,
					             sch.class,
			              		 'Y' billing_activity_flag,
                                                 case when sch.class not in ('CB', 'BR')
                                                        and dso.dso_value = 'Y' then
                                                          'Y'
                                                 else 'N' end billed_amount_flag,
				                 null on_account_credit_flag,
			             	     decode(sch.class,'DEP','Y','N') unapplied_deposit_flag,
			                     'Transaction' action,
			                     sch.actual_date_closed
			              from fii_ar_pmt_schedules_f sch,
							   fii_ar_dso_setup dso,
        					   fii_ar_paysch_merge_gt gt
		      		      where sch.class <> 'PMT'
				          and dso.dso_group='TC'
				          and dso.dso_type = sch.class
                          and sch.customer_trx_id = gt.customer_trx_id

			              union all

			              --Applications
			              select rct.collector_bill_to_customer_id,
			            		 rct.collector_bill_to_site_use_id,
			            		 rct.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     null adjustment_id,
			                     rct.receivable_application_id,
			            		 rct.apply_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 decode(g_collection_criteria,
				                        'GL', rct.filter_date,
										null) gl_date,
			                     -1*(rct.amount_applied_trx
								   +nvl(rct.earned_discount_amount_trx,0)
			                       +nvl(rct.unearned_discount_amount_trx,0)) bucket_amount_trx,
			                     -1*(rct.amount_applied_trx_func
								   +nvl(rct.earned_discount_amount_func,0)
			                       +nvl(rct.unearned_discount_amount_func,0)) bucket_amount_func,
			                     -1*(rct.amount_applied_trx_prim
								   +nvl(rct.earned_discount_amount_prim,0)
			                       +nvl(rct.unearned_discount_amount_prim,0)) bucket_amount_prim,
			                     -1*(rct.amount_applied_trx_sec
								   +nvl(rct.earned_discount_amount_sec,0)
			                       +nvl(rct.unearned_discount_amount_sec,0)) bucket_amount_sec,
					            -1*rct.amount_applied_trx unaged_amount_trx,
							-1*rct.amount_applied_trx_func unaged_amount_func,
							-1*rct.amount_applied_trx_prim unaged_amount_prim,
							-1*rct.amount_applied_trx_sec unaged_amount_sec,
						    --Added for bug 6053566
				            	case when rct.application_type = 'CASH' and sch.class = 'CM'
								then rct.amount_applied_trx
							     when rct.application_type = 'CM'
								then -1*rct.amount_applied_rct
							     else 0 end on_acct_credit_amount_trx,
							case when rct.application_type = 'CASH' and sch.class = 'CM'
								then rct.amount_applied_trx_func
						 	     when rct.application_type = 'CM'
								then -1*rct.amount_applied_rct_func
							     else 0 end on_acct_credit_amount_func,
							case when rct.application_type = 'CASH' and sch.class = 'CM'
								then rct.amount_applied_trx_prim
							     when rct.application_type = 'CM'
								then -1*rct.amount_applied_rct_prim
							     else 0 end on_acct_credit_amount_prim,
							case when rct.application_type = 'CASH' and sch.class = 'CM'
								then rct.amount_applied_trx_sec
							     when rct.application_type = 'CM'
								then -1*rct.amount_applied_rct_sec
							     else 0 end on_acct_credit_amount_sec,
					             sch.class,
			              		 'N' billing_activity_flag,
			    		         'N' billed_amount_flag,
				                 null on_account_credit_flag,
				                 case when rct.application_type = 'CM' and sch.class='DEP'
										and rct.cm_previous_customer_trx_id is not null
									  then 'Y'
									  else 'N' end  unapplied_deposit_flag,
			                     'Application' action,
			                     sch.actual_date_closed
			              from fii_ar_receipts_f rct,
			                   fii_ar_pmt_schedules_f sch,
    					       FII_AR_PAYSCH_MERGE_GT gt
			              where rct.application_status = 'APP'
				          and sch.class <> 'PMT'
				          and rct.applied_payment_schedule_id = sch.payment_schedule_id
            	          and rct.applied_customer_trx_id = gt.customer_trx_id

			              union all

			              --Adjustments
			              select adj.bill_to_customer_id,
			            		 adj.bill_to_site_use_id,
			            		 adj.org_id,
			            		 sch.customer_trx_id,
			            		 sch.payment_schedule_id,
			                     adj.adjustment_id,
			                     null receivable_application_id,
			            		 adj.apply_date appl_trx_date,
								 sch.trx_date,
			            		 sch.due_date,
								 adj.gl_date,
			                     adj.amount_trx  bucket_amount_trx,
			                     adj.amount_func bucket_amount_func,
			                     adj.amount_prim bucket_amount_prim,
			                     adj.amount_sec  bucket_amount_sec,
					             adj.amount_trx  unaged_amount_trx,
					             adj.amount_func unaged_amount_func,
					             adj.amount_prim unaged_amount_prim,
					             adj.amount_sec  unaged_amount_sec,
							 0 on_acct_credit_amount_trx,
							 0 on_acct_credit_amount_func,
							 0 on_acct_credit_amount_prim,
							 0 on_acct_credit_amount_sec,
					             sch.class,
			              		 'N' billing_activity_flag,
                                                 case when sch.class not in ('CB', 'BR')
                                                        and (adj.adj_class not in ('CB', 'BR') or adj.adj_class is not null)
                                                        and schdso.dso_value = 'Y'
                                                        and (adjdso.dso_value is null or adjdso.dso_value = 'Y')
                                                       then 'Y'
                                                      else 'N' end  billed_amount_flag,
				                 null on_account_credit_flag,
								 decode(adj.adj_class,'DEP','Y','N') unapplied_deposit_flag,
			                     'Adjustment' action,
			                     sch.actual_date_closed
			              from fii_ar_adjustments_f adj,
			                   fii_ar_pmt_schedules_f sch,
							   fii_ar_dso_setup schdso,
							   fii_ar_dso_setup adjdso,
                               FII_AR_PAYSCH_MERGE_GT gt
				          where adj.payment_schedule_id = sch.payment_schedule_id
				          and sch.class <> 'PMT'
				          and schdso.dso_group='TC'
				          and schdso.dso_type = sch.class
				          and nvl(adjdso.dso_group,'TC')='TC'
				          and adj.adj_class = adjdso.dso_type (+)
                          and adj.customer_trx_id = gt.customer_trx_id) v,
			             (SELECT 1 marker FROM DUAL WHERE g_current_bucket_3_low is not null UNION ALL
			              SELECT 2 marker FROM DUAL WHERE g_current_bucket_2_low is not null UNION ALL
			              SELECT 3 marker FROM DUAL UNION ALL
			              SELECT 4 marker FROM DUAL UNION ALL
			              SELECT 5 marker FROM DUAL WHERE g_past_due_bucket_2_low is not null UNION ALL
			              SELECT 6 marker FROM DUAL WHERE g_past_due_bucket_3_low is not null UNION ALL
			              SELECT 7 marker FROM DUAL WHERE g_past_due_bucket_4_low is not null UNION ALL
			              SELECT 8 marker FROM DUAL WHERE g_past_due_bucket_5_low is not null UNION ALL
			              SELECT 9 marker FROM DUAL WHERE g_past_due_bucket_6_low is not null UNION ALL
			              SELECT 10 marker FROM DUAL WHERE g_past_due_bucket_7_low is not null) m)
			    WHERE event_date is not null)
			GROUP BY time_id,
                               time_id_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
			       adjustment_id,
			       receivable_application_id,
				   appl_trx_date,
				   trx_date,
				   due_date,
			       event_date,
			       current_bucket_1_amount_trx,
			       current_bucket_1_amount_func,
			       current_bucket_1_amount_prim,
			       current_bucket_1_amount_sec,
			       current_bucket_2_amount_trx,
			       current_bucket_2_amount_func,
			       current_bucket_2_amount_prim,
			       current_bucket_2_amount_sec,
			       current_bucket_3_amount_trx,
			       current_bucket_3_amount_func,
			       current_bucket_3_amount_prim,
			       current_bucket_3_amount_sec,
			       past_due_bucket_1_amount_trx,
			       past_due_bucket_1_amount_func,
			       past_due_bucket_1_amount_prim,
			       past_due_bucket_1_amount_sec,
			       past_due_bucket_2_amount_trx,
			       past_due_bucket_2_amount_func,
			       past_due_bucket_2_amount_prim,
			       past_due_bucket_2_amount_sec,
			       past_due_bucket_3_amount_trx,
			       past_due_bucket_3_amount_func,
			       past_due_bucket_3_amount_prim,
			       past_due_bucket_3_amount_sec,
			       past_due_bucket_4_amount_trx,
			       past_due_bucket_4_amount_func,
			       past_due_bucket_4_amount_prim,
			       past_due_bucket_4_amount_sec,
			       past_due_bucket_5_amount_trx,
			       past_due_bucket_5_amount_func,
			       past_due_bucket_5_amount_prim,
			       past_due_bucket_5_amount_sec,
			       past_due_bucket_6_amount_trx,
			       past_due_bucket_6_amount_func,
			       past_due_bucket_6_amount_prim,
			       past_due_bucket_6_amount_sec,
			       past_due_bucket_7_amount_trx,
			       past_due_bucket_7_amount_func,
			       past_due_bucket_7_amount_prim,
			       past_due_bucket_7_amount_sec,
				   next_aging_date,
			       unaged_amount_trx,
			       unaged_amount_func,
			       unaged_amount_prim,
			       unaged_amount_sec,
				 on_acct_credit_amount_trx,
	 			 on_acct_credit_amount_func,
	 			 on_acct_credit_amount_prim,
	 			 on_acct_credit_amount_sec,
			       class,
			  	   billing_activity_flag,
			       billed_amount_flag,
			       on_account_credit_flag,
			 	   unapplied_deposit_flag,
			       action,
			       actual_date_closed,
			       aging_flag
			)
		)  inc_ag
	WHERE NOT EXISTS
		  (SELECT 1
		   FROM  fii_ar_aging_receivables ag
		   WHERE ag.time_id = inc_ag.time_id
		   AND ag.customer_trx_id = inc_ag.customer_trx_id
		   AND ag.payment_schedule_id = inc_ag.payment_schedule_id
		   AND nvl(ag.adjustment_id,-1) = nvl(inc_ag.adjustment_id,-1)
		   AND nvl(ag.receivable_application_id,-1) = nvl(inc_ag.receivable_application_id,-1))
	GROUP BY time_id,
              time_id_date,
	      event_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      customer_trx_id,
	      payment_schedule_id,
	      adjustment_id,
	      receivable_application_id,
	      appl_trx_date,
		  trx_date,
	      due_date,
		  next_aging_date,
	      unaged_amount_trx,
	      unaged_amount_func,
	      unaged_amount_prim,
	      unaged_amount_sec,
		on_acct_credit_amount_trx,
	 	on_acct_credit_amount_func,
	 	on_acct_credit_amount_prim,
	 	on_acct_credit_amount_sec,
	      class,
	      billing_activity_flag,
	      billed_amount_flag,
	      on_account_credit_flag,
	      unapplied_deposit_flag,
          action,
		  aging_flag;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into fii_ar_aging_receivables in incremental mode');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing fii_ar_aging_receivables table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'fii_ar_aging_receivables');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_RECEIVABLES_AGING;


------------------------------------------------------------------
-- Procedure Inc_RECEIPTS_AGING
-- Purpose
--   This procedure inserts records in fii_ar_aging_receipts
------------------------------------------------------------------
PROCEDURE Inc_RECEIPTS_AGING IS

	type time_id_type IS TABLE OF fii_ar_aging_receipts.time_id%type;
	type event_date_type IS TABLE OF fii_ar_aging_receipts.event_date%type;
	type bill_to_customer_id_type IS TABLE OF fii_ar_aging_receipts.bill_to_customer_id%type;
	type bill_to_site_use_id_type IS TABLE OF fii_ar_aging_receipts.bill_to_site_use_id%type;
	type org_id_type IS TABLE OF fii_ar_aging_receipts.org_id%type;
	type cash_receipt_id_type IS TABLE OF fii_ar_aging_receipts.cash_receipt_id%type;
	type bucket_1_amount_func_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_1_amount_func%type;
	type bucket_1_amount_prim_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_1_amount_prim%type;
	type bucket_1_amount_sec_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_1_amount_sec%type;
	type bucket_1_count_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_1_count%type;
	type bucket_2_amount_func_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_2_amount_func%type;
	type bucket_2_amount_prim_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_2_amount_prim%type;
	type bucket_2_amount_sec_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_2_amount_sec%type;
	type bucket_2_count_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_2_count%type;
	type bucket_3_amount_func_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_3_amount_func%type;
	type bucket_3_amount_prim_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_3_amount_prim%type;
	type bucket_3_amount_sec_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_3_amount_sec%type;
	type bucket_3_count_type IS TABLE OF fii_ar_aging_receipts.aging_bucket_3_count%type;
	type total_unapplied_count_type IS TABLE OF fii_ar_aging_receipts.total_unapplied_count%type;
	type next_aging_date_type IS TABLE OF fii_ar_aging_receipts.next_aging_date%type;
	time_id_MS time_id_type;
	event_date_MS event_date_type;
	bill_to_customer_id_MS bill_to_customer_id_type;
	bill_to_site_use_id_MS bill_to_site_use_id_type;
	org_id_MS org_id_type;
	cash_receipt_id_MS cash_receipt_id_type;
	bucket_1_amount_func_MS bucket_1_amount_func_type;
	bucket_1_amount_prim_MS bucket_1_amount_prim_type;
	bucket_1_amount_sec_MS bucket_1_amount_sec_type;
	bucket_1_count_MS bucket_1_count_type;
	bucket_2_amount_func_MS bucket_2_amount_func_type;
	bucket_2_amount_prim_MS bucket_2_amount_prim_type;
	bucket_2_amount_sec_MS bucket_2_amount_sec_type;
	bucket_2_count_MS bucket_2_count_type;
	bucket_3_amount_func_MS bucket_3_amount_func_type;
	bucket_3_amount_prim_MS bucket_3_amount_prim_type;
	bucket_3_amount_sec_MS bucket_3_amount_sec_type;
	bucket_3_count_MS bucket_3_count_type;
	total_unapplied_count_MS total_unapplied_count_type;
	next_aging_date_MS next_aging_date_type;

BEGIN

  g_state := 'Populating memory structures for fii_ar_aging_receipts';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

	--INSERT INTO  fii_ar_aging_receipts_t
	SELECT time_id,
		  event_date,
	      next_aging_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      cash_receipt_id,
	      sum(aging_bucket_1_amount_func),
	      sum(aging_bucket_1_amount_prim),
	      sum(aging_bucket_1_amount_sec),
	      sum(aging_bucket_1_count),
	      sum(aging_bucket_2_amount_func),
	      sum(aging_bucket_2_amount_prim),
	      sum(aging_bucket_2_amount_sec),
	      sum(aging_bucket_2_count),
	      sum(aging_bucket_3_amount_func),
	      sum(aging_bucket_3_amount_prim),
	      sum(aging_bucket_3_amount_sec),
	      sum(aging_bucket_3_count),
		  sum(total_unapplied_count)
		  --sysdate, --CREATION_DATE,
		  --g_fii_user_id,       --CREATED_BY,
		  --sysdate, --LAST_UPDATE_DATE,
		  --g_fii_user_id,       --LAST_UPDATED_BY,
		  --g_fii_login_id        --LAST_UPDATE_LOGIN
	BULK COLLECT INTO --RctAgingMS
		time_id_MS,
		event_date_MS,
		next_aging_date_MS,
		bill_to_customer_id_MS,
		bill_to_site_use_id_MS,
		org_id_MS,
		cash_receipt_id_MS,
		bucket_1_amount_func_MS,
		bucket_1_amount_prim_MS,
		bucket_1_amount_sec_MS,
		bucket_1_count_MS,
		bucket_2_amount_func_MS,
		bucket_2_amount_prim_MS,
		bucket_2_amount_sec_MS,
		bucket_2_count_MS,
		bucket_3_amount_func_MS,
		bucket_3_amount_prim_MS,
		bucket_3_amount_sec_MS,
		bucket_3_count_MS,
		total_unapplied_count_MS
	FROM
		(SELECT time_id,
  			   next_aging_date,
		       bill_to_customer_id,
			   bill_to_site_use_id,
			   org_id,
			   cash_receipt_id,
		       event_date,
		       aging_bucket_1_amount_func,
		       aging_bucket_1_amount_prim,
		       aging_bucket_1_amount_sec,
		       (case when aging_bucket_1_amount_func = aging_bucket_1_amt_func_cum
		                    AND aging_bucket_1_amount_func <>0
		                then 1
		             when aging_bucket_1_amt_func_cum = 0
		                    AND aging_bucket_1_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_1_count,
		       aging_bucket_2_amount_func,
		       aging_bucket_2_amount_prim,
		       aging_bucket_2_amount_sec,
		       (case when aging_bucket_2_amount_func = aging_bucket_2_amt_func_cum
		                    AND aging_bucket_2_amount_func <>0
		                then 1
		             when aging_bucket_2_amt_func_cum = 0
		                    AND aging_bucket_2_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_2_count,
		       aging_bucket_3_amount_func,
		       aging_bucket_3_amount_prim,
		       aging_bucket_3_amount_sec,
		       (case when aging_bucket_3_amount_func = aging_bucket_3_amt_func_cum
		                    AND aging_bucket_3_amount_func <>0
		                then 1
		             when aging_bucket_3_amt_func_cum = 0
		                    AND aging_bucket_3_amount_func <>0
		                then -1
		             else 0 end) aging_bucket_3_count,
			   (case when total_unapplied_amount_func = total_unapplied_amt_func_cum
		                    AND total_unapplied_amount_func <>0
		                then 1
		             when total_unapplied_amt_func_cum = 0
		                    AND total_unapplied_amount_func <>0
		                then -1
		             else 0 end) total_unapplied_count,
		       aging_flag
		FROM
		   (SELECT time_id,
	  			   next_aging_date,
			       bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   cash_receipt_id,
			       event_date,
			       aging_bucket_1_amount_func,
			       aging_bucket_1_amount_prim,
			       aging_bucket_1_amount_sec,
			       SUM(aging_bucket_1_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_1_amt_func_cum,
			       aging_bucket_2_amount_func,
			       aging_bucket_2_amount_prim,
			       aging_bucket_2_amount_sec,
			       SUM(aging_bucket_2_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_2_amt_func_cum,
			       aging_bucket_3_amount_func,
			       aging_bucket_3_amount_prim,
			       aging_bucket_3_amount_sec,
			       SUM(aging_bucket_3_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) aging_bucket_3_amt_func_cum,
				   (aging_bucket_1_amount_func
					+ aging_bucket_2_amount_func
					+ aging_bucket_3_amount_func) total_unapplied_amount_func,
					(SUM(aging_bucket_1_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
					 + SUM(aging_bucket_2_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
 					 + SUM(aging_bucket_3_amount_func) OVER (partition by cash_receipt_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)) total_unapplied_amt_func_cum,
 			       aging_flag
			FROM
			   (SELECT to_number(to_char(decode(g_collection_criteria,
				                       'GL', case when gl_date >= event_date
													then gl_date
												  else decode(aging_flag,'N',gl_date,event_date) end,
				                       event_date), 'J')) time_id,
	 				   next_aging_date,
			           bill_to_customer_id,
			    	   bill_to_site_use_id,
			    	   org_id,
			    	   cash_receipt_id,
			           receivable_application_id,
			           event_date,
			           (case when marker=1
			                    then bucket_amount_func
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) aging_bucket_1_amount_func,
			           (case when marker=1
			                    then bucket_amount_prim
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) aging_bucket_1_amount_prim,
			           (case when marker=1
			                    then bucket_amount_sec
			                 when marker=2 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) aging_bucket_1_amount_sec,
			            ----------------
			           (case when marker=2
			                    then bucket_amount_func
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_func
			                 else 0 end) aging_bucket_2_amount_func,
			           (case when marker=2
			                    then bucket_amount_prim
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_prim
			                 else 0 end) aging_bucket_2_amount_prim,
			           (case when marker=2
			                    then bucket_amount_sec
			                 when marker=3 and aging_flag='Y'
			                    then -1*bucket_amount_sec
			                 else 0 end) aging_bucket_2_amount_sec,
			            ----------------
			           (case when marker=3
			                    then bucket_amount_func
			                 else 0 end) aging_bucket_3_amount_func,
			           (case when marker=3
			                    then bucket_amount_prim
			                 else 0 end) aging_bucket_3_amount_prim,
			           (case when marker=3
			                    then bucket_amount_sec
			                 else 0 end) aging_bucket_3_amount_sec,
			            ---------------
			           aging_flag
			    FROM
			       (SELECT m.marker,
			               v.bill_to_customer_id,
			        	   v.bill_to_site_use_id,
			        	   v.org_id,
			        	   v.cash_receipt_id,
			               v.receivable_application_id,
			         	   v.apply_date,
						   v.gl_date,
			               v.bucket_amount_func,
			               v.bucket_amount_prim,
			               v.bucket_amount_sec,
			               decode(m.marker,
			                      1, case when (g_rct_bucket_1_high is not null AND trunc(v.apply_date) between trunc(v.receipt_date) and trunc(v.receipt_date)+g_rct_bucket_1_high)
			                                then v.apply_date
										  when (g_rct_bucket_1_high is null AND trunc(v.apply_date) >= trunc(v.receipt_date))
			                                then v.apply_date
			                              else null end,
			                      2, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_2_low
			                                and trunc(receipt_date) + g_rct_bucket_2_low <= g_sysdate
											and trunc(receipt_date) + g_rct_bucket_2_low <= trunc(rct_actual_date_closed)
			                                then trunc(receipt_date) + g_rct_bucket_2_low
			                              when (g_rct_bucket_2_high is not null AND trunc(v.apply_date) between trunc(v.receipt_date)+g_rct_bucket_2_low and trunc(v.receipt_date)+g_rct_bucket_2_high)
			                                then trunc(v.apply_date)
			                              when (g_rct_bucket_2_high is null AND trunc(v.apply_date) >= trunc(v.receipt_date)+g_rct_bucket_2_low)
			                                then trunc(v.apply_date)
			                              else null end,
			                      3, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_3_low
			                                and trunc(receipt_date) + g_rct_bucket_3_low <= g_sysdate
											and trunc(receipt_date) + g_rct_bucket_3_low <= trunc(rct_actual_date_closed)
			                                then trunc(receipt_date) + g_rct_bucket_3_low
			                              when trunc(v.apply_date) >= trunc(v.receipt_date)+g_rct_bucket_3_low
			                                then trunc(v.apply_date)
			                              else null end) event_date,
						   decode(m.marker,
			                      1, case when trunc(rct_actual_date_closed) >= trunc(v.receipt_date) + g_rct_bucket_2_low
											then trunc(v.receipt_date) + g_rct_bucket_2_low
									 else null end,
			                      2, case when trunc(rct_actual_date_closed) >= trunc(receipt_date) + g_rct_bucket_3_low
											then trunc(receipt_date) + g_rct_bucket_3_low
									 else null end,
			                      3, null) next_aging_date,
			               decode(m.marker,
			                      1, 'N',
			                      2, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_2_low
			                                and trunc(receipt_date) + g_rct_bucket_2_low <= g_sysdate
			                                then 'Y'
			                              else'N' end,
			                      3, case when trunc(v.apply_date) < trunc(v.receipt_date)+g_rct_bucket_3_low
			                                and trunc(receipt_date) + g_rct_bucket_3_low <= g_sysdate
			                                then 'Y'
			                              else 'N' end) aging_flag
			        FROM (--Unapplied Receipts
			              select  gt.apply_date,
			                      gt.receipt_date,
								  gt.gl_date,
								  gt.rct_actual_date_closed,
			            		  gt.bill_to_customer_id,
			            		  gt.bill_to_site_use_id,
			            		  gt.org_id,
			            		  gt.cash_receipt_id,
			                      gt.receivable_application_id,
			            		  gt.amount_applied_rct_func bucket_amount_func,
			            		  gt.amount_applied_rct_prim bucket_amount_prim,
			            		  gt.amount_applied_rct_sec bucket_amount_sec
			              from FII_AR_RECAPP_MERGE_GT gt
			              where gt.application_status in ('UNAPP','UNID')
						  and gt.header_status not in ('REV', 'NSF', 'STOP')
						  and nvl(gt.applied_payment_schedule_id,1) > 0 --exclude all special applications
					      and gt.application_type = 'CASH'
						  and gt.amount_applied_rct_func <> 0) v,
			             (SELECT 1 marker FROM DUAL UNION ALL
			              SELECT 2 marker FROM DUAL WHERE g_rct_bucket_2_low is not null UNION ALL
			              SELECT 3 marker FROM DUAL WHERE g_rct_bucket_3_low is not null) m)
			    WHERE event_date is not null)
			GROUP BY time_id,
			         bill_to_customer_id,
			    	 bill_to_site_use_id,
			    	 org_id,
			    	 cash_receipt_id,
			         receivable_application_id,
			         event_date,
			         aging_bucket_1_amount_func,
			         aging_bucket_1_amount_prim,
			         aging_bucket_1_amount_sec,
			         aging_bucket_2_amount_func,
			         aging_bucket_2_amount_prim,
			         aging_bucket_2_amount_sec,
			         aging_bucket_3_amount_func,
			         aging_bucket_3_amount_prim,
			         aging_bucket_3_amount_sec,
					 next_aging_date,
			         aging_flag

			order by receivable_application_id, event_date
			)
		)
	GROUP BY time_id,
	      event_date,
	      bill_to_customer_id,
	      bill_to_site_use_id,
	      org_id,
	      cash_receipt_id,
	      next_aging_date
	HAVING sum(aging_bucket_1_amount_func) <> 0
		   or
	  	   sum(aging_bucket_2_amount_func) <> 0
		   or
		   sum(aging_bucket_3_amount_func) <>0;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into memory structures related to fii_ar_aging_receipts.');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Updating fii_ar_aging_receipts';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  IF time_id_MS.First is not null Then

	FORALL i in time_id_MS.First..time_id_MS.Last
	UPDATE  fii_ar_aging_receipts ag
	SET ag.aging_bucket_1_amount_func = bucket_1_amount_func_MS(i),
	    ag.aging_bucket_1_amount_prim = bucket_1_amount_prim_MS(i),
	    ag.aging_bucket_1_amount_sec = bucket_1_amount_sec_MS(i),
	    ag.aging_bucket_1_count = bucket_1_count_MS(i),
	    ag.aging_bucket_2_amount_func = bucket_2_amount_func_MS(i),
	    ag.aging_bucket_2_amount_prim = bucket_2_amount_prim_MS(i),
	    ag.aging_bucket_2_amount_sec = bucket_2_amount_sec_MS(i),
	    ag.aging_bucket_2_count = bucket_2_count_MS(i),
	    ag.aging_bucket_3_amount_func = bucket_3_amount_func_MS(i),
	    ag.aging_bucket_3_amount_prim = bucket_3_amount_prim_MS(i),
	    ag.aging_bucket_3_amount_sec = bucket_3_amount_sec_MS(i),
	    ag.aging_bucket_3_count = bucket_3_count_MS(i),
	    ag.next_aging_date = next_aging_date_MS(i),
		ag.last_update_date = sysdate,
		ag.last_update_login = g_fii_login_id
	WHERE ag.time_id = time_id_MS(i)
	 AND ag.cash_receipt_id = cash_receipt_id_MS(i)
	 AND (ag.aging_bucket_1_amount_func <> bucket_1_amount_func_MS(i)
	      OR ag.aging_bucket_2_amount_func <> bucket_2_amount_func_MS(i)
	      OR ag.aging_bucket_3_amount_func <> bucket_3_amount_func_MS(i));

  End If;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated ' ||SQL%ROWCOUNT|| ' records in fii_ar_aging_receipts');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Inserting into fii_ar_aging_receipts';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  IF time_id_MS.First is not null Then

	FORALL i in time_id_MS.First..time_id_MS.Last
	INSERT INTO  fii_ar_aging_receipts ag
	SELECT time_id_MS(i), event_date_MS(i), next_aging_date_MS(i), bill_to_customer_id_MS(i),
	 bill_to_site_use_id_MS(i), org_id_MS(i), cash_receipt_id_MS(i),
	 bucket_1_amount_func_MS(i), bucket_1_amount_prim_MS(i), bucket_1_amount_sec_MS(i), bucket_1_count_MS(i),
	 bucket_2_amount_func_MS(i), bucket_2_amount_prim_MS(i), bucket_2_amount_sec_MS(i), bucket_2_count_MS(i),
	 bucket_3_amount_func_MS(i), bucket_3_amount_prim_MS(i), bucket_3_amount_sec_MS(i), bucket_3_count_MS(i),
	 total_unapplied_count_MS(i), sysdate, g_fii_user_id, sysdate, g_fii_user_id, g_fii_login_id
	FROM DUAL
	WHERE NOT EXISTS
		(SELECT 1
		 FROM  fii_ar_aging_receipts ag
		 WHERE ag.time_id = time_id_MS(i)
		 AND ag.cash_receipt_id = cash_receipt_id_MS(i));

  End If;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into fii_ar_aging_receipts');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing fii_ar_aging_receipts table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'fii_ar_aging_receipts');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_RECEIPTS_AGING;

------------------------------------------------------------------
-- Procedure Inc_DISPUTES_AGING
-- Purpose
--   This procedure inserts records in fii_ar_aging_receipts
------------------------------------------------------------------
PROCEDURE Inc_DISPUTES_AGING IS

BEGIN

  g_state := 'Inserting into fii_ar_aging_disputes';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

    INSERT INTO FII_AR_AGING_DISPUTES
	 (time_id,
	  event_date,
	  next_aging_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  org_id,
	  customer_trx_id,
	  payment_schedule_id,
	  due_date,
	  current_dispute_amount_func,
	  current_dispute_amount_prim,
	  current_dispute_amount_sec,
	  current_dispute_count,
	  past_due_dispute_amount_func,
	  past_due_dispute_amount_prim,
	  past_due_dispute_amount_sec,
	  past_due_dispute_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
	SELECT time_id,
		  event_date,
	      next_aging_date,
		  bill_to_customer_id,
		  bill_to_site_use_id,
		  org_id,
		  customer_trx_id,
		  payment_schedule_id,
		  due_date,
		  sum(current_dispute_amount_func),
		  sum(current_dispute_amount_prim),
		  sum(current_dispute_amount_sec),
		  sum(current_dispute_count),
		  sum(past_due_dispute_amount_func),
		  sum(past_due_dispute_amount_prim),
		  sum(past_due_dispute_amount_sec),
		  sum(past_due_dispute_count),
		  sysdate CREATION_DATE,
		  g_fii_user_id CREATED_BY,
		  sysdate LAST_UPDATE_DATE,
		  g_fii_user_id LAST_UPDATED_BY,
		  g_fii_login_id LAST_UPDATE_LOGIN
	FROM (
		SELECT time_id,
			  event_date,
		      next_aging_date,
			  bill_to_customer_id,
			  bill_to_site_use_id,
			  org_id,
			  customer_trx_id,
			  payment_schedule_id,
			  due_date,
			  current_dispute_amount_func,
			  current_dispute_amount_prim,
			  current_dispute_amount_sec,
		      SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) current_dispute_amount_funcc,
		      (case when current_dispute_amount_func = SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
		                and current_dispute_amount_func <> 0
						then 1
		             when SUM(current_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) = 0
		                    AND current_dispute_amount_func <> 0
		                then -1
		             else 0 end) current_dispute_count,
			  past_due_dispute_amount_func,
			  past_due_dispute_amount_prim,
			  past_due_dispute_amount_sec,
		      SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) past_due_dispute_amount_funcc,
		      (case when past_due_dispute_amount_func = SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING)
		                and past_due_dispute_amount_func <> 0
						then 1
		             when SUM(past_due_dispute_amount_func) OVER (partition by customer_trx_id ORDER BY time_id ROWS UNBOUNDED PRECEDING) = 0
		                and past_due_dispute_amount_func <> 0
		                then -1
		             else 0 end) past_due_dispute_count,

		       aging_flag
		FROM
		   (SELECT to_number(to_char(event_date, 'J')) time_id,
				   event_date,
				   next_aging_date,
				   bill_to_customer_id,
				   bill_to_site_use_id,
				   org_id,
				   customer_trx_id,
				   payment_schedule_id,
				   due_date,
		           (case when marker=1
		                    then bucket_amount_func
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_func
		                 else 0 end) current_dispute_amount_func,
		           (case when marker=1
		                    then bucket_amount_prim
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_prim
		                 else 0 end) current_dispute_amount_prim,
		           (case when marker=1
		                    then bucket_amount_sec
		                 when marker=2 and aging_flag='Y'
		                    then -1*bucket_amount_sec
		                 else 0 end) current_dispute_amount_sec,
		            ----------------
		           (case when marker=2
		                    then bucket_amount_func
		                 else 0 end) past_due_dispute_amount_func,
		           (case when marker=2
		                    then bucket_amount_prim
		                 else 0 end) past_due_dispute_amount_prim,
		           (case when marker=2
		                    then bucket_amount_sec
		                 else 0 end) past_due_dispute_amount_sec,
		            ---------------
		            aging_flag
		    FROM
		       (SELECT m.marker,
					   v.time_id,
		               v.bill_to_customer_id,
		        	   v.bill_to_site_use_id,
		        	   v.org_id,
		        	   v.customer_trx_id,
		        	   v.payment_schedule_id,
					   v.due_date,
		               v.bucket_amount_func,
		               v.bucket_amount_prim,
		               v.bucket_amount_sec,
		               decode(m.marker,
		                      1, case when trunc(v.start_date)<=trunc(v.due_date)
		                                then v.start_date
		                              else null end,
		                      2, case when trunc(v.start_date) <= trunc(v.due_date)
											and actual_date_closed >= trunc(v.due_date)+1
											and trunc(v.due_date)+1  <= g_sysdate
		                                then trunc(v.due_date)+1
		                              when trunc(v.start_date) >= trunc(v.due_date)+1
		                                then trunc(v.start_date)
		                              else null end) event_date,
					   decode(m.marker,
		                      1, case when trunc(v.due_date)+1 <= actual_date_closed
										then trunc(v.due_date)+1 end,
		                      2, null) next_aging_date,
		               decode(m.marker,
		                      1, 'N',
		                      2, case when trunc(v.start_date) <= trunc(v.due_date)
											and v.actual_date_closed >= trunc(v.due_date)+1
											and trunc(v.due_date)+1  <= g_sysdate
		                                then 'Y'
		                              else 'N' end) aging_flag
		        FROM (--Disputes
		              select dis.time_id,
							 dis.start_date,
							 dis.bill_to_customer_id,
							 dis.bill_to_site_use_id,
							 dis.org_id,
							 --dis.dispute_history_id,
							 dis.customer_trx_id,
							 dis.payment_schedule_id,
							 dis.due_date,
							 dis.actual_date_closed,
		                     sum(dis.dispute_amount_func)   bucket_amount_func,
		                     sum(dis.dispute_amount_prim)   bucket_amount_prim,
		                     sum(dis.dispute_amount_sec)    bucket_amount_sec
		              from fii_ar_dispute_history_f dis,
                                   (select distinct customer_trx_id
                                    from fii_ar_disp_update_gt dis_gt,
                                         fii_ar_dispute_history_f f
                                    where dis_gt.payment_schedule_id = f.payment_schedule_id) gt
					  where dis.customer_trx_id = gt.customer_trx_id
					  group by dis.time_id,
							 dis.start_date,
							 dis.bill_to_customer_id,
							 dis.bill_to_site_use_id,
							 dis.org_id,
							 dis.customer_trx_id,
							 dis.payment_schedule_id,
							 dis.due_date,
							 dis.actual_date_closed

					  union all

					  --Disputes that are ended
					  select to_number(to_char(end_date, 'J')) time_id,
					       least(end_date, actual_date_closed) start_date,
					       bill_to_customer_id,
						   bill_to_site_use_id,
						   org_id,
						   customer_trx_id,
						   payment_schedule_id,
						   due_date,
						   actual_date_closed,
					       -1*bucket_amount_func,
					       -1*bucket_amount_prim,
					       -1*bucket_amount_sec
					  from
					    (select null time_id,
					         max(nvl(dis.end_date, to_date('12/31/4712','MM/DD/YYYY'))) end_date,
					    	 dis.bill_to_customer_id,
					    	 dis.bill_to_site_use_id,
					    	 dis.org_id,
					    	 dis.customer_trx_id,
					    	 dis.payment_schedule_id,
					    	 dis.due_date,
					    	 dis.actual_date_closed,
					         sum(dis.dispute_amount_func)   bucket_amount_func,
					         sum(dis.dispute_amount_prim)   bucket_amount_prim,
					         sum(dis.dispute_amount_sec)    bucket_amount_sec
					    from fii_ar_dispute_history_f dis,
						 (select distinct customer_trx_id
                                                  from fii_ar_disp_update_gt dis_gt,
                                                       fii_ar_dispute_history_f f
                                                  where dis_gt.payment_schedule_id = f.payment_schedule_id) gt
					    where dis.customer_trx_id = gt.customer_trx_id
					    group by dis.bill_to_customer_id,
					    	 dis.bill_to_site_use_id,
					    	 dis.org_id,
					    	 dis.customer_trx_id,
					    	 dis.payment_schedule_id,
					    	 dis.due_date,
					    	 dis.actual_date_closed)
					  where least(end_date, actual_date_closed) <> to_date('12/31/4712','MM/DD/YYYY')) v,
		             (SELECT 1 marker FROM DUAL UNION ALL
		              SELECT 2 marker FROM DUAL) m)
		    WHERE event_date is not null)
/*		GROUP BY time_id,
			  event_date,
		      next_aging_date,
			  bill_to_customer_id,
			  bill_to_site_use_id,
			  org_id,
			  --dispute_history_id,
			  customer_trx_id,
			  payment_schedule_id,
			  due_date,
			  current_dispute_amount_func,
			  current_dispute_amount_prim,
			  current_dispute_amount_sec,
			  past_due_dispute_amount_func,
			  past_due_dispute_amount_prim,
			  past_due_dispute_amount_sec,
		      aging_flag
*/
		order by payment_schedule_id, event_date

	) inc_ag
	WHERE NOT EXISTS
		  (SELECT 1
		   FROM  fii_ar_aging_disputes ag
		   WHERE ag.time_id = inc_ag.time_id
		   AND ag.payment_schedule_id = inc_ag.payment_schedule_id)
	GROUP BY time_id,
		  event_date,
	      next_aging_date,
		  bill_to_customer_id,
		  bill_to_site_use_id,
		  org_id,
		  --dispute_history_id,
		  customer_trx_id,
		  payment_schedule_id,
		  due_date
	HAVING sum(current_dispute_amount_func) <> 0
		   or
	  	   sum(past_due_dispute_amount_func) <> 0;



  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into fii_ar_aging_disputes.');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  g_state := 'Analyzing fii_ar_aging_disputes table';
  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'fii_ar_aging_disputes');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Inc_DISPUTES_AGING;

------------------------------------------------------------------
-- Procedure CLEAN_REC_AGING
-- Purpose
--   This procedure deletes records from fii_ar_aging_receivables
--   that comply with either one of the following cases:
--   1- Records with customer_trx_id corresponding to an incompleted trx
--   2- Records that correspond to transactions that have passed from
--      a state of complete to incomplete and then back to complete since the
--  	last run.
--   3- Records that correspond to transactions that have been updated
--      after initial load (new appl or adj) and having event_date >
--      min update date.
------------------------------------------------------------------
PROCEDURE CLEAN_REC_AGING IS

    type payment_schedule_id_type is table of NUMBER(15);
    type customer_trx_id_type is table of NUMBER(15);
    type min_date_type is table of DATE;
    sch_id_array payment_schedule_id_type;
    trx_id_array customer_trx_id_type;
    min_date_array min_date_type;

BEGIN

    g_state := 'Started CLEAN_REC_AGING';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	SELECT payment_schedule_id, customer_trx_id, min_date
	BULK COLLECT INTO sch_id_array, trx_id_array, min_date_array
	FROM (--Case 1 and Case 2
              select payment_schedule_id, null customer_trx_id, null min_date
              from fii_ar_paysch_delete_gt

              union all

              --Case 3
              select null payment_schedule_id, customer_trx_id, min(min_date) min_date
              from
                    (select applied_customer_trx_id customer_trx_id, min(decode(g_collection_criteria, 'GL', gl_date, apply_date)) min_date
                     from FII_AR_RECAPP_INSERT_GT
                     where applied_payment_schedule_id > 0
                     group by applied_customer_trx_id

                     union all

                     select customer_trx_id, min(decode(g_collection_criteria, 'GL', gl_date, apply_date)) min_date
                     from FII_AR_ADJ_UPDATE_GT
                     group by customer_trx_id)
              group by customer_trx_id
             );


    g_state := 'Deleting from fii_ar_aging_receivables';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

    IF trx_id_array.First is not null Then

		FORALL i in trx_id_array.First..trx_id_array.Last
			DELETE FROM  fii_ar_aging_receivables ag
			WHERE (sch_id_array(i) is not null
	                       and ag.payment_schedule_id = sch_id_array(i))
	                OR (sch_id_array(i) is null
	                    and ag.customer_trx_id = trx_id_array(i)
	                    and ag.event_date >= min_date_array(i));
     End If;

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from fii_ar_aging_receivables.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

      --dbms_output.put_line('Error occured while ' || g_state);
      --dbms_output.put_line(g_exception_msg);

END;

------------------------------------------------------------------
-- Procedure CLEAN_RCT_AGING
-- Purpose
--   This procedure deletes records from fii_ar_aging_receipts
--   that comply with either one of the following cases:
--   1- Deleted receipts
--   2- event_date > actual_date_closed of closed receipts
--   3- Bug 5862579: Receipts in aging table that are now reveresed.
------------------------------------------------------------------
PROCEDURE CLEAN_RCT_AGING IS

    type cash_receipt_id_type is table of NUMBER(15);
    type actual_date_closed_type is table of NUMBER;
	rct_id_array cash_receipt_id_type;
	date_closed_array actual_date_closed_type;

BEGIN

	g_state := 'Started CLEAN_RCT_AGING';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	SELECT cash_receipt_id, actual_date_closed
	BULK COLLECT INTO rct_id_array, date_closed_array
	FROM (--Case 1
		 select cash_receipt_id,  1 actual_date_closed
		 from FII_AR_RECAPP_DELETE_GT

		 union all

		 --Cases 2
		 select distinct ag.cash_receipt_id, to_number(to_char(rct.rct_actual_date_closed, 'J')) actual_date_closed
		 from fii_ar_receipts_f rct,
			   fii_ar_aging_receipts ag
		 where rct.cash_receipt_id = ag.cash_receipt_id
		 and rct.receivable_application_id <= G_MAX_RECEIVABLE_APPL_ID
         and to_number(to_char(rct.rct_actual_date_closed, 'J')) < ag.time_id

		union all

                --Case 3
		select ag.cash_receipt_id, 1 actual_date_closed
		from fii_ar_receipts_f rct,
		     fii_ar_aging_receipts ag
		where rct.cash_receipt_id = ag.cash_receipt_id
		and rct.receivable_application_id <= G_MAX_RECEIVABLE_APPL_ID
            and rct.header_status in ('REV','NSF','STOP') );

	g_state := 'Deleting from fii_ar_aging_receipts';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

    If rct_id_array.First is not null Then

		FORALL i in rct_id_array.First..rct_id_array.Last
			DELETE FROM  fii_ar_aging_receipts ag
			WHERE ag.cash_receipt_id = rct_id_array(i)
			AND ag.time_id > date_closed_array(i);

    End If;

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from fii_ar_aging_receipts.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END;

------------------------------------------------------------------
-- Procedure CLEAN_DISP_AGING
-- Purpose
--   This procedure deletes records from fii_ar_aging_disputes
--   that comply with either one of the following cases:
--	  1- incompleted trx(s)
--    2- C-I-C trx(s)
--    3- event_date > actual_date_closed in GT table of updated trx(s)
--    4- event_date > end_date of updated disputes
------------------------------------------------------------------
PROCEDURE CLEAN_DISP_AGING IS

    type payment_schedule_id_type is table of NUMBER(15);
    type customer_trx_id_type is table of NUMBER(15);
    type min_date_type is table of DATE;
    sch_id_array payment_schedule_id_type;
    trx_id_array customer_trx_id_type;
    min_date_array min_date_type;

BEGIN

    g_state := 'Started CLEAN_DISP_AGING';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	SELECT payment_schedule_id, customer_trx_id, min_date
	BULK COLLECT INTO sch_id_array, trx_id_array, min_date_array
	FROM (--Case 1 and 2
          select payment_schedule_id, null customer_trx_id, to_date(1, 'J') min_date
          from fii_ar_paysch_delete_gt

          union all

		  --Case 3
		  select null payment_schedule_id, gt.customer_trx_id, gt.actual_date_closed min_date
		  from fii_ar_paysch_merge_gt gt,
			   fii_ar_aging_disputes ag
		  where ag.payment_schedule_id = gt.payment_schedule_id
		  and ag.event_date >= gt.actual_date_closed

		  union all

          --Case 4
		  select null payment_schedule_id, ag.customer_trx_id, gt.end_date min_date
		  from fii_ar_disp_update_gt gt,
			   fii_ar_aging_disputes ag
		  where ag.payment_schedule_id = gt.payment_schedule_id
		  and ag.event_date >= gt.end_date
         );

    g_state := 'Deleting from fii_ar_aging_disputes';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	If min_date_array.First is not null Then

		FORALL i in min_date_array.First..min_date_array.Last
			DELETE FROM  fii_ar_aging_disputes ag
			WHERE (sch_id_array(i) is not null
                               and ag.payment_schedule_id = sch_id_array(i))
                           OR (trx_id_array(i) is not null
                               and ag.customer_trx_id = trx_id_array(i)
                               and ag.event_date >= min_date_array(i));

	End If;

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Deleted ' ||SQL%ROWCOUNT|| ' records from fii_ar_aging_disputes.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

      --dbms_output.put_line('Error occured while ' || g_state);
      --dbms_output.put_line(g_exception_msg);

END CLEAN_DISP_AGING;

------------------------------------------------------------------
-- Procedure POPULATE_INCREMENTAL_IDS
-- Purpose
--   This procedure detects new/updated receipts and adjustments.
--   It also detects records in fii_ar_aging_receivables that have not been
--   completely aged.
--   Corresponding customer_trx_id(s) are populated in FII_AR_PAYSCH_MERGE_GT
------------------------------------------------------------------
PROCEDURE POPULATE_INCREMENTAL_IDS IS

BEGIN

    g_state := 'Populating FII_AR_PAYSCH_MERGE_GT from fii_ar_aging_receivables';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

    --FII_AR_PAYSCH_MERGE_GT already contains:
    --trx_ids of new payment schedules
	--trx_ids that have new applications
	--trx_ids that have new or updated adjustments

	--Insert trx ids that are already in aging table but not yet aged completely
	INSERT INTO FII_AR_PAYSCH_MERGE_GT
	(customer_trx_id)
	(select distinct ag.customer_trx_id
         from  fii_ar_aging_receivables ag
         where ag.next_aging_date > G_LAST_UPDATE_DATE --'15-APR-2005'
         and ag.next_aging_date <= g_sysdate --'20-MAY-2005'
         and not exists
           (select 1
            from fii_ar_paysch_merge_gt t
            where t.customer_trx_id = ag.customer_trx_id));

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' additional records into FII_AR_PAYSCH_MERGE_GT.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END;


------------------------------------------------------------------
-- Procedure POPULATE_INCREMENTAL_RCT_IDS
-- Purpose
--   This procedure detects new unapplied receipts.
--   It also detects records in fii_ar_aging_receipts that have not been
--   completely aged.
--   Corresponding cash_receipt_id(s) are populated in FII_AR_RECAPP_MERGE_GT
------------------------------------------------------------------
PROCEDURE POPULATE_INCREMENTAL_RCT_IDS IS

BEGIN

    g_state := 'Populating FII_AR_INC_RCT_AGING_T from fii_ar_receipts_f';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	--trx_ids that have new applications
	--These are already in FII_AR_RECAPP_MERGE_GT

	g_state := 'Populating FII_AR_RECAPP_MERGE_GT from fii_ar_aging_receipts';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

	--Insert rct ids that are already in aging table but not yet aged completely
	INSERT INTO FII_AR_RECAPP_MERGE_GT
	( receivable_application_id,
	  time_id,
	  cash_receipt_id,
	  application_status,
	  header_status,
	  amount_applied_rct,
	  amount_applied_trx,
	  amount_applied_rct_func,
	  amount_applied_trx_func,
	  amount_applied_rct_prim,
	  amount_applied_trx_prim,
	  amount_applied_rct_sec,
	  amount_applied_trx_sec,
	  earned_discount_amount_trx,
	  earned_discount_amount_func,
	  earned_discount_amount_prim,
	  earned_discount_amount_sec,
	  unearned_discount_amount_trx,
	  unearned_discount_amount_func,
	  unearned_discount_amount_prim,
	  unearned_discount_amount_sec,
	  apply_date,
	  gl_date,
	  filter_date,
	  header_filter_date,
	  application_type,
	  applied_payment_schedule_id,
	  applied_customer_trx_id,
	  customer_trx_id,
	  payment_schedule_id,
	  receipt_number,
	  receipt_type,
	  receipt_date,
	  rct_actual_date_closed,
	  receipt_method_id,
	  currency_code,
	  user_id,
	  ar_creation_date,
	  bill_to_customer_id,
	  bill_to_site_use_id,
	  collector_bill_to_customer_id,
	  collector_bill_to_site_use_id,
	  org_id,
	  trx_date,
	  due_date,
	  cm_previous_customer_trx_id,
	  total_receipt_count,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login
	 )
	(SELECT   receivable_application_id,
			  time_id,
			  rct.cash_receipt_id,
			  application_status,
			  header_status,
			  amount_applied_rct,
			  amount_applied_trx,
			  amount_applied_rct_func,
			  amount_applied_trx_func,
			  amount_applied_rct_prim,
			  amount_applied_trx_prim,
			  amount_applied_rct_sec,
			  amount_applied_trx_sec,
			  earned_discount_amount_trx,
			  earned_discount_amount_func,
			  earned_discount_amount_prim,
			  earned_discount_amount_sec,
			  unearned_discount_amount_trx,
			  unearned_discount_amount_func,
			  unearned_discount_amount_prim,
			  unearned_discount_amount_sec,
			  apply_date,
			  gl_date,
			  filter_date,
			  header_filter_date,
			  application_type,
			  applied_payment_schedule_id,
			  applied_customer_trx_id,
			  customer_trx_id,
			  payment_schedule_id,
			  receipt_number,
			  receipt_type,
			  receipt_date,
			  rct_actual_date_closed,
			  receipt_method_id,
			  currency_code,
			  user_id,
			  ar_creation_date,
			  bill_to_customer_id,
			  bill_to_site_use_id,
			  collector_bill_to_customer_id,
			  collector_bill_to_site_use_id,
			  org_id,
			  trx_date,
			  due_date,
			  cm_previous_customer_trx_id,
			  total_receipt_count,
			  creation_date,
			  created_by,
			  last_update_date,
			  last_updated_by,
			  last_update_login
	 from fii_ar_receipts_f rct,
	      (select distinct ag.cash_receipt_id
		   from  fii_ar_aging_receipts ag
		   where ag.next_aging_date > G_LAST_UPDATE_DATE --'15-APR-2005'
		   and ag.next_aging_date <= g_sysdate --'20-MAY-2005'
		   and not exists
			    (select 1
			     from FII_AR_RECAPP_MERGE_GT t
			     where t.cash_receipt_id = ag.cash_receipt_id
				 and t.application_status in ('UNAPP','UNID')
				 and t.header_status not in ('REV', 'NSF', 'STOP')
				 and nvl(t.applied_payment_schedule_id,1) > 0 --exclude all special applications
				 and t.application_type = 'CASH'
				 and t.amount_applied_rct_func <> 0)) ag
	 where rct.cash_receipt_id = ag.cash_receipt_id
     and rct.application_status in ('UNAPP','UNID')
     and rct.header_status not in ('REV', 'NSF', 'STOP')
     and nvl(rct.applied_payment_schedule_id,1) > 0 --exclude all special applications
     and rct.application_type = 'CASH'
     and rct.amount_applied_rct_func <> 0);

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' additional records into FII_AR_RECAPP_MERGE_GT.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END;

------------------------------------------------------------------
-- Procedure POPULATE_INCREMENTAL_DISP_IDS
-- Purpose
--    Ages inc disputes:
--    a- New and Updated disputes with last_update_date > MAX
--    b- Non-completely aged disputes
------------------------------------------------------------------
PROCEDURE POPULATE_INCREMENTAL_DISP_IDS IS

BEGIN

    g_state := 'Populating FII_AR_DISP_UPDATE_GT from fii_ar_aging_disputes';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
    end if;

    --FII_AR_DISP_UPDATE_GT already contains:
    --sch_ids of new and updated disputes

	--Insert sch ids that are already in aging table but not yet aged completely
	INSERT INTO FII_AR_DISP_UPDATE_GT
	(payment_schedule_id)
	(select distinct ag.payment_schedule_id
         from  fii_ar_aging_disputes ag
         where ag.next_aging_date > G_LAST_UPDATE_DATE --'15-APR-2005'
         and ag.next_aging_date <= g_sysdate --'20-MAY-2005'
         and not exists
           (select 1
            from FII_AR_DISP_UPDATE_GT t
            where t.payment_schedule_id = ag.payment_schedule_id));

	 if g_debug_flag = 'Y' then
	     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' additional records into FII_AR_DISP_UPDATE_GT.');
	     FII_UTIL.stop_timer;
	     FII_UTIL.print_timer('Duration');
	     FII_UTIL.put_line('');
	 end if;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_INCREMENTAL_DISP_IDS;


-----------------------------------------------------------
-- Procedure
--   Inc_Extraction()
-- Purpose
--   This routine handles all procedures involved in populating FII
--   AR DBI fact tables in incremental load.

-----------------------------------------------------------
--  PROCEDURE Inc_Extraction
-----------------------------------------------------------
Procedure Inc_Extraction( Errbuf          IN OUT NOCOPY VARCHAR2,
                          Retcode         IN OUT NOCOPY VARCHAR2
                        ) IS
  l_dir                VARCHAR2(400);

BEGIN
  g_state := 'Inside the procedure Inc_Extraction';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  Retcode := 0;

  ------------------------------------------------------
  -- Set default directory in case if the profile option
  -- BIS_DEBUG_LOG_DIRECTORY is not set up
  ------------------------------------------------------
  l_dir:=FII_UTIL.get_utl_file_dir;

  ----------------------------------------------------------------
  -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
  -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
  -- the log files and output files are written to
  ----------------------------------------------------------------
  FII_UTIL.initialize('FII_AR_FACTS_AGING_INIT.log','FII_AR_FACTS_AGING_INIT.out',l_dir, 'FII_AR_FACTS_AGING_INIT');

  EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE=UNLIMITED';

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Init procedure to initialize the global variables');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INIT;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Populating dimension helper tables fii_ar_help_mkt_classes and fii_ar_help_collectors');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  POPULATE_HELPER_TABLES;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Inc_Prepare procedure to prepare for the incremental load');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  Inc_Prepare;


  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the GET_BUCKET_RANGES procedure to load and validate bucket range definitions');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  GET_BUCKET_RANGES;


  g_state := 'Truncating table FII_AR_CURR_RATES_T';
  TRUNCATE_TABLE('FII_AR_CURR_RATES_T');

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Inc_RATES procedure to insert the missing rate info');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  Inc_RATES;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Verify_Missing_Rates procedure');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  IF (VERIFY_MISSING_RATES = -1) THEN
    g_retcode := -1;
    g_errbuf := fnd_message.get_string('FII', 'FII_MISS_EXCH_RATE_FOUND');

    RAISE G_MISSING_RATES;

  -----------------------------------------------------------------------
  -- If there are no missing exchange rate records, then insert
  -- records into the fact and aging tables
  -----------------------------------------------------------------------
  ELSE

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_PAYMENT_SCHEDULES');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_PAYMENT_SCHEDULES;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_DISPUTES');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_DISPUTES;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_TRANSACTIONS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_TRANSACTIONS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_ADJUSTMENTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_ADJUSTMENTS;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_RECEIPTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_RECEIPTS;


    /*
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_SCHEDULED_DISCOUNTS');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    POPULATE_SCHEDULED_DISCOUNTS;
	*/

	----------------------------------------------------------
	---------- Inc load of FII_AR_AGING_RECEIVABLES-----------
	----------------------------------------------------------
	if g_debug_flag = 'Y' then
	 FII_UTIL.put_line('-------------------------------------------------');
	 FII_UTIL.put_line('Calling the CLEAN_REC_AGING procedure to delete from fii_ar_aging_receivables');
	 FII_UTIL.put_line('-------------------------------------------------');
	end if;
	CLEAN_REC_AGING;

	if g_debug_flag = 'Y' then
	 FII_UTIL.put_line('-------------------------------------------------');
	 FII_UTIL.put_line('Calling the POPULATE_INCREMENTAL_IDS procedure');
	 FII_UTIL.put_line('-------------------------------------------------');
	end if;
  	POPULATE_INCREMENTAL_IDS;

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_RECEIVABLES_AGING');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;
    Inc_RECEIVABLES_AGING;

	----------------------------------------------------------
	---------- Inc load of FII_AR_AGING_RECEIPTS--------------
	----------------------------------------------------------
	if g_debug_flag = 'Y' then
	   FII_UTIL.put_line('-------------------------------------------------');
	   FII_UTIL.put_line('Calling the CLEAN_RCT_AGING procedure to delete from fii_ar_aging_receipts');
	   FII_UTIL.put_line('-------------------------------------------------');
    end if;
 	CLEAN_RCT_AGING;

    if g_debug_flag = 'Y' then
	   FII_UTIL.put_line('-------------------------------------------------');
	   FII_UTIL.put_line('Calling the POPULATE_INCREMENTAL_RCT_IDS procedure');
	   FII_UTIL.put_line('-------------------------------------------------');
    end if;
	POPULATE_INCREMENTAL_RCT_IDS;

    if g_debug_flag = 'Y' then
	       FII_UTIL.put_line('-------------------------------------------------');
	       FII_UTIL.put_line('Calling procedure Inc_RECEIPTS_AGING');
	       FII_UTIL.put_line('-------------------------------------------------');
    end if;
	Inc_RECEIPTS_AGING;

  ----------------------------------------------------------
  ---------- Inc load of FII_AR_AGING_DISPUTES--------------
  ----------------------------------------------------------
  if g_debug_flag = 'Y' then
	   FII_UTIL.put_line('-------------------------------------------------');
	   FII_UTIL.put_line('Calling the CLEAN_DISP_AGING procedure to delete from fii_ar_aging_disputes');
	   FII_UTIL.put_line('-------------------------------------------------');
  end if;
  CLEAN_DISP_AGING;

  if g_debug_flag = 'Y' then
	   FII_UTIL.put_line('-------------------------------------------------');
	   FII_UTIL.put_line('Calling the POPULATE_INCREMENTAL_DISP_IDS procedure');
	   FII_UTIL.put_line('-------------------------------------------------');
  end if;
  POPULATE_INCREMENTAL_DISP_IDS;

  if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure Inc_DISPUTES_AGING');
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('');
  end if;
  Inc_DISPUTES_AGING;


    g_state := 'Logging program sysdate as ar_last_update_date in fii_change_log table';

    INSERT INTO fii_change_log
    (log_item, item_value, CREATION_DATE, CREATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
    (SELECT 'AR_LAST_UPDATE_DATE',
            to_char(g_sysdate_time,'MM/DD/YYYY HH24:MI:SS'),
            sysdate,        --CREATION_DATE,
            g_fii_user_id,  --CREATED_BY,
            sysdate,        --LAST_UPDATE_DATE,
            g_fii_user_id,  --LAST_UPDATED_BY,
            g_fii_login_id  --LAST_UPDATE_LOGIN
     FROM DUAL
     WHERE NOT EXISTS
        (select 1 from fii_change_log
         where log_item = 'AR_LAST_UPDATE_DATE'));

    IF (SQL%ROWCOUNT = 0) THEN
        UPDATE fii_change_log
        SET item_value = to_char(g_sysdate_time,'MM/DD/YYYY HH24:MI:SS'),
            last_update_date  = g_sysdate_time,
            last_update_login = g_fii_login_id,
            last_updated_by   = g_fii_user_id
        WHERE log_item = 'AR_LAST_UPDATE_DATE';
    END IF;

    delete from FII_AR_RECEIPTS_DELETE_T
    where CREATION_DATE <= g_sysdate_time;

  END IF;

  COMMIT;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('return code is ' || retcode);
  end if;

  g_retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    g_retcode:= -1;
    retcode := g_retcode;
    g_exception_msg  := g_retcode || ':' || g_errbuf;
    if g_debug_flag = 'Y' then
        FII_UTIL.put_line('Error occured while: ' || g_state);
    end if;
    FII_UTIL.put_line(g_exception_msg);

    -- dbms_output.put_line('Error occured while: ' || g_state);
    -- dbms_output.put_line('Error Message: ' || g_exception_msg);

END Inc_Extraction;

FUNCTION Delete_CashReceipt_Sub (
  p_subscription_guid IN RAW,
  p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2 IS
  l_key  VARCHAR2(240);
  l_pos  NUMBER;
  l_id   VARCHAR2(240);
BEGIN
  l_key := p_event.GetEventKey();
  -- l_pos := instr(l_key, '_');
  -- l_id  := substr(l_key, 1, l_pos - 1);
  insert into FII_AR_RECEIPTS_DELETE_T (
    EVENT_KEY,
    CASH_RECEIPT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  values(
    l_key,
    0, -- to_number(l_id),
    sysdate,
    111,
    sysdate,
    111,
    111
  );
  -- commit;
  return 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    return 'ERROR';
END Delete_CashReceipt_Sub;

END FII_AR_FACTS_AGING_PKG;


/
