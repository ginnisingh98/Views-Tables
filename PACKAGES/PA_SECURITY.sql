--------------------------------------------------------
--  DDL for Package PA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SECURITY" AUTHID CURRENT_USER AS
/* $Header: PAPLSECS.pls 120.1.12010000.3 2009/06/08 11:59:42 paljain ship $ */

  G_user_id		   NUMBER;
  G_person_id		   NUMBER;
  G_module_name		   VARCHAR2(30);
  G_query_allowed	   VARCHAR2(1);
  G_update_allowed     	   VARCHAR2(1);
  G_view_labor_costs	   VARCHAR2(1);
  G_cross_project_user     VARCHAR2(1);
  G_cross_project_view     VARCHAR2(1);
  G_proj_id		   NUMBER := NULL;     --7716514
  G_allow_result	   NUMBER := NULL;     --7716514

  FUNCTION view_labor_costs_new ( X_project_id      IN NUMBER) RETURN NUMBER;   --7716514
  FUNCTION view_labor_costs_new2 ( X_project_id      IN NUMBER) RETURN VARCHAR2; -- 8460451
  PROCEDURE Initialize ( X_user_id	IN NUMBER
                       , X_calling_module  IN VARCHAR2 );

  FUNCTION allow_query ( X_project_id     IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (allow_query, WNDS, WNPS);

  FUNCTION allow_update ( X_project_id     IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (allow_update, WNDS, WNPS);

  FUNCTION view_labor_costs ( X_project_id     IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (view_labor_costs, WNDS, WNPS);

  PROCEDURE set_value ( X_security_level  IN VARCHAR2
		      , X_value	          IN VARCHAR2 );

  FUNCTION check_key_member ( X_person_id    IN NUMBER
                            , X_project_id   IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (check_key_member, WNDS, WNPS);

  FUNCTION check_key_member_no_dates (X_person_id    IN NUMBER
                                    , X_project_id   IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (check_key_member_no_dates, WNDS, WNPS);

  FUNCTION check_labor_cost_access ( X_person_id   IN NUMBER
                                   , X_project_id  IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (check_labor_cost_access, WNDS, WNPS);

  FUNCTION check_project_authority ( X_person_id  IN NUMBER,
                                     X_project_id IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (check_project_authority, WNDS, WNPS, TRUST);
     /* added trust pragma option to call functions that do not have pragma defined like pa_security_pvt.get_grantee_key */

/* Enhancement 6519194*/
/*  FUNCTION check_forecast_authority ( X_person_id  IN NUMBER,
                                      X_project_id IN NUMBER ) RETURN VARCHAR2;*/

/*  pragma RESTRICT_REFERENCES (check_forecast_authority, WNDS, WNPS, TRUST);*/
     /* added trust pragma option to call functions that do not have pragma defined like pa_security_pvt.get_grantee_key */

END pa_security;

/
