--------------------------------------------------------
--  DDL for Package Body CSI_CZ_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CZ_INT" AS
/* $Header: csigczib.pls 120.5 2006/02/08 13:46:05 srramakr noship $ */

  PROCEDURE debug(
    p_message                IN     varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  procedure api_log(
    p_api_name               IN     varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_cz_int',
      p_api_name => p_api_name);
  END api_log;

  PROCEDURE get_configuration_revision(
    p_config_header_id       IN     number,
    p_target_commitment_date IN     date,
    px_instance_level        IN OUT NOCOPY varchar2,
    x_install_config_rec     OUT NOCOPY    config_rec , -- Bug 4147624, item instance locking. The config keys in the rec
    x_return_status          OUT NOCOPY    varchar2,    -- would actually correspond to values of the Installed Root
    x_return_message         OUT NOCOPY    varchar2)
  IS

    l_rev_found        boolean := FALSE;
    l_instance_level   varchar2(30);

    /* Commented this cursor and changed as below for bug 3502896
       as suggested by CZ  */

    -- CURSOR installed_cur(p_inst_hdr_id in number) IS
    --  SELECT cii.config_inst_rev_num
    --  FROM   csi_item_instances cii
    --  WHERE  cii.config_inst_hdr_id = p_inst_hdr_id
    --  AND    sysdate BETWEEN nvl(cii.active_start_date, sysdate-1)
    --                 AND     nvl(cii.active_end_date, sysdate+1);
/* Changes for bug 3901123 . Commented this cursor to replace with a single select - Performance
    CURSOR installed_cur(p_inst_hdr_id in number) IS
      SELECT cii.config_inst_rev_num
      FROM   csi_item_instances cii,
             cz_config_items czItems
      WHERE  cii.config_inst_hdr_id = p_inst_hdr_id
      AND    czItems.instance_hdr_id  = p_inst_hdr_id
      AND    czItems.component_instance_type in ('I','R')  -- I = Root instance
      AND    czItems.config_item_id = cii.config_inst_item_id
      AND    sysdate BETWEEN nvl(cii.active_start_date, sysdate-1)
                     AND     nvl(cii.active_end_date, sysdate+1);
*/

    CURSOR proposed_cur(p_inst_hdr_id in number) IS
      SELECT ctd.config_inst_rev_num
      FROM   csi_t_transaction_lines ctl,
             csi_t_txn_line_details  ctd
      WHERE  ctd.config_inst_hdr_id        = p_inst_hdr_id
      AND    ctl.transaction_line_id       = ctd.transaction_line_id
      AND    ctl.source_transaction_status = 'PROPOSED'
      AND    not exists (SELECT 'X' FROM csi_t_txn_line_details ctlx
                         WHERE  ctlx.config_inst_hdr_id           = ctd.config_inst_hdr_id
                         AND    ctlx.config_inst_baseline_rev_num = ctd.config_inst_rev_num);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    --Initializing the lock status
    x_install_config_rec.lock_status := 0;


    l_instance_level := nvl(px_instance_level, 'INSTALLED');

    IF l_instance_level = 'INSTALLED' THEN
     -- Added for 3901123

       Begin

          SELECT cii.config_inst_hdr_id, -- changes made for MACD locking bug, 4147624
                 cii.config_inst_rev_num,
                 cii.config_inst_item_id
          INTO   x_install_config_rec.config_inst_hdr_id,
                 x_install_config_rec.config_inst_rev_num,
                 x_install_config_rec.config_inst_item_id
          FROM   csi_item_instances cii
          WHERE  cii.config_inst_hdr_id = p_config_header_id
          AND    sysdate BETWEEN nvl(cii.active_start_date, sysdate-1)
          AND     nvl(cii.active_end_date, sysdate+1)
          AND EXISTS (SELECT 'Y'  -- bug 3901123
                      FROM cz_config_items czItems
                      WHERE czItems.instance_hdr_id  = p_config_header_id
                      AND  czItems.instance_rev_nbr = cii.config_inst_rev_num
                      AND czItems.config_item_id = cii.config_inst_item_id
                      AND czItems.component_instance_type = 'I'  -- I = Root instance
                      AND czItems.deleted_flag = '0');
          l_rev_found := TRUE;
       Exception when others then
          l_rev_found := FALSE;
       End;

       IF (l_rev_found)
       THEN
         BEGIN
           SELECT lock_source_appln_id, -- pass the locking details except the locked CZ keys
                  lock_source_header_ref,
                  lock_source_line_ref1,
                  lock_source_line_ref2,
                  lock_source_line_ref3,
                  lock_id,
                  lock_status
           INTO   x_install_config_rec.source_application_id,
                  x_install_config_rec.source_txn_header_ref,
                  x_install_config_rec.source_txn_line_ref1,
                  x_install_config_rec.source_txn_line_ref2,
                  x_install_config_rec.source_txn_line_ref3,
                  x_install_config_rec.lock_id,
                  x_install_config_rec.lock_status
           FROM   CSI_ITEM_INSTANCE_LOCKS
           WHERE  CONFIG_INST_HDR_ID  = p_config_header_id
           AND    CONFIG_INST_ITEM_ID = x_install_config_rec.config_inst_item_id
           AND    LOCK_STATUS <> 0;

         EXCEPTION
           WHEN OTHERS THEN
                NULL;
         END;
       END IF;

/* commented the loop for 3901123
      FOR installed_rec IN installed_cur (p_config_header_id)
      LOOP
        l_rev_found := TRUE;
        x_install_config_rec.config_inst_rev_num  := installed_rec.config_inst_rev_num;
      END LOOP;
*/

    /*

    -- commenting as proposed and PENDING are not supported in the first release

    ELSIF l_instance_level = 'PROPOSED' THEN

      FOR proposed_rec IN proposed_cur(p_config_header_id)
      LOOP
        l_rev_found := TRUE;
        x_install_config_rec.config_inst_rev_num := proposed_rec.config_inst_rev_num;
      END LOOP;

      IF NOT(l_rev_found) THEN
        FOR installed_rec IN installed_cur (p_config_header_id)
        LOOP
          l_rev_found := TRUE;
          x_install_config_rec.config_inst_rev_num := installed_rec.config_inst_rev_num;
          px_instance_level   := 'INSTALLED';
        END LOOP;
      END IF;
      */

    ELSE

      fnd_message.set_name('CSI', 'CSI_UNSUPPORTED_INST_LEVEL');
      fnd_message.set_token('INST_LVL', px_instance_level);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;

    IF NOT(l_rev_found) THEN
      x_install_config_rec.config_inst_rev_num := null;
      /*
      fnd_message.set_name('CSI','CSI_CONFIG_REV_NOT_FOUND');
      fnd_message.set_token('LEVEL', l_instance_level);
      fnd_message.set_token('INST_HDR_ID', p_config_header_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
      */
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := csi_t_gen_utility_pvt.dump_error_stack;
  END get_configuration_revision;

  --
  --
  --
  PROCEDURE get_connected_configurations(
    p_config_query_table     IN     config_query_table,
    p_instance_level         IN     varchar2,
    x_config_pair_table      OUT NOCOPY    config_pair_table,
    x_return_status          OUT NOCOPY    varchar2,
    x_return_message         OUT NOCOPY    varchar2)
  IS

    l_o_ind         binary_integer := 0;
    l_instance_id   number;

    CURSOR pending_cur(p_inst_hdr_id in number, p_inst_rev_num in number) IS
      SELECT cti.sub_config_inst_hdr_id,
             cti.sub_config_inst_rev_num,
             cti.sub_config_inst_item_id,
             cti.obj_config_inst_hdr_id,
             cti.obj_config_inst_rev_num,
             cti.obj_config_inst_item_id
      FROM   csi_t_ii_relationships cti
      WHERE  cti.relationship_type_code = 'CONNECTED-TO'
      AND    ((
                cti.sub_config_inst_hdr_id = p_inst_hdr_id
                  AND
                cti.sub_config_inst_rev_num = p_inst_rev_num
              )
               OR
              (
                cti.obj_config_inst_hdr_id = p_inst_hdr_id
                  AND
                cti.obj_config_inst_rev_num = p_inst_rev_num
              )
             );
/* replaced the cursor for 3892929
    CURSOR installed_cur(p_inst_hdr_id in number, p_inst_rev_num in number) IS
      SELECT subject_id,
             object_id
      FROM   csi_ii_relationships cir,
             csi_item_instances   cii
      WHERE  cii.config_inst_hdr_id     = p_inst_hdr_id
      AND    cii.config_inst_rev_num    = p_inst_rev_num
      AND    cir.relationship_type_code = 'CONNECTED-TO'
      AND    ( cir.subject_id = cii.instance_id
                 OR
               cir.object_id  = cii.instance_id)
      AND    sysdate BETWEEN nvl(cir.active_start_date, sysdate-1)
                     AND     nvl(cir.active_end_date, sysdate+1);
*/

  CURSOR installed_cur(p_inst_hdr_id in number, p_inst_rev_num in number) IS
      SELECT subject_id ,
             object_id ,
             instance_id ,
             decode (subject_id, instance_id, config_inst_hdr_id, -9999) sub_inst_hdr_id,
             decode (object_id, instance_id, config_inst_hdr_id, -9999) obj_inst_hdr_id,
             config_inst_item_id,
             config_inst_rev_num
      FROM   csi_ii_relationships cir,
             csi_item_instances   cii
      WHERE  cii.config_inst_hdr_id     = p_inst_hdr_id
      AND    cii.config_inst_rev_num    = p_inst_rev_num
      AND    cir.relationship_type_code = 'CONNECTED-TO'
      AND    ( cir.subject_id = cii.instance_id
                 OR
               cir.object_id  = cii.instance_id)
      AND    sysdate BETWEEN nvl(cir.active_start_date, sysdate-1)
                     AND     nvl(cir.active_end_date, sysdate+1);

    l_root_hdr_id   number;
    l_root_rev_num  number;
    l_root_item_id  number;
    l_conn_hdr_id   number;
    l_found         BOOLEAN;

    l_sub_hdr_id    number;
    l_sub_rev_num   number;
    l_sub_item_id   number;

    l_obj_hdr_id    number;
    l_obj_rev_num   number;
    l_obj_item_id   number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_config_query_table.COUNT > 0 THEN

      FOR l_ind IN p_config_query_table.FIRST .. p_config_query_table.LAST
      LOOP
        IF p_instance_level = 'INSTALLED' THEN

          FOR installed_rec IN installed_cur (
                p_config_query_table(l_ind).config_header_id,
                p_config_query_table(l_ind).config_revision_number)
          LOOP

            l_sub_hdr_id  := null;
            l_sub_rev_num := null;
            l_sub_item_id := null;
            l_obj_hdr_id  := null;
            l_obj_rev_num := null;
            l_obj_item_id := null;
            l_root_hdr_id := null;
            l_root_rev_num:= null;
            l_root_item_id:= null;
            l_conn_hdr_id := null;

            DECLARE
              do_not_build exception;
            BEGIN

             /* commented and replaced below for bug 3892929
              BEGIN
                SELECT config_inst_hdr_id ,
                       config_inst_rev_num,
                       config_inst_item_id
                INTO   l_sub_hdr_id,
                       l_sub_rev_num,
                       l_sub_item_id
                FROM   csi_item_instances
                WHERE  instance_id = installed_rec.subject_id
                AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                               AND     nvl(active_end_date, sysdate+1);
              EXCEPTION
                WHEN no_data_found THEN
                  RAISE do_not_build;
              END;

              BEGIN
                SELECT config_inst_hdr_id ,
                       config_inst_rev_num,
                       config_inst_item_id
                INTO   l_obj_hdr_id,
                       l_obj_rev_num,
                       l_obj_item_id
                FROM   csi_item_instances
                WHERE  instance_id = installed_rec.object_id
                AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                               AND     nvl(active_end_date, sysdate+1);
              EXCEPTION
                WHEN no_data_found THEN
                  RAISE do_not_build;
              END;

              l_o_ind := l_o_ind + 1;

              x_config_pair_table(l_o_ind).object_header_id        := l_obj_hdr_id;
              x_config_pair_table(l_o_ind).object_revision_number  := l_obj_rev_num;
              x_config_pair_table(l_o_ind).object_item_id          := l_obj_item_id;

              x_config_pair_table(l_o_ind).subject_header_id       := l_sub_hdr_id;
              x_config_pair_table(l_o_ind).subject_revision_number := l_sub_rev_num;
              x_config_pair_table(l_o_ind).subject_item_id         := l_sub_item_id;

            EXCEPTION
              WHEN do_not_build THEN
                null;
            END;
          END LOOP;
         bug 3892929 */

            IF installed_rec.subject_id is not null
                 OR
               installed_rec.object_id is not null THEN
             IF nvl(installed_rec.sub_inst_hdr_id, -9999) = -9999 THEN
                l_obj_hdr_id  := installed_rec.obj_inst_hdr_id;
                l_obj_item_id := installed_rec.config_inst_item_id;
                l_obj_rev_num := installed_rec.config_inst_rev_num;
                -- get the cz 3tuple
                BEGIN
                  SELECT config_inst_hdr_id ,
                         config_inst_rev_num,
                         config_inst_item_id
                  INTO   l_sub_hdr_id,
                         l_sub_rev_num,
                         l_sub_item_id
                  FROM   csi_item_instances
                  WHERE  instance_id = installed_rec.subject_id
                  AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                                 AND     nvl(active_end_date, sysdate+1);
                  l_conn_hdr_id :=  l_sub_hdr_id;  -- the connected instance hdr ID
                EXCEPTION
                  WHEN no_data_found THEN
                    RAISE do_not_build;
                END;
             ELSE
                l_sub_hdr_id  := installed_rec.sub_inst_hdr_id;
                l_sub_item_id := installed_rec.config_inst_item_id;
                l_sub_rev_num := installed_rec.config_inst_rev_num;
                BEGIN
                  SELECT config_inst_hdr_id ,
                         config_inst_rev_num,
                         config_inst_item_id
                  INTO   l_obj_hdr_id,
                         l_obj_rev_num,
                         l_obj_item_id
                  FROM   csi_item_instances
                  WHERE  instance_id = installed_rec.object_id
                  AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                                 AND     nvl(active_end_date, sysdate+1);
                  l_conn_hdr_id :=  l_obj_hdr_id;  -- the connected instance hdr ID
                EXCEPTION
                  WHEN no_data_found THEN
                    RAISE do_not_build;
                END;
             END IF;
             -- now get the root of the connected instance

             Begin

               SELECT cii.config_inst_hdr_id ,
                      cii.config_inst_rev_num,
                      cii.config_inst_item_id
               INTO   l_root_hdr_id,
                      l_root_rev_num,
                      l_root_item_id
               FROM   csi_item_instances cii
               WHERE  cii.config_inst_hdr_id  = l_conn_hdr_id
               AND    sysdate BETWEEN nvl(cii.active_start_date, sysdate-1)
               AND     nvl(cii.active_end_date, sysdate+1)
               AND EXISTS (SELECT 'Y'
                           FROM cz_config_items czItems
                           WHERE czItems.instance_hdr_id  = l_conn_hdr_id
                           AND  czItems.instance_rev_nbr = cii.config_inst_rev_num
                           AND czItems.config_item_id = cii.config_inst_item_id
                           AND czItems.component_instance_type = 'I'  -- I = Root instance
                           AND czItems.deleted_flag = '0');
             Exception when others then
                  fnd_message.set_name('CSI','CSI_CONFIG_REV_NOT_FOUND');
                  fnd_message.set_token('LEVEL', 'INSTALLED');
                  fnd_message.set_token('INST_HDR_ID', l_conn_hdr_id);
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
             End;

             l_found := FALSE;
             IF x_config_pair_table.count > 0 THEN
               FOR x_ind in x_config_pair_table.First .. x_config_pair_table.LAST LOOP
                IF ( l_sub_hdr_id is not null OR l_obj_hdr_id is not null) THEN
                 IF (   (x_config_pair_table(x_ind).root_header_id = l_obj_hdr_id)
                     OR (x_config_pair_table(x_ind).root_header_id = l_sub_hdr_id) )
                   --only if a particular tree/root has not already been loaded/identified, build it
                 THEN
                     l_found := TRUE;
                 END IF;
                END IF;
               END LOOP;
             END IF;

             IF NOT l_found THEN
                l_o_ind := l_o_ind + 1;
                --Initializing the lock_status
                x_config_pair_table(l_o_ind).lock_status := 0;

                x_config_pair_table(l_o_ind).root_header_id          := l_root_hdr_id;
                x_config_pair_table(l_o_ind).root_revision_number    := l_root_rev_num;
                x_config_pair_table(l_o_ind).root_item_id            := l_root_item_id;
                x_config_pair_table(l_o_ind).object_header_id        := l_obj_hdr_id;
                x_config_pair_table(l_o_ind).object_revision_number  := l_obj_rev_num;
                x_config_pair_table(l_o_ind).object_item_id          := l_obj_item_id;
                x_config_pair_table(l_o_ind).subject_header_id       := l_sub_hdr_id;
                x_config_pair_table(l_o_ind).subject_revision_number := l_sub_rev_num;
                x_config_pair_table(l_o_ind).subject_item_id         := l_sub_item_id;

                  BEGIN
                    SELECT lock_source_appln_id,
                           lock_source_header_ref,
                           lock_source_line_ref1,
                           lock_source_line_ref2,
                           lock_source_line_ref3,
                           lock_id,
                           lock_status
                    INTO   x_config_pair_table(l_o_ind).source_application_id,
                           x_config_pair_table(l_o_ind).source_txn_header_ref,
                           x_config_pair_table(l_o_ind).source_txn_line_ref1,
                           x_config_pair_table(l_o_ind).source_txn_line_ref2,
                           x_config_pair_table(l_o_ind).source_txn_line_ref3,
                           x_config_pair_table(l_o_ind).lock_id,
                           x_config_pair_table(l_o_ind).lock_status
                    FROM   CSI_ITEM_INSTANCE_LOCKS
                    WHERE  config_inst_hdr_id = l_root_hdr_id
                    AND    config_inst_item_id   = l_root_item_id
                    AND    LOCK_STATUS  <> 0;

                  EXCEPTION
                    WHEN OTHERS THEN
                         NULL;
                  END;

              ELSE
                RAISE do_not_build;
              END IF;
            END IF;
            EXCEPTION
              WHEN do_not_build THEN
                null;
            END;
          END LOOP;

        ELSIF p_instance_level = 'PENDING' THEN

          FOR pending_rec IN pending_cur(p_config_query_table(l_ind).config_header_id,
                                         p_config_query_table(l_ind).config_revision_number)
          LOOP
            l_o_ind := l_o_ind + 1;

            x_config_pair_table(l_o_ind).subject_header_id
                                         := pending_rec.sub_config_inst_hdr_id;
            x_config_pair_table(l_o_ind).subject_revision_number
                                         := pending_rec.sub_config_inst_rev_num;
            x_config_pair_table(l_o_ind).subject_item_id
                                         := pending_rec.sub_config_inst_item_id;
            x_config_pair_table(l_o_ind).object_header_id
                                         := pending_rec.obj_config_inst_hdr_id;
            x_config_pair_table(l_o_ind).object_revision_number
                                         := pending_rec.obj_config_inst_rev_num;
            x_config_pair_table(l_o_ind).object_item_id
                                         := pending_rec.obj_config_inst_item_id;

          END LOOP;
        END IF;
      END LOOP;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_connected_configurations;

  Function check_item_instance_lock (
        p_init_msg_list    IN   VARCHAR2 := FND_API.g_false,
        p_config_rec       IN   config_rec,
        x_return_status    OUT  NOCOPY VARCHAR2,
        x_msg_count        OUT  NOCOPY NUMBER,
        x_msg_data         OUT  NOCOPY VARCHAR2)
     RETURN BOOLEAN is

     l_locked          BOOLEAN := FALSE;
  Begin
    x_return_status := fnd_api.g_ret_sts_success;

    l_locked := csi_item_instance_pvt.check_item_instance_lock(
                       p_config_inst_hdr_id  => p_config_rec.config_inst_hdr_id,
                       p_config_inst_item_id => p_config_rec.config_inst_item_id,
                       p_config_inst_rev_num => p_config_rec.config_inst_rev_num,
                       p_instance_id         => p_config_rec.instance_id);
    Return l_locked;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      Return TRUE;
  END check_item_instance_lock;

  PROCEDURE lock_item_instances(
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2 := FND_API.g_false,
        p_commit             IN VARCHAR2 := FND_API.g_false,
        p_validation_level   IN NUMBER  := FND_API.g_valid_level_full,
        px_config_tbl        IN OUT NOCOPY config_tbl,
        x_return_status      OUT NOCOPY    varchar2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2 )
  IS

   l_lock                    BOOLEAN := FALSE;
   l_config_rec              config_rec;
   l_config_tbl              config_tbl;
   l_parent_ind              NUMBER;
   l_child_ind               NUMBER;
   l_CONFIG_SESSION_HDR_ID   NUMBER;
   l_CONFIG_SESSION_REV_NUM  NUMBER;
   l_CONFIG_SESSION_ITEM_ID  NUMBER;
   l_txn_rec                 csi_datastructures_pub.transaction_rec;
   l_flag                    NUMBER;
   l_csi_debug_level         NUMBER;
   l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_return_message          VARCHAR2(2000);

    -- Cursor to populate all the child keys for the root keys passed from CZ.
    CURSOR sess_cur(
      p_config_inst_hdr_id  IN NUMBER,
      p_config_inst_rev_num IN NUMBER,
      p_config_inst_item_id in NUMBER)
    IS
      SELECT ctl.CONFIG_SESSION_HDR_ID,
             ctl.CONFIG_SESSION_REV_NUM,
             ctl.CONFIG_SESSION_ITEM_ID,
             ctld.CONFIG_INST_HDR_ID,
             ctld.CONFIG_INST_REV_NUM,
             ctld.CONFIG_INST_ITEM_ID,
             ctld.instance_id
      FROM   csi_t_transaction_lines  ctl,
             csi_t_txn_line_details ctld
      WHERE  ctl.transaction_line_id = ctld.transaction_line_id
      AND    CONFIG_INST_HDR_ID      = p_config_inst_hdr_id
      AND    CONFIG_INST_REV_NUM     = p_config_inst_rev_num;
      -- AND    CONFIG_INST_ITEM_ID     <> p_config_inst_item_id;

  Begin

    savepoint csi_cz_lock_item;

    -- This routine checks if ib is active
    csi_utility_grp.check_ib_active;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csilock',
      p_file_segment2 =>  to_char(sysdate,'DDMONYYYY'));

    api_log('lock_item_instance');

    -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
    l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- Building txn rec
    -- l_txn_rec.transaction_id                 := fnd_api.g_miss_num;
    l_txn_rec.transaction_date               := sysdate;
    l_txn_rec.source_transaction_date        := sysdate;
    l_txn_rec.transaction_type_id            := 51;

    -- Populating the txn details for the child keys taking root keys passed from CZ.
    IF px_config_tbl.COUNT > 0 THEN
      l_child_ind := 1;
      -- For each root key populate the child keys
      FOR l_key IN px_config_tbl.FIRST .. px_config_tbl.LAST
      LOOP

        debug('Processing root key ');
        debug('config_hdr_id('||l_key||')  :'||px_config_tbl(l_key).config_inst_hdr_id);
        debug('config_itm_id('||l_key||')  :'||px_config_tbl(l_key).config_inst_item_id);
        debug('config_rev_num('||l_key||') :'||px_config_tbl(l_key).config_inst_rev_num);
        debug('src Appln Id('||l_key||')   :'||px_config_tbl(l_key).source_application_id);

        IF ( px_config_tbl(l_key).source_application_id is null
            OR
             px_config_tbl(l_key).source_application_id = fnd_api.g_miss_num
           )
          OR
           ( px_config_tbl(l_key).source_txn_header_ref is null
            OR
             px_config_tbl(l_key).source_txn_header_ref = fnd_api.g_miss_num
           )
        THEN
          fnd_message.set_name('CSI','CSI_CZ_LOCK_DTLS_MISS');
          fnd_message.set_token('APPLN_ID',px_config_tbl(l_key).source_application_id);
          fnd_message.set_token('HEADER_REF',px_config_tbl(l_key).source_txn_header_ref);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        FOR sess_rec IN sess_cur(px_config_tbl(l_key).config_inst_hdr_id,
                                 px_config_tbl(l_key).config_inst_rev_num,
                                 px_config_tbl(l_key).config_inst_item_id)
        LOOP
        -- Build the lock config table for all the child and parent config keys
            l_config_tbl(l_child_ind).source_application_id := px_config_tbl(l_key).source_application_id;
            l_config_tbl(l_child_ind).source_txn_header_ref := px_config_tbl(l_key).source_txn_header_ref;
            l_config_tbl(l_child_ind).config_inst_hdr_id    := sess_rec.CONFIG_INST_HDR_ID;
            l_config_tbl(l_child_ind).config_inst_rev_num   := sess_rec.CONFIG_INST_REV_NUM;
            l_config_tbl(l_child_ind).config_inst_item_id   := sess_rec.CONFIG_INST_ITEM_ID;
            -- l_config_tbl(l_child_ind).instance_id           := sess_rec.INSTANCE_ID;


            l_CONFIG_SESSION_HDR_ID  := sess_rec.CONFIG_SESSION_HDR_ID;
            l_CONFIG_SESSION_REV_NUM := sess_rec.CONFIG_SESSION_REV_NUM;
            l_CONFIG_SESSION_ITEM_ID := sess_rec.CONFIG_SESSION_ITEM_ID;

            -- Building the record for the config keys to check for the Lock Status.
            l_config_rec.config_inst_hdr_id  := sess_rec.CONFIG_INST_HDR_ID;
            l_config_rec.config_inst_rev_num := sess_rec.CONFIG_INST_REV_NUM;
            l_config_rec.config_inst_item_id := sess_rec.CONFIG_INST_ITEM_ID;

            -- checking for the config keys if they are locked alreday.
            l_lock := check_item_instance_lock (
                             p_init_msg_list => fnd_api.g_true,
                             p_config_rec    => l_config_rec,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

            IF (l_lock)
            THEN
              fnd_message.set_name('CSI','CSI_CONFIG_KEYS_LOCKED');
              fnd_message.set_token('CONFIG_INST_HDR_ID',l_config_rec.config_inst_hdr_id);
              fnd_message.set_token('CONFIG_INST_ITEM_ID',l_config_rec.config_inst_item_id);
              fnd_message.set_token('CONFIG_INST_REV_NUM',l_config_rec.config_inst_rev_num);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
              Exit;
            ELSE
            /*
            -- Populating the order line details onto the key rec
             BEGIN
              SELECT line_number||'.'||
                     shipment_number||'.'||
                     option_number
              INTO   l_config_rec.source_txn_line_ref1
                     --,l_config_rec.source_txn_line_ref2
                     --,l_config_rec.source_txn_line_ref3
              FROM   oe_order_lines_all oel,
                     oe_order_headers_all oeh
              WHERE  oeh.header_id        = oel.header_id
              AND    oeh.order_number     = px_config_tbl(l_key).source_txn_header_ref
              AND    oel.config_header_id = l_CONFIG_SESSION_HDR_ID
              AND    oel.config_rev_nbr   = l_CONFIG_SESSION_REV_NUM
              AND    oel.configuration_id = l_CONFIG_SESSION_ITEM_ID;

            EXCEPTION
              WHEN NO_DATA_FOUND Then
                fnd_message.set_name('CSI','CSI_CZ_KEY_INVAL_OREDER');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error;
                Exit;
            END;
            */
            -- Populating the instance_id onto the key rec
            -- IF l_config_rec.instance_id is null
            --  OR
            --   l_config_rec.instance_id = fnd_api.g_miss_num
            -- THEN
              BEGIN
                SELECT instance_id
                INTO   l_config_tbl(l_child_ind).instance_id
                FROM   CSI_ITEM_INSTANCES
                WHERE  CONFIG_INST_HDR_ID  = l_config_rec.config_inst_hdr_id
                -- AND    CONFIG_INST_REV_NUM = l_config_rec.config_inst_rev_num
                AND    CONFIG_INST_ITEM_ID = l_config_rec.config_inst_item_id;

              EXCEPTION
                WHEN NO_DATA_FOUND Then
                  Null;
              END;
            -- END IF;
              -- l_config_tbl(l_child_ind).source_txn_line_ref1       := l_config_rec.source_txn_line_ref1;
              -- l_config_tbl(l_child_ind).source_txn_line_ref2       := l_config_rec.source_txn_line_ref2;
              -- l_config_tbl(l_child_ind).source_txn_line_ref3       := l_config_rec.source_txn_line_ref3;
              l_config_tbl(l_child_ind).lock_status                := 2;
              l_child_ind := l_child_ind + 1;
            END IF; -- End If for Falg Check
        END LOOP; -- End Loop for the cild keys
      END LOOP; -- End Loop for Root Keys
    END IF;

    debug('Before call to csi_item_instance_pvt.lock_item_instances');
    debug('Records count to be locked '||nvl(l_config_tbl.count,0));

    csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pvt',
              p_api_name => 'lock_item_instance');

    csi_t_gen_utility_pvt.dump_csi_config_tbl(
              p_config_tbl => l_config_tbl);

    -- Call to core API for Locking
    csi_item_instance_pvt.lock_item_instances(
           p_api_version         => 1.0,
           p_commit              => fnd_api.g_false,
           p_init_msg_list       => fnd_api.g_true,
           p_validation_level    => fnd_api.g_valid_level_full,
           px_config_tbl         => l_config_tbl,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data);

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
           debug('Failed csi_item_instance_pvt.lock_item_instance');
           RAISE fnd_api.g_exc_error;
         END IF;

    -- Assigningrequired values to px_config keys
    IF px_config_tbl.count > 0
    THEN
      FOR i IN px_config_tbl.FIRST .. px_config_tbl.LAST
      LOOP
       IF l_config_tbl.count > 0
       THEN
         FOR j in l_config_tbl.FIRST .. l_config_tbl.LAST
         LOOP
           IF px_config_tbl(i).config_inst_hdr_id  = l_config_tbl(j).config_inst_hdr_id
             AND
              px_config_tbl(i).config_inst_rev_num = l_config_tbl(j).config_inst_rev_num
             AND
              px_config_tbl(i).config_inst_item_id = l_config_tbl(j).config_inst_item_id
           THEN
              px_config_tbl(i) := l_config_tbl(j);
              debug('config_hdr_id  :'||px_config_tbl(i).config_inst_hdr_id);
              debug('config_itm_id  :'||px_config_tbl(i).config_inst_item_id);
              debug('config_rev_num :'||px_config_tbl(i).config_inst_rev_num);
              debug('lock_status    :'||px_config_tbl(i).lock_status);
              debug('lock_id        :'||px_config_tbl(i).lock_id);
           END IF;
         END LOOP;
       END IF;
      END LOOP;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
             (p_count        =>      x_msg_count ,
              p_data         =>      x_msg_data   );

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      FND_MSG_PUB.Count_And_Get
             (p_count        =>      x_msg_count ,
              p_data         =>      x_msg_data   );
      rollback to csi_cz_lock_item;
      debug(l_return_message);
    WHEN others THEN
      fnd_message.set_name ('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', 'OTHERS Error :'||substr(sqlerrm, 1, 300));
      fnd_msg_pub.add;
       FND_MSG_PUB.Count_And_Get
             (p_count        =>      x_msg_count ,
              p_data         =>      x_msg_data   );
      x_return_status  := fnd_api.g_ret_sts_error;
      l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      rollback to csi_cz_lock_item;
      debug(l_return_message);
  END lock_item_instances;

  PROCEDURE get_lock_status(
    p_config_inst_header_id IN NUMBER,
    p_config_inst_rev_num   IN NUMBER,
    p_config_inst_item_id   IN NUMBER,
    x_lock_status           OUT NOCOPY NUMBER,
    x_lock_id               OUT NOCOPY NUMBER)
  IS
  BEGIN
    api_log('get_lock_status');

    SELECT lock_status,
           lock_id
    INTO   x_lock_status,
           x_lock_id
    FROM   csi_item_instance_locks
    WHERE  config_inst_hdr_id  = p_config_inst_header_id
    AND    config_inst_rev_num = p_config_inst_rev_num
    AND    config_inst_item_id = p_config_inst_item_id;

  EXCEPTION
    WHEN no_data_found THEN
      x_lock_status := 0;
    WHEN others THEN
      x_lock_status := 0;
  END get_lock_status;


  PROCEDURE populate_connected_tbl(
    p_config_inst_header_id IN NUMBER,
    p_config_inst_rev_num   IN NUMBER,
    p_config_inst_item_id   IN NUMBER,
    p_config_rec            IN config_rec,
    x_conn_config_tbl       OUT NOCOPY config_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_parent_hdr_id       number;
    l_parent_rev_num      number;
    l_parent_item_id      number;
    l_ind                 number := 0;

   CURSOR sub_cur(l_hdr_id IN number, l_rev_num IN number, l_item_id IN NUMBER,
                   l_parent_hdr_id IN number, l_parent_rev_num IN number, l_parent_item_id IN number) IS
      SELECT sub_config_inst_hdr_id,
             sub_config_inst_rev_num,
             sub_config_inst_item_id
      FROM   csi_t_ii_relationships
      WHERE  obj_config_inst_hdr_id  = p_config_inst_header_id
      AND    obj_config_inst_rev_num = p_config_inst_rev_num
      AND    obj_config_inst_item_id = p_config_inst_item_id
      AND    sub_config_inst_hdr_id  <> l_parent_hdr_id
      -- AND    sub_config_inst_rev_num <> l_parent_rev_num
      AND    sub_config_inst_item_id <> l_parent_item_id
      AND    relationship_type_code  = 'CONNECTED-TO';

   CURSOR obj_cur(l_hdr_id IN number, l_rev_num IN number, l_item_id IN NUMBER,
                   l_parent_hdr_id IN number, l_parent_rev_num IN number, l_parent_item_id IN number) IS
      SELECT obj_config_inst_hdr_id,
             obj_config_inst_rev_num,
             obj_config_inst_item_id
      FROM   csi_t_ii_relationships
      WHERE  sub_config_inst_hdr_id  = p_config_inst_header_id
      AND    sub_config_inst_rev_num = p_config_inst_rev_num
      AND    sub_config_inst_item_id = p_config_inst_item_id
      AND    obj_config_inst_hdr_id  <> l_parent_hdr_id
      -- AND    obj_config_inst_rev_num <> l_parent_rev_num
      AND    obj_config_inst_item_id <> l_parent_item_id
      AND    relationship_type_code  = 'CONNECTED-TO';

  BEGIN

    api_log('populate_connected_tbl');

    x_return_status := fnd_api.g_ret_sts_success;
    l_parent_hdr_id  := p_config_rec.config_inst_hdr_id;
    l_parent_rev_num := p_config_rec.config_inst_rev_num;
    l_parent_item_id := p_config_rec.config_inst_item_id;

    -- Building sub keys
    FOR l_sub_key in sub_cur(p_config_inst_header_id,p_config_inst_rev_num,p_config_inst_item_id,
                             l_parent_hdr_id,l_parent_rev_num,l_parent_item_id)
    LOOP
      l_ind := l_ind + 1;
      x_conn_config_tbl(l_ind).config_inst_hdr_id  := l_sub_key.sub_config_inst_hdr_id;
      x_conn_config_tbl(l_ind).config_inst_rev_num := l_sub_key.sub_config_inst_rev_num;
      x_conn_config_tbl(l_ind).config_inst_item_id := l_sub_key.sub_config_inst_item_id;
      x_conn_config_tbl(l_ind).source_txn_header_ref := p_config_rec.source_txn_header_ref;
      x_conn_config_tbl(l_ind).source_txn_line_ref1 := p_config_rec.source_txn_line_ref1;
      x_conn_config_tbl(l_ind).source_application_id := p_config_rec.source_application_id;

      -- Populate the lock_status of each subject key
      get_lock_status( p_config_inst_header_id => x_conn_config_tbl(l_ind).config_inst_hdr_id,
                       p_config_inst_rev_num   => x_conn_config_tbl(l_ind).config_inst_rev_num,
                       p_config_inst_item_id   => x_conn_config_tbl(l_ind).config_inst_item_id,
                       x_lock_status           => x_conn_config_tbl(l_ind).lock_status,
                       x_lock_id               => x_conn_config_tbl(l_ind).lock_id);
    END LOOP;

    -- Building obj keys
    FOR l_obj_key in obj_cur(p_config_inst_header_id,p_config_inst_rev_num,p_config_inst_item_id,
                             l_parent_hdr_id,l_parent_rev_num,l_parent_item_id)
    LOOP
      l_ind := l_ind + 1;
      x_conn_config_tbl(l_ind).config_inst_hdr_id  := l_obj_key.obj_config_inst_hdr_id;
      x_conn_config_tbl(l_ind).config_inst_rev_num := l_obj_key.obj_config_inst_rev_num;
      x_conn_config_tbl(l_ind).config_inst_item_id := l_obj_key.obj_config_inst_item_id;
      x_conn_config_tbl(l_ind).source_txn_header_ref := p_config_rec.source_txn_header_ref;
      x_conn_config_tbl(l_ind).source_txn_line_ref1 := p_config_rec.source_txn_line_ref1;
      x_conn_config_tbl(l_ind).source_application_id := p_config_rec.source_application_id;

      -- Populate the lock_status of each object key
      get_lock_status( p_config_inst_header_id => x_conn_config_tbl(l_ind).config_inst_hdr_id,
                       p_config_inst_rev_num   => x_conn_config_tbl(l_ind).config_inst_rev_num,
                       p_config_inst_item_id   => x_conn_config_tbl(l_ind).config_inst_item_id,
                       x_lock_status           => x_conn_config_tbl(l_ind).lock_status,
                       x_lock_id               => x_conn_config_tbl(l_ind).lock_id);
    END LOOP;
  END populate_connected_tbl;

  PROCEDURE Unlock_Current_Node(
	  p_api_version        IN NUMBER,
	  p_init_msg_list      IN VARCHAR2,
	  p_commit             IN VARCHAR2,
	  p_validation_level   IN NUMBER,
	  p_config_rec         IN config_rec,
	  x_conn_config_tbl    OUT NOCOPY config_tbl,
	  x_return_status      OUT NOCOPY    varchar2,
	  x_msg_count          OUT NOCOPY NUMBER,
	  x_msg_data           OUT NOCOPY VARCHAR2 )
    IS
      l_config_tbl                config_tbl;
      l_comp_conn_config_tbl      config_tbl;
      l_config_rec                config_rec;
      l_child_config_rec          config_rec;
      l_return_message            VARCHAR2(2000);
      l_root_inst_hdr_id          NUMBER;
      l_root_inst_rev_num         NUMBER;
      l_root_inst_item_id         NUMBER;
      l_root                      BOOLEAN;

      l_lock_status               NUMBER := 0;
      l_child_ind                 NUMBER := 0;
      l_found_locked              BOOLEAN;

      CURSOR comp_cur(l_root_inst_hdr_id IN number, l_root_inst_rev_num IN number,
		      l_config_inst_hdr_id IN NUMBER,l_config_inst_rev_num IN NUMBER,
		      l_config_inst_item_id IN NUMBER) IS
       SELECT *
	FROM   csi_item_instance_locks
	WHERE  root_config_inst_hdr_id  = l_root_inst_hdr_id
	AND    root_config_inst_rev_num = l_root_inst_rev_num
	AND    NOT( config_inst_hdr_id = l_config_inst_hdr_id
	AND         config_inst_rev_num = l_config_inst_rev_num
	AND         config_inst_item_id = l_config_inst_item_id )
	AND    lock_status <> 0;

  BEGIN

     x_return_status := fnd_api.g_ret_sts_success;
     api_log('unlock_current_node');

     savepoint unlock_current_node;

     -- This is called from csi_order_fulfillment proc.
     debug('Processing unlock for config keys:'|| p_config_rec.config_inst_hdr_id||'-'|| p_config_rec.config_inst_rev_num||'-'||p_config_rec.config_inst_item_id);

     l_config_rec := p_config_rec;

     -- Populate the Subject and Object Config Key along with the lock status
     -- for the fulfillable Item with Connected-To relationship.
     debug('Populating the connected to keys for the passed key');

     populate_connected_tbl(
	p_config_inst_header_id => p_config_rec.config_inst_hdr_id,
	p_config_inst_rev_num   => p_config_rec.config_inst_rev_num,
	p_config_inst_item_id   => p_config_rec.config_inst_item_id,
	p_config_rec            => l_config_rec,
	x_conn_config_tbl       => x_conn_config_tbl,
	x_return_status         => x_return_status);

     IF x_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;


     -- If any of the neighbours of the fulfilled INstance is in Locked status
     -- then mark the fulfillable instance to be "To Be Unlocked i.e 1"
     --
     l_found_locked := FALSE;
     l_root := TRUE; -- Defaulting it to TRUE becos if neighbors are in locked state then
		     -- the current node should be set to 1. Root will be checked only if
		     -- all connected-to's are in unlocked state.
     IF x_conn_config_tbl.count > 0 THEN
	FOR i in x_conn_config_tbl.FIRST .. x_conn_config_tbl.LAST
	LOOP
	   IF x_conn_config_tbl(i).lock_status = 2 THEN
	      l_found_locked := TRUE;
	      EXIT;
	   END IF;
	END LOOP;
     END IF;
     --
     IF l_found_locked  = FALSE THEN
	debug('None of the Connected-To are in Locked Status. So Checking Components..');
	-- Checking for component of relationships
	SELECT root_config_inst_hdr_id,
	       root_config_inst_rev_num,
	       root_config_inst_item_id
	INTO   l_root_inst_hdr_id,
	       l_root_inst_rev_num,
	       l_root_inst_item_id
	FROM   csi_item_instance_locks
	WHERE  config_inst_hdr_id  = p_config_rec.config_inst_hdr_id
	AND    config_inst_rev_num = p_config_rec.config_inst_rev_num
	AND    config_inst_item_id = p_config_rec.config_inst_item_id;
	--
	IF p_config_rec.config_inst_hdr_id = l_root_inst_hdr_id AND
	   p_config_rec.config_inst_rev_num = l_root_inst_rev_num AND
	   p_config_rec.config_inst_item_id = l_root_inst_item_id THEN
	   debug('Current Node qualifies as Root...');
	   l_root := TRUE;
	ELSE
           debug('Current Node is not the Root...');
	   l_root := FALSE;
	END IF;
	--
	FOR comp_rec IN COMP_CUR(l_root_inst_hdr_id,l_root_inst_rev_num,
				 p_config_rec.config_inst_hdr_id,
				 p_config_rec.config_inst_rev_num,
				 p_config_rec.config_inst_item_id ) LOOP
	   IF comp_rec.lock_status = 2 THEN
	      debug('One of the components is in Locked State. Cannot un-lock the Root..');
	      l_found_locked := TRUE;
	      l_config_tbl.DELETE; -- Deleting the children from the List
	      EXIT;
	   END IF;
	   --
	   -- Keep Adding the components to the list.
	   -- Look for components connections
	   l_child_config_rec.config_inst_hdr_id := comp_rec.config_inst_hdr_id;
	   l_child_config_rec.config_inst_rev_num := comp_rec.config_inst_rev_num;
	   l_child_config_rec.config_inst_item_id := comp_rec.config_inst_item_id;
	   --
           -- Even though the components that are in 1 status are purely because of their
           -- connections havig status 2, we still call the populate_connected_tbl routine.
           -- This is because during re-configuring API will lock the components which are not
           -- there in the order with status 1. Obviously, such configurations won't be there
           -- in CSI_T_II_RELATIONSHIPS. Since we cannot distinguish between configuring and re-configuring
           -- we always call the below routine to look for component's connections.
           --
	   populate_connected_tbl(
	      p_config_inst_header_id => comp_rec.config_inst_hdr_id,
	      p_config_inst_rev_num   => comp_rec.config_inst_rev_num,
	      p_config_inst_item_id   => comp_rec.config_inst_item_id,
	      p_config_rec            => l_child_config_rec,
	      x_conn_config_tbl       => l_comp_conn_config_tbl,
	      x_return_status         => x_return_status);

	   IF x_return_status <> fnd_api.g_ret_sts_success THEN
	      RAISE fnd_api.g_exc_error;
	   END IF;
	   --
	   IF l_comp_conn_config_tbl.count > 0 THEN
	      FOR i in l_comp_conn_config_tbl.FIRST .. l_comp_conn_config_tbl.LAST
	      LOOP
		 IF l_comp_conn_config_tbl(i).lock_status = 2 THEN
		    l_found_locked := TRUE;
		    EXIT;
		 END IF;
	      END LOOP;
	   END IF;
	   --
	   IF l_found_locked = TRUE THEN
	      EXIT;
	   END IF;
	   --
	   l_child_ind := l_config_tbl.count + 1;
	   l_config_tbl(l_child_ind).config_inst_hdr_id := comp_rec.config_inst_hdr_id;
	   l_config_tbl(l_child_ind).config_inst_rev_num := comp_rec.config_inst_rev_num;
	   l_config_tbl(l_child_ind).config_inst_item_id := comp_rec.config_inst_item_id;
	   l_config_tbl(l_child_ind).lock_id     := comp_rec.lock_id;
	   l_config_tbl(l_child_ind).lock_status := 0;
	   l_config_tbl(l_child_ind).source_txn_header_ref := p_config_rec.source_txn_header_ref;
	   l_config_tbl(l_child_ind).source_txn_line_ref1 := p_config_rec.source_txn_line_ref1;
	   l_config_tbl(l_child_ind).source_application_id := p_config_rec.source_application_id;
	END LOOP;
     END IF; -- components check
     --
     IF l_found_locked THEN
	l_config_tbl.DELETE; -- Ignoring the previously loaded list
	IF l_root = TRUE THEN
	   l_config_tbl(1)             := p_config_rec;
	   l_config_tbl(1).lock_status := 1;
	ELSE
	   l_config_tbl(1)             := p_config_rec;
	   l_config_tbl(1).lock_status := 0;
	END IF;
     ELSE -- Along with the children, parent will get unlocked. Adding the parent
	l_child_ind := l_config_tbl.count + 1;
	l_config_tbl(l_child_ind)             := p_config_rec;
	l_config_tbl(l_child_ind).lock_status := 0;
     END IF;
     --
     csi_t_gen_utility_pvt.dump_api_info(
	       p_pkg_name => 'csi_item_instance_pvt',
	       p_api_name => 'unlock_item_instance');

     csi_t_gen_utility_pvt.dump_csi_config_tbl(
	       p_config_tbl => l_config_tbl);

     csi_item_instance_pvt.unlock_item_instances(
	p_api_version         => 1.0,
	p_commit              => fnd_api.g_false,
	p_init_msg_list       => fnd_api.g_true,
	p_validation_level    => fnd_api.g_valid_level_full,
	p_config_tbl          => l_config_tbl,
	p_unlock_all          => fnd_api.g_false,
	x_return_status       => x_return_status,
	x_msg_count           => x_msg_count,
	x_msg_data            => x_msg_data);

     IF x_return_status <> fnd_api.g_ret_sts_success THEN
	debug('Failed csi_item_instance_pvt.unlock_item_instance');
	RAISE fnd_api.g_exc_error;
     END IF;
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status  := fnd_api.g_ret_sts_error;
	l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
	FND_MSG_PUB.Count_And_Get
	     (p_count        =>      x_msg_count ,
	      p_data         =>      x_msg_data   );
	rollback to unlock_current_node;
	debug(l_return_message);
     WHEN others THEN
	fnd_message.set_name ('FND', 'FND_GENERIC_MESSAGE');
	fnd_message.set_token('MESSAGE', 'OTHERS Error :'||substr(sqlerrm, 1, 300));
	fnd_msg_pub.add;
	FND_MSG_PUB.Count_And_Get
	     (p_count        =>      x_msg_count ,
	      p_data         =>      x_msg_data   );
	x_return_status  := fnd_api.g_ret_sts_error;
	l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
	rollback to unlock_current_node;
	debug(l_return_message);
  END Unlock_Current_Node;

  PROCEDURE unlock_item_instances(
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2 := FND_API.g_false,
        p_commit             IN VARCHAR2 := FND_API.g_false,
        p_validation_level   IN NUMBER  := FND_API.g_valid_level_full,
        p_config_tbl         IN config_tbl,
        x_return_status      OUT NOCOPY    varchar2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2 )
  IS
    l_txn_rec            csi_datastructures_pub.transaction_rec;
    l_config_tbl         config_tbl;
    l_all_config_tbl     config_tbl;
    l_config_rec         config_rec;
    x_conn_config_tbl    config_tbl;
    l_conn_config_tbl    config_tbl;
    l_return_message     VARCHAR2(2000);
    l_lock_status        NUMBER := 0;
    l_from_cz            VARCHAR2(10) := 'NO';

    l_lock_config_rec    config_rec;
    l_lock_id            NUMBER;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('unlock_item_instance');

    savepoint csi_cz_unlock_item;

    -- Building txn rec
    -- l_txn_rec.transaction_id                 := fnd_api.g_miss_num;
    l_txn_rec.transaction_date               := sysdate;
    l_txn_rec.source_transaction_date        := sysdate;
    l_txn_rec.transaction_type_id            := 401;

    -- Populate Lock_id for passed keys
    If p_config_tbl.count > 0 Then
      Begin
        Select config_inst_hdr_id,
               config_inst_item_id,
               config_inst_rev_num,
               lock_id,
               lock_source_appln_id,
               lock_source_header_ref
        Into   l_lock_config_rec.config_inst_hdr_id,
               l_lock_config_rec.config_inst_item_id,
               l_lock_config_rec.config_inst_rev_num,
               l_lock_config_rec.lock_id,
               l_lock_config_rec.source_application_id,
               l_lock_config_rec.source_txn_header_ref
        From   csi_item_instance_locks
        Where  config_inst_hdr_id  =  p_config_tbl(1).config_inst_hdr_id
        And    config_inst_item_id =  p_config_tbl(1).config_inst_item_id
        And    config_inst_rev_num =  p_config_tbl(1).config_inst_rev_num;

      Exception
        When OTHERS Then
          debug('Lock_Id not found for keys '|| p_config_tbl(1).config_inst_hdr_id||'-'||p_config_tbl(1).config_inst_item_id||'-'||p_config_tbl(1).config_inst_rev_num);
          Null;
      End;
    End If;

    -- Validate the lock_id if this proc. is called from other callers.
    IF p_config_tbl.count > 0
    THEN
      FOR l_key in p_config_tbl.FIRST .. p_config_tbl.LAST
      LOOP
        IF ( p_config_tbl(l_key).source_application_id <> 542
            AND
             p_config_tbl(l_key).source_application_id <> fnd_api.g_miss_num
           )
          AND
           -- In future need to make sure that lock_id is passed from other callers.
           ( p_config_tbl(l_key).source_txn_header_ref is NULL--lock_id is NULL
            OR
             p_config_tbl(l_key).source_txn_header_ref = fnd_api.g_miss_char --lock_id = fnd_api.g_miss_num
           )
        THEN
          fnd_message.set_name('CSI','CSI_CZ_LOCK_ID_MISS');
          fnd_message.set_token('CONFIG_INST_HDR_ID',p_config_tbl(l_key).config_inst_hdr_id);
          fnd_message.set_token('CONFIG_INST_REV_NUM',p_config_tbl(l_key).config_inst_rev_num);
          fnd_message.set_token('CONFIG_INST_ITEM_ID',p_config_tbl(l_key).config_inst_item_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
          EXIT;
        END IF;
      END LOOP;
    END IF;

   -- If this proc. is called from other callers this might be a cancellation, delete etc..
   -- So setting the lock status to "0" for all the passed keys

   debug('Source Application id :'||p_config_tbl(1).source_application_id);

   IF p_config_tbl(1).source_application_id <> 542
   THEN
     -- This call is made for Cancellation. Suppose we re-configure an existing configuration and cancelling the same,
     -- OM unlocks the configuration. When the same order is re-configured again CZ puts the same revision number
     -- for the new lines. This creates multiple records in CSI_ITEM_INSTANCE_LOCKS for the config keys.
     -- To avoid this, we are deleting the rows upon cancellation.
     --
     DELETE FROM CSI_ITEM_INSTANCE_LOCKS
     WHERE lock_id = l_lock_config_rec.lock_id;
     --
     /********* COMMENTED
     l_from_cz := 'YES';
     IF p_config_tbl.count > 0
     THEN
       FOR i in p_config_tbl.FIRST .. p_config_tbl.LAST
       LOOP
         l_all_config_tbl(i) := p_config_tbl(i);
         l_all_config_tbl(i).lock_id :=  l_lock_config_rec.lock_id;
         l_all_config_tbl(i).lock_status := 0;
       END LOOP;

        debug('Before call to csi_item_instance_pvt.unlock_item_instances');
        debug('Record count passed to api '||nvl(l_all_config_tbl.count,0));


       csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pvt',
              p_api_name => 'unlock_item_instance');

       csi_t_gen_utility_pvt.dump_csi_config_tbl(
              p_config_tbl => l_all_config_tbl);

       csi_item_instance_pvt.unlock_item_instances(
                p_api_version         => 1.0,
                p_commit              => fnd_api.g_false,
                p_init_msg_list       => fnd_api.g_true,
                p_validation_level    => fnd_api.g_valid_level_full,
                p_config_tbl          => l_all_config_tbl,
                p_unlock_all          => fnd_api.g_true,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Failed csi_item_instance_pvt.unlock_item_instance');
          RAISE fnd_api.g_exc_error;
       END IF;
     END IF;
     ******** END OF COMMENT *******/
   ELSE
      -- This is called from csi_order_fulfillment proc.
      IF p_config_tbl.count > 0 and l_from_cz = 'NO'
      THEN
         -- For each passed key if the Lock status is "0" then condtinue the algorithm
         FOR l_key in p_config_tbl.FIRST .. p_config_tbl.LAST
         LOOP
	    get_lock_status(
		    p_config_inst_header_id => p_config_tbl(l_key).config_inst_hdr_id,
		    p_config_inst_rev_num   => p_config_tbl(l_key).config_inst_rev_num,
		    p_config_inst_item_id   => p_config_tbl(l_key).config_inst_item_id,
		    x_lock_status           => l_lock_status,
		    x_lock_id               => l_lock_id
		    );
            IF l_lock_status = 2 THEN
               l_config_rec := p_config_tbl(l_key);
               l_config_rec.lock_id := l_lock_id;
               --
               Unlock_Current_Node(
		   p_api_version        => 1.0,
		   p_init_msg_list      => fnd_api.g_true,
		   p_commit             => fnd_api.g_false,
		   p_validation_level   => fnd_api.g_valid_level_full,
		   p_config_rec         => l_config_rec,
		   x_conn_config_tbl    => x_conn_config_tbl,
		   x_return_status      => x_return_status,
		   x_msg_count          => x_msg_count,
		   x_msg_data           => x_msg_data);

	       IF x_return_status <> fnd_api.g_ret_sts_success THEN
	          debug('Failed unlock_current_node');
	          RAISE fnd_api.g_exc_error;
	       END IF;
               --
               -- Process IJs
               debug('Connected to key count :'||nvl(x_conn_config_tbl.count,0));
               --
	       IF x_conn_config_tbl.count > 0 THEN
		  debug('Process IJs...');
		  FOR i in x_conn_config_tbl.FIRST .. x_conn_config_tbl.LAST
		  LOOP
		     get_lock_status(
				p_config_inst_header_id => x_conn_config_tbl(i).config_inst_hdr_id,
				p_config_inst_rev_num   => x_conn_config_tbl(i).config_inst_rev_num,
				p_config_inst_item_id   => x_conn_config_tbl(i).config_inst_item_id,
				x_lock_status           => l_lock_status,
				x_lock_id               => l_lock_id
				);
		     IF l_lock_status = 1 THEN -- Lock Status should be 1 for IJs
                        l_config_rec := x_conn_config_tbl(i);
                        l_config_rec.lock_id := l_lock_id;
                        --
			Unlock_Current_Node(
			   p_api_version        => 1.0,
			   p_init_msg_list      => fnd_api.g_true,
			   p_commit             => fnd_api.g_false,
			   p_validation_level   => fnd_api.g_valid_level_full,
			   p_config_rec         => l_config_rec,
			   x_conn_config_tbl    => l_conn_config_tbl, -- will not be used further
			   x_return_status      => x_return_status,
			   x_msg_count          => x_msg_count,
			   x_msg_data           => x_msg_data);

			IF x_return_status <> fnd_api.g_ret_sts_success THEN
			   debug('Failed unlock_current_node for IJs...');
			   RAISE fnd_api.g_exc_error;
			END IF;
		     END IF;
		  END LOOP;
	       END IF;
            ELSE
               debug('Config keys are already in unlocked status');
               FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LOCKS');
               FND_MSG_PUB.Add;
            END IF;
         END LOOP;
      END IF;
   END IF;

  -- Standard call to get message count and if count is  get message info.
  FND_MSG_PUB.Count_And_Get
          (p_count        =>      x_msg_count ,
           p_data         =>      x_msg_data   );

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      FND_MSG_PUB.Count_And_Get
           (p_count        =>      x_msg_count ,
            p_data         =>      x_msg_data   );
      rollback to csi_cz_unlock_item;
      debug(l_return_message);
    WHEN others THEN
      fnd_message.set_name ('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', 'OTHERS Error :'||substr(sqlerrm, 1, 300));
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
           (p_count        =>      x_msg_count ,
            p_data         =>      x_msg_data   );
      x_return_status  := fnd_api.g_ret_sts_error;
      l_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      rollback to csi_cz_unlock_item;
      debug(l_return_message);



  END unlock_item_instances;

  PROCEDURE configure_from_html_ui(
    p_session_hdr_id IN  number,
    p_instance_id    IN  number,
    -- Added the following 3 parameters fro bug 3711457
    p_session_rev_num_old IN number,
    p_session_rev_num_new IN number,
    p_action         IN      varchar2,
    x_error_message  OUT NOCOPY varchar2,
    x_return_status  OUT NOCOPY varchar2,
    x_msg_count      OUT NOCOPY number,
    x_msg_data       OUT NOCOPY varchar2)
  IS

    -- Included new parameter for the cursor for Bug 3711457
    CURSOR td_cur(p_sess_hdr_id IN number, p_sess_rev_num IN number) IS
      SELECT config_session_hdr_id,
             config_session_rev_num,
             config_session_item_id
      FROM   csi_t_transaction_lines
      WHERE  config_session_hdr_id = p_sess_hdr_id
      -- Added the and condition for Bug 3711457
      AND    config_session_rev_num = p_sess_rev_num
      ORDER BY config_session_item_id;

    l_session_keys   csi_utility_grp.config_session_keys;
    l_instance_tbl   csi_datastructures_pub.instance_tbl;
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;

    -- Added for BUg 3711457
    l_config_keys   td_cur%ROWTYPE;
    l_usage_exists  number;
    l_return_value  number;
    l_error_message varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiczuii',
      p_file_segment2 => p_session_hdr_id);

    debug('Re-Configure from Install Base HTML User Interface');
    api_log('configure_from_html_ui');

    debug('  p_session_hdr_id :'||p_session_hdr_id );
    debug('  p_instance_id    :'||p_instance_id );
    debug('  p_rev_num_old    :'||p_session_rev_num_old );
    debug('  p_rev_num_new    :'||p_session_rev_num_new );
    debug('  p_action         :'||p_action );

    savepoint configure_from_html_ui;

    -- Begin Code fix for Bug 3711457
    IF p_session_rev_num_old is NOT NULL
    THEN
      OPEN td_cur(p_session_hdr_id,p_session_rev_num_old);

      FETCH td_cur INTO l_config_keys;

      -- Calleg CZ Delete API to delete all the details
      -- corresponding to old_session_rev_number
      CZ_CF_API.delete_configuration(
        config_hdr_id  => p_session_hdr_id,
        config_rev_nbr => p_session_rev_num_old,
        usage_exists   => l_usage_exists,
        Error_message  => l_error_message,
        Return_value   => l_return_value);

        IF l_return_value <> 1
          AND
           td_cur%ROWCOUNT > 0
        THEN
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_error_message);
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      CLOSE td_cur;
    END IF;

    IF p_action = 'SAVE'
      AND
       ( p_session_rev_num_new is not null
        AND
         p_session_rev_num_new <> fnd_api.g_miss_num
       )
    THEN
    -- End Code Fix for 3711457
    -- Included new parameter for the cursor for Bug 3711457
      FOR td_rec IN td_cur (p_session_hdr_id,p_session_rev_num_new)
      LOOP

        l_session_keys(td_cur%rowcount).session_hdr_id := td_rec.config_session_hdr_id;
        l_session_keys(td_cur%rowcount).session_rev_num := td_rec.config_session_rev_num;
        l_session_keys(td_cur%rowcount).session_item_id := td_rec.config_session_item_id;

      END LOOP;

      csi_interface_pkg.process_cz_txn_details(
        p_config_session_keys  => l_session_keys,
        p_instance_id          => p_instance_id,
        x_instance_tbl         => l_instance_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      debug('Re-Configure from Install Base HTML User Interface successful.');
    END IF; -- Added for Bug 3711457

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      rollback to configure_from_html_ui;

      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      x_msg_data      := x_error_message;
      x_msg_count     := 1;
    WHEN others THEN

      rollback to configure_from_html_ui;

      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := substr(sqlerrm, 1, 500);
      x_msg_data      := x_error_message;
      x_msg_count     := 1;

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', x_error_message);
      fnd_msg_pub.add;

  END configure_from_html_ui;

Procedure CSI_CONFIG_LAUNCH_PRMS
(	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level	IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	x_configurable OUT NOCOPY 	VARCHAR2,
	x_icx_sessn_tkt OUT NOCOPY VARCHAR2,
	x_db_id	 OUT NOCOPY VARCHAR2,
	x_servlet_url OUT NOCOPY VARCHAR2,
	x_sysdate OUT NOCOPY VARCHAR2
) is
	l_api_name	CONSTANT VARCHAR2(30)	:= 'CSI_CONFIG_LAUNCH_PRMS';
	l_api_version	CONSTANT NUMBER		:= 1.0;

	l_resp_id		NUMBER;
	l_resp_appl_id		NUMBER;
	l_log_enabled   VARCHAR2(1) := 'N';
	l_user_id	NUMBER;

BEGIN
	l_user_id := fnd_global.user_id;

	SAVEPOINT	CSI_CONFIG_LAUNCH_PRMS;
	-- Standard call to check for call compatibility.
	/*IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;*/

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;


	l_resp_id := fnd_profile.value('RESP_ID');
	l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');

	-- get icx session ticket
	x_icx_sessn_tkt := CZ_CF_API.ICX_SESSION_TICKET;

	-- get the dbc file name
	x_db_id := FND_WEB_CONFIG.DATABASE_ID;

	-- get the URL for servlet
	x_servlet_url := fnd_profile.value('CZ_UIMGR_URL');

	-- get the SYSDATE
	x_sysdate := to_char(sysdate,'mm-dd-yyyy-hh24-mi-ss');


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(  	p_encoded 		=> FND_API.G_FALSE,
    		p_count         =>      x_msg_count,
        	p_data          =>      x_msg_data
    	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CSI_CONFIG_LAUNCH_PRMS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		csi_gen_utility_pvt.put_line('csi_cz_int.CSI_CONFIG_LAUNCH_PRMS: UNEXPECTED ERROR EXCEPTION ');
		ROLLBACK TO CSI_CONFIG_LAUNCH_PRMS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
       			p_data         	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		csi_gen_utility_pvt.put_line('csi_cz_int.CSI_CONFIG_LAUNCH_PRMS: OTHER EXCEPTION ');
		ROLLBACK TO CSI_CONFIG_LAUNCH_PRMS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		/*IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;*/
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
       			p_data         	=>      x_msg_data
    		);
		/*ibe_util.disable_debug;*/
END CSI_CONFIG_LAUNCH_PRMS; -- Procedure CSI_CONFIG_LAUNCH_PRMS



PROCEDURE IS_CONFIGURABLE(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT NOCOPY  VARCHAR2
                         ,x_return_status   OUT NOCOPY  VARCHAR2
                         ,x_msg_count       OUT NOCOPY  NUMBER
                         ,x_msg_data        OUT NOCOPY  VARCHAR2
                         ) IS
l_found    NUMBER;
BEGIN
    cz_network_api_pub.IS_CONFIGURABLE(p_api_version
                         ,p_config_hdr_id
                         ,p_config_rev_nbr
                         ,p_config_item_id
                         ,x_return_value
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);

   -- Begin of fix for Bug 2873845
   -- Checking whether the config keys has a Instance.
   IF x_return_value = FND_API.G_FALSE
   THEN
     Begin
       Select count(*)
       Into   l_found
       From   csi_item_instances i,
              cz_config_items_v  c
       Where  i.config_inst_hdr_id  = c.instance_hdr_id
       and    i.config_inst_rev_num = c.instance_rev_nbr
       and    i.config_inst_item_id = c.config_item_id
       and    c.config_hdr_id       = p_config_hdr_id
       and    c.config_rev_nbr      = p_config_rev_nbr
       and    c.config_item_id      = p_config_item_id;

       IF NVL(l_found,0) > 0 Then
         x_return_value := FND_API.G_TRUE;
       ELSE
         x_return_value := FND_API.G_FALSE;
       END IF;

     End;
   END IF;
   -- End of fix for Bug 2873845.

/*EXCEPTION
   WHEN exception_name THEN
       statements ;*/
END IS_CONFIGURABLE;


PROCEDURE generate_config_trees(p_api_version        IN   NUMBER,
                                p_config_query_table IN   config_query_table,
                                p_tree_copy_mode     IN   VARCHAR2,
                                x_cfg_model_tbl      OUT NOCOPY  config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
				        ) IS

      l_in_cfg_tbl CZ_API_PUB.config_tbl_type;
      l_tree_copy_mode VARCHAR2(4) := 'R';
      l_index integer := 0;
      l_config_model_tbl CZ_API_PUB.config_model_tbl_type;
      l_appl_param_rec CZ_API_PUB.appl_param_rec_type;

BEGIN
      IF 0 < p_config_query_table.count() THEN
        l_index := p_config_query_table.FIRST;

         l_appl_param_rec.config_creation_date     := sysdate;
         l_appl_param_rec.config_model_lookup_date := null;
         l_appl_param_rec.config_effective_date    := null;
         l_appl_param_rec.usage_name               := null;
         l_appl_param_rec.publication_mode         := null;
         l_appl_param_rec.language   := 'US';
         l_appl_param_rec.calling_application_id   := 542;

         LOOP
            l_in_cfg_tbl(l_index).config_hdr_id := p_config_query_table(l_index).config_header_id;
            l_in_cfg_tbl(l_index).config_rev_nbr := p_config_query_table(l_index).config_revision_number;

            EXIT WHEN l_index = p_config_query_table.LAST;
            l_index := p_config_query_table.NEXT(l_index);
        END LOOP;

             CZ_NETWORK_API_PUB.generate_config_trees(p_api_version => p_api_version,
                                                      p_config_tbl =>l_in_cfg_tbl,
				                                      p_tree_copy_mode => l_tree_copy_mode,
                                                      p_appl_param_rec => l_appl_param_rec,
                                                      p_validation_context  => CZ_API_PUB.G_INSTALLED,
                                                      x_config_model_tbl=> l_config_model_tbl,
                                                      x_return_status =>x_return_status,
                                                      x_msg_count => x_msg_count,
                                                      x_msg_data => x_msg_data );

             IF 0 < l_config_model_tbl.count() THEN
             l_index := l_config_model_tbl.FIRST;

             LOOP
                x_cfg_model_tbl(l_index).inventory_item_id := l_config_model_tbl(l_index).inventory_item_id;
                x_cfg_model_tbl(l_index).organization_id := l_config_model_tbl(l_index).organization_id;
                x_cfg_model_tbl(l_index).config_hdr_id := l_config_model_tbl(l_index).config_hdr_id;
                x_cfg_model_tbl(l_index).config_rev_nbr := l_config_model_tbl(l_index).config_rev_nbr;
                x_cfg_model_tbl(l_index).config_item_id := l_config_model_tbl(l_index).config_item_id;

               EXIT WHEN l_index = l_config_model_tbl.LAST;
               l_index := l_config_model_tbl.NEXT(l_index);
             END LOOP;
             END IF; --IF 0 < l_config_model_tbl.count() THEN

       END IF; --IF 0 < p_config_query_table.count() THEN

END generate_config_trees;

END csi_cz_int;

/
