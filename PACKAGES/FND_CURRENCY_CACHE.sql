--------------------------------------------------------
--  DDL for Package FND_CURRENCY_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CURRENCY_CACHE" AUTHID CURRENT_USER as
/* $Header: AFMLCUCS.pls 120.2 2005/11/02 14:05:10 fskinner noship $ */


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


/*
** GET_INFO- get the precision information for a currency code
**
** returns information about a currency code, based on the
** cache of currency information from the FND db table.
**
*/
 procedure GET_INFO(
    currency_code  IN  VARCHAR2, /* currency code */
    precision      OUT nocopy NUMBER, /* number of digits to right of decimal*/
    ext_precision  OUT nocopy NUMBER, /* precision where more precision is needed*/
    min_acct_unit  OUT nocopy NUMBER  /* minimum value by which amt can vary */
 );


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
    format_mask    OUT nocopy VARCHAR2,
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

END FND_CURRENCY_CACHE;


 

/
