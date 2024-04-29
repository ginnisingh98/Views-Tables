--------------------------------------------------------
--  DDL for Package Body FTP_BR_IRCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_IRCS_PVT" AS
/* $Header: ftpircsb.pls 120.1 2006/01/26 08:40:21 appldev noship $ */


-- Translate Row for FTP_IRCS_TL

G_PKG_NAME constant varchar2(30) := 'FTP_BR_IRCS_PVT';

PROCEDURE TranslateRow(
x_interest_rate_code	IN NUMBER,
x_description		IN VARCHAR2,
x_last_update_date	IN VARCHAR2,
x_owner			IN VARCHAR2,
x_custom_mode		IN VARCHAR2) IS

owner_id	number;
ludate		date;
row_id		varchar2(64);
f_luby		number;  -- entity owner in file
f_ludate	date;    -- entity update date in file
db_luby		number;  -- entity owner in db
db_ludate	date;    -- entity update date in db

BEGIN
	f_luby := fnd_load_util.owner_id(x_owner);
	f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
	BEGIN
	  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_luby, db_ludate
	  FROM FTP_IRCS_TL
	  WHERE INTEREST_RATE_CODE = x_interest_rate_code
	  AND LANGUAGE = userenv('LANG');
	  IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate, x_custom_mode)) THEN
	      UPDATE FTP_IRCS_TL SET
	      DESCRIPTION = nvl(x_description, DESCRIPTION),
	      LAST_UPDATE_DATE = f_ludate,
	      LAST_UPDATED_BY = f_luby,
	      LAST_UPDATE_LOGIN = 0,
	      SOURCE_LANG = userenv('LANG')
	      WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	      AND INTEREST_RATE_CODE = x_interest_rate_code;
	  END IF;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		null;
	  END;
END TranslateRow;

-- bomathew 20060126 - Bug 4902755 - Copying ADD_LANGUAGE from ftppaypb.pls

procedure ADD_LANGUAGE
is
begin
  delete from FTP_IRCS_TL T
  where not exists
    (select NULL
    from FTP_IRCS_B B
    where B.INTEREST_RATE_CODE = T.INTEREST_RATE_CODE
    );

  update FTP_IRCS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FTP_IRCS_TL B
    where B.INTEREST_RATE_CODE = T.INTEREST_RATE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INTEREST_RATE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.INTEREST_RATE_CODE,
      SUBT.LANGUAGE
    from FTP_IRCS_TL SUBB, FTP_IRCS_TL SUBT
    where SUBB.INTEREST_RATE_CODE = SUBT.INTEREST_RATE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FTP_IRCS_TL (
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    INTEREST_RATE_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT_VERSION_NUMBER,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.INTEREST_RATE_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FTP_IRCS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FTP_IRCS_TL T
    where T.INTEREST_RATE_CODE = B.INTEREST_RATE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


END FTP_BR_IRCS_PVT;

/
