--------------------------------------------------------
--  DDL for Package INVTTMTX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVTTMTX" AUTHID CURRENT_USER as
/* $Header: INVTTMTS.pls 120.2 2006/05/03 22:14:19 ajohnson ship $ */

  G_TRANSACTION_PERIOD_ID 	NUMBER;
  G_ORG_ID			NUMBER;
  G_TRANSACTION_DATE		DATE;
  G_CURRENT_DATE		DATE;
  G_CURRENT_PERIOD_ID		NUMBER;
  G_PERIOD_STATUS               NUMBER := 0; -- ( 0 - CLOSED ; 1 - OPEN )

  PROCEDURE tdatechk(org_id               IN      INTEGER,
                     transaction_date     IN      DATE,
                     period_id            OUT     nocopy INTEGER,
                     open_past_period     IN OUT  nocopy BOOLEAN);

  FUNCTION ship_number_validation(shipment_number IN VARCHAR2) RETURN NUMBER;

  procedure post_query(
    p_org_id                in  number,
    p_inventory_item_id     in  number,
    p_subinv                in  varchar2,
    p_to_subinv             in  varchar2,
    p_reason_id             in  number,
    p_trx_type              in  varchar2,
    p_transaction_action_id in  number,
    p_from_uom              in  varchar2,
    p_to_uom                in  varchar2,
    p_sub_qty_tracked       out nocopy number,
    p_sub_asset_inv         out nocopy number,
    p_sub_locator_type      out nocopy number,
    p_sub_material_acct     out nocopy number,
    p_to_sub_qty_tracked    out nocopy number,
    p_to_sub_asset_inv      out nocopy number,
    p_to_sub_locator_type   out nocopy number,
    p_to_sub_material_acct  out nocopy number,
    p_reason_name           out nocopy varchar2,
    p_transaction_type      out nocopy varchar2,
    p_conversion_rate       out nocopy number);

Procedure RPC_FAILURE_ROLLBACK(trx_header_id number,
			       cleanup_success in out nocopy boolean);

Procedure lot_handling(hdr_id NUMBER,
		      lot_success IN OUT nocopy VARCHAR2);

END INVTTMTX;


 

/
