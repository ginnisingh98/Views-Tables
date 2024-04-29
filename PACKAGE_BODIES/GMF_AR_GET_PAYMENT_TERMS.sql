--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_PAYMENT_TERMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_PAYMENT_TERMS" as
/* $Header: gmfpaytb.pls 115.4 1999/12/10 07:51:06 pkm ship      $ */
          apps_base_language	fnd_languages.language_code%TYPE;
          cursor cur_ar_get_payment_terms(start_date   date,
                                          end_date     date,
                                          term_name    varchar2,
                                          termid       number) is
             select PAY.NAME,                   PYT.term_id,
                    PYT.CREDIT_CHECK_FLAG,      PYT.DUE_CUTOFF_DAY,
                    PYT.PRINTING_LEAD_DAYS,     PAY.DESCRIPTION,
                    PYT.BASE_AMOUNT,            PYT.CALC_DISCOUNT_ON_LINES_FLAG,
                    PYT.FIRST_INSTALLMENT_CODE, PYT.IN_USE,
                    PYT.PARTIAL_DISCOUNT_FLAG,  PYT.ATTRIBUTE_CATEGORY,
                    PYT.ATTRIBUTE1,             PYT.ATTRIBUTE2,
                    PYT.ATTRIBUTE3,             PYT.ATTRIBUTE4,
                    PYT.ATTRIBUTE5,             PYT.ATTRIBUTE6,
                    PYT.ATTRIBUTE7,             PYT.ATTRIBUTE8,
                    PYT.ATTRIBUTE9,             PYT.ATTRIBUTE10,
                    PYT.ATTRIBUTE11,            PYT.ATTRIBUTE12,
                    PYT.ATTRIBUTE13,            PYT.ATTRIBUTE14,
                    PYT.ATTRIBUTE15,            PYT.CREATED_BY,
                    PYT.CREATION_DATE,          PYT.LAST_UPDATE_DATE,
                    PYT.LAST_UPDATED_BY
             from   RA_TERMS_B PYT ,
                    RA_TERMS_TL PAY
	     -- B1107729 NAME column is referred from PAY instead of PYT
             where  lower(PAY.name) like lower(nvl(term_name, PAY.name))
               and  PYT.term_id = nvl(termid, PYT.term_id)
               and  PYT.term_id = PAY.term_id
               and  PAY.language = apps_base_language
               and  PYT.last_update_date between
                                         nvl(start_date, PYT.last_update_date)
                                     and nvl(end_date, PYT.last_update_date);

    procedure AR_GET_PAYMENT_TERMS (term_name          in out varchar2,
                                    termid             in out number,
                                    start_date         in out date,
                                    end_date           in out date,
                                    credit_check       out    varchar2,
                                    cutoff_day         out    varchar2,
                                    print_lead_days    out    varchar2,
                                    description        out    varchar2,
                                    base_amount        out    varchar2,
                                    calc_discount      out    varchar2,
                                    installment_cd     out    varchar2,
                                    in_use             out    varchar2,
                                    partial_discount   out    varchar2,
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
                                    created_by         out    number,
                                    creation_date      out    date,
                                    last_update_date   out    date,
                                    last_updated_by    out    number,
                                    row_to_fetch       in out number,
                                    error_status       out    number) is

    begin

         SELECT language_code
         INTO apps_base_language
         FROM fnd_languages
         WHERE installed_flag = 'B';

         if NOT cur_ar_get_payment_terms%ISOPEN then
            open cur_ar_get_payment_terms(start_date, end_date,
                                          term_name, termid);
         end if;

         fetch cur_ar_get_payment_terms
         into  term_name,           termid,            credit_check,
               cutoff_day,          print_lead_days,   description,
               base_amount,         calc_discount,     installment_cd,
               in_use,              partial_discount,  attr_category,
               att1,                att2,              att3,
               att4,                att5,              att6,
               att7,                att8,              att9,
               att10,               att11,             att12,
               att13,               att14,             att15,
               created_by,          creation_date,     last_update_date,
               last_updated_by;

        if cur_ar_get_payment_terms%NOTFOUND then
           error_status := 100;
           close cur_ar_get_payment_terms;
        end if;
        if row_to_fetch = 1 and cur_ar_get_payment_terms%ISOPEN then
           close cur_ar_get_payment_terms;
        end if;

      exception

          when others then
               error_status := SQLCODE;

  end AR_GET_PAYMENT_TERMS;
END GMF_AR_GET_PAYMENT_TERMS;

/
