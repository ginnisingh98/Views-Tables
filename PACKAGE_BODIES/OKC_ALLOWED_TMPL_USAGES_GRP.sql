--------------------------------------------------------
--  DDL for Package Body OKC_ALLOWED_TMPL_USAGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ALLOWED_TMPL_USAGES_GRP" AS
/* $Header: OKCGALDTMPLUSGB.pls 120.0 2005/05/26 09:52:56 appldev noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ALLOWED_TMPL_USAGES_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	                     CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  ---------------------------------------
  -- PROCEDURE Validate_Allowed_Tmpl_Usages  --
  ---------------------------------------
  PROCEDURE Validate_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_Validate_Allowed_Tmpl_Usages';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered Validate_Allowed_Tmpl_Usages', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Validate_Allowed_Usages_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_ALLOWED_TMPL_USAGES_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving Validate_Allowed_Tmpl_Usages', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Validate_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Validate_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Allowed_Tmpl_Usages because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Validate_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Validate_Allowed_Tmpl_Usages;

  -------------------------------------
  -- PROCEDURE Create_Allowed_Tmpl_Usages
  -------------------------------------
  PROCEDURE Create_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER   := NULL,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    x_allowed_tmpl_usages_id OUT NOCOPY NUMBER

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_Lock_Allowed_Tmpl_Usages';
    l_object_version_number  OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by             OKC_ALLOWED_TMPL_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_ALLOWED_TMPL_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_ALLOWED_TMPL_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered Create_Allowed_Tmpl_Usages', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Create_Allowed_Usages_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_ALLOWED_TMPL_USAGES_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      x_allowed_tmpl_usages_id => x_allowed_tmpl_usages_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving Create_Allowed_Tmpl_Usages', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving Create_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Create_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving Create_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Create_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving Create_Allowed_Tmpl_Usages because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Create_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Create_Allowed_Tmpl_Usages;
  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Allowed_Tmpl_Usages
  ---------------------------------------------------------------------------
  PROCEDURE Lock_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,
    p_object_version_number  IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Lock_Allowed_Tmpl_Usages';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered Lock_Allowed_Tmpl_Usages', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Lock_Allowed_Usages_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_ALLOWED_TMPL_USAGES_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving Lock_Allowed_Tmpl_Usages', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving Lock_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Lock_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving Lock_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Lock_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving Lock_Allowed_Tmpl_Usages because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Lock_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Lock_Allowed_Tmpl_Usages;
  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Allowed_Tmpl_Usages
  ---------------------------------------------------------------------------
  PROCEDURE Update_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Update_Allowed_Tmpl_Usages';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered Update_Allowed_Tmpl_Usages', 2);
       okc_debug.log('1700: Locking row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Update_Allowed_Usages_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_ALLOWED_TMPL_USAGES_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving Update_Allowed_Tmpl_Usages', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving Update_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Update_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving Update_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Update_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving Update_Allowed_Tmpl_Usages because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Update_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Update_Allowed_Tmpl_Usages;

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Allowed_Tmpl_Usages
  ---------------------------------------------------------------------------
  PROCEDURE Delete_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,
    p_object_version_number  IN NUMBER
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Delete_Allowed_Tmpl_Usages';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered Delete_Allowed_Tmpl_Usages', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Allowed_Usages_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Deleting A Row
    --------------------------------------------
    OKC_ALLOWED_TMPL_USAGES_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving Delete_Allowed_Tmpl_Usages', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving Delete_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Delete_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving Delete_Allowed_Tmpl_Usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Delete_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving Delete_Allowed_Tmpl_Usages because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Delete_Allowed_Usages_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Delete_Allowed_Tmpl_Usages;

END OKC_ALLOWED_TMPL_USAGES_GRP;

/
