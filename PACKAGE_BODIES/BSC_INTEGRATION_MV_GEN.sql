--------------------------------------------------------
--  DDL for Package Body BSC_INTEGRATION_MV_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_INTEGRATION_MV_GEN" AS
/* $Header: BSCIMVGB.pls 115.3 2003/01/14 20:21:15 meastmon ship $ */

procedure Drop_Materialized_View(
  x_mv_name		varchar2,
  x_is_dim              varchar2
) is
begin
    null;
end Drop_Materialized_View;

procedure Refresh_MVs(
  x_mv_name             varchar2,
  x_year_rng            varchar2
) is
begin
    null;
end Refresh_MVs;

END BSC_INTEGRATION_MV_GEN;

/
