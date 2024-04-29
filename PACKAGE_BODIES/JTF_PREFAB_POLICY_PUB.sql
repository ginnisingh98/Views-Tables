--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_POLICY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_POLICY_PUB" AS
/* $Header: jtfprefabpob.pls 120.3 2005/10/28 01:23:28 emekala ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_POLICY_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabpob.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           OUT  NOCOPY    jtf_prefab_policies_b.policy_id%TYPE,
  p_policy_name         IN      jtf_prefab_policies_b.policy_name%TYPE,
  p_priority            IN      jtf_prefab_policies_b.priority%TYPE,
  p_description         IN      jtf_prefab_policies_tl.description%TYPE,
  p_enabled_flag        IN      jtf_prefab_policies_b.enabled_flag%TYPE,
  p_application_id      IN      jtf_prefab_policies_b.application_id%TYPE,
  p_all_applications_flag IN    jtf_prefab_policies_b.all_applications_flag%TYPE,
  p_depth               IN      jtf_prefab_policies_b.depth%TYPE,
  p_all_responsibilities_flag IN  jtf_prefab_policies_b.all_responsibilities_flag%TYPE,
  p_all_users_flag      IN      jtf_prefab_policies_b.all_users_flag%TYPE,
  p_refresh_interval    IN      jtf_prefab_policies_b.refresh_interval%TYPE,
  p_interval_unit       IN      jtf_prefab_policies_b.interval_unit%TYPE,
  p_start_time          IN      jtf_prefab_policies_b.start_time%TYPE,
  p_end_time            IN      jtf_prefab_policies_b.end_time%TYPE,
  p_run_always_flag     IN      jtf_prefab_policies_b.run_always_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_POLICY';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_policies_b_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

   	OPEN sequence_cursor;
   	FETCH sequence_cursor INTO p_policy_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_POLICIES_PKG.INSERT_ROW(l_row_id,
                                           p_policy_id,
                                           p_object_version_number,
                                           NULL,
                                           p_policy_name,
                                           p_priority,
                                           p_enabled_flag,
                                           p_application_id,
                                           p_all_applications_flag,
                                           p_depth,
                                           p_all_responsibilities_flag,
                                           p_all_users_flag,
                                           p_refresh_interval,
                                           p_interval_unit,
                                           p_start_time,
                                           p_end_time,
                                           p_run_always_flag,
                                           p_description,
                                           SYSDATE,
                                           G_USER_ID,
                                           SYSDATE,
                                           G_USER_ID,
                                           G_LOGIN_ID);

        /*
        INSERT INTO jtf_prefab_policies (policy_id,
                                         object_version_number,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_date,
                                         last_update_login,
                                         policy_name,
                                         application_id,
                                         -- security_group_id,
                                         priority,
                                         description,
                                         enabled_flag,
                                         application_id_col,
                                         all_applications_flag,
                                         depth,
                                         all_responsibilities_flag,
                                         all_users_flag,
                                         refresh_interval,
                                         interval_unit,
                                         start_time,
                                         end_time,
                                         run_always_flag)
        VALUES (p_policy_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                p_policy_name,
                p_application_id,
                -- NULL,
                p_priority,
                p_description,
                p_enabled_flag,
                p_application_id_col,
                p_all_applications_flag,
                p_depth,
                p_all_responsibilities_flag,
                p_all_users_flag,
                p_refresh_interval,
                p_interval_unit,
                p_start_time,
                p_end_time,
                p_run_always_flag);
                */

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_POLICY;

PROCEDURE UPDATE_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_policies_b.policy_id%TYPE,
  p_policy_name         IN      jtf_prefab_policies_b.policy_name%TYPE,
  p_priority            IN      jtf_prefab_policies_b.priority%TYPE,
  p_description         IN      jtf_prefab_policies_tl.description%TYPE,
  p_enabled_flag        IN      jtf_prefab_policies_b.enabled_flag%TYPE,
  p_application_id      IN      jtf_prefab_policies_b.application_id%TYPE,
  p_all_applications_flag IN      jtf_prefab_policies_b.all_applications_flag%TYPE,
  p_depth               IN      jtf_prefab_policies_b.depth%TYPE,
  p_all_responsibilities_flag IN  jtf_prefab_policies_b.all_responsibilities_flag%TYPE,
  p_all_users_flag      IN      jtf_prefab_policies_b.all_users_flag%TYPE,
  p_refresh_interval    IN      jtf_prefab_policies_b.refresh_interval%TYPE,
  p_interval_unit       IN      jtf_prefab_policies_b.interval_unit%TYPE,
  p_start_time          IN      jtf_prefab_policies_b.start_time%TYPE,
  p_end_time            IN      jtf_prefab_policies_b.end_time%TYPE,
  p_run_always_flag     IN      jtf_prefab_policies_b.run_always_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        JTF_PREFAB_POLICIES_PKG.UPDATE_ROW(p_policy_id,
                                           p_object_version_number,
                                           NULL,
                                           p_policy_name,
                                           p_priority,
                                           p_enabled_flag,
                                           p_application_id,
                                           p_all_applications_flag,
                                           p_depth,
                                           p_all_responsibilities_flag,
                                           p_all_users_flag,
                                           p_refresh_interval,
                                           p_interval_unit,
                                           p_start_time,
                                           p_end_time,
                                           p_run_always_flag,
                                           p_description,
                                           SYSDATE,
                                           G_USER_ID,
                                           G_LOGIN_ID);

        /*
        UPDATE jtf_prefab_policies
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            policy_name = p_policy_name,
            application_id = p_application_id,
            priority = p_priority,
            description = p_description,
            enabled_flag = p_enabled_flag,
            all_applications_flag = p_all_applications_flag,
            depth = p_depth,
            all_responsibilities_flag = p_all_responsibilities_flag,
            all_users_flag = p_all_users_flag,
            refresh_interval = p_refresh_interval,
            interval_unit = p_interval_unit,
            start_time = p_start_time,
            end_time = p_end_time,
            run_always_flag = p_run_always_flag
        WHERE policy_id = p_policy_id;
         */

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_POLICY;

procedure DELETE_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_policies_b.policy_id%TYPE,

  p_object_version_number IN    jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_POLICY';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        JTF_PREFAB_POLICIES_PKG.DELETE_ROW(p_policy_id);

        /*
        DELETE FROM jtf_prefab_policies
        WHERE policy_id = p_policy_id;
         */

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_POLICY;

PROCEDURE INSERT_UR_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,
  p_userresp_id         IN      jtf_prefab_ur_policies.userresp_id%TYPE,
  p_userresp_type       IN      jtf_prefab_ur_policies.userresp_type%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_UR_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_UR_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_ur_policies (ur_policy_id,
                                            object_version_number,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date,
                                            last_update_login,
                                            -- security_group_id,
                                            policy_id,
                                            userresp_id,
                                            userresp_type)
        VALUES (jtf_prefab_ur_policies_s.NEXTVAL,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_policy_id,
                p_userresp_id,
                p_userresp_type);

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_UR_POLICY;

PROCEDURE DELETE_UR_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,
  p_userresp_id         IN      jtf_prefab_ur_policies.userresp_id%TYPE,
  p_userresp_type       IN      jtf_prefab_ur_policies.userresp_type%TYPE,

  p_object_version_number IN    jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_UR_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_UR_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        DELETE FROM jtf_prefab_ur_policies
        WHERE policy_id = p_policy_id
        AND   userresp_id = p_userresp_id
        AND   userresp_type = p_userresp_type;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_UR_POLICY;

PROCEDURE DELETE_UR_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,

  p_object_version_number IN    jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_UR_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_UR_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        DELETE FROM jtf_prefab_ur_policies
        WHERE policy_id = p_policy_id;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_UR_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_UR_POLICY;

PROCEDURE CONFIGURE_SYS_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_start_flag          IN      jtf_prefab_sys_policies.start_flag%TYPE,
  p_cpu                 IN      jtf_prefab_sys_policies.cpu%TYPE,
  p_memory              IN      jtf_prefab_sys_policies.memory%TYPE,
  p_disk_location       IN      jtf_prefab_sys_policies.disk_location%TYPE,
  p_max_concurrency     IN      jtf_prefab_sys_policies.max_concurrency%TYPE,
  p_use_load_balancer_flag IN      jtf_prefab_sys_policies.use_load_balancer_flag%TYPE,
  p_load_balancer_url   IN      jtf_prefab_sys_policies.load_balancer_url%TYPE,
  p_refresh_flag        IN      jtf_prefab_sys_policies.refresh_flag%TYPE,
  p_interceptor_enabled_flag IN jtf_prefab_sys_policies.interceptor_enabled_flag%TYPE,
  p_cache_memory        IN      jtf_prefab_sys_policies.cache_memory%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_sys_policies.object_version_number%TYPE,
  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'CONFIGURE_SYS_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT CONFIGURE_SYS_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        UPDATE jtf_prefab_sys_policies
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            start_flag = p_start_flag,
            cpu = p_cpu,
            memory = p_memory,
            disk_location = p_disk_location,
            max_concurrency = p_max_concurrency,
            use_load_balancer_flag = p_use_load_balancer_flag,
            load_balancer_url = p_load_balancer_url,
            refresh_flag = p_refresh_flag,
            interceptor_enabled_flag = p_interceptor_enabled_flag,
            cache_memory = p_cache_memory;

        IF SQL%NOTFOUND THEN
          p_object_version_number := 1;

          INSERT INTO jtf_prefab_sys_policies (sys_policy_id,
                                               object_version_number,
                                               created_by,
                                               creation_date,
                                               last_updated_by,
                                               last_update_date,
                                               last_update_login,
                                               -- security_group_id,
                                               start_flag,
                                               cpu,
                                               memory,
                                               disk_location,
                                               max_concurrency,
                                               use_load_balancer_flag,
                                               load_balancer_url,
                                               refresh_flag,
                                               interceptor_enabled_flag,
                                               cache_memory)
          VALUES (jtf_prefab_sys_policies_s.NEXTVAL,
                  p_object_version_number,
                  G_USER_ID,
                  SYSDATE,
                  G_USER_ID,
                  SYSDATE,
                  G_LOGIN_ID,
                  -- NULL,
                  p_start_flag,
                  p_cpu,
                  p_memory,
                  p_disk_location,
                  p_max_concurrency,
                  p_use_load_balancer_flag,
                  p_load_balancer_url,
                  p_refresh_flag,
                  p_interceptor_enabled_flag,
                  p_cache_memory);
        END IF;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CONFIGURE_SYS_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CONFIGURE_SYS_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO CONFIGURE_SYS_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END CONFIGURE_SYS_POLICY;

PROCEDURE INSERT_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           OUT  NOCOPY    jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,
  p_hostname            IN      jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_description         IN      jtf_prefab_wsh_poes_tl.description%TYPE,
  p_weight              IN      jtf_prefab_wsh_poes_b.weight%TYPE,
  p_load_pick_up_flag   IN      jtf_prefab_wsh_poes_b.load_pick_up_flag%TYPE,
  p_cache_size          IN      jtf_prefab_wsh_poes_b.cache_size%TYPE,
  p_wsh_type            IN      jtf_prefab_wsh_poes_b.wsh_type%TYPE,
  p_prefab_enabled_flag IN      jtf_prefab_wsh_poes_b.prefab_enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_WSH_POLICY';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_wsh_poes_b_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_WSH_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

   	OPEN sequence_cursor;
   	FETCH sequence_cursor INTO p_wsh_po_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_WSH_POES_PKG.INSERT_ROW(l_row_id,
                                               p_wsh_po_id,
                                               p_object_version_number,
                                               NULL,
                                               p_hostname,
                                               p_weight,
                                               p_load_pick_up_flag,
                                               p_cache_size,
                                               p_wsh_type,
                                               p_prefab_enabled_flag,
                                               p_description,
                                               SYSDATE,
                                               G_USER_ID,
                                               SYSDATE,
                                               G_USER_ID,
                                               G_LOGIN_ID);
        /*
        INSERT INTO jtf_prefab_wsh_policies(wsh_policy_id,
                                            object_version_number,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date,
                                            last_update_login,
                                            -- security_group_id,
                                            hostname,
                                            description,
                                            weight,
                                            load_pick_up_flag,
                                            prefab_enable_flag,
                                            prefetch_enable_flag,
                                            cache_enable_flag,
                                            cache_size,
                                            wsh_type)
        VALUES (p_wsh_policy_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_hostname,
                p_description,
                p_weight,
                p_load_pick_up_flag,
                p_prefab_enable_flag,
                p_prefetch_enable_flag,
                p_cache_enable_flag,
                p_cache_size,
                p_wsh_type);
                */

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_WSH_POLICY;

PROCEDURE UPDATE_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,
  p_hostname            IN      jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_description         IN      jtf_prefab_wsh_poes_tl.description%TYPE,
  p_weight              IN      jtf_prefab_wsh_poes_b.weight%TYPE,
  p_load_pick_up_flag   IN      jtf_prefab_wsh_poes_b.load_pick_up_flag%TYPE,
  p_cache_size          IN      jtf_prefab_wsh_poes_b.cache_size%TYPE,
  p_wsh_type            IN      jtf_prefab_wsh_poes_b.wsh_type%TYPE,
  p_prefab_enabled_flag IN      jtf_prefab_wsh_poes_b.prefab_enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_WSH_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_WSH_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------
        JTF_PREFAB_WSH_POES_PKG.UPDATE_ROW(p_wsh_po_id,
                                               p_object_version_number,
                                               NULL,
                                               p_hostname,
                                               p_weight,
                                               p_load_pick_up_flag,
                                               p_cache_size,
                                               p_wsh_type,
                                               p_prefab_enabled_flag,
                                               p_description,
                                               SYSDATE,
                                               G_USER_ID,
                                               G_LOGIN_ID);
        /*
        UPDATE jtf_prefab_wsh_policies
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            description= p_description,
            weight = p_weight,
            load_pick_up_flag = p_load_pick_up_flag,
            prefab_enable_flag = p_prefab_enable_flag,
            prefetch_enable_flag = p_prefetch_enable_flag,
            cache_enable_flag = p_cache_enable_flag,
            cache_size = p_cache_size,
            wsh_type = p_wsh_type
        WHERE wsh_policy_id = p_wsh_policy_id;
         */

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_WSH_POLICY;

procedure DELETE_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_WSH_POLICY';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_WSH_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        JTF_PREFAB_WSH_POES_PKG.DELETE_ROW(p_wsh_po_id);

        /*
        DELETE FROM jtf_prefab_wsh_policies
        WHERE wsh_policy_id = p_wsh_policy_id;
         */

        JTF_PREFAB_CACHE_PUB.DELETE_HOST_APPS_FOR_HOST(p_api_version,
                                                       p_init_msg_list,
                                                       p_commit,
                                                       p_wsh_po_id,
                                                       p_object_version_number,
                                                       x_return_status,
                                                       x_msg_count,
                                                       x_msg_data);

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_WSH_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_WSH_POLICY;

PROCEDURE INSERT_WSHP_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,
  p_port                IN      jtf_prefab_wshp_policies.port%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_WSHP_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_WSHP_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_wshp_policies (wshp_policy_id,
                                              object_version_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              -- security_group_id,
                                              wsh_po_id,
                                              port)
        VALUES (jtf_prefab_wshp_policies_s.NEXTVAL,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_wsh_po_id,
                p_port);

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO INSERT_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_WSHP_POLICY;

PROCEDURE DELETE_WSHP_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,
  p_port                IN      jtf_prefab_wshp_policies.port%TYPE,

  p_object_version_number IN    jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_WSHP_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_WSHP_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        DELETE FROM jtf_prefab_wshp_policies
        WHERE wsh_po_id = p_wsh_po_id
        AND   port = p_port;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_WSHP_POLICY;

PROCEDURE DELETE_WSHP_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_WSHP_POLICY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_WSHP_POLICY;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- real logic --
        ----------------

        DELETE FROM jtf_prefab_wshp_policies
        WHERE wsh_po_id = p_wsh_po_id;

        -----------------------
        -- end of real logic --

        -- Standard check of p_commit.
        IF (FND_API.To_Boolean(p_commit)) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_WSHP_POLICY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_WSHP_POLICY;

END JTF_PREFAB_POLICY_PUB;

/
