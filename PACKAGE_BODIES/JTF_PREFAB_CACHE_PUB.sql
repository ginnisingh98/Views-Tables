--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_CACHE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_CACHE_PUB" AS
/* $Header: jtfprefabcab.pls 120.3 2006/09/15 12:23:31 amaddula ship $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_PREFAB_CACHE_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfprefabcab.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE INSERT_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         OUT  NOCOPY jtf_prefab_host_apps.host_app_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_host_apps.wsh_po_id%TYPE,
  p_application_id      IN      jtf_prefab_host_apps.application_id%TYPE,
  p_cache_policy        IN      jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy IN      jtf_prefab_host_apps.cache_filter_policy%TYPE,

  p_object_version_number OUT NOCOPY  jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_HOST_APP';
        l_api_version           NUMBER  := p_api_version;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_host_apps_s.NEXTVAL from dual;
        CURSOR cache_comps_cursor IS
          SELECT ca_comp_id
          FROM jtf_prefab_ca_comps_vl
          WHERE application_id = p_application_id and cache_generic_flag='f';
        CURSOR cache_comps_cursor_gen IS
          SELECT ca_comp_id
          FROM jtf_prefab_ca_comps_vl
          WHERE cache_generic_flag='t';
        CURSOR cache_filters_cursor IS
          SELECT ca_filter_id
          FROM jtf_prefab_ca_filters_vl
          WHERE application_id = p_application_id;
        l_ca_comp_id            NUMBER;
        l_ha_comp_id            NUMBER;
        l_ca_filter_id          NUMBER;
        l_ha_filter_id          NUMBER;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_HOST_APP;

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
   	FETCH sequence_cursor INTO p_host_app_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_host_apps (host_app_id,
                                     object_version_number,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     -- security_group_id,
                                     wsh_po_id,
                                     application_id,
                                     cache_policy,
                                     cache_clear_flag,
                                     cache_reload_flag,
                                     cache_filter_policy)
        VALUES (p_host_app_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_wsh_po_id,
                p_application_id,
                p_cache_policy,
                p_cache_clear_flag,
                p_cache_reload_flag,
                p_cache_filter_policy);

        -- figure out all the cache components, and for each component,
        -- add to the ha_comps table

        IF p_application_id = -1 THEN
         OPEN cache_comps_cursor_gen;
         FETCH cache_comps_cursor_gen INTO l_ca_comp_id;

         WHILE cache_comps_cursor_gen%FOUND LOOP
           JTF_PREFAB_CACHE_PUB.INSERT_HA_COMP(p_api_version,
                                               p_init_msg_list,
                                               p_commit,
                                               l_ha_comp_id,
                                               p_host_app_id,
                                               l_ca_comp_id,
                                               'CO',
                                               'f',
                                               'f',
                                               p_object_version_number,
                                               x_return_status,
                                               x_msg_count,
                                               x_msg_data);
           FETCH cache_comps_cursor_gen INTO l_ca_comp_id;
         END LOOP;
         CLOSE cache_comps_cursor_gen;
        ELSE
         OPEN cache_comps_cursor;
         FETCH cache_comps_cursor INTO l_ca_comp_id;
         WHILE cache_comps_cursor%FOUND LOOP
           JTF_PREFAB_CACHE_PUB.INSERT_HA_COMP(p_api_version,
                                               p_init_msg_list,
                                               p_commit,
                                               l_ha_comp_id,
                                               p_host_app_id,
                                               l_ca_comp_id,
                                               'CO',
                                               'f',
                                               'f',
                                               p_object_version_number,
                                               x_return_status,
                                               x_msg_count,
                                               x_msg_data);
           FETCH cache_comps_cursor INTO l_ca_comp_id;
         END LOOP;
         CLOSE cache_comps_cursor;
        END IF;

        -- for each application/host pair that the filter belongs to,
        -- add a row to ha_filters

        OPEN cache_filters_cursor;
        FETCH cache_filters_cursor INTO l_ca_filter_id;

        WHILE cache_filters_cursor%FOUND LOOP
          JTF_PREFAB_CACHE_PUB.INSERT_HA_FILTER(p_api_version,
                                                p_init_msg_list,
                                                p_commit,
                                                l_ha_filter_id,
                                                p_host_app_id,
                                                l_ca_filter_id,
                                                't',
                                                p_object_version_number,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data);
          FETCH cache_filters_cursor INTO l_ca_filter_id;
        END LOOP;

        CLOSE cache_filters_cursor;

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
                ROLLBACK TO INSERT_HOST_APP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_HOST_APP;

PROCEDURE UPDATE_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,
  p_cache_policy        IN      jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy IN      jtf_prefab_host_apps.cache_filter_policy%TYPE,

  p_object_version_number IN OUT NOCOPY jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT   NOCOPY  VARCHAR2,
  x_msg_count           OUT   NOCOPY  NUMBER,
  x_msg_data            OUT   NOCOPY  VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_HOST_APP';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_HOST_APP;

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

        UPDATE jtf_prefab_host_apps
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            cache_policy = p_cache_policy,
            cache_clear_flag = p_cache_clear_flag,
            cache_reload_flag = p_cache_reload_flag,
            cache_filter_policy = p_cache_filter_policy
        WHERE host_app_id = p_host_app_id;

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
                ROLLBACK TO UPDATE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_HOST_APP;

procedure SELECT_HOST_APP_FOR_HOST(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_host_apps.object_version_number%TYPE,
  p_wsh_po_id           OUT  NOCOPY    jtf_prefab_host_apps.wsh_po_id%TYPE,
  p_application_id      OUT  NOCOPY    jtf_prefab_host_apps.application_id%TYPE,
  p_cache_policy        OUT  NOCOPY    jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    OUT  NOCOPY    jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   OUT  NOCOPY    jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy OUT  NOCOPY    jtf_prefab_host_apps.cache_filter_policy%TYPE,
  p_hostname            OUT  NOCOPY    jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_appname             OUT  NOCOPY    fnd_application_vl.application_name%TYPE,
  p_app_short_name      OUT  NOCOPY    fnd_application_vl.application_short_name%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'SELECT_HOST_APPS_FOR_HOST';
        l_api_version           CONSTANT NUMBER := p_api_version;

        CURSOR host_app_cursor IS
          SELECT application_id
          FROM jtf_prefab_host_apps
          WHERE host_app_id = p_host_app_id;

BEGIN

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
        x_msg_count := 0;
        x_msg_data := 'S';


  open host_app_cursor;
  fetch host_app_cursor into p_application_id;

  if host_app_cursor%FOUND  THEN

     if p_application_id = -1 then

       SELECT app.object_version_number, app.wsh_po_id, app.application_id, app.cache_policy, app.cache_clear_flag, app.cache_reload_flag, app.cache_filter_policy, host.hostname, 'HTML-Platform', ''
       INTO p_object_version_number, p_wsh_po_id, p_application_id, p_cache_policy, p_cache_clear_flag, p_cache_reload_flag, p_cache_filter_policy, p_hostname, p_appname, p_app_short_name
       FROM jtf_prefab_host_apps app, jtf_prefab_wsh_poes_vl host
       WHERE app.host_app_id = p_host_app_id
       AND app.wsh_po_id = host.wsh_po_id;

     else

      SELECT app.object_version_number, app.wsh_po_id, app.application_id, app.cache_policy, app.cache_clear_flag, app.cache_reload_flag, app.cache_filter_policy, host.hostname, fndapp.application_name, fndapp.application_short_name
      INTO p_object_version_number, p_wsh_po_id, p_application_id, p_cache_policy, p_cache_clear_flag, p_cache_reload_flag, p_cache_filter_policy, p_hostname, p_appname, p_app_short_name
      FROM jtf_prefab_host_apps app, jtf_prefab_wsh_poes_vl host, fnd_application_vl fndapp
      WHERE app.host_app_id = p_host_app_id
      AND app.wsh_po_id = host.wsh_po_id
      AND app.application_id = fndapp.application_id;

     end if;

   end if;
   close host_app_cursor;

END SELECT_HOST_APP_FOR_HOST;


procedure DELETE_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HOST_APP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HOST_APP;

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

        DELETE FROM jtf_prefab_host_apps
        WHERE host_app_id = p_host_app_id;

        JTF_PREFAB_CACHE_PUB.DELETE_HA_COMPS_FOR_HOST_APP(p_api_version,
                                                          p_init_msg_list,
                                                          p_commit,
                                                          p_host_app_id,
                                                          p_object_version_number,
                                                          x_return_status,
                                                          x_msg_count,
                                                          x_msg_data);

        JTF_PREFAB_CACHE_PUB.DELETE_HA_FILTERS_F_HOST_APP(p_api_version,
                                                            p_init_msg_list,
                                                            p_commit,
                                                            p_host_app_id,
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
                ROLLBACK TO DELETE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HOST_APP;

procedure DELETE_HOST_APPS_FOR_HOST(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_host_apps.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HOST_APPS_FOR_HOST';
        l_api_version           CONSTANT NUMBER := p_api_version;

        CURSOR host_apps_cursor IS
          SELECT host_app_id
          FROM jtf_prefab_host_apps
          WHERE wsh_po_id = p_wsh_po_id;
        l_host_app_id           NUMBER;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HOST_APPS_FOR_HOST;

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

        OPEN host_apps_cursor;

        FETCH host_apps_cursor INTO l_host_app_id;
        WHILE host_apps_cursor%FOUND LOOP
          JTF_PREFAB_CACHE_PUB.DELETE_HOST_APP(p_api_version,
                                               p_init_msg_list,
                                               p_commit,
                                               l_host_app_id,
                                               p_object_version_number,
                                               x_return_status,
                                               x_msg_count,
                                               x_msg_data);
          FETCH host_apps_cursor INTO l_host_app_id;
        END LOOP;

        CLOSE host_apps_cursor;

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
                ROLLBACK TO DELETE_HOST_APPS_FOR_HOST;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HOST_APPS_FOR_HOST;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HOST_APPS_FOR_HOST;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HOST_APPS_FOR_HOST;

PROCEDURE INSERT_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          OUT  NOCOPY   jtf_prefab_ca_comps_b.ca_comp_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_comps_b.application_id%TYPE,
  p_comp_name           IN      jtf_prefab_ca_comps_b.comp_name%TYPE,
  p_description         IN      jtf_prefab_ca_comps_tl.description%TYPE,
  p_component_key       IN      jtf_prefab_ca_comps_b.component_key%TYPE,
  p_loader_class_name   IN      jtf_prefab_ca_comps_b.loader_class_name%TYPE,
  p_timeout_type        IN      jtf_prefab_ca_comps_b.timeout_type%TYPE,
  p_timeout             IN      jtf_prefab_ca_comps_b.timeout%TYPE,
  p_timeout_unit        IN      jtf_prefab_ca_comps_b.timeout_unit%TYPE,
  p_sgid_enabled_flag   IN      jtf_prefab_ca_comps_b.sgid_enabled_flag%TYPE,
  p_stat_enabled_flag   IN      jtf_prefab_ca_comps_b.stat_enabled_flag%TYPE,
  p_distributed_flag    IN      jtf_prefab_ca_comps_b.distributed_flag%TYPE,
  p_cache_generic_flag  IN      jtf_prefab_ca_comps_b.cache_generic_flag%TYPE,
  p_business_event_name IN      jtf_prefab_ca_comps_b.business_event_name%TYPE,

  p_object_version_number OUT NOCOPY  jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_CACHE_COMP';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ca_comps_b_s.NEXTVAL from dual;
        CURSOR host_apps_cursor IS
          SELECT host_app_id
          FROM jtf_prefab_host_apps
          WHERE application_id = p_application_id;
        CURSOR host_apps_cursor_gen IS
          SELECT host_app_id
          FROM jtf_prefab_host_apps
          WHERE application_id = -1;
        l_host_app_id           NUMBER;
        l_ha_comp_id            NUMBER;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_CACHE_COMP;

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
   	FETCH sequence_cursor INTO p_ca_comp_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_CA_COMPS_PKG.INSERT_ROW(l_row_id,
                                              p_ca_comp_id,
                                              NULL,
                                              p_application_id,
                                              p_comp_name,
                                              p_component_key,
                                              p_loader_class_name,
                                              p_timeout_type,
                                              p_timeout,
                                              p_timeout_unit,
                                              p_sgid_enabled_flag,
                                              p_stat_enabled_flag,
                                              p_distributed_flag,
                                              p_cache_generic_flag,
                                              p_business_event_name,
                                              p_object_version_number,
                                              p_description,
                                              SYSDATE,
                                              G_USER_ID,
                                              SYSDATE,
                                              G_USER_ID,
                                              G_LOGIN_ID);

        /*
        INSERT INTO jtf_prefab_cache_comps (ca_comp_id,
                                            object_version_number,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date,
                                            last_update_login,
                                            -- security_group_id,
                                            application_id,
                                            comp_name,
                                            description,
                                            component_key,
                                            loader_class_name,
                                            timeout_type,
                                            timeout,
                                            timeout_unit,
                                            sgid_enabled_flag,
                                            stat_enabled_flag,
                                            distributed_flag,
                                            cache_generic_flag)
        VALUES (p_ca_comp_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_application_id,
                p_comp_name,
                p_description,
                p_component_key,
                p_loader_class_name,
                p_timeout_type,
                p_timeout,
                p_timeout_unit,
                p_sgid_enabled_flag,
                p_stat_enabled_flag,
                p_distributed_flag,
                p_cache_generic_flag);
                */

        -- for each application/host pair that the component belongs to,
        -- add a row to ha_comps

        IF p_cache_generic_flag = 'f' THEN
          OPEN host_apps_cursor;
          FETCH host_apps_cursor INTO l_host_app_id;

          WHILE host_apps_cursor%FOUND LOOP
            JTF_PREFAB_CACHE_PUB.INSERT_HA_COMP(p_api_version,
                                                p_init_msg_list,
                                                p_commit,
                                                l_ha_comp_id,
                                                l_host_app_id,
                                                p_ca_comp_id,
                                                'CO',
                                                'f',
                                                'f',
                                                p_object_version_number,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data);
            FETCH host_apps_cursor INTO l_host_app_id;
          END LOOP;
          CLOSE host_apps_cursor;

        END IF;

        IF p_cache_generic_flag = 't' THEN
          OPEN host_apps_cursor_gen;
          FETCH host_apps_cursor_gen INTO l_host_app_id;

          WHILE host_apps_cursor_gen%FOUND LOOP
            JTF_PREFAB_CACHE_PUB.INSERT_HA_COMP(p_api_version,
                                                p_init_msg_list,
                                                p_commit,
                                                l_ha_comp_id,
                                                l_host_app_id,
                                                p_ca_comp_id,
                                                'CO',
                                                'f',
                                                'f',
                                                p_object_version_number,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data);
            FETCH host_apps_cursor_gen INTO l_host_app_id;
          END LOOP;
          CLOSE host_apps_cursor_gen;

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
                ROLLBACK TO INSERT_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_CACHE_COMP;

PROCEDURE UPDATE_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_comps_b.application_id%TYPE,
  p_comp_name           IN      jtf_prefab_ca_comps_b.comp_name%TYPE,
  p_description         IN      jtf_prefab_ca_comps_tl.description%TYPE,
  p_component_key       IN      jtf_prefab_ca_comps_b.component_key%TYPE,
  p_loader_class_name   IN      jtf_prefab_ca_comps_b.loader_class_name%TYPE,
  p_timeout_type        IN      jtf_prefab_ca_comps_b.timeout_type%TYPE,
  p_timeout             IN      jtf_prefab_ca_comps_b.timeout%TYPE,
  p_timeout_unit        IN      jtf_prefab_ca_comps_b.timeout_unit%TYPE,
  p_sgid_enabled_flag   IN      jtf_prefab_ca_comps_b.sgid_enabled_flag%TYPE,
  p_stat_enabled_flag   IN      jtf_prefab_ca_comps_b.stat_enabled_flag%TYPE,
  p_distributed_flag    IN      jtf_prefab_ca_comps_b.distributed_flag%TYPE,
  p_cache_generic_flag  IN      jtf_prefab_ca_comps_b.cache_generic_flag%TYPE,
  p_business_event_name IN      jtf_prefab_ca_comps_b.business_event_name%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_CACHE_COMP';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_CACHE_COMP;

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

        JTF_PREFAB_CA_COMPS_PKG.UPDATE_ROW(p_ca_comp_id,
                                              NULL,
                                              p_application_id,
                                              p_comp_name,
                                              p_component_key,
                                              p_loader_class_name,
                                              p_timeout_type,
                                              p_timeout,
                                              p_timeout_unit,
                                              p_sgid_enabled_flag,
                                              p_stat_enabled_flag,
                                              p_distributed_flag,
                                              p_cache_generic_flag,
                                              p_business_event_name,
                                              p_object_version_number,
                                              p_description,
                                              SYSDATE,
                                              G_USER_ID,
                                              G_LOGIN_ID);

        /*
        UPDATE jtf_prefab_cache_comps
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            comp_name = p_comp_name,
            description = p_description,
            loader_class_name = p_loader_class_name,
            timeout_type = p_timeout_type,
            timeout = p_timeout,
            timeout_unit = p_timeout_unit,
            sgid_enabled_flag = p_sgid_enabled_flag,
            stat_enabled_flag = p_stat_enabled_flag,
            distributed_flag = p_distributed_flag,
            cache_generic_flag = p_cache_generic_flag
        WHERE ca_comp_id = p_ca_comp_id;
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
                ROLLBACK TO UPDATE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_CACHE_COMP;

PROCEDURE UPDATE_CACHE_COMP_1(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,

 -- p_object_version_number IN OUT  NOCOPY jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_CACHE_COMP_1';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_CACHE_COMP_1;

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
        -- Passing values for ca_comp_id and last_updated_by columns
        JTF_PREFAB_CA_COMPS_PKG.UPDATE_ROW_1(p_ca_comp_id,
                                             1);


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
                ROLLBACK TO UPDATE_CACHE_COMP_1;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_CACHE_COMP_1;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_CACHE_COMP_1;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_CACHE_COMP_1;

procedure DELETE_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CACHE_COMP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CACHE_COMP;

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

        JTF_PREFAB_CA_COMPS_PKG.DELETE_ROW(p_ca_comp_id);

        /*
        DELETE FROM jtf_prefab_cache_comps
        WHERE ca_comp_id = p_ca_comp_id;
         */

        JTF_PREFAB_CACHE_PUB.DELETE_HA_COMPS_FOR_CACHE_COMP(p_api_version,
                                                            p_init_msg_list,
                                                            p_commit,
                                                            p_ca_comp_id,
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
                ROLLBACK TO DELETE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CACHE_COMP;

PROCEDURE INSERT_HA_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_comp_id          OUT  NOCOPY   jtf_prefab_ha_comps.ha_comp_id%TYPE,
  p_host_app_id         IN      jtf_prefab_ha_comps.host_app_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_ha_comps.ca_comp_id%TYPE,
  p_cache_policy        IN      jtf_prefab_ha_comps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_ha_comps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_ha_comps.cache_reload_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_HA_COMP';
        l_api_version           NUMBER  := p_api_version;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ha_comps_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_HA_COMP;

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
   	FETCH sequence_cursor INTO p_ha_comp_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_ha_comps (ha_comp_id,
                                            object_version_number,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date,
                                            last_update_login,
                                            -- security_group_id,
                                            host_app_id,
                                            ca_comp_id,
                                            cache_policy,
                                            cache_clear_flag,
                                            cache_reload_flag)
        VALUES (p_ha_comp_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_host_app_id,
                p_ca_comp_id,
                p_cache_policy,
                p_cache_clear_flag,
                p_cache_reload_flag);

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
                ROLLBACK TO INSERT_HA_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_HA_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_HA_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_HA_COMP;

PROCEDURE UPDATE_HA_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_comp_id          IN      jtf_prefab_ha_comps.ha_comp_id%TYPE,
  p_cache_policy        IN      jtf_prefab_ha_comps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_ha_comps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_ha_comps.cache_reload_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_HA_COMP';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_HA_COMP;

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

        UPDATE jtf_prefab_ha_comps
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            cache_policy = p_cache_policy,
            cache_clear_flag = p_cache_clear_flag,
            cache_reload_flag = p_cache_reload_flag
        WHERE ha_comp_id = p_ha_comp_id;

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
                ROLLBACK TO UPDATE_HA_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_HA_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_HA_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_HA_COMP;

procedure DELETE_HA_COMPS_FOR_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_ha_comps.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HA_COMPS_FOR_HOST_APP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HA_COMPS_FOR_HOST_APP;

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

        DELETE FROM jtf_prefab_ha_comps
        WHERE host_app_id = p_host_app_id;

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
                ROLLBACK TO DELETE_HA_COMPS_FOR_HOST_APP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HA_COMPS_FOR_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HA_COMPS_FOR_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HA_COMPS_FOR_HOST_APP;

procedure DELETE_HA_COMPS_FOR_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ha_comps.ca_comp_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HA_COMPS_FOR_CACHE_COMP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HA_COMPS_FOR_CACHE_COMP;

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

        DELETE FROM jtf_prefab_ha_comps
        WHERE ca_comp_id = p_ca_comp_id;

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
                ROLLBACK TO DELETE_HA_COMPS_FOR_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HA_COMPS_FOR_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HA_COMPS_FOR_CACHE_COMP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HA_COMPS_FOR_CACHE_COMP;

PROCEDURE INSERT_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_cache_stat_id       OUT  NOCOPY   jtf_prefab_cache_stats.cache_stat_id%TYPE,
  p_security_group_id   IN      jtf_prefab_cache_stats.security_group_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_cache_stats.wsh_po_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_cache_stats.ca_comp_id%TYPE,
  p_jvm_id              IN      jtf_prefab_cache_stats.jvm_id%TYPE,
  p_num_cache_miss      IN      jtf_prefab_cache_stats.num_cache_miss%TYPE,
  p_num_cache_hit       IN      jtf_prefab_cache_stats.num_cache_hit%TYPE,
  p_num_loader_miss     IN      jtf_prefab_cache_stats.num_loader_miss%TYPE,
  p_num_invalidate_call IN      jtf_prefab_cache_stats.num_invalidate_call%TYPE,
  p_num_invalidations   IN      jtf_prefab_cache_stats.num_invalidations%TYPE,
  p_num_objects         IN      jtf_prefab_cache_stats.num_objects%TYPE,
  p_expiration_time     IN      jtf_prefab_cache_stats.expiration_time%TYPE,
  p_start_time          IN      jtf_prefab_cache_stats.start_time%TYPE,
  p_end_time            IN      jtf_prefab_cache_stats.end_time%TYPE,

  p_object_version_number OUT  NOCOPY jtf_prefab_cache_stats.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_CACHE_STAT';
        l_api_version           NUMBER  := p_api_version;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_cache_stats_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_CACHE_STAT;

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
   	FETCH sequence_cursor INTO p_cache_stat_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_cache_stats(cache_stat_id,
                                           object_version_number,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           -- security_group_id,
                                           wsh_po_id,
                                           ca_comp_id,
                                           jvm_id,
                                           num_cache_miss,
                                           num_cache_hit,
                                           num_loader_miss,
                                           num_invalidate_call,
                                           num_invalidations,
                                           num_objects,
                                           expiration_time,
                                           start_time,
                                           end_time)
        VALUES (p_cache_stat_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- p_security_group_id,
                p_wsh_po_id,
                p_ca_comp_id,
                -- p_jvm_id,
			0,
                p_num_cache_miss,
                p_num_cache_hit,
                p_num_loader_miss,
                p_num_invalidate_call,
                p_num_invalidations,
                p_num_objects,
                p_expiration_time,
                p_start_time,
                p_end_time);

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
                ROLLBACK TO INSERT_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );
END INSERT_CACHE_STAT;

PROCEDURE UPDATE_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_cache_stat_id       IN      jtf_prefab_cache_stats.cache_stat_id%TYPE,
  p_security_group_id   IN      jtf_prefab_cache_stats.security_group_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_cache_stats.wsh_po_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_cache_stats.ca_comp_id%TYPE,
  p_jvm_id              IN      jtf_prefab_cache_stats.jvm_id%TYPE,
  p_num_cache_miss      IN      jtf_prefab_cache_stats.num_cache_miss%TYPE,
  p_num_cache_hit       IN      jtf_prefab_cache_stats.num_cache_hit%TYPE,
  p_num_loader_miss     IN      jtf_prefab_cache_stats.num_loader_miss%TYPE,
  p_num_invalidate_call IN      jtf_prefab_cache_stats.num_invalidate_call%TYPE,
  p_num_invalidations   IN      jtf_prefab_cache_stats.num_invalidations%TYPE,
  p_num_objects         IN      jtf_prefab_cache_stats.num_objects%TYPE,
  p_expiration_time     IN      jtf_prefab_cache_stats.expiration_time%TYPE,
  p_start_time          IN      jtf_prefab_cache_stats.start_time%TYPE,
  p_end_time            IN      jtf_prefab_cache_stats.end_time%TYPE,

  p_object_version_number IN OUT NOCOPY  jtf_prefab_cache_stats.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_CACHE_STAT';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_CACHE_STAT;

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

        UPDATE jtf_prefab_cache_stats
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            -- wsh_po_id = p_wsh_po_id,
            -- ca_comp_id = p_ca_comp_id,
            -- jvm_id = p_jvm_id,
            num_cache_miss = num_cache_miss + p_num_cache_miss,
            num_cache_hit = num_cache_hit + p_num_cache_hit,
            num_loader_miss = num_loader_miss + p_num_loader_miss,
            num_invalidate_call = num_invalidate_call + p_num_invalidate_call,
            num_invalidations = num_invalidations + p_num_invalidations,
            num_objects = GREATEST(num_objects, p_num_objects),
            expiration_time = p_expiration_time,
            -- security_group_id = p_security_group_id,
            end_time = p_end_time
        WHERE
            (cache_stat_id = p_cache_stat_id)
		or (jvm_id = 0 and wsh_po_id = p_wsh_po_id and ca_comp_id = p_ca_comp_id);


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
                ROLLBACK TO UPDATE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_CACHE_STAT;

procedure DELETE_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CACHE_STAT';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CACHE_STAT;

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

        UPDATE jtf_prefab_cache_stats
        SET end_time = GREATEST(expiration_time, sysdate), num_objects = 0
        WHERE expiration_time < sysdate and
              end_time < start_time;

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
                ROLLBACK TO DELETE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CACHE_STAT;


procedure RESET_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,
  p_wsh_po_id           IN      NUMBER,
  p_ca_comp_id          IN      NUMBER,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'RESET_CACHE_STAT';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT RESET_CACHE_STAT;

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

        DELETE FROM jtf_prefab_cache_stats
        WHERE wsh_po_id = p_wsh_po_id and
              ca_comp_id = p_ca_comp_id and
              expiration_time < sysdate;

        UPDATE jtf_prefab_cache_stats
              SET num_cache_miss = 0, num_cache_hit = 0, num_loader_miss = 0,
              num_invalidate_call = 0, num_invalidations = 0, num_objects = 0,
              start_time = sysdate
        WHERE wsh_po_id = p_wsh_po_id and
              ca_comp_id = p_ca_comp_id;

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
                ROLLBACK TO RESET_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RESET_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO RESET_CACHE_STAT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END RESET_CACHE_STAT;


PROCEDURE INSERT_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        OUT  NOCOPY   jtf_prefab_ca_filters_b.ca_filter_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_filters_b.application_id%TYPE,
  p_ca_filter_name      IN      jtf_prefab_ca_filters_b.ca_filter_name%TYPE,
  p_description         IN      jtf_prefab_ca_filters_tl.description%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_CA_FILTER';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ca_filters_b_s.NEXTVAL from dual;
        CURSOR host_apps_cursor IS
          SELECT host_app_id
          FROM jtf_prefab_host_apps
          WHERE application_id = p_application_id;
        l_host_app_id           NUMBER;
        l_ha_filter_id            NUMBER;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_CA_FILTER;

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
   	FETCH sequence_cursor INTO p_ca_filter_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        JTF_PREFAB_CA_FILTERS_PKG.INSERT_ROW(p_ca_filter_id,
                                             p_ca_filter_name,
                                             p_application_id,
                                             NULL,
                                             p_object_version_number,
                                             p_description,
                                             SYSDATE,
                                             G_USER_ID,
                                             SYSDATE,
                                             G_USER_ID,
                                             G_LOGIN_ID);

        -- for each application/host pair that the filter belongs to,
        -- add a row to ha_filters

        OPEN host_apps_cursor;
        FETCH host_apps_cursor INTO l_host_app_id;

        WHILE host_apps_cursor%FOUND LOOP
          JTF_PREFAB_CACHE_PUB.INSERT_HA_FILTER(p_api_version,
                                                p_init_msg_list,
                                                p_commit,
                                                l_ha_filter_id,
                                                l_host_app_id,
                                                p_ca_filter_id,
                                                't',
                                                p_object_version_number,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data);
          FETCH host_apps_cursor INTO l_host_app_id;
        END LOOP;

        CLOSE host_apps_cursor;

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
                ROLLBACK TO INSERT_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_CA_FILTER;

PROCEDURE UPDATE_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_filters_b.ca_filter_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_filters_b.application_id%TYPE,
  p_ca_filter_name      IN      jtf_prefab_ca_filters_b.ca_filter_name%TYPE,
  p_description         IN      jtf_prefab_ca_filters_tl.description%TYPE,

  p_object_version_number IN OUT NOCOPY jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_CA_FILTER';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_CA_FILTER;

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

        JTF_PREFAB_CA_FILTERS_PKG.UPDATE_ROW(p_ca_filter_id,
                                             p_ca_filter_name,
                                             p_application_id,
                                             NULL,
                                             p_object_version_number,
                                             p_description,
                                             SYSDATE,
                                             G_USER_ID,
                                             G_LOGIN_ID);

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
                ROLLBACK TO UPDATE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_CA_FILTER;

procedure DELETE_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_filters_b.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CA_FILTER';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CA_FILTER;

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

        JTF_PREFAB_CA_FILTERS_PKG.DELETE_ROW(p_ca_filter_id);

        JTF_PREFAB_CACHE_PUB.DELETE_HA_FILTERS_F_CA_FILTER(p_api_version,
                                                             p_init_msg_list,
                                                             p_commit,
                                                             p_ca_filter_id,
                                                             p_object_version_number,
                                                             x_return_status,
                                                             x_msg_count,
                                                             x_msg_data);
        JTF_PREFAB_CACHE_PUB.DELETE_CA_FL_RESP(p_api_version,
                                               p_init_msg_list,
                                               p_commit,
                                               p_ca_filter_id,
                                               p_object_version_number,
                                               x_return_status,
                                               x_msg_count,
                                               x_msg_data);
        JTF_PREFAB_CACHE_PUB.DELETE_CA_FL_LANG(p_api_version,
                                               p_init_msg_list,
                                               p_commit,
                                               p_ca_filter_id,
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
                ROLLBACK TO DELETE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CA_FILTER;

PROCEDURE INSERT_HA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_filter_id        OUT  NOCOPY   jtf_prefab_ha_filters.ha_filter_id%TYPE,
  p_host_app_id         IN      jtf_prefab_ha_filters.host_app_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ha_filters.ca_filter_id%TYPE,
  p_cache_filter_enabled_flag IN jtf_prefab_ha_filters.cache_filter_enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_HA_FILTER';
        l_api_version           NUMBER  := p_api_version;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ha_filters_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_HA_FILTER;

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
   	FETCH sequence_cursor INTO p_ha_filter_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_ha_filters (ha_filter_id,
                                           object_version_number,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           -- security_group_id,
                                           host_app_id,
                                           ca_filter_id,
                                           cache_filter_enabled_flag)
        VALUES (p_ha_filter_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_host_app_id,
                p_ca_filter_id,
                p_cache_filter_enabled_flag);

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
                ROLLBACK TO INSERT_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_HA_FILTER;

PROCEDURE UPDATE_HA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_filter_id        IN      jtf_prefab_ha_filters.ha_filter_id%TYPE,
  p_cache_filter_enabled_flag IN jtf_prefab_ha_filters.cache_filter_enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_HA_FILTER';
        l_api_version           NUMBER  := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_HA_FILTER;

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

        UPDATE jtf_prefab_ha_filters
        SET object_version_number = p_object_version_number,
            last_updated_by = G_USER_ID,
            last_update_date = SYSDATE,
            last_update_login = G_LOGIN_ID,
            cache_filter_enabled_flag = p_cache_filter_enabled_flag
        WHERE ha_filter_id = p_ha_filter_id;

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
                ROLLBACK TO UPDATE_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO UPDATE_HA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END UPDATE_HA_FILTER;

procedure DELETE_HA_FILTERS_F_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_ha_filters.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HA_FILTERS_F_HOST_APP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HA_FILTERS_F_HOST_APP;

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

        DELETE FROM jtf_prefab_ha_filters
        WHERE host_app_id = p_host_app_id;

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
                ROLLBACK TO DELETE_HA_FILTERS_F_HOST_APP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HA_FILTERS_F_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HA_FILTERS_F_HOST_APP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HA_FILTERS_F_HOST_APP;

procedure DELETE_HA_FILTERS_F_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ha_filters.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_HA_FILTERS_F_CA_FILTER';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_HA_FILTERS_F_CA_FILTER;

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

        DELETE FROM jtf_prefab_ha_filters
        WHERE ca_filter_id = p_ca_filter_id;

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
                ROLLBACK TO DELETE_HA_FILTERS_F_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_HA_FILTERS_F_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_HA_FILTERS_F_CA_FILTER;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_HA_FILTERS_F_CA_FILTER;

PROCEDURE INSERT_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_fl_resp_id       OUT  NOCOPY   jtf_prefab_ca_fl_resps.ca_fl_resp_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_ca_fl_resps.responsibility_id%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_CA_FL_RESP';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ca_fl_resps_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_CA_FL_RESP;

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
   	FETCH sequence_cursor INTO p_ca_fl_resp_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_ca_fl_resps(ca_fl_resp_id,
                                           object_version_number,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           -- security_group_id,
                                           ca_filter_id,
                                           responsibility_id)
        VALUES (p_ca_fl_resp_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_ca_filter_id,
                p_responsibility_id);

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
                ROLLBACK TO INSERT_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_CA_FL_RESP;

procedure DELETE_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id           IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CA_FL_RESP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CA_FL_RESP;

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

        DELETE FROM jtf_prefab_ca_fl_resps
        WHERE ca_filter_id = p_ca_filter_id;

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
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CA_FL_RESP;

procedure DELETE_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_ca_fl_resps.responsibility_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CA_FL_RESP';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CA_FL_RESP;

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

        DELETE FROM jtf_prefab_ca_fl_resps
        WHERE ca_filter_id = p_ca_filter_id
        AND   responsibility_id = p_responsibility_id;

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
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CA_FL_RESP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CA_FL_RESP;

PROCEDURE INSERT_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_fl_lang_id       OUT  NOCOPY   jtf_prefab_ca_fl_langs.ca_fl_lang_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,
  p_language_code       IN      jtf_prefab_ca_fl_langs.language_code%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        -- local variables --
        l_api_name              CONSTANT VARCHAR2(30)   := 'INSERT_CA_FL_LANG';
        l_api_version           NUMBER  := p_api_version;
        l_row_id                VARCHAR2(255) := NULL;

        CURSOR sequence_cursor IS
          SELECT jtf_prefab_ca_fl_langs_s.NEXTVAL from dual;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT INSERT_CA_FL_LANG;

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
   	FETCH sequence_cursor INTO p_ca_fl_lang_id;
   	CLOSE sequence_cursor;
        p_object_version_number := 1;

        INSERT INTO jtf_prefab_ca_fl_langs(ca_fl_lang_id,
                                           object_version_number,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           -- security_group_id,
                                           ca_filter_id,
                                           language_code)
        VALUES (p_ca_fl_lang_id,
                p_object_version_number,
                G_USER_ID,
                SYSDATE,
                G_USER_ID,
                SYSDATE,
                G_LOGIN_ID,
                -- NULL,
                p_ca_filter_id,
                p_language_code);

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
                ROLLBACK TO INSERT_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO INSERT_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO INSERT_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END INSERT_CA_FL_LANG;

procedure DELETE_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id           IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CA_FL_LANG';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CA_FL_LANG;

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

        DELETE FROM jtf_prefab_ca_fl_langs
        WHERE ca_filter_id = p_ca_filter_id;

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
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CA_FL_LANG;

procedure DELETE_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,
  p_language_code       IN      jtf_prefab_ca_fl_langs.language_code%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CA_FL_LANG';
        l_api_version           CONSTANT NUMBER := p_api_version;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT DELETE_CA_FL_LANG;

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

        DELETE FROM jtf_prefab_ca_fl_langs
        WHERE ca_filter_id = p_ca_filter_id
        AND   language_code = p_language_code;

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
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

        WHEN OTHERS THEN
                ROLLBACK TO DELETE_CA_FL_LANG;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data );

END DELETE_CA_FL_LANG;

END JTF_PREFAB_CACHE_PUB;

/
