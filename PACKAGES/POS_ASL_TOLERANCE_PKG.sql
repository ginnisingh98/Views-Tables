--------------------------------------------------------
--  DDL for Package POS_ASL_TOLERANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASL_TOLERANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: POSASLTS.pls 115.0 99/08/20 11:07:52 porting sh $ */

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id NUMBER;
  l_request_id NUMBER;

  TYPE t_text_table is table of varchar2(240) index by binary_integer;
  g_dummy t_text_table;

  PROCEDURE tolerance_frame(pos_asl_id        IN VARCHAR2 DEFAULT NULL);

  PROCEDURE submit_tolerance(pos_asl_id       IN t_text_table DEFAULT g_dummy,
                  pos_using_organization_id   IN t_text_table DEFAULT g_dummy,
                  pos_days_in_advance         IN t_text_table DEFAULT g_dummy,
                  pos_tolerance               IN t_text_table DEFAULT g_dummy,
                  p_asl_id                    IN VARCHAR2 DEFAULT NULL,
                  pos_tol_action              IN VARCHAR2 DEFAULT NULL,
                  pos_tol_rows                IN VARCHAR2 DEFAULT NULL,
                  pos_more_rows               IN VARCHAR2 DEFAULT NULL,
                  pos_error_row               IN VARCHAR2 DEFAULT NULL  );


END POS_ASL_TOLERANCE_PKG;

 

/
