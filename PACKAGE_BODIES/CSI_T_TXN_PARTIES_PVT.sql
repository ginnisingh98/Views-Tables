--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_PARTIES_PVT" as
/* $Header: csivtpab.pls 120.4 2006/01/04 17:57:30 shegde noship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_parties_pvt';
  g_file_name   CONSTANT VARCHAR2(12) := 'csivtpab.pls';

  g_user_id              NUMBER := FND_GLOBAL.User_Id;
  g_login_id             NUMBER := FND_GLOBAL.Login_Id;

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_t_txn_parties_pvt',
      p_api_name => p_api_name);
  END api_log;

  PROCEDURE create_txn_party_dtls(
    p_api_version              IN     number,
    p_commit                   IN     varchar2 := fnd_api.g_false,
    p_init_msg_list            IN     varchar2 := fnd_api.g_false,
    p_validation_level         IN     number   := fnd_api.g_valid_level_full,
    p_txn_party_dtl_index      IN     number,
    p_txn_party_detail_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_rec,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status               OUT NOCOPY varchar2,
    x_msg_count                   OUT NOCOPY number,
    x_msg_data                    OUT NOCOPY varchar2)
  IS

    l_api_name       CONSTANT varchar2(30)  := 'create_txn_party_dtls';
    l_api_version    CONSTANT number        := 1.0;
    l_debug_level             number;
    l_index                   number;
    l_txn_party_detail_id     number;
    l_pty_acct_rec            csi_t_datastructures_grp.txn_pty_acct_detail_rec;
    l_preserve_detail_flag    varchar2(1);

    l_contact_flag            varchar2(1) := 'P';

    l_return_status           varchar2(1);
    l_msg_count               number;
    l_msg_data                varchar2(512);

  BEGIN

    -- Standard Start of API savepoint
    savepoint create_txn_party_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
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

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 then

      csi_t_gen_utility_pvt.add(
       p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

      csi_t_gen_utility_pvt.dump_party_detail_rec(
        p_party_detail_rec => p_txn_party_detail_rec);

    END IF;

    -- Main API code

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_party_detail_rec.txn_line_detail_id,
      p_param_name  => 'p_txn_party_detail_rec.txn_line_detail_id',
      p_api_name    => l_api_name);

    csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
      p_txn_line_detail_id => p_txn_party_detail_rec.txn_line_detail_id,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN

      FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_DTL_ID_INVALID');
      FND_MESSAGE.set_token('LINE_DTL_ID',
                             p_txn_party_detail_rec.txn_line_detail_id);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;

    END IF;


    IF NVL(p_txn_party_detail_rec.instance_party_id , fnd_api.g_miss_num) =
       fnd_api.g_miss_num
    THEN

      csi_t_vldn_routines_pvt.check_reqd_param(
        p_value       => p_txn_party_detail_rec.party_source_table,
        p_param_name  => 'p_txn_party_detail_rec.party_source_table',
        p_api_name    => l_api_name);

      csi_t_vldn_routines_pvt.check_reqd_param(
        p_value       => p_txn_party_detail_rec.party_source_id,
        p_param_name  => 'p_txn_party_detail_rec.party_source_id',
        p_api_name    => l_api_name);

    END IF;


    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_party_detail_rec.relationship_type_code,
      p_param_name  => 'p_txn_party_detail_rec.relationship_type_code',
      p_api_name    => l_api_name);


    -- validate party_source_table from cs_lookups
    IF NVL(p_txn_party_detail_rec.party_source_table, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN

      IF NOT
         csi_instance_parties_vld_pvt.is_pty_source_tab_valid(
           p_party_source_table => p_txn_party_detail_rec.party_source_table)
      THEN
        csi_t_gen_utility_pvt.add('Validate party source table failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;


    -- validate party_source_id for party_source_table
    IF NVL(p_txn_party_detail_rec.party_source_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      IF NOT
         csi_instance_parties_vld_pvt.is_party_valid(
           p_party_source_table => p_txn_party_detail_rec.party_source_table,
           p_party_id           => p_txn_party_detail_rec.party_source_id,
           p_contact_flag       => p_txn_party_detail_rec.contact_flag)
      THEN
        csi_t_gen_utility_pvt.add('Validate party source id failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- mandate contact flag
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_party_detail_rec.contact_flag,
      p_param_name  => 'p_txn_party_detail_rec.contact_flag',
      p_api_name    => l_api_name);

    -- contact_flag should be Y or N
    IF nvl(p_txn_party_detail_rec.contact_flag,fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN
      csi_t_vldn_routines_pvt.validate_contact_flag(
        p_contact_flag  => p_txn_party_detail_rec.contact_flag,
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_CONTACT_FLAG_INVALID');
        FND_MESSAGE.set_token ('CONTACT_FLAG', p_txn_party_detail_rec.contact_flag);

        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

      END IF;
    END IF;

    -- validate relationship_type_code from cs_lookups
    IF NVL(p_txn_party_detail_rec.relationship_type_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN

      IF p_txn_party_detail_rec.contact_flag = 'Y' THEN
        l_contact_flag := 'C';
      ELSE
        l_contact_flag := 'P';
      END IF;

      IF NOT
         csi_instance_parties_vld_pvt.is_pty_rel_type_valid(
           p_party_rel_type_code => p_txn_party_detail_rec.relationship_type_code,
           p_contact_flag        => l_contact_flag)
      THEN
        csi_t_gen_utility_pvt.add('Validate party relationship type code failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;


    -- validate instance_party_id from csi_i_parties
    IF NVL(p_txn_party_detail_rec.instance_party_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      csi_t_vldn_routines_pvt.validate_instance_reference(
        p_level             => 'PARTY',
        p_level_dtl_id      => p_txn_party_detail_rec.txn_line_detail_id,
        p_level_inst_ref_id => p_txn_party_detail_rec.instance_party_id,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_error THEN
        csi_t_gen_utility_pvt.add('Validate instance reference failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    --validate contact_party_id

    -- validate owner

    IF p_txn_party_detail_rec.relationship_type_code = 'OWNER' THEN

      csi_t_vldn_routines_pvt.is_valid_owner_for_create(
        p_txn_line_detail_id => p_txn_party_detail_rec.txn_line_detail_id,
        p_instance_party_id  => p_txn_party_detail_rec.instance_party_id,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_OWNER_ERROR');
        FND_MESSAGE.set_token('PTY_SRC_NAME',
                              p_txn_party_detail_rec.party_source_table);
        FND_MESSAGE.set_token('PTY_SRC_ID',
                              p_txn_party_detail_rec.party_source_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    SELECT decode(nvl(p_txn_party_detail_rec.preserve_detail_flag,fnd_api.g_miss_char),
             fnd_api.g_miss_char, 'Y', p_txn_party_detail_rec.preserve_detail_flag)
    INTO   l_preserve_detail_flag
    FROM   sys.dual;

    -- call table handler to create row in the table
    IF nvl(p_txn_party_detail_rec.txn_party_detail_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN
      l_txn_party_detail_id := p_txn_party_detail_rec.txn_party_detail_id;
    END IF;

    BEGIN

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_party_detailss_pkg');

      csi_t_party_details_pkg.insert_row(
        px_txn_party_detail_id   => l_txn_party_detail_id,
        p_txn_line_detail_id     => p_txn_party_detail_rec.txn_line_detail_id,
        p_party_source_table     => p_txn_party_detail_rec.party_source_table,
        p_party_source_id        => p_txn_party_detail_rec.party_source_id,
        p_relationship_type_code => p_txn_party_detail_rec.relationship_type_code,
        p_contact_flag           => p_txn_party_detail_rec.contact_flag,
        p_active_start_date      => p_txn_party_detail_rec.active_start_date,
        p_active_end_date        => p_txn_party_detail_rec.active_end_date,
        p_preserve_detail_flag   => l_preserve_detail_flag,
        p_instance_party_id      => p_txn_party_detail_rec.instance_party_id,
        p_attribute1             => p_txn_party_detail_rec.attribute1,
        p_attribute2             => p_txn_party_detail_rec.attribute2,
        p_attribute3             => p_txn_party_detail_rec.attribute3,
        p_attribute4             => p_txn_party_detail_rec.attribute4,
        p_attribute5             => p_txn_party_detail_rec.attribute5,
        p_attribute6             => p_txn_party_detail_rec.attribute6,
        p_attribute7             => p_txn_party_detail_rec.attribute7,
        p_attribute8             => p_txn_party_detail_rec.attribute8,
        p_attribute9             => p_txn_party_detail_rec.attribute9,
        p_attribute10            => p_txn_party_detail_rec.attribute10,
        p_attribute11            => p_txn_party_detail_rec.attribute11,
        p_attribute12            => p_txn_party_detail_rec.attribute12,
        p_attribute13            => p_txn_party_detail_rec.attribute13,
        p_attribute14            => p_txn_party_detail_rec.attribute14,
        p_attribute15            => p_txn_party_detail_rec.attribute15,
        p_created_by             => g_user_id,
        p_creation_date          => sysdate,
        p_last_updated_by        => g_user_id,
        p_last_update_date       => sysdate,
        p_last_update_login      => g_login_id,
        p_object_version_number  => 1.0,
        p_context                => p_txn_party_detail_rec.context,
        p_contact_party_id       => null,
        p_primary_flag           => p_txn_party_detail_rec.primary_flag,
        p_preferred_flag         => p_txn_party_detail_rec.preferred_flag);

--p_txn_party_detail_rec.contact_party_id);

    exception
      when others then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_party_details_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    end;

    p_txn_party_detail_rec.txn_party_detail_id := l_txn_party_detail_id;

    if px_txn_pty_acct_detail_tbl.COUNT > 0 then
      -- loop thru party account detail
      FOR l_index IN px_txn_pty_acct_detail_tbl.FIRST..px_txn_pty_acct_detail_tbl.LAST
      LOOP

        if px_txn_pty_acct_detail_tbl(l_index).txn_party_details_index =
           p_txn_party_dtl_index then
          -- assign values to the record type variable

          l_pty_acct_rec := px_txn_pty_acct_detail_tbl(l_index);
          l_pty_acct_rec.txn_party_detail_id    := l_txn_party_detail_id;

          -- call api to create txn_party_account details
          csi_t_txn_parties_pvt.create_txn_pty_acct_dtls(
            p_api_version             => p_api_version,
            p_commit                  => p_commit,
            p_init_msg_list           => p_init_msg_list,
            p_validation_level        => p_validation_level,
            p_txn_pty_acct_detail_rec => l_pty_acct_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            csi_t_gen_utility_pvt.add('Create txn party accounts failed.');
            RAISE fnd_api.g_exc_error;
          END IF;

          px_txn_pty_acct_detail_tbl(l_index).txn_party_detail_id :=
             l_pty_acct_rec.txn_party_detail_id;
          px_txn_pty_acct_detail_tbl(l_index).txn_account_detail_id :=
             l_pty_acct_rec.txn_account_detail_id;

        END IF;

      END LOOP;

    END IF;
    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      csi_t_gen_utility_pvt.set_debug_off;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END create_txn_party_dtls;


  PROCEDURE create_txn_pty_acct_dtls(
    p_api_version             IN     number,
    p_commit                  IN     varchar2 := fnd_api.g_false,
    p_init_msg_list           IN     varchar2 := fnd_api.g_false,
    p_validation_level        IN     number   := fnd_api.g_valid_level_full,
    p_txn_pty_acct_detail_rec IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_rec,
    x_return_status              OUT NOCOPY varchar2,
    x_msg_count                  OUT NOCOPY number,
    x_msg_data                   OUT NOCOPY varchar2)

  IS

    l_api_name          CONSTANT varchar2(30)  := 'create_txn_pty_acct_dtls';
    l_api_version       CONSTANT number        := 1.0;
    l_debug_level                number;
    l_txn_account_detail_id      number;
    l_pty_dtl_rec                csi_t_party_details%rowtype;

    l_preserve_detail_flag       varchar2(1);
    l_return_status              varchar2(1);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_pty_acct_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.compatible_api_call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 THEN
      csi_t_gen_utility_pvt.add(
        p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

      csi_t_gen_utility_pvt.dump_pty_acct_rec(
       p_pty_acct_rec => p_txn_pty_acct_detail_rec);
    END IF;

    -- Main API code

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_pty_acct_detail_rec.account_id,
      p_param_name => 'p_txn_pty_acct_detail_rec.account_id',
      p_api_name   => 'create_txn_pty_acct_dtls');

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_pty_acct_detail_rec.relationship_type_code,
      p_param_name => 'p_txn_pty_acct_detail_rec.relationship_type_code',
      p_api_name   => 'create_txn_pty_acct_dtls');

    -- validate account_id from hz_cust_accounts table
    csi_t_vldn_routines_pvt.validate_account_id(
      p_account_id    => p_txn_pty_acct_detail_rec.account_id,
      x_return_status => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN

      FND_MESSAGE.set_name('CSI','CSI_TXN_ACCOUNT_ID_INVALID');
      FND_MESSAGE.set_token('ACCT_ID',p_txn_pty_acct_detail_rec.account_id);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;

    END IF;

    -- validate relationship_type_code from cs_lookups table
    IF NOT
      csi_instance_parties_vld_pvt.is_pty_rel_type_valid(
        p_party_rel_type_code => p_txn_pty_acct_detail_rec.relationship_type_code,
        p_contact_flag        => 'A')
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    --##
    -- validate ip_acount_id from the csi_instance_party_account_table
    IF NVL(p_txn_pty_acct_detail_rec.ip_account_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      csi_t_vldn_routines_pvt.validate_ip_account_id(
        p_ip_account_id   => p_txn_pty_acct_detail_rec.ip_account_id,
        x_return_status   => l_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN

        FND_MESSAGE.set_name('CSI','CSI_API_INVALID_IP_ACCOUNT_ID');
        FND_MESSAGE.set_token('IP_ACCOUNT_ID',p_txn_pty_acct_detail_rec.ip_account_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    -- validate# the party account id
    csi_t_vldn_routines_pvt.get_party_detail_rec(
      p_party_detail_id  => p_txn_pty_acct_detail_rec.txn_party_detail_id,
      x_party_detail_rec => l_pty_dtl_rec,
      x_return_status    => l_return_status);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      -- raise error
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_vldn_routines_pvt.validate_party_account_id(
      p_party_id         => l_pty_dtl_rec.party_source_id,
      p_party_account_id => p_txn_pty_acct_detail_rec.account_id,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN

      FND_MESSAGE.set_name('CSI','CSI_TXN_PTY_ACCT_INVALID');
      FND_MESSAGE.set_token('PTY_ID',l_pty_dtl_rec.party_source_id);
      FND_MESSAGE.set_token('PTY_ACC_ID',p_txn_pty_acct_detail_rec.account_id);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;

    END IF;

    -- validate bill_to and ship_to address
    IF p_txn_pty_acct_detail_rec.bill_to_address_id <> fnd_api.g_miss_num THEN

      csi_t_vldn_routines_pvt.validate_site_use_id(
        p_account_id    => p_txn_pty_acct_detail_rec.account_id,
        p_site_use_id   => p_txn_pty_acct_detail_rec.bill_to_address_id,
        p_site_use_code => 'BILL_TO',
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
        FND_MESSAGE.set_token('SITE_USE_ID',p_txn_pty_acct_detail_rec.
                                              bill_to_address_id);
        FND_MESSAGE.set_token('SITE_USE_CODE','BILL_TO');
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_txn_pty_acct_detail_rec.ship_to_address_id <> fnd_api.g_miss_num THEN

      csi_t_vldn_routines_pvt.validate_site_use_id(
        p_account_id    => p_txn_pty_acct_detail_rec.account_id,
        p_site_use_id   => p_txn_pty_acct_detail_rec.ship_to_address_id,
        p_site_use_code => 'SHIP_TO',
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
        FND_MESSAGE.set_token('SITE_USE_ID',p_txn_pty_acct_detail_rec.
                                              ship_to_address_id);
        FND_MESSAGE.set_token('SITE_USE_CODE','SHIP_TO');
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    SELECT decode(nvl(p_txn_pty_acct_detail_rec.preserve_detail_flag,fnd_api.g_miss_char),
             fnd_api.g_miss_char, 'Y', p_txn_pty_acct_detail_rec.preserve_detail_flag)
    INTO   l_preserve_detail_flag
    FROM   sys.dual;

    -- call the table handler to insert row in to the database table
    IF nvl(p_txn_pty_acct_detail_rec.txn_account_detail_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_txn_account_detail_id := p_txn_pty_acct_detail_rec.txn_account_detail_id;
    END IF;

    begin
      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_party_accounts_pkg');

      csi_t_party_accounts_pkg.insert_row(
        px_txn_account_detail_id => l_txn_account_detail_id,
        p_txn_party_detail_id    => p_txn_pty_acct_detail_rec.txn_party_detail_id,
        p_ip_account_id          => p_txn_pty_acct_detail_rec.ip_account_id,
        p_account_id             => p_txn_pty_acct_detail_rec.account_id,
        p_relationship_type_code => p_txn_pty_acct_detail_rec.relationship_type_code,
        p_bill_to_address_id     => p_txn_pty_acct_detail_rec.bill_to_address_id,
        p_ship_to_address_id     => p_txn_pty_acct_detail_rec.ship_to_address_id,
        p_active_start_date      => p_txn_pty_acct_detail_rec.active_start_date,
        p_active_end_date        => p_txn_pty_acct_detail_rec.active_end_date,
        p_preserve_detail_flag   => l_preserve_detail_flag,
        p_attribute1             => p_txn_pty_acct_detail_rec.attribute1,
        p_attribute2             => p_txn_pty_acct_detail_rec.attribute2,
        p_attribute3             => p_txn_pty_acct_detail_rec.attribute3,
        p_attribute4             => p_txn_pty_acct_detail_rec.attribute4,
        p_attribute5             => p_txn_pty_acct_detail_rec.attribute5,
        p_attribute6             => p_txn_pty_acct_detail_rec.attribute6,
        p_attribute7             => p_txn_pty_acct_detail_rec.attribute7,
        p_attribute8             => p_txn_pty_acct_detail_rec.attribute8,
        p_attribute9             => p_txn_pty_acct_detail_rec.attribute9,
        p_attribute10            => p_txn_pty_acct_detail_rec.attribute10,
        p_attribute11            => p_txn_pty_acct_detail_rec.attribute11,
        p_attribute12            => p_txn_pty_acct_detail_rec.attribute12,
        p_attribute13            => p_txn_pty_acct_detail_rec.attribute13,
        p_attribute14            => p_txn_pty_acct_detail_rec.attribute14,
        p_attribute15            => p_txn_pty_acct_detail_rec.attribute15,
        p_created_by             => g_user_id,
        p_creation_date          => sysdate,
        p_last_updated_by        => g_user_id,
        p_last_update_date       => sysdate,
        p_last_update_login      => g_login_id,
        p_object_version_number  => 1.0,
        p_context                => p_txn_pty_acct_detail_rec.context);

    exception
      when others then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_party_accounts_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    end;

    p_txn_pty_acct_detail_rec.txn_account_detail_id := l_txn_account_detail_id;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.set_debug_off;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO Create_Txn_Pty_Acct_Dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Txn_Pty_Acct_Dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Create_Txn_Pty_Acct_Dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

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

  END create_txn_pty_acct_dtls;

  PROCEDURE update_txn_party_dtls(
    p_api_version          IN  NUMBER,
    p_commit               IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_party_detail_tbl IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_party_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_pty_rec                 csi_t_party_details%ROWTYPE;
    l_pty_acct_rec            csi_t_datastructures_grp.txn_pty_acct_detail_rec;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(512);
    l_processing_status       csi_t_transaction_lines.processing_status%TYPE;
    l_del_pa_ids_tbl          csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_del_pa_ind              binary_integer;
    l_instance_exists_flag    csi_t_txn_line_details.instance_exists_flag%TYPE;
    l_instance_id             csi_t_txn_line_details.instance_id%TYPE;
    l_contact_flag            varchar2(1) := 'P';
    l_u_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_acct_ind              binary_integer;

    CURSOR pty_cur(p_pty_dtl_id IN number) IS
      SELECT *
      FROM   csi_t_party_details
      WHERE  txn_party_detail_id = p_pty_dtl_id;

    CURSOR pa_cur(p_pty_dtl_id in number) IS
      SELECT *
      FROM   csi_t_party_accounts
      WHERE  txn_party_detail_id = p_pty_dtl_id;

    CURSOR cont_pty_cur(p_txn_party_detail_id in number) IS
      SELECT txn_party_detail_id, preserve_detail_flag
      FROM   csi_t_party_details
      WHERE  contact_party_id = p_txn_party_detail_id
      AND contact_flag = 'Y';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_party_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
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

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code

    IF p_txn_party_detail_tbl.COUNT > 0 THEN

      FOR l_ind IN p_txn_party_detail_tbl.FIRST .. p_txn_party_detail_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_party_detail_rec(
            p_party_detail_rec => p_txn_party_detail_tbl(l_ind));
        END IF;

        l_pty_rec.txn_party_detail_id    :=
          p_txn_party_detail_tbl(l_ind).txn_party_detail_id;

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value      => l_pty_rec.txn_party_detail_id,
          p_param_name => 'l_pty_rec.txn_party_detail_id',
          p_api_name   => l_api_name);

        -- validate txn_party_detail_id
        csi_t_vldn_routines_pvt.validate_txn_party_detail_id(
          p_txn_party_detail_id => l_pty_rec.txn_party_detail_id,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_PARTY_DTL_ID_INVALID');
          FND_MESSAGE.set_token('PTY_DTL_ID',l_pty_rec.txn_party_detail_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        FOR l_pty_cur_rec IN pty_cur (l_pty_rec.txn_party_detail_id)
        LOOP

          l_pty_rec.txn_line_detail_id     := l_pty_cur_rec.txn_line_detail_id;

          -- check the processing status

          csi_t_vldn_routines_pvt.get_processing_status(
            p_level             => 'PARTY',
            p_level_dtl_id      => l_pty_rec.txn_line_detail_id,
            x_processing_status => l_processing_status,
            x_return_status     => l_return_status);

          IF l_processing_status = 'PROCESSED' THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
            FND_MESSAGE.set_token('LVL_ID', l_pty_rec.txn_line_detail_id);
            FND_MESSAGE.set_token('STATUS',l_processing_status);
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          l_pty_rec.party_source_table     :=
            p_txn_party_detail_tbl(l_ind).party_source_table;

          IF l_pty_rec.party_source_table <> fnd_api.g_miss_char
          THEN

             -- validate party_source_table
            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value       => l_pty_rec.party_source_table,
              p_param_name  => 'l_pty_rec.party_source_table',
              p_api_name    => l_api_name);

             IF NOT
               csi_instance_parties_vld_pvt.is_pty_source_tab_valid(
                 p_party_source_table => l_pty_rec.party_source_table)
             THEN
               csi_t_gen_utility_pvt.add('Validate party source table failed.');
               RAISE fnd_api.g_exc_error;
             END IF;

          END IF;

          l_pty_rec.party_source_id        :=
            p_txn_party_detail_tbl(l_ind).party_source_id;

          l_pty_rec.contact_flag           :=
            p_txn_party_detail_tbl(l_ind).contact_flag;


          IF l_pty_rec.party_source_id <> fnd_api.g_miss_num THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value       => l_pty_rec.party_source_id,
              p_param_name  => 'l_pty_rec.party_source_id',
              p_api_name    => l_api_name);

              -- validate party_source_id
              IF NOT
               csi_instance_parties_vld_pvt.is_party_valid(
                 p_party_source_table => l_pty_rec.party_source_table,
                 p_party_id           => l_pty_rec.party_source_id,
                 p_contact_flag       => l_pty_rec.contact_flag)
              THEN
                csi_t_gen_utility_pvt.add('Validate party source table failed.');
                RAISE fnd_api.g_exc_error;
              END IF;
          END IF;

          l_pty_rec.instance_party_id      :=
            p_txn_party_detail_tbl(l_ind).instance_party_id;

          IF NVL(l_pty_rec.instance_party_id , fnd_api.g_miss_num) <>
             fnd_api.g_miss_num
          THEN

            --check if the instance_party_id is a valid dtl of
            --referenced instance id (from the txn_line_details)

            csi_t_vldn_routines_pvt.validate_instance_reference(
              p_level             => 'PARTY',
              p_level_dtl_id      => l_pty_rec.txn_line_detail_id,
              p_level_inst_ref_id => l_pty_rec.instance_party_id,
              x_return_status     => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              csi_t_gen_utility_pvt.add('Validate instance party id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_pty_rec.relationship_type_code :=
            p_txn_party_detail_tbl(l_ind).relationship_type_code;

          IF l_pty_rec.relationship_type_code <> fnd_api.g_miss_char THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_pty_rec.relationship_type_code,
              p_param_name => 'l_pty_rec.relationship_type_code',
              p_api_name   => l_api_name);

            IF l_pty_rec.contact_flag = 'Y' THEN
              l_contact_flag := 'C';
            ELSE
              l_contact_flag := 'P';
            END IF;

            --validate relationship_type_code
            IF NOT
              csi_instance_parties_vld_pvt.is_pty_rel_type_valid(
                p_party_rel_type_code => l_pty_rec.relationship_type_code,
                p_contact_flag        => l_contact_flag)
            THEN
              csi_t_gen_utility_pvt.add('Validate party relationship type code failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_pty_rec.active_start_date      :=
            p_txn_party_detail_tbl(l_ind).active_start_date;

          l_pty_rec.active_end_date        :=
            p_txn_party_detail_tbl(l_ind).active_end_date;

          l_pty_rec.preserve_detail_flag   :=
            p_txn_party_detail_tbl(l_ind).preserve_detail_flag;

          l_pty_rec.attribute1             :=
            p_txn_party_detail_tbl(l_ind).attribute1;

          l_pty_rec.attribute2             :=
            p_txn_party_detail_tbl(l_ind).attribute2;

          l_pty_rec.attribute3             :=
            p_txn_party_detail_tbl(l_ind).attribute3;

          l_pty_rec.attribute4             :=
            p_txn_party_detail_tbl(l_ind).attribute4;

          l_pty_rec.attribute5             :=
            p_txn_party_detail_tbl(l_ind).attribute5;

          l_pty_rec.attribute6             :=
            p_txn_party_detail_tbl(l_ind).attribute6;

          l_pty_rec.attribute7             :=
            p_txn_party_detail_tbl(l_ind).attribute7;

          l_pty_rec.attribute8             :=
            p_txn_party_detail_tbl(l_ind).attribute8;

          l_pty_rec.attribute9             :=
            p_txn_party_detail_tbl(l_ind).attribute9;

          l_pty_rec.attribute10            :=
            p_txn_party_detail_tbl(l_ind).attribute10;

          l_pty_rec.attribute11            :=
            p_txn_party_detail_tbl(l_ind).attribute11;

          l_pty_rec.attribute12            :=
            p_txn_party_detail_tbl(l_ind).attribute12;

          l_pty_rec.attribute13            :=
            p_txn_party_detail_tbl(l_ind).attribute13;

          l_pty_rec.attribute14            :=
            p_txn_party_detail_tbl(l_ind).attribute14;

          l_pty_rec.attribute15            :=
            p_txn_party_detail_tbl(l_ind).attribute15;

          l_pty_rec.created_by             := l_pty_cur_rec.created_by;
          l_pty_rec.creation_date          := l_pty_cur_rec.creation_date;
          l_pty_rec.last_updated_by        := g_user_id;
          l_pty_rec.last_update_date       := sysdate;
          l_pty_rec.last_update_login      := g_login_id;

          l_pty_rec.object_version_number  :=
            p_txn_party_detail_tbl(l_ind).object_version_number;

          l_pty_rec.context                :=
            p_txn_party_detail_tbl(l_ind).context;

          l_pty_rec.contact_party_id       :=
            p_txn_party_detail_tbl(l_ind).contact_party_id;

          l_pty_rec.primary_flag           :=
            p_txn_party_detail_tbl(l_ind).primary_flag;

          l_pty_rec.preferred_flag         :=
            p_txn_party_detail_tbl(l_ind).preferred_flag;


          IF (l_pty_rec.party_source_id <> l_pty_cur_rec.party_source_id) THEN

            --check for the existing party_accounts if found then see if
            --loop thru the pty accounts and identify the candidated for deletion

            l_del_pa_ind := 0;

            FOR l_pa_cur_rec in  pa_cur(l_pty_rec.txn_party_detail_id)
            LOOP

              /* see if the preserve detail flag is set for any of the child */
              IF nvl(l_pa_cur_rec.preserve_detail_flag,'N') = 'Y' THEN

                /* check if the account id is valid for the party */
                csi_t_vldn_routines_pvt.validate_party_account_id(
                  p_party_id         => l_pty_rec.party_source_id,
                  p_party_account_id => l_pa_cur_rec.account_id,
                  x_return_status    => l_return_status);

                /* if not valid then mark the record for deletion */
                IF l_return_status <> fnd_api.g_ret_sts_success THEN

                  l_del_pa_ind := l_del_pa_ind + 1;

                  l_del_pa_ids_tbl(l_del_pa_ind).txn_party_detail_id :=
                    l_pa_cur_rec.txn_party_detail_id;
                  l_del_pa_ids_tbl(l_del_pa_ind).txn_account_detail_id :=
                    l_pa_cur_rec.txn_account_detail_id;

                END IF;

              ELSE
                -- mark record for deletion (populate the ids table)
                l_del_pa_ind := l_del_pa_ind + 1;

                l_del_pa_ids_tbl(l_del_pa_ind).txn_party_detail_id :=
                  l_pa_cur_rec.txn_party_detail_id;
                l_del_pa_ids_tbl(l_del_pa_ind).txn_account_detail_id :=
                  l_pa_cur_rec.txn_account_detail_id;

              END IF;

            END LOOP;


            IF l_del_pa_ids_tbl.COUNT > 0 THEN
               --call the delete party accounts api

              csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
                p_api_version          => p_api_version,
                p_commit               => p_commit,
                p_init_msg_list        => p_init_msg_list,
                p_validation_level     => p_validation_level,
                p_txn_pty_acct_ids_tbl => l_del_pa_ids_tbl,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;

            -- Self bug - added during Mass update testing....
            --check for the existing party contacts if found then see if they need to, can be preserved
            -- If the vldn fails for the party contacts, then delete them too
            --loop thru the pty contacts and identify the candidated for deletion
            FOR cont_pty_rec in cont_pty_cur(l_pty_rec.txn_party_detail_id)
            LOOP
              IF nvl(cont_pty_rec.preserve_detail_flag,'N') = 'Y' THEN

                /* check if the contact is valid for the new party */
                -- currently we do not seem to validate the contacts in txn details for even normal creation
                -- at the time of fixing it, code needs to be added here too
                debug('Party Contact needs to be preserved : '||cont_pty_rec.txn_party_detail_id);
              ELSE
                   debug('Deleting the Party Contact,  must not be preserved : '||cont_pty_rec.txn_party_detail_id);
                    csi_t_gen_utility_pvt.dump_api_info(
                       p_api_name => 'delete_row',
                       p_pkg_name => 'csi_t_party_details_pkg');

                    csi_t_party_details_pkg.delete_row(
                       p_txn_party_detail_id   => cont_pty_rec.txn_party_detail_id);
              END IF;

            END LOOP;

          END IF;

          begin
            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_row',
              p_pkg_name => 'csi_t_party_details_pkg');

            csi_t_party_details_pkg.update_row(
              p_txn_party_detail_id    => l_pty_rec.txn_party_detail_id,
              p_txn_line_detail_id     => l_pty_rec.txn_line_detail_id,
              p_party_source_table     => l_pty_rec.party_source_table,
              p_party_source_id        => l_pty_rec.party_source_id,
              p_relationship_type_code => l_pty_rec.relationship_type_code,
              p_contact_flag           => l_pty_rec.contact_flag,
              p_active_start_date      => l_pty_rec.active_start_date,
              p_active_end_date        => l_pty_rec.active_end_date,
              p_preserve_detail_flag   => l_pty_rec.preserve_detail_flag,
              p_instance_party_id      => l_pty_rec.instance_party_id,
              p_attribute1             => l_pty_rec.attribute1,
              p_attribute2             => l_pty_rec.attribute2,
              p_attribute3             => l_pty_rec.attribute3,
              p_attribute4             => l_pty_rec.attribute4,
              p_attribute5             => l_pty_rec.attribute5,
              p_attribute6             => l_pty_rec.attribute6,
              p_attribute7             => l_pty_rec.attribute7,
              p_attribute8             => l_pty_rec.attribute8,
              p_attribute9             => l_pty_rec.attribute9,
              p_attribute10            => l_pty_rec.attribute10,
              p_attribute11            => l_pty_rec.attribute11,
              p_attribute12            => l_pty_rec.attribute12,
              p_attribute13            => l_pty_rec.attribute13,
              p_attribute14            => l_pty_rec.attribute14,
              p_attribute15            => l_pty_rec.attribute15,
              p_created_by             => l_pty_rec.created_by,
              p_creation_date          => l_pty_rec.creation_date,
              p_last_updated_by        => l_pty_rec.last_updated_by,
              p_last_update_date       => l_pty_rec.last_update_date,
              p_last_update_login      => l_pty_rec.last_update_login,
              p_object_version_number  => l_pty_rec.object_version_number,
              p_context                => l_pty_rec.context,
              p_contact_party_id       => l_pty_rec.contact_party_id,
              p_primary_flag           => l_pty_rec.primary_flag,
              p_preferred_flag         => l_pty_rec.preferred_flag);

          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_party_details_pkg.update_row Failed. '||substr(sqlerrm,1,200));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end;

        END LOOP;


        IF px_txn_pty_acct_detail_tbl.COUNT > 0 THEN
          l_u_acct_ind := 0;

          FOR l_pa_ind IN px_txn_pty_acct_detail_tbl.FIRST..
                          px_txn_pty_acct_detail_tbl.LAST
          LOOP
           -- Self-Bug, part of Mass update. Handle create Account within a party update...
            IF nvl(px_txn_pty_acct_detail_tbl(l_pa_ind).txn_account_detail_id,fnd_api.g_miss_num) <>
               fnd_api.g_miss_num THEN -- it is a update account

              -- Build the acct tbl to call it at the end...

              l_u_pty_acct_tbl(l_u_acct_ind).txn_account_detail_id  :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).txn_account_detail_id;

              l_u_pty_acct_tbl(l_u_acct_ind).txn_party_detail_id    :=
                l_pty_rec.txn_party_detail_id;

              l_u_pty_acct_tbl(l_u_acct_ind).ip_account_id          :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).ip_account_id;

              l_u_pty_acct_tbl(l_u_acct_ind).account_id             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).account_id;

              l_u_pty_acct_tbl(l_u_acct_ind).relationship_type_code :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).relationship_type_code;

              l_u_pty_acct_tbl(l_u_acct_ind).bill_to_address_id :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).bill_to_address_id;

              l_u_pty_acct_tbl(l_u_acct_ind).ship_to_address_id :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).ship_to_address_id;

              l_u_pty_acct_tbl(l_u_acct_ind).active_start_date      :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).active_start_date;

              l_u_pty_acct_tbl(l_u_acct_ind).active_end_date        :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).active_end_date;

              l_u_pty_acct_tbl(l_u_acct_ind).preserve_detail_flag   :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).preserve_detail_flag;

              l_u_pty_acct_tbl(l_u_acct_ind).context                :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).context;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute1             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute1;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute2             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute2;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute3             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute3;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute4             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute4;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute5             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute5;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute6             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute6;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute7             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute7;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute8             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute8;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute9             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute9;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute10            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute10;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute11            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute11;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute12            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute12;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute13            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute13;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute14            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute14;

              l_u_pty_acct_tbl(l_u_acct_ind).attribute15            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute15;

              l_u_pty_acct_tbl(l_u_acct_ind).txn_party_details_index :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).txn_party_details_index;

              l_u_pty_acct_tbl(l_u_acct_ind).object_version_number  :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).object_version_number;
              l_u_acct_ind := l_u_acct_ind + 1;

            ELSIF px_txn_pty_acct_detail_tbl(l_pa_ind).txn_party_detail_id =
                  l_pty_rec.txn_party_detail_id THEN

              --populate row type variable

              l_pty_acct_rec.txn_account_detail_id  :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).txn_account_detail_id;

              l_pty_acct_rec.txn_party_detail_id    :=
                l_pty_rec.txn_party_detail_id;

              l_pty_acct_rec.ip_account_id          :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).ip_account_id;

              l_pty_acct_rec.account_id             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).account_id;

              l_pty_acct_rec.relationship_type_code :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).relationship_type_code;

              l_pty_acct_rec.bill_to_address_id :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).bill_to_address_id;

              l_pty_acct_rec.ship_to_address_id :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).ship_to_address_id;

              l_pty_acct_rec.active_start_date      :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).active_start_date;

              l_pty_acct_rec.active_end_date        :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).active_end_date;

              l_pty_acct_rec.preserve_detail_flag   :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).preserve_detail_flag;

              l_pty_acct_rec.context                :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).context;

              l_pty_acct_rec.attribute1             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute1;

              l_pty_acct_rec.attribute2             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute2;

              l_pty_acct_rec.attribute3             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute3;

              l_pty_acct_rec.attribute4             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute4;

              l_pty_acct_rec.attribute5             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute5;

              l_pty_acct_rec.attribute6             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute6;

              l_pty_acct_rec.attribute7             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute7;

              l_pty_acct_rec.attribute8             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute8;

              l_pty_acct_rec.attribute9             :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute9;

              l_pty_acct_rec.attribute10            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute10;

              l_pty_acct_rec.attribute11            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute11;

              l_pty_acct_rec.attribute12            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute12;

              l_pty_acct_rec.attribute13            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute13;

              l_pty_acct_rec.attribute14            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute14;

              l_pty_acct_rec.attribute15            :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).attribute15;

              l_pty_acct_rec.txn_party_details_index :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).txn_party_details_index;

              l_pty_acct_rec.object_version_number  :=
                px_txn_pty_acct_detail_tbl(l_pa_ind).object_version_number;


              -- call create party_account private API
              csi_t_txn_parties_pvt.create_txn_pty_acct_dtls(
                p_api_version             => p_api_version,
                p_commit                  => p_commit,
                p_init_msg_list           => p_init_msg_list,
                p_validation_level        => p_validation_level,
                p_txn_pty_acct_detail_rec => l_pty_acct_rec,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;

          END LOOP;

          IF l_u_pty_acct_tbl.count > 0 THEN
              -- call update party_account private API
              csi_t_txn_parties_pvt.update_txn_pty_acct_dtls(
                p_api_version             => p_api_version,
                p_commit                  => p_commit,
                p_init_msg_list           => p_init_msg_list,
                p_validation_level        => p_validation_level,
                p_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

          END IF;
        END IF;

      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO update_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO update_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END update_txn_party_dtls;

  /*
  */
  PROCEDURE update_txn_pty_acct_dtls (
     p_api_version         IN  NUMBER
    ,p_commit              IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_detail_tbl IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status       OUT NOCOPY VARCHAR2
    ,x_msg_count           OUT NOCOPY NUMBER
    ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_pty_acct_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_processing_status       csi_t_transaction_lines.processing_status%TYPE;
    l_return_status           varchar2(1);
    l_pa_rec                  csi_t_party_accounts%rowtype;

    CURSOR pa_cur (p_acct_dtl_id in number) IS
      SELECT *
      FROM   csi_t_party_accounts
      where  txn_account_detail_id = p_acct_dtl_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_pty_acct_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
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

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code

    IF p_txn_pty_acct_detail_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_pty_acct_detail_tbl.FIRST ..
                   p_txn_pty_acct_detail_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_pty_acct_rec(
            p_pty_acct_rec => p_txn_pty_acct_detail_tbl(l_ind));
        END IF;

        l_pa_rec.txn_account_detail_id :=
          p_txn_pty_acct_detail_tbl(l_ind).txn_account_detail_id;

          csi_t_vldn_routines_pvt.check_reqd_param(
            p_value      => l_pa_rec.txn_account_detail_id,
            p_param_name => 'l_pa_rec.txn_account_detail_id',
            p_api_name   => l_api_name);

        -- validate party_detail_id
        csi_t_vldn_routines_pvt.validate_txn_acct_detail_id(
          p_txn_acct_detail_id => l_pa_rec.txn_account_detail_id,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_PARTY_ACCT_ID_INVALID');
          FND_MESSAGE.set_token('PTY_DTL_ID',l_pa_rec.txn_account_detail_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        FOR l_pa_cur_rec in pa_cur (l_pa_rec.txn_account_detail_id)
        LOOP

          l_pa_rec.txn_party_detail_id := l_pa_cur_rec.txn_party_detail_id;

          csi_t_vldn_routines_pvt.get_processing_status(
            p_level             => 'PARTY_ACCT',
            p_level_dtl_id      => l_pa_rec.txn_party_detail_id,
            x_processing_status => l_processing_status,
            x_return_status     => l_return_status);

          IF l_processing_status = 'PROCESSED' THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
            FND_MESSAGE.set_token('LVL_ID', l_pa_rec.txn_account_detail_id);
            FND_MESSAGE.set_token('STATUS',l_processing_status);
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          l_pa_rec.ip_account_id :=
            p_txn_pty_acct_detail_tbl(l_ind).ip_account_id;

          IF nvl(l_pa_rec.ip_account_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
          THEN

            --validate ip_account_id
            IF NOT csi_instance_parties_vld_pvt.is_ip_account_valid(
                     p_ip_account_id => l_pa_rec.ip_account_id) THEN
              RAISE fnd_api.g_exc_error;
              csi_t_gen_utility_pvt.add('Validate ip account id failed.');
            END IF;

          END IF;

          l_pa_rec.account_id :=
            p_txn_pty_acct_detail_tbl(l_ind).account_id;

          IF l_pa_rec.account_id <> fnd_api.g_miss_num THEN

            -- validate account_id from hz_cust_accounts table
            csi_t_vldn_routines_pvt.validate_account_id(
              p_account_id    => l_pa_rec.account_id,
              x_return_status => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN

              FND_MESSAGE.set_name('CSI','CSI_TXN_ACCOUNT_ID_INVALID');
              FND_MESSAGE.set_token('ACCT_ID',l_pa_rec.account_id);
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;

            END IF;

          END IF;

          l_pa_rec.relationship_type_code :=
            p_txn_pty_acct_detail_tbl(l_ind).relationship_type_code;

          IF l_pa_rec.relationship_type_code <> fnd_api.g_miss_char THEN
            -- validate relationship_type_code
            IF NOT
               csi_instance_parties_vld_pvt.is_pty_rel_type_valid(
                 p_party_rel_type_code => l_pa_rec.relationship_type_code,
                 p_contact_flag        => 'A')
            THEN
              csi_t_gen_utility_pvt.add('Validate party relationship type code failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_pa_rec.bill_to_address_id := p_txn_pty_acct_detail_tbl(l_ind).bill_to_address_id;
          l_pa_rec.ship_to_address_id := p_txn_pty_acct_detail_tbl(l_ind).ship_to_address_id;
          l_pa_rec.active_start_date  := p_txn_pty_acct_detail_tbl(l_ind).active_start_date;
          l_pa_rec.active_end_date    := p_txn_pty_acct_detail_tbl(l_ind).active_end_date;
          l_pa_rec.preserve_detail_flag := p_txn_pty_acct_detail_tbl(l_ind).preserve_detail_flag;
          l_pa_rec.attribute1 := p_txn_pty_acct_detail_tbl(l_ind).attribute1;
          l_pa_rec.attribute2 := p_txn_pty_acct_detail_tbl(l_ind).attribute2;
          l_pa_rec.attribute3 := p_txn_pty_acct_detail_tbl(l_ind).attribute3;
          l_pa_rec.attribute4 := p_txn_pty_acct_detail_tbl(l_ind).attribute4;
          l_pa_rec.attribute5 := p_txn_pty_acct_detail_tbl(l_ind).attribute5;
          l_pa_rec.attribute6 := p_txn_pty_acct_detail_tbl(l_ind).attribute6;
          l_pa_rec.attribute7 := p_txn_pty_acct_detail_tbl(l_ind).attribute7;
          l_pa_rec.attribute8 := p_txn_pty_acct_detail_tbl(l_ind).attribute8;
          l_pa_rec.attribute9 := p_txn_pty_acct_detail_tbl(l_ind).attribute9;
          l_pa_rec.attribute10 := p_txn_pty_acct_detail_tbl(l_ind).attribute10;
          l_pa_rec.attribute11 := p_txn_pty_acct_detail_tbl(l_ind).attribute11;
          l_pa_rec.attribute12 := p_txn_pty_acct_detail_tbl(l_ind).attribute12;
          l_pa_rec.attribute13 := p_txn_pty_acct_detail_tbl(l_ind).attribute13;
          l_pa_rec.attribute14 := p_txn_pty_acct_detail_tbl(l_ind).attribute14;
          l_pa_rec.attribute15 := p_txn_pty_acct_detail_tbl(l_ind).attribute15;
          l_pa_rec.created_by        := l_pa_cur_rec.created_by;
          l_pa_rec.creation_date     := l_pa_cur_rec.creation_date;
          l_pa_rec.last_updated_by   := g_user_id;
          l_pa_rec.last_update_date  := sysdate;
          l_pa_rec.last_update_login := g_login_id;

          l_pa_rec.object_version_number :=
            p_txn_pty_acct_detail_tbl(l_ind).object_version_number;

          l_pa_rec.context :=
            p_txn_pty_acct_detail_tbl(l_ind).context;

          begin

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_row',
              p_pkg_name => 'csi_t_party_details_pkg');

            csi_t_party_accounts_pkg.update_row (
              p_txn_account_detail_id     => l_pa_rec.txn_account_detail_id,
              p_txn_party_detail_id       => l_pa_rec.txn_party_detail_id,
              p_ip_account_id             => l_pa_rec.ip_account_id,
              p_account_id                => l_pa_rec.account_id,
              p_relationship_type_code    => l_pa_rec.relationship_type_code,
              p_bill_to_address_id        => l_pa_rec.bill_to_address_id,
              p_ship_to_address_id        => l_pa_rec.ship_to_address_id,
              p_active_start_date         => l_pa_rec.active_start_date,
              p_active_end_date           => l_pa_rec.active_end_date,
              p_preserve_detail_flag      => l_pa_rec.preserve_detail_flag,
              p_attribute1                => l_pa_rec.attribute1,
              p_attribute2                => l_pa_rec.attribute2,
              p_attribute3                => l_pa_rec.attribute3,
              p_attribute4                => l_pa_rec.attribute4,
              p_attribute5                => l_pa_rec.attribute5,
              p_attribute6                => l_pa_rec.attribute6,
              p_attribute7                => l_pa_rec.attribute7,
              p_attribute8                => l_pa_rec.attribute8,
              p_attribute9                => l_pa_rec.attribute9,
              p_attribute10               => l_pa_rec.attribute10,
              p_attribute11               => l_pa_rec.attribute11,
              p_attribute12               => l_pa_rec.attribute12,
              p_attribute13               => l_pa_rec.attribute13,
              p_attribute14               => l_pa_rec.attribute14,
              p_attribute15               => l_pa_rec.attribute15,
              p_created_by                => l_pa_rec.created_by,
              p_creation_date             => l_pa_rec.creation_date,
              p_last_updated_by           => l_pa_rec.last_updated_by,
              p_last_update_date          => l_pa_rec.last_update_date,
              p_last_update_login         => l_pa_rec.last_update_login,
              p_object_version_number     => l_pa_rec.object_version_number,
              p_context                   => l_pa_rec.context);

          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_party_accounts_pkg.update_row Failed. '||substr(sqlerrm,1,200));
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
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO update_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN


      ROLLBACK TO update_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
  END update_txn_pty_acct_dtls;

  PROCEDURE delete_txn_party_dtls(
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_ids_tbl    IN  csi_t_datastructures_grp.txn_party_ids_tbl
    ,x_txn_pty_acct_ids_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_party_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_line_dtl_id             NUMBER;
    l_pty_dtl_id              NUMBER;
    l_pty_acc_ind             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

    CURSOR pty_acc_cur(p_txn_party_detail_id in number) IS
      SELECT txn_account_detail_id
      FROM   csi_t_party_accounts
      WHERE  txn_party_detail_id = p_txn_party_detail_id;

    CURSOR pty_cur (p_line_dtl_id IN NUMBER) IS
      SELECT txn_party_detail_id
      FROM   csi_t_party_details
      WHERE  txn_line_detail_id = p_line_dtl_id;

    CURSOR cont_pty_cur(p_txn_party_detail_id in number) IS
      SELECT txn_party_detail_id
      FROM   csi_t_party_details
      WHERE  contact_party_id = p_txn_party_detail_id
      AND contact_flag = 'Y';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_party_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
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

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

    END IF;

    l_pty_acc_ind := 0;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_party_ids_tbl.COUNT > 0 THEN

      FOR l_ind IN p_txn_party_ids_tbl.FIRST..p_txn_party_ids_tbl.LAST
      LOOP

        l_pty_dtl_id := p_txn_party_ids_tbl(l_ind).txn_party_detail_id;

        IF nvl(l_pty_dtl_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          -- validate the transaction party detail ID
          csi_t_vldn_routines_pvt.validate_txn_party_detail_id(
            p_txn_party_detail_id => l_pty_dtl_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_PARTY_DTL_ID_INVALID');
            FND_MESSAGE.set_token('PTY_DTL_ID',l_pty_dtl_id);
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          -- populate the party account table
          FOR pty_acc_rec in pty_acc_cur(l_pty_dtl_id)
          LOOP

            l_pty_acc_ind := l_pty_acc_ind + 1;

            x_txn_pty_acct_ids_tbl(l_pty_acc_ind).txn_party_detail_id
                  := l_pty_dtl_id;
            x_txn_pty_acct_ids_tbl(l_pty_acc_ind).txn_account_detail_id
                  := pty_acc_rec.txn_account_detail_id;

          END LOOP;

          csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
            p_api_version          => p_api_version,
            p_commit               => p_commit,
            p_init_msg_list        => p_init_msg_list,
            p_validation_level     => p_validation_level,
            p_txn_pty_acct_ids_tbl => x_txn_pty_acct_ids_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE fnd_api.g_exc_error;
          END IF;

       -- If the party deleted has contacts, delete them too
          FOR cont_pty_rec in cont_pty_cur(l_pty_dtl_id)
          LOOP

             debug('Deleting Party Contact rec: '||cont_pty_rec.txn_party_detail_id);
             csi_t_gen_utility_pvt.dump_api_info(
                p_api_name => 'delete_row',
                p_pkg_name => 'csi_t_party_details_pkg');

              csi_t_party_details_pkg.delete_row(
                p_txn_party_detail_id   => cont_pty_rec.txn_party_detail_id);

          END LOOP;

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'delete_row',
            p_pkg_name => 'csi_t_party_details_pkg');

          csi_t_party_details_pkg.delete_row(
            p_txn_party_detail_id   => l_pty_dtl_id);

        ELSE

          l_line_dtl_id := p_txn_party_ids_tbl(l_ind).txn_line_detail_id;

          csi_t_vldn_routines_pvt.check_reqd_param(
            p_value      => l_line_dtl_id,
            p_param_name => 'p_txn_party_ids_tbl.txn_line_detail_id',
            p_api_name   => l_api_name);

          -- validate txn_line_detail_id
          csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
            p_txn_line_detail_id => l_line_dtl_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

             FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_DTL_ID_INVALID');
             FND_MESSAGE.set_token('LINE_DTL_ID',l_line_dtl_id);
             FND_MSG_PUB.add;
             RAISE fnd_api.g_exc_error;

          END IF;

          FOR pty_rec in pty_cur (l_line_dtl_id)
          LOOP

            l_pty_dtl_id := pty_rec.txn_party_detail_id;

            FOR pty_acc_rec in pty_acc_cur(l_pty_dtl_id)
            LOOP

              l_pty_acc_ind := l_pty_acc_ind + 1;

              x_txn_pty_acct_ids_tbl(l_pty_acc_ind).txn_party_detail_id
                    := l_pty_dtl_id;
              x_txn_pty_acct_ids_tbl(l_pty_acc_ind).txn_account_detail_id
                    := pty_acc_rec.txn_account_detail_id;

            END LOOP;

            csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
              p_api_version          => p_api_version,
              p_commit               => p_commit,
              p_init_msg_list        => p_init_msg_list,
              p_validation_level     => p_validation_level,
              p_txn_pty_acct_ids_tbl => x_txn_pty_acct_ids_tbl,
              x_return_status        => l_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
            END IF;
            -- If the party deleted has contacts, delete them too
              FOR cont_pty_rec in cont_pty_cur(l_pty_dtl_id)
              LOOP

                 debug('Deleting Party Contact rec: '||cont_pty_rec.txn_party_detail_id);
                 csi_t_gen_utility_pvt.dump_api_info(
                    p_api_name => 'delete_row',
                    p_pkg_name => 'csi_t_party_details_pkg');

                  csi_t_party_details_pkg.delete_row(
                    p_txn_party_detail_id   => cont_pty_rec.txn_party_detail_id);

              END LOOP;

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'delete_row',
              p_pkg_name => 'csi_t_party_details_pkg');

            csi_t_party_details_pkg.delete_row(
              p_txn_party_detail_id => l_pty_dtl_id);

          END LOOP;
        END IF;
      END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_party_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_party_dtls;

  /* deletes the party accounts based on the ids passed */
  PROCEDURE delete_txn_pty_acct_dtls(
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_ids_tbl IN  csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_pty_acct_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_return_status           VARCHAR2(1);

    l_acct_dtl_id             NUMBER;
    l_pty_dtl_id              NUMBER;

    CURSOR pty_acc_cur (p_pty_dtl_id IN NUMBER) IS
      SELECT txn_account_detail_id
      FROM   csi_t_party_accounts
      WHERE  txn_party_detail_id = p_pty_dtl_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_pty_acct_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
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

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_pty_acct_ids_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_pty_acct_ids_tbl.FIRST ..
                   p_txn_pty_acct_ids_tbl.LAST
      LOOP

        l_acct_dtl_id := p_txn_pty_acct_ids_tbl(l_ind).txn_account_detail_id;

        IF nvl(l_acct_dtl_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          csi_t_vldn_routines_pvt.validate_txn_acct_detail_id(
            p_txn_acct_detail_id => l_acct_dtl_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_PARTY_ACCT_ID_INVALID');
            FND_MESSAGE.set_token('PTY_ACCT_ID',l_acct_dtl_id);
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'delete_row',
            p_pkg_name => 'csi_t_party_accounts_pkg');

          csi_t_party_accounts_pkg.delete_row(
            p_txn_account_detail_id => l_acct_dtl_id);

        ELSE

          l_pty_dtl_id := p_txn_pty_acct_ids_tbl(l_ind).txn_party_detail_id;

          -- validate txn_party_detail_id
          csi_t_vldn_routines_pvt.validate_txn_party_detail_id(
            p_txn_party_detail_id => l_pty_dtl_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

             FND_MESSAGE.set_name('CSI','CSI_TXN_PARTY_DTL_ID_INVALID');
             FND_MESSAGE.set_token('PTY_DTL_ID',l_pty_dtl_id);
             FND_MSG_PUB.add;
             RAISE fnd_api.g_exc_error;

          END IF;

          FOR pty_acc_rec in pty_acc_cur (l_pty_dtl_id)
          LOOP

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'delete_row',
              p_pkg_name => 'csi_t_party_accounts_pkg');

            csi_t_party_accounts_pkg.delete_row(
              p_txn_account_detail_id => pty_acc_rec.txn_account_detail_id);

          END LOOP;

        END IF;

      END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_pty_acct_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_pty_acct_dtls;

  PROCEDURE get_pty_acct_dtls(
    p_party_dtl_id        in  number,
    x_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_pty_acct_cur_id  integer;
    l_pty_acct_rec     csi_t_datastructures_grp.txn_pty_acct_detail_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_pty_acct_dtls');

    l_select_stmt :=
     'select txn_account_detail_id, txn_party_detail_id, ip_account_id, '||
     ' account_id, relationship_type_code, bill_to_address_id, ship_to_address_id, '||
     ' active_start_date, active_end_date, preserve_detail_flag, context, '||
     ' attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, '||
     ' attribute7, attribute8, attribute9, attribute10, attribute11, attribute12, '||
     ' attribute13, attribute14, attribute15, object_version_number '||
     'from   csi_t_party_accounts '||
     'where txn_party_detail_id = :party_dtl_id';

    l_pty_acct_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_pty_acct_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_pty_acct_cur_id, 'party_dtl_id', p_party_dtl_id);

    dbms_sql.define_column(l_pty_acct_cur_id,1,
         l_pty_acct_rec.txn_account_detail_id);
    dbms_sql.define_column(l_pty_acct_cur_id,2,
         l_pty_acct_rec.txn_party_detail_id);
    dbms_sql.define_column(l_pty_acct_cur_id,3,
         l_pty_acct_rec.ip_account_id);
    dbms_sql.define_column(l_pty_acct_cur_id,4,
         l_pty_acct_rec.account_id);
    dbms_sql.define_column(l_pty_acct_cur_id,5,
         l_pty_acct_rec.relationship_type_code,30);
    dbms_sql.define_column(l_pty_acct_cur_id,6,
         l_pty_acct_rec.bill_to_address_id);
    dbms_sql.define_column(l_pty_acct_cur_id,7,
         l_pty_acct_rec.ship_to_address_id);
    dbms_sql.define_column(l_pty_acct_cur_id,8,
         l_pty_acct_rec.active_start_date);
    dbms_sql.define_column(l_pty_acct_cur_id,9,
         l_pty_acct_rec.active_end_date);
    dbms_sql.define_column(l_pty_acct_cur_id,10,
         l_pty_acct_rec.preserve_detail_flag, 1);
    dbms_sql.define_column(l_pty_acct_cur_id,11,
         l_pty_acct_rec.context,30);
    dbms_sql.define_column(l_pty_acct_cur_id,12,
         l_pty_acct_rec.attribute1,150);
    dbms_sql.define_column(l_pty_acct_cur_id,13,
         l_pty_acct_rec.attribute2,150);
    dbms_sql.define_column(l_pty_acct_cur_id,14,
         l_pty_acct_rec.attribute3,150);
    dbms_sql.define_column(l_pty_acct_cur_id,15,
         l_pty_acct_rec.attribute4,150);
    dbms_sql.define_column(l_pty_acct_cur_id,16,
         l_pty_acct_rec.attribute5,150);
    dbms_sql.define_column(l_pty_acct_cur_id,17,
         l_pty_acct_rec.attribute6,150);
    dbms_sql.define_column(l_pty_acct_cur_id,18,
         l_pty_acct_rec.attribute7,150);
    dbms_sql.define_column(l_pty_acct_cur_id,19,
         l_pty_acct_rec.attribute8,150);
    dbms_sql.define_column(l_pty_acct_cur_id,20,
         l_pty_acct_rec.attribute9,150);
    dbms_sql.define_column(l_pty_acct_cur_id,21,
         l_pty_acct_rec.attribute10,150);
    dbms_sql.define_column(l_pty_acct_cur_id,22,
         l_pty_acct_rec.attribute11,150);
    dbms_sql.define_column(l_pty_acct_cur_id,23,
         l_pty_acct_rec.attribute12,150);
    dbms_sql.define_column(l_pty_acct_cur_id,24,
         l_pty_acct_rec.attribute13,150);
    dbms_sql.define_column(l_pty_acct_cur_id,25,
         l_pty_acct_rec.attribute14,150);
    dbms_sql.define_column(l_pty_acct_cur_id,26,
         l_pty_acct_rec.attribute15,150);
    dbms_sql.define_column(l_pty_acct_cur_id,27,
         l_pty_acct_rec.object_version_number);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_pty_acct_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_pty_acct_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_pty_acct_cur_id,1,
         x_pty_acct_detail_tbl(l_ind).txn_account_detail_id);
      dbms_sql.column_value(l_pty_acct_cur_id,2,
         x_pty_acct_detail_tbl(l_ind).txn_party_detail_id);
      dbms_sql.column_value(l_pty_acct_cur_id,3,
         x_pty_acct_detail_tbl(l_ind).ip_account_id);
      dbms_sql.column_value(l_pty_acct_cur_id,4,
         x_pty_acct_detail_tbl(l_ind).account_id);
      dbms_sql.column_value(l_pty_acct_cur_id,5,
         x_pty_acct_detail_tbl(l_ind).relationship_type_code);
      dbms_sql.column_value(l_pty_acct_cur_id,6,
         x_pty_acct_detail_tbl(l_ind).bill_to_address_id);
      dbms_sql.column_value(l_pty_acct_cur_id,7,
         x_pty_acct_detail_tbl(l_ind).ship_to_address_id);
      dbms_sql.column_value(l_pty_acct_cur_id,8,
         x_pty_acct_detail_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_pty_acct_cur_id,9,
         x_pty_acct_detail_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_pty_acct_cur_id,10,
         x_pty_acct_detail_tbl(l_ind).preserve_detail_flag);
      dbms_sql.column_value(l_pty_acct_cur_id,11,
         x_pty_acct_detail_tbl(l_ind).context);
      dbms_sql.column_value(l_pty_acct_cur_id,12,
         x_pty_acct_detail_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_pty_acct_cur_id,13,
         x_pty_acct_detail_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_pty_acct_cur_id,14,
         x_pty_acct_detail_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_pty_acct_cur_id,15,
         x_pty_acct_detail_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_pty_acct_cur_id,16,
         x_pty_acct_detail_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_pty_acct_cur_id,17,
         x_pty_acct_detail_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_pty_acct_cur_id,18,
         x_pty_acct_detail_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_pty_acct_cur_id,19,
         x_pty_acct_detail_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_pty_acct_cur_id,20,
         x_pty_acct_detail_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_pty_acct_cur_id,21,
         x_pty_acct_detail_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_pty_acct_cur_id,22,
         x_pty_acct_detail_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_pty_acct_cur_id,23,
         x_pty_acct_detail_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_pty_acct_cur_id,24,
         x_pty_acct_detail_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_pty_acct_cur_id,25,
         x_pty_acct_detail_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_pty_acct_cur_id,26,
         x_pty_acct_detail_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_pty_acct_cur_id,27,
         x_pty_acct_detail_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_pty_acct_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_pty_acct_cur_id) THEN
       dbms_sql.close_cursor(l_pty_acct_cur_id);
     END IF;
  END get_pty_acct_dtls;

  PROCEDURE get_party_dtls(
    p_line_dtl_id      in  number,
    x_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_pty_cur_id       integer;
    l_pty_rec          csi_t_datastructures_grp.txn_party_detail_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_party_dtls');

    l_select_stmt :=
     'select txn_party_detail_id, txn_line_detail_id, instance_party_id, '||
     ' party_source_table, party_source_id, relationship_type_code, contact_flag, '||
     ' contact_party_id, active_start_date, active_end_date, preserve_detail_flag, '||
     ' context, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, '||
     ' attribute7, attribute8, attribute9, attribute10, attribute11, attribute12, '||
     ' attribute13, attribute14, attribute15, object_version_number, '||
     ' primary_flag, preferred_flag '||
     'from  csi_t_party_details '||
     'where txn_line_detail_id = :line_dtl_id';

    l_pty_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_pty_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_pty_cur_id, 'line_dtl_id', p_line_dtl_id);

    dbms_sql.define_column(l_pty_cur_id,1,l_pty_rec.txn_party_detail_id);
    dbms_sql.define_column(l_pty_cur_id,2,l_pty_rec.txn_line_detail_id);
    dbms_sql.define_column(l_pty_cur_id,3,l_pty_rec.instance_party_id);
    dbms_sql.define_column(l_pty_cur_id,4,l_pty_rec.party_source_table,30);
    dbms_sql.define_column(l_pty_cur_id,5,l_pty_rec.party_source_id);
    dbms_sql.define_column(l_pty_cur_id,6,l_pty_rec.relationship_type_code,30);
    dbms_sql.define_column(l_pty_cur_id,7,l_pty_rec.contact_flag,1);
    dbms_sql.define_column(l_pty_cur_id,8,l_pty_rec.contact_party_id);
    dbms_sql.define_column(l_pty_cur_id,9,l_pty_rec.active_start_date);
    dbms_sql.define_column(l_pty_cur_id,10,l_pty_rec.active_end_date);
    dbms_sql.define_column(l_pty_cur_id,11,l_pty_rec.preserve_detail_flag,1);
    dbms_sql.define_column(l_pty_cur_id,12,l_pty_rec.context,30);
    dbms_sql.define_column(l_pty_cur_id,13,l_pty_rec.attribute1,150);
    dbms_sql.define_column(l_pty_cur_id,14,l_pty_rec.attribute2,150);
    dbms_sql.define_column(l_pty_cur_id,15,l_pty_rec.attribute3,150);
    dbms_sql.define_column(l_pty_cur_id,16,l_pty_rec.attribute4,150);
    dbms_sql.define_column(l_pty_cur_id,17,l_pty_rec.attribute5,150);
    dbms_sql.define_column(l_pty_cur_id,18,l_pty_rec.attribute6,150);
    dbms_sql.define_column(l_pty_cur_id,19,l_pty_rec.attribute7,150);
    dbms_sql.define_column(l_pty_cur_id,20,l_pty_rec.attribute8,150);
    dbms_sql.define_column(l_pty_cur_id,21,l_pty_rec.attribute9,150);
    dbms_sql.define_column(l_pty_cur_id,22,l_pty_rec.attribute10,150);
    dbms_sql.define_column(l_pty_cur_id,23,l_pty_rec.attribute11,150);
    dbms_sql.define_column(l_pty_cur_id,24,l_pty_rec.attribute12,150);
    dbms_sql.define_column(l_pty_cur_id,25,l_pty_rec.attribute13,150);
    dbms_sql.define_column(l_pty_cur_id,26,l_pty_rec.attribute14,150);
    dbms_sql.define_column(l_pty_cur_id,27,l_pty_rec.attribute15,150);
    dbms_sql.define_column(l_pty_cur_id,28,l_pty_rec.object_version_number);
    dbms_sql.define_column(l_pty_cur_id,29,l_pty_rec.primary_flag,1);
    dbms_sql.define_column(l_pty_cur_id,30,l_pty_rec.preferred_flag,1);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_pty_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_pty_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_pty_cur_id,1, x_party_detail_tbl(l_ind).txn_party_detail_id);
      dbms_sql.column_value(l_pty_cur_id,2, x_party_detail_tbl(l_ind).txn_line_detail_id);
      dbms_sql.column_value(l_pty_cur_id,3, x_party_detail_tbl(l_ind).instance_party_id);
      dbms_sql.column_value(l_pty_cur_id,4, x_party_detail_tbl(l_ind).party_source_table);
      dbms_sql.column_value(l_pty_cur_id,5, x_party_detail_tbl(l_ind).party_source_id);
      dbms_sql.column_value(l_pty_cur_id,6, x_party_detail_tbl(l_ind).relationship_type_code);
      dbms_sql.column_value(l_pty_cur_id,7, x_party_detail_tbl(l_ind).contact_flag);
      dbms_sql.column_value(l_pty_cur_id,8, x_party_detail_tbl(l_ind).contact_party_id);
      dbms_sql.column_value(l_pty_cur_id,9, x_party_detail_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_pty_cur_id,10, x_party_detail_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_pty_cur_id,11, x_party_detail_tbl(l_ind).preserve_detail_flag);
      dbms_sql.column_value(l_pty_cur_id,12, x_party_detail_tbl(l_ind).context);
      dbms_sql.column_value(l_pty_cur_id,13, x_party_detail_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_pty_cur_id,14, x_party_detail_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_pty_cur_id,15, x_party_detail_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_pty_cur_id,16, x_party_detail_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_pty_cur_id,17, x_party_detail_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_pty_cur_id,18, x_party_detail_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_pty_cur_id,19, x_party_detail_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_pty_cur_id,20, x_party_detail_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_pty_cur_id,21, x_party_detail_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_pty_cur_id,22, x_party_detail_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_pty_cur_id,23, x_party_detail_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_pty_cur_id,24, x_party_detail_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_pty_cur_id,25, x_party_detail_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_pty_cur_id,26, x_party_detail_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_pty_cur_id,27, x_party_detail_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_pty_cur_id,28, x_party_detail_tbl(l_ind).object_version_number);
      dbms_sql.column_value(l_pty_cur_id,29, x_party_detail_tbl(l_ind).primary_flag);
      dbms_sql.column_value(l_pty_cur_id,30, x_party_detail_tbl(l_ind).preferred_flag);

    END LOOP;

    dbms_sql.close_cursor(l_pty_cur_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF dbms_sql.is_open(l_pty_cur_id) THEN
        dbms_sql.close_cursor(l_pty_cur_id);
      END IF;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm, 1, 255));
      fnd_msg_pub.add;

      IF dbms_sql.is_open(l_pty_cur_id) THEN
        dbms_sql.close_cursor(l_pty_cur_id);
      END IF;
  END get_party_dtls;

  PROCEDURE get_all_party_dtls(
    p_line_detail_tbl  in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS
    l_party_detail_tbl     csi_t_datastructures_grp.txn_party_detail_tbl;
    l_tmp_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_p_ind                binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_line_detail_tbl.count > 0 THEN

      FOR l_ind in p_line_detail_tbl.FIRST .. p_line_detail_tbl.LAST
      LOOP

        l_tmp_party_detail_tbl.delete;
        get_party_dtls(
          p_line_dtl_id      => p_line_detail_tbl(l_ind).txn_line_detail_id,
          x_party_detail_tbl => l_tmp_party_detail_tbl,
          x_return_status    => l_return_status);

        IF l_tmp_party_detail_tbl.COUNT > 0 THEN
          FOR l_t_ind IN l_tmp_party_detail_tbl.FIRST .. l_tmp_party_detail_tbl.LAST
          LOOP
            l_p_ind := l_party_detail_tbl.count + 1;
            l_party_detail_tbl(l_p_ind) := l_tmp_party_detail_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;
    x_party_detail_tbl := l_party_detail_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_party_dtls;

  PROCEDURE get_all_pty_acct_dtls(
    p_party_detail_tbl    in  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_pa_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_tmp_pa_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_pa_ind        binary_integer := 0;
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    IF p_party_detail_tbl.count > 0 THEN
      FOR l_ind IN p_party_detail_tbl.FIRST .. p_party_detail_tbl.LAST
      LOOP

        l_tmp_pa_tbl.delete;

        get_pty_acct_dtls(
          p_party_dtl_id        => p_party_detail_tbl(l_ind).txn_party_detail_id,
          x_pty_acct_detail_tbl => l_tmp_pa_tbl,
          x_return_status       => l_return_status);

        IF l_tmp_pa_tbl.count > 0 THEN
          FOR l_t_ind IN l_tmp_pa_tbl.FIRST .. l_tmp_pa_tbl.LAST
          LOOP
            l_pa_ind := l_pa_tbl.count + 1;
            l_pa_tbl(l_pa_ind) := l_tmp_pa_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;

    END IF;
    x_pty_acct_detail_tbl := l_pa_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_pty_acct_dtls;

END csi_t_txn_parties_pvt;

/
