--------------------------------------------------------
--  DDL for Package Body HR_GBNICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GBNICAR" as
/* $Header: pygbnicr.pkb 115.4 1999/11/12 04:01:34 pkm ship      $ */
----------------------------------------------------------------------------------
--                                                                              --
--                          NICAR_CLASS1A_YTD                                   --
--                                                                              --
----------------------------------------------------------------------------------
  function nicar_class1a_ytd
     (
      p_business_group_id   number,
      p_assignment_id       number,
      p_element_type_id     number,
      p_end_of_period_date  date,
      p_term_date           date
     )
      return number is
--
-- N.B. When called from FastFormula, p_assignment_id, p_element_type_id
---     and p_business_group_id are
-- provided via context-set variables.
--
        csr0_session_date         date;
        v_tax_year_start          date;
        v_tax_year_end            date;
--
        csr1_price_max            number;
	csr1_ni_rate              number;
--
        csr2_element_name         varchar2(30);
        csr2_pr                   number;
        csr2_rd                   number;
        csr2_rn                   number;
        csr2_mb                   number;
        csr2_ft                   number;
        csr2_cc                   number;
        csr2_fs                   number;
        csr2_ap                   number;
--
        v_pri_sec_ind             varchar2(1);
--
        csr3_price                number;
        csr3_reg_date             date;
        csr3_mileage_band         number;
        csr3_fuel_scale           number;
	csr3_fuel_type            varchar2(10);
	csr3_engine_cc            number;
        csr3_payment              number;
        csr3_start_date           date;
        csr3_end_date             date;
--
	v_fuel_scale              number :=0;
        v_running_total           number :=0;
--
--
  cursor csr1_globals is
  SELECT        fnd_number.canonical_to_number(LIM.global_value)
	,	fnd_number.canonical_to_number(NIR.global_value)
  FROM          ff_globals_f    LIM
	,	ff_globals_f	NIR
  WHERE         LIM.global_name = 'NI_CAR_MAX_PRICE'
        AND     csr0_session_date between LIM.effective_start_date and LIM.effective_end_date
        AND     NIR.global_name = 'NI_CAR_CONTRIB_RATE'
        AND     csr0_session_date between NIR.effective_start_date and NIR.effective_end_date;
--
  cursor csr2_pri_sec is
  SELECT        E_TL.element_name
    	,	IPR.input_value_id
	,	IRD.input_value_id
	,	IRN.input_value_id
	,	IMB.input_value_id
	,	IFT.input_value_id
	,	ICC.input_value_id
	,	IFS.input_value_id
	,	IAP.input_value_id
  FROM		pay_input_values_f	IPR
	,	pay_input_values_f	IRD
	,	pay_input_values_f	IRN
	,	pay_input_values_f	IMB
	,	pay_input_values_f	IFT
	,	pay_input_values_f	ICC
	,	pay_input_values_f	IFS
	,	pay_input_values_f	IAP
	,	pay_element_types_f_tl	E_TL
	,	pay_element_types_f	E
  WHERE	E_TL.element_type_id = E.element_type_id
        AND     E.element_type_id       = p_element_type_id
        AND     userenv('LANG')         = E_TL.language
	AND	IPR.element_type_id   	= E.element_type_id
	AND	IPR.name             	= 'Price'
	AND	IRD.element_type_id   	=E.element_type_id
	AND	IRD.name		= 'Registration Date'
	AND	IRN.element_type_id   	= E.element_type_id
	AND	IRN.name		= 'Registration Number'
	AND	IMB.element_type_id   	= E.element_type_id
	AND	IMB.name		= 'Mileage Band'
	AND	IFT.element_type_id   	= E.element_type_id
	AND	IFT.name		= 'Fuel Type'
	AND	ICC.element_type_id   	= E.element_type_id
	AND	ICC.name		= 'Engine cc'
	AND	IFS.element_type_id   	= E.element_type_id
	AND	IFS.name		= 'Fuel Scale'
	AND	IAP.element_type_id   	= E.element_type_id
	AND	IAP.name             	= 'Payment'
        AND     csr0_session_date between E.effective_start_date and E.effective_end_date;
--
--
  cursor csr3_nicar is
-- bug 504994 changed the entry cursor to use a single join on values table
-- to improve performance
  select
	max(decode(V.input_value_id,csr2_pr,
		fnd_number.canonical_to_number(V.Screen_entry_value),null) )       csr3_price
	,max(decode(V.input_value_id, csr2_mb,
		fnd_number.canonical_to_number(V.Screen_entry_value),null)) 	      csr3_mileage_band
	,max(decode(V.input_value_id,csr2_rd,
		fnd_date.canonical_to_date(V.Screen_entry_value),null)) csr3_reg_date
	,max(decode(V.input_value_id,csr2_ft,
		V.Screen_entry_value,null))                   csr3_fuel_type
	,max(decode(V.input_value_id,csr2_cc,
		nvl(fnd_number.canonical_to_number(v.Screen_entry_value),0),null)) csr3_engine_cc
	,max(decode(V.input_value_id,csr2_fs,
		fnd_number.canonical_to_number(V.Screen_entry_value),null))        csr3_fuel_scale
	,max(decode(V.input_value_id,csr2_ap,
		nvl(fnd_number.canonical_to_number(V.Screen_entry_value),0),null)) csr3_payment
        ,EENT.effective_end_date                              csr3_end_date
        ,EENT.effective_start_date                            csr3_start_date
  FROM          pay_element_entries_f           EENT
        ,       pay_element_links_f             LINK
        ,       pay_element_entry_values_f      V
  WHERE         EENT.effective_end_date         >= v_tax_year_start
        AND     EENT.effective_start_date       <=
                 least(p_term_date,p_end_of_period_date,v_tax_year_end)
        AND     EENT.assignment_id              = p_assignment_id
        AND     LINK.element_type_id            = p_element_type_id
        AND     EENT.element_link_id            = LINK.element_link_id
        AND     EENT.effective_start_date       >= LINK.effective_start_date
        AND     EENT.effective_end_date         <= LINK.effective_end_date
        AND     EENT.entry_type			= 'E'
        AND     V.Element_entry_id              = EENT.element_entry_id
        AND     V.Effective_start_date          = EENT.effective_start_date
        group by EENT.effective_end_date, EENT.effective_start_date;
--
--
  BEGIN
--
-- Get the session date
      csr0_session_date := nicar_session_date(0);
--
--
-- Get the tax year start and end dates from the session date;
--
    v_tax_year_start := uk_tax_yr_start(csr0_session_date);
    v_tax_year_end := uk_tax_yr_end(csr0_session_date);
--
--
-- Get the max allowable price,  and the contrib rate
--
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',10);
    open csr1_globals;
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',20);
    fetch csr1_globals
      into        csr1_price_max
	,	csr1_ni_rate;
    close csr1_globals;
--
--
-- Get the element_name for the element type id, and all the associated
-- input value ids.
--
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',30);
    open csr2_pri_sec;
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',40);
    fetch csr2_pri_sec
      into        csr2_element_name
		, csr2_pr
		, csr2_rd
		, csr2_rn
		, csr2_mb
		, csr2_ft
		, csr2_cc
		, csr2_fs
		, csr2_ap
;
    close csr2_pri_sec;
--
--
-- Set the primary/Secondary indicator according to the element name
--
    if csr2_element_name = 'NI Car Primary'
    then
      v_pri_sec_ind := 'P';
    else
      v_pri_sec_ind := 'S';
    end if;
--
--
-- Get the required details for all company car benefits for the assignment
--
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',50);
    open csr3_nicar;
--
    hr_utility.set_location('hr_gbnicar.nicar_class1a_ytd',60);
    loop
        fetch csr3_nicar
        into    csr3_price
        ,       csr3_mileage_band
        ,       csr3_reg_date
	,	csr3_fuel_type
	,	csr3_engine_cc
        ,       csr3_fuel_scale
        ,       csr3_payment
        ,       csr3_end_date
        ,       csr3_start_date;
--
        exit when csr3_nicar%notfound;
--
--
-- If appropriate, get fuel scale charge from user table
-- A manually entered fuel scale value will always take precedence
-- so check it first.
-- If no fuel scale entered, check fuel type and engine cc
-- If valid, get the right charge from the table
--
    if csr3_fuel_scale is not null
    then
      v_fuel_scale := csr3_fuel_scale;
    else
        if csr3_fuel_type is null
        then
           v_fuel_scale := 0;
        else
           v_fuel_scale :=
                       fnd_number.canonical_to_number(hruserdt.get_table_value(p_business_group_id,
                                                           'FUEL_SCALE',
                                                           csr3_fuel_type,
                                                           csr3_engine_cc,
                                                           csr0_session_date));
	end if;
    end if;
--
        v_running_total := v_running_total +
                       ( trunc (csr1_ni_rate *
			   trunc( nicar_niable_value(csr3_price,
                                        csr1_price_max,
                                        csr3_mileage_band,
                                        v_pri_sec_ind,
                                        csr3_reg_date,
                                        v_fuel_scale,
                                        csr3_payment,
                                        greatest(csr3_start_date,
                                                 v_tax_year_start),
                                        least(csr3_end_date,
                                              p_end_of_period_date,
                                              p_term_date),
                                        v_tax_year_end)
				),2));
    end loop;
--
    close csr3_nicar;
--
    RETURN v_running_total;
--
  end nicar_class1a_ytd;
----------------------------------------------------------------------------------
--                                                                              --
--                          NICAR_DAYS_BETWEEN                                  --
--                                                                              --
----------------------------------------------------------------------------------
  function nicar_days_between
     (p_start_date      date,
      p_end_date        date)
    return number is
--
  v_start_feb          date := last_day(to_date('01-02-'||to_char(p_start_date,'YYYY'),'DD-MM-YYYY'));
  v_end_feb            date := last_day(to_date('01-02-'||to_char(p_end_date,'YYYY'),'DD-MM-YYYY'));
  v_start_ld           number(2) := 0;
  v_end_ld             number(2) := 0;
  v_days_between       number := 0;
--
  begin
    v_days_between := p_end_date - p_start_date +1;
    v_start_ld := to_number(to_char(v_start_feb,'DD'));
    v_end_ld := to_number(to_char(v_end_feb,'DD'));
--
    if (v_start_ld = 29 and v_start_feb between p_start_date and p_end_date) or
       (v_end_ld = 29 and v_end_feb between p_start_date and p_end_date) then
          v_days_between := v_days_between -1;
    end if;
--
  return v_days_between;
--
  end nicar_days_between;
----------------------------------------------------------------------------------
--                                                                              --
--                          NICAR_NIABLE_VALUE                                  --
--                                                                              --
----------------------------------------------------------------------------------
  function nicar_niable_value
     (p_price           number,
      p_price_cap       number,
      p_mileage_factor  number,
      p_pri_sec_ind     char,
      p_reg_date        date,
      p_fuel_scale      number,
      p_ann_payment     number,
      p_start_date      date,
      p_end_date        date,
      p_tax_end_date    date)
    return number is
--
        v_price               number;
        v_mileage_factor      number;
        v_age_factor          number;
        v_days                number;
        v_net_car_benefit     number;
        v_niable_car_benefit  number;

        v_reg_date            date;
        v_start_date          date;
        v_end_date            date;
        v_tax_end_date        date;
--
	csr1_value            varchar2(20);
	csr1_car_benefit      number;
--
cursor csr1_car_ben (cp_age_factor IN NUMBER,
		     cp_primary_ind IN VARCHAR2,
		     cp_mileage_factor IN NUMBER,
		     cp_date IN DATE) is
SELECT  puc.value
FROM    pay_user_column_instances_f puc,
	pay_user_columns col,
	pay_user_rows_f ur,
	pay_user_tables tab
WHERE   tab.user_table_id = col.user_table_id
AND     col.user_column_id = puc.user_column_id
AND     puc.user_row_id = ur.user_row_id
AND     tab.user_table_name = 'NI_CAR_BENEFIT'
--AGE BAND
AND     col.user_column_name =
	    DECODE(cp_primary_ind,
	           'P',DECODE(cp_age_factor,
			      2,'CAR_1_OVER_4','CAR_1_UNDER_4'),
                   'S',DECODE(cp_age_factor,
			      2,'CAR_2_OVER_4','CAR_2_UNDER_4'))
--MILEAGE BAND
AND  ur.user_row_id = (SELECT ur.user_row_id
                       FROM   pay_user_column_instances_f puc,
                              pay_user_columns col,
                              pay_user_tables tab,
                              pay_user_rows_f ur
                       WHERE  col.user_table_id = tab.user_table_id
                       AND    col.user_column_id = puc.user_column_id
                       AND    ur.user_row_id = puc.user_row_id
                       AND    tab.user_table_name = 'NI_CAR_BENEFIT'
                       AND    col.user_column_name = 'LABEL'
                       AND    cp_mileage_factor = to_number(puc.value)
                       AND    cp_date between
                           puc.effective_start_date AND puc.effective_end_date
                       AND    cp_date between
		 ur.effective_start_date AND ur.effective_end_date)
--
AND     cp_date BETWEEN
	puc.effective_start_date AND puc.effective_end_date
AND     cp_date BETWEEN
	ur.effective_start_date AND ur.effective_end_date;
--

  begin
--
-- Make sure the mileage factor is an integer,
-- also strip any time element from the date parameters
--
    v_mileage_factor := trunc(p_mileage_factor);
    v_reg_date := trunc(p_reg_date);
    v_start_date := trunc(p_start_date);
    v_end_date := trunc(p_end_date);
    v_tax_end_date := trunc(p_tax_end_date);
--
    if p_price <0
    then
          hr_utility.set_message(801,'HR_7361_LOC_INVALID_PRICE');
          hr_utility.raise_error;
    elsif v_mileage_factor not between 1 and 3
    then
          hr_utility.set_message(801,'HR_7366_LOC_INVALID_MILEAGE');
          hr_utility.raise_error;
    elsif v_reg_date > v_tax_end_date
    then
          hr_utility.set_message(801,'HR_7367_LOC_INVALID_REG_DATE');
          hr_utility.raise_error;
    elsif v_reg_date > v_start_date
    then
          hr_utility.set_message(801,'HR_7367_LOC_INVALID_REG_DATE');
          hr_utility.raise_error;
    elsif p_fuel_scale <0
    then
          hr_utility.set_message(801,'HR_7368_LOC_INVALID_FUELCHG');
          hr_utility.raise_error;
    elsif p_ann_payment <0
    then
          hr_utility.set_message(801,'HR_7369_LOC_INVALID_ANN_PAY');
          hr_utility.raise_error;
    end if;
--
-- Check price against price cap
--
    if p_price > p_price_cap
    then
          v_price := p_price_cap;
    else
          v_price := p_price;
    end if;
--
-- Set age factor according to whether or not registration date
-- is more than 4 years older than the tax year end date
--
    if add_months(v_tax_end_date,-48) > v_reg_date
    then
          v_age_factor := 2;
    else
          v_age_factor := 3;
    end if;
--
--  Derive availability days from start and end dates
--
    v_days := hr_gbnicar.nicar_days_between (v_start_date,v_end_date);
--
--  Now derive the net car benefit
--
    hr_utility.set_location('hr_gbnicar.nicar_niable_value',10);
    open csr1_car_ben(v_age_factor,
		      p_pri_sec_ind,
		      v_mileage_factor,
		      v_tax_end_date);
    hr_utility.set_location('hr_gbnicar.nicar_niable_value',20);
    fetch csr1_car_ben
	into    csr1_value;
    close csr1_car_ben;
--
    csr1_car_benefit := to_number(csr1_value);
--
    v_net_car_benefit := (v_price * csr1_car_benefit)/100;
--
--  Now adjust the net car benefit by the annual payment.
--  Note that under current legislation, any payment in excess
--  of the net car benefit is NOT allowed to reduce the fuel
--  scale charge, and therefore any negative result here must
--  be forced to zero before adding the fuel scale charge
--
    v_net_car_benefit := v_net_car_benefit - p_ann_payment;
    if v_net_car_benefit < 0
    then
          v_net_car_benefit := 0;
    end if;
--
--  Finally derive niable car benefit from net car benefit
--  and fuel scale charge, and pro-rate according to
--  availability
--
    v_niable_car_benefit := trunc((v_net_car_benefit + p_fuel_scale)
                                  * v_days / 365);
--
	return v_niable_car_benefit;
--
  end nicar_niable_value;
--
----------------------------------------------------------------------------------
--                                                                              --
--                          NICAR_PAYMENT_YTD                                   --
--                                                                              --
----------------------------------------------------------------------------------
  function nicar_payment_ytd
     (
      p_assignment_id       number,
      p_element_type_id     number,
      p_end_of_period_date  date,
      p_term_date           date
     )
  return number is
--
--  N.B. p_assignment_id and p_element_type_id are provided via
--  context-set variables
--
    f_tax_year_start                date;
    f_tax_year_end          date;
--
    c_session_date          date;
    c_start_date            date;
    c_end_date              date;
    c_payment               number;
    c_price                 number;
--
    v_start_date            date;
    v_end_date              date;
    v_days                  number := 0;
--
    f_running_total         number :=0;
--
    cursor c1_nicar_payment is
-- bug 504994 changed the entry cursor to use a single join on values table
-- to improve performance
    SELECT      max(decode(I.name,'Payment',
			nvl(fnd_number.canonical_to_number(V.screen_entry_value),0),null)) Payment
        ,       max(decode(I.name,'Price',
			fnd_number.canonical_to_number(V.screen_entry_value),null)) Price
        ,       EENT.effective_end_date
        ,       EENT.effective_start_date
    FROM        pay_element_entries_f           EENT
        ,       pay_element_links_f             LINK
        ,       pay_element_entry_values_f      V
        ,       pay_input_values_x              I
    WHERE       EENT.effective_end_date         >= f_tax_year_start
        AND     EENT.effective_start_date       <=
                  least(p_term_date,p_end_of_period_date,f_tax_year_end)
        AND     EENT.assignment_id              = p_assignment_id
        AND     LINK.element_type_id            = p_element_type_id
        AND     EENT.element_link_id            = LINK.element_link_id
        AND     EENT.effective_start_date       >= LINK.effective_start_date
        AND     EENT.effective_end_date         <= LINK.effective_end_date
	AND     EENT.entry_type			= 'E'
        AND     I.element_type_id  	        = p_element_type_id
					+ decode(EENT.element_entry_id,0,0,0)
        AND     V.element_entry_id              = EENT.element_entry_id
        AND     V.input_value_id       		= I.input_value_id
					+ decode(EENT.element_entry_id,0,0,0)
        AND     V.effective_start_date          = EENT.effective_start_date
        AND     V.effective_end_date            = EENT.effective_end_date
	group by EENT.effective_end_date, EENT.effective_start_date;
--
    begin
--
-- Get the session date
--
      c_session_date := nicar_session_date(0);
--
-- Now get the tax year start and end dates from the session date;
--
    f_tax_year_start := uk_tax_yr_start(c_session_date);
    f_tax_year_end := uk_tax_yr_end(c_session_date);
--
--  Get the sum of all annual payments and pro-rate
--
    hr_utility.set_location('hr_gbnicar.nicar_payment_ytd',10);
    open c1_nicar_payment;
--
    hr_utility.set_location('hr_gbnicar.nicar_payment_ytd',20);
    loop
        fetch c1_nicar_payment
        into    c_payment,
		c_price,
                c_end_date,
                c_start_date;
        exit when c1_nicar_payment%notfound;
--
--  If the price found is 0, don't add the annual payment to the
--  running total
--
        if c_price >0
        then
          v_start_date := greatest(c_start_date,
                                   f_tax_year_start);
          v_end_date := least(p_end_of_period_date,
                              c_end_date,
                              p_term_date);
          v_days := hr_gbnicar.nicar_days_between(v_start_date, v_end_date);

          f_running_total := f_running_total +
                             trunc((c_payment * v_days / 365),2);
        end if;
    end loop;
--
    close c1_nicar_payment;
--
    return f_running_total;
--
  end nicar_payment_ytd;
--
----------------------------------------------------------------------------------
--                                                                              --
--                          NICAR_SESSION_DATE                                  --
--                                                                              --
----------------------------------------------------------------------------------
  function nicar_session_date
    (p_dummy number)
    return date is
        c_session_date          date;
--
    cursor c0_effdate is
    SELECT          effective_date
    FROM            fnd_sessions
    WHERE           session_id = userenv('sessionid');
--
  begin
--
-- Get the session date from fnd_sessions
--
    hr_utility.set_location('hr_gbnicar.nicar_session_date',10);
    open c0_effdate;
    hr_utility.set_location('hr_gbnicar.nicar_session_date',20);
    fetch c0_effdate into c_session_date;
    if c0_effdate%notfound
    then
      c_session_date := trunc(sysdate);
    end if;
    close c0_effdate;
    return c_session_date;
  end nicar_session_date;
--
----------------------------------------------------------------------------------
--                                                                              --
--                           UK_TAX_YR_START                                    --
--                                                                              --
----------------------------------------------------------------------------------
  function uk_tax_yr_start
     (p_input_date  date)
    return date is
        f_year                  number(4);
        f_start_dd_mon          varchar2(7) := '06-04-';
        f_tax_year_start        date;
--
  begin
    f_year := to_number(to_char(p_input_date,'YYYY'));
--
    if p_input_date >= to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY')
    then
      f_tax_year_start := to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY');
    else
      f_tax_year_start := to_date(f_start_dd_mon||to_char(f_year -1),'DD-MM-YYYY');
    end if;
--
    return f_tax_year_start;
  end uk_tax_yr_start;
--
----------------------------------------------------------------------------------
--                                                                              --
--                           UK_TAX_YR_END                                      --
--                                                                              --
----------------------------------------------------------------------------------
  function uk_tax_yr_end
     (p_input_date  date)
   return date is
	f_year 			number(4);
	f_end_dd_mon 		varchar2(7) := '05-04-';
	f_tax_year_end		date;
--
  begin
    f_year := to_number(to_char(p_input_date,'YYYY'));
--
    if p_input_date > to_date(f_end_dd_mon||to_char(f_year),'DD-MM-YYYY')
    then
      f_tax_year_end := to_date(f_end_dd_mon||to_char(f_year +1),'DD-MM-YYYY');
    else
      f_tax_year_end := to_date(f_end_dd_mon||to_char(f_year),'DD-MM-YYYY');
    end if;
--
    return f_tax_year_end;
--
  end uk_tax_yr_end;
--
--
--
end hr_gbnicar;

/
