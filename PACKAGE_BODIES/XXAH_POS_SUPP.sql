--------------------------------------------------------
--  DDL for Package Body XXAH_POS_SUPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_POS_SUPP" 
AS
/**************************************************************************
 * VERSION      : $Id: xxah_pos_supp.pks  2016-05-25 08:28:10Z vema.reddy@atos.net $
 * DESCRIPTION  : Contains functionality for Deleting Old Records
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 25-May-2016 Vema Reddy       Initial
 *************************************************************************/

   /**************************************************************************
   *
   * PROCEDURE
   *   Delete records
   *
   * DESCRIPTION
   *    Delete ol Records on POS_SUPP_PUB_HISTORY table
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * errbuf            OUT            output buffer for error messages
   * retcode           OUT            return code for concurrent program
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
   PROCEDURE xxah_pub_history_delete (errorbuf   OUT VARCHAR2,
                                      retcode    OUT NUMBER)
   AS
      x_max_event_id    NUMBER;
      x_main_party_id   NUMBER;
      x_party_id        NUMBER;
      v_count           NUMBER;
      x_count           NUMBER;

      CURSOR supp_list
      IS
         SELECT   DISTINCT party_id
           FROM   pos_supp_pub_history;
   BEGIN
      FOR main_list IN supp_list
      LOOP
           SELECT   COUNT (1), party_id
             INTO   x_count, x_party_id
             FROM   pos_supp_pub_history
            WHERE   party_id = main_list.party_id
         GROUP BY   party_id;

         IF x_count >= 2
         THEN
              SELECT   MAX (publication_event_id), party_id
                INTO   x_max_event_id, x_main_party_id
                FROM   pos_supp_pub_history
               WHERE   party_id = x_party_id
            GROUP BY   party_id;


            DELETE   pos_supp_pub_history
             WHERE   publication_event_id NOT IN (x_max_event_id)
                     AND party_id = x_main_party_id;

            v_count := supp_list%ROWCOUNT;
            COMMIT;
         END IF;
      END LOOP;

      FND_FILE.PUT_LINE (
         FND_FILE.LOG,
         'No. Of records Processed and Deleted ==>' || '' || v_count
      );
   END;
END xxah_pos_supp;

/
