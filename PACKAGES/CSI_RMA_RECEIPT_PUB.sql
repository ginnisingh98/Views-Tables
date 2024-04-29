--------------------------------------------------------
--  DDL for Package CSI_RMA_RECEIPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_RMA_RECEIPT_PUB" AUTHID CURRENT_USER AS
/* $Header: csipirms.pls 120.1.12000000.1 2007/01/16 15:35:07 appldev ship $*/

  g_pkg_name       varchar2(30) := 'csi_rma_receipt_pub';
  g_user_id        number       := fnd_global.user_id;
  g_login_id       number       := fnd_global.login_id;
  g_sysdate        date         := sysdate;

  /* ---------------------------------------------------------------------- */
  /* Record definition to hold the inventory material transaction info      */
  /* get_mtl_txn_rec routine populates this data structure                  */
  /* ---------------------------------------------------------------------- */

  TYPE mtl_txn_rec IS RECORD (
    transaction_id            number       := fnd_api.g_miss_num,
    oe_line_id                number       := fnd_api.g_miss_num,
    inventory_item_id         number       := fnd_api.g_miss_num,
    organization_id           number       := fnd_api.g_miss_num,
    revision                  varchar2(3)  := fnd_api.g_miss_char,
    subinventory_code         varchar2(10) := fnd_api.g_miss_char,
    locator_id                number       := fnd_api.g_miss_num,
    lot_number                varchar2(80) := fnd_api.g_miss_char,
    serial_number             varchar2(30) := fnd_api.g_miss_char,
    inv_location_id           number       := fnd_api.g_miss_num,
    primary_uom_code          varchar2(3)  := fnd_api.g_miss_char,
    mmt_primary_quantity      number       := fnd_api.g_miss_num,
    lot_primary_quantity      number       := fnd_api.g_miss_num,
    transaction_quantity      number       := fnd_api.g_miss_num,
    transaction_uom           varchar2(3)  := fnd_api.g_miss_char,
    transaction_date          date         := fnd_api.g_miss_date,
    last_updated_by           number       := fnd_api.g_miss_num,
    transaction_type_id       number       := fnd_api.g_miss_num,
    instance_id               number       := null,
    instance_quantity         number       := fnd_api.g_miss_num,
    original_order_line_id    number       := fnd_api.g_miss_num,
    customer_location_id      number       := fnd_api.g_miss_num,
    customer_account_id       number       := fnd_api.g_miss_num,
    party_id                  number       := fnd_api.g_miss_num,
    txn_line_detail_id        number       := fnd_api.g_miss_num,
    sub_type_id               number       := fnd_api.g_miss_num,
    verified_flag             varchar2(1)  := 'N',
    processed_flag            varchar2(1)  := 'N',
    mtl_txn_creation_date     date         := fnd_api.g_miss_date);--bug 4026148


  TYPE mtl_txn_tbl IS TABLE OF mtl_txn_rec INDEX BY BINARY_INTEGER;

  TYPE item_control_rec IS RECORD (
    inventory_item_id         number       := fnd_api.g_miss_num,
    organization_id           number       := fnd_api.g_miss_num,
    serial_control_code       number       := fnd_api.g_miss_num,
    lot_control_code          number       := fnd_api.g_miss_num,
    revision_control_code     number       := fnd_api.g_miss_num,
    locator_control_code      number       := fnd_api.g_miss_num,
    ib_trackable_flag         varchar2(1)  := fnd_api.g_miss_char,
    primary_uom_code          varchar2(3)  := fnd_api.g_miss_char,
    bom_item_type             number       := fnd_api.g_miss_num,
    model_item_id             number       := fnd_api.g_miss_num,
    pick_components_flag      varchar2(1)  := fnd_api.g_miss_char,
    mult_srl_control_flag     varchar2(1)  := fnd_api.g_miss_char);

  TYPE inst_pa_rec IS RECORD (
    instance_id               number       := fnd_api.g_miss_num,
    internal_party_id         number       := fnd_api.g_miss_num,
    src_txn_party_id          number       := fnd_api.g_miss_num,
    src_txn_acct_id           number       := fnd_api.g_miss_num,
    ownership_ovr_flag        varchar2(1)  := fnd_api.g_miss_char,
    instance_party_id         number       := fnd_api.g_miss_num,
    party_id                  number       := fnd_api.g_miss_num,
    pty_obj_version           number       := fnd_api.g_miss_num,
    party_rltnshp_code        varchar2(30) := fnd_api.g_miss_char,
    ip_account_id             number       := fnd_api.g_miss_num,
    account_id                number       := fnd_api.g_miss_num,
    acct_obj_version          number       := fnd_api.g_miss_num,
    acct_rltnshp_code         varchar2(30) := fnd_api.g_miss_char);

  TYPE tld_inst_rec IS RECORD (
    txn_line_detail_id        number       := fnd_api.g_miss_num,
    sub_type_id               number       := fnd_api.g_miss_num,
    inventory_item_id         number       := fnd_api.g_miss_num,
    lot_number                varchar2(80) := fnd_api.g_miss_char,
    serial_number             varchar2(30) := fnd_api.g_miss_char,
    quantity                  number       := fnd_api.g_miss_num,
    instance_id               number       := fnd_api.g_miss_num,
    verified_flag             varchar2(1)  := 'N',
    processed_flag            varchar2(1)  := 'N',
    mtl_txn_creation_date     date         := fnd_api.g_miss_date);--bug 4026148

  TYPE tld_inst_tbl IS TABLE OF tld_inst_rec INDEX BY BINARY_INTEGER;

  TYPE source_order_rec IS RECORD (
    transaction_id            number       := fnd_api.g_miss_num,
    rma_line_id               number       := fnd_api.g_miss_num,
    original_order_line_id    number       := fnd_api.g_miss_num,
    original_order_qty        number       := fnd_api.g_miss_num,
    customer_location_id      number       := fnd_api.g_miss_num,
    party_id                  number       := fnd_api.g_miss_num,
    customer_account_id       number       := fnd_api.g_miss_num);

  TYPE mtl_trx_type IS RECORD(
    transaction_id            number,
    transaction_date          date,
    transaction_type_id       number,
    source_line_id            number,
    source_line_ref           varchar2(30),
    source_header_id          number,
    source_header_ref         varchar2(30));

  PROCEDURE get_rma_info(
    p_transaction_id     IN  number,
    x_mtl_trx_type       OUT NOCOPY mtl_trx_type,
    x_error_message      OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE get_sub_type_rec(
    p_transaction_type_id IN  number,
    p_sub_type_id         IN  number,
    x_sub_type_rec        OUT NOCOPY csi_txn_sub_types%rowtype,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE decode_message(
    p_msg_header          IN  xnp_message.msg_header_rec_type,
    p_msg_text            IN  varchar2,
    x_mtl_trx_rec         OUT NOCOPY mtl_trx_type,
    x_error_message       OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE rma_receipt(
    p_mtl_txn_id          IN  number,
    p_message_id          IN  number,
    x_return_status       OUT NOCOPY varchar2,
    px_trx_error_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

--  Moved the check and break routine to process txn pvt to avoid circular dependancy introduced in that routine for bug 2373109 and also to not load rma receipt for Non RMA txns . shegde. Bug 2443204
/*  Included this as part of fix for Bug : 2373109
    This procedure is called from different places

   PROCEDURE check_and_break_relation(
    p_instance_id         IN     number,
    p_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status       OUT NOCOPY    varchar2);
End Of Inclusion for Bug : 2373109
*/

END csi_rma_receipt_pub;

 

/
