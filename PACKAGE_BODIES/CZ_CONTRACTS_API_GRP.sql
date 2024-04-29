--------------------------------------------------------
--  DDL for Package Body CZ_CONTRACTS_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_CONTRACTS_API_GRP" AS
/*	$Header: czgconab.pls 120.1 2008/04/03 14:22:54 skudryav ship $		*/
--------------------------------------------------------------------------------

G_INCOMPATIBLE_API   EXCEPTION;
G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'cz_contracts_api_grp';

--------------------------------------------------------------------------------
FUNCTION rp_folder_exists (p_api_version    IN NUMBER,
                           p_encl_folder_id IN NUMBER,
                           p_rp_folder_id   IN NUMBER) RETURN BOOLEAN
IS
 x_folder_exists BOOLEAN := FALSE;
BEGIN
  x_folder_exists:=cz_modeloperations_pub.rp_folder_exists(p_api_version
                                                          ,p_encl_folder_id
                                                          ,p_rp_folder_id);
  RETURN x_folder_exists;
END rp_folder_exists;
--------------------------------------------------------------------------------
PROCEDURE create_rp_folder(p_api_version          IN  NUMBER
                          ,p_encl_folder_id       IN  CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,p_new_folder_name      IN  CZ_RP_ENTRIES.NAME%TYPE
                          ,p_folder_desc          IN  CZ_RP_ENTRIES.DESCRIPTION%TYPE
                          ,p_folder_notes         IN  CZ_RP_ENTRIES.NOTES%TYPE
                          ,x_new_folder_id        OUT NOCOPY  CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2
                          )
IS
BEGIN
 cz_modeloperations_pub.create_rp_folder(p_api_version
                                        ,p_encl_folder_id
                                        ,p_new_folder_name
                                        ,p_folder_desc
                                        ,p_folder_notes
                                        ,x_new_folder_id
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
END create_rp_folder;
--------------------------------------------------------------------------------
PROCEDURE import_generic(p_api_version      IN  NUMBER
                        ,p_run_id           IN  NUMBER
                        ,p_rp_folder_id     IN  NUMBER
                        ,x_run_id           OUT NOCOPY NUMBER
                        ,x_status           OUT NOCOPY NUMBER)
IS
BEGIN

 cz_imp_ps_node.gContractsModel := TRUE;  /* cnd_devl_project() checks this to allow seeded models */
 cz_modeloperations_pub.import_generic(p_api_version
                                       ,p_run_id
                                       ,p_rp_folder_id
                                       ,x_run_id
                                       ,x_status);
 cz_imp_ps_node.gContractsModel := FALSE;
EXCEPTION
  WHEN OTHERS THEN
    cz_imp_ps_node.gContractsModel := FALSE;
    RAISE;
END import_generic;
--------------------------------------------------------------------------------
PROCEDURE delete_model(p_api_version          IN  NUMBER
                      ,p_model_id             IN  NUMBER
                      ,p_orig_sys_ref         IN  VARCHAR2
                      ,x_return_status        OUT NOCOPY  VARCHAR2
                      ,x_msg_count            OUT NOCOPY  NUMBER
                      ,x_msg_data             OUT NOCOPY  VARCHAR2)
IS

 l_api_version  CONSTANT NUMBER := 1.0;
 l_api_name     CONSTANT VARCHAR2(30) := 'delete_model';
 l_dummy_nbr    NUMBER;

BEGIN

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  -- check for valid model id and orig sys ref
  BEGIN
    SELECT 1 into l_dummy_nbr
    FROM cz_devl_projects
    WHERE devl_project_id = p_model_id
    AND orig_sys_ref = p_orig_sys_ref
    AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := CZ_UTILS.GET_TEXT('CZ_MODEL_NOT_FOUND');
      x_msg_count := 1;
      RAISE FND_API.G_EXC_ERROR;
  END;

  cz_developer_utils_pvt.delete_model(p_model_id
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_model;

--------------------------------------------------------------------------------

PROCEDURE create_publication_request (
				  p_api_version  IN NUMBER,
				  p_model_id         IN NUMBER,
				  p_ui_def_id        IN NUMBER,
				  p_publication_mode IN VARCHAR2,
				  p_server_id        IN NUMBER,
				  p_appl_id_tbl      IN t_ref,
				  p_usg_id_tbl       IN t_ref,
				  p_lang_tbl         IN t_lang_code,
				  p_start_date       IN DATE,
				  p_end_date         IN DATE,
				  x_publication_id   OUT NOCOPY NUMBER,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_msg_count        OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2
				 )
IS
 l_appl_id_tbl   cz_pb_mgr.t_ref;
 l_usg_id_tbl    cz_pb_mgr.t_ref;
 l_lang_tbl      cz_pb_mgr.t_lang_code;
BEGIN
    FOR i IN p_appl_id_tbl.FIRST..p_appl_id_tbl.LAST LOOP
      l_appl_id_tbl(i) := p_appl_id_tbl(i);
      l_usg_id_tbl(i) := p_usg_id_tbl(i);
      l_lang_tbl(i) := p_lang_tbl(i);
    END LOOP;
    cz_pb_mgr.create_publication_request (p_model_id,
				  p_ui_def_id,
				  p_publication_mode,
				  p_server_id,
				  l_appl_id_tbl,
				  l_usg_id_tbl,
				  l_lang_tbl,
				  p_start_date,
				  p_end_date,
				  x_publication_id,
				  x_return_status,
				  x_msg_count,
				  x_msg_data);
 EXCEPTION
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_PB_CREATE_PB_REQUEST_ERR');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
END create_publication_request;

--------------------
PROCEDURE EDIT_PUBLICATION(p_api_version     IN NUMBER,
                           p_publicationId   IN NUMBER,
                           p_applicationId   IN  OUT  NOCOPY VARCHAR2,
                           p_languageId	   IN  OUT  NOCOPY VARCHAR2,
                           p_usageId         IN  OUT  NOCOPY VARCHAR2,
                           p_startDate	   IN	      DATE,
                           p_disableDate     IN	      DATE,
                           p_publicationMode IN       VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2)
IS

BEGIN
    cz_pb_mgr.edit_publication (p_publicationId,
                                p_applicationId,
				p_languageId,
                                p_usageId,
				p_startDate,
				p_disableDate,
				p_publicationMode,
				x_return_status,
				x_msg_count,
				x_msg_data);
EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_EDIT_PUB_ERR');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
 END EDIT_PUBLICATION;

-----------------------------------
PROCEDURE EDIT_PUBLICATION(p_api_version     IN NUMBER,
                           p_publicationId   IN NUMBER,
                           p_applicationId   IN  OUT  NOCOPY t_ref,
                           p_languageId	   IN  OUT  NOCOPY t_lang_code,
                           p_usageId         IN  OUT  NOCOPY t_ref,
                           p_startDate	   IN	      DATE,
                           p_disableDate     IN	      DATE,
                           p_publicationMode IN       VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_lang_tbl  cz_pb_mgr.t_lang_code;
l_usg_tbl   cz_pb_mgr.t_ref;
l_appl_tbl  cz_pb_mgr.t_ref;


BEGIN
l_lang_tbl.DELETE;
l_usg_tbl.DELETE;
l_appl_tbl.DELETE;

IF (p_applicationId.COUNT > 0) THEN
	FOR I IN p_applicationId.FIRST..p_applicationId.LAST
	LOOP
		l_appl_tbl(i) := p_applicationId(i);
	END LOOP;
END IF;

IF (p_languageId.COUNT > 0) THEN
	FOR I IN p_languageId.FIRST..p_languageId.LAST
	LOOP
	    l_lang_tbl(i) := p_languageId(i);
      END LOOP;
END IF;

IF (p_usageId.COUNT > 0) THEN
	FOR I IN p_usageId.FIRST..p_usageId.LAST
	LOOP
		l_usg_tbl(i) := p_usageId(i);
      END LOOP;
END IF;

cz_pb_mgr.edit_publication (p_publicationId,
                                l_appl_tbl,
					  l_lang_tbl,
                                l_usg_tbl,
				  	  p_startDate,
					p_disableDate,
					p_publicationMode,
					x_return_status,
					x_msg_count,
					x_msg_data);
EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_EDIT_PUB_ERR');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			     p_data  => x_msg_data);
 END EDIT_PUBLICATION;

----------------------------------
PROCEDURE DELETE_PUBLICATION(p_api_version     IN NUMBER,
                             publicationId   IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2
                            )
IS

BEGIN
   cz_pb_mgr.delete_publication(publicationId,x_return_status,x_msg_count,x_msg_data);
EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CZ', 'CZ_DELETE_PUB_ERR');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
			           p_data  => x_msg_data);
END DELETE_PUBLICATION;
----------------------------------
PROCEDURE delete_ui_def(p_api_version              IN   NUMBER,
                        p_ui_def_id                IN   NUMBER,
                        x_return_status            OUT  NOCOPY   VARCHAR2,
                        x_msg_count                OUT  NOCOPY   NUMBER,
                        x_msg_data                 OUT  NOCOPY   VARCHAR2
                        ) IS
 l_api_name      CONSTANT VARCHAR2(30) := 'delete_ui_def';
 l_api_version   CONSTANT NUMBER := 1.0;

BEGIN
 -- should initialized the fnd_msg_pub?
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE G_INCOMPATIBLE_API;
 END IF;

 cz_developer_utils_pvt.delete_ui_def(p_ui_def_id,
                                      x_return_status,
                                      x_msg_count,
                                      x_msg_data);
EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
    FND_MSG_PUB.add;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, x_msg_data);
END delete_ui_def;

PROCEDURE generate_logic(p_api_version      IN            NUMBER,
                         p_devl_project_id  IN            NUMBER,
                         x_run_id           OUT  NOCOPY   NUMBER,
                         x_return_status    OUT  NOCOPY   VARCHAR2,
                         x_msg_count        OUT  NOCOPY   NUMBER,
                         x_msg_data         OUT  NOCOPY   VARCHAR2) IS

 l_api_name      CONSTANT VARCHAR2(30) := 'generate_logic';
 l_api_version   CONSTANT NUMBER := 1.0;
 l_status        NUMBER;

BEGIN

 x_msg_count := 0;
 fnd_msg_pub.initialize;
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE G_INCOMPATIBLE_API;
 END IF;

 cz_modeloperations_pub.generate_logic(p_api_version     => 1.0,
                                       p_devl_project_id => p_devl_project_id,
                                       x_run_id          => x_run_id,
                                       x_status          => l_status);

 IF (x_run_id <> 0) THEN
   FOR i IN (SELECT message FROM cz_db_logs
             WHERE run_id = x_run_id)
   LOOP
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name,i.message);
      x_msg_data := i.message;
      x_msg_count := x_msg_count + 1;
   END LOOP;
 END IF;
 IF (l_status = cz_modeloperations_pub.G_STATUS_ERROR) THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 END IF;
EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
    FND_MSG_PUB.add;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, x_msg_data);
END generate_logic;

PROCEDURE publish_model(p_api_version      IN            NUMBER,
                        p_publication_id   IN            NUMBER,
                        x_run_id           OUT  NOCOPY   NUMBER,
                        x_return_status    OUT  NOCOPY   VARCHAR2,
                        x_msg_count        OUT  NOCOPY   NUMBER,
                        x_msg_data         OUT  NOCOPY   VARCHAR2) IS

 l_api_name      CONSTANT VARCHAR2(30) := 'publish_model';
 l_api_version   CONSTANT NUMBER := 1.0;
 l_status        NUMBER;

BEGIN

 x_msg_count := 0;
 fnd_msg_pub.initialize;
 IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE G_INCOMPATIBLE_API;
 END IF;

 cz_modeloperations_pub.publish_model(p_api_version    => 1.0,
                                      p_publication_id => p_publication_id,
                                      x_run_id         => x_run_id,
                                      x_status         => l_status);

 IF (x_run_id <> 0) THEN
   FOR i IN (SELECT message FROM cz_db_logs
             WHERE run_id = x_run_id)
   LOOP
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name,i.message);
      x_msg_count := x_msg_count + 1;
      x_msg_data := i.message;
   END LOOP;
 END IF;
 IF (l_status = cz_modeloperations_pub.G_STATUS_ERROR) THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 END IF;
EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
    FND_MSG_PUB.add;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name, x_msg_data);
END publish_model;
-------------------------------------------------------------------------------

PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2) IS
BEGIN
 -- fix for bug 6905101 ; skudryav 01-apr-2008
 FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS
           WHERE devl_project_id=p_devl_project_id AND
                 ui_style='7' AND
                 deleted_flag='0')
 LOOP
    cz_modeloperations_pub.refresh_jrad_ui(p_api_version   => 1.0,
                                           p_ui_def_id     => i.ui_def_id,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data);
    -- return in case of failure
    IF x_return_status IN(FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RETURN;
    END IF;
 END LOOP;
 cz_modeloperations_pub.create_jrad_ui(p_api_version        => 1.0,
                                       p_devl_project_id    => p_devl_project_id,
                                       p_show_all_nodes     => p_show_all_nodes,
                                       p_master_template_id => p_master_template_id,
                                       p_create_empty_ui    => p_create_empty_ui,
                                       x_ui_def_id          => x_ui_def_id,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data);
END create_jrad_ui;

END CZ_contracts_api_grp;

/
