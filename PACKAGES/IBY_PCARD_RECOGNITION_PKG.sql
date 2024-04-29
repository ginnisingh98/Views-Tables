--------------------------------------------------------
--  DDL for Package IBY_PCARD_RECOGNITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PCARD_RECOGNITION_PKG" AUTHID CURRENT_USER AS
/* $Header: ibypcrcs.pls 115.4 2002/11/19 01:45:29 jleybovi noship $ */


  /* Length of a credit card's bank identification number. */
  C_BIN_LENGTH CONSTANT NUMBER := 9;


  SUBTYPE PCARD_TYPEVAL IS VARCHAR2(1);

  /* Corporate purchase card subtype. */
  C_SUBTYPE_CORPORATE CONSTANT PCARD_TYPEVAL := 'C';

  /* Purchase purchase card subtype. */
  C_SUBTYPE_PURCHASE CONSTANT PCARD_TYPEVAL := 'P';

  /* Business purchase card subtype. */
  C_SUBTYPE_BUSINESS CONSTANT PCARD_TYPEVAL := 'B';

  /* Fleet purchase card subtype. */
  C_SUBTYPE_FLEET CONSTANT PCARD_TYPEVAL := 'F';

  /* Fleet purchase card subtype. */
  C_SUBTYPE_GOVERNMENT CONSTANT PCARD_TYPEVAL := 'G';

  /* For credit card numbers which do not belong to purchase cards. */
  C_SUBTYPE_NONPCARD CONSTANT PCARD_TYPEVAL := 'U';


  /*
   * USE: Gets the purchase card subtype associated with a given
   *      credit card number.
   *
   * ARGS:
   *    1.  the instrument number/credit card number; must consist
   *	    entirely of digits (i.e. '4111-411...' is not allowed!)
   *
   * OUTS:
   *    2.  the purchase card subtype associated with the given
   *        number; will be value C_SUBTYPE_NONPCARD if the number
   *        is not that of a purchase card.
   *
   */
   PROCEDURE getPCardSubType
	(
	p_instr_number		IN	VARCHAR,
	p_card_subtype		OUT NOCOPY PCARD_TYPEVAL
	);


END IBY_PCARD_RECOGNITION_PKG;

 

/
