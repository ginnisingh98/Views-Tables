--------------------------------------------------------
--  DDL for Package CN_PAY_APPROVAL_FLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_APPROVAL_FLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: cntpflws.pls 120.0 2005/06/06 17:51:12 appldev noship $*/

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

TYPE PAY_APPROVAL_FLOW_REC_TYPE IS RECORD
  (
    PAY_APPROVAL_FLOW_ID	NUMBER	,
    PAYRUN_ID	NUMBER	,
    PAYMENT_WORKSHEET_ID	NUMBER	,
    SUBMIT_BY_RESOURCE_ID	NUMBER	,
    SUBMIT_BY_USER_ID	NUMBER	,
    SUBMIT_BY_EMAIL	VARCHAR2(2000)	,
    SUBMIT_TO_RESOURCE_ID	NUMBER	,
    SUBMIT_TO_USER_ID	NUMBER	,
    SUBMIT_TO_EMAIL	VARCHAR2(2000)	,
    APPROVAL_STATUS	VARCHAR2(30)	,
    UPDATED_BY_RESOURCE_ID	NUMBER	,
    ORG_ID	NUMBER	,
    SECURITY_GROUP_ID	NUMBER	,
    ATTRIBUTE_CATEGORY	VARCHAR2(30)	,
    ATTRIBUTE1	VARCHAR2(150)	,
    ATTRIBUTE2	VARCHAR2(150)	,
    ATTRIBUTE3	VARCHAR2(150)	,
    ATTRIBUTE4	VARCHAR2(150)	,
    ATTRIBUTE5	VARCHAR2(150)	,
    ATTRIBUTE6	VARCHAR2(150)	,
    ATTRIBUTE7	VARCHAR2(150)	,
    ATTRIBUTE8	VARCHAR2(150)	,
    ATTRIBUTE9	VARCHAR2(150)	,
    ATTRIBUTE10	VARCHAR2(150)	,
    ATTRIBUTE11	VARCHAR2(150)	,
    ATTRIBUTE12	VARCHAR2(150)	,
    ATTRIBUTE13	VARCHAR2(150)	,
    ATTRIBUTE14	VARCHAR2(150)	,
    ATTRIBUTE15	VARCHAR2(150)	,
    CREATION_DATE	DATE	,
    CREATED_BY	NUMBER	,
    LAST_UPDATE_DATE	DATE	,
    LAST_UPDATED_BY	NUMBER	,
    LAST_UPDATE_LOGIN	NUMBER	,
    OBJECT_VERSION_NUMBER	NUMBER
  );

G_NULL_PAY_APPROVAL_FLOW_REC PAY_APPROVAL_FLOW_REC_TYPE;

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	Insert_row
--   Purpose
--      Main insert procedure
--   Note
--      1. Primary key should be populated from sequence before call
--         this procedure. No refernece to sequence in this procedure.
--      2. All paramaters are IN parameter.
-- * -------------------------------------------------------------------------*
PROCEDURE insert_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	update_row
--   Purpose
--      Main update procedure
--   Note
--      1. No object version checking, overwrite may happen
--      2. Calling lock_update for object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE update_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	lock_update_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. Object version checking is performed before checking
--      2. Calling update_row if you don not want object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE lock_update_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row
    (
      p_pay_approval_flow_id	NUMBER
    );

END CN_PAY_APPROVAL_FLOW_PKG;

 

/
