--------------------------------------------------------
--  DDL for Package Body JL_BR_WORKDAY_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_WORKDAY_CALENDAR" AS
/* $Header: jlbrscdb.pls 120.3.12010000.4 2009/09/24 12:47:15 mkandula ship $ */

PROCEDURE JL_BR_CHECK_DATE (
	p_date		IN 	varchar2,
	p_calendar  	IN	varchar2,
	p_city		IN	varchar2,
	p_action	IN	varchar2,
	p_new_date	IN OUT NOCOPY	varchar2,
	p_status	IN OUT NOCOPY	number)
IS
	x_disable_date	date;
	x_date		date;
	x_seq_num	number;
	x_prior_date	date;
	x_next_date	date;
	x_type		number;
	flag_exit	number(38);
	local_flag_exit	number(38);   -- Bug 801009
BEGIN
        --
        -- Bug 1176138
        -- When payment action is KEEP (= 3)do not validate the date; simply return
        --
        if nvl(p_action,'3') = '3' then
          p_status := 0;
          p_new_date := p_date;
          return;
        end if;

	select	to_date(p_date,'DD-MM-YYYY')
	into	x_date
	from	dual;

	p_status:= 0;
	flag_exit := 0;

	if x_date IS NOT NULL then
	WHILE flag_exit = 0 LOOP
----
          -- Bug 1052225
          -- Carry out Local Holiday processing ONLY when city is NOT NULL
          --
          if p_city IS NOT NULL then
   	    BEGIN
	      local_flag_exit := 0;
	      WHILE local_flag_exit = 0 LOOP
   	        BEGIN
	          SELECT  a.local_holiday_type, b.disable_date
                    INTO  x_type, x_disable_date
	            FROM  jl_br_local_holiday_dates a,
		          jl_br_local_holiday_sets b
                   WHERE  b.local_holiday_set_name = p_city  -- Bug 801019
  	             AND  a.local_holiday_set_id   = b.local_holiday_set_id
  	             AND  a.local_holiday_date     = x_date
                     AND  nvl(b.disable_date,sysdate + 1) > sysdate;

/* type = 1 -> Working-day	*/
/* type = 2 -> Non-working-day  */
/* action = 1 -> Anticipate	*/
/* action = 2 -> Postpone	*/
/* action = 3 -> Keep		*/

			if	x_type = 2 then
				if p_action = '1' then
					x_date := x_date - 1;
				elsif p_action = '2' then
					x_date := x_date + 1;
				end if;
			end if;

	        EXCEPTION
                  WHEN NO_DATA_FOUND	THEN
                          flag_exit       := 1;
                          local_flag_exit := 1;  -- Bug 801009
	        END;
	      END LOOP;
	    END;
          end if;
----

	  BEGIN
	    SELECT  seq_num,	prior_date,	next_date
	      INTO  x_seq_num,      x_prior_date,   x_next_date
	      FROM  BOM_CALENDAR_DATES
	     WHERE  calendar_code = p_calendar
	       AND  calendar_date     = x_date;

	/* 2=OFF -> non-working-day */
	/* NULL  -> non-working-day */
		if	x_seq_num IS NULL then
			flag_exit := 0;
			if p_action = '1' then
				x_date := x_prior_date;
			elsif p_action = '2' then
				x_date := x_next_date;
			end if;
		else
			flag_exit := 1;
			select	to_char(x_date,'DD-MM-YYYY')
			into	p_new_date
			from	dual;
		end if;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		flag_exit := 1; -- bug: 8618972
		p_status := -1;
	  END;
	END LOOP;
	END IF;
END JL_BR_CHECK_DATE;

PROCEDURE JL_BR_CHECK_DATE (
	p_date		IN 	varchar2,
	p_calendar  	IN	varchar2,
	p_city		IN	varchar2,
	p_action	IN	varchar2,
	p_new_date	IN OUT NOCOPY	varchar2,
	p_status	IN OUT NOCOPY	number,
        p_state         IN      varchar2) -- Bug 2319552
IS
	x_disable_date	date;
	x_date		date;
	x_seq_num	number;
	x_prior_date	date;
	x_next_date	date;
	x_type		number;
	flag_exit	number(38);
	local_flag_exit	number(38);   -- Bug 801009
BEGIN
        --
        -- Bug 1176138
        -- When payment action is KEEP (= 3)do not validate the date; simply return
        --
        if nvl(p_action,'3') = '3' then
          p_status := 0;
          p_new_date := p_date;
          return;
        end if;

	select	to_date(p_date,'DD-MM-YYYY')
	into	x_date
	from	dual;

	p_status:= 0;
	flag_exit := 0;

	if x_date IS NOT NULL then
	WHILE flag_exit = 0 LOOP
----
          -- Bug 1052225
          -- Carry out Local Holiday processing ONLY when city is NOT NULL
          --
          if p_city IS NOT NULL then
   	    BEGIN
	      local_flag_exit := 0;
	      WHILE local_flag_exit = 0 LOOP
   	        BEGIN
	          SELECT  a.local_holiday_type, b.disable_date
                    INTO  x_type, x_disable_date
	            FROM  jl_br_local_holiday_dates a,
		          jl_br_local_holiday_sets b
                   WHERE  b.local_holiday_set_name = p_city  -- Bug 801019
                     AND  nvl(b.state,'$') = nvl(p_state,'$')  -- Bug 2319552
  	             AND  a.local_holiday_set_id   = b.local_holiday_set_id
  	             AND  a.local_holiday_date     = x_date
                     AND  nvl(b.disable_date,sysdate + 1) > sysdate;

/* type = 1 -> Working-day	*/
/* type = 2 -> Non-working-day  */
/* action = 1 -> Anticipate	*/
/* action = 2 -> Postpone	*/
/* action = 3 -> Keep		*/

			if	x_type = 2 then
				if p_action = '1' then
					x_date := x_date - 1;
				elsif p_action = '2' then
					x_date := x_date + 1;
				end if;
			end if;

	        EXCEPTION
                  WHEN NO_DATA_FOUND	THEN
                          flag_exit       := 1;
                          local_flag_exit := 1;  -- Bug 801009
	        END;
	      END LOOP;
	    END;
          end if;
----

	  BEGIN
	    SELECT  seq_num,	prior_date,	next_date
	      INTO  x_seq_num,      x_prior_date,   x_next_date
	      FROM  BOM_CALENDAR_DATES
	     WHERE  calendar_code = p_calendar
	       AND  calendar_date     = x_date;

	/* 2=OFF -> non-working-day */
	/* NULL  -> non-working-day */
		if	x_seq_num IS NULL then
			flag_exit := 0;
			if p_action = '1' then
				x_date := x_prior_date;
			elsif p_action = '2' then
				x_date := x_next_date;
			end if;
		else
			flag_exit := 1;
			select	to_char(x_date,'DD-MM-YYYY')
			into	p_new_date
			from	dual;
		end if;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		flag_exit := 1;  -- bug: 8618972
		p_status := -1;
	  END;
	END LOOP;
	END IF;
END JL_BR_CHECK_DATE;

PROCEDURE JL_BR_PAY_DATE_BDC (
	p_date		  IN 	date,
	p_new_date	  IN OUT NOCOPY	date,
	p_status	  IN OUT NOCOPY	number)
IS

  l_calendar              VARCHAR2(10);
  l_payment_action        VARCHAR2(1);
  l_payment_location      VARCHAR2(80);
  l_city                  VARCHAR2(30);
  l_state                 VARCHAR2(30);
  returned_date           VARCHAR2(11);
  errcode1                NUMBER;
  l_org_id                NUMBER(38);

BEGIN

  l_org_id := mo_global.get_current_org_id;

  if l_org_id is null then
    return;
  end if;

  l_payment_location := jl_zz_sys_options_pkg.get_payment_location(l_org_id);

  IF NVL(l_payment_location,'$') = '1' THEN		-- 1 COMPANY
    --Replicating JL_ZZ_AP_LIBRARY_1_PKG.get_city_frm_sys; here with ORG_ID
    --as the above api is not yet accepting org_id. As is it might work for
    --calls from forms where context is set to single org, but same wont
    --work from pages that do not set this context (e.g. this current case
    --where payment date is now in OA page : more info on bug 5437175)

    Declare

      l_ledger_id       NUMBER;
      l_BSV             VARCHAR2(30);


      Cursor CityTReg Is
        Select etb.town_or_city, etb.region_2
        From
               xle_establishment_v etb
              ,xle_bsv_associations bsv
              ,gl_ledger_le_v gl
        Where
              etb.legal_entity_id = gl.legal_entity_id
        And   bsv.legal_parent_id = etb.legal_entity_id
        And   etb.establishment_id = bsv.legal_construct_id
        And   bsv.entity_name = l_BSV
        And   gl.ledger_id = l_ledger_id;

    Begin
      Begin
        select set_of_books_id,substr(global_attribute4,1,25)
          into l_ledger_id,l_BSV
          from ap_system_parameters_all
          where  nvl(org_id,-99) = nvl(l_org_id,-99);
      Exception
        when others THEN
          NULL;
      End;
      For CityReg2 IN CityTReg Loop
        l_city  := CityReg2.town_or_city;
        l_state := CityReg2.region_2;
      End Loop;


    End;
  /*  OA page VO doesnt have vendor_site_id, so its not possible
      to have this functionality in R12
      ...
  ELSIF NVL(l_payment_location,'$') = '2' THEN		-- 2 SUPPLIER
    JL_ZZ_AP_LIBRARY_1_PKG.get_city_frm_povend(p_vendor_site_id,
                                               l_city, 1, errcode1,
                                               l_state);
  */
  END IF;

  l_payment_action := jl_zz_sys_options_pkg.get_payment_action(l_org_id);
  l_calendar := jl_zz_sys_options_pkg.get_calendar;

  if (l_payment_location is null or
      l_payment_action is null or
      l_calendar is null or
      l_city is null or
      l_state is null
     ) then
    return;
  end if;

  jl_br_workday_calendar.jl_br_check_date(to_char(p_date,'DD-MM-YYYY'),
                                          l_calendar,
                                          l_city,
                                          l_payment_action,
                                          returned_date,
                                          p_status,
                                          l_state);
  if p_status = 0 then /* procedure successfull */
    p_new_date := to_date(returned_date,'DD-MM-YYYY');
  end if;
END JL_BR_PAY_DATE_BDC;

END JL_BR_WORKDAY_CALENDAR;

/
