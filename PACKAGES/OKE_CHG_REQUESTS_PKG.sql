--------------------------------------------------------
--  DDL for Package OKE_CHG_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CHG_REQUESTS_PKG" AUTHID CURRENT_USER as
/* $Header: OKEOCRXS.pls 120.0 2005/05/25 17:54:15 appldev noship $ */

PROCEDURE Start_WF_Process
( X_LAST_CHG_LOG_ID             IN      NUMBER
);

procedure INSERT_ROW
( X_ROWID                       in out NOCOPY VARCHAR2
, X_CHG_REQUEST_ID              in out NOCOPY NUMBER
, X_CREATION_DATE               in      DATE
, X_CREATED_BY                  in      NUMBER
, X_LAST_UPDATE_DATE            in      DATE
, X_LAST_UPDATED_BY             in      NUMBER
, X_LAST_UPDATE_LOGIN           in      NUMBER
, X_K_HEADER_ID                 in      NUMBER
, X_CHG_REQUEST_NUM             in out NOCOPY VARCHAR2
, X_CHG_TYPE_CODE               in      VARCHAR2
, X_CHG_STATUS_CODE             in      VARCHAR2
, X_CHG_REASON_CODE             in      VARCHAR2
, X_IMPACT_FUNDING_FLAG         in      VARCHAR2
, X_EFFECTIVE_DATE              in      DATE
, X_REQUESTED_BY_PERSON_ID      in      NUMBER
, X_REQUESTED_DATE              in      DATE
, X_RECEIVE_DATE                in      DATE
, X_APPROVE_DATE                in out NOCOPY DATE
, X_IMPLEMENT_DATE              in out NOCOPY DATE
, X_PREV_VERSION                in      NUMBER
, X_NEW_VERSION                 in      NUMBER
, X_DESCRIPTION                 in      VARCHAR2
, X_CHG_TEXT                    in      VARCHAR2
, X_LAST_CHG_LOG_ID             in out NOCOPY NUMBER
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
);

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
);

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
, X_APPROVE_DATE                in out NOCOPY DATE
, X_IMPLEMENT_DATE              in out NOCOPY DATE
, X_PREV_VERSION                in      NUMBER
, X_NEW_VERSION                 in      NUMBER
, X_DESCRIPTION                 in      VARCHAR2
, X_CHG_TEXT                    in      VARCHAR2
, X_LAST_CHG_LOG_ID             in out NOCOPY NUMBER
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
);

FUNCTION Validate_Chg_Request_Num
( X_K_HEADER_ID		in	NUMBER,
  X_CHG_REQ_NUM		in	VARCHAR2,
  X_CHG_REQ_ID		in	NUMBER
)RETURN VARCHAR2;

FUNCTION Chg_Req_Num_Type
(X_K_HEADER_ID		in	NUMBER
) RETURN VARCHAR2;

FUNCTION Chg_Req_Num_Mode
(X_K_HEADER_ID		in	NUMBER
) RETURN VARCHAR2;

end OKE_CHG_REQUESTS_PKG;

 

/
