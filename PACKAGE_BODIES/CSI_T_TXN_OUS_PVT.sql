--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_OUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_OUS_PVT" AS
/* $Header: csivtoub.pls 115.8 2002/11/12 00:31:37 rmamidip noship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_ous_pvt';
  g_file_name   CONSTANT VARCHAR2(12) := 'csivtoub.pls';

  g_user_id              NUMBER := fnd_global.user_id;
  g_login_id             NUMBER := fnd_global.login_id;

  PROCEDURE create_txn_org_assgn_dtls(
    p_api_version             IN     number,
    p_commit                  IN     varchar2 := fnd_api.g_false,
    p_init_msg_list           IN     varchar2 := fnd_api.g_false,
    p_validation_level        IN     number   := fnd_api.g_valid_level_full,
    p_txn_org_assgn_rec       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_rec,
    x_return_status              OUT NOCOPY varchar2,
    x_msg_count                  OUT NOCOPY number,
    x_msg_data                   OUT NOCOPY varchar2)

  IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'create_txn_org_assgn_dtls';
    l_api_version       CONSTANT NUMBER        := 1.0;
    l_debug_level                NUMBER;
    l_txn_operating_unit_id      NUMBER;
    l_preserve_detail_flag       VARCHAR2(1);

    l_return_status              VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_valid                      BOOLEAN;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_org_assgn_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    --debug info
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 THEN
      csi_t_gen_utility_pvt.dump_org_assgn_rec(
        p_org_assgn_rec => p_txn_org_assgn_rec);
    END IF;

    -- Main API code
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_org_assgn_rec.operating_unit_id,
      p_param_name => 'p_txn_org_assgn_rec.operating_unit_id',
      p_api_name   => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_org_assgn_rec.relationship_type_code,
      p_param_name => 'p_txn_org_assgn_rec.relationship_type_code',
      p_api_name   => l_api_name);

    -- validate operating unit
    l_valid :=
      csi_org_unit_vld_pvt.is_valid_operating_unit_id(
        p_operating_unit_id => p_txn_org_assgn_rec.operating_unit_id);
    IF NOT (l_valid) THEN
      csi_t_gen_utility_pvt.add('Validate operating unit id failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate relationship_type_code
    l_valid :=
     csi_org_unit_vld_pvt.is_valid_rel_type_code(
       p_relationship_type_code => p_txn_org_assgn_rec.relationship_type_code);

    IF NOT (l_valid) THEN
      csi_t_gen_utility_pvt.add('Validate ou relationship type code  failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    IF nvl(p_txn_org_assgn_rec.instance_ou_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      csi_t_vldn_routines_pvt.validate_instance_reference(
        p_level              => 'ORG_ASSGN',
        p_level_dtl_id       => p_txn_org_assgn_rec.txn_line_detail_id,
        p_level_inst_ref_id  => p_txn_org_assgn_rec.instance_ou_id,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    SELECT decode(nvl(p_txn_org_assgn_rec.preserve_detail_flag,fnd_api.g_miss_char),
             fnd_api.g_miss_char, 'Y', p_txn_org_assgn_rec.preserve_detail_flag)
    INTO   l_preserve_detail_flag
    FROM   sys.dual;

    -- call table handler

    if nvl(p_txn_org_assgn_rec.txn_operating_unit_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num then
      l_txn_operating_unit_id := p_txn_org_assgn_rec.txn_operating_unit_id;
    end if;

    --debug info
    begin

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_org_assignments_pkg');

      csi_t_org_assignments_pkg.insert_row(
        px_txn_operating_unit_id => l_txn_operating_unit_id,
        p_txn_line_detail_id     => p_txn_org_assgn_rec.txn_line_detail_id,
        p_operating_unit_id      => p_txn_org_assgn_rec.operating_unit_id,
        p_relationship_type_code => p_txn_org_assgn_rec.relationship_type_code,
        p_active_start_date      => p_txn_org_assgn_rec.active_start_date,
        p_active_end_date        => p_txn_org_assgn_rec.active_end_date,
        p_preserve_detail_flag   => l_preserve_detail_flag,
        p_instance_ou_id         => p_txn_org_assgn_rec.instance_ou_id,
        p_attribute1             => p_txn_org_assgn_rec.attribute1,
        p_attribute2             => p_txn_org_assgn_rec.attribute2,
        p_attribute3             => p_txn_org_assgn_rec.attribute3,
        p_attribute4             => p_txn_org_assgn_rec.attribute4,
        p_attribute5             => p_txn_org_assgn_rec.attribute5,
        p_attribute6             => p_txn_org_assgn_rec.attribute6,
        p_attribute7             => p_txn_org_assgn_rec.attribute7,
        p_attribute8             => p_txn_org_assgn_rec.attribute8,
        p_attribute9             => p_txn_org_assgn_rec.attribute9,
        p_attribute10            => p_txn_org_assgn_rec.attribute10,
        p_attribute11            => p_txn_org_assgn_rec.attribute11,
        p_attribute12            => p_txn_org_assgn_rec.attribute12,
        p_attribute13            => p_txn_org_assgn_rec.attribute13,
        p_attribute14            => p_txn_org_assgn_rec.attribute14,
        p_attribute15            => p_txn_org_assgn_rec.attribute15,
        p_created_by             => g_user_id,
        p_creation_date          => sysdate,
        p_last_updated_by        => g_user_id,
        p_last_update_date       => sysdate,
        p_last_update_login      => g_login_id,
        p_object_version_number  => 1.0,
        p_context                => p_txn_org_assgn_rec.context);

    exception
      when others then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_org_assignments_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    end;

    p_txn_org_assgn_rec.txn_operating_unit_id := l_txn_operating_unit_id;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      csi_t_gen_utility_pvt.set_debug_off;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO Create_Txn_Org_Assgn_Dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO Create_Txn_Org_Assgn_Dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Create_Txn_Org_Assgn_Dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(
           p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error) THEN

        fnd_msg_pub.add_exc_msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END create_txn_org_assgn_dtls;

  PROCEDURE update_txn_org_assgn_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_org_assgn_tbl      IN  csi_t_datastructures_grp.txn_org_assgn_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_org_assgn_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_ou_rec                  csi_t_org_assignments%rowtype;
    l_processing_status       csi_t_transaction_lines.processing_status%TYPE;
    l_valid                   BOOLEAN := TRUE;

    CURSOR ou_cur (l_txn_ou_id in number) IS
      SELECT *
      FROM   csi_t_org_assignments
      WHERE  txn_operating_unit_id = l_txn_ou_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_org_assgn_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    --debug info
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_org_assgn_tbl.COUNT > 0 THEN

      FOR l_ind in p_txn_org_assgn_tbl.FIRST..p_txn_org_assgn_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_org_assgn_rec(
            p_org_assgn_rec => p_txn_org_assgn_tbl(l_ind));
        END IF;

        l_ou_rec.txn_operating_unit_id :=
          p_txn_org_assgn_tbl(l_ind).txn_operating_unit_id;

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value      => l_ou_rec.txn_operating_unit_id,
          p_param_name => 'l_ou_rec.txn_operating_unit_id',
          p_api_name   => l_api_name);

        csi_t_vldn_routines_pvt.validate_txn_ou_id(
          p_txn_operating_unit_id => l_ou_rec.txn_operating_unit_id,
          x_return_status         => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_OU_ID_INVALID');
          FND_MESSAGE.set_token('TXN_OU_ID',l_ou_rec.txn_operating_unit_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        FOR l_ou_cur_rec in ou_cur(l_ou_rec.txn_operating_unit_id)
        LOOP

          l_ou_rec.txn_line_detail_id    := l_ou_cur_rec.txn_line_detail_id;

          csi_t_vldn_routines_pvt.get_processing_status(
            p_level             => 'ORG_ASSGN',
            p_level_dtl_id      => l_ou_rec.txn_line_detail_id,
            x_processing_status => l_processing_status,
            x_return_status     => l_return_status);

          IF l_processing_status = 'PROCESSED' THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
            FND_MESSAGE.set_token('LVL_ID', l_ou_rec.txn_operating_unit_id);
            FND_MESSAGE.set_token('STATUS',l_processing_status);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          l_ou_rec.operating_unit_id     :=
            p_txn_org_assgn_tbl(l_ind).operating_unit_id;

          -- validate operating_unit_id
          IF l_ou_rec.operating_unit_id <> fnd_api.g_miss_num THEN

            l_valid :=
              csi_org_unit_vld_pvt.is_valid_operating_unit_id(
                p_operating_unit_id => l_ou_rec.operating_unit_id);
            IF NOT (l_valid) THEN
              csi_t_gen_utility_pvt.add('Validate operating unit id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_ou_rec.relationship_type_code:=
            p_txn_org_assgn_tbl(l_ind).relationship_type_code;

          -- validate org relationship_type_code
          IF l_ou_rec.relationship_type_code <> fnd_api.g_miss_char THEN

            l_valid :=
              csi_org_unit_vld_pvt.is_valid_rel_type_code(
                p_relationship_type_code => l_ou_rec.relationship_type_code);
            IF NOT (l_valid) THEN
              csi_t_gen_utility_pvt.add('Validate ou relationship type code  failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_ou_rec.active_start_date     :=
            p_txn_org_assgn_tbl(l_ind).active_start_date;

          l_ou_rec.active_end_date       :=
            p_txn_org_assgn_tbl(l_ind).active_end_date;

          l_ou_rec.preserve_detail_flag  :=
            p_txn_org_assgn_tbl(l_ind).preserve_detail_flag;

          l_ou_rec.instance_ou_id        :=
            p_txn_org_assgn_tbl(l_ind).instance_ou_id;

          -- validate instance_ou_id
          IF nvl(l_ou_rec.instance_ou_id,fnd_api.g_miss_num) <>  fnd_api.g_miss_num
          THEN

            l_valid :=
              csi_org_unit_vld_pvt.is_valid_instance_ou_id(
                p_instance_ou_id => l_ou_rec.instance_ou_id);
            IF (l_valid) THEN
              csi_t_gen_utility_pvt.add('Validate instance ou id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_ou_rec.attribute1            := p_txn_org_assgn_tbl(l_ind).attribute1;
          l_ou_rec.attribute2            := p_txn_org_assgn_tbl(l_ind).attribute2;
          l_ou_rec.attribute3            := p_txn_org_assgn_tbl(l_ind).attribute3;
          l_ou_rec.attribute4            := p_txn_org_assgn_tbl(l_ind).attribute4;
          l_ou_rec.attribute5            := p_txn_org_assgn_tbl(l_ind).attribute5;
          l_ou_rec.attribute6            := p_txn_org_assgn_tbl(l_ind).attribute6;
          l_ou_rec.attribute7            := p_txn_org_assgn_tbl(l_ind).attribute7;
          l_ou_rec.attribute8            := p_txn_org_assgn_tbl(l_ind).attribute8;
          l_ou_rec.attribute9            := p_txn_org_assgn_tbl(l_ind).attribute9;
          l_ou_rec.attribute10           := p_txn_org_assgn_tbl(l_ind).attribute10;
          l_ou_rec.attribute11           := p_txn_org_assgn_tbl(l_ind).attribute11;
          l_ou_rec.attribute12           := p_txn_org_assgn_tbl(l_ind).attribute12;
          l_ou_rec.attribute13           := p_txn_org_assgn_tbl(l_ind).attribute13;
          l_ou_rec.attribute14           := p_txn_org_assgn_tbl(l_ind).attribute14;
          l_ou_rec.attribute15           := p_txn_org_assgn_tbl(l_ind).attribute15;
          l_ou_rec.created_by            := l_ou_cur_rec.created_by;
          l_ou_rec.creation_date         := l_ou_cur_rec.creation_date;
          l_ou_rec.last_updated_by       := g_user_id;
          l_ou_rec.last_update_date      := sysdate;
          l_ou_rec.last_update_login     := g_login_id;
          l_ou_rec.object_version_number := p_txn_org_assgn_tbl(l_ind).object_version_number;
          l_ou_rec.context               := p_txn_org_assgn_tbl(l_ind).context;

          --debug info
          begin

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_t_org_assignments_pkg',
              p_api_name => 'update_row');

            csi_t_org_assignments_pkg.update_row(
              p_txn_operating_unit_id => l_ou_rec.txn_operating_unit_id,
              p_txn_line_detail_id    => l_ou_rec.txn_line_detail_id,
              p_operating_unit_id     => l_ou_rec.operating_unit_id,
              p_relationship_type_code=> l_ou_rec.relationship_type_code,
              p_active_start_date     => l_ou_rec.active_start_date,
              p_active_end_date       => l_ou_rec.active_end_date,
              p_preserve_detail_flag  => l_ou_rec.preserve_detail_flag,
              p_instance_ou_id        => l_ou_rec.instance_ou_id,
              p_attribute1            => l_ou_rec.attribute1,
              p_attribute2            => l_ou_rec.attribute2,
              p_attribute3            => l_ou_rec.attribute3,
              p_attribute4            => l_ou_rec.attribute4,
              p_attribute5            => l_ou_rec.attribute5,
              p_attribute6            => l_ou_rec.attribute6,
              p_attribute7            => l_ou_rec.attribute7,
              p_attribute8            => l_ou_rec.attribute8,
              p_attribute9            => l_ou_rec.attribute9,
              p_attribute10           => l_ou_rec.attribute10,
              p_attribute11           => l_ou_rec.attribute11,
              p_attribute12           => l_ou_rec.attribute12,
              p_attribute13           => l_ou_rec.attribute13,
              p_attribute14           => l_ou_rec.attribute14,
              p_attribute15           => l_ou_rec.attribute15,
              p_created_by            => l_ou_rec.created_by,
              p_creation_date         => l_ou_rec.creation_date,
              p_last_updated_by       => l_ou_rec.last_updated_by,
              p_last_update_date      => l_ou_rec.last_update_date,
              p_last_update_login     => l_ou_rec.last_update_login,
              p_object_version_number => l_ou_rec.object_version_number,
              p_context               => l_ou_rec.context);

          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_org_assignments_pkg.update_row failed. '||substr(sqlerrm,1,200));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end;

        END LOOP;
      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_org_assgn_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO update_txn_org_assgn_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO update_txn_org_assgn_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(
           p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error) THEN

        fnd_msg_pub.add_exc_msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END update_txn_org_assgn_dtls;

  PROCEDURE delete_txn_org_assgn_dtls(
     p_api_version           IN  NUMBER
    ,p_commit                IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_org_assgn_ids_tbl IN  csi_t_datastructures_grp.txn_org_assgn_ids_tbl
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_org_assgn_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_return_status           VARCHAR2(1);
    l_txn_ou_id               NUMBER;

    l_line_dtl_id             NUMBER;

    CURSOR ou_cur (p_line_dtl_id IN NUMBER) IS
      SELECT txn_operating_unit_id
      FROM   csi_t_org_assignments
      WHERE  txn_line_detail_id = p_line_dtl_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_org_assgn_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    --debug info
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_org_assgn_ids_tbl.COUNT > 0 THEN

      FOR l_ind in p_txn_org_assgn_ids_tbl.FIRST..p_txn_org_assgn_ids_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          null; --##
        END IF;

        l_txn_ou_id := p_txn_org_assgn_ids_tbl(l_ind).txn_operating_unit_id;

        IF nvl(l_txn_ou_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          csi_t_vldn_routines_pvt.validate_txn_ou_id(
            p_txn_operating_unit_id => l_txn_ou_id,
            x_return_status         => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_OU_ID_INVALID');
            FND_MESSAGE.set_token('TXN_OU_ID',l_txn_ou_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          --debug info
          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'delete_row',
            p_pkg_name => 'csi_t_org_assignments_pkg');

          csi_t_org_assignments_pkg.delete_row(
            p_txn_operating_unit_id => l_txn_ou_id);

        ELSE

          l_line_dtl_id := p_txn_org_assgn_ids_tbl(l_ind).txn_line_detail_id;

          csi_t_vldn_routines_pvt.check_reqd_param(
            p_value      => l_line_dtl_id,
            p_param_name => 'p_txn_org_assgn_ids_tbl.txn_line_detail_id',
            p_api_name   => l_api_name);

          -- validate txn_line_detail_id
          csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
            p_txn_line_detail_id => l_line_dtl_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

             FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_DTL_ID_INVALID');
             FND_MESSAGE.set_token('LINE_DTL_ID',l_line_dtl_id);
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;

          END IF;

          FOR ou_rec in ou_cur (l_line_dtl_id)
          LOOP

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'delete_row',
              p_pkg_name => 'csi_t_org_assignments_pkg');

            csi_t_org_assignments_pkg.delete_row(
              p_txn_operating_unit_id => ou_rec.txn_operating_unit_id);

          END LOOP;

        END IF;

      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_org_assgn_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO delete_txn_org_assgn_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_org_assgn_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(
           p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error) THEN

        fnd_msg_pub.add_exc_msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_org_assgn_dtls;

  PROCEDURE get_org_assgn_dtls(
    p_line_dtl_id      in  number,
    x_org_assgn_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_oa_cur_id        integer;
    l_oa_rec           csi_t_datastructures_grp.txn_org_assgn_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    l_select_stmt :=
     'select txn_operating_unit_id, txn_line_detail_id, instance_ou_id, '||
     ' operating_unit_id, relationship_type_code, active_start_date, active_end_date, '||
     ' preserve_detail_flag, context, attribute1, attribute2, attribute3, attribute4, '||
     ' attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, '||
     ' attribute11, attribute12, attribute13, attribute14, attribute15, object_version_number '||
     'from   csi_t_org_assignments '||
     'where txn_line_detail_id = :line_dtl_id';

    l_oa_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_oa_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_oa_cur_id, 'line_dtl_id', p_line_dtl_id);

    dbms_sql.define_column(l_oa_cur_id,1,l_oa_rec.txn_operating_unit_id);
    dbms_sql.define_column(l_oa_cur_id,2,l_oa_rec.txn_line_detail_id);
    dbms_sql.define_column(l_oa_cur_id,3,l_oa_rec.instance_ou_id);
    dbms_sql.define_column(l_oa_cur_id,4,l_oa_rec.operating_unit_id);
    dbms_sql.define_column(l_oa_cur_id,5,l_oa_rec.relationship_type_code,30);
    dbms_sql.define_column(l_oa_cur_id,6,l_oa_rec.active_start_date);
    dbms_sql.define_column(l_oa_cur_id,7,l_oa_rec.active_end_date);
    dbms_sql.define_column(l_oa_cur_id,8,l_oa_rec.preserve_detail_flag,1);
    dbms_sql.define_column(l_oa_cur_id,9,l_oa_rec.context,30);
    dbms_sql.define_column(l_oa_cur_id,10,l_oa_rec.attribute1,150);
    dbms_sql.define_column(l_oa_cur_id,11,l_oa_rec.attribute2,150);
    dbms_sql.define_column(l_oa_cur_id,12,l_oa_rec.attribute3,150);
    dbms_sql.define_column(l_oa_cur_id,13,l_oa_rec.attribute4,150);
    dbms_sql.define_column(l_oa_cur_id,14,l_oa_rec.attribute5,150);
    dbms_sql.define_column(l_oa_cur_id,15,l_oa_rec.attribute6,150);
    dbms_sql.define_column(l_oa_cur_id,16,l_oa_rec.attribute7,150);
    dbms_sql.define_column(l_oa_cur_id,17,l_oa_rec.attribute8,150);
    dbms_sql.define_column(l_oa_cur_id,18,l_oa_rec.attribute9,150);
    dbms_sql.define_column(l_oa_cur_id,19,l_oa_rec.attribute10,150);
    dbms_sql.define_column(l_oa_cur_id,20,l_oa_rec.attribute11,150);
    dbms_sql.define_column(l_oa_cur_id,21,l_oa_rec.attribute12,150);
    dbms_sql.define_column(l_oa_cur_id,22,l_oa_rec.attribute13,150);
    dbms_sql.define_column(l_oa_cur_id,23,l_oa_rec.attribute14,150);
    dbms_sql.define_column(l_oa_cur_id,24,l_oa_rec.attribute15,150);
    dbms_sql.define_column(l_oa_cur_id,25,l_oa_rec.object_version_number);
    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_oa_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_oa_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_oa_cur_id,1,x_org_assgn_tbl(l_ind).txn_operating_unit_id);
      dbms_sql.column_value(l_oa_cur_id,2,x_org_assgn_tbl(l_ind).txn_line_detail_id);
      dbms_sql.column_value(l_oa_cur_id,3,x_org_assgn_tbl(l_ind).instance_ou_id);
      dbms_sql.column_value(l_oa_cur_id,4,x_org_assgn_tbl(l_ind).operating_unit_id);
      dbms_sql.column_value(l_oa_cur_id,5,x_org_assgn_tbl(l_ind).relationship_type_code);
      dbms_sql.column_value(l_oa_cur_id,6,x_org_assgn_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_oa_cur_id,7,x_org_assgn_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_oa_cur_id,8,x_org_assgn_tbl(l_ind).preserve_detail_flag);
      dbms_sql.column_value(l_oa_cur_id,9,x_org_assgn_tbl(l_ind).context);
      dbms_sql.column_value(l_oa_cur_id,10,x_org_assgn_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_oa_cur_id,11,x_org_assgn_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_oa_cur_id,12,x_org_assgn_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_oa_cur_id,13,x_org_assgn_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_oa_cur_id,14,x_org_assgn_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_oa_cur_id,15,x_org_assgn_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_oa_cur_id,16,x_org_assgn_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_oa_cur_id,17,x_org_assgn_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_oa_cur_id,18,x_org_assgn_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_oa_cur_id,19,x_org_assgn_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_oa_cur_id,20,x_org_assgn_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_oa_cur_id,21,x_org_assgn_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_oa_cur_id,22,x_org_assgn_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_oa_cur_id,23,x_org_assgn_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_oa_cur_id,24,x_org_assgn_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_oa_cur_id,25,x_org_assgn_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_oa_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_oa_cur_id) THEN
       dbms_sql.close_cursor(l_oa_cur_id);
     END IF;
  END get_org_assgn_dtls;

  PROCEDURE get_all_org_assgn_dtls(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
    l_c_ind         binary_integer := 0;
    l_oa_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_tmp_oa_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_txn_line_detail_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
      LOOP
        l_tmp_oa_tbl.delete;

        get_org_assgn_dtls(
          p_line_dtl_id      => p_txn_line_detail_tbl(l_ind).txn_line_detail_id,
          x_org_assgn_tbl    => l_tmp_oa_tbl,
          x_return_status    => l_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_tmp_oa_tbl.count > 0 THEN
          FOR l_t_ind IN l_tmp_oa_tbl.FIRST .. l_tmp_oa_tbl.LAST
          LOOP
            l_c_ind := l_oa_tbl.count + 1;
            l_oa_tbl(l_c_ind) := l_tmp_oa_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;
    x_org_assgn_tbl := l_oa_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_org_assgn_dtls;

END csi_t_txn_ous_pvt;

/
