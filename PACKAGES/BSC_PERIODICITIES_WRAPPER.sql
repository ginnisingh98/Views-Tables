--------------------------------------------------------
--  DDL for Package BSC_PERIODICITIES_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODICITIES_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCWPERS.pls 120.4 2006/04/18 22:36:35 ashankar noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCWPERS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: WRAPPER specification to manage periodicities             |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 19-SEP-2005 ashankar    Fixed Bug#4612590 in Update_Periodicity()     |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 21-MAR-2006 ashankar  Fixed bug#5099465 Modified Validate_Periodicity |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_WRAPPER';

PROCEDURE Create_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_Id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Custom_Code              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Calendar_Time_Stamp      IN          VARCHAR2 := NULL
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);


PROCEDURE Update_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2  := NULL
 ,p_Custom_Code              IN          NUMBER
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Calendar_Id              IN          NUMBER
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2 := NULL
 ,p_Calendar_Time_Stamp      IN          VARCHAR2 := NULL
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Calendar_Id              IN          NUMBER
 ,p_Action_Type              IN          VARCHAR2
 ,p_disable_period_val_flag  IN          VARCHAR2
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);

/**************************************************************
   OVERLOADED METHODS TO FIX THE BUG 4695330
/**************************************************************/

PROCEDURE Create_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_Id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Custom_Code              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Calendar_Time_Stamp      IN          VARCHAR2 := NULL
 ,p_disable_period_val_flag  IN          VARCHAR
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2  := NULL
 ,p_Custom_Code              IN          NUMBER
 ,p_disable_period_val_flag  IN          VARCHAR
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
);


END BSC_PERIODICITIES_WRAPPER;

 

/
