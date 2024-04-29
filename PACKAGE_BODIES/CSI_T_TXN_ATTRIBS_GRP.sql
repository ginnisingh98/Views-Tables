--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_ATTRIBS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_ATTRIBS_GRP" as
/*$Header: csigteab.pls 115.12 2004/01/08 23:53:58 rmamidip ship $*/

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_attribs_grp';
  g_file_name   CONSTANT VARCHAR2(12) := 'csigteab.pls';

  g_user_id              NUMBER := FND_GLOBAL.User_Id;
  g_login_id             NUMBER := FND_GLOBAL.Login_Id;


  PROCEDURE create_txn_ext_attrib_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'create_txn_ext_attrib_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

    l_count                        NUMBER;

    l_txn_ea_rec    csi_t_datastructures_grp.txn_ext_attrib_vals_rec;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_ext_attrib_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Create Txn Extended Attributes');
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

    IF px_txn_ext_attrib_vals_tbl.COUNT > 0 then

      -- loop thru ext attrib table
      FOR l_index IN px_txn_ext_attrib_vals_tbl.FIRST..px_txn_ext_attrib_vals_tbl.LAST
      LOOP

        l_txn_ea_rec := px_txn_ext_attrib_vals_tbl(l_index);

        -- call api to create extended attribute
        csi_t_txn_attribs_pvt.create_txn_ext_attrib_dtls(
          p_api_version          => p_api_version,
          p_commit               => p_commit,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          p_txn_ext_attrib_vals_rec  => l_txn_ea_rec,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

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

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Create Txn Extended Attributes');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
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

  END create_txn_ext_attrib_dtls;

  /*
  */
  PROCEDURE update_txn_ext_attrib_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_vals_tbl    IN csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'Update_Txn_Ext_Attrib_Dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(512);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Txn_Ext_Attrib_Dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Update Txn Extended Attributes');
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

    csi_t_txn_attribs_pvt.update_txn_ext_attrib_dtls(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_txn_ext_attrib_vals_tbl => p_txn_ext_attrib_vals_tbl,
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

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Update Txn Extended Attributes');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_Txn_Ext_Attrib_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Txn_Ext_Attrib_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Update_Txn_Ext_Attrib_Dtls;
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

  END update_txn_ext_attrib_dtls;

  PROCEDURE delete_txn_ext_attrib_dtls
  (
     p_api_version             IN  NUMBER
    ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_ids_tbl  IN  csi_t_datastructures_grp.
                                      txn_ext_attrib_ids_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_ext_attrib_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_ext_attrib_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Delete Txn Extended Attributes');
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

    csi_t_txn_attribs_pvt.delete_txn_ext_attrib_dtls(
      p_api_version            => p_api_version,
      p_commit                 => p_commit,
      p_init_msg_list          => p_init_msg_list,
      p_validation_level       => p_validation_level,
      p_txn_ext_attrib_ids_tbl => p_txn_ext_attrib_ids_tbl,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

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

    csi_t_gen_utility_pvt.add('API Successfully Executed         : Delete Txn Extended Attributes');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
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

  END delete_txn_ext_attrib_dtls;

END csi_t_txn_attribs_grp;

/
