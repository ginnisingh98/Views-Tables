--------------------------------------------------------
--  DDL for Package XTR_SETTLEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_SETTLEMENT" AUTHID CURRENT_USER as
/* $Header: xtrsetts.pls 120.3 2005/07/29 15:01:29 csutaria ship $ */
---------------------------------------------------------------------------------
PROCEDURE SETTLEMENT_SCRIPTS(errbuf  OUT nocopy    VARCHAR2,
                             retcode OUT nocopy   NUMBER,
		             l_company     IN VARCHAR2,
                             l_paydate     IN VARCHAR2,
			     l_setl_amt_from NUMBER,
			     l_setl_amt_to   NUMBER,
			     l_account     IN VARCHAR2,
			     l_currency    IN VARCHAR2,
			     l_script_name IN VARCHAR2,
			     l_cparty	   IN VARCHAR2,
			     l_prev_run    IN VARCHAR2 default 'N',
			     l_display_debug IN VARCHAR2,
			     l_transmit_payment IN VARCHAR2,
			     l_transmit_config_id IN VARCHAR2 );


----------------------------------------------------------------------------------

END XTR_SETTLEMENT;

 

/
