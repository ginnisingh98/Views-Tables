--------------------------------------------------------
--  DDL for Package AR_MATCH_REV_COGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MATCH_REV_COGS_GRP" AUTHID CURRENT_USER AS
/* $Header: ARCGSRVS.pls 120.2.12010000.2 2008/11/04 20:15:12 mraymond ship $ */


PROCEDURE period_status (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_eff_period_num IN  NUMBER,
  p_sob_id         IN  NUMBER,
  x_status         OUT NOCOPY  VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2);

FUNCTION get_costing_period_status (
  p_period_name  VARCHAR2)
  RETURN VARCHAR2;

FUNCTION potential_revenue (
  p_so_line_id IN NUMBER,
  p_period_number IN NUMBER)
  RETURN NUMBER;

PROCEDURE populate_cst_tables (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_from_gl_date   IN  DATE,
  p_to_gl_date     IN  DATE,
  p_ledger_id      IN  NUMBER DEFAULT NULL,
  x_status         OUT NOCOPY  VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2);

END ar_match_rev_cogs_grp;

/
