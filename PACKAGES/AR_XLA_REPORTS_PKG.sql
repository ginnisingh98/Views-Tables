--------------------------------------------------------
--  DDL for Package AR_XLA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_XLA_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXLARS.pls 120.1.12010000.1 2009/08/25 13:44:07 vsanka noship $ */

   PROCEDURE JE_REPORT_HOOK ( p_application_id IN NUMBER
                          , p_component_name IN VARCHAR2
                          , p_custom_query_flag IN VARCHAR2
                          , p_custom_header_query OUT NOCOPY VARCHAR2
                          , p_custom_line_query OUT NOCOPY VARCHAR2);

END AR_XLA_REPORTS_PKG;

/
