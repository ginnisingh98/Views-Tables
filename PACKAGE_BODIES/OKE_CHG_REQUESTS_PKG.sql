--------------------------------------------------------
--  DDL for Package Body OKE_CHG_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CHG_REQUESTS_PKG" as
/* $Header: OKEOCRXB.pls 120.0 2005/05/25 17:57:25 appldev noship $ */

PROCEDURE Start_WF_Process
( X_LAST_CHG_LOG_ID             IN      NUMBER
) IS

  CURSOR c IS
    SELECT wf_item_type
    ,      wf_item_key
    FROM   oke_chg_logs
    WHERE  chg_log_id = X_Last_Chg_Log_ID;
  crec c%rowtype;

BEGIN

  OPEN c;
  FETCH c INTO crec;
  CLOSE c;

  IF ( crec.wf_item_key IS NOT NULL ) THEN
    --
    -- Start the Workflow Process
    --
    WF_ENGINE.StartProcess( itemtype => crec.wf_item_type
                          , itemkey  => crec.wf_item_key );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  NULL;
END Start_WF_Process;


procedure INSERT_ROW
( X_ROWID                       in out NOCOPY  VARCHAR2
, X_CHG_REQUEST_ID              in out NOCOPY  NUMBER
, X_CREATION_DATE               in      DATE
, X_CREATED_BY                  in      NUMBER
, X_LAST_UPDATE_DATE            in      DATE
, X_LAST_UPDATED_BY             in      NUMBER
, X_LAST_UPDATE_LOGIN           in      NUMBER
, X_K_HEADER_ID                 in      NUMBER
, X_CHG_REQUEST_NUM             in out NOCOPY  VARCHAR2
, X_CHG_TYPE_CODE               in      VARCHAR2
, X_CHG_STATUS_CODE             in      VARCHAR2
, X_CHG_REASON_CODE             in      VARCHAR2
, X_IMPACT_FUNDING_FLAG         in      VARCHAR2
, X_EFFECTIVE_DATE              in      DATE
, X_REQUESTED_BY_PERSON_ID      in      NUMBER
, X_REQUESTED_DATE              in      DATE
, X_RECEIVE_DATE                in      DATE
, X_APPROVE_DATE                in out NOCOPY  DATE
, X_IMPLEMENT_DATE              in out NOCOPY  DATE
, X_PREV_VERSION                in      NUMBER
, X_NEW_VERSION                 in      NUMBER
, X_DESCRIPTION                 in      VARCHAR2
, X_CHG_TEXT                    in      VARCHAR2
, X_LAST_CHG_LOG_ID             in out NOCOPY  NUMBER
, X_ATTRIBUTE_CATEGORY          in      VARCHAR2
, X_ATTRIBUTE1                  in      VARCHAR2
, X_ATTRIBUTE2                  in      VARCHAR2
, X_ATTRIBUTE3                  in      VARCHAR2
, X_ATTRIBUTE4                  in      VARCHAR2
, X_ATTRIBUTE5                  in      VARCHAR2
, X_ATTRIBUTE6                  in      VARCHAR2
, X_ATTRIBUTE7                  in      VARCHAR2
, X_ATTRIBUTE8                  in      VARCHAR2
, X_ATTRIBUTE9                  in      VARCHAR2
, X_ATTRIBUTE10                 in      VARCHAR2
, X_ATTRIBUTE11                 in      VARCHAR2
, X_ATTRIBUTE12                 in      VARCHAR2
, X_ATTRIBUTE13                 in      VARCHAR2
, X_ATTRIBUTE14                 in      VARCHAR2
, X_ATTRIBUTE15                 in      VARCHAR2
) is

  cursor C1 is
    SELECT oke_chg_requests_s.nextval
    FROM   dual;

  cursor C2 is
    SELECT ROWID
    ,      LAST_CHG_LOG_ID
    ,      APPROVE_DATE
    ,      IMPLEMENT_DATE
    FROM oke_chg_requests
    WHERE chg_request_id = X_CHG_REQUEST_ID
    ;

  Auto_ChgReq_Number  BOOLEAN := FALSE;

begin

  OPEN c1;
  FETCH c1 INTO X_Chg_Request_ID;
  CLOSE c1;

  --
  -- Assign a dummy Number first
  --
  IF ( X_Chg_Request_Num IS NULL ) THEN
    Auto_ChgReq_Number := TRUE;
    X_Chg_Request_Num := 'TEMP:' || rpad(X_Chg_Request_ID , 25 , '*');
  END IF;

  SAVEPOINT OKE_CHG_REQUESTS_INSERT;

  insert into OKE_CHG_REQUESTS (
  CHG_REQUEST_ID
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, K_HEADER_ID
, CHG_REQUEST_NUM
, CHG_TYPE_CODE
, CHG_STATUS_CODE
, CHG_REASON_CODE
, IMPACT_FUNDING_FLAG
, EFFECTIVE_DATE
, REQUESTED_BY_PERSON_ID
, REQUESTED_DATE
, RECEIVE_DATE
, APPROVE_DATE
, IMPLEMENT_DATE
, PREV_VERSION
, NEW_VERSION
, DESCRIPTION
, CHG_TEXT
, ATTRIBUTE_CATEGORY
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
  ) values (
  X_CHG_REQUEST_ID
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_K_HEADER_ID
, X_CHG_REQUEST_NUM
, X_CHG_TYPE_CODE
, X_CHG_STATUS_CODE
, X_CHG_REASON_CODE
, X_IMPACT_FUNDING_FLAG
, X_EFFECTIVE_DATE
, X_REQUESTED_BY_PERSON_ID
, X_REQUESTED_DATE
, X_RECEIVE_DATE
, X_APPROVE_DATE
, X_IMPLEMENT_DATE
, X_PREV_VERSION
, X_NEW_VERSION
, X_DESCRIPTION
, X_CHG_TEXT
, X_ATTRIBUTE_CATEGORY
, X_ATTRIBUTE1
, X_ATTRIBUTE2
, X_ATTRIBUTE3
, X_ATTRIBUTE4
, X_ATTRIBUTE5
, X_ATTRIBUTE6
, X_ATTRIBUTE7
, X_ATTRIBUTE8
, X_ATTRIBUTE9
, X_ATTRIBUTE10
, X_ATTRIBUTE11
, X_ATTRIBUTE12
, X_ATTRIBUTE13
, X_ATTRIBUTE14
, X_ATTRIBUTE15
);

  open c2;
  fetch c2 into X_ROWID
              , X_LAST_CHG_LOG_ID
              , X_APPROVE_DATE
              , X_IMPLEMENT_DATE;
  if (c2%notfound) then
    close c2;
    raise no_data_found;
  end if;
  close c2;

  --
  -- Now assign the real number to reduce lock time
  --
  IF ( Auto_ChgReq_Number ) THEN
    X_Chg_Request_Num := OKE_NUMBER_SEQUENCES_PKG.Next_ChgReq_Number
                        ( X_CHG_TYPE_CODE , X_K_HEADER_ID );

    UPDATE oke_chg_requests
    SET    Chg_Request_Num = X_Chg_Request_Num
    WHERE  Chg_Request_ID  = X_Chg_Request_ID;

  END IF;

  Start_WF_Process( X_Last_Chg_Log_ID );

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO SAVEPOINT OKE_CHG_REQUESTS_INSERT;
  RAISE;

end INSERT_ROW;

procedure LOCK_ROW
( X_CHG_REQUEST_ID              in      NUMBER
, X_K_HEADER_ID                 in      NUMBER
, X_CHG_REQUEST_NUM             in      VARCHAR2
, X_CHG_TYPE_CODE               in      VARCHAR2
, X_CHG_STATUS_CODE             in      VARCHAR2
, X_CHG_REASON_CODE             in      VARCHAR2
, X_IMPACT_FUNDING_FLAG         in      VARCHAR2
, X_EFFECTIVE_DATE              in      DATE
, X_REQUESTED_BY_PERSON_ID      in      NUMBER
, X_REQUESTED_DATE              in      DATE
, X_RECEIVE_DATE                in      DATE
, X_APPROVE_DATE                in      DATE
, X_IMPLEMENT_DATE              in      DATE
, X_PREV_VERSION                in      NUMBER
, X_NEW_VERSION                 in      NUMBER
, X_DESCRIPTION                 in      VARCHAR2
, X_CHG_TEXT                    in      VARCHAR2
, X_ATTRIBUTE_CATEGORY          in      VARCHAR2
, X_ATTRIBUTE1                  in      VARCHAR2
, X_ATTRIBUTE2                  in      VARCHAR2
, X_ATTRIBUTE3                  in      VARCHAR2
, X_ATTRIBUTE4                  in      VARCHAR2
, X_ATTRIBUTE5                  in      VARCHAR2
, X_ATTRIBUTE6                  in      VARCHAR2
, X_ATTRIBUTE7                  in      VARCHAR2
, X_ATTRIBUTE8                  in      VARCHAR2
, X_ATTRIBUTE9                  in      VARCHAR2
, X_ATTRIBUTE10                 in      VARCHAR2
, X_ATTRIBUTE11                 in      VARCHAR2
, X_ATTRIBUTE12                 in      VARCHAR2
, X_ATTRIBUTE13                 in      VARCHAR2
, X_ATTRIBUTE14                 in      VARCHAR2
, X_ATTRIBUTE15                 in      VARCHAR2
) is
  cursor c is select
       CHG_REQUEST_ID
     , K_HEADER_ID
     , CHG_REQUEST_NUM
     , CHG_TYPE_CODE
     , CHG_STATUS_CODE
     , CHG_REASON_CODE
     , IMPACT_FUNDING_FLAG
     , EFFECTIVE_DATE
     , REQUESTED_BY_PERSON_ID
     , REQUESTED_DATE
     , RECEIVE_DATE
     , APPROVE_DATE
     , IMPLEMENT_DATE
     , PREV_VERSION
     , NEW_VERSION
     , DESCRIPTION
     , CHG_TEXT
     , ATTRIBUTE_CATEGORY
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
    from OKE_CHG_REQUESTS
    where CHG_REQUEST_ID = X_CHG_REQUEST_ID
    for update of CHG_REQUEST_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    (recinfo.CHG_REQUEST_ID = X_CHG_REQUEST_ID)
      AND ((recinfo.K_HEADER_ID = X_K_HEADER_ID)
           OR ((recinfo.K_HEADER_ID is null) AND (X_K_HEADER_ID is null)))
      AND ((recinfo.CHG_REQUEST_NUM = X_CHG_REQUEST_NUM)
           OR ((recinfo.CHG_REQUEST_NUM is null) AND (X_CHG_REQUEST_NUM is null)))
      AND ((recinfo.CHG_TYPE_CODE = X_CHG_TYPE_CODE)
           OR ((recinfo.CHG_TYPE_CODE is null) AND (X_CHG_TYPE_CODE is null)))
      AND ((recinfo.CHG_STATUS_CODE = X_CHG_STATUS_CODE)
           OR ((recinfo.CHG_STATUS_CODE is null) AND (X_CHG_STATUS_CODE is null)))
      AND ((recinfo.CHG_REASON_CODE = X_CHG_REASON_CODE)
           OR ((recinfo.CHG_REASON_CODE is null) AND (X_CHG_REASON_CODE is null)))
      AND ((recinfo.IMPACT_FUNDING_FLAG = X_IMPACT_FUNDING_FLAG)
           OR ((recinfo.IMPACT_FUNDING_FLAG is null) AND (X_IMPACT_FUNDING_FLAG is null)))
      AND ((recinfo.EFFECTIVE_DATE = X_EFFECTIVE_DATE)
           OR ((recinfo.EFFECTIVE_DATE is null) AND (X_EFFECTIVE_DATE is null)))
      AND ((recinfo.REQUESTED_BY_PERSON_ID = X_REQUESTED_BY_PERSON_ID)
           OR ((recinfo.REQUESTED_BY_PERSON_ID is null) AND (X_REQUESTED_BY_PERSON_ID is null)))
      AND ((recinfo.REQUESTED_DATE = X_REQUESTED_DATE)
           OR ((recinfo.REQUESTED_DATE is null) AND (X_REQUESTED_DATE is null)))
      AND ((recinfo.RECEIVE_DATE = X_RECEIVE_DATE)
           OR ((recinfo.RECEIVE_DATE is null) AND (X_RECEIVE_DATE is null)))
      AND ((recinfo.APPROVE_DATE = X_APPROVE_DATE)
           OR ((recinfo.APPROVE_DATE is null) AND (X_APPROVE_DATE is null)))
      AND ((recinfo.IMPLEMENT_DATE = X_IMPLEMENT_DATE)
           OR ((recinfo.IMPLEMENT_DATE is null) AND (X_IMPLEMENT_DATE is null)))
      AND ((recinfo.PREV_VERSION = X_PREV_VERSION)
           OR ((recinfo.PREV_VERSION is null) AND (X_PREV_VERSION is null)))
      AND ((recinfo.NEW_VERSION = X_NEW_VERSION)
           OR ((recinfo.NEW_VERSION is null) AND (X_NEW_VERSION is null)))
      AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND ((recinfo.CHG_TEXT = X_CHG_TEXT)
           OR ((recinfo.CHG_TEXT is null) AND (X_CHG_TEXT is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW
( X_CHG_REQUEST_ID              in      NUMBER
, X_LAST_UPDATE_DATE            in      DATE
, X_LAST_UPDATED_BY             in      NUMBER
, X_LAST_UPDATE_LOGIN           in      NUMBER
, X_K_HEADER_ID                 in      NUMBER
, X_CHG_REQUEST_NUM             in      VARCHAR2
, X_CHG_TYPE_CODE               in      VARCHAR2
, X_CHG_STATUS_CODE             in      VARCHAR2
, X_CHG_REASON_CODE             in      VARCHAR2
, X_IMPACT_FUNDING_FLAG         in      VARCHAR2
, X_EFFECTIVE_DATE              in      DATE
, X_REQUESTED_BY_PERSON_ID      in      NUMBER
, X_REQUESTED_DATE              in      DATE
, X_RECEIVE_DATE                in      DATE
, X_APPROVE_DATE                in out NOCOPY  DATE
, X_IMPLEMENT_DATE              in out NOCOPY  DATE
, X_PREV_VERSION                in      NUMBER
, X_NEW_VERSION                 in      NUMBER
, X_DESCRIPTION                 in      VARCHAR2
, X_CHG_TEXT                    in      VARCHAR2
, X_LAST_CHG_LOG_ID             in out NOCOPY  NUMBER
, X_ATTRIBUTE_CATEGORY          in      VARCHAR2
, X_ATTRIBUTE1                  in      VARCHAR2
, X_ATTRIBUTE2                  in      VARCHAR2
, X_ATTRIBUTE3                  in      VARCHAR2
, X_ATTRIBUTE4                  in      VARCHAR2
, X_ATTRIBUTE5                  in      VARCHAR2
, X_ATTRIBUTE6                  in      VARCHAR2
, X_ATTRIBUTE7                  in      VARCHAR2
, X_ATTRIBUTE8                  in      VARCHAR2
, X_ATTRIBUTE9                  in      VARCHAR2
, X_ATTRIBUTE10                 in      VARCHAR2
, X_ATTRIBUTE11                 in      VARCHAR2
, X_ATTRIBUTE12                 in      VARCHAR2
, X_ATTRIBUTE13                 in      VARCHAR2
, X_ATTRIBUTE14                 in      VARCHAR2
, X_ATTRIBUTE15                 in      VARCHAR2
) is

  cursor C is
    SELECT LAST_CHG_LOG_ID
    ,      APPROVE_DATE
    ,      IMPLEMENT_DATE
    FROM oke_chg_requests
    WHERE chg_request_id = X_CHG_REQUEST_ID
    ;

  cursor C2 is
    SELECT LAST_CHG_LOG_ID
    FROM oke_chg_requests
    WHERE chg_request_id = X_CHG_REQUEST_ID
    ;

  Prev_Chg_Log_ID   NUMBER;

begin

  open c2;
  fetch c2 into Prev_Chg_Log_ID;
  close c2;

  update OKE_CHG_REQUESTS set
  LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE
, LAST_UPDATED_BY 		= X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN   		= X_LAST_UPDATE_LOGIN
, K_HEADER_ID   		= X_K_HEADER_ID
, CHG_REQUEST_NUM   		= X_CHG_REQUEST_NUM
, CHG_TYPE_CODE   		= X_CHG_TYPE_CODE
, CHG_STATUS_CODE   		= X_CHG_STATUS_CODE
, CHG_REASON_CODE   		= X_CHG_REASON_CODE
, IMPACT_FUNDING_FLAG  		= X_IMPACT_FUNDING_FLAG
, EFFECTIVE_DATE   		= X_EFFECTIVE_DATE
, REQUESTED_BY_PERSON_ID	= X_REQUESTED_BY_PERSON_ID
, REQUESTED_DATE   		= X_REQUESTED_DATE
, RECEIVE_DATE   		= X_RECEIVE_DATE
, APPROVE_DATE   		= X_APPROVE_DATE
, IMPLEMENT_DATE   		= X_IMPLEMENT_DATE
, PREV_VERSION   		= X_PREV_VERSION
, NEW_VERSION   		= X_NEW_VERSION
, DESCRIPTION   		= X_DESCRIPTION
, CHG_TEXT   	        	= X_CHG_TEXT
, ATTRIBUTE_CATEGORY		= X_ATTRIBUTE_CATEGORY
, ATTRIBUTE1            	= X_ATTRIBUTE1
, ATTRIBUTE2			= X_ATTRIBUTE2
, ATTRIBUTE3    		= X_ATTRIBUTE3
, ATTRIBUTE4        		= X_ATTRIBUTE4
, ATTRIBUTE5            	= X_ATTRIBUTE5
, ATTRIBUTE6			= X_ATTRIBUTE6
, ATTRIBUTE7    		= X_ATTRIBUTE7
, ATTRIBUTE8        		= X_ATTRIBUTE8
, ATTRIBUTE9            	= X_ATTRIBUTE9
, ATTRIBUTE10           	= X_ATTRIBUTE10
, ATTRIBUTE11			= X_ATTRIBUTE11
, ATTRIBUTE12    		= X_ATTRIBUTE12
, ATTRIBUTE13        		= X_ATTRIBUTE13
, ATTRIBUTE14           	= X_ATTRIBUTE14
, ATTRIBUTE15           	= X_ATTRIBUTE15
where CHG_REQUEST_ID 	        = X_CHG_REQUEST_ID
;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  open c;
  fetch c into X_LAST_CHG_LOG_ID
             , X_APPROVE_DATE
             , X_IMPLEMENT_DATE;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  if ( Prev_Chg_Log_ID <> X_Last_Chg_Log_ID ) then
    Start_WF_Process( X_Last_Chg_Log_ID );
  end if;

end UPDATE_ROW;

FUNCTION Validate_Chg_Request_Num
( X_K_HEADER_ID		in	NUMBER,
  X_CHG_REQ_NUM		in	VARCHAR2,
  X_CHG_REQ_ID		in	NUMBER
)RETURN VARCHAR2
is
   Chg_Req_Num_Type varchar2(30);
   Rec_Count  NUMBER;
   Chg_Req_Num_OK varchar2(1);

   CURSOR c1
   ( C_K_Header_ID      NUMBER
   , C_Chg_Request_Num  VARCHAR2
   , C_Chg_Request_ID   NUMBER
   ) IS
     SELECT count(1)
     FROM   oke_chg_requests
     WHERE  K_Header_ID = C_K_Header_ID
     AND    Chg_Request_Num = C_Chg_Request_Num
     AND    (  C_Chg_Request_ID IS NULL
            OR Chg_Request_ID <> C_Chg_Request_ID );


begin

    Chg_Req_Num_OK := 'T';

    select Manual_ChgReq_Num_type
      into Chg_Req_Num_Type
      from oke_number_options N,
           oke_k_headers EH,
           okc_k_headers_b CH
     WHERE EH.K_Header_ID = X_K_HEADER_ID
       AND CH.ID          = EH.K_Header_ID
       AND N.K_Type_Code  = EH.K_Type_Code
       AND N.Buy_Or_Sell = CH.Buy_Or_Sell;

      --
      -- If Number Type is numeric, check if entry is numeric
      --
      IF ( Chg_Req_Num_Type = 'NUMERIC'
         AND OKE_NUMBER_SEQUENCES_PKG.Value_Is_Numeric
                 (X_CHG_REQ_NUM) = 'N' ) THEN
        FND_MESSAGE.SET_NAME('OKE','OKE_NUMSEQ_INVALID_NUMERIC');
        Chg_Req_Num_OK := 'F';
--        FND_MESSAGE.Error;
--        RAISE Form_Trigger_Failure;
      END IF;

      --
      -- Check if entered number is unique for given document
      --
      OPEN c1 ( X_K_HEADER_ID,
                X_CHG_REQ_NUM,
                X_CHG_REQ_ID);
      FETCH c1 INTO Rec_Count;
      CLOSE c1;

     IF Rec_Count > 0 THEN

        FND_MESSAGE.SET_NAME('OKE', 'OKE_CHGREQ_DUP_NUMBER');
        Chg_Req_Num_OK := 'F';
--        FND_MESSAGE.Error;
--        RAISE Form_Trigger_Failure;

     END IF;

     return Chg_Req_Num_OK;

end Validate_Chg_Request_Num;

FUNCTION Chg_Req_Num_Type
(X_K_HEADER_ID		in	NUMBER
)RETURN VARCHAR2 is
 Num_Type varchar2(30);
BEGIN
   select Manual_ChgReq_Num_Type
     into Num_Type
     from OKE_NUMBER_OPTIONS N,
          OKE_K_HEADERS EH,
          OKC_K_HEADERS_B CH
    WHERE EH.K_HEADER_ID = X_K_HEADER_ID
      AND CH.ID = EH.K_HEADER_ID
      AND N.K_TYPE_CODE = EH.K_TYPE_CODE
      AND N.BUY_OR_SELL = CH.BUY_OR_SELL;

return Num_Type;
END Chg_Req_Num_Type;

FUNCTION Chg_Req_Num_Mode
(X_K_HEADER_ID		in	NUMBER
)RETURN VARCHAR2 is
 Num_Mode varchar2(30);
BEGIN
   select ChgReq_Num_Mode
     into Num_Mode
     from OKE_NUMBER_OPTIONS N,
          OKE_K_HEADERS EH,
          OKC_K_HEADERS_B CH
    WHERE EH.K_HEADER_ID = X_K_HEADER_ID
      AND CH.ID = EH.K_HEADER_ID
      AND N.K_TYPE_CODE = EH.K_TYPE_CODE
      AND N.BUY_OR_SELL = CH.BUY_OR_SELL;

return Num_Mode;
END Chg_Req_Num_Mode;

end OKE_CHG_REQUESTS_PKG;

/
