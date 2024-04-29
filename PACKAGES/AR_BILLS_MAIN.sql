--------------------------------------------------------
--  DDL for Package AR_BILLS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_MAIN" AUTHID CURRENT_USER as
/* $Header: ARBRCOMS.pls 120.3 2005/06/02 19:18:14 vcrisost ship $ */
--


--
 /*-------------------------------------------------------------------+
  | 12-AUG-2000 J Rautiainen BR Implementation                        |
  | Forms and libraries cannot directly refer to PL/SQL package global|
  | variables, these record types are used to relay API constants     |
  | to client side using a function returning a record of this type.  |
  +-------------------------------------------------------------------*/
  TYPE fnd_api_constants_type IS RECORD (
    G_MISS_NUM            NUMBER      := FND_API.G_MISS_NUM,
    G_MISS_CHAR           VARCHAR2(1) := FND_API.G_MISS_CHAR,
    G_MISS_DATE           DATE        := FND_API.G_MISS_DATE,
    G_VALID_LEVEL_NONE    NUMBER      := FND_API.G_VALID_LEVEL_NONE,
    G_VALID_LEVEL_FULL    NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    G_RET_STS_SUCCESS     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS,
    G_RET_STS_ERROR       VARCHAR2(1) := FND_API.G_RET_STS_ERROR,
    G_RET_STS_UNEXP_ERROR VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR,
    G_TRUE                VARCHAR2(1) := FND_API.G_TRUE,
    G_FALSE               VARCHAR2(1) := FND_API.G_FALSE);

  TYPE fnd_msg_pub_constants_type IS RECORD (
    G_FIRST                NUMBER := FND_MSG_PUB.G_FIRST,
    G_NEXT                 NUMBER := FND_MSG_PUB.G_NEXT,
    G_LAST                 NUMBER := FND_MSG_PUB.G_LAST,
    G_PREVIOUS             NUMBER := FND_MSG_PUB.G_PREVIOUS,
    G_msg_level_threshold  NUMBER := FND_MSG_PUB.G_msg_level_threshold,
    G_MSG_LVL_UNEXP_ERROR  NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
    G_MSG_LVL_ERROR        NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR,
    G_MSG_LVL_SUCCESS      NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS,
    G_MSG_LVL_DEBUG_HIGH   NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,
    G_MSG_LVL_DEBUG_MEDIUM NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
    G_MSG_LVL_DEBUG_LOW    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


TYPE disallowedrectyp IS RECORD (
cf_block_item VARCHAR2(50));
TYPE disallowedtabtyp is TABLE OF disallowedrectyp
INDEX by BINARY_INTEGER;


currentform disallowedtabtyp;
disallowed disallowedtabtyp;


--
-- Definition of the BLOCKITEM record and table type
--
-- Used by the forms module as a list of canvas fields and flag indicating if they are accessible
--

TYPE blockitemrectyp is RECORD
(br_block_item VARCHAR2(50) , 		/* Format is block.item separated by a point */
update_allowed VARCHAR2(1));    	/* Y or N depending if the user should have access to the field */

TYPE blockitemtabtyp is TABLE of blockitemrectyp
INDEX BY BINARY_INTEGER;







-- Definition of the STATE Record type and table type
--
-- Master table of the rules governing access to fields   (only used in the server side)
--
--

TYPE stateRecTyp IS RECORD
(br_module VARCHAR2(30) ,		/* Module which the fields are to be controlled */
br_block_item VARCHAR2(50),		/*  Format is block.item separated by a point */
br_state varchar2(30) ,			/* State of the Bills Receivable 		*/
update_allowed VARCHAR2(1)) ;		 /* Y or N depending if the user should have access to the field */


/* The column State holds either the Status of the Bill Receivable INCOMPLETE , PENDING_ACCEPTANCE etc
  as defined in the look up type TRANSACTION_HISTORY_STATUS
	and also the values ACTIVITES , POSTED for these additional criteria */

TYPE statetabTyp is TABLE OF staterectyp
INDEX BY BINARY_INTEGER;


blockitem ar_bills_main.blockitemtabtyp;

BrState statetabtyp;




-- ===============================================================================================
--
-- The assignments page uses a cursor for the QuickAssign to select
-- and fetch from the database.
--

-- The cursor first fetches into a Pl/SQL table which is passed to the form.


-- First Define the AssignRecType and AssignTabTyp

TYPE assignRecTyp is RECORD
(
 trx_number 			RA_CUSTOMER_TRX.trx_number%TYPE 		,
 doc_sequence_value		RA_CUSTOMER_TRX.doc_sequence_value%TYPE	,
 trx_date 			RA_CUSTOMER_TRX.trx_date%TYPE			,
 comments			RA_CUSTOMER_TRX.comments%TYPE			 ,
 purchase_order			RA_CUSTOMER_TRX.purchase_order%TYPE		,
 invoice_currency_code 		AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE	,
 customer_trx_id		RA_CUSTOMER_TRX.customer_trx_id%TYPE		,
 payment_schedule_id		AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE ,
 amount_due_original		AR_PAYMENT_SCHEDULES.amount_due_original%TYPE		,
 amount_due_remaining		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE	,
 acctd_amount_due_remaining	AR_PAYMENT_SCHEDULES.acctd_amount_due_remaining%TYPE	,
 due_date			AR_PAYMENT_SCHEDULES.due_date%TYPE		,
 exchange_rate			AR_PAYMENT_SCHEDULES.exchange_rate%TYPE	,
 terms_sequence_number		AR_PAYMENT_SCHEDULES.terms_sequence_number%TYPE	,
 jgzz_fiscal_code		HZ_PARTIES.jgzz_fiscal_code%TYPE ,
 customer_number		HZ_CUST_ACCOUNTS.account_number%TYPE		,
 customer_name			HZ_PARTIES.party_name%TYPE ,
 customer_class_code		HZ_CUST_ACCOUNTS.customer_class_code%TYPE		,
 customer_category_code 	HZ_PARTIES.category_code%TYPE ,
 customer_category_meaning      AR_LOOKUPS.meaning%TYPE ,
 trx_type_name			RA_CUST_TRX_TYPES.name%TYPE		,
 trx_type_class			AR_LOOKUPS.meaning%TYPE			,
 trx_type_type			RA_CUST_TRX_TYPES.type%TYPE		,
 receipt_method_name		AR_RECEIPT_METHODS.NAME%TYPE		,
 receipt_method_id		AR_RECEIPT_METHODS.receipt_method_id%TYPE		,
 location			HZ_CUST_SITE_USES.location%type			,
 bill_to_site_use_id		RA_CUSTOMER_TRX.bill_to_site_use_id%TYPE	,
 bank_name  			ce_bank_branches_v.bank_name%TYPE 		,
 bank_branch_id			ce_bank_branches_v.branch_party_id%TYPE		,
 bank_account_id		ap_bank_accounts.bank_account_id%TYPE		,
 cons_billing_number		AR_CONS_INV_ALL.cons_billing_number%TYPE	 ,
 cons_inv_id			AR_CONS_INV.cons_inv_id%TYPE			,
 br_ref_customer_trx_id 	RA_CUSTOMER_TRX_LINES.br_ref_customer_trx_id%TYPE 	,
 br_ref_payment_schedule_id     RA_CUSTOMER_TRX_LINES.br_ref_payment_schedule_id%TYPE ,
 extended_amount		RA_CUSTOMER_TRX_LINES.extended_amount%TYPE ,
 extended_acctd_amount		RA_CUSTOMER_TRX_LINES.extended_acctd_amount%TYPE ,
 customer_trx_line_id		RA_CUSTOMER_TRX_LINES.customer_trx_line_id%TYPE	);

AssignRec	AssignRecTyp;


TYPE AssignTabTyp is TABLE OF AssignRecTyp
INDEX BY BINARY_INTEGER;

/* This is the actual table which is passed between the ON-SELECT trigger of ARBRMAIN.fmb
 Assignments block and the package ar_bills_main */

AssignTab AssignTabTyp;




--
--
-- ===============================================================================================



function load_table (pbr_module IN VARCHAR2 ) return Statetabtyp;

function get_all_items(pbr_module in varchar2) RETURN blockitemtabtyp;

function get_all_items_status (pbr_module in varchar2 ,  pbr_blockitem blockitemtabtyp , pbr_state1 in varchar2 ,
pbr_state2 in varchar2 , pbr_state3 in varchar2 , pbr_state4 in varchar2) RETURN blockitemtabtyp;



FUNCTION br_seq_enterable(p_sob_id in number , p_trans_type in varchar2 , p_trx_date in date ) RETURN  BOOLEAN;


FUNCTION br_posted(p_customer_trx_id in number) return VARCHAR2;

FUNCTION br_selected(p_customer_trx_id in number) return VARCHAR2;


FUNCTION fetch_assignments(Customer_Trx_Id IN NUMBER , Drawee_id in NUMBER ,
		Pay_unrelated_invoices IN VARCHAR2 , pg_where_clause In VARCHAR2 ,
		pg_order_clause IN VARCHAR2 , p_le_id in NUMBER, AssignmentAmount IN NUMBER , AssignTab IN OUT NOCOPY AssignTabTyp ,
		Extended_total OUT NOCOPY NUMBER) RETURN BOOLEAN;

FUNCTION GTRUE RETURN VARCHAR2;
FUNCTION GFALSE RETURN VARCHAR2;
FUNCTION  get_fnd_api_constants_rec RETURN fnd_api_constants_type;
FUNCTION  get_fnd_msg_pub_constants_rec RETURN fnd_msg_pub_constants_type;


FUNCTION revision RETURN VARCHAR2;
end;

 

/
