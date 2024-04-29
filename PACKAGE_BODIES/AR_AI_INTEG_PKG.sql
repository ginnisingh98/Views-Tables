--------------------------------------------------------
--  DDL for Package Body AR_AI_INTEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AI_INTEG_PKG" AS
/*$Header: ARXINTEGB.pls 120.2.12010000.6 2009/02/11 11:17:19 rsamanta noship $ */
G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'AR_AI_INTEG_PKG';
procedure DEFAULT_ATTRIBUTES (  p_org_id IN NUMBER,
                                p_bill_to_customer_account_id IN NUMBER,
                                p_ship_to_customer_account_id IN NUMBER,
                                p_currency_code IN VARCHAR2,
                                x_bill_to_address_id OUT NOCOPY VARCHAR2,
                                x_ship_to_address_id OUT NOCOPY VARCHAR2,
                                x_payment_term_id OUT NOCOPY NUMBER,
                                x_conversion_type OUT NOCOPY VARCHAR2,
                                x_conversion_date OUT NOCOPY DATE,
                                x_conversion_rate OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY    VARCHAR2)
IS
l_currency_code GL_LEDGERS.currency_code%TYPE;
l_procedure_name VARCHAR2(30);
BEGIN


l_procedure_name := '.DEFAULT_ATTRIBUTES';

 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'AR_AI_INTEG_PKG.DEFAULT_ATTRIBUTES (+)');
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'org_id : '||p_org_id);
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'bill_to_customer_account_id : '||p_bill_to_customer_account_id);
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'ship_to_customer_account_id : '||p_ship_to_customer_account_id);
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'currency_code : '||p_currency_code);
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_org_id is NULL THEN
             FND_MESSAGE.SET_NAME('AR','AR_MAND_PARAMETER_NULL');
             FND_MESSAGE.SET_TOKEN('PARAM','p_org_id');
             x_msg_data := FND_MESSAGE.GET;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
      END IF;
      IF p_bill_to_customer_account_id IS NULL THEN
             FND_MESSAGE.SET_NAME('AR','AR_MAND_PARAMETER_NULL');
             FND_MESSAGE.SET_TOKEN('PARAM','p_bill_to_customer_account_id');
             x_msg_data := FND_MESSAGE.GET;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
      END IF;

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Retrieving the Functional Currency');
  END IF;
   select  gl.currency_code into l_currency_code
    from ar_system_parameters_all asp,
           gl_ledgers gl
    where org_id = p_org_id
    and    gl.ledger_id = asp.set_of_books_id;

/*If the currency is in functional currency then only  defaulting . */
    IF p_currency_code  = l_currency_code THEN
          x_conversion_type := 'User';
          x_conversion_rate := 1;
          x_conversion_date := trunc(sysdate);

    END IF;
  BEGIN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Get the primary bill to site and payment_term_id');
      END IF;
         /* Get the primary bill to site */
            select site_use.cust_acct_site_id, site_use.PAYMENT_TERM_ID
                into x_bill_to_address_id,x_payment_term_id
               from hz_cust_site_uses_all site_use,
                    hz_cust_acct_sites_all sites
               where sites.cust_account_id = p_bill_to_customer_account_id
               and sites.status ='A'
               and sites.cust_acct_site_id = site_use.cust_acct_site_id
               and site_use.site_use_code = 'BILL_TO'
    	         and site_use.primary_flag = 'Y'
               and site_use.org_id = p_org_id;
        EXCEPTION
            WHEN NO_DATA_FOUND  THEN
            IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'No Primary Bill to Site');
            END IF;


   END;

    BEGIN
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Get the primary ship to site');
        END IF;
           /* Get the primary ship to site */
           IF p_ship_to_customer_account_id IS NOT NULL THEN
           select site_use.cust_acct_site_id
                  into x_ship_to_address_id
                 from hz_cust_site_uses_all site_use,
                      hz_cust_acct_sites_all sites
                 where sites.cust_account_id = p_ship_to_customer_account_id
                 and sites.status ='A'
                 and sites.cust_acct_site_id = site_use.cust_acct_site_id
                 and site_use.site_use_code = 'SHIP_TO'
      	         and site_use.primary_flag = 'Y'
                 and site_use.org_id = p_org_id;
             END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND  THEN
          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'No Primary Ship to Site');
          END IF;
    END;

   BEGIN
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Get the payment term id');
      END IF;

         IF x_payment_term_id Is NULL THEN
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Get the payment term id from hz_cust_accounts table');
           END IF;
         select payment_term_id into x_payment_term_id
          from  hz_cust_accounts
          where CUST_ACCOUNT_ID = p_bill_to_customer_account_id;
          END IF;

    EXCEPTION
            WHEN NO_DATA_FOUND  THEN
            IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'No Payment term id corresponding to bill_to_customer_account_id');
            END IF;
  END;

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'bill_to_address_id : '||x_bill_to_address_id);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'ship_to_address_id : '||x_ship_to_address_id);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'payment_term_id : '||x_payment_term_id);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'conversion_type : '||x_conversion_type);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'conversion_date : '||x_conversion_date);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'conversion_rate : '||x_conversion_rate);
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'AR_AI_INTEG_PKG.DEFAULT_ATTRIBUTES (-)');
    END IF;

     EXCEPTION
        WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR' ,SQLERRM);
        x_msg_data := fnd_message.get;

       IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_EXCEPTION,G_PKG_NAME||l_procedure_name,'SQLERRM :'||SQLERRM);
        END IF;

 END DEFAULT_ATTRIBUTES;

 END AR_AI_INTEG_PKG;

/
