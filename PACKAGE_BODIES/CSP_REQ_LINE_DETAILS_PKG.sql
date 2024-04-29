--------------------------------------------------------
--  DDL for Package Body CSP_REQ_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQ_LINE_DETAILS_PKG" as
/* $Header: csptrldb.pls 120.1.12010000.6 2013/06/06 12:47:18 htank ship $ */
-- Start of Comments
-- Package name     : CSP_REQUIREMENT_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQ_LINE_DETAILS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptrldb.pls';

PROCEDURE Insert_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER,
          p_DML_MODE VARCHAR2)
 IS
   CURSOR C2 IS SELECT CSP_REQ_LINE_DETAILS_S1.nextval FROM sys.dual;
   l_req_line_details CSP_REQ_LINE_DETAILS_PVT.Req_line_details_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQ_LINE_DETAILS_PKG.INSERT_ROW';
   l_dml_mode varchar2(10) := p_dml_mode;

	l_module_name VARCHAR2(100)	:= 'csp.plsql.csp_req_line_details_pkg.insert_row';

BEGIN

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'BEGIN...');
	end if;

          l_req_line_details.REQ_LINE_DETAIL_ID := px_REQ_LINE_DETAIL_ID ;
          l_req_line_details.REQUIREMENT_LINE_ID := p_REQUIREMENT_LINE_ID ;
          l_req_line_details.CREATED_BY          := p_CREATED_BY;
          l_req_line_details.CREATION_DATE       := p_CREATION_DATE;
          l_req_line_details.LAST_UPDATED_BY     :=p_LAST_UPDATED_BY;
          l_req_line_details.LAST_UPDATE_DATE    :=p_LAST_UPDATE_DATE;
          l_req_line_details.LAST_UPDATE_LOGIN   :=p_LAST_UPDATE_LOGIN ;
          l_req_line_details.SOURCE_TYPE         :=p_SOURCE_TYPE;
          l_req_line_details.SOURCE_ID           :=p_SOURCE_ID;

        IF l_dml_mode is null THEN
          l_dml_mode :='BOTH';
        END IF;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			l_module_name,
			'l_dml_mode = ' || l_dml_mode);
	end if;

        IF l_dml_mode <> 'POST' THEN
			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					l_module_name,
					'before calling csp_req_line_details_iuhk.Create_req_line_detail_Pre...');
			end if;

            csp_req_line_details_iuhk.Create_req_line_detail_Pre
                ( x_return_status          => l_return_status
                ) ;
			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					l_module_name,
					'after calling csp_req_line_details_iuhk.Create_req_line_detail_Pre. l_return_status = ' || l_return_status);
			end if;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       If (l_req_line_details.REQ_LINE_DETAIL_ID IS NULL) OR (l_req_line_details.REQ_LINE_DETAIL_ID = FND_API.G_MISS_NUM) then
           OPEN C2;
           FETCH C2 INTO  px_REQ_LINE_DETAIL_ID;
           CLOSE C2;
       End If;
   END IF;
   l_req_line_details.REQ_LINE_DETAIL_ID := px_REQ_LINE_DETAIL_ID ;
   user_hook_rec.REQ_LINE_DETAIL_ID := l_req_line_details.REQ_LINE_DETAIL_ID;

   IF l_dml_mode = 'BOTH' THEN

   INSERT INTO CSP_REQ_LINE_DETAILS(
           REQ_LINE_DETAIL_ID,
           REQUIREMENT_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           SOURCE_TYPE,
           SOURCE_ID
           )
   VALUES (
           px_REQ_LINE_DETAIL_ID,
           decode( l_req_line_details.REQUIREMENT_LINE_ID, FND_API.G_MISS_NUM, NULL, l_req_line_details.REQUIREMENT_LINE_ID),
           decode( l_req_line_details.CREATED_BY, FND_API.G_MISS_NUM, NULL, l_req_line_details.CREATED_BY),
           decode( l_req_line_details.CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_req_line_details.CREATION_DATE),
           decode( l_req_line_details.LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, l_req_line_details.LAST_UPDATED_BY),
           decode( l_req_line_details.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), l_req_line_details.LAST_UPDATE_DATE),
           decode( l_req_line_details.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, l_req_line_details.LAST_UPDATE_LOGIN),
           decode( l_req_line_details.SOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, l_req_line_details.SOURCE_TYPE),
           decode( l_req_line_details.SOURCE_ID, FND_API.G_MISS_NUM, NULL, l_req_line_details.SOURCE_ID)
            );
      END IF;

      IF l_dml_mode <> 'PRE' THEN
         user_hook_rec.REQUIREMENT_LINE_ID  := l_req_line_details.REQUIREMENT_LINE_ID;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					l_module_name,
					'before calling csp_req_line_details_iuhk.Create_req_line_detail_Post...');
			end if;

		  csp_req_line_details_iuhk.Create_req_line_detail_Post
                ( x_return_status          => l_return_status
                ) ;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					l_module_name,
					'after calling csp_req_line_details_iuhk.Create_req_line_detail_Post. l_return_status = ' || l_return_status);
			end if;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_POST_INT_USR_HK');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
End Insert_Row;

PROCEDURE Update_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER,
          p_DML_MODE VARCHAR2)
 IS
   l_req_line_details CSP_REQ_line_details_PVT.Req_LINE_Details_Rec_Type;
   l_api_name_full    varchar2(50) := 'CSP_REQ_LINE_DETAILS_PKG.UPDATE_ROW';
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_dml_mode varchar2(10) := p_dml_mode;
 BEGIN
    l_req_line_details.REQ_LINE_DETAIL_ID := px_REQ_LINE_DETAIL_ID ;
          l_req_line_details.REQUIREMENT_LINE_ID := p_REQUIREMENT_LINE_ID ;
          l_req_line_details.CREATED_BY          := p_CREATED_BY;
          l_req_line_details.CREATION_DATE       := p_CREATION_DATE;
          l_req_line_details.LAST_UPDATED_BY     :=p_LAST_UPDATED_BY;
          l_req_line_details.LAST_UPDATE_DATE    :=p_LAST_UPDATE_DATE;
          l_req_line_details.LAST_UPDATE_LOGIN   :=p_LAST_UPDATE_LOGIN ;
          l_req_line_details.SOURCE_TYPE         :=p_SOURCE_TYPE;
          l_req_line_details.SOURCE_ID           :=p_SOURCE_ID;
      IF l_dml_mode is null THEN
          l_dml_mode :='BOTH';
      END IF;

      IF l_dml_mode <> 'POST' THEN

            user_hook_rec.REQ_LINE_DETAIL_ID := l_req_line_details.REQ_LINE_DETAIL_ID;
            csp_req_line_details_iuhk.Update_req_line_detail_Pre
                ( x_return_status          => l_return_status
                ) ;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      IF l_dml_mode = 'BOTH' THEN

    Update CSP_REQ_LINE_DETAILS
    SET
              REQUIREMENT_LINE_ID = decode( l_req_line_details.REQUIREMENT_LINE_ID, FND_API.G_MISS_NUM, REQUIREMENT_LINE_ID, l_req_line_details.REQUIREMENT_LINE_ID),
              CREATED_BY = decode( l_req_line_details.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_req_line_details.CREATED_BY),
              CREATION_DATE = decode( l_req_line_details.CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, l_req_line_details.CREATION_DATE),
              LAST_UPDATED_BY = decode( l_req_line_details.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_req_line_details.LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( l_req_line_details.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, l_req_line_details.LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( l_req_line_details.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_req_line_details.LAST_UPDATE_LOGIN),
              SOURCE_TYPE = decode( l_req_line_details.SOURCE_TYPE, FND_API.G_MISS_CHAR, SOURCE_TYPE, l_req_line_details.SOURCE_TYPE),
              SOURCE_ID = decode( l_req_line_details.SOURCE_ID, FND_API.G_MISS_NUM, SOURCE_ID, l_req_line_details.SOURCE_ID)
    where REQ_LINE_DETAIL_ID = l_req_line_details.REQ_LINE_DETAIL_ID;
    END IF;

    IF l_dml_mode <> 'PRE' THEN
             csp_req_line_details_iuhk.Update_req_line_detail_post
                ( x_return_status          => l_return_status
                ) ;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
	/*
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
	*/
   END IF;
END Update_Row;

PROCEDURE Delete_Row(
    px_REQ_LINE_DETAIL_ID  NUMBER,
    p_DML_MODE VARCHAR2)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full    varchar2(50) := 'CSP_REQ_LINE_DETAILS_PKG.DELETE_ROW';
   l_dml_mode varchar2(10) := p_dml_mode;
 BEGIN
   IF l_dml_mode is null THEN
          l_dml_mode :='BOTH';
   END IF;

   IF l_dml_mode <> 'POST' THEN
          user_hook_rec.REQ_LINE_DETAIL_ID := px_REQ_LINE_DETAIL_ID;
            csp_req_line_details_iuhk.delete_req_line_detail_Pre
                ( x_return_status          => l_return_status
                ) ;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
                FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
    END IF;

    IF l_dml_mode = 'BOTH' THEN
     DELETE FROM CSP_REQ_LINE_DETAILS
      WHERE REQ_LINE_DETAIL_ID = px_REQ_LINE_DETAIL_ID;
    END IF;

    IF l_dml_mode <> 'PRE' THEN
      csp_req_line_details_iuhk.delete_req_line_detail_Post
                  ( x_return_status          => l_return_status
                  ) ;
              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
                  FND_MESSAGE.Set_Name('CSP', 'CSP_ERR_INT_CUST_USR_HK');
                  FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
			  /*
     If (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
     End If;*/
   END IF;
END Delete_Row;

PROCEDURE Lock_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_REQ_LINE_DETAILS
        WHERE REQ_LINE_DETAIL_ID =  px_REQ_LINE_DETAIL_ID
        FOR UPDATE of REQ_LINE_DETAIL_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.REQ_LINE_DETAIL_ID = px_REQ_LINE_DETAIL_ID)
       AND (    ( Recinfo.REQUIREMENT_LINE_ID = p_REQUIREMENT_LINE_ID)
            OR (    ( Recinfo.REQUIREMENT_LINE_ID IS NULL )
                AND (  p_REQUIREMENT_LINE_ID IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.SOURCE_TYPE = p_SOURCE_TYPE)
            OR (    ( Recinfo.SOURCE_TYPE IS NULL )
                AND (  p_SOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.SOURCE_ID = p_SOURCE_ID)
            OR (    ( Recinfo.SOURCE_ID IS NULL )
                AND (  p_SOURCE_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
End CSP_REQ_LINE_DETAILS_PKG;

/
