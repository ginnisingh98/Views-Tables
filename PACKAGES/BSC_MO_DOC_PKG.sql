--------------------------------------------------------
--  DDL for Package BSC_MO_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_DOC_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMODCS.pls 120.0 2005/06/01 15:53:40 appldev noship $ */
TYPE CurTyp IS REF CURSOR;
gDocIndicators BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator;
PROCEDURE Documentation (pMode IN NUMBER DEFAULT 1) ;
Function StrFix(p_string IN VARCHAR2, p_length IN NUMBER, p_center IN BOOLEAN DEFAULT FALSE) RETURN VARCHAR2;
Function GetPeriodicityName(Periodicity IN NUMBER) RETURN VARCHAR2;
Function GetMaxPeriod(Periodicity IN NUMBER) RETURN NUMBER;
Function GetMaxSubPeriodUsr(Periodicity IN NUMBER) RETURN NUMBER;
Function GetPeriodicityCalendarName(periodicity_id IN NUMBER) RETURN VARCHAR2;
END BSC_MO_DOC_PKG;

 

/
