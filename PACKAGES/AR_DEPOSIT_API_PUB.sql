--------------------------------------------------------
--  DDL for Package AR_DEPOSIT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DEPOSIT_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARXCDEPS.pls 120.14 2006/06/27 08:39:12 shveeram noship $ */
 /*#
 * Deposit APIs provide an extension to existing functionality of
 * creating and manipulating deposits through the standard Oracle
 * Receivables Transactions workbench.
 * @rep:scope public
 * @rep:metalink 236938.1 See OracleMetaLink note 236938.1
 * @rep:product AR
 * @rep:lifecycle active
 * @rep:displayname Deposit
 * @rep:category BUSINESS_ENTITY AR_DEPOSIT
  */

TYPE attr_rec_type IS RECORD(
                attribute_category    VARCHAR2(30)  DEFAULT NULL,
                attribute1            VARCHAR2(150) DEFAULT NULL,
       		attribute2            VARCHAR2(150) DEFAULT NULL,
        	attribute3            VARCHAR2(150) DEFAULT NULL,
        	attribute4            VARCHAR2(150) DEFAULT NULL,
       		attribute5            VARCHAR2(150) DEFAULT NULL,
        	attribute6            VARCHAR2(150) DEFAULT NULL,
        	attribute7            VARCHAR2(150) DEFAULT NULL,
        	attribute8            VARCHAR2(150) DEFAULT NULL,
        	attribute9            VARCHAR2(150) DEFAULT NULL,
        	attribute10           VARCHAR2(150) DEFAULT NULL,
        	attribute11           VARCHAR2(150) DEFAULT NULL,
        	attribute12           VARCHAR2(150) DEFAULT NULL,
        	attribute13           VARCHAR2(150) DEFAULT NULL,
        	attribute14           VARCHAR2(150) DEFAULT NULL,
        	attribute15           VARCHAR2(150) DEFAULT NULL);

attr_cust_rec_const        attr_rec_type;

attr_cust_lines_rec_const  attr_rec_type;

TYPE global_attr_rec_type IS RECORD(
            global_attribute_category     VARCHAR2(30)  DEFAULT NULL,
            global_attribute1             VARCHAR2(150) DEFAULT NULL,
            global_attribute2             VARCHAR2(150) DEFAULT NULL,
            global_attribute3             VARCHAR2(150) DEFAULT NULL,
            global_attribute4             VARCHAR2(150) DEFAULT NULL,
            global_attribute5             VARCHAR2(150) DEFAULT NULL,
            global_attribute6             VARCHAR2(150) DEFAULT NULL,
            global_attribute7             VARCHAR2(150) DEFAULT NULL,
            global_attribute8             VARCHAR2(150) DEFAULT NULL,
            global_attribute9             VARCHAR2(150) DEFAULT NULL,
            global_attribute10            VARCHAR2(150) DEFAULT NULL,
            global_attribute11            VARCHAR2(150) DEFAULT NULL,
            global_attribute12            VARCHAR2(150) DEFAULT NULL,
            global_attribute13            VARCHAR2(150) DEFAULT NULL,
            global_attribute14            VARCHAR2(150) DEFAULT NULL,
            global_attribute15            VARCHAR2(150) DEFAULT NULL,
            global_attribute16            VARCHAR2(150) DEFAULT NULL,
            global_attribute17            VARCHAR2(150) DEFAULT NULL,
            global_attribute18            VARCHAR2(150) DEFAULT NULL,
            global_attribute19            VARCHAR2(150) DEFAULT NULL,
            global_attribute20            VARCHAR2(150) DEFAULT NULL,
            global_attribute21            VARCHAR2(150) DEFAULT NULL,
            global_attribute22            VARCHAR2(150) DEFAULT NULL,
            global_attribute23            VARCHAR2(150) DEFAULT NULL,
            global_attribute24            VARCHAR2(150) DEFAULT NULL,
            global_attribute25            VARCHAR2(150) DEFAULT NULL,
            global_attribute26            VARCHAR2(150) DEFAULT NULL,
            global_attribute27            VARCHAR2(150) DEFAULT NULL,
            global_attribute28            VARCHAR2(150) DEFAULT NULL,
            global_attribute29            VARCHAR2(150) DEFAULT NULL,
            global_attribute30            VARCHAR2(150) DEFAULT NULL);

g_attr_cust_rec_const       global_attr_rec_type;

g_attr_cust_lines_rec_const global_attr_rec_type;
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
/*#
 * Use this procedure  to create  a deposit for Receivables transactions.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Deposit
 */

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
                 p_deposit_number               IN  VARCHAR2 DEFAULT NULL,
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
                 p_gl_date                      IN  DATE     DEFAULT trunc(Sysdate),
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
                 p_global_attr_cust_rec     IN global_attr_rec_type
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
                 p_cust_bank_account_id       IN  NUMBER     DEFAULT NULL,
                 p_cust_bank_account_name     IN  VARCHAR2  DEFAULT NULL ,
                 p_cust_bank_account_number   IN  VARCHAR2  DEFAULT NULL ,
                 p_start_date_commitment     IN  DATE     DEFAULT NULL,
                 p_end_date_commitment       IN  DATE     DEFAULT NULL,
                 p_amount                     IN  NUMBER,
                 p_inventory_id               IN  NUMBER  DEFAULT NULL,
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
                 p_org_id                       IN NUMBER    DEFAULT NULL,
                 p_payment_trxn_extension_id                       IN NUMBER    DEFAULT NULL,
                   --   ** OUT NOCOPY variables
                 X_new_trx_number      OUT NOCOPY ra_customer_trx.trx_number%type,
                 X_new_customer_trx_id OUT NOCOPY ra_customer_trx.customer_trx_id%type,
                 X_new_customer_trx_line_id
                                       OUT NOCOPY
                                ra_customer_trx_lines.customer_trx_line_id%type,
                 X_new_rowid           OUT NOCOPY  VARCHAR2) ;
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

 /*#
 * Use this procedure to assign non revenue sales credit to salesreps
 * for a deposit or commitment.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Sales Credit
 */

PROCEDURE insert_non_rev_salescredit(
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
 p_org_id                       IN  NUMBER   DEFAULT NULL  ) ;


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

PROCEDURE set_profile_for_testing(p_profile_batch_source         NUMBER,
                                  p_profile_doc_seq              VARCHAR2,
                                  p_profile_trxln_excpt          VARCHAR2,
                                  p_profile_enable_cc            VARCHAR2,
                                  p_profile_cc_rate_type         VARCHAR2,
                                  p_profile_dsp_inv_rate         VARCHAR2,
                                  p_profile_def_x_rate_type      VARCHAR2
                                  );
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
                               p_return_status  OUT NOCOPY VARCHAR2 );

END AR_DEPOSIT_API_PUB;

 

/
