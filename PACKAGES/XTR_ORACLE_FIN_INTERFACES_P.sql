--------------------------------------------------------
--  DDL for Package XTR_ORACLE_FIN_INTERFACES_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_ORACLE_FIN_INTERFACES_P" AUTHID CURRENT_USER as
/* $Header: xtrdists.pls 120.2 2006/07/14 06:43:25 eaggarwa ship $ */

-- CONTEXT: CALL = XTR_ORACLE_FIN_INTERFACES_P.Transfer_Jnls .

G_batch_id           XTR_JOURNALS.batch_id%TYPE;
--G_date_from   	     XTR_JOURNALS.journal_date%TYPE;
--G_date_to            XTR_JOURNALS.journal_date%TYPE;

----------------------------------------------------------------------

FUNCTION BALANCE_BATCH (in_batch_id		IN NUMBER) RETURN BOOLEAN;

----------------------------------------------------------------------

FUNCTION GET_UNBALANCE_PARAM (in_company	IN VARCHAR2) RETURN VARCHAR2;


----------------------------------------------------------------------------------------------------------------
PROCEDURE TRANSFER_JNLS(
			errbuff			OUT NOCOPY VARCHAR2,
			retcode			OUT NOCOPY NUMBER,
			in_company_code		IN  VARCHAR2,
		        in_batch_id             IN  NUMBER,
		        in_closed_periods	IN  VARCHAR2);          --bug 4504734
----------------------------------------------------------------------------------------------------------------
end XTR_ORACLE_FIN_INTERFACES_P;

 

/
