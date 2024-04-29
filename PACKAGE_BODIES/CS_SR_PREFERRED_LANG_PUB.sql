--------------------------------------------------------
--  DDL for Package Body CS_SR_PREFERRED_LANG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_PREFERRED_LANG_PUB" AS
/* $Header: cspprlb.pls 115.4 2002/11/30 10:13:59 pkesani noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_SR_Preferred_Lang_PUB';
G_INITIALIZED       CONSTANT VARCHAR2(1)  := 'R';


PROCEDURE initialize_rec(p_preferred_lang_record IN OUT
            NOCOPY CS_SR_Preferred_Lang_PVT.preferred_language_rec_type) AS

BEGIN
  CS_SR_Preferred_Lang_PVT.initialize_rec(p_preferred_lang_record);
END initialize_rec;



/* ************************************************************************* *
 *                            API Procedure Bodies                           *
 * ************************************************************************* */

--------------------------------------------------------------------------
-- Create_Preferred_Language
--------------------------------------------------------------------------


PROCEDURE Create_Preferred_Language
( p_api_version			  IN      NUMBER,
  p_init_msg_list		  IN      VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			  IN      VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status		  OUT     NOCOPY VARCHAR2,
  x_msg_count			  OUT     NOCOPY NUMBER,
  x_msg_data			  OUT     NOCOPY VARCHAR2,
  p_resp_appl_id		  IN      NUMBER	:= NULL,
  p_resp_id			  IN      NUMBER	:= NULL,
  p_user_id			  IN      NUMBER	,
  p_login_id			  IN      NUMBER	:= NULL,
  p_preferred_language_rec        IN      CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
 )
IS
  l_api_version	       CONSTANT	NUMBER		:= 1.0;
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Create_Preferred_Language';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_user_id;
  l_login_id			NUMBER		:= p_login_id;

  l_return_status		VARCHAR2(1);
  i				NUMBER := 0;		-- counter
  l_request_rec			CS_SR_Preferred_Lang_PVT.preferred_language_rec_type;

  l_preferred_language_rec      CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
                                DEFAULT p_preferred_language_rec;
  l_dummy			VARCHAR2(2000);


BEGIN
  SAVEPOINT Create_Preferred_Language_PUB;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- ----------------------------------------------------------------------
  -- Perform business rule validation and the database operation by calling
  -- the Private API.
  -- ----------------------------------------------------------------------

  CS_SR_Preferred_Lang_PVT.Create_Preferred_Language
    ( p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_resp_appl_id                 => l_resp_appl_id,
      p_resp_id                      => l_resp_id,
      p_user_id                      => l_user_id,
      p_login_id                     => l_login_id,
      p_preferred_language_rec       => l_preferred_language_rec
    );


  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Create_Preferred_Language;


--------------------------------------------------------------------------
-- Update_Preferred_Language
--------------------------------------------------------------------------

PROCEDURE Update_Preferred_Language
(
  p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2      := FND_API.G_FALSE,
  p_commit                 IN     VARCHAR2      := FND_API.G_FALSE,
  x_return_status          OUT    NOCOPY VARCHAR2,
  x_msg_count              OUT    NOCOPY NUMBER,
  x_msg_data               OUT    NOCOPY VARCHAR2,
  p_pref_lang_id           IN     NUMBER,
  p_object_version_number  IN     NUMBER,
  p_resp_appl_id           IN     NUMBER        := NULL,
  p_resp_id                IN     NUMBER        := NULL,
  p_user_id		   IN     NUMBER	,
  p_login_id		   IN     NUMBER	:= NULL,
  p_last_updated_by        IN     NUMBER,
  p_last_update_login      IN     NUMBER         :=NULL,
  p_last_update_date       IN     DATE,
  p_preferred_language_rec IN     CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
)
IS
  l_api_version	       CONSTANT	NUMBER		:= 1.0;
  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_Preferred_Language';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);

  l_preferred_language_rec      CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
                                DEFAULT p_preferred_language_rec;

  l_resp_appl_id		NUMBER		:= p_resp_appl_id;
  l_resp_id			NUMBER		:= p_resp_id;
  l_user_id			NUMBER		:= p_last_updated_by;
  l_login_id			NUMBER		:= p_last_update_login;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_Preferred_Language_PUB;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  CS_SR_Preferred_Lang_PVT.Update_Preferred_Language
    ( p_api_version           => 1.0,
      p_init_msg_list	      => FND_API.G_FALSE,
      p_commit		      => FND_API.G_FALSE,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      x_return_status	      => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_pref_lang_id          => p_pref_lang_id,
      p_object_version_number => p_object_version_number,
      p_resp_appl_id          => p_resp_appl_id,
      p_resp_id               => p_resp_id,
      p_user_id               => p_user_id,
      p_login_id              => p_login_id,
      p_last_updated_by	      => l_user_id,
      p_last_update_login     => l_login_id,
      p_last_update_date      => p_last_update_date,
      p_preferred_language_rec => l_preferred_language_rec
    );


  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Update_Preferred_Language_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Update_Preferred_Language;



END CS_SR_Preferred_lang_PUB;

/
