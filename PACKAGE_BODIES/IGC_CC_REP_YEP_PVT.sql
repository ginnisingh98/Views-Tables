--------------------------------------------------------
--  DDL for Package Body IGC_CC_REP_YEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_REP_YEP_PVT" AS
/*$Header: IGCCPRVB.pls 120.7.12000000.10 2007/12/06 15:02:03 bmaddine ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_REP_YEP_PVT';

  -- The flag determines whether to print debug information or not.
  l_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  --g_debug_flag        VARCHAR2(1) := 'N' ;
  g_line_num          NUMBER := 0;
  l_state_level number;
  l_debug_level number;

/*==================================================================================
                                 Procedure  INVOICE_CANC_OR_APPROVED
  =================================================================================*/
-- bug 2098010 ssmales - added p_process_type parameter to function below
FUNCTION invoice_canc_or_approved(p_cc_header_id NUMBER, p_process_type VARCHAR2)
RETURN BOOLEAN
IS
	l_count            NUMBER := 0;
	l_appr_count       NUMBER := 0;
	l_canc_count       NUMBER := 0;
	l_dist_count       NUMBER := 0;
	l_appr_dist_count  NUMBER := 0;

	l_invoice_id       ap_invoices_all.invoice_id%TYPE;
	l_cancelled_date   ap_invoices_all.cancelled_date%TYPE;

	CURSOR c_invoices(p_cc_header_id NUMBER)
        IS
		SELECT  unique apid.invoice_id
		FROM
 			ap_invoice_distributions_all apid,
        		po_distributions_all pod,
        		po_headers_all phh,
        		igc_cc_headers cch
		WHERE
			apid.po_distribution_id    = pod.po_distribution_id AND
			pod.po_header_id           = phh.po_header_id AND
			phh.org_id                 = cch.org_id AND
			phh.type_lookup_code       = 'STANDARD' AND
			phh.segment1               = cch.cc_num AND
			cch.cc_header_id           = p_cc_header_id;
BEGIN
	l_count := 0;

	l_canc_count := 0;
	l_appr_count := 0;

	OPEN c_invoices(p_cc_header_id);
	LOOP
		FETCH c_invoices INTO l_invoice_id;
		EXIT WHEN c_invoices%NOTFOUND;

		l_count := l_count + 1;

		l_cancelled_date := NULL;

		SELECT    cancelled_date
	        INTO      l_cancelled_date
		FROM      ap_invoices_all
		WHERE     invoice_id = l_invoice_id;

                IF (l_cancelled_date IS NOT NULL)
		THEN
			l_canc_count := l_canc_count + 1;
		ELSE

			l_dist_count      := 0;
			l_appr_dist_count := 0;

			BEGIN
				SELECT count(invoice_distribution_id)
				INTO l_dist_count
				FROM
					ap_invoice_distributions_all
				WHERE   invoice_id = l_invoice_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_dist_count := 0;
			END;

-- bug 2098010 ssmales - added if statement below to exec existing block only if proc_type is 'R'
                        IF p_process_type = 'R' THEN

			BEGIN
				SELECT count(invoice_distribution_id)
				INTO l_appr_dist_count
				FROM
					ap_invoice_distributions_all
				WHERE   invoice_id                     = l_invoice_id   AND
                               		 NVL(match_status_flag,'X')     = 'A'            AND
                                	NVL(exchange_rate_variance,0)  = 0;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_appr_dist_count := 0;
			END;
-- bug 2098010 ssmales - start - block below added for when proc_type is 'F'

                        ELSE     --p_process_type = 'F'

                        BEGIN
                               SELECT count(invoice_distribution_id)
                               INTO l_appr_dist_count
                               FROM
                                       ap_invoice_distributions_all
                               WHERE   invoice_id                  = l_invoice_id  AND
                                       NVL(match_status_flag, 'X') = 'A' ;
                        EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                        l_appr_dist_count := 0;
                        END;

                        END IF;
-- bug 2098010 ssmales - end


			IF (l_dist_count = l_appr_dist_count)
			THEN
				l_appr_count := l_appr_count + 1;

			END IF;

		END IF;


	END LOOP;
	CLOSE c_invoices;

	IF (l_count = l_appr_count + l_canc_count)
	THEN
		RETURN(FALSE);
	ELSE
		RETURN(TRUE);
	END IF;

END invoice_canc_or_approved;

/*==================================================================================
                                 Procedure LOCK_CC
  =================================================================================*/


FUNCTION LOCK_CC(p_cc_header_id  IN NUMBER)
RETURN BOOLEAN AS

CURSOR C(p_cc_header_id NUMBER) IS
          SELECT *
          FROM   IGC_CC_HEADERS
          WHERE
          	CC_HEADER_ID    = p_CC_HEADER_ID
          FOR UPDATE
	  NOWAIT;

V       C%ROWTYPE;
l_ERROR NUMBER;

BEGIN
    OPEN C(P_CC_HEADER_ID);
         FETCH C INTO V;
         IF    C%NOTFOUND
         THEN  RETURN FALSE;
         ELSE  RETURN TRUE;
         END IF;
    CLOSE C;

EXCEPTION
WHEN OTHERS
THEN
    l_ERROR := SQLCODE;
    IF l_ERROR = -54
    THEN
         RETURN FALSE;
    END IF;


END LOCK_CC;

/*==================================================================================
                            End of Procedure LOCK_CC
  =================================================================================*/



/*==================================================================================
                             Procedure LOCK_PO
  =================================================================================*/


FUNCTION LOCK_PO( p_cc_header_id NUMBER)
RETURN BOOLEAN AS

CURSOR CC(P_CC_HEADER_ID NUMBER) IS
           SELECT  'Y'
           FROM    PO_HEADERS_ALL A
           WHERE
		 A.PO_HEADER_ID =  (SELECT C.PO_HEADER_ID
                           	    FROM   IGC_CC_HEADERS B,
					   PO_HEADERS_ALL C
                           	    WHERE  B.ORG_ID            =  C.ORG_ID    AND
			                   B.CC_NUM            =  C.SEGMENT1  AND
					   C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
					   B.CC_HEADER_ID      = P_CC_HEADER_ID);
CURSOR CC1(P_CC_HEADER_ID NUMBER) IS
           SELECT  'Y'
           FROM    PO_HEADERS_ALL A
           WHERE
		 A.PO_HEADER_ID =  (SELECT C.PO_HEADER_ID
                           	    FROM   IGC_CC_HEADERS B,
					   PO_HEADERS_ALL C
                           	    WHERE  B.ORG_ID            =  C.ORG_ID    AND
			                   B.CC_NUM            =  C.SEGMENT1  AND
					   C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
					   B.CC_HEADER_ID      = P_CC_HEADER_ID)
           FOR UPDATE
	   NOWAIT;

VV      CC%ROWTYPE;
VV1     CC1%ROWTYPE;
l_ERROR NUMBER;

BEGIN
    	 OPEN CC(P_CC_HEADER_ID);
         FETCH CC INTO VV;
         IF    CC%NOTFOUND
         THEN
    		CLOSE CC;
		RETURN TRUE;
         ELSE
		OPEN CC1(P_CC_HEADER_ID);
		FETCH CC1 INTO VV1;
		IF CC1%NOTFOUND
		THEN
			CLOSE CC;
			CLOSE CC1;
			RETURN FALSE;
		ELSE
			CLOSE CC;
			CLOSE CC1;
			RETURN TRUE;
		END IF;
	END IF;
EXCEPTION
     WHEN OTHERS
     THEN
        l_ERROR := SQLCODE;
        IF l_ERROR = -54
        THEN
             RETURN FALSE;
        END IF;

END LOCK_PO;

/*==================================================================================
                            End of Procedure LOCK_PO
  =================================================================================*/


/*==================================================================================
                             Procedure VALIDATE_CC
  =================================================================================*/



FUNCTION VALIDATE_CC( p_CC_HEADER_ID   IN   NUMBER,
                      p_PROCESS_TYPE   IN   VARCHAR2,
                      p_PROCESS_PHASE  IN   VARCHAR2,
                      p_YEAR           IN   NUMBER,
                      p_SOB_ID         IN   NUMBER,
                      p_ORG_ID         IN   NUMBER,
                      p_PROV_ENC_ON    IN   BOOLEAN,
                      p_REQUEST_ID     IN   NUMBER)
RETURN VARCHAR2 AS

CURSOR C3 IS
          SELECT  *
          FROM    IGC_CC_HEADERS
          WHERE   IGC_CC_HEADERS.CC_HEADER_ID = p_CC_HEADER_ID;

CURSOR C4(HEADER_ID NUMBER) IS
          SELECT  *
          FROM    IGC_CC_ACCT_LINES
          WHERE   IGC_CC_ACCT_LINES.CC_HEADER_ID = HEADER_ID;

CURSOR C5(ACCT_LINE_ID NUMBER) IS
          SELECT  *
          FROM    IGC_CC_DET_PF_V
          WHERE   IGC_CC_DET_PF_V.CC_ACCT_LINE_ID  = ACCT_LINE_ID;

CURSOR C9 IS
          SELECT *
          FROM   IGC_CC_HEADERS
          WHERE  PARENT_HEADER_ID IN ( SELECT A.PARENT_HEADER_ID
                                       FROM   IGC_CC_HEADERS A , IGC_CC_HEADERS B
                                       WHERE  A.PARENT_HEADER_ID  = B.CC_HEADER_ID
                                       AND    A.PARENT_HEADER_ID  = p_CC_HEADER_ID);


v3                            C3%ROWTYPE;
V4                            C4%ROWTYPE;
V5                            C5%ROWTYPE;
V9                            C9%ROWTYPE;
l_INVOICE_STATUS              BOOLEAN;
l_PERIOD_COUNTER              NUMBER := 0;
l_STATUS_COUNTER              NUMBER :=0;
l_CC_APPROVAL_STATUS          IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE;
l_OVERBILLED_COUNTER          NUMBER := 0;
l_COUNTER                     NUMBER :=0;
l_PROCESS_TYPE                VARCHAR2(25);
l_STATE                       IGC_CC_HEADERS.CC_STATE%TYPE;
l_PREVIOUS_APPRVL_STATUS      IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE;
l_DUMMY                       VARCHAR2(1);
l_EXCEPTION                   igc_cc_process_exceptions.exception_reason%TYPE := NULL;

BEGIN

         IF     p_PROCESS_TYPE = 'Y'
         THEN
                l_PROCESS_TYPE := 'YEAR-END PROCESS';
         ELSIF  p_PROCESS_TYPE = 'R'
         THEN
                l_PROCESS_TYPE := 'REVALUATION PROCESS';
         ELSIF  p_PROCESS_TYPE = 'F'
         THEN
                l_PROCESS_TYPE := 'REVALUATION FIX PROCESS';
         END IF;

/*************************************** Start of VALIDATE_CC Procedure *****************************************/
    OPEN C3;
          LOOP
             FETCH C3 INTO V3;    /* Fetch Contracts based upon CC_HEADER_ID */
             EXIT WHEN C3%NOTFOUND;

               /**** Preliminary Mode and Final Mode Validation For STANDARD CC****/

              IF      p_PROCESS_TYPE IN ('Y','R','F') AND
                     (p_PROCESS_PHASE  = 'P'OR p_PROCESS_PHASE = 'F') AND
                      V3.CC_TYPE = 'S'
              THEN

                         /* Revaluation Validation */
                 IF p_PROCESS_TYPE = 'R' OR p_PROCESS_TYPE = 'F'
                 THEN
                     IF   ( ( (v3.cc_state = 'PR') AND (p_prov_enc_on = TRUE) ) OR
                            (v3.cc_state = 'CM') OR
                            ( ((v3.cc_state = 'CL') AND (p_prov_enc_on = TRUE)) AND (v3.cc_apprvl_status <> 'AP')) OR
                            ( (v3.cc_state = 'CT') AND (v3.cc_apprvl_status <> 'AP'))
                          )
                          AND V3.CC_ENCMBRNC_STATUS = 'N'
                     THEN
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_NOT_FULLY_ENC');
                          FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                          l_EXCEPTION := FND_MESSAGE.GET;

				INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
				(PROCESS_TYPE ,
				PROCESS_PHASE,
				CC_HEADER_ID,
				CC_ACCT_LINE_ID ,
				CC_DET_PF_LINE_ID,
				EXCEPTION_REASON,
				ORG_ID,
				SET_OF_BOOKS_ID,
				REQUEST_ID)
				VALUES (p_PROCESS_TYPE,
				p_PROCESS_PHASE,
				V3.CC_HEADER_ID,
				NULL,
				NULL,
				l_EXCEPTION,
				V3.ORG_ID,
				V3.SET_OF_BOOKS_ID,
				p_REQUEST_ID);
                            RETURN 'F';

                      END IF;

-- bug 2098010 ssmales - added p_process_type argument to function call below
                      l_INVOICE_STATUS := IGC_CC_REP_YEP_PVT.INVOICE_CANC_OR_APPROVED(V3.CC_HEADER_ID,
                                                                                      p_PROCESS_TYPE);

                      IF     l_INVOICE_STATUS =  TRUE
                      THEN
                             l_EXCEPTION := NULL;
                             FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_INVOICE_PAID_OR_CAN');
                             FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                             l_EXCEPTION := FND_MESSAGE.GET;

--                             INSERT INTO IGC_CC_PROCESS_EXCEPTIONS VALUES(
				INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
				(PROCESS_TYPE ,
				PROCESS_PHASE,
				CC_HEADER_ID,
				CC_ACCT_LINE_ID ,
				CC_DET_PF_LINE_ID,
				EXCEPTION_REASON,
				ORG_ID,
				SET_OF_BOOKS_ID,
				REQUEST_ID)
				VALUES (
							       p_PROCESS_TYPE,
							       p_PROCESS_PHASE,
							       V3.CC_HEADER_ID,
							       NULL,
							       NULL,
							       l_EXCEPTION,
							       V3.ORG_ID,
							       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);

                              RETURN 'F';

                      END IF;

                      IF    V3.CC_STATE = 'CM' AND V3.CC_APPRVL_STATUS = 'IN'
                      THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_REP_CM_INCOMPLETE');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

--                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS VALUES(p_PROCESS_TYPE,
                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                          RETURN 'F';
                     END IF;

                     IF    p_PROCESS_TYPE = 'R'
                     THEN
                          IF     IGC_CC_REVAL_FIX_PROCESS_PKG.REVALUE_FIX(V3.CC_HEADER_ID)
                          THEN
                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_HAS_REV_VARIANCES');
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                          	RETURN 'F';
                          END IF;
                      END IF;
                   END IF;
                             /* End of Revaluation Validation */


                            /* Fully Encumbrance check for YEAR END PROCESS  */

                      IF    p_PROCESS_TYPE = 'Y'
                      THEN
                            IF   ( ( (v3.cc_state = 'PR') AND (p_prov_enc_on = TRUE) ) OR
                                   (v3.cc_state = 'CM') OR
                                   ( ( (v3.cc_state = 'CL') AND (p_prov_enc_on = TRUE) ) AND (v3.cc_apprvl_status <> 'AP')) OR
                                   ( (v3.cc_state = 'CT') AND (v3.cc_apprvl_status <> 'AP'))
                                  )
                                  AND V3.CC_ENCMBRNC_STATUS = 'N'
                            THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_NOT_FULLY_ENC');
                                  FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                                   RETURN 'F';

                            END IF;
                      END IF;

                                /* END OF Fully Encumbrance check for YEAR END PROCESS  */


                     IF    V3.CC_STATE = 'PR' AND V3.CC_APPRVL_STATUS = 'IP'
                     THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_PR_INPROCESS');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

                                                     INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                          RETURN 'F';
                     END IF;

                     IF    V3.CC_STATE = 'CL' AND V3.CC_APPRVL_STATUS = 'IP'
                     THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CL_INPROCESS');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

                                                     INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                          p_PROCESS_PHASE,
                                                                          V3.CC_HEADER_ID,
                                                                          NULL,
                                                                          NULL,
                                                                          l_EXCEPTION,
                                                                          V3.ORG_ID,
                                                                          V3.SET_OF_BOOKS_ID,
                                                                          p_REQUEST_ID);
                            RETURN 'F';
                      END IF;

                      /* Over Billed Amount Validation for Standard CC in Cancelled State */

                     IF    V3.CC_STATE = 'CL' AND V3.CC_APPRVL_STATUS <>'IP'
                     THEN
                           l_OVERBILLED_COUNTER := 0;
                           OPEN C4(V3.CC_HEADER_ID);   /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                 LOOP
                                    FETCH C4 INTO V4;
                                    EXIT WHEN C4%NOTFOUND;
                                    OPEN C5(V4.CC_ACCT_LINE_ID);
                                          /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                          LOOP
                                             FETCH C5 INTO V5;
                                             EXIT WHEN C5%NOTFOUND;
                                             IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                             THEN
                                                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                   FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                                                   FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                   FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                   l_EXCEPTION := FND_MESSAGE.GET;

                                                                             INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                                            p_PROCESS_PHASE,
                                                                                            p_CC_HEADER_ID,
                                                                                            V5.CC_ACCT_LINE_ID,
                                                                                            V5.CC_DET_PF_LINE_ID,
                                                                                            l_EXCEPTION,
                                                                                            V3.ORG_ID,
                                                                                            V3.SET_OF_BOOKS_ID,
                                                                                            p_REQUEST_ID);

                                                    l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;

                                               END IF;
                                            END LOOP; /* End of Loop for Cursor C5 */
                                     CLOSE C5;
                                  END LOOP;   /* End of Loop for Cursor C4 */
                             CLOSE C4;

                         IF     l_OVERBILLED_COUNTER > 0
                         THEN
                                RETURN 'F';
                         END IF;

                     END IF;


                    IF    V3.CC_STATE = 'CM' AND V3.CC_APPRVL_STATUS = 'IP'
                    THEN
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CM_INPROCESS');
                          FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                          FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                          l_EXCEPTION := FND_MESSAGE.GET;

                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                             p_PROCESS_PHASE,
                                             V3.CC_HEADER_ID,
                                             NULL,
                                             NULL,
                                             l_EXCEPTION,
                                             V3.ORG_ID,
                                             V3.SET_OF_BOOKS_ID,
                                             p_REQUEST_ID);

                          RETURN 'F';
                    END IF;

                    IF    V3.CC_STATE = 'CM' AND V3.CC_APPRVL_STATUS <> 'IP'
                    THEN
                          l_OVERBILLED_COUNTER := 0;
                          OPEN C4(V3.CC_HEADER_ID);  /* Over Billed Amount Validation for Standard CC */
                                /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                LOOP
                                   FETCH C4 INTO V4;
                                   EXIT WHEN C4%NOTFOUND;

                                   OPEN C5(V4.CC_ACCT_LINE_ID);
                                         /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                         LOOP
                                            FETCH C5 INTO V5;
                                            EXIT WHEN C5%NOTFOUND;

                                            IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                            THEN
                                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                  FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                                                  FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                  FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                                                p_PROCESS_PHASE,
                                                                                                p_CC_HEADER_ID,
                                                                                                V5.CC_ACCT_LINE_ID,
                                                                                                V5.CC_DET_PF_LINE_ID,
                                                                                                l_EXCEPTION,
                                                                                                V3.ORG_ID,
                                                                                                V3.SET_OF_BOOKS_ID,
                                                                                                p_REQUEST_ID);

                                                   l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;

                                             END IF;
                                          END LOOP; /* End of Loop for Cursor C5 */
                                    CLOSE C5;
                                 END LOOP;   /* End of Loop for Cursor C4 */
                            CLOSE C4;

                         IF     l_OVERBILLED_COUNTER > 0
                         THEN
                                RETURN 'F';
                         END IF;

                    END IF;


                    IF    V3.CC_STATE = 'CT' AND V3.CC_APPRVL_STATUS = 'IP'
                    THEN
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CT_INPROCESS');
                          FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                          FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                          l_EXCEPTION := FND_MESSAGE.GET;

                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                         p_PROCESS_PHASE,
                                                                         V3.CC_HEADER_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         l_EXCEPTION,
                                                                         V3.ORG_ID,
                                                                         V3.SET_OF_BOOKS_ID,
                                                                         p_REQUEST_ID);
                          RETURN 'F';
                     END IF;

                     IF    V3.CC_STATE = 'CT' AND V3.CC_APPRVL_STATUS <> 'IP'
                     THEN
                           l_OVERBILLED_COUNTER := 0;
                           OPEN C4(V3.CC_HEADER_ID);   /* Over Billed Amount Validation for Standard CC */
                                 /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                 LOOP
                                    FETCH C4 INTO V4;
                                   EXIT WHEN C4%NOTFOUND;

                                    OPEN C5(V4.CC_ACCT_LINE_ID);
                                          /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                          LOOP
                                             FETCH C5 INTO V5;
                                             EXIT WHEN C5%NOTFOUND;

                                             IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                             THEN
                                                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                   FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                                                   FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                   FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                   l_EXCEPTION := FND_MESSAGE.GET;

                                                                             INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                                                p_PROCESS_PHASE,
                                                                                                p_CC_HEADER_ID,
                                                                                                V5.CC_ACCT_LINE_ID,
                                                                                                V5.CC_DET_PF_LINE_ID,
                                                                                                l_EXCEPTION,
                                                                                                V3.ORG_ID,
                                                                                                V3.SET_OF_BOOKS_ID,
                                                                                                p_REQUEST_ID);

                                                   l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;
                                              END IF;
                                          END LOOP; /* End of Loop for Cursor C5 */
                                    CLOSE C5;
                                END LOOP;   /* End of Loop for Cursor C4 */
                           CLOSE C4;

                           IF     l_OVERBILLED_COUNTER > 0
                           THEN
                                RETURN 'F';
                           END IF;
                     END IF;

               RETURN 'P';  /* if all IF Statements failed then Validation Status is Passed */
            END IF;
        END LOOP;           /*  End of Loop for Cursor C3 */
    CLOSE C3;               /* End Of Cursor C3 */


/********************** End of Preliminary and Final Mode Validation For STATNDARD CC ***********************/




/***************Validation Check for Cover and Release CC For Both Preliminary And Final Mode ***************/


     OPEN C3;
         LOOP
            FETCH C3 INTO V3;
            EXIT WHEN C3%NOTFOUND;

          IF       p_PROCESS_TYPE IN ('Y','R','F') AND
                       (p_PROCESS_PHASE  = 'P' OR p_PROCESS_PHASE = 'F') AND
                       V3.CC_TYPE = 'R'
              THEN
                       RETURN 'F';
              END IF;



          IF   p_PROCESS_TYPE IN ('Y','R','F') AND
               (p_PROCESS_PHASE  = 'P' OR p_PROCESS_PHASE = 'F') AND
               V3.CC_TYPE = 'C'
          THEN

                              /* Revaluation Validation */

              IF   p_PROCESS_TYPE = 'R' OR p_PROCESS_TYPE = 'F'
              THEN

                IF   ( ( (v3.cc_state = 'PR') AND (p_prov_enc_on = TRUE) ) OR
                       (v3.cc_state = 'CM') OR
                       ( ( (v3.cc_state = 'CL') AND (p_prov_enc_on = TRUE) ) AND (v3.cc_apprvl_status <> 'AP')) OR
                       ( (v3.cc_state = 'CT') AND (v3.cc_apprvl_status <> 'AP'))
                     )
                     AND V3.CC_ENCMBRNC_STATUS = 'N'
                THEN
                     l_EXCEPTION := NULL;
                     FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_NOT_FULLY_ENC');
                     FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                     l_EXCEPTION := FND_MESSAGE.GET;

                                               INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                   p_PROCESS_PHASE,
                                                                   V3.CC_HEADER_ID,
                                                                   NULL,
                                                                   NULL,
                                                                   l_EXCEPTION,
                                                                   V3.ORG_ID,
                                                                   V3.SET_OF_BOOKS_ID,
                                                                   p_REQUEST_ID);
                      RETURN 'F';

                END IF;

-- bug 2098010 ssmales - added p_process_type argument to function call below
                l_INVOICE_STATUS := IGC_CC_REP_YEP_PVT.INVOICE_CANC_OR_APPROVED(V3.CC_HEADER_ID,
                                                                                p_PROCESS_TYPE);

                IF     l_INVOICE_STATUS =  TRUE
                THEN
                       l_EXCEPTION := NULL;
                       FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_INVOICE_PAID_OR_CAN');
                       FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                       l_EXCEPTION := FND_MESSAGE.GET;

                                                 INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                       RETURN 'F';

                END IF;

                 IF    V3.CC_STATE = 'CM' AND V3.CC_APPRVL_STATUS = 'IN'
                      THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_REP_CM_INCOMPLETE');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

                                                     INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                          RETURN 'F';
                     END IF;

             END IF;
                            /* End Revaluation Validation */


               /*************** Checking Release Validation for each selected Cover CC *****/

                 OPEN C9;
                      LOOP
                        FETCH C9 INTO V9;
                        EXIT WHEN C9%NOTFOUND;

                              /* Revaluation Validation at Releaese Level*/

                         IF   p_PROCESS_TYPE = 'R' OR p_PROCESS_TYPE = 'F'
                         THEN

                            IF   ( ( (v9.cc_state = 'PR') AND (p_prov_enc_on = TRUE) ) OR
                                   (v9.cc_state = 'CM') OR
                                   ( ( (v9.cc_state = 'CL') AND (p_prov_enc_on = TRUE) ) AND (v9.cc_apprvl_status <> 'AP')) OR
                                   ( (v9.cc_state = 'CT') AND (v9.cc_apprvl_status <> 'AP'))
                                 )
                                 AND V9.CC_ENCMBRNC_STATUS = 'N'
                            THEN
                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_NOT_FULLY_ENC');
                                 FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V9.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);

                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                 FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                 FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);


                                  l_COUNTER := l_COUNTER + 1;
                            END IF;

-- bug 2098010 ssmales - added p_process_type argument to function call below
                            l_INVOICE_STATUS := IGC_CC_REP_YEP_PVT.INVOICE_CANC_OR_APPROVED(V9.CC_HEADER_ID,
                                                                                            p_PROCESS_TYPE);

                            IF     l_INVOICE_STATUS =  TRUE
                            THEN
                                   l_EXCEPTION := NULL;
                                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_INVOICE_PAID_OR_CAN');
                                   FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                   l_EXCEPTION := FND_MESSAGE.GET;

                                                             INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V9.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);

                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                 FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                 FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);


                                  l_COUNTER := l_COUNTER + 1;
                            END IF;

                             IF    V9.CC_STATE = 'CM' AND V9.CC_APPRVL_STATUS = 'IN'
                             THEN
                                   l_EXCEPTION := NULL;
                                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_REP_CM_INCOMPLETE');
                                   FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                   FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                                   l_EXCEPTION := FND_MESSAGE.GET;

                                                             INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);

                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                  FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);


                                   l_COUNTER := l_COUNTER + 1;

                             END IF;

                             IF    p_PROCESS_TYPE = 'R'
                             THEN
                                   IF     IGC_CC_REVAL_FIX_PROCESS_PKG.REVALUE_FIX(V9.CC_HEADER_ID)
                                   THEN

                                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                                       p_PROCESS_PHASE,
                                                                                       V9.CC_HEADER_ID,
                                                                                       NULL,
                                                                                       NULL,
                                                                                      'Contract Commitment has Revaluation Variances',
                                                                                       V3.ORG_ID,
                                                                                       V3.SET_OF_BOOKS_ID,
                                                                                       p_REQUEST_ID);
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                  FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);


                                   l_COUNTER := l_COUNTER + 1;


                                   END IF;
                             END IF;


                          END IF;
                                     /* End of Revaluation Validation at Release Level*/


                          IF    V9.CC_STATE = 'PR' AND V9.CC_APPRVL_STATUS = 'IP'
                          THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_PR_INPROCESS');
                                  FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V9.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                  FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);

                            	  IF p_PROCESS_TYPE = 'Y'
                                  THEN
                                  	UPDATE  IGC_CC_PROCESS_DATA A
                                         SET     VALIDATION_STATUS      =   'F'
                                  	WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                  	AND     A.REQUEST_ID           =   p_REQUEST_ID
                                  	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                  	AND     A.ORG_ID               =   p_ORG_ID
                                  	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
  				  END IF;

                                  l_COUNTER := l_COUNTER + 1;

                            END IF;

                            IF    V9.CC_STATE = 'PR' AND V9.CC_APPRVL_STATUS <> 'IP'
                            THEN
                                 IF  p_PROCESS_PHASE = 'F'
                                 THEN
                            	  	IF p_PROCESS_TYPE = 'Y'
                                  	THEN
                                       		UPDATE  IGC_CC_PROCESS_DATA A
                                       		SET     VALIDATION_STATUS      =   'P'
                                       		WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                       		AND     A.REQUEST_ID           =   p_REQUEST_ID
                                       		AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                       		AND     A.ORG_ID               =   p_ORG_ID
                                       		AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;

                                       		UPDATE IGC_CC_HEADERS
                                       		SET    CC_APPRVL_STATUS             = 'IP'
                                       		WHERE  IGC_CC_HEADERS.CC_HEADER_ID  =  V9.CC_HEADER_ID;
					END IF;

                                  END IF;

                                 IF    p_PROCESS_PHASE = 'P'
                                 THEN
                            	  	IF p_PROCESS_TYPE = 'Y'
                                  	THEN
                                       		UPDATE  IGC_CC_PROCESS_DATA A
                                       		SET     VALIDATION_STATUS      =   'P'
                                       		WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                       		AND     A.REQUEST_ID           =   p_REQUEST_ID
                                       		AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                       		AND     A.ORG_ID               =   p_ORG_ID
                                       		AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
					END IF;
                                 END IF;
                            END IF;

                            IF    V9.CC_STATE = 'CL' AND V9.CC_APPRVL_STATUS = 'IP'
                            THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CL_INPROCESS');
                                  FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V9.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                  FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                               p_PROCESS_PHASE,
                                               V3.CC_HEADER_ID,
                                               NULL,
                                               NULL,
                                               l_EXCEPTION,
                                               V3.ORG_ID,
                                               V3.SET_OF_BOOKS_ID,
                                               p_REQUEST_ID);


                            	  IF p_PROCESS_TYPE = 'Y'
                                  THEN
                                 	 UPDATE  IGC_CC_PROCESS_DATA A
                                  	 SET     VALIDATION_STATUS      =   'F'
                                  	 WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                  	 AND     A.REQUEST_ID           =   p_REQUEST_ID
                                         AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                         AND     A.ORG_ID               =   p_ORG_ID
                                         AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
				  END IF;

                                  l_COUNTER := l_COUNTER + 1;

                            END IF;

                            IF     V9.CC_STATE = 'CL' AND V9.CC_APPRVL_STATUS <>'IP'
                            THEN
                                   l_OVERBILLED_COUNTER := 0;
                                   OPEN C4(V9.CC_HEADER_ID);         /* Over Billed Amount Validation for Standard CC */

                                        /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                        LOOP
                                           FETCH C4 INTO V4;
                                          EXIT WHEN C4%NOTFOUND;
                                            OPEN C5(V4.CC_ACCT_LINE_ID);
                                                 /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                                 LOOP
                                                    FETCH C5 INTO V5;
                                                    EXIT WHEN C5%NOTFOUND;

                                                    IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                                    THEN
                                                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                          FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                                          FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                          FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                          l_EXCEPTION := FND_MESSAGE.GET;

                                                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                          p_PROCESS_PHASE,
                                                                          V9.CC_HEADER_ID,
                                                                          V5.CC_ACCT_LINE_ID,
                                                                          V5.CC_DET_PF_LINE_ID,
                                                                          l_EXCEPTION,
                                                                          V3.ORG_ID,
                                                                          V3.SET_OF_BOOKS_ID,
                                                                          p_REQUEST_ID);

                                                          l_EXCEPTION := NULL;
                                                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                                          FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                                          FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                                          l_EXCEPTION := FND_MESSAGE.GET;

                                                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                            p_PROCESS_PHASE,
                                                                            V3.CC_HEADER_ID,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
                                                                            V3.ORG_ID,
                                                                            V3.SET_OF_BOOKS_ID,
                                                                            p_REQUEST_ID);

                                                          l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;
                                                          l_COUNTER := l_COUNTER + 1;
                                                    END IF;

                                                 END LOOP;  /* End of Loop for Cursor C5 */
                                              CLOSE C5;
                                           END LOOP;   /* End of Loop for Cursor C4 */
                                     CLOSE C4;

                                                    IF l_OVERBILLED_COUNTER > 0
                                                    THEN
                            	  			IF p_PROCESS_TYPE = 'Y'
                                  			THEN
                                                          UPDATE  IGC_CC_PROCESS_DATA A
                                                          SET     VALIDATION_STATUS      =   'F'
                                                          WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                          AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                          AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                          AND     A.ORG_ID               =   p_ORG_ID
                                                          AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
							END IF;
                                                    ELSE

                                                          IF  p_PROCESS_PHASE = 'F' AND p_PROCESS_TYPE = 'Y'
                                                          THEN

                                                             	UPDATE  IGC_CC_PROCESS_DATA A
                                                             	SET     VALIDATION_STATUS      =   'P'
                                                             	WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                             	AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                             	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                             	AND     A.ORG_ID               =   p_ORG_ID
                                                             	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;

                                                             	UPDATE IGC_CC_HEADERS
                                                             	SET    CC_APPRVL_STATUS             = 'IP'
                                                             	WHERE  IGC_CC_HEADERS.CC_HEADER_ID  =  V9.CC_HEADER_ID;

                                                                SELECT   CC_STATE,CC_APPRVL_STATUS
                                                                INTO     l_STATE,l_PREVIOUS_APPRVL_STATUS
                                                                FROM     IGC_CC_HEADERS
                                                                WHERE    CC_HEADER_ID = V9.CC_HEADER_ID;


                                                                IF  l_STATE = 'CM' AND l_PREVIOUS_APPRVL_STATUS = 'AP'
                                                                THEN

                                                                  BEGIN
                                                                       SELECT 'Y'
                                                                       INTO l_DUMMY
                                                                       FROM   PO_HEADERS_ALL A
                                                                       WHERE
                                                                           A.PO_HEADER_ID =
                                                                                (SELECT C.PO_HEADER_ID
                                                                                 FROM   IGC_CC_HEADERS B,
                                                                                        PO_HEADERS_ALL C
                                                                                 WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                                                        B.CC_NUM            =  C.SEGMENT1  AND
                                                                                        C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                                                        B.CC_HEADER_ID      =  V9.CC_HEADER_ID  );


                                                                	UPDATE PO_HEADERS_ALL
                                                                	SET    APPROVED_FLAG     = 'N'
                                                                	WHERE  (SEGMENT1,ORG_ID,TYPE_LOOKUP_CODE) IN
                                                                               (SELECT SEGMENT1,a.ORG_ID,TYPE_LOOKUP_CODE
                                                                                FROM   PO_HEADERS_ALL a, IGC_CC_HEADERS b
                                                                                WHERE  a.SEGMENT1         =  b.CC_NUM
                                                                                AND    a.ORG_ID           =  b.ORG_ID
                                                                                AND    a.TYPE_LOOKUP_CODE = 'STANDARD'
                                                                                AND    b.CC_HEADER_ID     =  V9.CC_HEADER_ID);

                                                                         EXCEPTION
                                                                              WHEN NO_DATA_FOUND
                                                                              THEN
                                                                                   NULL;
                                                                   END;
                                                                 END IF;

                                                          END IF;

                                                          IF    p_PROCESS_PHASE = 'P'
                                                          THEN
                            	  			     IF p_PROCESS_TYPE = 'Y'
                                  			     THEN
                                                                UPDATE  IGC_CC_PROCESS_DATA A
                                                                SET     VALIDATION_STATUS      =   'P'
                                                                WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                                AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                                AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                                AND     A.ORG_ID               =   p_ORG_ID
                                                                AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
							    END IF;
                                                          END IF;
                                                    END IF;
                                END IF;


                            IF    V9.CC_STATE = 'CM' AND V9.CC_APPRVL_STATUS = 'IP'
                            THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CM_INPROCESS');
                                  FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                  p_PROCESS_PHASE,
                                                  V9.CC_HEADER_ID,
                                                  NULL,
                                                  NULL,
                                                  l_EXCEPTION,
                                                  V3.ORG_ID,
                                                  V3.SET_OF_BOOKS_ID,
                                                  p_REQUEST_ID);

                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                  FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                  FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                  p_PROCESS_PHASE,
                                                  V3.CC_HEADER_ID,
                                                  NULL,
                                                  NULL,
                                                  l_EXCEPTION,
			 	        	  V3.ORG_ID,
                                                  V3.SET_OF_BOOKS_ID,
                                                  p_REQUEST_ID);

                            	  IF p_PROCESS_TYPE = 'Y'
                                  THEN
                                 	 UPDATE  IGC_CC_PROCESS_DATA A
                                  	 SET     VALIDATION_STATUS      =   'F'
                                  	 WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                  	 AND     A.REQUEST_ID           =   p_REQUEST_ID
                                  	 AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                  	 AND     A.ORG_ID               =   p_ORG_ID
                                  	 AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
				   END IF;

                                  l_COUNTER := l_COUNTER + 1;

                            END IF;

                            IF    V9.CC_STATE = 'CM' AND V9.CC_APPRVL_STATUS <> 'IP'
                            THEN
                                  l_OVERBILLED_COUNTER := 0;
                                  OPEN C4(V9.CC_HEADER_ID);        /* Over Billed Amount Validation for Standard CC */
                                       /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                       LOOP
                                          FETCH C4 INTO V4;
                                         EXIT WHEN C4%NOTFOUND;
                                          OPEN C5(V4.CC_ACCT_LINE_ID);
                                               /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                               LOOP
                                                  FETCH C5 INTO V5;
                                                  EXIT WHEN C5%NOTFOUND;

                                                  IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                                  THEN
                                                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                        FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                                        FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                        FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                        l_EXCEPTION := FND_MESSAGE.GET;

                                                                                  INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                   p_PROCESS_PHASE,
                                                                   V9.CC_HEADER_ID,
                                                                   V5.CC_ACCT_LINE_ID,
                                                                   V5.CC_DET_PF_LINE_ID,
                                                                   l_EXCEPTION,
                                                                   V3.ORG_ID,
                                                                   V3.SET_OF_BOOKS_ID,
                                                                   p_REQUEST_ID);

                                                        l_EXCEPTION := NULL;
                                                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                                        FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                                        FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                                        l_EXCEPTION := FND_MESSAGE.GET;

                                                                                  INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                    p_PROCESS_PHASE,
                                                                    V3.CC_HEADER_ID,
                                                                    NULL,
                                                                    NULL,
                                                                    l_EXCEPTION,
						                    V3.ORG_ID,
                                                                    V3.SET_OF_BOOKS_ID,
                                                                    p_REQUEST_ID);

                                                         l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;
                                                         l_COUNTER := l_COUNTER + 1;
                                                    END IF;

                                                 END LOOP;  /* End of Loop for Cursor C5 */
                                              CLOSE C5;
                                           END LOOP;   /* End of Loop for Cursor C4 */
                                     CLOSE C4;

                                                IF l_OVERBILLED_COUNTER > 0
                                                THEN
                            	  			IF p_PROCESS_TYPE = 'Y'
                                  			THEN
                                                        	UPDATE  IGC_CC_PROCESS_DATA A
                                                        	SET     VALIDATION_STATUS      =   'F'
                                                        	WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                        	AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                        	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                        	AND     A.ORG_ID               =   p_ORG_ID
                                                        	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
							END IF;
                                                 ELSE
                                                        IF  p_PROCESS_PHASE = 'F' AND p_PROCESS_TYPE = 'Y'
                                                          THEN

                                                             UPDATE  IGC_CC_PROCESS_DATA A
                                                             SET     VALIDATION_STATUS      =   'P'
                                                             WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                             AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                             AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                             AND     A.ORG_ID               =   p_ORG_ID
                                                             AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;

                                                             UPDATE IGC_CC_HEADERS
                                                             SET    CC_APPRVL_STATUS             = 'IP'
                                                             WHERE  IGC_CC_HEADERS.CC_HEADER_ID  =  V9.CC_HEADER_ID;

                                                             SELECT   CC_STATE,CC_APPRVL_STATUS
                                                             INTO     l_STATE,l_PREVIOUS_APPRVL_STATUS
                                                             FROM     IGC_CC_HEADERS
                                                             WHERE    CC_HEADER_ID = V9.CC_HEADER_ID;

                                                             IF  l_STATE = 'CM' AND l_PREVIOUS_APPRVL_STATUS = 'AP'
                                                             THEN

                                                                BEGIN
                                                                       SELECT 'Y'
                                                                       INTO l_DUMMY
                                                                       FROM   PO_HEADERS_ALL A
                                                                       WHERE
                                                                           A.PO_HEADER_ID =
                                                                                (SELECT C.PO_HEADER_ID
                                                                                 FROM   IGC_CC_HEADERS B,
                                                                                        PO_HEADERS_ALL C
                                                                                 WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                                                        B.CC_NUM            =  C.SEGMENT1  AND
                                                                                        C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                                                        B.CC_HEADER_ID      =  V9.CC_HEADER_ID  );


                                                                        UPDATE PO_HEADERS_ALL
                                                                        SET    APPROVED_FLAG     = 'N'
                                                                        WHERE  (SEGMENT1,ORG_ID,TYPE_LOOKUP_CODE) IN
                                                                               (SELECT SEGMENT1,a.ORG_ID,TYPE_LOOKUP_CODE
                                                                                FROM   PO_HEADERS_ALL a, IGC_CC_HEADERS b
                                                                                WHERE  a.SEGMENT1         =  b.CC_NUM
                                                                                AND    a.ORG_ID           =  b.ORG_ID
                                                                                AND    a.TYPE_LOOKUP_CODE = 'STANDARD'
                                                                                AND    b.CC_HEADER_ID     =  V9.CC_HEADER_ID);

                                                                         EXCEPTION
                                                                              WHEN NO_DATA_FOUND
                                                                              THEN
                                                                                   NULL;
                                                                  END;
                                                              END IF;

                                                          END IF;

                                                          IF    p_PROCESS_PHASE = 'P' AND p_PROCESS_TYPE = 'Y'
                                                          THEN
                                                                UPDATE  IGC_CC_PROCESS_DATA A
                                                                SET     VALIDATION_STATUS      =   'P'
                                                                WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                                AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                                AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                                AND     A.ORG_ID               =   p_ORG_ID
                                                                AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
                                                          END IF;

                                                  END IF;

                           END IF;

                           IF    V9.CC_STATE = 'CT' AND V9.CC_APPRVL_STATUS = 'IP'
                           THEN
                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CT_INPROCESS');
                                 FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                 FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                   p_PROCESS_PHASE,
                                                   V9.CC_HEADER_ID,
                                                   NULL,
                                                   NULL,
                                                   l_EXCEPTION,
                                                   V3.ORG_ID,
                                                   V3.SET_OF_BOOKS_ID,
                                                   p_REQUEST_ID);

                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                 FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                 FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                 l_EXCEPTION := FND_MESSAGE.GET;

                                                           INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                   p_PROCESS_PHASE,
                                                   V3.CC_HEADER_ID,
                                                   NULL,
                                                   NULL,
                                                   l_EXCEPTION,
					      	   V3.ORG_ID,
                                                   V3.SET_OF_BOOKS_ID,
                                                   p_REQUEST_ID);
                          	IF (p_PROCESS_TYPE = 'Y')
				THEN
                                 	UPDATE  IGC_CC_PROCESS_DATA A
                                 	SET     VALIDATION_STATUS      =   'F'
                                 	WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                 	AND     A.REQUEST_ID           =   p_REQUEST_ID
                                 	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                 	AND     A.ORG_ID               =   p_ORG_ID
                                 	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
				END IF;

                                 l_COUNTER := l_COUNTER + 1;

                           END IF;

                          IF    V9.CC_STATE = 'CT' AND V9.CC_APPRVL_STATUS <> 'IP'
                          THEN
                                l_OVERBILLED_COUNTER := 0;
                                OPEN C4(V9.CC_HEADER_ID);   /* Over Billed Amount Validation for Standard CC */
                                       /* Fetching Records based upon CC_HEADER_ID in CC_ACCT_LINES */
                                       LOOP
                                          FETCH C4 INTO V4;
                                          EXIT WHEN C4%NOTFOUND;
                                          OPEN C5(V4.CC_ACCT_LINE_ID);
                                                /* Fetching Records based upon CC_HEADER_ID in CC_DET_PF */
                                                LOOP
                                                   FETCH C5 INTO V5;
                                                   EXIT WHEN C5%NOTFOUND;

                                                   IF    V5.CC_DET_PF_BILLED_AMT > V5.CC_DET_PF_ENTERED_AMT
                                                   THEN
                                                         FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_OVERBILLED');
                                                         FND_MESSAGE.SET_TOKEN('NUMBER',V9.CC_NUM,TRUE);
                                                         FND_MESSAGE.SET_TOKEN('ACCT_LINE_NUM',V4.CC_ACCT_LINE_NUM,TRUE);
                                                         FND_MESSAGE.SET_TOKEN('PF_LINE_NUM',V5.CC_DET_PF_LINE_NUM,TRUE);
                                                         l_EXCEPTION := FND_MESSAGE.GET;

                                                                                   INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                           p_PROCESS_PHASE,
                                                           V9.CC_HEADER_ID,
                                                           V5.CC_ACCT_LINE_ID,
                                                           V5.CC_DET_PF_LINE_ID,
                                                           l_EXCEPTION,
                                                           V3.ORG_ID,
                                                           V3.SET_OF_BOOKS_ID,
                                                           p_REQUEST_ID);

                                                         l_EXCEPTION := NULL;
                                                         FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_REL_COVER_FAIL');
                                                         FND_MESSAGE.SET_TOKEN('NUMBER1',V9.CC_NUM,TRUE);
                                                         FND_MESSAGE.SET_TOKEN('NUMBER2',V3.CC_NUM,TRUE);
                                                         l_EXCEPTION := FND_MESSAGE.GET;

                                                                                   INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                                                 p_PROCESS_PHASE,
                                                                 V3.CC_HEADER_ID,
                                                                 NULL,
                                                                 NULL,
                                                                 l_EXCEPTION,
						          	 V3.ORG_ID,
                                                                 V3.SET_OF_BOOKS_ID,
                                                                 p_REQUEST_ID);

                                                          l_OVERBILLED_COUNTER := l_OVERBILLED_COUNTER + 1;
                                                          l_COUNTER := l_COUNTER + 1;
                                                    END IF;

                                                 END LOOP;  /* End of Loop for Cursor C5 */
                                              CLOSE C5;
                                           END LOOP;   /* End of Loop for Cursor C4 */
                                     CLOSE C4;

                                                    IF    l_OVERBILLED_COUNTER > 0
                                                    THEN
                                                          UPDATE  IGC_CC_PROCESS_DATA A
                                                          SET     VALIDATION_STATUS      =   'F'
                                                          WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                          AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                          AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                          AND     A.ORG_ID               =   p_ORG_ID
                                                          AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
                                                    ELSE
                                                          IF  p_PROCESS_PHASE = 'F' AND P_PROCESS_TYPE = 'Y'
                                                          THEN

                                                             UPDATE  IGC_CC_PROCESS_DATA A
                                                             SET     VALIDATION_STATUS      =   'P'
                                                             WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                             AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                             AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                             AND     A.ORG_ID               =   p_ORG_ID
                                                             AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;

                                                             UPDATE IGC_CC_HEADERS
                                                             SET    CC_APPRVL_STATUS             = 'IP'
                                                             WHERE  IGC_CC_HEADERS.CC_HEADER_ID  =  V9.CC_HEADER_ID;

                                                             SELECT   CC_STATE,CC_APPRVL_STATUS
                                                             INTO     l_STATE,l_PREVIOUS_APPRVL_STATUS
                                                             FROM     IGC_CC_HEADERS
                                                             WHERE    CC_HEADER_ID = V9.CC_HEADER_ID;

                                                             IF  l_STATE = 'CM' AND l_PREVIOUS_APPRVL_STATUS = 'AP'
                                                             THEN

                                                               BEGIN
                                                                       SELECT 'Y'
                                                                       INTO l_DUMMY
                                                                       FROM   PO_HEADERS_ALL A
                                                                       WHERE
                                                                           A.PO_HEADER_ID =
                                                                                (SELECT C.PO_HEADER_ID
                                                                                 FROM   IGC_CC_HEADERS B,
                                                                                        PO_HEADERS_ALL C
                                                                                 WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                                                        B.CC_NUM            =  C.SEGMENT1  AND
                                                                                        C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                                                        B.CC_HEADER_ID      =  V9.CC_HEADER_ID  );


                                                                        UPDATE PO_HEADERS_ALL
                                                                        SET    APPROVED_FLAG     = 'N'
                                                                        WHERE  (SEGMENT1,ORG_ID,TYPE_LOOKUP_CODE) IN
                                                                               (SELECT SEGMENT1,a.ORG_ID,TYPE_LOOKUP_CODE
                                                                                FROM   PO_HEADERS_ALL a, IGC_CC_HEADERS b
                                                                                WHERE  a.SEGMENT1         =  b.CC_NUM
                                                                                AND    a.ORG_ID           =  b.ORG_ID
                                                                                AND    a.TYPE_LOOKUP_CODE = 'STANDARD'
                                                                                AND    b.CC_HEADER_ID     =  V9.CC_HEADER_ID);

                                                                         EXCEPTION
                                                                              WHEN NO_DATA_FOUND
                                                                              THEN
                                                                                   NULL;
                                                               END;
                                                            END IF;

                                                          END IF;
                                                          IF    p_PROCESS_PHASE = 'P'
                                                          THEN
                                                                UPDATE  IGC_CC_PROCESS_DATA A
                                                                SET     VALIDATION_STATUS      =   'P'
                                                                WHERE   A.CC_HEADER_ID         =   V9.CC_HEADER_ID
                                                                AND     A.REQUEST_ID           =   p_REQUEST_ID
                                                                AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                                                                AND     A.ORG_ID               =   p_ORG_ID
                                                                AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
                                                          END IF;

                                                    END IF;
                            END IF;
                        COMMIT;
                   END LOOP;  /*  End of LOOP C6 */
                 CLOSE C9; /* CURSOR C9 CLOSED */

                    /******************* End of Checking Release Validation ********************/


                    /***** Checking Cover Validation after chacking Corresponding Releases *****/

                                 /* Fully Encumbrance check for YEAR END PROCESS  */

                      IF    p_PROCESS_TYPE = 'Y'
                      THEN
                            IF   ( ( (v3.cc_state = 'PR') AND (p_prov_enc_on = TRUE) ) OR
                                   (v3.cc_state = 'CM') OR
                                   ( ( (v3.cc_state = 'CL') AND (p_prov_enc_on = TRUE) ) AND (v3.cc_apprvl_status <> 'AP')) OR
                                   ( (v3.cc_state = 'CT') AND (v3.cc_apprvl_status <> 'AP'))
                                  )
                                  AND V3.CC_ENCMBRNC_STATUS = 'N'
                            THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_NOT_FULLY_ENC');
                                  FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                                  l_EXCEPTION := FND_MESSAGE.GET;

                                                            INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,

                                                                       p_PROCESS_PHASE,
                                                                       V3.CC_HEADER_ID,
                                                                       NULL,
                                                                       NULL,
                                                                       l_EXCEPTION,
                                                                       V3.ORG_ID,
                                                                       V3.SET_OF_BOOKS_ID,
                                                                       p_REQUEST_ID);
                                   RETURN 'F';

                            END IF;
                      END IF;

                                /* END OF Fully Encumbrance check for YEAR END PROCESS  */


                    IF    V3.CC_STATE = 'PR' AND V3.CC_APPRVL_STATUS = 'IP'
                    THEN
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_PR_INPROCESS');
                          FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                          FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                          l_EXCEPTION := FND_MESSAGE.GET;

                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                           p_PROCESS_PHASE,
                                           V3.CC_HEADER_ID,
                                           NULL,
                                           NULL,
                                           l_EXCEPTION,
                                           V3.ORG_ID,
                                           V3.SET_OF_BOOKS_ID,
                                           p_REQUEST_ID);
			    IF (p_PROCESS_TYPE = 'Y')
			    THEN
                            	UPDATE  IGC_CC_PROCESS_DATA A
                            	SET     VALIDATION_STATUS      =   'F'
                            	WHERE   A.CC_HEADER_ID         =   V3.CC_HEADER_ID
                            	AND     A.REQUEST_ID           =   p_REQUEST_ID
                            	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                            	AND     A.ORG_ID               =   p_ORG_ID
                            	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
			    END IF;

                            RETURN 'F';


                    END IF;

                    IF    V3.CC_STATE = 'CL' AND V3.CC_APPRVL_STATUS = 'IP'
                    THEN
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CL_INPROCESS');
                          FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                          FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                          l_EXCEPTION := FND_MESSAGE.GET;

                                                    INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                           p_PROCESS_PHASE,
                                           V3.CC_HEADER_ID,
                                           NULL,
                                           NULL,
                                           l_EXCEPTION,
                                           V3.ORG_ID,
                                           V3.SET_OF_BOOKS_ID,
                                           p_REQUEST_ID);
			    IF (p_PROCESS_TYPE = 'Y')
			    THEN
                            	UPDATE  IGC_CC_PROCESS_DATA A
                            	SET     VALIDATION_STATUS      =   'F'
                            	WHERE   A.CC_HEADER_ID         =   V3.CC_HEADER_ID
                            	AND     A.REQUEST_ID           =   p_REQUEST_ID
                            	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                            	AND     A.ORG_ID               =   p_ORG_ID
                            	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
			    END IF;

                            RETURN 'F';


                     END IF;

                     IF    V3.CC_STATE = 'CM' AND V3.CC_APPRVL_STATUS = 'IP'
                     THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CM_INPROCESS');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

                                                     INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                          p_PROCESS_PHASE,
                                          V3.CC_HEADER_ID,
                                          NULL,
                                          NULL,
                                          l_EXCEPTION,
                                          V3.ORG_ID,
                                          V3.SET_OF_BOOKS_ID,
                                          p_REQUEST_ID);


			    IF (p_PROCESS_TYPE = 'Y')
			    THEN
                            	UPDATE  IGC_CC_PROCESS_DATA A
                            	SET     VALIDATION_STATUS      =   'F'
                            	WHERE   A.CC_HEADER_ID         =   V3.CC_HEADER_ID
                            	AND     A.REQUEST_ID           = p_REQUEST_ID
                            	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                            	AND     A.ORG_ID               =   p_ORG_ID
                            	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
			     END IF;

                            RETURN 'F';


                     END IF;

                     IF    V3.CC_STATE = 'CT' AND V3.CC_APPRVL_STATUS = 'IP'
                     THEN
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CT_INPROCESS');
                           FND_MESSAGE.SET_TOKEN('NUMBER',V3.CC_NUM,TRUE);
                           FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_PROCESS_TYPE,TRUE);
                           l_EXCEPTION := FND_MESSAGE.GET;

                                                     INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
                              (PROCESS_TYPE ,
                               PROCESS_PHASE,
                               CC_HEADER_ID,
                               CC_ACCT_LINE_ID ,
                               CC_DET_PF_LINE_ID,
                               EXCEPTION_REASON,
                               ORG_ID,
                               SET_OF_BOOKS_ID,
                               REQUEST_ID)
                           VALUES (P_PROCESS_TYPE,
                                          p_PROCESS_PHASE,
                                          V3.CC_HEADER_ID,
                                          NULL,
                                          NULL,
                                          l_EXCEPTION,
                                          V3.ORG_ID,
                                          V3.SET_OF_BOOKS_ID,
                                          p_REQUEST_ID);

			    IF (p_PROCESS_TYPE = 'Y')
			    THEN
                            	UPDATE  IGC_CC_PROCESS_DATA A
                            	SET     VALIDATION_STATUS      =   'F'
                            	WHERE   A.CC_HEADER_ID         =   V3.CC_HEADER_ID
                            	AND     A.REQUEST_ID           = p_REQUEST_ID
                            	AND     A.PROCESS_TYPE         =   p_PROCESS_TYPE
                            	AND     A.ORG_ID               =   p_ORG_ID
                            	AND     A.SET_OF_BOOKS_ID      =   p_SOB_ID;
			    END IF;

                            RETURN 'F';


                     END IF;

                    /****************** End of Checking Cover Validation ********************/
                     IF    l_COUNTER > 0
                     THEN
                           RETURN 'F';
                     ELSE
                           RETURN 'P'; /* if all IF Statements failed then Validation Status is Passed */
                     END IF;
           END IF;
      END LOOP;   /*  End of Loop for Cursor C3 */
  CLOSE C3;       /* Cursor Closed */

/******** End of Validation Check for Cover and Release CC For Both Preliminary And Final Mode **********/


END VALIDATE_CC;

/*==================================================================================
                             End of VALIDATE_CC Procedure
  =================================================================================*/



/* Checks whether all the invoices related to
Contract Commitment are either paid or cancelled */


/*==================================================================================
                                 Procedure  INVOICE_CANC_OR_PAID
  =================================================================================*/
FUNCTION invoice_canc_or_paid(p_cc_header_id NUMBER)
RETURN BOOLEAN
IS
	l_count            NUMBER := 0;
	l_paid_canc_count  NUMBER := 0;
	l_inv_dist_total   NUMBER := 0;

	l_invoice_id            ap_invoices_all.invoice_id%TYPE;
	l_cancelled_date        ap_invoices_all.cancelled_date%TYPE;
	l_payment_status_flag   ap_invoices_all.payment_status_flag%TYPE;

	l_po_header_id          po_headers_all.po_header_id%TYPE;
	l_po_distribution_id    po_distributions_all.po_distribution_id%TYPE;

	l_invoice_canc_paid_flag BOOLEAN := FALSE;

	CURSOR c_po_distributions(p_cc_header_id NUMBER)
	IS
		SELECT  pod.po_distribution_id
		FROM
        		po_distributions_all pod,
        		po_headers_all phh,
        		igc_cc_headers cch
		WHERE
			pod.po_header_id = phh.po_header_id AND
			phh.org_id = cch.org_id AND
			phh.type_lookup_code = 'STANDARD' AND
			phh.segment1 = cch.cc_num AND
			cch.cc_header_id = p_cc_header_id;

	CURSOR c_invoices(p_po_distribution_id NUMBER)
        IS
		SELECT  unique api.invoice_id
		FROM
 			ap_invoice_distributions_all apid,
       			ap_invoices_all api
		WHERE
			apid.invoice_id            = api.invoice_id AND
			apid.po_distribution_id    = p_po_distribution_id;
BEGIN
	l_count := 0;

	l_paid_canc_count := 0;

	OPEN c_po_distributions(p_cc_header_id);
	LOOP
		FETCH c_po_distributions INTO l_po_distribution_id;
		EXIT WHEN c_po_distributions%NOTFOUND;

		OPEN c_invoices(l_po_distribution_id);
		LOOP
			FETCH c_invoices INTO l_invoice_id;
			EXIT WHEN c_invoices%NOTFOUND;

			l_count := l_count + 1;

			l_cancelled_date      := NULL;
			l_payment_status_flag := 'N';

	        	SELECT	cancelled_date , NVL(payment_status_flag,'N')
	        	INTO      l_cancelled_date, l_payment_status_flag
			FROM      ap_invoices_all
			WHERE     invoice_id = l_invoice_id;

                	IF (l_cancelled_date IS NOT NULL) OR (l_payment_status_flag = 'Y')
			THEN
				l_paid_canc_count := l_paid_canc_count + 1;
			ELSE
				/* check for invoice distribution lines reversal */
				l_inv_dist_total := 9999;

				SELECT  SUM(NVL(apid.amount,0))
				INTO    l_inv_dist_total
				FROM
 					ap_invoice_distributions_all apid
				WHERE
					apid.invoice_id            = l_invoice_id AND
					apid.po_distribution_id    = l_po_distribution_id ;

				IF (l_inv_dist_total <> 0)
				THEN
					CLOSE c_invoices;
					CLOSE c_po_distributions;
					RETURN(TRUE);
				END IF;
				l_count := l_count - 1;

			END IF;


		END LOOP;
		CLOSE c_invoices;

	END LOOP;
	CLOSE c_po_distributions;


	IF (l_count = l_paid_canc_count)
	THEN
		RETURN(FALSE);
	ELSE
		RETURN(TRUE);
	END IF;

END invoice_canc_or_paid;

/* Inserts row into budgetary control interface table */

PROCEDURE Insert_Interface_Row(p_cc_interface_rec IN igc_cc_interface%ROWTYPE, l_insert_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
	INSERT INTO igc_cc_interface (
	batch_line_num,
	cc_header_id,
	cc_version_num,
	cc_acct_line_id,
	cc_det_pf_line_id,
	set_of_books_id,
	code_combination_id,
	cc_transaction_date,
	transaction_description,
	encumbrance_type_id,
	currency_code,
	cc_func_dr_amt,
	cc_func_cr_amt,
	je_source_name,
	je_category_name,
	actual_flag,
	budget_dest_flag,
	last_update_date,
	last_updated_by,
	last_update_login,
	creation_date,
	created_by,
	period_set_name,
	period_name,
	cbc_result_code,
	status_code,
	budget_version_id,
	budget_amt,
	commitment_encmbrnc_amt,
	obligation_encmbrnc_amt,
	funds_available_amt,
	document_type,
	reference_1,
	reference_2,
	reference_3,
	reference_4,
	reference_5,
	reference_6,
	reference_7,
	reference_8,
	reference_9,
	reference_10,
	cc_encmbrnc_date,
	/*Bug No : 6341012. SLA Uptake. Project_Line field added*/
	project_line
	)
	VALUES
	(p_cc_interface_rec.batch_line_num,
	p_cc_interface_rec.cc_header_id,
	p_cc_interface_rec.cc_version_num,
	p_cc_interface_rec.cc_acct_line_id,
	p_cc_interface_rec.cc_det_pf_line_id,
	p_cc_interface_rec.set_of_books_id,
	p_cc_interface_rec.code_combination_id,
	p_cc_interface_rec.cc_transaction_date,
	p_cc_interface_rec.transaction_description,
	p_cc_interface_rec.encumbrance_type_id,
	p_cc_interface_rec.currency_code,
	p_cc_interface_rec.cc_func_dr_amt,
	p_cc_interface_rec.cc_func_cr_amt,
	p_cc_interface_rec.je_source_name,
	p_cc_interface_rec.je_category_name,
	p_cc_interface_rec.actual_flag,
	p_cc_interface_rec.budget_dest_flag,
	p_cc_interface_rec.last_update_date,
	p_cc_interface_rec.last_updated_by,
	p_cc_interface_rec.last_update_login,
	p_cc_interface_rec.creation_date,
	p_cc_interface_rec.created_by,
	p_cc_interface_rec.period_set_name,
	p_cc_interface_rec.period_name,
	p_cc_interface_rec.cbc_result_code,
	p_cc_interface_rec.status_code,
	p_cc_interface_rec.budget_version_id,
	p_cc_interface_rec.budget_amt,
	p_cc_interface_rec.commitment_encmbrnc_amt,
	p_cc_interface_rec.obligation_encmbrnc_amt,
	p_cc_interface_rec.funds_available_amt,
	p_cc_interface_rec.document_type,
	p_cc_interface_rec.reference_1,
	p_cc_interface_rec.reference_2,
	p_cc_interface_rec.reference_3,
	p_cc_interface_rec.reference_4,
	p_cc_interface_rec.reference_5,
	p_cc_interface_rec.reference_6,
	p_cc_interface_rec.reference_7,
	p_cc_interface_rec.reference_8,
	p_cc_interface_rec.reference_9,
	p_cc_interface_rec.reference_10,
	p_cc_interface_rec.cc_encmbrnc_date,
	/*Bug No : 6341012. SLA Uptake. Project_Line field added*/
	p_cc_interface_rec.project_line
	);

 EXCEPTION
   WHEN OTHERS THEN
     l_insert_return_status := 'F';

     IF (l_state_level >= l_debug_level) THEN
      FND_LOG.STRING(l_state_level, 'igc_cc_rep_yep_pvt.insert_interface_row',
                                    'Record not inserted' || to_char(sysdate,'DD-MON-YY:MI:SS'));
     END IF;


END Insert_Interface_Row;

/* Populates the interface table for the budgetary control as per the process*/

PROCEDURE Process_Interface_Row(
/*Bug No : 6341012. SLA Uptake. Encumbrance_Type_Ids are not required*/
--	  p_cc_prov_enc_type_id       IN NUMBER,
--        p_cc_conf_enc_type_id       IN NUMBER,
--        p_req_encumbrance_type_id   IN financials_system_params_all.req_encumbrance_type_id%TYPE,
--	p_purch_encumbrance_type_id IN financials_system_params_all.purch_encumbrance_type_id%TYPE,
        p_currency_code             IN VARCHAR2,
        p_cc_headers_rec            IN igc_cc_headers%ROWTYPE,
        p_cc_acct_lines_rec         IN igc_cc_acct_lines%ROWTYPE,
        p_cc_pmt_fcst_rec           IN igc_cc_det_pf%ROWTYPE,
        p_mode                      IN VARCHAR2,
        p_type                      IN VARCHAR2,
	p_process_type              IN VARCHAR2,
  	p_yr_end_cr_date            IN DATE,
  	p_yr_end_dr_date            IN DATE,
  	p_rate_date                 IN DATE,
  	p_rate                      IN NUMBER,
  	p_revalue_fix_date          IN DATE,
        l_insert_status             OUT NOCOPY VARCHAR2
                             	)
IS

	l_cc_interface_rec igc_cc_interface%ROWTYPE;
        l_insert_return_status VARCHAR2(1);
	E_RETURN_FAIL       exception;
	l_ent_amt           NUMBER;
	l_enc_amt           NUMBER;
	l_func_amt          NUMBER;
	l_func_billed_amt   NUMBER;
	l_tran_amount       NUMBER;
	l_cr_tran_amount    NUMBER;
	l_dr_tran_amount    NUMBER;
	l_billed_amt        NUMBER;
	l_unbilled_amt      NUMBER;
	l_old_rate          NUMBER;

	l_unbilled_tax_amt  NUMBER;
	l_cr_tran_tax_amt   NUMBER;
	l_dr_tran_tax_amt   NUMBER;
	l_tran_tax_amt      NUMBER;
        l_return_status     VARCHAR2(1);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);

-- bug 2043221 ssmales - added declaration on line below
        l_withheld_tran_amt   NUMBER;

	l_cover_cc_num              igc_cc_headers.cc_num%TYPE;
        l_cover_cc_version_num      igc_cc_headers.cc_version_num%TYPE;
        l_cover_set_of_books_id     igc_cc_headers.set_of_books_id%TYPE;
        l_cover_cc_acct_date        igc_cc_headers.cc_acct_date%TYPE;

        l_cover_cc_acct_desc        igc_cc_acct_lines.cc_acct_desc%TYPE;
        l_cover_budg_code_comb_id   igc_cc_acct_lines.cc_budget_code_combination_id%TYPE;
        l_cover_cc_det_pf_date      igc_cc_det_pf.cc_det_pf_date%TYPE;


	/* Begin for fix for bug 1689924*/
	l_cc_header_id igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_id  igc_cc_acct_lines.cc_acct_line_id%TYPE;
	/* End for fix for bug 1689924*/
	P_Error_Code	VARCHAR2(32); /*EB Tax uptake - Bug No : 6472296*/
	l_taxable_flag     VARCHAR2(2);  /*Bug 6472296 EB Tax uptake - CC*/

BEGIN
	l_taxable_flag := nvl(p_cc_acct_lines_rec.cc_acct_taxable_flag,'N'); /*Bug 6472296 EB Tax uptake - CC*/
	IF (p_cc_headers_rec.cc_type = 'R') AND
           (p_process_type = 'F')
	THEN
		SELECT cc_num,cc_version_num, set_of_books_id, cc_acct_date
                INTO l_cover_cc_num, l_cover_cc_version_num, l_cover_set_of_books_id, l_cover_cc_acct_date
		FROM igc_cc_headers
                WHERE cc_header_id = p_cc_headers_rec.parent_header_id;

		SELECT cc_acct_desc, cc_budget_code_combination_id
                INTO l_cover_cc_acct_desc, l_cover_budg_code_comb_id
                FROM igc_cc_acct_lines
                WHERE cc_acct_line_id = p_cc_acct_lines_rec.parent_acct_line_id;
	END IF;

	l_cc_interface_rec.cbc_result_code          := NULL;
	l_cc_interface_rec.status_code              := NULL;
	l_cc_interface_rec.budget_version_id        := NULL;
	l_cc_interface_rec.budget_amt               := NULL;
	l_cc_interface_rec.commitment_encmbrnc_amt  := NULL;
	l_cc_interface_rec.obligation_encmbrnc_amt  := NULL;
	l_cc_interface_rec.funds_available_amt      := NULL;
	l_cc_interface_rec.reference_1              := NULL;
	l_cc_interface_rec.reference_2              := NULL;
	l_cc_interface_rec.reference_3              := NULL;
	l_cc_interface_rec.reference_4              := NULL;
	l_cc_interface_rec.reference_5              := NULL;
	l_cc_interface_rec.reference_6              := NULL;
/*Bug No : 6341012. SLA Uptake. Reference_7 should be 'EC'*/
--	l_cc_interface_rec.reference_7              := NULL;
	l_cc_interface_rec.reference_7		     := 'EC';
	l_cc_interface_rec.reference_8              := NULL;
	l_cc_interface_rec.reference_9              := NULL;
	l_cc_interface_rec.reference_10             := NULL;
	l_cc_interface_rec.cc_encmbrnc_date         := NULL;
	l_cc_interface_rec.document_type            := 'CC';

	IF (p_cc_headers_rec.cc_type = 'R') AND
           (p_process_type = 'F')
	THEN
		l_cc_interface_rec.cc_header_id             :=  p_cc_headers_rec.parent_header_id;
		l_cc_interface_rec.cc_version_num           :=  l_cover_cc_version_num + 1;
	        l_cc_interface_rec.set_of_books_id          :=  l_cover_set_of_books_id;
	ELSE
		l_cc_interface_rec.cc_header_id             :=  p_cc_headers_rec.cc_header_id;
		l_cc_interface_rec.cc_version_num           :=  p_cc_headers_rec.cc_version_num + 1;
	        l_cc_interface_rec.set_of_books_id          :=  p_cc_headers_rec.set_of_books_id;

	END IF;

	IF (p_cc_headers_rec.cc_type = 'R') AND
           (p_process_type = 'F')
	THEN
		l_cc_interface_rec.code_combination_id      :=  l_cover_budg_code_comb_id;
	ELSE
		l_cc_interface_rec.code_combination_id      :=  p_cc_acct_lines_rec.cc_budget_code_combination_id;
	END IF;

	l_cc_interface_rec.currency_code            :=  p_currency_code;
/*Bug No : 6341012. SLA Uptake. Je_Source_Name should be NULL*/
--	l_cc_interface_rec.je_source_name           := 'Contract Commitment';
	l_cc_interface_rec.actual_flag              :=  'E';
	l_cc_interface_rec.last_update_date         :=  sysdate;
	l_cc_interface_rec.last_updated_by          :=  -1;
	l_cc_interface_rec.last_update_login        :=  -1;
	l_cc_interface_rec.creation_date            :=  sysdate;
	l_cc_interface_rec.created_by               :=  -1;

/*Bug No : 6341012. SLA Uptake. Event_id, Project_ida re newly added in IGC_CC_INTERFACE
 Encumbrance_type_id is not required*/
	l_cc_interface_rec.Event_Id  :=  Null;
	l_cc_interface_rec.Project_line  := 'N';
	l_cc_interface_rec.encumbrance_type_id      :=  NULL;

	IF (p_cc_headers_rec.cc_type = 'R') AND
           (p_process_type = 'F')
	THEN
		l_cc_interface_rec.transaction_description  :=  LTRIM(RTRIM(l_cover_cc_num))
						        || ' ' || rtrim(ltrim(l_cover_cc_acct_desc));
        ELSE
		l_cc_interface_rec.transaction_description  :=  LTRIM(RTRIM(p_cc_headers_rec.cc_num))
						        || ' ' || rtrim(ltrim(p_cc_acct_lines_rec.cc_acct_desc));
        END IF;

	l_old_rate  := p_cc_headers_rec.conversion_rate;

	IF (p_type = 'A')
	THEN
		IF (p_cc_headers_rec.cc_type = 'R') AND
           	(p_process_type = 'F')
		THEN
			l_cc_interface_rec.cc_acct_line_id          :=  p_cc_acct_lines_rec.parent_acct_line_id;
			l_cc_interface_rec.cc_det_pf_line_id        :=  NULL;
			l_cc_interface_rec.budget_dest_flag         :=  'C';
			l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.parent_header_id;
			l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.parent_acct_line_id;
			l_cc_interface_rec.reference_3              :=  l_cover_cc_version_num + 1;
 --		        Bug 6341012  made reference_4 to be assigned from p_cc_headers_rec.cc_num rather than from p_cc_pmt_fcst.cc_det_pf_line_id
			l_cc_interface_rec.reference_4		    :=  p_cc_headers_rec.cc_num;
		ELSE
			l_cc_interface_rec.cc_acct_line_id          :=  p_cc_acct_lines_rec.cc_acct_line_id;
			l_cc_interface_rec.cc_det_pf_line_id        :=  NULL;
			l_cc_interface_rec.budget_dest_flag         :=  'C';
			l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.cc_header_id;
			l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.cc_acct_line_id;
			l_cc_interface_rec.reference_3              :=  p_cc_headers_rec.cc_version_num + 1;
 --		        Bug 6341012  made reference_4 to be assigned from p_cc_headers_rec.cc_num rather than from p_cc_pmt_fcst.cc_det_pf_line_id
			l_cc_interface_rec.reference_4		    :=  p_cc_headers_rec.cc_num;


		END IF;

		l_func_amt        := 0;
                l_func_billed_amt := 0;

		IF (p_process_type = 'Y')
		THEN
                        -- Performance fixes. Replaced the query with the one
                        -- below.
                        /*
			SELECT cc_acct_func_amt , cc_acct_func_billed_amt
			INTO   l_func_amt, l_func_billed_amt
			FROM   igc_cc_acct_lines_v
			WHERE  cc_acct_line_id = p_cc_acct_lines_rec.cc_acct_line_id;
                        */
			SELECT Nvl(cc_acct_func_amt,0) , Nvl(IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id),0)
			INTO   l_func_amt, l_func_billed_amt
			FROM   igc_cc_acct_lines ccal
			WHERE  ccal.cc_acct_line_id = p_cc_acct_lines_rec.cc_acct_line_id;

		        l_unbilled_amt       := l_func_amt - l_func_billed_amt;

                        -- Bug 2409502, calculate the non recoverable tax


			/*EB Tax uptake - Bug No : 6472296*/
/*
			igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_unbilled_amt,
                		p_tax_amount        => l_unbilled_tax_amt);
*/
			IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_unbilled_amt,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_unbilled_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);
				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
			/*EB Tax uptake - Bug No : 6472296 END*/
                        l_unbilled_amt := l_unbilled_amt + Nvl(l_unbilled_tax_amt,0);


                        -- Bug  2409502, End

			/* Reserve on first date of year */
	       		g_line_num := g_line_num + 1;

			l_cc_interface_rec.cc_transaction_date      :=  p_yr_end_dr_date;
			l_cc_interface_rec.batch_line_num           :=  g_line_num;
			l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
			l_cc_interface_rec.cc_func_dr_amt           :=  l_unbilled_amt;

			Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                        IF l_insert_return_status = 'F' THEN
	  		  raise E_RETURN_FAIL;
			END IF;

			l_cc_interface_rec.cc_transaction_date      :=  NULL;
			/* Liquidate on last date of fiscal year */

			g_line_num := g_line_num + 1;
			l_cc_interface_rec.cc_transaction_date      :=  p_yr_end_cr_date;

			l_cc_interface_rec.batch_line_num           :=  g_line_num;
			l_cc_interface_rec.cc_func_cr_amt           :=  NULL; /* 6670549 l_unbilled_amt; */
			l_cc_interface_rec.cc_func_dr_amt           :=  - l_unbilled_amt; /* 6670549 NULL; */

			Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                        IF l_insert_return_status = 'F' THEN
			  raise E_RETURN_FAIL;
			END IF;
		ELSIF (p_process_type = 'F')
		THEN

                        /* Queries to compute CBC entries based on realted SBC entries */


	                /* Begin for fix for bug 1689924*/
			IF (p_cc_headers_rec.cc_type = 'R') AND
           		   (p_process_type = 'F')
		        THEN
				l_cc_header_id    := p_cc_headers_rec.parent_header_id;
				l_cc_acct_line_id := p_cc_acct_lines_rec.parent_acct_line_id;
			ELSE
				l_cc_header_id    := p_cc_headers_rec.cc_header_id;
				l_cc_acct_line_id := p_cc_acct_lines_rec.cc_acct_line_id;
			END IF;

	                /* End for fix for bug 1689924*/

			l_dr_tran_amount       := 0;


			BEGIN

				SELECT SUM(NVL(igcci.cc_func_dr_amt,0))
				INTO l_dr_tran_amount
				FROM igc_cc_interface igcci
				WHERE
					igcci.cc_header_id = l_cc_header_id AND
		      			igcci.actual_flag = 'E'  AND
			       		igcci.cc_det_pf_line_id IN (SELECT ccdpf.cc_det_pf_line_id
					    		            FROM igc_cc_det_pf ccdpf
						     	            WHERE cc_acct_line_id =
							                  l_cc_acct_line_id);
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_dr_tran_amount := 0;
			END;

			l_cr_tran_amount       := 0;

			BEGIN

				SELECT SUM(NVL(igcci.cc_func_cr_amt,0))
				INTO l_cr_tran_amount
				FROM igc_cc_interface igcci
				WHERE
					igcci.cc_header_id = l_cc_header_id AND
		      			igcci.actual_flag = 'E'  AND
			       		igcci.cc_det_pf_line_id IN (SELECT ccdpf.cc_det_pf_line_id
						                    FROM igc_cc_det_pf ccdpf
						                    WHERE cc_acct_line_id =
							                  l_cc_acct_line_id);
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_cr_tran_amount := 0;
			END;

                        -- Bug 2409502, calculate the non recoverable tax
			/*EB Tax uptake - Bug No : 6472296*/
/*
			igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_dr_tran_amount,
                		p_tax_amount        => l_dr_tran_tax_amt);
*/
			IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_dr_tran_amount,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_dr_tran_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);

				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
                        l_dr_tran_amount := l_dr_tran_amount + Nvl(l_dr_tran_tax_amt,0);

/*                        igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_cr_tran_amount,
                		p_tax_amount        => l_cr_tran_tax_amt);
*/
                        IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_cr_tran_amount,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_cr_tran_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);
				/*EB Tax uptake - Bug No : 6472296 END*/
				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
                        l_cr_tran_amount := l_cr_tran_amount + Nvl(l_cr_tran_tax_amt,0);
                        -- Bug  2409502, End

			IF (p_cc_headers_rec.cc_type = 'R')
		        THEN

				IF (l_cover_cc_acct_date <= p_revalue_fix_date)
				THEN
					l_cc_interface_rec.cc_transaction_date   :=  p_revalue_fix_date;
				END IF;

				IF (l_cover_cc_acct_date > p_revalue_fix_date)
				THEN
					l_cc_interface_rec.cc_transaction_date   :=  l_cover_cc_acct_date ;
				END IF;
			ELSE
				IF (p_cc_headers_rec.cc_acct_date <= p_revalue_fix_date)
				THEN
					l_cc_interface_rec.cc_transaction_date   :=  p_revalue_fix_date;
				END IF;

				IF (p_cc_headers_rec.cc_acct_date > p_revalue_fix_date)
				THEN
					l_cc_interface_rec.cc_transaction_date   :=  p_cc_headers_rec.cc_acct_date ;
				END IF;
			END IF;

			IF (abs(l_dr_tran_amount) > 0 )
			THEN

				g_line_num := g_line_num + 1;

				l_cc_interface_rec.batch_line_num      	    :=  g_line_num;

				l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
				l_cc_interface_rec.cc_func_dr_amt           :=  l_dr_tran_amount; /* 6670549 ABS(l_dr_tran_amount); */
				Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
				END IF;

			END IF;

			IF (abs(l_cr_tran_amount) > 0 )
			THEN
				g_line_num := g_line_num + 1;

				l_cc_interface_rec.batch_line_num      	    :=  g_line_num;

				l_cc_interface_rec.cc_func_cr_amt           :=  ABS(l_cr_tran_amount);
				l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
				Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
				END IF;
			END IF;

		ELSIF (p_process_type = 'R')
		THEN
			l_tran_amount       := 0;
			l_func_billed_amt   := 0;
                        /* Queries to compute CBC entries based on realted SBC entries */
			IF (l_old_rate < p_rate)
			THEN
				SELECT SUM(NVL(igcci.cc_func_dr_amt,0))
				INTO l_tran_amount
				FROM igc_cc_interface igcci
				WHERE
					igcci.cc_header_id = p_cc_headers_rec.cc_header_id AND
		      			igcci.actual_flag = 'E'  AND
				        cc_det_pf_line_id IN (SELECT ccdpf.cc_det_pf_line_id
							     FROM igc_cc_det_pf ccdpf
							     WHERE cc_acct_line_id =
									p_cc_acct_lines_rec.cc_acct_line_id);
			END IF;

			IF (l_old_rate > p_rate)
			THEN
/* 6670549 The Select statement changed as we are entering debit amount as negative instead of positive credit amount
SELECT SUM(NVL(igcci.cc_func_cr_amt,0)) */
				SELECT SUM(NVL(igcci.cc_func_dr_amt,0))
				INTO l_tran_amount
				FROM igc_cc_interface igcci
				WHERE
					igcci.cc_header_id = p_cc_headers_rec.cc_header_id AND
		      			igcci.actual_flag = 'E'  AND
				        cc_det_pf_line_id IN (SELECT ccdpf.cc_det_pf_line_id
							     FROM igc_cc_det_pf ccdpf
							     WHERE cc_acct_line_id =
									p_cc_acct_lines_rec.cc_acct_line_id);
			END IF;


			g_line_num := g_line_num + 1;


			IF (p_cc_headers_rec.cc_acct_date <= p_rate_date)
			THEN
				l_cc_interface_rec.cc_transaction_date   :=  p_rate_date;
			END IF;

			IF (p_cc_headers_rec.cc_acct_date > p_rate_date)
			THEN
				l_cc_interface_rec.cc_transaction_date   :=  p_cc_headers_rec.cc_acct_date ;
			END IF;


			l_cc_interface_rec.batch_line_num      	 :=  g_line_num;

                        -- bug 2043221 ssmales - statement below added

                        l_withheld_tran_amt := ((NVL(p_cc_acct_lines_rec.cc_func_withheld_amt,0)
                                                * p_rate)
                                                / l_old_rate )
                                                - NVL(p_cc_acct_lines_rec.cc_func_withheld_amt,0);

                        l_tran_amount := Nvl(l_tran_amount,0) + Nvl(l_withheld_tran_amt,0);

                        -- Bug 2409502, Calculate non recoverable tax
			/*EB Tax uptake - Bug No : 6472296*/
/*
                        igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_tran_amount,
                		p_tax_amount        => l_tran_tax_amt);
*/
			IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_tran_amount,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_tran_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);
				/*EB Tax uptake - Bug No : 6472296 END*/
				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
	                l_tran_amount := l_tran_amount + Nvl(l_tran_tax_amt,0);

                        -- Bug 2409502, End

			IF (l_old_rate < p_rate)
			THEN
				l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
				l_cc_interface_rec.cc_func_dr_amt           :=  ABS(l_tran_amount);
				Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
				END IF;
			END IF;

			IF (l_old_rate > p_rate)
			THEN
				l_cc_interface_rec.cc_func_cr_amt           :=  NULL; /* 6670549 ABS(l_tran_amount);*/
				l_cc_interface_rec.cc_func_dr_amt           :=  l_tran_amount; /* 6670549 NULL;*/
				Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
				END IF;
			END IF;


		END IF;
	END IF;

	/* Payment Forecast Row */
	IF (p_type = 'P')
	THEN
		IF (p_cc_headers_rec.cc_type = 'R') AND
           	   (p_process_type = 'F')
		THEN
/*Bug No : 6341012. SLA Uptake. CC_Account_line_id should not be Null */
			l_cc_interface_rec.cc_acct_line_id          :=   p_cc_acct_lines_rec.cc_acct_line_id;
			l_cc_interface_rec.cc_det_pf_line_id        :=  p_cc_pmt_fcst_rec.parent_det_pf_line_id;
			l_cc_interface_rec.budget_dest_flag         :=  'S';
			l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.parent_header_id;
			l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.parent_acct_line_id;
			l_cc_interface_rec.reference_3              :=  l_cover_cc_version_num + 1;
--		Bug 6341012  made reference_4 to be assigned from p_cc_headers_rec.cc_num rather than from p_cc_pmt_fcst.cc_det_pf_line_id
			l_cc_interface_rec.reference_4		    :=  p_cc_headers_rec.cc_num;
			l_cover_cc_det_pf_date  := NULL;

                        SELECT cc_det_pf_date
                        INTO l_cover_cc_det_pf_date
			FROM igc_cc_det_pf
			WHERE cc_det_pf_line_id = p_cc_pmt_fcst_rec.parent_det_pf_line_id;
		ELSE
/*Bug No : 6341012. SLA Uptake. CC_Account_line_id should not be Null */
			l_cc_interface_rec.cc_acct_line_id          :=   p_cc_acct_lines_rec.cc_acct_line_id;
			l_cc_interface_rec.cc_det_pf_line_id        :=  p_cc_pmt_fcst_rec.cc_det_pf_line_id;
			l_cc_interface_rec.budget_dest_flag         :=  'S';
			l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.cc_header_id;
			l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.cc_acct_line_id;
			l_cc_interface_rec.reference_3              :=  p_cc_headers_rec.cc_version_num + 1;
--		Bug 6341012  made reference_4 to be assigned from p_cc_headers_rec.cc_num rather than from p_cc_pmt_fcst.cc_det_pf_line_id
			l_cc_interface_rec.reference_4		    :=  p_cc_headers_rec.cc_num;

		END IF;

		/* Year-end processing */

		l_func_amt        := 0;
                l_func_billed_amt := 0;

		IF (p_process_type = 'Y')
		THEN

			SELECT cc_det_pf_func_amt,cc_det_pf_func_billed_amt
			INTO l_func_amt,l_func_billed_amt
			FROM igc_cc_det_pf_v
			WHERE cc_det_pf_line_id = p_cc_pmt_fcst_rec.cc_det_pf_line_id;

		        l_unbilled_amt       :=  l_func_amt - l_func_billed_amt;



                        -- Bug 2409502, calculate the non recoverable tax
			/*EB Tax uptake - Bug No : 6472296*/
/*
                        igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_unbilled_amt,
                		p_tax_amount        => l_unbilled_tax_amt);
*/
                        IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_unbilled_amt,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_unbilled_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);

				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
			/*EB Tax uptake - Bug No : 6472296 END*/
                        l_unbilled_amt := l_unbilled_amt + Nvl(l_unbilled_tax_amt,0);


                        -- Bug  2409502, End
			/* Reserve on first date of year */
	       		g_line_num := g_line_num + 1;

			l_cc_interface_rec.cc_transaction_date      :=  p_yr_end_dr_date;
			l_cc_interface_rec.batch_line_num           :=  g_line_num;
			l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
			l_cc_interface_rec.cc_func_dr_amt           :=  l_unbilled_amt;

			Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
			END IF;

			/* Liquidate on last date of fiscal year */

			g_line_num := g_line_num + 1;

			l_cc_interface_rec.cc_transaction_date      :=  p_yr_end_cr_date;
			l_cc_interface_rec.batch_line_num           :=  g_line_num;
			l_cc_interface_rec.cc_func_cr_amt           :=  NULL; /* 6670549 l_unbilled_amt; */
			l_cc_interface_rec.cc_func_dr_amt           :=  -l_unbilled_amt; /* 6670549 NULL; */

			Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
			END IF;
		ELSIF (p_process_type = 'F')
		THEN
			/* Re_valuation Fix*/
			l_tran_amount       := 0;
			l_func_billed_amt   := 0;
			l_func_amt          := 0;
                        l_ent_amt           := 0;
                        l_billed_amt        := 0;

			BEGIN
				SELECT cc_det_pf_entered_amt,
                                       cc_det_pf_func_amt,
                                       cc_det_pf_billed_amt,
                                       cc_det_pf_func_billed_amt
				INTO   l_ent_amt,
                                       l_func_amt,
                                       l_billed_amt,
                                       l_func_billed_amt
				FROM   igc_cc_det_pf_v
				WHERE  cc_det_pf_line_id = p_cc_pmt_fcst_rec.cc_det_pf_line_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_func_billed_amt   := 0;
					l_func_amt          := 0;
                        		l_ent_amt           := 0;
                        		l_billed_amt        := 0;
			END;

			l_tran_amount :=
			( (l_ent_amt - l_billed_amt) * p_cc_headers_rec.conversion_rate ) -
                           (l_func_amt - l_func_billed_amt);


                        -- Bug 2409502, Calculate non recoverable tax
			/*EB Tax uptake - Bug No : 6472296*/
/*
                        igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                		(p_api_version       => 1.0,
                		p_init_msg_list     => FND_API.G_FALSE,
                		p_commit            => FND_API.G_FALSE,
                		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                		x_return_status     => l_return_status,
                		x_msg_count         => l_msg_count,
                		x_msg_data          => l_msg_data,
                		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                		p_amount            => l_tran_amount,
                		p_tax_amount        => l_tran_tax_amt);
*/
                        IF (l_taxable_flag = 'Y') THEN
				IGC_ETAX_UTIL_PKG.Calculate_Tax
					(P_CC_Header_Rec	=>p_cc_headers_rec,
					P_Calling_Mode		=>null,
					P_Amount		=>l_tran_amount,
					P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
					P_Tax_Amount		=>l_tran_tax_amt,
					P_Return_Status		=>l_return_status,
					P_Error_Code            =>P_Error_Code);
				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN
				    RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
			/*EB Tax uptake - Bug No : 6472296 END*/
                        l_tran_amount := l_tran_amount + Nvl(l_tran_tax_amt,0);
                        -- Bug 2409502, End
			IF  (l_tran_amount <> 0)
			THEN

				g_line_num := g_line_num + 1;

				IF (p_cc_headers_rec.cc_type = 'R')
				THEN
        				IF (l_cover_cc_det_pf_date <= p_revalue_fix_date)
					THEN
						l_cc_interface_rec.cc_transaction_date   :=  p_revalue_fix_date;
					ELSE
						l_cc_interface_rec.cc_transaction_date   :=  l_cover_cc_det_pf_date;
					END IF;
				END IF;

				IF (p_cc_headers_rec.cc_type <> 'R')
				THEN
        				IF (p_cc_pmt_fcst_rec.cc_det_pf_date <= p_revalue_fix_date)
					THEN
						l_cc_interface_rec.cc_transaction_date   :=  p_revalue_fix_date;
					ELSE
						l_cc_interface_rec.cc_transaction_date   :=  p_cc_pmt_fcst_rec.cc_det_pf_date;
					END IF;
				END IF;

				l_cc_interface_rec.batch_line_num      	 :=  g_line_num;

				IF (l_tran_amount < 0)
				THEN
					l_cc_interface_rec.cc_func_cr_amt           :=  NULL; /* 6670549 ABS(l_tran_amount); */
					l_cc_interface_rec.cc_func_dr_amt           :=  l_tran_amount; /* 6670549 NULL; */
					Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
					END IF;
				END IF;

				IF (l_tran_amount > 0)
				THEN
					l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
					l_cc_interface_rec.cc_func_dr_amt           :=  ABS(l_tran_amount);
					Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
					END IF;
				END IF;
			END IF;
		ELSIF (p_process_type = 'R')
		THEN
			/* Re_valuation */
			l_tran_amount       := 0;
			l_func_billed_amt   := 0;
			l_func_amt          := p_cc_pmt_fcst_rec.cc_det_pf_func_amt;
                        /* Fixed Bug 1497003 By including Confirmed state */
			IF ( (p_cc_headers_rec.cc_state = 'CT') OR
			     (p_cc_headers_rec.cc_state = 'CM'))
			THEN
				l_func_billed_amt := 0;

				BEGIN
					SELECT cc_det_pf_func_billed_amt
					INTO   l_func_billed_amt
					FROM   igc_cc_det_pf_v
					WHERE  cc_det_pf_line_id = p_cc_pmt_fcst_rec.cc_det_pf_line_id;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						l_func_billed_amt := 0;
				END;
			ELSE
				l_func_billed_amt := 0;
			END IF;

			IF ((l_func_amt > l_func_billed_amt) AND (p_rate > 0))
			THEN
				g_line_num := g_line_num + 1;

        			IF (p_cc_pmt_fcst_rec.cc_det_pf_date <= p_rate_date)
				THEN
					l_cc_interface_rec.cc_transaction_date            :=  p_rate_date;
				ELSE
					l_cc_interface_rec.cc_transaction_date            :=  p_cc_pmt_fcst_rec.cc_det_pf_date;
				END IF;

				l_cc_interface_rec.batch_line_num      	 :=  g_line_num;

				l_tran_amount :=
				((p_cc_pmt_fcst_rec.cc_det_pf_func_amt - l_func_billed_amt) / l_old_rate) *
				(p_rate - l_old_rate);


                                -- Bug 2409502, Calculate non recoverable tax
			/*EB Tax uptake - Bug No : 6472296*/
/*
                                igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
                        		(p_api_version       => 1.0,
                        		p_init_msg_list     => FND_API.G_FALSE,
                        		p_commit            => FND_API.G_FALSE,
                        		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                        		x_return_status     => l_return_status,
                        		x_msg_count         => l_msg_count,
                        		x_msg_data          => l_msg_data,
                        		p_tax_id            => p_cc_acct_lines_rec.tax_id,
                        		p_amount            => l_tran_amount,
                        		p_tax_amount        => l_tran_tax_amt);
*/
                                IF (l_taxable_flag = 'Y') THEN
					IGC_ETAX_UTIL_PKG.Calculate_Tax
						(P_CC_Header_Rec	=>p_cc_headers_rec,
						P_Calling_Mode		=>null,
						P_Amount		=>l_tran_amount,
						P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
						P_Tax_Amount		=>l_tran_tax_amt,
						P_Return_Status		=>l_return_status,
						P_Error_Code            =>P_Error_Code);

					IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
					THEN
					    RAISE FND_API.G_EXC_ERROR;
					END IF;
				END IF;
				/*EB Tax uptake - Bug No : 6472296 END*/
                                l_tran_amount := l_tran_amount + Nvl(l_tran_tax_amt,0);

                                -- Bug 2409502, End
				IF (l_tran_amount < 0)
				THEN
					l_cc_interface_rec.cc_func_cr_amt           :=  NULL; /* 6670549 ABS(l_tran_amount); */
					l_cc_interface_rec.cc_func_dr_amt           :=  l_tran_amount; /* 6670549 NULL; */
					Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
					END IF;
				END IF;

				IF (l_tran_amount > 0)
				THEN
					l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
					l_cc_interface_rec.cc_func_dr_amt           :=  ABS(l_tran_amount);
					Insert_Interface_Row(l_cc_interface_rec, l_insert_return_status);

                                        IF l_insert_return_status = 'F' THEN
					  raise E_RETURN_FAIL;
					END IF;
				END IF;
			END IF;
		END IF;

	END IF; /* p_type = 'P'*/

 EXCEPTION
  When E_RETURN_FAIL then
     l_insert_status := 'F';


END Process_Interface_Row;

FUNCTION Encumber_CC
(
  p_process_type                  IN       VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_sbc_on                        IN       BOOLEAN,
  p_cbc_on                        IN       BOOLEAN,
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--  p_cc_prov_enc_type_id           IN       NUMBER,
--  p_cc_conf_enc_type_id           IN       NUMBER,
--  p_req_encumbrance_type_id       IN       NUMBER,
--  p_purch_encumbrance_type_id     IN       NUMBER,
  p_currency_code                 IN       VARCHAR2,
  p_yr_start_date                 IN       DATE,
  p_yr_end_date                   IN       DATE,
  p_yr_end_cr_date                IN       DATE,
  p_yr_end_dr_date                IN       DATE,
  p_rate_date                     IN       DATE,
  p_rate                          IN       NUMBER,
  p_revalue_fix_date              IN       DATE
) RETURN VARCHAR2
IS
	l_interface_row_count		NUMBER;
        l_insert_status                 VARCHAR2(1);
	l_cc_headers_rec                igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec             igc_cc_acct_lines%ROWTYPE;
	l_cc_pmt_fcst_rec               igc_cc_det_pf%ROWTYPE;

        l_cover_set_of_books_id     igc_cc_headers.set_of_books_id%TYPE;

	l_process_account_row           BOOLEAN :=  FALSE;

	l_debug				VARCHAR2(1);

	l_cbc_on                        BOOLEAN;
	l_batch_result_code		VARCHAR2(3);
	l_bc_return_status              VARCHAR2(2);
	l_bc_success                    BOOLEAN;


	e_process_row                   EXCEPTION;
	e_bc_execution                  EXCEPTION;
	e_cc_not_found                  EXCEPTION;
	e_delete                        EXCEPTION;

	/* Contract Commitment detail payment forecast  */
	CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
	SELECT *
	FROM igc_cc_det_pf
	WHERE cc_acct_line_id =  t_cc_acct_line_id;
               /* Current year payment forecast lines only */

	/* Contract Commitment account lines  */

	CURSOR c_account_lines(t_cc_header_id NUMBER) IS
	SELECT *
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

BEGIN
	SAVEPOINT Execute_Budgetary_Ctrl1;

	g_line_num      := 0;


        BEGIN

		SELECT *
		INTO l_cc_headers_rec
		FROM igc_cc_headers
		WHERE cc_header_id = p_cc_header_id;

	EXCEPTION

		WHEN OTHERS
		THEN
			RAISE E_CC_NOT_FOUND;

	END;


	IF (l_cc_headers_rec.cc_type = 'R')
	THEN
		SELECT set_of_books_id
                INTO l_cover_set_of_books_id
		FROM igc_cc_headers
                WHERE cc_header_id = l_cc_headers_rec.parent_header_id;
	END IF;

	/* Delete existing interface rows */

	IF (l_cc_headers_rec.cc_type = 'R')
	THEN
		BEGIN

			DELETE igc_cc_interface
			WHERE cc_header_id = l_cc_headers_rec.parent_header_id AND
			      actual_flag = 'E';
		EXCEPTION
			WHEN OTHERS
			THEN
				NULL;
		END;

		COMMIT;
	END IF;

-- Commented out the following IF caluse as we want all the records
-- to be cleared out of of the IGC_CC_INTERFACE table.
-- Bug 1916208, Bidisha S 2 Aug 2001
--	IF (l_cc_headers_rec.cc_type <> 'R')
--	THEN
		BEGIN

			DELETE igc_cc_interface
			WHERE cc_header_id = p_cc_header_id AND
			      actual_flag = 'E';
		EXCEPTION
			WHEN OTHERS
			THEN
				NULL;
		END;

         IF l_cc_headers_rec.cc_type = 'C'
         THEN
             -- Delete all the child releases.
             BEGIN

		DELETE igc_cc_interface
		WHERE  cc_header_id IN (SELECT cc_header_id
                                       FROM   igc_cc_headers
                                       WHERE  parent_header_id = p_cc_header_id )
                AND    actual_flag = 'E';
	     EXCEPTION
		WHEN OTHERS
		THEN
			NULL;
             END;
         END IF;

		COMMIT;
--	END IF;

	SAVEPOINT Execute_Budgetary_Ctrl2;

	/* Process Interface Rows */


	OPEN c_account_lines(p_cc_header_id);

	LOOP
		FETCH c_account_lines INTO l_cc_acct_lines_rec;

		EXIT WHEN c_account_lines%NOTFOUND;

		l_process_account_row := FALSE;

		OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

		LOOP
			FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

			EXIT WHEN c_payment_forecast%NOTFOUND;

			/* Year-end processing */

			IF (p_process_type = 'Y')
			THEN
				/* check whether payment forecast belongs to yr-end processing year */
				IF ( (l_cc_pmt_fcst_rec.cc_det_pf_date <= p_yr_end_date) AND
				     (l_cc_pmt_fcst_rec.cc_det_pf_date >= p_yr_start_date)
				   )
				THEN

					BEGIN
						Process_Interface_Row(
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--						p_cc_prov_enc_type_id,
--        					p_cc_conf_enc_type_id,
--        					p_req_encumbrance_type_id,
--						p_purch_encumbrance_type_id,
        					p_currency_code,
        					l_cc_headers_rec,
        					l_cc_acct_lines_rec,
        					l_cc_pmt_fcst_rec,
        					'F',
        					'P',
						p_process_type,
  						p_yr_end_cr_date,
  						p_yr_end_dr_date,
  						p_rate_date,
  						p_rate,
                                                p_revalue_fix_date,
                                                l_insert_status
              				        );
					END;

				END IF;
			END IF;

			/* Re-valuation */

			IF (p_process_type = 'R')
			THEN
				BEGIN
					Process_Interface_Row(
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--					p_cc_prov_enc_type_id,
--        				p_cc_conf_enc_type_id,
--        				p_req_encumbrance_type_id,
--					p_purch_encumbrance_type_id,
        				p_currency_code,
        				l_cc_headers_rec,
        				l_cc_acct_lines_rec,
        				l_cc_pmt_fcst_rec,
        				'F',
        				'P',
					p_process_type,
  					p_yr_end_cr_date,
  					p_yr_end_dr_date,
  					p_rate_date,
  					p_rate,
                                        p_revalue_fix_date,
                                        l_insert_status
              			        );
				END;

                                IF l_insert_status = 'F' THEN
                                        RETURN ('F');
                                END IF;
			END IF;

			/* Re-valuation fix */

			IF (p_process_type = 'F')
			THEN
				BEGIN
					Process_Interface_Row(
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--					p_cc_prov_enc_type_id,
--        				p_cc_conf_enc_type_id,
--        				p_req_encumbrance_type_id,
--					p_purch_encumbrance_type_id,
        				p_currency_code,
        				l_cc_headers_rec,
        				l_cc_acct_lines_rec,
        				l_cc_pmt_fcst_rec,
        				'F',
        				'P',
					p_process_type,
  					p_yr_end_cr_date,
  					p_yr_end_dr_date,
  					p_rate_date,
  					p_rate,
  					p_revalue_fix_date,
                                        l_insert_status
              			        );
				END;
			END IF;

		END LOOP;

		CLOSE c_payment_forecast;

		/* Changed cc_type to cc_state in condition below to fix bug 1510337 */

	       	IF (p_cbc_on = TRUE)  AND
                   ( (p_process_type = 'R') OR
                     (p_process_type = 'F') OR
                     ( (p_process_type = 'Y') AND
                        ( (l_cc_headers_rec.cc_state = 'CL') OR
                          (l_cc_headers_rec.cc_state = 'PR') )
                     )
                    )
		THEN
			BEGIN


				Process_Interface_Row(
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--							p_cc_prov_enc_type_id,
--        						p_cc_conf_enc_type_id,
--        						p_req_encumbrance_type_id,
--							p_purch_encumbrance_type_id,
        						p_currency_code,
        						l_cc_headers_rec,
        						l_cc_acct_lines_rec,
        						l_cc_pmt_fcst_rec,
        						'F',
        						'A',
							p_process_type,
  							p_yr_end_cr_date,
  							p_yr_end_dr_date,
  							p_rate_date,
  							p_rate,
                                                        p_revalue_fix_date,
                                                        l_insert_status
              				             );
			END;

                        IF l_insert_status = 'F' and p_process_type = 'R' THEN
                            RETURN('F');
                        END IF;

		END IF;

	END LOOP;

	CLOSE c_account_lines;

	COMMIT;

	l_interface_row_count := 0;

	IF (l_cc_headers_rec.cc_type = 'R')
	THEN
		SELECT count(*)
		INTO l_interface_row_count
		FROM igc_cc_interface
		WHERE cc_header_id = l_cc_headers_rec.parent_header_id;
	END IF;

	IF (l_cc_headers_rec.cc_type <> 'R')
	THEN
		SELECT count(*)
		INTO l_interface_row_count
		FROM igc_cc_interface
		WHERE cc_header_id = p_cc_header_id;
	END IF;

	SAVEPOINT Execute_Budgetary_Ctrl4;

	 /* Execute budgetary control */

        BEGIN

 COMMIT; -- bug number 4130976

		IF (l_interface_row_count <> 0)
		THEN
			l_batch_result_code := NULL;

--			l_debug := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

			IF (l_debug_mode = 'Y')
			THEN
				l_debug := FND_API.G_TRUE;
			ELSE
				l_debug := FND_API.G_FALSE;
			END IF;

			BEGIN

				IF (l_cc_headers_rec.cc_type = 'R')
				THEN
                                        -- The call to IGCFCK updated to IGCPAFCK for bug 1844214.
                                        -- Bidisha S , 21 June 2001

					l_bc_success := IGC_CBC_PA_BC_PKG.IGCPAFCK(
                                                        p_sobid       =>  l_cover_set_of_books_id,
							p_header_id   =>  l_cc_headers_rec.parent_header_id,
			       		                p_mode        =>  'F',
						        p_actual_flag =>  'E',
						        p_ret_status  =>  l_bc_return_status,
						        p_batch_result_code => l_batch_result_code,
						        p_doc_type    =>  'CC',
						        p_debug       =>   l_debug,
						        p_conc_proc   =>   FND_API.G_FALSE);
				END IF;

				IF (l_cc_headers_rec.cc_type <> 'R')
				THEN
                                        -- The call to IGCFCK updated to IGCPAFCK for bug 1844214.
                                        -- Bidisha S , 21 June 2001

					l_bc_success := IGC_CBC_PA_BC_PKG.IGCPAFCK(
                                                        p_sobid       =>  l_cc_headers_rec.set_of_books_id,
							p_header_id   =>  l_cc_headers_rec.cc_header_id,
			       		                p_mode        =>  'F',
						        p_actual_flag =>  'E',
						        p_ret_status  =>  l_bc_return_status,
						        p_batch_result_code => l_batch_result_code,
						        p_doc_type    =>  'CC',
						        p_debug       =>   l_debug,
						        p_conc_proc   =>   FND_API.G_FALSE);
				END IF;

			EXCEPTION
				WHEN OTHERS
				THEN
					NULL;

			END;
		END IF;
	END;

	IF (l_interface_row_count <> 0)
	THEN

		IF (l_bc_success = TRUE)
		THEN
			IF ( (l_bc_return_status <> 'NA') AND
		     	     (l_bc_return_status <> 'AN') AND
		             (l_bc_return_status <> 'AA') AND
		             (l_bc_return_status <> 'AS') AND
		             (l_bc_return_status <> 'SA') AND
		             (l_bc_return_status <> 'SS') AND
		             (l_bc_return_status <> 'SN') AND
		             (l_bc_return_status <> 'NS') )
			THEN
				RETURN('F');
			ELSE
				RETURN('P');
			END IF;
		ELSE
			RETURN('F');
		END IF;
	ELSE
		RETURN('P');
	END IF;
END Encumber_CC;

FUNCTION get_budg_ctrl_params(
			       p_sob_id                    IN  NUMBER,
			       p_org_id                    IN  NUMBER,
			       p_currency_code             OUT NOCOPY VARCHAR2,
			       p_sbc_on 		   OUT NOCOPY BOOLEAN,
			       p_cbc_on 		   OUT NOCOPY BOOLEAN,
			       p_prov_enc_on               OUT NOCOPY BOOLEAN,
			       p_conf_enc_on               OUT NOCOPY BOOLEAN,
/*Bug No : 6341012. SLA Uptake. Encumbrance Types are not required*/
--			       p_req_encumbrance_type_id   OUT NOCOPY NUMBER,
--			       p_purch_encumbrance_type_id OUT NOCOPY NUMBER,
--			       p_cc_prov_enc_type_id       OUT NOCOPY NUMBER,
--			       p_cc_conf_enc_type_id       OUT NOCOPY NUMBER,
                               p_msg_data                  OUT NOCOPY VARCHAR2,
                               p_msg_count                 OUT NOCOPY NUMBER,
                               p_usr_msg                   OUT NOCOPY VARCHAR2
			      ) RETURN BOOLEAN
IS
	l_currency_code                 gl_sets_of_books.currency_code%TYPE;
	l_enable_budg_control_flag      gl_sets_of_books.enable_budgetary_control_flag%TYPE;
	l_cc_bc_enable_flag             igc_cc_bc_enable.cc_bc_enable_flag%TYPE;
/*Bug No : 6341012. SLA Uptake. Encumbrance Types are not required*/
--	l_req_encumbrance_type_id       financials_system_params_all.req_encumbrance_type_id%TYPE;
--	l_purch_encumbrance_type_id     financials_system_params_all.purch_encumbrance_type_id%TYPE;
	l_req_encumbrance_flag		financials_system_params_all.req_encumbrance_flag%TYPE;
	l_purch_encumbrance_flag	financials_system_params_all.purch_encumbrance_flag%TYPE;
--	l_cc_prov_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_prov_encmbrnc_enable_flag%TYPE;
--	l_cc_conf_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_conf_encmbrnc_enable_flag%TYPE;
--	l_cc_prov_enc_type_id           igc_cc_encmbrnc_ctrls.cc_prov_encmbrnc_type_id%TYPE;
--      l_cc_conf_enc_type_id           igc_cc_encmbrnc_ctrls.cc_conf_encmbrnc_type_id%TYPE;

	e_cc_not_found              EXCEPTION;
	e_cc_invalid_set_up         EXCEPTION;
	e_gl_data		    EXCEPTION;
	e_null_parameter            EXCEPTION;


BEGIN
	 p_currency_code  		:= NULL;

	 p_sbc_on 			:= FALSE;
	 p_cbc_on 			:= FALSE;
	 p_prov_enc_on 			:= FALSE;
	 p_conf_enc_on			:= FALSE;
/*Bug No : 6341012. SLA Uptake. Encumbrance Types are not required*/
--	 p_req_encumbrance_type_id      := NULL;
--	 p_purch_encumbrance_type_id    := NULL;
--	 p_cc_prov_enc_type_id          := NULL;
--	 p_cc_conf_enc_type_id          := NULL;

	l_enable_budg_control_flag := 'N';

	IF (p_org_id IS NULL)
	THEN
		fnd_message.set_name('IGC', 'IGC_CC_NO_ORG_ID');
		fnd_msg_pub.add;
		RAISE E_NULL_PARAMETER;
	END IF;

	IF (p_sob_id IS NULL)
	THEN
		fnd_message.set_name('IGC', 'IGC_CC_NO_SOB_ID');
		fnd_msg_pub.add;
		RAISE E_NULL_PARAMETER;
	END IF;


	/* Check whether SBC is turned on */

	BEGIN

		SELECT  NVL(enable_budgetary_control_flag,'N'),currency_code
		INTO    l_enable_budg_control_flag,l_currency_code
		FROM    gl_sets_of_books
		WHERE   set_of_books_id = p_sob_id;

	EXCEPTION

		WHEN NO_DATA_FOUND
		THEN
			l_enable_budg_control_flag := 'N';
	END;

	p_currency_code := l_currency_code;


	IF ( NVL(l_enable_budg_control_flag,'N') = 'Y')
	THEN
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID's are not required*/
		BEGIN
			SELECT  req_encumbrance_flag, purch_encumbrance_flag
			INTO    l_req_encumbrance_flag, l_purch_encumbrance_flag
			FROM    financials_system_params_all
			WHERE   set_of_books_id = p_sob_id AND
				org_id = p_org_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				l_req_encumbrance_flag      := 'N';
				l_purch_encumbrance_flag    := 'N';
		END;

		p_sbc_on := TRUE;

               	IF (l_req_encumbrance_flag = 'Y') OR ( l_purch_encumbrance_flag = 'Y')
		THEN

			/* Check whether CBC is turned on */

			BEGIN

				SELECT  cc_bc_enable_flag
				INTO    l_cc_bc_enable_flag
				FROM    igc_cc_bc_enable
				WHERE   set_of_books_id = p_sob_id;

			EXCEPTION

				WHEN NO_DATA_FOUND
				THEN
					l_cc_bc_enable_flag := 'N';
			END;

			IF (l_cc_bc_enable_flag = 'Y')
			THEN
				p_cbc_on := TRUE;
			ELSE
				p_cbc_on := FALSE;
			END IF;



			IF (NVL(l_req_encumbrance_flag,'N') = 'Y')
			THEN
			       p_prov_enc_on := TRUE;
			ELSE
			       p_prov_enc_on := FALSE;
			END IF;

			IF (NVL(l_purch_encumbrance_flag,'N') = 'Y')
			THEN
				p_conf_enc_on := TRUE;
			ELSE
				p_conf_enc_on := FALSE;
			END IF;
		END IF;
	END IF;

        RETURN TRUE;
EXCEPTION

	WHEN  E_CC_INVALID_SET_UP OR E_NULL_PARAMETER
	THEN
		 p_currency_code  		:= NULL;
		 p_sbc_on 			:= FALSE;
		 p_cbc_on 			:= FALSE;
		 p_prov_enc_on 			:= FALSE;
		 p_conf_enc_on			:= FALSE;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID's are not required*/
/*
                 p_req_encumbrance_type_id      := NULL;
		 p_purch_encumbrance_type_id    := NULL;
		 p_cc_prov_enc_type_id          := NULL;
		 p_cc_conf_enc_type_id          := NULL;
*/

		 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                             p_data  => p_msg_data );
		 RETURN FALSE;

	WHEN OTHERS
	THEN
		 p_currency_code  		:= NULL;
		 p_sbc_on 			:= FALSE;
		 p_cbc_on 			:= FALSE;
		 p_prov_enc_on 			:= FALSE;
		 p_conf_enc_on			:= FALSE;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID's are not required*/
/*
		 p_req_encumbrance_type_id      := NULL;
		 p_purch_encumbrance_type_id    := NULL;
		 p_cc_prov_enc_type_id          := NULL;
		 p_cc_conf_enc_type_id          := NULL;
*/

		FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                          'get_budg_ctrl_params');

		FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                            p_data  => p_msg_data );

		 RETURN FALSE;

END get_budg_ctrl_params;

BEGIN
    l_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level  := FND_LOG.LEVEL_STATEMENT;

END IGC_CC_REP_YEP_PVT;

/
