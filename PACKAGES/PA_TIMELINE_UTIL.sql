--------------------------------------------------------
--  DDL for Package PA_TIMELINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIMELINE_UTIL" AUTHID CURRENT_USER as
/* $Header: PARLUTSS.pls 120.1 2005/08/19 16:56:31 mwasowic noship $   */

--
-- Procedure            : Create_time_scale
-- Purpose              : Creating time scale and time marking and insert record into
--                        pa_timeline_time_scale.

PROCEDURE Create_Time_Scale( p_start_date                 IN   DATE,
														 p_end_date                   IN   DATE := null,
                             p_scale_type                 IN   VARCHAR2,
                             x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Function to get the week end date for given org id and given date

FUNCTION Get_Week_End_Date(p_org_id     IN NUMBER,
                           p_given_date IN DATE) RETURN DATE;

--pragma RESTRICT_REFERENCES (Get_Week_End_Date, WNDS, WNPS);

-- procedure to get the timeline period for the given date

PROCEDURE Get_Timeline_Period ( p_current_date 		 IN DATE,
																p_num_days         IN NUMBER := null,
				p_scale_type		 IN VARCHAR2,
				p_navigate_type		 IN VARCHAR2,
				p_org_id		 IN NUMBER,
				x_period_start_date	OUT NOCOPY DATE, --File.Sql.39 bug 4440895
				x_period_end_date	OUT NOCOPY DATE, --File.Sql.39 bug 4440895
      				x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             	x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             	x_msg_data              OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- procedure to build array of week start and date for a range of dates

PROCEDURE Get_Week_Dates_Range( p_org_id                IN      NUMBER,
                                p_start_date            IN      DATE,
                                p_end_date              IN      DATE,
                                x_WeekDatesRangeTab     OUT     NOCOPY PA_TIMELINE_GLOB.WeekDatesRangeTabTyp, --File.Sql.39 bug 4440895
                                x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- function to get color codes

FUNCTION Get_Color_Pattern_Code(p_lookup_code IN VARCHAR2) RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (Get_Color_Pattern_Code, WNDS, WNPS);

-- function to get the profile information

FUNCTION Get_Timeline_Profile_Setup RETURN PA_TIMELINE_GLOB.TimelineProfileSetup;
-- pragma RESTRICT_REFERENCES (Get_Timeline_Profile_Setup,WNDS,WNPS);

-- debug procedure

PROCEDURE debug(p_text IN VARCHAR2);

PROCEDURE debug(p_module IN VARCHAR2,
                p_msg IN VARCHAR2,
                p_log_level IN NUMBER DEFAULT 6);

END PA_TIMELINE_UTIL;
 

/
