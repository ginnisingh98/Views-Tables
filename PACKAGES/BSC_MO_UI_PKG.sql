--------------------------------------------------------
--  DDL for Package BSC_MO_UI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_UI_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOUIS.pls 120.3 2006/08/04 13:09:54 amitgupt noship $ */
G_PKG_NAME VARCHAR2(30) := 'BSC_MO_UI_PKG';
TYPE CurTyp IS REF CURSOR;

--pMode = 'ALL' or 'INCREMENTAL'
--PROCEDURE updateRelatedIndicatorsNew(pMode IN VARCHAR2);
PROCEDURE RenameInputTable(pOld IN VARCHAR2, pNew IN VARCHAR2, pStatus OUT NOCOPY VARCHAR2, pMessage OUT NOCOPY VARCHAR2) ;
PROCEDURE updateRelatedIndicators(pMode IN VARCHAR2, pProcessId IN NUMBER);
PROCEDURE  GetLevelsForIndicator(pIndicator IN NUMBER) ; --RETURN tab_clsIndicatorLevels;
FUNCTION GetDescriptionForColumn(pTableName IN VARCHAR2, pColumnName IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE launchOptimizer(pMode IN VARCHAR2, pRequestId OUT NOCOPY NUMBER, pStatus OUT NOCOPY VARCHAR2, pMessage OUT NOCOPY VARCHAR2);
PROCEDURE truncateTable(pTableName IN VARCHAR2, pSchema IN VARCHAR2 DEFAULT null);
FUNCTION getColDetails(pColType IN VARCHAR2, pTableName IN VARCHAR2, pTabType IN VARCHAR2) return CLOB ;
PROCEDURE getRelatedIndicators(pKPIList IN VARCHAR2, pProcessId IN NUMBER);
PROCEDURE deleteBSCSession(pSession IN NUMBER);
PROCEDURE CreateDBMeasureByKpiView;
PROCEDURE cleanUITempTable;
PROCEDURE checkSystemLock(p_all_objectives IN NUMBER, p_program_id IN NUMBER, p_user_id IN NUMBER, p_process_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2, x_msg_count OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2);
PROCEDURE getSystemLock(p_all_objectives IN NUMBER, p_query_time IN DATE, p_program_id IN NUMBER, p_user_id IN NUMBER, p_process_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2, x_msg_count OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2);

END BSC_MO_UI_PKG;

 

/
