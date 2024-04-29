--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RPT_CFR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RPT_CFR_PVT" AS
--$Header: JMFVCFRB.pls 120.40 2007/11/16 11:18:55 kdevadas ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVCFRB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Body file of the package for creating temporary    |
--|                        data for SHIKYU Confirmation Report.               |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   cfr_before_report_trigger                          |
--|                        get_onhand_components                              |
--|                        get_rpt_confirmation_data                          |
--|                        get_unallocated_components                         |
--|                        get_unallocated_rep_po                             |
--|                        get_rep_po_residual_unalloc                        |
--|                        set_rep_po_residual_unalloc                        |
--|                        set_rcv_transaction_unalloc                        |
--|                        get_unconsumed_components                          |
--|                        get_unconsumed_sub_po                              |
--|                        get_unconsumed_rep_po                              |
--|                        get_sub_po_residual_unconsume                      |
--|                        set_sub_po_residual_unconsume                      |
--|                        set_rcv_transaction_unconsume                      |
--|                        validate_cfr_mid_temp                              |
--|                        add_data_to_cfr_temp                               |
--|                        rpt_get_crude_data                                 |
--|                        rpt_get_Comp_Estimated_data                        |
--|                        rpt_get_SubPO_data                                 |
--|                        rpt_get_UnReceived_data                            |
--|                        rpt_get_Received_data                              |
--|                        rpt_get_Int_data                                   |
--|                        rpt_debug_show_mid_data                            |
--|                        rpt_debug_show_temp_data                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   15-APR-2005          shu  Created.                                      |
--|   10-OCT-2005          shu  Added some output information for debug       |
--|   11-OCT-2005          shu  Modified subcontracting_component column      |
--|                             select criteria.                              |
--|   13-OCT-2005          shu  Modified source code to avoid the warning     |
--|                             message. added debug output code              |
--|   18-NOV-2005          shu  added code for setting request completed with |
--|                             warning if SHIKYU profile is disable          |
--|   05-DEC-2005          shu  Fixed some no data issue due to null columns  |
--|   07-DEC-2005          shu  added procedures rpt_get_xxx for report data  |
--|   21-DEC-2005          shu  tuning SQLperformance in get_onhand_components|
--|   16-JAN-2006          shu  using FND_LOG.STRING for logging standard     |
--|   19-JAN-2006          shu  changed parameter p_currency_conversion_date  |
--|                             from date to varchar2;                        |
--|                             added rpt_debug_show_mid_data procedure       |
--|                             added rpt_debug_show_temp_data procedure      |
--|   26-JAN-2006          shu  fix bug #4997302 for report UOM conversion    |
--|   08-FEB-2006          shu  fix bug #4997302 for date conversion and      |
--|                             reversed Price/Cost conversion                |
--|   14-FEB-2006          shu  fix bug #4997302 for the item cost column     |
--|   13-MAR-2006          amy  remove commented code                         |
--|   19-MAY-2006          amy  updated procedure cfr_before_report_trigger to fix bug #5212686                         |
--|   24-MAY-2006          amy  updated procedure get_onhand_components to fix sqlid#17703607 in bug #5212686                         |
--|   22-JUNE-2006          amy  updated procedure rpt_get_Comp_Estimated_data and  rpt_get_Int_data                          |
--|                                  to fix bug #5231233                         |
--|   26-JUNE-2006          amy  updated procedure get_unconsumed_sub_po AND get_unconsumed_rep_po                         |
--|                                  to fix potensial issue,which occurs when same onhand components are found in different  tp organization                     |
--|   28-JUNE-2006          amy  updated procedure get_unallocated_rep_po                          |
--|                                  to fix potensial issue that some unallocated repPO are lost in the report                     |
--|                                  this issue was found when fixed bug  #5232863                    |
--|   28-JUNE-2006          amy  updated procedure rpt_get_crude_data to fix project_number related issue                          |
--|   19-JUNE-2006          amy  updated to fix bug 5391412                          |
--|                                          Updated procedure  rpt_get_SubPO_data to get all received subPOs(partial or fully)       |
--|                                                       instead of get those subPOs causing onhand Qty               |
--|                                          Renamed original procedure  rpt_get_SubPO_data as rpt_get_SubPO_data_Onhand for future use       |
--|                                                       instead of get those subPOs causing onhand Qty               |
--|                                          Added global variable g_ou_id to pass ou infro to procedure  rpt_get_SubPO_data      |
--|                                          Added global variable CFR_EXT_SUBPO_AFT_ONHAND to identify original subpo data in rpt_temp table      |
--|   28-JUNE-2006          amy  updated procedure  rpt_get_SubPO_data to fix bug 5415777                          |
--|   07-SEP-2006          amy  updated procedure  rpt_get_crude_data to fix bug 5510828(get project id for table sub not from rcv transactions)                          |
--|                                        updated procedure rpt_get_Comp_Estimated_data to fix bug 5510828(insert project_num/task_num information into rpt temp data(100)      |
--|                                        updated procedure rpt_get_SubPo_data to fix bug 5510828(insert project_num/task_num information into rpt temp data(110)      |
--|   18-SEP-2006          amy  updated procedure  get_unallocated_components to fix bug 5509464(get vendor_id/vendor_site_id from repleninshment po information in receiving transaction query)      |
--|                                        updated procedure get_unallocated_rep_po to fix bug 5509464(updated sql query criteria to cover the cases when having some rep POs have corresponding rep SOs        |
--|                                           but are not allocated to a subcontracting po.        |
--|                                        updated procedure rpt_get_crude_data to fix bug 5509464(updated sql query criteria to  cover the cases when having some rep POs have corresponding rep SOs     |
--|                                           but are not allocated to a subcontracting po.        |
--|   28-SEP-2006          amy  updated procedure  get_unallocated_components
--|                                                                    get_unallocated_rep_po      |
--|                                                                    set_rep_po_residual_unalloc      |
--|                                                                    set_rcv_transaction_unalloc      |
--|                                                                    set_sub_po_residual_unconsume      |
--|                                                                    set_rcv_transaction_unconsume      |
--|                                                                     to fix potential issue of operations between null numbers      |
--|   17-NOV-2006          amy  updated procedure cfr_before_report_trigger,  |
--|                             add_data_to_cfr_temp and                      |
--|                             rpt_get_UnReceived_data to fix bug 5583680    |
--|   20-NOV-2006          amy  updated procedure rpt_get_Comp_Estimated_data |
--|                             and rpt_get_Int_data to fix bug 5665445.      |
--|                             The issue was mainly due to the duplicated    |
--|                             conversions of the onhand qty from the        |
--|                             Secondary UOM, which caused the resulting     |
--|                             onhand qty to be much smaller than the actual |
--|                             onhand qty.                                   |
--|   21-NOV-2006         vchu  continued bug fix for bug 5583680:            |
--|                             modified the query in rpt_get_Received_data   |
--|                             to correctly fetched the replenishments       |
--|                             received in past xx days.  Also, replaced     |
--|                             usages of shipping_quantity_uom column of the |
--|                             oe_order_lines_all table by the               |
--|                             order_quantity_uom, since this is the correct |
--|                             uom accompanying the shipped_quantity.        |
--|   21-NOV-2006         vchu  bug fix for 5665334: Changed the signature    |
--|                             of cfr_before_report_trigger to pass in the   |
--|                             ID of the FROM and TO OEM Organization,       |
--|                             instead of the name.  Also added a new helper |
--|                             procedure to get the name of an Inventory     |
--|                             organization given the ID.  This procedure is |
--|                             called in cfr_before_report_trigger in order  |
--|                             to get the name of the TO and FROM            |
--|                             Organization in the current session language. |
--|   08-DEC-2006          amy  bug fix for 5702139: Updated procedure        |
--|                             get_unallocated_rep_po to pass correct uom    |
--|                             jmf_shikyu_allocations.uom to parameter p_current_uom_code |
--|                             when call function get_item_primary_quantity  |
--|                             to convert allocated quantity                 |
--|   11-DEC-2006          amy  bug fix for 5702139: Updated procedure        |
--|                             get_unallocated_rep_po again to pass primary  |
--|                             uom to parameter p_current_uom_code when      |
--|                             the replenishment PO is never allocated to a  |
--|                             subcontracting PO                             |
--|   04-OCT-2007      kdevadas  12.1 Buy/Sell Subcontracting changes         |
--|                              Reference - GBL_BuySell_TDD.doc              |
--|                              Reference - GBL_BuySell_FDD.doc              |
--|   16-NOV-2007      kdevadas  Bug 6630087 - Removed the standard cost check|
--|                              as Buy/Sell subcontracting supports non-std  |
--|                              OEM orgs as well                             |
--+===========================================================================+

  --=============================================
  -- CONSTANTS
  --=============================================
  G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

  --=============================================
  -- GLOBAL VARIABLES
  --=============================================

  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
  --Amy add for fixing bug 5391412 start
  g_ou_id NUMBER:=0;
  --Amy add for fixing bug 5391412 end

  --The report region for confirmation report
  CFR_CRUDE_DATA CONSTANT NUMBER := 10;
  CFR_EXT_COMPONENT CONSTANT NUMBER := 100;
  CFR_EXT_SUBCONTRACT_PO  CONSTANT NUMBER := 110;
  CFR_EXT_UN_RCV          CONSTANT NUMBER := 120;
  CFR_EXT_RCV_IN_DAYS     CONSTANT NUMBER := 130;
  --Amy add for fixing bug 5391412 start
  CFR_EXT_SUBPO_AFT_ONHAND  CONSTANT NUMBER := 140;
  --Amy add for fixing bug 5391412 end
  CFR_INT_COMPONENT CONSTANT NUMBER := 200;

  --the constant for temporary table rowtype identify for confirmation report
  CFR_TMP_ONHAND_ROW             CONSTANT NUMBER := 10; --The onhand information
  CFR_TMP_REP_PO_UNALLOCATED_ROW CONSTANT NUMBER := 20; --The replenishment purchase order unallocated info
  CFR_TMP_REP_PO_UNCONSUMED_ROW  CONSTANT NUMBER := 30; --The replenishment purchase order unconsumed info
  CFR_TMP_SUB_PO_UNCONSUMED_ROW  CONSTANT NUMBER := 40; --The subcontracting purchase order info
  CFR_TMP_RCV_ROW                CONSTANT NUMBER := 50; --The receive transactions info

  --the constant for temporary table get_rcv_flag for confirmation report
  CFR_REP_PO_GET_RCV_FLAG CONSTANT VARCHAR2(1) := 'Y'; --this rep_po line has been used for get_rcv_transactions
  CFR_SUB_PO_GET_REP_FLAG CONSTANT VARCHAR2(1) := 'Y'; --this sub_po line has been used for get_replenishment po

  -- Bug 5665334
  --========================================================================
  -- PROCEDURE : get_organization_name    PUBLIC
  -- PARAMETERS: p_organization_id        Inventory Organization ID
  --           : x_organization_name      Organization Name to be returned
  -- COMMENT   : The procedure returns the name of an Inventory Organization
  --             if the input ID parameter was valid.
  --========================================================================
  PROCEDURE get_organization_name
  ( p_organization_id      IN  NUMBER
  , x_organization_name    OUT NOCOPY VARCHAR2
  )
  IS
  BEGIN

    x_organization_name := NULL;

    IF p_organization_id IS NOT NULL
    THEN
      SELECT name
      INTO   x_organization_name
      FROM   hr_all_organization_units_tl haoutl
      WHERE  haoutl.organization_id = p_organization_id
      AND    haoutl.LANGUAGE = USERENV('LANG');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_organization_name := NULL;

    WHEN OTHERS THEN
      x_organization_name := NULL;

  END get_organization_name;

  --========================================================================
  -- PROCEDURE : cfr_before_report_trigger    PUBLIC
  -- PARAMETERS: p_rpt_mode                       the report mode: External/Internal report
  --           : p_ou_id                      Operating unit id
  --           : p_supplier_name_from         the supplier name from
  --           : p_supplier_name_to           the supplier name to
  --           : p_supplier_site_code_from    the supplier site code from
  --           : p_supplier_site_code_to      the supplier site code to
  --           : p_oem_inv_org_name_from      oem inventory org name from
  --           : p_oem_inv_org_name_to        oem inventory org name to
  --           : p_item_number_from           item number from
  --           : p_item_number_to             item number to
  --           : p_days_received              received after the days ago
  --           : p_sort_by                    By Supplier/Site or By Item,
  --                                          the External report can use only by Supplier/Site
  --           : p_currency_conversion_type   the currency conversion type
  --           : p_currency_conversion_date   the currency conversion date
  -- COMMENT   : this procedure will be called in the before report trigger,
  --             all the other needed procedures will be called in this procedure
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cfr_before_report_trigger
  (
    p_rpt_mode                 IN VARCHAR2
   ,p_ou_id                    IN NUMBER
   ,p_supplier_name_from       IN VARCHAR2
   ,p_supplier_site_code_from  IN VARCHAR2
   ,p_supplier_name_to         IN VARCHAR2
   ,p_supplier_site_code_to    IN VARCHAR2
    -- Bug 5665334
   ,p_oem_inv_org_id_from      IN NUMBER
   ,p_oem_inv_org_id_to        IN NUMBER
   ,p_item_number_from         IN VARCHAR2
   ,p_item_number_to           IN VARCHAR2
   ,p_days_received            IN NUMBER
   ,p_sort_by                  IN VARCHAR2
   ,p_currency_conversion_type IN VARCHAR2
   ,p_currency_conversion_date IN VARCHAR2   --from Report parameter, use VARCHAR2 not DATE
   ,p_functional_currency      IN VARCHAR2
  ) IS

    l_api_name CONSTANT VARCHAR2(30) := 'cfr_before_report_trigger';
    l_currency_conversion_date  DATE;
    --for checking SHIKYU enable profile.
    l_jmf_shk_not_enabled VARCHAR2(240);
    l_conc_succ           BOOLEAN;
    l_functional_currency      gl_ledgers.currency_code%TYPE;

    -- Bug 5665334
    l_oem_inv_org_name_from    hr_all_organization_units_tl.name%TYPE := NULL;
    l_oem_inv_org_name_to      hr_all_organization_units_tl.name%TYPE := NULL;

  BEGIN

    --Amy add for fixing bug 5391412 start
    -- set g_ou_id for rpt_get_subPO_data procedure.
    g_ou_id := p_ou_id;
    --Amy add for fixing bug 5391412 end

    -- Bug 5665334: Get the name of the OEM Organization From and Organization To
    get_organization_name
    ( p_organization_id   => p_oem_inv_org_id_from
    , x_organization_name => l_oem_inv_org_name_from
    );
    get_organization_name
    ( p_organization_id   => p_oem_inv_org_id_to
    , x_organization_name => l_oem_inv_org_name_to
    );

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name || '.begin'
           ,p_message   => 'CVS Version(v 2.26 2006/02/14):' ||
                             ',p_rpt_mode:' ||  p_rpt_mode ||
                             ',p_ou_id :' ||  g_ou_id ||
                             ',p_supplier_name_from:' || p_supplier_name_from ||
                             ',p_supplier_site_code_from:' || p_supplier_site_code_from ||
                             ',p_supplier_name_to :' ||  p_supplier_name_to ||
                             ',p_supplier_site_code_to:' || p_supplier_site_code_to ||
                             ',p_oem_inv_org_id_from:' || p_oem_inv_org_id_from ||
                             ',l_oem_inv_org_name_from:' || l_oem_inv_org_name_from ||
                             ',p_oem_inv_org_id_to:' ||  p_oem_inv_org_id_to ||
                             ',l_oem_inv_org_name_to:' ||  l_oem_inv_org_name_to ||
                             ',p_item_number_from:' ||  p_item_number_from ||
                             ',p_item_number_to:' ||  p_item_number_to ||
                             ',p_days_received:' || p_days_received ||
                             ',p_sort_by:' ||  p_sort_by ||
                             ',p_currency_conversion_type:' ||  p_currency_conversion_type ||
                             ',p_currency_conversion_date:' ||  p_currency_conversion_date ||
                             ',p_functional_currency:' || p_functional_currency
          );
    -- **** for debug information in readonly UT environment.--- end ****

    /*IF p_currency_conversion_date IS NULL */
    /* the input date format like 30-DEC-2005 in the parameter form
      Use fnd_date.canonical_to_date rather than use to_date, as some date formate issue.
    */
    IF p_currency_conversion_date IS NULL
    THEN
        l_currency_conversion_date := SYSDATE;
    ELSE
        l_currency_conversion_date := fnd_date.canonical_to_date(p_currency_conversion_date);
    END IF;

    l_functional_currency := p_functional_currency;
    IF (p_functional_currency IS NULL)
    THEN
        SELECT gl_ledgers.currency_code
          INTO l_functional_currency
          FROM gl_ledgers gl_ledgers
         WHERE gl_ledgers.ledger_id =
            /*   (SELECT DISTINCT xllv.ledger_id
                  FROM xle_le_ou_ledger_v xllv
                 WHERE xllv.operating_unit_id = p_ou_id
                 );*/
                 (select set_of_books_id from hr_operating_units
                  where organization_id = p_ou_id);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'l_functional_currency:' || l_functional_currency ||
                           ',l_currency_conversion_date:' || l_currency_conversion_date
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    --check if the SHIKYU enable profile is set to Yes. if no then return one error and stop.
    IF (NVL(FND_PROFILE.VALUE('JMF_SHK_CHARGE_BASED_ENABLED'), 'N') = 'N')
    THEN
      FND_MESSAGE.SET_NAME('JMF', 'JMF_SHK_NOT_ENABLE');
      l_jmf_shk_not_enabled := FND_MESSAGE.GET;

      fnd_file.PUT_LINE(fnd_file.output, l_jmf_shk_not_enabled);

      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                     ,message => l_jmf_shk_not_enabled);

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        IF l_conc_succ
        THEN
          fnd_log.STRING( FND_LOG.LEVEL_ERROR
                        ,g_module_prefix || l_api_name || '.Warning'
                        ,l_jmf_shk_not_enabled);
        END IF;
      END IF;

      RETURN;
    END IF;

    --clear old data if any
    DELETE FROM JMF_SHIKYU_CFR_MID_TEMP;
    DELETE FROM JMF_SHIKYU_CFR_RPT_TEMP;
    COMMIT;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    --get the on hand components information,with inv_org,item_id
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin, p_rpt_mode:' || p_rpt_mode || ',p_ou_id:' || p_ou_id
          );
    -- **** for debug information in readonly UT environment.--- end ****
    get_onhand_components(p_onhand_row_type         => CFR_TMP_ONHAND_ROW --p_onhand_row_type
                         ,p_ou_id                   => p_ou_id
                         ,p_supplier_name_from      => p_supplier_name_from
                         ,p_supplier_site_code_from => p_supplier_site_code_from
                         ,p_supplier_name_to        => p_supplier_name_to
                         ,p_supplier_site_code_to   => p_supplier_site_code_to
                         ,p_oem_inv_org_name_from   => l_oem_inv_org_name_from  -- Bug 5665334
                         ,p_oem_inv_org_name_to     => l_oem_inv_org_name_to    -- Bug 5665334
                         ,p_item_number_from        => p_item_number_from
                         ,p_item_number_to          => p_item_number_to);

    -- for each record in the onhand information (inv_org, item), get the confirmation data
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin, p_rpt_mode:' || p_rpt_mode || ',p_ou_id:' || p_ou_id
          );
    -- **** for debug information in readonly UT environment.--- end ****
    get_rpt_confirmation_data(p_onhand_row_type            => CFR_TMP_ONHAND_ROW --p_onhand_row_type
                             ,p_rep_po_unalloc_row_type    => CFR_TMP_REP_PO_UNALLOCATED_ROW --p_rep_po_unalloc_row_type
                             ,p_rep_po_unconsumed_row_type => CFR_TMP_REP_PO_UNCONSUMED_ROW --p_rep_po_unconsumed_row_type
                             ,p_sub_po_unconsumed_row_type => CFR_TMP_SUB_PO_UNCONSUMED_ROW --p_sub_po_unconsumed_row_type
                             ,p_rcv_transaction_row_type   => CFR_TMP_RCV_ROW --p_rcv_transaction_row_type
                             ,p_ou_id                      => p_ou_id
                             ,p_days_received              => p_days_received
                             ,p_currency_conversion_type => p_currency_conversion_type
                             ,p_currency_conversion_date => l_currency_conversion_date);


    -- create some data in the mid_temp table to make the data consistent
    validate_cfr_mid_temp(p_rcv_row_type => CFR_TMP_RCV_ROW);

    -- add the find data to temporary table for report, with the UOM Currency conversion
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin, p_rpt_mode:' || p_rpt_mode || ',p_ou_id:' || p_ou_id
          );
    -- **** for debug information in readonly UT environment.--- end ****
    add_data_to_cfr_temp(p_rcv_row_type        => CFR_TMP_RCV_ROW --p_rcv_row_type
                        ,p_rpt_mode            => p_rpt_mode
                        ,p_days_received       => p_days_received
                        ,p_currency_conversion_type  => p_currency_conversion_type
                        ,p_currency_conversion_date  => l_currency_conversion_date
                        ,p_functional_currency => l_functional_currency
						-- Amy added to fix bug 5583680 start
                        ,p_supplier_name_from      => p_supplier_name_from
                        ,p_supplier_site_code_from => p_supplier_site_code_from
                        ,p_supplier_name_to        => p_supplier_name_to
                        ,p_supplier_site_code_to   => p_supplier_site_code_to
                        ,p_oem_inv_org_name_from   => l_oem_inv_org_name_from  -- Bug 5665334
                        ,p_oem_inv_org_name_to     => l_oem_inv_org_name_to    -- Bug 5665334
					    -- Amy added to fix bug 5583680 end
                        );

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'end, p_rpt_mode:' || p_rpt_mode || ',p_ou_id:' || p_ou_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    COMMIT;

    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => NULL
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    rpt_debug_show_temp_data
                            (
                              p_rpt_data_type => NULL
                             ,p_output_to     => 'FND_LOG.STRING'
                            );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --Set message name;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION
                      , G_MODULE_PREFIX || l_api_name || '.no_data'
                      , 'JMF_SHK_RPT_NO_DATA');
      END IF;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.exception'
                      , 'EXCEPTION:WHEN OTHERS THEN');
      END IF;

      ROLLBACK;

  END cfr_before_report_trigger;

  --========================================================================
  -- PROCEDURE : cfr_get_onhand_components    PUBLIC
  -- PARAMETERS: p_onhand_row_type            row type id to identify the
  --                                          onhand components information
  --           : p_ou_id                      Operating unit id
  --           : p_supplier_name_from         the supplier name from
  --           : p_supplier_site_code_from    the supplier site code from
  --           : p_supplier_name_to           the supplier name to
  --           : p_supplier_site_code_to      the supplier site code to
  --           : p_oem_inv_org_name_from      oem inventory org name from
  --           : p_oem_inv_org_name_to        oem inventory org name to
  --           : p_item_number_from           item id from
  --           : p_item_number_to             item id to
  -- COMMENT   : It is used to get all the onhand compoents primary UOM quantity;
  --             (reference to the condition:''Operating Unit, 'from OEM INV organization' ,'to OEM INV organization',
  --             'From supplier','From site','To supplier','To site','From Item','To item')
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_onhand_components
  (
    p_onhand_row_type         IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_supplier_name_from      IN VARCHAR2
   ,p_supplier_site_code_from IN VARCHAR2
   ,p_supplier_name_to        IN VARCHAR2
   ,p_supplier_site_code_to   IN VARCHAR2
   ,p_oem_inv_org_name_from   IN VARCHAR2
   ,p_oem_inv_org_name_to     IN VARCHAR2
   ,p_item_number_from        IN VARCHAR2
   ,p_item_number_to          IN VARCHAR2
  ) IS

    -- cursor for the OEM inventory organization,to get the org_id,org_code,org_name
    -- refer to the org_name from and to condition
    CURSOR l_cur_get_oem_inv_org_info
           (lp_ou_id hr_all_organization_units.organization_id%TYPE
           , lp_oem_inv_org_name_from hr_all_organization_units_vl.NAME%TYPE
           , lp_oem_inv_org_name_to hr_all_organization_units_vl.NAME%TYPE
           ) IS
          SELECT mp.organization_id
                ,mp.organization_code
                ,haoutl.NAME
            FROM mtl_parameters               mp
                ,hr_organization_information  hoi
                ,hr_all_organization_units    haou
                ,HR_ALL_ORGANIZATION_UNITS_TL haoutl
           WHERE mp.organization_id = hoi.organization_id
             AND haou.organization_id = hoi.organization_id
             AND haou.organization_id = haoutl.organization_id
             AND NVL(mp.trading_partner_org_flag,'N') = 'N'
             AND hoi.org_information_context = 'Accounting Information'
             AND hoi.org_information3 = lp_ou_id
             AND haoutl.NAME >= NVL(lp_oem_inv_org_name_from
                                   ,haoutl.NAME)
             AND haoutl.NAME <= NVL(lp_oem_inv_org_name_to
                                   ,haoutl.NAME)
             AND haoutl.LANGUAGE = USERENV('LANG');

    l_oem_inv_org_id   mtl_parameters.organization_id%TYPE;
    l_oem_inv_org_code mtl_parameters.organization_code%TYPE;
    l_oem_inv_org_name hr_all_organization_units_vl.NAME%TYPE;

    -- need to be cleared, how to know the restriction from the oem_inv_org and supplier/site
    -- cursor for geting tp_inv_org_id using the specific oem_inv_org_id, supplier/site
    CURSOR l_cur_get_tp_inv_org_info
      ( lp_oem_inv_org_id mtl_interorg_parameters.from_organization_id%TYPE
      , lp_supplier_name_from po_vendors.vendor_name%TYPE
      , lp_supplier_name_to po_vendors.vendor_name%TYPE
      , lp_supplier_site_code_from po_vendor_sites_all.vendor_site_code%TYPE
      , lp_supplier_site_code_to po_vendor_sites_all.vendor_site_code%TYPE
      )
      IS
      SELECT mip.to_organization_id --tp_org_id
            ,mp.organization_code --tp_org_code
            ,pv.vendor_id --supplier_id
            ,pvs.vendor_site_id --supplier_site_id
        FROM mtl_interorg_parameters     mip
            ,po_vendors                  pv
            ,po_vendor_sites_all         pvs
            ,hr_organization_information hoi
            ,mtl_parameters              mp
       WHERE mip.from_organization_id = lp_oem_inv_org_id
        --AND mip.shikyu_enabled_flag = 'Y'
         AND mip.subcontracting_type in ('B','C') -- 12.1 Buy/Sell Subcontracting Changes
         AND mp.trading_partner_org_flag = 'Y' --hide for test as there is not data for this column!!!
         AND hoi.org_information_context = 'Customer/Supplier Association' --to identify the flexfield
         AND hoi.org_information3 = pv.vendor_id --(Application : Human Resources,Descriptive Flexfield Segment Title: Org Developer DF.)
         AND hoi.org_information4 = pvs.vendor_site_id
         AND mip.to_organization_id = hoi.organization_id
         AND mip.to_organization_id = mp.organization_id
         AND ((pv.vendor_name IS NULL) OR
             ((pv.vendor_name >= NVL(lp_supplier_name_from
                                     ,pv.vendor_name)) AND
             (pv.vendor_name <= NVL(lp_supplier_name_to
                                     ,pv.vendor_name))))
         AND ((pvs.vendor_site_code IS NULL) OR
             (pvs.vendor_site_code >=
             NVL(lp_supplier_site_code_from
                  ,pvs.vendor_site_code)) AND
             (pvs.vendor_site_code <=
             NVL(lp_supplier_site_code_to
                  ,pvs.vendor_site_code)));

    l_tp_inv_org_id    mtl_parameters.organization_id%TYPE;
    l_tp_inv_org_code  mtl_parameters.organization_code%TYPE;
    l_supplier_id      po_vendors.vendor_id%TYPE;
    l_supplier_site_id po_vendor_sites_all.vendor_site_id%TYPE;

    l_api_name CONSTANT VARCHAR2(30) := 'get_onhand_components';

  BEGIN

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_onhand_row_type:' ||  p_onhand_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_name_from:' || p_supplier_name_from ||
                             ',p_supplier_site_code_from:' || p_supplier_site_code_from ||
                             ',p_supplier_name_to :' ||  p_supplier_name_to ||
                             ',p_supplier_site_code_to:' || p_supplier_site_code_to ||
                             ',p_oem_inv_org_name_from:' || p_oem_inv_org_name_from ||
                             ',p_oem_inv_org_name_to:' ||  p_oem_inv_org_name_to ||
                             ',p_item_number_from:' ||  p_item_number_from ||
                             ',p_item_number_to:' ||  p_item_number_to
          );
    -- **** for debug information in readonly UT environment.--- end ****

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;

    --get the oem_inv_org information, then for each oem_inv_org, find the TP inv_org
    OPEN l_cur_get_oem_inv_org_info(p_ou_id
                                   ,p_oem_inv_org_name_from
                                   ,p_oem_inv_org_name_to);
    LOOP
      --find the oem organizations
      FETCH l_cur_get_oem_inv_org_info
        INTO l_oem_inv_org_id, l_oem_inv_org_code, l_oem_inv_org_name;

      EXIT WHEN l_cur_get_oem_inv_org_info%NOTFOUND; -- no more oem organiztions
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => ',l_oem_inv_org_id:' ||  l_oem_inv_org_id ||
                               ',l_oem_inv_org_code :' ||  l_oem_inv_org_code ||
                               ',l_oem_inv_org_name:' || l_oem_inv_org_name
            );
      -- **** for debug information in readonly UT environment.--- end ****

      --process for this oem_inv_org
      --find the tp_inv_orgs that belongs to the oem_inv_org and supplier/sites
      OPEN l_cur_get_tp_inv_org_info(l_oem_inv_org_id
                                    ,p_supplier_name_from
                                    ,p_supplier_name_to
                                    ,p_supplier_site_code_from
                                    ,p_supplier_site_code_to);
      LOOP
        --find the tp organizations
        FETCH l_cur_get_tp_inv_org_info
          INTO l_tp_inv_org_id, l_tp_inv_org_code, l_supplier_id, l_supplier_site_id;

        EXIT WHEN l_cur_get_tp_inv_org_info%NOTFOUND; -- no more tp organiztions
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => ',l_tp_inv_org_id:' ||  l_tp_inv_org_id ||
                                 ',l_tp_inv_org_code :' ||  l_tp_inv_org_code ||
                                 ',l_supplier_id:' || l_supplier_id ||
                                 ',l_supplier_site_id' ||  l_supplier_site_id
              );
        -- **** for debug information in readonly UT environment.--- end ****

        -- get the onhand quantity for each TP inv org items.
        -- for the specified tp_inv_org_id, find the items
        -- insert the data into the mid temp table,
        --???using the get_item_number function to get the flexfield values, or using segment1 for hardcoding?
        INSERT INTO jmf_shikyu_cfr_mid_temp
          (row_type --onhand row type
          ,oem_inv_org_id --oem_inv_org_id
          ,supplier_id --supplier_id
          ,site_id --site_id
          ,tp_inv_org_id --tp_inv_org_id
          ,item_id --item_id
          ,primary_unconsumed_quantity --onhand primary uom quantity
          ,project_id --project_id
          ,task_id --task_id
           )
          SELECT p_onhand_row_type
                ,l_oem_inv_org_id
                ,l_supplier_id
                ,l_supplier_site_id
                ,onhand.organization_id
                ,onhand.inventory_item_id
                ,SUM(onhand.transaction_quantity) primary_uom_qty
                ,onhand.project_id
                ,onhand.task_id
            FROM MTL_ONHAND_QUANTITIES  onhand
                ,MTL_SYSTEM_ITEMS_B_KFV item_f -- the latest view for the item flexfield
           WHERE onhand.organization_id = l_tp_inv_org_id
             AND onhand.organization_id = item_f.organization_id
             AND onhand.inventory_item_id = item_f.inventory_item_id
             AND item_f.subcontracting_component IS NOT NULL --= 'Y'
/*             AND item_f.concatenated_segments >=
                 NVL(p_item_number_from, item_f.concatenated_segments)
             AND item_f.concatenated_segments <=
                 NVL(p_item_number_to, item_f.concatenated_segments)*/
             AND (p_item_number_from IS NULL
                     OR item_f.concatenated_segments >= p_item_number_from)
             AND (p_item_number_to IS NULL
                     OR item_f.concatenated_segments <= p_item_number_to)
             GROUP BY onhand.organization_id
                   ,onhand.inventory_item_id
                   ,onhand.project_id
                   ,onhand.task_id;
      END LOOP; --end loop of finding the tp organizations
      CLOSE l_cur_get_tp_inv_org_info;

    END LOOP; --end loop of finding the oem organizations
    CLOSE l_cur_get_oem_inv_org_info;

    COMMIT; -- for debug on UT ?????
    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_onhand_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --Set message name;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'NO_DATA_FOUND'
            );
      -- **** for debug information in readonly UT environment.--- end ****

    WHEN OTHERS THEN
      -- raise log message;

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.exception'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'OTHERS'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_onhand_components;

  --========================================================================
  -- PROCEDURE : get_rpt_confirmation_data    PUBLIC
  -- PARAMETERS: p_onhand_row_type            row type id to identify the
  --                                          onhand components information
  --           : p_rep_po_unalloc_row_type    replenishment po unalloc row in mid-temp table
  --           : p_rep_po_unconsumed_row_type replenishment po unconsume row in mid-temp table
  --           : p_sub_po_unconsumed_row_type subcontract po unconsume row in mid-temp table
  --           : p_days_received              received after the days ago
  --           : p_sort_by                    By Supplier/Site or By Item, the External report can use only by Supplier/Site
  --           : p_currency_conversion_type   the currency conversion type
  --           : p_currency_conversion_date   the currency conversion date
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  --             first the unallocated qty,then the allocated but unconsumed qty.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_rpt_confirmation_data
  (
    p_onhand_row_type            IN NUMBER
   ,p_rep_po_unalloc_row_type    IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_days_received              IN NUMBER
   ,p_currency_conversion_type IN VARCHAR2
   ,p_currency_conversion_date IN DATE
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_rpt_confirmation_data';

    l_supplier_id      jmf_shikyu_cfr_mid_temp.supplier_id%TYPE;
    l_supplier_site_id jmf_shikyu_cfr_mid_temp.site_id%TYPE;
    l_oem_inv_org_id   jmf_shikyu_cfr_mid_temp.oem_inv_org_id%TYPE;
    l_tp_inv_org_id    jmf_shikyu_cfr_mid_temp.tp_inv_org_id%TYPE;
    l_item_id          jmf_shikyu_cfr_mid_temp.item_id%TYPE;
    l_project_id       jmf_shikyu_cfr_mid_temp.project_id%TYPE;
    l_task_id          jmf_shikyu_cfr_mid_temp.task_id%TYPE;
    l_onhand_quantity  jmf_shikyu_cfr_mid_temp.primary_unconsumed_quantity%TYPE;
    -- get on hand components information
    CURSOR l_cur_get_onhand_components IS
      SELECT supplier_id
            ,site_id
            ,oem_inv_org_id
            ,tp_inv_org_id
            ,item_id
            ,project_id
            ,task_id
            ,primary_unconsumed_quantity
        FROM jmf_shikyu_cfr_mid_temp
       WHERE row_type = p_onhand_row_type;

  BEGIN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_onhand_row_type:' ||  p_onhand_row_type ||
                             ',p_rep_po_unalloc_row_type :' ||  p_rep_po_unalloc_row_type ||
                             ',p_rep_po_unconsumed_row_type:' || p_rep_po_unconsumed_row_type ||
                             ',p_sub_po_unconsumed_row_type:' || p_sub_po_unconsumed_row_type ||
                             ',p_rcv_transaction_row_type :' ||  p_rcv_transaction_row_type ||
                             ',p_ou_id:' || p_ou_id ||
                             ',p_days_received:' || p_days_received ||
                             ',p_currency_conversion_type:' ||  p_currency_conversion_type ||
                             ',p_currency_conversion_date:' ||  p_currency_conversion_date
          );
    -- **** for debug information in readonly UT environment.--- end ****

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    OPEN l_cur_get_onhand_components;
    LOOP
      --find unallocated and allocated but unconsumed rcv_transactions for the inv_org,item.
      FETCH l_cur_get_onhand_components
        INTO l_supplier_id, l_supplier_site_id, l_oem_inv_org_id, l_tp_inv_org_id, l_item_id, l_project_id, l_task_id, l_onhand_quantity;

      EXIT WHEN l_cur_get_onhand_components%NOTFOUND;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => ',l_supplier_id:' ||  l_supplier_id ||
                               ',l_supplier_site_id :' ||  l_supplier_site_id ||
                               ',l_oem_inv_org_id:' || l_oem_inv_org_id ||
                               ',l_tp_inv_org_id:' || l_tp_inv_org_id ||
                               ',l_item_id :' ||  l_item_id ||
                               ',l_project_id:' || l_project_id ||
                               ',l_task_id:' || l_task_id ||
                               ',l_onhand_quantity:' ||  l_onhand_quantity
            );
      -- **** for debug information in readonly UT environment.--- end ****

      --get the unallocated rcv_transactions
      get_unallocated_components(p_rep_po_unalloc_row_type  => p_rep_po_unalloc_row_type
                                ,p_rcv_transaction_row_type => p_rcv_transaction_row_type
                                ,p_ou_id                    => p_ou_id
                                ,p_supplier_id              => l_supplier_id
                                ,p_supplier_site_id         => l_supplier_site_id
                                ,p_oem_inv_org_id           => l_oem_inv_org_id
                                ,p_tp_inv_org_id            => l_tp_inv_org_id
                                ,p_item_id                  => l_item_id
                                ,p_project_id               => l_project_id
                                ,p_task_id                  => l_task_id
                                ,x_need_to_find_pri_qty     => l_onhand_quantity);

      --get the allocated but unconsumed rcv_transactions
      IF l_onhand_quantity > 0
      THEN
        get_unconsumed_components(p_sub_po_unconsumed_row_type => p_sub_po_unconsumed_row_type
                                 ,p_rep_po_unconsumed_row_type => p_rep_po_unconsumed_row_type
                                 ,p_rcv_transaction_row_type   => p_rcv_transaction_row_type
                                 ,p_ou_id                      => p_ou_id
                                 ,p_supplier_id                => l_supplier_id
                                 ,p_supplier_site_id           => l_supplier_site_id
                                 ,p_oem_inv_org_id             => l_oem_inv_org_id
                                 ,p_tp_inv_org_id              => l_tp_inv_org_id
                                 ,p_item_id                    => l_item_id
                                 ,p_project_id                 => l_project_id
                                 ,p_task_id                    => l_task_id
                                 ,x_need_to_find_pri_qty       => l_onhand_quantity);
      END IF;

      -- record the l_onhand_quantity to column primary_unallocated_quantity
       UPDATE jmf_shikyu_cfr_mid_temp
          SET primary_unallocated_quantity = l_onhand_quantity
        WHERE row_type = p_onhand_row_type
          AND supplier_id = l_supplier_id
          AND site_id = l_supplier_site_id
          AND oem_inv_org_id = l_oem_inv_org_id
          AND tp_inv_org_id = l_tp_inv_org_id
          AND item_id = l_item_id
          AND ((project_id IS NULL) OR (project_id = l_project_id))
          AND ((task_id IS NULL) OR (task_id = l_task_id));

      IF l_onhand_quantity > 0
      THEN
        -- the found onhand quantity has no matched rcv_transactions
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => '** onhand quantity :' || l_onhand_quantity ||', has no matched rcv_transactions'
              );
        -- **** for debug information in readonly UT environment.--- end ****
      END IF;

    END LOOP; -- end of find the onhand information
    CLOSE l_cur_get_onhand_components;

    COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_rpt_confirmation_data;

  --========================================================================
  -- PROCEDURE : get_unallocated_components    PUBLIC
  -- PARAMETERS: p_rep_po_unalloc_row_type    row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : x_need_to_find_pri_qty       the need to find quantity under primary UOM
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe unallocated rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unallocated_components
  (
    p_rep_po_unalloc_row_type  IN NUMBER
   ,p_rcv_transaction_row_type IN NUMBER
   ,p_ou_id                    IN NUMBER
   ,p_supplier_id              IN NUMBER
   ,p_supplier_site_id         IN NUMBER
   ,p_oem_inv_org_id           IN NUMBER
   ,p_tp_inv_org_id            IN NUMBER
   ,p_item_id                  IN NUMBER
   ,p_project_id               IN NUMBER
   ,p_task_id                  IN NUMBER
   ,x_need_to_find_pri_qty     IN OUT NOCOPY NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_unallocated_components';

    -- get rcv_transaction information, rcv_transaction_id, rcv_unprocessed_qty
    -- decrease the rcv quantity processed and logged in the jmf_shikyu_cfr_mid_temp table.
    CURSOR l_cur_get_rcv_transaction_info IS
      SELECT rt.transaction_id
    -- Updated to fix potential issue of operations between null numbers
    --        ,rt.primary_quantity -
            ,NVL(rt.primary_quantity,0) -
             NVL((SELECT SUM(NVL(jscmt_rcv.primary_unallocated_quantity
                               ,0) + NVL(jscmt_rcv.primary_unconsumed_quantity
                                        ,0))
                   FROM jmf_shikyu_cfr_mid_temp jscmt_rcv
                  WHERE jscmt_rcv.row_type = 40
                    AND jscmt_rcv.shikyu_id = rt.transaction_id)
                ,0)
--Added to fix bug 5509464 start
             ,pha.vendor_id --p_supplier_id
             ,pha.vendor_site_id --p_supplier_site_id
--Added to fix bug 5509464 end
        FROM jmf_shikyu_cfr_mid_temp mid
            ,po_line_locations_all   pll
            ,rcv_transactions        rt
--Added to fix bug 5509464 start
            ,po_headers_all pha
--Added to fix bug 5509464 end
       WHERE mid.row_type = p_rep_po_unalloc_row_type
         AND NVL(mid.get_rcv_flag
                ,'N') <> CFR_REP_PO_GET_RCV_FLAG --if the rep_po line have done get rcv process, the get_rcv_flag will be set to 1
         AND mid.shikyu_id = pll.line_location_id
         AND rt.transaction_type = 'RECEIVE'
         AND pll.line_location_id = rt.po_line_location_id
--Added to fix bug 5509464 start
         AND pha.po_header_id=pll.po_header_id
--Added to fix bug 5509464 end
       ORDER BY rt.transaction_date;

    l_rcv_transaction_id          rcv_transactions.transaction_id%TYPE; --for cursor
    l_rcv_unprocessed_primary_qty rcv_transactions.primary_quantity%TYPE; --for cursor
--Added to fix bug 5509464 start
    l_supplier_id          po_headers_all.vendor_id%TYPE; --for cursor
    l_supplier_site_id po_headers_all.vendor_site_id%TYPE; --for cursor
--Added to fix bug 5509464 end

    l_rep_po_residual_pri        rcv_transactions.primary_quantity%TYPE;
    l_rcv_unallocated_pri        rcv_transactions.primary_quantity%TYPE;

  BEGIN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rep_po_unalloc_row_type  :' ||  p_rep_po_unalloc_row_type   ||
                             ',p_rcv_transaction_row_type   :' ||  p_rcv_transaction_row_type    ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;

    --step1:find all the replenishment PO with oem_inv_org,supplier/site,tp_inv_org,item that have unallocated components
    get_unallocated_rep_po(p_rep_po_unalloc_row_type => p_rep_po_unalloc_row_type
                          ,p_ou_id                   => p_ou_id
                          ,p_supplier_id             => p_supplier_id
                          ,p_supplier_site_id        => p_supplier_site_id
                          ,p_oem_inv_org_id          => p_oem_inv_org_id
                          ,p_tp_inv_org_id           => p_tp_inv_org_id
                          ,p_item_id                 => p_item_id
                          ,p_project_id              => p_project_id
                          ,p_task_id                 => p_task_id);
    --step2:find all the received transactions for the all replenishment PO above, based on LIFO receive date
    --
    OPEN l_cur_get_rcv_transaction_info;
    LOOP
      --begin rcv_transaction information
      EXIT WHEN x_need_to_find_pri_qty <= 0;

      FETCH l_cur_get_rcv_transaction_info
--Updated to fix bug 5509464 start
        --INTO l_rcv_transaction_id, l_rcv_unprocessed_primary_qty;
        INTO l_rcv_transaction_id, l_rcv_unprocessed_primary_qty,l_supplier_id,l_supplier_site_id;
--Updated to fix bug 5509464 end

      EXIT WHEN l_cur_get_rcv_transaction_info%NOTFOUND;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'begin:' ||
                               ',x_need_to_find_pri_qty  :' ||  x_need_to_find_pri_qty   ||
                               ',l_rcv_transaction_id   :' ||  l_rcv_transaction_id    ||
                               ',l_rcv_unprocessed_primary_qty :' ||  l_rcv_unprocessed_primary_qty
            );
      -- **** for debug information in readonly UT environment.--- end ****

      --step3:find the possible onhand components(for the unallocated )
      l_rep_po_residual_pri := get_rep_po_residual_unalloc(p_rep_po_unalloc_row_type => p_rep_po_unalloc_row_type
                                                          ,p_ou_id                   => p_ou_id
                                                          ,p_rcv_transaction_id      => l_rcv_transaction_id
--Updated to fix bug 5509464 start
                                                          --,p_supplier_id             => p_supplier_id
                                                          --,p_supplier_site_id        => p_supplier_site_id
                                                          ,p_supplier_id             => l_supplier_id
                                                          ,p_supplier_site_id        => l_supplier_site_id
--Updated to fix bug 5509464 end
                                                          ,p_oem_inv_org_id          => p_oem_inv_org_id
                                                          ,p_tp_inv_org_id           => p_tp_inv_org_id
                                                          ,p_item_id                 => p_item_id
                                                          ,p_project_id              => p_project_id
                                                          ,p_task_id                 => p_task_id); --the quantity for primary uom

      IF l_rep_po_residual_pri > 0
      THEN
        --the possilbe unallocated rcv_transactions primary quantity
        l_rcv_unallocated_pri := jmf_shikyu_rpt_util.get_min3(p_number1 => l_rcv_unprocessed_primary_qty
                                                             ,p_number2 => l_rep_po_residual_pri
                                                             ,p_number3 => x_need_to_find_pri_qty);

        --insert data to rcv_temp marking the processed rcv_transaction,
        set_rcv_transaction_unalloc(p_rcv_row_type        => p_rcv_transaction_row_type
                                   ,p_ou_id               => p_ou_id
                                   ,p_rcv_transaction_id  => l_rcv_transaction_id
                                   ,p_rcv_unallocated_pri => l_rcv_unallocated_pri
--Updated to fix bug 5509464 start
                                    ,p_supplier_id             => p_supplier_id
                                    ,p_supplier_site_id        => p_supplier_site_id
                                    --,l_supplier_id             => p_supplier_id
                                    --,l_supplier_site_id        => p_supplier_site_id
--Updated to fix bug 5509464 end
                                   ,p_oem_inv_org_id      => p_oem_inv_org_id
                                   ,p_tp_inv_org_id       => p_tp_inv_org_id
                                   ,p_item_id             => p_item_id
                                   ,p_project_id          => p_project_id
                                   ,p_task_id             => p_task_id);

        --the residual unallocated quantity for primary quantity
        --update replenishment po residual quantity information
        set_rep_po_residual_unalloc(p_rep_po_unalloc_row_type    => p_rep_po_unalloc_row_type
                                   ,p_rcv_transaction_row_type   => p_rcv_transaction_row_type
                                   ,p_ou_id                      => p_ou_id
                                   ,p_rcv_transaction_id         => l_rcv_transaction_id
--Updated to fix bug 5509464 start
                                   --,p_supplier_id             => p_supplier_id
                                   --,p_supplier_site_id        => p_supplier_site_id
                                   ,p_supplier_id             => l_supplier_id
                                   ,p_supplier_site_id        => l_supplier_site_id
--Updated to fix bug 5509464 end
                                   ,p_oem_inv_org_id             => p_oem_inv_org_id
                                   ,p_tp_inv_org_id              => p_tp_inv_org_id
                                   ,p_item_id                    => p_item_id
                                   ,p_project_id                 => p_project_id
                                   ,p_task_id                    => p_task_id
                                   ,p_new_rep_po_unallocated_pri => l_rcv_unallocated_pri);
        --update the need to find primary quantity
        x_need_to_find_pri_qty := x_need_to_find_pri_qty -
                                  l_rcv_unallocated_pri;

      END IF;

    END LOOP; -- end of find the rcv_transaction information
    CLOSE l_cur_get_rcv_transaction_info;

    --step4:update the get_rcv_flags for the rep_po lines, move to above, need the sucess status
    COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;
    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.exception'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_unallocated_components;

  --========================================================================
  -- PROCEDURE : get_unallocated_rep_po    PUBLIC ,get_unallocated_replenishment_po
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_ou_id                      the operating unit id
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order that have unallocated receipts for the item
  --             and insert the result to mid temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unallocated_rep_po
  (
    p_rep_po_unalloc_row_type IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_supplier_id             IN NUMBER
   ,p_supplier_site_id        IN NUMBER
   ,p_oem_inv_org_id          IN NUMBER
   ,p_tp_inv_org_id           IN NUMBER
   ,p_item_id                 IN NUMBER
   ,p_project_id              IN NUMBER
   ,p_task_id                 IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_unallocated_rep_po';

  BEGIN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rep_po_unalloc_row_type:' ||  p_rep_po_unalloc_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;

    -- the allocated quantity for one po line_location_id, change the UOM in po and shikyu allocation to primary UOM
    -- only insert the rep_po that not in mid temp table, if in the table already, keep the data.
    INSERT INTO jmf_shikyu_cfr_mid_temp
      (row_type
      ,shikyu_id
      ,uom
      ,primary_uom
      ,primary_unallocated_quantity
      ,supplier_id
      ,site_id
      ,oem_inv_org_id
      ,tp_inv_org_id
      ,item_id)
     SELECT p_rep_po_unalloc_row_type
           ,plla.line_location_id
           ,uom_tl.uom_code
           ,JMF_SHIKYU_RPT_UTIL.get_item_primary_uom_code(p_tp_inv_org_id
                                                         ,p_item_id)
           ,JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(p_tp_inv_org_id
                                                         ,pla.item_id
                                                         ,uom_tl.uom_code
    -- Updated to fix potential issue of operations between null numbers
                                                         -- ,plla.quantity_received) -
                                                         ,NVL(plla.quantity_received,0)) -
            (SELECT SUM(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(jsr.tp_organization_id
                                                                     ,jsr.shikyu_component_id
                                                                     -- fix bug 5702139
                                                                     -- ,uom_tl_s.uom_code
                                                                     ,decode(jsa.allocated_quantity
                                                                     				,null
                                                                     				,uom_tl_s.uom_code
                                                                     				,jsa.uom)
--Updated to fix bug 5509464 start
                                                                     --,jsa.allocated_quantity)) pll_allocated
                                                                     ,nvl(jsa.allocated_quantity,0))) pll_allocated
--Updated to fix bug 5509464 end
               FROM jmf_shikyu_allocations    jsa
                   ,jmf_shikyu_replenishments jsr
                   ,MTL_UNITS_OF_MEASURE_TL uom_tl_s
--Updated to fix bug 5509464 start
              --WHERE jsa.replenishment_so_line_id = jsr.replenishment_so_line_id
              --  AND jsa.shikyu_component_id = jsr.shikyu_component_id
              WHERE jsa.replenishment_so_line_id(+) = jsr.replenishment_so_line_id
                AND jsa.shikyu_component_id(+) = jsr.shikyu_component_id
--Updated to fix bug 5509464 end
                AND jsr.replenishment_po_shipment_id = plla.line_location_id
                AND plla.po_line_id = pla.po_line_id
                AND uom_tl_s.LANGUAGE = USERENV('LANG')
                -- fix bug 5702139
                -- AND pla.unit_meas_lookup_code = uom_tl_s.unit_of_measure
                AND po_uom_s.get_primary_uom(pla.item_id,p_tp_inv_org_id,null) = uom_tl_s.unit_of_measure -- primary UOM
                AND jsr.shikyu_component_id = p_item_id) residual_unallocated_pri
           ,pha.vendor_id --p_supplier_id
           ,pha.vendor_site_id --p_supplier_site_id
           ,p_oem_inv_org_id
           ,p_tp_inv_org_id
           ,p_item_id
       FROM po_headers_all          pha
           ,po_lines_all            pla
           ,po_line_locations_all   plla
           ,MTL_UNITS_OF_MEASURE_TL uom_tl
           ,HR_ORGANIZATION_INFORMATION hoi -- Add this table to get information of oem
      WHERE pla.po_header_id = pha.po_header_id
        AND plla.po_line_id = pla.po_line_id
        AND pla.unit_meas_lookup_code = uom_tl.unit_of_measure
        AND uom_tl.LANGUAGE = USERENV('LANG')
        AND pha.org_id = p_ou_id
        AND hoi.ORGANIZATION_ID = p_oem_inv_org_id
        AND hoi.org_information_context = 'Customer/Supplier Association' --to identify the flexfield
        AND ((pha.vendor_id = hoi.org_information3) OR -- when org_information_context is set to be 'Customer/Supplier Association',this identify the supplier_id of org
            (pha.vendor_id IS NULL AND hoi.org_information3 IS NULL))
        AND ((pha.vendor_site_id = hoi.org_information4) OR -- when org_information_context is set to be 'Customer/Supplier Association',this identify the supplier_site_id of org
            (pha.vendor_site_id IS NULL AND hoi.org_information4 IS NULL))
        AND pla.item_id = p_item_id
        AND plla.line_location_id NOT IN
            (SELECT jscmt.shikyu_id
               FROM jmf_shikyu_cfr_mid_temp jscmt
              WHERE jscmt.row_type = p_rep_po_unalloc_row_type
                AND jscmt.item_id = p_item_id
                AND jscmt.oem_inv_org_id = p_oem_inv_org_id
                AND jscmt.tp_inv_org_id = p_tp_inv_org_id
                AND jscmt.supplier_id = p_supplier_id
                AND jscmt.site_id = p_supplier_site_id)
--updated to fix bug 5232863 start
--        AND JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(pha.org_id
        AND JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(p_tp_inv_org_id
                                                         ,pla.item_id
                                                         ,uom_tl.uom_code
    -- Updated to fix potential issue of operations between null numbers
                                                         -- ,plla.quantity_received) >
                                                         ,NVL(plla.quantity_received,0)) >
--            (SELECT SUM(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(jsr.tp_organization_id
            (SELECT SUM(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(p_tp_inv_org_id
--updated to fix bug 5232863 end
                                                                     ,jsr.shikyu_component_id
                                                                     -- fix bug 5702139
                                                                     -- ,uom_tl_s.uom_code
                                                                     ,decode(jsa.allocated_quantity
                                                                     				,null
                                                                     				,uom_tl_s.uom_code
                                                                     				,jsa.uom)
--Updated to fix bug 5509464 start
                                                                     --,jsa.allocated_quantity)) pll_allocated
                                                                     ,nvl(jsa.allocated_quantity,0))) pll_allocated
--Updated to fix bug 5509464 end
               FROM jmf_shikyu_allocations    jsa
                   ,jmf_shikyu_replenishments jsr
                   ,MTL_UNITS_OF_MEASURE_TL uom_tl_s
--Updated to fix bug 5509464 start
              --WHERE jsa.replenishment_so_line_id = jsr.replenishment_so_line_id
              --  AND jsa.shikyu_component_id = jsr.shikyu_component_id
              WHERE jsa.replenishment_so_line_id(+) = jsr.replenishment_so_line_id
                AND jsa.shikyu_component_id(+)  = jsr.shikyu_component_id
--Updated to fix bug 5509464 end
                AND jsr.replenishment_po_shipment_id = plla.line_location_id
                AND plla.po_line_id = pla.po_line_id
                -- fix bug 5702139
                -- AND pla.unit_meas_lookup_code = uom_tl_s.unit_of_measure
                AND po_uom_s.get_primary_uom(pla.item_id,p_tp_inv_org_id,null) = uom_tl_s.unit_of_measure -- primary UOM
                AND jsr.shikyu_component_id = p_item_id);

    --update the residual_unallocated(quantity) column under UOM.
    UPDATE jmf_shikyu_cfr_mid_temp
       SET quantity = NVL(primary_unallocated_quantity,0) *
                      JMF_SHIKYU_RPT_UTIL.po_uom_convert_p(primary_uom
                                                          ,uom
                                                          ,item_id)
     WHERE row_type = p_rep_po_unalloc_row_type
       AND quantity IS NULL --only for those do not get the primary uom
       AND supplier_id = p_supplier_id
       AND site_id = p_supplier_site_id
       AND oem_inv_org_id = p_oem_inv_org_id
       AND tp_inv_org_id = p_tp_inv_org_id
       AND item_id = p_item_id;
    COMMIT; -- for debug on UT ?????

    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_rep_po_unalloc_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_unallocated_rep_po;

  --========================================================================
  -- FUNCTION  : get_rep_po_residual_unalloc    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order residual unallocated quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rep_po_residual_unalloc
  (
    p_rep_po_unalloc_row_type IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_rcv_transaction_id      IN NUMBER
   ,p_supplier_id             IN NUMBER
   ,p_supplier_site_id        IN NUMBER
   ,p_oem_inv_org_id          IN NUMBER
   ,p_tp_inv_org_id           IN NUMBER
   ,p_item_id                 IN NUMBER
   ,p_project_id              IN NUMBER
   ,p_task_id                 IN NUMBER
  ) RETURN NUMBER IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_rep_po_residual_unalloc';

    l_rep_po_unallocated_pri rcv_transactions.primary_quantity%TYPE;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rep_po_unalloc_row_type:' ||  p_rep_po_unalloc_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_rcv_transaction_id' || p_rcv_transaction_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    SELECT cfr_mid.primary_unallocated_quantity
      INTO l_rep_po_unallocated_pri
      FROM jmf_shikyu_cfr_mid_temp cfr_mid
          ,po_line_locations_all   poloc
          ,rcv_transactions        rcv
     WHERE rcv.transaction_type = 'RECEIVE'
       AND poloc.line_location_id = rcv.po_line_location_id
       AND cfr_mid.shikyu_id = poloc.line_location_id
       AND rcv.transaction_id = P_rcv_transaction_id
       AND cfr_mid.supplier_id = p_supplier_id
       AND cfr_mid.site_id = p_supplier_site_id
       AND cfr_mid.oem_inv_org_id = p_oem_inv_org_id
       AND cfr_mid.tp_inv_org_id = p_tp_inv_org_id
       AND cfr_mid.item_id = p_item_id
       AND cfr_mid.row_type = p_rep_po_unalloc_row_type
       AND rownum = 1;
    COMMIT; -- for debug on UT ?????
    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_rep_po_unalloc_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
    RETURN l_rep_po_unallocated_pri;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;
      l_rep_po_unallocated_pri := 0;
      RETURN l_rep_po_unallocated_pri;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'Exception: ' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****
      l_rep_po_unallocated_pri := 0;
      RETURN l_rep_po_unallocated_pri;

  END get_rep_po_residual_unalloc;

  --========================================================================
  -- PROCEDURE : set_rep_po_residual_unalloc    PUBLIC ,set_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_rep_po_id                  row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order residual unallocated quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rep_po_residual_unalloc
  (
    p_rep_po_unalloc_row_type    IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,p_new_rep_po_unallocated_pri IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'set_rep_po_residual_unalloc';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rep_po_unalloc_row_type:' ||  p_rep_po_unalloc_row_type ||
                             ',p_rcv_transaction_row_type:' ||  p_rcv_transaction_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_rcv_transaction_id' || p_rcv_transaction_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_new_rep_po_unallocated_pri:' ||  p_new_rep_po_unallocated_pri ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    UPDATE jmf_shikyu_cfr_mid_temp
    -- Updated to fix potential issue of operations between null numbers
       --SET quantity                     = quantity -
       --                                   (quantity *
       SET quantity                     = NVL(quantity,0) -
                                          (NVL(quantity,0) *
                                          p_new_rep_po_unallocated_pri /
                                          primary_unallocated_quantity) --residual_unallocated for the UOM
    -- Updated to fix potential issue of operations between null numbers
    --      ,primary_unallocated_quantity = primary_unallocated_quantity -
          ,primary_unallocated_quantity = NVL(primary_unallocated_quantity,0) -
                                          p_new_rep_po_unallocated_pri --residual_unallocated for the primary UOM
     WHERE row_type = p_rep_po_unalloc_row_type
       AND supplier_id = p_supplier_id
       AND site_id = p_supplier_site_id
       AND oem_inv_org_id = p_oem_inv_org_id
       AND tp_inv_org_id = p_tp_inv_org_id
       AND item_id = p_item_id
       AND shikyu_id =
           (SELECT rcv.po_line_location_id
              FROM rcv_transactions rcv
             WHERE rcv.transaction_id = p_rcv_transaction_id
                   AND rcv.transaction_type = 'RECEIVE');

     /*
       TODO: owner="sunwa" created="2005-11-27"
       text="how to deal with if the quantity less then 0"
       */
    COMMIT; -- for debug on UT ?????
    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_rep_po_unalloc_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END set_rep_po_residual_unalloc;

  --========================================================================
  -- PROCEDURE : set_rcv_transaction_unalloc    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_rcv_unallocated_pri        the rcv unallocated quantity for primary uom
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : update the replenishment po receive transaction unallocated information for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rcv_transaction_unalloc
  (
    p_rcv_row_type        IN NUMBER
   ,p_ou_id               IN NUMBER
   ,p_rcv_transaction_id  IN NUMBER
   ,p_rcv_unallocated_pri IN NUMBER
   ,p_supplier_id         IN NUMBER
   ,p_supplier_site_id    IN NUMBER
   ,p_oem_inv_org_id      IN NUMBER
   ,p_tp_inv_org_id       IN NUMBER
   ,p_item_id             IN NUMBER
   ,p_project_id          IN NUMBER
   ,p_task_id             IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'set_rcv_transaction_unalloc';

    l_jmf_cfr_mid_temp_rcv_rows NUMBER;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rcv_row_type:' ||  p_rcv_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_rcv_transaction_id' || p_rcv_transaction_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_rcv_unallocated_pri:' ||  p_rcv_unallocated_pri ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    --????
    SELECT COUNT(*)
      INTO l_jmf_cfr_mid_temp_rcv_rows
      FROM jmf_shikyu_cfr_mid_temp
     WHERE row_type = p_rcv_row_type
       AND shikyu_id = p_rcv_transaction_id;
    --find if there is a rcv_transaction line exist
    IF l_jmf_cfr_mid_temp_rcv_rows = 1 --Found one row
    THEN
      --update if exist
      UPDATE jmf_shikyu_cfr_mid_temp
    -- Updated to fix potential issue of operations between null numbers
--         SET primary_unallocated_quantity = primary_unallocated_quantity +
         SET primary_unallocated_quantity = NVL(primary_unallocated_quantity,0) +
                                            p_rcv_unallocated_pri
       WHERE row_type = p_rcv_row_type
         AND shikyu_id = p_rcv_transaction_id;
    ELSE
      --NOTFOUND
      --add if not exist
      INSERT INTO jmf_shikyu_cfr_mid_temp
        (row_type
        ,shikyu_id
        ,primary_unallocated_quantity
        ,oem_inv_org_id
        ,tp_inv_org_id
        ,item_id
        ,supplier_id
        ,site_id)
      VALUES
        (p_rcv_row_type
        ,p_rcv_transaction_id
        ,p_rcv_unallocated_pri
        ,p_oem_inv_org_id
        ,p_tp_inv_org_id
        ,p_item_id
        ,p_supplier_id
        ,p_supplier_site_id);
    END IF;
    COMMIT; -- for debug on UT ?????
    --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_rcv_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END set_rcv_transaction_unalloc;

  --========================================================================
  -- PROCEDURE : get_unconsumed_components    PUBLIC
  -- PARAMETERS: p_sub_po_unconsumed_row_type row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : x_need_to_find_pri_qty       the need to find quantity under primary UOM
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe allocated but unconsumed rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_components
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,x_need_to_find_pri_qty       IN OUT NOCOPY NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_unconsumed_components';

    -- get rcv_transaction information, rcv_transaction_id, rcv_unprocessed_qty, from subcontract order, via the replenishment po
    /*
    TODO: owner="sunwa" created="2005-11-30"
    text="how about RepPO received quantity < allocated? can this be happen?"
    */
    CURSOR l_cur_get_rcv_transaction_info IS
      SELECT rt.transaction_id
            ,rt.primary_quantity -
             NVL((SELECT SUM(NVL(mid_s.primary_unallocated_quantity
                               ,0) + NVL(mid_s.primary_unconsumed_quantity
                                        ,0))
                   FROM jmf_shikyu_cfr_mid_temp mid_s
                  WHERE mid_s.row_type = p_rcv_transaction_row_type
                    AND mid_s.shikyu_id = rt.transaction_id)
                ,0)
        FROM jmf_shikyu_allocations    alloc
            ,jmf_shikyu_replenishments jsr
            ,jmf_shikyu_cfr_mid_temp   mid
            ,rcv_transactions          rt
       WHERE mid.row_type = p_sub_po_unconsumed_row_type
         AND NVL(mid.get_rep_flag
                ,'N') <> CFR_REP_PO_GET_RCV_FLAG --if the rep_po line have done get rcv process, the get_rcv_flag will be set to 1
         AND mid.shikyu_id = alloc.subcontract_po_shipment_id
         AND mid.item_id = alloc.shikyu_component_id
         AND alloc.replenishment_so_line_id = jsr.replenishment_so_line_id
         AND jsr.replenishment_po_shipment_id = rt.po_line_location_id
         AND rt.transaction_type = 'RECEIVE'
         AND jsr.oem_organization_id = p_oem_inv_org_id
         AND jsr.tp_organization_id = p_tp_inv_org_id
         AND jsr.tp_supplier_id = p_supplier_id
         AND jsr.tp_supplier_site_id = p_supplier_site_id
         AND jsr.shikyu_component_id = p_item_id
       ORDER BY rt.transaction_date;

    l_rcv_transaction_id          rcv_transactions.transaction_id%TYPE; --for cursor
    l_rcv_unprocessed_primary_qty rcv_transactions.primary_quantity%TYPE; --for cursor

    l_sub_po_residual_pri rcv_transactions.primary_quantity%TYPE;
    l_rcv_unconsumed_pri  rcv_transactions.primary_quantity%TYPE;

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_sub_po_unconsumed_row_type:' ||  p_sub_po_unconsumed_row_type ||
                             ',p_rep_po_unconsumed_row_type:' ||  p_rep_po_unconsumed_row_type ||
                             ',p_rcv_transaction_row_type:' ||  p_rcv_transaction_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',x_need_to_find_pri_qty:' ||  x_need_to_find_pri_qty ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    --step1:find all the subcontracting PO that not fully received(with oem_inv_org,supplier/site,tp_inv_org,item)
    get_unconsumed_sub_po(p_sub_po_unconsumed_row_type => p_sub_po_unconsumed_row_type
                         ,p_ou_id                      => p_ou_id
                         ,p_supplier_id                => p_supplier_id
                         ,p_supplier_site_id           => p_supplier_site_id
                         ,p_oem_inv_org_id             => p_oem_inv_org_id
                         ,p_tp_inv_org_id              => p_tp_inv_org_id
                         ,p_item_id                    => p_item_id
                         ,p_project_id                 => p_project_id
                         ,p_task_id                    => p_task_id);
    --step2:find all the replenishment po received transactions for the all subcontract PO above, based on LIFO receive date
    --
    OPEN l_cur_get_rcv_transaction_info;
    LOOP
      --begin rcv_transaction information
      EXIT WHEN x_need_to_find_pri_qty <= 0;

      FETCH l_cur_get_rcv_transaction_info
        INTO l_rcv_transaction_id, l_rcv_unprocessed_primary_qty;

      EXIT WHEN l_cur_get_rcv_transaction_info%NOTFOUND;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'begin:' ||
                               ',x_need_to_find_pri_qty:' ||  x_need_to_find_pri_qty ||
                               ',l_rcv_transaction_id:' ||  l_rcv_transaction_id ||
                               ',l_rcv_unprocessed_primary_qty:' ||  l_rcv_unprocessed_primary_qty
            );
      -- **** for debug information in readonly UT environment.--- end ****

      --step3:find the possible onhand components(for the unconsumed )
      l_sub_po_residual_pri := get_sub_po_residual_unconsume(p_sub_po_unconsumed_row_type => p_sub_po_unconsumed_row_type
                                                            ,p_ou_id                      => p_ou_id
                                                            ,p_rcv_transaction_id         => l_rcv_transaction_id
                                                            ,p_supplier_id                => p_supplier_id
                                                            ,p_supplier_site_id           => p_supplier_site_id
                                                            ,p_oem_inv_org_id             => p_oem_inv_org_id
                                                            ,p_tp_inv_org_id              => p_tp_inv_org_id
                                                            ,p_item_id                    => p_item_id
                                                            ,p_project_id                 => p_project_id
                                                            ,p_task_id                    => p_task_id); --the quantity for primary uom

      IF l_sub_po_residual_pri > 0
      THEN
        --the possilbe unconsumed rcv_transactions primary quantity
        l_rcv_unconsumed_pri := jmf_shikyu_rpt_util.get_min3(p_number1 => l_rcv_unprocessed_primary_qty
                                                            ,p_number2 => l_sub_po_residual_pri
                                                            ,p_number3 => x_need_to_find_pri_qty);

        --insert data to rcv_temp marking the processed rcv_transaction,
        set_rcv_transaction_unconsume(p_rcv_row_type       => p_rcv_transaction_row_type
                                     ,p_ou_id              => p_ou_id
                                     ,p_rcv_transaction_id => l_rcv_transaction_id
                                     ,p_rcv_unconsumed_pri => l_rcv_unconsumed_pri
                                     ,p_supplier_id        => p_supplier_id
                                     ,p_supplier_site_id   => p_supplier_site_id
                                     ,p_oem_inv_org_id     => p_oem_inv_org_id
                                     ,p_tp_inv_org_id      => p_tp_inv_org_id
                                     ,p_item_id            => p_item_id
                                     ,p_project_id         => p_project_id
                                     ,p_task_id            => p_task_id);

        --the residual unconsumed quantity for primary quantity
        --update replenishment po residual unconsumed quantity information
        set_sub_po_residual_unconsume(p_sub_po_unconsumed_row_type => p_sub_po_unconsumed_row_type
                                     ,p_rcv_transaction_row_type   => p_rcv_transaction_row_type
                                     ,p_ou_id                      => p_ou_id
                                     ,p_rcv_transaction_id         => l_rcv_transaction_id
                                     ,p_supplier_id                => p_supplier_id
                                     ,p_supplier_site_id           => p_supplier_site_id
                                     ,p_oem_inv_org_id             => p_oem_inv_org_id
                                     ,p_tp_inv_org_id              => p_tp_inv_org_id
                                     ,p_item_id                    => p_item_id
                                     ,p_project_id                 => p_project_id
                                     ,p_task_id                    => p_task_id
                                     ,p_new_consumed_pri           => l_rcv_unconsumed_pri);
        --update the need to find primary quantity
        x_need_to_find_pri_qty := x_need_to_find_pri_qty - l_rcv_unconsumed_pri;

      END IF;

    END LOOP; -- end of find the rcv_transaction information
    CLOSE l_cur_get_rcv_transaction_info;

    --step4:update the get_rcv_flags for the rep_po lines
    COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_unconsumed_components;

  --========================================================================
  -- PROCEDURE : get_unconsumed_sub_po    PUBLIC ,unconsumed_subcontracting_po
  -- PARAMETERS: p_sub_po_unconsumed_row_type row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the subcontracting purchase order that not fully received
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_sub_po
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_unconsumed_sub_po';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_sub_po_unconsumed_row_type:' ||  p_sub_po_unconsumed_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    --the subcontract orders that not fully received

    -- insert only the new SubPO info
    INSERT INTO jmf_shikyu_cfr_mid_temp
      (row_type
      ,shikyu_id
      ,uom
      ,primary_uom
      ,primary_unconsumed_quantity
      ,supplier_id
      ,site_id
      ,oem_inv_org_id
      ,tp_inv_org_id
      ,item_id)
      SELECT p_sub_po_unconsumed_row_type
            ,sub_po.subcontract_po_shipment_id
            ,comp.uom
            ,JMF_SHIKYU_RPT_UTIL.get_item_primary_uom_code(sub_po.tp_organization_id
                                                          ,comp.shikyu_component_id)
            ,((SELECT NVL(SUM(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(sub_po.tp_organization_id
                                                                           ,jsa_a.shikyu_component_id
                                                                           ,jsa_a.uom
                                                                           ,NVL(jsa_a.allocated_quantity
                                                                               ,0)))
                         ,0)
                 FROM jmf_shikyu_allocations jsa_a
                WHERE jsa_a.subcontract_po_shipment_id =
                      comp.subcontract_po_shipment_id
                  AND jsa_a.shikyu_component_id = comp.shikyu_component_id) -
             wip_req.quantity_issued
             ) primary_possible_unconsumed
            ,ph.vendor_id
            ,ph.vendor_site_id
            ,sub_po.oem_organization_id
            ,sub_po.tp_organization_id
            ,comp.shikyu_component_id
        FROM po_line_locations_all      pll
            ,jmf_subcontract_orders     sub_po
            ,po_headers_all             ph
            ,jmf_shikyu_components      comp
            ,wip_requirement_operations wip_req
       WHERE pll.line_location_id = sub_po.subcontract_po_shipment_id
         AND pll.quantity > pll.quantity_received --this can be ignore if allow the allocated qty larger than ordered qty
         AND sub_po.oem_organization_id = p_oem_inv_org_id
         AND sub_po.tp_organization_id = p_tp_inv_org_id
         AND pll.po_header_id = ph.po_header_id
         AND ((ph.org_id IS NULL) OR (ph.org_id = p_ou_id))
         AND ph.vendor_id = p_supplier_id
         AND ph.vendor_site_id = p_supplier_site_id
         AND sub_po.wip_entity_id = wip_req.wip_entity_id
         AND sub_po.subcontract_po_shipment_id =
             comp.subcontract_po_shipment_id
         AND comp.shikyu_component_id = wip_req.inventory_item_id
         AND comp.shikyu_component_id = p_item_id
         AND sub_po.tp_organization_id = wip_req.organization_id
         AND wip_req.repetitive_schedule_id IS NULL
         AND wip_req.operation_seq_num = 1
--This may cause issue when same components are found in different tp organization,the onhand component are found
--   secondly,will be lost in them mid_temp table.That means in the report will lose some datas which should be displayed.
-- updated to fix this potensial issue.
/*         AND NOT ((comp.subcontract_po_shipment_id IN
              (SELECT jscmt_s.shikyu_id
                      FROM jmf_shikyu_cfr_mid_temp jscmt_s
                     WHERE jscmt_s.row_type = p_sub_po_unconsumed_row_type)) AND
              (comp.shikyu_component_id IN
              (SELECT jscmt_i.item_id
                      FROM jmf_shikyu_cfr_mid_temp jscmt_i
                     WHERE jscmt_i.row_type = p_sub_po_unconsumed_row_type)))*/
         AND NOT (comp.subcontract_po_shipment_id IN
                          (SELECT jscmt_s.shikyu_id
                              FROM jmf_shikyu_cfr_mid_temp jscmt_s
                            WHERE jscmt_s.row_type = p_sub_po_unconsumed_row_type
                                 AND jscmt_s.item_id = p_item_id))
         ;

    --update the primary UOM, primary_residual_unallocated
    UPDATE jmf_shikyu_cfr_mid_temp
       SET quantity = NVL(primary_unconsumed_quantity,0) *
                      JMF_SHIKYU_RPT_UTIL.po_uom_convert_p(primary_uom
                                                          ,uom
                                                          ,item_id)
     WHERE row_type = p_sub_po_unconsumed_row_type
       AND quantity IS NULL --only for those do not get the quantity of uom
       AND supplier_id = p_supplier_id
       AND site_id = p_supplier_site_id
       AND oem_inv_org_id = p_oem_inv_org_id
       AND tp_inv_org_id = p_tp_inv_org_id
       AND item_id = p_item_id;
    COMMIT; -- for debug on UT ?????
     --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_sub_po_unconsumed_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
   IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_unconsumed_sub_po;

  --========================================================================
  -- PROCEDURE : get_unconsumed_rep_po    PUBLIC ,get_unconsumed_replenishment_po
  -- PARAMETERS: p_rep_po_unconsume_row_type       row type id to identify the
  --                                          unconsumed components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order that have unallocated receipts for the item
  --             and insert the result to mid temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_rep_po
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_unconsumed_rep_po';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_sub_po_unconsumed_row_type:' ||  p_sub_po_unconsumed_row_type ||
                             ',p_rep_po_unconsumed_row_type:' ||  p_rep_po_unconsumed_row_type ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;

    -- the allocated quantity for one po line_location_id, assume that the UOM are the same in po and shikyu allocation
    -- need to add the supplier/site oem tp org and item restriction????.
    -- update 2005-11-30
    INSERT INTO jmf_shikyu_cfr_mid_temp
      (row_type
      ,shikyu_id
      ,uom
      ,primary_uom
      ,primary_unconsumed_quantity
      ,supplier_id
      ,site_id
      ,oem_inv_org_id
      ,tp_inv_org_id
      ,item_id)
      SELECT p_rep_po_unconsumed_row_type
            ,jsr.replenishment_po_shipment_id
            ,alloc.uom
            ,JMF_SHIKYU_RPT_UTIL.get_item_primary_uom_code(jsr.oem_organization_id
                                                          ,alloc.shikyu_component_id)
            ,JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(jsr.oem_organization_id
                                                          ,alloc.shikyu_component_id
                                                          ,alloc.uom
                                                          ,alloc.allocated_quantity) -
             NVL(wro.quantity_issued
                ,0)
            ,jsr.tp_supplier_id
            ,jsr.tp_supplier_site_id
            ,jsr.oem_organization_id
            ,jsr.tp_organization_id
            ,alloc.shikyu_component_id
        FROM jmf_shikyu_allocations     alloc
            ,jmf_shikyu_replenishments  jsr
            ,jmf_shikyu_cfr_mid_temp    mid
            ,jmf_subcontract_orders     jso
            ,wip_requirement_operations wro
       WHERE mid.row_type = p_sub_po_unconsumed_row_type
         AND NVL(mid.get_rep_flag
                ,'N') <> CFR_SUB_PO_GET_REP_FLAG
         AND mid.shikyu_id = alloc.subcontract_po_shipment_id
         AND mid.item_id = alloc.shikyu_component_id
         AND alloc.replenishment_so_line_id = jsr.replenishment_so_line_id
         AND jsr.oem_organization_id = p_oem_inv_org_id
         AND jsr.tp_organization_id = p_tp_inv_org_id
         AND jsr.tp_supplier_id = p_supplier_id
         AND jsr.tp_supplier_site_id = p_supplier_site_id
         AND alloc.shikyu_component_id = p_item_id
         AND alloc.subcontract_po_shipment_id =
             jso.subcontract_po_shipment_id
         AND jso.wip_entity_id = wro.wip_entity_id(+)
         AND jso.tp_organization_id = wro.organization_id(+)
         AND ((wro.operation_seq_num IS NULL) OR
             (wro.operation_seq_num = 1))
         AND wro.repetitive_schedule_id IS NULL
         AND alloc.shikyu_component_id = wro.inventory_item_id
--This may cause issue when same components are found in different tp organization,the onhand component are found
--   secondly,will be lost in them mid_temp table.That means in the report will lose some datas which should be displayed.
-- updated to fix this potensial issue.
/*         AND NOT
              ((jsr.replenishment_po_shipment_id IN
              (SELECT jscmt_s.shikyu_id
                   FROM jmf_shikyu_cfr_mid_temp jscmt_s
                  WHERE jscmt_s.row_type = p_rep_po_unconsumed_row_type)) AND
              (alloc.shikyu_component_id IN
              (SELECT jscmt_i.item_id
                   FROM jmf_shikyu_cfr_mid_temp jscmt_i
                  WHERE jscmt_i.row_type = p_rep_po_unconsumed_row_type)));
*/         AND NOT (jsr.replenishment_po_shipment_id IN
                          (SELECT jscmt_s.shikyu_id
                              FROM jmf_shikyu_cfr_mid_temp jscmt_s
                            WHERE jscmt_s.row_type = p_rep_po_unconsumed_row_type
                                 AND jscmt_s.item_id = p_item_id));

    --update the primary UOM, primary_residual_unallocated
    UPDATE jmf_shikyu_cfr_mid_temp
       SET quantity = NVL(primary_unconsumed_quantity,0) *
                      JMF_SHIKYU_RPT_UTIL.po_uom_convert_p(primary_uom
                                                          ,uom
                                                          ,item_id)
     WHERE row_type = p_rep_po_unconsumed_row_type
       AND quantity IS NULL --only for those do not get the quantity of uom
       AND supplier_id = p_supplier_id
       AND site_id = p_supplier_site_id
       AND oem_inv_org_id = p_oem_inv_org_id
       AND tp_inv_org_id = p_tp_inv_org_id
       AND item_id = p_item_id;

    COMMIT; -- for debug on UT ?????
     --print the data in mid temp table for debug.
    rpt_debug_show_mid_data(
                             p_row_type  => p_rep_po_unconsumed_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_unconsumed_rep_po;

  --========================================================================
  -- FUNCTION  : get_sub_po_residual_unconsume    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_sub_po_unconsumed_row_type      row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the subcontract order residual unconsumed quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_sub_po_residual_unconsume
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  ) RETURN NUMBER IS
    l_api_name CONSTANT VARCHAR2(30) := 'get_sub_po_residual_unconsume';

    l_sub_po_residual_pri rcv_transactions.primary_quantity%TYPE;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_sub_po_unconsumed_row_type:' ||  p_sub_po_unconsumed_row_type ||
                             ',p_rcv_transaction_id:' ||  p_rcv_transaction_id ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    SELECT SUM(NVL(cfr_mid.primary_unconsumed_quantity
                  ,0))
      INTO l_sub_po_residual_pri
      FROM jmf_shikyu_cfr_mid_temp   cfr_mid
          ,rcv_transactions          rcv
          ,jmf_shikyu_allocations    alloc
          ,jmf_shikyu_replenishments jsr
     WHERE rcv.transaction_id = P_rcv_transaction_id
       AND rcv.transaction_type = 'RECEIVE'
       AND cfr_mid.row_type = p_sub_po_unconsumed_row_type
       AND cfr_mid.supplier_id = p_supplier_id
       AND cfr_mid.site_id = p_supplier_site_id
       AND cfr_mid.oem_inv_org_id = p_oem_inv_org_id
       AND cfr_mid.tp_inv_org_id = p_tp_inv_org_id
       AND cfr_mid.item_id = p_item_id
       AND cfr_mid.shikyu_id = alloc.subcontract_po_shipment_id
       AND cfr_mid.item_id = alloc.shikyu_component_id
       AND alloc.replenishment_so_line_id = jsr.replenishment_so_line_id
       AND jsr.replenishment_po_shipment_id = rcv.po_line_location_id;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
    RETURN l_sub_po_residual_pri;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;
      RETURN 0;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      RETURN -1;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END get_sub_po_residual_unconsume;

  --========================================================================
  -- PROCEDURE : set_sub_po_residual_unconsume    PUBLIC ,set_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_sub_po_unconsumed_row_type     row type id to identify the
  --                                          unconsumed components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_rep_po_id                  row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : p_new_consumed_pri           the new consumed primary quantity that need to update in the temp table
  -- COMMENT   : find the subcontract order residual unaconsumed quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_sub_po_residual_unconsume
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,p_new_consumed_pri           IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'set_sub_po_residual_unconsume';

    CURSOR lcur_sub_po_temp_info IS
      SELECT cfr_mid.shikyu_id
            ,cfr_mid.primary_unconsumed_quantity
        FROM jmf_shikyu_cfr_mid_temp   cfr_mid
            ,rcv_transactions          rcv
            ,jmf_shikyu_allocations    alloc
            ,jmf_shikyu_replenishments jsr
       WHERE rcv.transaction_id = p_rcv_transaction_id
         AND rcv.transaction_type = 'RECEIVE'
         AND cfr_mid.row_type = p_sub_po_unconsumed_row_type
         AND cfr_mid.supplier_id = p_supplier_id
         AND cfr_mid.site_id = p_supplier_site_id
         AND cfr_mid.oem_inv_org_id = p_oem_inv_org_id
         AND cfr_mid.tp_inv_org_id = p_tp_inv_org_id
         AND cfr_mid.item_id = p_item_id
         AND cfr_mid.shikyu_id = alloc.subcontract_po_shipment_id
         AND cfr_mid.item_id = alloc.shikyu_component_id
         AND alloc.replenishment_so_line_id = jsr.replenishment_so_line_id
         AND jsr.replenishment_po_shipment_id = rcv.po_line_location_id
         AND cfr_mid.primary_unconsumed_quantity > 0
       ORDER BY cfr_mid.shikyu_id DESC;

    l_sub_po_id                 jmf_shikyu_cfr_mid_temp.shikyu_id%TYPE;
    l_residual_old_consumed_pri jmf_shikyu_cfr_mid_temp.primary_unconsumed_quantity%TYPE;
    l_residual_new_consumed_pri jmf_shikyu_cfr_mid_temp.primary_unconsumed_quantity%TYPE;
    l_cur_sub_po_consumed_pri   jmf_shikyu_cfr_mid_temp.primary_unconsumed_quantity%TYPE;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_sub_po_unconsumed_row_type:' ||  p_sub_po_unconsumed_row_type ||
                             ',p_rcv_transaction_row_type:' ||  p_rcv_transaction_row_type ||
                             ',p_rcv_transaction_id:' ||  p_rcv_transaction_id ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_new_consumed_pri:' || p_new_consumed_pri ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    --????
    l_residual_new_consumed_pri := p_new_consumed_pri;
    OPEN lcur_sub_po_temp_info;
    LOOP
      --begin process updating the unconsumed qty for the found subcontract order in the mid temp table
      EXIT WHEN l_residual_new_consumed_pri <= 0;

      FETCH lcur_sub_po_temp_info
        INTO l_sub_po_id, l_residual_old_consumed_pri;

      EXIT WHEN lcur_sub_po_temp_info%NOTFOUND;

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'begin:' ||
                               ',l_residual_new_consumed_pri:' ||  l_residual_new_consumed_pri ||
                               ',l_sub_po_id:' ||  l_sub_po_id ||
                               ',l_residual_old_consumed_pri:' ||  l_residual_old_consumed_pri
            );
      -- **** for debug information in readonly UT environment.--- end ****

      l_cur_sub_po_consumed_pri := jmf_shikyu_rpt_util.get_min2(l_residual_old_consumed_pri
                                                               ,l_residual_new_consumed_pri);
      UPDATE jmf_shikyu_cfr_mid_temp
    -- Updated to fix potential issue of operations between null numbers
    --     SET quantity                    = quantity -
    --                                       (quantity * l_cur_sub_po_consumed_pri /
         SET quantity                    = NVL(quantity,0) -
                                           ( NVL(quantity,0)  * l_cur_sub_po_consumed_pri /
                                           primary_unconsumed_quantity) --possible unconsumed for UOM
            ,primary_unconsumed_quantity = NVL(primary_unconsumed_quantity,0) -
                                           l_cur_sub_po_consumed_pri --possible unconsumed for primary UOM
       WHERE row_type = p_sub_po_unconsumed_row_type
         AND shikyu_id = l_sub_po_id
         AND oem_inv_org_id = p_oem_inv_org_id
         AND tp_inv_org_id = p_tp_inv_org_id
         AND item_id = p_item_id;

      l_residual_new_consumed_pri := l_residual_new_consumed_pri -
                                     l_cur_sub_po_consumed_pri;

    END LOOP; --end process updating the unconsumed qty for the found subcontract order in the mid temp table
    CLOSE lcur_sub_po_temp_info;

    /*
    TODO: owner="sunwa" created="2005-11-30"
    text="how about if the l_residual_new_consumed_pri still lager then 0 "
    */
    -- if l_residual_new_consumed_pri > 0 then ---
    COMMIT; -- for debug on UT ?????
    rpt_debug_show_mid_data(
                             p_row_type  => p_sub_po_unconsumed_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END set_sub_po_residual_unconsume;

  --========================================================================
  -- PROCEDURE : set_rcv_transaction_unconsume    PUBLIC ,get_replenishment_po_unconsumed quantity for primary uom
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_rcv_unallocated_pri        the rcv unallocated quantity for primary uom
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : update the replenishment po receive transaction unconsumed information for primary uom
  --             old_unconsumed  = old_unconsumed + p_rcv_unconsumed_pri
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rcv_transaction_unconsume
  (
    p_rcv_row_type       IN NUMBER
   ,p_ou_id              IN NUMBER
   ,p_rcv_transaction_id IN NUMBER
   ,p_rcv_unconsumed_pri IN NUMBER
   ,p_supplier_id        IN NUMBER
   ,p_supplier_site_id   IN NUMBER
   ,p_oem_inv_org_id     IN NUMBER
   ,p_tp_inv_org_id      IN NUMBER
   ,p_item_id            IN NUMBER
   ,p_project_id         IN NUMBER
   ,p_task_id            IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'set_rcv_transaction_unconsume';

    l_jmf_cfr_mid_temp_rcv_rows NUMBER;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rcv_row_type:' ||  p_rcv_row_type ||
                             ',p_rcv_transaction_id:' ||  p_rcv_transaction_id ||
                             ',p_ou_id :' ||  p_ou_id ||
                             ',p_supplier_id:' || p_supplier_id ||
                             ',p_supplier_site_id:' || p_supplier_site_id ||
                             ',p_oem_inv_org_id :' ||  p_oem_inv_org_id ||
                             ',p_tp_inv_org_id:' || p_tp_inv_org_id ||
                             ',p_item_id:' || p_item_id ||
                             ',p_rcv_unconsumed_pri:' || p_rcv_unconsumed_pri ||
                             ',p_project_id:' ||  p_project_id ||
                             ',p_task_id:' ||  p_task_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    -- Valid parameter validation;
    -- if all parameters are valid then continue; otherwise raise an error message in log;
    SELECT COUNT(*)
      INTO l_jmf_cfr_mid_temp_rcv_rows
      FROM jmf_shikyu_cfr_mid_temp
     WHERE row_type = p_rcv_row_type
       AND shikyu_id = p_rcv_transaction_id;
    --find if there is a rcv_transaction line exist
    IF l_jmf_cfr_mid_temp_rcv_rows = 1 --Found one row
    THEN
      --update if exist
      UPDATE jmf_shikyu_cfr_mid_temp
    -- Updated to fix potential issue of operations between null numbers
    --     SET primary_unconsumed_quantity = primary_unconsumed_quantity +
         SET primary_unconsumed_quantity = NVL(primary_unconsumed_quantity,0) +
                                           p_rcv_unconsumed_pri
       WHERE row_type = p_rcv_row_type
         AND shikyu_id = p_rcv_transaction_id;
    ELSE
      --NOTFOUND
      --add if not exist
      INSERT INTO jmf_shikyu_cfr_mid_temp
        (row_type
        ,shikyu_id
        ,primary_unconsumed_quantity
        ,oem_inv_org_id
        ,tp_inv_org_id
        ,item_id
        ,supplier_id
        ,site_id)
      VALUES
        (p_rcv_row_type
        ,p_rcv_transaction_id
        ,p_rcv_unconsumed_pri
        ,p_oem_inv_org_id
        ,p_tp_inv_org_id
        ,p_item_id
        ,p_supplier_id
        ,p_supplier_site_id);
    END IF; --IF l_jmf_cfr_mid_temp_rcv_rows = 1
    COMMIT; -- for debug on UT ?????
    rpt_debug_show_mid_data(
                             p_row_type  => p_rcv_row_type
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END set_rcv_transaction_unconsume;

  --========================================================================
  -- PROCEDURE : validate_cfr_mid_temp    PUBLIC ,validate the data in mid temp table, do UOM and Currency conversion
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : this include UOM and Currency conversion and data check
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE validate_cfr_mid_temp(p_rcv_row_type IN NUMBER)
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'validate_cfr_mid_temp';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rcv_row_type:' ||  p_rcv_row_type
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , 'p_rcv_row_type:' || p_rcv_row_type);
    END IF;

    -- fill the uom, primary_uom column for CFR_TMP_RCV_ROW rows
    UPDATE jmf_shikyu_cfr_mid_temp jscmt
       SET jscmt.uom         = (SELECT rt.unit_of_measure
                                  FROM rcv_transactions rt
                                 WHERE jscmt.row_type = CFR_TMP_RCV_ROW
                                   AND rt.transaction_id = jscmt.shikyu_id)
          ,jscmt.primary_uom = (SELECT rt.primary_unit_of_measure
                                  FROM rcv_transactions rt
                                 WHERE jscmt.row_type = CFR_TMP_RCV_ROW
                                   AND rt.transaction_id = jscmt.shikyu_id)
     WHERE jscmt.row_type = CFR_TMP_RCV_ROW;
    -- update the quantity  column for CFR_TMP_RCV_ROW rows
    --  quantity of UOM =
    UPDATE jmf_shikyu_cfr_mid_temp
       SET quantity = (NVL(primary_unallocated_quantity
                          ,0) + NVL(primary_unconsumed_quantity
                                    ,0)) *
                      JMF_SHIKYU_RPT_UTIL.po_uom_convert_p(JMF_SHIKYU_RPT_UTIL.uom_to_code(primary_uom)
                                                          ,JMF_SHIKYU_RPT_UTIL.uom_to_code(uom)
                                                          ,item_id)
     WHERE row_type = CFR_TMP_RCV_ROW;
    COMMIT; -- for debug on UT ?????
    rpt_debug_show_mid_data(
                             p_row_type  => CFR_TMP_RCV_ROW
                            ,p_output_to => 'FND_LOG.STRING'
                            );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN'
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END validate_cfr_mid_temp;

  --========================================================================
  -- PROCEDURE : add_data_to_cfr_temp    PUBLIC ,process the mid_temp data and add to temp talbe for report builder
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : and data merge to temp talbe for report builder
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE add_data_to_cfr_temp
  (
    p_rcv_row_type              IN NUMBER
   ,p_rpt_mode                  IN VARCHAR2
   ,p_days_received             IN NUMBER
   ,p_currency_conversion_type  IN VARCHAR2
   ,p_currency_conversion_date  IN DATE
   ,p_functional_currency       IN VARCHAR2
   -- Amy added to fix bug 5583680 start
   ,p_supplier_name_from      IN VARCHAR2
   ,p_supplier_site_code_from IN VARCHAR2
   ,p_supplier_name_to        IN VARCHAR2
   ,p_supplier_site_code_to   IN VARCHAR2
   ,p_oem_inv_org_name_from   IN VARCHAR2
   ,p_oem_inv_org_name_to     IN VARCHAR2
   -- Amy added to fix bug 5583680 end
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'add_data_to_cfr_temp';
    l_p_currency_conversion_date DATE;
  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',p_rcv_row_type:' ||  p_rcv_row_type ||
                             ',p_rpt_mode:' ||  p_rpt_mode ||
                             ',p_days_received:' ||  p_days_received ||
                             ',p_currency_conversion_type:' ||  p_currency_conversion_type ||
                             ',p_currency_conversion_date:' ||  p_currency_conversion_date ||
                             ',p_functional_currency:' ||  p_functional_currency
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.begin'
                    , NULL);
    END IF;

    IF p_currency_conversion_date IS NULL
    THEN
        l_p_currency_conversion_date := SYSDATE;
    ELSE
        l_p_currency_conversion_date := p_currency_conversion_date;
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin:' ||
                             ',l_p_currency_conversion_date:' ||  l_p_currency_conversion_date
          );
    -- **** for debug information in readonly UT environment.--- end ****


    --step1: get crude data: add the data for standard po, using po_lines_all
    rpt_get_crude_data(p_rpt_mode                  => p_rpt_mode
                      ,p_currency_conversion_type  => p_currency_conversion_type
                      ,p_currency_conversion_date  => l_p_currency_conversion_date
                      ,p_functional_currency       => p_functional_currency);

    -- get the summary estinated qty for SHIKYU_component region in the report
    rpt_get_Comp_Estimated_data(p_rpt_mode => p_rpt_mode);

    -- get the distinct SubPO info for SHIKYU_component accordingly in the report
    rpt_get_SubPO_data(p_rpt_mode => p_rpt_mode
    --Amy add for fixing bug 5391412 start
                                   ,p_ou_id => g_ou_id
                                   ,p_days_received => p_days_received);
    --Amy add for fixing bug 5391412 end

    -- get the data for Un-received Replenishments
    -- Amy updated to fix bug 5583680 start
    -- rpt_get_UnReceived_data(p_rpt_mode => p_rpt_mode);
	rpt_get_UnReceived_data(p_rpt_mode => p_rpt_mode
				           ,p_supplier_name_from      => p_supplier_name_from
						   ,p_supplier_site_code_from => p_supplier_site_code_from
						   ,p_supplier_name_to        => p_supplier_name_to
					       ,p_supplier_site_code_to   => p_supplier_site_code_to
						   ,p_oem_inv_org_name_from   => p_oem_inv_org_name_from
						   ,p_oem_inv_org_name_to     => p_oem_inv_org_name_to);
    -- Amy updated to fix bug 5583680 end

    -- get the data for Un-received Replenishments
    rpt_get_Received_data( p_rpt_mode         => p_rpt_mode
                          ,p_days_received    => p_days_received);

    -- get data for internal report
    rpt_get_Int_data(p_rpt_mode => p_rpt_mode);

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_RPT_NO_DATA');
      fnd_msg_pub.Add;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_PREFIX || l_api_name || '.execption'
                      , SQLERRM);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS THEN:' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END add_data_to_cfr_temp;

  --========================================================================
  -- PROCEDURE : rpt_get_crude_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the crude data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_CRUDE_DATA
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_crude_data(
   p_rpt_mode                  IN VARCHAR2
  ,p_currency_conversion_type  IN VARCHAR2
  ,p_currency_conversion_date  IN DATE
  ,p_functional_currency       IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

  -- insert the onhand items that with SubContracting Order.
  INSERT INTO jmf_shikyu_cfr_rpt_temp
    (rpt_mode
    ,TRANSACTION_ID
    ,RPT_DATA_TYPE
    ,oem_inv_org_id
    ,oem_inv_org_code
    ,supplier_id
    ,supplier_name
    ,site_id
    ,site_code
    ,site_address
    ,contact_id
    ,contact_name
    ,tp_inv_org_id
    ,tp_inv_org_code
    ,item_id
    ,item_number
    ,item_description
    ,currency_code
    ,functional_currency
    ,shikyu_price
    ,item_cost --the cost based on UOM after conversion from Pri_Uom
    ,value1 --the item qty in Pri Uom
    ,value2 --the item price in Pri UOM and Pri Currency
    ,value3 --the item cost in Pri UOM and Pri Currency, from cst_item_costs table
    ,project_id
    ,project_num
    ,task_id
    ,task_num
    ,uom
    ,ESTIMATED_QTY
    ,primary_uom
    ,REP_SO_HEADER_ID
    ,REP_SO_NUMBER
    ,REP_SO_VERSION_NUMBER
    ,REP_SO_LINE_ID
    ,REP_SO_LINE
    ,SHIPPED_DATE
    ,EXPECTED_RCV_DATE --the Rep PO need by date
    ,REP_PO_HEADER_ID
    ,REP_PO_NUMBER
    ,REP_PO_REVISION_NUM
    ,REP_PO_RELEASE_ID
    ,REP_PO_RELEASE_NUM
    ,REP_PO_LINE_ID
    ,REP_PO_LINE
    ,REP_PO_LINE_LOCATION_ID
    ,REP_PO_SHIPMENT
    ,REP_PO_DISTRIBUTION_ID
    ,SUBPO_HEADER_ID
    ,SUBPO_NUMBER
    ,SUBPO_LINE_ID
    ,SUBPO_LINE_NUM
    ,SUBPO_RELEASE_ID
    ,SUBPO_RELEASE_NUM
    ,SUBPO_SHIPMENT_ID
    ,SUBPO_SHIPMENT_NUM)
    SELECT p_rpt_mode rpt_mode
          ,cfr_mid.shikyu_id TRANSACTION_ID
          ,CFR_CRUDE_DATA RPT_DATA_TYPE
          ,cfr_mid.oem_inv_org_id oem_inv_org_id
          ,mp_oem.organization_code oem_org_code
          ,cfr_mid.supplier_id supplier_id
          ,pv.vendor_name supplier_name
          ,cfr_mid.site_id site_id
          ,pvs.vendor_site_code site_code
          ,pvs.address_line1 || ',' || pvs.address_line2 || ',' ||
           pvs.address_line3 site_address
          ,ph.vendor_contact_id contact_id
          ,pvc.prefix || ' ' || pvc.first_name || ',' || pvc.middle_name || ',' ||
           pvc.middle_name || ',' || pvc.last_name contact_name
          ,cfr_mid.tp_inv_org_id tp_inv_org_id
          ,mp_tp.organization_code tp_inv_org_code
          ,cfr_mid.item_id item_id
          ,JMF_SHIKYU_RPT_UTIL.get_item_number(cfr_mid.tp_inv_org_id
                                              ,cfr_mid.item_id) item_number
          ,item_v.description item_description
          ,ooha.transactional_curr_code currency_code --or jmf_shikyu_components.Currency ,not ph.currency_code
          ,p_functional_currency functional_currency
          ,oola.unit_selling_price po_unit_price --not pl.unit_price
          ,JMF_SHIKYU_RPT_UTIL.convert_amount(ooha.transactional_curr_code
                                             ,p_functional_currency
           --Amy update for fixing currency conversing issue start
           --when paramter p_currency_conversion_date and p_currency_conversion_type are not specified,
           -- use sysdate and conversion_type in so as default value.
                                             --,p_currency_conversion_date
                                             --,p_currency_conversion_type
                                             ,decode(p_currency_conversion_date,null,sysdate,p_currency_conversion_date)
                                             ,decode(p_currency_conversion_type,null,ooha.CONVERSION_TYPE_CODE,p_currency_conversion_type)
           --Amy update for fixing currency conversing issue end
                                             ,NVL(cic.item_cost
                                                 ,0) *
                                              PO_UOM_S.po_uom_convert_p(cfr_mid.primary_uom
                                                                       ,cfr_mid.uom
                                                                       ,cfr_mid.item_id)) item_cost --the cost based on UOM after conversion from Pri_Uom
          ,(cfr_mid.quantity *
           PO_UOM_S.po_uom_convert_p(cfr_mid.uom
                                     ,cfr_mid.primary_uom
                                     ,cfr_mid.item_id)) value1 --item qty in Primary
          ,JMF_SHIKYU_RPT_UTIL.convert_amount(ooha.transactional_curr_code
                                             ,p_functional_currency
           --Amy update for fixing currency conversing issue start
           --when paramter p_currency_conversion_date and p_currency_conversion_type are not specified,
           -- use sysdate and conversion_type in so as default value.
                                             --,p_currency_conversion_date
                                             --,p_currency_conversion_type
                                             ,decode(p_currency_conversion_date,null,sysdate,p_currency_conversion_date)
                                             ,decode(p_currency_conversion_type,null,ooha.CONVERSION_TYPE_CODE,p_currency_conversion_type)
           --Amy update for fixing currency conversing issue end
                                             ,oola.unit_selling_price *
                                              PO_UOM_S.po_uom_convert_p(cfr_mid.uom
                                                                       ,cfr_mid.primary_uom
                                                                       ,cfr_mid.item_id)) value2 --the item price in Pri UOM and Pri Currency
          ,NVL(cic.item_cost
              ,0) value3 --Standard_Item_Cost in Pri UOM and Pri Currency
--updated to fix project_id related issue start
          --,rcv.project_id project_id
          ,sub.project_id project_id
--updated to fix project_id related issue start
--updated to fix project_number related issue start
          --,prj.segment1 project_number
         ,NVL((SELECT DISTINCT segment1 AS project_number
                  FROM pa_projects_all
                WHERE pa_projects_all.project_id(+) = sub.project_id),
              (SELECT DISTINCT project_number
               FROM   pjm_seiban_numbers
               WHERE pjm_seiban_numbers.project_id(+) = sub.project_id)) project_number
--updated to fix project_number related issue end
--updated to fix project_id related issue start
          --,rcv.task_id task_id
          ,sub.task_id task_id
--updated to fix project_id related issue start
          ,task.task_number task_number
          ,cfr_mid.uom --should jmf_shikyu_components.uom,need rcv.unit_of_measure to conversion?
          ,cfr_mid.quantity --the SHIKYU component quantity find in rcv for unallocated + unconsumed
          ,cfr_mid.primary_uom --rcv.primary_unit_of_measure
          ,oola.header_id RepSO_header_id
          ,ooha.order_number REP_SO_NUMBER
          ,ooha.version_number RepSO_Version_number
          ,oola.line_id RepSO_line_id
          ,oola.line_number REP_SO_LINE
          ,oola.actual_shipment_date SHIPPED_DATE
          ,poloc.need_by_date --,EXPECTED_RCV_DATE
          ,rcv.po_header_id RepPO_header_id
          ,ph.segment1 REP_PO_NUMBER
          ,rcv.po_revision_num RepPO_Revision_num
          ,rcv.po_release_id RepPO_Release_id
          ,pra.release_num REP_PO_RELEASE
          ,rcv.po_line_id RepPO_Line_id
          ,pl.line_num REP_PO_LINE
          ,rcv.po_line_location_id RepPO_line_location_id
          ,poloc.shipment_num REP_PO_SHIPMENT
          ,rcv.po_distribution_id RepPO_distribution_id
          ,pha_s.po_header_id SubPO_header_id
          ,pha_s.segment1 SubPO_Number
          ,pla_s.po_line_id SubPO_line_id
          ,pla_s.line_num SubPO_Line_num
          ,pra_s.po_release_id SubPO_release_id
          ,pra_s.release_num SubPO_release_Num
          ,plla_s.line_location_id SubPO_shipment_id
          ,plla_s.shipment_num SubPO_shipment_num
      FROM jmf_shikyu_cfr_mid_temp   cfr_mid
          ,jmf_subcontract_orders sub
          ,po_line_locations_all     poloc
          ,rcv_transactions          rcv
          ,mtl_parameters            mp_oem
          ,mtl_parameters            mp_tp
          ,po_vendors                pv
          ,po_vendor_sites_all       pvs
          ,po_headers_all            ph
          ,po_vendor_contacts        pvc
          ,mtl_system_items_vl       item_v
          ,po_lines_all              pl
          ,pa_projects_all           prj
          ,pa_tasks                  task
          ,po_releases_all           pra
          ,jmf_shikyu_replenishments jsr
          ,oe_order_lines_all        oola
          ,oe_order_headers_all      ooha
          ,jmf_shikyu_allocations    jsa
          ,po_line_locations_all     plla_s
          ,po_headers_all            pha_s
          ,po_lines_all              pla_s
          ,po_releases_all           pra_s
          ,cst_item_costs            cic
     WHERE cfr_mid.row_type = CFR_TMP_RCV_ROW
       AND cfr_mid.oem_inv_org_id = mp_oem.organization_id
       AND cfr_mid.tp_inv_org_id = mp_tp.organization_id
       AND cfr_mid.supplier_id = pv.vendor_id(+)
       AND cfr_mid.site_id = pvs.vendor_site_id(+)
       AND cfr_mid.shikyu_id = rcv.transaction_id
       AND rcv.transaction_type = 'RECEIVE'
       AND rcv.po_header_id = ph.po_header_id
       AND ph.vendor_contact_id = pvc.vendor_contact_id(+)
       AND cfr_mid.tp_inv_org_id = item_v.organization_id
       AND cfr_mid.item_id = item_v.inventory_item_id
       AND rcv.po_line_location_id = poloc.line_location_id
       AND pl.po_line_id = poloc.po_line_id
       AND rcv.project_id = prj.project_id(+)
       AND rcv.task_id = task.task_id(+)
       AND poloc.po_release_id = pra.po_release_id(+)
       AND poloc.line_location_id = jsr.replenishment_po_shipment_id
       AND jsr.replenishment_so_line_id = oola.line_id
       AND oola.header_id = ooha.header_id
--Updated to fix bug 5509464 start
/*       AND jsa.replenishment_so_line_id = jsr.replenishment_so_line_id
       AND jsa.subcontract_po_shipment_id = plla_s.line_location_id
       AND sub.subcontract_po_shipment_id = plla_s.line_location_id
       AND plla_s.po_header_id = pha_s.po_header_id
       AND plla_s.po_line_id = pla_s.po_line_id*/
       AND jsa.replenishment_so_line_id(+) = jsr.replenishment_so_line_id
       AND jsa.subcontract_po_shipment_id = plla_s.line_location_id(+)
       AND plla_s.line_location_id = sub.subcontract_po_shipment_id(+)
       AND plla_s.po_header_id = pha_s.po_header_id(+)
       AND plla_s.po_line_id = pla_s.po_line_id(+)
--Updated to fix bug 5509464 end
       AND plla_s.po_release_id = pra_s.po_release_id(+)
       AND oola.inventory_item_id = cic.inventory_item_id(+)
       AND oola.ship_from_org_id = cic.organization_id(+);
       /* Bug 6630087 - Start */
       /*Standard Cost check no longer required
       as Buy/Sell Subcontracting is supported for non-standard cost
       OEM organizations as well.
       Note : The confirmation report will display data for both
       Chargeable Subcontracting and Buy/Sell enabled OEM orgs depending
       on the parameters chosen in the report  */
--       AND cic.cost_type_id = 1; --frozen cost/ standard cost
       /* Bug 6630087 - End */

  -- should insert the onhand items that without SubContracting Order.
  --or it will lose the onhand items
  /*
  TODO: owner="sunwa" category="Fix" priority="1 - High" created="2006-1-26"
  text="should insert the onhand items that without SubContracting Order."
  */

    COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_crude_data;

  --========================================================================
  -- PROCEDURE : rpt_get_Comp_Estimated_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the Component Estimated data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_COMPONENT
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_Comp_Estimated_data(p_rpt_mode IN VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_Comp_Estimated_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

    INSERT INTO JMF_SHIKYU_CFR_RPT_TEMP
      (rpt_mode
      ,RPT_DATA_TYPE
      ,oem_inv_org_id
      ,supplier_id
      ,site_id
      ,contact_id
      ,tp_inv_org_id
      ,item_id
      ,shikyu_price
      ,currency_code
      ,uom
      ,project_id
--added to fix project_number related issue start
      ,project_num
--added to fix project_number related issue end
      ,task_id
--added to fix project_number related issue start
      ,task_num
--added to fix project_number related issue end
      ,primary_uom
      ,ESTIMATED_QTY)
      --value SUM(temp.estimated_qty) are supposed to onhand_quantity at item/price level,but got incorrect quantity.
      --got incorrect onhand quantity due to use inapposite group.
      --updated select statement to add transaction_id into group by to get correct onhand quantity.
      /*
      TODO: owner="amy" category="Fix" priority="2 - Severe Loss of Service" created="2006-6-22"
      text="--updated for fix bug 5231233 Begin"
      */
/*      SELECT p_rpt_mode  RPT_MODE  --temp.rpt_mode
            ,CFR_EXT_COMPONENT RPT_DATA_TYPE
            ,temp.oem_inv_org_id shikyu_oem_inv_org_id
            ,temp.supplier_id shikyu_supplier_id
            ,temp.site_id shikyu_site_id
            ,temp.contact_id
            ,temp.tp_inv_org_id shikyu_tp_inv_org_id
            ,temp.item_id shikyu_item_id
            ,temp.shikyu_price shikyu_price
            ,temp.currency_code shikyu_currency
            ,temp.uom shikyu_uom
            ,temp.project_id
            ,temp.task_id
            ,temp.primary_uom shikyu_primary_uom
            ,SUM(temp.estimated_qty) shikyu_estimated_qty
        FROM JMF_SHIKYU_CFR_RPT_TEMP temp
       WHERE temp.rpt_DATA_TYPE = CFR_CRUDE_DATA
       GROUP BY temp.rpt_mode
               ,temp.oem_inv_org_id
               ,temp.supplier_id
               ,temp.site_id
               ,temp.contact_id
               ,temp.tp_inv_org_id
               ,temp.item_id
               ,temp.shikyu_price
               ,temp.currency_code
               ,temp.uom
               ,temp.project_id
               ,temp.task_id
               ,temp.primary_uom;
*/
      SELECT p_rpt_mode  RPT_MODE  --temp.rpt_mode
            ,CFR_EXT_COMPONENT RPT_DATA_TYPE
            ,temp.oem_inv_org_id shikyu_oem_inv_org_id
            ,temp.supplier_id shikyu_supplier_id
            ,temp.site_id shikyu_site_id
            ,temp.contact_id
            ,temp.tp_inv_org_id shikyu_tp_inv_org_id
            ,temp.item_id shikyu_item_id
            ,temp.shikyu_price shikyu_price
            ,temp.currency_code shikyu_currency
            ,temp.uom shikyu_uom
            ,temp.project_id
--added to fix project_number related issue start
            ,temp.project_num
--added to fix project_number related issue end
            ,temp.task_id
--added to fix project_number related issue start
            ,temp.task_num
--added to fix project_number related issue end
            ,temp.primary_uom shikyu_primary_uom
            ,SUM(temp.estimated_qty) shikyu_estimated_qty
        FROM (SELECT rpt_temp.rpt_mode rpt_mode
                                ,rpt_temp.oem_inv_org_id oem_inv_org_id
                                ,rpt_temp.supplier_id supplier_id
                                ,rpt_temp.site_id site_id
                                ,rpt_temp.contact_id contact_id
                                ,rpt_temp.tp_inv_org_id tp_inv_org_id
                                ,rpt_temp.item_id item_id
                                ,rpt_temp.shikyu_price shikyu_price
                                ,rpt_temp.currency_code currency_code
                                ,rpt_temp.uom uom
                                ,rpt_temp.project_id project_id
--added to fix project_number related issue start
                                ,rpt_temp.project_num project_num
--added to fix project_number related issue end
                                ,rpt_temp.task_id task_id
--added to fix project_number related issue start
                                ,rpt_temp.task_num task_num
--added to fix project_number related issue end
                                ,rpt_temp.primary_uom primary_uom
                                ,rpt_temp.estimated_qty
                                ,rpt_temp.transaction_id transaction_id
                     FROM JMF_SHIKYU_CFR_RPT_TEMP rpt_temp
                     WHERE rpt_temp.rpt_DATA_TYPE = CFR_CRUDE_DATA
                     GROUP BY rpt_temp.rpt_mode
                             ,rpt_temp.oem_inv_org_id
                             ,rpt_temp.supplier_id
                             ,rpt_temp.site_id
                             ,rpt_temp.contact_id
                             ,rpt_temp.tp_inv_org_id
                             ,rpt_temp.item_id
                             ,rpt_temp.shikyu_price
                             ,rpt_temp.currency_code
                             ,rpt_temp.uom
                             ,rpt_temp.project_id
--added to fix project_number related issue start
                             ,rpt_temp.project_num
--added to fix project_number related issue end
                             ,rpt_temp.task_id
--added to fix project_number related issue start
                             ,rpt_temp.task_num
--added to fix project_number related issue end
                             ,rpt_temp.primary_uom
                             ,rpt_temp.estimated_qty
                             ,rpt_temp.transaction_id) temp
         GROUP BY temp.rpt_mode
                 ,temp.oem_inv_org_id
                 ,temp.supplier_id
                 ,temp.site_id
                 ,temp.contact_id
                 ,temp.tp_inv_org_id
                 ,temp.item_id
                 ,temp.shikyu_price
                 ,temp.currency_code
                 ,temp.uom
                 ,temp.project_id
--added to fix project_number related issue start
                 ,temp.project_num
--added to fix project_number related issue end
                 ,temp.task_id
--added to fix project_number related issue start
                 ,temp.task_num
--added to fix project_number related issue end
                 ,temp.primary_uom;
    --updated for fix bug #5231233 End

    --seems the SUM(temp.estimated_qty) is not the onhand quantity.
    --add for fix bug 4997302 Begin
    --update the onhand quantity to the ESTIMATED_QTY column, assume the same price and cost, need track
    /*
    TODO: owner="sunwa" category="Fix" priority="1 - High" created="2006-1-26"
    text="--add for fix bug 4997302 Begin"
    */
    -- As the SUM(temp.estimated_qty) is correct by fixing bug #5231233,sql statement below should be updated
      /*
      TODO: owner="amy" category="Fix" priority="2 - Severe Loss of Service" created="2006-6-22"
      text="--updated for fix bug 5231233 Begin"
      */

	    -- Deleted Update to fix bug 5665445 for incorrect onhand Qty in Secondary UOM case
/*      UPDATE JMF_SHIKYU_CFR_RPT_TEMP jscrt
         SET jscrt.estimated_qty = PO_UOM_S.po_uom_convert_p(jscrt.primary_uom
                                                                       ,jscrt.uom
                                                                       ,jscrt.item_id) *jscrt.ESTIMATED_QTY,
                                     (SELECT jscmt.primary_unconsumed_quantity
                                      FROM jmf_shikyu_cfr_mid_temp jscmt
                                     WHERE jscmt.row_type = CFR_TMP_ONHAND_ROW   --10
                                       AND jscmt.tp_inv_org_id =
                                           jscrt.tp_inv_org_id
                                       AND jscmt.item_id = jscrt.item_id),
             jscrt.value1 = (SELECT jscmt.primary_unconsumed_quantity
                                      FROM jmf_shikyu_cfr_mid_temp jscmt
                                     WHERE jscmt.row_type = CFR_TMP_ONHAND_ROW   --10
                                       AND jscmt.tp_inv_org_id =
                                           jscrt.tp_inv_org_id
                                       AND jscmt.item_id = jscrt.item_id)
               jscrt.value1 = jscrt.ESTIMATED_QTY
    --updated for fix bug 5231233 End
       WHERE jscrt.rpt_data_type = CFR_EXT_COMPONENT;  --should not CFR_INT_COMPONENT;
    --add for fix bug 4997302 End
*/

    -- update the SHIKYU_components item number, desc, type info
    UPDATE JMF_SHIKYU_CFR_RPT_TEMP temp
       SET temp.item_number        = (SELECT msibk.concatenated_segments
                                        FROM MTL_SYSTEM_ITEMS_B_KFV msibk
                                       WHERE temp.tp_inv_org_id =
                                             msibk.organization_id
                                         AND temp.item_id =
                                             msibk.inventory_item_id)
          ,temp.item_description   = (SELECT msibk.description
                                        FROM MTL_SYSTEM_ITEMS_B_KFV msibk
                                       WHERE temp.tp_inv_org_id =
                                             msibk.organization_id
                                         AND temp.item_id =
                                             msibk.inventory_item_id)
          ,temp.replenishment_type = (SELECT flv.meaning
                                        FROM fnd_lookup_values      flv
                                            ,MTL_SYSTEM_ITEMS_B_KFV msibk
                                       WHERE flv.LANGUAGE = USERENV('LANG')
                                         AND flv.lookup_type =
                                             'JMF_SHK_ITEM_REPLEN_TYPE'
                                         AND msibk.subcontracting_component =
                                             flv.lookup_code
                                         AND temp.tp_inv_org_id =
                                             msibk.organization_id
                                         AND temp.item_id =
                                             msibk.inventory_item_id)
     WHERE temp.rpt_DATA_TYPE = CFR_EXT_COMPONENT;
     COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_Comp_Estimated_data;

  --========================================================================
  -- PROCEDURE : rpt_get_SubPO_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --                         p_ou_id                          ou_id to identify period infor
  --                         p_days_received             user entered parameter to determine period
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_SUBCONTRACT_PO
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_SubPO_data(p_rpt_mode IN VARCHAR2,p_ou_id IN NUMBER,p_days_received IN NUMBER) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_SubPO_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

    INSERT INTO JMF_SHIKYU_CFR_RPT_TEMP
      (RPT_MODE
      ,RPT_DATA_TYPE
      ,oem_inv_org_id
      ,supplier_id
      ,site_id
      ,tp_inv_org_id
      ,item_id
      ,shikyu_price
      ,currency_code
      ,uom
      ,project_id
--added to fix project_number related issue start
      ,project_num
--added to fix project_number related issue end
      ,task_id
--added to fix project_number related issue start
      ,task_num
--added to fix project_number related issue end
      ,primary_uom
      ,subpo_header_id
      ,subpo_number
      ,subpo_line_num
      ,subpo_release_num
      ,subpo_shipment_num
      ,OSA_ITEM_ID
      ,OSA_ITEM_NUMBER
      ,OSA_ITEM_DESCRIPTION
      ,REQUESTED_COMP_QTY
      ,ISSUED_COMP_QTY)
      SELECT   DISTINCT p_rpt_mode RPT_MODE  --temp.rpt_mode
                     ,CFR_EXT_SUBCONTRACT_PO RPT_DATA_TYPE
                     ,cfr_mid_item_group.oem_inv_org_id oem_inv_org_id
                     ,cfr_mid_item_group.supplier_id supplier_id
                     ,cfr_mid_item_group.site_id site_id
                     ,cfr_mid_item_group.tp_inv_org_id tp_inv_org_id
                     ,cfr_mid_item_group.item_id item_id
                     ,oola.unit_selling_price po_unit_price --not pl.unit_price
                     ,ooha.transactional_curr_code currency_code --or jmf_shikyu_components.Currency ,not ph.currency_code
                     ,cfr_mid_item_group.uom --should jmf_shikyu_components.uom,need rcv.unit_of_measure to conversion?
                     ,jso.project_id project_id
--Added to fix project_number related issue start
                     ,NVL((SELECT DISTINCT segment1 AS project_number
                              FROM pa_projects_all
                            WHERE pa_projects_all.project_id(+) = jso.project_id),
                          (SELECT DISTINCT project_number
                           FROM   pjm_seiban_numbers
                           WHERE pjm_seiban_numbers.project_id(+) = jso.project_id)) project_number
--Added to fix project_number related issue end
                     ,jso.task_id task_id
--Added to get task number  start
                     ,task.task_number task_number
--Added to get task number  end
                     ,cfr_mid_item_group.primary_uom --rcv.primary_unit_of_measure
                     ,pha_s.po_header_id SubPO_header_id
                     ,pha_s.segment1 SubPO_Number
                     ,pla_s.line_num SubPO_Line_num
                     ,pra_s.release_num SubPO_release_Num
                     ,plla_s.shipment_num SubPO_shipment_NUm
                     ,jso.osa_item_id
                     ,msibk.concatenated_segments
                     ,msibk.description
                     ,wro.required_quantity
                     ,wro.quantity_issued
                  FROM jmf_subcontract_orders jso
                      ,jmf_shikyu_components jsc
                      ,(select DISTINCT cfr_mid_temp.oem_inv_org_id oem_inv_org_id
                                                   ,cfr_mid_temp.supplier_id supplier_id
                                                   ,cfr_mid_temp.site_id site_id
                                                   ,cfr_mid_temp.tp_inv_org_id tp_inv_org_id
                                                   ,cfr_mid_temp.item_id item_id
                                                   ,cfr_mid_temp.uom
                                                   ,cfr_mid_temp.primary_uom
                        from jmf_shikyu_cfr_mid_temp cfr_mid_temp
                        where cfr_mid_temp.row_type = CFR_TMP_RCV_ROW) cfr_mid_item_group
                      ,jmf_shikyu_replenishments jsr
                      ,jmf_shikyu_allocations    jsa
                      ,oe_order_lines_all        oola
                      ,oe_order_headers_all      ooha
                      ,po_line_locations_all     plla_s
                      ,po_headers_all            pha_s
                      ,po_lines_all              pla_s
                      ,po_releases_all           pra_s
                      ,wip_requirement_operations wro
                      ,MTL_SYSTEM_ITEMS_B_KFV     msibk
                      ,rcv_transactions rt
--Added to get task start
                      ,pa_tasks                  task
--Added to get task end
                 WHERE jsc.SHIKYU_COMPONENT_ID = cfr_mid_item_group.item_id
                   AND jsc.OEM_ORGANIZATION_ID = cfr_mid_item_group.oem_inv_org_id
                   AND jsc.UOM = JMF_SHIKYU_RPT_UTIL.uom_to_code(cfr_mid_item_group.uom)
                   AND jsc.PRIMARY_UOM = JMF_SHIKYU_RPT_UTIL.uom_to_code(cfr_mid_item_group.primary_uom)
                   AND jso.TP_ORGANIZATION_ID = cfr_mid_item_group.tp_inv_org_id
                   AND jso.OEM_ORGANIZATION_ID = cfr_mid_item_group.oem_inv_org_id
                   AND jso.SUBCONTRACT_PO_SHIPMENT_ID = jsc.SUBCONTRACT_PO_SHIPMENT_ID
                   AND jsc.SUBCONTRACT_PO_SHIPMENT_ID = jsa.SUBCONTRACT_PO_SHIPMENT_ID
                   AND jsc.SHIKYU_COMPONENT_ID = jsa.SHIKYU_COMPONENT_ID
                   AND jsa.REPLENISHMENT_SO_LINE_ID = jsr.REPLENISHMENT_SO_LINE_ID
                   AND jsr.REPLENISHMENT_SO_LINE_ID = oola.LINE_ID
                   AND oola.HEADER_ID = ooha.HEADER_ID
                   AND plla_s.LINE_LOCATION_ID = jsa.SUBCONTRACT_PO_SHIPMENT_ID
                   AND pla_s.PO_LINE_ID=plla_s.PO_LINE_ID
                   AND pla_s.PO_HEADER_ID=plla_s.PO_HEADER_ID
                   AND pha_s.PO_HEADER_ID=pla_s.PO_HEADER_ID
                   AND plla_s.po_release_id = pra_s.po_release_id(+)
                   AND jso.osa_item_id = msibk.inventory_item_id
                   AND jso.tp_organization_id = wro.organization_id
                   AND jso.wip_entity_id = wro.wip_entity_id
                   AND jso.interlock_status = 'C' --added to fix bug 5415777
                   AND wro.operation_seq_num = 1
                   AND wro.repetitive_schedule_id IS NULL
                   AND cfr_mid_item_group.item_id = wro.inventory_item_id
                   AND plla_s.QUANTITY_RECEIVED>0
                   and plla_s.LINE_LOCATION_ID = rt.PO_LINE_LOCATION_ID
                   and rt.transaction_date < sysdate+1--period to date
                   and rt.transaction_date >= sysdate-p_days_received --period from date
--Added to get task start
                    AND jso.task_id = task.task_id(+)
--Added to get task end
                   ;

              COMMIT; -- for debug on UT ?????

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_SubPO_data;

  --========================================================================
  -- PROCEDURE : rpt_get_UnReceived_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_UN_RCV
  -- PRE-COND  :
  -- EXCEPTIONS: do not consider the SO return, and RepSO with RepPO is one to one.
  --========================================================================
  PROCEDURE rpt_get_UnReceived_data
  (
   p_rpt_mode IN VARCHAR2
  -- Amy added to fix bug 5583680 start
  ,p_supplier_name_from      IN VARCHAR2
  ,p_supplier_site_code_from IN VARCHAR2
  ,p_supplier_name_to        IN VARCHAR2
  ,p_supplier_site_code_to   IN VARCHAR2
  ,p_oem_inv_org_name_from   IN VARCHAR2
  ,p_oem_inv_org_name_to     IN VARCHAR2) IS
  -- Amy added to fix bug 5583680 end

  l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_UnReceived_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

   INSERT INTO JMF_SHIKYU_CFR_RPT_TEMP
     (rpt_mode
     ,rpt_data_type
     ,Oem_Inv_Org_Id
     ,Tp_Inv_Org_Id
     ,Supplier_Id
     ,Site_Id
     ,rep_so_header_id
     ,rep_so_number
     ,rep_so_line_id
     ,rep_so_line
     ,rep_po_header_id
     ,rep_po_number
     ,rep_po_line_id
     ,rep_po_line
     ,rep_po_line_location_id
     ,rep_po_shipment
     ,rep_po_release_id
     ,rep_po_release_num
     ,item_id
     ,item_number
     ,estimated_qty
     ,uom
     ,shipped_date
     ,expected_rcv_date)
     SELECT p_rpt_mode rpt_mode
           ,CFR_EXT_UN_RCV rpt_data_type
           ,jsr.oem_organization_id -- = oola.ship_from_org_id
           ,jsr.tp_organization_id -- = plla.ship_to_organization_id
           ,hoi.org_information3     -- the tp org 's supplier = SubPO supplier
           ,hoi.org_information4     -- the tp org 's supplier site  = SubPO site
           ,ooha.header_id rep_so_header_id
           ,ooha.order_number rep_so_number
           ,oola.line_id rep_so_line_id
           ,oola.line_number rep_so_line
           ,pha.po_header_id rep_po_header_id
           ,pha.segment1 rep_po_number
           ,pla.po_line_id rep_po_line_id
           ,pla.line_num rep_po_line
           ,plla.line_location_id rep_po_line_location_id
           ,plla.shipment_num rep_po_shipment
           ,pra.po_release_id rep_po_release_id
           ,pra.release_num rep_po_release_num
           ,oola.inventory_item_id item_id --jsr.shikyu_component_id
           ,oola.ordered_item item_number
           ,oola.shipped_quantity estimated_qty
           ,oola.order_quantity_uom uom
           ,oola.actual_shipment_date shipped_date
           ,NVL(plla.need_by_date
               ,plla.promised_date) expected_rcv_date
       FROM oe_order_lines_all        oola
           ,oe_order_headers_all      ooha
           ,po_line_locations_all     plla
           ,po_lines_all              pla
           ,po_releases_all           pra
           ,po_headers_all            pha
           ,jmf_shikyu_replenishments jsr
           ,hr_organization_information hoi
		   -- Amy added to fix bug 5583680 start
		   ,hr_all_organization_units_tl oem_haoutl
		   ,hr_organization_information  tp_hoi
		   ,po_vendors                   pv
		   ,po_vendor_sites_all          pvs
		   -- Amy added to fix bug 5583680 end
      WHERE oola.header_id = ooha.header_id
        AND plla.po_line_id = pla.po_line_id
        AND plla.po_header_id = pha.po_header_id
        AND plla.po_release_id = pra.po_release_id(+)
        AND oola.line_id = jsr.replenishment_so_line_id
        AND plla.line_location_id = jsr.replenishment_po_shipment_id
        AND jsr.tp_organization_id = hoi.organization_id
        AND hoi.org_information_context = 'Customer/Supplier Association'
	    -- Amy updated to fix bug 5583680 start
        /*AND (SELECT COUNT(*)
               FROM JMF_SHIKYU_CFR_RPT_TEMP jscrt
              WHERE jscrt.rpt_data_type = CFR_EXT_COMPONENT
                AND jscrt.oem_inv_org_id = jsr.oem_organization_id
                AND jscrt.tp_inv_org_id = jsr.tp_organization_id) > 0
        AND JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(oola.sold_from_org_id
                                                         ,oola.inventory_item_id
                                                         ,oola.order_quantity_uom
                                                         ,NVL(oola.shipped_quantity
                                                             ,0)) >
            JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(plla.ship_to_organization_id
                                                         ,pla.item_id
                                                         ,JMF_SHIKYU_RPT_UTIL.uom_to_code(pla.unit_meas_lookup_code)
                                                         ,NVL(plla.quantity_received
                                                             ,0));*/
		AND jsr.oem_organization_id = oem_haoutl.organization_id
		AND oem_haoutl.NAME >= NVL(p_oem_inv_org_name_from
		                          ,oem_haoutl.NAME)
		AND oem_haoutl.NAME <= NVL(p_oem_inv_org_name_to
		                          ,oem_haoutl.NAME)
		AND oem_haoutl.LANGUAGE = USERENV('LANG')
		AND jsr.tp_organization_id = tp_hoi.organization_id
		AND tp_hoi.org_information_context = 'Customer/Supplier Association'
		AND tp_hoi.org_information3 = pv.vendor_id
		AND tp_hoi.org_information4 = pvs.vendor_site_id
		AND pv.vendor_name >= NVL(p_supplier_name_from, pv.vendor_name)
		AND pv.vendor_name <= NVL(p_supplier_name_to, pv.vendor_name)
		AND pvs.vendor_site_code >= NVL(p_supplier_site_code_from, pvs.vendor_site_code)
		AND pvs.vendor_site_code <= NVL(p_supplier_site_code_to, pvs.vendor_site_code)
        AND NVL(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(jsr.oem_organization_id
		                                                         ,oola.inventory_item_id
		                                                         ,oola.order_quantity_uom
		                                                         ,NVL(oola.shipped_quantity
                                                             ,0)),0) >
            NVL(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(plla.ship_to_organization_id
		                                                         ,pla.item_id
		                                                         ,JMF_SHIKYU_RPT_UTIL.uom_to_code(pla.unit_meas_lookup_code)
		                                                         ,NVL(plla.quantity_received
                                                             ,0)),0);
		-- Amy updated to fix bug 5583680 end
     COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_UnReceived_data;

  --========================================================================
  -- PROCEDURE : rpt_get_Received_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the received data in days into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_RCV_IN_DAYS
  -- PRE-COND  :
  -- EXCEPTIONS: do not consider the SO return, and RepSO with RepPO is one to one.
  --========================================================================
  PROCEDURE rpt_get_Received_data(
   p_rpt_mode IN VARCHAR2
  ,p_days_received IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_Received_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

    -- data that Shipped = received and exptected rcv date is in p_days_received
    INSERT INTO JMF_SHIKYU_CFR_RPT_TEMP
      (rpt_mode
      ,rpt_data_type
      ,Oem_Inv_Org_Id
      ,Tp_Inv_Org_Id
      ,Supplier_Id
      ,Site_Id
      ,rep_so_header_id
      ,rep_so_number
      ,rep_so_line_id
      ,rep_so_line
      ,rep_po_header_id
      ,rep_po_number
      ,rep_po_line_id
      ,rep_po_line
      ,rep_po_line_location_id
      ,rep_po_shipment
      ,rep_po_release_id
      ,rep_po_release_num
      ,item_id
      ,item_number
      ,estimated_qty
      ,uom
      ,shipped_date
      ,expected_rcv_date)
      SELECT p_rpt_mode rpt_mode
            ,CFR_EXT_RCV_IN_DAYS rpt_data_type
            ,jsr.oem_organization_id  -- = oola.ship_from_org_id
            ,jsr.tp_organization_id   -- = plla.ship_to_organization_id
            ,hoi.org_information3     -- the tp org 's supplier = SubPO supplier
            ,hoi.org_information4     -- the tp org 's supplier site  = SubPO site
            ,ooha.header_id rep_so_header_id
            ,ooha.order_number rep_so_number
            ,oola.line_id rep_so_line_id
            ,oola.line_number rep_so_line
            ,pha.po_header_id rep_po_header_id
            ,pha.segment1 rep_po_number
            ,pla.po_line_id rep_po_line_id
            ,pla.line_num rep_po_line
            ,plla.line_location_id rep_po_line_location_id
            ,plla.shipment_num rep_po_shipment
            ,pra.po_release_id rep_po_release_id
            ,pra.release_num rep_po_release_num
            ,oola.inventory_item_id item_id --jsr.shikyu_component_id
            ,oola.ordered_item item_number
            ,oola.shipped_quantity estimated_qty
            ,oola.order_quantity_uom uom
            ,oola.actual_shipment_date shipped_date
            ,NVL(plla.need_by_date
                ,plla.promised_date) expected_rcv_date
        FROM oe_order_lines_all        oola
            ,oe_order_headers_all      ooha
            ,po_line_locations_all     plla
            ,po_lines_all              pla
            ,po_releases_all           pra
            ,po_headers_all            pha
            ,jmf_shikyu_replenishments jsr
            ,hr_organization_information hoi
       WHERE oola.header_id = ooha.header_id
         AND plla.po_line_id = pla.po_line_id
         AND plla.po_header_id = pha.po_header_id
         AND plla.po_release_id = pra.po_release_id(+)
         AND oola.line_id = jsr.replenishment_so_line_id
         AND plla.line_location_id = jsr.replenishment_po_shipment_id
         AND jsr.tp_organization_id = hoi.organization_id
         AND hoi.org_information_context = 'Customer/Supplier Association'
         AND (SELECT COUNT(*)
               FROM JMF_SHIKYU_CFR_RPT_TEMP jscrt
              WHERE jscrt.rpt_data_type = CFR_EXT_COMPONENT
                AND jscrt.oem_inv_org_id = jsr.oem_organization_id
                AND jscrt.tp_inv_org_id = jsr.tp_organization_id) > 0
         AND (SYSDATE - NVL(plla.need_by_date
                           ,plla.promised_date)) <= p_days_received
         -- Bug 5583680: Fixed data issue for the Received Replenishments in
         -- Past xx Days section
         AND NVL(oola.shipped_quantity,0) > 0
         AND NVL(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(jsr.oem_organization_id
                                                          ,oola.inventory_item_id
                                                          ,oola.order_quantity_uom
                                                          ,NVL(oola.shipped_quantity
                                                              ,0)),0) =
             NVL(JMF_SHIKYU_RPT_UTIL.get_item_primary_quantity(plla.ship_to_organization_id
                                                          ,pla.item_id
                                                          ,JMF_SHIKYU_RPT_UTIL.uom_to_code(pla.unit_meas_lookup_code)
                                                          ,NVL(plla.quantity_received
                                                              ,0)),0);
       COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_Received_data;

  --========================================================================
  -- PROCEDURE : rpt_get_Int_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the Component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_INT_COMPONENT
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_Int_data(p_rpt_mode IN VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_Int_data';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

    -- get the data for internal report
    INSERT INTO jmf_shikyu_cfr_rpt_temp
      (rpt_mode
      ,rpt_data_type
      ,oem_inv_org_id
      ,oem_inv_org_code
      ,oem_inv_org_name
      ,oem_inv_org_address
      ,supplier_id
      ,supplier_name
      ,site_id
      ,site_code
      ,site_address
      ,tp_inv_org_id
      ,tp_inv_org_code
      ,project_id
      ,project_num
      ,task_id
      ,task_num
      ,item_id
      ,item_number
      ,item_description
      ,estimated_qty
      ,primary_uom
      ,shikyu_price
      ,currency_code
      ,uom
      ,item_cost
      ,functional_currency
      ,value1  --Qty in Primary UOM
      ,value2  --SHIKYU Price in Pri UOM and Pri Currency
      ,value3) --SHIKYU Cost in Pri UOM and Pri Currency
      --value SUM(temp.estimated_qty) are supposed to onhand_quantity at item/price level,but got incorrect quantity.
      --got incorrect onhand quantity due to use inapposite group.
      --updated select statement to add transaction_id into group by to get correct onhand quantity.
      /*
      TODO: owner="amy" category="Fix" priority="2 - Severe Loss of Service" created="2006-6-22"
      text="--updated for fix bug 5231233 Begin"
      */
/*      SELECT p_rpt_mode rpt_mode
            ,CFR_INT_COMPONENT rpt_data_type
            ,jscrt.oem_inv_org_id Iss_oem_inv_org_id
            ,jscrt.oem_inv_org_code Iss_oem_inv_org_code
            ,haou.name Iss_oem_inv_org_name
            ,jscrt.oem_inv_org_address Iss_oem_inv_org_address
            ,jscrt.supplier_id Iss_supplier_id
            ,jscrt.supplier_name Iss_supplier_name
            ,jscrt.site_id Iss_site_id
            ,jscrt.site_code Iss_site_code
            ,jscrt.site_address Iss_site_address
            ,jscrt.tp_inv_org_id Iss_tp_inv_org_id
            ,jscrt.tp_inv_org_code Iss_tp_inv_org_code
            ,jscrt.project_id Iss_project_id
            ,jscrt.project_num Iss_project_num
            ,jscrt.task_id Iss_task_id
            ,jscrt.task_num Iss_task_num
            ,jscrt.item_id Iss_item_id
            ,jscrt.item_number Iss_item_number
            ,jscrt.item_description Iss_item_description
            ,SUM(jscrt.estimated_qty) Iss_estimated_qty_Sum
            ,jscrt.primary_uom Iss_primary_uom
            ,jscrt.shikyu_price Iss_shikyu_price
            ,jscrt.currency_code Iss_currency_code
            ,jscrt.uom Iss_uom
            ,jscrt.item_cost Iss_item_cost
            ,jscrt.functional_currency Iss_functional_currency
            ,SUM(jscrt.value1) Iss_estimated_qty_Sum_Pri
            ,jscrt.value2 Iss_SHIKYU_Price_PriU
            ,jscrt.value3 Iss_SHIKYU_Cost_PriU
        FROM jmf_shikyu_cfr_rpt_temp jscrt
            ,HR_ALL_ORGANIZATION_UNITS haou
       WHERE jscrt.oem_inv_org_id = haou.organization_id
         AND jscrt.rpt_data_type = CFR_CRUDE_DATA
       GROUP BY jscrt.oem_inv_org_id
               ,jscrt.oem_inv_org_code
               ,haou.name
               ,jscrt.oem_inv_org_address
               ,jscrt.supplier_id
               ,jscrt.supplier_name
               ,jscrt.site_id
               ,jscrt.site_code
               ,jscrt.site_address
               ,jscrt.tp_inv_org_id
               ,jscrt.tp_inv_org_code
               ,jscrt.project_id
               ,jscrt.project_num
               ,jscrt.task_id
               ,jscrt.task_num
               ,jscrt.item_id
               ,jscrt.item_number
               ,jscrt.item_description
               ,jscrt.primary_uom
               ,jscrt.shikyu_price
               ,jscrt.currency_code
               ,jscrt.uom
               ,jscrt.item_cost
               ,jscrt.functional_currency
               ,jscrt.value2
               ,jscrt.value3
               ;
*/
      SELECT rpt_temp.rpt_mode
            ,rpt_temp.rpt_data_type
            ,rpt_temp.oem_inv_org_id Iss_oem_inv_org_id
            ,rpt_temp.oem_inv_org_code Iss_oem_inv_org_code
            ,rpt_temp.oem_inv_org_name Iss_oem_inv_org_name
            ,rpt_temp.oem_inv_org_address Iss_oem_inv_org_address
            ,rpt_temp.supplier_id Iss_supplier_id
            ,rpt_temp.supplier_name Iss_supplier_name
            ,rpt_temp.site_id Iss_site_id
            ,rpt_temp.site_code Iss_site_code
            ,rpt_temp.site_address Iss_site_address
            ,rpt_temp.tp_inv_org_id Iss_tp_inv_org_id
            ,rpt_temp.tp_inv_org_code Iss_tp_inv_org_code
            ,rpt_temp.project_id Iss_project_id
            ,rpt_temp.project_num Iss_project_num
            ,rpt_temp.task_id Iss_task_id
            ,rpt_temp.task_num Iss_task_num
            ,rpt_temp.item_id Iss_item_id
            ,rpt_temp.item_number Iss_item_number
            ,rpt_temp.item_description Iss_item_description
            ,SUM(rpt_temp.estimated_qty) Iss_estimated_qty_Sum
            ,rpt_temp.primary_uom Iss_primary_uom
            ,rpt_temp.shikyu_price Iss_shikyu_price
            ,rpt_temp.currency_code Iss_currency_code
            ,rpt_temp.uom Iss_uom
            ,rpt_temp.item_cost Iss_item_cost
            ,rpt_temp.functional_currency Iss_functional_currency
            ,SUM(rpt_temp.value1) Iss_estimated_qty_Sum_Pri
            ,rpt_temp.value2 Iss_SHIKYU_Price_PriU
            ,rpt_temp.value3 Iss_SHIKYU_Cost_PriU
        FROM  (
      SELECT p_rpt_mode rpt_mode
             ,CFR_INT_COMPONENT rpt_data_type
            ,jscrt.oem_inv_org_id oem_inv_org_id
            ,jscrt.oem_inv_org_code oem_inv_org_code
            ,haou.name oem_inv_org_name
            ,jscrt.oem_inv_org_address oem_inv_org_address
            ,jscrt.supplier_id supplier_id
            ,jscrt.supplier_name supplier_name
            ,jscrt.site_id site_id
            ,jscrt.site_code site_code
            ,jscrt.site_address site_address
            ,jscrt.tp_inv_org_id tp_inv_org_id
            ,jscrt.tp_inv_org_code tp_inv_org_code
            ,jscrt.project_id project_id
            ,jscrt.project_num project_num
            ,jscrt.task_id task_id
            ,jscrt.task_num task_num
            ,jscrt.item_id item_id
            ,jscrt.item_number item_number
            ,jscrt.item_description item_description
            ,jscrt.estimated_qty estimated_qty
            ,jscrt.primary_uom primary_uom
            ,jscrt.shikyu_price shikyu_price
            ,jscrt.currency_code currency_code
            ,jscrt.uom uom
            ,jscrt.item_cost item_cost
            ,jscrt.functional_currency functional_currency
            ,jscrt.value1 value1
            ,jscrt.value2 value2
            ,jscrt.value3 value3
            ,jscrt.transaction_id transaction_id
        FROM jmf_shikyu_cfr_rpt_temp jscrt
            ,HR_ALL_ORGANIZATION_UNITS_TL haou
       WHERE jscrt.oem_inv_org_id = haou.organization_id
         AND jscrt.rpt_data_type = CFR_CRUDE_DATA
         AND haou.language = USERENV('LANG')
       GROUP BY jscrt.rpt_mode
               ,jscrt.oem_inv_org_id
               ,jscrt.oem_inv_org_code
               ,haou.name
               ,jscrt.oem_inv_org_address
               ,jscrt.supplier_id
               ,jscrt.supplier_name
               ,jscrt.site_id
               ,jscrt.site_code
               ,jscrt.site_address
               ,jscrt.tp_inv_org_id
               ,jscrt.tp_inv_org_code
               ,jscrt.project_id
               ,jscrt.project_num
               ,jscrt.task_id
               ,jscrt.task_num
               ,jscrt.item_id
               ,jscrt.item_number
               ,jscrt.item_description
               ,jscrt.primary_uom
               ,jscrt.shikyu_price
               ,jscrt.currency_code
               ,jscrt.uom
               ,jscrt.item_cost
               ,jscrt.functional_currency
               ,jscrt.value2
               ,jscrt.value3
               ,jscrt.transaction_id
               ,jscrt.estimated_qty
               ,jscrt.value1
               ) rpt_temp
   GROUP BY rpt_temp.rpt_mode
           ,rpt_temp.rpt_data_type
           ,rpt_temp.oem_inv_org_id
           ,rpt_temp.oem_inv_org_code
           ,rpt_temp.oem_inv_org_name
           ,rpt_temp.oem_inv_org_address
           ,rpt_temp.supplier_id
           ,rpt_temp.supplier_name
           ,rpt_temp.site_id
           ,rpt_temp.site_code
           ,rpt_temp.site_address
           ,rpt_temp.tp_inv_org_id
           ,rpt_temp.tp_inv_org_code
           ,rpt_temp.project_id
           ,rpt_temp.project_num
           ,rpt_temp.task_id
           ,rpt_temp.task_num
           ,rpt_temp.item_id
           ,rpt_temp.item_number
           ,rpt_temp.item_description
           ,rpt_temp.primary_uom
           ,rpt_temp.shikyu_price
           ,rpt_temp.currency_code
           ,rpt_temp.uom
           ,rpt_temp.item_cost
           ,rpt_temp.functional_currency
           ,rpt_temp.value2
           ,rpt_temp.value3;
    --updated for fix bug #5231233 End

    --seems the SUM(temp.estimated_qty) is not the onhand quantity.
    --add for fix bug 4997302 Begin
    --update the onhand quantity to the ESTIMATED_QTY column, assume the same price and cost, need track
    /*
    TODO: owner="sunwa" created="2006-1-26"
    text="--add for fix bug 4997302 Begin Internal"
    */
    -- modify the onhand quantity, for
    -- As the SUM(temp.estimated_qty) is correct by fixing bug #5231233,sql statement below should be updated
      /*
      TODO: owner="amy" category="Fix" priority="2 - Severe Loss of Service" created="2006-6-22"
      text="--updated for fix bug 5231233 Begin Internal"
      */

	    -- Deleted Update to fix bug 5665445 for incorrect onhand Qty in Secondary UOM case
/*      UPDATE JMF_SHIKYU_CFR_RPT_TEMP jscrt
         SET jscrt.estimated_qty = PO_UOM_S.po_uom_convert_p(jscrt.primary_uom
                                                                       ,jscrt.uom
                                                                       ,jscrt.item_id) *jscrt.ESTIMATED_QTY,
                                   (SELECT jscmt.primary_unconsumed_quantity
                                      FROM jmf_shikyu_cfr_mid_temp jscmt
                                     WHERE jscmt.row_type = CFR_TMP_ONHAND_ROW   --10
                                       AND jscmt.tp_inv_org_id =
                                           jscrt.tp_inv_org_id
                                       AND jscmt.item_id = jscrt.item_id),
             jscrt.value1 = (SELECT jscmt.primary_unconsumed_quantity
                                      FROM jmf_shikyu_cfr_mid_temp jscmt
                                     WHERE jscmt.row_type = CFR_TMP_ONHAND_ROW   --10
                                       AND jscmt.tp_inv_org_id =
                                           jscrt.tp_inv_org_id
                                       AND jscmt.item_id = jscrt.item_id)
               jscrt.value1 = jscrt.ESTIMATED_QTY
    --updated for fix bug 5231233 End Internal
       WHERE jscrt.rpt_data_type = CFR_INT_COMPONENT;
     -- modify the cost and price
*/
    --add for fix bug 4997302 Begin

       COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => SQLERRM);
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_Int_data;

  --========================================================================
  -- PROCEDURE : rpt_get_SubPO_data_Onhand    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --                      These subPOs can affect onhand quantity in MP inventory.
  --             RPT_DATA_TYPE = CFR_EXT_SUBPO_AFT_ONHAND
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_SubPO_data_Onhand(p_rpt_mode IN VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_get_SubPO_data_Onhand';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                ,p_message   => 'begin:');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name
                    ,'.begin');
    END IF;

    INSERT INTO JMF_SHIKYU_CFR_RPT_TEMP
      (RPT_MODE
      ,RPT_DATA_TYPE
      ,oem_inv_org_id
      ,supplier_id
      ,site_id
      ,tp_inv_org_id
      ,item_id
      ,shikyu_price
      ,currency_code
      ,uom
      ,project_id
      ,task_id
      ,primary_uom
      ,subpo_header_id
      ,subpo_number
      ,subpo_line_num
      ,subpo_release_num
      ,subpo_shipment_num
      ,OSA_ITEM_ID
      ,OSA_ITEM_NUMBER
      ,OSA_ITEM_DESCRIPTION
      ,REQUESTED_COMP_QTY
      ,ISSUED_COMP_QTY)
      SELECT DISTINCT p_rpt_mode RPT_MODE  --temp.rpt_mode
                     ,CFR_EXT_SUBPO_AFT_ONHAND RPT_DATA_TYPE
                     ,temp.oem_inv_org_id shikyu_oem_inv_org_id
                     ,temp.supplier_id shikyu_supplier_id
                     ,temp.site_id shikyu_site_id
                     ,temp.tp_inv_org_id shikyu_tp_inv_org_id
                     ,temp.item_id shikyu_item_id
                     ,temp.shikyu_price shikyu_price
                     ,temp.currency_code shikyu_currency
                     ,temp.uom shikyu_uom
                     ,temp.project_id
                     ,temp.task_id
                     ,temp.primary_uom shikyu_primary_uom
                     ,temp.subpo_header_id
                     ,temp.subpo_number
                     ,temp.subpo_line_num
                     ,temp.subpo_release_num
                     ,temp.subpo_shipment_num
                     ,jso.osa_item_id
                     ,msibk.concatenated_segments
                     ,msibk.description
                     ,wro.required_quantity
                     ,wro.quantity_issued
        FROM JMF_SHIKYU_CFR_RPT_TEMP    temp
            ,jmf_subcontract_orders     jso
            ,wip_requirement_operations wro
            ,MTL_SYSTEM_ITEMS_B_KFV     msibk
       WHERE temp.rpt_DATA_TYPE = CFR_CRUDE_DATA
         AND temp.subpo_shipment_id = jso.subcontract_po_shipment_id
         AND jso.oem_organization_id = msibk.organization_id
         AND jso.osa_item_id = msibk.inventory_item_id
         AND jso.tp_organization_id = wro.organization_id
         AND jso.wip_entity_id = wro.wip_entity_id
         AND wro.operation_seq_num = 1
         AND wro.repetitive_schedule_id IS NULL
         AND temp.item_id = wro.inventory_item_id;
       COMMIT; -- for debug on UT ?????
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y'
         AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,G_MODULE_PREFIX || l_api_name || '.execption'
                      ,NULL);
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => 'FND_LOG.STRING'
                                  ,p_api_name  => G_MODULE_PREFIX || l_api_name
                                  ,p_message   => 'WHEN OTHERS THEN');
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_get_SubPO_data_Onhand;

  --========================================================================
  -- PROCEDURE : rpt_debug_show_mid_data    PUBLIC ,
  -- PARAMETERS: p_row_type                 row type in jmf_shikyu_cfr_mid_temp
  --             p_output_to                the parameter for debug_output
  -- COMMENT   : show the data in temp table jmf_shikyu_cfr_mid_temp
  --             using debug_output
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_debug_show_mid_data
  (
    p_row_type  IN VARCHAR2
   ,p_output_to IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_debug_show_mid_data';

    CURSOR l_cur_get_mid_temp_data(lp_row_type jmf_shikyu_cfr_mid_temp.row_type%TYPE) IS
      SELECT row_type
            ,shikyu_id
            ,tp_inv_org_id
            ,item_id
            ,uom
            ,quantity
            ,primary_uom
            ,primary_unallocated_quantity
            ,primary_unconsumed_quantity
            ,project_id
            ,task_id
            ,oem_inv_org_id
            ,supplier_id
            ,site_id
            ,ou_id
            ,get_rcv_flag
            ,get_rep_flag
        FROM jmf_shikyu_cfr_mid_temp
       WHERE (lp_row_type IS NULL)
          OR (row_type = lp_row_type)
       ORDER BY row_type
               ,shikyu_id
               ,item_id;

    l_row_type                     jmf_shikyu_cfr_mid_temp.row_type%TYPE;
    l_shikyu_id                    jmf_shikyu_cfr_mid_temp.shikyu_id%TYPE;
    l_tp_inv_org_id                jmf_shikyu_cfr_mid_temp.tp_inv_org_id%TYPE;
    l_item_id                      jmf_shikyu_cfr_mid_temp.item_id%TYPE;
    l_uom                          jmf_shikyu_cfr_mid_temp.uom%TYPE;
    l_quantity                     jmf_shikyu_cfr_mid_temp.quantity%TYPE;
    l_primary_uom                  jmf_shikyu_cfr_mid_temp.primary_uom%TYPE;
    l_primary_unallocated_quantity jmf_shikyu_cfr_mid_temp.primary_unallocated_quantity%TYPE;
    l_primary_unconsumed_quantity  jmf_shikyu_cfr_mid_temp.primary_unconsumed_quantity%TYPE;
    l_project_id                   jmf_shikyu_cfr_mid_temp.project_id%TYPE;
    l_task_id                      jmf_shikyu_cfr_mid_temp.task_id%TYPE;
    l_oem_inv_org_id               jmf_shikyu_cfr_mid_temp.oem_inv_org_id%TYPE;
    l_supplier_id                  jmf_shikyu_cfr_mid_temp.supplier_id%TYPE;
    l_site_id                      jmf_shikyu_cfr_mid_temp.site_id%TYPE;
    l_ou_id                        jmf_shikyu_cfr_mid_temp.ou_id%TYPE;
    l_get_rcv_flag                 jmf_shikyu_cfr_mid_temp.get_rcv_flag%TYPE;
    l_get_rep_flag                 jmf_shikyu_cfr_mid_temp.get_rep_flag%TYPE;

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                    ,p_api_name  => G_MODULE_PREFIX ||
                                                    l_api_name
                                    ,p_message   => '==jmf_shikyu_cfr_mid_temp data Begin==');
    -- **** for debug information in readonly UT environment.--- end ****
    OPEN l_cur_get_mid_temp_data(p_row_type);
    LOOP
      --print the data in l_cur_get_mid_temp_data
      FETCH l_cur_get_mid_temp_data
        INTO   l_row_type
              ,l_shikyu_id
              ,l_tp_inv_org_id
              ,l_item_id
              ,l_uom
              ,l_quantity
              ,l_primary_uom
              ,l_primary_unallocated_quantity
              ,l_primary_unconsumed_quantity
              ,l_project_id
              ,l_task_id
              ,l_oem_inv_org_id
              ,l_supplier_id
              ,l_site_id
              ,l_ou_id
              ,l_get_rcv_flag
              ,l_get_rep_flag;

      EXIT WHEN l_cur_get_mid_temp_data%NOTFOUND;

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                      ,p_api_name  => G_MODULE_PREFIX ||
                                                      l_api_name
                                      ,p_message   => 'jmf_shikyu_cfr_mid_temp:' ||
                                                      ';row_type[' || 	l_row_type	 || ']' ||
                                                      ';shikyu_id[' ||	l_shikyu_id	 || ']' ||
                                                      ';tp_inv_org_id[' ||	l_tp_inv_org_id	 || ']' ||
                                                      ';item_id[' ||	l_item_id	 || ']' ||
                                                      ';uom[' ||	l_uom	 || ']' ||
                                                      ';quantity[' ||	l_quantity	 || ']' ||
                                                      ';primary_uom[' ||	l_primary_uom	 || ']' ||
                                                      ';primary_unallocated_quantity[' ||	l_primary_unallocated_quantity	 || ']' ||
                                                      ';primary_unconsumed_quantity[' ||	l_primary_unconsumed_quantity	 || ']' ||
                                                      ';project_id[' ||	l_project_id	 || ']' ||
                                                      ';task_id[' ||	l_task_id	 || ']' ||
                                                      ';oem_inv_org_id[' ||	l_oem_inv_org_id	 || ']' ||
                                                      ';supplier_id[' ||	l_supplier_id	 || ']' ||
                                                      ';site_id[' ||	l_site_id	 || ']' ||
                                                      ';ou_id[' ||	l_ou_id	 || ']' ||
                                                      ';get_rcv_flag[' ||	l_get_rcv_flag	 || ']' ||
                                                      ';get_rep_flag[' ||	l_get_rep_flag	 || ']'
                                      );
      -- **** for debug information in readonly UT environment.--- end ****

    END LOOP; --end loop of l_cur_get_mid_temp_data
    CLOSE l_cur_get_mid_temp_data;

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                    ,p_api_name  => G_MODULE_PREFIX ||
                                                    l_api_name
                                    ,p_message   => '==jmf_shikyu_cfr_mid_temp data end==');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING( FND_LOG.LEVEL_PROCEDURE
                    , g_module_prefix || l_api_name || '.end'
                    , NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                      ,p_api_name  => G_MODULE_PREFIX ||
                                                      l_api_name ||
                                                      '.Exception'
                                      ,p_message   => SQLERRM);
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_debug_show_mid_data;

  --========================================================================
  -- PROCEDURE : rpt_debug_show_temp_data    PUBLIC ,
  -- PARAMETERS: p_rpt_data_type            row type in jmf_shikyu_cfr_rpt_temp
  --             p_output_to                the parameter for debug_output
  -- COMMENT   : show the data in temp table jmf_shikyu_cfr_rpt_temp
  --             using debug_output
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_debug_show_temp_data
  (
    p_rpt_data_type IN VARCHAR2
   ,p_output_to     IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'rpt_debug_show_temp_data';

    CURSOR l_cur_get_temp_data(lrpt_data_type jmf_shikyu_cfr_rpt_temp.rpt_data_type%TYPE) IS
      SELECT rpt_mode
            ,rpt_data_type
            ,oem_inv_org_id
            ,oem_inv_org_code
            ,oem_inv_org_name
            ,oem_inv_org_address
            ,supplier_id
            ,supplier_name
            ,site_id
            ,site_code
            ,site_address
            ,tp_inv_org_id
            ,tp_inv_org_code
            ,project_id
            ,project_num
            ,task_id
            ,task_num
            ,item_id
            ,item_number
            ,item_description
            ,estimated_qty
            ,primary_uom
            ,shikyu_price
            ,currency_code
            ,uom
            ,item_cost
            ,functional_currency
            ,value1 --Qty in Primary UOM
            ,value2 --SHIKYU Price in Pri UOM and Pri Currency
            ,value3
        FROM jmf_shikyu_cfr_rpt_temp
       WHERE (lrpt_data_type IS NULL)
          OR (rpt_data_type = lrpt_data_type)
       ORDER BY rpt_mode
               ,rpt_data_type
               ,oem_inv_org_id
               ,supplier_id
               ,site_id;

    l_rpt_mode            jmf_shikyu_cfr_rpt_temp.rpt_mode%TYPE;
    l_rpt_data_type       jmf_shikyu_cfr_rpt_temp.rpt_data_type%TYPE;
    l_oem_inv_org_id      jmf_shikyu_cfr_rpt_temp.oem_inv_org_id%TYPE;
    l_oem_inv_org_code    jmf_shikyu_cfr_rpt_temp.oem_inv_org_code%TYPE;
    l_oem_inv_org_name    jmf_shikyu_cfr_rpt_temp.oem_inv_org_name%TYPE;
    l_oem_inv_org_address jmf_shikyu_cfr_rpt_temp.oem_inv_org_address%TYPE;
    l_supplier_id         jmf_shikyu_cfr_rpt_temp.supplier_id%TYPE;
    l_supplier_name       jmf_shikyu_cfr_rpt_temp.supplier_name%TYPE;
    l_site_id             jmf_shikyu_cfr_rpt_temp.site_id%TYPE;
    l_site_code           jmf_shikyu_cfr_rpt_temp.site_code%TYPE;
    l_site_address        jmf_shikyu_cfr_rpt_temp.site_address%TYPE;
    l_tp_inv_org_id       jmf_shikyu_cfr_rpt_temp.tp_inv_org_id%TYPE;
    l_tp_inv_org_code     jmf_shikyu_cfr_rpt_temp.tp_inv_org_code%TYPE;
    l_project_id          jmf_shikyu_cfr_rpt_temp.project_id%TYPE;
    l_project_num         jmf_shikyu_cfr_rpt_temp.project_num%TYPE;
    l_task_id             jmf_shikyu_cfr_rpt_temp.task_id%TYPE;
    l_task_num            jmf_shikyu_cfr_rpt_temp.task_num%TYPE;
    l_item_id             jmf_shikyu_cfr_rpt_temp.item_id%TYPE;
    l_item_number         jmf_shikyu_cfr_rpt_temp.item_number%TYPE;
    l_item_description    jmf_shikyu_cfr_rpt_temp.item_description%TYPE;
    l_estimated_qty       jmf_shikyu_cfr_rpt_temp.estimated_qty%TYPE;
    l_primary_uom         jmf_shikyu_cfr_rpt_temp.primary_uom%TYPE;
    l_shikyu_price        jmf_shikyu_cfr_rpt_temp.shikyu_price%TYPE;
    l_currency_code       jmf_shikyu_cfr_rpt_temp.currency_code%TYPE;
    l_uom                 jmf_shikyu_cfr_rpt_temp.uom%TYPE;
    l_item_cost           jmf_shikyu_cfr_rpt_temp.item_cost%TYPE;
    l_functional_currency jmf_shikyu_cfr_rpt_temp.functional_currency%TYPE;
    l_value1              jmf_shikyu_cfr_rpt_temp.value1%TYPE;
    l_value2              jmf_shikyu_cfr_rpt_temp.value2%TYPE;
    l_value3              jmf_shikyu_cfr_rpt_temp.value3%TYPE;

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                    ,p_api_name  => G_MODULE_PREFIX ||
                                                    l_api_name
                                    ,p_message   => '==jmf_shikyu_cfr_rpt_temp data Begin==');
    -- **** for debug information in readonly UT environment.--- end ****
    OPEN l_cur_get_temp_data(p_rpt_data_type);
    LOOP
      --print the data in l_cur_get_mid_temp_data
      FETCH l_cur_get_temp_data
        INTO l_rpt_mode
            ,l_rpt_data_type
            ,l_oem_inv_org_id
            ,l_oem_inv_org_code
            ,l_oem_inv_org_name
            ,l_oem_inv_org_address
            ,l_supplier_id
            ,l_supplier_name
            ,l_site_id
            ,l_site_code
            ,l_site_address
            ,l_tp_inv_org_id
            ,l_tp_inv_org_code
            ,l_project_id
            ,l_project_num
            ,l_task_id
            ,l_task_num
            ,l_item_id
            ,l_item_number
            ,l_item_description
            ,l_estimated_qty
            ,l_primary_uom
            ,l_shikyu_price
            ,l_currency_code
            ,l_uom
            ,l_item_cost
            ,l_functional_currency
            ,l_value1
            ,l_value2
            ,l_value3;

      EXIT WHEN l_cur_get_temp_data%NOTFOUND;

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                      ,p_api_name  => G_MODULE_PREFIX ||
                                                      l_api_name
                                      ,p_message   => 'jmf_shikyu_cfr_rpt_temp:' ||
                                                      ';rpt_mode[' ||
                                                      l_rpt_mode || ']' ||
                                                      ';rpt_data_type[' ||
                                                      l_rpt_data_type || ']' ||
                                                      ';oem_inv_org_id[' ||
                                                      l_oem_inv_org_id || ']' ||
                                                      ';oem_inv_org_code[' ||
                                                      l_oem_inv_org_code || ']' ||
                                                      ';oem_inv_org_name[' ||
                                                      l_oem_inv_org_name || ']' ||
                                                      ';oem_inv_org_address[' ||
                                                      l_oem_inv_org_address || ']' ||
                                                      ';supplier_id[' ||
                                                      l_supplier_id || ']' ||
                                                      ';supplier_name[' ||
                                                      l_supplier_name || ']' ||
                                                      ';site_id[' ||
                                                      l_site_id || ']' ||
                                                      ';site_code[' ||
                                                      l_site_code || ']' ||
                                                      ';site_address[' ||
                                                      l_site_address || ']' ||
                                                      ';tp_inv_org_id[' ||
                                                      l_tp_inv_org_id || ']' ||
                                                      ';tp_inv_org_code[' ||
                                                      l_tp_inv_org_code || ']' ||
                                                      ';project_id[' ||
                                                      l_project_id || ']' ||
                                                      ';project_num[' ||
                                                      l_project_num || ']' ||
                                                      ';task_id[' ||
                                                      l_task_id || ']' ||
                                                      ';task_num[' ||
                                                      l_task_num || ']' ||
                                                      ';item_id[' ||
                                                      l_item_id || ']' ||
                                                      ';item_number[' ||
                                                      l_item_number || ']' ||
                                                      ';item_description[' ||
                                                      l_item_description || ']' ||
                                                      ';estimated_qty[' ||
                                                      l_estimated_qty || ']' ||
                                                      ';primary_uom[' ||
                                                      l_primary_uom || ']' ||
                                                      ';shikyu_price[' ||
                                                      l_shikyu_price || ']' ||
                                                      ';currency_code[' ||
                                                      l_currency_code || ']' ||
                                                      ';uom[' || l_uom || ']' ||
                                                      ';item_cost[' ||
                                                      l_item_cost || ']' ||
                                                      ';functional_currency[' ||
                                                      l_functional_currency || ']' ||
                                                      ';value1[' || l_value1 || ']' ||
                                                      ';value2[' || l_value2 || ']' ||
                                                      ';value3[' || l_value3 || ']');
      -- **** for debug information in readonly UT environment.--- end ****

    END LOOP; --end loop of l_cur_get_mid_temp_data
    CLOSE l_cur_get_temp_data;

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                    ,p_api_name  => G_MODULE_PREFIX ||
                                                    l_api_name
                                    ,p_message   => '==jmf_shikyu_cfr_rpt_temp data end==');
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y'
       AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise log message;
      NULL;

    WHEN OTHERS THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output(p_output_to => p_output_to
                                      ,p_api_name  => G_MODULE_PREFIX ||
                                                      l_api_name ||
                                                      '.Exception'
                                      ,p_message   => SQLERRM);
      -- **** for debug information in readonly UT environment.--- end ****

  END rpt_debug_show_temp_data;

END JMF_SHIKYU_RPT_CFR_PVT;

/
