--------------------------------------------------------
--  DDL for Package Body IES_DEPL_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_DEPL_SCRIPT_PKG" AS
   /* $Header: ieslkdsb.pls 115.5 2003/05/23 21:03:03 prkotha noship $ */

/*-------------------------------------------------------------------------*
 |    PRIVATE CONSTANTS
 *-------------------------------------------------------------------------*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_depl_script_pkg';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ieslkdsb.pls';

/* private FUNCTION */

FUNCTION  get_active_locked_script_id(p_script_name     IN VARCHAR2,
                                      p_script_language IN VARCHAR2)
RETURN NUMBER IS
  l_script_id NUMBER;
BEGIN
 SELECT dscript_id
   INTO l_script_id
   FROM ies_deployed_scripts
  WHERE dscript_name = p_script_name
    AND dscript_lang_id = (SELECT language_id
			     FROM fnd_languages
			    WHERE nls_language = p_script_language)
    AND active_status = 1;
  RETURN l_script_id;
END;

/* END OF PRIVATE FUNCTIONS */

PROCEDURE lock_deployed_script
(
   p_api_version                    IN     NUMBER,
   p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
   p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
   p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
   p_dscript_id                     IN     NUMBER,
   x_return_status                  OUT NOCOPY     VARCHAR2,
   x_msg_count                      OUT NOCOPY     NUMBER,
   x_msg_data                       OUT NOCOPY     VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'lock_deployed_script';
  l_api_version   CONSTANT NUMBER         := 1.0;
  l_encoded       VARCHAR2(1)             := FND_API.G_FALSE;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT   lock_deployed_script_sp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize the API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    -- API body
    EXECUTE IMMEDIATE 'UPDATE ies_deployed_scripts SET lock_status = 1 '||
                    'WHERE DSCRIPT_ID = :dscriptId' USING p_dscript_id;

  EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
          FND_MESSAGE.SET_NAME('IES', 'IES_DSCRIPT_LOCK_ERROR');
          FND_MSG_PUB.Add;
       END IF;

    RAISE FND_API.G_EXC_ERROR;
  END;

  -- Signify Success
  IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
      FND_MESSAGE.SET_NAME('IES', 'IES_DSCRIPT_LOCK_SUCCESS');
      FND_MSG_PUB.Add;
  END IF;

  -- End of API body

  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN OTHERS THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF     FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg
     (      p_pkg_name            => G_PKG_NAME,
            p_procedure_name      => l_api_name,
            p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
     );
  END IF;
  FND_MSG_PUB.Count_And_Get
    (   p_encoded       =>      l_encoded,
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
    );

END lock_deployed_script;

PROCEDURE lock_deployed_script
(
   p_api_version                    IN     NUMBER,
   p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
   p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
   p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
   p_dscript_id                     IN     NUMBER,
   x_dscript_id                     OUT NOCOPY     NUMBER,
   x_return_status                  OUT NOCOPY     VARCHAR2,
   x_msg_count                      OUT NOCOPY     NUMBER,
   x_msg_data                       OUT NOCOPY     VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'lock_deployed_script';
  l_api_version   CONSTANT NUMBER         := 1.0;
  l_encoded       VARCHAR2(1)             := FND_API.G_FALSE;
  l_dscript_id     NUMBER;
BEGIN
-- Standard Start of API savepoint
  SAVEPOINT   lock_deployed_script_sp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize the API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    SELECT dscript_id
      INTO l_dscript_id
      FROM ies_deployed_scripts
     WHERE dscript_name = (SELECT dscript_name
                                FROM ies_deployed_scripts
                               WHERE dscript_id = p_dscript_id)
       AND dscript_lang_id = (SELECT dscript_lang_id
                                FROM ies_deployed_scripts
                               WHERE dscript_id = p_dscript_id)
       AND active_status = 1;

    lock_deployed_script(p_api_version ,
                         p_init_msg_list,
                         p_commit,
                         p_validation_level,
                         l_dscript_id,
                         x_return_status,
                         x_msg_count,
                         x_msg_data);
    x_dscript_id := l_dscript_id;
   END;
   -- Signify Success
   IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.SET_NAME('IES', 'IES_DSCRIPT_LOCK_SUCCESS');
      FND_MSG_PUB.Add;
   END IF;


   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );
EXCEPTION
WHEN NO_DATA_FOUND THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN OTHERS THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF     FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg
     (      p_pkg_name            => G_PKG_NAME,
            p_procedure_name      => l_api_name,
            p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
     );
  END IF;
  FND_MSG_PUB.Count_And_Get
    (   p_encoded       =>      l_encoded,
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
    );

END lock_deployed_script;

PROCEDURE lock_deployed_script
(
   p_api_version                    IN     NUMBER,
   p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
   p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
   p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
   p_dscript_name                   IN     VARCHAR2,
   p_dscript_language               IN     VARCHAR2,
   x_dscript_id                     OUT NOCOPY     NUMBER,
   x_return_status                  OUT NOCOPY     VARCHAR2,
   x_msg_count                      OUT NOCOPY     NUMBER,
   x_msg_data                       OUT NOCOPY     VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'lock_deployed_script';
  l_api_version   CONSTANT NUMBER         := 1.0;
  l_encoded       VARCHAR2(1)             := FND_API.G_FALSE;
  l_dscript_id     NUMBER;
BEGIN
-- Standard Start of API savepoint
  SAVEPOINT   lock_deployed_script_sp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize the API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_dscript_id := get_active_locked_script_id(p_dscript_name,
                                                p_dscript_language);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    lock_deployed_script(p_api_version ,
                         p_init_msg_list,
                         p_commit,
                         p_validation_level,
                         l_dscript_id	,
                         x_return_status,
                         x_msg_count,
                         x_msg_data);
     x_dscript_id := l_dscript_id;
   END;
   -- Signify Success
   IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.SET_NAME('IES', 'IES_DSCRIPT_LOCK_SUCCESS');
      FND_MSG_PUB.Add;
   END IF;


   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

EXCEPTION
WHEN NO_DATA_FOUND THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );
WHEN OTHERS THEN
  ROLLBACK TO lock_deployed_script_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF     FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg
     (      p_pkg_name            => G_PKG_NAME,
            p_procedure_name      => l_api_name,
            p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
     );
  END IF;
  FND_MSG_PUB.Count_And_Get
    (   p_encoded       =>      l_encoded,
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
    );

END lock_deployed_script;

END ies_depl_script_pkg;

/
