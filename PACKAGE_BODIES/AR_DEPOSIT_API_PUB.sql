--------------------------------------------------------
--  DDL for Package Body AR_DEPOSIT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DEPOSIT_API_PUB" AS
/* $Header: ARXCDEPB.pls 120.26.12010000.2 2008/11/13 16:11:49 pbapna ship $           */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'AR_DEPOSIT_API_PUB';
G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
PG_DEBUG        VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

 FUNCTION CurrRound( p_amount IN number,
                      p_currency_code IN varchar2) RETURN NUMBER;

 FUNCTION CurrRound( p_amount IN number,
                      p_currency_code IN varchar2) RETURN NUMBER IS


        l_precision           NUMBER(1);
        l_extended_precision  NUMBER;
        l_mau                 NUMBER;

  BEGIN
        fnd_currency.Get_Info( p_currency_code,
                               l_precision,
                               l_extended_precision,
                               l_mau );

       IF l_mau IS NOT NULL
        THEN
            RETURN( ROUND( p_amount / l_mau) * l_mau );
        ELSE
            RETURN( ROUND( p_amount, l_precision ));
        END IF;

    RETURN NULL; EXCEPTION
        WHEN OTHERS THEN
            RAISE;
  END CurrRound;


/*========================================================================
| Prototype Declarations Procedures
| This routine initialize_profile_globals is used to set the profile option
| values in the corresponding package global variables. This kind of approach
| was adopted to enable the testing routine to assign different testcase values
| to the package global variables having the profile option values. So when we
| run the testing routine, the profile option package variables are overidden
| and the procedure initialize_profile_globals would not do any initialization
| in that case
 *============================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE initialize_profile_globals
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |      This procedure does the following: Initialize all profile option values
 |      required by AR_DEPOSIT_API_PUB.Create_Deposit to create deposit.
 |      Values are set at public variables in ar_deposit_lib_pvt package spec
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |      AR_DEPOSIT_API_PUB.Create_Deposit
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      fnd_profile.value
 |
 | PARAMETERS
 |
 |          None
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-MAY-2001           Anuj              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
PROCEDURE initialize_profile_globals IS
  l_dummy varchar2(1);
  BEGIN
  arp_util.debug('AR_DEPOSIT_API_PUB.initialize_profile_globals()+ ');
  IF ar_deposit_lib_pvt.pg_profile_batch_source = FND_API.G_MISS_NUM  THEN
     ar_deposit_lib_pvt.pg_profile_batch_source
                       := fnd_profile.value('AR_RA_BATCH_SOURCE');
    --To make sure that Batch derived from profile option belongs to same org
   BEGIN
     IF ar_deposit_lib_pvt.pg_profile_batch_source is not null then
       select 'X' into l_dummy
       from ra_batch_sources
       where batch_source_id = ar_deposit_lib_pvt.pg_profile_batch_source;
    end if;
   EXCEPTION
       when others then
         ar_deposit_lib_pvt.pg_profile_batch_source := null;
   END;

  END IF;

  IF ar_deposit_lib_pvt.pg_profile_doc_seq = FND_API.G_MISS_CHAR THEN
     ar_deposit_lib_pvt.pg_profile_doc_seq
                       := fnd_profile.value('UNIQUE:SEQ_NUMBERS');
  END IF;

  IF ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag = FND_API.G_MISS_CHAR THEN
      ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag
                        := fnd_profile.value('ZX_ALLOW_TRX_LINE_EXEMPTIONS');
  END IF;

 -- Profile option AR_ENABLE_CROSS_CURRENCY has been obsolited instead it
 -- now always state 'Y'
 -- IF ar_deposit_lib_pvt.pg_profile_enable_cc = FND_API.G_MISS_CHAR THEN
      ar_deposit_lib_pvt.pg_profile_enable_cc := 'Y';
 --                      := fnd_profile.value('AR_ENABLE_CROSS_CURRENCY');
 -- END IF;


   IF ar_deposit_lib_pvt.pg_profile_cc_rate_type = FND_API.G_MISS_CHAR  THEN
      ar_deposit_lib_pvt.pg_profile_cc_rate_type
                       := ar_setup.value('AR_CROSS_CURRENCY_RATE_TYPE',null);
   -- null should be replaced with org_id, to find profile for diffrent org
   END IF;

   IF ar_deposit_lib_pvt.pg_profile_dsp_inv_rate = FND_API.G_MISS_CHAR  THEN
      ar_deposit_lib_pvt.pg_profile_dsp_inv_rate
                       := fnd_profile.value('DISPLAY_INVERSE_RATE');
   END IF;

   IF ar_deposit_lib_pvt.pg_profile_def_x_rate_type = FND_API.G_MISS_CHAR  THEN
      ar_deposit_lib_pvt.pg_profile_def_x_rate_type
                        := fnd_profile.value('AR_DEFAULT_EXCHANGE_RATE_TYPE');
   END IF;

  arp_util.debug('pg_profile_enable_cc        :'
                         ||ar_deposit_lib_pvt.pg_profile_enable_cc);
  arp_util.debug('pg_profile_trxln_excpt_flag :'
                         ||ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag);
  arp_util.debug('pg_profile_doc_seq          :'
                         || ar_deposit_lib_pvt.pg_profile_doc_seq);
  arp_util.debug('pg_profile_batch_source     :'
                         ||ar_deposit_lib_pvt.pg_profile_batch_source);
  arp_util.debug('pg_profile_def_x_rate_type  :'
                         ||ar_deposit_lib_pvt.pg_profile_def_x_rate_type);
  arp_util.debug('pg_profile_dsp_inv_rate     :'
                         ||ar_deposit_lib_pvt.pg_profile_dsp_inv_rate);
  arp_util.debug('pg_profile_cc_rate_type     :'
                         ||ar_deposit_lib_pvt.pg_profile_cc_rate_type);

   arp_util.debug('AR_DEPOSIT_API_PUB.initialize_profile_globals()- ');

 END initialize_profile_globals;

/*========================================================================
 | PUBLIC PROCEDURE CREATE_DEPOSIT
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |     This procedure does the following ......
 |     This routine is called to create deposit for the Transactions.
 |     This API routine has  8 output and 136 input parameters in total.
 |     As of some of the Out NOCOPY parameters, the API returns are Customer_trx_id ,
 |     Customer_trx_line_id, new  trx_number,  if generated during deposit
 |     creation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |      It will be used by ideposit UI's
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      arp_util.debug(
 |      FND_API.Compatible_API_Call
 |      FND_API.G_EXC_UNEXPECTED_ERROR
 |      FND_API.to_Boolean
 |      FND_MSG_PUB.initialize
 |      AR_DEPOSIT_LIB_PVT.Default_deposit_ids
 |      AR_DEPOSIT_LIB_PVT.Get_deposit_Defaults
 |      ar_deposit_val_pvt.Validate_Deposit
 |      Arp_trx_defaults.get_header_defaults
 |      ARP_TRX_VALIDATE.val_and_dflt_pay_mthd_and_bank
 |      ar_deposit_lib_pvt.Validate_Desc_Flexfield
 |      ar_deposit_lib_pvt.get_doc_seq
 |      FND_MSG_PUB.Count_And_Get
 |      arp_process_header_insrt_cover.insert_header_cover
 |      FND_MESSAGE.SET_NAME
 |      FND_MSG_PUB.Add;
 |      arp_process_header.post_commit
 |
 | PARAMETERS
 | Parameter		Type	Description
 | p_api_version	IN	Used to compare version numbers of
 |                              incoming calls to its current version
 |                              number.
 |p_init_msg_list       IN	Allows API callers to request that the API does
 |                              initialization of the
                                message list on their behalf.
 |p_commit		IN	Used by API callers to ask the API to commit on
 |				their behalf.
 |p_validation_level	IN 	Not to be used currently as this is a public API .
 |x_return_status  	OUT NOCOPY     Represents the API overall return status.
 |x_msg_count		OUT NOCOPY	Number of messages in the API message list
 |x_msg_data		OUT NOCOPY	This is the message in encoded format
 |				if x_msg_count=1
 |
 |2. Parameters relevant to the deposit
 |
 |Parameter		Type	Description
 |p_deposit_number	IN	The deposit number of the deposit to be created.
 |p_deposit_date	IN	The Deposit date of the entered deposit.
 |p_usr_currency_code	IN	The translated currency code.Used to derive the
 |				p_currency_code
 |                              if it is not entered
 |p_currency_code	IN	The actual currency code that gets stored in
 |				AR tables.
 |p_usr_exchange_rate_type IN	The translated exchange rate type.Used to derive
 |				the p_exchange_rate_type
 |                              if it has not been entered.
 |p_exchange_rate_type	IN	Exchange rate type stored in AR tables.
 |p_exchange_rate	IN	The exchange rate between the receipt currency
 |				and the functional currency.
 |p_exchange_rate_date	IN	The date on which the exchange rate is valid.
 |p_batch_source_id	IN	Batch source identifier for the commitment
 |p_batch_source_name	IN	Batch source name for the commitment
 |p_cust_trx_type_id	IN	Transaction Type identifier
 |p_cust_trx_type	IN	Transaction Type name
 |p_class		IN	It is constant value = "DEP", for
 |				future enhancement.
 |p_gl_date		IN	Date that this deposit will be posted to
 |				the General Ledger.
 |
 |p_bill_to_customer_id	 	IN	The customer_id for the bill
 |					to  customer.
 |p_bill_to_customer_name 	IN	The name for the entered customer.
 |p_bill_to_customer_number 	IN	The number for the entered customer.
 |p_bill_to_location		IN	The Location for the bill to  customer.
 |p_bill_to_contact_id		IN	The contact identifier for the bill
 |					to  customer.
 |p_bill_to_contact_first_name	IN	The first name of contact for the
 |					bill to  customer.
 |p_bill_to_contact_last_name	IN	The last name of contact for the
 |					bill to  customer.
 |p_ship_to_customer_id		IN	The customer_id for the ship
 |					to  customer.
 |p_ship_to_customer_name	IN	The name for the entered customer.
 |p_ship_to_customer_number	IN	The number for the entered customer.
 |p_ship_to_location		IN	The Location for the bill to  customer.
 |p_ship_to_contact_id		IN	The contact identifier for the bill
 |					to  customer.
 |p_ship_to_contact_first_name	IN	The first name of contact for the
 |                                      bill to  customer.
 |p_ship_to_contact_last_name	IN	The last name of contact for the bill
 |					to  customer.
 |p_term_id			IN	Payment terms identifier for the
 |					transactions.
 |p_term_name			IN	Payment terms name for the transactions.
 |p_salesrep_id			IN	Salesrep identifier for transactions.
 |p_salesrep_name		IN	Salesrep name for the transactions.
 |p_interface_header_context	IN	Interface header context
 |p_interface_header_attribute1
 |to
 |p_interface_header_attribute15
 |                              IN	Interface header attribute
 |p_attribute_category		IN	Descriptive Flexfield structure
 |					defining column
 |p_attribute1top_attribute15	IN	Descriptive Flexfield segment column
 |
 |p_global_attr_cust_rec	IN	This is a record type which contains
 |                                      all the 25 global descriptive
 |                                      flexfield segments and One global
 |                                      descriptive flexfield structure
 |					defining column.
 |p_document_number		IN	Value assigned to document receipt.
 |p_ussgl_transaction_code	IN	Code defined by Public Sec. accounting.
 |p_printing_option		IN	Printing option for the invoice
 |p_default_tax_exempt_flag	IN	Tax exempt flag.
 |p_status_trx			IN	Status of the transaction
 |p_financial_charges		IN	To indicate whether financial charges
 |					are calculated.
 |p_agreement_id		IN	Agreement associated with transaction
 |					for the customer.
 |p_special_instructions	In	Any special instruction for the
 |					transaction uptp 240 character.
 |p_comments		        IN      User comments
 |p_purchase_order		In	Perchase order number
 |p_purchase_order_revision	In	Perchase order revision number
 |p_purchase_order_date		In	Perchase order date
 |p_remit_to_address_id		In	Remit to address id for the customer
 |p_sold_to_customer_id		IN	The customer_id for the sold to  customer.
 |p_sold_to_customer_name	IN	The name for the entered/defaulted
 |					sold to customer.
 |p_sold_to_customer_number	IN	The number for the entered/defaulted
 |					sold to customer.
 |p_paying_customer_id		IN      The customer_id associated with the
 |					customer bank account assigned
 |                                      to your transaction
 |p_paying_customer_name	IN      The name for the entered/defaulted
 |					paying customer
 |p_paying_customer_number	IN	The number for the entered/defaulted
 |					paying customer
 |p_paying_location		IN	The Location for the paying  customer
 |p_receipt_method_name		IN	The Payment method name of transactions.
 |p_cust_bank_account_id	IN	Customer bank account  identifier.
 |p_cust_bank_account_name	IN	Customer bank account  name.
 |p_cust_bank_account_number	IN	Customer bank account  number.
 |p_start_date_commitment	IN	Start date of commitment
 |p_end_date_commitment	IN	End date of commitment
 |p_amount			IN	Deposit amount
 |p_inventory_id		IN	Item id of commitment,
 |				****	You can enter item id or Memo line id
 |p_memo_line_id		IN	Memo line id
 |p_memo_line_name		IN	Deposit amount
 |p_description			IN	Description of deposit
 |p_comm_interface_line_context	IN	Interface line context,for deposit
 |p_comm_interface_line_attr1
 |to
 |p_comm_interface_line_attr15	In	Interface line attribute value
 |p_global_attr_cust_lines_rec	In	This is a record type which contains all
 |					the 25 global descriptive flexfield
 |					segments for deposit lines and
 |					One global descriptive flexfield
 |					structure defining column.
 |p_owner_id			In	Id of the commitment owner
 |p_owners_name			In	Name of the commitment owner
 |X_new_trx_number		Out NOCOPY	New transaction no if generated
 |X_new_customer_trx_id		Out NOCOPY	New customer_trx_id of the deposit
 |					being created
 |X_new_customer_trx_line_id	Out NOCOPY	New customer_trx_line_id of the
 |					deposit being created
 |X_new_rowid			Out NOCOPY	Rowid of the deposit being created
 | KNOWN ISSUES
 |      Enter business functionality which was de-scoped as part of the
 |      implementation. Ideally this should never be used.
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


PROCEDURE CREATE_DEPOSIT(
           -- Standard API parameters.
                 p_api_version      IN  NUMBER,
                 p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE,
                 p_commit           IN  VARCHAR2 := FND_API.G_TRUE,
                 p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 x_return_status    OUT NOCOPY VARCHAR2,
                 x_msg_count        OUT NOCOPY NUMBER,
                 x_msg_data         OUT NOCOPY VARCHAR2,

                 -- Commitment, deposit info. parameters
                 p_deposit_number               IN  VARCHAR2,
                 p_deposit_date                 IN  DATE     DEFAULT trunc(sysdate),
                 p_usr_currency_code            IN  VARCHAR2 DEFAULT NULL,
                 p_currency_code                IN  VARCHAR2 DEFAULT NULL,
                 p_usr_exchange_rate_type       IN  VARCHAR2 DEFAULT NULL,
                 p_exchange_rate_type           IN  VARCHAR2 DEFAULT NULL,
                 p_exchange_rate                IN  NUMBER   DEFAULT NULL,
                 p_exchange_rate_date           IN  DATE     DEFAULT NULL,
                 p_batch_source_id              IN  NUMBER   DEFAULT NULL,
                 p_batch_source_name            IN  VARCHAR2 DEFAULT NULL,
                 p_cust_trx_type_id             IN  NUMBER   DEFAULT NULL,
                 p_cust_trx_type                IN  VARCHAR2 DEFAULT NULL,
                 p_class                        IN  VARCHAR2 DEFAULT 'DEP',
                 p_gl_date                      IN  DATE     DEFAULT trunc(sysdate),
                 p_bill_to_customer_id          IN  NUMBER   DEFAULT NULL,
                 p_bill_to_customer_name        IN  VARCHAR2 DEFAULT NULL,
                 p_bill_to_customer_number      IN  VARCHAR2 DEFAULT NULL,
                 p_bill_to_location             IN  VARCHAR2 DEFAULT NULL,
                 p_bill_to_contact_id           IN  NUMBER   DEFAULT NULL,
                 p_bill_to_contact_first_name   IN  VARCHAR2 DEFAULT NULL,
                 p_bill_to_contact_last_name    IN  VARCHAR2 DEFAULT NULL,
                 p_ship_to_customer_id          IN  NUMBER   DEFAULT NULL,
                 p_ship_to_customer_name        IN  VARCHAR2 DEFAULT NULL,
                 p_ship_to_customer_number      IN  VARCHAR2 DEFAULT NULL,
                 p_ship_to_location             IN  VARCHAR2 DEFAULT NULL,
                 p_ship_to_contact_id           IN  NUMBER   DEFAULT NULL,
                 p_ship_to_contact_first_name   IN  VARCHAR2 DEFAULT NULL,
                 p_ship_to_contact_last_name    IN  VARCHAR2 DEFAULT NULL,
                 p_term_id                      IN  NUMBER    DEFAULT NULL,
                 p_term_name                    IN  VARCHAR2  DEFAULT NULL,
                 p_salesrep_id                  IN  NUMBER    DEFAULT NULL,
                 p_salesrep_name                IN  VARCHAR2  DEFAULT NULL,
               --flexfeild for Header
                 p_interface_header_context       IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute1    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute2    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute3    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute4    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute5    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute6    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute7    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute8    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute9    IN VARCHAR2  DEFAULT NULL,
                 p_interface_header_attribute10   IN VARCHAR2 DEFAULT NULL,
                 p_interface_header_attribute11   IN  VARCHAR2 DEFAULT NULL,
                 p_interface_header_attribute12   IN VARCHAR2 DEFAULT NULL,
                 p_interface_header_attribute13   IN VARCHAR2 DEFAULT NULL,
                 p_interface_header_attribute14   IN VARCHAR2 DEFAULT NULL,
                 p_interface_header_attribute15   IN  VARCHAR2 DEFAULT NULL,

                 p_attribute_category       IN      VARCHAR2  DEFAULT NULL,
                 p_attribute1               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute2               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute3               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute4               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute5               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute6               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute7               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute8               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute9               IN      VARCHAR2 DEFAULT NULL,
                 p_attribute10              IN      VARCHAR2 DEFAULT NULL,
                 p_attribute11              IN      VARCHAR2 DEFAULT NULL,
                 p_attribute12              IN      VARCHAR2 DEFAULT NULL,
                 p_attribute13              IN      VARCHAR2 DEFAULT NULL,
                 p_attribute14              IN      VARCHAR2 DEFAULT NULL,
                 p_attribute15              IN      VARCHAR2 DEFAULT NULL,
                -- ******* Global Flexfield parameters *******
                 p_global_attr_cust_rec       IN global_attr_rec_type
                                              DEFAULT g_attr_cust_rec_const,

                 p_document_number            IN  VARCHAR2  DEFAULT NULL,
                 p_ussgl_transaction_code     IN  VARCHAR2  DEFAULT NULL,
		 p_printing_option            IN  VARCHAR2  DEFAULT 'PRI',
                 p_default_tax_exempt_flag    IN  VARCHAR2  DEFAULT 'S',
                 p_status_trx                 IN  VARCHAR2  DEFAULT NULL,
                 p_financial_charges          IN  VARCHAR2  DEFAULT NULL,
                 p_agreement_id               IN  NUMBER    DEFAULT NULL,
                 p_special_instructions       IN  VARCHAR2  DEFAULT NULL,
                 p_comments                   IN  VARCHAR2  DEFAULT NULL,
                 p_purchase_order             IN  VARCHAR2  DEFAULT NULL,
                 p_purchase_order_revision    IN  VARCHAR2  DEFAULT NULL,
                 p_purchase_order_date        IN  DATE      DEFAULT NULL,
                 p_remit_to_address_id        IN  NUMBER    DEFAULT NULL,
                 p_sold_to_customer_id        IN  NUMBER    DEFAULT NULL,
                 p_sold_to_customer_name      IN  VARCHAR2  DEFAULT NULL,
                 p_sold_to_customer_number    IN  VARCHAR2  DEFAULT NULL ,
                 p_paying_customer_id         IN  NUMBER    DEFAULT NULL,
                 p_paying_customer_name       IN  VARCHAR2  DEFAULT NULL,
                 p_paying_customer_number     IN  VARCHAR2  DEFAULT NULL ,
                 p_paying_location            IN  VARCHAR2  DEFAULT NULL,
                 p_receipt_method_id          IN  NUMBER    DEFAULT NULL,
                 p_receipt_method_name        IN  VARCHAR2  DEFAULT NULL ,
                 p_cust_bank_account_id       IN  NUMBER    DEFAULT NULL,
                 p_cust_bank_account_name     IN  VARCHAR2  DEFAULT NULL ,
                 p_cust_bank_account_number   IN  VARCHAR2  DEFAULT NULL ,
                 p_start_date_commitment     IN  DATE      DEFAULT NULL,
                 p_end_date_commitment       IN  DATE      DEFAULT NULL,
                 p_amount                     IN  NUMBER,
                 p_inventory_id               IN  NUMBER    DEFAULT NULL,
                 p_memo_line_id               IN  NUMBER    DEFAULT NULL,
                 p_memo_line_name             IN  VARCHAR2  DEFAULT NULL,
                 p_description                IN  VARCHAR2  DEFAULT NULL,
                --flexfeild for Lines
                 p_comm_interface_line_context  IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr1    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr2    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr3    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr4    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr5    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr6    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr7    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr8    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr9    IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr10   IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr11   IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr12   IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr13   IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr14   IN VARCHAR2  DEFAULT NULL,
                 p_comm_interface_line_attr15   IN VARCHAR2  DEFAULT NULL,

             -- ******* Global Flexfield parameters *******
                 p_global_attr_cust_lines_rec
                                  IN global_attr_rec_type
                                  DEFAULT g_attr_cust_lines_rec_const,
                 p_org_id                       IN  NUMBER   DEFAULT NULL,
                 p_payment_trxn_extension_id    IN  NUMBER   DEFAULT NULL,
            --   ** OUT NOCOPY variables
                 X_new_trx_number           OUT NOCOPY
                                ra_customer_trx.trx_number%type,
                 X_new_customer_trx_id      OUT NOCOPY
                                ra_customer_trx.customer_trx_id%type,
                 X_new_customer_trx_line_id OUT NOCOPY
                                ra_customer_trx_lines.customer_trx_line_id%type,
                 X_new_rowid                OUT NOCOPY  VARCHAR2 ) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name       CONSTANT VARCHAR2(20) := 'Create_Deposit';
    l_api_version    CONSTANT NUMBER       := 1.0;

    l_deposit_number             ra_customer_trx_all.trx_number%type;
    l_default_batch_source_id     ra_batch_sources.batch_source_id%type;
    l_default_batch_source_name   ra_batch_sources.name%type;
    l_auto_trx_numbering_flag     ra_batch_sources.auto_trx_numbering_flag%type;
    l_batch_source_type           ra_batch_sources.batch_source_type%type;
    l_copy_doc_number_flag 	  ra_batch_sources.copy_doc_number_flag%type;
    l_bs_default_cust_trx_type_id
                                  ra_cust_trx_types.cust_trx_type_id%type;
    l_default_cust_trx_type_id    ra_cust_trx_types.cust_trx_type_id%type;
    l_default_type_name           ra_cust_trx_types.name%type;
    l_class                       ra_cust_trx_types.type%type;
    l_open_receivables_flag       ra_cust_trx_types.accounting_affect_flag%type;
    l_post_to_gl_flag             ra_cust_trx_types.post_to_gl%type;
    l_allow_freight_flag          ra_cust_trx_types.allow_freight_flag%type;
    l_creation_sign               ra_cust_trx_types.creation_sign%type;
    l_dft_tax_calculation_flag    ra_cust_trx_types.tax_calculation_flag%type;
    l_tax_calculation_flag        ra_cust_trx_types.tax_calculation_flag%type;
    l_default_status_code         ar_lookups.lookup_code%type;
    l_default_status              ar_lookups.meaning%type;
    l_status_trx                  ar_lookups.meaning%type;
    l_default_printing_option     ar_lookups.meaning%type;
    l_printing_option             ar_lookups.lookup_code%type;
    l_default_term_id             ra_terms.term_id%type;
    l_default_term_name           ra_terms.name%type;
    l_number_of_due_dates         number;
    l_term_due_date               date;
    l_default_gl_date             date;
    l_gd_default_gl_date          date;
    l_ctt_default_ctrx_type_id    ra_cust_trx_types.cust_trx_type_id%type;
    l_ctt_default_type_name       ra_cust_trx_types.name%type;
    l_ctt_bs_default_type_name    ra_cust_trx_types.name%type;
    l_batch_source_id             ra_batch_sources.batch_source_id%type;
    l_cust_trx_type_id            ra_cust_trx_types.cust_trx_type_id%type;
    l_term_id                     ra_terms.term_id%type;
    l_salesrep_id                 ra_salesreps.salesrep_id%type;
    l_default_salesrep_id         ra_salesreps.salesrep_id%type;
    l_dft_bill_to_contact_id      Number;
    l_printing_pending            ra_customer_trx_all.printing_pending%type;
    l_doc_sequence_id             NUMBER;
    l_doc_sequence_value          VARCHAR2(50);
    l_attribute_rec               attr_rec_type;
    l_hd_attribute_rec            attr_rec_type;
    l_in_comm_attribute_rec       attr_rec_type;
    l_new_trx_number              ra_customer_trx.trx_number%type;
    l_new_customer_trx_id         ra_customer_trx.customer_trx_id%type;
    l_new_rowid                   varchar(18);
    l_bill_to_customer_id         ra_customer_trx.bill_to_customer_id%type;
    l_bill_to_customer_name       hz_parties.party_name%type;
    l_bill_to_customer_number     hz_cust_accounts.account_number%type;
    l_bill_to_location            hz_cust_site_uses.location%type;
    l_bill_to_site_use_id         ra_customer_trx.bill_to_site_use_id%type;
    l_bill_to_contact_id          ra_customer_trx.bill_to_contact_id%type;
    l_bill_to_contact_first_name  hz_parties.person_first_name%type;
    l_bill_to_contact_last_name   hz_parties.person_last_name%type;
    l_ship_to_customer_id         ra_customer_trx.ship_to_customer_id%type;
    l_ship_to_customer_name       hz_parties.party_name%type;
    l_ship_to_customer_number     hz_cust_accounts.account_number%type;
    l_ship_to_location            hz_cust_site_uses.location%type;
    l_ship_to_site_use_id         ra_customer_trx.ship_to_site_use_id%type;
    l_ship_to_contact_id          ra_customer_trx.ship_to_contact_id%type;
    l_ship_to_contact_first_name  hz_parties.person_first_name%type;
    l_ship_to_contact_last_name   hz_parties.person_last_name%type;
    l_usr_currency_code           ra_customer_trx.invoice_currency_code%type;
    l_usr_exchange_rate_type      ra_customer_trx.exchange_rate_type%type;
    l_currency_code               ra_customer_trx.invoice_currency_code%type;
    l_exchange_rate_type          ra_customer_trx.exchange_rate_type%type;
    l_exchange_rate               ra_customer_trx.exchange_rate%type;
    l_exchange_rate_date          ra_customer_trx.exchange_date%type;
    l_amount                      NUMBER;
    l_memo_line_id                NUMBER;
    l_memo_line_name              VARCHAR2(240);
    l_inventory_id                NUMBER;
    l_deposit_date                Date;
    l_gl_date                     Date;
    l_remit_to_address_id         ra_customer_trx.remit_to_address_id%type;
    l_cust_location_site_num      hz_cust_acct_sites.cust_acct_site_id%type;
    l_sold_to_customer_id         ra_customer_trx.bill_to_customer_id%type;
    l_sold_to_customer_name       hz_parties.party_name%type;
    l_sold_to_customer_number     hz_cust_accounts.account_number%type;
    l_start_date_commitmenmt      DATE;
    l_end_date_commitmenmt        DATE;
    l_paying_customer_id          ra_customer_trx.ship_to_customer_id%type;
    l_paying_customer_name        hz_parties.party_name%type;
    l_paying_customer_number      hz_cust_accounts.account_number%type;
    l_paying_location             hz_cust_site_uses.location%type;
    l_paying_site_use_id          ra_customer_trx.ship_to_site_use_id%type;
    l_receipt_method_id           ra_customer_trx.receipt_method_id%type;
    l_receipt_method_name         ar_receipt_methods.name%type;
    l_cust_bank_account_id        ra_customer_trx.customer_bank_account_id%type;
    l_cust_bank_account_name      ap_bank_accounts.bank_account_name%type;
    l_cust_bank_account_number    ap_bank_accounts.bank_account_num%type;
    l_agreement_id                ra_customer_trx.agreement_id%type;
    l_fin_payment_method_name     ar_receipt_methods.name%type;
    l_fin_receipt_method_id       ra_customer_trx.receipt_method_id%type;
    l_fin_creation_method_code    ar_receipt_classes.creation_method_code%type;
    l_fin_bank_account_num        ap_bank_accounts.bank_account_num%type;
    l_fin_bank_name               ce_bank_branches_v.bank_name%type;
    l_fin_bank_branch_name        ce_bank_branches_v.bank_branch_name%type;
    l_fin_bank_branch_id          ce_bank_branches_v.branch_party_id%TYPE;
    l_financial_charges           ra_customer_trx.finance_charges%type;

    --*******status
    l_receipt_method_status       VARCHAR2(1000);
    l_bank_acct_status            VARCHAR2(1000);
    l_post_commit_status          VARCHAR2(1000);
    l_return_val_status           VARCHAR2(1000);
    l_new_status                  VARCHAR2(1000);
    l_return_status               VARCHAR2(1000);
    l_doc_seq_status              VARCHAR2(1000);
    l_cdflex_val_return_status    VARCHAR2(1000);
    l_dflex_val_return_status     VARCHAR2(1000);
    l_intflex_val_return_status   VARCHAR2(1000);  /* Bug 4895995 FP Bug 5467022 */
    l_id_return_status            VARCHAR2(1000);
    l_dft_return_status           VARCHAR2(1000);
    l_dummy                       NUMBER;
    l_fin_customer_bank_account_id
                   ra_customer_trx.customer_bank_account_id%type;
    l_new_customer_trx_line_id
                   ra_customer_trx_lines.customer_trx_line_id%type;
    l_ctt_bs_deflt_ctrx_type_id
                   ra_cust_trx_types.cust_trx_type_id%type;
    l_allow_overapplication_flag
                         ra_cust_trx_types.allow_overapplication_flag%type;
    l_natural_app_only_flag
                         ra_cust_trx_types.natural_application_only_flag%type;
    l_default_printing_option_code
                         ar_lookups.lookup_code%type;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;
    l_payment_trxn_extension_id                           NUMBER;
    l_legal_entity_id		NUMBER;
BEGIN
         --assignment to local variables
arp_util.debug('AR_DEPOSIT_API_PUB.Create_Deposit()+ ');
arp_util.debug('initialize local variable ');
/*-----------------------------------------------------------------------+
 | Local Variable initializations		                         |
 +-----------------------------------------------------------------------*/



       l_hd_attribute_rec.attribute_category  :=   p_interface_header_context;
       l_hd_attribute_rec.attribute1          :=   p_interface_header_attribute1;
       l_hd_attribute_rec.attribute2          :=   p_interface_header_attribute2;
       l_hd_attribute_rec.attribute3          :=   p_interface_header_attribute3;
       l_hd_attribute_rec.attribute4          :=   p_interface_header_attribute4;
       l_hd_attribute_rec.attribute5          :=   p_interface_header_attribute5;
       l_hd_attribute_rec.attribute6          :=   p_interface_header_attribute6;
       l_hd_attribute_rec.attribute7          :=   p_interface_header_attribute7;
       l_hd_attribute_rec.attribute8          :=   p_interface_header_attribute8;
       l_hd_attribute_rec.attribute9          :=   p_interface_header_attribute9;
       l_hd_attribute_rec.attribute10         :=   p_interface_header_attribute10;
       l_hd_attribute_rec.attribute11         :=   p_interface_header_attribute11;
       l_hd_attribute_rec.attribute12         :=   p_interface_header_attribute12;
       l_hd_attribute_rec.attribute13         :=   p_interface_header_attribute13;
       l_hd_attribute_rec.attribute14         :=   p_interface_header_attribute14;
       l_hd_attribute_rec.attribute15         :=   p_interface_header_attribute15;



       l_attribute_rec.attribute_category  :=   p_attribute_category;
       l_attribute_rec.attribute1          :=   p_attribute1;
       l_attribute_rec.attribute2          :=   p_attribute2;
       l_attribute_rec.attribute3          :=   p_attribute3;
       l_attribute_rec.attribute4          :=   p_attribute4;
       l_attribute_rec.attribute5          :=   p_attribute5;
       l_attribute_rec.attribute6          :=   p_attribute6;
       l_attribute_rec.attribute7          :=   p_attribute7;
       l_attribute_rec.attribute8          :=   p_attribute8;
       l_attribute_rec.attribute9          :=   p_attribute9;
       l_attribute_rec.attribute10         :=   p_attribute10;
       l_attribute_rec.attribute11         :=   p_attribute11;
       l_attribute_rec.attribute12         :=   p_attribute12;
       l_attribute_rec.attribute13         :=   p_attribute13;
       l_attribute_rec.attribute14         :=   p_attribute14;
       l_attribute_rec.attribute15         :=   p_attribute15;

       l_in_comm_attribute_rec.attribute_category  :=   p_comm_interface_line_context;
       l_in_comm_attribute_rec.attribute1          :=   p_comm_interface_line_attr1;
       l_in_comm_attribute_rec.attribute2          :=   p_comm_interface_line_attr2;
       l_in_comm_attribute_rec.attribute3          :=   p_comm_interface_line_attr3;
       l_in_comm_attribute_rec.attribute4          :=   p_comm_interface_line_attr4;
       l_in_comm_attribute_rec.attribute5          :=   p_comm_interface_line_attr5;
       l_in_comm_attribute_rec.attribute6          :=   p_comm_interface_line_attr6;
       l_in_comm_attribute_rec.attribute7          :=   p_comm_interface_line_attr7;
       l_in_comm_attribute_rec.attribute8          :=   p_comm_interface_line_attr8;
       l_in_comm_attribute_rec.attribute9          :=   p_comm_interface_line_attr9;
       l_in_comm_attribute_rec.attribute10         :=   p_comm_interface_line_attr10;
       l_in_comm_attribute_rec.attribute11         :=   p_comm_interface_line_attr11;
       l_in_comm_attribute_rec.attribute12         :=   p_comm_interface_line_attr12;
       l_in_comm_attribute_rec.attribute13         :=   p_comm_interface_line_attr13;
       l_in_comm_attribute_rec.attribute14         :=   p_comm_interface_line_attr14;
       l_in_comm_attribute_rec.attribute15         :=   p_comm_interface_line_attr15;


       l_doc_sequence_value                :=   p_document_number;
       l_bill_to_customer_id        := p_bill_to_customer_id;
       l_bill_to_customer_name      := p_bill_to_customer_name;
       l_bill_to_customer_number    := p_bill_to_customer_number;
       l_bill_to_location           := p_bill_to_location;
       l_bill_to_site_use_id        := null;
       l_bill_to_contact_id         := p_bill_to_contact_id;
       l_bill_to_contact_first_name := p_bill_to_contact_first_name;
       l_bill_to_contact_last_name  := p_bill_to_contact_last_name;

       l_ship_to_customer_id        := p_ship_to_customer_id;
       l_ship_to_customer_name      := p_ship_to_customer_name;
       l_ship_to_customer_number    := p_ship_to_customer_number;
       l_ship_to_location           := p_ship_to_location;
       l_ship_to_site_use_id        := null;
       l_ship_to_contact_id         := p_ship_to_contact_id;
       l_ship_to_contact_first_name := p_ship_to_contact_first_name;
       l_ship_to_contact_last_name  := p_ship_to_contact_last_name;
       l_agreement_id               := p_agreement_id;

       l_usr_currency_code          := p_usr_currency_code;
       l_usr_exchange_rate_type     := p_usr_exchange_rate_type;
       l_currency_code              := p_currency_code;
       l_exchange_rate_type         := p_exchange_rate_type;
       l_exchange_rate              := p_exchange_rate ;
       l_exchange_rate_date         := p_exchange_rate_date;
       l_start_date_commitmenmt     := p_start_date_commitment;
       l_end_date_commitmenmt       := p_end_date_commitment;
       l_amount                     := p_amount;
       /*l_item                       :=  p_item;
       l_memo_line                  :=  p_memo_line;
       l_description                :=  p_description;*/
       l_memo_line_id               :=  p_memo_line_id;
       l_memo_line_name             :=  p_memo_line_name;

       l_inventory_id               :=  p_inventory_id;
       l_deposit_date               := p_deposit_date;
       l_gl_date                    := p_gl_date;


       l_remit_to_address_id        := p_remit_to_address_id;
       l_cust_location_site_num     := null;

       l_sold_to_customer_id        :=p_sold_to_customer_id;
       l_sold_to_customer_name      :=p_sold_to_customer_name;
       l_sold_to_customer_number    :=p_sold_to_customer_number;

       l_paying_customer_id        := p_paying_customer_id;
       l_paying_customer_name      := p_paying_customer_name;
       l_paying_customer_number    := p_paying_customer_number;
       l_paying_location           := p_paying_location;
       l_paying_site_use_id        := null;

       l_receipt_method_id         := p_receipt_method_id;
       l_receipt_method_name       := p_receipt_method_name;

       l_cust_bank_account_id      :=p_cust_bank_account_id;
       l_cust_bank_account_name    :=p_cust_bank_account_name;
       l_cust_bank_account_number  :=p_cust_bank_account_number;

       l_batch_source_id      := p_batch_source_id;
       l_cust_trx_type_id     := p_cust_trx_type_id;
       l_printing_option      := p_printing_option;
       l_status_trx           := p_status_trx;
       l_tax_calculation_flag := p_default_tax_exempt_flag;
       l_financial_charges    := p_financial_charges;
       l_salesrep_id          := p_salesrep_id;
       l_term_id              := p_term_id;
       l_payment_trxn_extension_id  := p_payment_trxn_extension_id;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

      SAVEPOINT Create_Deposit_PVT;
       arp_util.debug('Save point defined and calling compatible API call ');
       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status     := FND_API.G_RET_STS_SUCCESS;
        l_doc_seq_status    := FND_API.G_RET_STS_SUCCESS;

        l_id_return_status          := FND_API.G_RET_STS_SUCCESS;
        l_cdflex_val_return_status  := FND_API.G_RET_STS_SUCCESS;
        l_dflex_val_return_status   := FND_API.G_RET_STS_SUCCESS;
	    l_intflex_val_return_status := FND_API.G_RET_STS_SUCCESS; /* Bug 4895995 FP Bug 5467022 */
        l_dft_return_status         := FND_API.G_RET_STS_SUCCESS;
        l_receipt_method_status     := FND_API.G_RET_STS_SUCCESS;
        l_return_val_status         := FND_API.G_RET_STS_SUCCESS;
        l_bank_acct_status          := FND_API.G_RET_STS_SUCCESS;



/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
        /*-------------------------------------------------+
         | Initialize the profile option package variables |
         +-------------------------------------------------*/
           arp_util.debug('Before initialize_profile_globals ');
           initialize_profile_globals;
          arp_util.debug('After initialize_profile_globals');


/*--------------------------------------------------------------------------+
| Getting all id 's required for commitment creation from name or number    |
| comibination  it ll also be validated inside the called routine           |
+---------------------------------------------------------------------------*/

    AR_DEPOSIT_LIB_PVT.Default_deposit_ids
                             (l_salesrep_id,
                              p_salesrep_name,
                              l_term_id,
                              p_term_name,
                              l_batch_source_id,
                              p_batch_source_name,
                              l_cust_trx_type_id,
                              p_cust_trx_type,
                              l_bill_to_customer_id,
                              l_bill_to_site_use_id,
                              l_bill_to_customer_name,
                              l_bill_to_customer_number,
                              l_bill_to_location,
                              l_bill_to_contact_id,
                              l_bill_to_contact_first_name,
                              l_bill_to_contact_last_name,

                              l_ship_to_customer_id,
                              l_ship_to_site_use_id,
                              l_ship_to_customer_name,
                              l_ship_to_customer_number,
                              l_ship_to_location,
                              l_ship_to_contact_id,
                              l_ship_to_contact_first_name,
                              l_ship_to_contact_last_name,

                              l_usr_currency_code,
                              l_usr_exchange_rate_type,
                              l_currency_code,
                              l_exchange_rate_type,

                              l_remit_to_address_id,
                              l_cust_location_site_num,

                              l_sold_to_customer_id,
                              l_sold_to_customer_name,
                              l_sold_to_customer_number,

                              l_paying_customer_id,
                              l_paying_site_use_id,
                              l_paying_customer_name,
                              l_paying_customer_number,
                              l_paying_location,

                              l_receipt_method_id,
                              l_receipt_method_name,

                              l_cust_bank_account_id,
                              l_cust_bank_account_name,
                              l_cust_bank_account_number,
                              l_memo_line_id ,
                              l_memo_line_name,
                              l_inventory_id,
                              p_deposit_number ,
                              l_deposit_date,
                              l_id_return_status --out
                              );

arp_util.debug('l_receipt_method_id'||to_char(l_receipt_method_id));
/*----------------------------------------------------------------------------+
| Getting some of the defaulted values for depsoit creations		     |
+----------------------------------------------------------------------------*/

         AR_DEPOSIT_LIB_PVT.Get_deposit_Defaults
                                        (l_currency_code,
                                         l_exchange_rate_type,
                                         l_exchange_rate ,
                                         l_exchange_rate_date,
                                         l_start_date_commitmenmt,
                                         l_end_date_commitmenmt,
                                         l_amount,
                                         l_deposit_date,
                                         l_gl_date,
                                         l_bill_to_customer_id,
                                         l_bill_to_site_use_id,
                                         l_ship_to_customer_id,
                                         l_ship_to_site_use_id,
                                         l_default_salesrep_id,
                                         l_dft_bill_to_contact_id,
                                         'AR_DEPOSIT_API_PUB',
                                         l_dft_return_status);



 -- **** default the salesrep id,bill to contact if id's is not passed ****

	IF l_salesrep_id is null then
 		l_salesrep_id := l_default_salesrep_id;
	END IF;
	IF l_bill_to_contact_id is null then
 		l_bill_to_contact_id := l_dft_bill_to_contact_id;
	END IF;

/*----------------------------------------------------------------------------+
|Only do  main validation before creating the deposit			     |
+----------------------------------------------------------------------------*/
        ar_deposit_val_pvt.Validate_Deposit(l_batch_source_id,
                                            l_deposit_date,
                                            l_gl_date,
                                            l_doc_sequence_value,
                                            l_amount,
                                            l_currency_code,
                                            l_exchange_rate_type,
                                            l_exchange_rate,
                                            l_exchange_rate_date,
                                            l_printing_option,
                                            l_status_trx,
                                            l_tax_calculation_flag,
                                            l_financial_charges,
                                            l_return_val_status);

/*----------------------------------------------------------------------+
|Only do the check if either the batch_source_id or		       |
|ar_ra_batch_source are not null 				       |
+-----------------------------------------------------------------------*/

       IF   l_batch_source_id IS NOT NULL OR
            ar_deposit_lib_pvt.pg_profile_batch_source IS NOT NULL
       THEN

                 arp_trx_defaults.get_header_defaults(
                    l_batch_source_id,
                    NULL,
                    ar_deposit_lib_pvt.pg_profile_batch_source,
                    NULL,
                    l_cust_trx_type_id,
                    l_term_id,
                    NULL,
                    'DEP',
                    l_deposit_date,
                    NULL,--p_deposit_number,
                    NULL,
                    NULL,
                    'N',
                    'N',
                    'Y',
                    l_bill_to_customer_id,
                    l_bill_to_site_use_id,
                    l_gl_date,
                    NULL,
                    NULL,
                    NULL,
                    l_default_batch_source_id,
                    l_default_batch_source_name,
                    l_auto_trx_numbering_flag,
                    l_batch_source_type,
		    l_copy_doc_number_flag,
                    l_bs_default_cust_trx_type_id,
                    l_default_cust_trx_type_id,
                    l_default_type_name,
                    l_class,
                    l_open_receivables_flag,
                    l_post_to_gl_flag,
                    l_allow_freight_flag,
                    l_creation_sign,
                    l_allow_overapplication_flag,
                    l_natural_app_only_flag,
                    l_dft_tax_calculation_flag,
                    l_default_status_code,
                    l_default_status,
                    l_default_printing_option_code,
                    l_default_printing_option,
                    l_default_term_id,
                    l_default_term_name,
                    l_number_of_due_dates,
                    l_term_due_date,
                    l_default_gl_date,
                    'N',
                    'N',
                    'N',
                    'Y'
             );
       END IF;
       arp_util.debug('l_term_id := '||to_char(l_term_id));
       arp_util.debug('l_default_term_id := '||to_char(l_default_term_id));

       IF l_cust_trx_type_id is NULL and
          l_default_cust_trx_type_id is NULL THEN

         FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_NULL');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
       ELSIF l_cust_trx_type_id is NULL and l_default_cust_trx_type_id is NOT NULL THEN
          BEGIN
            SELECT  cust_trx_type_id
            INTO l_cust_trx_type_id
            FROM  ra_cust_trx_types
            where type = 'DEP' and
                  nvl(p_deposit_date, trunc(sysdate)) between
                      nvl(start_date(+), nvl(p_deposit_date, trunc(sysdate)))   and
                      nvl(end_date(+), nvl(p_deposit_date, trunc(sysdate)))  and
                  cust_trx_type_id = l_default_cust_trx_type_id;
          EXCEPTION

            WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_NULL');
                  FND_MSG_PUB.Add;
                  x_return_status := FND_API.G_RET_STS_ERROR;
           WHEN OTHERS THEN
             RAISE;
          END;

       END IF;

      --**** Passed deposit number will not be passed if l_auto_trx_numbering_flag
      --  it set to Y, a new deposit number will be generated
         IF nvl(l_auto_trx_numbering_flag,'N') = 'Y' then
             l_deposit_number := null;
         else
            l_deposit_number := p_deposit_number;
         end IF;
      --****overriding defaulted term_id
	IF l_term_id is not null
	THEN
  		 l_default_term_id := l_term_id;
	END IF;

/*----------------------------------------------------------------------------+
|  Only do the check if either the payment method or bank fields are not null |
+-----------------------------------------------------------------------------*/

   IF l_receipt_method_id is  null or
      l_cust_bank_account_id is  null THEN

      ARP_TRX_VALIDATE.val_and_dflt_pay_mthd_and_bank
                                    ( l_deposit_date ,
                                      l_currency_code ,
                                      l_paying_customer_id,
                                      l_paying_site_use_id,
                                      l_bill_to_customer_id,
                                      l_bill_to_site_use_id,
                                      l_receipt_method_id,
                                      l_cust_bank_account_id,
                                      NULL, -- *p_payment_type_code***
                                      l_fin_payment_method_name,
                                      l_fin_receipt_method_id,
                                      l_fin_creation_method_code,
                                      l_fin_customer_bank_account_id,
                                      l_fin_bank_account_num,
                                      l_fin_bank_name,
                                      l_fin_bank_branch_name,
                                      l_fin_bank_branch_id);
  	arp_util.debug('l_receipt_method_id'||
                               to_char(l_receipt_method_id));
  	arp_util.debug('l_cust_bank_account_id'||
                               to_char(l_cust_bank_account_id));
  	arp_util.debug('l_fin_receipt_method_id'||
                               to_char(l_fin_receipt_method_id));
  	arp_util.debug('l_fin_customer_bank_account_id'||
                               to_char(l_fin_customer_bank_account_id));

   END IF;

   IF l_printing_option is NULL
   THEN
         l_printing_option := l_default_printing_option;
   END IF;

   IF    (l_printing_option  = 'NOT' )
   THEN
        l_printing_pending :='N';
   ELSE
         l_printing_pending := 'Y';
   END IF;

   IF l_status_trx is NULL THEN
        l_status_trx := l_default_status_code;
   END IF;

   IF l_tax_calculation_flag is NULL THEN
        l_tax_calculation_flag := l_dft_tax_calculation_flag;
   END IF;

/*-----------------------------------------------------------------------------+
|  Validating Descriptive Flex Fields 					     |
+-----------------------------------------------------------------------------*/

        ar_deposit_lib_pvt.Validate_Desc_Flexfield(
                                            l_attribute_rec,
                                            'RA_CUSTOMER_TRX',
                                            l_dflex_val_return_status
                                            );
        ar_deposit_lib_pvt.Validate_Desc_Flexfield(
                                            l_hd_attribute_rec,
                                            'RA_INTERFACE_HEADER',
                                       --   l_dflex_val_return_status
					    					l_intflex_val_return_status  /* Bug 4895995 FP Bug 5467022 */
                                            );
        ar_deposit_lib_pvt.Validate_Desc_Flexfield(
                                            l_in_comm_attribute_rec,
                                           'RA_INTERFACE_LINES',
                                            l_cdflex_val_return_status
                                            );
END IF;

      IF l_id_return_status          <> FND_API.G_RET_STS_SUCCESS OR
         l_cdflex_val_return_status  <> FND_API.G_RET_STS_SUCCESS OR
         l_dflex_val_return_status   <> FND_API.G_RET_STS_SUCCESS OR
	 	 l_intflex_val_return_status <> FND_API.G_RET_STS_SUCCESS OR    /* Bug 4895995 FP Bug 5467022*/
         l_dft_return_status         <> FND_API.G_RET_STS_SUCCESS OR
         l_return_val_status         <> FND_API.G_RET_STS_SUCCESS OR
         l_receipt_method_status     <> FND_API.G_RET_STS_SUCCESS OR
         l_bank_acct_status          <> FND_API.G_RET_STS_SUCCESS


      THEN

            x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

/*-----------------------------------------------------------------------------+
| Call the document sequence routine only there have been no errors reported   |
| so far.								       |
+-----------------------------------------------------------------------------*/

        IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN

           ar_deposit_lib_pvt.get_doc_seq(222,
                                          l_default_type_name,
                                            --l_receipt_method_name,
                                          arp_global.set_of_books_id,
                                          'M',
                                          l_deposit_date,
                                          l_doc_sequence_value,
                                          l_doc_sequence_id,
                                          l_doc_seq_status
                                          );
        END IF;


       /*------------------------------------------------------------+
        |  If any errors - including validation failures - occurred, |
        |  rollback any changes and return an error status.          |
        +------------------------------------------------------------*/
      arp_util.debug('x_return_status : '||x_return_status);
      arp_util.debug('l_doc_seq_status : '||l_doc_seq_status);
	 IF (
              x_return_status         <> FND_API.G_RET_STS_SUCCESS
              OR l_doc_seq_status     <> FND_API.G_RET_STS_SUCCESS
             )
             THEN

              ROLLBACK TO Create_Deposit_PVT;


       /*-------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used  get the count of mesg.|
        | in the message stack. If there is only one message in |
        | the stack it retrieves this message                   |
        +-------------------------------------------------------*/
              x_return_status := FND_API.G_RET_STS_ERROR ;

              FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);

             arp_util.debug('Error(s) occurred.
                             Rolling back and setting status to ERROR');
             Return;
        END IF;
          arp_util.debug('x_return_status '||x_return_status);

/*---------------------------------------------------------------------+
 |   Bug 6620785 Get and validate default legal entity id              |
 +--------------------------------------------------------------------*/
    BEGIN
    IF pg_debug = 'Y' THEN
        arp_util.debug ('AR_DEPOSIT_API_PUB.populate_legal_entity(+)' );
    END IF;

	l_legal_entity_id := arp_legal_entity_util.get_default_le(
				l_sold_to_customer_id,
				l_bill_to_customer_id,
				l_cust_trx_type_id,
				l_batch_source_id);
    IF NVL(l_legal_entity_id, -1) = -1 then
	ROLLBACK TO Create_Deposit_PVT;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	Return;
    END IF;

    IF pg_debug = 'Y' THEN
	arp_util.debug ('AR_DEPOSIT_API_PUB.populate_legal_entity(-)' );
    END IF;

    EXCEPTION
            WHEN Others THEN
                FND_MESSAGE.SET_NAME('AR','AR_LE_NAME_MANDATORY');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                ROLLBACK TO Create_Deposit_PVT;
               FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
					p_data  => x_msg_data);
		return;
    END;

/*-----------------------------------------------------------------------------+
|   Inserting Header and line for commitment calling the routine ,             |
|   arp_process_header_insrt_cover.insert_header_cover                         |
+-----------------------------------------------------------------------------*/
   BEGIN
   arp_process_header_insrt_cover.insert_header_cover(
                      G_PKG_NAME,
                      p_api_version,
                      'DEP', -- p_class,  --p_class can be used for future enhancement
                      l_default_gl_date,
                      NULL,
                      NULL,
                      NULL,
                      l_deposit_number,
                      NULL,
                      'Y',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      l_default_cust_trx_type_id,
                      NULL,
                      l_default_batch_source_id,
                      l_agreement_id,
	              trunc(l_deposit_date), /*Bug 4065254*/
                      l_bill_to_customer_id,
                      l_bill_to_contact_id,
                      l_bill_to_site_use_id,
                      l_ship_to_customer_id,
                      l_ship_to_contact_id,
                      l_ship_to_site_use_id,
                      l_sold_to_customer_id ,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      trunc(l_start_date_commitmenmt), /*Bug 4065254*/
                      trunc(l_end_date_commitmenmt), /*Bug 4065254*/
                      trunc(l_exchange_rate_date), /*Bug 4065254*/
                      l_exchange_rate,
                      l_exchange_rate_type,
                      nvl(l_cust_bank_account_id,
                          l_fin_customer_bank_account_id),
                      l_financial_charges,
                      ar_deposit_lib_pvt.Get_FOB_POINT(l_bill_to_customer_id,
                                                       l_bill_to_location,
                                                       l_ship_to_customer_id,
                                                       l_ship_to_location,
                                                       x_return_status),
                      p_comments,
                      p_special_instructions,
                      l_currency_code,
                      NULL,
                      NULL,
                      NULL,
                      l_salesrep_id,
                      NULL,
                      NULL,
                      l_printing_option,
                      NULL,
                      l_printing_pending,
                      p_purchase_order,
                      p_purchase_order_date,
                      p_purchase_order_revision,
                      nvl(l_receipt_method_id,l_fin_receipt_method_id),
                      l_remit_to_address_id ,
                      NULL,
                      NULL,
                      NULL, /*Bug 4065254*/
                      trunc(l_term_due_date), /*Bug 4065254*/
                      l_default_term_id,
                      ar_deposit_lib_pvt.Get_Territory_id(l_bill_to_customer_id,						          l_bill_to_location,
                                                          l_ship_to_customer_id,							  l_ship_to_location,
                                                          l_salesrep_id,
							  l_deposit_date,
							  x_return_status),
                      NULL,
                      l_status_trx,
                      NUll,
                      l_doc_sequence_id,
                      l_doc_sequence_value,
                      l_paying_customer_id,
                      l_paying_site_use_id,
                      NULL,
                      l_tax_calculation_flag,
                      'ARXCDEPB' ,
                      p_ussgl_transaction_code,
                      NULL,
                      p_interface_header_context,
                      p_interface_header_attribute1,
                      p_interface_header_attribute2,
                      p_interface_header_attribute3,
                      p_interface_header_attribute4,
                      p_interface_header_attribute5,
                      p_interface_header_attribute6,
                      p_interface_header_attribute7,
                      p_interface_header_attribute8,
                      p_interface_header_attribute9,
                      p_interface_header_attribute10,
                      p_interface_header_attribute11,
                      p_interface_header_attribute12,
                      p_interface_header_attribute13,
                      p_interface_header_attribute14,
                      p_interface_header_attribute15,
                      l_attribute_rec.attribute_category,
                      l_attribute_rec.attribute1,
                      l_attribute_rec.attribute2,
                      l_attribute_rec.attribute3,
                      l_attribute_rec.attribute4,
                      l_attribute_rec.attribute5,
                      l_attribute_rec.attribute6,
                      l_attribute_rec.attribute7,
                      l_attribute_rec.attribute8,
                      l_attribute_rec.attribute9,
                      l_attribute_rec.attribute10,
                      l_attribute_rec.attribute11,
                      l_attribute_rec.attribute12,
                      l_attribute_rec.attribute13,
                      l_attribute_rec.attribute14,
                      l_attribute_rec.attribute15,
                      NULL,
                      l_inventory_id,
		      l_memo_line_id,
                      p_description,
                      l_amount,
                      p_comm_interface_line_attr1,
                      p_comm_interface_line_attr2,
                      p_comm_interface_line_attr3,
                      p_comm_interface_line_attr4,
                      p_comm_interface_line_attr5,
                      p_comm_interface_line_attr6,
                      p_comm_interface_line_attr7,
                      p_comm_interface_line_attr8,
                      p_comm_interface_line_attr9,
                      p_comm_interface_line_attr10,
                      p_comm_interface_line_attr11,
                      p_comm_interface_line_attr12,
                      p_comm_interface_line_attr13,
                      p_comm_interface_line_attr14,
                      p_comm_interface_line_attr15,
                      p_comm_interface_line_context,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      NULL,
                      l_new_trx_number,
                      l_new_customer_trx_id,
                      l_new_customer_trx_line_id,
                      l_new_rowid,
                      l_new_status,
		      l_legal_entity_id);

     X_new_trx_number           := l_new_trx_number;
     X_new_customer_trx_id      := l_new_customer_trx_id;
     X_new_customer_trx_line_id := l_new_customer_trx_line_id;
     X_new_rowid                := l_new_rowid;
arp_util.debug('arp_process_header_insrt_cover.insert_header_cover: l_new_status'||l_new_status );
   EXCEPTION
            WHEN Others THEN
             FND_MESSAGE.SET_NAME('AR','AR_DAPI_INSERT_HEADER_ST');
             FND_MSG_PUB.Add;
             FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             ROLLBACK TO Create_Deposit_PVT;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
             Return;
   END;


/* PAYMENT UPTAKE */

      IF l_new_customer_trx_id IS NOT NULL
      THEN
           BEGIN

             copy_trxn_extension (
                     p_customer_trx_id => l_new_customer_trx_id,
                     p_payment_trxn_extension_id =>l_payment_trxn_extension_id,
                     p_return_status =>l_return_status);

   /*       EXCEPTION
            WHEN Others THEN */




         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             FND_MESSAGE.SET_NAME('AR','AR_CC_AUTH_FAILED');
             FND_MSG_PUB.Add;
             FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             ROLLBACK TO Create_Deposit_PVT;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
             Return;
         END IF;

             EXCEPTION
             WHEN OTHERS THEN

             FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             ROLLBACK TO Create_Deposit_PVT;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
            return;

          END;
      END IF;

/* PAYMENT UPTAKE END */



  -- ****update ra_customer_trx and line for globalization felx

/*-----------------------------------------------------------------------------+
|   Posting commit activities i.e completing the deposit create by routine ,  |
|   arp_process_header_insrt_cover.insert_header_cover  using                 |
|   arp_process_header.post_commit  			                      |
+-----------------------------------------------------------------------------*/


      IF l_new_customer_trx_id IS NOT NULL
      THEN
           BEGIN
           arp_process_header.post_commit( 'AR_DEPOSIT_API_PUB',
                                           1.0,
                                           l_new_customer_trx_id,
                                           NULL,
                                           'Y',
                                           l_open_receivables_flag,
                                           NULL,
                                           l_creation_sign,
                                           l_allow_overapplication_flag,
                                           l_natural_app_only_flag,
                                           NULL
                                         );
          EXCEPTION
            WHEN Others THEN
             FND_MESSAGE.SET_NAME('AR','AR_DAPI_POST_COMMIT_ST');
             FND_MSG_PUB.Add;
             FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             ROLLBACK TO Create_Deposit_PVT;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
             Return;

          END;
      END IF;

-- Bug # 3177345
    IF NVL(l_copy_doc_number_flag, 'N') = 'Y' AND
         (l_doc_sequence_value IS NOT NULL)
    THEN
       update ra_customer_trx
       set  old_trx_number = l_new_trx_number ,
            trx_number = l_doc_sequence_value
       where customer_trx_id = l_new_customer_trx_id ;
       --Bug # 3515882 -also updatingh trx_number in payment schedule
       update ar_payment_schedules
       set   trx_number = l_doc_sequence_value
       where customer_trx_id = l_new_customer_trx_id ;

       X_new_trx_number           := l_doc_sequence_value;
     END IF;
 --bug 3177345

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            arp_util.debug('committing');
            Commit;
        END IF;

arp_util.debug('AR_DEPOSIT_API_PUB.Create_Deposit()- ');
END CREATE_DEPOSIT;
/*========================================================================
 | PUBLIC PROCEDURE insert_non_rev_salescredit
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |        This routine is called to assign non revenue sales credit to
 |        salesreps of  to deposit, commitment. You can  create as many
 |        of the non-revenue credit assignment.
 |        This API routine has  4 output and 22 input parameters in total.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |      AR_DEPOSIT_API_PUB.insert_non_rev_salescredit
 |      Parameter
 |      p_deposit_number
 |      p_customer_trx_id
 |      p_salesrep_number
 |      p_salesrep_id
 |      p_non_revenue_amount_split
 |      p_non_revenue_percent_split
 |      p_attribute_category
 |      p_attribute1 to p_attribute15
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 |          None
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-JUL-2003           Anuj              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/

PROCEDURE insert_non_rev_salescredit

(
 -- Standard API parameters.
 p_api_version                  IN  NUMBER,
 p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE,
 p_commit                       IN  VARCHAR2 := FND_API.G_TRUE,
 p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_deposit_number               IN  VARCHAR2 DEFAULT NULL,
 p_customer_trx_id              IN  NUMBER DEFAULT NULL,
 p_salesrep_number              IN  VARCHAR2  DEFAULT NULL,
 p_salesrep_id                  IN  NUMBER  DEFAULT NULL,
 p_non_revenue_amount_split     IN  NUMBER  DEFAULT NULL,
 p_non_revenue_percent_split    IN  NUMBER  DEFAULT NULL,
 p_attribute_category           IN  VARCHAR2 DEFAULT NULL ,
 p_attribute1                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute2                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute3                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute4                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute5                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute6                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute7                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute8                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute9                   IN  VARCHAR2 DEFAULT NULL ,
 p_attribute10                  IN  VARCHAR2 DEFAULT NULL ,
 p_attribute11                  IN  VARCHAR2 DEFAULT NULL ,
 p_attribute12                  IN  VARCHAR2 DEFAULT NULL ,
 p_attribute13                  IN  VARCHAR2 DEFAULT NULL ,
 p_attribute14                  IN  VARCHAR2 DEFAULT NULL ,
 p_attribute15                  IN  VARCHAR2 DEFAULT NULL ,
 p_org_id                       IN  NUMBER   DEFAULT NULL )

IS


 l_api_name       CONSTANT VARCHAR2(100) := 'insert_non_rev_salescredit';
 l_api_version    CONSTANT NUMBER       := 1.0;

 l_deposit_number            ra_customer_trx.trx_number%type;
 l_deposit_date           ra_customer_trx.trx_date%type;
 l_customer_trx_id           ra_cust_trx_line_salesreps.customer_trx_id%type;
 l_salesrep_number             ra_salesreps.salesrep_number%type;
 l_salesrep_id               ra_cust_trx_line_salesreps.salesrep_id%type;
 l_non_revenue_amount_split  ra_cust_trx_line_salesreps.non_revenue_amount_split%type;
 l_non_revenue_percent_split ra_cust_trx_line_salesreps.non_revenue_percent_split%type;
 l_desc_flex_rec             ar_deposit_api_pub.attr_rec_type;
 l_dflex_val_return_status   varchar2(1000);
 l_nosales_val_return_status varchar2(1000);
 l_dept_no_return_status     varchar2(1000);
 l_sales_val_return_status   varchar2(1000);
 l_nonrev_amt_pct_return_status varchar2(1000);
 l_dummy_return_status       varchar2(1000);
 l_INVOICE_CURRENCY_CODE     ra_customer_trx.INVOICE_CURRENCY_CODE%type;

 l_cust_trx_line_salesrep_id number;
 l_customer_trx_line_id      number;
 l_status                    varchar2(100);
 l_amount                    number;
 l_dummy_number              number;
 l_org_return_status VARCHAR2(1);
 l_org_id                           NUMBER;
BEGIN

--assignment to local variables
arp_util.debug('AR_DEPOSIT_API_PUB.insert_non_rev_salescredit()+ ');
arp_util.debug('initialize local variable ');

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

      SAVEPOINT Create_non_rev_sales_PVT;
       arp_util.debug('Save point defined and calling compatible API call ');
       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status             := FND_API.G_RET_STS_SUCCESS;
        l_dflex_val_return_status   := FND_API.G_RET_STS_SUCCESS;
        l_dummy_return_status       := FND_API.G_RET_STS_SUCCESS;
        l_sales_val_return_status   := FND_API.G_RET_STS_SUCCESS;
        l_nosales_val_return_status := FND_API.G_RET_STS_SUCCESS;
        l_nonrev_amt_pct_return_status := FND_API.G_RET_STS_SUCCESS;
        l_dept_no_return_status        := FND_API.G_RET_STS_SUCCESS;




/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE

        /*-------------------------------------------------+
         | Initialize the profile option package variables |
         +-------------------------------------------------*/
           arp_util.debug('Before initialize_profile_globals ');
           initialize_profile_globals;
          arp_util.debug('After initialize_profile_globals');


       l_amount  := 0;

     If  ( p_deposit_number IS  NULL AND
           p_customer_trx_id IS  NULL  ) then

         FND_MESSAGE.SET_NAME('AR','AR_DAPI_DEP_NO_ID_REQ');
         FND_MSG_PUB.Add;
         l_dept_no_return_status := FND_API.G_RET_STS_ERROR;

    elsif ( p_deposit_number IS  NOT NULL AND
           p_customer_trx_id IS  NOT NULL  ) then
       begin
           SELECT customer_trx_id,INVOICE_CURRENCY_CODE,trx_date
           INTO   l_customer_trx_id,l_INVOICE_CURRENCY_CODE,l_deposit_date
           FROM    ra_customer_trx
           WHERE  customer_trx_id = p_customer_trx_id;

           FND_MESSAGE.SET_NAME('AR','AR_DAPI_DEP_NO_ING');
           FND_MSG_PUB.Add;

           SELECT customer_trx_id into l_dummy_number
           FROM   ra_customer_trx cust_trx ,
                  ra_cust_trx_types cust_trx_type
           WHERE  cust_trx.cust_trx_type_id =cust_trx_type.cust_trx_type_id
                  and customer_trx_id = l_customer_trx_id
                  and cust_trx_type.TYPE = 'DEP';
        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_DEP_ID_INVALID');
                 FND_MSG_PUB.Add;
                 l_dept_no_return_status := FND_API.G_RET_STS_ERROR;

        end;
    elsif ( p_deposit_number IS  NULL AND
           p_customer_trx_id IS  NOT NULL  ) then
       begin
           SELECT customer_trx_id,INVOICE_CURRENCY_CODE,trx_date
           INTO   l_customer_trx_id,l_INVOICE_CURRENCY_CODE,l_deposit_date
           FROM    ra_customer_trx
           WHERE  customer_trx_id = p_customer_trx_id;

           SELECT customer_trx_id into l_dummy_number
           FROM   ra_customer_trx cust_trx ,
                  ra_cust_trx_types cust_trx_type
           WHERE  cust_trx.cust_trx_type_id =cust_trx_type.cust_trx_type_id
                  and customer_trx_id = l_customer_trx_id and
                   cust_trx_type.TYPE = 'DEP';
        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_DEP_ID_INVALID');
                 FND_MSG_PUB.Add;
                 l_dept_no_return_status := FND_API.G_RET_STS_ERROR;

        end;
      elsif ( p_deposit_number IS  NOT NULL AND
            p_customer_trx_id IS   NULL  ) then
       begin
           SELECT customer_trx_id,INVOICE_CURRENCY_CODE,trx_date
           INTO   l_customer_trx_id,l_INVOICE_CURRENCY_CODE,l_deposit_date
           FROM    ra_customer_trx
           WHERE  trx_number = p_deposit_number;

           SELECT customer_trx_id into l_dummy_number
           FROM   ra_customer_trx cust_trx ,
                  ra_cust_trx_types cust_trx_type
           WHERE  cust_trx.cust_trx_type_id =cust_trx_type.cust_trx_type_id
                  and customer_trx_id = l_customer_trx_id and
                   cust_trx_type.TYPE = 'DEP';
        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_DEP_NO_INVALID');
                 FND_MSG_PUB.Add;
                 l_dept_no_return_status := FND_API.G_RET_STS_ERROR;

        end;
    end if;

    if l_dept_no_return_status  =  FND_API.G_RET_STS_SUCCESS THEN
     begin
       select sum(EXTENDED_AMOUNT)
       into l_amount
       from ra_customer_trx_lines
       where customer_trx_id = l_customer_trx_id;
     end;
    end if;

    if l_dept_no_return_status  =  FND_API.G_RET_STS_SUCCESS THEN
     begin
       select customer_trx_line_id
       into l_customer_trx_line_id
       from ra_customer_trx_lines
       where customer_trx_id = l_customer_trx_id; --only line per deposit
     exception when others  then raise;
     end;
    end if;
    if ( p_salesrep_id IS  NULL AND
         p_salesrep_number IS  NULL  ) then

         FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_NO_ID_NAME');
         FND_MSG_PUB.Add;
         l_nosales_val_return_status := FND_API.G_RET_STS_ERROR;

    end if;



       IF   p_salesrep_id IS  NULL AND
            p_salesrep_number IS NOT NULL
       THEN

        begin
          SELECT salesrep_id
          INTO   l_salesrep_id
          FROM   ra_salesreps
          WHERE  SALESREP_NUMBER = p_salesrep_number and
                 NVL(status,'A') ='A' and
                 l_deposit_date between nvl(start_date_active, l_deposit_date) and
                                        nvl(end_date_active, l_deposit_date);


        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_NAME_INVALID');
                  FND_MSG_PUB.Add;
                  l_sales_val_return_status := FND_API.G_RET_STS_ERROR;

        end;
       ELSIF (p_salesrep_id IS  NOT NULL) THEN

        begin
          SELECT salesrep_id
          INTO   l_salesrep_id
          FROM   ra_salesreps
          WHERE  salesrep_id = p_salesrep_id and
                 NVL(status,'A') ='A' and
                 l_deposit_date between nvl(start_date_active, l_deposit_date) and
                                        nvl(end_date_active, l_deposit_date);


        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_ID_INVALID');
                 FND_MSG_PUB.Add;
                 l_sales_val_return_status := FND_API.G_RET_STS_ERROR;

        end;
       END IF;
if l_sales_val_return_status =  FND_API.G_RET_STS_SUCCESS  and
   l_dept_no_return_status   =  FND_API.G_RET_STS_SUCCESS THEN

   If  ( p_non_revenue_amount_split IS  NULL AND
         p_non_revenue_percent_split IS  NULL  ) then

         FND_MESSAGE.SET_NAME('AR','AR_DAPI_NON_REV_AMT_PCT');
         FND_MSG_PUB.Add;
         l_nonrev_amt_pct_return_status := FND_API.G_RET_STS_ERROR;
    elsif ( p_non_revenue_amount_split IS  NOT NULL AND
            p_non_revenue_percent_split IS  NULL  ) then
      l_non_revenue_amount_split  := p_non_revenue_amount_split;
      l_non_revenue_percent_split := ROUND(p_non_revenue_amount_split /l_amount,4 )*100;
   elsif ( p_non_revenue_amount_split IS   NULL AND
            p_non_revenue_percent_split IS  NOT NULL  ) then
      l_non_revenue_percent_split  := p_non_revenue_percent_split ;
      l_non_revenue_amount_split   := CurrRound(
                                        ( l_non_revenue_percent_split / 100 ) * l_amount ,l_INVOICE_CURRENCY_CODE);
   elsif ( p_non_revenue_amount_split IS   NOT NULL AND
            p_non_revenue_percent_split IS  NOT NULL  ) then
      l_non_revenue_percent_split  := p_non_revenue_percent_split ;
      l_non_revenue_amount_split   := CurrRound(
                                        ( l_non_revenue_percent_split / 100 ) * l_amount,l_INVOICE_CURRENCY_CODE );

       FND_MESSAGE.SET_NAME('AR','AR_DAPI_REV_AMT_IGN');
       FND_MSG_PUB.Add;
    end if;

      l_desc_flex_rec.attribute_category := p_attribute_category;
      l_desc_flex_rec.attribute1 := p_attribute1;
      l_desc_flex_rec.attribute2 := p_attribute2;
      l_desc_flex_rec.attribute3 := p_attribute3;
      l_desc_flex_rec.attribute4 := p_attribute4;
      l_desc_flex_rec.attribute5 := p_attribute5;
      l_desc_flex_rec.attribute6 := p_attribute6;
      l_desc_flex_rec.attribute7 := p_attribute7;
      l_desc_flex_rec.attribute8 := p_attribute8;
      l_desc_flex_rec.attribute9 := p_attribute9;
      l_desc_flex_rec.attribute10 := p_attribute10;
      l_desc_flex_rec.attribute11 := p_attribute11;
      l_desc_flex_rec.attribute12 := p_attribute12;
      l_desc_flex_rec.attribute13 := p_attribute13;
      l_desc_flex_rec.attribute14 := p_attribute14;
      l_desc_flex_rec.attribute15 := p_attribute15;
/*-----------------------------------------------------------------------------+
|  Validating Descriptive Flex Fields 					     |
+-----------------------------------------------------------------------------*/

         ar_deposit_lib_pvt.Validate_Desc_Flexfield(
                                            l_desc_flex_rec,
                                            'RA_CUST_TRX_LINE_SALESREPS',
                                            l_dflex_val_return_status
                                            );


 END IF;
END IF;
      IF  l_dflex_val_return_status   <> FND_API.G_RET_STS_SUCCESS OR
          l_sales_val_return_status   <> FND_API.G_RET_STS_SUCCESS OR
          l_nosales_val_return_status <> FND_API.G_RET_STS_SUCCESS OR
          l_nonrev_amt_pct_return_status <> FND_API.G_RET_STS_SUCCESS OR
          l_dept_no_return_status  <> FND_API.G_RET_STS_SUCCESS
      THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

 IF (  x_return_status  <> FND_API.G_RET_STS_SUCCESS  )  THEN
           ROLLBACK TO Create_non_rev_sales_PVT;
       /*-------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used  get the count of mesg.|
        | in the message stack. If there is only one message in |
        | the stack it retrieves this message                   |
        +-------------------------------------------------------*/
              x_return_status := FND_API.G_RET_STS_ERROR ;

              FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);

             arp_util.debug('Error(s) occurred.
                             Rolling back and setting status to ERROR');

             Return;
 END IF;

 arp_util.debug('x_return_status '||x_return_status);

      BEGIN
      arp_process_salescredit.insert_salescredit_cover(
                             l_api_name,
                             l_api_version,
                             FALSE, --l_rerun_autoaccounting_flag,
                             l_customer_trx_id , -- ak1 art_context.pg_customer_trx_id,
                             l_customer_trx_line_id, -- derive based on p_customer_trx_id
                             l_salesrep_id , -- ak2 Name_In('tscr_lines.salesrep_id'),
                             null, -- l_revenue_amount_split,
                             l_non_revenue_amount_split, --ak3 l_non_revenue_amount_split,
                             l_non_revenue_percent_split, --ak4 Name_In('tscr_lines.non_revenue_percent_split'),
                             null, --Name_In('tscr_lines.revenue_percent_split'),
                             null, --Name_In('tscr_lines.prev_cust_trx_line_salesrep_id'),
                             l_desc_flex_rec.attribute_category ,
                             l_desc_flex_rec.attribute1,
                             l_desc_flex_rec.attribute2,
                             l_desc_flex_rec.attribute3,
                             l_desc_flex_rec.attribute4,
                             l_desc_flex_rec.attribute5,
                             l_desc_flex_rec.attribute6,
                             l_desc_flex_rec.attribute7,
                             l_desc_flex_rec.attribute8,
                             l_desc_flex_rec.attribute9,
                             l_desc_flex_rec.attribute10,
                             l_desc_flex_rec.attribute11,
                             l_desc_flex_rec.attribute12,
                             l_desc_flex_rec.attribute13,
                             l_desc_flex_rec.attribute14,
                             l_desc_flex_rec.attribute15,
                             l_cust_trx_line_salesrep_id,
                             l_status );
       IF ( l_status <> 'OK' )
       THEN
           FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_ST');
           FND_MESSAGE.RAISE_ERROR;


       END IF;

    EXCEPTION
            WHEN Others THEN
             FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_ST');
             FND_MSG_PUB.Add;
             FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
             FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             ROLLBACK TO Create_non_rev_sales_PVT;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
             return;
    END;

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            arp_util.debug('committing');
            Commit;
        END IF;

arp_util.debug('AR_DEPOSIT_API_PUB.insert_non_rev_salescredit()- ');

END insert_non_rev_salescredit;


/*========================================================================
 |  PROCEDURE set_profile_for_testing
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |      This procedure does the following: Set the value of profile options
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      fnd_profile.value
 |
 | PARAMETERS
 |
 |          None
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-MAY-2001           Anuj              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/

PROCEDURE set_profile_for_testing(p_profile_batch_source      NUMBER,
                                  p_profile_doc_seq           VARCHAR2,
                                  p_profile_trxln_excpt       VARCHAR2,
                                  p_profile_enable_cc         VARCHAR2,
                                  p_profile_cc_rate_type      VARCHAR2,

                                  p_profile_dsp_inv_rate      VARCHAR2,
                                  p_profile_def_x_rate_type   VARCHAR2
                                  ) IS
BEGIN
  arp_util.debug('AR_DEPOSIT_API_PUB.set_profile_for_testing()+ ');

  ar_deposit_lib_pvt.pg_profile_batch_source       := p_profile_batch_source;
  ar_deposit_lib_pvt.pg_profile_doc_seq            := p_profile_doc_seq;
  ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag   := p_profile_trxln_excpt;
  ar_deposit_lib_pvt.pg_profile_enable_cc          := p_profile_enable_cc;
  ar_deposit_lib_pvt.pg_profile_cc_rate_type       := p_profile_cc_rate_type;
  ar_deposit_lib_pvt.pg_profile_dsp_inv_rate       := p_profile_dsp_inv_rate;
  ar_deposit_lib_pvt.pg_profile_def_x_rate_type    := p_profile_def_x_rate_type;

  arp_util.debug('AR_DEPOSIT_API_PUB.set_profile_for_testing()- ');

END set_profile_for_testing;


/*========================================================================
 |  PROCEDURE create_trxn_extension
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |      This procedure does the following: updates pmt_trx_extn
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      fnd_profile.value
 |
 | PARAMETERS
 |
 |          None
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-sep-2005           bichatte           created
 |
 *=======================================================================*/

  PROCEDURE copy_trxn_extension( p_customer_trx_id  IN  NUMBER,
                               p_payment_trxn_extension_id IN NUMBER,
                               p_return_status  OUT NOCOPY VARCHAR2 ) IS


             l_payer_rec                     IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
             l_cpy_msg_data                  VARCHAR2(2000);
             l_trxn_attribs_rec              IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
             p_trxn_entity_id                RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE;
             l_response_rec                  IBY_FNDCPT_COMMON_PUB.Result_rec_type;
             l_pmt_trxn_extension_id          IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
             o_payment_trxn_extension_id         RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE;

             l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
             l_assignment_id                 NUMBER;

             l_msg_count                     NUMBER;
             l_msg_data                      VARCHAR2(2000);


            l_payment_channel       ar_receipt_methods.payment_channel_code%type;
            l_customer_id           ra_customer_trx.paying_customer_id%type;
            l_customer_site_use_id  ra_customer_trx.paying_site_use_id%type;
            l_org_id                ra_customer_trx.org_id%type;
            l_trx_number            ra_customer_trx.trx_number%type;
            l_customer_trx_id       ra_customer_trx.customer_trx_id%type;
            l_party_id              hz_parties.party_id%type;


    BEGIN

arp_util.debug('AR_DEPOSIT_API_PUB.create_trxn_extension()'|| SQLERRM);
arp_util.debug('customer_trx_id'|| p_customer_trx_id);
arp_util.debug('payment_trxn_extension_id'|| p_payment_trxn_extension_id);




   IF p_payment_trxn_extension_id is NOT NULL THEN

             select trx.paying_customer_id,
                    trx.paying_site_use_id,
                    trx.org_id,
                    party.party_id,
                    trx.trx_number,
                    rm.payment_channel_code,
                    trx.customer_trx_id
             into   l_customer_id,
                    l_customer_site_use_id,
                    l_org_id,
                    l_party_id,
                    l_trx_number,
                    l_payment_channel,
                    l_customer_trx_id
             FROM   hz_cust_accounts hca,
                    hz_parties    party,
                    ra_customer_trx trx,
                    ar_receipt_methods rm
             WHERE  trx.customer_trx_id = p_customer_trx_id
             AND    hca.party_id = party.party_id
             AND    hca.cust_account_id = trx.paying_customer_id
             AND    trx.receipt_method_id = rm.receipt_method_id(+) ;



     SELECT INSTR_ASSIGNMENT_ID
     INTO  l_assignment_id
     from  iby_fndcpt_tx_extensions
     where trxn_extension_id = p_payment_trxn_extension_id;



arp_util.debug('AR_DEPOSIT_API_PUB.create_trxn_extension()'|| SQLERRM);
arp_util.debug('customer_trx_id'|| p_customer_trx_id);


     /* pouplate values into the variables */

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=  l_party_id;                  -- receipt customer party id mandatory
        l_payer_rec.org_id   := l_org_id;
        l_payer_rec.org_type := 'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id :=l_customer_id ;         -- receipt customer account_id
        l_payer_rec.Account_Site_Id :=l_customer_site_use_id; -- receipt customer site_id

        if l_customer_site_use_id is NULL  THEN

          l_payer_rec.org_id := NULL;
          l_payer_rec.org_type := NULL;

        end if;

        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id :=  l_trx_number;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'TRANSACTION';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := l_customer_trx_id;
        l_assignment_id := l_assignment_id;


        l_pmt_trxn_extension_id(1) := p_payment_trxn_extension_id;



             IBY_FNDCPT_TRXN_PUB.Copy_Transaction_Extension
                     ( p_api_version        => 1.0,
                       p_init_msg_list      => FND_API.G_TRUE,
                       p_commit             => FND_API.G_FALSE,
                       x_return_status      => l_return_status,
                       x_msg_count          => l_msg_count,
                       x_msg_data           => l_msg_data,
                       p_payer              => l_payer_rec,
                       p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                       p_entities           => l_pmt_trxn_extension_id,
                       p_trxn_attribs       => l_trxn_attribs_rec,
                       x_entity_id          => p_trxn_entity_id,          -- out parm
                       x_response           => l_response_rec             -- out
                      );


                IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

                         o_payment_trxn_extension_id  := p_trxn_entity_id ;

                     arp_standard.debug('the copied value of trx_entn is ' || o_payment_trxn_extension_id );


                        update ra_customer_trx
                        set payment_trxn_extension_id = o_payment_trxn_extension_id
                        where customer_trx_id = p_customer_trx_id ;


                 END IF;

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                   arp_util.debug('FAILED: ' ||l_response_rec.result_code,0);

                p_return_status := FND_API.G_RET_STS_ERROR ;

           END IF;


  END IF ; /* payment_trxn_extension_id is not null */

     arp_util.debug('AR_DEPOSIT_API_PUB.create_trxn_extension()'|| SQLERRM);
     EXCEPTION
        WHEN OTHERS THEN
                p_return_status := FND_API.G_RET_STS_ERROR ;

arp_util.debug('AR_DEPOSIT_API_PUB.create_trxn_extension()'|| SQLERRM);
END copy_trxn_extension;









BEGIN

   ar_deposit_lib_pvt.pg_profile_batch_source := FND_API.G_MISS_NUM;
   ar_deposit_lib_pvt.pg_profile_doc_seq := FND_API.G_MISS_CHAR;
   ar_deposit_lib_pvt.pg_profile_trxln_excpt_flag := FND_API.G_MISS_CHAR;
   ar_deposit_lib_pvt.pg_profile_enable_cc := FND_API.G_MISS_CHAR;
   ar_deposit_lib_pvt.pg_profile_cc_rate_type := FND_API.G_MISS_CHAR;
   ar_deposit_lib_pvt.pg_profile_dsp_inv_rate := FND_API.G_MISS_CHAR;
   ar_deposit_lib_pvt.pg_profile_def_x_rate_type := FND_API.G_MISS_CHAR;


END AR_DEPOSIT_API_PUB;

/
