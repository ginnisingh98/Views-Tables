--------------------------------------------------------
--  DDL for Package Body FV_PROMPT_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_PROMPT_PAY" as
    -- $Header: FVPPPSTB.pls 120.11 2006/10/11 09:35:07 arcgupta ship $
    --==============================================================
  g_module_name VARCHAR2(100) := 'fv.plsql.fv_prompt_pay.';

	-- Error Code and Error Messages
	v_error_code Number := 0 ;
	v_error_mesg Varchar2(500) ;

	-- Variables to hold passed parameters
	v_set_of_books_id	Number ;
	v_from_date		Date ;
	v_to_date		Date ;

----------------------------------------------------------------------
--				MAIN
----------------------------------------------------------------------
procedure main (
		Errbuf        OUT NOCOPY varchar2,
		retcode       OUT NOCOPY varchar2,
               currrency       in varchar2,
                from_date       in  varchar2,
                to_dt           in  varchar2,
		brk1		in number,
		brk2		in number DEFAULT NULL ,
		brk3		in number DEFAULT NULL ,
		brk4		in number DEFAULT NULL ,
		agency1 	in varchar2 DEFAULT NULL ,
		agency2		in varchar2 DEFAULT NULL
		)

IS
  l_module_name VARCHAR2(200) := g_module_name || 'main';
  l_org_id NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_set_of_books_name VARCHAR2(30);
  l_req_id NUMBER(15);

Begin

	-- Initialize parameters to global variables
	 -- Get Current Org ID
            l_org_id := MO_GLOBAL.get_current_org_id;

	mo_utils.get_ledger_info(l_org_id,v_set_of_books_id ,l_set_of_books_name);



	v_from_date     := to_date ( from_date , 'YYYY/MM/DD HH24:MI:SS' );
	v_to_date       := to_date ( to_dt     , 'YYYY/MM/DD HH24:MI:SS' ) ;

/* -- by ks
        If v_error_code = 0 Then
	    Delete from fv_prompt_pay_temp ;
            populate_temp_table ;
        End If ;

        If v_error_code = 0 Then
            Commit ;
*/



	    -- Get Currency Code  by using Set of Books ID
  	    select currency_code
	    into l_currency_code
	    from gl_ledgers_public_v
	    where ledger_id = v_set_of_books_id ;

	    -- Set Org_ID
	    fnd_request.set_org_id ( l_org_id );

	    -- Kick off the Prompt Payment Report
	    l_req_id := fnd_request.submit_request
			(
				application    =>  'FV' ,
				program        =>  'FVPPPPST' ,
				description    =>  NULL ,
				start_time      =>  NULL ,
				sub_request  =>  FALSE ,
				argument1     =>  v_set_of_books_id ,
				argument2     =>  l_set_of_books_name ,
				argument3     =>  l_currency_code ,
				argument4     =>  from_date ,
				argument5     =>  to_dt ,
				argument6     =>  brk1 ,
				argument7     =>  brk2 ,
				argument8     =>  brk3 ,
				argument9     =>  brk4 ,
				argument10   =>  agency1 ,
				argument11   =>  agency2);

	    if ( l_req_id <> 0 ) then
		    -- Set Oeg_ID
		    fnd_request.set_org_id ( l_org_id );
		    -- Kick off the Prompt Payment Exception Report
		    l_req_id := fnd_request.submit_request
				(
					application  =>  'FV' ,
					program	     =>  'FVPPPPEX' ,
					description   =>  NULL ,
					start_time     =>  NULL ,
					sub_request  =>  FALSE ,
					argument1    =>  v_set_of_books_id ,
					argument2    =>  l_set_of_books_name ,
					argument3    =>  l_currency_code ,
					argument4    =>  from_date ,
					argument5    =>  to_dt ,
					argument6    =>  agency1 ,
					argument7    =>  agency2);
	      COMMIT;
          Else
                Rollback ;
          End If ;


        retcode := to_char(v_error_code) ;
        errbuf  := v_error_mesg ;

EXCEPTION
  WHEN OTHERS THEN
    v_error_code := SQLCODE ;
    v_error_mesg  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', v_error_mesg) ;
    RAISE;
End Main ;


----------------------------------------------------------------------
--                     populate_temp_table
----------------------------------------------------------------------
Procedure populate_temp_table is
  l_module_name VARCHAR2(200) := g_module_name || 'populate_temp_table';

   Begin

    Insert Into fv_prompt_pay_temp
    (   invoice_id	   ,
        pay_invoice_id,
        pay_payment_number    ,
        pay_due_date     ,
        discount_amount_available ,
        invoice_payment_id ,
        discount_taken ,
        check_date   ,
        invoice_amount,
	invoice_type_lookup_code)
    Select
	A.invoice_id,
	S.invoice_id   ,
        S.payment_num  ,
        S.due_date     ,
        S.discount_amount_available,
        P.invoice_payment_id       ,
        nvl(P.discount_taken,0.00) ,
        K.check_date               ,
        A.INVOICE_AMOUNT	  ,
	A.Invoice_type_lookup_code
    FROM
	fv_terms_types T,
        ap_payment_schedules S,
        ap_invoice_payments P,
        ap_checks K,
        ap_invoices A
    WHERE
	    A.set_of_books_id           = v_set_of_books_id
    AND     A.payment_status_flag       = 'Y'
    AND     T.term_id                   = A.terms_id
    AND     T.terms_type                = 'PROMPT PAY'
    AND     S.invoice_id                = A.invoice_id
    AND     S.due_date is not null
    AND     S.due_date                  =
                        ( SELECT    max(U.due_date)
                          FROM    ap_payment_schedules U
                          WHERE   U.invoice_id  = S.invoice_id)
    AND     P.invoice_id                  =  S.invoice_id
    AND     P.payment_num                 =  S.payment_num
    AND     P.invoice_payment_id          =
                        ( SELECT  I.invoice_payment_id
                          FROM    ap_invoice_payments I,
                                  ap_checks C
                          WHERE   I.invoice_payment_id = P.invoice_payment_id
                          AND    C.check_id            = P.check_id
                          AND    C.check_date          =
                                ( SELECT  max(H.check_date)
                                  FROM    ap_checks H
                                  WHERE   H.check_id  = C.check_id ))
    AND     K.check_id                     =  P.check_id
    AND     K.check_date  between v_from_date and v_to_date
    AND     K.void_date is null ;
  Exception
	When NO_DATA_FOUND then
	     Null ;
  WHEN OTHERS THEN
    v_error_code := SQLCODE ;
    v_error_mesg  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', v_error_mesg) ;
    RAISE;
  End ;


-----------------------------------------------------------------
--			End Of the Package
-----------------------------------------------------------------
End fv_Prompt_pay ;


/
