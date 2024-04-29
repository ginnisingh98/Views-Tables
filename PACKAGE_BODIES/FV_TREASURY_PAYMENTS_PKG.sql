--------------------------------------------------------
--  DDL for Package Body FV_TREASURY_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_TREASURY_PAYMENTS_PKG" AS
-- $Header: FVAPPAYB.pls 120.19.12010000.2 2009/10/26 20:33:50 snama ship $

 g_module_name        VARCHAR2(200) := 'fv.plsql.fv_treasury_payments_pkg.';
 g_errmsg             VARCHAR2(1000);
 g_ledger_id          gl_ledgers.ledger_id%TYPE;
 g_org_id	      fv_operating_units.org_id%TYPE;
 g_treasury_conf_id   fv_treasury_confirmations.treasury_confirmation_id%TYPE;
 g_accounting_date    fv_treasury_confirmations.treasury_doc_date%TYPE;
 g_payment_instr_id   iby_pay_instructions_all.payment_instruction_id%TYPE;
 g_checkrun_name      ap_checks_all.checkrun_name%TYPE;
 x_err_code           NUMBER;
 x_err_stage          VARCHAR2(2000);
 g_dit_flag           VARCHAR2(1);
 G_LOG_LEVEL          CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


 PROCEDURE CREATE_TREASURY_PAYMENT_EVENT
                                        (p_calling_sequence IN VARCHAR2
                                        ,p_event_type       IN VARCHAR2
                                        ,p_treasury_conf_id IN NUMBER
                                        ,x_status_code     OUT NOCOPY VARCHAR2
                                        ,x_return_status   OUT NOCOPY VARCHAR2);
 PROCEDURE DO_CONFIRM_PROCESS (x_status_code     OUT NOCOPY VARCHAR2
                              ,x_return_status   OUT NOCOPY VARCHAR2);

 PROCEDURE DO_BACKOUT_PROCESS(x_status_code     OUT NOCOPY VARCHAR2
                             ,x_return_status   OUT NOCOPY VARCHAR2);

 /* Bug: 5727409 - Forward declaration of Procedure get_open_period */

 PROCEDURE GET_OPEN_PERIOD(p_accounting_date IN OUT NOCOPY DATE);

 PROCEDURE Main(x_errbuf   OUT NOCOPY VARCHAR2
               ,x_retcode  OUT NOCOPY VARCHAR2
               ,p_treas_conf_id IN  VARCHAR2
               ,p_button_name   IN  VARCHAR2)
 IS
    l_module_name VARCHAR2(200);
    l_dummy       NUMBER;
    l_dit_flag    fv_operating_units.dit_flag%TYPE;
    X_status_code   VARCHAR2(100);
    X_return_status VARCHAR2(100);
 BEGIN
     l_module_name         :=  g_module_name || 'Main ';
      SAVEPOINT FV_TREAS;
	-- Initialize variables
  	 x_err_code := 0;
     g_treasury_conf_id := TO_NUMBER(p_treas_conf_id);


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                            'Treasury Confirmation Id = '||g_treasury_conf_id);
     END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                            'Org Id = '|| g_org_id);
     END IF;


     BEGIN
 	   SELECT 1
           INTO   l_dummy
           FROM   gl_je_categories
           WHERE  je_category_name = 'Treasury Confirmation';

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
    	   l_dummy := 0;
     END;

     IF (l_dummy = 0) THEN
        IF p_button_name = 'TREASURY_CONFIRMATION.CONFIRM' THEN
             UPDATE fv_treasury_confirmations
      	    SET    confirmation_status_flag = 'N'
    	    WHERE treasury_confirmation_id = g_treasury_conf_id;
        ELSIF p_button_name = 'TREASURY_CONFIRMATION.BACK_OUT' THEN
            UPDATE fv_treasury_confirmations
 	        SET    confirmation_status_flag = 'Y'
	        WHERE treasury_confirmation_id = g_treasury_conf_id;
         END IF;
         commit;
    	  x_retcode := 2;
          x_errbuf  := 'The Treasury Confirmation journal category has not been seeded';
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                            'p_button_name = '||p_button_name);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                            'Treasury Confirmation Id = '||g_treasury_conf_id);
          END IF;
          Return;
     END IF;


     BEGIN
      SELECT payment_instruction_id
            ,treasury_doc_date
            ,set_of_books_id
            ,org_id
            ,checkrun_name
      INTO   g_payment_instr_id
            ,g_accounting_date
            ,g_ledger_id
            ,g_org_id
            ,g_checkrun_name
      FROM   fv_treasury_confirmations
      WHERE  treasury_confirmation_id = g_treasury_conf_id;

   /* Bug: 5727409 - getting open period accounting date */
   get_open_period(g_accounting_date);
      --Check whether dit_flag is enabled in fv_operating_units table
   g_dit_flag := Null;

    SELECT dit_flag
	INTO   l_dit_flag
	FROM   fv_operating_units
    where org_id = g_org_id ;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                   'dit flag = '||l_dit_flag);
    END IF;
    g_dit_flag := l_dit_flag;

    IF l_dit_flag <> 'Y' THEN
      x_retcode := 0;
      x_errbuf := 'Disbursement in transit checkbox is disabled in Define Federal Options form'||
                  '-no accounting created for Treasury Confirmation ';
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
           'No Accounting created for Treasury Confirmation -'||
           'disbursement in transit checkbox is disabled in Define Federal Options form');
        END IF;
    END IF;




      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                   'g_payment_instr_id = '||g_payment_instr_id);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                    'g_accounting_date = '||g_accounting_date);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                'g_ledger_id = '||g_ledger_id);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                      'g_org_id = '||g_org_id);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                        'g_checkrun_name = '||g_checkrun_name);
      END IF;
     EXCEPTION
      WHEN OTHERS THEN
        x_retcode := 2;
        x_errbuf := 'The Treasury Confirmation rows are not available';
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                            'p_button_name = '||p_button_name);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                            'Treasury Confirmation Id = '||g_treasury_conf_id);
        END IF;
     END;

     IF (x_retcode = 2) THEN
        IF p_button_name = 'TREASURY_CONFIRMATION.CONFIRM' THEN
            UPDATE fv_treasury_confirmations
     	    SET    confirmation_status_flag = 'N'
	    WHERE treasury_confirmation_id = g_treasury_conf_id;
         ELSIF p_button_name = 'TREASURY_CONFIRMATION.BACK_OUT' THEN
            UPDATE fv_treasury_confirmations
 	    SET    confirmation_status_flag = 'Y'
	    WHERE treasury_confirmation_id = g_treasury_conf_id;
         END IF;
         commit;
         RETURN;
     END IF;

     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                    'Button='||p_button_name);

     IF p_button_name = 'TREASURY_CONFIRMATION.CONFIRM' THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                'Confirmation Process begins');
		END IF;
        do_confirm_process(x_status_code,x_return_status);
        x_retcode := x_status_code;

        IF (x_status_code = 'SUCCESS') THEN
            UPDATE fv_treasury_confirmations
     	    SET    confirmation_status_flag = 'Y'
	     	WHERE treasury_confirmation_id = g_treasury_conf_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                     'The Confirm Process is Successful');
    	    END IF;
       ELSE

	   ROLLBACK TO FV_TREAS;
	    x_retcode:=2;


       	    UPDATE fv_treasury_confirmations
     	    SET    confirmation_status_flag = 'N'
	     	WHERE treasury_confirmation_id = g_treasury_conf_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                    'The Confirm Process has failed.');
		    END IF;

            END IF;

     ELSIF p_button_name = 'TREASURY_CONFIRMATION.BACK_OUT' THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                     'Backout Process begins');
		END IF;
          if g_dit_flag = 'Y' THEN

            do_backout_process(x_status_code,x_return_status);
            x_retcode := x_status_code;
         Else
            x_retcode :=0;
            x_status_code := 'SUCCESS';

         END IF;

	      IF (x_status_code = 'SUCCESS') THEN
        	    UPDATE fv_treasury_confirmations
 	            SET    confirmation_status_flag = 'B'
	   	       WHERE treasury_confirmation_id = g_treasury_conf_id;

	            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                     'The Backout Process is Successful');
 		    END IF;
	      ELSE
			   ROLLBACK TO FV_TREAS;
			    x_retcode:=2;

        	    UPDATE fv_treasury_confirmations
 	            SET    confirmation_status_flag = 'Y'
	   	        WHERE treasury_confirmation_id = g_treasury_conf_id;

        	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                    'The Backout Process has failed.');
		    END IF;

	     END IF;
     ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                           'No Treasury Confirmation process');
	  END IF;
      RETURN;
     END IF;

	Commit;

  EXCEPTION
       WHEN OTHERS THEN
            g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
 END Main;

PROCEDURE DO_CONFIRM_PROCESS (x_status_code   OUT NOCOPY VARCHAR2
                              ,x_return_status OUT NOCOPY VARCHAR2)
 IS
    l_dummy       NUMBER;
    l_begin_doc	  fv_treasury_confirmations.begin_doc_num%TYPE;
    l_end_doc	  fv_treasury_confirmations.end_doc_num%TYPE;
    l_diff        NUMBER;
    l_row_num     NUMBER;
    l_module_name VARCHAR2(200);
    l_void_count  NUMBER;

    l_void_status_code VARCHAR2(2000);
    l_void_return_status VARCHAR2(1);

    --Variables used for 11i Upgrade rows
    l_pay_fmt_program_name  ap_payment_programs.program_name%TYPE;
    l_checkrun_name fv_treasury_confirmations_all.checkrun_name%TYPE;
    l_select_str VARCHAR2(1000);
    TYPE t_refcur IS REF CURSOR;
    l_upg_check_id_cur  t_refcur;
    l_corr_treas_pay_num fv_tc_offsets.corrected_treasury_pay_number%TYPE;
    l_offset_check_id	fv_tc_offsets.check_id%TYPE;

   -- declare array to store check_ids
    TYPE l_check_row IS RECORD (CHECK_ID NUMBER(15)) ;
    TYPE l_check_tbl_type IS TABLE OF l_check_row INDEX BY BINARY_INTEGER;
    l_check_tbl  l_check_tbl_type;

    CURSOR cur_get_checks IS
    SELECT ac.check_id
    FROM   ap_checks ac
          ,fv_treasury_confirmations ftc
    WHERE ftc.treasury_confirmation_id = g_treasury_conf_id
    AND   ftc.payment_instruction_id   = ac.payment_instruction_id
    AND   ac.org_id                   = g_org_id;

    CURSOR	cur_corr_treas_pay_num IS
    SELECT	fto.corrected_treasury_pay_number, fto.check_id
    FROM	fv_tc_offsets	fto,
     	        ap_checks	ac,
                iby_pay_instructions_all ipa
    WHERE 	ac.check_id = fto.check_id
    AND     ipa.payment_instruction_id = ac.payment_instruction_id
    AND     ipa.payment_instruction_id = g_payment_instr_id;

    CURSOR c_check_ranges IS
    SELECT ftcr.range_from, ftcr.range_to
    FROM   fv_treasury_check_ranges ftcr
    WHERE  ftcr.treasury_confirmation_id = g_treasury_conf_id;

    l_calling_sequence VARCHAR2(1000);
    l_return_status    VARCHAR2(100);
    l_status_code    VARCHAR2(100);

 BEGIN

   l_module_name := g_module_name ||'do_confirm_process';

   l_calling_sequence := 'FV_TREASURY_PAYMENTS_PKG.do_confirm_process';

    l_void_count :=0;

    x_status_code := 'SUCCESS';

   -- select statement for 11i upgrade rows
    BEGIN
    SELECT checkrun_name
    INTO  l_checkrun_name
    FROM FV_TREASURY_CONFIRMATIONS_ALL
    WHERE payment_instruction_id = g_payment_instr_id
    AND   org_id                 = g_org_id;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'l_checkrun_name = '||l_checkrun_name);
    END IF;
    EXCEPTION
     WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                      'No Upgrade entries');
      END IF;
    l_checkrun_name := NULL;
    END;

    IF l_checkrun_name IS NOT NULL THEN



	SELECT appp.program_name
          INTO l_pay_fmt_program_name
         FROM  ap_inv_selection_criteria_all apisc ,
               ap_payment_programs appp
         WHERE apisc.checkrun_name = g_checkrun_name
         AND   apisc.org_id        = g_org_id
         AND   appp.program_id     = apisc.program_id ;


	-- setting the predefined order of the check_ids based on Payment Format

     IF l_pay_fmt_program_name IN ('FVBLCCDP' , 'FVBLPPDP','FVTPCCD','FVTIACHP',
				                   'FVTPPPD','FVTPPPDP','FVSPCCD','FVSPCCDP',
                   				   'FVSPPPDP','FVSPPPD' ) THEN
         l_select_str := 'SELECT check_id FROM  fv_tc_check_v WHERE' ||
                         ' checkrun_name = g_checkrun_name ORDER BY '||
                         ' routing_transit_num , num_1099, check_number'   ;
     ELSIF l_pay_fmt_program_name IN ('FVBLNCR','FVBLSLTR','FVTIACHB','FVSPNCR')
     THEN
         l_select_str := 'SELECT check_id FROM  fv_tc_check_v WHERE' ||
                         ' checkrun_name = g_checkrun_name ORDER BY '||
                         ' num_1099, check_number'   ;
     ELSE
         l_select_str := 'SELECT check_id FROM  fv_tc_check_v WHERE' ||
                         ' checkrun_name = g_checkrun_name' ||
        			     ' ORDER BY  check_number';
     END IF;
     -- Get all the 11i upgrade rows check_id values
     l_row_num := 1;
     OPEN l_upg_check_id_cur FOR l_select_str;
     LOOP
     FETCH l_upg_check_id_cur INTO l_check_tbl(l_row_num).check_id;
        l_row_num := l_row_num + 1;
      EXIT WHEN l_upg_check_id_cur %NOTFOUND;
     END LOOP;
   ELSE
     --Get all the R12 checks related to this treasury confirmation id
     l_row_num := 1;
     OPEN cur_get_checks;
     LOOP
     FETCH cur_get_checks INTO l_check_tbl(l_row_num).check_id;
        l_row_num := l_row_num + 1;
     EXIT WHEN cur_get_checks %NOTFOUND;
     END LOOP;

    END IF;

    l_row_num := 1;

     -- Assigning the treasury Pay number to the respective checks
     FOR c_check_range_rec IN c_check_ranges
     LOOP
       l_begin_doc := c_check_range_rec.range_from;
       l_end_doc   := c_check_range_rec.range_to;

        IF (l_begin_doc IS NULL) OR (l_end_doc IS NULL) OR
           (g_payment_instr_id IS NULL)  OR ( g_accounting_date IS NULL) THEN
            x_err_code := 20;
            x_err_stage :=  'Data in treasury confirmation table is missing';
            RETURN;
        END IF;

        l_diff  := l_end_doc - l_begin_doc + 1;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                 'l_diff is ' || l_diff);
        END IF;

      FOR i IN 1.. l_diff
      LOOP
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                                      'l_row_num:'||l_row_num);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                      'l_check_tbl(l_row_num).check_id:'||
                                       l_check_tbl(l_row_num).check_id);
       END IF;

        UPDATE ap_checks c
        SET treasury_pay_number = l_begin_doc,
            treasury_pay_date   = g_accounting_date,
            last_update_date    = SYSDATE,
            last_updated_by     = fnd_global.user_id,
            last_update_login   = fnd_global.login_id
        WHERE c.check_id = l_check_tbl(l_row_num).check_id;

        l_row_num   := l_row_num+1;
        l_begin_doc := l_begin_doc +1;
      END LOOP;
     END LOOP;

	-- Update ap_checks if a corrected treasury pay number
	-- for a payment within the batch being processed has been entered
	OPEN	cur_corr_treas_pay_num;
	LOOP
	FETCH	cur_corr_treas_pay_num INTO l_corr_treas_pay_num, l_offset_check_id;
	EXIT WHEN cur_corr_treas_pay_num%NOTFOUND;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'In corrected treasury pay number loop');
       END IF;

    IF l_corr_treas_pay_num IS NOT NULL THEN
		UPDATE	ap_checks
		SET	treasury_pay_number = l_corr_treas_pay_num
		WHERE	check_id = l_offset_check_id;
	END IF;
	END LOOP;
	CLOSE cur_corr_treas_pay_num;

    if g_dit_flag = 'Y' THEN

          create_treasury_payment_event(l_calling_sequence,
                                        'TREASURY_CONFIRM',
                                       g_treasury_conf_id ,
                                          x_status_code,
                                          x_return_status);



       IF x_status_code= 'SUCCESS' THEN

            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'Treasury Confirmation Successful. Checking for Voided Checks');

          SELECT COUNT(ac.check_id) INTO l_void_count
           FROM   ap_checks_all ac
              ,fv_treasury_confirmations_all ftc
            WHERE ftc.treasury_confirmation_id = g_treasury_conf_id
                AND   ftc.payment_instruction_id   = ac.payment_instruction_id
                AND   ac.org_id                   =  g_org_id
                AND  ac.org_id                     = ftc.org_id
                AND   ac.void_date IS NOT NULL;

                IF l_void_count <> 0 THEN


            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'Voided Checks = ' || l_void_count);


     INSERT INTO fv_voided_checks
    (
      void_id,
      checkrun_name,
      check_id,
      processed_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      payment_instruction_id
    )
    SELECT fv_voided_checks_s.nextval,
           ac.checkrun_name,
           ac.check_id,
           'U',
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
           ac.org_id,
           g_payment_instr_id
      FROM ap_checks_all ac,
           fv_treasury_confirmations_all fvc
      WHERE ac.org_id = g_org_id
        AND  fvc.org_id = ac.org_id
        AND fvc.treasury_confirmation_id= g_treasury_conf_id
        AND fvc.payment_instruction_id   = ac.payment_instruction_id
       AND ac.void_date IS NOT NULL
       AND (ac.checkrun_name IS NOT NULL OR ac.payment_id IS NOT NULL)
       AND NOT EXISTS (SELECT 1
                        FROM fv_voided_checks fvc
                       WHERE fvc.check_id = ac.check_id
                         AND fvc.org_id = ac.org_id);

     UPDATE fv_treasury_confirmations
     	    SET    confirmation_status_flag = 'Y'
	     	WHERE treasury_confirmation_id = g_treasury_conf_id;

     commit;

            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'Calling Create treasury payment for Voided Checks');

    create_treasury_payment_event(l_calling_sequence,
                                      'TREASURY_VOID',
                                      g_treasury_conf_id,
                                      x_status_code,
                                      x_return_status);


            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'After Create treasury payment for Voided Checks');

        BEGIN

           IF (x_status_code = 'SUCCESS') THEN


            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                             'Create treasury payment for Voided Checks is Successful');

            UPDATE fv_voided_checks
               SET processed_flag = 'P'
             WHERE processed_flag = 'U'
               AND org_id = g_org_id
               and check_id in ( select check_id
                                 from fv_treasury_confirmations_all fvtreas  ,
                                      ap_checks_all ac
                                 where
                                 fvtreas.org_id = g_org_id
                                 and ac.org_id = fvtreas.org_id
                                 and fvtreas.treasury_confirmation_id = g_treasury_conf_id
                                 and fvtreas.payment_instruction_id = ac.payment_instruction_id
                                 and ac.void_date is not null
                                 );
            END IF;

         EXCEPTION
                WHEN OTHERS THEN
                      fv_utility.log_mesg(fnd_log.level_exception,l_module_name||
                      'Error in Creating Void Accounting ',SQLERRM);
        END;




                END IF;
      END IF;

        END IF;


 EXCEPTION
   WHEN OTHERS THEN
      x_status_code := 'FAILURE';

 END do_confirm_process;

 PROCEDURE DO_BACKOUT_PROCESS (x_status_code   OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2)
 IS
    l_module_name      VARCHAR2(100);
    l_calling_sequence VARCHAR2(1000);
 BEGIN

   l_module_name := g_module_name ||'do_backout_process';

   l_calling_sequence := 'FV_TREASURY_PAYMENTS_PKG.do_backout_process';
   create_treasury_payment_event(l_calling_sequence,
                                'TREASURY_BACKOUT',
                               g_treasury_conf_id ,
                                x_status_code,
                                x_return_status);

 END do_backout_process;

PROCEDURE GET_OPEN_PERIOD(p_accounting_date IN OUT NOCOPY DATE)
IS
v_status gl_period_statuses.closing_status%type;
v_pyear gl_period_statuses.period_year%type;
l_module_name VARCHAR2(200);
v_pnum gl_period_statuses.effective_period_num%type;
BEGIN

/* To find out whether period is open for particular gl_accounting_date */
l_module_name := g_module_name ||' get_open_period';

   SELECT closing_status,period_year,effective_period_num
     INTO v_status,v_pyear,v_pnum
     FROM gl_period_statuses gps
    WHERE gps.ledger_id = g_ledger_id
      AND gps.application_id = 101
      AND p_accounting_date BETWEEN gps.start_date AND gps.end_date
      AND gps.adjustment_period_flag = 'N';

	IF v_status  = 'C' THEN    /* If Period is closed then get starting
				     accounting date of next open period */

		BEGIN

		SELECT start_date
		  INTO p_accounting_date
		  FROM gl_period_statuses gps
		 WHERE gps.ledger_id = g_ledger_id
		   AND gps.application_id = 101
		   AND gps.period_year >= v_pyear
		   AND effective_period_num > v_pnum
		   AND gps.closing_status = 'O'
		   AND gps.adjustment_period_flag = 'N'
		   AND ROWNUM  < 2
		 ORDER BY period_year,period_num ASC ;

		EXCEPTION
		WHEN others THEN
		fv_utility.log_mesg(fnd_log.level_exception,l_module_name||
                      'Error in getting next Open Period',SQLERRM);
		RETURN;

		END;
	ELSE
        p_accounting_date := p_accounting_date;

	END IF;  --- end of Closed Period

        EXCEPTION
		WHEN OTHERS THEN
		    fv_utility.log_mesg(fnd_log.level_exception,l_module_name,SQLERRM);

 END GET_OPEN_PERIOD;

 PROCEDURE CREATE_TREASURY_PAYMENT_EVENT
                                        (p_calling_sequence IN VARCHAR2
                                        ,p_event_type       IN VARCHAR2
                                        ,p_treasury_conf_id IN NUMBER
                                        ,x_status_code     OUT NOCOPY VARCHAR2
                                        ,x_return_status   OUT NOCOPY VARCHAR2)
 IS
  l_calling_sequence VARCHAR2(1000);
  l_module_name      VARCHAR2(200);

  l_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_reference_info XLA_EVENTS_PUB_PKG.T_EVENT_REFERENCE_INFO;

  CURSOR cur_get_payment_info(p_treasury_conf_id NUMBER) IS
  SELECT distinct ac.legal_entity_id, ftc.event_id
  FROM   ap_checks ac
        ,fv_treasury_confirmations ftc
  WHERE ftc.treasury_confirmation_id = p_treasury_conf_id
  AND   ftc.payment_instruction_id   = ac.payment_instruction_id
  AND   ac.org_id = g_org_id;

  CURSOR cur_get_void_info IS
  SELECT
      FVC.event_id,
      FTC.payment_instruction_id,
      FVC.check_id,
      FTC.treasury_confirmation_id
  FROM fv_voided_checks FVC,
       fv_treasury_confirmations_all FTC,
       ap_checks_all ac
  WHERE
  ftc.org_id = g_org_id
  AND FVC.org_id = ftc.org_id
  AND ac.org_id = FVC.org_id
  AND FTC.treasury_confirmation_id = p_treasury_conf_id
  AND FTC.payment_instruction_id  = ac.payment_instruction_id
  AND ac.check_id = fvc.check_id
  AND fvc.processed_flag = 'U'
  AND FTC.confirmation_status_flag = 'Y';


  CURSOR cur_void_acctg_date(l_check_id NUMBER) IS
  SELECT accounting_date
  FROM ap_invoice_payments_all
  WHERE check_id = l_check_id
  AND amount < 0
  GROUP BY check_id, accounting_date;

 l_event_status_code       VARCHAR2(1);
 l_pay_hist_id             AP_PAYMENT_HISTORY_ALL.payment_history_id%TYPE;
 l_check_id                NUMBER(15);
 l_check_number            NUMBER(15);
 l_legal_entity_id         NUMBER(15);
 l_batch                   NUMBER;
 l_errbuf                  VARCHAR2(1000);
 l_retcode                 NUMBER;
 l_api_message             VARCHAR2(1000);
 l_payment_instr_id        NUMBER(15);
 l_treas_conf_id           NUMBER(15);
 l_void_acctg_date         DATE;
 l_tc_event_id             NUMBER(15);
 l_void_event_id           NUMBER(15);
 l_pmt_id                  fv_treasury_confirmations_all.payment_instruction_id%TYPE;

 BEGIN
  l_calling_sequence := p_calling_sequence || ' -> FV_TREASURY_PAYMENTS_PKG.CREATE_TREASURY_PAYMENT_EVENT';
  l_module_name      := g_module_name||'Create_Treasury_Payment_Event';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                    'Calling Sequence: '||p_calling_sequence);
  END IF;

  --Set the reference info value based on event type
  IF p_event_type = 'TREASURY_CONFIRM' THEN
   l_reference_info.reference_char_1 := 'CONFIRM';
  ELSIF p_event_type = 'TREASURY_BACKOUT' THEN
   l_reference_info.reference_char_1 := 'BACKOUT';
  ELSIF p_event_type = 'TREASURY_VOID' THEN
    l_reference_info.reference_char_1 := 'VOID';
  ELSE
     l_reference_info.reference_char_1 := NULL;
  END IF;
  l_event_status_code := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;


  SELECT payment_instruction_id
  INTO
        l_pmt_id
  FROM  fv_treasury_confirmations ftc
  WHERE
   ftc.treasury_confirmation_id = p_treasury_conf_id;

  l_event_source_info.application_id        := 8901;
  l_event_source_info.ledger_id             := g_ledger_id;
  l_event_source_info.entity_type_code      := 'TREASURY_CONFIRMATION';
  l_event_source_info.transaction_number    := l_pmt_id; --p_treasury_conf_id;
  l_event_source_info.source_id_int_1       := p_treasury_conf_id;
  l_security_context.security_id_int_1      := g_org_id;

  IF p_event_type = 'TREASURY_CONFIRM' OR p_event_type = 'TREASURY_BACKOUT' THEN

     OPEN cur_get_payment_info(p_treasury_conf_id);
     FETCH cur_get_payment_info INTO l_legal_entity_id,l_tc_event_id;
     l_event_source_info.legal_entity_id       := l_legal_entity_id;

     IF XLA_EVENTS_PUB_PKG.event_exists
                    (p_event_source_info => l_event_source_info
                    ,p_event_type_code   => p_event_type
                    ,p_event_date        => g_accounting_date
                    ,p_event_status_code => l_event_status_code
                    ,p_event_number      => NULL
                    ,p_valuation_method  => NULL
                    ,p_security_context  => l_security_context) THEN

         IF (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,'Event exists! event_id =' || l_tc_event_id);
         END IF;

      --- call the xla_events_pub_pkg.get_array_event_info
         /*XLA_EVENTS_PUB_PKG.DELETE_EVENT(
             p_event_source_info => l_event_source_info,
             p_event_id => l_tc_event_id,
             p_valuation_method => NULL,
             p_security_context => l_security_context);

         IF (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'After delete '||l_tc_event_id);
         END IF;*/

     END IF;

     l_tc_event_id := NULL;

     l_tc_event_id := Xla_Events_Pub_Pkg.Create_Event
                    (
                      p_event_source_info => l_event_source_info,
                      p_event_type_code   => p_event_type,
                      p_event_date        => g_accounting_date,
                      p_event_status_code => l_event_status_code,
                      p_event_number      => NULL,
                      p_reference_info    => l_reference_info,
                      p_valuation_method  => NULL,
                      p_security_context  => l_security_context
--                      p_budgetary_control_flag => 'Y'
                     );

     IF FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Event ID: '||l_tc_event_id );
     END IF;

     IF l_tc_event_id is NULL THEN
           IF FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL THEN
                 FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'Event creation failed for: Treasury confirmation ID: '
                     || to_char(l_event_source_info.transaction_number));
           END IF;
           RAISE FND_API.g_exc_error;
     END IF;

     Insert into XLA_ACCT_PROG_EVENTS_GT (Event_Id)
     values (l_tc_Event_id);

      Update fv_treasury_confirmations_all
      Set event_id = l_tc_event_id
      Where treasury_confirmation_id = p_treasury_conf_id;

  ELSIF p_event_type = 'TREASURY_VOID' THEN
     OPEN cur_get_void_info;
     LOOP
         FETCH cur_get_void_info INTO l_void_event_id,
                                      l_payment_instr_id,
                                      l_check_id
                                     ,l_treas_conf_id;

         EXIT WHEN cur_get_void_info%NOTFOUND;


         OPEN cur_get_payment_info(l_treas_conf_id);
         FETCH cur_get_payment_info INTO l_tc_event_id, l_legal_entity_id;
         CLOSE cur_get_payment_info;

         l_event_source_info.legal_entity_id       := l_legal_entity_id;

         OPEN cur_void_acctg_date(l_check_id);
         FETCH cur_void_acctg_date INTO l_void_acctg_date;
         CLOSE cur_void_acctg_date;
	/*  Bug: 5727409 */

	 get_open_period(l_void_acctg_date);

/*
         IF XLA_EVENTS_PUB_PKG.event_exists
                    (p_event_source_info => l_event_source_info
                    ,p_event_type_code   => p_event_type
                    ,p_event_date        => l_void_acctg_date
                    ,p_event_status_code => l_event_status_code
                    ,p_event_number      => NULL
                    ,p_valuation_method  => NULL
                    ,p_security_context  => l_security_context) THEN

             IF (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,'Event exists! event_id =' || l_void_event_id);
             END IF;

             XLA_EVENTS_PUB_PKG.DELETE_EVENT(
               p_event_source_info => l_event_source_info,
               p_event_id => l_void_event_id,
               p_valuation_method => NULL,
               p_security_context => l_security_context);

             IF (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'After delete '||l_void_event_id);
             END IF;
          END IF;  */
         l_void_event_id := NULL;

         l_void_event_id := Xla_Events_Pub_Pkg.Create_Event
                    (
                      p_event_source_info => l_event_source_info,
                      p_event_type_code   => p_event_type,
                      p_event_date        => l_void_acctg_date,
                      p_event_status_code => l_event_status_code,
                      p_event_number      => NULL,
                      p_reference_info    => l_reference_info,
                      p_valuation_method  => NULL,
                      p_security_context  => l_security_context
--                      p_budgetary_control_flag => 'Y'
                     );

         IF FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Event ID: '||l_void_event_id );
         END IF;

        IF l_void_event_id is NULL THEN
           IF FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL THEN
                 FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'Event creation failed for: Treasury confirmation ID: '
                     || to_char(l_event_source_info.transaction_number)||'Check ID: '||l_check_id);
           END IF;
           RAISE FND_API.g_exc_error;
         END IF;

         INSERT INTO XLA_ACCT_PROG_EVENTS_GT (Event_Id)
         VALUES (l_void_Event_id);

         UPDATE fv_voided_checks
         SET event_id = l_void_event_id,
         payment_instruction_id = l_payment_instr_id
         WHERE  check_id = l_check_id
         AND org_id = g_org_id;

     END LOOP;
     CLOSE cur_get_void_info;

  END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_batch := NULL;
     l_errbuf:= NULL;
     l_retcode:= NULL;

     xla_accounting_pub_pkg.accounting_program_events
                    (p_application_id        => 8901
                     ,p_accounting_mode      => 'FINAL'
                     ,p_gl_posting_flag      => 'N'
                     ,p_accounting_batch_id  => l_batch
                     ,p_errbuf               => l_errbuf
                     ,p_retcode              => l_retcode
                    );

      IF l_retcode <> 0 THEN
           l_api_message := 'Error Accounting for Events in SLA';
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name ,
l_api_message);
           END IF;
           x_status_code := 'FAILURE';
           RAISE FND_API.g_exc_error;
      END IF;
      x_status_code := 'SUCCESS';

 EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
 END create_treasury_payment_event;

 PROCEDURE Void
 			   (X_errbuf        OUT NOCOPY VARCHAR2
              ,X_retcode       OUT NOCOPY VARCHAR2 )

 IS
  l_module_name          VARCHAR2(200);
--  l_group_id             NUMBER;
  l_err_code             NUMBER;
  l_err_stage            VARCHAR2(2000);
  l_reference1           gl_interface.reference1%TYPE;
  l_calling_sequence     VARCHAR2(2000);
  l_return_status        VARCHAR2(30);
  l_status_code          VARCHAR2(30);
  l_ledger_name          VARCHAR2(100);
  l_void_count           NUMBER;

 CURSOR cur_treas_conf
 IS
    SELECT max(fvtreas.TREASURY_CONFIRMATION_ID) TREASURY_CONFIRMATION_ID
    FROM   fv_voided_checks fvc , ap_checks_all apchk,fv_treasury_confirmations_all fvtreas
    WHERE
           apchk.org_id = g_org_id
    AND    apchk.org_id = fvtreas.org_id
    AND    apchk.check_id = fvc.check_id
    AND    apchk.payment_instruction_id = fvtreas.payment_instruction_id
    AND fvc.processed_flag = 'U'
    GROUP BY fvc.check_id;

treas_conf_rec cur_treas_conf%ROWTYPE;

 BEGIN
  fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'Start Of Void');

  l_module_name := g_module_name || 'Void';
  l_calling_sequence := 'FV_TREASURY_PAYMENTS_PKG.Void_Payments';
  l_reference1  := 'Void';

 IF g_org_id IS NULL THEN
     g_org_id := MO_GLOBAL.get_current_org_id;
     MO_UTILS.get_ledger_info(g_org_id, g_ledger_id, l_ledger_name);
 END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'INSERT INTO fv_voided_checks');
  END IF;

    BEGIN
    INSERT INTO fv_voided_checks
    (
      void_id,
      checkrun_name,
      check_id,
      processed_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    )
    SELECT fv_voided_checks_s.nextval,
           ac.checkrun_name,
           ac.check_id,
           'U',
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
           ac.org_id
      FROM ap_checks_all ac,
            fv_treasury_confirmations_all fvtc
      WHERE ac.org_id = g_org_id
      AND fvtc.org_id = ac.org_id
      AND fvtc.payment_instruction_id = ac.payment_instruction_id
       AND ac.void_date IS NOT NULL
       AND (ac.checkrun_name IS NOT NULL OR ac.payment_id IS NOT NULL)
       AND NOT EXISTS (SELECT 1
                        FROM fv_voided_checks fvc
                       WHERE fvc.check_id = ac.check_id
                         AND fvc.org_id = ac.org_id);

    EXCEPTION
    WHEN OTHERS THEN
      l_err_code := SQLCODE;
      l_err_stage := SQLERRM;
      X_retcode:=2;
      fv_utility.log_mesg(fnd_log.level_exception,l_module_name||' insert fv_voided_checks1',l_err_stage);
    END;

   l_status_code:='SUCCESS';

    OPEN cur_treas_conf ;
    LOOP
        FETCH cur_treas_conf INTO treas_conf_rec;
        EXIT WHEN (l_status_code <> 'SUCCESS' OR cur_treas_conf%NOTFOUND );

        l_status_code:='';

        l_void_count:=0;

           SELECT COUNT(ac.check_id) INTO l_void_count
           FROM   ap_checks_all ac
              ,fv_treasury_confirmations_all ftc
              , fv_voided_checks fvc
            WHERE ftc.treasury_confirmation_id = treas_conf_rec.TREASURY_CONFIRMATION_ID
                AND   ftc.payment_instruction_id   = ac.payment_instruction_id
                AND   ac.org_id                   =  g_org_id
                AND  ac.org_id                     = ftc.org_id
                AND   ac.void_date IS NOT NULL
                AND fvc.check_id = ac.check_id
                AND fvc.processed_flag = 'U';

        IF l_void_count <> 0 THEN
        create_treasury_payment_event(l_calling_sequence,
                                      'TREASURY_VOID',
                                      treas_conf_rec.TREASURY_CONFIRMATION_ID,
                                      l_status_code,
                                      l_return_status);

        BEGIN

           IF (l_status_code = 'SUCCESS') THEN

            UPDATE fv_voided_checks
               SET processed_flag = 'P'
             WHERE processed_flag = 'U'
               AND org_id = g_org_id
               and check_id in ( select check_id
                                 from fv_treasury_confirmations_all fvtreas  ,
                                      ap_checks_all ac
                                 where
                                 fvtreas.org_id = g_org_id
                                 and ac.org_id = fvtreas.org_id
                                 and fvtreas.treasury_confirmation_id = treas_conf_rec.TREASURY_CONFIRMATION_ID
                                 and fvtreas.payment_instruction_id = ac.payment_instruction_id
                                 and ac.void_date is not null
                                 );
            END IF;

         EXCEPTION
                WHEN OTHERS THEN
                      l_err_code := SQLCODE;
                      l_err_stage := SQLERRM;
                      fv_utility.log_mesg(fnd_log.level_exception,l_module_name||
                      'update fv_voided_checks1',l_err_stage);
        END;
     ELSE
        l_status_code:='SUCCESS';
     END IF ;

    END LOOP;
    CLOSE cur_treas_conf ;
/*
    BEGIN
        IF (l_status_code = 'SUCCESS') THEN
            UPDATE fv_voided_checks
               SET processed_flag = 'P'
             WHERE processed_flag = 'U'
               AND org_id = g_org_id;
        ELSE
            UPDATE fv_voided_checks
               SET processed_flag = 'X'
             WHERE processed_flag = 'U'
               AND org_id = g_org_id;

        END IF;
     EXCEPTION
            WHEN OTHERS THEN
              l_err_code := SQLCODE;
              l_err_stage := SQLERRM;
              fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'update fv_voided_checks1',l_err_stage);
    END;
*/

fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'End Of Void');
X_retcode:=0;
 END Void;


END FV_TREASURY_PAYMENTS_PKG;


/
