--------------------------------------------------------
--  DDL for Package Body ICX_CAT_STORE_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_STORE_ASSIGNMENT_PKG" AS
/* $Header: ICXSTAGB.pls 120.3 2006/03/20 20:49:35 msheikh noship $*/

FUNCTION GET_ASSIGNED_STORE_ID(p_contentType IN VARCHAR2,
                               p_contentId IN NUMBER)
RETURN NUMBER IS
  xErrLoc         INTEGER := 0;
  xCount          INTEGER := 0;
  xStoreId        ICX_CAT_SHOP_STORES_B.STORE_ID%TYPE;

  CURSOR store_assignments(p_contentType IN VARCHAR2,
                           p_contentId IN NUMBER) IS
    SELECT
      DISTINCT stores.store_id
    FROM
      icx_cat_store_contents contents,
      icx_Cat_shop_stores_b stores
    WHERE
      contents.content_type = p_contentType AND
      contents.content_id = p_contentId  AND
      contents.store_id = stores.store_id;
BEGIN

  xErrLoc := 100;

  FOR stores IN store_assignments(p_contentType, p_contentId) LOOP
    xErrLoc := xErrLoc + 100;
    xCount := xCount + 1;
    xStoreId := stores.store_id;
  END LOOP;

  IF (xCount = 0) THEN
    RETURN  0;
  ELSIF (xCount = 1) THEN
    RETURN  xStoreId;
  ELSE
    RETURN -1;
  END IF;


END GET_ASSIGNED_STORE_ID;


FUNCTION GET_STORE_ASSIGNMENT(p_contentType IN VARCHAR2,
                              p_contentId IN NUMBER)
RETURN VARCHAR2 IS
  xErrLoc         INTEGER := 0;
  xCount          INTEGER := 0;
  xStoreName      ICX_CAT_SHOP_STORES_TL.NAME%TYPE;
  xMultipleMsg    FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

  CURSOR store_assignments(p_contentType IN VARCHAR2,
                           p_contentId IN NUMBER) IS
    SELECT
      DISTINCT name
    FROM
      icx_cat_store_contents contents,
      icx_Cat_shop_stores_vl stores
    WHERE
      contents.content_type = p_contentType AND
      contents.content_id = p_contentId  AND
      contents.store_id = stores.store_id;
BEGIN

  xErrLoc := 100;

  FOR stores IN store_assignments(p_contentType, p_contentId) LOOP
    xErrLoc := xErrLoc + 100;
    xCount := xCount + 1;
    xStoreName := stores.name;
  END LOOP;

  IF (xCount = 0) THEN
    RETURN  NULL;
  ELSIF (xCount = 1) THEN
    RETURN  xStoreName;
  ELSE
    SELECT message_text
    INTO   xMultipleMsg
    FROM   fnd_new_messages
    WHERE  message_name = 'ICX_POR_MULTIPLE'
       AND language_code = USERENV('LANG');

    RETURN xMultipleMsg;
  END IF;


END GET_STORE_ASSIGNMENT;

END ICX_CAT_STORE_ASSIGNMENT_PKG;

/
