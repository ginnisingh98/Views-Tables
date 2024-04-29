--------------------------------------------------------
--  DDL for Package CSTPAPPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPAPPR" AUTHID CURRENT_USER AS
/* $Header: CSTAPPRS.pls 120.2.12010000.2 2008/11/10 13:11:08 anjha ship $ */

PROCEDURE create_acct_lines (
        i_legal_entity          in      number,
        i_cost_type_id          in      number,
        i_cost_group_id         in      number,
        i_period_id             in      number,
        i_transaction_id        in      number,
        i_event_type_id         in      varchar2,
	i_txn_type_flag         IN      VARCHAR2, --Bug 4586534
	o_err_num		out NOCOPY	number,
	o_err_code		out NOCOPY	varchar2,
	o_err_msg		out NOCOPY	varchar2
);


procedure create_rcv_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) ;

procedure create_adj_ae_lines(
  p_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  x_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  x_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) ;

PROCEDURE create_rae_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
);
PROCEDURE create_lc_adj_ae_lines(
  p_ae_txn_rec            IN         CSTPALTY.cst_ae_txn_rec_type,
  x_ae_line_rec_tbl       OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
  x_ae_err_rec            OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
);
procedure create_per_end_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) ;

PROCEDURE check_encumbrance(
i_transaction_id        IN      NUMBER,
i_set_of_books_id       IN      NUMBER,
i_period_name           IN      VARCHAR2,   --???
i_encumbrance_account_id        IN      NUMBER,
o_enc_flag              OUT NOCOPY     VARCHAR2,
o_purch_encumbrance_type_id     OUT NOCOPY     NUMBER,
o_purch_encumbrance_flag OUT NOCOPY     VARCHAR2,
o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
);


PROCEDURE insert_account(
  i_ae_txn_rec          IN    	CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec         IN    	CSTPALTY.cst_ae_curr_rec_type,
  i_dr_flag             IN    	BOOLEAN,
  i_ae_line_rec         IN    	CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY   	CSTPALTY.cst_ae_err_rec_type
);

FUNCTION get_net_del_qty(
        i_po_distribution_id    IN      NUMBER,
        i_transaction_id        IN      NUMBER)
RETURN NUMBER ;

procedure balance_account (
   l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
);

end CSTPAPPR;

/
