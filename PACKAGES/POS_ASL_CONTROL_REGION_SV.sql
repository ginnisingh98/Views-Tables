--------------------------------------------------------
--  DDL for Package POS_ASL_CONTROL_REGION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASL_CONTROL_REGION_SV" AUTHID CURRENT_USER AS
/* $Header: POSASLCS.pls 115.1 1999/11/12 14:16:22 pkm ship     $*/

  /* PaintControlRegion
   * ------------------
   */
  PROCEDURE PaintControlRegion(p_position VARCHAR2,
			       p_mode VARCHAR2 DEFAULT NULL);


END POS_ASL_CONTROL_REGION_SV;

 

/
