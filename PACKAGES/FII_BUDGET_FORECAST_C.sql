--------------------------------------------------------
--  DDL for Package FII_BUDGET_FORECAST_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_BUDGET_FORECAST_C" AUTHID CURRENT_USER AS
/* $Header: FIIBUUPS.pls 120.5 2005/10/30 05:07:41 appldev noship $ */

--
-- PUBLIC VARIABLES
--
FIIBUUP_PRIM_CURR_CODE		VARCHAR2(15) := NULL;
FIIBUUP_SEC_CURR_CODE		VARCHAR2(15) := NULL;
FIIBUUP_PRIM_CURR_MAU	 	NUMBER	     := NULL;
FIIBUUP_SEC_CURR_MAU		NUMBER	     := NULL;
FIIBUUP_BUDGET_TIME_UNIT	VARCHAR2(1)  := NULL;
FIIBUUP_FORECAST_TIME_UNIT	VARCHAR2(1)  := NULL;
FIIBUUP_USER_ID			NUMBER(15)   := NULL;
FIIBUUP_LOGIN_ID		NUMBER(15)   := NULL;
FIIBUUP_REQ_ID			NUMBER(15)   := NULL;
FIIBUUP_DEBUG			BOOLEAN	     := FALSE;
FIIBUUP_PURGE_PLAN_TYPE		VARCHAR2(1)  := NULL;
FIIBUUP_PURGE_TIME_UNIT		VARCHAR2(1)  := NULL;
FIIBUUP_PURGE_DATE		DATE	     := NULL;
FIIBUUP_PURGE_EFF_DATE          DATE         := NULL;
FIIBUUP_PURGE_TIME_PERIOD	VARCHAR2(100):= NULL;
FIIBUUP_GLOBAL_START_DATE       DATE         := NULL;
FIIBUUP_UNASSIGNED_UDD_ID       NUMBER(15)   := NULL;

--
-- PUBLIC PROCEDURES

  --
  -- Procedure
  --   	Main
  -- Purpose
  --   	This is the main routine of the DBI budget upload program
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  -- 	X_Mode: Mode of Operation.  Either U (Upload) or P (Purge)
  --    X_Plan_Type	: Plan type to operate on.  Either B (Budget),
  --		     	  F (Forecast) or A (Both).  Used only in Purge.
  --    X_Time_Unit	: Either D (Daily), P (Period), Q (Quarter) or Y (Year).
  --		     	  Used only in Purge.
  --    X_Date	   	: Purge date
  --	X_Time_Period   : Purge time period (other than date)
  --    X_Debug    	: Debug mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Main;
  -- Notes
  --
  PROCEDURE Main( X_Mode		IN	VARCHAR2,
		  X_Plan_Type		IN	VARCHAR2	DEFAULT NULL,
		  X_Time_Unit		IN	VARCHAR2	DEFAULT NULL,
		  X_Purge_Date		IN	VARCHAR2	DEFAULT NULL,
		  X_Purge_Time_Period	IN	VARCHAR2	DEFAULT NULL,
                  X_Purge_Eff_Date      IN      VARCHAR2        DEFAULT NULL,
		  X_Debug		IN	VARCHAR2	DEFAULT NULL);

  --
  -- Procedure
  --   	Upload
  -- Purpose
  --   	This is the concurrent job version of the Upload program.  This will
  --    be used when submitting the program through forms.
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  -- 	X_Debug: Debug Mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Upload(errbuf, retcode);
  -- Notes
  --
  PROCEDURE Upload(errbuf	OUT	NOCOPY VARCHAR2,
		   retcode	OUT	NOCOPY VARCHAR2,
		   X_Debug	IN	VARCHAR2   DEFAULT NULL);


  --
  -- Procedure
  --   	Purge
  -- Purpose
  --   	This is the concurrent job version of the Purge program.  This will be
  --    used when submitting the program through forms.
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  --    X_Plan_Type	: Plan type to operate on.  Either B (Budget)
  --		     	  or F (Forecast).  Used only in Purge.
  --    X_Time_Unit	: Either D (Daily), P (Period), Q (Quarter), Y (Year),
  --		     	  or A (All).  Used only in Purge.
  --    X_Date	   	: Purge date
  --	X_Time_Period   : Purge time period (other than date)
  --    X_Debug    	: Debug mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Purge
  --				(errbuf, retcode, 'B', 'P', 'Jan-01');
  -- Notes
  --
  PROCEDURE Purge(errbuf		OUT	NOCOPY VARCHAR2,
		  retcode		OUT	NOCOPY VARCHAR2,
		  X_Plan_Type		IN	VARCHAR2	DEFAULT NULL,
		  X_Time_Unit		IN	VARCHAR2	DEFAULT NULL,
		  X_Purge_Date		IN	VARCHAR2	DEFAULT NULL,
		  X_Purge_Time_Period	IN	VARCHAR2	DEFAULT NULL,
                  X_Purge_Eff_Date      IN      VARCHAR2        DEFAULT NULL,
		  X_Debug		IN	VARCHAR2   	DEFAULT NULL);


END FII_BUDGET_FORECAST_C;


 

/
