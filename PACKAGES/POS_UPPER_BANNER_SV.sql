--------------------------------------------------------
--  DDL for Package POS_UPPER_BANNER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_UPPER_BANNER_SV" AUTHID CURRENT_USER AS
/* $Header: POSUPBNS.pls 115.0 2001/10/22 17:09:42 pkm ship   $*/

  /* PaintLowerBanner
   * ----------------
   */
  PROCEDURE PaintUpperBanner(p_product VARCHAR2, p_title VARCHAR2);

  /* ModalWindowTitle
   * ----------------
   */
  PROCEDURE ModalWindowTitle(p_title VARCHAR2);


END POS_UPPER_BANNER_SV;

 

/
