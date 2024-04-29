--------------------------------------------------------
--  DDL for Package Body OKC_TIME_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_UTIL_PVT" AS
/* $Header: OKCCTULB.pls 120.3 2005/12/30 10:29:53 skekkar noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
----------------------------------------------------------------------------
-- The following procedure derives the most suitable period and duration based
-- on a start and end date.
----------------------------------------------------------------------------

  PROCEDURE get_seeded_timeunit (
   p_timeunit in varchar2,
   x_return_status out nocopy varchar2,
   x_quantity out nocopy number,
   x_timeunit out nocopy varchar2) is

/* Since UOM CODE is unique in MTL_UNITS_OF MEASURE we are not checking the
   class.This procedure should also be able to handle historical data. Therefore
   we are checking the active rows first instead of filtering using
   active_flag = Y */
   CURSOR time_code_unit_csr (p_uom_code IN varchar2) IS
         SELECT tce_code, quantity
         FROM okc_time_code_units_v
         WHERE uom_code = p_uom_code
         ORDER BY decode(active_flag,'Y',1,2);

/* Commented for bug 1787982
   CURSOR time_code_unit_csr (p_uom_code IN varchar2) is
	select tce_code, quantity
	 from okc_time_code_units_v
	 where uom_code = p_uom_code; */

    l_row_not_found                 BOOLEAN := TRUE;
    time_code_unit_rec               time_code_unit_csr%ROWTYPE;
    item_not_found_error          EXCEPTION;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 OPEN time_code_unit_csr(p_timeunit);
	 FETCH time_code_unit_csr into time_code_unit_rec;
      l_row_not_found := time_code_unit_csr%NOTFOUND;
      CLOSE time_code_unit_csr;
      IF (l_row_not_found) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
        RAISE item_not_found_error;
      ELSE
	   x_timeunit := time_code_unit_rec.tce_code;
	   x_quantity  := time_code_unit_rec.quantity;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   end get_seeded_timeunit;

  PROCEDURE get_uom_code (
   p_timeunit in varchar2,
   p_duration in number,
   x_return_status out nocopy varchar2,
   x_timeunit out nocopy varchar2,
   x_duration out nocopy NUMBER) is

/*
   CURSOR time_code_unit_csr (p_timeunit IN varchar2) is
	 SELECT uom_code, quantity
	 FROM   okc_time_code_units_b
	 WHERE  tce_code = p_timeunit
         AND    active_flag = 'Y'
	 AND    quantity = 1
*/
/* The following SQL clause was changed by msengupt to handle displaying in a higher User's Unit instead of the Standard Seeded Base Units.
e.g.  If the user has defined Quarter  as 3 Month (Seeded) and also Month as 1 Month (Seeded) in the Time Code Units,
the period and duration between 1/1/2000 and 6/30/2001 will be returned as 18 Months by the earlier approach. Now with the
query being modified to add an OR clause with Mod, The user's entry of Quarter will be considered and the query will return 6 Quarter - Bug#1821715
*/
   CURSOR time_code_unit_csr (p_timeunit IN varchar2, p_duration IN NUMBER) is
	 SELECT TCU.uom_code, TCU.quantity
--Bug 3262128  FROM   okc_time_code_units_b
         FROM   okc_time_code_units_b TCU,okx_units_of_measure_v UOM
	 WHERE  TCU.tce_code = p_timeunit
         AND    TCU.active_flag = 'Y'
--Bug 3262128 added condition to check for disable_date of UOM
         and nvl(UOM.disable_date,trunc(sysdate)) >= trunc(sysdate)
         AND TCU.UOM_CODE = UOM.UOM_CODE
	 AND    (TCU.quantity = 1   OR  mod(p_duration,TCU.quantity) = 0)
      ORDER BY TCU.quantity desc;

/* Commented for bug 1787982
   CURSOR time_code_unit_csr (p_timeunit IN varchar2) is
	select uom_code
	 from okc_time_code_units_v
	 where tce_code = p_timeunit
	 and quantity = 1; */

    l_row_not_found                 BOOLEAN := TRUE;
    time_code_unit_rec        time_code_unit_csr%ROWTYPE;
    item_not_found_error          EXCEPTION;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 OPEN time_code_unit_csr(p_timeunit, p_duration);
	 FETCH time_code_unit_csr into time_code_unit_rec;
      l_row_not_found := time_code_unit_csr%NOTFOUND;
      CLOSE time_code_unit_csr;
      IF (l_row_not_found) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
        RAISE item_not_found_error;
      ELSE
	   x_timeunit := time_code_unit_rec.uom_code;
           if time_code_unit_rec.quantity > 1 Then
             x_duration := p_duration/time_code_unit_rec.quantity;
           else
             x_duration := p_duration;
           end if;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   end get_uom_code;

  PROCEDURE get_duration(
    p_start_date in date,
    p_end_date in date,
    x_duration out nocopy number,
    x_timeunit out nocopy varchar2,
    x_return_status out nocopy varchar2) is
  l_counter number(12,6);
  l_date date;
  l_timeunit varchar2(10);
  l_offset number := 0;
  p_duration number := 0;
  begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    --Bug 3272514 Set the x_return_status to error if the end date is null
    if p_end_date is NULL Then
	 x_duration := NULL;
	 x_timeunit := NULL;
         x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;
    if p_start_date > p_end_date then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;
/*
    if to_char(p_start_date,'DDMM') = '2902' and
       to_char(p_end_date,'DDMM') = '2802'
    Then
      l_timeunit := 'YEAR';
      p_duration := to_number(to_char(p_end_date,'YYYY')) -
                    to_number(to_char(p_start_date,'YYYY'));
      get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	   x_duration := NULL;
      end if;
      return;
    end if;
*/
    if (p_end_date - p_start_date) < 1 and
	  (p_end_date <> p_start_date) then
	 l_offset := round((p_end_date - p_start_date)*86400,6);
	 if mod(l_offset,3600) = 0 then
	   l_timeunit := 'HOUR';
	   p_duration := l_offset/3600;
      elsif mod(l_offset,60)= 0 then
	   l_timeunit := 'MINUTE';
	   p_duration := l_offset/60;
      else
	   l_timeunit := 'SECOND';
	   p_duration := l_offset;
      end if;
      get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	   x_duration := NULL;
      end if;
      return;
    end if;
--    for l_counter in 1..100000000000 loop
    l_counter := 1;
    LOOP
      l_date := add_months(l_counter,p_start_date) -1;
      if p_end_date < l_date then
        l_timeunit := 'DAY';
        p_duration := trunc(p_end_date) - trunc(p_start_date) + 1;
        exit;
      elsif p_end_date = l_date then
/*
        if to_char(p_end_date,'DDMM') <> '2902' Then
          if mod(l_counter,12) = 0 then
            l_timeunit := 'YEAR';
            p_duration := l_counter/12;
            exit;
          else
            l_timeunit := 'MONTH';
            p_duration := l_counter;
            exit;
          end if;
        else
*/
          if mod(l_counter,12) = 0 then
            l_timeunit := 'YEAR';
            p_duration := l_counter/12;
            exit;
 -- Added for Bug 1846434
           else
            l_timeunit := 'MONTH';
            p_duration := l_counter;
 -- Commented for Bug 1846434
          --l_timeunit := 'DAY';
          --p_duration := trunc(p_end_date) - trunc(p_start_date) + 1;
          exit;
         end if;
--        end if;
      end if;
      l_counter := l_counter+1;
    end loop;
    get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
    if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	 x_duration := NULL;
    end if;
  END get_duration;

----------------------------------------------------------------------------
-- The following function returns the end date based on a start,duration and
-- period.
----------------------------------------------------------------------------
  FUNCTION get_enddate(
    p_start_date in date,
    p_timeunit varchar2,
    p_duration number)
  return date is
  l_end_date date;
  l_year number;
  l_timeunit varchar2(10);
  l_duration number;
  x_return_status     VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  begin
   if p_timeunit is NULL and
	 p_duration is NULL Then
	 return (NULL);
   end if;
   get_seeded_timeunit(p_timeunit,x_return_status,l_duration, l_timeunit);
   if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
    return (NULL);
   end if;
   l_duration := p_duration * l_duration;
   if l_timeunit = 'YEAR' Then
/*
     and to_char(p_start_date,'DDMM') = '2902'
   Then
     if l_duration > 0 then
       l_year := to_number(to_char(p_start_date,'YYYY')) + l_duration;
       l_end_date := to_date('2802'||l_year||to_char(p_start_date,'hh24miss'),'ddmmyyyyhh24miss');
     elsif l_duration < 0 then
       l_year := to_number(to_char(p_start_date,'YYYY')) + l_duration;
       l_end_date := to_date('0103'||l_year||to_char(p_start_date,'hh24miss'),'ddmmyyyyhh24miss');
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
*/
     if l_duration > 0 then
       l_end_date := add_months(p_start_date,(l_duration)*12)-1;
     elsif l_duration < 0 then
       l_end_date := add_months(p_start_date,(l_duration)*12)+1;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   end if;
   if l_timeunit = 'MONTH' then
     if l_duration > 0 then
       l_end_date := add_months(p_start_date,l_duration)-1;
     elsif l_duration < 0 then
       l_end_date := add_months(p_start_date,l_duration)+1;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   elsif l_timeunit = 'DAY' then
     if l_duration > 0 then
       l_end_date := p_start_date + l_duration - 1;
     elsif l_duration < 0 then
       l_end_date := p_start_date + l_duration + 1; -- added on 03/08/2002
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   elsif l_timeunit = 'HOUR' then
     if l_duration > 0 then
       l_end_date := p_start_date + ((l_duration * 3600) - 1)/86400;
     elsif l_duration < 0 then
       l_end_date := p_start_date + (l_duration * 3600)/86400;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   elsif l_timeunit = 'MINUTE' then
     if l_duration > 0 then
       l_end_date := p_start_date + ((l_duration * 60) -1)/86400 - 1;
     elsif l_duration < 0 then
       l_end_date := p_start_date + (l_duration * 60)/86400;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   elsif l_timeunit = 'SECOND' then
     if l_duration > 0 then
       l_end_date := p_start_date + l_duration/86400 - 1;
     elsif l_duration < 0 then
       l_end_date := p_start_date + l_duration/86400;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   elsif l_timeunit = 'YEAR' then
     if l_duration > 0 then
       l_year := to_number(to_char(p_start_date,'YYYY')) + l_duration;
       l_end_date := to_date(to_char(p_start_date,'DDMMHH24MISS') || l_year,'ddmmhh24missyyyy') -1;
     elsif l_duration < 0 then
       l_year := to_number(to_char(p_start_date,'YYYY')) + l_duration;
       l_end_date := to_date(to_char(p_start_date,'DDMMHH24MISS') || l_year,'ddmmhh24missyyyy') +1;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   else
    return(NULL);
   end if;
   EXCEPTION             --BUG:3595566 Exception block added to catch
      when OTHERS then   --            unhandled exceptions.
         if SQLCODE=-1841 then
            OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => G_DATE_ERROR,
                            p_token1       => sqlcode,
                            p_token1_value => sqlerrm);
         else
            OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => sqlcode,
                            p_token1_value => sqlerrm);
        end if;

  END get_enddate;

function get_app_id
return NUMBER
IS
  l_app_id NUMBER;
  CURSOR c_app IS
  SELECT application_id FROM fnd_application WHERE application_short_name = 'OKC';
BEGIN
  for v_app in c_app
  loop
    l_app_id := v_app.application_id;
  end loop;
  return l_app_id;
END;

-- /striping/
function get_app_id(rule_code in varchar2)
return NUMBER
IS
BEGIN
  return okc_rld_pvt.get_appl_id(rule_code);
END;

function get_rule_df_name
return varchar2
IS
BEGIN
  return 'OKC Rule Developer DF';
END;

-- /striping/
function get_rule_df_name(rule_code in varchar2)
return varchar2
IS
BEGIN
  return okc_rld_pvt.get_dff_name(rule_code);
END;

function get_rule_defs_using_vs(
  p_app_id IN NUMBER,
  p_dff_name IN VARCHAR2,
  p_fvs_name IN VARCHAR2)
return varchar2
is
   return_string  varchar2(400);

  CURSOR c_rule_dff (p_app_id IN NUMBER, p_dff_name IN VARCHAR2, p_fvs_name IN VARCHAR2) IS
  SELECT
    dff.form_left_prompt    prompt,
    dff.required_flag,
    dff.display_size,
    fvs.flex_value_set_name,
    dff.descriptive_flex_context_code  rdf_code
  FROM
    fnd_descr_flex_col_usage_vl  dff,
    fnd_flex_value_sets   fvs
  WHERE
    fvs.flex_value_set_id = dff.flex_value_set_id and
    --- need to select based on application id and descriptive flexfield name
    dff.application_id                = p_app_id and
    dff.descriptive_flexfield_name    = p_dff_name and
    fvs.flex_value_set_name           = p_fvs_name;
begin

  for v_rule_dff in c_rule_dff(p_app_id, p_dff_name, p_fvs_name)
  loop
    -- only add it to the string if it is not already there

    if return_string is null then
        return_string := '''' || v_rule_dff.rdf_code || '''';
    else
      if instr(return_string,v_rule_dff.rdf_code) = 0 then
        return_string := return_string || ',''' || v_rule_dff.rdf_code || '''';
      end if;
    end if;
  end loop;

  if return_string is not null then
    return_string := '(' || return_string || ')';
  end if;

  return return_string;
end;

PROCEDURE get_dff_column_values (
  p_app_id      IN NUMBER,
  p_dff_name    IN VARCHAR2,
  p_rdf_code    IN VARCHAR2,
  p_fvs_name    IN VARCHAR2,
  p_rule_id     IN NUMBER,
  p_col_vals    OUT NOCOPY t_col_vals,
  p_no_of_cols  OUT NOCOPY NUMBER
)
IS
  l_select_string  varchar2(2000);
  l_return_string  varchar2(1000);
  l_parse_string   varchar2(1000);
  l_value          varchar2(450);

  l_number_of_columns    number := 0;

  TYPE t_rule_cur IS REF CURSOR;
  c_rule  t_rule_cur;

  CURSOR c_rule_dff (p_app_id IN NUMBER, p_dff_name IN VARCHAR2, p_rdf_code IN VARCHAR2, p_fvs_name IN VARCHAR2) IS
  SELECT
    dff.form_left_prompt    prompt,
    dff.required_flag,
    dff.display_size,
    fvs.flex_value_set_name,
    dff.application_column_name
  FROM
    fnd_descr_flex_col_usage_vl  dff,
    fnd_flex_value_sets   fvs
  WHERE
    fvs.flex_value_set_id = dff.flex_value_set_id and
    --- need to select based on application id and descriptive flexfield name
    dff.descriptive_flex_context_code = p_rdf_code and
    dff.application_id                = p_app_id and
    dff.descriptive_flexfield_name    = p_dff_name and
    fvs.flex_value_set_name           = p_fvs_name
  ORDER BY
    dff.column_seq_num;
begin

  -- determine the timevalue columns to use

  for v_rule_dff in c_rule_dff(p_app_id, p_dff_name, p_rdf_code, p_fvs_name)
  loop
    -- only add it to the string if it is not already there

    if l_select_string is null then
        l_select_string := v_rule_dff.application_column_name;
        l_number_of_columns := 1;
        p_col_vals(l_number_of_columns).col_name := v_rule_dff.application_column_name;
    else
      if instr(l_select_string,v_rule_dff.application_column_name) = 0 then
        l_select_string := l_select_string ||
            ' ||'',''|| ' || v_rule_dff.application_column_name;
        l_number_of_columns := l_number_of_columns + 1;
        p_col_vals(l_number_of_columns).col_name := v_rule_dff.application_column_name;
      end if;
    end if;
  end loop;

  -- get the dates for the rule

  if l_select_string is not null and l_number_of_columns > 0 then
    l_select_string := 'SELECT ' || l_select_string || ' FROM OKC_RULES_B WHERE ID = :ID';

    open c_rule
     for l_select_string
   using p_rule_id;

   fetch c_rule into l_return_string;

   close c_rule;

  end if;

  -- parse the return string
  l_parse_string := l_return_string;
  l_return_string := null;
  for i in 1 .. l_number_of_columns
  loop
    l_value := null;
    declare
      l_comma_idx    number;
    begin
      if i < l_number_of_columns then

        l_comma_idx := instr(l_parse_string,',');
        if l_comma_idx > 1 then
          l_value := substr(l_parse_string,1,l_comma_idx-1);
          if l_comma_idx < length(l_parse_string) then
            l_parse_string := substr(l_parse_string,l_comma_idx+1,length(l_parse_string));
          else
            l_parse_string := null;
          end if;
        else
          l_value := null;
          if length(l_parse_string) > 1 then
            l_parse_string := substr(l_parse_string,2,length(l_parse_string));
          else
            l_parse_string := null;
          end if;
        end if;

      else
        l_value := l_parse_string;
      end if;

    end;
    p_col_vals(i).col_value := l_value;

  end loop;
  p_no_of_cols := l_number_of_columns;

end;

function get_tve_ids (
  p_app_id IN NUMBER,
  p_dff_name IN VARCHAR2,
  p_rdf_code IN VARCHAR2,
  p_fvs_name IN VARCHAR2,
  p_rule_id IN NUMBER)
return varchar2
is
  l_select_string  varchar2(2000);
  l_return_string  varchar2(1000);

  TYPE t_rule_cur IS REF CURSOR;
  c_rule  t_rule_cur;

  CURSOR c_rule_dff (p_app_id IN NUMBER, p_dff_name IN VARCHAR2, p_rdf_code IN VARCHAR2, p_fvs_name IN VARCHAR2) IS
  SELECT
    dff.form_left_prompt    prompt,
    dff.required_flag,
    dff.display_size,
    fvs.flex_value_set_name,
    dff.application_column_name
  FROM
    fnd_descr_flex_col_usage_vl  dff,
    fnd_flex_value_sets   fvs
  WHERE
    fvs.flex_value_set_id = dff.flex_value_set_id and
    --- need to select based on application id and descriptive flexfield name
    dff.descriptive_flex_context_code = p_rdf_code and
    dff.application_id                = p_app_id and
    dff.descriptive_flexfield_name    = p_dff_name and
    fvs.flex_value_set_name           = p_fvs_name
  ORDER BY
    dff.column_seq_num;
begin

  -- determine the timevalue columns to use

  for v_rule_dff in c_rule_dff(p_app_id, p_dff_name, p_rdf_code, p_fvs_name)
  loop
    -- only add it to the string if it is not already there

    if l_select_string is null then
        l_select_string :=  v_rule_dff.application_column_name ;
    else
      if instr(l_select_string,v_rule_dff.application_column_name) = 0 then
        l_select_string := l_select_string ||
            ' || ' || v_rule_dff.application_column_name;
      end if;
    end if;
  end loop;

  -- get the timevalues for the rule

  if l_select_string is not null then
    l_select_string := 'SELECT ' || l_select_string || ' FROM OKC_RULES_B WHERE ID = :ID';

    open c_rule
     for l_select_string
   using p_rule_id;

   fetch c_rule into l_return_string;

   close c_rule;

  end if;

  if l_return_string is not null then
    l_return_string := '(' || l_return_string || ')';
  end if;

  return l_return_string;
end;

-- Bug#2249285: New functions added to check offsets in months and days for Renewal of Keep Duraion Lines

FUNCTION get_uom_code(p_timeunit IN VARCHAR2) return VARCHAR2 IS

  CURSOR time_code_unit_csr(p_timeunit IN VARCHAR2) IS
	 SELECT uom_code
	 FROM   okc_time_code_units_b
	 WHERE  tce_code = p_timeunit
         AND    active_flag = 'Y'
	 AND    quantity = 1;

    l_row_not_found                 BOOLEAN := TRUE;
    time_code_unit_rec        time_code_unit_csr%ROWTYPE;
    item_not_found_error          EXCEPTION;
    x_timeunit VARCHAR2(40);
    BEGIN
      OPEN time_code_unit_csr(p_timeunit);
      FETCH time_code_unit_csr into time_code_unit_rec;
      l_row_not_found := time_code_unit_csr%NOTFOUND;
      CLOSE time_code_unit_csr;
      IF (l_row_not_found) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
        RAISE item_not_found_error;
      ELSE
          x_timeunit := time_code_unit_rec.uom_code;
          return x_timeunit;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
         NULL;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
   end get_uom_code;

  PROCEDURE get_oracle_months_and_days(
    p_start_date in date,
    p_end_date in date,
    x_month_duration out nocopy number,
    x_day_duration out nocopy number,
    x_return_status out nocopy varchar2) is
  l_counter number(12,6);
  l_date date;
  l_previous_date date;
  l_timeunit varchar2(10);
  l_offset number := 0;
  p_duration number := 0;
  begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    if p_end_date is NULL Then
	 x_month_duration := NULL;
	 x_day_duration := NULL;
	 return;
    end if;
    if p_start_date > p_end_date then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    end if;
    if (p_end_date - p_start_date) < 1  then
      x_day_duration := 0;
      x_month_duration := 0;
      return;
    end if;
    for l_counter in 0..100000 loop
      l_date := add_months(l_counter,p_start_date);
      if p_end_date < l_date then
        if (((trunc(l_date) - trunc(l_previous_date)))/2) <= (trunc(p_end_date) - trunc(l_previous_date)) then
          x_month_duration := l_counter;
          x_day_duration := trunc(p_end_date) - trunc(l_date);
--Begin: Bug 4437843 Additional Leap year check added
          if to_char(last_day(p_end_date),'DDMM') = '2902' THEN
            x_day_duration := x_day_duration + 1;
          end if;
--End: Bug 4437843 Additional Leap year check added
        else
          x_month_duration := l_counter-1;
          x_day_duration := trunc(p_end_date) - trunc(l_previous_date);
        end if;
        exit;
      elsif p_end_date = l_date then
        x_month_duration := l_counter;
        x_day_duration := 0;
        exit;
      end if;
      l_previous_date := l_date;
    end loop;
  END get_oracle_months_and_days;

----------------------------------------------------------------------------
-- The following procedure derives the most suitable SEEDED period and duration based
-- on a start and end date.
-- This procedure is called by oks_reprice_pvt for prorating price
-- bug 4919611 ( base bug 4919612)
----------------------------------------------------------------------------

  PROCEDURE get_pricing_duration(
    p_start_date in date,
    p_end_date in date,
    x_duration out nocopy number,
    x_timeunit out nocopy varchar2,
    x_return_status out nocopy varchar2) is
  l_counter number(12,6);
  l_date date;
  l_timeunit varchar2(10);
  l_offset number := 0;
  p_duration number := 0;
  begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    --Bug 3272514 Set the x_return_status to error if the end date is null
    if p_end_date is NULL Then
	 x_duration := NULL;
	 x_timeunit := NULL;
         x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;
    if p_start_date > p_end_date then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;
/*
    if to_char(p_start_date,'DDMM') = '2902' and
       to_char(p_end_date,'DDMM') = '2802'
    Then
      l_timeunit := 'YEAR';
      p_duration := to_number(to_char(p_end_date,'YYYY')) -
                    to_number(to_char(p_start_date,'YYYY'));
      get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	   x_duration := NULL;
      end if;
      return;
    end if;
*/
    if (p_end_date - p_start_date) < 1 and
	  (p_end_date <> p_start_date) then
	 l_offset := round((p_end_date - p_start_date)*86400,6);
	 if mod(l_offset,3600) = 0 then
	   l_timeunit := 'HOUR';
	   p_duration := l_offset/3600;
      elsif mod(l_offset,60)= 0 then
	   l_timeunit := 'MINUTE';
	   p_duration := l_offset/60;
      else
	   l_timeunit := 'SECOND';
	   p_duration := l_offset;
      end if;
      get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	   x_duration := NULL;
      end if;
      return;
    end if;
--    for l_counter in 1..100000000000 loop
    l_counter := 1;
    LOOP
      l_date := add_months(l_counter,p_start_date) -1;
      if p_end_date < l_date then
        l_timeunit := 'DAY';
        p_duration := trunc(p_end_date) - trunc(p_start_date) + 1;
        exit;
      elsif p_end_date = l_date then
/*
        if to_char(p_end_date,'DDMM') <> '2902' Then
          if mod(l_counter,12) = 0 then
            l_timeunit := 'YEAR';
            p_duration := l_counter/12;
            exit;
          else
            l_timeunit := 'MONTH';
            p_duration := l_counter;
            exit;
          end if;
        else
*/
          if mod(l_counter,12) = 0 then
            l_timeunit := 'YEAR';
            p_duration := l_counter/12;
            exit;
 -- Added for Bug 1846434
           else
            l_timeunit := 'MONTH';
            p_duration := l_counter;
 -- Commented for Bug 1846434
          --l_timeunit := 'DAY';
          --p_duration := trunc(p_end_date) - trunc(p_start_date) + 1;
          exit;
         end if;
--        end if;
      end if;
      l_counter := l_counter+1;
    end loop;
    -- for pricing proration, always get period which is seeded and not user defined
    -- added for pricing call bug 4919586 ( base bug 4917510)
    x_duration := p_duration;
    x_timeunit := l_timeunit;
    -- get_uom_code(l_timeunit,p_duration,x_return_status,x_timeunit,x_duration);
    if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	 x_duration := NULL;
    end if;
  END get_pricing_duration;

END OKC_TIME_UTIL_PVT;

/
