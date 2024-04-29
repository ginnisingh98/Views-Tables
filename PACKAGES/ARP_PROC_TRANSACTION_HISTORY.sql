--------------------------------------------------------
--  DDL for Package ARP_PROC_TRANSACTION_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROC_TRANSACTION_HISTORY" AUTHID CURRENT_USER AS
/* $Header: ARTETRHS.pls 120.2 2005/08/10 23:14:41 hyu ship $ */

  SUBTYPE r_sob_list_type      IS gl_mc_info.r_sob_list;
  SUBTYPE r_sob_list_rec_type  IS gl_mc_info.r_sob_rec;

PROCEDURE insert_transaction_history(p_trh_rec                IN  OUT NOCOPY ar_transaction_history%rowtype,
                                     p_transaction_history_id OUT NOCOPY     ar_transaction_history.transaction_history_id%type,
                                     p_move_deferred_tax      IN      VARCHAR2 DEFAULT 'N');

PROCEDURE update_transaction_history(p_trh_rec                IN  OUT NOCOPY ar_transaction_history%rowtype,
                                     p_transaction_history_id IN      ar_transaction_history.transaction_history_id%type);

PROCEDURE delete_transaction_history(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%type);

PROCEDURE delete_transaction_hist_dist(p_transaction_history_id IN ar_transaction_history.transaction_history_id%TYPE);

procedure create_trh_for_receipt_act(p_old_ps_rec   IN ar_payment_schedules%ROWTYPE,
                                     p_app_rec      IN ar_receivable_applications%ROWTYPE,
                                     p_called_from  IN VARCHAR2);


END ARP_PROC_TRANSACTION_HISTORY;

 

/
