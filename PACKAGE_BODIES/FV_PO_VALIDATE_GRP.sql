--------------------------------------------------------
--  DDL for Package Body FV_PO_VALIDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_PO_VALIDATE_GRP" as
-- $Header: FVPOVALB.pls 120.1 2005/08/16 16:30:17 ksriniva noship $

function get_balance_segment(l_ledger_id number) return varchar2;


PROCEDURE    CHECK_AGREEMENT_DATES(x_code_combination_id in number,
			               x_org_id      in number,
				       x_ledger_id   in number,
				       x_called_from   in varchar2,
                                       x_ATTRIBUTE1  IN VARCHAR2,
                                       x_ATTRIBUTE2  IN VARCHAR2,
                                       x_ATTRIBUTE3  IN VARCHAR2,
                                       x_ATTRIBUTE4  IN VARCHAR2,
                                       x_ATTRIBUTE5  IN VARCHAR2,
                                       x_ATTRIBUTE6  IN VARCHAR2,
                                       x_ATTRIBUTE7  IN VARCHAR2,
                                       x_ATTRIBUTE8  IN VARCHAR2,
                                       x_ATTRIBUTE9  IN VARCHAR2,
                                       x_ATTRIBUTE10 IN VARCHAR2,
                                       x_ATTRIBUTE11 IN VARCHAR2,
                                       x_ATTRIBUTE12 IN VARCHAR2,
                                       x_ATTRIBUTE13 IN VARCHAR2,
                                       x_ATTRIBUTE14 IN VARCHAR2,
                                       x_ATTRIBUTE15 IN VARCHAR2,
                                       x_status out nocopy varchar2,
                                       x_message out nocopy varchar2) is

         l_agreement_num_col      VARCHAR2(30);
         l_start_date_col         VARCHAR2(30);
         l_end_date_col           VARCHAR2(30);
         l_commitment_start_date  DATE;
         l_commitment_end_date    DATE;

         l_err_code               BOOLEAN;
         l_app_id                 number;
         l_dff			  varchar2(40);
         l_err_mesg               VARCHAR2(250);
         l_status                 varchar2(1);
         l_message                VARCHAR2(50);

         l_fund_value             VARCHAR2(25);
         l_stmt                   VARCHAR2(500);
         l_stmt                   VARCHAR2(500);
         l_profile_value          VARCHAR2(1);
         l_warning                VARCHAR2(1);
         l_ccid                   NUMBER(15);
         l_fund_category          fv_fund_parameters.fund_category%TYPE;
         l_start_dt               VARCHAR2(150);
         l_end_dt                 VARCHAR2(150);
         l_bal_seg_name           VARCHAR2(30);
         l_expiration_date        DATE;
         l_start_date             DATE;
         l_end_date               DATE;
         l_start_commit_date      DATE;
         l_end_commit_date        DATE;
         l_agreement_number       varchar2(30);
         l_module       varchar2(200)   :='FV_PO_VALIDATE_PKG.check_agreement_date';

BEGIN

       x_message := null;
       x_status := 'S';



	FND_PROFILE.GET('FV_VERIFY_REIMBURSABLE_DATES', l_profile_value);
        FND_PROFILE.GET('FV_WARNING_MESSAGE', l_warning);

        if ( nvl(l_profile_value , 'N') <> 'Y')  then
          return;
        End if;

        --determine fund segment
--------------------------------
                l_bal_seg_name := get_balance_segment(x_ledger_id);
--------------------------------------

             if l_bal_seg_name = 'ERROR' then
              x_message := 'FV_RA_NO_FUND';
              x_status  := 'E';
	      return;
	    End if;

                l_ccid   := x_code_combination_id;

                SELECT   decode(l_bal_seg_name,
                        'SEGMENT1', gcc.segment1,
                        'SEGMENT2', gcc.segment2,
                        'SEGMENT3', gcc.segment3,
                        'SEGMENT4', gcc.segment4,
                        'SEGMENT5', gcc.segment5,
                        'SEGMENT6', gcc.segment6,
                        'SEGMENT7', gcc.segment7,
                        'SEGMENT8', gcc.segment8,
                        'SEGMENT9', gcc.segment9,
                        'SEGMENT10',gcc.segment10,
                        'SEGMENT11',gcc.segment11,
                        'SEGMENT12',gcc.segment12,
                        'SEGMENT13',gcc.segment13,
                        'SEGMENT14',gcc.segment14,
                        'SEGMENT15',gcc.segment15,
                        'SEGMENT16',gcc.segment16,
                        'SEGMENT17',gcc.segment17,
                        'SEGMENT18',gcc.segment18,
                        'SEGMENT19',gcc.segment19,
                        'SEGMENT20',gcc.segment20,
                        'SEGMENT21',gcc.segment21,
                        'SEGMENT22',gcc.segment22,
                        'SEGMENT23',gcc.segment23,
                        'SEGMENT24',gcc.segment24,
                        'SEGMENT25',gcc.segment25,
                        'SEGMENT26',gcc.segment26,
                        'SEGMENT27',gcc.segment27,
                        'SEGMENT28',gcc.segment28,
                        'SEGMENT29',gcc.segment29,
                        'SEGMENT30',gcc.segment30)
                   INTO   l_fund_value
                   FROM   gl_code_combinations gcc
                   where  code_combination_id = l_ccid;

              BEGIN
                   SELECT fund_category, fts.expiration_date
                   INTO   l_fund_category , l_expiration_date
                   FROM   fv_fund_parameters fp,
                          fv_treasury_symbols fts
                   WHERE  fp.fund_value = l_fund_value
		  and     fts.treasury_symbol_id = fp.treasury_symbol_id
                   AND    fts.set_of_books_id = x_ledger_id ;

              EXCEPTION
                when no_data_found then
                x_status  := 'E';
                x_message := 'FV_RA_NO_FUND';
                  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module, x_message);
                  END IF;
	       return;
	     END;


  ----
	 if (x_called_from = 'PO') then
          l_app_id := 201;
          l_dff    := 'PO_DISTRIBUTIONS';
	 else
          l_app_id := 200;
          l_dff    := 'AP_INVOICE_DISTRIBUTIONS';
	End if;

IF l_fund_category IN ('R', 'S', 'T') THEN   /* 1 */


        BEGIN
                SELECT application_column_name
                INTO   l_agreement_num_col
                FROM   fnd_descr_flex_col_usage_vl
                WHERE  application_id = l_app_id
                AND    form_left_prompt = 'Agreement Number'
                AND    descriptive_flexfield_name = l_dff;
        EXCEPTION
                when no_data_found then
                 x_status   := 'E';
                 x_message  := 'FV_RA_NO_AGREEMENT_DFF';

                  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module, x_message);
                  END IF;
        END;

        BEGIN
                SELECT application_column_name
                INTO   l_start_date_col
                FROM   fnd_descr_flex_col_usage_vl
                WHERE  application_id = l_app_id
                AND    form_left_prompt = 'Start Date'
                AND    descriptive_flexfield_name = l_dff;
        EXCEPTION
                when no_data_found then
                 x_status   := 'E';
                 x_message     := 'FV_RA_NO_AGREEMENT_DFF';
                  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module, x_message);
                  END IF;
        END;

        BEGIN

                SELECT application_column_name
                INTO   l_end_date_col
                FROM   fnd_descr_flex_col_usage_vl
                WHERE  application_id = l_app_id
                AND    form_left_prompt = 'End Date'
                AND    descriptive_flexfield_name = l_dff;
        EXCEPTION
                when no_data_found then
                 x_status   := 'E';
                 x_message    := 'FV_RA_NO_AGREEMENT_DFF';
                  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module, x_message);
                  END IF;
        END;


  --- Now get the values for  agreement number , start date and end_date passed through the attributes
  --     value passed and attributes defined in DFF

  -- aggrement number
       select decode( substr(l_agreement_num_col,10,2),
                           1, x_attribute1,
                           2, x_attribute2,
                           3, x_attribute3,
                           4, x_attribute4,
                           5, x_attribute5,
                           6, x_attribute6,
                           7, x_attribute7,
                           8, x_attribute8,
                           9, x_attribute9,
                           10, x_attribute10,
                           11, x_attribute11,
                           12, x_attribute12,
                           13, x_attribute13,
                           14, x_attribute14,
                           15, x_attribute15 )
   into l_agreement_number from dual;


 -- start_date
              select decode( substr(l_start_date_col,10,2),
                           1, x_attribute1,
                           2, x_attribute2,
                           3, x_attribute3,
                           4, x_attribute4,
                           5, x_attribute5,
                           6, x_attribute6,
                           7, x_attribute7,
                           8, x_attribute8,
                           9, x_attribute9,
                           10, x_attribute10,
                           11, x_attribute11,
                           12, x_attribute12,
                           13, x_attribute13,
                           14, x_attribute14,
                           15, x_attribute15 )
       into l_start_dt  from dual;


 -- endt_date
              select decode( substr(l_end_date_col,10,2),
                           1, x_attribute1,
                           2, x_attribute2,
                           3, x_attribute3,
                           4, x_attribute4,
                           5, x_attribute5,
                           6, x_attribute6,
                           7, x_attribute7,
                           8, x_attribute8,
                           9, x_attribute9,
                           10, x_attribute10,
                           11, x_attribute11,
                           12, x_attribute12,
                           13, x_attribute13,
                           14, x_attribute14,
                           15, x_attribute15 )
       into l_end_dt  from dual;

       l_end_date := trunc(to_date(l_end_dt,'YYYY/MM/DD hh24:mi:ss'));

    IF l_agreement_number is null THEN
        x_message := 'FV_RA_NO_AGREEMENT';
        x_status  :='E';

    ELSIF l_start_date is null THEN
            x_status  :='E';
           x_message := 'FV_RA_NO_START_DATE';
    ELSIF l_end_date is null THEN
           x_message :=     'FV_RA_NO_END_DATE';
            x_status  :='E';
    ELSE

           BEGIN
                SELECT trunc(start_date_commitment), trunc(end_date_commitment)
                INTO   l_start_commit_date, l_end_commit_date
                FROM   ra_customer_trx
               WHERE    trx_number = l_agreement_number
                and  set_of_books_id = x_ledger_id;


                IF (l_start_commit_date IS NULL) THEN
                 x_message :=  'FV_RA_NO_PERFORM_DATES';
                 x_status :='E';
                ELSIF (l_end_commit_date IS NULL) THEN
                  x_message := 'FV_RA_NO_PERFORM_DATES';
                  x_status  :='E';
                End if;

              EXCEPTION
                when no_data_found then
                    X_MESSAGE := 'FV_RA_AGRMT_NOTFOUND';
                    x_status  :='E';
            END;
      END IF;

        IF l_start_date < l_start_commit_date THEN
                x_message := 'FV_RA_SD_LESS_AGREE';
                    x_status  :='E';
        ELSIF  l_start_date > l_end_commit_date THEN
                X_MESSAGE := 'FV_RA_SD_MORE_AGREE';
                    x_status  :='E';

        ELSIF l_end_date < l_start_commit_date THEN
                x_message := 'FV_RA_ED_LESS_AGREE';
                    x_status  :='E';

        ELSIF l_end_date> l_end_commit_date THEN
                x_message := 'FV_RA_ED_MORE_AGREE';
                x_status  :='E';
        END IF;

      return;
   END IF; /* 1*/

    ---- checking PYA Validation warning message

     If l_warning = 'Y' then
        IF l_expiration_date < trunc(sysdate) THEN
        x_message := 'FV_PY_WARNING';
        x_status  := 'W';
     END IF;
   End if;

   END CHECK_AGREEMENT_DATES;

 --------------------------------------------------------------------------------------------

function get_balance_segment(l_ledger_id number) return varchar2 is

l_module varchar2(150) := 'fv.pls.fv_po_validate.get_balance_segment';
l_ledger_name varchar2(150);
l_bal_seg_name varchar2(30);
l_coa_id    number(15);
l_boolean   boolean;


begin
  --- retrieve coa id

   select chart_of_accounts_id into l_coa_id
   from gl_ledgers_public_v
   where ledger_id = l_ledger_id;


     l_boolean := FND_FLEX_APIS.GET_SEGMENT_COLUMN(101,'GL#',l_coa_id, 'GL_BALANCING',l_bal_seg_name);
     IF(l_boolean) THEN
         null;
     ELSE
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module,'Did not find Balance Segment' );
                  END IF;
     END IF;

     return  upper(l_bal_seg_name);

EXCEPTION
  when no_data_found then
     IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module,'No Data found in get_balance_segment' );
     END IF;
     return  'ERROR';
  when others then
     IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module,'Error in get_balance_segment' );
     END IF;
     return  'ERROR';

END get_balance_segment;

------------------------------------------------------------------------------

End FV_PO_VALIDATE_GRP;


/
