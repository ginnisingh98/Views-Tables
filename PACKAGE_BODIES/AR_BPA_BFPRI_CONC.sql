--------------------------------------------------------
--  DDL for Package Body AR_BPA_BFPRI_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_BFPRI_CONC" AS
/* $Header: ARBPBFBB.pls 120.5.12010000.4 2009/05/19 10:32:18 pbapna ship $ */

cr    		CONSTANT char(1) := '
';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

FUNCTION build_from_clause RETURN VARCHAR2 IS
from_clause VARCHAR2(1024);

BEGIN

/*Bug8486880 Added party_site,loc tables with where conditions*/

from_clause := '  FROM ' || cr ||
      '  ar_cons_inv                				 		 cons, ' || cr ||
      '  hz_cust_acct_sites_all                  a_bill, ' || cr ||
      '  hz_cust_site_uses_all                   u_bill, ' || cr ||
      '  hz_cust_accounts_all            				 cust, ' || cr ||
      '  hz_party_sites                          party_site, ' || cr ||
      '  hz_locations                            loc' || cr ||
      '  WHERE    ' || cr ||
      '  cust.cust_account_id                    = cons.customer_id ' || cr ||
      '  AND u_bill.site_use_id                  = cons.site_use_id ' || cr ||
      '  AND u_bill.org_id                       = cons.org_id  ' || cr ||
      '  AND a_bill.cust_acct_site_id            = u_bill.cust_acct_site_id   ' || cr ||
      '  AND a_bill.org_id                       = u_bill.org_id ' || cr ||
      '  AND a_bill.party_site_id                = party_site.party_site_id ' || cr ||
      '  AND  loc.location_id                    = party_site.location_id ' || cr ||
      '  AND cons.bill_level_flag in (' || '''A'', ''S'')' || cr ||
      '  AND cons.status <> ' || '''REJECTED'''  || cr ||
      '  AND u_bill.PRIMARY_FLAG = decode(bill_level_flag, '|| '''A'', ''Y'', u_bill.PRIMARY_FLAG) ';

return from_clause;

END;

PROCEDURE check_child_request(
       p_request_id            IN OUT  NOCOPY  NUMBER
      ) IS

call_status     boolean;
rphase          varchar2(80);
rstatus         varchar2(80);
dphase          varchar2(30);
dstatus         varchar2(30);
message         varchar2(240);

BEGIN
    call_status := fnd_concurrent.get_request_status(
                        p_request_id,
                        '',
                        '',
                        rphase,
                        rstatus,
                        dphase,
                        dstatus,
                        message);

    fnd_file.put_line( fnd_file.output, arp_standard.fnd_message('AR_BPA_PRINT_CHILD_REQ',
                                                    'REQ_ID',
                                                    p_request_id,
                                                    'PHASE',
                                                    dphase,
                                                    'STATUS',
                                                    dstatus));

    IF ((dphase = 'COMPLETE') and (dstatus = 'NORMAL')) THEN
        fnd_file.put_line( fnd_file.log, 'child request id: ' || p_request_id || ' complete successfully');
    ELSE
        fnd_file.put_line( fnd_file.log, 'child request id: ' || p_request_id || ' did not complete successfully');
    END IF;

END;

FUNCTION submit_print_request(
       p_parent_request_id            IN     NUMBER,
       p_worker_id                    IN     NUMBER,
       p_order_by                     IN     VARCHAR2,
       p_template_id                  IN     NUMBER,
       p_stamp_flag										IN     VARCHAR2,
       p_child_template_id            IN     NUMBER,
       p_nls_lang                     IN     VARCHAR2,
       p_nls_territory                IN     VARCHAR2,
       p_sub_request_flag             IN     BOOLEAN,
       p_description		      IN     VARCHAR2 DEFAULT NULL
      ) RETURN NUMBER IS

l_options_ok  BOOLEAN;
m_request_id  NUMBER;

BEGIN

      l_options_ok := FND_REQUEST.SET_OPTIONS (
                      implicit      => 'NO'
                    , protected     => 'YES'
                    , language      => p_nls_lang
                    , territory     => p_nls_territory);
      IF (l_options_ok)
      THEN

        m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                  application   => 'AR'
                , program       => 'ARBPIPCP'
                , description   => p_description
                , start_time    => ''
                , sub_request   => p_sub_request_flag
                , argument1     => p_parent_request_id
                , argument2     => p_worker_id
                , argument3     => p_order_by
                , argument4     => p_template_id
                , argument5     => p_stamp_flag
                , argument6     => p_child_template_id
                , argument7     => 223
                , argument8     => chr(0)
                , argument9     => ''
                , argument10    => ''
                , argument11    => ''
                , argument12    => ''
                , argument13    => ''
                , argument14    => ''
                , argument15    => ''
                , argument16    => ''
                , argument17    => ''
                , argument18    => ''
                , argument19    => ''
                , argument20    => ''
                , argument21    => ''
                , argument22    => ''
                , argument23    => ''
                , argument24    => ''
                , argument25    => ''
                , argument26    => ''
                , argument27    => ''
                , argument28    => ''
                , argument29    => ''
                , argument30    => ''
                , argument31    => ''
                , argument32    => ''
                , argument33    => ''
                , argument34    => ''
                , argument35    => ''
                , argument36    => ''
                , argument37    => ''
                , argument38    => ''
                , argument39    => ''
                , argument40    => ''
                , argument41    => ''
                , argument42    => ''
                , argument43    => ''
                , argument44    => ''
                , argument45    => ''
                , argument46    => ''
                , argument47    => ''
                , argument48    => ''
                , argument49    => ''
                , argument50    => ''
                , argument51    => ''
                , argument52    => ''
                , argument53    => ''
                , argument54    => ''
                , argument55    => ''
                , argument56    => ''
                , argument57    => ''
                , argument58    => ''
                , argument59    => ''
                , argument61    => ''
                , argument62    => ''
                , argument63    => ''
                , argument64    => ''
                , argument65    => ''
                , argument66    => ''
                , argument67    => ''
                , argument68    => ''
                , argument69    => ''
                , argument70    => ''
                , argument71    => ''
                , argument72    => ''
                , argument73    => ''
                , argument74    => ''
                , argument75    => ''
                , argument76    => ''
                , argument77    => ''
                , argument78    => ''
                , argument79    => ''
                , argument80    => ''
                , argument81    => ''
                , argument82    => ''
                , argument83    => ''
                , argument84    => ''
                , argument85    => ''
                , argument86    => ''
                , argument87    => ''
                , argument88    => ''
                , argument89    => ''
                , argument90    => ''
                , argument91    => ''
                , argument92    => ''
                , argument93    => ''
                , argument94    => ''
                , argument95    => ''
                , argument96    => ''
                , argument97    => ''
                , argument98    => ''
                , argument99    => ''
                , argument100   => '');
   END IF;

   RETURN m_request_id;

END;

PROCEDURE build_where_clause(
    p_org_id  				 IN NUMBER DEFAULT NULL,
		p_cust_num_low     IN VARCHAR2 DEFAULT NULL,
		p_cust_num_high    IN VARCHAR2 DEFAULT NULL,
		p_bill_site_low    IN NUMBER DEFAULT NULL,
		p_bill_site_high   IN NUMBER DEFAULT NULL,
		p_bill_date_low    IN DATE DEFAULT NULL,
		p_bill_date_high   IN DATE DEFAULT NULL,
		p_bill_num_low   	 IN VARCHAR2 DEFAULT NULL,
		p_bill_num_high  	 IN VARCHAR2 DEFAULT NULL,
		p_request_id       IN NUMBER DEFAULT NULL,
		where_clause   		 OUT NOCOPY VARCHAR2) IS

BEGIN
   IF ( p_org_id is not null ) THEN
     where_clause :=where_clause || ' AND cons.org_id = :org_id ' || cr;
   END IF;

   IF ( (p_cust_num_low is not null) and (p_cust_num_high is null) ) THEN
     where_clause :=where_clause || ' AND cust.account_number = :cust_num_low ' || cr;
   ELSIF ( (p_cust_num_high is not null) and (p_cust_num_low is  null) ) THEN
     where_clause :=where_clause || ' AND cust.account_number = :cust_num_high '  || cr;
   ELSIF ( (p_cust_num_high is not null) and (p_cust_num_low is not null) ) THEN
     where_clause :=where_clause || ' AND cust.account_number >= :cust_num_low '  || cr;
     where_clause :=where_clause || ' AND cust.account_number <= :cust_num_high '  || cr;
   END IF;

   IF ( (p_bill_site_low is not null) and (p_bill_site_high is null) ) THEN
     where_clause :=where_clause || ' AND cons.site_use_id = :bill_site_low ' || cr;
   ELSIF ( (p_bill_site_high is not null) and (p_bill_site_low is  null) ) THEN
     where_clause :=where_clause || ' AND cons.site_use_id = :bill_site_high ' || cr;
   ELSIF ( (p_bill_site_high is not null) and (p_bill_site_low is not null) ) THEN
     where_clause :=where_clause || ' AND cons.site_use_id >= :bill_site_low ' || cr;
     where_clause :=where_clause || ' AND cons.site_use_id <= :bill_site_high ' || cr;
   END IF;

   where_clause :=where_clause || ' AND billing_date between nvl(:bill_date_low, billing_date) and nvl(:bill_date_high, billing_date) ' || cr;

   IF ( (p_bill_num_low is not null) and (p_bill_num_high is null) ) THEN
     where_clause :=where_clause || ' AND cons.cons_billing_number = :bill_num_low ' || cr;
   ELSIF ( (p_bill_num_high is not null) and (p_bill_num_low is  null) ) THEN
     where_clause :=where_clause || ' AND cons.cons_billing_number = :bill_num_high ' || cr;
   ELSIF ( (p_bill_num_low is not null) and (p_bill_num_high is not null) ) THEN
     where_clause :=where_clause || ' AND cons.cons_billing_number >= :bill_num_low ' || cr;
     where_clause :=where_clause || ' AND cons.cons_billing_number <= :bill_num_high ' || cr;
   END IF;

   IF ( p_request_id is not null ) THEN
      where_clause := where_clause || ' AND cons.concurrent_request_id = :concurrent_request_id ' || cr;
   END IF;

END BUILD_WHERE_CLAUSE;

PROCEDURE BIND_VARIABLES(
    p_org_id  				 IN NUMBER DEFAULT NULL,
		p_cust_num_low     IN VARCHAR2 DEFAULT NULL,
		p_cust_num_high    IN VARCHAR2 DEFAULT NULL,
		p_bill_site_low    IN NUMBER DEFAULT NULL,
		p_bill_site_high   IN NUMBER DEFAULT NULL,
		p_bill_date_low    IN DATE DEFAULT NULL,
		p_bill_date_high   IN DATE DEFAULT NULL,
		p_bill_num_low   	 IN VARCHAR2 DEFAULT NULL,
		p_bill_num_high  	 IN VARCHAR2 DEFAULT NULL,
		p_request_id       IN NUMBER DEFAULT NULL,
		cursor_name    		 IN INTEGER ) IS

BEGIN

   IF ( p_org_id is not null ) THEN
     dbms_sql.bind_variable( cursor_name, ':org_id', p_org_id) ;
   END IF;

   IF ( p_cust_num_low is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':cust_num_low', p_cust_num_low ) ;
   END IF;
   IF ( p_cust_num_high is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':cust_num_high', p_cust_num_high ) ;
   END IF;

   IF ( p_bill_site_low is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':bill_site_low', p_bill_site_low ) ;
   END IF;
   IF ( p_bill_site_high is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':bill_site_high', p_bill_site_high ) ;
   END IF;

   dbms_sql.bind_variable( cursor_name, ':bill_date_low', p_bill_date_low ) ;
   dbms_sql.bind_variable( cursor_name, ':bill_date_high', p_bill_date_high ) ;

   IF ( p_bill_num_low is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':bill_num_low', p_bill_num_low ) ;
   END IF;
   IF ( p_bill_num_high is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':bill_num_high', p_bill_num_high ) ;
   END IF;

   IF ( p_request_id is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':concurrent_request_id', p_request_id ) ;
   END IF;

END BIND_VARIABLES;


function PRINT_MLS_FUNCTION RETURN VARCHAR2 IS

-- variables used by build_where_clause
p_org_id              number         := NULL;
p_job_size            number         := NULL;
p_cust_num_low				varchar2(30)	 := NULL;
p_cust_num_high				varchar2(30)	 := NULL;
p_bill_site_low				number	 			 := NULL;
p_bill_site_high			number	 			 := NULL;
p_bill_date_low				date		 			 := NULL;
p_bill_date_high			date		 			 := NULL;
p_bill_num_low   		  varchar2(30)	 := NULL;
p_bill_num_high  		  varchar2(30)	 := NULL;
p_request_id       		NUMBER				 := NULL;

p_where 		varchar2(1024);

--local variables
userenv_lang 	varchar2(4);
--base_lang 		varchar2(4);/*Bug8486880*/
retval 		number;
parm_number 	number;
parm_name		varchar2(80);

sql_stmt_c		   number;
sql_stmt         varchar2(2048);
select_stmt      varchar2(1000);
lang_str 	    	 varchar2(240);

TYPE sql_stmt_rec_type IS RECORD
(language VARCHAR2(4));

sql_stmt_rec 		sql_stmt_rec_type ;
l_ignore                INTEGER;

BEGIN

   select  substr(userenv('LANG'),1,4)
   into    userenv_lang
   from    dual;

/* Bug8486880
   select  language_code
   into    base_lang
   from    fnd_languages
   where   installed_flag = 'B';
*/

   MO_global.init('AR');
   fnd_file.put_line( fnd_file.log, 'userenv_lang: ' || userenv_lang);
 --fnd_file.put_line( fnd_file.log, 'base_lang: ' || base_lang);/*Bug8486880*/

   /* Read in Parameter Values supplied by user */
   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Operating Unit',parm_number);
   IF retval = -1 THEN
      p_org_id := NULL;
   ELSE
      p_org_id:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_org_id: ' || p_org_id);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Job Size',parm_number);
   IF retval = -1 THEN
      p_job_size:= NULL;
   ELSE
      p_job_size:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_job_size: ' || p_job_size);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Number Low',parm_number);
   IF retval = -1 THEN
      p_cust_num_low:= NULL;
   ELSE
      p_cust_num_low:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_cust_num_low: ' || p_cust_num_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Number High',parm_number);
   IF retval = -1 THEN
      p_cust_num_high:= NULL;
   ELSE
      p_cust_num_high:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_cust_num_high: ' || p_cust_num_high);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Location Low',parm_number);
   IF retval = -1 THEN
      p_bill_site_low:= NULL;
   ELSE
      p_bill_site_low:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_site_low: ' || p_bill_site_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Location High',parm_number);
   IF retval = -1 THEN
      p_bill_site_high:= NULL;
   ELSE
      p_bill_site_high:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_site_high: ' || p_bill_site_high);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Billing Date Low',parm_number);
   IF retval = -1 THEN
      p_bill_date_low:= NULL;
   ELSE
      p_bill_date_low:= fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_date_low: ' || p_bill_date_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Billing Date High',parm_number);
   IF retval = -1 THEN
      p_bill_date_high:= NULL;
   ELSE
      p_bill_date_high:= fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_date_high: ' || p_bill_date_high);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Billing Number Low',parm_number);
   IF retval = -1 THEN
      p_bill_num_low:= NULL;
   ELSE
      p_bill_num_low:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_num_low: ' || p_bill_num_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Billing Number High',parm_number);
   IF retval = -1 THEN
      p_bill_num_high:= NULL;
   ELSE
      p_bill_num_high:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_bill_num_high: ' || p_bill_num_high);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Concurrent Request ID',parm_number);
   IF retval = -1 THEN
      p_request_id:= NULL;
   ELSE
      p_request_id:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_request_id: ' || p_request_id);

   /*Bug8486880*/
  select_stmt :=
      '  select distinct(nvl(rtrim(substr(loc.language,1,4)), ''' || userenv_lang || ''')) language ' || cr ||
         build_from_clause;

    Build_where_clause(
        p_org_id,
				p_cust_num_low ,
				p_cust_num_high ,
				p_bill_site_low,
				p_bill_site_high,
				p_bill_date_low,
				p_bill_date_high,
				p_bill_num_low,
				p_bill_num_high,
				p_request_id,
				p_where) ;

  sql_stmt := select_stmt || cr || p_where;

--  fnd_file.put_line( fnd_file.log, 'The final sql: ' || sql_stmt);
  ------------------------------------------------
  -- Parse sql stmts
  ------------------------------------------------

  sql_stmt_c:= dbms_sql.open_cursor;

  dbms_sql.parse( sql_stmt_c, sql_stmt , dbms_sql.v7 );
  bind_variables(
        p_org_id,
				p_cust_num_low ,
				p_cust_num_high ,
				p_bill_site_low,
				p_bill_site_high,
				p_bill_date_low,
				p_bill_date_high,
				p_bill_num_low,
				p_bill_num_high,
				p_request_id,
        sql_stmt_c);

  dbms_sql.define_column( sql_stmt_c, 1, sql_stmt_rec.language, 4);

  l_ignore := dbms_sql.execute( sql_stmt_c);

  LOOP
    IF (dbms_sql.fetch_rows( sql_stmt_c) > 0)
    THEN

        ------------------------------------------------------
        -- Get column values
        ------------------------------------------------------
        dbms_sql.column_value( sql_stmt_c, 1, sql_stmt_rec.language );

        IF (lang_str is null) THEN
            lang_str := sql_stmt_rec.language;
        ELSE
            lang_str := lang_str || ',' ||  sql_stmt_rec.language;
        END IF;
    ELSE
        EXIT;
    END IF;
 END LOOP;

 IF lang_str IS NULL THEN
   fnd_file.put_line( fnd_file.log, 'No documents matched the input parameters.' );
 ELSE
   fnd_file.put_line( fnd_file.log, 'lang_str: ' || lang_str);
 END IF;

RETURN lang_str;

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line( fnd_file.log, sql_stmt);
	RAISE;

END PRINT_MLS_FUNCTION  ;

PROCEDURE PRINT_BILLS(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_org_id                       IN NUMBER,
             p_job_size         IN NUMBER,
			 p_cust_num_low     						IN VARCHAR2,
			 p_cust_num_high    						IN VARCHAR2,
			 p_bill_site_low    						IN NUMBER,
			 p_bill_site_high   						IN NUMBER,
			 p_bill_date_low_in  						IN VARCHAR2,
			 p_bill_date_high_in 						IN VARCHAR2,
			 p_bill_num_low   							IN VARCHAR2,
			 p_bill_num_high  							IN VARCHAR2,
			 p_request_id       						IN NUMBER,
       p_template_id                  IN NUMBER
      ) IS
l_job_size      INTEGER := 500;
p_bill_date_low      date    := NULL;
p_bill_date_high     date		 := NULL;
p_where 		varchar2(1024);

--local variables
--base_lang 		varchar2(4);/*Bug8486880*/
userenv_lang 	varchar2(4);
retval 		number;
parm_number 	number;
parm_name		varchar2(80);

sql_stmt_c		   		number;
sql_stmt            varchar2(2048);
insert_stmt         varchar2(240);
select_stmt         varchar2(2048);

inserted_row_counts  INTEGER;
row_counts_perworker number;
divided_worker_counts number := 1;

-- variable used for concurrent program
req_data varchar2(240);
l_request_id    number;     -- child request id
m_request_id    number;     -- parent request id

l_low_range  NUMBER := 1;
l_high_range NUMBER := 1;
l_worker_id  NUMBER := 1;

cnt_warnings INTEGER := 0;
cnt_errors   INTEGER := 0;
request_status BOOLEAN;
return_stat    VARCHAR2(2000);
l_fail_count	NUMBER := 0;

BEGIN

	 MO_global.init('AR');
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'AR_BPA_BFPRI_CONC.print_bills(+)' );

   -- read the variable request_data to check if it is reentering the program
   req_data := fnd_conc_global.request_data;
   m_request_id := fnd_global.conc_request_id;

   FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_bills: ' || 'req_data: '|| req_data );
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_bills: ' || 'm_request_id: '|| m_request_id );
   IF (req_data is null) THEN
       FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_bills: '
                     || 'Entering print master program at the first time');
       -- read the user env language
      select  substr(userenv('LANG'),1,4)
      into    userenv_lang
      from    dual;

     /*Bug8486880
      select  language_code
      into    base_lang
      from    fnd_languages
      where   installed_flag = 'B';*/

      FND_FILE.PUT_LINE( FND_FILE.LOG, 'userenv_lang: '|| userenv_lang );
      --fnd_file.put_line( fnd_file.log, 'base_lang: ' || base_lang);

      if p_job_size > 0 then l_job_size := p_job_size; end if;
      p_bill_date_high := fnd_date.canonical_to_date(p_bill_date_high_in);
      p_bill_date_low := fnd_date.canonical_to_date(p_bill_date_low_in);
      -- print out the input parameters;
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_org_id: '|| p_org_id );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_job_size: '|| l_job_size );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_cust_num_low: '|| p_cust_num_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_cust_num_high: '|| p_cust_num_high );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_site_low: '|| p_bill_site_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_site_high: '|| p_bill_site_high );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_date_low: '|| p_bill_date_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_date_high: '|| p_bill_date_high );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_num_low: '|| p_bill_num_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_bill_num_high: '|| p_bill_num_high );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_request_id: '|| p_request_id );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_template_id: '|| p_template_id );

      -- fetch a list of billing document id based on the inputted parameters
      -- and insert into the ar_bpa_print_requests table

      insert_stmt := '  insert into ar_bpa_print_requests (request_id, payment_schedule_id,
			worker_id, created_by, creation_date,last_updated_by, last_update_date)';

       /*Bug 8486880*/
      select_stmt := '  select  ' || m_request_id || ', to_number(cons_billing_number), rownum, 1, sysdate, 1, sysdate from '
                     || cr ||' ( select cons.cons_billing_number '|| cr || build_from_clause ||
              '  AND nvl(loc.language,' || '''' || userenv_lang || ''') = ' || '''' || userenv_lang || '''' ;

		  Build_where_clause(
				        p_org_id,
								p_cust_num_low ,
								p_cust_num_high ,
								p_bill_site_low,
								p_bill_site_high,
								p_bill_date_low,
								p_bill_date_high,
								p_bill_num_low,
								p_bill_num_high,
								p_request_id,
								p_where) ;


	    sql_stmt := insert_stmt || cr || select_stmt || cr || p_where || ')';

--      fnd_file.put_line( fnd_file.log, sql_stmt);
      ------------------------------------------------
      -- Parse sql stmts
      ------------------------------------------------

      sql_stmt_c:= dbms_sql.open_cursor;

      dbms_sql.parse( sql_stmt_c, sql_stmt , dbms_sql.v7 );

  		bind_variables(
        p_org_id,
				p_cust_num_low ,
				p_cust_num_high ,
				p_bill_site_low,
				p_bill_site_high,
				p_bill_date_low,
				p_bill_date_high,
				p_bill_num_low,
				p_bill_num_high,
				p_request_id,
        sql_stmt_c);

      inserted_row_counts := dbms_sql.execute(sql_stmt_c);
      fnd_file.put_line( fnd_file.log, 'inserted row count: ' || inserted_row_counts);

      IF inserted_row_counts > 0 THEN

        -- update the last printed date for all the transactions that are being printed.
        -- bug 6955957
        update ra_customer_trx_all trx set trx.printing_last_printed = sysdate where trx.trx_number in
        (select cons.trx_number from ar_cons_inv_trx_all cons, ar_bpa_print_requests pri
          where pri.request_id = m_request_id
          and pri.payment_schedule_id = cons.cons_inv_id
        );

        divided_worker_counts := ceil(inserted_row_counts/l_job_size);
        row_counts_perworker  := ceil(inserted_row_counts/divided_worker_counts);

        fnd_file.put_line( fnd_file.log, 'row count per worker: ' || row_counts_perworker);
        fnd_file.put_line( fnd_file.log, 'divided worker count: ' || divided_worker_counts);

        l_worker_id  := 1 ;
        l_low_range  := 1 ;
	  		l_high_range := row_counts_perworker ;

         LOOP
            UPDATE ar_bpa_print_requests
                SET worker_id = l_worker_id
                WHERE request_id = m_request_id
                AND worker_id BETWEEN  l_low_range AND l_high_range;

	      IF l_worker_id >= divided_worker_counts THEN
                EXIT;
            END IF;

            l_worker_id        :=  l_worker_id  + 1;
            l_low_range        :=  l_low_range  + row_counts_perworker ;
            l_high_range       :=  l_high_range + row_counts_perworker ;

         END LOOP;
         commit;  -- commit the record here

         FOR no_of_workers in 1 .. divided_worker_counts
         LOOP
             l_request_id := submit_print_request(
                                           m_request_id,
                                           no_of_workers,
                                           '',
                                           p_template_id,
                                           'Y',
                                           '',
                                           '','', TRUE);
             IF (l_request_id = 0) THEN
                fnd_file.put_line( fnd_file.log, 'can not start for worker_id: ' ||no_of_workers );
								FND_MESSAGE.RETRIEVE(return_stat);
								fnd_file.put_line( fnd_file.log, 'Error occured : ' ||return_stat );
								l_fail_count := l_fail_count + 1;
             ELSE
                commit;
                fnd_file.put_line( fnd_file.log, 'child request id: ' ||
                    l_request_id || ' started for worker_id: ' ||no_of_workers );
             END IF;
        END LOOP;

        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => to_char(inserted_row_counts));
        fnd_file.put_line( fnd_file.log, 'The Master program changed status to pause and wait for child processes');
      ELSE
        fnd_file.new_line( fnd_file.log,1 );
        fnd_file.put_line( fnd_file.log, 'No bills matched the input parameters.');
        fnd_file.new_line( fnd_file.log,1 );
      END IF;

    ELSE

        FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_bills: '
                     || 'Entering print master program at the second time');
        fnd_file.put_line( fnd_file.output,
                           arp_standard.fnd_message('AR_BPA_PRINT_OUTPUT_HDR',
                                                    'NUM_OF_WORKER',
                                                    divided_worker_counts,
                                                    'TRX_COUNT',
                                                    req_data));

	IF divided_worker_counts > 0
	THEN
           DECLARE
               CURSOR child_request_cur(p_request_id IN NUMBER) IS
                   SELECT request_id, status_code
                   FROM fnd_concurrent_requests
                   WHERE parent_request_id = p_request_id;
           BEGIN
               FOR child_request_rec IN child_request_cur(m_request_id)
               LOOP
                   check_child_request(child_request_rec.request_id);
                   IF ( child_request_rec.status_code = 'G' OR child_request_rec.status_code = 'X'
                          OR child_request_rec.status_code ='D' OR child_request_rec.status_code ='T'  ) THEN
                       cnt_warnings := cnt_warnings + 1;
                   ELSIF ( child_request_rec.status_code = 'E' ) THEN
                       cnt_errors := cnt_errors + 1;
                   END IF;
               END LOOP;

               IF ((cnt_errors >  0) OR ( l_fail_count = divided_worker_counts ))
	       THEN
                   request_status := fnd_concurrent.set_completion_status('ERROR', '');
               ELSIF ((cnt_warnings > 0) OR (l_fail_count > 0) )
	       THEN
		    request_status := fnd_concurrent.set_completion_status('WARNING', '');
               ELSE
                   request_status := fnd_concurrent.set_completion_status('NORMAL', '');
               END IF;
           END;
	END IF;

	DELETE FROM ar_bpa_print_requests
	WHERE request_id = m_request_id;

	COMMIT;

    END IF;

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'AR_BPA_BFPRI_CONC.print_bills(-)' );

EXCEPTION
  WHEN OTHERS THEN
	RAISE;
END PRINT_BILLS;

PROCEDURE process_print_request( p_id_list   IN  VARCHAR2,
                                 x_req_id_list  OUT NOCOPY VARCHAR2,
                                 p_description  IN  VARCHAR2 ,
                                 p_template_id  IN  NUMBER,
                                 p_stamp_flag		IN VARCHAR2
				)
IS
TYPE lang_cur is REF CURSOR;
lang_cv lang_cur;

lang_selector VARCHAR2(1024);
lang_code     VARCHAR2(4);
base_lang     VARCHAR2(4);
nls_lang      VARCHAR2(30);
nls_terr      VARCHAR2(30);

select_stmt   VARCHAR2(1024);
select_cur    INTEGER;

ps_id  dbms_sql.number_table;

inserted_row_counts   INTEGER;
fetched_row_count     INTEGER;
ignore                INTEGER;

row_counts_perworker  number;
divided_worker_counts number := 1;

l_request_id    number;     -- child request id

l_low_range  NUMBER := 1;
l_high_range NUMBER := 1;

l_fail_flag VARCHAR2(1) ;

BEGIN

   SELECT    language_code
     INTO    base_lang
     FROM    fnd_languages
     WHERE   installed_flag = 'B';


	  lang_selector := '  select distinct(nvl(rtrim(substr(a_bill.language,1,4)), '''
			|| base_lang || ''')) language ' || cr || build_from_clause
			|| ' AND cons.cons_inv_id in ('|| p_id_list || ' )' ;


   OPEN lang_cv FOR lang_selector;

   LOOP

      FETCH lang_cv INTO lang_code;
      EXIT WHEN lang_cv%NOTFOUND;

      SELECT  nls_language, nls_territory
        INTO  nls_lang, nls_terr
        FROM  FND_LANGUAGES
        WHERE language_code = lang_code;

      select_stmt := ' SELECT to_number(cons.cons_billing_number) ' || cr || build_from_clause || cr ||
                    ' AND cons.cons_inv_id in ('|| p_id_list || ' ) ' || cr ||
                    ' AND nvl(a_bill.language, ''' || base_lang ||''' ) = :lang_code ';

      select_cur := dbms_sql.open_cursor;
      dbms_sql.parse( select_cur, select_stmt, dbms_sql.native );

      dbms_sql.bind_variable(select_cur,':lang_code', lang_code );
      dbms_sql.define_array(select_cur,1,ps_id,500,1 );
      ignore := dbms_sql.execute(select_cur);

      LOOP
         fetched_row_count := dbms_sql.fetch_rows(select_cur);
         dbms_sql.column_value(select_cur,1,ps_id);

         EXIT WHEN fetched_row_count <> 500 ;
      END LOOP;
      dbms_sql.close_cursor(select_cur);

      inserted_row_counts := ps_id.COUNT    ;

      divided_worker_counts := ceil(inserted_row_counts/500);
      row_counts_perworker  := ceil(inserted_row_counts/divided_worker_counts);

      l_low_range  := 1 ;
      l_high_range := row_counts_perworker ;


      FOR no_of_workers in 1 .. divided_worker_counts
      LOOP

         -- When parent request id is passed as -1, child
         -- request uses its request id to pick data.

         l_request_id := submit_print_request(
                                        -1,
                                        no_of_workers,
                                        '',
                                        p_template_id,
                                        p_stamp_flag,
                                        '',
                                        nls_lang ,
                                        nls_terr,
												                FALSE,
																				p_description);

	 IF l_request_id = 0
	 THEN
	    l_fail_flag := 'Y';
	 ELSIF x_req_id_list IS NULL THEN
            x_req_id_list  := l_request_id;
         ELSE
            x_req_id_list  := x_req_id_list  ||','|| l_request_id;
         END IF;

         FORALL i in l_low_range .. l_high_range
            INSERT INTO ar_bpa_print_requests (
            						request_id,
                				payment_schedule_id,
     	                	worker_id,
           	        		created_by,
                   			creation_date,
               					last_updated_by,
     	               		last_update_date)
     	    VALUES (l_request_id,
               	  ps_id(i),
                  no_of_workers  ,
     	            1,
           	      sysdate,
                  1,
                  sysdate);

         COMMIT;
         l_low_range  := l_low_range + row_counts_perworker;
         l_high_range := l_high_range + row_counts_perworker;
      END LOOP;
   END LOOP;

   /* If any time a request failed to submit, then we send the request id
	list as zero */
   IF l_fail_flag = 'Y' THEN
      x_req_id_list := '0';
   END IF;

   CLOSE lang_cv;
EXCEPTION
   WHEN OTHERS THEN
      IF dbms_sql.is_open(select_cur) THEN
         dbms_sql.close_cursor(select_cur);
      END IF;
      IF lang_cv%ISOPEN THEN
         CLOSE lang_cv;
      END IF;
      RAISE;
END process_print_request;

END AR_BPA_BFPRI_CONC;

/
