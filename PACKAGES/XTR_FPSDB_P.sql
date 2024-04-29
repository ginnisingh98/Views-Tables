--------------------------------------------------------
--  DDL for Package XTR_FPSDB_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FPSDB_P" AUTHID CURRENT_USER as
/* $Header: xtrfpsds.pls 120.1 2005/06/29 08:02:33 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE EXTRAPOLATE_FWDS(l_company     IN VARCHAR2,
                           l_period_from IN DATE,
                           l_period_to   IN DATE,
                           l_ccy         IN VARCHAR2,
                           l_ccyb	     IN VARCHAR2,
                           l_days        IN NUMBER,
                           l_fwds        IN OUT NOCOPY NUMBER);
end XTR_FPSDB_P;

 

/
