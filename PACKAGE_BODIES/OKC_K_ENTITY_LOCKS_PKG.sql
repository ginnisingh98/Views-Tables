--------------------------------------------------------
--  DDL for Package Body OKC_K_ENTITY_LOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ENTITY_LOCKS_PKG" 
/* $Header: OKCVELKB.pls 120.0.12010000.1 2011/12/09 11:58:49 serukull noship $ */

AS

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_ENTITY_LOCKS_PKG';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	                     CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30) := 'DELETED';
  G_AMEND_CODE_ADDED           CONSTANT   VARCHAR2(30) := 'ADDED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30) := 'UPDATED';

  G_DBG_LEVEL							    NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;
  G_STMT_LEVEL                NUMBER    := FND_LOG.LEVEL_STATEMENT;


PROCEDURE insert_row ( p_entity_name IN VARCHAR2,
                       p_entity_pk1 IN VARCHAR2,
                       p_entity_pk2 IN VARCHAR2,
                       p_entity_pk3 IN VARCHAR2,
                       p_entity_pk4 IN VARCHAR2,
                       p_entity_pk5 IN VARCHAR2,
                       P_LOCK_BY_ENTITY_ID IN NUMBER,
                       P_LOCK_by_document_type IN VARCHAR2,
                       p_LOCK_by_document_id IN NUMBER,
                       P_OBJECT_VERSION_NUMBER IN NUMBER,
                       P_CREATED_BY  IN NUMBER,
                       P_CREATION_DATE  IN  DATE,
                       P_LAST_UPDATED_BY  IN NUMBER,
                       P_LAST_UPDATE_DATE  IN DATE,
                       P_LAST_UPDATE_LOGIN  IN NUMBER,
                       x_k_entity_lock_id OUT NOCOPY NUMBER,
                       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                       X_MSG_COUNT OUT NOCOPY NUMBER,
                       X_MSG_DATA OUT NOCOPY VARCHAR2
                      )
IS
BEGIN

    IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_STMT_LEVEL,
     	   G_PKG_NAME, '1000: Entered Insert_Row Procedure' );
    END IF;


   INSERT INTO okc_k_entity_locks(
                  k_entity_lock_id,
                  entity_name,
                  entity_pk1,
                  entity_pk2,
                  entity_pk3,
                  entity_pk4,
                  entity_pk5,
                  LOCK_BY_ENTITY_ID,
                  LOCK_BY_DOCUMENT_TYPE,
                  LOCK_BY_DOCUMENT_ID,
                  OBJECT_VERSION_NUMBER,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN
                                  )
        VALUES(
               okc_k_entity_locks_s.NEXTVAL,
               P_ENTITY_NAME,
               p_entity_pk1,
               p_entity_pk2,
               p_entity_pk3,
               p_entity_pk4,
               p_entity_pk5,
               P_LOCK_BY_ENTITY_ID,
               P_LOCK_BY_DOCUMENT_TYPE,
               P_LOCK_BY_DOCUMENT_ID,
               P_OBJECT_VERSION_NUMBER,
               P_CREATED_BY,
               P_CREATION_DATE,
               P_LAST_UPDATED_BY,
               P_LAST_UPDATE_DATE,
               P_LAST_UPDATE_LOGIN
               )
               returning k_entity_lock_id INTO x_k_entity_lock_id;

   -- Check uniqueness

    X_RETURN_STATUS := G_RET_STS_SUCCESS;
    IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(G_STMT_LEVEL,
     	   G_PKG_NAME, '9999: Completed Insert_Row Procedure' );
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(G_STMT_LEVEL,
              G_PKG_NAME, '0000: Leaving Insert_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      X_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      --FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END insert_row;

PROCEDURE delete_row (P_ENTITY_NAME IN VARCHAR2,
                      p_entity_pk1 IN VARCHAR2,
                      p_entity_pk2 IN VARCHAR2,
                      p_entity_pk3 IN VARCHAR2,
                      p_entity_pk4 IN VARCHAR2,
                      p_entity_pk5 IN VARCHAR2,
                      P_LOCK_BY_ENTITY_ID IN NUMBER,
                      P_LOCK_by_document_type IN VARCHAR2,
                      p_LOCK_by_document_id IN NUMBER,
                      X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                      X_MSG_COUNT OUT NOCOPY NUMBER,
                      X_MSG_DATA OUT NOCOPY VARCHAR2
                     )
IS

l_del_Sql VARCHAR2(2000);

BEGIN

    IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: Entered delete_row ');
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: P_ENTITY_NAME ' || P_ENTITY_NAME );
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_entity_pk1 ' ||p_entity_pk1 );
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_entity_pk2 '||p_entity_pk2);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_entity_pk3 '||p_entity_pk3);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_entity_pk4  '||p_entity_pk4);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_entity_pk5  '||p_entity_pk5);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: P_LOCK_BY_ENTITY_ID  '||P_LOCK_BY_ENTITY_ID);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: P_LOCK_by_document_type  '||P_LOCK_by_document_type);
        FND_LOG.STRING(G_STMT_LEVEL, G_PKG_NAME, '0100: p_LOCK_by_document_id  '||p_LOCK_by_document_id);
    END IF;


l_del_Sql := 'DELETE FROM OKC_K_ENTITY_LOCKS WHERE ENTITY_NAME = P_ENTITY_NAME AND ENTITY_PK1 = '|| ''''||p_entity_pk1 ||'''';

 IF p_entity_pk2 IS NOT NULL THEN
  l_del_Sql :=  l_del_Sql || ' AND ENTITY_PK2  = '|| ''''||p_entity_pk2||'''';
 END IF;
 IF p_entity_pk3 IS NOT NULL THEN
  l_del_Sql := l_del_Sql || ' AND ENTITY_PK3  = '||''''||p_entity_pk3||'''';
 END IF;
 IF p_entity_pk4 IS NOT NULL THEN
 l_del_Sql :=  l_del_Sql ||  ' AND ENTITY_PK4  = '||''''||p_entity_pk4||'''';
 END IF;
 IF p_entity_pk5 IS NOT NULL THEN
 l_del_Sql :=  l_del_Sql ||  ' AND ENTITY_PK5  = '||''''||p_entity_pk5||'''';
 END IF;
 IF P_LOCK_BY_ENTITY_ID IS NOT NULL THEN
  l_del_Sql :=  l_del_Sql ||  ' AND LOCK_BY_ENTITY_ID  = '||P_LOCK_BY_ENTITY_ID;
 END IF;
 IF P_LOCK_by_document_type IS NOT NULL THEN
  l_del_Sql :=  l_del_Sql ||  ' AND LOCK_BY_DOCUMENT_TYPE  = '||''''||P_LOCK_by_document_type||'''';
 END IF;
 IF p_LOCK_by_document_id IS NOT NULL THEN
   l_del_Sql :=  l_del_Sql ||  ' AND LOCK_BY_DOCUMENT_ID  = '||p_LOCK_by_document_id;
 END IF;

     IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(G_STMT_LEVEL,
              G_PKG_NAME, '0500: sql to delete the lock: '||l_del_Sql);
     END IF;


   EXECUTE IMMEDIATE l_del_Sql;

   IF (SQL%NOTFOUND) THEN
     RAISE No_Data_Found;
   END IF;

   X_RETURN_STATUS := G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
      IF (  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(G_STMT_LEVEL,
              G_PKG_NAME, '0000: Leaving DELETE_row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);
      X_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      --FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END DELETE_row;

END okc_k_entity_locks_pkg;

/
