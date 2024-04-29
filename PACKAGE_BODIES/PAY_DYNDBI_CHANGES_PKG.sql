--------------------------------------------------------
--  DDL for Package Body PAY_DYNDBI_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYNDBI_CHANGES_PKG" as
/* $Header: pydbichg.pkb 120.3 2008/04/25 10:05:03 ubhat noship $ */

------------------------------- insert_row -------------------------------
procedure insert_row
(p_id in varchar2
,p_type in varchar2
,p_language in varchar2
) is
begin
  insert into pay_dyndbi_changes
  (id
  ,type
  ,language
  )
  select p_id
  ,      p_type
  ,      p_language
  from   dual
  where  not exists
  (
    select null
    from   pay_dyndbi_changes pdc
    where  pdc.id = p_id
    and    pdc.type = p_type
    and    pdc.language = p_language
  );
end insert_row;

------------------------------ insert_rows -------------------------------
procedure insert_rows
(p_id in varchar2
,p_type in varchar2
,p_languages in dbms_sql.varchar2s
) is
begin
  for i in 1 .. p_languages.count loop
    insert into pay_dyndbi_changes
    (id
    ,type
    ,language
    )
    select p_id
    ,      p_type
    ,      p_languages(i)
    from   dual
    where  not exists
    (
      select null
      from   pay_dyndbi_changes pdc
      where  pdc.id = p_id
      and    pdc.type = p_type
      and    pdc.language = p_languages(i)
    );
  end loop;
end insert_rows;

-------------------------- element_type_change ---------------------------
procedure element_type_change
(p_element_type_id in number
,p_languages       in dbms_sql.varchar2s
) is
--
-- Cursor for getting input values. Note: only need to fetch values
-- with GENERATE_DB_ITEMS_FLAG = 'Y'. Also, use the maximum effective
-- end date as this is what is done in HRDYNDBI.
--
cursor csr_input_values
(p_element_type_id in number
) is
select iv.input_value_id
from   pay_input_values_f iv
where  iv.element_type_id = p_element_type_id
and    iv.generate_db_items_flag = 'Y'
and    iv.effective_end_date =
       (
         select max(iv1.effective_end_date)
         from   pay_input_values_f iv1
         where  iv1.input_value_id = iv.input_value_id
       )
;
begin
  -- First handle the element type itself.
  insert_rows
  (p_id        => p_element_type_id
  ,p_type      => C_ELEMENT_TYPE
  ,p_languages => p_languages
  );
  -- Handle the input values for the element type.
  for iv in csr_input_values(p_element_type_id) loop
    insert_rows
    (p_id        => iv.input_value_id
    ,p_type      => C_INPUT_VALUE
    ,p_languages => p_languages
    );
  end loop;
end element_type_change;

-------------------------- balance_type_change ---------------------------
procedure balance_type_change
(p_balance_type_id in number
,p_languages       in dbms_sql.varchar2s
) is
cursor csr_defined_balances
(p_balance_type_id in number
) is
select db.defined_balance_id
from   pay_defined_balances db
where  db.balance_type_id = p_balance_type_id
;
begin
  for db in csr_defined_balances(p_balance_type_id) loop
    insert_rows
    (p_id        => db.defined_balance_id
    ,p_type      => C_DEFINED_BALANCE
    ,p_languages => p_languages
    );
  end loop;
end balance_type_change;

--------------------------- input_value_change ---------------------------
procedure input_value_change
(p_input_value_id in number
,p_languages      in dbms_sql.varchar2s
) is
cursor csr_input_value(p_input_value_id in number) is
select null
from   pay_input_values_f iv
where  iv.input_value_id = p_input_value_id
and    iv.generate_db_items_flag = 'Y'
and    iv.effective_end_date =
       (
         select max(iv1.effective_end_date)
         from   pay_input_values_f iv1
         where  iv1.input_value_id = p_input_value_id
       )
;
--
l_generate varchar2(10);
begin
  open csr_input_value(p_input_value_id => p_input_value_id);
  fetch csr_input_value
  into  l_generate;
  if csr_input_value%found then
    insert_rows
    (p_id        => p_input_value_id
    ,p_type      => C_INPUT_VALUE
    ,p_languages => p_languages
    );
  end if;
  close csr_input_value;
end input_value_change;

------------------------ balance_dimension_change ------------------------
procedure balance_dimension_change
(p_balance_dimension_id in number
,p_languages            in dbms_sql.varchar2s
) is
cursor csr_defined_balances
(p_balance_dimension_id in number
) is
select db.defined_balance_id
from   pay_defined_balances db
where  db.balance_dimension_id = p_balance_dimension_id
;
begin
  for db in csr_defined_balances(p_balance_dimension_id) loop
    insert_rows
    (p_id        => db.defined_balance_id
    ,p_type      => C_DEFINED_BALANCE
    ,p_languages => p_languages
    );
  end loop;
end balance_dimension_change;

------------------------------- delete_row -------------------------------
procedure delete_row
(p_id in varchar2
,p_type in varchar2
,p_language in varchar2
) is
begin
  delete from pay_dyndbi_changes pdc
  where  pdc.id = p_id
  and    pdc.type = p_type
  and    pdc.language = p_language
  ;
end delete_row;

------------------------------ delete_rows -------------------------------
procedure delete_rows
(p_id in number
,p_type in varchar2
) is
begin
  delete from pay_dyndbi_changes pdc
  where  pdc.id = p_id
  and    pdc.type = p_type
  ;
end delete_rows;

end pay_dyndbi_changes_pkg;

/
