--------------------------------------------------------
--  DDL for Package GLXRVSUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLXRVSUB_PKG" AUTHID CURRENT_USER AS
/* $Header: glfcrrvs.pls 120.5 2005/05/05 02:05:13 kvora ship $ */

  FUNCTION get_unique_id
    RETURN NUMBER;

  FUNCTION get_segment_num(
      coa_id    IN   VARCHAR2,
      segment   IN   VARCHAR2)
    RETURN NUMBER;

  FUNCTION is_summary_account(
      coa_id         IN   VARCHAR2,
      segment_name   IN   VARCHAR2,
      account_num    IN   VARCHAR2)
    RETURN BOOLEAN;

  FUNCTION has_overlapping(
      x_revaluation_id   NUMBER,
      x_row_id           VARCHAR2,
      x_segment1_low     VARCHAR2,
      x_segment1_high    VARCHAR2,
      x_segment2_low     VARCHAR2,
      x_segment2_high    VARCHAR2,
      x_segment3_low     VARCHAR2,
      x_segment3_high    VARCHAR2,
      x_segment4_low     VARCHAR2,
      x_segment4_high    VARCHAR2,
      x_segment5_low     VARCHAR2,
      x_segment5_high    VARCHAR2,
      x_segment6_low     VARCHAR2,
      x_segment6_high    VARCHAR2,
      x_segment7_low     VARCHAR2,
      x_segment7_high    VARCHAR2,
      x_segment8_low     VARCHAR2,
      x_segment8_high    VARCHAR2,
      x_segment9_low     VARCHAR2,
      x_segment9_high    VARCHAR2,
      x_segment10_low    VARCHAR2,
      x_segment10_high   VARCHAR2,
      x_segment11_low    VARCHAR2,
      x_segment11_high   VARCHAR2,
      x_segment12_low    VARCHAR2,
      x_segment12_high   VARCHAR2,
      x_segment13_low    VARCHAR2,
      x_segment13_high   VARCHAR2,
      x_segment14_low    VARCHAR2,
      x_segment14_high   VARCHAR2,
      x_segment15_low    VARCHAR2,
      x_segment15_high   VARCHAR2,
      x_segment16_low    VARCHAR2,
      x_segment16_high   VARCHAR2,
      x_segment17_low    VARCHAR2,
      x_segment17_high   VARCHAR2,
      x_segment18_low    VARCHAR2,
      x_segment18_high   VARCHAR2,
      x_segment19_low    VARCHAR2,
      x_segment19_high   VARCHAR2,
      x_segment20_low    VARCHAR2,
      x_segment20_high   VARCHAR2,
      x_segment21_low    VARCHAR2,
      x_segment21_high   VARCHAR2,
      x_segment22_low    VARCHAR2,
      x_segment22_high   VARCHAR2,
      x_segment23_low    VARCHAR2,
      x_segment23_high   VARCHAR2,
      x_segment24_low    VARCHAR2,
      x_segment24_high   VARCHAR2,
      x_segment25_low    VARCHAR2,
      x_segment25_high   VARCHAR2,
      x_segment26_low    VARCHAR2,
      x_segment26_high   VARCHAR2,
      x_segment27_low    VARCHAR2,
      x_segment27_high   VARCHAR2,
      x_segment28_low    VARCHAR2,
      x_segment28_high   VARCHAR2,
      x_segment29_low    VARCHAR2,
      x_segment29_high   VARCHAR2,
      x_segment30_low    VARCHAR2,
      x_segment30_high   VARCHAR2)
    RETURN BOOLEAN;

  PROCEDURE raise_exception(
      err_type       NUMBER,
      segment_name   VARCHAR2);

  FUNCTION name_existed(
      reval_name   VARCHAR2,
      reval_id     NUMBER,
      coa_id       NUMBER)
    RETURN BOOLEAN;

  FUNCTION range_found(
      reval_id   NUMBER)
    RETURN BOOLEAN;

END glxrvsub_pkg;

 

/
