--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_UD_KEY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_UD_KEY_PUB" AS
/* $Header: jtfprefabudb.pls 120.3 2005/10/28 00:23:28 emekala ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_UD_KEY_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabudb.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           OUT  NOCOPY     jtf_prefab_ud_keys_b.ud_key_id%TYPE,
  p_application_id      IN      jtf_prefab_ud_keys_b.application_id%TYPE,
  p_ud_key_name         IN      jtf_prefab_ud_keys_b.ud_key_name%TYPE,
  p_description         IN      jtf_prefab_ud_keys_tl.description%TYPE,
  p_filename            IN      jtf_prefab_ud_keys_b.filename%TYPE,
  p_user_defined_keys   IN      jtf_prefab_ud_keys_b.user_defined_keys%TYPE,
  p_enabled_flag        IN      jtf_prefab_ud_keys_b.enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY   jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_UD_KEY';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ud_keys_b_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_UD_KEY;

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
   	FETCH sequence_cursor INTO p_ud_key_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_UD_KEYS_PKG.INSERT_ROW(l_row_id,
                                          p_ud_key_id,
                                          p_object_version_number,
                                          NULL,
                                          p_application_id,
                                          p_ud_key_name,
                                          p_filename,
                                          p_user_defined_keys,
                                          p_enabled_flag,
                                          p_description,
                                          SYSDATE,
                                          G_USER_ID,
                                          SYSDATE,
                                          G_USER_ID,
                                          G_LOGIN_ID);
        /*
        INSERT INTO jtf_prefab_ud_keys (ud_key_id,
                                        object_version_number,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        security_group_id,
                                        application_id,
                                        ud_key_name,
                                        description,
                                        filename,
                                        user_defined_keys,
                                        enabled_flag)
        VALUES (p_ud_key_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                NULL,
                p_application_id,
                p_ud_key_name,
                p_description,
                p_filename,
                p_user_defined_keys,
                p_enabled_flag);
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
                ROLLBACK TO INSERT_UD_KEY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_UD_KEY;

PROCEDURE UPDATE_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           IN      jtf_prefab_ud_keys_b.ud_key_id%TYPE,
  p_application_id      IN      jtf_prefab_ud_keys_b.application_id%TYPE,
  p_ud_key_name         IN      jtf_prefab_ud_keys_b.ud_key_name%TYPE,
  p_description         IN      jtf_prefab_ud_keys_tl.description%TYPE,
  p_filename            IN      jtf_prefab_ud_keys_b.filename%TYPE,
  p_user_defined_keys   IN      jtf_prefab_ud_keys_b.user_defined_keys%TYPE,
  p_enabled_flag        IN      jtf_prefab_ud_keys_b.enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_UD_KEY';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_UD_KEY;

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

        JTF_PREFAB_UD_KEYS_PKG.UPDATE_ROW(p_ud_key_id,
                                          p_object_version_number,
                                          NULL,
                                          p_application_id,
                                          p_ud_key_name,
                                          p_filename,
                                          p_user_defined_keys,
                                          p_enabled_flag,
                                          p_description,
                                          SYSDATE,
                                          G_USER_ID,
                                          G_LOGIN_ID);

        /*
        UPDATE jtf_prefab_ud_keys
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            description = p_description,
            filename = p_filename,
            user_defined_keys = p_user_defined_keys,
            enabled_flag = p_enabled_flag
        WHERE ud_key_id = p_ud_key_id;
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
                ROLLBACK TO UPDATE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_UD_KEY;

procedure DELETE_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           IN      jtf_prefab_ud_keys_b.ud_key_id%TYPE,

  p_object_version_number IN    jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_UD_KEY';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_UD_KEY;

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

        JTF_PREFAB_UD_KEYS_PKG.DELETE_ROW(p_ud_key_id);

        /*
        DELETE FROM jtf_prefab_ud_keys
        WHERE ud_key_id = p_ud_key_id;
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
                ROLLBACK TO DELETE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_UD_KEY;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_UD_KEY;

END JTF_PREFAB_UD_KEY_PUB;

/
