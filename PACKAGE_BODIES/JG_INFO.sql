--------------------------------------------------------
--  DDL for Package Body JG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_INFO" as
/*  $Header: jgzzinfb.pls 120.2 2005/02/17 15:25:33 ahansen ship $ */
  procedure jg_get_period_dates (app_id		  IN NUMBER,
				 tset_of_books_id IN NUMBER,
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
 	and ledger_id = tset_of_books_id     -- 11ix
 	and application_id = app_id ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('SQLGL','GL_PLL_INVALID_PERIOD') ;
    fnd_message.set_token('PERIOD',tperiod_name) ;
    fnd_message.set_token('SOBID',to_char(tset_of_books_id)) ;
    errbuf := fnd_message.get ;

  WHEN OTHERS THEN
	errbuf := SQLERRM;
  END;
  procedure jg_get_set_of_books_info ( sobid IN NUMBER,
                                       coaid OUT NOCOPY NUMBER,
                                       sobname OUT NOCOPY VARCHAR2,
                                       func_curr OUT NOCOPY VARCHAR2,
                                       errbuf OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    select name, chart_of_accounts_id, currency_code
    into sobname, coaid, func_curr
    from gl_sets_of_books
    where set_of_books_id = sobid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('SQLGL','GL_PLL_INVALID_SOB') ;
    fnd_message.set_token('SOBID',to_char(sobid)) ;
    errbuf := fnd_message.get ;
    WHEN OTHERS THEN
      errbuf := SQLERRM;
  END;
  procedure jg_get_bud_or_enc_name ( actual_type IN VARCHAR2,
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
        fnd_message.set_name('SQLGL','GL_PLL_INVALID_BUDGET_VERSION') ;
        fnd_message.set_token('BUDID',to_char(type_id)) ;
        errbuf := fnd_message.get ;
      else
        /* There does not exist an encumbrance type with id ENCID */
        fnd_message.set_name('SQLGL','GL_PLL_INVALID_ENC_TYPE') ;
        fnd_message.set_token('ENCID',to_char(type_id)) ;
        errbuf := fnd_message.get ;
      end if;
    WHEN OTHERS THEN
      errbuf := SQLERRM;
  END;
  procedure jg_get_lookup_value ( lmode VARCHAR2,
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
    fnd_message.set_name('SQLGL','GL_PLL_MISSING_LOOKUP') ;
    fnd_message.set_token('CODE',code);
    fnd_message.set_token('TYPE',type);
    errbuf := fnd_message.get ;
    WHEN OTHERS THEN
      errbuf := SQLERRM;
  END;
  procedure jg_get_first_period(app_id		 IN NUMBER,
				tset_of_books_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
				errbuf	   	 OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = app_id
    AND     b.application_id = app_id
    AND     a.ledger_id = tset_of_books_id          -- 11ix
    AND     b.ledger_id = tset_of_books_id          -- 11ix
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     b.period_name = tperiod_name
    AND     a.period_num =
           (SELECT min(c.period_num)
              FROM gl_period_statuses c
             WHERE c.application_id = app_id
               AND c.ledger_id = tset_of_books_id      -- 11ix
               AND c.period_year = a.period_year
               AND c.period_type = a.period_type
          GROUP BY c.period_year);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('SQLGL','GL_PLL_INVALID_FIRST_PERIOD') ;
    fnd_message.set_token('PERIOD',tperiod_name) ;
    fnd_message.set_token('SOBID',to_char(tset_of_books_id)) ;
    errbuf := fnd_message.get ;
  WHEN OTHERS THEN
	errbuf := SQLERRM;
  END;
  procedure jg_get_first_period_of_quarter(app_id IN NUMBER,
				tset_of_books_id IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                tfirst_period    OUT NOCOPY VARCHAR2,
				errbuf	   	 OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = app_id
    AND     b.application_id = app_id
    AND     a.ledger_id = tset_of_books_id                      -- 11ix
    AND     b.ledger_id = tset_of_books_id                      -- 11ix
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     a.quarter_num = b.quarter_num
    AND     b.period_name = tperiod_name
    AND     a.period_num =
           (SELECT min(c.period_num)
              FROM gl_period_statuses c
             WHERE c.application_id = app_id
               AND c.ledger_id = tset_of_books_id               -- 11ix
               AND c.period_year = a.period_year
	       AND c.quarter_num = a.quarter_num
               AND c.period_type = a.period_type
          GROUP BY c.period_year,c.quarter_num);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('SQLGL','GL_PLL_INVALID_FIRST_PERIOD') ;
    fnd_message.set_token('PERIOD',tperiod_name) ;
    fnd_message.set_token('SOBID',to_char(tset_of_books_id)) ;
    errbuf := fnd_message.get ;
  WHEN OTHERS THEN
	errbuf := SQLERRM;
  END;
  procedure jg_get_consolidation_info(
                           cons_id NUMBER, cons_name OUT NOCOPY VARCHAR2,
                           method OUT NOCOPY VARCHAR2, curr_code OUT NOCOPY VARCHAR2,
                           from_sobid OUT NOCOPY NUMBER, to_sobid OUT NOCOPY NUMBER,
                           description OUT NOCOPY VARCHAR2, start_date OUT NOCOPY DATE,
                           end_date OUT NOCOPY DATE, errbuf OUT NOCOPY VARCHAR2) is
  begin
    select glc.name, glc.method, glc.from_currency_code,
           glc.from_ledger_id, glc.to_ledger_id,              -- 11ix
           glc.description, glc.start_date_active_11i, glc.end_date_active_11i
    into cons_name, method, curr_code, from_sobid, to_sobid,
         description, start_date, end_date
    from gl_consolidation glc
    where glc.consolidation_id = cons_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('SQLGL','GL_PLL_INVALID_CONSOLID_ID') ;
    fnd_message.set_token('CID', to_char(cons_id));
    errbuf := fnd_message.get ;
  end;

FUNCTION jg_format_curr_amt(in_precision NUMBER,
                            in_amount_disp VARCHAR2) return VARCHAR2
IS
     char_str         VARCHAR2(1);
     str_length       NUMBER;
     new_string       VARCHAR2(40);
     count_pos        NUMBER;
     done             BOOLEAN;

  BEGIN

    done := FALSE;
    IF ((in_precision > 0) AND (in_amount_disp IS NOT NULL)) THEN

       str_length :=  nvl(length(ltrim(rtrim(in_amount_disp))),0);
       count_pos  := 0;

       WHILE ((NOT done) or (count_pos + str_length > 0)) LOOP
             count_pos := count_pos - 1;
             char_str := substrb(in_amount_disp,count_pos , 1);

             IF ((char_str = ',') and (NOT done)) THEN
                new_string := REPLACE(in_amount_disp,',','$');
                done := TRUE;
            END IF;

             IF ((char_str = '.') AND (NOT done)) THEN
                new_string := TRANSLATE(in_amount_disp,'.,','$.');
                done := TRUE;
             END IF;

        END LOOP;

   ELSE
                new_string := replace(in_amount_disp,',','.');

   END IF;

   RETURN(new_string);

   EXCEPTION WHEN OTHERS THEN
        RETURN(in_amount_disp);

   END jg_format_curr_amt;
end jg_info;

/
