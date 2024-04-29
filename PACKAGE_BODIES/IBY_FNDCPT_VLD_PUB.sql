--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_VLD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_VLD_PUB" AS
/* $Header: ibypfcvb.pls 120.4.12010000.4 2009/10/21 08:55:09 sgogula ship $ */

/* ======================================================================*
| Global Data Types                                                     |
* ======================================================================*/
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_VLD_PUB';

-- Package global constants
PG_DEBUG VARCHAR2(1) := nvl(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


--------------- The following are internal procedures ---------------

PROCEDURE validate_zip (
	P_POSTAL_CODE	IN 	VARCHAR2,
	P_COUNTRY_CODE	IN	VARCHAR2,
	X_STATUS	OUT NOCOPY VARCHAR2
) IS
  l_zip_length 	NUMBER;
  l_zip		VARCHAR2(80);
BEGIN
  X_STATUS := 'Y';

  if P_COUNTRY_CODE = 'US' then
     l_zip_length := length(P_POSTAL_CODE);

     if l_zip_length = 5 or l_zip_length = 9 or (l_zip_length = 10 and substr(P_POSTAL_CODE,6,1) = '-') then
        if l_zip_length = 10 then
           l_zip := substr(P_POSTAL_CODE,1,5)||substr(P_POSTAL_CODE,7,4);
        else
           l_zip := P_POSTAL_CODE;
        end if;

        if translate(trim(l_zip),'0123456789','          ') <> rpad(' ',length(trim(l_zip)), ' ') THEN
           X_STATUS := 'N';
        end if;
     else
        X_STATUS := 'N';
     end if;  -- if l_zip_length is 5, 9 or 10 etc.
  end if;

END;  -- procedure validate_zip

--------------- The following are PUBLIC procedures ---------------


-- Validate Citibank credit card batch
PROCEDURE Validate_Citibank_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
) IS
l_api_name	CONSTANT VARCHAR2(30)	:= 'Validate_Citibank_Batch';
l_api_version	CONSTANT NUMBER 	:= 1.0;

l_batchid_size		NUMBER;

l_validzip 		VARCHAR2(1);
l_cust_trx_id		NUMBER;
l_ar_return_status	VARCHAR2(1);
l_ar_msg_count		NUMBER;
l_ar_msg_data		VARCHAR2(2000);
l_ship_to_zip		VARCHAR2(80);
l_ship_to_country	VARCHAR2(10);

cursor level2_trxn is
select	ts.instrtype,
	tc.card_data_level,
	ts.tangibleid,
	tc.instr_owner_postalcode,
	tc.instr_owner_country,
	tc.shipfromzip,
	tc.shiptozip
  from	iby_batches_all b,
  	iby_trxn_summaries_all ts,
  	iby_trxn_core tc
 where	b.mbatchid = P_MBATCH_ID
   and	b.mbatchid = ts.mbatchid
   and	ts.trxnmid = tc.trxnmid;

l_trxn_rec 	 level2_trxn%ROWTYPE;

BEGIN
  -- SAVEPOINT Validate_Paymentech_Batch;

  -- Standard call to check for call compatibility
  if NOT FND_API.Compatible_API_Call( l_api_version,
  				      p_api_version,
  				      l_api_name,
  				      G_PKG_NAME ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.To_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if PG_DEBUG in ('Y', 'C') then
     null; -- iby.debug('some info');
  end if;

  -- Validate BATCH NAME
  select length(batchid)
    into l_batchid_size
    from iby_batches_all
   where mbatchid = P_MBATCH_ID;

  if l_batchid_size > 8 then
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
     FND_MSG_PUB.add;
     FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
     return;
  end if;

  -- Validate POSTAL CODE's
  open level2_trxn;
  loop
     fetch level2_trxn into l_trxn_rec;
     exit when level2_trxn%NOTFOUND;

        if l_trxn_rec.instrtype = 'CREDITCARD' then
           -- Billing postal code
           validate_zip(l_trxn_rec.instr_owner_postalcode,
           		l_trxn_rec.instr_owner_country,
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;

           -- PENDING: MERCHANT_POSTAL_CODE

        elsif l_trxn_rec.instrtype = 'PURCHASECARD' then
           -- Billing postal code
           validate_zip(l_trxn_rec.instr_owner_postalcode,
           		l_trxn_rec.instr_owner_country,
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;

           -- PENDING: MERCHANT_POSTAL_CODE

           /*
           -- Shipping origin postal code: invoiceHeader.sellerPartner.address.postalCode
           validate_zip(l_trxn_rec.shipfromzip,
           		l_trxn_rec.shipfromcountry,  -- this does NOT exist now
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;

           -- Shipping destination postal code: invoiceHeader.buyerPartner.address.postalCode
           validate_zip(l_trxn_rec.shiptozip,
           		l_trxn_rec.shiptocountry,  -- this does NOT exist now
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;
           */

        else
          null;
        end if;  -- instrtype is CREDITCARD, PURCHASECARD, etc.

  end loop;
  close level2_trxn;

  FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);

END; -- procedure Validate_Citibank_Batch


-- Validate FDCNorth credit card batch
PROCEDURE Validate_FDCNorth_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
) IS
l_api_name	CONSTANT VARCHAR2(30)	:= 'Validate_FDCNorth_Batch';
l_api_version	CONSTANT NUMBER 	:= 1.0;

l_payee_id		NUMBER;
l_batch_close_date	DATE;
l_batch_count		NUMBER;
l_doc_line_count	NUMBER;
l_security_code         VARCHAR2(500);

l_validzip 		VARCHAR2(1);
l_cust_trx_id		NUMBER;
l_ar_return_status	VARCHAR2(1);
l_ar_msg_count		NUMBER;
l_ar_msg_data		VARCHAR2(2000);
l_ship_to_zip		VARCHAR2(80);
l_ship_to_country	VARCHAR2(10);

cursor level2_trxn is
select	ts.instrtype,
	tc.card_data_level,
	ts.tangibleid,
	ts.reqtype,
	tc.instr_owner_postalcode,
	tc.instr_owner_country,
	tc.shipfromzip,
	tc.shiptozip
  from	iby_batches_all b,
  	iby_trxn_summaries_all ts,
  	iby_trxn_core tc
 where	b.mbatchid = P_MBATCH_ID
   and	b.mbatchid = ts.mbatchid
   and	ts.trxnmid = tc.trxnmid;

l_trxn_rec 	 level2_trxn%ROWTYPE;

BEGIN
  -- SAVEPOINT Validate_Paymentech_Batch;

  -- Standard call to check for call compatibility
  if NOT FND_API.Compatible_API_Call( l_api_version,
  				      p_api_version,
  				      l_api_name,
  				      G_PKG_NAME ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.To_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if PG_DEBUG in ('Y', 'C') then
     null; -- iby.debug('some info');
  end if;

  /*
   * Fix for bug 5717285:
   *
   * FDC North has a limit on batches per day
   * submitted per security code (this limit
   * is not per payee itself, but per security code).
   *
   * If a company has two payees A and B, and these
   * two payess share the same security code X,
   * then the first batch sent by payee A will have
   * submission sequence id of 1, the first batch
   * submitted by payee B should have submission
   * sequence id of 2 (because the security code is
   * the same).
   */

  -- Validate BATCH COUNT PER SECURITY CODE
  SELECT
    mpayeeid,
    TRUNC(nvl(batchclosedate, SYSDATE))
  INTO
    l_payee_id,
    l_batch_close_date
  FROM
    iby_batches_all
  WHERE
    mbatchid = P_MBATCH_ID
   ;

  /*
   * Find security code for payee
   */
  SELECT
    val.account_option_value
  INTO
    l_security_code
  FROM
    IBY_BEP_ACCT_OPT_VALS val,
    IBY_BEPKEYS           key,
    IBY_PAYEE             payee
  WHERE
    val.bep_account_id = key.bep_account_id
    AND  payee.payeeid = key.ownerid
    AND  val.account_option_code = 'SEC_CODE'
    AND  payee.mpayeeid = l_payee_id
    ;
  /* this sql statement has been replaced by the one below */
  --select count(*)
  --  into l_batch_count
  --  from iby_batches_all
  -- where mpayeeid = l_payee_id
  --   and trunc(batchclosedate) = l_batch_close_date;

  /*
   * Select batch count based on the security code
   * linked to the payee account (not by the
   * payee id itself).
   */

SELECT
   COUNT(*)
INTO
 l_batch_count
FROM
 IBY_BEP_ACCT_OPT_VALS val,
 IBY_BEPKEYS           key,
 IBY_PAYEE             payee,
 IBY_BATCHES_ALL       batch
WHERE
 val.account_option_code = 'SEC_CODE'
 AND
 val.account_option_value = l_security_code
 AND
 val.bep_account_id = key.bep_account_id
 AND
 payee.payeeid = key.ownerid
 AND
 batch.mpayeeid = payee.mpayeeid
 AND
 TRUNC(batchclosedate) = l_batch_close_date
 ;

  if l_batch_count > 9 then
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     FND_MESSAGE.set_token('ERR_OBJECT', 'Batch count per merchant security code');
     FND_MSG_PUB.add;
     FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
     return;
  end if;

  -- Validate TRANSACTION TYPE
  -- Combined into postal code validation. Check for TRANSACTION TYPE

  -- Validate DOCUMENT LINE COUNT for Visa purchase card
  -- Combined into postal code validation. Check for DOCUMENT LINE COUNT

  -- Validate POSTAL CODE's
  open level2_trxn;
  loop
     fetch level2_trxn into l_trxn_rec;
     exit when level2_trxn%NOTFOUND;

        -- Validate TRANSACTION TYPE
        /*
         * Fix for bug 5857483:
         *
         * Added ORAPMTRETURN to the list of valid transaction
         * types.
         */
        if l_trxn_rec.reqtype not in ('ORAPMTCAPTURE', 'ORAPMTCREDIT',
           'ORAPMTRETURN') then
     	   x_return_status := FND_API.G_RET_STS_ERROR;
     	   FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	   FND_MESSAGE.set_token('ERR_OBJECT', 'Transaction type');
     	   FND_MSG_PUB.add;
     	   FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
           return;

        end if;

        if l_trxn_rec.instrtype = 'CREDITCARD' then
           validate_zip(l_trxn_rec.instr_owner_postalcode,
           		l_trxn_rec.instr_owner_country,
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;

        elsif l_trxn_rec.instrtype = 'PURCHASECARD' then

           -- Purchase card level 2
           if l_trxn_rec.card_data_level = 2 then
              -- Billing postal code
              validate_zip(l_trxn_rec.instr_owner_postalcode,
           		   l_trxn_rec.instr_owner_country,
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              /*
              -- Shipping origin postal code
              validate_zip(l_trxn_rec.shipfromzip,
            		   l_trxn_rec.shipfromcountry,  -- this does NOT exist now
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              -- Shipping destination postal code
              validate_zip(l_trxn_rec.shiptozip,
           		   l_trxn_rec.shiptocountry,  -- this does NOT exist now
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;
              */

           -- Purchase card level 3
           elsif l_trxn_rec.card_data_level = 3 then
              -- Billing postal code
              validate_zip(l_trxn_rec.instr_owner_postalcode,
           		   l_trxn_rec.instr_owner_country,
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              -- Shipping-to postal code
              iby_ar_utils.call_get_payment_info(l_trxn_rec.tangibleid,
             					 l_cust_trx_id,
             					 l_ar_return_status,
             					 x_msg_count,
             					 x_msg_data);
              /*
              if l_cust_trx_id = 0 then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              else
             	 begin
             	   -- Validate DOCUMENT LINE COUNT for Visa purchase card
             	   select count(*)
             	     into l_doc_line_count
             	     from ar_invoice_lines_v
             	    where customer_trx_id = l_cust_trx_id;

             	   if l_doc_line_count > 98 then
     		      x_return_status := FND_API.G_RET_STS_ERROR;
     	              FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	              FND_MESSAGE.set_token('ERR_OBJECT', 'Invoice line count for Visa purchase card');
     	              FND_MSG_PUB.add;
     	              FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                      return;
             	   end if;

                   select  hl.postal_code, hl.country
                     into  l_ship_to_zip, l_ship_to_country
                     from  hz_locations hl,
                  	   hz_party_sites hps,
                  	   hz_cust_acct_sites_all hcasa,
                  	   hz_cust_site_uses_all hcsua,
                  	   ar_invoice_header_v arihv
                    where  hl.location_id = hps.location_id and
                 	   hps.party_site_id = hcasa.party_site_id and
                 	   hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and
                 	   hcsua.site_use_id = arihv.ship_to_site_use_id and
                 	   arihv.customer_trx_id = l_cust_trx_id;
                  exception
                    when others then
                      l_ship_to_zip := null;
                      l_ship_to_country := null;
                  end;

                  validate_zip(l_ship_to_zip,
           		       l_ship_to_country,
           		       l_validzip );

                  if l_validzip = 'N' then
     		     x_return_status := FND_API.G_RET_STS_ERROR;
     	             FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	             FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	             FND_MSG_PUB.add;
     	             FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                     return;
                  end if;

               end;  -- l_cust_trx_id has a value
               */
               -- Shipping-from postal code
               -- This validation is NOT added, as shipfromzip is never populated

           else
             null;
           end if;  -- card_data_level is 2, 3 or else

        else
          null;
        end if;  -- instrtype is CREDITCARD, PURCHASECARD, etc.

  end loop;
  close level2_trxn;

  -- Bug 4243738: Added
  if x_return_status = FND_API.G_RET_STS_SUCCESS then
     update iby_batches_all
        set SENTCOUNTERDAILY = l_batch_count
      where mbatchid = P_MBATCH_ID;
  end if;

  FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);

END; -- procedure Validate_FDCNorth_Batch

-- Validate Paymentech credit card batch
PROCEDURE Validate_Paymentech_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
) IS
l_api_name	CONSTANT VARCHAR2(30)	:= 'Validate_Paymentech_Batch';
l_api_version	CONSTANT NUMBER 	:= 1.0;

l_batchid_size		NUMBER;

l_validzip 		VARCHAR2(1);
l_cust_trx_id		NUMBER;
l_ar_return_status	VARCHAR2(1);
l_ar_msg_count		NUMBER;
l_ar_msg_data		VARCHAR2(2000);
l_ship_to_zip		VARCHAR2(80);
l_ship_to_country	VARCHAR2(10);

cursor level2_trxn is
select	ts.instrtype,
	tc.card_data_level,
	ts.tangibleid,
	tc.instr_owner_postalcode,
	tc.instr_owner_country,
	tc.shipfromzip,
	tc.shiptozip
  from	iby_batches_all b,
  	iby_trxn_summaries_all ts,
  	iby_trxn_core tc
 where	b.mbatchid = P_MBATCH_ID
   and	b.mbatchid = ts.mbatchid
   and	ts.trxnmid = tc.trxnmid;

l_trxn_rec 	 level2_trxn%ROWTYPE;

BEGIN
  -- SAVEPOINT Validate_Paymentech_Batch;

  -- Standard call to check for call compatibility
  if NOT FND_API.Compatible_API_Call( l_api_version,
  				      p_api_version,
  				      l_api_name,
  				      G_PKG_NAME ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.To_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if PG_DEBUG in ('Y', 'C') then
     null; -- iby.debug('some info');
  end if;

  -- Validate BATCH NAME
  select length(batchid)
    into l_batchid_size
    from iby_batches_all
   where mbatchid = P_MBATCH_ID;

  if l_batchid_size > 8 then
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
     FND_MSG_PUB.add;
     FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
     return;
  end if;

  -- Validate POSTAL CODE's
  open level2_trxn;
  loop
     fetch level2_trxn into l_trxn_rec;
     exit when level2_trxn%NOTFOUND;

        if l_trxn_rec.instrtype = 'CREDITCARD' then
           validate_zip(l_trxn_rec.instr_owner_postalcode,
           		l_trxn_rec.instr_owner_country,
           		l_validzip );

           if l_validzip = 'N' then
     	      x_return_status := FND_API.G_RET_STS_ERROR;
     	      FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	      FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	      FND_MSG_PUB.add;
     	      FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
              return;
           end if;

        elsif l_trxn_rec.instrtype = 'PURCHASECARD' then

           -- Purchase card level 2
           if l_trxn_rec.card_data_level = 2 then
              -- Billing postal code
              validate_zip(l_trxn_rec.instr_owner_postalcode,
           		   l_trxn_rec.instr_owner_country,
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              /*
              -- Shipping origin postal code
              validate_zip(l_trxn_rec.shipfromzip,
            		   l_trxn_rec.shipfromcountry,  -- this does NOT exist now
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              -- Shipping destination postal code
              validate_zip(l_trxn_rec.shiptozip,
           		   l_trxn_rec.shiptocountry,  -- this does NOT exist now
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;
              */

           -- Purchase card level 3
           elsif l_trxn_rec.card_data_level = 3 then
              -- Billing postal code
              validate_zip(l_trxn_rec.instr_owner_postalcode,
           		   l_trxn_rec.instr_owner_country,
           		   l_validzip );

              if l_validzip = 'N' then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	         FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	         FND_MSG_PUB.add;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              end if;

              -- Shipping-to postal code
              iby_ar_utils.call_get_payment_info(l_trxn_rec.tangibleid,
             					 l_cust_trx_id,
             					 l_ar_return_status,
             					 x_msg_count,
             					 x_msg_data);
              /*
              if l_cust_trx_id = 0 then
     		 x_return_status := FND_API.G_RET_STS_ERROR;
     	         FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                 return;
              else
             	 begin
                   select  hl.postal_code, hl.country
                     into  l_ship_to_zip, l_ship_to_country
                     from  hz_locations hl,
                  	   hz_party_sites hps,
                  	   hz_cust_acct_sites_all hcasa,
                  	   hz_cust_site_uses_all hcsua,
                  	   ar_invoice_header_v arihv
                    where  hl.location_id = hps.location_id and
                 	   hps.party_site_id = hcasa.party_site_id and
                 	   hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and
                 	   hcsua.site_use_id = arihv.ship_to_site_use_id and
                 	   arihv.customer_trx_id = l_cust_trx_id;
                  exception
                    when others then
                      l_ship_to_zip := null;
                      l_ship_to_country := null;
                  end;

                  validate_zip(l_ship_to_zip,
           		       l_ship_to_country,
           		       l_validzip );

                  if l_validzip = 'N' then
     		     x_return_status := FND_API.G_RET_STS_ERROR;
     	             FND_MESSAGE.set_name('IBY','IBY_VALID_IS_INCORRECT');
     	             FND_MESSAGE.set_token('ERR_OBJECT', 'Postal code');
     	             FND_MSG_PUB.add;
     	             FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
                     return;
                  end if;


              end;  -- l_cust_trx_id has a value
              */
              -- Shipping-from postal code
              -- This validation is NOT added, as shipfromzip is never populated

           else
             null;
           end if;  -- card_data_level is 2, 3 or else

        else
          null;
        end if;  -- instrtype is CREDITCARD, PURCHASECARD, etc.

  end loop;
  close level2_trxn;

  FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);

END; -- procedure Validate_Paymentech_Batch


/* Validations on Mandate for SEPA DD */

/*
	To verify that one active direct debit authorization present for customer / customer site at bank account assignment level and its cancellation date has not yet passed
	To verify that the Mandate has the mandatory attributes like Unique Authorization Reference ID, Authorization Signing Date, Payee Legal Entity, Payee Address, Payee Identifier, Customer Address and Customer Identification Code.

*/
PROCEDURE Validate_SEPA_Mandate (
	p_assignment_id		IN	NUMBER,
        x_message 		OUT	NOCOPY	VARCHAR2,
	x_return_status         OUT	NOCOPY	VARCHAR2
) IS

  l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Validate_SEPA_Mandate';

  CURSOR c_mandate (ci_account_use_id IN iby_debit_authorizations.external_bank_account_use_id%TYPE)
  IS
    SELECT  da.authorization_reference_number
            ,da.auth_sign_date
	    ,da.creditor_legal_entity_id
            ,da.creditor_identifier
	    ,da.cust_addr_id
	    ,da.cust_identification_code
	    --,'da.payee_address' -- will be done thru LE API, during UI completion.
      FROM  iby_debit_authorizations da
     WHERE  da.external_bank_account_use_id =  ci_account_use_id
       AND  da.debit_auth_end IS NULL
       AND  da.curr_rec_indi = 'Y';

l_auth_reference_number      iby_debit_authorizations.authorization_reference_number%TYPE;
l_auth_sign_date             iby_debit_authorizations.auth_sign_date%TYPE;
l_creditor_legal_entity_id   iby_debit_authorizations.creditor_legal_entity_id%TYPE;
l_creditor_identifier        iby_debit_authorizations.creditor_identifier%TYPE;
l_cust_addr_id               iby_debit_authorizations.cust_addr_id%TYPE;
l_cust_identification        iby_debit_authorizations.cust_identification_code%TYPE;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
 END IF;

 IF (c_mandate%ISOPEN) THEN CLOSE c_mandate; END IF;

 OPEN c_mandate(p_assignment_id);
 FETCH c_mandate INTO  l_auth_reference_number ,l_auth_sign_date
                      ,l_creditor_legal_entity_id ,l_creditor_identifier
		      ,l_cust_addr_id ,l_cust_identification;

 IF (c_mandate%NOTFOUND) THEN
      x_return_status := 'INVALID';
      x_message := 'NO ACTIVE MANDATE';
 END IF;
 CLOSE c_mandate;

 IF (l_auth_reference_number IS NULL )
 THEN
      x_return_status := 'INVALID';
      x_message := 'UNIQUE AUTH REFERENCE';
 ELSIF (l_auth_sign_date IS NULL )
 THEN
      x_return_status := 'INVALID';
      x_message := 'AUTH SIGN DATE';
 ELSIF (l_creditor_legal_entity_id IS NULL )
 THEN
      x_return_status := 'INVALID';
      x_message := 'Payee LE';
 ELSIF (l_creditor_identifier) IS NULL
 THEN
      x_return_status := 'INVALID';
      x_message := 'Payee Identification';
 ELSIF (l_cust_addr_id IS NULL )
 THEN
      x_return_status := 'INVALID';
      x_message := 'Customer Address';
 ELSIF (l_cust_identification IS NULL )
 THEN
      x_return_status := 'INVALID';
      x_message := 'Customer Identification';
 END IF;

 IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
 END IF;

END;  -- procedure Validate_SEPA_Mandate


-- Validate SEPA DD batch
PROCEDURE Validate_Sepa_DD_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
) IS

l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Validate_Sepa_DD_Batch';
l_api_name	CONSTANT VARCHAR2(30)	:= 'Validate_Sepa_DD_Batch';
l_api_version	CONSTANT NUMBER 	:= 1.0;
 -- TODO: To  verify that Payee Legal Entity Name and Payer Bank Account Name is same as present at its source.
 -- TODO: Payee Address

-- Cursor for settlement records.
cursor  c_settle_trxns is
select	ts.trxnmid
  from	iby_batches_all b
  	,iby_trxn_summaries_all ts
 where	b.mbatchid = P_MBATCH_ID
   and	b.mbatchid = ts.mbatchid ;

-- Cursor to retrieve the certain mandate params.
cursor  c_mandate(ci_trxnmid IN iby_trxn_summaries_all.trxnmid%TYPE)
is
select	ts.creditor_reference
        ,da.authorization_reference_number
        ,da.auth_sign_date
        ,da.creditor_legal_entity_id
        ,da.creditor_identifier
	,da.cust_addr_id
	,da.cust_identification_code
  from	iby_trxn_summaries_all ts
        ,iby_debit_authorizations da
 where	ts.trxnmid = ci_trxnmid
   and  ts.debit_authorization_id  =  da.debit_authorization_id
   and  da.auth_cancel_date is null
   and  da.debit_auth_end is null
   and  da.curr_rec_indi = 'Y' ;

  -- Cursor to retrieve the account option values.
 cursor  c_acct_option_vals
 ( ci_trxnmid IN iby_trxn_summaries_all.trxnmid%TYPE )
 is
 select  vals.account_option_code
         ,vals.account_option_value
   from  iby_trxn_summaries_all ts
         ,iby_bepkeys keys
         ,iby_bep_acct_opt_vals vals
         ,iby_payee payee
  where  ts.trxnmid = ci_trxnmid
    and  ts.payeeid = payee.payeeid
    and  ts.payeeid = keys.ownerid
    and  ts.bepkey = keys.key
    and  keys.ownertype = 'PAYEE'
    and  keys.bep_account_id = vals.bep_account_id (+)
  --  and  vals.account_option_code = ci_acct_option_code;
    and  vals.account_option_code in ('SEPA_INITIATING_PARTY_ID' , 'SEPA_INITIATING_PARTY_ID_ISSUER'
                                      ,'SEPA_INITIATING_PARTY_NAME' ,'SEPA_BATCH_BOOKING' );

 l_trxnmid                    iby_trxn_summaries_all.trxnmid%TYPE;

 l_creditor_reference         iby_trxn_summaries_all.creditor_reference%TYPE;
 l_auth_reference_number      iby_debit_authorizations.authorization_reference_number%TYPE;
 l_auth_sign_date             iby_debit_authorizations.auth_sign_date%TYPE;
 l_creditor_legal_entity_id   iby_debit_authorizations.creditor_legal_entity_id%TYPE;
 l_creditor_identifier        iby_debit_authorizations.creditor_identifier%TYPE;
 l_cust_addr_id               iby_debit_authorizations.cust_addr_id%TYPE;
 l_cust_identification        iby_debit_authorizations.cust_identification_code%TYPE;

 l_ini_party_id               iby_bep_acct_opt_vals.account_option_value%TYPE;
 l_ini_party_id_issuer        iby_bep_acct_opt_vals.account_option_value%TYPE;
 l_ini_party_name             iby_bep_acct_opt_vals.account_option_value%TYPE;
 l_batch_booking_flag         iby_bep_acct_opt_vals.account_option_value%TYPE;

 l_account_option_code        iby_bep_acct_opt_vals.account_option_code%TYPE;
 l_account_option_value       iby_bep_acct_opt_vals.account_option_value%TYPE;


BEGIN

  -- Standard call to check for call compatibility
  if NOT FND_API.Compatible_API_Call( l_api_version,
  				      p_api_version,
  				      l_api_name,
  				      G_PKG_NAME ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.To_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  open c_settle_trxns;
  loop
     fetch c_settle_trxns into l_trxnmid;
     exit when c_settle_trxns%NOTFOUND;

     OPEN c_mandate(l_trxnmid);
     FETCH c_mandate INTO  l_creditor_reference,l_auth_reference_number ,l_auth_sign_date
                      ,l_creditor_legal_entity_id ,l_creditor_identifier
		      ,l_cust_addr_id ,l_cust_identification;

     IF (c_mandate%NOTFOUND) THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Active Debit Authorization is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
	return;
     END IF;
     CLOSE c_mandate;

     /*  checking the mandate attributes */
     IF (l_creditor_reference IS NULL )
     THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Creditor Reference is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
     ELSIF(l_auth_reference_number IS NULL )
     THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Unique Authorization Reference ID is required on Enter Debit Authorization');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
     ELSIF (l_auth_sign_date IS NULL )
     THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Authorization Signing Date is required on Enter Debit Authorization');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_creditor_legal_entity_id IS NULL )
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Payee Legal Entity is required on Enter Debit Authorization');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_creditor_identifier IS NULL )
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Payee Identifier is required on Enter Debit Authorization');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_cust_addr_id IS NULL )
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Customer Address is required on Enter Debit Authorizationd');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_cust_identification IS NULL )
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Customer Identification Code is required on Enter Debit Authorization');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    END IF;

     /*  checking the payment system option */
    l_ini_party_id          := NULL;
    l_ini_party_id_issuer   := NULL;
    l_ini_party_name        := NULL;
    l_batch_booking_flag    := NULL;

    OPEN c_acct_option_vals(l_trxnmid);
    loop
      FETCH c_acct_option_vals INTO l_account_option_code ,l_account_option_value;

      IF (c_acct_option_vals%NOTFOUND) THEN
         EXIT;
      END IF;
      CLOSE c_acct_option_vals;

      IF (l_account_option_code = 'SEPA_INITIATING_PARTY_ID')
      THEN
         l_ini_party_id := l_account_option_value ;
      ELSIF (l_account_option_code = 'SEPA_INITIATING_PARTY_ID_ISSUER')
      THEN
	  l_ini_party_id_issuer := l_account_option_value ;
      ELSIF (l_account_option_code = 'SEPA_INITIATING_PARTY_NAME')
      THEN
   	  l_ini_party_name := l_account_option_value ;
      ELSIF (l_account_option_code = 'SEPA_BATCH_BOOKING')
      THEN
	  l_batch_booking_flag := l_account_option_value ;
      END IF;

    end loop;

    IF (l_ini_party_id IS NULL)
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Initiating Party ID is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_ini_party_id_issuer IS NULL)
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Initiating Party ID Issuer is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_ini_party_name IS NULL)
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Initiating Party Name is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF (l_batch_booking_flag IS NULL)
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Batch Booking is required');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    ELSIF ((l_batch_booking_flag <> 'TRUE') AND (l_batch_booking_flag <> 'FALSE' ))
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.set_name('IBY','Batch Booking is Invalid');
	FND_MESSAGE.set_token('ERR_OBJECT', 'Batch name');
	FND_MSG_PUB.add;
	FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);
    END IF;

      /* End of checking the payment system option */

  end loop;
  close c_settle_trxns;

  FND_MSG_PUB.Count_And_Get('T',x_msg_count,x_msg_data);

END; -- procedure Validate_Sepa_DD_Batch


END IBY_FNDCPT_VLD_PUB;

/
