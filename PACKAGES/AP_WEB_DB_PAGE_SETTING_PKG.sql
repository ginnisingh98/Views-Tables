--------------------------------------------------------
--  DDL for Package AP_WEB_DB_PAGE_SETTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_PAGE_SETTING_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcpgss.pls 120.0 2006/09/06 16:36:31 qle noship $ */

--------------------------------------------------------------------------
PROCEDURE saveSetting(p_userId IN NUMBER,
                      p_pageName IN VARCHAR2,
                      p_objectName IN VARCHAR2,
                      p_objectTypeCode IN VARCHAR2,
                      p_hideFlag IN VARCHAR2,
                      p_selectedTab IN VARCHAR2,
                      p_sortedColumn IN VARCHAR2,
                      p_sortOrderCode IN VARCHAR2
);
-------------------------------------------------------------------

END AP_WEB_DB_PAGE_SETTING_PKG;

 

/
