--------------------------------------------------------
--  DDL for Package Body OKS_IMPORT_POST_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IMPORT_POST_INSERT" AS
-- $Header: OKSPKIMPPOIB.pls 120.7.12010000.3 2010/02/12 11:44:59 harlaksh ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OKSPKIMPPOIB.pls   Created By Mihira Karra                         |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Service Contracts Import Post Insert Routines Package              |
--|                                                                       |
--|  Bug:7916240 -Renewal of Imported Subscription Contract has Incorrect |
--|               Billing Schedule.Changes are made in the procedure      |
--|               Generate_bil_sch_Subs_lines                             |
--|  Bug:9019205 -Service Contracts Import program fails incase of using user|
--|               defined uoms.                                             |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'OKS_IMPORT_INSERT';

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_NAME     CONSTANT VARCHAR2(50) := 'oks.plsql.import.' || G_PKG_NAME;
G_WORKER_REQ_ID   CONSTANT NUMBER       := FND_GLOBAL.conc_request_id;
G_MODULE_HEAD     CONSTANT VARCHAR2(60) := G_MODULE_NAME || '(Req Id = '||G_WORKER_REQ_ID||').';
G_LOG_LEVEL       CONSTANT NUMBER       := fnd_log.G_CURRENT_RUNTIME_LEVEL;
G_UNEXPECTED_LOG  CONSTANT BOOLEAN      := fnd_log.level_unexpected >= G_LOG_LEVEL AND
                                            fnd_log.TEST(fnd_log.level_unexpected, G_MODULE_HEAD);
G_ERROR_LOG       CONSTANT BOOLEAN      := G_UNEXPECTED_LOG AND fnd_log.level_error >= G_LOG_LEVEL;
G_EXCEPTION_LOG   CONSTANT BOOLEAN      := G_ERROR_LOG AND fnd_log.level_exception >= G_LOG_LEVEL;
G_EVENT_LOG       CONSTANT BOOLEAN      := G_EXCEPTION_LOG AND fnd_log.level_event >= G_LOG_LEVEL;
G_PROCEDURE_LOG   CONSTANT BOOLEAN      := G_EVENT_LOG AND fnd_log.level_procedure >= G_LOG_LEVEL;
G_STMT_LOG        CONSTANT BOOLEAN      := G_PROCEDURE_LOG AND fnd_log.level_statement >= G_LOG_LEVEL;

--==========================
-- PROCEDURES AND FUNCTIONS
--==========================


--========================================================================
-- PROCEDURE : 	Generate_bil_sch_Subs_lines     PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure will generate Billing Streams and schedules
--		for Subscription Lines
--=========================================================================

PROCEDURE Generate_bil_sch_Subs_lines
IS
	l_stmt_num  NUMBER := 0;
	l_routine   CONSTANT VARCHAR2(30) := 'Generate_bil_sch_Subs_lines';
	l_int_count     NUMBER := 0;
	l_stg_count     NUMBER := 0;
	l_recur_bill_occurance NUMBER := 0 ;

  BEGIN
	IF G_PROCEDURE_LOG THEN
		 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  ');

	END IF;



-- Generates Billing Streams for subscription lines
	l_stmt_num := 10;

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL) THEN
      INTO OKS_STREAM_LEVELS_B
	(ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

  VALUES (ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)


SELECT okc_p_util.raw_to_number(sys_guid())	ID
       ,INNER_Q2.SEQ                          SEQUENCE_NO
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 'DAY'
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS null THEN 'DAY'
	      WHEN INNER_Q2.SEQ = 3  THEN	'DAY'
	      ELSE INNER_Q1.BILLING_INTERVAL_PERIOD
	 END)  UOM_CODE
       ,(CASE WHEN INNER_Q2.SEQ = 1 THEN INNER_Q1.LIN_STR_DT
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date is not null THEN INNER_Q1.FIRST_BILL_UPTO_DATE + 1
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE
	      WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LAST_BILL_FROM_DATE
	 END) START_DATE
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LIN_END_DT
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
              WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT
	 END) END_DATE
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 1
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 1
	      WHEN INNER_Q2.SEQ = 3  THEN 1
	 END) LEVEL_PERIODS
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1 -- including the days between the difference
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
              WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date is NULL THEN  INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	      WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	      ELSE INNER_Q1.BILLING_INTERVAL_DURATION
	 END) UOM_PER_PERIOD
       ,(CASE WHEN INNER_Q1.FBILL IS NOT NULL AND INNER_Q1.LBILL IS NOT NULL
			THEN (CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
						  THEN INNER_Q1.FBILL
				   WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
						  THEN (INNER_Q1.SUBTOTAL - nvl(INNER_Q1.FBILL,0) - nvl(INNER_Q1.LBILL,0))
        			   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
						  THEN  ROUND(((INNER_Q1.SUBTOTAL - nvl(INNER_Q1.FBILL,0) - nvl(INNER_Q1.LBILL,0))/INNER_Q1.RECUR_BILL_OCCURANCES),2) /*Bug:7916240*/
        			   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
						  THEN INNER_Q1.LBILL
			           WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LBILL
			      END)
              WHEN INNER_Q1.FBILL IS NULL AND INNER_Q1.LBILL IS NULL
			THEN (CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
						THEN ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
			           WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
						THEN  ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION ,2) /*BUg:71962410 removed * INNER_Q1.RECUR_BILL_OCCURANCES*/
			           WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
                                                THEN Round(((((INNER_Q1.SUBTOTAL -
							ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
								*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES))/INNER_Q1.RECUR_BILL_OCCURANCES),2)                     /*Bug:7916240*/
                                   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
                                                THEN inner_q1.subtotal -
                                                        ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
                                   WHEN INNER_Q2.SEQ = 3
                                                THEN inner_q1.subtotal -
                                                        ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS),2) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1
								- round((INNER_Q1.SUBTOTAL - (ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS),2) *
										(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1))/CALC_BILL_PERIOD_2 ,2)
												*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES
                              END)
              WHEN INNER_Q1.FBILL IS NULL AND INNER_Q1.LBILL IS NOT NULL
			THEN (CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
						THEN  ROUND((INNER_Q1.SUBTOTAL - INNER_Q1.LBILL)/DAY_FIRST_MID_STR  * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) * 1 ,2)
				   WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
						THEN ROUND(((INNER_Q1.SUBTOTAL - INNER_Q1.LBILL)/INNER_Q1.RECUR_BILL_OCCURANCES),2)     /*Bug:7916240*/
        			   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
						THEN ROUND((INNER_Q1.SUBTOTAL - ROUND((INNER_Q1.SUBTOTAL - INNER_Q1.LBILL)/DAY_FIRST_MID_STR
							* (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) * 1 ,2) - INNER_Q1.LBILL)/INNER_Q1.RECUR_BILL_OCCURANCES,2)  /*Bug:7916240*/
				   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
						THEN INNER_Q1.LBILL
			           WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LBILL
			      END)
              WHEN INNER_Q1.FBILL IS NOT NULL AND INNER_Q1.LBILL IS NULL
			THEN (CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
						THEN  INNER_Q1.FBILL
				   WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
						THEN ROUND((INNER_Q1.SUBTOTAL)/CALC_BILL_PERIOD_1 * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
        			   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
						THEN ROUND((INNER_Q1.SUBTOTAL - INNER_Q1.FBILL)/CALC_BILL_PERIOD_2 * INNER_Q1.BILLING_INTERVAL_DURATION ,2)        /*Bug:71962410 removed * INNER_Q1.RECUR_BILL_OCCURANCES*/
        			   WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
						THEN INNER_Q1.SUBTOTAL - ROUND((INNER_Q1.SUBTOTAL)/CALC_BILL_PERIOD_1 * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
				   WHEN INNER_Q2.SEQ = 3
						THEN INNER_Q1.SUBTOTAL - INNER_Q1.FBILL
								- ROUND((INNER_Q1.SUBTOTAL - INNER_Q1.FBILL)/CALC_BILL_PERIOD_2 *
									INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
			      END)
         END) LEVEL_AMOUNT
       ,INNER_Q1.RECUR_BILL_OCCURANCES FREQUENCY
       ,INNER_Q1.*
       ,INNER_Q2.*
FROM
	(SELECT  OKCLINB_LINE.ID              LINE_ID
		,null		              CHR_ID
		,OKCLINB_LINE.ID              CLE_ID
		,OKCHDRB.ID                   DNZ_CHR_ID
		,OLSTG.FIRST_BILL_UPTO_DATE   FIRST_BILL_UPTO_DATE
	        ,OLSTG.FIRST_BILLED_AMOUNT    FBILL
	        ,OLSTG.LAST_BILLED_AMOUNT     LBILL
		,(CASE	WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 )= OLSTG.END_DATE THEN 1
			WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1) = OLSTG.END_DATE  THEN 2
			WHEN  OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 2
			WHEN  OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 3
		  END) NUM_STREAMS
		,OLSTG.BILLING_INTERVAL_PERIOD					BILLING_INTERVAL_PERIOD
		/*,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD ='DAY'  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1 ,OLSTG.START_DATE) -- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'DAY' THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) CALC_BILL_PERIOD_2 */ /*Modified for bug:9019205*/
                  ,(CASE WHEN bip.tce_code ='DAY'   and  bip.quantity =1   THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN bip.tce_code ='DAY'    and bip.quantity =7    THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN bip.tce_code ='MONTH' and bip.quantity =1 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN bip.tce_code ='MONTH' and bip.quantity = 3  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN bip.tce_code ='DAY'   and  bip.quantity =1 THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN bip.tce_code ='DAY'    and bip.quantity =7 THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN bip.tce_code ='MONTH' and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
	                WHEN bip.tce_code ='MONTH' and bip.quantity = 3 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
		        WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) CALC_BILL_PERIOD_2
		,(OLSTG.END_DATE  - OLSTG.START_DATE)+1				NO_OF_DAYS
		,OLSTG.LAST_BILL_FROM_DATE - OLSTG.START_DATE			DAY_FIRST_MID_STR
		,OLSTG.LAST_BILL_FROM_DATE -(OLSTG.FIRST_BILL_UPTO_DATE +1) +1   DAY_MID_STR
		,OLSTG.LINE_TYPE						LINE_TYPE
		,OLSTG.RECUR_BILL_OCCURANCES					RECUR_BILL_OCCURANCES
		,OLSTG.BILLING_INTERVAL_DURATION				BILLING_INTERVAL_DURATION
		,nvl(OKCLINB_LINE.PRICE_NEGOTIATED,0)				SUBTOTAL
		,OLSTG.START_DATE						LIN_STR_DT
		,OLSTG.END_DATE							LIN_END_DT
		,OLSTG.LAST_BILL_FROM_DATE					LAST_BILL_FROM_DATE
		,1								OBJECT_VERSION_NUMBER
		,null								REQUEST_ID -- need to confirm
		,FND_GLOBAL.USER_ID						CREATED_BY
		,SYSDATE							CREATION_DATE
		,FND_GLOBAL.USER_ID						LAST_UPDATED_BY
		,SYSDATE							LAST_UPDATE_DATE
		,FND_GLOBAL.LOGIN_ID						LAST_UPDATE_LOGIN
                ,bip.tce_code                                                   tce_code         /*Added for bug:9019205*/
                ,bip.quantity                                                   quantity
	 FROM  OKS_INT_LINE_STG_TEMP      OLSTG
	      ,OKS_INT_HEADER_STG_TEMP    HDRSTG
	      ,OKC_K_HEADERS_ALL_B        OKCHDRB
              ,OKC_K_LINES_B              OKCLINB_LINE
              ,OKC_TIME_CODE_UNITS_B      BIP
              ,OKC_TIME_CODE_UNITS_TL     BIPTL
         WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
	 AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
	 AND   HDRSTG.INTERFACE_STATUS ='S'
	 AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
	 AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
	 AND   OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
	 AND   OLSTG.LINE_TYPE='SUBSCRIPTION'
         AND   OLSTG.billing_interval_period=BIP.uom_code(+)              /*Modifiefd for bug:9019205*/
         AND   BIP.uom_code = BIPTL.uom_code
         AND   BIP.tce_code = BIPTL.tce_code
         AND   BIPTL.language(+)=USERENV('LANG')) INNER_Q1

	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= 3) INNER_Q2
WHERE INNER_Q2.SEQ <= INNER_Q1.NUM_STREAMS;

/*	IF G_STMT_LOG THEN

		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
	END IF;  */

l_stmt_num :=20;

	SELECT MAX(RECUR_BILL_OCCURANCES) INTO l_recur_bill_occurance FROM OKS_INT_LINE_STG_TEMP ;

--This query creates billing schedules from streams for Subscription lines

l_stmt_num :=30 ;

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	 INTO OKS_LEVEL_ELEMENTS
		(ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
	VALUES (ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
SELECT   SUBS_SCH_DT.*
	,(CASE WHEN SUBS_SCH_DT.INVOICING_RULE_ID = -2 THEN
			(CASE WHEN SUBS_SCH_DT.DATE_START >= SYSDATE THEN SUBS_SCH_DT.DATE_START
				ELSE SYSDATE
			END)
	       WHEN SUBS_SCH_DT.INVOICING_RULE_ID = -3 THEN
			(CASE WHEN SUBS_SCH_DT.DATE_END >= SYSDATE THEN SUBS_SCH_DT.DATE_END
				ELSE SYSDATE
			END)
	  END) DATE_TRANSACTION

	,(CASE WHEN SUBS_SCH_DT.INVOICING_RULE_ID = -2 THEN SUBS_SCH_DT.DATE_START
	       WHEN SUBS_SCH_DT.INVOICING_RULE_ID = -3 THEN SUBS_SCH_DT.DATE_END +1
	  END)  DATE_TO_INTERFACE
FROM
	(SELECT	 okc_p_util.raw_to_number(sys_guid())	ID
		,INNER_Q2.SEQ 				SEQUENCE_NUMBER

		,(CASE  WHEN INNER_Q2.SEQ=1  THEN INNER_Q1.STRM_START_DATE
				-- IN OTHER CASES
			ELSE/* DECODE (INNER_Q1.BILLING_INTERVAL_PERIOD
                    			,'DAY'	,	MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
					,'WK'	,	MID_SM_STR_DT + (7 * (INNER_Q2.SEQ -1 ))
					,'MTH'	,	ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
					,'QRT'	,	ADD_MONTHS(MID_SM_STR_DT , 3 * (INNER_Q2.SEQ -1 ))
					,'YR'	,	ADD_MONTHS(MID_SM_STR_DT , 12 * (INNER_Q2.SEQ -1 )) )
		  END)*/
                  (CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN  MID_SM_STR_DT + INNER_Q2.SEQ -1
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN  MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ-1))
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1))
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ-1))
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ-1))
                   END )
                  END )DATE_START

		,(CASE	WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL  --first stream
				THEN 	INNER_Q1.LEVEL_AMOUNT
			WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL  -- normal stream
				THEN
					(CASE WHEN  INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) *(INNER_Q2.SEQ-1) >0
							THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS  --if it is the last schedule for the stream, value difference due to rounding is to be adjusted
										AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
											THEN INNER_Q1.LEVEL_AMOUNT
								   WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
											THEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
								   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
							     END)
					      ELSE 0
					 END)
			WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL -- then it is normal stream
				THEN
					(CASE	WHEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1) >0
									THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
													THEN INNER_Q1.LEVEL_AMOUNT
										   WHEN INNER_Q2.SEQ = INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
													THEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
										   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
									      END)
					        ELSE 0
					 END)
			WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL -- last bill stream
				THEN INNER_Q1.LEVEL_AMOUNT
			WHEN INNER_Q1.SEQUENCE_NO = 3 THEN  INNER_Q1.LEVEL_AMOUNT
	          END) AMOUNT

		,(CASE	WHEN INNER_Q1.FULLY_BILLED = 'Y' THEN SYSDATE
			ELSE NULL
		  END)								DATE_COMPLETED
		,INNER_Q1.OBJECT_VERSION_NUMBER					OBJECT_VERSION_NUMBER
		,INNER_Q1.OKS_STRM_LVL_ID					RUL_ID
		,FND_GLOBAL.USER_ID						CREATED_BY
		,SYSDATE							CREATION_DATE
		,FND_GLOBAL.USER_ID						LAST_UPDATED_BY
		,SYSDATE							LAST_UPDATE_DATE
		,INNER_Q1.CLE_ID						CLE_ID
		,INNER_Q1.DNZ_CHR_ID						DNZ_CHR_ID
		,INNER_Q1.PARENT_CLE_ID						PARENT_CLE_ID
        	,(CASE	WHEN  INNER_Q2.SEQ = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
				AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE   --first stream
						THEN INNER_Q1.FIRST_BILL_UPTO_DATE
			WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = INNER_Q1.LAST_BILL_FROM_DATE  --last stream
						THEN INNER_Q1.LIN_END_DT
				-- IN OTHER CASES
			ELSE /*DECODE( INNER_Q1.BILLING_INTERVAL_PERIOD
					, 'DAY'	, MID_SM_STR_DT - 1  + INNER_Q2.SEQ
					, 'WK'  , MID_SM_STR_DT - 1 + (7 * (INNER_Q2.SEQ))
					, 'MTH' , ADD_MONTHS(MID_SM_STR_DT - 1 , (INNER_Q2.SEQ ))
					, 'QRT' , ADD_MONTHS(MID_SM_STR_DT - 1 , 3 * (INNER_Q2.SEQ ))
					, 'YR'  , ADD_MONTHS(MID_SM_STR_DT - 1  , 12 * (INNER_Q2.SEQ )) )

		  END) */
                  (CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN  MID_SM_STR_DT-1 + INNER_Q2.SEQ
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN  MID_SM_STR_DT-1  + (7 * (INNER_Q2.SEQ))
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT-1 , (INNER_Q2.SEQ ))
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 3 * (INNER_Q2.SEQ ))
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 12 * (INNER_Q2.SEQ ))
                   END )
                    END )DATE_END
		,INNER_Q1.RECUR_BILL_OCCURANCES		FREQUENCY
		,INNER_Q1.INVOICING_RULE_ID		INVOICING_RULE_ID
	 FROM
	       (SELECT  OLSTG.LINE_INTERFACE_ID                 LINE_INTERFACE_ID
			,OKS_STRM_LVL.ID			OKS_STRM_LVL_ID
			,OKCLINB_LINE.ID                        CLE_ID
			,OKCHDRB.ID				DNZ_CHR_ID
			,OKCLINB_LINE.ID			PARENT_CLE_ID
			,OKCLINB_LINE.INV_RULE_ID		INVOICING_RULE_ID
			,1					OBJECT_VERSION_NUMBER
			,nvl(OKCLINB_LINE.PRICE_NEGOTIATED,0)  	SUBTOTAL
			,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
			,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
			,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
			,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
			,OLSTG.START_DATE			LIN_START_DT
			,OLSTG.END_DATE				LIN_END_DT
			,NVL(OLSTG.FIRST_BILLED_AMOUNT,0)	FIRST_BILL_AMOUNT
			,NVL(OLSTG.LAST_BILLED_AMOUNT,0)	LAST_BILL_AMOUNT
			,OLSTG.FIRST_BILL_UPTO_DATE		FIRST_BILL_UPTO_DATE
			,OKS_STRM_LVL.LEVEL_PERIODS		LEVEL_PERIODS
			,OKS_STRM_LVL.SEQUENCE_NO		SEQUENCE_NO
			/*,nvl(OKS_STRM_LVL.LEVEL_AMOUNT,0)	LEVEL_AMOUNT    Bug:7916240*/
                        , (CASE  WHEN  (OKS_STRM_LVL.END_DATE = OLSTG.END_DATE)   THEN
                            (CASE WHEN OKS_STRM_LVL.UOM_CODE <>'DAY' and OKS_STRM_LVL.LEVEL_PERIODS = OLSTG.RECUR_BILL_OCCURANCES then
                                     nvl( SUBTOTAL- (SELECT Sum(level_amount * LEVEL_PERIODS)
                                        FROM oks_stream_levels_b b
                                      WHERE b.cle_id = OKCLINB_LINE.ID
                                      GROUP BY b.cle_id ),SUBTOTAL) + NVL(OKS_STRM_LVL.LEVEL_AMOUNT,0)*(OKS_STRM_LVL.LEVEL_PERIODS)
                                ELSE
                                       nvl( SUBTOTAL- (SELECT Sum(level_amount * LEVEL_PERIODS)
                                        FROM oks_stream_levels_b b
                                      WHERE b.cle_id = OKCLINB_LINE.ID
                                      GROUP BY b.cle_id ),SUBTOTAL) + NVL(OKS_STRM_LVL.LEVEL_AMOUNT,0)
                                    END)
                           ELSE
                               (CASE  WHEN OKS_STRM_LVL.UOM_CODE <>'DAY'   THEN
                               NVL(OKS_STRM_LVL.LEVEL_AMOUNT,0)*(OKS_STRM_LVL.LEVEL_PERIODS)
			  ELSE
                              (CASE WHEN (OKS_STRM_LVL.LEVEL_PERIODS = OLSTG.RECUR_BILL_OCCURANCES ) THEN
                                    NVL(OKS_STRM_LVL.LEVEL_AMOUNT,0)*(OKS_STRM_LVL.LEVEL_PERIODS)
                             ELSE
                               NVL(OKS_STRM_LVL.LEVEL_AMOUNT,0)
                               END)
                           END)
                           END)LEVEL_AMOUNT
			,HDRSTG.FULLY_BILLED			FULLY_BILLED
			,OKS_STRM_LVL.START_DATE		STRM_START_DATE
			,OKS_STRM_LVL.END_DATE			STRM_END_DATE
			,(CASE	WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL THEN OLSTG.FIRST_BILL_UPTO_DATE +1
				ELSE OLSTG.START_DATE
			  END) MID_SM_STR_DT
			, OLSTG.LAST_BILL_FROM_DATE - 1		MID_SM_END_DT
			,OLSTG.LINE_TYPE			LINE_TYPE
                        ,bip.tce_code                           tce_code
                        ,bip.quantity                           quantity      /*Added for bug:9019205*/

		FROM	 OKS_INT_LINE_STG_TEMP		OLSTG
			,OKC_K_LINES_B			OKCLINB_LINE
			,OKC_K_HEADERS_ALL_B		OKCHDRB
			,OKS_INT_HEADER_STG_TEMP	HDRSTG
			,OKS_STREAM_LEVELS_B		OKS_STRM_LVL
                        ,OKC_TIME_CODE_UNITS_B          BIP
                        ,OKC_TIME_CODE_UNITS_TL          BIPTL
		WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
		AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
		AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
		AND   HDRSTG.INTERFACE_STATUS ='S'
		AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
		AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
		AND   OKS_STRM_LVL.DNZ_CHR_ID = OKCHDRB.ID
		AND  OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
		AND  OKS_STRM_LVL.CLE_ID = OKCLINB_LINE.ID
		AND  OLSTG.LINE_TYPE='SUBSCRIPTION'
                AND  OLSTG.billing_interval_period=BIP.uom_code(+)
                AND  BIP.uom_code =BIPTL.uom_code
                AND  BIP.tce_code = BIPTL.tce_code
                AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1         /*Added for bug:9019205*/

	      ,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= l_recur_bill_occurance ) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.LEVEL_PERIODS)SUBS_SCH_DT;

	/*IF G_STMT_LOG THEN
		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
	END IF;  */


/* IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');

END IF; */

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Generate_bil_sch_Subs_lines;

--========================================================================
-- PROCEDURE  :  Generate_bil_sch_Usage_lines    PRIVATE
-- PARAMETERS :
-- COMMENT    :  This procedure will invoke the API's to generate
--	         the Billing Streams and schedules for Usage Lines
--=========================================================================

PROCEDURE Generate_bil_sch_Usage_lines
IS
	l_stmt_num  NUMBER := 0;
	l_routine   CONSTANT VARCHAR2(30) := 'Generate_bil_sch_Subs_lines';
	l_int_count     NUMBER := 0;
	l_stg_count     NUMBER := 0;
	l_recur_bill_occurance NUMBER := 0 ;
 BEGIN

	IF G_PROCEDURE_LOG THEN
		 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  ');

	END IF;

--- Generates billing Streams for usage Counters
l_stmt_num := 10;

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	INTO OKS_STREAM_LEVELS_B
	(ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

  VALUES (ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

SELECT  okc_p_util.raw_to_number(sys_guid())	ID
	,INNER_Q2.SEQ  			SEQUENCE_NO
	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS null THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 3  THEN	'DAY'
	       else INNER_Q1.BILLING_INTERVAL_PERIOD
	  END)  UOM_CODE

	,(CASE WHEN INNER_Q2.SEQ = 1 THEN INNER_Q1.LIN_STR_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date is not null THEN INNER_Q1.FIRST_BILL_UPTO_DATE + 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LAST_BILL_FROM_DATE
	  END) START_DATE

	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LIN_END_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT
	  END) END_DATE

	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 1
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 1
	       WHEN INNER_Q2.SEQ = 3  THEN 1
	  END) LEVEL_PERIODS

	,(CASE  WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL
			THEN INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.CVL_START_DT + 1 -- difference in the days with the days inclusive
		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	        WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN  INNER_Q1.CVL_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1)
		WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.CVL_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	 	ELSE INNER_Q1.BILLING_INTERVAL_DURATION
	   END) UOM_PER_PERIOD

	 ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
			THEN ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
			THEN  ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
			THEN ROUND((INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
					(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
							*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
			THEN INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) *
						INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 3
			THEN
			INNER_Q1.SUBTOTAL
				- ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
				-  ROUND((INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
					(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
							*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)

	   END) LEVEL_AMOUNT
	  ,INNER_Q1.RECUR_BILL_OCCURANCES    FREQUENCY
	  ,INNER_Q1.*
	  ,INNER_Q2.*
FROM
	(SELECT  OKCLINB_SUBLINE.ID			CLE_ID
		,null					CHR_ID -- can be null for sublines
		,OKCHDRB.ID				DNZ_CHR_ID
		,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) = OLSTG.END_DATE THEN 1
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1) = OLSTG.END_DATE  THEN 2
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 2
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE  IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 3
	          END) NUM_STREAMS
		,1					OBJECT_VERSION_NUMBER
		,null					REQUEST_ID
		,FND_GLOBAL.USER_ID			CREATED_BY
		,SYSDATE				CREATION_DATE
		,FND_GLOBAL.USER_ID			LAST_UPDATED_BY
		,SYSDATE				LAST_UPDATE_DATE
		,FND_GLOBAL.LOGIN_ID			LAST_UPDATE_LOGIN
		,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
		,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
		,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
		,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
		,INNER_1.STR_DT				CVL_START_DT
		,INNER_1.END_DT				CVL_END_DT
		,OLSTG.FIRST_BILL_UPTO_DATE		FIRST_BILL_UPTO_DATE
		,nvl(INNER_1.STOTAL,0) 			SUBTOTAL
		,OLSTG.LINE_TYPE			LINE_TYPE
		,OLSTG.START_DATE			LIN_STR_DT
		,OLSTG.END_DATE				LIN_END_DT
		,(INNER_1.END_DT  - INNER_1.STR_DT)+1	NO_OF_DAYS
		/*,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD ='DAY'  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'DAY' THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) CALC_BILL_PERIOD_2*/
                ,bip.tce_code                           tce_code
                ,bip.quantity                           quantity
		,(CASE	WHEN bip.tce_code ='DAY'   and  bip.quantity =1   THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN bip.tce_code ='DAY'    and bip.quantity =7    THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN bip.tce_code ='MONTH' and bip.quantity =1 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN bip.tce_code ='MONTH' and bip.quantity = 3  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN bip.tce_code ='DAY'   and  bip.quantity =1 THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN bip.tce_code ='DAY'    and bip.quantity =7 THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN bip.tce_code ='MONTH' and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
	                WHEN bip.tce_code ='MONTH' and bip.quantity = 3 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
		        WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) CALC_BILL_PERIOD_2                        /*Added for bug:9019205*/
	 FROM	OKS_INT_LINE_STG_TEMP		OLSTG

		,(SELECT USGSTG.LINE_INTERFACE_ID   LINE_INTERFACE_ID
			,USGSTG.LINE_NUMBER	    LINE_NUMBER
			,USGSTG.START_DATE	    STR_DT
			,USGSTG.END_DATE	    END_DT
			,USGSTG.SUBTOTAL	    STOTAL
		  FROM	 OKS_INT_USAGE_COUNTER_STG_TEMP USGSTG )INNER_1

		,OKC_K_LINES_B			OKCLINB_LINE
		,OKC_K_LINES_B			OKCLINB_SUBLINE
		,OKC_K_HEADERS_ALL_B		OKCHDRB
		,OKS_INT_HEADER_STG_TEMP	HDRSTG
                ,OKC_TIME_CODE_UNITS_B		BIP
                ,OKC_TIME_CODE_UNITS_TL		BIPTL         /*Added for bug:9019205*/
	 WHERE INNER_1.LINE_INTERFACE_ID = OLSTG.LINE_INTERFACE_ID
	 AND   OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
         AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
         AND   HDRSTG.INTERFACE_STATUS ='S'
         AND   OKCLINB_LINE.DNZ_CHR_ID = OKCHDRB.ID
         AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
         AND   OLSTG.LINE_NUMBER = OKCLINB_LINE.LINE_NUMBER
         AND   OKCLINB_SUBLINE.DNZ_CHR_ID = OKCHDRB.ID
         AND   OKCLINB_SUBLINE.CLE_ID = OKCLINB_LINE.ID
         AND   OKCLINB_SUBLINE.LINE_NUMBER = INNER_1.LINE_NUMBER
         AND   OLSTG.LINE_TYPE = 'USAGE'
         AND   OLSTG.billing_interval_period=BIP.uom_code(+)
         AND   BIP.uom_code =BIPTL.uom_code
         AND   BIP.tce_code =BIPTL.tce_code
         AND   BIPTL.language(+)=USERENV('LANG')) INNER_Q1                /*Modified for bug:9019205*/

	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= 3) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.NUM_STREAMS;

  l_int_count := SQL%ROWCOUNT;
 /* IF G_STMT_LOG THEN
        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
		 'Number of records successfully inserted = ' || l_int_count );

  END IF; */

l_stmt_num :=20;

	SELECT MAX(RECUR_BILL_OCCURANCES) INTO l_recur_bill_occurance FROM OKS_INT_LINE_STG_TEMP ;

/*  IF G_STMT_LOG THEN

        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' || l_stmt_num,
		 'Value of max Recur Bill Occurance  = ' || l_recur_bill_occurance  );
  END IF; */


l_stmt_num :=30;

-- this query inserts records into level elements as schedules for billing streams for Usage Counters

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	 INTO OKS_LEVEL_ELEMENTS
		(ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
	VALUES (ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
SELECT	COV_SCH_DT.*
	,(CASE WHEN COV_SCH_DT.INVOICING_RULE_ID = -2
			THEN
				(CASE WHEN COV_SCH_DT.DATE_START >= SYSDATE THEN COV_SCH_DT.DATE_START
				      ELSE SYSDATE
				 END)
	       WHEN COV_SCH_DT.INVOICING_RULE_ID = -3
			THEN
				(CASE WHEN COV_SCH_DT.DATE_END > = SYSDATE THEN COV_SCH_DT.DATE_END
				      ELSE SYSDATE
				END)
	  END) DATE_TRANSACTION

	,(CASE WHEN COV_SCH_DT.INVOICING_RULE_ID = -2 THEN COV_SCH_DT.DATE_START
	       WHEN COV_SCH_DT.INVOICING_RULE_ID = -3 THEN COV_SCH_DT.DATE_END +1
	  END)  DATE_TO_INTERFACE

FROM
	(SELECT	okc_p_util.raw_to_number(sys_guid())					ID
		,INNER_Q2.SEQ								SEQUENCE_NUMBER
		,(CASE  WHEN INNER_Q2.SEQ = 1  AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE  -- first bill stream
				AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
						THEN INNER_Q1.CVL_START_DT

			WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = inner_q1.last_bill_from_date  -- last bill stream
					THEN INNER_Q1.last_bill_from_date
				-- IN OTHER CASES
			ELSE  /* DECODE (INNER_Q1.BILLING_INTERVAL_PERIOD
						,'DAY'	,	MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
						,'WK'	,	MID_SM_STR_DT + (7 * (INNER_Q2.SEQ -1 ))
						,'MTH'	,	ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
						,'QRT'	,	ADD_MONTHS(MID_SM_STR_DT , 3 * (INNER_Q2.SEQ -1 ))
						,'YR'	,	ADD_MONTHS(MID_SM_STR_DT , 12 * (INNER_Q2.SEQ -1 )) )
		  END )*/
                  (CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN  MID_SM_STR_DT + INNER_Q2.SEQ -1
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN  MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ-1))
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1))
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ-1 ))
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ -1))
                   END )
                   END )DATE_START

		,(CASE WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
					THEN INNER_Q1.LEVEL_AMOUNT
               	       WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL  -- normal stream
					THEN (CASE WHEN  INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) *(INNER_Q2.SEQ-1) >0
								THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS  --if it is the last schedule for the stream, value difference due to rounding is to be adjusted
											AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
													THEN INNER_Q1.LEVEL_AMOUNT
									   WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
													THEN INNER_Q1.LEVEL_AMOUNT -
														ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
									   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
							              END)
						   ELSE 0
					      END)
		       WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL -- then it is normal stream
					THEN  (CASE WHEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1) >0
								THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS
											AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
													THEN INNER_Q1.LEVEL_AMOUNT
									   WHEN INNER_Q2.SEQ = INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
													THEN INNER_Q1.LEVEL_AMOUNT -
														ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
									   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
								      END)
				                    ELSE 0
				               END)
			WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL -- last bill stream
					THEN INNER_Q1.LEVEL_AMOUNT
			WHEN INNER_Q1.SEQUENCE_NO = 3 THEN  INNER_Q1.LEVEL_AMOUNT
		  END) AMOUNT
		,(CASE WHEN INNER_Q1.FULLY_BILLED = 'Y' THEN SYSDATE
		       ELSE NULL
		  END)								DATE_COMPLETED
		,INNER_Q1.OBJECT_VERSION_NUMBER						OBJECT_VERSION_NUMBER
		,INNER_Q1.OKS_STRM_LVL_ID						RUL_ID
		,FND_GLOBAL.USER_ID							CREATED_BY
		,SYSDATE								CREATION_DATE
		,FND_GLOBAL.USER_ID							LAST_UPDATED_BY
		,SYSDATE								LAST_UPDATE_DATE
		,INNER_Q1.CLE_ID							CLE_ID
		,INNER_Q1.DNZ_CHR_ID							DNZ_CHR_ID
		,INNER_Q1.PARENT_CLE_ID							PARENT_CLE_ID
		,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE  -- first bill stream
				AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
					THEN INNER_Q1.FIRST_BILL_UPTO_DATE
		       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = inner_q1.last_bill_from_date  -- last bill stream
					THEN INNER_Q1.CVL_END_DT
				-- IN OTHER CASES
			ELSE/* DECODE( INNER_Q1.BILLING_INTERVAL_PERIOD
					, 'DAY'	, MID_SM_STR_DT + INNER_Q2.SEQ -1
					, 'WK'  , MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ)) -1
					, 'MTH' , ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ )) -1
					, 'QRT' , ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ )) -1
					, 'YR'  , ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ )) -1 )

		  END ) */
                  ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT + INNER_Q2.SEQ -1
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ)) -1
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ )) -1
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ )) -1
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ )) -1
                   END )
                    END )DATE_END
		,INNER_Q1.RECUR_BILL_OCCURANCES		FREQUENCY
		,INNER_Q1.INVOICING_RULE_ID		INVOICING_RULE_ID
	 FROM
		(SELECT  OKCLINB_SUBLINE.ID			CLE_ID
			,OKS_STRM_LVL.ID			OKS_STRM_LVL_ID
			,null					CHR_ID	-- can be null for sublines
			,OKCHDRB.ID				DNZ_CHR_ID
			,OKCLINB_LINE.ID			PARENT_CLE_ID
			,OKCLINB_LINE.INV_RULE_ID		INVOICING_RULE_ID
			,1					OBJECT_VERSION_NUMBER
			,NVL(INNER_1.STOTAL,0)			SUBTOTAL
			,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
			,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
			,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
			,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
			,INNER_1.STR_DT				CVL_START_DT
			,INNER_1.END_DT				CVL_END_DT
			,OLSTG.FIRST_BILL_UPTO_DATE	        FIRST_BILL_UPTO_DATE
			,OKS_STRM_LVL.LEVEL_PERIODS		LEVEL_PERIODS
			,OKS_STRM_LVL.LEVEL_AMOUNT		LEVEL_AMOUNT
			,HDRSTG.FULLY_BILLED			FULLY_BILLED
			,OKS_STRM_LVL.START_DATE		STRM_START_DATE
			,OKS_STRM_LVL.END_DATE			STRM_END_DATE
			,OLSTG.LINE_TYPE			LINE_TYPE
			,OKS_STRM_LVL.SEQUENCE_NO		SEQUENCE_NO
			,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL THEN OLSTG.FIRST_BILL_UPTO_DATE +1
				ELSE  INNER_1.STR_DT
			  END) MID_SM_STR_DT
			,OLSTG.LAST_BILL_FROM_DATE -1   MID_SM_END_DT
                        ,bip.tce_code                           tce_code
                        ,bip.quantity                           quantity

		 FROM	 OKS_INT_LINE_STG_TEMP		OLSTG
			,(SELECT  USGSTG.LINE_INTERFACE_ID	LINE_INTERFACE_ID
				 ,USGSTG.LINE_NUMBER		LINE_NUMBER
		                 ,USGSTG.START_DATE		STR_DT
		                 ,USGSTG.END_DATE		END_DT
		                 ,USGSTG.SUBTOTAL		STOTAL
	                  FROM  OKS_INT_USAGE_COUNTER_STG_TEMP USGSTG ) INNER_1
			,OKC_K_LINES_B			OKCLINB_LINE
			,OKC_K_LINES_B			OKCLINB_SUBLINE
			,OKC_K_HEADERS_ALL_B		OKCHDRB
			,OKS_INT_HEADER_STG_TEMP	HDRSTG
			,OKS_STREAM_LEVELS_B		OKS_STRM_LVL
                        ,OKC_TIME_CODE_UNITS_B        BIP
                        ,OKC_TIME_CODE_UNITS_TL        BIPTL             /*Added for bug:9019205*/
		 WHERE INNER_1.LINE_INTERFACE_ID  = OLSTG.LINE_INTERFACE_ID
		 AND OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
		 AND HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
		 AND NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
		 AND HDRSTG.INTERFACE_STATUS ='S'
                 AND OKCLINB_LINE.DNZ_CHR_ID = OKCHDRB.ID
                 AND OKCLINB_LINE.CHR_ID = OKCHDRB.ID
                 AND OLSTG.LINE_NUMBER = OKCLINB_LINE.LINE_NUMBER
                 AND OKCLINB_SUBLINE.DNZ_CHR_ID = OKCHDRB.ID
                 AND OKCLINB_SUBLINE.CLE_ID = OKCLINB_LINE.ID
                 AND OKCLINB_SUBLINE.LINE_NUMBER = INNER_1.LINE_NUMBER
                 AND OKS_STRM_LVL.DNZ_CHR_ID = OKCHDRB.ID
		 AND OKS_STRM_LVL.CLE_ID = OKCLINB_SUBLINE.ID
		 AND OKS_STRM_LVL.CHR_ID IS NULL
		 AND OLSTG.LINE_TYPE = 'USAGE'
                 AND OLSTG.billing_interval_period=BIP.uom_code(+)
                 AND BIP.uom_code =BIPTL.uom_code
                 AND BIP.tce_code =BIPTL.tce_code
                 AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1 	 /*Added for bug:9019205*/

		,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= l_recur_bill_occurance ) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.LEVEL_PERIODS) COV_SCH_DT;


--Generates Billing Streams for Usage Lines

l_stmt_num :=40;

INSERT ALL
    WHEN (FREQUENCY IS NOT NULL) THEN
	INTO OKS_STREAM_LEVELS_B
	(ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

  VALUES (ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)
SELECT  okc_p_util.raw_to_number(sys_guid())  ID
       ,INNER_Q2.SEQ                          SEQUENCE_NO
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 'DAY'
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 'DAY'
	      WHEN INNER_Q2.SEQ = 3  THEN 'DAY'
	      ELSE INNER_Q1.BILLING_INTERVAL_PERIOD
	 END)  UOM_CODE
       ,(CASE WHEN INNER_Q2.SEQ = 1 THEN INNER_Q1.LIN_STR_DT
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE + 1
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE
	      WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LAST_BILL_FROM_DATE
	 END) START_DATE
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LIN_END_DT
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	      WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT
	 END) END_DATE
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 1
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 1
	      WHEN INNER_Q2.SEQ = 3  THEN 1
	 END) LEVEL_PERIODS
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL
				THEN INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1 -- including the days between the difference
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN  INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	      WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	      ELSE INNER_Q1.BILLING_INTERVAL_DURATION
	  END) UOM_PER_PERIOD
       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
			THEN ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
	      WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
			THEN  ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
			THEN ROUND((INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
							(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
								*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
	      WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
			THEN INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) *
					INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
	      WHEN INNER_Q2.SEQ = 3
			THEN INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
				 -  ROUND((INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
							(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
								*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)

	 END) LEVEL_AMOUNT
       ,INNER_Q1.RECUR_BILL_OCCURANCES FREQUENCY
       ,INNER_Q1.*
       ,INNER_Q2.*
FROM
	(SELECT  OKCLINB_LINE.ID              LINE_ID
		,null		              CHR_ID
	        ,OKCLINB_LINE.ID              CLE_ID
		,OKCHDRB.ID                   DNZ_CHR_ID
	        ,OLSTG.FIRST_BILL_UPTO_DATE   FIRST_BILL_UPTO_DATE
		,OLSTG.FIRST_BILLED_AMOUNT    SUM_FBILL
	        ,OLSTG.LAST_BILLED_AMOUNT     SUM_LBILL
		,(CASE  WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) = OLSTG.END_DATE   THEN 1
	                WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1) = OLSTG.END_DATE  THEN 2
	                WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 2
	                WHEN  OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 3
	          END) NUM_STREAMS
	        ,OLSTG.BILLING_INTERVAL_PERIOD					BILLING_INTERVAL_PERIOD
		/*,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD ='DAY'  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1 ,OLSTG.START_DATE) -- no of months
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
	          END) CALC_BILL_PERIOD_1
		,(CASE  WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'DAY' THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
                        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
                        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
                        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
                        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
	          END)*/
                  ,(CASE WHEN BIP.tce_code ='DAY'   and BIP.quantity =1  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN BIP.tce_code ='DAY'   and BIP.quantity =7  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN BIP.tce_code ='MONTH' and BIP.quantity =1    THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN BIP.tce_code ='MONTH' and BIP.quantity = 3 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN BIP.tce_code ='YEAR'  and BIP.quantity =1   THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
                  ,(CASE WHEN BIP.tce_code ='MONTH' and BIP.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1)) -- no of months
                         WHEN BIP.tce_code ='MONTH' and BIP.quantity = 3 THEN MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
                         WHEN BIP.tce_code ='YEAR'  and BIP.quantity =1 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
                         WHEN BIP.tce_code ='DAY'   and BIP.quantity =7 THEN  ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
                         WHEN BIP.tce_code ='DAY'   and BIP.quantity =1 THEN  (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
                   END)CALC_BILL_PERIOD_2                                  /*Added for bug:9019205*/
		,OLSTG.LINE_TYPE				LINE_TYPE
		,OLSTG.RECUR_BILL_OCCURANCES			RECUR_BILL_OCCURANCES
		,OLSTG.BILLING_INTERVAL_DURATION		BILLING_INTERVAL_DURATION
	        ,NVL(OKCLINB_LINE.PRICE_NEGOTIATED,0)		SUBTOTAL
	        ,OLSTG.START_DATE				LIN_STR_DT
		,OLSTG.END_DATE					LIN_END_DT
		,(OLSTG.END_DATE  - OLSTG.START_DATE)+1		NO_OF_DAYS
	        ,OLSTG.LAST_BILL_FROM_DATE			LAST_BILL_FROM_DATE
		,1						OBJECT_VERSION_NUMBER
	        ,NULL						REQUEST_ID -- need to confirm
		,FND_GLOBAL.USER_ID				CREATED_BY
		,SYSDATE					CREATION_DATE
		,FND_GLOBAL.USER_ID				LAST_UPDATED_BY
		,SYSDATE					LAST_UPDATE_DATE
		,FND_GLOBAL.LOGIN_ID				LAST_UPDATE_LOGIN
                ,bip.tce_code                                   tce_code
                ,bip.quantity                                    quantity        /*Added for bug:9019205*/
	 FROM  OKS_INT_LINE_STG_TEMP      OLSTG
	      ,OKS_INT_HEADER_STG_TEMP    HDRSTG
	      ,OKC_K_HEADERS_ALL_B        OKCHDRB
              ,OKC_K_LINES_B              OKCLINB_LINE
              ,OKC_TIME_CODE_UNITS_B    BIP
              ,OKC_TIME_CODE_UNITS_TL    BIPTL                                /*Added for bug:9019205*/
	WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
	AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
	AND   HDRSTG.INTERFACE_STATUS ='S'
	AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
	AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
	AND   OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
	AND   OLSTG.LINE_TYPE ='USAGE'
        AND OLSTG.billing_interval_period=BIP.uom_code(+)
        AND  BIP.uom_code =BIPTL.uom_code
        AND   BIP.tce_code =BIPTL.tce_code
        AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1                /*Added for bug:9019205*/
	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= 3) INNER_Q2
WHERE INNER_Q2.SEQ <= INNER_Q1.NUM_STREAMS;

/* l_int_count := SQL%ROWCOUNT;
  IF G_STMT_LOG THEN
	null;
		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
  END IF;*/

-- Generates Shedules for usage lines
l_stmt_num :=50;

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	 INTO OKS_LEVEL_ELEMENTS
		(ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
	VALUES (ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)

SELECT	 USG_SCH_DT.*
	,(CASE WHEN USG_SCH_DT.INVOICING_RULE_ID = -2
			THEN (CASE WHEN USG_SCH_DT.DATE_START >= SYSDATE THEN USG_SCH_DT.DATE_START
				   ELSE SYSDATE
			      END)
	       WHEN USG_SCH_DT.INVOICING_RULE_ID = -3
			THEN (CASE WHEN USG_SCH_DT.DATE_END >= SYSDATE THEN 	USG_SCH_DT.DATE_END
				   ELSE SYSDATE
			      END)
	  END)  DATE_TRANSACTION
	 ,(CASE WHEN USG_SCH_DT.INVOICING_RULE_ID = -2 THEN USG_SCH_DT.DATE_START
		WHEN USG_SCH_DT.INVOICING_RULE_ID = -3 THEN USG_SCH_DT.DATE_END +1
           END)  DATE_TO_INTERFACE
FROM
	(SELECT	 okc_p_util.raw_to_number(sys_guid())	ID
		,INNER_Q2.SEQ 				SEQUENCE_NUMBER
	        ,(CASE  WHEN INNER_Q2.SEQ=1  THEN INNER_Q1.STRM_START_DATE
				-- IN OTHER CASES
			ELSE /*DECODE (INNER_Q1.BILLING_INTERVAL_PERIOD
					,'DAY'	,	MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
					,'WK'	,	MID_SM_STR_DT + (7 * (INNER_Q2.SEQ -1 ))
					,'MTH'	,	ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
					,'QRT'	,	ADD_MONTHS(MID_SM_STR_DT , 3 * (INNER_Q2.SEQ -1 ))
					,'YR'	,	ADD_MONTHS(MID_SM_STR_DT , 12 * (INNER_Q2.SEQ -1 )) )
		  END) */
                  ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT + INNER_Q2.SEQ -1
                          WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ-1))
                          WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1))
                          WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ-1))
                           WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ-1))
                      END )
                       END)DATE_START                            /*Added for bug:9019205*/
		,(CASE	WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL --first stream
				THEN INNER_Q1.LEVEL_AMOUNT
			WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL  -- normal stream
				THEN
				     (CASE WHEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) *(INNER_Q2.SEQ-1) >0
							THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS  --if it is the last schedule for the stream, value difference due to rounding is to be adjusted
									AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0 THEN INNER_Q1.LEVEL_AMOUNT
								   WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0 THEN
										INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
								   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
							     END)
					   ELSE 0
				      END)
			WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL -- then it is normal stream
				THEN
					(CASE WHEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1) >0
							THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
												THEN INNER_Q1.LEVEL_AMOUNT
								   WHEN INNER_Q2.SEQ = INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
												THEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
								 					*(INNER_Q2.SEQ-1)
								   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
							      END)
					      ELSE 0
				         END)
		        WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL -- last bill stream
					THEN INNER_Q1.LEVEL_AMOUNT
		        WHEN INNER_Q1.SEQUENCE_NO = 3 THEN  INNER_Q1.LEVEL_AMOUNT
		  END)	AMOUNT
		,(CASE WHEN INNER_Q1.FULLY_BILLED = 'Y' THEN SYSDATE
			ELSE NULL
		  END)					DATE_COMPLETED
		,INNER_Q1.OBJECT_VERSION_NUMBER		OBJECT_VERSION_NUMBER
		,INNER_Q1.OKS_STRM_LVL_ID		RUL_ID
		,FND_GLOBAL.USER_ID			CREATED_BY
		,SYSDATE				CREATION_DATE
		,FND_GLOBAL.USER_ID			LAST_UPDATED_BY
		,SYSDATE				LAST_UPDATE_DATE
		,INNER_Q1.CLE_ID			CLE_ID
		,INNER_Q1.DNZ_CHR_ID			DNZ_CHR_ID
		,INNER_Q1.PARENT_CLE_ID			PARENT_CLE_ID
        	,(CASE  WHEN  INNER_Q2.SEQ = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL  --first stream
				AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE
					THEN INNER_Q1.FIRST_BILL_UPTO_DATE
			WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = INNER_Q1.LAST_BILL_FROM_DATE  --last stream
					THEN  INNER_Q1.LIN_END_DT
				-- IN OTHER CASES
			ELSE/* DECODE( INNER_Q1.BILLING_INTERVAL_PERIOD
					, 'DAY'	, MID_SM_STR_DT - 1  + INNER_Q2.SEQ
					, 'WK'  , MID_SM_STR_DT - 1 + (7 * (INNER_Q2.SEQ))
					, 'MTH' , ADD_MONTHS(MID_SM_STR_DT - 1 , (INNER_Q2.SEQ ))
					, 'QRT' , ADD_MONTHS(MID_SM_STR_DT - 1 , 3 * (INNER_Q2.SEQ ))
					, 'YR'  , ADD_MONTHS(MID_SM_STR_DT - 1  , 12 * (INNER_Q2.SEQ )) )

		  END) */
                  ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT -1+ INNER_Q2.SEQ
                          WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT -1 + (7 * (INNER_Q2.SEQ))
                          WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT-1 , (INNER_Q2.SEQ ))
                          WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 3 * (INNER_Q2.SEQ ))
                          WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 12 * (INNER_Q2.SEQ ))
                        END )
                         END )DATE_END	                                     /*Added for bug:9019205*/
	        ,INNER_Q1.RECUR_BILL_OCCURANCES	        FREQUENCY
	       ,INNER_Q1.INVOICING_RULE_ID		INVOICING_RULE_ID
	 FROM
		(SELECT  OLSTG.LINE_INTERFACE_ID		LINE_INTERFACE_ID
			,OKS_STRM_LVL.ID			OKS_STRM_LVL_ID
			,OKCLINB_LINE.ID                        CLE_ID
			,OKCHDRB.ID				DNZ_CHR_ID
			,OKCLINB_LINE.ID			PARENT_CLE_ID
			,OKCLINB_LINE.INV_RULE_ID		INVOICING_RULE_ID
			,1					OBJECT_VERSION_NUMBER
			,nvl(OKCLINB_LINE.PRICE_NEGOTIATED,0)  	SUBTOTAL
			,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
			,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
			,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
			,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
			,OLSTG.START_DATE			LIN_START_DT
			,OLSTG.END_DATE				LIN_END_DT
			,NVL(OLSTG.FIRST_BILLED_AMOUNT,0)	FIRST_BILL_AMOUNT
			,NVL(OLSTG.LAST_BILLED_AMOUNT,0)	LAST_BILL_AMOUNT
			,OLSTG.FIRST_BILL_UPTO_DATE		FIRST_BILL_UPTO_DATE
			,OKS_STRM_LVL.LEVEL_PERIODS		LEVEL_PERIODS
			,OKS_STRM_LVL.SEQUENCE_NO		SEQUENCE_NO
			,nvl(OKS_STRM_LVL.LEVEL_AMOUNT,0)	LEVEL_AMOUNT
			,HDRSTG.FULLY_BILLED			FULLY_BILLED
			,OKS_STRM_LVL.START_DATE		STRM_START_DATE
			,OKS_STRM_LVL.END_DATE			STRM_END_DATE
			,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL THEN OLSTG.FIRST_BILL_UPTO_DATE +1
			       ELSE OLSTG.START_DATE
			  END) MID_SM_STR_DT
			,OLSTG.LAST_BILL_FROM_DATE - 1		MID_SM_END_DT
		        ,OLSTG.LINE_TYPE			LINE_TYPE
                         ,bip.tce_code                           tce_code
                         ,bip.quantity                           quantity           /*Added for bug:9019205*/

	 FROM	 OKS_INT_LINE_STG_TEMP		OLSTG
		,OKC_K_LINES_B			OKCLINB_LINE
		,OKC_K_HEADERS_ALL_B		OKCHDRB
		,OKS_INT_HEADER_STG_TEMP	HDRSTG
		,OKS_STREAM_LEVELS_B		OKS_STRM_LVL
                ,OKC_TIME_CODE_UNITS_B          BIP
               ,OKC_TIME_CODE_UNITS_TL          BIPTL                               /*Added for bug:9019205*/
	 WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
	 AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
	 AND   HDRSTG.INTERFACE_STATUS ='S'
	 AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
	 AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
	 AND   OKS_STRM_LVL.DNZ_CHR_ID = OKCHDRB.ID
         AND  OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
	 AND  OKS_STRM_LVL.CLE_ID = OKCLINB_LINE.ID
         AND  OLSTG.LINE_TYPE='USAGE'
         AND  OLSTG.billing_interval_period=BIP.uom_code(+)
         AND  BIP.uom_code =BIPTL.uom_code
         AND   BIP.tce_code =BIPTL.tce_code
         AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1                /*Added for bug:9019205*/
	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= l_recur_bill_occurance ) INNER_Q2
WHERE INNER_Q2.SEQ <= INNER_Q1.LEVEL_PERIODS)USG_SCH_DT;


	/*IF G_STMT_LOG THEN
		fnd_log.string(fnd_log.level_statement,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
				 'Number of records successfully inserted = ' || l_int_count );
	END IF;  */

/* IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
			null;
 END IF;    */

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Generate_bil_sch_Usage_lines;

--========================================================================
-- PROCEDURE  :  Generate_bil_sch_Service_line    PRIVATE
-- PARAMETERS :
-- COMMENT    :  This procedure will generate the Billing Streams
--		 and schedules for Service Lines and sublines
--=========================================================================

PROCEDURE Generate_bil_sch_Service_line
IS
	l_stmt_num  NUMBER := 0;
	l_routine   CONSTANT VARCHAR2(30) := 'Generate_bil_sch_Service_line';
	l_int_count     NUMBER := 0;
	l_stg_count     NUMBER := 0;
	l_recur_bill_occurance NUMBER := 0 ;
 BEGIN

	IF G_PROCEDURE_LOG THEN
		 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  ');

	END IF;

-- Generates Billing Streams for Service sublines

	l_stmt_num := 10;

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	INTO OKS_STREAM_LEVELS_B
	(ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

  VALUES (ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

SELECT  okc_p_util.raw_to_number(sys_guid())	ID
	,INNER_Q2.SEQ  			SEQUENCE_NO
	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS null THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 3  THEN	'DAY'
	       else INNER_Q1.BILLING_INTERVAL_PERIOD
	  END)  UOM_CODE

	,(CASE WHEN INNER_Q2.SEQ = 1 THEN INNER_Q1.LIN_STR_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date is not null THEN INNER_Q1.FIRST_BILL_UPTO_DATE + 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LAST_BILL_FROM_DATE
	  END) START_DATE

	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LIN_END_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT
	  END) END_DATE

	,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 1
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 1
	       WHEN INNER_Q2.SEQ = 3  THEN 1
	  END) LEVEL_PERIODS

	,(CASE  WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL
			THEN INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.CVL_START_DT + 1 -- difference in the days with the days inclusive
		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	        WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN  INNER_Q1.CVL_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1)
		WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.CVL_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
	 	ELSE INNER_Q1.BILLING_INTERVAL_DURATION
	   END) UOM_PER_PERIOD

	 ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
			THEN ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
			THEN  ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
			THEN ROUND((INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
					(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
							*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
			THEN INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) *
						INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 3
			THEN
			INNER_Q1.SUBTOTAL
				- ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
				-  ROUND((INNER_Q1.SUBTOTAL -
				ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
					(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
							*INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)

	   END) LEVEL_AMOUNT
	  ,INNER_Q1.RECUR_BILL_OCCURANCES    FREQUENCY
	  ,INNER_Q1.*
	  ,INNER_Q2.*
FROM
	(SELECT  OKCLINB_SUBLINE.ID			CLE_ID
		,null					CHR_ID -- can be null for sublines
		,OKCHDRB.ID				DNZ_CHR_ID
		,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) = OLSTG.END_DATE THEN 1
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1) = OLSTG.END_DATE  THEN 2
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 2
	               WHEN OLSTG.FIRST_BILL_UPTO_DATE  IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 3
	          END) NUM_STREAMS
		,1					OBJECT_VERSION_NUMBER
		,null					REQUEST_ID
		,FND_GLOBAL.USER_ID			CREATED_BY
		,SYSDATE				CREATION_DATE
		,FND_GLOBAL.USER_ID			LAST_UPDATED_BY
		,SYSDATE				LAST_UPDATE_DATE
		,FND_GLOBAL.LOGIN_ID			LAST_UPDATE_LOGIN
		,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
		,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
		,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
		,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
		,INNER_1.STR_DT				CVL_START_DT
		,INNER_1.END_DT				CVL_END_DT
		,OLSTG.FIRST_BILL_UPTO_DATE		FIRST_BILL_UPTO_DATE
		,nvl(INNER_1.STOTAL,0) 			SUBTOTAL
		,OLSTG.LINE_TYPE			LINE_TYPE
		,OLSTG.START_DATE			LIN_STR_DT
		,OLSTG.END_DATE				LIN_END_DT
		,(INNER_1.END_DT  - INNER_1.STR_DT)+1	NO_OF_DAYS
                 ,bip.tce_code                           tce_code
                ,bip.quantity                           quantity                  /*Added for bug:9019205*/
		/*(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD ='DAY'  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'DAY' THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
		        WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) */
                  ,(CASE WHEN bip.tce_code ='DAY'   and  bip.quantity =1   THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN bip.tce_code ='DAY'    and bip.quantity =7    THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN bip.tce_code ='MONTH' and bip.quantity =1 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN bip.tce_code ='MONTH' and bip.quantity = 3  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE	WHEN bip.tce_code ='DAY'   and  bip.quantity =1 THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN bip.tce_code ='DAY'    and bip.quantity =7 THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN bip.tce_code ='MONTH' and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
	                WHEN bip.tce_code ='MONTH' and bip.quantity = 3 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
		        WHEN bip.tce_code ='YEAR'  and bip.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) CALC_BILL_PERIOD_2                             /*Added for bug:9019205*/
	 FROM	OKS_INT_LINE_STG_TEMP		OLSTG

		,(SELECT CVLSTG.LINE_INTERFACE_ID   LINE_INTERFACE_ID
			,CLI.LINE_NUMBER	    LINE_NUMBER
			,CLI.START_DATE		    STR_DT
			,CLI.END_DATE		    END_DT
			,CLI.SUBTOTAL		    STOTAL
		  FROM	 OKS_COVERED_LEVELS_INTERFACE CLI
			,OKS_INT_COVERED_LEVEL_STG_TEMP CVLSTG
		  WHERE  CLI.COVERED_LEVEL_INTERFACE_ID = CVLSTG.COVERED_LEVEL_INTERFACE_ID )INNER_1

		,OKC_K_LINES_B			OKCLINB_LINE
		,OKC_K_LINES_B			OKCLINB_SUBLINE
		,OKC_K_HEADERS_ALL_B		OKCHDRB
		,OKS_INT_HEADER_STG_TEMP	HDRSTG
                ,OKC_TIME_CODE_UNITS_B		BIP
                ,OKC_TIME_CODE_UNITS_TL		BIPTL                         /*Added for bug:9019205*/
	 WHERE INNER_1.LINE_INTERFACE_ID = OLSTG.LINE_INTERFACE_ID
	 AND   OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
         AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
         AND   HDRSTG.INTERFACE_STATUS ='S'
         AND   OKCLINB_LINE.DNZ_CHR_ID = OKCHDRB.ID
         AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
         AND   OLSTG.LINE_NUMBER = OKCLINB_LINE.LINE_NUMBER
         AND   OKCLINB_SUBLINE.DNZ_CHR_ID = OKCHDRB.ID
         AND   OKCLINB_SUBLINE.CLE_ID = OKCLINB_LINE.ID
         AND   OKCLINB_SUBLINE.LINE_NUMBER = INNER_1.LINE_NUMBER
         AND   OLSTG.LINE_TYPE NOT IN ('SUBSCRIPTION','USAGE')
         AND   OLSTG.billing_interval_period=BIP.uom_code(+)
         AND   BIP.uom_code =BIPTL.uom_code
         AND   BIP.tce_code =BIPTL.tce_code
         AND   BIPTL.language(+)=USERENV('LANG')) INNER_Q1              /*Added for bug:9019205*/

	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= 3) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.NUM_STREAMS;

  l_int_count := SQL%ROWCOUNT;
 /* IF G_STMT_LOG THEN
        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
		 'Number of records successfully inserted = ' || l_int_count );

  END IF; */

l_stmt_num :=20;

	SELECT MAX(RECUR_BILL_OCCURANCES) INTO l_recur_bill_occurance FROM OKS_INT_LINE_STG_TEMP ;

/*  IF G_STMT_LOG THEN

        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' || l_stmt_num,
		 'Value of max Recur Bill Occurance  = ' || l_recur_bill_occurance  );
  END IF; */


l_stmt_num :=30;

-- this query inserts records into level elements as schedules for billing streams for sublines

INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	 INTO OKS_LEVEL_ELEMENTS
		(ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
	VALUES (ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
SELECT	COV_SCH_DT.*
	,(CASE WHEN COV_SCH_DT.INVOICING_RULE_ID = -2
			THEN
				(CASE WHEN COV_SCH_DT.DATE_START >= SYSDATE THEN COV_SCH_DT.DATE_START
				      ELSE SYSDATE
				 END)
	       WHEN COV_SCH_DT.INVOICING_RULE_ID = -3
			THEN
				(CASE WHEN COV_SCH_DT.DATE_END > = SYSDATE THEN COV_SCH_DT.DATE_END
				      ELSE SYSDATE
				END)
	  END) DATE_TRANSACTION

	,(CASE WHEN COV_SCH_DT.INVOICING_RULE_ID = -2 THEN COV_SCH_DT.DATE_START
	       WHEN COV_SCH_DT.INVOICING_RULE_ID = -3 THEN COV_SCH_DT.DATE_END +1
	  END)  DATE_TO_INTERFACE

FROM
	(SELECT	okc_p_util.raw_to_number(sys_guid())					ID
		,INNER_Q2.SEQ								SEQUENCE_NUMBER
		,(CASE  WHEN INNER_Q2.SEQ = 1  AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE  -- first bill stream
				AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
						THEN INNER_Q1.CVL_START_DT

			WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = inner_q1.last_bill_from_date  -- last bill stream
					THEN INNER_Q1.last_bill_from_date
				-- IN OTHER CASES
			ELSE /*  DECODE (INNER_Q1.BILLING_INTERVAL_PERIOD
						,'DAY'	,	MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
						,'WK'	,	MID_SM_STR_DT + (7 * (INNER_Q2.SEQ -1 ))
						,'MTH'	,	ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
						,'QRT'	,	ADD_MONTHS(MID_SM_STR_DT , 3 * (INNER_Q2.SEQ -1 ))
						,'YR'	,	ADD_MONTHS(MID_SM_STR_DT , 12 * (INNER_Q2.SEQ -1 )) )
		  END ) */
                  (  CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN  MID_SM_STR_DT + INNER_Q2.SEQ -1
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN  MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ -1))
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ -1 ))
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ -1))
                   END )
                    END )DATE_START         /*Added for bug:9019205*/

		,(CASE WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
					THEN INNER_Q1.LEVEL_AMOUNT
               	       WHEN INNER_Q1.SEQUENCE_NO = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL  -- normal stream
					THEN (CASE WHEN  INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) *(INNER_Q2.SEQ-1) >0
								THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS  --if it is the last schedule for the stream, value difference due to rounding is to be adjusted
											AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
													THEN INNER_Q1.LEVEL_AMOUNT
									   WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
													THEN INNER_Q1.LEVEL_AMOUNT -
														ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
									   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
							              END)
						   ELSE 0
					      END)
		       WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL -- then it is normal stream
					THEN  (CASE WHEN INNER_Q1.LEVEL_AMOUNT - ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1) >0
								THEN (CASE WHEN INNER_Q2.SEQ =INNER_Q1.LEVEL_PERIODS
											AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) = 0
													THEN INNER_Q1.LEVEL_AMOUNT
									   WHEN INNER_Q2.SEQ = INNER_Q1.LEVEL_PERIODS AND ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2) >0
													THEN INNER_Q1.LEVEL_AMOUNT -
														ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)*(INNER_Q2.SEQ-1)
									   ELSE ROUND(INNER_Q1.LEVEL_AMOUNT/INNER_Q1.LEVEL_PERIODS,2)
								      END)
				                    ELSE 0
				               END)
			WHEN INNER_Q1.SEQUENCE_NO = 2 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NULL -- last bill stream
					THEN INNER_Q1.LEVEL_AMOUNT
			WHEN INNER_Q1.SEQUENCE_NO = 3 THEN  INNER_Q1.LEVEL_AMOUNT
		  END) AMOUNT
		,(CASE WHEN INNER_Q1.FULLY_BILLED = 'Y' THEN SYSDATE
		       ELSE NULL
		  END)								DATE_COMPLETED
		,INNER_Q1.OBJECT_VERSION_NUMBER						OBJECT_VERSION_NUMBER
		,INNER_Q1.OKS_STRM_LVL_ID						RUL_ID
		,FND_GLOBAL.USER_ID							CREATED_BY
		,SYSDATE								CREATION_DATE
		,FND_GLOBAL.USER_ID							LAST_UPDATED_BY
		,SYSDATE								LAST_UPDATE_DATE
		,INNER_Q1.CLE_ID							CLE_ID
		,INNER_Q1.DNZ_CHR_ID							DNZ_CHR_ID
		,INNER_Q1.PARENT_CLE_ID							PARENT_CLE_ID
		,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE  -- first bill stream
				AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL
					THEN INNER_Q1.FIRST_BILL_UPTO_DATE
		       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = inner_q1.last_bill_from_date  -- last bill stream
					THEN INNER_Q1.CVL_END_DT
				-- IN OTHER CASES
			ELSE/* DECODE( INNER_Q1.BILLING_INTERVAL_PERIOD
					, 'DAY'	, MID_SM_STR_DT + INNER_Q2.SEQ -1
					, 'WK'  , MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ)) -1
					, 'MTH' , ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ )) -1
					, 'QRT' , ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ )) -1
					, 'YR'  , ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ )) -1 )

		  END )*/
                  ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT + INNER_Q2.SEQ -1
                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ)) -1
                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ )) -1
                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ )) -1
                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ )) -1
                   END )
                    END )DATE_END                                 /*Added for bug:9019205*/
		,INNER_Q1.RECUR_BILL_OCCURANCES		FREQUENCY
		,INNER_Q1.INVOICING_RULE_ID		INVOICING_RULE_ID
	 FROM
		(SELECT  OKCLINB_SUBLINE.ID			CLE_ID
			,OKS_STRM_LVL.ID			OKS_STRM_LVL_ID
			,null					CHR_ID	-- can be null for sublines
			,OKCHDRB.ID				DNZ_CHR_ID
			,OKCLINB_LINE.ID			PARENT_CLE_ID
			,OKCLINB_LINE.INV_RULE_ID		INVOICING_RULE_ID
			,1					OBJECT_VERSION_NUMBER
			,NVL(INNER_1.STOTAL,0)			SUBTOTAL
			,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
			,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
			,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
			,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
			,INNER_1.STR_DT				CVL_START_DT
			,INNER_1.END_DT				CVL_END_DT
			,OLSTG.FIRST_BILL_UPTO_DATE	        FIRST_BILL_UPTO_DATE
			,OKS_STRM_LVL.LEVEL_PERIODS		LEVEL_PERIODS
			,OKS_STRM_LVL.LEVEL_AMOUNT		LEVEL_AMOUNT
			,HDRSTG.FULLY_BILLED			FULLY_BILLED
			,OKS_STRM_LVL.START_DATE		STRM_START_DATE
			,OKS_STRM_LVL.END_DATE			STRM_END_DATE
			,OLSTG.LINE_TYPE			LINE_TYPE
			,OKS_STRM_LVL.SEQUENCE_NO		SEQUENCE_NO
			,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL THEN OLSTG.FIRST_BILL_UPTO_DATE +1
				ELSE  INNER_1.STR_DT
			  END) MID_SM_STR_DT
			,OLSTG.LAST_BILL_FROM_DATE -1   MID_SM_END_DT
                         ,bip.tce_code                           tce_code
                        ,bip.quantity                           quantity          /*Added for bug:9019205*/

		 FROM	 OKS_INT_LINE_STG_TEMP		OLSTG
			,(SELECT  CVLSTG.LINE_INTERFACE_ID	LINE_INTERFACE_ID
				 ,CLI.LINE_NUMBER		LINE_NUMBER
		                 ,CLI.START_DATE		STR_DT
		                 ,CLI.END_DATE		END_DT
		                 ,CLI.SUBTOTAL		STOTAL
	                  FROM   OKS_COVERED_LEVELS_INTERFACE   CLI
		                ,OKS_INT_COVERED_LEVEL_STG_TEMP CVLSTG
	                  WHERE CLI.COVERED_LEVEL_INTERFACE_ID = CVLSTG.COVERED_LEVEL_INTERFACE_ID ) INNER_1
			,OKC_K_LINES_B			OKCLINB_LINE
			,OKC_K_LINES_B			OKCLINB_SUBLINE
			,OKC_K_HEADERS_ALL_B		OKCHDRB
			,OKS_INT_HEADER_STG_TEMP	HDRSTG
			,OKS_STREAM_LEVELS_B		OKS_STRM_LVL
                        ,OKC_TIME_CODE_UNITS_B        BIP
                        ,OKC_TIME_CODE_UNITS_TL        BIPTL                        /*Added for bug:9019205*/
		 WHERE INNER_1.LINE_INTERFACE_ID  = OLSTG.LINE_INTERFACE_ID
		 AND OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
		 AND HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
		 AND NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
		 AND HDRSTG.INTERFACE_STATUS ='S'
                 AND OKCLINB_LINE.DNZ_CHR_ID = OKCHDRB.ID
                 AND OKCLINB_LINE.CHR_ID = OKCHDRB.ID
                 AND OLSTG.LINE_NUMBER = OKCLINB_LINE.LINE_NUMBER
                 AND OKCLINB_SUBLINE.DNZ_CHR_ID = OKCHDRB.ID
                 AND OKCLINB_SUBLINE.CLE_ID = OKCLINB_LINE.ID
                 AND OKCLINB_SUBLINE.LINE_NUMBER = INNER_1.LINE_NUMBER
                 AND OKS_STRM_LVL.DNZ_CHR_ID = OKCHDRB.ID
		 AND OKS_STRM_LVL.CLE_ID = OKCLINB_SUBLINE.ID
		 AND OKS_STRM_LVL.CHR_ID IS NULL
		 AND OLSTG.LINE_TYPE NOT IN ('SUBSCRIPTION','USAGE')
                 AND  OLSTG.billing_interval_period=BIP.uom_code(+)
                 AND  BIP.uom_code =BIPTL.uom_code
                 AND   BIP.tce_code =BIPTL.tce_code
                 AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1 	               /*Added for bug:9019205*/

		,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= l_recur_bill_occurance ) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.LEVEL_PERIODS) COV_SCH_DT;

-- Billing Streams and Schedules for Service Lines

l_stmt_num := 40;

INSERT ALL
  WHEN (FREQUENCY IS NOT NULL) THEN
	INTO OKS_STREAM_LEVELS_B
	(ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

  VALUES (ID
	,CHR_ID
	,CLE_ID
	,DNZ_CHR_ID
	,SEQUENCE_NO
	,UOM_CODE
	,START_DATE
	,END_DATE
	,LEVEL_PERIODS
	,UOM_PER_PERIOD
	,LEVEL_AMOUNT
	,OBJECT_VERSION_NUMBER
	,REQUEST_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN)

SELECT  okc_p_util.raw_to_number(sys_guid())	ID

       ,INNER_Q2.SEQ                          SEQUENCE_NO

       ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS not NULL THEN INNER_Q1.BILLING_INTERVAL_PERIOD
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS null THEN 'DAY'
	       WHEN INNER_Q2.SEQ = 3  THEN	'DAY'
	       else INNER_Q1.BILLING_INTERVAL_PERIOD
	  END)  UOM_CODE

       ,(CASE WHEN INNER_Q2.SEQ = 1 THEN INNER_Q1.LIN_STR_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date is not null THEN INNER_Q1.FIRST_BILL_UPTO_DATE + 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LAST_BILL_FROM_DATE
	  END) START_DATE

        ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.FIRST_BILL_UPTO_DATE
	       WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.LIN_END_DT
	       WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.LAST_BILL_FROM_DATE - 1
	       WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT
	  END) END_DATE

          ,(CASE WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN 1
		 WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	         WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.RECUR_BILL_OCCURANCES
	         WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL THEN 1
	         WHEN INNER_Q2.SEQ = 3  THEN 1
	  END) LEVEL_PERIODS

        ,(CASE  WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL
				THEN INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1 -- including the days between the difference

		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
	        WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL THEN INNER_Q1.BILLING_INTERVAL_DURATION
		WHEN INNER_Q2.SEQ = 2 AND  INNER_Q1.first_bill_upto_date IS NULL THEN  INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
		WHEN INNER_Q2.SEQ = 3  THEN INNER_Q1.LIN_END_DT -(INNER_Q1.LAST_BILL_FROM_DATE - 1 )
                ELSE INNER_Q1.BILLING_INTERVAL_DURATION
	  END) UOM_PER_PERIOD
	,(CASE  WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NOT NULL  -- first stream
			THEN ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)

		WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.first_bill_upto_date IS NULL -- normal stream
			THEN  ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) * INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)

		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NOT NULL  --normal stream
			THEN ROUND((INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
							(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
									* INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 2 AND INNER_Q1.first_bill_upto_date IS NULL -- last stream
			THEN INNER_Q1.SUBTOTAL -
                                 ROUND((INNER_Q1.SUBTOTAL/CALC_BILL_PERIOD_1) *
						INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
		WHEN INNER_Q2.SEQ = 3
			THEN
                            INNER_Q1.SUBTOTAL
				- ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) * (INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2)
					- ROUND((INNER_Q1.SUBTOTAL -
					ROUND((INNER_Q1.SUBTOTAL/INNER_Q1.NO_OF_DAYS) *
							(INNER_Q1.FIRST_BILL_UPTO_DATE - INNER_Q1.LIN_STR_DT +1) *1,2))/CALC_BILL_PERIOD_2
									* INNER_Q1.BILLING_INTERVAL_DURATION * INNER_Q1.RECUR_BILL_OCCURANCES,2)
	  END) LEVEL_AMOUNT
        ,INNER_Q1.RECUR_BILL_OCCURANCES FREQUENCY
        ,INNER_Q1.*
        ,INNER_Q2.*
FROM
	(SELECT  OKCLINB_LINE.ID              LINE_ID
		,null		              CHR_ID
		,OKCLINB_LINE.ID              CLE_ID
		,OKCHDRB.ID                   DNZ_CHR_ID
		,OLSTG.FIRST_BILL_UPTO_DATE   FIRST_BILL_UPTO_DATE
		,(CASE  WHEN  OLSTG.FIRST_BILL_UPTO_DATE  IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) = OLSTG.END_DATE   THEN 1
	                WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1) = OLSTG.END_DATE  THEN 2
	                WHEN  OLSTG.FIRST_BILL_UPTO_DATE IS NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 2
	                WHEN  OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL AND (OLSTG.LAST_BILL_FROM_DATE -1 ) < OLSTG.END_DATE THEN 3
		  END) NUM_STREAMS
	        ,OLSTG.BILLING_INTERVAL_PERIOD					BILLING_INTERVAL_PERIOD
		/*,(CASE	WHEN OLSTG.BILLING_INTERVAL_PERIOD ='DAY'  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
	                WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
		,(CASE  WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'DAY' THEN (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'WK'  THEN ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'MTH' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))-- no of months
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'QRT' THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
			WHEN OLSTG.BILLING_INTERVAL_PERIOD = 'YR'  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
		  END) */
                  ,(CASE WHEN BIP.tce_code ='DAY'   and BIP.quantity =1  THEN  (OLSTG.END_DATE  - OLSTG.START_DATE)+1	 --no_of_day
			WHEN BIP.tce_code ='DAY'   and BIP.quantity =7  THEN  ((OLSTG.END_DATE  - OLSTG.START_DATE)+1)/7 -- no of weeks
		        WHEN BIP.tce_code ='MONTH' and BIP.quantity =1    THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE) -- no of months
			WHEN BIP.tce_code ='MONTH' and BIP.quantity = 3 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/3 -- no of quarter
			WHEN BIP.tce_code ='YEAR'  and BIP.quantity =1   THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,OLSTG.START_DATE)/12 -- no of years
		  END) CALC_BILL_PERIOD_1
                  ,(CASE WHEN BIP.tce_code ='MONTH' and BIP.quantity =1  THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1)) -- no of months
                         WHEN BIP.tce_code ='MONTH' and BIP.quantity = 3 THEN MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/3  -- no of quarter
                         WHEN BIP.tce_code ='YEAR'  and BIP.quantity =1 THEN  MONTHS_BETWEEN(OLSTG.END_DATE + 1,(OLSTG.FIRST_BILL_UPTO_DATE+1))/12 -- no of years
                         WHEN BIP.tce_code ='DAY'   and BIP.quantity =7 THEN  ((OLSTG.END_DATE  - OLSTG.FIRST_BILL_UPTO_DATE + 1) +1 )/7  -- no of weeks
                         WHEN BIP.tce_code ='DAY'   and BIP.quantity =1 THEN  (OLSTG.END_dATE -OLSTG.FIRST_BILL_UPTO_DATE +1) +1 --no of days
                   END) CALC_BILL_PERIOD_2                                      /*Added for bug:9019205*/
		,OLSTG.LINE_TYPE						LINE_TYPE
		,OLSTG.RECUR_BILL_OCCURANCES					RECUR_BILL_OCCURANCES
		,OLSTG.BILLING_INTERVAL_DURATION				BILLING_INTERVAL_DURATION
		,nvl(OKCLINB_LINE.PRICE_NEGOTIATED,0)				SUBTOTAL
		,OLSTG.START_DATE						LIN_STR_DT
		,OLSTG.END_DATE							LIN_END_DT
		,(OLSTG.END_DATE  - OLSTG.START_DATE)+1				NO_OF_DAYS
		,OLSTG.LAST_BILL_FROM_DATE					LAST_BILL_FROM_DATE
	        ,1								OBJECT_VERSION_NUMBER
		,null								REQUEST_ID -- need to confirm
		,FND_GLOBAL.USER_ID						CREATED_BY
		,SYSDATE							CREATION_DATE
		,FND_GLOBAL.USER_ID						LAST_UPDATED_BY
		,SYSDATE							LAST_UPDATE_DATE
		,FND_GLOBAL.LOGIN_ID						LAST_UPDATE_LOGIN
                ,bip.tce_code                                                   tce_code
                ,bip.quantity                                                   quantity         /*Added for bug:9019205*/
	 FROM   OKS_INT_LINE_STG_TEMP      OLSTG
		,OKS_INT_HEADER_STG_TEMP    HDRSTG
		,OKC_K_HEADERS_ALL_B        OKCHDRB
		,OKC_K_LINES_B              OKCLINB_LINE
                ,OKC_TIME_CODE_UNITS_B    BIP
               ,OKC_TIME_CODE_UNITS_TL    BIPTL                                /*Added for bug:9019205*/
	 WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
	 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
	 AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
	 AND   HDRSTG.INTERFACE_STATUS ='S'
	 AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
	 AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
         AND   OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
         AND   OLSTG.LINE_TYPE NOT IN ('SUBSCRIPTION', 'USAGE')
          AND OLSTG.billing_interval_period=BIP.uom_code(+)
         AND  BIP.uom_code =BIPTL.uom_code
         AND   BIP.tce_code =BIPTL.tce_code
         AND  BIPTL.language(+)=USERENV('LANG'))INNER_Q1

	,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= 3) INNER_Q2

WHERE INNER_Q2.SEQ <= INNER_Q1.NUM_STREAMS;

 l_int_count := SQL%ROWCOUNT;

  /*IF G_STMT_LOG THEN

		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
  END IF; */

l_stmt_num := 50;

--This query creates billing schedules from streams for lines
 INSERT ALL
   WHEN (FREQUENCY IS NOT NULL ) then
	 INTO OKS_LEVEL_ELEMENTS
		(ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)
	VALUES  (ID
		,SEQUENCE_NUMBER
		,DATE_START
		,AMOUNT
		,DATE_TRANSACTION
		,DATE_TO_INTERFACE
		,DATE_COMPLETED
		,OBJECT_VERSION_NUMBER
		,RUL_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,CLE_ID
		,DNZ_CHR_ID
		,PARENT_CLE_ID
		,DATE_END)

SELECT  okc_p_util.raw_to_number(sys_guid())	ID
       ,SCH_LIN_INSERT . *
FROM
	(SELECT  DISTINCT COV_LVL_ELEM.PARENT_CLE_ID  AS PAR_CLE_ID
		,LIN_SCH_DT.*

		,SUM(COV_LVL_ELEM.AMOUNT)  OVER (PARTITION BY COV_LVL_ELEM.PARENT_CLE_ID, LIN_SCH_DT.DATE_START ) AMOUNT

		,(CASE  WHEN LIN_SCH_DT.INVOICING_RULE_ID = -2
					THEN (CASE WHEN LIN_SCH_DT.DATE_START >= SYSDATE THEN LIN_SCH_DT.DATE_START
								ELSE SYSDATE
					      END)
			WHEN LIN_SCH_DT.INVOICING_RULE_ID = -3
					THEN (CASE WHEN LIN_SCH_DT.DATE_END > = SYSDATE THEN LIN_SCH_DT.DATE_END
								   ELSE SYSDATE
					      END)
		  END) DATE_TRANSACTION

		 ,(CASE WHEN LIN_SCH_DT.INVOICING_RULE_ID = -2 THEN LIN_SCH_DT.DATE_START
			WHEN LIN_SCH_DT.INVOICING_RULE_ID = -3 THEN LIN_SCH_DT.DATE_END +1
	  	   END)	 DATE_TO_INTERFACE

	 FROM    OKS_LEVEL_ELEMENTS COV_LVL_ELEM
		,(SELECT	INNER_Q2.SEQ 				SEQUENCE_NUMBER
				,(CASE  WHEN INNER_Q2.SEQ=1  THEN INNER_Q1.STRM_START_DATE
						-- IN OTHER CASES
					ELSE  /* DECODE (INNER_Q1.BILLING_INTERVAL_PERIOD
							,'DAY'	,	MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
							,'WK'	,	MID_SM_STR_DT + (7 * (INNER_Q2.SEQ -1 ))
							,'MTH'	,	ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
							,'QRT'	,	ADD_MONTHS(MID_SM_STR_DT , 3 * (INNER_Q2.SEQ -1 ))
							,'YR'	,	ADD_MONTHS(MID_SM_STR_DT , 12 * (INNER_Q2.SEQ -1 )) )
				  END ) */
                                  ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT + (INNER_Q2.SEQ -1 )
                                       WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT  + (7 * (INNER_Q2.SEQ-1))
                                       WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT , (INNER_Q2.SEQ -1 ))
                                       WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT  , 3 * (INNER_Q2.SEQ-1 ))
                                       WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT  , 12 * (INNER_Q2.SEQ -1 ))
                                  END )
                                  END)DATE_START          /*Added for bug:9019205*/
				,(CASE WHEN INNER_Q1.FULLY_BILLED = 'Y' THEN SYSDATE
					ELSE NULL
				  END)  DATE_COMPLETED

				,INNER_Q1.OBJECT_VERSION_NUMBER		OBJECT_VERSION_NUMBER
				,INNER_Q1.OKS_STRM_LVL_ID		RUL_ID
				,FND_GLOBAL.USER_ID			CREATED_BY
				,SYSDATE				CREATION_DATE
				,FND_GLOBAL.USER_ID			LAST_UPDATED_BY
				,SYSDATE				LAST_UPDATE_DATE
				,INNER_Q1.CLE_ID			CLE_ID
				,INNER_Q1.DNZ_CHR_ID			DNZ_CHR_ID
				,INNER_Q1.PARENT_CLE_ID			PARENT_CLE_ID
	        		,(CASE  WHEN  INNER_Q2.SEQ = 1 AND INNER_Q1.FIRST_BILL_UPTO_DATE IS NOT NULL  --first stream
						AND INNER_Q1.STRM_END_DATE = INNER_Q1.FIRST_BILL_UPTO_DATE
								THEN INNER_Q1.FIRST_BILL_UPTO_DATE
					WHEN INNER_Q2.SEQ = 1 AND INNER_Q1.STRM_START_DATE = INNER_Q1.LAST_BILL_FROM_DATE  --last stream
								THEN INNER_Q1.LIN_END_DT
						-- IN OTHER CASES
					ELSE /*DECODE( INNER_Q1.BILLING_INTERVAL_PERIOD
							, 'DAY'	, MID_SM_STR_DT - 1  + INNER_Q2.SEQ
							, 'WK'  , MID_SM_STR_DT - 1 + (7 * (INNER_Q2.SEQ))
							, 'MTH' , ADD_MONTHS(MID_SM_STR_DT - 1 , (INNER_Q2.SEQ ))
							, 'QRT' , ADD_MONTHS(MID_SM_STR_DT - 1 , 3 * (INNER_Q2.SEQ ))
							, 'YR'  , ADD_MONTHS(MID_SM_STR_DT - 1  , 12 * (INNER_Q2.SEQ )) )

				  END)*/
                                   ( CASE WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity =1   THEN MID_SM_STR_DT-1 + INNER_Q2.SEQ
                                        WHEN INNER_Q1.tce_code ='DAY' and INNER_Q1.quantity = 7  THEN MID_SM_STR_DT -1 + (7 * (INNER_Q2.SEQ))
                                        WHEN INNER_Q1.tce_code ='MONTH'  and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT -1, (INNER_Q2.SEQ ))
                                         WHEN INNER_Q1.tce_code ='MONTH'   and INNER_Q1.quantity =3   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 3 * (INNER_Q2.SEQ ))
                                         WHEN INNER_Q1.tce_code ='YEAR'   and INNER_Q1.quantity =1   THEN ADD_MONTHS(MID_SM_STR_DT -1 , 12 * (INNER_Q2.SEQ ))
                                   END )
                                   END )DATE_END
				,INNER_Q1.RECUR_BILL_OCCURANCES	    FREQUENCY
				,INNER_Q1.INVOICING_RULE_ID	    INVOICING_RULE_ID
		  FROM
			(SELECT	 OLSTG.LINE_INTERFACE_ID                LINE_INTERFACE_ID
				,OKS_STRM_LVL.ID			OKS_STRM_LVL_ID
				,OKCLINB_LINE.ID                        CLE_ID
				,OKCHDRB.ID				DNZ_CHR_ID
				,OKCLINB_LINE.ID			PARENT_CLE_ID
				,OKCLINB_LINE.INV_RULE_ID		INVOICING_RULE_ID
				,1					OBJECT_VERSION_NUMBER
				,nvl(OKCLINB_LINE.PRICE_NEGOTIATED,0)  	SUBTOTAL
				,OLSTG.LAST_BILL_FROM_DATE		LAST_BILL_FROM_DATE
				,OLSTG.BILLING_INTERVAL_PERIOD		BILLING_INTERVAL_PERIOD
				,OLSTG.BILLING_INTERVAL_DURATION	BILLING_INTERVAL_DURATION
				,OLSTG.RECUR_BILL_OCCURANCES		RECUR_BILL_OCCURANCES
				,OLSTG.START_DATE			LIN_START_DT
				,OLSTG.END_DATE				LIN_END_DT
				,OLSTG.FIRST_BILL_UPTO_DATE		FIRST_BILL_UPTO_DATE
				,OKS_STRM_LVL.LEVEL_PERIODS		LEVEL_PERIODS
				,OKS_STRM_LVL.SEQUENCE_NO		SEQUENCE_NO
				,nvl(OKS_STRM_LVL.LEVEL_AMOUNT,0)	LEVEL_AMOUNT
				,HDRSTG.FULLY_BILLED			FULLY_BILLED
				,OKS_STRM_LVL.START_DATE		STRM_START_DATE
				,OKS_STRM_LVL.END_DATE			STRM_END_DATE
				,(CASE WHEN OLSTG.FIRST_BILL_UPTO_DATE IS NOT NULL THEN OLSTG.FIRST_BILL_UPTO_DATE +1
						ELSE OLSTG.START_DATE
				  END)	   MID_SM_STR_DT
				,OLSTG.LAST_BILL_FROM_DATE - 1		MID_SM_END_DT
				,OLSTG.LINE_TYPE			LINE_TYPE
                                 ,bip.tce_code                           tce_code
                                ,bip.quantity                           quantity
			 FROM	 OKS_INT_LINE_STG_TEMP		OLSTG
				,OKC_K_LINES_B			OKCLINB_LINE
				,OKC_K_HEADERS_ALL_B		OKCHDRB
				,OKS_INT_HEADER_STG_TEMP	HDRSTG
				,OKS_STREAM_LEVELS_B		OKS_STRM_LVL
                                ,OKC_TIME_CODE_UNITS_B          BIP
                                ,OKC_TIME_CODE_UNITS_TL          BIPTL
			 WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
			 AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
			 AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
			 AND   HDRSTG.INTERFACE_STATUS ='S'
			 AND   OKCLINB_LINE.DNZ_CHR_ID   = OKCHDRB.ID
			 AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
			 AND   OKS_STRM_LVL.DNZ_CHR_ID = OKCHDRB.ID
			 AND  OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
			 AND  OKS_STRM_LVL.CLE_ID = OKCLINB_LINE.ID
			 AND   OLSTG.LINE_TYPE NOT IN ('SUBSCRIPTION', 'USAGE')
                         AND  OLSTG.billing_interval_period=BIP.uom_code(+)
                         AND  BIP.uom_code =BIPTL.uom_code
                         AND   BIP.tce_code =BIPTL.tce_code
                         AND  BIPTL.language(+)=USERENV('LANG')) INNER_Q1	 /*Added for bug:9019205*/
			,(SELECT ROWNUM AS SEQ FROM DUAL CONNECT BY LEVEL <= l_recur_bill_occurance ) INNER_Q2
		  WHERE INNER_Q2.SEQ <= INNER_Q1.LEVEL_PERIODS) LIN_SCH_DT
	 WHERE COV_LVL_ELEM.PARENT_CLE_ID = LIN_SCH_DT.CLE_ID
	 AND COV_LVL_ELEM.DATE_START(+) >= LIN_SCH_DT.DATE_START
	 AND COV_LVL_ELEM.DATE_END(+) <= LIN_SCH_DT.DATE_END ) SCH_LIN_INSERT;

 /* IF G_STMT_LOG THEN
		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
 END IF;  */

/* IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
			null;
 END IF;  */

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Generate_bil_sch_Service_line;

--========================================================================
-- PROCEDURE : 	Generate_billing_schedules     PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure will generate Billing Streams and schedules
--		for sublines and lines
--=========================================================================

PROCEDURE Generate_billing_schedules
IS
	l_stmt_num  NUMBER := 0;
	l_routine   CONSTANT VARCHAR2(30) := 'Generate_billing_schedules';
	l_int_count     NUMBER := 0;
	l_stg_count     NUMBER := 0;
	l_recur_bill_occurance NUMBER := 0 ;
  BEGIN
	IF G_PROCEDURE_LOG THEN
		 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  ');

	END IF;


	l_stmt_num := 10;

		Generate_bil_sch_Service_line;
	l_stmt_num :=20 ;
		Generate_bil_sch_Subs_lines;

	l_stmt_num := 30;
		Generate_bil_sch_Usage_lines;

	IF G_STMT_LOG THEN
		fnd_log.string(fnd_log.level_statement,
		     G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
			 'Number of records successfully inserted = ' || l_int_count );
	 END IF;

	IF G_PROCEDURE_LOG THEN
	      fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
			null;
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Generate_billing_schedules;

--========================================================================
-- PROCEDURE  :  Generate_PM_schedules      PRIVATE
-- PARAMETERS :
-- COMMENT    :  This procedure will invoke the API's to generate
--	         the Preventive maintenance schedules
--=========================================================================

PROCEDURE Generate_PM_schedules
IS

CURSOR get_line_cnt_details
IS

SELECT OKSLINB_LINE.COVERAGE_ID as reference_template_id
      ,OKCLINB_LINE.id	as cle_id
      ,OKCLINB_LINE.start_date as start_date
      ,OKCLINB_LINE.end_date   as end_date

FROM  OKS_INT_LINE_STG_TEMP      OLSTG
      ,OKS_INT_HEADER_STG_TEMP    HDRSTG
      ,OKC_K_LINES_B              OKCLINB_LINE
      ,OKS_K_LINES_B              OKSLINB_LINE
      ,OKC_K_HEADERS_ALL_B        OKCHDRB
WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
AND   HDRSTG.INTERFACE_STATUS ='S'
AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
AND   OKCLINB_LINE.DNZ_CHR_ID = OKCHDRB.ID
AND   OKCLINB_LINE.CHR_ID = OKCHDRB.ID
AND   OKCLINB_LINE.LINE_NUMBER = OLSTG.LINE_NUMBER
AND   OKSLINB_LINE.CLE_ID = OKCLINB_LINE.ID
AND OLSTG.LINE_TYPE <> 'USAGE';


-- ===========================
--	VARIABLES
-- ===========================

l_stmt_num  NUMBER := 0;
l_routine   CONSTANT VARCHAR2(30) := 'Generate_PM_schedules';


l_api_version	  CONSTANT	NUMBER     := 1.0;
l_init_msg_list	  CONSTANT	VARCHAR2(1):= 'F';
l_return_status			VARCHAR2(1);
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000):=null;

TYPE cur_line_cnt_txn_tab IS TABLE OF get_line_cnt_details%rowtype INDEX BY BINARY_INTEGER;
l_cur_line_cnt_txn_tab	cur_line_cnt_txn_tab;
l_empty_txn_tab		cur_line_cnt_txn_tab;

l_current_index    BINARY_INTEGER := 0;
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;

BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  .' );
 END IF;

 FND_MSG_PUB.initialize;

l_stmt_num := 10;

	IF NOT get_line_cnt_details%ISOPEN THEN
		OPEN get_line_cnt_details ;
	END IF;

	LOOP
		l_cur_line_cnt_txn_tab := l_empty_txn_tab;
		FETCH get_line_cnt_details BULK COLLECT INTO l_cur_line_cnt_txn_tab LIMIT l_batch_size;

		l_loop_count := l_cur_line_cnt_txn_tab.count;

		FOR i IN 1..l_loop_count
			LOOP
				l_stmt_num := 20;

					OKS_PM_PROGRAMS_PVT.CREATE_PM_PROGRAM_SCHEDULE
						       (p_api_version	=> l_api_version ,
							p_init_msg_list => l_init_msg_list,
							x_return_status => l_return_status ,
							x_msg_count  => l_msg_count ,
							x_msg_data  => l_msg_data ,
							p_template_cle_id  => l_cur_line_cnt_txn_tab(i).reference_template_id ,
							p_cle_id  =>  l_cur_line_cnt_txn_tab(i).cle_id ,
							p_cov_start_date =>  l_cur_line_cnt_txn_tab(i).start_date ,
							p_cov_end_date => l_cur_line_cnt_txn_tab(i).end_date );

			END LOOP;	 -- FOR i IN 1..l_loop_count

	IF G_EXCEPTION_LOG THEN
			FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , l_msg_data || 'Return Status ' || l_return_status);
	END IF;

		EXIT WHEN get_line_cnt_details%NOTFOUND;

	END LOOP;	-- fetch loop

CLOSE get_line_cnt_details;

 IF G_STMT_LOG THEN

        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' || l_stmt_num,
		' Succesffully Created Preventive Maintainence Schedules ' );
  END IF;

IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Generate_PM_schedules ;

--========================================================================
-- PROCEDURE  :  Create_JTF_notes       PRIVATE
-- PARAMETERS :
-- COMMENT    :  This procedure will invoke the API to create JTF notes
--		 for headers and lines.
--=========================================================================

PROCEDURE  Create_JTF_notes
IS

CURSOR get_hdr_notes
IS

 SELECT 'OKS_HDR_NOTE'			SOURCE_OBJECT_CODE
        ,OKCHDRB.ID			SOURCE_OBJECT_ID
	,OKS_NT_INT.NOTES		NOTES
	,OKS_NT_INT.NOTES_DETAIL	NOTES_DETAIL
	,OKS_NT_INT.NOTE_STATUS		NOTE_STATUS
	,OKS_NT_INT.NOTE_TYPE		NOTE_TYPE
	,OKS_NT_INT.ENTERED_BY		ENTERED_BY
	,OKS_NT_INT.ENTERED_DATE	ENTERED_DATE
FROM     OKS_NOTES_INTERFACE		OKS_NT_INT
	,OKS_int_header_stg_temp	HDRSTG
	,OKC_K_HEADERS_ALL_B		OKCHDRB
WHERE   OKS_NT_INT.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
AND     OKS_NT_INT.LINE_INTERFACE_ID IS NULL
AND     HDRSTG.INTERFACE_STATUS ='S'
AND     HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
AND     NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') ;


CURSOR get_line_notes
IS

 SELECT 'OKS_COV_NOTE'            SOURCE_OBJECT_CODE
	,OKCLINB.ID               SOURCE_OBJECT_ID
	,OKS_NT_INT.NOTES         NOTES
	,OKS_NT_INT.NOTES_DETAIL  NOTES_DETAIL
	,OKS_NT_INT.NOTE_STATUS   NOTE_STATUS
	,OKS_NT_INT.NOTE_TYPE     NOTE_TYPE
	,OKS_NT_INT.ENTERED_BY    ENTERED_BY
	,OKS_NT_INT.ENTERED_DATE  ENTERED_DATE

FROM     OKS_NOTES_INTERFACE       OKS_NT_INT
	,OKS_INT_LINE_STG_TEMP    OLSTG
	,OKS_INT_HEADER_STG_TEMP  HDRSTG
	,OKC_K_HEADERS_ALL_B      OKCHDRB
	,OKC_K_LINES_B            OKCLINB

WHERE OKS_NT_INT.LINE_INTERFACE_ID = OLSTG.LINE_INTERFACE_ID
AND   OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
AND   OKS_NT_INT.LINE_INTERFACE_ID IS NOT NULL
AND   HDRSTG.INTERFACE_STATUS ='S'
AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
AND   OKCLINB.CHR_ID = OKCHDRB.ID
AND   OKCLInB.DNZ_CHR_ID = OKCHDRB.ID
AND   OKCLINB.LINE_NUMBER = OLSTG.LINE_NUMBER;

-- ================================
--	VARIABLES
-- ================================

l_stmt_num		NUMBER := 0;
l_routine   CONSTANT	VARCHAR2(30) := 'Create_JTF_notes' ;

l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000) := null ;
l_jtf_note_id		NUMBER;
l_jtf_note_contexts_tab  jtf_notes_pub.jtf_note_contexts_tbl_type ;


TYPE cur_get_hdr_notes IS TABLE OF get_hdr_notes%rowtype INDEX BY BINARY_INTEGER;
l_cur_hdr_notes_txn_tab		cur_get_hdr_notes;
l_empty_hdr_txn_tab		cur_get_hdr_notes;

TYPE cur_get_line_notes IS TABLE OF get_line_notes%rowtype INDEX BY BINARY_INTEGER;
l_cur_line_notes_txn_tab	cur_get_line_notes;
l_empty_line_txn_tab		cur_get_line_notes;

l_current_index    BINARY_INTEGER := 0;
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;

BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  .' );
 END IF;

 FND_MSG_PUB.initialize;

l_stmt_num := 10;

	IF NOT get_hdr_notes%ISOPEN THEN
		OPEN get_hdr_notes ;
	END IF;

	LOOP
		l_cur_hdr_notes_txn_tab := l_empty_hdr_txn_tab;
		FETCH get_hdr_notes BULK COLLECT INTO l_cur_hdr_notes_txn_tab LIMIT l_batch_size;

		l_loop_count := l_cur_hdr_notes_txn_tab.count;

		FOR i IN 1..l_loop_count
			LOOP
				l_stmt_num := 20;

				JTF_NOTES_PUB.create_note
				  (p_jtf_note_id            => NULL
				  , p_api_version           => 1.0
				  , p_init_msg_list         => 'F'
				  , p_commit                => 'F'
				  , p_validation_level      => 0
				  , x_return_status         => l_return_status
				  , x_msg_count             => l_msg_count
				  , x_msg_data              => l_msg_data
				  , p_source_object_code    => l_cur_hdr_notes_txn_tab(i).source_object_code
				  , p_source_object_id      => l_cur_hdr_notes_txn_tab(i).source_object_id
				  , p_notes                 => l_cur_hdr_notes_txn_tab(i).notes
				  , p_notes_detail          => l_cur_hdr_notes_txn_tab(i).notes_detail
				  , p_note_status           => l_cur_hdr_notes_txn_tab(i).note_status
				  , p_note_type             => l_cur_hdr_notes_txn_tab(i).note_type
				  , p_entered_by            => l_cur_hdr_notes_txn_tab(i).entered_by
				  , p_entered_date          => l_cur_hdr_notes_txn_tab(i).entered_date
				  , x_jtf_note_id           => l_jtf_note_id
				  , p_creation_date         => SYSDATE
				  , p_created_by            => FND_GLOBAL.USER_ID
				  , p_last_update_date      => SYSDATE
				  , p_last_updated_by       => FND_GLOBAL.USER_ID
				  , p_last_update_login     => FND_GLOBAL.LOGIN_ID
				  , p_attribute1            => NULL
				  , p_attribute2            => NULL
				  , p_attribute3            => NULL
				  , p_attribute4            => NULL
				  , p_attribute5            => NULL
				  , p_attribute6            => NULL
				  , p_attribute7            => NULL
				  , p_attribute8            => NULL
				  , p_attribute9            => NULL
				  , p_attribute10           => NULL
				  , p_attribute11           => NULL
				  , p_attribute12           => NULL
				  , p_attribute13           => NULL
				  , p_attribute14           => NULL
				  , p_attribute15           => NULL
				  , p_context               => NULL
				  , p_jtf_note_contexts_tab => l_jtf_note_contexts_tab);

			END LOOP;	 -- FOR i IN 1..l_loop_count

	IF G_EXCEPTION_LOG THEN
			FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , l_msg_data || 'Return Status ' || l_return_status);
	END IF;

		EXIT WHEN  get_hdr_notes%NOTFOUND;

	END LOOP;	-- fetch loop

CLOSE get_hdr_notes;

 IF G_STMT_LOG THEN

        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' || l_stmt_num,
		' Succesffully Created JTF Notes for headers ' );
  END IF;

l_stmt_num := 20;

IF NOT get_line_notes%ISOPEN THEN
	OPEN get_line_notes ;
END IF;

LOOP
	l_cur_line_notes_txn_tab := l_empty_line_txn_tab;
	FETCH get_line_notes BULK COLLECT INTO l_cur_line_notes_txn_tab LIMIT l_batch_size;

	l_loop_count := l_cur_line_notes_txn_tab.count;

	FOR i IN 1..l_loop_count

		LOOP
			l_stmt_num := 20;

			JTF_NOTES_PUB.create_note
				  (p_jtf_note_id            => NULL
				  , p_api_version           => 1.0
				  , p_init_msg_list         => 'F'
				  , p_commit                => 'F'
				  , p_validation_level      => 0
				  , x_return_status         => l_return_status
				  , x_msg_count             => l_msg_count
				  , x_msg_data              => l_msg_data
				  , p_source_object_code    => l_cur_line_notes_txn_tab(i).source_object_code
				  , p_source_object_id      => l_cur_line_notes_txn_tab(i).source_object_id
				  , p_notes                 => l_cur_line_notes_txn_tab(i).notes
				  , p_notes_detail          => l_cur_line_notes_txn_tab(i).notes_detail
				  , p_note_status           => l_cur_line_notes_txn_tab(i).note_status
				  , p_note_type             => l_cur_line_notes_txn_tab(i).note_type
				  , p_entered_by            => l_cur_line_notes_txn_tab(i).entered_by
				  , p_entered_date          => l_cur_line_notes_txn_tab(i).entered_date
				  , x_jtf_note_id           => l_jtf_note_id
				  , p_creation_date         => SYSDATE
				  , p_created_by            => FND_GLOBAL.USER_ID
				  , p_last_update_date      => SYSDATE
				  , p_last_updated_by       => FND_GLOBAL.USER_ID
				  , p_last_update_login     => FND_GLOBAL.LOGIN_ID
				  , p_attribute1            => NULL
				  , p_attribute2            => NULL
				  , p_attribute3            => NULL
				  , p_attribute4            => NULL
				  , p_attribute5            => NULL
				  , p_attribute6            => NULL
				  , p_attribute7            => NULL
				  , p_attribute8            => NULL
				  , p_attribute9            => NULL
				  , p_attribute10           => NULL
				  , p_attribute11           => NULL
				  , p_attribute12           => NULL
				  , p_attribute13           => NULL
				  , p_attribute14           => NULL
				  , p_attribute15           => NULL
				  , p_context               => NULL
				  , p_jtf_note_contexts_tab => l_jtf_note_contexts_tab);

			END LOOP;	 -- FOR i IN 1..l_loop_count

	IF G_EXCEPTION_LOG THEN
		FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , l_msg_data || 'Return Status ' || l_return_status);
	END IF;

		EXIT WHEN get_line_notes%NOTFOUND;

	END LOOP;	-- fetch loop

CLOSE get_line_notes;

 IF G_STMT_LOG THEN

        fnd_log.string(fnd_log.level_statement,
	     G_MODULE_HEAD || l_routine || '.' || l_stmt_num,
		' Succesffully Created JTF Notes for Lines ' );
  END IF;

IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END  Create_JTF_notes  ;

--========================================================================
-- PROCEDURE : 	Instantiate_srvc_ctr_events      PRIVATE
-- PARAMETERS:
-- COMMENT   : This procedure will invoke the API used to instantiate
--	      (a) Service counters associated with the service item and
--	      (b) events that have been defined for the item.
--=========================================================================

PROCEDURE Instantiate_srvc_ctr_events
IS

CURSOR get_line_itm_id
IS
SELECT  OLSTG.ITEM_ID		SERVICE_ITEM_ID
       ,OKCHDRB.ID		HDRB_ID
       ,OKCLINB.ID		LINB_ID

FROM   OKS_INT_LINE_STG_TEMP	OLSTG
      ,OKC_K_LINES_B		OKCLINB
      ,OKC_K_HEADERS_ALL_B	OKCHDRB
      ,OKS_INT_HEADER_STG_TEMP  HDRSTG

WHERE OLSTG.HEADER_INTERFACE_ID = HDRSTG.HEADER_INTERFACE_ID
AND   HDRSTG.INTERFACE_STATUS ='S'
AND   HDRSTG.CONTRACT_NUMBER = OKCHDRB.CONTRACT_NUMBER
AND   NVL(HDRSTG.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1') = NVL(OKCHDRB.CONTRACT_NUMBER_MODIFIER , 'Xwqwewe@!&*aQ1')
AND   OLSTG.LINE_NUMBER = OKCLINB.LINE_NUMBER
AND   OKCLINB.DNZ_CHR_ID = OKCHDRB.ID
AND   OKCLINB.CHR_ID = OKCHDRB.ID
AND   OLSTG.LINE_TYPE ='SERVICE';

-- ===========================
--        VARIABLES
-- ===========================

l_stmt_num  NUMBER := 0;
l_routine   CONSTANT VARCHAR2(30) := 'Instantiate_srvc_ctr_events';

l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000):=null;


l_ctr_grp_id_template	NUMBER;
l_ctr_grp_id_instance	NUMBER;
l_instcnd_inp_rec       OKC_INST_CND_PUB.instcnd_inp_rec;

TYPE cur_line_itm_txn_tab IS TABLE OF get_line_itm_id%rowtype INDEX BY BINARY_INTEGER;
l_cur_line_itm_txn_tab	cur_line_itm_txn_tab;
l_empty_txn_tab		cur_line_itm_txn_tab;

l_current_index    BINARY_INTEGER := 0;
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;


BEGIN

	IF G_PROCEDURE_LOG THEN
		fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  .' );
	END IF;

	FND_MSG_PUB.initialize;

	l_stmt_num := 10;

	IF NOT get_line_itm_id%ISOPEN THEN
		OPEN get_line_itm_id ;
	END IF;

	l_stmt_num :=20;
LOOP

	l_cur_line_itm_txn_tab := l_empty_txn_tab;
	FETCH get_line_itm_id BULK COLLECT INTO l_cur_line_itm_txn_tab LIMIT l_batch_size;

	l_loop_count := l_cur_line_itm_txn_tab.count;

	FOR i IN 1..l_loop_count
		LOOP
			CS_COUNTERS_PUB.AUTOINSTANTIATE_COUNTERS(
					 p_api_version               => 1.0 ,
					 p_init_msg_list             => okc_api.g_false,
					 x_return_status             => l_return_status,
					 x_msg_count                 => l_msg_count,
					 x_msg_data                  => l_msg_data,
					 p_commit                    => 'F',
					 p_source_object_id_template => l_cur_line_itm_txn_tab(i).service_item_id,
					 p_source_object_id_instance => l_cur_line_itm_txn_tab(i).linb_id,
					 x_ctr_grp_id_template       => l_ctr_grp_id_template,
					 x_ctr_grp_id_instance       => l_ctr_grp_id_instance);

			IF G_STMT_LOG THEN
				fnd_log.string(fnd_log.level_statement,
					G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
						'Auto instatianted Counters  for Record number' || i || '    Return Status  is   '
						|| l_return_status );
			END IF;

				l_instcnd_inp_rec.ins_ctr_grp_id	:= l_ctr_grp_id_instance;
				l_instcnd_inp_rec.tmp_ctr_grp_id	:= l_ctr_grp_id_template;
				l_instcnd_inp_rec.chr_id 		:= l_cur_line_itm_txn_tab(i).hdrb_id;
				l_instcnd_inp_rec.cle_id 		:= l_cur_line_itm_txn_tab(i).linb_id ;
				l_instcnd_inp_rec.jtot_object_code 	:= 'OKC_K_LINE';
				l_instcnd_inp_rec.inv_item_id 		:= l_cur_line_itm_txn_tab(i).service_item_id ;

			OKC_INST_CND_PUB.INST_CONDITION(
						 p_api_version               => 1.0 ,
						 p_init_msg_list             => okc_api.g_false,
						 x_return_status             => l_return_status,
						 x_msg_count                 => l_msg_count,
						 x_msg_data                  => l_msg_data,
						 p_instcnd_inp_rec           => l_instcnd_inp_rec);

			IF G_STMT_LOG THEN
				fnd_log.string(fnd_log.level_statement,
					G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
						'Instantiated events for Record number' || i || '    Return Status  is   '
						|| l_return_status );
			END IF;

		END LOOP;	 -- FOR i IN 1..l_loop_count

	IF G_EXCEPTION_LOG THEN
			FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, G_MODULE_HEAD || l_routine , l_msg_data || 'Return Status ' || l_return_status);
	END IF;

		EXIT WHEN get_line_itm_id%NOTFOUND ;

	END LOOP;	-- fetch loop

CLOSE get_line_itm_id;

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Instantiate_srvc_ctr_events ;


--========================================================================
-- PROCEDURE : 	Import_Post_Insert     PUBLIC
-- PARAMETERS:
-- COMMENT   : This procedure will invoke the procedures to implement
--             the Post Insert Process
--=========================================================================


PROCEDURE Import_Post_Insert
IS

 l_stmt_num  NUMBER := 0;
  l_routine   CONSTANT VARCHAR2(30) := 'Import_Post_Insert';
BEGIN

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Entering  .' );

 END IF;

 FND_MSG_PUB.initialize;

l_stmt_num := 10;

	Generate_billing_schedules ;
	Generate_PM_schedules ;
	Create_JTF_notes ;
	Instantiate_srvc_ctr_events;

 IF G_PROCEDURE_LOG THEN
	 fnd_log.string(fnd_log.level_procedure,
			G_MODULE_HEAD || l_routine || '.' ||l_stmt_num,
                        'Exit.');
 END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		--     ROLLBACK;
		RAISE FND_API.G_EXC_ERROR;
	WHEN OTHERS THEN
		--    ROLLBACK;
		FND_MESSAGE.Set_Name('OKS', 'OKS_IMPORT_UNEXPECTED');
		FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
		FND_MESSAGE.set_token('MESSAGE', 'stmt_num '||l_stmt_num||' ('||SQLCODE||') '||SQLERRM);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;

END Import_Post_Insert;

END OKS_IMPORT_POST_INSERT;

/
