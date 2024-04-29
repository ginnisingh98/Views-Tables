--------------------------------------------------------
--  DDL for Package Body PN_INDEX_EXCLUDE_TERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_EXCLUDE_TERM_PKG" AS
-- $Header: PNINXTRB.pls 120.3 2006/12/20 07:40:40 rdonthul ship $


-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-JUL-05  hrodda  o Bug 4284035 - Replaced pn_index_exclude_term with _ALL
--                      table.Also added a check for org id.
--20-SEP-06   pseeram o Modified insert_row procedure to include
--                      new column include_exclude_falg
-------------------------------------------------------------------------------
procedure INSERT_ROW
(
   X_INDEX_EXCLUDE_TERM_ID      IN OUT NOCOPY    NUMBER
   ,X_ORG_ID                    IN               NUMBER
   ,X_INDEX_LEASE_ID            IN               NUMBER
   ,X_PAYMENT_TERM_ID           IN               NUMBER
   ,X_LAST_UPDATE_DATE          IN               DATE
   ,X_LAST_UPDATED_BY           IN               NUMBER
   ,X_CREATION_DATE             IN               DATE
   ,X_CREATED_BY                IN               NUMBER
   ,X_LAST_UPDATE_LOGIN         IN               NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG      IN               VARCHAR2
)
IS
   l_return_status         VARCHAR2(30)    := NULL;
   l_rowId                 VARCHAR2(18)    := NULL;
   l_rowExists             VARCHAR2(10)    := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_index_leases_all WHERE index_lease_id = x_index_lease_id;
   l_org_ID NUMBER;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.insert_row (+)');

   /* If no INDEX_EXCLUDE_TERM_ID is provided, get one from sequence */

   BEGIN
      SELECT '1'
      INTO l_rowExists
      FROM DUAL
      WHERE EXISTS ( SELECT 1
                     FROM pn_index_exclude_term_all exclude
                     WHERE exclude.index_lease_id = x_index_lease_id
                     AND exclude.payment_term_id = x_payment_term_id
                     AND exclude.org_id = x_org_id);

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_rowExists := '0';
   END;


   IF l_rowExists = '0' THEN

      IF x_org_id IS NULL THEN
        FOR rec IN org_cur LOOP
           l_org_id := rec.org_id;
        END LOOP;
      ELSE
        l_org_id := x_org_id;
      END IF;

      IF (X_INDEX_EXCLUDE_TERM_ID IS NULL) THEN
         SELECT PN_INDEX_EXCLUDE_TERM_s.nextval
         INTO   X_INDEX_EXCLUDE_TERM_ID
         FROM   dual;
      END IF;

      INSERT INTO PN_INDEX_EXCLUDE_TERM_ALL
      (
          INDEX_EXCLUDE_TERM_ID
         ,ORG_ID
         ,INDEX_LEASE_ID
         ,PAYMENT_TERM_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,INCLUDE_EXCLUDE_FLAG
      )
      VALUES
      (
          X_INDEX_EXCLUDE_TERM_ID
         ,l_org_id
         ,X_INDEX_LEASE_ID
         ,X_PAYMENT_TERM_ID
         ,X_LAST_UPDATE_DATE
         ,X_LAST_UPDATED_BY
         ,X_CREATION_DATE
         ,X_CREATED_BY
         ,X_LAST_UPDATE_LOGIN
         ,X_INCLUDE_EXCLUDE_FLAG
      );

   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.insert_row (-)');

END INSERT_ROW;



-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_exclude_term with _ALL
--                     table.
-- 20-SEP-06 pseeram o Modified update_row procedure to include
--                      new column include_exclude_falg
-------------------------------------------------------------------------------
procedure UPDATE_ROW
(
    X_INDEX_EXCLUDE_TERM_ID         IN        NUMBER
   ,X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
   ,X_LAST_UPDATE_DATE              IN        DATE
   ,X_LAST_UPDATED_BY               IN        NUMBER
   ,X_LAST_UPDATE_LOGIN             IN        NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG          IN        VARCHAR2
)
IS
   l_return_status    VARCHAR2(30) := NULL;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.update_row (+)');

   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   UPDATE PN_INDEX_EXCLUDE_TERM_ALL
   SET
       INDEX_LEASE_ID                =X_INDEX_LEASE_ID
      ,PAYMENT_TERM_ID               =X_PAYMENT_TERM_ID
      ,LAST_UPDATE_DATE              =X_LAST_UPDATE_DATE
      ,LAST_UPDATED_BY               =X_LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN             =X_LAST_UPDATE_LOGIN
      ,INCLUDE_EXCLUDE_FLAG          =X_INCLUDE_EXCLUDE_FLAG
   WHERE INDEX_EXCLUDE_TERM_ID = X_INDEX_EXCLUDE_TERM_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND ;
   END IF;
  PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.update_row (-)');

END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_exclude_term with _ALL
--                     table.
--20-SEP-06   pseeram o Modified lock_row procedure to include
--                      new column include_exclude_falg
-------------------------------------------------------------------------------
procedure LOCK_ROW
(
    X_INDEX_EXCLUDE_TERM_ID         IN        NUMBER
   ,X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG          IN        VARCHAR2
)
IS

   CURSOR c1 IS
      SELECT * FROM  PN_INDEX_EXCLUDE_TERM_ALL
      WHERE INDEX_EXCLUDE_TERM_ID = X_INDEX_EXCLUDE_TERM_ID
      FOR UPDATE OF INDEX_EXCLUDE_TERM_ID NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.lock_row (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%notfound) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.INDEX_EXCLUDE_TERM_ID = X_INDEX_EXCLUDE_TERM_ID) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_EXCLUDE_TERM_ID',tlinfo.index_exclude_term_id);
   END IF;

   IF NOT (tlinfo.INDEX_LEASE_ID = X_INDEX_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_LEASE_ID',tlinfo.index_lease_id);
   END IF;

   IF NOT (tlinfo.PAYMENT_TERM_ID = X_PAYMENT_TERM_ID) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_ID',tlinfo.payment_term_id);
   END IF;

   IF NOT (tlinfo.INCLUDE_EXCLUDE_FLAG = X_INCLUDE_EXCLUDE_FLAG) THEN
      pn_var_rent_pkg.lock_row_exception('INCLUDE_EXCLUDE_FLAG',tlinfo.include_exclude_flag);
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.lock_row (-)');
END LOCK_ROW;



-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_exclude_term with _ALL
--                     table.
-------------------------------------------------------------------------------

procedure delete_row
(
    X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
)
IS

   l_rowExists     VARCHAR2(10)    := NULL;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.delete_row (+)');

   BEGIN
      SELECT '1'
      INTO l_rowExists
      FROM DUAL
      WHERE EXISTS ( SELECT 1
                     FROM pn_index_exclude_term_all  exclude
                     WHERE exclude.index_lease_id = x_index_lease_id
                     AND exclude.payment_term_id = x_payment_term_id);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_rowExists := '0';
   END;

   IF l_rowExists = '1' THEN

      DELETE FROM PN_INDEX_EXCLUDE_TERM_ALL
      WHERE INDEX_LEASE_ID = X_INDEX_LEASE_ID
      AND   PAYMENT_TERM_ID = X_PAYMENT_TERM_ID;

      IF (sql%notfound) THEN
         RAISE NO_DATA_FOUND;
      END IF;

   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.delete_row (-)');

END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ALL_EXCLUDE_TERMS
-- INVOKED FROM : DELETE_ALL_EXCLUDE_TERMS_THR procedure
-- PURPOSE      : deletes all the rows corresponding to a particular index-lease-id
-- HISTORY      :
-- 03-OCT-06  prabhakar o Created
-------------------------------------------------------------------------------

procedure DELETE_ALL_EXCLUDE_TERMS( X_INDEX_LEASE_ID  IN  NUMBER )
IS

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.DELETE_ALL_EXCLUDE_TERMS (+)');

      DELETE FROM PN_INDEX_EXCLUDE_TERM_ALL
      WHERE INDEX_LEASE_ID = X_INDEX_LEASE_ID;

   PNP_DEBUG_PKG.debug (' PN_INDEX_EXCLUDE_TERM_PKG.DELETE_ALL_EXCLUDE_TERMS (-)');

END DELETE_ALL_EXCLUDE_TERMS;

END PN_INDEX_EXCLUDE_TERM_PKG;

/
