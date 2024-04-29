--------------------------------------------------------
--  DDL for Package BSC_INTEGRATION_MV_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_INTEGRATION_MV_GEN" AUTHID CURRENT_USER AS
/* $Header: BSCIMVGS.pls 115.3 2003/01/14 20:23:50 meastmon ship $ */


procedure Drop_Materialized_View(
  x_mv_name		varchar2,
  x_is_dim              varchar2
);

procedure Refresh_MVs(
  x_mv_name             varchar2,
  x_year_rng            varchar2
);

END BSC_INTEGRATION_MV_GEN;

 

/
