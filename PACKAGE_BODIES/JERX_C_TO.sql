--------------------------------------------------------
--  DDL for Package Body JERX_C_TO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JERX_C_TO" AS
/* $Header: jegrctob.pls 120.7 2008/05/29 11:57:23 pakumare ship $ */


PROCEDURE GET_TRNOVR_DATA(
  errbuf             OUT NOCOPY  VARCHAR2,
  retcode            OUT NOCOPY  NUMBER,
  argument1         in  varchar2,   -- application short name
  argument2         in  varchar2,   -- set of books id
  argument3         in  varchar2,   -- GL Period from
  argument4         in  varchar2,   -- GL Period To
  argument5	    in	varchar2,   -- Range Type
  argument6	    in  varchar2,   -- Cust/Supplier Name From
  argument7	    in  varchar2,   -- Cust/Supplier Name To
  argument8	    in 	varchar2,   -- Cust/Supplier Number From
  argument9	    in  varchar2,   -- Cust/Supplier Number To
  argument10  	    in	varchar2,   -- Currency Code
  argument11        in  varchar2,   -- invoice amount lower limit
  argument12        in  varchar2,   -- balance type +ve/-ve
  argument13        in  varchar2,   -- Legal Entity id
  argument14        in  varchar2, ---- Rule id
  argument15        in  varchar2,
  argument16        in  varchar2,
  argument17        in  varchar2,
  argument18        in  varchar2,
  argument19        in  varchar2,
  argument20        in  varchar2,
  argument21        in  varchar2,
  argument22        in  varchar2,
  argument23        in  varchar2,
  argument24        in  varchar2,
  argument25        in  varchar2,
  argument26        in  varchar2,
  argument27        in  varchar2,
  argument28        in  varchar2,
  argument29        in  varchar2,
  argument30        in  varchar2,
  argument31        in  varchar2,
  argument32        in  varchar2,
  argument33        in  varchar2,
  argument34        in  varchar2,
  argument35        in  varchar2,
  argument36        in  varchar2,
  argument37        in  varchar2,
  argument38        in  varchar2,
  argument39        in  varchar2,
  argument40        in  varchar2,
  argument41        in  varchar2,
  argument42        in  varchar2,
  argument43        in  varchar2,
  argument44        in  varchar2,
  argument45        in  varchar2,
  argument46        in  varchar2,
  argument47        in  varchar2,
  argument48        in  varchar2,
  argument49        in  varchar2,
  argument50        in  varchar2,
  argument51        in  varchar2,
  argument52        in  varchar2,
  argument53        in  varchar2,
  argument54        in  varchar2,
  argument55        in  varchar2,
  argument56        in  varchar2,
  argument57        in  varchar2,
  argument58        in  varchar2,
  argument59        in  varchar2,
  argument60        in  varchar2,
  argument61        in  varchar2,
  argument62        in  varchar2,
  argument63        in  varchar2,
  argument64        in  varchar2,
  argument65        in  varchar2,
  argument66        in  varchar2,
  argument67        in  varchar2,
  argument68        in  varchar2,
  argument69        in  varchar2,
  argument70        in  varchar2,
  argument71        in  varchar2,
  argument72        in  varchar2,
  argument73        in  varchar2,
  argument74        in  varchar2,
  argument75        in  varchar2,
  argument76        in  varchar2,
  argument77        in  varchar2,
  argument78        in  varchar2,
  argument79        in  varchar2,
  argument80        in  varchar2,
  argument81        in  varchar2,
  argument82        in  varchar2,
  argument83        in  varchar2,
  argument84        in  varchar2,
  argument85        in  varchar2,
  argument86        in  varchar2,
  argument87        in  varchar2,
  argument88        in  varchar2,
  argument89        in  varchar2,
  argument90        in  varchar2,
  argument91        in  varchar2,
  argument92        in  varchar2,
  argument93        in  varchar2,
  argument94        in  varchar2,
  argument95        in  varchar2,
  argument96        in  varchar2,
  argument97        in  varchar2,
  argument98        in  varchar2,
  argument99        in  varchar2,
  argument100       in  varchar2)
IS
  l_stage_request_id         number;
  l_conc_request_id	     number;
  l_set_request_id	     number;
  l_period_start_date	     varchar2(25);
  l_period_end_date	     varchar2(25);
  l_sob_currency_code	     varchar2(15);
  l_argument10		     varchar2(15);
  l_argument12	     	     varchar2(2);

BEGIN

  -- Log All the Parameters received by the program.

  fnd_file.put_line( fnd_file.log,'Application short name         : ' || argument1 );
  fnd_file.put_line( fnd_file.log,'Set of Books ID                : ' || argument2 );
  fnd_file.put_line( fnd_file.log,'GL Period From                 : ' || argument3 );
  fnd_file.put_line( fnd_file.log,'GL Period To                   : ' || argument4 );
  fnd_file.put_line( fnd_file.log,'Range Type                     : ' || argument5 );
  fnd_file.put_line( fnd_file.log,'Cust/Sup Name From		  : ' || argument6 );
  fnd_file.put_line( fnd_file.log,'Cust/Sup Name To		  : ' || argument7 );
  fnd_file.put_line( fnd_file.log,'Cust/Sup Number From		  : ' || argument8 );
  fnd_file.put_line( fnd_file.log,'Cust/Sup Number To		  : ' || argument9 );
  fnd_file.put_line( fnd_file.log,'Currency Code		  : ' || argument10 );
  fnd_file.put_line( fnd_file.log,'Amount Lower Limit		  : ' || argument11 );
  fnd_file.put_line( fnd_file.log,'Amount Sign			  : ' || argument12 );
  fnd_file.put_line( fnd_file.log,'Legal Entity id                : ' || argument13);
  fnd_file.put_line( fnd_file.log,'Rule id                        : ' || argument14 );
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion

  l_conc_request_id       := fnd_global.conc_request_id;

  SELECT parent_request_id
  INTO l_stage_request_id
  FROM fnd_concurrent_requests
  WHERE request_id = l_conc_request_id;

  SELECT parent_request_id
  INTO   l_set_request_id
  FROM fnd_concurrent_requests
  WHERE request_id = l_stage_request_id;

  l_conc_request_id := l_set_request_id;

  fnd_file.put_line(FND_FILE.log,'Parent Request ID :'||to_char(l_conc_request_id));

  -- Get GL Period start date and end date.

  select  	to_char(gps.start_date,'DD/MM/YYYY')||' 00:00:00',
                to_char(gps2.end_date,'DD/MM/YYYY')||' 23:59:59',
		sob.currency_code

  into		l_period_start_date,
		l_period_end_date,
		l_sob_currency_code

  from          gl_period_statuses gps,
                gl_period_statuses gps2,
               --- gl_sets_of_books sob,
                gl_ledgers_public_v sob,
		fnd_application fa
  where         fa.application_short_name = argument1
  and		fa.application_id = gps.application_id
  and		fa.application_id = gps2.application_id
  and		gps.set_of_books_id = to_number(argument2)
  --and           gps.ledger_id = to_number(argument2)
  and           gps.set_of_books_id = sob.ledger_id
  --and           gps.ledger_id = sob.ledger_id
  and           gps.period_name = argument3
  and           gps.adjustment_period_flag <> 'Y'
  and		gps2.set_of_books_id = to_number(argument2)
  and           gps2.set_of_books_id = sob.ledger_id
  and		gps2.ledger_id = to_number(argument2)
  and           gps2.ledger_id = sob.ledger_id
  and           gps2.period_name = argument4
  and           gps2.adjustment_period_flag <> 'Y';

  -- Validate Year. Year should be same for start year and end year.

  IF ( substr(l_period_start_date,7,4) <> substr(l_period_end_date,7,4)) then

  	fnd_file.put_line( fnd_file.log,'Period Start date : '|| l_period_start_date);
  	fnd_file.put_line( fnd_file.log,'Period End date : '|| l_period_end_date);
  	fnd_file.put_line( fnd_file.log,'From Period and To Period should be in the same year');
	retcode := 2;
	RETURN;

  END IF;

  -- If Set of books currency code is equal to the parameter's currency code
  -- or null then initialize currency code. It should consider all transactions.

  IF (l_sob_currency_code = nvl(argument10,l_sob_currency_code) ) then

	l_argument10 := NULL;

  ELSE
	l_argument10 := argument10;

  END IF;

  -- Argument12 to be converted to sign parameter.

  if ( argument12 = '+' ) then
	l_argument12 := '1';
  elsif ( argument12 = '-' ) then
	l_argument12 := '-1';
  end if;

  -- Run report based upon application short name passed to the procedure.

  IF (argument1 = 'SQLAP') THEN
  jerx_to.je_ap_turnover_extract(
	errbuf,
	retcode,
        argument1,
        argument2,
        l_period_start_date,
        l_period_end_date,
        argument5,
	argument6,
	argument7,
        argument8,
	argument9,
	l_argument10,
	argument14,
	argument11,
	l_argument12,
        l_conc_request_id,
        to_number(argument13)
        );
  END IF;

  IF (argument1 = 'AR') THEN
  jerx_to.je_ar_turnover_extract(
        errbuf,
	retcode,
	argument1,
        argument2,
        l_period_start_date,
        l_period_end_date,
        argument5,
        argument6,
	argument7,
        argument8,
	argument9,
	l_argument10,
	argument14,
	argument11,
	l_argument12,
        l_conc_request_id,
        to_number(argument13)
        );
  END IF;

EXCEPTION
    WHEN app_exceptions.application_exception THEN
      retcode := 2;
      fnd_file.put_line( fnd_file.log,'An application level exception occured in JERX_C_TO package.');
    WHEN OTHERS THEN
      retcode := 2;
      fnd_file.put_line( fnd_file.log,'Trapped other exception occured in JERX_C_TO package.');
      fnd_file.put_line( fnd_file.log, SQLERRM );

END GET_TRNOVR_DATA;

END JERX_C_TO;

/
