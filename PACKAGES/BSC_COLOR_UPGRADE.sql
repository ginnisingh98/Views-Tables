--------------------------------------------------------
--  DDL for Package BSC_COLOR_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: BSCCOLUS.pls 120.2.12000000.1 2007/07/17 07:43:30 appldev noship $ */

FUNCTION upgrade_kpi_measures (
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_objectives (
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_calculated_colors (
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_sys_colors (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_color_thresholds (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_ag_calculated_kpis (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_simulation_objectives (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION upgrade_assessments (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

END BSC_COLOR_UPGRADE;

 

/
