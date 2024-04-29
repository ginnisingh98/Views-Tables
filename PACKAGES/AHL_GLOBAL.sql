--------------------------------------------------------
--  DDL for Package AHL_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: AHLUGLBS.pls 115.1 2002/10/10 20:36:11 jaramana noship $ */

AHL_APPLICATION_ID CONSTANT NUMBER        := 867;
AHL_APP_SHORT_NAME CONSTANT VARCHAR2(50)  := 'AHL';

-- Modules (Programs)
AHL_MC_PROGRAM_ID CONSTANT NUMBER := 1;  -- Master Configuration
AHL_UC_PROGRAM_ID CONSTANT NUMBER := 2;  -- Unit Configuration
AHL_DI_PROGRAM_ID CONSTANT NUMBER := 3;  -- Document Index
AHL_RM_PROGRAM_ID CONSTANT NUMBER := 4;  -- Route Management
AHL_PC_PROGRAM_ID CONSTANT NUMBER := 5;  -- Product Classification

AHL_UMP_PROGRAM_ID CONSTANT NUMBER := 6;  -- Unit Maintenance Plan
AHL_FMP_PROGRAM_ID CONSTANT NUMBER := 7;  -- Fleet Maintenance Plan
AHL_LTP_PROGRAM_ID CONSTANT NUMBER := 8;  -- Long Term Planning
AHL_VWP_PROGRAM_ID CONSTANT NUMBER := 9;  -- Visit Work Package
AHL_OSP_PROGRAM_ID CONSTANT NUMBER := 10; -- Outside Processing
AHL_PP_PROGRAM_ID  CONSTANT NUMBER := 11; -- Production Planning
AHL_P_PROGRAM_ID   CONSTANT NUMBER := 12; -- Production ??



END AHL_GLOBAL; -- Package spec

 

/
