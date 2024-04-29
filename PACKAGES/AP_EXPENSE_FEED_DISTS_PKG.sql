--------------------------------------------------------
--  DDL for Package AP_EXPENSE_FEED_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_EXPENSE_FEED_DISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apiwdsts.pls 120.1 2005/06/24 21:12:04 hchacko ship $ */

PROCEDURE RETURN_SEGMENTS(
              P_CODE_COMBINATION_ID     NUMBER,
              P_COST_CENTER             IN OUT NOCOPY VARCHAR2,
              P_ACCOUNT_SEGMENT_VALUE   IN OUT NOCOPY VARCHAR2,
              P_ERROR_MESSAGE           IN OUT NOCOPY VARCHAR2,
              P_CALLING_SEQUENCE        VARCHAR2);

END AP_EXPENSE_FEED_DISTS_PKG;

 

/
