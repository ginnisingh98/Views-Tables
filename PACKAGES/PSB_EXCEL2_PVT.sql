--------------------------------------------------------
--  DDL for Package PSB_EXCEL2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_EXCEL2_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVXL2S.pls 120.2 2005/07/13 11:31:44 shtripat ship $ */

/* ----------------------------------------------------------------------- */


  PROCEDURE Move_To_PSB
  (
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER,
  p_import_worksheet_type     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM,
  p_pct_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_pct_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM
  );


END PSB_EXCEL2_PVT;

 

/
