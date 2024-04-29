--------------------------------------------------------
--  DDL for Package Body XXAH_POS_SUPP_PUB_JOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_POS_SUPP_PUB_JOB_PKG" AS

/****************************************************************************
*                           Identification
*                           ==============
* Name              : XXAH_POS_SUPP_PUB_JOB_PKG
* Description       : Package for RFC115 Problemen
****************************************************************************
*                           Change History
*                           ==============
*  Date                Version        Done by
* 12-APR-2017       1.0         Sunil Thamke RFC115 Problemen
****************************************************************************/

  PROCEDURE publish_supp_event_job(ERRBUFF            OUT NOCOPY VARCHAR2,
                                   RETCODE            OUT NOCOPY NUMBER,
                                   p_party_id   IN NUMBER) AS

        partyid_list           pos_tbl_number;
        p_publication_event_id NUMBER;
        p_published_by         NUMBER := fnd_global.user_id;
        p_publish_detail       VARCHAR2(25) := fnd_global.login_id;
        l_from_date            DATE;
        l_to_date              DATE;
        l_event_key            NUMBER := NULL;
        l_party_id                AP_SUPPLIERS.party_id%TYPE;
        row_count varchar2(30);

    TYPE t_record IS TABLE OF pos_supp_pub_history%ROWTYPE;

    l_table t_record;


CURSOR c_load(p_party_id in number)
      IS
      SELECT *
        FROM pos_supp_pub_history
        where trunc(publication_date) = trunc(sysdate)
            and party_id = p_party_id;

CURSOR c_suppliers(p_supparty_id IN NUMBER )
IS
SELECT ap.party_id
                FROM   ap_suppliers ap,
                POS_XXAH_SUPPLIER_TY_AGV pxs
                WHERE  ap.party_id =  pxs.party_id
                AND ap.party_id = nvl(p_supparty_id,ap.party_id);


    BEGIN

            l_party_id    := p_party_id;


          fnd_file.put_line(fnd_file.log,'Parameters passed to the Program are as below:');
          fnd_file.put_line(fnd_file.log,'-----------------------------------------------');
          fnd_file.put_line(fnd_file.log,'l_party_id:'||l_party_id);

        -- Begin Bug 13833924/12765249
        IF l_party_id IS not null then
        SELECT party_id
        BULK COLLECT
        INTO   partyid_list
        FROM   (SELECT ap.party_id
                FROM   ap_suppliers ap,
                POS_XXAH_SUPPLIER_TY_AGV pxs
                WHERE  ap.party_id =  pxs.party_id
                AND    ap.party_id = l_party_id);
  else

          SELECT party_id
        BULK COLLECT
        INTO   partyid_list
        FROM   (SELECT ap.party_id
                FROM   ap_suppliers ap,
                POS_XXAH_SUPPLIER_TY_AGV pxs
                WHERE  ap.party_id =  pxs.party_id);

        end if;

        -- End Bug 13833924/12765249

        if partyid_list.count>0 then

           fnd_file.put_line(fnd_file.log,'Total Number of Published Parties: Count:'||partyid_list.count);
           p_publication_event_id := get_curr_supp_pub_event_id;
           fnd_file.put_line(fnd_file.log,'Publication event Id:'||p_publication_event_id);
           --Calling the Supplier Publish Package
           pos_supp_pub_raise_event_pkg.get_bo_and_insert(partyid_list,
                                                          p_publication_event_id,
                                                          p_published_by,
                                                          p_publish_detail);

         --Calling the workflow section to raise the workflow event
         l_event_key := pos_supp_pub_raise_event_pkg.raise_publish_supplier_event(p_publication_event_id);
       else
         fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------------------------');
         fnd_file.put_line(fnd_file.log,'MESSAGE:** No Party IDs are available to Publish in the given date range **');
         fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------------------------');

        end if;


        --
    BEGIN

FOR r_suppliers IN c_suppliers(l_party_id)
    LOOP

    OPEN c_load(r_suppliers.party_id);

    LOOP
      -- l_table.DELETE;

      FETCH c_load BULK COLLECT
        INTO l_table LIMIT 10000;
        row_count:=c_load%ROWCOUNT;


      FORALL i IN 1 .. l_table.COUNT

        MERGE INTO XXAH_SUPPLIER_PAYLOAD ab USING (
        SELECT l_table(i) .publication_event_id AS event_id,
               l_table(i) .party_id AS party_id,
               l_table(i) .xmlcontent AS xmlcontent
          FROM DUAL) bc ON (ab.party_id = bc.party_id) WHEN MATCHED THEN
      UPDATE
      SET xmlcontent = l_table(i).xmlcontent,last_update_date=
      CURRENT_TIMESTAMP WHEN NOT MATCHED
      THEN
      INSERT(event_id, party_id, xmlcontent)
      VALUES(bc.event_id, bc.PARTY_ID, bc.XMLCONTENT);


      EXIT WHEN c_load%NOTFOUND;
      COMMIT;


    END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'No. Of records inserted ==>' || '' ||row_count );

    CLOSE c_load;

    END LOOP;
  END;

        --


    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'EXCEPTION :' || SQLCODE ||'Error Message :'|| SQLERRM);

    END publish_supp_event_job;
----------------------------------------------
    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER IS
    BEGIN
        SELECT pos_supp_pub_event_s.nextval
        INTO   g_curr_supp_publish_event_id
        FROM   dual;

        RETURN g_curr_supp_publish_event_id;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN - 1;
    END;

------------------------------------------------
END XXAH_POS_SUPP_PUB_JOB_PKG;

/
