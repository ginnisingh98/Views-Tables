--------------------------------------------------------
--  DDL for Package FEM_INTF_DIM_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTF_DIM_VALIDATION_PKG" AUTHID CURRENT_USER AS
/*$Header: fem_intf_val_eng.pls 120.0 2006/06/26 12:54:31 hkaniven ship $*/

PROCEDURE Main (
  x_errbuf              OUT NOCOPY  VARCHAR2,
  x_retcode             OUT NOCOPY  VARCHAR2,
  p_obj_def_id          IN          VARCHAR2,
  p_ledger_id           IN          VARCHAR2,
  p_cal_period_id       IN          VARCHAR2,
  p_dataset_code        IN          VARCHAR2,
  p_source_system_code  IN          VARCHAR2,
  p_num_rows            IN          VARCHAR2 default '500',
  p_print_report_flag   IN          VARCHAR2 default 'N',
  p_num_rec_to_print    IN          VARCHAR2 default '500'
);

PROCEDURE Validate_Params (
  x_completion_code     OUT NOCOPY  NUMBER
);

PROCEDURE Validate_Dims (
  x_completion_code     OUT NOCOPY  NUMBER
);

PROCEDURE Populate_Dim_Info(
  x_completion_code     OUT NOCOPY  NUMBER
);

PROCEDURE Is_Number(
    p_string            IN          VARCHAR2,
    x_string_value      OUT NOCOPY  NUMBER);

END FEM_INTF_DIM_VALIDATION_PKG;

 

/
