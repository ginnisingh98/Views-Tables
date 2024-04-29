--------------------------------------------------------
--  DDL for Package PSA_MF_UPD_PST_CTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_UPD_PST_CTRL_PKG" 
/* $Header: PSAMFUPS.pls 120.3 2006/09/13 14:02:18 agovil ship $ */
AUTHID CURRENT_USER as

procedure update_posting_control(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2,
                                 p_posting_control_id in number);
end PSA_MF_UPD_PST_CTRL_PKG;

 

/
