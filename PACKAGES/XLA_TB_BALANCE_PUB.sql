--------------------------------------------------------
--  DDL for Package XLA_TB_BALANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_BALANCE_PUB" AUTHID CURRENT_USER AS
/* $Header: xlatbblp.pkh 120.2 2008/03/03 11:20:05 samejain ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    XLA_TB_BALANCE_PUB                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Trial Balance Upgrade API (Public)                             |
|                                                                       |
| HISTORY                                                               |
|    21-Dec-05 M.Asada          Created                                 |
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

END xla_tb_balance_pub;

/
