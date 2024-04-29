--------------------------------------------------------
--  DDL for Package Body ARI_SERVICE_CHARGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_SERVICE_CHARGE_PKG" AS
/* $Header: ARISCRGB.pls 120.2.12010000.4 2010/05/13 13:09:19 nkanchan ship $ */

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/

G_PKG_NAME      CONSTANT VARCHAR2(40)    := 'ARI_SERVICE_CHARGE_PKG';
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

CURSOR C_INVOICE_SET IS
SELECT PAYMENT_SCHEDULE_ID,
       PAYMENT_AMT,
       CUSTOMER_ID,
       ACCOUNT_NUMBER,
       CUSTOMER_TRX_ID,
       CURRENCY_CODE,
       STATUS
FROM  AR_IREC_PAYMENT_LIST_GT;

/*========================================================================
 | PROCEDURE    Adjust Invoice
 |
 | DESCRIPTION  iReceivables adjust invoice
 |
 |
 | PARAMETERS adjustment_rec_type IN adjustment_rec_type
 |
 *=======================================================================*/
FUNCTION ADJUST_INVOICE (P_ADJUSTMENT_REC_TYPE IN ARI_SERVICE_CHARGE_PKG.ADJUSTMENT_REC_TYPE)
RETURN VARCHAR2

IS

RETURN_VALUE            VARCHAR2(01) ;
L_API_VERSION 			NUMBER ;
L_RETURN_STATUS  		VARCHAR2(1);
L_MSG_COUNT    			NUMBER;
L_MSG_DATA     			VARCHAR2(2000);
L_MSG_INDEX    			NUMBER;
L_MESG		  		VARCHAR2(2000);
L_NEW_ADJUST_NUMBER		VARCHAR2(20);
L_NEW_ADJUST_ID			NUMBER(15);
L_ADJ_REC				AR_ADJUSTMENTS%ROWTYPE;
L_PROCEDURE_NAME	    VARCHAR2(30) ;
l_debug_info            VARCHAR2(200);

BEGIN

   --Assign default values
   RETURN_VALUE    := FND_API.G_RET_STS_SUCCESS;
   L_API_VERSION   := 1.0;
   L_RETURN_STATUS := NULL;
   L_MSG_COUNT     := 0;
   L_MSG_DATA      := NULL;
   L_MSG_INDEX     := 0;
   L_MESG          := NULL;
   L_NEW_ADJUST_NUMBER := NULL;
   L_NEW_ADJUST_ID := 0;
   L_PROCEDURE_NAME:= '.ADJUST_INVOICE';

   L_ADJ_REC.TYPE 				  := 'CHARGES';
   L_ADJ_REC.PAYMENT_SCHEDULE_ID  := P_ADJUSTMENT_REC_TYPE.PAYMENT_SCHEDULE_ID;
   L_ADJ_REC.RECEIVABLES_TRX_ID   := P_ADJUSTMENT_REC_TYPE.RECEIVABLES_TRX_ID;
   L_ADJ_REC.AMOUNT			      := P_ADJUSTMENT_REC_TYPE.AMOUNT;
   -- KRM - Look into this logic
   -- Since we are not doing a line adjustment, we may not
   -- need this at all.
   -- If the TYPE = Invoice then this value is not required
   L_ADJ_REC.APPLY_DATE		      := P_ADJUSTMENT_REC_TYPE.APPLY_DATE;
   L_ADJ_REC.GL_DATE			  := P_ADJUSTMENT_REC_TYPE.GL_DATE;
   L_ADJ_REC.CREATED_FROM		  := P_ADJUSTMENT_REC_TYPE.CREATED_FROM;

   --------------------------------------------------------------------
   l_debug_info := 'Adjusting Invoice, calling CREATE_ADJUSTMENT';
   --------------------------------------------------------------------

   -- Bug 3892588 - Modified call to ensure the adjusted amount is not validated against the user's approval limit
   AR_ADJUST_PUB.CREATE_ADJUSTMENT(P_API_NAME          => 'AR_ADJUST_PUB'
                                  ,P_API_VERSION       => L_API_VERSION
				  ,P_INIT_MSG_LIST     => FND_API.G_TRUE
                               	  ,P_MSG_COUNT	       => L_MSG_COUNT
    			   	  ,P_MSG_DATA	       => L_MSG_DATA
  			   	  ,P_RETURN_STATUS     => L_RETURN_STATUS
			   	  ,P_ADJ_REC	       => L_ADJ_REC
			   	  ,P_NEW_ADJUST_NUMBER => L_NEW_ADJUST_NUMBER
			   	  ,P_NEW_ADJUST_ID     => L_NEW_ADJUST_ID
				  ,P_CHK_APPROVAL_LIMITS => 'F');


   IF L_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
 	    RETURN_VALUE := FND_API.G_RET_STS_ERROR;
	    --Bug 4146107 - Errors during payment not bubbled up
            IF L_MSG_DATA IS NOT NULL THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, L_PROCEDURE_NAME, L_MSG_DATA);
            END IF;
        IF (PG_DEBUG = 'Y') THEN
           arp_standard.debug('Result from api: Adj Nbr = ' || L_NEW_ADJUST_NUMBER);
           arp_standard.debug('L_RETURN_STATUS=>'||L_RETURN_STATUS);
           arp_standard.debug('L_MSG_COUNT=>'||to_char(L_MSG_COUNT));
        END IF;
   END IF;  -- END RETURN NOT SUCCESS

RETURN(RETURN_VALUE);

EXCEPTION
  WHEN  OTHERS  THEN
   IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
     arp_standard.debug('ERROR =>'|| SQLERRM);
   END IF;
   --Bug 3630101
   FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
   FND_MSG_PUB.ADD;

   RETURN_VALUE := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN(RETURN_VALUE);
END ADJUST_INVOICE;


/* =======================================================================
 | PROCEDURE    Compute Service Charge
 |
 | DESCRIPTION  iReceivables PROCEDURE TO RETURN THE SERVICE CHARGE -
 |
 |
 |
 * ======================================================================*/
PROCEDURE COMPUTE_SERVICE_CHARGE(P_INVOICE_SET IN OUT NOCOPY ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE,
                                 P_PAYMENT_TYPE IN varchar2 DEFAULT NULL, P_LOOKUP_CODE IN varchar2 DEFAULT NULL)
IS

  L_PROCEDURE_NAME	    VARCHAR2(30);
  L_COUNT                 NUMBER ;
  L_TOTAL_COUNT           NUMBER;
  L_SERVICE_CHARGE_AMOUNT NUMBER;
  L_TOTAL_SERVICE_CHARGE  NUMBER;
  l_debug_info            VARCHAR2(200);
  L_SERVICE_CHRG_PRCNT    NUMBER;
  L_LOOKUP_TYPE           VARCHAR2(200);
BEGIN

--Assign default values
L_PROCEDURE_NAME  	:= '.COMPUTE_SERVICE_CHARGE';
L_SERVICE_CHARGE_AMOUNT := 0;
L_TOTAL_SERVICE_CHARGE  := 0;

/*
This procedure can be customized by the customer.
Service charge can be added by the amount of the invoice or by the percentage
of the invoice amount or the flat amount or the layered rate.
--
1) CALCULATE THE ONE(FLAT CHARGE) CHARGE FOR THE SET OF INVOICES - IF WE DO
   THAT FOR WHICH INVOICE WE UPDATE THE CHARGE IN THE GLOBAL TABLE AND ALSO
   FOR WHICH INVOICE WE ADD THE AMOUNT.
2) IF THE SERVICE CHARGE IS CALCULATED FOR EVERY INVOICE,UPDATE the GLOBAL
   TABLE WITH THE SERVICE CHARGE
*/
   --------------------------------------------------------------------
   l_debug_info := 'Calculating service charge';
   --------------------------------------------------------------------

  -- Here is an example of a pro-rated service charge;
  -- Flat rate service charge:
  L_TOTAL_SERVICE_CHARGE := P_INVOICE_SET.COUNT * 2;

  -- Prorate the service charge for the invoices
  L_TOTAL_COUNT := P_INVOICE_SET.COUNT;
  L_SERVICE_CHARGE_AMOUNT := L_TOTAL_SERVICE_CHARGE/L_TOTAL_COUNT;

  -- Since we do not know how the table may have been indexed
  -- we shall play it safe by using NEXT to traverse the table
  L_COUNT := P_INVOICE_SET.FIRST;

  -- CUSTOMIZED % BASED CODE
  L_TOTAL_SERVICE_CHARGE := 0;

if P_PAYMENT_TYPE = 'CREDIT_CARD' then
   L_SERVICE_CHRG_PRCNT := 0;
   L_LOOKUP_TYPE := 'AR_CREDIT_CARD_SURCHARGE';
else
   L_SERVICE_CHRG_PRCNT := 0.05;
   L_LOOKUP_TYPE := null;
end if;

-- fnd_lookup_values, ar_lookups
  IF P_LOOKUP_CODE IS NOT NULL THEN
    BEGIN
      SELECT ATTRIBUTE1 INTO L_SERVICE_CHRG_PRCNT from ar_lookups where lookup_type = upper(L_LOOKUP_TYPE) AND lookup_code = upper(P_LOOKUP_CODE)
      AND ENABLED_FLAG='Y' and sysdate between start_date_active and nvl(end_date_active,sysdate);
    EXCEPTION
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Could not find Service Charge Lookup Value in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('Service Charge lookup_type : ' || P_PAYMENT_TYPE);
         arp_standard.debug('Service Charge lookup_code : ' || p_lookup_code);
    END;
  END IF;

  --if no value is defined for credit card type in lookup then setting default values 0.05
  IF L_SERVICE_CHRG_PRCNT is null or L_SERVICE_CHRG_PRCNT ='' then
   L_SERVICE_CHRG_PRCNT := 0.05;
  END IF;

  WHILE L_COUNT IS NOT NULL
  LOOP
    L_SERVICE_CHARGE_AMOUNT := P_INVOICE_SET(L_COUNT).PAYMENT_AMOUNT * L_SERVICE_CHRG_PRCNT/100;

    P_INVOICE_SET(L_COUNT).SERVICE_CHARGE := L_SERVICE_CHARGE_AMOUNT;

    L_TOTAL_SERVICE_CHARGE := L_TOTAL_SERVICE_CHARGE + L_SERVICE_CHARGE_AMOUNT;

    L_COUNT := P_INVOICE_SET.NEXT(L_COUNT);
  END LOOP;

  EXCEPTION
    WHEN  OTHERS  THEN
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END COMPUTE_SERVICE_CHARGE;


/* =======================================================================
 | PROCEDURE    Apply Service Charge
 |
 | DESCRIPTION  iReceivables PROCEDURE TO APPLY THE SERVICE CHARGE -
 |
 |
 | PARAMETERS
 |
 * ======================================================================*/
FUNCTION APPLY_CHARGE(P_INVOICE_SET IN ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE)
RETURN VARCHAR2
IS

L_RETURN_VALUE      VARCHAR2(1)	;
L_PROCEDURE_NAME    VARCHAR2(30);

L_ADJ_REC		ARI_SERVICE_CHARGE_PKG.ADJUSTMENT_REC_TYPE;
L_COUNT                 NUMBER;
L_TOTAL_INVOICES        NUMBER;
l_debug_info            VARCHAR2(200);
L_CUSTOMER_ID           NUMBER(15);
L_CUSTOMER_SITE_USE_ID  NUMBER(15);

BEGIN
  --Assign default values
  L_RETURN_VALUE         := NULL;
  L_PROCEDURE_NAME       := '.APPLY_CHARGE';

  --fnd_log_repository.init;
  -- Since we do not know how the table may have been indexed
  -- we shall play it safe by using NEXT to traverse the table
  L_COUNT := P_INVOICE_SET.FIRST;

  --------------------------------------------------------------------
   l_debug_info := 'Applying service charge';
  --------------------------------------------------------------------
  --Bug 3886652 - Customer and Customer Site added as params to ARI_CONFIG.get_service_charge_activity_id
  WHILE L_COUNT IS NOT NULL
  LOOP
     -- Call the AR_ADJUST api to adjust the invoice.
     L_ADJ_REC.PAYMENT_SCHEDULE_ID  := P_INVOICE_SET(L_COUNT).PAYMENT_SCHEDULE_ID;
     L_CUSTOMER_ID                  := P_INVOICE_SET(L_COUNT).CUSTOMER_ID;
     L_CUSTOMER_SITE_USE_ID         := P_INVOICE_SET(L_COUNT).CUSTOMER_SITE_USE_ID;
     L_ADJ_REC.RECEIVABLES_TRX_ID   := ARI_UTILITIES.get_service_charge_activity_id(L_CUSTOMER_ID, L_CUSTOMER_SITE_USE_ID);
     L_ADJ_REC.AMOUNT			    := P_INVOICE_SET(L_COUNT).SERVICE_CHARGE;
     L_ADJ_REC.APPLY_DATE		    := sysdate;
     L_ADJ_REC.GL_DATE			    := sysdate;
     L_ADJ_REC.CREATED_FROM		    := 'ARI_ADJ_INVOICE';

     -- Call the adjustment API Wrapper
     L_RETURN_VALUE :=ARI_SERVICE_CHARGE_PKG.ADJUST_INVOICE(L_ADJ_REC);

     IF L_RETURN_VALUE <> FND_API.G_RET_STS_SUCCESS THEN
       L_RETURN_VALUE := FND_API.G_RET_STS_ERROR;
       IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
         arp_standard.debug('ERROR =>'|| SQLERRM);
       END IF;
       EXIT;
     END IF;

     L_COUNT := P_INVOICE_SET.NEXT(L_COUNT);

  END LOOP;

  RETURN L_RETURN_VALUE;
  EXCEPTION
    WHEN  OTHERS  THEN
      IF (SQLCODE <> -20001) THEN
         IF (PG_DEBUG = 'Y') THEN
           arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
           arp_standard.debug('ERROR =>'|| SQLERRM);
         END IF;
         FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
         FND_MSG_PUB.ADD;
         RETURN FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

END APPLY_CHARGE;


END ARI_SERVICE_CHARGE_PKG;

/
