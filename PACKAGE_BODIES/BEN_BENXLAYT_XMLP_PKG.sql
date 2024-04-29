--------------------------------------------------------
--  DDL for Package Body BEN_BENXLAYT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENXLAYT_XMLP_PKG" AS
/* $Header: BENXLAYTB.pls 120.1 2007/12/10 08:40:43 vjaganat noship $ */

function commentsformula(total_function in varchar2, data_element_type in varchar2, string_value in varchar2, condition_data_element in number, ext_data_element in number, sum_data_element in number) return varchar2 is
  cursor get_function is
  SELECT meaning
  FROM   hr_lookups
  WHERE  lookup_code = total_function
  AND    lookup_type = 'BEN_EXT_TTL_FNCTN';
  l_function      hr_lookups.meaning%type;

  l_operator      hr_lookups.meaning%type;
  cursor get_data_element
  (p_ext_data_elmt_id     number) is
  SELECT name
  FROM   ben_ext_data_elmt
  WHERE  ext_data_elmt_id = p_ext_data_elmt_id ;


  cursor get_where_clause
  (p_ext_data_elmt_id    number) is
  SELECT cond_ext_data_elmt_id ,oper_cd,val,and_or_cd
  FROM ben_ext_where_clause where ext_data_elmt_id = p_ext_data_elmt_id ;

  l_sum_data_elmt  ben_ext_data_elmt.name%type;
  l_cond_data_elmt  ben_ext_data_elmt.name%type;

  l_where_flag     boolean :=FALSE;
  l_where_clause   varchar2(2000);
  l_return         varchar2(2000);
begin
  if data_element_type = 'S' then
    l_return := 'String Value = ' || string_value;
  elsif data_element_type = 'D' then
    l_return := 'Values are:';
  elsif data_element_type = 'T' then
    open get_function;
    fetch get_function into l_function;
    close get_function;
  end if;
    if total_function = 'CNT' then
      l_return := l_function || ' all ' || fnd_global.local_chr(10);
      if condition_data_element is not null then
         FOR where_clause IN get_where_clause(ext_data_element) LOOP
      	    open get_data_element(where_clause.cond_ext_data_elmt_id);
            fetch get_data_element into l_cond_data_elmt;
            close get_data_element;
            l_where_flag   := TRUE ;
            l_where_clause := l_where_clause || l_cond_data_elmt || ' ' || hr_general.decode_lookup('BEN_EXT_OPER',where_clause.oper_cd)
                              || ' ' || where_clause.val || ' ' || hr_general.decode_lookup('BEN_EXT_AND_OR',where_clause.and_or_cd)
                              || fnd_global.local_chr(10);
         END LOOP;

           if l_where_flag then
              l_return := l_return || ' where ' || l_where_clause;
           end if;

     end if;
   elsif total_function = 'SUM' then

      open get_data_element(sum_data_element);
      fetch get_data_element into l_sum_data_elmt;
      close get_data_element;
      l_return := l_function || ' ' || l_sum_data_elmt || fnd_global.local_chr(10);
     if condition_data_element is not null then
         FOR where_clause IN get_where_clause(ext_data_element) LOOP
      	    open get_data_element(where_clause.cond_ext_data_elmt_id);
            fetch get_data_element into l_cond_data_elmt;
            close get_data_element;
            l_where_flag   := TRUE ;
            l_where_clause := l_where_clause || l_cond_data_elmt || ' ' || hr_general.decode_lookup('BEN_EXT_OPER',where_clause.oper_cd)
                              || ' ' || where_clause.val || ' ' || hr_general.decode_lookup('BEN_EXT_AND_OR',where_clause.and_or_cd)
                              || fnd_global.local_chr(10);
         END LOOP;

           if l_where_flag then
              l_return := l_return || ' where ' || l_where_clause;
           end if;

     end if;
  end if;  return (l_return);
end;

function BeforeReport return boolean is
begin
    --hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END BEN_BENXLAYT_XMLP_PKG ;

/
