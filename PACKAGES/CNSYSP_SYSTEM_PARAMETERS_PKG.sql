--------------------------------------------------------
--  DDL for Package CNSYSP_SYSTEM_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYSP_SYSTEM_PARAMETERS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsysp1s.pls 115.1 99/07/16 07:18:53 porting ship $


-- History
--   07-05-95           Amy Erickson            Updated
--   07-26-95           Amy Erickson            Updated
--

/* ----------------------------------------------------------- */

PROCEDURE Populate_Fields (
                x_set_of_books_id                       number,
                x_trx_rollup_method                     varchar2,
                x_usage_flag                            varchar2,
                x_status                                varchar2,
                x_sob_name                      IN OUT  varchar2,
                x_sob_calendar                  IN OUT  varchar2,
                x_sob_period_type               IN OUT  varchar2,
                x_sob_currency                  IN OUT  varchar2,
                x_trx_rollup_method_string      IN OUT  varchar2,
                x_usage_string                  IN OUT  varchar2,
                x_status_string                 IN OUT  varchar2);


/* ----------------------------------------------------------- */

PROCEDURE Populate_Fields_Dim_Hier (
                x_rev_class_dimension_id        IN OUT   number,
                x_rev_class_hierarchy_id        IN OUT   number,
                x_rev_class_hierarchy_name      IN OUT   varchar2,
                x_srp_rollup_dimension_id       IN OUT   number,
                x_srp_rollup_hierarchy_id       IN OUT   number,
                x_srp_rollup_hierarchy_name     IN OUT   varchar2);

/* ----------------------------------------------------------- */

PROCEDURE Set_Defaults (
                        x_repository_id                 number,
                        x_system_batch_size     IN OUT  number,
                        x_transfer_batch_size   IN OUT  number,
                        x_clawback_grace_days   IN OUT  number,
                        x_trx_rollup_method     IN OUT  varchar2,
                        x_srp_rollup_flag       IN OUT  varchar2);


/* ----------------------------------------------------------- */

/*  Block off for we are not saving the last SP. 12/30/94

procedure save_to_last_sp (X_repository_id number); */

/* ----------------------------------------------------------- */

/*  Block off for we are not saving the last SP. 12/30/94

procedure restore_from_last_sp (X_repository_id number); */

/* ----------------------------------------------------------- */


END CNSYSP_system_parameters_PKG;

 

/
