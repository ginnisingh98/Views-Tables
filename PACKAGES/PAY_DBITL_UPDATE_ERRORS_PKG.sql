--------------------------------------------------------
--  DDL for Package PAY_DBITL_UPDATE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DBITL_UPDATE_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: pydbtlue.pkh 120.1 2006/11/10 17:24:20 arashid noship $ */
--
-- Longer bulk bind type.
--
type t_vc4k is table of varchar2(4096) index by binary_integer;
------------------------------- insert_row -------------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Inserts a row into PAY_DBITL_UPDATE_ERRORS.
--
procedure insert_row
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
,p_message_text    in varchar2
);

procedure insert_row
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
,p_message_text    in varchar2
,p_rowid              out nocopy varchar2
);


------------------------------- delete_rows ------------------------------
--
-- NAME
--   delete_rows, delete_row
--
-- DESCRIPTION
--   Delete row(s) from PAY_DBITL_UPDATE_ERRORS.
--
procedure delete_rows
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
);

procedure delete_rows
(p_rowids in dbms_sql.varchar2s
);

procedure delete_row
(p_rowid in varchar2
);

----------------------------- fetch_all_rows -----------------------------
--
-- NAME
--   fetch_all_rows
--
-- DESCRIPTION
--   Fetch all rows from PAY_DBITL_UPDATE_ERRORS.
--
procedure fetch_all_rows
(p_rowids   out nocopy dbms_sql.varchar2s
,p_messages out nocopy dbms_sql.varchar2_table
);

end pay_dbitl_update_errors_pkg;

 

/
