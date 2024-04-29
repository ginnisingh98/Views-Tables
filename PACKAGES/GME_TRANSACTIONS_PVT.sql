--------------------------------------------------------
--  DDL for Package GME_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVPTXS.pls 120.13.12010000.4 2010/03/22 15:11:14 gmurator ship $ */
   /* Bug 5903208 Added PL/SQL table to store values */
   TYPE p_qty_rec IS RECORD (doc_qty NUMBER);
   TYPE p_qty_tab IS TABLE OF p_qty_rec INDEX BY VARCHAR2(100);
   p_qty_tbl p_qty_tab;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   create_material_txn
   |
   | USAGE
   |    Inserts the transaction to interface table and moves to temp when
   |    called from forms.
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_mmli_tbl -- table of mtl_transaction_lots_inumber_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE create_material_txn (
      p_mmti_rec        IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl        IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_phantom_trans   IN              NUMBER DEFAULT 0
     ,x_return_status   OUT NOCOPY      VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   update_material_txn
   |
   | USAGE
   |    update the transaction in interface table - it deletes all transactions
   |    of transaction_id passed. Creates new transactions as passed.
   |
   | ARGUMENTS
   |   p_transaction_id - transaction_id from mmt for deletion
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_mmli_tbl -- table of mtl_transaction_lots_inumber_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE update_material_txn (
      p_transaction_id   IN              NUMBER
     ,p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl         IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   update_material_txn
   |
   | USAGE
   |    update the transaction in interface table - it deletes all transactions
   |    by getting transaction_id from the mmt record passed. Creates new transactions
   |    in interface by converting the mmt to mmti.
   |
   | ARGUMENTS
   |   p_mmt_rec -- mtl_material_transaction rowtype
   |   p_mmln_tbl -- table of mtl_transaction_lots_inumber_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE update_material_txn (
      p_mmt_rec         IN              mtl_material_transactions%ROWTYPE
     ,p_mmln_tbl        IN              gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   delete_material_txn
   |
   | USAGE
   |    delete all transactions of transaction_id passed by creating reverse transaction.
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for deletion
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   |   A. Mishra       21-Sep-2009   Bug 8605909
   |      Added p_trans_date parameter.
   +==========================================================================+ */
   PROCEDURE delete_material_txn (
      p_transaction_id   IN              NUMBER
     ,p_txns_pair        IN              NUMBER DEFAULT NULL
     ,p_trans_date       IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   build_txn_inter
   |
   | USAGE
   |    Inserts the transaction to interface table
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_mmli_tbl -- table of mtl_trans_lots_inter_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE build_txn_inter (
      p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl         IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_assign_phantom   IN              NUMBER DEFAULT 0
     ,x_mmti_rec         OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_mmli_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   build_txn_inter
   |
   | USAGE
   |    Inserts the transaction to interface table
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
  /* Bug 4929610 Added new parameter */
   PROCEDURE build_txn_inter_hdr (
      p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_assign_phantom   IN              NUMBER DEFAULT 0
     ,x_mmti_rec         OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,p_insert_hdr       IN              BOOLEAN DEFAULT TRUE);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   build_txn_inter_hdr
   |
   | USAGE
   |    Inserts the transaction to interface table
   |
   | ARGUMENTS
   |  p_mmli_rec -- record of mtl_transaction_lots_interface as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |   Back Port Bug 6925025 11-Apr-2008 Srinivasulu Puri
   |    Added parameters subinventory_code and locator_id.
   |
   +==========================================================================+ */
   PROCEDURE build_txn_inter_lot (
      p_trans_inter_id        IN              NUMBER
     ,p_transaction_type_id   IN              NUMBER
     ,p_inventory_item_id     IN              NUMBER
     ,p_subinventory_code     IN              VARCHAR2
     ,p_locator_id            IN              NUMBER
     ,p_mmli_rec              IN              mtl_transaction_lots_interface%ROWTYPE
     ,x_mmli_rec              OUT NOCOPY      mtl_transaction_lots_interface%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   get_transactions
   |
   | USAGE
   |    Gets all transactions from mmt based on transaction_id passed.
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for fetch
   |
   | RETURNS
   |
   |   returns via x_status OUT parameters
   |   x_mmt_rec -- mtl_transaction_interface rowtype
   |   x_mmln_tbl -- table of mtl_trans_lots_number_tbl
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE get_transactions (
      p_transaction_id   IN              NUMBER
     ,x_mmt_rec          OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   construct_mmti
   |
   | USAGE
   |    Construct interface table record based on mmt passed to it.
   |
   | ARGUMENTS
   |   p_mmt_rec -- mtl_material_transaction rowtype
   |   p_mmln_tbl -- table of mtl_trans_lots_num_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |               x_mmti_rec mtl_transactions_interface rowtype
   |               x_mmli_tbl table of mtl_trans_lots_inter_tbl
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE construct_mmti (
      p_mmt_rec         IN              mtl_material_transactions%ROWTYPE
     ,p_mmln_tbl        IN              gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_mmti_rec        OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_mmli_tbl        OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_mat_trans
   |
   | USAGE
   |    Gets all transactions from mmt based on material_detail_id and batch_id passed.
   |
   | ARGUMENTS
   |   p_mat_det_id -- material_detail_id passed of material
   |   p_batch_id -- batch_id to which the material belongs.
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |               x_mmt_tbl- gives back all transactions of the material
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   |
   |  G. Muratore     19-MAR-2010   Bug 8751983
   |     Added p_order_by parameter to allow fetching of transactions in reverse trans order.
   +==========================================================================+ */
   PROCEDURE get_mat_trans (
      p_mat_det_id      IN              NUMBER
     ,p_batch_id        IN              NUMBER
     ,p_phantom_line_id IN              NUMBER DEFAULT NULL
     ,p_order_by        IN              NUMBER DEFAULT 1
     ,x_mmt_tbl         OUT NOCOPY      gme_common_pvt.mtl_mat_tran_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   get_lot_trans
   |
   | USAGE
   |    Gets all lot transactions from mmln for a given transaction_id.
   |
   | ARGUMENTS
   |   p_transaction_id --  transaction_id for which all lot info is required.
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |                x_mmln_tbl- all lot info for a given transaction_id.
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE get_lot_trans (
      p_transaction_id   IN              NUMBER
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2);

/* +==========================================================================+
| PROCEDURE NAME
|   GME_PRE_PROCESS
|
| USAGE
|    Gets all pre-process validations based on header_id
|
| ARGUMENTS
|   p_transaction_hdr_id
|
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|
+==========================================================================+ */
   PROCEDURE gme_pre_process (
      p_transaction_hdr_id   IN              NUMBER
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_returnable_qty
   |
   | USAGE
   |    Gets net quantity that can be returned from mmt based on the details passed
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_lot_number - Lot number
   |   p_lot_control - 1 for plain 2 for lot control
   | RETURNS
   |   x_return_status S for success, U for unexpected
   |   x_available_qty  Quantity that can be returned.
   | HISTORY
   |   Created  20-Sep-05 Shrikant Nene
   |
   +==========================================================================+ */
   PROCEDURE get_returnable_qty (
      p_mmti_rec                IN          mtl_transactions_interface%ROWTYPE,
      p_lot_number              IN          VARCHAR2,
      p_lot_control             IN          NUMBER,
      x_available_qty           OUT NOCOPY  NUMBER,
      x_return_status           OUT NOCOPY  VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   PRE_PROCESS_VAL
   |
   | USAGE
   |    validations for individual transactions
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE pre_process_val (
      p_transaction_interface_id   IN              NUMBER
     ,x_return_status              OUT NOCOPY      VARCHAR2);

/* +==========================================================================+
| PROCEDURE NAME
|   gme_txn_message
|
| USAGE
|    validations for individual transactions
|
| ARGUMENTS
|   p_mmti_rec -- mtl_transaction_interface rowtype
|
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|
+==========================================================================+ */
   PROCEDURE gme_txn_message (
      p_api_name                   IN              VARCHAR2
     ,p_transaction_interface_id   IN              VARCHAR2);

    /* +==========================================================================+
   | PROCEDURE NAME
   |   gme_post_process
   |
   | USAGE
   |
   |
   | ARGUMENTS
   |   p_transaction_id
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE gme_post_process (
      p_transaction_id   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2);

/* +==========================================================================+
| PROCEDURE NAME
|    purge_trans_pairs
|
| USAGE
|
|
| ARGUMENTS
|   p_batch_id
|   p_material_detail_id
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|
+==========================================================================+ */
   PROCEDURE purge_trans_pairs (
      p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   /* +==========================================================================+
     | PROCEDURE NAME
     |   Process_transactions
     |
     | USAGE
     |   This is the interface procedure to the Inventory Transaction
     |   Manager to validate and process a batch of material transaction
     |   interface records
     |
     | ARGUMENTS
     |   p_api_version API Version of this procedure. Current version is 1.0
     |   p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not                  |
     |   p_commit Indicates whether to commit the changes after successful processing
     |   p_validation_level Indicates whether or not to perform a full validation
     |   x_return_status Returns the status to indicate success or failure of execution
     |   x_msg_count Returns number of error message in the error message stack in case of failure
     |   x_msg_data Returns the error message in case of failure
     |   x_trans_count The count of material transaction interface records processed.
     |   p_table Source of transaction records with value 1 of material transaction interface table and value 2 of material transaction temp table
     |   p_header_id Transaction header id (If not passed in then call gme_common_pvt.get_txn_header_id to populate
     |
     | RETURNS
     |   returns via x_ OUT parameters
     |
     | HISTORY
     |   Created  07-Mar-05 Jalaj Srivastava
     |
     +==========================================================================+ */
   /* Bug 5255959 added p_clear_qty_cache parameter */
   PROCEDURE process_transactions (
      p_api_version        IN              NUMBER := 1
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full
     ,p_table              IN              NUMBER := 2
     ,p_header_id          IN              NUMBER
            := gme_common_pvt.get_txn_header_id
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_trans_count        OUT NOCOPY      NUMBER
     --Bug#5584699 Changed the datatype from boolean to varchar2.
     ,p_clear_qty_cache    IN              VARCHAR2 := fnd_api.g_true);
     --,p_clear_qty_cache    IN              BOOLEAN DEFAULT TRUE);

   /* +==========================================================================+
      | PROCEDURE NAME
      |   query_quantities
      |
      | USAGE
      |    Query quantities at a level specified by the input
      |
      | ARGUMENTS
      |   p_api_version API Version of this procedure. Current version is 1.0
      |   p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not                  |
      |   x_return_status Returns the status to indicate success or failure of execution
      |   x_msg_count Returns number of error message in the error message stack in case of failure
      |   x_msg_data Returns the error message in case of failure
      |
      | RETURNS
      |   returns via x_ OUT parameters
      |
      | HISTORY
      |   Created  07-Mar-05 Jalaj Srivastava
      |
      +==========================================================================+ */
   PROCEDURE query_quantities (
      p_api_version_number           IN              NUMBER := 1
     ,p_init_msg_lst                 IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,x_msg_count                    OUT NOCOPY      NUMBER
     ,x_msg_data                     OUT NOCOPY      VARCHAR2
     ,p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER
     ,p_tree_mode                    IN              INTEGER
     ,p_is_serial_control            IN              BOOLEAN DEFAULT FALSE
     ,p_grade_code                   IN              VARCHAR2
     ,p_demand_source_type_id        IN              NUMBER
            DEFAULT gme_common_pvt.g_txn_source_type
     ,p_demand_source_header_id      IN              NUMBER DEFAULT -9999
     ,p_demand_source_line_id        IN              NUMBER DEFAULT -9999
     ,p_demand_source_name           IN              VARCHAR2 DEFAULT NULL
     ,p_lot_expiration_date          IN              DATE DEFAULT NULL
     ,p_revision                     IN              VARCHAR2
     ,p_lot_number                   IN              VARCHAR2
     ,p_subinventory_code            IN              VARCHAR2
     ,p_locator_id                   IN              NUMBER
     ,p_onhand_source                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_all_subs
     ,x_qoh                          OUT NOCOPY      NUMBER
     ,x_rqoh                         OUT NOCOPY      NUMBER
     ,x_qr                           OUT NOCOPY      NUMBER
     ,x_qs                           OUT NOCOPY      NUMBER
     ,x_att                          OUT NOCOPY      NUMBER
     ,x_atr                          OUT NOCOPY      NUMBER
     ,x_sqoh                         OUT NOCOPY      NUMBER
     ,x_srqoh                        OUT NOCOPY      NUMBER
     ,x_sqr                          OUT NOCOPY      NUMBER
     ,x_sqs                          OUT NOCOPY      NUMBER
     ,x_satt                         OUT NOCOPY      NUMBER
     ,x_satr                         OUT NOCOPY      NUMBER
     ,p_transfer_subinventory_code   IN              VARCHAR2 DEFAULT NULL
     ,p_cost_group_id                IN              NUMBER DEFAULT NULL
     ,p_lpn_id                       IN              NUMBER DEFAULT NULL
     ,p_transfer_locator_id          IN              NUMBER DEFAULT NULL);

   /* +==========================================================================+
            | PROCEDURE NAME
            |   update_quantities
            |
            | USAGE
            |    Update quantity at the level specified by the input and
            |    return the quantities at the level after the update
            |
            | ARGUMENTS
            |   p_api_version API Version of this procedure. Current version is 1.0
            |   p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not                  |
            |   x_return_status Returns the status to indicate success or failure of execution
            |   x_msg_count Returns number of error message in the error message stack in case of failure
            |   x_msg_data Returns the error message in case of failure
            |
            | RETURNS
            |   returns via x_ OUT parameters
            |
            | HISTORY
            |   Created  07-Mar-05 Jalaj Srivastava
            |
            +==========================================================================+ */
   PROCEDURE update_quantities (
      p_api_version_number           IN              NUMBER := 1
     ,p_init_msg_lst                 IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,x_msg_count                    OUT NOCOPY      NUMBER
     ,x_msg_data                     OUT NOCOPY      VARCHAR2
     ,p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER
     ,p_tree_mode                    IN              INTEGER
     ,p_is_serial_control            IN              BOOLEAN := FALSE
     ,p_demand_source_type_id        IN              NUMBER
            DEFAULT gme_common_pvt.g_txn_source_type
     ,p_demand_source_header_id      IN              NUMBER DEFAULT -9999
     ,p_demand_source_line_id        IN              NUMBER DEFAULT -9999
     ,p_demand_source_name           IN              VARCHAR2 DEFAULT NULL
     ,p_lot_expiration_date          IN              DATE DEFAULT NULL
     ,p_revision                     IN              VARCHAR2 DEFAULT NULL
     ,p_lot_number                   IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory_code            IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id                   IN              NUMBER DEFAULT NULL
     ,p_grade_code                   IN              VARCHAR2 DEFAULT NULL
     ,p_primary_quantity             IN              NUMBER
     ,p_quantity_type                IN              INTEGER
     ,p_secondary_quantity           IN              NUMBER
     ,p_onhand_source                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_all_subs
     ,x_qoh                          OUT NOCOPY      NUMBER
     ,x_rqoh                         OUT NOCOPY      NUMBER
     ,x_qr                           OUT NOCOPY      NUMBER
     ,x_qs                           OUT NOCOPY      NUMBER
     ,x_att                          OUT NOCOPY      NUMBER
     ,x_atr                          OUT NOCOPY      NUMBER
     ,x_sqoh                         OUT NOCOPY      NUMBER
     ,x_srqoh                        OUT NOCOPY      NUMBER
     ,x_sqr                          OUT NOCOPY      NUMBER
     ,x_sqs                          OUT NOCOPY      NUMBER
     ,x_satt                         OUT NOCOPY      NUMBER
     ,x_satr                         OUT NOCOPY      NUMBER
     ,p_transfer_subinventory_code   IN              VARCHAR2 DEFAULT NULL
     ,p_cost_group_id                IN              NUMBER DEFAULT NULL
     ,p_containerized                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_containerized_false
     ,p_lpn_id                       IN              NUMBER DEFAULT NULL
     ,p_transfer_locator_id          IN              NUMBER DEFAULT NULL);

  /* Bug 4929610 Added function */
  FUNCTION is_lot_expired (p_organization_id   IN NUMBER,
                           p_inventory_item_id IN NUMBER,
                           p_lot_number        IN VARCHAR2,
                           p_date              IN DATE) RETURN BOOLEAN;
  PROCEDURE insert_txn_inter_hdr(p_mmti_rec      IN  mtl_transactions_interface%ROWTYPE,
                                 x_return_status OUT NOCOPY VARCHAR2);
-- nsinghi Bug5176319. Added the proc.
   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_mmt_transactions
   |
   | USAGE
   |    Gets all transactions from mmt based on transaction_id passed. Unlike get_transactions,
   |    this procedure does not check for enteries in gme_transaction_pairs
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for fetch
   |
   | RETURNS
   |
   |   returns via x_status OUT parameters
   |   x_mmt_rec -- mtl_material_transactions rowtype
   |   x_mmln_tbl -- table of mtl_trans_lots_number_tbl
   | HISTORY
   |   Created  19-Jun-06 Namit S. Created
   |
   +==========================================================================+ */

  PROCEDURE get_mmt_transactions (
      p_transaction_id   IN              NUMBER
     ,x_mmt_rec          OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2);

  /* Bug 5358129 Added procedure */
  PROCEDURE validate_lot_for_ing(p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_lot_number        IN VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2);
  /* Added for bug 5597385 */
  PROCEDURE gmo_pre_process_val(p_mmti_rec      IN  mtl_transactions_interface%ROWTYPE,
                                p_mmli_tbl      IN  gme_common_pvt.mtl_trans_lots_inter_tbl,
                                p_mode          IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2);
END gme_transactions_pvt;


/
