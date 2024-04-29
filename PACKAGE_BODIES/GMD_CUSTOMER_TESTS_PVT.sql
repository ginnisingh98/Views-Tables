--------------------------------------------------------
--  DDL for Package Body GMD_CUSTOMER_TESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_CUSTOMER_TESTS_PVT" as
/* $Header: GMDVTCUB.pls 115.5 2002/12/03 17:10:05 cnagarba noship $*/

procedure INSERT_ROW (
  X_ROWID in out nocopy ROWID,
  X_TEST_ID in NUMBER,
  X_CUST_ID in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_CUST_TEST_DISPLAY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_CUSTOMER_TESTS_B
    where TEST_ID = X_TEST_ID
    and CUST_ID = X_CUST_ID
    ;
begin

  insert into GMD_CUSTOMER_TESTS_B (
    TEST_ID,
    CUST_ID,
    REPORT_PRECISION,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TEST_ID,
    X_CUST_ID,
    X_REPORT_PRECISION,
    X_TEXT_CODE,
    NVL(X_CREATION_DATE,SYSDATE),
    NVL(X_CREATED_BY,FND_GLOBAL.USER_ID),
    NVL(X_LAST_UPDATE_DATE,SYSDATE),
    NVL(X_LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
    NVL(X_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID)
  );

  insert into GMD_CUSTOMER_TESTS_TL (
    TEST_ID,
    CUST_ID,
    CUST_TEST_DISPLAY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEST_ID,
    X_CUST_ID,
    X_CUST_TEST_DISPLAY,
    NVL(X_CREATION_DATE,SYSDATE),
    NVL(X_CREATED_BY,FND_GLOBAL.USER_ID),
    NVL(X_LAST_UPDATE_DATE,SYSDATE),
    NVL(X_LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
    NVL(X_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_CUSTOMER_TESTS_TL T
    where T.TEST_ID = X_TEST_ID
    and T.CUST_ID = X_CUST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


FUNCTION INSERT_ROW(p_customer_tests_rec IN GMD_CUSTOMER_TESTS%ROWTYPE) RETURN BOOLEAN IS
l_rowid ROWID;
BEGIN
   GMD_CUSTOMER_TESTS_PVT.INSERT_ROW(
    X_ROWID => l_rowid,
    X_TEST_ID => p_customer_tests_rec.TEST_ID,
    X_CUST_ID => p_customer_tests_rec.CUST_ID,
    X_REPORT_PRECISION => p_customer_tests_rec.REPORT_PRECISION,
    X_TEXT_CODE => p_customer_tests_rec.TEXT_CODE,
    X_CUST_TEST_DISPLAY => p_customer_tests_rec.CUST_TEST_DISPLAY,
    X_CREATION_DATE => p_customer_tests_rec.CREATION_DATE,
    X_CREATED_BY => p_customer_tests_rec.CREATED_BY,
    X_LAST_UPDATE_DATE => p_customer_tests_rec.LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => p_customer_tests_rec.LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => p_customer_tests_rec.LAST_UPDATE_LOGIN);

    RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
    FND_MESSAGE.Set_Token('PACKAGE','GMD_CUSTOMER_TESTS_PVT.INSERT_ROW');
    FND_MESSAGE.Set_Token('ERROR', SUBSTR(SQLERRM,1,100));
    FND_MESSAGE.Set_Token('POSITION','010' );
    FND_MSG_PUB.ADD;
    RETURN FALSE;
END INSERT_ROW;

procedure LOCK_ROW (
  X_TEST_ID in NUMBER,
  X_CUST_ID in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_CUST_TEST_DISPLAY in VARCHAR2
) is
  cursor c is select
      REPORT_PRECISION,
      TEXT_CODE
    from GMD_CUSTOMER_TESTS_B
    where TEST_ID = X_TEST_ID
    and CUST_ID = X_CUST_ID
    for update of TEST_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CUST_TEST_DISPLAY,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_CUSTOMER_TESTS_TL
    where TEST_ID = X_TEST_ID
    and CUST_ID = X_CUST_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEST_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.REPORT_PRECISION = X_REPORT_PRECISION)
           OR ((recinfo.REPORT_PRECISION is null) AND (X_REPORT_PRECISION is null)))
     AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CUST_TEST_DISPLAY = X_CUST_TEST_DISPLAY)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TEST_ID in NUMBER,
  X_CUST_ID in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_CUST_TEST_DISPLAY in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_CUSTOMER_TESTS_B set
    REPORT_PRECISION = X_REPORT_PRECISION,
    TEXT_CODE = X_TEXT_CODE,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,SYSDATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID)
  where TEST_ID = X_TEST_ID
  and CUST_ID = X_CUST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_CUSTOMER_TESTS_TL set
    CUST_TEST_DISPLAY = X_CUST_TEST_DISPLAY,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,SYSDATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID),
    SOURCE_LANG = userenv('LANG')
  where TEST_ID = X_TEST_ID
  and CUST_ID = X_CUST_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

FUNCTION DELETE_ROW (
  P_TEST_ID 	  IN  NUMBER,
  P_CUST_ID 	  IN  NUMBER) RETURN BOOLEAN IS
begin
  IF P_TEST_ID IS NOT NULL AND P_CUST_ID IS NOT NULL THEN
     delete from GMD_CUSTOMER_TESTS_TL
     where TEST_ID = P_TEST_ID
     and CUST_ID = P_CUST_ID;

     if (sql%notfound) then
       raise no_data_found;
     end if;

     delete from GMD_CUSTOMER_TESTS_B
     where TEST_ID = P_TEST_ID
     and CUST_ID = P_CUST_ID;

     if (sql%notfound) then
       raise no_data_found;
     end if;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_CUSTOMER_TESTS');
    RETURN FALSE;
  END IF;

RETURN TRUE;

EXCEPTION
WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_CUSTOMER_TESTS');
     RETURN FALSE;
WHEN OTHERS THEN
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_CUSTOMER_TESTS_PVT.DELETE_ROW','ERROR',SUBSTR(SQLERRM,1,100),'POSITION','010');
    RETURN FALSE;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_CUSTOMER_TESTS_TL T
  where not exists
    (select NULL
    from GMD_CUSTOMER_TESTS_B B
    where B.TEST_ID = T.TEST_ID
    and B.CUST_ID = T.CUST_ID
    );

  update GMD_CUSTOMER_TESTS_TL T set (
      CUST_TEST_DISPLAY
    ) = (select
      B.CUST_TEST_DISPLAY
    from GMD_CUSTOMER_TESTS_TL B
    where B.TEST_ID = T.TEST_ID
    and B.CUST_ID = T.CUST_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEST_ID,
      T.CUST_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEST_ID,
      SUBT.CUST_ID,
      SUBT.LANGUAGE
    from GMD_CUSTOMER_TESTS_TL SUBB, GMD_CUSTOMER_TESTS_TL SUBT
    where SUBB.TEST_ID = SUBT.TEST_ID
    and SUBB.CUST_ID = SUBT.CUST_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CUST_TEST_DISPLAY <> SUBT.CUST_TEST_DISPLAY
  ));

  insert into GMD_CUSTOMER_TESTS_TL (
    TEST_ID,
    CUST_ID,
    CUST_TEST_DISPLAY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEST_ID,
    B.CUST_ID,
    B.CUST_TEST_DISPLAY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_CUSTOMER_TESTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_CUSTOMER_TESTS_TL T
    where T.TEST_ID = B.TEST_ID
    and T.CUST_ID = B.CUST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

FUNCTION lock_row (
  p_test_id   IN  NUMBER,
  p_cust_id   IN  NUMBER)
RETURN BOOLEAN
IS
  dummy       NUMBER;
BEGIN

  IF P_TEST_ID IS NOT NULL AND P_CUST_ID IS NOT NULL THEN
    SELECT test_id
    INTO   dummy
    FROM   gmd_customer_tests_b
    WHERE  test_id = p_test_id
    AND    cust_id = p_cust_id
    FOR UPDATE OF test_id NOWAIT  ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_CUSTOMER_TESTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_CUSTOMER_TESTS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_CUSTOMER_TESTS_PVT.LOCK_ROW','ERROR',SUBSTR(SQLERRM,1,100),'POSITION','010');
     RETURN FALSE;
END lock_row;

end GMD_CUSTOMER_TESTS_PVT;

/
