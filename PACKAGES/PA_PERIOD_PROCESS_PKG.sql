--------------------------------------------------------
--  DDL for Package PA_PERIOD_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERIOD_PROCESS_PKG" AUTHID CURRENT_USER as
-- $Header: PAGLPKGS.pls 120.1 2005/08/10 14:38:58 eyefimov noship $

Enable_New_GL_Date_Der              VARCHAR2(1);

--
-- Function		: Is_enabled
-- Purpose		: This functions returns 'Y' if the profile option
--                        PA_EN_NEW_GLDATE_DERIVATION is set as 'Y' otherwise 'N'.
-- Parameters		: None.
--
FUNCTION Is_enabled  RETURN VARCHAR2 	;

G_Application_Id                    NUMBER;

--
-- Function             : Application_id
-- Purpose              : This functions returns the application id based on profile
--                            PA_EN_NEW_GLDATE_DERIVATION. If this profile is set as 'Y' then
--                it will returnn 8271. Else it will return 101.
-- Parameters           : None.
--

FUNCTION Application_id  RETURN NUMBER  ;

--
-- Function             : Use_Same_PA_GL_Period
-- Purpose              : This functions returns 'Y' if the implementation option
--                        Maintain Common PA and GL Periods is set as 'Y' otherwise 'N'.
-- Parameters           : None.
--
-- Bug#2103722
--  Added parameter p_org_id.
--
FUNCTION Use_Same_PA_GL_Period(p_org_id IN pa_implementations_all.org_id%TYPE DEFAULT NULL) RETURN VARCHAR2 ;

--
-- Procedure            : Update_PA_Period_Status
-- Purpose              : This procedure will update the PA period status when the
--                        Implementation option - Maintain Common PA and GL Periods
--                        is set to Yes and the Profile - Enable Enhanced Period
--                        Processing is set to Yes.
--                        This API is called from the GL Periods Form - PAXPAGLP.fmb
-- Parameters           : None.
--
PROCEDURE Update_PA_Period_Status ;

--Procedure            : Check_Imp_Option_Controls
--Purpose              : This procedure is called from the implementation form
--                       when the user changes the option - Maintain Common PA
--                       and GL Periods from N to Y.
--                       The checks that are performed are as follows:
--                       1. See if the calendar and period_type for GL and PA
--                          period are the same
--                       2. Check if the profile PA: Enable Enhanced Period Processing
--                          is enabled.
--                       3. Check if the PA period status is in sync with the GL period
--                          status
PROCEDURE Check_Imp_Option_Controls(p_period_set_name in varchar2,
                         p_pa_period_type  in varchar2,
                         p_sob_id          in number,
                         p_org_id          in number,
                         x_return_status   out nocopy varchar2,
                         x_error_message_code out nocopy varchar2);


END PA_PERIOD_PROCESS_PKG;
 

/
