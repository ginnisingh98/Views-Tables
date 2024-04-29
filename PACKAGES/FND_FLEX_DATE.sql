--------------------------------------------------------
--  DDL for Package FND_FLEX_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_DATE" AUTHID CURRENT_USER AS
  /* $Header: AFFFDTES.pls 115.0 99/07/16 23:17:57 porting ship $ */


  /* ---------------------------------------------------------------------- */
  /* Convert date format.                                                   */
  /* ---------------------------------------------------------------------- */
  FUNCTION convert_format(in_date  IN  VARCHAR2,
                          in_mask  IN  VARCHAR2,
                          out_date IN OUT VARCHAR2,
                          out_mask IN  VARCHAR2) RETURN BOOLEAN;

END FND_FLEX_DATE;

 

/
