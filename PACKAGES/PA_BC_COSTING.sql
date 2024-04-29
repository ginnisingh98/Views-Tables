--------------------------------------------------------
--  DDL for Package PA_BC_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BC_COSTING" AUTHID CURRENT_USER AS
/* $Header: PABCCSTS.pls 120.0 2005/06/03 13:47:35 appldev noship $ */

  /*
   * Funds Checking Procedure.
   * Calls PA Funds-Checker.
   */
  PROCEDURE costing_fc_proc ( p_calling_module IN  VARCHAR2
                             ,p_request_id     IN  NUMBER
                             ,x_return_status  OUT NOCOPY NUMBER
                             ,x_error_code     OUT NOCOPY VARCHAR2
                             ,x_error_stage    OUT NOCOPY NUMBER
                           );

  /*
   * Resource Maps BTC CDLs.
   */
  PROCEDURE map_btc_items ( p_request_id     IN  NUMBER
                           ,x_return_status  OUT NOCOPY NUMBER
                           ,x_error_code     OUT NOCOPY VARCHAR2
                           ,x_error_stage    OUT NOCOPY VARCHAR2
                          );

  /*
   * Called during the Distribute Total Burdened Costs process.
   * Validates the debit lines.
   */
  PROCEDURE validate_debit_lines ( p_request_id     IN  NUMBER
                                  ,x_return_status  OUT NOCOPY NUMBER
                                  ,x_error_code     OUT NOCOPY VARCHAR2
                                  ,x_error_stage    OUT NOCOPY NUMBER
                                );

  /*
   * Funds Checking Procedure for Contingent Labor.
   * Calls PA Funds-Checker.
   */
  PROCEDURE costing_fc_proc_cwk ( p_calling_module IN  VARCHAR2
                                 ,p_request_id     IN  NUMBER
                                 ,x_return_status  OUT NOCOPY NUMBER
                                 ,x_error_code     OUT NOCOPY VARCHAR2
                                 ,x_error_stage    OUT NOCOPY NUMBER
                               );


END pa_bc_costing;

 

/
