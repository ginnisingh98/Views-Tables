--------------------------------------------------------
--  DDL for Package JAI_AR_RCTLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_RCTLA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_rctla_t.pls 120.7 2007/08/17 19:33:02 brathod ship $ */

/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.2
                      Projects Billing Enh.
                      forward ported from R11i to R12

2			 27/04/2007			CSahoo for bug#5879769, File Version 120.3
											Forward porting of 11i bug#5694855
											Added a function get_service_type to get the service_type_code
											added the cursor c_get_address_details to get the customer_id and Customer_site_id
5. 14/05/2007	bduvarag for Bug5879769	File Version 120.14
		Removed the Project Billing Code

6. 18-Aug-2007  brathod, File Version 120.6
                Reimplemented Project Billing code
---------------------------------------------------------------------------------------- */


  t_rec  RA_CUSTOMER_TRX_LINES_ALL%rowtype ;
lc_modvat_tax CONSTANT varchar2(15) := 'Modvat Recovery';/*Bug 5684363 bduvarag*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARI_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARI_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

   -- added by csahoo for bug#5879769
		---start
	cursor c_get_address_details(cp_cust_trx_id ra_customer_trx_lines_all.customer_trx_id%type)
	is
	select bill_to_customer_id,
				 bill_to_site_use_id,
				 ship_to_customer_id,
				 ship_to_site_use_id
	from ra_customer_trx_all
	where customer_trx_id = cp_cust_trx_id;

	r_add c_get_address_details%rowtype;

	FUNCTION get_service_type(pn_party_id      NUMBER,
														pn_party_site_id NUMBER,
														pv_party_type    VARCHAR2) return VARCHAR2;

  	---End

    /*following function added for Projects Billing Implementation. bug#6012570 (5876390) */

  procedure import_projects_taxes
          (       r_new         in         ra_customer_trx_lines_all%rowtype
              ,   r_old         in         ra_customer_trx_lines_all%rowtype
              ,   pv_action     in         varchar2
              ,   pv_err_msg OUT NOCOPY varchar2
              ,   pv_err_flg OUT NOCOPY varchar2
          );


  function is_this_projects_context(
    pv_context          IN  varchar2
  ) return boolean ;


END JAI_AR_RCTLA_TRIGGER_PKG ;

/
