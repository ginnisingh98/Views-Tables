--------------------------------------------------------
--  DDL for Package Body JAI_RETRO_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RETRO_PRC_PKG" AS
--$Header: jai_retro_prc.plb 120.7.12010000.2 2010/04/15 11:05:26 boboli ship $
--|+======================================================================+
--| Copyright (c) 2007 Oracle Corporation Redwood Shores, California, USA |
--|                       All rights reserved.                            |
--+=======================================================================+
--| FILENAME                                                              |
--|     JAI_RETRO_PRC_PKG.plb                                             |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    This package offer funcitons to process the retro receipt          |
--|                                                                       |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Process_Retroactive_Update                             |
--|      PROCEDURE Do_Cenvat_Claim                                        |
--|      PROCEDURE Do_Vat_Claim                                           |
--|      PROCEDURE Do_Unclaim                                             |
--|      PROCEDURE Get_Tax_Amount_Breakup                                 |
--|      PROCEDURE Get_Vat_CenVat_Amount                                  |
--|      PROCEDURE Print_Shipment_Detail                                  |
--|      PROCEDURE Get_Tot_NonRe_Tax_Amount                               |
--|                                                                       |
--|      FUNCTION  Get_Recoverable_Amount                                 |
--|      FUNCTION  Get_NonRecoverable_Amount                              |
--|                                                                       |
--| HISTORY                                                               |
--|     2008/01/08 Eric Ma       Created                                  |
--|     2008/02/01 Eric Ma  Add log,change Do_Uncalim and Process_Retroactive_Update for bug #6788048
--|     2008/03/28 Eric Ma  reversal the debit/credit and correct the cenvat
--|                         tax amount for the bug 6918495 and bug 6914567
--|
--|     2008/04/08 Eric Ma  fail to fully fix the bug 6918495 as the amount is still in half as expected
--|                         open an new bug 6955045 and the modification is for the bug
--|
--|     2008/04/10 Eric Ma  changed the code for bug#6957519/6958938/6968839 ,incorrect accouting entries generated in DELIVERY
--|
--|     2008/04/15 Eric Ma  changed the code for bug#6968733 on Apr 15,2008,Vat tax claim is not correct after retro
--|
--|     2008/04/21 Jia Li  changed the code for bug#6988208 on Apr 21,2008,
--|                        Recoverable amt on Vat tax claim header is not correct after retro .
--|
--|     2010/04/14 Bo Li   For bug9305067
--|                        Change the parameters for the procedure insert_vat_repository_entry .
--|                                                                       |
--+======================================================================*/
--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Recoverable_Amount                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get the recoverable amount for a given tax id
--
--
--  PARAMETERS:
--      In: pn_tax_id          NUMBER               tax identifier
--          pn_tax_amount      NUMBER               tax amount
--          pn_conver_rate     NUMBER DEFAULT 1     converstion rate between different currency
--          pn_rounding_factor NUMBER DEFAULT NULL  rounding factor
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
FUNCTION Get_Recoverable_Amount
( pn_tax_id          NUMBER
, pn_tax_amount      NUMBER
, pn_conver_rate     NUMBER DEFAULT 1
, pn_rounding_factor NUMBER DEFAULT NULL
)
RETURN NUMBER
IS

CURSOR get_jai_cmn_taxes_all_cur
IS
SELECT
  mod_cr_percentage
, rounding_factor
FROM
  jai_cmn_taxes_all
WHERE tax_id = pn_tax_id;

ln_re_tax_amount   NUMBER;
ln_mod_cr_percent  jai_cmn_taxes_all.MOD_CR_PERCENTAGE%TYPE;
ln_rounding_factor jai_cmn_taxes_all.rounding_factor%TYPE;
lv_procedure_name             VARCHAR2(40):='Get_Recoverable_Amount';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;
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
    ln_mod_cr_percent
  , ln_rounding_factor;
  CLOSE get_jai_cmn_taxes_all_cur;

  ln_mod_cr_percent  := NVL(ln_mod_cr_percent,0)/100;
  ln_rounding_factor := NVL(NVL(pn_rounding_factor,ln_rounding_factor),0);
  ln_re_tax_amount   := pn_tax_amount * ln_mod_cr_percent *pn_conver_rate;
  ln_re_tax_amount   := ROUND(ln_re_tax_amount,ln_rounding_factor);


  IF (ln_proc_level >= ln_dbg_level)
  THEN

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.pn_tax_amount'
                  , 'pn_tax_amount :' || pn_tax_amount
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.ln_mod_cr_percent'
                  , 'ln_mod_cr_percent :' || ln_mod_cr_percent
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.pn_conver_rate'
                  , 'pn_conver_rate :' || pn_conver_rate
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'ln_re_tax_amount' || ln_re_tax_amount
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level


  RETURN NVL(ln_re_tax_amount,0) ;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_Recoverable_Amount;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_NonRecoverable_Amount                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get the non recoverable tax amount for a given tax id
--
--
--  PARAMETERS:
--      In: pn_tax_id          NUMBER               tax identifier
--          pn_tax_amount      NUMBER               tax amount
--          pn_conver_rate     NUMBER DEFAULT 1     converstion rate between different currency
--          pn_rounding_factor NUMBER DEFAULT NULL  rounding factor
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================

FUNCTION Get_NonRecoverable_Amount
( pn_tax_id          NUMBER
, pn_tax_amount      NUMBER
, pn_conver_rate     NUMBER DEFAULT 1
, pn_rounding_factor NUMBER DEFAULT NULL
)
RETURN NUMBER
IS

CURSOR get_jai_cmn_taxes_all_cur
IS
SELECT
  mod_cr_percentage
, rounding_factor
FROM
  jai_cmn_taxes_all
WHERE tax_id = pn_tax_id;

ln_nr_tax_amount      NUMBER;
ln_nr_mod_cr_percent  jai_cmn_taxes_all.MOD_CR_PERCENTAGE%TYPE;
ln_mod_cr_percent     jai_cmn_taxes_all.MOD_CR_PERCENTAGE%TYPE;
ln_rounding_factor    jai_cmn_taxes_all.rounding_factor%TYPE;
lv_procedure_name     VARCHAR2(40):='Get_NonRecoverable_Amount';
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
    ln_mod_cr_percent
  , ln_rounding_factor;
  CLOSE get_jai_cmn_taxes_all_cur;

  ln_nr_mod_cr_percent  := (100-NVL(ln_mod_cr_percent,0))/100;
  ln_rounding_factor    := NVL(NVL(pn_rounding_factor,ln_rounding_factor),0);
  ln_nr_tax_amount      := pn_tax_amount * ln_nr_mod_cr_percent *pn_conver_rate;
  ln_nr_tax_amount      := ROUND(ln_nr_tax_amount,ln_rounding_factor);

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

  RETURN NVL(ln_nr_tax_amount,0) ;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_NonRecoverable_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Tot_NonRe_Tax_Amount                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get the total origianl/modified/difference of
--    non recoverable tax amount for a given line_change_id
--
--
--  PARAMETERS:
--      In: pn_line_change_id  NUMBER               tax identifier
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--           10-Apr-2008   Eric Ma  Updated the procedure for the bug 6957519/6958938/6968839
--==========================================================================

PROCEDURE Get_Tot_NonRe_Tax_Amount
( pn_line_change_id             IN NUMBER
, xn_org_nonre_tax_amount       OUT NOCOPY NUMBER
, xn_modif_nonre_tax_amount     OUT NOCOPY NUMBER
, xn_diff_nonre_tax_amount      OUT NOCOPY NUMBER
)
IS
CURSOR get_tax_info_cur
IS
SELECT
  original_tax_amount  --eric added for bug 6957519/6958938/6968839
, modified_tax_amount
, tax_id
FROM
  jai_retro_tax_changes
WHERE line_change_id = pn_line_change_id;

ln_tot_org_nr_tax_amt   NUMBER :=0;   --eric added for bug 6957519/6958938/6968839  on Apr 10,2008
ln_tot_modif_nr_tax_amt NUMBER :=0;   --eric added for bug 6957519/6958938/6968839  on Apr 10,2008
ln_tot_diff_nr_tax_amt  NUMBER :=0;   --eric added for bug 6957519/6958938/6968839  on Apr 10,2008

lv_procedure_name     VARCHAR2(40):='Get_Tot_NonRe_Tax_Amount';
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
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'pn_line_change_id :'|| pn_line_change_id
                  );
  END IF; --l_proc_level>=l_dbg_level

  --eric modified for bug 6957519/6958938/6968839  on Apr 10,2008, beign
  -----------------------------------------------------------------------------------------------------
  FOR tax_info_rec IN get_tax_info_cur
  LOOP
    ln_tot_modif_nr_tax_amt :=  ln_tot_modif_nr_tax_amt +
                           Get_NonRecoverable_Amount( pn_tax_id      => tax_info_rec.tax_id
                                                    , pn_tax_amount  => tax_info_rec.modified_tax_amount
                                                    );

    ln_tot_org_nr_tax_amt :=  ln_tot_org_nr_tax_amt +
                           Get_NonRecoverable_Amount( pn_tax_id      => tax_info_rec.tax_id
                                                    , pn_tax_amount  => tax_info_rec.original_tax_amount
                                                    );
--  FND_FILE.PUT_LINE(fnd_file.log,'  Tax id is : '||  tax_info_rec.tax_id||'Accumulated Tax is: '||ln_tot_nr_tax_amt);
  END LOOP;--tax_info_rec IN get_tax_info_cur

  ln_tot_diff_nr_tax_amt  := ln_tot_modif_nr_tax_amt - ln_tot_org_nr_tax_amt;

  xn_org_nonre_tax_amount    := ln_tot_org_nr_tax_amt   ;
  xn_modif_nonre_tax_amount  := ln_tot_modif_nr_tax_amt ;
  xn_diff_nonre_tax_amount   := ln_tot_diff_nr_tax_amt  ;

  -----------------------------------------------------------------------------------------------------
  --eric modified for bug 6957519/6958938/6968839  on Apr 10,2008, end

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'ln_tot_modif_nr_tax_amt :'|| ln_tot_modif_nr_tax_amt
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'ln_tot_org_nr_tax_amt :'|| ln_tot_org_nr_tax_amt
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'ln_tot_diff_nr_tax_amt :'|| ln_tot_diff_nr_tax_amt
                  );

    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

  --eric deleted for bug 6957519/6958938/6968839  on Apr 10,2008,begin
  ---------------------------------------------
  --RETURN ln_tot_nr_tax_amt;
  ---------------------------------------------
  --eric deleted for bug 6957519/6958938/6968839  on Apr 10,2008,end
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_Tot_NonRe_Tax_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Vat_CenVat_Amount                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get total recoverable modified/original amount of  vat/cenvat tax
--    for a given line_change_id. The difference between modified and original tax amount will also
--    be returned by the procedure
--
--  PARAMETERS:
--      In: pn_line_change_id  NUMBER               jai retro line change identifier
--
--      OUT:
--          xn_re_vat_amount            NUMBER     original recoverable vat tax amount
--          xn_modif_re_vat_amount      NUMBER     modified recoverable vat tax amount
--          xn_diff_re_vat_amount       NUMBER     difference between  original/ modified recoverable vat tax amount
--          xn_re_cenvat_amount         NUMBER     original recoverable excise tax amount
--          xn_modif_re_cenvat_amount   NUMBER     modified recoverable excise tax amount
--          xn_diff_re_cenvat_amount    NUMBER     difference between  original/ modified recoverable vat tax amount
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
PROCEDURE Get_Vat_CenVat_Amount
( pn_line_change_id         IN NUMBER
, xn_re_vat_amount          OUT NOCOPY NUMBER
, xn_modif_re_vat_amount    OUT NOCOPY NUMBER
, xn_diff_re_vat_amount     OUT NOCOPY NUMBER
, xn_re_cenvat_amount       OUT NOCOPY NUMBER
, xn_modif_re_cenvat_amount OUT NOCOPY NUMBER
, xn_diff_re_cenvat_amount  OUT NOCOPY NUMBER
)
IS

CURSOR get_cenvat_tax_info_cur
IS
SELECT
  original_tax_amount
, modified_tax_amount
, tax_id
FROM
  jai_retro_tax_changes
WHERE line_change_id = pn_line_change_id
  AND tax_type IN ( JAI_CONSTANTS.tax_type_excise
                  , JAI_CONSTANTS.tax_type_exc_additional
                  , JAI_CONSTANTS.tax_type_exc_other
                  , JAI_CONSTANTS.tax_type_exc_edu_cess
                  , JAI_CONSTANTS.tax_type_sh_exc_edu_cess
                  )
  AND recoverable_flag ='Y';

CURSOR get_vat_tax_info_cur
IS
SELECT
  original_tax_amount
, modified_tax_amount
, tax_id
FROM
  jai_retro_tax_changes jrtc
WHERE EXISTS(  SELECT
                 'X'
               FROM
                 JAI_RGM_DEFINITIONS jr
               , JAI_RGM_REGISTRATIONS jrr
               WHERE jr.regime_id          = jrr.regime_id
                 AND jr.regime_code        = jai_constants.vat_regime
                 AND jrr.registration_type = jai_constants.regn_type_tax_types
                 AND jrtc.tax_type         = jrr.attribute_code
            )
  AND recoverable_flag ='Y'
  AND line_change_id   = pn_line_change_id;

ln_tot_re_cenvat_amt       NUMBER :=0;
ln_modif_tot_re_cenvat_amt NUMBER :=0;
ln_tot_re_vat_amt          NUMBER :=0;
ln_modif_tot_re_vat_amt    NUMBER :=0;

lv_procedure_name     VARCHAR2(40):='Get_Vat_CenVat_Amount';
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

  FOR cenvat_tax_info_rec IN get_cenvat_tax_info_cur
  LOOP
    ln_tot_re_cenvat_amt := ln_tot_re_cenvat_amt +
                             Get_Recoverable_Amount ( pn_tax_id    =>cenvat_tax_info_rec.tax_id
                                                    , pn_tax_amount =>cenvat_tax_info_rec.original_tax_amount
                                                    );

    ln_modif_tot_re_cenvat_amt :=  ln_modif_tot_re_cenvat_amt +
                             Get_Recoverable_Amount ( pn_tax_id    =>cenvat_tax_info_rec.tax_id
                                                    , pn_tax_amount =>cenvat_tax_info_rec.modified_tax_amount
                                                    );
  END LOOP;
  xn_re_cenvat_amount       := ln_tot_re_cenvat_amt ;
  xn_modif_re_cenvat_amount := ln_modif_tot_re_cenvat_amt;
  xn_diff_re_cenvat_amount  := ln_modif_tot_re_cenvat_amt - ln_tot_re_cenvat_amt;

  FOR vat_tax_info_rec IN get_vat_tax_info_cur
  LOOP
    ln_tot_re_vat_amt := ln_tot_re_vat_amt +
                             Get_Recoverable_Amount ( pn_tax_id    =>vat_tax_info_rec.tax_id
                                                    , pn_tax_amount =>vat_tax_info_rec.original_tax_amount
                                                    );

    ln_modif_tot_re_vat_amt :=  ln_modif_tot_re_vat_amt +
                             Get_Recoverable_Amount ( pn_tax_id    =>vat_tax_info_rec.tax_id
                                                    , pn_tax_amount =>vat_tax_info_rec.modified_tax_amount
                                                    );
  END LOOP;
  xn_re_vat_amount          := ln_tot_re_vat_amt  ;
  xn_modif_re_vat_amount    := ln_modif_tot_re_vat_amt;
  xn_diff_re_vat_amount     := ln_modif_tot_re_vat_amt - ln_tot_re_vat_amt;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_Vat_CenVat_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Tax_Amount_Breakup                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get breakup the excise tax amount for different tax types
--
--
--  PARAMETERS:
--      In: pn_shipment_line_id  NUMBER               tax identifier
--          pn_transaction_id    NUMBER               transaction identifier
--          pn_line_change_id    NUMBER      identifier of jai_retro_line_changes
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================

PROCEDURE Get_Tax_Amount_Breakup
( pn_shipment_line_id  IN         NUMBER
, pn_transaction_id    IN         NUMBER
, pn_curr_conv_rate    IN         NUMBER
, pr_tax               OUT NOCOPY JAI_RCV_EXCISE_PROCESSING_PKG.tax_breakup
, pv_breakup_type      IN         VARCHAR2
, pn_line_change_id    IN         NUMBER
)
IS
ln_curr_conv            NUMBER;
ln_mod_problem_amt      NUMBER;
ln_nonmod_problem_amt   NUMBER;
ln_apportion_factor     NUMBER;

lv_procedure_name     VARCHAR2(40):='Get_Tax_Amount_Breakup';
ln_dbg_level          NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level         NUMBER:=FND_LOG.LEVEL_PROCEDURE;
BEGIN
  --This procedure returns excise amounts as per transaction quantity
  --If p_breakup_type is RG23D, then total tax amount should be added to excise amount instead of taking
  --mod_cr_percentage into consideration
ln_mod_problem_amt      := 0;
ln_nonmod_problem_amt   := 0;
ln_apportion_factor   := jai_rcv_trx_processing_pkg.get_apportion_factor(pn_transaction_id);
FOR tax_rec IN (SELECT
                  jrtc.tax_type
                , (jrtc.modified_tax_amount - jrtc.original_tax_amount)                tax_amount
                , nvl(jrtc.recoverable_flag, 'N')                                      modvat_flag
                , nvl(jrtc.currency_code, jai_rcv_trx_processing_pkg.gv_func_curr)     currency
                , nvl(decode(pv_breakup_type, 'RG23D', 100, jtc.mod_cr_percentage), 0) mod_cr_percentage
                , nvl(jtc.rounding_factor, 0)                                          rnd
                 FROM
                   jai_retro_tax_changes jrtc
                 , jai_cmn_taxes_all jtc
                 , jai_retro_line_changes jrlc
                 WHERE jrlc.doc_line_id = pn_shipment_line_id
                   AND jrtc.line_change_id = jrlc.line_change_id
                   AND jrlc.doc_type = 'RECEIPT'
                   AND jtc.tax_id = jrtc.tax_id
                   AND jrlc.line_change_id = pn_line_change_id
                 )
LOOP
  IF tax_rec.currency <> jai_rcv_trx_processing_pkg.gv_func_curr
  THEN
    ln_curr_conv := NVL(pn_curr_conv_rate, 1);
  ELSE
    ln_curr_conv := 1;
  END IF;

  IF pv_breakup_type = 'RG23D'
  THEN    -- trading case
    IF upper(tax_rec.tax_type) = JAI_CONSTANTS.excise_regime
    THEN
      pr_tax.basic_excise   := pr_tax.basic_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF upper(tax_rec.tax_type) = JAI_CONSTANTS.tax_type_exc_additional
    THEN
      pr_tax.addl_excise    := pr_tax.addl_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF upper(tax_rec.tax_type) = JAI_CONSTANTS.tax_type_exc_other
    THEN
      pr_tax.other_excise   := pr_tax.other_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = JAI_CONSTANTS.tax_type_cvd
    THEN
      pr_tax.cvd      := pr_tax.cvd + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = jai_constants.tax_type_exc_edu_cess
    THEN
      pr_tax.excise_edu_cess   := pr_tax.excise_edu_cess + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = jai_constants.tax_type_cvd_edu_cess
    THEN
      pr_tax.cvd_edu_cess   := pr_tax.cvd_edu_cess + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_cvd_edu_cess
    THEN
      pr_tax.sh_cvd_edu_cess  := nvl(pr_tax.sh_cvd_edu_cess,0) + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_exc_edu_cess
    THEN
      pr_tax.sh_exc_edu_cess  := nvl(pr_tax.sh_exc_edu_cess,0) + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSIF tax_rec.tax_type = jai_constants.tax_type_add_cvd
    THEN
      pr_tax.addl_cvd  := pr_tax.addl_cvd + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSE
      pr_tax.non_cenvat  := pr_tax.non_cenvat + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    END IF;
  ELSE  -- manufacturing case
    IF tax_rec.modvat_flag = 'Y' AND
         upper(tax_rec.tax_type) IN (JAI_CONSTANTS.excise_regime, JAI_CONSTANTS.tax_type_exc_additional,
                               JAI_CONSTANTS.tax_type_exc_other, JAI_CONSTANTS.tax_type_cvd,
             JAI_CONSTANTS.tax_type_add_cvd,
             jai_constants.tax_type_exc_edu_cess,
             jai_constants.tax_type_cvd_edu_cess,
             jai_constants.tax_type_sh_cvd_edu_cess,
             jai_constants.tax_type_sh_exc_edu_cess)
    THEN
      IF upper(tax_rec.tax_type) = JAI_CONSTANTS.excise_regime
      THEN
        pr_tax.basic_excise := pr_tax.basic_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF upper(tax_rec.tax_type) = JAI_CONSTANTS.tax_type_exc_additional
      THEN
        pr_tax.addl_excise := pr_tax.addl_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF upper(tax_rec.tax_type) = JAI_CONSTANTS.tax_type_exc_other
      THEN
        pr_tax.other_excise := pr_tax.other_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF tax_rec.tax_type IN (JAI_CONSTANTS.tax_type_cvd)
      THEN
        pr_tax.cvd := pr_tax.cvd
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF tax_rec.tax_type IN ( jai_constants.tax_type_add_cvd)
      THEN
        pr_tax.addl_cvd := pr_tax.addl_cvd
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF tax_rec.tax_type = jai_constants.tax_type_exc_edu_cess
      THEN
        pr_tax.excise_edu_cess   := pr_tax.excise_edu_cess +
                + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF tax_rec.tax_type = jai_constants.tax_type_cvd_edu_cess
      THEN
        pr_tax.cvd_edu_cess   := pr_tax.cvd_edu_cess
                + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_exc_edu_cess
      THEN
        pr_tax.sh_exc_edu_cess   := nvl(pr_tax.sh_exc_edu_cess,0)+
					              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
					            + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
		  ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_cvd_edu_cess
      THEN
			  pr_tax.sh_cvd_edu_cess   := nvl(pr_tax.sh_cvd_edu_cess,0)+
											+ round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        pr_tax.non_cenvat := pr_tax.non_cenvat
										+ round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      ELSE
        ln_mod_problem_amt := ln_mod_problem_amt
              + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
      END IF;
    ELSIF tax_rec.modvat_flag = 'N' and tax_rec.tax_type NOT IN (JAI_CONSTANTS.tax_type_tds, JAI_CONSTANTS.tax_type_modvat_recovery)
    THEN
      pr_tax.non_cenvat := pr_tax.non_cenvat
            + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    ELSE
      ln_nonmod_problem_amt := ln_nonmod_problem_amt
            + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
    END IF;
  END IF;
END LOOP;
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_Tax_Amount_Breakup;

--==========================================================================
--  Function NAME:
--
--    Get_Jai_Rcv_Trans_Record                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get the jai transaction record for a
--    given transaction id
--
--
--  PARAMETERS:
--      In: pn_transaction_id  NUMBER               transaction identifier
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
Function Get_Jai_Rcv_Trans_Record
( pn_transaction_id jai_rcv_transactions.transaction_id%TYPE
)
RETURN  jai_rcv_transactions%ROWTYPE
IS

  CURSOR get_jai_rcv_transactions_cur
  IS
  SELECT
  *
  FROM
    jai_rcv_transactions
  WHERE transaction_id   = pn_transaction_id;


  jai_rcv_transactions_rec     jai_rcv_transactions%ROWTYPE;

lv_procedure_name     VARCHAR2(40):='Get_Jai_Rcv_Trans_Record';
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

  OPEN  get_jai_rcv_transactions_cur;
  FETCH get_jai_rcv_transactions_cur
   INTO jai_rcv_transactions_rec;
  CLOSE get_jai_rcv_transactions_cur;

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)
  RETURN jai_rcv_transactions_rec;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Get_Jai_Rcv_Trans_Record;

--==========================================================================
--  Function NAME:
--
--    Get_Jai_Rcv_Lines_Record                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to get the jai_rcv_lines record for a
--    given transaction id
--
--
--  PARAMETERS:
--      In: pn_transaction_id  NUMBER               transaction identifier
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
Function Get_Jai_Rcv_Lines_Record
( pn_transaction_id jai_rcv_transactions.transaction_id%TYPE
)
RETURN  jai_rcv_lines%ROWTYPE
IS

  CURSOR get_jai_rcv_lines_cur
  IS
  SELECT
  *
  FROM
    jai_rcv_lines
  WHERE transaction_id   = pn_transaction_id;

  jai_rcv_lines_rec     jai_rcv_lines%ROWTYPE;

  lv_procedure_name     VARCHAR2(40):='Get_Jai_Rcv_Trans_Record';
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

  OPEN  get_jai_rcv_lines_cur;
  FETCH get_jai_rcv_lines_cur
   INTO jai_rcv_lines_rec;
  CLOSE get_jai_rcv_lines_cur;

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

 RETURN jai_rcv_lines_rec;
EXCEPTION
  WHEN OTHERS
  THEN
    RAISE;
END Get_Jai_Rcv_Lines_Record;

--==========================================================================
--  PROCEDURE NAME:
--
--    Do_Unclaim                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to unclaim the tax on receipt or processing the
--    costing
--
--
--  PARAMETERS:
--      In:pn_organization_id NUMBER      inventory organization identifier
--         pn_transaction_id  NUMBER      transaction identifier
--         pn_amount          NUMBER      non recoverable amount
--         pn_version_number  NUMBER      receipt version number
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--           01-Feb-2008   Eric Ma  Add log and change  code for bug #6788048
--==========================================================================

PROCEDURE Do_Unclaim
( pn_organization_id IN NUMBER
, pn_transaction_id  IN NUMBER
, pn_amount          IN NUMBER
, pn_version_number  IN NUMBER
)
IS
CURSOR rcv_transactions_cur IS
SELECT
  destination_type_code
, shipment_line_id
FROM rcv_transactions
WHERE transaction_id = pn_transaction_id;


CURSOR get_mtl_parameters_cur IS
SELECT
  primary_cost_method
, expense_account
, purchase_price_var_account
, organization_code
FROM
  mtl_parameters
WHERE
  organization_id = pn_organization_id;

CURSOR get_rcv_parameters_cur IS
SELECT
  retroprice_adj_account_id
, receiving_account_id
FROM
  rcv_parameters
WHERE
  organization_id = pn_organization_id;

lv_primary_cost_method        mtl_parameters.primary_cost_method%TYPE;
lv_destination_type_code      jai_rcv_transactions.destination_type_code%TYPE;
ln_shipment_line_id           jai_rcv_transactions.shipment_line_id%TYPE;
lv_receipt_num                jai_rcv_transactions.receipt_num%TYPE;
ln_expense_account            mtl_parameters.expense_account%TYPE;
lv_process_message            VARCHAR2(500);
lv_process_status             VARCHAR2(500);
lv_code_path                  VARCHAR2(500);
ln_purchase_price_var_account mtl_parameters.purchase_price_var_account%TYPE;
ln_retroprice_adj_account_id  rcv_parameters.retroprice_adj_account_id%TYPE;
func_curr_det_rec             jai_plsql_cache_pkg.func_curr_details;
lv_period_name                gl_periods.period_name%TYPE;
ln_receiving_account_id       rcv_parameters.receiving_account_id%TYPE;
ln_user_id                    NUMBER := fnd_global.user_id;
lv_procedure_name             VARCHAR2(40):='Do_Unclaim';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;
lv_organization_code          mtl_parameters.organization_code%TYPE;/*added by rchandan*/
BEGIN
	--logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  OPEN  get_mtl_parameters_cur;
  FETCH get_mtl_parameters_cur
  INTO
    lv_primary_cost_method
  , ln_expense_account
  , ln_purchase_price_var_account
  , lv_organization_code;
  CLOSE get_mtl_parameters_cur;

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 1');
    FND_FILE.PUT_LINE(fnd_file.log,'lv_primary_cost_method '|| lv_primary_cost_method);
    FND_FILE.PUT_LINE(fnd_file.log,'ln_expense_account '|| ln_expense_account);
    FND_FILE.PUT_LINE(fnd_file.log,'ln_purchase_price_var_account '|| ln_purchase_price_var_account);
    FND_FILE.PUT_LINE(fnd_file.log,'lv_organization_code '|| lv_organization_code);
  END IF; --l_proc_level>=l_dbg_level

  OPEN  get_rcv_parameters_cur;
  FETCH get_rcv_parameters_cur
  INTO
    ln_retroprice_adj_account_id,
    ln_receiving_account_id;
  CLOSE get_rcv_parameters_cur;

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 2');
    FND_FILE.PUT_LINE(fnd_file.log,'ln_retroprice_adj_account_id '|| ln_retroprice_adj_account_id);
    FND_FILE.PUT_LINE(fnd_file.log,'ln_receiving_account_id '|| ln_receiving_account_id);
  END IF; --l_proc_level>=l_dbg_level

  OPEN rcv_transactions_cur;
  FETCH rcv_transactions_cur
  INTO
    lv_destination_type_code
  , ln_shipment_line_id;
  CLOSE rcv_transactions_cur;

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 3');
    FND_FILE.PUT_LINE(fnd_file.log,'lv_destination_type_code '|| lv_destination_type_code);
    FND_FILE.PUT_LINE(fnd_file.log,'ln_shipment_line_id '|| ln_shipment_line_id);
  END IF; --l_proc_level>=l_dbg_level

  IF (lv_destination_type_code = 'EXPENSE')
  THEN -- if the destination_type_code in DELIVER transaction is EXPENSE

    -- Debit the account calling the following procedure
    jai_rcv_accounting_pkg.process_transaction
    ( p_transaction_id       => pn_transaction_id
    , p_acct_type            => 'REGULAR'
    , p_acct_nature          => 'Expense Accounting'
    , p_source_name          => 'Purchasing India'
    , p_category_name        => 'Receiving India'
    , p_code_combination_id  => ln_expense_account
    , p_entered_dr           => pn_amount
    , p_entered_cr           => NULL
    , p_currency_code        => 'INR'
    , p_accounting_date      => SYSDATE
    , p_reference_10         => NULL
    , p_reference_23         => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24         => 'rcv_transactions'
    , p_reference_25         => 'transaction_id'
    , p_reference_26         => to_char(pn_transaction_id)
    , p_destination          => 'G'
    , p_simulate_flag        => 'N'
    , p_codepath             => lv_code_path
    , p_process_message      => lv_process_message
    , p_process_status       => lv_process_status
    , p_reference_name       => 'RETRO CENVAT CLAIMS ' || pn_version_number
    , p_reference_id         => 1
    );

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim accounting returned with error for Expense  : ' || lv_process_message);
    END IF; -- (lv_process_status IN ('X','E'))
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 4');
    END IF; --l_proc_level>=l_dbg_level

    -- Credit the receiving_account_id by calling the following procedure

    jai_rcv_accounting_pkg.process_transaction
    ( p_transaction_id       => pn_transaction_id
    , p_acct_type            => 'REGULAR'
    , p_acct_nature          => 'Expense Accounting'
    , p_source_name          => 'Purchasing India'
    , p_category_name        => 'Receiving India'
    , p_code_combination_id  => ln_receiving_account_id
    , p_entered_dr           => NULL
    , p_entered_cr           => pn_amount
    , p_currency_code        => 'INR'
    , p_accounting_date      => SYSDATE
    , p_reference_10         => NULL
    , p_reference_23         => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24         => 'rcv_transactions'
    , p_reference_25         => 'transaction_id'
    , p_reference_26         => to_char(pn_transaction_id)
    , p_destination          => 'G'
    , p_simulate_flag        => 'N'
    , p_codepath             => lv_code_path
    , p_process_message      => lv_process_message
    , p_process_status       => lv_process_status
    , p_reference_name       => 'RETRO CENVAT CLAIMS ' || pn_version_number
    , p_reference_id         => 2
    );

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim accounting returned with error for Expense  :  ' || lv_process_message);
    END IF; -- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 5');
    END IF; --l_proc_level>=l_dbg_level

  ELSIF (lv_primary_cost_method = 1)
  THEN -- if its Standard Costing

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 6');
    END IF; --l_proc_level>=l_dbg_level

    -- Debit the account by calling
    jai_rcv_accounting_pkg.process_transaction
    (  p_transaction_id         => pn_transaction_id
     , p_acct_type              => 'REGULAR'
     , p_acct_nature            => 'Standard Costing'
     , p_source_name            => 'Inventory India'
     , p_category_name          => 'MTL'
     , p_code_combination_id    => ln_purchase_price_var_account
     , p_entered_dr             => pn_amount
     , p_entered_cr             => NULL
     , p_currency_code          => 'INR'
     , p_accounting_date        => SYSDATE
     , p_reference_10           => NULL
     , p_reference_23           => 'jai_retro_prc_pkg.do_accounting'
     , p_reference_24           => 'rcv_transactions'
     , p_reference_25           => 'transaction_id'
     , p_reference_26           => to_char(pn_transaction_id)
     , p_destination            => 'S'
     , p_simulate_flag          => 'N'
     , p_codepath               => lv_code_path
     , p_process_message        => lv_process_message
     , p_process_status         => lv_process_status
     , p_reference_name         => 'RETRO CENVAT CLAIMS ' || pn_version_number
     , p_reference_id           => 1
     );

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim accounting returned with error for Standard Costing : ' || lv_process_message);
	  END IF;	-- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 7');
    END IF; --l_proc_level>=l_dbg_level

    -- Credit the receiving account by calling
    jai_rcv_accounting_pkg.process_transaction
    ( p_transaction_id         => pn_transaction_id
    , p_acct_type              => 'REGULAR'
    , p_acct_nature            => 'Standard Costing'
    , p_source_name            => 'Inventory India'
    , p_category_name          => 'MTL'
    , p_code_combination_id    => ln_receiving_account_id
    , p_entered_dr             => NULL
    , p_entered_cr             => pn_amount
    , p_currency_code          => 'INR'
    , p_accounting_date        => SYSDATE
    , p_reference_10           => NULL
    , p_reference_23           => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24           => 'rcv_transactions'
    , p_reference_25           => 'transaction_id'
    , p_reference_26           => to_char(pn_transaction_id)
    , p_destination            => 'S'
    , p_simulate_flag          => 'N'
    , p_codepath               => lv_code_path
    , p_process_message        => lv_process_message
    , p_process_status         => lv_process_status
    , p_reference_name         => 'RETRO CENVAT CLAIMS ' || pn_version_number
    , p_reference_id           => 2
    );

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim accounting returned with error for Standard Costing : ' || lv_process_message);
    END IF;	-- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 8');
    END IF; --l_proc_level>=l_dbg_level

  ELSIF (lv_primary_cost_method = 2)
  THEN -- if its Average costing

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 9');
    END IF; --l_proc_level>=l_dbg_level

    -- Get the organization details by calling the following function
    func_curr_det_rec := jai_plsql_cache_pkg.return_sob_curr(p_org_id  =>  pn_organization_id);


    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 10');
    END IF; --l_proc_level>=l_dbg_level

    -- Get the period name using the following query
    SELECT gd.period_name
    INTO lv_period_name
    FROM
      gl_ledgers gle
    , gl_periods gd
    WHERE gle.ledger_id = func_curr_det_rec.ledger_id
      AND gd.period_set_name = gle.period_set_name
    --  AND SYSDATE BETWEEN gd.start_date AND gd.end_date bug #6788048
      --eric changed on Feb 1, 2008 for bug  #6788048 begin
      ---------------------------------------------
      AND SYSDATE >=TRUNC(gd.start_date)
      AND SYSDATE < TRUNC(gd.end_date+1)
      ---------------------------------------------
      --eric changed on Feb 1, 2008 for bug  #6788048 end
      AND gd.adjustment_period_flag = 'N';

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 11');
      FND_FILE.PUT_LINE(fnd_file.log,'lv_period_name '|| lv_period_name);
    END IF; --l_proc_level>=l_dbg_level

    -- Get the receipt_num
    SELECT receipt_num
    INTO lv_receipt_num
    FROM jai_rcv_lines
    WHERE shipment_line_id = ln_shipment_line_id;

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 12');
      FND_FILE.PUT_LINE(fnd_file.log,'lv_receipt_num '|| lv_receipt_num);
    END IF; --l_proc_level>=l_dbg_level

    --  Debit the Retroprice account by calling
    jai_rcv_accounting_pkg.gl_entry
    ( p_organization_id           => pn_organization_id
    , p_organization_code         => func_curr_det_rec.organization_code
    , p_set_of_books_id           => func_curr_det_rec.ledger_id
    , p_credit_amount             => NULL
    , p_debit_amount              => pn_amount
    , p_cc_id                     => ln_retroprice_adj_account_id
    , p_je_source_name            => 'Inventory India'
    , p_je_category_name          => 'MTL'
    , p_created_by                => ln_user_id
    , p_accounting_date           => SYSDATE
    , p_currency_code             => 'INR'
    , p_currency_conversion_date  => NULL
    , p_currency_conversion_type  => NULL
    , p_currency_conversion_rate  => NULL
    , p_reference_10              => 'JAI Retropricing Unclaim Entry for the Receipt Number '||lv_receipt_num ||' for the Organization code '||lv_organization_code
    , p_reference_23              => 'JAI_RETRO_PRC_PKG.Do_Accounting'
    , p_reference_24              => 'rcv_transactions'
    , p_reference_25              => 'transaction_id'
    , p_reference_26              => to_char(pn_transaction_id)
    , p_process_message           => lv_process_message
    , p_process_status            => lv_process_status
    , p_codepath                  => lv_code_path
    );

    --FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 9');

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim GL Entry returned with error for Average Costing : '|| lv_process_message);
    END IF; -- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 13');
    END IF; --l_proc_level>=l_dbg_level

    jai_rcv_journal_pkg.insert_row
    ( p_organization_id          => pn_organization_id
    , p_organization_code  	 => func_curr_det_rec.organization_code
    , p_receipt_num	      	 => lv_receipt_num
    , p_transaction_id           => pn_transaction_id
    , p_transaction_date         => SYSDATE
    , p_shipment_line_id         => ln_shipment_line_id
    , p_acct_type                => 'REGULAR'
    , p_acct_nature              => 'Average Costing'
    , p_source_name              => 'Inventory India'
    , p_category_name            => 'MTL'
    , p_code_combination_id    	 => ln_retroprice_adj_account_id
    , p_entered_dr               => pn_amount
    , p_entered_cr               => NULL
    , p_transaction_type         => 'DELIVER'
    , p_period_name              => lv_period_name
    , p_currency_code            => 'INR'
    , p_currency_conversion_type => NULL
    , p_currency_conversion_date => NULL
    , p_currency_conversion_rate => NULL
    , p_simulate_flag            => 'N'
    , p_process_status           => lv_process_status
    , p_process_message          => lv_process_message
    , p_reference_name           => 'RETRO CENVAT CLAIMS ' || pn_version_number
    , p_reference_id             => 1
    );

    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim Journal Entry returned with error for Average Costing : ' || lv_process_message);
    END IF;	-- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 14');
    END IF; --l_proc_level>=l_dbg_level

    -- Credit the receiving account by calling

    jai_rcv_accounting_pkg.gl_entry
    ( p_organization_id          => pn_organization_id
    , p_organization_code        => func_curr_det_rec.organization_code
    , p_set_of_books_id          => func_curr_det_rec.ledger_id
    , p_credit_amount            => pn_amount
    , p_debit_amount             => NULL
    , p_cc_id                    => ln_receiving_account_id
    , p_je_source_name           => 'Inventory India'
    , p_je_category_name         => 'MTL'
    , p_created_by               => ln_user_id
    , p_accounting_date          => SYSDATE
    , p_currency_code            => 'INR'
    , p_currency_conversion_date => NULL
    , p_currency_conversion_type => NULL
    , p_currency_conversion_rate => NULL
    , p_reference_10             => 'India Localization.....'
    , p_reference_23             => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24             => 'rcv_transactions'
    , p_reference_25             => 'transaction_id'
    , p_reference_26             => to_char(pn_transaction_id)
    , p_process_message          => lv_process_message
    , p_process_status           => lv_process_status
    , p_codepath                 => lv_code_path
    );

    IF (lv_process_status IN ('X','E'))
    THEN
	    raise_application_error(-20120,'Unclaim GL Entry returned with error for Average Costing : ' || lv_process_message);
    END IF;	-- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 15');
    END IF; --l_proc_level>=l_dbg_level

    jai_rcv_journal_pkg.insert_row
    ( p_organization_id	     => pn_organization_id
    , p_organization_code        => func_curr_det_rec.organization_code
    , p_receipt_num              => lv_receipt_num
    , p_transaction_id           => pn_transaction_id
    , p_transaction_date         => SYSDATE
    , p_shipment_line_id         => ln_shipment_line_id
    , p_acct_type                => 'REGULAR'
    , p_acct_nature              => 'Average Costing'
    , p_source_name              => 'Inventory India'
    , p_category_name            => 'MTL'
    , p_code_combination_id      => ln_receiving_account_id
    , p_entered_dr               => NULL
    , p_entered_cr               => pn_amount
    , p_transaction_type         => 'DELIVER'
    , p_period_name              => lv_period_name
    , p_currency_code            => 'INR'
    , p_currency_conversion_type => NULL
    , p_currency_conversion_date => NULL
    , p_currency_conversion_rate => NULL
    , p_simulate_flag            => 'N'
    , p_process_status           => lv_process_status
    , p_process_message          => lv_process_message
    , p_reference_name           => 'RETRO CENVAT CLAIMS ' || pn_version_number
    , p_reference_id             => 2
    );

    --FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 12');
    IF (lv_process_status IN ('X','E'))
    THEN
      raise_application_error(-20120,'Unclaim Journal Entry returned with error for Average Costing : ' || lv_process_message);
    END IF;	-- (lv_process_status IN ('X','E'))

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Unclaim 16');
    END IF; --l_proc_level>=l_dbg_level
  END IF; -- (lv_destination_type_code = 'EXPENSE')

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Do_Unclaim;



--==========================================================================
--  PROCEDURE NAME:
--
--    Do_Accounting                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to processing the accounting related logic
--
--
--  PARAMETERS:
--      In:pn_transaction_id    NUMBER      transaction identifier
--         pn_shipment_line_id  NUMBER      shipemnt line identifier,
--         pn_vat_amount        NUMBER      recoverable vat tax amount
--         xv_vat_action        NUMBER      vat action 'CLAIM' or 'UNCLAIM'
--         pn_cenvat_amount     NUMBER      recoverable vat tax amount
--         xv_cenvat_action     NUMBER      vat action 'CLAIM' or 'UNCLAIM'
--         pn_version_number    NUMBER      receipt version number
--         pn_line_change_id    NUMBER      identifier of jai_retro_line_changes
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
PROCEDURE Do_Accounting
( pn_shipment_line_id IN NUMBER
, pn_transaction_id   IN NUMBER
, pn_cenvat_amount    IN NUMBER
, xv_cenvat_action    IN OUT NOCOPY VARCHAR2
, pn_vat_amount       IN NUMBER
, xv_vat_action       IN OUT NOCOPY VARCHAR2
, pn_non_rec_amount   IN NUMBER
, pn_version_number   IN NUMBER
, pn_line_change_id   IN NUMBER
)
IS

CURSOR Rcv_Trx_Cur
IS
SELECT
  transaction_id
, organization_id
FROM
  Rcv_Transactions
WHERE shipment_line_id = pn_shipment_line_id
  AND transaction_type = 'DELIVER';

ln_tax_diff_tot                      NUMBER;
lv_currency                          Jai_Retro_Tax_Changes.Currency_Code%TYPE;
ln_curr_conv_rate                    Rcv_Transactions.Currency_Conversion_Rate%TYPE;
ln_organization_id                   Rcv_Transactions.Organization_Id%TYPE;
ln_recv_acct_id                      Rcv_Parameters.Receiving_Account_Id%TYPE;
ln_ap_accrual_acc                    Mtl_Parameters.Ap_Accrual_Account%TYPE;
ln_non_rec_amount                    NUMBER;
lv_include_cenvat_in_costing         VARCHAR2(10);

lv_codepath           VARCHAR2(4000);
lv_process_message    VARCHAR2(4000);
lv_process_status     VARCHAR2(4000);

lv_procedure_name             VARCHAR2(40):='Do_Accounting';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;


BEGIN

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  SELECT
    NVL(currency_conversion_rate,1)
  , organization_id
  INTO
    ln_curr_conv_rate
  , ln_organization_id
  FROM
    Rcv_Transactions
  WHERE shipment_line_id = pn_shipment_line_id
    AND transaction_type = 'RECEIVE';

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 1');
    FND_FILE.PUT_LINE(fnd_file.log,'ln_curr_conv_rate '|| ln_curr_conv_rate);
    FND_FILE.PUT_LINE(fnd_file.log,'ln_organization_id '|| ln_organization_id);
  END IF; --l_proc_level>=l_dbg_level

  --Get the total tax difference from jai_retro_tax_changes for the shipment_line_id
  -- Get the difference in INR. Multiply with currency_conversion_rate of rcv_transactions
  -- if the tax is in Non INR currency
  SELECT
    SUM((modified_tax_amount - original_tax_amount) * DECODE(currency_code,'INR',1, ln_curr_conv_rate)) tax_diff_tot
  INTO
    ln_tax_diff_tot
  FROM
    Jai_Retro_Tax_Changes
  WHERE line_change_id = pn_line_change_id ;/*rchandan. removed sub query and replaced with pn_line_change_id*/

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 2');
    FND_FILE.PUT_LINE(fnd_file.log,'ln_tax_diff_tot '|| ln_tax_diff_tot);
  END IF; --l_proc_level>=l_dbg_level


  /* eric deleted for a bug on Jan 22,2008
    IF lv_currency <> 'INR'
    THEN
      ln_tax_diff_tot := ln_tax_diff_tot * ln_curr_conv_rate;
    END IF;
  */

 --FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 2');

  --IF the total difference is NOT EQUAL to ZERO THEN
  IF ln_tax_diff_tot <> 0
  THEN
    --Get the receiving_account_id from rcv_parameters for the current organization id
    SELECT
      receiving_account_id
    INTO
      ln_recv_acct_id
    FROM
      Rcv_Parameters
    WHERE organization_id = ln_organization_id;

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 3');
      FND_FILE.PUT_LINE(fnd_file.log,'ln_recv_acct_id '|| ln_recv_acct_id);
    END IF; --l_proc_level>=l_dbg_level

    --Debit the account by calling the following procedure
    Jai_Rcv_Accounting_Pkg.Process_Transaction
    ( p_transaction_id      => pn_transaction_id
    , p_acct_type           => 'REGULAR'
    , p_acct_nature         => 'Receiving'
    , p_source_name         => 'Purchasing India'
    , p_category_name       => 'Receiving India'
    , p_code_combination_id => ln_recv_acct_id--receiving_account_id
    , p_entered_dr          => ln_tax_diff_tot --ln_amount --Total tax difference in INR
    , p_entered_cr          => NULL
    , p_currency_code       => 'INR'
    , p_accounting_date     => SYSDATE
    , p_reference_10        => NULL
    , p_reference_23        => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24        => 'rcv_transactions'
    , p_reference_25        => 'transaction_id'
    , p_reference_26        => to_char(pn_transaction_id)
    , p_destination         => 'G' --G indicates GL Interface Entries,
    , p_simulate_flag       => 'N'
    , p_codepath            => lv_codepath
    , p_process_message     => lv_process_message -- OUT parameter
    , p_process_status      => lv_process_status  -- OUT parameter
    , p_reference_name      => 'RETRO CENVAT CLAIMS ' ||pn_version_number
    , p_reference_id        => 1
    );
 --FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 3');

    IF lv_process_status IN ('X', 'E')
    THEN
      raise_application_error(-20120,'Receive Accounting Entry retruned with error  : '||lv_process_message);
    END IF;

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 4');
    END IF; --l_proc_level>=l_dbg_level

    --Get the ap_accrual_account from mtl_parameters for the current organization id
    SELECT
      Ap_Accrual_Account
    INTO
      ln_ap_accrual_acc
    FROM
      Mtl_Parameters
    WHERE organization_id = ln_organization_id;

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 5');
      FND_FILE.PUT_LINE(fnd_file.log,'ln_ap_accrual_acc '|| ln_ap_accrual_acc);
    END IF; --l_proc_level>=l_dbg_level

    --Credit the account by calling the following procedure
    Jai_Rcv_Accounting_Pkg.Process_Transaction
    ( p_transaction_id      	=> pn_transaction_id
    , p_acct_type           	=> 'REGULAR'
    , p_acct_nature         	=> 'Receiving'
    , p_source_name         	=> 'Purchasing India'
    , p_category_name       	=> 'Receiving India'
    , p_code_combination_id 	=> ln_ap_accrual_acc --ap_accrual_account
    , p_entered_dr          	=> NULL
    , p_entered_cr          	=> ln_tax_diff_tot --ln_amount --Total tax difference in INR
    , p_currency_code       	=> 'INR'
    , p_accounting_date     	=> SYSDATE
    , p_reference_10        	=> NULL
    , p_reference_23            => 'jai_retro_prc_pkg.do_accounting'
    , p_reference_24            => 'rcv_transactions'
    , p_reference_25            => 'transaction_id'
    , p_reference_26            => to_char(pn_transaction_id)
    , p_destination         	=> 'G' --GL Interface Entries
    , p_simulate_flag       	=> 'N'
    , p_codepath                => lv_codepath
    , p_process_message     	=> lv_process_message -- OUT parameter
    , p_process_status      	=> lv_process_status  -- OUT parameter
    , p_reference_name     	=> 'RETRO CENVAT CLAIMS ' ||pn_version_number
    , p_reference_id        	=> 2
    );

-- FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 4');
    IF lv_process_status IN ('X', 'E')
    THEN
      raise_application_error(-20120,'Receive Accounting Entry retruned with error : '||lv_process_message);
    END IF;

    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 6');
    END IF; --l_proc_level>=l_dbg_level

    ln_non_rec_amount := pn_non_rec_amount;

    --LOOP through the DELIVER transactions for the shipment_line_id from rcv_transactions
    FOR trx_rec IN Rcv_Trx_Cur
    LOOP
      IF pn_cenvat_amount <> 0 --if the recoverable cenvat amount is not zero
      THEN
        --Call the following function to decide if cenvat needs to be included in costing
        lv_include_cenvat_in_costing := Jai_Rcv_Deliver_Rtr_Pkg.Include_Cenvat_In_Costing( p_transaction_id    => trx_rec.transaction_id --DELIEVR transaction id
                                                                                         , p_process_message   => lv_process_message
                                                                                         , p_process_status    => lv_process_status
                                                                                         , p_codepath          => lv_codepath
                                                                                         );

        IF lv_include_cenvat_in_costing = 'Y' OR xv_cenvat_action = 'UNCLAIM' THEN
          FND_FILE.PUT_LINE(fnd_file.log,'    lv_include_cenvat_in_costing : '|| lv_include_cenvat_in_costing);
          xv_cenvat_action   := 'UNCLAIMED'; -- CENVAT is included in Unclaim. do_cenvat_claim is no more called
          ln_non_rec_amount  := ln_non_rec_amount + pn_cenvat_amount; -- include recoverable cenvat in Non recoverable amount
        END IF;

      END IF;

      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 7');
      END IF; --l_proc_level>=l_dbg_level

      IF xv_vat_action = 'UNCLAIM' AND pn_vat_amount <> 0 THEN --If VAT amount exists and VAT action is UNCLAIM
        xv_vat_action   := 'UNCLAIMED'; -- VAT is included in Unclaim. do_vat_claim is no more called
        ln_non_rec_amount  := ln_non_rec_amount + pn_vat_amount; -- include recoverable VAT in Non recoverable amount
      END IF;

      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 8');
      END IF; --l_proc_level>=l_dbg_level

      IF (ln_non_rec_amount <> 0)
      THEN
        --Call the following procedure to do unclaim
        Do_Unclaim( pn_organization_id => trx_rec.organization_id   -- current organization from rcv_transactions or jai_rcv_lines
                  , pn_transaction_id  => trx_rec.transaction_id    -- DELIVER transaction_id
                  , pn_amount          => ln_non_rec_amount         -- Amount to be unclaimed
                  , pn_version_number  => pn_version_number
                  );

        FND_FILE.PUT_LINE(fnd_file.log,'    Do_Unclaim()  Invoked');
      ELSE
      	FND_FILE.PUT_LINE(fnd_file.log,'    Do_Unclaim()  is not Invoked');
      END IF;--(ln_non_rec_amount <> 0)

      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 9');
      END IF; --l_proc_level>=l_dbg_level

      IF xv_cenvat_action = 'UNCLAIMED'
      THEN
        --update jai_retro_line_changes to modify excise_action to 'UNCLAIM'
        UPDATE
          Jai_Retro_Line_Changes
        SET
          Excise_Action = 'UNCLAIM'
        WHERE line_change_id =pn_line_change_id;
      END IF;

      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 10');
      END IF; --l_proc_level>=l_dbg_level

      IF xv_vat_action = 'UNCLAIMED'
      THEN
        --update jai_retro_line_changes to modify vat_action to 'UNCLAIM'
        UPDATE
          Jai_Retro_Line_Changes
        SET
          Vat_Action = 'UNCLAIM'
        WHERE line_change_id = pn_line_change_id;
      END IF;

      IF (ln_proc_level >= ln_dbg_level)
      THEN
        FND_FILE.PUT_LINE(fnd_file.log,'Do_Accounting 11');
      END IF; --l_proc_level>=l_dbg_level
    END LOOP; --FOR trx_rec IN rcv_trx_cur  --DELIVER transactions
  END IF;
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Do_Accounting;

--==========================================================================
--  PROCEDURE NAME:
--
--    Do_Vat_Claim                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to claim the vat tax on receipt
--
--
--  PARAMETERS:
--      In:pn_transaction_id    NUMBER      transaction identifier
--         pn_shipment_line_id  NUMBER      shipemnt line identifier,
--         pn_vat_amount        NUMBER      recoverable vat tax amount
--         pv_supp_vat_inv_no   VARCHAR2    supplementary invoice number
--         pd_supp_vat_inv_date DATE        supplementary invoice date
--         pn_version_number    NUMBER      receipt version number
--         pn_line_change_id    NUMBER      identifier of jai_retro_line_changes
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================

PROCEDURE  Do_Vat_Claim
( pn_transaction_id     IN NUMBER
, pn_shipment_line_id   IN NUMBER
, pn_vat_amount         IN NUMBER
, pv_supp_vat_inv_no    IN VARCHAR2 DEFAULT NULL
, pd_supp_vat_inv_date  IN DATE     DEFAULT NULL
, pn_version_number     IN NUMBER
, pn_line_change_id     IN NUMBER
)
IS
--This procedure is used to CLAIm or UNCLAIM VAT to the extent it got modified
--It does the corresponding accounting as well

jai_rcv_rgm_lines_rec jai_rcv_rgm_lines%ROWTYPE;
rcv_transactions_rec     rcv_transactions%ROWTYPE;
ln_tot_clm_instl_amt        NUMBER;
ln_tot_instl_amt            NUMBER;
ln_installment_cnt          NUMBER;
ln_new_re_tax_amt           NUMBER;
ln_orig_re_tax_amt          NUMBER;
ln_diff_re_tax_amt          NUMBER;
ln_instl_diff               NUMBER;
ln_tax_instl_claimed_cnt    NUMBER;
ln_tax_claimed_diff_amount  NUMBER;
ln_organization_id          NUMBER;
ln_location_id              NUMBER;
ln_receipt_num              NUMBER;
ln_regime_id                NUMBER;
ln_interim_recovery_account NUMBER;
ln_code_combination_id      NUMBER;
ln_repository_id            NUMBER;
lv_reference_10        VARCHAR2 (4000);
lv_reference_23        VARCHAR2 (4000);
lv_reference_24        VARCHAR2 (4000);
lv_reference_25        VARCHAR2 (4000);
lv_reference_26        VARCHAR2 (4000);
lv_process_status      VARCHAR2 (4000);
lv_process_message     VARCHAR2 (4000);
lv_receipt_number      jai_rcv_lines.receipt_num%TYPE;
lv_code_path           VARCHAR2 (4000); --TO BE DONE
--lv_receipt_num         jai_rcv_lines.receipt_num%TYPE;/*rchandan*/

CURSOR get_rcv_transactions_cur
IS
SELECT
*
FROM
  rcv_transactions
WHERE
  transaction_id = pn_transaction_id;

CURSOR jai_rcv_rgm_lines_cur (pn_shipment_line_id NUMBER)
IS
SELECT
*
FROM
  jai_rcv_rgm_lines
WHERE shipment_line_id = pn_shipment_line_id ;

CURSOR jai_rcv_rgm_instl_count_cur
( pn_rcv_rgm_line_id NUMBER
, pn_tax_id          NUMBER DEFAULT NULL --added by eric for bug#6968733 on Apr 15,2008
)
IS
SELECT
  COUNT(*)
FROM
  jai_rcv_rgm_claims
WHERE rcv_rgm_line_id  = pn_rcv_rgm_line_id
  AND tax_id           = NVL(pn_tax_id,tax_id); --added by eric for bug#6968733 on Apr 15,2008


CURSOR jai_rcv_rgm_claimed_count_cur
( pn_rcv_rgm_line_id NUMBER,
  pn_tax_id          NUMBER DEFAULT NULL
)
IS
SELECT
  COUNT(*)
FROM
  jai_rcv_rgm_claims
WHERE rcv_rgm_line_id  = pn_rcv_rgm_line_id
  AND tax_id           = NVL(pn_tax_id,tax_id)
  AND claimed_amount IS NOT NULL;

CURSOR jai_retro_tax_changes_cur
IS
SELECT
*
FROM
  jai_retro_tax_changes jrtc
WHERE EXISTS ( SELECT
                 'X'
               FROM
                 JAI_RGM_DEFINITIONS jr
               , JAI_RGM_REGISTRATIONS jrr
               WHERE jr.regime_id = jrr.regime_id
                 AND jr.regime_code = jai_constants.vat_regime
                 AND jrr.registration_type = jai_constants.regn_type_tax_types
                 AND jrtc.tax_type =jrr.attribute_code
            )
  AND jrtc.recoverable_flag ='Y'
  AND jrtc.line_change_id   = pn_line_change_id;


CURSOR get_claim_schedule_cur ( pn_rcv_rgm_line_id NUMBER)
IS
SELECT
  SUM( a.installment_amount - a.claimed_amount ) claim_amount
, tax_type
, MIN(claim_schedule_id) claim_schedule_id
FROM
  jai_rcv_rgm_claims  A
WHERE rcv_rgm_line_id = pn_rcv_rgm_line_id
  AND claimed_amount IS NOT NULL
 GROUP BY a.tax_type;

CURSOR get_parameters_cur ( pn_rcv_rgm_line_id NUMBER)
IS
SELECT
  jrrl.organization_id
, jrrl.location_id
, jrl.receipt_num
, jrd.regime_id
FROM
  jai_rcv_rgm_lines   jrrl
, jai_rgm_definitions jrd
, jai_rcv_lines       jrl
WHERE jrrl.rcv_rgm_line_id  = pn_rcv_rgm_line_id
  AND jrrl.shipment_line_id = jrl.shipment_line_id
  AND jrrl.regime_code      = jrd.regime_code;

lv_procedure_name             VARCHAR2(40):='Do_Vat_Claim';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;

BEGIN
	--logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level
	--Get the primary_cost_method from mtl_parameters for the organization

  OPEN  get_rcv_transactions_cur;
  FETCH get_rcv_transactions_cur
  INTO
    rcv_transactions_rec ;
  CLOSE get_rcv_transactions_cur;

  -- Get the receipt_num
  SELECT receipt_num
  INTO lv_receipt_number
  FROM jai_rcv_lines
  WHERE shipment_line_id = pn_shipment_line_id;

  --Get the record from jai_rcv_rgm_lines for the current shipment_line_id ( ln_rcv_rgm_line_id )
  OPEN  jai_rcv_rgm_lines_cur (pn_shipment_line_id => pn_shipment_line_id);
  FETCH jai_rcv_rgm_lines_cur
   INTO jai_rcv_rgm_lines_rec;
  CLOSE jai_rcv_rgm_lines_cur;


  --deleted by eric for bug#6968733 on Apr 15,2008,begin
  ----------------------------------------------------------------------
  /*
  --Get the count of installments from jai_rcv_rgm_claims for the rcv_rgm_line_id from the above record(ln_installment_cnt)
  OPEN  jai_rcv_rgm_instl_count_cur
       ( pn_rcv_rgm_line_id =>jai_rcv_rgm_lines_rec.rcv_rgm_line_id)
  FETCH jai_rcv_rgm_instl_count_cur
   INTO ln_installment_cnt;
  CLOSE jai_rcv_rgm_instl_count_cur;
  */

  ----------------------------------------------------------------------
  --deleted by eric for bug#6968733 on Apr 15,2008,end


  --Initialise ln_tot_clm_instl_amt to zero. This is used to calculate the total claimed
  --Initialise ln_tot_instl_amt to zero. This is used to calculate the total installment amount difference
  ln_tot_clm_instl_amt  :=0 ;
  ln_tot_instl_amt      :=0 ;

  --LOOP through jai_retro_tax_changes where recoverable_flag is 'Y' and tax_type is one of tax types attached to VAT regime
  FOR jai_retor_tax_changes_rec IN jai_retro_tax_changes_cur
  LOOP
    -- calculate the recoverable portion of the difference in modified and original tax_amount
    -- Use mod_cr_percentage from jai_cmn_taxes_all
    ln_new_re_tax_amt  := Get_Recoverable_Amount ( pn_tax_id     => jai_retor_tax_changes_rec.tax_id
                                                 , pn_tax_amount => jai_retor_tax_changes_rec.modified_tax_amount
                                                 );
    ln_orig_re_tax_amt := Get_Recoverable_Amount ( pn_tax_id     => jai_retor_tax_changes_rec.tax_id
                                                 , pn_tax_amount => jai_retor_tax_changes_rec.original_tax_amount
                                                 );
    ln_diff_re_tax_amt :=  ln_new_re_tax_amt - ln_orig_re_tax_amt;

    --added by eric for bug#6968733 on Apr 15,2008,begin
    ----------------------------------------------------------------------
    --Get the count of installments from jai_rcv_rgm_claims for the rcv_rgm_line_id from the above record(ln_installment_cnt)
    OPEN  jai_rcv_rgm_instl_count_cur
         ( pn_rcv_rgm_line_id =>jai_rcv_rgm_lines_rec.rcv_rgm_line_id
         , pn_tax_id          => jai_retor_tax_changes_rec.tax_id
         );
    FETCH jai_rcv_rgm_instl_count_cur
     INTO ln_installment_cnt;
    CLOSE jai_rcv_rgm_instl_count_cur;
    ----------------------------------------------------------------------
    --added by eric for bug#6968733 on Apr 15,2008,end


    -- calculate the installment difference amount by doing ln_diff_re_tax_amt / ln_installment_cnt( ln_instl_diff )
    ln_instl_diff := ln_diff_re_tax_amt/ln_installment_cnt;

    --Update jai_rcv_rgm_claims to increment installment amount
    UPDATE jai_rcv_rgm_claims
    SET    installment_amount = installment_amount + ln_instl_diff
    WHERE  rcv_rgm_line_id    = jai_rcv_rgm_lines_rec.rcv_rgm_line_id
      AND  tax_id             = jai_retor_tax_changes_rec.tax_id;


    --get no of installments which are claimed for this tax_id by counting the records for which
    --claimed_amount is populated (ln_instl_claimed_cnt)
    OPEN jai_rcv_rgm_claimed_count_cur
         ( pn_rcv_rgm_line_id => jai_rcv_rgm_lines_rec.rcv_rgm_line_id
         , pn_tax_id          => jai_retor_tax_changes_rec.tax_id
         );
    FETCH jai_rcv_rgm_claimed_count_cur
    INTO  ln_tax_instl_claimed_cnt;
    CLOSE jai_rcv_rgm_claimed_count_cur;

    --Get the total amount to be claimed for this tax id by using  ln_claim_diff_amount := ln_tax_instl_claimed_cnt * ln_instl_diff

    --changed by eric for bug#6968733 on Apr 15,2008,begin
    ----------------------------------------------------------------------
    -- ln_tax_claimed_diff_amount := ln_tax_inst_claimed_cnt * ln_instl_diff  ;

    ln_tax_claimed_diff_amount := ln_tax_instl_claimed_cnt * ln_instl_diff  ;
    ----------------------------------------------------------------------
    --changed by eric for bug#6968733 on Apr 15,2008,end

    ln_tot_clm_instl_amt := ln_tot_clm_instl_amt + ln_tax_claimed_diff_amount; -- Total change amount claimed for this receipt

    ln_tot_instl_amt := ln_tot_instl_amt + ln_diff_re_tax_amt; -- Total change in installment amounts
  END LOOP; -- (jai_retor_tax_changes_rec IN jai_retro_tax_changes_cur)

  IF ln_tot_instl_amt <> 0
  THEN
    --Update jai_rcv_rgm_lines to increment recoverable_amount

    UPDATE jai_rcv_rgm_lines
       SET recoverable_amount = recoverable_amount + ln_tot_instl_amt
     --WHERE rcv_rgm_line_id = jai_rcv_rgm_lines.rcv_rgm_line_id;
     WHERE rcv_rgm_line_id = jai_rcv_rgm_lines_rec.rcv_rgm_line_id;  -- Modified by Jia for bug#6988208, on Apr 21, 2008.

  END IF;-- (ln_tot_instl_amt <> 0 )


  --IF any amount is claimed THEN
  IF ln_tot_clm_instl_amt <>0
  THEN
    --UPDATE jai_rcv_rgm_lines to increment the recovered_amount by the amount claimed
    UPDATE jai_rcv_rgm_lines
       SET recovered_amount   = recovered_amount   + ln_tot_clm_instl_amt
     --WHERE rcv_rgm_line_id = jai_rcv_rgm_lines.rcv_rgm_line_id;
     WHERE rcv_rgm_line_id = jai_rcv_rgm_lines_rec.rcv_rgm_line_id;  -- Modified by Jia for bug#6988208, on Apr 21, 2008.

  END IF; -- (ln_tot_clm_instl_amt <>0)

  FOR claim_schedule_rec IN get_claim_schedule_cur
  (pn_rcv_rgm_line_id =>jai_rcv_rgm_lines_rec.rcv_rgm_line_id)
  LOOP
    OPEN  get_parameters_cur (jai_rcv_rgm_lines_rec.rcv_rgm_line_id);
    FETCH get_parameters_cur
    INTO
      ln_organization_id
    , ln_location_id
    , ln_receipt_num
    , ln_regime_id  ;
    CLOSE get_parameters_cur;

    --Get the Interim recovery account by calling the following function
    ln_interim_recovery_account :=
      jai_cmn_rgm_recording_pkg.get_account
      ( p_regime_id         => ln_regime_id         -- fetched above
      , p_organization_type => jai_constants.orgn_type_io
      , p_organization_id   => ln_organization_id   -- fetched above
      , p_location_id       => ln_location_id       -- fetched above
      , p_tax_type          => claim_schedule_rec.tax_type  -- current tax type in the LOOP
      , p_account_name      => jai_constants.recovery_interim
      );
    IF ln_interim_recovery_account IS NULL THEN
      raise_application_error(-20110,'Recovery Account not defined in VAT Setup');
    END IF;

    --Get the recovery account by calling the following funcation
    ln_code_combination_id :=
      jai_cmn_rgm_recording_pkg.get_account
      ( p_regime_id         => ln_regime_id       -- fetched above
      , p_organization_type => jai_constants.orgn_type_io
      , p_organization_id   => ln_organization_id -- fetched above
      , p_location_id       => ln_location_id     -- fetched above
      , p_tax_type          => claim_schedule_rec.tax_type  -- current tax type in the LOOP
      , p_account_name      => jai_constants.recovery
      );

    IF ln_code_combination_id IS NULL THEN
      raise_application_error(-20110,'Recovery Account not defined in VAT Setup');
    END IF;

    --Call the following procedure to make an entry in VAT repository to the extent it is claimed

    jai_cmn_rgm_recording_pkg.insert_vat_repository_entry
    (
      pn_repository_id        => ln_repository_id, -- OUT parameter
      pn_regime_id            => ln_regime_id,     -- fetched above
      pv_tax_type             => claim_schedule_rec.tax_type,  -- current tax type in the LOOP
      pv_organization_type    => jai_constants.orgn_type_io,
      pn_organization_id      => ln_organization_id, -- fetched above
      pn_location_id          => ln_location_id,     -- fetched above
      pv_source               => jai_constants.source_rcv,
      pv_source_trx_type      => 'RETROACTIVE VAT CLAIM:'||to_char(pn_version_number),
      pv_source_table_name    => 'RCV_TRANSACTIONS',
      pn_source_id            => pn_transaction_id,
      pd_transaction_date     => trunc(sysdate),
      pv_account_name         => jai_constants.recovery,
      pn_charge_account_id    => ln_code_combination_id,
      pn_balancing_account_id => ln_interim_recovery_account,
      pn_credit_amount        => claim_schedule_rec.claim_amount, -- current claim amount in the LOOP
      pn_debit_amount         => claim_schedule_rec.claim_amount,
      pn_assessable_value     => NULL,
      pn_tax_rate             => NULL,
      pn_reference_id         => claim_schedule_rec.claim_schedule_id,-- Current claim_schedule_id in LOOP
      pn_batch_id             => NULL,
      pn_inv_organization_id  => ln_organization_id, -- fetched above
      pv_invoice_no           => pv_supp_vat_inv_no,
      pd_invoice_date         => pd_supp_vat_inv_date,
      pv_called_from          => 'JAI_RETRO_PRC_PKG.DO_VAT_CLAIM',
      pv_process_flag         => lv_process_status,
      pv_process_message      => lv_process_message,
      --Added by Bo Li for bug9305067 2010-4-14 BEGIN
      --------------------------------------------------
      pv_trx_reference_context    => NULL,
      pv_trx_reference1           => NULL,
      pv_trx_reference2           => NULL,
      pv_trx_reference3           => NULL,
      pv_trx_reference4           => NULL,
      pv_trx_reference5           => NULL
      ----------------------------------------------
      --Added by Bo Li for bug9305067 2010-4-14 BEGIN
    );

    IF lv_process_status <> jai_constants.successful
    THEN
      raise_application_error(-20120,'VAT repository Entry retruned with error : '||lv_process_message);
    END IF;

    lv_reference_10 := 'India Local Retroactive VAT Claim Entries For Receipt:'||lv_receipt_number;
    lv_reference_23 := 'JAI_RETRO_PRC_PKG.DO_VAT_CLAIM';
    lv_reference_24 := 'JAI_RETRO_TAX_CHANGES';
    lv_reference_25 := 'transaction_id';
    lv_reference_26 := pn_transaction_id;

    --Call the following procedure to debit the recovery account

    jai_rcv_accounting_pkg.process_transaction
    ( p_transaction_id      => pn_transaction_id,
      p_acct_type           => 'REGULAR',
      p_acct_nature         => 'VAT CLAIM',
      p_source_name         => 'Purchasing India',
      p_category_name       => 'Receiving India',
      p_code_combination_id => ln_code_combination_id,
      p_entered_dr          => claim_schedule_rec.claim_amount,
      p_entered_cr          => NULL,
      p_currency_code       => rcv_transactions_rec.currency_code,
      p_accounting_date     => SYSDATE,
      p_reference_10        => lv_reference_10,
      p_reference_23        => lv_reference_23,
      p_reference_24        => lv_reference_24,
      p_reference_25        => ln_repository_id,
      p_reference_26        => lv_reference_26,
      p_destination         => 'G',
      p_simulate_flag       => 'N',
      p_codepath            => lv_code_path,
      p_process_message     => lv_process_message,
      p_process_status      => lv_process_status,
      p_reference_name      => 'RETROACTIVE VAT CLAIM:'||to_char(pn_version_number),
      p_reference_id        => claim_schedule_rec.claim_schedule_id
    );

    IF lv_process_status <> jai_constants.successful THEN
      raise_application_error(-20120,'VAT Claim accounting retruned with error : '||lv_process_message);
    END IF;

     --Call the following procedure to credit the recovery account
    jai_rcv_accounting_pkg.process_transaction
    ( p_transaction_id      => pn_transaction_id,
      p_acct_type           => 'REGULAR',
      p_acct_nature         => 'VAT CLAIM',
      p_source_name         => 'Purchasing India',
      p_category_name       => 'Receiving India',
      p_code_combination_id => ln_interim_recovery_account,
      p_entered_dr          => NULL,
      p_entered_cr          => claim_schedule_rec.claim_amount,
      p_currency_code       => 'INR',
      p_accounting_date     => SYSDATE,
      p_reference_10        => lv_reference_10,
      p_reference_23        => lv_reference_23,
      p_reference_24        => lv_reference_24,
      p_reference_25        => ln_repository_id,
      p_reference_26        => lv_reference_26,
      p_destination         => 'G',
      p_simulate_flag       => 'N',
      p_codepath            => lv_code_path,
      p_process_message     => lv_process_message,
      p_process_status      => lv_process_status,
      p_reference_name      => 'RETROACTIVE VAT CLAIM:'||to_char(pn_version_number),
      p_reference_id        => claim_schedule_rec.claim_schedule_id
    );

    IF lv_process_status <> jai_constants.successful THEN
      raise_application_error(-20120,'VAT Claim accounting retruned with error : '||lv_process_message);
    END IF;

    --Update jai_rcv_rgm_claims to set the claimed amount equal to installment amount as claim is made

    UPDATE jai_rcv_rgm_claims
    SET    claimed_amount     = installment_amount
    WHERE  rcv_rgm_line_id    = jai_rcv_rgm_lines_rec.rcv_rgm_line_id
      AND  tax_type           = claim_schedule_rec.tax_type -- Current tax type in the loop
      AND  claimed_amount IS NOT NULL;

  END LOOP; -- claimed records

  -- UPDATE jai_retro_line_changes to modify vat_action as 'CLAIM' for the current receipt line
  UPDATE
    jai_retro_line_changes
  SET
    vat_action = 'CLAIM'
  WHERE line_change_id = pn_line_change_id;

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)  --logging for debug
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
END Do_Vat_Claim;

--==========================================================================
--  PROCEDURE NAME:
--
--    Do_Cenvat_Claim                     Private
--
--  DESCRIPTION:
--
--    This procedure is used to claim the cenvat tax on receipt
--
--
--  PARAMETERS:
--      In:pn_transaction_id    NUMBER      transaction identifier
--         pn_shipment_line_id  NUMBER      shipemnt line identifier,
--         pv_supp_vat_inv_no   VARCHAR2    supplementary invoice number
--         pd_supp_vat_inv_date DATE        supplementary invoice date
--         pn_version_number    NUMBER      receipt version number
--         pn_line_change_id    NUMBER      identifier of jai_retro_line_changes
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
PROCEDURE	Do_Cenvat_Claim
( pn_transaction_id     IN NUMBER,
  pn_shipment_line_id   IN NUMBER,
  pv_supp_exc_inv_no    IN VARCHAR2 DEFAULT NULL,
  pd_supp_exc_inv_date  IN DATE     DEFAULT NULL,
  pn_version_number     IN NUMBER,
  pn_line_change_id     IN NUMBER
)
IS
  --This procedure is used to CLAIM or UNCLAIM the CENVAT to the extent it got modified
  --It does the corresponding accounting as well
  lv_process_status  VARCHAR2(4000);
  lv_process_message VARCHAR2(4000);
  lv_code_path       VARCHAR2(4000);
  lv_cgin_code       VARCHAR2(4000);
  xt_tax_breakup_rec  jai_rcv_excise_processing_pkg.tax_breakup;
  lt_tax_breakup_rec  jai_rcv_excise_processing_pkg.tax_breakup;
  ln_charge_account_id NUMBER;
  xv_register_id       NUMBER;
  xv_process_status    VARCHAR2(4000);
  xv_process_message   VARCHAR2(4000);
  xv_code_path         VARCHAR2(4000);
  lv_tax_breakup_type  VARCHAR2(4000);
  lv_register_type     VARCHAR2(4000);

  CURSOR get_jai_transaction_cur
  IS
  SELECT
  *
  FROM
  	jai_rcv_transactions
  WHERE
    transaction_id = pn_transaction_id;

  CURSOR get_rcv_cenvat_claim_cur
  IS
  SELECT
    cenvat_claimed_ptg
  FROM
  	jai_rcv_cenvat_claims
  WHERE transaction_id = pn_transaction_id;



jai_transaction_rec get_jai_transaction_cur%ROWTYPE;

lv_procedure_name             VARCHAR2(40):='Do_Cenvat_Claim';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;
lv_amount_register            VARCHAR2(15);/*added by rchandan*/
ln_cenvat_claimed_ptg         NUMBER;/*added by rchandan*/

--added by eric for  bug 6918495 and bug 6914567 on Mar 28, 2008,begin
-------------------------------------------------------
CENVAT_CREDIT     CONSTANT     VARCHAR2(2)   := 'Cr';
CENVAT_DEBIT      CONSTANT     VARCHAR2(2)   := 'Dr';
-------------------------------------------------------
--added by eric for  bug 6918495 and bug 6914567  on Mar 28, 2008,end

BEGIN
	--logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level
  --Get the primary_cost_method from mtl_parameters for the organization

  --Call the following procedure to decide if Claim is valid for this transaction
  JAI_RCV_EXCISE_PROCESSING_PKG.Validate_Transaction
  ( p_transaction_id    => pn_transaction_id
  , p_validation_type   => 'COMMON'
  , p_process_status    => lv_process_status -- OUT parameter
  , p_process_message   => lv_process_message-- OUT parameter
  , p_simulate_flag     => 'N'
  , p_codepath          => lv_code_path -- OUT parameter
  );

  IF lv_process_status = 'E' THEN
    raise_application_error(-20120,'Validaiton of the receipt for Cenvat processing returned with error : '||lv_process_message);
  END IF;

  IF lv_process_status = 'X' THEN
    --Print that Claim is not valid for this and print lv_process_message
    FND_FILE.PUT_LINE(fnd_file.log, 'Total receipt fail to pass cenvat prossing validation,for the reason: '||lv_process_message);


    UPDATE
      jai_retro_line_changes
    SET
      excise_action ='UNCLAIM'
    WHERE
      line_change_id = pn_line_change_id;

    RETURN;
  END IF;


  --Get the record from jai_rcv_transactions for the current transaction_id
  OPEN  get_jai_transaction_cur;
  FETCH get_jai_transaction_cur
  INTO  jai_transaction_rec;
  CLOSE get_jai_transaction_cur;

  --Get  cenvat_claimed_ptg from jai_rcv_cenvat_claims for the current transaction_id
  OPEN  get_rcv_cenvat_claim_cur;
  FETCH get_rcv_cenvat_claim_cur
  INTO
    ln_cenvat_claimed_ptg;
  CLOSE get_rcv_cenvat_claim_cur;

  IF (jai_transaction_rec.organization_type = 'T')
  THEN  --Trading
    lv_tax_breakup_type := 'RG23D';
  ELSE  -- manufacturing and others
    lv_tax_breakup_type := 'MODVAT';
  END IF;--(jai_rcv_transactions.organization_type = 'T')

  --Call the following procedure to get the tax amounts by tax types
  Get_Tax_Amount_Breakup
  ( pn_shipment_line_id  => pn_shipment_line_id
  , pn_transaction_id    => pn_transaction_id
  , pn_curr_conv_rate    => jai_transaction_rec.currency_conversion_rate -- from rcv_transactions
  , pr_tax               => xt_tax_breakup_rec        -- OUT parameter
  , pv_breakup_type      => lv_tax_breakup_type
  , pn_line_change_id    => pn_line_change_id
  );

  lv_register_type := JAI_GENERAL_PKG.Get_Rg_Register_Type(jai_transaction_rec.item_class);
	lv_cgin_code := NULL;

  lt_tax_breakup_rec := xt_tax_breakup_rec;

  IF lv_register_type = 'C'
  THEN
    lv_amount_register := 'RG23C'; /*added by rchandan*/
    IF ln_cenvat_claimed_ptg = 50
    THEN
      lv_cgin_code := 'REGULAR-HALF';

      --deleted by eric for  bug 6918495 on Mar 28, 2008,begin
      ------------------------------------------------------------------------------
      /*
      --calculate lt_tax_breakup_rec to be half the xt_tax_breakup_rec
      lt_tax_breakup_rec.basic_excise     :=0.5 * xt_tax_breakup_rec.basic_excise   ;
      lt_tax_breakup_rec.addl_excise      :=0.5 * xt_tax_breakup_rec.addl_excise    ;
      lt_tax_breakup_rec.other_excise     :=0.5 * xt_tax_breakup_rec.other_excise   ;
      lt_tax_breakup_rec.cvd              :=0.5 * xt_tax_breakup_rec.cvd            ;
      lt_tax_breakup_rec.non_cenvat       :=0.5 * xt_tax_breakup_rec.non_cenvat     ;
      lt_tax_breakup_rec.excise_edu_cess  :=0.5 * xt_tax_breakup_rec.excise_edu_cess;
      lt_tax_breakup_rec.cvd_edu_cess     :=0.5 * xt_tax_breakup_rec.cvd_edu_cess   ;
      lt_tax_breakup_rec.addl_cvd         :=0.5 * xt_tax_breakup_rec.addl_cvd       ;
      lt_tax_breakup_rec.sh_exc_edu_cess  :=0.5 * xt_tax_breakup_rec.sh_exc_edu_cess;
      lt_tax_breakup_rec.sh_cvd_edu_cess  :=0.5 * xt_tax_breakup_rec.sh_cvd_edu_cess;
      */
      ------------------------------------------------------------------------------
      --deleted by eric for  bug 6918495 on Mar 28, 2008,end

      --modified by eric for  bug 6955045  on Mar 28, 2008,begin
      /*
       patch 6918495 failed to fix the bug 6918495, the bug of amount expected to double the
       current amount in the accounting type CENVAT-REG-50%.

       The tax amount calculated here is used by both accounting entries and tax repository.
       So we invoke the funcions Accounting_entries and Rg23_Part_Ii_Entry  of package JAI_RCV_EXCISE_PROCESSING_PKG
       to process it. In the function jai_rcv_excise_processing_pkg.accounting_entries, it has the logic to process
       lv_cgin_code := 'REGULAR-HALF' but the logic in Rg23_Part_Ii_Entry is not ignored.

       So we need to prepare the data
       lt_tax_breakup_rec := -xt_tax_breakup_rec for Accounting_entries
       and
       xt_tax_breakup_rec := 0.5*xt_tax_breakup_rec for Rg23_Part_Ii_Entry




       The orignal code is as:
         xt_tax_breakup_rec  := 0.5*xt_tax_breakup_rec
         lt_tax_breakup_rec  := -xt_tax_breakup_rec
       So the first symptom of  bug 6955045 is fixed but the secod is still there.


       Now opening a new bug 6955045 and changing the code as

         lt_tax_breakup_rec := -xt_tax_breakup_rec
         xt_tax_breakup_rec := 0.5*xt_tax_breakup_rec
      */




      --Added by eric for  bug 6918495 on Mar 28, 2008,begin
      ------------------------------------------------------------------------------
      lt_tax_breakup_rec.basic_excise     := -xt_tax_breakup_rec.basic_excise   ;
      lt_tax_breakup_rec.addl_excise      := -xt_tax_breakup_rec.addl_excise    ;
      lt_tax_breakup_rec.other_excise     := -xt_tax_breakup_rec.other_excise   ;
      lt_tax_breakup_rec.cvd              := -xt_tax_breakup_rec.cvd            ;
      lt_tax_breakup_rec.non_cenvat       := -xt_tax_breakup_rec.non_cenvat     ;
      lt_tax_breakup_rec.excise_edu_cess  := -xt_tax_breakup_rec.excise_edu_cess;
      lt_tax_breakup_rec.cvd_edu_cess     := -xt_tax_breakup_rec.cvd_edu_cess   ;
      lt_tax_breakup_rec.addl_cvd         := -xt_tax_breakup_rec.addl_cvd       ;
      lt_tax_breakup_rec.sh_exc_edu_cess  := -xt_tax_breakup_rec.sh_exc_edu_cess;
      lt_tax_breakup_rec.sh_cvd_edu_cess  := -xt_tax_breakup_rec.sh_cvd_edu_cess;

      --calculate lt_tax_breakup_rec to be half the xt_tax_breakup_rec
      xt_tax_breakup_rec.basic_excise     :=0.5 * xt_tax_breakup_rec.basic_excise   ;
      xt_tax_breakup_rec.addl_excise      :=0.5 * xt_tax_breakup_rec.addl_excise    ;
      xt_tax_breakup_rec.other_excise     :=0.5 * xt_tax_breakup_rec.other_excise   ;
      xt_tax_breakup_rec.cvd              :=0.5 * xt_tax_breakup_rec.cvd            ;
      xt_tax_breakup_rec.non_cenvat       :=0.5 * xt_tax_breakup_rec.non_cenvat     ;
      xt_tax_breakup_rec.excise_edu_cess  :=0.5 * xt_tax_breakup_rec.excise_edu_cess;
      xt_tax_breakup_rec.cvd_edu_cess     :=0.5 * xt_tax_breakup_rec.cvd_edu_cess   ;
      xt_tax_breakup_rec.addl_cvd         :=0.5 * xt_tax_breakup_rec.addl_cvd       ;
      xt_tax_breakup_rec.sh_exc_edu_cess  :=0.5 * xt_tax_breakup_rec.sh_exc_edu_cess;
      xt_tax_breakup_rec.sh_cvd_edu_cess  :=0.5 * xt_tax_breakup_rec.sh_cvd_edu_cess;
      ------------------------------------------------------------------------------
      --Added by eric for  bug 6918495 on Mar 28, 2008,end
      --modified by eric for  bug 6955045  on Mar 28, 2008,end

    ELSIF ln_cenvat_claimed_ptg = 100
    THEN
      lv_cgin_code := 'REGULAR-FULL-RETRO';
    END IF; -- ( ln_cenvat_claimed_ptg = 50)
  ELSIF lv_register_type = 'A' THEN

    lv_amount_register := 'RG23A'; /*added by rchandan*/

  END IF; -- (lv_register_type = 'C')



  JAI_RCV_EXCISE_PROCESSING_PKG.Rg23_Part_Ii_Entry
  ( p_transaction_id        	=> pn_transaction_id

  --modified by eric for  bug 6918495 on Mar 28, 2008,begin
  ------------------------------------------------------------------------------
  , pr_tax                      => xt_tax_breakup_rec    --lt_tax_breakup_rec
  ------------------------------------------------------------------------------
  --modified by eric for  bug 6918495 on Mar 28, 2008,end
  , p_part_i_register_id    	=> NULL
  , p_register_entry_type   	=> CENVAT_CREDIT
  , p_reference_num         	=> 'RETRO CENVAT CLAIMS '||pn_version_number
  , p_register_id           	=> xv_register_id
  , p_process_status        	=> xv_process_status
  , p_process_message       	=> xv_process_message
  , p_simulate_flag         	=> 'N'
  , p_codepath              	=> xv_code_path
  );

  IF lv_process_status IN ('X','E')
  THEN
    raise_application_error(-20120,'RG23 part II Entry retruned with error : '||lv_process_message);
  END IF;

  --UPDATE JAI_CMN_RG_23AC_II_TRXS and modify excise_invoice_no and excise_invoice_date
  --with pv_supp_exc_inv_no and pd_supp_exc_inv_date respectively
  UPDATE
    JAI_CMN_RG_23AC_II_TRXS
  SET
    excise_invoice_no    = pv_supp_exc_inv_no
  , excise_invoice_date  = pd_supp_exc_inv_date
  WHERE register_id = xv_register_id;

  --Call the following procedure to do cenvat accounting
  jai_rcv_excise_processing_pkg.accounting_entries
  ( p_transaction_id           => pn_transaction_id
  , pr_tax                     => lt_tax_breakup_rec
  , p_cgin_code                => lv_cgin_code
  --modified by eric for bug 6918495 and bug 6914567 on Mar 28, 2008,begin
  -------------------------------------------------------
  --, p_cenvat_accounting_type   => 'CENVAT_DEBIT'
  , p_cenvat_accounting_type   => CENVAT_DEBIT
  -------------------------------------------------------
  --modified by eric for bug 6918495 and bug 6914567 on Mar 28, 2008,end
  , p_amount_register          => lv_amount_register/*rchandan. replaced xv_register_id with lv_amount_register*/
  , p_cenvat_account_id        => ln_charge_account_id  -- OUT parameter
  , p_process_status           => lv_process_status
  , p_process_message          => lv_process_message
  , p_simulate_flag            => 'N'
  , p_codepath                 => lv_code_path
  , pv_retro_reference         => 'RETRO CENVAT CLAIMS '||pn_version_number
  );

  IF lv_process_status IN ('X','E')
  THEN
    raise_application_error(-20120,'CENVAT Claim accounting retruned with error : '||lv_process_message);
  END IF;

  --UPDATE jai_retro_line_changes to modify excise_action as 'CLAIM'
  UPDATE
    jai_retro_line_changes
  SET
    excise_action = 'CLAIM'
  WHERE line_change_id = pn_line_change_id;


  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)  --logging for debug
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RAISE;
END Do_Cenvat_Claim;
--==========================================================================
--  PROCEDURE NAME:
--
--    Process_Retroactive_Update                     Publice
--
--  DESCRIPTION:
--
--    This procedure is used to claim the cenvat tax on receipt
--
--
--  PARAMETERS:
--      In:errbuf               NUMBER      error buffer the cocurent
--         retcode              NUMBER      return the cocurent
--         pn_vendor_id         NUMBER      vendor identifier
--         pn_vendor_site_id    NUMBER      vendor site identifier
--         pn_po_header_id      NUMBER      aggrement identifer
--         pv_from_eff_date     VARCHAR2    effective from date
--         pv_vat_action        NUMBER      vat action 'CLAIM' or 'UNCLAIM'
--         pv_supp_exc_inv_no   VARCHAR2    supplementary invoice number
--         pv_supp_exc_inv_date DATE        supplementary invoice date
--         pv_cenvat_action     NUMBER      cenvat action 'CLAIM' or 'UNCLAIM'
--         pv_supp_vat_inv_no   VARCHAR2    supplementary invoice number
--         pv_process_downward DATE        supplementary invoice date
--         pn_version_number    NUMBER      receipt version number
--         pv_process_downward  VARCHAR2    down revision processing flag
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--           01-Feb-2008   Eric Ma  add logs and change code in exception for bug #6788048
--==========================================================================
PROCEDURE Process_Retroactive_Update
( errbuf                OUT  NOCOPY       VARCHAR2
, retcode               OUT  NOCOPY       VARCHAR2
, pn_vendor_id          IN NUMBER
, pn_vendor_site_id     IN NUMBER   DEFAULT NULL
, pn_po_header_id       IN NUMBER   DEFAULT NULL
, pv_from_eff_date      IN VARCHAR2 DEFAULT NULL
, pv_cenvat_action      IN VARCHAR2 DEFAULT NULL
, pv_supp_exc_inv_no    IN VARCHAR2 DEFAULT NULL
, pv_supp_exc_inv_date  IN VARCHAR2 DEFAULT NULL
, pv_vat_action         IN VARCHAR2 DEFAULT NULL
, pv_supp_vat_inv_no    IN VARCHAR2 DEFAULT NULL
, pv_supp_vat_inv_date  IN VARCHAR2 DEFAULT NULL
, pv_process_downward   IN VARCHAR2 DEFAULT NULL
)
IS
  jai_rcv_transactions_rec     jai_rcv_transactions%ROWTYPE;
  jai_rcv_lines_rec            jai_rcv_lines%ROWTYPE;

  ln_skip_rcpt_cnt       NUMBER := NULL;
  lv_profile_setting     VARCHAR2(255);

  ln_recv_line_amount    NUMBER;
  ln_recv_tax_amount     NUMBER;
  ln_vat_assess_value    NUMBER;
  ln_assessable_value    NUMBER;
  ln_retro_line_changes_id NUMBER;
  lv_cenvat_action       VARCHAR2(4000);
  lv_vat_action          VARCHAR2(4000);
  ln_re_vat_amount       NUMBER;
  ln_re_cenvat_amount    NUMBER;
  ln_modif_re_vat_amount NUMBER;
  ln_modif_re_cenvat_amount NUMBER;
  ln_diff_re_vat_amount NUMBER;
  ln_diff_re_cenvat_amount NUMBER;
  ln_non_rec_amount        NUMBER;
  ln_retro_line_changes_version NUMBER;

ld_from_eff_date      DATE := TO_DATE(pv_from_eff_date, 'YYYY/MM/DD hh24:mi:ss');
ld_supp_exc_inv_date  DATE := TO_DATE(pv_supp_exc_inv_date, 'YYYY/MM/DD hh24:mi:ss');
ld_supp_vat_inv_date  DATE := TO_DATE(pv_supp_vat_inv_date, 'YYYY/MM/DD hh24:mi:ss');
ln_receipt_processed_no     NUMBER;
ln_tot_receipt_processed_no NUMBER :=0;
ln_tot_receipt_no           NUMBER;


ln_org_nonre_tax_amount      NUMBER;   --added by eric on Apr 10,2008 for bug 6957519/6958938/6968839
ln_modif_nonre_tax_amount    NUMBER;   --added by eric on Apr 10,2008 for bug 6957519/6958938/6968839
ln_diff_nonre_tax_amount     NUMBER;   --added by eric on Apr 10,2008 for bug 6957519/6958938/6968839

CURSOR get_rcv_transactions_cur
( pn_line_location_id rcv_transactions.po_line_location_id%TYPE
, pn_line_change_id   jai_retro_line_changes.line_change_id%TYPE
)
IS
SELECT
*
FROM
  rcv_transactions rt
WHERE rt.transaction_type = 'RECEIVE'
  AND rt.po_line_location_id =pn_line_location_id
  AND creation_date >= NVL(ld_from_eff_date,creation_date)-- eric changed according to review comment #36
  AND NOT EXISTS ( SELECT
                    'X'
                  FROM
                    jai_retro_line_changes jrlc
                  WHERE jrlc.doc_line_id = rt.shipment_line_id
                    AND jrlc.source_line_change_id = pn_line_change_id
                    AND jrlc.doc_type = 'RECEIPT'
                );

CURSOR get_jai_rcv_line_taxes_cur
(pn_transaction_id jai_rcv_line_taxes.transaction_id%TYPE )
IS
SELECT
jrlt.*,
jcta.adhoc_flag
FROM
  jai_rcv_line_taxes jrlt
, jai_cmn_taxes_all  jcta
WHERE  jrlt.transaction_id = pn_transaction_id
  AND  jrlt.tax_id         = jcta.tax_id;

CURSOR get_jai_retro_line_change_cur
IS
-- doc_type is RELEASE
SELECT
  line_change_id
, doc_type
, doc_header_id
, doc_line_id
, line_location_id
, from_header_id
, from_line_id
, doc_version_number
, source_line_change_id
, price_change_date
, inventory_item_id
, organization_id
, original_unit_price
, modified_unit_price
, receipt_processed_flag
, excise_action
, vat_action
, excise_invoice_no
, excise_invoice_date
, vat_invoice_no
, vat_invoice_date
, retro_request_id
, doc_number
, vendor_id
, vendor_site_id
FROM
  jai_retro_line_changes jrlc
WHERE  vendor_id      = NVL(pn_vendor_id,vendor_id)
  AND  vendor_site_id = NVL(pn_vendor_site_id,vendor_site_id)
  AND  (  (doc_type = 'RELEASE'     AND doc_header_id  = NVL(pn_po_header_id  ,doc_header_id))
       OR (doc_type = 'STANDARD PO' AND from_header_id = NVL(pn_po_header_id  ,from_header_id))
       )
  AND  NVL(receipt_processed_flag,'N') <>jai_constants.yes
  --AND creation_date <= NVL(ld_from_eff_date,creation_date) , eric remomved according to review comment #36
  AND  (original_unit_price < modified_unit_price OR pv_process_downward = jai_constants.yes )
  AND doc_version_number =( SELECT MAX(doc_version_number)
                            FROM   jai_retro_line_changes   a
                            WHERE  a.line_location_id   = jrlc.line_location_id
                          ) ;
lv_procedure_name             VARCHAR2(40):='Process_Retroactive_Update';
ln_dbg_level                  NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level                 NUMBER:=FND_LOG.LEVEL_PROCEDURE;

BEGIN
	--logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  BEGIN
    FND_FILE.PUT_LINE(fnd_file.log, 'Concurrent Input Parameter Is :');
    FND_FILE.PUT_LINE(fnd_file.log, '-------------------------------------------------------------- ');
    FND_FILE.PUT_LINE(fnd_file.log, 'VENDOR ID                 :'|| pn_vendor_id      );
    FND_FILE.PUT_LINE(fnd_file.log, 'VENDOR SITE ID            :'|| pn_vendor_site_id );
    FND_FILE.PUT_LINE(fnd_file.log, 'AGGREMENT ID              :'|| pn_po_header_id   );
    FND_FILE.PUT_LINE(fnd_file.log, 'EFFECTIVE DATE            :'|| pv_from_eff_date  );
    FND_FILE.PUT_LINE(fnd_file.log, 'Execise Action            :'|| pv_cenvat_action  );
    FND_FILE.PUT_LINE(fnd_file.log, 'Supp Execise Invoice No.  :'|| pv_supp_exc_inv_no  );
    FND_FILE.PUT_LINE(fnd_file.log, 'Supp Execise Invoice Date :'|| pv_supp_exc_inv_date );
    FND_FILE.PUT_LINE(fnd_file.log, 'Vat Action                :'|| pv_vat_action  );
    FND_FILE.PUT_LINE(fnd_file.log, 'Supp VAT Invoice No.      :'|| pv_supp_vat_inv_no  );
    FND_FILE.PUT_LINE(fnd_file.log, 'Supp VAT Invoice Date     :'|| pv_supp_vat_inv_date );
    FND_FILE.PUT_LINE(fnd_file.log, 'Down Revision Process     :'|| pv_process_downward  );
    FND_FILE.PUT_LINE(fnd_file.log, '--------------------------------------------------------- ');
  END;

  retcode := 0;
  errbuf  := NULL;

  IF (pv_cenvat_action ='CLAIM' AND (pv_supp_exc_inv_no IS NULL OR pv_supp_exc_inv_date IS NULL))
  THEN
    FND_FILE.PUT_LINE(fnd_file.log, ' Both Supplementary Excise Invoice NO and Supplementary Excise Invoice date should not be null when Excise Action is CLAIM' );
    retcode :=2;
    RETURN;
  END IF;


  IF (pv_vat_action ='CLAIM' AND (pv_supp_vat_inv_no IS NULL OR pv_supp_vat_inv_date IS NULL))
  THEN
    FND_FILE.PUT_LINE(fnd_file.log, ' Both Supplementary Vat Invoice NO and Supplementary Vat Invoice date should not be null when Excise Action is CLAIM' );
    retcode :=2;
    RETURN;
  END IF;

  --Get the value for the profile: "PO: Allow Retroactive Pricing of POs"
  lv_profile_setting := FND_PROFILE.VALUE('PO_ALLOW_RETROPRICING_OF_PO');

  IF (lv_profile_setting <>'ALL_RELEASES')
  THEN
    FND_FILE.PUT_LINE(fnd_file.log, 'PO: Allow Retroactive Pricing of POs = '||lv_profile_setting );
    FND_FILE.PUT_LINE(fnd_file.log, 'This Concurrent Program is not executed as the profile (PO: Allow Retroactive Pricing of POs) is not set to ''ALL RELEASES''');
    retcode :=0;
    RETURN;
  END IF;

  FOR jai_retro_line_change_rec IN get_jai_retro_line_change_cur
  LOOP
    -- Print the shipment line information
    BEGIN
      FND_FILE.PUT_LINE(fnd_file.log, ' ');
      FND_FILE.PUT_LINE(fnd_file.log, '++++');
      FND_FILE.PUT_LINE(fnd_file.log, 'Loop for the shipment line, line_change_id ='||jai_retro_line_change_rec.line_change_id );
      FND_FILE.PUT_LINE(fnd_file.log, 'doc_type               = '||jai_retro_line_change_rec.doc_type              );
      FND_FILE.PUT_LINE(fnd_file.log, 'doc_header_id          = '||jai_retro_line_change_rec.doc_header_id         );
      FND_FILE.PUT_LINE(fnd_file.log, 'doc_line_id            = '||jai_retro_line_change_rec.doc_line_id           );
      FND_FILE.PUT_LINE(fnd_file.log, 'line_location_id       = '||jai_retro_line_change_rec.line_location_id      );
      FND_FILE.PUT_LINE(fnd_file.log, 'from_header_id         = '||jai_retro_line_change_rec.from_header_id        );
      FND_FILE.PUT_LINE(fnd_file.log, 'from_line_id           = '||jai_retro_line_change_rec.from_line_id          );
      FND_FILE.PUT_LINE(fnd_file.log, 'doc_version_number     = '||jai_retro_line_change_rec.doc_version_number    );
      FND_FILE.PUT_LINE(fnd_file.log, 'inventory_item_id      = '||jai_retro_line_change_rec.inventory_item_id     );
      FND_FILE.PUT_LINE(fnd_file.log, 'organization_id        = '||jai_retro_line_change_rec.organization_id       );
      FND_FILE.PUT_LINE(fnd_file.log, 'original_unit_price    = '||jai_retro_line_change_rec.original_unit_price   );
      FND_FILE.PUT_LINE(fnd_file.log, 'modified_unit_price    = '||jai_retro_line_change_rec.modified_unit_price   );
      FND_FILE.PUT_LINE(fnd_file.log, 'receipt_processed_flag = '||jai_retro_line_change_rec.receipt_processed_flag);
      FND_FILE.PUT_LINE(fnd_file.log, 'excise_action          = '||jai_retro_line_change_rec.excise_action         );
      FND_FILE.PUT_LINE(fnd_file.log, 'vat_action             = '||jai_retro_line_change_rec.vat_action            );
      FND_FILE.PUT_LINE(fnd_file.log, 'excise_invoice_no      = '||jai_retro_line_change_rec.excise_invoice_no     );
      FND_FILE.PUT_LINE(fnd_file.log, 'excise_invoice_date    = '||jai_retro_line_change_rec.excise_invoice_date   );
      FND_FILE.PUT_LINE(fnd_file.log, 'vat_invoice_no         = '||jai_retro_line_change_rec.vat_invoice_no        );
      FND_FILE.PUT_LINE(fnd_file.log, 'vat_invoice_date       = '||jai_retro_line_change_rec.vat_invoice_date      );
      FND_FILE.PUT_LINE(fnd_file.log, 'retro_request_id       = '||jai_retro_line_change_rec.retro_request_id      );
      FND_FILE.PUT_LINE(fnd_file.log, 'doc_number             = '||jai_retro_line_change_rec.doc_number            );
      FND_FILE.PUT_LINE(fnd_file.log, 'vendor_id              = '||jai_retro_line_change_rec.vendor_id             );
      FND_FILE.PUT_LINE(fnd_file.log, 'vendor_site_id         = '||jai_retro_line_change_rec.vendor_site_id        );
    END;

    ln_skip_rcpt_cnt := 0; --This is to count the number of receipts which are not processed for this Shipment
    ln_receipt_processed_no :=0 ;--Initial vaiable for counting receipt processed number for a shipment
    ln_tot_receipt_no :=0;   --Initial vaiable for counting total receipts number for a shipment

    --LOOP through the RECEIVE transactions performed against the current Shipment
    FOR rcv_transactions_rec IN get_rcv_transactions_cur ( pn_line_location_id => jai_retro_line_change_rec.line_location_id
                                                   , pn_line_change_id   => jai_retro_line_change_rec.line_change_id
                                                   )
    LOOP
      ln_tot_receipt_no := ln_tot_receipt_no +1;
      jai_rcv_transactions_rec := Get_Jai_Rcv_Trans_Record(rcv_transactions_rec.transaction_id);
      jai_rcv_lines_rec        := Get_Jai_Rcv_Lines_Record(rcv_transactions_rec.transaction_id);

      BEGIN
      	FND_FILE.PUT_LINE(fnd_file.log, ' ');
      	FND_FILE.PUT_LINE(fnd_file.log, '  ++');
        FND_FILE.PUT_LINE(fnd_file.log, '  LOOP through the RECEIVE transactions,Transaction id is    : ' ||rcv_transactions_rec.transaction_id);
        FND_FILE.PUT_LINE(fnd_file.log, '  Shipment Header id is    : ' ||jai_rcv_lines_rec.shipment_header_id);
        FND_FILE.PUT_LINE(fnd_file.log, '  Shipment Line id is      : ' ||jai_rcv_lines_rec.shipment_line_id);
        FND_FILE.PUT_LINE(fnd_file.log, '  Receipt Number is        : ' ||jai_rcv_lines_rec.receipt_num );
        FND_FILE.PUT_LINE(fnd_file.log, '  Receipt Vat status is    : ' ||jai_rcv_transactions_rec.process_vat_status);
        FND_FILE.PUT_LINE(fnd_file.log, '  Receipt CenVat status is : ' ||jai_rcv_transactions_rec.cenvat_rg_status);
        FND_FILE.PUT_LINE(fnd_file.log, '');
      END;
      IF ( jai_rcv_transactions_rec.process_vat_status IS NULL
            OR jai_rcv_transactions_rec.process_vat_status = 'P'
            OR jai_rcv_transactions_rec.process_vat_status = 'N'
            OR jai_rcv_transactions_rec.process_vat_status = 'EE'
            OR jai_rcv_transactions_rec.cenvat_rg_status  IS NULL
            OR jai_rcv_transactions_rec.cenvat_rg_status  = 'P'
            OR jai_rcv_transactions_rec.cenvat_rg_status  = 'N'
            OR jai_rcv_transactions_rec.cenvat_rg_status  = 'EE'
            )
      THEN
        -- Print a message stating that the Receipt is not claimed and it should be claimed before
        -- JAI Retroactive price Update is Run
        IF( jai_rcv_transactions_rec.process_vat_status IS NULL
            OR jai_rcv_transactions_rec.process_vat_status = 'P'
            OR jai_rcv_transactions_rec.process_vat_status = 'N'
            OR jai_rcv_transactions_rec.process_vat_status = 'EE'
           )
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  Vat tax on the receipt :'||jai_rcv_lines_rec.receipt_num||' is not claimed.');
        END IF;

        IF( jai_rcv_transactions_rec.cenvat_rg_status IS NULL
            OR jai_rcv_transactions_rec.cenvat_rg_status = 'P'
            OR jai_rcv_transactions_rec.cenvat_rg_status = 'N'
            OR jai_rcv_transactions_rec.cenvat_rg_status = 'EE'
           )
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  Cenvat tax on the receipt :'||jai_rcv_lines_rec.receipt_num||' is not claimed.');
        END IF;

      	FND_FILE.PUT_LINE(fnd_file.log, '  Please Claim it before running the concurrent JAI Retroactive price Update');
        ln_skip_rcpt_cnt := ln_skip_rcpt_cnt + 1;
      ELSE
      	--get the retro line change id the receipt from a sequence
        SELECT
          jai_retro_line_changes_s.nextval
        INTO
          ln_retro_line_changes_id
        FROM
          DUAL;

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_retro_line_changes_id : '|| ln_retro_line_changes_id);
        END IF; --l_proc_level>=l_dbg_level

        --get the version number of retro tax line for the receipt
        --starting from 0
        SELECT
          NVL(MAX(doc_version_number),0) + 1 /*rchandan. Moved +1 outside NVL*/
        INTO
          ln_retro_line_changes_version
        FROM
          jai_retro_line_changes
        WHERE doc_header_id = jai_rcv_lines_rec.shipment_header_id
          AND doc_line_id   = jai_rcv_lines_rec.shipment_line_id
          AND doc_type      = 'RECEIPT';

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_retro_line_changes_version : '|| ln_retro_line_changes_version);
        END IF; --l_proc_level>=l_dbg_level

        --insert data into jai_retro_line_changes table
        INSERT INTO jai_retro_line_changes
        ( line_change_id
        , doc_type
        , doc_header_id
        , doc_line_id
        , line_location_id
        , doc_version_number
        , source_line_change_id -- added for indicating receipt processed or not
        , price_change_date
        , inventory_item_id
        , organization_id
        , original_unit_price
        , modified_unit_price
        , receipt_processed_flag
        , excise_action
        , excise_invoice_no
        , excise_invoice_date
        , vat_action
        , vat_invoice_no
        , vat_invoice_date
        , retro_request_id
        , doc_number
        , vendor_id
        , vendor_site_id
        , creation_date
        , created_by
        , last_update_date
        , last_update_login
        , last_updated_by
        , object_version_number
        )
        VALUES
        ( ln_retro_line_changes_id                            --=>  jai_retro_line_changes_s.nextval
        , 'RECEIPT'                                           --=>  'RECEIPT'
        , jai_rcv_lines_rec.shipment_header_id                --=>  shipment_header_id from jai_rcv_lines
        , jai_rcv_lines_rec.shipment_line_id                  --=>  shipment_Line_Id from jai_rcv_lines
        , NULL                                                --=>  NULL
        , ln_retro_line_changes_version                       --=>  Increment previous version number of this receipt,issue??
        , jai_retro_line_change_rec.line_change_id            --=>  source_line_change_id ,The line_change_id of latest shipment
        , SYSDATE                                             --=>  Sysdate
        , jai_rcv_lines_rec.inventory_item_id                 --=>  inventory_item_id from jai_rcv_lines
        , jai_rcv_lines_rec.organization_id                   --=>  Organization_id from jai_rcv_lines
        , jai_retro_line_change_rec.original_unit_price       --=>  original_unit_price from jai_retro_line_changes of the current Release
        , jai_retro_line_change_rec.modified_unit_price       --=>  Modified_unit_price from jai_retro_line_changes of the current Release
        , 'Y'                                                 --=>  receipt_processed_flag :'Y'
        , pv_cenvat_action                                    --=>  pv_cenvat_action
        , pv_supp_exc_inv_no                                  --=>  pv_supp_exc_inv_no
        , ld_supp_exc_inv_date                                --=>  pd_supp_exc_inv_date
        , pv_vat_action                                       --=>  pv_vat_action
        , pv_supp_vat_inv_no                                  --=>  pv_supp_vat_inv_no
        , ld_supp_vat_inv_date                                --=>  pd_supp_vat_inv_date
        , fnd_global.conc_request_id                          --=>  fnd_global.conc_request_id
        , jai_rcv_lines_rec.receipt_num                       --=>  receipt_number from jai_rcv_lines
        , rcv_transactions_rec.vendor_id                      --=>  vendor_id from rcv_transactions
        , rcv_transactions_rec.vendor_site_id                 --=>  vendor_site_id from rcv_transactions
        , SYSDATE                                             --=>  sysdate
        , FND_GLOBAL.USER_ID                                  --=>  fnd_global.user_id
        , SYSDATE                                             --=>  sysdate
        , FND_GLOBAL.LOGIN_ID                                 --=>  fnd_global.login_id
        , FND_GLOBAL.USER_ID                                  --=>  fnd_global.user_id
        , NULL                                                --=>  NULL
        );

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  Table jai_retro_line_changes inserted ');
        END IF; --l_proc_level>=l_dbg_level

      	FOR jai_rcv_line_taxes_rec IN get_jai_rcv_line_taxes_cur (rcv_transactions_rec.transaction_id)
        LOOP
          -- Insert into jai_retro_tax_changes
          INSERT INTO jai_retro_tax_changes
          ( tax_change_id
          , line_change_id
          , tax_line_no
          , tax_id
          , tax_name
          , tax_type
          , currency_code
          , original_tax_amount
          , modified_tax_amount
          , Recoverable_flag
          , adhoc_flag
          , third_party_flag
          , creation_date
          , created_by
          , last_update_date
          , last_update_login
          , last_updated_by
          , object_version_number
          )
          VALUES
          ( jai_retro_tax_changes_s.nextval               --=>  jai_retro_tax_changes_s.nextval
          , ln_retro_line_changes_id                      --=>  from jai_retro_line_changes
          , jai_rcv_line_taxes_rec.tax_line_no		         --=>  from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.tax_id                 --=>  from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.tax_name               --=>  from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.tax_type               --=>  from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.currency               --=>  from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.tax_amount             --=>  tax_amount from jai_rcv_line_taxes
          , NULL                                          --=>  NULL ,modified_tax_amount
          , jai_rcv_line_taxes_rec.modvat_flag            --=>  modvat_flag from jai_rcv_line_taxes
          , jai_rcv_line_taxes_rec.adhoc_flag             --=>  adhoc_flag from jai_cmn_taxes_all. Join using tax_id
          , jai_rcv_line_taxes_rec.third_party_flag       --=>  from jai_rcv_line_taxes
          , SYSDATE                                       --=>  sysdate
          , fnd_global.user_id                            --=>  fnd_global.user_id
          , SYSDATE                                       --=>  sysdate
          , fnd_global.login_id                           --=>  fnd_global.login_id
          , fnd_global.user_id                            --=>  fnd_global.user_id
          , NULL                                          --=>  NULL
          ) ;
        END LOOP;-- (jai_rcv_line_taxes_rec IN get_jai_rcv_line_taxes_cur)

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  Table jai_retro_tax_changes inserted  ');
        END IF; --l_proc_level>=l_dbg_level

        --calc_new_line_amount
        ln_recv_line_amount :=  jai_retro_line_change_rec.modified_unit_price
                              * rcv_transactions_rec.quantity;

        ln_recv_tax_amount  := ln_recv_line_amount;

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_recv_line_amount : '|| ln_recv_line_amount);
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_recv_tax_amount : '|| ln_recv_tax_amount);
        END IF; --l_proc_level>=l_dbg_level

        --get_assessable_value
        ln_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value
                               ( p_vendor_id      => rcv_transactions_rec.vendor_id
                               , p_vendor_site_id => rcv_transactions_rec.vendor_site_id
                               , p_inv_item_id    => jai_rcv_lines_rec.inventory_item_id
                               , p_line_uom       => jai_rcv_transactions_rec.uom_code
                               );

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_assessable_value : '|| ln_assessable_value);
        END IF; --l_proc_level>=l_dbg_level

        IF NVL( ln_assessable_value, 0 ) <= 0
        THEN
          ln_assessable_value := ln_recv_line_amount;
        ELSE
          ln_assessable_value := ln_assessable_value * rcv_transactions_rec.quantity;
        END IF;

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_assessable_value :=ln_assessable_value*quantity : '|| ln_assessable_value);
        END IF; --l_proc_level>=l_dbg_level

        --get_vat_assessable_value
        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value
                               ( p_party_id          => rcv_transactions_rec.vendor_id
                               , p_party_site_id     => rcv_transactions_rec.vendor_site_id
                               , p_inventory_item_id => jai_rcv_lines_rec.inventory_item_id
                               , p_uom_code          => jai_rcv_transactions_rec.uom_code
                               , p_default_price     => jai_retro_line_change_rec.modified_unit_price
                               , p_ass_value_date    => trunc(sysdate)
                               , p_party_type        => 'V'
                               );

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_vat_assess_value : '|| ln_vat_assess_value);
        END IF; --l_proc_level>=l_dbg_level


        ln_vat_assess_value := ln_vat_assess_value * rcv_transactions_rec.quantity;

        IF (ln_proc_level >= ln_dbg_level)
        THEN
          FND_FILE.PUT_LINE(fnd_file.log, '  ln_vat_assess_value :=ln_vat_assess_value*quantity : '|| ln_vat_assess_value);
        END IF; --l_proc_level>=l_dbg_level

        JAI_PO_TAX_PKG.Calculate_Tax
	( p_type                => 'RECEIPTS'
        , p_header_id 		=> jai_rcv_lines_rec.shipment_header_id          -- Receipt Shipment header Id
        , P_line_id 		=> jai_rcv_lines_rec.shipment_line_id            -- Receipt Shipment line Id
        , p_line_loc_id 	=> -999
        , p_line_quantity 	=> rcv_transactions_rec.quantity                 -- receipt Quantity
        , p_price 		=> ln_recv_line_amount                           -- Receipt line Amount
        , p_line_uom_code 	=> jai_rcv_transactions_rec.uom_code             -- Receipt UOM code
        , p_tax_amount 		=> ln_recv_tax_amount                            -- Receipt line Amount ( IN Out parameter that gives the total tax amount and takes line amount as Input)
        , p_assessable_value 	=> ln_assessable_value                           -- Excise Assesable value
        , p_vat_assess_value 	=> ln_vat_assess_value                           -- VAT Assessable value
        , p_item_id 	        => jai_rcv_lines_rec.inventory_item_id           -- Inventory item id
        , p_conv_rate        	=> rcv_transactions_rec.currency_conversion_rate -- currency conversion rate
        , pv_retroprice_changed => 'Y'                                           --CHANGED NEW
        , pv_called_from      	=> 'RETROACTIVE'                                 -- New parameter
        );

        -- print the new total tax amount of the receipt
        Fnd_File.Put_Line(FND_FILE.LOG,'  New total tax amount of the receipt '||jai_rcv_lines_rec.receipt_num||' IS :' ||ln_recv_tax_amount);

        -- After recalculating the tax ,updat the modified_tax_amount  of jai_retro_tax_changes table
      	FOR jai_rcv_line_taxes_rec IN get_jai_rcv_line_taxes_cur (rcv_transactions_rec.transaction_id)
        LOOP
          -- Update the new tax amount in modified_tax_amount column of jai_retro_tax_changes
          UPDATE
            jai_retro_tax_changes jrtc
          SET
            modified_tax_amount = ( SELECT tax_amount
                                    FROM   jai_rcv_line_taxes jrlt
                                    WHERE  jrlt.shipment_header_id     = jai_rcv_lines_rec.shipment_header_id
                                      AND  jrlt.shipment_line_id       = jai_rcv_lines_rec.shipment_line_id
                                      AND  jrlt.tax_id                 = jrtc.tax_id
                                  )
          WHERE  line_change_id      = ln_retro_line_changes_id
            AND  tax_line_no         = jai_rcv_line_taxes_rec.tax_line_no
            AND  tax_id              = jai_rcv_line_taxes_rec.tax_id   ;
        END LOOP;	 --jai_rcv_line_taxes_rec IN get_jai_rcv_line_taxes_cur

        Fnd_File.Put_Line(FND_FILE.LOG,'  New tax has been updated to the table jai_retro_tax_changes ');

        Get_Vat_CenVat_Amount
        ( pn_line_change_id         => ln_retro_line_changes_id
        , xn_re_vat_amount          => ln_re_vat_amount
        , xn_modif_re_vat_amount    => ln_modif_re_vat_amount
        , xn_diff_re_vat_amount     => ln_diff_re_vat_amount
        , xn_re_cenvat_amount       => ln_re_cenvat_amount
        , xn_modif_re_cenvat_amount => ln_modif_re_cenvat_amount
        , xn_diff_re_cenvat_amount  => ln_diff_re_cenvat_amount
        );
        --eric deleted for bug 6957519/6958938/6968839  on Apr 10,2008,begin
        ----------------------------------------------------------------------------------------------
        --ln_non_rec_amount := Get_Tot_NonRe_Tax_Amount(pn_line_change_id => ln_retro_line_changes_id);
        ----------------------------------------------------------------------------------------------
        --eric deleted for bug 6957519/6958938/6968839  on Apr 10,2008,end


        --eric added for bug 6957519/6958938/6968839  on Apr 10,2008,begin
        ----------------------------------------------------------------------------------------------
        Get_Tot_NonRe_Tax_Amount
        ( pn_line_change_id         => ln_retro_line_changes_id
        , xn_org_nonre_tax_amount   => ln_org_nonre_tax_amount
        , xn_modif_nonre_tax_amount => ln_modif_nonre_tax_amount
        , xn_diff_nonre_tax_amount  => ln_diff_nonre_tax_amount
        );
        ----------------------------------------------------------------------------------------------
        --eric added for bug 6957519/6958938/6968839  on Apr 10,2008,end

        Fnd_File.Put_Line(FND_FILE.LOG,'  New VAT tax amount is     : '|| ln_modif_re_vat_amount|| ', the difference from old vat tax is :'|| ln_diff_re_vat_amount);
        Fnd_File.Put_Line(FND_FILE.LOG,'  New CENVAT tax amount is  : '|| ln_modif_re_cenvat_amount|| ', the difference from old cenvat tax is :'|| ln_diff_re_cenvat_amount);
        Fnd_File.Put_Line(FND_FILE.LOG,'  New NonRecoverable Tax is : '|| ln_modif_nonre_tax_amount|| ', the difference from old NonRecoverable tax is :'|| ln_diff_nonre_tax_amount);

        lv_cenvat_action  := pv_cenvat_action ;
        lv_vat_action     := pv_vat_action    ;

        -- Call the procedure to do accounting for both RECEIVE and DELIVER transactions

        -- xv_cenvat_action/xv_vat_action are IN OUT parameters. Even if the user decides
        -- to claim cenvat, depending on set up we may chose to  unclaim. This parameter returns the action taken
        -- and takes the pv_cenvat_action as input
        Do_Accounting
        ( pn_shipment_line_id => rcv_transactions_rec.shipment_line_id   -- from rcv_transactions
        , pn_transaction_id   => rcv_transactions_rec.transaction_id     -- from rcv_transactions for the current RECEIVE transaction,
        , pn_cenvat_amount    => ln_diff_re_cenvat_amount      -- Cenvat amount difference from above
        , xv_cenvat_action    => lv_cenvat_action
        , pn_vat_amount       => ln_diff_re_vat_amount         -- recoverable VAT difference from above
        , xv_vat_action       => lv_vat_action
        --eric modified for bug 6957519/6958938/6968839  on Apr 10,2008,begin
        -------------------------------------------------------------------------
        --, pn_non_rec_amount   => ln_non_rec_amount -- Non recoverable tax amount from above
        , pn_non_rec_amount   => ln_diff_nonre_tax_amount      -- difference of Non recoverable tax amount between org and modifed amount
        -------------------------------------------------------------------------
        --eric modified for bug 6957519/6958938/6968839  on Apr 10,2008,end
        , pn_version_number   => ln_retro_line_changes_version -- current version of the receipt i.e previous version plus one
        , pn_line_change_id   => ln_retro_line_changes_id
        );

        Fnd_File.Put_Line(FND_FILE.LOG,' ');
        Fnd_File.Put_Line(FND_FILE.LOG,'  Do_Accounting() Invoked. ');
        Fnd_File.Put_Line(FND_FILE.LOG,' ');
	-- print a message stating that accounting is done
	-- Call the procedure to Claim or Unclaim Cenvat do its accounting

        -- if its UNCLAIMED then amount is already uncalimed during DELIVER in do_accounting
	IF (NVL(lv_cenvat_action,'$') <> 'UNCLAIMED' AND ln_diff_re_cenvat_amount <> 0 )
	THEN
          Do_Cenvat_Claim
          ( pn_transaction_id    => rcv_transactions_rec.transaction_id  -- from rcv_transactions
          , pn_shipment_line_id  => rcv_transactions_rec.shipment_line_id  -- from rcv_transactions
          --, pn_cenvat_amount     => ln_diff_re_cenvat_amount ,delete the useless parameter by eric on Jan 24,2008
          , pv_supp_exc_inv_no   => pv_supp_exc_inv_no
          , pd_supp_exc_inv_date => ld_supp_exc_inv_date
          , pn_version_number    => ln_retro_line_changes_version -- current version of the receipt
          , pn_line_change_id    => ln_retro_line_changes_id
          );
          Fnd_File.Put_Line(FND_FILE.LOG,' ');
          Fnd_File.Put_Line(FND_FILE.LOG,'  Do_Cenvat_Claim() Invoked. ');
          Fnd_File.Put_Line(FND_FILE.LOG,' ');

	  --Print a message stating that the receipt cenvat is claimed or unclaimed depending on value of lv_cenvat_action
	ELSE
	  Fnd_File.Put_Line(FND_FILE.LOG,'  Cenvat_action = '|| lv_cenvat_action);
	  Fnd_File.Put_Line(FND_FILE.LOG,'  Diff Cenvat_Amount = '|| ln_diff_re_cenvat_amount);
	  Fnd_File.Put_Line(FND_FILE.LOG,'  Did not invoke DO_CENVAT_CLAIM() subroutine');
	END IF;--(lv_cenvat_action <> 'UNCLAIMED' AND ln_cenvat_amount <> 0 )

	-- Call the procedure to Claim or Unclaim VAT and do its accounting

	IF (NVL(lv_vat_action,'$') <> 'UNCLAIMED' AND ln_diff_re_vat_amount <> 0)
        THEN --if VAT is unclaimed in do_accounting then we should not claim or unclaim
	  Do_Vat_Claim
	  ( pn_transaction_id    => rcv_transactions_rec.transaction_id, -- from rcv_transactions
            pn_shipment_line_id  => rcv_transactions_rec.shipment_line_id, -- from rcv_transactions
            pn_vat_amount        => ln_diff_re_vat_amount,
            pv_supp_vat_inv_no   => pv_supp_vat_inv_no,
            pd_supp_vat_inv_date => ld_supp_vat_inv_date,
            pn_version_number    => ln_retro_line_changes_version -- current version of the receipt
          , pn_line_change_id    => ln_retro_line_changes_id
          );

          Fnd_File.Put_Line(FND_FILE.LOG,' ');
          Fnd_File.Put_Line(FND_FILE.LOG,'  Do_Vat_Claim() Invoked. ');
          Fnd_File.Put_Line(FND_FILE.LOG,' ');

	  --Print a message stating that the receipt vat is claimed or unclaimed depending on value of lv_vat_action
	ELSE
	  Fnd_File.Put_Line(FND_FILE.LOG,'  lv_vat_action = '|| lv_vat_action);
	  Fnd_File.Put_Line(FND_FILE.LOG,'  Diff Vat Amount = '|| ln_diff_re_vat_amount);
	  Fnd_File.Put_Line(FND_FILE.LOG,'  Did not invoke DO_VAT_CLAIM() subroutine');
	END IF;	--(lv_vat_action <> 'UNCLAIMED' AND ln_vat_amount <> 0)

        --Increaset the total processed receipt number;
        ln_receipt_processed_no :=ln_receipt_processed_no+1;
      END IF;	-- IF ( jai_rcv_transactions_rec.process_vat_status IS NULL )

      FND_FILE.PUT_LINE(fnd_file.log, '  The Receipt :'||jai_rcv_lines_rec.receipt_num||' processing is  done.');
      FND_FILE.PUT_LINE(fnd_file.log, '  End loop through the RECEIVE transactions,Transaction id is    : ' ||rcv_transactions_rec.transaction_id);
      FND_FILE.PUT_LINE(fnd_file.log, '  ++');
    END LOOP; --rcv_transactions_rec IN get_rcv_transactions_cur

    IF (ln_skip_rcpt_cnt =0)
    THEN
      UPDATE
        jai_retro_line_changes
      SET
        receipt_processed_flag = 'Y'
      WHERE
        line_change_id = jai_retro_line_change_rec.line_change_id;
    END IF; -- (ln_skip_rcpt_cnt =0)

    --increase the number of total receipt processed
    ln_tot_receipt_processed_no := ln_tot_receipt_processed_no + ln_receipt_processed_no ;

    FND_FILE.PUT_LINE(fnd_file.log, 'Total receipt number for current shipment is: '||ln_tot_receipt_no);
    FND_FILE.PUT_LINE(fnd_file.log, 'Total processed receipt for current shipment number is: '||ln_receipt_processed_no);
    FND_FILE.PUT_LINE(fnd_file.log, 'End loop for the shipment line, line_change_id ='||jai_retro_line_change_rec.line_change_id );
    FND_FILE.PUT_LINE(fnd_file.log, '++++');
  END LOOP;--jai_retro_line_change_rec IN get_jai_retro_line_change_cur

  IF ( ln_skip_rcpt_cnt IS NULL OR ln_tot_receipt_processed_no = 0)
  THEN
  	Fnd_File.Put_Line(FND_FILE.LOG,' ');
  	Fnd_File.Put_Line(FND_FILE.LOG,' ');
  	Fnd_File.Put_Line(FND_FILE.LOG,'No valid data found for processing');
  	Fnd_File.Put_Line(FND_FILE.LOG,' ');
  	Fnd_File.Put_Line(FND_FILE.LOG,' ');
  END IF ;
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)  --logging for debug
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  	retcode := 2;
   	errbuf  := Sqlerrm;
    --RAISE;  BUG #6788048
    RETURN;
END Process_Retroactive_Update;

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Price_Changes                     Public
--
--  DESCRIPTION:
--
--    This procedure is used to insert location line history changes
--    when doing retroactive price update.
--
--  PARAMETERS:
--      In: pr_old                lc_rec%TYPE  old line record
--          pr_new                lc_rec%TYPE  new line record
--     Out: pv_process_flag       VARCHAR2     return flag
--          pv_process_message    VARCHAR2     return message
--
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Kevin Cheng  Created
--==========================================================================
PROCEDURE Insert_Price_Changes
( pr_old               IN lc_rec%TYPE
, pr_new               IN lc_rec%TYPE
, pv_process_flag      OUT NOCOPY VARCHAR2
, pv_process_message   OUT NOCOPY VARCHAR2
)
IS
CURSOR cur_loc_line_taxes
IS
SELECT
  jpt.tax_line_no
, jpt.tax_id
, jcta.tax_name
, jcta.tax_type
, jpt.currency
, jpt.tax_amount
, jcta.adhoc_flag
, jpt.modvat_flag
, jpt.vendor_id
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.tax_id = jcta.tax_id
  AND jpt.line_location_id = pr_old.line_location_id;

lv_doc_number              po_headers_all.segment1%TYPE;
ln_vendor_id               po_headers_all.vendor_id%TYPE;
ln_vendor_site_id          po_headers_all.vendor_site_id%TYPE;
ln_item_id                 mtl_system_items_b.inventory_item_id%TYPE;
ln_revision_num            po_headers_all.revision_num%TYPE;
ln_retro_line_changes_id   NUMBER;
ln_retro_tax_changes_id    NUMBER;
lv_third_party_flag        VARCHAR2(1);

BEGIN
  pv_process_flag    := 'SS';
  pv_process_message := '';

  BEGIN
    SELECT
      JAI_RETRO_LINE_CHANGES_S.NEXTVAL
    INTO
      ln_retro_line_changes_id
    FROM dual;
  EXCEPTION
    WHEN no_data_found THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting line sequence.'||SQLERRM;
      RETURN;
    WHEN OTHERS THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting line sequence.'||SQLERRM;
      RETURN;
  END;

  --Get revision number
  BEGIN
    SELECT
      NVL(max(doc_version_number), 0) + 1 /*added max and replaced -1 with 0*/
    INTO
      ln_revision_num
    FROM
      JAI_RETRO_LINE_CHANGES jrlc
    WHERE jrlc.doc_header_id = pr_old.po_header_id
      AND jrlc.doc_line_id = pr_old.po_line_id
      AND jrlc.line_location_id = pr_old.line_location_id /*added by rchandan*/
      AND jrlc.doc_type IN ('RELEASE', 'STANDARD PO');

  EXCEPTION
    WHEN no_data_found THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting revision number.'||SQLERRM;
      RETURN;
    WHEN too_many_rows THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting revision number.'||SQLERRM;
      RETURN;
    WHEN OTHERS THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting revision number.'||SQLERRM;
      RETURN;
  END;

  BEGIN
    SELECT
      item_id
    INTO
      ln_item_id
    FROM
      po_lines_all
    WHERE po_line_id = pr_old.po_line_id;
  EXCEPTION
    WHEN no_data_found THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting line item id.'||SQLERRM;
      RETURN;
    WHEN too_many_rows THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting line item id.'||SQLERRM;
      RETURN;
    WHEN OTHERS THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting line item id.'||SQLERRM;
      RETURN;
  END;

  BEGIN
    IF pr_old.shipment_type = 'STANDARD'
    THEN
        SELECT
        segment1
      , vendor_id
      , vendor_site_id
      INTO
        lv_doc_number
      , ln_vendor_id
      , ln_vendor_site_id
      FROM
        po_headers_all
      WHERE po_header_id = pr_old.from_header_id;

    ELSIF pr_old.shipment_type = 'BLANKET'
    THEN
        SELECT
        segment1
      , vendor_id
      , vendor_site_id
      INTO
        lv_doc_number
      , ln_vendor_id
      , ln_vendor_site_id
      FROM
        po_headers_all
      WHERE po_header_id = pr_old.po_header_id;

    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting agreement relate information.'||SQLERRM;
      RETURN;
    WHEN too_many_rows THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting agreement relate information.'||SQLERRM;
      RETURN;
    WHEN OTHERS THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When getting agreement relate information.'||SQLERRM;
      RETURN;
  END;

  BEGIN
    IF pr_old.shipment_type = 'STANDARD'
    THEN
      INSERT INTO JAI_RETRO_LINE_CHANGES
      ( LINE_CHANGE_ID
      , DOC_TYPE
      , DOC_HEADER_ID
      , DOC_LINE_ID
      , LINE_LOCATION_ID
      , FROM_HEADER_ID
      , FROM_LINE_ID
      , DOC_VERSION_NUMBER
      , PRICE_CHANGE_DATE
      , INVENTORY_ITEM_ID
      , ORGANIZATION_ID
      , ORIGINAL_UNIT_PRICE
      , MODIFIED_UNIT_PRICE
      , RECEIPT_PROCESSED_FLAG
      , EXCISE_ACTION
      , VAT_ACTION
      , EXCISE_INVOICE_NO
      , EXCISE_INVOICE_DATE
      , VAT_INVOICE_NO
      , VAT_INVOICE_DATE
      , RETRO_REQUEST_ID
      , DOC_NUMBER
      , VENDOR_ID
      , VENDOR_SITE_ID
      , CREATION_DATE
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
      , LAST_UPDATED_BY
      , CREATED_BY
      , OBJECT_VERSION_NUMBER
      )
      VALUES
      ( ln_retro_line_changes_id
      , 'STANDARD PO'
      , pr_old.po_header_id
      , pr_old.po_line_id
      , pr_old.line_location_id
      , pr_old.from_header_id
      , pr_old.from_line_id
      , ln_revision_num
      , pr_new.retroactive_date
      , ln_item_id
      , pr_old.ship_to_organization_id
      , pr_old.price_override
      , pr_new.price_override
      , 'N'
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , lv_doc_number
      , ln_vendor_id
      , ln_vendor_site_id
      , SYSDATE
      , SYSDATE
      , fnd_global.login_id
      , fnd_global.user_id
      , fnd_global.user_id
      , NULL
      );
    ELSIF pr_old.shipment_type = 'BLANKET'
    THEN
      INSERT INTO JAI_RETRO_LINE_CHANGES
      ( LINE_CHANGE_ID
      , DOC_TYPE
      , DOC_HEADER_ID
      , DOC_LINE_ID
      , LINE_LOCATION_ID
      , FROM_HEADER_ID
      , FROM_LINE_ID
      , DOC_VERSION_NUMBER
      , PRICE_CHANGE_DATE
      , INVENTORY_ITEM_ID
      , ORGANIZATION_ID
      , ORIGINAL_UNIT_PRICE
      , MODIFIED_UNIT_PRICE
      , RECEIPT_PROCESSED_FLAG
      , EXCISE_ACTION
      , VAT_ACTION
      , EXCISE_INVOICE_NO
      , EXCISE_INVOICE_DATE
      , VAT_INVOICE_NO
      , VAT_INVOICE_DATE
      , RETRO_REQUEST_ID
      , DOC_NUMBER
      , VENDOR_ID
      , VENDOR_SITE_ID
      , CREATION_DATE
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
      , LAST_UPDATED_BY
      , CREATED_BY
      , OBJECT_VERSION_NUMBER
      )
      VALUES
      ( ln_retro_line_changes_id
      , 'RELEASE'
      , pr_old.po_header_id
      , pr_old.po_line_id
      , pr_old.line_location_id
      , pr_old.po_header_id
      , pr_old.po_line_id
      , ln_revision_num
      , pr_new.retroactive_date
      , ln_item_id
      , pr_old.ship_to_organization_id
      , pr_old.price_override
      , pr_new.price_override
      , 'N'
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , lv_doc_number
      , ln_vendor_id
      , ln_vendor_site_id
      , SYSDATE
      , SYSDATE
      , fnd_global.login_id
      , fnd_global.user_id
      , fnd_global.user_id
      , NULL
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pv_process_flag    := 'UE';
      pv_process_message := 'When inserting line change history.'||SQLERRM;
      RETURN;
  END;

  FOR tax_rec IN cur_loc_line_taxes
  LOOP
    BEGIN
      SELECT
        JAI_RETRO_TAX_CHANGES_S.NEXTVAL
      INTO
        ln_retro_tax_changes_id
      FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        pv_process_flag    := 'UE';
        pv_process_message := 'When getting tax line sequence.'||SQLERRM;
        RETURN;
      WHEN OTHERS THEN
        pv_process_flag    := 'UE';
        pv_process_message := 'When getting tax line sequence.'||SQLERRM;
        RETURN;
    END;

    IF tax_rec.vendor_id = ln_vendor_id
    THEN
      lv_third_party_flag := 'N';
    ELSE
      lv_third_party_flag := 'Y';
    END IF;

    BEGIN
      INSERT INTO JAI_RETRO_TAX_CHANGES
      ( TAX_CHANGE_ID
      , LINE_CHANGE_ID
      , TAX_LINE_NO
      , TAX_ID
      , TAX_NAME
      , TAX_TYPE
      , CURRENCY_CODE
      , ORIGINAL_TAX_AMOUNT
      , MODIFIED_TAX_AMOUNT
      , RECOVERABLE_FLAG
      , ADHOC_FLAG
      , THIRD_PARTY_FLAG
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
      , LAST_UPDATED_BY
      , OBJECT_VERSION_NUMBER
      )
      VALUES
      ( ln_retro_tax_changes_id
      , ln_retro_line_changes_id
      , tax_rec.tax_line_no
      , tax_rec.tax_id
      , tax_rec.tax_name
      , tax_rec.tax_type
      , tax_rec.currency
      , tax_rec.tax_amount
      , -99999
      , tax_rec.modvat_flag
      , tax_rec.adhoc_flag
      , lv_third_party_flag
      , SYSDATE
      , fnd_global.user_id
      , SYSDATE
      , fnd_global.login_id
      , fnd_global.user_id
      , NULL
      );
    EXCEPTION
      WHEN OTHERS THEN
        pv_process_flag    := 'UE';
        pv_process_message := 'When inserting tax line change history.'||SQLERRM;
        RETURN;
    END;
  END LOOP;
END Insert_Price_Changes;

--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Price_Changes                     Public
--
--  DESCRIPTION:
--
--    This procedure is used to update tax amount in tax line changes table
--    when doing retroactive price update.
--
--  PARAMETERS:
--      In: pn_tax_amt            NUMBER       updated tax amount
--          pn_line_no            NUMBER       tax line number
--          pn_line_loc_id        NUMBER       line location id
--     Out: pv_process_flag       VARCHAR2     return flag
--          pv_process_message    VARCHAR2     return message
--
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Kevin Cheng  Created
--==========================================================================
PROCEDURE Update_Price_Changes
( pn_tax_amt           IN NUMBER
, pn_line_no           IN NUMBER
, pn_line_loc_id       IN NUMBER
, pv_process_flag      OUT NOCOPY VARCHAR2
, pv_process_message   OUT NOCOPY VARCHAR2
)
IS
BEGIN
  pv_process_flag    := 'SS';
  pv_process_message := '';

  UPDATE
    JAI_RETRO_TAX_CHANGES
  SET
    modified_tax_amount = pn_tax_amt
  , last_update_date  = SYSDATE
  , last_updated_by   = fnd_global.user_id
  , last_update_login = fnd_global.login_id
    WHERE tax_line_no = pn_line_no
      AND line_change_id = (SELECT
                              line_change_id
                            FROM
                              JAI_RETRO_LINE_CHANGES jrpc
                            WHERE jrpc.Line_location_id = pn_line_loc_id
                              AND jrpc.Doc_Type IN ('RELEASE','RECEIPT','STANDARD PO')
                              AND jrpc.Doc_version_number = (SELECT
                                                               MAX(Doc_version_number)
                                                             FROM
                                                               JAI_RETRO_LINE_CHANGES jrpc1
                                                             WHERE jrpc1.Line_location_id = pn_line_loc_id
                                                               AND jrpc1.Doc_Type IN ('RELEASE','RECEIPT','STANDARD PO')
                                                            )
                           );

EXCEPTION
  WHEN OTHERS THEN
    pv_process_flag    := 'UE';
    pv_process_message := 'When updating tax line change history.'||SQLERRM;
END Update_Price_Changes;

END JAI_RETRO_PRC_PKG;

/
