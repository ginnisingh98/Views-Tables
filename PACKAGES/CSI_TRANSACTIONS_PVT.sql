--------------------------------------------------------
--  DDL for Package CSI_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtrxs.pls 115.14 2003/09/04 23:58:35 sguthiva ship $ */
  -- start OF comments
  -- package name     : csi_transactions_pvt
  -- purpose          :
  -- history          :
  -- note             :
  -- end OF comments

  -- default NUMBER OF records fetch per call
  g_default_num_rec_fetch     NUMBER := 30;
  g_trans_date                DATE   :=sysdate;


  TYPE util_order_by_rec_type IS RECORD (
    col_choice NUMBER        := fnd_api.g_miss_num,
    col_name   VARCHAR2(30)  := fnd_api.g_miss_char);

  g_miss_util_order_by_rec    util_order_by_rec_type;

  TYPE util_order_by_tbl_type IS TABLE OF util_order_by_rec_type
    INDEX BY BINARY_INTEGER;


  PROCEDURE get_transactions(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_commit                     IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level           IN   NUMBER   := fnd_api.g_valid_level_full,
    p_txnfind_rec                IN   csi_datastructures_pub.transaction_query_rec ,
    p_rec_requested              IN   NUMBER   := g_default_num_rec_fetch,
    p_start_rec_prt              IN   NUMBER   := 1,
    p_return_tot_count           IN   VARCHAR2 := fnd_api.g_false,
    p_order_by_rec               IN   csi_datastructures_pub.transaction_sort_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_transaction_tbl            OUT NOCOPY  csi_datastructures_pub.transaction_header_tbl,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER);



/* ---------------------------------------------------------------------------------- */
/* ---  this PROCEDURE IS used to accept AND validate parameters                  --- */
/* ---  before inserting INTO csi_transactions table.                             --- */
/* ---------------------------------------------------------------------------------- */

  PROCEDURE create_transaction(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_commit                     IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level           IN   NUMBER   := fnd_api.g_valid_level_full,
    p_success_if_exists_flag     IN   VARCHAR2 := 'N',
    p_transaction_rec            IN  OUT NOCOPY csi_datastructures_pub.transaction_rec ,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2);


/* ---------------------------------------------------------------------------------- */
/* ---  this PROCEDURE IS used to accept AND validate parameters                  --- */
/* ---  before updating  INTO csi_transactions table.                             --- */
/* ---------------------------------------------------------------------------------- */

  PROCEDURE update_transactions(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_commit                     IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level           IN   NUMBER   := fnd_api.g_valid_level_full,
    p_transaction_rec            IN   csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2);

/* ---------------------------------------------------------------------------------- */
/* ---  this PROCEDURE IS used to insert INTO csi_txn_errors table.               --- */
/* ---------------------------------------------------------------------------------- */


  PROCEDURE create_txn_error(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_commit                     IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level           IN   NUMBER   := fnd_api.g_valid_level_full,
    p_txn_error_rec              IN   csi_datastructures_pub.transaction_error_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_transaction_error_id       OUT NOCOPY  NUMBER);

END csi_transactions_pvt;

 

/
