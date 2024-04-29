--------------------------------------------------------
--  DDL for Package PJI_REP_VP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_VP_UTILS" AUTHID CURRENT_USER AS
/* $Header: PJIRX14S.pls 120.0 2005/05/29 12:18:28 appldev noship $ */

PROCEDURE Check_Plan_Version_Lock
(p_version_id NUMBER
, p_user_id NUMBER
, p_budget_forecast_flag VARCHAR2
, p_plan_type_code VARCHAR2
, x_lock_flag OUT NOCOPY VARCHAR2
, x_lock_msg OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Get_currency_tip	 (
                           p_project_id         IN     NUMBER,
                           p_curr_type          IN     VARCHAR2,
                           p_version_type       IN     VARCHAR2,
                           x_tip_msg            OUT NOCOPY   VARCHAR2,
                           x_return_status      OUT NOCOPY   VARCHAR2,
                           x_msg_count          OUT NOCOPY   NUMBER  ,
                           x_msg_data           OUT NOCOPY   VARCHAR2
                         );
/******************************************************************************
   NAME:       Pji_Vp_Rep_Locking
   PURPOSE:    Perform certain operations related to locking

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        3/25/2004             1. Created this package.

   PARAMETERS:
   INPUT:
   OUTPUT:
   RETURNED VALUE:
   CALLED BY:
   CALLS:
   EXAMPLE USE:

   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:

   Here is the complete list of automatically available Auto Replace Keywords:
      Object Name:     Pji_Vp_Rep_Locking
      Sysdate:         3/25/2004
      Date/Time:       3/25/2004 12:07:45 PM
      Date:            3/25/2004
      Time:            12:07:45 PM
      Username:         Ning
      Table Name:

******************************************************************************/
END Pji_Rep_Vp_Utils;

 

/
