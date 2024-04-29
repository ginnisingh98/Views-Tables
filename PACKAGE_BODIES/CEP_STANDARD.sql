--------------------------------------------------------
--  DDL for Package Body CEP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CEP_STANDARD" AS
/* $Header: ceseutlb.pls 120.24.12010000.4 2009/10/26 23:24:11 vnetan ship $             */
/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

debug_flag varchar2(1) := null; -- 'F' for file debug and 'S' for screen debug

FUNCTION return_patch_level RETURN VARCHAR2 IS
BEGIN
  RETURN (G_patch_level);
END return_patch_level;


/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug      - Print a debug message                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |    line_of_text           The line of text that will be displayed.         |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |			                                                       |
 | HISTORY                                                                    |
 |    12 Jun 95  Ganesh Vaidee    Created                                     |
 |    28 Jul 99  K Adams          Added option to either send it to a file or |
 |				  dbms_output.                                |
 |                                                                            |
 *----------------------------------------------------------------------------*/
procedure debug( line in varchar2 ) is
begin
If g_debug = 'Y' Then /* Bug 7125240 */
  /* Bug 3234187 */
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'ce', line);
  end if;


  IF fnd_global.CONC_REQUEST_ID <> -1 THEN
       FND_FILE.put_line(FND_FILE.LOG, line);
  END IF;
End If ;

end;
--
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    enable_debug      - Enable run time debugging                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    12 Jun 95  Ganesh Vaidee    Created                                     |
 |    28 Jul 99  K Adams          Added option to either send it to a file or |
 |				  dbms_output. 				      |
 |                                If debug path and file name are passed,     |
 |                                it writes to the path/file_name instead     |
 |                                of dbms_output.                             |
 |                                If AR is installed, it includes ar debug    |
 |                                messages, too.                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/
procedure enable_debug( path_name in varchar2 default NULL,
			file_name in varchar2 default NULL) is

install		BOOLEAN;
status   	VARCHAR2(1);
industry 	VARCHAR2(1);

begin
    install := fnd_installation.get(222,222,status,industry);

    if (path_name is not null and file_name is not null) then
       debug_flag := 'F';
       ce_debug_pkg.enable_file_debug(path_name, file_name);
       /* Bug 7445326 - removed AR logging
       if (status = 'I') then
	     arp_standard.enable_file_debug(path_name,file_name);
       end if;*/
    else
       debug_flag := 'S';
       /* Bug 7445326 - removed AR logging
       if (status = 'I') then
	     arp_standard.enable_debug;
       end if;*/
    end if;
exception
  when others then
    raise;
end;
--
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    12 Jun 95  Ganesh Vaidee    Created                                     |
 |    28 Jul 99  K Adams          Added option to either send it to a file or |
 |				  dbms_output. 				      |
 |                                                                            |
 *----------------------------------------------------------------------------*/
procedure disable_debug (display_debug in varchar2) is

install		BOOLEAN;
status   	VARCHAR2(1);
industry 	VARCHAR2(1);

begin
  if display_debug = 'Y' then
    debug_flag := null;
    ce_debug_pkg.disable_file_debug;
    /* - Bug 7445326 Removed ar logging
    install := fnd_installation.get(222,222,status,industry);
    if (status ='I') then
	arp_standard.disable_debug;
        arp_standard.disable_file_debug;
    end if;
    */
  end if;
exception
  when others then
    raise;
end;
--

FUNCTION Get_Window_Session_Title(p_org_id number default NULL,
				  p_legal_entity_id number default NULL) RETURN VARCHAR2 IS


  l_multi_org 		VARCHAR2(1);
  l_multi_cur		VARCHAR2(1);
  l_wnd_context 	VARCHAR2(80);
  l_id			VARCHAR2(15);

BEGIN

  /*
  ***
  *** Get multi-org and MRC information on the current
  *** prodcut installation.
  ***
   */
  SELECT 	nvl(multi_org_flag, 'N')
  ,		nvl(multi_currency_flag, 'N')
  INTO 		l_multi_org
  ,		l_multi_cur
  FROM		fnd_product_groups;


  /*
  ***
  *** Case #1 : Non-Multi-Org or Multi-SOB
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (SPB Short Name) - context Info
  ***       e.g. Maintain Forecasts (US OPS) - Forecast Context Info
  ***
  ***  B. MRC installed, Primary Books
  ***       Form Name (SOB Short Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecasts (US OPS: USD) - Forecast Context Info
  ***  C. MRC installed, Report Books
  ***       Form Name (SOB Short Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecasts (US OPS: EUR) - Forecast Context Info
  ***
  ***
   */
  IF (l_multi_org = 'N') THEN

    BEGIN
      select 	g.short_name ||
		  decode(g.mrc_sob_type_code, 'N', NULL,
                    decode(l_multi_cur, 'N', NULL,
		      ': ' || substr(g.currency_code, 1, 5)))
      into 	l_wnd_context
      from 	gl_sets_of_books g
      ,	 	ce_system_parameters c
      where	c.set_of_books_id = g.set_of_books_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return (NULL);
    END;

  /*
  ***
  *** Case #2 : Multi-Org
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (OU Name) - Context Info
  ***       e.g. Maintain Forecasts (US West) - Forecast Context Info
  **
  ***  B. MRC installed, Primary Books
  ***       Form Name (OU Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecast (US West: USD) - Forecast Context Info
  ***
  ***  C. MRC installed, Reporting Books
  ***       Form Name (OU Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecast (US West: EUR) - Forecast Context Info
  ***
  ***
   */
  ELSE

   --bug 3676745 MOAC and BA uptake
   IF (p_org_id is not null) THEN

      --FND_PROFILE.GET ('ORG_ID', l_id);

      BEGIN
        select 	substr(h.name, 1, 53) ||
                  decode(g.mrc_sob_type_code, 'N', substr(h.name, 54, 7),
		    decode(l_multi_cur, 'N', substr(h.name, 54, 7),
                      ': ' || substr(g.currency_code, 1, 5)))
        into 	l_wnd_context
        from 	gl_sets_of_books g,
		ce_system_parameters c,
		XLE_FP_OU_LEDGER_V   xo,
		hr_operating_units h
        where     h.organization_id = to_number(p_org_id)
        --where     h.organization_id = to_number(l_id)
        --and      h.organization_id = c.org_id
        and      h.organization_id = xo.OPERATING_UNIT_ID
	and      xo.LEGAL_ENTITY_ID = c.LEGAL_ENTITY_ID
        and       c.set_of_books_id = g.set_of_books_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN null;
      END;
   ELSIF (p_legal_entity_id is not null) THEN

      BEGIN
        select 	substr(h.name, 1, 53) ||
                  decode(g.mrc_sob_type_code, 'N', substr(h.name, 54, 7),
		    decode(l_multi_cur, 'N', substr(h.name, 54, 7),
                      ': ' || substr(g.currency_code, 1, 5)))
        into 	l_wnd_context
        from 	gl_sets_of_books g,
		ce_system_parameters c,
		XLE_ENTITY_PROFILES  h
        where     h.LEGAL_ENTITY_ID = to_number(p_legal_entity_id)
        and      h.LEGAL_ENTITY_ID =  c.LEGAL_ENTITY_ID
        and       c.set_of_books_id = g.set_of_books_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN null;
      END;
    END IF;

  END IF;

  return l_wnd_context;

END Get_Window_Session_Title;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_effective_date						      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This is primarily for AR autolockbox interface. Calculates the          |
 |	effective date for receipts.                                          |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    29 Oct 1996	Bidemi Carrol		Created			      |
 |                                                                            |
 *----------------------------------------------------------------------------*/
function get_effective_date(p_bank_account_id NUMBER,
			p_trx_code VARCHAR2,
			p_receipt_date DATE) RETURN DATE IS
fd	ce_transaction_codes.float_days%TYPE;
begin
  select nvl(float_days,0)
  into fd
  from ce_transaction_codes ctc
  where ctc.trx_code = p_trx_code
  and   ctc.bank_account_id = p_bank_account_id;

 return (p_receipt_date + fd);
exception
  when others then
    return p_receipt_date;
end get_effective_date;


/**
 * PROCEDURE debug_msg_stack
 *
 * DESCRIPTION
 *     Show debug messages on message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_msg_count                    Message count in message stack.
 *     p_msg_data                     Message data if message count is 1.
 *
 * MODIFICATION HISTORY
 *
 *   15-SEP-2004    Xin Wang            Created.
 *
 */
PROCEDURE debug_msg_stack(p_msg_count   IN NUMBER,
                          p_msg_data    IN VARCHAR2) IS
    i     NUMBER;

BEGIN

    IF p_msg_count <= 0 THEN
        RETURN;
    END IF;

    IF p_msg_count = 1 THEN
        debug( p_msg_data);
    ELSE
        FOR i IN 1..p_msg_count LOOP
            debug( FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ));
        END LOOP;
    END IF;

END debug_msg_stack;


  /*=======================================================================+
   | PUBLIC PRECEDURE sql_error                                            |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure sets the error message and raise an exception        |
   |   for unhandled sql errors.                                           |
   |   Called by other routines.                                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_routine                                                         |
   |     p_errcode                                                         |
   |     p_errmsg                                                          |
   +=======================================================================*/
   PROCEDURE sql_error(p_routine   IN VARCHAR2,
                       p_errcode   IN NUMBER,
                       p_errmsg    IN VARCHAR2) IS
   BEGIN
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', p_routine);
     fnd_message.set_token('ERRNO', p_errcode);
     fnd_message.set_token('REASON', p_errmsg);
     app_exception.raise_exception;
   EXCEPTION
     WHEN OTHERS THEN RAISE;
   END sql_error;


  /*=======================================================================+
   | PUBLIC PRECEDURE get_umx_predicate                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure return where clause predicate generated from UMX API |
   |   to apply BA access security or BAT security                         |
   | USAGE				                                   |
   |   From clause should include XLE_FIRSTPARTY_INFORMATION_V or any      |
   |   other view/table that has LEGAL_ENTITY_ID column since Where clause |
   |   predicate references LEGAL_ENTITY_ID column.			   |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_object_name: CEBAT, CEBAC                                                         |
   +=======================================================================*/
  FUNCTION get_umx_predicate(p_object_name   IN VARCHAR2) RETURN VARCHAR2 IS
    p_predicate   varchar2(32767);
    p_return_status varchar2(30);
  BEGIN

    FND_DATA_SECURITY.GET_SECURITY_PREDICATE(
	1.0,
	null,
	p_object_name,
	null,
	fnd_global.user_name,
	null,
        p_predicate,
	p_return_status,
	null);

    IF p_return_status <> 'T' THEN
      RETURN ('1=2');
    ELSE
      RETURN p_predicate;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN RAISE;
  END get_umx_predicate;


  /*=======================================================================+
   | PUBLIC PRECEDURE check_ba_security	                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function checks if user has access to the input LE based on    |
   |   Bank account Access or Bank Account Transfer security defined in UMX|
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_le_id: Legal Entity ID					   |
   |     p_security_mode: CEBAT for Bank Account Transfer security	   |
   |                      CEBAC for Bank Account Creation security         |
   |   OUT:								   |
   |	 1: if user has access					           |
   |     0: otherwise 							   |
   +=======================================================================*/
  FUNCTION check_ba_security ( p_le_id 		NUMBER,
			       p_security_mode	VARCHAR2) RETURN NUMBER IS
    l_predicate   	varchar2(32767);
    l_return_status 	varchar2(30);
    l_final_query 	varchar2(32767);
    l_cursor_id		NUMBER;
    l_exec_id		NUMBER;
    l_row 		NUMBER;
  BEGIN

    l_cursor_id := DBMS_SQL.open_cursor;

    l_final_query := 'SELECT 1 from fnd_grants grt, fnd_objects obj, wf_user_roles rol, xle_entity_profiles le ' ||
                     'where grt.object_id = obj.object_id and obj.obj_name = ''' || p_security_mode || ''' and ' ||
                     'GRANTEE_TYPE = '''||'GROUP'||''' and GRANTEE_KEY = rol.role_name and  ' ||
                     'rol.user_name in ((select fnd_global.user_name from dual) UNION ALL '||
            	     '(select incrns.name from wf_local_roles incrns, fnd_user f '||
                     'where '''|| 'HZ_PARTY' ||''' = incrns.orig_system and f.user_name = fnd_global.user_name '||
                     'and f.person_party_id  = incrns.orig_system_id and incrns.partition_id = 9)) '||
 		     'and   INSTANCE_PK1_VALUE = to_char(le.legal_entity_id) '||
                     'and   le.legal_entity_id = '|| to_char(p_le_id);


    DBMS_SQL.Parse(l_cursor_id,
		 l_final_query,
		 DBMS_SQL.v7);

    cep_standard.debug('Parsed sucessfully');

    l_exec_id := DBMS_SQL.execute(l_cursor_id);
    l_row := DBMS_SQL.FETCH_ROWS(l_cursor_id);
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    RETURN l_row;

  EXCEPTION
    WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS: check_bat_security');
	IF DBMS_SQL.IS_OPEN(l_cursor_id) THEN
	  DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
	  cep_standard.debug('Cursor Closed');
	END IF;
	RAISE;
  END check_ba_security;

  /*=======================================================================+
   | PUBLIC PRECEDURE get_conversion_rate                                  |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function calls gl_currency_api.get_rate to return exchange     |
   |   rate.  If there is no rate defined in GL or any exception occurs    |
   |   then this function returns 0.					   |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_ledger_id: Ledger ID					           |
   |     p_currency_code: Currency_code   				   |
   |     p_exchange_date: Exchange rate date 			           |
   |     p_exchange_rate_type;  Exchang rate type			   |
   |   OUT:								   |
   |	 exchange rate						           |
   |     0: if no rate defined in GL or error occurs 			   |
   +=======================================================================*/
  FUNCTION get_conversion_rate ( p_ledger_id 	NUMBER,
			       p_currency_code	VARCHAR2,
			       p_exchange_date  DATE,
			       p_exchange_rate_type  VARCHAR2) RETURN NUMBER IS
  BEGIN

    RETURN nvl(gl_currency_api.get_rate(p_ledger_id,
			       p_currency_code,
			       p_exchange_date,
			       p_exchange_rate_type),0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END get_conversion_rate;

  /*=======================================================================+
   | PUBLIC PRECEDURE init_security                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |  This procedure populates global temp table, ce_security_profiles_tmp,|
   |  based on ce_security_profiles_v. The ce_security_profiles_tmp table  |
   |  is referenced from ce_bank_accts_gt_v.				   |
   +=======================================================================*/
  PROCEDURE init_security IS
    l_resp_appl_id  NUMBER(15);   -- 8823179: Added variable
    l_appl_name     VARCHAR2(50);
  BEGIN
    -- 8823179: IF block added
    IF FND_GLOBAL.resp_appl_id=101 THEN
        l_resp_appl_id := 260;
    ELSE
        l_resp_appl_id := FND_GLOBAL.resp_appl_id;
    END IF;

    -- call MO Init if it has not been set yet
    IF MO_GLOBAL.is_mo_init_done = 'N' THEN
      select  APPLICATION_SHORT_NAME
      into    l_appl_name
      from    FND_APPLICATION
      where   APPLICATION_ID = l_resp_appl_id; -- 8823179 : Changed l_resp_appl_id

      -- Bug 5860453. Do not call MOAC if the product is XTR
      IF (l_appl_name <> 'XTR') THEN
	      -- Set MOAC security
	      MO_GLOBAL.init(l_appl_name);
      END IF;
    END IF;

    -- clean up the GT table
    delete ce_security_profiles_gt;

    insert into ce_security_profiles_gt
	(organization_type,
	 organization_id,
	 name)
    select organization_type,
	   organization_id,
	   name
    from ce_security_profiles_v;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END init_security;

  /*=======================================================================+
   | PUBLIC PRECEDURE init_security_baui                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |  This procedure populates global temp table, ce_security_profiles_tmp,|
   |  based on security logic in ce_security_profiles_v except for BG.     |
   |  All available BG will be populated to ce_security_profiles_tmp table |
   +=======================================================================*/
  PROCEDURE init_security_baui IS
  BEGIN
    -- Set MOAC security
    MO_GLOBAL.init('CE');

    -- clean up the GT table
    delete ce_security_profiles_gt;

    insert into ce_security_profiles_gt
	(organization_type,
	 organization_id,
	 name)
    ( select organization_type,
	   organization_id,
	   name
    from ce_security_profiles_v
    union
    select  'BUSINESS_GROUP',
             org.BUSINESS_GROUP_ID,
             org.NAME
    from hr_organization_information oi,
         hr_all_organization_units org
    WHERE   oi.organization_id = org.organization_id
    and  oi.org_information_context = 'CLASS'
    AND   oi.org_information1 = 'HR_BG');
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END init_security_baui;

/* begin code added for the bug 7125240 */
Begin
    g_debug := FND_PROFILE.value('CE_DEBUG') ;

end CEP_STANDARD;

/
