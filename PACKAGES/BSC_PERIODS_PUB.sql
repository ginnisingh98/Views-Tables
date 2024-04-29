--------------------------------------------------------
--  DDL for Package BSC_PERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPPITS.pls 120.2.12000000.2 2007/01/31 09:35:07 ashankar ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPPCTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the calendar tables         |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM | 12-AUG-2005 Aditya Rao added API Get_Period_List                      |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 17-JAN-2007 ashankar Fix for the bug5654559                           |
REM +=======================================================================+
*/

G_PKG_NAME       CONSTANT VARCHAR2(30):= 'BSC_PERIODS_PUB';
C_MONTH_WEEK     CONSTANT NUMBER      := 11;
C_MONTH_DAY      CONSTANT NUMBER      := 12;


TYPE Start_End_Period_Record IS record
(
  Start_Period  VARCHAR2(32000)
, End_Period    VARCHAR2(32000)
);
TYPE Start_End_Period_Varray IS VARRAY(365) OF Start_End_Period_Record;

period_Varray Start_End_Period_Varray;

TYPE Period_Record IS record
(
  Periodicity_Id         bsc_sys_periods.periodicity_id%TYPE
, Base_Periodicity_Id    bsc_sys_periods.periodicity_id%TYPE
, Calendar_Id            bsc_sys_calendars_b.calendar_id%TYPE
, Year                   bsc_sys_periods.year%TYPE
, Periodicity_Type       bsc_sys_periodicities.periodicity_type%TYPE
, Periods                VARCHAR2(32000)
, period_Varry           Start_End_Period_Varray
, No_Of_Periods          bsc_sys_periodicities.num_of_periods%TYPE
, Created_By             bsc_sys_periods.created_by%TYPE
, Creation_Date          bsc_sys_periods.creation_date%TYPE
, Last_Updated_By        bsc_sys_periods.last_updated_by%TYPE
, Last_Update_Date       bsc_sys_periods.last_update_date%TYPE
, Last_Update_Login      bsc_sys_periods.last_update_login%TYPE
, Time_Fk                bsc_sys_periods.time_fk%TYPE
);

PROCEDURE Create_Periods
( p_Api_Version             IN          NUMBER
, p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record           IN          BSC_PERIODS_PUB.Period_Record
, p_disable_period_val_flag IN          VARCHAR2
, x_Return_Status           OUT NOCOPY  VARCHAR2
, x_Msg_Count               OUT NOCOPY  NUMBER
, x_Msg_Data                OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Periods
( p_Api_Version             IN          NUMBER
, p_Commit                  IN          VARCHAR2
, p_Period_Record           IN          BSC_PERIODS_PUB.Period_Record
, x_Structual_Change        OUT NOCOPY  BOOLEAN
, p_disable_period_val_flag IN          VARCHAR2
, x_Return_Status           OUT NOCOPY  VARCHAR2
, x_Msg_Count               OUT NOCOPY  NUMBER
, x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Delete_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Periods_Action
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, p_Action         IN          VARCHAR2
, x_Start_Period   IN          VARCHAR2
, x_End_Period     IN          VARCHAR2
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);

FUNCTION Is_Period_Modified
(p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
)RETURN VARCHAR2;

PROCEDURE Create_Periodicity_View
( p_Periodicity_Id         IN  NUMBER
, p_Short_Name             IN  VARCHAR2
, p_Calendar_Id            IN  NUMBER
, x_Periodicity_View_Name  OUT NOCOPY VARCHAR2
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Drop_Periodicity_View
( p_Periodicity_View  IN  VARCHAR2
, x_Return_Status     OUT NOCOPY  VARCHAR2
, x_Msg_Count         OUT NOCOPY  NUMBER
, x_Msg_Data          OUT NOCOPY  VARCHAR2
);

FUNCTION Get_Period_List (p_Periodicity_Id IN NUMBER) RETURN VARCHAR2;

PROCEDURE Create_Periodicity_View
(
     p_Periodicity_Id        IN         NUMBER
  ,  p_Short_Name            IN         VARCHAR2
  ,  p_Calendar_Id           IN         NUMBER
  ,  p_periodicity_Type      IN         BSC_SYS_PERIODICITIES.periodicity_type%TYPE
  ,  x_Periodicity_View_Name OUT NOCOPY VARCHAR2
  ,  x_Return_Status         OUT NOCOPY VARCHAR2
  ,  x_Msg_Count             OUT NOCOPY NUMBER
  ,  x_Msg_Data              OUT NOCOPY VARCHAR2
);
END BSC_PERIODS_PUB;

 

/
