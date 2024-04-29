--------------------------------------------------------
--  DDL for Package GL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_INFO" AUTHID CURRENT_USER as
/* $Header: gluplifs.pls 120.4 2005/05/05 01:42:03 kvora ship $ */
  procedure gl_get_period_dates (tledger_id IN NUMBER,
                                 tperiod_name     IN VARCHAR2,
                                 tstart_date      OUT NOCOPY DATE,
                                 tend_date        OUT NOCOPY DATE,
				 errbuf	   	  OUT NOCOPY VARCHAR2);

--   NAME
--     gl_get_ledger_info
--   DESCRIPTION
--     Gets the chart of accounts id and the name of the
--     ledger provided.
--   PARAMETERS
--     ledid     - holds the  ledger id
--     coaid     - holds the returned chart of accounts id
--     ledname   - holds the returned ledger name
--     func_curr - holds the returned functional currency
--     errbuf    - holds the returned error message, if there is one
  procedure gl_get_ledger_info ( ledid IN NUMBER,
                                       coaid OUT NOCOPY NUMBER,
                                       ledname OUT NOCOPY VARCHAR2,
                                       func_curr OUT NOCOPY VARCHAR2,
                                       errbuf OUT NOCOPY VARCHAR2);

--   NAME
--     gl_get_bud_or_enc_name
--   DESCRIPTION
--     This routine takes the actual type (Actual, Budget,
--     or Encumbrance) and the budget version id or the
--     encumbrance type id.  It returns null, for an
--     actual type of Actual, the name of the budget, for
--     Budget, or the encumbrance type, for Encumbrance.
--   PARAMETERS
--     actual_type - A (Actual), B (Budget), or
--                   E (Encumbrance)
--     type_id     - the budget version ID of the budget or
--                   the encumbrance type ID for the
--                   encumbrance
--     name        - holds the returned value: null, for actuals; the budget
--                                             name, for budgets; and the
--                                             encumbrance type, for
--                                             encumbrances.
--     errbuf      - holds the returned error message, if there is one
procedure gl_get_bud_or_enc_name ( actual_type IN VARCHAR2,
                                   type_id IN NUMBER,
                                   name   OUT NOCOPY VARCHAR2,
                                   errbuf OUT NOCOPY VARCHAR2);

--   NAME
--     gl_get_lookup_value
--   DESCRIPTION
--     This function gets the meaning or description of a
--     lookup code for a particular lookup type
--   PARAMETERS
--     lmode   - M (Meaning) or D (Description)
--     code    - the lookup code
--     type    - the lookup type
--     errbuf  - holds the returned error message, if there is one
procedure gl_get_lookup_value ( lmode VARCHAR2,
                                code  VARCHAR2,
                                type  VARCHAR2,
                                value OUT NOCOPY VARCHAR2,
                                errbuf OUT NOCOPY VARCHAR2);

--   NAME
--     gl_get_first_period
--   DESCRIPTION
--     This function gets the first period of the year
--     for a particular period_name
--   PARAMETERS
--     tledger_id   - valid ledger_id (IN)
--     tperiod_name	  - valid period_name (IN)
--     tfirst_period	  - first period of the year
--     errbuf  - holds the returned error message, if there is one
procedure gl_get_first_period(tledger_id IN NUMBER,
                              tperiod_name     IN VARCHAR2,
                              tfirst_period    OUT NOCOPY VARCHAR2,
			      errbuf	       OUT NOCOPY VARCHAR2);

-- Kai Pigg 7/6/1993. New procedure
--   NAME
--     gl_get_first_period_of_quarter
--   DESCRIPTION
--     This function gets the first period of the quarter
--     for a particular period_name
--   PARAMETERS
--     tledger_id   - valid ledger_id (IN)
--     tperiod_name	  - valid period_name (IN)
--     tfirst_period	  - first period of the quarter
--     errbuf  - holds the returned error message, if there is one
procedure gl_get_first_period_of_quarter(tledger_id IN NUMBER,
                              tperiod_name     IN VARCHAR2,
                              tfirst_period    OUT NOCOPY VARCHAR2,
			      errbuf	       OUT NOCOPY VARCHAR2);

--   NAME
--     gl_get_consolidation_info
--   PURPOSE
--     Gets various information about a consolidation
--   PARAMETERS
--     cons_id     - the id of the consolidation
--     cons_name   - the name of the consolidation
--     method      - the method of consolidation (this is a code use
--                   gl_lookups to get the method name)
--     curr_code   - the consolidation currency code
--     from_ledid  - the id of the child ledger.
--     to_ledid    - the id of the parentledgers.
--     description - the description of the consolidation
--     start_date  - the start date for the consolidation
--     end_date    - the end date for the consolidation
--     errbuf      - holds any returned error messages
procedure gl_get_consolidation_info(
                           cons_id NUMBER, cons_name OUT NOCOPY VARCHAR2,
                           method OUT NOCOPY VARCHAR2, curr_code OUT NOCOPY VARCHAR2,
                           from_ledid OUT NOCOPY NUMBER, to_ledid OUT NOCOPY NUMBER,
                           description OUT NOCOPY VARCHAR2,
                           errbuf OUT NOCOPY VARCHAR2);
end gl_info;


 

/
