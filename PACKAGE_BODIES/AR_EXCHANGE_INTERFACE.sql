--------------------------------------------------------
--  DDL for Package Body AR_EXCHANGE_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_EXCHANGE_INTERFACE" as
/*$Header: AREXINTB.pls 115.7 2002/11/15 02:33:15 anukumar ship $ */

/* Private procedures */
PROCEDURE debug( p_indent IN NUMBER, p_text IN VARCHAR2 ) IS
BEGIN
	fnd_file.put_line( FND_FILE.LOG, RPAD(' ', p_indent*2)||p_text );
	--dbms_output.put_line( RPAD(' ', p_indent*2)||p_text );
END debug;

PROCEDURE request_output( p_indent IN NUMBER, p_text IN VARCHAR2 ) IS
BEGIN
	--fnd_file.put_line( FND_FILE.OUTPUT, RPAD(' ', p_indent*2)||p_text );
	--dbms_output.put_line( RPAD(' ', p_indent*2)||p_text );
	null;
END request_output;

/*
 Create customers in AR for exchange party.
*/
procedure ar_customer_interface (
	errbuf out NOCOPY varchar2,
	retcode out NOCOPY varchar2,
	p_customer_name IN VARCHAR2 default null
	) IS

	l_error_code	varchar2(30);
	l_error_msg	varchar2(255);
	l_conc_request_id NUMBER;

	l_cust_autonum_flag varchar2(10);

LEVEL0 CONSTANT NUMBER := 0;
LEVEL2 CONSTANT NUMBER := 2;
LEVEL4 CONSTANT NUMBER := 4;
LEVEL_MIDDLE CONSTANT NUMBER := 16;
OUTPUT_LINE_WIDTH CONSTANT NUMBER := 40;

cursor c_sysop is
	select nvl(generate_customer_number,'N')
	from 	ar_system_parameters;
BEGIN

	debug(LEVEL0,'ar_exchange_interface.ar_customer_interface +');
	debug(LEVEL0,'-----------------------------------------');
	l_conc_request_id := fnd_global.conc_request_id;
	debug(LEVEL0,'conc.request id = '||to_char(l_conc_request_id));

	debug(LEVEL0,'Calling ar_exchange_interface_pkg.customer_interface + ');
	ar_exchange_interface_pkg.customer_interface
		(null,
		null,
		l_conc_request_id,
		l_error_code,
		l_error_msg);


	l_cust_autonum_flag := 'Y';

	/* Get value into l_cust_autonum_flag here */

	open c_sysop;
	fetch c_sysop into l_cust_autonum_flag;
	close c_sysop;

	debug(LEVEL2, 'Resetting customer_number field (autonum = '||l_cust_autonum_flag||')');
	update ra_customers_interface_all
	set customer_number = decode(l_cust_autonum_flag, 'Y', NULL, customer_number)
	where orig_system_customer_ref  like 'EXCHANGE_CUST%';

	debug(LEVEL4,'Status code from remote call: '||l_error_code);

	COMMIT WORK;
EXCEPTION
	WHEN OTHERS THEN
		debug(LEVEL0,'Error from remote call: '||sqlcode||','||sqlerrm);
END ar_customer_interface;

/*
 Create invoices in AR for billing activity for a party, consolidated for a month.
*/
procedure ar_invoice_interface (
	errbuf out NOCOPY varchar2,
	retcode out NOCOPY varchar2,
	p_cutoff_date IN date default null ,
	p_customer_name IN VARCHAR2 default null
	) IS

	l_billing_period	varchar2(30);
	l_error_code	varchar2(30);
	l_error_msg	varchar2(255);
	l_conc_request_id NUMBER;

LEVEL0 CONSTANT NUMBER := 0;
LEVEL2 CONSTANT NUMBER := 2;
LEVEL4 CONSTANT NUMBER := 4;
LEVEL_MIDDLE CONSTANT NUMBER := 16;
OUTPUT_LINE_WIDTH CONSTANT NUMBER := 40;

BEGIN


	debug(LEVEL0,'ar_exchange_interface.invoice_interface +');
	debug(LEVEL0,'-----------------------------------------');
	l_conc_request_id := fnd_global.conc_request_id;
	debug(LEVEL0,'conc.request id = '||to_char(l_conc_request_id));

	debug(LEVEL0,'Calling ar_exchange_interface_pkg.invoice_interface() + ');
	ar_exchange_interface_pkg.invoice_interface
		(p_cutoff_date,
		 p_customer_name,
		 l_conc_request_id,
		 l_error_code,
		 l_error_msg );
	debug(LEVEL4,'Status code from remote call: '||l_error_code);

	COMMIT WORK;
EXCEPTION
	WHEN OTHERS THEN
		debug(LEVEL0,'Error from remote call: '||sqlcode||','||sqlerrm);
END ar_invoice_interface;

END ar_exchange_interface;

/
