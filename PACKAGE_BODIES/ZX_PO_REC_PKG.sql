--------------------------------------------------------
--  DDL for Package Body ZX_PO_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PO_REC_PKG" AS
/* $Header: zxpotrxpoprecb.pls 120.10.12010000.5 2009/04/30 08:50:18 prigovin ship $ */

pg_po_header_id_tab 	         po_header_id_tbl;
pg_po_line_id_tab	         po_line_id_tbl;
pg_po_dist_id_tab 	         po_dist_id_tbl;
pg_tax_code_id_tab               tax_code_id_tbl;
pg_trx_date_tab  	         trx_date_tbl;
pg_code_combination_id_tab       code_combination_id_tbl;
pg_vendor_id_tab                 vendor_id_tbl;
pg_tax_rec_override_flag_tab     tax_recovery_override_flag_tbl;
pg_tax_recovery_rate_tab         tax_recovery_rate_tbl;
pg_vendor_site_id_tab	         vendor_site_id_tbl;
pg_item_id_tab 	                 inv_org_id_tbl;
pg_inv_org_id_tab 	         item_id_tbl;
pg_chart_of_accounts_id_tab      chart_of_accounts_id_tbl;
pg_tc_tax_recovery_rule_id_tab   tc_tax_recovery_rule_id_tbl;
pg_tc_tax_recovery_rate_tab      tc_tax_recovery_rate_tbl;
pg_vendor_type_lookup_code_tab   vendor_type_lookup_code_tbl;


-- pg_get_tax_recovery_rate_tab	get_rec_rate_tbl;
l_rec_rate number;
 TYPE get_rec_rate_tbl1 IS TABLE OF PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%TYPE INDEX BY BINARY_INTEGER;
pg_get_tax_recovery_rate_tab1         get_rec_rate_tbl1;

C_LINES_PER_INSERT                 CONSTANT NUMBER :=  5000;
i NUMBER;
PG_DEBUG varchar2(1) :='Y';

PROCEDURE get_rec_info(
  p_start_rowid    IN            ROWID,
  p_end_rowid      IN            ROWID) IS

CURSOR pod_rec_rate IS
SELECT /*+ ORDERED NO_EXPAND use_nl(pod, pol, poll, atc,atg, atc1, pov) */
       NVL(poll.po_release_id, poh.po_header_id),
       pod.line_location_id,
       pod.po_distribution_id,
       NVL(atg.tax_code_id,atc.tax_id),
       poh.last_update_date,
       pod.code_combination_id,
       poh.vendor_id,
       pod.tax_recovery_override_flag,
       pod.recovery_rate,
       poh.vendor_site_id,
       pol.item_id,
       poh.inventory_organization_id,
       poh.chart_of_accounts_id,
       atc1.tax_recovery_rule_id,
       atc1.tax_recovery_rate,
       pov.vendor_type_lookup_code
 FROM
      ( SELECT /*+ ROWID(poh) NO_MERGE swap_join_inputs(fsp) swap_join_inputs(lgr)
                   INDEX (fsp financials_system_params_u1) INDEX (lgr gl_ledgers_u2)*/
               poh.po_header_id, poh.last_update_date,poh.vendor_id,poh.vendor_site_id,
               fsp.set_of_books_id, fsp.org_id, fsp.inventory_organization_id,
               lgr.chart_of_accounts_id
          FROM po_headers_all poh,
      	       financials_system_params_all fsp,
      	       xla_upgrade_dates upd,
      	       gl_ledgers lgr
         WHERE poh.rowid BETWEEN p_start_rowid AND p_end_rowid
           AND NVL(poh.closed_code, 'OPEN') <> 'FINALLY CLOSED'
           AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
           AND upd.ledger_id = fsp.set_of_books_id
           AND (NVL(poh.closed_code, 'OPEN') = 'OPEN' OR
                poh.last_update_date >= upd.start_date
               )
           AND lgr.ledger_id = fsp.set_of_books_id
      ) poh,
      po_distributions_all pod,
      po_line_locations_all poll,
      po_lines_all pol,
      ap_tax_codes_all atc,
      ar_tax_group_codes_all atg,
      ap_tax_codes_all atc1,
      po_vendors pov
WHERE poh.po_header_id = pod.po_header_id
  AND pol.po_header_id = poll.po_header_id
  AND pol.po_line_id = poll.po_line_id
  AND poll.po_header_id = pod.po_header_id
  AND poll.po_line_id = pod.po_line_id
  AND poll.line_location_id = pod.line_location_id
  AND nvl(atc.org_id,-99)=nvl(poh.org_id,-99)
  AND poll.tax_code_id = atc.tax_id(+)
  AND poll.tax_code_id = atg.tax_group_id(+)
  --Bug 8352135
  AND atg.start_date <= poll.last_update_date
  AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
  AND atc.tax_type = 'TAX_GROUP'
  AND pod.recovery_rate IS NULL
  AND atc1.tax_id(+) = atg.tax_code_id
  AND atc1.enabled_flag(+) = 'Y'
  AND pov.vendor_id = poh.vendor_id;

 l_count	NUMBER;
 l_tax_rate_id NUMBER;

BEGIN

  OPEN pod_rec_rate;
  LOOP
    FETCH pod_rec_rate BULK COLLECT INTO
          pg_po_header_id_tab,
          pg_po_line_id_tab,
          pg_po_dist_id_tab,
          pg_tax_code_id_tab,
          pg_trx_date_tab,
          pg_code_combination_id_tab,
          pg_vendor_id_tab,
          pg_tax_rec_override_flag_tab,
          pg_tax_recovery_rate_tab,
          pg_vendor_site_id_tab,
          pg_item_id_tab,
          pg_inv_org_id_tab,
          pg_chart_of_accounts_id_tab,
          pg_tc_tax_recovery_rule_id_tab,
          pg_tc_tax_recovery_rate_tab,
          pg_vendor_type_lookup_code_tab
    LIMIT C_LINES_PER_INSERT;

    l_count := pg_tax_code_id_tab.COUNT;
    IF l_count > 0 THEN
      FOR i IN 1 .. l_count LOOP
        ZX_TAX_RECOVERY_PKG.get_default_rate(
                  p_tax_code                  => NULL,
                  p_tax_id                    => PG_TAX_CODE_ID_TAB(i),
                  p_tax_date                  => PG_TRX_DATE_TAB(i),
                  p_code_combination_id       => PG_CODE_COMBINATION_ID_TAB(i),
                  p_vendor_id                 => PG_VENDOR_ID_TAB(i),
                  p_distribution_id           => null,
                  p_tax_user_override_flag    => PG_TAX_REC_OVERRIDE_FLAG_TAB(i),
                  p_user_tax_recovery_rate    => PG_TAX_RECOVERY_RATE_TAB(i),
                  p_concatenated_segments     => '',
                  p_vendor_site_id            => PG_VENDOR_SITE_ID_TAB(i),
                  p_inventory_item_id         => PG_ITEM_ID_TAB(i),
                  p_item_org_id               => PG_ITEM_ID_TAB(i),
                  APPL_SHORT_NAME             => 'PO',
                  FUNC_SHORT_NAME             => '',
                  p_calling_sequence          => 'PO_MIG',
                  p_chart_of_accounts_id      => pg_chart_of_accounts_id_tab(i),
                  p_tc_tax_recovery_rule_id   => pg_tc_tax_recovery_rule_id_tab(i),
                  p_tc_tax_recovery_rate      => pg_tc_tax_recovery_rate_tab(i),
                  p_vendor_type_lookup_code   => pg_vendor_type_lookup_code_tab(i),
                  p_tax_recovery_rate         => l_rec_rate );

        pg_get_tax_recovery_rate_tab(i) := l_rec_rate;
        BEGIN
            SELECT TAX_RATE_ID INTO l_tax_rate_id
            FROM ZX_RATES_B
            WHERE NVL(source_id,tax_rate_id) = pg_tax_code_id_tab(i)
	    AND record_type_code='MIGRATED';
        EXCEPTION
           WHEN OTHERS THEN
              NULL;
        END;

            IF (pg_tax_code_id_tab(i) <> l_tax_rate_id) and l_tax_rate_id is NOT NULL THEN
              pg_tax_code_id_tab(i) := l_tax_rate_id;
            END IF;

      END LOOP;

      insert_rec_info;
      COMMIT;
    ELSE
      --Bug 7715015
      IF pod_rec_rate%ISOPEN THEN
        CLOSE pod_rec_rate;
      END IF;
      EXIT;
    END IF;

    IF pod_rec_rate%NOTFOUND THEN
      --Bug 7715015
      IF pod_rec_rate%ISOPEN THEN
        CLOSE pod_rec_rate;
      END IF;
      EXIT;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF pod_rec_rate%ISOPEN THEN
     CLOSE pod_rec_rate;
    END IF;
    RAISE;

END get_rec_info;

PROCEDURE INSERT_REC_INFO
IS

  l_count       number;

BEGIN

  -- To handle re-runnability, truncate the table first

  -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ZX.ZX_PO_REC_DIST';

  l_count := NVL(PG_TAX_CODE_ID_TAB.COUNT, 0);

  FORALL i IN 1 .. l_count
    INSERT INTO  ZX_PO_REC_DIST
    ( PO_HEADER_ID,
      PO_LINE_LOCATION_ID,
      PO_DISTRIBUTION_ID,
      REC_RATE,
      TAX_RATE_ID,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
    PG_PO_HEADER_ID_TAB(i),
    PG_PO_LINE_ID_TAB(i),
    PG_PO_DIST_ID_TAB(i),
    pg_get_tax_recovery_rate_tab(i),
    PG_TAX_CODE_ID_TAB(i),
    1,
    SYSDATE,
    1,
    SYSDATE,
    1   );

/* IF PG_DEBUG = 'Y' THEN
      		         dbms_output.put_line('after call to PO_REC_DIST_TBL ');
       END IF;   */

  END INSERT_REC_INFO;

PROCEDURE INIT_REC_GT_TABLES  IS
BEGIN

 -- PG_PO_HEADER_ID_TAB.DELETE;
 -- PG_PO_LINE_ID_TAB.DELETE;
 -- PG_PO_DIST_ID_TAB.DELETE;

 PG_TAX_CODE_ID_TAB.DELETE;
 PG_TRX_DATE_TAB.DELETE;
 PG_CODE_COMBINATION_ID_TAB.DELETE;
 PG_VENDOR_ID_TAB.DELETE;
 PG_TAX_REC_OVERRIDE_FLAG_TAB.DELETE;
 PG_TAX_RECOVERY_RATE_TAB.DELETE;
 PG_VENDOR_SITE_ID_TAB.DELETE;
 PG_ITEM_ID_TAB.DELETE;
 PG_INV_ORG_ID_TAB.DELETE;
 -- pg_get_tax_recovery_rate_tab.DELETE;

END INIT_REC_GT_TABLES;

PROCEDURE get_rec_info(
  p_upg_trx_info_rec IN         ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2) AS

 CURSOR pod_rec_rate_po IS
 SELECT /*+ ORDERED NO_EXPAND use_nl(pod, poll,pol, atc,atg, atc1, pov)
            INDEX (fsp financials_system_params_u1) INDEX (lgr gl_ledgers_u2)*/
        poh.po_header_id,
        pod.line_location_id,
        pod.po_distribution_id,
        NVL(atg.tax_code_id, atc.tax_id),
        poh.last_update_date,
        pod.code_combination_id,
        poh.vendor_id,
        pod.tax_recovery_override_flag,
        pod.recovery_rate,
        poh.vendor_site_id,
        pol.item_id,
        fsp.inventory_organization_id,
        lgr.chart_of_accounts_id,
        atc1.tax_recovery_rule_id,
        atc1.tax_recovery_rate,
        pov.vendor_type_lookup_code
   FROM po_headers_all poh,
        po_distributions_all pod,
        po_line_locations_all poll,
        po_lines_all pol,
        ap_tax_codes_all atc,
        ar_tax_group_codes_all atg,
        ap_tax_codes_all atc1,
        po_vendors pov,
        financials_system_params_all fsp,
        gl_ledgers lgr
  WHERE poh.po_header_id = p_upg_trx_info_rec.trx_id
    AND pod.po_header_id = poh.po_header_id
    AND pod.recovery_rate IS NULL
    AND poll.po_header_id = pod.po_header_id
    AND poll.po_line_id = pod.po_line_id
    AND poll.line_location_id = pod.line_location_id
    AND pol.po_header_id = poll.po_header_id
    AND pol.po_line_id = poll.po_line_id
    AND nvl(atc.org_id,-99)=nvl(poh.org_id,-99)
    AND poll.tax_code_id = atc.tax_id
    AND poll.tax_code_id = atg.tax_group_id
    AND atc.tax_type = 'TAX_GROUP'
    AND atc1.tax_id = atg.tax_code_id
    AND atc1.enabled_flag = 'Y'
    AND pov.vendor_id = poh.vendor_id
    AND NVL(fsp.org_id, -99) = NVL(poh.org_id, -99)
    AND lgr.ledger_id = fsp.set_of_books_id;

 CURSOR pod_rec_rate_release IS
 SELECT /*+ ORDERED NO_EXPAND use_nl(pod, poh, pol, atc,atg, atc1, pov)
            INDEX (fsp financials_system_params_u1) INDEX (lgr gl_ledgers_u2)*/
        poll.po_release_id,
        pod.line_location_id,
        pod.po_distribution_id,
        NVL(atg.tax_code_id, atc.tax_id),
        poh.last_update_date,
        pod.code_combination_id,
        poh.vendor_id,
        pod.tax_recovery_override_flag,
        pod.recovery_rate,
        poh.vendor_site_id,
        pol.item_id,
        fsp.inventory_organization_id,
        lgr.chart_of_accounts_id,
        atc1.tax_recovery_rule_id,
        atc1.tax_recovery_rate,
        pov.vendor_type_lookup_code
  FROM po_line_locations_all poll,
       po_distributions_all pod,
       po_headers_all poh,
       po_lines_all pol,
       ap_tax_codes_all atc,
       ar_tax_group_codes_all atg,
       ap_tax_codes_all atc1,
       po_vendors pov,
       financials_system_params_all fsp,
       gl_ledgers lgr
 WHERE poll.po_release_id = p_upg_trx_info_rec.trx_id
   AND pod.po_header_id = poll.po_header_id
   AND pod.po_line_id = poll.po_line_id
   AND pod.line_location_id = poll.line_location_id
   AND pod.recovery_rate IS NULL
   AND poh.po_header_id = poll.po_header_id
   AND pol.po_header_id = poll.po_header_id
   AND pol.po_line_id = poll.po_line_id
   AND nvl(atc.org_id,-99)=nvl(poh.org_id,-99)
   AND poll.tax_code_id = atc.tax_id
   AND poll.tax_code_id = atg.tax_group_id
   AND atc.tax_type = 'TAX_GROUP'
   AND atc1.tax_id = atg.tax_code_id
   AND atc1.enabled_flag = 'Y'
   AND pov.vendor_id = poh.vendor_id
   AND NVL(fsp.org_id, -99) = NVL(poh.org_id, -99)
   AND lgr.ledger_id = fsp.set_of_books_id;

 l_count	NUMBER;
 l_tax_rate_id  NUMBER;

BEGIN

  IF p_upg_trx_info_rec.entity_code = 'PURCHASE_ORDER' THEN
    OPEN pod_rec_rate_po;
    LOOP
      FETCH pod_rec_rate_po BULK COLLECT INTO
            pg_po_header_id_tab,
            pg_po_line_id_tab,
            pg_po_dist_id_tab,
            pg_tax_code_id_tab,
            pg_trx_date_tab,
            pg_code_combination_id_tab,
            pg_vendor_id_tab,
            pg_tax_rec_override_flag_tab,
            pg_tax_recovery_rate_tab,
            pg_vendor_site_id_tab,
            pg_item_id_tab,
            pg_inv_org_id_tab,
            pg_chart_of_accounts_id_tab,
            pg_tc_tax_recovery_rule_id_tab,
            pg_tc_tax_recovery_rate_tab,
            pg_vendor_type_lookup_code_tab
      LIMIT C_LINES_PER_INSERT;

      l_count := pg_tax_code_id_tab.COUNT;
      IF l_count > 0 THEN
        FOR i IN 1 .. l_count LOOP
          ZX_TAX_RECOVERY_PKG.get_default_rate(
                    p_tax_code                  => NULL,
                    p_tax_id                    => PG_TAX_CODE_ID_TAB(i),
                    p_tax_date                  => PG_TRX_DATE_TAB(i),
                    p_code_combination_id       => PG_CODE_COMBINATION_ID_TAB(i),
                    p_vendor_id                 => PG_VENDOR_ID_TAB(i),
                    p_distribution_id           => null,
                    p_tax_user_override_flag    => PG_TAX_REC_OVERRIDE_FLAG_TAB(i),
                    p_user_tax_recovery_rate    => PG_TAX_RECOVERY_RATE_TAB(i),
                    p_concatenated_segments     => '',
                    p_vendor_site_id            => PG_VENDOR_SITE_ID_TAB(i),
                    p_inventory_item_id         => PG_ITEM_ID_TAB(i),
                    p_item_org_id               => PG_ITEM_ID_TAB(i),
                    APPL_SHORT_NAME             => 'PO',
                    FUNC_SHORT_NAME             => '',
                    p_calling_sequence          => 'PO_MIG',
                    p_chart_of_accounts_id      => pg_chart_of_accounts_id_tab(i),
                    p_tc_tax_recovery_rule_id   => pg_tc_tax_recovery_rule_id_tab(i),
                    p_tc_tax_recovery_rate      => pg_tc_tax_recovery_rate_tab(i),
                    p_vendor_type_lookup_code   => pg_vendor_type_lookup_code_tab(i),
                    p_tax_recovery_rate         => l_rec_rate );

          pg_get_tax_recovery_rate_tab(i) := l_rec_rate;
          BEGIN
            SELECT TAX_RATE_ID INTO l_tax_rate_id
            FROM ZX_RATES_B
            WHERE NVL(source_id,tax_rate_id) = pg_tax_code_id_tab(i)
            AND record_type_code='MIGRATED';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

            IF (pg_tax_code_id_tab(i) <> l_tax_rate_id) and l_tax_rate_id is NOT NULL THEN
              pg_tax_code_id_tab(i) := l_tax_rate_id;
            END IF;

        END LOOP;

        insert_rec_info;
        COMMIT;
      ELSE
        CLOSE pod_rec_rate_po;
        EXIT;
      END IF;

      IF pod_rec_rate_po%NOTFOUND THEN
        CLOSE pod_rec_rate_po;
        EXIT;
      END IF;
    END LOOP;

  ELSIF p_upg_trx_info_rec.entity_code = 'RELEASE' THEN
    OPEN pod_rec_rate_release;
    LOOP
      FETCH pod_rec_rate_release BULK COLLECT INTO
            pg_po_header_id_tab,
            pg_po_line_id_tab,
            pg_po_dist_id_tab,
            pg_tax_code_id_tab,
            pg_trx_date_tab,
            pg_code_combination_id_tab,
            pg_vendor_id_tab,
            pg_tax_rec_override_flag_tab,
            pg_tax_recovery_rate_tab,
            pg_vendor_site_id_tab,
            pg_item_id_tab,
            pg_inv_org_id_tab,
            pg_chart_of_accounts_id_tab,
            pg_tc_tax_recovery_rule_id_tab,
            pg_tc_tax_recovery_rate_tab,
            pg_vendor_type_lookup_code_tab
      LIMIT C_LINES_PER_INSERT;

      l_count := pg_tax_code_id_tab.COUNT;

      IF l_count > 0 THEN
        FOR i IN 1 .. l_count LOOP
          ZX_TAX_RECOVERY_PKG.get_default_rate(
                    p_tax_code                  => NULL,
                    p_tax_id                    => PG_TAX_CODE_ID_TAB(i),
                    p_tax_date                  => PG_TRX_DATE_TAB(i),
                    p_code_combination_id       => PG_CODE_COMBINATION_ID_TAB(i),
                    p_vendor_id                 => PG_VENDOR_ID_TAB(i),
                    p_distribution_id           => null,
                    p_tax_user_override_flag    => PG_TAX_REC_OVERRIDE_FLAG_TAB(i),
                    p_user_tax_recovery_rate    => PG_TAX_RECOVERY_RATE_TAB(i),
                    p_concatenated_segments     => '',
                    p_vendor_site_id            => PG_VENDOR_SITE_ID_TAB(i),
                    p_inventory_item_id         => PG_ITEM_ID_TAB(i),
                    p_item_org_id               => PG_ITEM_ID_TAB(i),
                    APPL_SHORT_NAME             => 'PO',
                    FUNC_SHORT_NAME             => '',
                    p_calling_sequence          => 'PO_MIG',
                    p_chart_of_accounts_id      => pg_chart_of_accounts_id_tab(i),
                    p_tc_tax_recovery_rule_id   => pg_tc_tax_recovery_rule_id_tab(i),
                    p_tc_tax_recovery_rate      => pg_tc_tax_recovery_rate_tab(i),
                    p_vendor_type_lookup_code   => pg_vendor_type_lookup_code_tab(i),
                    p_tax_recovery_rate         => l_rec_rate );

          pg_get_tax_recovery_rate_tab(i) := l_rec_rate;
          BEGIN
            SELECT TAX_RATE_ID INTO l_tax_rate_id
            FROM ZX_RATES_B
            WHERE NVL(source_id,tax_rate_id) = pg_tax_code_id_tab(i)
            AND record_type_code='MIGRATED';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

            IF (pg_tax_code_id_tab(i) <> l_tax_rate_id) and l_tax_rate_id is NOT NULL THEN
              pg_tax_code_id_tab(i) := l_tax_rate_id;
            END IF;
        END LOOP;

        insert_rec_info;
        COMMIT;
      ELSE
        CLOSE pod_rec_rate_release;
        EXIT;
      END IF;

      IF pod_rec_rate_po%NOTFOUND THEN
        CLOSE pod_rec_rate_release;
        EXIT;
      END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF pod_rec_rate_po%ISOPEN THEN
     CLOSE pod_rec_rate_po;
    END IF;

    IF pod_rec_rate_release%ISOPEN THEN
     CLOSE pod_rec_rate_release;
    END IF;
    RAISE;

END get_rec_info;

PROCEDURE get_rec_info(
  x_return_status        OUT NOCOPY  VARCHAR2) AS

CURSOR pod_rec_rate IS
 SELECT /*+ ORDERED NO_EXPAND use_nl(pod,poll,pol, atc,atg, atc1, pov)
            INDEX (fsp financials_system_params_u1) INDEX (lgr gl_ledgers_u2)*/
       poh.po_header_id,
       pod.line_location_id,
       pod.po_distribution_id,
       NVL(atg.tax_code_id,atc.tax_id),
       poh.last_update_date,
       pod.code_combination_id,
       poh.vendor_id,
       pod.tax_recovery_override_flag,
       pod.recovery_rate,
       poh.vendor_site_id,
       pol.item_id,
       fsp.inventory_organization_id,
       lgr.chart_of_accounts_id,
       atc1.tax_recovery_rule_id,
       atc1.tax_recovery_rate,
       pov.vendor_type_lookup_code
  FROM (select distinct other_doc_application_id, other_doc_trx_id
          from ZX_VALIDATION_ERRORS_GT
         where other_doc_application_id = 201
           and other_doc_entity_code = 'PURCHASE_ORDER'
           and other_doc_event_class_code = 'PO_PA'
       ) zxvalerr,
       po_headers_all poh,
       po_distributions_all pod,
       po_line_locations_all poll,
       po_lines_all pol,
       ap_tax_codes_all atc,
       ar_tax_group_codes_all atg,
       ap_tax_codes_all atc1,
       po_vendors pov,
       financials_system_params_all fsp,
       gl_ledgers lgr
 WHERE poh.po_header_id = zxvalerr.other_doc_trx_id
   AND pod.po_header_id = poh.po_header_id
   AND pod.recovery_rate IS NULL
   AND poll.po_header_id = pod.po_header_id
   AND poll.po_line_id = pod.po_line_id
   AND poll.line_location_id = pod.line_location_id
   AND pol.po_header_id = poll.po_header_id
   AND pol.po_line_id = poll.po_line_id
   AND nvl(atc.org_id,-99)=nvl(poh.org_id,-99)
   AND poll.tax_code_id = atc.tax_id
   AND poll.tax_code_id = atg.tax_group_id
   AND atc.tax_type = 'TAX_GROUP'
   AND atc1.tax_id = atg.tax_code_id
   AND atc1.enabled_flag = 'Y'
   AND pov.vendor_id = poh.vendor_id
   AND NVL(fsp.org_id, -99) = NVL(poh.org_id, -99)
   AND lgr.ledger_id = fsp.set_of_books_id
UNION
 SELECT /*+ ORDERED NO_EXPAND use_nl(pod, poh, pol, atc,atg, atc1, pov)
            INDEX (fsp financials_system_params_u1) INDEX (lgr gl_ledgers_u2)*/
       poll.po_release_id,
       pod.line_location_id,
       pod.po_distribution_id,
       NVL(atg.tax_code_id,atc.tax_id),
       poh.last_update_date,
       pod.code_combination_id,
       poh.vendor_id,
       pod.tax_recovery_override_flag,
       pod.recovery_rate,
       poh.vendor_site_id,
       pol.item_id,
       fsp.inventory_organization_id,
       lgr.chart_of_accounts_id,
       atc1.tax_recovery_rule_id,
       atc1.tax_recovery_rate,
       pov.vendor_type_lookup_code
  FROM (select distinct other_doc_application_id, other_doc_trx_id
          from ZX_VALIDATION_ERRORS_GT
       	 where other_doc_application_id = 201
       	   and other_doc_entity_code = 'RELEASE'
           and other_doc_event_class_code = 'RELEASE'
       ) zxvalerr,
       po_line_locations_all poll,
       po_headers_all poh,
       po_distributions_all pod,
       po_lines_all pol,
       ap_tax_codes_all atc,
       ar_tax_group_codes_all atg,
       ap_tax_codes_all atc1,
       po_vendors pov,
       financials_system_params_all fsp,
       gl_ledgers lgr
 WHERE poll.po_release_id = zxvalerr.other_doc_trx_id
   AND pod.po_header_id = poll.po_header_id
   AND pod.po_line_id = poll.po_line_id
   AND pod.line_location_id = poll.line_location_id
   AND pod.recovery_rate IS NULL
   AND poh.po_header_id = poll.po_header_id
   AND pol.po_header_id = poll.po_header_id
   AND pol.po_line_id = poll.po_line_id
   AND nvl(atc.org_id,-99)=nvl(poh.org_id,-99)
   AND poll.tax_code_id = atc.tax_id
   AND poll.tax_code_id = atg.tax_group_id
   AND atc.tax_type = 'TAX_GROUP'
   AND atc1.tax_id = atg.tax_code_id
   AND atc1.enabled_flag = 'Y'
   AND pov.vendor_id = poh.vendor_id
   AND NVL(fsp.org_id, -99) = NVL(poh.org_id, -99)
   AND lgr.ledger_id = fsp.set_of_books_id;

 l_count	NUMBER;
 l_tax_rate_id NUMBER;

BEGIN

  -- calculate recovery rate for Purchase Order
  --
  OPEN pod_rec_rate;
  LOOP
    FETCH pod_rec_rate BULK COLLECT INTO
          pg_po_header_id_tab,
          pg_po_line_id_tab,
          pg_po_dist_id_tab,
          pg_tax_code_id_tab,
          pg_trx_date_tab,
          pg_code_combination_id_tab,
          pg_vendor_id_tab,
          pg_tax_rec_override_flag_tab,
          pg_tax_recovery_rate_tab,
          pg_vendor_site_id_tab,
          pg_item_id_tab,
          pg_inv_org_id_tab,
          pg_chart_of_accounts_id_tab,
          pg_tc_tax_recovery_rule_id_tab,
          pg_tc_tax_recovery_rate_tab,
          pg_vendor_type_lookup_code_tab
    LIMIT C_LINES_PER_INSERT;

    l_count := pg_tax_code_id_tab.COUNT;
    IF l_count > 0 THEN
      FOR i IN 1 .. l_count LOOP
        ZX_TAX_RECOVERY_PKG.get_default_rate(
                  p_tax_code                  => NULL,
                  p_tax_id                    => PG_TAX_CODE_ID_TAB(i),
                  p_tax_date                  => PG_TRX_DATE_TAB(i),
                  p_code_combination_id       => PG_CODE_COMBINATION_ID_TAB(i),
                  p_vendor_id                 => PG_VENDOR_ID_TAB(i),
                  p_distribution_id           => null,
                  p_tax_user_override_flag    => PG_TAX_REC_OVERRIDE_FLAG_TAB(i),
                  p_user_tax_recovery_rate    => PG_TAX_RECOVERY_RATE_TAB(i),
                  p_concatenated_segments     => '',
                  p_vendor_site_id            => PG_VENDOR_SITE_ID_TAB(i),
                  p_inventory_item_id         => PG_ITEM_ID_TAB(i),
                  p_item_org_id               => PG_ITEM_ID_TAB(i),
                  APPL_SHORT_NAME             => 'PO',
                  FUNC_SHORT_NAME             => '',
                  p_calling_sequence          => 'PO_MIG',
                  p_chart_of_accounts_id      => pg_chart_of_accounts_id_tab(i),
                  p_tc_tax_recovery_rule_id   => pg_tc_tax_recovery_rule_id_tab(i),
                  p_tc_tax_recovery_rate      => pg_tc_tax_recovery_rate_tab(i),
                  p_vendor_type_lookup_code   => pg_vendor_type_lookup_code_tab(i),
                  p_tax_recovery_rate         => l_rec_rate );

        pg_get_tax_recovery_rate_tab(i) := l_rec_rate;
        BEGIN
            SELECT TAX_RATE_ID INTO l_tax_rate_id
            FROM ZX_RATES_B
            WHERE NVL(source_id,tax_rate_id) = pg_tax_code_id_tab(i)
	    AND record_type_code='MIGRATED';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

            IF (pg_tax_code_id_tab(i) <> l_tax_rate_id) and l_tax_rate_id is NOT NULL THEN
              pg_tax_code_id_tab(i) := l_tax_rate_id;
            END IF;

      END LOOP;

      insert_rec_info;
      -- COMMIT;
    ELSE
      CLOSE pod_rec_rate;
      EXIT;
    END IF;

    IF pod_rec_rate%NOTFOUND THEN
      CLOSE pod_rec_rate;
      EXIT;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF pod_rec_rate%ISOPEN THEN
     CLOSE pod_rec_rate;
    END IF;
    RAISE;

END get_rec_info;

end ZX_PO_REC_PKG;

/
