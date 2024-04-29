--------------------------------------------------------
--  DDL for Package Body HZ_BATCH_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BATCH_ACTION_PUB" AS
/*$Header: ARHBATAB.pls 120.16 2006/05/03 09:03:27 vravicha noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

 TYPE sel_cur           IS REF CURSOR;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------
/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE action_on_entities ( p_batch_id            IN NUMBER,
                               p_entity              IN VARCHAR2,
                               p_action_on_entity    IN VARCHAR2
                             );

/* Commented out for bug 4673725
PROCEDURE update_int_tables ( p_batch_id                IN NUMBER,
                              p_tab_name                IN VARCHAR2,
                              p_orig_system             IN VARCHAR2,
                              p_orig_system_osr   IN VARCHAR2,
                              p_dup_os_val              IN VARCHAR2,
                              p_dup_osr_val             IN VARCHAR2,
                              p_action_on_entity        IN VARCHAR2
                            );
*/

PROCEDURE reg_action_on_party ( p_batch_id                  IN NUMBER,
                                p_action_new_parties        IN VARCHAR2,
                                p_action_existing_parties   IN VARCHAR2,
                                p_action_dup_parties        IN VARCHAR2,
                                p_action_pot_dup_parties    IN VARCHAR2,
                                x_return_status             OUT NOCOPY VARCHAR2
                             );

PROCEDURE reg_action_on_sites ( p_batch_id              IN NUMBER,
                               p_action_new_addrs       IN VARCHAR2,
                               p_action_existing_addrs  IN VARCHAR2,
                               p_action_pot_dup_addrs   IN VARCHAR2,
                               x_return_status          OUT NOCOPY VARCHAR2
                             );

PROCEDURE reg_action_on_cont ( p_batch_id                  IN NUMBER,
                               p_action_new_contacts       IN VARCHAR2,
                               p_action_existing_contacts  IN VARCHAR2,
                               p_action_pot_dup_contacts   IN VARCHAR2,
                               x_return_status             OUT NOCOPY VARCHAR2
                             ) ;

PROCEDURE reg_action_on_cpts ( p_batch_id                  IN NUMBER,
                               p_action_new_cpts           IN VARCHAR2,
                               p_action_existing_cpts      IN VARCHAR2,
                               p_action_pot_dup_cpts       IN VARCHAR2,
                               x_return_status             OUT NOCOPY VARCHAR2
                             );


PROCEDURE reg_action_on_supents (x_return_status OUT NOCOPY VARCHAR2) ;


PROCEDURE reg_action_on_finents (x_return_status OUT NOCOPY VARCHAR2) ;

PROCEDURE action_on_parties(p_sql IN VARCHAR2,
                            p_batch_id IN NUMBER,
                            p_action_new_parties       IN VARCHAR2,
                            p_action_existing_parties  IN VARCHAR2,
                            p_action_dup_parties IN VARCHAR2,
                            p_action_pot_dup_parties IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE action_on_sites(p_sql IN VARCHAR2,
                          p_batch_id IN NUMBER,
			  p_action_new_addrs       IN VARCHAR2,
                          p_action_existing_addrs  IN VARCHAR2,
                          p_action_pot_dup_addrs IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE action_on_contacts(p_sql IN VARCHAR2,
                             p_batch_id IN NUMBER,
			     p_action_new_contacts       IN VARCHAR2,
                             p_action_existing_contacts  IN VARCHAR2,
                             p_action_pot_dup_contacts   IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE action_on_contactpts(p_sql IN VARCHAR2,
                               p_batch_id IN NUMBER,
                               p_action_new_cpts       IN VARCHAR2,
                               p_action_existing_cpts  IN VARCHAR2,
                               p_action_pot_dup_cpts VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2);

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   08-18-2003    Rajeshwari P      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
        END IF;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   08-18-2003    Rajeshwari P      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;

END disable_debug;
*/

/**
 * PRIVATE PROCEDURE action_on_entities
 *
 * DESCRIPTION
 *     private procedure to implement the actions on entities.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *    p_batch_id         Interface Batch ID.
 *    p_entity           PARTY, PARTY_SITES, CONTACTS and
 *                       CONTACT POINTS.a
 *    p_action_on_entity Action to be taken on entities.
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P       o Created.
 *
 */

PROCEDURE action_on_entities (
    p_batch_id          IN NUMBER,
    p_entity            IN VARCHAR2,
    p_action_on_entity  IN VARCHAR2
 ) IS


 TYPE L_DUP_RECORD_OSList is TABLE OF HZ_IMP_INT_DEDUP_RESULTS.dup_record_os%TYPE;
      l_dup_record_os      L_DUP_RECORD_OSList;
      l_winner_record_os   L_DUP_RECORD_OSList;
      l_record_os          L_DUP_RECORD_OSList;
 TYPE L_DUP_RECORD_OSRList is TABLE OF HZ_IMP_INT_DEDUP_RESULTS.dup_record_osr%TYPE;
      l_dup_record_osr     L_DUP_RECORD_OSRList ;
      l_winner_record_osr  L_DUP_RECORD_OSRList;
      l_record_osr         L_DUP_RECORD_OSRList;

 l_rec_os   HZ_IMP_INT_DEDUP_RESULTS.dup_record_os%TYPE;
 l_rec_osr  HZ_IMP_INT_DEDUP_RESULTS.dup_record_osr%TYPE;

 CURSOR  tobe_removed_rec( p_batch_id IN NUMBER, p_entity IN VARCHAR2)  IS
 SELECT dup_record_os, dup_record_osr
 FROM     HZ_IMP_INT_DEDUP_RESULTS
 WHERE batch_id = p_batch_id
 AND entity = p_entity ;

 CURSOR sel_dup_set (p_batch_id IN NUMBER, p_entity IN  VARCHAR2 )  IS
 select distinct winner_record_os, winner_record_osr
 from hz_imp_int_dedup_results
 where batch_id = p_batch_id
 and entity = p_entity
 group by winner_record_os,winner_record_osr;

--//Choose the latest updated record
 CURSOR max_last_date ( p_batch_id in NUMBER , p_entity in VARCHAR2,p_winner_record_os IN VARCHAR2,  p_winner_record_osr IN VARCHAR2) IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_last_update_date,sysdate) = (  SELECT MAX( nvl(DUP_LAST_UPDATE_DATE,sysdate))
 			     FROM  HZ_IMP_INT_DEDUP_RESULTS
 			     WHERE   batch_id =p_batch_id
                             and entity = p_entity
                             AND winner_record_os = p_winner_record_os
                             AND winner_record_osr = p_winner_record_osr   )
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;

--//Choose the latest created record
CURSOR max_created_date ( p_batch_id in NUMBER , p_entity in VARCHAR2,p_winner_record_os IN VARCHAR2,  p_winner_record_osr IN VARCHAR2) IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_creation_date,sysdate) = (  SELECT MAX( nvl(DUP_CREATION_DATE,sysdate))
                             FROM  HZ_IMP_INT_DEDUP_RESULTS
                             WHERE   batch_id =p_batch_id
                             and entity = p_entity
                             AND winner_record_os = p_winner_record_os
                             AND winner_record_osr = p_winner_record_osr   )
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;

--//Choose the earliest created record
CURSOR min_created_date ( p_batch_id in NUMBER , p_entity in VARCHAR2,p_winner_record_os IN VARCHAR2,  p_winner_record_osr IN VARCHAR2) IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_creation_date,sysdate) = (  SELECT MIN( nvl(DUP_CREATION_DATE,sysdate))
                             FROM  HZ_IMP_INT_DEDUP_RESULTS
                             WHERE   batch_id =p_batch_id
                             and entity = p_entity
                             AND winner_record_os = p_winner_record_os
                             AND winner_record_osr = p_winner_record_osr   )
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;


--// Cursor to select the child entities of Party entity
 CURSOR get_party_rec(p_batch_id IN NUMBER) is
 SELECT party_orig_system, party_orig_system_reference
 FROM    HZ_IMP_PARTIES_INT
 WHERE   batch_id = p_batch_id
 AND     interface_status = 'R'
 ;

--//Cursor to select the child entities of Site entity
 CURSOR get_site_rec(p_batch_id IN NUMBER) is
 SELECT site_orig_system, site_orig_system_reference
 FROM    HZ_IMP_ADDRESSES_INT
 WHERE   batch_id = p_batch_id
 AND     interface_status = 'R';

--//Cursor to select the child entities of contact entity
 CURSOR get_contacts_rec(p_batch_id IN NUMBER) is
 SELECT contact_orig_system, contact_orig_system_reference
 FROM    HZ_IMP_CONTACTS_INT
 WHERE   batch_id = p_batch_id
 AND     interface_status = 'R';

    l_last_fetch                BOOLEAN;
    l_last_fetch_result         BOOLEAN;
    i                           NUMBER;
    j                           NUMBER;
    commit_counter              NUMBER;
    l_debug_prefix		VARCHAR2(30) := '';

BEGIN
   -- Check if API is called in debug mode. If yes, enable debug.
      --enable_debug;

   -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update interface tables for action=remove_all (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

   commit_counter := 1000;

     if p_action_on_entity = 'REMOVE_ALL' THEN
        IF p_entity = 'PARTY' THEN
  --Mark all the records to be removed
          UPDATE HZ_IMP_PARTIES_INT
          SET interface_status = 'R'
          WHERE batch_id = p_batch_id
	   AND( party_orig_system, party_orig_system_reference ) in
                ( select dup_record_os, dup_record_osr
                  FROM HZ_IMP_INT_DEDUP_RESULTS result
                  WHERE result.batch_id = p_batch_id
		  --AND   result.dup_record_os = result.winner_record_os --Bug3339642.
		  --AND   result.dup_record_osr <> result.winner_record_osr --Bug3339642.
                  AND result.entity = 'PARTY');

        ELSIF p_entity = 'PARTY_SITES' THEN
  --Mark all the site records to be removed
           UPDATE HZ_IMP_ADDRESSES_INT
           SET interface_status = 'R'
           WHERE batch_id = p_batch_id
           AND( site_orig_system, site_orig_system_reference ) in
                ( select dup_record_os, dup_record_osr
                  FROM HZ_IMP_INT_DEDUP_RESULTS result
                  WHERE result.batch_id = p_batch_id
		  --AND   result.dup_record_os = result.winner_record_os --Bug3339642.
		  --AND   result.dup_record_osr <> result.winner_record_osr --Bug3339642.
                  AND result.entity = 'PARTY_SITES');

        ELSIF p_entity = 'CONTACTS' THEN
  --Mark all the contact records to be removed
           UPDATE HZ_IMP_CONTACTS_INT
           SET interface_status = 'R'
           WHERE batch_id = p_batch_id
	   AND( contact_orig_system,contact_orig_system_reference) in
                ( select dup_record_os, dup_record_osr
                  FROM HZ_IMP_INT_DEDUP_RESULTS result
                  WHERE result.batch_id = p_batch_id
		  --AND   result.dup_record_os = result.winner_record_os    --Bug3339642.
		  --AND   result.dup_record_osr <> result.winner_record_osr --Bug3339642.
                  AND result.entity = 'CONTACTS');

        ELSIF p_entity = 'CONTACT_POINTS' THEN
  --Mark all the contact point records to be removed
           UPDATE HZ_IMP_CONTACTPTS_INT
           SET interface_status = 'R'
           WHERE batch_id = p_batch_id
	   AND(cp_orig_system ,cp_orig_system_reference) in
                ( select dup_record_os, dup_record_osr
                  FROM HZ_IMP_INT_DEDUP_RESULTS result
                  WHERE result.batch_id = p_batch_id
		  --AND   result.dup_record_os = result.winner_record_os --Bug3339642.
		  --AND   result.dup_record_osr <> result.winner_record_osr --Bug3339642.
                  AND result.entity = 'CONTACT_POINTS');

        END IF;
--// The other actions, keep_latest_updated,keep_latest_created, keep_earliest_created
    else

      BEGIN
  --Pick the duplicate set
        OPEN sel_dup_set(p_batch_id, p_entity );
        LOOP
        FETCH sel_dup_set BULK COLLECT INTO
              l_winner_record_os, l_winner_record_osr
        LIMIT commit_counter;

        IF sel_dup_set%NOTFOUND THEN
           l_last_fetch_result := TRUE;
        END IF;

        IF l_winner_record_osr.COUNT = 0 AND l_last_fetch_result THEN
             EXIT;
        END IF;

        FOR i in l_winner_record_osr.FIRST..l_winner_record_osr.LAST
        LOOP
           BEGIN

        IF p_action_on_entity = 'KEEP_LATEST_UPDATED' THEN
--Select the record with max dup_last_update_date

             OPEN max_last_date(p_batch_id, p_entity, l_winner_record_os(i), l_winner_record_osr(i));
             FETCH max_last_date INTO
                   l_rec_os, l_rec_osr ;
             CLOSE max_last_date;

        ELSIF p_action_on_entity = 'KEEP_LATEST_CREATED' THEN
--Select the record with max dup_creation_date

             OPEN max_created_date(p_batch_id, p_entity, l_winner_record_os(i), l_winner_record_osr(i));
             FETCH max_created_date INTO
                   l_rec_os, l_rec_osr ;
             CLOSE max_created_date;

        ELSIF p_action_on_entity = 'KEEP_EARLIEST_CREATED' THEN
--Select the record with earliest creation date

             OPEN min_created_date(p_batch_id, p_entity, l_winner_record_os(i), l_winner_record_osr(i));
             FETCH min_created_date INTO
                   l_rec_os, l_rec_osr ;
             CLOSE min_created_date;

        END IF;

--Set the winner record

                UPDATE HZ_IMP_INT_DEDUP_RESULTS
                SET WINNER_RECORD_OS = l_rec_os ,WINNER_RECORD_OSR = l_rec_osr
                WHERE batch_id = p_batch_id
                AND entity = p_entity
                AND WINNER_RECORD_OS = l_winner_record_os(i)
                AND WINNER_RECORD_OSR = l_winner_record_osr(i) ;

--Remove the duplicate records
--Hz_parties
          IF p_entity = 'PARTY' THEN

                UPDATE HZ_IMP_PARTIES_INT party
                SET INTERFACE_STATUS = 'R'
                WHERE batch_id = p_batch_id
                AND( party_orig_system, party_orig_system_reference ) in
                ( select dup_record_os, dup_record_osr
                  FROM HZ_IMP_INT_DEDUP_RESULTS result
                  WHERE result.batch_id = p_batch_id
                  AND result.entity = 'PARTY'
                  AND result.dup_record_osr <> l_rec_osr
                  AND WINNER_RECORD_OS = l_rec_os
                  AND WINNER_RECORD_OSR = l_rec_osr );

         ELSIF p_entity = 'PARTY_SITES' THEN
                UPDATE HZ_IMP_ADDRESSES_INT
                SET INTERFACE_STATUS = 'R'
                WHERE batch_id = p_batch_id
                AND( site_orig_system, site_orig_system_reference ) in
                   ( select dup_record_os, dup_record_osr
                     FROM HZ_IMP_INT_DEDUP_RESULTS result
                     WHERE result.batch_id = p_batch_id
                     AND result.entity = 'PARTY_SITES'
                     AND result.dup_record_osr <> l_rec_osr
                     AND WINNER_RECORD_OS = l_rec_os
                     AND WINNER_RECORD_OSR = l_rec_osr ) ;

         ELSIF p_entity = 'CONTACTS' THEN
                UPDATE HZ_IMP_CONTACTS_INT
                SET interface_status = 'R'
                WHERE batch_id = p_batch_id
                AND ( contact_orig_system,contact_orig_system_reference ) in
                    ( select dup_record_os, dup_record_osr
                      FROM HZ_IMP_INT_DEDUP_RESULTS result
                      WHERE result.batch_id = p_batch_id
                      AND result.entity = 'CONTACTS'
                      AND result.dup_record_osr <> l_rec_osr
                      AND WINNER_RECORD_OS = l_rec_os
                      AND WINNER_RECORD_OSR = l_rec_osr ) ;

          ELSIF p_entity = 'CONTACT_POINTS' THEN
                 UPDATE HZ_IMP_CONTACTPTS_INT
                 SET interface_status = 'R'
                 WHERE batch_id = p_batch_id
                 AND ( cp_orig_system, cp_orig_system_reference ) in
                    ( select dup_record_os, dup_record_osr
                      FROM HZ_IMP_INT_DEDUP_RESULTS result
                      WHERE result.batch_id = p_batch_id
                      AND result.entity = 'CONTACT_POINTS'
                      AND result.dup_record_osr <> l_rec_osr
                      AND WINNER_RECORD_OS = l_rec_os
                      AND WINNER_RECORD_OSR = l_rec_osr ) ;

          END IF;

           END;
         END LOOP;  -- End of For loop

             IF l_last_fetch_result = TRUE THEN
                EXIT;
             END IF;

             COMMIT;

             END LOOP;
             CLOSE sel_dup_set;

EXCEPTION
     WHEN OTHERS THEN
          NULL;
      END;

END IF;  -- //End of actions

IF p_entity = 'PARTY' THEN

  --Mark the child records to be removed
    Begin
            OPEN get_party_rec(p_batch_id ) ;
            LOOP
            FETCH get_party_rec BULK COLLECT INTO
                  l_record_os, l_record_osr
            LIMIT commit_counter;

            IF get_party_rec%NOTFOUND THEN
               l_last_fetch := TRUE;
            END IF;

            IF l_record_osr.COUNT = 0 AND l_last_fetch THEN
             EXIT;
            END IF;

  -- Start of Bug No: 3770319
  --Update site records
	    FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_ADDRESSES_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

  --Update site uses
            /*FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_ADDRESSUSES_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);
	       */
      -- Doing this here is redundant as it will be done during p_entity = 'PARTY_SITES' call.
  --Update contact records
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_CONTACTS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND ((sub_orig_system = l_record_os(i)
                    AND sub_orig_system_reference = l_record_osr(i))
		    OR
		    (obj_orig_system = l_record_os(i)
		     AND obj_orig_system_reference = l_record_osr(i))
		   );
  -- Update contact roles
     -- Doing this here is redundant as it will be done during p_entity = 'CONTACTS' call.
  -- Update contact point records
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_CONTACTPTS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

-- Update relationship records
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_RELSHIPS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND ((sub_orig_system = l_record_os(i)
                    AND sub_orig_system_reference = l_record_osr(i))
		    OR
		    (obj_orig_system = l_record_os(i)
		     AND obj_orig_system_reference = l_record_osr(i))
		   );

  -- End of Bug No: 3770319

  --Update Classifications
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_CLASSIFICS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

  --Update Credit Ratings
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_CREDITRTNGS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

  --Update Financial Numbers
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_FINNUMBERS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

  --Update Financial Reports
            FORALL i in l_record_osr.FIRST..l_record_osr.LAST
               UPDATE HZ_IMP_FINREPORTS_INT
               SET interface_status = 'R'
               WHERE batch_id = p_batch_id
               AND party_orig_system = l_record_os(i)
               AND party_orig_system_reference = l_record_osr(i);

            IF l_last_fetch = TRUE THEN
               EXIT;
            END IF;

            COMMIT;

            END LOOP; --Hz_parties
            CLOSE get_party_rec;

     EXCEPTION
     WHEN OTHERS THEN
          NULL;
     END;

    ELSIF p_entity = 'PARTY_SITES' THEN

  --Mark the child records to be removed
    BEGIN
           OPEN get_site_rec(p_batch_id );
           LOOP
           FETCH get_site_rec BULK COLLECT INTO
                  l_record_os, l_record_osr
           LIMIT commit_counter;

           IF get_site_rec%NOTFOUND THEN
               l_last_fetch := TRUE;
           END IF;

           IF l_record_osr.COUNT = 0 AND l_last_fetch THEN
              EXIT;
           END IF;

  --Update Site Uses
           FORALL i in l_record_osr.FIRST..l_record_osr.LAST
              UPDATE HZ_IMP_ADDRESSUSES_INT
	      SET interface_status = 'R'
              WHERE batch_id = p_batch_id
              AND site_orig_system = l_record_os(i)
              AND site_orig_system_reference = l_record_osr(i);

           IF  l_last_fetch = TRUE THEN
              EXIT;
          END IF;

          commit;
          END LOOP;
          close get_site_rec;

     EXCEPTION
     WHEN OTHERS THEN
          NULL;
     END;


    ELSIF p_entity = 'CONTACTS' THEN

  --Mark the child records to be removed
    BEGIN
           OPEN get_contacts_rec(p_batch_id );
           LOOP
           FETCH get_contacts_rec BULK COLLECT INTO
                  l_record_os, l_record_osr
           LIMIT commit_counter;

           IF get_contacts_rec%NOTFOUND THEN
               l_last_fetch := TRUE;
           END IF;

           IF l_record_osr.COUNT = 0 AND l_last_fetch THEN
              EXIT;
           END IF;

--//Update contact roles
           FORALL i in l_record_osr.FIRST..l_record_osr.LAST
              UPDATE HZ_IMP_CONTACTROLES_INT
              SET interface_status = 'R'
              WHERE batch_id = p_batch_id
              AND contact_orig_system = l_record_os(i)
              AND contact_orig_system_reference = l_record_osr(i);

           IF  l_last_fetch = TRUE THEN
               EXIT;
           END IF;

           commit;
           END LOOP;
           close get_contacts_rec;

    EXCEPTION
     WHEN OTHERS THEN
          NULL;
     END;
  END IF;

END action_on_entities;

/**
 * PRIVATE PROCEDURE update_int_tables
 *
 * DESCRIPTION
 *     private procedure to update the interface_status of
 *     interface tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *    p_batch_id         Interface Batch ID.
 *    p_tab_name         Interface table name.
 *    p_orig_system      Orig System of the duplicate record in
 *                       Interface table.
 *    p_orig_system_reference Orig system reference of the duplicate
 *                            record in Interface table.
 *    p_dup_os_val       Orig System Value
 *    p_dup_osr_val      Orig system reference Value.
 *    p_action_on_entity Action on entities.
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P       o Created.
 *
 */
/* Commented out for bug 4673725. Also removed the lines that caused
   SQL literal problem to avoid false positive.
PROCEDURE update_int_tables (
    p_batch_id          IN NUMBER,
    p_tab_name          IN VARCHAR2,
    p_orig_system       IN VARCHAR2,
    p_orig_system_osr   IN VARCHAR2,
    p_dup_os_val             IN VARCHAR2,
    p_dup_osr_val            IN VARCHAR2,
    p_action_on_entity       IN VARCHAR2
 ) IS
 l_debug_prefix		       VARCHAR2(30) := '';
BEGIN

   -- Check if API is called in debug mode. If yes, enable debug.
      --enable_debug;

   -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update interface tables (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  -- Debug info.
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update interface tables (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  -- Check if API is called in debug mode. If yes, disable debug.
     --disable_debug;

EXCEPTION
WHEN OTHERS THEN
NULL;

END update_int_tables;
*/

/**
 * PRIVATE PROCEDURE reg_action_on_party
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *    p_batch_id                Interface Batch ID.
 *    p_action_new_parties      Action on new parties.
 *                              Insert - Default
 *                              Remove - remove from parties interface table
 *                                       and all its child entities.
 *    p_action__existing_parties Action on existing parties.
 *                               Update - Default
 *                               Remove - remove from parties interface table
 *                                       and all its child entities.
 *    p_action_dup_parties      Action on duplicate parties.
 *                              Auto Merge - Default
 *                              Request Merge
 *                              Insert
 *                              Remove
 *   p_action_pot_dup_parties   Action on potential duplicates.
 *                              Request Merge - Default
 *                              Insert
 *                              Remove
 *
 *    OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-25-2003    Rajeshwari P       o Created.
 *
 */

 PROCEDURE reg_action_on_party( p_batch_id                 IN NUMBER,
                               p_action_new_parties       IN VARCHAR2,
                               p_action_existing_parties  IN VARCHAR2,
                               p_action_dup_parties       IN VARCHAR2,
                               p_action_pot_dup_parties   IN VARCHAR2,
                               x_return_status            OUT NOCOPY VARCHAR2
                             ) IS

 new_party_sql                  VARCHAR2(4000);
 existing_party_sql             VARCHAR2(4000);
 dup_party_sql                  VARCHAR2(4000);
 pot_dup_party_sql              VARCHAR2(4000);
 cur_sql                        VARCHAR2(4000);


 BEGIN

    -- Initialize API return status to success.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Choose the action to be performed

    new_party_sql := 'select int.party_id,int.party_orig_system,int.party_orig_system_reference '||
                 'from hz_imp_parties_int int, hz_imp_parties_sg stage '||
                 'where int.batch_id = :p_batch_id ' ||
                 'and int.batch_id = stage.batch_id '||
                 'and int.rowid = stage.int_row_id '||
                 'and int.dqm_action_flag IS NULL '||
                 'AND stage.action_flag = ''I'' ';

    existing_party_sql := 'select int.party_id,int.party_orig_system,int.party_orig_system_reference '||
                      'from hz_imp_parties_int int, hz_imp_parties_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'AND stage.action_flag = ''U'' ';

    dup_party_sql   := 'select int.party_id,int.party_orig_system,int.party_orig_system_reference '||
                   'from hz_imp_parties_int int, hz_imp_parties_sg stage '||
                   'where int.batch_id = :p_batch_id '||
                   'and int.batch_id = stage.batch_id '||
                   'and int.rowid = stage.int_row_id '||
                   'and int.dqm_action_flag = ''D'' ' ||
                   'AND stage.action_flag = ''I'' ';

    pot_dup_party_sql  := 'select int.party_id,int.party_orig_system,int.party_orig_system_reference '||
                      'from hz_imp_parties_int int, hz_imp_parties_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'and int.dqm_action_flag = ''P'' '||
                      'AND stage.action_flag = ''I'' ';

    IF ( p_action_new_parties IS NOT NULL ) THEN
         action_on_parties(new_party_sql,p_batch_id,p_action_new_parties,NULL,NULL,NULL,x_return_status);
    END IF;

    IF ( p_action_existing_parties IS NOT NULL ) THEN
         action_on_parties(existing_party_sql,p_batch_id,NULL,p_action_existing_parties,NULL,NULL,x_return_status);
    END IF;

    IF ( p_action_dup_parties IS NOT NULL ) THEN
         action_on_parties(dup_party_sql,p_batch_id,NULL,NULL,p_action_dup_parties,NULL,x_return_status);
    END IF;

    IF ( p_action_pot_dup_parties IS NOT NULL ) THEN
         action_on_parties(pot_dup_party_sql,p_batch_id,NULL,NULL,NULL,p_action_pot_dup_parties,x_return_status);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

END reg_action_on_party;

/**
 * PRIVATE PROCEDURE reg_action_on_sites
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *   p_batch_id                Interface Batch ID.
 *   p_action_new_addrs      Action on new sites.
 *                              Insert - Default
 *                              Remove - remove from Address interface table
 *                                       and all its child entities.
 *   p_action__existing_addrs Action on existing sites.
 *                               Update - Default
 *                               Remove - remove from parties interface table
 *                                       and all its child entities.
 *   p_action_pot_dup_addrs   Action on potential duplicates.
 *                              Request Merge - Default
 *                              Insert
 *                              Remove
 *
 *    OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-25-2003    Rajeshwari P       o Created.
 *
 */

 PROCEDURE reg_action_on_sites ( p_batch_id                 IN NUMBER,
                               p_action_new_addrs       IN VARCHAR2,
                               p_action_existing_addrs  IN VARCHAR2,
                               p_action_pot_dup_addrs   IN VARCHAR2,
                               x_return_status            OUT NOCOPY VARCHAR2
                             ) IS

  new_site_sql                  VARCHAR2(4000);
  existing_site_sql             VARCHAR2(4000);
  pot_dup_site_sql              VARCHAR2(4000);
  cur_sql                       VARCHAR2(4000);

 BEGIN

    -- Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Choose the action to be performed on sites

    new_site_sql := 'select int.site_orig_system,int.site_orig_system_reference '||
                 'from hz_imp_addresses_int int, hz_imp_addresses_sg stage '||
                 'where int.batch_id = :p_batch_id ' ||
                 'and int.batch_id = stage.batch_id '||
                 'and int.rowid = stage.int_row_id '||
                 'and int.dqm_action_flag IS NULL '||
                 'AND stage.action_flag = ''I'' ';

    existing_site_sql := 'select int.site_orig_system,int.site_orig_system_reference '||
                      'from hz_imp_addresses_int int, hz_imp_addresses_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'AND stage.action_flag = ''U'' ';

    pot_dup_site_sql  := 'select int.site_orig_system,int.site_orig_system_reference '||
                      'from hz_imp_addresses_int int, hz_imp_addresses_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'and int.dqm_action_flag = ''P'' '||
                      'AND stage.action_flag = ''I'' ';

    IF ( p_action_new_addrs IS NOT NULL ) THEN
         action_on_sites(new_site_sql,p_batch_id,p_action_new_addrs,NULL,NULL,x_return_status);
    END IF;

    IF ( p_action_existing_addrs IS NOT NULL ) THEN
         action_on_sites(existing_site_sql,p_batch_id,NULL,p_action_existing_addrs,NULL,x_return_status);
    END IF;

    IF ( p_action_pot_dup_addrs IS NOT NULL ) THEN
         action_on_sites(pot_dup_site_sql,p_batch_id, NULL,NULL,p_action_pot_dup_addrs,x_return_status);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END reg_action_on_sites;

/**
 * PRIVATE PROCEDURE reg_action_on_cont
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *   p_batch_id                Interface Batch ID.
 *   p_action_new_contacts      Action on new contacts.
 *                              Insert - Default
 *                              Remove - remove from Contact interface table
 *                                       and all its child entities.
 *   p_action__existing_contacts Action on existing contacts.
 *                               Update - Default
 *                               Remove - remove from parties interface table
 *                                       and all its child entities.
 *   p_action_pot_dup_contacts   Action on potential duplicates.
 *                              Request Merge - Default
 *                              Insert
 *                              Remove
 *
 *    OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-25-2003    Rajeshwari P       o Created.
 *
 */

  PROCEDURE reg_action_on_cont ( p_batch_id            IN NUMBER,
                               p_action_new_contacts       IN VARCHAR2,
                               p_action_existing_contacts  IN VARCHAR2,
                               p_action_pot_dup_contacts   IN VARCHAR2,
                               x_return_status         OUT NOCOPY VARCHAR2
                             ) IS

  new_cont_sql                  VARCHAR2(4000);
  existing_cont_sql             VARCHAR2(4000);
  pot_dup_cont_sql              VARCHAR2(4000);
  cur_sql                       VARCHAR2(4000);

  BEGIN

    -- Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Choose the action to be performed on sites

    new_cont_sql := 'select int.contact_orig_system,int.contact_orig_system_reference '||
                 'from hz_imp_contacts_int int, hz_imp_contacts_sg stage '||
                 'where int.batch_id = :p_batch_id ' ||
                 'and int.batch_id = stage.batch_id '||
                 'and int.rowid= stage.int_row_id '||
                 'and int.dqm_action_flag IS NULL '||
                 'AND stage.action_flag = ''I'' ';

    existing_cont_sql := 'select int.contact_orig_system,int.contact_orig_system_reference '||
                      'from hz_imp_contacts_int int, hz_imp_contacts_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid= stage.int_row_id '||
                      'AND stage.action_flag = ''U'' ';

     pot_dup_cont_sql  := 'select int.contact_orig_system,int.contact_orig_system_reference '||
                      'from hz_imp_contacts_int int, hz_imp_contacts_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid= stage.int_row_id '||
                      'and int.dqm_action_flag = ''P'' '||
                      'AND stage.action_flag = ''I'' ';

    IF ( p_action_new_contacts IS NOT NULL ) THEN
         action_on_contacts(new_cont_sql,p_batch_id,p_action_new_contacts,NULL,NULL,x_return_status);
    END IF;

    IF (  p_action_existing_contacts IS NOT NULL ) THEN
         action_on_contacts(existing_cont_sql,p_batch_id,NULL,p_action_existing_contacts,NULL,x_return_status);
    END IF;

    IF (  p_action_pot_dup_contacts IS NOT NULL ) THEN
         action_on_contacts(pot_dup_cont_sql,p_batch_id,NULL,NULL,p_action_pot_dup_contacts,x_return_status);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END reg_action_on_cont ;


/**
 * PRIVATE PROCEDURE reg_action_on_cont
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *   p_batch_id                Interface Batch ID.
 *   p_action_new_cpts      Action on new contacts.
 *                              Insert - Default
 *                              Remove - remove from Contact interface table
 *                                       and all its child entities.
 *   p_action__existing_cpts Action on existing contacts.
 *                               Update - Default
 *                               Remove - remove from parties interface table
 *                                       and all its child entities.
 *   p_action_pot_dup_cpts   Action on potential duplicates.
 *                              Request Merge - Default
 *                              Insert
 *                              Remove
 *
 *    OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-25-2003    Rajeshwari P       o Created.
 *
 */
PROCEDURE reg_action_on_cpts ( p_batch_id                  IN NUMBER,
                               p_action_new_cpts       IN VARCHAR2,
                               p_action_existing_cpts  IN VARCHAR2,
                               p_action_pot_dup_cpts   IN VARCHAR2,
                               x_return_status             OUT NOCOPY VARCHAR2
                             ) IS

  new_cpts_sql                  VARCHAR2(4000);
  existing_cpts_sql             VARCHAR2(4000);
  pot_dup_cpts_sql              VARCHAR2(4000);
  cur_sql                       VARCHAR2(4000);

 BEGIN

    -- Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Choose the action to be performed on sites

    new_cpts_sql := 'select int.cp_orig_system,int.cp_orig_system_reference '||
                 'from hz_imp_contactpts_int int, hz_imp_contactpts_sg stage '||
                 'where int.batch_id = :p_batch_id ' ||
                 'and int.batch_id = stage.batch_id '||
                 'and int.rowid = stage.int_row_id '||
                 'and int.dqm_action_flag IS NULL '||
                 'AND stage.action_flag = ''I'' ';

    existing_cpts_sql := 'select int.cp_orig_system,int.cp_orig_system_reference '||
                      'from hz_imp_contactpts_int int, hz_imp_contactpts_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'AND stage.action_flag = ''U'' ';

    pot_dup_cpts_sql  := 'select int.cp_orig_system,int.cp_orig_system_reference '||
                      'from hz_imp_contactpts_int int, hz_imp_contactpts_sg stage '||
                      'where int.batch_id = :p_batch_id '||
                      'and int.batch_id = stage.batch_id '||
                      'and int.rowid = stage.int_row_id '||
                      'and int.dqm_action_flag = ''P'' '||
                      'AND stage.action_flag = ''I'' ';

    IF ( p_action_new_cpts IS NOT NULL ) THEN
         action_on_contactpts(new_cpts_sql,p_batch_id,p_action_new_cpts,NULL,NULL,x_return_status);
    END IF;

    IF (  p_action_existing_cpts IS NOT NULL ) THEN
         action_on_contactpts(existing_cpts_sql,p_batch_id,NULL,p_action_existing_cpts,NULL,x_return_status);
    END IF;

    IF (  p_action_pot_dup_cpts IS NOT NULL ) THEN
         action_on_contactpts(pot_dup_cpts_sql,p_batch_id,NULL,NULL,p_action_pot_dup_cpts,x_return_status);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END reg_action_on_cpts ;

/**
 * PRIVATE PROCEDURE reg_action_on_supents
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *
 *
 *   OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-26-2003    Rajeshwari P       o Created.
 *
 */

 PROCEDURE reg_action_on_supents (x_return_status OUT NOCOPY VARCHAR2) is

TYPE sel_cur           IS REF CURSOR;
  sql_stmt             sel_cur;

  sel_use              VARCHAR2(4000);
  sel_class            VARCHAR2(4000);
  sel_roles            VARCHAR2(4000);
  sel_rel              VARCHAR2(4000);

 TYPE INT_ROWIDList IS TABLE OF VARCHAR2(1000);
      l_int_rowid      INT_ROWIDList;
 commit_counter    NUMBER;
 l_last_fetch      BOOLEAN;
 i                 NUMBER;
 j                 NUMBER;


 BEGIN

    -- Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        commit_counter := 1000;

--// Site uses
  BEGIN

    FOR j in 1..2 LOOP

    if j=0 then
      sel_use := 'SELECT int_row_id FROM HZ_IMP_ADDRESSUSES_SG WHERE action_flag = ''I'' ';
    else
      sel_use := 'SELECT int_row_id FROM HZ_IMP_ADDRESSUSES_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_use;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_ADDRESSUSES_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

 EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
 END;

--//CLASSIFICATIONS

 BEGIN

    FOR j in 1..2 LOOP

    if j=0 then
      sel_class := 'SELECT int_row_id FROM HZ_IMP_CLASSIFICS_SG WHERE action_flag = ''I'' ';
    else
      sel_class := 'SELECT int_row_id FROM HZ_IMP_CLASSIFICS_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_class;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_CLASSIFICS_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
 END;


 --//Contact Roles

 BEGIN

    FOR j in 1..2 LOOP

    if j=0 then
      sel_roles := 'SELECT int_row_id FROM HZ_IMP_CONTACTROLES_SG WHERE action_flag = ''I'' ';
    else
      sel_roles := 'SELECT int_row_id FROM HZ_IMP_CONTACTROLES_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_roles;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_CONTACTROLES_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
 END;

 --//Relationships

 BEGIN

    FOR j in 1..2  LOOP

    if j=0 then
      sel_rel := 'SELECT int_row_id FROM HZ_IMP_RELSHIPS_SG WHERE action_flag = ''I'' ';
    else
      sel_rel := 'SELECT int_row_id FROM HZ_IMP_RELSHIPS_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_roles;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_RELSHIPS_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
 END;


 END reg_action_on_supents;


/**
 * PRIVATE PROCEDURE reg_action_on_finents
 *
 * DESCRIPTION
 *     private procedure to update the interface tables with
 *     appropriate actions after DQM has performed registry
 *     de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *   ARGUMENTS
 *   IN:
 *
 *
 *   OUT:
 *     x_return_status         Return status after the call.
 *
 * MODIFICATION HISTORY
 *
 *   08-25-2003    Rajeshwari P       o Created.
 *
 */

PROCEDURE reg_action_on_finents (
                                  x_return_status OUT NOCOPY VARCHAR2
                                ) is

  TYPE sel_cur           IS REF CURSOR;
  sql_stmt             sel_cur;

  sel_finreports              VARCHAR2(4000);
  sel_finnumbers              VARCHAR2(4000);
  sel_credit                  VARCHAR2(4000);

  TYPE INT_ROWIDList IS TABLE OF VARCHAR2(1000);
       l_int_rowid      INT_ROWIDList;
  commit_counter    NUMBER;
  l_last_fetch      BOOLEAN;
  i                 NUMBER;
  j                 NUMBER;

  BEGIN

    -- Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        commit_counter := 1000;

--// Financial Reports
  BEGIN

-- Run the loop twice, once for Insert and another time for Update
    FOR j in 1..2 LOOP

    if j=1 then
      sel_finreports := 'SELECT int_row_id FROM HZ_IMP_FINREPORTS_SG WHERE action_flag = ''I'' ';
    else
      sel_finreports := 'SELECT int_row_id FROM HZ_IMP_FINREPORTS_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_finreports;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_FINREPORTS_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
 END;

--//Financial Numbers
 BEGIN

    FOR j in 1..2 LOOP

    if j=0 then
      sel_finnumbers := 'SELECT int_row_id FROM HZ_IMP_FINNUMBERS_SG WHERE action_flag = ''I'' ';
    else
      sel_finnumbers := 'SELECT int_row_id FROM HZ_IMP_FINNUMBERS_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_finnumbers;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_FINNUMBERS_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
 END;


--//Credit Ratings

 BEGIN

    FOR j in 1..2 LOOP

    if j=0 then
      sel_credit := 'SELECT int_row_id FROM HZ_IMP_CREDITRTNGS_SG WHERE action_flag = ''I'' ';
    else
      sel_credit := 'SELECT int_row_id FROM HZ_IMP_CREDITRTNGS_SG WHERE action_flag = ''U'' ';
    end if;

    OPEN sql_stmt FOR sel_credit;
    LOOP
    FETCH sql_stmt BULK COLLECT INTO
          l_int_rowid
    LIMIT commit_Counter;

    IF sql_stmt%NOTFOUND THEN
          l_last_fetch := TRUE ;
    END IF;

    IF l_int_rowid.COUNT = 0 AND l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    FORALL i in l_int_rowid.FIRST..l_int_rowid.LAST
    UPDATE HZ_IMP_CREDITRTNGS_INT
    SET interface_status = 'R'
    WHERE rowid = l_int_rowid(i) ;

    IF  l_last_fetch = TRUE THEN
        EXIT;
    END IF;

    commit;
    END LOOP;
    close sql_stmt ;

    END LOOP ;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
 END;

 END reg_action_on_finents;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------
/**
 * PROCEDURE clear_status
 *
 * DESCRIPTION
 *     Clear the interface_status and dqm_action_flag of the interface
 *     tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   p_batch_id           Interface Batch ID.
 *
 *   OUT:
 *   x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error).
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

  PROCEDURE clear_status (
      p_batch_id        IN            NUMBER,
      x_return_status   OUT NOCOPY    VARCHAR2
                         ) IS
  Cursor select_party_rec(p_batch_id IN NUMBER ,p_entity IN VARCHAR2 ) is
	select dup_record_os,dup_record_osr
	FROM HZ_IMP_INT_DEDUP_RESULTS
	WHERE batch_id = p_batch_id
	AND ENTITY = p_entity
	UNION
	SELECT party_osr,party_os
	FROM HZ_IMP_DUP_PARTIES
	WHERE batch_id= p_batch_id
          ;

   Cursor select_detail_rec(p_batch_id IN NUMBER ,p_entity IN VARCHAR2 ) is
	select dup_record_os,dup_record_osr
	FROM HZ_IMP_INT_DEDUP_RESULTS
	WHERE batch_id = p_batch_id
	AND ENTITY = p_entity
	UNION
	SELECT record_os,record_osr
	FROM HZ_IMP_DUP_DETAILS
	WHERE batch_id= p_batch_id
	AND entity= p_entity
         ;

    TYPE L_DUP_OSPartyList  is TABLE OF HZ_IMP_PARTIES_INT.party_orig_system%TYPE;
         l_dup_os_party    L_DUP_OSPartyList;
    TYPE L_DUP_OSRPartyList   is TABLE OF HZ_IMP_PARTIES_INT.party_orig_system_reference%TYPE;
         l_dup_osr_party L_DUP_OSRPartyList ;
    TYPE L_DUP_OSSitesList is TABLE OF HZ_IMP_ADDRESSES_INT.site_orig_system%TYPE;
         l_dup_os_sites    L_DUP_OSSitesList;
    TYPE L_DUP_OSRSitesList is TABLE OF HZ_IMP_ADDRESSES_INT.site_orig_system_reference%TYPE;
         l_dup_osr_sites   L_DUP_OSRSitesList;
    TYPE L_DUP_OSContList is TABLE OF HZ_IMP_CONTACTS_INT.contact_orig_system%TYPE;
         l_dup_os_cont     L_DUP_OSContList;
    TYPE L_DUP_OSRContList is TABLE OF HZ_IMP_CONTACTS_INT.contact_orig_system_reference%TYPE;
         l_dup_osr_cont    L_DUP_OSRContList;
    TYPE L_DUP_OSCptsList is TABLE OF HZ_IMP_CONTACTPTS_INT.cp_orig_system%TYPE;
         l_dup_os_cp     L_DUP_OSCptsList;
    TYPE L_DUP_OSRCptsList is TABLE OF HZ_IMP_CONTACTPTS_INT.cp_orig_system_reference%TYPE;
         l_dup_osr_cp    L_DUP_OSRCptsList;

    l_last_fetch                BOOLEAN;
    commit_counter              NUMBER;
    l_debug_prefix		VARCHAR2(30) := '';
 BEGIN

     commit_counter := 1000;

  ---Check if API is called in debug mode. If yes, enable debug.
     --enable_debug;

  -- Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.debug(p_message=>'clear status of interface tables (+) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

   -- Initialize API return status to success.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- For entity= Party
      Begin
        Open select_party_rec( p_batch_id , 'PARTY' ) ;
        LOOP

        Fetch select_party_rec BULK COLLECT into
              l_dup_os_party,l_dup_osr_party
        LIMIT commit_counter;

        IF select_party_rec%NOTFOUND THEN
           l_last_fetch := TRUE;
        END IF;

        IF l_dup_osr_party.COUNT = 0 AND l_last_fetch THEN
             EXIT;
        END IF;


        FORALL i in l_dup_osr_party.FIRST..l_dup_osr_party.LAST
         UPDATE HZ_IMP_PARTIES_INT
         SET interface_status = NULL,dqm_action_flag = NULL
         WHERE batch_id = p_batch_id
         AND party_orig_system = l_dup_os_party(i)
         AND party_orig_system_reference = l_dup_osr_party(i)
         AND ( interface_status = 'R' OR dqm_action_flag is not NULL );

--Classifications
        FORALL i in l_dup_osr_party.FIRST..l_dup_osr_party.LAST
         UPDATE HZ_IMP_CLASSIFICS_INT
         SET interface_status = NULL
         WHERE batch_id = p_batch_id
         AND party_orig_system = l_dup_os_party(i)
         AND party_orig_system_reference = l_dup_osr_party(i)
         AND interface_status = 'R' ;

--Credit Ratings
         FORALL i in l_dup_osr_party.FIRST..l_dup_osr_party.LAST
         UPDATE HZ_IMP_CREDITRTNGS_INT
         SET interface_status = NULL
         WHERE batch_id = p_batch_id
         AND party_orig_system = l_dup_os_party(i)
         AND party_orig_system_reference = l_dup_osr_party(i)
         AND interface_status = 'R' ;

--Financial Numbers
         FORALL i in l_dup_osr_party.FIRST..l_dup_osr_party.LAST
         UPDATE HZ_IMP_FINNUMBERS_INT
         SET interface_status = NULL
         WHERE batch_id = p_batch_id
         AND party_orig_system = l_dup_os_party(i)
         AND party_orig_system_reference = l_dup_osr_party(i)
         AND interface_status = 'R' ;

--Financial Reports
         FORALL i in l_dup_osr_party.FIRST..l_dup_osr_party.LAST
         UPDATE HZ_IMP_FINREPORTS_INT
         SET interface_status = NULL
         WHERE batch_id = p_batch_id
         AND party_orig_system = l_dup_os_party(i)
         AND party_orig_system_reference = l_dup_osr_party(i)
         AND interface_status = 'R' ;

         IF  l_last_fetch = TRUE THEN
          EXIT;
         END IF;

         commit;
        END LOOP;
        close select_party_rec;

       END;

--For entity= PARTY_SITES
       BEGIN
         l_last_fetch := FALSE;

          Open select_detail_rec ( p_batch_id ,'PARTY_SITES' );
          LOOP

          FETCH select_detail_rec BULK COLLECT INTO
                l_dup_os_sites,l_dup_osr_sites
          LIMIT commit_counter;

          IF select_detail_rec%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF l_dup_osr_sites.COUNT = 0 AND l_last_fetch THEN
             EXIT;
          END IF;

          FORALL i in l_dup_osr_sites.FIRST..l_dup_osr_sites.LAST
          UPDATE HZ_IMP_ADDRESSES_INT
          SET interface_status = NULL,dqm_action_flag = NULL
          WHERE batch_id = p_batch_id
          AND site_orig_system = l_dup_os_sites(i)
          AND site_orig_system_reference = l_dup_osr_sites(i)
          AND ( interface_status = 'R' OR dqm_action_flag is not NULL );

--Party site Uses

          FORALL i in l_dup_osr_sites.FIRST..l_dup_osr_sites.LAST
          UPDATE HZ_IMP_ADDRESSUSES_INT
          SET interface_status = NULL
          WHERE batch_id = p_batch_id
          AND site_orig_system = l_dup_os_sites(i)
          AND site_orig_system_reference = l_dup_osr_sites(i)
          AND interface_status = 'R' ;

          IF  l_last_fetch = TRUE THEN
              EXIT;
          END IF;

          commit;
          END LOOP;
          close select_detail_rec;

        END;

--For entity=Contacts
        BEGIN
          l_last_fetch := FALSE;

          Open select_detail_rec ( p_batch_id ,'CONTACTS' );
          LOOP

          FETCH select_detail_rec BULK COLLECT INTO
                l_dup_os_cont,l_dup_osr_cont
          LIMIT commit_counter;

          IF select_detail_rec%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF l_dup_osr_cont.COUNT = 0 AND l_last_fetch THEN
             EXIT;
          END IF;

          FORALL i in l_dup_osr_cont.FIRST..l_dup_osr_cont.LAST
          UPDATE HZ_IMP_CONTACTS_INT
          SET interface_status = NULL,dqm_action_flag = NULL
          WHERE batch_id = p_batch_id
          AND contact_orig_system = l_dup_os_cont(i)
          AND contact_orig_system_reference = l_dup_osr_cont(i)
          AND ( interface_status = 'R' OR dqm_action_flag is not NULL );

--Contact Roles
          FORALL i in l_dup_osr_cont.FIRST..l_dup_osr_cont.LAST
          UPDATE HZ_IMP_CONTACTROLES_INT
          SET interface_status = NULL
          WHERE batch_id = p_batch_id
          AND contact_orig_system = l_dup_os_cont(i)
          AND contact_orig_system_reference = l_dup_osr_cont(i)
          AND interface_status = 'R' ;

          IF  l_last_fetch = TRUE THEN
              EXIT;
          END IF;

          commit;
          END LOOP;
          close select_detail_rec;

        END;

--For entity=Contact points

        BEGIN
          l_last_fetch := FALSE;

          Open select_detail_rec ( p_batch_id ,'CONTACT_POINTS' );
          LOOP

          FETCH select_detail_rec BULK COLLECT INTO
                l_dup_os_cp,l_dup_osr_cp
          LIMIT commit_counter;

          IF select_detail_rec%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF l_dup_osr_cp.COUNT = 0 AND l_last_fetch THEN
             EXIT;
          END IF;

          FORALL i in l_dup_osr_cp.FIRST..l_dup_osr_cp.LAST
          UPDATE HZ_IMP_CONTACTPTS_INT
          SET interface_status = NULL,dqm_action_flag = NULL
          WHERE batch_id = p_batch_id
          AND cp_orig_system = l_dup_os_cp(i)
          AND cp_orig_system_reference = l_dup_osr_cp(i)
          AND ( interface_status = 'R' OR dqm_action_flag is not NULL );

          IF  l_last_fetch = TRUE THEN
              EXIT;
          END IF;

          commit;
          END LOOP;
          close select_detail_rec;

        END;

EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;

END clear_status;

/**
 *PROCEDURE batch_dedup_action
 *
 * DESCRIPTION
 *     Mark the interface_status in the interface tables
 *     with 'R' to indicate which records should be removed from
 *     processing by Data Load program.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   p_batch_id                 Batch ID from batch summary table.
 *   p_action_on_parties        Action to be taken on duplicate party records
 *                              in the interface tables.
 *   p_action_on_addresses      Action to be taken on duplicate site records
 *                              in the interface tables.
 *   p_action_on_contacts       Action to be taken on duplicate contact records
 *                              in the interface tables.
 *   p_action_on_contact_points Action to be taken on duplicate contact point
 *                              records in the interface tables.
 *
 *   OUT:
 *   x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error),
 *                        FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   x_msg_count          Number of messages in message stack.
 *   x_msg_data           Message text if x_msg_count is 1..
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

PROCEDURE batch_dedup_action (
    p_batch_id                  IN         NUMBER,
    p_action_on_parties         IN         VARCHAR2,
    p_action_on_addresses       IN         VARCHAR2,
    p_action_on_contacts        IN         VARCHAR2,
    p_action_on_contact_points  IN         VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
      ) IS

    /*Cursor action( p_batch_id IN NUMBER ) IS
       SELECT  BD_ACTION_ON_PARTIES,BD_ACTION_ON_ADDRESSES,
               BD_ACTION_ON_CONTACTS,BD_ACTION_ON_CONTACT_POINTS
       FROM hz_imp_batch_summary
       WHERE batch_id = p_batch_id;

         l_action_on_parties  hz_imp_batch_summary.BD_ACTION_ON_PARTIES%TYPE;
         l_action_on_addresses   hz_imp_batch_summary.BD_ACTION_ON_ADDRESSES%TYPE;
         l_action_on_contacts  hz_imp_batch_summary.BD_ACTION_ON_CONTACTS%TYPE;
         l_action_on_cont_points hz_imp_batch_summary.BD_ACTION_ON_CONTACT_POINTS%TYPE;
     */
	 l_debug_prefix		VARCHAR2(30) := '';


BEGIN


  ---Check if API is called in debug mode. If yes, enable debug.
     --enable_debug;
  -- Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.debug(p_message=>'update the interface tables after batch deduplication (+) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
       END IF;

   -- Initialize API return status to success.
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --3585887 Commented the code to fetch the previous actions.
      /*OPEN action( p_batch_id );
      FETCH action INTO
            l_action_on_parties,l_action_on_addresses,
            l_action_on_contacts,l_action_on_cont_points ;
      CLOSE action;*/


         action_on_entities ( p_batch_id , 'PARTY' , p_action_on_parties );

  -- Update hz_imp_batch_summary table
        UPDATE   HZ_IMP_BATCH_SUMMARY
        SET BD_ACTION_ON_PARTIES = p_action_on_parties
        WHERE batch_id = p_batch_id;




         action_on_entities ( p_batch_id , 'PARTY_SITES', p_action_on_addresses ) ;

  --Update hz_imp_batch_summary table
         UPDATE   HZ_IMP_BATCH_SUMMARY
         SET BD_ACTION_ON_ADDRESSES = p_action_on_addresses
         WHERE batch_id = p_batch_id;




         action_on_entities ( p_batch_id , 'CONTACTS',p_action_on_contacts );

   --Update hz_imp_batch_summary table
         UPDATE   HZ_IMP_BATCH_SUMMARY
         SET BD_ACTION_ON_CONTACTS = p_action_on_contacts
         WHERE batch_id = p_batch_id;




         action_on_entities ( p_batch_id , 'CONTACT_POINTS' , p_action_on_contact_points);

   --Update hz_imp_batch_summary table
         UPDATE   HZ_IMP_BATCH_SUMMARY
         SET BD_ACTION_ON_CONTACT_POINTS = p_action_on_contact_points
         WHERE batch_id = p_batch_id;



EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;

END batch_dedup_action;

/**
 *PROCEDURE registry_dedup_action
 *
 * DESCRIPTION
 *     This API will be called to reflect the user defined
 *     options into the interface tables after DQM has performed
 *     registry de-duplication.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *    p_batch_id                  Interface Batch ID
 *    p_action_new_parties        New Parties,
 *    p_action_existing_parties   Existing parties,
 *    p_action_dup_parties        Dup parties,
 *    p_action_pot_dup_parties    Potential duplicate parties,
 *    p_action_new_addrs          New Address,
 *    p_action_existing_addrs     Existing Address,
 *    p_action_pot_dup_addrs      Potential Duplicate address,
 *    p_action_new_contacts       New Contacts,
 *    p_action_existing_contacts  Existing Contacts,
 *    p_action_pot_dup_contacts   Potential duplicate Contacts,
 *    p_action_new_cpts           New Contact Points,
 *    p_action_existing_cpts      Existing Contact Points,
 *    p_action_pot_dup_cpts       Potential Duplicate Contact Points,
 *    p_action_new_supents        New Supents,
 *    p_action_existing_supents   Existing Supents,
 *    p_action_new_finents        New Finents,
 *    p_action_existing_finents   Existing Finents,
 *
 *   OUT:
 *    x_return_status      Return status after the call. The status can
 *                        be FND_API.G_RET_STS_SUCCESS (success),
 *                        FND_API.G_RET_STS_ERROR (error),
 *                        FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   x_msg_count          Number of messages in message stack.
 *   x_msg_data           Message text if x_msg_count is 1..
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-17-2003    Rajeshwari P      o Created.
 *
 */

PROCEDURE registry_dedup_action (
     p_batch_id                  IN         NUMBER,
     p_action_new_parties        IN         VARCHAR2,
     p_action_existing_parties   IN         VARCHAR2,
     p_action_dup_parties        IN         VARCHAR2,
     p_action_pot_dup_parties    IN         VARCHAR2,
     p_action_new_addrs          IN         VARCHAR2,
     p_action_existing_addrs     IN         VARCHAR2,
     p_action_pot_dup_addrs      IN         VARCHAR2,
     p_action_new_contacts       IN         VARCHAR2,
     p_action_existing_contacts  IN         VARCHAR2,
     p_action_pot_dup_contacts   IN         VARCHAR2,
     p_action_new_cpts           IN         VARCHAR2,
     p_action_existing_cpts      IN         VARCHAR2,
     p_action_pot_dup_cpts       IN         VARCHAR2,
     p_action_new_supents        IN         VARCHAR2,
     p_action_existing_supents   IN         VARCHAR2,
     p_action_new_finents        IN         VARCHAR2,
     p_action_existing_finents   IN         VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
 l_debug_prefix		VARCHAR2(30) := '';

BEGIN

   --Check if API is called in debug mode. If yes, enable debug.
     --enable_debug;

   --Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug(p_message=>'update the interface tables after batch deduplication (+) ',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
       END IF;

   -- Initialize API return status to success.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Choose the action to be performed on parties after registry de-duplication
   -- is done by DQM.

      reg_action_on_party ( p_batch_id,
                            p_action_new_parties,
                            p_action_existing_parties,
                            p_action_dup_parties,
                            p_action_pot_dup_parties,
                            x_return_status
                           );

--///Action to be performed on Sites

      reg_action_on_sites ( p_batch_id              ,
                            p_action_new_addrs       ,
                            p_action_existing_addrs  ,
                            p_action_pot_dup_addrs   ,
                            x_return_status
                             );

--//Action to be performed on Contacts

      reg_action_on_cont ( p_batch_id                  ,
                           p_action_new_contacts       ,
                           p_action_existing_contacts  ,
                           p_action_pot_dup_contacts  ,
                           x_return_status
                             ) ;

--//Action to be performed on Contact points

      reg_action_on_cpts ( p_batch_id                  ,
                           p_action_new_cpts           ,
                           p_action_existing_cpts      ,
                           p_action_pot_dup_cpts      ,
                           x_return_status
                             );

--//Action to be performed on Site Uses, Classification, Contact Roles and Relationships

      reg_action_on_supents (x_return_status ) ;

--//Action to be performed on Financial Reports, Financial numbers and Credit ratings

      reg_action_on_finents (x_return_status ) ;


EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

END registry_dedup_action;

/**
 *FUNCTION GET_DEDUP_BATCH_STATUS
 *
 * DESCRIPTION
 *     This API will be called to get the
 *     status (Import/Remove) of records in
 *     dedup results based on the action
 *     in batch summary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *    p_batch_id              Interface Batch ID
 *    p_entity                Entity Name in Dedup Results,
 *    p_action_on_entity      Action on entity in Batch Summary,
 *    p_winner_record_os      Winner record Orig System in Dedup Results
 *    p_winner_record_osr     Winner record Orig System Reference in Dedup Results
 *    p_dup_record_os         Dup record Orig System in Dedup Results
 *    p_dup_record_osr        Dup record Orig System Reference in Dedup Results
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-30-2003    Ramesh Ch      o Created.
 *
 */

FUNCTION GET_DEDUP_BATCH_STATUS(p_batch_id                  IN         NUMBER,
				p_entity                    IN         VARCHAR2,
				p_action_on_entity          IN         VARCHAR2,
				p_winner_record_os          IN         VARCHAR2,
        			p_winner_record_osr         IN         VARCHAR2,
   				p_dup_record_os             IN         VARCHAR2,
				p_dup_record_osr            IN         VARCHAR2
				)
RETURN VARCHAR2
IS
--//Choose the latest updated record
CURSOR max_last_date  IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_last_update_date,sysdate) = (  SELECT MAX( nvl(DUP_LAST_UPDATE_DATE,sysdate))
					     FROM  HZ_IMP_INT_DEDUP_RESULTS
					     WHERE   batch_id =p_batch_id
					     and entity = p_entity
					     AND winner_record_os = p_winner_record_os
					     AND winner_record_osr = p_winner_record_osr)
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;

--//Choose the latest created record
CURSOR max_created_date IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_creation_date,sysdate) = (  SELECT MAX( nvl(DUP_CREATION_DATE,sysdate))
					  FROM  HZ_IMP_INT_DEDUP_RESULTS
					  WHERE   batch_id =p_batch_id
					  AND entity = p_entity
					  AND winner_record_os = p_winner_record_os
					  AND winner_record_osr = p_winner_record_osr)
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;

--//Choose the earliest created record
CURSOR min_created_date IS
 SELECT DUP_RECORD_OS, DUP_RECORD_OSR
 FROM   HZ_IMP_INT_DEDUP_RESULTS
 WHERE  batch_id  = p_batch_id
 AND  entity  =  p_entity
 AND  nvl(dup_creation_date,sysdate) = (  SELECT MIN( nvl(DUP_CREATION_DATE,sysdate))
   				          FROM  HZ_IMP_INT_DEDUP_RESULTS
					  WHERE   batch_id =p_batch_id
					  AND entity = p_entity
					  AND winner_record_os = p_winner_record_os
					  AND winner_record_osr = p_winner_record_osr)
AND winner_record_os = p_winner_record_os
AND winner_record_osr = p_winner_record_osr
AND rownum =1;

--//Get the Status for the action
CURSOR c_status(p_lkp_code VARCHAR2) IS
SELECT MEANING FROM FND_LOOKUP_VALUES lkp
WHERE  lkp.lookup_code=p_lkp_code
AND    lkp.lookup_type='HZ_IMP_BATCH_DEDUP_STATUS'
AND    lkp.language  = userenv('LANG')
AND    lkp.view_application_id  = 222
AND    lkp.security_group_id  =fnd_global.lookup_security_group('HZ_IMP_BATCH_DEDUP_STATUS', 222)
AND    rownum=1;

--local variables
l_lkp_code              VARCHAR2(30):=NULL;
l_status		VARCHAR2(80):=NULL;
l_dup_record_osr	VARCHAR2(255):=NULL;
l_dup_record_os         VARCHAR2(30):=NULL;

BEGIN

IF p_action_on_entity='KEEP_LATEST_UPDATED' THEN
   OPEN  max_last_date;
   FETCH max_last_date INTO l_dup_record_os,l_dup_record_osr;
   CLOSE max_last_date;
ELSIF p_action_on_entity='KEEP_LATEST_CREATED' THEN
   OPEN  max_created_date;
   FETCH max_created_date INTO l_dup_record_os,l_dup_record_osr;
   CLOSE max_created_date;
ELSIF p_action_on_entity='KEEP_EARLIEST_CREATED' THEN
   OPEN  min_created_date;
   FETCH min_created_date INTO l_dup_record_os,l_dup_record_osr;
   CLOSE min_created_date;
END IF;
IF p_action_on_entity='REMOVE_ALL' THEN
   l_lkp_code:='REMOVE';
ELSIF p_action_on_entity='KEEP_ALL' THEN
      l_lkp_code:='IMPORT';
ELSE
 IF(l_dup_record_os=p_dup_record_os AND l_dup_record_osr=p_dup_record_osr) THEN
      l_lkp_code:='IMPORT';
 ELSE
      l_lkp_code:='REMOVE';
 END IF;
END IF;
OPEN c_status(l_lkp_code);
FETCH c_status INTO l_status;
CLOSE c_status;
RETURN l_status;
EXCEPTION WHEN OTHERS THEN
RETURN NULL;
END GET_DEDUP_BATCH_STATUS;

PROCEDURE action_on_parties(p_sql IN VARCHAR2,
                            p_batch_id IN NUMBER,
                            p_action_new_parties       IN VARCHAR2,
                            p_action_existing_parties  IN VARCHAR2,
                            p_action_dup_parties IN VARCHAR2,
                            p_action_pot_dup_parties IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
sel_parties        sel_cur;

 TYPE L_PARTY_ORIG_SYSList IS TABLE OF HZ_IMP_PARTIES_INT.PARTY_ORIG_SYSTEM%TYPE;
     l_party_orig_os        L_PARTY_ORIG_SYSList;
 TYPE L_PARTY_ORIG_SYS_REFList IS TABLE OF HZ_IMP_PARTIES_INT.PARTY_ORIG_SYSTEM_REFERENCE%TYPE;
     l_party_orig_osr       L_PARTY_ORIG_SYS_REFList;
 TYPE L_PARTY_IDList  IS TABLE OF HZ_IMP_PARTIES_INT.PARTY_ID%TYPE;
     l_party_id             L_PARTY_IDList;

 TYPE L_SITE_ORIG_SYSList IS TABLE OF HZ_IMP_ADDRESSES_INT.SITE_ORIG_SYSTEM%TYPE;
       l_site_orig_os        L_SITE_ORIG_SYSList;
 TYPE L_SITE_ORIG_SYS_REFList IS TABLE OF HZ_IMP_ADDRESSES_INT.SITE_ORIG_SYSTEM_REFERENCE%TYPE;
       l_site_orig_osr       L_SITE_ORIG_SYS_REFList;
 TYPE L_CONT_ORIG_SYSList IS TABLE OF HZ_IMP_CONTACTS_INT.CONTACT_ORIG_SYSTEM%TYPE;
     l_cont_orig_os        L_CONT_ORIG_SYSList;
 TYPE L_CONT_ORIG_SYS_REFList IS TABLE OF HZ_IMP_CONTACTS_INT.CONTACT_ORIG_SYSTEM_REFERENCE%TYPE;
     l_cont_orig_osr       L_CONT_ORIG_SYS_REFList;

 commit_counter    NUMBER;
 l_last_fetch      BOOLEAN;
 i                 NUMBER;

BEGIN
     commit_counter := 1000;
    OPEN sel_parties FOR p_sql USING p_batch_id;
       LOOP
       FETCH sel_parties BULK COLLECT INTO
             l_party_id, l_party_orig_os, l_party_orig_osr
       LIMIT commit_counter;

       IF sel_parties%NOTFOUND THEN
          l_last_fetch := TRUE ;
       END IF;

       IF l_party_orig_osr.COUNT = 0 AND l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       IF (p_action_new_parties||p_action_existing_parties||
         p_action_dup_parties||p_action_pot_dup_parties
         ='REMOVE')
       THEN
       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST

--//Update parties interface table
       UPDATE HZ_IMP_PARTIES_INT party
       SET INTERFACE_STATUS = 'R', dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND ((party_id IS NULL and l_party_id(i) IS NULL)
             OR (party_id IS NOT NULL and l_party_id(i) IS NOT NULL and party_id=l_party_id(i)))
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

       --Child entities for Party
-- Classifications

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_CLASSIFICS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

       --Credit Ratings

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_CREDITRTNGS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

--Financial Numbers

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_FINNUMBERS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

--Financial Reports

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_FINREPORTS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

       IF (p_action_dup_parties <> NULL and
          (p_action_dup_parties = 'REMOVE' or p_action_dup_parties = 'INSERT' ) )
                  or
          (p_action_pot_dup_parties <> NULL and
          (p_action_pot_dup_parties = 'REMOVE' or p_action_pot_dup_parties = 'INSERT' ) )
       THEN

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_DUP_PARTIES
       SET auto_merge_flag = 'R'
       WHERE batch_id = p_batch_id
       AND party_id = l_party_id(i)
       AND party_os = l_party_orig_os(i)
       AND party_osr = l_party_orig_osr(i) ;

       END IF;

-- Addresses

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_ADDRESSES_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i)
       RETURNING site_orig_system,site_orig_system_Reference BULK COLLECT into l_site_orig_os,l_site_orig_osr;

-- Child entitites for Addresses
       FORALL i in l_site_orig_osr.FIRST..l_site_orig_osr.LAST
       UPDATE HZ_IMP_ADDRESSUSES_INT
       SET INTERFACE_STATUS = 'R'
       WHERE batch_id = p_batch_id
       AND site_orig_system = l_site_orig_os(i)
       AND site_orig_system_reference = l_site_orig_osr(i) ;

-- Contact points

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTPTS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

-- Relationships

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_RELSHIPS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND (sub_orig_system = l_party_orig_os(i)
       AND sub_orig_system_reference = l_party_orig_osr(i))
       OR
       (obj_orig_system = l_party_orig_os(i)
       AND obj_orig_system_reference = l_party_orig_osr(i));


-- Contacts
       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTS_INT
       SET interface_status = 'R'
       WHERE batch_id = p_batch_id
       AND (sub_orig_system = l_party_orig_os(i)
       AND sub_orig_system_reference = l_party_orig_osr(i))
       OR
       (obj_orig_system = l_party_orig_os(i)
       AND obj_orig_system_reference = l_party_orig_osr(i))
       RETURNING contact_orig_system,contact_orig_system_reference BULK COLLECT into l_cont_orig_os,l_cont_orig_osr;

--Child entities for Contact
       FORALL i in l_cont_orig_osr.FIRST..l_cont_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTROLES_INT
       SET INTERFACE_STATUS = 'R'
       WHERE batch_id = p_batch_id
       AND contact_orig_system = l_cont_orig_os(i)
       AND contact_orig_system_reference = l_cont_orig_osr(i) ;


       END IF;

       IF ( (p_action_dup_parties <> NULL and p_action_dup_parties = 'INSERT' )
                        OR
            (p_action_pot_dup_parties <> NULL and p_action_pot_dup_parties = 'INSERT' )
          )
       THEN

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_PARTIES_INT
       SET dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND party_id = l_party_id(i)
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;

       ELSIF (p_action_dup_parties <> NULL and p_action_dup_parties = 'REQUEST_MERGE' )
       THEN

       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_PARTIES_INT
       SET dqm_action_flag = 'P'
       WHERE batch_id = p_batch_id
       AND party_id = l_party_id(i)
       AND party_orig_system = l_party_orig_os(i)
       AND party_orig_system_reference = l_party_orig_osr(i) ;


       FORALL i in l_party_orig_osr.FIRST..l_party_orig_osr.LAST
       UPDATE HZ_IMP_DUP_PARTIES
       SET auto_merge_flag = 'N'
       WHERE batch_id = p_batch_id
       AND party_id = l_party_id(i)
       AND party_os = l_party_orig_os(i)
       AND party_osr = l_party_orig_osr(i) ;

       END IF;

       IF l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       COMMIT;

       END LOOP;
       CLOSE sel_parties;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END action_on_parties;

PROCEDURE action_on_sites(p_sql IN VARCHAR2,
                          p_batch_id IN NUMBER,
			  p_action_new_addrs       IN VARCHAR2,
                          p_action_existing_addrs  IN VARCHAR2,
                          p_action_pot_dup_addrs   IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)
IS
  sel_addrs        sel_cur;

  TYPE L_SITE_ORIG_SYSList IS TABLE OF HZ_IMP_ADDRESSES_INT.SITE_ORIG_SYSTEM%TYPE;
       l_site_orig_os        L_SITE_ORIG_SYSList;
  TYPE L_SITE_ORIG_SYS_REFList IS TABLE OF HZ_IMP_ADDRESSES_INT.SITE_ORIG_SYSTEM_REFERENCE%TYPE;
       l_site_orig_osr       L_SITE_ORIG_SYS_REFList;

  commit_counter    NUMBER;
  l_last_fetch      BOOLEAN;
  i                 NUMBER;

 BEGIN
     commit_counter := 1000;

       OPEN sel_addrs FOR p_sql USING p_batch_id;
       LOOP
       FETCH sel_addrs BULK COLLECT INTO
             l_site_orig_os, l_site_orig_osr
       LIMIT commit_counter;

       IF sel_addrs%NOTFOUND THEN
          l_last_fetch := TRUE ;
       END IF;

       IF l_site_orig_osr.COUNT = 0 AND l_last_fetch = TRUE THEN
          EXIT;
       END IF;

      IF (p_action_new_addrs||p_action_existing_addrs||p_action_pot_dup_addrs='REMOVE')
      THEN
       FORALL i in l_site_orig_osr.FIRST..l_site_orig_osr.LAST
--//Update addresses interface table
       UPDATE HZ_IMP_ADDRESSES_INT
       SET INTERFACE_STATUS = 'R', dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND site_orig_system = l_site_orig_os(i)
       AND site_orig_system_reference = l_site_orig_osr(i) ;

--Child entities for Party
       FORALL i in l_site_orig_osr.FIRST..l_site_orig_osr.LAST
       UPDATE HZ_IMP_ADDRESSUSES_INT
       SET INTERFACE_STATUS = 'R'
       WHERE batch_id = p_batch_id
       AND site_orig_system = l_site_orig_os(i)
       AND site_orig_system_reference = l_site_orig_osr(i) ;
       END IF;

       IF (p_action_pot_dup_addrs <> NULL and
          (p_action_pot_dup_addrs = 'REMOVE' or p_action_pot_dup_addrs = 'INSERT' ) )
       THEN

       FORALL i in l_site_orig_osr.FIRST..l_site_orig_osr.LAST
       DELETE FROM HZ_IMP_DUP_DETAILS
       WHERE batch_id = p_batch_id
       AND record_os = l_site_orig_os(i)
       AND record_osr = l_site_orig_osr(i) ;

       END IF;

       IF (p_action_pot_dup_addrs <> NULL and p_action_pot_dup_addrs = 'INSERT' )
       THEN

       FORALL i in l_site_orig_osr.FIRST..l_site_orig_osr.LAST
       UPDATE HZ_IMP_ADDRESSES_INT
       SET dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND site_orig_system = l_site_orig_os(i)
       AND site_orig_system_reference = l_site_orig_osr(i) ;

       END IF;

       IF l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       COMMIT;

       END LOOP;
       CLOSE sel_addrs;


EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END action_on_sites;

PROCEDURE action_on_contacts(p_sql IN VARCHAR2,
                          p_batch_id IN NUMBER,
			  p_action_new_contacts       IN VARCHAR2,
                          p_action_existing_contacts  IN VARCHAR2,
                          p_action_pot_dup_contacts   IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)
IS
  sel_cont              sel_cur;

  TYPE L_CONT_ORIG_SYSList IS TABLE OF HZ_IMP_CONTACTS_INT.CONTACT_ORIG_SYSTEM%TYPE;
     l_cont_orig_os        L_CONT_ORIG_SYSList;
  TYPE L_CONT_ORIG_SYS_REFList IS TABLE OF HZ_IMP_CONTACTS_INT.CONTACT_ORIG_SYSTEM_REFERENCE%TYPE;
     l_cont_orig_osr       L_CONT_ORIG_SYS_REFList;

  commit_counter    NUMBER;
  l_last_fetch      BOOLEAN;
  i                 NUMBER;

  BEGIN
     commit_counter := 1000;

       OPEN sel_cont FOR p_sql USING p_batch_id;
       LOOP
       FETCH sel_cont BULK COLLECT INTO
             l_cont_orig_os, l_cont_orig_osr
       LIMIT commit_counter;

       IF sel_cont%NOTFOUND THEN
          l_last_fetch := TRUE ;
       END IF;

       IF l_cont_orig_osr.COUNT = 0 AND l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       IF (p_action_new_contacts||p_action_existing_contacts||p_action_pot_dup_contacts='REMOVE')
       THEN
       FORALL i in l_cont_orig_osr.FIRST..l_cont_orig_osr.LAST
--//Update contact interface table
       UPDATE HZ_IMP_CONTACTS_INT
       SET INTERFACE_STATUS = 'R', dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND contact_orig_system = l_cont_orig_os(i)
       AND contact_orig_system_reference = l_cont_orig_osr(i) ;

--Child entities for Contact
       FORALL i in l_cont_orig_osr.FIRST..l_cont_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTROLES_INT
       SET INTERFACE_STATUS = 'R'
       WHERE batch_id = p_batch_id
       AND contact_orig_system = l_cont_orig_os(i)
       AND contact_orig_system_reference = l_cont_orig_osr(i) ;
       END IF;

       IF (p_action_pot_dup_contacts <> NULL and
          (p_action_pot_dup_contacts = 'REMOVE' or p_action_pot_dup_contacts = 'INSERT' ) )
       THEN

       FORALL i in l_cont_orig_osr.FIRST..l_cont_orig_osr.LAST
       DELETE FROM HZ_IMP_DUP_DETAILS
       WHERE batch_id = p_batch_id
       AND record_os = l_cont_orig_os(i)
       AND record_osr = l_cont_orig_osr(i) ;

       END IF;

       IF (p_action_pot_dup_contacts <> NULL and p_action_pot_dup_contacts = 'INSERT' )
       THEN

       FORALL i in l_cont_orig_osr.FIRST..l_cont_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTS_INT
       SET dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND contact_orig_system = l_cont_orig_os(i)
       AND contact_orig_system_reference = l_cont_orig_osr(i) ;

       END IF;

       IF l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       COMMIT;

       END LOOP;
       CLOSE sel_cont;


EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END action_on_contacts;

PROCEDURE action_on_contactpts(p_sql IN VARCHAR2,
                          p_batch_id IN NUMBER,
			  p_action_new_cpts       IN VARCHAR2,
                          p_action_existing_cpts  IN VARCHAR2,
                          p_action_pot_dup_cpts   IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)
IS
  sel_cpts             sel_cur;

  TYPE L_CPTS_ORIG_SYSList IS TABLE OF HZ_IMP_CONTACTPTS_INT.CP_ORIG_SYSTEM%TYPE;
     l_cpts_orig_os        L_CPTS_ORIG_SYSList;
  TYPE L_CPTS_ORIG_SYS_REFList IS TABLE OF HZ_IMP_CONTACTPTS_INT.CP_ORIG_SYSTEM_REFERENCE%TYPE;
     l_cpts_orig_osr       L_CPTS_ORIG_SYS_REFList;

  commit_counter    NUMBER;
  l_last_fetch      BOOLEAN;
  i                 NUMBER;

 BEGIN
       commit_counter := 1000;

       OPEN sel_cpts FOR p_sql USING p_batch_id;
       LOOP
       FETCH sel_cpts BULK COLLECT INTO
             l_cpts_orig_os, l_cpts_orig_osr
       LIMIT commit_counter;

       IF sel_cpts%NOTFOUND THEN
          l_last_fetch := TRUE ;
       END IF;

       IF l_cpts_orig_osr.COUNT = 0 AND l_last_fetch THEN
             EXIT;
        END IF;

       IF (p_action_new_cpts||p_action_existing_cpts||p_action_pot_dup_cpts='REMOVE')
       THEN
       FORALL i in l_cpts_orig_osr.FIRST..l_cpts_orig_osr.LAST
--//Update contact points interface table
       UPDATE HZ_IMP_CONTACTPTS_INT
       SET INTERFACE_STATUS = 'R', dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND cp_orig_system = l_cpts_orig_os(i)
       AND cp_orig_system_reference = l_cpts_orig_osr(i) ;
       END IF;

       IF (p_action_pot_dup_cpts <> NULL and
          (p_action_pot_dup_cpts = 'REMOVE' or p_action_pot_dup_cpts = 'INSERT' ) )
       THEN

       FORALL i in l_cpts_orig_osr.FIRST..l_cpts_orig_osr.LAST
       DELETE FROM HZ_IMP_DUP_DETAILS
       WHERE batch_id = p_batch_id
       AND record_os = l_cpts_orig_os(i)
       AND record_osr = l_cpts_orig_osr(i) ;

       END IF;

       IF (p_action_pot_dup_cpts <> NULL and p_action_pot_dup_cpts = 'INSERT' )
       THEN

       FORALL i in l_cpts_orig_osr.FIRST..l_cpts_orig_osr.LAST
       UPDATE HZ_IMP_CONTACTPTS_INT
       SET dqm_action_flag = NULL
       WHERE batch_id = p_batch_id
       AND cp_orig_system = l_cpts_orig_os(i)
       AND cp_orig_system_reference = l_cpts_orig_osr(i) ;

       END IF;

       IF l_last_fetch = TRUE THEN
          EXIT;
       END IF;

       COMMIT;

       END LOOP;
       CLOSE sel_cpts;


EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END action_on_contactpts ;

END HZ_BATCH_ACTION_PUB;

/
