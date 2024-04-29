--------------------------------------------------------
--  DDL for Package GCS_RP_UTIL_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_RP_UTIL_BUILD_PKG" AUTHID CURRENT_USER as
/* $Header: gcsrputblds.pls 120.0 2006/05/03 01:46:18 skamdar noship $ */

  --Global Variables
    g_api	VARCHAR2(50)	:=	'gcs.plsql.GCS_RP_UTIL_BUILD_PKG';
    g_nl	VARCHAR2(1)	:=	'''';

  PROCEDURE create_rp_utility_pkg     (p_retcode	NUMBER,
	                               p_errbuf		VARCHAR2);

END GCS_RP_UTIL_BUILD_PKG;

 

/
