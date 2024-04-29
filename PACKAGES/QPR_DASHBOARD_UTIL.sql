--------------------------------------------------------
--  DDL for Package QPR_DASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DASHBOARD_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPRPDSBS.pls 120.0 2007/10/11 13:11:22 agbennet noship $  */
TYPE  DashboardDetailsRec is RECORD
(  dashboard_detail_id  NUMBER
,  row_number    NUMBER
,  column_number    NUMBER
,  content_id    NUMBER
,  width         NUMBER
);


TYPE DashboardDetailsTab is TABLE of DashboardDetailsRec INDEX by BINARY_INTEGER;


PROCEDURE Create_Dashboard_Default
(  p_user_id              IN   NUMBER
  ,p_plan_id              IN   NUMBER
  ,x_return_status        OUT   NOCOPY  VARCHAR2
);

PROCEDURE  Populate_Dashboard_Details
(  p_user_id              IN     NUMBER
  ,p_plan_id              IN     NUMBER
  ,p_dashboard_id         IN     NUMBER
  ,n_dashboard_id         IN     NUMBER
  ,p_dsb_table            OUT   NOCOPY  DashboardDetailsTab
  ,x_return_status        OUT   NOCOPY   VARCHAR2
);


PROCEDURE Generate_Default_Rows
(  p_dashboard_name       IN   VARCHAR2
  ,p_source_template_id   IN   NUMBER
  ,p_dashboard_id         IN   NUMBER
  ,p_source_lang          IN   VARCHAR2
  ,p_dsb_table            IN   DashboardDetailsTab
  ,x_return_status        OUT  NOCOPY  VARCHAR2
);


PROCEDURE Delete_Dashboards
(
  p_price_plan_id        IN    NUMBER
 ,x_return_status        OUT   NOCOPY VARCHAR2
);

END QPR_DASHBOARD_UTIL;

/
