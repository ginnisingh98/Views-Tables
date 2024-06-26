--------------------------------------------------------
--  DDL for Package CN_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REASONS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntresns.pls 115.0 2002/04/22 20:53:08 pkm ship       $*/

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

TYPE REASONS_ALL_REC_TYPE IS RECORD(
    REASON_ID			NUMBER		:= FND_API.G_MISS_NUM,
    UPDATED_TABLE		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    UPD_TABLE_ID		NUMBER		:= FND_API.G_MISS_NUM,
    REASON			VARCHAR2(8000)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE_CATEGORY		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE1			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE2			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE3			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE4			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE5			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE6			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE7			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE8			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE9			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE10			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE11			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE12			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE13			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE14			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE15			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    CREATED_BY			NUMBER		:= FND_API.G_MISS_NUM,
    CREATION_DATE		DATE		:= FND_API.G_MISS_DATE,
    LAST_UPDATED_BY		NUMBER		:= FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE		DATE		:= FND_API.G_MISS_DATE,
    LAST_UPDATE_LOGIN		NUMBER		:= FND_API.G_MISS_NUM,
    ORG_ID			NUMBER		:= FND_API.G_MISS_NUM,
    SECURITY_GROUP_ID		NUMBER		:= FND_API.G_MISS_NUM,
    OBJECT_VERSION_NUMBER	NUMBER		:= FND_API.G_MISS_NUM,
    LOOKUP_TYPE			VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    REASON_CODE			VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    UPDATE_FLAG			VARCHAR2(30)	:= FND_API.G_MISS_CHAR);

G_MISS_REASONS_ALL_REC REASONS_ALL_REC_TYPE;

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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE);

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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE);

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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE);

-- * -------------------------------------------------------------------------*
--   Procedure Name
--	delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row(
      p_reason_id	NUMBER);

END CN_REASONS_PKG;

 

/
