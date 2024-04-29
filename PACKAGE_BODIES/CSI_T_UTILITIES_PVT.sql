--------------------------------------------------------
--  DDL for Package Body CSI_T_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_UTILITIES_PVT" as
/* $Header: csivtulb.pls 120.4 2006/03/16 03:23:46 srsarava noship $ */


  PROCEDURE debug(
    p_message             IN  varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE build_instance_id_list(
    p_txn_line_detial_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_instance_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_instance_id_list    varchar2(1000);
    l_hit_count           number := 0;

  BEGIN

    l_instance_id_list := ' (' ;

    FOR l_ind in p_txn_line_detial_tbl.FIRST .. p_txn_line_detial_tbl.LAST
    LOOP

      IF p_txn_line_detial_tbl(l_ind).instance_exists_flag = 'Y' THEN

        l_hit_count := l_hit_count + 1;

        l_instance_id_list := l_instance_id_list||
          to_char(p_txn_line_detial_tbl(l_ind).instance_id)||',';
      END IF;

    END LOOP;

    l_instance_id_list := rtrim(l_instance_id_list, ',')||')';

    IF l_hit_count > 0 THEN
      x_instance_id_list := l_instance_id_list;
    ELSE
      x_instance_id_list := null;
    END IF;

  END build_instance_id_list;

  PROCEDURE build_txn_line_id_list(
    p_txn_line_detial_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_txn_line_id_list    varchar2(1000) := null;

  BEGIN

    IF p_txn_line_detial_tbl.COUNT > 0 THEN

      l_txn_line_id_list := ' (' ;

      FOR l_ind in p_txn_line_detial_tbl.FIRST .. p_txn_line_detial_tbl.LAST
      LOOP
        l_txn_line_id_list := l_txn_line_id_list||
          to_char(p_txn_line_detial_tbl(l_ind).transaction_line_id)||',';
      END LOOP;

      l_txn_line_id_list := rtrim(l_txn_line_id_list, ',')||')';

      x_txn_line_id_list := l_txn_line_id_list;

    END IF;

  END build_txn_line_id_list;

  PROCEDURE build_party_dtl_id_list(
    p_txn_party_detial_tbl in  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_party_dtl_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_party_dtl_id_list    varchar2(512);

  BEGIN

    l_party_dtl_id_list := ' (' ;

    FOR l_ind in p_txn_party_detial_tbl.FIRST .. p_txn_party_detial_tbl.LAST
    LOOP
      l_party_dtl_id_list := l_party_dtl_id_list||
        to_char(p_txn_party_detial_tbl(l_ind).txn_party_detail_id)||',';
    END LOOP;

    l_party_dtl_id_list := rtrim(l_party_dtl_id_list, ',')||')';

    x_party_dtl_id_list := l_party_dtl_id_list;

  END build_party_dtl_id_list;

  PROCEDURE build_line_dtl_id_list(
    p_txn_line_detial_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_line_dtl_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_line_dtl_id_list    varchar2(512);

  BEGIN

    l_line_dtl_id_list := ' (' ;

    FOR l_ind in p_txn_line_detial_tbl.FIRST .. p_txn_line_detial_tbl.LAST
    LOOP
      l_line_dtl_id_list := l_line_dtl_id_list||
        to_char(p_txn_line_detial_tbl(l_ind).txn_line_detail_id)||',';
    END LOOP;

    l_line_dtl_id_list := rtrim(l_line_dtl_id_list, ',')||')';

    x_line_dtl_id_list := l_line_dtl_id_list;

  END build_line_dtl_id_list;

  /* This routine merges the transaction details tables */
  PROCEDURE merge_tables(
    px_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_pty_dtl_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_pty_acct_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_ext_attrib_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    --
    p_line_dtl_tbl     IN csi_t_datastructures_grp.txn_line_detail_tbl,
    p_pty_dtl_tbl      IN csi_t_datastructures_grp.txn_party_detail_tbl,
    p_pty_acct_tbl     IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_ii_rltns_tbl     IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_org_assgn_tbl    IN csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_ext_attrib_tbl   IN csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    p_txn_systems_tbl  IN csi_t_datastructures_grp.txn_systems_tbl)
  IS

    l_line_ind         binary_integer;
    l_pty_ind          binary_integer;
    l_pa_ind           binary_integer;
    l_ii_ind           binary_integer;
    l_oa_ind           binary_integer;
    l_ea_ind           binary_integer;
    l_sys_ind          binary_integer;

  BEGIN

    l_line_ind  := px_line_dtl_tbl.COUNT;

    IF p_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ind in p_line_dtl_tbl.FIRST..p_line_dtl_tbl.LAST
      LOOP

        l_line_ind := l_line_ind + 1;
        px_line_dtl_tbl(l_line_ind) := p_line_dtl_tbl(l_ind);

      END LOOP;
    END IF;

    l_pty_ind   := px_pty_dtl_tbl.COUNT;
    IF p_pty_dtl_tbl.COUNT > 0 THEN

      FOR l_ind in p_pty_dtl_tbl.FIRST..p_pty_dtl_tbl.LAST
      LOOP

        l_pty_ind := l_pty_ind + 1;
        px_pty_dtl_tbl(l_pty_ind) := p_pty_dtl_tbl(l_ind);

      END LOOP;

    END IF;

    l_pa_ind    := px_pty_acct_tbl.COUNT;
    IF p_pty_acct_tbl.COUNT > 0 THEN

      FOR l_ind in p_pty_acct_tbl.FIRST .. p_pty_acct_tbl.LAST
      LOOP

        l_pa_ind := l_pa_ind + 1;
        px_pty_acct_tbl(l_pa_ind) := p_pty_acct_tbl(l_ind);

      END LOOP;
    END IF;

    l_ii_ind    := px_ii_rltns_tbl.COUNT;
    IF p_ii_rltns_tbl.COUNT > 0 THEN

      FOR l_ind in p_ii_rltns_tbl.FIRST .. p_ii_rltns_tbl.LAST
      LOOP

        l_ii_ind := l_ii_ind + 1;
        px_ii_rltns_tbl(l_ii_ind) := p_ii_rltns_tbl(l_ind);

      END LOOP;
    END IF;

    l_oa_ind    := px_org_assgn_tbl.COUNT;
    IF p_org_assgn_tbl.COUNT > 0 THEN

      FOR l_ind in p_org_assgn_tbl.FIRST..p_org_assgn_tbl.LAST
      LOOP

        l_oa_ind := l_oa_ind + 1;
        px_org_assgn_tbl(l_oa_ind) := p_org_assgn_tbl(l_ind);

      END LOOP;
    END IF;

    l_ea_ind    := px_ext_attrib_tbl.COUNT;
    IF p_ext_attrib_tbl.COUNT > 0 THEN

      FOR l_ind in p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST
      LOOP

        l_ea_ind := l_ea_ind + 1;
        px_ext_attrib_tbl(l_ea_ind) := p_ext_attrib_tbl(l_ind);

      END LOOP;
    END IF;

    l_sys_ind := px_txn_systems_tbl.count;
    IF p_txn_systems_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_systems_tbl.FIRST .. p_txn_systems_tbl.LAST
      LOOP

        l_sys_ind := l_sys_ind + 1;
        px_txn_systems_tbl(l_sys_ind) := p_txn_systems_tbl(l_ind);

      END LOOP;
    END IF;

  END merge_tables;



  /* This routine converts the ids into indexes, This is to prepare the
     pl/sql tables to be passed to the create API. Used in the Copy Txn Details
     API
  */
  PROCEDURE convert_ids_to_index(
    px_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_pty_dtl_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_pty_acct_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_ext_attrib_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl)
  IS

    l_debug_level      NUMBER;
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_pty_acct_tbl     csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    ll_pa_ind          binary_integer;

    l_pty_dtl_tbl      csi_t_datastructures_grp.txn_party_detail_tbl;

    l_subject_index    binary_integer;
    l_object_index     binary_integer;
    l_line_dtl_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;

  BEGIN

    --debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'convert_ids_to_index',
      p_pkg_name => 'csi_t_utilities_pvt');


    l_pty_dtl_tbl := px_pty_dtl_tbl;
    l_line_dtl_tbl := px_line_dtl_tbl;
    -- preserving the assc txn line detail id while copying . added this for loop  for bug 3600950
      FOR l_tld_ind in px_line_dtl_tbl.FIRST..px_line_dtl_tbl.LAST
      LOOP
        IF px_line_dtl_tbl(l_tld_ind).source_transaction_flag = 'N' THEN
        /* translate the assc_txn_line_detail_id to an index */
          IF nvl(px_line_dtl_tbl(l_tld_ind).assc_txn_line_detail_id, fnd_api.g_miss_num)
              <> fnd_api.g_miss_num
          THEN
            FOR l_s_ind in l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
            LOOP

              IF px_line_dtl_tbl(l_s_ind).txn_line_detail_id = px_line_dtl_tbl(l_tld_ind).assc_txn_line_detail_id
              THEN
                 px_line_dtl_tbl(l_tld_ind).assc_txn_line_detail_id := l_s_ind;
                exit;
              END IF;
            END LOOP;
           END IF;
        END IF;
      END LOOP;

    -- ii_relationsips

    IF px_ii_rltns_tbl.COUNT > 0 THEN
      FOR l_ii_ind in px_ii_rltns_tbl.FIRST..px_ii_rltns_tbl.LAST
      LOOP

        px_ii_rltns_tbl(l_ii_ind).transaction_line_id := fnd_api.g_miss_num;
        px_ii_rltns_tbl(l_ii_ind).txn_relationship_id := fnd_api.g_miss_num;

        /* translate the subject_id to subject index */
        IF px_ii_rltns_tbl(l_ii_ind).subject_id IS NOT NULL
        THEN
          IF px_line_dtl_tbl.COUNT > 0
          THEN
            FOR l_s_ind in px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
            LOOP

              IF px_line_dtl_tbl(l_s_ind).txn_line_detail_id = px_ii_rltns_tbl(l_ii_ind).subject_id
              THEN
                l_subject_index := l_s_ind;
                exit;
              END IF;

            END LOOP;
          END IF;
        END IF;

        /* translate the object_id to object index */
        IF px_ii_rltns_tbl(l_ii_ind).object_id IS NOT NULL THEN
          IF px_line_dtl_tbl.COUNT > 0 THEN
            FOR l_o_ind in px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
            LOOP

              IF px_line_dtl_tbl(l_o_ind).txn_line_detail_id = px_ii_rltns_tbl(l_ii_ind).object_id
              THEN
                l_object_index := l_o_ind;
                exit;
              END IF;

            END LOOP;
          END IF;
        END IF;

     ---Added (Start) for m-to-m enhancements
     ---As we are also supporting rltns across source SO Lines
     ---in that case the subject/object id will not find any match
     ---in px_line_dtl_tbl. In such case we will keep the subject/object
     ---as the same and flag it is as NOT an index.
      IF l_subject_index IS NOT NULL
      THEN
        px_ii_rltns_tbl(l_ii_ind).subject_id := l_subject_index;
        px_ii_rltns_tbl(l_ii_ind).subject_index_flag := 'Y' ;
      ELSE
        px_ii_rltns_tbl(l_ii_ind).subject_index_flag := 'N' ;
      END IF ;

      IF l_object_index IS NOT NULL
      THEN
        px_ii_rltns_tbl(l_ii_ind).object_id := l_object_index;
        px_ii_rltns_tbl(l_ii_ind).object_index_flag := 'Y' ;
      ELSE
        px_ii_rltns_tbl(l_ii_ind).object_index_flag := 'N' ;
      END IF ;
      ---Added (End) for m-to-m enhancements

      END LOOP;
    END IF;

    ll_pa_ind := 0;
    IF px_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ln_ind IN px_line_dtl_tbl.first .. px_line_dtl_tbl.LAST
      LOOP

        IF px_pty_dtl_tbl.COUNT > 0 THEN
          FOR l_pt_ind in px_pty_dtl_tbl.FIRST..px_pty_dtl_tbl.LAST
          LOOP

            IF px_pty_dtl_tbl(l_pt_ind).txn_line_detail_id =
                px_line_dtl_tbl(l_ln_ind).txn_line_detail_id
            THEN
              IF px_pty_acct_tbl.COUNT > 0 THEN
                FOR l_pa_ind in px_pty_acct_tbl.FIRST..px_pty_acct_tbl.LAST
                LOOP

                  IF px_pty_acct_tbl(l_pa_ind).txn_party_detail_id =
                      px_pty_dtl_tbl(l_pt_ind).txn_party_detail_id
                  THEN
                    ll_pa_ind := ll_pa_ind + 1;
                    px_pty_acct_tbl(l_pa_ind).txn_party_details_index := l_pt_ind;
                    px_pty_acct_tbl(l_pa_ind).txn_party_detail_id := fnd_api.g_miss_num;
                    px_pty_acct_tbl(l_pa_ind).txn_account_detail_id := fnd_api.g_miss_num;
                    l_pty_acct_tbl(ll_pa_ind) := px_pty_acct_tbl(l_pa_ind);
                  END IF;
                END LOOP;
              END IF;

              px_pty_dtl_tbl(l_pt_ind).txn_line_details_index := l_ln_ind;
              px_pty_dtl_tbl(l_pt_ind).txn_line_detail_id := fnd_api.g_miss_num;
            END IF;
            --px_pty_dtl_tbl(l_pt_ind).txn_party_detail_id := fnd_api.g_miss_num;
          END LOOP;
        END IF;

        IF px_org_assgn_tbl.COUNT > 0 THEN
          FOR l_oa_ind in px_org_assgn_tbl.FIRST..px_org_assgn_tbl.LAST
          LOOP
            IF px_org_assgn_tbl(l_oa_ind).txn_line_detail_id =
                px_line_dtl_tbl(l_ln_ind).txn_line_detail_id
            THEN
              px_org_assgn_tbl(l_oa_ind).txn_line_details_index := l_ln_ind;
              px_org_assgn_tbl(l_oa_ind).txn_line_detail_id := fnd_api.g_miss_num;
            END IF;
            px_org_assgn_tbl(l_oa_ind).txn_operating_unit_id := fnd_api.g_miss_num;
          END LOOP;
        END IF;

        IF px_ext_attrib_tbl.COUNT > 0 THEN
          FOR l_ea_ind in px_ext_attrib_tbl.FIRST..px_ext_attrib_tbl.LAST
          LOOP
            IF px_ext_attrib_tbl(l_ea_ind).txn_line_detail_id =
                 px_line_dtl_tbl(l_ln_ind).txn_line_detail_id
            THEN
              px_ext_attrib_tbl(l_ea_ind).txn_line_details_index := l_ln_ind;
              px_ext_attrib_tbl(l_ea_ind).txn_line_detail_id := fnd_api.g_miss_num;
            END IF;
            px_ext_attrib_tbl(l_ea_ind).txn_attrib_detail_id := fnd_api.g_miss_num;
          END LOOP;
        END IF;

        px_line_dtl_tbl(l_ln_ind).txn_line_detail_id := fnd_api.g_miss_num;
        px_line_dtl_tbl(l_ln_ind).transaction_line_id := fnd_api.g_miss_num;

        IF px_line_dtl_tbl(l_ln_ind).transaction_system_id <> fnd_api.g_miss_num THEN

          csi_t_vldn_routines_pvt.get_txn_systems_index(
            p_txn_system_id     => px_line_dtl_tbl(l_ln_ind).transaction_system_id,
            p_txn_systems_tbl   => px_txn_systems_tbl,
            x_txn_systems_index => px_line_dtl_tbl(l_ln_ind).txn_systems_index,
            x_return_status     => l_return_status);

          px_line_dtl_tbl(l_ln_ind).transaction_system_id := fnd_api.g_miss_num;

        END IF;

      END LOOP;
    END IF;

    IF px_txn_systems_tbl.COUNT > 0 THEN
      FOR l_sys_ind in px_txn_systems_tbl.FIRST..px_txn_systems_tbl.LAST
      LOOP
        px_txn_systems_tbl(l_sys_ind).transaction_line_id   := fnd_api.g_miss_num;
        px_txn_systems_tbl(l_sys_ind).transaction_system_id := fnd_api.g_miss_num;
      END LOOP;
    END IF;

    px_pty_acct_tbl := l_pty_acct_tbl;

    IF px_pty_dtl_tbl.COUNT > 0 THEN
      FOR l_ind IN px_pty_dtl_tbl.FIRST .. px_pty_dtl_tbl.LAST
      LOOP
        px_pty_dtl_tbl(l_ind).txn_party_detail_id := fnd_api.g_miss_num;

        IF nvl(px_pty_dtl_tbl(l_ind).contact_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN
          FOR ll_ind IN l_pty_dtl_tbl.FIRST .. l_pty_dtl_tbl.LAST
          LOOP
            IF l_pty_dtl_tbl(ll_ind).txn_party_detail_id = px_pty_dtl_tbl(l_ind).contact_party_id
            THEN
              px_pty_dtl_tbl(l_ind).contact_party_id := ll_ind;
              exit;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;

  END convert_ids_to_index;


  /* This routine builds a txn system ids list given txn line detail pl/sql
     table. The output is a comma seperated list of txn system id list within
     braces which can be used in a IN operator in a where clause
  */

  PROCEDURE build_txn_system_id_list(
    p_txn_line_detial_tbl IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_system_id_list  OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_txn_system_id_list  varchar2(1000);
    l_hit_count           number := 0;

  BEGIN

    l_txn_system_id_list := ' (' ;

    FOR l_ind in p_txn_line_detial_tbl.FIRST .. p_txn_line_detial_tbl.LAST
    LOOP

      IF p_txn_line_detial_tbl(l_ind).transaction_system_id <> fnd_api.g_miss_num THEN

        l_hit_count := l_hit_count + 1;

        l_txn_system_id_list := l_txn_system_id_list||
          to_char(p_txn_line_detial_tbl(l_ind).transaction_system_id)||',';

      END IF;

    END LOOP;

    l_txn_system_id_list := rtrim(l_txn_system_id_list, ',')||')';

    IF l_hit_count > 0 THEN
      x_txn_system_id_list := l_txn_system_id_list;
    ELSE
      x_txn_system_id_list := null;
    END IF;

  END build_txn_system_id_list;

  PROCEDURE source_for_standalone(
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_source_rec          OUT NOCOPY csi_t_ui_pvt.txn_source_rec,
    x_txn_line_detail_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_detail_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_txn_source_rec          csi_t_ui_pvt.txn_source_rec;
    l_txn_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl             csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl            csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_org_assgn_tbl           csi_t_datastructures_grp.txn_org_assgn_tbl;

    l_mo_org_id               oe_order_lines_all.org_id%TYPE;
    l_serial_control_code     mtl_system_items_b.serial_number_control_code%TYPE;
    l_lot_control_code        mtl_system_items_b.lot_control_code%TYPE;
    l_nl_trackable_flag       mtl_system_items_b.comms_nl_trackable_flag%TYPE;
    l_loop_count              number;
    l_td_quantity             number;
    l_uom                     varchar2(30);
    l_item_type_code          oe_order_lines_all.item_type_code%TYPE;
    l_location_type_code      varchar2(30) := fnd_api.g_miss_char;
    l_location_id             number  := fnd_api.g_miss_num;
    l_operating_unit_id       number;
    l_oa_relationship_code    varchar2(30);
    l_sub_type_id             number  := fnd_api.g_miss_num;
    l_shippable_flag          varchar2(1) := 'N';
    l_sold_from_org_id        number;

    -- For partner prdering
    l_partner_rec             oe_install_base_util.partner_order_rec;
    l_ib_owner                VARCHAR2(60);
    l_end_customer_id         NUMBER;
    l_partner_ib_owner        VARCHAR2(60);
    l_line_id                 NUMBER;


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF px_txn_line_rec.source_transaction_table = 'OE_ORDER_LINES_ALL' THEN

      BEGIN

        SELECT ol.inventory_item_id,
               ol.item_revision,
               ol.ordered_quantity,
               ol.order_quantity_uom,
               ol.shipped_quantity,
               ol.fulfilled_quantity,
               ol.org_id,
               ol.item_type_code,
               nvl(ol.sold_to_org_id, oh.sold_to_org_id),
               nvl(ol.invoice_to_org_id, oh.invoice_to_org_id),
               nvl(ol.ship_to_org_id, oh.ship_to_org_id),
               nvl(ol.sold_from_org_id, oh.sold_from_org_id),
               ol.line_id,
               ol.header_id
        INTO   l_txn_source_rec.inventory_item_id,
               l_txn_source_rec.item_revision,
               l_txn_source_rec.source_quantity,
               l_txn_source_rec.source_uom,
               l_txn_source_rec.shipped_quantity,
               l_txn_source_rec.fulfilled_quantity,
               l_mo_org_id,
               l_item_type_code,
               l_txn_source_rec.party_account_id,
               l_txn_source_rec.bill_to_address_id,
               l_txn_source_rec.ship_to_address_id,
               l_sold_from_org_id,
               l_line_id,
               px_txn_line_rec.source_txn_header_id
        FROM   oe_order_lines_all ol,
               oe_order_headers_all oh
        WHERE  line_id      = px_txn_line_rec.source_transaction_id
        AND    oh.header_id = ol.header_id;

        -- for partner ordering
        OE_INSTALL_BASE_UTIL.get_partner_ord_rec(p_order_line_id      => l_line_id,
                                                 x_partner_order_rec  => l_partner_rec);

        IF l_partner_rec.IB_OWNER = 'END_CUSTOMER'
        THEN
          IF l_partner_rec.END_CUSTOMER_ID is null Then
             fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
             fnd_msg_pub.add;
             raise fnd_api.g_exc_error;
          ELSE
             l_ib_owner                        := l_partner_rec.ib_owner;
             l_txn_source_rec.party_account_id := l_partner_rec.end_customer_id;
          END IF;
        ELSIF  l_partner_rec.IB_OWNER = 'INSTALL_BASE'
        THEN
             l_ib_owner                        := l_partner_rec.ib_owner;
             l_txn_source_rec.party_account_id := fnd_api.g_miss_num;
        ELSE
          l_txn_source_rec.party_account_id  := l_txn_source_rec.party_account_id;
        END IF;


        SELECT party_id
        INTO   l_txn_source_rec.party_id
        FROM   hz_cust_accounts
        where  cust_account_id = l_txn_source_rec.party_account_id;

        l_txn_source_rec.organization_id := oe_sys_parameters.value(
                                              param_name => 'MASTER_ORGANIZATION_ID',
                                              p_org_id   => l_mo_org_id);

        l_location_type_code := 'HZ_PARTY_SITES';
        l_location_id        := l_txn_source_rec.ship_to_address_id;

      EXCEPTION
        WHEN no_data_found THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_SOURCE_ID_INVALID');
          FND_MESSAGE.set_token('SRC_NAME',px_txn_line_rec.source_transaction_table);
          FND_MESSAGE.set_token('SRC_LINE_ID',px_txn_line_rec.source_transaction_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

      END;

    ELSIF px_txn_line_rec.source_transaction_table = 'WSH_DELIVERY_DETAILS' THEN

        SELECT inventory_item_id,
               revision,
               shipped_quantity,
               requested_quantity_uom,
               organization_id,
               customer_id
        INTO   l_txn_source_rec.inventory_item_id,
               l_txn_source_rec.item_revision,
               l_txn_source_rec.source_quantity,
               l_txn_source_rec.source_uom,
               l_txn_source_rec.organization_id,
               l_txn_source_rec.party_id
--        FROM   wsh_delivery_details
        FROM   wsh_delivery_details_ob_grp_v
        WHERE  delivery_detail_id = px_txn_line_rec.source_transaction_id;

    ELSIF px_txn_line_rec.source_transaction_table = 'PO_LINES_ALL' THEN

        SELECT item_id,
               item_revision,
               quantity,
               unit_meas_lookup_code
        INTO   l_txn_source_rec.inventory_item_id,
               l_txn_source_rec.item_revision,
               l_txn_source_rec.source_quantity,
               l_uom
        FROM   po_lines_all
        WHERE  po_line_id = px_txn_line_rec.source_transaction_id;

    ELSIF px_txn_line_rec.source_transaction_table = 'RCV_SHIPMENT_LINES' THEN
      null;
    ELSIF px_txn_line_rec.source_transaction_table = 'RCV_TRANSACTIONS' THEN
      null;
    ELSIF px_txn_line_rec.source_transaction_table = 'MATERIAL_TRANSACTION' THEN
      null;
    ELSIF px_txn_line_rec.source_transaction_table = 'MATERIAL_TRANSACTION' THEN
      null;
    ELSIF px_txn_line_rec.source_transaction_table = 'ASO_QUOTE_LINES_ALL' THEN
      null;
    ELSE

      FND_MESSAGE.set_name('CSI','CSI_TXN_SRC_TABLE_INVALID');
      FND_MESSAGE.set_token('SRC_TABLE',px_txn_line_rec.source_transaction_table);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;

    BEGIN

      SELECT concatenated_segments ,
             serial_number_control_code,
             lot_control_code,
             nvl(comms_nl_trackable_flag,'N'),
             primary_uom_code,
             nvl(shippable_item_flag,'N')
      INTO   l_txn_source_rec.inventory_item_name,
             l_serial_control_code,
             l_lot_control_code,
             l_nl_trackable_flag,
             l_txn_source_rec.primary_uom,
             l_shippable_flag
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = l_txn_source_rec.inventory_item_id
      AND    organization_id   = l_txn_source_rec.organization_id;

    EXCEPTION
      WHEN no_data_found THEN
        RAISE fnd_api.g_exc_error;
    END;

    /* logic to derive sub_type_id */

    BEGIN

      SELECT sub_type_id
      INTO   l_sub_type_id
      FROM   csi_txn_sub_types
      WHERE  transaction_type_id = px_txn_line_rec.source_transaction_type_id
      AND    default_flag = 'Y';

    EXCEPTION
      WHEN no_data_found THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_TYPE_ID_INVALID');
        FND_MESSAGE.set_token('TXN_TYPE_ID',px_txn_line_rec.source_transaction_type_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

      WHEN too_many_rows THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_TYPE_ID_INVALID');
        FND_MESSAGE.set_token('TXN_TYPE_ID',px_txn_line_rec.source_transaction_type_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

    END;

    -- serial control chk (1 - NO Control ELSE serialized)
    IF l_serial_control_code = 1 then
      l_loop_count  := 1;
      l_td_quantity := l_txn_source_rec.source_quantity;
      l_txn_source_rec.serial_control_flag := 'N';
    ELSE
     -- Commented out for UI
     -- l_loop_count  := l_txn_source_rec.source_quantity;
      l_loop_count  := 1;
      l_td_quantity := l_txn_source_rec.source_quantity;
      l_txn_source_rec.serial_control_flag := 'Y';
    END IF;

    IF nvl(l_lot_control_code, -9999) =  2 THEN
      l_txn_source_rec.lot_control_flag := 'Y';
    ELSE
      l_txn_source_rec.lot_control_flag := 'N';
    END IF;

    l_txn_source_rec.nl_trackable_flag := l_nl_trackable_flag;

-- Commented out for UI
    /* overriding rhe serial control here */
/*    IF l_item_type_code in ('MODEL', 'KIT') THEN
      l_loop_count  := l_txn_source_rec.source_quantity;
      l_td_quantity := 1;
    END IF;
*/

    --populate txn_line_detail table
    FOR l_ind in 1..l_loop_count
    LOOP

      l_txn_line_dtl_tbl(l_ind).sub_type_id             := l_sub_type_id;
      l_txn_line_dtl_tbl(l_ind).instance_exists_flag    := 'N';
      l_txn_line_dtl_tbl(l_ind).source_transaction_flag := 'Y';
      l_txn_line_dtl_tbl(l_ind).inventory_item_id       := l_txn_source_rec.inventory_item_id;
      l_txn_line_dtl_tbl(l_ind).inventory_revision      := l_txn_source_rec.item_revision;
      l_txn_line_dtl_tbl(l_ind).inv_organization_id     := l_txn_source_rec.organization_id;
      l_txn_line_dtl_tbl(l_ind).quantity                := l_td_quantity;
      l_txn_line_dtl_tbl(l_ind).unit_of_measure         := l_txn_source_rec.source_uom;

      IF l_txn_source_rec.serial_control_flag = 'Y' THEN
        l_txn_line_dtl_tbl(l_ind).mfg_serial_number_flag := 'Y';
      ELSE
        l_txn_line_dtl_tbl(l_ind).mfg_serial_number_flag := 'N';
      END IF;

      --l_txn_line_dtl_tbl(l_ind).location_type_code      := l_location_type_code;
      --l_txn_line_dtl_tbl(l_ind).location_id             := l_location_id;
      --l_txn_line_dtl_tbl(l_ind).installation_date       := sysdate;
      l_txn_line_dtl_tbl(l_ind).active_start_date       := sysdate;
      l_txn_line_dtl_tbl(l_ind).processing_status       := 'SUBMIT';
      l_txn_line_dtl_tbl(l_ind).object_version_number   := 1.0;

      -- party details
      l_pty_dtl_tbl(l_ind).party_source_table       := 'HZ_PARTIES';
      l_pty_dtl_tbl(l_ind).party_source_id          := l_txn_source_rec.party_id;
      l_pty_dtl_tbl(l_ind).relationship_type_code   := 'OWNER';
      l_pty_dtl_tbl(l_ind).active_start_date        := sysdate;
      l_pty_dtl_tbl(l_ind).preserve_detail_flag     := 'Y';
      l_pty_dtl_tbl(l_ind).txn_line_details_index   := l_ind;
      l_pty_dtl_tbl(l_ind).contact_flag             := 'N';

      -- party account details
      l_pty_acct_tbl(l_ind).account_id              := l_txn_source_rec.party_account_id;
      l_pty_acct_tbl(l_ind).bill_to_address_id      := l_txn_source_rec.bill_to_address_id;
      l_pty_acct_tbl(l_ind).ship_to_address_id      := l_txn_source_rec.ship_to_address_id;
      l_pty_acct_tbl(l_ind).relationship_type_code  := 'OWNER';
      l_pty_acct_tbl(l_ind).active_start_date       := sysdate;
      l_pty_acct_tbl(l_ind).preserve_detail_flag    := 'Y';
      l_pty_acct_tbl(l_ind).txn_party_details_index := l_ind;

      l_org_assgn_tbl(l_ind).operating_unit_id      := l_sold_from_org_id;
      l_org_assgn_tbl(l_ind).relationship_type_code := 'SOLD_FROM';
      l_org_assgn_tbl(l_ind).active_start_date      := sysdate;
      l_org_assgn_tbl(l_ind).preserve_detail_flag   := 'Y';
      l_org_assgn_tbl(l_ind).txn_line_details_index := l_ind;

    END LOOP;

    x_txn_source_rec          := l_txn_source_rec;
    x_txn_line_detail_tbl     := l_txn_line_dtl_tbl;
    x_txn_party_detail_tbl    := l_pty_dtl_tbl;
    x_txn_pty_acct_detail_tbl := l_pty_acct_tbl;
    x_txn_org_assgn_tbl       := l_org_assgn_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END source_for_standalone;

  PROCEDURE source_for_params(
    p_txn_source_param_rec    IN  csi_t_ui_pvt.txn_source_param_rec,
    x_txn_source_rec          OUT NOCOPY csi_t_ui_pvt.txn_source_rec,
    x_txn_line_detail_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_detail_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_txn_source_rec          csi_t_ui_pvt.txn_source_rec;
    l_txn_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;

    l_mo_org_id               oe_order_lines_all.org_id%TYPE;
    l_serial_control_code     mtl_system_items_b.serial_number_control_code%TYPE;
    l_lot_control_code        mtl_system_items_b.lot_control_code%TYPE;
    l_nl_trackable_flag       mtl_system_items_b.comms_nl_trackable_flag%TYPE;
    l_loop_count              number;
    l_td_quantity             number;
    l_uom                     varchar2(30);
    l_item_type               mtl_system_items.bom_item_type%TYPE;
    l_location_type_code      varchar2(30) := fnd_api.g_miss_char;
    l_location_id             number  := fnd_api.g_miss_num;
    l_operating_unit_id       number;
    l_oa_relationship_code    varchar2(30);
    l_sub_type_id             number  := fnd_api.g_miss_num;
    l_shippable_flag          varchar2(1) := 'N';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_txn_source_rec.organization_id    := p_txn_source_param_rec.inv_orgn_id;
    l_txn_source_rec.inventory_item_id  := p_txn_source_param_rec.inventory_item_id;
    l_txn_source_rec.item_revision      := p_txn_source_param_rec.item_revision;
    l_txn_source_rec.source_quantity    := p_txn_source_param_rec.transacted_quantity;
    l_txn_source_rec.source_uom         := p_txn_source_param_rec.transacted_uom;
    l_txn_source_rec.party_id           := p_txn_source_param_rec.party_id;
    l_txn_source_rec.party_account_id   := p_txn_source_param_rec.account_id;
    l_txn_source_rec.bill_to_address_id := p_txn_source_param_rec.invoice_to_org_id;
    l_txn_source_rec.ship_to_address_id := p_txn_source_param_rec.ship_to_org_id;

    BEGIN

      SELECT concatenated_segments ,
             serial_number_control_code,
             lot_control_code,
             nvl(comms_nl_trackable_flag,'N'),
             primary_uom_code,
             nvl(shippable_item_flag,'N')
      INTO   l_txn_source_rec.inventory_item_name,
             l_serial_control_code,
             l_lot_control_code,
             l_nl_trackable_flag,
             l_txn_source_rec.primary_uom,
             l_shippable_flag
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = l_txn_source_rec.inventory_item_id
      AND    organization_id   = l_txn_source_rec.organization_id;

    EXCEPTION
      WHEN no_data_found THEN
        RAISE fnd_api.g_exc_error;
    END;

    /* logic to derive sub_type_id */

    BEGIN

      SELECT sub_type_id
      INTO   l_sub_type_id
      FROM   csi_txn_sub_types
      WHERE  transaction_type_id = p_txn_source_param_rec.source_transaction_type_id
      AND    default_flag = 'Y';

    EXCEPTION
      WHEN no_data_found THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_TYPE_ID_INVALID');
        FND_MESSAGE.set_token('TXN_TYPE_ID',p_txn_source_param_rec.source_transaction_type_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

      WHEN too_many_rows THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_TYPE_ID_INVALID');
        FND_MESSAGE.set_token('TXN_TYPE_ID',p_txn_source_param_rec.source_transaction_type_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

    END;

    -- serial control chk (1 - NO Control ELSE serialized)
    IF l_serial_control_code = 1 then
      l_loop_count  := 1;
      l_td_quantity := l_txn_source_rec.source_quantity;
      l_txn_source_rec.serial_control_flag := 'N';
    ELSE
      -- Commented out for UI
      --l_loop_count  := l_txn_source_rec.source_quantity;
      l_loop_count    := 1;
      l_td_quantity   :=  l_txn_source_rec.source_quantity;
      l_txn_source_rec.serial_control_flag := 'Y';
    END IF;

    IF nvl(l_lot_control_code, -9999) =  2 THEN
      l_txn_source_rec.lot_control_flag := 'Y';
    ELSE
      l_txn_source_rec.lot_control_flag := 'N';
    END IF;

    l_txn_source_rec.nl_trackable_flag := l_nl_trackable_flag;

    /* if MODEL then split the transaction detail into one each */

-- commented out for UI
/*    IF l_item_type = 1 THEN
      l_loop_count  := l_txn_source_rec.source_quantity;
      l_td_quantity := 1;
    END IF;
*/
    --populate txn_line_detail table
    FOR l_ind in 1..l_loop_count
    LOOP

      l_txn_line_dtl_tbl(l_ind).sub_type_id             := l_sub_type_id;
      l_txn_line_dtl_tbl(l_ind).instance_exists_flag    := 'N';
      l_txn_line_dtl_tbl(l_ind).source_transaction_flag := 'Y';
      l_txn_line_dtl_tbl(l_ind).inventory_item_id       := l_txn_source_rec.inventory_item_id;
      l_txn_line_dtl_tbl(l_ind).inventory_revision      := l_txn_source_rec.item_revision;
      l_txn_line_dtl_tbl(l_ind).inv_organization_id     := l_txn_source_rec.organization_id;
      l_txn_line_dtl_tbl(l_ind).quantity                := l_td_quantity;
      l_txn_line_dtl_tbl(l_ind).unit_of_measure         := l_txn_source_rec.source_uom;

      IF l_txn_source_rec.serial_control_flag = 'Y' THEN
        l_txn_line_dtl_tbl(l_ind).mfg_serial_number_flag := 'Y';
      ELSE
        l_txn_line_dtl_tbl(l_ind).mfg_serial_number_flag := 'N';
      END IF;

      l_txn_line_dtl_tbl(l_ind).installation_date       := sysdate;
      l_txn_line_dtl_tbl(l_ind).active_start_date       := sysdate;
      l_txn_line_dtl_tbl(l_ind).processing_status       := 'SUBMIT';
      l_txn_line_dtl_tbl(l_ind).object_version_number   := 1.0;

    END LOOP;

    x_txn_line_detail_tbl := l_txn_line_dtl_tbl;
    x_txn_source_rec      := l_txn_source_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END source_for_params;

  PROCEDURE get_source_dtls(
    p_txn_source_param_rec    IN  csi_t_ui_pvt.txn_source_param_rec,
    x_txn_source_rec          OUT NOCOPY csi_t_ui_pvt.txn_source_rec,
    x_txn_line_rec            OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_detail_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_detail_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_txn_source_rec          csi_t_ui_pvt.txn_source_rec;
    l_txn_line_rec            csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl           csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;

    l_debug_level             number;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    x_return_status := l_return_status;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'get_source_dtls',
      p_pkg_name => 'csi_t_utilities_pvt');

    IF l_debug_level > 1 then

      csi_t_gen_utility_pvt.dump_txn_source_param_rec(
        p_txn_source_param_rec => p_txn_source_param_rec);

    END IF;

    IF p_txn_source_param_rec.standalone_mode = 'Y' THEN

      l_txn_line_rec.source_transaction_type_id :=
                     p_txn_source_param_rec.source_transaction_type_id;
      l_txn_line_rec.source_transaction_table   :=
                     p_txn_source_param_rec.source_transaction_table;
      l_txn_line_rec.source_transaction_id      :=
                     p_txn_source_param_rec.source_transaction_id;

      source_for_standalone(
        px_txn_line_rec           => l_txn_line_rec,
        x_txn_source_rec          => l_txn_source_rec,
        x_txn_line_detail_tbl     => l_txn_line_dtl_tbl,
        x_txn_party_detail_tbl    => l_txn_party_tbl,
        x_txn_pty_acct_detail_tbl => l_txn_pty_acct_tbl,
        x_txn_org_assgn_tbl       => l_txn_org_assgn_tbl,
        x_return_status           => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE

      source_for_params(
        p_txn_source_param_rec    => p_txn_source_param_rec,
        x_txn_source_rec          => l_txn_source_rec,
        x_txn_line_detail_tbl     => l_txn_line_dtl_tbl,
        x_txn_party_detail_tbl    => l_txn_party_tbl,
        x_txn_pty_acct_detail_tbl => l_txn_pty_acct_tbl,
        x_txn_org_assgn_tbl       => l_txn_org_assgn_tbl,
        x_return_status           => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    x_txn_source_rec          := l_txn_source_rec;
    x_txn_line_rec            := l_txn_line_rec;
    x_txn_line_detail_tbl     := l_txn_line_dtl_tbl;
    x_txn_party_detail_tbl    := l_txn_party_tbl;
    x_txn_pty_acct_detail_tbl := l_txn_pty_acct_tbl;
    x_txn_org_assgn_tbl       := l_txn_org_assgn_tbl;

    csi_t_gen_utility_pvt.dump_txn_source_rec(
      p_txn_source_rec => l_txn_source_rec);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others THEN
      fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',sqlerrm);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_source_dtls;


  FUNCTION delimiter_count (p_data_string IN varchar2 ) RETURN number
  IS
    l_delimiter            char := ':';
    l_loop_count           binary_integer;
    l_delimiter_position   binary_integer;
  BEGIN

    l_loop_count := 0;
    LOOP
      l_loop_count         := l_loop_count + 1;
      l_delimiter_position := instr(p_data_string, l_delimiter, 1, l_loop_count);

      IF l_delimiter_position = 0 THEN
        EXIT;
      END IF;
    END LOOP;

    IF l_loop_count > 0 THEN
      RETURN(l_loop_count-1);
    ELSE
      RETURN(l_loop_count);
    END IF;

  END delimiter_count;


  FUNCTION om_vld_org_id(p_order_line_id IN number) RETURN number IS
    l_org_id        number;
    l_om_vld_org_id number;
  BEGIN

    SELECT org_id INTO l_org_id
    FROM   oe_order_lines_all
    WHERE  line_id = p_order_line_id;

    l_om_vld_org_id := oe_sys_parameters.value(
                         param_name => 'MASTER_ORGANIZATION_ID',
                         p_org_id   =>l_org_id );

    RETURN l_om_vld_org_id;


  END om_vld_org_id;

  PROCEDURE cascade_child(
    p_data_string      IN  varchar2,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_api_name             varchar2(30) := 'create_child';

    l_delimiter            char := ':';

    l_transaction_line_id  number;
    l_child_source_id      number;
    l_inventory_item_id    number;
    l_item_revision        varchar2(30);
    l_quantity_ratio       number;
    l_order_qty            number; --added for bug 5096435
    l_item_uom             varchar2(3);

    l_parent_source_table  varchar2(30);
    l_parent_source_id     number;

    l_txn_cascade_tbl      csi_t_utilities_pvt.txn_cascade_tbl;

    /* translate string parameters */

    l_loop_count           binary_integer;
    l_exit                 boolean;
    l_delimiter_position   binary_integer;
    l_new_string           varchar2(2000);
    l_value                varchar2(100);
    l_delimiter_count      number;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(512);
    l_msg_count            number;
    --declared for bug5096435
    l_model_qty            number;
    l_model_remnant_flag   varchar2(1) := 'N';
    l_sum_qty              number;
    l_link_to_line_id      number;

  BEGIN

    fnd_msg_pub.initialize;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => g_pkg_name);

    x_return_status := fnd_api.g_ret_sts_success;

    /* translate data string in to values */

    l_loop_count         := 0;
    l_exit               := FALSE;
    l_delimiter_position := 0;
    l_new_string         := p_data_string;

    l_delimiter_count    := delimiter_count(p_data_string => p_data_string);

    debug('  hierarchy_string    : '||p_data_string);
    debug('  delimiter_count     : '||l_delimiter_count);

    LOOP

      l_loop_count         := l_loop_count + 1;
      l_delimiter_position := instr(l_new_string, l_delimiter);

      IF l_delimiter_position = 0 THEN
        l_exit := TRUE;
        l_delimiter_position := length(l_new_string) + 1;
      END IF;

      l_value  := substr(l_new_string, 1, (l_delimiter_position-1));

      IF l_loop_count = 1 THEN
        l_parent_source_id     := l_value;

      END IF;

      IF l_loop_count = 2 THEN
        l_child_source_id      := l_value;
      END IF;

      IF l_loop_count = 3 THEN
        l_inventory_item_id    := l_value;
      END IF;

      --fix for bug5096435
      IF l_loop_count = 4 THEN

        IF l_delimiter_count = 6 THEN
          l_item_revision      := l_value;
        ELSE
          l_item_revision      := null;
          l_quantity_ratio     := l_value;
        END IF;

      END IF;

      IF l_loop_count = 5 THEN
        IF l_delimiter_count = 6 THEN
          l_quantity_ratio     := l_value;
        ELSE
          l_item_uom           := l_value;
        END IF;

      END IF;
      IF l_loop_count = 6 THEN
        IF l_delimiter_count = 6 THEN
          l_item_uom             := l_value;
        ELSE
          l_order_qty            := l_value;
        END IF;
      END IF;
      IF l_loop_count = 7 THEN
        IF l_delimiter_count = 6 THEN
          l_order_qty            := l_value;
        END IF;
      END IF; --end 0f fix of bug 5096435

      EXIT when l_exit = TRUE;

      l_new_string := substr(l_new_string, (l_delimiter_position + 1));

    END LOOP;

--fix for bug5096435
    BEGIN
	SELECT nvl(model_remnant_flag,'N'),ordered_quantity
	INTO l_model_remnant_flag,l_model_qty
	FROM oe_order_lines_all
	WHERE line_id=l_parent_source_id;
    EXCEPTION
    WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', l_parent_source_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;
    IF l_model_remnant_flag = 'Y' THEN
      BEGIN
        SELECT nvl(link_to_line_id,-99)
	INTO l_link_to_line_id
	FROM oe_order_lines_all
	WHERE line_id=l_child_source_id;
      EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', l_child_source_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END;
      IF l_link_to_line_id <> -99 THEN

	   SELECT SUM(ordered_quantity) INTO  l_sum_qty
           FROM oe_order_lines_all
           WHERE link_to_line_id = l_link_to_line_id
           AND inventory_item_id = l_inventory_item_id;

	  l_quantity_ratio := l_sum_qty/l_model_qty;
      ELSE
        fnd_message.set_name('CSI','CSI_OE_LINK_TO_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINK_TO_LINE_ID', l_child_source_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
 --end of fix for bug 5096435


    debug('    top_model_line_id : '|| l_parent_source_id);
    debug('    line_id           : '|| l_child_source_id);
    debug('    inventory_item_id : '|| l_inventory_item_id);
    debug('    revision          : '|| l_item_revision);
    debug('    Ordered Quantity  : '|| l_order_qty); --fix for bug5096435
    debug('    quantity_ratio    : '|| l_quantity_ratio);
    debug('    item_uom          : '|| l_item_uom);

    l_parent_source_table := 'OE_ORDER_LINES_ALL';

    l_txn_cascade_tbl(1).parent_source_table := l_parent_source_table;
    l_txn_cascade_tbl(1).parent_source_id    := l_parent_source_id;
    l_txn_cascade_tbl(1).child_source_id     := l_child_source_id;
    l_txn_cascade_tbl(1).inventory_item_id   := l_inventory_item_id;
    l_txn_cascade_tbl(1).item_revision       := l_item_revision;
    l_txn_cascade_tbl(1).ordered_quantity    := l_order_qty;  --fix for bug5096435
    l_txn_cascade_tbl(1).quantity_ratio      := l_quantity_ratio;
    l_txn_cascade_tbl(1).item_uom            := l_item_uom;

    csi_t_utilities_pvt.cascade(
      p_txn_cascade_tbl => l_txn_cascade_tbl,
      x_return_status   => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', 'Error in cascade_child: '||substr(sqlerrm, 1, 240));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END cascade_child;

  PROCEDURE cascade_model(
    p_model_line_id   IN  number,
    x_return_status   OUT NOCOPY varchar2)
  IS

    l_om_vld_org_id        number;
    l_model_line_rec       oe_order_lines_all%rowtype;
    l_line_tbl             oe_order_pub.line_tbl_type;
    l_qty_ratio            number;
    l_tc_ind               number;
    l_txn_cascade_tbl      csi_t_utilities_pvt.txn_cascade_tbl;

    l_api_name             varchar2(30) := 'cascade_model';
    l_debug_level          number;
    txn_dtls_not_found     exception;
    l_error_message        varchar2(255);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(512);
    l_msg_count            number;
    l_order_line_qty       number; --added for bug 5096435

  BEGIN

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    BEGIN

      SELECT * INTO l_model_line_rec
      FROM   oe_order_lines_all
      WHERE  line_id = p_model_line_id;

    EXCEPTION
      WHEN no_data_found THEN

        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_model_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

    END;

    dbms_application_info.set_client_info(l_model_line_rec.org_id);

    l_om_vld_org_id := oe_sys_parameters.value(
                        param_name => 'MASTER_ORGANIZATION_ID',
                        p_org_id   => l_model_line_rec.org_id);

    csi_order_fulfill_pub.get_all_ib_trackable_children(
      p_model_line_id      => p_model_line_id,
      p_om_vld_org_id      => l_om_vld_org_id,
      x_trackable_line_tbl => l_line_tbl,
      x_return_status      => l_return_status);

    l_tc_ind := 0;

    IF l_line_tbl.COUNT > 0 THEN

      FOR l_ind IN l_line_tbl.FIRST .. l_line_tbl.LAST
      LOOP
        --fix for bug 5096435
	--Here we ensure that for remnant lines we calculate ratio
	--by summing all order quantity of relevent order lines.
        IF l_line_tbl(l_ind).model_remnant_flag = 'Y' THEN
            BEGIN
            	select sum(ordered_quantity)
            	into l_order_line_qty
            	from oe_order_lines_all
            	where link_to_line_id = l_line_tbl(l_ind).link_to_line_id
            	and inventory_item_id = l_line_tbl(l_ind).inventory_item_id
            	and model_remnant_flag = 'Y';
            EXCEPTION
            WHEN others THEN
                NULL;
            END;
            l_qty_ratio := l_order_line_qty/l_model_line_rec.ordered_quantity;
        ELSE
        l_qty_ratio := l_line_tbl(l_ind).ordered_quantity/l_model_line_rec.ordered_quantity;
        END IF;

        l_tc_ind := l_tc_ind + 1;

        l_txn_cascade_tbl(l_tc_ind).parent_source_table := 'OE_ORDER_LINES_ALL';
        l_txn_cascade_tbl(l_tc_ind).parent_source_id    := p_model_line_id;
        l_txn_cascade_tbl(l_tc_ind).child_source_id     := l_line_tbl(l_ind).line_id;
	--fix for bug5096435:ordered_quantity is included to have better control of qty in cascade
	--api while cascading txn details from model line
	l_txn_cascade_tbl(l_tc_ind).ordered_quantity    := l_line_tbl(l_ind).ordered_quantity;
        l_txn_cascade_tbl(l_tc_ind).inventory_item_id   := l_line_tbl(l_ind).inventory_item_id;
        l_txn_cascade_tbl(l_tc_ind).item_revision       := l_line_tbl(l_ind).item_revision;
        l_txn_cascade_tbl(l_tc_ind).quantity_ratio      := l_qty_ratio;
        l_txn_cascade_tbl(l_tc_ind).item_uom            := l_line_tbl(l_ind).order_quantity_uom;

      END LOOP;

    END IF;

    csi_t_utilities_pvt.cascade(
      p_txn_cascade_tbl => l_txn_cascade_tbl,
      x_return_status   => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END cascade_model;


  /* CASCADE_TXN_DTLS */
  PROCEDURE cascade(
    p_txn_cascade_tbl IN  csi_t_utilities_pvt.txn_cascade_tbl,
    x_return_status   OUT NOCOPY varchar2)
  IS

    l_om_vld_org_id        number;
    l_src_txn_type_id      number;
    l_src_txn_hdr_id       number;
    l_chk_txn_line_rec     csi_t_datastructures_grp.txn_line_rec;

    l_td_found             boolean := FALSE;

    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_query_rec   csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_g_line_dtl_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl       csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_csi_ea_tbl         csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl    csi_t_datastructures_grp.txn_systems_tbl;

    l_c_td_ind             binary_integer;
    l_c_pt_ind             binary_integer;
    l_c_pa_ind             binary_integer;
    l_c_oa_ind             binary_integer;
    l_c_ea_ind             binary_integer;
    l_c_con_ind            binary_integer; -- Added for Bug 3648418 (Ref Bug 3605645)

    l_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;

    -- For Bug 3555078
    l_parent_line_rec      oe_order_pub.line_rec_type := oe_order_pub.g_miss_line_rec;
    l_no_trackable_parent  varchar2(1) := 'N';
    l_loop_quantity        number := 0;

    l_api_name             varchar2(30) := 'cascade';
    l_debug_level          number;
    txn_dtls_not_found     exception;
    l_error_message        varchar2(255);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(512);
    l_msg_count            number;

     --parent-child cascading for remnant 4344316
    l_non_ib_mdl_qty       number;
    l_rem_qty		   number := 0; --added for bug5096435
  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => g_pkg_name);

    IF p_txn_cascade_tbl.COUNT > 0 THEN

      -- get_transaction_dtls
      l_txn_line_query_rec.source_transaction_table := p_txn_cascade_tbl(1).parent_source_table;
      l_txn_line_query_rec.source_transaction_id    := p_txn_cascade_tbl(1).parent_source_id;

      l_txn_line_detail_query_rec.source_transaction_flag := 'Y';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_txn_line_query_rec        => l_txn_line_query_rec,
        p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
        x_txn_line_detail_tbl       => l_g_line_dtl_tbl,
        p_get_parties_flag          => fnd_api.g_true,
        x_txn_party_detail_tbl      => l_g_pty_dtl_tbl,
        p_get_pty_accts_flag        => fnd_api.g_true,
        x_txn_pty_acct_detail_tbl   => l_g_pty_acct_tbl,
        p_get_ii_rltns_flag         => fnd_api.g_false,
        x_txn_ii_rltns_tbl          => l_g_ii_rltns_tbl,
        p_get_org_assgns_flag       => fnd_api.g_true,
        x_txn_org_assgn_tbl         => l_g_org_assgn_tbl,
        p_get_ext_attrib_vals_flag  => fnd_api.g_false,
        x_txn_ext_attrib_vals_tbl   => l_g_ext_attrib_tbl,
        p_get_csi_attribs_flag      => fnd_api.g_false,
        x_csi_ext_attribs_tbl       => l_g_csi_ea_tbl,
        p_get_csi_iea_values_flag   => fnd_api.g_false,
        x_csi_iea_values_tbl        => l_g_csi_eav_tbl,
        p_get_txn_systems_flag      => fnd_api.g_false,
        x_txn_systems_tbl           => l_g_txn_systems_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_g_line_dtl_tbl.count = 0 THEN
        RAISE txn_dtls_not_found;
      END IF;

      SELECT source_transaction_type_id,
             source_txn_header_id
      INTO   l_src_txn_type_id,
             l_src_txn_hdr_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table = p_txn_cascade_tbl(1).parent_source_table
      AND    source_transaction_id    = p_txn_cascade_tbl(1).parent_source_id;

      /* for each of the order line children create transaction detail */

      FOR l_ind IN p_txn_cascade_tbl.FIRST .. p_txn_cascade_tbl.LAST
      LOOP


        /* check if transaction details exist for this child */

        l_chk_txn_line_rec.source_transaction_table := p_txn_cascade_tbl(l_ind).parent_source_table;
        l_chk_txn_line_rec.source_transaction_id    := p_txn_cascade_tbl(l_ind).child_source_id;

        l_td_found := csi_t_txn_details_pvt.check_txn_details_exist(
                        p_txn_line_rec => l_chk_txn_line_rec);
        l_rem_qty   := p_txn_cascade_tbl(l_ind).ordered_quantity; --added for bug 5096435

        IF NOT (l_td_found) THEN

          l_txn_line_rec.transaction_line_id        := fnd_api.g_miss_num;
          l_txn_line_rec.source_transaction_table   := p_txn_cascade_tbl(l_ind).parent_source_table;
          l_txn_line_rec.source_transaction_id      := p_txn_cascade_tbl(l_ind).child_source_id;
          l_txn_line_rec.source_transaction_type_id := l_src_txn_type_id;
          l_txn_line_rec.source_txn_header_id       := l_src_txn_hdr_id;
          l_txn_line_rec.processing_status          := 'SUBMIT';

          l_c_td_ind := 0;
          l_c_pt_ind := 0;
          l_c_pa_ind := 0;
          l_c_oa_ind := 0;
          l_c_ea_ind := 0;
          l_c_con_ind := 0; -- Added for Bug 3648418 (Ref Bug 3605645)

          l_om_vld_org_id := om_vld_org_id(p_txn_cascade_tbl(1).child_source_id);

          --    Begin fix for Bug 3555078
          csi_order_fulfill_pub.get_ib_trackable_parent(
            p_current_line_id   => p_txn_cascade_tbl(1).child_source_id,
            p_om_vld_org_id     => l_om_vld_org_id,
            x_parent_line_rec   => l_parent_line_rec,
            x_return_status     => l_return_status);

          If nvl(l_parent_line_rec.line_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
          Then
             l_no_trackable_parent := 'Y';
          End If;
          --    End fix for Bug 3555078

          FOR l_td_ind IN l_g_line_dtl_tbl.FIRST .. l_g_line_dtl_tbl.LAST
          LOOP
	    IF l_rem_qty <= 0 THEN --fix for bug 5096435
                EXIT;
            END IF;
            -- Begin Fix for Bug 3555078
            IF l_no_trackable_parent = 'Y'
            Then
               l_loop_quantity := 1;
            Else
	       --Start 4344316
	       IF l_g_line_dtl_tbl(l_td_ind).quantity > l_parent_line_rec.ordered_quantity Then
		 l_loop_quantity := l_parent_line_rec.ordered_quantity;
               ELSE
		 l_loop_quantity := l_g_line_dtl_tbl(l_td_ind).quantity;
	       END IF;
	       --End 4344316
            End If;
            -- End fix for Bug 3555078




            FOR i in 1..l_loop_quantity -- l_g_line_dtl_tbl(l_td_ind).quantity
            LOOP
            IF l_rem_qty <= 0 THEN --fix for bug 5096435
                EXIT;
            END IF;

	    l_c_td_ind := l_c_td_ind + 1;

            l_line_dtl_tbl(l_c_td_ind)          := l_g_line_dtl_tbl(l_td_ind);

            -- Begin Fix for Bug 3555078
            -- l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio;
         /*   IF l_no_trackable_parent = 'Y'
            Then
              l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio * l_g_line_dtl_tbl(l_td_ind).quantity;
            ELSE
              l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio;
            END IF;*/
            -- End fix for Bug 3555078

               --Start 4344316
         IF l_no_trackable_parent = 'N'
            THEN
		IF l_rem_qty <= p_txn_cascade_tbl(l_ind).quantity_ratio THEN --fix for bug 5096435
		    l_line_dtl_tbl(l_c_td_ind).quantity := l_rem_qty;
	        ELSE
		    l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio;
	        END IF;
            ELSE
	      BEGIN
	        select nvl(ordered_quantity,0) INTO l_non_ib_mdl_qty
		FROM oe_order_lines_all
		WHERE line_id = p_txn_cascade_tbl(1).parent_source_id;
	        IF l_rem_qty <= p_txn_cascade_tbl(l_ind).quantity_ratio THEN --fix for bug 5096435
		   l_line_dtl_tbl(l_c_td_ind).quantity := l_rem_qty;
                ELSE
                If l_g_line_dtl_tbl(l_td_ind).quantity > l_non_ib_mdl_qty Then
                  l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio * l_non_ib_mdl_qty;
                Else
                  l_line_dtl_tbl(l_c_td_ind).quantity := p_txn_cascade_tbl(l_ind).quantity_ratio * l_g_line_dtl_tbl(l_td_ind).quantity;
                End If;
		End If;
              EXCEPTION
                 WHEN no_data_found THEN
		     fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
		     fnd_message.set_token('OE_LINE_ID', p_txn_cascade_tbl(1).parent_source_id);
		     fnd_msg_pub.add;
		     RAISE fnd_api.g_exc_error;
   	      END;
            END IF;
                     --Start 4344316
            l_rem_qty   := l_rem_qty - l_line_dtl_tbl(l_c_td_ind).quantity; --fix for bug5096435
            l_line_dtl_tbl(l_c_td_ind).transaction_line_id := fnd_api.g_miss_num;
            l_line_dtl_tbl(l_c_td_ind).txn_line_detail_id  := fnd_api.g_miss_num;
            l_line_dtl_tbl(l_c_td_ind).inventory_item_id   :=
                                       p_txn_cascade_tbl(l_ind).inventory_item_id;
            l_line_dtl_tbl(l_c_td_ind).unit_of_measure     := p_txn_cascade_tbl(l_ind).item_uom;
            l_line_dtl_tbl(l_c_td_ind).inventory_revision  := p_txn_cascade_tbl(l_ind).item_revision;
            l_line_dtl_tbl(l_c_td_ind).csi_transaction_id  := fnd_api.g_miss_num;
            l_line_dtl_tbl(l_c_td_ind).processing_status   := 'SUBMIT';
            l_line_dtl_tbl(l_c_td_ind).instance_exists_flag := 'N';
            l_line_dtl_tbl(l_c_td_ind).instance_id          := fnd_api.g_miss_num;
            l_line_dtl_tbl(l_c_td_ind).source_txn_line_detail_id  :=
              l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id;
            l_line_dtl_tbl(l_c_td_ind).changed_instance_id  := fnd_api.g_miss_num;

            -- Fix for Bug 2962072 included to Null out Version_Label.
            l_line_dtl_tbl(l_c_td_ind).version_label := fnd_api.g_miss_char;

            -- derive the item related attributes here

            IF l_g_pty_dtl_tbl.COUNT > 0 THEN
              FOR l_pt_ind IN l_g_pty_dtl_tbl.FIRST .. l_g_pty_dtl_tbl.LAST
              LOOP

                IF l_g_pty_dtl_tbl(l_pt_ind).txn_line_detail_id = l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id
                  AND
                   l_g_pty_dtl_tbl(l_pt_ind).Contact_FLAG ='N' -- Added the condition for Bug 3648418 (Ref Bug 3605645)
                THEN

                  l_c_pt_ind := l_c_pt_ind + 1;

                  l_pty_dtl_tbl(l_c_pt_ind) := l_g_pty_dtl_tbl(l_pt_ind);
                  l_pty_dtl_tbl(l_c_pt_ind).txn_line_detail_id  := fnd_api.g_miss_num;
                  l_pty_dtl_tbl(l_c_pt_ind).txn_party_detail_id := fnd_api.g_miss_num;
                  l_pty_dtl_tbl(l_c_pt_ind).txn_line_details_index := l_c_td_ind;
                  l_pty_dtl_tbl(l_c_pt_ind).instance_party_id      := fnd_api.g_miss_num;
                  l_c_con_ind := l_c_pt_ind; -- Added for Bug 3648418 (Ref Bug 3605645), Trapping index for Party in context

                  -- For Bug 3524837
                  /*-- Creating index for contact parties --*/
                  /* Begin fix for Bug 3648418 (Ref Bug 3605645)
                  IF NVL(l_pty_dtl_tbl(l_c_pt_ind).contact_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                   THEN
                    FOR l_con_pt_ind in l_g_pty_dtl_tbl.FIRST .. l_g_pty_dtl_tbl.LAST
                    LOOP
                       IF l_g_pty_dtl_tbl(l_con_pt_ind).txn_party_detail_id = l_pty_dtl_tbl(l_c_pt_ind).contact_party_id
                       THEN
                         l_pty_dtl_tbl(l_c_pt_ind).contact_party_id := l_con_pt_ind;
                      END IF;
                    END LOOP;
                  END IF;
                  */
                  FOR l_con_pt_ind in l_g_pty_dtl_tbl.FIRST .. l_g_pty_dtl_tbl.LAST
                  LOOP
                    IF l_g_pty_dtl_tbl(l_con_pt_ind).txn_line_detail_id = l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id
                      AND
                       NVL(l_g_pty_dtl_tbl(l_con_pt_ind).contact_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                      AND
                       l_g_pty_dtl_tbl(l_pt_ind).txn_party_detail_id = l_g_pty_dtl_tbl(l_con_pt_ind).contact_party_id
                    THEN
                      l_c_pt_ind := l_c_pt_ind + 1;
                      l_pty_dtl_tbl(l_c_pt_ind) := l_g_pty_dtl_tbl(l_con_pt_ind);
                      l_pty_dtl_tbl(l_c_pt_ind).txn_line_detail_id  := fnd_api.g_miss_num;
                      l_pty_dtl_tbl(l_c_pt_ind).txn_party_detail_id := fnd_api.g_miss_num;
                      l_pty_dtl_tbl(l_c_pt_ind).txn_line_details_index := l_c_td_ind;
                      l_pty_dtl_tbl(l_c_pt_ind).instance_party_id      := fnd_api.g_miss_num;
                      l_pty_dtl_tbl(l_c_pt_ind).contact_party_id := l_c_con_ind;
                    END IF;
                  END LOOP;
                  -- End fix for Bug 3648418 (Ref Bug 3605645)

                  IF l_g_pty_acct_tbl.COUNT > 0 THEN

                    FOR l_pa_ind IN l_g_pty_acct_tbl.FIRST .. l_g_pty_acct_tbl.LAST
                    LOOP
                      IF l_g_pty_acct_tbl(l_pa_ind).txn_party_detail_id =
                         l_g_pty_dtl_tbl(l_pt_ind).txn_party_detail_id THEN

                        l_c_pa_ind := l_c_pa_ind + 1;

                        l_pty_acct_tbl(l_c_pa_ind) := l_g_pty_acct_tbl(l_pa_ind);
                        l_pty_acct_tbl(l_c_pa_ind).txn_party_detail_id     := fnd_api.g_miss_num;
                        l_pty_acct_tbl(l_c_pa_ind).txn_account_detail_id   := fnd_api.g_miss_num;
                        l_pty_acct_tbl(l_c_pa_ind).txn_party_details_index := l_c_con_ind; -- l_c_pt_ind Changed for Bug 3648418 (Ref Bug 3605645)
                        l_pty_acct_tbl(l_c_pa_ind).ip_account_id           := fnd_api.g_miss_num;

                      END IF; -- pty acct detail id chk

                    END LOOP; -- party acct table loop

                  END IF; -- party acct count chk

                END IF; -- txn_line_detail_id check

              END LOOP; -- party table loop

            END IF; -- party count check

            IF l_g_org_assgn_tbl.COUNT > 0 THEN
              FOR l_oa_ind IN l_g_org_assgn_tbl.FIRST .. l_g_org_assgn_tbl.LAST
              LOOP
                IF l_g_org_assgn_tbl(l_oa_ind).txn_line_detail_id =
                   l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id THEN

                  l_c_oa_ind := l_c_oa_ind + 1;
                  l_org_assgn_tbl(l_c_oa_ind) := l_g_org_assgn_tbl(l_oa_ind);
                  l_org_assgn_tbl(l_c_oa_ind).txn_line_detail_id    := fnd_api.g_miss_num;
                  l_org_assgn_tbl(l_c_oa_ind).txn_operating_unit_id := fnd_api.g_miss_num;
                  l_org_assgn_tbl(l_c_oa_ind).txn_line_details_index := l_c_td_ind;
                  l_org_assgn_tbl(l_c_oa_ind).instance_ou_id         := fnd_api.g_miss_num;

                END IF;
              END LOOP;
            END IF;

            IF l_g_ext_attrib_tbl.COUNT > 0 THEN
              FOR l_ea_ind IN l_g_ext_attrib_tbl.FIRST .. l_g_ext_attrib_tbl.LAST
              LOOP
                IF l_g_ext_attrib_tbl(l_ea_ind).txn_line_detail_id =
                   l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id THEN

                  l_c_ea_ind := l_c_ea_ind + 1;
                  l_ext_attrib_tbl(l_c_ea_ind) := l_g_ext_attrib_tbl(l_ea_ind);
                  l_ext_attrib_tbl(l_c_ea_ind).txn_line_detail_id := fnd_api.g_miss_num;
                  l_ext_attrib_tbl(l_c_ea_ind).txn_attrib_detail_id := fnd_api.g_miss_num;
                  l_ext_attrib_tbl(l_c_ea_ind).txn_line_details_index := l_c_td_ind;

                END IF;
              END LOOP;
            END IF;
            END LOOP;

          END LOOP; -- txn line details loop

          -- create transaction dtls
          csi_t_txn_details_grp.create_transaction_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            px_txn_line_rec            => l_txn_line_rec,
            px_txn_line_detail_tbl     => l_line_dtl_tbl,
            px_txn_party_detail_tbl    => l_pty_dtl_tbl,
            px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
            px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
            px_txn_org_assgn_tbl       => l_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
            px_txn_systems_tbl         => l_txn_systems_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

          /* clean up the pl/sql tables */
          l_line_dtl_tbl.DELETE;
          l_pty_dtl_tbl.DELETE;
          l_pty_acct_tbl.DELETE;
          l_ii_rltns_tbl.DELETE;
          l_org_assgn_tbl.DELETE;
          l_ext_attrib_tbl.DELETE;
          l_txn_systems_tbl.DELETE;

        ELSE
          debug('txn dtls found for the child '||p_txn_cascade_tbl(l_ind).child_source_id);
        END IF; -- td found for the children chk

      END LOOP;-- children line table loop

    END IF; -- children line table count chk

  EXCEPTION

    WHEN txn_dtls_not_found THEN
     x_return_status := fnd_api.g_ret_sts_success;
    WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;

  END cascade;

END csi_t_utilities_pvt;

/
