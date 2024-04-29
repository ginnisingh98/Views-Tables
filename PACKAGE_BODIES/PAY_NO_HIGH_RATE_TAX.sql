--------------------------------------------------------
--  DDL for Package Body PAY_NO_HIGH_RATE_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_HIGH_RATE_TAX" as
/* $Header: pynohtax.pkb 120.8.12010000.2 2009/03/10 13:44:38 vijranga ship $ */
 --

 /* commenting FUNCTION get_tax_values_high_rate and creating new function to remove
    hard-coded user table names for high rate tax tables. */

 /*

 FUNCTION get_tax_values_high_rate    (
				     p_business_group_id IN number
                            ,p_Date_Earned  IN DATE
                            ,p_table_name          IN VARCHAR2
                            ,p_freq            IN VARCHAR2
                            ,p_ptd_amount         IN VARCHAR2
                            ,p_high_tax OUT NOCOPY VARCHAR2
                            ,p_high_tax_base OUT NOCOPY VARCHAR2
                            ,p_high_rate_tax OUT NOCOPY VARCHAR2) return varchar2 IS
 l_high_tax	 	number;
 l_high_tax_base 	number;
 l_high_rate_tax	number;
 l_test_table_name	varchar2(100);
 l_default_table_name	varchar2(100);
 l_test_flag		varchar2(1);
 l_user_table_id	number;
 l_user_row_id		number;
 l_user_colunm_id	number;
 l_pc_value		number;
 l_low_L		varchar2(100);
 l_high_L		varchar2(100);
 l_low_user_row_id	number;
 l_low_pc		varchar2(100);
 l_high_pc		varchar2(100);
 l_test_L		varchar2(100);
 l_test_H		varchar2(100);
 l_sub_high_band_low    varchar2(100);
 l_high_band_high       varchar2(100);
 l_tax_base		number;
 l_low_range_tax 	number;
 l_high_range_tax	number;
 l_total_deduction 	number;
 cursor c_get_name(l_table_name VARCHAR2) is
 	select 'Y'
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO' ;
 cursor c_get_table_id(l_table_name VARCHAR2) is
 	select user_table_id
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';
 cursor c_get_column_id (l_freq VARCHAR2 , l_table_id number) is
 	select user_column_id
 	from PAY_USER_COLUMNS
 	where USER_TABLE_ID = l_table_id
 	AND user_column_name = l_freq;
 cursor c_get_pc_value (l_column_id number , l_date date , l_table_id number , l_ptd_amount varchar2) is
 	select VALUE , user_row_id
 	from pay_user_column_instances_f
 	where user_column_id = l_column_id
 	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 	AND user_row_id in (select user_row_id from  pay_user_rows_f where
 			     	user_table_id = l_table_id and to_number(l_ptd_amount) between to_number(row_low_range_or_name) and to_number(row_high_range)
 			     	AND l_date  between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE);
 cursor c_get_row_details (l_row_id number , l_date date) is
 	select ROW_LOW_RANGE_OR_NAME , ROW_HIGH_RANGE
 	from PAY_USER_ROWS_F
 	where USER_ROW_ID = l_row_id
 	AND l_date BETWEEN EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
 cursor c_get_low_details (l_high_row_id number , l_date date , l_column_id number ) is
 	select VALUE , user_row_id
 	from pay_user_column_instances_f
 	where user_column_id = l_column_id
 	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 	AND user_row_id <> l_high_row_id;
 begin
 l_test_flag := 'N';
 l_default_table_name := 'Norway_high_rate_table_7100_to_7231';
 OPEN c_get_name(p_table_name);
 FETCH c_get_name into l_test_flag;
 CLOSE c_get_name;
 IF l_test_flag <> 'Y' THEN
 	l_test_table_name := l_default_table_name;
 ELSE
	l_test_table_name := p_table_name;
 END IF;
 OPEN c_get_table_id(l_test_table_name);
 FETCH c_get_table_id into l_user_table_id;
 CLOSE c_get_table_id;
 OPEN c_get_column_id(p_freq , l_user_table_id);
 FETCH c_get_column_id into l_user_colunm_id;
 CLOSE c_get_column_id;
 OPEN c_get_pc_value(l_user_colunm_id , p_Date_Earned , l_user_table_id , p_ptd_amount);
 FETCH c_get_pc_value into l_pc_value , l_user_row_id;
 CLOSE c_get_pc_value;
 OPEN c_get_row_details(l_user_row_id , p_Date_Earned );
 FETCH c_get_row_details into l_test_L , l_test_H;
 CLOSE c_get_row_details;
If l_test_table_name in ('Norway_high_rate_table_7500' ,'Norway_high_rate_table_7350','Norway_high_rate_table_7600','Norway_high_rate_table_7650') then
	l_test_H := 999999;
end if;
 IF to_number(l_test_H) = to_number('999999') THEN
 	l_high_pc := l_pc_value;
	If p_freq = '1' and l_test_table_name <> 'Norway_high_rate_table_7100P_to_7231P' then
		if p_freq = '1' and l_test_table_name = 'Norway_high_rate_table_7500' then
			l_high_range_tax := (to_number(p_ptd_amount) - to_number('90001')) * to_number('39') / 100;
			l_low_range_tax := 0;
			l_high_tax := l_low_range_tax + l_high_range_tax;
			l_high_rate_tax := to_number('90000')	;
			l_high_rate_tax := to_number('90000')	;
		elsif p_freq = '1' and l_test_table_name = 'Norway_high_rate_table_7350' then
			l_high_range_tax := (to_number(p_ptd_amount) - to_number('90001')) * to_number('47') / 100;
			l_low_range_tax := 0;
			l_high_tax := l_low_range_tax + l_high_range_tax;
			l_high_rate_tax := to_number('90000')	;
			l_high_rate_tax := to_number('90000')	;
		elsif p_freq = '1' and l_test_table_name = 'Norway_high_rate_table_7600' then
			l_high_range_tax := (to_number(p_ptd_amount) - to_number('90001')) * to_number('39') / 100;
			l_low_range_tax := 0;
			l_high_tax := l_low_range_tax + l_high_range_tax;
			l_high_rate_tax := to_number('90000')	;
			l_high_rate_tax := to_number('90000')	;
		elsif p_freq = '1' and l_test_table_name = 'Norway_high_rate_table_7650' then
			l_high_range_tax := (to_number(p_ptd_amount) - to_number('90001')) * to_number('45') / 100;
			l_low_range_tax := 0;
			l_high_tax := l_low_range_tax + l_high_range_tax;
			l_high_rate_tax := to_number('90000')	;
			l_high_rate_tax := to_number('90000')	;
		else
	        	OPEN c_get_row_details(l_user_row_id, p_Date_Earned );
		        FETCH c_get_row_details into l_sub_high_band_low, l_high_band_high;
	        	CLOSE c_get_row_details;
			l_high_range_tax := (to_number(p_ptd_amount) - to_number(l_sub_high_band_low)+1) * to_number(l_high_pc) / 100;
			l_low_range_tax := 0;
			l_high_tax := l_low_range_tax + l_high_range_tax;
			l_high_rate_tax := to_number(l_sub_high_band_low);
		end if;
	elsif p_freq = '7' and l_test_table_name <> 'Norway_high_rate_table_7100_to_7231' then
		OPEN c_get_row_details(l_user_row_id, p_Date_Earned );
	        FETCH c_get_row_details into l_sub_high_band_low, l_high_band_high;
	        CLOSE c_get_row_details;
		l_high_range_tax := (to_number(p_ptd_amount) - to_number(l_sub_high_band_low)+1) * to_number(l_high_pc) / 100;
		l_low_range_tax := 0;
		l_high_tax := l_low_range_tax + l_high_range_tax;
		l_high_rate_tax := to_number(l_sub_high_band_low)	;
	else
 		OPEN c_get_low_details(l_user_row_id,p_Date_Earned,l_user_colunm_id);
	 	FETCH c_get_low_details into l_low_pc, l_low_user_row_id;
	 	CLOSE c_get_low_details;
	 	OPEN c_get_row_details(l_low_user_row_id , p_Date_Earned );
		FETCH c_get_row_details into l_low_L , l_high_L;
		CLOSE c_get_row_details;
	        OPEN c_get_row_details(l_user_row_id, p_Date_Earned );
        	FETCH c_get_row_details into l_sub_high_band_low, l_high_band_high;
	        CLOSE c_get_row_details;
	 	l_tax_base := to_number(p_ptd_amount) - to_number(l_low_L);
 		l_low_range_tax := ((to_number(l_sub_high_band_low)-1) - to_number(l_low_L)) * to_number(l_low_pc) / 100;
	 	l_high_range_tax := (to_number(p_ptd_amount) - to_number(l_sub_high_band_low)+1) * to_number(l_high_pc) / 100;
	 	l_high_tax := l_low_range_tax + l_high_range_tax;
	 	l_high_rate_tax := l_low_L;
	end if;
 ELSE
 	l_low_pc := l_pc_value;
 	l_tax_base := to_number(p_ptd_amount) - to_number(l_test_L);
 	l_high_tax := (to_number(p_ptd_amount) - to_number(l_test_L)) * to_number(l_low_pc) / 100 ;
 	l_high_rate_tax := l_test_L;
 END IF;
  	p_high_rate_tax := l_high_rate_tax;
 	p_high_tax := l_high_tax;
 	p_high_tax_base := l_high_tax_base;
 RETURN '1';
 END get_tax_values_high_rate;

*/

 /* commented above function get_tax_values_high_rate and creating new function to remove
    hard-coded user table names for high rate tax tables. */

---------------------------------------------------------------------------------------------------------
 FUNCTION get_tax_values_high_rate    (
				     p_business_group_id IN number
                            ,p_Date_Earned  IN DATE
                            ,p_table_name          IN VARCHAR2
                            ,p_freq            IN VARCHAR2
                            ,p_ptd_amount         IN VARCHAR2
                            ,p_high_tax OUT NOCOPY VARCHAR2
                            ,p_high_tax_base OUT NOCOPY VARCHAR2
                            ,p_high_rate_tax OUT NOCOPY VARCHAR2) return varchar2 IS


 l_high_tax	 	number;
 l_high_tax_base 	number;
 l_high_rate_tax	number;
 l_test_table_name	varchar2(100);
 l_default_table_name	varchar2(100);
 l_test_flag		varchar2(10);
 l_user_table_id	number;
 l_user_row_id		number;
 l_user_colunm_id	number;
 l_pc_value		number;
 l_low_L		varchar2(100);
 l_high_L		varchar2(100);
 l_low_user_row_id	number;
 l_low_pc		varchar2(100);
 l_high_pc		varchar2(100);
 l_test_L		varchar2(100);
 l_test_H		varchar2(100);
 l_sub_high_band_low    varchar2(100);
 l_high_band_high       varchar2(100);
 l_tax_base		number;
 l_low_range_tax 	number;
 l_high_range_tax	number;
 l_total_deduction 	number;


 cursor c_get_name(l_table_name VARCHAR2) is
 	select 'Y'
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO' ;


 cursor c_get_table_id(l_table_name VARCHAR2) is
 	select user_table_id
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';


 cursor c_get_column_id (l_freq VARCHAR2 , l_table_id number) is
 	select user_column_id
 	from PAY_USER_COLUMNS
 	where USER_TABLE_ID = l_table_id
 	AND user_column_name = l_freq;


 cursor c_get_pc_value (l_column_id number , l_date date , l_table_id number , l_ptd_amount varchar2) is
 	select VALUE , user_row_id
 	from pay_user_column_instances_f
 	where user_column_id = l_column_id
 	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 	AND user_row_id in (select user_row_id
			    from  pay_user_rows_f
			    where user_table_id = l_table_id
			    and to_number(l_ptd_amount) between to_number(row_low_range_or_name) and to_number(row_high_range)
 			    and l_date  between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE);


 cursor c_get_row_details (l_row_id number , l_date date) is
 	select ROW_LOW_RANGE_OR_NAME , ROW_HIGH_RANGE
 	from PAY_USER_ROWS_F
 	where USER_ROW_ID = l_row_id
 	AND l_date BETWEEN EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;


 cursor c_get_low_details (l_high_row_id number , l_date date , l_column_id number ) is
 	select VALUE , user_row_id
 	from pay_user_column_instances_f
 	where user_column_id = l_column_id
 	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 	AND user_row_id <> l_high_row_id;

 begin

 l_test_flag := 'N';
 -- 2009 Legislative changes renamed user table from 7231 to 7233
 l_default_table_name := 'Norway_high_rate_table_7100_to_7233';

 OPEN c_get_name(p_table_name);
 FETCH c_get_name into l_test_flag;
 CLOSE c_get_name;

 IF l_test_flag <> 'Y' THEN
 	l_test_table_name := l_default_table_name;
 ELSE
	l_test_table_name := p_table_name;
 END IF;

 OPEN c_get_table_id(l_test_table_name);
 FETCH c_get_table_id into l_user_table_id;
 CLOSE c_get_table_id;

 OPEN c_get_column_id(p_freq , l_user_table_id);
 FETCH c_get_column_id into l_user_colunm_id;
 CLOSE c_get_column_id;

 OPEN c_get_pc_value(l_user_colunm_id , p_Date_Earned , l_user_table_id , p_ptd_amount);
 FETCH c_get_pc_value into l_pc_value , l_user_row_id;
 CLOSE c_get_pc_value;

 OPEN c_get_row_details(l_user_row_id, p_Date_Earned );
 FETCH c_get_row_details into l_test_L , l_test_H;
 CLOSE c_get_row_details;

 IF to_number(l_test_H) = to_number('999999') THEN

	l_high_pc := l_pc_value;

	/* since l_test_H = 999999, we are in the high band; find out if there is a low band also */

	OPEN c_get_low_details(l_user_row_id,p_Date_Earned,l_user_colunm_id);
	FETCH c_get_low_details into l_low_pc, l_low_user_row_id;
	CLOSE c_get_low_details;

	IF (l_low_user_row_id IS NOT NULL) THEN

		/* low band exists */
		/* get row limits of the low band */

		OPEN c_get_row_details(l_low_user_row_id , p_Date_Earned );
		FETCH c_get_row_details into l_low_L , l_high_L;
		CLOSE c_get_row_details;

		l_high_tax_base := to_number(p_ptd_amount) - ( to_number(l_low_L) - 1 );
		l_low_range_tax := ( to_number(l_test_L) - to_number(l_low_L) ) * to_number(l_low_pc) / 100 ;
		l_high_range_tax := ( to_number(p_ptd_amount) - ( to_number(l_test_L) - 1 ) ) * to_number(l_high_pc) / 100 ;
		l_high_tax := l_low_range_tax + l_high_range_tax ;
		l_high_rate_tax := to_char(( to_number(l_low_L) - 1 )) ;

	ELSE
		/* low band does not exists */
		/* do only high band calculation */
		l_high_tax_base := to_number(p_ptd_amount) - ( to_number(l_low_L) - 1 );
		l_low_range_tax := 0 ;
		l_high_range_tax := ( to_number(p_ptd_amount) - ( to_number(l_test_L) - 1 ) ) * to_number(l_high_pc) / 100 ;
		l_high_tax := l_low_range_tax + l_high_range_tax ;
		l_high_rate_tax := to_char(( to_number(l_low_L) - 1 )) ;
	END IF;

 ELSE
	/* we are already in the low band , there is no high band; so calculate only low band tax */
	l_low_pc := l_pc_value;
 	l_high_tax_base := to_number(p_ptd_amount) - ( to_number(l_test_L) - 1 );
	l_high_tax := ( to_number(p_ptd_amount) - ( to_number(l_test_L) - 1 ) ) * to_number(l_low_pc) / 100 ;
	l_high_rate_tax := to_char(( to_number(l_test_L) - 1 )) ;

 END IF;

p_high_rate_tax := l_high_rate_tax;
p_high_tax	:= l_high_tax;
p_high_tax_base := l_high_tax_base;

 RETURN '1';

 END get_tax_values_high_rate;

---------------------------------------------------------------------------------------------------------

 --
  --
  FUNCTION get_start_range    (
                              p_Date_Earned  IN DATE
                             ,p_business_group_id IN number
                             ,p_table_name          IN VARCHAR2
                             ,p_freq            IN VARCHAR2
                             ,p_ptd_amount         IN VARCHAR2
                             ,p_start_range OUT NOCOPY VARCHAR2) return varchar2 IS

  l_test_flag		varchar2(1);
  l_user_table_id	number;
  l_user_row_id		number;
  l_user_colunm_id	number;
  l_test_table_name	varchar2(100);
  l_default_table_name	varchar2(100);
  l_start_value		varchar2(100);
  l_column_name 	varchar2(100);

  cursor c_get_name(l_table_name VARCHAR2) is
  	select 'Y'
  	from PAY_USER_TABLES
  	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';

  cursor c_get_table_id(l_table_name VARCHAR2) is
  	select user_table_id
  	from PAY_USER_TABLES
  	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';

  cursor c_get_column_id (l_freq VARCHAR2 , l_table_id number) is
  	select user_column_id
  	from PAY_USER_COLUMNS
  	where USER_TABLE_ID = l_table_id
  	AND user_column_name = l_freq;

/*
  cursor c_get_start_value (l_table_id number , l_column_id number , l_ptd_amount varchar2 , l_date date) is
  	select value
  	from pay_user_column_instances_f
  	where user_column_id = l_column_id
  	AND user_row_id in (select user_row_id from pay_user_rows_f
  	where user_table_id = l_table_id AND l_date between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
  	AND to_number(l_ptd_amount) between to_number(ROW_LOW_RANGE_OR_NAME) and to_number(ROW_HIGH_RANGE));
*/

/* Modified cursor c_get_start_value to include effective date check */

  cursor c_get_start_value (l_table_id number , l_column_id number , l_ptd_amount varchar2 , l_date date) is
  	select value
  	from pay_user_column_instances_f
  	where user_column_id = l_column_id
  	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
  	AND user_row_id in (select user_row_id from pay_user_rows_f
  	where user_table_id = l_table_id AND l_date between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
  	AND to_number(l_ptd_amount) between to_number(ROW_LOW_RANGE_OR_NAME) and to_number(ROW_HIGH_RANGE));


  begin

  l_test_flag := 'N';
  -- 2009 Legislative changes renamed user table from 7231 to 7233
  l_default_table_name := 'Norway_high_rate_table_7100_to_7233';
  l_column_name := 'START_RANGE_' || p_freq;

  OPEN c_get_name(p_table_name);
  FETCH c_get_name into l_test_flag;
  CLOSE c_get_name;

 /* IF l_test_flag = 'Y' THEN
  	l_test_table_name := p_table_name;
  ELSE
  	l_test_table_name := l_default_table_name;
  END IF;
*/

If l_test_flag <>'Y' then
  	l_test_table_name := l_default_table_name;
Else
  	l_test_table_name := p_table_name;
end if;

  OPEN c_get_table_id(l_test_table_name);
  FETCH c_get_table_id into l_user_table_id;
  CLOSE c_get_table_id;

  OPEN c_get_column_id(l_column_name , l_user_table_id);
  FETCH c_get_column_id into l_user_colunm_id;
  CLOSE c_get_column_id;

  OPEN c_get_start_value(l_user_table_id , l_user_colunm_id , p_ptd_amount , p_Date_Earned );
  FETCH c_get_start_value into l_start_value;
  CLOSE c_get_start_value;

  p_start_range := l_start_value;

/*
If p_freq = '1' and l_test_table_name in ('Norway_high_rate_table_7350','Norway_high_rate_table_7500','Norway_high_rate_table_7600','Norway_high_rate_table_7650') then
	p_start_range := '90000';
end if;
*/

  RETURN '1';

  END get_start_range;

---------------------------------------------------------------------------------------------------------

/* Commented to use the Tax table upload logic on 19th May 2005
 --
 FUNCTION get_normal_tax    (
				     p_Date_Earned  IN DATE
                             ,p_business_group_id IN number
                             ,p_table_name          IN VARCHAR2
                             ,p_freq            IN VARCHAR2
                             ,p_type            IN VARCHAR2
                             ,p_ptd_amount         IN VARCHAR2
                             ,p_normal_tax OUT NOCOPY VARCHAR2) return varchar2 IS
 l_high_tax	 	number;
 l_high_tax_base 	number;
 l_high_rate_tax	number;
 l_test_table_name	varchar2(100);
 l_default_table_name	varchar2(100);
 l_test_flag		varchar2(1);
 l_user_table_id	number;
 l_user_row_id		number;
 l_user_colunm_id	number;
 l_pc_value		number;
 l_normal_tax	varchar2(100);
 l_tax_value      varchar2(100);
 cursor c_get_name(l_table_name VARCHAR2) is
 	select 'Y'
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';
 cursor c_get_table_id(l_table_name VARCHAR2) is
 	select user_table_id
 	from PAY_USER_TABLES
 	where USER_TABLE_NAME = l_table_name
      and legislation_code = 'NO';
 cursor c_get_column_id (l_freq VARCHAR2 , l_table_id number) is
 	select user_column_id
 	from PAY_USER_COLUMNS
 	where USER_TABLE_ID = l_table_id
 	AND user_column_name = l_freq;
 cursor c_get_tax_value (l_column_id number , l_date date , l_table_id number , l_ptd_amount varchar2) is
 	select VALUE
 	from pay_user_column_instances_f
 	where user_column_id = l_column_id
 	AND l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 	AND user_row_id in (select user_row_id from  pay_user_rows_f where
 			     	user_table_id = l_table_id and to_number(l_ptd_amount) between to_number(row_low_range_or_name) and to_number(row_high_range)
 			     	AND l_date  between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE);
 begin
 l_test_flag := 'N';
 l_default_table_name := 'NORWAY_NORMAL_TAX_TABLE_7100_'||p_type;
 OPEN c_get_name(p_table_name);
 FETCH c_get_name into l_test_flag;
 CLOSE c_get_name;
 IF l_test_flag <> 'Y' THEN
 	l_test_table_name := l_default_table_name;
 ELSE
	l_test_table_name := p_table_name;
 END IF;
 OPEN c_get_table_id(l_test_table_name);
 FETCH c_get_table_id into l_user_table_id;
 CLOSE c_get_table_id;
 OPEN c_get_column_id(p_freq , l_user_table_id);
 FETCH c_get_column_id into l_user_colunm_id;
 CLOSE c_get_column_id;
 OPEN c_get_tax_value(l_user_colunm_id , p_Date_Earned , l_user_table_id , p_ptd_amount);
 FETCH c_get_tax_value into l_tax_value;
 CLOSE c_get_tax_value;
If l_tax_value is null then
	l_tax_value := '0';
End if;
 	p_normal_tax := l_tax_value;
 RETURN '1';
 END get_normal_tax;
 --
End of commented on 19th May 2005.*/
 --
 FUNCTION get_normal_tax    ( p_Date_Earned  IN DATE
                             ,p_business_group_id IN number
                             ,p_table_name          IN VARCHAR2
                             ,p_freq            IN VARCHAR2
                             ,p_type            IN VARCHAR2
                             ,p_ptd_amount         IN VARCHAR2
                             ,p_normal_tax OUT NOCOPY VARCHAR2) return varchar2 IS
 l_normal_tax	number;

/*
 cursor csr_get_normal_tax (l_table_number varchar2 , l_freq varchar2 , l_type varchar2 , l_bg_id number ,l_date date,l_amount varchar2) is
	Select Amount1
 	from PAY_RANGE_TABLES_F PRTF , PAY_RANGES_F PRF
 	where PRTF.range_table_id = PRF.range_table_id
	and PRTF.range_table_number = TO_NUMBER(l_table_number)
	and PRTF.period_frequency = l_freq
	and PRTF.earnings_type = l_type
	and PRTF.business_group_id = l_bg_id
	and PRTF.legislation_code = 'NO'
	and l_date between PRTF.effective_start_date and PRTF.effective_end_date
	and to_number(l_amount)	between PRF.low_band and PRF.high_band
	and l_date between PRF.effective_start_date and PRF.effective_end_date;
*/

-- Bug Fix 5533206, Norwegian Tax Tables will now be uploaded without any Business Group
-- Modifying cursor to check for business_gorup_id IS NULL

 cursor csr_get_normal_tax (l_table_number varchar2 , l_freq varchar2 , l_type varchar2 ,l_date date,l_amount varchar2) is
	Select Amount1
 	from PAY_RANGE_TABLES_F PRTF , PAY_RANGES_F PRF
 	where PRTF.range_table_id = PRF.range_table_id
	and PRTF.range_table_number = TO_NUMBER(l_table_number)
	and PRTF.period_frequency = l_freq
	and PRTF.earnings_type = l_type
	and PRTF.business_group_id IS NULL
	and PRTF.legislation_code = 'NO'
	and l_date between PRTF.effective_start_date and PRTF.effective_end_date
	and to_number(l_amount)	between PRF.low_band and PRF.high_band
	and l_date between PRF.effective_start_date and PRF.effective_end_date;



 begin

	-- open csr_get_normal_tax (p_table_name,p_freq,p_type,p_business_group_id,p_date_earned,p_ptd_amount);

	-- Bug Fix 5533206, Norwegian Tax Tables will now be uploaded without any Business Group
	-- Modifying cursor call

	open csr_get_normal_tax (p_table_name,p_freq,p_type,p_date_earned,p_ptd_amount);
	fetch csr_get_normal_tax into l_normal_tax;
	close csr_get_normal_tax;

If l_normal_tax is null then
	l_normal_tax := 0;
End if;
 	p_normal_tax := to_char(l_normal_tax);
 RETURN '1';
 END get_normal_tax;
  --
  FUNCTION get_reduced_rule    (
                              p_payroll_action_id   IN number
                             ,p_payroll_id          IN VARCHAR2
                             ,p_reduced_rule OUT NOCOPY VARCHAR2) return varchar2 IS
  l_reduced_rule varchar2(80);
  cursor c_get_rule (l_pact_id number , l_payroll_id number) IS
  SELECT ptp.prd_information1
  FROM per_time_periods ptp , pay_payroll_actions ppa
  WHERE ppa.payroll_action_id = l_pact_id
  AND   ppa.action_type in ('Q','R')
  AND   ppa.time_period_id = ptp.time_period_id
  AND   ptp.payroll_id = l_payroll_id;
  begin
  OPEN c_get_rule(p_payroll_action_id , p_payroll_id);
  FETCH c_get_rule into l_reduced_rule;
  CLOSE c_get_rule;
  if l_reduced_rule is null then
  	l_reduced_rule := 'N';
  end if;
  	p_reduced_rule := l_reduced_rule;
  RETURN '1';
  END get_reduced_rule;
 --
 -- Function GET_MESSAGE
 -- This function is used to obtain a message.
 -- The token parameters must be of the form 'TOKEN_NAME:TOKEN_VALUE' i.e.
 -- If you want to set the value of a token called ELEMENT to Tax
 -- the token parameter would be 'ELEMENT:Tax.'
 ------------------------------------------------------------------------
 	function get_message
 			(p_product           in varchar2
 			,p_message_name      in varchar2
 			,p_token1            in varchar2 default null
                         ,p_token2            in varchar2 default null
                         ,p_token3            in varchar2 default null) return varchar2
 			is
 			   l_message varchar2(2000);
 			   l_token_name varchar2(20);
 			   l_token_value varchar2(80);
 			   l_colon_position number;
 			   l_proc varchar2(72) ;
 	--
 	begin
 	--
 	   hr_utility.set_location('Entered '||l_proc,5);
 	   hr_utility.set_location('.  Message Name: '||p_message_name,40);
 	   fnd_message.set_name(p_product, p_message_name);
 	   if p_token1 is not null then
 	      /* Obtain token 1 name and value */
 	      l_colon_position := instr(p_token1,':');
 	      l_token_name  := substr(p_token1,1,l_colon_position-1);
 	      l_token_value := substr(p_token1,l_colon_position+1,length(p_token1));
 	      fnd_message.set_token(l_token_name, l_token_value);
 	      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
 	   end if;
 	   if p_token2 is not null  then
 	      /* Obtain token 2 name and value */
 	      l_colon_position := instr(p_token2,':');
 	      l_token_name  := substr(p_token2,1,l_colon_position-1);
 	      l_token_value := substr(p_token2,l_colon_position+1,length(p_token2));
 	      fnd_message.set_token(l_token_name, l_token_value);
 	      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
 	   end if;
 	   if p_token3 is not null then
 	      /* Obtain token 3 name and value */
 	      l_colon_position := instr(p_token3,':');
 	      l_token_name  := substr(p_token3,1,l_colon_position-1);
 	      l_token_value := substr(p_token3,l_colon_position+1,length(p_token3));
 	      fnd_message.set_token(l_token_name, l_token_value);
 	      hr_utility.set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
 	   end if;
 	   l_message := substr(fnd_message.get,1,254);
 	   hr_utility.set_location('leaving '||l_proc,100);
 	   return l_message;
 	end get_message;
 ------------------------------------------------------------------------

-- Modified function get_prim_tax_card for Legislative changes 2007.

/*
  function get_prim_tax_card (
			      p_assignment_id		IN NUMBER
                             ,p_date_earned		IN DATE
                             ,p_tax_card_type   OUT NOCOPY VARCHAR2
                             ,p_tax_municipality OUT NOCOPY VARCHAR2
                             ,p_tax_percentage   OUT NOCOPY VARCHAR2
                             ,p_tax_table_number OUT NOCOPY VARCHAR2
                             ,p_tax_table_type   OUT NOCOPY VARCHAR2
                             ,p_tft_value        OUT NOCOPY VARCHAR2
			     ,p_tax_card_msg     OUT NOCOPY VARCHAR2 ) return varchar2
*/

  function get_prim_tax_card (
			      p_assignment_id		IN NUMBER
                             ,p_date_earned		IN DATE
			     ,p_assignment_action_id	IN NUMBER
			     ,p_payroll_action_id	IN NUMBER
                             ,p_tax_card_type   OUT NOCOPY VARCHAR2
                             ,p_tax_municipality OUT NOCOPY VARCHAR2
                             ,p_tax_percentage   OUT NOCOPY VARCHAR2
                             ,p_tax_table_number OUT NOCOPY VARCHAR2
                             ,p_tax_table_type   OUT NOCOPY VARCHAR2
                             ,p_tft_value        OUT NOCOPY VARCHAR2
			     ,p_tax_card_msg     OUT NOCOPY VARCHAR2 ) return varchar2
	is
 			   l_tax_card_type varchar2(80);
 			   l_tax_municipality varchar2(80);
 			   l_tax_municipality_num number;
 			   l_tax_percentage varchar2(80);
 			   l_tax_percentage_num number := null;
 			   l_tax_table_number varchar2(80) ;
 			   l_tax_table_type  varchar2(80) ;
 			   l_tft_value  varchar2(80) ;
 			   l_tft_value_num  number(13,2);
 			   l_main_person_id	number;
 			   l_prim_asg_id	number;

			   -- BUG 4774784 fix start

			   l_eeid		NUMBER;
 			   l_full_name		VARCHAR2(240);
 			   l_emp_num		VARCHAR2(30);
 			   l_no_tax_card_msg    VARCHAR2(1000);
 			   l_return_val		VARCHAR2(20);

			   -- BUG 4774784 fix end

	CURSOR get_person_id (l_assignment_id number,l_date_earned date) is
	SELECT person_id
	FROM per_all_assignments_f paf
	WHERE paf.assignment_id = l_assignment_id
	AND l_date_earned between paf.effective_start_date and paf.effective_end_date;

	CURSOR get_prim_assignment_id( l_person_id number,l_date date) is
	SELECT assignment_id
	FROM per_all_assignments_f paf
	WHERE paf.person_id = l_person_id
	AND   primary_flag = 'Y'
	AND l_date between paf.effective_start_date and paf.effective_end_date;

	CURSOR get_tax_card_details( l_assignment_id number,l_date date , l_input_name varchar2) is
	SELECT screen_entry_value
	FROM pay_element_entry_values_f eev,
	     pay_element_entries_f ee,
	     pay_element_types_f et,
	     pay_input_values_f iv
	WHERE eev.element_entry_id = ee.element_entry_id
	And l_date between eev.effective_start_date and ee.effective_end_date
	And ee.assignment_id = l_assignment_id
	AND l_date between ee.effective_start_date and ee.effective_end_date
	And et.element_name = 'Tax Card'
	And et.legislation_code = 'NO'
	And l_date between et.effective_start_date and et.effective_end_date
	And et.element_type_id = iv.element_type_id
	And iv.name = l_input_name
	And l_date between iv.effective_start_date and iv.effective_end_date
	And eev.input_value_id = iv.input_value_id;

	-- BUG 4774784 fix start

	-- cursor to get employee full name and employee number
        CURSOR get_person_details (l_person_id number,l_date_earned date) is
	SELECT full_name , employee_number
	FROM per_all_people_f
	WHERE person_id = l_person_id
	AND l_date_earned between effective_start_date and effective_end_date ;

	-- cursor to check if element TAX CARD exists on the primary assignment of the employee
	CURSOR csr_chk_tax_card( l_assignment_id number,l_date date ) is
	SELECT ee.ELEMENT_ENTRY_ID
	FROM pay_element_entries_f ee,
	     pay_element_types_f et
	WHERE et.element_name = 'Tax Card'
	And et.legislation_code = 'NO'
	And l_date between et.effective_start_date and et.effective_end_date
        And et.element_type_id = ee.element_type_id
        AND ee.assignment_id = l_assignment_id
	AND l_date between ee.effective_start_date and ee.effective_end_date ;

	-- BUG 4774784 fix end

-------- Adding new cursors for Legislative changes 2007

    -- Legislative changes 2007 : cursor to get the tax municipality for Ambulatory operations

   CURSOR csr_get_amb_op_tax_mun (p_asg_id	  NUMBER , pay_act_id	NUMBER ) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f	pee
          ,pay_element_entry_values_f	eev
          ,pay_input_values_f		piv
          ,pay_element_types_f		pet
          ,pay_payroll_actions		ppa
    WHERE  ppa.payroll_action_id    = pay_act_id
    AND    pee.assignment_id        = p_asg_id
    AND    pet.element_name         = 'Employer Contribution Information'
    AND    pet.legislation_code     = 'NO'
    AND    piv.name                 = 'Tax Municipality'
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN pee.effective_start_date AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN piv.effective_start_date AND     piv.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date AND     pet.effective_end_date ;


    -- Legislative changes 2007 : cursor to fetch the Tax Municipality at Local Unit

	CURSOR csr_get_lu_tax_mun (p_assignment_action_id NUMBER) IS
	SELECT ORG_INFORMATION6   lu_tax_mun
	FROM   pay_assignment_actions	assact ,
	       per_all_assignments_f    paa  ,
	       pay_payroll_actions	ppa ,
	       hr_soft_coding_keyflex   scl ,
	       hr_organization_information hoi
	WHERE  assact.assignment_action_id =  p_assignment_action_id
	AND    ppa.payroll_action_id = assact.payroll_action_id
	AND    paa.assignment_id = assact.assignment_id
	AND    ppa.effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
	AND    paa.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
	AND    hoi.organization_id = scl.segment2
	AND    hoi.org_information_context = 'NO_LOCAL_UNIT_DETAILS' ;

-------- End Adding new cursors for Legislative changes 2007

	--
 	begin

		open get_person_id (p_assignment_id,p_date_earned);
		fetch get_person_id into l_main_person_id;
		close get_person_id;

		open get_prim_assignment_id (l_main_person_id,p_date_earned);
		fetch get_prim_assignment_id into l_prim_asg_id;
		close get_prim_assignment_id;


		-- BUG 4774784 fix start

		OPEN csr_chk_tax_card( l_prim_asg_id ,p_date_earned );
	        FETCH csr_chk_tax_card into l_eeid ;

		IF csr_chk_tax_card%NOTFOUND
	            THEN
		        -- TAX CARD element not attached to emp's primary assignment
			OPEN  get_person_details (l_main_person_id ,p_date_earned ) ;
			FETCH get_person_details into l_full_name , l_emp_num ;
	                CLOSE get_person_details;

		        hr_utility.set_message (801, 'PAY_376863_NO_TAX_CARD_ELE_ERR');
			hr_utility.set_message_token (801, 'EMP_NAME', l_full_name);
	                hr_utility.set_message_token (801, 'EMP_NUM', l_emp_num);

		        l_no_tax_card_msg := hr_utility.get_message ;

			-- Put the meassage in the log file
		        fnd_file.put_line (fnd_file.LOG, l_no_tax_card_msg );

			l_return_val := '0' ;

	        ELSE
			-- TAX CARD element found
			l_return_val := '1' ;
		        l_no_tax_card_msg := '';


			-- BUG 4774784 fix end


			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Municipality');
			fetch get_tax_card_details into l_tax_municipality;
			close get_tax_card_details;

			-- Changes for Legislative changes 2007

			-- the above l_tax_municipality is the Tax Municipality from Tax Card
			-- the value for Tax Municipality returned from this procedure will be used for
			-- JURISRICTION_CODE context which will be used in Employer Contribution calculations.

			-- For calculations before 2007, the Tax Municipality for this will be fetched from
			-- the input value of the element 'Tax Card'.
			-- For calculations in and after 2007, the Tax Municipality for this will be fetched from
			-- the input value of the element 'Employer Contribution Information' (Ambulatory Operations)
			-- or the Tax Municipality at the Local Unit attached to the assignment.


			IF (to_number(to_char(p_date_earned,'RRRR')) >= 2007)

			THEN
			     OPEN  csr_get_amb_op_tax_mun (p_assignment_id , p_payroll_action_id );
			     FETCH csr_get_amb_op_tax_mun INTO l_tax_municipality;
			     CLOSE csr_get_amb_op_tax_mun;

			     IF ( l_tax_municipality IS NULL )
				THEN
					OPEN  csr_get_lu_tax_mun ( p_assignment_action_id );
					FETCH csr_get_lu_tax_mun INTO l_tax_municipality;
					CLOSE csr_get_lu_tax_mun ;

			     END IF ;

			END IF ;

			-- End Changes for Legislative changes 2007

			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Card Type');
			fetch get_tax_card_details into l_tax_card_type;
			close get_tax_card_details;

			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Percentage');
			fetch get_tax_card_details into l_tax_percentage;
			close get_tax_card_details;

			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Table Number');
			fetch get_tax_card_details into l_tax_table_number;
			close get_tax_card_details;

			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Table Type');
			fetch get_tax_card_details into l_tax_table_type;
			close get_tax_card_details;

			open get_tax_card_details (l_prim_asg_id,p_date_earned,'Tax Free Threshold');
			fetch get_tax_card_details into l_tft_value;
			close get_tax_card_details;

		END IF;

		CLOSE csr_chk_tax_card ;


		If l_tax_card_type is null then
			l_tax_card_type := 'PB';
		End If;

		If l_tax_municipality is null then
			l_tax_municipality := 0;
		End If;

		If l_tax_percentage is null then
			l_tax_percentage := '50';
		End If;

		If l_tax_table_number is null then
			l_tax_table_number := '9999';
		End If;

		If l_tax_table_type is null then
			l_tax_table_type := 'O';
		End If;

		If l_tft_value is null then
			l_tft_value := '0';
		End If;

		p_tax_card_type    := l_tax_card_type;
		p_tax_municipality := l_tax_municipality;
		p_tax_percentage   := l_tax_percentage;
		p_tax_table_number := l_tax_table_number;
		p_tax_table_type   := l_tax_table_type;
		p_tft_value	   := l_tft_value;
		p_tax_card_msg     := l_no_tax_card_msg ;

		-- RETURN '1';
	        RETURN l_return_val ;

	end get_prim_tax_card;

 ------------------------------------------------------------------------

FUNCTION get_pay_holiday_rule  ( p_payroll_action_id IN NUMBER
			        ,p_payroll_id IN VARCHAR2
			        ,p_pay_holiday_rule OUT nocopy VARCHAR2)

RETURN VARCHAR2 IS

l_pay_holiday_rule VARCHAR2(80);

CURSOR csr_get_pay_holiday_rule (l_pact_id NUMBER,   l_payroll_id NUMBER) IS
SELECT ptp.prd_information2
FROM per_time_periods ptp,
  pay_payroll_actions ppa
WHERE ppa.payroll_action_id = l_pact_id
 AND ppa.action_type IN('Q','R')
 AND ppa.time_period_id = ptp.time_period_id
 AND ptp.payroll_id = l_payroll_id ;

BEGIN

  OPEN csr_get_pay_holiday_rule (p_payroll_action_id , p_payroll_id) ;
  FETCH csr_get_pay_holiday_rule INTO l_pay_holiday_rule ;
  CLOSE csr_get_pay_holiday_rule ;

  IF l_pay_holiday_rule IS NULL THEN
    l_pay_holiday_rule := 'N';
  END IF;

  p_pay_holiday_rule := l_pay_holiday_rule;
  RETURN '1';

END get_pay_holiday_rule ;


 ------------------------------------------------------------------------
END PAY_NO_HIGH_RATE_TAX;

/
