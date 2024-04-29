--------------------------------------------------------
--  DDL for Package LNS_OCM_ADP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_OCM_ADP_PUB" AUTHID CURRENT_USER AS
/*$Header: LNS_ADP_PUBP_S.pls 120.0 2005/09/02 05:42:18 hikumar noship $ */


FUNCTION loan_request_amount(x_resultout	OUT NOCOPY VARCHAR2,
       			     x_errormsg		OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION is_secured_loan (x_resultout	OUT NOCOPY VARCHAR2,
   			  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION loan_collateral_percentage (x_resultout	OUT NOCOPY VARCHAR2,
               			     x_errormsg		OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION initial_intrest_rate (x_resultout	OUT NOCOPY VARCHAR2,
               		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION number_of_coborrowers (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION is_having_coborrowers (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION number_of_guarantors (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION is_having_guarantors (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION required_collateral_amount (x_resultout	OUT NOCOPY VARCHAR2,
                     				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_collateral_amount (x_resultout	OUT NOCOPY VARCHAR2,
                   				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION deliquency_cond_amount (x_resultout	OUT NOCOPY VARCHAR2,
                   				  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION total_assets_valuation_amt (x_resultout	OUT NOCOPY VARCHAR2,
                   				  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_assets_pledged_amt (x_resultout	OUT NOCOPY VARCHAR2,
                   				  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION total_assets_available_amt (x_resultout	OUT NOCOPY VARCHAR2,
                   				  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION number_active_loans ( x_resultout	OUT NOCOPY VARCHAR2,
      			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION balance_amt_active_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                  		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION number_pending_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                  			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION balance_amt_pending_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                 		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION number_delinquent_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   	   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION balance_amt_delinquent_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION number_default_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   	   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION balance_amt_default_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION number_paidoff_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   		   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION balance_amt_paidoff_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   		       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;


FUNCTION total_active_loans  ( x_resultout	OUT NOCOPY VARCHAR2,
              			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_bal_amt_active_loans (  x_resultout	OUT NOCOPY VARCHAR2,
              		           x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_deliquent_loans  ( x_resultout	OUT NOCOPY VARCHAR2,
                	      x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_overdue_amt_active_loans (  x_resultout	OUT NOCOPY VARCHAR2,
                      			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

FUNCTION total_defaulted_loans (  x_resultout	OUT NOCOPY VARCHAR2,
              			  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

END LNS_OCM_ADP_PUB ;

 

/
