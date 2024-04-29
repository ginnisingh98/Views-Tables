--------------------------------------------------------
--  DDL for Package FTE_TL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TL_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTETLLRS.pls 120.0 2005/06/28 02:17:39 pkaliyam noship $ */

  --Global package variables
  g_unit_uom        VARCHAR2(10);
  g_debug_set       BOOLEAN := TRUE;
  g_debug_on        BOOLEAN := TRUE;

  G_CONST_PRECEDENCE_LOW  CONSTANT NUMBER := 180;
  G_CONST_PRECEDENCE_MID  CONSTANT NUMBER := 200;
  G_CONST_PRECEDENCE_HIGH CONSTANT NUMBER := 220;



  TYPE Number_Tab      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE Varchar100_Tab  IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  TYPE Varchar2000_Tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


  --Caches for Rate Chart Information
  Chart_Names                 Varchar100_Tab;
  Chart_Carriers              Varchar100_Tab;
  Chart_Service_Levels        Varchar100_Tab;
  Chart_LineNums              Number_Tab;
  Chart_Process_Ids           Number_Tab;
  Chart_Types                 Varchar100_Tab;
  Chart_Min_Charges           Varchar2000_Tab;
  Chart_Start_Dates           Varchar100_Tab;
  Chart_End_Dates             Varchar100_Tab;
  Chart_Ids                   Number_Tab;
  Chart_Currencies            Varchar100_Tab;
  Link_Chartnames             Varchar100_Tab;
  Link_Modifiernames          Varchar100_Tab;

  Fac_Modifier_Names          Varchar100_Tab;
  Fac_Modifier_Bases          Varchar100_Tab;
  Fac_Modifier_Uoms           Varchar100_Tab;

  g_chart_name                VARCHAR2(60);
  g_carrier_name              VARCHAR2(60);
  g_service_level             VARCHAR2(30);
  g_carrier_id                NUMBER;
  g_carrier_unit_basis        VARCHAR2(30);
  g_carrier_unit_basis_uom    VARCHAR2(3);
  g_carrier_distance_uom      VARCHAR2(3);
  g_carrier_time_uom          VARCHAR2(3);
  g_carrier_currency          VARCHAR2(3);

  g_wknd_layovr_uom           VARCHAR2(10);
  g_layovr_charges            STRINGARRAY := STRINGARRAY();
  g_layovr_breaks             STRINGARRAY := STRINGARRAY();

  PROCEDURE PROCESS_TL_BASE_RATES( p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                   p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                   p_line_number     IN  NUMBER,
                                   p_doValidate      IN  BOOLEAN DEFAULT TRUE,
                                   x_status          OUT NOCOPY  NUMBER,
                                   x_error_msg       OUT NOCOPY  VARCHAR2);

  PROCEDURE PROCESS_TL_SURCHARGES(p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                  p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                  p_line_number     IN  NUMBER,
                                  p_doValidate      IN  BOOLEAN DEFAULT TRUE,
                                  x_error_msg       OUT   NOCOPY  VARCHAR2,
                                  x_status          OUT   NOCOPY  NUMBER);

  PROCEDURE PROCESS_FACILITY_CHARGES(p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                     p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                     p_line_number     IN  NUMBER,
                                     x_error_msg       OUT NOCOPY  VARCHAR2,
                                     x_status          OUT NOCOPY  NUMBER);

  PROCEDURE SUBMIT_TL_CHART (x_status     OUT NOCOPY NUMBER,
			     x_error_msg  OUT NOCOPY VARCHAR2);

  PROCEDURE PROCESS_DATA(p_type            IN  VARCHAR2,
                         p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                         p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                         p_line_number     IN  NUMBER,
                         x_status          OUT NOCOPY  NUMBER,
                         x_error_msg       OUT NOCOPY  VARCHAR2);

  PROCEDURE RESET_ALL;
END FTE_TL_LOADER;

 

/
