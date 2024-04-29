--------------------------------------------------------
--  DDL for Package Body AP_ISPEED_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ISPEED_UTIL_PKG" AS
/* $Header: apispedb.pls 120.4 2004/10/28 23:21:47 pjena noship $ */
--
-- Declare Variables Global to this Package.
--
  PROCEDURE Installation_Status(
            P_Installation_Exists    OUT NOCOPY VARCHAR2)
  IS
    po_status 		VARCHAR2(30);
    inv_status		VARCHAR2(30);
    industry		VARCHAR2(30);

  BEGIN

    if (FND_INSTALLATION.GET(201,201, po_status, industry) and
	FND_INSTALLATION.GET(401,401, inv_status, industry)) then
      if (po_status <> 'I' and inv_status <> 'I') then
        P_Installation_Exists := 'N';
      else
        P_Installation_Exists := 'Y';
      end if;
    end if;

  END  Installation_Status;

  PROCEDURE Add_Language( P_Term_Id  IN NUMBER)

  IS
  BEGIN

    insert into AP_TERMS_TL (
    TERM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    ENABLED_FLAG,
    DUE_CUTOFF_DAY,
    DESCRIPTION,
    TYPE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    RANK,
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
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TERM_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.ENABLED_FLAG,
    B.DUE_CUTOFF_DAY,
    B.DESCRIPTION,
    B.TYPE,
    B.START_DATE_ACTIVE,
    B.END_DATE_ACTIVE,
    B.RANK,
    B.ATTRIBUTE_CATEGORY,
    B.ATTRIBUTE1,
    B.ATTRIBUTE2,
    B.ATTRIBUTE3,
    B.ATTRIBUTE4,
    B.ATTRIBUTE5,
    B.ATTRIBUTE6,
    B.ATTRIBUTE7,
    B.ATTRIBUTE8,
    B.ATTRIBUTE9,
    B.ATTRIBUTE10,
    B.ATTRIBUTE11,
    B.ATTRIBUTE12,
    B.ATTRIBUTE13,
    B.ATTRIBUTE14,
    B.ATTRIBUTE15,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AP_TERMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.TERM_ID = P_Term_Id
  and not exists
    (select NULL
    from AP_TERMS_TL T
    where T.TERM_ID = B.TERM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language;


--
END AP_ISPEED_UTIL_PKG;

/
