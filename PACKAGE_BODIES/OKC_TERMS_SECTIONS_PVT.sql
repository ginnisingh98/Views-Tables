--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_SECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_SECTIONS_PVT" AS
/* $Header: OKCVSCNB.pls 120.1.12010000.2 2011/12/09 13:51:32 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_LOCK_RECORD_DELETED        CONSTANT VARCHAR2(200) := OKC_API.G_LOCK_RECORD_DELETED;
  ---------------------------------------------------------------------------
  -- VALIDATION LEVELS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE_VALID_LEVEL CONSTANT NUMBER := OKC_API.G_REQUIRED_VALUE_VALID_LEVEL;
  G_VALID_VALUE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_VALID_VALUE_VALID_LEVEL;
  G_LOOKUP_CODE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_LOOKUP_CODE_VALID_LEVEL;
  G_FOREIGN_KEY_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_FOREIGN_KEY_VALID_LEVEL;
  G_RECORD_VALID_LEVEL         CONSTANT NUMBER := OKC_API.G_RECORD_VALID_LEVEL;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_SECTIONS_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;
  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_id                         IN NUMBER,
    x_id                         OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_SECTIONS_B_S.NEXTVAL FROM DUAL;
  BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '100: Entered get_seq_id' );
    END IF;

    IF( p_id IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_id                        ;
      IF l_seq_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_seq_csr;
    END IF;

    /*IF (l_debug = 'Y') THEN
     Okc_Debug.Log('200: Leaving get_seq_id', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
       	    G_PKG_NAME, '200: Leaving get_seq_id' );
    END IF;
    RETURN G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
      	      G_PKG_NAME, '300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_seq_csr%ISOPEN THEN
        CLOSE l_seq_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Seq_Id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTIONS_B
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_id                         IN NUMBER,

    x_section_sequence           OUT NOCOPY NUMBER,
    x_label                      OUT NOCOPY VARCHAR2,
    x_scn_id                     OUT NOCOPY NUMBER,
    x_heading                    OUT NOCOPY VARCHAR2,
    x_description                OUT NOCOPY VARCHAR2,
    x_document_type              OUT NOCOPY VARCHAR2,
    x_document_id                OUT NOCOPY NUMBER,
    x_scn_code                   OUT NOCOPY VARCHAR2,
    x_amendment_description      OUT NOCOPY VARCHAR2,
    x_amendment_operation_code   OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY NUMBER,
    x_orig_system_reference_id2  OUT NOCOPY NUMBER,
    x_print_yn                   OUT NOCOPY VARCHAR2,
    x_attribute_category         OUT NOCOPY VARCHAR2,
    x_attribute1                 OUT NOCOPY VARCHAR2,
    x_attribute2                 OUT NOCOPY VARCHAR2,
    x_attribute3                 OUT NOCOPY VARCHAR2,
    x_attribute4                 OUT NOCOPY VARCHAR2,
    x_attribute5                 OUT NOCOPY VARCHAR2,
    x_attribute6                 OUT NOCOPY VARCHAR2,
    x_attribute7                 OUT NOCOPY VARCHAR2,
    x_attribute8                 OUT NOCOPY VARCHAR2,
    x_attribute9                 OUT NOCOPY VARCHAR2,
    x_attribute10                OUT NOCOPY VARCHAR2,
    x_attribute11                OUT NOCOPY VARCHAR2,
    x_attribute12                OUT NOCOPY VARCHAR2,
    x_attribute13                OUT NOCOPY VARCHAR2,
    x_attribute14                OUT NOCOPY VARCHAR2,
    x_attribute15                OUT NOCOPY VARCHAR2,
    x_summary_amend_operation_code  OUT NOCOPY VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER,
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE,
    x_last_amended_by            OUT NOCOPY NUMBER,
    x_last_amendment_date        OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_SECTIONS_B_pk_csr (cp_id IN NUMBER) IS
    SELECT
            SECTION_SEQUENCE,
            LABEL,
            SCN_ID,
            HEADING,
            DESCRIPTION,
            DOCUMENT_TYPE,
            DOCUMENT_ID,
            SCN_CODE,
            AMENDMENT_DESCRIPTION,
            AMENDMENT_OPERATION_CODE,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            PRINT_YN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            SUMMARY_AMEND_OPERATION_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_AMENDED_BY,
            LAST_AMENDMENT_DATE
      FROM OKC_SECTIONS_B t
     WHERE t.ID = cp_id;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
       	    G_PKG_NAME, '400: Entered get_rec' );
    END IF;

    -- Get current database values
    OPEN OKC_SECTIONS_B_pk_csr (p_id);
    FETCH OKC_SECTIONS_B_pk_csr INTO
            x_section_sequence,
            x_label,
            x_scn_id,
            x_heading,
            x_description,
            x_document_type,
            x_document_id,
            x_scn_code,
            x_amendment_description,
            x_amendment_operation_code,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_print_yn,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_summary_amend_operation_code,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_last_amended_by,
            x_last_amendment_date;
    IF OKC_SECTIONS_B_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_SECTIONS_B_pk_csr;

   /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('500: Leaving  get_rec ', 2);
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
       	    G_PKG_NAME, '500: Leaving  get_rec ' );
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Leaving get_rec because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '600: Leaving get_rec because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_SECTIONS_B_pk_csr%ISOPEN THEN
        CLOSE OKC_SECTIONS_B_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_SECTIONS_B --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_object_version_number      IN NUMBER,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE,
    x_section_sequence           OUT NOCOPY NUMBER,
    x_label                      OUT NOCOPY VARCHAR2,
    x_scn_id                     OUT NOCOPY NUMBER,
    x_heading                    OUT NOCOPY VARCHAR2,
    x_object_version_number      OUT NOCOPY VARCHAR2,
    x_description                OUT NOCOPY VARCHAR2,
    x_document_type              OUT NOCOPY VARCHAR2,
    x_document_id                OUT NOCOPY NUMBER,
    x_scn_code                   OUT NOCOPY VARCHAR2,
    x_amendment_description      OUT NOCOPY VARCHAR2,
    x_amendment_operation_code   OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY NUMBER,
    x_orig_system_reference_id2  OUT NOCOPY NUMBER,
    x_print_yn                   OUT NOCOPY VARCHAR2,
    x_attribute_category         OUT NOCOPY VARCHAR2,
    x_attribute1                 OUT NOCOPY VARCHAR2,
    x_attribute2                 OUT NOCOPY VARCHAR2,
    x_attribute3                 OUT NOCOPY VARCHAR2,
    x_attribute4                 OUT NOCOPY VARCHAR2,
    x_attribute5                 OUT NOCOPY VARCHAR2,
    x_attribute6                 OUT NOCOPY VARCHAR2,
    x_attribute7                 OUT NOCOPY VARCHAR2,
    x_attribute8                 OUT NOCOPY VARCHAR2,
    x_attribute9                 OUT NOCOPY VARCHAR2,
    x_attribute10                OUT NOCOPY VARCHAR2,
    x_attribute11                OUT NOCOPY VARCHAR2,
    x_attribute12                OUT NOCOPY VARCHAR2,
    x_attribute13                OUT NOCOPY VARCHAR2,
    x_attribute14                OUT NOCOPY VARCHAR2,
    x_attribute15                OUT NOCOPY VARCHAR2,
    x_summary_amend_operation_code OUT NOCOPY VARCHAR2,
    x_last_amended_by            OUT NOCOPY NUMBER,
    x_last_amendment_date        OUT NOCOPY DATE
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number      OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_SECTIONS_B.CREATED_BY%TYPE;
    l_creation_date              OKC_SECTIONS_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_SECTIONS_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_SECTIONS_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_SECTIONS_B.LAST_UPDATE_DATE%TYPE;
  BEGIN
    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
      	   G_PKG_NAME, '700: Entered Set_Attributes ' );
    END IF;

    IF( p_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_id                         => p_id,
        x_section_sequence           => x_section_sequence,
        x_label                      => x_label,
        x_scn_id                     => x_scn_id,
        x_heading                    => x_heading,
        x_description                => x_description,
        x_document_type              => x_document_type,
        x_document_id                => x_document_id,
        x_scn_code                   => x_scn_code,
        x_amendment_description      => x_amendment_description,
        x_amendment_operation_code   => x_amendment_operation_code,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1  => x_orig_system_reference_id1,
        x_orig_system_reference_id2  => x_orig_system_reference_id2,
        x_print_yn                   => x_print_yn,
        x_attribute_category         => x_attribute_category,
        x_attribute1                 => x_attribute1,
        x_attribute2                 => x_attribute2,
        x_attribute3                 => x_attribute3,
        x_attribute4                 => x_attribute4,
        x_attribute5                 => x_attribute5,
        x_attribute6                 => x_attribute6,
        x_attribute7                 => x_attribute7,
        x_attribute8                 => x_attribute8,
        x_attribute9                 => x_attribute9,
        x_attribute10                => x_attribute10,
        x_attribute11                => x_attribute11,
        x_attribute12                => x_attribute12,
        x_attribute13                => x_attribute13,
        x_attribute14                => x_attribute14,
        x_attribute15                => x_attribute15,
        x_summary_amend_operation_code => x_summary_amend_operation_code,
        x_object_version_number      => x_object_version_number,
        x_created_by                 => l_created_by,
        x_creation_date              => l_creation_date,
        x_last_updated_by            => l_last_updated_by,
        x_last_update_login          => l_last_update_login,
        x_last_update_date           => l_last_update_date,
        x_last_amended_by            => x_last_amended_by,
        x_last_amendment_date        => x_last_amendment_date
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_section_sequence = G_MISS_NUM) THEN
        x_section_sequence := NULL;
       ELSIF (p_SECTION_SEQUENCE IS NOT NULL) THEN
        x_section_sequence := p_section_sequence;
      END IF;

      IF (p_label = G_MISS_CHAR) THEN
        x_label := NULL;
       ELSIF (p_LABEL IS NOT NULL) THEN
        x_label := p_label;
      END IF;

      IF (p_scn_id = G_MISS_NUM) THEN
        x_scn_id := NULL;
       ELSIF (p_SCN_ID IS NOT NULL) THEN
        x_scn_id := p_scn_id;
      END IF;

      IF (p_heading = G_MISS_CHAR) THEN
        x_heading := NULL;
       ELSIF (p_HEADING IS NOT NULL) THEN
        x_heading := p_heading;
      END IF;

      IF (p_description = G_MISS_CHAR) THEN
        x_description := NULL;
       ELSIF (p_description IS NOT NULL) THEN
        x_description := p_description;
      END IF;

      IF (p_document_type = G_MISS_CHAR) THEN
        x_document_type := NULL;
       ELSIF (p_DOCUMENT_TYPE IS NOT NULL) THEN
        x_document_type := p_document_type;
      END IF;

      IF (p_document_id = G_MISS_NUM) THEN
        x_document_id := NULL;
       ELSIF (p_DOCUMENT_ID IS NOT NULL) THEN
        x_document_id := p_document_id;
      END IF;

      IF (p_scn_code = G_MISS_CHAR) THEN
        x_scn_code := NULL;
       ELSIF (p_SCN_CODE IS NOT NULL) THEN
        x_scn_code := p_scn_code;
      END IF;

      IF (p_amendment_description = G_MISS_CHAR) THEN
        x_amendment_description := NULL;
       ELSIF (p_AMENDMENT_DESCRIPTION IS NOT NULL) THEN
        x_amendment_description := p_amendment_description;
      END IF;

      IF (p_amendment_operation_code = G_MISS_CHAR) THEN
        x_amendment_operation_code := NULL;
       ELSIF (p_AMENDMENT_OPERATION_CODE IS NOT NULL) THEN
        x_amendment_operation_code := p_amendment_operation_code;
      END IF;

      IF p_amendment_operation_code IS NOT NULL
       AND p_amendment_operation_code <> G_MISS_CHAR
       AND x_amendment_operation_code IS NOT NULL
       THEN
        x_last_amendment_date := Sysdate;
        x_last_amended_by := Fnd_Global.User_Id;
      END IF;

      IF (p_last_amended_by = G_MISS_NUM) THEN
        x_last_amended_by := NULL;
      END IF;

      IF (p_last_amendment_date = G_MISS_DATE) THEN
        x_last_amendment_date := NULL;
      END IF;

      IF (p_orig_system_reference_code = G_MISS_CHAR) THEN
        x_orig_system_reference_code := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_CODE IS NOT NULL) THEN
        x_orig_system_reference_code := p_orig_system_reference_code;
      END IF;

      IF (p_orig_system_reference_id1 = G_MISS_NUM) THEN
        x_orig_system_reference_id1 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID1 IS NOT NULL) THEN
        x_orig_system_reference_id1 := p_orig_system_reference_id1;
      END IF;

      IF (p_orig_system_reference_id2 = G_MISS_NUM) THEN
        x_orig_system_reference_id2 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID2 IS NOT NULL) THEN
        x_orig_system_reference_id2 := p_orig_system_reference_id2;
      END IF;

      IF nvl(p_scn_code,'?')='UNASSIGNED' THEN
            x_print_yn:='N';
      ELSE
            x_print_yn:='Y';
      END IF;

      IF (p_attribute_category = G_MISS_CHAR) THEN
        x_attribute_category := NULL;
       ELSIF (p_ATTRIBUTE_CATEGORY IS NOT NULL) THEN
        x_attribute_category := p_attribute_category;
      END IF;

      IF (p_attribute1 = G_MISS_CHAR) THEN
        x_attribute1 := NULL;
       ELSIF (p_ATTRIBUTE1 IS NOT NULL) THEN
        x_attribute1 := p_attribute1;
      END IF;

      IF (p_attribute2 = G_MISS_CHAR) THEN
        x_attribute2 := NULL;
       ELSIF (p_ATTRIBUTE2 IS NOT NULL) THEN
        x_attribute2 := p_attribute2;
      END IF;

      IF (p_attribute3 = G_MISS_CHAR) THEN
        x_attribute3 := NULL;
       ELSIF (p_ATTRIBUTE3 IS NOT NULL) THEN
        x_attribute3 := p_attribute3;
      END IF;

      IF (p_attribute4 = G_MISS_CHAR) THEN
        x_attribute4 := NULL;
       ELSIF (p_ATTRIBUTE4 IS NOT NULL) THEN
        x_attribute4 := p_attribute4;
      END IF;

      IF (p_attribute5 = G_MISS_CHAR) THEN
        x_attribute5 := NULL;
       ELSIF (p_ATTRIBUTE5 IS NOT NULL) THEN
        x_attribute5 := p_attribute5;
      END IF;

      IF (p_attribute6 = G_MISS_CHAR) THEN
        x_attribute6 := NULL;
       ELSIF (p_ATTRIBUTE6 IS NOT NULL) THEN
        x_attribute6 := p_attribute6;
      END IF;

      IF (p_attribute7 = G_MISS_CHAR) THEN
        x_attribute7 := NULL;
       ELSIF (p_ATTRIBUTE7 IS NOT NULL) THEN
        x_attribute7 := p_attribute7;
      END IF;

      IF (p_attribute8 = G_MISS_CHAR) THEN
        x_attribute8 := NULL;
       ELSIF (p_ATTRIBUTE8 IS NOT NULL) THEN
        x_attribute8 := p_attribute8;
      END IF;

      IF (p_attribute9 = G_MISS_CHAR) THEN
        x_attribute9 := NULL;
       ELSIF (p_ATTRIBUTE9 IS NOT NULL) THEN
        x_attribute9 := p_attribute9;
      END IF;

      IF (p_attribute10 = G_MISS_CHAR) THEN
        x_attribute10 := NULL;
       ELSIF (p_ATTRIBUTE10 IS NOT NULL) THEN
        x_attribute10 := p_attribute10;
      END IF;

      IF (p_attribute11 = G_MISS_CHAR) THEN
        x_attribute11 := NULL;
       ELSIF (p_ATTRIBUTE11 IS NOT NULL) THEN
        x_attribute11 := p_attribute11;
      END IF;

      IF (p_attribute12 = G_MISS_CHAR) THEN
        x_attribute12 := NULL;
       ELSIF (p_ATTRIBUTE12 IS NOT NULL) THEN
        x_attribute12 := p_attribute12;
      END IF;

      IF (p_attribute13 = G_MISS_CHAR) THEN
        x_attribute13 := NULL;
       ELSIF (p_ATTRIBUTE13 IS NOT NULL) THEN
        x_attribute13 := p_attribute13;
      END IF;

      IF (p_attribute14 = G_MISS_CHAR) THEN
        x_attribute14 := NULL;
       ELSIF (p_ATTRIBUTE14 IS NOT NULL) THEN
        x_attribute14 := p_attribute14;
      END IF;

      IF (p_attribute15 = G_MISS_CHAR) THEN
        x_attribute15 := NULL;
       ELSIF (p_ATTRIBUTE15 IS NOT NULL) THEN
        x_attribute15 := p_attribute15;
      END IF;

      IF (p_summary_amend_operation_code = G_MISS_CHAR) THEN
        x_summary_amend_operation_code := NULL;
       ELSIF (p_summary_amend_operation_code IS NOT NULL) THEN
        x_summary_amend_operation_code := p_summary_amend_operation_code;
      END IF;
    END IF;

    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('800: Leaving  Set_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
      	   G_PKG_NAME, '800: Leaving  Set_Attributes ' );
    END IF;

    RETURN G_RET_STS_SUCCESS ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception');
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN G_RET_STS_UNEXP_ERROR;

  END Set_Attributes ;

  ----------------------------------------------
  -- Validate_Attributes for: OKC_SECTIONS_B --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_scn_id_csr is
     SELECT '!'
      FROM OKC_SECTIONS_B
      WHERE ID = p_scn_id;

    CURSOR l_doc_type_csr is
     SELECT '!'
      FROM OKC_BUS_DOC_TYPES_V
      WHERE document_type = p_document_type;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '1200: Entered Validate_Attributes' );
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1300: required values validation' );
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1400: - attribute ID ' );
      END IF;

      IF ( p_id IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ID is invalid', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
            	G_PKG_NAME, '1500: - attribute ID is invalid' );
      	END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute DOCUMENT_TYPE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1400: - attribute DOCUMENT_TYPE ' );
      END IF;
      IF ( p_document_type IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute DOCUMENT_TYPE is invalid', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
            	G_PKG_NAME, '1500: - attribute DOCUMENT_TYPE is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DOCUMENT_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute DOCUMENT_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1400: - attribute DOCUMENT_ID ' );
      END IF;
      IF ( p_document_id IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute DOCUMENT_ID is invalid', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
            	G_PKG_NAME, '1500: - attribute DOCUMENT_ID is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DOCUMENT_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute SECTION_SEQUENCE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1400: - attribute SECTION_SEQUENCE ' );
      END IF;
      IF ( p_section_sequence IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SECTION_SEQUENCE is invalid', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
            	G_PKG_NAME, '1500: - attribute SECTION_SEQUENCE is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SECTION_SEQUENCE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1600: static values and range validation' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute PRINT_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1700: - attribute PRINT_YN ' );
      END IF;
      IF ( p_print_yn NOT IN ('Y','N') AND p_print_yn IS NOT NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute PRINT_YN is invalid', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
            	G_PKG_NAME, '1800: - attribute PRINT_YN is invalid' );
	END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'PRINT_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '1900: lookup codes validation' );
      END IF;


      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute SCN_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2000: - attribute SCN_CODE ' );
      END IF;

/*    bug 3676155

      IF p_scn_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code('OKC_ARTICLE_SECTION',p_scn_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SCN_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
*/

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute AMENDMENT_OPERATION_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2000: - attribute AMENDMENT_OPERATION_CODE ' );
      END IF;
      IF p_amendment_operation_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code('OKC_AMEND_OPN_CODE',p_amendment_operation_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'AMENDMENT_OPERATION_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2100: foreigh keys validation ' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2190: - attribute DOCUMENT_TYPE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2190: - attribute DOCUMENT_TYPE ' );
      END IF;

      IF p_document_type IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN  l_doc_type_csr;
        FETCH l_doc_type_csr INTO l_dummy_var;
        CLOSE l_doc_type_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DOCUMENT_TYPE is invalid', 2);
          END IF;*/

         IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
   	      FND_LOG.STRING(G_PROC_LEVEL,
    	         G_PKG_NAME, '2300: - attribute DOCUMENT_TYPE is invalid' );
         END IF;

          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOCUMENT_TYPE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute SCN_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2200: - attribute SCN_ID ' );
      END IF;

      IF p_scn_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_scn_id_csr;
        FETCH l_scn_id_csr INTO l_dummy_var;
        CLOSE l_scn_id_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute SCN_ID is invalid', 2);
          END IF;*/

	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	      FND_LOG.STRING(G_PROC_LEVEL,
     	          G_PKG_NAME, '2300: - attribute SCN_ID is invalid' );
	  END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCN_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2400: Leaving Validate_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2400: Leaving Validate_Attributes ' );
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      --Okc_Debug.Log('2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm, 2);
      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);



      IF l_scn_id_csr%ISOPEN THEN
        CLOSE l_scn_id_csr;
      END IF;

      IF l_doc_type_csr%ISOPEN THEN
        CLOSE l_doc_type_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_SECTIONS_B --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	         IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '2600: Entered Validate_Record' );
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_summary_amend_operation_code => p_summary_amend_operation_code
    );
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	 FND_LOG.STRING(G_PROC_LEVEL,
     	     G_PKG_NAME, '2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm );
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2800: Entered Record Level Validations', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	 FND_LOG.STRING(G_PROC_LEVEL,
     	     G_PKG_NAME, '2800: Entered Record Level Validations' );
      END IF;
/*+++++++++++++start of hand code +++++++++++++++++++*/
-- ?? manual coding for Record Level Validations if required ??
/*+++++++++++++End of hand code +++++++++++++++++++*/
    END IF;

    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('2900: Leaving Validate_Record : '||sqlerrm, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	 FND_LOG.STRING(G_PROC_LEVEL,
    	     G_PKG_NAME, '2900: Leaving Validate_Record : '||sqlerrm);
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_EXCP_LEVEL,
	       G_PKG_NAME, '3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_SECTIONS_B --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_object_version_number      IN NUMBER
  ) IS
      l_section_sequence           OKC_SECTIONS_B.SECTION_SEQUENCE%TYPE;
      l_label                      OKC_SECTIONS_B.LABEL%TYPE;
      l_scn_id                     OKC_SECTIONS_B.SCN_ID%TYPE;
      l_heading                    OKC_SECTIONS_B.HEADING%TYPE;
      l_description                OKC_SECTIONS_B.DESCRIPTION%TYPE;
      l_document_type              OKC_SECTIONS_B.DOCUMENT_TYPE%TYPE;
      l_document_id                OKC_SECTIONS_B.DOCUMENT_ID%TYPE;
      l_scn_code                   OKC_SECTIONS_B.SCN_CODE%TYPE;
      l_amendment_description      OKC_SECTIONS_B.AMENDMENT_DESCRIPTION%TYPE;
      l_amendment_operation_code   OKC_SECTIONS_B.AMENDMENT_OPERATION_CODE%TYPE;
      l_orig_system_reference_code OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1  OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2  OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
      l_print_yn                   OKC_SECTIONS_B.PRINT_YN%TYPE;
      l_attribute_category         OKC_SECTIONS_B.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1                 OKC_SECTIONS_B.ATTRIBUTE1%TYPE;
      l_attribute2                 OKC_SECTIONS_B.ATTRIBUTE2%TYPE;
      l_attribute3                 OKC_SECTIONS_B.ATTRIBUTE3%TYPE;
      l_attribute4                 OKC_SECTIONS_B.ATTRIBUTE4%TYPE;
      l_attribute5                 OKC_SECTIONS_B.ATTRIBUTE5%TYPE;
      l_attribute6                 OKC_SECTIONS_B.ATTRIBUTE6%TYPE;
      l_attribute7                 OKC_SECTIONS_B.ATTRIBUTE7%TYPE;
      l_attribute8                 OKC_SECTIONS_B.ATTRIBUTE8%TYPE;
      l_attribute9                 OKC_SECTIONS_B.ATTRIBUTE9%TYPE;
      l_attribute10                OKC_SECTIONS_B.ATTRIBUTE10%TYPE;
      l_attribute11                OKC_SECTIONS_B.ATTRIBUTE11%TYPE;
      l_attribute12                OKC_SECTIONS_B.ATTRIBUTE12%TYPE;
      l_attribute13                OKC_SECTIONS_B.ATTRIBUTE13%TYPE;
      l_attribute14                OKC_SECTIONS_B.ATTRIBUTE14%TYPE;
      l_attribute15                OKC_SECTIONS_B.ATTRIBUTE15%TYPE;
      l_summary_amend_operation_code OKC_SECTIONS_B.summary_amend_operation_code%TYPE;
      l_object_version_number      OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by                 OKC_SECTIONS_B.CREATED_BY%TYPE;
      l_creation_date              OKC_SECTIONS_B.CREATION_DATE%TYPE;
      l_last_updated_by            OKC_SECTIONS_B.LAST_UPDATED_BY%TYPE;
      l_last_update_login          OKC_SECTIONS_B.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date           OKC_SECTIONS_B.LAST_UPDATE_DATE%TYPE;
      l_last_amended_by            OKC_SECTIONS_B.LAST_AMENDED_BY%TYPE;
      l_last_amendment_date        OKC_SECTIONS_B.LAST_AMENDMENT_DATE%TYPE;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	 FND_LOG.STRING(G_PROC_LEVEL,
    	     G_PKG_NAME, '3100: Entered validate_row');
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_object_version_number      => p_object_version_number,
      p_last_amended_by            => NULL,
      p_last_amendment_date        => NULL,
      x_section_sequence           => l_section_sequence,
      x_label                      => l_label,
      x_scn_id                     => l_scn_id,
      x_heading                    => l_heading,
      x_object_version_number      => l_object_version_number,
      x_description                => l_description,
      x_document_type              => l_document_type,
      x_document_id                => l_document_id,
      x_scn_code                   => l_scn_code,
      x_amendment_description      => l_amendment_description,
      x_amendment_operation_code   => l_amendment_operation_code,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_print_yn                   => l_print_yn,
      x_attribute_category         => l_attribute_category,
      x_attribute1                 => l_attribute1,
      x_attribute2                 => l_attribute2,
      x_attribute3                 => l_attribute3,
      x_attribute4                 => l_attribute4,
      x_attribute5                 => l_attribute5,
      x_attribute6                 => l_attribute6,
      x_attribute7                 => l_attribute7,
      x_attribute8                 => l_attribute8,
      x_attribute9                 => l_attribute9,
      x_attribute10                => l_attribute10,
      x_attribute11                => l_attribute11,
      x_attribute12                => l_attribute12,
      x_attribute13                => l_attribute13,
      x_attribute14                => l_attribute14,
      x_attribute15                => l_attribute15,
      x_summary_amend_operation_code => l_summary_amend_operation_code,
      x_last_amended_by            => l_last_amended_by,
      x_last_amendment_date        => l_last_amendment_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_id                         => p_id,
      p_section_sequence           => l_section_sequence,
      p_label                      => l_label,
      p_scn_id                     => l_scn_id,
      p_heading                    => l_heading,
      p_description                => l_description,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_scn_code                   => l_scn_code,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_print_yn                   => l_print_yn,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_summary_amend_operation_code => l_summary_amend_operation_code
    );

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3200: Leaving validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '3200: Leaving validate_row' );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_EXCP_LEVEL,
  	      G_PKG_NAME, '3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_EXCP_LEVEL,
  	      G_PKG_NAME, '3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_EXCP_LEVEL,
  	      G_PKG_NAME, '3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Validate_Row;

  ---------------------------------------------------------------------------
  -- PROCEDURE Insert_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Insert_Row for:OKC_SECTIONS_B --
  -------------------------------------
  FUNCTION Insert_Row(
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_object_version_number      IN NUMBER,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE

  ) RETURN VARCHAR2 IS

   l_chr_id   NUMBER;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '3600: Entered Insert_Row function' );
    END IF;
    IF p_document_type IN ('OKC_SELL','OKC_BUY','OKO','OKS','OKE_SELL','OKE_BUY','OKL') THEN
       l_chr_id := okc_terms_util_pvt.get_chr_id_for_doc_id(p_document_id);
    END IF;

    INSERT INTO OKC_SECTIONS_B(
        ID,
        SECTION_SEQUENCE,
        SCN_TYPE,
        CHR_ID,
        SAT_CODE,
        LABEL,
        SCN_ID,
        HEADING,
        DESCRIPTION,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SCN_CODE,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        PRINT_YN,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SUMMARY_AMEND_OPERATION_CODE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE)
      VALUES (
        p_id,
        p_section_sequence,
        Null,
        l_chr_id,
        Null,
        p_label,
        p_scn_id,
        p_heading,
        p_description,
        p_document_type,
        p_document_id,
        p_scn_code,
        p_amendment_description,
        p_amendment_operation_code,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        p_print_yn,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_summary_amend_operation_code,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
        p_last_amended_by,
        p_last_amendment_date);

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3700: Leaving Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '3700: Leaving Insert_Row' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3800: Leaving Insert_Row:OTHERS Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '3800: Leaving Insert_Row:OTHERS Exception' );
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );

  END Insert_Row;


  -------------------------------------
  -- Insert_Row for:OKC_SECTIONS_B --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    x_id                         OUT NOCOPY NUMBER

  ) IS

    l_object_version_number      OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_SECTIONS_B.CREATED_BY%TYPE;
    l_creation_date              OKC_SECTIONS_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_SECTIONS_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_SECTIONS_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_SECTIONS_B.LAST_UPDATE_DATE%TYPE;
    l_last_amended_by            OKC_SECTIONS_B.LAST_AMENDED_BY%TYPE;
    l_last_amendment_date        OKC_SECTIONS_B.LAST_AMENDMENT_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '4200: Entered Insert_Row' );
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_id => p_id,
        x_id => x_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_id := p_id;
    END IF;
    -- Set Internal columns
    l_object_version_number      := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;
    IF p_amendment_operation_code IS NOT NULL THEN
      l_last_amendment_date := l_creation_date;
      l_last_amended_by := l_created_by;
    END IF;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_id                         => x_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_summary_amend_operation_code => p_summary_amend_operation_code
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --------------------------------------------
    -- Call the internal Insert_Row for each child record
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4300: Call the internal Insert_Row for Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '4300: Call the internal Insert_Row for Base Table' );
    END IF;

    x_return_status := Insert_Row(
      p_id                         => x_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_object_version_number      => l_object_version_number,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_last_amended_by            => l_last_amended_by,
      p_last_amendment_date        => l_last_amendment_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4500: Leaving Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '4500: Leaving Insert_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Insert_Row;
  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- Lock_Row for:OKC_SECTIONS_B --
  -----------------------------------
  FUNCTION Lock_Row(
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) RETURN VARCHAR2 IS


    CURSOR lock_csr (cp_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_SECTIONS_B
     WHERE ID = cp_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_SECTIONS_B
     WHERE ID = cp_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '4900: Entered Lock_Row');
    END IF;

    BEGIN

      OPEN lock_csr( p_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        /*IF (l_debug = 'Y') THEN
           Okc_Debug.Log('5000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
        END IF;*/

	IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '5000: Leaving Lock_Row:E_Resource_Busy Exception' );
	END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_APP_NAME,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_SECTIONS_B',
                   'PKEY',p_id,
                   'OVN',p_object_version_number
                    );
      ELSIF l_object_version_number > p_object_version_number THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      ELSIF l_object_version_number = -1 THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      ELSE -- it can be the only above condition. It can happen after restore version
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      END IF;
     ELSE
      l_return_status := G_RET_STS_SUCCESS;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5100: Leaving Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '5100: Leaving Lock_Row');
    END IF;

    RETURN( l_return_status );

  EXCEPTION
    WHEN OTHERS THEN

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      IF (lchk_csr%ISOPEN) THEN
        CLOSE lchk_csr;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
  	 FND_LOG.STRING(G_PROC_LEVEL,
    	     G_PKG_NAME, '5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );
  END Lock_Row;

  -----------------------------------
  -- Lock_Row for:OKC_SECTIONS_B --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
   ) IS
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5700: Entered Lock_Row', 2);
       Okc_Debug.Log('5800: Locking Row for Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '5700: Entered Lock_Row');
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '5800: Locking Row for Base Table');
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each _B child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('6000: Leaving Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '6000: Leaving Lock_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm );
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Lock_Row;
  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Update_Row for:OKC_SECTIONS_B --
  -------------------------------------
  FUNCTION Update_Row(
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_object_version_number      IN NUMBER,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE
   ) RETURN VARCHAR2 IS

   l_chr_id   NUMBER;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '6400: Entered Update_Row');
    END IF;
    IF p_document_type IN ('OKC_SELL','OKC_BUY','OKO','OKS','OKE_SELL','OKE_BUY','OKL') THEN
       l_chr_id := okc_terms_util_pvt.get_chr_id_for_doc_id(p_document_id);
    END IF;

    UPDATE OKC_SECTIONS_B
     SET SECTION_SEQUENCE           = p_section_sequence,
         LABEL                      = p_label,
         SCN_ID                     = p_scn_id,
         HEADING                    = p_heading,
         DESCRIPTION                = p_description,
         DOCUMENT_TYPE              = p_document_type,
         DOCUMENT_ID                = p_document_id,
         CHR_ID                     = l_chr_id,
         SCN_CODE                   = p_scn_code,
         AMENDMENT_DESCRIPTION      = p_amendment_description,
         AMENDMENT_OPERATION_CODE   = p_amendment_operation_code,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1  = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2  = p_orig_system_reference_id2,
         PRINT_YN                   = p_print_yn,
         ATTRIBUTE_CATEGORY         = p_attribute_category,
         ATTRIBUTE1                 = p_attribute1,
         ATTRIBUTE2                 = p_attribute2,
         ATTRIBUTE3                 = p_attribute3,
         ATTRIBUTE4                 = p_attribute4,
         ATTRIBUTE5                 = p_attribute5,
         ATTRIBUTE6                 = p_attribute6,
         ATTRIBUTE7                 = p_attribute7,
         ATTRIBUTE8                 = p_attribute8,
         ATTRIBUTE9                 = p_attribute9,
         ATTRIBUTE10                = p_attribute10,
         ATTRIBUTE11                = p_attribute11,
         ATTRIBUTE12                = p_attribute12,
         ATTRIBUTE13                = p_attribute13,
         ATTRIBUTE14                = p_attribute14,
         ATTRIBUTE15                = p_attribute15,
         SUMMARY_AMEND_OPERATION_CODE = p_summary_amend_operation_code,
         OBJECT_VERSION_NUMBER      = p_object_version_number,
         LAST_UPDATED_BY            = p_last_updated_by,
         LAST_UPDATE_LOGIN          = p_last_update_login,
         LAST_UPDATE_DATE           = p_last_update_date,
         LAST_AMENDED_BY            = p_last_amended_by,
         LAST_AMENDMENT_DATE        = p_last_amendment_date
    WHERE ID                        = p_id;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6500: Leaving Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '6500: Leaving Update_Row');
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
     	 	G_PKG_NAME, '6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Update_Row;

  -------------------------------------
  -- Update_Row for:OKC_SECTIONS_B --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE,
    p_object_version_number      IN NUMBER

   ) IS

    l_section_sequence           OKC_SECTIONS_B.SECTION_SEQUENCE%TYPE;
    l_label                      OKC_SECTIONS_B.LABEL%TYPE;
    l_scn_id                     OKC_SECTIONS_B.SCN_ID%TYPE;
    l_heading                    OKC_SECTIONS_B.HEADING%TYPE;
    l_description                OKC_SECTIONS_B.DESCRIPTION%TYPE;
    l_document_type              OKC_SECTIONS_B.DOCUMENT_TYPE%TYPE;
    l_document_id                OKC_SECTIONS_B.DOCUMENT_ID%TYPE;
    l_scn_code                   OKC_SECTIONS_B.SCN_CODE%TYPE;
    l_amendment_description      OKC_SECTIONS_B.AMENDMENT_DESCRIPTION%TYPE;
    l_amendment_operation_code   OKC_SECTIONS_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_orig_system_reference_code OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1  OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2  OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_print_yn                   OKC_SECTIONS_B.PRINT_YN%TYPE;
    l_attribute_category         OKC_SECTIONS_B.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1                 OKC_SECTIONS_B.ATTRIBUTE1%TYPE;
    l_attribute2                 OKC_SECTIONS_B.ATTRIBUTE2%TYPE;
    l_attribute3                 OKC_SECTIONS_B.ATTRIBUTE3%TYPE;
    l_attribute4                 OKC_SECTIONS_B.ATTRIBUTE4%TYPE;
    l_attribute5                 OKC_SECTIONS_B.ATTRIBUTE5%TYPE;
    l_attribute6                 OKC_SECTIONS_B.ATTRIBUTE6%TYPE;
    l_attribute7                 OKC_SECTIONS_B.ATTRIBUTE7%TYPE;
    l_attribute8                 OKC_SECTIONS_B.ATTRIBUTE8%TYPE;
    l_attribute9                 OKC_SECTIONS_B.ATTRIBUTE9%TYPE;
    l_attribute10                OKC_SECTIONS_B.ATTRIBUTE10%TYPE;
    l_attribute11                OKC_SECTIONS_B.ATTRIBUTE11%TYPE;
    l_attribute12                OKC_SECTIONS_B.ATTRIBUTE12%TYPE;
    l_attribute13                OKC_SECTIONS_B.ATTRIBUTE13%TYPE;
    l_attribute14                OKC_SECTIONS_B.ATTRIBUTE14%TYPE;
    l_attribute15                OKC_SECTIONS_B.ATTRIBUTE15%TYPE;
    l_summary_amend_operation_code OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_object_version_number      OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_SECTIONS_B.CREATED_BY%TYPE;
    l_creation_date              OKC_SECTIONS_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_SECTIONS_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_SECTIONS_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_SECTIONS_B.LAST_UPDATE_DATE%TYPE;
    l_last_amended_by            OKC_SECTIONS_B.LAST_AMENDED_BY%TYPE;
    l_last_amendment_date        OKC_SECTIONS_B.LAST_AMENDMENT_DATE%TYPE;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7000: Entered Update_Row');
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7100: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Setting attributes', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7300: Setting attributes');
    END IF;

    x_return_status := Set_Attributes(
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_object_version_number      => p_object_version_number,
      p_last_amended_by            => p_last_amended_by,
      p_last_amendment_date        => p_last_amendment_date,
      x_section_sequence           => l_section_sequence,
      x_label                      => l_label,
      x_scn_id                     => l_scn_id,
      x_heading                    => l_heading,
      x_object_version_number      => l_object_version_number,
      x_description                => l_description,
      x_document_type              => l_document_type,
      x_document_id                => l_document_id,
      x_scn_code                   => l_scn_code,
      x_amendment_description      => l_amendment_description,
      x_amendment_operation_code   => l_amendment_operation_code,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_print_yn                   => l_print_yn,
      x_attribute_category         => l_attribute_category,
      x_attribute1                 => l_attribute1,
      x_attribute2                 => l_attribute2,
      x_attribute3                 => l_attribute3,
      x_attribute4                 => l_attribute4,
      x_attribute5                 => l_attribute5,
      x_attribute6                 => l_attribute6,
      x_attribute7                 => l_attribute7,
      x_attribute8                 => l_attribute8,
      x_attribute9                 => l_attribute9,
      x_attribute10                => l_attribute10,
      x_attribute11                => l_attribute11,
      x_attribute12                => l_attribute12,
      x_attribute13                => l_attribute13,
      x_attribute14                => l_attribute14,
      x_attribute15                => l_attribute15,
      x_summary_amend_operation_code => l_summary_amend_operation_code,
      x_last_amended_by            => l_last_amended_by,
      x_last_amendment_date        => l_last_amendment_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Record Validation', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7400: Record Validation');
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_id                         => p_id,
      p_section_sequence           => l_section_sequence,
      p_label                      => l_label,
      p_scn_id                     => l_scn_id,
      p_heading                    => l_heading,
      p_description                => l_description,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_scn_code                   => l_scn_code,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_print_yn                   => l_print_yn,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_summary_amend_operation_code => l_summary_amend_operation_code
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7500: Filling WHO columns', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7500: Filling WHO columns');
    END IF;

    -- Filling who columns
    l_last_update_date := SYSDATE;
    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    -- Object version increment
    IF Nvl(l_object_version_number, 0) >= 0 THEN
      l_object_version_number := Nvl(l_object_version_number, 0) + 1;
    END IF;

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7600: Updating Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7600: Updating Row');
    END IF;

    x_return_status := Update_Row(
      p_id                         => p_id,
      p_section_sequence           => l_section_sequence,
      p_label                      => l_label,
      p_scn_id                     => l_scn_id,
      p_heading                    => l_heading,
      p_description                => l_description,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_scn_code                   => l_scn_code,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_print_yn                   => l_print_yn,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_object_version_number      => l_object_version_number,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_last_amended_by            => l_last_amended_by,
      p_last_amendment_date        => l_last_amendment_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('7800: Leaving Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '7800: Leaving Update_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Update_Row;

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Delete_Row for:OKC_SECTIONS_B --
  -------------------------------------
  FUNCTION Delete_Row(
    p_id                         IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '8200: Entered Delete_Row');
    END IF;

    DELETE FROM OKC_SECTIONS_B WHERE ID = p_ID;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8300: Leaving Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '8300: Leaving Delete_Row');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );

  END Delete_Row;

  -------------------------------------
  -- Delete_Row for:OKC_SECTIONS_B --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status              OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '8800: Entered Delete_Row');
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '8900: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '9100: Removing _B row');
    END IF;
    x_return_status := Delete_Row( p_id => p_id );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9300: Leaving Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '9300: Leaving Delete_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/
      x_return_status := G_RET_STS_UNEXP_ERROR;

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
 	       G_PKG_NAME, '9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Row;

  PROCEDURE delete_set(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER
    ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
  ) IS
    CURSOR lock_csr IS
    SELECT rowid FROM OKC_SECTIONS_B
      WHERE document_type = p_doc_type and
            document_id   = p_doc_id
            AND         (( p_retain_lock_terms_yn = 'N')
                            OR
                           (p_retain_lock_terms_yn ='Y' AND amendment_operation_code IS NULL)
                         )

      FOR UPDATE NOWAIT;
   BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '9700: Entered Delete_Set');
      	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '9705: p_retain_lock_terms_yn  : ' || p_retain_lock_terms_yn);

    END IF;

    -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    DELETE FROM OKC_SECTIONS_B
      WHERE document_type = p_doc_type and
            document_id   = p_doc_id
            AND
                          (( p_retain_lock_terms_yn = 'N')
                            OR
                           (p_retain_lock_terms_yn ='Y' AND amendment_operation_code IS NULL)
                          )
             ;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '11000: Leaving Delete_set');
    END IF;

  EXCEPTION
    WHEN E_Resource_Busy THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '000: Leaving Delete_set:E_Resource_Busy Exception' );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception' );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Set;


--This function is to be called from versioning API OKC_VERSION_PVT
  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered create_version', 2);
       Okc_Debug.Log('9800: Saving Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '9700: Entered create_version' );
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '9800: Saving Base Table' );
    END IF;

    -----------------------------------------
    -- Saving Base Table
    -----------------------------------------
    INSERT INTO OKC_SECTIONS_BH (
        major_version,
        ID,
        SECTION_SEQUENCE,
        SCN_TYPE,
        CHR_ID,
        SAT_CODE,
        LABEL,
        SCN_ID,
        HEADING,
        DESCRIPTION,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SCN_CODE,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        PRINT_YN,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SUMMARY_AMEND_OPERATION_CODE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE)
     SELECT
        p_major_version,
        ID,
        SECTION_SEQUENCE,
        SCN_TYPE,
        CHR_ID,
        SAT_CODE,
        LABEL,
        SCN_ID,
        HEADING,
        DESCRIPTION,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SCN_CODE,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        PRINT_YN,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SUMMARY_AMEND_OPERATION_CODE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE
      FROM OKC_SECTIONS_B
      WHERE document_type = p_doc_type
      AND   document_id   = p_doc_id;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10000: Leaving create_version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '10000: Leaving create_version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10100: Leaving create_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '10100: Leaving create_version because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT

  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10200: Entered restore_version', 2);
       Okc_Debug.Log('10300: Restoring Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '10200: Entered restore_version' );
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '10300: Restoring Base Table' );
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    INSERT INTO OKC_SECTIONS_B (
        ID,
        SECTION_SEQUENCE,
        SCN_TYPE,
        CHR_ID,
        SAT_CODE,
        LABEL,
        SCN_ID,
        HEADING,
        DESCRIPTION,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SCN_CODE,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        PRINT_YN,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SUMMARY_AMEND_OPERATION_CODE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE)
     SELECT
        ID,
        SECTION_SEQUENCE,
        SCN_TYPE,
        CHR_ID,
        SAT_CODE,
        LABEL,
        SCN_ID,
        HEADING,
        DESCRIPTION,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SCN_CODE,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        PRINT_YN,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SUMMARY_AMEND_OPERATION_CODE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE
      FROM OKC_SECTIONS_BH
      WHERE document_type = p_doc_type and document_id = p_doc_id AND major_version = p_major_version;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10500: Leaving restore_version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	     G_PKG_NAME, '10500: Leaving restore_version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10600: Leaving restore_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '10600: Leaving restore_version because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END restore_version;

--This Function is called from Versioning API OKC_VERSION_PVT
-- to delete sections for specified version of document

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7200: Entered Delete_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
 	       G_PKG_NAME, '7200: Entered Delete_Version' );
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    DELETE
      FROM OKC_SECTIONS_BH
      WHERE document_type = p_doc_type and document_id = p_doc_id AND major_version = p_major_version;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Leaving Delete_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
 	       G_PKG_NAME, '7300: Leaving Delete_Version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	        G_PKG_NAME, '7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Delete_Version;

END OKC_TERMS_SECTIONS_PVT;

/
