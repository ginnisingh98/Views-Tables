--------------------------------------------------------
--  DDL for Package Body JTF_TTY_CREATE_TERR_FROM_GEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_CREATE_TERR_FROM_GEO" AS
/* $Header: jtfctfgb.pls 120.5 2006/09/12 02:22:49 spai noship $ */
--    Start of Comments
--    PURPOSE
--      For creating/updating equivalent territory for each geo territory created
--      or updated
--
--    HISTORY
--      06/02/03    Vbghosh  Initial Creation
--    End of Comments
----

PROCEDURE CREATE_TERR (p_geo_terr_id        IN NUMBER,
		               p_geo_parent_terr_id IN NUMBER,
		               p_geo_terr_name      IN VARCHAR2)
IS
   l_parent_terr_id NUMBER;
   l_terr_id NUMBER;
   l_qual_type_usg_id NUMBER;

   l_terr_qtype_usg_id NUMBER;
   l_terr_qual_id   NUMBER;
   l_terr_val_id NUMBER;

   l_geo_terr_group_id NUMBER;
   l_terr_rsc_id  NUMBER;
   l_terr_type_id NUMBER;

   l_terr_rsc_access_id NUMBER;

   l_start_date_active DATE;
   l_end_date_active DATE;

   l_access_type VARCHAR2(200);



   l_org_id NUMBER;
   l_rank   NUMBER;



   /* Cursor to get QType Usage from geo_terr_id. This value will be inserted in
    table jtf_qtype_usgs_all */

    CURSOR c_get_qtype_usgs(l_geo_terr_id NUMBER) IS
    SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_geo_terr gtr
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_terr_id
       AND gtr.geo_territory_id = grsc.geo_territory_id
       AND grsc.rsc_role_code = tgr.role_code
       AND tgr.terr_group_id = gtr.terr_group_id
       AND ra.terr_group_role_id = tgr.terr_group_role_id;


     /* Cursor to find Role Code  */
    CURSOR c_role_code(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
           ,b.terr_group_id
    FROM  jtf_tty_terr_grp_roles b
    WHERE
    b.terr_group_id         = l_terr_group_id
    ORDER BY b.role_code;

     /* Resource for territory */
    CURSOR c_terr_resource (l_geo_territory_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.resource_id
         , a.rsc_group_id
         , NVL(a.rsc_resource_type,'RS_EMPLOYEE') rsc_resource_type
    FROM jtf_tty_geo_terr_rsc a
       , jtf_tty_geo_terr b
    WHERE a.geo_territory_id = b.geo_territory_id
    AND b.geo_territory_id = l_geo_territory_id
    AND a.rsc_role_code = l_role;


    /* Access Types for a particular Role within a Territory Group */
   CURSOR c_role_access( lp_terr_group_id NUMBER
                               , lp_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id        = lp_terr_group_id
    AND b.role_code            = lp_role;



BEGIN   --top level begin


    --dbms_output.put_line(' THis is Test');
    --dbms_output.put_line(' p_geo_parent_terr_id ='||p_geo_parent_terr_id);

    BEGIN
    --dbms_output.put_line('p_geo_terr_id:' || p_geo_terr_id);

	   /* Check if call is for update or create
	    for the geo_terr_id if there is record present in terr_all
	   then call is for update.In this case ..*/
	   BEGIN
	         SELECT
				terr_id
				INTO l_terr_id
				FROM jtf_terr_all
				WHERE geo_territory_id = p_geo_terr_id;

            EXCEPTION
	        when FND_API.G_EXC_ERROR then
	        -- Add proper error logging
                --dbms_output.put_line(' exc err sqlerrm:' || sqlerrm);
	        NULL;
	        when FND_API.G_EXC_UNEXPECTED_ERROR then
	        -- Add proper error logging
                --dbms_output.put_line('unexp err sqlerrm:' || sqlerrm);
	        NULL;
	        when no_data_found then
                --dbms_output.put_line('no data found sqlerrm:' || sqlerrm);
	        NULL;
	        when others then
                --dbms_output.put_line('other sqlerrm:' || sqlerrm);
	        -- Add proper error logging
	        NULL;

        END;

    --dbms_output.put_line('terr_id:' || l_terr_id);

            /* If l_terr_id is not null then call is from update
	       So delete all the relevant records and then let continue the create
	       process
	       if create then create the terr_id using the sequence*/
	    IF l_terr_id IS NOT NULL THEN
		/* Update case All the delete scripts here */

		DELETE FROM jtf_terr_usgs_all where terr_id = l_terr_id;
		DELETE FROM jtf_terr_qtype_usgs_all where terr_id = l_terr_id;

		DELETE FROM jtf_terr_rsc_access_all
		WHERE terr_rsc_id  IN (SELECT terr_rsc_id FROM jtf_terr_rsc_all WHERE terr_id = l_terr_id);

		DELETE FROM jtf_terr_rsc_all WHERE terr_id = l_terr_id;

		DELETE FROM jtf_terr_all WHERE terr_id = l_terr_id;

	    ELSE
		/*create the sequence only when call is from create otherwise use the existing ID */

		SELECT JTF_TERR_S.nextval
		INTO l_terr_id
		FROM dual;

	    END IF;


     EXCEPTION
	  WHEN OTHERS THEN
             --dbms_output.put_line('SQL Error while gettting parent terr_id  ' || sqlerrm);
	     RAISE;
    END;


	    /* get the parent territory for geo's parent This will be inserted in parent_terr_id of terr_all */
	    /* get parent terr id  and Org Id */

	    BEGIN
    --dbms_output.put_line('p_geo_parent_terr_id:'||p_geo_parent_terr_id);
		    SELECT terr_id,
			   org_id,
			   rank,
			   start_Date_active,
			   end_date_active,
                           territory_type_id
		      INTO l_parent_terr_id,
			   l_org_id,
			   l_rank,
			   l_start_date_active,
			   l_end_date_active,
                           l_terr_type_id
		      FROM jtf_terr_all
		      WHERE geo_territory_id  = p_geo_parent_terr_id;

		      --dbms_output.put_line(' Parent Territory Id is:'||l_parent_terr_id);

	    EXCEPTION
	      WHEN OTHERS THEN
                --dbms_output.put_line('SQL Error while gettting parent terr_id  ' || sqlerrm);
		   RAISE;
        END;

    --dbms_output.put_line('l_parent_terr_id:'||l_parent_terr_id);

	  /* get terr group Id */

	BEGIN
	    SELECT terr_group_id
	     INTO l_geo_terr_group_id
	     FROM jtf_tty_geo_terr
	  where geo_territory_id = p_geo_terr_id;
    --dbms_output.put_line('terr_group_id:'||l_geo_terr_group_id);

        EXCEPTION
	      when FND_API.G_EXC_ERROR then
	       -- Add proper error logging
	       NULL;
	      when FND_API.G_EXC_UNEXPECTED_ERROR then
	        -- Add proper error logging
	        NULL;
	      when others then
	        --dbms_output.put_line('SQL Error  ' || sqlerrm);
	        RAISE;
       END;

       BEGIN  -- insert into terr_all



       --dbms_output.put_line('TERRITORY ID   ' || l_terr_id);

	    INSERT INTO jtf_terr_all
	     ( TERR_ID
	    , NAME
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,CREATION_DATE
	    ,CREATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,APPLICATION_SHORT_NAME
	    , ENABLED_FLAG
	    , PARENT_TERRITORY_ID
	    , RANK
            , TERRITORY_TYPE_ID
	    ,ORG_ID
	    ,OBJECT_VERSION_NUMBER
            ,CATCH_ALL_FLAG
            ,TERR_GROUP_FLAG
	    ,GEO_TERR_FLAG
	    ,GEO_TERRITORY_ID
	    ,TERR_GROUP_ID
	    ,START_DATE_ACTIVE
	    ,END_DATE_ACTIVE
	    )
	   SELECT l_terr_id
	    , p_geo_terr_name
	    , LAST_UPDATE_DATE
	    , LAST_UPDATED_BY
	    , SYSDATE
	    , CREATED_BY
	    , LAST_UPDATE_LOGIN
	    , 'JTF'
	    , 'Y'
	    , l_parent_terr_id
	    , l_rank--TODO Rank
            , l_terr_type_id
	    ,  l_org_id --org id
	    , OBJECT_VERSION_NUMBER
            , 'N'
            , 'Y'
	    , 'Y'
	    , p_geo_terr_id
	    , l_geo_terr_group_id
	    , l_start_date_active   --TODO END_DATE_ACTIVE
	    , l_end_date_active
	    FROM jtf_tty_geo_terr
	    where geo_territory_id = p_geo_terr_id;
	    --dbms_output.put_line(' After inserting jtf_terr_all');



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
		--dbms_output.put_line('Error 1 ' || sqlerrm);
                NULL;
        WHEN OTHERS THEN
		--dbms_output.put_line('Error 2 ' || sqlerrm);
                NULL;
    END; -- insert into terr_all

    BEGIN --insert into jtf_terr_usgs_all
    --dbms_output.put_line('insert into jtf_terr_usgs_all');

	  /* insert into terr_usgs_all */

           --dbms_output.put_line('Before inserting in terr usgs all Terr ID =   ' || l_terr_id);
	   INSERT INTO jtf_terr_usgs_all
		   (TERR_USG_ID
		    , LAST_UPDATE_DATE
		    , LAST_UPDATED_BY
		    , CREATION_DATE
		    , CREATED_BY
		    , LAST_UPDATE_LOGIN
		    , TERR_ID
		    , SOURCE_ID
		    , ORG_ID
		    )
	    SELECT  JTF_TERR_USGS_S.NEXTVAL
		   , LAST_UPDATE_DATE
		   , LAST_UPDATED_BY
		   , SYSDATE --CREATION_DATE
		   , CREATED_BY
		   , LAST_UPDATE_LOGIN
		   , l_terr_id
		   , -1001  -- FOR SALES ??
		   , l_org_id
	    from jtf_tty_geo_terr
	    where geo_territory_id = p_geo_terr_id;

	    --dbms_output.put_line(' After inserting jtf_terr_usgs_all');



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
		--dbms_output.put_line('Error 3 ' || sqlerrm);
		RAISE;
        WHEN OTHERS THEN
		--dbms_output.put_line('Error 4 ' || sqlerrm);
		RAISE;
    END; --insert into jtf_terr_usgs_all

    BEGIN -- insert into QType Usage

     /* Open the cursor to get the Qtype */

     FOR acctype IN c_get_qtype_usgs(p_geo_terr_id) LOOP

	IF acctype.access_type='ACCOUNT' THEN
		l_qual_type_usg_id := -1001;
	END IF;

        IF acctype.access_type='LEAD' THEN
		l_qual_type_usg_id := -1002;
	END IF;

	IF acctype.access_type='OPPORTUNITY' THEN
		l_qual_type_usg_id := -1003;
	END IF;

	IF acctype.access_type='PROPOSAL' THEN
		l_qual_type_usg_id := -1106;
         END IF;

	IF acctype.access_type='QUOTE' THEN
		l_qual_type_usg_id := -1105;
        END IF;



        /* get the sequence */
        SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

        /* Insert into table jtf_terr_qtype_all */

    --dbms_output.put_line('insert into jtf_terr_qtype_usgs_all');
        INSERT INTO jtf_terr_qtype_usgs_all
        (TERR_QTYPE_USG_ID
	, LAST_UPDATED_BY
	, LAST_UPDATE_DATE
	, CREATED_BY
	, CREATION_DATE
	, LAST_UPDATE_LOGIN
	, TERR_ID
	, QUAL_TYPE_USG_ID
	, ORG_ID
	)
        SELECT l_terr_qtype_usg_id
        , LAST_UPDATED_BY
	, LAST_UPDATE_DATE
	, CREATED_BY
	, SYSDATE --CREATION_DATE
	, LAST_UPDATE_LOGIN
	, l_terr_id
	, l_qual_type_usg_id
	, l_org_id
	FROM jtf_tty_geo_terr
       WHERE geo_territory_id = p_geo_terr_id;

       --dbms_output.put_line(' After inserting jtf_terr_qtype_usgs_all');




     END LOOP;


    EXCEPTION
         WHEN OTHERS THEN
          --dbms_output.put_line('Error 6 ' || sqlerrm);
          RAISE;
   END; --insert into QType Usage


   /* populate resource table */
  BEGIN
    --dbms_output.put_line('get c_role_code');
    FOR tran_type IN c_role_code (l_geo_terr_group_id) LOOP

          --dbms_output.put_line('role_code:'||tran_type.role_code||',terr_group_id:'||tran_type.terr_group_id);
          FOR rsc IN c_terr_resource(p_geo_terr_id,tran_type.role_code) LOOP
          --dbms_output.put_line('rs:'||rsc.resource_id||',rsc_group_id:'||rsc.rsc_group_id||',rsc_resource_type:'||rsc.rsc_resource_type);

	     /*insert in jtf_terr_rsc_all */


	     SELECT JTF_TERR_RSC_S.NEXTVAL
               INTO l_terr_rsc_id
               FROM DUAL;

	       INSERT INTO jtf_terr_rsc_all
	       ( TERR_RSC_ID
		 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,CREATION_DATE
		 ,CREATED_BY
		 ,LAST_UPDATE_LOGIN
		 ,TERR_ID
		 ,RESOURCE_ID
		 ,RESOURCE_TYPE
                 ,GROUP_ID
		 ,ROLE
		 ,PRIMARY_CONTACT_FLAG
		 ,START_DATE_ACTIVE
		 ,END_DATE_ACTIVE
		 ,ORG_ID
                 ,OBJECT_VERSION_NUMBER )
		SELECT l_terr_rsc_id
                 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,SYSDATE --CREATION_DATE
		 ,CREATED_BY
		 ,LAST_UPDATE_LOGIN
		 , l_terr_id
		 , rsc.resource_id
		 , rsc.rsc_resource_type
                 , rsc.rsc_group_id
                 , tran_type.role_code
		 , 'N'
		 , l_start_date_active
		 , l_end_date_active
		 , l_org_id --org id
                 , 1
                 FROM jtf_tty_geo_terr
		 WHERE geo_territory_id = p_geo_terr_id;

		   --dbms_output.put_line(' After inserting jtf_terr_rsc_all');


               /*insert in jtf_terr_rsc_access_all table */
	       FOR rsc_acc IN c_role_access(l_geo_terr_group_id, tran_type.role_code) LOOP
               --dbms_output.put_line('acc_type:'||rsc_acc.access_type);

		    /* get the sequence */
			SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
			   INTO l_terr_rsc_access_id
			   FROM DUAL;

                   /* commented this as all the types are found to be same
                   IF (rsc_acc.access_type= 'ACCOUNT') THEN
			l_access_type :='ACCOUNT';
		   END IF;

                   IF (rsc_acc.access_type= 'OPPORTUNITY') THEN
			l_access_type :='OPPOR';
		   END IF;

		   IF (rsc_acc.access_type= 'LEAD') THEN
			l_access_type :='LEAD';
		   END IF;

		   IF (rsc_acc.access_type= 'PROPOSAL') THEN
			l_access_type :='PROPOSAL';
		   END IF;

		   IF (rsc_acc.access_type = 'QUOTE') THEN
			l_access_type :='QUOTE';
                    END IF;

		    */

                    -- SOLIN, BUG 5018824
                   /* insert into jft_Terr_rsc_Access_all */
		   INSERT INTO jtf_terr_rsc_access_all
		   ( TERR_RSC_ACCESS_ID
		     ,LAST_UPDATE_DATE
		     ,LAST_UPDATED_BY
		     ,CREATION_DATE
		     ,CREATED_BY
		     ,LAST_UPDATE_LOGIN
		     ,TERR_RSC_ID
		     ,ACCESS_TYPE
		     ,ORG_ID
                     ,OBJECT_VERSION_NUMBER
		     ,TRANS_ACCESS_CODE

		   )
		   SELECT
                     l_terr_rsc_access_id
                     ,SYSDATE
		     ,fnd_global.user_id
		     ,SYSDATE--CREATION_DATE
		     ,fnd_global.user_id
		     ,fnd_global.login_id
		     ,l_terr_rsc_id
		     --,l_access_type --commented out
		     , rsc_acc.access_type
		     , l_org_id --org Id
                     , 1
		     , c.trans_access_code
                     FROM jtf_terr_rsc_all b
                        , jtf_terr_rsc_access_all c
                     WHERE b.terr_id = l_parent_terr_id
                       AND b.role = tran_type.role_code
                       AND b.resource_type <> 'RS_EMPLOYEE'
                       AND b.terr_rsc_id = c.terr_rsc_id
                       AND c.access_type = rsc_acc.access_type;
                    -- SOLIN, BUG 5018824, end
                 --dbms_output.put_line(' After inserting jtf_terr_rsc_access_all');

               END LOOP; --rsc_acc


          END LOOP;  --rsc

     END LOOP; --tran_type

    END; --populate resource table




    IF (c_get_qtype_usgs%ISOPEN) THEN
        CLOSE c_get_qtype_usgs;
    END IF;

    IF (c_role_code%ISOPEN) THEN
        CLOSE c_role_code;
    END IF;

    IF (c_terr_resource%ISOPEN) THEN
        CLOSE c_terr_resource;
    END IF;

    IF (c_role_access%ISOPEN) THEN
        CLOSE c_role_access;
    END IF;


     COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END CREATE_TERR;



END JTF_TTY_CREATE_TERR_FROM_GEO;

/
