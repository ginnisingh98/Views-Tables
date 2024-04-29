--------------------------------------------------------
--  DDL for Package PSB_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_GL_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVOGLS.pls 120.5 2006/01/17 18:10:55 matthoma ship $ */

PROCEDURE Create_Revision_Journal
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER,
  p_order_by1           IN      VARCHAR2,
  p_order_by2           IN      VARCHAR2,
  p_order_by3           IN      VARCHAR2,
  p_error_code          OUT  NOCOPY     VARCHAR2 -- bug# 4341619
);

PROCEDURE Transfer_GLI_To_GL_CP
( errbuf            OUT  NOCOPY  VARCHAR2,
  retcode           OUT  NOCOPY  VARCHAR2,
  p_source_id       IN   NUMBER,
  p_currency_code   IN   VARCHAR2 DEFAULT 'C',  -- Bug 3029168
  p_gl_transfer_mode     VARCHAR2 DEFAULT NULL,
  p_order_by1       IN   VARCHAR2,
  p_order_by2       IN   VARCHAR2,
  p_order_by3       IN   VARCHAR2
);


PROCEDURE Create_Budget_Journal_CP
( errbuf                OUT  NOCOPY     VARCHAR2,
  retcode               OUT  NOCOPY     VARCHAR2,
  p_worksheet_id        IN      NUMBER,
  p_budget_stage_id     IN      NUMBER,
  p_budget_year_id      IN      NUMBER,
  p_year_journal        IN      VARCHAR2,
  p_gl_transfer_mode    IN      VARCHAR2,
  p_currency_code       IN      VARCHAR2  DEFAULT 'C',  -- Bug 3029168
  p_auto_offset         IN      VARCHAR2,
  p_gl_budget_set_id    IN      NUMBER,
  p_run_mode            IN      VARCHAR2,
  p_order_by1           IN      VARCHAR2,
  p_order_by2           IN      VARCHAR2,
  p_order_by3           IN      VARCHAR2
);

PROCEDURE Create_Adopted_Budget_CP
( errbuf                OUT  NOCOPY     VARCHAR2,
  retcode               OUT  NOCOPY     VARCHAR2,
  p_worksheet_id        IN      NUMBER,
  p_budget_stage_id     IN      NUMBER,
  p_budget_year_id      IN      NUMBER,
  p_year_journal        IN      VARCHAR2,
  p_gl_transfer_mode    IN      VARCHAR2,
  p_auto_offset         IN      VARCHAR2,
  p_gl_budget_set_id    IN      NUMBER
);


PROCEDURE Get_Qualifier_Segnum
( p_api_version          IN     NUMBER,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY    VARCHAR2,
  p_msg_count            OUT  NOCOPY    NUMBER,
  p_msg_data             OUT  NOCOPY    VARCHAR2,
  p_chart_of_accounts_id IN     NUMBER,
  p_segment_number       OUT  NOCOPY    NUMBER
);

/* start bug 3659531 */
PROCEDURE Find_Document_Posting_Status
( x_return_Status 	       OUT NOCOPY VARCHAR2, -- Bug#4460150
  x_document_posted_flag       OUT NOCOPY VARCHAR2, -- Bug#4460150
  p_document_type 	       IN         VARCHAR2,
  p_Document_Id		       IN         NUMBER
);
/* end bug 3659531 */

END PSB_GL_Interface_PVT;

 

/
