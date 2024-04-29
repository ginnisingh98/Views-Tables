--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_VALIDATE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_VALIDATE_PROC" AS
-- $Header: INVVALCB.pls 120.1.12010000.2 2009/10/20 10:25:02 abhissri ship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVVALCB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_VALIDATE_PROC                                 |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Validate_Transaction                                              |
--|                                                                       |
--| REFERENCED PROCEDURES                                                 |
--|     INV_MGD_MVT_STATS_PVT.Get_Open_Mvmt_Stats_Txns                    |
--|     INV_MGD_MVT_SETUP_MDTR.Get_Movement_Stat_Usages                   |
--|     INV_MGD_MVT_STATS_PVT.Validate_Movement_Statistics                |
--|     INV_MGD_MVT_STATS_PVT.Update_Mtl_Movement_Statistics              |
--|     INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info                         |
--|     INV_MGD_MVT_UTILS_PKG.Log                                         |
--|     INV_MGD_MVT_RPT_GEN.Print_Header                                  |
--|     INV_MGD_MVT_RPT_GEN.Print_Footer                                  |
--|     INV_MGD_MVT_RPT_GEN.Print_Body                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     05/25/2000 ksaini        Created Validate_Transaction Wrapper API |
--|                              For Exception Verification Report        |
--|     07/14/2003 tsimmond      added procedure Populate_temp_table for  |
--|                              new design of the Exception Report       |
--+======================================================================*/

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_MVT_VALIDATE_PROC';
g_final_excp_list      INV_MGD_MVT_DATA_STR.excp_list ;
G_rpt_page_col         CONSTANT INTEGER      := 78 ;
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_VALIDATE_PROC.';
--========================================================================
--PROCEDURE : Populate_temp_table         PRIVATE
--
--PARAMETERS: p_excp_list                IN
--            p_mtl_movement_transaction IN
--
-- COMMENT   : Procedure populates temp table INV_MVT_EXCEP_REP_TEMP with
--             data, that is printed in Exception Report
--=======================================================================
PROCEDURE Populate_temp_table
( p_excp_list  IN INV_MGD_MVT_DATA_STR.EXCP_LIST
, p_mtl_movement_transaction IN INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
l_num_of_exceptions NUMBER;
l_item_code         VARCHAR2(40);
l_count_i           NUMBER;
l_error_name        VARCHAR2(100);
l_error_type        VARCHAR2(25);
l_count             NUMBER;
l_excp_col_name     VARCHAR2(100);
l_f_currency_code   VARCHAR2(15);
l_tp_name           VARCHAR2(360);
l_tp_type           VARCHAR2(80);
l_procedure_name CONSTANT VARCHAR2(30) := 'Populate_Temp_Table';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_num_of_exceptions := p_excp_list.COUNT;

  ---dbms_output.put_line('Number of exceptions: '|| l_num_of_exceptions);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_NAME || l_procedure_name
                  , 'Number of exceptions: '|| l_num_of_exceptions
                );
  END IF;

  l_count_i := 1;
  WHILE l_count_i <= l_num_of_exceptions
  LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_procedure_name
                    , 'Loop : '|| l_count_i
                  );
    END IF;

    ---------------Missing Invoice------------------------
    IF p_excp_list(l_count_i).excp_message_cd=1
      AND p_excp_list(l_count_i).excp_col_name='INVOICE_ID'
    THEN
     -- FND_MESSAGE.set_name('INV','INV_MGD_MVT_MIS_INV');

      --FND_MESSAGE.set_token('EXCP_MISSING_COL'
      --                  , p_excp_list(l_count_i).excp_col_name
      --                  );

      l_error_name:='INV_MGD_MVT_MIS_INV';
      l_error_type:='Warning';

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_procedure_name
                      ,'Insert record into temp table'
                      );
      END IF;

      INSERT INTO inv_mvt_excep_rep_temp
      ( error_type
      , error_name
      , inventory_item_id
      , item_code
      , movement_id
      , from_currency_code
      , to_currency_code
      , exchange_type
      , from_uom
      , to_uom
      , tp_name
      , tp_type
      , column_name
      , number_of_records
      )
      VALUES
      ( l_error_type
      , l_error_name
      , NULL
      , NULL
      , p_mtl_movement_transaction.movement_id
      , NULL  ----from_currency_code
      , NULL  ----to_currency_code
      , NULL  ----p_mtl_movement_transaction.exchange_type
      , NULL  ----from_uom
      , NULL  ----to_uom
      , NULL  ----tp_name
      , NULL  ----tp_type
      , p_excp_list(l_count_i).excp_col_name
      , NULL
      );

    ------------Missing Commodity_code --------
    ELSIF p_excp_list(l_count_i).excp_message_cd=1
      AND p_excp_list(l_count_i).excp_col_name='COMMODITY_CODE'
    THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Missing Commodity_code'
                    );
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'error_name='||l_error_name
                      );
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'column_name='||p_excp_list(l_count_i).excp_col_name
                      );
      END IF;

      l_error_name:='INV_MGD_MVT_MIS_COMC';
      l_error_type:='Error';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'error_name='||l_error_name
                      );
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Get item code for item_id='||TO_CHAR(p_mtl_movement_transaction.inventory_item_id)
                      );
      END IF;

      BEGIN

	/* Bugfix 9003740: item_number should be used in place of segment1
	SELECT segment1
        INTO l_item_code
        FROM mtl_item_flexfields
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
          AND organization_id=p_mtl_movement_transaction.organization_id;
	*/

	SELECT item_number
        INTO l_item_code
        FROM mtl_item_flexfields
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
          AND organization_id=p_mtl_movement_transaction.organization_id;


      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_NAME || l_procedure_name
                          , 'There is no data in item_number in mtl_item_flexfields for
                             item_id='||TO_CHAR(p_mtl_movement_transaction.inventory_item_id)
                          );
          END IF;

         ------Exception Missing Item ---------------------
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Missing Item'
                        );
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table'
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( 'Error'
        , 'INV_MGD_MVT_MIS_ITEM'
        , NULL
        , NULL
        , p_mtl_movement_transaction.movement_id
        , NULL  ----p_mtl_movement_transaction.currency_code
        , NULL
        , NULL  ----p_mtl_movement_transaction.currency_conversion_rate
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , NULL
        , NULL
        );

      END;

      ------Checking if information about this item and this exception
      ------already exists in temp table

      SELECT COUNT(*)
      INTO l_count
      FROM inv_mvt_excep_rep_temp
      WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
        AND error_name=l_error_name
        AND column_name='COMMODITY_CODE';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'l_count='||TO_CHAR(l_count)
                    );
      END IF;

      IF l_count>0
      THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Update temp table'
                        );
        END IF;

        ------update mode
        UPDATE inv_mvt_excep_rep_temp
        SET number_of_records=number_of_records+1
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
        AND error_name=l_error_name
        AND column_name='COMMODITY_CODE';

      ELSE
        ------insert mode

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table:'
                        );
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'error_type='||l_error_type
                        );
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'error_name='||l_error_name
                         );
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'column_name='||p_excp_list(l_count_i).excp_col_name||
                          'item_id='||p_mtl_movement_transaction.inventory_item_id
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( l_error_type
        , l_error_name
        , p_mtl_movement_transaction.inventory_item_id
        , l_item_code
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , p_excp_list(l_count_i).excp_col_name
        , 1
        );

      END IF;

    ------------Missing Unit_weight--------
    ELSIF p_excp_list(l_count_i).excp_message_cd=1
      AND p_excp_list(l_count_i).excp_col_name='UNIT_WEIGHT'
    THEN
      --FND_MESSAGE.set_name('INV','INV_MGD_MVT_MIS_UNW');

     -- FND_MESSAGE.set_token('EXCP_MISSING_COL'
     --                   , p_excp_list(l_count_i).excp_col_name
     --                   );

      l_error_name:='INV_MGD_MVT_MIS_UNW';
      l_error_type:='Error';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Get item code for item_id='||TO_CHAR(p_mtl_movement_transaction.inventory_item_id)
                      );
      END IF;

      BEGIN

	/* Bugfix 9003740: item_number should be used in place of segment1
	SELECT segment1
        INTO l_item_code
        FROM mtl_item_flexfields
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
        AND organization_id=p_mtl_movement_transaction.organization_id;
	*/

	SELECT item_number
        INTO l_item_code
        FROM mtl_item_flexfields
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
          AND organization_id=p_mtl_movement_transaction.organization_id;


      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_NAME || l_procedure_name
                          , 'There is no data in item_number in mtl_item_flexfields for
                            item_id='||TO_CHAR(p_mtl_movement_transaction.inventory_item_id)
                          );
          END IF;

          ------Exception Missing Item ---------------------
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_NAME || l_procedure_name
                          , 'Missing Item'
                          );
          END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table:'
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( 'Error'
        , 'INV_MGD_MVT_MIS_ITEM'
        , NULL
        , NULL
        , p_mtl_movement_transaction.movement_id
        , NULL  ----p_mtl_movement_transaction.currency_code
        , NULL
        , NULL  ----p_mtl_movement_transaction.currency_conversion_rate
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , NULL
        , NULL
        );

      END;

      ------Checking if information about this item and this exception
      ------already exists in temp table

      SELECT COUNT(*)
      INTO l_count
      FROM inv_mvt_excep_rep_temp
      WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
        AND error_name=l_error_name;

      IF l_count>0
      THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Update temp table:'
                        );
        END IF;

        ------update mode
        UPDATE inv_mvt_excep_rep_temp
        SET number_of_records=number_of_records+1
        WHERE inventory_item_id=p_mtl_movement_transaction.inventory_item_id
        AND error_name=l_error_name;

      ELSE
        ------insert mode
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table:'
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( l_error_type
        , l_error_name
        , p_mtl_movement_transaction.inventory_item_id
        , l_item_code
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , p_excp_list(l_count_i).excp_col_name
        , 1
        );

      END IF;

    -------------Missing Exchange Rate-----------------------
    ELSIF p_excp_list(l_count_i).excp_message_cd=1
      AND p_excp_list(l_count_i).excp_col_name='CURRENCY_CONVERSION_RATE'

    THEN

      --FND_MESSAGE.set_name('INV','INV_MGD_MVT_MIS_EXR');

      --FND_MESSAGE.set_token('EXCP_MISSING_COL'
      --                  , p_excp_list(l_count_i).excp_col_name
      --                  );

      l_error_name:='INV_MGD_MVT_MIS_EXR';
      l_error_type:='Error';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Missing Exchange Rate,l_error_name= '||l_error_name
                      );
      END IF;

      ----get functional currency
      l_f_currency_code := INV_MGD_MVT_UTILS_PKG.Get_LE_Currency
                           (p_mtl_movement_transaction.entity_org_id);

      ------Checking if information about this currency and this exception
      ------already exists in temp table
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Checking if this currency already exists in temp table'
                      );
      END IF;

      SELECT COUNT(*)
      INTO l_count
      FROM inv_mvt_excep_rep_temp
      WHERE from_currency_code=p_mtl_movement_transaction.currency_code
        AND error_name=l_error_name;

      IF l_count>0
      THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Update temp table'
                        );
        END IF;

        ------update mode
        UPDATE inv_mvt_excep_rep_temp
        SET number_of_records=number_of_records+1
        WHERE from_currency_code=p_mtl_movement_transaction.currency_code
        AND error_name=l_error_name;

      ELSE
        ------insert mode
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table:'
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( l_error_type
        , l_error_name
        , NULL
        , NULL
        , NULL
        , p_mtl_movement_transaction.currency_code
        , l_f_currency_code
        , p_mtl_movement_transaction.currency_conversion_rate
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , p_excp_list(l_count_i).excp_col_name
        , 1
        );

      END IF;

    ------------Missing VAT NUMBER --------
    ELSIF p_excp_list(l_count_i).excp_message_cd=1
      AND p_excp_list(l_count_i).excp_col_name='PARTNER_VAT_NUMBER'
    THEN

      l_error_name:='INV_MGD_MVT_MIS_TP_VAT';
      l_error_type:='Error';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Get Parner name and Partner Type'
                      );
      END IF;

      -----for SO
      IF p_mtl_movement_transaction.document_source_type IN ('SO','IO','RMA')
        AND p_mtl_movement_transaction.bill_to_site_use_id IS NOT NULL
      THEN
        l_tp_name:=p_mtl_movement_transaction.CUSTOMER_NAME;

        FND_MESSAGE.set_name('INV','INV_MGD_MVT_EXCP_TP_CUST');
        l_tp_type:=FND_MESSAGE.GET;


      ELSIF p_mtl_movement_transaction.document_source_type in ('PO','RTV')
       AND p_mtl_movement_transaction.vendor_site_id IS NOT NULL
      THEN
        l_tp_name:=p_mtl_movement_transaction.VENDOR_NAME;

        FND_MESSAGE.set_name('INV','INV_MGD_MVT_EXCP_TP_SUP');
        l_tp_type:=FND_MESSAGE.GET;

      ELSIF p_mtl_movement_transaction.document_source_type = 'INV'
      THEN
        FND_MESSAGE.set_name('INV','INV_MGD_MVT_EXCP_TP_ORG');
        l_tp_type:=FND_MESSAGE.GET;

        BEGIN

          SELECT name
          INTO l_tp_name
          FROM hr_all_organization_units
          WHERE organization_id=p_mtl_movement_transaction.entity_org_id;
        EXCEPTION
          WHEN OTHERS
          THEN
            null;
        END;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , ' Parner name='||l_tp_name||
                        ' Partner Type='||l_tp_type
                      );
      END IF;

      ------Checking if information about this customer or supplier and this exception
      ------already exists in temp table

      SELECT COUNT(*)
      INTO l_count
      FROM inv_mvt_excep_rep_temp
      WHERE tp_name=l_tp_name
        AND tp_type=l_tp_type
        AND column_name='PARTNER_VAT_NUMBER'
        AND error_name=l_error_name;

      IF l_count>0
      THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Update temp table:'
                        );
        END IF;

        ------update mode
        UPDATE inv_mvt_excep_rep_temp
        SET number_of_records=number_of_records+1
        WHERE tp_name=l_tp_name
        AND tp_type=l_tp_type
        AND column_name='PARTNER_VAT_NUMBER'
        AND error_name=l_error_name;

      ELSE
        ------insert mode
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_procedure_name
                        , 'Insert record into temp table, error_name='||l_error_name
                        );
        END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( l_error_type
        , l_error_name
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL  ----from_uom
        , NULL  ----to_uom
        , l_tp_name
        , l_tp_type
        , p_excp_list(l_count_i).excp_col_name
        , 1
        );

      END IF;

    -------------Incorrect Value------------------------------
    ELSIF p_excp_list(l_count_i).excp_message_cd=2
    THEN
      --FND_MESSAGE.set_name('INV','INV_MGD_MVT_INVAL_VAL');

      --FND_MESSAGE.set_token('EXCP_INCORRECT_COL'
      --                  , p_excp_list(l_count_i).excp_col_name
      --                  );

      l_error_name:='INV_MGD_MVT_INVAL_VAL';
      l_error_type:='Error';

      ------get the name as it appears in the form instead of column_name
      IF p_excp_list(l_count_i).excp_col_name='DELIVERY_TERMS'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_DT'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='TRANSACTION_NATURE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_TN'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='TRANSPORT_MODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_TM'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='PORT'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_P'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

     ELSIF p_excp_list(l_count_i).excp_col_name='STATISTICAL_PROCEDURE_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_SPC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='AREA'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_A'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='OUTSIDE_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_PC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='OUTSIDE_UNIT_PRICE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_OUP'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='TRIANGULATION_COUNTRY_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_TCC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='OIL_REFERENCE_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_ORC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

     ELSIF p_excp_list(l_count_i).excp_col_name='CONTAINER_TYPE_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_CTC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

     ELSIF p_excp_list(l_count_i).excp_col_name='FLOW_INDICATOR_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_FIC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='AFFILIATION_REFERENCE_CODE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_ARC'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;

      ELSIF p_excp_list(l_count_i).excp_col_name='OUTSIDE_EXT_VALUE'
      THEN
        FND_MESSAGE.set_name('INV'
                       ,'INV_MGD_MVT_EXCP_OEV'
                       );
        l_excp_col_name:=FND_MESSAGE.GET;


      ELSE
        l_excp_col_name:=p_excp_list(l_count_i).excp_col_name;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Insert record into temp table:'
                      );
      END IF;

        INSERT INTO inv_mvt_excep_rep_temp
        ( error_type
        , error_name
        , inventory_item_id
        , item_code
        , movement_id
        , from_currency_code
        , to_currency_code
        , exchange_type
        , from_uom
        , to_uom
        , tp_name
        , tp_type
        , column_name
        , number_of_records
        )
        VALUES
        ( l_error_type
        , l_error_name
        , NULL
        , NULL
        , p_mtl_movement_transaction.movement_id
        , NULL  ----p_mtl_movement_transaction.currency_code
        , NULL
        , NULL  ----p_mtl_movement_transaction.currency_conversion_rate
        , NULL  ----from_uom
        , NULL  ----to_uom
        , NULL  ----tp_name
        , NULL  ----tp_type
        , l_excp_col_name
        , NULL
        );


   END IF;
  l_count_i := l_count_i + 1;
  END LOOP;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  EXCEPTION

    WHEN OTHERS THEN

    IF
      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                            , 'INV_MGD_MVT_Populate_temp_table '
                            );
    END IF;


END Populate_temp_table;


--========================================================================
--PROCEDURE : Validate_Transaction         PUBLIC
--
--PARAMETERS: p_api_version_number       IN  Known api version
--            p_init_msg_list            IN  FND_API.G_FALSE to preserve list
--            p_legal_entity_id          IN  Legal Entity Id
--            p_economic_zone_code       IN  Economic Zone Code
--            p_usage_type               IN  Usage type
--            p_stat_type                IN  Stat Type
--            p_period_name              IN  Period name
--            p_document_source_type     IN  Document Source Type
--            x_return_status            OUT return status
--
--
-- VERSION   : current version            1.0
--             initial_version            1.0
-- COMMENT   : Wrapper API to call Validate_Movement_Statistics
--=======================================================================

PROCEDURE Validate_Transaction (
    p_api_version_number           IN  NUMBER
    , p_init_msg_list              IN  VARCHAR2
    , p_legal_entity_id            IN  NUMBER
    , p_economic_zone_code         IN  VARCHAR2
    , p_usage_type                 IN  VARCHAR2
    , p_stat_type                  IN  VARCHAR2
    , p_period_name                IN  VARCHAR2
    , p_document_source_type       IN  VARCHAR2
    , x_return_status              OUT NOCOPY VARCHAR2
    , x_msg_count                  OUT NOCOPY NUMBER
    , x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

--  Cursor For Fetching Movement Statistics Records
 val_crsr          INV_MGD_MVT_DATA_STR.valCurTyp;
 l_excp_list       INV_MGD_MVT_DATA_STR.excp_list;
 l_record_status   VARCHAR2(1);
 l_return_status   VARCHAR2(1);
 x_updated_flag    VARCHAR2(1);
 l_msg_count       NUMBER;
 l_msg_data        VARCHAR2(100);
 l_mtl_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
 l_init_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
 l_ret_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
 l_movement_stat_usages_rec
                   INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;

 l_procedure_name CONSTANT VARCHAR2(30) := 'Validate_Transaction';

 l_api_version_number  NUMBER;
 l_init_msg_list       VARCHAR2(30);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_api_version_number IS NULL
  THEN
    l_api_version_number  := 1;
  END IF;

  IF p_init_msg_list IS NULL
  THEN
    l_init_msg_list       := FND_API.G_FALSE;
  END IF;

  --INV_MGD_MVT_UTILS_PKG.Log_Initialize;

  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

  l_excp_list.DELETE;
  l_mtl_movement_statistics := l_init_movement_statistics ;
  l_ret_movement_statistics := l_init_movement_statistics ;


  INV_MGD_MVT_SETUP_MDTR.Get_Movement_Stat_Usages
  ( x_return_status            => x_return_status
  , x_msg_count                => x_msg_count
  , x_msg_data                 => x_msg_data
  , p_legal_entity_id          => p_legal_entity_id
  , p_economic_zone_code       => p_economic_zone_code
  , p_usage_type               => p_usage_type
  , p_stat_type                => p_stat_type
  , x_movement_stat_usages_rec => l_movement_stat_usages_rec
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_movement_stat_usages_rec.gl_period_name := p_period_name;

/*  -- Print Report Header
  INV_MGD_MVT_RPT_GEN.Print_Header( p_legal_entity_id      => p_legal_entity_id
              , p_period_name          => p_period_name
              , p_document_source_type => p_document_source_type
              );
*/ ---changed for FPJ


  -- Open Cursor
  INV_MGD_MVT_STATS_PVT.Get_Open_Mvmt_Stats_Txns(
              val_crsr => val_crsr
            , p_movement_statistics => l_mtl_movement_statistics
	    , p_legal_entity_id  => p_legal_entity_id
	    , p_economic_zone_code => p_economic_zone_code
	    , p_usage_type => p_usage_type
	    , p_stat_type => p_stat_type
	    , p_period_name => p_period_name
	    , p_document_source_type => p_document_source_type
	    , x_return_status => x_return_status );

IF x_return_status = 'Y' THEN

  --- Fetch the Cursor into the Record Type
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_NAME || l_procedure_name
                  , 'LOOP on val_cur cursor for validate transaction'
                );
  END IF;

  LOOP

    FETCH val_crsr INTO
      l_mtl_movement_statistics.movement_id
    , l_mtl_movement_statistics.organization_id
    , l_mtl_movement_statistics.entity_org_id
    , l_mtl_movement_statistics.movement_type
    , l_mtl_movement_statistics.movement_status
    , l_mtl_movement_statistics.transaction_date
    , l_mtl_movement_statistics.last_update_date
    , l_mtl_movement_statistics.last_updated_by
    , l_mtl_movement_statistics.creation_date
    , l_mtl_movement_statistics.created_by
    , l_mtl_movement_statistics.last_update_login
    , l_mtl_movement_statistics.document_source_type
    , l_mtl_movement_statistics.creation_method
    , l_mtl_movement_statistics.document_reference
    , l_mtl_movement_statistics.document_line_reference
    , l_mtl_movement_statistics.document_unit_price
    , l_mtl_movement_statistics.document_line_ext_value
    , l_mtl_movement_statistics.receipt_reference
    , l_mtl_movement_statistics.shipment_reference
    , l_mtl_movement_statistics.shipment_line_reference
    , l_mtl_movement_statistics.pick_slip_reference
    , l_mtl_movement_statistics.customer_name
    , l_mtl_movement_statistics.customer_number
    , l_mtl_movement_statistics.customer_location
    , l_mtl_movement_statistics.transacting_from_org
    , l_mtl_movement_statistics.transacting_to_org
    , l_mtl_movement_statistics.vendor_name
    , l_mtl_movement_statistics.vendor_number
    , l_mtl_movement_statistics.vendor_site
    , l_mtl_movement_statistics.bill_to_name
    , l_mtl_movement_statistics.bill_to_number
    , l_mtl_movement_statistics.bill_to_site
    , l_mtl_movement_statistics.po_header_id
    , l_mtl_movement_statistics.po_line_id
    , l_mtl_movement_statistics.po_line_location_id
    , l_mtl_movement_statistics.order_header_id
    , l_mtl_movement_statistics.order_line_id
    , l_mtl_movement_statistics.picking_line_id
    , l_mtl_movement_statistics.shipment_header_id
    , l_mtl_movement_statistics.shipment_line_id
    , l_mtl_movement_statistics.ship_to_customer_id
    , l_mtl_movement_statistics.ship_to_site_use_id
    , l_mtl_movement_statistics.bill_to_customer_id
    , l_mtl_movement_statistics.bill_to_site_use_id
    , l_mtl_movement_statistics.vendor_id
    , l_mtl_movement_statistics.vendor_site_id
    , l_mtl_movement_statistics.from_organization_id
    , l_mtl_movement_statistics.to_organization_id
    , l_mtl_movement_statistics.parent_movement_id
    , l_mtl_movement_statistics.inventory_item_id
    , l_mtl_movement_statistics.item_description
    , l_mtl_movement_statistics.item_cost
    , l_mtl_movement_statistics.transaction_quantity
    , l_mtl_movement_statistics.transaction_uom_code
    , l_mtl_movement_statistics.primary_quantity
    , l_mtl_movement_statistics.invoice_batch_id
    , l_mtl_movement_statistics.invoice_id
    , l_mtl_movement_statistics.customer_trx_line_id
    , l_mtl_movement_statistics.invoice_batch_reference
    , l_mtl_movement_statistics.invoice_reference
    , l_mtl_movement_statistics.invoice_line_reference
    , l_mtl_movement_statistics.invoice_date_reference
    , l_mtl_movement_statistics.invoice_quantity
    , l_mtl_movement_statistics.invoice_unit_price
    , l_mtl_movement_statistics.invoice_line_ext_value
    , l_mtl_movement_statistics.outside_code
    , l_mtl_movement_statistics.outside_ext_value
    , l_mtl_movement_statistics.outside_unit_price
    , l_mtl_movement_statistics.currency_code
    , l_mtl_movement_statistics.currency_conversion_rate
    , l_mtl_movement_statistics.currency_conversion_type
    , l_mtl_movement_statistics.currency_conversion_date
    , l_mtl_movement_statistics.period_name
    , l_mtl_movement_statistics.report_reference
    , l_mtl_movement_statistics.report_date
    , l_mtl_movement_statistics.category_id
    , l_mtl_movement_statistics.weight_method
    , l_mtl_movement_statistics.unit_weight
    , l_mtl_movement_statistics.total_weight
    , l_mtl_movement_statistics.transaction_nature
    , l_mtl_movement_statistics.delivery_terms
    , l_mtl_movement_statistics.transport_mode
    , l_mtl_movement_statistics.alternate_quantity
    , l_mtl_movement_statistics.alternate_uom_code
    , l_mtl_movement_statistics.dispatch_territory_code
    , l_mtl_movement_statistics.destination_territory_code
    , l_mtl_movement_statistics.origin_territory_code
    , l_mtl_movement_statistics.stat_method
    , l_mtl_movement_statistics.stat_adj_percent
    , l_mtl_movement_statistics.stat_adj_amount
    , l_mtl_movement_statistics.stat_ext_value
    , l_mtl_movement_statistics.area
    , l_mtl_movement_statistics.port
    , l_mtl_movement_statistics.stat_type
    , l_mtl_movement_statistics.comments
    , l_mtl_movement_statistics.attribute_category
    , l_mtl_movement_statistics.commodity_code
    , l_mtl_movement_statistics.commodity_description
    , l_mtl_movement_statistics.requisition_header_id
    , l_mtl_movement_statistics.requisition_line_id
    , l_mtl_movement_statistics.picking_line_detail_id
    , l_mtl_movement_statistics.usage_type
    , l_mtl_movement_statistics.zone_code
    , l_mtl_movement_statistics.edi_sent_flag
    , l_mtl_movement_statistics.statistical_procedure_code
    , l_mtl_movement_statistics.movement_amount
    , l_mtl_movement_statistics.triangulation_country_code
    , l_mtl_movement_statistics.csa_code
    , l_mtl_movement_statistics.oil_reference_code
    , l_mtl_movement_statistics.container_type_code
    , l_mtl_movement_statistics.flow_indicator_code
    , l_mtl_movement_statistics.affiliation_reference_code
    , l_mtl_movement_statistics.origin_territory_eu_code
    , l_mtl_movement_statistics.destination_territory_eu_code
    , l_mtl_movement_statistics.dispatch_territory_eu_code
    , l_mtl_movement_statistics.set_of_books_period
    , l_mtl_movement_statistics.taric_code
    , l_mtl_movement_statistics.preference_code
    , l_mtl_movement_statistics.rcv_transaction_id
    , l_mtl_movement_statistics.mtl_transaction_id
    , l_mtl_movement_statistics.total_weight_uom_code
    , l_mtl_movement_statistics.financial_document_flag
    , l_mtl_movement_statistics.customer_vat_number
    , l_mtl_movement_statistics.attribute1
    , l_mtl_movement_statistics.attribute2
    , l_mtl_movement_statistics.attribute3
    , l_mtl_movement_statistics.attribute4
    , l_mtl_movement_statistics.attribute5
    , l_mtl_movement_statistics.attribute6
    , l_mtl_movement_statistics.attribute7
    , l_mtl_movement_statistics.attribute8
    , l_mtl_movement_statistics.attribute9
    , l_mtl_movement_statistics.attribute10
    , l_mtl_movement_statistics.attribute11
    , l_mtl_movement_statistics.attribute12
    , l_mtl_movement_statistics.attribute13
    , l_mtl_movement_statistics.attribute14
    , l_mtl_movement_statistics.attribute15
    , l_mtl_movement_statistics.triangulation_country_eu_code
    , l_mtl_movement_statistics.distribution_line_number
    , l_mtl_movement_statistics.ship_to_name
    , l_mtl_movement_statistics.ship_to_number
    , l_mtl_movement_statistics.ship_to_site
    , l_mtl_movement_statistics.edi_transaction_date
    , l_mtl_movement_statistics.edi_transaction_reference
    , l_mtl_movement_statistics.esl_drop_shipment_code;

    EXIT WHEN val_crsr%NOTFOUND;

    -- Call the validate_movement_statistics  Verification procedure inside
    -- LOOP FOR every record Fetched from the CURSOR
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_procedure_name
                    , 'Processing movement_id '||TO_CHAR(l_mtl_movement_statistics.movement_id)
                  );
    END IF;

    --l_excp_list := l_excp_list_empty;
    l_excp_list.DELETE;


    INV_MGD_MVT_STATS_PVT.Validate_Movement_Statistics
    ( p_movement_statistics      => l_mtl_movement_statistics
    , p_movement_stat_usages_rec => l_movement_stat_usages_rec
    , x_return_status            => x_return_status
    , x_updated_flag             => x_updated_flag
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    , x_excp_list                => l_excp_list
    , x_movement_statistics      => l_ret_movement_statistics
    );

    IF nvl(l_excp_list.COUNT,0) > 0
    THEN
      -------changes for FPJ-------------
      Populate_temp_table
      ( p_excp_list  => l_excp_list
      , p_mtl_movement_transaction =>l_ret_movement_statistics
      );

   /*   INV_MGD_MVT_RPT_GEN.Print_Body( p_excp_list => l_excp_list
                , p_mtl_movement_transaction => l_ret_movement_statistics
                );
   */

    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_procedure_name
                      , 'Record validated with no exception'
                    );
      END IF;
    END IF;

    l_excp_list.DELETE;

    IF x_updated_flag='Y' OR l_ret_movement_statistics.movement_status='V'
    THEN
        INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
	       ( p_movement_statistics => l_ret_movement_statistics
	       , x_return_status   => x_return_status
	       , x_msg_count  => x_msg_count
	       , x_msg_data   => x_msg_data
               );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_mtl_movement_statistics := l_init_movement_statistics ;

  END LOOP;

  ELSE
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF; --IF x_return_status='Y'

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_NAME || l_procedure_name
                  , 'END LOOP on val_crsr'
                );
  END IF;

  -----INV_MGD_MVT_RPT_GEN.Print_Footer(p_page_width => g_rpt_page_col);
  ---- changed for FPJ

  x_msg_data  := NULL;
  x_msg_count := 0;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN

   IF
    FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                          , 'INV_MGD_MVT_Validate_Txn '
                          );
   END IF;

  x_msg_data  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
  x_msg_count := 2;


END Validate_Transaction;

END INV_MGD_MVT_VALIDATE_PROC;

/
