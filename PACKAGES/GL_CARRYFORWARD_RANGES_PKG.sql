--------------------------------------------------------
--  DDL for Package GL_CARRYFORWARD_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CARRYFORWARD_RANGES_PKG" AUTHID CURRENT_USER as
/* $Header: glicfras.pls 120.2 2005/05/05 01:03:46 kvora ship $ */

--
-- Package
--   GL_CARRYFORWARD_RANGES_PKG
-- Purpose
--   To implement various data checking needed for the
--   gl_carryforward_ranges
-- History
--   06-15-94  Kai Pigg Created

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique range id
  -- History
  --   06-15-94  Kai Pigg Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_carryforward_ranges_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   check_overlapping
  -- Purpose
  --   Checks to make sure that there are not overlapping
  --   ranges in your carryforward ranges
  -- History
  --   08-08-94  Kai Pigg    Created
  -- Arguments
  --   x_carryforward_range_id  Unique ID generated in the form.
  --				Note that this ID may be the same for bunch
  --				of rows
  --   x_segment1_low		Lower limit of segment value.
  --   x_segment1_high		Higher limit of segment value.
  --   ...			there are 30 ranges in the row
  --   x_segment30_low		Lower limit of segment value.
  --   x_segment30_high		Higher limit of segment value.
  --   row_id                   The id of the row
  --                            containing the period
  -- Example
  --   periods.check_overlapping(1232, '000', 'ZZZ',...,(30 pairs of ranges)
  --                             'AA01');
  -- Notes
  --
  PROCEDURE check_overlapping(x_carryforward_range_id IN NUMBER,
                         x_segment1_low    IN VARCHAR2,
                         x_segment1_high   IN VARCHAR2,
                         x_segment2_low    IN VARCHAR2,
                         x_segment2_high   IN VARCHAR2,
                         x_segment3_low    IN VARCHAR2,
                         x_segment3_high   IN VARCHAR2,
                         x_segment4_low    IN VARCHAR2,
                         x_segment4_high   IN VARCHAR2,
                         x_segment5_low    IN VARCHAR2,
                         x_segment5_high   IN VARCHAR2,
                         x_segment6_low    IN VARCHAR2,
                         x_segment6_high   IN VARCHAR2,
                         x_segment7_low    IN VARCHAR2,
                         x_segment7_high   IN VARCHAR2,
                         x_segment8_low    IN VARCHAR2,
                         x_segment8_high   IN VARCHAR2,
                         x_segment9_low    IN VARCHAR2,
                         x_segment9_high   IN VARCHAR2,
                         x_segment10_low   IN VARCHAR2,
                         x_segment10_high  IN VARCHAR2,
                         x_segment11_low   IN VARCHAR2,
                         x_segment11_high  IN VARCHAR2,
                         x_segment12_low   IN VARCHAR2,
                         x_segment12_high  IN VARCHAR2,
                         x_segment13_low   IN VARCHAR2,
                         x_segment13_high  IN VARCHAR2,
                         x_segment14_low   IN VARCHAR2,
                         x_segment14_high  IN VARCHAR2,
                         x_segment15_low   IN VARCHAR2,
                         x_segment15_high  IN VARCHAR2,
                         x_segment16_low   IN VARCHAR2,
                         x_segment16_high  IN VARCHAR2,
                         x_segment17_low   IN VARCHAR2,
                         x_segment17_high  IN VARCHAR2,
                         x_segment18_low   IN VARCHAR2,
                         x_segment18_high  IN VARCHAR2,
                         x_segment19_low   IN VARCHAR2,
                         x_segment19_high  IN VARCHAR2,
                         x_segment20_low   IN VARCHAR2,
                         x_segment20_high  IN VARCHAR2,
                         x_segment21_low   IN VARCHAR2,
                         x_segment21_high  IN VARCHAR2,
                         x_segment22_low   IN VARCHAR2,
                         x_segment22_high  IN VARCHAR2,
                         x_segment23_low   IN VARCHAR2,
                         x_segment23_high  IN VARCHAR2,
                         x_segment24_low   IN VARCHAR2,
                         x_segment24_high  IN VARCHAR2,
                         x_segment25_low   IN VARCHAR2,
                         x_segment25_high  IN VARCHAR2,
                         x_segment26_low   IN VARCHAR2,
                         x_segment26_high  IN VARCHAR2,
                         x_segment27_low   IN VARCHAR2,
                         x_segment27_high  IN VARCHAR2,
                         x_segment28_low   IN VARCHAR2,
                         x_segment28_high  IN VARCHAR2,
                         x_segment29_low   IN VARCHAR2,
                         x_segment29_high  IN VARCHAR2,
                         x_segment30_low   IN VARCHAR2,
                         x_segment30_high  IN VARCHAR2,
                         row_id            IN VARCHAR2);

END GL_CARRYFORWARD_RANGES_PKG;

 

/
