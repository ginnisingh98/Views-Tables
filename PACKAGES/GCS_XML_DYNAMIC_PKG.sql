--------------------------------------------------------
--  DDL for Package GCS_XML_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_XML_DYNAMIC_PKG" AUTHID CURRENT_USER as
/* $Header: gcsxmldyns.pls 120.1 2005/10/30 05:19:44 appldev noship $ */

  --Global Variables
    g_api	VARCHAR2(50)	:=	'gcs.plsql.GCS_XML_DYNAMIC_PKG';
    g_nl	VARCHAR2(1)	:=	'''';

  PROCEDURE create_xml_utility_pkg     (p_retcode	NUMBER,
	                                      p_errbuf	VARCHAR2);

END GCS_XML_DYNAMIC_PKG;

 

/
