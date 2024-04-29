--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_FIN_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_FIN_MDTR" AS
/* $Header: INVFMDRB.pls 120.12.12010000.7 2010/01/22 06:14:48 skolluku ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVFMDRB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Calc_Exchange_Rate                                                |
--|     Calc_Conversion_Date                                              |
--|     Calc_Invoice_Info                                                 |
--|     Calc_Movement_Amount                                              |
--|     Calc_Statistics_Value                                             |
--|     Get_Set_Of_Books_Period                                           |
--|     Get_Reference_Date                                                |
--|     Log_Initialize                                                    |
--|     Log                                                               |
--|     Calc_Cto_Amount_So                                                |
--|     Calc_Cto_Amount_drp                                               |
--|     Calc_Cto_Amount_rma                                               |
--|     Calc_Cto_Amount_ar                                                |
--|     Calc_Cto_Amount_ap                                                |
--|     Calc_Line_Charge                                                  |
--|     Calc_Total_Line_Charge                                            |
--|     Calc_Processed_Ret_Data                                           |
--| HISTORY                                                               |
--|     12-03-2002  vma  Add code to print to log only if debug profile   |
--|                      option is enabled. This is to comply with new    |
--|                      PL/SQL standard for better performance.          |
--| 07-Nov-06  nesoni   File is modified for bug 5440432 to calculate     |
--|                     invoice correctly for intercompany SO Arrival	  |
--| 22-Jul-07  kdevadas Fix for bug 6035548 - Invoice Details calculated  |
--|			for RMA when selling and shipping orgs are diff.  |
--| 22-Jul-07  kdevadas Fix for bug 6158521 - Calc_Movement_Amount	  |
--|			ignores UOM conversion for Arrival transactions   |
--| 26-Jun-2008 kdevadas Movement ISO uptake - 6889669( ER :4930271)      |
--| 01-oct-08   Ajmittal Fix for bug 7446311 - Calc_Processed_Ret_Data     |
--|         Added one join in cursor l_rtv_cm_po_based.                   |
--+========================================================================

--===================
-- GLOBALS
--===================

g_too_many_transactions_exc  EXCEPTION;
g_no_data_transaction_exc    EXCEPTION;
g_log_level                  NUMBER ;
g_log_mode                   VARCHAR2(3);       -- possible values: OFF, SQL, SRS
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_FIN_MDTR.';

--====================
--Private procedure
--====================
-- ========================================================================
-- PROCEDURE : Get_Conversion_rate PUBLIC
-- PARAMETERS: p_invoice_currency_code - I/C AP invoice currency
--             p_movement_transaction  - movement transaction data record
-- COMMENT   : This function returns the conversion rate based on
--             the conversion date that is set up in the
--             statistical type info form.
--=======================================================================

Function Get_Conversion_Rate
(  p_invoice_currency_code VARCHAR2
,  p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
RETURN NUMBER IS
l_gl_set_of_books_id       VARCHAR2(15);
l_last_dayofperiod         DATE;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Conversion_Rate';
l_period_set_name  mtl_stat_type_usages.period_set_name%type;
l_period_type      mtl_stat_type_usages.period_type%type;
l_conversion_option mtl_stat_type_usages.conversion_option%type;
l_conversion_type  mtl_stat_type_usages.conversion_type%type;
l_currency_conversion_rate number;
l_currency_conversion_date date;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.legal entiry id  - '
                  ,p_movement_transaction.entity_org_id
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.stat type  - '
                  ,p_movement_transaction.stat_type
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.period name  - '
                  ,p_movement_transaction.period_name
                  );


  END IF;

  SELECT
     period_set_name
   , period_type
   , conversion_option
   , conversion_type
  INTO
     l_period_set_name
   , l_period_type
   , l_conversion_option
   , l_conversion_type
  FROM
     mtl_stat_type_usages
  WHERE
    legal_entity_id = p_movement_transaction.entity_org_id
    AND stat_type = p_movement_transaction.stat_type;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.period set name'
                  ,l_period_set_name
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.period type  - '
                  ,l_period_type
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.conversion option  - '
                  ,l_conversion_option
                  );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.conversion type  - '
                  ,l_conversion_type
                  );

  END IF;


  --Get the end date of the period
  SELECT end_date
  INTO
    l_last_dayofperiod
  FROM
    GL_PERIODS
  WHERE period_name     = p_movement_transaction.period_name
    AND period_set_name = l_period_set_name
    AND period_type     = l_period_type;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.last day of period'
                  , l_last_dayofperiod
                  );
 END IF ;

  IF UPPER(l_conversion_option) = 'CO_LAST_DAY'
  THEN

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.co last day'
			  , l_conversion_option
			  );
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.invoice currency code'
			  , p_invoice_currency_code
			  );
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.gl_currency_code'
			  , p_movement_transaction.gl_currency_code
			  );
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.l_last_dayofperiod'
			  , l_last_dayofperiod
			  );
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.l_conversion_type'
			  , l_conversion_type
			  );
	END IF ;

    l_currency_conversion_rate := GL_CURRENCY_API.Get_Rate
    ( x_from_currency   => p_invoice_currency_code
    , x_to_currency   => p_movement_transaction.gl_currency_code
    , x_conversion_date => l_last_dayofperiod
    , x_conversion_type => l_conversion_type
    );

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.conversion rate'
			  , l_currency_conversion_rate
			  );
	 END IF ;


  ELSE

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			  , G_MODULE_NAME || l_procedure_name || '.CO DAILY'
			  , 'in daily conversion routine'
			  );
	 END IF ;

	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
		  THEN
		    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
				  , G_MODULE_NAME || l_procedure_name || '.co last day'
				  , l_conversion_option
				  );
		    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
				  , G_MODULE_NAME || l_procedure_name || '.invoice currency code'
				  , p_invoice_currency_code
				  );
		    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
				  , G_MODULE_NAME || l_procedure_name || '.gl_currency_code'
				  , p_movement_transaction.gl_currency_code
				  );
		    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
				  , G_MODULE_NAME || l_procedure_name || '.l_last_dayofperiod'
				  , l_last_dayofperiod
				  );
		    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
				  , G_MODULE_NAME || l_procedure_name || '.l_conversion_type'
				  , l_conversion_type
				  );
		END IF ;

    l_currency_conversion_date :=
      NVL(p_movement_transaction.invoice_date_reference, p_movement_transaction.transaction_date);

    l_currency_conversion_rate := GL_CURRENCY_API.Get_Rate
    ( x_from_currency   => p_invoice_currency_code
    , x_to_currency   => p_movement_transaction.gl_currency_code
    , x_conversion_date => l_currency_conversion_date
    , x_conversion_type => l_conversion_type
    );
  END IF;

  IF l_currency_conversion_rate IS NULL
  THEN
    l_currency_conversion_rate := 1;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

   return l_currency_conversion_rate;
EXCEPTION
  WHEN GL_CURRENCY_API.no_rate
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No rate exception'
                      , 'Exception'
                      );
      END IF;
      l_currency_conversion_rate := 1;
      return l_currency_conversion_rate;
  WHEN NO_DATA_FOUND
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No data found exception'
                      , 'Exception'
                      );
      END IF;
        l_currency_conversion_rate := 1;
	return l_currency_conversion_rate;
  WHEN OTHERS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.Others exception'
                      , 'Exception'
                      );
      END IF;
      l_currency_conversion_rate := 1;
      return l_currency_conversion_rate;
END Get_Conversion_Rate;


-- ========================================================================
-- PROCEDURE : Calc_Cto_Amount_So   Private
-- PARAMETERS: p_order_line_id      IN order line id
--             p_order_number       IN sales order number
--             x_extended_amount    OUT invoice amount
--             x_cm_extended_amount OUT invoice amount for credit memo
-- COMMENT   : Procedure to calcualte the invoice amount for CTO items
-- ========================================================================
PROCEDURE Calc_Cto_Amount_So
( p_order_line_id      IN NUMBER
, p_order_number       IN VARCHAR2
, x_extended_amount    OUT NOCOPY NUMBER
, x_cm_extended_amount OUT NOCOPY NUMBER
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Cto_Amount_So';

  --Cursor to calculate invoice amount for CTO item
  CURSOR l_cto_amt IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  , oe_order_lines_all oola
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ratt.type                 NOT IN ('CM','DM')
    AND NOT EXISTS
       (SELECT null
        FROM oe_price_adjustments
        WHERE (line_id = oola.line_id
               OR (line_id IS NULL AND modifier_level_code = 'ORDER'))
          AND TO_CHAR(price_adjustment_id)= NVL(ratl.interface_line_attribute11, '-9999')
          AND header_id = oola.header_id)
    AND ratl.line_type            = 'LINE'
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND ratl.sales_order  = p_order_number
    AND ratl.interface_line_attribute6 = to_char(oola.line_id)
    AND oola.top_model_line_id = p_order_line_id
    AND ratl.interface_line_context <> 'INTERCOMPANY';

  --Cursor to calculate invoice amount for CTO item credit memo
  CURSOR l_cto_cm_amt IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  , oe_order_lines_all oola
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ((ratt.type               IN ('CM','DM'))
        OR (NVL(ratl.interface_line_attribute11, '-9999') --Fix bug 2423946
           IN (SELECT TO_CHAR(price_adjustment_id)
                 FROM oe_price_adjustments
                WHERE header_id = oola.header_id
                  AND (line_id = oola.line_id
                       OR (line_id IS NULL AND modifier_level_code = 'ORDER')) )))
    AND ratl.line_type            = 'LINE'
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND ratl.quantity_credited    IS   NULL
    AND ratl.sales_order  = p_order_number
    AND ratl.interface_line_attribute6 = to_char(oola.line_id)
    AND oola.top_model_line_id = p_order_line_id
    AND ratl.interface_line_context <> 'INTERCOMPANY';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --No need to check cursor not found, because cursor with SUM
  --function always return true
  OPEN l_cto_amt;
  FETCH l_cto_amt INTO
    x_extended_amount;
  CLOSE l_cto_amt;

  OPEN l_cto_cm_amt;
  FETCH l_cto_cm_amt INTO
    x_cm_extended_amount;
  CLOSE l_cto_cm_amt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Cto_Amount_So;

-- ========================================================================
-- PROCEDURE : Calc_Cto_Amount_Drp  PUBLIC
-- PARAMETERS: p_order_line_id      IN order line id
--             x_extended_amount    OUT invoice amount
--             x_cm_extended_amount OUT invoice amount for credit memo
-- COMMENT   : Procedure to calcualte the invoice amount for CTO items
-- ========================================================================
PROCEDURE Calc_Cto_Amount_Drp
( p_order_line_id      IN NUMBER
, p_order_number       IN VARCHAR2
, x_extended_amount    OUT NOCOPY NUMBER
, x_cm_extended_amount OUT NOCOPY NUMBER
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Cto_Amount_Drp';

  --Cursor to calculate invoice amount for CTO item for dropship
  CURSOR l_cto_amt_drp IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt     --add in for fixing bug 2447381
  , oe_order_lines_all oola
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ratt.type                 NOT IN ('CM','DM')
    AND NOT EXISTS
        (SELECT null
         FROM oe_price_adjustments
         WHERE (line_id = oola.line_id
                OR (line_id IS NULL AND modifier_level_code = 'ORDER'))
           AND TO_CHAR(price_adjustment_id)= NVL(ratl.interface_line_attribute11, '-9999')
           AND header_id = oola.header_id)
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND ratl.line_type            = 'LINE'  --yawang
    AND ratl.sales_order  = p_order_number
    AND ratl.interface_line_attribute6 = to_char(oola.line_id)
    AND oola.top_model_line_id = p_order_line_id
    AND rat.complete_flag = 'Y'
    AND ratl.interface_line_context <> 'INTERCOMPANY';

  --Cursor to calculate invoice amount for dropship CTO item credit memo
  CURSOR l_cto_cm_amt_drp IS
  SELECT
   SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  , oe_order_lines_all oola
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ((ratt.type               IN ('CM','DM'))
        OR (NVL(ratl.interface_line_attribute11, '-9999') --Fix bug 2423946
           IN (SELECT TO_CHAR(price_adjustment_id)
                 FROM oe_price_adjustments
                WHERE header_id = oola.header_id
                  AND (line_id = oola.line_id
                       OR (line_id IS NULL AND modifier_level_code = 'ORDER')) )))
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND ratl.line_type            = 'LINE'  --yawang
    AND ratl.sales_order  = p_order_number
    AND ratl.interface_line_attribute6 =
                          to_char(oola.line_id)
    AND oola.top_model_line_id = p_order_line_id
    AND rat.complete_flag = 'Y'
    AND ratl.interface_line_context <> 'INTERCOMPANY';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --No need to check cursor not found, because cursor with SUM
  --function always return true
  OPEN l_cto_amt_drp;
  FETCH l_cto_amt_drp INTO
    x_extended_amount;
  CLOSE l_cto_amt_drp;

  OPEN l_cto_cm_amt_drp;
  FETCH l_cto_cm_amt_drp INTO
    x_cm_extended_amount;
  CLOSE l_cto_cm_amt_drp;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Cto_Amount_Drp;

-- ========================================================================
-- PROCEDURE : Calc_Cto_Amount_Rma   Private
-- PARAMETERS: p_order_line_id      IN order line id
--             p_org_id             IN operating unit id
--             x_extended_amount    OUT invoice amount
-- COMMENT   : Procedure to calcualte the invoice amount for CTO items
-- ========================================================================
PROCEDURE Calc_Cto_Amount_Rma
( p_order_line_id      IN NUMBER
, p_order_number       IN VARCHAR2
, p_org_id             IN NUMBER
, x_extended_amount    OUT NOCOPY NUMBER
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Cto_Amount_Rma';

  --Cursor to calculate invoice amount for RMA CTO item
  /* Bug 8435314 */
  /*CURSOR l_cto_amt_rma IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  , oe_order_lines_all oola
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ratt.type                 IN ('CM','DM')
    AND ratl.line_type            = 'LINE'  --yawang
    AND ratl.quantity_credited    IS  NOT NULL
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND NVL(ratl.org_id,0)  = NVL(p_org_id,0)
    AND ratl.interface_line_attribute6 = to_char(oola.line_id)
    AND ratl.sales_order  = p_order_number
    AND oola.top_model_line_id = p_order_line_id
    AND ratl.interface_line_context <> 'INTERCOMPANY';*/

  CURSOR l_cto_amt_rma IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
    AND rat.cust_trx_type_id      = ratt.cust_trx_type_id
    AND rat.org_id                = ratt.org_id
    AND ratt.type                 IN ('CM','DM')
    AND ratl.line_type            = 'LINE'  --yawang
    AND ratl.quantity_credited    IS  NOT NULL
    AND NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
    AND NVL(ratl.org_id,0)  = NVL(p_org_id,0)
    AND ratl.interface_line_attribute6 In
        ( SELECT DISTINCT To_Char(ol.line_id) FROM  oe_order_lines_all ol
          WHERE (return_attribute1,return_attribute2) IN
                  (SELECT header_id,line_id FROM oe_order_lines_all ol1
                  WHERE (header_id,Top_model_line_id) IN
                         (SELECT  return_attribute1,return_attribute2 FROM  oe_order_lines_all ol
                           WHERE  ol.line_id=p_order_line_id )))
    AND ratl.interface_line_attribute1  = p_order_number
    AND ratl.interface_line_context <> 'INTERCOMPANY';
    /*End bug 8435314 */

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --No need to check cursor not found, because cursor with SUM
  --function always return true
  OPEN l_cto_amt_rma;
  FETCH l_cto_amt_rma INTO
    x_extended_amount;
  CLOSE l_cto_amt_rma;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Cto_Amount_Rma;

-- ========================================================================
-- PROCEDURE : Calc_Cto_Amount_Ar   Private
-- PARAMETERS: p_order_line_id      IN order line id
--             x_extended_amount    OUT invoice amount
-- COMMENT   : Procedure to calcualte the invoice amount for CTO items
-- ========================================================================
PROCEDURE Calc_Cto_Amount_Ar
( p_order_line_id      IN NUMBER
, p_order_number       IN VARCHAR2
, x_extended_amount    OUT NOCOPY NUMBER
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Cto_Amount_Ar';

  --Cursor to calculate invoice amount for ar intercompany invoice for CTO item
  CURSOR l_cto_amt_ar IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_LINES_ALL ratl
  , oe_order_lines_all oola
  WHERE ratl.line_type            = 'LINE'
    AND ratl.interface_line_attribute6 = to_char(oola.line_id)
    AND ratl.sales_order  = p_order_number
    AND oola.top_model_line_id = p_order_line_id
    AND ratl.interface_line_context = 'INTERCOMPANY';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --No need to check cursor not found, because cursor with SUM
  --function always return true
  OPEN l_cto_amt_ar;
  FETCH l_cto_amt_ar INTO
    x_extended_amount;
  CLOSE l_cto_amt_ar;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Cto_Amount_Ar;

-- ========================================================================
-- PROCEDURE : Calc_Cto_Amount_Ap   Private
-- PARAMETERS: p_order_line_id      IN order line id
--             x_extended_amount    OUT invoice amount
-- COMMENT   : Procedure to calcualte the invoice amount for CTO items
-- ========================================================================
PROCEDURE Calc_Cto_Amount_Ap
( p_order_line_id      IN NUMBER
, p_order_number       IN VARCHAR2
, x_extended_amount    OUT NOCOPY NUMBER
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Cto_Amount_Ap';

  -- Bug 5440432: Following query is modified to replace where clause
  -- 'AND rcta.trx_number||'-'||rcta.org_id = aia.invoice_num' with
  -- 'AND (rcta.trx_number||'-'||rcta.org_id = aia.invoice_num
  -- OR rcta.trx_number = aia.invoice_num)'
  -- This change was introduced because of bug 4180686 in 11.5.10

  --Cursor to calculate invoice amount for ap intercompany invoice for CTO item
  CURSOR l_cto_amt_ap IS
  SELECT
    SUM(NVL(aila.amount,rctla.extended_amount))
  FROM
    AP_INVOICES_ALL aia
   , AP_INVOICE_LINES_ALL aila
  , RA_CUSTOMER_TRX_LINES_ALL rctla
  , ra_customer_trx_all rcta
  , oe_order_lines_all oola
   WHERE aia.invoice_id = aila.invoice_id
     AND aia.cancelled_date IS NULL
     AND aila.line_type_lookup_code = 'ITEM'
     AND aia.reference_1  = TO_CHAR(rctla.customer_trx_id)
     AND aila.reference_1 = TO_CHAR(rctla.customer_trx_line_id)
     AND rctla.customer_trx_id = rcta.customer_trx_id
     AND (rcta.trx_number||'-'||rcta.org_id = aia.invoice_num
         OR rcta.trx_number = aia.invoice_num)
    AND rctla.sales_order  = p_order_number
    AND rctla.interface_line_attribute6 = to_char(oola.line_id)
    AND oola.top_model_line_id = p_order_line_id
    AND nvl(aila.discarded_flag, 'N') <> 'Y'
    AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
    AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --No need to check cursor not found, because cursor with SUM
  --function always return true
  OPEN l_cto_amt_ap;
  FETCH l_cto_amt_ap INTO
    x_extended_amount;
  CLOSE l_cto_amt_ap;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Cto_Amount_Ap;


-- ========================================================================
-- PROCEDURE : Calc_Line_Charge        Private
-- PARAMETERS: p_line_id               IN  order line id
--             p_invoiced_line_qty     IN  invoiced quantity for this line
--             x_line_freight_charge   OUT line level freight charge
-- COMMENT   : Procedure to calcualte the line level freight charge
-- ========================================================================
PROCEDURE Calc_Line_Charge
( p_line_id              IN NUMBER
, p_invoiced_line_qty    IN NUMBER
, x_line_freight_charge  OUT NOCOPY NUMBER
)
IS
l_line_freight_unit_amt NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Line_Charge';

--Find out line level freight charge per unit
CURSOR c_adj_line_freight
IS
SELECT
  SUM(NVL(ADJUSTED_AMOUNT_PER_PQTY,0))
FROM
  oe_price_adjustments
WHERE line_id = p_line_id
  AND modifier_level_code = 'LINE'
  AND list_line_type_code = 'FREIGHT_CHARGE';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN c_adj_line_freight;
  FETCH c_adj_line_freight INTO l_line_freight_unit_amt;
  CLOSE c_adj_line_freight;

  --Check null value. Can not use cursor%notfound,because sum
  --function in cursor select always returns a row (found)
  IF l_line_freight_unit_amt IS NULL
  THEN
    l_line_freight_unit_amt := 0;
  END IF;

  --Use invoiced quantity to calculate the line level charge, because the
  --invoiced qty may be different from the ordered quantity
  x_line_freight_charge := l_line_freight_unit_amt * nvl(p_invoiced_line_qty,0);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Line_Charge;

-- ========================================================================
-- PROCEDURE : Calc_Total_Line_Charge  Private
-- PARAMETERS: p_movement_transaction  IN movement transaction record
--             x_total_line_charge     OUT line level charge for all lines
--             x_total_invoiced_qty    OUT total invoiced qty for this order
-- COMMENT   : Procedure to calcualte total line level charge
-- ========================================================================
PROCEDURE Calc_Total_Line_Charge
( p_movement_transaction IN INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_this_line_charge     OUT NOCOPY NUMBER
, x_total_line_charge    OUT NOCOPY NUMBER
, x_total_invoiced_qty   OUT NOCOPY NUMBER
)
IS
l_line_id             NUMBER;
l_model_line_id       NUMBER;
l_item_type_code      oe_order_lines_all.item_type_code%TYPE;
l_invoiced_line_qty   NUMBER;
l_total_invoiced_qty  NUMBER  :=0;
l_line_freight_charge NUMBER;
l_total_line_charge   NUMBER := 0;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Total_Line_Charge';

--Find out all the order lines which share an invoice with the processing
--order line
CURSOR c_order_lines IS
SELECT DISTINCT
 TO_NUMBER(interface_line_attribute6)
FROM
  ra_customer_trx_lines_all
WHERE sales_order = to_char(p_movement_transaction.order_number)
  AND line_type = 'LINE'
  AND customer_trx_id IN
      (SELECT customer_trx_id
         FROM ra_customer_trx_lines_all
        WHERE interface_line_attribute6 = to_char(p_movement_transaction.order_line_id)
          AND sales_order = to_char(p_movement_transaction.order_number))
ORDER BY TO_NUMBER(interface_line_attribute6);

--Find out if this item is a CTO item
CURSOR c_cto IS
  SELECT
    item_type_code
  , top_model_line_id
  FROM
    oe_order_lines_all
  WHERE line_id = p_movement_transaction.order_line_id;

--Calculate the invoice quantity for an order line
CURSOR c_invoiced_line_qty IS
  SELECT
    SUM(NVL(ratl.quantity_invoiced,0))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ratt.type                 NOT IN ('CM','DM')
  AND   NVL(ratl.interface_line_attribute11, '-9999')  --Fix bug 2423946
        NOT IN (SELECT TO_CHAR(price_adjustment_id)
                  FROM oe_price_adjustments
                 WHERE header_id = p_movement_transaction.order_header_id
                   AND (line_id  = l_line_id
                        OR (line_id IS NULL AND modifier_level_code = 'ORDER')))
  AND   ratl.line_type            = 'LINE'
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.sales_order  = to_char(p_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 = l_line_id
  AND   ratl.interface_line_context <> 'INTERCOMPANY';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN c_order_lines;
  LOOP
    FETCH c_order_lines INTO l_line_id;
    EXIT WHEN c_order_lines%NOTFOUND;

    --Check if this order line is of CTO item
    OPEN c_cto;
    FETCH c_cto INTO
      l_item_type_code
    , l_model_line_id;
    CLOSE c_cto;

    IF l_item_type_code = 'CONFIG'
    THEN
      l_line_id := l_model_line_id;
    END IF;

    --Calculate invoiced qty for this line in the line loop
    OPEN c_invoiced_line_qty;
    FETCH c_invoiced_line_qty INTO l_invoiced_line_qty;
    CLOSE c_invoiced_line_qty;

    IF l_invoiced_line_qty IS NULL
    THEN
      l_invoiced_line_qty := 0;
    END IF;

    --Calculate line charge (using invoiced qty) for this line in
    --the line loop
    Calc_Line_Charge
    ( p_line_id             => l_line_id
    , p_invoiced_line_qty   => l_invoiced_line_qty
    , x_line_freight_charge => l_line_freight_charge
    );

    --The line charge for the processing line in calling program. This value will
    --be passed back to calling program so that the calling program does not need
    --to call calc_line_charge again
    IF l_line_id = p_movement_transaction.order_line_id
    THEN
      x_this_line_charge := l_line_freight_charge;
    END IF;

    --Total invoiced qty and total line charge
    l_total_invoiced_qty := l_total_invoiced_qty + l_invoiced_line_qty;
    l_total_line_charge  := l_total_line_charge + l_line_freight_charge;
  END LOOP;
  CLOSE c_order_lines;

  x_total_invoiced_qty := l_total_invoiced_qty;
  x_total_line_charge  := l_total_line_charge;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Total_Line_Charge;

-- ========================================================================
-- PROCEDURE : Calc_Processed_Ret_Data  Private
-- PARAMETERS: p_movement_transaction  IN movement transaction record
--             x_processed_ret_amt     OUT line level charge for all lines
--             x_processed_ret_qty     OUT total invoiced qty for this order
-- COMMENT   : Procedure to calcualte processed invoice amount and quantity
--             for RTV and RMA
-- ========================================================================
PROCEDURE Calc_Processed_Ret_Data
( p_movement_transaction IN INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_processed_ret_amt    OUT NOCOPY NUMBER
, x_processed_ret_qty    OUT NOCOPY NUMBER
)
IS
l_rtv_count               NUMBER;
l_processed_rtv_trans_qty NUMBER;
l_total_rtv_trans_qty     NUMBER;
l_rma_count               NUMBER;
l_parent_transaction_id   NUMBER;
l_rtv_extended_amount     NUMBER;
l_rtv_invoice_quantity    NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Processed_Ret_Data';

  --Cursor to get processed rma count for a given SO
  --Fix bug 2861110
  CURSOR l_rma IS
  SELECT
    count(transaction_id)
  FROM
    rcv_transactions rt
  , oe_order_lines_all oola
  WHERE rt.oe_order_line_id = oola.line_id
    AND oola.reference_line_id = to_char(p_movement_transaction.order_line_id)
    AND rt.mvt_stat_status = 'PROCESSED'
    AND rt.source_document_code = 'RMA';

  --Cursor to get processed rma invoice for a given SO
  --Fix bug 2861110
  CURSOR l_rma_processed IS
  SELECT
    SUM(NVL(ratl.extended_amount,0))
  , SUM(NVL(ratl.quantity_credited,0))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  , OE_ORDER_LINES_ALL oola
  , RCV_TRANSACTIONS rt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ratt.type                 IN ('CM','DM')
  AND   ratl.line_type            = 'LINE'  --yawang
  AND   ratl.quantity_credited    IS  NOT NULL
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
 -- AND   NVL(ratl.org_id,0)  = NVL(p_movement_transaction.org_id,0)
  AND   ratl.interface_line_attribute6 = to_char(oola.line_id)
  AND   oola.reference_line_id     = to_char(p_movement_transaction.order_line_id)
  AND   rt.oe_order_line_id  = oola.line_id
  AND   rt.mvt_stat_status = 'PROCESSED'
  AND   rt.transaction_type = 'DELIVER'
  AND   ratl.interface_line_context <> 'INTERCOMPANY'
  AND   oola.line_id NOT IN (SELECT order_line_id
                               FROM mtl_movement_statistics
                              WHERE entity_org_id = p_movement_transaction.entity_org_id
                                AND zone_code     = p_movement_transaction.zone_code
                                AND usage_type    = p_movement_transaction.usage_type
                                AND stat_type     = p_movement_transaction.stat_type
                                AND document_source_type = 'RMA'
                                AND rcv_transaction_id = rt.transaction_id);

  --Cursor to check if this PO receipt has any processed RTV
  --Fix bug 2861110
  CURSOR l_rtv IS
  SELECT
    COUNT(transaction_id)
  FROM
    rcv_transactions
  WHERE transaction_type = 'RETURN TO VENDOR'
    AND parent_transaction_id = p_movement_transaction.rcv_transaction_id
    AND mvt_stat_status = 'PROCESSED';

  --Cursor to get total rtv transaction quantity for Italian LE
  --fix bug 2861110
  CURSOR l_total_rtv_quantity IS
  SELECT
    SUM(quantity)
  FROM
    rcv_transactions
  WHERE po_header_id = p_movement_transaction.po_header_id
    AND transaction_type = 'RETURN TO VENDOR';

  --Cursor to get processed rtv transaction quantity exclude
  --those RTV that created in next period, which will create
  --seperate MS record with its own credit memo as invoice info
  CURSOR l_netted_rtv_quantity IS
  SELECT
    SUM(quantity)
  FROM
    rcv_transactions rt
  WHERE po_header_id = p_movement_transaction.po_header_id
    AND transaction_type = 'RETURN TO VENDOR'
    AND mvt_stat_status = 'PROCESSED'
    AND transaction_id NOT IN (SELECT rcv_transaction_id
                                 FROM mtl_movement_statistics
                                WHERE document_source_type = 'RTV'
                                  AND po_header_id = rt.po_header_id
                                  AND entity_org_id = p_movement_transaction.entity_org_id
                                  AND zone_code     = p_movement_transaction.zone_code
                                  AND usage_type    = p_movement_transaction.usage_type
                                  AND stat_type     = p_movement_transaction.stat_type);

  --Cursor for Credit memos that is associated with RTV transaction
  --in case of receipt based matching
  -- Bug 5655040.Cursor has been modified to AP Line tables in place of Distributions
  --CURSOR l_rtv_cm_receipt_based IS
  ---SELECT
  --  SUM(apid.amount)
  --, SUM(apid.quantity_invoiced)
  --FROM
  --  AP_INVOICES_ALL api,
  --  AP_INVOICE_DISTRIBUTIONS_ALL apid
  --WHERE api.invoice_id = apid.invoice_id
  --AND   api.invoice_type_lookup_code in ('CREDIT','DEBIT')
  --AND   apid.rcv_transaction_id    = l_parent_transaction_id
  --AND   apid.line_type_lookup_code = 'ITEM' --yawang, limit for good cost only
  --AND   NVL(apid.quantity_invoiced,0) < 0
  --AND   api.cancelled_date IS NULL
  --AND  (NVL(apid.match_status_flag,'N') = 'A'
  --      OR (NVL(apid.match_status_flag,'N') = 'T'
  --          AND api.wfapproval_status = 'NOT REQUIRED'));

  CURSOR l_rtv_cm_receipt_based IS
  SELECT
    SUM(aila.amount)
  , SUM(aila.quantity_invoiced)
  FROM
    AP_INVOICES_ALL aia,
    AP_INVOICE_LINES_ALL aila
  WHERE aia.invoice_id = aila.invoice_id
  AND   aia.invoice_type_lookup_code in ('CREDIT','DEBIT')
  AND   aila.rcv_transaction_id    = l_parent_transaction_id
  AND   aila.line_type_lookup_code = 'ITEM'
  AND   NVL(aila.quantity_invoiced,0) < 0
  AND   aia.cancelled_date IS NULL
  AND nvl(aila.discarded_flag, 'N') <> 'Y'
  AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
  AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

  -- Cursor for RTV's where credit memo is to be associated with
  -- RTV in case of PO based matching.
  -- Bug 5655040.Cursor has been modified to AP Line tables in place of Distributions
  --CURSOR l_rtv_cm_po_based IS
  --SELECT
  --  SUM(a.amount)       --yawang
  --, SUM(quantity_invoiced)
  --FROM
  --  PO_HEADERS_ALL b
  --, PO_DISTRIBUTIONS_ALL c
  --, AP_INVOICES_ALL d
  --, AP_INVOICE_DISTRIBUTIONS_ALL a
  --WHERE b.po_header_id              = c.po_header_id
  --AND   d.invoice_id                = a.invoice_id
  --AND   c.po_distribution_id        = a.po_distribution_id
  --AND  (NVL(a.match_status_flag,'N') = 'A'
  --      OR (NVL(a.match_status_flag,'N') = 'T'
  --          AND d.wfapproval_status = 'NOT REQUIRED'))
  --AND   d.invoice_type_lookup_code in ('CREDIT','DEBIT')
  --AND   d.cancelled_date IS NULL
  --AND   a.line_type_lookup_code = 'ITEM' --yawang, limit for good cost only
  --AND   NVL(a.quantity_invoiced,0) < 0
  --AND   b.po_header_id       = p_movement_transaction.po_header_id
  --AND   c.line_location_id   = p_movement_transaction.po_line_location_id;
  CURSOR l_rtv_cm_po_based IS
  SELECT
    SUM(aila.amount)       --yawang
  , SUM(aila.quantity_invoiced)
  FROM
    PO_HEADERS_ALL pha
  , PO_DISTRIBUTIONS_ALL pda
  , AP_INVOICES_ALL aia
  , AP_INVOICE_LINES_ALL aila
  WHERE pha.po_header_id              = pda.po_header_id
  AND   aia.invoice_id                = aila.invoice_id
  AND   pda.po_header_id              = aila.po_header_id   /*Bug 7446311 Joined to imporve performance*/
  AND   pda.po_distribution_id        = aila.po_distribution_id
  AND   aia.invoice_type_lookup_code in ('CREDIT','DEBIT')
  AND   aia.cancelled_date IS NULL
  AND   aila.line_type_lookup_code = 'ITEM' --yawang, limit for good cost only
  AND   NVL(aila.quantity_invoiced,0) < 0
  AND   pha.po_header_id       = p_movement_transaction.po_header_id
  AND   pda.line_location_id   = p_movement_transaction.po_line_location_id
  AND nvl(aila.discarded_flag, 'N') <> 'Y'
  AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
  AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  IF p_movement_transaction.document_source_type = 'SO'
  THEN
    OPEN l_rma;
    FETCH l_rma INTO
      l_rma_count;
    CLOSE l_rma;

    IF l_rma_count > 0
    THEN
      OPEN l_rma_processed;
      FETCH l_rma_processed INTO
        x_processed_ret_amt
      , x_processed_ret_qty;
      CLOSE l_rma_processed;
    END IF;
  ELSIF p_movement_transaction.document_source_type = 'PO'
  THEN
    OPEN l_rtv;
    FETCH l_rtv INTO
      l_rtv_count;
    CLOSE l_rtv;

    IF l_rtv_count > 0
    THEN
      --RTV is child of PO. To find RTV credit memo, needs to know the
      --parent id of the rtv. Parent id of rtv is the rcv transaction id of
      --current PO, which is used in receipt based matching
      l_parent_transaction_id := p_movement_transaction.rcv_transaction_id;

      --Open receipt based matching rtv credit memo cursor
      OPEN l_rtv_cm_receipt_based;
      FETCH l_rtv_cm_receipt_based INTO
        l_rtv_extended_amount
      , l_rtv_invoice_quantity;

      --If not receipt based credit memo, open po based credit memo for rtv
      IF l_rtv_cm_receipt_based%NOTFOUND OR l_rtv_extended_amount IS NULL
      THEN
        OPEN l_rtv_cm_po_based;
        FETCH l_rtv_cm_po_based INTO
          l_rtv_extended_amount
        , l_rtv_invoice_quantity;

        IF l_rtv_cm_po_based%NOTFOUND OR l_rtv_extended_amount IS NULL
        THEN
          l_rtv_extended_amount := 0;
          l_rtv_invoice_quantity := 0;
        END IF;

        CLOSE l_rtv_cm_po_based;
      END IF;
      CLOSE l_rtv_cm_receipt_based;

      --Find total rtv transaction quantity
      OPEN l_total_rtv_quantity;
      FETCH l_total_rtv_quantity INTO
        l_total_rtv_trans_qty;
      CLOSE l_total_rtv_quantity;

      --Find netted rtv transaction quantity
      OPEN l_netted_rtv_quantity;
      FETCH l_netted_rtv_quantity INTO
        l_processed_rtv_trans_qty;
      CLOSE l_netted_rtv_quantity;

      --Find processed rtv invoice amount and invoice quantity
      IF l_total_rtv_trans_qty IS NOT NULL
      THEN
        x_processed_ret_amt := (l_processed_rtv_trans_qty/l_total_rtv_trans_qty)
                                   * l_rtv_extended_amount;
        x_processed_ret_qty := (l_processed_rtv_trans_qty/l_total_rtv_trans_qty)
                                   * l_rtv_invoice_quantity;
      END IF;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Calc_Processed_Ret_Data;


--====================
--Public procedure
--====================

--========================================================================
-- PROCEDURE : Exchange_Rate_Calc PUBLIC
-- PARAMETERS:
--             p_stat_typ_transaction  mtl_stat_type_usages data record
--             p_movement_transaction  movement transaction data record
-- COMMENT   : This function returns the exchange rate based on
--             the conversion date that is set up in the
--             statistical type info form.
--=======================================================================

PROCEDURE Calc_Exchange_Rate
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
)
IS
l_gl_set_of_books_id       VARCHAR2(15);
l_last_dayofperiod         DATE;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Exchange_Rate';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --Get the end date of the period
  SELECT end_date
  INTO
    l_last_dayofperiod
  FROM
    GL_PERIODS
  WHERE period_name     = x_movement_transaction.period_name
    AND period_set_name = p_stat_typ_transaction.period_set_name
    AND period_type     = p_stat_typ_transaction.period_type;

  IF UPPER(p_stat_typ_transaction.conversion_option) = 'CO_LAST_DAY'
  THEN
    x_movement_transaction.currency_conversion_rate := GL_CURRENCY_API.Get_Rate
    ( x_from_currency   => x_movement_transaction.currency_code
    , x_to_currency   => x_movement_transaction.gl_currency_code
    , x_conversion_date => l_last_dayofperiod
    , x_conversion_type => x_movement_transaction.currency_conversion_type
    );

    x_movement_transaction.currency_conversion_date := l_last_dayofperiod;
  ELSE
    x_movement_transaction.currency_conversion_date :=
      NVL(x_movement_transaction.invoice_date_reference, x_movement_transaction.transaction_date);

    x_movement_transaction.currency_conversion_rate := GL_CURRENCY_API.Get_Rate
    ( x_from_currency   => x_movement_transaction.currency_code
    , x_to_currency   => x_movement_transaction.gl_currency_code
    , x_conversion_date => x_movement_transaction.currency_conversion_date
    , x_conversion_type => x_movement_transaction.currency_conversion_type
    );
  END IF;

  IF x_movement_transaction.currency_conversion_rate IS NULL
  THEN
    x_movement_transaction.currency_conversion_rate := 1;
    x_movement_transaction.currency_conversion_type := null;
    x_movement_transaction.currency_conversion_date := null;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN GL_CURRENCY_API.no_rate
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No rate exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction.currency_conversion_rate := 1;
      x_movement_transaction.currency_conversion_type := null;
      x_movement_transaction.currency_conversion_date := null;
  WHEN NO_DATA_FOUND
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No data found exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction.currency_conversion_rate := 1;
      x_movement_transaction.currency_conversion_type := null;
      x_movement_transaction.currency_conversion_date := null;
  WHEN OTHERS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.Others exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction.currency_conversion_rate := 1;
      x_movement_transaction.currency_conversion_type := null;
      x_movement_transaction.currency_conversion_date := null;
END Calc_Exchange_Rate;

--========================================================================
-- FUNCTION : Calc_Movement_AMount PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- COMMENT   : Calculates and returns the Movement Amount value
--=======================================================================

FUNCTION Calc_Movement_Amount
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
RETURN NUMBER
IS
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_report_price         NUMBER;
  l_tr_value             NUMBER;
  l_inv_uom              VARCHAR2(10);
  l_trans_conv_inv_rate  NUMBER;
  l_inv_qty              NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Movement_Amount';
  l_invoice_currency   VARCHAR2(10);
  l_currency_conversion_rate  NUMBER;

  CURSOR inv_uom IS
  SELECT
    uom_code
  FROM
    ra_customer_trx_lines_all
  WHERE customer_trx_line_id = l_movement_transaction.customer_trx_line_id;

  /* Bug 6158521 - Start */
  /* Define cursor to the invoice UOM for AP invoices */
  CURSOR poinv_uom IS
  SELECT
	UOM.UOM_CODE
  FROM
	AP_INVOICE_DISTRIBUTIONS_ALL AID,MTL_UNITS_OF_MEASURE UOM
  WHERE AID.invoice_id = l_movement_transaction.invoice_id
  AND AID.distribution_line_number = l_movement_transaction.distribution_line_number
  AND AID.MATCHED_UOM_LOOKUP_CODE=UOM.UNIT_OF_MEASURE;

/* Bug 6158521 - End */

BEGIN

  l_currency_conversion_rate := 1; -- 6889669
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction := p_movement_transaction;

  -----------------------------------------------
  -- INVOICE_ID is not null                    --
  -----------------------------------------------
  IF l_movement_transaction.invoice_id is not null
     AND (l_movement_transaction.document_source_type IN ('SO','RMA', 'IO') -- 6889669
     OR  l_movement_transaction.document_source_type IN ('PO','RTV'))
  THEN
    --Invoice quantity may have different uom than transaction qty
    --convert invoice qty to same uom as transaction qty
    --This is for SO only
    IF (l_movement_transaction.document_source_type IN ('SO','RMA')
       AND l_movement_transaction.customer_trx_line_id IS NOT NULL)
    THEN
      OPEN inv_uom;
      FETCH inv_uom INTO l_inv_uom;
      IF inv_uom%NOTFOUND
      THEN
        l_inv_uom := l_movement_transaction.transaction_uom_code;
      END IF;
      CLOSE inv_uom;

   /* Bug 6158521 - Start */
   /* Call INV UOM conversion if invoice UOM is different from txn UOM */
    ELSE
       IF (l_movement_transaction.distribution_line_number IS NOT NULL)
       THEN
	OPEN poinv_uom;
	FETCH poinv_uom INTO l_inv_uom;
	IF poinv_uom%NOTFOUND
	Then
      l_inv_uom := l_movement_transaction.transaction_uom_code;
	END IF;
        CLOSE poinv_uom;
	ELSE
		l_inv_uom := l_movement_transaction.transaction_uom_code;
	END IF;
    END IF;

    IF l_movement_transaction.transaction_uom_code <> l_inv_uom
    THEN
      INV_CONVERT.Inv_Um_Conversion
      ( from_unit   => l_movement_transaction.transaction_uom_code
      , to_unit     => l_inv_uom
      , item_id     => l_movement_transaction.inventory_item_id
      , uom_rate    => l_trans_conv_inv_rate
      );
    ELSE
      l_trans_conv_inv_rate := 1;
    END IF;

    /* Special case for Internal Orders  - 6889669  - BEGIN */
    IF (l_movement_transaction.document_source_type = 'IO')
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_procedure_name || '.begin'
                      ,'in Calc Movement Amount for IO'
                      );
      END IF;

      /* Invoice conversion for I/C AP - 6889669 - Start*/
      /* For an IO Arrival, ensure that the invoice currency is the
      same as the SOB currency, if not do the necessary conversion
      Note: This does NOT have to be done for IO dispatch as the currency
      is pulled from the shipping transaction whereas for an IO arrival,
      the currency is pulled from the Receiving transactions */

      IF (l_movement_transaction.movement_type  = 'A') THEN
	BEGIN
	  SELECT
	     NVL(invoice_currency_code, -1)
	  INTO
	     l_invoice_currency
	  FROM
	     AP_INVOICES_ALL
	  WHERE
	     invoice_id = l_movement_transaction.invoice_id ;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			 , G_MODULE_NAME || l_procedure_name || '.begin'
			  ,'The I/C AP invoice currency is '||l_invoice_currency
			   );
	   END IF;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			 , G_MODULE_NAME || l_procedure_name || '.begin'
			  ,'The GL currency code is '||l_movement_transaction.gl_currency_code
			   );
	   END IF;

	   IF (l_invoice_currency <> l_movement_transaction.gl_currency_code) THEN
	     l_currency_conversion_rate := Get_Conversion_Rate(l_invoice_currency,l_movement_transaction );
	   END IF;
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			 , G_MODULE_NAME || l_procedure_name || '.begin'
			  ,'The currency conversion is  '||l_currency_conversion_rate
			   );
	   END IF;

	EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			 , G_MODULE_NAME || l_procedure_name || '.begin'
			  ,'No data found for Internal Order I/C AP'
			   );
	   END IF;
        WHEN OTHERS THEN
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	  THEN
	    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
		      , G_MODULE_NAME || l_procedure_name || '.begin'
		      ,'Others exception for Internal Order I/C AP'
		      );
	  END IF;
        END;
      END IF ;

      /* Invoice conversion for I/C AP - 6889669 - End*/

      OPEN inv_uom;
      FETCH inv_uom INTO l_inv_uom;
      IF inv_uom%NOTFOUND
      THEN
        l_inv_uom := l_movement_transaction.transaction_uom_code;
      END IF;
      CLOSE inv_uom;
    -- Bug 7833114
    -- Removed else condition as it is reverting Invoice_Uom to transation_uom if it is not IO
    -- skolluku
    --ELSE
    --  l_inv_uom := l_movement_transaction.transaction_uom_code;
    END IF;

    IF l_movement_transaction.transaction_uom_code <> l_inv_uom
    THEN
      INV_CONVERT.Inv_Um_Conversion
      ( from_unit   => l_movement_transaction.transaction_uom_code
      , to_unit     => l_inv_uom
      , item_id     => l_movement_transaction.inventory_item_id
      , uom_rate    => l_trans_conv_inv_rate
      );
    ELSE
      l_trans_conv_inv_rate := 1;
    END IF;
    /* Special case for Internal Orders  - 6889669  - BEGIN */

    l_inv_qty := ROUND(l_movement_transaction.invoice_quantity / l_trans_conv_inv_rate,2);

    --transaction quantity maybe negative for Italian RTV and RMA
    --when this procedurre is called in update_invoice. bug 2861110
    IF abs(l_inv_qty) = abs(l_movement_transaction.transaction_quantity)
    THEN
      l_tr_value := l_movement_transaction.invoice_line_ext_value;
    ELSE
      IF abs(l_inv_qty) < abs(l_movement_transaction.transaction_quantity)
      THEN
        l_report_price := NVL(l_movement_transaction.document_unit_price,0)
                       + NVL(l_movement_transaction.outside_unit_price,0);

        l_tr_value :=  (abs(l_movement_transaction.transaction_quantity)
                        - abs(NVL(l_inv_qty,0))) * l_report_price
                       +abs(l_movement_transaction.invoice_line_ext_value);
      ELSE
        --Bug 3665762, in the case of update invoice, the movement amount should not
        --be updated to 0 for dropshipment, set the movement amount to invoice value
        IF (l_movement_transaction.transaction_nature = '17'
           AND l_movement_transaction.transaction_quantity = 0)
        THEN
          l_tr_value := l_movement_transaction.invoice_line_ext_value;
        ELSE
          l_tr_value :=  abs(l_movement_transaction.transaction_quantity)
                       * l_movement_transaction.invoice_unit_price * l_trans_conv_inv_rate;
        END IF;
      END IF;

      /*
      IF (l_movement_transaction.document_source_type='RTV') THEN
        IF (abs(l_movement_transaction.invoice_quantity)) =
          (abs(l_movement_transaction.transaction_quantity)) THEN
        l_tr_value := l_movement_transaction.invoice_line_ext_value;
        END IF;
      END IF;
    */

    END IF;
  --------------------------------------------------
  -- INVOICE_ID is null                           --
  --------------------------------------------------
  ELSE
    IF abs(NVL(l_movement_transaction.invoice_quantity,0)) =
	abs(l_movement_transaction.transaction_quantity)
    THEN
      l_tr_value := l_movement_transaction.document_line_ext_value;
    ELSE
      -- if DOCUMENT_SOURCE_TYPE is a Sales Order
      -- or DOCUMENT_SOURCE_TYPE is a Purchase Order
      -- or DOCUMENT_SOURCE_TYPE is a Return of Merchandize
      --    Authorization
      -- or DOCUMENT_SOURCE_TYPE is miscellaneous
      --    with a price not equal to 0

      IF l_movement_transaction.document_source_type    IN ('SO', 'IO') -- 6889669
         OR l_movement_transaction.document_source_type  = 'PO'
         OR l_movement_transaction.document_source_type  = 'RTV'
         OR l_movement_transaction.document_source_type  = 'RMA'
         OR (l_movement_transaction.document_source_type = 'MISC'
         AND NVL(l_movement_transaction.document_unit_price,0) <> 0)
      THEN
        l_report_price := NVL(l_movement_transaction.document_unit_price,0)
                          + NVL(l_movement_transaction.outside_unit_price,0);
      ELSE
        l_report_price := NVL(l_movement_transaction.item_cost,0)
                        + NVL(l_movement_transaction.outside_unit_price,0);
      END IF;

      l_tr_value := (abs(l_movement_transaction.transaction_quantity)
                      - abs(NVL(l_movement_transaction.invoice_quantity,0)))
                            * l_report_price;
    END IF;
  END IF;

  /* Special case for 6889669 */
  IF (l_movement_transaction.document_source_type = 'IO') AND (l_movement_transaction.movement_type  = 'A')
      AND  (nvl(l_currency_conversion_rate, 1)<>1) THEN
      l_tr_value := round (l_tr_value * l_currency_conversion_rate, 2);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
		 , G_MODULE_NAME || l_procedure_name || '.begin'
		  ,'l_tr_value for IO arrival is  '||l_tr_value
		   );
       END IF;
  ELSE
    l_tr_value := round (l_tr_value * NVL(l_movement_transaction.currency_conversion_rate,1),2);
  END IF ;


  --RTV and RMA are special (AA and DA) in Italian,the movement amount in
  --Italian should be negative.If this procedure is called in update_invoice,the
  --movement type is already set to AA and DA, so we can use this criteria
  --to make movement amount negative,therwise always make it positive,for Italian
  --RTV and RMA,it will be set to negative later.bug2861110
  IF ((l_movement_transaction.document_source_type = 'RTV'
       AND NVL(l_movement_transaction.movement_type,'D') = 'AA')
     OR (l_movement_transaction.document_source_type = 'RMA'
         AND NVL(l_movement_transaction.movement_type,'A') = 'DA'))
  THEN
    l_tr_value := 0 - abs(l_tr_value);
  ELSE
    l_tr_value := abs(l_tr_value);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'in Calc Movement Amountis '||l_tr_value
                  );
  END IF;


  RETURN(l_tr_value);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN(0);
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN(0);

END Calc_Movement_Amount;

--========================================================================
-- FUNCTION : Calc_Statistics_Value PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Calculates and returns the Statistics value
--=======================================================================

FUNCTION Calc_Statistics_Value
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
RETURN NUMBER
IS
l_stat_value                   NUMBER;
l_inv_total_freight_amt        NUMBER;
l_order_freight_charge         NUMBER;
l_order_freight_charge_to_line NUMBER;
l_line_freight_charge          NUMBER;
l_freight_charge               NUMBER;
--l_invoiced_line_qty            NUMBER := p_movement_transaction.invoice_quantity;
l_movement_amount              NUMBER;

--Stat adjusted amount needs to be kept if this procedure is called
--after updating invoice and the stat adj amt is not null (entered
--through Movement Statistics form)
l_stat_adj_amount              NUMBER;

l_total_line_charge            NUMBER;
l_total_invoiced_qty           NUMBER;
l_stat_ext_value               NUMBER;
l_conversion_rate              NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Statistics_Value';

--Total freight amount on the invoices for this order line
CURSOR c_inv_freight_amt
IS
SELECT
  SUM(extended_amount)
FROM
  ra_customer_trx_lines_all
WHERE (sales_order = to_char(p_movement_transaction.order_number)
       OR sales_order IS NULL) --for manual invoice
  AND line_type = 'FREIGHT'
  AND customer_trx_id IN
      (SELECT customer_trx_id
         FROM ra_customer_trx_lines_all
        WHERE interface_line_attribute6 = to_char(p_movement_transaction.order_line_id)
          AND sales_order = to_char(p_movement_transaction.order_number));

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --Initialize variables
  l_movement_amount := p_movement_transaction.movement_amount;
  l_stat_adj_amount := NVL(p_movement_transaction.stat_adj_amount,0);
  l_conversion_rate := p_movement_transaction.currency_conversion_rate;

  --Statistics value should be same as movement amount in most cases, however
  --there are cases where the two values are different. For example when
  --freight charge is included in the same SO invoice, we need to include that
  --freight charge into statistics value to do Intrastat report

  --The following calcualtion trys to cover manual invoice case too. But it's
  --very compilicated in manual case. There could be freight charge on manual
  --invoice different from that in price adjustment table. There could be
  --invoiced quantity different from ordered quantity. There could be multiple
  --shipments with one invoice or one shipment transaction with multiple invoices
  --and each of the invoice has freight charge. There could be credit memo with
  --freight charge on it......

  --Only calculate freight charge for SO where invoice and freight charge is
  --existed

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.movement amt in stat value is '
                  ,p_movement_transaction.movement_amount
                  );
  END IF;


  IF (p_movement_transaction.invoice_id IS NOT NULL
     AND p_movement_transaction.document_source_type = 'SO')
  THEN
    --Find out total freight charge on all related invoices for this order line
    OPEN c_inv_freight_amt;
    FETCH c_inv_freight_amt INTO
      l_inv_total_freight_amt;
    CLOSE c_inv_freight_amt;

    --Check if freight amount on invoice is null, cursor with sum function
    --is always return row, so can not use cursor%notfound to check
    IF l_inv_total_freight_amt IS NULL
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_procedure_name
                        || '.end no freight amt'
                      ,'exit procedure'
                      );
      END IF;
      RETURN (l_movement_amount + l_stat_adj_amount);
    END IF;

    --Calculate total line freight charge from invoiced quantity for
    --all lines
    Calc_Total_Line_Charge
    ( p_movement_transaction  => p_movement_transaction
     , x_this_line_charge     => l_line_freight_charge
     , x_total_line_charge    => l_total_line_charge
     , x_total_invoiced_qty   => l_total_invoiced_qty
     );

    --Freight charge 1: Calculate order level freight charge
    --To cover manual invoice scenario, the total order freight charge will
    --be the result of total freight charge on invoices substract the total
    --line charge for all the lines. The charge is in functional currency
    l_order_freight_charge := l_inv_total_freight_amt * l_conversion_rate - l_total_line_charge;

    --Distribute this order level charge to each line
    IF (l_order_freight_charge <> 0
       AND l_total_invoiced_qty <> 0)
    THEN
      l_order_freight_charge_to_line :=
        ROUND(((l_order_freight_charge/l_total_invoiced_qty)
               * p_movement_transaction.invoice_quantity),5);
    ELSE
      l_order_freight_charge_to_line := 0;
    END IF;

    --Freight charge2: line level freight charge
    --Can use oe_price_adjustments.adjusted_amount_per_pqty to calculate total
    --line charge for this line.
    --Comment out following code, because the line charge is calculated and
    --returned from the call of Calc_Total_Line_Charge
    /*Calc_Total_Line_Charge
    ( p_movement_transaction  => p_movement_transaction
    , x_this_line_charge     => l_line_freight_charge
    , x_total_line_charge    => l_total_line_charge
    , x_total_invoiced_qty   => l_total_invoiced_qty
    );*/

    --Total freight charge for each line including order level and line level
    l_freight_charge := ROUND((l_order_freight_charge_to_line + l_line_freight_charge),2);

    --Include freight charge into statistical value
    l_stat_ext_value := l_movement_amount + l_freight_charge + l_stat_adj_amount;
  ELSE
    l_stat_ext_value := l_movement_amount + l_stat_adj_amount;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

RETURN(l_stat_ext_value);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN(l_movement_amount + l_stat_adj_amount);
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN(l_movement_amount + l_stat_adj_amount);
END Calc_Statistics_Value;

-- ========================================================================
-- PROCEDURE : Calc_Invoice_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT Movement Statistics Record
--             p_stat_typ_transaction  IN  Stat type Usages record
-- COMMENT   : Procedure to calcualte the invoice information
--             Calculation of Invoice Information
--             The verification program calls this Procedure to populate the
--             invoice information to the Movement Statistics table.
-- ========================================================================
PROCEDURE Calc_Invoice_Info
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_unit_price	         NUMBER;
  l_invoice_quantity     NUMBER;
  l_rtv_invoice_quantity NUMBER :=0;
  l_tran_curr_code       VARCHAR2(15);
  l_tran_curr_type       VARCHAR2(30);
  l_tran_curr_rate       NUMBER;
  l_tran_curr_date       DATE;
  l_extended_amount      NUMBER;
  l_cm_extended_amount   NUMBER :=0;
  l_rtv_extended_amount  NUMBER :=0;
  l_uom_code             VARCHAR2(3);
  l_parent_transaction_id NUMBER;
  l_so_le_id             NUMBER;
  l_shipping_le_id       NUMBER;
  l_item_type_code       OE_ORDER_LINES_ALL.Item_Type_Code%TYPE;
  l_model_line_id        OE_ORDER_LINES_ALL.Line_Id%TYPE;
  l_cto_line_id          OE_ORDER_LINES_ALL.Line_Id%TYPE;

  --fix bug2861110
  l_processed_ret_amt    NUMBER;
  l_processed_ret_qty    NUMBER;
  l_total_rtv_trans_qty     NUMBER;

  --fix bug 2695323
  l_total_rma_qty           NUMBER;

  -- bug 5440432, new variables intorduced.
  l_ar_invoiced_amount NUMBER;
  l_ar_invoiced_qty    NUMBER;

  --R12 PO price and qty correction
  l_prc_amount          NUMBER;  --price correction amt
  l_qtc_amount          NUMBER;  --qty correction amt
  l_qtc_qty             NUMBER;  --qty corrected in qty correction

  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Invoice_Info';

-- Cursor to get all the invoice information after we get the invoice_id

CURSOR l_arc IS
  SELECT
    rat.trx_date
  , rat.batch_id
  , NVL(rat.exchange_rate,1)
  , rat.exchange_rate_type
  , rat.exchange_date
  , NVL(rat.invoice_currency_code,l_movement_transaction.currency_code)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  WHERE rat.customer_trx_id       = x_movement_transaction.invoice_id;

-- Cursor for SO invoices which are non credit/debit memos.

CURSOR l_sum_arc IS
  SELECT
    MAX(ratl.customer_trx_line_id)
  , MAX(rat.customer_trx_id)
  , SUM(ratl.extended_amount)
  , SUM(NVL(ratl.quantity_invoiced,l_movement_transaction.transaction_quantity))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ratt.type                 NOT IN ('CM','DM')
  AND   NVL(ratl.interface_line_attribute11, '-9999')  --Fix bug 2423946
        NOT IN (SELECT TO_CHAR(price_adjustment_id)
                  FROM oe_price_adjustments
                 WHERE header_id = l_movement_transaction.order_header_id
                   AND (line_id  = l_movement_transaction.order_line_id
                        OR (line_id IS NULL AND modifier_level_code = 'ORDER')))
  AND   ratl.line_type            = 'LINE'
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 =
                              to_char(l_movement_transaction.order_line_id)
  AND   ratl.interface_line_context <> 'INTERCOMPANY';

-- Cursor for RMA transactions

CURSOR l_sum_rma_arc IS
  SELECT
    MAX(ratl.customer_trx_line_id)
  , MAX(rat.customer_trx_id)
  , SUM(ratl.extended_amount)
  , SUM(NVL(ratl.quantity_credited,l_movement_transaction.transaction_quantity))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ratt.type                 IN ('CM','DM')
  AND   ratl.line_type            = 'LINE'  --yawang
  AND   ratl.quantity_credited    IS  NOT NULL
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  --AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND ratl.interface_line_attribute1 = to_char(l_movement_transaction.order_number)
  AND   NVL(ratl.org_id,0)  = NVL(l_movement_transaction.org_id,0)
  AND   ratl.interface_line_attribute6 =
                              to_char(l_movement_transaction.order_line_id)
  AND   ratl.interface_line_context <> 'INTERCOMPANY';

-- Cursor for SO Credit/Debit memos.

CURSOR l_sum_cm_arc IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ((ratt.type               IN ('CM','DM'))
        OR (NVL(ratl.interface_line_attribute11, '-9999') --Fix bug 2423946
           IN (SELECT TO_CHAR(price_adjustment_id)
                 FROM oe_price_adjustments
                WHERE header_id = l_movement_transaction.order_header_id
                  AND (line_id = l_movement_transaction.order_line_id
                       OR (line_id IS NULL AND modifier_level_code = 'ORDER')) )))
  AND   ratl.line_type            = 'LINE'  --yawang
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.quantity_credited    IS   NULL
  AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 =
                              to_char(l_movement_transaction.order_line_id)
  AND   ratl.interface_line_context <> 'INTERCOMPANY';

/* Bug 8435314 Add New Cursor for config Item in RMA*/
  CURSOR l_rma_config IS
  SELECT DISTINCT 'CONFIG' FROM mtl_system_items
   WHERE inventory_item_id = l_movement_transaction.inventory_item_id
     AND auto_created_config_flag = 'Y'
     AND base_item_id IS NOT null;

     CURSOR l_rma_model_id IS
     SELECT DISTINCT ol.line_id FROM  oe_order_lines_all ol
     WHERE (return_attribute1,return_attribute2) IN
           (SELECT  header_id,Top_model_line_id FROM oe_order_lines_all ol1
           WHERE   (header_id,Top_model_line_id) IN
                   (SELECT header_id,Top_model_line_id FROM oe_order_lines_all ol2
                   WHERE (header_id,line_id ) IN
                         (SELECT return_attribute1,return_attribute2 FROM oe_order_lines_all ol3
                          WHERE ol3.line_id=l_movement_transaction.order_line_id
                          AND ol3.header_id=l_movement_transaction.order_header_id)))
       AND ol.header_id=l_movement_transaction.order_header_id;
/*End bug 8435314*/

-- Cursor for drop shipment transactions

CURSOR l_sum_drparc IS
  SELECT
    MAX(ratl.customer_trx_line_id)
  , MAX(rat.customer_trx_id)
  , SUM(ratl.extended_amount)
  , SUM(NVL(ratl.quantity_invoiced,l_movement_transaction.transaction_quantity))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt     --add in for fixing bug 2447381
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  --AND   ratl.quantity_invoiced    = ratl.quantity_ordered
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ratt.type                 NOT IN ('CM','DM')
  AND   NVL(ratl.interface_line_attribute11, '-9999')  --Fix bug 2423946
        NOT IN (SELECT TO_CHAR(price_adjustment_id)
                  FROM oe_price_adjustments
                 WHERE header_id = l_movement_transaction.order_header_id
                   AND (line_id  = l_movement_transaction.order_line_id
                        OR (line_id IS NULL AND modifier_level_code = 'ORDER')))
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.line_type            = 'LINE'  --yawang
  AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 =
                          to_char(l_movement_transaction.order_line_id)
  AND   rat.complete_flag = 'Y'
  AND   ratl.interface_line_context <> 'INTERCOMPANY';

-- Cursor for drop shipment transactions with credit memo/debit memos

CURSOR l_sum_cm_drparc IS
  SELECT
    SUM(ratl.extended_amount)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  , RA_CUST_TRX_TYPES_ALL ratt
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  --AND   ratl.quantity_invoiced    = ratl.quantity_ordered
  AND   rat.cust_trx_type_id      = ratt.cust_trx_type_id
  AND   rat.org_id                = ratt.org_id
  AND   ((ratt.type               IN ('CM','DM'))
        OR (NVL(ratl.interface_line_attribute11, '-9999') --Fix bug 2423946
           IN (SELECT TO_CHAR(price_adjustment_id)
                 FROM oe_price_adjustments
                WHERE header_id = l_movement_transaction.order_header_id
                  AND (line_id = l_movement_transaction.order_line_id
                       OR (line_id IS NULL AND modifier_level_code = 'ORDER')) )))
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.line_type            = 'LINE'  --yawang
  AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 =
                          to_char(l_movement_transaction.order_line_id)
  AND   rat.complete_flag = 'Y'
  AND   ratl.interface_line_context <> 'INTERCOMPANY';

  --Cursor for ar intercompany invoice
  CURSOR l_ar_intercompany IS
  SELECT
    MAX(ratl.customer_trx_line_id)
  , MAX(rat.customer_trx_id)
  , SUM(ratl.extended_amount)
  , SUM(NVL(ratl.quantity_invoiced,l_movement_transaction.transaction_quantity))
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  AND   ratl.line_type            = 'LINE'
  AND   ratl.sales_order  = to_char(l_movement_transaction.order_number)
  AND   ratl.interface_line_attribute6 =
                              to_char(l_movement_transaction.order_line_id)
  AND   ratl.interface_line_context = 'INTERCOMPANY';

  -- Bug 5440432: Following query is modified to replace where clause
  -- 'AND rcta.trx_number||'-'||rcta.org_id = aia.invoice_num' with
  -- 'AND (rcta.trx_number||'-'||rcta.org_id = aia.invoice_num
  -- OR rcta.trx_number = aia.invoice_num)'
  -- This change was introduced because of bug 4180686 in 11.5.10
  -- Apart from that a new cursor l_ap_intercompany_invoiced_qty  is
  -- introduced to get quantity/Amount from AR Invoice tables if
  -- AP details are missing.
  --Cursor for ap intercompany invoice
  --CURSOR l_ap_intercompany IS
  --SELECT
  --  MAX(aida.invoice_id)
  --, MAX(distribution_line_number)
  --, SUM(NVL(aida.amount,rctla.extended_amount))
  --, SUM(NVL(aida.quantity_invoiced,rctla.quantity_invoiced))
  --FROM
  --  AP_INVOICES_ALL aia
  --, AP_INVOICE_DISTRIBUTIONS_ALL aida
  --, RA_CUSTOMER_TRX_LINES_ALL rctla
  --, ra_customer_trx_all rcta
  --WHERE aia.invoice_id = aida.invoice_id
  --  AND (NVL(aida.match_status_flag,'N') = 'A'
  --       OR (NVL(aida.match_status_flag,'N') = 'T'
  --           AND aia.wfapproval_status = 'NOT REQUIRED'))
  --  AND aia.cancelled_date IS NULL
  --  AND aida.line_type_lookup_code = 'ITEM' --yawang, limit for good cost only
  --  AND aia.reference_1  = TO_CHAR(rctla.customer_trx_id)
  --  AND aida.reference_1 = TO_CHAR(rctla.customer_trx_line_id)
  --  AND rctla.customer_trx_id = rcta.customer_trx_id
  --  AND rcta.trx_number||'-'||rcta.org_id = aia.invoice_num
  --  AND rctla.sales_order  = to_char(l_movement_transaction.order_number)
  --  AND rctla.interface_line_attribute6 =
  --      to_char(l_movement_transaction.order_line_id);
CURSOR l_ap_intercompany IS
  SELECT
     MAX(aia.invoice_id)
   , MAX(aila.line_number)
   , SUM(NVL(aila.amount, 0))
   , SUM(NVL(aila.quantity_invoiced,0))
   FROM
     AP_INVOICES_ALL aia
   , AP_INVOICE_LINES_ALL aila
   , RA_CUSTOMER_TRX_LINES_ALL rctla
   , ra_customer_trx_all rcta
   WHERE aia.invoice_id = aila.invoice_id
     AND aia.cancelled_date IS NULL
     AND aila.line_type_lookup_code = 'ITEM'
     AND aia.reference_1  = TO_CHAR(rctla.customer_trx_id)
     AND aila.reference_1 = TO_CHAR(rctla.customer_trx_line_id)
     AND rctla.customer_trx_id = rcta.customer_trx_id
     AND (rcta.trx_number||'-'||rcta.org_id = aia.invoice_num
         OR rcta.trx_number = aia.invoice_num)
     AND rctla.sales_order  = to_char(l_movement_transaction.order_number)
     AND rctla.interface_line_attribute6 =
         to_char(l_movement_transaction.order_line_id)
     AND nvl(aila.discarded_flag, 'N') <> 'Y'
     AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
     AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

  CURSOR l_ap_intercompany_invoiced_qty IS
  SELECT
   SUM(NVL(rctla.extended_amount,0)) InvoiceAmount
  ,SUM(NVL(rctla.quantity_invoiced,0)) InvoicedQuantity
   FROM
     AP_INVOICES_ALL aia
   , RA_CUSTOMER_TRX_LINES_ALL rctla
   WHERE aia.invoice_id = x_movement_transaction.invoice_id
     AND aia.reference_1 = TO_CHAR(rctla.customer_trx_id)
     AND rctla.sales_order  = to_char(l_movement_transaction.order_number)
     AND rctla.interface_line_attribute6 =
         to_char(l_movement_transaction.order_line_id);
    /* 7165989 - Intercompany AP invoice for RMA */
  CURSOR l_ap_intercompany_rma_inv_qty IS
  SELECT
   SUM(NVL(rctla.extended_amount,0)) InvoiceAmount
  , SUM(NVL(rctla.quantity_credited,l_movement_transaction.transaction_quantity)) InvoicedQuantity
   FROM
     AP_INVOICES_ALL aia
   , RA_CUSTOMER_TRX_LINES_ALL rctla
   WHERE aia.invoice_id = x_movement_transaction.invoice_id
     AND aia.reference_1 = TO_CHAR(rctla.customer_trx_id)
     AND rctla.interface_line_attribute1  = to_char(l_movement_transaction.order_number)
     AND rctla.interface_line_attribute6 =
         to_char(l_movement_transaction.order_line_id);

    /* 7165989 - End */

  -- Cursor to get the invoice info based on the invoice_id
  CURSOR l_ap_intercompany_invo IS
  SELECT
    ap.invoice_currency_code
  , NVL(ap.exchange_rate,NVL(rctl.exchange_rate, 1))
  , NVL(ap.exchange_rate_type,rctl.exchange_rate_type)
  , NVL(ap.exchange_date,rctl.exchange_date)
  , ap.batch_id
  , ap.invoice_date
  FROM
    AP_INVOICES_ALL ap
  , RA_CUSTOMER_TRX_ALL rctl
  WHERE ap.invoice_id = x_movement_transaction.invoice_id
    AND ap.reference_1 = rctl.customer_trx_id;

-- Cursor to get all the invoice information for drop shipments after fetching
-- the invoice_id.

CURSOR l_drparc IS
  SELECT
    rat.trx_date
  , rat.batch_id
  , NVL(rat.exchange_rate,1)
  , rat.exchange_rate_type
  , rat.exchange_date
  , NVL(rat.invoice_currency_code,l_movement_transaction.currency_code)
  FROM
    RA_CUSTOMER_TRX_ALL rat
  , RA_CUSTOMER_TRX_LINES_ALL ratl
  WHERE rat.customer_trx_id       = ratl.customer_trx_id
  --AND   ratl.quantity_invoiced    = ratl.quantity_ordered
  AND   NVL(UPPER(ratl.sales_order_source),'ORDER ENTRY') = 'ORDER ENTRY'
  AND   ratl.interface_line_attribute6 = to_char(l_movement_transaction.order_line_id)
  AND   ratl.customer_trx_line_id = x_movement_transaction.customer_trx_line_id;

-- Cursor to get the invoice info based on the invoice_id for PO

CURSOR l_apc IS
  SELECT
    ap.invoice_currency_code
  , NVL(ap.exchange_rate,1)
  , ap.exchange_rate_type
  , ap.exchange_date
  , ap.batch_id
  , ap.invoice_date
  FROM
    AP_INVOICES_ALL ap
  WHERE ap.invoice_id = x_movement_transaction.invoice_id;

-- Cursor for PO based matching regular invoice
-- modified for AP invoice lines uptake in R12
CURSOR l_po_inv IS
SELECT
  SUM(aila.amount)
, MAX(aila.line_number)
, MAX(aia.invoice_id)
, SUM(aila.quantity_invoiced)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.invoice_type_lookup_code in ('STANDARD','MIXED')
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'ITEM_TO_PO'
 AND aila.po_line_location_id = l_movement_transaction.po_line_location_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

/*bug 8435322 Added new cursor to fetch max distribution_line_number for max Invoice Id*/
CURSOR l_po_line_number IS
  SELECT
    MAX(distribution_line_number)
  FROM
    AP_INVOICES_ALL b
  , AP_INVOICE_DISTRIBUTIONS_ALL a
  WHERE  b.invoice_id                    = x_movement_transaction.invoice_id
    AND  b.invoice_id                    = a.invoice_id
    AND  (NVL(a.match_status_flag,'N')   = 'A'
           OR (NVL(a.match_status_flag,'N') = 'T'
               AND b.wfapproval_status = 'NOT REQUIRED'))
    AND  a.line_type_lookup_code          = 'ITEM' ;
/*End bug 8435322 */

-- Cursor for price correction in case of PO based matching.
-- Modified for AP invoice lines uptake in R12
-- Although price correction in AP directly reflects price correction for certain
-- quantity, but for us we display  only one invoice for each transaction, we still
-- need to average the price for each qty after price adjustment. So here we only
-- take the amount.
--CURSOR l_po_cm_inv IS
CURSOR l_po_prc_inv IS
SELECT
  SUM(aila.amount)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'PRICE_CORRECTION'
 AND aila.po_line_location_id = l_movement_transaction.po_line_location_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));
-- Cursor for quantity correction in case of PO based matching.
-- Modified for AP invoice lines uptake in R12
CURSOR l_po_qtc_inv IS
SELECT
  SUM(aila.quantity_invoiced)
, SUM(aila.amount)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'QTY_CORRECTION'
 AND aila.po_line_location_id = l_movement_transaction.po_line_location_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

-- Cursor for RTV's where credit memo is to be associated with
-- RTV in case of PO based matching.
-- modified for AP invoice lines uptake in R12
CURSOR l_po_rtv_cm_inv IS
SELECT
  SUM(aila.amount)
, MAX(aila.line_number)
, MAX(aia.invoice_id)
, SUM(aila.quantity_invoiced)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.invoice_type_lookup_code in ('CREDIT','DEBIT')
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'ITEM_TO_PO'
 AND NVL(aila.quantity_invoiced,0) < 0
 AND aila.po_line_location_id = l_movement_transaction.po_line_location_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

-- Cursor for Receipt based matching regular invoice
-- Modified for AP invoice lines uptake in R12
CURSOR l_ap_inv IS
SELECT
 sum(aila.amount)
, MAX(aila.line_number)
, MAX(aia.invoice_id)
, sum(aila.quantity_invoiced)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.invoice_type_lookup_code in ('STANDARD','MIXED')
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'ITEM_TO_RECEIPT'
 AND aila.rcv_transaction_id = l_movement_transaction.rcv_transaction_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

-- Cursor for price correction in case of Receipt based matching.
-- Modified for AP invoice lines uptake in R12
-- Although price correction in AP directly reflects price correction for certain
-- quantity, but for us we display only one invoice for each transaction, we still
-- need to average the price for each qty after price adjustment. So here we only
-- take the amount.
--CURSOR l_ap_cm_inv IS
CURSOR l_ap_prc_inv IS
SELECT
  SUM(aila.amount)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'PRICE_CORRECTION'
 AND aila.rcv_transaction_id = l_movement_transaction.rcv_transaction_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

-- Cursor for quantity correction in case of Receipt based matching.
-- Modified for AP invoice lines uptake in R12
CURSOR l_ap_qtc_inv IS
SELECT
  SUM(aila.quantity_invoiced)
, SUM(aila.amount)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'QTY_CORRECTION'
 AND aila.rcv_transaction_id = l_movement_transaction.rcv_transaction_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

-- Cursor for Credit memos that is associated with RTV transaction
-- in case of receipt based matching.
-- modified in R12 to use line table
CURSOR l_ap_rtv_cm_inv IS
SELECT
 sum(aila.amount)
, MAX(aila.line_number)
, MAX(aia.invoice_id)
, sum(aila.quantity_invoiced)
FROM
 ap_invoices_all aia
, ap_invoice_lines_all aila
WHERE aia.invoice_id = aila.invoice_id
 AND aia.invoice_type_lookup_code in ('CREDIT','DEBIT')
 AND aia.cancelled_date IS NULL
 AND aila.line_type_lookup_code = 'ITEM'
 AND aila.match_type = 'ITEM_TO_RECEIPT'
 AND NVL(aila.quantity_invoiced,0) < 0
 AND aila.rcv_transaction_id = l_parent_transaction_id
 -- Bug 5655040. Commented as condition is modified and few more conditioned
 -- added to whereclause to check hold and disregard status.
 --AND NOT EXISTS (SELECT 1
 --                FROM ap_invoice_distributions_all aida
 --                WHERE aida.invoice_id = aia.invoice_id
 --                  AND aida.invoice_line_number = aila.line_number
 --                  AND NVL(aida.match_status_flag,'N') <> 'A');
 AND nvl(aila.discarded_flag, 'N') <> 'Y'
 AND NOT EXISTS (SELECT 'Unreleased holds exist'
                      FROM   ap_holds_all aha
                      WHERE  aha.invoice_id = aia.invoice_id
                      AND    aha.release_lookup_code is null)
 AND EXISTS (SELECT 'Invoice is approved'
                      FROM ap_invoice_distributions_all aida
                      WHERE aida.invoice_id = aia.invoice_id
                      AND NVL(aida.match_status_flag, 'N') NOT in ('N', 'S'));

  --Cursor to check if this SO is for CTO items
  CURSOR l_cto IS
  SELECT
    item_type_code
  , top_model_line_id
  FROM
    oe_order_lines_all
  WHERE line_id = l_movement_transaction.order_line_id;

  --Cursor to get total rtv transaction quantity
  CURSOR l_total_rtv_quantity IS
  SELECT
    SUM(quantity)
  FROM
    rcv_transactions
  WHERE po_header_id = l_movement_transaction.po_header_id
    AND transaction_type = 'RETURN TO VENDOR';

BEGIN

  --Consigned support move condition from INVUINTB.pls to here
 -- IF (x_movement_transaction.document_source_type IN ('IO','INV')
 IF (x_movement_transaction.document_source_type IN ('INV')
     OR x_movement_transaction.consigned_flag = 'Y'
     OR x_movement_transaction.financial_document_flag = 'NOT_REQUIRED_CORRECT')
  THEN
    RETURN;

  ELSE
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name || '.begin'
                    ,'enter procedure'
                    );
      END IF;

  l_movement_transaction := x_movement_transaction;
  l_stat_typ_transaction := p_stat_typ_transaction;

  -- Now do all the calculations for currency.
  --x_movement_transaction.currency_conversion_type :=
   -- l_stat_typ_transaction.conversion_type;

  l_tran_curr_code  := x_movement_transaction.currency_code;
  l_tran_curr_rate  := x_movement_transaction.currency_conversion_rate;
  l_tran_curr_date  := x_movement_transaction.currency_conversion_date;
  l_tran_curr_type  := x_movement_transaction.currency_conversion_type;

--  IF l_movement_transaction.document_source_type IN ( 'SO','RMA')
  IF l_movement_transaction.document_source_type IN ( 'IO','SO','RMA')
  THEN




    --Find out the legal entity where this SO is created
    l_so_le_id := INV_MGD_MVT_UTILS_PKG.Get_SO_Legal_Entity
                  (p_order_line_id => l_movement_transaction.order_line_id);

    --Find out the legal entity where this SO is shipped
    l_shipping_le_id := INV_MGD_MVT_UTILS_PKG.Get_Shipping_Legal_Entity
                        (p_warehouse_id => l_movement_transaction.organization_id);

    --Check if this order line is of CTO item
    OPEN l_cto;
    FETCH l_cto INTO
      l_item_type_code
    , l_model_line_id;
    CLOSE l_cto;

    IF l_item_type_code = 'CONFIG'
    THEN
      l_cto_line_id := l_movement_transaction.order_line_id;

      --Set order line to model line id to calculate correct invoice
      l_movement_transaction.order_line_id := l_model_line_id;
    END IF;

    -- Check if the transaction is a drop shipment; if it is not then
    -- fetch the l_sum_arc cursor and l_sum_cm_arc which gets the
    -- credit/memo transactions.
    IF l_movement_transaction.po_header_id IS NULL
       OR l_movement_transaction.po_header_id = FND_API.G_MISS_NUM
    THEN
      --Not drop shipment
      IF l_movement_transaction.document_source_type = 'SO'
      THEN
        --If this SO is created and shipped in different legal entity
        --and we are in invoice based triangulation mode,we need
        -- intercompany invoice
        IF (l_so_le_id IS NOT NULL
            AND l_so_le_id <> l_shipping_le_id
            AND NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')
                = 'INVOICE_BASED')
        THEN
          --If this processor is run at the legal entity where this SO
          --is created and the record created is Arrival intercompany SO
          --we need an intercompany ap invoice
          IF (l_so_le_id = l_movement_transaction.entity_org_id
             AND l_movement_transaction.movement_type = 'A')
          THEN
            --intercompany ap invoice
            OPEN l_ap_intercompany;
            FETCH l_ap_intercompany INTO
              x_movement_transaction.invoice_id
            , x_movement_transaction.distribution_line_number
            , l_extended_amount
            , x_movement_transaction.invoice_quantity;
            CLOSE l_ap_intercompany;

            IF x_movement_transaction.invoice_id IS NOT NULL
            THEN
              --Recalculate invoice amount for ap intercompany CTO item
              IF l_item_type_code = 'CONFIG'
              THEN
                Calc_Cto_Amount_ap
                ( p_order_line_id      => l_movement_transaction.order_line_id
                , p_order_number       => to_char(l_movement_transaction.order_number)
                , x_extended_amount    => l_extended_amount
                );
              END IF;

             -- bug 5440432, Following IF block is added to get details from AR invoice
              -- if Amount or Quantity is missing from AP Invoice.
              IF l_extended_amount = 0 OR x_movement_transaction.invoice_quantity = 0 THEN
               OPEN l_ap_intercompany_invoiced_qty;
               FETCH l_ap_intercompany_invoiced_qty INTO
                 l_ar_invoiced_amount, l_ar_invoiced_qty;
               CLOSE l_ap_intercompany_invoiced_qty;
               IF l_extended_amount = 0 THEN
                l_extended_amount := l_ar_invoiced_amount;
               END IF;
               IF x_movement_transaction.invoice_quantity = 0 THEN
                x_movement_transaction.invoice_quantity := l_ar_invoiced_qty;
               END IF;
              END IF;
              --Open cursor to get other invoice information
              OPEN l_ap_intercompany_invo;
              FETCH l_ap_intercompany_invo INTO
                x_movement_transaction.currency_code
              , x_movement_transaction.currency_conversion_rate
              , x_movement_transaction.currency_conversion_type
              , x_movement_transaction.currency_conversion_date
              , x_movement_transaction.invoice_batch_id
              , x_movement_transaction.invoice_date_reference;

              IF l_ap_intercompany_invo%NOTFOUND
              THEN
                x_movement_transaction.currency_code            := l_tran_curr_code;
                x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
                x_movement_transaction.currency_conversion_type := l_tran_curr_type;
                x_movement_transaction.currency_conversion_date := l_tran_curr_date;
                x_movement_transaction.invoice_batch_id         := null;
                x_movement_transaction.invoice_date_reference   := null;
              END IF;
              CLOSE l_ap_intercompany_invo;
            END IF;  --yawang

          --If this processor is run at the legal entity where this SO
          --is created but the record created is a virtual Dispatch to customer
          --we need an regular ar invoice to customer
          ELSIF (l_so_le_id = l_movement_transaction.entity_org_id
                AND l_movement_transaction.movement_type = 'D')
          THEN
            --Regular SO invoice
            OPEN l_sum_arc;
            FETCH l_sum_arc INTO
              x_movement_transaction.customer_trx_line_id
            , x_movement_transaction.invoice_id
            , l_extended_amount
            , x_movement_transaction.invoice_quantity;
            CLOSE l_sum_arc;

            IF x_movement_transaction.invoice_id IS NOT NULL
            THEN
              OPEN l_sum_cm_arc;
              FETCH l_sum_cm_arc INTO
                l_cm_extended_amount;
              CLOSE l_sum_cm_arc;

              --Recalculate invoice amount for CTO item
              IF l_item_type_code = 'CONFIG'
              THEN
                Calc_Cto_Amount_So
                ( p_order_line_id      => l_movement_transaction.order_line_id
                , p_order_number       => to_char(l_movement_transaction.order_number)
                , x_extended_amount    => l_extended_amount
                , x_cm_extended_amount => l_cm_extended_amount
                );
              END IF;
            END IF;

          --If this processor is run at the legal entity where this SO
          --is shipped, we need an ar intercompany invoice
          ELSIF (l_shipping_le_id = l_movement_transaction.entity_org_id)
          THEN
            OPEN l_ar_intercompany;
            FETCH l_ar_intercompany INTO
              x_movement_transaction.customer_trx_line_id
            , x_movement_transaction.invoice_id
            , l_extended_amount
            , x_movement_transaction.invoice_quantity;
            CLOSE l_ar_intercompany;

            --Recalculate invoice amount for ar intercompany CTO item
            IF l_item_type_code = 'CONFIG'
               AND x_movement_transaction.customer_trx_line_id IS NOT NULL
            THEN
              Calc_Cto_Amount_ar
              ( p_order_line_id      => l_movement_transaction.order_line_id
              , p_order_number       => to_char(l_movement_transaction.order_number)
              , x_extended_amount    => l_extended_amount
              );
            END IF;
          END IF;
        ELSE
          --Regular SO invoice
          OPEN l_sum_arc;
          FETCH l_sum_arc INTO
            x_movement_transaction.customer_trx_line_id
          , x_movement_transaction.invoice_id
          , l_extended_amount
          , x_movement_transaction.invoice_quantity;
          CLOSE l_sum_arc;

          IF x_movement_transaction.invoice_id IS NOT NULL
          THEN
            OPEN l_sum_cm_arc;
            FETCH l_sum_cm_arc INTO
              l_cm_extended_amount;
            CLOSE l_sum_cm_arc;

            --Recalculate invoice amount for CTO item
            IF l_item_type_code = 'CONFIG'
            THEN
              Calc_Cto_Amount_So
              ( p_order_line_id      => l_movement_transaction.order_line_id
              , p_order_number       => to_char(l_movement_transaction.order_number)
              , x_extended_amount    => l_extended_amount
              , x_cm_extended_amount => l_cm_extended_amount
              );
            END IF;

            --Fix Italian bug 2861110.Update_invoice_info will revert any netted invoice
            --amt and qty back to original SO invoice amt and qty. The following code
            --will net the invoice amt and qty again for processed RMA
            IF l_stat_typ_transaction.returns_processing = 'AGGRTN'
            THEN
              Calc_Processed_Ret_Data
              (p_movement_transaction => l_movement_transaction
              , x_processed_ret_amt   => l_processed_ret_amt
              , x_processed_ret_qty   => l_processed_ret_qty
              );

              --Net processed rma amt and qty to SO
              l_extended_amount := l_extended_amount + NVL(l_processed_ret_amt,0);
              x_movement_transaction.invoice_quantity :=
                 x_movement_transaction.invoice_quantity + NVL(l_processed_ret_qty,0);
            END IF;
          END IF;  --yawang end of invoice not null
        END IF;
      END IF;


    /*********************************** Special case for an IO - BEGIN **************************************/

       IF l_movement_transaction.document_source_type = 'IO'
       THEN
        --If this processor is run at the legal entity where this SO
                --is created and the record created is Arrival intercompany SO
                --we need an intercompany ap invoice

            --          IF (l_so_le_id = l_movement_transaction.entity_org_id
            --             AND l_movement_transaction.movement_type = 'A')
            -- kdevadas
            --FOR an Internal ORDER, the so le Id would always be the ship TO LE -
            --will NOT be the same AS the entity_org_id WHERE MSP IS RUN
          IF (l_movement_transaction.movement_type = 'A')
	        THEN
      	    --intercompany ap invoice
            OPEN l_ap_intercompany;
            FETCH l_ap_intercompany INTO
              x_movement_transaction.invoice_id
            , x_movement_transaction.distribution_line_number
            , l_extended_amount
            , x_movement_transaction.invoice_quantity;

		          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
		          THEN
		          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
		              , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY INVOICE ID ********************* '
		              , x_movement_transaction.invoice_id
		              );
		          END IF ;

            CLOSE l_ap_intercompany;


            IF x_movement_transaction.invoice_id IS NOT NULL
            THEN

              --Recalculate invoice amount for ap intercompany CTO item
              IF l_item_type_code = 'CONFIG'
              THEN
                Calc_Cto_Amount_ap
                ( p_order_line_id      => l_movement_transaction.order_line_id
                , p_order_number       => to_char(l_movement_transaction.order_number)
                , x_extended_amount    => l_extended_amount
                );
              END IF;
              -- bug 5411006, Following IF block is added to get details from AR invoice
              -- if Amount or Quantity is missing from AP Invoice.
              IF l_extended_amount = 0 OR x_movement_transaction.invoice_quantity = 0 THEN
                OPEN l_ap_intercompany_invoiced_qty;
                FETCH l_ap_intercompany_invoiced_qty INTO
                  l_ar_invoiced_amount, l_ar_invoiced_qty;
                CLOSE l_ap_intercompany_invoiced_qty;
                IF l_extended_amount = 0 THEN
                 l_extended_amount := l_ar_invoiced_amount;
                END IF;
                IF x_movement_transaction.invoice_quantity = 0 THEN
                  x_movement_transaction.invoice_quantity := l_ar_invoiced_qty;
                END IF;
              END IF;
              --Open cursor to get other invoice information
              OPEN l_ap_intercompany_invo;
              FETCH l_ap_intercompany_invo INTO
                x_movement_transaction.currency_code
              , x_movement_transaction.currency_conversion_rate
              , x_movement_transaction.currency_conversion_type
              , x_movement_transaction.currency_conversion_date
              , x_movement_transaction.invoice_batch_id
              , x_movement_transaction.invoice_date_reference;

             	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          		THEN
          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY CURRENCY CODE ********************* '
          		    , x_movement_transaction.currency_code
          		    );
          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY currency_conversion_type ********************* '
          		    , x_movement_transaction.currency_conversion_rate
          		    );
          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANYcurrency_conversion_typeE ********************* '
          		    , x_movement_transaction.currency_conversion_type
          		    );
          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY currency_conversion_date********************* '
          		    , x_movement_transaction.currency_conversion_date
          		    );
          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY invoice_batch_id   ********************* '
          		    , x_movement_transaction.invoice_batch_id
          		    );

          		FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
          		    , G_MODULE_NAME || l_procedure_name || 'AP INTERCOMPANY invoice_date_reference   ********************* '
          		    , x_movement_transaction.invoice_date_reference
          		    );
          		END IF ;

              IF l_ap_intercompany_invo%NOTFOUND
              THEN
                x_movement_transaction.currency_code            := l_tran_curr_code;
                x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
                x_movement_transaction.currency_conversion_type := l_tran_curr_type;
                x_movement_transaction.currency_conversion_date := l_tran_curr_date;
                x_movement_transaction.invoice_batch_id         := null;
                x_movement_transaction.invoice_date_reference   := null;
              END IF;
              CLOSE l_ap_intercompany_invo;
            END IF;  --yawang

          --If this processor is run at the legal entity where this SO
          --is shipped, we need an ar intercompany invoice
          ELSIF (l_shipping_le_id = l_movement_transaction.entity_org_id)
          THEN
            OPEN l_ar_intercompany;
            FETCH l_ar_intercompany INTO
              x_movement_transaction.customer_trx_line_id
            , x_movement_transaction.invoice_id
            , l_extended_amount
            , x_movement_transaction.invoice_quantity;
            CLOSE l_ar_intercompany;

            --Recalculate invoice amount for ar intercompany CTO item
            IF l_item_type_code = 'CONFIG'
               AND x_movement_transaction.customer_trx_line_id IS NOT NULL
            THEN
              Calc_Cto_Amount_ar
              ( p_order_line_id      => l_movement_transaction.order_line_id
              , p_order_number       => to_char(l_movement_transaction.order_number)
              , x_extended_amount    => l_extended_amount
              );
            END IF;
          END IF;   -- end if elsif
	     END IF ;  -- end of IO loop


      /*********************************** Special case for an IO - END**************************************/

      IF l_movement_transaction.document_source_type = 'RMA'
      THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_procedure_name || '.begin'
                    ,'************ 2 RMA ******************'
                    );
      END IF;
      /*bug 8435314 */
      Open l_rma_config;
      Fetch l_rma_config into l_item_type_code;
      Close l_rma_config;
      IF l_item_type_code = 'CONFIG'
      Then
        Open l_rma_model_id;
        Fetch l_rma_model_id into l_model_line_id;
        Close l_rma_model_id;
        IF  l_model_line_id is not null then
        FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_line_id 1 : '||l_movement_transaction.order_line_id);
           l_movement_transaction.order_line_id :=l_model_line_id;
        FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_line_id 2 : '||l_movement_transaction.order_line_id);
        End if;
      End if;
     /*End bug 8435314*/
/* bug# 7165989  Intercompany AP/AR Invoice for RMA*/
--If this RMA is created and shipped in different legal entity
--and we are in invoice based triangulation mode,we need
-- intercompany invoice
  IF (l_so_le_id IS NOT NULL
      AND l_so_le_id <> l_shipping_le_id
      AND NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')
               ='INVOICE_BASED')
  THEN
  --If this processor is run at the legal entity where this SO
          --is created and the record created is Arrival intercompany SO
          --we need an intercompany ap invoice
          IF (l_so_le_id = l_movement_transaction.entity_org_id
             AND l_movement_transaction.movement_type = 'D')--change from A to D
          THEN
		    --intercompany ap invoice
		    OPEN l_ap_intercompany;
		    FETCH l_ap_intercompany INTO
		      x_movement_transaction.invoice_id
		    , x_movement_transaction.distribution_line_number
		    , l_extended_amount
		    , x_movement_transaction.invoice_quantity;
		    CLOSE l_ap_intercompany;

		    FND_FILE.put_line(FND_FILE.log, 'The invoice id  is : '||x_movement_transaction.invoice_id);
		    FND_FILE.put_line(FND_FILE.log, 'The invoice qty(1) is : '||x_movement_transaction.invoice_quantity);

		    IF x_movement_transaction.invoice_id IS NOT NULL
		    THEN
		      --Recalculate invoice amount for ap intercompany CTO item
		      IF l_item_type_code = 'CONFIG'
		      THEN
			Calc_Cto_Amount_ap
			( p_order_line_id      => l_movement_transaction.order_line_id
			, p_order_number       => to_char(l_movement_transaction.order_number)
			, x_extended_amount    => l_extended_amount
			);
		      END IF;
		      -- bug 5411006, Following IF block is added to get details from AR invoice
		      -- if Amount or Quantity is missing from AP Invoice.

		      /* 7165989 - new cursor defined for intercompany RMA Dispatch */
		      /* The invoice quantity is fetched from quantity_credited in RA_CUSTOMER_TRX_LINES_ALL*/
		      /* as AP_INVOICES_ALL does not have the invoice quantity */
		      IF l_extended_amount = 0 OR x_movement_transaction.invoice_quantity = 0 THEN
			       OPEN l_ap_intercompany_rma_inv_qty;
			       FETCH l_ap_intercompany_rma_inv_qty INTO
				 l_ar_invoiced_amount, l_ar_invoiced_qty;
			       CLOSE l_ap_intercompany_rma_inv_qty;
			       IF l_extended_amount = 0 THEN
					l_extended_amount := l_ar_invoiced_amount;
			       END IF;
			       IF x_movement_transaction.invoice_quantity = 0 THEN
					x_movement_transaction.invoice_quantity := l_ar_invoiced_qty;
			       END IF;

			  FND_FILE.put_line(FND_FILE.log, 'The invoice qty(2) is  : '||x_movement_transaction.invoice_quantity);

		      END IF;
		      --Open cursor to get other invoice information
		      OPEN l_ap_intercompany_invo;
		      FETCH l_ap_intercompany_invo INTO
			x_movement_transaction.currency_code
		      , x_movement_transaction.currency_conversion_rate
		      , x_movement_transaction.currency_conversion_type
		      , x_movement_transaction.currency_conversion_date
		      , x_movement_transaction.invoice_batch_id
		      , x_movement_transaction.invoice_date_reference;

		      FND_FILE.put_line(FND_FILE.log, 'The currency_code is  : '||x_movement_transaction.currency_code);
		      FND_FILE.put_line(FND_FILE.log, 'The currency_conversion_rate is  : '||x_movement_transaction.currency_conversion_rate);
		      FND_FILE.put_line(FND_FILE.log, 'The currency_conversion_type is  : '||x_movement_transaction.currency_conversion_type);
		      FND_FILE.put_line(FND_FILE.log, 'The currency_conversion_date is  : '||x_movement_transaction.currency_conversion_date);
		      FND_FILE.put_line(FND_FILE.log, 'The invoice_batch_id is  : '||x_movement_transaction.invoice_batch_id);
		      FND_FILE.put_line(FND_FILE.log, 'The invoice_date_reference is  : '||x_movement_transaction.invoice_date_reference);


		      IF l_ap_intercompany_invo%NOTFOUND
		      THEN
			x_movement_transaction.currency_code            := l_tran_curr_code;
			x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
			x_movement_transaction.currency_conversion_type := l_tran_curr_type;
			x_movement_transaction.currency_conversion_date := l_tran_curr_date;
			x_movement_transaction.invoice_batch_id         := null;
			x_movement_transaction.invoice_date_reference   := null;
		      END IF;
		      CLOSE l_ap_intercompany_invo;
		    END IF; -- Intercompany AR Invoice
          --If this processor is run at the legal entity where this SO
          --is created but the record created is a virtual Dispatch to customer
          --we need an regular ar invoice to customer
          ELSIF (l_so_le_id = l_movement_transaction.entity_org_id
                AND l_movement_transaction.movement_type = 'A')--change from D to A
          THEN
            --Check for Credit/debit memo transaction type against RMA.
		OPEN l_sum_rma_arc;
		FETCH l_sum_rma_arc INTO
		  x_movement_transaction.customer_trx_line_id
	        , x_movement_transaction.invoice_id
	        , l_extended_amount
	        , x_movement_transaction.invoice_quantity;
	         CLOSE l_sum_rma_arc;

		--Recalculate invoice amount for rma CTO item
		 IF l_item_type_code = 'CONFIG'
		   AND x_movement_transaction.customer_trx_line_id IS NOT NULL
		  THEN
              FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_line_id 3 : '||l_movement_transaction.order_line_id);
              FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_number  3: '||l_movement_transaction.order_number);
              FND_FILE.put_line(FND_FILE.log, 'The l_extended_amount 3 : '||l_extended_amount);
              FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.org_id 3 : '||l_movement_transaction.org_id);
              Calc_Cto_Amount_Rma
			   ( p_order_line_id      => l_movement_transaction.order_line_id
			   , p_order_number       => to_char(l_movement_transaction.order_number)
			   , p_org_id             => l_movement_transaction.org_id
			   , x_extended_amount    => l_extended_amount
			   );
               FND_FILE.put_line(FND_FILE.log, 'The l_extended_amount 3.1 : '||l_extended_amount);
	         END IF;

          --If this processor is run at the legal entity where this SO
          --is shipped, we need an ar intercompany invoice
          ELSIF (l_shipping_le_id = l_movement_transaction.entity_org_id
	  AND l_movement_transaction.movement_type = 'A')
          THEN
		OPEN l_ar_intercompany;
	        FETCH l_ar_intercompany INTO
		      x_movement_transaction.customer_trx_line_id
	            , x_movement_transaction.invoice_id
		    , l_extended_amount
	            , x_movement_transaction.invoice_quantity;
		CLOSE l_ar_intercompany;

            --Recalculate invoice amount for ar intercompany CTO item
		IF l_item_type_code = 'CONFIG'
                   AND x_movement_transaction.customer_trx_line_id IS NOT NULL
	        THEN
		      Calc_Cto_Amount_ar
	              ( p_order_line_id      => l_movement_transaction.order_line_id
		      , p_order_number       => to_char(l_movement_transaction.order_number)
	              , x_extended_amount    => l_extended_amount
	              );
                END IF;
          END IF;
    ELSE
/* bug# 7165989 End Intercompany AP/AR Invoice for RMA*/
        --Check for Credit/debit memo transaction type against SO.
        OPEN l_sum_rma_arc;
        FETCH l_sum_rma_arc INTO
          x_movement_transaction.customer_trx_line_id
        , x_movement_transaction.invoice_id
        , l_extended_amount
        , x_movement_transaction.invoice_quantity;
        CLOSE l_sum_rma_arc;

        --Recalculate invoice amount for rma CTO item
        IF l_item_type_code = 'CONFIG'
           AND x_movement_transaction.customer_trx_line_id IS NOT NULL
        THEN
          FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_line_id 4 : '||l_movement_transaction.order_line_id);
          FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.order_number  4: '||l_movement_transaction.order_number);
          FND_FILE.put_line(FND_FILE.log, 'The l_extended_amount 1 4: '||l_extended_amount);
          FND_FILE.put_line(FND_FILE.log, 'The l_movement_transaction.org_id 4 : '||l_movement_transaction.org_id);
          Calc_Cto_Amount_Rma
          ( p_order_line_id      => l_movement_transaction.order_line_id
          , p_order_number       => to_char(l_movement_transaction.order_number)
          , p_org_id             => l_movement_transaction.org_id
          , x_extended_amount    => l_extended_amount
          );
          FND_FILE.put_line(FND_FILE.log, 'The l_extended_amount 4.1: '||l_extended_amount);
        END IF;

        /*--Fix bug 2695323
        --In the case of multiple receipts for a KIT RMA, the kit order line
        --is not split for the multiple receipts. One invoice for the order line
        --and multiple receipts. Do a proportional calculation for the invoice
        --qty for each receipt
        --Get total return qty
        SELECT ordered_quantity
          INTO l_total_rma_qty
          FROM oe_order_lines_all
         WHERE line_id = l_movement_transaction.order_line_id;

        x_movement_transaction.invoice_quantity :=
             (l_movement_transaction.transaction_quantity/l_total_rma_qty)
              * x_movement_transaction.invoice_quantity;
        l_extended_amount :=
             (l_movement_transaction.transaction_quantity/l_total_rma_qty)
              * l_extended_amount;*/
      END IF;
    End if;/*7165989*/
      --Get other invoice information
      --Bug 6035548. Invoice details for RMA should always be calculated
      --even when selling org is diff than shipping org.
      IF (l_so_le_id <> l_shipping_le_id
          AND l_so_le_id = l_movement_transaction.entity_org_id
          AND l_movement_transaction.movement_type = 'A'
          AND l_movement_transaction.document_source_type <> 'RMA' )
      THEN
        NULL;
      ELSE
       /* Bug 7165989 - For IO arrival,  look only at the AP invoice, not the AR invoice */
        IF (l_movement_transaction.movement_type = 'A'
        AND l_movement_transaction.document_source_type = 'IO')
	OR (l_movement_transaction.movement_type = 'D'
	AND l_movement_transaction.document_source_type = 'RMA') THEN
	  NULL;
	else

        OPEN l_arc;
        FETCH l_arc INTO
          x_movement_transaction.invoice_date_reference
        , x_movement_transaction.invoice_batch_id
        , x_movement_transaction.currency_conversion_rate
        , x_movement_transaction.currency_conversion_type
        , x_movement_transaction.currency_conversion_date
        , x_movement_transaction.currency_code;

        IF l_arc%NOTFOUND
        THEN
          x_movement_transaction.currency_code            := l_tran_curr_code;
          x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
          x_movement_transaction.currency_conversion_type := l_tran_curr_type;
          x_movement_transaction.currency_conversion_date := l_tran_curr_date;
          x_movement_transaction.invoice_batch_id         := null;
          x_movement_transaction.invoice_date_reference   := null;
        END IF;
        CLOSE l_arc;
      END IF;
      End if;
    ELSE   --drop shimement
      OPEN l_sum_drparc;
      FETCH l_sum_drparc INTO
        x_movement_transaction.customer_trx_line_id
      , x_movement_transaction.invoice_id
      , l_extended_amount
      , x_movement_transaction.invoice_quantity;
      CLOSE l_sum_drparc;

      IF x_movement_transaction.invoice_id IS NOT NULL
      THEN
        OPEN l_sum_cm_drparc;
        FETCH l_sum_cm_drparc INTO
          l_cm_extended_amount;
        CLOSE l_sum_cm_drparc;
      END IF;

      OPEN l_drparc;
      FETCH l_drparc INTO
        x_movement_transaction.invoice_date_reference
      , x_movement_transaction.invoice_batch_id
      , x_movement_transaction.currency_conversion_rate
      , x_movement_transaction.currency_conversion_type
      , x_movement_transaction.currency_conversion_date
      , x_movement_transaction.currency_code;
      CLOSE l_drparc;

      --Recalculate invoice amount for dropship CTO item
      IF l_item_type_code = 'CONFIG'
         AND x_movement_transaction.customer_trx_line_id IS NOT NULL
      THEN
        Calc_Cto_Amount_Drp
        ( p_order_line_id      => l_movement_transaction.order_line_id
        , p_order_number       => to_char(l_movement_transaction.order_number)
        , x_extended_amount    => l_extended_amount
        , x_cm_extended_amount => l_cm_extended_amount
        );
      END IF;
    END IF;

    IF l_extended_amount IS NULL
    THEN
      x_movement_transaction.invoice_line_ext_value := null;
      x_movement_transaction.invoice_unit_price := null;
      x_movement_transaction.invoice_quantity := null;
    ELSE

      l_extended_amount := l_extended_amount + NVL(l_cm_extended_amount,0);
      x_movement_transaction.invoice_line_ext_value := l_extended_amount;
		          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
		          THEN
		          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
		              , G_MODULE_NAME || l_procedure_name || 'EXTENDED AMOUNT IS ********************* '
		              , l_extended_amount
		              );
		          END IF ;

      x_movement_transaction.invoice_quantity :=
           NVL(x_movement_transaction.invoice_quantity,
           x_movement_transaction.transaction_quantity);

      IF (x_movement_transaction.invoice_quantity IS NOT NULL
          AND x_movement_transaction.invoice_quantity <> 0)
      THEN
        x_movement_transaction.invoice_unit_price :=
                      l_extended_amount / x_movement_transaction.invoice_quantity;
--		          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
--		          THEN
--		          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
--		              , G_MODULE_NAME || l_procedure_name || 'unit_price IS ********************* '
--		              ,  x_movement_transaction.invoice_unit_price
--		              );
--		          END IF ;

--           IF (x_movement_transaction.invoice_id IS NOT NULL)
--           THEN
--            /* if intercompany invoice exists, the document unit price will be the same as the invoice unit price - 6889669 */
--            --x_movement_transaction.document_unit_price      := x_movement_transaction.invoice_unit_price;
--            x_movement_transaction.document_line_ext_value  := x_movement_transaction.invoice_unit_price *
--                                                              x_movement_transaction.transaction_quantity;
--           END IF;
      ELSE
        x_movement_transaction.invoice_unit_price := null;
      END IF;
    END IF;

  ELSIF l_movement_transaction.document_source_type IN ('PO')
  THEN
    -- Fetch the cursor for non credit memo type transactions. This is
    -- against receipt based matching if one exists;
    OPEN l_ap_inv ;
    FETCH l_ap_inv INTO
      l_extended_amount
    , x_movement_transaction.distribution_line_number
    , x_movement_transaction.invoice_id
    , l_invoice_quantity;
    CLOSE l_ap_inv;

    IF x_movement_transaction.invoice_id IS NOT NULL
    THEN
      -- Fetch the cursor for price correction.
      OPEN l_ap_prc_inv;
      FETCH l_ap_prc_inv INTO
        l_prc_amount;
      CLOSE l_ap_prc_inv;

      -- Fetch the cursor for quantity correction.
      OPEN l_ap_qtc_inv;
      FETCH l_ap_qtc_inv INTO
        l_qtc_qty
      , l_qtc_amount;
      CLOSE l_ap_qtc_inv;
    ELSE
      -- If receipt based matching does not exists, check if it matched agains
      -- a PO; check non credit memo based transactions;
      OPEN l_po_inv ;
      FETCH l_po_inv INTO
        l_extended_amount
      , x_movement_transaction.distribution_line_number
      , x_movement_transaction.invoice_id
      , l_invoice_quantity;
      CLOSE l_po_inv;

      IF x_movement_transaction.invoice_id IS NOT NULL
      THEN
       /*bug 8435322 Added new cursor to fetch max distribution_line_number for max Invoice Id*/
        OPEN l_po_line_number ;
        FETCH l_po_line_number INTO
          x_movement_transaction.distribution_line_number;
        CLOSE l_po_line_number;
        /*End bug 8435322*/
        -- Fetch the cursor for price correction.
        OPEN l_po_prc_inv ;
        FETCH l_po_prc_inv INTO
          l_prc_amount;
        CLOSE l_po_prc_inv;

        -- Fetch the cursor for quantity correction.
        OPEN l_po_qtc_inv;
        FETCH l_po_qtc_inv INTO
          l_qtc_qty
        , l_qtc_amount;
        CLOSE l_po_qtc_inv;
      ELSE
        x_movement_transaction.currency_code            := l_tran_curr_code;
        x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
        x_movement_transaction.currency_conversion_type := l_tran_curr_type;
        x_movement_transaction.currency_conversion_date := l_tran_curr_date;
        x_movement_transaction.invoice_batch_id         := null;
        x_movement_transaction.invoice_date_reference   := null;
        x_movement_transaction.invoice_id               := null;
        x_movement_transaction.invoice_quantity         := null;
        x_movement_transaction.invoice_unit_price       := null;
        x_movement_transaction.invoice_line_ext_value   := null;
        x_movement_transaction.distribution_line_number := null;
      END IF;
    END IF; -- finish check receipt/po based invoice

    --Fix italian bug 2861110.Update_invoice_info will revert any netted invoice
    --amt and qty back to original PO invoice amt and qty. The following code
    --will net the invoice amt and qty again for processed RTV
    IF (l_stat_typ_transaction.returns_processing = 'AGGRTN'
       AND x_movement_transaction.invoice_id IS NOT NULL)
    THEN
      Calc_Processed_Ret_Data
      (p_movement_transaction => l_movement_transaction
      , x_processed_ret_amt   => l_processed_ret_amt
      , x_processed_ret_qty   => l_processed_ret_qty
      );

      --The correct netted PO invoce amount and quantity
      l_extended_amount := l_extended_amount + NVL(l_processed_ret_amt,0);
      l_invoice_quantity := l_invoice_quantity + NVL(l_processed_ret_qty,0);
    END IF; --end bug 2861110

    IF l_extended_amount IS NULL
    THEN
      x_movement_transaction.invoice_line_ext_value := null;
      x_movement_transaction.invoice_unit_price := null;
      x_movement_transaction.invoice_quantity := null;
    ELSE
      l_extended_amount  := l_extended_amount + NVL(l_prc_amount,0) + NVL(l_qtc_amount, 0);
      x_movement_transaction.invoice_line_ext_value := l_extended_amount;

      x_movement_transaction.invoice_quantity     :=
        NVL(l_invoice_quantity,x_movement_transaction.transaction_quantity) + NVL(l_qtc_qty, 0);

      --Fix bug 2340128, decide to use extended amount to calculate unit
      --price
      IF (x_movement_transaction.invoice_quantity IS NOT NULL
          AND x_movement_transaction.invoice_quantity <> 0)
      THEN
        x_movement_transaction.invoice_unit_price :=
           l_extended_amount / x_movement_transaction.invoice_quantity;
      ELSE
        x_movement_transaction.invoice_unit_price := null;
      END IF;
    END IF;

    OPEN l_apc;
    FETCH l_apc INTO
      x_movement_transaction.currency_code
    , x_movement_transaction.currency_conversion_rate
    , x_movement_transaction.currency_conversion_type
    , x_movement_transaction.currency_conversion_date
    , x_movement_transaction.invoice_batch_id
    , x_movement_transaction.invoice_date_reference;

    IF l_apc%NOTFOUND
    THEN
      x_movement_transaction.currency_code            := l_tran_curr_code;
      x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
      x_movement_transaction.currency_conversion_type := l_tran_curr_type;
      x_movement_transaction.currency_conversion_date := l_tran_curr_date;
      x_movement_transaction.invoice_batch_id         := null;
      x_movement_transaction.invoice_date_reference   := null;
      x_movement_transaction.invoice_id               := null;
    END IF;

    CLOSE l_apc;
  ELSIF l_movement_transaction.document_source_type IN ('RTV')
  THEN
    --Get parent transaction id for RTV transaction
    --Used in open l_ap_rtv_cm_inv
    BEGIN
      IF l_movement_transaction.rcv_transaction_id IS NOT NULL
      THEN
        SELECT parent_transaction_id
        INTO   l_parent_transaction_id
        FROM   rcv_transactions
        WHERE  transaction_id = l_movement_transaction.rcv_transaction_id;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          l_parent_transaction_id := -1;
    END;

    --First check if this rtv matched to any receipt based credit memo
    OPEN l_ap_rtv_cm_inv ;
    FETCH l_ap_rtv_cm_inv INTO
      l_rtv_extended_amount
    , x_movement_transaction.distribution_line_number
    , x_movement_transaction.invoice_id
    , l_rtv_invoice_quantity;
    CLOSE l_ap_rtv_cm_inv;

    -- if the Credit/Debit memo is matched against Purchase Orders rather than
    -- receipts.
    IF x_movement_transaction.invoice_id IS NULL
    THEN
      OPEN l_po_rtv_cm_inv ;
      FETCH l_po_rtv_cm_inv INTO
        l_rtv_extended_amount
      , x_movement_transaction.distribution_line_number
      , x_movement_transaction.invoice_id
      , l_rtv_invoice_quantity;
      CLOSE l_po_rtv_cm_inv;
    END IF;    /*bug 8250147 Change end if condition to call l_apc cursor properly for ever case*/
      IF x_movement_transaction.invoice_id IS NULL
      THEN
        x_movement_transaction.currency_code            := l_tran_curr_code;
        x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
        x_movement_transaction.currency_conversion_type := l_tran_curr_type;
        x_movement_transaction.currency_conversion_date := l_tran_curr_date;
        x_movement_transaction.invoice_batch_id         := null;
        x_movement_transaction.invoice_date_reference   := null;
        x_movement_transaction.invoice_id               := null;
        x_movement_transaction.invoice_quantity         := null;
        x_movement_transaction.invoice_unit_price       := null;
        x_movement_transaction.invoice_line_ext_value   := null;
        x_movement_transaction.distribution_line_number := null;
      ELSE
        OPEN l_apc;
        FETCH l_apc INTO
          x_movement_transaction.currency_code
        , x_movement_transaction.currency_conversion_rate
        , x_movement_transaction.currency_conversion_type
        , x_movement_transaction.currency_conversion_date
        , x_movement_transaction.invoice_batch_id
        , x_movement_transaction.invoice_date_reference;

        IF l_apc%NOTFOUND
        THEN
          x_movement_transaction.currency_code            := l_tran_curr_code;
          x_movement_transaction.currency_conversion_rate := l_tran_curr_rate;
          x_movement_transaction.currency_conversion_type := l_tran_curr_type;
          x_movement_transaction.currency_conversion_date := l_tran_curr_date;
          x_movement_transaction.invoice_batch_id         := null;
          x_movement_transaction.invoice_date_reference   := null;
        END IF;
        CLOSE l_apc;
      END IF;  --second invoice id null
   /*END IF;    bug 8250147 Change end if condition to call l_apc cursor properly for ever case*/

    IF l_rtv_extended_amount IS NULL
    THEN
      x_movement_transaction.invoice_line_ext_value := null;
      x_movement_transaction.invoice_unit_price := null;
      x_movement_transaction.invoice_quantity := null;
    ELSE
      --In case there are multiple rtv associated with creidt memo, calculate
      --inoice amt and qty for this rtv
      --First find total rtv transaction quantity
      OPEN l_total_rtv_quantity;
      FETCH l_total_rtv_quantity INTO
        l_total_rtv_trans_qty;
      CLOSE l_total_rtv_quantity;

      --Amount and quantity for this rtv
      IF (l_total_rtv_trans_qty IS NOT NULL
         AND l_total_rtv_trans_qty <> 0)
      THEN
        l_rtv_invoice_quantity       :=
           (x_movement_transaction.transaction_quantity/l_total_rtv_trans_qty)
            * l_rtv_invoice_quantity;
        l_rtv_extended_amount        :=
           (x_movement_transaction.transaction_quantity/l_total_rtv_trans_qty)
            *l_rtv_extended_amount;
      END IF;

      --Set rtv qty and amt
      x_movement_transaction.invoice_quantity       :=
           NVL(l_rtv_invoice_quantity,x_movement_transaction.transaction_quantity);
      x_movement_transaction.invoice_line_ext_value := l_rtv_extended_amount;

      IF (l_rtv_invoice_quantity <> 0
          AND l_rtv_extended_amount IS NOT NULL)
      THEN
        x_movement_transaction.invoice_unit_price
           := l_rtv_extended_amount/l_rtv_invoice_quantity;
      ELSE
        x_movement_transaction.invoice_unit_price := NULL;
      END IF;
    END IF;  -- end rtv_extended_amount null
  END IF;

  /*--If there is no invoice
  IF x_movement_transaction.invoice_id IS NULL
  THEN
    --If transaction currency is same as functional currency
    IF NVL(x_movement_transaction.currency_code,FND_API.G_MISS_CHAR) =
       NVL(l_stat_typ_transaction.gl_currency_code,FND_API.G_MISS_CHAR)
    THEN
      x_movement_transaction.currency_conversion_rate := 1;
      x_movement_transaction.currency_conversion_type := null;
      x_movement_transaction.currency_conversion_date := null;

    --If transaction currency is different from functional currency and
    --transaction conversion rate/type is not populated in PO/SO document
    --calc rate from GL package
    ELSIF (x_movement_transaction.currency_conversion_rate IS NULL
           OR x_movement_transaction.currency_conversion_type IS NULL)
    THEN
      Calc_Exchange_Rate( x_movement_transaction => x_movement_transaction
                        , p_stat_typ_transaction => l_stat_typ_transaction
            	        );
    END IF;
  END IF; */

  IF NVL(x_movement_transaction.currency_code,FND_API.G_MISS_CHAR) =
       NVL(l_stat_typ_transaction.gl_currency_code,FND_API.G_MISS_CHAR)
  THEN
    x_movement_transaction.currency_conversion_rate := 1;
    x_movement_transaction.currency_conversion_date := null;
    x_movement_transaction.currency_conversion_type := null;
  ELSE
    --Fix bug 4285335, if user setup a conversion type on parameter form, always take the type
    --from parameter form, the two parameters are modified to optional
    IF l_stat_typ_transaction.conversion_type IS NOT NULL
    THEN
      x_movement_transaction.currency_conversion_type := l_stat_typ_transaction.conversion_type;

      Calc_Exchange_Rate
      ( x_movement_transaction => x_movement_transaction
      , p_stat_typ_transaction => l_stat_typ_transaction
      );
    END IF;
  END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No data found exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction := l_movement_transaction;

      --Switch back the order line id for CTO item
      IF (l_item_type_code = 'CONFIG' AND l_cto_line_id IS NOT NULL)
      THEN
        x_movement_transaction.order_line_id := l_cto_line_id;
      END IF;
  WHEN TOO_MANY_ROWS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.too many rows exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction := l_movement_transaction;

      --Switch back the order line id for CTO item
      IF (l_item_type_code = 'CONFIG' AND l_cto_line_id IS NOT NULL)
      THEN
        x_movement_transaction.order_line_id := l_cto_line_id;
      END IF;
  WHEN OTHERS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.Others exception'
                      , 'Exception'
                      );
      END IF;
      x_movement_transaction := l_movement_transaction;

      --Switch back the order line id for CTO item
      IF (l_item_type_code = 'CONFIG' AND l_cto_line_id IS NOT NULL)
      THEN
        x_movement_transaction.order_line_id := l_cto_line_id;
      END IF;
END Calc_Invoice_Info;


--========================================================================
-- FUNCTION :  Get_Set_Of_Books_Period
-- PARAMETERS: p_legal_entity_id        Legal Entity
--             p_period_date            Invoice date or transaction date
-- COMMENT   : Function that returns the Period Name
--             based on invoice date or movement date if invoice date is null
--=========================================================================
/* Bug: 5291257. Function defintion is modified to remove parameter
p_period_type.  */
FUNCTION Get_Set_Of_Books_Period
( p_legal_entity_id IN VARCHAR2
, p_period_date     IN DATE
--, p_period_type     IN VARCHAR2
)
RETURN VARCHAR2
IS
  l_set_of_books_period  VARCHAR2(15);
  l_function_name CONSTANT VARCHAR2(30) := 'Get_Set_Of_Books_Period';

/* Bug: 5291257. Following cursor definition is modified and p_period_type is replaced with
gllv.accounted_period_type */
CURSOR c_pname IS
  SELECT
    glp.period_name
  FROM
    gl_periods glp
  , gl_ledger_le_v gllv
  WHERE gllv.period_set_name                = glp.period_set_name
    AND gllv.legal_entity_id                = p_legal_entity_id
    AND gllv.ledger_category_code           = 'PRIMARY'
    AND glp.period_type                     = gllv.accounted_period_type
    AND NVL(glp.adjustment_period_flag,'N') = 'N'
    AND trunc(p_period_date) BETWEEN trunc(glp.start_date) AND trunc(glp.end_date);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN c_pname;
  FETCH c_pname
  INTO l_set_of_books_period;

  IF c_pname%NOTFOUND THEN
    l_set_of_books_period:= null;
  END IF;

  CLOSE c_pname;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

RETURN l_set_of_books_period;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Set_Of_Books_Period;


--========================================================================
-- FUNCTION :  Get_Period_Name
-- PARAMETERS: p_movement_transacton    Movement Transaction record
--             p_stat_typ_transaction   Stat typ tranaction
-- COMMENT   : Function that returns the Period Name
--=========================================================================

FUNCTION Get_Period_Name
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
)
RETURN VARCHAR2
IS
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_function_name CONSTANT VARCHAR2(30) := 'Get_Period_Name';

CURSOR c_period IS
  SELECT
    period_name
  FROM
    GL_PERIODS
  WHERE period_set_name = l_stat_typ_transaction.period_set_name
  AND   l_movement_transaction.transaction_date between
        (start_date) and (end_date)
  AND   start_date      >= l_stat_typ_transaction.start_date
  AND   end_date        <= l_stat_typ_transaction.end_date
  AND   period_type      = l_stat_typ_transaction.period_type
  AND   NVL(adjustment_period_flag,'N') = 'N';

CURSOR c_period1 IS
  SELECT
    period_name
  FROM
    GL_PERIODS
  WHERE period_set_name = l_stat_typ_transaction.period_set_name
  AND   trunc(l_movement_transaction.transaction_date) between
        trunc(start_date) and trunc(end_date)
  AND   period_type      = l_stat_typ_transaction.period_type
  AND   start_date      >= l_stat_typ_transaction.start_date
  AND   NVL(adjustment_period_flag,'N') = 'N';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

    l_movement_transaction := p_movement_transaction;
    l_stat_typ_transaction := p_stat_typ_transaction;

    IF (l_stat_typ_transaction.start_date IS NOT NULL)
       AND
       (l_stat_typ_transaction.end_date IS NOT NULL)
    THEN
      OPEN  c_period;
      FETCH c_period
      INTO l_movement_transaction.period_name;

      IF c_period%NOTFOUND THEN
         CLOSE c_period;
      ELSE
         CLOSE c_period;
      END IF;

    ELSE
      OPEN  c_period1;
      FETCH c_period1
      INTO l_movement_transaction.period_name;

      IF c_period1%NOTFOUND THEN
         CLOSE c_period1;
      ELSE
         CLOSE c_period1;
      END IF;
   END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_function_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

   RETURN l_movement_transaction.period_name;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_function_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN NULL;
END Get_Period_Name;


--========================================================================
-- PROCEDURE : Get_Reference_Date
-- PARAMETERS: x_movement_transacton    Movement Transaction record
--             p_stat_typ_transaction   Stat typ tranaction
-- COMMENT   : Procedure that gets the Reference Date
--=========================================================================

PROCEDURE Get_Reference_Date
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
  l_transaction_date     DATE;
  l_invoice_date         DATE;
  l_pending_date         DATE;
  l_months               NUMBER;
  l_no_days              NUMBER;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Reference_Date';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_stat_typ_transaction := p_stat_typ_transaction;
  l_transaction_date     := x_movement_transaction.transaction_date;
  l_invoice_date         := x_movement_transaction.invoice_date_reference;

  --Fix bug 4927726
  --Find out the original transaction date for a pending record, the current
  --transaction date is a reference date calculated before
  IF x_movement_transaction.movement_status = 'P'
  THEN
  -- Bug 5741580. Following code is modified to fetch the transaction date again
  -- from original transactions.
   IF  x_movement_transaction.document_source_type = 'SO'
   THEN
    SELECT initial_pickup_date
      INTO l_transaction_date
      FROM wsh_delivery_details_ob_grp_v wdd
      , wsh_new_deliveries_ob_grp_v   wnd
      , wsh_delivery_assignments wda
     WHERE wnd.delivery_id = wda.delivery_id
     AND wda.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.source_line_id = x_movement_transaction.order_line_id
     AND wda.delivery_detail_id = x_movement_transaction.picking_line_detail_id
     AND wdd.organization_id = x_movement_transaction.organization_id
     AND nvl(wnd.customer_id,wdd.customer_id) = x_movement_transaction.ship_to_customer_id
     AND rownum = 1;
   ELSIF  x_movement_transaction.document_source_type = 'INV'
   THEN
     SELECT transaction_date
     INTO l_transaction_date
     FROM MTL_MATERIAL_TRANSACTIONS MMT
     WHERE MMT.transaction_id = x_movement_transaction.mtl_transaction_id;
   ELSE
     SELECT transaction_date
     INTO l_transaction_date
     FROM rcv_transactions
     WHERE transaction_id = x_movement_transaction.rcv_transaction_id;
   END IF;
  END IF;

  --Get correct pending date
  --Find out the number of days the next month of the transaction date
  SELECT to_number(to_char(LAST_DAY(add_months(l_transaction_date,1)),'DD'))
  INTO
    l_no_days
  FROM DUAL;

  -- If the pending invoice days is greater than the # of days in the month,
  -- then pending_invoice_days is the # of days in the month.
  IF l_no_days < NVL(l_stat_typ_transaction.pending_invoice_days,15)
  THEN
    l_stat_typ_transaction.pending_invoice_days := l_no_days;
  END IF;

  l_pending_date := to_date( NVL(l_stat_typ_transaction.pending_invoice_days,15)
                    ||'-'||to_char(add_months(l_transaction_date,1),'MON-YY'),'DD-MON-YY');

  -- If there is no invoice ,check if it has passed the invoice
  -- threshold date (pending_invoice_days) to determine the movement status
  -- the reference date is always same as the pending date.
  IF (x_movement_transaction.invoice_id IS NULL)
  THEN
    --Fix bug 4170403
    /*l_months := round(months_between(sysdate, l_transaction_date));

    --If the transaction has taken place more than a month ago, or if the
    --transaction has taken place previous month and sysdate is greater
    --than the pending invoice days, reference date is the following month
    --plus the pending_invoice_days.
    IF (l_months > 1) OR
       (((l_months =1) AND (to_char(sysdate,'DD') >
          l_stat_typ_transaction.pending_invoice_days)) AND
       (to_char(sysdate,'MM') <> to_char(l_transaction_date,'MM'))) */

    IF GREATEST(sysdate ,l_pending_date) = sysdate
    THEN
      x_movement_transaction.movement_status :='O';
    ELSE
      -- Wait for the invoice till next month
      x_movement_transaction.movement_status :='P';
    END IF;

    x_movement_transaction.reference_date := l_pending_date;
  ELSE -- invoice present
    IF (l_transaction_date = l_invoice_date)
    THEN
      x_movement_transaction.reference_date := x_movement_transaction.transaction_date;
    -- Invoice was received before the transaction took place;
    ELSIF (GREATEST(l_transaction_date ,l_invoice_date) = l_transaction_date)
    THEN
      IF (l_transaction_date - l_invoice_date ) >
          NVL(l_stat_typ_transaction.prior_invoice_days,30)
      THEN
        x_movement_transaction.reference_date := l_transaction_date;
      ELSE
        x_movement_transaction.reference_date := l_invoice_date;
      END IF;
    ELSE -- invoice is received later
      --Fix bug 2365712 yawang
      --IF (l_invoice_date - l_transaction_date ) >
      --        NVL(l_stat_typ_transaction.pending_invoice_days,15)
      IF (GREATEST(l_invoice_date ,l_pending_date) = l_invoice_date)
      THEN
        x_movement_transaction.reference_date := l_pending_date;
      ELSE
        x_movement_transaction.reference_date := l_invoice_date;
      END IF;
    END IF;

    x_movement_transaction.movement_status :='O';
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Get_Reference_Date;


--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;


END  INV_MGD_MVT_FIN_MDTR;

/
