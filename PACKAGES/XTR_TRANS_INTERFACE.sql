--------------------------------------------------------
--  DDL for Package XTR_TRANS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_TRANS_INTERFACE" AUTHID CURRENT_USER AS
/*$Header: xtrtrins.pls 120.1 2005/06/29 07:57:54 rjose ship $   */

-- CONTEXT: CALL = XTR_TRANS_INTERFACE.Transfer_From_Interface.
--    GLOBAL variables
--
--
 l_div          varchar2(1);
 l_divisor      NUMBER;
 l_count        NUMBER;
 l_error        NUMBER;
 l_import_nos   NUMBER;
 l_num_trans    NUMBER;
 l_db_total     NUMBER;
 l_cr_total     NUMBER;
 l_total        NUMBER;
 l_source       varchar2(20);
 l_tsfr_trailer varchar2(1);
 l_rev_trailer  varchar2(1);
 l_verify_total varchar2(1);
 l_ccy          varchar2(15);
 l_cre_date     DATE;
 l_net_amount   NUMBER;
 l_net_debit    NUMBER;
 l_net_credit   NUMBER;
 l_dr_trans     NUMBER;
 l_cr_trans     NUMBER;
 l_net_trans    NUMBER;
 l_debit        NUMBER;
 l_company      VARCHAR2(7);
 l_acct         VARCHAR2(20);
 l_batch_acct   VARCHAR2(20);
 l_imp_source   VARCHAR2(20);
 fnd_user_id 	NUMBER;
 x_user		VARCHAR2(30);
--
-- Pass in Parameter
--
G_source		VARCHAR2(20);
G_creation_date	        DATE;
G_currency 	        VARCHAR2(15);

PROCEDURE TRANSFER_FROM_INTERFACE ( errbuf       OUT    NOCOPY VARCHAR2,
                        	    retcode      OUT    NOCOPY NUMBER,
                                    p_source            VARCHAR2,
				    p_creation_date     VARCHAR2,
				    p_currency		VARCHAR2 );


END XTR_TRANS_INTERFACE;

 

/
