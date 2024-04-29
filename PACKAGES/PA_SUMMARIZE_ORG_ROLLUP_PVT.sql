--------------------------------------------------------
--  DDL for Package PA_SUMMARIZE_ORG_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SUMMARIZE_ORG_ROLLUP_PVT" AUTHID CURRENT_USER AS
/* $Header: PARRORGS.pls 115.4 2002/03/04 04:51:15 pkm ship     $ */

  PROCEDURE refresh_org_hierarchy_rollup( p_balance_type_code  IN VARCHAR2);

  PROCEDURE create_missing_parent_objects( p_balance_type_code  IN VARCHAR2);

  PROCEDURE org_rollup_pagl_period_type( p_balance_type_code          IN VARCHAR2
                                        ,p_period_type                IN VARCHAR2
                                        ,p_effective_start_period_num IN PLS_INTEGER
                                       );

  PROCEDURE org_rollup_ge_period_type( p_balance_type_code   IN VARCHAR2
                                      ,p_period_type         IN VARCHAR2
                                      ,p_start_date          IN DATE
                                      ,p_end_date            IN DATE
                                     );

END PA_SUMMARIZE_ORG_ROLLUP_PVT;

 

/
