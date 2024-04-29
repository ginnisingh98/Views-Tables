--------------------------------------------------------
--  DDL for Package AP_UPDATE_1099_AWT_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_UPDATE_1099_AWT_DISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apupawts.pls 120.0 2003/06/13 17:56:24 isartawi noship $ */

FUNCTION Get_Income_Tax_Region(
                P_invoice_id           IN     NUMBER,
                P_calling_sequence     IN     VARCHAR2   DEFAULT NULL )
RETURN    VARCHAR2;
--
PROCEDURE Upgrade(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY NUMBER,
            P_calling_sequence IN  VARCHAR2 DEFAULT NULL);
--
END Ap_Update_1099_Awt_Dists_Pkg;

 

/
