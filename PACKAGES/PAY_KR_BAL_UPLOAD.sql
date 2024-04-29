--------------------------------------------------------
--  DDL for Package PAY_KR_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_BAL_UPLOAD" AUTHID CURRENT_USER as
/* $Header: pykrupld.pkh 115.2 2002/02/04 02:20:12 pkm ship        $ */
--------------------------------------------------------------------------------
function expiry_date(p_upload_date       date,
                     p_dimension_name    varchar2,
                     p_assignment_id     number,
                     p_original_entry_id number) return date;
--------------------------------------------------------------------------------
function is_supported(p_dimension_name varchar2) return number;
--------------------------------------------------------------------------------
procedure validate_batch_lines(p_batch_id number);
--------------------------------------------------------------------------------
function include_adjustment(p_balance_type_id    number,
                            p_dimension_name     varchar2,
                            p_original_entry_id  number,
                            p_upload_date	 date,
                            p_batch_line_id      number,
                            p_test_batch_line_id number)
return number;
--------------------------------------------------------------------------------
end pay_kr_bal_upload;

 

/
