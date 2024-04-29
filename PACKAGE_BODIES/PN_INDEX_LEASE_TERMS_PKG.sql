--------------------------------------------------------
--  DDL for Package Body PN_INDEX_LEASE_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_LEASE_TERMS_PKG" AS
-- $Header: PNILTRHB.pls 120.3 2005/11/30 21:36:01 appldev noship $

-- +==========================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +==========================================================================+
-- |  Name
-- |    PN_INDEX_LEASE_TERMS_PKG
-- |
-- |  Description
-- |    This package contains row handler procedures to populate
-- |     PN_INDEX_LEASE_TERMS_ALL.
-- |
-- |  History
-- |    05-dec-2001 achauhan  Created
-- |    15-JAN-2002 Mrinal Misra   Added dbdrv command.
-- |    01-FEB-2002 Mrinal Misra   Added checkfile command.
-- |    14-JUL-2005 SatyaDeep      Replaced bases views by _ALL table
-- +==========================================================================+


-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 14-jul-05  sdmahesh o Bug 4284035 - Replaced pn_index_lease_terms with
--                       _ALL table.
-- 12-Nov-05  HRodda   o Bug 4734542 Modified select statement to select
--                       org_id from index_leases_all instead of
--                       pn_index_lease_terms_all.
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-------------------------------------------------------------------------------
procedure INSERT_ROW
(
         X_INDEX_LEASE_TERM_ID         IN OUT NOCOPY    NUMBER
        ,X_INDEX_LEASE_ID              IN        NUMBER
        ,X_INDEX_PERIOD_ID             IN        NUMBER
        ,X_LEASE_TERM_ID               IN        NUMBER
        ,X_RENT_INCREASE_TERM_ID       IN        NUMBER
        ,X_AMOUNT                      IN        NUMBER
        ,X_APPROVED_FLAG               IN        VARCHAR2
        ,X_INDEX_TERM_INDICATOR        IN        VARCHAR2
        ,X_LAST_UPDATE_DATE            IN        DATE
        ,X_LAST_UPDATED_BY             IN        NUMBER
        ,X_CREATION_DATE               IN        DATE
        ,X_CREATED_BY                  IN        NUMBER
        ,X_LAST_UPDATE_LOGIN           IN        NUMBER
) IS

l_return_status         VARCHAR2(30)    := NULL;
l_rowId                 VARCHAR2(18)    := NULL;
l_rowExists             VARCHAR2(10)    := NULL;
l_org_id                NUMBER;

CURSOR org_cur IS
  SELECT org_id
  FROM   pn_index_leases_all
  WHERE  index_lease_id = x_index_lease_id;


BEGIN

  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.insert_row (+)');

  FOR rec IN org_cur LOOP
    l_org_id := rec.org_id;
  END LOOP;

-- If no INDEX_LEASE_TERM_ID is provided, get one from sequence


         BEGIN
            SELECT '1'
            INTO l_rowExists
                           FROM DUAL
            WHERE EXISTS (
                         SELECT 1
                         FROM  pn_index_lease_terms_all ilt
                         WHERE ilt.index_lease_id  = x_index_lease_id
                                        AND   ilt.index_period_id = x_index_period_id
                                        AND   ilt.lease_term_id   = x_lease_term_id
                         AND   ilt.rent_increase_term_id = x_rent_increase_term_id);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_rowExists := '0';
      END;


      IF l_rowExists = '0' THEN

                 IF (X_INDEX_LEASE_TERM_ID IS NULL) THEN
                        SELECT PN_INDEX_LEASE_TERM_S.nextval into    X_INDEX_LEASE_TERM_ID from    dual;
                 END IF;

                INSERT INTO PN_INDEX_LEASE_TERMS_ALL
                (
                        index_lease_term_id
                        ,index_lease_id
                        ,index_period_id
                        ,lease_term_id
                        ,rent_increase_term_id
                        ,amount
                        ,approved_flag
                        ,index_term_indicator
                        ,last_update_date
                        ,last_updated_by
                        ,creation_date
                        ,created_by
                        ,last_update_login
                        ,org_id
                )
               VALUES
           (
                        x_index_lease_term_id
                        ,x_index_lease_id
                        ,x_index_period_id
                        ,x_lease_term_id
                        ,x_rent_increase_term_id
                        ,x_amount
                        ,x_approved_flag
                        ,x_index_term_indicator
                        ,x_last_update_date
                        ,x_last_updated_by
                        ,x_creation_date
                        ,x_created_by
                        ,x_last_update_login
                        ,l_org_id
                );

           END IF;
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.insert_row (-)');
END INSERT_ROW;



-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 14-jul-05  sdmahesh o Bug 4284035 - Replaced pn_index_lease_terms with _ALL table.
------------------------------------------------------------------------------
procedure UPDATE_ROW
(
         X_INDEX_LEASE_TERM_ID         IN        NUMBER
        ,X_INDEX_LEASE_ID              IN        NUMBER
        ,X_INDEX_PERIOD_ID             IN        NUMBER
        ,X_LEASE_TERM_ID               IN        NUMBER
        ,X_RENT_INCREASE_TERM_ID       IN        NUMBER
        ,X_AMOUNT                      IN        NUMBER
        ,X_APPROVED_FLAG               IN        VARCHAR2
        ,X_INDEX_TERM_INDICATOR        IN        VARCHAR2
        ,X_LAST_UPDATE_DATE            IN        DATE
        ,X_LAST_UPDATED_BY             IN        NUMBER
        ,X_LAST_UPDATE_LOGIN           IN        NUMBER
) IS

BEGIN

  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.update_row (+)');

UPDATE PN_INDEX_LEASE_TERMS_ALL
SET
         INDEX_LEASE_TERM_ID   = X_INDEX_LEASE_TERM_ID
        ,INDEX_LEASE_ID        = X_INDEX_LEASE_ID
        ,INDEX_PERIOD_ID       = X_INDEX_PERIOD_ID
        ,LEASE_TERM_ID         = X_LEASE_TERM_ID
        ,RENT_INCREASE_TERM_ID = X_RENT_INCREASE_TERM_ID
        ,AMOUNT                = X_AMOUNT
        ,APPROVED_FLAG         = X_APPROVED_FLAG
        ,INDEX_TERM_INDICATOR  = X_INDEX_TERM_INDICATOR
        ,LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE
        ,LAST_UPDATED_BY       = X_LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
WHERE INDEX_LEASE_TERM_ID     =  X_INDEX_LEASE_TERM_ID;

if (sql%notfound) then raise no_data_found ; end if;

  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.update_row (-)');
end update_row;




-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 14-jul-05  sdmahesh o Bug 4284035 - Replaced pn_index_lease_terms with _ALL table.
------------------------------------------------------------------------------

procedure LOCK_ROW
(
         X_INDEX_LEASE_TERM_ID         IN        NUMBER
        ,X_INDEX_LEASE_ID              IN        NUMBER
        ,X_INDEX_PERIOD_ID             IN        NUMBER
        ,X_LEASE_TERM_ID               IN        NUMBER
        ,X_RENT_INCREASE_TERM_ID       IN        NUMBER
        ,X_AMOUNT                      IN        NUMBER
        ,X_APPROVED_FLAG                     IN      VARCHAR2
        ,X_INDEX_TERM_INDICATOR        IN            VARCHAR2
) IS
CURSOR c1 IS
SELECT  *
FROM  PN_INDEX_LEASE_TERMS_ALL
WHERE INDEX_LEASE_TERM_ID = X_INDEX_LEASE_TERM_ID
FOR UPDATE OF INDEX_LEASE_TERM_ID NOWAIT;
tlinfo c1%ROWTYPE;

BEGIN
  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.lock_row (+)');
open c1; fetch c1 into tlinfo; if (c1%notfound) then close c1; return; end if; close c1;
if (
             tlinfo.INDEX_LEASE_TERM_ID         = X_INDEX_LEASE_TERM_ID
        AND  tlinfo.INDEX_LEASE_ID              = X_INDEX_LEASE_ID
        AND  tlinfo.INDEX_PERIOD_ID             = X_INDEX_PERIOD_ID
        AND      tlinfo.LEASE_TERM_ID                           = X_LEASE_TERM_ID
        AND      tlinfo.RENT_INCREASE_TERM_ID           = X_RENT_INCREASE_TERM_ID
        AND      tlinfo.AMOUNT                                          = X_AMOUNT
        AND      tlinfo.APPROVED_FLAG                           = X_APPROVED_FLAG
        AND      tlinfo.INDEX_TERM_INDICATOR            = X_INDEX_TERM_INDICATOR
)
then null; ELSE
fnd_message.set_name('FND', 'FORM_RECORD_CHANGED'); app_exception.raise_exception;
end if;
  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.lock_row (-)');
end LOCK_ROW;



-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 14-jul-05  sdmahesh o Bug 4284035 - Replaced pn_index_lease_terms with
--                                                               _ALL table.
------------------------------------------------------------------------------

procedure delete_row
(
         X_INDEX_LEASE_TERM_ID         IN                NUMBER
        ,X_INDEX_LEASE_ID              IN        NUMBER
        ,X_INDEX_PERIOD_ID             IN        NUMBER
        ,X_LEASE_TERM_ID               IN        NUMBER
        ,X_RENT_INCREASE_TERM_ID       IN        NUMBER
) IS

l_rowExists                             VARCHAR2(10)    := NULL;

BEGIN
  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.delete_row (+)');

         BEGIN
            SELECT '1'
            INTO l_rowExists
            FROM DUAL
            WHERE EXISTS (
                         SELECT 1
                           FROM  pn_index_lease_terms_all ilt
                           WHERE ilt.index_lease_id  = x_index_lease_id
                           AND   ilt.index_period_id = x_index_period_id
                           AND   ilt.lease_term_id   = x_lease_term_id
                           AND   ilt.rent_increase_term_id      = x_rent_increase_term_id);

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_rowExists := '0';
      END;

      IF l_rowExists = '1' THEN

        DELETE FROM pn_index_lease_terms_all ilt
        WHERE   ilt.index_lease_id              = x_index_lease_id
        AND     ilt.index_period_id             = x_index_period_id
        AND     ilt.lease_term_id               = x_lease_term_id
        AND     ilt.rent_increase_term_id       = x_rent_increase_term_id;

         if (sql%notfound) then
            raise no_data_found;
         end if;

      END IF;
  PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_TERMS_PKG.delete_row (-)');
END delete_row;


END PN_INDEX_LEASE_TERMS_PKG;

/
