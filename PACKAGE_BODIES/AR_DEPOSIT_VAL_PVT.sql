--------------------------------------------------------
--  DDL for Package Body AR_DEPOSIT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DEPOSIT_VAL_PVT" AS
/* $Header: ARXDEPVB.pls 115.3 2003/07/24 22:43:43 anukumar noship $    */

--Validation procedures are contained in this package

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

PROCEDURE Validate_deposit_Date(p_deposit_date  IN DATE,
                                p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
    arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_deposit_Date()+');

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_deposit_Date()-');
END Validate_deposit_Date;

PROCEDURE Validate_batch_source(p_batch_source_id IN NUMBER ,
                                p_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy NUMBER :=NULL;
  BEGIN
    arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_batch_source()+');

    p_return_status := FND_API.G_RET_STS_SUCCESS;
    if ar_deposit_lib_pvt.pg_profile_batch_source is null and
       p_batch_source_id  is null
    then
        FND_MESSAGE.set_name( 'AR', 'AR_DAPI_NO_BATCH' );
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    end if;


    BEGIN
        IF p_batch_source_id is not null THEN
         SELECT batch_source_id
         INTO   l_dummy
         FROM   ra_batch_sources
         WHERE  batch_source_id  = p_batch_source_id;
        END IF;
    EXCEPTION
          WHEN no_data_found THEN
               arp_util.debug('EXCEPTION: no_data_found
                               Validate_batch_source() ');
               FND_MESSAGE.set_name( 'AR', 'AR_DAPI_COMM_BATCH_INVALID' );
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;


          WHEN others THEN
              arp_util.debug('EXCEPTION:others Validate_batch_source() ');
               p_return_status := FND_API.G_RET_STS_ERROR;
              RAISE;

    END;

    arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_batch_source()-');
END Validate_batch_source;


PROCEDURE Validate_Gl_Date(p_gl_date IN DATE,
                           p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Gl_Date ()+');
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( NOT arp_util.is_gl_date_valid( p_gl_date )) THEN
    FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
    FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_gl_date ));
    FND_MSG_PUB.Add;
    p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Gl_Date ()+');
END Validate_Gl_Date;


PROCEDURE Validate_amount(p_amount        IN NUMBER,
                          p_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_amount () +');
  p_return_status := FND_API.G_RET_STS_SUCCESS;

 --Raise error if the deposit amount is null or negative
 IF p_amount IS NULL THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AR','AR_DAPI_COMM_AMOUNT_NULL');
    FND_MSG_PUB.Add;

 ElSIF (p_amount < 0)
   THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AR','AR_TW_COMMIT_AMOUNT_NEGATIVE');
    FND_MSG_PUB.Add;

 END IF;

  arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_amount () -');
END Validate_amount;

PROCEDURE Validate_Exchange_Rate(
                      p_currency_code       IN  VARCHAR2,
                      p_exchange_rate_type  IN  VARCHAR2,
                      p_exchange_rate       IN  NUMBER,
                      p_exchange_rate_date  IN  DATE,
                      p_return_status       OUT NOCOPY VARCHAR2) IS
l_euro_to_emu_rate  NUMBER;
l_cross_rate   NUMBER;
l_conversion_rate  NUMBER;
l_exchange_rate_valid   varchar2(2);
BEGIN
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Exchange_Rate () +');
 p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_currency_code <> arp_global.functional_currency THEN

   IF p_exchange_rate_type IS NULL THEN

     -- raise exception
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_TYPE_NULL');
     FND_MSG_PUB.Add;
    Return;

   ELSE
     -- Validate the rate_type against the database values
     -- if invalid then return
    BEGIN
     SELECT 'Y'
     INTO   l_exchange_rate_valid
     FROM   gl_daily_conversion_types
     WHERE  conversion_type = p_exchange_rate_type;
    EXCEPTION
     WHEN no_data_found THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_TYPE_INVALID');
      FND_MSG_PUB.Add;
      Return;
    END;

    IF  p_exchange_rate_type = 'User' THEN

      IF p_exchange_rate IS NULL THEN
        --*** raise error message, because for rate_type 'User'
        --*** the rate should be specified.
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_NULL');
        FND_MSG_PUB.Add;
      ELSIF p_exchange_rate = 0 THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_EXCHANGE_RATE_ZERO');
        FND_MSG_PUB.Add;
      ELSIF p_exchange_rate < 0 THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_EXCHANGE_RATE_NEGATIVE');
        FND_MSG_PUB.Add;
      END IF;

    ELSE
       --this is the case where rate_type <> 'User'
      IF p_exchange_rate IS NULL THEN
       --This could happen only in case if the defaulting routines
       --could not get the exchange_rate
       --raise an error message in that case

        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR','AR_NO_RATE_DATA_FOUND');
        FND_MSG_PUB.Add;
      END IF;

    END IF;

   END IF;
 ELSE
   --the functional and the entered currency are same
   --so there should be no exchange_rate information

    IF (p_exchange_rate IS NOT NULL) THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_INVALID');
        FND_MSG_PUB.Add;
    END IF;
    IF (p_exchange_rate_type IS NOT NULL)  THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_TYPE_INVALID');
        FND_MSG_PUB.Add;
    END IF;
    IF (p_exchange_rate_date IS NOT NULL)  THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_DATE_INVALID');
        FND_MSG_PUB.Add;
    END IF;
 END IF;
   arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Exchange_Rate () -');
EXCEPTION
 WHEN others THEN
  arp_util.debug('EXCEPTION: Validate_Exchange_Rate() ');
  arp_util.debug('p_exchange_rate_type  =  '
                 ||p_exchange_rate_type);
  RAISE;
END Validate_Exchange_Rate;

FUNCTION Is_currency_valid(p_currency_code IN
                           ra_customer_trx.invoice_currency_code%TYPE)
RETURN VARCHAR2 IS
l_currency_valid VARCHAR2(1);
BEGIN
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Is_currency_valid () +');
   SELECT 'Y'
   INTO   l_currency_valid
   FROM   fnd_currencies
   WHERE  p_currency_code = currency_code;
  arp_util.debug('AR_DEPOSIT_VAL_PVT.Is_currency_valid () -');

   RETURN(l_currency_valid);

EXCEPTION
WHEN no_data_found THEN
 l_currency_valid := 'N';
 RETURN(l_currency_valid);
WHEN others THEN
 arp_util.debug('EXCEPTION: Validate_Exchange_Rate() ');
 arp_util.debug('p_currency_code  =  '||p_currency_code);
 raise;
END Is_currency_valid;

PROCEDURE Validate_Currency(
            p_currency_code   in ra_customer_trx.invoice_currency_code%TYPE,
            p_exchange_rate_type IN ra_customer_trx.exchange_rate_type%TYPE,
            p_exchange_rate IN ra_customer_trx.exchange_rate%TYPE,
            p_exchange_rate_date IN ar_cash_receipts.exchange_date%TYPE,
            p_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;
      arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Currency () +');
     IF (Is_currency_valid(p_currency_code) = 'Y') THEN

       IF  ((arp_global.functional_currency <> p_currency_code) OR
            (p_exchange_rate_type IS NOT NULL OR
             p_exchange_rate IS NOT NULL OR
             p_exchange_rate_date IS NOT NULL)) THEN

          Validate_Exchange_Rate(p_currency_code,
                                 p_exchange_rate_type,
                                 p_exchange_rate,
                                 p_exchange_rate_date,
                                 p_return_status);
         END IF;
     ELSE
        --the entered currency is invalid
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CURR_CODE_INVALID');
        FND_MSG_PUB.Add;
     END IF;
       arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Currency () -');
END Validate_Currency;

/*========================================================================
 | PUBLIC PROCEDURE Validate_Deposit
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |    This procedure does the following ......      |
 |    Perform some of basic validation
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      Validate_deposit_Date
 |      Validate_batch_source'
 |      Validate_Gl_Date
 |      Validate_amount
 |      Validate_Exchange_Rate
 |      Is_currency_valid
 |      Validate_Currency
 |      arp_util.debug(
 |      FND_MESSAGE.SET_NAME
 |      FND_MSG_PUB.Add;
 |
 | PARAMETERS
 | Parameter			Type	Description
 | p_batch_source_id    	IN      Batch source
 | p_deposit_date   		IN 	Deposit date
 | p_gl_date        		IN 	Gl Date
 | p_doc_sequence_value 	IN      Doc seq no value
 | p_amount         		IN      Deposit amount
 | p_currency_code  		IN      Currenct code
 | p_exchange_rate_type		IN      Exchange type
 | p_exchange_rate  		IN      Exchange rate
 | p_exchange_rate_date		IN      Exchange rate date
 | p_printing_option		IN      Printing option
 | p_status_trx     		IN      Transaction status
 | p_default_tax_exempt_flag	IN      Tax exempt flag
 | p_financial_charges		IN      Financial Charges
 | p_return_status 		OUT  NOCOPY    Return Status
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-MAY-2001           Anuj              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/

PROCEDURE Validate_Deposit(
     p_batch_source_id          IN ra_batch_sources.batch_source_id%type,
     p_deposit_date             IN date,
     p_gl_date                  IN date,
     p_doc_sequence_value       IN ra_customer_trx.doc_sequence_value%type,
     p_amount                   IN ra_customer_trx_lines.extended_amount%type,
     p_currency_code            IN ra_customer_trx.invoice_currency_code%TYPE,
     p_exchange_rate_type       IN ra_customer_trx.exchange_rate_type%TYPE,
     p_exchange_rate            IN ra_customer_trx.exchange_rate%TYPE,
     p_exchange_rate_date       IN ra_customer_trx.exchange_date%TYPE,
     p_printing_option          IN  VARCHAR2,
     p_status_trx               IN  VARCHAR2,
     p_default_tax_exempt_flag  IN  VARCHAR2,
     p_financial_charges        IN  VARCHAR2  DEFAULT NULL,
     p_return_status            OUT NOCOPY VARCHAR2)
IS
l_deposit_date_return_status  VARCHAR2(1);
l_gl_date_return_status       VARCHAR2(1);
l_batch_return_status         VARCHAR2(1);
l_amount_return_status        VARCHAR2(1);
l_currency_return_status      VARCHAR2(1);
l_doc_seq_return_status       VARCHAR2(1);
l_po_return_status            VARCHAR2(1);
l_status_trx_return_status    VARCHAR2(1);
l_fc_return_status             VARCHAR2(1);

cursor c_status_cur is   SELECT lookup_code CODE
                         FROM AR_LOOKUPS
                         WHERE LOOKUP_TYPE = 'INVOICE_TRX_STATUS';

c_status_rec              c_status_cur%rowtype;
c_status_result           VARCHAR2(1) := 'N';

cursor c_tax_flag_cur is
        select lookup_code CODE
        from ar_lookups
        where lookup_type = 'TAX_CONTROL_FLAG' and
        lookup_code <>
        decode(nvl(ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag,'Y'),
                'Y', '!@#$', 'N', 'E');
c_tax_flag              c_tax_flag_cur%rowtype;
l_tax_flag_return_status    VARCHAR2(1);
c_tax_flag_result           VARCHAR2(1) := 'N';

BEGIN
       arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Deposit () +');

      p_return_status                := FND_API.G_RET_STS_SUCCESS;
      l_deposit_date_return_status   := FND_API.G_RET_STS_SUCCESS;
      l_gl_date_return_status        := FND_API.G_RET_STS_SUCCESS;
      l_batch_return_status          := FND_API.G_RET_STS_SUCCESS;
      l_amount_return_status         := FND_API.G_RET_STS_SUCCESS;
      l_currency_return_status       := FND_API.G_RET_STS_SUCCESS;
      l_doc_seq_return_status        := FND_API.G_RET_STS_SUCCESS;
      l_po_return_status             := FND_API.G_RET_STS_SUCCESS;
      l_status_trx_return_status     := FND_API.G_RET_STS_SUCCESS;
      l_fc_return_status             := FND_API.G_RET_STS_SUCCESS;



    --validate batch source
     Validate_batch_source(p_batch_source_id,l_batch_return_status);
    arp_util.debug('l_batch_return_status : '||l_batch_return_status);
    --Validate deposit_Date

      Validate_deposit_Date(p_deposit_date,
                            l_deposit_date_return_status);


    --Validate gl_date

      Validate_Gl_Date(p_gl_date,
                       l_gl_date_return_status);
      arp_util.debug('l_gl_date_return_status : '||l_gl_date_return_status);


   --Validate document sequence value

      IF(NVL(ar_deposit_lib_pvt.pg_profile_doc_seq, 'N') = 'N' )  AND
          p_doc_sequence_value IS NOT NULL
        THEN
             l_doc_seq_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_VAL_INVALID');
             FND_MSG_PUB.Add;
       END IF;

   --Validate amount
      Validate_amount(p_amount ,
                      l_amount_return_status);
      arp_util.debug('l_amount_return_status : '||l_amount_return_status);

    --Validate Customer info


    --Validate currency and exchange rate info.
     IF p_currency_code <> arp_global.functional_currency OR
        p_exchange_rate_type IS NOT NULL OR
        p_exchange_rate  IS NOT NULL OR
        p_exchange_rate_date  IS NOT NULL THEN
       Validate_currency(p_currency_code,
                         p_exchange_rate_type,
                         p_exchange_rate,
                         p_exchange_rate_date,
                         l_currency_return_status);
     END IF;
     arp_util.debug('l_currency_return_status : '||l_currency_return_status);

    IF  p_printing_option not in ('PRI','NOT') and
        p_printing_option is not null
    THEN
            l_po_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_DAPI_PO_INVALID');
             FND_MSG_PUB.Add;

    END IF;

   IF  p_financial_charges not in ('Y','N') and
       p_financial_charges is not null
    THEN
        l_fc_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('AR','AR_DAPI_FC_INVALID');
        FND_MSG_PUB.Add;

    END IF;

--validation transaction status
  FOR c_status_rec in c_status_cur LOOP

   IF  p_status_trx = c_status_rec.code or
       p_status_trx is null
   THEN
        c_status_result := 'Y';
   END IF;

  END LOOP;
  IF c_status_result = 'N'   THEN
     l_status_trx_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_DAPI_STATUS_TRX_INVALID');
     FND_MSG_PUB.Add;

  END IF;

--validation tax flag
  FOR c_tax_flag_rec in c_tax_flag_cur LOOP
   IF  p_default_tax_exempt_flag = c_tax_flag_rec.code  or
       p_default_tax_exempt_flag is null
   THEN
        c_tax_flag_result := 'Y';
   END IF;

  END LOOP;

  IF c_tax_flag_result = 'N'   THEN
     l_tax_flag_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_DAPI_TAX_FLAG_INVALID');
     FND_MSG_PUB.Add;

  END IF;


    IF (l_gl_date_return_status       = FND_API.G_RET_STS_ERROR) OR
        (l_deposit_date_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_amount_return_status       = FND_API.G_RET_STS_ERROR) OR
        (l_currency_return_status     = FND_API.G_RET_STS_ERROR) OR
        (l_doc_seq_return_status      = FND_API.G_RET_STS_ERROR) OR
        (l_batch_return_status        = FND_API.G_RET_STS_ERROR) OR
        (l_status_trx_return_status   = FND_API.G_RET_STS_ERROR) OR
        (l_po_return_status           = FND_API.G_RET_STS_ERROR) OR
        (l_tax_flag_return_status     = FND_API.G_RET_STS_ERROR) OR
        (l_fc_return_status           = FND_API.G_RET_STS_ERROR)
    THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    arp_util.debug('Validate_Cash_Receipt Return status :'||p_return_status);
    arp_util.debug('AR_DEPOSIT_VAL_PVT.Validate_Deposit () -');
EXCEPTION
 WHEN others THEN
  raise;

END Validate_deposit;

END AR_DEPOSIT_VAL_PVT;

/
