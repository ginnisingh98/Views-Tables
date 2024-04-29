--------------------------------------------------------
--  DDL for Package Body AR_BPA_INSTALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_INSTALL_PKG" AS
/* $Header: ARBPINSB.pls 120.2 2004/07/30 08:17:15 verao noship $ */

FUNCTION IS_BPA_INSTALLED RETURN VARCHAR2 IS
BEGIN

	Return('Y');

END IS_BPA_INSTALLED;

END AR_BPA_INSTALL_PKG;


/
