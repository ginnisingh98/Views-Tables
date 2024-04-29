--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_HEADERS_PKG" as
/* $Header: csftdbhb.pls 120.5.12010000.2 2008/08/05 18:05:14 syenduri ship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_HEADERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csftdbfb.pls';

PROCEDURE Insert_Row(
          px_DEBRIEF_HEADER_ID   IN OUT NOCOPY NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
	      p_commit         IN  VARCHAR2 DEFAULT Null, -- added for bug 3565704
           p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null,
          p_DML_mode                           VARCHAR2
          )

 IS
   CURSOR C2 IS SELECT CSF_DEBRIEF_HEADERS_S1.nextval FROM sys.dual;
   l_api_name_full varchar2(50) := 'CSF_DEBRIEF_HEADERS_PKG.INSERT_ROW';
   l_debrief_header CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_commit           varchar2(2);   -- added for bug 3565704
   l_dml_mode 		  varchar2(10) := p_DML_mode;
BEGIN
          l_debrief_header.DEBRIEF_HEADER_ID := px_DEBRIEF_HEADER_ID   ;
          l_debrief_header.DEBRIEF_NUMBER     := p_DEBRIEF_NUMBER    ;
          l_debrief_header.DEBRIEF_DATE       := p_DEBRIEF_DATE    ;
          l_debrief_header.DEBRIEF_STATUS_ID  := p_DEBRIEF_STATUS_ID    ;
          l_debrief_header.TASK_ASSIGNMENT_ID := p_TASK_ASSIGNMENT_ID    ;
          l_debrief_header.CREATED_BY         := p_CREATED_BY    ;
          l_debrief_header.CREATION_DATE      := p_CREATION_DATE   ;
          l_debrief_header.LAST_UPDATED_BY    := p_LAST_UPDATED_BY    ;
          l_debrief_header.LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE    ;
          l_debrief_header.LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN    ;
          l_debrief_header.ATTRIBUTE1         := p_ATTRIBUTE1    ;
          l_debrief_header.ATTRIBUTE2         := p_ATTRIBUTE2    ;
           l_debrief_header.ATTRIBUTE3        := p_ATTRIBUTE3    ;
          l_debrief_header.ATTRIBUTE4         := p_ATTRIBUTE4    ;
          l_debrief_header.ATTRIBUTE5         := p_ATTRIBUTE5    ;
          l_debrief_header.ATTRIBUTE6         := p_ATTRIBUTE6    ;
          l_debrief_header.ATTRIBUTE7         := p_ATTRIBUTE7    ;
          l_debrief_header.ATTRIBUTE8         := p_ATTRIBUTE8    ;
          l_debrief_header.ATTRIBUTE9         := p_ATTRIBUTE9    ;
          l_debrief_header.ATTRIBUTE10        := p_ATTRIBUTE10    ;
          l_debrief_header.ATTRIBUTE11         := p_ATTRIBUTE11    ;
          l_debrief_header.ATTRIBUTE12        := p_ATTRIBUTE12    ;
          l_debrief_header.ATTRIBUTE13        := p_ATTRIBUTE13    ;
          l_debrief_header.ATTRIBUTE14        := p_ATTRIBUTE14    ;
          l_debrief_header.ATTRIBUTE15        := p_ATTRIBUTE15    ;
          l_debrief_header.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
          l_debrief_header.object_version_number :=p_object_version_number;
          l_debrief_header.TRAVEL_START_TIME      :=p_TRAVEL_START_TIME;
          l_debrief_header.TRAVEL_END_TIME        :=p_TRAVEL_END_TIME;
          l_debrief_header.TRAVEL_DISTANCE_IN_KM  :=p_TRAVEL_DISTANCE_IN_KM;

    IF l_dml_mode is null THEN
      l_dml_mode := 'BOTH';
    END IF;

    IF l_dml_mode <> 'POST' THEN
      IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                          'Insert_Row',
                                          'B', 'C')  THEN

                csf_debrief_headers_cuhk.Create_debrief_header_Pre
                    ( px_debrief_header     => l_debrief_header,
                      x_return_status          => l_return_status,
                      x_msg_count              => l_msg_count,
                      x_msg_data               => l_msg_data
                    ) ;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
          FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Insert_Row',
                                      'B', 'V')  THEN
    csf_debrief_headers_vuhk.Create_debrief_header_Pre
                ( px_debrief_header     => l_debrief_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_API_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csf_debrief_headers_iuhk.Create_debrief_header_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   IF l_dml_mode = 'BOTH' THEN
     If (l_debrief_header.DEBRIEF_HEADER_ID IS NULL) OR (l_debrief_header.DEBRIEF_HEADER_ID = FND_API.G_MISS_NUM) then
         OPEN C2;
         FETCH C2 INTO px_DEBRIEF_HEADER_ID;
         CLOSE C2;
     End If;
   END IF;

   l_debrief_header.DEBRIEF_HEADER_ID := px_DEBRIEF_HEADER_ID;
   user_hooks_rec.DEBRIEF_HEADER_ID := l_debrief_header.DEBRIEF_HEADER_ID;

   IF l_dml_mode = 'BOTH' THEN
     INSERT INTO CSF_DEBRIEF_HEADERS(
             DEBRIEF_HEADER_ID,
             DEBRIEF_NUMBER,
             DEBRIEF_DATE,
             DEBRIEF_STATUS_ID,
             TASK_ASSIGNMENT_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
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
             ATTRIBUTE_CATEGORY,
             OBJECT_VERSION_NUMBER,
             TRAVEL_START_TIME,
             TRAVEL_END_TIME,
             TRAVEL_DISTANCE_IN_KM,
             PROCESSED_FLAG
            ) VALUES (
             px_DEBRIEF_HEADER_ID,
             decode( l_debrief_header.DEBRIEF_NUMBER, FND_API.G_MISS_CHAR, NULL, l_debrief_header.DEBRIEF_NUMBER),
             decode( l_debrief_header.DEBRIEF_DATE, FND_API.G_MISS_DATE, to_date(null), l_debrief_header.DEBRIEF_DATE),
             decode( l_debrief_header.DEBRIEF_STATUS_ID, FND_API.G_MISS_NUM, NULL, l_debrief_header.DEBRIEF_STATUS_ID),
             decode( l_debrief_header.TASK_ASSIGNMENT_ID, FND_API.G_MISS_NUM, NULL, l_debrief_header.TASK_ASSIGNMENT_ID),
             decode( l_debrief_header.CREATED_BY, FND_API.G_MISS_NUM, fnd_global.user_id, l_debrief_header.CREATED_BY),
             decode( l_debrief_header.CREATION_DATE, FND_API.G_MISS_DATE, sysdate, l_debrief_header.CREATION_DATE),
             decode( l_debrief_header.LAST_UPDATED_BY, FND_API.G_MISS_NUM, fnd_global.user_id, l_debrief_header.LAST_UPDATED_BY),
             decode( l_debrief_header.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, sysdate, l_debrief_header.LAST_UPDATE_DATE),
             decode( l_debrief_header.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, fnd_global.conc_login_id, l_debrief_header.LAST_UPDATE_LOGIN),
             decode( l_debrief_header.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE1),
             decode( l_debrief_header.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE2),
             decode( l_debrief_header.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE3),
             decode( l_debrief_header.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE4),
             decode( l_debrief_header.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE5),
             decode( l_debrief_header.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE6),
             decode( l_debrief_header.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE7),
             decode( l_debrief_header.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE8),
             decode( l_debrief_header.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE9),
             decode( l_debrief_header.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE10),
             decode( l_debrief_header.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE11),
             decode( l_debrief_header.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE12),
             decode( l_debrief_header.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE13),
             decode( l_debrief_header.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE14),
             decode( l_debrief_header.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE15),
             decode( l_debrief_header.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, l_debrief_header.ATTRIBUTE_CATEGORY),
             decode( l_debrief_header.OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL,l_debrief_header.OBJECT_VERSION_NUMBER),
             decode( l_debrief_header.TRAVEL_START_TIME, FND_API.G_MISS_DATE, to_date(null), l_debrief_header.TRAVEL_START_TIME),
             decode( l_debrief_header.TRAVEL_END_TIME, FND_API.G_MISS_DATE, to_date(null), l_debrief_header.TRAVEL_END_TIME),
             decode( l_debrief_header.TRAVEL_DISTANCE_IN_KM, FND_API.G_MISS_NUM, NULL, l_debrief_header.TRAVEL_DISTANCE_IN_KM),
             'UNPROCESSED'
             );
  END IF;

  IF l_dml_mode <> 'PRE' THEN
    IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                        'Insert_Row',
                                        'A', 'C')  THEN

              csf_debrief_headers_cuhk.Create_debrief_header_post
                  ( px_debrief_header     => l_debrief_header,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CS', 'CS_ERR_POST_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;
  END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Insert_Row',
                                      'A', 'V')  THEN
    csf_debrief_headers_vuhk.Create_debrief_header_post
                ( px_debrief_header     => l_debrief_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csf_debrief_headers_iuhk.Create_debrief_header_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 -- added for bug 3565704
 -- Standard check of p_commit

  if p_commit is null then
    l_commit := FND_API.G_FALSE;
  else
    l_commit := p_commit;
  end if;

-- Commented for bug 5067610
  --IF FND_API.To_Boolean(l_commit) THEN
    --COMMIT WORK;
  --END IF;
-- Till here for bug 5067610

End Insert_Row;

PROCEDURE Update_Row(
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
           p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null,
          p_DML_mode                           VARCHAR2
          )

 IS
          l_api_name_full varchar2(50) := 'CSF_DEBRIEF_HEADERS_PKG.UPDATE_ROW';
          l_debrief_header   CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type;
          l_return_status    varchar2(100);
          l_msg_count        NUMBER;
          l_msg_data         varchar2(1000);
          l_dml_mode	     varchar2(10) := p_DML_mode;
 BEGIN
          l_debrief_header.DEBRIEF_HEADER_ID := p_DEBRIEF_HEADER_ID   ;
          l_debrief_header.DEBRIEF_NUMBER     := p_DEBRIEF_NUMBER    ;
          l_debrief_header.DEBRIEF_DATE       := p_DEBRIEF_DATE    ;
          l_debrief_header.DEBRIEF_STATUS_ID  := p_DEBRIEF_STATUS_ID    ;
          l_debrief_header.TASK_ASSIGNMENT_ID := p_TASK_ASSIGNMENT_ID    ;
          l_debrief_header.CREATED_BY         := p_CREATED_BY    ;
          l_debrief_header.CREATION_DATE      := p_CREATION_DATE   ;
          l_debrief_header.LAST_UPDATED_BY    := p_LAST_UPDATED_BY    ;
          l_debrief_header.LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE    ;
          l_debrief_header.LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN    ;
          l_debrief_header.ATTRIBUTE1         := p_ATTRIBUTE1    ;
          l_debrief_header.ATTRIBUTE2         := p_ATTRIBUTE2    ;
           l_debrief_header.ATTRIBUTE3        := p_ATTRIBUTE3    ;
          l_debrief_header.ATTRIBUTE4         := p_ATTRIBUTE4    ;
          l_debrief_header.ATTRIBUTE5         := p_ATTRIBUTE5    ;
          l_debrief_header.ATTRIBUTE6         := p_ATTRIBUTE6    ;
          l_debrief_header.ATTRIBUTE7         := p_ATTRIBUTE7    ;
          l_debrief_header.ATTRIBUTE8         := p_ATTRIBUTE8    ;
          l_debrief_header.ATTRIBUTE9         := p_ATTRIBUTE9    ;
          l_debrief_header.ATTRIBUTE10        := p_ATTRIBUTE10    ;
          l_debrief_header.ATTRIBUTE11         := p_ATTRIBUTE11    ;
          l_debrief_header.ATTRIBUTE12        := p_ATTRIBUTE12    ;
          l_debrief_header.ATTRIBUTE13        := p_ATTRIBUTE13    ;
          l_debrief_header.ATTRIBUTE14        := p_ATTRIBUTE14    ;
          l_debrief_header.ATTRIBUTE15        := p_ATTRIBUTE15    ;
          l_debrief_header.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
           l_debrief_header.object_version_number :=p_object_version_number;
          l_debrief_header.TRAVEL_START_TIME      :=p_TRAVEL_START_TIME;
          l_debrief_header.TRAVEL_END_TIME        :=p_TRAVEL_END_TIME;
          l_debrief_header.TRAVEL_DISTANCE_IN_KM  :=p_TRAVEL_DISTANCE_IN_KM;

          if l_dml_mode is null then
            l_dml_mode := 'BOTH';
          end if;

    if l_dml_mode <> 'POST' then
      IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                        'Update_Row',
                                        'B', 'C')  THEN

              csf_debrief_headers_cuhk.update_debrief_header_Pre
                  ( px_debrief_header     => l_debrief_header,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  ) ;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
        FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;
    END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Update_Row',
                                      'B', 'V')  THEN
    csf_debrief_headers_vuhk.update_debrief_header_Pre
                ( px_debrief_header     => l_debrief_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    user_hooks_rec.DEBRIEF_HEADER_ID := l_debrief_header.DEBRIEF_HEADER_ID;
    csf_debrief_headers_iuhk.update_debrief_header_Pre
               ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    if l_dml_mode = 'BOTH' then

        Update CSF_DEBRIEF_HEADERS
        SET
                  DEBRIEF_NUMBER = decode( l_debrief_header.DEBRIEF_NUMBER, FND_API.G_MISS_CHAR, DEBRIEF_NUMBER, l_debrief_header.DEBRIEF_NUMBER),
                  DEBRIEF_DATE = decode( l_debrief_header.DEBRIEF_DATE, FND_API.G_MISS_DATE, DEBRIEF_DATE, l_debrief_header.DEBRIEF_DATE),
                  DEBRIEF_STATUS_ID = decode( l_debrief_header.DEBRIEF_STATUS_ID, FND_API.G_MISS_NUM, DEBRIEF_STATUS_ID, l_debrief_header.DEBRIEF_STATUS_ID),
                  TASK_ASSIGNMENT_ID = decode( l_debrief_header.TASK_ASSIGNMENT_ID, FND_API.G_MISS_NUM, TASK_ASSIGNMENT_ID, l_debrief_header.TASK_ASSIGNMENT_ID),
                  CREATED_BY = decode( l_debrief_header.CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, l_debrief_header.CREATED_BY),
                  CREATION_DATE = decode( l_debrief_header.CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, l_debrief_header.CREATION_DATE),
                  LAST_UPDATED_BY = decode( l_debrief_header.LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, l_debrief_header.LAST_UPDATED_BY),
                  LAST_UPDATE_DATE = decode( l_debrief_header.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, l_debrief_header.LAST_UPDATE_DATE),
                  LAST_UPDATE_LOGIN = decode( l_debrief_header.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, l_debrief_header.LAST_UPDATE_LOGIN),
                  ATTRIBUTE1 = decode( l_debrief_header.ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, l_debrief_header.ATTRIBUTE1),
                  ATTRIBUTE2 = decode( l_debrief_header.ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, l_debrief_header.ATTRIBUTE2),
                  ATTRIBUTE3 = decode( l_debrief_header.ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, l_debrief_header.ATTRIBUTE3),
                  ATTRIBUTE4 = decode( l_debrief_header.ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, l_debrief_header.ATTRIBUTE4),
                  ATTRIBUTE5 = decode( l_debrief_header.ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, l_debrief_header.ATTRIBUTE5),
                  ATTRIBUTE6 = decode( l_debrief_header.ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, l_debrief_header.ATTRIBUTE6),
                  ATTRIBUTE7 = decode( l_debrief_header.ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, l_debrief_header.ATTRIBUTE7),
                  ATTRIBUTE8 = decode( l_debrief_header.ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, l_debrief_header.ATTRIBUTE8),
                  ATTRIBUTE9 = decode( l_debrief_header.ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, l_debrief_header.ATTRIBUTE9),
                  ATTRIBUTE10 = decode( l_debrief_header.ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, l_debrief_header.ATTRIBUTE10),
                  ATTRIBUTE11 = decode( l_debrief_header.ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, l_debrief_header.ATTRIBUTE11),
                  ATTRIBUTE12 = decode( l_debrief_header.ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, l_debrief_header.ATTRIBUTE12),
                  ATTRIBUTE13 = decode( l_debrief_header.ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, l_debrief_header.ATTRIBUTE13),
                  ATTRIBUTE14 = decode( l_debrief_header.ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, l_debrief_header.ATTRIBUTE14),
                  ATTRIBUTE15 = decode( l_debrief_header.ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, l_debrief_header.ATTRIBUTE15),
                  ATTRIBUTE_CATEGORY = decode( l_debrief_header.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, l_debrief_header.ATTRIBUTE_CATEGORY),
                  OBJECT_VERSION_NUMBER =  decode( l_debrief_header.OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER,l_debrief_header.OBJECT_VERSION_NUMBER),
                  TRAVEL_START_TIME  = decode( l_debrief_header.TRAVEL_START_TIME, FND_API.G_MISS_DATE, TRAVEL_START_TIME, l_debrief_header.TRAVEL_START_TIME),
                  TRAVEL_END_TIME  = decode( l_debrief_header.TRAVEL_END_TIME, FND_API.G_MISS_DATE, TRAVEL_END_TIME, l_debrief_header.TRAVEL_END_TIME),
                  TRAVEL_DISTANCE_IN_KM = decode( l_debrief_header.TRAVEL_DISTANCE_IN_KM, FND_API.G_MISS_NUM, TRAVEL_DISTANCE_IN_KM, l_debrief_header.TRAVEL_DISTANCE_IN_KM)

        where DEBRIEF_HEADER_ID = l_debrief_header.DEBRIEF_HEADER_ID;

        If (SQL%NOTFOUND) then
            RAISE NO_DATA_FOUND;
        End If;
    end if;

    if l_dml_mode <> 'PRE' then
        IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                          'Update_Row',
                                          'A', 'C')  THEN

                csf_debrief_headers_cuhk.update_debrief_header_post
                    ( px_debrief_header     => l_debrief_header,
                      x_return_status          => l_return_status,
                      x_msg_count              => l_msg_count,
                      x_msg_data               => l_msg_data
                    ) ;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
          FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_CUST_USR_HK');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       END IF;
   END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Update_Row',
                                      'A', 'V')  THEN
    csf_debrief_headers_vuhk.update_debrief_header_post
                ( px_debrief_header     => l_debrief_header,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csf_debrief_headers_iuhk.update_debrief_header_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_DEBRIEF_HEADER_ID  NUMBER,
    p_DML_mode           VARCHAR2)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full varchar2(50) := 'CSF_DEBRIEF_HEADERS_PKG.DELETE_ROW';
   l_dml_mode	      varchar2(10) := p_DML_mode;
 BEGIN

    if l_dml_mode is null then
      l_dml_mode := 'BOTH';
    end if;

    if l_dml_mode <> 'POST' then
        IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                          'Delete_Row',
                                          'B', 'C')  THEN

                csf_debrief_headers_cuhk.delete_debrief_header_Pre
                    ( p_header_id     => p_DEBRIEF_HEADER_ID,
                      x_return_status          => l_return_status,
                      x_msg_count              => l_msg_count,
                      x_msg_data               => l_msg_data
                    ) ;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
          FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_CUST_USR_HK');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       END IF;
    END IF;

  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Delete_Row',
                                      'B', 'V')  THEN
    csf_debrief_headers_vuhk.delete_debrief_header_Pre
                ( p_header_id              => p_DEBRIEF_HEADER_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    user_hooks_rec.DEBRIEF_HEADER_ID := p_DEBRIEF_HEADER_ID;
    csf_debrief_headers_iuhk.delete_debrief_header_Pre
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   if l_dml_mode = 'BOTH' then
       DELETE FROM CSF_DEBRIEF_HEADERS
        WHERE DEBRIEF_HEADER_ID = p_DEBRIEF_HEADER_ID;
       If (SQL%NOTFOUND) then
           RAISE NO_DATA_FOUND;
       End If;
   end if;

   if l_dml_mode <> 'PRE' then
       IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                          'Delete_Row',
                                          'A', 'C')  THEN

                csf_debrief_headers_cuhk.delete_debrief_header_Post
                    ( p_header_id     => p_DEBRIEF_HEADER_ID,
                      x_return_status          => l_return_status,
                      x_msg_count              => l_msg_count,
                      x_msg_data               => l_msg_data
                    ) ;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
          FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_CUST_USR_HK');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       END IF;
    END IF;


  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CSF_DEBRIEF_HEADERS_PKG',
                                      'Delete_Row',
                                      'A', 'V')  THEN
    csf_debrief_headers_vuhk.delete_debrief_header_post
                ( p_header_id     => p_DEBRIEF_HEADER_ID,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_msg_count,
                  x_msg_data               => l_msg_data
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    csf_debrief_headers_iuhk.Delete_debrief_header_post
                ( x_return_status          => l_return_status
                ) ;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CSF_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
           p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null
          )

 IS
   CURSOR C IS
        SELECT *
         FROM CSF_DEBRIEF_HEADERS
        WHERE DEBRIEF_HEADER_ID =  p_DEBRIEF_HEADER_ID
        FOR UPDATE of DEBRIEF_HEADER_ID NOWAIT;
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
           (      Recinfo.DEBRIEF_HEADER_ID = p_DEBRIEF_HEADER_ID)
       AND (    ( Recinfo.DEBRIEF_NUMBER = p_DEBRIEF_NUMBER)
            OR (    ( Recinfo.DEBRIEF_NUMBER IS NULL )
                AND (  p_DEBRIEF_NUMBER IS NULL )))
       AND (    ( Recinfo.DEBRIEF_DATE = p_DEBRIEF_DATE)
            OR (    ( Recinfo.DEBRIEF_DATE IS NULL )
                AND (  p_DEBRIEF_DATE IS NULL )))
       AND (    ( Recinfo.DEBRIEF_STATUS_ID = p_DEBRIEF_STATUS_ID)
            OR (    ( Recinfo.DEBRIEF_STATUS_ID IS NULL )
                AND (  p_DEBRIEF_STATUS_ID IS NULL )))
       AND (    ( Recinfo.TASK_ASSIGNMENT_ID = p_TASK_ASSIGNMENT_ID)
            OR (    ( Recinfo.TASK_ASSIGNMENT_ID IS NULL )
                AND (  p_TASK_ASSIGNMENT_ID IS NULL )))
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
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.TRAVEL_START_TIME = p_TRAVEL_START_TIME)
            OR (    ( Recinfo.TRAVEL_START_TIME IS NULL )
                AND (  p_TRAVEL_START_TIME IS NULL )))
       AND (    ( Recinfo.TRAVEL_END_TIME = p_TRAVEL_END_TIME)
            OR (    ( Recinfo.TRAVEL_END_TIME IS NULL )
                AND (  p_TRAVEL_END_TIME IS NULL )))
       AND (    ( Recinfo.TRAVEL_DISTANCE_IN_KM = p_TRAVEL_DISTANCE_IN_KM)
            OR (    ( Recinfo.TRAVEL_DISTANCE_IN_KM IS NULL )
                AND (  p_TRAVEL_DISTANCE_IN_KM IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

FUNCTION GET_RESOURCE_NAME(
    p_resource_id   number,
    p_resource_type varchar2)
    RETURN varchar2 is

    cursor resource_name is
    select resource_name from jtf_rs_all_resources_vl
    where  resource_id = p_resource_id
    and    resource_type = p_resource_type;

    l_resource_name varchar2(200);

    begin
      open resource_name;
      fetch resource_name into l_resource_name;
      close resource_name;
      return l_resource_name;
    end;

END CSF_DEBRIEF_HEADERS_PKG;

/
