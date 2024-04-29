--------------------------------------------------------
--  DDL for Package Body GL_CONS_FLEX_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_FLEX_MAP_PKG" as
/* $Header: glicofrb.pls 120.4 2005/05/05 01:04:53 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

PROCEDURE Check_Overlap(X_Coa_Mapping_Id           NUMBER,
			row_id			   VARCHAR2,
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
) IS

CURSOR C1 IS SELECT 'Overlapping'
    FROM DUAL
   WHERE EXISTS
    (SELECT 'X' FROM  GL_CONS_FLEXFIELD_MAP fm
      WHERE COA_MAPPING_ID = X_Coa_Mapping_Id
	AND (row_id IS null OR fm.rowid <> row_id)
        AND (nvl(segment30_low, 'X') <= nvl(X_Segment30_High,'X')
        AND  nvl(segment30_high,'X') >= nvl(X_Segment30_Low, 'X')
        AND  nvl(segment29_low, 'X') <= nvl(X_Segment29_High,'X')
        AND  nvl(segment29_high,'X') >= nvl(X_Segment29_Low, 'X')
        AND  nvl(segment28_low, 'X') <= nvl(X_Segment28_High,'X')
        AND  nvl(segment28_high,'X') >= nvl(X_Segment28_Low, 'X')
        AND  nvl(segment27_low, 'X') <= nvl(X_Segment27_High,'X')
        AND  nvl(segment27_high,'X') >= nvl(X_Segment27_Low, 'X')
        AND  nvl(segment26_low, 'X') <= nvl(X_Segment26_High,'X')
        AND  nvl(segment26_high,'X') >= nvl(X_Segment26_Low, 'X')
        AND  nvl(segment25_low, 'X') <= nvl(X_Segment25_High,'X')
        AND  nvl(segment25_high,'X') >= nvl(X_Segment25_Low, 'X')
        AND  nvl(segment24_low, 'X') <= nvl(X_Segment24_High,'X')
        AND  nvl(segment24_high,'X') >= nvl(X_Segment24_Low, 'X')
        AND  nvl(segment23_low, 'X') <= nvl(X_Segment23_High,'X')
        AND  nvl(segment23_high,'X') >= nvl(X_Segment23_Low, 'X')
        AND  nvl(segment22_low, 'X') <= nvl(X_Segment22_High,'X')
        AND  nvl(segment22_high,'X') >= nvl(X_Segment22_Low, 'X')
        AND  nvl(segment21_low, 'X') <= nvl(X_Segment21_High,'X')
        AND  nvl(segment21_high,'X') >= nvl(X_Segment21_Low, 'X')
        AND  nvl(segment20_low, 'X') <= nvl(X_Segment20_High,'X')
        AND  nvl(segment20_high,'X') >= nvl(X_Segment20_Low, 'X')
        AND  nvl(segment19_low, 'X') <= nvl(X_Segment19_High,'X')
        AND  nvl(segment19_high,'X') >= nvl(X_Segment19_Low, 'X')
        AND  nvl(segment18_low, 'X') <= nvl(X_Segment18_High,'X')
        AND  nvl(segment18_high,'X') >= nvl(X_Segment18_Low, 'X')
        AND  nvl(segment17_low, 'X') <= nvl(X_Segment17_High,'X')
        AND  nvl(segment17_high,'X') >= nvl(X_Segment17_Low, 'X')
        AND  nvl(segment16_low, 'X') <= nvl(X_Segment16_High,'X')
        AND  nvl(segment16_high,'X') >= nvl(X_Segment16_Low, 'X')
        AND  nvl(segment15_low, 'X') <= nvl(X_Segment15_High,'X')
        AND  nvl(segment15_high,'X') >= nvl(X_Segment15_Low, 'X'))
        AND  nvl(segment14_low, 'X') <= nvl(X_Segment14_High,'X')
        AND  nvl(segment14_high,'X') >= nvl(X_Segment14_Low, 'X')
        AND  nvl(segment13_low, 'X') <= nvl(X_Segment13_High,'X')
        AND  nvl(segment13_high,'X') >= nvl(X_Segment13_Low, 'X')
        AND  nvl(segment12_low, 'X') <= nvl(X_Segment12_High,'X')
        AND  nvl(segment12_high,'X') >= nvl(X_Segment12_Low, 'X')
        AND  nvl(segment11_low, 'X') <= nvl(X_Segment11_High,'X')
        AND  nvl(segment11_high,'X') >= nvl(X_Segment11_Low, 'X')
        AND  nvl(segment10_low, 'X') <= nvl(X_Segment10_High,'X')
        AND  nvl(segment10_high,'X') >= nvl(X_Segment10_Low, 'X')
        AND  nvl( segment9_low, 'X') <= nvl(X_Segment9_High, 'X')
        AND  nvl(segment9_high, 'X') >= nvl( X_Segment9_Low, 'X')
        AND  nvl( segment8_low, 'X') <= nvl(X_Segment8_High, 'X')
        AND  nvl(segment8_high, 'X') >= nvl( X_Segment8_Low, 'X')
        AND  nvl( segment7_low, 'X') <= nvl(X_Segment7_High, 'X')
        AND  nvl(segment7_high, 'X') >= nvl( X_Segment7_Low, 'X')
        AND  nvl( segment6_low, 'X') <= nvl(X_Segment6_High, 'X')
        AND  nvl(segment6_high, 'X') >= nvl( X_Segment6_Low, 'X')
        AND  nvl( segment5_low, 'X') <= nvl(X_Segment5_High, 'X')
        AND  nvl(segment5_high, 'X') >= nvl( X_Segment5_Low, 'X')
        AND  nvl( segment4_low, 'X') <= nvl(X_Segment4_High, 'X')
        AND  nvl(segment4_high, 'X') >= nvl( X_Segment4_Low, 'X')
        AND  nvl( segment3_low, 'X') <= nvl(X_Segment3_High, 'X')
        AND  nvl(segment3_high, 'X') >= nvl( X_Segment3_Low, 'X')
        AND  nvl( segment2_low, 'X') <= nvl(X_Segment2_High, 'X')
        AND  nvl(segment2_high, 'X') >= nvl( X_Segment2_Low, 'X')
        AND  nvl( segment1_low, 'X') <= nvl(X_Segment1_High, 'X')
        AND  nvl(segment1_high, 'X') >= nvl( X_Segment1_Low, 'X'));

  V1   VARCHAR2(11);

BEGIN
  OPEN C1;
  FETCH C1 INTO V1;
  IF (C1%FOUND) THEN
    CLOSE C1;
    fnd_message.set_name('SQLGL', 'GL_CONS_OVERLAPPING_RANGES');
    app_exception.raise_exception;
  END IF;

  CLOSE C1;
END Check_Overlap;

PROCEDURE Get_New_Id(next_val IN OUT NOCOPY NUMBER) IS

BEGIN
  select GL_CONS_FLEXFIELD_MAP_S.NEXTVAL
  into   next_val
  from   dual;

  IF (next_val is NULL) THEN
    fnd_message.set_name('SQLGL', 'GL_SEQUENCE_NOT_FOUND');
    fnd_message.set_token('TAB_S', 'GL_CONS_FLEXFIELD_MAP_S');
    app_exception.raise_exception;
  END IF;
END Get_New_Id;

END GL_CONS_FLEX_MAP_PKG;

/
