--------------------------------------------------------
--  DDL for Package AP_MASS_ADDITIONS_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MASS_ADDITIONS_CREATE_PKG" AUTHID CURRENT_USER AS
/* $Header: apmassas.pls 120.3 2005/06/22 17:35:09 bghose noship $ */

PROCEDURE Mass_Additions_Create(
                errbuf             OUT NOCOPY VARCHAR2,
                retcode            OUT NOCOPY NUMBER,
                P_acctg_date       IN  VARCHAR2,
                P_bt_code          IN  VARCHAR2,
                P_calling_sequence IN  VARCHAR2 DEFAULT NULL);
--
END AP_MASS_ADDITIONS_CREATE_PKG;

 

/
