--------------------------------------------------------
--  DDL for Package GME_POST_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_POST_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMEVRCBS.pls 120.4 2006/10/27 17:20:39 creddy noship $ */

  TYPE subinv_rec IS RECORD (subinventory VARCHAR2(10), organization_id NUMBER);
  TYPE subinv_tab IS TABLE OF subinv_rec INDEX BY VARCHAR2(4);
  p_subinv_tbl    subinv_tab;
  TYPE subinv_loctype_rec IS RECORD (locator_type NUMBER);
  TYPE subinv_loctype_tab IS TABLE OF subinv_loctype_rec INDEX BY VARCHAR2(10);
  p_subinv_loctype_tbl    subinv_loctype_tab;
  TYPE locator_rec IS RECORD (locator_id NUMBER, organization_id NUMBER, subinventory VARCHAR2(10));
  TYPE locator_tab IS TABLE OF locator_rec INDEX BY VARCHAR2(16);
  p_locator_tbl    locator_tab;

  TYPE mtl_dtl_mig_tab IS TABLE OF gme_material_details_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE steps_mig_tab IS TABLE OF gme_batch_steps_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE activ_mig_tab IS TABLE OF gme_batch_step_activ_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE rsrc_mig_tab IS TABLE OF gme_batch_step_resources_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE process_param_mig_tab IS TABLE OF gme_process_parameters_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE process_param_tab IS TABLE OF gme_process_parameters%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE rsrc_txns_mig_tab IS TABLE OF gme_resource_txns_mig%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE rsrc_txns_tab IS TABLE OF gme_resource_txns%ROWTYPE INDEX BY BINARY_INTEGER;
  /* Bug 5620671 Added param completed ind */
  CURSOR Cur_get_txns(v_completed_ind NUMBER) IS
    SELECT p.*, m.new_batch_id, m.organization_id, m.new_batch_no, m.plant_code
    FROM   gme_batch_txns_mig t, gme_batch_mapping_mig m, ic_tran_pnd p
    WHERE  t.batch_id = m.old_batch_id
           AND p.trans_id = t.trans_id
           AND NVL(t.migrated_ind,0) = 0
           AND p.completed_ind = v_completed_ind
    ORDER BY m.organization_id, t.batch_id, p.line_id, p.trans_id;

  PROCEDURE recreate_open_batches(err_buf  OUT NOCOPY VARCHAR2,
                                  ret_code OUT NOCOPY VARCHAR2);
  PROCEDURE build_batch_hdr(p_batch_header_mig   IN gme_batch_header_mig%ROWTYPE,
                            x_batch_header       OUT NOCOPY gme_batch_header%ROWTYPE);
  PROCEDURE build_mtl_dtl(p_mtl_dtl_mig   IN  gme_post_migration.mtl_dtl_mig_tab,
                          x_mtl_dtl       OUT NOCOPY gme_common_pvt.material_details_tab);
  PROCEDURE build_steps(p_steps_mig   IN  gme_post_migration.steps_mig_tab,
                        x_steps       OUT NOCOPY gme_common_pvt.steps_tab);
  PROCEDURE build_activities(p_activities_mig IN gme_post_migration.activ_mig_tab,
                             x_activities     IN OUT NOCOPY gme_common_pvt.activities_tab);
  PROCEDURE build_resources(p_resources_mig IN gme_post_migration.rsrc_mig_tab,
                            x_resources     IN OUT NOCOPY gme_common_pvt.resources_tab);
  PROCEDURE build_parameters(p_parameters_mig IN gme_post_migration.process_param_mig_tab,
                             x_parameters     IN OUT NOCOPY gme_post_migration.process_param_tab);
  PROCEDURE build_rsrc_txns(p_rsrc_txns_mig IN gme_post_migration.rsrc_txns_mig_tab,
                            x_rsrc_txns     IN OUT NOCOPY gme_post_migration.rsrc_txns_tab);
  FUNCTION get_new_step_id(p_old_step_id   IN NUMBER,
                           p_new_batch_id  IN NUMBER) RETURN NUMBER;
  FUNCTION get_new_mat_id(p_old_mat_id   IN NUMBER,
                          p_new_batch_id IN NUMBER) RETURN NUMBER;
  PROCEDURE create_step_dependencies(p_old_batch_id IN NUMBER,
                                     p_new_batch_id IN NUMBER);
  PROCEDURE create_item_step_assoc(p_old_batch_id IN NUMBER,
                                   p_new_batch_id IN NUMBER);
  PROCEDURE create_batch_step_charges(p_old_batch_id IN NUMBER,
                                      p_new_batch_id IN NUMBER);
  PROCEDURE create_batch_step_transfers(p_old_batch_id IN NUMBER,
                                        p_new_batch_id IN NUMBER);
  PROCEDURE create_batch_mapping(p_batch_header_mig IN gme_batch_header_mig%ROWTYPE,
                                 p_batch_header     IN gme_batch_header%ROWTYPE);
  PROCEDURE create_phantom_links;
  PROCEDURE release_batches;
  PROCEDURE check_date(p_organization_id IN NUMBER,
                       p_date            IN DATE,
                       x_date            OUT NOCOPY DATE,
                       x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE get_subinventory(p_whse_code       IN VARCHAR2,
                             x_subinventory    OUT NOCOPY VARCHAR2,
                             x_organization_id OUT NOCOPY NUMBER);
  PROCEDURE get_locator(p_location        IN VARCHAR2,
                        p_whse_code       IN VARCHAR2,
                        x_organization_id OUT NOCOPY NUMBER,
                        x_locator_id      OUT NOCOPY NUMBER,
                        x_subinventory    OUT NOCOPY VARCHAR2);
  FUNCTION get_latest_revision(p_organization_id   IN NUMBER,
                               p_inventory_item_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE get_subinv_locator_type(p_subinventory IN VARCHAR2,
                                    p_organization_id IN NUMBER,
                                    x_locator_type OUT NOCOPY NUMBER);
  FUNCTION get_reason(p_reason_code IN VARCHAR2) RETURN NUMBER;
  PROCEDURE create_locator(p_location		IN  VARCHAR2,
                           p_organization_id	IN  NUMBER,
                           p_subinventory_code	IN  VARCHAR2,
                           x_location_id	OUT NOCOPY NUMBER,
                           x_failure_count	OUT NOCOPY NUMBER);
  PROCEDURE get_distribution_account(p_subinventory  IN VARCHAR2,
                                     p_org_id        IN NUMBER,
                                     x_dist_acct_id  OUT NOCOPY NUMBER);
  /* Bug 5620671 Added param completed ind */
  PROCEDURE create_txns_reservations(p_completed_ind IN NUMBER);
  PROCEDURE create_issue_receipt(p_curr_org_id       IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_txn_rec           IN Cur_get_txns%ROWTYPE,
                                 p_mmti_rec          IN mtl_transactions_interface%ROWTYPE,
                                 p_item_no           IN VARCHAR2,
                                 p_subinventory      IN VARCHAR2,
                                 p_locator_id        IN NUMBER,
                                 p_batch_org_id      IN NUMBER,
                                 x_subinventory      OUT NOCOPY VARCHAR2,
                                 x_locator_id        OUT NOCOPY NUMBER,
                                 x_lot_number        OUT NOCOPY VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2);
  PROCEDURE insert_interface_recs(p_mti_rec  IN mtl_transactions_interface%ROWTYPE,
                                  p_mtli_rec IN mtl_transaction_lots_interface%ROWTYPE,
                                  x_return_status OUT NOCOPY VARCHAR2);
  PROCEDURE close_steps;
  PROCEDURE insert_lab_lots;
END gme_post_migration;

 

/
