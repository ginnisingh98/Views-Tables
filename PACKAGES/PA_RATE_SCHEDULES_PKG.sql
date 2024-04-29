--------------------------------------------------------
--  DDL for Package PA_RATE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RATE_SCHEDULES_PKG" AUTHID CURRENT_USER AS
-- $Header: PARTSCHS.pls 120.1 2005/08/19 17:01:32 mwasowic noship $

-- Following API is added for Billing Enhancements for Patchset L

  PROCEDURE Copy_Rate_Schedules (
    P_Source_Organization_ID    IN  NUMBER,
    P_Source_Rate_Schedule      IN  VARCHAR2,
    P_Organization_ID           IN  NUMBER,
    P_Rate_Schedule             IN  VARCHAR2,
    P_Rate_Schedule_Desc        IN  VARCHAR2,
    P_Rate_Sch_Currency_Code    IN  VARCHAR2,
    P_Share_Across_OU_Flag      IN  VARCHAR2,
    P_Escalated_Rate_Perc       IN  NUMBER  DEFAULT 0,
    P_Escalated_Markup_Perc     IN  NUMBER  DEFAULT 0,
    X_Return_Status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Msg_Data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


END PA_Rate_Schedules_PKG;

 

/
