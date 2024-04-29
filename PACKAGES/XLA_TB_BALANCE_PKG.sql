--------------------------------------------------------
--  DDL for Package XLA_TB_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbbal.pkh 120.2.12010000.1 2008/07/29 10:08:00 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tb_balance_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Trial Balance Upgrade package                                  |
|                                                                       |
| HISTORY                                                               |
|    15-Dec-05 Mizuru Asada    Created                                  |
|                                                                       |
+======================================================================*/
PROCEDURE upload_balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_definition_code   IN  VARCHAR2
  ,p_definition_name   IN  VARCHAR2
  ,p_definition_desc   IN  VARCHAR2
  ,p_ledger_id         IN  NUMBER
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  ,p_gl_date_from      IN  DATE
  ,p_gl_date_to        IN  DATE
  ,p_mode              IN  VARCHAR2
  );

PROCEDURE Upgrade_AP_Balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  );


END xla_tb_balance_pkg;

/
