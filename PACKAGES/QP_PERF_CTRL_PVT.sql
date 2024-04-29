--------------------------------------------------------
--  DDL for Package QP_PERF_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PERF_CTRL_PVT" AUTHID CURRENT_USER as
/* $Header: QPXPRFCS.pls 120.0.12010000.1 2008/10/31 05:16:23 ssangane noship $ */

g_perf constant varchar2(30)  := 'QP_PERFORMANCE_CONTROL';
g_on constant varchar2(30)  := 'ON';
g_off constant varchar2(30)  := 'OFF';
g_update_factor constant varchar2(30)  := 'FACTOR';

PROCEDURE Exec_prog(
  ERR_BUFF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY NUMBER,
  P_LIST_HEADER_ID_LOW IN NUMBER,
  P_LIST_HEADER_ID_HIGH IN NUMBER,
  P_UPDATE_TYPE IN VARCHAR2
);

end qp_perf_ctrl_pvt;

/
