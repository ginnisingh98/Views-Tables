--------------------------------------------------------
--  DDL for Package GL_EBI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_EBI_PUB" AUTHID CURRENT_USER AS
/* $Header: gleipus.pls 120.0.12010000.2 2010/01/28 12:16:11 sommukhe noship $ */

PROCEDURE process_currency_exc_rate_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_integration_id         IN              VARCHAR2
 ,p_lang_code              IN              VARCHAR2
 ,p_name_value_tbl         IN              gl_ebi_name_value_tbl
 ,p_daily_rates_tbl        IN              gl_ebi_daily_rates_tbl
 ,x_request_id             OUT NOCOPY      NUMBER
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 );

PROCEDURE purge_currency_exc_rate_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_integration_id         IN              VARCHAR2
 ,p_lang_code              IN              VARCHAR2
 ,x_daily_rates_tbl        OUT NOCOPY      gl_ebi_daily_rates_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 );

PROCEDURE process_accounting_period_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_acct_period_tbl        IN              gl_ebi_acct_period_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 );

END GL_EBI_PUB;

/
