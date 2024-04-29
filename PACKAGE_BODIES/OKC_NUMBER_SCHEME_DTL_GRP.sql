--------------------------------------------------------
--  DDL for Package Body OKC_NUMBER_SCHEME_DTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_NUMBER_SCHEME_DTL_GRP" AS
/* $Header: OKCGNSDB.pls 120.1 2005/11/03 02:29:42 ndoddi noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_NUMBER_SCHEME_DTL_GRP';
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

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  ---------------------------------------
  -- PROCEDURE Validate_Number_Scheme_Dtl  --
  ---------------------------------------
  PROCEDURE Validate_Number_Scheme_Dtl(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_validation_level	    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER
  ) IS
    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'g_Validate_Number_Scheme_Dtl';

  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered Validate_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered Validate_Number_Scheme_Dtl' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Validate_Num_Scheme_Dtl_GRP;
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
    OKC_NUMBER_SCHEME_DTL_PVT.Validate_Row(
      p_validation_level      => p_validation_level,
      x_return_status         => x_return_status,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
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

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving Validate_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '200: Leaving Validate_Number_Scheme_Dtl' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '300: Leaving Validate_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Validate_Num_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '400: Leaving Validate_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Validate_Num_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '500: Leaving Validate_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm );
      END IF;
      ROLLBACK TO g_Validate_Num_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Validate_Number_Scheme_Dtl;

  -------------------------------------
  -- PROCEDURE Insert_Number_Scheme_Dtl
  -------------------------------------
  PROCEDURE Insert_Number_Scheme_Dtl(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_validation_level	    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    x_num_scheme_id         OUT NOCOPY NUMBER,
    x_num_sequence_code     OUT NOCOPY VARCHAR2,
    x_sequence_level        OUT NOCOPY NUMBER

  ) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'g_Lock_Number_Scheme_Dtl';
    l_object_version_number OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by            OKC_NUMBER_SCHEME_DTLS.CREATED_BY%TYPE;
    l_creation_date         OKC_NUMBER_SCHEME_DTLS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_NUMBER_SCHEME_DTLS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered Insert_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '600: Entered Insert_Number_Scheme_Dtl' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Insert_Number_Scheme_Dtl_GRP;
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
    OKC_NUMBER_SCHEME_DTL_PVT.Insert_Row(
      p_validation_level      =>   p_validation_level,
      x_return_status         =>   x_return_status,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
      x_num_scheme_id         => x_num_scheme_id,
      x_num_sequence_code     => x_num_sequence_code,
      x_sequence_level        => x_sequence_level
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

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving Insert_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '700: Leaving Insert_Number_Scheme_Dtl' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving Insert_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '800: Leaving Insert_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Insert_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving Insert_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '900: Leaving Insert_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Insert_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving Insert_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '1000: Leaving Insert_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm );
      END IF;
      ROLLBACK TO g_Insert_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Insert_Number_Scheme_Dtl;
  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Number_Scheme_Dtl
  ---------------------------------------------------------------------------
  PROCEDURE Lock_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_object_version_number IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Lock_Number_Scheme_Dtl';
  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered Lock_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1100: Entered Lock_Number_Scheme_Dtl' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Lock_Number_Scheme_Dtl_GRP;
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
    OKC_NUMBER_SCHEME_DTL_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
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

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving Lock_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1200: Leaving Lock_Number_Scheme_Dtl' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving Lock_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '1300: Leaving Lock_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Lock_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving Lock_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '1400: Leaving Lock_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Lock_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving Lock_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '1500: Leaving Lock_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm );
      END IF;
      ROLLBACK TO g_Lock_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Lock_Number_Scheme_Dtl;
  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Number_Scheme_Dtl
  ---------------------------------------------------------------------------
  PROCEDURE Update_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Update_Number_Scheme_Dtl';

  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered Update_Number_Scheme_Dtl', 2);
       okc_debug.log('1700: Locking row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1600: Entered Update_Number_Scheme_Dtl');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1700: Locking row');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Update_Number_Scheme_Dtl_GRP;
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
    OKC_NUMBER_SCHEME_DTL_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
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

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving Update_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1800: Leaving Update_Number_Scheme_Dtl' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving Update_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '1900: Leaving Update_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Update_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving Update_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2000: Leaving Update_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Update_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving Update_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2100: Leaving Update_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm );
      END IF;
      ROLLBACK TO g_Update_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Update_Number_Scheme_Dtl;

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Number_Scheme_Dtl
  ---------------------------------------------------------------------------
  PROCEDURE Delete_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_object_version_number IN NUMBER
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Delete_Number_Scheme_Dtl';
  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered Delete_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2200: Entered Delete_Number_Scheme_Dtl' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Number_Scheme_Dtl_GRP;
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
    OKC_NUMBER_SCHEME_DTL_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
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

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving Delete_Number_Scheme_Dtl', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2300: Leaving Delete_Number_Scheme_Dtl' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving Delete_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2400: Leaving Delete_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Delete_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving Delete_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2500: Leaving Delete_Number_Scheme_Dtl: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_Delete_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving Delete_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2600: Leaving Delete_Number_Scheme_Dtl because of EXCEPTION: '||sqlerrm );
      END IF;
      ROLLBACK TO g_Delete_Number_Scheme_Dtl_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Delete_Number_Scheme_Dtl;

END OKC_NUMBER_SCHEME_DTL_GRP;

/
