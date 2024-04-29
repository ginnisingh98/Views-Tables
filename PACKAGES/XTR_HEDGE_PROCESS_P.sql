--------------------------------------------------------
--  DDL for Package XTR_HEDGE_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_HEDGE_PROCESS_P" AUTHID CURRENT_USER AS
/* $Header: xtrhdgps.pls 120.2 2004/06/30 16:22:55 rvallams ship $ */

e_invalid_criteria_set EXCEPTION;
e_batch_been_run       EXCEPTION;

TYPE hedge_items      IS TABLE OF xtr_hedge_criteria.criteria_code%TYPE INDEX BY BINARY_INTEGER;
TYPE hedge_conditions IS TABLE OF xtr_hedge_criteria.operator%TYPE      INDEX BY BINARY_INTEGER;
TYPE hedge_values     IS TABLE OF xtr_hedge_criteria.from_value%TYPE    INDEX BY BINARY_INTEGER;

TYPE criteria_set_rec_type IS RECORD (
	criteria_set    xtr_hedge_criteria.criteria_set%TYPE,
	criteria_set_owner xtr_hedge_criteria.criteria_set_owner%TYPE,
	source          xtr_hedge_criteria.from_value%TYPE,
	currency        xtr_hedge_criteria.from_value%TYPE,
	company_code    xtr_hedge_criteria.from_value%TYPE,
	sob_currency    xtr_hedge_criteria.from_value%TYPE,
	discount        xtr_hedge_criteria.from_value%TYPE,
	factor          xtr_hedge_criteria.from_value%TYPE,
	due_date_from   xtr_hedge_criteria.from_value%TYPE,  --MUST MAINTAIN INVARIANT DATE TYPE OF RRRR/MM/DD
	due_date_to     xtr_hedge_criteria.to_value%TYPE,    --MUST MAINTAIN INVARIANT DATE TYPE OF RRRR/MM/DD
	ar_unpld        xtr_hedge_criteria.from_value%TYPE,
	ap_unpld        xtr_hedge_criteria.from_value%TYPE,
	condition_count NUMBER,
	item            hedge_items,
	condition       hedge_conditions,
	value           hedge_values
);

PROCEDURE SAVE_CRITERIA_SET(p_crit_set CRITERIA_SET_REC_TYPE);

PROCEDURE DELETE_CRITERIA_SET(p_crit_set CRITERIA_SET_REC_TYPE);

PROCEDURE LOAD_CRITERIA_SET(p_crit_set IN OUT NOCOPY CRITERIA_SET_REC_TYPE);

PROCEDURE CALC_PCT_ALLOC (ERRBUF     OUT NOCOPY VARCHAR2,
                          RETCODE    OUT NOCOPY VARCHAR2,
                          P_HEDGE_NO IN  NUMBER);


PROCEDURE POPULATE_ITEMS(P_HEDGE_NO IN NUMBER);

FUNCTION GET_WHERE_CLAUSE(P_HEDGE_NO IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_SOURCE_CODE(P_HEDGE_NO IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_REQUEST_STATUS(P_REQUEST_ID IN NUMBER) RETURN VARCHAR2;

PROCEDURE GENERATE_QUERY_FROM_DETAILS(p_crit_set CRITERIA_SET_REC_TYPE,
                                      p_query OUT NOCOPY VARCHAR2,
                                      p_where OUT NOCOPY VARCHAR2,
                                      p_where1 OUT NOCOPY VARCHAR2,
                                      p_where2 OUT NOCOPY VARCHAR2);

PROCEDURE GET_HOAPR_REPORT_PARAMETERS(p_criteria_set_name VARCHAR2,
                                      p_criteria_set_owner VARCHAR2,
                                      p_source          IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_currency        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_company_code    IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_sob_currency    IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_discount        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_factor          IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_due_date_from   IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_due_date_to     IN OUT NOCOPY xtr_hedge_criteria.to_value%TYPE,
                                      p_ar_unpld        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_ap_unpld        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_ar_from  OUT NOCOPY VARCHAR2,
                                      p_ap_from  OUT NOCOPY VARCHAR2,
                                      p_ar_where OUT NOCOPY VARCHAR2,
                                      p_ap_where OUT NOCOPY VARCHAR2);



/*=====================================================================
   BEGIN: New objects for BUG 3378028 - FAS HEDGE ACCOUNTING PROJECT
======================================================================*/

PROCEDURE retro_eff_test (errbuf     OUT NOCOPY VARCHAR2,
                          retcode    OUT NOCOPY VARCHAR2,
                          p_company  IN  VARCHAR2,
                          p_batch_id IN NUMBER);

PROCEDURE retro_main_calc(p_company  IN  VARCHAR2,
			  p_batch_id IN NUMBER);

PROCEDURE ins_retro_event(p_batch_id  IN NUMBER,
			  p_event in VARCHAR2);

PROCEDURE calc_reclass(p_company     IN VARCHAR2,
		       p_batch_id    IN NUMBER,
                       p_hedge_no    IN NUMBER,
                       p_reclass_id  IN NUMBER,
                       p_date        IN DATE);

PROCEDURE authorize(p_company IN VARCHAR2,
		    p_batch_id in NUMBER);


FUNCTION get_gl_ccy(p_amount_type IN VARCHAR2,
		    p_deal_no IN NUMBER,
		    p_company IN VARCHAR2) return VARCHAR2;

--PROCEDURE log_msg(p_msg IN VARCHAR2);


/*=====================================================================
   END: New objects for BUG 3378028 - FAS HEDGE ACCOUNTING PROJECT
======================================================================*/



END XTR_HEDGE_PROCESS_P;

 

/
