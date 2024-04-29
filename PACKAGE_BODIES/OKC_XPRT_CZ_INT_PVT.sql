--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_CZ_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_CZ_INT_PVT" AS
/* $Header: OKCVXCZINTB.pls 120.0 2005/05/25 23:04:21 appldev noship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_CZ_INT_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=510; -- OKC Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;


---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE import_generic
(
 p_api_version      IN  NUMBER,
 p_run_id           IN  NUMBER,
 p_rp_folder_id     IN  NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'import_generic';
l_cz_return_status         NUMBER;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.import_generic with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_run_id : '||p_run_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_rp_folder_id : '||p_rp_folder_id);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.import_generic with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_run_id:  '||p_run_id);
       fnd_file.put_line(FND_FILE.LOG,'p_rp_folder_id:  '||p_rp_folder_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Call the CZ Generic Import API
      CZ_CONTRACTS_API_GRP.import_generic
       (
        p_api_version          => l_api_version,
        p_run_id               => p_run_id,
        x_run_id               => x_run_id,
        p_rp_folder_id         => p_rp_folder_id,
        x_status               => l_cz_return_status
       );

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.import_generic ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_status : '||l_cz_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_run_id : '||x_run_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.import_generic');
       fnd_file.put_line(FND_FILE.LOG,'x_status:  '||l_cz_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_run_id:  '||x_run_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


     IF l_cz_return_status = G_CZ_STATUS_SUCCESS THEN
        x_return_status  := FND_API.G_RET_STS_SUCCESS;
     ELSIF l_cz_return_status = G_CZ_STATUS_ERROR OR
           l_cz_return_status = G_CZ_STATUS_WARNING THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
     ELSE
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
     END IF;

-- Add Error Handling routine to check if all the records were successfully imported
-- check if for the x_run_id all the records in the import tables have status = 'OK'
-- also check the cz_xfr_run_results table for the entity
-- error details in cz_db_logs


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END import_generic;


---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE create_rp_folder
(
 p_api_version      IN  NUMBER,
 p_encl_folder_id   IN NUMBER,
 p_new_folder_name  IN VARCHAR2,
 p_folder_desc      IN VARCHAR2,
 p_folder_notes     IN VARCHAR2,
 x_new_folder_id    OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'create_rp_folder';
l_cz_return_status         VARCHAR2(30);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.create_rp_folder with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_encl_folder_id : '||p_encl_folder_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_new_folder_name : '||p_new_folder_name);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.create_rp_folder with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_encl_folder_id:  '||p_encl_folder_id);
       fnd_file.put_line(FND_FILE.LOG,'p_new_folder_name:  '||p_new_folder_name);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


-- Call the CZ Generic Import API
      CZ_CONTRACTS_API_GRP.create_rp_folder
       (
        p_api_version        => l_api_version,
        p_encl_folder_id     => p_encl_folder_id,
        p_new_folder_name    => p_new_folder_name,
        p_folder_desc        => p_folder_desc,
        p_folder_notes       => p_folder_notes,
        x_new_folder_id      => x_new_folder_id,
        x_return_status      => l_cz_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
       );


    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.create_rp_folder');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_new_folder_id : '||x_new_folder_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||l_cz_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.create_rp_folder');
       fnd_file.put_line(FND_FILE.LOG,'x_status:  '||l_cz_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_new_folder_id:  '||x_new_folder_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


    -- For the above call , l_cz_return_status is a string 'S' , 'E' or 'U'
    -- so directly assing the same to x_return_status
       x_return_status := l_cz_return_status;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_rp_folder;



PROCEDURE delete_ui_def
(
 p_api_version      IN  NUMBER,
 p_ui_def_id        IN  NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) IS


l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'delete_ui_def';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.delete_ui_def with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_ui_def_id : '||p_ui_def_id);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.delete_ui_def with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_ui_def_id:  '||p_ui_def_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Call the CZ delete_ui_def API
      CZ_contracts_api_grp.delete_ui_def
       (
        p_api_version          => l_api_version,
	   p_ui_def_id            => p_ui_def_id,
	   x_return_status        => x_return_status,
	   x_msg_count            => x_msg_count,
	   x_msg_data             => x_msg_data
	  );


    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.delete_ui_def ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.delete_ui_def');
       fnd_file.put_line(FND_FILE.LOG,'x_return_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_count:  '||x_msg_count);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_data:  '||x_msg_data);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;


EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END delete_ui_def;


PROCEDURE create_jrad_ui
(
 p_api_version        IN  NUMBER,
 p_devl_project_id    IN  NUMBER,
 p_show_all_nodes     IN  VARCHAR2,
 p_master_template_id IN  NUMBER,
 p_create_empty_ui    IN  VARCHAR2,
 x_ui_def_id          OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_msg_data	       OUT NOCOPY VARCHAR2,
 x_msg_count	       OUT NOCOPY NUMBER
) IS


l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'create_jrad_ui';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.create_jrad_ui with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_devl_project_id : '||p_devl_project_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_show_all_nodes : '||p_show_all_nodes);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_master_template_id : '||p_master_template_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_create_empty_ui : '||p_create_empty_ui);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.create_jrad_ui with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_devl_project_id:  '||p_devl_project_id);
       fnd_file.put_line(FND_FILE.LOG,'p_show_all_nodes:  '||p_show_all_nodes);
       fnd_file.put_line(FND_FILE.LOG,'p_master_template_id:  '||p_master_template_id);
       fnd_file.put_line(FND_FILE.LOG,'p_create_empty_ui:  '||p_create_empty_ui);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Call the CZ create_jrad_ui API
	 CZ_CONTRACTS_API_GRP.create_jrad_ui
       (
        p_api_version          => l_api_version,
        p_devl_project_id      => p_devl_project_id,
        p_show_all_nodes       => p_show_all_nodes,
        p_master_template_id   => p_master_template_id,
        p_create_empty_ui      => p_create_empty_ui,
	   x_ui_def_id            => x_ui_def_id,
	   x_return_status        => x_return_status,
	   x_msg_count            => x_msg_count,
	   x_msg_data             => x_msg_data
	  );

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.create_jrad_ui ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_ui_def_id : '||x_ui_def_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.create_jrad_ui');
       fnd_file.put_line(FND_FILE.LOG,'x_return_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_ui_def_id:  '||x_ui_def_id);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_count:  '||x_msg_count);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_data:  '||x_msg_data);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;



EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_jrad_ui;


PROCEDURE generate_logic
(
 p_api_version      IN  NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_devl_project_id  IN  NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    	OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'generate_logic';

l_rec_number              NUMBER:= 0;

CURSOR csr_db_logs(p_run_id IN NUMBER) IS
SELECT logtime,
       caller,
       message
FROM cz_db_logs
WHERE run_id = p_run_id
ORDER BY logtime;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.generate_logic with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_devl_project_id : '||p_devl_project_id);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.generate_logic with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_devl_project_id:  '||p_devl_project_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Call the CZ Generic Import API
    /*
       CZ will return Success for generate_logic if there were warnings
	  In case of warnings x_run_id will NOT be 0 and x_msg_data will have data
	  from cz_db_logs
    */
      CZ_CONTRACTS_API_GRP.generate_logic
       (
        p_api_version          => l_api_version,
        p_devl_project_id      => p_devl_project_id,
        x_run_id               => x_run_id,
	   x_return_status        => x_return_status,
	   x_msg_count            => x_msg_count,
	   x_msg_data             => x_msg_data

       );

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.generate_logic ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_run_id : '||x_run_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.generate_logic');
       fnd_file.put_line(FND_FILE.LOG,'x_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_run_id:  '||x_run_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


       -- bug 4081597 If any errors happens put details in logfile
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) OR (x_return_status = G_RET_STS_ERROR) THEN
         FOR csr_db_logs_rec IN csr_db_logs(p_run_id => x_run_id)
           LOOP
             l_rec_number := l_rec_number +1;
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'*************** Record   :  '||l_rec_number||'  **************');
             fnd_file.put_line(FND_FILE.LOG,'Logtime  :  '||csr_db_logs_rec.logtime);
             fnd_file.put_line(FND_FILE.LOG,'Caller   :  '||csr_db_logs_rec.caller);
             fnd_file.put_line(FND_FILE.LOG,'Message  :  '||csr_db_logs_rec.message);
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');
          END LOOP;
       END IF;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END generate_logic;

-------------------------------------------------------------------------------

PROCEDURE delete_publication
(
 p_api_version      IN  NUMBER,
 p_init_msg_lst     IN  VARCHAR2,
 p_publication_id   IN  NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'delete_publication';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.delete_publication with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_publication_id : '||p_publication_id);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.delete_publication with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_publication_id:  '||p_publication_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Initialize the CZ parameter values

      CZ_CONTRACTS_API_GRP.delete_publication
       (
        p_api_version          => l_api_version,
        publicationid          => p_publication_id,
        x_return_status        => x_return_status,
        x_msg_count      	   => x_msg_count,
        x_msg_data             => x_msg_data
       );

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.delete_publication ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_count : '||x_msg_count);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_data : '||x_msg_data);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.delete_publication');
       fnd_file.put_line(FND_FILE.LOG,'x_return_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_count:  '||x_msg_count);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_data:  '||x_msg_data);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END delete_publication;


PROCEDURE create_publication_request
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_devl_project_id  IN NUMBER,
 p_ui_def_id        IN NUMBER,
 p_publication_mode IN VARCHAR2,
 x_publication_id   OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) IS

CURSOR csr_get_publication_dtl IS
SELECT publication_id
FROM cz_model_publications
WHERE model_id = p_devl_project_id
AND deleted_flag = '0'
AND publication_mode ='t';

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'create_publication_request';
l_cz_return_status         NUMBER;
l_appl_id_tbl              CZ_CONTRACTS_API_GRP.t_ref;
l_usg_id_tbl               CZ_CONTRACTS_API_GRP.t_ref;
l_lang_tbl                 CZ_CONTRACTS_API_GRP.t_lang_code;
l_server_id                NUMBER;
l_start_date 			  DATE;
l_end_date			  DATE;
l_publication_id 		  NUMBER;
i                          BINARY_INTEGER;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Input parameters for the CZ api
     l_server_id      := '0'; -- Check with CZ
	l_appl_id_tbl(1) := 510; -- OKC App Id
	l_usg_id_tbl(1)  := -1; -- Any usage


	-- Get all installed languages
	OPEN csr_installed_languages;
	    FETCH csr_installed_languages BULK COLLECT INTO l_lang_tbl;
	CLOSE csr_installed_languages;


	l_start_date     := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
	l_end_date	  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;


      -- Add code for initialization of applicability parameters

      -- Call the CZ Delete publication api for deleting any existing test publication
      OPEN csr_get_publication_dtl;
	   LOOP
          FETCH csr_get_publication_dtl INTO l_publication_id;
		EXIT WHEN csr_get_publication_dtl%NOTFOUND;
	         -- Added code for deleting test publication
    	          delete_publication
		     (
		      p_api_version           => l_api_version,
		      p_init_msg_lst          => p_init_msg_lst,
		      p_publication_id        => l_publication_id,
		      x_return_status         => x_return_status,
		      x_msg_count      	      => x_msg_count,
		      x_msg_data              => x_msg_data
		      );

                 --- If any errors happen abort API
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

	   END LOOP;
	 CLOSE csr_get_publication_dtl;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.create_publication_request with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_model_id : '||p_devl_project_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_ui_def_id : '||p_ui_def_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_publication_mode : '||p_publication_mode);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_server_id : '||l_server_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'l_appl_id_tbl(1) : 510');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'l_usg_id_tbl(1) : -1');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_start_date : '||l_start_date);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_end_date : '||l_end_date);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.create_publication_request with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  	'||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_model_id:  		'||p_devl_project_id);
       fnd_file.put_line(FND_FILE.LOG,'p_ui_def_id:  		'||p_ui_def_id);
       fnd_file.put_line(FND_FILE.LOG,'p_publication_mode:  '||p_publication_mode);
       fnd_file.put_line(FND_FILE.LOG,'p_server_id:  		'||l_server_id);
       fnd_file.put_line(FND_FILE.LOG,'l_appl_id_tbl(1) : 510');
       fnd_file.put_line(FND_FILE.LOG,'l_usg_id_tbl(1) : -1');
       fnd_file.put_line(FND_FILE.LOG,'p_start_date:  		'||l_start_date);
       fnd_file.put_line(FND_FILE.LOG,'p_end_date:  		'||l_end_date);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

      -- Add code for initialization of applicability parameters

      -- Call the CZ Generic Import API
      CZ_CONTRACTS_API_GRP.create_publication_request
       (
        p_api_version          	=> l_api_version,
        p_model_id      	    => p_devl_project_id,
        p_ui_def_id             => p_ui_def_id,
        p_publication_mode      => p_publication_mode,
        p_server_id             => l_server_id,
        p_appl_id_tbl           => l_appl_id_tbl,
        p_usg_id_tbl            => l_usg_id_tbl,
        p_lang_tbl      	    => l_lang_tbl,
        p_start_date            => l_start_date,
        p_end_date              => l_end_date,
        x_publication_id      	=> x_publication_id,
        x_return_status         => x_return_status,
        x_msg_count      	    => x_msg_count,
        x_msg_data              => x_msg_data
       );
    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.create_publication_request ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_publication_id : '||x_publication_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_count : '||x_msg_count);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_data : '||x_msg_data);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.create_publication_request');
       fnd_file.put_line(FND_FILE.LOG,'x_return_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_publication_id:  '||x_publication_id);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_count:  '||x_msg_count);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_data:  '||x_msg_data);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_publication_request;



-------------------------------------------------------------------------------
  /*====================================================================+
  Procedure Name : copy_configuration
  Description    : Calls CZ's copy_configuration API.

  +====================================================================*/
  PROCEDURE copy_configuration(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_new_config_flag              IN VARCHAR2,
    x_new_config_header_id         OUT NOCOPY NUMBER,
    x_new_config_rev_nbr           OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

  IS

     l_api_name CONSTANT VARCHAR2(30) := 'copy_configuration_auto';
     l_package_procedure VARCHAR2(60);
     l_x_config_header_id NUMBER;
     l_x_config_rev_nbr NUMBER;
     l_x_error_message VARCHAR2(2000);
     l_x_copy_return_status NUMBER;

  BEGIN

  --
  -- Check Debug Value
  --
  l_package_procedure := G_PKG_NAME || '.' || l_api_name;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_api_version : '||p_api_version);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_init_msg_list : '||p_init_msg_list);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_config_rev_nbr : '||p_config_rev_nbr);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_new_config_flag : '||p_new_config_flag);
  END IF;


    x_return_status :=  G_RET_STS_SUCCESS;

    --
    -- p_config_header_id AND p_config_rev_nbr cannot be NULL
    --
    IF (p_config_header_id is NULL OR p_config_rev_nbr is NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Fix for P1 bug 4090615. Changed from copy_configuration to copy_configuration_auto
	CZ_CF_API.copy_configuration_auto(
                  config_hdr_id       => p_config_header_id,
                  config_rev_nbr      => p_config_rev_nbr,
                  new_config_flag     => 1, -- copy with new config_header_id
                  out_config_hdr_id   => l_x_config_header_id,
                  out_config_rev_nbr  => l_x_config_rev_nbr,
                  error_message       => l_x_error_message,
                  return_value        => l_x_copy_return_status, -- 1 (Success) or 0 (Failure)
                  handle_deleted_flag => 0, -- undelete new config if source config was deleted
                  new_name            => NULL);

    IF (l_x_config_header_id is NULL OR l_x_config_rev_nbr is NULL
        OR l_x_copy_return_status = 0)
    THEN

      IF (l_x_error_message is NOT NULL)
      THEN
        x_msg_data := l_x_error_message;
      ELSE
        x_msg_data := 'OKC_EXPRT_COPY_CONFIG_FAILED';
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_new_config_header_id := l_x_config_header_id;
    x_new_config_rev_nbr := l_x_config_rev_nbr;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: x_new_config_header_id : '||l_x_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: x_new_config_rev_nbr : '||l_x_config_rev_nbr);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: x_return_status  : '||x_return_status);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);
  END copy_configuration;

-------------------------------------------------------------------------------
  /*====================================================================+
  Procedure Name : delete_configuration
  Description    : Calls CZ's delete_configuration API.

  +====================================================================*/
  PROCEDURE delete_configuration(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

  IS

     l_api_name CONSTANT VARCHAR2(30) := 'delete_configuration';
     l_package_procedure VARCHAR2(60);

     l_x_usage_exists NUMBER; -- 1 if configuration usage record exists and
                              -- configuration is not deleted.

     l_x_delete_status NUMBER; -- 1 if delete was successful; otherwise 0
     l_x_error_message VARCHAR2(2000); -- error message if l_x_delete_status = 0

  BEGIN

  --
  -- Check Debug Value
  --
  l_package_procedure := G_PKG_NAME || '.' || l_api_name;
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_api_version : '||p_api_version);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_init_msg_list : '||p_init_msg_list);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_config_rev_nbr : '||p_config_rev_nbr);
  END IF;

    x_return_status :=  G_RET_STS_SUCCESS;

    CZ_CF_API.delete_configuration(
                     config_hdr_id  => p_config_header_id,
                     config_rev_nbr => p_config_rev_nbr,
                     usage_exists   => l_x_usage_exists,
                     error_message  => l_x_error_message,
                     return_value   => l_x_delete_status);

    IF (l_x_delete_status = 0)
    THEN

      IF (l_x_error_message is NOT NULL)
      THEN
        x_msg_data := l_x_error_message;
      ELSE
        x_msg_data := 'OKC_EXPRT_DEL_CONFIG_FAILED';
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: x_return_status  : '||x_return_status);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;


  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

  END delete_configuration;
-------------------------------------------------------------------------------
  /*====================================================================+
  Procedure Name : batch_validate
  Description    : Calls CZ's Validate API and Converts the HTML_PIECES
                   output to LONG for Parsing.

                 Configurator's Output Validation Status:
                 CONFIG_PROCESSED              constant NUMBER :=0;
                 CONFIG_PROCESSED_NO_TERMINATE constant NUMBER :=1;
                 INIT_TOO_LONG                 constant NUMBER :=2;
                 INVALID_OPTION_REQUEST        constant NUMBER :=3;
                 CONFIG_EXCEPTION              constant NUMBER :=4;
                 DATABASE_ERROR                constant NUMBER :=5;
                 UTL_HTTP_INIT_FAILED          constant NUMBER :=6;
                 UTL_HTTP_REQUEST_FAILED       constant NUMBER :=7;
  +====================================================================*/
  PROCEDURE batch_validate(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_cz_xml_init_msg              IN VARCHAR2,
    x_cz_xml_terminate_msg         OUT NOCOPY LONG, -- CZ_CF_API.CFG_OUTPUT_PIECES,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

  IS

     l_api_name CONSTANT VARCHAR2(30) := 'batch_validate';
     l_package_procedure VARCHAR2(60);

     l_cfg_input_list CZ_CF_API.CFG_INPUT_LIST;  -- Not passing any inputs.
                                                 -- Note that CZ's Validate procedure
                                                 -- must be modified to accommodate
                                                 -- inputs from non-BOM applications.
     l_cfg_output_pieces CZ_CF_API.CFG_OUTPUT_PIECES; -- UTL_HTTP.HTML_PIECES
     l_x_validation_status NUMBER; -- See Valid Values in Procedure Header.

     l_rec_index NUMBER;
     l_long_xml LONG;

  BEGIN

     --
     -- Check Debug Value
     --
     l_package_procedure := G_PKG_NAME || '.' || l_api_name;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_api_version : '||p_api_version);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_init_msg_list : '||p_init_msg_list);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_cz_xml_init_msg : '||p_cz_xml_init_msg);
  END IF;

    x_return_status :=  G_RET_STS_SUCCESS;

     IF (p_cz_xml_init_msg is NULL)
     THEN
         x_msg_data := 'OKC_EXPRT_BV_NULL_INIT_MSG';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     CZ_CF_API.VALIDATE(
               config_input_list => l_cfg_input_list,
               init_message      => p_cz_xml_init_msg,
               config_messages   => l_cfg_output_pieces,
               validation_status => l_x_validation_status,
               url               => FND_PROFILE.value('CZ_UIMGR_URL'),
               p_validation_type => CZ_API_PUB.VALIDATE_ORDER);


  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: validation_status : '||l_x_validation_status);
  END IF;



       IF (l_cfg_output_pieces.COUNT > 0 )
       THEN
         l_rec_index := l_cfg_output_pieces.FIRST;
         LOOP
            -- debug log
             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),1,255))));
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),256,255))));
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),512,255))));
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),768,255))));
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),1024,255))));
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '100: cz terminate msg = '||ltrim(rtrim(substr(l_cfg_output_pieces(l_rec_index),1280,255))));
		   END IF; -- debug log

           EXIT WHEN l_rec_index = l_cfg_output_pieces.LAST;
           l_rec_index := l_cfg_output_pieces.NEXT(l_rec_index);
         END LOOP;
       END IF;

     --IF (l_x_validation_status <> 0 OR l_cfg_output_pieces.COUNT <= 0)
     IF (l_cfg_output_pieces.COUNT <= 0)
     THEN

       x_msg_data := 'OKC_EXPRT_BV_VALIDATE_ERROR';

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;


     -- CZ_CF_API.VALIDATE returns the status as a constant in range of
     -- 0 to 8 in which 0 is success

     IF (l_x_validation_status = 1) THEN
        x_msg_data := 'CONFIG_PROCESSED_NO_TERMINATE';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 2) THEN
        x_msg_data := 'INIT_TOO_LONG';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 3) THEN
        x_msg_data := 'INVALID_OPTION_REQUEST';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 4) THEN
        x_msg_data := 'CONFIG_EXCEPTION';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 5) THEN
        x_msg_data := 'DATABASE_ERROR';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 6) THEN
        x_msg_data := 'UTL_HTTP_INIT_FAILED';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 7) THEN
        x_msg_data := 'UTL_HTTP_REQUEST_FAILED';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_x_validation_status = 8) THEN
        x_msg_data := 'INVALID_VALIDATION_TYPE';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF; -- l_x_validation_status <> 0

     --
     -- Convert HTML_PIECES to LONG for parsing
     --
     l_rec_index := l_cfg_output_pieces.FIRST;
     LOOP

        l_long_xml := l_long_xml || l_cfg_output_pieces(l_rec_index);

        EXIT WHEN l_rec_index = l_cfg_output_pieces.LAST;
        l_rec_index := l_cfg_output_pieces.NEXT(l_rec_index);

     END LOOP;

     x_cz_xml_terminate_msg := l_long_xml;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: x_return_status  : '||x_return_status);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;


  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;

  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                END IF;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);
  END batch_validate;

-------------------------------------------------------------------------------

---------------------------------------------------
---------------------------------------------------
--  Procedure: edit_publication
---------------------------------------------------
PROCEDURE edit_publication
(
 p_api_version      IN  NUMBER,
 p_init_msg_lst     IN  VARCHAR2,
 p_publication_id   IN  NUMBER,
 p_publication_mode IN  VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'edit_publication';
l_cz_return_status         NUMBER;

l_applicationId              CZ_CONTRACTS_API_GRP.t_ref;
l_usageId                    CZ_CONTRACTS_API_GRP.t_ref;
l_languageId                 CZ_CONTRACTS_API_GRP.t_lang_code;

l_startdate			DATE;
l_disabledate			   DATE;

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Input parameters for the CZ api
	l_applicationId(1)  := '510'; -- OKC App Id
	l_usageId(1)        := '-1'; -- Any usage

	-- Get all installed languages
	OPEN csr_installed_languages;
	    FETCH csr_installed_languages BULK COLLECT INTO l_languageId;
	CLOSE csr_installed_languages;

	l_startdate      := G_CZ_EPOCH_BEGIN; -- Need to change to CZ_CONTRACTS_API_GRP once available
	l_disabledate    := G_CZ_EPOCH_END; -- Need to change to CZ_CONTRACTS_API_GRP once available

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.edit_publication with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_publication_id : '||p_publication_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_publication_mode : '||p_publication_mode);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_applicationId(1) : 510');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_usageId(1) : -1');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_startdate : '||l_startdate);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_disabledate : '||l_disabledate);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.edit_publication with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_publication_id:  '||p_publication_id);
       fnd_file.put_line(FND_FILE.LOG,'p_publication_mode:  '||p_publication_mode);
       fnd_file.put_line(FND_FILE.LOG,'p_applicationId: 510  ');
       fnd_file.put_line(FND_FILE.LOG,'p_usageId: -1 ');
       fnd_file.put_line(FND_FILE.LOG,'p_startdate:  '||l_startdate);
       fnd_file.put_line(FND_FILE.LOG,'p_disabledate:  '||l_disabledate);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
	   fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Initialize the CZ parameter values


      CZ_CONTRACTS_API_GRP.edit_publication
       (
        p_api_version          => l_api_version,
        p_publicationid        => p_publication_id,
        p_applicationId        => l_applicationId,
        p_languageId           => l_languageId,
        p_usageId              => l_usageId,
        p_startdate            => l_startdate,
        p_disabledate          => l_disabledate,
        p_publicationmode      => p_publication_mode,
        x_return_status        => x_return_status,
        x_msg_count      	   => x_msg_count,
        x_msg_data             => x_msg_data
       );


    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.edit_publication ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_return_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_count : '||x_msg_count);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_msg_data : '||x_msg_data);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.edit_publication');
       fnd_file.put_line(FND_FILE.LOG,'x_return_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_count:  '||x_msg_count);
       fnd_file.put_line(FND_FILE.LOG,'x_msg_data:  '||x_msg_data);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');



-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END edit_publication;


PROCEDURE publish_model
(
 p_api_version      IN  NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_publication_id   IN  NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    	OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'publish_model';

l_rec_number              NUMBER:= 0;

CURSOR csr_db_logs(p_run_id IN NUMBER) IS
SELECT logtime,
       caller,
       message
FROM cz_db_logs
WHERE run_id = p_run_id
ORDER BY logtime;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CONTRACTS_API_GRP.publish_model with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_devl_project_id : '||p_publication_id);
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'Calling CZ_CONTRACTS_API_GRP.publish_model with parameters');
       fnd_file.put_line(FND_FILE.LOG,'p_api_version:  '||l_api_version);
       fnd_file.put_line(FND_FILE.LOG,'p_publication_id:  '||p_publication_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

    -- Call the CZ Generic Import API
    /*
       CZ will return Success for publish_model if there were warnings
	  In case of warnings x_run_id will NOT be 0 and x_msg_data will have data
	  from cz_db_logs
    */
      CZ_CONTRACTS_API_GRP.publish_model
       (
        p_api_version          => l_api_version,
        p_publication_id      => p_publication_id,
        x_run_id               => x_run_id,
	   x_return_status        => x_return_status,
	   x_msg_count            => x_msg_count,
	   x_msg_data             => x_msg_data

       );

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CONTRACTS_API_GRP.publish_model ');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_status : '||x_return_status);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_run_id : '||x_run_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
     END IF;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'After calling CZ_CONTRACTS_API_GRP.publish_model');
       fnd_file.put_line(FND_FILE.LOG,'x_status:  '||x_return_status);
       fnd_file.put_line(FND_FILE.LOG,'x_run_id:  '||x_run_id);
       fnd_file.put_line(FND_FILE.LOG,'Current Time :  '||to_char(sysdate,'dd mm yyyy HH:MI:SS'));
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

       -- bug 4081597 If any errors happens put details in logfile
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) OR (x_return_status = G_RET_STS_ERROR) THEN
         FOR csr_db_logs_rec IN csr_db_logs(p_run_id => x_run_id)
           LOOP
             l_rec_number := l_rec_number +1;
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'*************** Record   :  '||l_rec_number||'  **************');
             fnd_file.put_line(FND_FILE.LOG,'Logtime  :  '||csr_db_logs_rec.logtime);
             fnd_file.put_line(FND_FILE.LOG,'Caller   :  '||csr_db_logs_rec.caller);
             fnd_file.put_line(FND_FILE.LOG,'Message  :  '||csr_db_logs_rec.message);
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');
          END LOOP;
       END IF;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END publish_model;



PROCEDURE publication_for_product
(
 p_api_version                  IN NUMBER,
 p_init_msg_lst                 IN VARCHAR2,
 p_product_key                  IN VARCHAR2,
 p_usage_name                   IN VARCHAR2,
 p_publication_mode             IN VARCHAR2,
 p_effective_date               IN DATE,
 x_publication_id               OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'publication_for_product';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_lst ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'Calling CZ_CF_API.publication_for_product with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_api_version : '||l_api_version);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_product_key : '||p_product_key);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_usage_name : '||p_usage_name);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_publication_mode : '||p_publication_mode);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'p_effective_date : '||p_effective_date);
     END IF;

           x_publication_id := CZ_CF_API.publication_for_product
		                     (
                                product_key            => p_product_key,
                                config_lookup_date     => p_effective_date,
                                calling_application_id => 510,
                                usage_name             => p_usage_name, -- Defaults to:CZ: Publication Usage profile
                                publication_mode       => p_publication_mode, -- OKC always uses Production
                                language               => USERENV('LANG')
						  );


    -- debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 '   ********************************************************');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'After Calling CZ_CF_API.publication_for_product with parameters');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                 G_MODULE||l_api_name,
                 'x_publication_id : '||x_publication_id);
     END IF;



-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END publication_for_product;





-------------------------------------------------------------------------------

END OKC_XPRT_CZ_INT_PVT ;

/
