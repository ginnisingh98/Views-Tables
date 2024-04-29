--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_LOAD_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_LOAD_DIST_PUB" AS
/* $Header: jtfprefabldb.pls 120.1 2005/07/02 00:56:38 appldev ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_LOAD_DIST_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabldb.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_PRB(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_prbs.policy_id%TYPE,
  p_uri                 IN      jtf_prefab_prbs.uri%TYPE,
  p_user_id             IN      jtf_prefab_prbs.user_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_prbs.responsibility_id%TYPE,
  p_application_id      IN      jtf_prefab_prbs.application_id%TYPE,
  p_prefab_hostname     IN      jtf_prefab_prbs.prefab_hostname%TYPE,

  p_object_version_number OUT NOCOPY   jtf_prefab_prbs.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_PRB';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_PRB;

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

        INSERT INTO jtf_prefab_prbs(prb_id,
                                    object_version_number,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    -- security_group_id,
                                    policy_id,
                                    uri,
                                    user_id,
                                    responsibility_id,
                                    application_id,
                                    prefab_hostname)
        VALUES (jtf_prefab_prbs_s.NEXTVAL,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_policy_id,
                p_uri,
                p_user_id,
                p_responsibility_id,
                p_application_id,
                p_prefab_hostname);

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
                ROLLBACK TO INSERT_PRB;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_PRB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_PRB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_PRB;

END JTF_PREFAB_LOAD_DIST_PUB;

/
