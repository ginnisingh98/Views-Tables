--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_PARTIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_PARTIES_GRP" as
/*$Header: csigtpab.pls 120.2 2006/01/04 17:55:21 shegde noship $*/

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_parties_grp';
  g_file_name   CONSTANT VARCHAR2(12) := 'csigtpab.pls';

  g_user_id              NUMBER := FND_GLOBAL.User_Id;
  g_login_id             NUMBER := FND_GLOBAL.Login_Id;


  PROCEDURE create_txn_party_dtls(
    p_api_version        IN  NUMBER,
    p_commit             IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level   IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_party_detail_tbl IN  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)

  IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'create_txn_party_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

    l_txn_party_rec       csi_t_datastructures_grp.txn_party_detail_rec;
    l_txn_party_accts_tbl csi_t_datastructures_grp.txn_pty_acct_detail_tbl;

    l_count                        NUMBER;
    --contact party id variables
    l_tmp_party_dtl_tbl      csi_t_datastructures_grp.txn_party_detail_tbl;
    l_contact_party_id       number;
    l_contact_party_index    varchar2(1);
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_party_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Create Txn Party AND Accounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code starts here
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    IF px_txn_party_detail_tbl.count > 0 THEN

      -- new attribute, R12 Mass Update API call, due to the API call from EO, UI is unable to correctly identify
      -- and collect and pass the correct indexes.. need a additional attribute for update_transaction_dtls
      -- first loop through and identify this new attribute is passed by caller or not...
      l_contact_party_index := 'N';
      FOR l_ind in px_txn_party_detail_tbl.FIRST..px_txn_party_detail_tbl.LAST
      LOOP

        IF l_contact_party_index = 'N' THEN
          IF nvl(px_txn_party_detail_tbl(l_ind).txn_contact_party_index, fnd_api.g_miss_num) <>
             fnd_api.g_miss_num
          THEN
              l_contact_party_index := 'Y';
          END IF;
        END IF;
        --initialize row variable
        l_txn_party_rec := px_txn_party_detail_tbl(l_ind);
        l_txn_party_accts_tbl := px_txn_pty_acct_detail_tbl; -- added for self - bug
        -- call api to create party detail records
        csi_t_txn_parties_pvt.create_txn_party_dtls(
          p_api_version          => p_api_version,
          p_commit               => p_commit,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
--          p_txn_party_dtl_index  => fnd_api.g_miss_num,
          p_txn_party_dtl_index  => l_ind, -- added for self bug
          p_txn_party_detail_rec    => l_txn_party_rec,
          px_txn_pty_acct_detail_tbl => l_txn_party_accts_tbl,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        px_txn_party_detail_tbl(l_ind)  := l_txn_party_rec;
      END LOOP;

      l_tmp_party_dtl_tbl := px_txn_party_detail_tbl;
      px_txn_pty_acct_detail_tbl := l_txn_party_accts_tbl;

      /* process the contact party id */
      FOR cont_ind IN px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST
      LOOP
        IF nvl(px_txn_party_detail_tbl(cont_ind).contact_party_id, fnd_api.g_miss_num) <>
           fnd_api.g_miss_num AND nvl(px_txn_party_detail_tbl(cont_ind).contact_flag, 'N') = 'Y'
        THEN
           IF nvl(l_contact_party_index, 'N') = 'Y' THEN
             l_contact_party_id := null;
             FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
             LOOP
                IF ( l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index is not null
                   AND l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index <>  fnd_api.g_miss_num )
                THEN
                   IF l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index = px_txn_party_detail_tbl(cont_ind).contact_party_id
                     AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                          OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N')
                   THEN
                       l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                       exit;
                   END IF;
                ELSIF l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id = px_txn_party_detail_tbl(cont_ind).contact_party_id
                     AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                          OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N')
                THEN
                    l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                    exit;
                END IF;
              END LOOP;
           ELSE
              l_contact_party_id := null;
              FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
              LOOP
                IF p_ind = px_txn_party_detail_tbl(cont_ind).contact_party_id
                  AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                       OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N' )
                THEN
                   l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                   exit;
                ELSIF l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id = px_txn_party_detail_tbl(cont_ind).contact_party_id
                  AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                       OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N' )
                THEN
                     l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                     exit;
                END IF;
              END LOOP;
           END IF;

           IF l_contact_party_id is not null THEN
               update csi_t_party_details
               set    contact_party_id    = l_contact_party_id
               where  txn_party_detail_id = px_txn_party_detail_tbl(cont_ind).txn_party_detail_id;
           END IF;

        END IF;
      END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Create Txn Party And Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_party_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_txn_party_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_party_dtls;
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

  END create_txn_party_dtls;

  PROCEDURE create_txn_pty_acct_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_pty_acct_detail_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'create_txn_pty_acct_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

    l_count                        NUMBER;
    l_pty_acct_rec  csi_t_datastructures_grp.txn_pty_acct_detail_rec;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_pty_acct_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Create Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code starts here
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    IF px_txn_pty_acct_detail_tbl.count > 0 THEN

      FOR l_ind IN px_txn_pty_acct_detail_tbl.FIRST..
                   px_txn_pty_acct_detail_tbl.LAST
      LOOP

        -- assign values to the record type variable

        l_pty_acct_rec := px_txn_pty_acct_detail_tbl(l_ind);

        -- call api to create txn_party_account details
        csi_t_txn_parties_pvt.create_txn_pty_acct_dtls(
          p_api_version         => p_api_version,
          p_commit              => p_commit,
          p_init_msg_list       => p_init_msg_list,
          p_validation_level    => p_validation_level,
          p_txn_pty_acct_detail_rec => l_pty_acct_rec,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

      END LOOP;

    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Create Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_pty_acct_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_txn_pty_acct_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_pty_acct_dtls;
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

  END create_txn_pty_acct_dtls;

  PROCEDURE update_txn_party_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_detail_tbl   IN  csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2)

  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'Update_Txn_Party_Dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Txn_Party_Dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Update Txn Party And Accounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_parties_pvt.update_txn_party_dtls(
     p_api_version              => p_api_version,
     p_commit                   => fnd_api.g_false,
     p_init_msg_list            => p_init_msg_list,
     p_validation_level         => p_validation_level,
     p_txn_party_detail_tbl     => p_txn_party_detail_tbl,
     px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
     x_return_status            => l_return_status,
     x_msg_count                => l_msg_count,
     x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Update Txn Party And Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_Txn_Party_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Txn_Party_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Update_Txn_Party_Dtls;
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

  END update_txn_party_dtls;

  /*
  */
  PROCEDURE update_txn_pty_acct_dtls
  (
     p_api_version         IN  NUMBER
    ,p_commit              IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_detail_tbl IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status       OUT NOCOPY VARCHAR2
    ,x_msg_count           OUT NOCOPY NUMBER
    ,x_msg_data            OUT NOCOPY VARCHAR2
  )

  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'Update_Txn_Party_acct_Dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Txn_Party_acct_Dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Update Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_parties_pvt.update_txn_pty_acct_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_pty_acct_detail_tbl => p_txn_pty_acct_detail_tbl,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Update Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_party_acct_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Txn_Party_acct_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Update_Txn_Party_acct_Dtls;
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
  END update_txn_pty_acct_dtls;

  /* deletes the party entity for the given party detail id */
  PROCEDURE delete_txn_party_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_ids_tbl      IN  csi_t_datastructures_grp.txn_party_ids_tbl
    ,x_txn_pty_acct_ids_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_party_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_party_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Delete Txn Party and acounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_parties_pvt.delete_txn_party_dtls(
      p_api_version          => p_api_version,
      p_commit               => p_commit,
      p_init_msg_list        => p_init_msg_list,
      p_validation_level     => p_validation_level,
      p_txn_party_ids_tbl    => p_txn_party_ids_tbl,
      x_txn_pty_acct_ids_tbl => x_txn_pty_acct_ids_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Delete Txn Party and Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_party_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_party_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_party_dtls;
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

  END delete_txn_party_dtls;

  /* deletes the party accounts entity based on the party account id */
  PROCEDURE delete_txn_pty_acct_dtls              (
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_ids_tbl IN  csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_party_acct_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_party_acct_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : delete Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));


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

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
      p_api_version          => p_api_version,
      p_commit               => p_commit,
      p_init_msg_list        => p_init_msg_list,
      p_validation_level     => p_validation_level,
      p_txn_pty_acct_ids_tbl => p_txn_pty_acct_ids_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Delete Txn Party Accounts');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_party_acct_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_party_acct_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_party_acct_dtls;
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

  END delete_txn_pty_acct_dtls;

END csi_t_txn_parties_grp;

/
