--------------------------------------------------------
--  DDL for Package Body GL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_INFO" as
/* $Header: gluplifb.pls 120.5 2005/05/05 01:41:56 kvora ship $ */
  procedure gl_get_period_dates (tledger_id IN NUMBER,
                                 tperiod_name     IN VARCHAR2,
                                 tstart_date      OUT NOCOPY DATE,
                                 tend_date        OUT NOCOPY DATE,
				 errbuf	   	  OUT NOCOPY VARCHAR2)
  IS

  BEGIN

 	select start_date, end_date
 	into   tstart_date, tend_date
 	from gl_period_statuses
 	where period_name = tperiod_name
 	and ledger_id = tledger_id
 	and application_id = 101;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	errbuf := gl_message.get_message('GL_PLL_INVALID_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LDGID', to_char(tledger_id) );

  WHEN OTHERS THEN

	errbuf := SQLERRM;

  END;


  procedure gl_get_ledger_info ( ledid IN NUMBER,
                                       coaid OUT NOCOPY NUMBER,
                                       ledname OUT NOCOPY VARCHAR2,
                                       func_curr OUT NOCOPY VARCHAR2,
                                       errbuf OUT NOCOPY VARCHAR2)

  IS

  BEGIN
    select name, chart_of_accounts_id, currency_code
    into ledname, coaid, func_curr
    from gl_ledgers
    where ledger_id = ledid;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_SOB', 'Y',
                                   'LEDID', to_char(ledid));

    WHEN OTHERS THEN
      errbuf := SQLERRM;

  END;


  procedure gl_get_bud_or_enc_name ( actual_type IN VARCHAR2,
                                     type_id IN NUMBER,
                                     name   OUT NOCOPY VARCHAR2,
                                     errbuf OUT NOCOPY VARCHAR2)

  IS

  BEGIN
    if (actual_type = 'B') then
      select bv.budget_name
      into name
      from gl_budget_versions bv
      where bv.budget_version_id = type_id;

    elsif (actual_type = 'E') then
      select e.encumbrance_type
      into name
      from gl_encumbrance_types e
      where e.encumbrance_type_id = type_id;
    end if;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      if (actual_type = 'B') then
        /* There does not exist a budget with budget version id BUDID */
        errbuf := gl_message.get_message('GL_PLL_INVALID_BUDGET_VERSION', 'Y',
                                     'BUDID', to_char(type_id));
      else
        /* There does not exist an encumbrance type with id ENCID */
        errbuf := gl_message.get_message('GL_PLL_INVALID_ENC_TYPE', 'Y',
                                     'ENCID', to_char(type_id));
      end if;

    WHEN OTHERS THEN
      errbuf := SQLERRM;

  END;


  procedure gl_get_lookup_value ( lmode VARCHAR2,
                                  code  VARCHAR2,
                                  type  VARCHAR2,
                                  value OUT NOCOPY VARCHAR2,
                                  errbuf OUT NOCOPY VARCHAR2)

  IS

  BEGIN
    select decode(lmode, 'M', meaning, description)
    into value
    from gl_lookups
    where lookup_code = code
    and   lookup_type = type;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
        /* The lookup code CODE of lookup type TYPE is missing */
        errbuf := gl_message.get_message('GL_PLL_MISSING_LOOKUP', 'Y',
                                     'CODE', code, 'TYPE', type);

    WHEN OTHERS THEN
      errbuf := SQLERRM;

  END;


  procedure gl_get_first_period(tledger_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
				errbuf	   	 OUT NOCOPY VARCHAR2)
  IS

  BEGIN

    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = 101
    AND     b.application_id = 101
    AND     a.ledger_id =tledger_id
    AND     b.ledger_id = tledger_id
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     b.period_name = tperiod_name
    AND     a.period_num =
           (SELECT min(c.period_num)
              FROM gl_period_statuses c
             WHERE c.application_id = 101
               AND c.ledger_id =tledger_id
               AND c.period_year = a.period_year
               AND c.period_type = a.period_type
          GROUP BY c.period_year);

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	errbuf := gl_message.get_message('GL_PLL_INVALID_FIRST_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LEDID', tledger_id);

  WHEN OTHERS THEN

	errbuf := SQLERRM;

  END;

  procedure gl_get_first_period_of_quarter(tledger_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
				errbuf	   	 OUT NOCOPY VARCHAR2)
  IS

  BEGIN

    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = 101
    AND     b.application_id = 101
    AND     a.ledger_id =tledger_id
    AND     b.ledger_id = tledger_id
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     a.quarter_num = b.quarter_num
    AND     b.period_name = tperiod_name
    AND     a.period_num =
           (SELECT min(c.period_num)
              FROM gl_period_statuses c
             WHERE c.application_id = 101
               AND c.ledger_id = tledger_id
               AND c.period_year = a.period_year
	       AND c.quarter_num = a.quarter_num
               AND c.period_type = a.period_type
          GROUP BY c.period_year,c.quarter_num);

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	errbuf := gl_message.get_message('GL_PLL_INVALID_FIRST_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LEDID', tledger_id);

  WHEN OTHERS THEN

	errbuf := SQLERRM;

  END;



  procedure gl_get_consolidation_info(
                           cons_id NUMBER, cons_name OUT NOCOPY VARCHAR2,
                           method OUT NOCOPY VARCHAR2, curr_code OUT NOCOPY VARCHAR2,
                           from_ledid OUT NOCOPY NUMBER, to_ledid OUT NOCOPY NUMBER,
                           description OUT NOCOPY VARCHAR2,
                           errbuf OUT NOCOPY VARCHAR2) is
  begin
    select glc.name, glc.method, glc.from_currency_code,
           glc.from_ledger_id, glc.to_ledger_id,
           glc.description
    into cons_name, method, curr_code, from_ledid, to_ledid,
         description
    from gl_consolidation glc
    where glc.consolidation_id = cons_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(cons_id));
  end;

end gl_info;


/
