--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_IGIPMTHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_IGIPMTHP_PKG" AS
-- $Header: IGIPMTHB.pls 120.0.12000000.2 2007/07/16 12:35:51 vensubra noship $
  -- Private type declarations
 procedure populate_history (p_old_header_id number, p_request_status_code varchar2)
  is
      l_new_header_id number;
  begin
    select IGI_CIS_MTH_RET_HDR_T_S.nextval into l_new_header_id from dual;
    insert into igi_cis_mth_ret_hdr_h
      (HEADER_ID,
             ORG_ID,
             CIS_SENDER_ID,
             TAX_OFFICE_NUMBER,
             PAYE_REFERENCE,
             REQUEST_ID,
             REQUEST_STATUS_CODE,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_LOGIN_ID,
             UNIQUE_TAX_REFERENCE_NUM,
             ACCOUNTS_OFFICE_REFERENCE,
             PERIOD_NAME,
             PERIOD_ENDING_DATE,
             NIL_RETURN_FLAG,
             EMPLOYMENT_STATUS_FLAG,
             SUBCONT_VERIFY_FLAG,
             INFORMATION_CORRECT_FLAG,
             INACTIVITY_INDICATOR,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY)
      select l_new_header_id,
             ORG_ID,
             CIS_SENDER_ID,
             TAX_OFFICE_NUMBER,
             PAYE_REFERENCE,
             REQUEST_ID,
             p_request_status_code,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_LOGIN_ID,
             UNIQUE_TAX_REFERENCE_NUM,
             ACCOUNTS_OFFICE_REFERENCE,
             PERIOD_NAME,
             PERIOD_ENDING_DATE,
             NIL_RETURN_FLAG,
             EMPLOYMENT_STATUS_FLAG,
             SUBCONT_VERIFY_FLAG,
             INFORMATION_CORRECT_FLAG,
             INACTIVITY_INDICATOR,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY
        from  igi_cis_mth_ret_hdr_h
        where HEADER_ID  = p_old_header_id ;

        insert into igi_cis_mth_ret_lines_h
        (HEADER_ID,
               ORG_ID,
               VENDOR_ID,
               VENDOR_NAME,
               VENDOR_TYPE_LOOKUP_CODE,
               FIRST_NAME,
               SECOND_NAME,
               LAST_NAME,
               SALUTATION,
               TRADING_NAME,
               UNMATCHED_TAX_FLAG,
               UNIQUE_TAX_REFERENCE_NUM,
               COMPANY_REGISTRATION_NUMBER,
               NATIONAL_INSURANCE_NUMBER,
               VERIFICATION_NUMBER,
               TOTAL_PAYMENTS,
               LABOUR_COST,
               MATERIAL_COST,
               TOTAL_DEDUCTIONS,
               DISCOUNT_AMOUNT,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY)
        select l_new_header_id,
               ORG_ID,
               VENDOR_ID,
               VENDOR_NAME,
               VENDOR_TYPE_LOOKUP_CODE,
               FIRST_NAME,
               SECOND_NAME,
               LAST_NAME,
               SALUTATION,
               TRADING_NAME,
               UNMATCHED_TAX_FLAG,
               UNIQUE_TAX_REFERENCE_NUM,
               COMPANY_REGISTRATION_NUMBER,
               NATIONAL_INSURANCE_NUMBER,
               VERIFICATION_NUMBER,
               TOTAL_PAYMENTS,
               LABOUR_COST,
               MATERIAL_COST,
               TOTAL_DEDUCTIONS,
               DISCOUNT_AMOUNT,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY
          from igi_cis_mth_ret_lines_h
          where HEADER_ID  = p_old_header_id ;

          insert into igi_cis_mth_ret_pay_h
          (HEADER_ID,
                 ORG_ID,
                 VENDOR_ID,
                 CHILD_VENDOR_ID,
                 INVOICE_ID,
                 INVOICE_PAYMENT_ID,
                 AMOUNT,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT)
          Select l_new_header_id,
                 ORG_ID,
                 VENDOR_ID,
                 CHILD_VENDOR_ID,
                 INVOICE_ID,
                 INVOICE_PAYMENT_ID,
                 AMOUNT,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT
            from igi_cis_mth_ret_pay_h
            where HEADER_ID  = p_old_header_id ;
          commit;
  end;

  PROCEDURE pr_audit_update(p_in_header_id IN NUMBER,p_in_completion_code IN VARCHAR2)
  IS
    l_cnt_header_id number;
    l_temp_count number :=0;
    l_hist_count number :=0;
  BEGIN

    --Following block added for bug # 6074547
    begin
      select count(header_id) into l_temp_count
      from igi_cis_mth_ret_hdr_t where header_id = p_in_header_id;

      select count(header_id) into l_hist_count
      from igi_cis_mth_ret_hdr_h where header_id = p_in_header_id;

      if l_temp_count = 0 and l_hist_count > 0 then
         populate_history(p_in_header_id,p_in_completion_code);
         return;
      end if;
    end;

    update igi_cis_mth_ret_hdr_t
      set REQUEST_STATUS_CODE = p_in_completion_code,
      PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID(),
      PROGRAM_ID = FND_GLOBAL.CONC_PROGRAM_ID(),
      PROGRAM_LOGIN_ID = FND_GLOBAL.CONC_LOGIN_ID()
      where HEADER_ID = p_in_header_id;
      BEGIN
        select count(header_id)
          into l_cnt_header_id
          from igi_cis_mth_ret_hdr_h
         where header_id = p_in_header_id
         group by header_id;
      EXCEPTION
        when no_data_found then
         l_cnt_header_id := 0;
      END;
   IF (l_cnt_header_id = 0) THEN
   insert into igi_cis_mth_ret_hdr_h
      (HEADER_ID,
             ORG_ID,
             CIS_SENDER_ID,
             TAX_OFFICE_NUMBER,
             PAYE_REFERENCE,
             REQUEST_ID,
             REQUEST_STATUS_CODE,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_LOGIN_ID,
             UNIQUE_TAX_REFERENCE_NUM,
             ACCOUNTS_OFFICE_REFERENCE,
             PERIOD_NAME,
             PERIOD_ENDING_DATE,
             NIL_RETURN_FLAG,
             EMPLOYMENT_STATUS_FLAG,
             SUBCONT_VERIFY_FLAG,
             INFORMATION_CORRECT_FLAG,
             INACTIVITY_INDICATOR,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY)
      select HEADER_ID,
             ORG_ID,
             CIS_SENDER_ID,
             TAX_OFFICE_NUMBER,
             PAYE_REFERENCE,
             REQUEST_ID,
             REQUEST_STATUS_CODE,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_LOGIN_ID,
             UNIQUE_TAX_REFERENCE_NUM,
             ACCOUNTS_OFFICE_REFERENCE,
             PERIOD_NAME,
             PERIOD_ENDING_DATE,
             NIL_RETURN_FLAG,
             EMPLOYMENT_STATUS_FLAG,
             SUBCONT_VERIFY_FLAG,
             INFORMATION_CORRECT_FLAG,
             INACTIVITY_INDICATOR,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY
        from  igi_cis_mth_ret_hdr_t
        where HEADER_ID  = p_in_header_id ;
        insert into igi_cis_mth_ret_lines_h
        (HEADER_ID,
               ORG_ID,
               VENDOR_ID,
               VENDOR_NAME,
               VENDOR_TYPE_LOOKUP_CODE,
               FIRST_NAME,
               SECOND_NAME,
               LAST_NAME,
               SALUTATION,
               TRADING_NAME,
               UNMATCHED_TAX_FLAG,
               UNIQUE_TAX_REFERENCE_NUM,
               COMPANY_REGISTRATION_NUMBER,
               NATIONAL_INSURANCE_NUMBER,
               VERIFICATION_NUMBER,
               TOTAL_PAYMENTS,
               LABOUR_COST,
               MATERIAL_COST,
               TOTAL_DEDUCTIONS,
               DISCOUNT_AMOUNT,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY)
        select HEADER_ID,
               ORG_ID,
               VENDOR_ID,
               VENDOR_NAME,
               VENDOR_TYPE_LOOKUP_CODE,
               FIRST_NAME,
               SECOND_NAME,
               LAST_NAME,
               SALUTATION,
               TRADING_NAME,
               UNMATCHED_TAX_FLAG,
               UNIQUE_TAX_REFERENCE_NUM,
               COMPANY_REGISTRATION_NUMBER,
               NATIONAL_INSURANCE_NUMBER,
               VERIFICATION_NUMBER,
               TOTAL_PAYMENTS,
               LABOUR_COST,
               MATERIAL_COST,
               TOTAL_DEDUCTIONS,
               DISCOUNT_AMOUNT,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY
          from igi_cis_mth_ret_lines_t
          where HEADER_ID  = p_in_header_id ;
          insert into igi_cis_mth_ret_pay_h
          (HEADER_ID,
                 ORG_ID,
                 VENDOR_ID,
                 CHILD_VENDOR_ID,
                 INVOICE_ID,
                 INVOICE_PAYMENT_ID,
                 AMOUNT,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT)
          Select HEADER_ID,
                 ORG_ID,
                 VENDOR_ID,
                 CHILD_VENDOR_ID,
                 INVOICE_ID,
                 INVOICE_PAYMENT_ID,
                 AMOUNT,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT
            from igi_cis_mth_ret_pay_t
            where HEADER_ID  = p_in_header_id ;
          delete from igi_cis_mth_ret_hdr_t where header_id = p_in_header_id;
          delete from igi_cis_mth_ret_lines_t where header_id = p_in_header_id;
          delete from igi_cis_mth_ret_pay_t where header_id = p_in_header_id;
          commit;
       ELSE
        null;
       END IF;
       EXCEPTION
        when others then
         --raise_application_error('-20301','Error in insertion of audit table ');
         null;
      end pr_audit_update ;
end IGI_CIS2007_IGIPMTHP_PKG;

/
