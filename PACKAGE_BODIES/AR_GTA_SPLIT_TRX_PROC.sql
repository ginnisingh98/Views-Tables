--------------------------------------------------------
--  DDL for Package Body AR_GTA_SPLIT_TRX_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_SPLIT_TRX_PROC" AS
--$Header: ARGRXTRB.pls 120.0.12010000.4 2010/03/17 03:26:59 yaozhan noship $

--+===========================================================================
--|                    Copyright (c) 2002 Oracle Corporation
--|                       Redwood Shores, California, USA
--|                            All rights reserved.
--+===========================================================================
--|
--|  FILENAME :
--|                        ARRXTRB.pls
--|
--|  DESCRIPTION:
--|                        This procedure split GTA transactions against setup
--|                        of max amount,sales list flag and lines number
--|
--|
--|
--|
--|  HISTORY:
--|                         Created : 10-MAY-2005 : Jim.Zheng
--|                        30-sep-2005: Jim zheng modify because registration
--|                                     issue.
--|                        10-Oct-2005: Jim Zheng add some log for debug .
--|
--|                        11-Oct-2005: Jim Zheng fix bug after debug on DMFDV11i
--|
--|                        13-Oct-2005: Jim Zheng fix get trx type bug
--|
--|                        01-Dec-2005: Jim Zheng Fix a init error in judge_cm_limit
--|                        02-Dec-2005: Jim Zheng Fix a gta_trx_number bug, procedure Split_transactions
--|
--|                        06-Dec-2005: Jim Zheng Fix a gta_trx_number bug, difference of l_gta_trx and l_gta_trx_new,
--|                                               procedure Split_transactions
--|                        06-Dec-2005: Jim Zheng Change the tax rate -- 0.17 to l_GTA_Trx_line.tax_rate
--|                                               when split a trx line
--|                        08-Dec-2005: Jim Zheng Add output log for debug
--|                        14-Dec-2005: Jim Zheng Add gta_inv_number into temp table ar_gta_transfer_temp
--|                        15-Dec-2005: Jim Zheng Add transaction id for successful transaction in add_succ_to_temp
--|                        17-Feb-2006: Jogen Hu  Replace fnd_file.put_line(fnd_file.log by log procedure
--|                        25-Apr-2006: Jogen Hu  Modify Split_Transactions for bug 5168852
--|                        12-Jun-2006: Shujuan Yan  Modify Split_trx_by_taxreg_num for bug 5258345
--|                        12-Jun-2006: Shujuan Yan  Process_before_split for bug 5168900
--|                        28-Dec-2007 Subba  Modified for R12.1
--|                        16-Dec-2008 Yao Zhang fix bug 7644235, CreditMemo should not be transfered or splited when
--|                                    exceed the limition of max amount or max lines.
--|                        15-Jan-2009 Yao Zhang fix bug 7709947 RECEIVABLES TRANSFER TO GOLDEN TAX ADAPTOR ENDS IN ERROR
--|                        23-Jan-2009 Yao Zhang fix bug 7758496 CreditMemo whose line num exceeds max line number limitation
--|                                                              should be transfered when sales list is enabled
--|                        16-Jun-2009 Yao Zhang fix bug#8605196 ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
--|                                                          ER1 Support discount lines
--|                                                          ER2 Support customer name,address,bank info in Chinese
--|                        04-08-2009 Yao Zhang fix bug#8756943 TRANSFER AND CONSOLIDATION LOGIC FOR CREDIT MEMO WITH DISCOUNT LINES .
--|                        28-10-2009 Yao Zhang fix bug#9045187 CREDIT MEMO WITH DISCOUNT TRANSFER AMOUNT LIMIT ISSUE
--|                        12-Mar-2009 Yao Zhang Fix bug#9398467 LENGTH OF DISCOUNT TAX AMOUNT IN GTA WORKBENCH IS OVER SIZE
--+===========================================================================

--=============================================================================
--  PROCEDURE NAME:
--         log
--  TYPE:
--         private
--
--  DESCRIPTION :
--         This procedure log message
--  PARAMETERS    :
--                p_level   IN VARCHAR2
--                p_module  IN VARCHAR2
--                p_message IN VARCHAR2
--
-- HISTORY:
--            10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE log
(p_level   IN VARCHAR2
,p_module  IN VARCHAR2
,p_message IN VARCHAR2)
IS
BEGIN

  IF(p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(LOG_LEVEL => p_level
                  ,MODULE    => p_module
                  ,MESSAGE   => p_message
                );
  END IF;

END;

--=============================================================================
--  PROCEDURE NAME:
--         split_Transactions
--  TYPE:
--         PUBLIC
--
--  DESCRIPTION :
--         This procedure returns slpited tracsation by max_amount, max_lines
--  PARAMETERS    :
--                P_ORG_ID           IN        org_id
--                p_transfer_id      IN        the transfer rule
--                P_GTA_TRX_Tbl      IN        a trx nested table as input
--                x_GTA_TRX_Tbl      OUT       a trx nestedt tabel as output
--
-- HISTORY:
--            10-MAY-2005 : Jim.Zheng  Create
--            16-Jun-2009   Yao Zhang fix bug 8605196 Modified
--            04-Aug-2009   Yao Zhang fix bug#8756943 Modified
--            12-Mar-2009  Yao Zhang  Fix bug#9398467 Modified
--=============================================================================
PROCEDURE Split_Transactions
( P_ORG_ID	                IN	        NUMBER
, p_transfer_id             IN          NUMBER
, P_GTA_TRX_Tbl	            IN	        AR_GTA_TRX_UTIL.TRX_TBL_TYPE
, x_GTA_TRX_Tbl	            OUT NOCOPY	AR_GTA_TRX_UTIL.TRX_TBL_TYPE
)
IS
l_procedure_name VARCHAR2(30):='Split_Transactions';

--parameter for splite max_lines and max_amount;
l_sum_of_amount          NUMBER := 0;
l_lines_number           NUMBER;
l_processing_row         NUMBER;    -- a process number when split the trx ( this split action is loop by line )
l_accumulated_amount     NUMBER;    -- amount of the trx
l_amount                 NUMBER;

--get from option table,this four variable is the split codition
l_max_amount             NUMBER;
l_max_line               NUMBER;
l_sales_list_flag        ar_gta_rule_headers_all.Sales_List_Flag%TYPE;
l_split_flag             ar_gta_system_parameters.Trx_Line_Split_Flag%TYPE;

l_GTA_TRX                AR_GTA_TRX_UTIL.trx_rec_type;    -- trx get from input parameter
l_gta_trx_succesed       AR_GTA_TRX_UTIL.trx_rec_type;    -- trx for insert into temp table for report
l_gta_trx_init           AR_GTA_TRX_UTIL.trx_rec_type;    -- trx for init

-- use when split a trx line
l_GTA_Trx_line_old       AR_GTA_TRX_UTIL.trx_line_rec_type;
l_GTA_TRX_line_new       AR_GTA_TRX_UTIL.trx_line_rec_type;
l_gta_trx_line_init      AR_GTA_TRX_UTIL.trx_line_rec_type;

-- use when split a new trx
l_GTA_Trx_new            AR_GTA_TRX_UTIL.trx_rec_type;
l_gta_trx_new_succ       AR_Gta_Trx_Util.trx_rec_type;
l_trx_lines_new          AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
l_trx_header_new         AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;


-- use by split trx by tax rate and fp registration number
l_gta_rate_trx_tbl       AR_GTA_TRX_UTIL.TRX_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();
l_gta_taxreg_trx_tbl     AR_GTA_TRX_UTIL.TRX_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();

l_quantity_limit         NUMBER;

l_trx_lines              AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();

l_trx_index              NUMBER;  -- loop index of l_gta_trx
l_trx_rate_index         NUMBER;  -- loop index of l_gta_rate_trx
l_trx_line_index         NUMBER;  -- loop index of trx lines
l_result                 BOOLEAN;

l_trx_type               ra_cust_trx_types_all.type%TYPE;
l_fp_reg_num             ar_gta_trx_headers_all.fp_tax_registration_number%TYPE;

l_trx_group_number       NUMBER;

l_functional_price       ar_gta_trx_lines_all.unit_price%TYPE;  --25-Apr-2006: Jogen Hu  bug 5168852

--Yao add for bug#8605196 to support discount line
l_discount_line_number   NUMBER;--discount line number for the transaction
l_discount_row           NUMBER;--count the discount line which will be printed on VAT invoice
l_actual_amount          NUMBER;--transaction amount with discount amount
l_actual_unit_price      NUMBER;


BEGIN

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'Begin Split_trx');


  END IF;
  -- init all nested table
  l_trx_lines_new    := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
  l_trx_lines        := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
  l_gta_trx_new.trx_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
  l_gta_rate_trx_tbl := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();
  x_GTA_TRX_Tbl      := AR_GTA_TRX_UTIL.TRX_TBL_TYPE();

  --begin select max amount, max number of lines and  sales list flag
  BEGIN
    SELECT
      TRX_LINE_SPLIT_FLAG
    INTO
      l_split_flag
    FROM
      AR_GTA_SYSTEM_PARAMETERS_all
    WHERE org_id = p_org_id;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    --fnd_file.put_line(fnd_file.LOG, 'l_split_flag:'||l_split_flag);
    log(FND_LOG.LEVEL_PROCEDURE
          , G_MODULE_PREFIX || l_procedure_name
          , 'l_split_flag:'||l_split_flag);
  END IF;
  -- end log

  EXCEPTION
    -- no data found , raise a data error
    WHEN no_data_found THEN
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , 'no data found');

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , fnd_message.get());

       END IF;
       RAISE;
       RETURN;
  END;

  BEGIN
    SELECT
      sales_list_flag
    INTO
      l_sales_list_flag
    FROM
      AR_GTA_RULE_HEADERS_All
    WHERE org_id = p_org_id
      AND rule_header_id = p_transfer_id;
  EXCEPTION
    -- no data found , raise a data error
    WHEN no_data_found THEN
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , 'no data found');

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , fnd_message.get());

       END IF;
       RAISE;
       RETURN;
  END;


  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_sales_list_flag:'||l_sales_list_flag);
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'begin split_trx_loop......');
  END IF;
  -- end log



  -- begin  split trx
  l_trx_index := P_GTA_TRX_Tbl.FIRST;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_trx_index......'||l_trx_index);
  END IF;
  -- end log


  WHILE l_trx_index IS NOT NULL
  LOOP

    l_gta_trx_succesed := P_GTA_TRX_Tbl(l_trx_index);


    l_GTA_TRx := P_GTA_TRX_tbl(l_trx_index);

    -- init trx group number
    l_trx_group_number := 1;

    -- begin split by tax registration number
    split_trx_by_taxreg_number(p_gta_trx   => l_GTA_TRX
                               , x_TRX_Tbl => l_gta_taxreg_trx_tbl);
    -- end split by tax registration number

    -- begin log
    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'End Split_trx_by_taxreg_number:'||l_gta_taxreg_trx_tbl.COUNT);
    END IF;
    -- end log

    -- begin split by tax rate
    split_trx_by_rate(p_gta_tbl   => l_gta_taxreg_trx_tbl
                      ,x_trx_tbl  => l_gta_rate_trx_tbl
                     );
    -- end split by tax rate


    -- begin log
    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'End split_trx_by_rate:'||l_gta_rate_trx_tbl.COUNT);
    END IF;
    -- end log

    -- loop by a new trx nested table which split by rate
    l_trx_rate_index := l_gta_rate_trx_tbl.FIRST;
    WHILE l_trx_rate_index IS NOT NULL
    LOOP
      -- use l_gta_trx again
      -- now we get a new trx of single rate
      l_GTA_TRX := l_gta_rate_trx_tbl(l_trx_rate_index);

      -- get trx type
      get_trx_type(p_org_id     => p_org_id
                  , p_gta_trx   => l_GTA_TRX
                  , x_trx_type  => l_trx_type);


      -- begin log
      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_trx_rate_index:'||l_trx_rate_index);
        log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'End get_trx_type:'||l_trx_type);
      END IF;
      -- end log

      -- IS CM ?\
     /* IF l_trx_type = 'CM'
      THEN
        -- judge the CM can fit the max amount and the max line counts
        judge_cm_limit(p_gta_trx     =>  l_gta_trx
                      , p_org_id     =>  p_org_id
                      , x_result     =>  l_result);
        IF l_result
        THEN
          -- add this l_gta_trx into the result table
          l_gta_trx.trx_header.group_number := l_trx_group_number;
          l_trx_group_number := l_trx_group_number + 1;
          process_before_split( x_gta_trx_rec  => l_GTA_TRX
                              );
          x_GTA_TRX_Tbl.EXTEND;
          x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx;
        ELSE
          NULL;
          -- throw exception
        END IF;

      ELSE --l_trx_type = 'CM'*/
        -- get max_amount and max_line_count
    --Yao Zhang add for credit memo with discount lines exceed max line number should be transfered
    --without split Fix bug#8756943
     IF l_trx_type = 'CM'
     THEN
          l_gta_trx.trx_header.group_number := l_trx_group_number;
          l_trx_group_number := l_trx_group_number + 1;
          process_before_split( x_gta_trx_rec  => l_GTA_TRX
                              );
          x_GTA_TRX_Tbl.EXTEND;
          x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx;
     ELSE
     --Yao Zhang add end
        get_max_amount_line(p_gta_trx        => l_gta_trx
                            , p_org_id       => P_ORG_ID
                            , x_max_amount   => l_max_amount
                            , x_max_line     => l_max_line
                           );

        -- begin log
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'get_max_amount_line');
          log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_max_amount:'||l_max_amount);
          log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_max_line:'||l_max_line);
        END IF;
        -- end log
        --The following code is Modifie by Yao for bug#8605196 to support discount line
        -- get lines number and amount
        l_trx_line_index := l_gta_trx.trx_lines.FIRST;
        WHILE l_trx_line_index IS NOT NULL
        LOOP
          l_sum_of_amount := l_sum_of_amount + l_GTA_TRX.trx_lines(l_trx_line_index).amount
                             +nvl(l_GTA_TRX.trx_lines(l_trx_line_index).discount_amount,0);
          IF l_GTA_TRX.trx_lines(l_trx_line_index).discount_flag='1'
          Then
          l_discount_line_number:=nvl(l_discount_line_number,0)+1;
          END IF;/*l_GTA_TRX.trx_lines(l_trx_line_index).discount_flag='1'*/
           --Yao Zhang add end to support discount line number
          l_trx_line_index := l_gta_trx.trx_lines.NEXT(l_trx_line_index);
        END LOOP;
        l_lines_number := l_GTA_TRX.trx_lines.COUNT+nvl(l_discount_line_number,0);--Modified by Yao for bug#8605196
        -- if the trx is regular and don't need split, push it into rusult
        IF l_sum_of_amount<l_max_amount AND (l_lines_number<l_max_line OR l_sales_list_flag='Y' )
        THEN
          -- begin log
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_sum_of_amount<l_max_amount AND (l_lines_number<l_max_line OR l_sales_list_flag=''Y'' )');
          END IF;
          -- end log

          -- insert trx into result table
          l_gta_trx.trx_header.group_number := l_trx_group_number;
          l_trx_group_number := l_trx_group_number + 1;
          process_before_split( x_gta_trx_rec  => l_GTA_TRX
                              );
          x_GTA_TRX_Tbl.EXTEND;
          x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx;
        ELSE /*l_sum_of_amount<l_max_amount AND (l_lines_number<l_max_line OR l_sales_list_flag='Y' )*/

          -- init the l_processing_row and l_accumulated_amount
          l_processing_row:=1;
          l_accumulated_amount:=0;
          l_discount_row:=0;--Yao add for bug#8605196

          WHILE (l_processing_row<=l_GTA_TRX.trx_lines.COUNT)
          LOOP
            -- init l_gta_trx_line_old
            l_gta_trx_line_old := l_gta_trx_line_init;
            l_gta_trx_new      := l_gta_trx_init;
            l_gta_trx_new_succ := l_gta_trx_init;
            l_trx_lines_new    := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
            l_GTA_TRX_line_old :=l_GTA_TRX.trx_lines(l_processing_row);
            l_amount:=l_GTA_TRX_line_old.amount;
            l_actual_amount:=l_GTA_TRX_line_old.amount+nvl(l_GTA_TRX_line_old.discount_amount,0);
            l_actual_unit_price:=(l_GTA_TRX_line_old.amount+nvl(l_GTA_TRX_line_old.discount_amount,0))/l_GTA_TRX_line_old.quantity;
            IF l_GTA_TRX_line_old.discount_flag='1'
            THEN
            l_discount_row:=l_discount_row+1;
            END IF;/*l_GTA_TRX_line_old.discount_flag='1'*/
            -- 25-Apr-2006: Jogen Hu  bug 5168852
            --the following code is changed by Yao for bug 9398467
            -- 13-Jul-2009: Allen Yang modified for bug 8619860
            --------------------------------------------------------------------------
            --l_functional_price:=l_GTA_TRX_line_old.amount/l_GTA_TRX_line_old.quantity;
            --l_functional_price:= round(l_GTA_TRX_line_old.amount/l_GTA_TRX_line_old.quantity, 2);
            l_functional_price:= round(l_GTA_TRX_line_old.amount/l_GTA_TRX_line_old.quantity, 6);
            --------------------------------------------------------------------------

            -- begin log
            IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
              log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name
               , 'l_functional_price:'||l_functional_price);
            END IF;
            -- end log
            -- 25-Apr-2006: Jogen Hu  bug 5168852

            l_accumulated_amount := l_accumulated_amount + nvl( l_actual_amount, 0);
            IF l_accumulated_amount <= l_max_amount AND l_processing_row+l_discount_row </*=*/ l_max_line
            THEN

              -- begin log
              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_accumulated_amount <= l_max_amount AND l_processing_row </*=*/ l_max_line');
              END IF;
              -- end log

              IF l_processing_row = l_GTA_TRX.trx_lines.COUNT
              THEN
                -- now this can due to the same condition at
                l_gta_trx.trx_header.group_number := l_trx_group_number;
                l_trx_group_number := l_trx_group_number + 1;
                process_before_split(x_gta_trx_rec   => l_GTA_TRX
                                    );
                x_GTA_TRX_Tbl.EXTEND;
                x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_TRX;

                -- else goto end loop and due to next line
              END IF;  -- end if l_processing_row = l_GTA_TRX.trx_lines.COUNT

              -- > line < amount and sales 'N', split by line
            ELSIF l_processing_row+l_discount_row >= l_max_line AND l_sales_list_flag = 'Y' AND l_accumulated_amount <= l_max_amount
            THEN

              -- begin log
              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_processing_row >= l_max_line AND l_sales_list_flag = ''Y'' AND l_accumulated_amount <= l_max_amount');
              END IF;
              -- end log

              IF l_processing_row = l_GTA_TRX.trx_lines.COUNT
              THEN
                l_gta_trx.trx_header.group_number := l_trx_group_number;
                l_trx_group_number := l_trx_group_number + 1;
                process_before_split(x_gta_trx_rec   => l_GTA_TRX
                                    );
                x_GTA_TRX_Tbl.EXTEND;
                x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_TRX;

              -- ELSE goto end loop and due to next line
              END IF;/*end if l_processing_row = l_GTA_TRX.trx_lines.COUNT*/

            ELSIF l_processing_row+l_discount_row = l_max_line AND  l_sales_list_flag = 'N' AND l_accumulated_amount <= l_max_amount
            THEN
              IF l_processing_row = l_GTA_TRX.trx_lines.COUNT
              THEN
                l_gta_trx.trx_header.group_number := l_trx_group_number;
                l_trx_group_number := l_trx_group_number + 1;
                process_before_split(x_gta_trx_rec    => l_GTA_TRX
                                    );

                x_GTA_TRX_Tbl.EXTEND;
                x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_TRX;



              ELSE /*l_processing_row  < l_GTA_TRX.trx_lines.COUNT */

                 split_nested_table(p_trx_lines                    => l_gta_trx.trx_lines
                                    , p_split_flag                 => l_processing_row
                                    , x_first_lines                => l_trx_lines_new
                                    , x_last_lines                 => l_trx_lines
                                    );

                  -- copy trx header
                  copy_header(p_GTA_TRX_Header_Rec                 => l_GTA_TRX.trx_header
                              , x_GTA_TRX_Header_Rec               => l_trx_header_new
                              );


                  -- get new trx number
                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_gta_trx_new.trx_lines  := l_trx_lines_new;

                  -- add new trx to result tbl
                  l_GTA_Trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec                => l_GTA_TRX_new
                                      );

                  x_GTA_TRX_Tbl.EXTEND;
                  x_gta_trx_tbl(x_gta_trx_tbl.COUNT) := l_gta_trx_new;
                  --add_succ_to_temp(l_GTA_TRX);

                  -- update the header , replace the l_gta_trx header by new header
                  l_GTA_TRX.trx_header := l_trx_header_new;

                  -- update the old trx.trx_lines
                  l_GTA_TRX.trx_lines := l_trx_lines;

                  -- init l_processing_row and l_accumulateed_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;
                  l_discount_row:=0;

              END IF;  /*l_processing_row  < l_GTA_TRX.trx_lines.COUNT */
--The following code is added by Yao Zhang for bug#8605196 to support discount line
            ELSIF l_processing_row+l_discount_row = l_max_line+1 AND  l_sales_list_flag = 'N' AND l_accumulated_amount <= l_max_amount
            THEN
               /*l_processing_row  < l_GTA_TRX.trx_lines.COUNT */

                 split_nested_table(p_trx_lines                    => l_gta_trx.trx_lines
                                    , p_split_flag                 => l_processing_row-1
                                    , x_first_lines                => l_trx_lines_new
                                    , x_last_lines                 => l_trx_lines
                                    );

                  -- copy trx header
                  copy_header(p_GTA_TRX_Header_Rec                 => l_GTA_TRX.trx_header
                              , x_GTA_TRX_Header_Rec               => l_trx_header_new
                              );


                  -- get new trx number
                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_gta_trx_new.trx_lines  := l_trx_lines_new;

                  -- add new trx to result tbl
                  l_GTA_Trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec                => l_GTA_TRX_new
                                      );

                  x_GTA_TRX_Tbl.EXTEND;
                  x_gta_trx_tbl(x_gta_trx_tbl.COUNT) := l_gta_trx_new;
                  --add_succ_to_temp(l_GTA_TRX);
                  -- update the header , replace the l_gta_trx header by new header
                  l_GTA_TRX.trx_header := l_trx_header_new;
                  -- update the old trx.trx_lines
                  l_GTA_TRX.trx_lines := l_trx_lines;
                  -- init l_processing_row and l_accumulateed_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;
                  l_discount_row:=0;
--The above code is added by Yao Zhang for bug#8605196 to support discount line
            /*This condition include the l_process_number > max_line, l_procecss_number = max_line, l_process_number < max_line,
             * due to this three condition the process is same, split by amount.
             */
            ELSIF l_accumulated_amount > l_max_amount
            THEN
              -- begin log
              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_accumulated_amount > l_max_amount');
              END IF;
              -- end log

              l_trx_lines  :=  l_GTA_TRX.trx_lines;

              IF l_split_flag = 'Y'
              THEN
                IF l_gta_trx.trx_lines.COUNT = 1
                THEN
                  l_GTA_Trx_line_old := l_GTA_TRX.trx_lines(l_processing_row);
                  l_GTA_TRX_line_new := l_GTA_Trx_line_old;
                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  /*l_quantity_limit:=
                    floor((l_max_amount - l_accumulated_amount + l_GTA_Trx_line_old.amount)/l_GTA_Trx_line_old.unit_price);*/
                  l_quantity_limit:=floor((l_max_amount-l_accumulated_amount+l_actual_amount)/l_actual_unit_price  );
                  IF l_quantity_limit > 0
                  THEN
                    l_GTA_TRX_line_new.quantity := l_quantity_limit;

                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_GTA_TRX_line_new.unit_price;
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_functional_price;
                    --Yao modified for bug 9369455
                    l_GTA_TRX_line_new.amount   := round(l_quantity_limit * l_functional_price,2);
                    --The following code is changed by Yao for bug 9398467

                    /*l_gta_trx_line_new.discount_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;--Yao add for bug#8605196
                    l_gta_trx_line_new.discount_tax_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;--Yao add for bug#8605196*/

                    l_gta_trx_line_new.discount_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                    l_gta_trx_line_new.discount_tax_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);
                    --Yao modified end for bug 9398467

                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    -- it should be change after ebtax!!!
                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    --l_GTA_TRX_line_new.tax_amount := l_GTA_TRX_line_new.tax_rate*(l_quantity_limit * l_GTA_TRX_line_new.unit_price);
                    l_GTA_TRX_line_new.tax_amount := round(l_GTA_TRX_line_new.tax_rate*(l_quantity_limit * l_functional_price),2);
                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    l_gta_trx_line_new.original_currency_amount := l_quantity_limit * l_GTA_TRX_line_new.unit_price;

                    SELECT
                      AR_GTA_TRX_LINES_ALL_S.NEXTVAL
                    INTO
                      l_GTA_TRX_line_new.GTA_TRX_LINE_ID
                    FROM
                      dual;

                    --l_GTA_TRX_line_new.GTA_TRX_LINE_ID := AR_GTA_TRX_LINES_ALL_S.NEXTVAL;
                    l_trx_lines_new.EXTEND;
                    l_trx_lines_new(l_trx_lines_new.COUNT) := l_GTA_TRX_line_new;
                  -- ELSE l_quantity_limit =0 , then the old line is no change and new line is not needed
                  END IF;/*l_quantity_limit > 0*/



                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  --l_GTA_TRX_line_old.amount   := l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  l_GTA_TRX_line_old.amount:=
                                              l_amount - round(l_quantity_limit*l_functional_price,2);--round for bug
                  --the following code is changed by Yao for bug#9398467

                  --Yao add for bug#8605196
                  /*l_gta_trx_line_old.discount_amount:=
                            l_GTA_TRX_line_old.discount_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;
                  --Yao add for bug#8605196
                  l_gta_trx_line_old.discount_tax_amount:=
                            l_GTA_TRX_line_old.discount_tax_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;*/

                  l_gta_trx_line_old.discount_amount:=l_GTA_TRX_line_old.discount_amount-
                                                      round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                  l_gta_trx_line_old.discount_tax_amount:=l_GTA_TRX_line_old.discount_tax_amount-
                                                         round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);
                  --Yao changed end for bug#9398467
                  --l_GTA_Trx_line_old.tax_amount := l_GTA_Trx_line_old.tax_rate*(l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price);
                  l_GTA_Trx_line_old.tax_amount := round(l_GTA_Trx_line_old.tax_rate*(l_amount - l_quantity_limit*l_functional_price),2);
                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  l_GTA_TRX_line_old.quantity := l_GTA_Trx_line_old.quantity - l_quantity_limit;
                  l_GTA_Trx_line_old.original_currency_amount := l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  -- insert old line to the head of l_trx_lines
                  l_trx_lines(1) := l_GTA_Trx_line_old;
                  -- new trx
                  copy_header(p_GTA_TRX_Header_Rec   => l_GTA_TRX.trx_header
                             , x_GTA_TRX_Header_Rec  => l_trx_header_new
                             );

                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_GTA_Trx_new.trx_lines  := l_trx_lines_new;

                  -- add the new trx to result table
                  l_gta_trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec     => l_GTA_TRX_new
                                      );
                  x_GTA_TRX_Tbl.EXTEND;
                  x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx_new;
                  --add_succ_to_temp(l_GTA_TRX);
                  -- update the header of old trx
                  l_gta_trx.trx_header := l_trx_header_new;
                  -- update the lines of old trx
                  l_GTA_TRX.trx_lines := l_trx_lines;

                  -- init the l_processing_row and l_accumulated_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;
                  l_discount_row:=0;--Yao add for bug#8605196

                ELSE /*l_gta_trx.trx_lines.COUNT = 1*/

                  -- split trx lines exclude the last line
                  split_nested_table(p_trx_lines      => l_GTA_TRX.trx_lines
                                     , p_split_flag   => l_processing_row - 1
                                     , x_first_lines  => l_trx_lines_new
                                     , x_last_lines   => l_trx_lines
                                    );

                  -- split line to new line and old line
                  l_GTA_Trx_line_old := l_GTA_TRX.trx_lines(l_processing_row);
                  l_GTA_TRX_line_new := l_GTA_Trx_line_old;

                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  /*l_quantity_limit:=
                    floor((l_max_amount - l_accumulated_amount + l_GTA_Trx_line_old.amount)/l_GTA_Trx_line_old.unit_price);*/

                l_quantity_limit:=floor((l_max_amount-l_accumulated_amount+l_actual_amount)/l_actual_unit_price  ) ;
                  -- 25-Apr-2006: Jogen Hu  bug 5168852

                  IF l_quantity_limit > 0
                  THEN
                    l_GTA_TRX_line_new.quantity := l_quantity_limit;

                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_GTA_TRX_line_new.unit_price;
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_functional_price;
                    --Yao modified for bug 9369455
                    l_GTA_TRX_line_new.amount   := round(l_quantity_limit * l_functional_price,2);
                   --the following code is changed by Yao for bug 9398467
                    /*--Yao add for bug#8605196
                    l_gta_trx_line_new.discount_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;--Yao add for bug#8605196
                    l_gta_trx_line_new.discount_tax_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;--Yao add for bug#8605196*/

                    l_gta_trx_line_new.discount_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                    l_gta_trx_line_new.discount_tax_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);
                    --Yao modified end for bug 9398467

                    --l_GTA_TRX_line_new.tax_amount := l_GTA_TRX_line_new.tax_rate * (l_quantity_limit * l_GTA_TRX_line_new.unit_price);
                    l_GTA_TRX_line_new.tax_amount := round(l_GTA_TRX_line_new.tax_rate * (l_quantity_limit * l_functional_price),2);
                    -- 25-Apr-2006: Jogen Hu  bug 5168852
                    l_GTA_TRX_line_new.original_currency_amount := l_quantity_limit * l_GTA_TRX_line_new.unit_price;
                    SELECT
                      AR_GTA_TRX_LINES_ALL_S.NEXTVAL
                    INTO
                      l_GTA_TRX_line_new.GTA_TRX_LINE_ID
                    FROM
                      dual;
                    --l_GTA_TRX_line_new.GTA_TRX_LINE_ID := AR_GTA_TRX_LINES_ALL_S.NEXTVAL;
                    l_trx_lines_new.EXTEND;
                    l_trx_lines_new(l_trx_lines_new.COUNT) := l_GTA_TRX_line_new;
                  -- ELSE l_quantity_limit =0 , then the old line is no change and new line is not needed
                  END IF;/*l_quantity_limit > 0*/
                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  --l_GTA_TRX_line_old.amount:=l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  l_GTA_TRX_line_old.amount:=l_amount - round(l_quantity_limit*l_functional_price,2);--round for bug 9369455

                  --the following code is changed by Yao for bug#9398467
                 /* --Yao add for bug#8605196
                  l_gta_trx_line_old.discount_amount:=
                  l_GTA_TRX_line_old.discount_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;
                  --Yao add for bug#8605196
                  l_gta_trx_line_old.discount_tax_amount:=
                            l_GTA_TRX_line_old.discount_tax_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;*/
                  l_gta_trx_line_old.discount_amount:=l_GTA_TRX_line_old.discount_amount-
                                                      round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                  l_gta_trx_line_old.discount_tax_amount:=l_GTA_TRX_line_old.discount_tax_amount-
                                                      round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);

                  --Yao changed end for bug#9398467
                  --l_GTA_Trx_line_old.tax_amount := l_GTA_Trx_line_old.tax_rate * (l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price);
                  l_GTA_Trx_line_old.tax_amount := round(l_GTA_Trx_line_old.tax_rate * (l_amount - l_quantity_limit*l_functional_price),2);--round for bug 9369455
                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  l_GTA_TRX_line_old.quantity:=l_GTA_Trx_line_old.quantity - l_quantity_limit;
                  l_GTA_Trx_line_old.original_currency_amount := l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  -- insert old line to the head of l_trx_lines
                  l_trx_lines(1) := l_GTA_Trx_line_old;
                  -- new trx
                  copy_header(p_GTA_TRX_Header_Rec   => l_GTA_TRX.trx_header
                             , x_GTA_TRX_Header_Rec  => l_trx_header_new);

                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_GTA_Trx_new.trx_lines  := l_trx_lines_new;

                  -- add the new trx to result table
                  l_GTA_Trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec     => l_GTA_TRX_new
                                      );
                  x_GTA_TRX_Tbl.EXTEND;
                  x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx_new;
                  --add_succ_to_temp(l_GTA_TRX);

                  -- update the header of old trx
                  l_gta_trx.trx_header := l_trx_header_new;
                  -- update the lines of old trx
                  l_GTA_TRX.trx_lines := l_trx_lines;

                  -- init the l_processing_row and l_accumulated_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;
                  l_discount_row:=0;--Yao add for bug#8605196

                END IF ; /*l_gta_trx.trx_lines.COUNT = 1*/

              ELSE /* l_split_flag = 'N' */
                IF l_processing_row = 1
                THEN
                  split_nested_table(p_trx_lines    =>  l_GTA_TRX.trx_lines
                                    , p_split_flag  =>  l_processing_row -1
                                    , x_first_lines =>  l_trx_lines_new
                                    , x_last_lines  =>  l_trx_lines);

                  -- split this line
                  l_GTA_Trx_line_old := l_GTA_TRX.trx_lines(l_processing_row);
                  l_GTA_TRX_line_new := l_GTA_Trx_line_old;

                  -- get quantity limit
                   -- 25-Apr-2006: Jogen Hu  bug 5168852
                 /* l_quantity_limit:=
                    floor((l_max_amount - l_accumulated_amount + l_GTA_Trx_line_old.amount)/l_GTA_Trx_line_old.unit_price);*/
                    l_quantity_limit:=floor((l_max_amount-l_accumulated_amount+l_actual_amount)/l_actual_unit_price  ) ;
                 -- 25-Apr-2006: Jogen Hu  bug 5168852

                  IF l_quantity_limit > 0
                  THEN
                    l_GTA_TRX_line_new.quantity := l_quantity_limit;

                   -- 25-Apr-2006: Jogen Hu  bug 5168852
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_GTA_TRX_line_new.unit_price;
                    --l_GTA_TRX_line_new.amount   := l_quantity_limit * l_functional_price;
                    --Yao modified for bug 9369455
                    l_GTA_TRX_line_new.amount   := round(l_quantity_limit * l_functional_price,2);
                    --the following code is changed by Yao for bug9398467
                   /* --Yao add for bug#8605196
                    l_gta_trx_line_new.discount_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;--Yao add for bug#8605196
                    --Yao add for bug#8605196
                    l_gta_trx_line_new.discount_tax_amount:=
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;--Yao add for bug#8605196*/

                     l_gta_trx_line_new.discount_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                    l_gta_trx_line_new.discount_tax_amount:=round(
                    (l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);
                    --Yao modified end for bug 9398467

                    --l_gta_trx_line_new.tax_amount := l_gta_trx_line_new.tax_rate * (l_quantity_limit * l_GTA_TRX_line_new.unit_price);
                    l_gta_trx_line_new.tax_amount := round(l_gta_trx_line_new.tax_rate * (l_quantity_limit * l_functional_price),2);
                   -- 25-Apr-2006: Jogen Hu  bug 5168852

                    l_gta_trx_line_new.original_currency_amount := l_quantity_limit * l_GTA_TRX_line_new.unit_price;
                    SELECT
                      AR_GTA_TRX_LINES_ALL_S.NEXTVAL
                    INTO
                      l_GTA_TRX_line_new.GTA_TRX_LINE_ID
                    FROM
                      dual;
                    --l_GTA_TRX_line_new.GTA_TRX_LINE_ID := AR_GTA_TRX_LINES_ALL_S.NEXTVAL;
                    l_trx_lines_new.EXTEND;
                    l_trx_lines_new(l_trx_lines_new.COUNT) := l_GTA_TRX_line_new;
                  -- ELSE l_quantity_limit =0 , then the old line is no change and new line is not needed
                  END IF;/*l_quantity_limit > 0*/


                   -- 25-Apr-2006: Jogen Hu  bug 5168852
                  --l_GTA_TRX_line_old.amount:=l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  l_GTA_TRX_line_old.amount:=l_amount - round(l_quantity_limit*l_functional_price,2);--round for bug 9369455
                  --the following code is changed by Yao for bug#9398467
                  /*--Yao add for bug#8605196
                  l_gta_trx_line_old.discount_amount:=
                            l_GTA_TRX_line_old.discount_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount;
                  --Yao add for bug#8605196
                  l_gta_trx_line_old.discount_tax_amount:=
                            l_GTA_TRX_line_old.discount_tax_amount-(l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount;*/
                  l_gta_trx_line_old.discount_amount:=l_GTA_TRX_line_old.discount_amount-
                                                      round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_amount,2);
                  l_gta_trx_line_old.discount_tax_amount:=l_GTA_TRX_line_old.discount_tax_amount-
                                                      round((l_quantity_limit/l_GTA_Trx_line_old.quantity)*l_GTA_TRX_line_old.discount_tax_amount,2);
                  --Yao changed end for bug#9398467
                  --l_GTA_Trx_line_old.tax_amount := l_GTA_Trx_line_old.tax_rate * (l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price);
                  l_GTA_Trx_line_old.tax_amount := round(l_GTA_Trx_line_old.tax_rate * (l_amount - l_quantity_limit*l_functional_price),2);
                  -- 25-Apr-2006: Jogen Hu  bug 5168852
                  l_GTA_TRX_line_old.quantity:=l_GTA_Trx_line_old.quantity - l_quantity_limit;
                  l_GTA_TRX_line_old.original_currency_amount:= l_amount - l_quantity_limit*l_GTA_Trx_line_old.unit_price;
                  -- insert old line to the head of l_trx_lines
                  l_trx_lines(1) := l_GTA_Trx_line_old;
                  -- new trx
                  copy_header(p_GTA_TRX_Header_Rec   => l_GTA_TRX.trx_header
                             , x_GTA_TRX_Header_Rec  => l_trx_header_new);

                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_GTA_Trx_new.trx_lines  := l_trx_lines_new;

                  -- add the new trx to result table
                  l_gta_trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec     => l_GTA_TRX_new
                                      );
                  x_GTA_TRX_Tbl.EXTEND;
                  x_GTA_TRX_Tbl(x_GTA_TRX_Tbl.COUNT) := l_GTA_Trx_new;
                  --add_succ_to_temp(l_GTA_TRX);

                  -- update the header of old trx
                  l_gta_trx.trx_header := l_trx_header_new;
                  -- update the lines of old trx
                  l_GTA_TRX.trx_lines := l_trx_lines;

                  -- init the l_processing_row and l_accumulated_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;

                ELSE /*l_gta_trx.trx_lines.COUNT = 1*/
                  split_nested_table(p_trx_lines    =>  l_GTA_TRX.trx_lines
                                    , p_split_flag  =>  l_processing_row -1
                                    , x_first_lines =>  l_trx_lines_new
                                    , x_last_lines  =>  l_trx_lines);

                  -- copy trx header
                  copy_header(p_GTA_TRX_Header_Rec      => l_GTA_TRX.trx_header
                              , x_GTA_TRX_Header_Rec    => l_trx_header_new );

                  -- get new trx number
                  l_GTA_Trx_new.trx_header := l_GTA_TRX.trx_header;
                  l_gta_trx_new.trx_lines  := l_trx_lines_new;

                  -- add it to result tbl
                  l_gta_trx_new.trx_header.group_number := l_trx_group_number;
                  l_trx_group_number := l_trx_group_number + 1;
                  process_before_split(x_gta_trx_rec   => l_GTA_TRX_new
                                      );

                  x_GTA_TRX_Tbl.EXTEND;
                  x_gta_trx_tbl(x_gta_trx_tbl.COUNT) := l_gta_trx_new;

                  --update the header of olf trx
                  l_gta_trx.trx_header := l_trx_header_new;
                  -- update the old trx.trx_lines
                  l_GTA_TRX.trx_lines := l_trx_lines;

                  -- init l_processing_row and l_accumulateed_amount
                  l_processing_row := 0;
                  l_accumulated_amount := 0;
                  l_discount_row:=0;
                END IF;/*l_gta_trx.trx_lines.COUNT = 1*/
              END IF; --  end if l_split_flag = 'Y'
            --ELSE
               --l_processing_row = l_max_line AND  l_sales_list_flag = 'N' and l_accumulated_amount > l_max_amount
            END IF;  -- /*end if l_accumulated_amount <= l_max_amount AND l_processing_row<l_max_line*/
            l_processing_row := l_processing_row + 1;
          END LOOP;  --end loop by lines
        END IF; -- end if (l_sum_of_amount<l_max_amount AND (l_lines_number<l_max_line or l_sales_list_flag='Y' ))

     END IF;/*l_trx_type <> 'CM'*/

      --begin split the l_gta_trx
          l_trx_rate_index := l_gta_rate_trx_tbl.NEXT(l_trx_rate_index);
    END LOOP;   -- end loop of  l_gta_rate_trx_tbl /*l_trx_rate_index IS NOT NULL*/

    -- add the succesed infomation into the temp table

    add_succ_to_temp(l_gta_trx_succesed);
    l_trx_index := P_GTA_TRX_Tbl.NEXT(l_trx_index);

  END LOOP;  -- end loop by P_gta_trx_tbl /*l_trx_index IS NOT NULL*/

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END Split_Transactions;


--=============================================================================
-- PROCEDURE NAME :
--              Copy_Header
-- TYPE:
--              PUBLIC
--
-- DESCRIPTION:
--              When split trx procedure new a trx, new a trx_header for the new trx
-- PARAMETERS:
--              p_GTA_TRX_Header_Rec           IN        old trx_header
--              x_GTA_TRX_Header_Rec           OUT       new trx_header
--
-- HISTORY:
--              10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE Copy_Header
( p_GTA_TRX_Header_Rec IN AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
, x_GTA_TRX_Header_Rec OUT NOCOPY AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
) AS
l_procedure_name       VARCHAR2(30):= 'Copy_Header';
l_gta_header_id        ar_gta_trx_headers.gta_trx_header_id%TYPE;
l_gta_trx_header_rec   AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE;

BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  l_GTA_TRX_Header_Rec := p_GTA_TRX_Header_Rec;
  SELECT
    AR_GTA_TRX_HEADERS_ALL_S.NEXTVAL
  INTO
    l_GTA_TRX_Header_Rec.gta_trx_header_id
  FROM
    dual;
  --x_GTA_TRX_Header_Rec.gta_trx_header_id := AR_GTA_TRX_HEADERS_ALL_S.NEXTVAL;
  -- use this if is due to the trx first split and

  l_GTA_TRX_Header_Rec.group_number := p_GTA_TRX_Header_Rec.group_number + 1;

  l_GTA_TRX_Header_rec.gta_trx_number := l_GTA_TRX_Header_Rec.ra_trx_id
                                         || '-'
                                         || l_GTA_TRX_Header_Rec.group_number
                                         || '-'
                                         || l_GTA_TRX_Header_rec.version;

  x_GTA_TRX_Header_Rec := l_gta_trx_header_rec;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Copy_Header;

--=============================================================================
-- PROCEDURE NAME:
--           split_nested_table
-- TYPE:
--           PUBLIC
--
-- DESCRIPTION :
--                 a nested table hasn't a split method, this procedure make a
--                 split table method for TRX_Line_tbl_type
--                 be change.
-- PARAMETERS:
--   p_trx_lines           IN        source table
--   split_flag            IN        the position of table which be split
--   x_first_lines         OUT       first party of demanation table
--   x_last_lines          OUT       last party of demanation table
--
-- HISTORY:
--                 10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE Split_Nested_Table
(p_trx_lines                IN              AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
, p_split_flag                IN              NUMBER
, x_first_lines             OUT NOCOPY      AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
, x_last_lines              OUT NOCOPY      AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE
)
IS
l_first_lines      AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
l_last_lines       AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
l_index            NUMBER;
l_procedure_name   VARCHAR2(50):='Split_Nested_Table';

BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  --init
  x_first_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
  x_last_lines  := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();

  IF p_split_flag = 0
  THEN
    l_last_lines := p_trx_lines;
  ELSE
    l_first_lines.EXTEND(p_split_flag);

    l_index := l_first_lines.FIRST;
    WHILE l_index <= p_split_flag
    LOOP
      l_first_lines(l_index) := p_trx_lines(l_index);
      l_index := l_first_lines.NEXT(l_index);
    END LOOP;

    l_last_lines.EXTEND(p_trx_lines.COUNT - p_split_flag);

    l_index := l_last_lines.FIRST;
    WHILE l_index <= (p_trx_lines.COUNT - p_split_flag)
    LOOP
      l_last_lines(l_index) := p_trx_lines(l_index + p_split_flag);
      l_index := l_last_lines.NEXT(l_index);
    END LOOP;
  END IF;

  x_first_lines := l_first_lines;
  x_last_lines  := l_last_lines;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END split_nested_table;

--=============================================================================
-- PROCEDURE NAME:
--          process_before_split
-- TYPE:
--          PUBLIC
--
-- DESCRIPTION:
--          When split trx procedure new a trx, the line_num, trx_num, trx_header_id alse
--          be change.
-- PARAMETERS:
--   x_gta_trx_rec           IN OUT NOCOPY       new trx which line number is changed
--
-- HISTORY:
--          10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE process_before_split
(
 x_gta_trx_rec     IN OUT NOCOPY                AR_Gta_Trx_Util.TRX_REC_TYPE
)
AS

l_procedure_name   VARCHAR2(35) := 'get_trx_header_id';
l_index            NUMBER;  -- loop index

BEGIN

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  -- generate gta_trx_number
  x_GTA_TRX_rec.trx_header.gta_trx_number := x_GTA_TRX_Rec.trx_header.ra_trx_id
                                             || '-'
                                             || x_GTA_TRX_Rec.trx_header.group_number
                                             || '-'
                                             || x_GTA_TRX_Rec.trx_header.version;

  -- generate line number
  l_index := x_gta_trx_rec.trx_lines.FIRST;
  WHILE l_index IS NOT NULL
  LOOP
    SELECT
      AR_Gta_Trx_Lines_All_s.NEXTVAL
    INTO
      x_gta_trx_rec.trx_lines(l_index).gta_trx_line_id
    FROM
      dual;
    x_gta_trx_rec.trx_lines(l_index).line_number := to_char(l_index);
    x_gta_trx_rec.trx_lines(l_index).gta_trx_header_id := x_gta_trx_rec.trx_header.gta_trx_header_id;
    l_index := x_gta_trx_rec.trx_lines.NEXT(l_index);
  END LOOP;

  -- get fp registration number and tp registration number;
  --12/06/2006   Shujuan Yan  bug 5168900
  IF x_gta_trx_rec.trx_lines.FIRST IS NOT NULL
  THEN
  x_gta_trx_rec.trx_header.fp_tax_registration_number := x_gta_trx_rec.trx_lines(1).fp_tax_registration_number;
  x_gta_trx_rec.trx_header.tp_tax_registration_number := x_gta_trx_rec.trx_lines(1).tp_tax_registration_number;

--28/12/07 added by subba for R12.1


  x_gta_trx_rec.trx_header.invoice_type := ar_gta_trx_util.get_invoice_type(p_org_id =>  x_gta_trx_rec.trx_header.org_id
                                                       ,p_customer_trx_id=> x_gta_trx_rec.trx_header.ra_trx_id
                                                       ,p_fp_tax_registration_num => x_gta_trx_rec.trx_lines(1).fp_tax_registration_number);


  END IF;
  --12/06/2006   Shujuan Yan  bug 5168900

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END Process_Before_Split;


--=============================================================================
-- PROCEDURE NAME:
--          add_succ_to_temp
-- TYPE:
--          PUBLIC
--
-- DESCRIPTION :
--                 insert a sucess row to temp table when a trx is be due successed
--                 be change.
-- PARAMETERS:
--   p_gta_trx_rec         in   the successed trx
--
-- HISTORY:
--         10-MAY-2005 : Jim.Zheng  Create
--         15-Jan-2009:  Yao Zhang Modified for bug 7709947
--=============================================================================
PROCEDURE add_succ_to_temp
(
 p_gta_trx_rec   IN         AR_Gta_Trx_Util.TRX_REC_TYPE
)
AS
l_amount         NUMBER;
l_trx_num        VARCHAR2(30);
l_trx_type       VARCHAR2(30);
l_cust_name      VARCHAR2(360);--Yao Zhang changed for bug 7709947
l_gta_inv_num    VARCHAR2(30);

l_procedure_name        VARCHAR2(30) := 'add_succ_to_temp';
l_index                 NUMBER;  -- loop index
l_warning_record_count  NUMBER;
l_customer_trx_id       NUMBER(15);

BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

  l_amount := 0;

  l_index := p_gta_trx_rec.trx_lines.FIRST;
  WHILE l_index IS NOT NULL
  LOOP
    l_amount := l_amount + p_gta_trx_rec.trx_lines(l_index).amount;
    l_index := p_gta_trx_rec.trx_lines.NEXT(l_index);
  END LOOP;

  l_trx_num     := p_gta_trx_rec.trx_header.ra_trx_number;
  l_customer_trx_id := p_gta_trx_rec.trx_header.ra_trx_id;
  BEGIN
    SELECT
      ctt.TYPE
    INTO
      l_trx_type
    FROM
      ra_customer_trx_all h
      , ra_cust_trx_types_all ctt
    WHERE ctt.cust_trx_type_id = h.cust_trx_type_id
      AND ctt.Org_Id = h.Org_Id
      AND h.customer_trx_id = p_gta_trx_rec.trx_header.ra_trx_id;
  EXCEPTION
    WHEN no_data_found THEN
         IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                         , G_MODULE_PREFIX || l_procedure_name
                         ,'No data found. ');
         END IF;
  END;

  --l_trx_type := p_gta_trx_rec.trx_header.trx_type;
  l_cust_name   := p_gta_trx_rec.trx_header.bill_to_customer_name;
  l_gta_inv_num := p_gta_trx_rec.trx_header.gta_trx_number;
  SELECT
    COUNT(*)
  INTO
    l_warning_record_count
  FROM
    ar_gta_transfer_temp temp
  WHERE temp.transaction_id = l_customer_trx_id
    AND temp.succeeded = 'W';

  IF l_warning_record_count = 0
  THEN
    INSERT INTO
      ar_gta_transfer_temp t
      (t.seq
      , t.succeeded
      , t.transaction_id
      , t.transaction_num
      , t.transaction_type
      , t.customer_name
      , t.amount
      , t.failedreason
      , t.gta_invoice_num
      )
    SELECT
      ar_gta_transfer_temp_s.NEXTVAL
      , 'Y'
      , l_customer_trx_id
      , l_trx_num
      , l_trx_type
      , l_cust_name
      , l_amount
      , NULL
      , l_gta_inv_num
    FROM
      dual;
  ELSIF l_warning_record_count = 1
  THEN
    UPDATE
      ar_gta_transfer_temp temp
    SET
      temp.amount = l_amount
    WHERE temp.transaction_id = l_customer_trx_id
      AND temp.succeeded = 'W';

  END IF;/*l_warning_record_count = 0*/


  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END add_succ_to_temp;


--=============================================================================
-- PROCEDURE NAME:
--                split_trx_by_taxreg_number
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 split trx by first party registration number
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_rec_type
--   x_trx_tbl         out  AR_Gta_Trx_Util.trx_tbl_type
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_trx_by_taxreg_number
(p_gta_trx       IN               AR_GTA_TRX_UTIL.trx_rec_type
,x_trx_tbl       OUT NOCOPY       AR_Gta_Trx_Util.trx_tbl_type
)
IS
l_procedure_name         VARCHAR2(100) := 'split_trx_by_tax_registration_number';
l_gta_rate_trx_line      AR_GTA_TRX_UTIL.trx_line_rec_type;
l_gta_rate_trx           AR_GTA_TRX_UTIL.trx_rec_type;
l_gta_rate_trx_tbl       AR_GTA_TRX_UTIL.TRX_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();
l_tax_reg_number         ar_gta_trx_headers_all.fp_tax_registration_number%TYPE;
l_add_flag               NUMBER := 0;
l_gta_trx                AR_GTA_TRX_UTIL.trx_rec_type;
l_gta_trx_line_init      AR_GTA_TRX_UTIL.trx_line_rec_type;
l_trx_header_new         AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
l_trx_rate_index         NUMBER;  -- index for nested table loop
l_index                  NUMBER;  -- index for nested table loop
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;
  -- init l_gta_rate_trx_tbl
  l_gta_rate_trx_tbl := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();

  -- init x_trx_tbl
  x_trx_tbl := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();

  -- init l_gta_rate_trx
  l_gta_rate_trx.trx_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();

  l_gta_trx := p_gta_trx;

  -- split the different rate lines to different trx, use loop and if else
  l_trx_rate_index := l_GTA_TRX.trx_lines.FIRST;
  WHILE l_trx_rate_index IS NOT NULL
  LOOP
    -- init l_gta_rate_trx_line
    l_gta_rate_trx_line := l_gta_trx_line_init;
    l_add_flag := 0;   --12/06/2006   Shujuan Yan  bug

    -- read first line , if it is first line
    -- new a trx, and insert it into l_gta_trx_tbl
    IF l_trx_rate_index=1
    THEN
      l_gta_rate_trx_line := l_GTA_TRX.trx_lines(l_trx_rate_index);

      l_gta_rate_trx.trx_header := l_GTA_TRX.trx_header;

      l_gta_rate_trx.trx_lines.EXTEND;
      l_gta_rate_trx.trx_lines(l_gta_rate_trx.trx_lines.COUNT) := l_gta_rate_trx_line;

      l_gta_rate_trx_tbl.EXTEND;
      l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT) := l_gta_rate_trx;
    -- if it isn't first line , compare the tax_rate to the pre trx
    ELSE
      l_gta_rate_trx_line := l_GTA_TRX.trx_lines(l_trx_rate_index);
      l_tax_reg_number := l_gta_rate_trx_line.fp_tax_registration_number;
      -- compare the lines rate , if same rate ,add the line to trx, else new trx and insert it in to l_gta_trx_tbl
      l_index := l_gta_rate_trx_tbl.FIRST;
      WHILE l_index IS NOT NULL
      LOOP
        IF l_gta_rate_trx_tbl(l_index).trx_lines(1).fp_tax_registration_number = l_tax_reg_number
        THEN
          l_add_flag := l_index;
        END IF ;
        l_index := l_gta_rate_trx_tbl.NEXT(l_index);
      END LOOP; -- end loop l_gta_trx_tbl;

      -- if the tax_rate is not equal pre trx
      IF l_add_flag = 0
      THEN
      -- new trx for new tax_rate
        copy_header( p_GTA_TRX_Header_Rec   => l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT).trx_header
                    , x_GTA_TRX_Header_Rec  => l_trx_header_new );
        l_gta_rate_trx.trx_header := l_trx_header_new;
        l_gta_rate_trx.trx_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
        l_gta_rate_trx.trx_lines.EXTEND;
        l_gta_rate_trx.trx_lines(l_gta_rate_trx.trx_lines.COUNT) := l_gta_rate_trx_line;

        l_gta_rate_trx_tbl.EXTEND;
        l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT) := l_gta_rate_trx;

      ELSE
        -- add the line to the same tax_rate trx lines
        l_gta_rate_trx_tbl(l_add_flag).trx_lines.EXTEND;
        l_gta_rate_trx_tbl(l_add_flag).trx_lines(l_gta_rate_trx_tbl(l_add_flag).trx_lines.COUNT) := l_gta_rate_trx_line;
      END IF;  -- end if l_add_flag = 0

    END IF; -- end if i=1;

    l_trx_rate_index := l_gta_trx.trx_lines.NEXT(l_trx_rate_index);
  END LOOP;  -- end loop l_Gta_TRx.trx_lines. Now the trx is split in a trx_tbl

  -- output
  x_trx_tbl := l_gta_rate_trx_tbl;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END split_trx_by_taxreg_number;

--=============================================================================
-- PROCEDURE NAME:
--                split_trx_by_rate
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 split trx by tax rate
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   x_trx_tbl         out  AR_Gta_Trx_Util.trx_tbl_type
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE split_trx_by_rate
(p_gta_tbl       IN               AR_GTA_TRX_UTIL.trx_tbl_type
,x_trx_tbl       OUT NOCOPY       AR_Gta_Trx_Util.trx_tbl_type
)
IS
l_procedure_name         VARCHAR2(100) := 'split_trx_by_tax_registration_number';
l_gta_rate_trx_line      AR_GTA_TRX_UTIL.trx_line_rec_type;
l_gta_rate_trx           AR_GTA_TRX_UTIL.trx_rec_type;
l_gta_rate_trx_tbl       AR_GTA_TRX_UTIL.TRX_Tbl_TYPE := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();
l_tax_rate               NUMBER;
l_add_flag               NUMBER := 0;
l_gta_trx                AR_GTA_TRX_UTIL.trx_rec_type;
l_gta_trx_line_init      AR_GTA_TRX_UTIL.trx_line_rec_type;
l_trx_header_new         AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
l_trx_rate_index         NUMBER;  -- index for nested table loop
l_index                  NUMBER;  -- index for nested table loop
l_gta_index              NUMBER;  -- index for nested table loop
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;
  -- init l_gta_rate_trx_tbl
  l_gta_rate_trx_tbl := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();

  -- init x_trx_tbl
  x_trx_tbl := AR_GTA_TRX_UTIL.TRX_Tbl_TYPE();

  l_gta_index := p_gta_tbl.FIRST;
  WHILE l_gta_index IS NOT NULL
  LOOP
    -- init l_gta_rate_trx
    l_gta_rate_trx.trx_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();

    l_gta_trx := p_gta_tbl(l_gta_index);

    -- split the different rate lines to different trx, use loop and if else
    l_trx_rate_index := l_GTA_TRX.trx_lines.FIRST;
    WHILE l_trx_rate_index IS NOT NULL
    LOOP
      -- init l_gta_rate_trx_line
      l_gta_rate_trx_line := l_gta_trx_line_init;
      l_add_flag := 0;   --12/06/2006   Shujuan Yan  bug

      -- read first line , if it is first line
      -- new a trx, and insert it into l_gta_trx_tbl
      IF l_trx_rate_index=1
      THEN
        l_gta_rate_trx_line := l_GTA_TRX.trx_lines(l_trx_rate_index);

        l_gta_rate_trx.trx_header := l_GTA_TRX.trx_header;

        l_gta_rate_trx.trx_lines.EXTEND;
        l_gta_rate_trx.trx_lines(l_gta_rate_trx.trx_lines.COUNT) := l_gta_rate_trx_line;

        l_gta_rate_trx_tbl.EXTEND;
        l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT) := l_gta_rate_trx;
      -- if it isn't first line , compare the tax_rate to the pre trx
      ELSE
        l_gta_rate_trx_line := l_GTA_TRX.trx_lines(l_trx_rate_index);
        l_tax_rate := l_gta_rate_trx_line.tax_rate;
        -- compare the lines rate , if same rate ,add the line to trx, else new trx and insert it in to l_gta_trx_tbl
        l_index := l_gta_rate_trx_tbl.FIRST;
        WHILE l_index IS NOT NULL
        LOOP
          IF l_gta_rate_trx_tbl(l_index).trx_lines(1).tax_rate = l_tax_rate
          THEN
            l_add_flag := l_index;
          END IF ;
          l_index := l_gta_rate_trx_tbl.NEXT(l_index);
        END LOOP; -- end loop l_gta_trx_tbl;

        -- if the tax_rate is not equal pre trx
        IF l_add_flag = 0
        THEN
        -- new trx for new tax_rate
          copy_header( p_GTA_TRX_Header_Rec   => l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT).trx_header
                      , x_GTA_TRX_Header_Rec  => l_trx_header_new );
          l_gta_rate_trx.trx_header := l_trx_header_new;
          l_gta_rate_trx.trx_lines := AR_GTA_TRX_UTIL.TRX_line_Tbl_TYPE();
          l_gta_rate_trx.trx_lines.EXTEND;
          l_gta_rate_trx.trx_lines(l_gta_rate_trx.trx_lines.COUNT) := l_gta_rate_trx_line;

          l_gta_rate_trx_tbl.EXTEND;
          l_gta_rate_trx_tbl(l_gta_rate_trx_tbl.COUNT) := l_gta_rate_trx;

        ELSE
          -- add the line to the same tax_rate trx lines
          l_gta_rate_trx_tbl(l_add_flag).trx_lines.EXTEND;
          l_gta_rate_trx_tbl(l_add_flag).trx_lines(l_gta_rate_trx_tbl(l_add_flag).trx_lines.COUNT) := l_gta_rate_trx_line;
        END IF;  -- end if l_add_flag = 0

      END IF; -- end if i=1;

      l_trx_rate_index := l_gta_trx.trx_lines.NEXT(l_trx_rate_index);
    END LOOP;  -- end loop l_Gta_TRx.trx_lines. Now the trx is split in a trx_tbl

    l_gta_index := p_gta_tbl.NEXT(l_gta_index);
  END LOOP; -- end loop p_gta_tbl

  -- output
  x_trx_tbl := l_gta_rate_trx_tbl;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END split_trx_by_rate;

--=============================================================================
-- PROCEDURE NAME:
--                get_trx_type
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 get trx type by trx id
-- PARAMETERS:
--   p_org_id          IN   NUMBER
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   x_trx_type        out  ra_cust_trx_types_all.type%TYPE
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--                 04-Aug-2009 : Yao Zhang fix bug#8756943 modified
--=============================================================================
PROCEDURE get_trx_type
(p_org_id     IN           NUMBER
, p_gta_trx   IN           AR_Gta_Trx_Util.trx_rec_type
, x_trx_type  OUT  NOCOPY  ra_cust_trx_types_all.type%TYPE
)
IS

l_procedure_name VARCHAR2(30) := 'get_trx_type';
l_trx_id         ra_customer_trx_all.customer_trx_id%TYPE;
l_trx_type       ra_cust_trx_types_all.type%TYPE;
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

  IF p_gta_trx.trx_header.ra_trx_id IS NOT NULL
  THEN
    l_trx_id := p_gta_trx.trx_header.ra_trx_id;

    --Yao Zhang add for credit memo with discount lines exceed max line number should be transfered
    --without split for bug#8756943
    IF p_gta_trx.trx_header.consolidation_flag='0'
    THEN
      IF AR_GTA_TRX_UTIL.Get_Gtainvoice_Amount(p_gta_trx.trx_header.gta_trx_header_id)>0
      THEN l_trx_type:='INV';
      ELSE l_trx_type:='CM';
      END IF;
    ELSE
    BEGIN
    SELECT
      ctt.TYPE
    INTO
      l_trx_type
    FROM
      ra_customer_trx_all h
      ,ra_cust_trx_types_all ctt
    WHERE h.CUST_TRX_TYPE_ID = ctt.CUST_TRX_TYPE_ID(+)
      AND ctt.TYPE IN ('INV', 'CM', 'DM')
      AND ctt.org_id = p_org_id
      AND h.customer_trx_id = l_trx_id;
      EXCEPTION
      WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
      END IF;
      RAISE;
      END;
  END IF;--p_gta_trx.trx_header.consolidation_flag='0'
  END IF;/*p_gta_trx.trx_header.ra_trx_id IS NOT NULL*/

  x_trx_type := l_trx_type;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END get_trx_type;

--=============================================================================
-- PROCEDURE NAME:
--                judge_cm_limit
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 Judge wether the CM exceed the max line and max amount
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   p_org_id          in   number
--   x_result          out  BOOLEAN
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--                 16-Dec-2008   Yao Zhang Changed for bug 7644235
--                 23-Jan-2009 : Yao Zhang changed for bug 7758496
--                 28-Oct-2009 : Yao Zhang changed for bug 9045187
--=============================================================================
PROCEDURE judge_cm_limit
(p_gta_trx    IN           AR_Gta_Trx_Util.trx_rec_type
, p_org_id    IN           NUMBER
, p_transfer_id IN          NUMBER --yao zhang changed for bug 7758496
, x_result    OUT  NOCOPY  BOOLEAN)
IS
l_procedure_name VARCHAR2(30) := 'judge_cm_limit';
l_gta_trx        AR_Gta_Trx_Util.trx_rec_type;
l_fp_reg_num     ar_gta_trx_headers_all.fp_tax_registration_number%TYPE;
l_max_amount     ar_gta_tax_limits_all.max_amount%TYPE;
l_max_line       ar_gta_tax_limits_all.max_num_of_line%TYPE;
l_lines_number   NUMBER;
l_sum_of_amount  NUMBER;
l_trx_line_index NUMBER;
l_invoice_type   ar_gta_trx_headers_all.invoice_type%TYPE; --added by subba for R12.1
l_sales_list_flag        ar_gta_rule_headers_all.Sales_List_Flag%TYPE;--added by Yao Zhang for bug 7758496
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

  x_result := TRUE;
  l_gta_trx := p_gta_trx;
  l_fp_reg_num := l_gta_trx.trx_lines(1).fp_tax_registration_number;

  --added by subba for R12.1, getting invoice type to caliculate VAT limits

  l_invoice_type := ar_gta_trx_util.get_invoice_type(p_org_id =>  l_gta_trx.trx_header.org_id
                                                       ,p_customer_trx_id=> l_gta_trx.trx_header.ra_trx_id
                                                       ,p_fp_tax_registration_num => l_fp_reg_num);
  l_sum_of_amount := 0;

  BEGIN
    SELECT
      limits.max_amount
      , limits.max_num_of_line
    INTO
      l_max_amount
      , l_max_line
    FROM
      ar_gta_tax_limits_all limits
    WHERE limits.fp_tax_registration_number = l_fp_reg_num
      AND limits.invoice_type = l_invoice_type
      AND limits.org_id = p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , 'no data found');

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , fnd_message.get());

       END IF;
       RAISE;
       RETURN;
  END;

  --the following code is added by Yao Zhang for bug 7758496
  BEGIN
    SELECT
      sales_list_flag
    INTO
      l_sales_list_flag
    FROM
      AR_GTA_RULE_HEADERS_All
    WHERE org_id = p_org_id
      AND rule_header_id = p_transfer_id;
  EXCEPTION
    -- no data found , raise a data error
    WHEN no_data_found THEN
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , 'no data found');

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , fnd_message.get());

       END IF;
       RAISE;
       RETURN;
  END;
  --add end by yao zhang for bug 7758496

  l_lines_number := l_GTA_TRX.trx_lines.COUNT;

  l_trx_line_index := l_gta_trx.trx_lines.FIRST;
  WHILE l_trx_line_index IS NOT NULL
  LOOP
   --Yao Modified for bug#9045187
    --l_sum_of_amount := l_sum_of_amount + l_GTA_TRX.trx_lines(l_trx_line_index).amount*(-1);
    l_sum_of_amount:=l_sum_of_amount+l_GTA_TRX.trx_lines(l_trx_line_index).amount
                     +nvl(l_GTA_TRX.trx_lines(l_trx_line_index).discount_amount,0);
    IF l_GTA_TRX.trx_lines(l_trx_line_index).quantity IS NOT NULL
    THEN
      IF l_GTA_TRX.trx_lines(l_trx_line_index).quantity > 0
      THEN
        l_GTA_TRX.trx_lines(l_trx_line_index).quantity := l_GTA_TRX.trx_lines(l_trx_line_index).quantity*(-1);
      END IF;/*l_GTA_TRX.trx_lines(l_trx_line_index).quantity > 0*/
    END IF;/*l_GTA_TRX.trx_lines(l_trx_line_index).quantity IS NOT NULL*/
    l_trx_line_index := l_gta_trx.trx_lines.NEXT(l_trx_line_index);
  END LOOP;
  -- max amount and max line is mandotrary not null
  IF l_max_amount IS NULL OR l_max_line IS NULL
  THEN
    x_result := FALSE;
  END IF; /*l_max_amount IS NULL OR l_max_line IS NULL*/
  --IF l_sum_of_amount > l_max_amount OR l_lines_number > l_max_line --delete By Yao Zhang for bug 7644235
  IF ABS(l_sum_of_amount) > l_max_amount OR --add By Yao Zhang for bug 7644235
    (l_lines_number > l_max_line and l_sales_list_flag='N') --yao zhang changed for bug 7758496

  THEN
    x_result := FALSE;
  END IF;/*l_sum_of_amount > l_max_amount OR l_lines_number > l_max_line*/

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END;


--=============================================================================
-- PROCEDURE NAME:
--                get_max_amount_line
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 get max line and max amount by fp registration number
-- PARAMETERS:
--   p_gta_trx         in   AR_GTA_TRX_UTIL.trx_tbl_type
--   p_org_id          in   number
--   x_max_amount      in   number
--   x_max_line        in   number
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE get_max_amount_line
(p_gta_trx       IN           AR_Gta_Trx_Util.trx_rec_type
, p_org_id       IN           NUMBER
, x_max_amount   OUT NOCOPY   NUMBER
, x_max_line     OUT NOCOPY   NUMBER)
IS
l_procedure_name VARCHAR2(30) := 'judge_cm_limit';
l_gta_trx        AR_Gta_Trx_Util.trx_rec_type;
l_fp_reg_num     ar_gta_trx_headers_all.fp_tax_registration_number%TYPE;
l_max_amount     NUMBER;
l_max_line       NUMBER;
l_error_string   VARCHAR2(2000);  --added by subba.
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'Begin get_max_amount_line  '||'p_org_id:'||P_org_id);
  END IF;
  -- end log

  l_gta_trx := p_gta_trx;
  l_fp_reg_num := l_gta_trx.trx_lines(1).fp_tax_registration_number;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'l_fp_reg_num:  '||l_fp_reg_num);
  END IF;
  -- end log
/*   28/12/07 commented by Subba to change the logic for R12.1
  BEGIN
    SELECT
      limits.max_amount
      , limits.max_num_of_line
    INTO
      l_max_amount
      , l_max_line
    FROM
      ar_gta_tax_limits_all limits
    WHERE limits.fp_tax_registration_number = l_fp_reg_num
      AND limits.org_id = p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , 'no data found');

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                        , G_MODULE_PREFIX || l_procedure_name
                        , fnd_message.get());

       END IF;
       RAISE;
       RETURN;
  END;
*/ --New logic is added below



 l_gta_trx.trx_header.invoice_type := ar_gta_trx_util.get_invoice_type(p_org_id => p_org_id
                                                       ,p_customer_trx_id=> l_gta_trx.trx_header.ra_trx_id
                                                       ,p_fp_tax_registration_num => l_fp_reg_num);

BEGIN
    SELECT
      jgtla.max_amount
     ,jgtla.max_num_of_line
    INTO
        l_max_amount
      , l_max_line
    FROM
      ar_gta_tax_limits_all jgtla
    WHERE jgtla.fp_tax_registration_number = l_fp_reg_num
      AND jgtla.invoice_type = l_gta_trx.trx_header.invoice_type
      AND jgtla.org_id  = p_org_id;



  EXCEPTION
    WHEN no_data_found THEN

         --AR_GTA_SYS_CONFIG_MISSING
         fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
         l_error_string := fnd_message.get();
         -- output error
          fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="UTF-8" ?>
           <TransferReport>
                  <ReportFailed>Y</ReportFailed>
                 <ReportFailedMsg>'||l_error_string ||'</ReportFailedMsg>
           <TransferReport>');

	       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                                  ,G_MODULE_PREFIX || l_procedure_name
                                  ,'no data found for max_amt and mx_num_line'
                                 );
         END IF;
         RAISE;
        RETURN;
  END; -- added by Subba for R12.1


  IF l_max_line IS NOT NULL AND l_max_amount IS NOT NULL
  THEN
    x_max_line := l_max_line;
    x_max_amount := l_max_amount;
  END IF ; /*l_max_line IS NOT NULL AND l_max_amount IS NOT NULL*/

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'End get_max_amount_line:'||l_fp_reg_num);
  END IF;
  -- end log

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                , G_MODULE_PREFIX || l_procedure_name
                ,'Begin Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END get_max_amount_line;

--=============================================================================
-- PROCEDURE NAME:
--                fileter_credit_memo
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION:
--                 filter credit memo which amount and lines number exceeded.
-- PARAMETERS:
--   p_org_id          in           number
--   p_gta_trx_tbl     in           ar_gta_trx_util.trx_tbl_type
--   x_gta_trx_tbl     out nocopy   ar_gta_trx_util.trx_tbl_type
--
-- HISTORY:
--                 10-Sep-2005 : Jim.Zheng  Create
--                 23-Jan-2009 : yao zhang changed for bug 7758496
--=============================================================================
PROCEDURE  filter_credit_memo
(p_org_id                IN          NUMBER
, p_transfer_id             IN          NUMBER--yao zhang changed for bug 7758496
, p_gta_trx_tbl          IN          ar_gta_trx_util.trx_tbl_type
, x_gta_Trx_tbl          OUT NOCOPY  ar_gta_trx_util.trx_tbl_type
)
IS
l_index              NUMBER;
l_procedure_name     VARCHAR2(50) := 'filter_credit_memo';
l_trx_type           VARCHAR2(30);
l_trx_reg_tbl        ar_gta_trx_util.trx_tbl_type;
l_trx_rate_tbl       ar_gta_trx_util.trx_tbl_type;
l_rate_index         NUMBER;
l_result             BOOLEAN;
l_gta_trx            ar_gta_trx_util.trx_rec_type;
l_gta_rate_trx       ar_gta_trx_util.trx_rec_type;
l_cm_exceed_limit    EXCEPTION;
l_error_string       VARCHAR2(500);

BEGIN

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'Begin filter_credit_memo');
  END IF;
  -- end log

  -- init x_gta_Trx_tbl
  x_gta_Trx_tbl := ar_gta_trx_util.trx_tbl_type();

  -- begin loop the p_gta_trx_tbl
  l_index := p_gta_trx_tbl.FIRST;
  WHILE l_index IS NOT NULL
  LOOP
    BEGIN

      l_gta_trx := p_gta_trx_tbl(l_index);
      get_Trx_type(p_org_id        => p_org_id
                  , p_gta_trx      => l_gta_trx
                  , x_trx_type     => l_trx_type);
      IF l_trx_type = 'CM'
      THEN

        split_trx_by_taxreg_number(p_gta_trx  => l_gta_trx
                                  , x_trx_tbl => l_trx_reg_tbl);
        split_trx_by_rate(p_gta_tbl   =>  l_trx_reg_tbl
                         ,x_trx_tbl   =>  l_trx_rate_tbl);

        l_rate_index := l_trx_rate_tbl.FIRST;
        WHILE l_rate_index IS NOT NULL
        LOOP
          l_gta_rate_trx := l_trx_rate_tbl(l_rate_index);
          judge_cm_limit(p_gta_trx    => l_gta_rate_trx
                        ,p_org_id     => p_org_id
                        , p_transfer_id => p_transfer_id
                        ,x_result     => l_result);
          IF l_result = FALSE
          THEN
            fnd_message.SET_NAME('AR', 'AR_GTA_CRMEMO_EXCEED_LIMIT');
            l_error_string := fnd_message.GET();
            IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
              fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                             , G_MODULE_PREFIX || l_procedure_name
                             , l_error_string
                            );
            END IF;
            RAISE l_cm_exceed_limit;
          END IF;
          l_rate_index := l_trx_rate_tbl.NEXT(l_rate_index);
        END LOOP;/*l_rate_index IS NOT NULL*/
        x_gta_trx_tbl.EXTEND;
        x_gta_trx_tbl(x_gta_trx_tbl.COUNT) := l_gta_trx;

      ELSE /*l_trx_type = 'CM'*/
        -- begin log
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'Is not a CM');
        END IF;
        -- end log

        x_gta_trx_tbl.EXTEND;
        x_gta_trx_tbl(x_gta_trx_tbl.COUNT) := l_gta_trx;
      END IF;/*l_trx_type = 'CM'*/


    EXCEPTION
      WHEN l_cm_exceed_limit
      THEN
        --delete warning data from ar_gta_transfer_temp
        DELETE
          ar_gta_transfer_temp temp
        WHERE temp.transaction_id = l_gta_trx.trx_header.ra_trx_id
          AND temp.succeeded = 'W';

        -- error message into temp table.
        INSERT INTO
          ar_gta_transfer_temp t
            (t.seq
            , t.transaction_id
            , t.succeeded
            , t.transaction_num
            , t.transaction_type
            , t.customer_name
            , t.amount
            , t.failedreason
            , t.gta_invoice_num
            )
         SELECT
           ar_gta_transfer_temp_s.NEXTVAL
           , l_gta_trx.trx_header.ra_trx_id
           , 'N'
           , l_gta_trx.trx_header.ra_trx_number
           , 'CM'
           , l_gta_trx.trx_header.bill_to_customer_name
           , NULL
           , l_error_string
           , NULL
         FROM
           dual;
    END;
    l_index := p_gta_trx_tbl.NEXT(l_index);
  END LOOP;/*l_index IS NOT NULL*/

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX || l_procedure_name, 'End filter_credit_memo');
  END IF;
  -- end log

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END filter_credit_memo;


END AR_GTA_SPLIT_TRX_PROC;

/
