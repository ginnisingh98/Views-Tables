--------------------------------------------------------
--  DDL for Package Body FV_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_UTILITY" AS
--$Header: FVXUTL1B.pls 120.18.12010000.6 2010/01/06 20:29:58 snama ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;
  g_current_level NUMBER ;

  TYPE typ_flex_acct IS TABLE OF varchar2(150) INDEX BY BINARY_INTEGER;

  g_flex_acct typ_flex_acct ;
  l_flex_acct typ_flex_acct ;
  g_l_index NUMBER := 0;

  PROCEDURE message
  (
    p_level   IN NUMBER DEFAULT NULL,
    p_module  IN VARCHAR2 DEFAULT NULL,
    p_pop     IN BOOLEAN DEFAULT FALSE
  ) IS
    l_level    NUMBER ;
    l_module   VARCHAR2(2000) ;
  BEGIN
     IF p_level IS NULL THEN
        l_level :=  fnd_log.LEVEL_ERROR ;
     ELSE
	l_level := p_level;
     END IF;

     IF  p_module IS NULL THEN
        l_module := 'fv.plsql.';
     ELSE
	l_module := p_module;
     END IF;

    IF (l_level >= g_current_level) THEN
      fnd_log.message (l_level, l_module, p_pop);
    END IF;
  END;

  PROCEDURE message
  (
    p_module  IN VARCHAR2 DEFAULT NULL,
    p_level   IN NUMBER DEFAULT NULL,
    p_pop     IN BOOLEAN DEFAULT FALSE
  ) IS
    l_level    NUMBER ;
    l_module   VARCHAR2(2000) ;
  BEGIN

     IF p_level IS NULL THEN
        l_level :=  fnd_log.LEVEL_ERROR ;
     ELSE
        l_level := p_level;
     END IF;

     IF  p_module IS NULL THEN
        l_module := 'fv.plsql.';
     ELSE
        l_module := p_module;
     END IF;

    IF (l_level >= g_current_level) THEN
      fnd_log.message (l_level, l_module, p_pop);
    END IF;
  END;

  PROCEDURE log_mesg
  (
    p_level   IN NUMBER,
    p_module  IN VARCHAR2,
    p_message IN VARCHAR2
  ) IS
  BEGIN
    IF (p_level >= g_current_level) THEN
      fnd_log.string (p_level, p_module, p_message);
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_message);
  END;

  PROCEDURE log_mesg
  (
    p_message IN VARCHAR2,
    p_module  IN VARCHAR2 DEFAULT NULL,
    p_level   IN NUMBER DEFAULT NULL
  ) IS

    l_level    NUMBER ;
    l_module   VARCHAR2(2000) ;
  BEGIN

     IF p_level IS NULL THEN
        l_level := fnd_log.LEVEL_STATEMENT;
     ELSE
        l_level := p_level;
     END IF;

     IF  p_module IS NULL THEN
        l_module := 'fv.plsql.';
     ELSE
        l_module := p_module;
     END IF;

    log_mesg (l_level, l_module, p_message);
  END;

  PROCEDURE debug_mesg
  (
    p_level   IN NUMBER,
    p_module  IN VARCHAR2,
    p_message IN VARCHAR2
  ) IS
  BEGIN
   IF p_level >=  fnd_log.LEVEL_STATEMENT  THEN
    fnd_log.string (p_level, p_module, p_message);
   END IF;
  END;


  PROCEDURE debug_mesg
  (
    p_message IN VARCHAR2,
    p_module  IN VARCHAR2 DEFAULT NULL,
    p_level   IN NUMBER DEFAULT  NULL
  ) IS
    l_level    NUMBER ;
    l_module   VARCHAR2(2000);


  BEGIN
     IF p_level IS NULL THEN
        l_level := fnd_log.LEVEL_STATEMENT;
     ELSE
        l_level := p_level;
     END IF;

     IF  p_module IS NULL THEN
        l_module := 'fv.plsql.';
     ELSE
        l_module := p_module;
     END IF;
    IF (p_level >= g_current_level) THEN
      debug_mesg (l_level, l_module, p_message);
    END IF;
  END;


--  Time Stamp Function - returns date and time
  function TIME_STAMP return varchar2
  IS
    l_module_name VARCHAR2(200) ;
    l_errbuf VARCHAR2(1024);
    l_time varchar2(25);
  BEGIN
     l_module_name  := g_module_name || 'TIME_STAMP';

    SELECT to_char(SYSDATE, 'MM/DD/YYYY HH:MM:SS')
    INTO l_time
    FROM dual;

    RETURN (l_time);
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;

  END;

----------------------------------------------------------------------------

PROCEDURE GET_LEDGER_INFO (p_org_id in number ,
                           p_ledger_id out nocopy varchar2,
                           p_coa_id    out nocopy varchar2,
                           p_currency  out nocopy varchar2,
			   p_status    out nocopy varchar2) is

  l_ledger_name gl_ledgers_public_v.name%type;

  BEGIN

 iF (p_org_id IS NOT NULL) THEN

     mo_utils.get_ledger_info(p_org_id,p_ledger_id,l_ledger_name);

        if (p_ledger_id is not null) then
               select chart_of_accounts_id,currency_code into p_coa_id , p_currency
               from gl_ledgers_public_v
               where ledger_id = p_ledger_id;
               p_status := 0;
        End if;
  else
   p_status := 1;
  End if;

  EXCEPTION
    when no_data_found then
     p_status := 1;
    when others  then
     p_status := 1;
  End ;

 -------------------------------------------------------------------------------------


-- Procedure used to retrieve FV context variable values.
-- User_id is current fnd_global.userid
-- resp_id is the current fnd_global.resp_id (responsibility_id)
-- Variable value should be
--      CHART_OF_ACCOUNTS_ID to obtain chart_of_accounts_id context variable,
--      ACCT_SEGMENT to obtain acct_segment name context variable,
--      BALANCE_SEGMENT to obtain balance_segment name context variable
-- Returned is the value for the  context variable specified above.
-- Returned variable values are all varchar2.
-- Error_code is a boolean which will be FALSE if NO errors are found and
-- TRUE if errors are raised during processing.  Error_message will only
-- contain an error message if error_code is TRUE.
--
PROCEDURE get_context(user_id              IN number,
                       resp_id              IN number,
		       variable_type        IN varchar2,
                       variable_value       OUT NOCOPY varchar2,
		       error_code	    OUT NOCOPY boolean,
		       error_message	    OUT NOCOPY varchar2) IS
    l_module_name VARCHAR2(200) ;
 x_appl_id number;
 no_data_exception EXCEPTION;
BEGIN
l_module_name   := g_module_name || 'get_context';


  error_code := FALSE;

  fnd_profile.get('RESP_APPL_ID',x_appl_id);

  -- initialize the FV Context
  fnd_global.apps_initialize(user_id,resp_id,8901);


  -- retrieving the context variables for the specified type
   variable_value := sys_context('FV_CONTEXT',variable_type);

   fnd_global.apps_initialize(user_id, resp_id, x_appl_id);
   IF variable_value is null THEN
      raise no_data_exception;
   END IF;

EXCEPTION
   WHEN no_data_exception THEN
     error_code := TRUE;
     error_message := ('No data found for this FV Context Variable '||variable_type);
     LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception',error_message);

   WHEN others THEN
      error_code := TRUE;
      error_message := 'Error in retrieving FV Context Variables for '||variable_type||' - '||sqlerrm;
      LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',error_message);

END get_context;

---added GET  REPORT  INFO PROCEDURE
PROCEDURE GET_REPORT_INFO(
  p_request_id            IN  NUMBER,
  p_report_id             OUT NOCOPY NUMBER,
  p_report_set            OUT NOCOPY VARCHAR2,
  p_responsibility        OUT NOCOPY VARCHAR2,
  p_application           OUT NOCOPY VARCHAR2,
  p_request_time          OUT NOCOPY DATE,
  p_resub_interval        OUT NOCOPY VARCHAR2,
  p_run_time              OUT NOCOPY DATE,
  p_printer               OUT NOCOPY VARCHAR2,
  p_copies                OUT NOCOPY NUMBER,
  p_save_output           OUT NOCOPY VARCHAR2 )

AS
    l_module_name VARCHAR2(200) ;
    l_errbuf VARCHAR2(1024);
	v_report_id             NUMBER(15);
        v_responsibility        VARCHAR2(240);
        v_application           VARCHAR2(240);
        v_request_time          DATE;
        v_resub_interval        VARCHAR2(100);
        v_run_time              DATE;
        v_printer               VARCHAR2(30);
        v_copies                NUMBER(15);
        v_so_flag               VARCHAR2(1);
        v_save_output           VARCHAR2(10);
        v_parent_id             NUMBER(15);
        v_request_type          VARCHAR2(1);
        v_description           VARCHAR2(100);

        CURSOR c_get_info	IS
	SELECT fcr.concurrent_program_id,
               fcr.parent_request_id,
               fr.responsibility_name,
               fa.description,
               fcr.requested_start_date,
               TO_CHAR(fcr.RESUBMIT_INTERVAL)||' '||fcr.RESUBMIT_INTERVAL_UNIT_CODE,
               fcr.actual_start_date,
               fcr.printer,
               fcr.number_of_copies,
               fcr.save_output_flag
        FROM   FND_CONCURRENT_REQUESTS FCR,
               FND_APPLICATION_VL FA,
               FND_RESPONSIBILITY_VL FR
	WHERE  fcr.responsibility_id = fr.responsibility_id
          AND  fcr.program_application_id = fa.application_id
          and  fcr.request_id = p_request_id;

       CURSOR c_get_rs (cp_parent_id 		fnd_concurrent_requests.parent_request_id%TYPE) IS
		SELECT	parent_request_id,
                        request_type, description
		FROM	fnd_concurrent_requests
		WHERE	request_id = cp_parent_id;


BEGIN

 l_module_name := g_module_name || 'GET_REPORT_INFO';
        OPEN c_get_info;

        FETCH c_get_info
         INTO v_report_id,
              v_parent_id,
              v_responsibility,
              v_application,
              v_request_time,
              v_resub_interval,
              v_run_time,
              v_printer,
              v_copies,
              v_so_flag;
        CLOSE c_get_info;


       IF
           v_so_flag = 'Y'
       THEN
           v_save_output := 'YES';
       ELSE
           v_save_output  := 'NO';

       END IF;

       v_description  := '';
       v_request_type := '';

       IF  v_parent_id > 0
       THEN
           OPEN c_get_rs (v_parent_id);
           FETCH c_get_rs
             INTO v_parent_id,v_request_type,v_description;
           CLOSE c_get_rs;

           IF v_request_type = 'S'
           THEN
               OPEN c_get_rs (v_parent_id);
               FETCH c_get_rs
                 INTO  v_parent_id,v_request_type,v_description;
              CLOSE c_get_rs;
           END IF;

           IF v_request_type = 'M'
           THEN
              p_report_set    :=  v_description;
           END IF;
       END IF;

       p_report_id      :=  v_report_id;
       p_responsibility :=  v_responsibility;
       p_application    :=  v_application;
       p_request_time   :=  v_request_time;
       p_resub_interval :=  v_resub_interval;
       p_run_time       :=  v_run_time;
       p_printer        :=  v_printer;
       p_copies         :=  v_copies;
       p_save_output    :=  v_save_output;


EXCEPTION
       WHEN OTHERS THEN
         l_errbuf := SQLERRM;
	       Fnd_Message.Set_Name('FV','FV_DC_GENERAL');
	       FND_MESSAGE.SET_TOKEN('MSG','UNHANDLED EXCEPTION IN GETTING REPORT INFORMATION');
         LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
         MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception');

       	       App_Exception.Raise_Exception;

END GET_REPORT_INFO;

--
-- This procedure should be called to determine the Organization Name for a
-- NON-Multiorg Database only.  If an error occurs error_code will be TRUE
-- and error_message will contain the error message.  Please check in
-- the calling process.
--
PROCEDURE GET_ORG_INFO(v_set_of_books_id IN NUMBER,
                       v_organization_name OUT NOCOPY VARCHAR2,
                       error_code OUT NOCOPY BOOLEAN,
                       error_message OUT NOCOPY VARCHAR2) IS

    l_module_name VARCHAR2(200) ;
BEGIN

  l_module_name  := g_module_name || 'GET_ORG_INFO';



     select substr(legal_entity_name,1,60)
     into v_organization_name
     from GL_LEDGER_LE_V
     where ledger_id =  v_set_of_books_id
     and rownum = 1
     order by  legal_entity_name;

   error_code := FALSE;
   error_message := null;

EXCEPTION
   when others then
     error_code := TRUE;
     error_message := 'Error in FV_UTILTIY.GET_ORG_INFO -'||sqlerrm;
     LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',error_message);

END get_org_info;

Procedure gl_get_first_period(tset_of_books_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
				errbuf	   	 OUT NOCOPY VARCHAR2)
  IS
    l_module_name VARCHAR2(200) ;

  BEGIN

  l_module_name := g_module_name || 'gl_get_first_period';


    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = 101
    AND     b.application_id = 101
    AND     a.ledger_id = tset_of_books_id
    AND     b.ledger_id = tset_of_books_id
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     b.period_name = tperiod_name
    AND     a.period_num =
           (SELECT min(c.period_num)
              FROM gl_period_statuses c
             WHERE c.application_id = 101
               AND c.ledger_id = tset_of_books_id
               AND c.period_year = a.period_year
               AND c.period_type = a.period_type
          GROUP BY c.period_year);

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	errbuf := gl_message.get_message('GL_PLL_INVALID_FIRST_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'SOBID', tset_of_books_id);
  LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception',errbuf);

  WHEN OTHERS THEN

	errbuf := SQLERRM;
  LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

  END;

-------------------------------------------------------------------------------
PROCEDURE get_segment_col_names(chart_of_accounts_id	IN	NUMBER,
				acct_seg_name		OUT NOCOPY	VARCHAR2,
				balance_seg_name	OUT NOCOPY	VARCHAR2,
				error_code		OUT NOCOPY	BOOLEAN,
				error_message		OUT NOCOPY	VARCHAR2) IS
   l_module_name VARCHAR2(200) := g_module_name || 'get_segment_col_names';
   l_errbuf      VARCHAR2(1024);

   num_boolean BOOLEAN;
   apps_id     NUMBER := 101;
   flex_code   VARCHAR2(25) := 'GL#';
   flex_num    NUMBER;
   invalid_acct_segment_error EXCEPTION;
   invalid_bal_segment_error EXCEPTION;

 BEGIN

 error_code := FALSE;
 error_message := null;

 flex_num := chart_of_accounts_id;

 num_boolean := FND_FLEX_APIS.GET_SEGMENT_COLUMN(apps_id,flex_code,flex_num,
                     'GL_ACCOUNT',acct_seg_name);

 IF(num_boolean) THEN
         null;
 ELSE
         raise invalid_acct_segment_error;
 END IF;

 acct_seg_name := upper(acct_seg_name);

 num_boolean := FND_FLEX_APIS.GET_SEGMENT_COLUMN(apps_id,flex_code,flex_num,
                        'GL_BALANCING',balance_seg_name);

 IF(num_boolean) THEN
         null;
 ELSE
         raise invalid_bal_segment_error;
 END IF;

 balance_seg_name := upper(balance_seg_name);

 EXCEPTION
   WHEN invalid_acct_segment_error THEN
     l_errbuf := SQLERRM;
     error_code := TRUE;
     error_message := 'Error in FV_UTILTIY.GET_SEGMENT_COL_NAMES - '||l_errbuf;
     LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception1',l_errbuf);
     LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception1','Error in FV_CONTEXT_PKG.GET_SEGMENT_COL_NAMES: Cannot read Account Segment Information');
     RAISE_APPLICATION_ERROR(-20002,'Error in FV_CONTEXT_PKG.GET_SEGMENT_COL_NAMES: Cannot read Account Segment Information');

   WHEN invalid_bal_segment_error THEN
     l_errbuf := SQLERRM;
     error_code := TRUE;
     error_message := 'Error in FV_UTILTIY.GET_SEGMENT_COL_NAMES - '||l_errbuf;
     LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception1',l_errbuf);
     LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception1','Error in FV_CONTEXT_PKG.GET_SEGMENT_COL_NAMES: Cannot read Balancing Segment Information');
     RAISE_APPLICATION_ERROR(-20002,'Error in FV_CONTEXT_PKG.GET_SEGMENT_COL_NAMES: Cannot read Account Segment Information');

   WHEN others THEN
     l_errbuf := SQLERRM;
     error_code := TRUE;
     error_message := 'Error in FV_UTILTIY.GET_SEGMENT_COL_NAMES - '||l_errbuf;
     LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception2',l_errbuf);
     RAISE_APPLICATION_ERROR(-20003,'Error in FV_CONTEXT_PKG.GET_SEGMENT_COL_NAMES: '||l_errbuf);

END get_segment_col_names;

PROCEDURE calc_child_flex_value (p_flex_value_set_id IN NUMBER, p_parent_flex_value IN VARCHAR2)
IS

CURSOR c_child_flex_value IS
SELECT flex_value, summary_flag, flex_value_set_id, parent_flex_value
    FROM fnd_flex_value_children_v
   WHERE (flex_value_set_id = p_flex_value_set_id) AND (parent_flex_value = p_parent_flex_value)
ORDER BY flex_value;

l_index NUMBER;
l_flag BOOLEAN;
l_module_name VARCHAR2(200) := g_module_name || 'calc_child_flex_value';
l_errbuf      VARCHAR2(1024);

BEGIN

  l_flag := FALSE;

  FOR l_child_flex_value in c_child_flex_Value
  LOOP
    IF (l_child_flex_value.summary_flag = 'N') THEN
        IF NOT (g_l_index = 0 ) THEN
          FOR l_index IN g_flex_acct.first..g_flex_acct.last
          LOOP
            IF (l_child_flex_value.flex_value = g_flex_acct(l_index)) THEN
              l_flag := TRUE;
              exit;
            END IF;
          END LOOP;
        END IF;
        IF NOT l_flag THEN
          g_flex_acct(g_l_index):= l_child_flex_value.flex_value;
          g_l_index := g_l_index + 1;
        END IF;
    ELSIF (l_child_flex_value.summary_flag = 'Y') THEN
        calc_child_flex_value(p_flex_value_set_id, l_child_flex_value.flex_value);
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',l_errbuf);
END calc_child_flex_value;

FUNCTION calc_concat_accts(p_flex_value IN VARCHAR2,
                           p_coa_id IN NUMBER)
RETURN VARCHAR2 IS

CURSOR c_flex_value IS
SELECT flexvalue.flex_value, flexvalue.summary_flag, fndidflex.flex_value_set_id
  FROM fnd_segment_attribute_values fndseg,
       fnd_id_flex_segments_vl fndidflex,
       fnd_flex_values_vl flexvalue
 WHERE fndseg.id_flex_num = p_coa_id
   AND fndseg.segment_attribute_type = 'GL_ACCOUNT'
   AND fndseg.id_flex_code = 'GL#'
   AND fndseg.attribute_value = 'Y'
   AND fndseg.application_column_name = fndidflex.application_column_name
   AND fndidflex.id_flex_num = p_coa_id
   AND fndidflex.id_flex_code = 'GL#'
   AND fndidflex.flex_value_set_id = flexvalue.flex_value_set_id
   AND flexvalue.enabled_flag = 'Y'
   and flexvalue.flex_value = p_flex_value;
l_index NUMBER;
l_str VARCHAR2(4000);
l_module_name VARCHAR2(200) := g_module_name || 'calc_concat_accts';
l_errbuf      VARCHAR2(1024);
l_flex_value c_flex_value%ROWTYPE;

BEGIN
  g_flex_acct := l_flex_acct;
  g_l_index := 0;
  OPEN c_flex_value;
  FETCH c_flex_value INTO l_flex_value;
  CLOSE c_flex_value;
  IF (l_flex_value.summary_flag = 'N') THEN
    RETURN l_flex_value.flex_value;
  END IF;

  calc_child_flex_value(l_flex_value.flex_value_set_id,l_flex_value.flex_value);
  FOR l_index IN g_flex_acct.first..g_flex_acct.last
  LOOP
    IF l_str IS NULL THEN
      l_str := g_flex_acct(l_index);
    ELSE
      l_str := l_str || ', ' || g_flex_acct(l_index);
    END IF;
  END LOOP;
RETURN l_str;

EXCEPTION
  WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',l_errbuf);
     RETURN NULL;
END  calc_concat_accts;
----------------------------------------------------------------------------

PROCEDURE Get_Period_Year(period_from 		VARCHAR2,
			period_to		VARCHAR2,
			sob_id			NUMBER,
			period_start_date OUT NOCOPY DATE,
			period_end_date OUT NOCOPY DATE,
			period_year     OUT NOCOPY NUMBER,
			errbuf	 OUT NOCOPY VARCHAR2,
			retcode	 OUT NOCOPY 	NUMBER)  IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_Period_Year';
	vl_period_set_name Gl_Periods.period_set_name%TYPE;
BEGIN
   BEGIN
	SELECT 	period_set_name
	INTO	vl_period_set_name
	FROM 	Gl_Sets_Of_Books
	WHERE	set_of_books_id	= sob_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    retcode := 2;
	    errbuf  := 'Period Set name not found for set of books '||to_char(sob_id);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found',errbuf);
            RETURN ;
	WHEN OTHERS THEN
            retcode := SQLCODE ;
            errbuf  := SQLERRM  ||
                ' -- Error in Get_Period_Year procedure,while getting the period set name.' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1',errbuf);
            RETURN ;
   END;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD SET NAME IS '||VL_PERIOD_SET_NAME);
   END IF;

   BEGIN
	SELECT 	period_year
	INTO	period_year
	FROM 	Gl_Periods
	WHERE	period_set_name = vl_period_set_name
	AND	period_name	= period_from;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
            retcode := 2;
            errbuf  := 'Period Year not found for the set of books '||to_char(sob_id) ||
		' and the period set name '||vl_period_set_name;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found1',errbuf);
            RETURN ;

	WHEN OTHERS THEN
            retcode := SQLCODE ;
            errbuf  := SQLERRM  ||
                ' -- Error in Get_Period_Year procedure,while getting the period year.' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception2',errbuf);
            RETURN ;
   END;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD YEAR IS '||TO_CHAR(PERIOD_YEAR));
 END IF;

   BEGIN	/* From Period Start Date */
	SELECT start_date
	INTO	period_start_date
	FROM	Gl_Period_Statuses
	WHERE	ledger_id = sob_id
	AND	application_id = 101
	AND	period_year = period_year
	AND	period_name = period_from
	AND     adjustment_period_flag = 'N';
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
            retcode := 2;
            errbuf  := 'Start Date not defined for the period name '||period_from;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found2',errbuf);
            RETURN ;

        WHEN OTHERS THEN
            retcode := SQLCODE ;
            errbuf  := SQLERRM  ||
                ' -- Error in Get_Period_Year procedure,while getting the start date for the from period '||period_from ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception3',errbuf);
            RETURN ;
   END;		/* From Period Start Date */
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD START DATE IS '||TO_CHAR(PERIOD_START_DATE));
 END IF;

   BEGIN        /* To Period End Date */
        SELECT end_date
        INTO    period_end_date
        FROM    Gl_Period_Statuses
        WHERE   ledger_id = sob_id
        AND     application_id = 101
        AND     period_year = period_year
        AND     period_name = period_to
	AND     adjustment_period_flag = 'N';
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retcode := 2;
            errbuf  := 'End Date not defined for the period name '||period_to;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found3',errbuf);
            RETURN ;

        WHEN OTHERS THEN
            retcode := SQLCODE ;
            errbuf  := SQLERRM  ||
                ' -- Error in Get_Period_Year procedure,while getting the end date for the to period '||period_to ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception4',errbuf);
            RETURN ;
   END;         /* To Period End Date */
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'       PERIOD END DATE IS '||TO_CHAR(PERIOD_END_DATE));
 END IF;

   -- Setting up the retcode
   retcode := 0;
EXCEPTION
  WHEN OTHERS THEN
    retcode := SQLCODE;
    errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RETURN;

END Get_Period_Year;

  FUNCTION tin
  (
    p_vendor_type_lookup_code IN VARCHAR2,
    p_org_type_lookup_code    IN VARCHAR2,
    p_num_1099                IN VARCHAR2,
    p_individual_1099         IN VARCHAR2,
    p_employee_id             IN NUMBER
  )
  RETURN VARCHAR2
  IS
    l_tin VARCHAR2(100);
    l_module_name VARCHAR2(200);
    l_errbuf VARCHAR2(1024);
  BEGIN
    l_module_name := g_module_name || 'tin';
    IF (p_vendor_type_lookup_code = 'EMPLOYEE') THEN
      BEGIN
        SELECT papf.national_identifier
          INTO l_tin
          FROM per_all_people_f papf
         WHERE person_id = p_employee_id
           AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_tin := NVL(p_num_1099, p_individual_1099);
      END;
    ELSIF(p_vendor_type_lookup_code = 'CONTRACTOR') THEN
      IF (p_org_type_lookup_code IN ('INDIVIDUAL', 'FOREIGN INDIVIDUAL', 'PARTNERSHIP', 'FOREIGN PARTNERSHIP')) THEN
        l_tin := p_individual_1099;
      ELSE
        l_tin := p_num_1099;
      END IF;
    ELSE
      l_tin := NVL(p_num_1099, p_individual_1099);
    END IF;
    RETURN l_tin;
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception',l_errbuf);
      RAISE;
  END;

---------------------------------------------------------------
  PROCEDURE get_accrual_account
  (
    p_wf_item_type IN VARCHAR2,
    p_wf_item_key IN VARCHAR2,
    p_new_accrual_ccid OUT NOCOPY NUMBER
  )  IS

  l_module VARCHAR2(200) := g_module_name||'get_accrual_account.';
  l_default_accrual_acct_id NUMBER;
  l_result BOOLEAN;
  l_chart_of_accounts_id NUMBER;
  l_account_segment_num NUMBER;
  l_no_of_segments NUMBER;
  l_charge_ccid_segs fnd_flex_ext.segmentarray;
  l_def_accrual_ccid_segs fnd_flex_ext.segmentarray;
  l_org_id NUMBER;
  l_ledger_id NUMBER;
  l_ledger_name gl_ledgers.name%TYPE;
  l_charge_account_ccid NUMBER;



  BEGIN

    log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'BEGIN');
    log_mesg(fnd_log.LEVEL_STATEMENT,l_module,'p_wf_item_type: '||p_wf_item_type);
    log_mesg(fnd_log.LEVEL_STATEMENT,l_module,'p_wf_item_key: '||p_wf_item_key);

    -- get the default accrual_account_ccid from po_system_parameters
    BEGIN

        SELECT accrued_code_combination_id
        INTO l_default_accrual_acct_id
        FROM po_system_parameters;

        log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'l_default_accrual_acct_id: '
                 ||l_default_accrual_acct_id);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'No default accrual account found in po system parameters!');
        WHEN OTHERS THEN
          log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'When others error: '||sqlerrm);
    END;

    -- get the charge account ccid from workflow
    l_charge_account_ccid := wf_engine.GetItemAttrNumber
                           (
                             itemtype => p_wf_item_type,
                             itemkey => p_wf_item_key,
                             aname => 'CODE_COMBINATION_ID'
                            );

    IF l_charge_account_ccid IS NULL THEN
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Charge account ccid is null!');
       RETURN;
      ELSE
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Charge account ccid is: '||l_charge_account_ccid);
    END IF;


    -- get the chard of accounts id from workflow
    l_chart_of_accounts_id := wf_engine.GetItemAttrNumber
                           (
                             itemtype => p_wf_item_type,
                             itemkey => p_wf_item_key,
                             aname => 'CHART_OF_ACCOUNTS_ID'
                           );

    IF l_chart_of_accounts_id IS NULL THEN
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Chart of accounts id is null!');
       RETURN;
      ELSE
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Chart of accounts id: '||l_chart_of_accounts_id);
    END IF;

    l_result := fnd_flex_apis.get_qualifier_segnum
                (
                  appl_id          => 101,
			            key_flex_code    => 'GL#',
			            structure_number => l_chart_of_accounts_id,
			            flex_qual_name   => 'GL_ACCOUNT',
			            segment_number   => l_account_segment_num
                );
    IF l_result THEN
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Accounting segment number: '||l_account_segment_num);
     ELSE
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Could not get Accounting segment from coa id: '
               ||l_chart_of_accounts_id);
      RETURN;
    END IF;

    --Get the segments from the po charge ccid
    l_result := fnd_flex_ext.get_segments
                (
                  application_short_name  => 'SQLGL',
                  key_flex_code           => 'GL#',
                  structure_number        => l_chart_of_accounts_id,
                  combination_id          => l_charge_account_ccid,
                  n_segments              => l_no_of_segments,
                  segments                => l_charge_ccid_segs
                );

    IF NOT l_result THEN
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Could not get segments for po charge ccid: '||l_charge_account_ccid);
      RETURN;
    END IF;

    --Get the segments from the default accrual ccid
    l_result := fnd_flex_ext.get_segments
                (
                  application_short_name  => 'SQLGL',
                  key_flex_code           => 'GL#',
                  structure_number        => l_chart_of_accounts_id,
                  combination_id          => l_default_accrual_acct_id,
                  n_segments              => l_no_of_segments,
                  segments                => l_def_accrual_ccid_segs
                );

    IF NOT l_result THEN
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Could not get segments for default accrual ccid: '||l_default_accrual_acct_id);
      RETURN;
    END IF;

    --Set the accounting segment of default accrual to the charge account
    log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Replacing charge account segment with that from default account');
    l_charge_ccid_segs(l_account_segment_num) := l_def_accrual_ccid_segs(l_account_segment_num);

    -- validate this segment combination and get ccid
    -- flex API will create combination if it does not exist
    l_result := fnd_flex_ext.get_combination_id
                (
                  application_short_name => 'SQLGL',
                  key_flex_code          => 'GL#',
                  structure_number       => l_chart_of_accounts_id,
                  validation_date        => sysdate,
                  n_segments             => l_no_of_segments,
                  segments               => l_charge_ccid_segs,
                  combination_id         => p_new_accrual_ccid
                );

    IF l_result THEN
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'New accrual ccid: '||p_new_accrual_ccid);
     ELSE
       log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Could not create new default charge account!');
      RETURN;
    END IF;

    log_mesg(fnd_log.LEVEL_STATEMENT, l_module,  'END');
   EXCEPTION WHEN OTHERS THEN
       log_mesg(fnd_log.LEVEL_UNEXPECTED, l_module, 'When others error: '||SQLERRM);
  END get_accrual_account;

---------------------------------------------------------------
/*-------------------------------------------------------------
 *Procedure to delete orphan BC events.
 *Called from psa_ap_bc_pvt.delete_events.
 *Returns 'S' for success and 'E' for error.
 *
 *-----------------------------------------------------------*/
  PROCEDURE delete_fv_bc_orphan
  ( p_ledger_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_status OUT NOCOPY VARCHAR2
  )  IS

l_module VARCHAR2(200) := g_module_name||'delete_fv_bc_orphan.';
l_event_count NUMBER;
TYPE Event_tab_type IS TABLE OF XLA_EVENTS_INT_GT%rowtype
INDEX BY BINARY_INTEGER;
l_events_Tab           Event_tab_type;

CURSOR c_get_unprocessed_fv_events IS
   SELECT xte.transaction_number, xla.application_id, xla.event_id,
          xla.event_type_code,
          xla.event_date,
          xla.event_status_code,
          xla.process_status_code,
          xte.entity_id,
          xte.legal_entity_id,
          xte.entity_code,
          xte.source_id_int_1,
          xte.source_id_int_2,
          xte.source_id_int_3,
          xte.source_id_int_4,
          xte.source_id_char_1
   FROM xla_events xla,
        xla_transaction_entities xte
   WHERE NVL(xla.budgetary_control_flag, 'N') ='Y'
   AND   xla.application_id = 8901
   AND   xla.event_date BETWEEN p_start_date AND p_end_date
   AND   xla.event_status_code in ('U','I')
   AND   xla.process_status_code <> 'P'
   AND   xla.entity_id = xte.entity_id
   AND   xla.application_id = xte.application_id
   AND   xte.ledger_id =  p_ledger_id;

BEGIN
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'BEGIN');
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'Parameters: ');
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'p_ledger_id: '||p_ledger_id);
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'p_start_date: '||p_start_date);
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module, 'p_end_date: '||p_end_date);

      xla_security_pkg.set_security_context(8901);

      DELETE FROM XLA_EVENTS_INT_GT;
      log_mesg(fnd_log.LEVEL_STATEMENT, l_module,
                '# of rows deleted from xla_events_int_gt: '|| SQL%ROWCOUNT );
      fnd_file.put_line(fnd_file.log,
                '-------------------------------------------------------');
      fnd_file.put_line(fnd_file.log,'Deleting Federal events, if any.');
      l_event_count := 0;

      FOR rec_events IN c_get_unprocessed_fv_events
      LOOP
          l_event_count := l_event_count+1;
          l_events_tab(l_event_count).entity_id           := rec_events.entity_id;
          l_events_tab(l_event_count).application_id      := 8901;
          l_events_tab(l_event_count).ledger_id           := p_ledger_id;
          l_events_tab(l_event_count).legal_entity_id     := rec_events.legal_entity_id;
          l_events_tab(l_event_count).entity_code         := rec_events.entity_code;
          l_events_tab(l_event_count).event_id            := rec_events.event_id;
          l_events_tab(l_event_count).transaction_number  := rec_events.transaction_number;
          l_events_tab(l_event_count).event_status_code   := rec_events.event_status_code;
          l_events_tab(l_event_count).process_status_code := rec_events.process_status_code;
          l_events_tab(l_event_count).source_id_int_1     := rec_events.source_id_int_1;
      END LOOP;

      IF l_event_count > 0 THEN
       FORALL i IN 1..l_event_count
       INSERT INTO XLA_EVENTS_INT_GT
              VALUES l_events_tab(i) ;
       fnd_file.put_line(fnd_file.log,' # of rows inserted into xla_events_int_gt table: ' || l_event_count);
       fnd_file.put_line(fnd_file.log,'Calling XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENT ');

       XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENTS(p_application_id => 8901);

       fnd_file.put_line(fnd_file.log,'After Deletion of Federal Unprocessed Events');
       fnd_file.put_line(fnd_file.log,'The following Federal BC unprocessed/Error events have been deleted');
      fnd_file.put_line(fnd_file.log ,'Event ID  Event Status Code Process Status Code');
      fnd_file.put_line(fnd_file.log ,'--------- ----------------- -------------------');

       FOR i IN 1..l_event_count
        LOOP
         fnd_file.put_line(fnd_file.log ,l_events_tab(i).event_id||'        '||
                                         l_events_tab(i).event_status_code   ||' '||
                                         l_events_tab(i).process_status_code);



          --Update the event id of the BE row to null if the row exists.
          --If the row does not exist, it means that the user has deleted it from
          --the form.
          log_mesg(fnd_log.LEVEL_STATEMENT, l_module,
          'Updating event id: '||l_events_tab(i).event_id||' to NULL for related distributions.');
          UPDATE fv_be_trx_dtls
          SET    event_id = NULL
          WHERE  event_id = l_events_tab(i).event_id;

          log_mesg(fnd_log.LEVEL_STATEMENT, l_module,
            '# distributions in fv_be_trx_dtls that have been updated to NULL: '||SQL%ROWCOUNT);

        END LOOP;

       ELSE
         fnd_file.put_line(fnd_file.log,'**** No Federal events found to delete ****');
      END IF;
      p_status := 'S';

    log_mesg(fnd_log.LEVEL_STATEMENT, l_module,  'END');
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');
   EXCEPTION WHEN OTHERS THEN
       log_mesg(fnd_log.LEVEL_UNEXPECTED, l_module, 'When others error: '||SQLERRM);
       p_status := 'E';
END delete_fv_bc_orphan;
----------------------------------------------------------------------------------------

BEGIN
  g_module_name := 'FV_UTILITY.';
  g_current_level := fnd_log.g_current_runtime_level;

END; -- package body

/
