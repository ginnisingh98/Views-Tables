--------------------------------------------------------
--  DDL for Package Body JAI_PO_WF_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_WF_UTIL_PUB" AS
/* $Header: jainpowfut.plb 120.0.12010000.6 2009/08/11 07:36:49 erma noship $ */
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     jainpowfut.pls                                                    |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This is the utility package for IL po notification.               |
  --|                                                                       |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Get_Req_Curr_Conv_Rate                                 |
  --|      PROCEDURE Get_Currency_Convertion_Rate                           |
  --|      PROCEDURE Get_Jai_Tax_Amount                                     |
  --|      PROCEDURE Get_Jai_New_Tax_Amount                                 |
  --|      PROCEDURE Populate_Session_GT                                    |
  --|      FUNCTION  Get_Tax_Region                                         |
  --|      FUNCTION  Get_Poreq_Tax                                          |
  --|      FUNCTION  Get_Jai_Req_Tax_Disp                                   |
  --|      FUNCTION  Get_Jai_Tax_Disp                                       |
  --|      FUNCTION  Get_Jai_Open_Form_Command                              |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     2009-Feb-11 Eric Ma   Created
  --|     2009-Aug-02 Eric Ma   Code change in the procedure of  Get_Jai_Open_Form_Command
  --|                           removing all "" from the code for the bug 8744317
  --|
  --|     2009-Aug-03 Eric Ma   Remove all logic in the procedures  and
  --|                           return NULL for all functions for bug 8757047 and 8757049
  --|
  --|     2009-Aug-11 Eric Ma   Restore all business logic for bug 8785506
  --|
  --+======================================================================*/

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Req_Curr_Conv_Rate                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the conversion rate for a Requsition line
  --
  --  PARAMETERS:
  --      In: pn_req_header_id      IN   NUMBER               req header id
  --          pn_req_line_id        IN   NUMBER               req line id
  --          pv_tax_currency       IN   VARCHAR2             tax currency code
  --          xn_conversion_rate    OUT  NUMBER               conversion  rate
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================

  PROCEDURE Get_Req_Curr_Conv_Rate
  ( pn_req_header_id     IN NUMBER
  , pn_req_line_id       IN NUMBER
  , pv_tax_currency      IN VARCHAR2
  , xn_conversion_rate   OUT NOCOPY NUMBER
  )
  IS
  ln_denominator_rate       NUMBER;
  ln_numerator_rate         NUMBER;
  ln_currency_rate          NUMBER;

  lv_base_currency           GL_SETS_OF_BOOKS.currency_code%TYPE;
  lv_req_conv_curr_rate_type  po_requisition_lines_all.rate_type%TYPE;
  ld_req_conv_curr_rate_date  po_requisition_lines_all.rate_date%TYPE;
  ln_req_conv_curr_rate       po_requisition_lines_all.rate%TYPE;
  lv_req_conv_curr_code       po_requisition_lines_all.currency_code%TYPE;

  lv_procedure_name     VARCHAR2(40):='Get_Req_Curr_Conv_Rate';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;

  CURSOR Get_Curr_Conv_Rate_Cur
  IS
  SELECT
    currency_code
  , rate
  FROM
    PO_REQUISITION_LINES_ALL
  WHERE  requisition_header_id = pn_req_header_id
    AND  requisition_line_id   = pn_req_line_id ;

  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    lv_base_currency := PO_CORE_S2.get_base_currency;

     OPEN  Get_Curr_Conv_Rate_Cur;
    FETCH  Get_Curr_Conv_Rate_Cur
     INTO  lv_req_conv_curr_code,ln_req_conv_curr_rate;
    CLOSE  Get_Curr_Conv_Rate_Cur;


    --dbms_output.put_line ( '-------Get_Req_Curr_Conv_Rate-------');
    --dbms_output.put_line ( 'pn_req_header_id             ='||pn_req_header_id);
    --dbms_output.put_line ( 'pn_req_line_id         ='||pn_req_line_id);
    --dbms_output.put_line ( 'pv_tax_currency        ='||pv_tax_currency);
    --dbms_output.put_line ( 'ln_req_conv_curr_rate   ='||ln_req_conv_curr_rate);
    --dbms_output.put_line ( 'lv_base_currency        ='||lv_base_currency);

    --When the line currency is same as base currency, no conversion rate can be retrived
    --from the req table. So assign the value 1 to the rate
    IF (lv_req_conv_curr_code = lv_base_currency)
    THEN
      ln_req_conv_curr_rate :=1;
    END IF;

    --When no foreign currency code in the line level,
    --the line currency is same as the currency in header level
    --and the document currency of requesition is always the base currency
    --So converstion rate is 1
    IF lv_req_conv_curr_code IS NULL
    THEN
      lv_req_conv_curr_code :=lv_base_currency;
      ln_req_conv_curr_rate :=1;
    END IF;

    --For all of the belwo case,convert the tax from foreign
    -- currency to the base currency by the  ln_currency_rate

    IF (pv_tax_currency = lv_req_conv_curr_code)
    THEN
      -- If the currency in the current tax line is same as the foreign
      -- currency code defined in the Req Line, use the REQ line convertion rate
      ln_currency_rate :=  ln_req_conv_curr_rate;

      --dbms_output.put_line ( 'if 1');
    ELSIF (pv_tax_currency = lv_base_currency)
    THEN
      -- If the tax currency equals to the base currency,
      -- then the converstion_rate  is 1
      ln_currency_rate := 1;

      --dbms_output.put_line ( 'if 2');
    ELSE
     -- In other cases, coverting the currency by the type and date
     -- defined in the REQ line level
      gl_currency_api.get_closest_triangulation_rate
      ( x_from_currency    => pv_tax_currency
      , x_to_currency      => lv_base_currency
      , x_conversion_date  => ld_req_conv_curr_rate_date
      , x_conversion_type  => lv_req_conv_curr_rate_type
      , x_max_roll_days    => 5
      , x_denominator      => ln_denominator_rate
      , x_numerator        => ln_numerator_rate
      , x_rate             => ln_currency_rate
      );
      --dbms_output.put_line ( 'if 3');
    END IF; --(pv_tax_currency = ln_req_conv_curr_code)

    xn_conversion_rate := ln_currency_rate;

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)
  EXCEPTION
    WHEN OTHERS
    THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  END Get_Req_Curr_Conv_Rate;

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Currency_Convertion_Rate                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the conversion rate for PO/PA
  --
  --  PARAMETERS:
  --      In: pn_document_id      IN   NUMBER               PO/PA header id
  --          pv_tax_currency     IN   VARCHAR2             tax currency code
  --          xn_conversion_rate  OUT  NUMBER               conversion  rate
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================
  PROCEDURE Get_Currency_Convertion_Rate
  ( pn_document_id   IN NUMBER
  , pv_tax_currency  IN VARCHAR2
  , xn_conversion_rate OUT NOCOPY NUMBER
  )
  IS
  ln_denominator_rate       NUMBER;
  ln_numerator_rate         NUMBER;
  ln_currency_rate          NUMBER;

  lv_currency_code          PO_HEADERS_ALL.currency_code%TYPE;
  lv_po_currency_rate_type  PO_HEADERS_ALL.rate_type%TYPE;
  ld_po_currency_rate_date  PO_HEADERS_ALL.rate_date%TYPE;
  ln_po_currency_rate       PO_HEADERS_ALL.rate%TYPE;
  lv_base_currency          GL_SETS_OF_BOOKS.currency_code%TYPE;
  lv_po_currency            PO_HEADERS_ALL.currency_code%TYPE;

  lv_procedure_name     VARCHAR2(40):='Get_Currency_Convertion_Rate';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    -- get the currency convert information from po/pa header level
    PO_CORE_S2.GET_PO_CURRENCY_INFO (p_po_header_id      => pn_document_id,
                                     x_currency_code     => lv_currency_code,
                                     x_curr_rate_type    => lv_po_currency_rate_type,
                                     x_curr_rate_date    => ld_po_currency_rate_date,
                                     x_currency_rate     => ln_po_currency_rate);

     -- get the PO/PA currency and base currency
     PO_CORE_S2.GET_PO_CURRENCY (x_object_id      =>pn_document_id,
                                 x_base_currency  =>lv_base_currency ,
                                 x_po_currency    =>lv_po_currency);


    IF (pv_tax_currency <> lv_po_currency        --TAX CURRENCY <> PO/PA CURRENCY
        AND pv_tax_currency = lv_base_currency   --TAX CURRENCY =  PO/PA CURRENCY
        AND lv_po_currency  = lv_currency_code   --PO/PA CURRENCY  = THE CURRENCY DEFINED IN CONVERSION FORM
       )
    THEN
      -- the tax currency is different from PO/PA currency
      -- so change the tax currency to the PO/PA currency
      -- and also the converstion rate is defined in the po_header level
      ln_currency_rate :=1/ln_po_currency_rate;
    ELSIF (pv_tax_currency = lv_po_currency )
    THEN
      -- the tax currency eaquals to PO/PA currency
      -- then the converation rate is 1
      ln_currency_rate :=1;
    ELSE
      -- the converation rate is not defined
      -- user the convertion type / converstion date defined in the po header
      -- change the tax currency to the PO/PA currency
      gl_currency_api.get_closest_triangulation_rate
      ( x_from_currency    => pv_tax_currency
      , x_to_currency      => lv_po_currency
      , x_conversion_date  => ld_po_currency_rate_date
      , x_conversion_type  => lv_po_currency_rate_type
      , x_max_roll_days    => 5
      , x_denominator      => ln_denominator_rate
      , x_numerator        => ln_numerator_rate
      , x_rate             => ln_currency_rate
      );
    END IF;

    xn_conversion_rate := ln_currency_rate;

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)
  EXCEPTION
    WHEN OTHERS
    THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  END Get_Currency_Convertion_Rate;

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Tax_Amount_Info                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a given tax id and tax amount
  --
  --  PARAMETERS:
  --      In: pn_tax_id            IN   NUMBER               tax identifier
  --          pn_tax_amount        IN   NUMBER               tax amount
  --          pn_conver_rate       IN   NUMBER DEFAULT 1     converstion rate between different currency
  --          pn_rounding_factor   IN   NUMBER DEFAULT NULL  rounding factor
  --          x_excl_tax_amount    OUT  NUMBER               exclusive tax amount
  --          x_excl_nr_tax_amount OUT  NUMBER               exclusive non recoverable tax amount
  --          pn_trx_rec_flag      IN   VARCHAR2             The modvat flat in tax transaction level
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           10-FEB-2009   Eric Ma  created
  --==========================================================================

  PROCEDURE  Get_Tax_Amount_Info
  ( pn_tax_id             IN NUMBER
  , pn_tax_amount         IN NUMBER
  , pn_conver_rate        IN NUMBER DEFAULT 1
  , pn_rounding_factor    IN NUMBER DEFAULT NULL
  , xn_excl_tax_amount    OUT NOCOPY NUMBER
  , xn_excl_nr_tax_amount OUT NOCOPY NUMBER
  , pn_trx_rec_flag        IN VARCHAR2 DEFAULT 'N'  -- add by Xiao Lv for MADVAT flag
  )
  IS

  CURSOR get_jai_cmn_taxes_all_cur
  IS
  SELECT
    NVL(inclusive_tax_flag,'N')
  , NVL(mod_cr_percentage,0)
  , NVL(rounding_factor,0)
  FROM
    jai_cmn_taxes_all
  WHERE tax_id = pn_tax_id;


  ln_nr_tax_amount      NUMBER;
  lv_incl_tax_flag      jai_cmn_taxes_all.inclusive_tax_flag%TYPE;
  ln_nr_mod_cr_percent  jai_cmn_taxes_all.MOD_CR_PERCENTAGE%TYPE;
  ln_mod_cr_percent     jai_cmn_taxes_all.MOD_CR_PERCENTAGE%TYPE;
  ln_rounding_factor    jai_cmn_taxes_all.rounding_factor%TYPE;

  lv_procedure_name     VARCHAR2(40):='Get_Tax_Amount_Info';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    OPEN  get_jai_cmn_taxes_all_cur;
    FETCH get_jai_cmn_taxes_all_cur
    INTO
      lv_incl_tax_flag
    , ln_mod_cr_percent
    , ln_rounding_factor;
    CLOSE get_jai_cmn_taxes_all_cur;

    --dbms_output.put_line ( '-------Get_Tax_Amount_Info-------');
    --dbms_output.put_line ( 'lv_incl_tax_flag    ='||lv_incl_tax_flag);
    --dbms_output.put_line ( 'ln_mod_cr_percent ='||ln_mod_cr_percent);
    --dbms_output.put_line ( 'ln_rounding_factor    ='||ln_rounding_factor);


    --dbms_output.put_line ( 'pn_tax_id          ='||pn_tax_id);
    --dbms_output.put_line ( 'pn_tax_amount      ='||pn_tax_amount);
    --dbms_output.put_line ( 'pn_conver_rate     ='||pn_conver_rate);
    --dbms_output.put_line ( 'pn_rounding_factor ='||pn_rounding_factor);
    --dbms_output.put_line ( 'pn_trx_rec_flag    ='||pn_trx_rec_flag);

    IF (lv_incl_tax_flag ='Y')--inclusive tax
    THEN
      xn_excl_tax_amount    := 0;
      xn_excl_nr_tax_amount := 0;
    ELSE --exclusive tax
      IF (pn_trx_rec_flag = 'Y')
      THEN
        ln_nr_mod_cr_percent  := (100-ln_mod_cr_percent)/100;
      ELSE
        ln_nr_mod_cr_percent  := 1;
      END IF; -- (pn_trx_rec_flag)

      ln_rounding_factor    := NVL(pn_rounding_factor,ln_rounding_factor);
      ln_nr_tax_amount      := pn_tax_amount * ln_nr_mod_cr_percent * pn_conver_rate;
      ln_nr_tax_amount      := ROUND(ln_nr_tax_amount,ln_rounding_factor);
    --dbms_output.put_line ( 'ln_nr_tax_amount    ='||ln_nr_tax_amount);
      xn_excl_nr_tax_amount  := ln_nr_tax_amount;
      xn_excl_tax_amount     := ROUND(pn_tax_amount* pn_conver_rate,ln_rounding_factor);
    END IF;

    --dbms_output.put_line ( 'x_excl_nr_tax_amount ='||x_excl_nr_tax_amount);
    --dbms_output.put_line ( 'x_excl_tax_amount    ='||x_excl_tax_amount);

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)
  EXCEPTION
    WHEN OTHERS
    THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      RAISE;
  END Get_Tax_Amount_Info;

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Jai_Tax_Amount                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a PO,PR or a RELEASE
  --
  --  PARAMETERS:
  --      In: pv_document_type         IN VARCHAR2,                       document type  : requisition,po,release
  --          pn_document_id           IN NUMBER,                         document_id    : req header id,po header id
  --          pn_release_num           IN NUMBER DEFAULT NULL,            release nmuber : for release,it receive release number
  --          xn_excl_tax_amount      OUT NOCOPY NUMBER,                  exclusive tax amount for the document
  --          xn_excl_nr_tax_amount   OUT NOCOPY NUMBER                   exclusive non recoverable tax amount for the document
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           10-FEB-2009   Eric Ma  created
  --           25-MAR-2009   Xiao Lv  modified
  --==========================================================================


  PROCEDURE Get_Jai_Tax_Amount
  ( pv_document_type       IN VARCHAR2,
    pn_document_id         IN NUMBER,
    pn_requisition_line_id IN NUMBER DEFAULT NULL, --add by Xiao Lv
    xn_excl_tax_amount    OUT NOCOPY NUMBER,
    xn_excl_nr_tax_amount OUT NOCOPY NUMBER
  )
  IS
  ln_tax_id                 NUMBER;
  ln_tax_amount             NUMBER;
  ln_excl_tax_amount        NUMBER :=0;
  ln_excl_nr_tax_amount     NUMBER :=0;
  ln_total_tax_amount       NUMBER :=0;
  ln_total_nr_tax_amount    NUMBER :=0;
  ln_currency_rate          NUMBER;
  ln_req_line_id            JAI_PO_REQ_LINE_TAXES.requisition_line_id%TYPE;
  lv_req_tax_currency       JAI_PO_REQ_LINE_TAXES.currency%TYPE;
  lv_po_tax_currency        JAI_PO_TAXES.currency%TYPE;
  lv_rel_tax_currency       JAI_PO_TAXES.currency%TYPE;
  lv_modvat_flag            VARCHAR2(1); --add by Xiao Lv for IL po notification on Mar-25-2009
  ln_po_header_id           PO_RELEASES_ALL.PO_HEADER_ID%TYPE;

  CURSOR Get_Req_tax_Cur
  IS
  SELECT
    tax_id
  , NVL(tax_amount,0)
  , currency
  , requisition_line_id
  , NVL(modvat_flag,'N') --add by Xiao Lv for IL po notification on Mar-25-2009
  FROM
    JAI_PO_REQ_LINE_TAXES
  WHERE REQUISITION_HEADER_ID = pn_document_id
    AND REQUISITION_LINE_ID   = NVL(pn_requisition_line_id, REQUISITION_LINE_ID); --add by Xiao


  CURSOR Get_Po_tax_Cur
  IS
  SELECT
    tax_id
  , NVL(tax_amount, 0)
  , currency
  , NVL(modvat_flag,'N') --add by Xiao Lv for IL po notification on Mar-25-2009
  FROM
    JAI_PO_TAXES
  WHERE PO_HEADER_ID = pn_document_id;


  CURSOR Get_Rel_tax_Cur
  IS
  SELECT
    JPT.tax_id
  , NVL(JPT.tax_amount,0)
  , JPT.currency
  , NVL(JPT.modvat_flag,'N') --add by Xiao Lv for IL po notification on Mar-25-2009
  FROM
    PO_LINE_LOCATIONS_ALL  PLLA
  , JAI_PO_TAXES JPT
  WHERE PLLA.LINE_LOCATION_ID = JPT.LINE_LOCATION_ID
    AND PLLA.PO_RELEASE_ID   = pn_document_id;


  CURSOR Get_Po_Header_Id_Cur
  IS
  SELECT
    POA.PO_HEADER_ID
  FROM
    PO_RELEASES_ALL POA
  WHERE POA.PO_RELEASE_ID = pn_document_id;


  lv_procedure_name     VARCHAR2(40) := 'Get_Jai_Tax_Amount';
  ln_dbg_level          NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER       := FND_LOG.LEVEL_PROCEDURE;

  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    IF pv_document_type= JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
    THEN
      --calculate requsition tax
      OPEN Get_Req_tax_Cur;
      LOOP
        FETCH Get_Req_tax_Cur
         INTO ln_tax_id
            , ln_tax_amount
            , lv_req_tax_currency
            , ln_req_line_id
            , lv_modvat_flag;
        EXIT WHEN Get_Req_tax_Cur%NOTFOUND;

       --dbms_output.put_line ( '-------Get_JAI_Tax_Amount-------');
       --dbms_output.put_line ( 'ln_tax_id             ='||ln_tax_id);
       --dbms_output.put_line ( 'ln_tax_amount         ='||ln_tax_amount);
       --dbms_output.put_line ( 'lv_req_tax_currency   ='||lv_req_tax_currency);
       --dbms_output.put_line ( 'ln_req_line_id        ='||ln_req_line_id);
       --dbms_output.put_line ( 'lv_modvat_flag        ='||lv_modvat_flag);

        Get_Req_Curr_Conv_Rate ( pn_req_header_id    => pn_document_id
                               , pn_req_line_id      => ln_req_line_id
                               , pv_tax_currency     => lv_req_tax_currency
                               , xn_conversion_rate  => ln_currency_rate
                               );
       --dbms_output.put_line ( 'ln_currency_rate        ='||ln_currency_rate);

        Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                            , pn_tax_amount         =>ln_tax_amount
                            , pn_conver_rate        =>ln_currency_rate
                            , xn_excl_tax_amount    =>ln_excl_tax_amount
                            , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                            , pn_trx_rec_flag       =>lv_modvat_flag -- add by Xiao Lv on Mar-25-2009
                            );

         ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
         ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;
       --dbms_output.put_line ( 'ln_total_tax_amount       ='||ln_total_tax_amount);
       --dbms_output.put_line ( 'ln_total_nr_tax_amount    ='||ln_total_nr_tax_amount);
      END LOOP;

      CLOSE Get_Req_tax_Cur;
    ELSIF pv_document_type= JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
    THEN
      --calculate PO tax
      OPEN Get_Po_tax_Cur;
      LOOP
        FETCH Get_Po_tax_Cur

        INTO
          ln_tax_id
        , ln_tax_amount
        , lv_po_tax_currency
        , lv_modvat_flag;
        EXIT WHEN Get_Po_tax_Cur%NOTFOUND;

        Get_Currency_Convertion_Rate ( pn_document_id     => pn_document_id
                                     , pv_tax_currency    => lv_po_tax_currency
                                     , xn_conversion_rate => ln_currency_rate
                                     );

        Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                            , pn_tax_amount         =>ln_tax_amount
                            , pn_conver_rate        =>ln_currency_rate
                            , xn_excl_tax_amount    =>ln_excl_tax_amount
                            , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                            , pn_trx_rec_flag       =>lv_modvat_flag -- add by Xiao Lv on Mar-25-2009
                            );

        ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
        ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;

       --dbms_output.put_line ( 'ln_total_tax_amount       ='||ln_total_tax_amount);
       --dbms_output.put_line ( 'ln_total_nr_tax_amount    ='||ln_total_nr_tax_amount);
      END LOOP;

      CLOSE Get_Po_tax_Cur;
    ELSIF pv_document_type= JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
    THEN
      --Get po header id
      OPEN  Get_Po_Header_Id_Cur;
      FETCH Get_Po_Header_Id_Cur
       INTO ln_po_header_id;
      CLOSE Get_Po_Header_Id_Cur;

      --calculate Release tax
      OPEN Get_Rel_tax_Cur;
      LOOP
        FETCH Get_Rel_tax_Cur
        INTO
          ln_tax_id
        , ln_tax_amount
        , lv_rel_tax_currency
        , lv_modvat_flag;
        EXIT  WHEN Get_Rel_tax_Cur%NOTFOUND;

         Get_Currency_Convertion_Rate ( pn_document_id     => ln_po_header_id
                                      , pv_tax_currency    => lv_rel_tax_currency
                                      , xn_conversion_rate => ln_currency_rate
                                      );


         Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                             , pn_tax_amount         =>ln_tax_amount
                             , pn_conver_rate        =>ln_currency_rate
                             , xn_excl_tax_amount    =>ln_excl_tax_amount
                             , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                             , pn_trx_rec_flag       =>lv_modvat_flag -- add by Xiao Lv on Mar-25-2009
                             );

         ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
         ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;
       --dbms_output.put_line ( 'ln_total_tax_amount       ='||ln_total_tax_amount);
       --dbms_output.put_line ( 'ln_total_nr_tax_amount    ='||ln_total_nr_tax_amount);
      END LOOP;

      CLOSE Get_Rel_tax_Cur;
    END IF;--(p_document_type=JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE)

    --set the values to output parameters
    xn_excl_tax_amount    := NVL(ln_total_tax_amount,0);
    xn_excl_nr_tax_amount := NVL(ln_total_nr_tax_amount,0);


    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)

  EXCEPTION
    WHEN OTHERS
    THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      RAISE;
  END Get_Jai_Tax_Amount;

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Tax_Region                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to return the tax region code
  --
  --  PARAMETERS:
  --      In: pv_document_type      IN   VARCHAR2     document type
  --          pn_document_id        IN   NUMBER       document header id
  --          pn_org_id             IN   NUMBER       organization id
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================

  FUNCTION Get_Tax_Region
  ( pv_document_type      IN VARCHAR2   DEFAULT NULL
  , pn_document_id        IN NUMBER     DEFAULT NULL
  , pn_org_id             IN NUMBER     DEFAULT NULL
  ) RETURN VARCHAR2
  IS
  ln_org_id             NUMBER := pn_org_id;
  lv_procedure_name     VARCHAR2(40):='Get_Tax_Region';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    --if org id is not availabe, get the org id by the parameter of document type and
    -- document header id
    IF ( ln_org_id IS NULL
         AND (pv_document_type IS NOT NULL
              AND pn_document_id  IS NOT NULL
             )
       )
    THEN
      PO_REQAPPROVAL_INIT1.get_multiorg_context
      ( document_type => pv_document_type
      , document_id   => pn_document_id
      , x_orgid       => ln_org_id
      );
    END IF;

    --Check if indian localization is enabled or not by the org id
    IF (jai_cmn_utils_pkg.check_jai_exists
         ( p_calling_object     => GV_MODULE_PREFIX ||'.' || lv_procedure_name
         , p_org_id             => ln_org_id
         )
       )
    THEN
      --logging for debug
      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING( ln_proc_level
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                      , 'Exit procedure'
                      );
      END IF; -- (ln_proc_level>=ln_dbg_level)

      RETURN 'JAI';
    ELSE
      --logging for debug
      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING( ln_proc_level
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                      , 'Exit procedure'
                      );
      END IF; -- (ln_proc_level>=ln_dbg_level)

      RETURN NULL;
    END IF;--(jai_cmn_utils_pkg.check_jai_exists)
  EXCEPTION
  WHEN OTHERS
  THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
  END Get_Tax_Region;


  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Jai_New_Tax_Amount                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a PO,PR or a RELEASE
  --
  --  PARAMETERS:
  --      In: pv_document_type         IN VARCHAR2,                       document type  : requisition,po,release
  --          pn_document_id           IN NUMBER,                         document_id    : req header id,po header id
  --          pn_release_num           IN NUMBER DEFAULT NULL,            release nmuber : for release,it receive release number
  --          xn_excl_tax_amount      OUT NOCOPY NUMBER,                  exclusive tax amount for the document
  --          xn_excl_nr_tax_amount   OUT NOCOPY NUMBER                   exclusive non recoverable tax amount for the document
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           7-Apr-2009   Xiao Lv  created
  --==========================================================================


  PROCEDURE Get_Jai_New_Tax_Amount
  ( pv_document_type         IN VARCHAR2,
    pn_document_id           IN NUMBER,
    pn_chg_request_group_id  IN NUMBER,
    xn_excl_tax_amount       OUT NOCOPY NUMBER,
    xn_excl_nr_tax_amount    OUT NOCOPY NUMBER
  )
  IS
  ln_tax_id                   NUMBER;
  ln_tax_amount               NUMBER;
  ln_excl_tax_amount          NUMBER :=0; --exclusive tax amount for a tax line
  ln_excl_nr_tax_amount       NUMBER :=0; --exclusive nr tax amount for a tax line
  ln_total_tax_amount         NUMBER :=0; --tax lines amount summary  for a req line
  ln_total_nr_tax_amount      NUMBER :=0; --tax lines amount summary of nr tax for a req line

  ln_new_tax_amount           NUMBER :=0; --new tax amount for a req line
  ln_new_nr_tax_amount        NUMBER :=0; --new nr tax amount for a req line
  ln_new_total_tax_amount     NUMBER :=0; --total new tax amount for a req
  ln_new_total_nr_tax_amount  NUMBER :=0; --total new nr tax amount for a req

  ln_currency_rate            NUMBER;
  ln_req_line_id              JAI_PO_REQ_LINE_TAXES.requisition_line_id%TYPE;
  lv_req_tax_currency         JAI_PO_REQ_LINE_TAXES.currency%TYPE;
  lv_modvat_flag              VARCHAR2(1); --add by Xiao Lv for IL po notification on Mar-25-2009
  lv_adhoc_flag               VARCHAR2(1); --add by Xiao Lv for adhoc tax flag.
  ln_total_adhoc_tax_amount   NUMBER :=0;
  ln_old_quantity             NUMBER;
  ln_new_quantity             NUMBER;


  CURSOR Get_Req_tax_Cur
  IS
  SELECT
    jprlt.tax_id
  , jprlt.tax_amount
  , jprlt.currency
  , NVL(jprlt.modvat_flag,'N')
  , NVL(jcta.adhoc_flag, 'N')
  FROM
    JAI_PO_REQ_LINE_TAXES jprlt
  , JAI_CMN_TAXES_ALL     jcta
  WHERE jcta.tax_id = jprlt.tax_id
    AND jprlt.requisition_line_id   = ln_req_line_id
    AND jprlt.REQUISITION_HEADER_ID = pn_document_id;

  CURSOR Get_New_Old_Quantity_Cur
  IS
  SELECT
    document_line_id
  , NVL(old_quantity,1)
  , NVL(new_quantity,0)
  FROM
    po_change_requests
  WHERE document_header_id = pn_document_id
    and request_level='LINE'
    and change_request_group_id =pn_chg_request_group_id;

  lv_procedure_name     VARCHAR2(40) := 'Get_Jai_New_Tax_Amount';
  ln_dbg_level          NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER       := FND_LOG.LEVEL_PROCEDURE;

  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    IF pv_document_type= JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
    THEN
      OPEN Get_New_Old_Quantity_Cur;
      LOOP
        FETCH Get_New_Old_Quantity_Cur
         INTO ln_req_line_id
            , ln_old_quantity
            , ln_new_quantity;
        EXIT WHEN Get_New_Old_Quantity_Cur%NOTFOUND;

        --dbms_output.put_line('ln_req_line_id: '||ln_req_line_id);
        --dbms_output.put_line('ln_old_quantity: '||ln_old_quantity);
        --dbms_output.put_line('ln_new_quantity: '||ln_new_quantity);

        ln_total_tax_amount    :=0;
        ln_total_nr_tax_amount :=0;
        ln_total_adhoc_tax_amount :=0;

        OPEN Get_Req_tax_Cur;
        LOOP
          FETCH Get_Req_tax_Cur
           INTO ln_tax_id
              , ln_tax_amount
              , lv_req_tax_currency
              , lv_modvat_flag
              , lv_adhoc_flag;

             --dbms_output.put_line('ln_tax_id: '||ln_tax_id);
             --dbms_output.put_line('ln_tax_amount: '||ln_tax_amount);
             --dbms_output.put_line('lv_req_tax_currency: '||lv_req_tax_currency);
             --dbms_output.put_line('lv_modvat_flag: '||lv_modvat_flag);
             --dbms_output.put_line('lv_adhoc_flag: '||lv_adhoc_flag);
          EXIT WHEN Get_Req_tax_Cur%NOTFOUND;

          Get_Req_Curr_Conv_Rate ( pn_req_header_id    => pn_document_id
                                 , pn_req_line_id      => ln_req_line_id
                                 , pv_tax_currency     => lv_req_tax_currency
                                 , xn_conversion_rate  => ln_currency_rate
                                 );

             --dbms_output.put_line('ln_currency_rate: '||ln_currency_rate);

          Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                              , pn_tax_amount         =>ln_tax_amount
                              , pn_conver_rate        =>ln_currency_rate
                              , xn_excl_tax_amount    =>ln_excl_tax_amount
                              , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                              , pn_trx_rec_flag       =>lv_modvat_flag
                              );
--dbms_output.put_line('ln_excl_tax_amount: '||ln_excl_tax_amount);
--dbms_output.put_line('ln_excl_nr_tax_amount: '||ln_excl_nr_tax_amount);

           ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
           ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;

           IF( lv_adhoc_flag = 'Y') THEN
             ln_total_adhoc_tax_amount := ln_total_adhoc_tax_amount + ln_tax_amount;
           END IF;

        END LOOP;

        CLOSE Get_Req_tax_Cur;


    --dbms_output.put_line('ln_total_tax_amount: '||ln_total_tax_amount);
    --dbms_output.put_line('ln_total_nr_tax_amount: '||ln_total_nr_tax_amount);
    --dbms_output.put_line('ln_total_adhoc_tax_amount: '||ln_total_adhoc_tax_amount);



        --calculate new tax
        ln_new_tax_amount := (ln_total_tax_amount - ln_total_adhoc_tax_amount)
                         * ln_new_quantity/ln_old_quantity + ln_total_adhoc_tax_amount;


        ln_new_nr_tax_amount := (ln_total_nr_tax_amount- ln_total_adhoc_tax_amount)
                         * ln_new_quantity/ln_old_quantity + ln_total_adhoc_tax_amount;

    --dbms_output.put_line('ln_new_tax_amount: '||ln_new_tax_amount);
    --dbms_output.put_line('ln_new_nr_tax_amount: '||ln_new_nr_tax_amount);

        --calculate new tax total
        ln_new_total_tax_amount    := ln_new_tax_amount    + ln_new_total_tax_amount;
        ln_new_total_nr_tax_amount := ln_new_nr_tax_amount + ln_new_total_nr_tax_amount;
      END LOOP;

      CLOSE Get_New_Old_Quantity_Cur;
    END IF;--(p_document_type=JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE)

    --set the values to output parameters
    xn_excl_tax_amount    := NVL(ln_new_total_tax_amount,0);
    xn_excl_nr_tax_amount := NVL(ln_new_total_nr_tax_amount,0);


    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; -- (ln_proc_level>=ln_dbg_level)

  EXCEPTION
    WHEN OTHERS
    THEN
      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                      , Sqlcode||Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      RAISE;
  END Get_Jai_New_Tax_Amount;

 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Req_Tax_Disp                     Public
  --
  --  DESCRIPTION:
  --    Return the formatted non-recoverable tax for display
  --
  --  PARAMETERS:
  --      In: pn_jai_excl_nr_tax      IN   NUMBER        non recoverable tax amount
  --          pv_total_tax_dsp        IN   VARCHAR2      total tax amount for display
  --          pv_currency_code        IN   VARCHAR2      currency code used for formating
  --          pv_currency_mask        IN   VARCHAR       formatted mask used by fnd_currency function
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           8-Apr-2009   Eric Ma  created
  --==========================================================================
  FUNCTION Get_Jai_Req_Tax_Disp
  ( pn_jai_excl_nr_tax IN NUMBER
  , pv_total_tax_dsp   IN VARCHAR2
  , pv_currency_code   IN VARCHAR2
  , pv_currency_mask   IN VARCHAR2
  ) RETURN VARCHAR2
  IS
  lv_jai_excl_nr_tax_disp  VARCHAR2(32000);
  lv_amount_for_tax_disp   VARCHAR2(32000);
  lv_procedure_name     VARCHAR2(40):='Get_Jai_Req_Tax_Disp';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    lv_jai_excl_nr_tax_disp := TO_CHAR(pn_jai_excl_nr_tax,FND_CURRENCY.GET_FORMAT_MASK(pv_currency_code, pv_currency_mask));
    lv_amount_for_tax_disp := lv_jai_excl_nr_tax_disp ||' '|| pv_currency_code ||' (Total Tax: ' || pv_total_tax_dsp ||')';

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level
    RETURN lv_amount_for_tax_disp;
  EXCEPTION
  WHEN OTHERS
  THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                  , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
  END Get_Jai_Req_Tax_Disp;

 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Tax_Disp                     Public
  --
  --  DESCRIPTION:
  --    Return the formatted tax amount for display
  --
  --  PARAMETERS:
  --      In: pn_tax_amount           IN   NUMBER        tax amount
  --          pv_currency_code        IN   VARCHAR2      currency code used for formating
  --          pv_currency_mask        IN   VARCHAR       formatted mask used by fnd_currency function
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           8-Apr-2009   Eric Ma  created
  --==========================================================================
  FUNCTION Get_Jai_Tax_Disp
  ( pn_tax_amount IN NUMBER
  , pv_currency_code   IN VARCHAR2
  , pv_currency_mask   IN VARCHAR2
  ) RETURN VARCHAR2
  IS
  lv_amount_for_tax_disp   VARCHAR2(32000);
  lv_procedure_name     VARCHAR2(40):='Get_Jai_Tax_Disp';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level
    lv_amount_for_tax_disp := TO_CHAR(pn_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(pv_currency_code,pv_currency_mask));

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level
    RETURN lv_amount_for_tax_disp;
  EXCEPTION
  WHEN OTHERS
  THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                  , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
  END Get_Jai_Tax_Disp;

--==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Open_Form_command                     Public
  --
  --  DESCRIPTION:
  --    Return the open form command for each document type
  --
  --  PARAMETERS:
  --      In: pv_document_type        IN   VARCHAR2      document type
  --  DESIGN REFERENCES:
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Eric Ma  created
  --==========================================================================

  Function Get_Jai_Open_Form_Command( pv_document_type VARCHAR2 )
  RETURN VARCHAR2
  IS
  lv_open_form VARCHAR2 (32000);
  lv_procedure_name     VARCHAR2(40):='Get_Jai_Open_Form_command';
  ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    IF (pv_document_type= JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE)
    THEN
      --Requistion

      --Modified by Eric on 2009-Aug-02 for bug 8744317,begin
      ------------------------------------------------------------------------------
      lv_open_form := 'JAINREQN_FUN:REQUISITION_HEADER_ID=' || '&' ||'DOCUMENT_ID'||
                      ' P_MODE=MODIFY' ||                      -- replace "MODIFY" with MODIFY
                      ' JAINREQN_CALLING_FORM=POXSTNOT';       -- replace "POXSTNOT" with POXSTNOT
      ------------------------------------------------------------------------------
      --Modified by Eric on 2009-Aug-02 for bug 8744317,end


    ELSIF (pv_document_type= JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE)
    THEN
      --PO,PA

      --Modified by Eric on 2009-Aug-02 for bug 8744317,begin
      ------------------------------------------------------------------------------
      lv_open_form := 'JAINPO_FUN:PO_HEADER_ID=' || '&' || 'DOCUMENT_ID' ||
                      ' ACCESS_LEVEL_CODE=MODIFY' ||           -- replace "MODIFY" with MODIFY
                      ' JAINPO_CALLING_FORM=POXSTNOT';         -- replace "POXSTNOT" with POXSTNOT
      ------------------------------------------------------------------------------
      --Modified by Eric on 2009-Aug-02 for bug 8744317,end

    ELSIF (pv_document_type= JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE)
    THEN
      --Release

      --Modified by Eric on 2009-Aug-02 for bug 8744317,begin
      ------------------------------------------------------------------------------
      lv_open_form := 'JAINPORL_FUN:PO_RELEASE_ID=' || '&' || 'DOCUMENT_ID' ||
                      ' ACCESS_LEVEL_CODE=MODIFY' ||           -- replace "MODIFY" with MODIFY
                      ' JAINPORL_CALLING_FORM=POXSTNOT';       -- replace "POXSTNOT" with POXSTNOT
      ------------------------------------------------------------------------------
      --Modified by Eric on 2009-Aug-02 for bug 8744317,end
    END IF;

    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                    , 'Exit procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

    RETURN lv_open_form;
  EXCEPTION
  WHEN OTHERS
  THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
  END Get_Jai_Open_Form_Command;



 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Poreq_Tax                     Public
  --
  --  DESCRIPTION:
  --    get po requisition tax
  --
  --  PARAMETERS:
  --      In: pv_document_type          IN   VARCHAR2      po type
  --          pn_document_id            IN   NUMBER        req header id,po header id,po release id
  --          pn_release_num            IN   NUMBER        release num
  --          pn_line_id                IN   NUMBER        po line id
  --          pn_line_location_id       IN   NUMBER        po line location id
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Xiao Lv  created
  --==========================================================================

  FUNCTION Get_Poreq_Tax
  ( pv_document_type       IN VARCHAR2
  , pn_document_id         IN NUMBER
  , pn_release_num         IN NUMBER DEFAULT NULL
  , pn_line_id             IN NUMBER DEFAULT NULL
  , pn_line_location_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER
  IS
    ln_tax_id                 NUMBER;
    ln_tax_amount             NUMBER;
    ln_excl_tax_amount        NUMBER;
    ln_excl_nr_tax_amount     NUMBER;
    ln_total_tax_amount       NUMBER :=0;
    ln_total_nr_tax_amount    NUMBER :=0;
    ln_currency_rate          NUMBER;
    ln_req_line_id            JAI_PO_REQ_LINE_TAXES.requisition_line_id%TYPE;
    lv_req_tax_currency       JAI_PO_REQ_LINE_TAXES.currency%TYPE;
    lv_po_tax_currency        JAI_PO_TAXES.currency%TYPE;
    lv_rel_tax_currency       JAI_PO_TAXES.currency%TYPE;
    lv_modvat_flag    VARCHAR2(1);


    CURSOR Get_Req_tax_Cur
    IS
    SELECT
      tax_id
    , tax_amount
    , currency
    , requisition_line_id
    , modvat_flag
    FROM
      JAI_PO_REQ_LINE_TAXES
    WHERE REQUISITION_HEADER_ID = pn_document_id
  AND requisition_line_id = NVL(pn_line_id, requisition_line_id);


    CURSOR Get_Po_tax_Cur
    IS
    SELECT
      tax_id
    , tax_amount
    , currency
    , modvat_flag
    FROM
      JAI_PO_TAXES
    WHERE PO_HEADER_ID = pn_document_id
  AND po_line_id = NVL(pn_line_id, po_line_id)
  And line_location_id = NVL(pn_line_location_id, line_location_id);


    CURSOR Get_Rel_tax_Cur
    IS
    SELECT
      JPT.tax_id
    , JPT.tax_amount
    , JPT.currency
    , JPT.modvat_flag
    FROM
      PO_RELEASES_ALL POA
    , PO_LINE_LOCATIONS_ALL  PLLA
    , JAI_PO_TAXES JPT
    WHERE   PLLA.LINE_LOCATION_ID = JPT.LINE_LOCATION_ID
      AND   POA.PO_HEADER_ID  = PLLA.PO_HEADER_ID
      AND   POA.PO_RELEASE_ID = PLLA.PO_RELEASE_ID
      AND   POA.RELEASE_NUM   = pn_release_num
      AND   POA.PO_HEADER_ID  = pn_document_id
      AND   PLLA.LINE_LOCATION_ID = pn_line_location_id ;

    lv_procedure_name     VARCHAR2(40):='Get_Poreq_Tax';
    ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;

    BEGIN
      --logging for debug
      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING( ln_proc_level
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                      , 'Enter procedure'
                      );
      END IF; --l_proc_level>=l_dbg_level



      IF pv_document_type= JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
      THEN
        OPEN Get_Req_tax_Cur;
        LOOP
          FETCH Get_Req_tax_Cur
           INTO ln_tax_id,ln_tax_amount,lv_req_tax_currency,ln_req_line_id, lv_modvat_flag;
          EXIT  WHEN Get_Req_tax_Cur%NOTFOUND;

          Get_Req_Curr_Conv_Rate ( pn_req_header_id    => pn_document_id
                                           , pn_req_line_id      => ln_req_line_id
                                           , pv_tax_currency     =>lv_req_tax_currency
                                           , xn_conversion_rate  => ln_currency_rate
                                           );
--dbms_output.put_line('***********************');
--dbms_output.put_line('ln_curreny_rate: ' || ln_currency_rate);


          Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                              , pn_tax_amount         =>ln_tax_amount
                              , pn_conver_rate        =>ln_currency_rate
                              , xn_excl_tax_amount    =>ln_excl_tax_amount
                              , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                              , pn_trx_rec_flag         => lv_modvat_flag
                              );
--dbms_output.put_line('ln_tax_id: ' || ln_tax_id);
--dbms_output.put_line('ln_tax_amount: ' || ln_tax_amount);
--dbms_output.put_line('ln_total_tax_amount: ' || ln_total_tax_amount);

           ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
           ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;
        END LOOP;

        CLOSE Get_Req_tax_Cur;
      ELSIF pv_document_type= JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
      THEN


        OPEN Get_Po_tax_Cur;
        LOOP
          FETCH Get_Po_tax_Cur
          INTO  ln_tax_id,ln_tax_amount,lv_po_tax_currency, lv_modvat_flag;
          EXIT WHEN Get_Po_tax_Cur%NOTFOUND;

          Get_Currency_Convertion_Rate ( pn_document_id     => pn_document_id
                                       , pv_tax_currency    => lv_po_tax_currency
                                       , xn_conversion_rate => ln_currency_rate
                                       );

          Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                              , pn_tax_amount         =>ln_tax_amount
                              , pn_conver_rate        =>ln_currency_rate
                              , xn_excl_tax_amount    =>ln_excl_tax_amount
                              , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
                               , pn_trx_rec_flag        => lv_modvat_flag
                              );


          ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
          ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;

         --dbms_output.put_line ( 'ln_total_tax_amount       ='||ln_total_tax_amount);
         --dbms_output.put_line ( 'ln_total_nr_tax_amount    ='||ln_total_nr_tax_amount);
        END LOOP;

        CLOSE Get_Po_tax_Cur;
      ELSIF pv_document_type= JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
      THEN
        OPEN Get_Rel_tax_Cur;
        LOOP
          FETCH Get_Rel_tax_Cur
           INTO ln_tax_id,ln_tax_amount,lv_rel_tax_currency, lv_modvat_flag;
          EXIT  WHEN Get_Rel_tax_Cur%NOTFOUND;

           Get_Currency_Convertion_Rate ( pn_document_id     => pn_document_id
                                        , pv_tax_currency    => lv_rel_tax_currency
                                        , xn_conversion_rate => ln_currency_rate
                                        );

           Get_Tax_Amount_Info ( pn_tax_id             =>ln_tax_id
                               , pn_tax_amount         =>ln_tax_amount
                               , pn_conver_rate        =>ln_currency_rate
                               , xn_excl_tax_amount    =>ln_excl_tax_amount
                               , xn_excl_nr_tax_amount =>ln_excl_nr_tax_amount
            , pn_trx_rec_flag         => lv_modvat_flag
                               );

           ln_total_tax_amount    :=  ln_total_tax_amount    + ln_excl_tax_amount;
           ln_total_nr_tax_amount :=  ln_total_nr_tax_amount + ln_excl_nr_tax_amount;
        END LOOP;
        CLOSE Get_Rel_tax_Cur;
      END IF;--(p_document_type=JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE)

      --logging for debug
      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING( ln_proc_level
                      , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                      , 'Exit procedure'
                      );
      END IF; -- (ln_proc_level>=ln_dbg_level)

        RETURN  ln_total_tax_amount;

    EXCEPTION
      WHEN OTHERS
      THEN
        IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                        , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                        , Sqlcode||Sqlerrm);
        END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        RAISE;
    END Get_Poreq_Tax;



 --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Populate_Session_GT                     Public
  --
  --  DESCRIPTION:
  --    Populate_session_gt will insert IL tax amount into session table
  --
  --  PARAMETERS:
  --      In: p_document_id          IN   NUMBER        req header id,po header id,po release id
  --          p_document_type        IN   VARCHAR2      po type
  --          p_document_subtype     IN   VARCHAR2
  --          x_session_gt_key       IN   NUMBER
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Xiao Lv  created
  --==========================================================================

  PROCEDURE Populate_Session_GT(
     p_document_id         IN     NUMBER
  ,  p_document_type       IN     VARCHAR2
  ,  p_document_subtype    IN     VARCHAR2
  ,  x_session_gt_key      IN     NUMBER
  )
  IS
     d_progress VARCHAR2(30);

  BEGIN

  IF ( p_document_type = JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE )
  THEN
    INSERT
      INTO PO_SESSION_GT(
           key
         , num1
         , num2
         , num3
         , num4
         , num5
         , num6
         , char1
         , char2
         )
    SELECT x_session_gt_key
         , GET_POREQ_TAX( JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
                        , poh.po_header_id
                        , NULL
                        , pol.po_line_id
                        , poll.line_location_id)
            * nvl(pod.rate,1)

         , NULL
         , pod.code_combination_id
         , poll.ship_to_location_id + 0
         , pol.item_id
         , pol.category_id
         , DECODE(nvl(pol.cancel_flag, 'N')
              , 'N'
              , NVL(poll.cancel_flag, 'N')
              , pol.cancel_flag)
         , DECODE(nvl(pol.closed_code, 'OPEN')
              , 'OPEN'
              , NVL(poll.closed_code, 'OPEN')
              , pol.closed_code)
      FROM po_headers        poh
         , po_lines          pol
         , po_line_locations poll
         , po_distributions  pod
     WHERE poh.po_header_id = p_document_id
       AND pol.po_header_id = poh.po_header_id
       AND poll.po_line_id = pol.po_line_id
       AND poll.shipment_type <> 'PREPAYMENT' -- <Complex Work R12>
       AND pod.line_location_id = poll.line_location_id
       AND ((poh.type_lookup_code <> 'PLANNED') OR
          ((poh.type_lookup_code = 'PLANNED') AND
           (poll.shipment_type = 'PLANNED')))
       AND pod.distribution_num=1;

  ELSIF (p_document_type = JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE)
   THEN
      d_progress := 30;

      INSERT
        INTO PO_SESSION_GT(
             key
           , num1
           , num2
           , num3
           , num4
           , num5
           , num6
           , char1
           , char2
           )
      SELECT x_session_gt_key
           , GET_POREQ_TAX( JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
                       , porl.requisition_header_id
                       , NULL
                       , porl.requisition_line_id
                       , NULL )
           , NULL
           , pord.code_combination_id
           , porl.deliver_to_location_id
           , porl.item_id
           , porl.category_id
           , 'N'
           , 'OPEN'                      -- Bug 4610058
        FROM po_req_distributions pord
           , po_requisition_lines porl
       WHERE porl.requisition_header_id = p_document_id
         AND porl.requisition_line_id = pord.requisition_line_id
         AND NVL(porl.cancel_flag, 'N') = 'N'
         AND NVL(porl.modified_by_agent_flag, 'N') = 'N'
         AND pord.distribution_num=1;

    ELSIF (p_document_type = JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE)
    THEN
      d_progress := 40;
      INSERT
        INTO PO_SESSION_GT(
             key
           , num1
           , num2
            , num3
           , num4
           , num5
           , num6
           , char1
           , char2
           )
      SELECT x_session_gt_key
           , GET_POREQ_TAX( JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
                         , pod.po_header_id
                         , poa.release_num
                         , pol.po_line_id
                         , poll.line_location_id
                         )
              * NVL(pod.rate,1)
           , NULL
           , pod.code_combination_id
           , poll.ship_to_location_id
           , pol.item_id
           , pol.category_id
           , DECODE(nvl(pol.cancel_flag, 'N'), 'N', NVL(poll.cancel_flag, 'N'), pol.cancel_flag)
           , DECODE(nvl(pol.closed_code, 'OPEN'), 'OPEN', NVL(poll.closed_code, 'OPEN'), pol.closed_code)
        FROM po_distributions pod
           , po_line_locations poll
           , po_lines pol
           , po_releases_all poa
       WHERE poa.po_release_id =  p_document_id
         AND poll.po_release_id = p_document_id
         AND poll.po_line_id = pol.po_line_id
         AND pod.line_location_id = poll.line_location_id
         AND pod.distribution_num = 1;
    END IF;

 END Populate_Session_GT;

END JAI_PO_WF_UTIL_PUB;

/
