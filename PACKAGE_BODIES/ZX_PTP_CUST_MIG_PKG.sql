--------------------------------------------------------
--  DDL for Package Body ZX_PTP_CUST_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PTP_CUST_MIG_PKG" AS
/* $Header: zxptpcustmigb.pls 120.22 2005/07/25 07:45:36 asengupt ship $ */


l_Created_By              zx_party_tax_profile.created_by%type             := fnd_global.user_id;
l_Creation_Date           zx_party_tax_profile.creation_date%type          := SYSDATE;
l_Last_Updated_By         zx_party_tax_profile.last_updated_by%type        := fnd_global.user_id;
l_Last_Update_Date        zx_party_tax_profile.last_update_date%type       := SYSDATE;
l_Last_Update_Login       zx_party_tax_profile.last_update_login%type      := FND_GLOBAL.CONC_LOGIN_ID;
l_Request_Id              zx_party_tax_profile.request_id%type             := FND_GLOBAL.CONC_REQUEST_ID;
l_Program_Application_Id  zx_party_tax_profile.program_application_id%type := 235;
l_Program_Id              zx_party_tax_profile.program_id%type             := FND_GLOBAL.CONC_PROGRAM_ID;
l_Program_Login_Id        zx_party_tax_profile.program_login_id%type       := FND_GLOBAL.CONC_LOGIN_ID;

----The variables added below enable the ad_parallel_update feature to be used to imporve performance
l_worker_id                 NUMBER;
l_num_workers               NUMBER;
l_table_owner               VARCHAR2(30);
l_batch_size                VARCHAR2(30);
l_any_rows_to_process       BOOLEAN;
l_table_name                VARCHAR2(30);
l_script_name               VARCHAR2(30);
l_start_rowid               ROWID;
l_end_rowid                 ROWID;
l_rows_processed            NUMBER;




/*=========================================================================+
 | PROCEDURE                                                               |
 |    CUSTOMER_MIGRATE                                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This procedure is used to create party tax profiles and             |
 |     registrations for customers based on their accounts.                |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     ZX_PTP_CUST_MIG                                                     |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     20-Jul-04  Ranjith Palani,Arnab Sengupta      Created.              |
 |                                                                         |
 |=========================================================================*/

PROCEDURE CUSTOMER_MIGRATE IS
BEGIN

	  arp_util_tax.debug(' CUSTOMER_MIGRATE (+) ' );

	  arp_util_tax.debug(' Creating Customer PTP  ' );


		       INSERT ALL
				     INTO
					ZX_PARTY_TAX_PROFILE (
					 Party_Tax_Profile_Id
					,Party_Id
					,Rep_Registration_Number  --BugFix 4054814
					,Registration_Type_Code
					,Country_Code
					,Party_Type_Code
					,Customer_Flag
					,First_Party_Le_Flag
					,Supplier_Flag
					,Site_Flag
					,Legal_Establishment_Flag
					,Rounding_Level_code  --rp
					,Process_For_Applicability_Flag
					,Rounding_Rule_Code  --rp
					,Inclusive_Tax_Flag
					,Use_Le_As_Subscriber_Flag
					,Effective_From_Use_Le
					,Reporting_Authority_Flag
					,Collecting_Authority_Flag
					,Provider_Type_Code
					,RECORD_TYPE_CODE
					,Tax_Classification_Code
					,Self_Assess_Flag
					,Allow_Offset_Tax_Flag
					,Allow_Awt_Flag
					,Created_By
					,Creation_Date
					,Last_Updated_By
					,Last_Update_Date
					,Last_Update_Login
					,REQUEST_ID
					,PROGRAM_APPLICATION_ID
					,PROGRAM_ID
					,PROGRAM_LOGIN_ID
					,OBJECT_VERSION_NUMBER
					)
					VALUES
			                (
					ZX_PARTY_TAX_PROFILE_S.NEXTVAL
					,PARTY_ID -- Party ID
					,TAX_REFERENCE -- Rep Registration Number
					,NULL		   -- Registration Type
					,COUNTRY_CODE	   -- Country Code
					,'THIRD_PARTY'        -- Party Type Bug 4381583
					,'Y' -- Customer_Flag
					,'N' -- First Party
					,'N' -- Suppliers
					,'N' -- Site
					,'N' -- Establishment
					,'LINE'  -- Rounding Level
					,'Y' -- Process_For_Applicability_Flag
					,'NEAREST'
					,'N'
					,'N' -- Use_Le_As_Subscriber_Flag
					,NULL -- Effective_From_Use_Le
					,'N' -- Reporting Authority Flag
					,'N'  -- Collecting Authority Flag
					,NULL -- Provider Type
					,'MIGRATED' -- Record Type
					,NULL -- 	Tax Classification
					,'N' -- Self_Assess_Flag
					,'N' -- Allow_Offset_Tax_Flag
					,'N' -- Allow_AWT_Flag
					,l_Created_By
                                        ,l_Creation_Date
                                        ,l_Last_Updated_By
                                        ,l_Last_Update_Date
                                        ,l_Last_Update_Login
                                        ,l_Request_Id
                                        ,l_Program_Application_Id
                                        ,l_Program_Id
                                        ,l_Program_Login_Id
                                        ,1
					)

					SELECT
					HZP.PARTY_ID PARTY_ID,
					HZP.Tax_Reference TAX_REFERENCE,
					HZP.COUNTRY   COUNTRY_CODE

                   FROM
         				HZ_PARTIES HZP
                   WHERE
				     (HZP.PARTY_TYPE = 'ORGANIZATION'
			          OR HZP.PARTY_TYPE = 'PERSON')
                                AND      not exists (select 1 from zx_party_tax_profile
                                         where party_id = HZP.PARTY_ID and Party_Type_Code = 'THIRD_PARTY'
					 );


                arp_util_tax.debug(' CUSTOMER_MIGRATE (-) ' );


        EXCEPTION
                WHEN OTHERS THEN
                arp_util_tax.debug('Exception: Error Occurred during PTP Customer '|| SQLERRM );

END CUSTOMER_MIGRATE;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    CUSTOMER_SITE_MIGRATE                                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This procedure is used to create party tax profiles and             |
 |     registrations for customers based on their account sites.           |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     ZX_PTP_CUST_MIG                                                     |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     20-Jul-04  Ranjith Palani,Arnab Sengupta      Created.              |
 |                                                                         |
 |=========================================================================*/


	PROCEDURE CUSTOMER_SITE_MIGRATE IS

	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;

	BEGIN
	 	arp_util_tax.debug(' CUSTOMER_SITE_MIGRATE(+) ' );
		arp_util_tax.debug(' Creating customer site PTP ' );


				INSERT
					INTO
					ZX_PARTY_TAX_PROFILE(
					 Party_Tax_Profile_Id
					,Party_Id
					,Rep_Registration_Number --BugFix 4054875
					,Registration_Type_Code
					,Country_Code
					,Party_Type_code
					,Customer_Flag
					,First_Party_Le_Flag
					,Supplier_Flag
					,Site_Flag
					,Legal_Establishment_Flag
					,Rounding_Level_code
					,Process_For_Applicability_Flag
					,Rounding_Rule_Code
					,Inclusive_Tax_Flag
					,Use_Le_As_Subscriber_Flag
					,Effective_From_Use_Le
					,Reporting_Authority_Flag
					,Collecting_Authority_Flag
					,PROVIDER_TYPE_CODE
					,RECORD_TYPE_CODE
					,TAX_CLASSIFICATION_CODE
					,Self_Assess_Flag
					,ALLOW_AWT_FLAG
					,Allow_Offset_Tax_Flag
					,Created_By
					,Creation_Date
					,Last_Updated_By
					,Last_Update_Date
					,Last_Update_Login
					,REQUEST_ID
					,PROGRAM_APPLICATION_ID
					,PROGRAM_ID
					,PROGRAM_LOGIN_ID
					,OBJECT_VERSION_NUMBER
					)
			SELECT
					 ZX_PARTY_TAX_PROFILE_S.NEXTVAL
					,HZPS.PARTY_SITE_ID -- Party ID
					,PTP.Rep_Registration_Number   --- Rep Registration
					,NULL
					,PTP.COUNTRY_CODE
					,'THIRD_PARTY_SITE' -- Party Type Bug 4381583
					,'Y' -- Customer_Flag
					,'N' -- First Party
					,'N' -- Suppliers
					,'Y' -- Site
					,'N' -- Establishment
					,PTP.Rounding_Level_code
					,'Y' -- Process_For_Applicability_Flag
		                        ,PTP.Rounding_Rule_Code
					,'N'
					,'N' -- Use_Le_As_Subscriber_Flag
					,NULL -- Effective_From_Use_Le
					,'N' -- Reporting Authority Flag
					,'N' -- Collecting Authority Flag
					, NULL -- Provider Type
					,'MIGRATED' -- Record Type
					, NULL
					,'N' -- Self_Assess_Flag
					,'N' -- Allow_Offset_Tax_Flag
					,'N' --Allow_AWT_Flag
					,l_Created_By
                                        ,l_Creation_Date
                                        ,l_Last_Updated_By
                                        ,l_Last_Update_Date
                                        ,l_Last_Update_Login
                                        ,l_Request_Id
                                        ,l_Program_Application_Id
                                        ,l_Program_Id
                                        ,l_Program_Login_Id
                                        ,1
				FROM

				     ZX_PARTY_TAX_PROFILE PTP,
				     HZ_PARTY_SITES HZPS

				WHERE
				        PTP.party_id = HZPS.party_id
				AND 	PTP.Party_Type_Code = 'CUSTOMER'
				AND 	not exists ( select 1 from zx_party_tax_profile
					              		where party_id = HZPS.Party_Site_Id
					                and Party_Type_Code = 'THIRD_PARTY_SITE');



        EXCEPTION
        When Others then
             arp_util_tax.debug('Exception: Error in Cust Site Migration' || SQLERRM );
	arp_util_tax.debug(' CUSTOMER_SITE_USES Registration creation (-) ' );


	END  CUSTOMER_SITE_MIGRATE ;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    Create_Lookups                                                       |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This procedure is used to create lookups for zx_ptptr_geo_type_class|
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     ZX_PTP_CUST_MIG                                                     |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     20-Jul-04  Ranjith Palani,Arnab Sengupta      Created.              |
 |                                                                         |
 |=========================================================================*/


	PROCEDURE Create_Lookups IS
	BEGIN
	    IF PG_DEBUG = 'Y' THEN
	       arp_util_tax.debug('Create_Lookup(+)');
	    END IF;

	INSERT ALL
	WHEN (NOT EXISTS
	      (SELECT 1 FROM FND_LOOKUP_TYPES
	       WHERE LOOKUP_TYPE = 'ZX_PTPTR_GEO_TYPE_CLASS')
	      ) THEN
	INTO FND_LOOKUP_TYPES
	(
	 APPLICATION_ID         ,
	 LOOKUP_TYPE            ,
	 CUSTOMIZATION_LEVEL    ,
	 SECURITY_GROUP_ID      ,
	 VIEW_APPLICATION_ID    ,
	 CREATION_DATE          ,
	 CREATED_BY             ,
	 LAST_UPDATE_DATE       ,
	 LAST_UPDATED_BY        ,
	 LAST_UPDATE_LOGIN
	)
	VALUES
	(
	 235                    ,
	'ZX_PTPTR_GEO_TYPE_CLASS' ,
	'E'                      ,
	 0                       ,
	 0                       ,
	 SYSDATE                 ,
	 fnd_global.user_id      ,
	 SYSDATE                 ,
	 fnd_global.user_id      ,
	 fnd_global.conc_login_id
	)
	SELECT 1  FROM DUAL;

	INSERT INTO FND_LOOKUP_TYPES_TL
	(
	            LOOKUP_TYPE,
	            SECURITY_GROUP_ID,
	            VIEW_APPLICATION_ID,
	            LANGUAGE,
	            SOURCE_LANG,
	            MEANING,
	            DESCRIPTION,
	            CREATED_BY,
	            CREATION_DATE,
	            LAST_UPDATED_BY,
	            LAST_UPDATE_DATE,
	            LAST_UPDATE_LOGIN
	)
	SELECT
	            types.lookup_type,
	            0                ,--SECURITY_GROUP_ID
	            0                ,--VIEW_APPLICATION_ID
	            L.LANGUAGE_CODE  ,
	            userenv('LANG')  ,
	            'Tax Registrations Geo Type Classification',--MEANING
	            'This lookup type has been created to migrate HZ_CUST_SITE_USES.TAX_CLASSIFICATION to tax registrations.' ,--DESCRIPTION
	            fnd_global.user_id             ,
	            SYSDATE                        ,
	            fnd_global.user_id             ,
	            SYSDATE                        ,
	            fnd_global.conc_login_id
	FROM        FND_LOOKUP_TYPES types,    FND_LANGUAGES L
	WHERE  L.INSTALLED_FLAG in ('I', 'B')
	AND    types.lookup_type = 'ZX_PTPTR_GEO_TYPE_CLASS'
	AND    not exists
	       (select '1'
	        from   fnd_lookup_types_tl sub
	        where  sub.lookup_type = 'ZX_PTPTR_GEO_TYPE_CLASS'
	        and    sub.security_group_id = 0
	        and    sub.view_application_id = 0
	        and    sub.language = l.language_code);

	INSERT INTO FND_LOOKUP_VALUES
	(
	 LOOKUP_TYPE            ,
	 LANGUAGE               ,
	 LOOKUP_CODE            ,
	 MEANING                ,
	 DESCRIPTION            ,
	 ENABLED_FLAG           ,
	 START_DATE_ACTIVE      ,
	 END_DATE_ACTIVE        ,
	 SOURCE_LANG            ,
	 SECURITY_GROUP_ID      ,
	 VIEW_APPLICATION_ID    ,
	 TERRITORY_CODE         ,
	 ATTRIBUTE_CATEGORY     ,
	 ATTRIBUTE1             ,
	 ATTRIBUTE2             ,
	 ATTRIBUTE3             ,
	 ATTRIBUTE4             ,
	 ATTRIBUTE5             ,
	 ATTRIBUTE6             ,
	 ATTRIBUTE7             ,
	 ATTRIBUTE8             ,
	 ATTRIBUTE9             ,
	 ATTRIBUTE10            ,
	 ATTRIBUTE11            ,
	 ATTRIBUTE12            ,
	 ATTRIBUTE13            ,
	 ATTRIBUTE14            ,
	 ATTRIBUTE15            ,
	 TAG                    ,
	 CREATION_DATE          ,
	 CREATED_BY             ,
	 LAST_UPDATE_DATE       ,
	 LAST_UPDATED_BY        ,
	 LAST_UPDATE_LOGIN
	)
	SELECT
	'ZX_PTPTR_GEO_TYPE_CLASS',
	 l.language_code , -- LANGUAGE
	 lk.LOOKUP_CODE             ,
	 lk.MEANING                 ,
	 lk.DESCRIPTION             ,
	 'Y'                     ,--ENABLED_FLAG
	 lk.START_DATE_ACTIVE       ,
	 NULL                    ,--END_DATE_ACTIVE
	 userenv('LANG')         ,--SOURCE_LANG
	 0                       ,--SECURITY_GROUP_ID
	 0                       ,--VIEW_APPLICATION_ID
	 NULL                    ,--TERRITORY_CODE
	 NULL                    ,--ATTRIBUTE_CATEGORY
	 NULL                    ,--ATTRIBUTE1
	 NULL                    ,--ATTRIBUTE2
	 NULL                    ,--ATTRIBUTE3
	 NULL                    ,--ATTRIBUTE4
	 NULL                    ,--ATTRIBUTE5
	 NULL                    ,--ATTRIBUTE6
	 NULL                    ,--ATTRIBUTE7
	 NULL                    ,--ATTRIBUTE8
	 NULL                    ,--ATTRIBUTE9
	 NULL                    ,--ATTRIBUTE10
	 NULL                    ,--ATTRIBUTE11
	 NULL                    ,--ATTRIBUTE12
	 NULL                    ,--ATTRIBUTE13
	 NULL                    ,--ATTRIBUTE14
	 NULL                    ,--ATTRIBUTE15
	 NULL                    ,--TAG
	 SYSDATE                 ,
	 fnd_global.user_id      ,
	 SYSDATE                 ,
	 fnd_global.user_id      ,
	 fnd_global.conc_login_id
	FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
	WHERE lk.lookup_type = 'AR_TAX_CLASSIFICATION'
	       and  lk.language = 'US'
	       and  l.installed_flag in ('I', 'B')
	AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_PTPTR_GEO_TYPE_CLASS'
	    and   language    = l.LANGUAGE_CODE);

	    IF PG_DEBUG = 'Y' THEN
	       arp_util_tax.debug('Create_Lookup(-)');
	    END IF;

	END Create_Lookups;



/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_PTP_CUST_MIG                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This procedure is used as the driver procedure to call all the other|
 |     procdures                                                           |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |                                                                         |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     20-Jul-04  Ranjith Palani,Arnab Sengupta      Created.              |
 |                                                                         |
 |=========================================================================*/



	PROCEDURE ZX_PTP_CUST_MIG IS
	BEGIN

			EXECUTE IMMEDIATE 'ALTER SEQUENCE ZX.ZX_PARTY_TAX_PROFILE_S CACHE 20000';

	                arp_util_tax.debug(' ZX_PTP_CUST_MIG... (+) ' );

			arp_util_tax.debug(' Calling CREATE_LOOKUPS..  ' );

			--ZX_PTP_CUST_MIG_PKG.CREATE_LOOKUPS;

	                arp_util_tax.debug(' Calling CUSTOMER_MIGRATE..  ' );

	                --ZX_PTP_CUST_MIG_PKG.CUSTOMER_MIGRATE;

	                arp_util_tax.debug(' Calling CUSTOMER_SITE_MIGRATE..  ' );

	     		--ZX_PTP_CUST_MIG_PKG.CUSTOMER_SITE_MIGRATE;

			EXECUTE IMMEDIATE 'ALTER SEQUENCE ZX.ZX_PARTY_TAX_PROFILE_S CACHE 20';

	END ZX_PTP_CUST_MIG;


   END  ZX_PTP_CUST_MIG_PKG;

/
