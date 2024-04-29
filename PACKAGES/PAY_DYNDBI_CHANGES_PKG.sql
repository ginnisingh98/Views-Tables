--------------------------------------------------------
--  DDL for Package PAY_DYNDBI_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DYNDBI_CHANGES_PKG" AUTHID CURRENT_USER as
/* $Header: pydbichg.pkh 120.2 2005/11/07 09:13:55 arashid noship $ */

-- ========= --
-- Constants --
-- ========= --
C_DEFINED_BALANCE constant varchar2(16) := 'DB';
C_ELEMENT_TYPE    constant varchar2(16) := 'ET';
C_INPUT_VALUE     constant varchar2(16) := 'EIV';

------------------------------- insert_row -------------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Inserts a row into PAY_DYNDBI_CHANGES. No insert is performed if
--   an identical row already exists.
--
procedure insert_row
(p_id in varchar2
,p_type in varchar2
,p_language in varchar2
);

------------------------------ insert_rows -------------------------------
--
-- NAME
--   insert_rows
--
-- DESCRIPTION
--   Inserts rows into PAY_DYNDBI_CHANGES. No insert is performed if
--   an identical row already exists.
--
procedure insert_rows
(p_id in varchar2
,p_type in varchar2
,p_languages in dbms_sql.varchar2s
);

-------------------------- element_type_change ---------------------------
--
-- NAME
--   element_type_change
--
-- DESCRIPTION
--   Inserts rows into PAY_DYNDBI_CHANGES to record database items to be
--   regenerated after an element name translation has changed.
--
procedure element_type_change
(p_element_type_id in number
,p_languages       in dbms_sql.varchar2s
);

-------------------------- balance_type_change ---------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Inserts rows into PAY_DYNDBI_CHANGES to record database items to be
--   regenerated after a balance name translation has changed.
--
procedure balance_type_change
(p_balance_type_id in number
,p_languages       in dbms_sql.varchar2s
);

--------------------------- input_value_change ---------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Inserts rows into PAY_DYNDBI_CHANGES to record database items to be
--   regenerated after an element input value name translation has
--   changed.
--
procedure input_value_change
(p_input_value_id in number
,p_languages      in dbms_sql.varchar2s
);

------------------------ balance_dimension_change ------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Inserts rows into PAY_DYNDBI_CHANGES to record database items to be
--   regenerated after a balance dimension translation has changed.
--
procedure balance_dimension_change
(p_balance_dimension_id in number
,p_languages            in dbms_sql.varchar2s
);

------------------------------- delete_row -------------------------------
--
-- NAME
--   delete_row
--
-- DESCRIPTION
--   Deletes a row from PAY_DYNDBI_CHANGES.
--
procedure delete_row
(p_id in varchar2
,p_type in varchar2
,p_language in varchar2
);

------------------------------ delete_rows -------------------------------
--
-- NAME
--   delete_row
--
-- DESCRIPTION
--   Deletes rows from PAY_DYNDBI_CHANGES according to id and type.
--
procedure delete_rows
(p_id in number
,p_type in varchar2
);

end pay_dyndbi_changes_pkg;

 

/
