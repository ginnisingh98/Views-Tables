--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RPT_SPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RPT_SPR_PVT" AS
--$Header: JMFVSPRB.pls 120.13 2006/11/09 01:13:33 rajkrish noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVSPRB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Body file of the package for creating temporary    |
--|                        data for the SHIKYU Subcontracting Order Report.   |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   spr_load_subcontracting_po                         |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   28-MAY-2005          fwang  Created.                                    |
--|   18-NOV-2005          shu    Added code for setting request completed    |
--|                               with warning if SHIKYU profile is disable   |
--|   01-Dec-2005          shzhao Changed the dynamic sql                     |
--|   02-Dec-2005          shzhao Changed the blanket po logic in PROCEDURE   |
--|                               spr_load_subcontracting_po                  |
--|   05-Dec-2005          shzhao Did a small change on PROCEDURE             |
--|                               spr_load_subcontracting_po for to_char      |
--|   12-Dec-2005          shzhao did a small change on PROCEDURE             |
--|                               spr_load_subcontracting_po for address      |
--|   10-Jan-2006          shzhao Updated the logging code.                   |
--|   12-Apr-2006          the2   Fixed bug 5151544: The Parameter selection  |
--|                               "Buyer Name and Employee no" does not work. |
--|   16-Jun-2006          the2   Fixed bug 5197398: Add Project_num and      |
--|                               task_num to subcontracting order report.    |
--|   23-Jun-2006          the2   Fixed bug 5352338: adjust cursor            |
--|                               l_cur_get_subcontracting_po                 |
--|   26-Jun-2006          the2   Adjust cursor l_cur_get_subcontracting_po to|
--|                               get project_id and task_id from             |
--|                               jmf_subcontract_orders table                |
--|   26-Jun-2006          the2   Adjust cursor l_cur_get_subcontracting_po to|
--|                               merge project_num1 and project_num2 to just |
--|                               one project_num                             |
--+===========================================================================+

  --=============================================
  -- CONSTANTS
  --=============================================
  g_pkg_name      CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_RPT_SPR_PVT';
  g_module_prefix CONSTANT VARCHAR2(50) := 'jmf.plsql.' || g_pkg_name || '.';

  --=============================================
  -- GLOBAL VARIABLES
  --=============================================

  g_debug_level NUMBER := fnd_log.g_current_runtime_level;
  g_proc_level  NUMBER := fnd_log.level_procedure;
  --g_unexp_level NUMBER := fnd_log.level_unexpected;
  g_excep_level NUMBER := fnd_log.level_exception;

  --========================================================================
  -- PROCEDURE : spr_load_subcontracting_po     PUBLIC
  -- PARAMETERS: p_ou_id                     operating unit id
  --           : p_report_type               print selection
  --           : p_po_num_from               po number from
  --           : p_po_num_to                 po number to
  --           : p_agent_name_num            agent number
  --           : p_cancel_line               print cancel line
  --           : p_approved_flag             approved
  -- COMMENT   : get shikyu subcontracting data and insert into temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================

  PROCEDURE spr_load_subcontracting_po
  ( p_ou_id          IN NUMBER
  , p_report_type    IN VARCHAR2
  , p_po_num_from    IN VARCHAR2
  , p_po_num_to      IN VARCHAR2
  , p_agent_name_num IN NUMBER
  , p_cancel_line    IN VARCHAR2
  , p_approved_flag  IN VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'spr_load_subcontracting_po';

     l_subcontract_po_shipment_id  jmf_shikyu_spr_rpt_temp.SUBCONTRACT_PO_SHIPMENT_ID%TYPE ;
     l_shipment_type        jmf_shikyu_spr_rpt_temp.shipment_type%TYPE;
     l_report_title_num     jmf_shikyu_spr_rpt_temp.report_title_num%TYPE ;
     l_po_number            jmf_shikyu_spr_rpt_temp.sub_po_num%TYPE ;
     l_agent_name           jmf_shikyu_spr_rpt_temp.agent_name%TYPE ;
     l_line_num             jmf_shikyu_spr_rpt_temp.SUB_PO_LINE_NUM%TYPE ;
     l_shipment_num         jmf_shikyu_spr_rpt_temp.SHIP_OR_RELEASE_NUM%TYPE ;
     l_revision_num         jmf_shikyu_spr_rpt_temp.REV_NUM%TYPE ;
     l_creation_date        jmf_shikyu_spr_rpt_temp.CREATION_DATE%TYPE ;
     l_created_by_name      jmf_shikyu_spr_rpt_temp.CREATED_BY_NAME%TYPE ;
     l_revised_date         jmf_shikyu_spr_rpt_temp.REVISED_DATE%TYPE ;
     l_last_updated_by_name jmf_shikyu_spr_rpt_temp.REVISED_BY_NAME%TYPE ;
     l_vendor_site_code     jmf_shikyu_spr_rpt_temp.VENDOR_SITE_CODE%TYPE ;
     l_vendor_address_line1 jmf_shikyu_spr_rpt_temp.VENDOR_SITE_ADDRESS1%TYPE ;
     l_vendor_address_line2  jmf_shikyu_spr_rpt_temp.VENDOR_SITE_ADDRESS2%TYPE ;
     l_vendor_address_line3  jmf_shikyu_spr_rpt_temp.VENDOR_SITE_ADDRESS3%TYPE ;
     l_shipto_location_code  jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_CODE%TYPE ;
     l_shipto_address_line_1 jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_ADDRESS1%TYPE ;
     l_shipto_address_line_2 jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_ADDRESS2%TYPE ;
     l_shipto_address_line_3 jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_ADDRESS3%TYPE ;
     l_billto_location_code  jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_CODE%TYPE ;
     l_billto_address_line_1 jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_ADDRESS1%TYPE ;
     l_billto_address_line_2 jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_ADDRESS2%TYPE ;
     l_billto_address_line_3 jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_ADDRESS3%TYPE ;

     l_vendor_city_state_zip jmf_shikyu_spr_rpt_temp.VENDOR_CITY_STATE_ZIP%TYPE ;
     l_vendor_country jmf_shikyu_spr_rpt_temp.VENDOR_COUNTRY%TYPE ;
     l_ship_to_site_postal_code  jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_POSTAL_CODE%TYPE ;
     l_ship_to_site_country  jmf_shikyu_spr_rpt_temp.SHIP_TO_SITE_COUNTRY%TYPE ;
     l_billto_site_postal_code jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_POSTAL_CODE%TYPE ;
     l_billto_site_country  jmf_shikyu_spr_rpt_temp.BILL_TO_SITE_COUNTRY%TYPE ;

     l_customer_num          jmf_shikyu_spr_rpt_temp.CUSTOMER_NUM%TYPE ;
     l_supplier_num          jmf_shikyu_spr_rpt_temp.SUPPLIER_NUM%TYPE ;
     l_pay_term              jmf_shikyu_spr_rpt_temp.PAY_TERM%TYPE ;
     l_FREIGHT_TERM          jmf_shikyu_spr_rpt_temp.FREIGHT_TERM%TYPE ;
     l_FOB_TYPE              jmf_shikyu_spr_rpt_temp.FOB_TYPE%TYPE ;
     l_SHIPPING_CONTROL      jmf_shikyu_spr_rpt_temp.SHIPPING_CONTROL%TYPE ;
     l_SHIP_VIA              jmf_shikyu_spr_rpt_temp.SHIP_VIA%TYPE ;
     l_CONFIRM_TO_NAME       jmf_shikyu_spr_rpt_temp.CONFIRM_TO_NAME%TYPE ;
     l_CONFIRM_TO_TELEPHONE  jmf_shikyu_spr_rpt_temp.CONFIRM_TO_TELEPHONE%TYPE ;
     l_REQUESTER             jmf_shikyu_spr_rpt_temp.REQUESTER%TYPE ;
     l_NOTES                 jmf_shikyu_spr_rpt_temp.NOTES%TYPE ;
     l_project_num           jmf_shikyu_spr_rpt_temp.PROJECT_NUM%TYPE ;
     l_task_num              jmf_shikyu_spr_rpt_temp.TASK_NUM%TYPE ;
     l_ITEM_NUM              jmf_shikyu_spr_rpt_temp.ITEM_NUM%TYPE ;
     l_ITEM_DESC             jmf_shikyu_spr_rpt_temp.ITEM_DESC%TYPE ;
     l_NEED_BY_DATE          jmf_shikyu_spr_rpt_temp.NEED_BY_DATE%TYPE ;
     l_PROMISED_DATE         jmf_shikyu_spr_rpt_temp.PROMISED_DATE%TYPE ;
     l_QUANTITY              jmf_shikyu_spr_rpt_temp.QUANTITY%TYPE ;
     l_UOM                   jmf_shikyu_spr_rpt_temp.UOM%TYPE ;
     l_ITEM_PRICE            jmf_shikyu_spr_rpt_temp.ITEM_PRICE%TYPE ;
     l_TAXABLE_FLAG          jmf_shikyu_spr_rpt_temp.TAXABLE_FLAG%TYPE ;
     l_AMOUNT                jmf_shikyu_spr_rpt_temp.AMOUNT%TYPE ;
     l_AGENT_ID              jmf_shikyu_spr_rpt_temp.AGENT_ID%TYPE ;
     l_VENDOR_ID             jmf_shikyu_spr_rpt_temp.VENDOR_ID%TYPE ;
     l_ITEM_ID               jmf_shikyu_spr_rpt_temp.ITEM_ID%TYPE ;

     l_print_count           po_headers_all.print_count%TYPE;
     l_printed_date          po_headers_all.printed_date%TYPE;
     l_type_lookup_code      po_headers_all.type_lookup_code%TYPE;
     l_po_header_id          po_headers_all.po_header_id%TYPE;
     l_po_line_id            po_lines_all.po_line_id%TYPE;

     l_cancel_flag           po_lines_all.cancel_flag%TYPE;
     l_po_release_id         po_line_locations_all.po_release_id%TYPE;

     l_manual_po_num_type    PO_SYSTEM_PARAMETERS.manual_po_num_type%TYPE;

     CURSOR l_cur_get_blanket_po (
              lp_org_id NUMBER
              , lp_po_header_id NUMBER
              , lp_po_line_id NUMBER
              , lp_po_release_id NUMBER ) IS
     SELECT 'Subcontracting Order ' || h.segment1 || '-' || to_char(l.line_num) || '-' ||
               to_char(re.release_num) || ',' || to_char(h.revision_num)  REPORT_TITLE_NUM
               ,re.release_num
     FROM   po_headers_all h
         , po_lines_all l
         , po_line_locations_all loc
         , po_releases_all re
     WHERE re.po_release_id = loc.po_release_id
           AND loc.po_line_id = lp_po_line_id
           AND l.po_header_id = lp_po_header_id
           AND h.org_id = lp_org_id
           AND h.po_header_id = l.po_header_id
           AND l.po_line_id = loc.po_line_id
           AND re.po_release_id = lp_po_release_id ;

     CURSOR l_cur_get_subcontracting_po(
              lp_org_id NUMBER
            , lp_po_num_from VARCHAR2
            , lp_po_num_to  VARCHAR2
            , lp_agent_name_num NUMBER
            , lp_approved_flag VARCHAR2
            , lp_manual_po_num_type VARCHAR2) IS
      SELECT sub.subcontract_po_shipment_id
            , loc.shipment_type
            , 'Subcontracting Order ' || h.segment1 || '-' || l.line_num || '-' ||
               loc.shipment_num || ',' || h.revision_num REPORT_TITLE_NUM
            ,  h.segment1
            , (SELECT hremp.full_name
               FROM hr_employees hremp
               WHERE hremp.employee_id(+) = h.agent_id
                     AND h.agent_id = nvl(lp_agent_name_num,h.agent_id))  AGENT_NAME
            , l.line_num
            , loc.shipment_num
            , h.revision_num
            , h.creation_date
            , (SELECT fnd_user.user_name
               FROM fnd_user
               WHERE fnd_user.user_id = h.created_by) created_by
            , h.revised_date
            , (SELECT fnd_user.user_name
               FROM fnd_user
               WHERE fnd_user.user_id = h.last_updated_by) last_updated_by
            , pvsa.vendor_site_code
            , pvsa.address_line1
            , pvsa.address_line2
            , pvsa.address_line3
            , pvsa.city || ' ' || pvsa.state || ' ' ||  pvsa.zip
            , ( SELECT nls_territory
                FROM FND_TERRITORIES
                WHERE territory_code= pvsa.country)
            , hrloc.location_code
            , hrloc.address_line_1
            , hrloc.address_line_2
            , hrloc.address_line_3
            , hrloc.region_1 || ' ' ||  hrloc.region_2 || ' ' || hrloc.postal_code
            , ( SELECT nls_territory
                FROM FND_TERRITORIES
                WHERE territory_code= hrloc.country)
            , hrloc2.location_code
            , hrloc2.address_line_1
            , hrloc2.address_line_2
            , hrloc2.address_line_3
            , hrloc2.region_1 || ' ' ||  hrloc2.region_2 || ' ' || hrloc2.postal_code
            , ( SELECT nls_territory
                FROM FND_TERRITORIES
                WHERE territory_code= hrloc2.country)
            , (SELECT po_vendors.customer_num
                FROM po_vendors
                WHERE po_vendors.vendor_id = h.vendor_id)
            , (SELECT po_vendors.segment1
               FROM po_vendors
               WHERE po_vendors.vendor_id = h.vendor_id)
            ,  (SELECT ap_terms_tl.NAME
                FROM ap_terms_tl
                WHERE ap_terms_tl.term_id = h.terms_id AND
                  ap_terms_tl.LANGUAGE = userenv('LANG'))
            ,  (SELECT po_lookup_codes.displayed_field
                FROM po_lookup_codes
                WHERE po_lookup_codes.lookup_type = 'FREIGHT TERMS' AND
                  po_lookup_codes.lookup_code = h.freight_terms_lookup_code)
            ,  (SELECT po_lookup_codes.displayed_field
                FROM po_lookup_codes
                WHERE po_lookup_codes.lookup_type = 'FOB' AND
                      po_lookup_codes.lookup_code = h.fob_lookup_code)
            ,  (SELECT po_lookup_codes.displayed_field
                 FROM po_lookup_codes
                 WHERE po_lookup_codes.lookup_type = 'SHIPPING CONTROL' AND
                       po_lookup_codes.lookup_code = h.shipping_control)
            ,  (SELECT org_freight_tl.freight_code_tl
                 FROM org_freight_tl
                 WHERE org_freight_tl.freight_code = h.ship_via_lookup_code AND
                     org_freight_tl.LANGUAGE = userenv('LANG') AND
                     org_freight_tl.organization_id = l.org_id)
            ,  pvc.first_name || ' ' || pvc.last_name
            ,  pvc.phone
            ,  decode((SELECT COUNT(d.po_distribution_id)
                        FROM po_distributions_all d
                        WHERE d.line_location_id = sub.subcontract_po_shipment_id),
                        1,
                       ( SELECT hremp.full_name || '  ' || hrloc.location_code
                         FROM po_distributions_all d,
                         hr_locations_all     hrloc,
                         hr_employees         hremp
                         WHERE hrloc.location_id(+) = d.deliver_to_location_id AND
                               hremp.employee_id(+) = d.deliver_to_person_id AND
                               d.line_location_id = sub.subcontract_po_shipment_id),
                       --  'MANY REQUESTOR')
                            '%M' )
             ,  l.note_to_vendor
             ,  proj.project_number
             ,  pt.task_number
             ,  loc.shipment_num
             ,  mtl.segment1
             ,  mtl.description
             ,  loc.need_by_date
             ,  loc.promised_date
             ,  loc.quantity
             ,  l.unit_meas_lookup_code
             ,  sub.osa_item_price
             ,  l.taxable_flag
             ,  l.unit_price * l.quantity
             ,  h.agent_id
             ,  h.vendor_id
             ,  l.item_id
             ,  h.print_count
             ,  h.printed_date
             ,  l.cancel_flag
             ,  h.type_lookup_code
             ,  h.po_header_id
             ,  l.po_line_id
             ,  loc.po_release_id
    FROM po_headers_all         h,
          po_lines_all           l,
          po_line_locations_all  loc,
          jmf_subcontract_orders sub,
          mtl_system_items_vl    mtl,
          po_vendor_sites_all    pvsa,
          hr_locations_all       hrloc,
          hr_locations_all       hrloc2,
          po_vendor_contacts     pvc,
          (select distinct project_id, segment1 AS project_number
           from   pa_projects_all
           union
           select distinct project_id, project_number
           from   pjm_seiban_numbers) proj,
          pa_tasks               pt
    WHERE --h.type_lookup_code IN ('STANDARD')
            h.po_header_id = sub.subcontract_po_header_id
          AND  l.po_line_id = sub.subcontract_po_line_id
          AND  loc.line_location_id = sub.subcontract_po_shipment_id
          AND  pvsa.vendor_site_id(+) = h.vendor_site_id
          AND  hrloc.location_id(+) = h.ship_to_location_id
          AND  hrloc2.location_id(+) = h.bill_to_location_id
          AND  pvc.vendor_contact_id(+) = h.vendor_contact_id
          AND  mtl.inventory_item_id = l.item_id
          AND  sub.oem_organization_id = mtl.organization_id
          AND  l.org_id = lp_org_id
          AND  ((decode(lp_manual_po_num_type,
                        'NUMERIC',
                        decode(rtrim(h.segment1, '0123456789'),
                               NULL,
                               to_number(h.segment1),
                               -1),
                        null) BETWEEN
               decode(lp_manual_po_num_type,
                        'NUMERIC',
                        decode(rtrim(nvl(lp_po_num_from, h.segment1), '0123456789'),
                               NULL,
                               to_number(nvl(lp_po_num_from, h.segment1)),
                               -1),
                        null) AND
               decode(lp_manual_po_num_type,
                        'NUMERIC',
                        decode(rtrim(nvl(lp_po_num_to, h.segment1), '0123456789'),
                               NULL,
                               to_number(nvl(lp_po_num_to, h.segment1)),
                               -1),
                        null)) OR
               (h.segment1 BETWEEN decode(lp_manual_po_num_type,
                                             'ALPHANUMERIC',
                                             nvl(lp_po_num_from, h.segment1),
                                             null) AND
               decode(lp_manual_po_num_type,
                        'ALPHANUMERIC',
                        nvl(lp_po_num_to, h.segment1),
                        null)))
          AND  h.approved_flag = NVL(lp_approved_flag,h.approved_flag)
          AND  h.agent_id = NVL(lp_agent_name_num,h.agent_id)
          AND  proj.project_id(+) = sub.project_id
          AND  pt.task_id(+) = sub.task_id;


  BEGIN
  --  g_debug_level := fnd_log.g_current_runtime_level;

    IF (g_proc_level >= g_debug_level)
    THEN
      fnd_log.STRING(g_proc_level
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    DELETE FROM jmf_shikyu_spr_rpt_temp;

    commit;

    SELECT psp.manual_po_num_type manual_po_num_type
    INTO   l_manual_po_num_type
    FROM   po_system_parameters_all psp
    where  org_id = p_ou_id;

   /* EXCEPTION
      WHEN no_data_found THEN
        l_manual_po_num_type := 'ALPHANUMERIC';   */

    OPEN l_cur_get_subcontracting_po
                (  p_ou_id
                 , p_po_num_from
                 , p_po_num_to
                 , p_agent_name_num
                 , p_approved_flag
                 , l_manual_po_num_type
                   );

    LOOP
      FETCH l_cur_get_subcontracting_po
       INTO  l_subcontract_po_shipment_id
             ,l_shipment_type
             ,l_report_title_num
             ,l_po_number
             ,l_agent_name
             ,l_line_num
             ,l_shipment_num
             ,l_revision_num
             ,l_creation_date
             ,l_created_by_name
             ,l_revised_date
             ,l_last_updated_by_name
             ,l_vendor_site_code
             ,l_vendor_address_line1
             ,l_vendor_address_line2
             ,l_vendor_address_line3
             ,l_vendor_city_state_zip
             ,l_vendor_country
             ,l_shipto_location_code
             ,l_shipto_address_line_1
             ,l_shipto_address_line_2
             ,l_shipto_address_line_3
             ,l_ship_to_site_postal_code
             ,l_ship_to_site_country
             ,l_billto_location_code
             ,l_billto_address_line_1
             ,l_billto_address_line_2
             ,l_billto_address_line_3
             ,l_billto_site_postal_code
             ,l_billto_site_country
             ,l_customer_num
             ,l_supplier_num
             ,l_pay_term
             ,l_FREIGHT_TERM
             ,l_FOB_TYPE
             ,l_SHIPPING_CONTROL
             ,l_SHIP_VIA
             ,l_CONFIRM_TO_NAME
             ,l_CONFIRM_TO_TELEPHONE
             ,l_REQUESTER
             ,l_NOTES
             ,l_project_num
             ,l_task_num
             ,l_SHIPMENT_NUM
             ,l_ITEM_NUM
             ,l_ITEM_DESC
             ,l_NEED_BY_DATE
             ,l_PROMISED_DATE
             ,l_QUANTITY
             ,l_UOM
             ,l_ITEM_PRICE
             ,l_TAXABLE_FLAG
             ,l_AMOUNT
             ,l_AGENT_ID
             ,l_VENDOR_ID
             ,l_ITEM_ID
             ,l_print_count
             ,l_printed_date
             ,l_cancel_flag
             ,l_type_lookup_code
             ,l_po_header_id
             ,l_po_line_id
             ,l_po_release_id  ;

      EXIT WHEN l_cur_get_subcontracting_po%NOTFOUND;

          --p_report_type
      IF ( p_report_type = 'N' AND nvl(l_print_count,0) = 0) OR
         ( p_report_type = 'C' AND l_revised_date > l_printed_date) OR
         ( nvl( p_report_type,'R') = 'R')   THEN

         -- cancel flag
         IF  (NVL(p_cancel_line ,'Y') = 'N' AND l_cancel_flag ='N') OR
              ( NVL(p_cancel_line ,'Y') = 'Y')   THEN

            -- need_by_date and promised_date
            IF (l_NEED_BY_DATE IS NOT NULL) AND (l_PROMISED_DATE IS NOT NULL) THEN
               l_PROMISED_DATE :=NULL;
            END IF;

           -- balnket PO
            IF l_type_lookup_code = 'BLANKET' THEN

              OPEN l_cur_get_blanket_po (
                p_ou_id
              , l_po_header_id
              , l_po_line_id
              , l_po_release_id) ;

              LOOP
                FETCH l_cur_get_blanket_po
                    INTO  l_report_title_num
                         , l_shipment_num   ;


                EXIT WHEN l_cur_get_blanket_po%NOTFOUND;
              END LOOP;
              CLOSE l_cur_get_blanket_po;

           END IF;

           INSERT INTO jmf_shikyu_spr_rpt_temp
           ( subcontract_po_shipment_id
             , shipment_type
             , report_title_num
             , sub_po_num
             , agent_name
             , sub_po_line_num
             , ship_or_release_num
             , rev_num
             , creation_date
             , created_by_name
             , revised_date
             , REVISED_BY_NAME
             , vendor_site_code
             , VENDOR_SITE_ADDRESS1
             , VENDOR_SITE_ADDRESS2
             , VENDOR_SITE_ADDRESS3
             , VENDOR_CITY_STATE_ZIP
             , VENDOR_COUNTRY
             , SHIP_TO_SITE_CODE
             , SHIP_TO_SITE_ADDRESS1
             , SHIP_TO_SITE_ADDRESS2
             , SHIP_TO_SITE_ADDRESS3
             , SHIP_TO_SITE_POSTAL_CODE
             , SHIP_TO_SITE_COUNTRY
             , BILL_TO_SITE_CODE
             , BILL_TO_SITE_ADDRESS1
             , BILL_TO_SITE_ADDRESS2
             , BILL_TO_SITE_ADDRESS3
             , BILL_TO_SITE_POSTAL_CODE
             , BILL_TO_SITE_COUNTRY
             , customer_num
             , supplier_num
             , pay_term
             , FREIGHT_TERM
             , FOB_TYPE
             , SHIPPING_CONTROL
             , SHIP_VIA
             , CONFIRM_TO_NAME
             , CONFIRM_TO_TELEPHONE
             , REQUESTER
             , NOTES
             , PROJECT_NUM
             , TASK_NUM
             , SHIPMENT_NUM
             , ITEM_NUM
             , ITEM_DESC
             , NEED_BY_DATE
             , PROMISED_DATE
             , QUANTITY
             , UOM
             , ITEM_PRICE
             , TAXABLE_FLAG
             , AMOUNT
             , AGENT_ID
             , VENDOR_ID
             , ITEM_ID  )
      VALUES
        (l_subcontract_po_shipment_id
             ,l_shipment_type
             ,l_report_title_num
             ,l_po_number
             ,l_agent_name
             ,l_line_num
             ,l_shipment_num
             ,l_revision_num
             ,l_creation_date
             ,l_created_by_name
             ,l_revised_date
             ,l_last_updated_by_name
             ,l_vendor_site_code
             ,l_vendor_address_line1
             ,l_vendor_address_line2
             ,l_vendor_address_line3
             ,l_vendor_city_state_zip
             ,l_vendor_country
             ,l_shipto_location_code
             ,l_shipto_address_line_1
             ,l_shipto_address_line_2
             ,l_shipto_address_line_3
             ,l_ship_to_site_postal_code
             ,l_ship_to_site_country
             ,l_billto_location_code
             ,l_billto_address_line_1
             ,l_billto_address_line_2
             ,l_billto_address_line_3
             ,l_billto_site_postal_code
             ,l_billto_site_country
             ,l_customer_num
             ,l_supplier_num
             ,l_pay_term
             ,l_FREIGHT_TERM
             ,l_FOB_TYPE
             ,l_SHIPPING_CONTROL
             ,l_SHIP_VIA
             ,l_CONFIRM_TO_NAME
             ,l_CONFIRM_TO_TELEPHONE
             ,l_REQUESTER
             ,l_NOTES
             ,l_project_num
             ,l_task_num
             ,l_SHIPMENT_NUM
             ,l_ITEM_NUM
             ,l_ITEM_DESC
             ,l_NEED_BY_DATE
             ,l_PROMISED_DATE
             ,l_QUANTITY
             ,l_UOM
             ,l_ITEM_PRICE
             ,l_TAXABLE_FLAG
             ,l_AMOUNT
             ,l_AGENT_ID
             ,l_VENDOR_ID
             ,l_ITEM_ID);
    END IF;

    END IF;

    COMMIT;

    END LOOP;

    CLOSE l_cur_get_subcontracting_po;


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

  END spr_load_subcontracting_po;

END jmf_shikyu_rpt_spr_pvt;

/
