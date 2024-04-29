--------------------------------------------------------
--  DDL for Package GL_CONS_FLEX_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_FLEX_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: glicofrs.pls 120.4 2005/05/05 01:04:59 kvora ship $ */
--
-- Package
--   gl_cons_flexfield_map_pkg
-- Purpose
--   Package procedures for Consolidation Setup form,
--     Flexfield Mapping Rules block
-- History
--   01/03/94	E Wilson	Created
--

  --
  -- Procedure
  --   Check_Overlap
  -- Purpose
  --   Check for overlapping subsidiary flexfield ranges
  -- Arguments
  --   X_Coa_Mapping_Id        COA mapping id
  --   X_Segment**_Low         Subsidiary range low segment value
  --   X_Segment**_High        Subsidiary range high segment value
  -- Example
  --   GL_CONS_FLEXFIELD_MAP_PKG.Check_Overlap(
  --          :FLEXFIELD_MAP.coa_mapping_id, :FLEXFIELD_MAP.row_id,
  --          :FLEXFIELD_MAP.segment1_low, :FLEXFIELD_MAP.segment1_high,
  --          :FLEXFIELD_MAP.segment2_low, :FLEXFIELD_MAP.segment2_high,
  --                   .
  --                   .
  --                   .
  --          :FLEXFIELD_MAP.segment30_low, :FLEXFIELD_MAP.segmen30_high);
  -- Notes
  --
  PROCEDURE Check_Overlap(X_Coa_Mapping_Id		NUMBER,
			  row_id			VARCHAR2,
                          X_Segment1_Low                VARCHAR2,
                          X_Segment1_High               VARCHAR2,
                          X_Segment2_Low                VARCHAR2,
                          X_Segment2_High               VARCHAR2,
                          X_Segment3_Low                VARCHAR2,
                          X_Segment3_High               VARCHAR2,
                          X_Segment4_Low                VARCHAR2,
                          X_Segment4_High               VARCHAR2,
                          X_Segment5_Low                VARCHAR2,
                          X_Segment5_High               VARCHAR2,
                          X_Segment6_Low                VARCHAR2,
                          X_Segment6_High               VARCHAR2,
                          X_Segment7_Low                VARCHAR2,
                          X_Segment7_High               VARCHAR2,
                          X_Segment8_Low                VARCHAR2,
                          X_Segment8_High               VARCHAR2,
                          X_Segment9_Low                VARCHAR2,
                          X_Segment9_High               VARCHAR2,
                          X_Segment10_Low                VARCHAR2,
                          X_Segment10_High               VARCHAR2,
                          X_Segment11_Low                VARCHAR2,
                          X_Segment11_High               VARCHAR2,
                          X_Segment12_Low                VARCHAR2,
                          X_Segment12_High               VARCHAR2,
                          X_Segment13_Low                VARCHAR2,
                          X_Segment13_High               VARCHAR2,
                          X_Segment14_Low                VARCHAR2,
                          X_Segment14_High               VARCHAR2,
                          X_Segment15_Low                VARCHAR2,
                          X_Segment15_High               VARCHAR2,
                          X_Segment16_Low                VARCHAR2,
                          X_Segment16_High               VARCHAR2,
                          X_Segment17_Low                VARCHAR2,
                          X_Segment17_High               VARCHAR2,
                          X_Segment18_Low                VARCHAR2,
                          X_Segment18_High               VARCHAR2,
                          X_Segment19_Low                VARCHAR2,
                          X_Segment19_High               VARCHAR2,
                          X_Segment20_Low                VARCHAR2,
                          X_Segment20_High               VARCHAR2,
                          X_Segment21_Low                VARCHAR2,
                          X_Segment21_High               VARCHAR2,
                          X_Segment22_Low                VARCHAR2,
                          X_Segment22_High               VARCHAR2,
                          X_Segment23_Low                VARCHAR2,
                          X_Segment23_High               VARCHAR2,
                          X_Segment24_Low                VARCHAR2,
                          X_Segment24_High               VARCHAR2,
                          X_Segment25_Low                VARCHAR2,
                          X_Segment25_High               VARCHAR2,
                          X_Segment26_Low                VARCHAR2,
                          X_Segment26_High               VARCHAR2,
                          X_Segment27_Low                VARCHAR2,
                          X_Segment27_High               VARCHAR2,
                          X_Segment28_Low                VARCHAR2,
                          X_Segment28_High               VARCHAR2,
                          X_Segment29_Low                VARCHAR2,
                          X_Segment29_High               VARCHAR2,
                          X_Segment30_Low                VARCHAR2,
                          X_Segment30_High               VARCHAR2
);

  --
  -- Procedure
  --   Get_New_Id
  -- Purpose
  --   Get next value from GL_CONS_FLEXFIELD_MAP_S
  -- Arguments
  --   next_val    Return next value in sequence
  -- Example
  --   GL_CONS_FLEXFIELD_MAP_PKG.Get_New_Id(:FLEXFIELD_MAP.flexfield_map_id)
  -- Notes
  --
  PROCEDURE Get_New_Id(next_val  IN OUT NOCOPY NUMBER);

END GL_CONS_FLEX_MAP_PKG;

 

/
