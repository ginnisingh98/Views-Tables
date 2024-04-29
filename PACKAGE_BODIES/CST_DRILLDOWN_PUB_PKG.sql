--------------------------------------------------------
--  DDL for Package Body CST_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_DRILLDOWN_PUB_PKG" AS
/* $Header: CSTDRILB.pls 120.2.12010000.4 2010/04/13 16:37:08 mpuranik ship $ */

pg_FORM_USAGE_MODE	CONSTANT VARCHAR2(30) := 'SLA_DRILLDOWN';

PROCEDURE DRILLDOWN
(p_application_id IN INTEGER,
p_ledger_id IN INTEGER,
p_legal_entity_id IN INTEGER DEFAULT NULL,
p_entity_code IN VARCHAR2,
p_event_class_code IN VARCHAR2,
p_event_type_code IN VARCHAR2,
p_source_id_int_1 IN INTEGER DEFAULT NULL,
p_source_id_int_2 IN INTEGER DEFAULT NULL,
p_source_id_int_3 IN INTEGER DEFAULT NULL,
p_source_id_int_4 IN INTEGER DEFAULT NULL,
p_source_id_char_1 IN VARCHAR2 DEFAULT NULL,
p_source_id_char_2 IN VARCHAR2 DEFAULT NULL,
p_source_id_char_3 IN VARCHAR2 DEFAULT NULL,
p_source_id_char_4 IN VARCHAR2 DEFAULT NULL,
p_security_id_int_1 IN INTEGER DEFAULT NULL,
p_security_id_int_2 IN INTEGER DEFAULT NULL,
p_security_id_int_3 IN INTEGER DEFAULT NULL,
p_security_id_char_1 IN VARCHAR2 DEFAULT NULL,
p_security_id_char_2 IN VARCHAR2 DEFAULT NULL,
p_security_id_char_3 IN VARCHAR2 DEFAULT NULL,
p_valuation_method IN VARCHAR2 DEFAULT NULL,
p_user_interface_type IN OUT NOCOPY VARCHAR2,
p_function_name IN OUT NOCOPY VARCHAR2,
p_parameters IN OUT NOCOPY VARCHAR2)
IS

l_security_id_int_1 INTEGER;
l_lot_txn_id INTEGER;

BEGIN
    IF (p_application_id = 707) THEN
      IF (p_entity_code = 'MTL_ACCOUNTING_EVENTS') AND
         (p_event_class_code <> 'LOT') THEN
            p_user_interface_type := 'FORM';
            p_function_name := 'CST_INVTVTXN';

          IF (p_event_class_code = 'FOB_SHIP_RECIPIENT_SHIP') OR
             (p_event_class_code = 'FOB_RCPT_SENDER_RCPT') THEN
           SELECT organization_id
             INTO l_security_id_int_1
             FROM mtl_material_transactions
            WHERE transaction_id = p_source_id_int_1;
          ELSE
            l_security_id_int_1 := p_security_id_int_1;
          END IF;

            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
				||' INVTVTXN_GO_DETAIL="Y"'
				||' INVTVTXN_TRXN_ID="' || to_char(p_source_id_int_1)||'"'
				||' ORG_ID="'||to_char(l_security_id_int_1)||'"';
       ELSIF (p_entity_code = 'RCV_ACCOUNTING_EVENTS') AND
             (p_event_class_code NOT IN
	       ( 'PERIOD_END_ACCRUAL','RETR_PRICE_ADJ_RCV','RETR_PRICE_ADJ_DEL',
	         'LDD_COST_ADJ_RCV','LDD_COST_ADJ_DEL')
	      ) THEN
            p_user_interface_type := 'FORM';
            p_function_name := 'RCV_RCVRCVRC';
            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
				||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
				||' MO_ORG_ID="'||to_char(p_security_id_int_2)||'"'
				||' ORG_ID="'||to_char(p_source_id_int_3)||'"';
       ELSIF (p_entity_code = 'RCV_ACCOUNTING_EVENTS') AND
             (p_event_class_code IN
	       ( 'PERIOD_END_ACCRUAL','RETR_PRICE_ADJ_RCV','RETR_PRICE_ADJ_DEL',
	         'LDD_COST_ADJ_RCV','LDD_COST_ADJ_DEL')
	      ) THEN
         p_user_interface_type := 'FORM';
         p_function_name := 'CST_CSTFQRAE';
	 p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
				||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
				||' ACCOUNTING_EVENT_ID="'||to_char(p_source_id_int_2)||'"'
				||' ORG_ID="'||to_char(p_source_id_int_3)||'"';
        ELSIF (p_entity_code = 'WIP_ACCOUNTING_EVENTS') AND
              (p_event_class_code <> 'WIP_LOT') THEN
              /*Bug 9074297 - All wip journals should drill down to View Resource Transactions form
              (p_event_class_code NOT IN ('WIP_LOT', 'WIP_COST_UPD', 'VARIANCE')) AND
              (p_event_type_code <> 'EST_SCRAP_ABSORPTION') THEN */
            p_user_interface_type := 'FORM';
            p_function_name := 'WIP_WIPTQRSC';
            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
				||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
				||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
        ELSIF (p_event_class_code = 'WIP_LOT') THEN
            p_user_interface_type := 'FORM';
            p_function_name := 'WSM_WSMFJLTX';
            SELECT source_line_id
            INTO   l_lot_txn_id
            FROM   wip_transactions
            WHERE  transaction_id = p_source_id_int_1;
            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
                                ||' WLT_TXN_ID="' || to_char(l_lot_txn_id)||'"'
                                ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
        ELSIF (p_event_class_code = 'LOT') THEN
            p_user_interface_type := 'FORM';
            p_function_name := 'WSM_WSMFJLTX';
            SELECT source_line_id
            INTO   l_lot_txn_id
            FROM   mtl_material_transactions
            WHERE  transaction_id = p_source_id_int_1;
            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
                                ||' WLT_TXN_ID="' || to_char(l_lot_txn_id)||'"'
                                ||' ORG_ID="'||to_char(p_security_id_int_1)||'"';
        ELSIF (p_entity_code = 'WO_ACCOUNTING_EVENTS') THEN
            p_user_interface_type := 'FORM';
            p_function_name := 'CST_CSTACRVT';
            p_parameters := ' FORM_USAGE_MODE="'||pg_FORM_USAGE_MODE||'"'
				||' TRANSACTION_ID="' || to_char(p_source_id_int_1)||'"'
				||' ORG_ID="'||to_char(p_security_id_int_2)||'"';
        ELSE
            p_user_interface_type := 'NONE';
        END IF;
    END IF;
END DRILLDOWN;
END CST_DRILLDOWN_PUB_PKG;

/
