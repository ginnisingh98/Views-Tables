--------------------------------------------------------
--  DDL for Package XTR_RESET_BOND_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RESET_BOND_RATE" AUTHID CURRENT_USER AS
/* $Header: xtrrfbrs.pls 120.0 2005/11/15 08:46:27 badiredd noship $*/


 PROCEDURE RESET_BOND_BENCHMARK_RATE (errbuf       	OUT NOCOPY VARCHAR2,
                      	       retcode      	OUT NOCOPY NUMBER,
			                   p_rateset_from   IN VARCHAR2,
                               p_rateset_to     IN VARCHAR2,
                               p_rateset_adj    IN NUMBER,
                               p_bond_issue_code IN VARCHAR2,
                               p_currency       IN VARCHAR2,
                               p_bench_mark       IN VARCHAR2,
                               p_overwrite_type IN VARCHAR2 DEFAULT 'N');


 PROCEDURE VALIDATE_TRANSACTION(p_bond_issue_code        IN VARCHAR2,
                               p_coupon_date     IN DATE,
                               p_ratefix_date   IN DATE,
                               p_overwrite_type IN VARCHAR2,
                               p_valid_ok       OUT NOCOPY BOOLEAN,
            			       p_retcode		OUT NOCOPY NUMBER);

 PROCEDURE UPDATE_COUPON_DETAILS(p_bond_issue_code IN VARCHAR2,
                                 p_coupon_date IN DATE,
                                 p_new_rate IN NUMBER,
                                 p_deal_number IN NUMBER,
                                 p_transaction_number IN NUMBER,
                                 p_update_type IN VARCHAR2);


 PROCEDURE UPDATE_COUPON_AMOUNT(p_bond_issue_code IN VARCHAR2,
                                 p_deal_number IN NUMBER,
                                 p_transaction_number IN NUMBER
                                 );


 PROCEDURE UPDATE_BOND_DETAILS(p_bond_issue_code IN VARCHAR2,
                                 p_coupon_date IN DATE,
                                 p_ratefix_date IN DATE,
                                 p_new_rate IN NUMBER,
                                 p_count OUT NOCOPY NUMBER);

END XTR_RESET_BOND_RATE; -- Package spec

 

/
