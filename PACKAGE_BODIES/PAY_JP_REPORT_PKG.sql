--------------------------------------------------------
--  DDL for Package Body PAY_JP_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_REPORT_PKG" AS
/* $Header: pyjprep.pkb 120.8.12010000.7 2009/12/16 02:34:08 keyazawa ship $ */
  g_end_of_time date := hr_general.end_of_time;
  g_meiji_from  date := to_date('1868-09-08','YYYY-MM-DD');
  g_meiji_to  date := to_date('1912-07-29','YYYY-MM-DD');
  g_taishou_from  date := to_date('1912-07-30','YYYY-MM-DD');
  g_taishou_to  date := to_date('1926-12-24','YYYY-MM-DD');
  g_shouwa_from date := to_date('1926-12-25','YYYY-MM-DD');
  g_shouwa_to date := to_date('1989-01-07','YYYY-MM-DD');
  g_heisei_from date := to_date('1989-01-08','YYYY-MM-DD');
  g_heisei_to date := g_end_of_time;

  g_husband_user_name fnd_new_messages.message_text%type := fnd_message.get_string('PAY','PAY_JP_HUSBAND');
  g_wife_user_name    fnd_new_messages.message_text%type := fnd_message.get_string('PAY','PAY_JP_WIFE');
--
  c_legislation_code varchar2(2) := 'JP';
  c_com_hi_smr_info_elm pay_element_types_f.element_name%type := 'COM_HI_SMR_INFO';
  c_com_wp_smr_info_elm pay_element_types_f.element_name%type := 'COM_WP_SMR_INFO';
  c_appl_mth_iv pay_input_values_f.name%type := 'APPLY_MTH';
  c_appl_cat_iv pay_input_values_f.name%type := 'APPLY_TYPE';
  c_com_si_info_elm pay_element_types_f.element_name%type := 'COM_SI_INFO';
  c_hi_org_iv pay_input_values_f.name%type := 'HI_LOCATION';
  c_wp_org_iv pay_input_values_f.name%type := 'WP_LOCATION';
  c_wpf_org_iv pay_input_values_f.name%type := 'WPF_LOCATION';
  c_hi_num_iv pay_input_values_f.name%type := 'HI_CARD_NUM';
  c_wp_num_iv pay_input_values_f.name%type := 'WP_SERIAL_NUM';
  c_bp_num_iv pay_input_values_f.name%type := 'BASIC_PENSION_NUM';
  c_com_si_rep_elm pay_element_types_f.element_name%type := 'COM_SI_REPORT_INFO';
  c_exc_iv pay_input_values_f.name%type := 'OUTPUT_FLAG';
  c_san_ele_set pay_element_sets.element_set_name%type := 'SAN';
  c_gep_ele_set pay_element_sets.element_set_name%type := 'GEP';
  c_iku_ele_set pay_element_sets.element_set_name%type := 'IKU';
--
  c_com_hi_q_info_elm pay_element_types_f.element_name%type := 'COM_HI_QUALIFY_INFO';
  c_com_wp_q_info_elm pay_element_types_f.element_name%type := 'COM_WP_QUALIFY_INFO';
  c_com_wpf_q_info_elm pay_element_types_f.element_name%type := 'COM_WPF_QUALIFY_INFO';
  c_qd_iv pay_input_values_f.name%type := 'QUALIFY_DATE';
  c_dqd_iv pay_input_values_f.name%type := 'DISQUALIFY_DATE';
--
  c_hi_number varchar2(20) := 'HI_NUMBER';
  c_wp_number varchar2(20) := 'WP_NUMBER';
  c_hi_num_sort number := 1;
  c_wp_num_sort number := 2;
--
g_debug    boolean := hr_utility.debug_enabled;
c_lf constant varchar2(1) := fnd_global.local_chr(10);
c_cr constant varchar2(1) := fnd_global.local_chr(13);
c_max_line_size  binary_integer := 32767;
c_comma_delimiter varchar2(1) := ',';
c_dot_delimiter   varchar2(1) := '.';
--
--------------------------------------------------------------
--                  INSERT_SESSION_DATE                     --
--------------------------------------------------------------
  PROCEDURE INSERT_SESSION_DATE(
    P_EFFECTIVE_DATE  IN DATE)
  IS
  BEGIN
    delete_session_date;

    insert  into fnd_sessions(session_id,effective_date)
    select  userenv('sessionid'),trunc(p_effective_date)
    from  dual;
  END INSERT_SESSION_DATE;

--------------------------------------------------------------
--                  DELETE_SESSION_DATE                     --
--------------------------------------------------------------
  PROCEDURE DELETE_SESSION_DATE
  IS
  BEGIN
    delete from fnd_sessions where session_id=userenv('sessionid');
  END DELETE_SESSION_DATE;

-----------------------------------------------------
--               TO_ERA                            --
-----------------------------------------------------
  PROCEDURE TO_ERA( p_date    IN  DATE,
        p_era_code  OUT NOCOPY NUMBER,
        p_year    OUT NOCOPY NUMBER,
        p_month   OUT NOCOPY NUMBER,
        p_day   OUT NOCOPY NUMBER)
  IS
  BEGIN
    if p_date between g_meiji_from and g_meiji_to then
      p_era_code  := '1';
      p_year    := to_number(to_char(p_date,'YYYY'))-to_number(to_char(g_meiji_from,'YYYY'))+1;
      p_month   := to_number(to_char(p_date,'MM'));
      p_day   := to_number(to_char(p_date,'DD'));
    elsif p_date between g_taishou_from and g_taishou_to then
      p_era_code  := '3';
      p_year    := to_number(to_char(p_date,'YYYY'))-to_number(to_char(g_taishou_from,'YYYY'))+1;
      p_month   := to_number(to_char(p_date,'MM'));
      p_day   := to_number(to_char(p_date,'DD'));
    elsif p_date between g_shouwa_from and g_shouwa_to then
      p_era_code  := '5';
      p_year    := to_number(to_char(p_date,'YYYY'))-to_number(to_char(g_shouwa_from,'YYYY'))+1;
      p_month   := to_number(to_char(p_date,'MM'));
      p_day   := to_number(to_char(p_date,'DD'));
    elsif p_date between g_heisei_from and g_heisei_to then
      p_era_code  := '7';
      p_year    := to_number(to_char(p_date,'YYYY'))-to_number(to_char(g_heisei_from,'YYYY'))+1;
      p_month   := to_number(to_char(p_date,'MM'));
      p_day   := to_number(to_char(p_date,'DD'));
    else
      p_era_code  := NULL;
      p_year    := NULL;
      p_month   := NULL;
      p_day   := NULL;
    end if;
  END TO_ERA;

-----------------------------------------------------
--          GET_CONCATENATED_NUMBERS               --
-----------------------------------------------------
  FUNCTION get_concatenated_numbers(
    p_number1 IN NUMBER,
    p_number2 IN NUMBER,
    p_number3 IN NUMBER,
    p_number4 IN NUMBER,
    p_number5 IN NUMBER,
    p_number6 IN NUMBER,
    p_number7 IN NUMBER,
    p_number8 IN NUMBER,
    p_number9 IN NUMBER,
    p_number10  IN NUMBER) RETURN VARCHAR2
  IS
    l_concatenated_numbers  VARCHAR2(150);
  BEGIN
    l_concatenated_numbers:=NULL;

    if p_number1 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number1);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number1);
      end if;
    end if;
    if p_number2 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number2);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number2);
      end if;
    end if;
    if p_number3 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number3);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number3);
      end if;
    end if;
    if p_number4 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number4);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number4);
      end if;
    end if;
    if p_number5 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number5);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number5);
      end if;
    end if;
    if p_number6 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number6);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number6);
      end if;
    end if;
    if p_number7 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number7);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number7);
      end if;
    end if;
    if p_number8 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number8);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number8);
      end if;
    end if;
    if p_number9 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number9);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number9);
      end if;
    end if;
    if p_number10 is not NULL then
      if l_concatenated_numbers is NULL then
        l_concatenated_numbers:=fnd_number.number_to_canonical(p_number10);
      else
        l_concatenated_numbers:=l_concatenated_numbers || ',' || fnd_number.number_to_canonical(p_number10);
      end if;
    end if;

    return l_concatenated_numbers;
  END get_concatenated_numbers;

-----------------------------------------------------
--          GET_CONCATENATED_DEPENDENTS            --
-----------------------------------------------------
  FUNCTION get_concatenated_dependents(
    p_person_id       IN NUMBER,
    p_effective_date  IN DATE,
    p_kanji_flag      IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_first_flag  BOOLEAN := TRUE;
    l_terminator  VARCHAR2(10);
    l_description VARCHAR2(2000);
--
    CURSOR csr_dependent IS
      -- Pay attention that can't rename the column name of view
      select  pp.last_name      EE_LAST_NAME_KANA,
        pp.per_information18    EE_LAST_NAME,
        pcon.last_name          CON_LAST_NAME_KANA,
        pcon.first_name         CON_FIRST_NAME_KANA,
        pcon.per_information18  CON_LAST_NAME,
        pcon.per_information19  CON_FIRST_NAME,
        decode(pcon.sex,'M',1,'F',2,3)  SEX_ORDER,
        pcon.date_of_birth    DATE_OF_BIRTH,
        decode(pcr.contact_type,'S',decode(pcon.sex,'F',fnd_message.get_string('PAY','PAY_JP_WIFE'),fnd_message.get_string('PAY','PAY_JP_HUSBAND')),flv1.meaning) CONTACT_TYPE,
        decode(pcr.contact_type,'S',decode(pcon.sex,'F',fnd_message.get_string('PAY','PAY_JP_WIFE_KANA'),fnd_message.get_string('PAY','PAY_JP_HUSBAND_KANA')),flv2.meaning) CONTACT_TYPE_KANA
      from
        hr_lookups      flv2,
        hr_lookups      flv1,
        per_all_people_f    pcon,
        per_contact_relationships pcr,
        per_all_people_f    pp
      where pp.person_id=p_person_id
      and p_effective_date
        between pp.effective_start_date and pp.effective_end_date
      and pcr.person_id=pp.person_id
      and pcr.dependent_flag='Y'
      and p_effective_date
          between pcr.date_start and nvl(pcr.date_end,to_date('4712-12-31','YYYY-MM-DD'))
      and pcon.person_id=pcr.contact_person_id
      and ( (p_effective_date
          between pcon.effective_start_date and pcon.effective_end_date)
        or  (not exists(
            select  NULL
            from  per_all_people_f  pcon2
            where pcon2.person_id=pcon.person_id
            and p_effective_date
              between pcon2.effective_start_date and pcon2.effective_end_date)
          and pcon.effective_start_date=pcon.start_date))
      and flv1.lookup_type='CONTACT'
      and flv1.lookup_code=pcr.contact_type
      and flv2.lookup_type(+)='JP_CONTACT_KANA'
      and flv2.lookup_code(+)=pcr.contact_type
      order by 8,7,3,4;
    BEGIN
      l_description := NULL;

      for l_rec_dependent in csr_dependent loop
        if l_first_flag then
          l_terminator := '';
          l_first_flag := FALSE;
        else
          l_terminator := ',';
        end if;

        if nvl(p_kanji_flag,'1') = '1' then
          if l_rec_dependent.ee_last_name <> l_rec_dependent.con_last_name
          or l_rec_dependent.ee_last_name_kana <> l_rec_dependent.con_last_name_kana then
            l_description := substrb(l_description || l_terminator || l_rec_dependent.contact_type || ' ' || l_rec_dependent.con_last_name || ' ' || l_rec_dependent.con_first_name,1,2000);
          else
            l_description := substrb(l_description || l_terminator || l_rec_dependent.contact_type || ' ' || l_rec_dependent.con_first_name,1,2000);
          end if;
        else
          if l_rec_dependent.ee_last_name <> l_rec_dependent.con_last_name
          or l_rec_dependent.ee_last_name_kana <> l_rec_dependent.con_last_name_kana then
            l_description := substrb(l_description || l_terminator || l_rec_dependent.contact_type_kana || ' ' || l_rec_dependent.con_last_name_kana || ' ' || l_rec_dependent.con_first_name_kana,1,2000);
          else
            l_description := substrb(l_description || l_terminator || l_rec_dependent.contact_type_kana || ' ' || l_rec_dependent.con_first_name_kana,1,2000);
          end if;
        end if;
      end loop;

    return l_description;
  END get_concatenated_dependents;

-----------------------------------------------------
  FUNCTION convert2(
-----------------------------------------------------
    str   IN VARCHAR2,
    dest_set  IN VARCHAR2) RETURN VARCHAR2
  IS
    l_value VARCHAR2(2000);
  BEGIN
    l_value := convert(str,dest_set);

    return l_value;
  END convert2;

-----------------------------------------------------
  FUNCTION substrb2(
-----------------------------------------------------
    str   IN VARCHAR2,
    pos   IN NUMBER,
    len   IN NUMBER) RETURN VARCHAR2
  IS
    l_value VARCHAR2(2000);
  BEGIN
    l_value := substrb(str,pos,len);

    return l_value;
  END substrb2;

-----------------------------------------------------
  FUNCTION substr2(
-----------------------------------------------------
    str   IN VARCHAR2,
    pos   IN NUMBER,
    len   IN NUMBER) RETURN VARCHAR2
  IS
    l_value VARCHAR2(2000);
  BEGIN
    l_value := substr(str,pos,len);

    return l_value;
  END substr2;

-----------------------------------------------------
--                  DYNAMIC_SQL                    --
-----------------------------------------------------
  PROCEDURE dynamic_sql(
    p_sql_statement   IN VARCHAR2,
    p_bind_variables  IN g_tab_bind_variables,
    p_column_names    IN g_tab_column_names)
  IS
    i     INTEGER;
    j     INTEGER;
    l_cursor_id   INTEGER;
    l_dummy_integer   INTEGER;
    l_dummy_varchar2  VARCHAR2(255);
  BEGIN
    l_cursor_id:=dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor_id,p_sql_statement,dbms_sql.v7);

    BEGIN
      i:=0;
      LOOP
        i:=i+1;
        if p_bind_variables(i).datatype='NUMBER' then
          dbms_sql.bind_variable(l_cursor_id,':' || p_bind_variables(i).name,to_number(p_bind_variables(i).value));
        elsif p_bind_variables(i).datatype='VARCHAR2' then
          dbms_sql.bind_variable(l_cursor_id,':' || p_bind_variables(i).name,p_bind_variables(i).value);
        elsif p_bind_variables(i).datatype='DATE' then
          dbms_sql.bind_variable(l_cursor_id,':' || p_bind_variables(i).name,fnd_date.canonical_to_date(p_bind_variables(i).value));
        end if;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        i:=i-1;
        NULL;
    END;

    BEGIN
      j:=0;
      LOOP
        j:=j+1;
        l_dummy_varchar2:=p_column_names(j);
        dbms_sql.define_column(l_cursor_id,j,l_dummy_varchar2,255);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        j:=j-1;
        NULL;
    END;

    l_dummy_integer:=dbms_sql.execute(l_cursor_id);
    loop
--      dbms_output.put_line(rpad('=',30,'='));
      l_dummy_integer:=dbms_sql.fetch_rows(l_cursor_id);
      exit when l_dummy_integer<>1;
      for i in 1..j loop
        dbms_sql.column_value(l_cursor_id,i,l_dummy_varchar2);
--        dbms_output.put_line(rpad(p_column_names(i),30,' ') || ' = ' || l_dummy_varchar2);
      end loop;
    end loop;

    dbms_sql.close_cursor(l_cursor_id);
  EXCEPTION
    when others then
--      dbms_output.put_line(SQLERRM);
      dbms_sql.close_cursor(l_cursor_id);
  END dynamic_sql;

-----------------------------------------------------
--          SET_SPACE_ON_ADDRESSS            --
-----------------------------------------------------
-- This part is out of scope for seed conversion.
  FUNCTION SET_SPACE_ON_ADDRESS(
    p_address   IN VARCHAR2,
    p_district_name   IN VARCHAR2,
    p_kana_flag   IN NUMBER) RETURN VARCHAR2
  IS
    l_text      varchar2(80) := p_address;
    l_district_name   varchar2(80) := p_district_name;
    l_prefecture_name varchar2(80) := replace(l_text,p_district_name);

  BEGIN
    if l_text is not NULL then
      if p_kana_flag = 1 then
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B8DEDD'),
              hr_jp_standard_pkg.sjhextochar('B8DEDD20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('20CFB8DEDD20'),
              hr_jp_standard_pkg.sjhextochar('CFB8DEDD20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('20B8DEDD20'),
              hr_jp_standard_pkg.sjhextochar('20B8DEDD'));
        --SEIREI SHITEI TOSHI 12
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('C1CADEBC'),
              hr_jp_standard_pkg.sjhextochar('C1CADEBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('D6BACACFBC'),
              hr_jp_standard_pkg.sjhextochar('D6BACACFBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('C5BADED4BC'),
              hr_jp_standard_pkg.sjhextochar('C5BADED4BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BBAFCEDFDBBC'),
              hr_jp_standard_pkg.sjhextochar('BBAFCEDFDBBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BEDDC0DEB2BC'),
              hr_jp_standard_pkg.sjhextochar('BEDDC0DEB2BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BBB2C0CFBC'),
              hr_jp_standard_pkg.sjhextochar('BBB2C0CFBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BCBDDEB5B6BC'),
              hr_jp_standard_pkg.sjhextochar('BCBDDEB5B6BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B7AEB3C4BC'),
              hr_jp_standard_pkg.sjhextochar('B7AEB3C4BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B5B5BBB6BC'),
              hr_jp_standard_pkg.sjhextochar('B5B5BBB6BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BAB3CDDEBC'),
              hr_jp_standard_pkg.sjhextochar('BAB3CDDEBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('CBDBBCCFBC'),
              hr_jp_standard_pkg.sjhextochar('CBDBBCCFBC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B7C0B7ADB3BCADB3BC'),
              hr_jp_standard_pkg.sjhextochar('B7C0B7ADB3BCADB3BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('CCB8B5B6BC'),
              hr_jp_standard_pkg.sjhextochar('CCB8B5B6BC20'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B5B5BCCFB5B5BCCFCFC1'),
              hr_jp_standard_pkg.sjhextochar('B5B5BCCF20B5B5BCCFCFC1'));
  --
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('C4BCCFC4BCCFD1D7'),
              hr_jp_standard_pkg.sjhextochar('C4BCCF20C4BCCFD1D7'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('C6B2BCDECFC6B2BCDECFD1D7'),
              hr_jp_standard_pkg.sjhextochar('C6B2BCDECF20C6B2BCDECFD1D7'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('BAB3BDDEBCCFBAB3C2DEBCCFD1D7'),
              hr_jp_standard_pkg.sjhextochar('BAB3BDDEBCCF20BAB3C2DEBCCFD1D7'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('D0D4B9BCDECFD0D4B9D1D7'),
              hr_jp_standard_pkg.sjhextochar('D0D4B9BCDECF20D0D4B9D1D7'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('D0B8D7BCDECFD0B8D7BCDECFD1D7'),
              hr_jp_standard_pkg.sjhextochar('D0B8D7BCDECF20D0B8D7BCDECFD1D7'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('CAC1BCDED6B3BCDECFCAC1BCDED6B3CFC1'),
              hr_jp_standard_pkg.sjhextochar('CAC1BCDED6B3BCDECF20CAC1BCDED6B3CFC1'));
        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B1B5B6DEBCCFB1B5B6DEBCCFD1D7'),
              hr_jp_standard_pkg.sjhextochar('B1B5B6DEBCCF20B1B5B6DEBCCFD1D7'));

        l_district_name := replace(l_district_name,
              hr_jp_standard_pkg.sjhextochar('B5B6DEBBDCD7BCAEC4B3B5B6DEBBDCD7D1D7'),
              hr_jp_standard_pkg.sjhextochar('B5B6DEBBDCD7BCAEC4B320B5B6DEBBDCD7D1D7'));
        l_text := l_prefecture_name||' '||l_district_name;
      else
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8C53'),
              hr_jp_standard_pkg.sjhextochar('8C538140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8E73'),
              hr_jp_standard_pkg.sjhextochar('8E738140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8CA7'),
              hr_jp_standard_pkg.sjhextochar('8CA78140'));
  --
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('966B8A4393B9'),
              hr_jp_standard_pkg.sjhextochar('966B8A4393B98140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('938C8B9E9373'),
              hr_jp_standard_pkg.sjhextochar('938C8B9E93738140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8B9E9373957B'),
              hr_jp_standard_pkg.sjhextochar('8B9E9373957B8140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('91E58DE3957B'),
              hr_jp_standard_pkg.sjhextochar('91E58DE3957B8140'));
  --
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8C5381408C538140'),
              hr_jp_standard_pkg.sjhextochar('8C5381408C53'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8C5381408E738140'),
              hr_jp_standard_pkg.sjhextochar('8C5381408E73'));

        --case of GIFU or FUKUSIMA
        if substrb(l_text,1,6) = hr_jp_standard_pkg.sjhextochar('8AF2958C8CA7')
          or substrb(l_text,1,6) = hr_jp_standard_pkg.sjhextochar('959F93878CA7') then
          l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8CA781408C538140'),
              hr_jp_standard_pkg.sjhextochar('8CA781408C53'));
        else
          l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8CA781408C538140'),
              hr_jp_standard_pkg.sjhextochar('8CA78C538140'));
        end if;
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8CA781408E738140'),
              hr_jp_standard_pkg.sjhextochar('8CA781408E73'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8E7381408C538140'),
              hr_jp_standard_pkg.sjhextochar('8E738C538140'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('94AA93FA8E7381408FEA8E73'),
              hr_jp_standard_pkg.sjhextochar('94AA93FA8E738FEA8E73'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('91E598618C5381408E528E73'),
              hr_jp_standard_pkg.sjhextochar('91E598618C538E528E73'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('938C8E738140978892AC'),
              hr_jp_standard_pkg.sjhextochar('938C8E73978892AC'));
  --
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('91E5938791E5938792AC'),
              hr_jp_standard_pkg.sjhextochar('91E59387814091E5938792AC'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('979893879798938791BA'),
              hr_jp_standard_pkg.sjhextochar('9798938781409798938791BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('905693879056938791BA'),
              hr_jp_standard_pkg.sjhextochar('9056938781409056938791BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('905F92C39387905F92C3938791BA'),
              hr_jp_standard_pkg.sjhextochar('905F92C393878140905F92C3938791BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8E4F91EE93878E4F91EE91BA'),
              hr_jp_standard_pkg.sjhextochar('8E4F91EE938781408E4F91EE91BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8CE491A093878CE491A0938791BA'),
              hr_jp_standard_pkg.sjhextochar('8CE491A0938781408CE491A0938791BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('94AA8FE4938794AA8FE492AC'),
              hr_jp_standard_pkg.sjhextochar('94AA8FE49387814094AA8FE492AC'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('90C28350938790C28350938791BA'),
              hr_jp_standard_pkg.sjhextochar('90C283509387814090C28350938791BA'));
        l_text := replace(l_text,
              hr_jp_standard_pkg.sjhextochar('8FAC8A7D8CB48F9493878FAC8A7D8CB491BA'),
              hr_jp_standard_pkg.sjhextochar('8FAC8A7D8CB48F94938781408FAC8A7D8CB491BA'));
      end if;
    end if;
    return l_text;
  END set_space_on_address;

-----------------------------------------------------
--          GET_MAX_VALUE            --
-----------------------------------------------------
  FUNCTION GET_MAX_VALUE(
    p_user_table_name IN VARCHAR2,
    p_udt_column_name IN VARCHAR2,
    p_effective_date  IN DATE ) RETURN NUMBER
  IS
    l_value   number := null;
    CURSOR cur_max_value IS
      select max(to_number(value))
        from  pay_user_tables       put,
            pay_user_columns      puc,
            pay_user_column_instances_f puci
        where put.user_table_name = p_user_table_name
        and   puc.user_table_id = put.user_table_id
        and   puc.user_column_name = p_udt_column_name
        and   puci.user_column_id = puc.user_column_id
        and   p_effective_date
          between puci.effective_start_date and puci.effective_end_date;
  BEGIN
    open cur_max_value;
    fetch cur_max_value into l_value;
    close cur_max_value;

    return l_value;
  END get_max_value;

-----------------------------------------------------
--          GET_MIN_VALUE            --
-----------------------------------------------------
  FUNCTION GET_MIN_VALUE(
    p_user_table_name IN VARCHAR2,
    p_udt_column_name IN VARCHAR2,
    p_effective_date  IN DATE ) RETURN NUMBER
  IS
    l_value   number := null;
    CURSOR cur_min_value IS
      select min(to_number(value))
        from  pay_user_tables       put,
            pay_user_columns      puc,
            pay_user_column_instances_f puci
        where put.user_table_name = p_user_table_name
        and   puc.user_table_id = put.user_table_id
        and   puc.user_column_name = p_udt_column_name
        and   puci.user_column_id = puc.user_column_id
        and   p_effective_date
          between puci.effective_start_date and puci.effective_end_date;
  BEGIN
    open cur_min_value;
    fetch cur_min_value into l_value;
    close cur_min_value;

    return l_value;
  END get_min_value;

-----------------------------------------------------
--          SJTOJIS            --
-----------------------------------------------------
  FUNCTION sjtojis(p_src  IN VARCHAR2)  RETURN VARCHAR2
  IS
    l_jis VARCHAR2(2000) := '';
    l_src VARCHAR2(4);
    l_b1  VARCHAR2(2);
    l_b2  VARCHAR2(2);
    l_b3  VARCHAR2(2);
    l_b4  VARCHAR2(2);
    l_kanji NUMBER := 0;
    l_ank NUMBER := 0;

  BEGIN
    if length(p_src) is null then
      return NULL;
    end if;

    for i in 1.. length(p_src) loop
      l_src := hr_jp_standard_pkg.chartohex(substr(p_src,i,1),'JA16SJIS');
      if length(l_src) = 2 then   --1byte character
        if l_kanji = 1 and l_ank = 0 then
          l_ank := 1;
          l_kanji := 0;
          -- escape sequence KO (kanji out, ANK shift code "ESC(H")
          l_jis := l_jis || '1B2848';
        end if;
        l_jis := l_jis || l_src;
      else          --2byte caracter
        l_b1 := substr(l_src,1,1);
        l_b2 := substr(l_src,2,1);
        l_b3 := substr(l_src,3,1);
        l_b4 := substr(l_src,4,1);

        -- hex A..F -> 10..15
        if to_number(hr_jp_standard_pkg.chartohex(l_b1,'JA16SJIS')) >= 41 then
          l_b1 := to_char(to_number(hr_jp_standard_pkg.chartohex(l_b1,'JA16SJIS'))) - 31;
        end if;
        if to_number(hr_jp_standard_pkg.chartohex(l_b2,'JA16SJIS')) >= 41 then
          l_b2 := to_char(to_number(hr_jp_standard_pkg.chartohex(l_b2,'JA16SJIS'))) - 31;
        end if;
        if to_number(hr_jp_standard_pkg.chartohex(l_b3,'JA16SJIS')) >= 41 then
          l_b3 := to_char(to_number(hr_jp_standard_pkg.chartohex(l_b3,'JA16SJIS'))) - 31;
        end if;
        if to_number(hr_jp_standard_pkg.chartohex(l_b4,'JA16SJIS')) >= 41 then
          l_b4 := to_char(to_number(hr_jp_standard_pkg.chartohex(l_b4,'JA16SJIS'))) - 31;
        end if;

        -- if 1byte >= 0xE0 then   1byte := 1byte - 0x40;
        if to_number(l_b1) >= 14 then
          l_b1 := to_char(to_number(l_b1) - 4);
        end if;
        -- if 2byte >= 0x80 then   2byte := 2byte - 0x01;
        if to_number(l_b3) >= 8 then
          if to_number(l_b4) < 1 then
            l_b3 := to_char(to_number(l_b3) - 1);
            l_b4 := '15';
          else
            l_b4 := to_char(to_number(l_b4) - 1);
          end if;
        end if;
        -- if 2byte >= 0x9E then   1byte := (1byte - 0x70) * 2, 2byte := 2byte - 0x7D;
        -- else   1byte := ((1byte - 0x70) * 2) - 1, 2byte := 2byte - 0x1F;
        if to_number(l_b3 || lpad(l_b4,2,'0')) >= 914 then
          l_b1 := to_char((to_number(l_b1) - 7) * 2);
          l_b2 := to_char(to_number(l_b2) * 2);
          if to_number(l_b2) > 15 then
            l_b1 := to_char(to_number(l_b1) + 1);
            l_b2 := to_char(to_number(l_b2) - 16);
          end if;
          if to_number(l_b4) < 13 then
            l_b3 := to_char(to_number(l_b3) - 8);
            l_b4 := to_char(to_number(l_b4) + 3);
          else
            l_b3 := to_char(to_number(l_b3) - 7);
            l_b4 := to_char(to_number(l_b4) - 13);
          end if;
        else
          if to_number(l_b2) < 1 then
            l_b1 := to_char(((to_number(l_b1) - 7) * 2) - 1);
            l_b2 := '15';
          else
            l_b1 := to_char((to_number(l_b1) - 7) * 2);
            l_b2 := to_char((to_number(l_b2) * 2) - 1);
            if to_number(l_b2) > 15 then
              l_b1 := to_char(to_number(l_b1) + 1);
              l_b2 := to_char(to_number(l_b2) - 16);
            end if;
          end if;
          if to_number(l_b4) < 15 then
              l_b3 := to_char(to_number(l_b3) - 2);
            l_b4 := to_char(to_number(l_b4) + 1);
          else
            l_b3 := to_char(to_number(l_b3) - 1);
            l_b4 := to_char(to_number(l_b4) - 15);
          end if;
        end if;

        if l_kanji = 0 then
          l_kanji := 1;
          l_ank := 0;
          -- escape sequence KI (kanji in, KANJI shift code "ESC$@")
          l_jis := l_jis || '1B2440';
        end if;

        if to_number(l_b1) > 9 then
          l_b1 := hr_jp_standard_pkg.sjhextochar(to_char(to_number(l_b1)+31));
        end if;
        if to_number(l_b2) > 9 then
          l_b2 := hr_jp_standard_pkg.sjhextochar(to_char(to_number(l_b2)+31));
        end if;
        if to_number(l_b3) > 9 then
          l_b3 := hr_jp_standard_pkg.sjhextochar(to_char(to_number(l_b3)+31));
        end if;
        if to_number(l_b4) > 9 then
          l_b4 := hr_jp_standard_pkg.sjhextochar(to_char(to_number(l_b4)+31));
        end if;

        l_jis := l_jis || l_b1 || l_b2 || l_b3 || l_b4;
      end if;
    end loop;

    if l_kanji = 1 and l_ank = 0 then
      -- escape sequence KO (kanji out, ANK shift code "ESC(H")
      l_jis := l_jis || '1B2848';
    end if;

    return hr_jp_standard_pkg.sjhextochar(l_jis);
--    dbms_output.put_line(l_jis);
  END sjtojis;
-----------------------------------------------------
--           ELIGIBLE_FOR_SUBMISSION               --
-----------------------------------------------------
  FUNCTION eligible_for_submission (
    p_year              IN NUMBER,
    p_itax_yea_category IN VARCHAR2,
    p_gross_taxable_amt IN NUMBER,
    p_taxable_amt       IN NUMBER,
    p_prev_swot_taxable_amt IN NUMBER,
    p_executive_flag    IN VARCHAR2,
    p_itax_category     IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_eligible_flag   VARCHAR2(1) := 'N';
    l_taxable_amt_total NUMBER;
    l_prev_swot_taxable_amt NUMBER := 0;
  BEGIN
    if p_year between 0 and 4712 then
      -- Total salary doesn't depend on YEA status.
      if p_itax_yea_category is not NULL then
        l_taxable_amt_total := p_gross_taxable_amt;
      else
        l_taxable_amt_total := p_taxable_amt
                 + l_prev_swot_taxable_amt;
      end if;

      -- In case YEA is processed.
      if p_itax_yea_category = '0' then
        if p_executive_flag = 'Y' then
          if l_taxable_amt_total > 1500000 then
            l_eligible_flag := 'Y';
          end if;
        else
          if l_taxable_amt_total > 5000000 then
            l_eligible_flag := 'Y';
          end if;
        end if;
      else
        if p_itax_category in ('M_KOU', 'D_KOU') then
          if p_executive_flag = 'Y' then
            if l_taxable_amt_total > 500000 then
              l_eligible_flag := 'Y';
            end if;
          else
            if l_taxable_amt_total > 2500000 then
              l_eligible_flag := 'Y';
            end if;
          end if;
        else
          if l_taxable_amt_total > 500000 then
            l_eligible_flag := 'Y';
          end if;
        end if;
      end if;
    end if;
    return l_eligible_flag;
  END eligible_for_submission;
--
-----------------------------------------------------
--              GET_PREV_SWOT_INFO                 --
-----------------------------------------------------
  FUNCTION get_prev_swot_info (
    p_business_group_id in NUMBER,
    p_assignment_id   in NUMBER,
    p_year      in NUMBER,
    p_itax_organization_id  in NUMBER,
    p_swot_iv_id    in NUMBER,
    p_action_sequence in NUMBER,
    p_kanji_flag    in VARCHAR2,
    p_media_type    in VARCHAR2) RETURN VARCHAR2
  IS
  cursor csr_prev_swot_1 is
    select  v1.business_group_id,
      v1.itax_organization_id,
      v1.effective_date,
      v1.date_earned,
      v1.assignment_id,
      v1.action_sequence
    from  pay_jp_pre_itax_v1 v1
    where v1.business_group_id = p_business_group_id
    and to_char(v1.effective_date, 'YYYY') = p_year
    and v1.assignment_id = p_assignment_id
    --
    and v1.itax_organization_id <> p_itax_organization_id
    and v1.action_sequence < p_action_sequence
    order by v1.date_earned desc;
--
  cursor csr_prev_swot_2(cp_itax_organization_id NUMBER, cp_action_sequence NUMBER) is
    select  /* Removed the hint as per Bug# 4767108 */
            nvl(sum(decode(pai.action_information13, 'TERM',
                 NULL, decode(pai.action_information21, cp_itax_organization_id,
                              pai.action_information2 + pai.action_information3, NULL ))),0) PREV_SWOT_TAXABLE_AMT,
            nvl(sum(decode(pai.action_information13, 'TERM',
                      NULL, decode(pai.action_information21, cp_itax_organization_id,
                              pai.action_information24 + pai.action_information25, NULL))),0) PREV_SWOT_ITAX,
            nvl(sum(decode(pai.action_information13, 'TERM',
                      NULL, decode(pai.action_information21, cp_itax_organization_id,
                              pai.action_information6 + pai.action_information9 + pai.action_information12 + pai.action_information20 + pai.action_information14, NULL))),0) PREV_SWOT_SI_PREM,
            nvl(sum(decode(pai.action_information13, 'TERM',
                      NULL, decode(pai.action_information21, cp_itax_organization_id, pai.action_information14, NULL))), 0) PREV_SWOT_MUTUAL_AID
    from    pay_assignment_actions paa,
            pay_payroll_actions ppa,
            pay_action_information pai,
            per_all_assignments_f pa
    where   paa.assignment_id = p_assignment_id
/* Below conditions have already been taken care in Pre-Tax Archiver
   process. So they are redundant here and removed.
   for Bug# 5033800 */
--     and     paa.action_status = 'C'
--     and     ppa.action_type in ('R', 'Q', 'B', 'I')
/* Below conditions were removed, as they are redundant ones.
   for Bug# 5033800 */
--    and     pai.action_context_type = 'AAP'
--     and     pai.assignment_id = pass.assignment_id
    and     ppa.payroll_action_id = paa.payroll_action_id
    and     to_char(ppa.effective_date, 'YYYY') = p_year
    and     pai.action_information_category = 'JP_PRE_TAX_1'
    and     pai.action_information1 = paa.assignment_action_id
    and     ((pai.action_information13 in ('SALARY', 'BONUS', 'SP_BONUS', 'YEA', 'RE_YEA')
              and paa.action_sequence <= cp_action_sequence)
             or
             (pai.action_information13 = 'TERM'))
    and     pai.action_information22 in ('M_KOU', 'M_OTSU', 'D_KOU', 'D_OTSU', 'D_HEI')
    and     pa.assignment_id = paa.assignment_id
    and     ppa.effective_date between pa.effective_start_date and pa.effective_end_date
    --
    and     not exists(
              select  NULL /* Removed the hint as per Bug# 5033800 */
              from    pay_action_interlocks pai2,
                      pay_assignment_actions paa2,
                      pay_payroll_actions ppa2
              where   pai2.locked_action_id = paa.assignment_action_id
              and     paa2.assignment_action_id = pai2.locking_action_id
              and     ppa2.payroll_action_id = paa2.payroll_action_id
              and     ppa2.action_type = 'V');
--
    -- /* Join peev before pee to avoid merge join cartesian */
  cursor csr_prev_swot(cp_date_earned DATE, cp_itax_organization_id NUMBER) is
    select  /* Removed the hint as per Bug# 4767108 */
            decode(p_kanji_flag,
              '1',hoi.org_information1,hoi.org_information2) EMPLOYER_NAME,
            pay_jp_report_pkg.substrb2(
              decode(p_kanji_flag,
                '1',hoi.org_information6||hoi.org_information7||hoi.org_information8,
                hoi.org_information9||hoi.org_information10||hoi.org_information11),1,255) EMPLOYER_ADDRESS,
            peev.effective_end_date  PREV_SWOT_TERM_DATE
    from    hr_organization_information hoi,
            pay_element_entry_values_f peev,
            pay_element_entries_f pee
    where   hoi.organization_id(+) = cp_itax_organization_id
    and     hoi.org_information_context(+) = 'JP_TAX_SWOT_INFO'
    -- Previous SWOT term date
    and     cp_date_earned between peev.effective_start_date and peev.effective_end_date
    and     peev.input_value_id = p_swot_iv_id
    and     peev.screen_entry_value = hoi.organization_id
    and     pee.element_entry_id = peev.element_entry_id
    and     pee.assignment_id = p_assignment_id
    and     pee.effective_start_date = peev.effective_start_date
    and     pee.effective_end_date = peev.effective_end_date;

  l_prev_swot_rec csr_prev_swot%ROWTYPE;

  l_description varchar2(2000);
  l_prev_term_era_code  NUMBER;
  l_prev_term_year  NUMBER;
  l_prev_term_month NUMBER;
  l_prev_term_day   NUMBER;
  l_prev_taxable_amt  VARCHAR2(255);
  l_prev_itax   VARCHAR2(255);
  l_prev_si_prem    VARCHAR2(255);
  l_prev_mutual_aid VARCHAR2(255);
  l_prev_add    VARCHAR2(255);
  l_prev_name   VARCHAR2(255);
  l_prev_term   VARCHAR2(255);
  l_prev_add_id_for_file    VARCHAR2(10) := NULL;
  l_prev_name_id_for_file   VARCHAR2(10) := NULL;
  l_prev_term_id_for_file   VARCHAR2(10) := NULL;

  BEGIN

    l_description := NULL;

    if nvl(p_media_type,'NULL') <> 'NULL' then
      l_prev_add_id_for_file  := 'P_ADDRESS';
      l_prev_name_id_for_file := 'P_NAME';
      l_prev_term_id_for_file := 'P_TERM';
    end if;

    for l_prev_swot_1_rec in csr_prev_swot_1 loop
      for l_prev_swot_2_rec in csr_prev_swot_2(l_prev_swot_1_rec.itax_organization_id, l_prev_swot_1_rec.action_sequence) loop
        for l_prev_swot_rec in csr_prev_swot(l_prev_swot_1_rec.date_earned, l_prev_swot_1_rec.itax_organization_id) loop

      l_prev_taxable_amt := NULL;
      l_prev_itax := NULL;
      l_prev_si_prem := NULL;
      l_prev_mutual_aid := NULL;
      l_prev_add := NULL;
      l_prev_name := NULL;
      l_prev_term := NULL;

    pay_jp_report_pkg.to_era(l_prev_swot_rec.prev_swot_term_date,
           l_prev_term_era_code,
           l_prev_term_year,
           l_prev_term_month,
           l_prev_term_day);
    l_prev_term_year := l_prev_term_year - trunc(l_prev_term_year,-2);

    if not (l_prev_swot_2_rec.prev_swot_taxable_amt = 0
      and l_prev_swot_2_rec.prev_swot_itax = 0
      and l_prev_swot_2_rec.prev_swot_si_prem = 0) then

      if P_KANJI_FLAG = '1' then -- Kanji
        if (l_description is NULL) then
          l_description := l_description || fnd_message.get_string('PAY','PAY_JP_PREVIOUS_EMPLOYMENT');
        else
          l_description := l_description || ',' ||fnd_message.get_string('PAY','PAY_JP_PREVIOUS_EMPLOYMENT');
        end if;
        l_prev_taxable_amt := fnd_message.get_string('PAY','PAY_JP_SALARY')
              || to_char(l_prev_swot_2_rec.prev_swot_taxable_amt)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        l_prev_si_prem := ',' ||fnd_message.get_string('PAY','PAY_JP_TRANS_SI')
              || to_char(l_prev_swot_2_rec.prev_swot_si_prem)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        if (l_prev_swot_2_rec.prev_swot_mutual_aid is not NULL) then
          l_prev_mutual_aid := '(' ||fnd_message.get_string('PAY','PAY_JP_WITHIN')
                || to_char(l_prev_swot_2_rec.prev_swot_mutual_aid)
                || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX') ||')';
        end if;
        l_prev_itax := ',' ||fnd_message.get_string('PAY','PAY_JP_TAX')
              || to_char(l_prev_swot_2_rec.prev_swot_itax)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        if nvl(l_prev_swot_rec.employer_address,' ') <> ' ' then
          l_prev_add := ',' || l_prev_swot_rec.employer_address;
        end if;
        if nvl(l_prev_swot_rec.employer_name,' ') <> ' ' then
          l_prev_name := ',' || l_prev_swot_rec.employer_name;
        end if;
        if (l_prev_swot_rec.prev_swot_term_date is not NULL) then
          l_prev_term := ','
            || lpad(to_char(l_prev_term_year),2,'0') || fnd_message.get_string('PER','HR_JP_YY')
            || lpad(to_char(l_prev_term_month),2,'0') || fnd_message.get_string('PER','HR_JP_MM')
            || lpad(to_char(l_prev_term_day),2,'0') || fnd_message.get_string('PER','HR_JP_DD')
                  || fnd_message.get_string('PAY','PAY_JP_TERM');
        end if;
      else  -- Kana
        if (l_description is NULL) then
          l_description := l_description || fnd_message.get_string('PAY','PAY_JP_PREV_EMPLOYMENT_KANA');
        else
          l_description := l_description || ',' ||fnd_message.get_string('PAY','PAY_JP_PREV_EMPLOYMENT_KANA');
        end if;
        l_prev_taxable_amt := fnd_message.get_string('PAY','PAY_JP_TRANS_SALARY_KANA')
              || to_char(l_prev_swot_2_rec.prev_swot_taxable_amt)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        l_prev_si_prem := ',' || fnd_message.get_string('PAY','PAY_JP_TRANS_SI_KANA')
              || to_char(l_prev_swot_2_rec.prev_swot_si_prem)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        if (l_prev_swot_2_rec.prev_swot_mutual_aid is not NULL) then
          l_prev_mutual_aid := '(' ||fnd_message.get_string('PAY','PAY_JP_WITHIN_KANA')
                || to_char(l_prev_swot_2_rec.prev_swot_mutual_aid)
                || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA') || ')';
        end if;
        l_prev_itax := ',' ||fnd_message.get_string('PAY','PAY_JP_TAX_KANA')
              || to_char(l_prev_swot_2_rec.prev_swot_itax)
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        if nvl(l_prev_swot_rec.employer_address,' ') <> ' ' then
          l_prev_add := ',' || l_prev_swot_rec.employer_address;
        end if;
        if nvl(l_prev_swot_rec.employer_name,' ') <> ' ' then
          l_prev_name := ',' || l_prev_swot_rec.employer_name;
        end if;
        if (l_prev_swot_rec.prev_swot_term_date is not NULL) then
          l_prev_term := ','
            || lpad(to_char(l_prev_term_year),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_YY_KANA')
            || lpad(to_char(l_prev_term_month),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_MM_KANA')
            || lpad(to_char(l_prev_term_day),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_DD_KANA')
                  || fnd_message.get_string('PAY','PAY_JP_TRANS_TERM_KANA');
        end if;
      end if;
      l_description := pay_jp_report_pkg.substrb2(l_description
                || l_prev_taxable_amt || l_prev_si_prem
                || l_prev_mutual_aid || l_prev_itax
                || l_prev_add_id_for_file || l_prev_add
                || l_prev_name_id_for_file || l_prev_name
                || l_prev_term_id_for_file || l_prev_term,1,2000);
    end if;

        end loop;
      end loop;
    end loop;
    return l_description;

  END get_prev_swot_info;

-----------------------------------------------------
--                GET_PJOB_INFO                    --
-----------------------------------------------------
  FUNCTION get_pjob_info (
    p_assignment_id     in NUMBER,
    p_effective_date    in DATE,
    p_business_group_id     in NUMBER,
    p_pjob_ele_type_id    in NUMBER,
    p_taxable_amt_iv_id   in NUMBER,
    p_si_prem_iv_id     in NUMBER,
    p_mutual_aid_iv_id    in NUMBER,
    p_itax_iv_id      in NUMBER,
    p_term_date_iv_id   in NUMBER,
    p_addr_iv_id      in NUMBER,
    p_employer_name_iv_id   in NUMBER,
    p_kanji_flag      in VARCHAR2,
    p_media_type      in VARCHAR2) RETURN VARCHAR2
  IS

  cursor csr_get_entry_values is
    select  /*+ ORDERED
                    NO_MERGE(entry_type_v)
                    INDEX(TAXABLE_AMT PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(ITAX PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(SI_PREM PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(MUTUAL_AID PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(TERM_DATE PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(ADDR PAY_ELEMENT_ENTRY_VALUES_F_N50)
                    INDEX(EMPLOYER_NAME PAY_ELEMENT_ENTRY_VALUES_F_N50) */
                nvl(taxable_amt.screen_entry_value,0)   PJOB_TAXABLE_AMT,
          nvl(itax.screen_entry_value,0)          PJOB_ITAX,
          nvl(si_prem.screen_entry_value,0)       PJOB_SI_PREM,
          nvl(mutual_aid.screen_entry_value,0)    PJOB_MUTUAL_AID,
          fnd_date.canonical_to_date(term_date.screen_entry_value) PJOB_TERM_DATE,
          addr.screen_entry_value                 PJOB_ADDR,
          employer_name.screen_entry_value        PJOB_EMPLOYER_NAME
    from    (select  /*+ ORDERED
                             INDEX(PETF PAY_ELEMENT_TYPES_F_PK)
                             INDEX(PELF PAY_ELEMENT_LINKS_F_N7)
                             INDEX(PEEF PAY_ELEMENT_ENTRIES_F_N51) */
                         peef.element_entry_id
                 from    pay_element_types_f petf,
                         pay_element_links_f pelf,
                         pay_element_entries_f peef
                 where   petf.element_type_id = p_pjob_ele_type_id
                 and     pelf.element_type_id = petf.element_type_id
                 and     pelf.business_group_id +0 = p_business_group_id
                 and     peef.element_link_id = pelf.element_link_id
                 and     peef.assignment_id = p_assignment_id)  entry_type_v,
                pay_element_entry_values_f taxable_amt,
                pay_element_entry_values_f itax,
                pay_element_entry_values_f si_prem,
                pay_element_entry_values_f mutual_aid,
                pay_element_entry_values_f term_date,
                pay_element_entry_values_f addr,
                pay_element_entry_values_f employer_name
    where   taxable_amt.element_entry_id = entry_type_v.element_entry_id
    and     taxable_amt.input_value_id = p_taxable_amt_iv_id
    and     p_effective_date
                between taxable_amt.effective_start_date and taxable_amt.effective_end_date
    and     itax.element_entry_id = entry_type_v.element_entry_id
    and     itax.input_value_id = p_itax_iv_id
    and     p_effective_date
                between itax.effective_start_date and itax.effective_end_date
    and     si_prem.element_entry_id = entry_type_v.element_entry_id
    and     si_prem.input_value_id = p_si_prem_iv_id
    and     p_effective_date
                between si_prem.effective_start_date and si_prem.effective_end_date
    and     mutual_aid.element_entry_id = entry_type_v.element_entry_id
    and     mutual_aid.input_value_id = p_mutual_aid_iv_id
    and     p_effective_date
                between mutual_aid.effective_start_date and mutual_aid.effective_end_date
    and     term_date.element_entry_id = entry_type_v.element_entry_id
    and     term_date.input_value_id = p_term_date_iv_id
    and     p_effective_date
                between term_date.effective_start_date and term_date.effective_end_date
    and     addr.element_entry_id = entry_type_v.element_entry_id
    and     addr.input_value_id = p_addr_iv_id
    and     p_effective_date
                between addr.effective_start_date and addr.effective_end_date
    and     employer_name.element_entry_id = entry_type_v.element_entry_id
    and     employer_name.input_value_id = p_employer_name_iv_id
    and     p_effective_date
                between employer_name.effective_start_date and employer_name.effective_end_date
    order by pjob_term_date desc;

  l_get_entry_values_rec  csr_get_entry_values%ROWTYPE;

  l_description   VARCHAR2(2000);
  l_pjob_taxable_amt  VARCHAR2(255);
  l_pjob_itax   VARCHAR2(255);
  l_pjob_si_prem    VARCHAR2(255);
  l_pjob_mutual_aid VARCHAR2(255);
  l_pjob_term_date  VARCHAR2(255);
  l_pjob_addr   VARCHAR2(255);
  l_pjob_employer_name  VARCHAR2(255);

  l_year      NUMBER;
  l_month     NUMBER;
  l_day     NUMBER;
  l_era_code    NUMBER;

  l_prev_add_id_for_file    VARCHAR2(10) := NULL;
  l_prev_name_id_for_file   VARCHAR2(10) := NULL;
  l_prev_term_id_for_file   VARCHAR2(10) := NULL;

  BEGIN
    l_description := NULL;

    if nvl(p_media_type,'NULL') <> 'NULL' then
      l_prev_add_id_for_file  := 'P_ADDRESS';
      l_prev_name_id_for_file := 'P_NAME';
      l_prev_term_id_for_file := 'P_TERM';
    end if;

    for l_get_entry_values_rec in csr_get_entry_values loop
      l_pjob_taxable_amt := NULL;
      l_pjob_si_prem := NULL;
      l_pjob_mutual_aid := NULL;
      l_pjob_itax := NULL;
      l_pjob_term_date := NULL;
      l_pjob_addr := NULL;
      l_pjob_employer_name := NULL;

    pay_jp_report_pkg.to_era(l_get_entry_values_rec.pjob_term_date,
           l_era_code,
           l_year,
           l_month,
           l_day);
    l_year := l_year - trunc(l_year,-2);

    if not (l_get_entry_values_rec.pjob_taxable_amt = 0
      and l_get_entry_values_rec.pjob_si_prem = 0
      and l_get_entry_values_rec.pjob_itax = 0) then
      if p_kanji_flag = '1' then
        if (l_description is NULL) then
          l_description := l_description || fnd_message.get_string('PAY','PAY_JP_PREVIOUS_EMPLOYMENT');
        else
          l_description := l_description || ',' ||fnd_message.get_string('PAY','PAY_JP_PREVIOUS_EMPLOYMENT');
        end if;
        l_pjob_taxable_amt := fnd_message.get_string('PAY','PAY_JP_SALARY')
              || l_get_entry_values_rec.pjob_taxable_amt
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        l_pjob_si_prem := ','||fnd_message.get_string('PAY','PAY_JP_TRANS_SI')
              || l_get_entry_values_rec.pjob_si_prem
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        if (l_get_entry_values_rec.pjob_mutual_aid is not NULL) then
          l_pjob_mutual_aid := '('||fnd_message.get_string('PAY','PAY_JP_WITHIN')
                || l_get_entry_values_rec.pjob_mutual_aid
                || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX')||')';
        end if;
        l_pjob_itax := ','||fnd_message.get_string('PAY','PAY_JP_TAX')
              || l_get_entry_values_rec.pjob_itax
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX');
        if nvl(l_get_entry_values_rec.pjob_addr, ' ') <> ' ' then
          l_pjob_addr := ',' || l_get_entry_values_rec.pjob_addr;
        end if;
        if nvl(l_get_entry_values_rec.pjob_employer_name, ' ') <> ' ' then
          l_pjob_employer_name := ',' || l_get_entry_values_rec.pjob_employer_name;
        end if;
        if (l_get_entry_values_rec.pjob_term_date is not NULL) then
          l_pjob_term_date := ','
              || lpad(to_char(l_year),2,'0') || fnd_message.get_string('PER','HR_JP_YY')
              || lpad(to_char(l_month),2,'0') || fnd_message.get_string('PER','HR_JP_MM')
              || lpad(to_char(l_day),2,'0') || fnd_message.get_string('PER','HR_JP_DD')
                    || fnd_message.get_string('PAY','PAY_JP_TERM');
        end if;
      else
        if (l_description is NULL) then
          l_description := l_description || fnd_message.get_string('PAY','PAY_JP_PREV_EMPLOYMENT_KANA');
        else
          l_description := l_description || ',' || fnd_message.get_string('PAY','PAY_JP_PREV_EMPLOYMENT_KANA');
        end if;
        l_pjob_taxable_amt := fnd_message.get_string('PAY','PAY_JP_TRANS_SALARY_KANA')
              || l_get_entry_values_rec.pjob_taxable_amt
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        l_pjob_si_prem := ',' || fnd_message.get_string('PAY','PAY_JP_TRANS_SI_KANA')
              || l_get_entry_values_rec.pjob_si_prem
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        if (l_get_entry_values_rec.pjob_mutual_aid is not NULL) then
          l_pjob_mutual_aid := '('||fnd_message.get_string('PAY','PAY_JP_WITHIN_KANA')
                || l_get_entry_values_rec.pjob_mutual_aid
                || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA') ||')';
        end if;
        l_pjob_itax := ',' ||fnd_message.get_string('PAY','PAY_JP_TAX_KANA')
              || l_get_entry_values_rec.pjob_itax
              || fnd_message.get_string('PAY','PAY_JP_JBA_MONEY_SUFFIX_KANA');
        if nvl(l_get_entry_values_rec.pjob_addr, ' ') <> ' ' then
          l_pjob_addr := ',' || l_get_entry_values_rec.pjob_addr;
        end if;
        if nvl(l_get_entry_values_rec.pjob_employer_name, ' ') <> ' ' then
          l_pjob_employer_name := ',' || l_get_entry_values_rec.pjob_employer_name;
        end if;
        if (l_get_entry_values_rec.pjob_term_date is not NULL) then
          l_pjob_term_date := ','
              || lpad(to_char(l_year),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_YY_KANA')
              || lpad(to_char(l_month),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_MM_KANA')
              || lpad(to_char(l_day),2,'0') || fnd_message.get_string('PAY','PAY_JP_TRANS_DD_KANA')
                    || fnd_message.get_string('PAY','PAY_JP_TRANS_TERM_KANA');
        end if;
      end if;
      l_description := pay_jp_report_pkg.substrb2(l_description
                || l_pjob_taxable_amt || l_pjob_si_prem
                || l_pjob_mutual_aid || l_pjob_itax
                || l_prev_add_id_for_file || l_pjob_addr
                || l_prev_name_id_for_file || l_pjob_employer_name
                || l_prev_term_id_for_file || l_pjob_term_date,1,2000);
    end if;

    end loop;

    return l_description;

  END get_pjob_info;
--
-----------------------------------------------------
--            CONVERT_TO_WTM_FORMAT                --
-----------------------------------------------------
-- This part is out of scope for seed conversion.
  FUNCTION convert_to_wtm_format(
    p_text            IN VARCHAR2,
    p_kanji_flag      IN VARCHAR2,
    p_media_type      IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_text  VARCHAR2(4000) := ltrim(rtrim(substrb(p_text,1,2000)));
BEGIN
    if nvl(l_text,' ') = ' ' then
        return l_text;
    end if;

    if nvl(p_media_type,'MT') <> 'MT' then
        l_text  :=  replace(l_text,',','');
    end if;
    if nvl(p_kanji_flag,'1') = '0' then
        -- Translate KANA 2 byte to 1 byte
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('83418343834583478349834A834C834E83508352835483568358835A835C835E83608363836583678369836A836B836C836D836E837183748377837A837D837E8380838183828384838683888389838A838B838C838D838F83928393'),
              hr_jp_standard_pkg.sjhextochar('B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCA6DD'));

        -- for voiced sound
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('834B'),hr_jp_standard_pkg.sjhextochar('B6DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('834D'),hr_jp_standard_pkg.sjhextochar('B7DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('834F'),hr_jp_standard_pkg.sjhextochar('B8DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8351'),hr_jp_standard_pkg.sjhextochar('B9DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8353'),hr_jp_standard_pkg.sjhextochar('BADE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8355'),hr_jp_standard_pkg.sjhextochar('BBDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8357'),hr_jp_standard_pkg.sjhextochar('BCDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8359'),hr_jp_standard_pkg.sjhextochar('BDDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('835B'),hr_jp_standard_pkg.sjhextochar('BEDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('835D'),hr_jp_standard_pkg.sjhextochar('BFDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('835F'),hr_jp_standard_pkg.sjhextochar('C0DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8361'),hr_jp_standard_pkg.sjhextochar('C1DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8364'),hr_jp_standard_pkg.sjhextochar('C2DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8366'),hr_jp_standard_pkg.sjhextochar('C3DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8368'),hr_jp_standard_pkg.sjhextochar('C4DE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('836F'),hr_jp_standard_pkg.sjhextochar('CADE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8370'),hr_jp_standard_pkg.sjhextochar('CADF'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8372'),hr_jp_standard_pkg.sjhextochar('CBDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8373'),hr_jp_standard_pkg.sjhextochar('CBDF'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8375'),hr_jp_standard_pkg.sjhextochar('CCDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8376'),hr_jp_standard_pkg.sjhextochar('CCDF'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8378'),hr_jp_standard_pkg.sjhextochar('CDDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('8379'),hr_jp_standard_pkg.sjhextochar('CDDF'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('837B'),hr_jp_standard_pkg.sjhextochar('CEDE'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('837C'),hr_jp_standard_pkg.sjhextochar('CEDF'));

        -- for double consonant and so on
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('834083428344834683488383838583878362A7A8A9AAABACADAEAF'),
              hr_jp_standard_pkg.sjhextochar('B1B2B3B4B5D4D5D6C2B1B2B3B4B5D4D5D6C2'));

        -- for others
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('81428175817681418145815B'),
              hr_jp_standard_pkg.sjhextochar('A1A2A3A4A5B0'));

        -- for space
        l_text  :=  translate(l_text,hr_jp_standard_pkg.sjhextochar('8140'),' ');

    else
        -- Translate 1 byte to 2 byte
        l_text  :=  to_multi_byte(l_text);

        -- for voiced sound and so on
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('B6DE'),hr_jp_standard_pkg.sjhextochar('834B'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('B7DE'),hr_jp_standard_pkg.sjhextochar('834D'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('B8DE'),hr_jp_standard_pkg.sjhextochar('834F'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('B9DE'),hr_jp_standard_pkg.sjhextochar('8351'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BADE'),hr_jp_standard_pkg.sjhextochar('8353'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BBDE'),hr_jp_standard_pkg.sjhextochar('8355'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BCDE'),hr_jp_standard_pkg.sjhextochar('8357'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BDDE'),hr_jp_standard_pkg.sjhextochar('8359'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BEDE'),hr_jp_standard_pkg.sjhextochar('835B'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('BFDE'),hr_jp_standard_pkg.sjhextochar('835D'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('C0DE'),hr_jp_standard_pkg.sjhextochar('835F'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('C1DE'),hr_jp_standard_pkg.sjhextochar('8361'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('C2DE'),hr_jp_standard_pkg.sjhextochar('8364'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('C3DE'),hr_jp_standard_pkg.sjhextochar('8366'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('C4DE'),hr_jp_standard_pkg.sjhextochar('8368'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CADE'),hr_jp_standard_pkg.sjhextochar('836F'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CADF'),hr_jp_standard_pkg.sjhextochar('8370'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CBDE'),hr_jp_standard_pkg.sjhextochar('8372'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CBDF'),hr_jp_standard_pkg.sjhextochar('8373'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CCDE'),hr_jp_standard_pkg.sjhextochar('8375'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CCDF'),hr_jp_standard_pkg.sjhextochar('8376'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CDDE'),hr_jp_standard_pkg.sjhextochar('8378'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CDDF'),hr_jp_standard_pkg.sjhextochar('8379'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CEDE'),hr_jp_standard_pkg.sjhextochar('837B'));
        l_text  :=  replace(l_text,hr_jp_standard_pkg.sjhextochar('CEDF'),hr_jp_standard_pkg.sjhextochar('837C'));

        -- for KANA
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCA6DD'),
              hr_jp_standard_pkg.sjhextochar('83418343834583478349834A834C834E83508352835483568358835A835C835E83608363836583678369836A836B836C836D836E837183748377837A837D837E8380838183828384838683888389838A838B838C838D838F83928393'));

        -- for double consonant and so on
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('A7A8A9AAABACADAEAF'),
              hr_jp_standard_pkg.sjhextochar('834083428344834683488383838583878362'));

        -- for others
        l_text  :=  translate(l_text,
              hr_jp_standard_pkg.sjhextochar('A1A2A3A4A5B0'),
              hr_jp_standard_pkg.sjhextochar('81428175817681418145815B'));

        -- for space
        l_text  :=  translate(l_text,' ',hr_jp_standard_pkg.sjhextochar('8140'));
    end if;


  return ltrim(rtrim(substrb(l_text,1,2000)));

END convert_to_wtm_format;
--
 FUNCTION get_concatenated_disability(
  p_person_id           IN      NUMBER,
  p_effective_date      IN      DATE)   RETURN VARCHAR2 IS
  --
  CURSOR cel_disability_details IS
   SELECT  /*+ ORDERED
               INDEX(PCR PER_CONTACT_RELATIONSHIPS_N2)
               INDEX(PCEIF PER_CONTACT_EXTRA_INFO_N1)
               INDEX(PAPF PER_PEOPLE_F_PK) */
           DECODE(pceif.cei_information7,
             NULL,SUBSTRB(papf.per_information18 || ' ' || papf.per_information19 ||
                    DECODE(pceif.cei_information6,
                      '20', '(' ||fnd_message.get_string('PAY','PAY_JP_LIVING_SEPARATELY') || ')',
                      '30', '(' ||fnd_message.get_string('PAY','PAY_JP_LIVING_TOGETHER') || ')' , NULL), 1, 2000),
             SUBSTRB(papf.per_information18 || ' ' || papf.per_information19 || ' ('  || pceif.cei_information7 ||
               DECODE(pceif.cei_information6,
                 '20', ', ' || fnd_message.get_string('PAY','PAY_JP_LIVING_SEPARATELY'),
                 '30', ', ' || fnd_message.get_string('PAY','PAY_JP_LIVING_TOGETHER'), NULL) || ')',1,2000))  details
   FROM    per_contact_relationships pcr,
           per_contact_extra_info_f pceif,
           per_all_people_f papf
   WHERE   pcr.person_id = p_person_id
   AND     pcr.cont_information_category = 'JP'
   AND     pcr.cont_information1 = 'Y'
   AND     p_effective_date
           BETWEEN NVL(pcr.date_start, p_effective_date) AND NVL(pcr.date_end, p_effective_date)
   AND     pceif.contact_relationship_id = pcr.contact_relationship_id
   AND     pceif.information_type = 'JP_ITAX_DEPENDENT'
   AND     pceif.cei_information6 <> '0'
   AND     p_effective_date
           BETWEEN pceif.effective_start_date AND pceif.effective_end_date
   AND     papf.person_id = pcr.contact_person_id
   AND     p_effective_date
           BETWEEN papf.effective_start_date AND papf.effective_end_date
   ORDER BY  pcr.cont_information2,
             papf.date_of_birth;
  --
  l_first_flag                  BOOLEAN := TRUE;
  l_celrec_disability_details   cel_disability_details%ROWTYPE;
  l_terminator                  VARCHAR2(5);
  l_disability_details          VARCHAR2(2000);
  --
 BEGIN
  --
  FOR l_celrec_disability_details IN cel_disability_details LOOP
   --
   IF l_first_flag THEN
    --
    l_terminator := '';
    l_first_flag := FALSE;
    --
   ELSE
    --
    l_terminator := fnd_global.local_chr(10);
    --
   END IF;
   --
   l_disability_details := SUBSTRB(l_disability_details || l_terminator || l_celrec_disability_details.details, 1, 2000);
   --
  END LOOP;
  --
  RETURN(l_disability_details);
  --
 END get_concatenated_disability;
 --
-- -----------------------------------------------------------------------------
-- get_hi_dependent_exists
-- -----------------------------------------------------------------------------
--
-- This function will be obsolete according to superseded with get_hi_dependent_number.
--
FUNCTION get_hi_dependent_exists(
  p_person_id      IN NUMBER,
  p_effective_date IN DATE)
--
RETURN VARCHAR2 IS
--
  l_return  VARCHAR2(1);
  --
  CURSOR cel_hi_dependent_exists
  IS
  SELECT 'Y'
  FROM dual
  WHERE EXISTS(
          SELECT /*+ ORDERED */
                 NULL
          FROM   per_contact_relationships pcr,
                 per_contact_extra_info_f  pceif
          WHERE  pcr.person_id = p_person_id
          AND    pcr.cont_information_category = 'JP'
          AND    pcr.cont_information1 = 'Y'
          AND    p_effective_date
                 BETWEEN NVL(pcr.date_start, p_effective_date) AND NVL(pcr.date_end, p_effective_date)
          AND    pceif.contact_relationship_id = pcr.contact_relationship_id
          AND    pceif.information_type LIKE 'JP_HI%'
          AND    p_effective_date
                 between pceif.effective_start_date and pceif.effective_end_date
          AND    p_effective_date
                 between DECODE(pceif.information_type,
                           'JP_HI_SPOUSE', fnd_date.canonical_to_date(pceif.cei_information3),
                           'JP_HI_DEPENDENT', fnd_date.canonical_to_date(pceif.cei_information1),
                            null)
                 and nvl(DECODE(pceif.information_type,
                           'JP_HI_SPOUSE', fnd_date.canonical_to_date(pceif.cei_information10),
                           'JP_HI_DEPENDENT', fnd_date.canonical_to_date(pceif.cei_information6),
                           null),pceif.effective_end_date));
  --
 BEGIN
  --
  OPEN cel_hi_dependent_exists;
  FETCH cel_hi_dependent_exists INTO l_return;
  --
  IF cel_hi_dependent_exists%NOTFOUND THEN
   --
   l_return := 'N';
   --
  END IF;
  --
  CLOSE cel_hi_dependent_exists;
  --
  RETURN(l_return);
  --
 END get_hi_dependent_exists;
--
-- -----------------------------------------------------------------------------
-- get_hi_dependent_number
-- -----------------------------------------------------------------------------
--
function get_hi_dependent_number(
--
  p_person_id       in number,
  p_effective_date  in date)
--
return number is
--
  l_return  number := 0;
--
  -- Owing to distinguish contact is qualified/disqualified,
  -- It is required to point historical(date track) data on target date.
  --
  -- eg. 1. Employee HI qualified at 2004/01/01 (Session Date 2004/02/01)
  --          Contact HI_SPOUSE DFF
  --              QD  : 2004/01/01
  --              DQD : Null
  --              ESD : 2004/02/01
  --              EED : 4712/12/31
  --     2. Contact Start work at 2004/03/01 (Session Date 2004/03/01)
  --          Contact HI_SPOUSE DFF
  --              QD  : 2004/01/01  2004/01/01
  --              DQD : Null        2004/03/01
  --              ESD : 2004/02/01  2004/03/01
  --              EED : 2004/02/29  4712/12/31
  --     3. Contact Back family at 2004/04/01 (Session Date 2004/04/01)
  --          Contact HI_SPOUSE DFF
  --              QD  : 2004/01/01  2004/01/01  2004/04/01
  --              DQD : Null        2004/03/01  Null
  --              ESD : 2004/02/01  2004/03/01  2004/04/01
  --              EED : 2004/02/29  2004/03/31  4712/12/31
  --     Employee is qualified in January, But Contact is not spouse
  --     since there is no data in the period. This is bad operation.
  --     Session Date(ESD) should be same or earlier than qualified date.
  --     If Employee is disqualified in Feburary, Contact is spouse.
  --     If Employee is disqualified in March, Contact is not spouse.
  --     If Employee is disqualified in April, Contact is spouse.
  --
  -- Following are example of coverage.
  --
  -- p_effective_date = 2004/01/01
  --
  --     Case1. o   Case2. o   Case3. x   Case4. x   Case5. x   Case6. x   Case7. x
  -- ESD 1990/01/01 1990/01/01 1990/01/01 1990/01/01 1990/01/01 2005/01/01 1990/01/01
  -- EED 4712/12/31 4712/12/31 4712/12/31 4712/12/31 4712/12/31 4712/12/31 2003/01/01
  -- QD  2003/01/01 2003/01/01 N/A        N/A        2010/12/31 2003/01/01 2003/01/01
  -- DQD 2010/12/31 N/A        2010/12/31 N/A        2003/01/01 2010/12/31 2010/12/31
  --
  cursor cel_hi_dependent_number
  is
  select count(pcr.person_id)
  from   per_contact_relationships pcr
  where  pcr.person_id = p_person_id
  and    pcr.cont_information_category = 'JP'
  and    pcr.cont_information1 = 'Y'
  and    p_effective_date
         between nvl(pcr.date_start, p_effective_date) and nvl(pcr.date_end, p_effective_date)
  and    exists(
           select null
           from   per_contact_extra_info_f pceif
           where  pceif.contact_relationship_id = pcr.contact_relationship_id
           and    p_effective_date
                  between pceif.effective_start_date and pceif.effective_end_date
           and    pceif.information_type like 'JP_HI%'
           and    p_effective_date
                  between  decode(pceif.information_type,
                             'JP_HI_SPOUSE', fnd_date.canonical_to_date(pceif.cei_information3),
                             'JP_HI_DEPENDENT', fnd_date.canonical_to_date(pceif.cei_information1),
                             null)
                 and nvl(DECODE(pceif.information_type,
                           'JP_HI_SPOUSE', fnd_date.canonical_to_date(pceif.cei_information10),
                           'JP_HI_DEPENDENT', fnd_date.canonical_to_date(pceif.cei_information6),
                           null),pceif.effective_end_date));
--
begin
--
  open cel_hi_dependent_number;
  fetch cel_hi_dependent_number into l_return;
  close cel_hi_dependent_number;
--
  return(l_return);
--
end get_hi_dependent_number;
--
-- -----------------------------------------------------------------------------
-- chk_use_contact_extra_info
-- -----------------------------------------------------------------------------
function  chk_use_contact_extra_info(
            p_business_group_id in number)
return  varchar2
is
--
  l_dpnt_control_method hr_organization_information.org_information1%type;
  l_return varchar2(1);
--
  cursor  csr_get_bg_info
  is
  select hoi.org_information1
  from   hr_organization_information hoi
  where  hoi.organization_id = p_business_group_id
  and    hoi.org_information_context = 'JP_BUSINESS_GROUP_INFO';
--
begin
--
  open csr_get_bg_info;
  fetch csr_get_bg_info into l_dpnt_control_method;
  close csr_get_bg_info;
--
-- Distinguish if contact relationship data can be used.
--
  -- if bg info is null then return N
  l_return := 'N';
  --
  if l_dpnt_control_method = 'CEI' then
    l_return := 'Y';
  end if;
--
  return(l_return);
--
end chk_use_contact_extra_info;
--
 FUNCTION get_si_dependent_report_type(
  p_person_id           per_all_people_f.person_id%TYPE,
  p_qualified_date      DATE) RETURN NUMBER IS
  --
  CURSOR cel_added IS
   SELECT 1 FROM per_jp_si_dependent_transfer_v
   WHERE person_id = p_person_id
   AND dependent_type IN ('S', 'D')
   AND transfer_type = 'I'
   AND TRUNC(transfer_date) <> p_qualified_date;
  --
  CURSOR cel_hi_removed IS
   SELECT 2 FROM per_jp_si_dependent_transfer_v
   WHERE person_id = p_person_id
   AND dependent_type IN ('S', 'D')
   AND transfer_type = 'E';
  --
  CURSOR cel_np_added IS
   SELECT 4 FROM per_jp_si_dependent_transfer_v
   WHERE person_id = p_person_id
   AND dependent_type = '3'
   AND transfer_type = 'I'
   AND TRUNC(transfer_date) <> p_qualified_date;
  --
  CURSOR cel_np_removed IS
   SELECT 8 FROM per_jp_si_dependent_transfer_v
   WHERE person_id = p_person_id
   AND dependent_type = '3'
   AND transfer_type = 'E'
   AND type3_disqualified_notice = 'Y';
  --
  l_cursor              NUMBER;
  l_return              NUMBER;
  --
 BEGIN
  --
  l_return := 0;
  --
  OPEN cel_added;
  FETCH cel_added INTO l_cursor;
  --
  IF cel_added%FOUND THEN
   --
   l_return := l_cursor;
   --
  END IF;
  --
  CLOSE cel_added;
  --
  OPEN cel_hi_removed;
  FETCH cel_hi_removed INTO l_cursor;
  --
  IF cel_hi_removed%FOUND THEN
   --
   l_return := l_return + l_cursor;
   --
  END IF;
  --
  CLOSE cel_hi_removed;
  --
  OPEN cel_np_added;
  FETCH cel_np_added INTO l_cursor;
  --
  IF cel_np_added%FOUND THEN
   --
   l_return := l_return + l_cursor;
   --
  END IF;
  --
  CLOSE cel_np_added;
  --
  OPEN cel_np_removed;
  FETCH cel_np_removed INTO l_cursor;
  --
  IF cel_np_removed%FOUND THEN
   --
   l_return := l_return + l_cursor;
   --
  END IF;
  --
  CLOSE cel_np_removed;
  --
  RETURN(l_return);
  --
 END get_si_dependent_report_type;
 --
 FUNCTION get_si_dep_ee_effective_date(
  p_person_id           per_all_people_f.person_id%TYPE,
  p_date_from           DATE,
  p_date_to             DATE,
  p_report_type         hr_lookups.lookup_code%TYPE) RETURN DATE IS
  --
  CURSOR cel_max_effective_date IS
   SELECT transfer_date
   FROM per_jp_si_dependent_transfer_v
   WHERE person_id = p_person_id
   AND DECODE(transfer_type, 'I', transfer_date, 'E', transfer_date + 1) BETWEEN p_date_from AND p_date_to
   AND (p_report_type = '0'
    OR (p_report_type = '10'
     AND dependent_type IN ('S', 'D'))
    OR (p_report_type = '20'
     AND dependent_type = '3'))
   ORDER BY transfer_date DESC;
  --
  l_return              DATE;
 --
 BEGIN
  --
  OPEN cel_max_effective_date;
  FETCH cel_max_effective_date INTO l_return;
  CLOSE cel_max_effective_date;
  --
  RETURN(l_return);
  --
 END get_si_dep_ee_effective_date;
 --
-----------------------------------------------------
--            DECODE_ASS_SET_NAME                  --
-----------------------------------------------------
--
  FUNCTION decode_ass_set_name(
    p_assignment_set_id  in hr_assignment_sets.assignment_set_id%type)
  RETURN VARCHAR2
  IS
  --
    l_meaning  varchar2(80) := null;
  --
    cursor  csr_ass_set_name
    is
    select  assignment_set_name
    from    hr_assignment_sets
    where   assignment_set_id = p_assignment_set_id;
  --
  BEGIN
  --
  -- Only open the cursor if the parameter is going to retrieve anything
  --
    if p_assignment_set_id is not null then
      open csr_ass_set_name;
      fetch csr_ass_set_name into l_meaning;
      close csr_ass_set_name;
    end if;
  --
    return l_meaning;
  --
  END decode_ass_set_name;
--
  function get_si_rec_id(
    p_rec_name in varchar2)
  return number
  is
  --
    l_elm_id number;
    l_rslt_id number;
  --
  begin
  --
    if pay_jp_report_pkg.g_legislation_code is null
       or pay_jp_report_pkg.g_legislation_code <> c_legislation_code then
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.hi_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_org_iv);
      pay_jp_report_pkg.g_si_rec.wp_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_org_iv);
      pay_jp_report_pkg.g_si_rec.wpf_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wpf_org_iv);
      pay_jp_report_pkg.g_si_rec.hi_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_num_iv);
      pay_jp_report_pkg.g_si_rec.wp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_num_iv);
      pay_jp_report_pkg.g_si_rec.bp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_bp_num_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_rep_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.exc_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_exc_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.hi_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.hi_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.wp_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.wp_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wpf_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.wpf_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.wpf_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      pay_jp_report_pkg.g_legislation_code := c_legislation_code;
    --
    end if;
  --
    if p_rec_name = 'hi_org_iv_id' then
      if pay_jp_report_pkg.g_si_rec.hi_org_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.hi_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_org_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.hi_org_iv_id;
    elsif p_rec_name = 'wp_org_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wp_org_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wp_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_org_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wp_org_iv_id;
    elsif p_rec_name = 'wpf_org_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wpf_org_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wpf_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wpf_org_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wpf_org_iv_id;
    elsif p_rec_name = 'hi_num_iv_id' then
      if pay_jp_report_pkg.g_si_rec.hi_num_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.hi_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_num_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.hi_num_iv_id;
    elsif p_rec_name = 'wp_num_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wp_num_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_num_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wp_num_iv_id;
    elsif p_rec_name = 'bp_num_iv_id' then
      if pay_jp_report_pkg.g_si_rec.bp_num_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.bp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_bp_num_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.bp_num_iv_id;
    elsif p_rec_name = 'exc_iv_id' then
      if pay_jp_report_pkg.g_si_rec.exc_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_rep_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.exc_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_exc_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.exc_iv_id;
    elsif p_rec_name = 'hi_qd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.hi_qd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.hi_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.hi_qd_iv_id;
    elsif p_rec_name = 'wp_qd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wp_qd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wp_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wp_qd_iv_id;
    elsif p_rec_name = 'wpf_qd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wpf_qd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wpf_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wpf_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wpf_qd_iv_id;
    elsif p_rec_name = 'hi_dqd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.hi_dqd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.hi_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.hi_dqd_iv_id;
    elsif p_rec_name = 'wp_dqd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wp_dqd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wp_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wp_dqd_iv_id;
    elsif p_rec_name = 'wpf_dqd_iv_id' then
      if pay_jp_report_pkg.g_si_rec.wpf_dqd_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wpf_q_info_elm,-1,c_legislation_code);
        pay_jp_report_pkg.g_si_rec.wpf_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_si_rec.wpf_dqd_iv_id;
    end if;
  --
  return l_rslt_id;
  end get_si_rec_id;
--
  function get_gs_rec_id(
    p_rec_name in varchar2)
  return number
  is
    l_ele_set pay_element_sets.element_set_name%type;
    l_elm_id number;
    l_rslt_id number;
  --
    cursor csr_ele_set
    is
    select pes.element_set_id
    from   pay_element_sets pes
    where  pes.legislation_code = c_legislation_code
    and    pes.element_set_name = l_ele_set;
  --
  begin
  --
    if pay_jp_report_pkg.g_legislation_code is null
       or pay_jp_report_pkg.g_legislation_code <> c_legislation_code then
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_smr_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_gs_rec.hi_appl_mth_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_mth_iv);
      pay_jp_report_pkg.g_gs_rec.hi_appl_cat_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_cat_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_smr_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_gs_rec.wp_appl_mth_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_mth_iv);
      pay_jp_report_pkg.g_gs_rec.wp_appl_cat_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_cat_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.hi_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_org_iv);
      pay_jp_report_pkg.g_si_rec.wp_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_org_iv);
      pay_jp_report_pkg.g_si_rec.wpf_org_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wpf_org_iv);
      pay_jp_report_pkg.g_si_rec.hi_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_hi_num_iv);
      pay_jp_report_pkg.g_si_rec.wp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_wp_num_iv);
      pay_jp_report_pkg.g_si_rec.bp_num_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_bp_num_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_si_rep_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.exc_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_exc_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.hi_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.hi_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.wp_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.wp_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wpf_q_info_elm,-1,c_legislation_code);
      pay_jp_report_pkg.g_si_rec.wpf_qd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_qd_iv);
      pay_jp_report_pkg.g_si_rec.wpf_dqd_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_dqd_iv);
    --
      l_ele_set := c_san_ele_set;
      open csr_ele_set;
      fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.san_ele_set_id;
      close csr_ele_set;
    --
      l_ele_set := c_gep_ele_set;
      open csr_ele_set;
      fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.gep_ele_set_id;
      close csr_ele_set;
    --
      l_ele_set := c_iku_ele_set;
      open csr_ele_set;
      fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.iku_ele_set_id;
      close csr_ele_set;
    --
      pay_jp_report_pkg.g_legislation_code := c_legislation_code;
    --
    end if;
  --
    if p_rec_name = 'hi_appl_mth_iv_id' then
      if pay_jp_report_pkg.g_gs_rec.hi_appl_mth_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_smr_info_elm,null,c_legislation_code);
        pay_jp_report_pkg.g_gs_rec.hi_appl_mth_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_mth_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.hi_appl_mth_iv_id;
    elsif p_rec_name = 'wp_appl_mth_iv_id' then
      if pay_jp_report_pkg.g_gs_rec.wp_appl_mth_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_smr_info_elm,null,c_legislation_code);
        pay_jp_report_pkg.g_gs_rec.wp_appl_mth_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_mth_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.wp_appl_mth_iv_id;
    elsif p_rec_name = 'hi_appl_cat_iv_id' then
      if pay_jp_report_pkg.g_gs_rec.hi_appl_cat_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_hi_smr_info_elm,null,c_legislation_code);
        pay_jp_report_pkg.g_gs_rec.hi_appl_cat_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_cat_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.hi_appl_cat_iv_id;
    elsif p_rec_name = 'wp_appl_cat_iv_id' then
      if pay_jp_report_pkg.g_gs_rec.wp_appl_cat_iv_id is null then
        l_elm_id := pay_jp_balance_pkg.get_element_type_id(c_com_wp_smr_info_elm,null,c_legislation_code);
        pay_jp_report_pkg.g_gs_rec.wp_appl_cat_iv_id := pay_jp_balance_pkg.get_input_value_id(l_elm_id,c_appl_cat_iv);
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.wp_appl_cat_iv_id;
    elsif p_rec_name = 'san_ele_set_id' then
      if pay_jp_report_pkg.g_gs_rec.san_ele_set_id is null then
        open csr_ele_set;
        fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.san_ele_set_id;
        close csr_ele_set;
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.san_ele_set_id;
    elsif p_rec_name = 'gep_ele_set_id' then
      if pay_jp_report_pkg.g_gs_rec.gep_ele_set_id is null then
        open csr_ele_set;
        fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.gep_ele_set_id;
        close csr_ele_set;
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.gep_ele_set_id;
    elsif p_rec_name = 'iku_ele_set_id' then
      if pay_jp_report_pkg.g_gs_rec.iku_ele_set_id is null then
        open csr_ele_set;
        fetch csr_ele_set into pay_jp_report_pkg.g_gs_rec.iku_ele_set_id;
        close csr_ele_set;
      end if;
      l_rslt_id := pay_jp_report_pkg.g_gs_rec.iku_ele_set_id;
    end if;
  --
  return l_rslt_id;
  end get_gs_rec_id;
--
  function chk_hi_wp(
    p_sort_order  in varchar2,
    p_submit_type in number,
    p_si_type     in number)
  return number
  is
  --
    l_hi_wp number := c_hi_num_sort;
  --
  begin
  --
    if p_sort_order = c_wp_number then
    --
      l_hi_wp := c_wp_num_sort;
    --
    else
    --
      if p_submit_type in (3,7) then
      --
        if p_si_type in (2,6) then
        --
          l_hi_wp := c_wp_num_sort;
        --
        end if;
      --
      end if;
    --
    end if;
  --
  return l_hi_wp;
  end chk_hi_wp;
--
  procedure get_latest_std_mth_comp_info(
    p_assignment_id          in number,
    p_effective_date         in date,
    p_date_earned            in date,
    p_applied_mth_iv_id      in number,
    p_new_std_mth_comp_iv_id in number,
    p_old_std_mth_comp_iv_id in number,
    p_latest_applied_date    out nocopy date,
    p_latest_std_mth_comp    out nocopy varchar2)
  is
  --
    /* Limitation: This logic does not check whether employee is qualified at the past time. */
    /* Only related to current status of qualification. */
    /* Include updating entry and new entry as qualification. */
    cursor csr_past_std_mth_comp is
    select  /*+ ORDERED
                USE_NL(PLIV1, PLIV2, PEE, PEEV1, PEEV2)
                INDEX(PAY_LINK_INPUT_VALUES_F_N2 PLIV1)
                INDEX(PAY_LINK_INPUT_VALUES_F_N2 PLIV2)
                INDEX(PAY_ELEMENT_ENTRIES_F_N51 PEE)
                INDEX(PAY_ELEMENT_ENTRY_VALUES_F_N50 PEEV1)
                INDEX(PAY_ELEMENT_ENTRY_VALUES_F_N50 PEEV2) */
            pee.element_entry_id        ee_id,
            pee.effective_start_date    ee_esd,
            pee.effective_end_date      ee_eed,
            peev1.screen_entry_value    applied_mth,
            peev2.screen_entry_value    new_std_mth_comp
    from    pay_link_input_values_f     pliv1,
            pay_link_input_values_f     pliv2,
            pay_element_entries_f       pee,
            pay_element_entry_values_f  peev1,
            pay_element_entry_values_f  peev2
    where   pliv1.input_value_id = p_applied_mth_iv_id
    and     pliv2.input_value_id = p_new_std_mth_comp_iv_id
    and     pee.assignment_id = p_assignment_id
            /* use not eed but esd to include entry data as qualification */
            /* DBItem Entry is referred by date earned, */
            /* but if update recurring has been occurred, */
            /* all future entry are updating from effective date. */
            /* therefore, don't need to include future entry till date earned. */
    and     pee.entry_type = 'E'
    and     pee.effective_start_date < p_effective_date
    and     pee.element_link_id = pliv1.element_link_id
    and     pee.element_link_id = pliv2.element_link_id
    and     pee.effective_start_date
            between pliv1.effective_start_date and pliv1.effective_end_date
    and     pee.effective_start_date
            between pliv2.effective_start_date and pliv2.effective_end_date
    and     peev1.element_entry_id = pee.element_entry_id
    and     peev1.input_value_id = pliv1.input_value_id
    and     peev1.effective_start_date = pee.effective_start_date
    and     peev1.effective_end_date = pee.effective_end_date
    and     peev2.element_entry_id = pee.element_entry_id
    and     peev2.input_value_id = pliv2.input_value_id
    and     peev2.effective_start_date = pee.effective_start_date
    and     peev2.effective_end_date = pee.effective_end_date
    order by pee.effective_start_date desc;
  --
    l_csr_past_std_mth_comp       csr_past_std_mth_comp%rowtype;
    l_applied_mth_one_day_before  varchar2(60);
    l_applied_mth                 varchar2(60);
    l_applied_mth_old             varchar2(60);
    l_std_mth_comp_old            varchar2(60);
  --
  begin
  --
    l_applied_mth := pay_jp_balance_pkg.get_entry_value_char(p_applied_mth_iv_id,p_assignment_id,p_effective_date);
    l_applied_mth_one_day_before := pay_jp_balance_pkg.get_entry_value_char(p_applied_mth_iv_id,p_assignment_id,p_effective_date - 1);
  --
    if trunc(to_date(nvl(l_applied_mth_one_day_before,'000101')||'01','YYYYMMDD'),'MM')
       < trunc(p_date_earned,'MM') then
      l_applied_mth_old := l_applied_mth_one_day_before;
      if nvl(l_applied_mth,'000101') <> nvl(l_applied_mth_one_day_before,'000101') then
        l_std_mth_comp_old := pay_jp_balance_pkg.get_entry_value_char(p_old_std_mth_comp_iv_id,p_assignment_id,p_effective_date);
      else
        if l_applied_mth is not null and l_applied_mth_one_day_before is not null then
          /* This case is for entry that is not updated(process) ie. qualificaiton data */
          l_std_mth_comp_old := pay_jp_balance_pkg.get_entry_value_char(p_new_std_mth_comp_iv_id,p_assignment_id,p_date_earned);
        end if;
      end if;
    else
    --
      open csr_past_std_mth_comp;
      loop
        fetch csr_past_std_mth_comp into l_csr_past_std_mth_comp;
        exit when csr_past_std_mth_comp%notfound;
        /* Applied data on the Same Date Earned Month can not be applicable since short term. */
        /* Geppen Applied 9 > Santei(8) => Previous entry should be used.) */
        /* Date Earned of Santei is always 8/1, One of Geppen is always X/1 */
        if trunc(to_date(nvl(l_csr_past_std_mth_comp.applied_mth,'000101')||'01','YYYYMMDD'),'MM')
          < trunc(p_date_earned,'MM') then
          l_applied_mth_old := l_csr_past_std_mth_comp.applied_mth;
          if l_applied_mth_old is not null then
            l_std_mth_comp_old := l_csr_past_std_mth_comp.new_std_mth_comp;
          --l_std_mth_comp_old := pay_jp_balance_pkg.get_entry_value_char(p_new_std_mth_comp_iv_id,p_assignment_id,l_csr_past_std_mth_comp.ee_esd);
          end if;
          exit;
        end if;
      end loop;
      close csr_past_std_mth_comp;
    --
    end if;
  --
    if l_applied_mth_old is not null then
      p_latest_applied_date := to_date(l_applied_mth_old||'01','YYYYMMDD');
    else
      p_latest_applied_date := null;
    end if;
  --
    p_latest_std_mth_comp := l_std_mth_comp_old;
  --
  end get_latest_std_mth_comp_info;
--
  function chk_hi_wp_invalid(
    p_qualified_date in date,
    p_disqualified_date in date,
    p_date_earned in date)
  return number
  is
  --
    l_qualified_date    date := p_qualified_date;
    l_disqualified_date date := p_disqualified_date;
  --
    /* 0: N, 1: Y */
    l_hi_wp_invalid number := 0;
  --
  begin
  --
    if l_qualified_date is null then
    -- no entry value, not insured.
      if l_disqualified_date is null then
      --
        l_qualified_date := hr_api.g_eot;
        l_disqualified_date := hr_api.g_sot;
      -- this paterns identify "not insured" as shortage of data.
      -- qualified date should be under disqualified date.
      else
      --
        l_qualified_date := hr_api.g_eot;
      --
      end if;
    --
    else
    --
      -- This is normal patern.
      -- disqualified date should be over qualified date.
      if l_disqualified_date is null then
      --
        l_disqualified_date := hr_api.g_eot;
      --
      end if;
    --
    end if;
  --
    if p_date_earned < l_qualified_date
    or l_disqualified_date <= p_date_earned then
    --
      l_hi_wp_invalid := 1;
    --
    end if;
  --
  return l_hi_wp_invalid;
  end chk_hi_wp_invalid;
--
  function get_applied_date_old(
    p_hi_invalid in number,
    p_wp_invalid in number,
    p_hi_applied_date_old in date,
    p_wp_applied_date_old in date,
    p_si_submit_type in number)
  return date
  is
  --
    l_applied_date_old date;
  --
  begin
  --
    if p_hi_invalid = 0 and p_wp_invalid = 0 then
    --
      if trunc(nvl(p_hi_applied_date_old,hr_api.g_sot),'MM') < trunc(nvl(p_wp_applied_date_old,hr_api.g_sot),'MM')
      or p_si_submit_type = 2 then
      --
        l_applied_date_old := p_wp_applied_date_old;
      --
      else
      --
        l_applied_date_old := p_hi_applied_date_old;
      --
      end if;
    --
    else
    --
      if p_hi_invalid = 1 then
      --
        l_applied_date_old := p_wp_applied_date_old;
      --
      end if;
      --
      if p_wp_invalid = 1 then
      --
        l_applied_date_old := p_hi_applied_date_old;
      --
      end if;
    --
    end if;
  --
  return l_applied_date_old;
  end get_applied_date_old;
--
  function get_user_elm_name(p_base_elm_name in varchar2)
  return varchar2
  is
  --
    l_user_elm_name pay_element_types_f_tl.element_name%type;
  --
    cursor csr_user_elm_name
    is
    select pett.element_name
    from   pay_element_types_f pet,
           pay_element_types_f_tl pett
    where  pet.element_name = p_base_elm_name
    and    pett.element_type_id = pet.element_type_id
    and    pett.language = userenv('LANG');
  --
  begin
  --
    open csr_user_elm_name;
    fetch csr_user_elm_name into l_user_elm_name;
    close csr_user_elm_name;
  --
  return l_user_elm_name;
  end get_user_elm_name;
--
-- -------------------------------------------------------------------------
-- append_select_clause
-- -------------------------------------------------------------------------
procedure append_select_clause(
  p_clause in varchar2,
  p_select_clause in out nocopy varchar2)
is
begin
--
  p_select_clause := p_select_clause||p_clause||c_lf;
--
end append_select_clause;
--
-- -------------------------------------------------------------------------
-- append_from_clause
-- -------------------------------------------------------------------------
procedure append_from_clause(
  p_clause in varchar2,
  p_from_clause in out nocopy varchar2,
  p_top in varchar2 default 'N')
is
begin
--
  if p_from_clause is null then
  --
    p_from_clause := 'from '||p_clause||c_lf;
  --
  else
  --
    if p_top = 'Y' then
    --
      p_from_clause := 'from '||p_clause||substrb(p_from_clause,5,lengthb(p_from_clause) - 4)||c_lf;
    --
    else
    --
      p_from_clause := p_from_clause||p_clause||c_lf;
    --
    end if;
  --
  end if;
--
end append_from_clause;
--
-- -------------------------------------------------------------------------
-- append_where_clause
-- -------------------------------------------------------------------------
procedure append_where_clause(
  p_clause in varchar2,
  p_where_clause in out nocopy varchar2)
is
begin
--
  if p_where_clause is null then
  --
    p_where_clause := 'where '||p_clause||c_lf;
  --
  else
  --
    p_where_clause := p_where_clause||'and '||p_clause||c_lf;
  --
  end if;
--
end append_where_clause;
--
-- -------------------------------------------------------------------------
-- append_order_clause
-- -------------------------------------------------------------------------
procedure append_order_clause(
  p_clause in varchar2,
  p_order_clause in out nocopy varchar2)
is
begin
--
  if p_order_clause is null then
  --
    p_order_clause := 'order by '||p_clause||c_lf;
  --
  else
  --
    p_order_clause := p_order_clause||', '||p_clause||c_lf;
  --
  end if;
--
end append_order_clause;
--
-- -------------------------------------------------------------------------
-- show_debug
-- -------------------------------------------------------------------------
procedure show_debug(
  p_text in varchar2)
is
--
  c_max number := 200;
--
  l_max number;
  l_len number := 0;
  l_text_len number := lengthb(p_text);
--
begin
--
  if p_text is not null then
  --
    <<loop_show_debug>>
    loop
    --
      if l_len >= l_text_len then
        exit loop_show_debug;
      end if;
    --
      l_max := l_text_len - l_len;
      if l_max > c_max then
      --
        l_max := c_max;
      --
      end if;
    --
      hr_utility.trace(substrb(p_text,l_len + 1,l_max));
    --
      l_len := l_len + l_max;
    --
    end loop loop_show_debug;
  --
  end if;
--
end show_debug;
--
-- -------------------------------------------------------------------------
-- show_warning
-- -------------------------------------------------------------------------
procedure show_warning(
  p_which in number,
  p_text  in varchar2)
is
--
  c_max number := 200;
--
  l_max number;
  l_len number := 0;
  l_max_char_len number;
  -- use length (not lengthb)
  l_text_len number := length(p_text);
--
begin
--
  if p_text is not null then
  --
    l_max_char_len := trunc(c_max/lengthb(to_multi_byte(' ')));
  --
    <<loop_show_warning>>
    loop
    --
      if l_len >= l_text_len then
        exit loop_show_warning;
      end if;
    --
      l_max := l_text_len - l_len;
      if l_max > c_max then
      --
        l_max := c_max;
      --
      end if;
    --
      -- use substr (not substrb)
      fnd_file.put_line(p_which,substr(p_text,l_len + 1,l_max));
    --
      l_len := l_len + l_max;
    --
    end loop loop_show_warning;
  --
  end if;
--
end show_warning;
--
-- -------------------------------------------------------------------------
-- set_char_set
-- -------------------------------------------------------------------------
procedure set_char_set(
  p_char_set in varchar2)
is
begin
--
  pay_jp_report_pkg.g_char_set := p_char_set;
--
end set_char_set;
--
-- -------------------------------------------------------------------------
-- set_db_char_set
-- -------------------------------------------------------------------------
procedure set_db_char_set(
  p_db_char_set in varchar2 default null)
is
--
  cursor csr_db_char_set
  is
  --select tag
  select lookup_code
  from   fnd_lookup_values
  where  lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
  and    lookup_code = substr(userenv('language'),instr(userenv('language'),'.') + 1)
  and    language = 'US';
--
begin
--
  if p_db_char_set is not null then
  --
    pay_jp_report_pkg.g_db_char_set := p_db_char_set;
  --
  else
  --
    if pay_jp_report_pkg.g_db_char_set is null then
    --
      open csr_db_char_set;
      fetch csr_db_char_set into pay_jp_report_pkg.g_db_char_set;
      close csr_db_char_set;
    --
    end if;
  --
  end if;
--
end set_db_char_set;
--
-- -------------------------------------------------------------------------
-- check_file
-- -------------------------------------------------------------------------
function check_file(
  p_file_name in varchar2,
  p_file_dir  in varchar2)
return boolean
is
--
  l_check_file boolean := false;
  l_file_size number;
  l_block_size number;
--
begin
--
  utl_file.fgetattr(p_file_dir,p_file_name,l_check_file,l_file_size,l_block_size);
--
  -- workaround for some bug
  if l_check_file is null
  and l_file_size = 0
  and l_block_size = 0 then
  --
    l_check_file := false;
  --
  end if;
--
return l_check_file;
--
exception
when others then
--
  if g_debug then
    hr_utility.trace('check_file : others');
  end if;
  --
  return l_check_file;
--
end check_file;
--
-- -------------------------------------------------------------------------
-- open_file
-- -------------------------------------------------------------------------
procedure open_file(
  p_file_name in varchar2,
  p_file_dir  in varchar2,
  p_file_out  out nocopy utl_file.file_type,
  p_file_type in varchar2 default 'a')
is
--
  l_file_out utl_file.file_type;
  l_user_error varchar2(255);
--
begin
--
  if p_file_type = 'a'
  or p_file_type = 'w' then
  --
    l_file_out := utl_file.fopen(p_file_dir,p_file_name,p_file_type);
  --
    begin
    --
      utl_file.fclose(l_file_out);
    --
    exception
    when others then
      null;
    end;
  --
  end if;
--
  p_file_out := utl_file.fopen(p_file_dir,p_file_name,p_file_type,c_max_line_size);
--
exception
when utl_file.invalid_path then
--
  if g_debug then
    hr_utility.trace('open_file : invalid_path');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_PATH');
  fnd_message.set_token('FILE_DIR',p_file_dir,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.invalid_mode then
--
  if g_debug then
    hr_utility.trace('open_file : invalid_mode');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_MODE');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  fnd_message.set_token('FILE_MODE','a',false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.invalid_operation then
--
  if g_debug then
    hr_utility.trace('open_file : invalid_operation');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_OPERATN');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  fnd_message.set_token('TEMP_DIR',p_file_dir,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.invalid_maxlinesize then
--
  if g_debug then
    hr_utility.trace('open_file : invalid_maxlinesize');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_MAXLINE');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  fnd_message.set_token('MAXLINE',c_max_line_size,false);
  --
  raise_application_error(-20100,l_user_error);
--
when others then
--
  if g_debug then
    hr_utility.trace('open_file : others');
  end if;
  --
  raise;
--
end open_file;
--
-- -------------------------------------------------------------------------
-- read_file
-- -------------------------------------------------------------------------
procedure read_file(
  p_file_name in varchar2,
  p_file_out in utl_file.file_type,
  p_file_data_tbl out nocopy t_file_data_tbl)
is
--
  l_file_data_tbl t_file_data_tbl;
  l_file_data_tbl_cnt number;
--
  l_user_error varchar2(255);
--
begin
--
  l_file_data_tbl.delete;
  l_file_data_tbl_cnt := 0;
--
  loop
  --
    begin
    --
      utl_file.get_line(p_file_out,l_file_data_tbl(l_file_data_tbl_cnt));
      -- remove carriage return for linux
      l_file_data_tbl(l_file_data_tbl_cnt) := replace(l_file_data_tbl(l_file_data_tbl_cnt),c_cr,null);
      l_file_data_tbl_cnt := l_file_data_tbl_cnt + 1;
    --
    exception
    when no_data_found then
      exit;
    end;
  --
  end loop;
--
  p_file_data_tbl := l_file_data_tbl;
--
exception
when utl_file.invalid_filehandle then
--
  if g_debug then
    hr_utility.trace('read_file : invalid_filehandle');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_HANDLE');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.invalid_operation then
--
  if g_debug then
    hr_utility.trace('read_file : invalid_operation');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_OPERATN');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.read_error then
--
  if g_debug then
    hr_utility.trace('read_file : read_error');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_READ_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when others then
--
  if g_debug then
    hr_utility.trace('write_file : others');
  end if;
  --
  raise;
--
end read_file;
--
-- -------------------------------------------------------------------------
-- write_file
-- -------------------------------------------------------------------------
procedure write_file(
  p_file_name in varchar2,
  p_file_out in utl_file.file_type,
  p_line in varchar2,
  p_char_set in varchar2 default null)
is
--
  l_max_char_len number;
  l_line_len number;
  l_char_len number := 0;
  l_char_s number := 1;
  l_loop_cnt number := 0;
  l_user_error varchar2(255);
  l_char_set varchar2(30);
--
begin
--
  if p_line is not null
  and lengthb(p_line) > c_max_line_size then
  --
    if g_debug then
      hr_utility.trace('write_file over length');
    end if;
  --
    l_char_set := p_char_set;
    if l_char_set is null then
    --
      --if pay_jp_report_pkg.g_char_set is null then
      --  hr_utility.set_message(800,'HR_7944_CHECK_FMT_BAD_FORMAT');
      --  hr_utility.raise_error;
      --else
        l_char_set := pay_jp_report_pkg.g_char_set;
      --end if;
    --
    end if;
  --
    if l_char_set is null then
      l_max_char_len := trunc(c_max_line_size/lengthb(to_multi_byte(' ')));
    else
      l_max_char_len := trunc(c_max_line_size/lengthb(convert(to_multi_byte(' '),l_char_set)));
    end if;
  --
    -- use length (not lengthb)
    l_line_len := length(p_line);
  --
    <<loop_write_line>>
    loop
    --
      if l_char_s > l_line_len then
        exit loop_write_line;
      else
      --
        l_loop_cnt := l_loop_cnt + 1;
        --
        if l_max_char_len * l_loop_cnt > l_line_len then
          l_char_len := l_line_len - (l_max_char_len * (l_loop_cnt - 1));
        else
          l_char_len := l_max_char_len;
        end if;
      --
        -- use substr (not substrb)
        utl_file.put(p_file_out, substr(p_line,l_char_s,l_char_len));
      --
        l_char_s := l_char_s + l_char_len;
      --
      end if;
    --
    end loop loop_write_line;
  --
    utl_file.new_line(p_file_out,1);
  --
  else
  --
    if g_debug then
      hr_utility.trace('write_file normal length');
    end if;
  --
    utl_file.put_line(p_file_out,p_line);
  --
  end if;
--
exception
when utl_file.invalid_filehandle then
--
  if g_debug then
    hr_utility.trace('write_file : invalid_filehandle');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_HANDLE');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.invalid_operation then
--
  if g_debug then
    hr_utility.trace('write_file : invalid_operation');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_OPERATN');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when utl_file.write_error then
--
  if g_debug then
    hr_utility.trace('write_file : write_error');
  end if;
  --
  fnd_message.set_name('FND','CONC-FILE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  l_user_error := substrb(fnd_message.get,1,255);
  --
  fnd_message.set_name('FND','CONC-TEMPFILE_WRITE_ERROR');
  fnd_message.set_token('TEMP_FILE',p_file_name,false);
  --
  raise_application_error(-20100,l_user_error);
--
when others then
--
  if g_debug then
    hr_utility.trace('write_file : others');
  end if;
  --
  raise;
--
end write_file;
--
-- -------------------------------------------------------------------------
-- close_file
-- -------------------------------------------------------------------------
procedure close_file(
  p_file_name in varchar2,
  p_file_out in out nocopy utl_file.file_type,
  p_file_type in varchar2 default 'a')
is
--
begin
--
  if p_file_type = 'a'
  or p_file_type = 'w' then
  --
    utl_file.fflush(p_file_out);
  --
  end if;
--
  utl_file.fclose(p_file_out);
--
exception
when others then
--
  if g_debug then
    hr_utility.trace('close file error : '||p_file_name);
  end if;
--
  raise;
--
end close_file;
--
-- -------------------------------------------------------------------------
-- delete_file
-- -------------------------------------------------------------------------
procedure delete_file(
  p_file_dir in varchar2,
  p_file_name in varchar2)
is
--
  l_file_chk  boolean;
  l_file_size number;
  l_block_size number;
--
begin
--
  utl_file.fgetattr(p_file_dir,p_file_name,l_file_chk,l_file_size,l_block_size);
  if l_file_chk then
  --
    utl_file.fremove(p_file_dir,p_file_name);
  --
  end if;
--
exception
when others then
--
  if g_debug then
    hr_utility.trace('delete file error : '||p_file_name);
  end if;
--
  raise;
--
end delete_file;
--
-- -------------------------------------------------------------------------
-- split_str
-- -------------------------------------------------------------------------
function split_str(
  p_text in varchar2,
  p_n in number)
return varchar2
is
--
  l_text varchar2(4000);
--
  l_pos number;
  l_prev_pos number;
--
begin
--
  if lengthb(p_text) > 0
  and p_n > 0 then
  --
    l_pos := nvl(instrb(p_text,c_comma_delimiter,1,p_n),0);
    -- first part
    if p_n = 1 then
    --
      if l_pos > 0 then
      --
        l_text := substrb(p_text,1,l_pos-1);
      --
      end if;
    --
    else
    --
      l_prev_pos := nvl(instrb(p_text,c_comma_delimiter,1,p_n-1),0);
    --
      if l_prev_pos > 0 then
      --
        -- last part
        if l_pos = 0 then
        --
          l_text := substrb(p_text,l_prev_pos+1);
        --
        else
        --
          l_text := substrb(p_text,l_prev_pos+1,l_pos-l_prev_pos-1);
        --
        end if;
      --
      end if;
    --
    end if;
  --
  end if;
--
return l_text;
--
end split_str;
--
-- -------------------------------------------------------------------------
-- cnv_str
-- -------------------------------------------------------------------------
function cnv_str(
  p_text in varchar2,
  p_start in number default null,
  p_end in number default null)
return varchar2
is
--
  l_text varchar2(4000);
--
begin
--
  l_text := ltrim(rtrim(replace(p_text,to_multi_byte(' '),' ')));
--
  if p_start is not null
  and p_end is not null then
  --
    -- use substr (not substrb)
    l_text := substr(l_text,p_start,p_end);
  --
  end if;
--
return l_text;
--
end cnv_str;
--
-- -------------------------------------------------------------------------
-- cnv_siz (text)
-- -------------------------------------------------------------------------
function cnv_siz(
  p_type in varchar2,
  p_len in number,
  p_text in varchar2)
return varchar2
is
--
  l_len number;
--
begin
--
  -- use substr (not substrb)
  if p_type = 'z' then
    return substr(hr_jp_standard_pkg.to_zenkaku(p_text),1,p_len);
  elsif p_type = 'h' then
    return substr(hr_jp_standard_pkg.to_hankaku(p_text),1,p_len);
  else
    return substr(p_text,1,p_len);
  end if;
--
end cnv_siz;
--
-- -------------------------------------------------------------------------
-- cnv_siz (number)
-- -------------------------------------------------------------------------
function cnv_siz(
  p_type in varchar2,
  p_len in number,
  p_text in number)
return number
is
begin
--
return to_number(to_single_byte(cnv_siz(p_type,p_len,to_char(p_text))));
--
end cnv_siz;
--
-- -------------------------------------------------------------------------
-- cnv_txt (text)
-- -------------------------------------------------------------------------
function cnv_txt(
  p_text in varchar2,
  p_char_set in varchar2 default null)
return varchar2
is
--
  l_char_set varchar2(30);
  --l_db_char_set varchar2(30);
--
  --cursor csr_db_char_set
  --is
  --select tag
  --from   fnd_lookup_values
  --where  lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
  --and    lookup_code = substr(userenv('language'),instr(userenv('language'),'.') + 1)
  --and    language = 'US';
--
begin
--
  --open csr_db_char_set;
  --fetch csr_db_char_set into l_db_char_set;
  --close csr_db_char_set;
--
  l_char_set := p_char_set;
  if l_char_set is null then
  --
    --if pay_jp_report_pkg.g_char_set is null then
    --  hr_utility.set_message(800,'HR_7944_CHECK_FMT_BAD_FORMAT');
    --  hr_utility.raise_error;
    --else
      l_char_set := pay_jp_report_pkg.g_char_set;
    --end if;
  --
  end if;
--
--return convert(convert(p_text,l_db_char_set),l_char_set,l_db_char_set);
return convert(p_text,l_char_set);
--
end cnv_txt;
--
-- -------------------------------------------------------------------------
-- cnv_txt (number)
-- -------------------------------------------------------------------------
function cnv_txt(
  p_text in number,
  p_char_set in varchar2 default null)
return varchar2
is
begin
--
-- not use fnd_number.number_to_canonical
return cnv_txt(to_char(p_text),p_char_set);
--
end cnv_txt;
--
-- -------------------------------------------------------------------------
-- cnv_db_txt (text)
-- -------------------------------------------------------------------------
function cnv_db_txt(
  p_text in varchar2,
  p_char_set in varchar2 default null,
  p_db_char_set in varchar2 default null)
return varchar2
is
--
  l_char_set varchar2(30);
  l_db_char_set varchar2(30);
--
  --cursor csr_db_char_set
  --is
  --select tag
  --from   fnd_lookup_values
  --where  lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
  --and    lookup_code = substr(userenv('language'),instr(userenv('language'),'.') + 1)
  --and    language = 'US';
--
begin
--
  --open csr_db_char_set;
  --fetch csr_db_char_set into l_db_char_set;
  --close csr_db_char_set;
--
  l_char_set := p_char_set;
  if l_char_set is null then
  --
    --if pay_jp_report_pkg.g_char_set is null then
    --  hr_utility.set_message(800,'HR_7944_CHECK_FMT_BAD_FORMAT');
    --  hr_utility.raise_error;
    --else
      l_char_set := pay_jp_report_pkg.g_char_set;
    --end if;
  --
  end if;
--
  l_db_char_set := p_db_char_set;
  if l_db_char_set is null then
  --
    --if pay_jp_report_pkg.g_db_char_set is null then
    --  hr_utility.set_message(800,'HR_7944_CHECK_FMT_BAD_FORMAT');
    --  hr_utility.raise_error;
    --else
      l_db_char_set := pay_jp_report_pkg.g_db_char_set;
    --end if;
  --
  end if;
--
  return convert(p_text,l_db_char_set,l_char_set);
--
end cnv_db_txt;
--
-- -------------------------------------------------------------------------
-- add_tag (text)
-- -------------------------------------------------------------------------
function add_tag(
  p_tag in varchar2,
  p_text in varchar2)
return varchar2
is
begin
--
return '<'||p_tag||'>'||p_text||'</'||p_tag||'>';
--
end add_tag;
--
-- -------------------------------------------------------------------------
-- add_tag (date)
-- -------------------------------------------------------------------------
function add_tag(
  p_tag in varchar2,
  p_text in date)
return varchar2
is
begin
--
return add_tag(p_tag,fnd_date.date_to_canonical(p_text));
--
end add_tag;
--
-- -------------------------------------------------------------------------
-- add_tag (number)
-- -------------------------------------------------------------------------
function add_tag(
  p_tag in varchar2,
  p_text in number)
return varchar2
is
begin
--
return add_tag(p_tag,fnd_number.number_to_canonical(p_text));
--
end add_tag;
--
-- -------------------------------------------------------------------------
-- add_tag_m (money)
-- -------------------------------------------------------------------------
function add_tag_m(
  p_tag in varchar2,
  p_text in number)
return varchar2
is
begin
--
return add_tag(p_tag,htmlspchar(to_char(p_text,fnd_currency.get_format_mask('JPY',40))));
--
end add_tag_m;
--
-- -------------------------------------------------------------------------
-- add_tag_v (text)
-- -------------------------------------------------------------------------
function add_tag_v(
  p_tag in varchar2,
  p_text in varchar2)
return varchar2
is
begin
--
return add_tag(p_tag,htmlspchar(p_text));
--
end add_tag_v;
--
-- -------------------------------------------------------------------------
-- htmlspchar
-- -------------------------------------------------------------------------
function htmlspchar(
  p_text in varchar2)
return varchar2
is
--
  l_htmlspchar varchar2(1) := 'N';
--
begin
--
  if nvl(instr(p_text,'<'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'>'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'\&'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,''''),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'"'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
if l_htmlspchar = 'Y' then
  return '<![CDATA['||p_text||']]>';
else
  return p_text;
end if;
end htmlspchar;
--
-- -------------------------------------------------------------------------
-- set_delimiter
-- -------------------------------------------------------------------------
procedure set_delimiter(
  p_delimiter in varchar2)
is
begin
--
  pay_jp_report_pkg.g_delimiter := p_delimiter;
--
end set_delimiter;
--
-- -------------------------------------------------------------------------
-- csvspchar
-- -------------------------------------------------------------------------
function csvspchar(
  p_text in varchar2)
return varchar2
is
--
  l_text varchar2(4000);
--
begin
--
  if pay_jp_report_pkg.g_delimiter is null then
    set_delimiter(c_dot_delimiter);
  end if;
--
  l_text := replace(p_text,c_comma_delimiter,pay_jp_report_pkg.g_delimiter);
--
return l_text;
end csvspchar;
--
-- -------------------------------------------------------------------------
-- decode_value
-- -------------------------------------------------------------------------
function decode_value(
  p_condition in boolean,
  p_true_value in varchar2,
  p_false_value in varchar2)
return varchar2
is
begin
--
  if p_condition then
    return p_true_value;
  else
    return p_false_value;
  end if;
--
end decode_value;
--
END PAY_JP_REPORT_PKG;

/
