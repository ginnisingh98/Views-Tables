--------------------------------------------------------
--  DDL for Package BSC_BIS_PMDLDR_DELDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_PMDLDR_DELDATA" AUTHID CURRENT_USER AS
/* $Header: BSCPMDDS.pls 115.2 2003/09/11 23:06:10 ili ship $ */

 PROCEDURE  INITIALIZE;
 PROCEDURE  SELECT_INDICATOR(p_ind number);
 PROCEDURE  GET_RELATED_INDICATORS;
 PROCEDURE  SET_RECURSIVE_LEVEL( P_lvl number);
END BSC_BIS_PMDLDR_DELDATA;

 

/
