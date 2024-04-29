--------------------------------------------------------
--  DDL for Package QP_JPE_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_JPE_CTRL_PVT" AUTHID CURRENT_USER as
/* $Header: QPXJPECS.pls 120.0 2006/03/09 16:18:10 hwong noship $ */

g_internal constant varchar2(30)  := 'QP_INTERNAL_11510_J';
g_engine_type constant varchar2(30)  := 'QP_PRICING_ENGINE_TYPE';
g_null constant varchar2(10)  := 'QWERTY';
g_plsql constant varchar2(10)  := 'PLSQL';
g_java constant varchar2(10)  := 'JAVA';
g_site constant varchar2(10)  := 'SITE';

procedure switch(
err_buff out nocopy varchar2,
retcode out nocopy number,
p_control in  varchar2
);

end qp_jpe_ctrl_pvt;

 

/
