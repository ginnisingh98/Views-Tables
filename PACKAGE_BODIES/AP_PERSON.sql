--------------------------------------------------------
--  DDL for Package Body AP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PERSON" AS
/* $Header: appersnb.pls 115.0 99/07/17 07:32:24 porting ship $ */

  /*
    NAME
      ap_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */

    PROCEDURE ap_predel_validation (p_person_id   number) IS

        v_delete_permitted    varchar2(1);

    BEGIN

        hr_utility.set_location('AP_PERSON.AP_PREDEL_VALIDATION', 1);

        begin
            select  'Y'
            into    v_delete_permitted
            from    sys.dual
            where   not exists (
                    select  null
                    from    ap_expense_report_headers_all   erh
                    where   erh.employee_id                 = P_PERSON_ID);
         exception
            when NO_DATA_FOUND then
                    hr_utility.set_message (801, 'HR_6244_ALL_AP_PER_NO_DEL');
                    hr_utility.raise_error;
         end;

    END ap_predel_validation;

END AP_PERSON;

/
