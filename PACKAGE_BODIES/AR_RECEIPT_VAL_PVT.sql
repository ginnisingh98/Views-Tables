--------------------------------------------------------
--  DDL for Package Body AR_RECEIPT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RECEIPT_VAL_PVT" AS
/* $Header: ARXPREVB.pls 120.46.12010000.14 2010/03/11 23:04:02 dgaurab ship $    */
--Validation procedures are contained in this package

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Validate_Receipt_Date(p_receipt_date  IN DATE,
                                p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Receipt_Date()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Receipt_Date()-');
    END IF;
END Validate_Receipt_Date;

PROCEDURE Validate_Gl_Date(p_gl_date IN DATE,
                           p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_Gl_Date ()+');
  END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF ( NOT arp_util.is_gl_date_valid( p_gl_date )) THEN
    FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
    FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_gl_date ));
    FND_MSG_PUB.Add;
    p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_Gl_Date ()+');
  END IF;
END Validate_Gl_Date;

PROCEDURE Validate_Deposit_Date(p_deposit_date IN DATE,
                                p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Deposit_Date ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

END Validate_Deposit_Date;

PROCEDURE Validate_Maturity_Date(p_maturity_date IN DATE,
                                 p_receipt_date IN DATE,
                                 p_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Maturity_Date ()+');
   END IF;
 IF (p_maturity_date < p_receipt_date) THEN
   p_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.set_name( 'AR','AR_RW_MAT_BEFORE_RCT_DATE');
  -- arp_util.debug('m'||FND_MESSAGE.GET_ENCODED);
   FND_MSG_PUB.ADD;
 ELSE
   p_return_status := FND_API.G_RET_STS_SUCCESS;
 END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Maturity_Date ()-');
   END IF;
END Validate_Maturity_Date;

PROCEDURE Validate_amount(p_amount IN OUT NOCOPY NUMBER,
                          p_factor_discount_amount IN NUMBER,
                          p_state  IN VARCHAR2,
                          p_type   IN VARCHAR2,
                          p_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount () +');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

 --Raise error if the receipt amount is null or negative
 IF p_amount IS NULL THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_AMOUNT_NULL');
    FND_MSG_PUB.Add;

 ElSIF (p_amount < 0) AND (p_type = 'CASH')
   THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AR','AR_RW_RCT_AMOUNT_NEGATIVE');
    FND_MSG_PUB.Add;

 END IF;


-- If the profile option AR : Create bank charges = No or
-- the state is not CONFIRMED  then raise error if the
-- bank charges exist.

 IF (NVL(ar_receipt_lib_pvt.pg_profile_create_bk_charges,'N') = 'N')
  THEN

    IF ( NVL(p_factor_discount_amount,0) <> 0 )
     THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'AR_BK_CH_NOT_ALLWD_IF_NOT_CLR');
      FND_MSG_PUB.Add;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'Bank charges are not allowed ');
      END IF;
    END IF;

 ELSE

   IF (p_state <> 'CLEARED') AND (NVL(p_factor_discount_amount,0) <> 0 )
    THEN
     -- raise error about bank charges not allowed because the
     -- state of the receipt is <> 'CLEARED'
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_BK_CH_NOT_ALLWD_IF_NOT_CLR');
     FND_MSG_PUB.Add;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount: ' || 'The bank charges are not allowed if the state <> CLEARED');
     END IF;
   END IF;

   IF p_factor_discount_amount < 0  THEN

    -- Raise error if the bank charges amount less than 0
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_JG_BC_AMOUNT_NEGATIVE');
     FND_MSG_PUB.Add;
   END IF;

   p_amount := nvl(p_amount,0) + nvl(p_factor_discount_amount,0);

   IF (p_amount < 0) AND (p_type = 'CASH')
    THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_RW_RCT_AMOUNT_NEGATIVE');
     FND_MSG_PUB.Add;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount: ' || 'Receipt amount is negative ');
     END IF;
   END IF;

 END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount () +');
  END IF;
END Validate_amount;

PROCEDURE Validate_Customer(p_customer_id  IN NUMBER,
                            /* 6612301 */
                            p_customer_bank_account_id  IN OUT NOCOPY NUMBER,
                            p_location                  IN  VARCHAR2,
                            p_customer_site_use_id      IN OUT NOCOPY NUMBER,
                            p_currency_code             IN VARCHAR2,
                            p_receipt_date              IN DATE,
                            p_return_status             OUT NOCOPY VARCHAR2) IS

 l_temp BINARY_INTEGER;
 l_dummy_cust  Customer_Rec;
 l_record_exists_in_cache  VARCHAR2(2);
BEGIN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_amount: ' || 'Validate_Customer_id()+');
       END IF;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
/*         l_temp := Customer_Cache_Tbl.LAST;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_amount: ' || 'cache ');
          END IF;

          IF l_temp IS NULL THEN
             --The cache is empty : populate it directly.
             l_record_exists_in_cache := 'N';

          ELSE
             --this is the case where records exist in the cache, compare the current record
             --with these records.

             l_record_exists_in_cache := 'N';

            FOR l_counter IN 1..l_temp  LOOP
             IF (Customer_Cache_Tbl(l_counter).customer_id = p_customer_id) AND
                (Customer_Cache_Tbl(l_counter).site_use_id = p_customer_site_use_id)
              THEN
                   --Current record exists in the cache
                    l_record_exists_in_cache := 'Y';
                    EXIT;
              END IF;
             END LOOP;
          END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_amount: ' || 'record_exists_in_cache = '||l_record_exists_in_cache);
       END IF;
*/
       IF (p_customer_id IS NOT NULL) THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_amount: ' || 'Now Validating Customer id ');
          END IF;
              /*--------------------------------+
               |                                |
               |   Validate Customer_id         |
               |                                |
               +--------------------------------*/

          -- IF l_record_exists_in_cache = 'N'  THEN

                  /* modified for tca uptake */
                  /* fixed bug 1544201: removed references to
                     customer_prospect_code */
                  BEGIN
                    SELECT cust.cust_account_id
                    INTO   l_dummy_cust.customer_id
                    FROM   hz_cust_accounts cust,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           cust.cust_account_id = p_customer_id and
                           cust.party_id = party.party_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_ID_INVALID');
                         FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                         IF PG_DEBUG in ('Y', 'C') THEN
                            arp_util.debug('Validate_amount: ' || 'EXCEPTION: Cache_Customer_id() ');
                            arp_util.debug('Validate_amount: ' || 'p_customer_id  =  ' ||TO_CHAR(p_customer_id));
                         END IF;
                         RAISE;
                  END;

              /*------------------------------------+
               |                                    |
               | Validate Customer site_use_id      |
               |                                    |
               +------------------------------------*/
               --There is no point in validating the customer_site_use_id
               --and the customer bank account id if the validation of
               --customer id has failed

             IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
               --no need to validate site_use_id if derived from the transaction
              IF ar_receipt_lib_pvt.pg_cust_derived_from IS NULL THEN

               IF p_customer_site_use_id IS NOT NULL  THEN
                 --no need to validate site_use_id if derived from the transaction
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('Validate_amount: ' || 'Now validating Customer site_use_id ');
                 END IF;
                  BEGIN
                    SELECT site_uses.site_use_id
                    INTO   l_dummy_cust.site_use_id
                    FROM   hz_cust_site_uses_all site_uses,
                           hz_cust_acct_sites acct_site
                    WHERE  acct_site.cust_account_id = p_customer_id
                      /*AND  acct_site.status = 'A'  Bug 4317815*/
                      AND  acct_site.cust_acct_site_id =
                                     site_uses.cust_acct_site_id
                      AND  site_uses.site_use_code IN ('BILL_TO','DRAWEE')
                      /*AND  site_uses.status = 'A'  Bug 4317815*/
                      AND  site_uses.site_use_id = p_customer_site_use_id;
                     ar_receipt_lib_pvt.pg_cust_derived_from := NULL;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_STE_USE_ID_INVALID');
                         FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                         IF PG_DEBUG in ('Y', 'C') THEN
                            arp_util.debug('Validate_amount: ' || 'EXCEPTION: Validate_Customer_Site_Use_id() ');
                            arp_util.debug('Validate_amount: ' || 'p_customer_site_use_id  =  '
                                  ||TO_CHAR(p_customer_site_use_id));
                         END IF;
                         RAISE;
                  END;

               ELSE
                  --here we need to differentiate between the case where the location was
                  --passed in but the site_use_id could not be derived and the case where
                  --location was not passed in
                  IF p_location IS NOT NULL THEN
                  -- for the specified location there is no data in
                  -- hz_cust_site_uses
                  -- the error message was not raised in the defaulting routine.
                     p_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_LOC_INVALID');
                     FND_MSG_PUB.Add;
                  ELSE

                  --This is the case where customer site use id is null, neither it was supplied
                  --by the user nor it could be defaulted a WARNING message is raised to
                  --indicate that the customer site use id could not be defaulted.

                   IF nvl(arp_global.sysparam.site_required_flag,'N') = 'Y'  THEN
                    --error
                      FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_STE_USE_ID_NOT_DEF');
                      FND_MSG_PUB.Add;
                      p_return_status := FND_API.G_RET_STS_ERROR;
                   ELSE
                    --warning
                    IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
                      THEN
                      FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_STE_USE_ID_NOT_DEF');
                      FND_MSG_PUB.Add;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Validate_amount: ' || 'Customer site use id is null');
                      END IF;
                    END IF;
                   END IF;

                  END IF;
               END IF;
              ELSE
                 ar_receipt_lib_pvt.pg_cust_derived_from := NULL;
              END IF;

              /*------------------------------------+
               |                                    |
               | Validate Customer bank_account_id  |
               |                                    |
               +------------------------------------*/
/* 6612301 */
/*  Revert changes done for customer bank ref under payment uptake */
               IF p_customer_bank_account_id IS NOT NULL THEN

                 BEGIN
                 /*  SELECT   ba.bank_account_id
                   INTO     l_dummy_cust.bank_account_id
                   FROM     ap_bank_accounts ba,
                            ap_bank_account_uses bau
                   WHERE    ba.bank_account_id = bau.external_bank_account_id
                        and bau.customer_id = p_customer_id
                        and (bau.customer_site_use_id is null
                              or bau.customer_site_use_id = p_customer_site_use_id)
                        and (ba.currency_code = p_currency_code or
                             ba.bank_branch_id = 1)
                        -- OSTEINME 2/27/2001: change for iReceivables:
                        -- for credit card bank accounts the currency is
                        -- irrelevant.  See bug 1659130
                        and p_receipt_date
                             between nvl(bau.start_date,p_receipt_date)
                        and nvl(bau.end_date,p_receipt_date)
                        and nvl(ba.inactive_date,p_receipt_date) >=
                             p_receipt_date
                        and ba.bank_account_id = p_customer_bank_account_id; */

      select  bb.bank_account_id
			into  l_dummy_cust.bank_account_id
			from iby_fndcpt_payer_assgn_instr_v a,
			       iby_ext_bank_accounts_v bb
			where a.cust_account_id = p_customer_id
			and a.instrument_type = 'BANKACCOUNT'
			and ( a.acct_site_use_id =  p_customer_site_use_id or a.acct_site_use_id is null)
			and p_receipt_date  between nvl(trunc(bb.start_date),p_receipt_date)
						and nvl(trunc(bb.end_date),p_receipt_date)
			and a.currency_code = p_currency_code
			and bb.ext_bank_account_id = a.instrument_id
			and bb.bank_account_id = p_customer_bank_account_id;

                 EXCEPTION
                   WHEN no_data_found THEN
                    IF ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_id IS NOT NULL THEN
                     p_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_ID_INVALID');
                     FND_MSG_PUB.Add;
                    ELSIF ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_num IS NOT NULL THEN
                     p_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NUM_INVALID');
                     FND_MSG_PUB.Add;
                    ELSIF  ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_name IS NOT NULL THEN
                     p_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NAME_INVALID');
                     FND_MSG_PUB.Add;
                    END IF;
                   WHEN too_many_rows THEN
                     --Each customer site can have multiple accounts, so if it retrives more than
                     --one record, the validation is true.
                    null;
                   WHEN OTHERS THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Validate_amount: ' || 'EXCEPTION: Validate_Customer_Bank_account_id() ');
                        arp_util.debug('Validate_amount: ' || 'p_customer_bank_account_id  =  '
                               ||TO_CHAR(p_customer_bank_account_id));
                     END IF;
                     RAISE;

                 END;

               ELSE
                 --this is the case where the bank account id is neither entered
                 --by the user not could it be defaulted from the bank account number or name.
                 --the error for not being able to default the id from the name/number
                 --already raised in the defaulting routine
                null;
               END IF;

             END IF;

            /*  IF p_return_status =  FND_API.G_RET_STS_SUCCESS  THEN

                l_temp := nvl(l_temp,0) + 1;
                Customer_Cache_Tbl(l_temp) :=  l_dummy_cust;

              END IF;
            */
           --END IF; --if record_exists_in_cache = 'N'

       ELSE
             --If p_customer_id is null and the customer_bank_account_id or
             --the site_use_id has been passed in, then raise an error.
 /* 6612301 */
          IF p_customer_bank_account_id IS NOT NULL THEN
            IF ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_id IS NOT NULL
             THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_ID_INVALID');
              FND_MSG_PUB.Add;
            ELSIF ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_num IS NOT NULL
             THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NUM_INVALID');
              FND_MSG_PUB.Add;
            ELSIF ar_receipt_api_pub.Original_create_cash_info.customer_bank_account_name IS NOT NULL
             THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NAME_INVALID');
              FND_MSG_PUB.Add;
            END IF;

         END IF;    /* bichatte payment uptake commenting  ( Reverted) */

         IF p_customer_site_use_id IS NOT NULL THEN
            IF  ar_receipt_api_pub.Original_create_cash_info.cust_site_use_id IS NOT NULL
             THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_SITE_USE_ID_INVALID');
              FND_MSG_PUB.Add;
            ELSIF ar_receipt_api_pub.Original_create_cash_info.location IS NULL THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_LOC_INVALID');
              FND_MSG_PUB.Add;
            END IF;
         END IF;

       END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount: ' || 'Validate_Customer_id ()-');
   END IF;
END Validate_Customer;

PROCEDURE Validate_receipt_method (p_receipt_method_id  IN NUMBER,
                           p_remittance_bank_account_id  IN NUMBER,
                           p_receipt_date    IN  DATE,
                           p_currency_code   IN  VARCHAR2,
                           p_state           IN VARCHAR2,
                           p_called_from     IN VARCHAR2,
                           p_return_status   OUT NOCOPY VARCHAR2) IS
 l_temp BINARY_INTEGER;
 l_dummy_method  Receipt_Method_Rec;
 l_record_exists_in_cache  VARCHAR2(2);
 receipt_md_null EXCEPTION;
 remittance_bank_valid  EXCEPTION;
 remittance_bank_invalid  EXCEPTION;
 remittance_bank_null EXCEPTION;
 receipt_method_invalid   EXCEPTION;
BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_amount: ' || 'Validate_Receipt_Method()+');
       END IF;

       p_return_status := FND_API.G_RET_STS_SUCCESS;

       l_temp := Method_Info_Cache_Tbl.LAST;
         IF l_temp IS NULL THEN
              --The cache is empty : populate it directly.
              l_record_exists_in_cache := 'N';

         ELSE
            --The records exist in the cache, compare them with the current record
              l_record_exists_in_cache := 'N';
            FOR l_counter IN 1..l_temp  LOOP
             IF Method_Info_Cache_Tbl(l_counter).method_id = p_receipt_method_id AND
                Method_Info_Cache_Tbl(l_counter).bank_account_id = p_remittance_bank_account_id
               THEN
                --current record exists in the cache, exit out NOCOPY of the loop
                l_record_exists_in_cache := 'Y';
                EXIT;
             END IF;
            END LOOP;
         END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate_amount: ' || 'l_record_exists_in_cache = '||l_record_exists_in_cache);
            END IF;
          IF l_record_exists_in_cache = 'N'  THEN

            --validate the existing record against the database

              /*--------------------------------+
               |                                |
               |   Validate Receipt_method      |
               |    and Remit bank_account_id   |
               +--------------------------------*/
             IF p_receipt_method_id IS NOT NULL
              THEN

              --if the creation_status that was derived at the defaulting phase ,
              -- for this receipt method , is null then the receipt method id is invalid
                IF p_state IS NULL THEN
                    raise receipt_method_invalid;
                ELSE
                --this is for the case where user had entered the receipt_method
                --and the remittance bank id, and only the p_state was defaulted by
                --the defaulting routines.
                --As per the defaulting routines if remittance bank account id remains
                --null(can't be defaulted) then p_state shall also be null.
                --
                --We validate the receipt method and the remittance bank account id
                --seperately to get the relevant error message:
                /*Bug9081614*/
                  BEGIN
                   SELECT rm.receipt_method_id,
                          ba.bank_acct_use_id,
                          rc.creation_method_code,
                          rc.remit_flag
                   INTO  l_dummy_method.method_id,
                         l_dummy_method.bank_account_id,
                         l_dummy_method.state,
                         l_dummy_method.remit_flag
                   FROM  ar_receipt_methods rm,
                         ce_bank_accounts cba,
                         ce_bank_acct_uses_ou ba,
                         ar_receipt_method_accounts rma,
                         ar_receipt_classes rc
                   WHERE rm.receipt_method_id = p_receipt_method_id
                     and (p_receipt_date between rm.start_date and nvl(rm.end_date, p_receipt_date))
                     and  ((rc.creation_method_code = DECODE(p_called_from,'BR_REMITTED','BR_REMIT',
                                                             'BR_FACTORED_WITH_RECOURSE','BR_REMIT',
                                                             'BR_FACTORED_WITHOUT_RECOURSE','BR_REMIT','@*%?&')) or
                           (rc.creation_method_code = 'MANUAL') or
                           (rc.creation_method_code = 'NETTING') or
                            (rc.creation_method_code = 'AUTOMATIC' and
                             -- rc.remit_flag = 'Y' and
                             -- OSTEINME 2/27/2001: removed remit_flag
                             -- condition for iReceivables CC functionality.
			     -- See bug 1659109.
                              rc.confirm_flag = decode(p_called_from, 'AUTORECAPI',rc.confirm_flag,'N')))
                     and cba.account_classification = 'INTERNAL'
                     and nvl(ba.end_date, p_receipt_date +1) > p_receipt_date
                     and p_receipt_date between rma.start_date and
                                nvl(rma.end_date, p_receipt_date)
                     and cba.currency_code = decode(cba.receipt_multi_currency_flag, 'Y',
                                   cba.currency_code, p_currency_code)
                     and rc.receipt_class_id = rm.receipt_class_id
                     and rm.receipt_method_id = rma.receipt_method_id
                     and rma.remit_bank_acct_use_id = ba.bank_acct_use_id
                     and ba.bank_account_id = cba.bank_account_id
                   --APANDIT: changes made for the misc receipt creation api.
                     and  ((nvl(p_called_from,'*&#$') <> 'MISC')
                              or
                               (rm.receipt_class_id not in (
                                             SELECT arc.receipt_class_id
                                             FROM   ar_receipt_classes arc
                                             WHERE  arc.notes_receivable='Y'
                                                or  arc.bill_of_exchange_flag='Y')));

                     --this above PL/SQL block will get successfully executed only in the case when
                     --receipt method has only one valid remittance bank account and in this case
                     --we can directly compare the remittance bank account id with the value obtained
                     --from the above query and if it is not same then the remittance bank account id
                     --is invalid

                   IF p_remittance_bank_account_id IS NOT NULL THEN
                     IF l_dummy_method.bank_account_id = p_remittance_bank_account_id THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           arp_util.debug('Validate_amount: ' || 'Remittance bank account id is valid ');
                        END IF;

            			--Cache the valid record [Bug 6454022]
            			IF (p_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            			   l_temp := nvl(l_temp,0) + 1;
            			   Method_Info_Cache_Tbl(l_temp) := l_dummy_method;
            			END IF;

                        raise remittance_bank_valid;
                     ELSE
                       raise remittance_bank_invalid;
                     END IF;
                     --if the remittance bank account id is null then whatever has defaulted into
                     --l_dummy_method.bank_account_id is valid is the above validation sql
                     --got executed sucessfully
                   END IF;
                  EXCEPTION
                   WHEN too_many_rows THEN
                    --the receipt method is valid but has more than one remittance bank account
                    --If the remittance bank account id is null at this stage that means that neither the
                    --user had not entered one and nor could it be defaulted
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Validate_amount: ' || 'Too_many_rows raised');
                      END IF;
                      null;
                   WHEN no_data_found THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                       arp_util.debug('Validate_amount: ' || 'no_data_found_raised');
                    END IF;
                    raise receipt_method_invalid;
                    --raising the exception here so that the next block which validates the
                    --remittance bank_id does not executed and the exception in trapped in the
                    --exception handler of the outer block.
                  END;
                END IF; --p_state is null
              ELSE
                    raise receipt_md_null;
              END IF; --p_method_id is null

              --this code would get executed only in case of the too_many_rows exception
              --being raised in the previous block
              IF p_remittance_bank_account_id IS NULL THEN
                 raise remittance_bank_null;
              ELSE
                /*Bug9081614*/
                  BEGIN
                   SELECT rm.receipt_method_id,
                          ba.bank_acct_use_id,
                          rc.creation_method_code,
                          rc.remit_flag
                   INTO  l_dummy_method.method_id,
                         l_dummy_method.bank_account_id,
                         l_dummy_method.state,
                         l_dummy_method.remit_flag
                   FROM  ar_receipt_methods rm,
                         ce_bank_accounts cba,
                         ce_bank_acct_uses_ou ba,
                         ar_receipt_method_accounts rma,
                         ar_receipt_classes rc
                   WHERE rm.receipt_method_id = p_receipt_method_id
                     and rma.remit_bank_acct_use_id = p_remittance_bank_account_id
                     and (p_receipt_date between rm.start_date and nvl(rm.end_date, p_receipt_date))
                     and  ((rc.creation_method_code = DECODE(p_called_from,'BR_REMITTED','BR_REMIT',
                                                             'BR_FACTORED_WITH_RECOURSE','BR_REMIT',
                                                             'BR_FACTORED_WITHOUT_RECOURSE','BR_REMIT','@*%?&')) or
                           (rc.creation_method_code = 'MANUAL') or
                           (rc.creation_method_code = 'NETTING') or
                            (rc.creation_method_code = 'AUTOMATIC' and
                             -- rc.remit_flag = 'Y' and
                             -- OSTEINME 2/27/2001: removed remit_flag
                             -- condition for iReceivables CC functionality.
			     -- See bug 1659109.
                             -- bichatte autorecapi.
                               rc.confirm_flag = decode(p_called_from, 'AUTORECAPI',rc.confirm_flag,'N')))
                     and cba.account_classification = 'INTERNAL'
                     and nvl(ba.end_date, p_receipt_date +1) > p_receipt_date
                     and p_receipt_date between rma.start_date and
                                nvl(rma.end_date, p_receipt_date)
                     and cba.currency_code = decode(cba.receipt_multi_currency_flag, 'Y',
                                   cba.currency_code, p_currency_code)
                     and rc.receipt_class_id = rm.receipt_class_id
                     and rm.receipt_method_id = rma.receipt_method_id
                     and rma.remit_bank_acct_use_id = ba.bank_acct_use_id
                     and ba.bank_account_id = cba.bank_account_id
                   --APANDIT: changes made for the misc receipt creation api.
                     and  ((nvl(p_called_from,'*&#$') <> 'MISC')
                           or
                              (rm.receipt_class_id not in (
                                       SELECT arc.receipt_class_id
                                       FROM   ar_receipt_classes arc
                                       WHERE  arc.notes_receivable='Y'
                                          OR  arc.bill_of_exchange_flag='Y')));

                  EXCEPTION
                   WHEN no_data_found THEN
                    raise remittance_bank_invalid;
                  END;
             END IF;

             IF (p_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_temp := nvl(l_temp,0) + 1;
               Method_Info_Cache_Tbl(l_temp) := l_dummy_method;
             END IF;

          END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Validate_Receipt_Method ()-');
  END IF;
EXCEPTION
WHEN receipt_method_invalid THEN
 IF ar_receipt_api_pub.Original_create_cash_info.receipt_method_id IS NOT NULL THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_ID_INVALID');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Invalid receipt method id ');
  END IF;
 ELSIF ar_receipt_api_pub.Original_create_cash_info.receipt_method_name IS NOT NULL THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCT_MD_NAME_INVALID');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Invalid receipt method name ');
  END IF;
 END IF;

WHEN remittance_bank_valid THEN
  null;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Exception: remittance_bank_valid ');
  END IF;

WHEN remittance_bank_invalid THEN
 IF ar_receipt_api_pub.Original_create_cash_info.remit_bank_acct_use_id IS NOT NULL THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_ID_INVALID');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Invalid remittance bank account id');
  END IF;
 ELSIF ar_receipt_api_pub.Original_create_cash_info.remittance_bank_account_num IS NOT NULL THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NUM_INVALID');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Invalid remittance bank account number');
  END IF;
 ELSIF ar_receipt_api_pub.Original_create_cash_info.remittance_bank_account_name IS NOT NULL THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NAME_INVALID');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Invalid remittance bank account name');
  END IF;
 END IF;

WHEN remittance_bank_null THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_ID_NULL');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'The remittance bank account could not be defaulted ');
  END IF;
WHEN receipt_md_null  THEN
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_ID_NULL');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'The receipt method id is null ');
  END IF;
WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'EXCEPTION: Validate_Receipt_Method_() ');
                        arp_util.debug('Validate_amount: ' || 'p_receipt_method_id  =  '
                               ||TO_CHAR(p_receipt_method_id));
                        arp_util.debug('Validate_amount: ' || 'p_remittance_bank_account_id = '
                               ||TO_CHAR(p_remittance_bank_account_id));
                     END IF;
                     RAISE;
END Validate_Receipt_Method;

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
        --raise error message, because for rate_type 'User' the rate should be specified.
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
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'EXCEPTION: Validate_Exchange_Rate() ');
     arp_util.debug('Validate_amount: ' || 'p_exchange_rate_type  =  '
                 ||p_exchange_rate_type);
  END IF;
  RAISE;
END Validate_Exchange_Rate;

FUNCTION Is_currency_valid(p_currency_code IN
                            ar_cash_receipts.currency_code%TYPE) RETURN VARCHAR2 IS
l_currency_valid VARCHAR2(1);
BEGIN
   SELECT 'Y'
   INTO   l_currency_valid
   FROM   fnd_currencies
   WHERE  p_currency_code = currency_code;

   RETURN(l_currency_valid);
EXCEPTION
WHEN no_data_found THEN
 l_currency_valid := 'N';
 RETURN(l_currency_valid);
WHEN others THEN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Validate_amount: ' || 'EXCEPTION: Validate_Exchange_Rate() ');
    arp_util.debug('Validate_amount: ' || 'p_currency_code  =  '||p_currency_code);
 END IF;
 raise;
END Is_currency_valid;

PROCEDURE Validate_Currency(
                    p_currency_code IN ar_cash_receipts.currency_code%TYPE,
                    p_exchange_rate_type IN ar_cash_receipts.exchange_rate_type%TYPE,
                    p_exchange_rate IN ar_cash_receipts.exchange_rate%TYPE,
                    p_exchange_rate_date IN ar_cash_receipts.exchange_date%TYPE,
                    p_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;
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
END Validate_Currency;

PROCEDURE val_duplicate_receipt(p_receipt_number IN VARCHAR2,
                        p_receipt_date   IN DATE,
                        p_amount         IN NUMBER,
                        p_type           IN VARCHAR2,
                        p_customer_id    IN NUMBER,
                        p_return_status  OUT NOCOPY VARCHAR2) IS
l_duplicate_receipt     varchar2(1) := 'N';
CURSOR validate_duplicate_receipt IS
      SELECT 'Y'
      FROM   ar_cash_receipts cr
      WHERE  cr.receipt_number                 = p_receipt_number
      AND    cr.receipt_date                   = p_receipt_date
      AND    cr.amount                         = p_amount
      AND    NVL(cr.pay_from_customer, -99999) = NVL(p_customer_id, -99999)
      AND    cr.type                           = p_type
      AND    cr.status                         NOT IN (
    		SELECT  arl.lookup_code FROM ar_lookups arl
    		WHERE   arl.lookup_type  = 'REVERSAL_CATEGORY_TYPE');

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Validate_amount: ' || 'val_duplicate_receipt ()+');
 END IF;
    BEGIN

      OPEN  validate_duplicate_receipt;
      FETCH validate_duplicate_receipt INTO l_duplicate_receipt;
      CLOSE validate_duplicate_receipt;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
      WHEN TOO_MANY_ROWS THEN
        l_duplicate_receipt := 'Y';
    END;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount: ' || 'l_duplicate_receipt  :'||l_duplicate_receipt);
   END IF;
   -- Do not allow to create duplicate receipts
    IF l_duplicate_receipt = 'Y' THEN
       IF p_type = 'CASH' THEN
          FND_MESSAGE.SET_NAME('AR','AR_RW_CASH_DUPLICATE_RECEIPT');
          FND_MSG_PUB.ADD;
          p_return_status := FND_API.G_RET_STS_ERROR;
       ELSIF p_type = 'MISC' THEN
          FND_MESSAGE.SET_NAME('AR','AR_RW_MISC_DUPLICATE_RECEIPT');
          FND_MSG_PUB.ADD;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount: ' || 'val_duplicate_receipt ()-');
   END IF;
END val_duplicate_receipt;

PROCEDURE Validate_Cash_Receipt(
                 p_receipt_number  IN ar_cash_receipts.receipt_number%TYPE,
                 p_receipt_method_id IN ar_cash_receipts.receipt_method_id%TYPE,
                 p_state         IN ar_receipt_classes.creation_status%TYPE,
                 p_receipt_date  IN ar_cash_receipts.receipt_date%TYPE,
                 p_gl_date       IN ar_cash_receipt_history.gl_date%TYPE,
                 p_maturity_date IN DATE,
                 p_deposit_date  IN ar_cash_receipts.deposit_date%TYPE,
                 p_amount        IN OUT NOCOPY ar_cash_receipts.amount%TYPE,
                 p_factor_discount_amount   IN ar_cash_receipts.factor_discount_amount%TYPE,
                 p_customer_id              IN ar_cash_receipts.pay_from_customer%TYPE,
                 /* 6612301 */
                 p_customer_bank_account_id IN OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE,
                 p_location                 IN hz_cust_site_uses.location%TYPE,
                 p_customer_site_use_id     IN OUT NOCOPY ar_cash_receipts.customer_site_use_id%TYPE,
                 p_remittance_bank_account_id   IN ar_cash_receipts.remit_bank_acct_use_id%TYPE,
                 p_override_remit_account_flag  IN ar_cash_receipts.override_remit_account_flag%TYPE,
                 p_anticipated_clearing_date    IN ar_cash_receipts.anticipated_clearing_date%TYPE,
                 p_currency_code            IN ar_cash_receipts.currency_code%TYPE,
                 p_exchange_rate_type       IN ar_cash_receipts.exchange_rate_type%TYPE,
                 p_exchange_rate            IN ar_cash_receipts.exchange_rate%TYPE,
                 p_exchange_rate_date       IN ar_cash_receipts.exchange_date%TYPE,
                 p_doc_sequence_value       IN NUMBER,
                 p_called_from              IN VARCHAR2,
                 p_return_status            OUT NOCOPY VARCHAR2)
IS
l_receipt_date_return_status  VARCHAR2(1);
l_gl_date_return_status  VARCHAR2(1);
l_deposit_date_return_status  VARCHAR2(1);
l_maturity_date_return_status  VARCHAR2(1);
l_rcpt_md_return_status   VARCHAR2(1);
l_amount_return_status   VARCHAR2(1);
l_customer_return_status  VARCHAR2(1);
l_override_remit_return_status  VARCHAR2(1);
l_currency_return_status VARCHAR2(1);
l_doc_seq_return_status  VARCHAR2(1);
l_dup_return_status      VARCHAR2(1);
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_amount: ' || 'Validate_Receipt()+ ');
	END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;

    --Validate receipt_date

      Validate_Receipt_Date(p_receipt_date,
                            l_receipt_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_receipt_date_return_status : '||l_receipt_date_return_status);
      END IF;

    --Validate gl_date

      Validate_Gl_Date(p_gl_date,
                       l_gl_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_gl_date_return_status : '||l_gl_date_return_status);
      END IF;
    --Validate deposit_date

      Validate_Deposit_Date(p_deposit_date,
                            l_deposit_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_deposit_date_return_status : '||l_deposit_date_return_status);
      END IF;

    --Validate maturity_date

      Validate_Maturity_Date(p_maturity_date,
                             p_receipt_date,
                             l_maturity_date_return_status);
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_amount: ' || 'l_maturity_date_return_status : '||l_maturity_date_return_status);
       END IF;


    --Validate Receipt_method
      Validate_Receipt_Method(p_receipt_method_id,
                              p_remittance_bank_account_id,
                              p_receipt_date,
                              p_currency_code,
                              p_state,
                              p_called_from,
                              l_rcpt_md_return_status);
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_amount: ' || 'l_rcpt_md_return_status : '||l_rcpt_md_return_status);
       END IF;

   --Validate document sequence value

      IF(NVL(ar_receipt_lib_pvt.pg_profile_doc_seq, 'N') = 'N' )  AND
          p_doc_sequence_value IS NOT NULL
        THEN
             l_doc_seq_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_VAL_INVALID');
             FND_MSG_PUB.Add;
       END IF;
   --Validate amount
      Validate_amount(p_amount ,
                      p_factor_discount_amount,
                      p_state,
                      'CASH',
                      l_amount_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_amount_return_status : '||l_amount_return_status);
      END IF;

    --Validate Customer info

      Validate_Customer(p_customer_id,
                        /* 6612301 */
                        p_customer_bank_account_id,
                        p_location,
                        p_customer_site_use_id,
                        p_currency_code,
                        p_receipt_date,
                        l_customer_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_customer_return_status : '||l_customer_return_status);
      END IF;

    --Validate the override_remit_bank_account_flag
      IF (p_override_remit_account_flag NOT IN ('Y','N')) THEN
       FND_MESSAGE.SET_NAME('AR','AR_OVERR_REM_BK_FLAG_INVALID');
       FND_MSG_PUB.ADD;
       l_override_remit_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
       l_override_remit_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount: ' || 'l_override_remit_return_status : '||l_override_remit_return_status);
      END IF;

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
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount: ' || 'l_currency_return_status : '||l_currency_return_status);
     END IF;

     IF p_receipt_number IS NOT NULL AND
        p_amount IS NOT NULL THEN
        val_duplicate_receipt(p_receipt_number ,
                              p_receipt_date   ,
                              p_amount         ,
                              'CASH'           ,
                              p_customer_id    ,
                              l_dup_return_status );
     END IF;

     IF (l_receipt_date_return_status =  FND_API.G_RET_STS_ERROR) OR
        (l_gl_date_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_deposit_date_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_maturity_date_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_rcpt_md_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_amount_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_customer_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_override_remit_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_currency_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_doc_seq_return_status = FND_API.G_RET_STS_ERROR) OR
        (l_dup_return_status = FND_API.G_RET_STS_ERROR)
       THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_amount: ' || 'Validate_Cash_Receipt Return status :'||p_return_status);
    END IF;

EXCEPTION
 WHEN others THEN
  raise;

END Validate_Cash_Receipt;


PROCEDURE Validate_amount_applied(
                      p_amount_applied              IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id        IN NUMBER,
                      p_inv_line_amount             IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag  IN VARCHAR2,
                      p_natural_appln_only_flag IN VARCHAR2,
                      p_discount                    IN NUMBER,
                      p_amount_due_remaining        IN NUMBER,
                      p_amount_due_original         IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                       ) IS
l_message_name    VARCHAR2(50);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_amount_applied IS NULL
    THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APPLIED_AMT_NULL');
     FND_MSG_PUB.Add;
     return;
  /* The amount Applied can be greater than the line amount. The line level application
     is not supported yet: Bug 3476306 */
  /*ELSE
    IF (p_customer_trx_line_id IS NOT NULL) AND
       (nvl(p_inv_line_amount,0)  < p_amount_applied)
     --in case of line_number being not null and
     --inv_line_amount being null error message
     --would have been raised in the validate_line_number
      THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('AR','AR_RW_APPLIED_GREATER_LINE');
       FND_MESSAGE.SET_TOKEN('AMOUNT',p_inv_line_amount);
       FND_MSG_PUB.Add;
    END IF; */
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Before calling the check_natural_application routine ');
  END IF;
  IF p_applied_payment_schedule_id > 0 THEN

        arp_non_db_pkg.check_natural_application(
            p_creation_sign             => p_creation_sign
          , p_allow_overapplication_flag=> p_allow_overappln_flag
          , p_natural_app_only_flag     => p_natural_appln_only_flag
          , p_sign_of_ps                => '-'
          , p_chk_overapp_if_zero       => 'N'
          , p_payment_amount            => p_amount_applied
          , p_discount_taken            => p_discount
          , p_amount_due_remaining      => p_amount_due_remaining
          , p_amount_due_original       => p_amount_due_original
          , event                       => 'WHEN-VALIDATE-ITEM'
          , p_message_name              => l_message_name);

    IF ( l_message_name IS NOT NULL)
     THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR',l_message_name);
         FND_MSG_PUB.Add;
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount_applied ()-');
  END IF;
END Validate_amount_applied;

--- LLCA
PROCEDURE Validate_line_applied(
                      p_line_amount                 IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id        IN NUMBER,
                      p_inv_line_amount             IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag	    IN VARCHAR2,
                      p_natural_appln_only_flag     IN VARCHAR2,
		      p_llca_type		    IN VARCHAR2,
                      p_discount                    IN NUMBER,
                      p_line_items_remaining        IN NUMBER,
                      p_line_items_original         IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                       ) IS
l_line_message_name    VARCHAR2(50);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_line_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_line_amount IS NULL THEN
     return;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Before calling the check_natural_application routine ');
  END IF;

  IF p_applied_payment_schedule_id > 0 THEN

        arp_non_db_pkg.check_natural_application(
            p_creation_sign             => p_creation_sign
          , p_allow_overapplication_flag=> p_allow_overappln_flag
          , p_natural_app_only_flag     => p_natural_appln_only_flag
          , p_sign_of_ps                => '-'
          , p_chk_overapp_if_zero       => 'N'
          , p_payment_amount            => p_line_amount
          , p_discount_taken            => p_discount
          , p_amount_due_remaining      => p_line_items_remaining
          , p_amount_due_original       => p_line_items_original
          , event                       => 'WHEN-VALIDATE-ITEM'
          , p_message_name              => l_line_message_name);

    IF ( l_line_message_name IS NOT NULL)
     THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR',l_line_message_name);
         FND_MSG_PUB.Add;
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_line_applied ()-');
  END IF;
END Validate_line_applied;
--- LLCA
PROCEDURE Validate_tax_applied(
                      p_tax_amount                  IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag	    IN VARCHAR2,
                      p_natural_appln_only_flag     IN VARCHAR2,
		      p_llca_type		    IN VARCHAR2,
                      p_discount                    IN NUMBER,
                      p_tax_remaining		    IN NUMBER,
                      p_tax_original		    IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                       ) IS
l_tax_message_name    VARCHAR2(50);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_tax_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_amount IS NULL THEN
     return;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Before calling the check_natural_application routine ');
  END IF;

  IF p_applied_payment_schedule_id > 0 THEN

        arp_non_db_pkg.check_natural_application(
            p_creation_sign             => p_creation_sign
          , p_allow_overapplication_flag=> p_allow_overappln_flag
          , p_natural_app_only_flag     => p_natural_appln_only_flag
          , p_sign_of_ps                => '-'
          , p_chk_overapp_if_zero       => 'N'
          , p_payment_amount            => p_tax_amount
          , p_discount_taken            => p_discount
          , p_amount_due_remaining      => p_tax_remaining
          , p_amount_due_original       => p_tax_original
          , event                       => 'WHEN-VALIDATE-ITEM'
          , p_message_name              => l_tax_message_name);

    IF ( l_tax_message_name IS NOT NULL)
     THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR',l_tax_message_name);
         FND_MSG_PUB.Add;
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_tax_applied ()-');
  END IF;
END Validate_tax_applied;

--- LLCA
PROCEDURE Validate_freight_applied(
                      p_freight_amount              IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id        IN NUMBER,
                      p_inv_line_amount             IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag	    IN VARCHAR2,
                      p_natural_appln_only_flag     IN VARCHAR2,
		      p_llca_type		    IN VARCHAR2,
                      p_discount                    IN NUMBER,
                      p_freight_remaining	    IN NUMBER,
                      p_freight_original	    IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                       ) IS
l_frt_message_name    VARCHAR2(50);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_freight_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_freight_amount IS NULL THEN
     return;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Before calling the check_natural_application routine ');
  END IF;

  IF p_applied_payment_schedule_id > 0 THEN

        arp_non_db_pkg.check_natural_application(
            p_creation_sign             => p_creation_sign
          , p_allow_overapplication_flag=> p_allow_overappln_flag
          , p_natural_app_only_flag     => p_natural_appln_only_flag
          , p_sign_of_ps                => '-'
          , p_chk_overapp_if_zero       => 'N'
          , p_payment_amount            => p_freight_amount
          , p_discount_taken            => p_discount
          , p_amount_due_remaining      => p_freight_remaining
          , p_amount_due_original       => p_freight_original
          , event                       => 'WHEN-VALIDATE-ITEM'
          , p_message_name              => l_frt_message_name);

    IF ( l_frt_message_name IS NOT NULL)
     THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR',l_frt_message_name);
         FND_MSG_PUB.Add;
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_freight_applied ()-');
  END IF;
END Validate_freight_applied;


--- LLCA
PROCEDURE Validate_charges_applied(
                      p_charges_amount              IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id        IN NUMBER,
                      p_inv_line_amount             IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag	    IN VARCHAR2,
                      p_natural_appln_only_flag     IN VARCHAR2,
      		      p_llca_type		    IN VARCHAR2,
                      p_discount                    IN NUMBER,
		      p_rec_charges_remaining 	    IN NUMBER,
                      p_rec_charges_charged	    IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                       ) IS
l_message_name    VARCHAR2(50);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_charges_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_charges_amount IS NULL THEN
     return;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount: ' || 'Before calling the check_natural_application routine ');
  END IF;

  IF p_applied_payment_schedule_id > 0 THEN

        arp_non_db_pkg.check_natural_application(
            p_creation_sign             => p_creation_sign
          , p_allow_overapplication_flag=> p_allow_overappln_flag
          , p_natural_app_only_flag     => p_natural_appln_only_flag
          , p_sign_of_ps                => '-'
          , p_chk_overapp_if_zero       => 'N'
          , p_payment_amount            => p_charges_amount
          , p_discount_taken            => p_discount
          , p_amount_due_remaining      => p_rec_charges_remaining
          , p_amount_due_original       => p_rec_charges_charged
          , event                       => 'WHEN-VALIDATE-ITEM'
          , p_message_name              => l_message_name);

    IF ( l_message_name IS NOT NULL)
     THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR',l_message_name);
         FND_MSG_PUB.Add;
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_charges_applied ()-');
  END IF;
END Validate_charges_applied;

PROCEDURE Validate_amount_applied_from(
                           p_amount_applied_from  IN NUMBER,
                           p_amount_applied   IN NUMBER,
                           p_cr_unapp_amount IN NUMBER,
                           p_cr_currency_code IN VARCHAR2,
                           p_trx_currency_code IN VARCHAR2,
                           p_return_status OUT NOCOPY VARCHAR2
                                      ) IS
l_remaining_unapp_rct_amt NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_amount_applied_from ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Bugfix 2634721. Modified the NVL clause */
    l_remaining_unapp_rct_amt := p_cr_unapp_amount - nvl(p_amount_applied_from, p_amount_applied);

    IF l_remaining_unapp_rct_amt < 0 THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount: ' || 'l_remaining_unapp_rct_amt :'||to_char(l_remaining_unapp_rct_amt));
     END IF;
       p_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('AR','AR_RW_APP_NEG_UNAPP');
       FND_MSG_PUB.Add;
    END IF;

    IF p_cr_currency_code = p_trx_currency_code AND
       p_amount_applied_from IS NOT NULL
     THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_AMT_APP_FROM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount_applied_from ()-');
     END IF;
END  Validate_amount_applied_from;

/* Added this over loaded procedure for bug 3119391 */
PROCEDURE Validate_amount_applied_from(
                               p_receivable_application_id IN NUMBER,
			       p_cr_unapp_amount IN NUMBER,
                               p_return_status OUT NOCOPY VARCHAR2
			       ) IS
l_amount_applied NUMBER;
l_amount_applied_from NUMBER;
l_remaining_unapp_rct_amt NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_amount_applied_from over loaded()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT amount_applied,
           amount_applied_from INTO l_amount_applied,l_amount_applied_from
    FROM  ar_receivable_applications
    WHERE receivable_application_id = p_receivable_application_id;

    l_remaining_unapp_rct_amt := p_cr_unapp_amount + nvl(l_amount_applied_from, l_amount_applied);

    IF l_remaining_unapp_rct_amt < 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount_applied_from: ' || 'l_remaining_unapp_rct_amt :'||to_char(l_remaining_unapp_rct_amt));
      END IF;
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR','AR_RW_AMOUNT_LESS_THAN_APP');
      FND_MSG_PUB.Add;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount_applied_from over loaded()-');
    END IF;
END  Validate_amount_applied_from;

PROCEDURE Validate_trans_to_receipt_rate(
                           p_trans_to_receipt_rate IN NUMBER,
                           p_cr_currency_code IN VARCHAR2,
                           p_trx_currency_code IN VARCHAR2,
                           p_amount_applied IN NUMBER,
                           p_amount_applied_from IN NUMBER,
                           p_return_status OUT NOCOPY VARCHAR2
                           ) IS
l_amount_applied_cr  NUMBER; --amount_applied in receipt currency
l_amount_applied_from  NUMBER;
l_amount_applied   NUMBER;
BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_trans_to_receipt_rate ()+');
     END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
  --Validate the trans_to_receipt_rate
   IF p_trx_currency_code = p_cr_currency_code  AND
      p_trans_to_receipt_rate IS NOT NULL
    THEN
     --raise error because this is not a cross-currency application
     --and the user should not have specified a value for trans_to_receipt_rate

       p_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CC_RATE_INVALID');
       FND_MSG_PUB.Add;
   ELSIF p_trx_currency_code <> p_cr_currency_code THEN
      IF p_trans_to_receipt_rate IS NULL THEN

         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CC_RATE_NULL');
         FND_MSG_PUB.Add;
      ELSIF p_trans_to_receipt_rate < 0 THEN

         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR','AR_RW_CC_RATE_POSITIVE');
         FND_MSG_PUB.Add;

      ELSE

      --Validate the trans_to_receipt_rate with reference to
      --amount_applied_from and amount_applied as we should
      --always maintain the following relationship between the
      --three :
      --amount_applied * trans_to_receipt_rate
      --                       = amount_applied_from.
      --this is to be done only if the user had passed in the values
      --for both amount_applied_from and trans_to_receipt_rate
       IF p_amount_applied IS NOT NULL AND
          ar_receipt_api_pub.Original_application_info.amount_applied_from IS NOT NULL AND
          ar_receipt_api_pub.Original_application_info.trans_to_receipt_rate IS NOT NULL
        THEN
         l_amount_applied := arp_util.CurrRound(
                                     p_amount_applied,
                                     p_trx_currency_code
                                    );
         l_amount_applied_cr := arp_util.CurrRound(
                                   l_amount_applied*p_trans_to_receipt_rate,
                                   p_cr_currency_code
                                    );
         l_amount_applied_from := arp_util.CurrRound(
                                   p_amount_applied_from,
                                   p_cr_currency_code
                                    );

         IF l_amount_applied_cr <> l_amount_applied_from  THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CC_RATE_AMTS_INVALID');
           FND_MSG_PUB.Add;
         END IF;
       END IF;
   END IF;
  END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_trans_to_receipt_rate ()-');
     END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_trans_to_receipt_rate: ' || 'EXCEPTION: Validate_Exchange_Rate() ');
   END IF;
   raise;
END Validate_trans_to_receipt_rate;

PROCEDURE Validate_discount(p_discount IN NUMBER,
                            p_amount_due_remaining IN NUMBER,
                            p_amount_due_original IN NUMBER,
                            p_amount_applied IN NUMBER,
                            p_partial_discount_flag IN VARCHAR2,
                            p_applied_payment_schedule_id IN NUMBER,
                            p_discount_earned_allowed IN NUMBER,
                            p_discount_max_allowed IN NUMBER,
                            p_trx_currency_code  IN VARCHAR2,
                            p_return_status OUT NOCOPY VARCHAR2
                            ) IS
BEGIN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_discount ()+');
       END IF;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
       -- Do not allow discount for "On Account" applications
       IF (p_discount <> 0
           AND p_applied_payment_schedule_id = -1)
        THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name ('AR','AR_RW_VAL_ONACC_DISC');
          fnd_msg_pub.Add;

       -- Do not negative discounts unless the amount applied is also
       -- negative.
       ELSIF p_amount_applied >= 0 and
             p_discount < 0 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name ('AR','AR_RW_VAL_NEG_DISCNT');
          fnd_msg_pub.Add;
       -- Bug 3527600: Do not allow positive discounts unless the amount
       -- applied is also positive.
       ELSIF p_amount_applied < 0 and
             p_discount > 0 THEN
          fnd_message.set_name ('AR','AR_RW_VAL_POS_DISCNT');
          fnd_msg_pub.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;

       -- If partial payment discounts are not allowed.

       -- OSTEINME 3/9/01: Bug 1680623: partial discount
       -- should be allowed if payment amount + discount equal
       -- original balance (since it's not a partial discount!)
       -- Added p_discount to the 2nd AND clause.
       -- Bug 3527600: Allow for negative discount

       ELSIF p_partial_discount_flag = 'N'
             AND  p_discount <> 0
	    -- AND (p_amount_due_original - (p_amount_applied+p_discount)) > 0
          -- Fixed the inconsistency between UI/Receipt API, Bug # 3072421
             -- Bug 3527600: Allow for negative discount
             -- Bug 3845905: Allow for overapplications
             AND (  (p_amount_applied >= 0 AND
	            (p_amount_due_remaining - (p_amount_applied + p_discount)) > 0)
                  OR (p_amount_applied < 0 AND
	            (p_amount_due_remaining - (p_amount_applied + p_discount)) < 0))
        THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name ('AR','AR_NO_PARTIAL_DISC');
          fnd_msg_pub.Add;

       ELSIF p_discount IS NOT NULL THEN

      --Do not give discounts more than allowed.
           -- Bug 3527600: Allow for negative discount
          IF (ABS(p_discount) > ABS(p_discount_max_allowed))
           THEN
             fnd_message.set_name ('AR','AR_RW_VAL_DISCOUNT');
             fnd_message.set_token ('DISC_AVAILABLE'
               ,TO_CHAR(p_discount_max_allowed,
               fnd_currency.get_format_mask (p_trx_currency_code,30))
               ||' '||p_trx_currency_code);
             fnd_msg_pub.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;

          -- Check for Unearned Discounts.
          -- Bug 3527600: Allow for negative discount
          ELSIF arp_global.sysparam.unearned_discount = 'N'
             AND ABS(p_discount) > ABS(p_discount_earned_allowed)
           THEN
             fnd_message.set_name ('AR','AR_RW_VAL_UNEARNED_DISCOUNT');
             fnd_msg_pub.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_discount ()-');
       END IF;
END Validate_discount;

PROCEDURE Validate_apply_gl_date(p_apply_gl_date IN DATE,
                                 p_trx_gl_date IN DATE,
                                 p_cr_gl_date  IN DATE,
                                 p_return_status OUT NOCOPY VARCHAR2
                                 ) IS
l_bool  BOOLEAN;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_gl_date ()+');
    END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_gl_date IS NOT NULL THEN

       -- Check that the application GL Date is not before the invoice GL Date.
       IF p_apply_gl_date < p_trx_gl_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_VAL_GL_INV_GL');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;

        -- Check that the application GL Date is not before the receipt GL Date.
       END IF;

       IF p_apply_gl_date < p_cr_gl_date  THEN
          FND_MESSAGE.SET_NAME('AR','AR_RW_GL_DATE_BEFORE_REC_GL');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


       -- Check that the Application GL Date is in an open or future GL period.
       IF ( NOT arp_util.is_gl_date_valid( p_apply_gl_date )) THEN
         FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
         FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_apply_gl_date ));
         FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_gl_date ()-');
    END IF;

END Validate_apply_gl_date;

PROCEDURE Validate_apply_date(p_apply_date IN DATE,
                              p_trx_date IN DATE,
                              p_cr_date  IN DATE,
                              p_return_status OUT NOCOPY VARCHAR2
                               ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()+');
    END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_date IS NOT NULL THEN

       -- check that the apply  date is not before the invoice date.
       IF p_apply_date < p_trx_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_APPLY_BEFORE_TRANSACTION');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;

        -- check that the application date is not before the receipt date.
       END IF;

       IF p_apply_date < p_cr_date  THEN
          FND_MESSAGE.SET_NAME('AR','AR_APPLY_BEFORE_RECEIPT');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()-');
    END IF;
END Validate_apply_date;

PROCEDURE Validate_Application_info(
                      p_apply_date                  IN DATE,
                      p_cr_date                     IN DATE,
                      p_trx_date                    IN DATE,
                      p_apply_gl_date               IN DATE,
                      p_trx_gl_date                 IN DATE,
                      p_cr_gl_date                  IN DATE,
                      p_amount_applied              IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id        IN NUMBER,
                      p_inv_line_amount             IN NUMBER,
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overappln_flag  IN VARCHAR2,
                      p_natural_appln_only_flag IN VARCHAR2,
                      p_discount                    IN NUMBER,
                      p_amount_due_remaining        IN NUMBER,
                      p_amount_due_original         IN NUMBER,
                      p_trans_to_receipt_rate       IN NUMBER,
                      p_cr_currency_code            IN VARCHAR2,
                      p_trx_currency_code           IN VARCHAR2,
                      p_amount_applied_from         IN NUMBER,
                      p_cr_unapp_amount             IN NUMBER,
                      p_partial_discount_flag       IN VARCHAR2,
                      p_discount_earned_allowed     IN NUMBER,
                      p_discount_max_allowed        IN NUMBER,
                      p_move_deferred_tax           IN VARCHAR2,
	 	      p_llca_type		    IN VARCHAR2,
 		      p_line_amount		    IN NUMBER,
		      p_tax_amount		    IN NUMBER,
		      p_freight_amount		    IN NUMBER,
		      p_charges_amount		    IN NUMBER,
	              p_line_discount               IN NUMBER,
	              p_tax_discount                IN NUMBER,
	              p_freight_discount            IN NUMBER,
		      p_line_items_original	    IN NUMBER,
		      p_line_items_remaining	    IN NUMBER,
		      p_tax_original		    IN NUMBER,
		      p_tax_remaining		    IN NUMBER,
		      p_freight_original	    IN NUMBER,
		      p_freight_remaining	    IN NUMBER,
		      p_rec_charges_charged	    IN NUMBER,
		      p_rec_charges_remaining	    IN NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                          ) IS
l_gl_date_return_status  VARCHAR2(1);
l_amt_applied_return_status VARCHAR2(1);
l_x_rate_return_status  VARCHAR2(1);
l_disc_return_status  VARCHAR2(1);
l_amt_app_from_return_status VARCHAR2(1);
l_apply_date_return_status   VARCHAR2(1);
--LLCA
l_line_applied_return_status VARCHAR2(1);
l_tax_applied_return_status  VARCHAR2(1);
l_frt_applied_return_status  VARCHAR2(1);
l_chg_applied_return_status  VARCHAR2(1);
BEGIN

   --The customer_trx_id, cash_receipt_id and the applied_payment_schedule_id
   --have already been validated in the defaulting routines.

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Application_info ()+');
    END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
        --validation of the trx_number/customer_trx_id and
        --receipt_number/cash_receipt_id entered by the user
        --is done in the process of defaulting the Trx info and
        --the Receipt Info by the respective defaulting routines

         validate_apply_date(p_apply_date,
                             p_trx_date,
                             p_cr_date,
                             l_apply_date_return_status
                             );

         validate_apply_gl_date(p_apply_gl_date ,
                                 p_trx_gl_date ,
                                 p_cr_gl_date  ,
                                 l_gl_date_return_status
                                 );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Application_info: ' || 'Apply gl_date return
		status :'||l_gl_date_return_status);
   END IF;
        validate_amount_applied(
                      p_amount_applied ,
                      p_applied_payment_schedule_id ,
                      p_customer_trx_line_id ,
                      p_inv_line_amount      ,
                      p_creation_sign        ,
                      p_allow_overappln_flag ,
                      p_natural_appln_only_flag,
                      p_discount       ,
                      p_amount_due_remaining ,
                      p_amount_due_original,
                      l_amt_applied_return_status
                       );
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_Application_info: ' || 'Amount applied return
		status :'||l_amt_applied_return_status);
     END IF;

     If p_llca_type = 'S' THEN
	-- Validate the line/tax/freight/charges amount only if p_llca_type is
	-- not null.
	If nvl(p_line_amount,0) <> 0  THEN
	   validate_line_applied(
	                      p_line_amount ,
	                      p_applied_payment_schedule_id ,
		              p_customer_trx_line_id ,
		  	      p_inv_line_amount      ,
	                      p_creation_sign        ,
		              p_allow_overappln_flag ,
			      p_natural_appln_only_flag,
			      p_llca_type,
			      p_discount       ,
			      p_line_items_remaining ,
			      p_line_items_original,
			      l_line_applied_return_status
			     );
	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Validate_Application_info: ' || 'Line
			Amount applied return status :'||l_line_applied_return_status);
	     END IF;
	End If;

	If nvl(p_tax_amount,0) <> 0 THEN
 	   validate_tax_applied(
	                      p_tax_amount ,
	                      p_applied_payment_schedule_id ,
	                      p_creation_sign        ,
		              p_allow_overappln_flag ,
			      p_natural_appln_only_flag,
			      p_llca_type,
			      p_discount       ,
			      p_tax_remaining ,
			      p_tax_original,
			      l_tax_applied_return_status
			     );
	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Validate_Application_info: ' || 'Tax Amount
		 applied return status :'||l_tax_applied_return_status);
	     END IF;
	END IF;

	IF nvl(p_freight_amount,0) <> 0	THEN
	  validate_Freight_applied(
	                      p_freight_amount ,
	                      p_applied_payment_schedule_id ,
		              p_customer_trx_line_id ,
		  	      p_inv_line_amount      ,
	                      p_creation_sign        ,
		              p_allow_overappln_flag ,
			      p_natural_appln_only_flag,
			      p_llca_type,
			      p_discount ,
			      p_freight_remaining ,
			      p_freight_original,
			      l_frt_applied_return_status
			     );
	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Validate_Application_info: ' || 'Freight Amount
		 applied return status :'||l_frt_applied_return_status);
	     END IF;
	END IF;

	IF nvl(p_charges_amount,0) <> 0 THEN
	  validate_charges_applied(
	                      p_charges_amount ,
	                      p_applied_payment_schedule_id ,
		              p_customer_trx_line_id ,
		  	      p_inv_line_amount      ,
	                      p_creation_sign        ,
		              p_allow_overappln_flag ,
			      p_natural_appln_only_flag,
			      p_llca_type,
			      p_discount       ,
			      p_rec_charges_remaining ,
	--		      p_rec_charges_charged,   Pass original as remaining bcoz
	--		      ar_open_trx_v does not have charges original
			      p_rec_charges_remaining ,
			      l_chg_applied_return_status
			     );
	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Validate_Application_info: ' || 'Charges Amount
			applied return status :'||l_chg_applied_return_status);
	     END IF;
	END IF;
     END IF;

         validate_trans_to_receipt_rate(
                           p_trans_to_receipt_rate ,
                           p_cr_currency_code ,
                           p_trx_currency_code ,
                           p_amount_applied ,
                           p_amount_applied_from ,
                           l_x_rate_return_status
                           );
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_Application_info: ' || 'Trans to receipt rate return status :'||l_x_rate_return_status);
     END IF;
         validate_amount_applied_from(
                           p_amount_applied_from  ,
                           p_amount_applied,
                           p_cr_unapp_amount ,
                           p_cr_currency_code ,
                           p_trx_currency_code ,
                           l_amt_app_from_return_status
                                      );
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_Application_info: ' || 'Amount applied from return_status :'||l_amt_app_from_return_status);
     END IF;

          validate_discount(p_discount    ,
                            p_amount_due_remaining  ,
                            p_amount_due_original  ,
                            p_amount_applied       ,
                            p_partial_discount_flag,
                            p_applied_payment_schedule_id,
                            p_discount_earned_allowed    ,
                            p_discount_max_allowed       ,
                            p_trx_currency_code,
                            l_disc_return_status
                            );

       -- LLCA
/*     If P_llca_type is NOT NULL
       THEN
		IF (( Nvl(p_line_discount,0) + Nvl(p_tax_discount,0)
			+ Nvl(p_freight_discount,0) )
			> Nvl(p_discount_max_allowed,0)
		   )
		THEN
		      FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_LTFC_DISC_OAPP');
		      FND_MSG_PUB.ADD;
		      p_return_status := FND_API.G_RET_STS_ERROR ;
		END IF;
	END IF;   */

       --validate p_move_deferred_tax
       IF p_move_deferred_tax NOT IN ('Y','N') THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_DEF_TAX_FLAG_INVALID');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Application_info: ' || 'Discount return status :'||l_disc_return_status);
      END IF;

    IF l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_amt_applied_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_x_rate_return_status  <> FND_API.G_RET_STS_SUCCESS OR
       l_disc_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_amt_app_from_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_apply_date_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Application_info ()-');
    END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Validate_Application_Info() ');
  END IF;
  raise;
END Validate_Application_info;

PROCEDURE Validate_Rev_gl_date(p_reversal_gl_date IN DATE,
                               p_apply_gl_date  IN DATE,
                               p_receipt_gl_date IN DATE,
                               p_recpt_last_state_gl_date  IN DATE, /* Bug fix 2441105 */
                               p_return_status  OUT NOCOPY VARCHAR2
                               ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Rev_gl_date ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_reversal_gl_date IS NOT NULL THEN

    IF  p_reversal_gl_date < NVL(p_apply_gl_date,p_reversal_gl_date)  THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEFORE_APP_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', p_apply_gl_date);
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF p_reversal_gl_date < nvl(p_receipt_gl_date,p_reversal_gl_date) THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEFORE_RECEIPT_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', p_receipt_gl_date);
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    /* Bug fix 2441105 */
    IF p_reversal_gl_date < nvl(p_recpt_last_state_gl_date,p_reversal_gl_date) THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEF_RCPT_STATE_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', p_recpt_last_state_gl_date);
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF ( NOT arp_util.is_gl_date_valid(p_reversal_gl_date)) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
        FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_reversal_gl_date ));
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  ELSE
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_GL_DATE_NULL');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Rev_gl_date: ' || 'The Reversal gl date is null ');
      END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_Rev_gl_date ()+');
  END IF;
EXCEPTION
  WHEN others THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION: Validate_rev_gl_date() ');
      END IF;
      raise;
END Validate_Rev_gl_date;


/* 8668394: No reversal allowed before application date OR application gl_date */
PROCEDURE  validate_rev_appln_date(p_cash_receipt_id IN NUMBER,
			      p_reversal_gl_date IN DATE,
			      p_reversal_date IN DATE ,
		              p_return_status OUT NOCOPY VARCHAR2
			      ) IS
l_apply_date  date;
l_gl_date     date;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('validate_rev_appln_date ()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    Select max(apply_date) , max(gl_date)
    into   l_apply_date    , l_gl_date
    from   ar_receivable_applications
    where  cash_receipt_id = p_cash_receipt_id;

    IF p_reversal_gl_date < l_gl_date THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEF_RCPT_APP_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', TO_CHAR(l_gl_date));
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_reversal_date < l_apply_date THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEF_RCPT_APP_DATE');
	FND_MESSAGE.SET_TOKEN('APPLY_DATE', TO_CHAR(l_apply_date));
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('validate_rev_appln_date ()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('No application exists for this receipt.');
      END IF;
      null;
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION: validate_rev_appln_date() ' || sqlerrm);
      END IF;
      raise;
END validate_rev_appln_date;


PROCEDURE Validate_receivable_appln_id(
                       p_receivable_application_id  IN  NUMBER,
                       p_application_type  IN VARCHAR2,
                       p_return_status OUT NOCOPY VARCHAR2) IS
l_valid NUMBER;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_receivable_appln_id ()+');
  END IF;
   --validate the receivable application id only if it was passed in
   --directly as a parameter. No need to validate if it was derived.
   IF p_receivable_application_id IS NOT NULL AND
      ar_receipt_api_pub.Original_unapp_info.receivable_application_id IS NOT NULL
     THEN
       SELECT count(*)
       INTO   l_valid
       FROM   AR_RECEIVABLE_APPLICATIONS ra
       WHERE  ra.receivable_application_id = p_receivable_application_id
         and  ra.display = 'Y'
         and  ra.status = p_application_type
         and  ra.application_type = 'CASH';

     IF  l_valid = 0 THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF p_receivable_application_id IS NULL  THEN
    IF ar_receipt_api_pub.Original_unapp_info.trx_number IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.applied_ps_id IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.cash_receipt_id IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.receipt_number  IS NULL
     THEN
     --receivable application id is null
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF ar_receipt_api_pub.Original_unapp_info.trx_number IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NULL AND
       ar_receipt_api_pub.Original_unapp_info.applied_ps_id IS NULL AND
       (ar_receipt_api_pub.Original_unapp_info.cash_receipt_id IS NOT NULL OR
       ar_receipt_api_pub.Original_unapp_info.receipt_number IS NOT NULL)
     THEN
     --the transaction was not specified
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_NULL');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF (ar_receipt_api_pub.Original_unapp_info.trx_number IS NOT NULL OR
       ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NOT NULL OR
       ar_receipt_api_pub.Original_unapp_info.applied_ps_id IS NOT NULL) AND
       ar_receipt_api_pub.Original_unapp_info.cash_receipt_id IS  NULL AND
       ar_receipt_api_pub.Original_unapp_info.receipt_number IS  NULL
    THEN
    --the receipt was not specified
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_receivable_appln_id ()-');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Validate_receivable_appln_id()');
   END IF;
   raise;
END Validate_receivable_appln_id;

/*Added parameter p_cr_unapp_amount for bug 3119391 */
PROCEDURE Validate_unapp_info(
                      p_receipt_gl_date             IN DATE,
                      p_receivable_application_id   IN NUMBER,
                      p_reversal_gl_date            IN DATE,
                      p_apply_gl_date               IN DATE,
		      p_cr_unapp_amount             IN  NUMBER,
                      p_return_status               OUT NOCOPY VARCHAR2
                      ) IS
l_rec_app_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_rev_gl_date_return_status  VARCHAR2(1) ;
l_amt_app_from_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;/*Added for 3119391 */
BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_unapp_info ()+');
   END IF;

       --In case the user has entered the receivable application id
       -- as well as the receipt and transaction info, then the cross validation
       --is done at the defaulting phase itself so no need to do that here.
          Validate_receivable_appln_id(
                                  p_receivable_application_id,
                                  'APP',
                                  l_rec_app_return_status);

          Validate_rev_gl_date( p_reversal_gl_date ,
                                p_apply_gl_date ,
                                p_receipt_gl_date,
                                NULL,
                                l_rev_gl_date_return_status
                                  );
          /*Addded this call for bug 3119391 */
          Validate_amount_applied_from( p_receivable_application_id,
	                                p_cr_unapp_amount,
					l_amt_app_from_return_status);
          /*Added l_amt_app_from_return_status condition for bug 3119391 */
          IF l_rev_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
             l_rec_app_return_status <> FND_API.G_RET_STS_SUCCESS OR
             l_amt_app_from_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               p_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
               p_return_status := FND_API.G_RET_STS_SUCCESS;
          END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_unapp_info: ' || 'Recevable appln id return status '||l_rec_app_return_status);
      arp_util.debug('Validate_unapp_info: ' || 'Rev_gl_date_return_status :'||l_rev_gl_date_return_status);
      arp_util.debug('Validate_unapp_info ()-');
   END IF;
END Validate_unapp_info;

PROCEDURE check_std_reversible(p_cash_receipt_id  IN NUMBER,
                               p_reversal_date    IN DATE,
                               p_receipt_state    IN VARCHAR2,
                               p_called_from      IN VARCHAR2,
                               p_std_reversal_possible  OUT NOCOPY VARCHAR2
                               )  IS
l_dummy NUMBER;
l_reserved   VARCHAR2(1) DEFAULT 'N';
l_std_appln  VARCHAR2(1) DEFAULT 'N';
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('check_std_reversible ()+');
   END IF;
   --Check whether it has not been reversed yet
  IF p_reversal_date IS NULL  OR
     p_receipt_state <> 'APPROVED'  THEN
    --  Check if a 'CB' was created against this PMT to be reversed.
    --  Check if there are any PMT, ADJ, or CM or CB against this 'CB' records
    --  in AR_PAYMENT_SCHEDULES table.  Also check to see if the CB has
    --   already been posted.  If any of these 2 conditions is TRUE, then
    --  PMT can only be reversed using DM Reversal.
    --  Make sure that the adj which is automatically created against the CB
    --  associated with the receipt being reversed does not get caught in
    --  the SQL.  For such an adj, the adj.receivables_trx_id = -12


     SELECT  COUNT(payment_schedule_id)
     INTO    l_dummy
     FROM    ar_payment_schedules    ps,
             ra_cust_trx_line_gl_dist rctlg
     WHERE   ps.associated_cash_receipt_id = p_cash_receipt_id
     AND     ps.class = 'CB'
     AND     ps.customer_trx_id = rctlg.customer_trx_id
     AND (      nvl(ps.amount_applied, 0) <> 0
            OR  nvl(ps.amount_credited, 0) <> 0
            OR 0 <> ( SELECT sum(adj.amount)
                      FROM  ar_adjustments adj
                      WHERE adj.payment_schedule_id =
                             ps.payment_schedule_id
                        AND adj.receivables_trx_id <> -12
                     )
          );

     IF (l_dummy > 0) THEN
       p_std_reversal_possible := 'N';
     ELSE
       p_std_reversal_possible := 'Y';
     END IF;
  ELSE
       p_std_reversal_possible := 'N';
  END IF;


  --added code to check if there is a bill of type 'reserved' is
  --applied to the receipt
  IF p_std_reversal_possible = 'Y' THEN

      --check if there is a SHORT TERM DEBT application on the receipt
    BEGIN
       SELECT 'Y'
       INTO   l_std_appln
       FROM   ar_receivable_applications ra
       WHERE  ra.cash_receipt_id = p_cash_receipt_id
        AND   ra.status = 'ACTIVITY'
        AND   ra.applied_payment_schedule_id = -2
        AND   display = 'Y'
        AND   p_called_from NOT IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE');  --fixed bug 1450460
    EXCEPTION
      WHEN no_data_found THEN
       null;
      WHEN others THEN
       raise;
    END;

      --check the receipt has been applied to a bill for which
      --the reversed_type and the reversed_value columns in the payment_schedule
      --record have not null values(indicating that it is in the br remit process)

   IF p_called_from IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE') THEN
    --called from the BR Remittance program
    null;
   ELSE

      BEGIN
         SELECT 'Y'
         INTO   l_reserved
         FROM   ar_payment_schedules ps,
                ar_receivable_applications ra
         WHERE  ra.cash_receipt_id = p_cash_receipt_id
           AND  ra.applied_payment_schedule_id = ps.payment_schedule_id
           AND  ps.reserved_type IS NOT NULL
           AND  ps.reserved_value IS NOT NULL
           AND  ra.status = 'APP'
           AND  ra.display  = 'Y';
      EXCEPTION
        WHEN no_data_found THEN
         null;
        WHEN others THEN
         raise;
      END;

   END IF;

      IF l_reserved = 'Y' OR
         l_std_appln = 'Y' THEN
        p_std_reversal_possible := 'N';
      END IF;

   END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('check_std_reversible ()-');
END IF;

EXCEPTION
  WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: check_std_reversible()');
    END IF;
    raise;
END check_std_reversible;

PROCEDURE Validate_cash_receipt_id(
                           p_type IN VARCHAR2,
                           p_cash_receipt_id IN NUMBER,
                           p_status1 IN VARCHAR2,
                           p_status2 IN VARCHAR2,
                           p_status3 IN VARCHAR2,
                           p_status4 IN VARCHAR2,
                           p_status5 IN VARCHAR2,
                           p_return_status OUT NOCOPY VARCHAR2) IS
l_valid  NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_cash_receipt_id ()+');
  END IF;
   IF p_cash_receipt_id IS NOT NULL THEN

     SELECT count(*)
     INTO   l_valid
     FROM   ar_cash_receipts cr,
            ar_cash_receipt_history crh
     WHERE  cr.cash_receipt_id = p_cash_receipt_id
       and  cr.cash_receipt_id = crh.cash_receipt_id
       and  crh.current_record_flag = 'Y'
       and  crh.status
                 IN (p_status1,p_status2,p_status3,p_status4,p_status5);

     IF l_valid = 0  THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_cash_receipt_id ()-');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Validate_cash_receipt_id() ');
   END IF;
   raise;
END Validate_cash_receipt_id;

PROCEDURE Validate_reversal_catg_code(
                         p_reversal_category_code IN VARCHAR2,
                         p_return_status  OUT NOCOPY VARCHAR2
                                      ) IS
l_valid  NUMBER;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_reversal_catg_code ()+');
   END IF;
  IF p_reversal_category_code IS NOT NULL  THEN
     SELECT count(*)
     INTO   l_valid
     FROM   ar_lookups
     WHERE  lookup_type = 'REVERSAL_CATEGORY_TYPE'
       and  enabled_flag = 'Y'
       and  lookup_code = p_reversal_category_code;
     IF l_valid =0 THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_CAT_CD_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_CAT_CD_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_reversal_catg_code ()-');
   END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Validate_reversal_catg_code() ');
  END IF;
  raise;
END Validate_reversal_catg_code;

PROCEDURE Validate_reversal_reason_code(
                       p_reversal_reason_code IN VARCHAR2,
                       p_return_status  OUT NOCOPY VARCHAR2
                                 ) IS
l_valid NUMBER;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_reversal_reason_code IS NOT NULL  THEN
     SELECT count(*)
     INTO   l_valid
     FROM   ar_lookups
     WHERE  lookup_type = 'CKAJST_REASON'
       and  enabled_flag = 'Y'
       and  lookup_code = p_reversal_reason_code;
     IF l_valid =0 THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_REAS_CD_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_REAS_CD_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Validate_reversal_reason_code() ');
  END IF;
  raise;
END Validate_reversal_reason_code;

PROCEDURE Validate_reverse_info(
                          p_cash_receipt_id         IN NUMBER,
                          p_receipt_gl_date         IN DATE,
                          p_reversal_category_code  IN VARCHAR2,
                          p_reversal_reason_code    IN VARCHAR2,
                          p_reversal_gl_date        IN DATE,
                          p_reversal_date           IN DATE,
                          p_return_status           OUT NOCOPY VARCHAR2
                          ) IS
l_cr_return_status   VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_rev_cat_return_status VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_rev_res_return_status VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_rev_gld_return_status VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_rev_appln_return_status VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
BEGIN
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_reverse_info ()+');
    END IF;
    Validate_cash_receipt_id('ALL',
                           p_cash_receipt_id,
                           'APPROVED',
                           'CONFIRMED',
                           'CLEARED',
                           'REMITTED',
                           'RISK_ELIMINATED', /* Bug fix 3263841 */
                           l_cr_return_status);

     Validate_reversal_catg_code(p_reversal_category_code,
                                 l_rev_cat_return_status);

     Validate_reversal_reason_code(p_reversal_reason_code,
                                   l_rev_res_return_status
                                   );

     Validate_Rev_gl_date(p_reversal_gl_date,
                          NULL, --apply gl date not valid in this case.
                          NULL,
                          p_receipt_gl_date,
                          l_rev_gld_return_status
                          );

      /* Bug 8668394 */
      validate_rev_appln_date(p_cash_receipt_id,
			      p_reversal_gl_date,
			      p_reversal_date,
			      l_rev_appln_return_status
			      );

      IF l_rev_gld_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_rev_res_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_rev_cat_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_cr_return_status  <> FND_API.G_RET_STS_SUCCESS  OR
	 l_rev_appln_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_reverse_info ()-');
    END IF;
EXCEPTION
  WHEN others  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Validate_reverse_info ()');
    END IF;
    raise;
END  Validate_reverse_info;

PROCEDURE validate_on_ac_app( p_cash_receipt_id IN NUMBER,
                              p_cr_gl_date  IN DATE,
                              p_cr_unapp_amount IN NUMBER,
                              p_cr_date IN DATE,
                              p_cr_payment_schedule_id IN NUMBER,
                              p_applied_amount IN NUMBER,
                              p_apply_gl_date IN DATE,
                              p_apply_date IN DATE,
                              p_return_status OUT NOCOPY VARCHAR2,
                              p_applied_ps_id IN NUMBER,
                              p_called_from IN VARCHAR2
                               ) IS
l_cr_return_status  VARCHAR2(1);
l_amt_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_gl_date_return_status VARCHAR2(1);
l_apply_date_return_status  VARCHAR2(1);
BEGIN
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('validate_on_ac_app ()+');
        END IF;

         validate_cash_receipt_id('ALL',
                                   p_cash_receipt_id,
                                   NULL,
                                   'CONFIRMED',
                                   'CLEARED',
                                   'REMITTED',
                                   'RISK_ELIMINATED', /* Bug fix 3263841 */
                                   l_cr_return_status);

        validate_apply_date(p_apply_date,
                            p_apply_date,
                            p_cr_date,
                            l_apply_date_return_status
                             );

       --  validate amount applied
          IF  p_applied_amount IS NULL  THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_APPLIED_AMT_NULL');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;

          -- Bug 2751910 - allow -ve amount on application to receipt (ps>0)
          ELSIF  (p_applied_amount < 0 AND NVL(p_applied_ps_id,-1) <> -4 AND
                  NVL(p_applied_ps_id,-1) <> -3 AND
                  NVL(p_applied_ps_id,-1) < 0) THEN
              IF p_applied_ps_id = -8 THEN
                 FND_MESSAGE.SET_NAME('AR','AR_REF_CM_APP_NEG');
                 FND_MSG_PUB.Add;
              ELSE
                 FND_MESSAGE.SET_NAME('AR','AR_RW_APP_NEG_ON_ACCT');
                 FND_MSG_PUB.Add;
   	      END IF;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;
          -- Bug 2897244 - amount not checked if called from form/postbatch
          ELSIF ((nvl(p_cr_unapp_amount,0)- p_applied_amount) < 0 AND
                 NVL(p_applied_ps_id,-1) <> -4 AND
                 NVL(p_called_from,'RAPI') NOT IN ('ARXRWAPP','ARCAPB')) THEN
              FND_MESSAGE.SET_NAME('AR','AR_RW_AMOUNT_LESS_THAN_APP');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

               validate_apply_gl_date(p_apply_gl_date,
                                      p_apply_gl_date,
                                      p_cr_gl_date,
                                      l_gl_date_return_status
                                      );

          IF  l_cr_return_status <> FND_API.G_RET_STS_SUCCESS  OR
              l_amt_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_apply_date_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('validate_on_ac_app ()-');
        END IF;
EXCEPTION
WHEN others  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  validate_on_ac_app()');
    END IF;
    raise;
END validate_on_ac_app;


 /*----------------------------------------------------------+
  | validate_unapp_on_ac_act_info routine is called for both |
  | 1) activity_unapplication and                            |
  | 2) on_account_unapplication                              |
  +----------------------------------------------------------*/
PROCEDURE validate_unapp_on_ac_act_info(
                              p_receipt_gl_date  IN DATE,
                              p_receivable_application_id  IN NUMBER,
                              p_reversal_gl_date  IN DATE,
                              p_apply_gl_date    IN DATE,
                              p_cr_unapp_amt     IN NUMBER, /* Bug fix 3569640 */
                              p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_amt_app_from_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;/*Added for 3569640 */
BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('validate_unapp_on_ac_act_info: ' || 'Validate_unapp_on_acc_act_info ()+');
     END IF;


         --the receivable_application_id was validated in the defaulting stage
         --for all cases : 1. only receivable_application_id specified
         --                2. only cash receipt specified
         --                3. both cash receipt and receivable_application_id specified
         -- no need to validate it here

          Validate_rev_gl_date( p_reversal_gl_date ,
                                p_apply_gl_date ,
                                p_receipt_gl_date,
                                NULL,
                                p_return_status
                                  );

         /* Bug fix 3569640 */
         IF p_receivable_application_id IS NOT NULL
           AND p_cr_unapp_amt IS NOT NULL THEN
            Validate_amount_applied_from( p_receivable_application_id,
                                          p_cr_unapp_amt,
                                          l_amt_app_from_return_status);
         END IF;
         IF l_amt_app_from_return_status <> FND_API.G_RET_STS_SUCCESS OR
            p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_unapp_on_ac_act_info: ' || 'p_return_status :'||p_return_status);
       arp_util.debug('validate_unapp_on_ac_act_info: ' || 'Validate_unapp_on_acc_act_info ()-');
    END IF;
END validate_unapp_on_ac_act_info;

PROCEDURE validate_ccrefund(
                            p_cash_receipt_id IN NUMBER,
                            p_applied_ps_id IN NUMBER,
                            p_return_status IN OUT NOCOPY VARCHAR2
                            ) IS
l_payment_type          VARCHAR2(30);

BEGIN

 --If the applied payment schedule_id -7, we can issue the refund only to credit card.

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Validate_ccrefund (+)');
 END IF;
 IF p_applied_ps_id = -6 THEN
    BEGIN
       SELECT NVL(arm.payment_channel_code,'NONE')
       INTO   l_payment_type
       FROM   ar_cash_receipts cr,
              ar_receipt_methods arm
       WHERE  cr.receipt_method_id = arm.receipt_method_id
       AND    cr.cash_receipt_id=p_cash_receipt_id;

       IF l_payment_type <> 'CREDIT_CARD' THEN
            FND_MESSAGE.SET_NAME('AR','AR_RW_CCR_RECEIPT_ONLY');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    EXCEPTION
       WHEN others then
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Validate ccrefund' ||SQLERRM);
            FND_MSG_PUB.Add;
    END;
 END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_ccrefund (-)');
    END IF;
END validate_ccrefund;


--
--Bug 1645041 : Added parameters p_cr_currency_code, p_applied_amount
-- and p_cash_receipt_id which were to be used in approval limit
-- validation logic added in this procedure for the write-off activity.
-- Bug 2270825 - validation for claims
--
PROCEDURE validate_activity(p_receivables_trx_id IN NUMBER,
                            p_applied_ps_id IN NUMBER,
                            p_cash_receipt_id IN NUMBER,
                            p_applied_amount IN NUMBER,
                            p_cr_currency_code IN VARCHAR2,
                            p_val_writeoff_limits_flag IN VARCHAR2,
                            p_return_status IN OUT NOCOPY VARCHAR2
                            ) IS
l_activity_type   VARCHAR2(30);
l_amount_from           NUMBER;
l_amount_to             NUMBER;
l_user_id               NUMBER;
l_existing_wo_amount    NUMBER;
l_tot_write_off_amt     NUMBER;
l_max_wrt_off_amount    NUMBER;
l_min_wrt_off_amount    NUMBER;

--Bug 5367753
l_exchange_rate         NUMBER;
l_tot_writeoff_amt_func NUMBER;
l_functional_currency   ar_cash_receipts.currency_code%TYPE;

cursor activity_type is
 select type
 from   ar_receivables_trx rt
 where  receivables_trx_id = p_receivables_trx_id;

BEGIN

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_activity (+)');
 END IF;

 OPEN activity_type;
 FETCH activity_type INTO l_activity_type;
 IF activity_type%NOTFOUND THEN
   FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_TRX_ID_INVALID');
   FND_MSG_PUB.Add;
   p_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
 CLOSE activity_type;

 IF l_activity_type IS NOT NULL THEN
  --Validate applied ps_id
  --additional conditions need to be added for the ps_id in future
  -- -2 corresponds to short term debit
    IF p_applied_ps_id = -2 THEN
      IF l_activity_type <> 'SHORT_TERM_DEBT' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

  --SNAMBIAR - Modified for Write-Off
    ELSIF p_applied_ps_id = -3 THEN
      IF l_activity_type <> 'WRITEOFF' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      --some additional validation that we need to do for the Write-Off: Bug 1645041.
      -- Bug 2751910 - Validation against user limits excluded if flag set


       l_user_id       := to_number(fnd_profile.value('USER_ID'));

       --get the existing write-off amount on the receipt.

         BEGIN
          SELECT sum(amount_applied)
          INTO l_existing_wo_amount
  	  FROM ar_receivable_applications
  	  WHERE applied_payment_schedule_id = -3
          AND   status = 'ACTIVITY'
          AND   NVL(confirmed_flag,'Y') = 'Y'
          AND   cash_receipt_id = p_cash_receipt_id;

          --Bug 5367753 fetch exchange_rate of the receipt.
          SELECT nvl(exchange_rate,1)
          INTO l_exchange_rate
          FROM ar_cash_receipts
          WHERE cash_receipt_id = p_cash_receipt_id;

          l_tot_write_off_amt := NVL(l_existing_wo_amount,0) + NVL(p_applied_amount,0);

         EXCEPTION
           WHEN no_data_found THEN
             l_tot_write_off_amt := p_applied_amount;
         END;

       IF NVL(p_val_writeoff_limits_flag,'Y') <> 'N' THEN
         BEGIN
          SELECT NVL(amount_from,0),
                 NVL(amount_to,0)
          INTO   l_amount_from,
                 l_amount_to
          FROM   ar_approval_user_limits
          where  currency_code = p_cr_currency_code
          and    user_id = l_user_id
          and    document_type ='WRTOFF';
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           fnd_message.set_name ('AR','AR_WR_NO_LIMIT');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
         END;

         IF (NVL(l_tot_write_off_amt,0) > l_amount_to) OR
            (NVL(l_tot_write_off_amt,l_amount_from) < l_amount_from)
          THEN
           fnd_message.set_name ('AR','AR_WR_USER_LIMIT');
           fnd_message.set_token('FROM_AMOUNT', to_char(l_amount_from), FALSE);
           fnd_message.set_token('TO_AMOUNT', to_char(l_amount_to), FALSE);
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

       END IF;

       -- Bug 2751910 - validate against system limits
       --Bug 5367753 Modified SQL to fetch functional currency code.
       SELECT MAX_WRTOFF_AMOUNT,
              MIN_WRTOFF_AMOUNT,
              sob.currency_code
       INTO   l_max_wrt_off_amount,
              l_min_wrt_off_amount,
              l_functional_currency
       FROM   AR_SYSTEM_PARAMETERS sys,gl_sets_of_books sob
       WHERE  sys.set_of_books_id = sob.set_of_books_id;

       -- Bug 3136127 - if writeoff amount > 0 then max limit must have a value
       -- if < 0, then min limit must have a value < 0
       IF ((l_max_wrt_off_amount IS NULL AND
            NVL(l_tot_write_off_amt,0) > 0 )
         OR
           (l_min_wrt_off_amount IS NULL AND
            NVL(l_tot_write_off_amt,0) < 0 )
        ) THEN
          fnd_message.set_name ('AR','AR_SYSTEM_WR_NO_LIMIT_SET');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('l_max_wrt_off_amount = '||l_max_wrt_off_amount);
          arp_util.debug('l_min_wrt_off_amount = '||l_min_wrt_off_amount);
          arp_util.debug('l_tot_write_off_amt = '||l_tot_write_off_amt);
       END IF;

     /**Bug 5367753 Condition is added to convert the writeoff amount into
        functional currency for validation */
       IF l_functional_currency <> p_cr_currency_code THEN
          l_tot_writeoff_amt_func := arpcurr.functional_amount(
                                  l_tot_write_off_amt,
                                  l_functional_currency,
                                  l_exchange_rate,
                                  arp_global.base_precision,
                                  arp_global.base_min_acc_unit);
       END IF;

       IF l_tot_writeoff_amt_func IS NULL THEN
          l_tot_writeoff_amt_func := l_tot_write_off_amt;
       END IF;

       IF ( (NVL(l_tot_write_off_amt,0) > l_max_wrt_off_amount) OR
            (NVL(l_tot_write_off_amt,0) < l_min_wrt_off_amount) ) THEN
          arp_util.debug('ERROR l_tot_write_off_amt = '||l_tot_write_off_amt);
          fnd_message.set_name ('AR','AR_WR_TOTAL_EXCEED_MAX_AMOUNT');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    ELSIF p_applied_ps_id = -4 THEN
      IF l_activity_type <> 'CLAIM_INVESTIGATION' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_applied_ps_id = -5 THEN
       IF (l_activity_type <> 'ADJUST') OR (p_receivables_trx_id <> -11) THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_applied_ps_id = -6 THEN
       IF l_activity_type <> 'CCREFUND' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_applied_ps_id = -7 THEN
      IF l_activity_type <> 'PREPAYMENT' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_applied_ps_id = -8 THEN
      IF l_activity_type <> 'CM_REFUND' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    ELSE
      --the applied payment schedule id is invalid
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF; --additional control structures to be added for new activity types.
  END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_activity (-)');
 END IF;
END validate_activity;

PROCEDURE validate_activity_app( p_receivables_trx_id IN NUMBER,
                                 p_applied_ps_id  IN NUMBER,
                                 p_cash_receipt_id IN NUMBER,
                                 p_cr_gl_date  IN DATE,
                                 p_cr_unapp_amount IN NUMBER,
                                 p_cr_date IN DATE,
                                 p_cr_payment_schedule_id IN NUMBER,
                                 p_applied_amount IN NUMBER,
                                 p_apply_gl_date IN DATE,
                                 p_apply_date IN DATE,
                                 p_link_to_customer_trx_id IN NUMBER,
                                 p_cr_currency_code IN VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_val_writeoff_limits_flag IN VARCHAR2,
                                 p_called_from IN VARCHAR2 -- Bug 2897244
                                 ) IS
l_valid   VARCHAR2(1) DEFAULT 'N';
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('validate_activity_app ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
     validate_on_ac_app(
                   p_cash_receipt_id,
                   p_cr_gl_date,
                   p_cr_unapp_amount,
                   p_cr_date,
                   p_cr_payment_schedule_id,
                   p_applied_amount,
                   p_apply_gl_date,
                   p_apply_date,
                   p_return_status,
                   p_applied_ps_id,
                   p_called_from -- Bug 2897244
                    );
     IF p_receivables_trx_id <> -16        -- Seeded netting activity
     THEN
        validate_activity(
                   p_receivables_trx_id,
                   p_applied_ps_id,
                   p_cash_receipt_id,
                   p_applied_amount,
                   p_cr_currency_code,
                   p_val_writeoff_limits_flag,
                   p_return_status
                    );
     END IF;
     -- if this routine is called for ccrefund,this routine will check whether
     -- the receipt is a credit card receipt or not. We can issue refund only
     -- to credit card at this point.

     validate_ccrefund(
                   p_cash_receipt_id,
                   p_applied_ps_id,
                   p_return_status
                   );

   --SNAMBIAR for chargeback activity,customer_trx_id of the CB should be passed and should
   --be valid
     IF p_applied_ps_id = -5 THEN
        IF p_link_to_customer_trx_id IS NOT NULL THEN
           BEGIN
             SELECT 'Y'
             INTO   l_valid
             FROM   ar_payment_schedules
             WHERE  customer_trx_id=p_link_to_customer_trx_id
             AND   class='CB';
    	   EXCEPTION
     	     WHEN no_data_found THEN
                  FND_MESSAGE.SET_NAME('AR','AR_RAPI_LK_CUS_TRX_ID_INVALID');
                  FND_MSG_PUB.Add;
                  p_return_status := FND_API.G_RET_STS_ERROR;
            WHEN others THEN
                 raise;
            END;
            IF l_valid <> 'Y' THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_LK_CUS_TRX_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_valid := Null;
        ELSE
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_LK_CUS_TRX_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;

   --validate the p_link_to_customer_trx_id
   --SNAMBIAR Modified for Write-off
    IF p_link_to_customer_trx_id IS NOT NULL AND p_applied_ps_id <> -5 THEN

    BEGIN
     SELECT 'Y'
     INTO   l_valid
     FROM   ar_transaction_history
     WHERE  status IN ('FACTORED', 'MATURED_PEND_RISK_ELIMINATION',
                       'PENDING_REMITTANCE','CLOSED')
       AND  customer_trx_id = p_link_to_customer_trx_id
       AND  current_record_flag = 'Y';

       IF l_valid <> 'Y' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_LK_CUS_TRX_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    EXCEPTION
     WHEN no_data_found THEN
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_LK_CUS_TRX_ID_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
     WHEN others THEN
       raise;
    END;
   END IF;
     arp_util.debug('fnd_api.g_ret_sts_error = '||fnd_api.g_ret_sts_error);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('validate_activity_app ()-');
  END IF;
END validate_activity_app;

-- Bug 2270825 - additional validation for claims
PROCEDURE validate_application_ref(
                p_applied_ps_id                IN     NUMBER,
                p_application_ref_type         IN     VARCHAR2,
                p_application_ref_id           IN     NUMBER,
                p_application_ref_num          IN     VARCHAR2,
                p_secondary_application_ref_id IN     NUMBER,
                p_cash_receipt_id              IN     NUMBER,
                p_amount_applied               IN     NUMBER,
                p_amount_due_remaining         IN     NUMBER,
                p_cr_currency_code             IN     VARCHAR2,
                p_trx_currency_code            IN     VARCHAR2,
                p_application_ref_reason       IN     VARCHAR2,
                p_return_status                OUT NOCOPY    VARCHAR2
                   ) IS
l_valid  VARCHAR2(1) := 'N';
l_query_text     VARCHAR2(2000);
l_dummy          VARCHAR2(100);
l_claim_id       NUMBER;
l_net_claim_amount   NUMBER;
l_check_amount       NUMBER;
l_reason_code_id     NUMBER;
l_currency_code      fnd_currencies.currency_code%TYPE;
invalid_claim    EXCEPTION;

BEGIN
  arp_util.debug('validate_application_reference  ()+');

 IF (p_application_ref_type IS NOT NULL AND p_applied_ps_id < 0) THEN
  IF p_applied_ps_id IS NOT NULL  and p_applied_ps_id in (-4,-5,-6,-7) THEN
     BEGIN
         SELECT 'Y'
         INTO   l_valid
         FROM   ar_lookups
         WHERE  lookup_type = DECODE(p_applied_ps_id,-4,'APPLICATION_REF_TYPE',
                                                     -5,'CHARGEBACK',
                                                     -6, 'MISC_RECEIPT',
                                                     -7,'AR_PREPAYMENT_TYPE',
                                                     'NONE')
         AND    enabled_flag = 'Y'
         AND    lookup_code = p_application_ref_type;
     EXCEPTION
         WHEN no_data_found THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_INVALID_APP_REF');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
     END;
  ELSE
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
 END IF;
 /* Bug 2270825 - claim specific validation */
 /* Bug 2751910 - reason no longer compulsory */
 IF p_application_ref_type = 'CLAIM'
 THEN
   IF (p_application_ref_num IS NULL AND p_secondary_application_ref_id IS NULL)
   THEN
     IF p_application_ref_reason IS NOT NULL THEN
       /* Bug 3780081: bind variable used for reason_code_id */
       l_reason_code_id := TO_NUMBER(p_application_ref_reason);
       l_query_text :=
         ' select reason_code_id from ozf_reason_codes_vl '||
         ' where reason_code_id = :application_ref_reason '||
         ' and sysdate between nvl(start_date_active,sysdate) '||
         ' and nvl(end_date_active,sysdate) ';
       BEGIN
         EXECUTE IMMEDIATE l_query_text INTO l_dummy USING l_reason_code_id;
       EXCEPTION
         WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_INVALID_REF_REASON');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
       END;
     END IF;
   ELSE

     /* Bug 3780081: split query into 2 variants using bind variables */
     IF p_applied_ps_id = -4
     THEN
       l_currency_code := p_cr_currency_code;
     ELSE
       l_currency_code := p_trx_currency_code;
     END IF;
     l_query_text :=
         ' select claim_id from ozf_ar_deductions_v ';
     IF p_secondary_application_ref_id IS NOT NULL
     THEN
       l_query_text := l_query_text ||
         ' where claim_id = :secondary_application_ref_id '||
         ' and currency_code = :currency_code ';
       arp_util.debug('claim query text : '||l_query_text);
       BEGIN
         EXECUTE IMMEDIATE l_query_text INTO l_claim_id
         USING p_secondary_application_ref_id, l_currency_code ;
       EXCEPTION
         WHEN OTHERS THEN
           RAISE invalid_claim;
       END;
     ELSE
       l_query_text := l_query_text ||
         ' where claim_number = :application_ref_num '||
         ' and currency_code = :currency_code ';
       arp_util.debug('claim query text : '||l_query_text);
       BEGIN
         EXECUTE IMMEDIATE l_query_text INTO l_claim_id
         USING p_application_ref_num, l_currency_code ;
       EXCEPTION
         WHEN OTHERS THEN
           RAISE invalid_claim;
       END;
     END IF;

     /* Bug 2353144 - amount checking uses net amount remaining for claim */
     IF p_applied_ps_id = -4
     THEN
       l_check_amount := (p_amount_applied * -1);
     ELSE
       l_check_amount := (p_amount_due_remaining - p_amount_applied);
     END IF;
     arp_util.debug('l_check_amount = '||l_check_amount);
     /* Bug 2751910 - no longer need to cross check the amount */

   END IF;
 END IF;

   arp_util.debug('validate_application_reference  ()-');
EXCEPTION
  WHEN invalid_claim THEN
         IF p_secondary_application_ref_id IS NOT NULL
         THEN
           FND_MESSAGE.SET_NAME('AR','AR_RW_INVALID_CLAIM_ID');
           FND_MESSAGE.SET_TOKEN('CLAIM_ID',p_secondary_application_ref_id);
         ELSE
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_INVALID_CLAIM_NUM');
           FND_MESSAGE.SET_TOKEN('CLAIM_NUM',p_application_ref_num);
         END IF;
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
	 RAISE;
 WHEN others THEN
   p_return_status := FND_API.G_RET_STS_ERROR;
   arp_util.debug('EXCEPTION :validate_application_reference  ()-'||SQLERRM);
   raise;
END;

PROCEDURE Validate_misc_receipt(
                p_receipt_number               IN     VARCHAR2,
                p_receipt_method_id            IN     NUMBER,
                p_state                        IN     VARCHAR2,
                p_receipt_date                 IN     DATE,
                p_gl_date                      IN     DATE,
                p_deposit_date                 IN     DATE,
                p_amount                       IN     NUMBER,
                p_orig_receivables_trx_id      IN     NUMBER,
                p_receivables_trx_id           IN     NUMBER,
                p_distribution_set_id          IN OUT NOCOPY NUMBER,
                p_orig_vat_tax_id              IN     NUMBER,
                p_vat_tax_id                   IN     NUMBER,
                p_tax_rate                     IN OUT NOCOPY NUMBER,
                p_tax_amount                   IN     NUMBER,
                p_reference_num                IN     VARCHAR2,
                p_orig_reference_id            IN     NUMBER,
                p_reference_id                 IN     NUMBER,
                p_reference_type               IN     VARCHAR2,
                p_remittance_bank_account_id   IN     NUMBER,
                p_anticipated_clearing_date    IN     DATE,
                p_currency_code                IN     VARCHAR2,
                p_exchange_rate_type           IN     VARCHAR2,
                p_exchange_rate                IN     NUMBER,
                p_exchange_date                IN     DATE,
                p_doc_sequence_value           IN     NUMBER,
                p_return_status                   OUT NOCOPY VARCHAR2
                   )
IS

l_receipt_date_return_status  VARCHAR2(1);
l_gl_date_return_status       VARCHAR2(1);
l_deposit_date_return_status  VARCHAR2(1);
l_rcpt_md_return_status       VARCHAR2(1);
l_amount_return_status        VARCHAR2(1);
l_currency_return_status      VARCHAR2(1);
l_doc_seq_return_status       VARCHAR2(1);
l_dup_return_status           VARCHAR2(1);
l_activity_return_status      VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_tax_id_return_status        VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_tax_rate_return_status      VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_tax_rate                    NUMBER;
l_tax_validate_flag           VARCHAR2(1);
l_reference_valid             VARCHAR2(1);
l_ref_id_return_status        VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_ref_type_return_status      VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Validate_misc_receipt()+ ');
        END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;

    --Validate receipt_date

      Validate_Receipt_Date(p_receipt_date,
                            l_receipt_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_misc_receipt: ' || 'l_receipt_date_return_status : '||l_receipt_date_return_status);
      END IF;

    --Validate gl_date

      Validate_Gl_Date(p_gl_date,
                       l_gl_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_misc_receipt: ' || 'l_gl_date_return_status : '||l_gl_date_return_status);
      END IF;

    --Validate deposit_date

      Validate_Deposit_Date(p_deposit_date,
                            l_deposit_date_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_misc_receipt: ' || 'l_deposit_date_return_status : '||l_deposit_date_return_status);
      END IF;


    --Validate Receipt_method
      Validate_Receipt_Method(p_receipt_method_id,
                              p_remittance_bank_account_id,
                              p_receipt_date,
                              p_currency_code,
                              p_state,
                              'MISC',
                              l_rcpt_md_return_status);
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_misc_receipt: ' || 'l_rcpt_md_return_status : '||l_rcpt_md_return_status);
       END IF;

   --Validate document sequence value

      IF(NVL(ar_receipt_lib_pvt.pg_profile_doc_seq, 'N') = 'N' )  AND
          p_doc_sequence_value IS NOT NULL
        THEN
             l_doc_seq_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_VAL_INVALID');
             FND_MSG_PUB.Add;
       END IF;

    --Validate currency and exchange rate info.
     IF p_currency_code <> arp_global.functional_currency OR
        p_exchange_rate_type  IS NOT NULL OR
        p_exchange_rate       IS NOT NULL OR
        p_exchange_date  IS NOT NULL
      THEN
       Validate_currency(p_currency_code,
                         p_exchange_rate_type,
                         p_exchange_rate,
                         p_exchange_date,
                         l_currency_return_status);
     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_misc_receipt: ' || 'l_currency_return_status : '||l_currency_return_status);
     END IF;

     IF p_receipt_number IS NOT NULL AND
        p_amount IS NOT NULL
      THEN
        val_duplicate_receipt(p_receipt_number,
                              p_receipt_date,
                              p_amount,
                              'MISC',
                              null,
                              l_dup_return_status );
     END IF;

    --Validate the activity on the misc receipt.
    --Also default the distribution_set_id.
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_misc_receipt: ' || 'Validating the activity ');
   END IF;
    IF p_receivables_trx_id IS NOT NULL THEN

     --CC Chargeback logic
      BEGIN
             SELECT rt.default_acctg_distribution_set
             INTO   p_distribution_set_id
             FROM   ar_receivables_trx rt
             WHERE  rt.receivables_trx_id = p_receivables_trx_id
             AND    rt.type in
            ('MISCCASH', 'BANK_ERROR', 'CCREFUND', 'CM_REFUND','CC_CHARGEBACK')
             AND    nvl(rt.status, 'A') = 'A'
             AND    p_receipt_date >= nvl(rt.start_date_active, p_receipt_date)
             AND    p_receipt_date <= nvl(rt.end_date_active, p_receipt_date);
      EXCEPTION
       WHEN no_data_found THEN
         IF p_orig_receivables_trx_id IS NULL THEN
             l_activity_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_INVALID');
             FND_MSG_PUB.Add;
         ELSE
             l_activity_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_TRX_ID_INVALID');
             FND_MSG_PUB.Add;
         END IF;
      END;
    ELSE
             l_activity_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_TRX_ID_NULL');
             FND_MSG_PUB.Add;
    END IF;


    --Validate vat_tax_id
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_misc_receipt: ' || 'Validating vat_tax_id');
    END IF;

  IF arp_global.sysparam.accounting_method = 'ACCRUAL'
   THEN
      IF p_vat_tax_id IS NOT NULL THEN
        BEGIN
           SELECT percentage_rate
           INTO   l_tax_rate
           FROM   zx_sco_rates vt
           WHERE  p_receipt_date between
                          nvl(vt.effective_from, p_receipt_date)
                     and  nvl(vt.effective_to, p_receipt_date)
             AND  (vt.tax_class =  decode(sign(p_amount), 1, 'OUTPUT',
                                        0, 'OUTPUT',-1, 'INPUT') OR vt.tax_class IS NULL) -- Added condition --> vt.tax_class IS NULL to handle (bug 8648248)
             AND  vt.tax_rate_id = p_vat_tax_id;                                          -- the Miscellaneous Receipt creation through Standard API
/*  Bug 5955921 - Replaced the obsoleted ar_vat_tax with zx_sco_rates
            SELECT tax_rate, validate_flag
            INTO   l_tax_rate, l_tax_validate_flag
            FROM   ar_vat_tax vt
            WHERE  p_receipt_date between
		          nvl(vt.start_date, p_receipt_date)
	             and  nvl(vt.end_date, p_receipt_date)
              AND  vt.set_of_books_id = arp_global.set_of_books_id
              AND  vt.tax_class =  decode(sign(p_amount), 1, 'O', 0, 'O',  -1, 'I')
              AND  vt.enabled_flag='Y'
              AND  vt.tax_type <> 'TAX_GROUP'
              AND  vt.tax_type <> 'LOCATION'
              AND  vt.tax_type <> 'SALES_TAX'
              AND  vt.displayed_flag='Y'
              AND  vt.vat_tax_id = p_vat_tax_id;   */

        EXCEPTION
         WHEN no_data_found THEN
            IF p_orig_vat_tax_id IS NOT NULL THEN
              l_tax_id_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_VAT_TAX_ID_INVALID');
              FND_MSG_PUB.Add;
            ELSE
              l_tax_id_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_CODE_INVALID');
              FND_MSG_PUB.Add;
            END IF;
        END;

       --In case where user has specified the tax_rate/tax amount , we need to verify
       --the adhoc flag on the tax_code as well as the profile option
       --'Tax: Allow Ad Hoc Tax Changes'
       --to see if he alowed to do so.
       --p_tax_rate is the user specified  tax rate or the tax rate derived from the
       --user specified tax amount and the receipt amount.
       /* 4743228 - use ZX profile instead */
       IF p_tax_rate IS NOT NULL THEN
           /* Bug 5955921  l_tax_validate_flag = 'N' OR */
          IF fnd_profile.value('ZX_ALLOW_TAX_UPDATE') = 'N'
          THEN
              l_tax_rate_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_RATE_INVALID');
              FND_MSG_PUB.Add;
          END IF;
       ELSE

         IF arp_global.sysparam.accounting_method = 'ACCRUAL' THEN
          p_tax_rate := l_tax_rate;
         END IF;

       END IF;


      ELSE
     --this is the case where we dont have any vat_tax_id, but the user has specified the
     --tax rate as a input parameter.
        IF p_tax_rate IS NOT NULL THEN
              l_tax_id_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_RATE_INVALID');
              FND_MSG_PUB.Add;
        END IF;
      END IF;

  ELSE
    --if the accounting is cash basis.
    IF p_vat_tax_id IS NOT NULL THEN
       --raise error as no tax accounting is done for cash basis in misc receipt.
             l_tax_id_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_VAT_TAX_ID_INVALID');
             FND_MSG_PUB.Add;
    END IF;

    IF p_tax_rate   IS NOT NULL  THEN
             l_tax_id_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_RATE_INVALID');
             FND_MSG_PUB.Add;
    END IF;

  END IF;



    --Validate reference_id, reference_type
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_misc_receipt: ' || 'Validation for reference id begins');
   END IF;
   IF p_reference_type IS NOT NULL  THEN
    IF p_reference_id IS NOT NULL THEN
     BEGIN
        IF  (p_reference_type = 'PAYMENT')  THEN
          --get from ap_checks.
            select 'y'
            into   l_reference_valid
            from   ap_checks
            where  check_id = p_reference_id /* Bug fix 2982212 */
            and ce_bank_acct_use_id = p_remittance_bank_account_id;/*bug8449826*/
              /*and  bank_account_id = p_remittance_bank_account_id;*/
        ELSIF (p_reference_type = 'PAYMENT_BATCH' ) THEN
          --
            select 'y'
            into   l_reference_valid
            from   ap_invoice_selection_criteria isc
            where  isc.checkrun_id = p_reference_id /* Bug fix 2982212 */
              and  bank_account_id = p_remittance_bank_account_id;
        ELSIF (p_reference_type = 'RECEIPT' ) THEN
          --
            select 'y'
            into   l_reference_valid
            from   ar_cash_receipts
            where  cash_receipt_id = p_reference_id
             and   remit_bank_acct_use_id = p_remittance_bank_account_id;
        ELSIF (p_reference_type = 'REMITTANCE' ) THEN
         --
            select 'y'
            into   l_reference_valid
            from   ar_batches
            where  batch_id = p_reference_id /* Bug fix 2982212 */
             and   type = 'REMITTANCE'
             and   remit_bank_acct_use_id = p_remittance_bank_account_id;
        /* Bug 4112494 - added for credit memo refunds */
        ELSIF (p_reference_type = 'CREDIT_MEMO' ) THEN
          --
            select 'y'
            into   l_reference_valid
            from   ra_customer_trx
            where  customer_trx_id = p_reference_id;
        ELSE
         --the reference_type is invalid, raise error.
            l_ref_type_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_TYPE_INVALID');
            FND_MSG_PUB.Add;

        END IF;
     EXCEPTION
        WHEN no_data_found THEN
          IF p_orig_reference_id IS NULL THEN
            l_ref_id_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_NUM_INVALID');
            FND_MSG_PUB.Add;
          ELSE
            l_ref_id_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_ID_INVALID');
            FND_MSG_PUB.Add;
          END IF;
     END;
    ELSE
      --the reference_id is null, raise error.
      IF p_reference_num IS NOT NULL THEN
          --this would happen if the reference_id could not be
          --derived from reference number
            l_ref_id_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_NUM_INVALID');
            FND_MSG_PUB.Add;
      ELSE
            l_ref_id_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_ID_NULL');
            FND_MSG_PUB.Add;
      END IF;

    END IF;

   ELSE
       --reference_type is null

      IF p_orig_reference_id IS NULL  AND
         p_reference_num IS NULL
       THEN
            null;
      ELSE
        --this means any one of the orig_reference_id, reference_num or
        --reference_id is specified, so a null reference type should
        --raise an error.
            l_ref_type_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_TYPE_NULL');
            FND_MSG_PUB.Add;
      END IF;
   END IF;


     IF (l_receipt_date_return_status   = FND_API.G_RET_STS_ERROR) OR
        (l_gl_date_return_status        = FND_API.G_RET_STS_ERROR) OR
        (l_deposit_date_return_status   = FND_API.G_RET_STS_ERROR) OR
        (l_rcpt_md_return_status        = FND_API.G_RET_STS_ERROR) OR
        (l_amount_return_status         = FND_API.G_RET_STS_ERROR) OR
        (l_currency_return_status       = FND_API.G_RET_STS_ERROR) OR
        (l_doc_seq_return_status        = FND_API.G_RET_STS_ERROR) OR
        (l_dup_return_status            = FND_API.G_RET_STS_ERROR) OR
        (l_activity_return_status       = FND_API.G_RET_STS_ERROR) OR
        (l_tax_id_return_status         = FND_API.G_RET_STS_ERROR) OR
        (l_ref_id_return_status         = FND_API.G_RET_STS_ERROR) OR
        (l_ref_type_return_status       = FND_API.G_RET_STS_ERROR)
       THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_misc_receipt return status :'||p_return_status);
    END IF;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION : Validate_misc_receipt()');
   END IF;
  raise;

END Validate_misc_receipt;

PROCEDURE validate_prepay_amount(
                p_receipt_number              IN  VARCHAR2,
                p_cash_receipt_id             IN  NUMBER,
                p_applied_ps_id               IN  NUMBER,
                p_receivable_application_id   IN  NUMBER,
                p_refund_amount               IN  NUMBER,
                p_return_status               OUT NOCOPY VARCHAR2
                               ) IS
l_cash_receipt_id  NUMBER;
l_prepay_amount    NUMBER;
BEGIN

 arp_util.debug('Validate prepay amount (+)');
 p_return_status := FND_API.G_RET_STS_SUCCESS;

 l_cash_receipt_id := p_cash_receipt_id;

 IF p_receipt_number IS NOT NULL THEN
        ar_receipt_lib_pvt.Default_cash_receipt_id(l_cash_receipt_id ,
                                p_receipt_number ,
                                p_return_status);
 END IF;

 IF l_cash_receipt_id IS NOT NULL THEN

    SELECT sum(nvl(amount_applied,0))
    INTO   l_prepay_amount
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cash_receipt_id
    AND    applied_payment_schedule_id = p_applied_ps_id
    AND    display = 'Y'
    AND    status = 'OTHER ACC';

 END IF;

 IF p_receivable_application_id IS NOT NULL THEN

    SELECT sum(nvl(amount_applied,0))
    INTO   l_prepay_amount
    FROM    ar_receivable_applications
    WHERE   receivable_application_id = p_receivable_application_id
    AND     display = 'Y'
    AND     applied_payment_schedule_id = p_applied_ps_id
    AND     status = 'OTHER ACC';

 END IF;

 IF nvl(p_refund_amount,0) > l_prepay_amount THEN
    --raise error X validation failed
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_PREPAY_AMT_LESS');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR ;
 END IF;

 arp_util.debug('Validate prepay amount (-)');

EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
 arp_util.debug('EXCEPTION :Validate prepay amount '||SQLERRM);
END;

PROCEDURE validate_payment_type(
                p_receipt_number              IN  VARCHAR2,
                p_cash_receipt_id             IN  NUMBER,
                p_receivable_application_id   IN  NUMBER,
                p_payment_action              IN  VARCHAR2,
                p_return_status               OUT NOCOPY VARCHAR2
                   ) IS

l_payment_type_code     VARCHAR2(30);
l_cash_receipt_id  NUMBER;

BEGIN
 arp_util.debug('Validate payment Type (+)');
 p_return_status := FND_API.G_RET_STS_SUCCESS;

 l_cash_receipt_id := p_cash_receipt_id;

 IF p_receipt_number IS NOT NULL THEN
        ar_receipt_lib_pvt.Default_cash_receipt_id(l_cash_receipt_id ,
                                p_receipt_number ,
                                p_return_status);
 END IF;

 IF l_cash_receipt_id IS NOT NULL THEN

    SELECT NVL(payment_channel_code,'CASH')
    INTO   l_payment_type_code
    FROM   ar_receipt_methods arm,
           ar_cash_receipts cr
    WHERE  cr.receipt_method_id = arm.receipt_method_id
    AND    cr.cash_receipt_id=l_cash_receipt_id;


 ELSIF p_receivable_application_id is not null THEN

    SELECT NVL(payment_channel_code,'CASH')
    INTO   l_payment_type_code
    FROM   ar_receipt_methods arm,
           ar_cash_receipts cr,
           ar_receivable_applications app
    WHERE  cr.receipt_method_id = arm.receipt_method_id
    AND    app.cash_receipt_id=cr.cash_receipt_id
    AND    app.receivable_application_id = p_receivable_application_id;

 END IF;

 IF (NVL(l_payment_type_code,'CASH') <> 'CREDIT_CARD') THEN

       IF p_payment_action = 'CREATE_RCPT' THEN

         FND_MESSAGE.set_name ('AR','AR_RAPI_PREPAY_ONLYFOR_CC');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR ;

       ELSIF  p_payment_action = 'REFUND_RCPT' THEN

         FND_MESSAGE.set_name ('AR','AR_RW_CCR_NOT_CC_RECEIPT');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR ;

      END IF;
 END IF;

 arp_util.debug('Validate payment Type (-)');

EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
 arp_util.debug('EXCEPTION :Validate payment type '||SQLERRM);
END;

 -- Bug 2270809
 -- If a claim investigation app, then check the claim status.
 -- If not OPEN,CANCELLED,COMPLETE then disallow unapply

PROCEDURE validate_claim_unapply(
                p_secondary_app_ref_id        IN  VARCHAR2,
                p_invoice_ps_id               IN  NUMBER,
                p_customer_trx_id             IN  NUMBER,
                p_cash_receipt_id             IN  NUMBER,
                p_receipt_number              IN  VARCHAR2,
                p_amount_applied              IN  NUMBER,
                p_cancel_claim_flag           IN  VARCHAR2,
                p_return_status               OUT NOCOPY VARCHAR2)
IS
  l_claim_status                  VARCHAR2(30);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_secondary_app_ref_id          NUMBER;
  l_claim_reason_code_id          NUMBER;
  l_claim_reason_name             VARCHAR2(100);
  l_claim_number                  VARCHAR2(30);


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_val_pvt.validate_claim_unapply()+');
  END IF;

  l_secondary_app_ref_id := p_secondary_app_ref_id;

  arp_process_application.update_claim(
                p_claim_id      =>  l_secondary_app_ref_id
              , p_invoice_ps_id =>  p_invoice_ps_id
              , p_customer_trx_id => p_customer_trx_id
              , p_amount        =>  0
              , p_amount_applied => p_amount_applied
              , p_apply_date    =>  SYSDATE
              , p_cash_receipt_id => p_cash_receipt_id
              , p_receipt_number => p_receipt_number
              , p_action_type   => 'U'
              , x_claim_reason_code_id => l_claim_reason_code_id
              , x_claim_reason_name    => l_claim_reason_name
              , x_claim_number         => l_claim_number
              , x_return_status =>  p_return_status
              , x_msg_count     =>  l_msg_count
              , x_msg_data      =>  l_msg_data);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_val_pvt.validate_claim_unapply()-');
  END IF;
EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION :ar_receipt_val_pvt.validate_claim_unapply '||SQLERRM);
     END IF;
END validate_claim_unapply;

PROCEDURE validate_open_receipt_info(
       p_cash_receipt_id         IN  NUMBER
     , p_open_cash_receipt_id    IN  NUMBER
     , p_apply_date              IN  DATE
     , p_apply_gl_date           IN  DATE
     , p_cr_gl_date              IN  DATE
     , p_open_cr_gl_date         IN  DATE
     , p_cr_date                 IN  DATE
     , p_amount_applied          IN  NUMBER
     , p_other_amount_applied    IN  NUMBER
     , p_receipt_currency        IN  VARCHAR2
     , p_open_receipt_currency   IN  VARCHAR2
     , p_cr_customer_id          IN  NUMBER
     , p_open_cr_customer_id     IN  NUMBER
     , p_unapplied_cash          IN  NUMBER
     , p_called_from             IN  VARCHAR2
     , p_return_status           OUT NOCOPY VARCHAR2
) IS
l_rct_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_gl_date_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_act_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_amt_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_cust_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_cur_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_apply_date_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_func_currency         gl_sets_of_books.currency_code%TYPE;
l_activity_name         ar_receivables_trx.name%TYPE;
l_ccid			NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_open_receipt_info()+');
  END IF;

  -- Bug 3235089: checks for activity existing and accounting set up
  BEGIN
     SELECT name, code_combination_id
     INTO   l_activity_name, l_ccid
     FROM   ar_receivables_trx
     WHERE  receivables_trx_id = -16;

     IF l_ccid IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RW_NO_NETTING_ACCOUNT');
       FND_MSG_PUB.Add;
       l_act_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME('AR','AR_RW_MISSING_NETTING_ACTIVITY');
       FND_MSG_PUB.Add;
       l_act_return_status := FND_API.G_RET_STS_ERROR;
  END;

  IF p_cash_receipt_id = p_open_cash_receipt_id THEN
    FND_MESSAGE.SET_NAME('AR','AR_RW_NET_RCT_APPLY_SELF');
    FND_MSG_PUB.Add;
    l_rct_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if valid paying customer
  IF NOT arp_trx_validate.validate_paying_customer(
               p_paying_customer_id           => p_cr_customer_id,
               p_trx_date                     => p_cr_date,
               p_bill_to_customer_id          => p_open_cr_customer_id,
               p_ct_prev_paying_customer_id   => p_cr_customer_id,
               p_currency_code                => p_receipt_currency,
               p_pay_unrelated_invoices_flag  => arp_global.sysparam.pay_unrelated_invoices_flag,
               p_ct_prev_trx_date             => p_cr_date)  THEN
          FND_MESSAGE.SET_NAME('AR','ARTA_PYMNT_UNRELATED_CUST');
          FND_MSG_PUB.Add;
          l_cust_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


         validate_apply_date(p_apply_date,
                             p_apply_date, /* Bug fix 3286069 */
                             p_cr_date,
                             l_apply_date_return_status
                             );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_open_receipt_info: ' || 'Apply date return status :'||l_apply_date_return_status);
   END IF;

         validate_apply_gl_date(p_apply_gl_date ,
                                 p_cr_gl_date ,
                                 p_cr_gl_date  ,
                                 l_gl_date_return_status
                                 );

       IF p_apply_gl_date < p_open_cr_gl_date  THEN
          FND_MESSAGE.SET_NAME('AR','AR_RW_GL_DATE_BEFORE_OPEN_REC');
          FND_MSG_PUB.Add;
          l_gl_date_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_open_receipt_info: ' || 'Apply gl_date return status :'||l_gl_date_return_status);
      arp_util.debug('Validate_open_receipt_info: ' || 'p_unapplied_cash :'||p_unapplied_cash);
      arp_util.debug('Validate_open_receipt_info: ' || 'p_amount_applied :'||p_amount_applied);
      arp_util.debug('Validate_open_receipt_info: ' || 'p_called_from :'||p_called_from);
   END IF;
       --  validate amount applied
          IF  p_amount_applied IS NULL  THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_APPLIED_AMT_NULL');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;

          ELSE
            -- Bug 2897244 - receipt overapplication not checked if called
            -- from ARXRWAPP or PostBatch
            IF NVL(p_called_from,'RAPI') NOT IN ('ARXRWAPP','ARCAPB')
            THEN
              IF (nvl(p_unapplied_cash,0)- p_amount_applied) < 0 THEN
                FND_MESSAGE.SET_NAME('AR','AR_RW_AMOUNT_LESS_THAN_APP');
                FND_MSG_PUB.Add;
                l_amt_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF;
            IF ((SIGN(p_other_amount_applied * -1) <> SIGN(p_amount_applied)) OR
                (ABS(p_amount_applied) > ABS(p_other_amount_applied)) ) THEN
              FND_MESSAGE.SET_NAME('AR','AR_RW_NET_OPEN_AMT_INC');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

          END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_open_receipt_info: ' || 'Amount return status :'||l_amt_return_status);
   END IF;

   SELECT sob.currency_code
   INTO   l_func_currency
   FROM   ar_system_parameters sp,
          gl_sets_of_books sob
   WHERE  sp.set_of_books_id = sob.set_of_books_id;

   IF (p_receipt_currency <> p_open_receipt_currency) THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_NET_DIFF_RCT_CURR');
        FND_MSG_PUB.Add;
        l_cur_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

    IF l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_rct_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_act_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_amt_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_cur_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_cust_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_apply_date_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_val_pvt.validate_open_receipt_info()-');
  END IF;
EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION :ar_receipt_val_pvt.validate_open_receipt_info '||SQLERRM);
     END IF;

END validate_open_receipt_info;

PROCEDURE validate_unapp_open_receipt(
       p_applied_cash_receipt_id IN  NUMBER
     , p_amount_applied          IN  NUMBER
     , p_return_status           IN OUT NOCOPY VARCHAR2
) IS

  l_cr_amount             NUMBER;
  l_amount_applied        NUMBER;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_unapp_open_receipt()+');
  END IF;

  -- Check if unapplication will send the applied-to receipt negative

    SELECT amount
    INTO   l_cr_amount
    FROM   ar_cash_receipts
    WHERE  cash_receipt_id = p_applied_cash_receipt_id;

    SELECT NVL(SUM(amount_applied),0)
    INTO   l_amount_applied
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_applied_cash_receipt_id
    AND    display = 'Y';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_unapp_open_receipt-Receipt amount: '||l_cr_amount);
       arp_util.debug('validate_unapp_open_receipt-Applied amount: '||l_amount_applied);
    END IF;

    IF (l_cr_amount - l_amount_applied - p_amount_applied) < 0 THEN
       FND_MESSAGE.set_name('AR','AR_RW_NET_UNAPP_OVERAPP');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_val_pvt.validate_unapp_open_receipt()-');
  END IF;

EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION :ar_receipt_val_pvt.validate_unapp_open_receipt '||SQLERRM);
     END IF;

END validate_unapp_open_receipt;

PROCEDURE validate_llca_insert_ad(
         p_cash_receipt_id       IN	NUMBER
        ,p_customer_trx_id       IN	NUMBER
        ,p_customer_trx_line_id  IN	NUMBER
        ,p_cr_unapp_amount       IN	NUMBER
        ,p_llca_type             IN	VARCHAR2
        ,p_group_id              IN	VARCHAR2
        ,p_line_amount           IN	NUMBER
        ,p_tax_amount            IN	NUMBER
        ,p_freight_amount        IN	NUMBER
        ,p_charges_amount        IN	NUMBER
        ,p_line_discount         IN	NUMBER
        ,p_tax_discount          IN	NUMBER
        ,p_freight_discount      IN	NUMBER
        ,p_amount_applied        IN     NUMBER
        ,p_amount_applied_from   IN	NUMBER
        ,p_trans_to_receipt_rate IN	NUMBER
        ,p_invoice_currency_code IN	VARCHAR2
        ,p_receipt_currency_code IN	VARCHAR2
        ,p_earned_discount       IN	NUMBER
        ,p_unearned_discount     IN	NUMBER
        ,p_max_discount          IN	NUMBER
        ,p_line_items_original	 IN	NUMBER
	,p_line_items_remaining	 IN	NUMBER
	,p_tax_original		 IN	NUMBER
	,p_tax_remaining	 IN	NUMBER
	,p_freight_original	 IN	NUMBER
	,p_freight_remaining	 IN	NUMBER
	,p_rec_charges_charged	 IN	NUMBER
	,p_rec_charges_remaining IN	NUMBER
        ,p_attribute_category    IN	VARCHAR2
        ,p_attribute1            IN	VARCHAR2
        ,p_attribute2            IN	VARCHAR2
        ,p_attribute3            IN	VARCHAR2
        ,p_attribute4            IN	VARCHAR2
        ,p_attribute5            IN	VARCHAR2
        ,p_attribute6            IN	VARCHAR2
        ,p_attribute7            IN	VARCHAR2
        ,p_attribute8            IN	VARCHAR2
        ,p_attribute9            IN	VARCHAR2
        ,p_attribute10           IN	VARCHAR2
        ,p_attribute11           IN	VARCHAR2
        ,p_attribute12           IN	VARCHAR2
        ,p_attribute13           IN	VARCHAR2
        ,p_attribute14           IN	VARCHAR2
        ,p_attribute15           IN	VARCHAR2
        ,p_comments              IN	VARCHAR2
        ,p_return_status         OUT NOCOPY VARCHAR2
        ,p_msg_count             OUT NOCOPY NUMBER
        ,p_msg_data              OUT NOCOPY VARCHAR2
        ) IS

cursor all_lines_in_grp (p_cust_trx_id in number,
			 p_grp_id in number) is
select to_char(line.line_number) apply_to,
       line.customer_trx_line_id LINE_ID,
       nvl(line.source_data_key4,0) GROUP_ID ,
       nvl(line.amount_due_remaining,0) line_to_apply,
       nvl(tax.amount_due_remaining,0) tax_to_apply
from ra_customer_trx_lines line,
     (select link_to_cust_trx_line_id,
             line_type,
             sum(nvl(amount_due_original,0)) amount_due_original,
             sum(nvl(amount_due_remaining,0)) amount_due_remaining
       from ra_customer_trx_lines
       where customer_trx_id =  p_cust_trx_id  -- Bug 7241703 Added condition
          and nvl(line_type,'TAX') =  'TAX'
       group by link_to_cust_trx_line_id,line_type
      ) tax
where line.customer_Trx_id = p_cust_trx_id
and line.line_type = 'LINE'
and line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
and line.source_data_key4 = p_grp_id;

cursor all_lines_cur (p_cust_trx_id in number) is
select  to_char(line.line_number) apply_to,
        line.customer_trx_line_id line_id,
        nvl(line.source_data_key4,0) group_id ,
        nvl(line.amount_due_remaining,0) line_to_apply,
        nvl(tax.amount_due_remaining,0)  tax_to_apply
from ra_customer_trx_lines line,
     (select link_to_cust_trx_line_id,
             line_type,
             sum(nvl(amount_due_original,0)) amount_due_original,
             sum(nvl(amount_due_remaining,0)) amount_due_remaining
      from ra_customer_trx_lines
      where customer_trx_id =  p_cust_trx_id  -- Bug 7241703 Added condition
        and nvl(line_type,'TAX') =  'TAX'
      group by link_to_cust_trx_line_id,line_type
      ) tax
where line.customer_Trx_id = p_cust_trx_id
and line.line_type = 'LINE'
and   line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
order by line_number;

cursor gt_lines_cur (p_cust_trx_id in number) is
select * from ar_llca_trx_lines_gt
where customer_trx_id = p_cust_trx_id;

ll_msg_data		varchar2(2000);
ll_return_status	varchar2(1);
ll_msg_count		number;
l_gt_count		NUMBER :=0;

l_ctl_id		number;
llca_ra_rec		ar_receivable_applications%rowtype;

-- LLCA - LINE LEVEL
l_rowid			rowid;
l_group_id		ra_customer_trx_lines.source_data_key4%type;
l_line_amount_remaining	NUMBER;
l_line_tax_remaining	NUMBER;
l_line_number		NUMBER;
l_calc_tot_amount_app   NUMBER;
l_calc_amount_app_from  NUMBER; -- Amount in Receipt Currency
l_calc_line_per		NUMBER;
l_calc_line_amount	NUMBER;
l_calc_tax_amount	NUMBER;
l_calc_freight_amount	NUMBER;
l_cr_unapp_bal		NUMBER;
l_dflex_val_return_status VARCHAR2(1); --bug7311231
l_attribute_rec         ar_receipt_api_pub.attribute_rec_type; --bug7311231
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_llac_insert_ad()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Initialization the GT tables ...');
      arp_util.debug('DONE In the default initialization the GT tables ...');
  END IF;
/*
  -- Initialize the Sys Parameters /INV PS /REC PS / Copy Trx lines into GT
  arp_process_det_pkg.initialization (p_customer_trx_id,
 	                              p_cash_receipt_id,
	 	  	 	      p_return_status,
				      p_msg_data,
				      p_msg_count);  */
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Initialization Return_status = '||p_return_status);
   END IF;

   -- LLCA Summary
   IF p_llca_type = 'S'
   THEN

     IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Summary Level application... ');
      arp_util.debug('p_line_amount      ... '||p_line_amount);
      arp_util.debug('p_tax_amount       ... '||p_tax_amount);
      arp_util.debug('p_freight_amount   ... '||p_freight_amount);
      arp_util.debug('p_charges_amount   ... '||p_charges_amount);
      arp_util.debug('p_line_discount    ... '||p_line_discount);
      arp_util.debug('p_tax_discount     ... '||p_tax_discount);
      arp_util.debug('p_freight_discount ... '||p_freight_discount);
      arp_util.debug('Trans_to_receipt_rate='||p_trans_to_receipt_rate);
      arp_util.debug('Invoice Currency Code='||p_invoice_currency_code);
      arp_util.debug('Receipt Currency Code='||p_receipt_currency_code);
      arp_util.debug('............................ ');
     END IF;

--bug7311231.
     ar_ll_rcv_summary_pkg.insert_row(
		          x_cash_receipt_id     => p_cash_receipt_id,
		          x_customer_trx_id     => p_customer_trx_id,
			  x_lin                 => p_line_amount,
		          x_tax                 => p_tax_amount,
			  x_frt                 => p_freight_amount,
		          x_chg                 => p_charges_amount,
		          x_lin_dsc             => p_line_discount,
			  x_tax_dsc             => p_tax_discount,
		          x_frt_dsc             => p_freight_discount,
			  x_created_by_module   => 'RAPI'
		         ,x_inv_curr_code       => p_invoice_currency_code
			 ,x_inv_to_rct_rate     => p_trans_to_receipt_rate
		         ,x_rct_curr_code       => p_receipt_currency_code
			 ,x_attribute_category  => p_attribute_category
			 ,x_attribute1          => p_attribute1
			 ,x_attribute2          => p_attribute2
			 ,x_attribute3          => p_attribute3
			 ,x_attribute4          => p_attribute4
			 ,x_attribute5          => p_attribute5
			 ,x_attribute6          => p_attribute6
			 ,x_attribute7          => p_attribute7
			 ,x_attribute8          => p_attribute8
			 ,x_attribute9          => p_attribute9
			 ,x_attribute10         => p_attribute10
			 ,x_attribute11         => p_attribute11
			 ,x_attribute12         => p_attribute12
			 ,x_attribute13         => p_attribute13
			 ,x_attribute14         => p_attribute14
			 ,x_attribute15         => p_attribute15
		        );
   -- Group Level
   ELSIF p_llca_type = 'G'
   THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Group Level application... ');
      END IF;

      If p_group_id is NOT NULL
      THEN
       -- Customer Select Specify Group
       l_cr_unapp_bal		:= Nvl(p_cr_unapp_amount,0);

        For line_grp in All_lines_in_grp (p_customer_trx_id,p_group_id)
        LOOP
	 l_calc_tot_amount_app := Nvl(line_grp.line_to_apply,0)
					+ Nvl(line_grp.tax_to_apply,0);

  	 If Nvl(l_cr_unapp_bal,0) = 0
	 Then
	    l_calc_tot_amount_app := 0;
	    l_calc_line_amount	:= 0;
	    l_calc_tax_amount	:= 0;
	 Else
 	     If Nvl(l_calc_tot_amount_app,0) > Nvl(l_cr_unapp_bal,0) Then
	        -- Unapplied balance is non zero and > than amount applied, so default the
		-- Unapplied balance to total amount applied and calculate the line amount as
		-- amount_applied * (line_bal/(line_bal+tax_bal)) and tax_amount =
		-- amount_applied - line_amount

		l_calc_tot_amount_app :=  arp_util.CurrRound(l_cr_unapp_bal
					   ,p_invoice_currency_code);

		Select decode ( ( Nvl(line_grp.line_to_apply,0)
					 / (Nvl(line_grp.line_to_apply,0)
					  + Nvl(line_grp.tax_to_apply,0)
				           )
				 ),0,1,
				 ( Nvl(line_grp.line_to_apply,0)
					 / (Nvl(line_grp.line_to_apply,0)
					  + Nvl(line_grp.tax_to_apply,0)
				           )
				 )
			      )
		into l_calc_line_per
		from dual;

		l_calc_line_amount    :=  arp_util.CurrRound((l_calc_tot_amount_app
					  * l_calc_line_per),p_invoice_currency_code);
 	        l_calc_tax_amount     :=  arp_util.CurrRound((Nvl(l_calc_tot_amount_app,0)
		 			  - Nvl(l_calc_line_amount,0))
					  ,p_invoice_currency_code);
 	     Else
		l_calc_line_amount   := Nvl(line_grp.line_to_apply,0);
		l_calc_tax_amount    := Nvl(line_grp.tax_to_apply,0);
	     End If;

 	    -- Reset the balance
             l_cr_unapp_bal       := Nvl(l_cr_unapp_bal,0) - (Nvl(l_calc_line_amount,0)
						+ Nvl(l_calc_tax_amount,0));
         End If;

	 ar_activity_details_pkg.insert_row (
                      x_rowid                     => l_rowid,
                      x_cash_receipt_id           => p_cash_receipt_id,
                      x_customer_trx_line_id      => line_grp.line_id,
                      x_allocated_receipt_amount  => Nvl(l_calc_tot_amount_app,0),
                      x_amount                    => Nvl(l_calc_line_amount,0),
                      x_tax                       => Nvl(l_calc_tax_amount,0),
                      x_line_discount             => '',
                      x_tax_discount              => '',
                      x_line_balance              => line_grp.line_to_apply,
                      x_tax_balance               => Nvl(line_grp.tax_to_apply,0),
                      x_apply_to                  => line_grp.apply_to,
	              x_attribute_category        => p_attribute_category,
	              x_attribute1                => p_attribute1,
    		      x_attribute2                => p_attribute2,
		      x_attribute3                => p_attribute3,
	              x_attribute4                => p_attribute4,
	              x_attribute5                => p_attribute5,
	              x_attribute6                => p_attribute6,
	              x_attribute7                => p_attribute7,
	              x_attribute8                => p_attribute8,
	              x_attribute9                => p_attribute9,
	              x_attribute10               => p_attribute10,
	              x_attribute11               => p_attribute11,
	              x_attribute12               => p_attribute12,
	              x_attribute13               => p_attribute13,
	              x_attribute14               => p_attribute14,
	              x_attribute15               => p_attribute15,
	              x_comments                  => p_comments,
		      x_group_id                  => line_grp.group_id,
                      x_object_version_number     => 1,
                      x_created_by_module         => 'RAPI',
                      x_reference1                => '',
	              x_reference2                => '',
       	              x_reference3                => '',
	              x_reference4                => '',
	              x_reference5                => ''
			);
 	  End Loop;
       End If;
   -- Line Level
   ELSIF p_llca_type = 'L'
   THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Line Level application... ');
      END IF;

	select count(*)
	into l_gt_count
	from ar_llca_trx_lines_gt
	where customer_trx_id = p_customer_trx_id
	and rownum = 1;

     -- All Lines
     IF  nvl(l_gt_count,0) = 0
     THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('All Lines... ');
      END IF;
       -- Customer Select All lines
       l_cr_unapp_bal		:= Nvl(p_cr_unapp_amount,0);

       For All_lines_row in All_lines_cur (p_customer_trx_id)
       LOOP

	 l_calc_tot_amount_app := Nvl(All_lines_row.line_to_apply,0)
					+ Nvl(All_lines_row.tax_to_apply,0);
        /* Bug 5438627  : Amount in Receipt Currency */
         If p_trans_to_receipt_rate <> 0 then
             l_calc_amount_app_from := arp_util.CurrRound((Nvl(l_calc_tot_amount_app,0) *
                                      nvl(p_trans_to_receipt_rate,0)), p_receipt_currency_code);
         Else
             l_calc_amount_app_from := Nvl(l_calc_tot_amount_app,0);
         End If;

  	 If Nvl(l_cr_unapp_bal,0) = 0
	 Then
	    l_calc_tot_amount_app  := 0;
            l_calc_amount_app_from := 0;
	    l_calc_line_amount	   := 0;
	    l_calc_tax_amount	   := 0;
	 Else
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Customer_trx_line_id   => '||to_char(All_lines_row.line_id));
                arp_util.debug('l_calc_tot_amount_app -> '||to_char(l_calc_tot_amount_app));
                arp_util.debug('l_calc_amount_app_from-> '||to_char(l_calc_amount_app_from));
                arp_util.debug('l_cr_unapp_bal        -> '||to_char(l_cr_unapp_bal));
             END IF;
 	     If Nvl(l_calc_amount_app_from,0) > Nvl(l_cr_unapp_bal,0) Then
	        -- Unapplied balance is non zero and > than amount applied, so default the
		-- Unapplied balance to total amount applied and calculate the line amount as
		-- amount_applied * (line_bal/(line_bal+tax_bal)) and tax_amount =
		-- amount_applied - line_amount

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('l_calc_amount_app_from > l_cr_unapp_bal' );
                   arp_util.debug('Resetting... amount applied and buckets');
                END IF;

		l_calc_amount_app_from :=  Nvl(l_cr_unapp_bal,0);

                If p_trans_to_receipt_rate <> 0 then
                   l_calc_tot_amount_app :=  arp_util.CurrRound((l_cr_unapp_bal/p_trans_to_receipt_rate)
                                           ,p_invoice_currency_code);
                Else
                   l_calc_tot_amount_app := arp_util.CurrRound(l_cr_unapp_bal
                                           ,p_invoice_currency_code);
                End If;


		Select decode ( ( Nvl(All_lines_row.line_to_apply,0)
					 / (Nvl(All_lines_row.line_to_apply,0)
					  + Nvl(All_lines_row.tax_to_apply,0)
				           )
				 ),0,1,
				 ( Nvl(All_lines_row.line_to_apply,0)
					 / (Nvl(All_lines_row.line_to_apply,0)
					  + Nvl(All_lines_row.tax_to_apply,0)
				           )
				 )
			      )
		into l_calc_line_per
		from dual;

		l_calc_line_amount    :=  arp_util.CurrRound((l_calc_tot_amount_app
					  * l_calc_line_per),p_invoice_currency_code);
 	        l_calc_tax_amount     :=  arp_util.CurrRound((Nvl(l_calc_tot_amount_app,0)
		 			  - Nvl(l_calc_line_amount,0))
					  ,p_invoice_currency_code);
 	     Else
		l_calc_line_amount   := Nvl(All_lines_row.line_to_apply,0);
		l_calc_tax_amount    := Nvl(All_lines_row.tax_to_apply,0);
	     End If;

 	    -- Reset the balance
             l_cr_unapp_bal       := Nvl(l_cr_unapp_bal,0) - Nvl(l_calc_amount_app_from,0);

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('l_calc_line_amount   -> '||to_char(l_calc_line_amount));
                arp_util.debug('l_calc_tax_amount    -> '||to_char(l_calc_tax_amount));
                arp_util.debug('l_cr_unapp_bal (R)    => '||to_char(l_cr_unapp_bal));
             END IF;
         End If;

	 ar_activity_details_pkg.insert_row (
                      x_rowid                     => l_rowid,
                      x_cash_receipt_id           => p_cash_receipt_id,
                      x_customer_trx_line_id      => All_lines_row.line_id,
                      x_allocated_receipt_amount  => Nvl(l_calc_amount_app_from,0),
                      x_amount                    => Nvl(l_calc_line_amount,0),
                      x_tax                       => Nvl(l_calc_tax_amount,0),
                      x_line_discount             => '',
                      x_tax_discount              => '',
                      x_line_balance              => All_lines_row.line_to_apply,
                      x_tax_balance               => Nvl(All_lines_row.tax_to_apply,0),
                      x_apply_to                  => All_lines_row.apply_to,
	              x_attribute_category        => p_attribute_category,
	              x_attribute1                => p_attribute1,
    		      x_attribute2                => p_attribute2,
		      x_attribute3                => p_attribute3,
	              x_attribute4                => p_attribute4,
	              x_attribute5                => p_attribute5,
	              x_attribute6                => p_attribute6,
	              x_attribute7                => p_attribute7,
	              x_attribute8                => p_attribute8,
	              x_attribute9                => p_attribute9,
	              x_attribute10               => p_attribute10,
	              x_attribute11               => p_attribute11,
	              x_attribute12               => p_attribute12,
	              x_attribute13               => p_attribute13,
	              x_attribute14               => p_attribute14,
	              x_attribute15               => p_attribute15,
	              x_comments                  => p_comments,
		      x_group_id                  => All_lines_row.group_id,
                      x_object_version_number     => 1,
                      x_created_by_module         => 'RAPI',
                      x_reference1                => '',
	              x_reference2                => '',
       	              x_reference3                => '',
	              x_reference4                => '',
	              x_reference5                => ''
			);
 	  End Loop;
      -- SPECIFIED LINES
      ELSIF  Nvl(l_gt_count,0) > 0
      THEN
	---
       IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Specified one or more lines in PLSQL table... ');
       END IF;

       -- Calculate the line level amounts
       l_cr_unapp_bal		 := Nvl(p_cr_unapp_amount,0);

--bug7311231, start
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validating Value passed for Descriptive Flexfield at line level.');
       END IF;
       For sp_lines_row in gt_lines_cur(p_customer_trx_id)
       LOOP
          l_attribute_rec.attribute_category := sp_lines_row.attribute_category;
	  l_attribute_rec.attribute1 := sp_lines_row.attribute1;
	  l_attribute_rec.attribute2 := sp_lines_row.attribute2;
	  l_attribute_rec.attribute3 := sp_lines_row.attribute3;
	  l_attribute_rec.attribute4 := sp_lines_row.attribute4;
	  l_attribute_rec.attribute5 := sp_lines_row.attribute5;
	  l_attribute_rec.attribute6 := sp_lines_row.attribute6;
	  l_attribute_rec.attribute7 := sp_lines_row.attribute7;
	  l_attribute_rec.attribute8 := sp_lines_row.attribute8;
	  l_attribute_rec.attribute9 := sp_lines_row.attribute9;
	  l_attribute_rec.attribute10 := sp_lines_row.attribute10;
	  l_attribute_rec.attribute11 := sp_lines_row.attribute11;
	  l_attribute_rec.attribute12 := sp_lines_row.attribute12;
	  l_attribute_rec.attribute13 := sp_lines_row.attribute13;
	  l_attribute_rec.attribute14 := sp_lines_row.attribute14;
	  l_attribute_rec.attribute15 := sp_lines_row.attribute15;

          ar_receipt_lib_pvt.Validate_Desc_Flexfield(
                                 l_attribute_rec,
                                 'AR_ACTIVITY_DETAILS',
                                  l_dflex_val_return_status
                                          );

	  If l_dflex_val_return_status <> FND_API.G_RET_STS_SUCCESS Then
	    p_return_status := 'X';
	    ar_receipt_lib_pvt.populate_errors_gt(
	        p_customer_trx_id => p_customer_trx_id,
		p_customer_trx_line_id => sp_lines_row.customer_trx_line_id,
		p_error_message =>
		               'Flexfield Validation at Line Level Failed.',
		p_invalid_value => NULL);
	  End If;
       End Loop;

       If p_return_status = 'X' Then
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Failed: Validation of Descriptive Flexfield at line level.');
          END IF;
          return;
       End If;
--bug7311231, End.

       For sp_lines_row in gt_lines_cur(p_customer_trx_id)
       LOOP
	BEGIN
	select  nvl(line.source_data_key4,0) group_id,
		nvl(line.amount_due_remaining,0),
	        nvl(tax.amount_due_remaining,0)
	into
		l_group_id,
		l_line_amount_remaining,
		l_line_tax_remaining
	from ra_customer_trx_lines line,
	     (select link_to_cust_trx_line_id,
		     line_type,
	             sum(nvl(amount_due_original,0)) amount_due_original,
		     sum(nvl(amount_due_remaining,0)) amount_due_remaining
	      from ra_customer_trx_lines
	      where customer_trx_id =  sp_lines_row.customer_trx_id  -- Bug 7241703 Added condition
	      and nvl(line_type,'TAX') =  'TAX'
	      group by link_to_cust_trx_line_id,line_type
	      ) tax
	where line.customer_Trx_id = sp_lines_row.customer_trx_id
	and   line.customer_trx_line_id = sp_lines_row.customer_trx_line_id
	and line.line_type = 'LINE'
	and line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+);
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	       p_return_status := FND_API.G_RET_STS_ERROR ;
	      FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_TRX_LINE_ID_INVALID');
	      FND_MSG_PUB.ADD;
	      RAISE;
	  WHEN others THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug('' || 'EXCEPTION: validate_llac_insert_ad()');
	    END IF;
	    RAISE;
        END;

            /* Bug 5438627  : Amount in Receipt Currency */
            If p_trans_to_receipt_rate <> 0 then
                  l_calc_amount_app_from := arp_util.CurrRound((Nvl(sp_lines_row.amount_applied,0) *
                                      nvl(p_trans_to_receipt_rate,0)), p_receipt_currency_code);
            Else
                  l_calc_amount_app_from := Nvl(sp_lines_row.amount_applied,0);
            End If;

            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Amount_applied        -> '||to_char(sp_lines_row.amount_applied));
                arp_util.debug('l_calc_amount_app_from-> '||to_char(l_calc_amount_app_from));
                arp_util.debug('l_cr_unapp_bal        -> '||to_char(l_cr_unapp_bal));
            END IF;

	    -- Check the Unapplied balance
            /* Acctd amount will be validated via validate_amount_applied_from, so
                the below validation is not required.
	    If Nvl(l_calc_amount_app_from,0) > Nvl(l_cr_unapp_bal,0)
	    Then
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('l_calc_amount_app_from > l_cr_unapp_bal' );
                   arp_util.debug('Raise an error... amount applied and buckets');
                END IF;
                p_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name ('AR','AR_RW_APP_NEG_UNAPP');
                fnd_msg_pub.Add;
	    End If;  */

 	    -- Reset the balance
            l_cr_unapp_bal       := Nvl(l_cr_unapp_bal,0) - Nvl(l_calc_amount_app_from,0);

            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('l_calc_line_amount   -> '||to_char(l_calc_line_amount));
                arp_util.debug('l_calc_tax_amount    -> '||to_char(l_calc_tax_amount));
                arp_util.debug('l_cr_unapp_bal (R)    => '||to_char(l_cr_unapp_bal));
            END IF;
 ---	End If;
--bug7311231, Picking the flexfield value from ar_llca_trx_lines_gt, for each line.
	ar_activity_details_pkg.insert_row(
	          x_rowid                     => l_rowid,
	          x_cash_receipt_id           => p_cash_receipt_id,
		  x_customer_trx_line_id      => sp_lines_row.customer_trx_line_id,
                  x_allocated_receipt_amount  => Nvl(l_calc_amount_app_from,0),
                  x_amount                    => Nvl(sp_lines_row.line_amount,0),
                  x_tax                       => Nvl(sp_lines_row.tax_amount,0),
	          x_line_discount             => Nvl(sp_lines_row.line_discount,0),
	          x_tax_discount              => Nvl(sp_lines_row.tax_discount,0),
	          x_line_balance              => l_line_amount_remaining,
	          x_tax_balance               => l_line_tax_remaining,
	          x_apply_to                  => sp_lines_row.line_number,
	          x_attribute_category        => sp_lines_row.attribute_category,
	          x_attribute1                => sp_lines_row.attribute1,
    		  x_attribute2                => sp_lines_row.attribute2,
		  x_attribute3                => sp_lines_row.attribute3,
	          x_attribute4                => sp_lines_row.attribute4,
	          x_attribute5                => sp_lines_row.attribute5,
	          x_attribute6                => sp_lines_row.attribute6,
	          x_attribute7                => sp_lines_row.attribute7,
	          x_attribute8                => sp_lines_row.attribute8,
	          x_attribute9                => sp_lines_row.attribute9,
	          x_attribute10               => sp_lines_row.attribute10,
	          x_attribute11               => sp_lines_row.attribute11,
	          x_attribute12               => sp_lines_row.attribute12,
	          x_attribute13               => sp_lines_row.attribute13,
	          x_attribute14               => sp_lines_row.attribute14,
	          x_attribute15               => sp_lines_row.attribute15,
	          x_comments                  => p_comments,
	          x_group_id                  => l_group_id,
	          x_object_version_number     => 1,
	          x_created_by_module         => 'RAPI',
	          x_reference1                => '',
	          x_reference2                => '',
	          x_reference3                => '',
	          x_reference4                => '',
	          x_reference5                => ''
	       );
	End Loop;
	End IF;  /* End of l_gt_count  */

  -- Check for freight amount
     If  NVL(p_freight_amount,0) <> 0
     THEN
	     ar_ll_rcv_summary_pkg.insert_frt_rows(
		    x_cash_receipt_id     => p_cash_receipt_id,
	            x_customer_trx_id     => p_customer_trx_id,
	            x_frt                 => p_freight_amount,
	            x_frt_dsc             => p_freight_discount,
	            x_created_by_module   => 'RAPI'
	            ,x_inv_curr_code      => p_invoice_currency_code
	            ,x_inv_to_rct_rate	  => p_trans_to_receipt_rate
	            ,x_rct_curr_code      => p_receipt_currency_code
	            ,x_comments           => NULL
						);
     END If;

  End If; /* End of LLCA TYPE */

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_llac_insert_ad()-');
  END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: ar_receipt_val_pvt.validate_llac_insert_ad()');
  END IF;
  RAISE;
END validate_llca_insert_ad;

PROCEDURE validate_llca_insert_app(
         p_cash_receipt_id       IN	NUMBER
        ,p_customer_trx_id       IN	NUMBER
        ,p_disc_earn_allowed     IN	NUMBER
        ,p_disc_max_allowed      IN	NUMBER
        ,p_return_status         OUT NOCOPY VARCHAR2
        ,p_msg_count             OUT NOCOPY NUMBER
        ,p_msg_data              OUT NOCOPY VARCHAR2
        ) IS
cursor rcv_lines_cur (p_cust_trx_id in number, p_cash_rec_id in number) is
     select
         trx_lines.line_type,
         trx_lines.source_data_key1 sdk1,
         trx_lines.source_data_key2 sdk2,
         trx_lines.source_data_key3 sdk3,
         trx_lines.source_data_key4 sdk4,
         trx_lines.source_data_key5 sdk5,
         trx_lines.customer_Trx_line_id ctl_id,
         --
         rcv_lines.amount lin,
         rcv_lines.tax tax,
         rcv_lines.freight frt,
         rcv_lines.charges chg,
         --
         --
         rcv_lines.line_discount lin_disc,
         rcv_lines.tax_discount tax_disc,
         rcv_lines.freight_discount frt_disc,
         0 chg_disc,
         --
         rcv_lines.allocated_receipt_amount
     from ar_activity_details rcv_lines,
	  ra_customer_trx_lines trx_lines
     where  trx_lines.customer_trx_id = p_cust_trx_id
       and  rcv_lines.cash_receipt_id = p_cash_rec_id
       and  nvl(rcv_lines.CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- Bug 7241111
       and  trx_lines.line_type = 'LINE'
       and   rcv_lines.customer_trx_line_id = trx_lines.customer_trx_line_id;

cursor rcv_frtchg_cur (pf_ct_id in number, pf_cr_id in number) is
select trx_lines.line_type,
          sum(Nvl(rcv_lines.amount,0)) lin,
          sum(Nvl(rcv_lines.tax,0)) tax,
          sum(Nvl(rcv_lines.freight,0)) frt,
          sum(Nvl(rcv_lines.charges,0)) chg,
          sum(Nvl(rcv_lines.line_discount,0)) lin_disc,
          sum(Nvl(rcv_lines.tax_discount,0))  tax_disc,
          sum(NVl(rcv_lines.freight_discount,0)) frt_disc,
          sum(Nvl(rcv_lines.allocated_receipt_amount,0)) allocated
from ar_Activity_details rcv_lines,
     ra_customer_trx_lines_all trx_lines
where trx_lines.customer_trx_id = pf_ct_id
  and  rcv_lines.cash_receipt_id = pf_cr_id
  and  nvl(rcv_lines.CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- Bug 7241111
  and  trx_lines.line_type in ('FREIGHT','CHARGES')
  and  rcv_lines.customer_trx_line_id = trx_lines.customer_trx_line_id
 group by trx_lines.line_type;


ll_msg_data		varchar2(2000);
ll_return_status	varchar2(1);
ll_msg_count		number;
l_demon 	        NUMBER;
l_calc_ed_line_disc	NUMBER :=0;
l_calc_ued_line_disc    NUMBER :=0;
l_calc_ed_tax_disc	NUMBER :=0;
l_calc_ued_tax_disc     NUMBER :=0;
l_calc_ed_frt_disc	NUMBER :=0;
l_calc_ued_frt_disc     NUMBER :=0;
lf_calc_ed_frt_disc	NUMBER :=0;
lf_calc_ued_frt_disc    NUMBER :=0;
Begin
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_llac_insert_app()+');
  END IF;
  ll_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Execute the application and populate the Line wise details into RA GT
  For rcv_lines_row in rcv_lines_cur (p_customer_trx_id, p_cash_receipt_id)
  LOOP

    l_demon := p_disc_earn_allowed + (p_disc_max_allowed - p_disc_earn_allowed);
    If l_demon <> 0
    Then
     l_calc_ed_line_disc :=  (rcv_lines_row.lin_disc / l_demon) * p_disc_earn_allowed;
     l_calc_ued_line_disc :=  rcv_lines_row.lin_disc - l_calc_ed_line_disc;
     l_calc_ed_tax_disc  :=  (rcv_lines_row.tax_disc / l_demon) * p_disc_earn_allowed;
     l_calc_ued_tax_disc :=  rcv_lines_row.tax_disc - l_calc_ed_tax_disc;
     l_calc_ed_frt_disc  :=  (rcv_lines_row.frt_disc / l_demon) * p_disc_earn_allowed;
     l_calc_ued_frt_disc :=  rcv_lines_row.frt_disc - l_calc_ed_frt_disc;
    End If;

  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Calling Application Execute for Lines and Tax');
      arp_util.debug('Customer Trx Line ID  => '||rcv_lines_row.ctl_id);
      arp_util.debug('Line Amount           => '||rcv_lines_row.lin);
      arp_util.debug('Tax  Amount           => '||rcv_lines_row.Tax);
      arp_util.debug('Freight Amount        => '||rcv_lines_row.frt);
      arp_util.debug('Charges Amount        => '||rcv_lines_row.Chg);
      arp_util.debug('Line Earned Discount  => '||l_calc_ed_line_disc);
      arp_util.debug('Tax  Earned Discount  => '||l_calc_ed_tax_disc);
      arp_util.debug('Frt  Earned Discount  => '||l_calc_ed_frt_disc);
      arp_util.debug('Line UNearned Discount=> '||l_calc_ued_line_disc);
      arp_util.debug('Tax  UNearned Discount=> '||l_calc_ued_tax_disc);
      arp_util.debug('Frt  UNearned Discount=> '||l_calc_ued_frt_disc);
  END IF;
    arp_process_det_pkg.application_execute(
	       p_app_level                      =>'LINE',
               p_source_data_key1               =>rcv_lines_row.sdk1,
               p_source_data_key2               =>rcv_lines_row.sdk2,
               p_source_data_key3               =>rcv_lines_row.sdk3,
               p_source_data_key4               =>rcv_lines_row.sdk4,
               p_source_data_key5               =>rcv_lines_row.sdk5,
               p_ctl_id                         =>rcv_lines_row.ctl_id,
               --
               p_line_applied                   =>rcv_lines_row.lin,
               p_tax_applied                    =>rcv_lines_row.tax,
               p_freight_applied                =>rcv_lines_row.frt,
               p_charges_applied                =>rcv_lines_row.chg,
	       --
               p_line_ediscounted               =>l_calc_ed_line_disc,
	       p_tax_ediscounted                =>l_calc_ed_tax_disc,
               p_freight_ediscounted            =>l_calc_ed_frt_disc,
               p_charges_ediscounted            =>0,
               --
               p_line_uediscounted              =>l_calc_ued_line_disc,
               p_tax_uediscounted               =>l_calc_ued_tax_disc,
               p_freight_uediscounted           =>l_calc_ued_frt_disc,
               p_charges_uediscounted           =>0,
               --
               x_return_status                  =>ll_return_status,
               x_msg_count                      =>ll_msg_count,
               x_msg_data                       =>ll_msg_data);
   End Loop;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_llac_insert_app(Line)+');
   END IF;

IF ll_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ll_return_status := FND_API.G_RET_STS_ERROR;
ELSE
   FOR rcv_frtchg_row in rcv_frtchg_cur (p_customer_trx_id, p_cash_receipt_id)
   LOOP
    l_demon := p_disc_earn_allowed + (p_disc_max_allowed - p_disc_earn_allowed);
    If l_demon <> 0
    Then
     lf_calc_ed_frt_disc  :=  (rcv_frtchg_row.frt_disc / l_demon) * p_disc_earn_allowed;
     lf_calc_ued_frt_disc :=  rcv_frtchg_row.frt_disc - lf_calc_ed_frt_disc;
    End If;
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Calling Application Execute for Freight Lines ');
      arp_util.debug('Line Amount           => '||rcv_frtchg_row.lin);
      arp_util.debug('Tax  Amount           => '||rcv_frtchg_row.Tax);
      arp_util.debug('Freight Amount        => '||rcv_frtchg_row.frt);
      arp_util.debug('Charges Amount        => '||rcv_frtchg_row.Chg);
      arp_util.debug('Frt  Earned Discount  => '||lf_calc_ed_frt_disc);
      arp_util.debug('Frt  UNearned Discount=> '||lf_calc_ued_frt_disc);
    END IF;
             arp_process_det_pkg.application_execute(
               p_app_level                      =>'TRANSACTION',
               p_source_data_key1               =>NULL,
               p_source_data_key2               =>NULL,
               p_source_data_key3               =>NULL,
               p_source_data_key4               =>NULL,
               p_source_data_key5               =>NULL,
               p_ctl_id                         =>NULL,   -- Taxable line id
               --
               p_line_applied                   =>rcv_frtchg_row.lin,
               p_tax_applied                    =>rcv_frtchg_row.tax,
               p_freight_applied                =>rcv_frtchg_row.frt,
               p_charges_applied                =>rcv_frtchg_row.chg,
               --
               p_line_ediscounted               =>0,
	       p_tax_ediscounted                =>0,
               p_freight_ediscounted            =>lf_calc_ed_frt_disc,
               p_charges_ediscounted            =>0,
               --
               p_line_uediscounted              =>0,
               p_tax_uediscounted               =>0,
               p_freight_uediscounted           =>lf_calc_ued_frt_disc,
               p_charges_uediscounted           =>0,
               --
               x_return_status                  =>ll_return_status,
               x_msg_count                      =>ll_msg_count,
               x_msg_data                       =>ll_msg_data);
    END LOOP;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_val_pvt.validate_llac_insert_app()-');
  END IF;

EXCEPTION
WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: ar_receipt_val_pvt.validate_llac_insert_app()');
  END IF;
  RAISE;
END validate_llca_insert_app;

END AR_RECEIPT_VAL_PVT;

/
