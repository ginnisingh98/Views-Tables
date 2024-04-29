--------------------------------------------------------
--  DDL for Package Body FV_BE_RPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_RPR_PKG" AS
--$Header: FVBERPRB.pls 120.19.12010000.2 2009/11/04 03:22:16 yanasing ship $
  g_module_name VARCHAR2(100);


g_errbuf  	VARCHAR2(1000);
g_retcode 	NUMBER := 0;
g_user_id       NUMBER(15);
g_resp_id       NUMBER(15);
g_login_id      NUMBER(15);
g_sysdate       DATE;
g_sob_id        NUMBER(15);

PROCEDURE main ( errbuf        OUT NOCOPY VARCHAR2,
            	 retcode       OUT NOCOPY VARCHAR2,
	    	 p_sob_id          NUMBER,
		 p_approval_id     NUMBER,
	    	 p_submitter_id    NUMBER,
	   	 p_approver_id     NUMBER,
	    	 p_note    	   VARCHAR2
            )
IS

l_module_name VARCHAR2(200);
e_error   EXCEPTION;

l_rpr_rec 	fv_be_rpr_transactions%ROWTYPE;
l_trx_hdr_rec	fv_be_trx_hdrs%ROWTYPE;
l_trx_dtl_rec	fv_be_trx_dtls%ROWTYPE;
l_from_doc_number Fv_Be_Trx_Hdrs.doc_number%TYPE;
l_to_doc_number Fv_Be_Trx_Hdrs.doc_number%TYPE;
l_workflow_flag  fv_budget_options.workflow_flag%TYPE;

l_from_doc_id   NUMBER(15);
l_to_doc_id     NUMBER(15);
l_amount        CHAR(19);
l_gl_date       CHAR(11);
l_packet_id       NUMBER(15);
l_error_flag    VARCHAR2(1) ;
l_log_message   VARCHAR2(2000);

-- R12 changes

l_doc_type      CONSTANT VARCHAR2(30) := 'BE_RPR_TRANSACTIONS';
l_event_type    VARCHAR2(30);
l_return_status VARCHAR2(10);
l_status_code   VARCHAR2(100);

-- R12 changes

CURSOR rpr_transactions_c IS
	SELECT * FROM fv_be_rpr_transactions
	WHERE set_of_books_id = p_sob_id
	AND   approval_id = p_approval_id
	AND   transaction_status  = 'IP'
	ORDER BY budget_level_id;

BEGIN
    l_module_name	:= g_module_name || 'main';
    l_error_flag	:= 'N';

    IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
      Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
						'START OF PROCESS');
    END IF;
    retcode := 0;
    g_user_id := fnd_global.user_id;
    g_resp_id := fnd_global.resp_id;
    g_login_id := fnd_global.login_id;
    g_sysdate := SYSDATE;
    g_sob_id := p_sob_id;

    SELECT workflow_flag
    INTO   l_workflow_flag
    FROM   fv_budget_options
    WHERE  set_of_books_id = p_sob_id;

    l_log_message := ' Reprogramming Documents Creation and Approval Output Report';
    fnd_file.put_line(FND_FILE.OUTPUT,l_log_message);
    l_log_message := '     ';
    fnd_file.put_line(FND_FILE.OUTPUT,l_log_message);
    l_log_message := '   From Document        To Document          GL Date                  Amount  Status ';
    fnd_file.put_line(FND_FILE.OUTPUT,l_log_message);
    l_log_message := '   -------------        -----------          --------                 ------  -------';
    fnd_file.put_line(FND_FILE.OUTPUT,l_log_message);

    BEGIN

    FOR l_rpr_rec IN rpr_transactions_c
    LOOP

	FOR i IN 1..2
	LOOP

    	  IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
          Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
							'INSIDE CURSOR LOOP');
    	  END IF;

    	  IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
          Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
						'SETTING HEADER VARIABLES ');
    	  END IF;

	  set_hdr_fields(i, l_trx_hdr_rec, l_rpr_rec);

          IF (g_retcode = 2) THEN
	    RAISE e_error;
	  END IF;

	  IF (i=1) THEN
		l_from_doc_id := l_trx_hdr_rec.doc_id;
		l_from_doc_number := l_trx_hdr_rec.doc_number;
	  ELSE
		l_to_doc_id := l_trx_hdr_rec.doc_id;
		l_to_doc_number := l_trx_hdr_rec.doc_number;
	  END IF;

          IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
            Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
					'BEFORE INSERTING RECORD DOC NUMBER '||
					            l_trx_hdr_rec.doc_number);
          END IF;

	  insert_hdr_record(l_trx_hdr_rec);

          IF (g_retcode = 2) THEN
	    RAISE e_error;
	  END IF;

    	  IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
          Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
						'SETTING DETAIL VARIABLES ');
    	  END IF;

	  set_dtl_fields(i, l_trx_dtl_rec, l_rpr_rec);

          IF (g_retcode = 2) THEN
	    RAISE e_error;
	  END IF;

	  l_trx_dtl_rec.doc_id 	:= l_trx_hdr_rec.doc_id;

          IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
            Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
					'BEFORE INSERTING DETAIL RECORD');
          END IF;

	  insert_dtl_record(l_trx_dtl_rec);

          IF (g_retcode = 2) THEN
	    RAISE e_error;
	  END IF;

	END LOOP;  --for i in 1..2

	--Check if a lock is needed when record is fetched???????

	UPDATE fv_be_rpr_transactions
	SET    transaction_status = 'PR'
	WHERE  transaction_id = l_rpr_rec.transaction_id;

	COMMIT;

	UPDATE fv_be_trx_hdrs
	SET doc_status = 'IP'
	WHERE doc_id IN (l_from_doc_id, l_to_doc_id);

	UPDATE fv_be_trx_dtls
	SET transaction_status = 'IP'
	WHERE doc_id IN (l_from_doc_id, l_to_doc_id);

	COMMIT;
        -- R12 changes

        If l_rpr_rec.budget_level_id = 1 Then
           l_event_type := 'RPR_BA_RESERVE';
        Else
           l_event_type := 'RPR_FD_RESERVE';
        End If;

        -- R12 changes
	IF ((l_workflow_flag = 'Y') AND (g_user_id <> l_rpr_rec.approved_by_user_id)) THEN
			--p_approver_id)) then

           IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
             Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
							'CALLING WORKFLOW');
           END IF;
	   --Call workflow procedure
           fv_wf_be_approval.Main(errbuf, retcode,p_sob_id,
                                p_submitter_id,l_rpr_rec.approved_by_user_id,
                                l_from_doc_id,
                                p_note, l_to_doc_id,g_user_id,g_resp_id);

	    IF retcode <> 0 THEN
		l_log_message := 'Error submitting workflow '||errbuf;
		Fv_Utility.Log_Mesg(Fnd_Log.Level_Error, l_module_name,
								L_LOG_MESSAGE);
		reset_doc_status(l_from_doc_id, l_to_doc_id);
		l_error_flag := 'Y';
	    ELSE
		l_log_message := 'Document submitted to workflow ';
		IF ( Fnd_Log.Level_Statement>=
					 Fnd_Log.G_Current_Runtime_Level) THEN
	    	    Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement,
						 l_module_name,L_LOG_MESSAGE);
		END IF;
	    END IF;

	ELSE

           IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
             Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
						'CALLING FUNDS RESERVATION');
           END IF;

           -- R12 changes
	   fv_be_fund_pkg.main (
                 errbuf,
                 retcode,
                 'R',
                 p_sob_id,
	    	 l_from_doc_id,
                 l_to_doc_id,
		 g_user_id,
                 l_doc_type,
                 l_event_type,
                 l_rpr_rec.gl_date,
                 l_return_status,
                 l_status_code,
                 g_user_id,
                 g_resp_id);

           -- R12 changes
	    IF retcode = 2  THEN
	        l_log_message := 'Error in Fund Reservation process '||errbuf;
	        IF ( Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)THEN
            		Fv_Utility.Debug_Mesg(Fnd_Log.Level_Error, l_module_name,
								L_LOG_MESSAGE);
	        END IF;
		reset_doc_status(l_from_doc_id, l_to_doc_id);
		l_error_flag := 'Y';
	    ELSIF retcode = 1 THEN
	       l_log_message := 'Unable to Reserve Funds, no documents created';
            Fv_Utility.Log_Mesg(Fnd_Log.Level_Error, l_module_name,
								L_LOG_MESSAGE);
	    ELSE
		l_log_message := 'Fund Reservation Successful ';
	        IF ( Fnd_Log.Level_Statement>=
					Fnd_Log.G_Current_Runtime_Level) THEN
            Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
							L_LOG_MESSAGE);
	        END IF;
	    END IF;

	END IF; --workflow flag

	IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
    		Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
							'BEFORE AMOUNT');
	END IF;
	l_amount := TO_CHAR(l_trx_dtl_rec.amount,'999,999,999,999.99');
	IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
   		Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
								'AFTER AMOUNT');
	END IF;
	l_gl_date := TO_CHAR(l_trx_dtl_rec.gl_date,'DD-MON-YYYY');

	l_log_message := '   '||l_from_doc_number||' '||l_to_doc_number
		|| ' '|| l_gl_date || ' ' || l_amount ||'  ' ||l_log_message;

	fnd_file.put_line(FND_FILE.OUTPUT,l_log_message);

    END LOOP;  --l_rpr_rec cursor


    IF (l_error_flag = 'Y') THEN
	retcode := 2;
    END IF;
    IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
      Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
							'PROCESS END');
    END IF;

    EXCEPTION WHEN e_error THEN

      IF ( Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) THEN
        Fv_Utility.Debug_Mesg(Fnd_Log.Level_Statement, l_module_name,
					'EXCEPTION ENCOUNTERED IN MAIN ');
      END IF;

      -- Rolling back the row created in fv_be_trx_hdrs.
      ROLLBACK ;

      --Reset transaction status to Incomplete if error encountered
      UPDATE fv_be_rpr_transactions
	 SET transaction_status = 'IN'
       WHERE set_of_books_id = p_sob_id
         AND approval_id = p_approval_id
         AND transaction_status  = 'IP';

      retcode := g_retcode;
      errbuf := g_errbuf;
      RETURN;

    END;

    EXCEPTION WHEN OTHERS THEN
      retcode := 2;
      errbuf := 'Error in main procedure '|| SQLERRM;
      Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',errbuf);
      RETURN;

END ; --procedure main


PROCEDURE set_hdr_fields (p_count NUMBER,
			  p_trx_hdr_rec  OUT NOCOPY fv_be_trx_hdrs%ROWTYPE,
			  p_rpr_rec fv_be_rpr_transactions%ROWTYPE)
IS
l_module_name VARCHAR2(200);

BEGIN
	l_module_name  := g_module_name || 'set_hdr_fields';
	SELECT fv_be_trx_hdrs_s.NEXTVAL
	INTO   p_trx_hdr_rec.doc_id
	FROM dual;

	IF (p_count=1) THEN
	   p_trx_hdr_rec.doc_number 		:= p_rpr_rec.doc_number||'-RPF';
	   p_trx_hdr_rec.fund_value		:= p_rpr_rec.fund_value_from;
	   p_trx_hdr_rec.doc_total		:= p_rpr_rec.amount * -1;

	ELSE
	   p_trx_hdr_rec.doc_number 		:= p_rpr_rec.doc_number||'-RPT';
	   p_trx_hdr_rec.fund_value		:= p_rpr_rec.fund_value_to;
	   p_trx_hdr_rec.doc_total              := p_rpr_rec.amount;
	END IF;
	p_trx_hdr_rec.revision_num 		:= 0;
	p_trx_hdr_rec.internal_revision_num 	:= 0;

	SELECT treasury_symbol_id
	INTO   p_trx_hdr_rec.treasury_symbol_id
	FROM   fv_fund_parameters
	WHERE  fund_value =
         DECODE(p_count,1,p_rpr_rec.fund_value_from,2,p_rpr_rec.fund_value_to)
	AND    set_of_books_id = g_sob_id;

	p_trx_hdr_rec.budget_level_id		:= p_rpr_rec.budget_level_id;
	p_trx_hdr_rec.transaction_date		:= g_sysdate;
	p_trx_hdr_rec.doc_status 		:= 'IN';
	p_trx_hdr_rec.source			:= 'RPR';
	IF p_rpr_rec.budget_level_id = 1 THEN
	  IF (p_count=1) THEN
	   p_trx_hdr_rec.budgeting_segments := p_rpr_rec.distribution_from;
	   p_trx_hdr_rec.segment1		:= p_rpr_rec.segment1_from;
	   p_trx_hdr_rec.segment2		:= p_rpr_rec.segment2_from;
	   p_trx_hdr_rec.segment3		:= p_rpr_rec.segment3_from;
	   p_trx_hdr_rec.segment4		:= p_rpr_rec.segment4_from;
	   p_trx_hdr_rec.segment5		:= p_rpr_rec.segment5_from;
	   p_trx_hdr_rec.segment6		:= p_rpr_rec.segment6_from;
	   p_trx_hdr_rec.segment7		:= p_rpr_rec.segment7_from;
	   p_trx_hdr_rec.segment8		:= p_rpr_rec.segment8_from;
	   p_trx_hdr_rec.segment9		:= p_rpr_rec.segment9_from;
	   p_trx_hdr_rec.segment10		:= p_rpr_rec.segment10_from;
	   p_trx_hdr_rec.segment11		:= p_rpr_rec.segment11_from;
	   p_trx_hdr_rec.segment12		:= p_rpr_rec.segment12_from;
	   p_trx_hdr_rec.segment13		:= p_rpr_rec.segment13_from;
	   p_trx_hdr_rec.segment14		:= p_rpr_rec.segment14_from;
	   p_trx_hdr_rec.segment15		:= p_rpr_rec.segment15_from;
	   p_trx_hdr_rec.segment16		:= p_rpr_rec.segment16_from;
	   p_trx_hdr_rec.segment17		:= p_rpr_rec.segment17_from;
	   p_trx_hdr_rec.segment18		:= p_rpr_rec.segment18_from;
	   p_trx_hdr_rec.segment19		:= p_rpr_rec.segment19_from;
	   p_trx_hdr_rec.segment20		:= p_rpr_rec.segment20_from;
	   p_trx_hdr_rec.segment21		:= p_rpr_rec.segment21_from;
	   p_trx_hdr_rec.segment22		:= p_rpr_rec.segment22_from;
	   p_trx_hdr_rec.segment23		:= p_rpr_rec.segment23_from;
	   p_trx_hdr_rec.segment24		:= p_rpr_rec.segment24_from;
	   p_trx_hdr_rec.segment25		:= p_rpr_rec.segment25_from;
	   p_trx_hdr_rec.segment26		:= p_rpr_rec.segment26_from;
	   p_trx_hdr_rec.segment27		:= p_rpr_rec.segment27_from;
	   p_trx_hdr_rec.segment28		:= p_rpr_rec.segment28_from;
	   p_trx_hdr_rec.segment29		:= p_rpr_rec.segment29_from;
	   p_trx_hdr_rec.segment30		:= p_rpr_rec.segment30_from;
	  ELSE
	   p_trx_hdr_rec.budgeting_segments := p_rpr_rec.distribution_to;
	   p_trx_hdr_rec.segment1		:= p_rpr_rec.segment1;
	   p_trx_hdr_rec.segment2		:= p_rpr_rec.segment2;
	   p_trx_hdr_rec.segment3		:= p_rpr_rec.segment3;
	   p_trx_hdr_rec.segment4		:= p_rpr_rec.segment4;
	   p_trx_hdr_rec.segment5		:= p_rpr_rec.segment5;
	   p_trx_hdr_rec.segment6		:= p_rpr_rec.segment6;
	   p_trx_hdr_rec.segment7		:= p_rpr_rec.segment7;
	   p_trx_hdr_rec.segment8		:= p_rpr_rec.segment8;
	   p_trx_hdr_rec.segment9		:= p_rpr_rec.segment9;
	   p_trx_hdr_rec.segment10		:= p_rpr_rec.segment10;
	   p_trx_hdr_rec.segment11		:= p_rpr_rec.segment11;
	   p_trx_hdr_rec.segment12		:= p_rpr_rec.segment12;
	   p_trx_hdr_rec.segment13		:= p_rpr_rec.segment13;
	   p_trx_hdr_rec.segment14		:= p_rpr_rec.segment14;
	   p_trx_hdr_rec.segment15		:= p_rpr_rec.segment15;
	   p_trx_hdr_rec.segment16		:= p_rpr_rec.segment16;
	   p_trx_hdr_rec.segment17		:= p_rpr_rec.segment17;
	   p_trx_hdr_rec.segment18		:= p_rpr_rec.segment18;
	   p_trx_hdr_rec.segment19		:= p_rpr_rec.segment19;
	   p_trx_hdr_rec.segment20		:= p_rpr_rec.segment20;
	   p_trx_hdr_rec.segment21		:= p_rpr_rec.segment21;
	   p_trx_hdr_rec.segment22		:= p_rpr_rec.segment22;
	   p_trx_hdr_rec.segment23		:= p_rpr_rec.segment23;
	   p_trx_hdr_rec.segment24		:= p_rpr_rec.segment24;
	   p_trx_hdr_rec.segment25		:= p_rpr_rec.segment25;
	   p_trx_hdr_rec.segment26		:= p_rpr_rec.segment26;
	   p_trx_hdr_rec.segment27		:= p_rpr_rec.segment27;
	   p_trx_hdr_rec.segment28		:= p_rpr_rec.segment28;
	   p_trx_hdr_rec.segment29		:= p_rpr_rec.segment29;
	   p_trx_hdr_rec.segment30		:= p_rpr_rec.segment30;

	  END IF;

	ELSE

	  /*
	  Commented for bug 9067331 and added below query
	  p_trx_hdr_rec.budgeting_segments	:= NULL;
	   p_trx_hdr_rec.segment1		:= NULL;
	   p_trx_hdr_rec.segment2		:= NULL;
	   p_trx_hdr_rec.segment3		:= NULL;
	   p_trx_hdr_rec.segment4		:= NULL;
	   p_trx_hdr_rec.segment5		:= NULL;
	   p_trx_hdr_rec.segment6		:= NULL;
	   p_trx_hdr_rec.segment7		:= NULL;
	   p_trx_hdr_rec.segment8		:= NULL;
	   p_trx_hdr_rec.segment9		:= NULL;
	   p_trx_hdr_rec.segment10		:= NULL;
	   p_trx_hdr_rec.segment11		:= NULL;
	   p_trx_hdr_rec.segment12		:= NULL;
	   p_trx_hdr_rec.segment13		:= NULL;
	   p_trx_hdr_rec.segment14		:= NULL;
	   p_trx_hdr_rec.segment15		:= NULL;
	   p_trx_hdr_rec.segment16		:= NULL;
	   p_trx_hdr_rec.segment17		:= NULL;
	   p_trx_hdr_rec.segment18		:= NULL;
	   p_trx_hdr_rec.segment19		:= NULL;
	   p_trx_hdr_rec.segment20		:= NULL;
	   p_trx_hdr_rec.segment21		:= NULL;
	   p_trx_hdr_rec.segment22		:= NULL;
	   p_trx_hdr_rec.segment23		:= NULL;
	   p_trx_hdr_rec.segment24		:= NULL;
	   p_trx_hdr_rec.segment25		:= NULL;
	   p_trx_hdr_rec.segment26		:= NULL;
	   p_trx_hdr_rec.segment27		:= NULL;
	   p_trx_hdr_rec.segment28		:= NULL;
	   p_trx_hdr_rec.segment29		:= NULL;
	   p_trx_hdr_rec.segment30		:= NULL;*/

	  select  h.budgeting_segments,
                  h.segment1,h.segment2,h.segment3,h.segment4,h.segment5,h.segment6,
                  h.segment7,h.segment8,h.segment9,h.segment10,
                  h.segment11,h.segment12,h.segment13,h.segment14,h.segment15,h.segment16,
                  h.segment17,h.segment18,h.segment19,h.segment20,h.segment21,h.segment22,h.segment23,
                  h.segment24, h.segment25,h.segment26,h.segment27,
                  h.segment28,h.segment29,h.segment30
                  into
             p_trx_hdr_rec.budgeting_segments,
	   p_trx_hdr_rec.segment1,
	   p_trx_hdr_rec.segment2,
	   p_trx_hdr_rec.segment3,
	   p_trx_hdr_rec.segment4,
	   p_trx_hdr_rec.segment5,
	   p_trx_hdr_rec.segment6,
	   p_trx_hdr_rec.segment7,
	   p_trx_hdr_rec.segment8,
	   p_trx_hdr_rec.segment9,
	    p_trx_hdr_rec.segment10,
	    p_trx_hdr_rec.segment11,
	    p_trx_hdr_rec.segment12,
	    p_trx_hdr_rec.segment13,
	    p_trx_hdr_rec.segment14,
	    p_trx_hdr_rec.segment15,
	    p_trx_hdr_rec.segment16,
	    p_trx_hdr_rec.segment17,
	    p_trx_hdr_rec.segment18,
	    p_trx_hdr_rec.segment19,
	    p_trx_hdr_rec.segment20,
	    p_trx_hdr_rec.segment21,
	    p_trx_hdr_rec.segment22,
	    p_trx_hdr_rec.segment23,
	    p_trx_hdr_rec.segment24,
	    p_trx_hdr_rec.segment25,
	    p_trx_hdr_rec.segment26,
	    p_trx_hdr_rec.segment27,
	    p_trx_hdr_rec.segment28,
	    p_trx_hdr_rec.segment29,
	    p_trx_hdr_rec.segment30
            from fv_be_trx_dtls d , fv_be_trx_hdrs h
	    where d.budgeting_segments =  p_rpr_rec.distribution_from
	    and h.doc_id = d.doc_id
            and h.budget_level_id =  p_rpr_rec.budget_level_id
	    and rownum = 1;

	END IF;

	p_trx_hdr_rec.approval_id		:= NULL;
	p_trx_hdr_rec.distribution_amount	:= NULL;
        p_trx_hdr_rec.old_doc_number		:= NULL;
	p_trx_hdr_rec.set_of_books_id		:= g_sob_id;
	p_trx_hdr_rec.creation_date		:= g_sysdate;
	p_trx_hdr_rec.created_by  		:= g_user_id;
	p_trx_hdr_rec.last_update_date		:= g_sysdate;
	p_trx_hdr_rec.last_updated_by		:= g_user_id;
	p_trx_hdr_rec.last_update_login		:= g_login_id;
	p_trx_hdr_rec.bu_group_id               := p_rpr_rec.bu_group_id;

  EXCEPTION WHEN OTHERS THEN
	g_retcode := 2;
	g_errbuf := 'Error in set_hdr_fields procedure '|| SQLERRM;
  Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
					'.final_exception',g_errbuf);
END; --procedure set_hdr_fields

PROCEDURE set_dtl_fields (p_count NUMBER,
			  p_trx_dtl_rec  OUT NOCOPY fv_be_trx_dtls%ROWTYPE,
			  p_rpr_rec fv_be_rpr_transactions%ROWTYPE)
IS
l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'set_dtl_fields';
	SELECT fv_be_trx_dtls_s.NEXTVAL
	INTO p_trx_dtl_rec.transaction_id
	FROM dual;

	p_trx_dtl_rec.revision_num 		:= 0;
	p_trx_dtl_rec.transaction_status	:= 'IN';

	p_trx_dtl_rec.gl_date := p_rpr_rec.gl_date;

    	SELECT quarter_num
        INTO   p_trx_dtl_rec.quarter_num
        FROM   gl_period_statuses
        WHERE  set_of_books_id = g_sob_id
        AND    application_id = '101'
        AND    start_date <= p_rpr_rec.gl_date
        AND    end_date  >= p_rpr_rec.gl_date
        AND    adjustment_period_flag='N';

	p_trx_dtl_rec.transaction_type_id := p_rpr_rec.transaction_type_id;

	--Set the detail records segments regardless of the budget level
	--As per the latest change even for first budget level in the table
	--segment values will be stored at detail level but they will not be
	--visible on the form. This is only for the lower level
	--from distribution LOV purpose.

	  IF (p_count=1) THEN

	   p_trx_dtl_rec.budgeting_segments := p_rpr_rec.distribution_from;
	   p_trx_dtl_rec.segment1		:= p_rpr_rec.segment1_from;
	   p_trx_dtl_rec.segment2		:= p_rpr_rec.segment2_from;
	   p_trx_dtl_rec.segment3		:= p_rpr_rec.segment3_from;
	   p_trx_dtl_rec.segment4		:= p_rpr_rec.segment4_from;
	   p_trx_dtl_rec.segment5		:= p_rpr_rec.segment5_from;
	   p_trx_dtl_rec.segment6		:= p_rpr_rec.segment6_from;
	   p_trx_dtl_rec.segment7		:= p_rpr_rec.segment7_from;
	   p_trx_dtl_rec.segment8		:= p_rpr_rec.segment8_from;
	   p_trx_dtl_rec.segment9		:= p_rpr_rec.segment9_from;
	   p_trx_dtl_rec.segment10		:= p_rpr_rec.segment10_from;
	   p_trx_dtl_rec.segment11		:= p_rpr_rec.segment11_from;
	   p_trx_dtl_rec.segment12		:= p_rpr_rec.segment12_from;
	   p_trx_dtl_rec.segment13		:= p_rpr_rec.segment13_from;
	   p_trx_dtl_rec.segment14		:= p_rpr_rec.segment14_from;
	   p_trx_dtl_rec.segment15		:= p_rpr_rec.segment15_from;
	   p_trx_dtl_rec.segment16		:= p_rpr_rec.segment16_from;
	   p_trx_dtl_rec.segment17		:= p_rpr_rec.segment17_from;
	   p_trx_dtl_rec.segment18		:= p_rpr_rec.segment18_from;
	   p_trx_dtl_rec.segment19		:= p_rpr_rec.segment19_from;
	   p_trx_dtl_rec.segment20		:= p_rpr_rec.segment20_from;
	   p_trx_dtl_rec.segment21		:= p_rpr_rec.segment21_from;
	   p_trx_dtl_rec.segment22		:= p_rpr_rec.segment22_from;
	   p_trx_dtl_rec.segment23		:= p_rpr_rec.segment23_from;
	   p_trx_dtl_rec.segment24		:= p_rpr_rec.segment24_from;
	   p_trx_dtl_rec.segment25		:= p_rpr_rec.segment25_from;
	   p_trx_dtl_rec.segment26		:= p_rpr_rec.segment26_from;
	   p_trx_dtl_rec.segment27		:= p_rpr_rec.segment27_from;
	   p_trx_dtl_rec.segment28		:= p_rpr_rec.segment28_from;
	   p_trx_dtl_rec.segment29		:= p_rpr_rec.segment29_from;
	   p_trx_dtl_rec.segment30		:= p_rpr_rec.segment30_from;
	  ELSE
	   p_trx_dtl_rec.budgeting_segments := p_rpr_rec.distribution_to;
	   p_trx_dtl_rec.segment1		:= p_rpr_rec.segment1;
	   p_trx_dtl_rec.segment2		:= p_rpr_rec.segment2;
	   p_trx_dtl_rec.segment3		:= p_rpr_rec.segment3;
	   p_trx_dtl_rec.segment4		:= p_rpr_rec.segment4;
	   p_trx_dtl_rec.segment5		:= p_rpr_rec.segment5;
	   p_trx_dtl_rec.segment6		:= p_rpr_rec.segment6;
	   p_trx_dtl_rec.segment7		:= p_rpr_rec.segment7;
	   p_trx_dtl_rec.segment8		:= p_rpr_rec.segment8;
	   p_trx_dtl_rec.segment9		:= p_rpr_rec.segment9;
	   p_trx_dtl_rec.segment10		:= p_rpr_rec.segment10;
	   p_trx_dtl_rec.segment11		:= p_rpr_rec.segment11;
	   p_trx_dtl_rec.segment12		:= p_rpr_rec.segment12;
	   p_trx_dtl_rec.segment13		:= p_rpr_rec.segment13;
	   p_trx_dtl_rec.segment14		:= p_rpr_rec.segment14;
	   p_trx_dtl_rec.segment15		:= p_rpr_rec.segment15;
	   p_trx_dtl_rec.segment16		:= p_rpr_rec.segment16;
	   p_trx_dtl_rec.segment17		:= p_rpr_rec.segment17;
	   p_trx_dtl_rec.segment18		:= p_rpr_rec.segment18;
	   p_trx_dtl_rec.segment19		:= p_rpr_rec.segment19;
	   p_trx_dtl_rec.segment20		:= p_rpr_rec.segment20;
	   p_trx_dtl_rec.segment21		:= p_rpr_rec.segment21;
	   p_trx_dtl_rec.segment22		:= p_rpr_rec.segment22;
	   p_trx_dtl_rec.segment23		:= p_rpr_rec.segment23;
	   p_trx_dtl_rec.segment24		:= p_rpr_rec.segment24;
	   p_trx_dtl_rec.segment25		:= p_rpr_rec.segment25;
	   p_trx_dtl_rec.segment26		:= p_rpr_rec.segment26;
	   p_trx_dtl_rec.segment27		:= p_rpr_rec.segment27;
	   p_trx_dtl_rec.segment28		:= p_rpr_rec.segment28;
	   p_trx_dtl_rec.segment29		:= p_rpr_rec.segment29;
	   p_trx_dtl_rec.segment30		:= p_rpr_rec.segment30;

	  END IF;

	IF (p_count=1) THEN
	  p_trx_dtl_rec.increase_decrease_flag	:= 'D';
	ELSE
	  p_trx_dtl_rec.increase_decrease_flag	:= 'I';
	END IF;
	p_trx_dtl_rec.amount			:= p_rpr_rec.amount;
	p_trx_dtl_rec.sub_type		        := p_rpr_rec.sub_type;
	p_trx_dtl_rec.gl_transfer_flag		:= 'N';
	p_trx_dtl_rec.approved_by_user_id	:= NULL;
	p_trx_dtl_rec.approved_by_user_id	:= NULL;
	p_trx_dtl_rec.posting_process_id	:= NULL;
	p_trx_dtl_rec.set_of_books_id		:= g_sob_id;
	p_trx_dtl_rec.creation_date		:= g_sysdate;
	p_trx_dtl_rec.created_by		:= g_user_id;
	p_trx_dtl_rec.last_update_date		:= g_sysdate;
	p_trx_dtl_rec.last_updated_by		:= g_user_id;
	p_trx_dtl_rec.last_update_login		:= g_login_id;
	p_trx_dtl_rec.public_law_code		:= p_rpr_rec.public_law_code;
	p_trx_dtl_rec.advance_type		:= p_rpr_rec.advance_type;
	p_trx_dtl_rec.dept_id			:= p_rpr_rec.dept_id;
	p_trx_dtl_rec.main_account		:= p_rpr_rec.main_account;
	p_trx_dtl_rec.transfer_description	:= p_rpr_rec.transfer_description;



  EXCEPTION WHEN OTHERS THEN
	g_retcode := 2;
	g_errbuf := 'Error in set_dtl_fields procedure '|| SQLERRM;
  Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',g_errbuf);

END; --procedure set_dtl_fields

PROCEDURE insert_hdr_record(p_trx_hdr_rec fv_be_trx_hdrs%ROWTYPE) IS
l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'insert_hdr_record';

	INSERT INTO fv_be_trx_hdrs
		(doc_id			,
		 doc_number		,
		 revision_num		,
		 internal_revision_num	,
		 treasury_symbol_id	,
		 fund_value		,
		 budget_level_id	,
		 transaction_date	,
		 doc_status		,
		 doc_total		,
		 source			,
		 budgeting_segments	,
		 segment1		,
		 segment2		,
		 segment3		,
		 segment4		,
		 segment5		,
		 segment6		,
		 segment7		,
		 segment8		,
		 segment9		,
		 segment10		,
		 segment11		,
		 segment12		,
		 segment13		,
		 segment14		,
		 segment15		,
		 segment16		,
	 	 segment17		,
		 segment18		,
		 segment19		,
		 segment20		,
		 segment21		,
		 segment22		,
		 segment23		,
		 segment24		,
		 segment25		,
		 segment26		,
		 segment27		,
		 segment28		,
		 segment29		,
		 segment30		,
		 approval_id		,
		 approved_by_user_id	,
		 distribution_amount	,
		 old_doc_number		,
		 set_of_books_id	,
		 bu_group_id		,
		 creation_date		,
		 created_by		,
		 last_update_date	,
		 last_updated_by	,
		 last_update_login)
	 VALUES
		(p_trx_hdr_rec.doc_id			,
		 p_trx_hdr_rec.doc_number		,
	 	 p_trx_hdr_rec.revision_num		,
		 p_trx_hdr_rec.internal_revision_num	,
		 p_trx_hdr_rec.treasury_symbol_id	,
		 p_trx_hdr_rec.fund_value		,
		 p_trx_hdr_rec.budget_level_id		,
		 TRUNC(p_trx_hdr_rec.transaction_date)	,
		 p_trx_hdr_rec.doc_status		,
		 p_trx_hdr_rec.doc_total		,
		 p_trx_hdr_rec.source			,
		 p_trx_hdr_rec.budgeting_segments	,
		 p_trx_hdr_rec.segment1			,
		 p_trx_hdr_rec.segment2			,
		 p_trx_hdr_rec.segment3			,
		 p_trx_hdr_rec.segment4			,
		 p_trx_hdr_rec.segment5			,
		 p_trx_hdr_rec.segment6			,
		 p_trx_hdr_rec.segment7			,
		 p_trx_hdr_rec.segment8			,
		 p_trx_hdr_rec.segment9			,
		 p_trx_hdr_rec.segment10		,
		 p_trx_hdr_rec.segment11		,
		 p_trx_hdr_rec.segment12		,
		 p_trx_hdr_rec.segment13		,
	 	 p_trx_hdr_rec.segment14		,
		 p_trx_hdr_rec.segment15		,
		 p_trx_hdr_rec.segment16		,
		 p_trx_hdr_rec.segment17		,
		 p_trx_hdr_rec.segment18		,
		 p_trx_hdr_rec.segment19		,
		 p_trx_hdr_rec.segment20		,
		 p_trx_hdr_rec.segment21		,
		 p_trx_hdr_rec.segment22		,
		 p_trx_hdr_rec.segment23		,
		 p_trx_hdr_rec.segment24		,
		 p_trx_hdr_rec.segment25		,
		 p_trx_hdr_rec.segment26		,
		 p_trx_hdr_rec.segment27		,
		 p_trx_hdr_rec.segment28		,
		 p_trx_hdr_rec.segment29		,
		 p_trx_hdr_rec.segment30		,
		 p_trx_hdr_rec.approval_id		,
		 p_trx_hdr_rec.approved_by_user_id	,
		 p_trx_hdr_rec.distribution_amount	,
		 p_trx_hdr_rec.old_doc_number		,
		 p_trx_hdr_rec.set_of_books_id		,
		 p_trx_hdr_rec.bu_group_id		,
		 p_trx_hdr_rec.creation_date		,
		 p_trx_hdr_rec.created_by		,
		 p_trx_hdr_rec.last_update_date		,
		 p_trx_hdr_rec.last_updated_by		,
		 p_trx_hdr_rec.last_update_login       );

  EXCEPTION WHEN OTHERS THEN
	g_retcode := 2;
	g_errbuf := 'Error in insert_hdr_record procedure '||SQLERRM;
  	Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',g_errbuf);

END; --procedure insert_hdr_record

PROCEDURE insert_dtl_record (p_trx_dtl_rec fv_be_trx_dtls%ROWTYPE) IS
l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'insert_dtl_record';
	INSERT INTO fv_be_trx_dtls
		(transaction_id		,
		 doc_id			,
		 revision_num		,
		 transaction_status	,
	 	 gl_date		,
		 quarter_num		,
		 transaction_type_id	,
	 	 budgeting_segments	,
		 segment1		,
		 segment2		,
		 segment3		,
		 segment4		,
		 segment5		,
		 segment6		,
		 segment7		,
		 segment8		,
		 segment9		,
		 segment10		,
		 segment11		,
		 segment12		,
		 segment13		,
		 segment14		,
		 segment15		,
		 segment16		,
		 segment17		,
		 segment18		,
		 segment19		,
		 segment20		,
		 segment21		,
		 segment22		,
		 segment23		,
		 segment24		,
		 segment25		,
		 segment26		,
		 segment27		,
		 segment28		,
		 segment29		,
		 segment30		,
		 increase_decrease_flag ,
		 amount			,
		 public_law_code	,
		 advance_type		,
		 dept_id		,
		 main_account		,
		 transfer_description	,
		 sub_type        	,
		 gl_transfer_flag	,
		 approved_by_user_id	,
		 posting_process_id	,
		 set_of_books_id	,
		 creation_date		,
		 created_by		,
		 last_update_date	,
		 last_updated_by	,
		 last_update_login	)
	 VALUES
		(p_trx_dtl_rec.transaction_id		,
		 p_trx_dtl_rec.doc_id			,
		 p_trx_dtl_rec.revision_num		,
		 p_trx_dtl_rec.transaction_status	,
		 TRUNC(p_trx_dtl_rec.gl_date)		,
		 p_trx_dtl_rec.quarter_num		,
		 p_trx_dtl_rec.transaction_type_id	,
		 p_trx_dtl_rec.budgeting_segments	,
		 p_trx_dtl_rec.segment1			,
		 p_trx_dtl_rec.segment2			,
		 p_trx_dtl_rec.segment3			,
		 p_trx_dtl_rec.segment4			,
		 p_trx_dtl_rec.segment5			,
		 p_trx_dtl_rec.segment6			,
		 p_trx_dtl_rec.segment7			,
		 p_trx_dtl_rec.segment8			,
		 p_trx_dtl_rec.segment9			,
		 p_trx_dtl_rec.segment10		,
		 p_trx_dtl_rec.segment11		,
		 p_trx_dtl_rec.segment12		,
		 p_trx_dtl_rec.segment13		,
		 p_trx_dtl_rec.segment14		,
		 p_trx_dtl_rec.segment15		,
		 p_trx_dtl_rec.segment16		,
		 p_trx_dtl_rec.segment17		,
		 p_trx_dtl_rec.segment18		,
	 	 p_trx_dtl_rec.segment19		,
		 p_trx_dtl_rec.segment20		,
		 p_trx_dtl_rec.segment21		,
		 p_trx_dtl_rec.segment22		,
		 p_trx_dtl_rec.segment23		,
		 p_trx_dtl_rec.segment24,
	 	 p_trx_dtl_rec.segment25		,
		 p_trx_dtl_rec.segment26		,
		 p_trx_dtl_rec.segment27		,
		 p_trx_dtl_rec.segment28		,
		 p_trx_dtl_rec.segment29		,
		 p_trx_dtl_rec.segment30		,
		 p_trx_dtl_rec.increase_decrease_flag	,
		 p_trx_dtl_rec.amount			,
		 p_trx_dtl_rec.public_law_code		,
		 p_trx_dtl_rec.advance_type		,
		 p_trx_dtl_rec.dept_id			,
		 p_trx_dtl_rec.main_account		,
		 p_trx_dtl_rec.transfer_description	,
		 p_trx_dtl_rec.sub_type  		,
		 p_trx_dtl_rec.gl_transfer_flag		,
		 p_trx_dtl_rec.approved_by_user_id	,
		 p_trx_dtl_rec.posting_process_id	,
		 p_trx_dtl_rec.set_of_books_id		,
		 p_trx_dtl_rec.creation_date		,
		 p_trx_dtl_rec.created_by		,
		 p_trx_dtl_rec.last_update_date		,
		 p_trx_dtl_rec.last_updated_by		,
		 p_trx_dtl_rec.last_update_login       );

  EXCEPTION WHEN OTHERS THEN
	g_retcode := 2;
	g_errbuf := 'Error in insert_dtl_record procedure '||SQLERRM;
	Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',g_errbuf);

END; --procedure insert_dtl_record

PROCEDURE reset_doc_status(p_from_doc_id NUMBER, p_to_doc_id NUMBER) IS
l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'reset_doc_status';
	UPDATE fv_be_trx_hdrs
	SET doc_status = 'IN',
	    approved_by_user_id = NULL
	WHERE doc_id IN (p_from_doc_id, p_to_doc_id);

	UPDATE fv_be_trx_dtls
	SET transaction_status = 'IN'
	WHERE doc_id IN (p_from_doc_id, p_to_doc_id);

	COMMIT;

  EXCEPTION WHEN OTHERS THEN
	g_retcode := 2;
	g_errbuf := 'Error in reset_doc_status procedure '||SQLERRM;
  	Fv_Utility.Log_Mesg(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
						'.final_exception',g_errbuf);
END;
BEGIN
  g_module_name := 'fv.plsql.fv_be_rpr_pkg.';
END fv_be_rpr_pkg; -- Package body

/
