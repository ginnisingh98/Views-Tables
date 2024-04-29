--------------------------------------------------------
--  DDL for Package Body IEC_DEFAULT_SUBSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_DEFAULT_SUBSET_PVT" AS
/* $Header: IECADSBB.pls 115.8 2004/05/18 19:38:06 minwang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_DEFAULT_SUBSET_PVT';

G_DEFAULT_SUBSET_NAME CONSTANT VARCHAR2(30) := 'IEC_DEFAULT_SUBSET_NAME';


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CREATE_DEFAULT_SUBSETS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : if a default subset has not previously been
--                created on the list the create one.

--  Parameters  :
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Status Plugin. */
PROCEDURE CREATE_DEFAULT_SUBSETS( P_LIST_ID IN NUMBER
                                , X_RETURN_STATUS OUT NOCOPY VARCHAR2)
IS
  l_user_id NUMBER;
  l_login_id NUMBER;
  l_log_status VARCHAR2(1);
  l_method_name CONSTANT VARCHAR2(30) := 'CREATE_DEFAULT_SUBSETS';
  l_default_subset_name VARCHAR2(255);
  l_subset_name VARCHAR2(255);
  l_index NUMBER;

BEGIN
  l_user_id := NVL(FND_GLOBAL.USER_ID, -1);
  l_login_id := NVL(FND_GLOBAL.CONC_LOGIN_ID, -1);

  SAVEPOINT CREATE_DEFAULT_SUBSET_START;
  X_RETURN_STATUS := 'S';

  ----------------------------------------------------------------
  -- We use the lookup to get the default subset name.
  ----------------------------------------------------------------
  BEGIN
    SELECT MEANING
    INTO   l_default_subset_name
    FROM   IEC_LOOKUPS
    WHERE  LOOKUP_TYPE = G_DEFAULT_SUBSET_NAME
    AND    LOOKUP_CODE = G_DEFAULT_SUBSET_NAME;

  EXCEPTION
    ----------------------------------------------------------------
    -- We probably should log the fact that we weren't able to get
    -- the default subset names for the lookups table.  Currently
    -- we just set the name to a default.  FUTURE.
    ----------------------------------------------------------------
    WHEN NO_DATA_FOUND THEN
      l_default_subset_name := 'DEFAULT SUBSET';

    ----------------------------------------------------------------
    -- We need to create a log message indicating that an internal
    -- unexpected PLSQL error occurred, give the sub_method, method
    -- package, SQLCODE, and SQLERRM  FUTURE.  For now we are just
    -- re-raising the original exception.
    ----------------------------------------------------------------
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  BEGIN

    SELECT SUBSET_NAME
    INTO   L_SUBSET_NAME
    FROM   IEC_G_LIST_SUBSETS
    WHERE  LIST_HEADER_ID = P_LIST_ID
    AND    DEFAULT_SUBSET_FLAG = 'Y';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN

          INSERT INTO IEC_G_LIST_SUBSETS
          (           LIST_SUBSET_ID
          ,           LIST_HEADER_ID
          ,           SUBSET_NAME
          ,           QUANTUM
          ,           PRIORITY
          ,           STATUS_CODE
          ,           DEFAULT_SUBSET_FLAG
          ,           QUOTA
          ,           QUOTA_RESET
          ,           RELEASE_STRATEGY
          ,           CREATED_BY
          ,           CREATION_DATE
          ,           LAST_UPDATED_BY
          ,           LAST_UPDATE_DATE
          ,           OBJECT_VERSION_NUMBER
          )
          VALUES
          (           IEC_G_LIST_SUBSETS_S.NEXTVAL
          ,           P_LIST_ID
          ,           l_default_subset_name
          ,           10
          ,           1
          ,           'ACTIVE'
          ,           'Y'
          ,           0
          ,           0
          ,           'QUA'
          ,           l_user_id
          ,           SYSDATE
          ,           l_login_id
          ,           SYSDATE
          ,           1
          );

        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END; -- END INSERT BLOCK

      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END; -- END SELECT BLOCK

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO CREATE_DEFAULT_SUBSET_START;
    X_RETURN_STATUS := 'U';
END CREATE_DEFAULT_SUBSETS;



-- PL/SQL Block
END IEC_DEFAULT_SUBSET_PVT;

/
