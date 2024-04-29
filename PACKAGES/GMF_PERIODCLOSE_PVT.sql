--------------------------------------------------------
--  DDL for Package GMF_PERIODCLOSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_PERIODCLOSE_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVIAPS.pls 120.1 2006/07/25 10:29:43 jboppana noship $ */
/*======================================================================+
|                Copyright (c) 2005 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|   GMF_PeriodClose_PVT                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|   Period Close Private API for Process Organizations                  |
|   Generates period ending balances for process organizations          |
|                                                                       |
| HISTORY                                                               |
|                                                                       |
|   03-Jun-05 Rajesh Seshadri - Created                                 |
+======================================================================*/

PROCEDURE Compile_Period_Balances (
  x_errbuf        OUT NOCOPY VARCHAR2,
  x_retcode       OUT NOCOPY VARCHAR2,
  p_organization_id        IN NUMBER,
  p_closing_acct_period_id    IN NUMBER
);

PROCEDURE Compile_Inv_Period_Balances (
  p_organization_id        IN NUMBER,
  p_closing_acct_period_id    IN NUMBER,
  p_schedule_close_date     IN DATE,
  p_final_close IN NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_return_msg	OUT NOCOPY VARCHAR2
  );

PROCEDURE Compile_Period_Balances_LE(
  x_errbuf        OUT NOCOPY VARCHAR2,
  x_retcode       OUT NOCOPY VARCHAR2,
  p_le_id IN NUMBER,
  p_fiscal_year IN NUMBER,
  p_fiscal_period IN NUMBER,
  p_final_close IN VARCHAR2,
  p_org_code IN VARCHAR2
  );

END GMF_PeriodClose_PVT;

 

/
