--------------------------------------------------------
--  DDL for Package Body APRX_C_PY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APRX_C_PY" as
/* $Header: aprxcpyb.pls 120.4.12010000.3 2010/03/25 18:55:51 bgoyal ship $ */

procedure payment_register_run(
  errbuf	    out	NOCOPY varchar2,
  retcode           out	NOCOPY varchar2,
  argument1         in  varchar2,   -- payment_date_start
  argument2         in  varchar2,   -- payment_date_end
  argument3         in  varchar2,   -- payment_type_flag
  argument4         in  varchar2 default 'N',   -- debug_flag
  argument5         in  varchar2 default 'N',   -- sql_trace
  argument6         in  varchar2  default  null,
  argument7         in  varchar2  default  null,
  argument8         in   number,                   /* ledger_id , bug8760710 */
  argument9         in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	    in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	    in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	    in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	    in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	    in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	    in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	    in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	    in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	    in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default  null)
is
  l_request_id	number;
  debug_flag varchar2(1);
  sql_trace varchar2(1);

  l_payment_date_start		date;
  l_payment_date_end		date;
  l_payment_type_flag		varchar2(25);
  l_ledger_id			number;     /* 8760710 */

begin
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
  l_request_id :=		fnd_global.conc_request_id;
  l_payment_date_start := 	to_date(argument1, 'YYYY/MM/DD HH24:MI:SS');
  l_payment_date_end := 	to_date(argument2, 'YYYY/MM/DD HH24:MI:SS');
  l_payment_type_flag :=	argument3;
  l_ledger_id         :=        argument8;			 /* 8760710 */
  debug_flag :=			upper(substrb(argument4,1,1));
  sql_trace :=			upper(substrb(argument5,1,1));

  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  if sql_trace = 'Y' then
 	fa_rx_util_pkg.enable_trace;
  end if;
  if debug_flag = 'Y' then
	fa_rx_util_pkg.enable_debug;
  end if;

  --
  -- Run report
  aprx_py.payment_register_run(
	l_payment_date_start,
	l_payment_date_end,
	null, 			-- Curreny code
	null, 			-- Bank Account name
	null,			-- Payment Method
	l_payment_type_flag,
	l_ledger_id,            /* 8760710 */
	l_request_id,
	retcode,
	errbuf);
end payment_register_run;



procedure payment_actual_run(
  errbuf	    out	NOCOPY varchar2,
  retcode           out	NOCOPY varchar2,
  argument1         in  varchar2,   -- payment_date_start
  argument2         in  varchar2,   -- payment_date_end
  argument3         in  varchar2,   -- payment_currency_code
  argument4         in  varchar2,   -- payment_bank_account_name
  argument5         in  varchar2,   -- payment_method
  argument6         in  varchar2  default 'N',   -- debug_flag
  argument7         in  varchar2  default 'N',   -- sql_trace
  argument8         in  varchar2  default  null,
  argument9         in  number,     /* ledger_id Added for bug#9475295*/
  argument10        in  varchar2  default  null,  /* Added for bug#9475295 */
  argument11	    in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	    in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	    in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	    in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	    in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	    in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	    in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	    in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	    in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default  null)
is
  l_request_id	number;
  debug_flag varchar2(1);
  sql_trace varchar2(1);

  l_payment_date_start		date;
  l_payment_date_end		date;
  l_payment_currency_code	varchar2(15);
  l_payment_bank_account_name	varchar2(80);
  l_payment_method		varchar2(25);
  l_payment_actual_date	varchar2(20);
  l_ledger_id                    number;   /* bug8760710 */
begin
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
  l_request_id :=		fnd_global.conc_request_id;
  l_payment_date_start := 	to_date(argument1, 'YYYY/MM/DD HH24:MI:SS');
  l_payment_date_end := 	to_date(argument2, 'YYYY/MM/DD HH24:MI:SS');
  l_payment_currency_code := 	argument3;
  l_payment_bank_account_name :=	argument4;
  l_ledger_id            :=    argument9;	/* Changed from argument10 to argument9 for bug#9475295 */
  l_payment_method :=		argument5;
  debug_flag :=			upper(substrb(argument6,1,1));
  sql_trace :=			upper(substrb(argument7,1,1));

  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  if sql_trace = 'Y' then
 	fa_rx_util_pkg.enable_trace;
  end if;
  if debug_flag = 'Y' then
	fa_rx_util_pkg.enable_debug;
  end if;

  --
  -- Run report
  aprx_py.payment_actual_run(
	l_payment_date_start,
	l_payment_date_end,
	l_payment_currency_code,
	l_payment_bank_account_name,
	l_payment_method,
	NULL, 		-- Payment type
	l_ledger_id      ,   /* bug8760710 */
	l_request_id,
	retcode,
	errbuf);

end payment_actual_run;


end aprx_c_py;

/
