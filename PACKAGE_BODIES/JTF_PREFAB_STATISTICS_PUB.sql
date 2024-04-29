--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_STATISTICS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_STATISTICS_PUB" AS
/* $Header: jtfprefabstb.pls 120.3 2005/10/28 00:22:56 emekala ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_STATISTICS_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabstb.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          IN      jtf_prefab_statistics.start_time%TYPE,
  p_end_time            IN      jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    IN      jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      IN      jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       IN      jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        IN      jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       IN      jtf_prefab_statistics.system_status%TYPE,
  p_error_status        IN      jtf_prefab_statistics.error_status%TYPE,
  p_depth               IN      jtf_prefab_statistics.depth%TYPE,
  p_disk_used           IN      jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             IN      jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             IN      jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            IN      jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number OUT  NOCOPY    NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_STATISTICS';
        l_api_version           NUMBER  := p_api_version;

        l_statistics_id         NUMBER := NULL;
        CURSOR statistics_id IS SELECT jtf_prefab_statistics_s.NEXTVAL FROM sys.dual;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_STATISTICS;

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
        -- Use Sequence as the unique key
        OPEN statistics_id;
        FETCH statistics_id INTO l_statistics_id;
        CLOSE statistics_id;

        p_object_version_number := 1;

        INSERT INTO jtf_prefab_statistics (statistics_id,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_date,
                                             last_update_login,
                                             object_version_number,
                                             -- security_group_id,
                                             policy_id,
                                             wsh_po_id,
                                             start_time,
                                             end_time,
                                             last_update_time,
                                             pages_last_run,
                                             pages_crawled,
                                             refresh_rate,
                                             system_status,
                                             error_status,
                                             depth,
                                             disk_used,
                                             avg_mem,
                                             avg_cpu,
                                             hit_rate)
               VALUES (l_statistics_id,
                       G_USER_ID,
                       SYSDATE,
                       G_USER_ID,
                       SYSDATE,
                       G_LOGIN_ID,
                       p_object_version_number,
                       -- NULL,
                       p_policy_id,
                       p_wsh_po_id,
                       p_start_time,
                       p_end_time,
                       p_last_update_time,
                       p_pages_last_run,
                       p_pages_crawled,
                       p_refresh_rate,
                       p_system_status,
                       p_error_status,
                       p_depth,
                       p_disk_used,
                       p_avg_mem,
                       p_avg_cpu,
                       p_hit_rate);

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
                ROLLBACK TO INSERT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_STATISTICS;

PROCEDURE UPDATE_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          IN      jtf_prefab_statistics.start_time%TYPE,
  p_end_time            IN      jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    IN      jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      IN      jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       IN      jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        IN      jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       IN      jtf_prefab_statistics.system_status%TYPE,
  p_error_status        IN      jtf_prefab_statistics.error_status%TYPE,
  p_depth               IN      jtf_prefab_statistics.depth%TYPE,
  p_disk_used           IN      jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             IN      jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             IN      jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            IN      jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number IN OUT  NOCOPY     NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_STATISTICS';
        l_api_version           NUMBER  := p_api_version;

        l_object_version        NUMBER := NULL;

--        l_um_row                JTF_XML_URL_MAPPINGS_B%ROWTYPE;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_STATISTICS;

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
/*
        SELECT object_version_number INTO l_object_version
        FROM jtf_prefab_statistics
        WHERE application_id = p_application_id;

        -- checking for object version number
        if (l_object_version IS NULL OR l_object_version > p_OBJ_VER_NUMBER) THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSE
                p_obj_ver_number := p_obj_ver_number + 1;
        END IF;
*/

        UPDATE jtf_prefab_statistics
        SET last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            object_version_number = p_object_version_number,
            start_time = p_start_time,
            end_time = p_end_time,
            last_update_time = p_last_update_time,
            pages_last_run = p_pages_last_run,
            pages_crawled = p_pages_crawled,
            refresh_rate = p_refresh_rate,
            system_status = p_system_status,
            error_status = p_error_status,
            depth = p_depth,
            disk_used = p_disk_used,
            avg_mem = p_avg_mem,
            avg_cpu = p_avg_cpu,
            hit_rate = p_hit_rate
        WHERE policy_id = p_policy_id AND wsh_po_id = p_wsh_po_id;

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
                ROLLBACK TO UPDATE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_STATISTICS;

PROCEDURE DELETE_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      NUMBER,
  p_wsh_po_id           IN      NUMBER,

  p_object_version_number      IN      NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_STATISTICS';
        l_api_version           CONSTANT NUMBER := p_api_version;

        l_object_version        NUMBER := NULL;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_STATISTICS;

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
/*
        SELECT object_version_number INTO l_object_version
        FROM jtf_prefab_statistics
        WHERE application_id = p_application_id;

        -- checking for object version number
        IF (l_object_version IS NULL OR l_object_version > p_obj_ver_number) THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
        DELETE FROM jtf_prefab_statistics
        WHERE policy_id = p_policy_id AND wsh_po_id = p_wsh_po_id;

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
                ROLLBACK TO DELETE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_STATISTICS;

PROCEDURE SELECT_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          OUT  NOCOPY     jtf_prefab_statistics.start_time%TYPE,
  p_end_time            OUT  NOCOPY     jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    OUT  NOCOPY     jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      OUT  NOCOPY     jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       OUT  NOCOPY     jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        OUT  NOCOPY     jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       OUT  NOCOPY     jtf_prefab_statistics.system_status%TYPE,
  p_error_status        OUT  NOCOPY     jtf_prefab_statistics.error_status%TYPE,
  p_depth               OUT  NOCOPY     jtf_prefab_statistics.depth%TYPE,
  p_disk_used           OUT  NOCOPY     jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             OUT  NOCOPY     jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             OUT  NOCOPY     jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            OUT  NOCOPY     jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number OUT  NOCOPY   NUMBER,
  p_row_count           OUT  NOCOPY     NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'SELECT_STATISTICS';
        l_api_version           NUMBER  := p_api_version;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT SELECT_STATISTICS;

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

        SELECT start_time, end_time, last_update_time,
               pages_last_run, pages_crawled, refresh_rate,
               system_status, error_status, depth, disk_used,
               avg_mem, avg_cpu, hit_rate,
               object_version_number
        INTO p_start_time, p_end_time, p_last_update_time,
               p_pages_last_run, p_pages_crawled, p_refresh_rate,
               p_system_status, p_error_status, p_depth, p_disk_used,
               p_avg_mem, p_avg_cpu, p_hit_rate,
               p_object_version_number
        FROM jtf_prefab_statistics
        WHERE policy_id = p_policy_id AND wsh_po_id = p_wsh_po_id;

        p_row_count := SQL%ROWCOUNT;

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
                ROLLBACK TO SELECT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO SELECT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO SELECT_STATISTICS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END SELECT_STATISTICS;

END JTF_PREFAB_STATISTICS_PUB;

/
