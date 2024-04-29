--------------------------------------------------------
--  DDL for Package Body PN_REC_EXP_EXTR_FROM_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_EXP_EXTR_FROM_GL_PKG" AS
/* $Header: PNGLRECB.pls 120.2 2005/12/01 14:45:22 sdmahesh noship $ */

/*----------------- DECLARATIONS PRIVATE TO THE PACKAGE ---------------------*/

TYPE periods_rec IS RECORD(period_name VARCHAR2(15),
                           start_date  DATE,
                           end_date    DATE);
TYPE ccid_rec    IS RECORD(map_row NUMBER,
                           map_id  NUMBER,
                           ccid    NUMBER,
                           act_amount  NUMBER,
                           bud_amount  NUMBER);

TYPE periods_tbl     IS TABLE OF periods_rec            INDEX BY BINARY_INTEGER;
TYPE ccid_tbl        IS TABLE OF ccid_rec               INDEX BY BINARY_INTEGER;
TYPE rec_exp_itf_tbl IS TABLE OF pn_rec_exp_itf%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE loc_acc_map_tbl IS TABLE OF pn_loc_acc_map%ROWTYPE INDEX BY BINARY_INTEGER;

/*------------------ PROCEDURES PRIVATE TO THE PACKAGE ----------------------*/

/*===========================================================================+
 | PROCEDURE
 |   verify_dates_for_map
 |
 | DESCRIPTION
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |   10-JUL-03 Kiran     o created
 +===========================================================================*/

PROCEDURE verify_dates_for_map(p_map_t     IN OUT NOCOPY loc_acc_map_tbl,
                               p_periods_t IN periods_tbl)
IS

l_info              VARCHAR2(240);

BEGIN

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.verify_dates_for_map (+)');

FOR i IN 1..p_map_t.COUNT LOOP

  l_info := 'verifying dates for map, Mapping Row number: '||to_char(i);
  /* verify start date */
  FOR j in 1..p_periods_t.COUNT LOOP
    IF p_map_t(i).effective_from_date <= p_periods_t(j).end_date THEN
       p_map_t(i).effective_from_date := p_periods_t(j).start_date;
       EXIT;
    END IF;
  END LOOP;
  /* verify end date */
  FOR j in REVERSE 1..p_periods_t.COUNT LOOP
    IF p_map_t(i).effective_to_date >= p_periods_t(j).start_date THEN
       p_map_t(i).effective_to_date := p_periods_t(j).end_date;
       EXIT;
    END IF;
  END LOOP;

END LOOP;

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.verify_dates_for_map (-)');

EXCEPTION
  WHEN OTHERS THEN
    Put_Log('Error while '|| l_info);
    Raise;

END verify_dates_for_map;

/*===========================================================================+
 | PROCEDURE
 |   get_ccids
 |
 | DESCRIPTION
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |   10-JUL-03 Kiran     o created
 |   27-OCT-05 sdmahesh  o ATG Mandated changes for SQL literals
 +===========================================================================*/

PROCEDURE get_ccids(p_sob_id IN NUMBER,
                    p_map_t  IN loc_acc_map_tbl,
                    p_ccid_t IN OUT NOCOPY ccid_tbl)
IS

l_summary_flag   VARCHAR2(1) := 'N';
x_summary_flag   VARCHAR2(1);
l_info           VARCHAR2(240);
l_ccid_tbl_count NUMBER := p_ccid_t.COUNT;
l_ccid_temp      NUMBER;
l_Where_Clause   VARCHAR2(1000);
l_rows           INTEGER;
l_count          INTEGER;
l_sob_id         INTEGER;
l_cursor         INTEGER;



l_statement                VARCHAR2(10000);
l_segment1_low             VARCHAR2(25);
l_segment1_high            VARCHAR2(25);
l_segment2_low             VARCHAR2(25);
l_segment2_high            VARCHAR2(25);
l_segment3_low             VARCHAR2(25);
l_segment3_high            VARCHAR2(25);
l_segment4_low             VARCHAR2(25);
l_segment4_high            VARCHAR2(25);
l_segment5_low             VARCHAR2(25);
l_segment5_high            VARCHAR2(25);
l_segment6_low             VARCHAR2(25);
l_segment6_high            VARCHAR2(25);
l_segment7_low             VARCHAR2(25);
l_segment7_high            VARCHAR2(25);
l_segment8_low             VARCHAR2(25);
l_segment8_high            VARCHAR2(25);
l_segment9_low             VARCHAR2(25);
l_segment9_high            VARCHAR2(25);
l_segment10_low             VARCHAR2(25);
l_segment10_high            VARCHAR2(25);
l_segment11_low             VARCHAR2(25);
l_segment11_high            VARCHAR2(25);
l_segment12_low             VARCHAR2(25);
l_segment12_high            VARCHAR2(25);
l_segment13_low             VARCHAR2(25);
l_segment13_high            VARCHAR2(25);
l_segment14_low             VARCHAR2(25);
l_segment14_high            VARCHAR2(25);
l_segment15_low             VARCHAR2(25);
l_segment15_high            VARCHAR2(25);
l_segment16_low             VARCHAR2(25);
l_segment16_high            VARCHAR2(25);
l_segment17_low             VARCHAR2(25);
l_segment17_high            VARCHAR2(25);
l_segment18_low             VARCHAR2(25);
l_segment18_high            VARCHAR2(25);
l_segment19_low             VARCHAR2(25);
l_segment19_high            VARCHAR2(25);
l_segment20_low             VARCHAR2(25);
l_segment20_high            VARCHAR2(25);
l_segment21_low             VARCHAR2(25);
l_segment21_high            VARCHAR2(25);
l_segment22_low             VARCHAR2(25);
l_segment22_high            VARCHAR2(25);
l_segment23_low             VARCHAR2(25);
l_segment23_high            VARCHAR2(25);
l_segment24_low             VARCHAR2(25);
l_segment24_high            VARCHAR2(25);
l_segment25_low             VARCHAR2(25);
l_segment25_high            VARCHAR2(25);
l_segment26_low             VARCHAR2(25);
l_segment26_high            VARCHAR2(25);
l_segment27_low             VARCHAR2(25);
l_segment27_high            VARCHAR2(25);
l_segment28_low             VARCHAR2(25);
l_segment28_high            VARCHAR2(25);
l_segment29_low             VARCHAR2(25);
l_segment29_high            VARCHAR2(25);
l_segment30_low             VARCHAR2(25);
l_segment30_high            VARCHAR2(25);


BEGIN

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.get_ccids (+)');

FOR i IN 1..p_map_t.COUNT LOOP

  l_info := 'processing Map Row: '||to_char(i)
             ||'; Creating dynamic Where Clause';

  l_Where_Clause := null;
  l_cursor := dbms_sql.open_cursor;

  /* segment 1 */
  IF p_map_t(i).segment1_low IS NOT NULL
     and p_map_t(i).segment1_high IS NULL THEN
     l_segment1_low   := p_map_t(i).segment1_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment1 >= :l_segment1_low';


  ELSIF p_map_t(i).segment1_low IS NULL
     and p_map_t(i).segment1_high IS NOT NULL THEN
     l_segment1_high := p_map_t(i).segment1_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment1 <= :l_segment1_high';


  ELSIF p_map_t(i).segment1_low IS NOT NULL
     and p_map_t(i).segment1_high IS NOT NULL THEN
     l_segment1_low   := p_map_t(i).segment1_low;
     l_segment1_high :=  p_map_t(i).segment1_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment1 Between :l_segment1_low
                        And :l_segment1_high';

  END IF;

  /* segment 2 */
  IF p_map_t(i).segment2_low IS NOT NULL
     and p_map_t(i).segment2_high IS NULL THEN
     l_segment2_low   := p_map_t(i).segment2_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment2 >= :l_segment2_low';

  ELSIF p_map_t(i).segment2_low IS NULL
     and p_map_t(i).segment2_high IS NOT NULL THEN
     l_segment2_high   := p_map_t(i).segment2_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment2 <= :l_segment2_high';


  ELSIF p_map_t(i).segment2_low IS NOT NULL
     and p_map_t(i).segment2_high IS NOT NULL THEN
     l_segment2_low   := p_map_t(i).segment2_low;
     l_segment2_high :=  p_map_t(i).segment2_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment2 Between :l_segment2_low
                        And :l_segment2_high ';

  END IF;

  /* segment 3 */
  IF p_map_t(i).segment3_low IS NOT NULL
     and p_map_t(i).segment3_high IS NULL THEN
     l_segment3_low   := p_map_t(i).segment3_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment3 >= :l_segment3_low';


  ELSIF p_map_t(i).segment3_low IS NULL
     and p_map_t(i).segment3_high IS NOT NULL THEN
     l_segment3_high   := p_map_t(i).segment3_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment3 <= :l_segment3_high';


  ELSIF p_map_t(i).segment3_low IS NOT NULL
     and p_map_t(i).segment3_high IS NOT NULL THEN
     l_segment3_low   := p_map_t(i).segment3_low;
     l_segment3_high :=  p_map_t(i).segment3_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment3 Between :l_segment3_low
                        And :l_segment3_high ';

  END IF;

  /* segment 4 */
  IF p_map_t(i).segment4_low IS NOT NULL
     and p_map_t(i).segment4_high IS NULL THEN
     l_segment4_low   := p_map_t(i).segment4_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment4 >= :l_segment4_low';


  ELSIF p_map_t(i).segment4_low IS NULL
     and p_map_t(i).segment4_high IS NOT NULL THEN
     l_segment4_high   := p_map_t(i).segment4_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment4 <= :l_segment4_high';


  ELSIF p_map_t(i).segment4_low IS NOT NULL
     and p_map_t(i).segment4_high IS NOT NULL THEN
     l_segment4_low   := p_map_t(i).segment4_low;
     l_segment4_high :=  p_map_t(i).segment4_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment4 Between :l_segment4_low
                        And :l_segment4_high ';

  END IF;

  /* segment 5 */
  IF p_map_t(i).segment5_low IS NOT NULL
     and p_map_t(i).segment5_high IS NULL THEN
     l_segment5_low   := p_map_t(i).segment5_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment5 >= :l_segment5_low';


  ELSIF p_map_t(i).segment5_low IS NULL
     and p_map_t(i).segment5_high IS NOT NULL THEN
     l_segment5_high   := p_map_t(i).segment5_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment5 <= :l_segment5_high';


  ELSIF p_map_t(i).segment5_low IS NOT NULL
     and p_map_t(i).segment5_high IS NOT NULL THEN
     l_segment5_low   := p_map_t(i).segment5_low;
     l_segment5_high :=  p_map_t(i).segment5_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment5 Between :l_segment5_low
                        And :l_segment5_high ';

  END IF;


  /* segment 6 */
  IF p_map_t(i).segment6_low IS NOT NULL
     and p_map_t(i).segment6_high IS NULL THEN
     l_segment6_low   := p_map_t(i).segment6_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment6 >= :l_segment6_low';


  ELSIF p_map_t(i).segment6_low IS NULL
     and p_map_t(i).segment6_high IS NOT NULL THEN
     l_segment6_high   := p_map_t(i).segment6_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment6 <= :l_segment6_high';


  ELSIF p_map_t(i).segment6_low IS NOT NULL
     and p_map_t(i).segment6_high IS NOT NULL THEN
     l_segment6_low   := p_map_t(i).segment6_low;
     l_segment6_high :=  p_map_t(i).segment6_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment6 Between :l_segment6_low
                        And :l_segment6_high ';

  END IF;

  /* segment 7 */
  IF p_map_t(i).segment7_low IS NOT NULL
     and p_map_t(i).segment7_high IS NULL THEN
     l_segment7_low   := p_map_t(i).segment7_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment7 >= :l_segment7_low';


  ELSIF p_map_t(i).segment7_low IS NULL
     and p_map_t(i).segment7_high IS NOT NULL THEN
     l_segment7_high   := p_map_t(i).segment7_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment7 <= :l_segment7_high';


  ELSIF p_map_t(i).segment7_low IS NOT NULL
     and p_map_t(i).segment7_high IS NOT NULL THEN
     l_segment7_low   := p_map_t(i).segment7_low;
     l_segment7_high :=  p_map_t(i).segment7_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment7 Between :l_segment7_low
                        And :l_segment7_high ';

  END IF;

  /* segment 8 */
  IF p_map_t(i).segment8_low IS NOT NULL
     and p_map_t(i).segment8_high IS NULL THEN
     l_segment8_low   := p_map_t(i).segment8_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment8 >= :l_segment8_low';


  ELSIF p_map_t(i).segment8_low IS NULL
     and p_map_t(i).segment8_high IS NOT NULL THEN
     l_segment8_high   := p_map_t(i).segment8_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment8 <= :l_segment8_high';


  ELSIF p_map_t(i).segment8_low IS NOT NULL
     and p_map_t(i).segment8_high IS NOT NULL THEN
     l_segment8_low   := p_map_t(i).segment8_low;
     l_segment8_high :=  p_map_t(i).segment8_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment8 Between :l_segment8_low
                        And :l_segment8_high ';

  END IF;

  /* segment 9 */
  IF p_map_t(i).segment9_low IS NOT NULL
     and p_map_t(i).segment9_high IS NULL THEN
     l_segment9_low   := p_map_t(i).segment9_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment9 >= :l_segment9_low';


  ELSIF p_map_t(i).segment9_low IS NULL
     and p_map_t(i).segment9_high IS NOT NULL THEN
     l_segment9_high   := p_map_t(i).segment9_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment9 <= :l_segment9_high';


  ELSIF p_map_t(i).segment9_low IS NOT NULL
     and p_map_t(i).segment9_high IS NOT NULL THEN
     l_segment9_low   := p_map_t(i).segment9_low;
     l_segment9_high :=  p_map_t(i).segment9_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment9 Between :l_segment9_low
                        And :l_segment9_high ';

  END IF;

  /* segment 10 */
  IF p_map_t(i).segment10_low IS NOT NULL
     and p_map_t(i).segment10_high IS NULL THEN
     l_segment10_low   := p_map_t(i).segment10_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment10 >= :l_segment10_low';


  ELSIF p_map_t(i).segment10_low IS NULL
     and p_map_t(i).segment10_high IS NOT NULL THEN
     l_segment10_high   := p_map_t(i).segment10_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment10 <= :l_segment10_high';


  ELSIF p_map_t(i).segment10_low IS NOT NULL
     and p_map_t(i).segment10_high IS NOT NULL THEN
     l_segment10_low   := p_map_t(i).segment10_low;
     l_segment10_high :=  p_map_t(i).segment10_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment10 Between :l_segment10_low
                        And :l_segment10_high ';

  END IF;

  /* segment 11 */
  IF p_map_t(i).segment11_low IS NOT NULL
     and p_map_t(i).segment11_high IS NULL THEN
     l_segment11_low   := p_map_t(i).segment11_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment11 >= :l_segment11_low';


  ELSIF p_map_t(i).segment11_low IS NULL
     and p_map_t(i).segment11_high IS NOT NULL THEN
     l_segment11_high   := p_map_t(i).segment11_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment11 <= :l_segment11_high';


  ELSIF p_map_t(i).segment11_low IS NOT NULL
     and p_map_t(i).segment11_high IS NOT NULL THEN
     l_segment11_low   := p_map_t(i).segment11_low;
     l_segment11_high :=  p_map_t(i).segment11_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment11 Between :l_segment11_low
                        And :l_segment11_high ';

  END IF;

  /* segment 12 */
  IF p_map_t(i).segment12_low IS NOT NULL
     and p_map_t(i).segment12_high IS NULL THEN
     l_segment12_low   := p_map_t(i).segment12_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment12 >= :l_segment12_low';


  ELSIF p_map_t(i).segment12_low IS NULL
     and p_map_t(i).segment12_high IS NOT NULL THEN
     l_segment12_high   := p_map_t(i).segment12_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment12 <= :l_segment12_high';


  ELSIF p_map_t(i).segment12_low IS NOT NULL
     and p_map_t(i).segment12_high IS NOT NULL THEN
     l_segment12_low   := p_map_t(i).segment12_low;
     l_segment12_high :=  p_map_t(i).segment12_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment12 Between :l_segment12_low
                        And :l_segment12_high ';

  END IF;

  /* segment 13 */
  IF p_map_t(i).segment13_low IS NOT NULL
     and p_map_t(i).segment13_high IS NULL THEN
     l_segment13_low   := p_map_t(i).segment13_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment13 >= :l_segment13_low';


  ELSIF p_map_t(i).segment13_low IS NULL
     and p_map_t(i).segment13_high IS NOT NULL THEN
     l_segment13_high   := p_map_t(i).segment13_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment13 <= :l_segment13_high';


  ELSIF p_map_t(i).segment13_low IS NOT NULL
     and p_map_t(i).segment13_high IS NOT NULL THEN
     l_segment13_low   := p_map_t(i).segment13_low;
     l_segment13_high :=  p_map_t(i).segment13_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment13 Between :l_segment13_low
                        And :l_segment13_high ';

  END IF;

  /* segment 14 */
  IF p_map_t(i).segment14_low IS NOT NULL
     and p_map_t(i).segment14_high IS NULL THEN
     l_segment14_low   := p_map_t(i).segment14_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment14 >= :l_segment14_low';


  ELSIF p_map_t(i).segment14_low IS NULL
     and p_map_t(i).segment14_high IS NOT NULL THEN
     l_segment14_high   := p_map_t(i).segment14_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment14 <= :l_segment14_high';


  ELSIF p_map_t(i).segment14_low IS NOT NULL
     and p_map_t(i).segment14_high IS NOT NULL THEN
     l_segment14_low   := p_map_t(i).segment14_low;
     l_segment14_high :=  p_map_t(i).segment14_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment14 Between :l_segment14_low
                        And :l_segment14_high ';


  END IF;

  /* segment 15 */
  IF p_map_t(i).segment15_low IS NOT NULL
     and p_map_t(i).segment15_high IS NULL THEN
     l_segment15_low   := p_map_t(i).segment15_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment15 >= :l_segment15_low';


  ELSIF p_map_t(i).segment15_low IS NULL
     and p_map_t(i).segment15_high IS NOT NULL THEN
     l_segment15_high   := p_map_t(i).segment15_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment15 <= :l_segment15_high';


  ELSIF p_map_t(i).segment15_low IS NOT NULL
     and p_map_t(i).segment15_high IS NOT NULL THEN
     l_segment15_low   := p_map_t(i).segment15_low;
     l_segment15_high :=  p_map_t(i).segment15_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment15 Between :l_segment15_low
                        And :l_segment15_high ';

  END IF;

  /* segment 16 */
  IF p_map_t(i).segment16_low IS NOT NULL
     and p_map_t(i).segment16_high IS NULL THEN
     l_segment16_low   := p_map_t(i).segment16_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment16 >= :l_segment16_low';


  ELSIF p_map_t(i).segment16_low IS NULL
     and p_map_t(i).segment16_high IS NOT NULL THEN
     l_segment16_high   := p_map_t(i).segment16_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment16 <= :l_segment16_high';


  ELSIF p_map_t(i).segment16_low IS NOT NULL
     and p_map_t(i).segment16_high IS NOT NULL THEN
     l_segment16_low   := p_map_t(i).segment16_low;
     l_segment16_high :=  p_map_t(i).segment16_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment16 Between :l_segment16_low
                        And :l_segment16_high ';

  END IF;


  /* segment 17 */
    IF p_map_t(i).segment17_low IS NOT NULL
     and p_map_t(i).segment17_high IS NULL THEN
     l_segment17_low   := p_map_t(i).segment17_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment17 >= :l_segment17_low';


  ELSIF p_map_t(i).segment17_low IS NULL
     and p_map_t(i).segment17_high IS NOT NULL THEN
     l_segment17_high   := p_map_t(i).segment17_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment17 <= :l_segment17_high';


  ELSIF p_map_t(i).segment17_low IS NOT NULL
     and p_map_t(i).segment17_high IS NOT NULL THEN
     l_segment17_low   := p_map_t(i).segment17_low;
     l_segment17_high :=  p_map_t(i).segment17_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment17 Between :l_segment17_low
                        And :l_segment17_high ';

  END IF;

  /* segment 18 */
  IF p_map_t(i).segment18_low IS NOT NULL
     and p_map_t(i).segment18_high IS NULL THEN
     l_segment18_low   := p_map_t(i).segment18_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment18 >= :l_segment18_low';


  ELSIF p_map_t(i).segment18_low IS NULL
     and p_map_t(i).segment18_high IS NOT NULL THEN
     l_segment18_high   := p_map_t(i).segment18_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment18 <= :l_segment18_high';


  ELSIF p_map_t(i).segment18_low IS NOT NULL
     and p_map_t(i).segment18_high IS NOT NULL THEN
     l_segment18_low   := p_map_t(i).segment18_low;
     l_segment18_high :=  p_map_t(i).segment18_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment18 Between :l_segment18_low
                        And :l_segment18_high ';

  END IF;


  /* segment 19 */
  IF p_map_t(i).segment19_low IS NOT NULL
     and p_map_t(i).segment19_high IS NULL THEN
     l_segment19_low   := p_map_t(i).segment19_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment19 >= :l_segment19_low';


  ELSIF p_map_t(i).segment19_low IS NULL
     and p_map_t(i).segment19_high IS NOT NULL THEN
     l_segment19_high   := p_map_t(i).segment19_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment19 <= :l_segment19_high';


  ELSIF p_map_t(i).segment19_low IS NOT NULL
     and p_map_t(i).segment19_high IS NOT NULL THEN
     l_segment19_low   := p_map_t(i).segment19_low;
     l_segment19_high :=  p_map_t(i).segment19_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment19 Between :l_segment19_low
                        And :l_segment19_high ';

  END IF;

  /* segment 20 */
  IF p_map_t(i).segment20_low IS NOT NULL
     and p_map_t(i).segment20_high IS NULL THEN
     l_segment20_low   := p_map_t(i).segment20_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment20 >= :l_segment20_low';


  ELSIF p_map_t(i).segment20_low IS NULL
     and p_map_t(i).segment20_high IS NOT NULL THEN
     l_segment20_high   := p_map_t(i).segment20_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment20 <= :l_segment20_high';


  ELSIF p_map_t(i).segment20_low IS NOT NULL
     and p_map_t(i).segment20_high IS NOT NULL THEN
     l_segment20_low   := p_map_t(i).segment20_low;
     l_segment20_high :=  p_map_t(i).segment20_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment20 Between :l_segment20_low
                        And :l_segment20_high ';

  END IF;

  /* segment 21 */
  IF p_map_t(i).segment21_low IS NOT NULL
     and p_map_t(i).segment21_high IS NULL THEN
     l_segment21_low   := p_map_t(i).segment21_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment21 >= :l_segment21_low';


  ELSIF p_map_t(i).segment21_low IS NULL
     and p_map_t(i).segment21_high IS NOT NULL THEN
     l_segment21_high   := p_map_t(i).segment21_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment21 <= :l_segment21_high';


  ELSIF p_map_t(i).segment21_low IS NOT NULL
     and p_map_t(i).segment21_high IS NOT NULL THEN
     l_segment21_low   := p_map_t(i).segment21_low;
     l_segment21_high :=  p_map_t(i).segment21_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment21 Between :l_segment21_low
                        And :l_segment21_high ';

  END IF;

  /* segment 22 */
  IF p_map_t(i).segment22_low IS NOT NULL
     and p_map_t(i).segment22_high IS NULL THEN
     l_segment22_low   := p_map_t(i).segment22_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment22 >= :l_segment22_low';


  ELSIF p_map_t(i).segment22_low IS NULL
     and p_map_t(i).segment22_high IS NOT NULL THEN
     l_segment22_high   := p_map_t(i).segment22_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment22 <= :l_segment22_high';


  ELSIF p_map_t(i).segment22_low IS NOT NULL
     and p_map_t(i).segment22_high IS NOT NULL THEN
     l_segment22_low   := p_map_t(i).segment22_low;
     l_segment22_high :=  p_map_t(i).segment22_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment22 Between :l_segment22_low
                        And :l_segment22_high ';

  END IF;

  /* segment 23 */
  IF p_map_t(i).segment23_low IS NOT NULL
     and p_map_t(i).segment23_high IS NULL THEN
     l_segment23_low   := p_map_t(i).segment23_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment23 >= :l_segment23_low';


  ELSIF p_map_t(i).segment23_low IS NULL
     and p_map_t(i).segment23_high IS NOT NULL THEN
     l_segment23_high   := p_map_t(i).segment23_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment23 <= :l_segment23_high';


  ELSIF p_map_t(i).segment23_low IS NOT NULL
     and p_map_t(i).segment23_high IS NOT NULL THEN
     l_segment23_low   := p_map_t(i).segment23_low;
     l_segment23_high :=  p_map_t(i).segment23_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment23 Between :l_segment23_low
                        And :l_segment23_high ';

  END IF;

  /* segment 24 */
   IF p_map_t(i).segment24_low IS NOT NULL
     and p_map_t(i).segment24_high IS NULL THEN
     l_segment24_low   := p_map_t(i).segment24_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment24 >= :l_segment24_low';


  ELSIF p_map_t(i).segment24_low IS NULL
     and p_map_t(i).segment24_high IS NOT NULL THEN
     l_segment24_high   := p_map_t(i).segment24_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment24 <= :l_segment24_high';


  ELSIF p_map_t(i).segment24_low IS NOT NULL
     and p_map_t(i).segment24_high IS NOT NULL THEN
     l_segment24_low   := p_map_t(i).segment24_low;
     l_segment24_high :=  p_map_t(i).segment24_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment24 Between :l_segment24_low
                        And :l_segment24_high ';

  END IF;


  /* segment 25 */
  IF p_map_t(i).segment25_low IS NOT NULL
     and p_map_t(i).segment25_high IS NULL THEN
     l_segment25_low   := p_map_t(i).segment25_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment25 >= :l_segment25_low';


  ELSIF p_map_t(i).segment25_low IS NULL
     and p_map_t(i).segment25_high IS NOT NULL THEN
     l_segment25_high   := p_map_t(i).segment25_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment25 <= :l_segment25_high';


  ELSIF p_map_t(i).segment25_low IS NOT NULL
     and p_map_t(i).segment25_high IS NOT NULL THEN
     l_segment25_low   := p_map_t(i).segment25_low;
     l_segment25_high :=  p_map_t(i).segment25_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment25 Between :l_segment25_low
                        And :l_segment25_high ';

  END IF;

  /* segment 26 */
  IF p_map_t(i).segment26_low IS NOT NULL
     and p_map_t(i).segment26_high IS NULL THEN
     l_segment26_low   := p_map_t(i).segment26_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment26 >= :l_segment26_low';


  ELSIF p_map_t(i).segment26_low IS NULL
     and p_map_t(i).segment26_high IS NOT NULL THEN
     l_segment26_high   := p_map_t(i).segment26_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment26 <= :l_segment26_high';


  ELSIF p_map_t(i).segment26_low IS NOT NULL
     and p_map_t(i).segment26_high IS NOT NULL THEN
     l_segment26_low   := p_map_t(i).segment26_low;
     l_segment26_high :=  p_map_t(i).segment26_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment26 Between :l_segment26_low
                        And :l_segment26_high ';

  END IF;

  /* segment 27 */
  IF p_map_t(i).segment27_low IS NOT NULL
     and p_map_t(i).segment27_high IS NULL THEN
     l_segment27_low   := p_map_t(i).segment27_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment27 >= :l_segment27_low';


  ELSIF p_map_t(i).segment27_low IS NULL
     and p_map_t(i).segment27_high IS NOT NULL THEN
     l_segment27_high   := p_map_t(i).segment27_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment27 <= :l_segment27_high';


  ELSIF p_map_t(i).segment27_low IS NOT NULL
     and p_map_t(i).segment27_high IS NOT NULL THEN
     l_segment27_low   := p_map_t(i).segment27_low;
     l_segment27_high :=  p_map_t(i).segment27_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment27 Between :l_segment27_low
                        And :l_segment27_high ';

  END IF;

  /* segment 28 */
  IF p_map_t(i).segment28_low IS NOT NULL
     and p_map_t(i).segment28_high IS NULL THEN
     l_segment28_low   := p_map_t(i).segment28_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment28 >= :l_segment28_low';


  ELSIF p_map_t(i).segment28_low IS NULL
     and p_map_t(i).segment28_high IS NOT NULL THEN
     l_segment28_high   := p_map_t(i).segment28_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment28 <= :l_segment28_high';


  ELSIF p_map_t(i).segment28_low IS NOT NULL
     and p_map_t(i).segment28_high IS NOT NULL THEN
     l_segment28_low   := p_map_t(i).segment28_low;
     l_segment28_high :=  p_map_t(i).segment28_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment28 Between :l_segment28_low
                        And :l_segment28_high ';

  END IF;

  /* segment 29 */
  IF p_map_t(i).segment29_low IS NOT NULL
     and p_map_t(i).segment29_high IS NULL THEN
     l_segment29_low   := p_map_t(i).segment29_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment29 >= :l_segment29_low';


  ELSIF p_map_t(i).segment29_low IS NULL
     and p_map_t(i).segment29_high IS NOT NULL THEN
     l_segment29_high   := p_map_t(i).segment29_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment29 <= :l_segment29_high';


  ELSIF p_map_t(i).segment29_low IS NOT NULL
     and p_map_t(i).segment29_high IS NOT NULL THEN
     l_segment29_low   := p_map_t(i).segment29_low;
     l_segment29_high :=  p_map_t(i).segment29_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment29 Between :l_segment29_low
                        And :l_segment29_high ';

  END IF;

  /* segment 30 */
  IF p_map_t(i).segment30_low IS NOT NULL
     and p_map_t(i).segment30_high IS NULL THEN
     l_segment30_low   := p_map_t(i).segment30_low;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment30 >= :l_segment30_low';


  ELSIF p_map_t(i).segment30_low IS NULL
     and p_map_t(i).segment30_high IS NOT NULL THEN
     l_segment30_high   := p_map_t(i).segment30_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment30 <= :l_segment30_high';


  ELSIF p_map_t(i).segment30_low IS NOT NULL
     and p_map_t(i).segment30_high IS NOT NULL THEN
     l_segment30_low   := p_map_t(i).segment30_low;
     l_segment30_high :=  p_map_t(i).segment30_high;
     l_Where_Clause := l_Where_Clause
                    ||' And gcc.segment30 Between :l_segment30_low
                        And :l_segment30_high ';

  END IF;

  Put_Log('Where clause for CCID: ');
  Put_Log(l_Where_clause);

  l_info := 'opening ref cursor for CCID';

  l_sob_id := p_sob_id;
  x_summary_flag := l_summary_flag;
  l_statement :=
    'Select gcc.code_combination_id
     From   gl_code_combinations gcc,
            gl_sets_of_books     gsob
     Where  gsob.set_of_books_id  = :l_sob_id
     And    gcc.chart_of_accounts_id   = gsob.chart_of_accounts_id
     And    gcc.summary_flag = :x_summary_flag
     And    gcc.template_id IS NULL '
    || l_Where_Clause ;



  put_log('l_statement='||l_statement);
  dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);
  dbms_sql.bind_variable(l_cursor,'l_sob_id',l_sob_id);
  dbms_sql.bind_variable(l_cursor,'x_summary_flag',x_summary_flag);

 /* segment 1 */
  IF p_map_t(i).segment1_low IS NOT NULL
     and p_map_t(i).segment1_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment1_low',l_segment1_low);

  ELSIF p_map_t(i).segment1_low IS NULL
     and p_map_t(i).segment1_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment1_high',l_segment1_high);

  ELSIF p_map_t(i).segment1_low IS NOT NULL
     and p_map_t(i).segment1_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment1_low',l_segment1_low);
       dbms_sql.bind_variable(l_cursor,'l_segment1_high',l_segment1_high);
  END IF;

  /* segment 2 */
  IF p_map_t(i).segment2_low IS NOT NULL
     and p_map_t(i).segment2_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment2_low',l_segment2_low);

  ELSIF p_map_t(i).segment2_low IS NULL
     and p_map_t(i).segment2_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment2_high',l_segment2_high);

  ELSIF p_map_t(i).segment2_low IS NOT NULL
     and p_map_t(i).segment2_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment2_low',l_segment2_low);
       dbms_sql.bind_variable(l_cursor,'l_segment2_high',l_segment2_high);
  END IF;

  /* segment 3 */
  IF p_map_t(i).segment3_low IS NOT NULL
     and p_map_t(i).segment3_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment3_low',l_segment3_low);

  ELSIF p_map_t(i).segment3_low IS NULL
     and p_map_t(i).segment3_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment3_high',l_segment3_high);

  ELSIF p_map_t(i).segment3_low IS NOT NULL
     and p_map_t(i).segment3_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment3_low',l_segment3_low);
       dbms_sql.bind_variable(l_cursor,'l_segment3_high',l_segment3_high);
  END IF;

  /* segment 4 */
  IF p_map_t(i).segment4_low IS NOT NULL
     and p_map_t(i).segment4_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment4_low',l_segment4_low);

  ELSIF p_map_t(i).segment4_low IS NULL
     and p_map_t(i).segment4_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment4_high',l_segment4_high);

  ELSIF p_map_t(i).segment4_low IS NOT NULL
     and p_map_t(i).segment4_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment4_low',l_segment4_low);
       dbms_sql.bind_variable(l_cursor,'l_segment4_high',l_segment4_high);
  END IF;

  /* segment 5 */
  IF p_map_t(i).segment5_low IS NOT NULL
     and p_map_t(i).segment5_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment5_low',l_segment5_low);

  ELSIF p_map_t(i).segment5_low IS NULL
     and p_map_t(i).segment5_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment5_high',l_segment5_high);

  ELSIF p_map_t(i).segment5_low IS NOT NULL
     and p_map_t(i).segment5_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment5_low',l_segment5_low);
       dbms_sql.bind_variable(l_cursor,'l_segment5_high',l_segment5_high);
  END IF;

  /* segment 6 */
  IF p_map_t(i).segment6_low IS NOT NULL
     and p_map_t(i).segment6_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment6_low',l_segment6_low);

  ELSIF p_map_t(i).segment6_low IS NULL
     and p_map_t(i).segment6_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment6_high',l_segment6_high);

  ELSIF p_map_t(i).segment6_low IS NOT NULL
     and p_map_t(i).segment6_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment6_low',l_segment6_low);
       dbms_sql.bind_variable(l_cursor,'l_segment6_high',l_segment6_high);
  END IF;

  /* segment 7 */
  IF p_map_t(i).segment7_low IS NOT NULL
     and p_map_t(i).segment7_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment7_low',l_segment7_low);

  ELSIF p_map_t(i).segment7_low IS NULL
     and p_map_t(i).segment7_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment7_high',l_segment7_high);

  ELSIF p_map_t(i).segment7_low IS NOT NULL
     and p_map_t(i).segment7_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment7_low',l_segment7_low);
       dbms_sql.bind_variable(l_cursor,'l_segment7_high',l_segment7_high);
  END IF;

  /* segment 8 */
  IF p_map_t(i).segment8_low IS NOT NULL
     and p_map_t(i).segment8_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment8_low',l_segment8_low);

  ELSIF p_map_t(i).segment8_low IS NULL
     and p_map_t(i).segment8_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment8_high',l_segment8_high);

  ELSIF p_map_t(i).segment8_low IS NOT NULL
     and p_map_t(i).segment8_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment8_low',l_segment8_low);
       dbms_sql.bind_variable(l_cursor,'l_segment8_high',l_segment8_high);
  END IF;

  /* segment 9 */
  IF p_map_t(i).segment9_low IS NOT NULL
     and p_map_t(i).segment9_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment9_low',l_segment9_low);

  ELSIF p_map_t(i).segment9_low IS NULL
     and p_map_t(i).segment9_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment9_high',l_segment9_high);

  ELSIF p_map_t(i).segment9_low IS NOT NULL
     and p_map_t(i).segment9_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment9_low',l_segment9_low);
       dbms_sql.bind_variable(l_cursor,'l_segment9_high',l_segment9_high);
  END IF;

  /* segment 10 */
  IF p_map_t(i).segment10_low IS NOT NULL
     and p_map_t(i).segment10_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment10_low',l_segment10_low);

  ELSIF p_map_t(i).segment10_low IS NULL
     and p_map_t(i).segment10_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment10_high',l_segment10_high);

  ELSIF p_map_t(i).segment10_low IS NOT NULL
     and p_map_t(i).segment10_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment10_low',l_segment10_low);
       dbms_sql.bind_variable(l_cursor,'l_segment10_high',l_segment10_high);
  END IF;

  /* segment 11 */
  IF p_map_t(i).segment11_low IS NOT NULL
     and p_map_t(i).segment11_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment11_low',l_segment11_low);

  ELSIF p_map_t(i).segment11_low IS NULL
     and p_map_t(i).segment11_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment11_high',l_segment11_high);

  ELSIF p_map_t(i).segment11_low IS NOT NULL
     and p_map_t(i).segment11_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment11_low',l_segment11_low);
       dbms_sql.bind_variable(l_cursor,'l_segment11_high',l_segment11_high);
  END IF;

  /* segment 12 */
  IF p_map_t(i).segment12_low IS NOT NULL
     and p_map_t(i).segment12_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment12_low',l_segment12_low);

  ELSIF p_map_t(i).segment12_low IS NULL
     and p_map_t(i).segment12_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment12_high',l_segment12_high);

  ELSIF p_map_t(i).segment12_low IS NOT NULL
     and p_map_t(i).segment12_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment12_low',l_segment12_low);
       dbms_sql.bind_variable(l_cursor,'l_segment12_high',l_segment12_high);
  END IF;

  /* segment 13 */
  IF p_map_t(i).segment13_low IS NOT NULL
     and p_map_t(i).segment13_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment13_low',l_segment13_low);

  ELSIF p_map_t(i).segment13_low IS NULL
     and p_map_t(i).segment13_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment13_high',l_segment13_high);

  ELSIF p_map_t(i).segment13_low IS NOT NULL
     and p_map_t(i).segment13_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment13_low',l_segment13_low);
       dbms_sql.bind_variable(l_cursor,'l_segment13_high',l_segment13_high);
  END IF;

  /* segment 14 */
  IF p_map_t(i).segment14_low IS NOT NULL
     and p_map_t(i).segment14_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment14_low',l_segment14_low);

  ELSIF p_map_t(i).segment14_low IS NULL
     and p_map_t(i).segment14_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment14_high',l_segment14_high);

  ELSIF p_map_t(i).segment14_low IS NOT NULL
     and p_map_t(i).segment14_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment14_low',l_segment14_low);
       dbms_sql.bind_variable(l_cursor,'l_segment14_high',l_segment14_high);
  END IF;

  /* segment 15 */
  IF p_map_t(i).segment15_low IS NOT NULL
     and p_map_t(i).segment15_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment15_low',l_segment15_low);

  ELSIF p_map_t(i).segment15_low IS NULL
     and p_map_t(i).segment15_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment15_high',l_segment15_high);

  ELSIF p_map_t(i).segment15_low IS NOT NULL
     and p_map_t(i).segment15_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment15_low',l_segment15_low);
       dbms_sql.bind_variable(l_cursor,'l_segment15_high',l_segment15_high);
  END IF;

  /* segment 16 */
  IF p_map_t(i).segment16_low IS NOT NULL
     and p_map_t(i).segment16_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment16_low',l_segment16_low);

  ELSIF p_map_t(i).segment16_low IS NULL
     and p_map_t(i).segment16_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment16_high',l_segment16_high);

  ELSIF p_map_t(i).segment16_low IS NOT NULL
     and p_map_t(i).segment16_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment16_low',l_segment16_low);
       dbms_sql.bind_variable(l_cursor,'l_segment16_high',l_segment16_high);
  END IF;

  /* segment 17 */
  IF p_map_t(i).segment17_low IS NOT NULL
     and p_map_t(i).segment17_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment17_low',l_segment17_low);

  ELSIF p_map_t(i).segment17_low IS NULL
     and p_map_t(i).segment17_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment17_high',l_segment17_high);

  ELSIF p_map_t(i).segment17_low IS NOT NULL
     and p_map_t(i).segment17_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment17_low',l_segment17_low);
       dbms_sql.bind_variable(l_cursor,'l_segment17_high',l_segment17_high);
  END IF;

  /* segment 18 */
  IF p_map_t(i).segment18_low IS NOT NULL
     and p_map_t(i).segment18_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment18_low',l_segment18_low);

  ELSIF p_map_t(i).segment18_low IS NULL
     and p_map_t(i).segment18_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment18_high',l_segment18_high);

  ELSIF p_map_t(i).segment18_low IS NOT NULL
     and p_map_t(i).segment18_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment18_low',l_segment18_low);
       dbms_sql.bind_variable(l_cursor,'l_segment18_high',l_segment18_high);
  END IF;

  /* segment 19 */
  IF p_map_t(i).segment19_low IS NOT NULL
     and p_map_t(i).segment19_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment19_low',l_segment19_low);

  ELSIF p_map_t(i).segment19_low IS NULL
     and p_map_t(i).segment19_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment19_high',l_segment19_high);

  ELSIF p_map_t(i).segment19_low IS NOT NULL
     and p_map_t(i).segment19_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment19_low',l_segment19_low);
       dbms_sql.bind_variable(l_cursor,'l_segment19_high',l_segment19_high);
  END IF;

  /* segment 20 */
  IF p_map_t(i).segment20_low IS NOT NULL
     and p_map_t(i).segment20_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment20_low',l_segment20_low);

  ELSIF p_map_t(i).segment20_low IS NULL
     and p_map_t(i).segment20_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment20_high',l_segment20_high);

  ELSIF p_map_t(i).segment20_low IS NOT NULL
     and p_map_t(i).segment20_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment20_low',l_segment20_low);
       dbms_sql.bind_variable(l_cursor,'l_segment20_high',l_segment20_high);
  END IF;

  /* segment 21 */
  IF p_map_t(i).segment21_low IS NOT NULL
     and p_map_t(i).segment21_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment21_low',l_segment21_low);

  ELSIF p_map_t(i).segment21_low IS NULL
     and p_map_t(i).segment21_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment21_high',l_segment21_high);

  ELSIF p_map_t(i).segment21_low IS NOT NULL
     and p_map_t(i).segment21_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment21_low',l_segment21_low);
       dbms_sql.bind_variable(l_cursor,'l_segment21_high',l_segment21_high);
  END IF;

  /* segment 22 */
  IF p_map_t(i).segment22_low IS NOT NULL
     and p_map_t(i).segment22_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment22_low',l_segment22_low);

  ELSIF p_map_t(i).segment22_low IS NULL
     and p_map_t(i).segment22_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment22_high',l_segment22_high);

  ELSIF p_map_t(i).segment22_low IS NOT NULL
     and p_map_t(i).segment22_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment22_low',l_segment22_low);
       dbms_sql.bind_variable(l_cursor,'l_segment22_high',l_segment22_high);
  END IF;

  /* segment 23 */
  IF p_map_t(i).segment23_low IS NOT NULL
     and p_map_t(i).segment23_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment23_low',l_segment23_low);

  ELSIF p_map_t(i).segment23_low IS NULL
     and p_map_t(i).segment23_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment23_high',l_segment23_high);

  ELSIF p_map_t(i).segment23_low IS NOT NULL
     and p_map_t(i).segment23_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment23_low',l_segment23_low);
       dbms_sql.bind_variable(l_cursor,'l_segment23_high',l_segment23_high);
  END IF;

  /* segment 24 */
  IF p_map_t(i).segment24_low IS NOT NULL
     and p_map_t(i).segment24_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment24_low',l_segment24_low);

  ELSIF p_map_t(i).segment24_low IS NULL
     and p_map_t(i).segment24_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment24_high',l_segment24_high);

  ELSIF p_map_t(i).segment24_low IS NOT NULL
     and p_map_t(i).segment24_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment24_low',l_segment24_low);
       dbms_sql.bind_variable(l_cursor,'l_segment24_high',l_segment24_high);
  END IF;

  /* segment 25 */
  IF p_map_t(i).segment25_low IS NOT NULL
     and p_map_t(i).segment25_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment25_low',l_segment25_low);

  ELSIF p_map_t(i).segment25_low IS NULL
     and p_map_t(i).segment25_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment25_high',l_segment25_high);

  ELSIF p_map_t(i).segment25_low IS NOT NULL
     and p_map_t(i).segment25_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment25_low',l_segment25_low);
       dbms_sql.bind_variable(l_cursor,'l_segment25_high',l_segment25_high);
  END IF;

  /* segment 26 */
  IF p_map_t(i).segment26_low IS NOT NULL
     and p_map_t(i).segment26_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment26_low',l_segment26_low);

  ELSIF p_map_t(i).segment26_low IS NULL
     and p_map_t(i).segment26_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment26_high',l_segment26_high);

  ELSIF p_map_t(i).segment26_low IS NOT NULL
     and p_map_t(i).segment26_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment26_low',l_segment26_low);
       dbms_sql.bind_variable(l_cursor,'l_segment26_high',l_segment26_high);
  END IF;

  /* segment 27 */
  IF p_map_t(i).segment27_low IS NOT NULL
     and p_map_t(i).segment27_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment27_low',l_segment27_low);

  ELSIF p_map_t(i).segment27_low IS NULL
     and p_map_t(i).segment27_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment27_high',l_segment27_high);

  ELSIF p_map_t(i).segment27_low IS NOT NULL
     and p_map_t(i).segment27_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment27_low',l_segment27_low);
       dbms_sql.bind_variable(l_cursor,'l_segment27_high',l_segment27_high);
  END IF;

  /* segment 28 */
  IF p_map_t(i).segment28_low IS NOT NULL
     and p_map_t(i).segment28_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment28_low',l_segment28_low);

  ELSIF p_map_t(i).segment28_low IS NULL
     and p_map_t(i).segment28_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment28_high',l_segment28_high);

  ELSIF p_map_t(i).segment28_low IS NOT NULL
     and p_map_t(i).segment28_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment28_low',l_segment28_low);
       dbms_sql.bind_variable(l_cursor,'l_segment28_high',l_segment28_high);
  END IF;

  /* segment 29 */
  IF p_map_t(i).segment29_low IS NOT NULL
     and p_map_t(i).segment29_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment29_low',l_segment29_low);

  ELSIF p_map_t(i).segment29_low IS NULL
     and p_map_t(i).segment29_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment29_high',l_segment29_high);

  ELSIF p_map_t(i).segment29_low IS NOT NULL
     and p_map_t(i).segment29_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment29_low',l_segment29_low);
       dbms_sql.bind_variable(l_cursor,'l_segment29_high',l_segment29_high);
  END IF;

  /* segment 30 */
  IF p_map_t(i).segment30_low IS NOT NULL
     and p_map_t(i).segment30_high IS NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment30_low',l_segment30_low);

  ELSIF p_map_t(i).segment30_low IS NULL
     and p_map_t(i).segment30_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment30_high',l_segment30_high);

  ELSIF p_map_t(i).segment30_low IS NOT NULL
     and p_map_t(i).segment30_high IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_segment30_low',l_segment30_low);
       dbms_sql.bind_variable(l_cursor,'l_segment30_high',l_segment30_high);
  END IF;

  dbms_sql.define_column (l_cursor,1,l_ccid_temp);
  l_rows   := dbms_sql.execute(l_cursor);

  l_info := 'populating the CCID pl/sql table';

  LOOP

    l_count := dbms_sql.fetch_rows( l_cursor );
    EXIT WHEN l_count <> 1;
    dbms_sql.column_value(l_cursor,1,l_ccid_temp);

    l_ccid_tbl_count := l_ccid_tbl_count + 1;

    p_ccid_t(l_ccid_tbl_count).map_row := i;
    p_ccid_t(l_ccid_tbl_count).map_id := p_map_t(i).loc_acc_map_id;
    p_ccid_t(l_ccid_tbl_count).ccid := l_ccid_temp;
    p_ccid_t(l_ccid_tbl_count).act_amount := 0;
    p_ccid_t(l_ccid_tbl_count).bud_amount := 0;

  END LOOP;

  IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
  END IF;




END LOOP;

Put_Log('Number of rows in CCID pl/sql table: '||to_char(l_ccid_tbl_count));

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.get_ccids (-)');

EXCEPTION
  WHEN OTHERS THEN
    Put_Log('Error while '|| l_info);
    Raise;

END get_ccids;

/*===========================================================================+
 | PROCEDURE
 |   get_amounts
 |
 | DESCRIPTION
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |   10-JUL-03 Kiran     o created
 +===========================================================================*/

PROCEDURE get_amounts(p_sob_id      IN NUMBER,
                      p_actual_flag IN VARCHAR2,
                      p_budget_name IN VARCHAR2,
                      p_map_t       IN loc_acc_map_tbl,
                      p_ccid_t      IN OUT NOCOPY ccid_tbl)
IS

l_info VARCHAR2(240);

/* cursor for currency code */
CURSOR curr_code(sob_id NUMBER) IS
  select gl_sob.currency_code as CURRENCY_CODE
  from   gl_sets_of_books gl_sob
  where  gl_sob.set_of_books_id = sob_id;

l_currency_code VARCHAR2(15) := 'USD';

/* cursor for budget ID */
CURSOR budget(name VARCHAR2, sob_id NUMBER) IS
  select gbv.budget_version_id
  from   gl_budgets gb,
         gl_budget_versions gbv
  where  gb.ledger_id = sob_id
  and    gb.budget_name = name
  and    gbv.budget_name = gb.budget_name
  order by gb.current_version_id;

l_budget_version_id NUMBER;

/* cursor for actual */
CURSOR act_amt (ccid     NUMBER,
                sob_id   NUMBER,
                currency VARCHAR2,
                start_dt DATE,
                end_dt   DATE) IS
  Select sum(nvl(gb.period_net_dr,0) - nvl(gb.period_net_cr,0))
  From   gl_balances gb
  Where  gb.code_combination_id = ccid
  And    gb.ledger_id     = sob_id
  And    gb.currency_code = currency
  And    gb.actual_flag = 'A'
  And    gb.template_id IS NULL
  And    gb.period_name IN
         (Select gps.period_name
          From   gl_period_statuses gps
          Where  application_id = 101
          And    ledger_id = sob_id
          And    gps.start_date >= start_dt
          And    gps.end_date   <= end_dt);

/* cursor for budgeted */
CURSOR bud_amt (ccid     NUMBER,
                sob_id   NUMBER,
                currency VARCHAR2,
                bud_id   NUMBER,
                start_dt DATE,
                end_dt   DATE) IS
  Select sum(nvl(gb.period_net_dr,0) - nvl(gb.period_net_cr,0))
  From   gl_balances gb
  Where  code_combination_id = ccid
  And    ledger_id     = sob_id
  And    currency_code = currency
  And    actual_flag = 'B'
  And    budget_version_id = bud_id
  And    template_id IS NULL
  And    period_name IN
         (Select gps.period_name
          From   gl_period_statuses gps
          Where  application_id = 101
          And    ledger_id = sob_id
          And    gps.start_date >= start_dt
          And    gps.end_date   <= end_dt);

BEGIN

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.get_amount (+)');

l_info := 'getting the currency code';

OPEN curr_code(p_sob_id);
  FETCH curr_code INTO l_currency_code;
CLOSE curr_code;

IF p_actual_flag = 'A' THEN

  l_info := 'getting the actual amounts';

  FOR i IN 1..p_ccid_t.COUNT LOOP

    Put_Log('loop: '||to_char(i)||
            '  CCID: '||to_char(p_ccid_t(i).ccid)||
            '  SOB: '||to_char(p_sob_id)||
            '  CURRENY: '||l_currency_code||
            '  FROM DT: '||to_char(p_map_t(p_ccid_t(i).map_row).effective_from_date)||
            '  TO DT: '||to_char(p_map_t(p_ccid_t(i).map_row).effective_to_date));

    OPEN act_amt(p_ccid_t(i).ccid,
                 p_sob_id,
                 l_currency_code,
                 p_map_t(p_ccid_t(i).map_row).effective_from_date,
                 p_map_t(p_ccid_t(i).map_row).effective_to_date);
      FETCH act_amt INTO p_ccid_t(i).act_amount;
      p_ccid_t(i).bud_amount := 0;
      Put_Log('Amount'||to_char(i)||': '||to_char(p_ccid_t(i).act_amount));
    CLOSE act_amt;

  END LOOP;

ELSIF p_actual_flag = 'B' THEN

  l_info := 'getting the budget version ID';
  OPEN budget(p_budget_name , p_sob_id);
  LOOP
    FETCH budget INTO l_budget_version_id;
    EXIT when budget%NOTFOUND;
  END LOOP;
  CLOSE budget;

  l_info := 'getting the budget amounts';

  FOR i IN 1..p_ccid_t.COUNT LOOP

    Put_Log('loop: '||to_char(i)||
            '  CCID: '||to_char(p_ccid_t(i).ccid)||
            '  SOB: '||to_char(p_sob_id)||
            '  CURRENY: '||l_currency_code||
            '  BUDGET: '||to_char(l_budget_version_id)||
            '  FROM DT: '||to_char(p_map_t(p_ccid_t(i).map_row).effective_from_date)||
            '  TO DT: '||to_char(p_map_t(p_ccid_t(i).map_row).effective_to_date));

    OPEN bud_amt(p_ccid_t(i).ccid,
                 p_sob_id,
                 l_currency_code,
                 l_budget_version_id,
                 p_map_t(p_ccid_t(i).map_row).effective_from_date,
                 p_map_t(p_ccid_t(i).map_row).effective_to_date);
      FETCH bud_amt INTO p_ccid_t(i).bud_amount;
      p_ccid_t(i).act_amount := 0;
      Put_Log('Amount'||to_char(i)||': '||to_char(p_ccid_t(i).bud_amount));
    CLOSE bud_amt;

  END LOOP;

END IF;

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.get_amount (-)');

EXCEPTION
  WHEN OTHERS THEN
    Put_Log('Error while '|| l_info);
    Raise;

END get_amounts;

/*===========================================================================+
 | PROCEDURE
 |   populate_rec_exp_interface
 |
 | DESCRIPTION
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |   10-JUL-03 Kiran     o created
 +===========================================================================*/

PROCEDURE populate_rec_exp_itf(p_sob_id      IN NUMBER,
                               p_from_date   IN DATE,
                               p_to_date     IN DATE,
                               p_map_t       IN loc_acc_map_tbl,
                               p_ccid_t      IN ccid_tbl)
IS

l_info       VARCHAR2(240);
l_insert_ctr NUMBER := 0;

/* cursor for currency code */
CURSOR curr_code(sob_id NUMBER) IS
  select gl_sob.currency_code as CURRENCY_CODE
  from   gl_sets_of_books gl_sob
  where  gl_sob.set_of_books_id = sob_id;

l_currency_code VARCHAR2(15) := 'USD';

BEGIN

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.populate_rec_exp_itf (+)');

Put_Log('SOB: '||to_char(p_sob_id)||' FRM DT: '||p_from_date||' TO DT: '||p_to_date);

l_info := 'fetching currency code';

OPEN curr_code(p_sob_id);
  FETCH curr_code INTO l_currency_code;
CLOSE curr_code;

FOR i IN 1..p_ccid_t.COUNT LOOP

  l_info := 'inserting into pn_rec_exp_itf table for CCID: '||to_char(p_ccid_t(i).ccid);

  insert into pn_rec_exp_itf
  (
    EXPENSE_LINE_DTL_ID,
    PROPERTY_ID,
    LOCATION_ID,
    EXPENSE_TYPE_CODE,
    EXPENSE_ACCOUNT_ID,
    ACCOUNT_DESCRIPTION,
    ACTUAL_AMOUNT,
    BUDGETED_AMOUNT,
    CURRENCY_CODE,
    FROM_DATE,
    TO_DATE,
    TRANSFER_FLAG,
    MODE_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ORG_ID
  )
  values
  (
    null,
    p_map_t(p_ccid_t(i).map_row).PROPERTY_ID,
    p_map_t(p_ccid_t(i).map_row).LOCATION_ID,
    p_map_t(p_ccid_t(i).map_row).EXPENSE_TYPE_CODE,
    p_ccid_t(i).CCID,
    null,
    nvl(p_ccid_t(i).ACT_AMOUNT,0),
    nvl(p_ccid_t(i).BUD_AMOUNT,0),
    l_currency_code,
    P_FROM_DATE,
    P_TO_DATE,
    'N',
    null,
    SYSDATE,
    nvl(fnd_profile.value('USER_ID'),-1),
    SYSDATE,
    nvl(fnd_profile.value('USER_ID'),-1),
    nvl(fnd_profile.value('USER_ID'),-1),
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    to_number(pn_mo_cache_utils.get_current_org_id)
  );

  l_insert_ctr := l_insert_ctr + 1;

END LOOP;

Put_Log('Number of records processed: '||to_char(p_ccid_t.COUNT));
Put_Log('Number of records inserted: '||to_char(l_insert_ctr));

--commit;

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.populate_rec_exp_itf (-)');

EXCEPTION
  WHEN OTHERS THEN
    Put_Log('Error while '|| l_info);
    Raise;

END populate_rec_exp_itf;

/*------------------------- PUBLIC PROCEDURES -----------------------------*/

/*===========================================================================+
 | PROCEDURE
 |   extract_expense_from_gl
 |
 | DESCRIPTION
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |   10-JUL-03 Kiran     o created
 +===========================================================================*/

PROCEDURE extract_expense_from_gl(
       errbuf                    OUT NOCOPY VARCHAR2,
       retcode                   OUT NOCOPY VARCHAR2,
       p_loc_acc_map_hdr_id      IN VARCHAR2,
       p_location_id             IN VARCHAR2,
       p_property_id             IN VARCHAR2,
       p_set_of_books_id         IN VARCHAR2,
       p_period_start            IN gl_period_statuses.period_name%TYPE,
       p_period_end              IN gl_period_statuses.period_name%TYPE,
       p_balance_type_code       IN gl_lookups.lookup_code%TYPE,
       p_balance_type_code_hide  IN gl_lookups.lookup_code%TYPE DEFAULT NULL,
       p_budget_name             IN gl_budgets.budget_name%TYPE,
       p_populate_rec            IN VARCHAR2,
       p_populate_rec_hide       IN VARCHAR2,
       p_as_of_date              IN VARCHAR2,
       p_period_start_date       IN VARCHAR2,
       p_period_end_date         IN VARCHAR2,
       p_populate_expcl_dtl      IN VARCHAR2,
       p_populate_arcl_dtl       IN VARCHAR2,
       p_override                IN VARCHAR2,
       p_rec_exp_num             IN VARCHAR2)
IS

/* exceptions */
BAD_INPUT_EXCEPTION EXCEPTION;

/* interface pl/sql table */
recovery_itf_tbl rec_exp_itf_tbl;

/* mapping pl/sql table */
map_tbl loc_acc_map_tbl;

/* period from to date tbl */
period_from_to_date_tbl periods_tbl;

/* ccid table - has fk to map table */
code_combinations_tbl ccid_tbl;

/* CURSORS FOR PERIODS */
/* period dates by period name */
CURSOR period_dates_by_period_cur(period VARCHAR2) IS
   Select g.period_name,
          g.start_date,
          g.end_date
   From   gl_period_statuses g,
          gl_sets_of_books   b
   Where  g.application_id  = 101
   And    g.ledger_id       = p_set_of_books_id
   And    b.set_of_books_id = g.ledger_id
   And    g.period_type     = b.accounted_period_type
   And    g.period_name     = period;

/* periods for start-end dates */
CURSOR period_dates_by_dates_cur(start_dt DATE, end_dt DATE) IS
   Select g.period_name,
          g.start_date,
          g.end_date
   From   gl_period_statuses g,
          gl_sets_of_books   b
   Where  g.application_id  = 101
   And    g.ledger_id       = p_set_of_books_id
   And    b.set_of_books_id = g.set_of_books_id
   And    g.period_type     = b.accounted_period_type
   And    g.start_date     >= start_dt
   And    g.end_date       <= end_dt
   Order by g.start_date;

/* period start end dates etc */
l_period_count       NUMBER;
l_period_name_st     VARCHAR2(15);
l_period_start_stdt  DATE;
l_period_start_enddt DATE;
l_period_name_end    VARCHAR2(15);
l_period_end_stdt    DATE;
l_period_end_enddt   DATE;

/* cursors for mapping */

CURSOR mapping IS
   Select map.*
   From   PN_LOC_ACC_MAP_ALL map
   Where  map.LOC_ACC_MAP_HDR_ID = p_loc_acc_map_hdr_id
   And    map.RECOVERABLE_FLAG = 'Y'
   And    map.effective_from_date <= l_period_end_enddt
   And    map.effective_to_date >= l_period_start_stdt;

CURSOR mapping_loc IS
   Select map.*
   From   PN_LOC_ACC_MAP_ALL map
   Where  map.LOC_ACC_MAP_HDR_ID = p_loc_acc_map_hdr_id
   And    map.LOCATION_ID = p_location_id
   And    map.RECOVERABLE_FLAG = 'Y'
   And    map.effective_from_date <= l_period_end_enddt
   And    map.effective_to_date >= l_period_start_stdt;

CURSOR mapping_prop IS
   Select map.*
   From   PN_LOC_ACC_MAP_ALL map
   Where  map.LOC_ACC_MAP_HDR_ID = p_loc_acc_map_hdr_id
   And    map.PROPERTY_ID = p_property_id
   And    map.RECOVERABLE_FLAG = 'Y'
   And    map.effective_from_date <= l_period_end_enddt
   And    map.effective_to_date >= l_period_start_stdt;

CURSOR mapping_loc_prop IS
   Select map.*
   From   PN_LOC_ACC_MAP_ALL map
   Where  map.LOC_ACC_MAP_HDR_ID = p_loc_acc_map_hdr_id
   And    map.PROPERTY_ID = p_property_id
   And    map.LOCATION_ID = p_location_id
   And    map.RECOVERABLE_FLAG = 'Y'
   And    map.effective_from_date <= l_period_end_enddt
   And    map.effective_to_date >= l_period_start_stdt;

/* variables for mapping operations */
l_map_count  NUMBER;

/* variables for logging */
l_info              VARCHAR2(240);
l_counter           BINARY_INTEGER := 0;

/* variables for dates for calling export to Rec pgm */
l_as_of_date        DATE := fnd_date.canonical_to_date(p_as_of_date);
l_period_start_date DATE := fnd_date.canonical_to_date(p_period_start_date);
l_period_end_date   DATE := fnd_date.canonical_to_date(p_period_end_date);

/* cursor for currency code */
CURSOR curr_code(sob_id NUMBER) IS
  select gl_sob.currency_code as CURRENCY_CODE
  from   gl_sets_of_books gl_sob
  where  gl_sob.set_of_books_id = sob_id;

l_currency_code VARCHAR2(15) := 'USD';

/* cursor for property code */
CURSOR prop_code(prop_id NUMBER) IS
  select prop.PROPERTY_CODE
  from   PN_PROPERTIES_ALL prop
  where  prop.property_id = prop_id;

l_property_code VARCHAR2(90);

/* cursor for location code */
CURSOR loc_code(loc_id NUMBER) IS
  select loc.LOCATION_CODE
  from   pn_locations_ALL loc
  where  loc.LOCATION_ID = loc_id;

l_location_code VARCHAR2(90);

BEGIN

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.extract_expense_from_gl (+)');

/* --- Log all the parameters passed in --- */

l_info := 'logging all input params';

Put_Log('Location to account mapping ID: '||p_loc_acc_map_hdr_id);
Put_Log('Location ID: '||p_location_id);
Put_Log('Property ID: '||p_property_id);
Put_Log('Set of books ID: '||p_set_of_books_id);
Put_Log('Period Start: '||p_period_start);
Put_Log('Period End: '||p_period_end);
Put_Log('Balance type code: '||p_balance_type_code);
Put_Log('Balance type code hidden: '||p_balance_type_code_hide);
Put_Log('Budget Name: '||p_budget_name);
Put_Log('Populate recoveries: '||p_populate_rec);
Put_Log('Populate recoveries hidden: '||p_populate_rec_hide);
Put_Log('As of date: '||p_as_of_date);
Put_Log('Period start date: '||p_period_start_date);
Put_Log('Period end date: '||p_period_end_date);
Put_Log('Populate expense class details: '||p_populate_expcl_dtl);
Put_Log('Populate area class details: '||p_populate_arcl_dtl);
Put_Log('Keep overrides: '||p_override);
Put_Log('Recovery Expense Number: '||p_rec_exp_num);

/* --- Bug#3112803 perform input validation in case of   ---
   --- Populate Recoveries is set to 'YES'               ---
   --- Only minmum validation is done here to make sure  ---
   --- that we dont pull in data from GL_BALANCES even if---
   --- minimal inputs are not present. The Expense       ---
   --- Extraction program will do a detailed validation  --- */
IF p_populate_rec = 'Y' THEN

  IF p_property_id IS NULL
    AND p_location_id IS NULL THEN

    fnd_message.set_name('PN','PN_LOC_PROP_REQ');
    RAISE BAD_INPUT_EXCEPTION;

  ELSIF p_rec_exp_num IS NULL AND
    pn_mo_cache_utils.get_profile_value
                      ( 'PN_AUTOMATIC_REC_EXPENSE_NUM'
                       , TO_NUMBER(pn_mo_cache_utils.get_current_org_id)) = 'N' THEN

    fnd_message.set_name('PN','PN_REC_EXP_NUM_REQ');
    RAISE BAD_INPUT_EXCEPTION;

  END IF;

END IF;

/* --- first get the start and end dates for the periods --- */
l_info := 'getting start and end dates for period from - to';

OPEN period_dates_by_period_cur(p_period_start);
  FETCH period_dates_by_period_cur
  INTO l_period_name_st, l_period_start_stdt, l_period_start_enddt;
CLOSE period_dates_by_period_cur;

OPEN period_dates_by_period_cur(p_period_end);
  FETCH period_dates_by_period_cur
  INTO  l_period_name_end, l_period_end_stdt, l_period_end_enddt;
CLOSE period_dates_by_period_cur;

/* --- get all the periods between period from - to --- */
l_info := 'getting all period name, dates for period from - to';

l_counter := 0;
FOR periods in period_dates_by_dates_cur
               (l_period_start_stdt,
                l_period_end_enddt) LOOP

  l_counter := l_counter + 1;

  period_from_to_date_tbl(l_counter).period_name := periods.period_name;
  period_from_to_date_tbl(l_counter).start_date  := periods.start_date;
  period_from_to_date_tbl(l_counter).end_date    := periods.end_date;

END LOOP;

l_period_count := period_from_to_date_tbl.COUNT;
Put_Log('Number of Perods fetched: '||to_char(l_period_count));

/* --- open the appropriate cursor for mapping based on ---
   --- if the mapping name/location/property is entered --- */
l_info := 'populating the mapping pl/sql table';

map_tbl.delete; /* reset the table */
l_counter := 0; /* reset the counter */

if (p_location_id IS NULL and p_property_id IS NULL) then

  /*OPEN mapping;
  FETCH mapping BULK COLLECT INTO map_tbl;
  CLOSE mapping;*/

  FOR map in mapping LOOP

    l_counter := l_counter + 1;

    map_tbl(l_counter).LOC_ACC_MAP_ID := map.LOC_ACC_MAP_ID;
    map_tbl(l_counter).LOC_ACC_MAP_HDR_ID := map.LOC_ACC_MAP_HDR_ID;
    map_tbl(l_counter).PROPERTY_ID := map.PROPERTY_ID;
    map_tbl(l_counter).LOCATION_ID := map.LOCATION_ID;
    map_tbl(l_counter).ACCOUNT_LOW := map.ACCOUNT_LOW;
    map_tbl(l_counter).ACCOUNT_HIGH := map.ACCOUNT_HIGH;
    map_tbl(l_counter).EXPENSE_TYPE_CODE := map.EXPENSE_TYPE_CODE;
    map_tbl(l_counter).EFFECTIVE_FROM_DATE := map.EFFECTIVE_FROM_DATE;
    map_tbl(l_counter).EFFECTIVE_TO_DATE := map.EFFECTIVE_TO_DATE;
    map_tbl(l_counter).RECOVERABLE_FLAG := map.RECOVERABLE_FLAG;
    map_tbl(l_counter).SEGMENT1_LOW  := map.SEGMENT1_LOW;
    map_tbl(l_counter).SEGMENT1_HIGH := map.SEGMENT1_HIGH;
    map_tbl(l_counter).SEGMENT2_LOW  := map.SEGMENT2_LOW;
    map_tbl(l_counter).SEGMENT2_HIGH := map.SEGMENT2_HIGH;
    map_tbl(l_counter).SEGMENT3_LOW  := map.SEGMENT3_LOW;
    map_tbl(l_counter).SEGMENT3_HIGH := map.SEGMENT3_HIGH;
    map_tbl(l_counter).SEGMENT4_LOW  := map.SEGMENT4_LOW;
    map_tbl(l_counter).SEGMENT4_HIGH := map.SEGMENT4_HIGH;
    map_tbl(l_counter).SEGMENT5_LOW  := map.SEGMENT5_LOW;
    map_tbl(l_counter).SEGMENT5_HIGH := map.SEGMENT5_HIGH;
    map_tbl(l_counter).SEGMENT6_LOW  := map.SEGMENT6_LOW;
    map_tbl(l_counter).SEGMENT6_HIGH := map.SEGMENT6_HIGH;
    map_tbl(l_counter).SEGMENT7_LOW  := map.SEGMENT7_LOW;
    map_tbl(l_counter).SEGMENT7_HIGH := map.SEGMENT7_HIGH;
    map_tbl(l_counter).SEGMENT8_LOW  := map.SEGMENT8_LOW;
    map_tbl(l_counter).SEGMENT8_HIGH := map.SEGMENT8_HIGH;
    map_tbl(l_counter).SEGMENT9_LOW  := map.SEGMENT9_LOW;
    map_tbl(l_counter).SEGMENT9_HIGH := map.SEGMENT9_HIGH;
    map_tbl(l_counter).SEGMENT10_LOW  := map.SEGMENT10_LOW;
    map_tbl(l_counter).SEGMENT10_HIGH := map.SEGMENT10_HIGH;
    map_tbl(l_counter).SEGMENT11_LOW  := map.SEGMENT11_LOW;
    map_tbl(l_counter).SEGMENT11_HIGH := map.SEGMENT11_HIGH;
    map_tbl(l_counter).SEGMENT12_LOW  := map.SEGMENT12_LOW;
    map_tbl(l_counter).SEGMENT12_HIGH := map.SEGMENT12_HIGH;
    map_tbl(l_counter).SEGMENT13_LOW  := map.SEGMENT13_LOW;
    map_tbl(l_counter).SEGMENT13_HIGH := map.SEGMENT13_HIGH;
    map_tbl(l_counter).SEGMENT14_LOW  := map.SEGMENT14_LOW;
    map_tbl(l_counter).SEGMENT14_HIGH := map.SEGMENT14_HIGH;
    map_tbl(l_counter).SEGMENT15_LOW  := map.SEGMENT15_LOW;
    map_tbl(l_counter).SEGMENT15_HIGH := map.SEGMENT15_HIGH;
    map_tbl(l_counter).SEGMENT16_LOW  := map.SEGMENT16_LOW;
    map_tbl(l_counter).SEGMENT16_HIGH := map.SEGMENT16_HIGH;
    map_tbl(l_counter).SEGMENT17_LOW  := map.SEGMENT17_LOW;
    map_tbl(l_counter).SEGMENT17_HIGH := map.SEGMENT17_HIGH;
    map_tbl(l_counter).SEGMENT18_LOW  := map.SEGMENT18_LOW;
    map_tbl(l_counter).SEGMENT18_HIGH := map.SEGMENT18_HIGH;
    map_tbl(l_counter).SEGMENT19_LOW  := map.SEGMENT19_LOW;
    map_tbl(l_counter).SEGMENT19_HIGH := map.SEGMENT19_HIGH;
    map_tbl(l_counter).SEGMENT20_LOW  := map.SEGMENT20_LOW;
    map_tbl(l_counter).SEGMENT20_HIGH := map.SEGMENT20_HIGH;
    map_tbl(l_counter).SEGMENT21_LOW  := map.SEGMENT21_LOW;
    map_tbl(l_counter).SEGMENT21_HIGH := map.SEGMENT21_HIGH;
    map_tbl(l_counter).SEGMENT22_LOW  := map.SEGMENT22_LOW;
    map_tbl(l_counter).SEGMENT22_HIGH := map.SEGMENT22_HIGH;
    map_tbl(l_counter).SEGMENT23_LOW  := map.SEGMENT23_LOW;
    map_tbl(l_counter).SEGMENT23_HIGH := map.SEGMENT23_HIGH;
    map_tbl(l_counter).SEGMENT24_LOW  := map.SEGMENT24_LOW;
    map_tbl(l_counter).SEGMENT24_HIGH := map.SEGMENT24_HIGH;
    map_tbl(l_counter).SEGMENT25_LOW  := map.SEGMENT25_LOW;
    map_tbl(l_counter).SEGMENT25_HIGH := map.SEGMENT25_HIGH;
    map_tbl(l_counter).SEGMENT26_LOW  := map.SEGMENT26_LOW;
    map_tbl(l_counter).SEGMENT26_HIGH := map.SEGMENT26_HIGH;
    map_tbl(l_counter).SEGMENT27_LOW  := map.SEGMENT27_LOW;
    map_tbl(l_counter).SEGMENT27_HIGH := map.SEGMENT27_HIGH;
    map_tbl(l_counter).SEGMENT28_LOW  := map.SEGMENT28_LOW;
    map_tbl(l_counter).SEGMENT28_HIGH := map.SEGMENT28_HIGH;
    map_tbl(l_counter).SEGMENT29_LOW  := map.SEGMENT29_LOW;
    map_tbl(l_counter).SEGMENT29_HIGH := map.SEGMENT29_HIGH;
    map_tbl(l_counter).SEGMENT30_LOW  := map.SEGMENT30_LOW;
    map_tbl(l_counter).SEGMENT30_HIGH := map.SEGMENT30_HIGH;

  END LOOP;

elsif (p_location_id IS NOT NULL and p_property_id IS NULL) then

  /*OPEN mapping_loc;
  FETCH mapping_loc BULK COLLECT INTO map_tbl;
  CLOSE mapping_loc;*/

  FOR map in mapping_loc LOOP

    l_counter := l_counter + 1;

    map_tbl(l_counter).LOC_ACC_MAP_ID := map.LOC_ACC_MAP_ID;
    map_tbl(l_counter).LOC_ACC_MAP_HDR_ID := map.LOC_ACC_MAP_HDR_ID;
    map_tbl(l_counter).PROPERTY_ID := map.PROPERTY_ID;
    map_tbl(l_counter).LOCATION_ID := map.LOCATION_ID;
    map_tbl(l_counter).ACCOUNT_LOW := map.ACCOUNT_LOW;
    map_tbl(l_counter).ACCOUNT_HIGH := map.ACCOUNT_HIGH;
    map_tbl(l_counter).EXPENSE_TYPE_CODE := map.EXPENSE_TYPE_CODE;
    map_tbl(l_counter).EFFECTIVE_FROM_DATE := map.EFFECTIVE_FROM_DATE;
    map_tbl(l_counter).EFFECTIVE_TO_DATE := map.EFFECTIVE_TO_DATE;
    map_tbl(l_counter).RECOVERABLE_FLAG := map.RECOVERABLE_FLAG;
    map_tbl(l_counter).SEGMENT1_LOW  := map.SEGMENT1_LOW;
    map_tbl(l_counter).SEGMENT1_HIGH := map.SEGMENT1_HIGH;
    map_tbl(l_counter).SEGMENT2_LOW  := map.SEGMENT2_LOW;
    map_tbl(l_counter).SEGMENT2_HIGH := map.SEGMENT2_HIGH;
    map_tbl(l_counter).SEGMENT3_LOW  := map.SEGMENT3_LOW;
    map_tbl(l_counter).SEGMENT3_HIGH := map.SEGMENT3_HIGH;
    map_tbl(l_counter).SEGMENT4_LOW  := map.SEGMENT4_LOW;
    map_tbl(l_counter).SEGMENT4_HIGH := map.SEGMENT4_HIGH;
    map_tbl(l_counter).SEGMENT5_LOW  := map.SEGMENT5_LOW;
    map_tbl(l_counter).SEGMENT5_HIGH := map.SEGMENT5_HIGH;
    map_tbl(l_counter).SEGMENT6_LOW  := map.SEGMENT6_LOW;
    map_tbl(l_counter).SEGMENT6_HIGH := map.SEGMENT6_HIGH;
    map_tbl(l_counter).SEGMENT7_LOW  := map.SEGMENT7_LOW;
    map_tbl(l_counter).SEGMENT7_HIGH := map.SEGMENT7_HIGH;
    map_tbl(l_counter).SEGMENT8_LOW  := map.SEGMENT8_LOW;
    map_tbl(l_counter).SEGMENT8_HIGH := map.SEGMENT8_HIGH;
    map_tbl(l_counter).SEGMENT9_LOW  := map.SEGMENT9_LOW;
    map_tbl(l_counter).SEGMENT9_HIGH := map.SEGMENT9_HIGH;
    map_tbl(l_counter).SEGMENT10_LOW  := map.SEGMENT10_LOW;
    map_tbl(l_counter).SEGMENT10_HIGH := map.SEGMENT10_HIGH;
    map_tbl(l_counter).SEGMENT11_LOW  := map.SEGMENT11_LOW;
    map_tbl(l_counter).SEGMENT11_HIGH := map.SEGMENT11_HIGH;
    map_tbl(l_counter).SEGMENT12_LOW  := map.SEGMENT12_LOW;
    map_tbl(l_counter).SEGMENT12_HIGH := map.SEGMENT12_HIGH;
    map_tbl(l_counter).SEGMENT13_LOW  := map.SEGMENT13_LOW;
    map_tbl(l_counter).SEGMENT13_HIGH := map.SEGMENT13_HIGH;
    map_tbl(l_counter).SEGMENT14_LOW  := map.SEGMENT14_LOW;
    map_tbl(l_counter).SEGMENT14_HIGH := map.SEGMENT14_HIGH;
    map_tbl(l_counter).SEGMENT15_LOW  := map.SEGMENT15_LOW;
    map_tbl(l_counter).SEGMENT15_HIGH := map.SEGMENT15_HIGH;
    map_tbl(l_counter).SEGMENT16_LOW  := map.SEGMENT16_LOW;
    map_tbl(l_counter).SEGMENT16_HIGH := map.SEGMENT16_HIGH;
    map_tbl(l_counter).SEGMENT17_LOW  := map.SEGMENT17_LOW;
    map_tbl(l_counter).SEGMENT17_HIGH := map.SEGMENT17_HIGH;
    map_tbl(l_counter).SEGMENT18_LOW  := map.SEGMENT18_LOW;
    map_tbl(l_counter).SEGMENT18_HIGH := map.SEGMENT18_HIGH;
    map_tbl(l_counter).SEGMENT19_LOW  := map.SEGMENT19_LOW;
    map_tbl(l_counter).SEGMENT19_HIGH := map.SEGMENT19_HIGH;
    map_tbl(l_counter).SEGMENT20_LOW  := map.SEGMENT20_LOW;
    map_tbl(l_counter).SEGMENT20_HIGH := map.SEGMENT20_HIGH;
    map_tbl(l_counter).SEGMENT21_LOW  := map.SEGMENT21_LOW;
    map_tbl(l_counter).SEGMENT21_HIGH := map.SEGMENT21_HIGH;
    map_tbl(l_counter).SEGMENT22_LOW  := map.SEGMENT22_LOW;
    map_tbl(l_counter).SEGMENT22_HIGH := map.SEGMENT22_HIGH;
    map_tbl(l_counter).SEGMENT23_LOW  := map.SEGMENT23_LOW;
    map_tbl(l_counter).SEGMENT23_HIGH := map.SEGMENT23_HIGH;
    map_tbl(l_counter).SEGMENT24_LOW  := map.SEGMENT24_LOW;
    map_tbl(l_counter).SEGMENT24_HIGH := map.SEGMENT24_HIGH;
    map_tbl(l_counter).SEGMENT25_LOW  := map.SEGMENT25_LOW;
    map_tbl(l_counter).SEGMENT25_HIGH := map.SEGMENT25_HIGH;
    map_tbl(l_counter).SEGMENT26_LOW  := map.SEGMENT26_LOW;
    map_tbl(l_counter).SEGMENT26_HIGH := map.SEGMENT26_HIGH;
    map_tbl(l_counter).SEGMENT27_LOW  := map.SEGMENT27_LOW;
    map_tbl(l_counter).SEGMENT27_HIGH := map.SEGMENT27_HIGH;
    map_tbl(l_counter).SEGMENT28_LOW  := map.SEGMENT28_LOW;
    map_tbl(l_counter).SEGMENT28_HIGH := map.SEGMENT28_HIGH;
    map_tbl(l_counter).SEGMENT29_LOW  := map.SEGMENT29_LOW;
    map_tbl(l_counter).SEGMENT29_HIGH := map.SEGMENT29_HIGH;
    map_tbl(l_counter).SEGMENT30_LOW  := map.SEGMENT30_LOW;
    map_tbl(l_counter).SEGMENT30_HIGH := map.SEGMENT30_HIGH;

  END LOOP;

elsif (p_location_id IS NULL and p_property_id IS NOT NULL) then

  /*OPEN mapping_prop;
  FETCH mapping_prop BULK COLLECT INTO map_tbl;
  CLOSE mapping_prop;*/

  FOR map in mapping_prop LOOP

    l_counter := l_counter + 1;

    map_tbl(l_counter).LOC_ACC_MAP_ID := map.LOC_ACC_MAP_ID;
    map_tbl(l_counter).LOC_ACC_MAP_HDR_ID := map.LOC_ACC_MAP_HDR_ID;
    map_tbl(l_counter).PROPERTY_ID := map.PROPERTY_ID;
    map_tbl(l_counter).LOCATION_ID := map.LOCATION_ID;
    map_tbl(l_counter).ACCOUNT_LOW := map.ACCOUNT_LOW;
    map_tbl(l_counter).ACCOUNT_HIGH := map.ACCOUNT_HIGH;
    map_tbl(l_counter).EXPENSE_TYPE_CODE := map.EXPENSE_TYPE_CODE;
    map_tbl(l_counter).EFFECTIVE_FROM_DATE := map.EFFECTIVE_FROM_DATE;
    map_tbl(l_counter).EFFECTIVE_TO_DATE := map.EFFECTIVE_TO_DATE;
    map_tbl(l_counter).RECOVERABLE_FLAG := map.RECOVERABLE_FLAG;
    map_tbl(l_counter).SEGMENT1_LOW  := map.SEGMENT1_LOW;
    map_tbl(l_counter).SEGMENT1_HIGH := map.SEGMENT1_HIGH;
    map_tbl(l_counter).SEGMENT2_LOW  := map.SEGMENT2_LOW;
    map_tbl(l_counter).SEGMENT2_HIGH := map.SEGMENT2_HIGH;
    map_tbl(l_counter).SEGMENT3_LOW  := map.SEGMENT3_LOW;
    map_tbl(l_counter).SEGMENT3_HIGH := map.SEGMENT3_HIGH;
    map_tbl(l_counter).SEGMENT4_LOW  := map.SEGMENT4_LOW;
    map_tbl(l_counter).SEGMENT4_HIGH := map.SEGMENT4_HIGH;
    map_tbl(l_counter).SEGMENT5_LOW  := map.SEGMENT5_LOW;
    map_tbl(l_counter).SEGMENT5_HIGH := map.SEGMENT5_HIGH;
    map_tbl(l_counter).SEGMENT6_LOW  := map.SEGMENT6_LOW;
    map_tbl(l_counter).SEGMENT6_HIGH := map.SEGMENT6_HIGH;
    map_tbl(l_counter).SEGMENT7_LOW  := map.SEGMENT7_LOW;
    map_tbl(l_counter).SEGMENT7_HIGH := map.SEGMENT7_HIGH;
    map_tbl(l_counter).SEGMENT8_LOW  := map.SEGMENT8_LOW;
    map_tbl(l_counter).SEGMENT8_HIGH := map.SEGMENT8_HIGH;
    map_tbl(l_counter).SEGMENT9_LOW  := map.SEGMENT9_LOW;
    map_tbl(l_counter).SEGMENT9_HIGH := map.SEGMENT9_HIGH;
    map_tbl(l_counter).SEGMENT10_LOW  := map.SEGMENT10_LOW;
    map_tbl(l_counter).SEGMENT10_HIGH := map.SEGMENT10_HIGH;
    map_tbl(l_counter).SEGMENT11_LOW  := map.SEGMENT11_LOW;
    map_tbl(l_counter).SEGMENT11_HIGH := map.SEGMENT11_HIGH;
    map_tbl(l_counter).SEGMENT12_LOW  := map.SEGMENT12_LOW;
    map_tbl(l_counter).SEGMENT12_HIGH := map.SEGMENT12_HIGH;
    map_tbl(l_counter).SEGMENT13_LOW  := map.SEGMENT13_LOW;
    map_tbl(l_counter).SEGMENT13_HIGH := map.SEGMENT13_HIGH;
    map_tbl(l_counter).SEGMENT14_LOW  := map.SEGMENT14_LOW;
    map_tbl(l_counter).SEGMENT14_HIGH := map.SEGMENT14_HIGH;
    map_tbl(l_counter).SEGMENT15_LOW  := map.SEGMENT15_LOW;
    map_tbl(l_counter).SEGMENT15_HIGH := map.SEGMENT15_HIGH;
    map_tbl(l_counter).SEGMENT16_LOW  := map.SEGMENT16_LOW;
    map_tbl(l_counter).SEGMENT16_HIGH := map.SEGMENT16_HIGH;
    map_tbl(l_counter).SEGMENT17_LOW  := map.SEGMENT17_LOW;
    map_tbl(l_counter).SEGMENT17_HIGH := map.SEGMENT17_HIGH;
    map_tbl(l_counter).SEGMENT18_LOW  := map.SEGMENT18_LOW;
    map_tbl(l_counter).SEGMENT18_HIGH := map.SEGMENT18_HIGH;
    map_tbl(l_counter).SEGMENT19_LOW  := map.SEGMENT19_LOW;
    map_tbl(l_counter).SEGMENT19_HIGH := map.SEGMENT19_HIGH;
    map_tbl(l_counter).SEGMENT20_LOW  := map.SEGMENT20_LOW;
    map_tbl(l_counter).SEGMENT20_HIGH := map.SEGMENT20_HIGH;
    map_tbl(l_counter).SEGMENT21_LOW  := map.SEGMENT21_LOW;
    map_tbl(l_counter).SEGMENT21_HIGH := map.SEGMENT21_HIGH;
    map_tbl(l_counter).SEGMENT22_LOW  := map.SEGMENT22_LOW;
    map_tbl(l_counter).SEGMENT22_HIGH := map.SEGMENT22_HIGH;
    map_tbl(l_counter).SEGMENT23_LOW  := map.SEGMENT23_LOW;
    map_tbl(l_counter).SEGMENT23_HIGH := map.SEGMENT23_HIGH;
    map_tbl(l_counter).SEGMENT24_LOW  := map.SEGMENT24_LOW;
    map_tbl(l_counter).SEGMENT24_HIGH := map.SEGMENT24_HIGH;
    map_tbl(l_counter).SEGMENT25_LOW  := map.SEGMENT25_LOW;
    map_tbl(l_counter).SEGMENT25_HIGH := map.SEGMENT25_HIGH;
    map_tbl(l_counter).SEGMENT26_LOW  := map.SEGMENT26_LOW;
    map_tbl(l_counter).SEGMENT26_HIGH := map.SEGMENT26_HIGH;
    map_tbl(l_counter).SEGMENT27_LOW  := map.SEGMENT27_LOW;
    map_tbl(l_counter).SEGMENT27_HIGH := map.SEGMENT27_HIGH;
    map_tbl(l_counter).SEGMENT28_LOW  := map.SEGMENT28_LOW;
    map_tbl(l_counter).SEGMENT28_HIGH := map.SEGMENT28_HIGH;
    map_tbl(l_counter).SEGMENT29_LOW  := map.SEGMENT29_LOW;
    map_tbl(l_counter).SEGMENT29_HIGH := map.SEGMENT29_HIGH;
    map_tbl(l_counter).SEGMENT30_LOW  := map.SEGMENT30_LOW;
    map_tbl(l_counter).SEGMENT30_HIGH := map.SEGMENT30_HIGH;

  END LOOP;

elsif (p_location_id IS NOT NULL and p_property_id IS NOT NULL) then

  /*OPEN mapping_loc_prop;
  FETCH mapping_loc_prop BULK COLLECT INTO map_tbl;
  CLOSE mapping_loc_prop;*/

  FOR map in mapping_loc_prop LOOP

    l_counter := l_counter + 1;

    map_tbl(l_counter).LOC_ACC_MAP_ID := map.LOC_ACC_MAP_ID;
    map_tbl(l_counter).LOC_ACC_MAP_HDR_ID := map.LOC_ACC_MAP_HDR_ID;
    map_tbl(l_counter).PROPERTY_ID := map.PROPERTY_ID;
    map_tbl(l_counter).LOCATION_ID := map.LOCATION_ID;
    map_tbl(l_counter).ACCOUNT_LOW := map.ACCOUNT_LOW;
    map_tbl(l_counter).ACCOUNT_HIGH := map.ACCOUNT_HIGH;
    map_tbl(l_counter).EXPENSE_TYPE_CODE := map.EXPENSE_TYPE_CODE;
    map_tbl(l_counter).EFFECTIVE_FROM_DATE := map.EFFECTIVE_FROM_DATE;
    map_tbl(l_counter).EFFECTIVE_TO_DATE := map.EFFECTIVE_TO_DATE;
    map_tbl(l_counter).RECOVERABLE_FLAG := map.RECOVERABLE_FLAG;
    map_tbl(l_counter).SEGMENT1_LOW  := map.SEGMENT1_LOW;
    map_tbl(l_counter).SEGMENT1_HIGH := map.SEGMENT1_HIGH;
    map_tbl(l_counter).SEGMENT2_LOW  := map.SEGMENT2_LOW;
    map_tbl(l_counter).SEGMENT2_HIGH := map.SEGMENT2_HIGH;
    map_tbl(l_counter).SEGMENT3_LOW  := map.SEGMENT3_LOW;
    map_tbl(l_counter).SEGMENT3_HIGH := map.SEGMENT3_HIGH;
    map_tbl(l_counter).SEGMENT4_LOW  := map.SEGMENT4_LOW;
    map_tbl(l_counter).SEGMENT4_HIGH := map.SEGMENT4_HIGH;
    map_tbl(l_counter).SEGMENT5_LOW  := map.SEGMENT5_LOW;
    map_tbl(l_counter).SEGMENT5_HIGH := map.SEGMENT5_HIGH;
    map_tbl(l_counter).SEGMENT6_LOW  := map.SEGMENT6_LOW;
    map_tbl(l_counter).SEGMENT6_HIGH := map.SEGMENT6_HIGH;
    map_tbl(l_counter).SEGMENT7_LOW  := map.SEGMENT7_LOW;
    map_tbl(l_counter).SEGMENT7_HIGH := map.SEGMENT7_HIGH;
    map_tbl(l_counter).SEGMENT8_LOW  := map.SEGMENT8_LOW;
    map_tbl(l_counter).SEGMENT8_HIGH := map.SEGMENT8_HIGH;
    map_tbl(l_counter).SEGMENT9_LOW  := map.SEGMENT9_LOW;
    map_tbl(l_counter).SEGMENT9_HIGH := map.SEGMENT9_HIGH;
    map_tbl(l_counter).SEGMENT10_LOW  := map.SEGMENT10_LOW;
    map_tbl(l_counter).SEGMENT10_HIGH := map.SEGMENT10_HIGH;
    map_tbl(l_counter).SEGMENT11_LOW  := map.SEGMENT11_LOW;
    map_tbl(l_counter).SEGMENT11_HIGH := map.SEGMENT11_HIGH;
    map_tbl(l_counter).SEGMENT12_LOW  := map.SEGMENT12_LOW;
    map_tbl(l_counter).SEGMENT12_HIGH := map.SEGMENT12_HIGH;
    map_tbl(l_counter).SEGMENT13_LOW  := map.SEGMENT13_LOW;
    map_tbl(l_counter).SEGMENT13_HIGH := map.SEGMENT13_HIGH;
    map_tbl(l_counter).SEGMENT14_LOW  := map.SEGMENT14_LOW;
    map_tbl(l_counter).SEGMENT14_HIGH := map.SEGMENT14_HIGH;
    map_tbl(l_counter).SEGMENT15_LOW  := map.SEGMENT15_LOW;
    map_tbl(l_counter).SEGMENT15_HIGH := map.SEGMENT15_HIGH;
    map_tbl(l_counter).SEGMENT16_LOW  := map.SEGMENT16_LOW;
    map_tbl(l_counter).SEGMENT16_HIGH := map.SEGMENT16_HIGH;
    map_tbl(l_counter).SEGMENT17_LOW  := map.SEGMENT17_LOW;
    map_tbl(l_counter).SEGMENT17_HIGH := map.SEGMENT17_HIGH;
    map_tbl(l_counter).SEGMENT18_LOW  := map.SEGMENT18_LOW;
    map_tbl(l_counter).SEGMENT18_HIGH := map.SEGMENT18_HIGH;
    map_tbl(l_counter).SEGMENT19_LOW  := map.SEGMENT19_LOW;
    map_tbl(l_counter).SEGMENT19_HIGH := map.SEGMENT19_HIGH;
    map_tbl(l_counter).SEGMENT20_LOW  := map.SEGMENT20_LOW;
    map_tbl(l_counter).SEGMENT20_HIGH := map.SEGMENT20_HIGH;
    map_tbl(l_counter).SEGMENT21_LOW  := map.SEGMENT21_LOW;
    map_tbl(l_counter).SEGMENT21_HIGH := map.SEGMENT21_HIGH;
    map_tbl(l_counter).SEGMENT22_LOW  := map.SEGMENT22_LOW;
    map_tbl(l_counter).SEGMENT22_HIGH := map.SEGMENT22_HIGH;
    map_tbl(l_counter).SEGMENT23_LOW  := map.SEGMENT23_LOW;
    map_tbl(l_counter).SEGMENT23_HIGH := map.SEGMENT23_HIGH;
    map_tbl(l_counter).SEGMENT24_LOW  := map.SEGMENT24_LOW;
    map_tbl(l_counter).SEGMENT24_HIGH := map.SEGMENT24_HIGH;
    map_tbl(l_counter).SEGMENT25_LOW  := map.SEGMENT25_LOW;
    map_tbl(l_counter).SEGMENT25_HIGH := map.SEGMENT25_HIGH;
    map_tbl(l_counter).SEGMENT26_LOW  := map.SEGMENT26_LOW;
    map_tbl(l_counter).SEGMENT26_HIGH := map.SEGMENT26_HIGH;
    map_tbl(l_counter).SEGMENT27_LOW  := map.SEGMENT27_LOW;
    map_tbl(l_counter).SEGMENT27_HIGH := map.SEGMENT27_HIGH;
    map_tbl(l_counter).SEGMENT28_LOW  := map.SEGMENT28_LOW;
    map_tbl(l_counter).SEGMENT28_HIGH := map.SEGMENT28_HIGH;
    map_tbl(l_counter).SEGMENT29_LOW  := map.SEGMENT29_LOW;
    map_tbl(l_counter).SEGMENT29_HIGH := map.SEGMENT29_HIGH;
    map_tbl(l_counter).SEGMENT30_LOW  := map.SEGMENT30_LOW;
    map_tbl(l_counter).SEGMENT30_HIGH := map.SEGMENT30_HIGH;

  END LOOP;

end if;

l_map_count := map_tbl.COUNT;
Put_Log('Number of Mapping records fetched: '||to_char(l_map_count));

/* --- verify the dates for all the maps --- */
verify_dates_for_map(p_map_t     => map_tbl,
                     p_periods_t => period_from_to_date_tbl);

/* --- get all CCIDs --- */
code_combinations_tbl.DELETE;
get_ccids(p_sob_id => to_number(p_set_of_books_id),
          p_map_t  => map_tbl,
          p_ccid_t => code_combinations_tbl);

/* --- get all the Balances from GL Balances --- */

get_amounts(p_sob_id => to_number(p_set_of_books_id),
            p_actual_flag => p_balance_type_code,
            p_budget_name => p_budget_name,
            p_map_t       => map_tbl,
            p_ccid_t      => code_combinations_tbl);

/* --- insert data into the ITF table --- */
populate_rec_exp_itf(p_sob_id    => to_number(p_set_of_books_id),
                     p_from_date => l_period_start_date,
                     p_to_date   => l_period_end_date,
                     p_map_t     => map_tbl,
                     p_ccid_t    => code_combinations_tbl);

/* --- call Recovery Module Expense Lines Extract if ---
   --- populate recoveries = YES                     --- */

IF p_populate_rec = 'Y' THEN

  l_info := 'calling Recovery Module Expense Lines Extract';

  OPEN curr_code(to_number(p_set_of_books_id));
    FETCH curr_code INTO l_currency_code;
  CLOSE curr_code;

  IF p_property_id IS NOT NULL THEN
    OPEN prop_code(TO_NUMBER(p_property_id));
      FETCH prop_code INTO l_property_code;
    CLOSE prop_code;
  END IF;

  IF p_location_id IS NOT NULL THEN
    OPEN loc_code(TO_NUMBER(p_location_id));
      FETCH loc_code INTO l_location_code;
    CLOSE loc_code;
  END IF;

  Put_Log('Calling pn_recovery_extract_pkg.extract_line_expense_area with parameters:');
  Put_Log('Location Code: '||l_location_code);
  Put_Log('Property Code: '||l_property_code);
  Put_Log('Currency Code: '||l_currency_code);
  Put_Log('As Of Date: '||p_as_of_date);
  Put_Log('From Date: '||p_period_start_date);
  Put_Log('To Date: '||p_period_end_date);
  Put_Log('Populate Expense Class Details: '||p_populate_expcl_dtl);
  Put_Log('Populate Area Class Details: '||p_populate_arcl_dtl);
  Put_Log('Keep Overrides: '||p_override);
  Put_Log('Extract Code: '||p_rec_exp_num);


  pn_recovery_extract_pkg.extract_line_expense_area
  (
    errbuf               => errbuf,
    retcode              => retcode,
    p_location_code      => l_location_code,
    p_property_code      => l_property_code,
    p_as_of_date         => p_as_of_date,
    p_from_date          => p_period_start_date,
    p_to_date            => p_period_end_date,
    p_currency_code      => l_currency_code,
    p_pop_exp_class_dtl  => p_populate_expcl_dtl,
    p_pop_area_class_dtl => p_populate_arcl_dtl,
    p_keep_override      => p_override,
    p_extract_code       => p_rec_exp_num,
    p_called_from        => 'SRS'
  );

END IF;

Put_Log('PN_REC_EXP_EXTR_FROM_GL_PKG.extract_expense_from_gl (-)');

EXCEPTION
  WHEN BAD_INPUT_EXCEPTION THEN
    Put_Line(fnd_message.get);
    raise;
  WHEN OTHERS THEN
    Put_Log('Error while '||l_info);
    Raise;

END extract_expense_from_gl;

/*===========================================================================+
 | PROCEDURE
 |   Put_Log
 |
 | DESCRIPTION
 |   Writes the String passed as argument to Concurrent Log
 |
 | ARGUMENTS: p_String
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | MODIFICATION HISTORY
 |   Created   Naga Vijayapuram  1999
 |
 |   10-JUL-03 Kiran     o copied from PNVLOSPB
 +===========================================================================*/

Procedure Put_Log(p_String VarChar2) IS

BEGIN

  Fnd_File.Put_Line(Fnd_File.Log,    p_String);

EXCEPTION

  When Others Then Raise;

END Put_Log;


/*===========================================================================+
 | PROCEDURE
 |   Put_Line
 |
 | DESCRIPTION
 |   Writes the String passed as argument to Concurrent Log/Output
 |
 | ARGUMENTS: p_String
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | MODIFICATION HISTORY
 |   Created   Naga Vijayapuram  1999
 |
 |   10-JUL-03 Kiran     o copied from PNVLOSPB
 |
 +===========================================================================*/

Procedure Put_Line(p_String VarChar2) IS

BEGIN

    Fnd_File.Put_Line(Fnd_File.Log,    p_String);
    Fnd_File.Put_Line(Fnd_File.Output, p_String);

EXCEPTION

  When Others Then Raise;

END Put_Line;

END PN_REC_EXP_EXTR_FROM_GL_PKG;

/
