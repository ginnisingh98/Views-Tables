--------------------------------------------------------
--  DDL for Package Body AR_XLA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_XLA_REPORTS_PKG" as
/* $Header: ARXLARB.pls 120.1.12010000.2 2009/08/31 10:22:23 vsanka noship $ */

/*========================================================================+
  Custom query procedure for concurrent 'Sales Journal by GL Account (XML)'
 ========================================================================*/
  PROCEDURE JE_REPORT_HOOK ( p_application_id IN NUMBER
                          , p_component_name IN VARCHAR2
                          , p_custom_query_flag IN VARCHAR2
                          , p_custom_header_query OUT NOCOPY VARCHAR2
                          , p_custom_line_query OUT NOCOPY VARCHAR2) AS
  BEGIN

    IF p_component_name = 'ARSJGLARPT' THEN   -- check the concurrent name
        IF p_custom_query_flag = 'L' THEN     -- Match with GL == No => Show Lines
            p_custom_line_query := 'select /*+ index(xdl, XLA_DISTRIBUTION_LINKS_N3) */
            sum(xdl.unrounded_entered_dr) L1, sum(xdl.unrounded_entered_cr) L2,
            sum(xdl.unrounded_accounted_dr) L3, sum(xdl.unrounded_accounted_cr) L4,
            xdl.application_id L5, xdl.ae_header_id L6, xdl.ae_line_num L7
            from xla_distribution_links xdl
            where xdl.event_class_code = ''CREDIT_MEMO''
	    and xdl.source_distribution_type = ''RA_CUST_TRX_LINE_GL_DIST_ALL''
            and xdl.application_id = to_number(:APPLICATION_ID)
            and xdl.ae_header_id = to_number(:HEADER_ID)
            and xdl.ae_line_num = to_number(:ORIG_LINE_NUMBER)
            group by xdl.application_id, xdl.ae_header_id, xdl.ae_line_num ';
        END IF;
    END IF;

  END JE_REPORT_HOOK;

END AR_XLA_REPORTS_PKG;

/
