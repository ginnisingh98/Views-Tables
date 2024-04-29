--------------------------------------------------------
--  DDL for Package GMF_AR_CHECK_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_CHECK_CREDIT" AUTHID CURRENT_USER as
/* $Header: gmfcrhis.pls 115.1 2002/11/11 00:34:52 rseshadr ship $ */

     procedure proc_ar_check_credit(st_date        in out NOCOPY date,
                                    en_date        in out NOCOPY date,
                                    cust_id        in out NOCOPY number,
                                    cr_hist_id     out    NOCOPY number,
                                    lst_updt_dt    out    NOCOPY date,
                                    lst_updt_by    out    NOCOPY number,
                                    lst_updt_login out    NOCOPY number,
                                    create_dat     out    NOCOPY date,
                                    create_by      out    NOCOPY number,
                                    on_hld         out    NOCOPY varchar2,
                                    hld_dt         out    NOCOPY date,
                                    cr_lmt         out    NOCOPY number,
                                    cr_rating      out    NOCOPY varchar2,
                                    risk_cd        out    NOCOPY varchar2,
                                    os_bal         out    NOCOPY number,
                                    sit_use_id     out    NOCOPY number,
                                    row_to_fetch   in out NOCOPY number,
                                    error_status   out    NOCOPY number);
END GMF_AR_CHECK_CREDIT;

 

/
