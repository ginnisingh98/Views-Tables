--------------------------------------------------------
--  DDL for Package Body MSC_CL_SCE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SCE_COLLECTION" AS -- body
/* $Header: MSCXCSCB.pls 120.7 2006/09/01 09:37:10 vsiyer noship $ */


 CURSOR newCompCursor(p_sr_instance_id NUMBER) IS
      SELECT mst.company_name
      from   msc_st_trading_partners mst
      where  sr_instance_id = p_sr_instance_id
      and    company_name is not null
      MINUS
      SELECT mc.company_name
      from   msc_companies mc;

 names companyNames;
 v_my_company msc_companies.company_name%TYPE;
 v_sr_instance_id NUMBER;
 lv_sql_stmt     VARCHAR2(2048);
 lv_sql_stmt1     VARCHAR2(2048);

   --=====================================================================
   -- Get the profile value from profile option MSC:Configuration
   -- If the profile option is null or not defined then assume it's value
   -- as 'APS'.
   --=====================================================================

   G_MSC_CONFIGURATION VARCHAR2(20) := nvl(fnd_profile.value('MSC_X_CONFIGURATION'), G_CONF_APS);

   PROCEDURE PROCESS_COMPANY_CHANGE(p_status OUT NOCOPY NUMBER) IS

       v_my_company_old_name msc_companies.company_name%TYPE;
       v_my_company_new_name msc_companies.company_name%TYPE;

   BEGIN
     -- ========== Get My company's old Name ============
    v_my_company_old_name := MSC_CL_SCE_COLLECTION.GET_MY_COMPANY;
    IF (v_my_company_old_name = null) then

        LOG_MESSAGE('Error while fetching Company Name');
        p_status := MSC_CL_COLLECTION.G_ERROR;

    END IF;

    -- ========== Get My company's new name ============
    v_my_company_new_name := fnd_profile.value('MSC_X_COMPANY_NAME');
     -- LOG_MESSAGE('The OEM''s Company new name is :'||v_my_company_new_name);
     --LOG_MESSAGE('The OEM''s Company old name is :'||v_my_company_old_name);

    -- ========== Update msc_companies and msc_trading_partners with new name ===

       if v_my_company_new_name <> v_my_company_old_name then

       -- dbms_output.put_line('In Here');

            -- ==== Update msc_companies ====
            BEGIN
                update msc_companies
                set company_name = v_my_company_new_name
                where company_id = G_OEM_ID;

            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while updating Company Name in msc_companies');
      ROLLBACK;
                p_status := MSC_CL_COLLECTION.G_ERROR;
            END;

            -- =======================================
            -- Update msc_trading_partners.
            -- Update all records where
            -- sr_company_id = -1 (This indicates OEM)
            -- and partner_name = v_my_company_old_name
            -- ========================================
            BEGIN
                update msc_trading_partners
                set partner_name = v_my_company_new_name
                where
                partner_name = v_my_company_old_name
                and partner_type in (G_SUPPLIER, G_CUSTOMER)
                and sr_tp_id = -1
                and nvl(company_id, 1) <> 1;
            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while updating Company Name in msc_trading_partners');
      ROLLBACK;
                p_status := MSC_CL_COLLECTION.G_ERROR;
            END;
        end if;

   COMMIT;

   p_status := MSC_CL_COLLECTION.G_SUCCESS;

   END; -- PROCESS_COMPANY_CHANGE

   FUNCTION SCE_TRANSFORM_KEYS(p_instance_id NUMBER,
                         p_current_user   NUMBER,
                   p_current_date   DATE,
                   p_last_collection_id   NUMBER,
                   p_is_incremental_refresh BOOLEAN,
                   p_is_complete_refresh BOOLEAN,
                   p_is_partial_refresh BOOLEAN,
				   p_is_cont_refresh  BOOLEAN,
                   p_supplier_enabled NUMBER,
                   p_customer_enabled NUMBER) RETURN BOOLEAN IS
   lv_msc_tp_coll_window  NUMBER;
   BEGIN
      -- Initialize the instance_id
      v_sr_instance_id := null;

      -- Populate instance Id with Current Instance Id
      v_sr_instance_id := p_instance_id;

      -- LOG_MESSAGE('The instance_id is '||v_sr_instance_id);

      -- ======================================================================================
      -- Delete all Company related LID tables. These tables will be
      -- populated again during Collection.
     -- Perform this step for Complete and partial collections only.
     -- We need not to delete these tables for net change scenario
      -- ======================================================================================
     BEGIN
      lv_msc_tp_coll_window := NVL(TO_NUMBER(FND_PROFILE.VALUE('MSC_COLLECTION_WINDOW_FOR_TP_CHANGES')),0);
     EXCEPTION
        WHEN OTHERS THEN
          lv_msc_tp_coll_window := 0;
     END;

      BEGIN

     IF (p_is_incremental_refresh <> TRUE) THEN

	 -- ========== Check for updates in company site names ==========
     	 UPDATE_COMPANY_SITE_NAMES;


         IF (p_is_complete_refresh) THEN

                  -- ======================================================================================
                  -- Delete Records from msc_trading_partner_maps which are of typr "Planning organization".
              -- These records will be found using msc_company_site_id_lid as reference.
                   -- ======================================================================================
              lv_sql_stmt1 := ' delete msc_trading_partner_maps mtpm '||
                          ' where exists(select 1 '||
                           ' from msc_company_site_id_lid mcsil '||
                          '   where mcsil.company_site_id = mtpm.company_key '||
                           '  and mcsil.partner_type = 3'||
                          '   and mcsil.sr_instance_id = :v_sr_instance_id ) '||
                          ' and mtpm.map_type = 2';

              EXECUTE IMMEDIATE lv_sql_stmt1 USING v_sr_instance_id;

              COMMIT;

              IF lv_msc_tp_coll_window = 0 THEN
                  DELETE MSC_COMPANY_ID_LID WHERE SR_INSTANCE_ID= p_instance_id;
                  DELETE MSC_COMPANY_SITE_ID_LID WHERE SR_INSTANCE_ID= p_instance_id;
              END IF;


                  -- ======================================================================================
                  -- Delete Records from msc_trading_partner_maps which are of typr "Planning organization".
                   -- This step is required because APS always deletes the Planning Org records and collect
                   -- it fresh.
                   -- ======================================================================================

                  lv_sql_stmt:= ' delete msc_trading_partner_maps mtpm '||
                                ' where exists (select 1 '||
                                ' from msc_trading_partners mtp '||
                                ' where mtp.partner_type = 3'||
                                ' and   mtp.sr_instance_id = :v_sr_instance_id'||
                                ' and   mtp.partner_id = mtpm.tp_key '||
                                ' )'||
                                ' and mtpm.map_type = 2';

                  EXECUTE IMMEDIATE lv_sql_stmt USING v_sr_instance_id;

                  COMMIT;

              ELSIF (p_is_partial_refresh or p_is_cont_refresh) THEN

                  IF ((p_supplier_enabled = MSC_CL_COLLECTION.SYS_YES)
                      OR
                      (p_customer_enabled = MSC_CL_COLLECTION.SYS_YES)) THEN

                      -- ======================================================================================
                      -- Delete Records from msc_trading_partner_maps which are of typr "Planning organization".
                 -- These records will be found using msc_company_site_id_lid as reference.
                       -- ======================================================================================
                  lv_sql_stmt1 := ' delete msc_trading_partner_maps mtpm '||
                                 ' where exists(select 1 '||
                               ' from msc_company_site_id_lid mcsil '||
                              '  where mcsil.company_site_id = mtpm.company_key '||
                               ' and mcsil.partner_type = 3'||
                              '  and mcsil.sr_instance_id = :v_sr_instance_id ) '||
                              ' and mtpm.map_type = 2';

                    EXECUTE IMMEDIATE lv_sql_stmt1 USING v_sr_instance_id;

                  COMMIT;
		  IF lv_msc_tp_coll_window = 0 THEN
                      DELETE MSC_COMPANY_ID_LID WHERE SR_INSTANCE_ID= p_instance_id;
                      DELETE MSC_COMPANY_SITE_ID_LID WHERE SR_INSTANCE_ID= p_instance_id;
                  END IF;

                    -- ======================================================================================
                      -- Delete Records from msc_trading_partner_maps which are of typr "Planning organization".
                       -- This step is required because APS always deletes the Planning Org records and collect
                       -- it fresh.
                       -- ======================================================================================

                      lv_sql_stmt:= ' delete msc_trading_partner_maps mtpm '||
                                    ' where exists (select 1 '||
                                    ' from msc_trading_partners mtp '||
                                    ' where mtp.partner_type = 3'||
                                    ' and   mtp.sr_instance_id = :v_sr_instance_id'||
                                    ' and   mtp.partner_id = mtpm.tp_key '||
                                    ' )'||
                                    ' and mtpm.map_type = 2';

                      EXECUTE IMMEDIATE lv_sql_stmt USING v_sr_instance_id;

                      COMMIT;

                  END IF;

              END IF;

          END IF;
      EXCEPTION WHEN OTHERS THEN
          ROLLBACK;
          LOG_MESSAGE('Error while deleting the SCE LID/ Maps tables');
      END;

      -- ======================================================================================
      -- Create company_id for new companies.
      -- ======================================================================================

      LOG_MESSAGE('Creating global Ids for new Companies');
      CREATE_NEW_COMPANIES ( p_current_user,
                 p_current_date,
                 p_last_collection_id );
      COMMIT;

      -- ======================================================================================
      -- Populate msc_company_id_lid table with new Company information
      -- ======================================================================================

      LOG_MESSAGE('Populating msc_company_id_lid');
      POPULATE_COMPANY_ID_LID;
      COMMIT;

      -- ======================================================================================
      -- Create relationships for new Companies
      -- ======================================================================================

      LOG_MESSAGE('Populating new Company Relationships');
      CREATE_NEW_RELATIONSHIPS;
      COMMIT;

      -- ======================================================================================
      -- Create new Company Sites
      -- ======================================================================================

      LOG_MESSAGE('Creating new company sites');
      CREATE_NEW_COMPANY_SITES;
      COMMIT;

      -- Populate msc_company_site_id_lid
      LOG_MESSAGE('Populating msc_company_site_id_lid');
      POPULATE_COMPANY_SITE_ID_LID;
      COMMIT;

      -- Collect Company Information
      -- This step is commented out since we do not require any Company attributes in
      -- msc_companies.

      -- LOG_MESSAGE('Collecting Companies');
      -- COLLECT_COMPANIES;

      -- ======================================================================================
      -- Collect Company Site Information
      -- This will collect the all Site attributes. The attributes, we are currently
      -- interested in are
      -- 1. planning_enabled_flag.
      -- 2. Address attributes.
      -- 3. Location Code.
      -- Rest of the attributes are also collected for future use.
      -- ======================================================================================

      LOG_MESSAGE('Collecting Company sites');
      COLLECT_COMPANY_SITES;
      COMMIT;

--      Following code is commented because we will not be collecting locations seperately.
--      LOG_MESSAGE('Collecting Company Locations');
--      CREATE_NEW_COMPANY_LOCATIONS (v_sr_instance_id);
--      COLLECT_COMPANY_LOCATIONS (v_sr_instance_id);

      -- If there is no error in processing the return TRUE
      return TRUE;


   END SCE_TRANSFORM_KEYS;

   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

     IF fnd_global.conc_request_id > 0 THEN   -- concurrent program

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

     ELSE

          -- dbms_output.put_line( pBUFF);
       null;

     END IF;

   END LOG_MESSAGE;

   FUNCTION GET_MY_COMPANY return VARCHAR2 IS
       p_my_company    msc_companies.company_name%TYPE;
   BEGIN

      /* Get the name of the own Company */
      /* This name is seeded with company_is = 1 in msc_companies */
      BEGIN
         select company_name into p_my_company
         from msc_companies
         where company_id = 1;
      EXCEPTION
         WHEN OTHERS THEN
         return 'My Company';
      END;

      LOG_MESSAGE('The name in GET_MY_COMPANY :'||p_my_company);
      return p_my_company;

   END GET_MY_COMPANY;

   PROCEDURE UPDATE_COMPANY_SITE_NAMES IS

   -- Cursor for changed company site names
    CURSOR updCompanyNameRecords IS
      SELECT mcs.company_id, mcs.company_site_id,
            decode(mtps.partner_type,G_SUPPLIER, mtps.tp_site_code, G_CUSTOMER, mtps.LOCATION)
  		FROM msc_st_Trading_partner_sites mtps,
  			msc_company_site_id_lid mcsl,
  			msc_company_sites mcs            --bug 5097405
	    WHERE mtps.sr_instance_id = mcsl.sr_instance_id
	         AND mtps.sr_instance_id = v_sr_instance_id
			 AND mtps.partner_type = mcsl.partner_type
			 AND mtps.sr_tp_site_id = mcsl.sr_company_site_id
			 AND mcs.company_site_id = mcsl.company_site_id
			 AND mcs.company_site_name <> decode(mtps.partner_type,G_SUPPLIER, mtps.tp_site_code, G_CUSTOMER, mtps.LOCATION)
			 AND mtps.partner_type in (G_SUPPLIER, G_CUSTOMER);


   a_company_id number_arr;
   a_company_site_id number_arr;
   a_company_site_name companySites;

   BEGIN

     OPEN updCompanyNameRecords;

     FETCH updCompanyNameRecords BULK COLLECT INTO
        a_company_id,
        a_company_site_id,
        a_company_site_name;

     CLOSE updCompanyNameRecords;


     LOG_MESSAGE('No. of msc_company_sites name change records = '||a_company_site_id.COUNT);
     -- update msc_company_sites table
     -- Perform this step only if some data is fetched
     IF a_company_site_id.COUNT > 0 THEN
           FOR i IN 1..a_company_site_id.COUNT LOOP
            	BEGIN
	                 UPDATE msc_company_sites
	                 	   SET company_site_name=a_company_site_name(i)
	                 WHERE company_site_id = a_company_site_id(i)
	                 	   AND company_id = a_company_id(i);
	            EXCEPTION
	              WHEN DUP_VAL_ON_INDEX THEN
	                 LOG_MESSAGE('Unique key violation while updating company_site_names');
	                 LOG_MESSAGE('Clean up required for the site - Company ID: '||a_company_id(i)||', Site ID: '||a_company_site_id(i)||', Site Name: '||a_company_site_name(i));
	                 LOG_MESSAGE(SQLERRM);
	              WHEN OTHERS THEN
                     LOG_MESSAGE('Error while updating company_site_names');
                     LOG_MESSAGE(SQLERRM);
    	        END;
           END LOOP;
     END IF;

   END UPDATE_COMPANY_SITE_NAMES;

   PROCEDURE CREATE_NEW_COMPANIES( p_current_user  NUMBER,
                     p_current_date DATE,
                       p_last_collection_id  NUMBER ) IS
   BEGIN

      -- LOG_MESSAGE('Fetched My Company name');
      v_my_company := GET_MY_COMPANY;

      /* Bulk Collect new Company Names into names */

      open newCompCursor(v_sr_instance_id);
      FETCH newCompCursor BULK COLLECT INTO names;
      close newCompCursor;

      -- LOG_MESSAGE('Bulk Collected new Company names');

      /* Bulk insert the new Companies in msc_companies */
      /* Do this step only if there is data fetched for insert */

      if names.LAST > 0 then
         BEGIN
         FORALL i IN names.FIRST..names.LAST
         insert into msc_companies
            (COMPANY_ID  ,
             COMPANY_NAME  ,
             CREATION_DATE ,
             CREATED_BY ,
             LAST_UPDATE_DATE   ,
             LAST_UPDATED_BY  ,
             LAST_UPDATE_LOGIN
             )
             values
             ( msc_companies_s.nextval,
               names(i),
               p_current_date,
               p_current_user,
               p_current_date,
               p_current_user,
               p_current_user
             );
          EXCEPTION
             WHEN OTHERS THEN
                 LOG_MESSAGE('Error while creating new companies');
                 LOG_MESSAGE('========================================');
                 FND_MESSAGE.SET_NAME('MSC', 'MSC_X_NEW_COMP_ERR');
                 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CREATE_NEW_COMPANIES');
                 FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_COMPANIES');
                 LOG_MESSAGE(FND_MESSAGE.GET);

                 LOG_MESSAGE(SQLERRM);
          END;
      COMMIT;
       --Bug 5155944: Analysing the table to improve performance
       msc_analyse_tables_pk.analyse_table( 'MSC_COMPANIES');
       END IF;

   END CREATE_NEW_COMPANIES;

   PROCEDURE POPULATE_COMPANY_ID_LID IS

   -- Cursor for msc_company_id_lid
      CURSOR newCompLidRecords IS
         select distinct
            mst.sr_instance_id sr_instance_id,
            nvl(mst.company_id, -1) sr_company_id,
            decode(mst.partner_type, G_SUPPLIER, G_CUSTOMER,
                                     G_CUSTOMER, G_SUPPLIER,
                   mst.partner_type) partner_type,
            mc.company_id company_id
         from msc_st_trading_partners mst,
              msc_companies mc
         where nvl(mst.company_name, v_my_company) = mc.company_name
         and   mst.sr_instance_id = v_sr_instance_id
         MINUS
         select mcil.sr_instance_id,
                mcil.sr_company_id,
                mcil.partner_type,
                mcil.company_id
         from   msc_company_id_lid mcil;

    a_sr_instance_id number_arr;
    a_sr_company_id  number_arr;
    a_partner_type      number_arr;
    a_company_id     number_arr;


   BEGIN

         open newCompLidRecords;
         FETCH newCompLidRecords BULK COLLECT INTO
            a_sr_instance_id,
            a_sr_company_id,
            a_partner_type,
            a_company_id;
         close newCompLidRecords;


    LOG_MESSAGE('No. of company_id_lid records = '||a_sr_instance_id.COUNT);
         -- Populate msc_company_id_lid table
         -- Perform this step only if some data is fetched
         BEGIN
            IF a_sr_instance_id.COUNT > 0 THEN

               FORALL i IN 1..a_sr_instance_id.COUNT
               insert into msc_company_id_lid
                  ( sr_instance_id,
                    sr_company_id,
                    partner_type,
                    company_id
                  )
                  values
                  ( a_sr_instance_id(i),
                    a_sr_company_id(i),
                    a_partner_type(i),
                    a_company_id(i)
                  );
            END IF;
         EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while uploading msc_company_id_lid table');

            LOG_MESSAGE('========================================');
            FND_MESSAGE.SET_NAME('MSC', 'MSC_X_COMP_LID_ERR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'POPULATE_COMPANY_ID_LID');
            FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_COMPANY_ID_LID');
            LOG_MESSAGE(FND_MESSAGE.GET);

           LOG_MESSAGE(SQLERRM);

            ROLLBACK;
            RETURN ;
         END;

         -- Commit the transaction
         COMMIT;
         --Bug 5155944: Analysing the table to improve performance
         msc_analyse_tables_pk.analyse_table( 'MSC_COMPANY_ID_LID');


   END POPULATE_COMPANY_ID_LID;

   PROCEDURE CREATE_NEW_RELATIONSHIPS IS

   -- Cursor of new relationships --

      CURSOR newCompRelCursor IS
         select mc1.company_id subject_id,
                mc2.company_id object_id,
                mst.partner_type relationship_type
         from   msc_st_trading_partners mst,
            msc_companies mc1,
            msc_companies mc2
         where  nvl(mst.company_name, v_my_company) = mc2.company_name
         and    nvl(mst.partner_name, v_my_company) = mc1.company_name
         and    mst.sr_instance_id = v_sr_instance_id
         -- Do not include Inventory Organizations in relationship records.
         and    mst.partner_type <> 3
         MINUS
         select subject_id, object_id, relationship_type
         from msc_company_relationships;

    a_subject_id  number_arr;
    a_object_id   number_arr;
    a_relationship_type number_arr;

   BEGIN
   LOG_MESSAGE('Uploading new Company relationships');

      -- Bulk Collect new Relationships

      open newCompRelCursor;
      FETCH newCompRelCursor BULK COLLECT INTO
         a_subject_id,
         a_object_id,
         a_relationship_type;
      close newCompRelCursor;


      -- Insert new Relationships
      -- Do this step only if some data is fetched in earlier step
      IF a_subject_id.COUNT > 0 THEN
         BEGIN
            FORALL i IN 1..a_subject_id.COUNT
            INSERT INTO msc_company_relationships
            ( RELATIONSHIP_ID ,
               SUBJECT_ID      ,
               OBJECT_ID       ,
              RELATIONSHIP_TYPE ,
               CREATION_DATE     ,
               CREATED_BY        ,
               LAST_UPDATE_DATE  ,
               LAST_UPDATED_BY
            )
            values
            ( msc_company_rels_s.nextval,
              a_subject_id(i),
              a_object_id(i),
              a_relationship_type(i),
              sysdate,
              -1,
              sysdate,
              -1
            );
         EXCEPTION
            WHEN OTHERS THEN
               LOG_MESSAGE('Error while creating new relationships');

               LOG_MESSAGE('========================================');
               FND_MESSAGE.SET_NAME('MSC', 'MSC_X_COMPANY_REL_ERR');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CREARE_NEW_RELATIONSHIPS');
               FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_COMPANY_RELATIONSHIPS');
               LOG_MESSAGE(FND_MESSAGE.GET);

               LOG_MESSAGE(SQLERRM);
               ROLLBACK;
         END;
      COMMIT;
  	 --Bug 5155944: Analysing the table to improve performance
         msc_analyse_tables_pk.analyse_table( 'MSC_COMPANY_RELATIONSHIPS');
      END IF;

   END CREATE_NEW_RELATIONSHIPS;

   PROCEDURE CREATE_NEW_COMPANY_SITES IS

   -- Cursor for New Company Sites

   -- Get the Planning and non planning Sites
      CURSOR newCompSites IS
      Select mc.company_id company_id,
             mst.organization_code company_site_name
      from   msc_st_trading_partners mst,
             msc_companies mc
      where  nvl(mst.company_name, v_my_company) = mc.company_name
      and    mst.sr_instance_id = v_sr_instance_id
      and    mst.partner_type = 3

      UNION

   -- Add Sites from msc_st_trading_partner_sites for CUSTOMERS
   -- This step is required because for Oracle ERP data there won't be
   -- any record in msc_trading_partners for Supplier and Customer Sites.

      select mcil.company_id company_id,
              mstp.LOCATION company_site_name
      from   msc_st_trading_partner_sites mstp,
             msc_company_id_lid mcil
      where
      -- Make sure that the Trading partner is defined as Company
             mstp.sr_tp_id = mcil.sr_company_id
      and    mstp.sr_instance_id = mcil.sr_instance_id
      and    mstp.partner_type = mcil.partner_type
      and    mstp.sr_instance_id = v_sr_instance_id

      -- Partner_type should not be 3, i.e. organization
      -- because this Partner Type is already included in previous query.
      and    mstp.partner_type = G_CUSTOMER

      UNION

   -- Add sites from msc_trading_partner_sites for Suppliers.
      SELECT mcil.company_id company_id,
             mstp.tp_site_code  company_site_name
      from msc_st_trading_partner_sites mstp,
           msc_company_id_lid mcil
      where
      -- Make sure that the Trading partner is defined as Company
           mstp.sr_tp_id = mcil.sr_company_id
      and  mstp.sr_instance_id = mcil.sr_instance_id
      and  mstp.sr_instance_id = v_sr_instance_id
      and  mstp.partner_type = mcil.partner_type

      -- Partner_type should not be 3, i.e. organization
      -- Partner Type is already included in above query.
      and  mstp.partner_type = G_SUPPLIER
      MINUS
      select mcs.company_id company_id,
             mcs.company_site_name company_site_name
      from   msc_company_sites mcs;

-- Variables to hold company_id and company_site_name
   a_company_id number_arr;
   a_company_site_name companySites;

   BEGIN
      /* Fetch new site records */

      OPEN newCompSites;

      FETCH newCompSites BULK COLLECT INTO
      a_company_id,
      a_company_site_name;

      close newCompSites;


      /* Populate msc_company_sites with new records.
         Do this step only if some data is fetched */


      if a_company_id.COUNT > 0 THEN
      BEGIN
         FORALL i IN 1..a_company_id.COUNT
           INSERT INTO msc_company_sites
              ( company_site_id,
                company_id,
                company_site_name,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
              )
              values
              ( msc_company_sites_s.nextval,
                a_company_id(i),
                a_company_site_name(i),
                sysdate,
                -1,
                sysdate,
                -1
              );
       EXCEPTION
            WHEN OTHERS THEN
               LOG_MESSAGE('Error while creating new Sites');

               LOG_MESSAGE('========================================');
               FND_MESSAGE.SET_NAME('MSC', 'MSC_X_COMP_SITES_ERR');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CREATE_NEW_COMPANY_SITES');
               FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_COMPANY_SITES');
               LOG_MESSAGE(FND_MESSAGE.GET);

               LOG_MESSAGE(SQLERRM);
               ROLLBACK;
       END;
       COMMIT;
          --Bug 5155944: Analysing the table to improve performance
       msc_analyse_tables_pk.analyse_table( 'MSC_COMPANY_SITES');
       END IF;

   END CREATE_NEW_COMPANY_SITES;

   PROCEDURE POPULATE_COMPANY_SITE_ID_LID IS

   BEGIN
     LOG_MESSAGE('POPULATE_COMPANY_SITE_ID_LID started');

     BEGIN

     INSERT INTO MSC_COMPANY_SITE_ID_LID
     ( SR_INSTANCE_ID,
       SR_COMPANY_ID,
       SR_COMPANY_SITE_ID,
       PARTNER_TYPE,
       COMPANY_SITE_ID
     )
      SELECT mst.sr_instance_id sr_instace_id,
             nvl(mst.company_id, -1) sr_company_id,
             mst.sr_tp_id sr_company_site_id,
             mst.partner_type partner_type,
             mcs.company_site_id
      from   msc_st_trading_partners mst,
             msc_company_id_lid mcil,
             msc_company_sites mcs
      where  nvl(mst.company_id, -1) = mcil.sr_company_id
      and    mst.sr_instance_id = mcil.sr_instance_id
      and    mst.partner_type = mcil.partner_type
      and    mst.sr_instance_id = v_sr_instance_id
      and    mst.partner_type = G_ORGANIZATION
      and    mcil.company_id = mcs.company_id
      and    mst.organization_code = mcs.company_site_name
      and    not exists (select 1
                         from msc_company_site_id_lid mcsil
                         where mcsil.sr_instance_id = mst.sr_instance_id
                         and   mcsil.sr_company_id = nvl(mst.company_id, -1)
                         and   mcsil.sr_company_site_id = mst.sr_tp_id
                         and   mcsil.partner_type = mst.partner_type
                         and   mcsil.company_site_id = mcs.company_site_id)
      UNION
      -- Local Id - Source Id map for Customer and Supplier Sites.
      SELECT mtps.sr_instance_id,
             mtps.sr_tp_id sr_company_id,
             mtps.sr_tp_site_id sr_company_site_id,
             mtps.partner_type,
             mcs.company_site_id
      from   msc_st_trading_partner_sites mtps,
             msc_company_id_lid mcil,
             msc_company_sites mcs
      where  mtps.sr_instance_id = mcil.sr_instance_id
      and    mtps.sr_instance_id = v_sr_instance_id
      and    mtps.sr_tp_id = mcil.sr_company_id
      and    mtps.partner_type = mcil.partner_type
      and    mcil.company_id = mcs.company_id
      and    decode(mtps.partner_type, 2, mtps.LOCATION,
                        1, tp_site_code ) = mcs.company_site_name
      and    not exists (select 1
                         from msc_company_site_id_lid mcsil
                         where mcsil.sr_instance_id = mtps.sr_instance_id
                         and   mcsil.sr_company_id = mtps.sr_tp_id
                         and   mcsil.sr_company_site_id = mtps.sr_tp_site_id
                         and   mcsil.partner_type = mtps.partner_type
                         and   mcsil.company_site_id = mcs.company_site_id);
             EXCEPTION
                 WHEN OTHERS THEN
                     LOG_MESSAGE('Error while POPULATing COMPANY_SITE_ID_LID');
                     LOG_MESSAGE('========================================');
                     FND_MESSAGE.SET_NAME('MSC', 'MSC_X_COMPSITE_IDLID_ERR');
                     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'POPULATE_COMPANY_SITE_ID_LID');
                     FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_COMPANY_SITE_ID_LID');
                     LOG_MESSAGE(FND_MESSAGE.GET);
                     LOG_MESSAGE(SQLERRM);

             END;
             COMMIT;
              --Bug 5155944: Analysing the table to improve performance
             msc_analyse_tables_pk.analyse_table( 'MSC_COMPANY_SITE_ID_LID');

     LOG_MESSAGE('Successfully populated MSC_COMPANY_SITE_ID_LID');

   END POPULATE_COMPANY_SITE_ID_LID;


   -- Trading Partner Data cleanup.

   FUNCTION CLEANSE_DATA_FOR_SCE(p_instance_id NUMBER ,
                                 p_my_company VARCHAR2) RETURN BOOLEAN IS

   CURSOR biDirectional IS
       select
              sr_instance_id,
         sr_tp_id company_id,
         nvl(company_id, -1) sr_tp_id,
              partner_name company_name,
         decode(partner_type,G_SUPPLIER, G_CUSTOMER, G_CUSTOMER, G_SUPPLIER) partner_type,
              nvl(company_name, p_my_company) partner_name
       from msc_st_trading_partners
            where sr_instance_id = p_instance_id
            and partner_type in (G_SUPPLIER, G_CUSTOMER)
            MINUS
       select
         sr_instance_id,
              nvl(company_id, -1) company_id,
         sr_tp_id,
         nvl(company_name, p_my_company) company_name,
         partner_type,
         partner_name
       from   msc_st_trading_partners
       where  sr_instance_id = p_instance_id
       and    partner_type in (G_SUPPLIER, G_CUSTOMER);

    a_sr_tp_id number_arr;
    a_partner_name companyNames;
    a_sr_company_id number_arr;
    a_partner_type number_arr;
    a_company_name companyNames;
    a_sr_instance_id number_arr;


    /* Error out records in msc_st_item_suppliers if
       same Supplier Item belonging to same Supplier Site is pointing
       to multiple master items.
    */
    CURSOR validateItemSuppliers IS
        select
        nvl(company_id ,-1),
        using_organization_id,
        organization_id,
         supplier_id,
         supplier_site_id,
         item_name,
         count(*) count
   from  msc_st_item_suppliers
   where sr_instance_id = p_instance_id
   and   item_name is not null
   group by nvl(company_id ,-1), using_organization_id,
          organization_id, supplier_id, supplier_site_id, item_name
   having count(*) > 1 ;

      a_cust_company_id number_arr;
      a_using_organization_id number_arr;
      a_organization_id    number_arr;
        a_supplier_id    number_arr;
        a_supplier_site_id number_arr;
        a_item_name   items;
        a_count number_arr;

   c_non_my_company  NUMBER;
   a_instance_type      NUMBER;

    CURSOR validateItemCustomers IS
        select
            customer_id,
            customer_site_id,
            customer_item_name,
            count(*) count
        from msc_st_item_customers mic
        where sr_instance_id = p_instance_id
        and   item_name is not null
        group by customer_id,
             customer_site_id,
             company_id,
             customer_item_name
        having count(*) > 1;

        a_customer_id   number_arr;
        a_customer_site_id  number_arr;
        a_company_id number_arr;
        a1_item_name items;
        a1_count  number_arr;


    BEGIN
      LOG_MESSAGE('CLEANSE_DATA_FOR_SCE started');
      LOG_MESSAGE('The instance_id is : '||p_instance_id);
      -- return TRUE;

      /* Data validation starts */

          /*  Abandon Collection if
         - MSC:Configuration = 'APS' and
         - Company_name <> v_my_company

            company_name <> v_my_company indicates that it's a multi company data.
          */

   --=============================================================================
   -- Initialize G_MSC_CONFIGURATION if it is not initialized already
   --=============================================================================

   IF G_MSC_CONFIGURATION = NULL THEN
       G_MSC_CONFIGURATION := nvl(fnd_profile.value('MSC_ATP_DEFAULT_INSTANCE'), G_CONF_APS);
   END IF;

   IF (G_MSC_CONFIGURATION = G_CONF_APS) THEN
       BEGIN
           select count(*)
           into c_non_my_company
           from msc_st_trading_partners mstp
           where nvl(mstp.company_name, p_my_company) <> p_my_company
           and mstp.sr_instance_id = p_instance_id;

           IF (c_non_my_company > 0) THEN

                    LOG_MESSAGE('========================================');
                    FND_MESSAGE.SET_NAME('MSC', 'MSC_X_MULTICOMP_DATA_ERR');
                    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CLEANSE_DATA_FOR_SCE');
                    FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ST_TRADING_PARTNERS');
                    LOG_MESSAGE(FND_MESSAGE.GET);


               RETURN FALSE;
           END IF;

       EXCEPTION WHEN OTHERS THEN

                LOG_MESSAGE('========================================');

                FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
                FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CLEANSE_DATA_FOR_SCE');
                FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_ST_TRADING_PARTNERS');
                LOG_MESSAGE(FND_MESSAGE.GET);


                FND_MESSAGE.SET_NAME('MSC', 'MSC_X_MULTICOMP_SQL_ERR');
                LOG_MESSAGE(FND_MESSAGE.GET);

           LOG_MESSAGE(SQLERRM);

           RETURN FALSE;
       END;
   END IF;


          /*  Abandon the Collection if
         - Source = Exchange and
         - MSC:Configuration = 'APS'
          */

   IF (G_MSC_CONFIGURATION = G_CONF_APS) THEN
       BEGIN
           select instance_type
           into a_instance_type
           from msc_apps_instances mai
           where mai.instance_id = p_instance_id;

           IF (a_instance_type = 3) THEN

             LOG_MESSAGE('========================================');
                  FND_MESSAGE.SET_NAME('MSC', 'MSC_X_MPX_COLL_ERR');
                  LOG_MESSAGE(FND_MESSAGE.GET);

             RETURN FALSE;
           END IF;

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('ERROR while validating Trading Partner staing table for APS configuration');
           LOG_MESSAGE(SQLERRM);
           RETURN FALSE;
       END;
   END IF;

      --==== Data Validation for the many to one records in msc_st_item_suppliers

       /* Error out records in msc_st_item_suppliers if
          same Supplier Item belonging to same Supplier Site is pointing
          to multiple master items.
       */

       BEGIN
           LOG_MESSAGE('Validation of msc_item_suppliers started');

       OPEN validateItemSuppliers;

           FETCH validateItemSuppliers BULK COLLECT INTO
               a_cust_company_id,
               a_using_organization_id,
                   a_organization_id ,
                    a_supplier_id ,
                    a_supplier_site_id ,
                    a_item_name,
                    a_count ;
                CLOSE validateItemSuppliers;

        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while fetching records from validateItemSuppliers cursor');
                 LOG_MESSAGE(SQLERRM);
                 return FALSE;
        END;

            IF a_organization_id.COUNT > 0 THEN
                 BEGIN

       --==== Put this information into LOG file ====
                LOG_MESSAGE('========================================');
                LOG_MESSAGE('Supplier Item is being cross referenced with multiple Master Items');
                FND_MESSAGE.SET_NAME('MSC', 'MSC_X_ITEM_SUPP_1');
                LOG_MESSAGE(FND_MESSAGE.GET);

                FOR i in 1..a_organization_id.COUNT LOOP
                    FND_MESSAGE.SET_NAME('MSC', 'MSC_X_ITEM_SUPP_2');
                    FND_MESSAGE.SET_TOKEN('SUPPLIER_ID', a_supplier_id(i));
                    FND_MESSAGE.SET_TOKEN('SUPPLIER_SITE_ID', a_supplier_site_id(i));
                    FND_MESSAGE.SET_TOKEN('SUPPLIER_ITEM_NAME', a_item_name(i));
                    LOG_MESSAGE(FND_MESSAGE.GET);
                END LOOP;



                     FORALL i IN 1..a_organization_id.COUNT
                     UPDATE msc_st_item_suppliers msis
           set    process_flag = MSC_CL_COLLECTION.G_ERROR
           where  msis.organization_id = a_organization_id(i)
           and    msis.supplier_id =  a_supplier_id(i)
           and    nvl(msis.supplier_site_id, -99) =  nvl(a_supplier_site_id (i), -99)
           and    msis.item_name = a_item_name(i);

                 EXCEPTION
                     WHEN OTHERS THEN

                         LOG_MESSAGE('Error while updating invalid records in msc_st_item_suppliers');
                         LOG_MESSAGE(SQLERRM);
                         return FALSE;
                 END;
             END IF;

                 LOG_MESSAGE('Validation of msc_item_suppliers finished successfully');

            /* Error out records in msc_st_item_customers if
          same Customer Item belonging to same Customer Site is pointing
          to multiple master items.
       */

       BEGIN

           OPEN validateItemCustomers;

           FETCH validateItemCustomers BULK COLLECT INTO
                    a_customer_id ,
                    a_customer_site_id ,
                    a1_item_name,
                    a1_count ;
                CLOSE validateItemCustomers;

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('Error while fetching records from validateItemCustomers cursor');
                LOG_MESSAGE(SQLERRM);
                return FALSE;
       END;


            IF a_customer_id.COUNT > 0 THEN
                 BEGIN

       --==== Put this information into LOG file ====
                LOG_MESSAGE('========================================');

                FND_MESSAGE.SET_NAME('MSC', 'MSC_X_ITEM_CUST_1');
                LOG_MESSAGE(FND_MESSAGE.GET);

                FOR i in 1..a_company_id.COUNT LOOP

                         FND_MESSAGE.SET_NAME('MSC', 'MSC_X_ITEM_CUST_2');
                    FND_MESSAGE.SET_TOKEN('CUSTOMER_ID', a_customer_id(i));
                    FND_MESSAGE.SET_TOKEN('SUPPLIER_SITE_ID', a_customer_site_id(i));
                    FND_MESSAGE.SET_TOKEN('SUPPLIER_ITEM_NAME', a1_item_name(i));
                    LOG_MESSAGE(FND_MESSAGE.GET);

                END LOOP;

                     FORALL i IN 1..a_company_id.COUNT
                     UPDATE msc_st_item_customers msic
           set    process_flag = MSC_CL_COLLECTION.G_ERROR
           where  msic.customer_id = a_customer_id(i)
           and    nvl(msic.customer_site_id, -99) =  nvl(a_customer_site_id (i), -99)
           and    msic.customer_item_name = a1_item_name(i);

                 EXCEPTION
                     WHEN OTHERS THEN
          LOG_MESSAGE('Error while validating Item Customers');
                         LOG_MESSAGE(SQLERRM);
                         return FALSE;
                 END;
             END IF;
                 LOG_MESSAGE('Validation of msc_item_customers finished');

      /* Data validation ends */


-- ==== Data Cleanup Starts here ====

   /*
         If MSC:Configuration = 'APS+SCE' and
         Source = 'ERP'
            - Update Company_name and company_id column for TPs whose
              sites are modeled as Inventory Organizaion
      */

      /* Create Bi-Directional records  */

         OPEN biDirectional;

         FETCH biDirectional BULK COLLECT INTO
           a_sr_instance_id ,
           a_sr_company_id ,
             a_sr_tp_id ,
           a_company_name,
           a_partner_type ,
           a_partner_name ;
         CLOSE biDirectional;

      LOG_MESSAGE('Number of Bi-Directional records : '||a_sr_instance_id.COUNT);

         IF a_sr_instance_id.COUNT > 0 THEN
             BEGIN

                 FORALL i IN 1..a_sr_instance_id.COUNT
                 INSERT INTO MSC_ST_TRADING_PARTNERS
                     ( SR_INSTANCE_ID,
                       COMPANY_ID,
                       COMPANY_NAME,
                       SR_TP_ID,
                       PARTNER_NAME,
                       PARTNER_TYPE
                     )
                     VALUES
                     ( a_sr_instance_id(i),
                       a_sr_company_id(i),
                       a_company_name(i),
                       a_sr_tp_id(i),
                       a_partner_name(i),
                       a_partner_type(i)
                     );

             EXCEPTION
                 WHEN OTHERS THEN
                     LOG_MESSAGE('Error while creating Bi-Directional records');

                     LOG_MESSAGE('========================================');
                     FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
                     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CLEANSE_DATA_FOR_SCE');
                     LOG_MESSAGE(FND_MESSAGE.GET);

                     LOG_MESSAGE(SQLERRM);
                     return FALSE;
             END;
         END IF;


-- ==== Data Clean up ends here ====

         return TRUE;

     END CLEANSE_DATA_FOR_SCE;

-- ==== Data Clean up for Trading Partner Items ====

    PROCEDURE CLEANSE_TP_ITEMS(p_instance_id NUMBER) IS

        CURSOR supItemCompanies IS
            select ROWIDTOCHAR(msis.rowid),
                   mcil.company_id,
                   -99
            from   msc_st_item_suppliers msis,
                   msc_company_id_lid mcil
            where  msis.supplier_id = mcil.sr_company_id
       and    msis.sr_instance_id = mcil.sr_instance_id
       and    mcil.partner_type = G_SUPPLIER
       and    msis.sr_instance_id = p_instance_id
       and    msis.supplier_site_id is null
       and     msis.item_name is not null
       UNION
       select ROWIDTOCHAR(msis.rowid),
         mcil.company_id,
         mcsil.company_site_id
       from   msc_st_item_suppliers msis,
                   msc_company_id_lid mcil,
                   msc_company_site_id_lid mcsil
       where  msis.supplier_id = mcil.sr_company_id
       and    msis.sr_instance_id = mcil.sr_instance_id
       and    mcil.partner_type = G_SUPPLIER
       and    msis.sr_instance_id = p_instance_id
       and    msis.supplier_site_id = mcsil.sr_company_site_id
       and    msis.sr_instance_id = mcsil.sr_instance_id
       and    msis.supplier_id = mcsil.sr_company_id
       and    mcsil.partner_type = G_SUPPLIER
       and    msis.supplier_site_id is not null
       and    msis.item_name is not null;

   a_rowid  rowids;
   a_company_id number_arr;
   a_company_site_id number_arr;

        CURSOR custItemCompanies IS
       select ROWIDTOCHAR(msic.rowid),
                   mcil.company_id,
                   -99
            from   msc_st_item_customers msic,
                   msc_company_id_lid mcil
            where  msic.customer_id = mcil.sr_company_id
       and    msic.sr_instance_id = mcil.sr_instance_id
       and    mcil.partner_type = G_CUSTOMER
       and    msic.sr_instance_id = p_instance_id
       and    msic.customer_site_id is null
       and     msic.customer_item_name is not null
       UNION
       select ROWIDTOCHAR(msic.rowid),
         mcil.company_id,
         mcsil.company_site_id
       from   msc_st_item_customers msic,
                   msc_company_id_lid mcil,
                   msc_company_site_id_lid mcsil
       where  msic.customer_id = mcil.sr_company_id
       and    msic.sr_instance_id = mcil.sr_instance_id
       and    mcil.partner_type = G_CUSTOMER
       and    msic.sr_instance_id = p_instance_id
       and    msic.customer_site_id = mcsil.sr_company_site_id
       and    msic.sr_instance_id = mcsil.sr_instance_id
       and    msic.customer_id = mcsil.sr_company_id
       and    mcsil.partner_type = G_CUSTOMER
       and    msic.customer_site_id is not null
       and    msic.customer_item_name is not null;

    BEGIN

         LOG_MESSAGE('INSIDE CLEANSE_TP_ITEMS');
/*
        OPEN supItemCompanies;

        FETCH supItemCompanies BULK COLLECT INTO
            a_rowid,
            a_company_id,
            a_company_site_id;
        CLOSE supItemCompanies;

        IF a_rowid.COUNT > 0 THEN
            BEGIN
                FORALL i IN 1..a_rowid.COUNT
                    UPDATE msc_st_item_suppliers mis
                    set supplier_company_id = a_company_id(i),
                        supplier_company_site_id = decode(a_company_site_id(i), -99, null, a_company_site_id(i))
                    where mis.rowid = CHARTOROWID(a_rowid(i));
            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while updating msc_item_suppliers with company_id and company_site_id');
                LOG_MESSAGE('========================================');
                FND_MESSAGE.SET_NAME('MSC', 'MSC_CLEAN_TP_ITEM_ERR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CLEANSE_TP_ITEMS');
                LOG_MESSAGE(FND_MESSAGE.GET);
            END;
        END IF;
*/

        /*
            Add a code to address Customer Items.
        */

   /*
        OPEN custItemCompanies;

        FETCH custItemCompanies BULK COLLECT INTO
            a_rowid,
            a_company_id,
            a_company_site_id;
        CLOSE custItemCompanies;

        IF a_rowid.COUNT > 0 THEN
            BEGIN
                FORALL i IN 1..a_rowid.COUNT
                    UPDATE msc_st_item_customers msic
                    set company_id = a_company_id(i),
                        company_site_id = decode(a_company_site_id(i), -99, null, a_company_site_id(i))
                    where msic.rowid = CHARTOROWID(a_rowid(i));
            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while updating msc_item_customers with company_id and company_site_id');
                LOG_MESSAGE('========================================');
                FND_MESSAGE.SET_NAME('MSC', 'MSC_CLEAN_TP_ITEM_ERR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CLEANSE_TP_ITEMS');
                LOG_MESSAGE(FND_MESSAGE.GET);
            END;
        END IF;


        LOG_MESSAGE('CLEANSE_TP_ITEMS SUCCESSFUL');
        */

    END CLEANSE_TP_ITEMS;

-- ==== COLLECT_COMPANY_SITES ====
/*
   This procedure collects following information

    - Planning Sites from msc_st_trading_partners into msc_company_sites

    - Non Planning Sites from msc_st_trading_partners into msc_company_sites

    - Customer / Supplier non planning Sites from msc_st_trading_partner_sites
      into msc_company_sites
*/
   PROCEDURE COLLECT_COMPANY_SITES IS

       -- Planning / Non Planning Sites from msc_st_trading_partners
       CURSOR collCompanySites IS
       SELECT
       mcsil.COMPANY_SITE_ID,
       nvl(mtp.PLANNING_ENABLED_FLAG, 'Y')
       from  msc_st_trading_partners mtp,
             msc_company_site_id_lid mcsil
       where nvl(mtp.company_id, -1) = mcsil.sr_company_id
       and   mtp.sr_instance_id = mcsil.sr_instance_id
       and   mtp.sr_instance_id = v_sr_instance_id
       and   mtp.sr_tp_id = mcsil.sr_company_site_id
       and   mtp.partner_type = mcsil.partner_type
       and   mtp.partner_type = G_ORGANIZATION;

       -- Collect the Trading Partner Sites.
       CURSOR collCompanyTpSites IS
       SELECT distinct
             mcsil.COMPANY_SITE_ID,
              mstps.LOCATION,
             mstps.LONGITUDE,
             mstps.LATITUDE,
             mstps.ADDRESS1,
             mstps.ADDRESS2,
             mstps.ADDRESS3,
             mstps.ADDRESS4,
             mstps.country,
             mstps.state,
             mstps.city,
             mstps.county,
             mstps.province,
             mstps.postal_code
       FROM  MSC_ST_TRADING_PARTNER_SITES mstps,
             msc_company_site_id_lid mcsil
       WHERE mcsil.SR_COMPANY_ID = nvl(mstps.sr_tp_id, -1)
         AND mcsil.SR_COMPANY_SITE_ID= mstps.SR_TP_SITE_ID
         AND mcsil.SR_INSTANCE_ID= mstps.SR_INSTANCE_ID
         AND mcsil.partner_type = mstps.partner_type
         AND mstps.SR_INSTANCE_ID= v_sr_instance_id
         AND mstps.partner_type IN (G_SUPPLIER, G_CUSTOMER)
       ORDER BY
             mcsil.COMPANY_SITE_ID;

--=======================================================================================
--  Following cursor will be used to collect location and address information
--  for planning Organization. This information is stored in msc_st_trading_partner_sites
--  table.
--=======================================================================================
       CURSOR collOrgSiteAttrib IS
       SELECT
             mcsil.COMPANY_SITE_ID,
             mtps.location,
             mtps.longitude,
             mtps.latitude,
             mtps.ADDRESS1,
             mtps.ADDRESS2,
             mtps.ADDRESS3,
             mtps.ADDRESS4,
             mtps.country,
             mtps.state,
             mtps.city,
             mtps.county,
             mtps.province,
             mtps.postal_code
       from  msc_st_trading_partner_sites mtps,
             msc_company_site_id_lid mcsil
       where nvl(mtps.company_id, -1) = mcsil.sr_company_id
       and   mtps.sr_instance_id = mcsil.sr_instance_id
       and   mtps.sr_instance_id = v_sr_instance_id
       and   mtps.sr_tp_id = mcsil.sr_company_site_id
       and   mtps.partner_type = mcsil.partner_type
       and   mtps.partner_type = G_ORGANIZATION;

       a_COMPANY_SITE_ID   number_arr;
       -- a_DELETED_FLAG      number_arr;
       -- a_REFRESH_ID     number_arr;
       -- a_OPERATING_UNIT    number_arr;
       -- a_DISABLE_DATE      date_arr;
       -- a_MASTER_ORGANIZATION  number_arr;
       -- a_WEIGHT_UOM     char3_arr;
       -- a_MAXIMUM_WEIGHT    number_arr;
       -- a_VOLUME_UOM     char3_arr;
       -- a_MAXIMUM_VOLUME    number_arr;
       a_PLANNING_ENABLED_FLAG   char_arr;
       -- a_CALENDAR_CODE     calendarCodes;
       -- a_CALENDAR_EXCEPTION_SET_ID  number_arr;
       -- a_PROJECT_REFERENCE_ENABLED  number_arr;
       -- a_PROJECT_CONTROL_LEVEL      number_arr;
       -- a_DEMAND_LATENESS_COST    number_arr;
       -- a_SUPPLIER_CAP_OVERUTIL_COST number_arr;
       -- a_RESOURCE_CAP_OVERUTIL_COST number_arr;
--       a_DEFAULT_DEMAND_CLASS     defaultDemandClasses;
       -- a_TRANSPORT_CAP_OVER_UTIL_COST  number_arr;
       -- a_USE_PHANTOM_ROUTINGS    number_arr;
       -- a_INHERIT_PHANTOM_OP_SEQ     number_arr;
       -- a_DEFAULT_ATP_RULE_ID     number_arr;
       -- a_MATERIAL_ACCOUNT     number_arr;
       -- a_EXPENSE_ACCOUNT      number_arr;
--       a_CUSTOMER_CLASS_CODE      customerClassCodes;
       -- a_SERVICE_LEVEL        number_arr;
       -- a_ORGANIZATION_TYPE    number_arr;
       a_LOCATION       locationCodes;
       a_LONGITUDE         number_arr;
       a_LATITUDE       number_arr;

       a_ADDRESS1       addressLines;
       a_ADDRESS2       addressLines;
       a_ADDRESS3       addressLines;
       a_ADDRESS4       addressLines;
       a_country        countries;
       a_state          states;
       a_city           cities;
       a_postal_code       postalCodes;
       a_county            counties;
       a_province       provinces;

   BEGIN
       LOG_MESSAGE('Inside collect_company_sites');

--==================================================================================
--  Following SQL will update planning_enabled flag in msc_company_sites. This will
--  also take care of situation where previous non planning site has become planning
--  organization.
--==================================================================================
       OPEN collCompanySites;
           FETCH collCompanySites BULK COLLECT INTO
            a_COMPANY_SITE_ID,
                a_PLANNING_ENABLED_FLAG;
       CLOSE collCompanySites;


       IF a_company_site_id.COUNT > 0 THEN
           BEGIN
               FORALL i IN 1..a_company_site_id.COUNT
               UPDATE MSC_COMPANY_SITES
               SET      PLANNING_ENABLED = a_PLANNING_ENABLED_FLAG(i)
             WHERE   COMPANY_SITE_ID = a_COMPANY_SITE_ID(i);
         EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('Error while collecting Planning/ Non Planning Company Sites');
      END;
     END IF;


--==================================================================================
--  Collect Location / Address information for non Planning sites. Mainly sites of
--  the trading partners (Customer / Supplier). If the collections happen from
--  marketplace Exchange then we might have Company's own non planning sites in
--  this CURSOR.
--==================================================================================
      OPEN collCompanyTpSites;

      FETCH collCompanyTpSites BULK COLLECT INTO
               a_COMPANY_SITE_ID,
                a_LOCATION,
               a_LONGITUDE,
               a_LATITUDE,
               a_ADDRESS1,
               a_ADDRESS2,
               a_ADDRESS3,
               a_ADDRESS4,
               a_country,
               a_state,
               a_city,
               a_county,
               a_province,
               a_postal_code;
           CLOSE collCompanyTpSites;

           IF a_COMPANY_SITE_ID.COUNT > 0 THEN
               BEGIN
                   FORALL i IN 1..a_COMPANY_SITE_ID.COUNT
                       UPDATE MSC_COMPANY_SITES
                         set LOCATION = a_LOCATION(i),
                             LONGITUDE = a_LONGITUDE(i),
                             LATITUDE = a_LATITUDE(i),
                             ADDRESS1 = a_ADDRESS1(i),
                             ADDRESS2 = a_ADDRESS2(i),
                             ADDRESS3 = a_ADDRESS3(i),
                             ADDRESS4 = a_ADDRESS4(i),
                             country  = a_country(i),
                             state    = a_state(i),
                             city     = a_city(i),
                             county   = a_county(i),
                             province = a_province(i),
                             postal_code = a_postal_code(i)
                     where company_site_id = a_company_site_id(i);
               EXCEPTION WHEN OTHERS THEN
                   LOG_MESSAGE('Error while Collecting Company Sites for TPs');
               END;
           END IF;


--==================================================================================
--  Collect Location / Address information for planning Orgs.
--==================================================================================

           BEGIN

          OPEN collOrgSiteAttrib;

          FETCH collOrgSiteAttrib BULK COLLECT INTO
                   a_COMPANY_SITE_ID,
                    a_LOCATION,
                   a_LONGITUDE,
                   a_LATITUDE,
                   a_ADDRESS1,
                   a_ADDRESS2,
                   a_ADDRESS3,
                   a_ADDRESS4,
                   a_country,
                   a_state,
                   a_city,
                   a_county,
                   a_province,
                   a_postal_code;
               CLOSE collOrgSiteAttrib;

           EXCEPTION WHEN OTHERS THEN
               LOG_MESSAGE('Error while opening and hetching from collOrgSiteAttrib');
               LOG_MESSAGE(SQLERRM);
           END;

           IF a_COMPANY_SITE_ID.COUNT > 0 THEN
               BEGIN
                   FORALL i IN 1..a_COMPANY_SITE_ID.COUNT
                       UPDATE MSC_COMPANY_SITES
                         set LOCATION = a_LOCATION(i),
                             LONGITUDE = a_LONGITUDE(i),
                             LATITUDE = a_LATITUDE(i),
                             ADDRESS1 = a_ADDRESS1(i),
                             ADDRESS2 = a_ADDRESS2(i),
                             ADDRESS3 = a_ADDRESS3(i),
                             ADDRESS4 = a_ADDRESS4(i),
                             country  = a_country(i),
                             state    = a_state(i),
                             city     = a_city(i),
                             county     = a_county(i),
                             province     = a_province(i),
                             postal_code = a_postal_code(i)
                     where company_site_id = a_company_site_id(i);
               EXCEPTION WHEN OTHERS THEN
                   LOG_MESSAGE('Error while Collecting Location / Address information for Planning Organizations.');
                   LOG_MESSAGE(SQLERRM);
               END;
           END IF;

   END COLLECT_COMPANY_SITES;



   PROCEDURE POPULATE_TP_MAP_TABLE(p_instance_id   NUMBER) IS

   -- ==== Cursor for 'Trading Partner' maps
     cursor newTpMap is
     select DISTINCT mtp.partner_id,
            mcr.relationship_id
          from   msc_trading_partners mtp,
             msc_tp_id_lid mtil,
       msc_company_id_lid mcil,
       msc_company_relationships mcr
          where  mtp.partner_id = mtil.tp_id
          and    mtil.sr_instance_id = p_instance_id
     and    mtil.sr_tp_id     = mcil.sr_company_id
     and    mtil.sr_instance_id = mcil.sr_instance_id
     and    mtil.partner_type = mcil.partner_type
     and    mcil.company_id   = mcr.object_id
     /* Perf changes start */
     /* Removed nvl(mtp.company_id,...) */
     and    mtp.company_id IS NULL
     and    mcr.subject_id = MSC_CL_COLLECTION.G_MY_COMPANY_ID
     /* and    nvl(mtp.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID) = mcr.subject_id */
     /* Perf changes end */
     and    decode(mtp.partner_type, G_SUPPLIER, G_CUSTOMER, G_CUSTOMER, G_SUPPLIER)
            = mcr.relationship_type
     -- Make sure that only trading Partner records are considered.
     and    mtp.partner_type IN (G_SUPPLIER, G_CUSTOMER)
     /* Perf changes */
     /* Removed Minus and added following code lines for performance fix */
     and    not exists ( select 1
                         from msc_trading_partner_maps  mtpm
                         where mtpm.tp_key = mtp.partner_id
                         and   mtpm.company_key = mcr.relationship_id
                         and   mtpm.map_type = 1);
     /* MINUS
     select tp_key,
            company_key
     from   msc_trading_partner_maps
     where  map_type = 1; */

     a_tp_id number_arr;
     a_company_id number_arr;

   -- ==== Cursor for 'Organization' Maps
          cursor newOrgMap is
          select DISTINCT mtp.partner_id,
                 mcs.company_site_id
          from   msc_company_sites mcs,
                msc_company_site_id_lid mcsil,
                msc_trading_partners mtp
          where  mcs.company_site_id = mcsil.company_site_id
          -- Process for the current instance only
          and    mcsil.sr_instance_id = p_instance_id
          -- Join for Organization
          and    mcsil.sr_instance_id = mtp.sr_instance_id
          and    mcsil.sr_company_site_id = mtp.sr_tp_id
          and    mcsil.partner_type = mtp.partner_type
          and    mtp.partner_type = G_ORGANIZATION
          -- Join for company_id
          /* Perf changes */
          /* and    mcs.company_id = nvl(mtp.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID) */
          and    mcs.company_id = MSC_CL_COLLECTION.G_MY_COMPANY_ID
          and    mtp.company_id IS NULL
          and    not exists ( select 1
                              from msc_trading_partner_maps mtpm
                              where mtpm.tp_key = mtp.partner_id
                              and mtpm.company_key
                                        = mcs.company_site_id
                              and   mtpm.map_type = 2);
/*
MINUS
     select tp_key,
            company_key
     from   msc_trading_partner_maps
     where  map_type = 2; */

     a_partner_id number_arr;
     a_company_site_id number_arr;

   -- ==== Cursor for TP Sites Maps.
          cursor newTpSIteMap is
          select DISTINCT mtsil.tp_site_id,
                 mcs.company_site_id
          from   msc_company_sites mcs,
             msc_company_site_id_lid mcsil,
             msc_tp_site_id_lid mtsil
          where  mcs.company_site_id = mcsil.company_site_id
          and    mcsil.sr_instance_id = p_instance_id
          and    mcsil.sr_instance_id = mtsil.sr_instance_id
          and    mcsil.partner_type   = mtsil.partner_type
          and    mtsil.sr_company_id = -1
          and    mcsil.sr_company_site_id = mtsil.sr_tp_site_id
          and    not exists (select 1
                             from msc_trading_partner_maps mtpm
                             where mtpm.tp_key = mtsil.tp_site_id
                             and  mtpm.company_key = mcs.company_site_id
                             and  mtpm.map_type = 3);


/*          MINUS
          select tp_key,
            company_key
     from   msc_trading_partner_maps
     where  map_type = 3; */

     a_tp_site_id number_arr;
     a1_company_site_id number_arr;

   BEGIN
      /* Fetch 'Trading Partner' Map records
         Assuming Map Types as follows
         1 - Trading Partners
         2 - Planning Organizations
         3 - Trading Partner Sites
      */

      OPEN newTpMap;

      FETCH newTpMap BULK COLLECT INTO
      a_tp_id,
      a_company_id;

      close newTpMap;

       IF a_tp_id.COUNT > 0 THEN
      BEGIN
         FORALL i IN 1..a_tp_id.COUNT
           insert into msc_trading_partner_maps
           ( map_id,
            map_type,
            tp_key,
            COMPANY_KEY  ,
            CREATION_DATE,
            CREATED_BY  ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_LOGIN
            ) values
           ( msc_tp_maps_s.nextval,
            1,
            a_tp_id(i),
            a_company_id(i),
            sysdate,
            -1,
            sysdate,
            -1,
            -1
           );

      COMMIT;

      EXCEPTION
       WHEN OTHERS THEN
         LOG_MESSAGE('Error while populating TP map');
         LOG_MESSAGE(SQLERRM);
         RETURN;
                END;
           END IF;


      /* Now Populate the map records for Planning Organization */

      OPEN newOrgMap;

      FETCH newOrgMap BULK COLLECT INTO
      a_partner_id,
      a_company_site_id;

      close newOrgMap;

       IF a_partner_id.COUNT > 0 THEN
      BEGIN
         FORALL i IN 1..a_partner_id.COUNT
           insert into msc_trading_partner_maps
           ( map_id,
            map_type,
            tp_key,
            COMPANY_KEY  ,
            CREATION_DATE,
            CREATED_BY  ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_LOGIN
                 )
                 values
           ( msc_tp_maps_s.nextval,
            2,
            a_partner_id(i),
            a_company_site_id(i),
            sysdate,
            -1,
            sysdate,
            -1,
            -1
           );

      COMMIT;

      EXCEPTION
       WHEN OTHERS THEN
         LOG_MESSAGE('Error while populating Planning Org map');
         LOG_MESSAGE(SQLERRM);
         RETURN;
                END;
           END IF;

      /* Now Populate the map records for Trading Partner Organization */

      BEGIN
          OPEN newTpSIteMap;
          FETCH newTpSIteMap BULK COLLECT INTO
              a_tp_site_id,
              a1_company_site_id;

          close newTpSIteMap;
      EXCEPTION WHEN OTHERS THEN
          LOG_MESSAGE('Error while fetching from newTpSIteMap');
          LOG_MESSAGE(SQLERRM);
      END;

      LOG_MESSAGE('Total Company Site Maps : '||a_tp_site_id.COUNT);

       IF a_tp_site_id.COUNT > 0 THEN
      BEGIN
         FORALL i IN 1..a_tp_site_id.COUNT
           insert into msc_trading_partner_maps
           ( map_id,
            map_type,
            tp_key,
            COMPANY_KEY  ,
            CREATION_DATE,
            CREATED_BY  ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_LOGIN
                 )
                 values
           ( msc_tp_maps_s.nextval,
            3,
            a_tp_site_id(i),
            a1_company_site_id(i),
            sysdate,
            -1,
            sysdate,
            -1,
            -1
           );

      COMMIT;

      EXCEPTION
       WHEN OTHERS THEN
         LOG_MESSAGE('Error while populating Trading Partner Site Maps');
         LOG_MESSAGE(SQLERRM);
         RETURN;
                END;
           END IF;
      --Bug 5155944: Analysing the table to improve performance
    msc_analyse_tables_pk.analyse_table( 'MSC_TRADING_PARTNER_MAPS');

   END POPULATE_TP_MAP_TABLE;


    --==== ODS Load for msc_item_customers ====
    PROCEDURE LOAD_ITEM_CUSTOMERS(p_instance_id NUMBER) IS

    CURSOR itemCustomers IS
    select t1.inventory_item_id,
           mtil.tp_id,
           mtsil.tp_site_id,
           mic.customer_item_name,
           mic.description,
           mic.lead_time,
           mic.uom_code,
           mic.list_price,
           mic.planner_code,
           mic.refresh_number
    from   msc_st_item_customers mic,
           msc_tp_id_lid mtil,
           msc_tp_site_id_lid mtsil,
           msc_item_id_lid t1
    where  t1.SR_INVENTORY_ITEM_ID = mic.inventory_item_id
    AND    t1.sr_instance_id= mic.sr_instance_id
    and    mic.customer_id = mtil.sr_tp_id
    and    nvl(mic.company_id, -1) = nvl(mtil.sr_company_id, -1)
    and    mic.sr_instance_id = mtil.sr_instance_id
    and    mic.sr_instance_id = p_instance_id
    and    mtil.partner_type = G_CUSTOMER
    and    mic.customer_site_id = mtsil.sr_tp_site_id (+)
    and    mic.sr_instance_id = mtsil.sr_instance_id (+)
    and    nvl(mic.company_id, -1) = nvl(mtsil.sr_company_id, -1)
    and    mtsil.partner_type (+) = G_CUSTOMER;

    a_inventory_item_id    number_arr;
    a_tp_id    number_arr;
    a_tp_site_id    number_arr;
    a_item_name    items;
    a_description    descriptions;
    a_lead_time    number_arr;
    a_uom_code    uomCodes;
    a_list_price    number_arr;
    a_planner_code  plannerCodes;
    a_refresh_number number_arr;

    /* Variables initiated for insert operation */
    a_ins_inventory_item_id     number_arr   := number_arr();
    a_ins_tp_id      number_arr  := number_arr();
    a_ins_tp_site_id       number_arr  := number_arr();
    a_ins_item_name        items       := items();
    a_ins_description      descriptions   := descriptions();
    a_ins_lead_time        number_arr  := number_arr();
    a_ins_uom_code         uomCodes    := uomCodes();
    a_ins_list_price       number_arr  := number_arr();
    a_ins_planner_code     plannerCodes   := plannerCodes();
    a_ins_refresh_number   number_arr  := number_arr();
    a_ins_count         number_arr  := number_arr();
    BEGIN

    OPEN itemCustomers;

        FETCH itemCustomers BULK COLLECT INTO
            a_inventory_item_id,
            a_tp_id,
            a_tp_site_id,
            a_item_name,
            a_description,
            a_lead_time,
       a_uom_code,
       a_list_price,
       a_planner_code,
       a_refresh_number;

    CLOSE itemCustomers;

    LOG_MESSAGE('Total customer Item cross references :'||a_inventory_item_id.COUNT);

    IF a_inventory_item_id.COUNT > 0 THEN
        BEGIN

       /* Update the record if it already exists */
       BEGIN

            FORALL i IN 1..a_inventory_item_id.COUNT
                 UPDATE MSC_ITEM_CUSTOMERS mic
      set lead_time = a_lead_time(i),
             uom_code = a_uom_code(i),
                  list_price = a_list_price(i),
             refresh_number = a_refresh_number(i),
             last_update_date = sysdate,
             last_updated_by = -1
      where mic.plan_id = -1
      and   inventory_item_id = a_inventory_item_id(i)
      and   customer_id = a_tp_id(i)
      and   nvl(customer_site_id, -99) = nvl(a_tp_site_id(i), -99);

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('ERROR while updating msc_item_customers');
           LOG_MESSAGE(SQLERRM);
       END;

       /* Build the collection objects for insertion */
       FOR i IN 1..a_inventory_item_id.COUNT LOOP
           IF (SQL%BULK_ROWCOUNT(i) = 0) THEN

           /* Extend the Collection objects */
           a_ins_count.EXTEND;
           a_ins_inventory_item_id.EXTEND;
           a_ins_tp_id.EXTEND;
           a_ins_tp_site_id.EXTEND;
           a_ins_item_name.EXTEND;
           a_ins_description.EXTEND;
           a_ins_lead_time.EXTEND;
           a_ins_uom_code.EXTEND;
           a_ins_list_price.EXTEND;
           a_ins_planner_code.EXTEND;
           a_ins_refresh_number.EXTEND;


           /* Populate collection objects */
           a_ins_count(a_ins_count.COUNT)       := i;
           a_ins_inventory_item_id(a_ins_count.COUNT) := a_inventory_item_Id(i);
           a_ins_tp_id(a_ins_count.COUNT)    := a_tp_id(i);
           a_ins_tp_site_id(a_ins_count.COUNT)  := a_tp_site_id(i);
           a_ins_item_name(a_ins_count.COUNT)      := a_item_name(i);
           a_ins_description(a_ins_count.COUNT)    := a_description(i);
           a_ins_lead_time(a_ins_count.COUNT)      := a_lead_time(i);
           a_ins_uom_code(a_ins_count.COUNT)    := a_uom_code(i);
           a_ins_list_price(a_ins_count.COUNT)     := a_list_price(i);
           a_ins_planner_code(a_ins_count.COUNT)      := a_planner_code(i);
           a_ins_refresh_number(a_ins_count.COUNT)    := a_refresh_number(i);

           END IF;  -- (SQL%BULK_ROWCOUNT(i) = 0)
       END LOOP;

       /* Insert the record if the record does not exist */

       IF a_ins_count.COUNT > 0 THEN

           FORALL i IN 1..a_ins_count.COUNT
                  INSERT INTO MSC_ITEM_CUSTOMERS
                  (PLAN_ID ,
              CUSTOMER_ID ,
              CUSTOMER_SITE_ID,
              INVENTORY_ITEM_ID,
              CUSTOMER_ITEM_NAME ,
              DESCRIPTION ,
              LEAD_TIME ,
              UOM_CODE,
              LIST_PRICE ,
              PLANNER_CODE,
              REFRESH_NUMBER ,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE ,
              CREATED_BY
                  )
                  VALUES
                  (
                   -1, -- Plan Id for Collections Plan
                   a_ins_tp_id(i),
                   a_ins_tp_site_id(i),
                   a_ins_inventory_item_id(i),
                   a_ins_item_name(i),
                   a_ins_description(i),
                   a_ins_lead_time(i),
                   a_ins_uom_code(i),
                   a_ins_list_price(i),
                   a_ins_planner_code(i),
                   a_ins_refresh_number(i),
                   sysdate,
                   -1,
                   sysdate,
                   -1
                  );

        END IF; -- a_ins_count.COUNT > 0

        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while inserting into msc_item_customers');
            LOG_MESSAGE(SQLERRM);

        END;
    END IF;  -- a_inventory_item_id.COUNT > 0

    END LOAD_ITEM_CUSTOMERS;

--======================================================================
-- Collection Pull for User Company Association.
-- This procedure brings User - Company association from ERP.
-- This procedure expectsfollowing set up.
--    1. Users are defined with same name in Source as well as
--       destination
--       instance.
--    2. Users are associated with Customer / Supplier in source
--       instance.
-- If the user is not associated with any company then the procedure
-- assumes
-- that the User belongs to OEM company.
--======================================================================

    PROCEDURE PULL_USER_COMPANY(p_dblink      varchar2,
                    p_instance_id       NUMBER,
                    p_return_status OUT NOCOPY BOOLEAN,
            p_user_company_mode NUMBER) IS

    v_sql_stmt    VARCHAR2(2048);

    BEGIN

    --=======================================================
   -- Collect the records only if p_user_company_mode is set
   -- to User Company Association OR
   -- User Company Association and User Collections
    --=======================================================

    IF ( p_user_company_mode = COMPANY_ONLY OR
        p_user_company_mode = USER_AND_COMPANY) THEN

      v_sql_stmt :=
        ' insert into msc_st_company_users '
        ||' ( user_name ,'
        ||'   sr_company_id ,'
        ||'   sr_instance_id ,'
        ||'   partner_type ,'
        ||'   start_date ,'
        ||'   end_date ,'
        ||'   description ,'
        ||'   email_address ,'
        ||'   fax ,'
        ||'   collection_parameter '
        ||' ) '
        ||'   select distinct'
        ||'   x.user_name ,'
        ||'   x.sr_company_id ,'
        ||'   :v_sr_instance_id ,'
        ||'   x.partner_type ,'
        ||'   x.start_date ,'
        ||'   x.end_date ,'
        ||'   x.description ,'
        ||'   x.email_address ,'
        ||'   x.fax ,'
        ||'   :v_collection_parameter '
        ||'   from MRP_AP_COMPANY_USERS_V'||p_dblink||' x';

   COMMIT;
         -- Collect the records
        BEGIN
            EXECUTE IMMEDIATE v_sql_stmt USING p_instance_id, p_user_company_mode;
        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while pulling msc_company_users data from '||p_instance_id||' (sr_instance_id)');
       LOG_MESSAGE(SQLERRM);
       p_return_status := FALSE;
        END;

    END IF; -- IF p_user_company_mode

    END PULL_USER_COMPANY;

    -- Bug 4872872 : Create password based on value of profile "SignOn Password Length" .

    FUNCTION build_passwd RETURN VARCHAR2
    IS

      passwd_len number  :=  NVL(FND_PROFILE.VALUE('SIGNON_PASSWORD_LENGTH') , 5) ;
      msize number := passwd_len -8 ;
      p_password varchar2(30) := 'welcome1';
	Begin

        log_message('Profile "SignOn Password Length" = '||passwd_len);

	IF (msize > 0 ) THEN
	FOR i in 1..msize LOOP

	p_password := p_password||'i+1' ;

	END LOOP;
        END IF;
	--log_message('Password  :'||p_password);
	RETURN p_password ;

     EXCEPTION WHEN OTHERS THEN
	RETURN 'welcome1' ;

     END build_passwd ;

    PROCEDURE LOAD_USER_COMPANY (p_sr_instance_id NUMBER) IS
-- =================
-- Get the new users
-- =================
    CURSOR newUsers IS
    select distinct user_name,
           start_date,
           end_date,
           description,
           email_address,
           fax
    from msc_st_company_users mscu
    where mscu.sr_instance_id = p_sr_instance_id
    and not exists (select '1'
             from fnd_user fu
             where fu.user_name = UPPER(mscu.user_name))
    -- ================================================================================
    -- Pull only if Collection Parameter is set to "Users and User Company Association"
    -- ================================================================================
    and mscu.collection_parameter =  USER_AND_COMPANY;

--===============================================================================================
-- If User-Company association already exists in system by virtue of collection from one source
-- system then we need to reject User-Company association from other source instance for the same
-- user name.
--===============================================================================================

    CURSOR invalidUsers IS
    select distinct mscu.user_name user_name
    from msc_st_company_users mscu,
         fnd_user fu
    where UPPER(mscu.user_name) = fu.user_name
    and   mscu.sr_instance_id = p_sr_instance_id
    and exists (select '1'
                from msc_company_users mcu
                where mcu.user_id = fu.user_id
                and   nvl(mcu.sr_instance_id, -999) <> mscu.sr_instance_id
               );

    CURSOR validUsersUpdate IS
    select fu.user_name user_name,
           mscu.sr_instance_id sr_instance_id,
           mscu.start_date start_date,
           mscu.end_date end_date,
           mscu.description description,
           mscu.email_address email_address,
           mscu.fax fax
    from msc_st_company_users mscu,
         fnd_user fu,
         msc_company_id_lid mcil
    where mscu.sr_instance_id = p_sr_instance_id
    and   UPPER(mscu.user_name) = fu.user_name
    and   mscu.sr_company_id = mcil.sr_company_id
    and   mscu.sr_instance_id = mcil.sr_instance_id
    and   mscu.partner_type = mcil.partner_type
    and   not exists (select '1'
                from msc_company_users mcu
                where mcu.user_id = fu.user_id
                and   nvl(mcu.sr_instance_id, -999) <> mscu.sr_instance_id
               )
    -- ==========================================================
    -- Get Users for updation only if the collection_parameter is
    -- "Users and User Company Association"
    -- ==========================================================
    and   mscu.collection_parameter = USER_AND_COMPANY
    MINUS
    select fu.user_name user_name,
           mcu.sr_instance_id sr_instance_id,
           fu.start_date start_date,
           fu.end_date end_date,
           fu.description description,
           fu.email_address email_address,
           fu.fax fax
    from   msc_company_users mcu,
         fnd_user fu
    where  mcu.user_id = fu.user_id
    and    mcu.sr_instance_id = p_sr_instance_id;

    CURSOR validUsers IS
    select fu.user_id user_id,
           mscu.sr_instance_id sr_instance_id,
           mcil.company_id company_id
    from msc_st_company_users mscu,
         fnd_user fu,
         msc_company_id_lid mcil
    where mscu.sr_instance_id = p_sr_instance_id
    and   UPPER(mscu.user_name) = fu.user_name
    and   mscu.sr_company_id = mcil.sr_company_id
    and   mscu.sr_instance_id = mcil.sr_instance_id
    and   mscu.partner_type = mcil.partner_type
    and   mscu.sr_company_id <>-1
    and   not exists (select '1'
                from msc_company_users mcu
                where mcu.user_id = fu.user_id
                and   nvl(mcu.sr_instance_id, -999) <> mscu.sr_instance_id
               )

    UNION

    select fu.user_id user_id,
           mscu.sr_instance_id sr_instance_id,
           1 company_id
    from   msc_st_company_users mscu,
           fnd_user fu
    where  UPPER(mscu.user_name) = fu.user_name
    and    mscu.sr_company_id = -1
    and    not exists  (select '1'
                from msc_company_users mcu
                where mcu.user_id = fu.user_id
                and   nvl(mcu.sr_instance_id, -999) <> mscu.sr_instance_id
               )


    MINUS
    select mcu.user_id,
           mcu.sr_instance_id,
           mcu.company_id
    from   msc_company_users mcu
    where  sr_instance_id = p_sr_instance_id;


    a_user_name users;
    a_user_id number_arr;
    a_instance_id number_arr;
    a_company_id number_arr;

    a_ins_user_id number_arr := number_arr();
    a_ins_instance_id number_arr := number_arr();
    a_ins_company_id number_arr := number_arr();
    a_ins_count number_arr := number_arr();

    c_passwd varchar2(30) ;

    BEGIN

--======================================================================
-- Report invalid user-company association to LOG file.
--======================================================================

        OPEN invalidUsers;
        FETCH invalidUsers BULK COLLECT INTO
            a_user_name;
        CLOSE invalidUsers;

        IF a_user_name.COUNT > 0 then
            LOG_MESSAGE('User company association validations');
            LOG_MESSAGE('==============================');
                FOR i IN 1..a_user_name.COUNT LOOP
                    LOG_MESSAGE('User '||a_user_name(i)||' is already associated with other Company');
                END LOOP;
       LOG_MESSAGE('==============================');
   END IF;

--============================================
-- Create new users. Perform this task only if
-- p_user_company_mode is USER_AND_COMPANY
--============================================
   BEGIN
       FOR C1 in newUsers LOOP
	Begin
           FND_USER_PKG.createUser(  x_user_name => C1.user_name,
                 x_owner     => 'CUST',
                 x_unencrypted_password  => 'welcome',
                 x_start_date => C1.start_date,
                 x_end_date => C1.end_date,
                 x_description => C1.description,
                 x_email_address => C1.email_address,
                 x_fax => C1.fax
               );

	 Exception
           WHEN OTHERS THEN
	    LOG_MESSAGE('While creating a new user, following error occured. Will try to create the User again');
            LOG_MESSAGE(SQLERRM);

              c_passwd  := build_passwd ;

             FND_USER_PKG.createUser(  x_user_name => C1.user_name,
                 x_owner     => 'CUST',
                 x_unencrypted_password  => c_passwd,
                 x_start_date => C1.start_date,
                 x_end_date => C1.end_date,
                 x_description => C1.description,
                 x_email_address => C1.email_address,
                 x_fax => C1.fax
               );
	      LOG_MESSAGE('Created the User successfully.');
	   End;

      --==========================================================================
      -- Once the user is created, assign MSCX_SC_PLANNER responsibility
      -- to the user
      --==========================================================================

      Fnd_User_Resp_Groups_Api.LOAD_ROW (  x_user_name => C1.user_name,
                   x_resp_key => 'MSCX_SC_PLANNER',
                   x_app_short_name => 'MSC',
                   x_security_group => 'STANDARD',
                   x_owner => NULL,
                   x_start_date => to_char(C1.start_date, 'YYYY/MM/DD'),
                   x_end_date => to_char(C1.end_date, 'YYYY/MM/DD'),
                   x_description => C1.description
                );

       END LOOP;

       COMMIT;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
            LOG_MESSAGE('Please make sure that MSCX_SC_PLANNER responsibility exists');
       LOG_MESSAGE(SQLERRM);
       ROLLBACK;
       RAISE;
   WHEN OTHERS THEN
       LOG_MESSAGE('ERROR while creating a new user using FND_USER_PKG.createUser API');
       LOG_MESSAGE(SQLERRM);
       ROLLBACK;
       RAISE;
   END;

   COMMIT;

--====================================================
-- insert/update the valid users' company association.
--====================================================

        BEGIN
           OPEN validUsers;
       FETCH validUsers BULK COLLECT INTO
           a_user_id,
           a_instance_id,
           a_company_id;

       CLOSE validUsers;
   EXCEPTION WHEN OTHERS THEN
       LOG_MESSAGE('Error while fetching records from validUsers cursor');
       LOG_MESSAGE(SQLERRM);
   END;

   IF a_user_id.COUNT > 0 THEN
       BEGIN
           FORALL i in 1..a_user_id.COUNT
               UPDATE msc_company_users mcu
               set
               company_id = a_company_id(i)
           where mcu.user_id = a_user_id(i)
           and   mcu.sr_instance_id = a_instance_id(i);

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('Error while updating msc_company_users');
                LOG_MESSAGE(SQLERRM);
      RAISE;
       END;
   END IF;


   /* Build the collection objects for insertion */
   FOR i IN 1..a_user_id.COUNT LOOP
       IF (SQL%BULK_ROWCOUNT(i) = 0) THEN

       /* Extend the Collection objects */
           a_ins_count.EXTEND;
           a_ins_user_id.EXTEND;
           a_ins_instance_id.EXTEND;
           a_ins_company_id.EXTEND;

       /* Populate collection objects */
           a_ins_count(a_ins_count.COUNT) := i;
           a_ins_user_id(a_ins_count.COUNT)  := a_user_id(i);
           a_ins_instance_id(a_ins_count.COUNT):= a_instance_id(i);
           a_ins_company_id(a_ins_count.COUNT)  := a_company_id(i);
       END IF;
   END LOOP;


   IF a_ins_count.COUNT > 0 THEN
       BEGIN

           FORALL i in 1..a_ins_count.COUNT
               INSERT INTO MSC_COMPANY_USERS
               ( USER_ID,
                 COMPANY_ID,
                 SR_INSTANCE_ID
               )
               VALUES
               ( a_ins_user_id(i),
                 a_ins_company_id(i),
                 a_ins_instance_id(i)
               );

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('Error while inserting records in msc_company_users');
           LOG_MESSAGE(SQLERRM);
      RAISE;
       END;
   END IF;

--==============================================
-- Update current users with changed information
--==============================================

   BEGIN

   FOR C1 IN validUsersUpdate LOOP
       FND_USER_PKG.UpdateUser( x_user_name => C1.user_name,
                    x_owner => 'CUST',
                 x_start_date => C1.start_date,
                 x_end_date => C1.end_date,
                 x_description => C1.description,
                 x_email_address => C1.email_address,
                 x_fax => C1.fax
                );

   END LOOP;

   COMMIT;
   EXCEPTION WHEN OTHERS THEN
       LOG_MESSAGE('ERROR while updating the User information');
       LOG_MESSAGE(SQLERRM);
       ROLLBACK;
       RAISE;
   END;

    END LOAD_USER_COMPANY;

END MSC_CL_SCE_COLLECTION;

/
