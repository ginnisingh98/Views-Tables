--------------------------------------------------------
--  DDL for Package ARP_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_GLOBAL" AUTHID CURRENT_USER AS
/*$Header: ARCUGLBS.pls 120.6 2004/09/16 16:32:08 rvsharma noship $*/
--
--
-- Public Variables
--
   sysparam			AR_SYSTEM_PARAMETERS%ROWTYPE;
   chart_of_accounts_id		NUMBER;
   set_of_books_id		NUMBER;
   functional_currency		GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
   period_set_name		GL_SETS_OF_BOOKS.PERIOD_SET_NAME%TYPE;
   created_by		        NUMBER;
   creation_date		DATE;
   last_updated_by		NUMBER;
   last_update_date 		DATE;
   last_update_login		NUMBER;
   request_id			NUMBER;
   program_id			NUMBER;
   program_application_id  	NUMBER;
   program_update_date		DATE;
   user_id			NUMBER;
   base_precision		fnd_currencies.precision%type;
   base_min_acc_unit		fnd_currencies.minimum_accountable_unit%type;
   tm_installed_flag            VARCHAR2(1);
   tm_default_setup_flag        VARCHAR2(1);

   G_CB_RT_ID     CONSTANT  NUMBER := -11;
   G_CB_REV_RT_ID     CONSTANT  NUMBER := -12;
   G_AR_APP_ID	      CONSTANT NUMBER := 222;
   G_GL_APP_ID        CONSTANT NUMBER := 101;
   --
   G_MAX_DATE         CONSTANT DATE := TO_DATE( '12/31/4712', 'MM/DD/YYYY' );
   --
   -- Bug 3172032/3146233 : added global variable which is checked in the ra_cust_trx_line_gl_dist_bri trigger
   G_ALLOW_DATAFIX    BOOLEAN := FALSE;

   conc_program_name   fnd_concurrent_programs_vl.concurrent_program_name%type; /*Bug 3678916*/

   -- This is the seeded bank branch for credit cards
   -- The value for this will have to be changed for the cba project.

   CC_BANK_BRANCH_ID CONSTANT NUMBER := 1;


--
-- Linefeed character
--
CRLF            CONSTANT VARCHAR2(1) := '
';
YES		CONSTANT VARCHAR2(1) := 'Y';
NO		CONSTANT VARCHAR2(1) := 'N';
--
--
--
MSG_LEVEL_BASIC 	CONSTANT NUMBER := 0;
MSG_LEVEL_TIMING 	CONSTANT NUMBER := 1;
MSG_LEVEL_DEBUG 	CONSTANT NUMBER := 2;
MSG_LEVEL_DEBUG2 	CONSTANT NUMBER := 3;
MSG_LEVEL_DEVELOP 	CONSTANT NUMBER := 10;

msg_level  NUMBER := MSG_LEVEL_DEVELOP;

--
--
-- Public Record Type for receivable applications record
--
   TYPE app_rec_type IS RECORD
  (
    gl_date_closed                      DATE,
    actual_date_closed                  DATE,
    --
    acctd_amount_applied                NUMBER,
    amount_applied                      NUMBER,
    line_applied                        NUMBER,
    tax_applied                         NUMBER,
    freight_applied                     NUMBER,
    receivables_charges_applied         NUMBER,
    amount_adjusted_pending             NUMBER,
    --
    line_ediscounted                    NUMBER,
    line_uediscounted                   NUMBER,
    tax_ediscounted                     NUMBER,
    tax_uediscounted                    NUMBER,
    freight_ediscounted                 NUMBER,
    freight_uediscounted                NUMBER,
    charges_ediscounted                 NUMBER,
    charges_uediscounted                NUMBER,
    --
    earned_discount_taken               NUMBER,
    unearned_discount_taken             NUMBER,
    acctd_earned_discount_taken         NUMBER,
    acctd_unearned_discount_taken       NUMBER,
    --
    trx_type                            VARCHAR2(20),
    user_id                             NUMBER,
    ps_id                               NUMBER,
    cash_receipt_ps_id		        NUMBER,
    charges_type_adjusted               NUMBER    /* Bug 3769587 */
   );
    --

    /* Bug 1679088 : define new public procedure to allow initialization
       process to run whenever required */
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;09/13/2002*/
   PROCEDURE INIT_GLOBAL(p_org_id number default null);
/* Multi-Org Access Control Changes for SSA;End;anukumar;09/13/2002*/

    /* Bug 3251839 : Function to return cached tm_installed_flag */
    FUNCTION TM_INSTALLED RETURN VARCHAR2;

END ARP_GLOBAL;

 

/
