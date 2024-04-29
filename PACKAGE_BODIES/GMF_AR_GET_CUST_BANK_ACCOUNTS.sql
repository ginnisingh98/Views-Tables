--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_CUST_BANK_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_CUST_BANK_ACCOUNTS" as
/* $Header: gmfbankb.pls 115.0 99/07/16 04:14:46 porting shi $ */
          cursor cur_ar_get_cust_bank_accounts(start_date  date,
                                               end_date    date,
                                               cust_id     number,
                                               siteuseid   number) is
             select BAU.CUSTOMER_ID,             BAU.CUSTOMER_SITE_USE_ID,
                    BAU.PRIMARY_FLAG,            BAU.START_DATE,
                    BAU.END_DATE,                BAC.BANK_ACCOUNT_NUM,
                    BAC.BANK_ACCOUNT_NAME,       BAC.CURRENCY_CODE,
                    BAC.DESCRIPTION,             BAC.MAX_CHECK_AMOUNT,
                    BAC.MIN_CHECK_AMOUNT,        BAC.INACTIVE_DATE,
                    BAC.ASSET_CODE_COMBINATION_ID,
                    BAC.GAIN_CODE_COMBINATION_ID,
                    BAC.LOSS_CODE_COMBINATION_ID,
                    BAC.BANK_ACCOUNT_TYPE,       BAC.MAX_OUTLAY,
                    BAC.MULTI_CURRENCY_FLAG,     BAC.ACCOUNT_TYPE,
                    BAC.POOLED_FLAG,             BAC.ZERO_AMOUNTS_ALLOWED,
                    BAU.ATTRIBUTE_CATEGORY,      BAU.ATTRIBUTE1,
                    BAU.ATTRIBUTE2,              BAU.ATTRIBUTE3,
                    BAU.ATTRIBUTE4,              BAU.ATTRIBUTE5,
                    BAU.ATTRIBUTE6,              BAU.ATTRIBUTE7,
                    BAU.ATTRIBUTE8,              BAU.ATTRIBUTE9,
                    BAU.ATTRIBUTE10,             BAU.ATTRIBUTE11,
                    BAU.ATTRIBUTE12,             BAU.ATTRIBUTE13,
                    BAU.ATTRIBUTE14,             BAU.ATTRIBUTE15,
                    BAU.CREATED_BY,              BAU.CREATION_DATE,
                    BAU.LAST_UPDATE_DATE,        BAU.LAST_UPDATED_BY
             from   AP_BANK_ACCOUNT_USES_ALL BAU,
                    AP_BANK_ACCOUNTS_ALL BAC
             where  ((BAU.customer_id = nvl(cust_id, BAU.customer_id)
                     and  BAU.customer_site_use_id =
		          nvl(siteuseid, BAU.customer_site_use_id))
                    or  (BAU.customer_id = nvl(cust_id, BAU.customer_id)
                        and  BAU.customer_site_use_id is null))
               and  BAU.external_bank_account_id = BAC.bank_account_id
               and  BAU.last_update_date between
                                         nvl(start_date, BAU.last_update_date)
                                     and nvl(end_date, BAU.last_update_date)
             order by BAU.customer_id, BAU.customer_site_use_id,
                      BAU.primary_flag desc;

    procedure AR_GET_CUST_BANK_ACCOUNTS (cust_id            in out number,
                                         siteuseid          in out number,
                                         start_date         in out date,
                                         end_date           in out date,
                                         primary_flag       out    varchar2,
                                         start_date_active  out    date,
                                         end_date_active    out    date,
                                         account_number     out    varchar2,
                                         account_name       out    varchar2,
                                         currency_code      out    varchar2,
                                         description        out    varchar2,
                                         max_check_amount   out    number,
                                         min_check_amount   out    number,
                                         inactive_date      out    date,
                                         asset_ccid         out    number,
                                         gain_ccid          out    number,
                                         loss_ccid          out    number,
                                         bank_account_type  out    varchar2,
                                         max_outlay         out    varchar2,
                                         multi_curr_flag    out    varchar2,
                                         account_type       out    varchar2,
                                         pooled_flag        out    varchar2,
                                         zero_amt_allowed   out    varchar2,
                                         attr_category      out    varchar2,
                                         att1               out    varchar2,
                                         att2               out    varchar2,
                                         att3               out    varchar2,
                                         att4               out    varchar2,
                                         att5               out    varchar2,
                                         att6               out    varchar2,
                                         att7               out    varchar2,
                                         att8               out    varchar2,
                                         att9               out    varchar2,
                                         att10              out    varchar2,
                                         att11              out    varchar2,
                                         att12              out    varchar2,
                                         att13              out    varchar2,
                                         att14              out    varchar2,
                                         att15              out    varchar2,
                                         created_by         out    varchar2,
                                         creation_date      out    date,
                                         last_update_date   out    date,
                                         last_updated_by    out    varchar2,
                                         row_to_fetch       in out number,
                                         error_status       out    number) is

    createdby    number;
    modifiedby   number;

    begin

         if NOT cur_ar_get_cust_bank_accounts%ISOPEN then
            open cur_ar_get_cust_bank_accounts(start_date, end_date,
                                               cust_id,    siteuseid);
         end if;

         fetch cur_ar_get_cust_bank_accounts
         into  cust_id,             siteuseid,        primary_flag,
               start_date_active,   end_date_active,  account_number,
               account_name,        currency_code,    description,
               max_check_amount,    min_check_amount, inactive_date,
               asset_ccid,          gain_ccid,        loss_ccid,
               bank_account_type,   max_outlay,       multi_curr_flag,
               account_type,        pooled_flag,      zero_amt_allowed,
               attr_category,       att1,             att2,
               att3,                att4,             att5,
               att6,                att7,             att8,
               att9,                att10,            att11,
               att12,               att13,            att14,
               att15,               createdby,        creation_date,
               last_update_date,    modifiedby;

        if cur_ar_get_cust_bank_accounts%NOTFOUND then
           error_status := 100;
           close cur_ar_get_cust_bank_accounts;
        else
           created_by := gmf_fnd_get_users.fnd_get_users(createdby);
           last_updated_by := gmf_fnd_get_users.fnd_get_users(modifiedby);
        end if;
        if row_to_fetch = 1 and cur_ar_get_cust_bank_accounts%ISOPEN then
           close cur_ar_get_cust_bank_accounts;
        end if;

      exception

          when others then
               error_status := SQLCODE;

  end AR_GET_CUST_BANK_ACCOUNTS;
END GMF_AR_GET_CUST_BANK_ACCOUNTS;

/
