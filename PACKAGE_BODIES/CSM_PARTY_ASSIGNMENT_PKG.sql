--------------------------------------------------------
--  DDL for Package Body CSM_PARTY_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PARTY_ASSIGNMENT_PKG" AS
/* $Header: csmptagb.pls 120.4 2008/02/29 08:58:24 anaraman noship $ */

PROCEDURE INSERT_PARTY_ASSG (p_user_id        IN  NUMBER,
                             p_party_id       IN  NUMBER,
                             p_owner_id       IN  NUMBER,
                             p_party_site_id  IN  NUMBER DEFAULT NULL,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_error_message  OUT NOCOPY VARCHAR2
                            )

IS

--variable declarations

l_chk_party                 NUMBER := NULL;
l_chk_party_site            NUMBER := NULL;
l_cnt_party                 NUMBER := 0;
l_cnt_party_site            NUMBER := 0;
l_cnt_upd_site              NUMBER := 0;
l_cnt_upd_party             NUMBER := 0;
l_sqlerrno                  VARCHAR2(20);
l_sqlerrmsg                 VARCHAR2(2000);
l_party_site_id             NUMBER;
l_deleted_flag              VARCHAR2(1) := NULL;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG Package ', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

  l_party_site_id := NVL(p_party_site_id,-1);

  IF l_party_site_id = -1

  THEN

    SELECT COUNT(1)
    INTO   l_chk_party
    FROM   hz_parties hp
    WHERE  hp.party_id = p_party_id;

  ELSIF l_party_site_id <> -1

  THEN

    SELECT COUNT(1)
    INTO   l_chk_party_site
    FROM   hz_party_sites hps
    WHERE  hps.party_id = p_party_id
    AND    hps.party_site_id = p_party_site_id;

  END IF;

  IF l_chk_party = 0

  THEN

    x_error_message := 'The party records does not exists in the HZ PARTIES base table for the party - '||p_party_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF l_chk_party_site = 0

  THEN

    x_error_message := 'The party site records does not exists in the HZ PARTY SITES base table for the party - '||p_party_id|| ' and site -'||p_party_site_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

      SELECT COUNT(1)
      INTO   l_cnt_party
      FROM   CSM_PARTY_ASSIGNMENT
      WHERE  USER_ID       = p_user_id
      AND    PARTY_ID      = p_party_id
      AND    PARTY_SITE_ID = l_party_site_id;

        IF l_cnt_party = 0 AND l_party_site_id = -1 THEN

        CSM_UTIL_PKG.LOG('Inserting the record with party id only ', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

           INSERT INTO CSM_PARTY_ASSIGNMENT( USER_ID,           PARTY_ID,
                                             OWNER_ID,          PARTY_SITE_ID,
                                             DELETED_FLAG,      CREATED_BY,
                                             CREATION_DATE,     LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,  LAST_UPDATE_LOGIN
                                           )
                                         VALUES
                                           ( p_user_id,         p_party_id,
                                             p_owner_id,        l_party_site_id,
                                             'N',               1,
                                             SYSDATE,           1,
                                             SYSDATE,           1
                                           );

        END IF;

        IF l_cnt_party = 0 AND l_party_site_id <> -1 THEN

          SELECT COUNT(1)
          INTO   l_cnt_party_site
          FROM   CSM_PARTY_ASSIGNMENT
          WHERE  USER_ID       = p_user_id
          AND    PARTY_ID      = p_party_id
          AND    PARTY_SITE_ID = -2;

            IF l_cnt_party_site = 0 THEN

            /* if the user first assign party alone to
               a user and then assign a record with party and site then
               we have to delete the record which hold the party alone */

               SELECT COUNT(1)
               INTO   l_cnt_upd_party
               FROM   CSM_PARTY_ASSIGNMENT
               WHERE  USER_ID       = p_user_id
               AND    PARTY_ID      = p_party_id
               AND    PARTY_SITE_ID = -1;

                 IF l_cnt_upd_party <> 0 THEN

                    CSM_UTIL_PKG.LOG('Updating the deleted flag to Y for party record ', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

                    UPDATE CSM_PARTY_ASSIGNMENT
                    SET    DELETED_FLAG  = 'Y'
                    WHERE  USER_ID       = p_user_id
                    AND    PARTY_ID      = p_party_id
                    AND    PARTY_SITE_ID = -1;

                 END IF;

             /* if the party is inserted along with the party_site
                another record is inserted with party_site_id as -2
                for deleting the access table purpose*/

              CSM_UTIL_PKG.LOG('Inserting the record with party id and party site id along with another record with - 2 as party site value', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

              INSERT INTO CSM_PARTY_ASSIGNMENT( USER_ID,              PARTY_ID,
                                                OWNER_ID,             PARTY_SITE_ID,
                                                DELETED_FLAG,         CREATED_BY,
                                                CREATION_DATE,        LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,     LAST_UPDATE_LOGIN
                                              )
                                            VALUES
                                              ( p_user_id,            p_party_id,
                                                p_owner_id,           -2,
                                                'N',                  1,
                                                SYSDATE,              1,
                                                SYSDATE,              1
                                              );

              INSERT INTO CSM_PARTY_ASSIGNMENT( USER_ID,              PARTY_ID,
                                                OWNER_ID,             PARTY_SITE_ID,
                                                DELETED_FLAG,         CREATED_BY,
                                                CREATION_DATE,        LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,     LAST_UPDATE_LOGIN
                                              )
                                            VALUES
                                              ( p_user_id,            p_party_id,
                                                p_owner_id,           l_party_site_id,
                                                'N',                  1,
                                                SYSDATE,              1,
                                                SYSDATE,              1
                                              );
            END IF;

            IF l_cnt_party_site <> 0 THEN

              CSM_UTIL_PKG.LOG('Inserting the record with party id and party site id only', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

              INSERT INTO CSM_PARTY_ASSIGNMENT( USER_ID,              PARTY_ID,
                                                OWNER_ID,             PARTY_SITE_ID,
                                                DELETED_FLAG,         CREATED_BY,
                                                CREATION_DATE,        LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,     LAST_UPDATE_LOGIN
                                              )
                                            VALUES
                                              ( p_user_id,            p_party_id,
                                                p_owner_id,           l_party_site_id,
                                                'N',                  1,
                                                SYSDATE,              1,
                                                SYSDATE,              1
                                              );

            END IF;

        END IF;

   /* if a party is removed by mistake and again added
      we are updating the deleted flag to N*/

    IF l_cnt_party <> 0 THEN

        SELECT deleted_flag
        INTO   l_deleted_flag
        FROM   CSM_PARTY_ASSIGNMENT
        WHERE  USER_ID       = p_user_id
        AND    PARTY_ID      = p_party_id
        AND    PARTY_SITE_ID = l_party_site_id;

          IF l_deleted_flag = 'Y' THEN

              CSM_UTIL_PKG.LOG('Updating the deleted flag to N for record which was deleted by mistake', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

              UPDATE CSM_PARTY_ASSIGNMENT
              SET    DELETED_FLAG  = 'N'
              WHERE  USER_ID       = p_user_id
              AND    PARTY_ID      = p_party_id
              AND    PARTY_SITE_ID = l_party_site_id;

          END IF;

    END IF;

     /* if the deleted flag is set to Y for a party
        and then a new record with party and party site id is inserted
        then we are updating the deleted flag to N*/

      SELECT COUNT(1)
      INTO   l_cnt_upd_site
      FROM   CSM_PARTY_ASSIGNMENT
      WHERE  USER_ID       = p_user_id
      AND    PARTY_ID      = p_party_id
      AND    PARTY_SITE_ID not in (-2,-1)
      AND    DELETED_FLAG  = 'N';

        IF l_cnt_upd_site <> 0  THEN

          CSM_UTIL_PKG.LOG('Updating the deleted flag to N for record which hold the -2 value if any record with part site is inserted', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

          UPDATE CSM_PARTY_ASSIGNMENT
          SET    DELETED_FLAG  = 'N'
          WHERE  USER_ID       = p_user_id
          AND    PARTY_ID      = p_party_id
          AND    OWNER_ID      = p_owner_id
          AND    PARTY_SITE_ID = -2;

        END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_error_message := 'PARTY_ID successfully Inserted ';
          CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG Package ', 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS THEN
    l_sqlerrno      := TO_CHAR(SQLCODE);
    l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_message := 'Exception in CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG Procedure :'||'while inserting the party -'||p_party_id|| 'for the user -'||p_user_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_ASSIGNMENT_PKG.INSERT_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

END INSERT_PARTY_ASSG;

PROCEDURE DELETE_PARTY_ASSG (p_user_id        IN  NUMBER,
                             p_party_id       IN  NUMBER,
                             p_owner_id       IN  NUMBER,
                             p_party_site_id  IN  NUMBER DEFAULT NULL,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_error_message  OUT NOCOPY VARCHAR2
                            )

IS

--variable declarations

l_cnt_upd                  NUMBER := 0;
l_cnt_upd_site             NUMBER := 0;
l_sqlerrno                 VARCHAR2(20);
l_sqlerrmsg                VARCHAR2(2000);
l_error_message            VARCHAR2(2000);
l_party_site_id            NUMBER;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG Package ', 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

  l_party_site_id := NVL(p_party_site_id,-1);

    SELECT COUNT(1)
    INTO   l_cnt_upd
    FROM   CSM_PARTY_ASSIGNMENT
    WHERE  USER_ID       = p_user_id
    AND    PARTY_ID      = p_party_id
    AND    PARTY_SITE_ID = l_party_site_id;

      IF l_cnt_upd <> 0  THEN

       CSM_UTIL_PKG.LOG('Updating the deleted flag to Y for Deleted records', 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

        UPDATE CSM_PARTY_ASSIGNMENT
        SET    DELETED_FLAG  = 'Y'
        WHERE  USER_ID       = p_user_id
        AND    PARTY_ID      = p_party_id
        AND    OWNER_ID      = p_owner_id
        AND    PARTY_SITE_ID = l_party_site_id;

        l_error_message := 'PARTY_ID successfully Deleted ';

      ELSE

        CSM_UTIL_PKG.LOG('No records found for Deleting', 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

        l_error_message := 'No records found for Deleting for user - '||p_user_id ||'and party -'||p_party_id||' and party site -'||l_party_site_id;

      END IF;

        /* if all the party_sites are deleted
           then record which holds the party_id (i.e -2)
           will also be deleted*/

        SELECT COUNT(1)
        INTO   l_cnt_upd_site
        FROM   CSM_PARTY_ASSIGNMENT
        WHERE  USER_ID       = p_user_id
        AND    PARTY_ID      = p_party_id
        AND    PARTY_SITE_ID not in (-2,-1)
        AND    DELETED_FLAG  = 'N';

          IF l_cnt_upd_site = 0  THEN

            CSM_UTIL_PKG.LOG('Updating the deleted flag to Y for the record which holds the -2 value', 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

            UPDATE CSM_PARTY_ASSIGNMENT
            SET    DELETED_FLAG  = 'Y'
            WHERE  USER_ID       = p_user_id
            AND    PARTY_ID      = p_party_id
            AND    OWNER_ID      = p_owner_id
            AND    PARTY_SITE_ID = -2;

          END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_error_message := l_error_message;
          CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG Package ', 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION
   WHEN others THEN
     l_sqlerrno      := TO_CHAR(SQLCODE);
     l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message := 'Exception in CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG Procedure :'||'while deleting the party -'||p_party_id|| 'for the user -'||p_user_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_ASSIGNMENT_PKG.DELETE_PARTY_ASSG',FND_LOG.LEVEL_EXCEPTION);

END DELETE_PARTY_ASSG;

END CSM_PARTY_ASSIGNMENT_PKG;

/
