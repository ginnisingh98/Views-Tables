--------------------------------------------------------
--  DDL for Package Body XTR_FPSDB_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FPSDB_P" as
/* $Header: xtrfpsdb.pls 120.1 2005/06/29 07:57:37 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
--  Procedure to Extrapolate the FWDS from the reval rates WITHOUT referring to a
--  specific yield curve
PROCEDURE EXTRAPOLATE_FWDS(l_company     IN VARCHAR2,
                           l_period_from IN DATE,
                           l_period_to   IN DATE,
                           l_ccy         IN VARCHAR2,
                           l_ccyb	     IN VARCHAR2,
                           l_days        IN NUMBER,
                           l_fwds        IN OUT NOCOPY NUMBER) is
begin
--Comment added by Ilavenil on 08/29/2001.
--The procedure body had a cursor which selected reval_rate column
--from xtr_revaluation_rates.  This is an onsoleted column.  Moreover, the
--procedure is not being called in any form, report, trigger, library, package.
--So removing it totally.
null;
end EXTRAPOLATE_FWDS;
end XTR_FPSDB_P;

/
