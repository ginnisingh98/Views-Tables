--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_CALCULATE_PKG" AS
--$Header: JACNCCEB.pls 120.1.12010000.3 2009/01/04 06:29:44 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     JACNCCEB.pls
--|
--| DESCRIPTION
--|
--|     This package contains the following PL/SQL tables/procedures/functions
--|     to implement calculation for main part of cash flow statement according
--|     to data that collected by 'Cash Flow Statement - Data Collection'
--|     program and stored in JA_CN_CFS_ACTIVITIES_ALL table, and rules defined
--|     in Cash Flow Statement Assignments form and Calculation window in FSG
--|     Row Set.
--|
--| TYPE LIEST
--|   G_PERIOD_NAME_TBL
--|
--| PROCEDURE LIST
--|   Populate_Period_Names
--|   Populate_Formula
--|   Categorize_Rows
--|   Calculate_Row_Amount
--|   Calculate_Rows_Amount
--|   Generate_Cfs_Xml
--|
--| HISTORY
--|   14-Mar-2006     Donghai Wang Created
--|   29-Aug-2008     Chaoqun Wu  CNAO Enhancement
--|                               Updated procedures Calculate_Row_Amount and Calculate_Rows_Amount
--|                               Added BSV parameter for CFS-Generation
--|   23-Sep-2008     Chaoqun Wu  Fix bug# 7427067
--    14-Oct-2008     Chaoqun Wu  Fix bug# 7481516
--|   16-Dec-2008     Shujuan Yan Fix bug 7626489
--+======================================================================*/

l_module_prefix   VARCHAR2(100):='JA_CN_CFS_CALCULATE_PKG';


--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Period_Names               Public
--
--  DESCRIPTION:
--
--      This procedure is to retrieve period names from gl_periods by the
--      parameter 'p_parameter' and the parameter p_balance_type, alternative
--      value is 'YTD/QTD/PTD'
--
--  PARAMETERS:
--      In:  p_set_of_bks_id     Identifier of GL set of book, a required
--                               parameter for FSG report
--           p_period_name       GL period Name
--           p_balace_type       Type of balance, available value is 'YTD/QTD/PTD'.
--                               a required parameter for FSG report
--
--     Out:  x_period_names      Qualified period names for cash flow statement
--                               calculation
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Populate_Period_Names
(p_ledger_id IN NUMBER
,p_period_name   IN VARCHAR2
,p_balance_type  IN VARCHAR2
,x_period_names  OUT NOCOPY JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
)
IS
l_ledger_id          gl_ledgers.ledger_id%TYPE :=p_ledger_id;
l_period_set_name        gl_periods.period_set_name%TYPE;
l_accounted_period_type  gl_periods.period_type%TYPE;
l_period_name            gl_periods.period_name%TYPE           :=p_period_name;
l_period_year            gl_periods.period_year%TYPE;
l_period_num             gl_periods.period_num%TYPE;
l_quarter_num            gl_periods.quarter_num%TYPE;

CURSOR c_period_set_name
IS
SELECT
  period_set_name
 ,accounted_period_type
FROM
  gl_ledgers
WHERE ledger_id=l_ledger_id;

CURSOR c_period_name_attribute
IS
SELECT
  period_year
 ,period_num
 ,quarter_num
FROM
  gl_periods
WHERE period_set_name=l_period_set_name
  AND period_type=l_accounted_period_type
  AND period_name=l_period_name;

CURSOR c_ytd_period_names
IS
SELECT
  period_name
FROM
  gl_periods
WHERE period_set_name=l_period_set_name
  AND period_type=l_accounted_period_type
  AND period_year=l_period_year
  AND period_num<=l_period_num;

CURSOR c_qtd_period_names
IS
SELECT
  period_name
FROM
  gl_periods
WHERE period_set_name=l_period_set_name
  AND period_type=l_accounted_period_type
  AND period_year=l_period_year
  AND quarter_num=l_quarter_num
  AND period_num<=l_period_num;

l_period_idx            NUMBER;
l_curr_period_name      gl_periods.period_name%TYPE;
l_period_names          JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Populate_Period_Names';


BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_ledger_id '||p_ledger_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_name '||p_period_name
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_balance_type '||p_balance_type
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

  --To Get current period set name per gl set of book
  OPEN c_period_set_name;
  FETCH c_period_set_name INTO l_period_set_name,l_accounted_period_type;
  CLOSE c_period_set_name;

  --To retrive set of period names according to parameters period_name and balance_type

   --Get period attributes for the period passed by the parameter period_name
   OPEN c_period_name_attribute;
   FETCH c_period_name_attribute INTO l_period_year,l_period_num,l_quarter_num;
   CLOSE c_period_name_attribute;

   l_period_idx:=0;

   --If balance type is YTD, then set of periods include all periods
   --from year beginning to period parameter
   IF p_balance_type='YTD'
   THEN

     OPEN c_ytd_period_names;
     FETCH c_ytd_period_names INTO l_curr_period_name;
     WHILE c_ytd_period_names%FOUND
     LOOP
       l_period_idx:=l_period_idx+1;
       l_period_names(l_period_idx):=l_curr_period_name;
       FETCH c_ytd_period_names INTO l_curr_period_name;
     END LOOP;  -- WHILE c_ytd_period_names%FOUND

     CLOSE c_ytd_period_names;

   --If balance type is QTD, then set of periods include all periods from first period of
   --same quarter as that of period parameter to period parameter

   ELSIF p_balance_type='QTD'
   THEN
     OPEN c_qtd_period_names;
     FETCH c_qtd_period_names INTO l_curr_period_name;
     WHILE c_qtd_period_names%FOUND
     LOOP
       l_period_idx:=l_period_idx+1;
       l_period_names(l_period_idx):=l_curr_period_name;
       FETCH c_qtd_period_names INTO l_curr_period_name;
     END LOOP;  --WHILE c_qtd_period_names%FOUND

     CLOSE c_qtd_period_names;

   ELSIF p_balance_type='PTD'
   THEN
     l_period_idx:=l_period_idx+1;
     l_period_names(l_period_idx):=l_period_name;
   END IF;  --p_balance_type='YTD'

   x_period_names:=l_period_names;

  --log for debug
    IF ( l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.end'
                    ,'Exit procedure'
                    );
    END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
END Populate_Period_Names;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Formula               Public
--
--  DESCRIPTION:
--
--      For Cash Flow Statement, user would define calculation rule for items
--      on 'FSG Rowset' form,  one item can be calculated by other items, it
--      can have multiple calculation lines. In one calculation line, user can
--      define a range for rows from low to high, or specify a specific row.
--      Also, rows selected in such calculation rules can be also items that
--      are calculated by other items. Just so, it is hard for calculating
--      directly. The procedure 'Populate_Formula' is used to convert involved
--      calculating items in calculation lines to most detailed items for all
--      calculated items, hereinto, most detailed items mean items that are
--      directly calculated by FSG account assignments or Cash Flow item assignments.
--
--  PARAMETERS:
--      In:  p_axis_set_id        Identifier of FSG Row Set
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--      23-Sep-2008     Chaoqun Wu  Fix bug# 7427067
--
--===========================================================================
PROCEDURE Populate_Formula
(p_coa     IN NUMBER  --Fix bug# 7427067
,p_axis_set_id   IN NUMBER
)
IS
l_coa                   NUMBER := p_coa;
l_axis_set_id           rg_report_axis_sets.axis_set_id%TYPE         :=p_axis_set_id;
l_calculation_seq       NUMBER;
l_application_id        rg_report_axes.application_id%TYPE;
l_axis_seq              rg_report_axes.axis_seq%TYPE;
l_axis_seq_low          rg_report_calculations.axis_seq_low%TYPE;
l_axis_seq_high         rg_report_calculations.axis_seq_high%TYPE;
l_axis_name_low         rg_report_calculations.axis_name_low%TYPE;
l_operator              rg_report_calculations.operator%TYPE;
l_operator_flag         NUMBER;
l_exit_flag             VARCHAR2(1);
l_cal_axis_seq          rg_report_axes.axis_seq%TYPE;
l_constant              rg_report_calculations.constant%TYPE;
l_type                  VARCHAR2(1);
l_display_flag          VARCHAR2(1);
l_display_zero_flag      VARCHAR2(1);
l_change_sign_flag      VARCHAR2(1);
l_calculated_row_count  NUMBER;
l_calculated_axis_seq   rg_report_axes.axis_seq%TYPE;

-----FOR TEST
L_GT_COUNTS             NUMBER:=-1;
l_gt_counts1            NUMBER:=-1;

CURSOR c_report_axis
IS
SELECT
  DISTINCT
  rra.application_id
 ,rra.axis_seq
 ,rra.display_flag
 ,rra.display_zero_amount_flag
 ,rra.change_sign_flag
FROM
  rg_report_axes rra
 ,rg_report_calculations rrc
WHERE rra.axis_set_id=l_axis_set_id
  AND rra.axis_set_id=rrc.axis_set_id
  AND rra.axis_seq=rrc.axis_seq;

CURSOR c_report_calculations
IS
SELECT
  operator
 ,axis_seq_low
 ,axis_seq_high
 ,axis_name_low
 ,constant
FROM
  rg_report_calculations
WHERE application_id=l_application_id
  AND axis_set_id=l_axis_set_id
  AND axis_seq=l_axis_seq
ORDER BY calculation_seq;

CURSOR c_axis_seqs_per_line
IS
SELECT
  rra.axis_seq
FROM
  rg_report_axes rra
WHERE rra.axis_set_id=l_axis_set_id
  AND rra.axis_seq BETWEEN l_axis_seq_low AND l_axis_seq_high
  --Fix bug# 7427067 begin
  AND (EXISTS (SELECT
                 rrac.axis_seq
              FROM
                rg_report_axis_contents rrac
              WHERE rrac.application_id=rra.application_id
                AND rrac.axis_set_id=rra.axis_set_id
                AND rrac.axis_seq=rra.axis_seq
             )
     OR
        EXISTS (SELECT
                  jccaa.axis_seq
               FROM
                 ja_cn_cfs_assignments_all jccaa
               WHERE jccaa.chart_of_accounts_id=l_coa
                 AND rra.axis_set_id=jccaa.axis_set_id
                 AND jccaa.axis_seq=rra.axis_seq
              )
      OR
        EXISTS (SELECT
                  rrc.axis_seq
FROM
                 rg_report_calculations rrc
               WHERE rrc.application_id=rra.application_id
                 AND rra.axis_set_id=rrc.axis_set_id
                 AND rrc.axis_seq=rra.axis_seq
              )
        );
  --Fix bug# 7427067 end


CURSOR c_axis_seq
IS
SELECT
  axis_seq
FROM
  rg_report_axes
WHERE application_id=l_application_id
  AND axis_set_id=l_axis_set_id
  AND axis_name=l_axis_name_low;

CURSOR c_calculation_rows
IS
SELECT
  axis_seq
 ,type
FROM
  ja_cn_cfs_row_cgs_gt
WHERE application_id=l_application_id
  AND axis_set_id=l_axis_set_id
  AND calculation_flag='Y'
ORDER BY axis_seq;

CURSOR c_calculated_rows_count
IS
SELECT
  count(DISTINCT ccg.axis_seq)
FROM
  ja_cn_cfs_row_cgs_gt       crcg
 ,ja_cn_cfs_calculations_gt  ccg
WHERE crcg.application_id=l_application_id
  AND crcg.axis_set_id=l_axis_set_id
  AND (crcg.type IS NULL) OR (crcg.type<>'E')
  AND ccg.application_id=crcg.application_id
  AND ccg.axis_set_id=crcg.axis_set_id
  AND ccg.cal_axis_seq=l_cal_axis_seq;


CURSOR c_calculated_rows
IS
SELECT
  DISTINCT ccg.axis_seq
FROM
  ja_cn_cfs_row_cgs_gt       crcg
 ,ja_cn_cfs_calculations_gt  ccg
WHERE crcg.application_id=l_application_id
  AND crcg.axis_set_id=l_axis_set_id
  AND (crcg.type IS NULL) OR (crcg.type<>'E')
  AND ccg.application_id=crcg.application_id
  AND ccg.axis_set_id=crcg.axis_set_id
  AND ccg.cal_axis_seq=l_cal_axis_seq;

CURSOR c_cfs_calculation_lines
IS
SELECT
  calculation_seq
 ,operator
 ,operator_flag
 ,cal_axis_seq
 ,constant
FROM
  ja_cn_cfs_calculations_gt
WHERE application_id=l_application_id
  AND axis_set_id=l_axis_set_id
  AND axis_seq=l_calculated_axis_seq
  AND cal_axis_seq=l_cal_axis_seq
ORDER BY calculation_seq;

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Populate_Formula';


BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

  --Retrive initial canculation lines from RG_REPORT_CALCULATIONS table for
  --each item in FSG Row Set that have calculation definition,
  --if a calculation line contain sequence number range that perform calculation,
  --then split this calculation line to multiple calculation lines and each line only
  --have one sequence number that perform calcluation, instead of a range.


  --Retrive all rows that have calculation definition for current FSG Row Set
  OPEN c_report_axis;
  FETCH c_report_axis INTO l_application_id,l_axis_seq,l_display_flag,l_display_zero_flag,l_change_sign_flag;
  WHILE c_report_axis%FOUND
  LOOP
    l_calculation_seq:=1;
    l_exit_flag:='N';

    --Retrive calculation lines for current row
    OPEN c_report_calculations;
    FETCH c_report_calculations INTO l_operator,l_axis_seq_low,l_axis_seq_high,l_axis_name_low,l_constant;
    WHILE c_report_calculations%FOUND
    LOOP

      --Calculation for Cash flow statment only supports '+'/'-'/Enter as operator, if operator is '*'/'/'
      --or any other operaters, then program would not perform calcuation for current FSG row and will show
      --an error message in correspondng item of Cash Flow Statement that is ultimately generated
      --by xml publisher

      --If l_operator is not '+'/'-'/'Enter', then doesn't continue checking curent cash flow item
      --and marked calculation for this item as error
      IF l_operator NOT IN ('+','-','ENTER')
      THEN
           l_exit_flag:='Y';
           EXIT;
      ELSE

        --If current calculation line is defined by sequence number range,then
        --Convert the range to multiple single sequence number, so the calculation line
        --would be split to multiple calculation line and inserted into temporary table
        --'JA_CN_CFS_CALCULATION_GBLTEMP

        --Operator 'Enter' has the same function as'+'
         IF l_operator='ENTER'
         THEN
           l_operator:='+';
         END IF;  --l_operator='ENTER'

         --To set operator flag
         IF l_operator='+'
         THEN
           l_operator_flag:=1;
         ELSIF l_operator='-'
         THEN
           l_operator_flag:=-1;
         END IF;--l_operator='+'


         IF  (l_axis_seq_low IS NOT NULL) AND
             (l_axis_seq_high IS NOT NULL)
         THEN

           --Split current line to multiple lines by sequence number range,
           --each line only contain one sequence number

           OPEN c_axis_seqs_per_line;
           FETCH c_axis_seqs_per_line INTO l_cal_axis_seq;
           WHILE c_axis_seqs_per_line%FOUND
           LOOP


             INSERT
             INTO
               ja_cn_cfs_calculations_gt
               (application_id,axis_set_id
               ,axis_seq
               ,calculation_seq
               ,operator
               ,operator_flag
               ,cal_axis_seq
               ,constant
               )
             VALUES
               (l_application_id
               ,l_axis_set_id
               ,l_axis_seq
               ,l_calculation_seq
               ,l_operator
               ,l_operator_flag
               ,l_cal_axis_seq
               ,''
               );

               -----------FOR TEST--------------------
               SELECT COUNT(*)
               INTO L_GT_COUNTS
               FROM ja_cn_cfs_calculations_gt;
               ---------------------------------------
              l_calculation_seq:=l_calculation_seq+1;
              FETCH c_axis_seqs_per_line INTO l_cal_axis_seq;
           END LOOP;

           CLOSE c_axis_seqs_per_line;

          --If current calculation line only contains one row name as operand,
          --then retrieve sequence number by row name and insert it into temporary table
          --'JA_CN_CFS_CALCULATION_GBLTEMP'
         ELSIF l_axis_name_low IS NOT NULL
         THEN
           OPEN c_axis_seq;
           FETCH c_axis_seq INTO l_cal_axis_seq;
           CLOSE c_axis_seq;

           INSERT
           INTO
             ja_cn_cfs_calculations_gt
               (application_id,axis_set_id
               ,axis_seq
               ,calculation_seq
               ,operator
               ,operator_flag
               ,cal_axis_seq
               ,constant
               )
           VALUES
             (l_application_id
             ,l_axis_set_id
             ,l_axis_seq
             ,l_calculation_seq
             ,l_operator
             ,l_operator_flag
             ,l_cal_axis_seq
             ,''
             );

           l_calculation_seq:=l_calculation_seq+1;

           --If current calculation line only constains a constant,then directly insert this
           --line into temporary table 'JA_CN_CFS_CALCULATION_GBLTEMP'
         ELSIF l_constant IS NOT NULL THEN


           INSERT
           INTO
             ja_cn_cfs_calculations_gt
              (application_id,axis_set_id
              ,axis_seq
              ,calculation_seq
              ,operator
              ,operator_flag
              ,cal_axis_seq
              ,constant
               )
           VALUES
             (l_application_id
             ,l_axis_set_id
             ,l_axis_seq
             ,l_calculation_seq
             ,l_operator
             ,l_operator_flag
             ,''
             ,l_constant
             );

           l_calculation_seq:=l_calculation_seq+1;
         END IF; --(l_axis_seq_low IS NOT NULL)
      END IF;  --l_operator<>'+' or l_operator<>'-' or l_operator <> 'ENTER'
      FETCH c_report_calculations INTO l_operator,l_axis_seq_low,l_axis_seq_high,l_axis_name_low,l_constant;
    END LOOP;  --WHILE c_report_calculation%FOUND

    CLOSE c_report_calculations;

   --Insert into current item into the tempoary table 'ja_cn_cfs_row_cgs_gt'
   --and set value of the column 'CALCULATION_FLAG' as 'Y'. If current item has calcuation lines with
   --wrong operator, then set value of the column 'TYPE' as 'E'

    IF l_exit_flag='Y'
    THEN
      l_type:='E';
    ELSE
      l_type:='';
    END IF;  --l_exit_flag='Y'

    INSERT
      INTO
        ja_cn_cfs_row_cgs_gt
        (application_id
        ,axis_set_id
        ,axis_seq
        ,type
        ,calculation_flag
        ,display_flag
        ,display_zero_amount_flag
        ,change_sign_flag
        )
    VALUES
     (l_application_id
     ,l_axis_set_id
     ,l_axis_seq
     ,l_type
     ,'Y'
     ,l_display_flag
     ,l_display_zero_flag
     ,l_change_sign_flag
     );

    FETCH c_report_axis INTO l_application_id,l_axis_seq,l_display_flag,l_display_zero_flag,l_change_sign_flag;
  END LOOP;  --c_report_axis%FOUND

  CLOSE c_report_axis;

  --It is possible that a row in calculation lines of a item is also a calcuated item, so the following
  --steps will translate rows in calculation lines into most detail rows

  --Retrive calculated items from the temporary table 'ja_cn_cfs_row_cgs_gt'

  OPEN c_calculation_rows;
  FETCH c_calculation_rows INTO l_cal_axis_seq,l_type;
  WHILE c_calculation_rows%FOUND
  LOOP

    l_calculated_row_count:=0;

    OPEN c_calculated_rows_count;
    FETCH c_calculated_rows_count INTO l_calculated_row_count;
    CLOSE c_calculated_rows_count;

    --Judge if there are other rows that use current row as operand
    IF l_calculated_row_count>0
    THEN

      --If current row with type 'E', then all other calculation rows that has this row as operand should be with type 'E' as well
      IF l_type='E'
      THEN
        UPDATE
          ja_cn_cfs_row_cgs_gt crcg
        SET
          crcg.type='E'
        WHERE crcg.application_id=l_application_id
          AND crcg.axis_set_id=l_axis_set_id
          AND (crcg.type IS NULL OR crcg.type<>'E')
          AND crcg.axis_seq IN (SELECT
                                DISTINCT ccg.axis_seq
                                FROM
                                  ja_cn_cfs_calculations_gt ccg
                                WHERE ccg.application_id=crcg.application_id
                                  AND ccg.axis_set_id=crcg.axis_set_id
                                  AND ccg.cal_axis_seq=l_cal_axis_seq
                               );
      ELSE

     --Begin to decompose current row number, replace calculation lines that are of
     --curent row number with calculation lines that belong to current row for all
     --other fsg rows that have current row as operands.
        OPEN c_calculated_rows;
        FETCH c_calculated_rows INTO l_calculated_axis_seq;
        WHILE c_calculated_rows%FOUND
        LOOP



          FOR l_cal_line IN c_cfs_calculation_lines
          LOOP

         --Decompose current row number
            INSERT
            INTO
              ja_cn_cfs_calculations_gt
              (application_id,axis_set_id
              ,axis_seq
              ,calculation_seq
              ,operator
              ,operator_flag
              ,cal_axis_seq
              ,constant
              )
            SELECT
              l_application_id
             ,l_axis_set_id
             ,l_calculated_axis_seq
             ,l_cal_line.calculation_seq+calculation_seq/10000
             ,decode(l_cal_line.operator_flag*operator_flag
                    ,1
                    ,'+'
                    ,-1
                    ,'-'
                    ,'+'
                    )
             ,l_cal_line.operator_flag*operator_flag
             ,cal_axis_seq
             ,constant
            FROM
              ja_cn_cfs_calculations_gt
            WHERE application_id=l_application_id
              AND axis_set_id=l_axis_set_id
              AND axis_seq=l_cal_axis_seq;


          END LOOP;  --l_cal_line IN c_cfs_calculation_lines

       --Delete lines with cal_axis_seq 'l_cal_axis_seq' from calculation lines
       --of row l_calculated_axis_seq
       --
          DELETE
          FROM
            ja_cn_cfs_calculations_gt
          WHERE application_id=l_application_id
            AND axis_set_id=l_axis_set_id
            AND axis_seq=l_calculated_axis_seq
            AND cal_axis_seq=l_cal_axis_seq;

          FETCH c_calculated_rows INTO l_calculated_axis_seq;

        END LOOP;  --WHILE c_calculated_rows%FOUND



        CLOSE c_calculated_rows;

      END IF;--l_type='E'

    END IF;  --l_calculated_row_count>0

    FETCH c_calculation_rows INTO l_cal_axis_seq,l_type;

  END LOOP; --WHILE c_calculation_rows%FOUND

  CLOSE c_calculation_rows;

                -----------FOR TEST--------------------
               SELECT COUNT(*)
               INTO l_gt_counts1
               FROM ja_cn_cfs_row_cgs_gt;
               ---------------------------------------



                -----------FOR TEST--------------------
               SELECT COUNT(*)
               INTO L_GT_COUNTS
               FROM ja_cn_cfs_calculations_gt;
               ---------------------------------------



  --log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

END Populate_Formula;

--==========================================================================
--  PROCEDURE NAME:
--
--    Categorize_Rows               Public
--
--  DESCRIPTION:
--
--    The 'Categorize_Rows' procedure is to categorize rows in FSG rowsets that
--    are defined for Cash Flow statement with the following three types:
--        1.  Rows belong to subsidiary part of Cash Flow Statement
--        2.  Rows belong to main part of Cash Flow Statement
--        3.  Rows that have calculation on FSG rowset form, but those rows
--            involved in calculation respectively belong to above the type one
--            and the type two.
--
--  PARAMETERS:
--      In: p_legal_entity_id    Identifier of legal entity
--          p_axis_set_id        Identifier of FSG Row Set
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--
--===========================================================================
PROCEDURE Categorize_Rows
(p_coa     IN NUMBER
,p_axis_set_id         IN NUMBER
)
IS
l_axis_set_id            rg_report_axis_sets.axis_set_id%TYPE  :=p_axis_set_id;
l_coa       NUMBER                                :=p_coa;
l_cal_type               VARCHAR2(1);
l_type                   VARCHAR2(1);

CURSOR c_axis_seq_fsg
IS
SELECT
  rra.application_id
 ,rra.axis_seq
 ,rra.display_flag
 ,rra.display_zero_amount_flag
 ,rra.change_sign_flag
 ,rra.display_format
FROM
  rg_report_axes          rra
WHERE rra.axis_set_id=l_axis_set_id
  AND EXISTS (SELECT
                rrac.axis_seq
              FROM
                rg_report_axis_contents rrac
              WHERE rrac.application_id=rra.application_id
                AND rrac.axis_set_id=rra.axis_set_id
                AND rrac.axis_seq=rra.axis_seq
             );

CURSOR c_axis_seq_cfs
IS
SELECT
  DISTINCT
  rra.application_id
 ,jccaa.axis_seq
 ,rra.display_flag
 ,rra.display_zero_amount_flag
 ,rra.change_sign_flag
 ,rra.display_format
FROM
  ja_cn_cfs_assignments_all jccaa
 ,rg_report_axes            rra
WHERE jccaa.chart_of_accounts_id=l_coa
  AND jccaa.axis_set_id=l_axis_set_id
  AND rra.axis_set_id=jccaa.axis_set_id
  AND jccaa.axis_seq=rra.axis_seq
  AND jccaa.axis_seq NOT IN (SELECT
                               jccrcg.axis_seq
                             FROM
                               ja_cn_cfs_row_cgs_gt jccrcg
                             WHERE axis_set_id=l_axis_set_id
                             );

CURSOR c_axis_seq_desc
IS
SELECT
  rra.application_id
 ,rra.axis_seq
 ,rra.display_flag
 ,rra.display_zero_amount_flag
 ,rra.change_sign_flag
 ,rra.display_format
FROM
  rg_report_axes rra
WHERE rra.axis_set_id=l_axis_set_id
  AND NOT EXISTS(SELECT
                   crcg.axis_seq
                 FROM
                   ja_cn_cfs_row_cgs_gt crcg
                 WHERE crcg.axis_set_id=rra.axis_set_id
                   AND crcg.axis_seq=rra.axis_seq
                 );

CURSOR c_cal_axis_seqs
IS
SELECT
  application_id
 ,axis_seq
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND calculation_flag='Y'
  AND (type IS NULL OR type<>'E')
FOR UPDATE;

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Categorize_Rows';

BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_coa '||p_coa
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
 --Retrive rows that have account assignment in FSG rowset,which are most detailed items for subsidiary
 --part of Cash flow Statement, and then insert these rows into the temporary table 'ja_cn_cfs_row_cgs_gt'
 --with type 'F'

  FOR l_axis_seq_fsg IN c_axis_seq_fsg
  LOOP
    INSERT
    INTO
      ja_cn_cfs_row_cgs_gt
      (application_id
      ,axis_set_id
      ,axis_seq
      ,type
      ,calculation_flag
      ,display_flag
      ,display_zero_amount_flag
      ,change_sign_flag
      ,display_format
      )
    VALUES
      (l_axis_seq_fsg.application_id
      ,l_axis_set_id
      ,l_axis_seq_fsg.axis_seq
      ,'F'
      ,'N'
      ,l_axis_seq_fsg.display_flag
      ,l_axis_seq_fsg.display_zero_amount_flag
      ,l_axis_seq_fsg.change_sign_flag
      ,l_axis_seq_fsg.display_format
      );

  END LOOP;  -- l_axis_seq_fsg IN c_axis_seq_fsg



  --If rows in FSG rowset have not account assignment and calculation, but have assignments by Cash Flow Item
  --Assignment form, they should be regarded as most detailed items for main part of Cash Flow Statement. Insert
  --these rows into the temporary table 'ja_cn_cfs_row_cgs_gt' with type 'C' after they are identified

  --So rows that are most detailed item for  main part of Cash flow statement, shoud be those in the table
  --JA_CN_CFS_ASSIGNMENTS_ALL for current legal entity and row set, and not in the table 'ja_cn_cfs_row_cgs_gt'
  FOR l_axis_seq_cfs IN c_axis_seq_cfs
  LOOP
    INSERT
    INTO
      ja_cn_cfs_row_cgs_gt
      (application_id
      ,axis_set_id
      ,axis_seq
      ,type
      ,calculation_flag
      ,display_flag
      ,display_zero_amount_flag
      ,change_sign_flag
      ,display_format
      )
    VALUES
      (l_axis_seq_cfs.application_id
      ,l_axis_set_id
      ,l_axis_seq_cfs.axis_seq
      ,'C'
      ,'N'
      ,l_axis_seq_cfs.display_flag
      ,l_axis_seq_cfs.display_zero_amount_flag
      ,l_axis_seq_cfs.change_sign_flag
      ,l_axis_seq_cfs.display_format
      );

  END LOOP;  --FOR l_axis_seq_cfs IN c_axis_seq_cfs



  --For all rows in FSG rowset that do not have calculation, account
  --assignments and cash flow item assignments,-they are description
  --lines in cash flow statment, we will store them into table
  --'ja_cn_cfs_row_cgs_gt' and mark them with type 'F'.

  FOR l_axis_seq_desc IN c_axis_seq_desc
  LOOP
    INSERT
    INTO
      ja_cn_cfs_row_cgs_gt
      (application_id
      ,axis_set_id
      ,axis_seq
      ,type
      ,calculation_flag
      ,display_flag
      ,display_zero_amount_flag
      ,change_sign_flag
      ,display_format
      )
    VALUES
      (l_axis_seq_desc.application_id
      ,l_axis_set_id
      ,l_axis_seq_desc.axis_seq
      ,'F'
      ,'N'
      ,l_axis_seq_desc.display_flag
      ,l_axis_seq_desc.display_zero_amount_flag
      ,l_axis_seq_desc.change_sign_flag
      ,l_axis_seq_desc.display_format
      );

  END LOOP;  --FOR l_axis_seq_desc IN c_axis_seq_desc




  --For a row with calculation_flag 'Y' in the table ja_cn_cfs_row_cgs_gt,
  --it means this row is a item which amount is calcuated by other rows.
  --In this case, if all rows that are involved in calculation for it belong to
  --main part of cash flow statment, then this row should belong to main part of
  --cash flow statemnt too, it should be marked as type 'C' in the table
  --'ja_cn_cfs_row_cgs_gt'.Else, if all rows that are involved in
  --calculation for it are belong to subsidiary part of cash flow statement,
  --then this row should belong to subsidiary part of cash flow statemnt as well,
  --it should be marked as type 'F' in the table 'ja_cn_cfs_row_cgs_gt'.
  --Else, if some rows that are involved in calcuation for it belong to main part
  --of cash flow statement, but others belong to subsidiary part of cash flow
  --statement, this row should be marked as type 'M', it would be processed by
  --procedure Generate_Cfs_Xml.
  FOR  l_cal_axis_seq IN c_cal_axis_seqs
  LOOP

    BEGIN
      --To get types of calculation lines of current row
      SELECT
        DISTINCT crcg.type
      INTO
        l_cal_type
      FROM
        ja_cn_cfs_row_cgs_gt     crcg
       ,ja_cn_cfs_calculations_gt ccg
      WHERE ccg.application_id=l_cal_axis_seq.application_id
        AND ccg.axis_set_id=l_axis_set_id
        AND ccg.axis_seq=l_cal_axis_seq.axis_seq
        AND crcg.application_id=ccg.application_id
        AND crcg.axis_set_id=ccg.axis_set_id
        AND crcg.axis_seq=ccg.cal_axis_seq;

      --If all operandS in calculation lines have type 'F',then the calculated
      --row should have type 'F' as well
      IF l_cal_type='F'
      THEN
        l_type:='F';

      ----If all operandS in calculation lines have type 'C',then the calculated
      --row should have type 'C' as well
      ELSIF l_cal_type='C'
      THEN
        l_type:='C';
      END IF;  -- l_cal_type='F'

    EXCEPTION
      --If the sql raise NO_DATA_FOUND exception,it means all calculation lines
      --of current row are comprised by CONSTANT, not include any other fsg row
      --so the type of current should be 'F', which is an item in subsidiary part of
      --cash flow statement
      WHEN NO_DATA_FOUND THEN
        l_type:='F';

      --If the sql raise TOO_MANY_ROWS exception,it means some calculation lines
      --of current row belong to subsidiary part of cash flow statement and others
      --belong to main part of cash flow statement, so the type of current row should
      --be 'M', it means amount of current row will be calculated by lines from both
      --parts
      WHEN TOO_MANY_ROWS THEN
        l_type:='M';

      WHEN OTHERS THEN
        RAISE;
    END;

    --Update type of current row in the table ja_cn_cfs_row_cgs_gt
    UPDATE
      ja_cn_cfs_row_cgs_gt
    SET
      type=l_type
    WHERE CURRENT OF c_cal_axis_seqs;

  END LOOP; --l_cal_axis_seq IN c_cal_axis_seqs

  --log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
END Categorize_Rows;

--==========================================================================
--  PROCEDURE NAME:
--
--    Calculate_Row_Amount               Public
--
--  DESCRIPTION:
--
--    The procedure 'Calculate_Row_Amount' is used to calculate amount for a
--    specific cash flow item in the main part of cash flow statement according
--    to assignment in the table 'JA_CN_CFS_ASSIGNMENTS_ALL' and amount of detailed
--    cash flow item in the table 'JA_CN_CFS_ACTIVITIES_ALL'.
--
--  PARAMETERS:
--      In:  p_legal_entity_id   Identifier of legal entity
--           p_set_of_bks_id     Identifier of GL set of book, a required
--                               parameter for FSG report
--           p_axis_set_id       Identifier of FSG Row Set
--           p_axis_seq          Sequence number of FSG row
--
--           p_balace_type       Type of balance, available value is 'YTD/QTD/PTD'.
--                               a required parameter for FSG report
--           p_period_names      Qualified period names for cash flow statement
--                               calculation
--           p_rounding_option   Rounding option for amount in Cash Flow statement
--           p_internal_trx_flag To indicate if intercompany transactions
--                               should be involved in amount calculation
--                               of cash flow statement.
--
--
--     Out:  x_amount            Amount of cash flow item
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--      1-Sep-2008      Chaoqun Wu Added BSV parameter for CNAO Enhancement
--
--===========================================================================
PROCEDURE Calculate_Row_Amount
(p_legal_entity_id    IN    NUMBER
,p_ledger_id      IN    NUMBER
,p_coa           IN     NUMBER  --added by lyb
,p_axis_set_id        IN    NUMBER
,p_axis_seq           IN    NUMBER
,p_period_names       IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_rounding_option    IN    VARCHAR2
,p_balancing_segment_value  IN VARCHAR2 --added for CNAO Enhancement
--,p_internal_trx_flag  IN    VARCHAR2
,x_amount             OUT   NOCOPY NUMBER
)
IS
l_legal_entity_id    NUMBER :=p_legal_entity_id;
l_ledger_id          gl_ledgers.ledger_id%TYPE :=p_ledger_id;
l_period_names       JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL :=p_period_names;
l_rounding_option    VARCHAR2(50) :=p_rounding_option;
l_axis_set_id        rg_report_axis_sets.axis_set_id%TYPE  :=p_axis_set_id;
l_axis_seq           rg_report_axes.axis_seq%TYPE :=p_axis_seq;
l_amount_per_period  NUMBER;
l_amount             NUMBER;
l_period_count       NUMBER;
l_period_name        VARCHAR2(15);
l_precision          fnd_currencies.precision%TYPE;
l_balancing_segment_value VARCHAR2(25) := p_balancing_segment_value;  --added for CNAO Enhancement
--l_internal_trx_flag  VARCHAR2(1) :=p_internal_trx_flag;

CURSOR c_precision
IS
SELECT
  nvl(PRECISION,0)
FROM
  fnd_currencies
WHERE currency_code=(SELECT
                       currency_code
                     FROM
                       gl_ledgers
                     WHERE ledger_id=l_ledger_id
                     );


--this cursor is updated by lyb,delete some sentence and change the parameter legal_entity_id to COA
CURSOR c_amount_per_period
IS
SELECT
  nvl(SUM(round(func_amount,decode(l_rounding_option,'R',l_precision,50))),0)
FROM
  ja_cn_cfs_activities_all
WHERE period_name=l_period_name
  AND legal_entity_id=l_legal_entity_id
  -- added for CNAO Enhancement begin
  AND (
       ( l_balancing_segment_value IS NULL
        OR
         l_balancing_segment_value = balancing_segment
       )
       AND EXISTS
        (
           SELECT *
            FROM Gl_Ledgers Lg,
                 Gl_Ledger_Relationships Rs,
                 Gl_Ledger_Norm_Seg_Vals nbsv
            WHERE lg.bal_seg_value_option_code='I'
             AND Rs.Application_Id = 101
             AND Lg.Ledger_Id = l_ledger_id              --Using variable ledger_id
             AND Lg.Ledger_Id = Rs.Target_Ledger_Id
             AND Nvl(Lg.Complete_Flag, 'Y') = 'Y'
             AND nbsv.Segment_Type_Code = 'B'
             AND Nvl(nbsv.Status_Code, 'I') <> 'D'
             AND(( Rs.Relationship_Type_Code = 'NONE'
               AND Rs.Target_Ledger_Id = LG.Ledger_Id
                 )
              OR ( Rs.Target_Ledger_Category_Code = 'ALC'
               AND Rs.Relationship_Type_Code IN ('SUBLEDGER', 'JOURNAL')
               AND Rs.Source_Ledger_Id = LG.Ledger_Id
                 )
               )
             AND nbsv.ledger_id=Lg.Ledger_Id
             AND nbsv.legal_entity_id = l_legal_entity_id  --Using variable legal_entity_id
             AND nbsv.Segment_Value = balancing_segment
          )
        )
  -- added for CNAO Enhancement end
  AND detailed_cfs_item IN (SELECT
                              detailed_cfs_item
                            FROM
                              ja_cn_cfs_assignments_all
                            WHERE chart_of_accounts_id=p_coa --updated by lyb
                              AND axis_set_id=l_axis_set_id
                              AND axis_seq=l_axis_seq
                           );

  --AND intercompany_flag LIKE decode(l_internal_trx_flag,'Y','%', 'N');

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Calculate_Row_Amount';

BEGIN
  l_period_count:=l_period_names.COUNT;
--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_legal_entity_id '||p_legal_entity_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_ledger_id '||p_ledger_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_seq '||p_axis_seq
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_names '
                  );


    FOR l_count IN 1..l_period_count
    LOOP
      FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_names'||l_count||' '||l_period_names(l_count)
                  );
    END LOOP;-- FOR l_count IN 1..l_period_count

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_rounding_option '||p_rounding_option
                  );

    FND_LOG.String(l_proc_level                                    --added for CNAO Enhancement
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_balancing_segment_value '||p_balancing_segment_value
                  );

/*    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_internal_trx_flag  '||p_internal_trx_flag
                  );*/

  END IF;  --(l_proc_level >= l_dbg_level)

  --To get precision of  functional currecy  of current gl set of book
  OPEN c_precision;
  FETCH c_precision INTO l_precision;
  CLOSE c_precision;

  --Calculate amount for a specific cash flow item according to assignment of detailed cash flow items
  --in the 'JA_CN_CFS_ACTIVITIES_ALL' and amount of detailed cash flow items that are populated by
  --'Cash flow Statment - collection' program

  --Initialize variable
  l_amount:=0;

  --To get the number of periods that are involved in calculation


  FOR l_count IN 1..l_period_count
  LOOP
    l_period_name:=l_period_names(l_count);
    OPEN c_amount_per_period;
    FETCH c_amount_per_period INTO l_amount_per_period;
    CLOSE c_amount_per_period;

    l_amount:=l_amount+l_amount_per_period;
  END LOOP;   --l_count IN 1..l_period_count
  x_amount:=round(l_amount,l_precision);

  --log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.out'
                  ,'x_amount '||x_amount
                  );


    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
END Calculate_Row_Amount;


--==========================================================================
--  PROCEDURE NAME:
--
--    Calculate_Rows_Amount               Public
--
--  DESCRIPTION:
--
--    The procedure Calculate_Rows_Amount is used to calculate amount for items
--    in the main part of Cash Flow Statement.
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_set_of_bks_id             Identifier of GL set of book, a required
--                                      parameter for FSG report
--          p_axis_set_id               Identifier of FSG Row Set
--          p_period_names              Qualified period names for cash flow statement
--                                      calculation
--          p_lastyear_period_names     Qualified period names in last year for cash
--                                      flow statement calculation
--          p_rounding_option           Rounding option for amount in Cash Flow statement
--          p_internal_trx_flag         To indicate if intercompany transactions
--                                      should be involved in amount calculation
--                                      of cash flow statement.
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--      14-Oct-2008     Chaoqun Wu   Fix bug# 7481516
--
--===========================================================================
PROCEDURE Calculate_Rows_Amount
(p_legal_entity_id       IN    NUMBER
,p_ledger_id         IN    NUMBER
,p_coa               IN    NUMBER
,p_axis_set_id           IN    NUMBER
,p_period_names          IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_lastyear_period_names IN    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL
,p_rounding_option       IN    VARCHAR2
,p_segment_override       IN VARCHAR2  --added for CNAO Enhancement
--,p_internal_trx_flag     IN    VARCHAR2
)
IS
l_legal_entity_id          NUMBER                                    :=p_legal_entity_id;
l_ledger_id                gl_ledgers.ledger_id%TYPE     :=p_ledger_id;
l_period_names             JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL :=p_period_names;
l_lastyear_period_names    JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL :=p_lastyear_period_names;
l_rounding_option          VARCHAR2(50)                              :=p_rounding_option;
l_axis_set_id              rg_report_axis_sets.axis_set_id%TYPE      :=p_axis_set_id;
l_axis_seq                 rg_report_axes.axis_seq%TYPE;
l_amount                   NUMBER;
l_lastyear_amount          NUMBER;
l_precision                fnd_currencies.precision%TYPE;
l_cal_axis_seq             rg_report_axes.axis_seq%TYPE;
l_segment_override         VARCHAR2(100)                             := p_segment_override; --added for CNAO Enhancement
l_balancing_segment_value  JA_CN_CFS_ACTIVITIES_ALL.BALANCING_SEGMENT%TYPE; --added for CNAO Enhancement
--l_internal_trx_flag        VARCHAR2(1);
l_cal_seq_amount           NUMBER;
l_cal_seq_lastyear_amount  NUMBER;
l_period_count             NUMBER;
l_lastyear_period_count    NUMBER;

CURSOR c_precision
IS
SELECT
  nvl(PRECISION,0)
FROM
  fnd_currencies
WHERE currency_code=(SELECT
                       currency_code
                     FROM
                       gl_ledgers
                     WHERE ledger_id=l_ledger_id
                     );

CURSOR c_detailed_cfs_rows
IS
SELECT
  axis_seq
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND type='C'
  AND calculation_flag='N'
FOR UPDATE;

CURSOR c_cal_cfs_rows
IS
SELECT
  axis_seq
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND type='C'
  AND calculation_flag='Y'
FOR UPDATE;

CURSOR c_calculation_lines
IS
SELECT
  operator
 ,cal_axis_seq
 ,constant
FROM
 ja_cn_cfs_calculations_gt
WHERE axis_set_id=l_axis_set_id
  AND axis_seq=l_axis_seq
ORDER BY calculation_seq;

CURSOR c_cal_seq_amount
IS
SELECT
  nvl(amount,0)
 ,nvl(last_year_amount,0)
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND axis_seq=l_cal_axis_seq;

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Calculate_Rows_Amount';

BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_legal_entity_id '||p_legal_entity_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_ledger_id '||p_ledger_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_names '
                  );

    l_period_count:=l_period_names.COUNT;

    FOR l_count IN 1..l_period_count
    LOOP
      FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_names'||l_count||' '||l_period_names(l_count)
                  );
    END LOOP;-- FOR l_count IN 1..l_period_count

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_lastyear_period_names '
                  );

    l_lastyear_period_count:=l_lastyear_period_names.COUNT;

    FOR l_count IN 1..l_lastyear_period_count
    LOOP
      FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_lastyear_period_names'||l_count||' '||l_lastyear_period_names(l_count)
                  );
    END LOOP;-- FOR l_count IN 1..l_lastyear_period_count

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_rounding_option '||p_rounding_option
                  );

    FND_LOG.String(l_proc_level                                    --added for CNAO Enhancement
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_segment_override '||p_segment_override
                  );

/*    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_internal_trx_flag  '||p_internal_trx_flag
                  );*/

  END IF;  --(l_proc_level >= l_dbg_level)
  --To get precision of currecy  of current gl set of book
  OPEN c_precision;
  FETCH c_precision INTO l_precision;
  CLOSE c_precision;

  --added for CNAO Enhancement
  l_balancing_segment_value := JA_CN_UTILITY.Get_Balancing_Segment_Value(
                                               p_coa,
                                               l_segment_override);

  --Calculate amount for rows with type 'C' and calculation flag 'N'
  -- in the table ja_cn_cfs_row_cgs_gt,-which are items in main
  --part of cash flow statment and formula are defined by Cash Flow
  --Statement Assignment form
  FOR l_detailed_cfs_row IN c_detailed_cfs_rows
  LOOP
    l_amount:=0;
    l_lastyear_amount:=0;
    JA_CN_CFS_CALCULATE_PKG.Calculate_Row_Amount(p_legal_entity_id   => l_legal_entity_id
                                                ,p_ledger_id     => l_ledger_id
                                                ,p_coa           => p_coa  --added by lyb
                                                ,p_axis_set_id       => l_axis_set_id
                                                ,p_axis_seq          => l_detailed_cfs_row.axis_seq
                                                ,p_period_names      => l_period_names
                                                ,p_rounding_option   => l_rounding_option
                                                ,p_balancing_segment_value =>l_balancing_segment_value
                                           --     ,p_internal_trx_flag => l_internal_trx_flag
                                                ,x_amount            => l_amount
                                                );

    --keep the amount to ja_cn_cfs_row_cgs_gt
    UPDATE
      ja_cn_cfs_row_cgs_gt
    SET
      amount=l_amount
    WHERE CURRENT OF c_detailed_cfs_rows;
    --If the parameter l_lastyear_period_names is not null, then calculate last year amount for current row
    IF l_lastyear_period_names IS NOT NULL
    THEN

      JA_CN_CFS_CALCULATE_PKG.Calculate_Row_Amount(p_legal_entity_id   => l_legal_entity_id
                                                  ,p_ledger_id     => l_ledger_id
                                                  ,p_coa           => p_coa  --added by lyb
                                                  ,p_axis_set_id       => l_axis_set_id
                                                  ,p_axis_seq          => l_detailed_cfs_row.axis_seq
                                                  ,p_period_names      => l_lastyear_period_names
                                                  ,p_rounding_option   => l_rounding_option
                                                  ,p_balancing_segment_value  =>l_balancing_segment_value  --added for CNAO Enhancement
                                                 -- ,p_internal_trx_flag => l_internal_trx_flag
                                                  ,x_amount            => l_lastyear_amount
                                                  );

      --keep the last year amount to ja_cn_cfs_row_cgs_gt
      UPDATE
        ja_cn_cfs_row_cgs_gt
      SET
        last_year_amount=l_lastyear_amount
      WHERE CURRENT OF c_detailed_cfs_rows;
    END IF; --l_lastyear_period_names IS NOT NULL


  END LOOP; --FOR l_detailed_cfs_row IN c_detailed_cfs_rows





  --Calculate amount for rows with type 'C' and calculation flag 'Y'
  -- in the table ja_cn_cfs_row_cgs_gt,which are items in main
  --part of cash flow statment. These row can calculated by other rows
  --with formula defined in FSG row set

  FOR l_cal_cfs_row IN c_cal_cfs_rows
  LOOP
    l_amount:=0;
    l_lastyear_amount:=0;

    --calculate amount and last year amount for current row according to relative
    --calculation lines in the table  'JA_CN_CFS_CALCULATION_GBLTEMP'

    l_axis_seq:=l_cal_cfs_row.axis_seq;

    FOR l_calculation_line IN c_calculation_lines
    LOOP

      l_cal_axis_seq:=l_calculation_line.cal_axis_seq;

      OPEN c_cal_seq_amount;
      FETCH c_cal_seq_amount INTO l_cal_seq_amount,l_cal_seq_lastyear_amount;
      CLOSE c_cal_seq_amount;

      IF l_calculation_line.operator='+'
      THEN
        l_amount:=l_amount+l_cal_seq_amount;
        l_lastyear_amount:=l_lastyear_amount+l_cal_seq_lastyear_amount;
      ELSIF l_calculation_line.operator='-'
      THEN
        l_amount:=l_amount-l_cal_seq_amount;     --Fix bug# 7481516 updated
        l_lastyear_amount:=l_lastyear_amount-l_cal_seq_lastyear_amount; --Fix bug# 7481516 updated
      END IF;  --l_operator='+'
    END LOOP; --FOR l_calculation_line IN c_calculation_lines

    --keep the amount and last year amount for current row in ja_cn_cfs_row_cgs_gt
    UPDATE
      ja_cn_cfs_row_cgs_gt
    SET
      amount=l_amount
     ,last_year_amount=l_lastyear_amount
    WHERE CURRENT OF c_cal_cfs_rows;

  END LOOP;  --FOR l_cal_cfs_row IN c_cal_cfs_rows

 --log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

END Calculate_Rows_Amount;


--==========================================================================
--  PROCEDURE NAME:
--
--    Generate_Cfs_Xml                  Public
--
--  DESCRIPTION:
--
--      The procedure Generate_Cfs_Xml is to generate xml output for main part of
--      cash flow statement by following format of FSG xml output.
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_set_of_bks_id             Identifier of GL set of book, a required
--                                      parameter for FSG report
--          p_period_name               GL period Name
--          p_axis_set_id               Identifier of FSG Row Set
--          p_rounding_option           Rounding option for amount in Cash Flow statement
--          p_balance_type              Type of balance, available value is
--                                      'YTD/QTD/PTD'. a required parameter for FSG
--                                      report
--          p_internal_trx_flag         To indicate if intercompany transactions
--                                      should be involved in amount calculation
--                                      of cash flow statement.
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      14-Mar-2006     Donghai Wang Created
--      16-Dec-2008     Shujuan yan  Fixed bug 7626489
--===========================================================================
PROCEDURE Generate_Cfs_Xml
(p_legal_entity_id         IN         NUMBER
,p_ledger_id           IN         NUMBER
,p_period_name             IN         VARCHAR2
,p_axis_set_id             IN         NUMBER
,p_rounding_option         IN         VARCHAR2
,p_balance_type            IN         VARCHAR2
--,p_internal_trx_flag       IN         VARCHAR2
,p_coa                     IN NUMBER
,p_segment_override        IN         VARCHAR2 --added for CNAO Enhancement
)
IS
l_coa                       Number              :=p_coa;
l_thousands_separator_flag  VARCHAR2(1);
l_format_mask               VARCHAR2(100);
l_final_display_format      VARCHAR2(30);
l_legal_entity_id           NUMBER                                   :=p_legal_entity_id;
l_ledger_id                 gl_ledgers.ledger_id%TYPE    :=p_ledger_id;
l_func_currency_code        fnd_currencies.currency_code%TYPE;
l_period_name               gl_periods.period_name%TYPE              :=p_period_name;
l_axis_set_id               rg_report_axis_sets.axis_set_id%TYPE     :=p_axis_set_id;
l_rounding_option           VARCHAR2(50)                             :=p_rounding_option;
l_balance_type              VARCHAR2(50)                             :=p_balance_type ;
l_segment_override          VARCHAR2(100)                            :=p_segment_override;  --addded for CNAO Enhancement
--l_internal_trx_flag         VARCHAR2(1)                              :=p_internal_trx_flag ;
l_period_names              JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;
l_lastyear_period_names     JA_CN_CFS_CALCULATE_PKG.G_PERIOD_NAME_TBL;
l_axis_seq                  rg_report_axes.axis_seq%TYPE;
l_type                      VARCHAR2(1);
l_calculation_flag          VARCHAR2(1);
l_display_zero_amount_flag  VARCHAR2(1);
l_change_sign_flag          VARCHAR2(1);
l_display_format            VARCHAR2(30);
l_amount                    NUMBER;
l_amount_display            VARCHAR2(40);
l_row_count                 NUMBER;

l_rowcnt                    VARCHAR2(50);
l_lincnt                    VARCHAR2(50);
l_colcnt                    VARCHAR2(50):='c1001';
l_rptcnt                    VARCHAR2(50):='p1001';

l_xml_output_row            XMLTYPE;
l_xml_output                XMLTYPE;
l_xml_output_root           XMLTYPE;

l_operator                  VARCHAR2(10);
l_operand                   VARCHAR2(500);
l_operands                  VARCHAR2(4000);
l_formula                   VARCHAR2(4000);

l_cal_lincnt                VARCHAR2(50);
l_error_message             VARCHAR2(4000);
l_characterset              varchar(245);



CURSOR c_axis_seq
IS
SELECT
  axis_seq
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND display_flag='Y'
ORDER BY axis_seq
FOR UPDATE;

CURSOR c_rows
IS
SELECT
  axis_seq
 ,type
 ,calculation_flag
 ,display_zero_amount_flag
 ,change_sign_flag
 ,display_format
 ,amount
 ,rowcnt
 ,lincnt
FROM
  ja_cn_cfs_row_cgs_gt
WHERE axis_set_id=l_axis_set_id
  AND display_flag='Y'
ORDER BY axis_seq;

CURSOR c_calculation_lines
IS
SELECT
  jcccg.operator
 ,jccrcg.lincnt
 ,jccrcg.change_sign_flag
FROM
  ja_cn_cfs_calculations_gt jcccg
 ,ja_cn_cfs_row_cgs_gt jccrcg
WHERE jcccg.axis_set_id=l_axis_set_id
  AND jcccg.axis_seq=l_axis_seq
  AND jcccg.axis_set_id=jccrcg.axis_set_id
  AND jcccg.cal_axis_seq=jccrcg.axis_seq
ORDER BY jcccg.calculation_seq;

l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Generate_Cfs_Xml';

BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_legal_entity_id '||p_legal_entity_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_ledger_id '||p_ledger_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_name '||p_period_name
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_rounding_option '||p_rounding_option
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_balance_type '||p_balance_type
                  );

    FND_LOG.String(l_proc_level                                   --addded for CNAO Enhancement
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_segment_override '||p_segment_override
                 );
/*    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_internal_trx_flag '||p_internal_trx_flag
                  );*/
  END IF;  --(l_proc_level >= l_dbg_level)

  --To get value of the profile 'CURRENCY: Thousands Separator' to decide if
  --it is need to export throusands separator for amount.
  l_thousands_separator_flag:=fnd_profile.value(name => 'CURRENCY:THOUSANDS_SEPARATOR');


  --To get format mask for functional currency
  SELECT
    currency_code
  INTO
    l_func_currency_code
  FROM
    gl_ledgers
  WHERE
    ledger_id=l_ledger_id ;

  l_format_mask:=FND_CURRENCY.Get_Format_Mask(currency_code => l_func_currency_code
                                             ,field_length => 30
                                             );



  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Populate_Fomula' to popluate most detailed
  --calculation lines for FSG row with calculation.
  JA_CN_CFS_CALCULATE_PKG.Populate_Formula(p_coa  =>l_coa  --Fix bug# 7427067 begin
                                          ,p_axis_set_id      =>l_axis_set_id
                                          );

  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Categorize_Rows' to categorize FSG row
  JA_CN_CFS_CALCULATE_PKG.Categorize_Rows(p_coa  =>l_coa
                                          ,p_axis_set_id      =>l_axis_set_id
                                          );

  --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Populate_Period_Names' to populate qualified period names
  --by 'period name' and 'balance type' for calculation
  JA_CN_CFS_CALCULATE_PKG.Populate_Period_Names(p_ledger_id    => l_ledger_id
                                               ,p_period_name      => l_period_name
                                               ,p_balance_type     => l_balance_type
                                               ,x_period_names     => l_period_names
                                               );


   --Call the procedure 'JA_CN_CFS_CALCULATE_PKG.Calculate_Rows_Amount' to
   --calculate amount for items in the main part of Cash Flow Statement
   JA_CN_CFS_CALCULATE_PKG.Calculate_Rows_Amount(p_legal_entity_id        =>l_legal_entity_id
                                                ,p_ledger_id          =>l_ledger_id
                                                ,p_coa               =>p_coa
                                                ,p_axis_set_id            =>l_axis_set_id
                                                ,p_period_names           =>l_period_names
                                                ,p_lastyear_period_names  =>l_lastyear_period_names
                                                ,p_rounding_option        =>l_rounding_option
                                                ,p_segment_override =>l_segment_override  --added for CNAO Enhancement
                                               -- ,p_internal_trx_flag      =>l_internal_trx_flag
                                                );


   --Generate XML output for items in the main part of Cash Flow Statement,
   --the output will have similar format as FSG xml output for combination intention

  --To populate row count and line count for each row in the rowset <l_axis_set_id>
  l_row_count:=0;

  OPEN c_axis_seq;
  FETCH c_axis_seq INTO l_axis_seq;

  WHILE c_axis_seq%FOUND
  LOOP
    --To number the row
    l_row_count:=l_row_count+1;

    --To populate rowcount and linecount for output xml like FSG
    l_rowcnt:='r1'||lpad(to_char(l_row_count),5,'0');
    l_lincnt:='l1'||lpad(to_char(l_row_count),5,'0');

   --Update current row with row count and line count
    UPDATE
      ja_cn_cfs_row_cgs_gt
    SET
      rowcnt=l_rowcnt
     ,lincnt=l_lincnt
    WHERE CURRENT OF c_axis_seq;

    FETCH c_axis_seq INTO l_axis_seq;
  END LOOP; --c_axis_seq%FOUND

  CLOSE c_axis_seq;

	--Retrive all rows which display_flag is 'Y' and belong to rowset 'l_rowset_id' from
  --the table ja_cn_cfs_row_cgs_gt by cursor c_rows in ascending order of axis_seq


  OPEN c_rows;
  FETCH
    c_rows
  INTO
    l_axis_seq
   ,l_type
   ,l_calculation_flag
   ,l_display_zero_amount_flag
   ,l_change_sign_flag
   ,l_display_format
   ,l_amount
   ,l_rowcnt
   ,l_lincnt
   ;
   WHILE c_rows%FOUND
   LOOP

     --If the type of current row is 'F', then the row is a item in the
     --subsidiary part of cash flow statement,it will not be handle the
     --by this program, just skip it
     IF l_type='F'
     THEN
       NULL;

     --If the type of current row is 'C', then the row is a item in the
     --main part of cash flow statment, it would be exported in FSG xml
     --output format
     ELSIF l_type='C'
     THEN
       --To judge if output zero for the row or not
       IF l_display_zero_amount_flag='N' AND NVL(l_amount,0)=0
       THEN
         l_amount:='';
         l_amount_display:='';
       ELSE
         --To change sign for the amount if need be
         IF l_change_sign_flag='Y'
         THEN
           l_amount:=nvl(l_amount,0)*-1;
         END IF;  --l_change_sign_flag='Y'

        --To apply format_mask to amount if any
         IF l_display_format IS NOT NULL
         THEN
           SELECT
             to_char(nvl(l_amount,0),'FM'||to_char(l_display_format,l_format_mask))
           INTO
             l_amount_display
           FROM dual;
         ELSE
           SELECT
             to_char(nvl(l_amount,0),l_format_mask)
           INTO
             l_amount_display
           FROM dual;
         END IF;-- l_display_format IS NOT NULL


       END IF; --l_display_zero_amount_flag='N' AND NVL(l_amount,0)=0




       --To generate xml output for current row
       SELECT
         XMLELEMENT("fsgRptLine"
                   ,XMLATTRIBUTES(l_rptcnt AS "RptCnt"
                                 ,l_rowcnt AS "RowCnt"
                                 ,l_lincnt AS "LinCnt"
                                 )
                   ,XMLELEMENT("fsgRptCell"
                                ,XMLATTRIBUTES(l_colcnt AS "ColCnt"
                                               )
                                ,nvl(l_amount_display,0)
                                )
                     )
         INTO
           l_xml_output_row
         FROM
           dual;

         --To concatenate xml output
         IF l_xml_output IS NULL
         THEN
           l_xml_output:=l_xml_output_row;
         ELSE
           SELECT
             XMLCONCAT(l_xml_output
                      ,l_xml_output_row
                      )
           INTO
             l_xml_output
           FROM
             dual;
         END IF; --l_xml_output IS NULL


      --If the type of current row is 'M', then the row is calculated by
      --items in both main part and subsidiary part of cash flow statment
      --so export formula for this row in xml and 'Cash Flow Statement - combination'
      --program will perform calcuation for the row.
      --The formula format should be like '<Formula DisplayZero="Y" ChangeSign="N">
      --LinCnt1:ColCnt=+LinCnt2:ColCnt+LinCnt3:ColCnt </Formula>
     ELSIF l_type='M'
     THEN
       --Retrieve calculation lines for current row
       --to Populate formula as requirement of combination

       --Variables initialization
       l_operands:='';
       l_formula:='';


       --To populater operands and operaters at right side of '=' in the formula
       FOR l_calculation_lines IN c_calculation_lines
       LOOP

         --operator should be generated according to 'Change Sign Flag
         IF l_calculation_lines.change_sign_flag='Y'
         THEN
           SELECT
             decode(l_calculation_lines.operator,'+','-','-','+','+')
           INTO
             l_operator
           FROM dual;
         ELSE
           l_operator:=l_calculation_lines.operator;
         END IF;  --_calculation_lines.change_sign_flag='Y'

         IF l_operands IS NULL
         THEN
           l_operands:=l_operator||l_calculation_lines.lincnt||':'||l_colcnt;
         ELSE
           l_operands:=l_operands||l_operator||l_calculation_lines.lincnt||':'||l_colcnt;
         END IF;--l_operands IS NULL
       END LOOP;  --FOR l_calculation_lines IN c_calculation_lines



       --To populate final formula
       l_formula:=l_lincnt||':'||l_colcnt||'='||l_operands;

       --To populate final display format
       IF l_display_format IS NOT NULL
       THEN
         SELECT
           'FM'||to_char(l_display_format,l_format_mask)
         INTO
           l_final_display_format
         FROM
           dual;
       ELSE
         l_final_display_format:=l_format_mask;
       END IF; --l_display_format IS NOT NULL


       --To generate xml output that contains formula for currrent row
       SELECT
           XMLELEMENT("Formula"
                     ,XMLATTRIBUTES(l_display_zero_amount_flag AS "DisplayZero"
                                   ,l_change_sign_flag AS "ChangeSign"
                                   ,l_final_display_format AS "DisplayFormat"
                                   )
                     ,l_formula
                     )
       INTO
         l_xml_output_row
       FROM
         dual;

       --To concatenate xml output
       IF l_xml_output IS NULL
       THEN
         l_xml_output:=l_xml_output_row;
       ELSE
         SELECT
           XMLCONCAT(l_xml_output
                    ,l_xml_output_row
                    )
         INTO
           l_xml_output
         FROM
           dual;
       END IF; --l_xml_output IS NULL

     --If the type of current row is 'E', then the row is calculated item,but its formual
     --is wrong, so amount of current row cannot be calculated, an error message will be
     --output in xml instead.
     ELSIF l_type='E'
     THEN
       --Get error message from FND message directory
       FND_MESSAGE.Set_Name(application => 'JA'
                           ,name =>'JA_CN_ERROR_FORMULA');
       l_error_message:=FND_MESSAGE.Get;

       --To generate xml output for current row
       SELECT
         XMLELEMENT("fsgRptLine"
                   ,XMLATTRIBUTES(l_rptcnt AS "RptCnt"
                                 ,l_rowcnt AS "RowCnt"
                                 ,l_lincnt AS "LinCnt"
                                 )
                   ,XMLELEMENT("fsgRptCell"
                              ,XMLATTRIBUTES(l_colcnt AS "ColCnt"
                                             )
                              ,l_error_message
                              )
                    )
       INTO
         l_xml_output_row
       FROM
         dual;

       --To concatenate xml output
       IF l_xml_output IS NULL
       THEN
         l_xml_output:=l_xml_output_row;
       ELSE
         SELECT
           XMLCONCAT(l_xml_output
                    ,l_xml_output_row
                    )
         INTO
          l_xml_output
         FROM
           dual;
       END IF; --l_xml_output IS NULL

     END IF; --l_type='F'
     FETCH
       c_rows
     INTO
       l_axis_seq
      ,l_type
      ,l_calculation_flag
      ,l_display_zero_amount_flag
      ,l_change_sign_flag
      ,l_display_format
      ,l_amount
      ,l_rowcnt
      ,l_lincnt
      ;

  END LOOP;  --c_rows%FOUND

  CLOSE c_rows;

  --To add root node for the xml output
  SELECT XMLELEMENT("MasterReport"
                   ,XMLATTRIBUTES('http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi"
                                 ,'http://www.oracle.com/fsg/2002-03-20/' AS "xmlns:fsg"
                                 ,'http://www.oracle.com/2002-03-20/fsg.xsd' AS "xsi:schemaLocation"
                                 )
                   ,l_xml_output
                   )
  INTO l_xml_output_root
  FROM dual;

  --Replace fsg with fsg; for XML output of fsg segments of main part of
  --cash flow statemen, for avoid XML schema analyzing in XML API.
  IF l_xml_output_root IS NOT NULL
  THEN
    -- Updated by shujuan for bug 7626489
    l_characterset :=Fnd_Profile.VALUE(NAME => 'ICX_CLIENT_IANA_ENCODING');
    FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding= '||'"'||l_characterset||'"?>');
    --FND_FILE.Put_Line(FND_FILE.Output,'<?xml version="1.0" encoding="utf-8" ?>');
    FND_FILE.Put_Line(FND_FILE.Output,REPLACE(l_xml_output_root.getclobval(),'fsgRpt','fsg:Rpt'));
  END IF;

--log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
END Generate_Cfs_Xml;


END JA_CN_CFS_CALCULATE_PKG;

/
