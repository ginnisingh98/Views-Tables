--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_DETAILS_PVT" as
/* $Header: csivttxb.pls 120.12.12000000.3 2007/06/12 09:48:46 smrsharm ship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_details_pvt';
  g_file_name   CONSTANT VARCHAR2(12) := 'csivttxb.pls';

  g_user_id              NUMBER := fnd_global.user_id;
  g_login_id             NUMBER := fnd_global.login_id;


  PROCEDURE debug(
    p_message in varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  FUNCTION check_txn_details_exist(
    p_txn_line_rec  IN  csi_t_datastructures_grp.txn_line_rec)
  RETURN BOOLEAN
  IS
    l_debug_level        number;
    l_api_name           varchar2(30) := 'check_txn_details_exist';
    l_txn_line_query_rec csi_t_datastructures_grp.txn_line_query_rec;
    l_found              BOOLEAN := FALSE;
    l_select_stmt        varchar2(4000);
    l_lines_where_clause varchar2(2000);
    l_cursor_id          integer;
    l_processed_rows     number := 0;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    l_lines_restrict     varchar2(1) := 'N';
    l_value number;

  BEGIN

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 THEN
      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_txn_line_rec);
    END IF;

    l_txn_line_query_rec.transaction_line_id      := p_txn_line_rec.transaction_line_id;
    l_txn_line_query_rec.source_txn_header_id     := p_txn_line_rec.source_txn_header_id;
    l_txn_line_query_rec.source_transaction_id    := p_txn_line_rec.source_transaction_id;
    l_txn_line_query_rec.source_transaction_table := p_txn_line_rec.source_transaction_table;
    l_txn_line_query_rec.processing_status        := p_txn_line_rec.processing_status;

    csi_t_txn_line_dtls_pvt.build_txn_lines_select(
      p_txn_line_query_rec => l_txn_line_query_rec,
      x_lines_select_stmt  => l_lines_where_clause,
      x_lines_restrict     => l_lines_restrict,
      x_return_status      => l_return_status);

    IF l_lines_restrict = 'Y' THEN
      l_select_stmt :=
        'select 1 l_value from csi_t_transaction_lines where '||l_lines_where_clause;

      IF l_debug_level > 10 THEN
        csi_t_gen_utility_pvt.add('  Select Stmt:'||l_select_stmt);
      END IF;

      l_cursor_id := dbms_sql.open_cursor;

      dbms_sql.parse(l_cursor_id, l_select_stmt , dbms_sql.native);

      IF nvl(l_txn_line_query_rec.transaction_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
        dbms_sql.bind_variable(l_cursor_id, 'transaction_line_id',
                                            l_txn_line_query_rec.transaction_line_id);
      END IF;

      IF nvl(l_txn_line_query_rec.source_txn_header_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
        dbms_sql.bind_variable(l_cursor_id, 'source_txn_header_id',
                                            l_txn_line_query_rec.source_txn_header_id);
      END IF;

      IF nvl(l_txn_line_query_rec.source_transaction_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
        dbms_sql.bind_variable(l_cursor_id, 'source_transaction_id',
                                            l_txn_line_query_rec.source_transaction_id);
      END IF;

      IF nvl(l_txn_line_query_rec.source_transaction_table, fnd_api.g_miss_char) <> fnd_api.g_miss_char
      THEN
        dbms_sql.bind_variable(l_cursor_id, 'source_transaction_table',
                                            l_txn_line_query_rec.source_transaction_table);
      END IF;

      IF nvl(l_txn_line_query_rec.processing_status, fnd_api.g_miss_char) <> fnd_api.g_miss_char
      THEN
        dbms_sql.bind_variable(l_cursor_id, 'processing_status',
                                            l_txn_line_query_rec.processing_status);
      END IF;

      dbms_sql.define_column(l_cursor_id,1,l_value);

      l_processed_rows := dbms_sql.execute(l_cursor_id);

      LOOP
        exit when dbms_sql.fetch_rows(l_cursor_id) = 0;
        l_found := TRUE;
        dbms_sql.column_value(l_cursor_id,1,l_value);
      END LOOP;

      dbms_sql.close_cursor(l_cursor_id);

    END IF;

    csi_t_gen_utility_pvt.set_debug_off;

    IF l_found THEN
      debug('Transaction Details found.');
    ELSE
      debug('Transaction Details not found.');
    END IF;

    return l_found;

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_cursor_id) THEN
       dbms_sql.close_cursor(l_cursor_id);
     END IF;
     return false;

  END check_txn_details_exist;

  PROCEDURE create_transaction_dtls(
    p_api_version              IN     NUMBER,
    p_commit                   IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list            IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level         IN     NUMBER   := fnd_api.g_valid_level_full,
    p_split_source_flag        IN     VARCHAR2 := fnd_api.g_false,
    px_txn_line_rec            IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2)
  IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'create_transaction_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);

    l_td_found                     char;
    l_txn_line_id                  NUMBER;
    l_txn_line_rec                 csi_t_datastructures_grp.txn_line_rec;
    l_line_dtl_rec                 csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_ii_rltns_rec             csi_t_datastructures_grp.txn_ii_rltns_rec;

    l_txn_system_rec               csi_t_datastructures_grp.txn_system_rec;
    l_txn_system_id                NUMBER;

    l_txn_source_name              csi_txn_types.source_transaction_type%type;
    l_obj_tld_id                   NUMBER ;
    l_sub_instance_id              NUMBER ;
    l_sub_tld_id                   NUMBER ;
    l_obj_instance_id              NUMBER ;
    l_s_index                      NUMBER ;
    l_skip_tl_create               varchar2(1) := 'N';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_transaction_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 then

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => px_txn_line_rec);

    END IF;

    -- Main API code starts here
    -- Added for CZ Integration (Begin)
    IF px_txn_line_rec.source_transaction_type_id = 401 THEN
      IF px_txn_line_rec.source_transaction_table <> 'WSH_DELIVERY_DETAILS' THEN --Added for bug5194812
        SELECT csi_t_transaction_lines_s2.nextval
        INTO   px_txn_line_rec.source_transaction_id
        FROM   dual;
        px_txn_line_rec.source_transaction_table := 'CONFIGURATOR' ; --????
      END IF;--Added for bug5194812
    END IF ;

    -- check for the required parameters
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => px_txn_line_rec.source_transaction_table,
      p_param_name  => 'px_txn_line_rec.source_transaction_table',
      p_api_name    => l_api_name);

    IF px_txn_line_rec.source_transaction_type_id <> 401 THEN
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => px_txn_line_rec.source_transaction_id,
      p_param_name  => 'px_txn_line_rec.source_transaction_id',
      p_api_name    => l_api_name);

    END IF;

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => px_txn_line_rec.source_transaction_type_id,
      p_param_name  => 'px_txn_line_rec.source_transaction_type_id',
      p_api_name    => l_api_name);

    -- duplicate check(will have to move to the validation routines)
    IF nvl(px_txn_line_rec.transaction_line_id, fnd_api.g_miss_num)  <> fnd_api.g_miss_num THEN
      BEGIN
        SELECT 'Y' INTO l_skip_tl_create
        FROM   csi_t_transaction_lines
        WHERE  transaction_line_id = px_txn_line_rec.transaction_line_id;
      EXCEPTION
        WHEN no_data_found THEN
          l_skip_tl_create := 'N';
      END;
    END IF;

    IF l_skip_tl_create <> 'Y' AND
 	        px_txn_line_rec.source_transaction_type_id <> 401  THEN
      csi_t_vldn_routines_pvt.check_duplicate(
        p_txn_line_rec  => px_txn_line_rec,
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_DETAIL_DUPLICATE');
        FND_MESSAGE.set_token('SRC_TABLE',px_txn_line_rec.source_transaction_table);
        FND_MESSAGE.set_token('SRC_ID',px_txn_line_rec.source_transaction_id);
        FND_MSG_PUB.add;

        RAISE FND_API.g_exc_error;

      END IF;
    END IF;

    -- Added for CZ Integration  (Begin)
    -- validate against CZ view
    IF NVL(px_txn_line_rec.config_session_hdr_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN
      csi_t_gen_utility_pvt.add('Validating against CZ view ');
      csi_t_vldn_routines_pvt.check_cz_session_keys(
        p_config_session_hdr_id  => px_txn_line_rec.config_session_hdr_id,
        p_config_session_rev_num => px_txn_line_rec.config_session_rev_num,
        p_config_session_item_id => px_txn_line_rec.config_session_item_id,
        x_return_status          => l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.g_exc_error;
      END IF;

      csi_t_vldn_routines_pvt.check_exists_in_cz(
        p_txn_line_dtl_tbl  => px_txn_line_detail_tbl,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.g_exc_error;
      END IF;
    END IF ; ---px_txn_line_rec.source_transaction_type_id=401
    -- Added for CZ Integration  (End)

    -- mandatory entities check

    IF p_validation_level = fnd_api.g_valid_level_full THEN

      IF px_txn_line_detail_tbl.COUNT = 0 THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_MISSING_ENTITY');
        FND_MESSAGE.set_token('ENTITY','Line Detail Info');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;

      END IF;

    END IF;

    /* this condition is used only for the interface program  */
    IF p_split_source_flag = fnd_api.g_false THEN

      IF p_validation_level = fnd_api.g_valid_level_full THEN

       -- business object validations
       -- Added for CZ Integration
       -- Bypass this check for Configurator, Mass edit as it is for OM.
       IF px_txn_line_rec.source_transaction_type_id not in (401,3)
       THEN
        csi_t_gen_utility_pvt.add('Validating source integrity.');

        csi_t_vldn_routines_pvt.check_source_integrity(
          p_validation_level  => p_validation_level,
          p_txn_line_rec      => px_txn_line_rec,
          p_txn_line_dtl_tbl  => px_txn_line_detail_tbl,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        csi_t_gen_utility_pvt.add('Validating party integrity.');

        csi_t_vldn_routines_pvt.check_party_integrity(
          p_txn_line_rec       => px_txn_line_rec,
          p_txn_line_dtl_tbl   => px_txn_line_detail_tbl,
          p_party_dtl_tbl      => px_txn_party_detail_tbl,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        -- end of business object validation
        csi_t_gen_utility_pvt.add('End of business object validations.');

       END IF ; ---<>401,3
      END IF;

      IF nvl(px_txn_line_rec.transaction_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_txn_line_id := px_txn_line_rec.transaction_line_id;
      END IF;


      IF l_skip_tl_create <> 'Y' THEN
        -- call table handler to populate the csi_t_transaction_lines table

        csi_t_gen_utility_pvt.dump_api_info(
          p_api_name => 'insert_row',
          p_pkg_name => 'csi_t_transaction_lines_pkg');

        BEGIN

          -- Added for CZ Integration (End)
          csi_t_transaction_lines_pkg.insert_row(
            px_transaction_line_id     => l_txn_line_id,
            p_source_transaction_type_id => px_txn_line_rec.source_transaction_type_id,
            p_source_transaction_table => px_txn_line_rec.source_transaction_table,
            p_source_txn_header_id     => px_txn_line_rec.source_txn_header_id,
            p_source_transaction_id    => px_txn_line_rec.source_transaction_id,
            -- Added for CZ Integration (Begin)
            p_config_session_hdr_id  => px_txn_line_rec.config_session_hdr_id ,
            p_config_session_rev_num  => px_txn_line_rec.config_session_rev_num ,
            p_config_session_item_id  => px_txn_line_rec.config_session_item_id ,
            p_config_valid_status  => px_txn_line_rec.config_valid_status ,
            p_source_transaction_status  => px_txn_line_rec.source_transaction_status ,
            -- Added for CZ Integration (End)
            p_error_code               => px_txn_line_rec.error_code,
            p_error_explanation        => px_txn_line_rec.error_explanation,
            p_processing_status        => 'SUBMIT',
            p_attribute1               => px_txn_line_rec.attribute1,
            p_attribute2               => px_txn_line_rec.attribute2,
            p_attribute3               => px_txn_line_rec.attribute3,
            p_attribute4               => px_txn_line_rec.attribute4,
            p_attribute5               => px_txn_line_rec.attribute5,
            p_attribute6               => px_txn_line_rec.attribute6,
            p_attribute7               => px_txn_line_rec.attribute7,
            p_attribute8               => px_txn_line_rec.attribute8,
            p_attribute9               => px_txn_line_rec.attribute9,
            p_attribute10              => px_txn_line_rec.attribute10,
            p_attribute11              => px_txn_line_rec.attribute11,
            p_attribute12              => px_txn_line_rec.attribute12,
            p_attribute13              => px_txn_line_rec.attribute13,
            p_attribute14              => px_txn_line_rec.attribute14,
            p_attribute15              => px_txn_line_rec.attribute15,
            p_created_by               => g_user_id,
            p_creation_date            => sysdate,
            p_last_updated_by          => g_user_id,
            p_last_update_date         => sysdate,
            p_last_update_login        => g_login_id,
            p_object_version_number    => 1.0,
            p_context                  => px_txn_line_rec.context);

        EXCEPTION
          WHEN others THEN
           fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
           fnd_message.set_token('MESSAGE','insert_row failed '||sqlerrm);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
        END;

      END IF;

      px_txn_line_rec.transaction_line_id := l_txn_line_id;

      IF px_txn_systems_tbl.COUNT > 0 THEN
        FOR l_ind in px_txn_systems_tbl.FIRST..px_txn_systems_tbl.LAST
        LOOP

          l_txn_system_rec := px_txn_systems_tbl(l_ind);
          l_txn_system_rec.transaction_line_id  := l_txn_line_id;

          csi_t_txn_systems_grp.create_txn_system(
            p_api_version      => p_api_version,
            p_commit           => p_commit,
            p_init_msg_list    => p_init_msg_list,
            p_validation_level => p_validation_level,
            p_txn_system_rec   => l_txn_system_rec,
            x_txn_system_id    => l_txn_system_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('FND','FND_GENERIC_MESSAGE');
            FND_MESSAGE.set_token('MESSAGE',
                       'csi_t_txn_systems_grp.create_txn_system API failed.');
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;
          END IF;

          px_txn_systems_tbl(l_ind).transaction_line_id   := l_txn_line_id;
          px_txn_systems_tbl(l_ind).transaction_system_id := l_txn_system_id;

        END LOOP;

      END IF;

    ELSE
      l_txn_line_id := px_txn_line_rec.transaction_line_id;
    END IF;

    IF px_txn_line_detail_tbl.count > 0 THEN

      -- loop through txn_line_details table
      FOR l_index IN  px_txn_line_detail_tbl.FIRST..px_txn_line_detail_tbl.LAST
      LOOP

        l_line_dtl_rec := px_txn_line_detail_tbl(l_index);
        l_line_dtl_rec.transaction_line_id  := l_txn_line_id;
        --Following IF has been added as part of changes for bug 3600950
        IF l_line_dtl_rec.source_transaction_flag = 'N' THEN
         IF nvl(l_line_dtl_rec.assc_txn_line_detail_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
           l_s_index := l_line_dtl_rec.assc_txn_line_detail_id;
           debug('IB Transaction type id referenced, Non-Source: '|| l_line_dtl_rec.sub_type_id
                  ||' Source: '|| px_txn_line_detail_tbl(l_s_index).sub_type_id);
           -- assigning the sub_type_id from Source to Non-source
           l_line_dtl_rec.sub_type_id := px_txn_line_detail_tbl(l_s_index).sub_type_id;
           IF nvl(px_txn_line_detail_tbl(l_s_index).txn_line_detail_id, fnd_api.g_miss_num)
              <> fnd_api.g_miss_num THEN
                l_line_dtl_rec.assc_txn_line_detail_id :=
                px_txn_line_detail_tbl(l_s_index).txn_line_detail_id;
           END IF;
         END IF;
        END IF;

        IF nvl(l_line_dtl_rec.txn_systems_index, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          -- convert txn_systems_index in to txn_system_id
          csi_t_vldn_routines_pvt.get_txn_system_id(
            p_txn_systems_index  => l_line_dtl_rec.txn_systems_index,
            p_txn_systems_tbl    => px_txn_systems_tbl,
            x_txn_system_id      => l_line_dtl_rec.transaction_system_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('FND','FND_GENERIC_MESSAGE');
            FND_MESSAGE.set_token('MESSAGE','Failed to convert txn system index to ID');
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;

          END IF;

        END IF;

/* Adding this IF piece so that the API will default value for this based on the value for instance id column - shegde*/

	IF ( l_line_dtl_rec.instance_id <> fnd_api.g_miss_num
	   AND l_line_dtl_rec.instance_id is NOT NULL ) THEN
		l_line_dtl_rec.instance_exists_flag := 'Y';
	ELSE
		l_line_dtl_rec.instance_exists_flag := 'N';
	END IF;

        -- call api to create the transaction line details
        csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
          p_api_version               => p_api_version,
          p_commit                    => p_commit,
          p_init_msg_list             => p_init_msg_list,
          p_validation_level          => p_validation_level,
          p_txn_line_dtl_index        => l_index,
          p_txn_line_dtl_rec          => l_line_dtl_rec,
          px_txn_party_dtl_tbl        => px_txn_party_detail_tbl,
          px_txn_pty_acct_detail_tbl  => px_txn_pty_acct_detail_tbl,
          px_txn_ii_rltns_tbl         => px_txn_ii_rltns_tbl,
          px_txn_org_assgn_tbl        => px_txn_org_assgn_tbl,
          px_txn_ext_attrib_vals_tbl  => px_txn_ext_attrib_vals_tbl,
          x_return_status             => l_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

        px_txn_line_detail_tbl(l_index).transaction_line_id :=
           l_line_dtl_rec.transaction_line_id;
        px_txn_line_detail_tbl(l_index).txn_line_detail_id :=
           l_line_dtl_rec.txn_line_detail_id;

      END LOOP;

      /* I have to do the relationship create after completing the creation
         of transaction details record. This is to translate the object and
         subject ids has to be translated to txn_line_detail_id s before
         storing in to the database. The caller will pass the object and the
         subject ids as the index reference of the txn line detail pl/sql
         table (cos he does not have the txn_line_detail_id at the time of
         calling the api). txn_line_detail_id gets generated at the time of
         actual call to the table handler within the api
      */

-- Added for CZ Integration (Begin)
    IF px_txn_ii_rltns_tbl.COUNT > 0
    THEN
      FOR i IN px_txn_ii_rltns_tbl.FIRST .. px_txn_ii_rltns_tbl.LAST
      LOOP
        l_sub_instance_id := NULL ;
        l_sub_tld_id   := NULL ;
        IF (NVL(px_txn_ii_rltns_tbl(i).sub_config_inst_hdr_id , fnd_api.g_miss_num)
                <>  fnd_api.g_miss_num
           AND NVL(px_txn_ii_rltns_tbl(i).subject_id, fnd_api.g_miss_num)
              = fnd_api.g_miss_num)
        THEN
          -- Now assuming that user is passing only config keys , get the associated instance/txn_detail_line.

          csi_t_gen_utility_pvt.add('Calling get_cz_inst_or_tld_id for subject ');
          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => px_txn_ii_rltns_tbl(i).sub_config_inst_hdr_id,
          p_config_inst_rev_num      => px_txn_ii_rltns_tbl(i).sub_config_inst_rev_num,
          p_config_inst_item_id      => px_txn_ii_rltns_tbl(i).sub_config_inst_item_id ,
          x_instance_id              => l_sub_instance_id  ,
          x_txn_line_detail_id       => l_sub_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_sub_instance_id IS NULL
             AND l_sub_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_sub_instance_id IS NOT NULL
          THEN
             px_txn_ii_rltns_tbl(i).subject_id := l_sub_instance_id;
             px_txn_ii_rltns_tbl(i).subject_type := 'I' ;
          ELSIF l_sub_tld_id IS NOT NULL
          THEN
             px_txn_ii_rltns_tbl(i).subject_id := l_sub_tld_id;
             px_txn_ii_rltns_tbl(i).subject_type := 'T' ;
             px_txn_ii_rltns_tbl(i).subject_index_flag := 'N' ;
          END IF ;
          csi_t_gen_utility_pvt.add('tld/instance id for subject ' || l_sub_instance_id || l_sub_tld_id);
        END IF ; ---Subject_id is NULL

        IF (NVL(px_txn_ii_rltns_tbl(i).obj_config_inst_hdr_id , fnd_api.g_miss_num)
                <>  fnd_api.g_miss_num
           AND NVL(px_txn_ii_rltns_tbl(i).object_id, fnd_api.g_miss_num)
              = fnd_api.g_miss_num)
        THEN
          csi_t_gen_utility_pvt.add('Calling get_cz_inst_or_tld_id for OBJECT');

          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => px_txn_ii_rltns_tbl(i).obj_config_inst_hdr_id,
          p_config_inst_rev_num      => px_txn_ii_rltns_tbl(i).obj_config_inst_rev_num,
          p_config_inst_item_id      => px_txn_ii_rltns_tbl(i).obj_config_inst_item_id ,
          x_instance_id              => l_obj_instance_id  ,
          x_txn_line_detail_id       => l_obj_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_obj_instance_id IS NOT NULL
          THEN
             px_txn_ii_rltns_tbl(i).object_id := l_obj_instance_id;
             px_txn_ii_rltns_tbl(i).object_type := 'I' ;
          ELSIF l_obj_tld_id IS NOT NULL
          THEN
             px_txn_ii_rltns_tbl(i).object_id := l_obj_tld_id;
             px_txn_ii_rltns_tbl(i).object_type := 'T' ;
             px_txn_ii_rltns_tbl(i).object_index_flag := 'N' ;
          END IF ;

          IF l_obj_instance_id IS NULL
             AND l_obj_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;
          csi_t_gen_utility_pvt.add('tld/instance id for OBJECT' || l_obj_instance_id || l_obj_tld_id);
        END IF ; --object is null
      END LOOP ;  --px_txn_ii_rltns_tbl loop
    END IF ;  ---px_txn_ii_rltns_tbl.count > 0
-- Added for CZ Integration (End)
      IF px_txn_ii_rltns_tbl.COUNT > 0 THEN

/*
-- Commented the call to pvt and instead performing the check_rltns_integrity and then a call to the relationships grp since it simplifies the validations calls for M-M.
        -- loop thru instance relationship table
        FOR l_index IN px_txn_ii_rltns_tbl.FIRST..px_txn_ii_rltns_tbl.LAST
        LOOP

          -- initialize record type variable
          l_txn_ii_rltns_rec := px_txn_ii_rltns_tbl(l_index);
          l_txn_ii_rltns_rec.transaction_line_id   := l_txn_line_id;

          -- call api to create intance relationship records
          csi_t_txn_rltnshps_pvt.create_txn_ii_rltns_dtls(
            p_api_version        => p_api_version,
            p_commit             => p_commit,
            p_init_msg_list      => p_init_msg_list,
            p_validation_level   => p_validation_level,
            p_txn_ii_rltns_rec   => l_txn_ii_rltns_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;
          px_txn_ii_rltns_tbl(l_index).txn_relationship_id :=
            l_txn_ii_rltns_rec.txn_relationship_id;
        END LOOP; -- rltns tbl loop

*/

      debug( 'create_txn pvt Dumping all the processing tables...');

      csi_t_gen_utility_pvt.dump_txn_tables(
        p_ids_or_index_based => 'I',
        p_line_detail_tbl    => px_txn_line_detail_tbl,
        p_party_detail_tbl   => px_txn_party_detail_tbl,
        p_pty_acct_tbl       => px_txn_pty_acct_detail_tbl,
        p_ii_rltns_tbl       => px_txn_ii_rltns_tbl,
        p_org_assgn_tbl      => px_txn_org_assgn_tbl,
        p_ea_vals_tbl        => px_txn_ext_attrib_vals_tbl);

      csi_t_vldn_routines_pvt.convert_rltns_index_to_ids(
        p_line_dtl_tbl  => px_txn_line_detail_tbl,
        px_ii_rltns_tbl => px_txn_ii_rltns_tbl,
        x_return_status => l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

-- Added M-M changes The check rltns integrity has now been moved here .
        /* this routine checks the ii relationships data integrity*/

        csi_t_gen_utility_pvt.add('Validating relations integrity.');

        csi_t_vldn_routines_pvt.check_rltns_integrity(
          p_txn_line_detail_tbl => px_txn_line_detail_tbl,
          p_txn_ii_rltns_tbl    => px_txn_ii_rltns_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

          -- call api to create intance relationship records
          csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
            p_api_version        => p_api_version,
            p_commit             => p_commit,
            p_init_msg_list      => p_init_msg_list,
            p_validation_level   => p_validation_level,
            px_txn_ii_rltns_tbl   => px_txn_ii_rltns_tbl,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

-- Added M-M changes . End

      END IF; -- if for rltns tbl count > 0

    END IF; -- main if for td tbl count > 0


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.add('transaction_line_id : '||l_txn_line_id);
    csi_t_gen_utility_pvt.add('Transaction details created successfully.');
    csi_t_gen_utility_pvt.set_debug_off;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

  END create_transaction_dtls;

  /*
     This API is for managing the transaction details entities incl. the line details.
  */

  PROCEDURE update_transaction_dtls (
     p_api_version              IN  NUMBER
    ,p_commit                   IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list            IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level         IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec             IN  csi_t_datastructures_grp.txn_line_rec
    ,px_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2)
IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'update_transaction_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);

    l_txn_line_rec            csi_t_datastructures_grp.txn_line_rec;
    l_c_tld_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;
    l_u_tld_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;
    l_d_tld_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;
    l_c_tld_ind               binary_integer;
    l_u_tld_ind               binary_integer;
    l_d_tld_ind               binary_integer;

    l_c_pty_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_u_pty_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_d_pty_ids_tbl           csi_t_datastructures_grp.txn_party_ids_tbl;
    l_c_pty_ind               binary_integer;
    l_u_pty_ind               binary_integer;
    l_d_pty_ind               binary_integer;

    l_c_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_d_pty_acct_ids_tbl      csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_c_pa_ind                binary_integer;
    l_u_pa_ind                binary_integer;
    l_d_pa_ind                binary_integer;

    l_c_eav_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_u_eav_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_c_ea_ind                binary_integer;
    l_u_ea_ind                binary_integer;

    l_c_oa_tbl                csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_u_oa_tbl                csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_oa_ind                binary_integer;
    l_u_oa_ind                binary_integer;

    l_c_ii_tbl                csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_u_ii_tbl                csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_c_ii_ind                binary_integer;

    l_indx                    PLS_INTEGER ;
    i                         PLS_INTEGER ;
    x_tmp_line_detail_tbl     csi_t_datastructures_grp.txn_line_detail_tbl ;
    x_tmp_party_detail_tbl    csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_tmp_pty_acct_detail_tbl csi_t_datastructures_grp.txn_pty_acct_detail_tbl ;
    x_tmp_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl ;
    x_tmp_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl ;
    x_tmp_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl ;
    x_tmp_systems_tbl         csi_t_datastructures_grp.txn_systems_tbl ;
    x_tmp_pty_acct_ids_tbl    csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_tmp_party_detail_tbl    csi_t_datastructures_grp.txn_party_detail_tbl ;
    l_exists                  VARCHAR2(1);

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_transaction_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT
       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name)
    THEN
         RAISE FND_API.G_Exc_Unexpected_Error;
    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 then
       csi_t_gen_utility_pvt.dump_txn_line_rec(
            p_txn_line_rec => p_txn_line_rec);
    END IF;

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- Since this API handles the Create , Update and Delete operations
    -- first read through the pl/sql tables to identify the operation
    -- and bundle them and re-index the passed table accordingly
    -- Assumption is the pl/sql indexes start with 1 and are
    -- continuous.
 l_txn_line_rec  := p_txn_line_rec;

 IF px_txn_line_detail_tbl.count > 0 THEN

    debug('Transaction Details count:'||px_txn_line_detail_tbl.count);

  -- delete all the local pl/sql tables
    l_c_tld_tbl.delete;
    l_u_tld_tbl.delete;
    l_d_tld_tbl.delete;
    l_c_pty_tbl.delete;
    l_u_pty_tbl.delete;
    l_c_pty_acct_tbl.delete;
    l_u_pty_acct_tbl.delete;
    l_c_eav_tbl.delete;
    l_u_eav_tbl.delete;
    l_c_oa_tbl.delete;
    l_u_oa_tbl.delete;
    l_c_ii_tbl.delete;
    l_u_ii_tbl.delete;
    l_d_pty_ids_tbl.delete;
    l_d_pty_acct_ids_tbl.delete;

    x_tmp_line_detail_tbl.delete;
    x_tmp_party_detail_tbl.delete;
    x_tmp_pty_acct_detail_tbl.delete;
    x_tmp_ii_rltns_tbl.delete;
    x_tmp_org_assgn_tbl.delete;
    x_tmp_ext_attrib_vals_tbl.delete;
    x_tmp_pty_acct_ids_tbl.delete;

    l_c_tld_ind := 0;
    l_u_tld_ind := 0;
    l_d_tld_ind := 0;
    l_c_pty_ind := 0;
    l_u_pty_ind := 0;
    l_d_pty_ind := 0;
    l_c_pa_ind  := 0;
    l_u_pa_ind  := 0;
    l_d_pa_ind  := 0;
    l_c_oa_ind  := 0;
    l_u_oa_ind  := 0;
    l_c_ea_ind  := 0;
    l_u_ea_ind  := 0;
    l_c_ii_ind  := 0;

  FOR i IN px_txn_line_detail_tbl.FIRST .. px_txn_line_detail_tbl.LAST
  LOOP
    IF nvl(px_txn_line_detail_tbl(i).txn_line_detail_id,fnd_api.g_miss_num)= fnd_api.g_miss_num THEN
         l_c_tld_tbl(l_c_tld_ind) := px_txn_line_detail_tbl(i);
         -- re-index the child pl/sql tables for the appropriate operation
         -- Transaction Party details table
         IF px_txn_party_detail_tbl.count > 0 THEN
          FOR pc_ind IN px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST
          LOOP
            IF ((nvl(px_txn_party_detail_tbl(pc_ind).txn_line_detail_id,fnd_api.g_miss_num) = fnd_api.g_miss_num )
             AND (px_txn_party_detail_tbl(pc_ind).txn_line_details_index = i ))
            THEN
               px_txn_party_detail_tbl(pc_ind).txn_line_details_index := l_c_tld_ind;

               -- Transaction Party account details table
               IF px_txn_pty_acct_detail_tbl.count > 0 THEN
                FOR pac_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
                LOOP
                 IF ((nvl(px_txn_pty_acct_detail_tbl(pac_ind).txn_account_detail_id,fnd_api.g_miss_num) = fnd_api.g_miss_num)
                  AND (px_txn_pty_acct_detail_tbl(pac_ind).txn_party_details_index = pc_ind)) THEN

                     px_txn_pty_acct_detail_tbl(pac_ind).txn_party_details_index := l_c_pty_ind;
                     l_c_pty_acct_tbl(l_c_pa_ind) := px_txn_pty_acct_detail_tbl(pac_ind);
                     l_c_pa_ind := l_c_pa_ind + 1;
                 END IF;
                END LOOP;
               END IF;

               -- Resetting the Transaction Party Contacts table
               l_tmp_party_detail_tbl := px_txn_party_detail_tbl;

               FOR con_ind IN l_tmp_party_detail_tbl.FIRST .. l_tmp_party_detail_tbl.LAST
               LOOP
                IF nvl(l_tmp_party_detail_tbl(con_ind).txn_party_detail_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
                  AND nvl(l_tmp_party_detail_tbl(con_ind).contact_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                  AND nvl(l_tmp_party_detail_tbl(con_ind).contact_flag, 'N') = 'Y' THEN
                 IF nvl(px_txn_party_detail_tbl(pc_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                  AND ( nvl(px_txn_party_detail_tbl(pc_ind).contact_flag, fnd_api.g_miss_char) = fnd_api.g_miss_char
                        OR nvl(px_txn_party_detail_tbl(pc_ind).contact_flag, 'N') = 'N') THEN
                  IF l_tmp_party_detail_tbl(con_ind).contact_party_id =
                     px_txn_party_detail_tbl(pc_ind).txn_contact_party_index THEN

                     l_tmp_party_detail_tbl(con_ind).contact_party_id := l_c_pty_ind;
                  END IF;
                 END IF;
                END IF;
               END LOOP;
               px_txn_party_detail_tbl := l_tmp_party_detail_tbl;

               IF nvl(px_txn_party_detail_tbl(pc_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                AND ( nvl(px_txn_party_detail_tbl(pc_ind).contact_flag, fnd_api.g_miss_char) = fnd_api.g_miss_char
                      OR nvl(px_txn_party_detail_tbl(pc_ind).contact_flag, 'N') = 'N') THEN

                   px_txn_party_detail_tbl(pc_ind).txn_contact_party_index := l_c_pty_ind;
               END IF;

               l_c_pty_tbl(l_c_pty_ind) := px_txn_party_detail_tbl(pc_ind);
               l_c_pty_ind := l_c_pty_ind + 1;
            END IF;
          END LOOP;
         END IF;
       -- Transaction extended atttribute values table
         IF px_txn_ext_attrib_vals_tbl.count > 0 THEN
          FOR eac_ind IN px_txn_ext_attrib_vals_tbl.FIRST .. px_txn_ext_attrib_vals_tbl.LAST
          LOOP
            IF px_txn_ext_attrib_vals_tbl(eac_ind).txn_line_details_index = i THEN
                 px_txn_ext_attrib_vals_tbl(eac_ind).txn_line_details_index := l_c_tld_ind;
                 l_c_eav_tbl(l_c_ea_ind) := px_txn_ext_attrib_vals_tbl(eac_ind);
                 l_c_ea_ind := l_c_ea_ind + 1;
            END IF;
          END LOOP;
         END IF;
       -- Transaction Org assignments table
         IF px_txn_org_assgn_tbl.count > 0 THEN
          FOR oac_ind IN px_txn_org_assgn_tbl.FIRST .. px_txn_org_assgn_tbl.LAST
          LOOP
            IF px_txn_org_assgn_tbl(oac_ind).txn_line_details_index = i THEN
                 px_txn_org_assgn_tbl(oac_ind).txn_line_details_index := l_c_tld_ind;
                 l_c_oa_tbl(l_c_oa_ind) := px_txn_org_assgn_tbl(oac_ind);
                 l_c_oa_ind := l_c_oa_ind + 1;
            END IF;
          END LOOP;
         END IF;
       -- Transaction details relationships table
         IF px_txn_ii_rltns_tbl.count > 0 THEN
          FOR iic_ind IN px_txn_ii_rltns_tbl.FIRST .. px_txn_ii_rltns_tbl.LAST
          LOOP
            IF px_txn_ii_rltns_tbl(iic_ind).subject_id = i
              AND nvl(px_txn_ii_rltns_tbl(iic_ind).subject_type, 'T') = 'T' THEN
                 px_txn_ii_rltns_tbl(iic_ind).subject_index_flag := 'Y';
                 px_txn_ii_rltns_tbl(iic_ind).subject_id := l_c_tld_ind;
                 l_c_ii_tbl(l_c_ii_ind) := px_txn_ii_rltns_tbl(iic_ind);
                 l_c_ii_ind := l_c_ii_ind + 1;
            ELSIF px_txn_ii_rltns_tbl(iic_ind).object_id = i
              AND nvl(px_txn_ii_rltns_tbl(iic_ind).object_type, 'T') = 'T' THEN
                 px_txn_ii_rltns_tbl(iic_ind).object_index_flag := 'Y';
                 px_txn_ii_rltns_tbl(iic_ind).object_id := l_c_tld_ind;
                 l_c_ii_tbl(l_c_ii_ind) := px_txn_ii_rltns_tbl(iic_ind);
                 l_c_ii_ind := l_c_ii_ind + 1;
            END IF;
          END LOOP;
         END IF;
         l_c_tld_ind := l_c_tld_ind +1;
    ELSE
      -- modified the IF below for bug 4769442
      IF nvl(px_txn_line_detail_tbl(i).active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
        AND l_txn_line_rec.source_transaction_type_id = 3
      THEN
      -- Check to see if Mass Update, delete operation and is allowed
            Debug('Line Detail ('||px_txn_line_detail_tbl(i).txn_line_detail_id||
                    ') has Active End Date set..Check Instance ID');
         BEGIN

           SELECT instance_id
           INTO   px_txn_line_detail_tbl(i).instance_id
           FROM csi_t_txn_line_details
           WHERE txn_line_detail_id = px_txn_line_detail_tbl(i).txn_line_detail_id
           AND   instance_id is NOT null;

           Debug('Instance ID ('||px_txn_line_detail_tbl(i).instance_id||') - Source Txn Type ID ('||
                  l_txn_line_rec.source_transaction_type_id ||') found so add this instance to be deleted');
         EXCEPTION
           when no_data_found then
             Debug('This instance will just be updated and not deleted ..'||
                    ' Either the Instance ID was NULL or not a Mass Update Transaction Type');
             NULL;
         END;
      END IF;
      IF nvl(px_txn_line_detail_tbl(i).active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
        AND nvl(px_txn_line_detail_tbl(i).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        AND l_txn_line_rec.source_transaction_type_id = 3
      THEN
      -- Check to see if Mass Update, delete operation and is allowed
         Debug('Instance ID ('||px_txn_line_detail_tbl(i).instance_id
               ||') - Source Txn Type ID ('||l_txn_line_rec.source_transaction_type_id
               ||') found so add this instance to be deleted');
         l_d_tld_tbl(l_d_tld_ind) := px_txn_line_detail_tbl(i);
         l_d_tld_ind := l_d_tld_ind +1;

      ELSE
        l_u_tld_tbl(l_u_tld_ind) := px_txn_line_detail_tbl(i);

        csi_t_gen_utility_pvt.dump_line_detail_rec(
           p_line_detail_rec => l_u_tld_tbl(l_u_tld_ind));

        -- re-index the child pl/sql tables
        -- Transaction Party details table
         IF px_txn_party_detail_tbl.count > 0 THEN
           FOR pu_ind IN px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST
           LOOP
             Debug('Upd Txn line detail, pu_ind: '|| pu_ind);
             csi_t_gen_utility_pvt.dump_party_detail_rec(px_txn_party_detail_tbl(pu_ind));
             IF nvl(px_txn_party_detail_tbl(pu_ind).txn_party_detail_id,fnd_api.g_miss_num)
                 = fnd_api.g_miss_num   -- New Party creation
             THEN
               Debug('Party ID: '|| px_txn_party_detail_tbl(pu_ind).party_source_id||'-'||pu_ind);
               IF px_txn_party_detail_tbl(pu_ind).txn_line_detail_id =
                  px_txn_line_detail_tbl(i).txn_line_detail_id
               THEN

                  l_u_pty_tbl(l_u_pty_ind) := px_txn_party_detail_tbl(pu_ind);
                  -- Transaction Party account details table
                  IF px_txn_pty_acct_detail_tbl.count > 0 THEN
                   FOR pau_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
                   LOOP
                     Debug('Upd Txn acct detail, pau_ind: '|| pau_ind);
                     IF nvl(px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id,fnd_api.g_miss_num)
                        = fnd_api.g_miss_num
                     THEN  -- New account creation
                      IF px_txn_pty_acct_detail_tbl(pau_ind).txn_party_details_index = pu_ind THEN

                         px_txn_pty_acct_detail_tbl(pau_ind).txn_party_details_index := l_u_pty_ind;
                         l_u_pty_acct_tbl(l_u_pa_ind) := px_txn_pty_acct_detail_tbl(pau_ind);
                         l_u_pa_ind := l_u_pa_ind + 1;
                      END IF;
                     END IF;
                   END LOOP;
                  END IF;

                  -- Resetting the Transaction Party Contacts table
                  l_tmp_party_detail_tbl := px_txn_party_detail_tbl;

                  FOR con_ind IN l_tmp_party_detail_tbl.FIRST .. l_tmp_party_detail_tbl.LAST
                  LOOP
                   IF nvl(l_tmp_party_detail_tbl(con_ind).txn_party_detail_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
                          -- New Party contact creation
                     AND nvl(l_tmp_party_detail_tbl(con_ind).contact_party_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                     AND nvl(l_tmp_party_detail_tbl(con_ind).contact_flag, 'N') = 'Y' THEN
                      IF nvl(px_txn_party_detail_tbl(pu_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                         AND ( nvl(px_txn_party_detail_tbl(pu_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                               OR nvl(px_txn_party_detail_tbl(pu_ind).contact_flag, 'N') = 'N') THEN
                       IF l_tmp_party_detail_tbl(con_ind).contact_party_id
                          = px_txn_party_detail_tbl(pu_ind).txn_contact_party_index THEN
                           l_tmp_party_detail_tbl(con_ind).contact_party_id := l_u_pty_ind;
                       END IF;
                      END IF;
                   END IF;
                  END LOOP;
                  px_txn_party_detail_tbl := l_tmp_party_detail_tbl;
                  debug('l_u_pty_ind: '||l_u_pty_ind);

                  IF nvl(px_txn_party_detail_tbl(pu_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                    AND ( nvl(px_txn_party_detail_tbl(pu_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                          OR nvl(px_txn_party_detail_tbl(pu_ind).contact_flag, 'N') = 'N')
                  THEN
                      -- reset the txn_contact_party_index of the update table too
                      px_txn_party_detail_tbl(pu_ind).txn_contact_party_index := l_u_pty_ind;
                  END IF;
                  l_u_pty_tbl(l_u_pty_ind) := px_txn_party_detail_tbl(pu_ind);
                  l_u_pty_ind := l_u_pty_ind + 1;
                END IF;
             ELSE  -- update to an existing party
                Debug('Upd Txn party  detail, pu_ind: '|| pu_ind||'type id:'||l_txn_line_rec.source_transaction_type_id);
                l_exists := 'N';
                IF nvl(px_txn_party_detail_tbl(pu_ind).preserve_detail_flag,fnd_api.g_miss_char) = 'N'
                   AND l_txn_line_rec.source_transaction_type_id = 3
                   -- Mass Update allows usage of preserve details flag for party deletion..
                THEN
                  If l_d_pty_ids_tbl.count > 0 THEN
                   For d in l_d_pty_ids_tbl.first .. l_d_pty_ids_tbl.last Loop
                    If l_d_pty_ids_tbl(d).txn_party_detail_id = px_txn_party_detail_tbl(pu_ind).txn_party_detail_id
                    Then
                       l_exists := 'Y';
                       exit;
                     End if;
                    End Loop;
                   Else
                      l_exists := 'N';
                   End If;
                   If l_exists <> 'Y' THEN
                     l_d_pty_ids_tbl(l_d_pty_ind).txn_party_detail_id := px_txn_party_detail_tbl(pu_ind).txn_party_detail_id;
                     l_d_pty_ind := l_d_pty_ind + 1 ;
                     l_exists := 'N';
                     Debug('marked for deletion:'||to_char(px_txn_party_detail_tbl(pu_ind).txn_party_detail_id));
                   End If;
                ELSE
                   If l_u_pty_tbl.count > 0 THEN
                    For u in l_u_pty_tbl.first .. l_u_pty_tbl.last Loop
                     If l_u_pty_tbl(u).txn_party_detail_id = px_txn_party_detail_tbl(pu_ind).txn_party_detail_id
                     Then
                        l_exists := 'Y';
                        exit;
                     End if;
                    End Loop;
                   Else
                            l_exists := 'N';
                   End If;
                   If l_exists <> 'Y' THEN
                     l_u_pty_tbl(l_u_pty_ind) := px_txn_party_detail_tbl(pu_ind);
                     l_u_pty_ind := l_u_pty_ind + 1;
                     l_exists := 'N';
                   End If;
                END IF;

                IF px_txn_pty_acct_detail_tbl.count > 0 THEN
                 FOR pau_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
                 LOOP
                  IF nvl(px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id,fnd_api.g_miss_num)
                      = fnd_api.g_miss_num THEN  -- New account creation

                    Debug('Upd Txn line detail Update Pty Crt Acct, pau_ind: '|| pau_ind);
                    csi_t_gen_utility_pvt.dump_pty_acct_rec(px_txn_pty_acct_detail_tbl(pau_ind));
                   IF px_txn_pty_acct_detail_tbl(pau_ind).txn_party_detail_id
                      = px_txn_party_detail_tbl(pu_ind).txn_party_detail_id THEN
                    IF l_u_pty_acct_tbl.count > 0 THEN
                      l_exists := 'N';
                      For u in l_u_pty_acct_tbl.first .. l_u_pty_acct_tbl.last Loop
                       IF ( (l_u_pty_acct_tbl(u).account_id = px_txn_pty_acct_detail_tbl(pau_ind).account_id)
                           AND (l_u_pty_acct_tbl(u).relationship_type_code =
                                px_txn_pty_acct_detail_tbl(pau_ind).relationship_type_code)
                           AND (l_u_pty_acct_tbl(u).txn_party_detail_id =
                                px_txn_pty_acct_detail_tbl(pau_ind).txn_party_detail_id) )
                       THEN -- not already in the pl/sql table .. append

                           l_exists := 'Y';
                           exit;
                       END IF;
                      End Loop;
                      IF l_exists <> 'Y' THEN
                         l_u_pty_acct_tbl(l_u_pa_ind) := px_txn_pty_acct_detail_tbl(pau_ind);
                         l_u_pa_ind := l_u_pa_ind + 1;
                         exit;
                      ELSE
                         exit; -- already in the pl/sql table .. ignore and exit
                      END IF;
                    ELSE
                       l_u_pty_acct_tbl(l_u_pa_ind) := px_txn_pty_acct_detail_tbl(pau_ind);
                       l_u_pa_ind := l_u_pa_ind + 1;
                    END IF;
                   END IF;
                  ELSE -- update to an existing account detail
                    Debug('Upd line detail Update Pty Upd Acct, pau_ind: '
                           || pau_ind||px_txn_pty_acct_detail_tbl(pau_ind).preserve_detail_flag);
                    IF nvl(px_txn_pty_acct_detail_tbl(pau_ind).preserve_detail_flag,fnd_api.g_miss_char) = 'N'
                      AND l_txn_line_rec.source_transaction_type_id = 3 THEN
                      -- Mass Update allows usage of preserve details flag for account deletion..

                       Debug('Update Acct, preserve flag: N');
                       IF l_d_pty_acct_ids_tbl.count > 0 THEN
                        For d in l_d_pty_acct_ids_tbl.first .. l_d_pty_acct_ids_tbl.last Loop
                         If l_d_pty_acct_ids_tbl(d).txn_account_detail_id =
                            px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id
                         Then
                            l_exists := 'Y';
                            exit;
                         End if;
                        End Loop;
                       Else
                         l_exists := 'N';
                       End If;
                       If l_exists <> 'Y' THEN
                         Debug('account marked for deletion: '|| px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id);
                         l_d_pty_acct_ids_tbl(l_d_pa_ind).txn_account_detail_id := px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id;
                         l_d_pa_ind := l_d_pa_ind + 1 ;
                         l_exists := 'N';
                       End If;
                    ELSE
                      IF l_u_pty_acct_tbl.count > 0 THEN
                       For u in l_u_pty_acct_tbl.first .. l_u_pty_acct_tbl.last Loop
                        If l_u_pty_acct_tbl(u).txn_account_detail_id =
                           px_txn_pty_acct_detail_tbl(pau_ind).txn_account_detail_id
                        Then
                           l_exists := 'Y';
                           exit;
                        End if;
                       End Loop;
                      Else
                         l_exists := 'N';
                      End If;
                      If l_exists <> 'Y' THEN
                         Debug('Upd Txn line detail Update Pty Upd acct, pau_ind: '|| pau_ind);
                         l_u_pty_acct_tbl(l_u_pa_ind) := px_txn_pty_acct_detail_tbl(pau_ind);
                         l_u_pa_ind := l_u_pa_ind + 1;
                         l_exists := 'N';
                      End If;
                    END IF;
                   END IF;
                 END LOOP;
               END IF;
             END IF; -- tpd.party detail id = g_miss
           END LOOP;
         END IF;
         -- Transaction extended atttribute values table
           IF px_txn_ext_attrib_vals_tbl.count > 0 THEN
            l_exists := 'N';
            FOR eau_ind IN px_txn_ext_attrib_vals_tbl.FIRST .. px_txn_ext_attrib_vals_tbl.LAST
            LOOP
              If l_u_eav_tbl.count > 0 THEN
                For u in l_u_eav_tbl.first .. l_u_eav_tbl.last Loop
                if ((l_u_eav_tbl(u).txn_attrib_detail_id <> fnd_api.g_miss_num
                     and px_txn_ext_attrib_vals_tbl(eau_ind).txn_attrib_detail_id <> fnd_api.g_miss_num)
                     and ( l_u_eav_tbl(u).txn_attrib_detail_id= px_txn_ext_attrib_vals_tbl(eau_ind).txn_attrib_detail_id))
                 Then
                    l_exists := 'Y';
                    exit;
                 End if;
                End Loop;
              Else
                 l_exists := 'N';
              End If;
              If l_exists <> 'Y' THEN
                 l_u_eav_tbl(l_u_ea_ind) := px_txn_ext_attrib_vals_tbl(eau_ind);
                 l_u_ea_ind := l_u_ea_ind + 1;
                 l_exists := 'N';
              END IF;
            END LOOP;
           END IF;
           -- Transaction Org assignments table
           IF px_txn_org_assgn_tbl.count > 0 THEN
            FOR oau_ind IN px_txn_org_assgn_tbl.FIRST .. px_txn_org_assgn_tbl.LAST
            LOOP
              If l_u_oa_tbl.count > 0 THEN
                For u in l_u_oa_tbl.first .. l_u_oa_tbl.last Loop
                 If l_u_oa_tbl(u).txn_operating_unit_id = px_txn_org_assgn_tbl(oau_ind).txn_operating_unit_id
                 Then
                    l_exists := 'Y';
                    exit;
                 End if;
                End Loop;
              Else
                 l_exists := 'N';
              End If;
              If l_exists <> 'Y' THEN
                   l_u_oa_tbl(l_u_oa_ind) := px_txn_org_assgn_tbl(oau_ind);
                   l_u_oa_ind := l_u_oa_ind + 1;
              END IF;
            END LOOP;
           END IF;
    	  l_u_tld_ind := l_u_tld_ind +1;
      END IF;
    END IF;
  END LOOP ;
 END IF;


 debug('Transaction Details count By operation:'||px_txn_line_detail_tbl.count);
 debug('                                       Create:'||l_c_tld_tbl.count);
 debug('                                       Update:'||l_u_tld_tbl.count);
 debug('                                       Delete:'||l_d_tld_tbl.count);


 IF l_c_tld_tbl.count > 0 THEN
  -- Calling the Create Txn details for all the new Transaction details...
    csi_t_txn_details_pvt.create_transaction_dtls(
      p_api_version               => p_api_version,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      px_txn_line_rec             => l_txn_line_rec,
      px_txn_line_detail_tbl      => l_c_tld_tbl,
      px_txn_party_detail_tbl     => l_c_pty_tbl,
      px_txn_pty_acct_detail_tbl  => l_c_pty_acct_tbl,
      px_txn_ii_rltns_tbl         => l_c_ii_tbl,
      px_txn_org_assgn_tbl        => l_c_oa_tbl,
      px_txn_ext_attrib_vals_tbl  => l_c_eav_tbl,
      px_txn_systems_tbl          => x_tmp_systems_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  -- need to use tmp tables and then reassign the ID's back to sync up the same px tables so that
  -- they can be passed back to the callers

     x_tmp_line_detail_tbl       := l_c_tld_tbl;
     x_tmp_party_detail_tbl      := l_c_pty_tbl;
     x_tmp_pty_acct_detail_tbl   := l_c_pty_acct_tbl;
     x_tmp_ii_rltns_tbl          := l_c_ii_tbl;
     x_tmp_org_assgn_tbl         := l_c_oa_tbl;
     x_tmp_ext_attrib_vals_tbl   := l_c_eav_tbl;

 END IF;

 IF l_u_tld_tbl.count > 0 THEN

      csi_t_gen_utility_pvt.dump_txn_tables(
        p_ids_or_index_based => 'I',
        p_line_detail_tbl    => l_u_tld_tbl,
        p_party_detail_tbl   => l_u_pty_tbl,
        p_pty_acct_tbl       => l_u_pty_acct_tbl,
        p_ii_rltns_tbl       => x_tmp_ii_rltns_tbl,
        p_org_assgn_tbl      => x_tmp_org_assgn_tbl,
        p_ea_vals_tbl        => l_u_eav_tbl);

  -- Calling the Update Txn details for the updates to Transaction details...
    csi_t_txn_line_dtls_pvt.update_txn_line_dtls(
      p_api_version              => p_api_version,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      p_txn_line_rec             => l_txn_line_rec,
      p_txn_line_detail_tbl      => l_u_tld_tbl,
      px_txn_ii_rltns_tbl        => l_u_ii_tbl,
      px_txn_party_detail_tbl    => l_u_pty_tbl,
      px_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
      px_txn_org_assgn_tbl       => l_u_oa_tbl,
      px_txn_ext_attrib_vals_tbl => l_u_eav_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_tmp_line_detail_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_line_detail_tbl.LAST,0)+1  ;
       FOR i IN x_tmp_line_detail_tbl.FIRST .. x_tmp_line_detail_tbl.LAST
       LOOP
          px_txn_line_detail_tbl(l_indx) := x_tmp_line_detail_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---x_tmp_line_detail_tbl

    ELSE  -- No creates performed earlier
       px_txn_line_detail_tbl := x_tmp_line_detail_tbl;
    END IF ; ---x_tmp_line_detail_tbl.COUNT > 0

    IF x_tmp_party_detail_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_party_detail_tbl.LAST,0)+1 ;
       FOR i IN x_tmp_party_detail_tbl.FIRST .. x_tmp_party_detail_tbl.LAST
       LOOP
          px_txn_party_detail_tbl(l_indx) := x_tmp_party_detail_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---x_tmp_party_detail_tbl

    ELSE  -- No creates performed earlier
       px_txn_party_detail_tbl := x_tmp_party_detail_tbl;
    END IF ; ---x_tmp_party_detail_tbl.COUNT > 0

    IF x_tmp_pty_acct_detail_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_pty_acct_detail_tbl.LAST,0)+1 ;
       FOR i IN x_tmp_pty_acct_detail_tbl.FIRST .. x_tmp_pty_acct_detail_tbl.LAST
       LOOP
          px_txn_pty_acct_detail_tbl(l_indx) := x_tmp_pty_acct_detail_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---x_tmp_pty_acct_detail_tbl

    ELSE  -- No creates performed earlier
       px_txn_pty_acct_detail_tbl := x_tmp_pty_acct_detail_tbl;
    END IF ; ---x_tmp_pty_acct_detail_tbl.COUNT > 0

    IF x_tmp_ii_rltns_tbl.COUNT > 0
    THEN
       px_txn_ii_rltns_tbl := x_tmp_ii_rltns_tbl; --cause we only allow relationship creates right now
    END IF ; ---x_tmp_ii_rltns_tbl.COUNT > 0

    IF x_tmp_org_assgn_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_org_assgn_tbl.LAST,0)+1 ;
       FOR i IN x_tmp_org_assgn_tbl.FIRST .. x_tmp_org_assgn_tbl.LAST
       LOOP
          px_txn_org_assgn_tbl(l_indx) := x_tmp_org_assgn_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---x_tmp_org_assgn_tbl

    ELSE  -- No creates performed earlier
       px_txn_org_assgn_tbl := x_tmp_org_assgn_tbl;
    END IF ; ---x_tmp_org_assgn_tbl.COUNT > 0

    IF x_tmp_ext_attrib_vals_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_ext_attrib_vals_tbl.LAST,0)+1 ;
       FOR i IN x_tmp_ext_attrib_vals_tbl.FIRST .. x_tmp_ext_attrib_vals_tbl.LAST
       LOOP
          px_txn_ext_attrib_vals_tbl(l_indx) := x_tmp_ext_attrib_vals_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---x_tmp_ext_attrib_vals_tbl

    ELSE  -- No creates performed earlier

       px_txn_ext_attrib_vals_tbl := x_tmp_ext_attrib_vals_tbl;

    END IF ; ---x_tmp_ext_attrib_vals_tbl.COUNT > 0

    IF l_d_pty_acct_ids_tbl.count > 0 THEN  -- Mass Update; remove new accounts
        debug('                                       deleting acct :'||l_d_pty_acct_ids_tbl.count);
         csi_t_txn_parties_grp.delete_txn_pty_acct_dtls(
             p_api_version              => 1.0
            ,p_commit                   => fnd_api.g_false
            ,p_init_msg_list            => p_init_msg_list
            ,p_validation_level         => p_validation_level
            ,p_txn_pty_acct_ids_tbl     => l_d_pty_acct_ids_tbl
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
    END IF;

    IF l_d_pty_ids_tbl.count > 0 THEN  -- Mass Update; remove current and new associations

        debug('                                       deleting Pty :'||l_d_pty_ids_tbl.count);

         csi_t_txn_parties_grp.delete_txn_party_dtls(
             p_api_version              => 1.0
            ,p_commit                   => fnd_api.g_false
            ,p_init_msg_list            => p_init_msg_list
            ,p_validation_level         => p_validation_level
            ,p_txn_party_ids_tbl        => l_d_pty_ids_tbl
            ,x_txn_pty_acct_ids_tbl     => x_tmp_pty_acct_ids_tbl
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
    END IF;
 ELSE -- No updates being procesed..

       px_txn_line_detail_tbl     := x_tmp_line_detail_tbl;
       px_txn_party_detail_tbl    := x_tmp_party_detail_tbl;
       px_txn_pty_acct_detail_tbl := x_tmp_pty_acct_detail_tbl;
       px_txn_ii_rltns_tbl        := x_tmp_ii_rltns_tbl;
       px_txn_org_assgn_tbl       := x_tmp_org_assgn_tbl;
       px_txn_ext_attrib_vals_tbl := x_tmp_ext_attrib_vals_tbl;

 END IF; -- l_u_tld_tbl.count > 0

 IF l_d_tld_tbl.count > 0 THEN
  -- Calling the Delete Txn details for deletion of the Txn Line Detail and it's child entities
  For d in l_d_tld_tbl.FIRST .. l_d_tld_tbl.LAST Loop
    csi_t_txn_details_pvt.delete_transaction_dtls(
      p_api_version         => p_api_version,
      p_commit              => p_commit,
      p_init_msg_list       => p_init_msg_list,
      p_validation_level    => p_validation_level,
      p_transaction_line_id => l_d_tld_tbl(d).transaction_line_id,
      p_txn_line_detail_id  => l_d_tld_tbl(d).txn_line_detail_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END Loop;

    IF px_txn_line_detail_tbl.COUNT > 0
    THEN
       l_indx := NVL(px_txn_line_detail_tbl.LAST,0)+1  ;
       FOR i IN l_d_tld_tbl.FIRST .. l_d_tld_tbl.LAST
       LOOP
          px_txn_line_detail_tbl(l_indx) := l_d_tld_tbl(i) ;
          l_indx := l_indx + 1 ;
       END LOOP ; ---l_d_tld_tbl
    END IF ; ---px_txn_line_detail_tbl.COUNT > 0
 END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.add('Transaction details updated successfully.');
    csi_t_gen_utility_pvt.set_debug_off;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

  END update_transaction_dtls;

  PROCEDURE delete_transaction_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_transaction_line_id    IN  NUMBER
    ,p_txn_line_detail_id     IN  NUMBER
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_transaction_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_transaction_line_id     NUMBER;
    l_rltn_exists             VARCHAR2(1) := 'N';


    l_td_ind                  BINARY_INTEGER;
    l_pty_ind                 BINARY_INTEGER;
    l_pty_acc_ind             BINARY_INTEGER;
    l_ii_ind                  BINARY_INTEGER;
    l_oa_ind                  BINARY_INTEGER;
    l_ea_ind                  BINARY_INTEGER;


    /* table type definitions */
    l_txn_line_rec          csi_t_datastructures_grp.txn_line_rec;
    l_line_dtl_ids_tbl      csi_t_datastructures_grp.txn_line_detail_ids_tbl;
    l_party_ids_tbl         csi_t_datastructures_grp.txn_party_ids_tbl;
    l_pty_acct_ids_tbl      csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_ii_rltns_ids_tbl      csi_t_datastructures_grp.txn_ii_rltns_ids_tbl;
    l_org_assgn_ids_tbl     csi_t_datastructures_grp.txn_org_assgn_ids_tbl;
    l_ext_attrib_ids_tbl    csi_t_datastructures_grp.txn_ext_attrib_ids_tbl;

    l_txn_pty_acct_ids_tbl  csi_t_datastructures_grp.txn_pty_acct_ids_tbl;


    CURSOR td_cur IS
      SELECT txn_line_detail_id
      FROM   csi_t_txn_line_details
      WHERE  transaction_line_id = p_transaction_line_id
       AND decode(txn_line_detail_id, p_txn_line_detail_id,p_txn_line_detail_id,-99999)
            = nvl(p_txn_line_detail_id,-99999); -- Added for Mass update R12

    CURSOR pty_cur(p_txn_line_dtl_id in number) IS
      SELECT txn_party_detail_id
      FROM   csi_t_party_details
      WHERE  txn_line_detail_id = p_txn_line_dtl_id;

    CURSOR pty_acc_cur(p_txn_party_dtl_id in number) IS
      SELECT txn_account_detail_id
      FROM   csi_t_party_accounts
      WHERE  txn_party_detail_id = p_txn_party_dtl_id;

    CURSOR ii_cur IS
      SELECT txn_relationship_id
      FROM   csi_t_ii_relationships
      WHERE  transaction_line_id = p_transaction_line_id;
/* Added for M-M since transaction line id no longer carries importance now Start */

    CURSOR txn_hdr_cur1 (p_txn_line_dtl_id in number) IS
      SELECT csit.transaction_line_id, csii.txn_relationship_id
      FROM   csi_t_ii_relationships csii , csi_t_txn_line_details csit
      WHERE  csit.txn_line_detail_id = csii.subject_id
        AND csii.subject_type = 'T'
        AND csii.subject_id in ( SELECT subject_id
            FROM   csi_t_ii_relationships
            WHERE  object_type ='T' AND object_id = p_txn_line_dtl_id)
        AND csii.object_id = p_txn_line_dtl_id ;

    CURSOR txn_hdr_cur2 (p_txn_line_dtl_id in number) IS
      SELECT csit.transaction_line_id, csii.txn_relationship_id
      FROM   csi_t_ii_relationships csii , csi_t_txn_line_details csit
      WHERE  csit.txn_line_detail_id = csii.object_id
        AND csii.object_type = 'T'
        AND csii.object_id in ( SELECT object_id
            FROM   csi_t_ii_relationships
            WHERE  subject_type ='T' AND subject_id = p_txn_line_dtl_id)
        AND csii.subject_id = p_txn_line_dtl_id ;

/* Added for M-M since transaction line id no longer carries importance now End */

    CURSOR oa_cur(p_txn_line_dtl_id in number) IS
      SELECT txn_operating_unit_id
      FROM   csi_t_org_assignments
      WHERE  txn_line_detail_id = p_txn_line_dtl_id;

    CURSOR ea_cur(p_txn_line_dtl_id in number) IS
      SELECT txn_attrib_detail_id
      FROM   csi_t_extend_attribs
      WHERE  txn_line_detail_id = p_txn_line_dtl_id;

    CURSOR sys_cur IS
      SELECT transaction_system_id
      FROM   csi_t_txn_systems
      WHERE  transaction_line_id = p_transaction_line_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_transaction_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    -- debug messages

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    csi_t_gen_utility_pvt.add('  p_transaction_line_id: '||
                          to_char(p_transaction_line_id));

    csi_t_gen_utility_pvt.add('  p_txn_line_detail_id: '||
                          to_char(p_txn_line_detail_id));

    -- Main API code
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_transaction_line_id,
      p_param_name => 'p_transaction_line_id',
      p_api_name   => l_api_name);

    -- validate transaction line id
    csi_t_vldn_routines_pvt.validate_transaction_line_id(
      p_transaction_line_id   => p_transaction_line_id,
      x_transaction_line_rec  => l_txn_line_rec,-- Added for Mass update R12
      x_return_status         => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN

      fnd_message.set_name('CSI','CSI_TXN_LINE_ID_INVALID');
      fnd_message.set_token('TXN_LINE_ID', p_transaction_line_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;

    -- put the business logics here

    -- cannot delete the converted transaction details.
    --  (Ones that are converted in to item instances) These records are
    --   identified by value in the csi_transaction_id.
    --   If the CSI_TRANSACTION_ID is not null or an appropriate value in the
    --   processing_status flag

    -- Added check for validation for Purge
    IF p_validation_level <> 999 THEN
     IF l_txn_line_rec.source_transaction_type_id <> 3 THEN -- Added for Mass update R12
      -- excluding the Mass Update Transactions

         csi_t_vldn_routines_pvt.check_ib_creation(
             p_transaction_line_id => p_transaction_line_id,
             x_return_status       => l_return_status);

         IF l_return_status = fnd_api.g_true THEN

            fnd_message.set_name('CSI','CSI_TXN_DELETION_NOT_ALLOWED');
            fnd_message.set_token('TXN_LINE_ID', p_transaction_line_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

         END IF;
       END IF;
     END IF;

    l_pty_ind     := 0;
    l_pty_acc_ind := 0;
    l_oa_ind      := 0;
    l_ea_ind      := 0;
    l_ii_ind      := 0;

    FOR td_rec in td_cur
    LOOP

      l_td_ind := td_cur%rowcount;
      debug ('deleting line detail ID:'||td_rec.txn_line_detail_id);

      -- populate txn_line_detail table

      l_line_dtl_ids_tbl(l_td_ind).
        transaction_line_id        := p_transaction_line_id;
      l_line_dtl_ids_tbl(l_td_ind).
        txn_line_detail_id         := td_rec.txn_line_detail_id;

      FOR pty_rec IN pty_cur(td_rec.txn_line_detail_id)
      LOOP

        l_pty_ind := l_pty_ind + 1;

        -- populate txn_party_detail_ids table

        l_party_ids_tbl(l_pty_ind).
          txn_line_detail_id       := td_rec.txn_line_detail_id;
        l_party_ids_tbl(l_pty_ind).
          txn_party_detail_id      := pty_rec.txn_party_detail_id;

        FOR pty_acc_rec IN pty_acc_cur(pty_rec.txn_party_detail_id)
        LOOP

          l_pty_acc_ind := l_pty_acc_ind + 1;

          -- populate txn_pty_account_ids table

          l_pty_acct_ids_tbl(l_pty_acc_ind).
            txn_party_detail_id    := pty_rec.txn_party_detail_id;
          l_pty_acct_ids_tbl(l_pty_acc_ind).
            txn_account_detail_id  := pty_acc_rec.txn_account_detail_id;

        END LOOP;

      END LOOP;

      FOR oa_rec IN oa_cur(td_rec.txn_line_detail_id)
      LOOP

        l_oa_ind := l_oa_ind + 1;

        l_org_assgn_ids_tbl(l_oa_ind).
          txn_line_detail_id         := td_rec.txn_line_detail_id;
        l_org_assgn_ids_tbl(l_oa_ind).
          txn_operating_unit_id      := oa_rec.txn_operating_unit_id;

      END LOOP;

      FOR ea_rec IN ea_cur(td_rec.txn_line_detail_id)
      LOOP

        l_ea_ind := l_ea_ind + 1;

        l_ext_attrib_ids_tbl(l_ea_ind).
          txn_line_detail_id         := td_rec.txn_line_detail_id;
        l_ext_attrib_ids_tbl(l_ea_ind).
          txn_attrib_detail_id       := ea_rec.txn_attrib_detail_id;

      END LOOP;

/* Added for M-M since transaction line id no longer carries importance now Start */

      FOR txn_hdr_rec IN txn_hdr_cur1(td_rec.txn_line_detail_id)
      LOOP
        l_transaction_line_id := txn_hdr_rec.transaction_line_id;

        IF l_transaction_line_id <> p_transaction_line_id THEN

            csi_t_vldn_routines_pvt.check_ib_creation(
              p_transaction_line_id => l_transaction_line_id,
              x_return_status       => l_return_status);

            IF l_return_status = fnd_api.g_true THEN
                FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_ID_PROCESSED');
                FND_MESSAGE.set_token('TXN_LINE_ID',l_transaction_line_id);
                FND_MSG_PUB.add;
                exit;  -- if a relationship is found and that has already been processed to IB then skip it else mark it for deletion
            END IF;

              l_ii_ind := l_ii_ind + 1;

              l_ii_rltns_ids_tbl(l_ii_ind).transaction_line_id := txn_hdr_rec.transaction_line_id;
              l_ii_rltns_ids_tbl(l_ii_ind).txn_relationship_id := txn_hdr_rec.txn_relationship_id;

        END IF;
      END LOOP;

      FOR txn_hdr_rec IN txn_hdr_cur2(td_rec.txn_line_detail_id)
      LOOP
        l_transaction_line_id := txn_hdr_rec.transaction_line_id;


        IF l_transaction_line_id <> p_transaction_line_id THEN

            csi_t_vldn_routines_pvt.check_ib_creation(
              p_transaction_line_id => l_transaction_line_id,
              x_return_status       => l_return_status);

            IF l_return_status = fnd_api.g_true THEN
                FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_ID_PROCESSED');
                FND_MESSAGE.set_token('TXN_LINE_ID',l_transaction_line_id);
                FND_MSG_PUB.add;
                exit;  -- if a relationship is found and that has already been processed to IB then skip it else mark it for deletion
            END IF;
              l_ii_ind := l_ii_ind + 1;

              l_ii_rltns_ids_tbl(l_ii_ind).transaction_line_id := txn_hdr_rec.transaction_line_id;
              l_ii_rltns_ids_tbl(l_ii_ind).txn_relationship_id := txn_hdr_rec.txn_relationship_id;

        END IF;
      END LOOP;

/* Added for M-M since transaction line id no longer carries importance now End */

    END LOOP;

    FOR ii_rec IN ii_cur
    LOOP
     IF l_ii_rltns_ids_tbl.count > 0 THEN
      For i in l_ii_rltns_ids_tbl.FIRST .. l_ii_rltns_ids_tbl.LAST
      LOOP
        IF l_ii_rltns_ids_tbl(i).txn_relationship_id = ii_rec.txn_relationship_id THEN
           l_rltn_exists := 'Y';
        END IF;
      END LOOP;
     END IF;
      IF l_rltn_exists = 'N' THEN   -- this pulls up all the relationships that are within the same txn line whereas the existing l_ii_rltns_ids_tbl are for across the txn line rltns
       l_ii_ind := l_ii_ind + 1;

       l_ii_rltns_ids_tbl(l_ii_ind).transaction_line_id := p_transaction_line_id;
       l_ii_rltns_ids_tbl(l_ii_ind).txn_relationship_id := ii_rec.txn_relationship_id;
      END IF;

    END LOOP;


    FOR sys_rec in sys_cur
    LOOP

      csi_t_txn_systems_grp.delete_txn_system(
        p_api_version       => 1.0,
        p_commit            => fnd_api.g_false,
        p_init_msg_list     => fnd_api.g_false,
        p_validation_level  => fnd_api.g_valid_level_full,
        p_txn_system_id     => sys_rec.transaction_system_id,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END LOOP;

    csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_pty_acct_ids_tbl    => l_pty_acct_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_txn_parties_pvt.delete_txn_party_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_party_ids_tbl       => l_party_ids_tbl,
      x_txn_pty_acct_ids_tbl    => l_txn_pty_acct_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_txn_rltnshps_pvt.delete_txn_ii_rltns_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_ii_rltns_ids_tbl    => l_ii_rltns_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_txn_ous_pvt.delete_txn_org_assgn_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_org_assgn_ids_tbl   => l_org_assgn_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_txn_attribs_pvt.delete_txn_ext_attrib_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_ext_attrib_ids_tbl  => l_ext_attrib_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_txn_line_dtls_pvt.delete_txn_line_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_line_detail_ids_tbl => l_line_dtl_ids_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call table handler to delete transaction lines
   IF nvl(p_txn_line_detail_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
    csi_t_transaction_lines_pkg.delete_row(
      p_transaction_line_id => p_transaction_line_id);
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.add('Transaction Details Deleted Successfully
		for Transaction Line ID:'||to_char(p_transaction_line_id)||
		' Txn line detail ID:'||to_char(p_txn_line_detail_id));

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delete_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_transaction_dtls;

/* Overloaded routine added and used : Bug 2543266 */

  PROCEDURE get_txn_systems(
    p_txn_line_dtl_tbl   in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_systems_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_txn_system_id    number ;
    l_sys_not_found    varchar2(1) := 'Y';
    l_ind              binary_integer := 0;
    s_ind              binary_integer;

    Cursor txn_sys(p_txn_system_id IN Number) is
	   Select transaction_system_id, system_name , description,
		system_type_code, system_number, bill_to_contact_id,
		ship_to_contact_id, technical_contact_id, config_system_type,
		service_admin_contact_id, ship_to_site_use_id,
		bill_to_site_use_id, coterminate_day_month, customer_id,
		install_site_use_id, transaction_line_id, start_date_active,
		end_date_active,context, attribute1, attribute2, attribute3,
		attribute4, attribute5, attribute6, attribute7, attribute8,
		attribute9, attribute10, attribute11, attribute12,
		attribute13, attribute14, attribute15, object_version_number
	   From  csi_t_txn_systems
	   Where transaction_system_id = p_txn_system_id;

  BEGIN
    IF p_txn_line_dtl_tbl.count > 0 THEN
	 For i in p_txn_line_dtl_tbl.FIRST .. p_txn_line_dtl_tbl.LAST
	 Loop
	   l_txn_system_id := p_txn_line_dtl_tbl(i).transaction_system_id;

	   IF x_txn_systems_tbl.count > 0 THEN
	    For j in x_txn_systems_tbl.FIRST ..x_txn_systems_tbl.LAST
	    Loop
		 IF l_txn_system_id = nvl(x_txn_systems_tbl(j).transaction_system_id, -999)
		 THEN
			l_sys_not_found := 'N';
		 END IF;

	    End Loop;
	   END IF;

	   IF l_sys_not_found = 'Y'  THEN
	     For sys_cur in txn_sys(l_txn_system_id)
		Loop

      	   l_ind := l_ind + 1;

      	   x_txn_systems_tbl(l_ind).transaction_system_id := sys_cur.transaction_system_id;
      	   x_txn_systems_tbl(l_ind).transaction_line_id   := sys_cur.transaction_line_id;
      	   x_txn_systems_tbl(l_ind).system_name           := sys_cur.system_name;
      	   x_txn_systems_tbl(l_ind).description           := sys_cur.description;
      	   x_txn_systems_tbl(l_ind).system_type_code      := sys_cur.system_type_code;
      	   x_txn_systems_tbl(l_ind).system_number         := sys_cur.system_number;
      	   x_txn_systems_tbl(l_ind).customer_id           := sys_cur.customer_id;
      	   x_txn_systems_tbl(l_ind).bill_to_contact_id    := sys_cur.bill_to_contact_id;
      	   x_txn_systems_tbl(l_ind).ship_to_contact_id    := sys_cur.ship_to_contact_id;
      	   x_txn_systems_tbl(l_ind).technical_contact_id  := sys_cur.technical_contact_id;
      	   x_txn_systems_tbl(l_ind).ship_to_site_use_id   := sys_cur.ship_to_site_use_id;
      	   x_txn_systems_tbl(l_ind).bill_to_site_use_id   := sys_cur.bill_to_site_use_id;
      	   x_txn_systems_tbl(l_ind).install_site_use_id   := sys_cur.install_site_use_id;
      	   x_txn_systems_tbl(l_ind).coterminate_day_month := sys_cur.coterminate_day_month;
      	   x_txn_systems_tbl(l_ind).config_system_type    := sys_cur.config_system_type;
      	   x_txn_systems_tbl(l_ind).object_version_number := sys_cur.object_version_number;
      	   x_txn_systems_tbl(l_ind).service_admin_contact_id  := sys_cur.service_admin_contact_id;
      	   x_txn_systems_tbl(l_ind).context      := sys_cur.context;
      	   x_txn_systems_tbl(l_ind).attribute1   := sys_cur.attribute1;
      	   x_txn_systems_tbl(l_ind).attribute2   := sys_cur.attribute2;
      	   x_txn_systems_tbl(l_ind).attribute3   := sys_cur.attribute3;
      	   x_txn_systems_tbl(l_ind).attribute4   := sys_cur.attribute4;
      	   x_txn_systems_tbl(l_ind).attribute5   := sys_cur.attribute5;
      	   x_txn_systems_tbl(l_ind).attribute6   := sys_cur.attribute6;
      	   x_txn_systems_tbl(l_ind).attribute7   := sys_cur.attribute7;
      	   x_txn_systems_tbl(l_ind).attribute8   := sys_cur.attribute8;
      	   x_txn_systems_tbl(l_ind).attribute9   := sys_cur.attribute9;
      	   x_txn_systems_tbl(l_ind).attribute10  := sys_cur.attribute10;
      	   x_txn_systems_tbl(l_ind).attribute11  := sys_cur.attribute11;
      	   x_txn_systems_tbl(l_ind).attribute12  := sys_cur.attribute12;
      	   x_txn_systems_tbl(l_ind).attribute13  := sys_cur.attribute13;
      	   x_txn_systems_tbl(l_ind).attribute14  := sys_cur.attribute14;
      	   x_txn_systems_tbl(l_ind).attribute15  := sys_cur.attribute15;

		End Loop;
	   END IF;
	 End Loop;
    END IF;

  --END;

  EXCEPTION
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  End get_txn_systems;

  /* This routine builds the txn systems query and makes a dynamic sql query
     to fetch the txn systems. ROutine rerurns a table of txn systems
  */
/*
Commented for Bug 2543266 . Using overloaded routine above instead.

  PROCEDURE get_txn_systems(
    p_txn_system_id_list in  varchar2,
    x_txn_systems_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_sys_cur_id       integer;
    l_sys_rec          csi_t_datastructures_grp.txn_system_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    l_select_stmt :=
     'select transaction_system_id, transaction_line_id, system_name,'||
     ' description, system_type_code, system_number, customer_id,'||
     ' bill_to_contact_id, ship_to_contact_id, technical_contact_id,'||
     ' service_admin_contact_id, ship_to_site_use_id, bill_to_site_use_id,'||
     ' install_site_use_id, coterminate_day_month, config_system_type,'||
     ' context, attribute1, attribute2, attribute3, attribute4, attribute5,'||
     ' attribute6, attribute7, attribute8, attribute9, attribute10,'||
     ' attribute11, attribute12, attribute13, attribute14, attribute15,'||
     ' object_version_number '||
     'from csi_t_txn_systems '||
     'where transaction_system_id in '||p_txn_system_id_list;

    --csi_t_gen_utility_pvt.add(l_select_stmt);

    l_sys_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_sys_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.define_column(l_sys_cur_id,1,l_sys_rec.transaction_system_id);
    dbms_sql.define_column(l_sys_cur_id,2,l_sys_rec.transaction_line_id);
    dbms_sql.define_column(l_sys_cur_id,3,l_sys_rec.system_name,50);
    dbms_sql.define_column(l_sys_cur_id,4,l_sys_rec.description,240);
    dbms_sql.define_column(l_sys_cur_id,5,l_sys_rec.system_type_code,30);
    dbms_sql.define_column(l_sys_cur_id,6,l_sys_rec.system_number,30);
    dbms_sql.define_column(l_sys_cur_id,7,l_sys_rec.customer_id);
    dbms_sql.define_column(l_sys_cur_id,8,l_sys_rec.bill_to_contact_id);
    dbms_sql.define_column(l_sys_cur_id,9,l_sys_rec.ship_to_contact_id);
    dbms_sql.define_column(l_sys_cur_id,10,l_sys_rec.technical_contact_id);
    dbms_sql.define_column(l_sys_cur_id,11,l_sys_rec.service_admin_contact_id);
    dbms_sql.define_column(l_sys_cur_id,12,l_sys_rec.ship_to_site_use_id);
    dbms_sql.define_column(l_sys_cur_id,13,l_sys_rec.bill_to_site_use_id);
    dbms_sql.define_column(l_sys_cur_id,14,l_sys_rec.install_site_use_id);
    dbms_sql.define_column(l_sys_cur_id,15,l_sys_rec.coterminate_day_month,6);
    dbms_sql.define_column(l_sys_cur_id,16,l_sys_rec.config_system_type,30);
    dbms_sql.define_column(l_sys_cur_id,17,l_sys_rec.context,30);
    dbms_sql.define_column(l_sys_cur_id,18,l_sys_rec.attribute1,150);
    dbms_sql.define_column(l_sys_cur_id,19,l_sys_rec.attribute2,150);
    dbms_sql.define_column(l_sys_cur_id,20,l_sys_rec.attribute3,150);
    dbms_sql.define_column(l_sys_cur_id,21,l_sys_rec.attribute4,150);
    dbms_sql.define_column(l_sys_cur_id,22,l_sys_rec.attribute5,150);
    dbms_sql.define_column(l_sys_cur_id,23,l_sys_rec.attribute6,150);
    dbms_sql.define_column(l_sys_cur_id,24,l_sys_rec.attribute7,150);
    dbms_sql.define_column(l_sys_cur_id,25,l_sys_rec.attribute8,150);
    dbms_sql.define_column(l_sys_cur_id,26,l_sys_rec.attribute9,150);
    dbms_sql.define_column(l_sys_cur_id,27,l_sys_rec.attribute10,150);
    dbms_sql.define_column(l_sys_cur_id,28,l_sys_rec.attribute11,150);
    dbms_sql.define_column(l_sys_cur_id,29,l_sys_rec.attribute12,150);
    dbms_sql.define_column(l_sys_cur_id,30,l_sys_rec.attribute13,150);
    dbms_sql.define_column(l_sys_cur_id,31,l_sys_rec.attribute14,150);
    dbms_sql.define_column(l_sys_cur_id,32,l_sys_rec.attribute15,150);
    dbms_sql.define_column(l_sys_cur_id,33,l_sys_rec.object_version_number);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_sys_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_sys_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_sys_cur_id,1, x_txn_systems_tbl(l_ind).transaction_system_id);
      dbms_sql.column_value(l_sys_cur_id,2, x_txn_systems_tbl(l_ind).transaction_line_id);
      dbms_sql.column_value(l_sys_cur_id,3, x_txn_systems_tbl(l_ind).system_name);
      dbms_sql.column_value(l_sys_cur_id,4, x_txn_systems_tbl(l_ind).description);
      dbms_sql.column_value(l_sys_cur_id,5, x_txn_systems_tbl(l_ind).system_type_code);
      dbms_sql.column_value(l_sys_cur_id,6, x_txn_systems_tbl(l_ind).system_number);
      dbms_sql.column_value(l_sys_cur_id,7, x_txn_systems_tbl(l_ind).customer_id);
      dbms_sql.column_value(l_sys_cur_id,8, x_txn_systems_tbl(l_ind).bill_to_contact_id);
      dbms_sql.column_value(l_sys_cur_id,9, x_txn_systems_tbl(l_ind).ship_to_contact_id);
      dbms_sql.column_value(l_sys_cur_id,10, x_txn_systems_tbl(l_ind).technical_contact_id);
      dbms_sql.column_value(l_sys_cur_id,11, x_txn_systems_tbl(l_ind).service_admin_contact_id);
      dbms_sql.column_value(l_sys_cur_id,12, x_txn_systems_tbl(l_ind).ship_to_site_use_id);
      dbms_sql.column_value(l_sys_cur_id,13, x_txn_systems_tbl(l_ind).bill_to_site_use_id);
      dbms_sql.column_value(l_sys_cur_id,14, x_txn_systems_tbl(l_ind).install_site_use_id);
      dbms_sql.column_value(l_sys_cur_id,15, x_txn_systems_tbl(l_ind).coterminate_day_month);
      dbms_sql.column_value(l_sys_cur_id,16, x_txn_systems_tbl(l_ind).config_system_type);
      dbms_sql.column_value(l_sys_cur_id,17, x_txn_systems_tbl(l_ind).context);
      dbms_sql.column_value(l_sys_cur_id,18, x_txn_systems_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_sys_cur_id,19, x_txn_systems_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_sys_cur_id,20, x_txn_systems_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_sys_cur_id,21, x_txn_systems_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_sys_cur_id,22, x_txn_systems_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_sys_cur_id,23, x_txn_systems_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_sys_cur_id,24, x_txn_systems_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_sys_cur_id,25, x_txn_systems_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_sys_cur_id,26, x_txn_systems_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_sys_cur_id,27, x_txn_systems_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_sys_cur_id,28, x_txn_systems_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_sys_cur_id,29, x_txn_systems_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_sys_cur_id,30, x_txn_systems_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_sys_cur_id,31, x_txn_systems_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_sys_cur_id,32, x_txn_systems_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_sys_cur_id,33, x_txn_systems_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_sys_cur_id);

  EXCEPTION
    WHEN others THEN

     csi_t_gen_utility_pvt.add(sqlerrm);

     IF dbms_sql.is_open(l_sys_cur_id) THEN
       dbms_sql.close_cursor(l_sys_cur_id);
     END IF;

  END get_txn_systems;

*/

  PROCEDURE get_transaction_details(
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level          IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_query_rec        IN     csi_t_datastructures_grp.txn_line_query_rec
    ,p_txn_line_detail_query_rec IN     csi_t_datastructures_grp.txn_line_detail_query_rec
    ,x_txn_line_detail_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,p_get_parties_flag          IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_party_detail_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,p_get_pty_accts_flag        IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_pty_acct_detail_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,p_get_ii_rltns_flag         IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_ii_rltns_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,p_get_org_assgns_flag       IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_org_assgn_tbl            OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,p_get_ext_attrib_vals_flag  IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_ext_attrib_vals_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,p_get_csi_attribs_flag      IN     VARCHAR2 := fnd_api.g_false
    ,x_csi_ext_attribs_tbl          OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl
    ,p_get_csi_iea_values_flag   IN     VARCHAR2 := fnd_api.g_false
    ,x_csi_iea_values_tbl           OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl
    ,p_get_txn_systems_flag      IN     VARCHAR2 := fnd_api.g_false
    ,x_txn_systems_tbl              OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'get_transaction_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;

    l_line_dtl_id_list        varchar2(1000);
    l_party_dtl_id_list       varchar2(1000);
    l_txn_line_id_list        varchar2(1000);
    l_instance_id_list        varchar2(1000);
    l_txn_system_id_list      varchar2(1000);

    l_txn_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_dtl_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl            csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl           csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ext_attribs_tbl     csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_ea_vals_tbl         csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl         csi_t_datastructures_grp.txn_systems_tbl;
    l_index                     NUMBER := 0 ;
    l_txn_line_id             NUMBER ;
    l_relation_exists          BOOLEAN ;

CURSOR txn_ii_rel_cur (c_txn_line_detail_id IN NUMBER)
IS
SELECT a.txn_relationship_id, a.transaction_line_id,a.csi_inst_relationship_id,
     a.subject_id, a.subject_type,  a.object_id, a.object_type ,  a.relationship_type_code, a.display_order,
      a.position_reference, a.mandatory_flag, a.active_start_date, a.active_end_date,
      a.context, a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5,
      a.attribute6, a.attribute7, a.attribute8, a.attribute9, a.attribute10, a.attribute11,
      a.attribute12, a.attribute13, a.attribute14, a.attribute15, a.object_version_number ,
a.sub_config_inst_hdr_id ,  a.sub_config_inst_rev_num ,  a.sub_config_inst_item_id ,
a.obj_config_inst_hdr_id ,  a.obj_config_inst_rev_num ,  a.obj_config_inst_item_id, a.target_commitment_date , a.transfer_components_flag
FROM   csi_t_ii_relationships a
WHERE ((a.object_id = c_txn_line_detail_id
AND a.object_type = 'T') OR (a.subject_id = c_txn_line_detail_id
AND a.subject_type = 'T'))
GROUP BY a.txn_relationship_id, a.transaction_line_id,a.csi_inst_relationship_id, a.subject_id, a.subject_type, a.object_id, a.object_type , a.relationship_type_code, a.display_order,
      a.position_reference, a.mandatory_flag, a.active_start_date, a.active_end_date,
      a.context, a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5,
      a.attribute6, a.attribute7, a.attribute8, a.attribute9, a.attribute10, a.attribute11,
      a.attribute12, a.attribute13, a.attribute14, a.attribute15, a.object_version_number ,
a.sub_config_inst_hdr_id ,  a.sub_config_inst_rev_num ,  a.sub_config_inst_item_id ,
a.obj_config_inst_hdr_id ,  a.obj_config_inst_rev_num ,  a.obj_config_inst_item_id , a.target_commitment_date , a.transfer_components_flag;

l_swap_loc_type     VARCHAR2(60);
l_swap_loc_id       NUMBER;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Get_Transaction_Dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.dump_txn_line_query_rec(
        p_txn_line_query_rec => p_txn_line_query_rec);

      csi_t_gen_utility_pvt.dump_txn_line_detail_query_rec(
        p_txn_line_detail_query_rec => p_txn_line_detail_query_rec);

    END IF;

    -- Main API code

    csi_t_txn_line_dtls_pvt.get_txn_line_dtls(
      p_txn_line_query_rec         => p_txn_line_query_rec,
      p_txn_line_detail_query_rec  => p_txn_line_detail_query_rec,
      x_txn_line_dtl_tbl           => l_txn_line_dtl_tbl,
      x_return_status              => l_return_status);

    -- 07-17 Modifed while CZ enhancements
    -- Logic for getting relations changed, now it is driven
    -- by the transaction line details return by the csi_t_txn_line_dtls_pvt.get_txn_line_dtls API
   IF l_txn_line_dtl_tbl.COUNT > 0
   THEN

      csi_t_gen_utility_pvt.add('l_txn_line_dtl_tbl.COUNT :'||l_txn_line_dtl_tbl.COUNT);

    FOR i IN l_txn_line_dtl_tbl.FIRST .. l_txn_line_dtl_tbl.LAST
    LOOP

     /*  Commented for Bug 3419098
      -- Begin swap values for location_id and Install_location_id

      IF l_txn_line_dtl_tbl(i).location_id is not null
      THEN
        l_swap_loc_type := l_txn_line_dtl_tbl(i).Install_location_type_code;
        l_swap_loc_id   := l_txn_line_dtl_tbl(i).Install_location_id;

        l_txn_line_dtl_tbl(i).Install_location_type_code := l_txn_line_dtl_tbl(i).location_type_code;
        l_txn_line_dtl_tbl(i).Install_location_id := l_txn_line_dtl_tbl(i).location_id;

        l_txn_line_dtl_tbl(i).location_id         := l_swap_loc_id;
        l_txn_line_dtl_tbl(i).location_type_code  := l_swap_loc_type;
      END IF;

      -- End swap values for location_id and Install_location_id
     End comment for Bug 3419098  */

      csi_t_gen_utility_pvt.add('Line Dtl ID'||i||': '||l_txn_line_dtl_tbl(i).txn_line_detail_id);
      FOR  txn_ii_rel_rec IN txn_ii_rel_cur(l_txn_line_dtl_tbl(i).txn_line_detail_id)
      LOOP
         l_relation_exists := FALSE ;
       IF x_txn_ii_rltns_tbl.COUNT > 0
       THEN
          FOR j IN x_txn_ii_rltns_tbl.FIRST .. x_txn_ii_rltns_tbl.LAST
          LOOP
             IF txn_ii_rel_rec.txn_relationship_id =
                              x_txn_ii_rltns_tbl(j).txn_relationship_id
             THEN
                l_relation_exists := TRUE ;
                EXIT ;
             END IF ;
          END LOOP ; --j IN x_txn_ii_rltns_tbl.FIRST
       END IF ; --x_txn_ii_rltns_tbl.COUNT > 0

       IF NOT l_relation_exists
       THEN
         l_index :=  NVL(x_txn_ii_rltns_tbl.LAST,0) + 1 ;

         x_txn_ii_rltns_tbl(l_index).txn_relationship_id := txn_ii_rel_rec.txn_relationship_id  ;
         x_txn_ii_rltns_tbl(l_index).transaction_line_id := txn_ii_rel_rec.transaction_line_id;
         x_txn_ii_rltns_tbl(l_index).csi_inst_relationship_id := txn_ii_rel_rec.csi_inst_relationship_id;
         x_txn_ii_rltns_tbl(l_index).subject_id := txn_ii_rel_rec.subject_id ;
         x_txn_ii_rltns_tbl(l_index).subject_type := txn_ii_rel_rec.subject_type ;
         x_txn_ii_rltns_tbl(l_index).object_id := txn_ii_rel_rec.object_id ;
         x_txn_ii_rltns_tbl(l_index).object_type := txn_ii_rel_rec.object_type ;
         x_txn_ii_rltns_tbl(l_index).relationship_type_code := txn_ii_rel_rec.relationship_type_code ;
         x_txn_ii_rltns_tbl(l_index).display_order := txn_ii_rel_rec.display_order ;
         x_txn_ii_rltns_tbl(l_index).position_reference := txn_ii_rel_rec.position_reference  ;
         x_txn_ii_rltns_tbl(l_index).mandatory_flag := txn_ii_rel_rec.mandatory_flag ;
         x_txn_ii_rltns_tbl(l_index).active_start_date := txn_ii_rel_rec.active_start_date  ;
         x_txn_ii_rltns_tbl(l_index).active_end_date := txn_ii_rel_rec.active_end_date  ;
         x_txn_ii_rltns_tbl(l_index).attribute2 := txn_ii_rel_rec.attribute2  ;
         x_txn_ii_rltns_tbl(l_index).attribute3 := txn_ii_rel_rec.attribute3  ;
         x_txn_ii_rltns_tbl(l_index).attribute4 := txn_ii_rel_rec.attribute4  ;
         x_txn_ii_rltns_tbl(l_index).attribute5 := txn_ii_rel_rec.attribute5  ;
         x_txn_ii_rltns_tbl(l_index).attribute6 := txn_ii_rel_rec.attribute6  ;
         x_txn_ii_rltns_tbl(l_index).attribute7 := txn_ii_rel_rec.attribute7  ;
         x_txn_ii_rltns_tbl(l_index).attribute8 := txn_ii_rel_rec.attribute8  ;
         x_txn_ii_rltns_tbl(l_index).attribute9 := txn_ii_rel_rec.attribute9  ;
         x_txn_ii_rltns_tbl(l_index).attribute10 := txn_ii_rel_rec.attribute10  ;
         x_txn_ii_rltns_tbl(l_index).attribute11 := txn_ii_rel_rec.attribute11 ;
         x_txn_ii_rltns_tbl(l_index).attribute12 := txn_ii_rel_rec.attribute12  ;
         x_txn_ii_rltns_tbl(l_index).attribute13 := txn_ii_rel_rec.attribute13  ;
         x_txn_ii_rltns_tbl(l_index).attribute14 := txn_ii_rel_rec.attribute14  ;
         x_txn_ii_rltns_tbl(l_index).attribute15 := txn_ii_rel_rec.attribute15  ;
         x_txn_ii_rltns_tbl(l_index).object_version_number  := txn_ii_rel_rec.object_version_number   ;
         x_txn_ii_rltns_tbl(l_index).sub_config_inst_hdr_id  := txn_ii_rel_rec.sub_config_inst_hdr_id   ;
         x_txn_ii_rltns_tbl(l_index).sub_config_inst_rev_num  := txn_ii_rel_rec.sub_config_inst_rev_num   ;
         x_txn_ii_rltns_tbl(l_index).sub_config_inst_item_id  := txn_ii_rel_rec.sub_config_inst_item_id   ;
         x_txn_ii_rltns_tbl(l_index).obj_config_inst_hdr_id  := txn_ii_rel_rec.obj_config_inst_hdr_id   ;
         x_txn_ii_rltns_tbl(l_index).obj_config_inst_rev_num  := txn_ii_rel_rec.obj_config_inst_rev_num   ;
         x_txn_ii_rltns_tbl(l_index).obj_config_inst_item_id  := txn_ii_rel_rec.obj_config_inst_item_id   ;
         x_txn_ii_rltns_tbl(l_index).target_commitment_date  := txn_ii_rel_rec.target_commitment_date   ;
         x_txn_ii_rltns_tbl(l_index).transfer_components_flag := txn_ii_rel_rec.transfer_components_flag ;

      		csi_t_gen_utility_pvt.add('Transaction Relationship ID'||l_index||': '||x_txn_ii_rltns_tbl(l_index).txn_relationship_id);

        END IF ; --l_retaionhip_exists
      END LOOP ; --txn_ii_rel_rec IN txn_ii_rel_cur
    END LOOP ; --l_txn_line_dtl_tbl.FIRST .. l_txn_line_dtl_tbl.LAST
   END IF ; ---l_txn_line_dtl_tbl.COUNT>0

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      csi_t_gen_utility_pvt.add('csi_t_txn_line_dtls_pvt.get_txn_line_dtls failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    x_txn_line_detail_tbl := l_txn_line_dtl_tbl;

    IF l_txn_line_dtl_tbl.COUNT > 0 THEN

      l_line_dtl_id_list := null;

      IF p_get_parties_flag = fnd_api.g_true THEN

        csi_t_txn_parties_pvt.get_all_party_dtls(
          p_line_detail_tbl  => l_txn_line_dtl_tbl,
          x_party_detail_tbl => l_txn_party_dtl_tbl,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_txn_party_detail_tbl := l_txn_party_dtl_tbl;

        IF l_txn_party_dtl_tbl.COUNT > 0 THEN

/* Commented for Bug 2543266

          l_party_dtl_id_list := null;

          csi_t_utilities_pvt.build_party_dtl_id_list(
            p_txn_party_detial_tbl => l_txn_party_dtl_tbl,
            x_party_dtl_id_list    => l_party_dtl_id_list,
            x_return_status        => l_return_status);

          csi_t_gen_utility_pvt.add('Party Dtl IDs: '||l_party_dtl_id_list);
*/

	 	For tdp in l_txn_party_dtl_tbl.FIRST .. l_txn_party_dtl_tbl.LAST
	 	LOOP
		-- Displaying the TD Party Detail's resultset... Replacement for the Commented code below . Bug 2543266

      		csi_t_gen_utility_pvt.add('Party Dtl ID'||tdp||': '||l_txn_party_dtl_tbl(tdp).txn_party_detail_id);

	 	END LOOP;

          IF p_get_pty_accts_flag = fnd_api.g_true THEN

            csi_t_txn_parties_pvt.get_all_pty_acct_dtls(
              p_party_detail_tbl    => l_txn_party_dtl_tbl,
              x_pty_acct_detail_tbl => l_txn_pty_acct_dtl_tbl,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            x_txn_pty_acct_detail_tbl := l_txn_pty_acct_dtl_tbl;

          END IF;

        END IF;
      END IF;

      IF p_get_ext_attrib_vals_flag = fnd_api.g_true THEN

        csi_t_txn_attribs_pvt.get_all_ext_attrib_dtls(
          p_txn_line_detail_tbl => l_txn_line_dtl_tbl,
          x_ext_attrib_tbl      => l_ext_attrib_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_txn_ext_attrib_vals_tbl := l_ext_attrib_tbl;

      END IF;

      IF p_get_csi_attribs_flag = fnd_api.g_true THEN

        csi_t_txn_attribs_pvt.get_all_csi_ext_attribs(
          p_txn_line_detail_tbl => l_txn_line_dtl_tbl,
          x_csi_ext_attribs_tbl => l_csi_ext_attribs_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_csi_ext_attribs_tbl := l_csi_ext_attribs_tbl;

      END IF;

      IF p_get_csi_iea_values_flag = fnd_api.g_true THEN

        csi_t_txn_attribs_pvt.get_all_csi_ext_attrib_vals(
          p_txn_line_detail_tbl => l_txn_line_dtl_tbl,
          x_csi_ea_vals_tbl     => l_csi_ea_vals_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_csi_iea_values_tbl := l_csi_ea_vals_tbl;

      END IF;

      IF p_get_org_assgns_flag = fnd_api.g_true THEN

        csi_t_txn_ous_pvt.get_all_org_assgn_dtls(
          p_txn_line_detail_tbl => l_txn_line_dtl_tbl,
          x_org_assgn_tbl       => l_org_assgn_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_txn_org_assgn_tbl := l_org_assgn_tbl;

      END IF;

    END IF;

    ---Kishor 05/09
  IF l_txn_line_dtl_tbl.COUNT > 0
  THEN
    IF NVL(p_txn_line_query_rec.transaction_line_id,fnd_api.g_miss_num) <>
        fnd_api.g_miss_num
    THEN
       l_txn_line_id := p_txn_line_query_rec.transaction_line_id ;
    ELSE
       l_txn_line_id := l_txn_line_dtl_tbl(1).transaction_line_id ;
    END IF ;
  END IF ;

    -- get txn systems
    IF p_get_txn_systems_flag = fnd_api.g_true THEN

/* Changes for Bug 2543266
      l_txn_system_id_list := null;

      csi_t_utilities_pvt.build_txn_system_id_list(
        p_txn_line_detial_tbl => l_txn_line_dtl_tbl,
        x_txn_system_id_list  => l_txn_system_id_list,
        x_return_status       => l_return_status);

      IF l_txn_system_id_list is not null then

        csi_t_gen_utility_pvt.add('Txn System IDs List: '||l_txn_system_id_list);

        get_txn_systems(
          p_txn_system_id_list => l_txn_system_id_list,
          x_txn_systems_tbl    => l_txn_systems_tbl,
          x_return_status      => l_return_status);

        x_txn_systems_tbl := l_txn_systems_tbl;

      END IF;
*/

        get_txn_systems(
          p_txn_line_dtl_tbl => l_txn_line_dtl_tbl,
          x_txn_systems_tbl  => l_txn_systems_tbl,
          x_return_status    => l_return_status);

        x_txn_systems_tbl := l_txn_systems_tbl;

        IF l_txn_systems_tbl.COUNT > 0 THEN
	 	For tds in l_txn_systems_tbl.FIRST .. l_txn_systems_tbl.LAST
	 	LOOP
		-- Displaying the TD Systems's resultset... Replacement for the Commented code below . Bug 2543266

      		csi_t_gen_utility_pvt.add('Transaction System ID'||tds||': '||l_txn_systems_tbl(tds).transaction_system_id);

	 	END LOOP;
	END IF;

    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

      csi_t_gen_utility_pvt.add('Get Transaction Details Successful');

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END get_transaction_details;

  FUNCTION check_td_for_create(
    p_txn_line_dtl_id  in number,
    p_txn_line_dtl_tbl in csi_t_datastructures_grp.txn_line_detail_tbl)
  RETURN boolean
  IS
    l_return boolean := FALSE;
  BEGIN
    IF p_txn_line_dtl_tbl.count > 0 THEN
      FOR l_ind in p_txn_line_dtl_tbl.first .. p_txn_line_dtl_tbl.LAST
      LOOP
        IF p_txn_line_dtl_id = p_txn_line_dtl_tbl(l_ind).txn_line_detail_id
        THEN
          l_return := TRUE;
          exit;
        END IF;
      END LOOP;
    END IF;
    return l_return;
  END check_td_for_create;

  PROCEDURE split_transaction_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    p_upd_txn_line_rec      IN  csi_t_datastructures_grp.txn_line_rec,
    p_upd_txn_line_dtl_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    px_crt_txn_line_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_crt_txn_line_dtl_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    l_api_name    CONSTANT VARCHAR2(30)  := 'split_transaction_dtls';
    l_api_version CONSTANT NUMBER        := 1.0;
    l_debug_level          NUMBER;

    l_return_status        VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_c_line_ind           binary_integer;
    l_c_pty_ind            binary_integer;
    l_c_pa_ind             binary_integer;
    l_c_ii_ind             binary_integer;
    l_c_oa_ind             binary_integer;
    l_c_ea_ind             binary_integer;

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_c_line_dtl_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_c_pty_dtl_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_c_pty_acct_tbl       csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_c_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_c_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_c_txn_systems_tbl    csi_t_datastructures_grp.txn_systems_tbl;

    l_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl           csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl          csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;

    l_ln_id_ind            binary_integer;

    l_line_dtl_ids_tbl     csi_t_datastructures_grp.txn_line_detail_ids_tbl;
    l_txn_line_id          csi_t_transaction_lines.transaction_line_id%type;

    l_create               boolean := FALSE;

  BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT split_transaction_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    csi_t_gen_utility_pvt.add('p_upd_txn_line_rec');

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_upd_txn_line_rec);

    END IF;

    -- Main API code starts here

    -- call the update api for the update information
    csi_t_txn_details_grp.update_txn_line_dtls(
      p_api_version              => p_api_version,
      p_commit                   => p_commit,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      p_txn_line_rec             => p_upd_txn_line_rec,
      p_txn_line_detail_tbl      => p_upd_txn_line_dtl_tbl,
      px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
      px_txn_party_detail_tbl    => l_pty_dtl_tbl,
      px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
      px_txn_org_assgn_tbl       => l_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    --loop the create table
    l_ln_id_ind := 0;

    IF px_crt_txn_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ind in px_crt_txn_line_dtl_tbl.FIRST .. px_crt_txn_line_dtl_tbl.LAST
      LOOP

        l_create :=
          check_td_for_create(
            p_txn_line_dtl_id  =>
              px_crt_txn_line_dtl_tbl(l_ind).txn_line_detail_id,
            p_txn_line_dtl_tbl => p_upd_txn_line_dtl_tbl);

        IF (l_create) THEN

          l_txn_line_detail_query_rec.txn_line_detail_id :=
            px_crt_txn_line_dtl_tbl(l_ind).txn_line_detail_id;

          --call the get api to fetch all the child entities
          csi_t_txn_details_grp.get_transaction_details(
            p_api_version              => p_api_version,
            p_commit                   => p_commit,
            p_init_msg_list            => p_init_msg_list,
            p_validation_level         => p_validation_level,
            p_txn_line_query_rec       => l_txn_line_query_rec,
            p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl      => l_line_dtl_tbl,
            p_get_parties_flag         => 'Y',
            x_txn_party_detail_tbl     => l_pty_dtl_tbl,
            p_get_pty_accts_flag       => 'Y',
            x_txn_pty_acct_detail_tbl  => l_pty_acct_tbl,
            p_get_ii_rltns_flag        => 'Y',
            x_txn_ii_rltns_tbl         => l_ii_rltns_tbl,
            p_get_org_assgns_flag      => 'Y',
            x_txn_org_assgn_tbl        => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag => 'Y',
            x_txn_ext_attrib_vals_tbl  => l_ext_attrib_tbl,
            p_get_csi_attribs_flag     => 'N',
            x_csi_ext_attribs_tbl      => l_csi_ea_tbl,
            p_get_csi_iea_values_flag  => 'N',
            x_csi_iea_values_tbl       => l_csi_eav_tbl,
            p_get_txn_systems_flag     => 'Y',
            x_txn_systems_tbl          => l_txn_systems_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          l_line_dtl_tbl(1).quantity :=
            px_crt_txn_line_dtl_tbl(l_ind).quantity;

          -- append to the table for create (call merge tables)

          csi_t_utilities_pvt.merge_tables(
            px_line_dtl_tbl    => l_c_line_dtl_tbl,
            px_pty_dtl_tbl     => l_c_pty_dtl_tbl,
            px_pty_acct_tbl    => l_c_pty_acct_tbl,
            px_ii_rltns_tbl    => l_c_ii_rltns_tbl,
            px_org_assgn_tbl   => l_c_org_assgn_tbl,
            px_ext_attrib_tbl  => l_c_ext_attrib_tbl,
            px_txn_systems_tbl => l_c_txn_systems_tbl,
            p_line_dtl_tbl     => l_line_dtl_tbl,
            p_pty_dtl_tbl      => l_pty_dtl_tbl,
            p_pty_acct_tbl     => l_pty_acct_tbl,
            p_ii_rltns_tbl     => l_ii_rltns_tbl,
            p_org_assgn_tbl    => l_org_assgn_tbl,
            p_ext_attrib_tbl   => l_ext_attrib_tbl,
            p_txn_systems_tbl  => l_txn_systems_tbl);

        ELSE
          -- populate txn_line_dtl_ids table to switch the txn_line_id
          l_ln_id_ind := l_ln_id_ind +1;

          l_line_dtl_ids_tbl(l_ln_id_ind).txn_line_detail_id :=
                          px_crt_txn_line_dtl_tbl(l_ind).txn_line_detail_id;

        END IF;

      END LOOP;

    END IF;

    IF l_c_line_dtl_tbl.count > 0 THEN

      csi_t_utilities_pvt.convert_ids_to_index(
        px_line_dtl_tbl    => l_c_line_dtl_tbl,
        px_pty_dtl_tbl     => l_c_pty_dtl_tbl,
        px_pty_acct_tbl    => l_c_pty_acct_tbl,
        px_ii_rltns_tbl    => l_c_ii_rltns_tbl,
        px_org_assgn_tbl   => l_c_org_assgn_tbl,
        px_ext_attrib_tbl  => l_c_ext_attrib_tbl,
        px_txn_systems_tbl => l_c_txn_systems_tbl);

      csi_t_txn_details_grp.create_transaction_dtls(
        p_api_version              => p_api_version,
        p_commit                   => p_commit,
        p_init_msg_list            => p_init_msg_list,
        p_validation_level         => p_validation_level,
        px_txn_line_rec            => px_crt_txn_line_rec,
        px_txn_line_detail_tbl     => l_c_line_dtl_tbl,
        px_txn_party_detail_tbl    => l_c_pty_dtl_tbl,
        px_txn_pty_acct_detail_tbl => l_c_pty_acct_tbl,
        px_txn_ii_rltns_tbl        => l_c_ii_rltns_tbl,
        px_txn_org_assgn_tbl       => l_c_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl => l_c_ext_attrib_tbl,
        px_txn_systems_tbl         => l_c_txn_systems_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_success THEN

        SELECT transaction_line_id
        INTO   l_txn_line_id
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_table = px_crt_txn_line_rec.source_transaction_table
        AND    source_transaction_id    = px_crt_txn_line_rec.source_transaction_id;

      ELSE
        raise fnd_api.g_exc_error;
      END IF;

    ELSE

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_transaction_lines_pkg');

      csi_t_transaction_lines_pkg.insert_row(
        px_transaction_line_id     => l_txn_line_id,
        p_source_transaction_type_id  => px_crt_txn_line_rec.source_transaction_type_id,
        p_source_transaction_table => px_crt_txn_line_rec.source_transaction_table,
        p_source_txn_header_id     => px_crt_txn_line_rec.source_txn_header_id,
        p_source_transaction_id    => px_crt_txn_line_rec.source_transaction_id,
        -- Added for CZ Integration (Begin)
          p_config_session_hdr_id  => px_crt_txn_line_rec.config_session_hdr_id ,
          p_config_session_rev_num  => px_crt_txn_line_rec.config_session_rev_num ,
          p_config_session_item_id  => px_crt_txn_line_rec.config_session_item_id ,
          p_config_valid_status  => px_crt_txn_line_rec.config_valid_status ,
          p_source_transaction_status  => px_crt_txn_line_rec.source_transaction_status ,
        -- Added for CZ Integration (End)
        p_error_code               => px_crt_txn_line_rec.error_code,
        p_error_explanation        => px_crt_txn_line_rec.error_explanation,
        p_processing_status        => px_crt_txn_line_rec.processing_status,
        p_attribute1               => px_crt_txn_line_rec.attribute1,
        p_attribute2               => px_crt_txn_line_rec.attribute2,
        p_attribute3               => px_crt_txn_line_rec.attribute3,
        p_attribute4               => px_crt_txn_line_rec.attribute4,
        p_attribute5               => px_crt_txn_line_rec.attribute5,
        p_attribute6               => px_crt_txn_line_rec.attribute6,
        p_attribute7               => px_crt_txn_line_rec.attribute7,
        p_attribute8               => px_crt_txn_line_rec.attribute8,
        p_attribute9               => px_crt_txn_line_rec.attribute9,
        p_attribute10              => px_crt_txn_line_rec.attribute10,
        p_attribute11              => px_crt_txn_line_rec.attribute11,
        p_attribute12              => px_crt_txn_line_rec.attribute12,
        p_attribute13              => px_crt_txn_line_rec.attribute13,
        p_attribute14              => px_crt_txn_line_rec.attribute14,
        p_attribute15              => px_crt_txn_line_rec.attribute15,
        p_created_by               => fnd_global.user_id,
        p_creation_date            => sysdate,
        p_last_updated_by          => fnd_global.user_id,
        p_last_update_date         => sysdate,
        p_last_update_login        => fnd_global.login_id,
        p_object_version_number    => 1.0,
        p_context                  => px_crt_txn_line_rec.context);

    END IF;

    IF l_line_dtl_ids_tbl.count > 0 THEN

      FOR l_ind in l_line_dtl_ids_tbl.FIRST .. l_line_dtl_ids_tbl.LAST
      LOOP

        UPDATE csi_t_txn_line_details
        SET    transaction_line_id = l_txn_line_id
        WHERE  txn_line_detail_id  = l_line_dtl_ids_tbl(l_ind).txn_line_detail_id;

      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO split_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO split_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN others THEN

      ROLLBACK TO split_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END split_transaction_dtls;

  PROCEDURE copy_transaction_dtls(
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec      IN     csi_t_datastructures_grp.txn_line_rec,
    px_new_txn_line_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_copy_parties_flag     IN     varchar2 := fnd_api.g_true,
    p_copy_pty_accts_flag   IN     varchar2 := fnd_api.g_true,
    p_copy_ii_rltns_flag    IN     varchar2 := fnd_api.g_true,
    p_copy_org_assgn_flag   IN     varchar2 := fnd_api.g_true,
    p_copy_ext_attribs_flag IN     varchar2 := fnd_api.g_true,
    p_copy_txn_systems_flag IN     varchar2 := fnd_api.g_true,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2)
  IS

    l_api_name    CONSTANT VARCHAR2(30)  := 'copy_transaction_dtls';
    l_api_version CONSTANT NUMBER        := 1.0;
    l_debug_level          NUMBER;

    l_return_status        VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl           csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl          csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;

    l_txn_line_id          csi_t_transaction_lines.transaction_line_id%type;
    l_txn_line_query_rec   csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec   csi_t_datastructures_grp.txn_line_detail_query_rec;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT copy_transaction_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;
    --debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => g_pkg_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.add('Source transaction line record :');

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_src_txn_line_rec);

      csi_t_gen_utility_pvt.add('Destination transaction line record :');

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => px_new_txn_line_rec);

    END IF;

    -- Main API code starts here

    -- build the txn_line_query_rec

    l_txn_line_query_rec.transaction_line_id      :=
                    p_src_txn_line_rec.transaction_line_id;
    l_txn_line_query_rec.source_transaction_table :=
                    p_src_txn_line_rec.source_transaction_table;
    l_txn_line_query_rec.source_transaction_id    :=
                    p_src_txn_line_rec.source_transaction_id;

    -- call the get api

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version              => p_api_version,
      p_commit                   => p_commit,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      p_txn_line_query_rec       => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl      => l_line_dtl_tbl,
      p_get_parties_flag         => p_copy_parties_flag,
      x_txn_party_detail_tbl     => l_pty_dtl_tbl,
      p_get_pty_accts_flag       => p_copy_pty_accts_flag,
      x_txn_pty_acct_detail_tbl  => l_pty_acct_tbl,
      ---05/20 Kishor DONT copy the relations , so dont get it.
      p_get_ii_rltns_flag        => fnd_api.g_false ,
      x_txn_ii_rltns_tbl         => l_ii_rltns_tbl,
      p_get_org_assgns_flag      => p_copy_org_assgn_flag,
      x_txn_org_assgn_tbl        => l_org_assgn_tbl,
      p_get_ext_attrib_vals_flag => p_copy_ext_attribs_flag,
      x_txn_ext_attrib_vals_tbl  => l_ext_attrib_tbl,
      p_get_csi_attribs_flag     => fnd_api.g_false,
      x_csi_ext_attribs_tbl      => l_csi_ea_tbl,
      p_get_csi_iea_values_flag  => fnd_api.g_false,
      x_csi_iea_values_tbl       => l_csi_eav_tbl,
      p_get_txn_systems_flag     => p_copy_txn_systems_flag,
      x_txn_systems_tbl          => l_txn_systems_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      csi_t_gen_utility_pvt.add('Getting the source transaction details for copy failed.');
      raise fnd_api.g_exc_error;
    END IF;
    csi_t_gen_utility_pvt.add('II rltns count before copying : '||l_ii_rltns_tbl.count);

   csi_t_gen_utility_pvt.add(l_txn_systems_tbl.count);

   IF l_txn_systems_tbl.count > 0 THEN
     csi_t_gen_utility_pvt.dump_txn_systems_rec(l_txn_systems_tbl(1));
   END IF;

   --Kishor 05/15 set the source txn line detail id
   FOR i IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
   LOOP
      csi_t_gen_utility_pvt.add('Copying src txn line detail id');
      l_line_dtl_tbl(i).source_txn_line_detail_id := l_line_dtl_tbl(i).txn_line_detail_id ;
      csi_t_gen_utility_pvt.add('l_line_dtl_tbl(i).source_txn_line_detail_id :'|| l_line_dtl_tbl(i).source_txn_line_detail_id);
   END LOOP ;

    -- translate the ids in to index
    csi_t_utilities_pvt.convert_ids_to_index(
      px_line_dtl_tbl    => l_line_dtl_tbl,
      px_pty_dtl_tbl     => l_pty_dtl_tbl,
      px_pty_acct_tbl    => l_pty_acct_tbl,
      px_ii_rltns_tbl    => l_ii_rltns_tbl,
      px_org_assgn_tbl   => l_org_assgn_tbl,
      px_ext_attrib_tbl  => l_ext_attrib_tbl,
      px_txn_systems_tbl => l_txn_systems_tbl);

   csi_t_gen_utility_pvt.add(l_txn_systems_tbl.count);
   csi_t_gen_utility_pvt.add('II rltns count after converting ids to indexes: '||l_ii_rltns_tbl.count);
   csi_t_gen_utility_pvt.add('Line Dtl index :'|| l_line_dtl_tbl(1).txn_line_detail_id);

   IF l_txn_systems_tbl.count > 0 THEN
     csi_t_gen_utility_pvt.dump_txn_systems_rec(l_txn_systems_tbl(1));
   END IF;

   -- call the create transaction dtls api
   csi_t_txn_details_grp.create_transaction_dtls(
      p_api_version              => p_api_version,
      p_commit                   => p_commit,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      px_txn_line_rec            => px_new_txn_line_rec,
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
      csi_t_gen_utility_pvt.add('Creating the transaction details for copy failed.');
      raise fnd_api.g_exc_error;
    END IF;

    csi_t_gen_utility_pvt.add('Transaction details copied successfully.');
    csi_t_gen_utility_pvt.add('II rltns count after copying : '||l_ii_rltns_tbl.count);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO copy_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO copy_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO copy_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END copy_transaction_dtls;

PROCEDURE split_transaction_details(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec        IN  csi_t_datastructures_grp.txn_line_rec,
    px_split_txn_line_rec     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_line_dtl_tbl           IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_pty_dtl_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_pty_acct_tbl            OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_org_assgn_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_txn_ext_attrib_vals_tbl OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_txn_systems_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  ) IS

    l_item_control_rec            csi_order_ship_pub.item_control_rec;
    l_txn_line_query_rec          csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_systems_tbl             csi_t_datastructures_grp.txn_systems_tbl;
    l_line_dtl_tbl                csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl                 csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl                csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl                csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl               csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl              csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl                  csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl                 csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_line_id                 csi_t_transaction_lines.transaction_line_id%type;
    l_txn_line_detail_query_rec   csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_return_status               varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                   number;
    l_msg_data                    varchar2(2000);
    l_api_name                    CONSTANT varchar2(30)  := 'split_transaction_details';
    l_api_version                 CONSTANT number        := 1.0;
    l_debug_level                 number;
    l_split_line_qty              number := 0;
    l_match_txn_dtl_qty           number := 0;
    l_tab_ind                     number;
  BEGIN

   -- Standard Start of API savepoint
    SAVEPOINT split_transaction_details;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;

   --debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => g_pkg_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF nvl(px_split_txn_line_rec.source_transaction_id,fnd_api.g_miss_num) = fnd_api.g_miss_num OR
      nvl(px_split_txn_line_rec.source_transaction_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num OR
      nvl(p_src_txn_line_rec.source_transaction_id,fnd_api.g_miss_num) = fnd_api.g_miss_num OR
      nvl(p_src_txn_line_rec.source_transaction_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

      x_msg_data      := 'Invalid parameters passed';
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.add('Source transaction line record :');

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_src_txn_line_rec);

      csi_t_gen_utility_pvt.add('Destination transaction line record :');

      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => px_split_txn_line_rec);

    END IF;

    -- Main API code starts here
    -- build the txn_line_query_rec

    l_txn_line_query_rec.transaction_line_id      :=
                    p_src_txn_line_rec.transaction_line_id;
    l_txn_line_query_rec.source_transaction_table :=
                    p_src_txn_line_rec.source_transaction_table;
    l_txn_line_query_rec.source_transaction_id    :=
                    p_src_txn_line_rec.source_transaction_id;


    csi_t_txn_details_grp.get_transaction_details(
      p_api_version              => l_api_version,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => fnd_api.g_false,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_txn_line_query_rec       => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl      => l_line_dtl_tbl,
      p_get_parties_flag         => fnd_api.g_true,
      x_txn_party_detail_tbl     => l_pty_dtl_tbl,
      p_get_pty_accts_flag       => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl  => l_pty_acct_tbl,
      p_get_ii_rltns_flag        => fnd_api.g_false ,
      x_txn_ii_rltns_tbl         => l_ii_rltns_tbl,
      p_get_org_assgns_flag      => fnd_api.g_true,
      x_txn_org_assgn_tbl        => l_org_assgn_tbl,
      p_get_ext_attrib_vals_flag => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl  => l_ext_attrib_tbl,
      p_get_csi_attribs_flag     => fnd_api.g_false,
      x_csi_ext_attribs_tbl      => l_csi_ea_tbl,
      p_get_csi_iea_values_flag  => fnd_api.g_false,
      x_csi_iea_values_tbl       => l_csi_eav_tbl,
      p_get_txn_systems_flag     => fnd_api.g_true,
      x_txn_systems_tbl          => l_txn_systems_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_debug_level > 1 AND l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Getting the source transaction details for copy failed.');
      raise fnd_api.g_exc_error;
    END IF;

    BEGIN
       SELECT ordered_quantity
       INTO   l_split_line_qty
       FROM   oe_order_lines_all
       WHERE  line_id   = px_split_txn_line_rec.source_transaction_id
       AND    header_id = nvl(px_split_txn_line_rec.source_txn_header_id,header_id);

       IF l_debug_level > 1 THEN
          debug(' Split RMA line Quantity :'|| l_split_line_qty);
       END IF;

       IF nvl(l_split_line_qty,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          x_msg_data      := 'Invalid OM Line quantity '||px_split_txn_line_rec.source_transaction_id;
          x_return_status := fnd_api.g_ret_sts_error;
          raise FND_API.G_EXC_ERROR;
       END IF;
      EXCEPTION
         WHEN OTHERS THEN
              x_msg_data      := 'Invalid OM Line id '||px_split_txn_line_rec.source_transaction_id;
              x_return_status := fnd_api.g_ret_sts_error;
              raise FND_API.G_EXC_ERROR;
    END;
    csi_utl_pkg.get_item_control_rec(
                   p_mtl_txn_id         => px_line_dtl_tbl(1).inv_mtl_transaction_id,
                   x_item_control_rec   => l_item_control_rec,
                   x_return_status      => l_return_status);

    px_line_dtl_tbl.delete;  -- Role of input table is complete

    IF l_line_dtl_tbl.count = 1 AND
       nvl(l_line_dtl_tbl(1).serial_number,fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
       px_line_dtl_tbl := l_line_dtl_tbl;
       px_line_dtl_tbl(1).processing_status := 'SUBMIT';

       IF p_src_txn_line_rec.source_transaction_type_id = 53 THEN
          px_line_dtl_tbl(1).quantity          := -1 * l_split_line_qty;
       ELSE
          px_line_dtl_tbl(1).quantity          := l_split_line_qty;
       END IF;
    ELSE -- l_line_dtl_tbl.count > 1
      /*-- Processing for serial control and lot-serial control items --*/
      IF l_item_control_rec.serial_control_code <> 1 THEN
         l_tab_ind := px_line_dtl_tbl.count ;
         FOR i IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
         LOOP
           IF l_line_dtl_tbl(i).processing_status <> 'PROCESSED' THEN
              l_match_txn_dtl_qty := l_match_txn_dtl_qty + abs(l_line_dtl_tbl(i).quantity);
              l_tab_ind := nvl(l_tab_ind,0) +1 ;
              px_line_dtl_tbl(l_tab_ind)   := l_line_dtl_tbl(i);
              px_line_dtl_tbl(l_tab_ind).source_txn_line_detail_id := l_line_dtl_tbl(i).txn_line_detail_id ;
           END IF;
         END LOOP ;

         IF l_debug_level > 1 AND nvl(l_match_txn_dtl_qty,0) <> nvl(l_split_line_qty,0) THEN
            debug('Total matching Transaction detail line quantity '||l_match_txn_dtl_qty ||' Does not matches OM line quantity '||l_split_line_qty);
            debug('Matching all pending Transaction detail lines for serial/lot control items');
         END IF;

      ELSE  /*-- Processing for non-serial, lot control items --*/
         l_tab_ind := px_line_dtl_tbl.count ;
         FOR i IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
         LOOP

           IF l_line_dtl_tbl(i).processing_status <> 'PROCESSED' THEN
              l_match_txn_dtl_qty := l_match_txn_dtl_qty + abs(l_line_dtl_tbl(i).quantity);
              l_tab_ind := nvl(l_tab_ind,0) +1 ;
              px_line_dtl_tbl(l_tab_ind)   := l_line_dtl_tbl(i);
              px_line_dtl_tbl(l_tab_ind).source_txn_line_detail_id := l_line_dtl_tbl(i).txn_line_detail_id ;
           END IF;
         END LOOP ;

         IF l_debug_level > 1 and nvl(l_match_txn_dtl_qty,0) <> nvl(l_split_line_qty,0) THEN
            debug('Total matching Transaction detail line quantity '||l_match_txn_dtl_qty ||' Does not matches OM line quantity '||l_split_line_qty);
            debug('No match processing for split OM line for non-serial/lot control items');
         END IF;

      END IF; -- for item serial control
    END IF;

    FOR l_txn_ind IN 1..px_line_dtl_tbl.count
    LOOP
      l_tab_ind := x_pty_dtl_tbl.count;
      FOR l_pty_ind IN 1..l_pty_dtl_tbl.count
      LOOP
        IF l_pty_dtl_tbl(l_pty_ind).txn_line_detail_id = px_line_dtl_tbl(l_txn_ind).txn_line_detail_id THEN
           l_tab_ind := nvl(l_tab_ind,0) +1;
           x_pty_dtl_tbl(l_tab_ind ) := l_pty_dtl_tbl(l_pty_ind);
        END IF;
      END LOOP;
      l_tab_ind := x_org_assgn_tbl.count;
      FOR l_org_ass_ind IN 1..l_org_assgn_tbl.count
      LOOP
        IF l_org_assgn_tbl(l_org_ass_ind).txn_line_detail_id = px_line_dtl_tbl(l_txn_ind).txn_line_detail_id THEN
           l_tab_ind := nvl(l_tab_ind,0) +1;
           x_org_assgn_tbl(l_tab_ind ) := l_org_assgn_tbl(l_org_ass_ind);
        END IF;
      END LOOP;
      l_tab_ind := x_txn_ext_attrib_vals_tbl.count;
      FOR l_extn_attr_ind IN 1..l_ext_attrib_tbl.count
      LOOP
        IF l_ext_attrib_tbl(l_extn_attr_ind).txn_line_detail_id = px_line_dtl_tbl(l_txn_ind).txn_line_detail_id THEN
           l_tab_ind := nvl(l_tab_ind,0) +1;
           x_txn_ext_attrib_vals_tbl(l_tab_ind ) := l_ext_attrib_tbl(l_extn_attr_ind);
        END IF;
      END LOOP;
      l_tab_ind := x_txn_systems_tbl.count;

    END LOOP;

    FOR l_pty_ind IN 1..x_pty_dtl_tbl.count
    LOOP
      l_tab_ind := x_pty_acct_tbl.count;
      FOR l_acc_ind IN 1..l_pty_acct_tbl.count
      LOOP
        IF l_pty_acct_tbl(l_acc_ind).txn_party_detail_id = x_pty_dtl_tbl(l_pty_ind).txn_party_detail_id THEN
           l_tab_ind := nvl(l_tab_ind,0) +1;
           x_pty_acct_tbl(l_tab_ind ) := l_pty_acct_tbl(l_acc_ind);
        END IF;
      END LOOP;
    END LOOP;
    IF px_line_dtl_tbl.count >0 THEN
       x_txn_systems_tbl := l_txn_systems_tbl;
    END IF;

    -- translate the ids in to index
    csi_t_utilities_pvt.convert_ids_to_index(
      px_line_dtl_tbl    => px_line_dtl_tbl,
      px_pty_dtl_tbl     => x_pty_dtl_tbl,
      px_pty_acct_tbl    => x_pty_acct_tbl,
      px_ii_rltns_tbl    => l_ii_rltns_tbl,
      px_org_assgn_tbl   => x_org_assgn_tbl,
      px_ext_attrib_tbl  => x_txn_ext_attrib_vals_tbl,
      px_txn_systems_tbl => x_txn_systems_tbl);

      IF l_line_dtl_tbl.count > 0 THEN
         l_ii_rltns_tbl.delete;

         IF l_debug_level > 1 THEN
            csi_t_gen_utility_pvt.dump_txn_tables
            (
              p_ids_or_index_based  => 'I'
             ,p_line_detail_tbl     => px_line_dtl_tbl
             ,p_party_detail_tbl    => x_pty_dtl_tbl
             ,p_pty_acct_tbl        => x_pty_acct_tbl
             ,p_ii_rltns_tbl        => l_ii_rltns_tbl
             ,p_org_assgn_tbl       => x_org_assgn_tbl
             ,p_ea_vals_tbl         => x_txn_ext_attrib_vals_tbl
           );
         END IF;

         csi_t_txn_details_grp.create_transaction_dtls
         (
               p_api_version              => p_api_version
              ,p_commit                   => p_commit
              ,p_init_msg_list            => p_init_msg_list
              ,p_validation_level         => p_validation_level
              ,px_txn_line_rec            => px_split_txn_line_rec
              ,px_txn_line_detail_tbl     => px_line_dtl_tbl
              ,px_txn_party_detail_tbl    => x_pty_dtl_tbl
              ,px_txn_pty_acct_detail_tbl => x_pty_acct_tbl
              ,px_txn_ii_rltns_tbl        => l_ii_rltns_tbl
              ,px_txn_org_assgn_tbl       => x_org_assgn_tbl
              ,px_txn_ext_attrib_vals_tbl => x_txn_ext_attrib_vals_tbl
              ,px_txn_systems_tbl         => x_txn_systems_tbl
              ,x_return_status            => x_return_status
              ,x_msg_count                => x_msg_count
              ,x_msg_data                 => x_msg_data
         );
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           debug('Creating the transaction details for copy failed.');
           raise fnd_api.g_exc_error;
        END IF;

      END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
  END split_transaction_details;

END csi_t_txn_details_pvt;

/
