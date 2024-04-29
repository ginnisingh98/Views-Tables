--------------------------------------------------------
--  DDL for Package FND_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CURRENCY" AUTHID CURRENT_USER as
/* $Header: AFMLCURS.pls 115.6 2003/01/06 19:28:53 pdeluna ship $ */


/* GET_FORMAT_MASK- get the format mask for a particular currency.
**
** Returns a currency format mask to be used with the forms
** SET_ITEM_PROPERTY(item_name, FORMAT_MASK,
** FND_CURRENCY.GET_FORMAT_MASK(...)) built-in call,
** or the PLSQL to_char() routine, based on the currency code passed in.
**
*/
 function GET_FORMAT_MASK( currency_code   IN VARCHAR2,
                            field_length    IN NUMBER)
  return VARCHAR2;
  pragma restrict_references(GET_FORMAT_MASK, WNDS);


/* SAFE_GET_FORMAT_MASK-  slower version of GET_FORMAT_MASK
**                         without WNPS pragma restrictions.
**
** This version of GET_FORMAT_MASK uses slower,
** non-caching profiles functions to do its defaulting.  It runs
** about half the speed of GET_FORMAT_MASK, but it can
** be used in situations, like where clauses, in views, that
** GET_FORMAT_MASK cannot be used due to pragma restrictions.
*/
 function SAFE_GET_FORMAT_MASK( currency_code   IN VARCHAR2,
                            field_length    IN NUMBER)
  return VARCHAR2;
  pragma restrict_references(SAFE_GET_FORMAT_MASK, WNDS, WNPS);

/*
** GET_INFO- get the precision information for a currency code
**
** returns information about a currency code, based on the
** cache of currency information from the FND db table.
**
*/
 procedure GET_INFO(
    currency_code  IN  VARCHAR2, /* currency code */
    precision      OUT NOCOPY NUMBER, /* number of digits to right of decimal*/
    ext_precision  OUT NOCOPY NUMBER, /* precision if more precision needed*/
    min_acct_unit  OUT NOCOPY NUMBER  /* min value by which amt can vary */
 );
 pragma restrict_references(GET_INFO, WNDS, WNPS, RNPS);


/* BUILD_FORMAT_MASK- create a format mask for a currency value
**
** Creates a currency format mask to be used with forms
** SET_ITEM_PROPERTY(item_name, FORMAT_MASK, new_format_mask)
** built-in call, or the PLSQL to_char() routine,
** based on the currency parameters passed in.
**
** Note that if neg_format is '-XXX', then pos_format must
** be '+XXX' or 'XXX'.
**
** If the last three parameters are left off, their values will
** default from the profile value system.
*/
 procedure BUILD_FORMAT_MASK(
    format_mask    OUT NOCOPY VARCHAR2,
    field_length   IN  NUMBER,  /* maximum number of char in dest field */
    precision      IN  NUMBER,  /* number of digits to right of decimal*/
    min_acct_unit  IN  NUMBER,  /* minimum value by which amt can vary */
    disp_grp_sep   IN  BOOLEAN default NULL,
	 /* NULL=from profile CURRENCY:THOUSANDS_SEPARATOR */
    neg_format     IN  VARCHAR2 default NULL,
	 /* '-XXX', 'XXX-', '<XXX>', */
	 /* NULL=from profile CURRENCY:NEGATVE_FORMAT */
    pos_format     IN  VARCHAR2 default NULL
	 /* 'XXX', '+XXX', 'XXX-', */
	 /* NULL=from profile CURRENCY:POSITIVE_FORMAT*/
 );
 pragma restrict_references(BUILD_FORMAT_MASK, WNDS);


/* SAFE_BUILD_FORMAT_MASK- slower version of BUILD_FORMAT_MASK
**                         without WNPS pragma restrictions.
**
** This version of BUILD_FORMAT_MASK uses slower,
** non-caching profiles functions to do its defaulting.  It runs
** about half the speed of BUILD_FORMAT_MASK, but it can
** be used in situations, like views, that BUILD_FORMAT_MASK
** cannot be used due to pragma restrictions.
** Note, however, that if you pass values for the
** disp_grp_sep, neg_format, and pos_format parameters instead
** of letting them default to NULL, then this routine will
** not be any slower than BUILD_FORMAT_MASK
*/
 procedure SAFE_BUILD_FORMAT_MASK(
    format_mask    OUT NOCOPY VARCHAR2,
    field_length   IN  NUMBER,  /* maximum number of char in dest field */
    precision      IN  NUMBER,  /* number of digits to right of decimal*/
    min_acct_unit  IN  NUMBER,  /* minimum value by which amt can vary */
    disp_grp_sep   IN  BOOLEAN default NULL,
	 /* NULL=from profile CURRENCY:THOUSANDS_SEPARATOR */
    neg_format     IN  VARCHAR2 default NULL,
	 /* '-XXX', 'XXX-', '<XXX>', */
	 /* NULL=from profile CURRENCY:NEGATVE_FORMAT */
    pos_format     IN  VARCHAR2 default NULL
	 /* 'XXX', '+XXX', 'XXX-', */
	 /* NULL=from profile CURRENCY:POSITIVE_FORMAT*/
 );
 pragma restrict_references(SAFE_BUILD_FORMAT_MASK, WNDS, WNPS);

END FND_CURRENCY;


 

/
