--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_FILTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_FILTER_PUB" AS
/* $Header: jtfprefabflb.pls 120.1 2005/07/02 00:56:25 appldev ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_FILTER_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabflb.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           OUT NOCOPY jtf_prefab_filters_b.filter_id%TYPE,
  p_filter_name         IN jtf_prefab_filters_b.filter_name%TYPE,
  p_application_id      IN jtf_prefab_filters_b.application_id%TYPE,
  p_description         IN jtf_prefab_filters_tl.description%TYPE,
  p_filter_string       IN jtf_prefab_filters_b.filter_string%TYPE,
  p_exclusion_flag      IN jtf_prefab_filters_b.exclusion_flag%TYPE,
  p_enabled_flag        IN jtf_prefab_filters_b.enabled_flag%TYPE,

  p_object_version_number OUT NOCOPY jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_FILTER';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_filters_b_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_FILTER;

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
   	FETCH sequence_cursor INTO p_filter_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_FILTERS_PKG.INSERT_ROW(l_row_id,
                                          p_filter_id,
                                          p_object_version_number,
                                          NULL,
                                          p_application_id,
                                          p_filter_name,
                                          p_filter_string,
                                          p_exclusion_flag,
                                          p_enabled_flag,
                                          p_description,
                                          SYSDATE,
                                          G_USER_ID,
                                          SYSDATE,
                                          G_USER_ID,
                                          G_LOGIN_ID);
        /*
        INSERT INTO jtf_prefab_filters (filter_id,
                                         object_version_number,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_date,
                                         last_update_login,
                                         security_group_id,
                                         filter_name,
                                         application_id,
                                         application_id_for_filter,
                                         description,
                                         filter_string,
                                         exclusion_flag,
                                         enabled_flag)
        VALUES (p_filter_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                NULL,
                p_filter_name,
                p_application_id,
                p_application_id_for_filter,
                p_description,
                p_filter_string,
                p_exclusion_flag,
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
                ROLLBACK TO INSERT_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_FILTER;

PROCEDURE UPDATE_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           IN jtf_prefab_filters_b.filter_id%TYPE,
  p_filter_name         IN jtf_prefab_filters_b.filter_name%TYPE,
  p_application_id      IN jtf_prefab_filters_b.application_id%TYPE,
  p_description         IN jtf_prefab_filters_tl.description%TYPE,
  p_filter_string       IN jtf_prefab_filters_b.filter_string%TYPE,
  p_exclusion_flag      IN jtf_prefab_filters_b.exclusion_flag%TYPE,
  p_enabled_flag        IN jtf_prefab_filters_b.enabled_flag%TYPE,

  p_object_version_number IN OUT NOCOPY jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_FILTER';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_FILTER;

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

        JTF_PREFAB_FILTERS_PKG.UPDATE_ROW(p_filter_id,
                                          p_object_version_number,
                                          NULL,
                                          p_application_id,
                                          p_filter_name,
                                          p_filter_string,
                                          p_exclusion_flag,
                                          p_enabled_flag,
                                          p_description,
                                          SYSDATE,
                                          G_USER_ID,
                                          G_LOGIN_ID);

        /*
        UPDATE jtf_prefab_filters
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            filter_name = p_filter_name,
            application_id = p_application_id,
            application_id_for_filter = p_application_id_for_filter,
            description = p_description,
            filter_string = p_filter_string,
            exclusion_flag = p_exclusion_flag,
            enabled_flag = p_enabled_flag
        WHERE filter_id = p_filter_id;
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
                ROLLBACK TO UPDATE_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_FILTER;

procedure DELETE_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           IN      jtf_prefab_filters_b.filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_FILTER';
        l_api_version           CONSTANT NUMBER := p_api_version;

        l_object_version        NUMBER := NULL;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_FILTER;

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

        JTF_PREFAB_FILTERS_PKG.DELETE_ROW(p_filter_id);

        /*
        DELETE FROM jtf_prefab_filters
        WHERE filter_id = p_filter_id;
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
                ROLLBACK TO DELETE_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_FILTER;

END JTF_PREFAB_FILTER_PUB;

/
