--------------------------------------------------------
--  DDL for Package OKS_SUBSCRIPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SUBSCRIPTION_PVT" AUTHID CURRENT_USER As
/* $Header: OKSRSUBS.pls 120.1 2005/06/28 05:30:32 jvorugan noship $*/

  -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_subscription_pvt';
-- Added global constants
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_APP_NAME              CONSTANT VARCHAR2(3)  := 'OKS';

  TYPE rangerec is RECORD
                  (low  NUMBER,
                   high NUMBER);
  TYPE rangetab is TABLE of rangerec INDEX BY BINARY_INTEGER;

  Procedure create_default_schedule
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
     p_intent        IN  VARCHAR2
   );

  Procedure recreate_schedule
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
     p_intent        IN  VARCHAR2,
     x_quantity      OUT NOCOPY NUMBER
   );

  Procedure recreate_instance
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER,
	p_custacct_id   IN  NUMBER
   );

  Procedure copy_subscription
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_source_cle_id IN  NUMBER,
     p_target_cle_id IN  NUMBER,
     p_intent        IN  VARCHAR2
  );

  Procedure undo_subscription
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN  NUMBER
  );

  Procedure validate_pattern
   ( p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY Number,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_instring      IN  VARCHAR2,
     p_lowval        IN  NUMBER,
     p_highval       IN  NUMBER,
     x_outstring     OUT NOCOPY VARCHAR2,
     x_outtab        OUT NOCOPY rangetab
   );

  Procedure get_subs_qty
   ( p_cle_id        IN  NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_quantity      OUT NOCOPY NUMBER,
     x_uom_code      OUT NOCOPY VARCHAR2
   );

  Procedure stretch_effectivity
   ( p_start_date    IN  DATE,
     p_end_date      IN  DATE,
     p_frequency     IN  VARCHAR2,
     x_new_start_dt  OUT NOCOPY DATE,
     x_new_end_dt    OUT NOCOPY DATE
   );

  Function subs_termn_amount
   ( p_cle_id        IN  NUMBER,
     p_termn_date    IN  DATE
   ) Return NUMBER;

  Function is_subs_tangible
   ( p_cle_id        IN  NUMBER
   ) Return BOOLEAN;

  Function map_freq_uom
   ( p_frequency     IN  VARCHAR2
   ) Return VARCHAR2;

  Procedure db_commit;

END OKS_SUBSCRIPTION_PVT;


 

/
