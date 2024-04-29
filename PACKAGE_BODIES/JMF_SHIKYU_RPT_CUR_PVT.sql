--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RPT_CUR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RPT_CUR_PVT" AS
--$Header: JMFVCURB.pls 120.25 2008/03/22 06:21:14 kdevadas ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVCURB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Body file of the package for creating temporary    |
--|                        data for the Shikyu Cost Update Analysis report.   |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   cuar_get_cost_data                                 |
--|                        cuar_get_unreceived_po                             |
--|                        cuar_get_unshipped_so                              |
--|                        cuar_get_rma_so                                    |
--|                        cuar_get_item_cost                                 |
--|                        get_uom_primary                                    |
--|                        get_uom_primary_code                               |
--|                        get_uom_primary_qty                                |
--|                        get_uom_primary_qty_from_code                      |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   28-MAY-2005          fwang  Created.                                    |
--|   18-NOV-2005          shu    added code for setting request completed    |
--|                               with warning if SHIKYU profile is disable   |
--|   28-Nov-2005          Sherly updated for a few of issues for unreceived  |
--|                               and unshipped                               |
--|   30-Nov-2005          Sherly updated function currency part and RMA      |
--|   Dec-5-2005           Sherly updated cuar_get_cost_data by adding a      |
--|                               parameter "function_currency"               |
--|                        Sherly updated cuar_get_unrecived_po and           |
--|                               cuar_get_unshipped_so for exception         |
--|   Dec-6-2005           Sherly udpated function IS_CURRENT_PERIOD to add   |
--|                               sysdate logic                               |
--|   Dec-8-2005           Sherly udpated function cuar_get_unreceived_po and |
--|                               cuar_get_unshipped_so to excelude the qty = |
--|                               0 or froze cost = plan cost.                |
--|   Dec-9-2005           Sherly updated function cuar_get_rma_so to exclude |
--|                               lines with amount = 0                       |
--|   Dec-12-2005          Sherly updated function cuar_get_unreceived_po and |
--|                               cuar_get_unshipped_so to replace org_id with|
--|                               ship_to_location_id when joined with mtl    |
--|   Dec-21-2005          Sherly update procedure cuar_get_rma_so to fix     |
--|                               some performance issue                      |
--|   Jan-10-2006          Sherly udpated all procedures to standarize the    |
--|                               log info                                    |
--|   Jan-18-2006          Sherly updated cuar_get_unreceived_po and          |
--|                               cuar_get_unshipped_so for log message       |
--|                               translation                                 |
--|   FEB-07-2006          Amy    solve potential issue of date conversion    |
--|   MAY-16-2006          Amy    solve bug 5212968                           |
--|   MAY-23-2006          Amy    solve bug 5232878:                          |
--|                               Modified l_cur_get_unreceived_po in         |
--|                               cuar_get_unreceived_po to get vendor_id and |
--|                               vendor_site_id from                         |
--|                               hr_organization_information for the         |
--|                               TP Organization instead of OEM Organization.|
--|                               Also, set the concurrent request status to  |
--|                               warning if the un-shipped SOs are not       |
--|                               defined in functional currency, and if no   |
--|                               values were supplied for the                |
--|                               'Currency conversion type' and              |
--|                               'Currency conversion date' concurrent       |
--|                               request parameters.                         |
--|   Jul-6-2006              Amy    updated procedure cuar_get_unshipped_so to solve bug5232878                          |
--|   Jul-7-2006              Amy    updated procedure cuar_get_unreceived_po and cuar_get_unshipped_so to solve project number related issue.                          |
--|   Aug-14-2006           Amy    updated procedure cuar_get_unshipped_so to fix bug#5462851.                          |
--|   Sep-01-2006           Amy    updated procedure cuar_get_rma_so to fix bug#5506431.                          |
--|   Sep-20-2006           Amy    updated procedure cuar_get_unreceived_po to add release number                         |
--|   Nov-07-2006           Amy    updated procedure cuar_get_unreceived_po to add default coverstion type/date in price conversion function                   |
--|   04-OCT-2007      kdevadas   Buy/Sell Subcontracting changes         |
--|                              Reference - GBL_BuySell_TDD.doc              |
--|                              Reference - GBL_BuySell_FDD.doc              |
--|   04-OCT-2007      kdevadas   Bug 6773949                                 |
--|                              Cost Update Analysis Report should display   |
--|                              data only Chargeable Subcontracting enabled  |
--|                              OEM orgs                                     |
--+===========================================================================+

  --=============================================
  -- CONSTANTS
  --=============================================
  g_pkg_name      CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_RPT_CUR_PVT';
  g_module_prefix CONSTANT VARCHAR2(50) := 'jmf.plsql.' || g_pkg_name || '.';

  --=============================================
  -- GLOBAL VARIABLES
  --=============================================

  g_debug_level NUMBER := fnd_log.g_current_runtime_level;
  g_proc_level  NUMBER := fnd_log.level_procedure;

  g_rate_not_found VARCHAR2(1) := 'N';

  --g_unexp_level NUMBER := fnd_log.level_unexpected;
  g_excep_level NUMBER := fnd_log.level_exception;

  --========================================================================
  -- PROCEDURE : cuar_get_cost_data          PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_run                       report run type
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_rate_not_found            Currency conversion Rate not found flag
  -- COMMENT   : used as portal to choose process according to run type
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_cost_data
  (
    p_cost_type_id      IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_inv_org_name_from IN VARCHAR2
   ,p_inv_org_name_to   IN VARCHAR2
   ,p_run               IN VARCHAR2
   ,p_currency_cnv_type IN VARCHAR2
   ,p_currency_cnv_date IN VARCHAR2
   ,p_function_currency IN VARCHAR2
   ,p_rate_not_found OUT NOCOPY VARCHAR2
  ) IS
    l_func_currency_code jmf_shikyu_cur_rpt_temp.func_currency_code%TYPE;
    l_currency_cnv_date  DATE;
    l_api_name CONSTANT VARCHAR2(30) := 'cuar_get_cost_data';


  BEGIN

    --g_debug_level := fnd_log.g_current_runtime_level;

    IF (g_proc_level >= g_debug_level)
    THEN
      fnd_log.STRING(g_proc_level
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    l_func_currency_code :=p_function_currency ;

    DELETE FROM jmf_shikyu_cur_rpt_temp;
    COMMIT;

    /* the input date format depends on server's setting.
       To avoid the potential issues,use function which is not using mask.
       */
    l_currency_cnv_date := fnd_date.canonical_to_date(p_currency_cnv_date);

    IF p_run = 'RUN_BEFORECOSTUPDATE'
    THEN
      cuar_get_unreceived_po(p_cost_type_id       => p_cost_type_id
                            ,p_org_id             => p_org_id
                            ,p_inv_org_name_from  => p_inv_org_name_from
                            ,p_inv_org_name_to    => p_inv_org_name_to
                            ,p_currency_cnv_type  => p_currency_cnv_type
                            ,p_currency_cnv_date  => l_currency_cnv_date
                            ,p_func_currency_code => l_func_currency_code
                                           );

      cuar_get_unshipped_so(p_cost_type_id       => p_cost_type_id
                           ,p_org_id             => p_org_id
                           ,p_inv_org_name_from  => p_inv_org_name_from
                           ,p_inv_org_name_to    => p_inv_org_name_to
                           ,p_currency_cnv_type  => p_currency_cnv_type
                           ,p_currency_cnv_date  => l_currency_cnv_date
                           ,p_func_currency_code => l_func_currency_code
                                               );

    ELSIF p_run = 'RUN_ATPERIODEND'
    THEN
      cuar_get_rma_so(p_org_id             => p_org_id
                     ,p_inv_org_name_from  => p_inv_org_name_from
                     ,p_inv_org_name_to    => p_inv_org_name_to
                     ,p_func_currency_code => l_func_currency_code);
    END IF;

    p_rate_not_found := g_rate_not_found;

  EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,'no_data_found');
      END IF;
    WHEN OTHERS THEN

      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;
  END cuar_get_cost_data;

  --========================================================================
  -- PROCEDURE : cuar_get_unreceived_po      PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
  -- COMMENT   : collect appropriate unreceived po qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
    PROCEDURE cuar_get_unreceived_po
  (
    p_cost_type_id       IN NUMBER
   ,p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_currency_cnv_type  IN VARCHAR2
   ,p_currency_cnv_date  IN DATE
   ,p_func_currency_code IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'cuar_get_unreceived_po';
    CURSOR l_cur_get_unreceived_po(lp_cost_type_id NUMBER, lp_org_id NUMBER, lp_inv_org_name_from VARCHAR2, lp_inv_org_name_to VARCHAR2, lp_currency_cnv_type VARCHAR2, lp_currency_cnv_date DATE, lp_func_currency_code VARCHAR2) IS
      SELECT 'UnReceived'
            ,haotl.NAME
--updated to fix project_number related issue start
            --,pa.segment1
           ,NVL((SELECT DISTINCT segment1 AS project_number
                    FROM pa_projects_all
                  WHERE pa_projects_all.project_id(+) = sub.project_id),
                (SELECT DISTINCT project_number
                 FROM   pjm_seiban_numbers
                 WHERE pjm_seiban_numbers.project_id(+) = sub.project_id)) segment1
--updated to fix project_number related issue end
            ,tasks.task_number
            ,ven.vendor_name
            ,pv.vendor_site_code
            ,h.segment1
            ,l.line_num
            ,sub.osa_item_id
            ,jmf_shikyu_rpt_util.get_item_number(l.org_id
                                                ,l.item_id)
            ,mtl.description
            ,sub.osa_item_price
            ,sub.currency
            ,loc.quantity - loc.quantity_received unreceived_qty
            ,l.unit_meas_lookup_code
     --       ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(loc.org_id
     ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(loc.ship_to_organization_id
                                                      ,sub.osa_item_id
                                                      ,1) frozend_cost
          --  ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(loc.org_id
          ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(loc.ship_to_organization_id
                                                      ,sub.osa_item_id
                                                      ,lp_cost_type_id)
            ,decode(sub.currency,lp_func_currency_code,sub.osa_item_price,jmf_shikyu_rpt_util.convert_amount(sub.currency
                                               ,lp_func_currency_code
                                               ,decode(lp_currency_cnv_date,null,sysdate,lp_currency_cnv_date)
                                               ,decode(lp_currency_cnv_type,null,h.rate_type,lp_currency_cnv_type)
                                               ,sub.osa_item_price))
            ,jmf_shikyu_rpt_cur_pvt.get_uom_primary_qty(l.item_id
                                                       ,loc.ship_to_organization_id
                                                       ,2
                                                       ,1
                                              --        ,loc.unit_meas_lookup_code)
                                                        ,l.unit_meas_lookup_code) --UOM exchange rate
             ,pra.release_num            --Added to display release number
/*      FROM   po_headers_all               h
            ,po_lines_all                 l
            ,po_line_locations_all        loc
            ,jmf_subcontract_orders       sub
            ,mtl_system_items_vl          mtl
            ,po_vendor_sites_all          pv
            ,hr_all_organization_units_tl haotl
            ,pa_projects_all              pa
            ,pa_tasks                     tasks
            ,po_vendors                   ven
      WHERE  \*h.type_lookup_code IN ('STANDARD')                                  AND *\
       h.po_header_id = sub.subcontract_po_header_id
       AND l.po_line_id = sub.subcontract_po_line_id
       AND sub.project_id = pa.project_id(+)
       AND sub.task_id = tasks.task_id(+)
       AND loc.line_location_id = sub.subcontract_po_shipment_id
       AND pv.vendor_site_id(+) = h.vendor_site_id
       AND mtl.inventory_item_id = l.item_id
       AND haotl.organization_id(+) = loc.ship_to_organization_id
       AND haotl.LANGUAGE = userenv('LANG')
       AND h.vendor_id = ven.vendor_id
       AND loc.ship_to_organization_id = mtl.organization_id
     --  AND loc.org_id = mtl.organization_id
       AND h.org_id = lp_org_id
       AND haotl.NAME >= nvl(lp_inv_org_name_from
                            ,haotl.NAME)
       AND haotl.NAME <= nvl(lp_inv_org_name_to
                            ,haotl.NAME);*/
--updated to fix project_number related issue start
      --FROM pa_projects_all              pa
      --      ,pa_tasks                     tasks
      FROM pa_tasks                     tasks
--updated to fix project_number related issue end
            ,po_vendor_sites_all          pv
            ,po_vendors                   ven
            ,mtl_system_items_vl          mtl
            ,jmf_subcontract_orders       sub
            ,po_line_locations_all        loc
            ,po_lines_all                 l
            ,po_headers_all               h
            ,hr_organization_information hoi
            ,mtl_interorg_parameters     mip
            ,hr_all_organization_units_tl haotl
            --Added to display release_number
            ,po_releases_all pra
--updated to fix project_number related issue start
      --WHERE  /*h.type_lookup_code IN ('standard')                                  AND */
       --pa.project_id(+) = sub.project_id
       --AND tasks.task_id(+) = sub.task_id
  WHERE tasks.task_id(+) = sub.task_id
--updated to fix project_number related issue end
       AND pv.vendor_site_id(+) = h.vendor_site_id
       AND ven.vendor_id = h.vendor_id
       AND haotl.organization_id(+) = loc.ship_to_organization_id
     --  AND loc.org_id = mtl.organization_id
       AND mtl.inventory_item_id = l.item_id
       AND mtl.organization_id = loc.ship_to_organization_id
       AND sub.subcontract_po_header_id = loc.po_header_id
       AND sub.subcontract_po_line_id = loc.po_line_id
       AND sub.subcontract_po_shipment_id = loc.line_location_id
       --Added to display release_number
       AND loc.po_release_id = pra.po_release_id(+)
       AND loc.po_line_id = l.po_line_id
       AND loc.po_header_id = l.po_header_id
       AND l.po_header_id = h.po_header_id
       AND h.org_id = lp_org_id
        AND h.vendor_id = hoi.org_information3
        AND h.vendor_site_id=hoi.org_information4
        AND hoi.org_information_context = 'Customer/Supplier Association' --to identify the flexfield
        AND hoi.organization_id = mip.to_organization_id
       --AND    mip.shikyu_enabled_flag = 'Y';
      	--AND mip.subcontracting_type in ('B','C')   -- 12.1 Buy/Sell Subcontracting changes
        AND mip.subcontracting_type = 'C' -- Bug 6773949
        and mip.from_organization_id =haotl.organization_id
       --AND hoi.organization_id = haotl.organization_id
       AND haotl.LANGUAGE = userenv('LANG')
       AND haotl.NAME >= nvl(lp_inv_org_name_from
                            ,haotl.NAME)
       AND haotl.NAME <= nvl(lp_inv_org_name_to
                            ,haotl.NAME);

    l_source             jmf_shikyu_cur_rpt_temp.SOURCE%TYPE;
    l_inventory_org_name jmf_shikyu_cur_rpt_temp.inventory_org_name%TYPE;
    l_project_num        jmf_shikyu_cur_rpt_temp.project_num%TYPE;
    l_task_num           jmf_shikyu_cur_rpt_temp.task_num%TYPE;
    l_vendor_name        jmf_shikyu_cur_rpt_temp.vendor_name%TYPE;
    l_vendor_site_code   jmf_shikyu_cur_rpt_temp.vendor_site_code%TYPE;
    l_order_num          jmf_shikyu_cur_rpt_temp.order_num%TYPE;
    l_line_num           jmf_shikyu_cur_rpt_temp.line_num%TYPE;
    l_item_id            jmf_shikyu_cur_rpt_temp.item_id%TYPE;
    l_item_name          jmf_shikyu_cur_rpt_temp.item_name%TYPE;
    l_item_desc          jmf_shikyu_cur_rpt_temp.item_desc%TYPE;
    l_unit_price         jmf_shikyu_cur_rpt_temp.unit_price%TYPE;
    l_currency           jmf_shikyu_cur_rpt_temp.currency%TYPE;
    l_quantity           jmf_shikyu_cur_rpt_temp.quantity%TYPE;
    l_uom_code           jmf_shikyu_cur_rpt_temp.uom_code%TYPE;
    l_unit_cost_frozen   jmf_shikyu_cur_rpt_temp.unit_cost_frozen%TYPE;
    l_unit_cost_plan     jmf_shikyu_cur_rpt_temp.unit_cost_plan%TYPE;
    l_func_unit_price    jmf_shikyu_cur_rpt_temp.func_unit_price%TYPE;
    l_qty_rate           jmf_shikyu_cur_rpt_temp.primary_qty%TYPE;
    l_func_currency_code jmf_shikyu_cur_rpt_temp.func_currency_code%TYPE;
    l_message            varchar2(200);
    l_order_line_id        jmf_shikyu_cur_rpt_temp.order_line_id%TYPE;--Added to display release number(When unreceived then mean release_num)

  BEGIN

   -- g_debug_level := fnd_log.g_current_runtime_level;

    IF (g_proc_level >= g_debug_level)
    THEN
      fnd_log.STRING(g_proc_level
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;
    l_func_currency_code := p_func_currency_code;

    OPEN l_cur_get_unreceived_po(p_cost_type_id
                                ,p_org_id
                                ,p_inv_org_name_from
                                ,p_inv_org_name_to
                                ,p_currency_cnv_type
                                ,p_currency_cnv_date
                                ,p_func_currency_code);

    LOOP
      FETCH l_cur_get_unreceived_po
      INTO  l_source,
            l_inventory_org_name,
            l_project_num,
            l_task_num,
            l_vendor_name,
            l_vendor_site_code,
            l_order_num,
            l_line_num,
            l_item_id,
            l_item_name,
            l_item_desc,
            l_unit_price,
            l_currency,
            l_quantity,
            l_uom_code,
            l_unit_cost_frozen,
            l_unit_cost_plan,
            l_func_unit_price,
            l_qty_rate,
            l_order_line_id;--Added to display release number(When unreceived means release_num)

      EXIT WHEN l_cur_get_unreceived_po%NOTFOUND;

      -- handle corruency conversion rate exception
      IF l_func_unit_price = -1 THEN
        -- p_rate_not_found := 'Y';
        g_rate_not_found := 'Y';

        IF (g_excep_level >= g_debug_level)
        THEN

          fnd_message.set_name('JMF'
                              ,'JMF_SHK_CURR_RATE_NOTFOUND');

          fnd_message.set_token('FROMCURRENCY'
                               ,l_currency);
          fnd_message.set_token('TOCURRENCY'
                               ,p_func_currency_code);
          fnd_message.set_token('DOCTYPE'
                               ,'PO');
          fnd_message.set_token('DOCNUMBER'
                               ,l_order_num);

          l_message := fnd_message.GET();


          fnd_file.put_line(fnd_file.LOG, l_message );

          fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,l_message);

         END IF;

      -- handle UOM conversion rate exception
      ELSIF l_qty_rate = -99999 THEN
         --  p_rate_not_found := 'Y';
           g_rate_not_found :='Y';

          IF (g_excep_level >= g_debug_level)
          THEN

          fnd_message.set_name('JMF'
                              ,'JMF_SHK_UOM_RATE_NOTFOUND');

          fnd_message.set_token('ITEMNUM'
                               ,l_item_name);
          fnd_message.set_token('DOCTYPE'
                               ,'PO');
          fnd_message.set_token('DOCNUMBER'
                               ,l_order_num);


          l_message := fnd_message.GET();

            fnd_file.put_line(fnd_file.LOG, l_message);
            fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,l_message);

          END IF;

      ELSIF (l_quantity <> 0) AND (l_unit_cost_frozen <> l_unit_cost_plan ) THEN


      INSERT INTO jmf_shikyu_cur_rpt_temp
        (SOURCE
        ,inventory_org_name
        ,project_num
        ,task_num
        ,vendor_name
        ,vendor_site_code
        ,order_num
        ,line_num
        ,item_id
        ,item_name
        ,item_desc
        ,unit_price
        ,currency
        ,quantity
        ,uom_code
        ,unit_cost_frozen
        ,unit_cost_plan
        ,func_unit_price
        ,primary_qty
        ,func_currency_code
        ,order_line_id)--Added to display release number(When unreceived means release_num)
      VALUES
        (l_source
        ,l_inventory_org_name
        ,l_project_num
        ,l_task_num
        ,l_vendor_name
        ,l_vendor_site_code
        ,l_order_num
        ,l_line_num
        ,l_item_id
        ,l_item_name
        ,l_item_desc
        ,l_unit_price
        ,l_currency
        ,l_quantity
        ,l_uom_code
        ,l_unit_cost_frozen *l_qty_rate
        ,l_unit_cost_plan *l_qty_rate
        ,l_func_unit_price
        ,l_qty_rate
        ,l_func_currency_code
        ,l_order_line_id);--Added to display release number(When unreceived means release_num)


    END IF;
    END LOOP;

    COMMIT;
    CLOSE l_cur_get_unreceived_po;

  EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,'no_data_found');
      END IF;
    WHEN OTHERS THEN

      ROLLBACK;

      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;
  END cuar_get_unreceived_po;

  --========================================================================
  -- PROCEDURE : cuar_get_unshipped_so       PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
   -- COMMENT   : collect appropriate unshipped so qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_unshipped_so
  (
    p_cost_type_id       IN NUMBER
   ,p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_currency_cnv_type  IN VARCHAR2
   ,p_currency_cnv_date  IN DATE
   ,p_func_currency_code IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'cuar_get_unshipped_so';
    CURSOR l_cur_get_unshipped_so(lp_cost_type_id NUMBER, lp_org_id NUMBER, lp_inv_org_name_from VARCHAR2, lp_inv_org_name_to VARCHAR2, lp_currency_cnv_type VARCHAR2, lp_currency_cnv_date DATE, lp_func_currency_code VARCHAR2) IS
      SELECT 'UnShipped'
            ,haotl.NAME
--updated to fix project_number related issue start
            --,pa.segment1
           ,NVL((SELECT DISTINCT segment1 AS project_number
                    FROM pa_projects_all
                  WHERE pa_projects_all.project_id(+) = sol.project_id),
                (SELECT DISTINCT project_number
                 FROM   pjm_seiban_numbers
                 WHERE pjm_seiban_numbers.project_id(+) = sol.project_id)) segment1
--updated to fix project_number related issue end
            ,tasks.task_number
            ,soh.order_number
            ,sol.line_number
            ,sol.inventory_item_id
            ,jmf_shikyu_rpt_util.get_item_number(sol.org_id
                                                ,sol.inventory_item_id) item_num
            ,mtl.description
            ,sol.unit_selling_price
            ,soh.transactional_curr_code
-- Updated to fix bug 5462851 start
-- To get unshipped Quantity
--            ,sol.ordered_quantity - nvl(sol.shipped_quantity,0) unshipped_qty
            ,repo.allocated_quantity unshipped_quantity
-- Updated to fix bug 5462851 end
            ,sol.pricing_quantity_uom
            ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(sol.ship_from_org_id
                                                      ,sol.inventory_item_id
                                                      ,1) frozend_cost
            ,jmf_shikyu_rpt_cur_pvt.cuar_get_item_cost(sol.ship_from_org_id
                                                      ,sol.inventory_item_id
                                                      ,lp_cost_type_id) planned_cost
            ,decode(soh.transactional_curr_code,lp_func_currency_code
                   , sol.unit_selling_price,jmf_shikyu_rpt_util.convert_amount(soh.transactional_curr_code
                                               ,lp_func_currency_code
/*                                               ,lp_currency_cnv_date
                                               ,lp_currency_cnv_type*/
                                               ,decode(lp_currency_cnv_date,null,sysdate,lp_currency_cnv_date)
                                               ,decode(lp_currency_cnv_type,null,soh.CONVERSION_TYPE_CODE,lp_currency_cnv_type)
                                               ,sol.unit_selling_price)) convert_amount
            ,jmf_shikyu_rpt_cur_pvt.get_uom_primary_qty_from_code(sol.inventory_item_id
                                                                 ,sol.ship_from_org_id
                                                                 ,2
                                                                 ,1
                                                                 ,sol.pricing_quantity_uom) exchange_UOM-- returns qty in primary UOM for 1 UOM in document
            ,sol.line_id
      FROM   oe_order_headers_all         soh
            ,oe_order_lines_all           sol
            ,hr_all_organization_units_tl haotl
--updated to fix project_number related issue start
            --,pa_projects_all              pa
--updated to fix project_number related issue end
            ,pa_tasks                     tasks
            ,jmf_shikyu_replenishments    repo
            ,mtl_system_items_vl          mtl
--updated to fix project_number related issue start
      --WHERE  pa.project_id(+) = sol.project_id
      --       AND tasks.task_id(+) = sol.task_id
      WHERE  tasks.task_id(+) = sol.task_id
--updated to fix project_number related issue end
             AND haotl.organization_id = sol.ship_from_org_id
             AND haotl.LANGUAGE = userenv('LANG')
             AND mtl.inventory_item_id = sol.inventory_item_id
            -- AND mtl.organization_id = sol.org_id
             AND mtl.organization_id = sol.ship_from_org_id
-- Added to fix bug 5462851 start
            AND repo.allocated_quantity > 0
            AND sol.shipped_quantity IS NULL
-- Added to fix bug 5462851 end
             AND repo.replenishment_so_header_id = soh.header_id
             AND repo.replenishment_so_line_id = sol.line_id
             AND soh.flow_status_code NOT IN ('ENTERED'
                                         ,'CANCELLED'
                                         ,'CLOSED')
             AND sol.org_id = lp_org_id
             AND haotl.NAME >= nvl(lp_inv_org_name_from
                                  ,haotl.NAME)
             AND haotl.NAME <= nvl(lp_inv_org_name_to
                                  ,haotl.NAME)
	            /* 12.1 Buy/Sell Subcontracting changes */
              /* Cost update analysis report is applicable only for Chargeable Sucbontracting */
              AND nvl(JMF_SHIKYU_GRP. GET_SUBCONTRACTING_TYPE(repo.oem_organization_id,  repo.tp_organization_id),
              NULL)  = 'C' ;


    l_source             jmf_shikyu_cur_rpt_temp.SOURCE%TYPE;
    l_inventory_org_name jmf_shikyu_cur_rpt_temp.inventory_org_name%TYPE;
    l_project_num        jmf_shikyu_cur_rpt_temp.project_num%TYPE;
    l_task_num           jmf_shikyu_cur_rpt_temp.task_num%TYPE;
    l_vendor_name        jmf_shikyu_cur_rpt_temp.vendor_name%TYPE;
    l_vendor_site_code   jmf_shikyu_cur_rpt_temp.vendor_site_code%TYPE;
    l_order_num          jmf_shikyu_cur_rpt_temp.order_num%TYPE;
    l_line_num           jmf_shikyu_cur_rpt_temp.line_num%TYPE;
    l_item_id            jmf_shikyu_cur_rpt_temp.item_id%TYPE;
    l_item_name          jmf_shikyu_cur_rpt_temp.item_name%TYPE;
    l_item_desc          jmf_shikyu_cur_rpt_temp.item_desc%TYPE;
    l_unit_price         jmf_shikyu_cur_rpt_temp.unit_price%TYPE;
    l_currency           jmf_shikyu_cur_rpt_temp.currency%TYPE;
    l_quantity           jmf_shikyu_cur_rpt_temp.quantity%TYPE;
    l_uom_code           jmf_shikyu_cur_rpt_temp.uom_code%TYPE;
    l_unit_cost_frozen   jmf_shikyu_cur_rpt_temp.unit_cost_frozen%TYPE;
    l_unit_cost_plan     jmf_shikyu_cur_rpt_temp.unit_cost_plan%TYPE;
    l_func_unit_price    jmf_shikyu_cur_rpt_temp.func_unit_price%TYPE;
    l_qty_rate           jmf_shikyu_cur_rpt_temp.primary_qty%TYPE;
    l_func_currency_code jmf_shikyu_cur_rpt_temp.func_currency_code%TYPE;
    l_order_line_id      jmf_shikyu_cur_rpt_temp.order_line_id%TYPE;
    l_message            varchar2(200);

  BEGIN
    --g_debug_level := fnd_log.g_current_runtime_level;

    IF (g_proc_level >= g_debug_level)
    THEN
      fnd_log.STRING(g_proc_level
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;
    l_func_currency_code := p_func_currency_code;

    OPEN l_cur_get_unshipped_so(p_cost_type_id
                               ,p_org_id
                               ,p_inv_org_name_from
                               ,p_inv_org_name_to
                               ,p_currency_cnv_type
                               ,p_currency_cnv_date
                               ,p_func_currency_code);

    LOOP
      FETCH l_cur_get_unshipped_so
      INTO  l_source,
            l_inventory_org_name,
            l_project_num,
            l_task_num,
            l_order_num,
            l_line_num,
            l_item_id,
            l_item_name,
            l_item_desc,
            l_unit_price,
            l_currency,
            l_quantity,
            l_uom_code,
            l_unit_cost_frozen ,
            l_unit_cost_plan ,
            l_func_unit_price,
            l_qty_rate,
            l_order_line_id;

      EXIT WHEN l_cur_get_unshipped_so%NOTFOUND;

      -- handle currency conversion rate not found exception
      IF l_func_unit_price = -1 THEN

        g_rate_not_found := 'Y';

        IF (g_excep_level >= g_debug_level)
        THEN

             --  p_rate_not_found := 'Y';
            -- g_rate_not_found := 'Y';
            --need translation?

          fnd_message.set_name('JMF'
                              ,'JMF_SHK_CURR_RATE_NOTFOUND');

          fnd_message.set_token('FROMCURRENCY'
                               ,l_currency);
          fnd_message.set_token('TOCURRENCY'
                               ,p_func_currency_code);
          fnd_message.set_token('DOCTYPE'
                               ,'SO');
          fnd_message.set_token('DOCNUMBER'
                               ,l_order_num);

          l_message := fnd_message.GET();

            fnd_file.put_line(fnd_file.LOG, l_message);
            fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,l_message);

          END IF;


      -- handle UOM conversion rate not found exception
      ELSIF l_qty_rate = -99999 THEN

          g_rate_not_found := 'Y';
          IF (g_excep_level >= g_debug_level)
          THEN

             --  p_rate_not_found := 'Y';
            -- g_rate_not_found := 'Y';

           fnd_message.set_name('JMF'
                              ,'JMF_SHK_UOM_RATE_NOTFOUND');

          fnd_message.set_token('ITEMNUM'
                               ,l_item_name);
          fnd_message.set_token('DOCTYPE'
                               ,'SO');
          fnd_message.set_token('DOCNUMBER'
                               ,l_order_num);


            fnd_file.put_line(fnd_file.LOG, l_message);
            fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,l_message);

          END IF;



      ELSIF (l_quantity <> 0) AND (l_unit_cost_frozen <> l_unit_cost_plan ) THEN

      INSERT INTO jmf_shikyu_cur_rpt_temp
        (SOURCE
        ,inventory_org_name
        ,project_num
        ,task_num
        ,vendor_name
        ,vendor_site_code
        ,order_num
        ,line_num
        ,item_id
        ,item_name
        ,item_desc
        ,unit_price
        ,currency
        ,quantity
        ,uom_code
        ,unit_cost_frozen
        ,unit_cost_plan
        ,func_unit_price
        ,primary_qty
        ,func_currency_code
        ,order_line_id)
      VALUES
        (l_source
        ,l_inventory_org_name
        ,l_project_num
        ,l_task_num
        ,l_vendor_name
        ,l_vendor_site_code
        ,l_order_num
        ,l_line_num
        ,l_item_id
        ,l_item_name
        ,l_item_desc
        ,l_unit_price
        ,l_currency
        ,l_quantity
        ,l_uom_code
        ,l_unit_cost_frozen * l_qty_rate  --convert into UOM in document
        ,l_unit_cost_plan * l_qty_rate    --convert into UOM in document
        ,l_func_unit_price
        ,l_qty_rate   -- exchange UOM Rate
        ,l_func_currency_code
        ,l_order_line_id);

    END IF;

    END LOOP;

    COMMIT;
    CLOSE l_cur_get_unshipped_so;

  EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,'no_data_found');
      END IF;
    WHEN OTHERS THEN

      ROLLBACK;

      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;
  END cuar_get_unshipped_so;

  --========================================================================
  -- PROCEDURE : cuar_get_rma_so             PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
  -- COMMENT   : collect appropriate rma so qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_rma_so
  (
    p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_func_currency_code IN VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'cuar_get_rma_so';
   -- l_start_date               DATE;
   -- l_end_date                 DATE;
   -- l_set_of_book_id           NUMBER;
    l_transaction_id           rcv_transactions.transaction_id%TYPE;
    l_rcv_line_id              oe_order_lines_all.line_id%TYPE;
    l_reference_line_id        oe_order_lines_all.reference_line_id%TYPE;
    l_org_id                   NUMBER;
    l_cur_rcv_order_number     oe_order_headers_all.order_number%TYPE;
    l_cur_rcv_line_number      oe_order_lines_all.line_number%TYPE;
    l_cur_rcv_ordered_quantity NUMBER;
    l_cur_rcv_shipped_quantity NUMBER;
    l_creation_date DATE;

    CURSOR l_cur_rcv_info(lp_inv_org_name_from VARCHAR2
                          , lp_inv_org_name_to VARCHAR2
                          , lp_org_id NUMBER) IS
      SELECT rcv.transaction_id
            ,oel.line_id
            ,oel.reference_line_id
            ,oel.org_id
            ,oeh.order_number
            ,oel.line_number
            ,oel.ordered_quantity
            ,oel.shipped_quantity
            ,oel.ship_from_org_id
            ,haotl.NAME
            ,rcv.creation_date
            ,rcv.transaction_id
      FROM   rcv_transactions             rcv
            ,oe_order_lines_all           oel
            ,oe_order_headers_all         oeh
            ,hr_all_organization_units_tl haotl
      WHERE  oel.org_id = lp_org_id
             AND rcv.transaction_type = 'DELIVER'
             AND oel.line_id = rcv.oe_order_line_id
             AND rcv.organization_id = oel.ship_from_org_id
             AND oel.header_id = oeh.header_id
             AND haotl.organization_id(+) = oel.ship_from_org_id
             AND haotl.LANGUAGE = userenv('LANG')
             AND haotl.NAME >= nvl(lp_inv_org_name_from
                                  ,haotl.NAME)
             AND haotl.NAME <= nvl(lp_inv_org_name_to
                                  ,haotl.NAME)
	            /* 12.1 Buy/Sell Subcontracting changes */
              /* Cost update analysis report is applicable only for Chargeable Sucbontracting */
              AND nvl(JMF_SHIKYU_GRP. GET_SUBCONTRACTING_TYPE(oel.ship_from_org_id,  oel.ship_to_org_id),
              NULL)  = 'C' ;


    l_source                 jmf_shikyu_cur_rpt_temp.SOURCE%TYPE;
    l_inventory_org_name     jmf_shikyu_cur_rpt_temp.inventory_org_name%TYPE;
    l_project_num            jmf_shikyu_cur_rpt_temp.project_num%TYPE;
    l_task_num               jmf_shikyu_cur_rpt_temp.task_num%TYPE;
    l_order_num              jmf_shikyu_cur_rpt_temp.order_num%TYPE;
    l_line_num               jmf_shikyu_cur_rpt_temp.line_num%TYPE;
    l_item_id                jmf_shikyu_cur_rpt_temp.item_id%TYPE;
    l_item_name              jmf_shikyu_cur_rpt_temp.item_name%TYPE;
    l_item_desc              jmf_shikyu_cur_rpt_temp.item_desc%TYPE;
    l_quantity               jmf_shikyu_cur_rpt_temp.quantity%TYPE;
    l_flow_status_code       oe_order_lines_all.flow_status_code%TYPE;
    l_unit_cost_frozen       jmf_shikyu_cur_rpt_temp.unit_cost_frozen%TYPE;
    l_unit_cost_plan         jmf_shikyu_cur_rpt_temp.unit_cost_plan%TYPE;
    l_primary_qty            jmf_shikyu_cur_rpt_temp.primary_qty%TYPE;
    l_func_currency_code     jmf_shikyu_cur_rpt_temp.func_currency_code%TYPE;
    l_order_line_id          jmf_shikyu_cur_rpt_temp.order_line_id%TYPE;
    l_no_ori_so_flag         VARCHAR2(5);
    l_no_appropriate_so_flag VARCHAR2(5);
    l_rma_over_shipped_flag  VARCHAR2(5);
    l_rma_qty                NUMBER;
    l_shipped_quantity       NUMBER;

    l_rcv_transaction_id     NUMBER;
    l_ship_from_org_id       NUMBER;
    l_om_ship_from_org_id    NUMBER;
    l_message                VARCHAR2(100);
    l_actual_shipment_date   Date;

  BEGIN
    --g_debug_level := fnd_log.g_current_runtime_level;

    IF (g_proc_level >= g_debug_level)
    THEN
      fnd_log.STRING(g_proc_level
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;
    --set_of_book_id
    --l_set_of_book_id := fnd_profile.VALUE('GL_SET_OF_BKS_ID');

    --get functional currency
    l_func_currency_code := p_func_currency_code;

    --get appropriate rcv
    OPEN l_cur_rcv_info(p_inv_org_name_from
                       ,p_inv_org_name_to
                       ,p_org_id);
    --loop through each rma trx in certain period according to parameters
    LOOP
      FETCH l_cur_rcv_info
        INTO l_transaction_id
            , l_rcv_line_id
            , l_reference_line_id
            , l_org_id
            , l_cur_rcv_order_number
            , l_cur_rcv_line_number
            , l_cur_rcv_ordered_quantity
            , l_cur_rcv_shipped_quantity
            , l_ship_from_org_id
            , l_inventory_org_name
            , l_creation_date
            , l_rcv_transaction_id;

      --EXIT;
      EXIT WHEN l_cur_rcv_info%NOTFOUND;

   IF is_current_period(l_creation_date ,l_ship_from_org_id) THEN
      --no related normal sales order
      l_no_ori_so_flag := 'N';

      IF l_reference_line_id IS NULL
      THEN

        l_no_ori_so_flag := 'Y';

        IF (g_excep_level >= g_debug_level)
        THEN


          fnd_message.set_name('JMF'
                              ,'JMF_SHK_RMA_REFERENCE_MISS');
          fnd_message.set_token('ORDERNUM'
                               ,l_cur_rcv_order_number);
          fnd_message.set_token('LINENUM'
                               ,l_cur_rcv_line_number);

          l_message := fnd_message.GET();

          fnd_file.put_line(fnd_file.LOG,  l_message);
          --l_message := 'RMA order with the number ' || l_cur_rcv_order_number || '-' ||
          --             l_cur_rcv_line_number ||
          --             ' doesn''t refer to any original sales order';
          fnd_log.STRING(g_excep_level
                        ,g_module_prefix || l_api_name || '.evaluate'
                        ,l_message);

        END IF; --  (g_proc_level >= g_debug_level)
      END IF; --l_reference_line_id IS NULL


      -- related normal sales order exists
      IF l_no_ori_so_flag = 'N'
      THEN
        --get corresponding info for each sale order line
       BEGIN
          l_no_appropriate_so_flag := 'N';
          SELECT pa.segment1
                ,tasks.task_number
                ,soh.order_number
                ,sol.line_number
                ,sol.inventory_item_id
                ,jmf_shikyu_rpt_util.get_item_number(sol.org_id
                                                    ,sol.inventory_item_id) item_num
                ,mtl.description
                ,sol.shipped_quantity
                 ,sol.flow_status_code
                 ,sol.ship_from_org_id
                 ,sol.actual_shipment_date
          INTO  l_project_num
                ,l_task_num
                ,l_order_num
                ,l_line_num
                ,l_item_id
                ,l_item_name
                ,l_item_desc
                ,l_shipped_quantity
                ,l_flow_status_code
                ,l_om_ship_from_org_id
                ,l_actual_shipment_date
          FROM   oe_order_headers_all         soh
                ,oe_order_lines_all           sol
                ,pa_projects_all              pa
                ,pa_tasks                     tasks
                ,jmf_shikyu_replenishments    repo
                ,mtl_system_items_vl          mtl
          WHERE  pa.project_id(+) = sol.project_id
                 AND tasks.task_id(+) = sol.task_id
                 AND mtl.inventory_item_id = sol.inventory_item_id
                 AND mtl.organization_id = l_ship_from_org_id
                 AND repo. replenishment_so_header_id = soh.header_id
                 AND repo. replenishment_so_line_id = sol.line_id
                 AND sol.line_id = l_reference_line_id
                 AND soh.header_id =sol.header_id;

        EXCEPTION
          WHEN no_data_found THEN
            l_no_appropriate_so_flag := 'Y';
            IF (g_excep_level >= g_debug_level)
            THEN
              fnd_log.STRING(g_excep_level
                            ,g_module_prefix || l_api_name || '.exception'
                            ,'no_data_found');
            END IF; --(g_proc_level >= g_debug_level)
          WHEN OTHERS THEN
            IF (g_excep_level >= g_debug_level)
            THEN
              fnd_log.STRING(g_excep_level
                            ,g_module_prefix || l_api_name || '.exception'
                            ,SQLERRM);
            END IF; --(g_proc_level >= g_debug_level)
        END;
        END IF; -- l_no_ori_so_flag = 'N'

        IF l_no_appropriate_so_flag = 'N'
        THEN
          IF l_flow_status_code = 'ENTERED'
             OR l_flow_status_code = 'AWAITING_SHIPPING' --'SHIPPED' or FULFILLED
          THEN
            l_no_appropriate_so_flag := 'Y';


            IF (g_excep_level >= g_debug_level)
            THEN

              fnd_message.set_name('JMF'
                                  ,'JMF_SHK_RMA_REFERENCE_MISS');
              fnd_message.set_token('ORDERNUM'
                                   ,l_order_num);
              fnd_message.set_token('LINENUM'
                                   ,l_line_num);

               l_message := fnd_message.GET();

               fnd_file.put_line(fnd_file.LOG,  l_message);
               fnd_log.STRING(g_excep_level
                            ,g_module_prefix || l_api_name || '.evaluate'
                            ,l_message);

            END IF;--(g_proc_level >= g_debug_level)

          ELSIF l_cur_rcv_ordered_quantity < l_cur_rcv_shipped_quantity
          THEN

            fnd_message.set_name('JMF'
                                ,'JMF_SHK_RMA_OVER_RECEIPT');
            fnd_message.set_token('ORDERNUM'
                                 ,l_order_num);
            fnd_message.set_token('LINENUM'
                                 ,l_line_num);
            l_message := fnd_message.GET();

            IF (g_excep_level >= g_debug_level)
            THEN

              fnd_file.put_line(fnd_file.LOG,  l_message);
              fnd_log.STRING(g_excep_level
                            ,g_module_prefix || l_api_name || '.evaluate'
                            ,l_message);
            END IF;--(g_proc_level >= g_debug_level)
          END IF;  --l_cur_rcv_ordered_quantity < l_cur_rcv_shipped_quantity
        END IF; --l_flow_status_code = 'ENTERED'

        END IF;

        --rma so is related to replenishment order
     IF l_no_appropriate_so_flag = 'N'
     THEN

          -- get shipped cost
          -- add AND inventory_item_id = l_item_id
           --  AND organization_id= l_ship_from_org_id
           --  AND transaction_date =  l_actual_shipment_date  to fix the FTS issue
         -- updated by amy to fix bug 5506431
         --SELECT actual_cost
         SELECT DISTINCT actual_cost
         INTO l_unit_cost_frozen
         FROM   mtl_material_transactions
         WHERE  trx_source_line_id = l_reference_line_id
             AND source_code = 'ORDER ENTRY'
             AND inventory_item_id = l_item_id
             AND organization_id= l_om_ship_from_org_id
             AND transaction_date =  l_actual_shipment_date  ;


          --get receipt cost
          --  add AND rcv_transaction_id = l_rcv_transaction_id to fix the FTS issue
         -- updated by amy to fix bug 5506431
         --SELECT actual_cost
         SELECT DISTINCT actual_cost
          INTO l_unit_cost_plan
          FROM   mtl_material_transactions
          WHERE   trx_source_line_id =l_rcv_line_id
                AND source_code = 'RCV'
                AND rcv_transaction_id = l_rcv_transaction_id ;


          --over received
          IF l_cur_rcv_shipped_quantity > l_shipped_quantity
          THEN
            l_rma_over_shipped_flag := 'YES';
            --l_cur_rcv_shipped_quantity := l_shipped_quantity ;
          ELSE
            l_rma_over_shipped_flag := 'NO';
          END IF;

              l_source           := 'RMA';
              l_primary_qty      := l_shipped_quantity;
              l_quantity         := l_rma_qty;
              l_order_line_id    := l_reference_line_id;

          IF (l_cur_rcv_shipped_quantity <> 0) AND (l_unit_cost_frozen <> l_unit_cost_plan ) THEN

              INSERT INTO jmf_shikyu_cur_rpt_temp
                (SOURCE
                ,inventory_org_name
                ,project_num
                ,task_num
                ,vendor_name
                ,vendor_site_code
                ,order_num
                ,line_num
                ,item_id
                ,item_name
                ,item_desc
                ,quantity
                ,uom_code
                ,unit_cost_frozen
                ,unit_cost_plan
                ,func_unit_price
                ,primary_qty
                ,order_line_id
                ,func_currency_code)
              VALUES
                (l_source
                ,l_inventory_org_name
                ,l_project_num
                ,l_task_num
                ,NULL
                ,NULL
                ,l_order_num
                ,l_line_num
                ,l_item_id
                ,l_item_name
                ,l_item_desc
                ,l_cur_rcv_shipped_quantity
                ,NULL
                ,l_unit_cost_frozen
                ,l_unit_cost_plan
                ,NULL
                ,l_shipped_quantity
                ,l_reference_line_id
                ,l_func_currency_code);
           COMMIT;
         END IF;
      END IF; --is_current_period(l_creation_date ,l_ship_from_org_id)

      END LOOP;
    CLOSE l_cur_rcv_info;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;
  END cuar_get_rma_so;


  --========================================================================
  -- FUNCTION  : IS_CURRENT_PERIOD          PUBLIC
  -- PARAMETERS: p_date                     DATE
  --           : p_org_id                   Inventory org id
  --
  -- RETURN    : will return if input date is in current inventory accounting period
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION is_current_period
  ( p_date IN DATE
    ,p_org_id IN NUMBER
  ) RETURN BOOLEAN IS
   l_number NUMBER;
   l_api_name VARCHAR2(30);

   BEGIN
    l_api_name := 'is_current_period' ;

   -- g_debug_level := fnd_log.g_current_runtime_level;

    SELECT 1
    INTO  l_number
    FROM   ORG_ACCT_PERIODS
    WHERE  organization_id= p_org_id
           AND  trunc(p_date,'dd') >= period_start_date
           AND  trunc(p_date,'dd') <= schedule_close_date
           AND  trunc(sysdate,'dd') >= period_start_date
           AND  trunc(sysdate,'dd') <= schedule_close_date ;

    RETURN (TRUE);
    EXCEPTION
    WHEN no_data_found THEN
         IF (g_excep_level >= g_debug_level)
         THEN
            fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,'no_data_found');
        END IF;

         RETURN (FALSE);
    WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;
    END is_current_period ;


  --========================================================================
  -- FUNCTION  : cuar_get_item_cost          PUBLIC
  -- PARAMETERS: p_ou_id                     operating unit id
  --           : p_item_id                   item id
  --           : p_cst_type_id               item cost type id
  -- RETURN    : will return the item cost
  -- COMMENT   : get item cost  for specific item
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION cuar_get_item_cost
  (
    p_org_id      IN NUMBER
   ,p_item_id     IN NUMBER
   ,p_cst_type_id IN NUMBER
  ) RETURN NUMBER IS
    l_item_cost NUMBER;
    l_api_name VARCHAR2(30);
  BEGIN

    l_api_name := 'cuar_get_item_cost' ;

   -- g_debug_level := fnd_log.g_current_runtime_level;

    SELECT item_cost
    INTO   l_item_cost
    FROM   cst_item_costs cost
    WHERE  cost.cost_type_id = p_cst_type_id
           AND cost.inventory_item_id = p_item_id
           AND organization_id = p_org_id;
    RETURN(l_item_cost);
  EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
      fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,'no_data_found');
      END IF;
      RETURN(0);

      WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;

  END cuar_get_item_cost;

  --========================================================================
  -- FUNCTION  : get_uom_primary          PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  -- RETURN    : will return the primary uom
  -- COMMENT   : getting the  primary UOM
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================

  FUNCTION get_uom_primary
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
  ) RETURN VARCHAR2 IS
    l_primary_uom VARCHAR2(25);
    l_api_name VARCHAR2(30);
  BEGIN

    l_api_name := 'get_uom_primary' ;

   --g_debug_level := fnd_log.g_current_runtime_level;

    SELECT primary_unit_of_measure
    INTO   l_primary_uom
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_inventory_item_id
           AND organization_id = p_org_id;
    RETURN(l_primary_uom);

    EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
      fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,'no_data_found');
      END IF;
      RETURN(NULL);

      WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;

  END get_uom_primary;

  --========================================================================
  -- FUNCTION  : get_uom_primary_code     PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_code
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
  ) RETURN VARCHAR2 IS
    l_primary_uom_code VARCHAR2(25);
    l_api_name VARCHAR2(30);
  BEGIN

    l_api_name := 'get_uom_primary_code' ;

    --g_debug_level := fnd_log.g_current_runtime_level;

    SELECT primary_uom_code
    INTO   l_primary_uom_code
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_inventory_item_id
           AND organization_id = p_org_id;
    RETURN(l_primary_uom_code);

    EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
      fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,'no_data_found');
      END IF;
      RETURN(NULL);

      WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;

  END get_uom_primary_code;

  --========================================================================
  -- FUNCTION  : get_uom_primary_qty      PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  --           : p_precision              precision
  --           : p_from_quantity          quantity of from UOM
  --           : p_from_unit              from UOM
  -- RETURN    : will return the quantity with primary uom
  -- COMMENT   : getting the quantity with primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_qty
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_precision         IN NUMBER
   ,p_from_quantity     IN NUMBER
   ,p_from_unit         IN VARCHAR2
  ) RETURN NUMBER IS
    l_qty         VARCHAR2(15);
    l_primary_uom VARCHAR(25);
  BEGIN
    l_primary_uom := get_uom_primary(p_inventory_item_id => p_inventory_item_id
                                    ,p_org_id            => p_org_id);
    l_qty         := inv_convert.inv_um_convert(item_id       => p_inventory_item_id
                                               ,PRECISION     => p_precision
                                               ,from_quantity => p_from_quantity
                                               ,from_unit     => NULL
                                               ,to_unit       => NULL
                                               ,from_name     => p_from_unit
                                               ,to_name       => l_primary_uom);
    RETURN(l_qty);
  END get_uom_primary_qty;

  --========================================================================
  -- FUNCTION  : get_uom_primary_qty_from_code     PUBLIC
  -- PARAMETERS: p_inventory_item_id               inventory item id
  --           : p_org_id                          organization id
  --           : p_precision                       precision
  --           : p_from_quantity                   quantity of from UOM
  --           : p_from_unit                       from UOM code
  -- RETURN    : will return the quantity with primary uom code
  -- COMMENT   : getting the quantity with primary uom code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_qty_from_code
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_precision         IN NUMBER
   ,p_from_quantity     IN NUMBER
   ,p_from_unit         IN VARCHAR2
  ) RETURN NUMBER IS
    l_qty         VARCHAR2(15);
    l_primary_uom VARCHAR(25);
    l_uom         VARCHAR(25);
    l_api_name VARCHAR2(30);
  BEGIN
    l_api_name := 'get_uom_primary_qty_from_code' ;

    g_debug_level := fnd_log.g_current_runtime_level;

    l_primary_uom := get_uom_primary(p_inventory_item_id => p_inventory_item_id
                                    ,p_org_id            => p_org_id);
    SELECT mtl_units_of_measure.unit_of_measure
    INTO   l_uom
    FROM   mtl_units_of_measure
    WHERE  mtl_units_of_measure.uom_code = p_from_unit;
    l_qty := inv_convert.inv_um_convert(item_id       => p_inventory_item_id
                                       ,PRECISION     => p_precision
                                       ,from_quantity => p_from_quantity
                                       ,from_unit     => NULL
                                       ,to_unit       => NULL
                                       ,from_name     => l_uom
                                       ,to_name       => l_primary_uom);
    RETURN(l_qty);

    EXCEPTION
    WHEN no_data_found THEN
      IF (g_excep_level >= g_debug_level)
      THEN
      fnd_log.STRING(g_excep_level
                    ,g_module_prefix || l_api_name || '.exception'
                    ,'no_data_found');
      END IF;
      RETURN(0);

      WHEN OTHERS THEN
      ROLLBACK;
      IF (g_excep_level >= g_debug_level)
      THEN
        fnd_log.STRING(g_excep_level
                      ,g_module_prefix || l_api_name || '.exception'
                      ,SQLERRM);
      END IF;

  END get_uom_primary_qty_from_code;

END jmf_shikyu_rpt_cur_pvt;

/
