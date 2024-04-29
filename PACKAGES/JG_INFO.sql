--------------------------------------------------------
--  DDL for Package JG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_INFO" AUTHID CURRENT_USER as
/* $Header: jgzzinfs.pls 115.1 2002/11/15 17:07:28 arimai ship $ */

--   NAME
--     jg_get_set_of_books_info
--   DESCRIPTION
--     Gets the chart of accounts id and the name of the
--     set of books provided.
--   PARAMETERS
--     sobid     - holds the set of books id
--     coaid     - holds the returned chart of accounts id
--     sobname   - holds the returned set of books name
--     func_curr - holds the returned functional currency
--     errbuf    - holds the returned error message, if there is one
  procedure jg_get_set_of_books_info ( sobid IN NUMBER,
                                       coaid OUT NOCOPY NUMBER,
                                       sobname OUT NOCOPY VARCHAR2,
                                       func_curr OUT NOCOPY VARCHAR2,
                                       errbuf OUT NOCOPY VARCHAR2);
--   NAME
--     jg_get_bud_or_enc_name
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
procedure jg_get_bud_or_enc_name ( actual_type IN VARCHAR2,
                                   type_id IN NUMBER,
                                   name   OUT NOCOPY VARCHAR2,
                                   errbuf OUT NOCOPY VARCHAR2);
--   NAME
--     jg_get_lookup_value
--   DESCRIPTION
--     This function gets the meaning or description of a
--     lookup code for a particular lookup type
--   PARAMETERS
--     lmode   - M (Meaning) or D (Description)
--     code    - the lookup code
--     type    - the lookup type
--     errbuf  - holds the returned error message, if there is one
procedure jg_get_lookup_value ( lmode VARCHAR2,
                                code  VARCHAR2,
                                type  VARCHAR2,
                                value OUT NOCOPY VARCHAR2,
                                errbuf OUT NOCOPY VARCHAR2);
--   NAME
--     jg_get_first_period
--   DESCRIPTION
--     This function gets the first period of the year
--     for a particular period_name
--   PARAMETERS
--     tset_of_books_id   - valid set_of_books_id (IN)
--     tperiod_name	  - valid period_name (IN)
--     tfirst_period	  - first period of the year
--     errbuf  - holds the returned error message, if there is one
procedure jg_get_first_period(app_id           IN  NUMBER,
			      tset_of_books_id IN NUMBER,
                              tperiod_name     IN VARCHAR2,
                              tfirst_period    OUT NOCOPY VARCHAR2,
			      errbuf	       OUT NOCOPY VARCHAR2);
-- Kai Pigg 7/6/1993. New procedure
--   NAME
--     jg_get_first_period_of_quarter
--   DESCRIPTION
--     This function gets the first period of the quarter
--     for a particular period_name
--   PARAMETERS
--     tset_of_books_id   - valid set_of_books_id (IN)
--     tperiod_name	  - valid period_name (IN)
--     tfirst_period	  - first period of the quarter
--     errbuf  - holds the returned error message, if there is one
procedure jg_get_first_period_of_quarter(app_id IN  NUMBER,
			      tset_of_books_id IN NUMBER,
                              tperiod_name     IN VARCHAR2,
                              tfirst_period    OUT NOCOPY VARCHAR2,
			      errbuf	       OUT NOCOPY VARCHAR2);
function jg_format_curr_amt(in_precision NUMBER,
                            in_amount_disp VARCHAR2) return VARCHAR2;
end jg_info;

 

/
