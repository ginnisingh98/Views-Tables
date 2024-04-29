--------------------------------------------------------
--  DDL for Package Body IBY_PCARD_RECOGNITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PCARD_RECOGNITION_PKG" AS
/* $Header: ibypcrcb.pls 120.1.12010000.2 2009/06/16 09:22:46 lyanamal ship $ */


  /*
   * Gets the purchase card subtype.
   */
   PROCEDURE getPCardSubType
	(
	p_instr_number		IN	VARCHAR,
	p_card_subtype		OUT NOCOPY PCARD_TYPEVAL
	)
   IS
	cardBIN		NUMBER;
   CURSOR pcard_type
   (ci_bin_number IN VARCHAR)
   IS
     SELECT SUBSTR(pcard_subtype,   1,   1)
     FROM iby_pcard_bin_range
     WHERE (cardBIN >= lowerlimit)
       AND (cardBIN <= upperlimit)
     ORDER BY last_updated_by DESC,
	last_update_date DESC;

   BEGIN
        IF (pcard_type%ISOPEN) THEN CLOSE pcard_type; END IF;
	cardBIN:= TO_NUMBER(SUBSTR(p_instr_number,1,C_BIN_LENGTH));

       OPEN pcard_type(cardBIN);
       FETCH pcard_type INTO p_card_subtype;

       IF (p_card_subtype IS NULL) THEN
	  p_card_subtype := C_SUBTYPE_NONPCARD;
       END IF;

       IF (pcard_type%NOTFOUND) THEN
	  p_card_subtype := C_SUBTYPE_NONPCARD;
       END IF;

       CLOSE pcard_type;


   EXCEPTION

    WHEN OTHERS THEN

	p_card_subtype := C_SUBTYPE_NONPCARD;


   END getPCardSubType;

END IBY_PCARD_RECOGNITION_PKG;

/
