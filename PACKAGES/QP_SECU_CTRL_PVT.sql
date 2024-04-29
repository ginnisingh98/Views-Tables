--------------------------------------------------------
--  DDL for Package QP_SECU_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_SECU_CTRL_PVT" AUTHID CURRENT_USER as
/* $Header: QPXSECCS.pls 120.1.12010000.1 2008/07/28 11:55:56 appldev ship $ */

g_security_control_prof constant varchar2(30)  := 'QP_SECURITY_CONTROL';
g_security_on constant varchar2(10)  := 'ON';
g_security_off constant varchar2(10)  := 'OFF';
g_y constant varchar2(1)  := 'Y';
g_n constant varchar2(1)  := 'N';

procedure switch(
err_buff out nocopy varchar2,
retcode out nocopy number,
p_security_control in varchar2,
p_control in varchar2 default g_n
);

end qp_secu_ctrl_pvt;

/
