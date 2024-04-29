--------------------------------------------------------
--  DDL for Package AR_CUMULATIVE_BALANCE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CUMULATIVE_BALANCE_REPORT" AUTHID CURRENT_USER AS
/* $Header: ARXCUABS.pls 120.4 2005/10/30 03:59:24 appldev noship $ */

PROCEDURE process_clob (p_xml_clob CLOB);

PROCEDURE generate_xml (
  p_reporting_level      IN   VARCHAR2,
  p_reporting_entity_id  IN   NUMBER,
  p_reporting_format     IN   VARCHAR2,
  p_sob_id               IN   NUMBER,
  p_coa_id               IN   NUMBER,
  p_co_seg_low           IN   VARCHAR2,
  p_co_seg_high          IN   VARCHAR2,
  p_gl_as_of_date        IN   VARCHAR2,
  p_gl_account_low       IN   VARCHAR2,
  p_gl_account_high      IN   VARCHAR2,
  p_refresh              IN   VARCHAR2  DEFAULT 'N',
  p_result               OUT NOCOPY CLOB);

END ar_cumulative_balance_report;

 

/
