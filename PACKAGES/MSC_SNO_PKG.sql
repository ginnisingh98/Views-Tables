--------------------------------------------------------
--  DDL for Package MSC_SNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SNO_PKG" AUTHID CURRENT_USER as
    /*  $Header: MSCHBSNS.pls 120.1.12010000.3 2009/10/08 23:30:03 pabram ship $ */

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

end msc_sno_pkg;

/
