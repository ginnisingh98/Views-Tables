--------------------------------------------------------
--  DDL for Package CSTPAPBR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPAPBR" AUTHID CURRENT_USER AS
/* $Header: CSTAPBRS.pls 120.5.12010000.2 2008/10/29 23:16:41 vjavli ship $ */

PROCEDURE create_acct_lines (
        i_legal_entity          in      number,
        i_cost_type_id          in      number,
        i_cost_group_id         in      number,
        i_period_id             in      number,
        i_transaction_id        in      number,
        i_event_type_id         in      varchar2,
        i_txn_type_flag         IN      VARCHAR2, -- Bug 4586534
        o_err_num       out NOCOPY  number,
        o_err_code      out NOCOPY  varchar2,
        o_err_msg       out NOCOPY  varchar2
);


procedure create_inv_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) ;

procedure wip_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure sub_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure interorg_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure pcu_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure inv_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure cost_logical_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure cost_consigned_update_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) ;

procedure inventory_accounts(
  i_ae_txn_rec      IN      CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec     IN      CSTPALTY.cst_ae_curr_rec_type,
  i_exp_flag        IN      BOOLEAN,
  i_exp_account         IN      NUMBER,
  i_dr_flag         IN      BOOLEAN,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type,
  i_intransit_flag      IN NUMBER DEFAULT 0
) ;

procedure encumbrance_account(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
);
procedure offset_accounts(
   i_ae_txn_rec     IN      CSTPALTY.cst_ae_txn_rec_type,
   i_ae_curr_rec    IN      CSTPALTY.cst_ae_curr_rec_type,
   i_acct_line_type IN      NUMBER,
   i_elemental      IN      NUMBER,
   i_ovhd_absp      IN      NUMBER,
   i_dr_flag        IN      BOOLEAN,
   i_ae_acct_rec    IN      CSTPALTY.cst_ae_acct_rec_type,
   l_ae_line_tbl    IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec     OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
);

procedure ovhd_accounts(
  i_ae_txn_rec    IN     CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec   IN     CSTPALTY.cst_ae_curr_rec_type,
  i_dr_flag   IN     BOOLEAN,
  l_ae_line_tbl   IN OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec    OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
);

PROCEDURE insert_account(
  i_ae_txn_rec          IN      CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec         IN      CSTPALTY.cst_ae_curr_rec_type,
  i_dr_flag             IN      BOOLEAN,
  i_ae_line_rec         IN      CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
);

procedure balance_account (
   l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
);


procedure create_wip_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) ;

procedure get_accts(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_line_rec               IN        CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_acct_id1                  OUT NOCOPY       NUMBER,
  o_acct_id2                  OUT NOCOPY       NUMBER,
  o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
);

procedure WIP_accounts(
                       i_ae_txn_rec     IN            CSTPALTY.cst_ae_txn_rec_type,
                       i_ae_curr_rec    IN            CSTPALTY.cst_ae_curr_rec_type,
                       i_acct_line_type IN            NUMBER,
                       i_ovhd_absp      IN            NUMBER,
                       i_dr_flag        IN            BOOLEAN,
                       i_ae_acct_rec    IN            CSTPALTY.cst_ae_acct_rec_type,
                       l_ae_line_tbl    IN OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
                       o_ae_err_rec     OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type);

Function Get_Intercompany_account(
                       i_ae_txn_rec     IN            CSTPALTY.cst_ae_txn_rec_type,
                       o_ae_err_rec     OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type)
RETURN NUMBER;

PROCEDURE cost_internal_order_exp_txn(
  i_ae_txn_rec       IN             CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec      IN             CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl      IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec       OUT NOCOPY     CSTPALTY.cst_ae_err_rec_type
) ;

Procedure get_pacp_priorPrd_mta_cost (
  i_ae_txn_rec       IN             CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec      IN             CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl      IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec       OUT NOCOPY     CSTPALTY.cst_ae_err_rec_type,
  o_pacp_flag              OUT NOCOPY NUMBER,
  o_pacp_pwac_cost         OUT NOCOPY NUMBER,
  o_prev_period_flag       OUT NOCOPY NUMBER,
  o_prev_period_pwac_cost  OUT NOCOPY NUMBER,
  o_perp_ship_flag         OUT NOCOPY NUMBER,
  o_perp_ship_value        OUT NOCOPY NUMBER,
  o_txfr_credit            OUT NOCOPY NUMBER
) ;

PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
            p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            p_req_line_id     IN PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE,
            p_item_id         IN MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
            p_organization_id IN MTL_PARAMETERS.ORGANIZATION_ID%TYPE,
            p_primary_qty     IN MTL_MATERIAL_TRANSACTIONS.PRIMARY_QUANTITY%TYPE,
            p_total_primary_qty   IN NUMBER,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            o_ae_err_rec          OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
 ) ;

 PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
            p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            o_ae_err_rec          OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
 );

end CSTPAPBR;

/
