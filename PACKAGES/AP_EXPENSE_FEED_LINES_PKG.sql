--------------------------------------------------------
--  DDL for Package AP_EXPENSE_FEED_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_EXPENSE_FEED_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: apiwtrxs.pls 120.1 2005/06/24 21:14:24 hchacko ship $ */

  PROCEDURE SELECT_SUMMARY(X_FEED_LINE_ID     IN NUMBER,
			   X_TOTAL            IN OUT NOCOPY NUMBER,
                           X_TOTAL_RTOT_DB    IN OUT NOCOPY NUMBER,
			   X_CALLING_SEQUENCE IN VARCHAR2);

END AP_EXPENSE_FEED_LINES_PKG;

 

/
