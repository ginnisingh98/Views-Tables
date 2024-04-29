--------------------------------------------------------
--  DDL for Package JAI_PA_SETUP_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_SETUP_DEF_PKG" AUTHID CURRENT_USER as
/* $Header: jai_pa_setup_def_pkg.pls 120.0.12010000.2 2009/04/24 07:39:18 mbremkum noship $ */
procedure default_pa_setup_org (errbuf               out nocopy varchar2,
                                retcode              out nocopy varchar2,
                                p_org_id             in  number);
end;

/
