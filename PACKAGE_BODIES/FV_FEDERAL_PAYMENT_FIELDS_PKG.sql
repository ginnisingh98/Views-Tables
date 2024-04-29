--------------------------------------------------------
--  DDL for Package Body FV_FEDERAL_PAYMENT_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FEDERAL_PAYMENT_FIELDS_PKG" AS
/* $Header: FVIBYPFB.pls 120.13 2006/11/07 21:31:27 dsadhukh noship $ */

-- Declaring a global variable for the package name
G_PKG_NAME CONSTANT VARCHAR2(30):='FV_FEDERAL_PAYMENT_FIELDS_PKG';


-- --------------------------------------------------------------------------
--                    Payment instruction level functions
-- --------------------------------------------------------------------------
--      The following functions take the payment instruction ID as an input
--      and return Federal specific attributes needed in the Federal payment
--      formats at the payment instruction (header) level.
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
--         Federal Employee Identification Number
-- --------------------------------------------------------------------------
--      This function will return the Federal Employee Identification
--      Number from fv_operating_units.
--
-- --------------------------------------------------------------------------
FUNCTION get_FEIN (p_payment_instruction_id IN number) return VARCHAR2 is

	    l_fed_employer_number 	fv_operating_units_all.fed_employer_id_number%TYPE;

        BEGIN
		if (NOT fv_install.enabled) then
		       return null;
		end if;

	    select fed_employer_id_number
	   	into l_fed_employer_number
	   	from fv_operating_units_all foua,
	             iby_pay_instructions_all ipia
	   	where ipia.payment_instruction_id = p_payment_instruction_id
	   	and   ipia.org_id = foua.org_id;

	        return l_fed_employer_number;
	   EXCEPTION
	        when others then
	             return null;
	   END get_FEIN;


-- --------------------------------------------------------------------------
--         Abbreviated Agency Code
-- --------------------------------------------------------------------------
--      This function will return the Abbreviated Agency Code from profile
--      FV_AGENCY_ID_ABBREVIATION
--
-- --------------------------------------------------------------------------

FUNCTION get_Abbreviated_Agency_Code (p_payment_instruction_id IN number)
            return VARCHAR2 IS

         v_abbr_agency_code VARCHAR2(30);
  BEGIN
   if (NOT fv_install.enabled) then
   return null;
   end if;

   v_abbr_agency_code := FND_PROFILE.VALUE('FV_AGENCY_ID_ABBREVIATION');

   return v_abbr_agency_code;

   EXCEPTION
   when others then
   return null;
  END get_abbreviated_agency_code;

-- --------------------------------------------------------------------------
--                    Payment level functions
-- --------------------------------------------------------------------------
--      The following functions take the payment ID as an input and return
--      Federal specific attributes needed in the Federal payment formats
--      at the payment level.
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
--                   Allotment Code
-- --------------------------------------------------------------------------
--      This function will return the allotment code.  This function will
--      return the allotment code for use in SPS PPD/PPD+ formats only.
--      This function will return a 'N' or null value.
-- --------------------------------------------------------------------------

  FUNCTION get_Allotment_Code (p_payment_id IN number) return VARCHAR2 is
        l_payment_reason_code 	iby_payments_all.payment_reason_code%TYPE;
  BEGIN

   if (NOT fv_install.enabled) then
   return null;
   end if;


   select payment_reason_code
   into l_payment_reason_code
   from iby_payments_all
   where payment_id = p_payment_id;

   if (l_payment_reason_code = 'US_FV_S') then
   return 'N';
   else
   return '';
   end if;

   EXCEPTION
   when others then
   return null;

  END get_allotment_code;

-- --------------------------------------------------------------------------
--      TOP Offset Eligibility Flag
-- --------------------------------------------------------------------------
--      This function will return the TOP Offset Eligibility flag.  A value
--      of 'Y' or 'N' will be returned.
-- --------------------------------------------------------------------------

FUNCTION TOP_Offset_Eligibility_Flag (p_payment_id IN number) return VARCHAR2
 IS


        l_payment_reason_code 	iby_payments_all.payment_reason_code%TYPE;
        l_payment_date 		iby_payments_all.payment_date%TYPE;
        l_org_id		iby_payments_all.org_id%TYPE;
        l_ledger_id             gl_ledgers.ledger_id%TYPE;
        l_ledger_name           gl_ledgers.name%TYPE;
        l_coa			gl_ledgers.chart_of_accounts_id%TYPE;
        l_delimiter   		VARCHAR2(1);
        l_vendor_id             ap_suppliers.vendor_id%TYPE;
        l_vendor_type           ap_suppliers.vendor_type_lookup_code%TYPE;
        l_vendor_site_id        ap_invoices_all.vendor_site_id%TYPE;
        l_offset_flag 		varchar2(1);
	l_acc_dist_tbl     	Fnd_Flex_Ext.segmentarray;
  	l_fv_low_tbl	     	Fnd_Flex_Ext.segmentarray;
  	l_fv_high_tbl	     	Fnd_Flex_Ext.segmentarray;
  	l_breakup_seg		NUMBER;
  	l_segment_nos		NUMBER;
  	l_get_segments_flag   	BOOLEAN;
  	l_ctr			NUMBER;


        CURSOR offset_exclusion_csr(p_sob_id_csr 	        NUMBER
  			     	   ,p_payment_reason_csr 	VARCHAR2
  			           ,p_vendor_type_csr		VARCHAR2
  			           ,p_vendor_id_csr		NUMBER
  			           ,p_vendor_site_id_csr	NUMBER
  			           ,p_payment_date_csr		DATE)
  	IS
  	SELECT '1'
  	FROM   FV_TOP_EXCLUSION_CRITERIA_ALL FVTOPEC
  	WHERE  FVTOPEC.set_of_books_id 	= p_sob_id_csr
  	AND   (FVTOPEC.payment_reason_code  	= NVL(p_payment_reason_csr,'-999')
  		OR FVTOPEC.vendor_type_code	= NVL(p_vendor_type_csr,'-999')
  		OR (FVTOPEC.vendor_id		= p_vendor_id_csr
  		   AND (FVTOPEC.vendor_site_id  	= p_vendor_site_id_csr
  			OR FVTOPEC.vendor_site_code   = 'ALL')))
  	AND (NVL(FVTOPEC.effective_start_date ,p_payment_date_csr) <= p_payment_date_csr
  	AND NVL(FVTOPEC.effective_end_date ,p_payment_date_csr) >= p_payment_date_csr);


        CURSOR invoice_dist_csr
        IS
        SELECT DISTINCT aid.dist_code_combination_id
        FROM  iby_payments_all ipa,
              iby_docs_payable_all idpa,
              ap_invoice_distributions aid
        WHERE ipa.payment_id = p_payment_id
        and   ipa.payment_id = idpa.payment_id
        and   idpa.calling_app_id = 200
        and   idpa.document_type = 'INVOICE'
        and   idpa.calling_app_doc_unique_ref2 = aid.invoice_id;


        CURSOR accounts_criteria_csr(p_payment_date_csr DATE
  			            ,p_sob_id_csr     NUMBER)
  	IS
  	SELECT concatenated_segments_low , concatenated_segments_high
  	FROM   fv_top_exclusion_criteria
  	WHERE  (concatenated_segments_low IS NOT NULL
  	AND    concatenated_segments_high IS NOT NULL )
  	AND    set_of_books_id = p_sob_id_csr
  	AND    NVL(effective_start_date ,p_payment_date_csr) <= p_payment_date_csr
  	AND    NVL(effective_end_date   ,p_payment_date_csr) >= p_payment_date_csr ;


        invoice_dist_rec 	invoice_dist_csr%ROWTYPE ;
        accounts_criteria_rec 	accounts_criteria_csr%ROWTYPE ;
	offset_exclusion_rec 	varchar2(1);


	BEGIN

            if (NOT fv_install.enabled) then
	       return null;
    	    end if;


        -- get the required data from payment_id

        select payment_reason_code, payment_date, org_id
        into l_payment_reason_code, l_payment_date, l_org_id
        from iby_payments_all
        where payment_id = p_payment_id;

        mo_utils.get_Ledger_Info
  		(p_operating_unit     	=>    l_org_id,
		 p_ledger_id 		=>    l_ledger_id,
	 	 p_ledger_name     	=>    l_ledger_name);



        select chart_of_accounts_id
        into l_coa
        from gl_ledgers
        where ledger_id = l_ledger_id;


        l_delimiter := fnd_flex_ext.get_delimiter('SQLGL'
  					         ,'GL#'
					         ,l_coa);


        select aia.vendor_id, aia.vendor_site_id, aps.vendor_type_lookup_code
        into l_vendor_id, l_vendor_site_id, l_vendor_type
        from iby_payments_all ipa,
             iby_docs_payable_all idpa,
             ap_invoices_all aia,
             ap_suppliers aps
        where ipa.payment_id = p_payment_id
        and   ipa.payment_id = idpa.payment_id
        and   idpa.calling_app_id = 200
        and   idpa.document_type = 'STANDARD'
        and   idpa.calling_app_doc_unique_ref2 = aia.invoice_id
        and   aia.vendor_id = aps.vendor_id
        and   rownum < 2;

   -- initialize l_offset_flag
   l_offset_flag := 'Y';

   OPEN 	offset_exclusion_csr(l_ledger_id
  				    ,l_payment_reason_code
  				    ,l_vendor_type
  				    ,l_vendor_id
  				    ,l_vendor_site_id
  				    ,l_payment_date) ;

   FETCH offset_exclusion_csr INTO offset_exclusion_rec;

   IF offset_exclusion_csr%FOUND THEN
      l_offset_flag := 'N' ;
      RETURN l_offset_flag;
   END IF ;

   CLOSE offset_exclusion_csr ;

   -- check excluded accounts in fv_top_exclusion_criteria table

  OPEN invoice_dist_csr;
  LOOP
    FETCH invoice_dist_csr  INTO  invoice_dist_rec ;
    EXIT WHEN invoice_dist_csr%NOTFOUND ;



     /*Determining the segment values and storing in a pl/sql table
       l_acc_dist_tbl*/
    l_get_segments_flag := fnd_flex_ext.get_segments
    		    (application_short_name =>'SQLGL'
			   	,key_flex_code    => 'GL#'
			   	,structure_number => l_coa
			   	,combination_id   =>
			   	invoice_dist_rec.dist_code_combination_id
				,n_segments       => l_segment_nos
				,segments         => l_acc_dist_tbl) ;

    OPEN accounts_criteria_csr(l_payment_date, l_ledger_id) ;
    LOOP
      FETCH accounts_criteria_csr INTO accounts_criteria_rec ;
      EXIT WHEN accounts_criteria_csr%NOTFOUND ;
      /*Determining the segment values and storing in a pl/sql table
       l_fv_low_tbl , l_fv_high_tbl based on the value in
       CONCATENATED_SEGMENTS_LOW , CONCATENATED_SEGMENTS_HIGH    */

      l_breakup_seg := fnd_flex_ext.breakup_segments
      	            (accounts_criteria_rec.CONCATENATED_SEGMENTS_LOW
					         ,l_delimiter
					         ,l_fv_low_tbl ) ;
      l_breakup_seg := fnd_flex_ext.breakup_segments
                    (accounts_criteria_rec.CONCATENATED_SEGMENTS_HIGH
						   ,l_delimiter
						   ,l_fv_high_tbl ) ;
      l_ctr := 0 ;
      IF (l_fv_low_tbl.COUNT <> 0 OR l_fv_high_tbl.COUNT <> 0 ) THEN

	  FOR  i IN 1..l_acc_dist_tbl.COUNT
	  LOOP
	     IF
	        (l_acc_dist_tbl(i) >= NVL(l_fv_low_tbl(i) , l_acc_dist_tbl(i))
	        AND
	        l_acc_dist_tbl(i) <= NVL(l_fv_high_tbl(i) , l_acc_dist_tbl(i)) )
	        THEN
                l_ctr := l_ctr + 1 ;
             ELSE
                  EXIT;
	     END IF;
          END LOOP;

          IF l_ctr = l_acc_dist_tbl.COUNT THEN
	      l_offset_flag := 'N' ;
              RETURN l_offset_flag;
          END IF ;

      END IF ;
    END LOOP ;
    /*  Check if no row exists for Accounting Criteria
    Then close all cusrsor and Exit*/

    IF accounts_criteria_csr%ROWCOUNT = 0 THEN
      CLOSE accounts_criteria_csr ;
      EXIT ;
    END IF ;
    CLOSE accounts_criteria_csr ;

  END LOOP ;
  CLOSE invoice_dist_csr ;

    RETURN l_offset_flag;

    EXCEPTION
          when others then
             return null;
END TOP_Offset_Eligibility_Flag;

-- --------------------------------------------------------------------------
--    Payment Instruction Sequence Number
-- --------------------------------------------------------------------------
--    This function would accept org_id and payment_reason_code as input
--    parameters and output the sequence number for a payment Instruction.
-- --------------------------------------------------------------------------

	FUNCTION GET_PAY_INSTR_SEQ_NUM (	p_org_id		in	number,
	 				p_payment_reason_code	in	varchar2)
	RETURN VARCHAR2
	IS
	  l_nextseq  		Fv_Pb_Seq_Assignments_All.next_seq_value%TYPE;
	  l_finalseq 		Fv_Pb_Seq_Assignments_All.next_seq_value%TYPE;
	  l_prefix   		Fv_Pb_Seq_Assignments_All.prefix%TYPE;
	  l_suffix   		Fv_Pb_Seq_Assignments_All.suffix%TYPE;
	  l_seq_assignment_id 	Fv_Pb_Seq_Assignments_All.seq_assignment_id%TYPE;
	  l_instruction_name 	iby_pay_instructions_all.pay_admin_assigned_ref_code%TYPE;
	  l_count    		NUMBER;
	  l_pi_count 		NUMBER;
	  l_module		varchar2(200)	:= G_PKG_NAME || '.GET_PAY_INSTR_SEQ_NUM';
          l_message  	        VARCHAR2(1000);

          CURSOR assign_nextseq_cur(p_org_id_csr number) IS
          SELECT seq_assignment_id, initial_seq_value, org_id
	  FROM Fv_Pb_Seq_Assignments_all FPSA
	  WHERE FPSA.org_id = p_org_id_csr
          AND FPSA.next_seq_value IS NULL;
	BEGIN

          -- if Federal is not enabled return null
	   if (NOT fv_install.enabled) then
                l_message := 'FV: Federal Enabled profile is not turned on';
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module, l_message);
	        return null;
	   end if;

	   -- if Sequential Numbering is not turned on then return null
	   if (fnd_profile.value ('FV_PB_SEQ_NUMBERING') <> 'Y') then
                l_message := 'FV: Enable Automatic Numbering profile is not turned on';
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module, l_message);
	        return null;
	   end if;

	  -- Set the next sequence number for all the assignments in the table
	  -- where next_seq_value IS NULL

	  FOR c_assign IN assign_nextseq_cur(p_org_id)
          LOOP
              UPDATE Fv_Pb_Seq_Assignments_all
	      SET next_seq_value = c_assign.initial_seq_value
	      WHERE org_id=c_assign.org_id
              AND seq_assignment_id = c_assign.seq_assignment_id;

	  END LOOP;


          BEGIN
	  	-- Get the sequence information
	  	SELECT next_seq_value, final_seq_value, prefix, suffix, seq_assignment_id
	  	INTO l_nextseq, l_finalseq, l_prefix, l_suffix, l_seq_assignment_id
	  	FROM Fv_Pb_Seq_Assignments_all
	  	WHERE payment_reason_code = p_payment_reason_code
	  	AND     org_id = p_org_id
	  	AND TRUNC(SYSDATE) BETWEEN TRUNC(start_date) AND NVL(TRUNC(end_date),TRUNC(SYSDATE));
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_message := 'Payment Instruction Sequence Assignment not set for org_id = ' || p_org_id || ' and payment_reason_code ' || p_payment_reason_code;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module, l_message);
	        return null;
          END;


	  -- Check if the next seq number exceeds the final number, as long as the
	  -- final number is not null. If it is null, then continue with the code.
	  if ((l_finalseq IS NOT NULL) AND (l_nextseq > l_finalseq)) THEN
	       return null;
	  end if;
	  -- Assign the payment batch name
	  l_instruction_name := l_prefix || l_nextseq || l_suffix;
	  -- Check for Uniqueness
	  LOOP
	  SELECT COUNT(*)
	  INTO l_pi_count
	  FROM iby_pay_instructions_all
	  WHERE org_id = p_org_id
	  AND pay_admin_assigned_ref_code = l_instruction_name;

           IF (l_pi_count = 0) THEN
	     EXIT;
           ELSE
	     l_nextseq := l_nextseq + 1;
             -- Check if the next seq number exceeds the final number
             IF ((l_finalseq IS NOT NULL) AND (l_nextseq > l_finalseq)) THEN
                l_message := 'Maximum sequence number reached - returning NULL ...';
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module, l_message);
	        return null;
	     END IF;
            -- Assign the payment instruction name
	    l_instruction_name := l_prefix || l_nextseq || l_suffix;
	   END IF;
          END LOOP;

          -- update table with next sequence to be used
          l_nextseq := l_nextseq + 1;
          update fv_pb_seq_assignments_all
          set next_seq_value = l_nextseq
          where seq_assignment_id = l_seq_assignment_id;
          return l_instruction_name;
      	EXCEPTION
	   WHEN OTHERS THEN
              l_message := SQLERRM;
              log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module, l_message);
	      return null;
	END GET_PAY_INSTR_SEQ_NUM;

-- --------------------------------------------------------------------------


-- --------------------------------------------------------------------------
--      Summary_Format_Prog_completed
-- --------------------------------------------------------------------------
--    This API will be called from IBY when the summary formats have completed
--    and will tell us the status of the payment instruction.  If the
--    payment instruction has completed successfully then the column
--    summary_schedule_flage in table fv_summary_consolidate_all will be
--    updated.
-- -------------------------------------------------------------------------
PROCEDURE Summary_Format_Prog_Completed
(p_api_version IN number,
 p_init_msg_list IN varchar2,
 p_commit IN varchar2,
 x_return_status OUT NOCOPY  varchar2,
 x_msg_count OUT  NOCOPY number,
 x_msg_data OUT  NOCOPY varchar2,
 p_payment_instruction_id IN number,
 p_format_complete_status IN varchar2)
IS
BEGIN

 x_return_status :='S';
 x_msg_data := null;
 x_msg_count := 0;

IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
	         		Fnd_Msg_Pub.Initialize;
END IF;

x_return_status :=Fnd_Api.G_Ret_Sts_Success;
x_msg_data := null;
x_msg_count := 0;

IF (fv_install.enabled) AND (p_format_complete_status = 'SUMMARY_FORMAT_SUCCESS')  THEN

			Update fv_summary_consolidate_all
			Set summary_schedule_flag = 'Y'
			Where payment_instruction_id = p_payment_instruction_id;
END IF;

IF Fnd_Api.To_Boolean(p_commit) THEN
	         		COMMIT;
END IF;

EXCEPTION
  WHEN others THEN
	       		 x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
	        		Fnd_Msg_Pub.Add_Exc_Msg(
	            				p_pkg_name       => 'FV_FEDERAL_PAYMENT_FIELDS_PKG',
	           	 			p_procedure_name => 'SUMMARY_FORMAT_PROG_COMPLETED');
	         		Fnd_Msg_Pub.Count_And_Get(
	            				p_encoded => Fnd_Api.G_False,
	            				p_count   => x_msg_count,
	            				p_data    => x_msg_data);


END;

-- ------------------------------------------------------------------------------
--        Submit Payment Instruction Treasury Symbol Listing Report
-- ------------------------------------------------------------------------------
--    This procedure will accept the payment_instruction_id and will submit the
--    Payment Instruction Treasury Symbol Listing Report as a concurrent program.
-- ------------------------------------------------------------------------------

PROCEDURE submit_pay_instr_ts_report ( p_init_msg_list          IN         varchar2,
                                       p_payment_instruction_id IN         number,
				       x_request_id             OUT NOCOPY number,
				       x_return_status          OUT NOCOPY varchar2,
                                       x_msg_count              OUT NOCOPY number,
				       x_msg_data		OUT NOCOPY varchar2)
IS
l_api_name CONSTANT varchar2(30) := 'submit_pay_instr_ts_report';
l_org_id NUMBER;
BEGIN
    IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_msg_data      := NULL;
    l_org_id        := MO_GLOBAL.get_current_org_id;

    IF (fv_install.enabled) THEN
        fnd_request.set_org_id(l_org_id);
        x_request_id := FND_REQUEST.submit_request('FV','FVIBYTSL',NULL,NULL,FALSE,p_payment_instruction_id);

        IF (x_request_id = 0) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('FV', 'FV_TSL_REQUEST_FAILED');
            FND_MSG_PUB.add;
        ELSE
            FND_MESSAGE.set_name('FV', 'FV_TSL_REQUEST_SUBMITTED');
            FND_MESSAGE.set_token('REQUEST_ID',x_request_id);
            FND_MSG_PUB.add;
        END IF;

    END IF;

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data );
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg( G_PKG_NAME,
                                 l_api_name );
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                   p_data  => x_msg_data );
END submit_pay_instr_ts_report;

---------------------------------------------------------------------------
--	 submit_cash_pos_report
---------------------------------------------------------------------------
-- This Procedure takes the org_id and checkrun_id as input parameters and
-- submits the cash position detail report.
---------------------------------------------------------------------------

 PROCEDURE submit_cash_pos_report(
			p_init_msg_list		in		varchar2,
            p_org_id		in		number,
           	p_checkrun_id		in		number,
           	x_request_id		out	nocopy	number,
            x_return_status		out	nocopy  varchar2,
			x_msg_count		out	nocopy  number,
			x_msg_data		out	nocopy  varchar2) is

l_api_name CONSTANT varchar2(30) := 'submit_cash_pos_report';

	begin
		IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
			FND_MSG_PUB.initialize;
		END IF;

	        	x_return_status := FND_API.G_RET_STS_SUCCESS;
	        	x_msg_count := 0;
		x_msg_data := null;
		if ((fv_install.enabled) AND (FND_PROFILE.VALUE('FV_ENABLE_CASH_POSITION_DETAIL_OPTION') = 'Y')) then

	x_request_id := FND_REQUEST.SUBMIT_REQUEST('FV', 'FVAPCPDP', NULL, NULL, FALSE,p_checkrun_id,p_org_id);

                		if (x_request_id = 0) then
	                  		x_return_status := FND_API.G_RET_STS_ERROR ;
	            		end if;
		end if;
	        FND_MSG_PUB.Count_And_Get
		(
			p_count         	=>      x_msg_count,
	        		p_data          	=>      x_msg_data
	 	);
	exception
		when others then
		       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		       FND_MSG_PUB.Add_Exc_Msg
		    	    (	G_PKG_NAME,
		    	    	l_api_name
			    );

		       FND_MSG_PUB.Count_And_Get
		    	    (  	p_count         	=>      x_msg_count,
		        		p_data          	=>      x_msg_data
		    	    );
	end submit_cash_pos_report;

----------------------------------------------------------------------------------------------------------
       PROCEDURE LOG_ERROR_MESSAGES
        (
            p_level   IN NUMBER,
            p_module  IN VARCHAR2,
            p_message IN VARCHAR2
        ) IS

        BEGIN

             IF (p_level >= fnd_log.g_current_runtime_level) THEN
                      fnd_log.string (p_level, p_module, p_message);
             END IF;

             -- log messages only if concurrent program
             IF (FND_GLOBAL.conc_request_id <> -1) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_message);
             END IF;

        END LOG_ERROR_MESSAGES;

END fv_federal_payment_fields_pkg;

/
