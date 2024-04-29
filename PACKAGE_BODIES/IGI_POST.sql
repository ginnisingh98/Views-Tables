--------------------------------------------------------
--  DDL for Package Body IGI_POST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_POST" AS
-- $Header: igipostb.pls 120.2.12000000.3 2007/09/21 07:49:49 pshivara ship $
--

  PROCEDURE IGI_POST_GL_POSTING(P_POSTING_RUN_ID  IN  NUMBER) IS

  	CURSOR C1(P_RUN_ID IN NUMBER) IS
  	SELECT JE_BATCH_ID,
               BUDGETARY_CONTROL_STATUS,
               STATUS
  	FROM   GL_JE_BATCHES
  	WHERE  POSTING_RUN_ID = P_RUN_ID;

  	CURSOR C2(P_JE_BATCH_ID IN NUMBER)  IS
  	SELECT	  JE_HEADER_ID
               -- , SET_OF_BOOKS_ID  -- bug 6315298
		, LEDGER_ID  -- bug 6315298
		, BUDGET_VERSION_ID
		, CURRENCY_CODE
		, PERIOD_NAME
		, STATUS
		, JE_SOURCE
		, JE_CATEGORY
	FROM	  GL_JE_HEADERS
	WHERE	  JE_BATCH_ID = P_JE_BATCH_ID;

	l_posting_run_id	GL_JE_BATCHES.POSTING_RUN_ID%TYPE;
	l_je_batch_id		GL_JE_BATCHES.JE_BATCH_ID%TYPE;
        l_ItrStatus_Flag        VARCHAR2(1);
        l_ItrErrorNum           NUMBER;


BEGIN
  BEGIN  -- BUD
    IF IGI_GEN.IS_REQ_INSTALLED('BUD') THEN
      l_posting_run_id := P_POSTING_RUN_ID;

      FOR cont1 IN C1(l_posting_run_id) LOOP
	l_je_batch_id  := cont1.je_batch_id;

	FOR cont2 IN C2(l_je_batch_id) LOOP

	  -- This replaces trigger IGI_BUD_GL_JE_HEADERS_T1
	  IF cont2.status 	= 'P' AND
	     cont2.je_source   	= 'MassAllocation' AND
	     cont2.je_category 	= 'Budget' THEN

	    UPDATE  GL_JE_LINES
	    SET     REFERENCE_1  = 'IGIGBUDMB'
		  , REFERENCE_2  = JE_HEADER_ID+JE_LINE_NUM
		  , REFERENCE_6  = 'N'
	    WHERE  JE_HEADER_ID = cont2.je_header_id;

	  END IF;

	  -- This replaces trigger IGI_BUD_GL_JE_HEADERS_T2
	  IF cont2.status = 'P' AND
	     cont2.budget_version_id is not null THEN

	    IGI_BUD.BUD_NEXT_YEAR_BUDGET(
			  CONT2.JE_HEADER_ID
			-- , CONT2.SET_OF_BOOKS_ID  -- bug 6315298
                        , CONT2.LEDGER_ID           -- bug 6315298
			, CONT2.BUDGET_VERSION_ID
			, CONT2.CURRENCY_CODE
			, CONT2.PERIOD_NAME);
	  END IF;
	END LOOP;	-- cont2
      END LOOP;		-- cont1

    END IF; -- BUD Installed Check

    EXCEPTION

    WHEN others THEN
      raise_application_error (-20000,'Error in BUD in IGI_POST');

    END; -- BUD


    BEGIN   --ITR
       IGI_GEN.get_option_status('ITR',l_ItrStatus_Flag,l_ItrErrorNum);

       IF l_ItrStatus_Flag = 'Y' THEN
           l_posting_run_id := P_POSTING_RUN_ID;
            FOR Cont3 in C1 (l_posting_run_id) LOOP
                l_je_batch_id := Cont3.je_batch_id;
                   -- This replaces trigger IGI_IGI_ITR_GL_JE_BATCHES_T1
                   IF Cont3.Status NOT IN ('S','U','I') and
                      Cont3.Budgetary_Control_Status IN ('F','P','N','R') THEN

                      IGI_ITR.Action(1);
                      IGI_ITR.Set_Batches(l_je_batch_id);
                   ELSE

                      IGI_ITR.Action(0);
                   END IF;


                   -- This replaces trigger IGI_IGI_GL_JE_BATCHES_T2
                   IGI_ITR.Process_Batches;
            END LOOP;  -- Cont3
                 --    IGI_ITR.Process_Batches;

       END IF; -- ITR INSTALLED CHECK


    EXCEPTION
        WHEN no_data_found THEN
           null;

        WHEN Others THEN
           raise_application_error (-20000, 'Error in ITR in IGI_POST');

    END; -- ITR

 END;
END IGI_POST;

/
