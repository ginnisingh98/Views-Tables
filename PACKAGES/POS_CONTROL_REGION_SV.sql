--------------------------------------------------------
--  DDL for Package POS_CONTROL_REGION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_CONTROL_REGION_SV" AUTHID CURRENT_USER AS
/* $Header: POSCTRLS.pls 115.0 99/08/20 11:09:23 porting sh $*/

  /* PaintControlRegion
   * ------------------
   */
  PROCEDURE PaintControlRegion(p_position VARCHAR2);


END POS_CONTROL_REGION_SV;

 

/
