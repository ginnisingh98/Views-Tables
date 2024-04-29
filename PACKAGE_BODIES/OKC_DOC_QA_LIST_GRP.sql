--------------------------------------------------------
--  DDL for Package Body OKC_DOC_QA_LIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DOC_QA_LIST_GRP" AS
/* $Header: OKCGQALB.pls 120.0 2005/05/25 19:48:25 appldev noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_DOC_QA_LIST_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
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
  -- PROCEDURE Validate_Doc_Qa_List  --
  ---------------------------------------
  PROCEDURE Validate_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    p_object_version_number IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_Validate_Doc_Qa_List';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered Validate_Doc_Qa_List', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Validate_Doc_Qa_List_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_DOC_QA_LIST_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      p_object_version_number => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving Validate_Doc_Qa_List', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Doc_Qa_List: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Validate_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Doc_Qa_List: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Validate_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Doc_Qa_List because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Validate_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Validate_Doc_Qa_List;

  -------------------------------------
  -- PROCEDURE Insert_Doc_Qa_List
  -------------------------------------
  PROCEDURE Insert_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    x_qa_code               OUT NOCOPY VARCHAR2,
    x_document_type         OUT NOCOPY VARCHAR2

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_Lock_Doc_Qa_List';
    l_object_version_number OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by            OKC_DOC_QA_LISTS.CREATED_BY%TYPE;
    l_creation_date         OKC_DOC_QA_LISTS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_DOC_QA_LISTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_DOC_QA_LISTS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_DOC_QA_LISTS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered Insert_Doc_Qa_List', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Insert_Doc_Qa_List_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_DOC_QA_LIST_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      x_qa_code               => x_qa_code,
      x_document_type         => x_document_type
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
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving Insert_Doc_Qa_List', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving Insert_Doc_Qa_List: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Insert_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving Insert_Doc_Qa_List: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Insert_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving Insert_Doc_Qa_List because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Insert_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Insert_Doc_Qa_List;
  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Doc_Qa_List
  ---------------------------------------------------------------------------
  PROCEDURE Lock_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_object_version_number IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Lock_Doc_Qa_List';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered Lock_Doc_Qa_List', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Lock_Doc_Qa_List_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_DOC_QA_LIST_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_object_version_number => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving Lock_Doc_Qa_List', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving Lock_Doc_Qa_List: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Lock_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving Lock_Doc_Qa_List: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Lock_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving Lock_Doc_Qa_List because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Lock_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Lock_Doc_Qa_List;
  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Doc_Qa_List
  ---------------------------------------------------------------------------
  PROCEDURE Update_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    p_object_version_number IN NUMBER

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Update_Doc_Qa_List';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered Update_Doc_Qa_List', 2);
       okc_debug.log('1700: Locking row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Update_Doc_Qa_List_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_DOC_QA_LIST_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      p_object_version_number => p_object_version_number
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
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving Update_Doc_Qa_List', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving Update_Doc_Qa_List: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Update_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving Update_Doc_Qa_List: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Update_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving Update_Doc_Qa_List because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Update_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Update_Doc_Qa_List;

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Doc_Qa_List
  ---------------------------------------------------------------------------
  PROCEDURE Delete_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_object_version_number IN NUMBER
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Delete_Doc_Qa_List';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered Delete_Doc_Qa_List', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Doc_Qa_List_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Deleting A Row
    --------------------------------------------
    OKC_DOC_QA_LIST_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_object_version_number => p_object_version_number
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
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving Delete_Doc_Qa_List', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving Delete_Doc_Qa_List: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Delete_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving Delete_Doc_Qa_List: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_Delete_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving Delete_Doc_Qa_List because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_Delete_Doc_Qa_List_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Delete_Doc_Qa_List;

END OKC_DOC_QA_LIST_GRP;

/
