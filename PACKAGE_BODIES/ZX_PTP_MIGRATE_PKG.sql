--------------------------------------------------------
--  DDL for Package Body ZX_PTP_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PTP_MIGRATE_PKG" AS
/* $Header: zxptpmigb.pls 120.59 2006/05/29 06:27:28 asengupt ship $ */


l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);


------------The procedures declared below were created as part of bug fix 3722296------

PROCEDURE ZX_CREATE_REG(
		p_reg_info		  varchar2,
		p_ptp_id                  zx_party_tax_profile.party_tax_profile_id%type
		       );

 PROCEDURE ZX_CREATE_REGISTRATIONS(
		p_hr_org_reg_info	varchar2,
		p_hr_loc_reg_info	varchar2,
		p_ar_tax_reg_info	varchar2,
		p_fin_vat_reg_info	varchar2,
                p_ptp_id                zx_party_tax_profile.party_tax_profile_id%type,
		p_level			number
		);


-------------THIS PROCEDURE MUST NOT BE INVOKED FROM ANY WRAPPER ROUTINE MUST ONLY BE
-------------CALLED FROM REG_REP_DRIVER_PROC

PROCEDURE ZX_CREATE_REP_TYPE_ASSOC
 (
 p_reg_rec		    register_num_tab,
 p_level		    NUMBER,
 p_ptp_id                   zx_party_tax_profile.party_tax_profile_id%type,
 p_hr_rep_type_info_lat     varchar2,
 p_hr_rep_type_info_kor     varchar2,
 p_hr_rep_type_info_eur_grc varchar2,
 p_ar_tax_reg_info          varchar2,
 p_fin_vat_reg_info         varchar2
 );

--PROCEDURE REG_REP_DRIVER_PROC
--(p_party_type_code zx_party_tax_profile.party_type_code%type) ;

--PROCEDURE REG_REP_DRIVER_PROC_OU
--(p_party_type_code zx_party_tax_profile.party_type_code%type) ;

-----------------------------------------------------------------------------------------



/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_CREATE_REG 	                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the registrations					   |
 |									   |
 |									   |
 |									   |
 |									   |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |    REG_REP_DRIVER_PROC                                                  |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |     Bugfix: 3722296                                                   |
 |=========================================================================*/

PROCEDURE ZX_CREATE_REG(
		p_reg_info		  varchar2,
		p_ptp_id                    zx_party_tax_profile.party_tax_profile_id%type
			)
  IS
  BEGIN


  		arp_util_tax.debug('ZX_CREATE_REG(+)');


		 INSERT
	               	INTO ZX_REGISTRATIONS (
						Registration_Id,
						Registration_Type_Code,
						Registration_Number,
						Registration_Status_Code,
						Registration_Source_Code,
						Registration_Reason_Code,
						Party_Tax_Profile_Id,
     						Tax_Classification_Code,
						Tax_Authority_Id,
						Coll_Tax_Authority_Id,
						Rep_Tax_Authority_Id,
						Tax,
						Tax_Regime_Code,
						Rounding_Rule_Code,
						Tax_Jurisdiction_Code,
						Self_Assess_Flag,
						Inclusive_Tax_Flag,
						Effective_From,
						Effective_To,
						Rep_Party_Tax_Name,
						Legal_Registration_Id,
						Default_Registration_Flag,
                        			Account_Id,
						RECORD_TYPE_CODE,
						Created_By,
						Creation_Date,
						Last_Updated_By,
						Last_Update_Date,
						Last_Update_Login,
						PROGRAM_APPLICATION_ID,
						REQUEST_ID,
						PROGRAM_ID,
						PROGRAM_LOGIN_ID,
						OBJECT_VERSION_NUMBER)
				SELECT

					       ZX_REGISTRATIONS_S.NEXTVAL,      --Registration Id
					       NULL,				--Registration_Type_Code
					       p_reg_info	,	        --Registration Number
					       'REGISTERED',			--Registration Status Code
					       'EXPLICIT',			--Registration Source Code
             				       NULL,				--Registration Reason Code
					       p_ptp_id,				--Party Tax Profile Id
					       NULL,				--Tax_Classification_Code
					       NULL,				--Tax_Authority_Id,
					       NULL,				--Coll_Tax_Authority_Id
					       NULL,				--Rep_Tax_Authority_Id
					       NULL,				--Tax
					       NULL,				--Tax Regime Code
					       ROUNDING_RULE_CODE,--Rounding Rule Code
					       NULL,				--Tax Jurisdiction Code
					       SELF_ASSESS_FLAG,	--Self Assess Flag
					       INCLUSIVE_TAX_FLAG,	--Inclusive Tax Flag
					       SYSDATE,				--Effective From
					       NULL,				--Effective To
					       NULL,				--Rep_Party_Tax_Name
					       NULL,				--Legal Registration Id
					       'Y',				--Default Registration Flag
					       NULL,	       			--Account_Id
					       'MIGRATED',			--Record Type Code
					       fnd_global.user_id,		--Created By
					       SYSDATE,				--Creation Date
					       fnd_global.user_id,		--Last Updated By
					       SYSDATE,				--Last Update Date
					       FND_GLOBAL.CONC_LOGIN_ID,        --Last_Update_Login
					       NULL,				--Program Application Id
					       FND_GLOBAL.CONC_REQUEST_ID,      --REQUEST_ID
					       FND_GLOBAL.CONC_PROGRAM_ID,      --PROGRAM_ID
					       FND_GLOBAL.CONC_LOGIN_ID  ,      --PROGRAM_LOGIN_ID
					       1

				FROM         ZX_PARTY_TAX_PROFILE

				WHERE        PARTY_TAX_PROFILE_ID=p_ptp_id
				AND             NOT EXISTS
						    (SELECT 1 FROM ZX_REGISTRATIONS WHERE REGISTRATION_NUMBER=p_reg_info
						     AND party_tax_profile_id = p_ptp_id);

  		arp_util_tax.debug('ZX_CREATE_REG(-)');


END ZX_CREATE_REG;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_CREATE_REGISTRATIONS                                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the registrations for various entities like           |
 |				1.HR Organization Information              |
 |				2.Hr Locations				   |
 |				3.AR System Parameters All		   |
 |				4.Financial Systems Parameters All         |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |    REG_REP_DRIVER_PROC                                                  |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |     Bugfix: 3722296                                                     |
 |=========================================================================*/



 PROCEDURE ZX_CREATE_REGISTRATIONS(
		p_hr_org_reg_info	varchar2,
		p_hr_loc_reg_info	varchar2,
		p_ar_tax_reg_info	varchar2,
		p_fin_vat_reg_info	varchar2,
                p_ptp_id                zx_party_tax_profile.party_tax_profile_id%type,
		p_level			number
		)
 IS
 BEGIN


   		arp_util_tax.debug('ZX_CREATE_REGISTRATIONS(+)');

      IF p_ptp_id is not null THEN

	IF p_level = 1 THEN

		ZX_CREATE_REG(p_hr_org_reg_info,p_ptp_id);

	ELSIF p_level = 2 THEN

		ZX_CREATE_REG(p_hr_loc_reg_info,p_ptp_id);

	ELSIF p_level = 3 THEN

		ZX_CREATE_REG( p_ar_tax_reg_info,p_ptp_id);


	ELSIF p_level = 4 THEN

		ZX_CREATE_REG( p_fin_vat_reg_info,p_ptp_id);

	END IF;


   		arp_util_tax.debug('ZX_CREATE_REGISTRATIONS(-)');

       END IF;
 END ZX_CREATE_REGISTRATIONS;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_CREATE_REP_TYPE_ASSOC                                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the reporting type associations			   |
 |    for various entities like						   |
 |				1.HR Organization Information              |
 |				2.Hr Locations				   |
 |				3.AR System Parameters All		   |
 |				4.Financial Systems Parameters All         |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     REG_REP_DRIVER_PROC                                                 |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |     Bugfix: 3722296                                                     |
 |=========================================================================*/


 PROCEDURE ZX_CREATE_REP_TYPE_ASSOC
 (
 p_reg_rec		    register_num_tab,
 p_level		    NUMBER,
 p_ptp_id                   zx_party_tax_profile.party_tax_profile_id%type,
 p_hr_rep_type_info_lat     varchar2,
 p_hr_rep_type_info_kor     varchar2,
 p_hr_rep_type_info_eur_grc varchar2,
 p_ar_tax_reg_info          varchar2,
 p_fin_vat_reg_info         varchar2)

IS

I NUMBER;
BEGIN

     arp_util_tax.debug('ZX_CREATE_REP_TYPE_ASSOC(+)');

     IF p_ptp_id IS NOT NULL THEN

	IF  p_level =2    THEN

		ZX_MIGRATE_REP_ENTITIES_PKG.ZX_CREATE_REP_ASSOCIATION_PTP
                     (p_hr_rep_type_info_lat,p_ptp_id,'JL - REG NUMBER');
		ZX_MIGRATE_REP_ENTITIES_PKG.ZX_CREATE_REP_ASSOCIATION_PTP
                     (p_hr_rep_type_info_kor,p_ptp_id,'JA - REG NUMBER');
		ZX_MIGRATE_REP_ENTITIES_PKG.ZX_CREATE_REP_ASSOCIATION_PTP
                     (p_hr_rep_type_info_eur_grc,p_ptp_id,'JE - REG NUMBER');

	ELSIF p_level = 3 THEN
		ZX_MIGRATE_REP_ENTITIES_PKG.ZX_CREATE_REP_ASSOCIATION_PTP
                     (p_ar_tax_reg_info,p_ptp_id,'AR-SYSTEM-PARAM-REG-NUM');

       ELSIF p_level = 4  THEN
		ZX_MIGRATE_REP_ENTITIES_PKG.ZX_CREATE_REP_ASSOCIATION_PTP
                     (p_fin_vat_reg_info,p_ptp_id,'FSO-REG-NUM');

       END IF;

     END IF;

   		arp_util_tax.debug('ZX_CREATE_REP_TYPE_ASSOC(-)');


END ZX_CREATE_REP_TYPE_ASSOC;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    REG_REP_DRIVER_PROC                                                  |
 |                                                                         |
 | DESCRIPTION								   |
 |		This procedure contains the acutal logic for deciding      |
 |		when to create a registrations and when to create          |
 |              a reporting type association .                             |
 |									   |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |		ZX_CREATE_REGISTRATIONS					   |
 |              ZX_CREATE_REP_TYPE_ASSOC                                   |
 | CALLED FROM                                                             |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |     Bugfix: 3722296                                                     |
 |=========================================================================*/


 PROCEDURE REG_REP_DRIVER_PROC(p_party_type_code zx_party_tax_profile.party_type_code%type)
 IS

 ---------------------Local variable declarations-----------------
 l_first_reg_val varchar2(160);
 l_ins_flag_one  BOOLEAN; ----This flag is used to ensure that only one registration is created
 l_ins_flag_two  BOOLEAN;-----This flag is used to ensure that duplicate reporting code associations are not created
 l_position_first_reg NUMBER;
 C_LINES_PER_COMMIT   NUMBER := 1000;

 --------TABLE DECLARTIONS-----------------------------------
 pg_org_reg_num_tab		org_reg_num_tab;
 pg_loc_reg_num_tab		loc_reg_num_tab;
 pg_ar_sys_reg_num_tab		ar_sys_reg_num_tab;
 pg_fin_sys_reg_num_tab		fin_sys_reg_num_tab;
 reg_num_tab			register_num_tab;
 ptp_tab		        party_tax_profile_tab;
 hr_rep_info_lat_tab		hr_org_rep_info_tab;
 hr_rep_info_kor_tab		hr_org_rep_info_tab;
 hr_rep_info_eur_grc_tab        hr_org_rep_info_tab;
 ---------------Cursor Declarations-----------------------------

CURSOR C_GET_REG_NUMBERS IS
SELECT  HrOrgInfo.ORG_INFORMATION2                              ORG_REG_NUM,
        decode(HrLoc.GLOBAL_ATTRIBUTE_CATEGORY, 'JL.AR.PERWSLOC.LOC'
              ,HrLoc.Global_Attribute11||hrloc.Global_Attribute12,'JL.CL.PERWSLOC.LOC',
                        HrLoc.Global_Attribute1)                LOC_REG_NUM,
        ARP.Tax_Registration_Number                             AR_SYS_REG_NUM,
        Fso.Vat_Registration_Num                                FIN_SYS_REG_NUM,
        PTP.Party_Tax_Profile_Id                                PTP_ID,
        HrLoc.Global_Attribute11||HrLoc.Global_Attribute12      HR_REP_TYPE_INFO_LAT,
        HrLoc.Global_Attribute1                                 HR_REP_TYPE_INFO_KOR,
        HrLoc.Global_Attribute2                                 HR_REP_TYPE_INFO_EUR_GRC
FROM
       Hr_Locations_All HrLoc
       ,xle_etb_profiles XEP
       ,Hr_All_Organization_Units HrOU
       ,Hr_Organization_Information HrOrgInfo
       ,Financials_System_Params_All Fso
       ,Ap_System_Parameters_All ASP
       ,Ar_System_Parameters_All ARP
       ,Zx_party_tax_profile ptp
WHERE
             XEP.legal_entity_id = HrOU.organization_id (+) --bug 4519314
AND          XEP.party_id = PTP.party_Id
AND          PTP.party_type_code = 'LEGAL_ESTABLISHMENT'
AND          decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id)
           = decode(l_multi_org_flag,'N',l_org_id,HrOrgInfo.organization_id(+))
AND          HrOrgInfo.Org_Information_Context = 'Legal Entity Accounting'
AND          decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id)
           = decode(l_multi_org_flag,'N',l_org_id,Fso.org_id(+))
AND          decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id)
           = decode(l_multi_org_flag,'N',l_org_id,ASP.org_id(+))
AND          HrOU.location_id = HrLoc.location_id (+)
AND          decode(l_multi_org_flag,'N',l_org_id,ASP.org_id)
           = decode(l_multi_org_flag,'N',l_org_id,ARP.org_id(+));

BEGIN

  arp_util_tax.debug('REG_REP_DRIVER_PROC(+)');

  ------------INITIALIZING THE FLAGS--------------------------------
  l_ins_flag_one:=FALSE;
  --------------Fetch all records into PL sql tables-----------------
  OPEN C_GET_REG_NUMBERS;

  LOOP

  FETCH C_GET_REG_NUMBERS BULK COLLECT INTO

	pg_org_reg_num_tab,
	pg_loc_reg_num_tab,
	pg_ar_sys_reg_num_tab,
	pg_fin_sys_reg_num_tab,
	ptp_tab,
	hr_rep_info_lat_tab,
	hr_rep_info_kor_tab,
	hr_rep_info_eur_grc_tab

	LIMIT C_LINES_PER_COMMIT;

  EXIT WHEN C_GET_REG_NUMBERS%NOTFOUND;

  END LOOP;

  CLOSE C_GET_REG_NUMBERS;

  FOR i IN 1..nvl(pg_org_reg_num_tab.last, 0)
  LOOP

	reg_num_tab(1) :=pg_org_reg_num_tab(i);
	reg_num_tab(2) :=pg_loc_reg_num_tab(i);
	reg_num_tab(3) :=pg_ar_sys_reg_num_tab(i);
	reg_num_tab(4) :=pg_fin_sys_reg_num_tab(i);

	l_ins_flag_one:=FALSE;

	FOR j in 1..4
	LOOP
	    IF  reg_num_tab(j) IS NOT NULL  THEN

	        ZX_CREATE_REP_TYPE_ASSOC
		   (reg_num_tab
		   ,j
		   ,ptp_tab(i)
		   ,hr_rep_info_lat_tab(i)
		   ,hr_rep_info_kor_tab(i)
		   ,hr_rep_info_eur_grc_tab(i)
		   ,pg_ar_sys_reg_num_tab(i)
		   ,pg_fin_sys_reg_num_tab(i));
             END IF;
	END LOOP;

  END LOOP;

  arp_util_tax.debug('REG_REP_DRIVER_PROC(-)');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
       arp_util_tax.debug('ERROR IN REG_REP_DRIVER_PROC');
END REG_REP_DRIVER_PROC;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    REG_REP_DRIVER_PROC_OU                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |              This procedure contains the acutal logic for deciding      |
 |              when to create a reporting type association .              |
 |                                                                         |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |              ZX_CREATE_REP_TYPE_ASSOC                                   |
 |                                                                         |
 |=========================================================================*/


 PROCEDURE REG_REP_DRIVER_PROC_OU(p_party_type_code zx_party_tax_profile.party_type_code%type)
 IS
 ---------------------Local variable declarations-----------------
 l_first_reg_val varchar2(160);
 l_position_first_reg NUMBER;
 C_LINES_PER_COMMIT   NUMBER := 1000;

 --------TABLE DECLARTIONS-----------------------------------
 pg_org_reg_num_tab              org_reg_num_tab;
 pg_loc_reg_num_tab              loc_reg_num_tab;
 pg_ar_sys_reg_num_tab           ar_sys_reg_num_tab;
 pg_fin_sys_reg_num_tab          fin_sys_reg_num_tab;
 reg_num_tab                     register_num_tab;
 ptp_tab                         party_tax_profile_tab;
 hr_rep_info_lat_tab             hr_org_rep_info_tab;
 hr_rep_info_kor_tab             hr_org_rep_info_tab;
 hr_rep_info_eur_grc_tab         hr_org_rep_info_tab;

 ---------------Cursor Declarations-----------------------------
CURSOR C_GET_REG_NUMBERS IS
SELECT
        HrOrgInfo.ORG_INFORMATION2                              ORG_REG_NUM,
        decode(HrLoc.GLOBAL_ATTRIBUTE_CATEGORY, 'JL.AR.PERWSLOC.LOC',
               HrLoc.Global_Attribute11,'JL.CL.PERWSLOC.LOC',
                        HrLoc.Global_Attribute1)                LOC_REG_NUM,
        ArSysParam.Tax_Registration_Number                      AR_SYS_REG_NUM,
        FinSysParam.Vat_Registration_Num                        FIN_SYS_REG_NUM,
        PTP.Party_Tax_Profile_Id                                PTP_ID,
        HrLoc.Global_Attribute11||HrLoc.Global_Attribute12      HR_REP_TYPE_INFO_LAT,
        HrLoc.Global_Attribute1                                 HR_REP_TYPE_INFO_KOR,
        HrLoc.Global_Attribute2                                 HR_REP_TYPE_INFO_EUR_GRC
FROM
        HR_ORGANIZATION_INFORMATION  HrOrgInfo,
        HR_LOCATIONS_ALL             HrLoc,
        FINANCIALS_SYSTEM_PARAMS_ALL FinSysParam,
        AR_SYSTEM_PARAMETERS_ALL     ArSysParam,
        HR_ALL_ORGANIZATION_UNITS    HrOrgUnits,
        ZX_PARTY_TAX_PROFILE         PTP
WHERE
        nvl(ptp.Party_Type_code,p_party_type_code)  = p_party_type_code
        and ptp.party_id (+)                        = HrOrgInfo.organization_id
        and decode(l_multi_org_flag,'N',l_org_id,HrOrgUnits.organization_id)  =
            decode(l_multi_org_flag,'N',l_org_id,HrOrgInfo.organization_id(+))
        and nvl(HrOrgInfo.ORG_INFORMATION_CONTEXT,'Legal Entity Accounting')  =
            'Legal Entity Accounting'
        and HrOrgUnits.location_id                 = HrLoc.location_id (+)
        and decode(l_multi_org_flag,'N',l_org_id,HrOrgUnits.organization_id) =
            decode(l_multi_org_flag,'N',l_org_id,ArSysParam.org_id(+))
        and decode(l_multi_org_flag,'N',l_org_id,HrOrgUnits.organization_id) =
            decode(l_multi_org_flag,'N',l_org_id,FinSysParam.org_id(+));

BEGIN
  arp_util_tax.debug('REG_REP_DRIVER_PROC_OU(+)');

  OPEN C_GET_REG_NUMBERS;

  LOOP

    FETCH C_GET_REG_NUMBERS BULK COLLECT INTO

        pg_org_reg_num_tab,
        pg_loc_reg_num_tab,
        pg_ar_sys_reg_num_tab,
        pg_fin_sys_reg_num_tab,
        ptp_tab,
        hr_rep_info_lat_tab,
        hr_rep_info_kor_tab,
        hr_rep_info_eur_grc_tab

        LIMIT C_LINES_PER_COMMIT;

    EXIT WHEN C_GET_REG_NUMBERS%NOTFOUND;

   END LOOP;

   CLOSE C_GET_REG_NUMBERS;

   FOR i IN 1..nvl(pg_org_reg_num_tab.last, 0) LOOP

      reg_num_tab(1) :=pg_org_reg_num_tab(i);
      reg_num_tab(2) :=pg_loc_reg_num_tab(i);
      reg_num_tab(3) :=pg_ar_sys_reg_num_tab(i);
      reg_num_tab(4) :=pg_fin_sys_reg_num_tab(i);

      FOR j in 1..4 LOOP

          IF  reg_num_tab(j) IS NOT NULL THEN

              ZX_CREATE_REP_TYPE_ASSOC
                       (reg_num_tab
                       ,j
                       ,ptp_tab(i)
                       ,hr_rep_info_lat_tab(i)
                       ,hr_rep_info_kor_tab(i)
                       ,hr_rep_info_eur_grc_tab(i)
                       ,pg_ar_sys_reg_num_tab(i)
                       ,pg_fin_sys_reg_num_tab(i));
          END IF;
      END LOOP;

   END LOOP;
   arp_util_tax.debug('REG_REP_DRIVER_PROC_OU(-)');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        arp_util_tax.debug('ERROR REG_REP_DRIVER_PROC_OU');
END REG_REP_DRIVER_PROC_OU;



/*===========================================================================+
|  Procedure  :     FIRST_PARTY_EXTRACT                               	    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		       profile migration which does the data                |
|		       migration for First party legal entitiy details.     |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES                                                                    |
|    								            |
|                                                                           |
|                                                                           |
|  History                                                                  |
|    zmohiudd	Tuesday, November 04,2003                                   |
|                                                                           |
|    									    |
+===========================================================================*/

	PROCEDURE FIRST_PARTY_EXTRACT(p_org_id in Number)
	IS

	BEGIN

	arp_util_tax.debug(' FIRST_PARTY_EXTRACT (+) ' );

			INSERT into
				ZX_PARTY_TAX_PROFILE(
				Party_Tax_Profile_Id,
				Party_Id,
				Party_Type_Code,
				Customer_Flag,
				First_Party_Le_Flag,
				Supplier_Flag,
				Site_Flag,
				Legal_Establishment_Flag,
				Rounding_Level_code,
				Process_For_Applicability_Flag ,
				ROUNDING_RULE_CODE,
				Inclusive_Tax_Flag,
				Use_Le_As_Subscriber_Flag,
				Reporting_Authority_Flag,
				Collecting_Authority_Flag,
				PROVIDER_TYPE_CODE,
				RECORD_TYPE_CODE,
				TAX_CLASSIFICATION_CODE,
				Self_Assess_Flag,
				Allow_Offset_Tax_Flag,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				ZX_PARTY_TAX_PROFILE_S.NEXTVAL
				,XEP.Party_ID -- Party_Id
				,'FIRST_PARTY' -- Party Type
				,'N' -- Customer_Flag
				,'Y' -- First Party LE Flag
				,'N' -- Supplier Flag
				,'N' -- Site_Flag
				,'N' -- Legal_Establishment_Flag
				,'HEADER' -- Rounding Level
				,'Y' -- Process_for_Applicability (Only for 3 Party)
				, Decode (FSO.TAX_ROUNDING_RULE, 'N', 'NEAREST','D','DOWN','UP') --ROUNDING_RULE_CODE
				,'N' -- Inclusive_Tax_Flag
				,'N' -- Use_Le_As_Subscriber_Flag
				,'N' --Reporting_Authority_Flag
				,'N' -- Collecting_Authority_Flag
				,'N' -- PROVIDER_TYPE_CODE
				, 'MIGRATED' -- RECORD_TYPE_CODE
				, nvl(HRloc.Tax_Name, Fso.Vat_Code) -- TAX_CLASSIFICATION_CODE
				,'N' -- Self_Assess_Flag
				,'N' -- Allow_Offset_Tax_Flag
				,Fnd_Global.User_Id
				,Sysdate
				,Fnd_Global.User_Id
				,Sysdate
				,Fnd_Global.Conc_Login_Id
				,1
			FROM
				xle_entity_profiles XEP,
				Hr_Locations_All HrLoc
				,Hr_All_Organization_Units HrOU
				,Financials_System_Params_All Fso
				WHERE
				HrOU.location_id = HrLoc.location_id (+)
				AND   decode(l_multi_org_flag,'N',l_org_id,HrOU.organization_id) = decode(l_multi_org_flag,'N',l_org_id,Fso.org_id(+))
				AND   decode(l_multi_org_flag,'N',l_org_id,HrOU.organization_id(+))  = XEP.legal_entity_id
				AND not exists ( select 1 from zx_party_tax_profile
			WHERE	party_id = XEP.Party_ID and Party_Type_Code = 'FIRST_PARTY'));

	arp_util_tax.debug(' FIRST_PARTY_EXTRACT (-) ' );

	EXCEPTION
		WHEN OTHERS THEN
    		   arp_util_tax.debug('Exception: Error Occurred during First party Extract in PTP/REGISTRATIONS Migration '||SQLERRM );

	END;


/*===========================================================================+
|  Procedure  :     LEGAL_ESTABLISHMENT                               	    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		       profile migration which does the data                |
|		       migration for Legal Establishment details.           |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES                                                                    |
|    								            |
|                                                                           |
|                                                                           |
|  History                                                                  |
|    zmohiudd	Tuesday, November 04,2003                                   |
|    Oct 24 Main Establishment Condition not needed                         |
|    									    |
+===========================================================================*/


PROCEDURE LEGAL_ESTABLISHMENT(p_org_id in NUMBER)
IS

   l_status fnd_module_installations.status%TYPE;
   l_db_status fnd_module_installations.DB_STATUS%TYPE;

BEGIN

   arp_util_tax.debug(' LEGAL_ESTABLISHMENT (+) ' );

   INSERT INTO ZX_PARTY_TAX_PROFILE
     (
      Party_Tax_Profile_Id,
      Party_Id,
      Rep_Registration_Number,
      Party_Type_code,
      Customer_Flag,
      First_Party_Le_Flag,
      Supplier_Flag,
      Site_Flag,
      Legal_Establishment_Flag,
      Rounding_Level_code,
      Process_For_Applicability_Flag ,
      ROUNDING_RULE_CODE,
      Inclusive_Tax_Flag,
      Use_Le_As_Subscriber_Flag,
      Reporting_Authority_Flag,
      Collecting_Authority_Flag,
      PROVIDER_TYPE_CODE,
      RECORD_TYPE_CODE,
      TAX_CLASSIFICATION_CODE,
      Self_Assess_Flag,
      Allow_Offset_Tax_Flag,
      Created_By,
      Creation_Date,
      Last_Updated_By,
      Last_Update_Date,
      Last_Update_Login,
      OBJECT_VERSION_NUMBER
     )
   SELECT
         ZX_PARTY_TAX_PROFILE_S.NEXTVAL
         ,XEP.Party_Id  --Party_Id
         --Bug 4361933
         ,nvl(hrorginfo.org_information2,
         nvl(decode(hrloc.GLOBAL_ATTRIBUTE_CATEGORY,
                  'JL.AR.PERWSLOC.LOC'
                  ,hrloc.Global_Attribute11||hrloc.Global_Attribute12,
                  'JL.CL.PERWSLOC.LOC'
                  ,hrloc.Global_Attribute11||hrloc.Global_Attribute12,
                  'JL.CO.PERWSLOC.LOC'
                  ,hrloc.Global_Attribute11||hrloc.Global_Attribute12,
                  'JA.KR.PERWSLOC.WITHHOLDING',hrloc.Global_Attribute1,
                  'JA.TW.PERWSLOC.LOC',hrloc.Global_Attribute1,
                  'JE.GR.PERWSLOC.LOC',hrloc.Global_Attribute2),
                  nvl(ARP.tax_registration_number, Fso.Vat_Registration_Num)))--REP_REGISTRATION_NUMBER
         ,'LEGAL_ESTABLISHMENT' -- Party Type
         ,'N' -- Customer_Flag
         ,'N' -- First Party LE Flag
         ,'N' -- Supplier Flag
         ,'N' --  Site_Flag
         ,'Y' -- Legal_Establishment_Flag
         ,'HEADER' -- Rounding Level
         ,'Y' -- Process_for_Applicability (Only for 3rd Party)
         ,Decode (FSO.TAX_ROUNDING_RULE, 'N', 'NEAREST','D','DOWN','UP') --ROUNDING_RULE_CODE
         ,ASP.Amount_Includes_Tax_Flag --INCLUSIVE_TAX_FLAG
         ,'N' -- Use_Le_As_Subscriber_Flag
         ,'N' --Reporting_Authority_Flag
         ,'N' -- Collecting_Authority_Flag
         ,'N' -- PROVIDER_TYPE_CODE
         ,'MIGRATED' -- RECORD_TYPE_CODE
         ,nvl(HRloc.Tax_Name, Fso.Vat_Code) --TAX_CLASSIFICATION_CODE
         ,'N' -- Self_Assess_Flag
         ,'N' -- Allow_Offset_Tax_Flag
         ,Fnd_Global.User_Id  -- Who Column
         ,Sysdate  -- Who Column
         ,Fnd_Global.User_Id  -- Who Column
         ,Sysdate  -- Who Column
         ,Fnd_Global.Conc_Login_Id  -- Who Column
         ,1
   FROM
        Hr_Locations_All HrLoc
       ,xle_etb_profiles XEP
       ,Hr_All_Organization_Units HrOU
       ,Hr_Organization_Information HrOrgInfo
       ,Financials_System_Params_All Fso
       ,Ap_System_Parameters_All ASP
       ,Ar_System_Parameters_All ARP
   WHERE
         XEP.legal_entity_id = HrOU.organization_id (+) --bug 4519314
         AND decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id) =
             decode(l_multi_org_flag,'N',l_org_id,HrOrgInfo.organization_id(+))
         AND HrOrgInfo.Org_Information_Context = 'Legal Entity Accounting'
         AND decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id) =
             decode(l_multi_org_flag,'N',l_org_id,Fso.org_id(+))
         AND decode(l_multi_org_flag,'N',l_org_id,HrOu.organization_id)=
             decode(l_multi_org_flag,'N',l_org_id,ASP.org_id(+))
         AND HrOU.location_id = HrLoc.location_id (+)
         AND decode(l_multi_org_flag,'N',l_org_id,ASP.org_id)  =
             decode(l_multi_org_flag,'N',l_org_id,ARP.org_id(+))
         AND NOT EXISTS
             (select 1 from zx_party_tax_profile where party_id = xep.party_id
              and party_type_code = 'LEGAL_ESTABLISHMENT');


   -- Remove logic to create  Associated Establishments' Business Organizations and locations
   -- this logic has been transfered to Legal Entity Team

--Bug 5228787
/*
   INSERT INTO ZX_REGISTRATIONS
     (
      Registration_Id,
      Registration_Type_Code,
      Registration_Number,
      Registration_Status_Code,
      Registration_Source_Code,
      Registration_Reason_Code,
      Party_Tax_Profile_Id,
      Tax_Authority_Id,
      Coll_Tax_Authority_Id,
      Rep_Tax_Authority_Id,
      Tax,
      Tax_Regime_Code,
      ROUNDING_RULE_CODE,
      Tax_Jurisdiction_Code,
      Self_Assess_Flag,
      Inclusive_Tax_Flag,
      Effective_From,
      Effective_To,
      Rep_Party_Tax_Name,
      Legal_Registration_Id,
      Default_Registration_Flag,
      BANK_ID,
      BANK_BRANCH_ID,
      BANK_ACCOUNT_NUM ,
      RECORD_TYPE_CODE,
      Created_By,
      Creation_Date,
      Last_Updated_By,
      Last_Update_Date,
      Last_Update_Login,
      OBJECT_VERSION_NUMBER)
   SELECT
         ZX_REGISTRATIONS_S.NEXTVAL
         ,Null -- Type
         ,ptp.rep_registration_number --Registration_Number
         ,'REGISTERED' -- Registration_Status_code
         ,'EXPLICIT'
         ,NULL -- Registration_Reason_Code
         ,PTP.Party_Tax_Profile_ID
         ,NULL -- Tax Authority ID
         ,NULL -- Collecting Tax Authority ID
         ,NULL -- Reporting Tax Authority ID
         ,NULL -- Tax
         ,NULL -- TAX Regime Code
         ,PTP.ROUNDING_RULE_CODE
         ,NULL -- Tax Jurisdiction Code
         ,PTP.Self_Assess_Flag  -- Self Assess
         ,PTP.Inclusive_Tax_Flag
         ,sysdate -- Effective from
         ,Null -- Effective to
         ,NULL -- Rep_Party_Tax_Name
         ,NULL -- Legal Registration_ID
         ,'Y'  -- Default Registration Flag
         ,hrloc.global_Attribute5
         ,hrloc.global_Attribute6
         ,hrloc.global_Attribute7
         ,'MIGRATED' -- Record Type
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,FND_GLOBAL.CONC_LOGIN_ID
         ,1
   FROM
        zx_party_tax_profile PTP,
        Hr_Locations_All HrLoc,
        Hr_All_Organization_Units hrou,
        Hr_Organization_Information hroi
   WHERE
         PTP.Party_Type_code = 'LEGAL_ESTABLISHMENT'
     and hrou.location_id= HrLoc.location_id (+)
     and decode(l_multi_org_flag,'N',l_org_id,HrOU.organization_id) =
         decode(l_multi_org_flag,'N',l_org_id,hroi.organization_id(+))
     AND HrOi.party_id = ptp.Party_id
     AND hrloc.global_attribute_category = 'JA.SG.PERWSLOC.LOC'
     and not exists (select 1 from zx_registrations
                      where party_tax_profile_id = ptp.party_tax_profile_id
                        and registration_number  = ptp.rep_registration_number);
*/

     ------Bugfix 3722296----------
     REG_REP_DRIVER_PROC('LEGAL_ESTABLISHMENT');
     ------------------------------


     -- Brazilian Tax Registation Number Upgrade

     BEGIN
       SELECT  STATUS, DB_STATUS
         INTO    l_status, l_db_status
         FROM    fnd_module_installations
        WHERE   APPLICATION_ID = '7004'
          and   MODULE_SHORT_NAME = 'jlbrloc';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
     arp_util_tax.debug('Exception: Error Occurred in Supplier sites Extract in PTP/REGISTRATIONS Migration '||SQLERRM );
     END;

    IF (nvl(l_status,'N') in ('I','S') or nvl(l_db_status,'N') in ('I','S')) THEN

    -- Inserts Records for CNPJ
       INSERT INTO ZX_REGISTRATIONS
         (
          Registration_Id,
          Registration_Type_Code,
          Registration_Number,
          Registration_Status_Code,
          Registration_Source_Code,
          Registration_Reason_Code,
          Party_Tax_Profile_Id,
          Tax_Authority_Id,
          Coll_Tax_Authority_Id,
          Rep_Tax_Authority_Id,
          Tax,
          Tax_Regime_Code,
          ROUNDING_RULE_CODE,
          Tax_Jurisdiction_Code,
          Self_Assess_Flag,
          Inclusive_Tax_Flag,
          Effective_From,
          Effective_To,
          Rep_Party_Tax_Name,
          Legal_Registration_Id,
          Default_Registration_Flag,
          RECORD_TYPE_CODE,
          Created_By,
          Creation_Date,
          Last_Updated_By,
          Last_Update_Date,
          Last_Update_Login,
          Object_Version_Number)
        SELECT
               ZX_REGISTRATIONS_S.NEXTVAL
               ,'CNPJ' -- Type
               ,jl.REGISTER_NUMBER||'/'||jl.REGISTER_SUBSIDIARY||'/'||jl.REGISTER_DIGIT Registration_Number
               ,'REGISTERED' -- Registration_Status_code
               ,'EXPLICIT'
               ,NULL -- Registration_Reason_Code
               ,PTP.Party_Tax_Profile_ID
               ,NULL -- Tax Authority ID
               ,NULL -- Collecting Tax Authority ID
               ,NULL -- Reporting Tax Authority ID
               ,NULL -- Tax
               ,'BR-IPI' -- Tax Regime Code
               ,PTP.ROUNDING_RULE_CODE
               , NULL -- Tax Jurisdiction Code
               ,PTP.Self_Assess_Flag  -- Self Assess
               ,PTP.Inclusive_Tax_Flag
               ,nvl(jl.CREATION_DATE, Sysdate) -- Effective from
               ,jl.INACTIVE_DATE -- Effective to
               ,NULL -- Rep_Party_Tax_Name
               ,NULL -- Legal Registration_ID
               ,'Y'  -- Default Registration Flag
               ,'MIGRATED' -- Record Type
               ,fnd_global.user_id
               ,SYSDATE
               ,fnd_global.user_id
               ,SYSDATE
               ,FND_GLOBAL.CONC_LOGIN_ID
               ,1
        FROM
               jl_br_company_infos jl
               ,gl_ledger_le_v gl
               ,xle_etb_profiles etb
               ,zx_party_tax_profile ptp
        WHERE
               jl.INACTIVE_DATE is null
          and  jl.set_of_books_id = gl.ledger_id
          and  etb.legal_entity_id = gl.legal_entity_id
          and  etb.party_id = ptp.party_id
          and  ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
          AND  NOT EXISTS (SELECT 1 FROM zx_registrations
                            WHERE party_tax_profile_id = ptp.party_tax_profile_id
                              AND Registration_Type_Code = 'CNPJ'
                              AND tax_regime_code = 'BR-IPI' );

    -- update rep_registation_number
    Update zx_party_tax_profile ptp
       Set    rep_registration_number =
         (Select  registration_number
            from   zx_registrations reg
           where   reg.party_tax_profile_id = ptp.party_tax_profile_id
             and   Registration_Type_Code = 'CNPJ'
             and   tax_regime_code = 'BR-IPI')
    Where  ptp.party_tax_profile_id =
         (Select reg.party_tax_profile_ID
            from   zx_registrations reg
           where   reg.party_tax_profile_id = ptp.party_tax_profile_id
             and   Registration_Type_Code = 'CNPJ'
             and   tax_regime_code = 'BR-IPI');

   -- Inserts Records for CNPJ
   INSERT INTO ZX_REGISTRATIONS
     (
      Registration_Id,
      Registration_Type_Code,
      Registration_Number,
      Registration_Status_Code,
      Registration_Source_Code,
      Registration_Reason_Code,
      Party_Tax_Profile_Id,
      Tax_Authority_Id,
      Coll_Tax_Authority_Id,
      Rep_Tax_Authority_Id,
      Tax,
      Tax_Regime_Code,
      ROUNDING_RULE_CODE,
      Tax_Jurisdiction_Code,
      Self_Assess_Flag,
      Inclusive_Tax_Flag,
      Effective_From,
      Effective_To,
      Rep_Party_Tax_Name,
      Legal_Registration_Id,
      Default_Registration_Flag,
      RECORD_TYPE_CODE,
      Created_By,
      Creation_Date,
      Last_Updated_By,
      Last_Update_Date,
      Last_Update_Login,
      Object_Version_Number)
   SELECT
          ZX_REGISTRATIONS_S.NEXTVAL
          ,'STATE INSCRIPTION' -- Type
          ,jl.STATE_INSCRIPTION -- Registration_Number
          ,'REGISTERED' -- Registration_Status_code
          ,'EXPLICIT'
          ,NULL -- Registration_Reason_Code
          ,PTP.Party_Tax_Profile_ID
          ,NULL -- Tax Authority ID
          ,NULL -- Collecting Tax Authority ID
          ,NULL -- Reporting Tax Authority ID
          ,NULL -- Tax
          ,'BR-ICMS' -- Tax Regime Code
          ,PTP.ROUNDING_RULE_CODE
          , NULL -- Tax Jurisdiction Code
          , PTP.Self_Assess_Flag  -- Self Assess
          ,PTP.Inclusive_Tax_Flag
          ,nvl(jl.CREATION_DATE, Sysdate) -- Effective from
          ,jl.INACTIVE_DATE -- Effective to
          ,NULL -- Rep_Party_Tax_Name
          ,NULL -- Legal Registration_ID
          ,'Y'  -- Default Registration Flag
          ,'MIGRATED' -- Record Type
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,FND_GLOBAL.CONC_LOGIN_ID
          ,1
    FROM
          jl_br_company_infos jl
          ,gl_ledger_le_v gl
          ,xle_etb_profiles etb
          ,zx_party_tax_profile ptp
    WHERE
          jl.INACTIVE_DATE is null
      and jl.set_of_books_id = gl.ledger_id
      and etb.legal_entity_id = gl.legal_entity_id
      and etb.party_id = ptp.party_id
      and ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
      AND NOT EXISTS (SELECT 1 FROM zx_registrations
                       WHERE party_tax_profile_id = ptp.party_tax_profile_id
                         AND Registration_Type_Code = 'STATE INSCRIPTION'
                         AND tax_regime_code = 'BR-ICMS');

    INSERT INTO ZX_REGISTRATIONS
      (
       Registration_Id,
       Registration_Type_Code,
       Registration_Number,
       Registration_Status_Code,
       Registration_Source_Code,
       Registration_Reason_Code,
       Party_Tax_Profile_Id,
       Tax_Authority_Id,
       Coll_Tax_Authority_Id,
       Rep_Tax_Authority_Id,
       Tax,
       Tax_Regime_Code,
       ROUNDING_RULE_CODE,
       Tax_Jurisdiction_Code,
       Self_Assess_Flag,
       Inclusive_Tax_Flag,
       Effective_From,
       Effective_To,
       Rep_Party_Tax_Name,
       Legal_Registration_Id,
       Default_Registration_Flag,
       RECORD_TYPE_CODE,
       Created_By,
       Creation_Date,
       Last_Updated_By,
       Last_Update_Date,
       Last_Update_Login,
       OBJECT_VERSION_NUMBER)
    SELECT
           ZX_REGISTRATIONS_S.NEXTVAL
           ,'CITY INSCRIPTION' -- Type
           ,jl.MUNICIPAL_INSCRIPTION -- Registration_Number
           ,'REGISTERED' -- Registration_Status_code
           ,'EXPLICIT'
           ,NULL -- Registration_Reason_Code
           ,PTP.Party_Tax_Profile_ID
           ,NULL -- Tax Authority ID
           ,NULL -- Collecting Tax Authority ID
           ,NULL -- Reporting Tax Authority ID
           ,NULL -- Tax
           ,'BR-ISS' -- Tax Regime Code
           ,PTP.ROUNDING_RULE_CODE
           ,NULL -- Tax Jurisdiction Code
           ,PTP.Self_Assess_Flag  -- Self Assess
           ,PTP.Inclusive_Tax_Flag
           ,nvl(jl.CREATION_DATE, Sysdate) -- Effective from
           ,jl.INACTIVE_DATE -- Effective to
           ,NULL -- Rep_Party_Tax_Name
           ,NULL -- Legal Registration_ID
           ,'Y'  -- Default Registration Flag
           ,'MIGRATED' -- Record Type
           ,fnd_global.user_id
           ,SYSDATE
           ,fnd_global.user_id
           ,SYSDATE
           ,FND_GLOBAL.CONC_LOGIN_ID
           ,1
      FROM
           jl_br_company_infos jl
           ,gl_ledger_le_v gl
           ,xle_etb_profiles etb
           ,zx_party_tax_profile ptp
     WHERE
           jl.INACTIVE_DATE is null
       and jl.set_of_books_id = gl.ledger_id
       and etb.legal_entity_id = gl.legal_entity_id
       and etb.party_id = ptp.party_id
       and ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
       AND NOT EXISTS (SELECT 1 FROM zx_registrations
                        WHERE party_tax_profile_id = ptp.party_tax_profile_id
                          AND registration_type_code = 'CITY INSCRIPTION'
                          AND tax_regime_code = 'BR-ISS');


   END IF; --  (nvl(l_status,'N') = 'Y' or  nvl(l_db_status,'N') = 'Y') Brazil Localizations
   -- Brazilian Tax Registation Number Upgrade

   arp_util_tax.debug(' LEGAL_ESTABLISHMENT (-) ' );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        arp_util_tax.debug('Exception: Error Occurred during Legal Establishment Extract in PTP/REGISTRATIONS Migration '||SQLERRM );
END LEGAL_ESTABLISHMENT;

/*===========================================================================+
|  Procedure  :     SUPPLIER_EXTRACT                               	    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		       profile migration which does the data                |
|		       migration for Supplier details.               	    |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES                                                                    |
|    								            |
|                                                                           |
|                                                                           |
|  History                                                                  |
|    zmohiudd	Tuesday, November 04,2003                                   |
|    Venkat     4th May 04	Bug # 3594759				    |
|    									    |
+===========================================================================*/

	PROCEDURE SUPPLIER_EXTRACT(p_party_id in NUMBER, p_org_id in NUMBER)
	IS


	---Commenting out this cursor declaration as it is not being used anywhere in the procedure
	---Bug 4054883

	/*CURSOR C_SUPPLIER_TYPE IS
	SELECT  POV.VENDOR_ID
	FROM	ap_suppliers POV , ZX_PARTY_TAX_PROFILE PTP
	WHERE   POV.VENDOR_ID  = PTP.PARTY_ID
		AND PTP.PARTY_TYPE_CODE = 'SUPPLIER'
		AND VENDOR_TYPE_LOOKUP_CODE is not null
		AND VENDOR_TYPE_LOOKUP_CODE <> 'TAX AUTHORITY';*/

	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;


	BEGIN

	arp_util_tax.debug(' SUPPLIER_EXTRACT(+) ' );

/*
 The logic to create PTPs for suppliers is  to loop through po_vendors based on
 po_vendors.party_id. TRN will be stored in zx_party_tax_profile it self. In
 this case no records will be created in zx_registrations.
*/
/*
Bug 4317072 as per this bug we would no longer be requiring the ad_parallel_update feature in the pls file
Separate scripts have been written to deal with this feature
*/
			INSERT INTO
				ZX_PARTY_TAX_PROFILE(
				 Party_Tax_Profile_Id
				,Party_Id
				,Rep_Registration_Number
				,Party_Type_code
				,Customer_Flag
				,First_Party_Le_Flag
				,Supplier_Flag
				,Site_Flag
				,Legal_Establishment_Flag
				,Rounding_Level_code
				,Process_For_Applicability_Flag
				,ROUNDING_RULE_CODE
				,Inclusive_Tax_Flag
				,Use_Le_As_Subscriber_Flag
				,Effective_From_Use_Le
				,Reporting_Authority_Flag
				,Collecting_Authority_Flag
				,PROVIDER_TYPE_CODE
				,RECORD_TYPE_CODE
				,TAX_CLASSIFICATION_CODE
				,Self_Assess_Flag
				,Allow_Offset_Tax_Flag
				,Created_By
				,Creation_Date
				,Last_Updated_By
				,Last_Update_Date
				,Last_Update_Login
				,OBJECT_VERSION_NUMBER)
			(SELECT
				ZX_PARTY_TAX_PROFILE_S.NEXTVAL
				,PARTY_ID -- Party ID
				,decode(pv.GLOBAL_ATTRIBUTE_CATEGORY,
				'JL.AR.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				'JL.CL.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				'JL.CO.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				pv.VAT_Registration_Num) -- Reg Num
				,'THIRD_PARTY' -- Party Type
				,'N' -- Customer_Flag
				,'N' -- First Party Flag
				,'Y' -- Supplier Flag
				,'N' -- Site Flag
				,'N' -- Establishment Flag
				,decode(nvl(auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE')
				,decode(nvl(auto_tax_calc_flag, 'N'), 'N', 'N', 'Y')
				,DECODE (AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN','UP')
				,nvl(amount_includes_tax_flag,'N')
				,'N' -- Use_Le_As_Subscriber_Flag
				,NULL -- Effective_From_Use_Le
				,'N' -- Reporting Authority Flag
				,'N'  -- Collecting Authority Flag
				,NULL -- Provider Type
				,'MIGRATED' -- Record Type
				,vat_code -- 	Tax Classification
				,'N' -- Self_Assess_Flag
				,nvl(offset_tax_flag,'N') -- Allow_Offset_Tax_Flag
				,fnd_global.user_id 	-- Who Columns
				,SYSDATE 		-- Who Columns
				,fnd_global.user_id 	-- Who Columns
				,SYSDATE 		-- Who Columns
				,FND_GLOBAL.CONC_LOGIN_ID   -- Who Columns
				, 1
			FROM     ap_suppliers PV
			WHERE VENDOR_ID = nvl(p_party_ID,VENDOR_ID)
				AND not exists (select 1 from zx_party_tax_profile
				where party_id = PV.party_id  and Party_Type_Code = 'THIRD_PARTY'));


/*
			INSERT INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
		 	(SELECT
				ZX_REGISTRATIONS_S.NEXTVAL
				,Null -- Type
				,decode(pv.GLOBAL_ATTRIBUTE_CATEGORY,
				'JL.AR.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				'JL.CL.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				'JL.CO.APXVDMVD.SUPPLIERS',pv.Global_Attribute12||pv.num_1099,
				pv.VAT_Registration_Num) -- Reg Num
				--Bug # 3594759
				,decode(pv.GLOBAL_ATTRIBUTE_CATEGORY,
				'JL.AR.APXVDMVD.SUPPLIERS',pv.Global_Attribute1,
				'REGISTERED') -- Registration_Status_code
				,'EXPLICIT' -- Registration_Source_Code
				,NULL -- Registration_Reason_Code
				,PTP.Party_Tax_Profile_ID
				,NULL -- Tax Authority ID
				,NULL -- Collecting Tax Authority ID
				,NULL -- Reporting Tax Authority ID
				,NULL -- Tax
				,NULL -- TAX_Regime_Code
				,PTP.ROUNDING_RULE_CODE
				, NULL -- Tax Jurisdiction Code
				, PTP.Self_Assess_Flag  -- Self Assess
				,PTP.Inclusive_Tax_Flag
				,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
				,PV.End_Date_Active -- Effective to
				,NULL -- Rep_Party_Tax_Name
				,NULL -- Legal Registration_ID
				,'Y'  -- Default Registration Flag
				,'MIGRATED' -- Record Type
				,fnd_global.user_id
				,SYSDATE
				,fnd_global.user_id
				,SYSDATE
				,FND_GLOBAL.CONC_LOGIN_ID
				,1
			FROM	ap_suppliers PV,
				zx_party_tax_profile PTP
			WHERE
				PV.Party_id = PTP.Party_ID
				AND PTP.Party_Type_code = 'SUPPLIER'
				and not exists (select 1 from zx_registrations
				WHERE party_tax_profile_id = ptp.party_tax_profile_id));
*/

	-- Bug # 3594759
	-- Verify Argentina Installation
	SELECT STATUS, DB_STATUS
	INTO l_status, l_db_status
	FROM  fnd_module_installations
	WHERE APPLICATION_ID = '7004'
	   And MODULE_SHORT_NAME = 'jlarloc';

	IF (nvl(l_status,'N') in ('I','S') or
	 nvl(l_db_status,'N') in ('I','S')) THEN

		-- Code to migrate the lookup code for the Lookup Type
		-- JLZZ_AP_VAT_REG_STAT_CODE into
		-- ZX_REGISTRATIONS_STATUS lookup type
		insert into fnd_lookup_values(
			LOOKUP_TYPE,
			LANGUAGE,
			LOOKUP_CODE,
			MEANING,
			DESCRIPTION,
			ENABLED_FLAG,
			START_DATE_ACTIVE,
			END_DATE_ACTIVE,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			LAST_UPDATE_DATE,
			SOURCE_LANG,
			SECURITY_GROUP_ID,
			VIEW_APPLICATION_ID,
			TERRITORY_CODE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15)
		(select
			'ZX_REGISTRATIONS_STATUS',
			LANGUAGE,
			LOOKUP_CODE,
			MEANING,
			DESCRIPTION,
			ENABLED_FLAG,
			START_DATE_ACTIVE,
			END_DATE_ACTIVE,
			fnd_global.user_id,
			SYSDATE,
			fnd_global.user_id,
			fnd_global.conc_login_id,
			SYSDATE,
			SOURCE_LANG,
			SECURITY_GROUP_ID,
			VIEW_APPLICATION_ID,
			TERRITORY_CODE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		FROM
			FND_LOOKUP_VALUES fnd
		WHERE
			fnd.LOOKUP_TYPE = 'JLZZ_AP_VAT_REG_STAT_CODE'
		AND NOT EXISTS
		 	( select 1 from FND_LOOKUP_VALUES
			  where  lookup_type = 'JLZZ_AP_VAT_REG_STAT_CODE' and
			         lookup_code = fnd.lookup_code) );

     	END IF;

	arp_util_tax.debug(' Now calling SUPPLIER_TYPE_EXTRACT ' );

	ZX_PTP_MIGRATE_PKG.SUPPLIER_TYPE_EXTRACT;


	arp_util_tax.debug(' Now calling SUPPLIER_ASSOC_EXTRACT ' );

		ZX_PTP_MIGRATE_PKG.SUPPLIER_ASSOC_EXTRACT;

	arp_util_tax.debug(' SUPPLIER_EXTRACT(-) ' );

	EXCEPTION
		WHEN OTHERS THEN
    		   arp_util_tax.debug('Exception: Error Occurred during Supplier extract in PTP/REGISTRATIONS Migration '||SQLERRM );

	END; -- End Suppliers Migration

--	Supplier Sites Migration

/*===========================================================================+
|  Procedure  :     SUPPLIER_SITE_EXTRACT                                   |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		       profile migration which does the data                |
|		       migration for Supplier site details.                 |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES                                                                    |
|    								            |
|                                                                           |
|                                                                           |
|  History                                                                  |
|    zmohiudd	Tuesday, November 04,2003                                   |
|    Venkat     4th May 04	Added code for Reporting Code Association   |
|    				Bug # 3594759				    |
+===========================================================================*/


	PROCEDURE SUPPLIER_SITE_EXTRACT(p_party_id in NUMBER, p_org_id in Number) IS

	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;


	BEGIN

	    arp_util_tax.debug(' SUPPLIER_SITE_EXTRACT(+) ' );

/*
Bug 4317072 as per this bug we would no longer be requiring the ad_parallel_update feature in the pls file
Separate scripts have been written to deal with this feature
*/

/*
 In case one party_site_id has multiple records in po_vendor_sites, we will
 group the tax attributes to determine if all of the are the same, if all
 attributes are the same we will create only one PTP for that party_site_id,
 with all tax attributes coming from po_vendor_sites. If the attributes are
 different we will create one PTP row for the first record coming in the query
 and  TR records for all other po_vendor_sites records.
*/

   INSERT ALL
	WHEN COUNT = 1
	THEN
            INTO
				ZX_PARTY_TAX_PROFILE(
				 Party_Tax_Profile_Id
				,Party_Id
				,Rep_Registration_Number
				,Party_Type_code
				,Customer_Flag
				,First_Party_Le_Flag
				,Supplier_Flag
				,Site_Flag
				,Legal_Establishment_Flag
				,Rounding_Level_code
				,Process_For_Applicability_Flag
				,ROUNDING_RULE_CODE
				,Inclusive_Tax_Flag
				,Use_Le_As_Subscriber_Flag
				,Effective_From_Use_Le
				,Reporting_Authority_Flag
				,Collecting_Authority_Flag
				,PROVIDER_TYPE_CODE
				,RECORD_TYPE_CODE
				,TAX_CLASSIFICATION_CODE
				,Self_Assess_Flag
				,Allow_Offset_Tax_Flag
				,Created_By
				,Creation_Date
				,Last_Updated_By
				,Last_Update_Date
				,Last_Update_Login
				,Object_Version_Number)

		    VALUES(
		          ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
		          PARTY_SITE_ID,
		          VAT_REGISTRATION_NUM
	          	,'THIRD_PARTY_SITE' -- Party Type
			,'N' -- Customer_Flag
			,'N' -- First Party Flag
			,'N' -- Supplier Flag
			,'Y' -- Site Flag
			,'N' -- Establishment Flag
                	,ROUNDING_LEVEL_CODE
	                ,PROCESS_FOR_APPLICABILITY_FLAG
        	        ,ROUNDING_RULE_CODE
                	,INCLUSIVE_TAX_FLAG
	              	,'N' -- Use_Le_As_Subscriber_Flag
			,NULL -- Effective_From_Use_Le
			,'N' -- Reporting Authority Flag
			,'N'  -- Collecting Authority Flag
			,NULL -- Provider Type
			,'MIGRATED' -- Record Type
        	        ,VAT_CODE
                	,'N'
	                ,ALLOW_OFFSET_TAX_FLAG
        	       ,fnd_global.user_id 	-- Who Columns
			,SYSDATE 		-- Who Columns
			,fnd_global.user_id 	-- Who Columns
			,SYSDATE 		-- Who Columns
			,FND_GLOBAL.CONC_LOGIN_ID   -- Who Columns
			,1)
			(SELECT
				 PVS.PARTY_SITE_ID  PARTY_SITE_ID-- Party ID
				,PVS.Vat_Registration_Num VAT_REGISTRATION_NUM
				,decode(nvl(PVS.auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE') ROUNDING_LEVEL_CODE
				,decode(nvl(PVS.auto_tax_calc_flag, 'N'), 'N', 'N', 'Y') PROCESS_FOR_APPLICABILITY_FLAG
				,DECODE (PVS.AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN','UP') ROUNDING_RULE_CODE
				,nvl(PVS.amount_includes_tax_flag,'N') INCLUSIVE_TAX_FLAG
				,PVS.vat_code -- 	Tax Classification
				,nvl(PVS.offset_tax_flag,'N') ALLOW_OFFSET_TAX_FLAG -- Allow_Offset_Tax_Flag
				, rank() OVER(PARTITION BY PVS.PARTY_SITE_ID ORDER BY PVS.VENDOR_SITE_ID ) COUNT

 			FROM
				 ap_suppliers  PV,
				 ap_supplier_sites_all PVS
			WHERE
				 PVS.VENDOR_SITE_ID = nvl(p_party_id,PVS.VENDOR_SITE_ID)  --this condition is for the sync process
                  	     AND PV.VENDOR_ID = PVS.VENDOR_ID
	             AND NOT EXISTS
        		       ( select 1 from zx_party_tax_profile
				WHERE party_id = pvs.PARTY_SITE_ID and Party_Type_Code = 'THIRD_PARTY_SITE'));


/*
Bug 4317072 as per this bug we would no longer be requiring the ad_parallel_update feature in the pls file
Separate scripts have been written to deal with this feature
*/
/*Commenting out the following code on account of bug 4378828*/
/*

	INSERT  ALL
		 WHEN (COUNTER > 1) then
		   INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Account_Id,
				Account_Site_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				Object_Version_Number)
			values
			(
			ZX_REGISTRATIONS_S.NEXTVAL,
			NULL,  --Registration_Type_Code
			Registration_Number ,
			Registration_Status_Code,
			'EXPLICIT' , -- Registration_Source_Code
			 NULL       , -- Registration_Reason_Code
			 PARTY_TAX_PROFILE_ID,
			 ACCOUNT_ID,
			 ACCOUNT_SITE_ID,
			 NULL -- Tax Authority ID
			,NULL -- Collecting Tax Authority ID
			,NULL -- Reporting Tax Authority ID
			,NULL -- Tax
			,NULL -- TAX_Regime_Code
			,ROUNDING_RULE_CODE
			, NULL -- Tax Jurisdiction Code
			,SELF_ASSESS_FLAG
			,INCLUSIVE_TAX_FLAG
			,EFFECTIVE_FROM
			,EFFECTIVE_TO
			,NULL -- Rep_Party_Tax_Name
			,NULL -- Legal Registration_ID
			,'Y'  -- Default Registration Flag
			,'MIGRATED' -- Record Type
			,fnd_global.user_id
			,SYSDATE
			,fnd_global.user_id
			,SYSDATE
			,FND_GLOBAL.CONC_LOGIN_ID
			,1
			)

		 	(SELECT
				decode(pv.GLOBAL_ATTRIBUTE_CATEGORY,
				'JL.AR.APXVDMVD.SUPPLIERS',pv.Global_Attribute12,
				'JL.CL.APXVDMVD.SUPPLIERS',pv.Global_Attribute12,
				'JL.CO.APXVDMVD.SUPPLIERS',pv.Global_Attribute12,
				pv.VAT_Registration_Num)  Registration_Number-- Reg Num
				--Bug # 3594759
				,decode(pv.GLOBAL_ATTRIBUTE_CATEGORY,
				'JL.AR.APXVDMVD.SUPPLIERS',pv.Global_Attribute1,
				'REGISTERED')  Registration_Status_Code-- Registration_Status_code
				,PTP.Party_Tax_Profile_ID PARTY_TAX_PROFILE_ID
				,pv.vendor_id ACCOUNT_ID
				,pvs.vendor_site_id ACCOUNT_SITE_ID
				,PTP.ROUNDING_RULE_CODE ROUNDING_RULE_CODE
				, PTP.Self_Assess_Flag   SELF_ASSESS_FLAG -- Self Assess
				,PTP.Inclusive_Tax_Flag  INCLUSIVE_TAX_FLAG
				,nvl(PV.Start_Date_Active, Sysdate) EFFECTIVE_FROM-- Effective from
				,PV.End_Date_Active EFFECTIVE_TO-- Effective to
				,counter

			FROM
				ap_suppliers   pv,
				ap_supplier_sites_all pvs,
				zx_party_tax_profile PTP,
				(select party_site_id,
				 COUNT
             			   (DISTINCT(PARTY_SITE_ID||AMOUNT_INCLUDES_TAX_FLAG
           			 ||AP_TAX_ROUNDING_RULE||AUTO_TAX_CALC_FLAG||OFFSET_TAX_FLAG||VAT_CODE||VAT_REGISTRATION_NUM) ) Counter
              			  FROM
           			     ap_supplier_sites_all
              			  group by party_site_id
               			 ) tax_attr_tab
			WHERE
		                  pv.vendor_id = pvs.vendor_id
			AND   PTP.party_id  =   pvs.party_site_id
			AND   tax_attr_tab.party_site_id = pvs.party_site_id
			AND   PTP.Party_Type_code = 'SUPPLIER_SITE'
				and not exists (select 1 from zx_registrations
				WHERE party_tax_profile_id = ptp.party_tax_profile_id));
*/


	 	/*        INSERT INTO
				ZX_PARTY_TAX_PROFILE(
				Party_Tax_Profile_Id
				,Party_Id
				,Party_Type_code
				,Customer_Flag
				,First_Party_Le_Flag
				,Supplier_Flag
				,Site_Flag
				,Legal_Establishment_Flag
				,Rounding_Level_code
				,Process_For_Applicability_Flag
				,ROUNDING_RULE_CODE
				,Inclusive_Tax_Flag
				,Use_Le_As_Subscriber_Flag
				,Effective_From_Use_Le
				,Reporting_Authority_Flag
				,Collecting_Authority_Flag
				,PROVIDER_TYPE_CODE
				,RECORD_TYPE_CODE
				,TAX_CLASSIFICATION_CODE
				,Self_Assess_Flag
				,Allow_Offset_Tax_Flag
				,Created_By
				,Creation_Date
				,Last_Updated_By
				,Last_Update_Date
				,Last_Update_Login
				,OBJECT_VERSION_NUMBER)
      			(SELECT
				ZX_PARTY_TAX_PROFILE_S.NEXTVAL
				,pvs.VENDOR_SITE_ID -- Party ID
				,'SUPPLIER_SITE' -- Party Type
				,'N' -- Customer_Flag
				,'N' -- First Party Flag
				,'Y' -- Supplier Flag
				,'Y' -- Site Flag
				,'N' -- Establishment Flag
				,decode(nvl(pvs.auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE')
				,decode(nvl(pvs.auto_tax_calc_flag, 'N'), 'N', 'N', 'Y')
				, DECODE (pvs.AP_TAX_ROUNDING_RULE,'N','NEAREST',
							'D','DOWN', 'UP')
				, nvl(pvs.amount_includes_tax_flag, 'N')
				,'N' -- Use_Le_As_Subscriber_Flag
				, NULL -- Effective_From_Use_Le
				,'N' -- Reporting Authority Flag
				,'N'  -- Collecting Authority Flag
				,NULL -- Provider Type
				,'MIGRATED' -- Record Type
				,pvs.vat_code -- 	Tax Classification
				,'N' -- Self_Assess_Flag
				, nvl(pv.offset_tax_flag,'N') -- Allow_Offset_Tax_Flag
				, fnd_global.user_id 	-- Who Columns
				,SYSDATE 		-- Who Columns
				,fnd_global.user_id 	-- Who Columns
				,SYSDATE 		-- Who Columns
				,FND_GLOBAL.CONC_LOGIN_ID   -- Who Columns
				,1
			FROM    ap_supplier_sites_all Pvs,
				ap_suppliers Pv
			WHERE   pvs.Vendor_Site_Id = nvl(P_Party_Id,pvs.Vendor_site_Id)
				AND pvs.vendor_id = pv.vendor_id
				AND not exists ( select 1 from zx_party_tax_profile
				WHERE party_id = pvs.VENDOR_SITE_ID and Party_Type_Code = 'SUPPLIER_SITE'));


			INSERT INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				ZX_REGISTRATIONS_S.NEXTVAL
				,NULL -- Type
				,PVS.VAT_Registration_Num --Reg Number
				,'REGISTERED' -- Registration_Status_code
				,'EXPLICIT' -- Registration_Source_Code
				,NULL -- Registration_Reason_Code
				,PTP.Party_Tax_Profile_ID
				,NULL -- Tax Authority ID
				,NULL -- Collecting Tax Authority ID
				,NULL -- Reporting Tax Authority ID
				,NULL -- Tax
				,NULL -- TAX_Regime_Code
				,PTP.ROUNDING_RULE_CODE
				, NULL -- Tax Jurisdiction Code
				, PTP.Self_Assess_Flag  -- Self Assess
				,PTP.Inclusive_Tax_Flag
				,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
				,PV.End_Date_Active -- Effective to
				,NULL -- Rep_Party_Tax_Name
				,NULL -- Legal Registration_ID
				,'Y'  -- Default Registration Flag
				,'MIGRATED' -- Record Type
				,fnd_global.user_id
				,SYSDATE
				,fnd_global.user_id
				,SYSDATE
				,FND_GLOBAL.CONC_LOGIN_ID
				,1
			   FROM  ap_supplier_sites_all PVS,
				 ap_suppliers PV,
				 zx_party_tax_profile PTP
			   WHERE
				PVS.vendor_site_id = PTP.Party_ID
				AND PTP.Party_Type_code = 'SUPPLIER_SITE'
				AND PVS.Vendor_ID = PV.Vendor_ID
				AND NOT EXISTS (SELECT 1 FROM zx_registrations
                                		WHERE party_tax_profile_id = ptp.party_tax_profile_id
						AND Registration_Type_Code is null));*/

--Commenting out this code since Brazilian GDFs are not being migrated as per bug 4054883*/
/*
-- Verify Brazil Installation

		BEGIN

			SELECT	STATUS, DB_STATUS
			INTO 	l_status, l_db_status
			FROM  	fnd_module_installations
			WHERE	APPLICATION_ID = '7004'
	          		and MODULE_SHORT_NAME = 'jlbrloc';

		EXCEPTION

	          WHEN OTHERS THEN
			arp_util_tax.debug('Exception: Error Occurred in Supplier sites Extract in PTP/REGISTRATIONS Migration '||SQLERRM );

		END;


		IF (nvl(l_status,'N') in ('I','S') or nvl(l_db_status,'N') in ('I','S')) THEN


		-- Inserts Records for CNPJ
			INSERT INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				Object_Version_Number)
		 	(SELECT
				ZX_REGISTRATIONS_S.NEXTVAL
				,'CNPJ' -- Type
				,PVS.Global_Attribute10||' / '||PVS.Global_Attribute11||' / '||PVS.Global_Attribute12 --Reg Number
				,'REGISTERED' -- Registration_Status_code
				,'EXPLICIT'
				,NULL -- Registration_Reason_Code
				,PTP.Party_Tax_Profile_ID
				,NULL -- Tax Authority ID
				,NULL -- Collecting Tax Authority ID
				,NULL -- Reporting Tax Authority ID
				,NULL -- Tax
				,'BR-IPI' -- Tax Regime Code
				,PTP.ROUNDING_RULE_CODE
				, NULL -- Tax Jurisdiction Code
				, PTP.Self_Assess_Flag  -- Self Assess
				,PTP.Inclusive_Tax_Flag
				,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
				,PV.End_Date_Active -- Effective to
				,NULL -- Rep_Party_Tax_Name
				,NULL -- Legal Registration_ID
				,'Y'  -- Default Registration Flag
				,'MIGRATED' -- Record Type
				,fnd_global.user_id
				,SYSDATE
				,fnd_global.user_id
				,SYSDATE
				,FND_GLOBAL.CONC_LOGIN_ID
				,1
			FROM	ap_supplier_sites_all PVS,
				ap_suppliers PV,
				zx_party_tax_profile PTP
			WHERE
				PVS.vendor_site_id = PTP.Party_ID
				AND PTP.Party_Type_code = 'SUPPLIER_SITE'
				AND PVS.Vendor_ID = PV.Vendor_ID
				AND pvs.GLOBAL_ATTRIBUTE_CATEGORY =  'JL.BR.APXVDMVD.SITES'
				AND NOT EXISTS (SELECT 1 FROM zx_registrations
                                                WHERE party_tax_profile_id = ptp.party_tax_profile_id
                                                AND Registration_Type_Code = 'CNPJ'
						AND tax_regime_code = 'BR-IPI' ));

	-- Inserts Records for State Inscription

			INSERT INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				ZX_REGISTRATIONS_S.NEXTVAL
				,'STATE INSCRIPTION' -- Type
				,PVS.Global_Attribute13 -- State Registration Num
				,'REGISTERED' -- Registration_Status_Code
				,'EXPLICIT'
				,NULL -- Registration_Reason_Code
				,PTP.Party_Tax_Profile_ID
				,NULL -- Tax Authority ID
				,NULL -- Collecting Tax Authority ID
				,NULL -- Reporting Tax Authority ID
				,NULL -- Tax
				,'BR-ICMS' -- Tax_Regime_Code
				,PTP.ROUNDING_RULE_CODE
				, NULL -- Tax Jurisdiction Code
				, PTP.Self_Assess_Flag -- Self Asses
				,PTP.Inclusive_Tax_Flag
				,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
				,PV.End_Date_Active -- Effective To
				,NULL -- Rep_Party_Tax_Name
				,NULL -- Legal Registration_ID
				,'N'  -- Default Registration Flag
				,'MIGRATED' -- Record Type
				,fnd_global.user_id
				,SYSDATE
				,fnd_global.user_id
				,SYSDATE
				,FND_GLOBAL.CONC_LOGIN_ID
				,1
			FROM	ap_supplier_sites_all PVS,
				ap_suppliers PV,
				zx_party_tax_profile PTP
			WHERE
					PVS.vendor_site_id = PTP.Party_ID
				AND	PTP.Party_Type_code = 'SUPPLIER_SITE'
				AND	PVS.Vendor_ID = PV.Vendor_ID
				AND       pvs.GLOBAL_ATTRIBUTE_CATEGORY =  'JL.BR.APXVDMVD.SITES'
				AND NOT EXISTS (SELECT 1 FROM zx_registrations
                                                WHERE party_tax_profile_id = ptp.party_tax_profile_id
                                                AND Registration_Type_Code = 'STATE INSCRIPTION'
						AND tax_regime_code= 'BR-ICMS' ));

		-- Inserts Records for Municipal Inscription

			INSERT INTO
				ZX_REGISTRATIONS(
				Registration_Id,
				Registration_Type_Code,
				Registration_Number,
				Registration_Status_Code,
				Registration_Source_Code,
				Registration_Reason_Code,
				Party_Tax_Profile_Id,
				Tax_Authority_Id,
				Coll_Tax_Authority_Id,
				Rep_Tax_Authority_Id,
				Tax,
				Tax_Regime_Code,
				ROUNDING_RULE_CODE,
				Tax_Jurisdiction_Code,
				Self_Assess_Flag,
				Inclusive_Tax_Flag,
				Effective_From,
				Effective_To,
				Rep_Party_Tax_Name,
				Legal_Registration_Id,
				Default_Registration_Flag,
				RECORD_TYPE_CODE,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				ZX_REGISTRATIONS_S.NEXTVAL
				,'CITY INSCRIPTION' -- Type
				,PVS.Global_Attribute14 -- City Registration Num
				,'REGISTERED' -- Registration_Status_Code
				,'EXPLICIT'
				,NULL -- Registration_Reason_Code
				,PTP.Party_Tax_Profile_ID
				,NULL -- Tax Authority ID
				,NULL -- Collecting Tax Authority ID
				,NULL -- Reporting Tax Authority ID
				,NULL -- Tax
				,'BR-ISS' -- Tax_Regime_Code
				,PTP.ROUNDING_RULE_CODE
				, NULL -- Tax Jurisdiction Code
				,PTP.Self_Assess_Flag  -- Self Asses
				,PTP.Inclusive_Tax_Flag
				,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
				,PV.End_Date_Active -- Effective To
				,NULL -- Rep_Party_Tax_Name
				,NULL -- Legal Registration_ID
				,'N'  -- Default Registration Flag
				,'MIGRATED' -- Record Type
				,fnd_global.user_id
				,SYSDATE
				,fnd_global.user_id
				,SYSDATE
				,FND_GLOBAL.CONC_LOGIN_ID
				,1
			FROM	ap_supplier_sites_all PVS,
				ap_suppliers PV,
				zx_party_tax_profile PTP
			WHERE
				PVS.vendor_site_id = PTP.Party_ID
				AND PTP.Party_Type_code = 'SUPPLIER_SITE'
				AND PVS.Vendor_ID = PV.Vendor_ID
				AND pvs.GLOBAL_ATTRIBUTE_CATEGORY =  'JL.BR.APXVDMVD.SITES'
 				AND NOT EXISTS (SELECT 1 FROM zx_registrations
                                                WHERE party_tax_profile_id = ptp.party_tax_profile_id
                                                AND registration_type_code = 'CITY INSCRIPTION'
						AND tax_regime_code = 'BR-ISS' ));


	END IF; --  (nvl(l_status,'N') = 'Y' or  nvl(l_db_status,'N') = 'Y') Brazil Localizations

*/
	arp_util_tax.debug(' SUPPLIER_SITE_EXTRACT(-) ' );

	EXCEPTION
		WHEN OTHERS THEN
           	   arp_util_tax.debug('Exception: Error Occurred during Supplier sites Extract in PTP/REGISTRATIONS Migration '||SQLERRM );

	END;
/*===========================================================================+
|  Procedure  :     OU_EXTRACT						    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		       profile migration which does the data		    |
|		       migration for Operating Unit details.                |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES      : Handle case for Non-Multi Org Environments                  |
|                                                                           |
|                                                                           |
|  History                                                                  |
|    zmohiudd	Tuesday, November 04,2003				    |
|                                                                           |
|    									    |
+===========================================================================*/

PROCEDURE OU_EXTRACT(p_party_id in NUMBER) IS

	BEGIN

	arp_util_tax.debug(' OU_EXTRACT(+) ' );
	IF L_MULTI_ORG_FLAG = 'N'
           --Bug Fix 4460944
	THEN
			INSERT INTO
				ZX_PARTY_TAX_PROFILE(
		                Party_Tax_Profile_Id,
				Party_Id,
				Party_Type_code,
				Customer_Flag,
				First_Party_Le_Flag,
				Supplier_Flag,
				Site_Flag,
				Legal_Establishment_Flag,
				Rounding_Level_code,
				Process_For_Applicability_Flag ,
				ROUNDING_RULE_CODE,
				Inclusive_Tax_Flag,
				Use_Le_As_Subscriber_Flag,
				Effective_From_Use_Le,
				Reporting_Authority_Flag,
				Collecting_Authority_Flag,
				PROVIDER_TYPE_CODE,
				RECORD_TYPE_CODE,
				TAX_CLASSIFICATION_CODE,
				Self_Assess_Flag,
				Allow_Offset_Tax_Flag,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				 ZX_PARTY_TAX_PROFILE_S.NEXTVAL -- Party_Tax_Profile_Id
				,L_ORG_ID	                -- Party_Id
				,'OU'				-- Party_Type_code
				,'N'				-- Customer Flag
				,'N'				-- First_Party_Le_Flag
				,'N'				-- Supllier_Flag
				,'N'				-- Site_Flag
				,'N'				-- Legal_Establishment_Flag
				,NULL				-- Rounding_Level_Code
				,'Y'				-- Process_For_Applicability_Flag
				,NULL,				-- Rounding_Rule_Code
				'N',				-- Inclusive_Tax_Flag
				'N',				-- Use_Le_As_Subscriber_Flag
				NULL,				-- Effective_From_Use_Le
				'N',				-- Reporting_Authority_Flag
				'N',				-- Collecting_Authority_Flag
				Null,				-- Provider_Type_Code
				'MIGRATED',			-- Record_Type_Code
				Null,				-- Tax_Classification_Code
				'N',				-- Self_Assess_Flag
				'N',				-- Allow_Offset_Tax_Flag
				fnd_global.user_id,		-- Created_By
				SYSDATE,			-- Creation_Date
				fnd_global.user_id,		-- Last_Updated_By
				SYSDATE,			-- Last_Update_Date
				FND_GLOBAL.CONC_LOGIN_ID,	-- Last_Update_Login
				1
			FROM	DUAL
			WHERE   not exists ( select 1 from zx_party_tax_profile
                                WHERE party_id = l_org_id and Party_Type_Code = 'OU'));

	ELSE

			INSERT INTO
				ZX_PARTY_TAX_PROFILE(
		                Party_Tax_Profile_Id,
				Party_Id,
				Party_Type_code,
				Customer_Flag,
				First_Party_Le_Flag,
				Supplier_Flag,
				Site_Flag,
				Legal_Establishment_Flag,
				Rounding_Level_code,
				Process_For_Applicability_Flag ,
				ROUNDING_RULE_CODE,
				Inclusive_Tax_Flag,
				Use_Le_As_Subscriber_Flag,
				Effective_From_Use_Le,
				Reporting_Authority_Flag,
				Collecting_Authority_Flag,
				PROVIDER_TYPE_CODE,
				RECORD_TYPE_CODE,
				TAX_CLASSIFICATION_CODE,
				Self_Assess_Flag,
				Allow_Offset_Tax_Flag,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER)
			(SELECT
				 ZX_PARTY_TAX_PROFILE_S.NEXTVAL -- Party_Tax_Profile_Id
				,Organization_id                -- Party_Id
				,'OU'				-- Party_Type_code
				,'N'				-- Customer Flag
				,'N'				-- First_Party_Le_Flag
				,'N'				-- Supllier_Flag
				,'N'				-- Site_Flag
				,'N'				-- Legal_Establishment_Flag
				,NULL				-- Rounding_Level_Code
				,'Y'				-- Process_For_Applicability_Flag
				,NULL,				-- Rounding_Rule_Code
				'N',				-- Inclusive_Tax_Flag
				'N',				-- Use_Le_As_Subscriber_Flag
				NULL,				-- Effective_From_Use_Le
				'N',				-- Reporting_Authority_Flag
				'N',				-- Collecting_Authority_Flag
				Null,				-- Provider_Type_Code
				'MIGRATED',			-- Record_Type_Code
				Null,				-- Tax_Classification_Code
				'N',				-- Self_Assess_Flag
				'N',				-- Allow_Offset_Tax_Flag
				fnd_global.user_id,		-- Created_By
				SYSDATE,			-- Creation_Date
				fnd_global.user_id,		-- Last_Updated_By
				SYSDATE,			-- Last_Update_Date
				FND_GLOBAL.CONC_LOGIN_ID,	-- Last_Update_Login
				1
			FROM	HR_OPERATING_UNITS
			WHERE   HR_OPERATING_UNITS.ORGANIZATION_ID =
	                        nvl(p_party_ID,HR_OPERATING_UNITS.ORGANIZATION_ID) and
				not exists ( select 1 from zx_party_tax_profile
                                WHERE party_id = organization_id and Party_Type_Code = 'OU'));

		        ------Bugfix 4308003----------
                        REG_REP_DRIVER_PROC_OU('OU');
                        ------------------------------
		END IF;



			arp_util_tax.debug(' OU_EXTRACT(-) ' );

			EXCEPTION
				WHEN OTHERS THEN
           			arp_util_tax.debug('Exception: Error Occurred during Operating Units Extract in PTP/REGISTRATIONS Migration '||SQLERRM );

			END;


/*===========================================================================+
|  Procedure:    SUPPLIER_TYPE_EXTRACT					    |
|                                                                           |
|                                                                           |
|  Description:  This procedure  does the data extraction for		    |
|                Fiscal Classifications for Party and populates		    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|  ARGUMENTS  :								    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|                                                                           |
|  NOTES								    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|  History								    |
|                                                                           |
|    zmohiudd	Wednesday, March 10, 2004		Created		    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
+===========================================================================*/


PROCEDURE SUPPLIER_TYPE_EXTRACT IS
BEGIN

	arp_util_tax.debug(' SUPPLIER_TYPE_EXTRACT .. (+) ' );

	-- Migrate fnd lookups source of Supplier Type

	arp_util_tax.debug(' Creating Fiscal classification types .. (+) ' );

	INSERT ALL
	INTO	ZX_FC_TYPES_B(
		CLASSIFICATION_TYPE_ID,
		OWNER_TABLE_CODE,
		OWNER_ID_CHAR,
		CLASSIFICATION_TYPE_CODE,
		CLASSIFICATION_TYPE_CATEG_CODE,
		CLASSIFICATION_TYPE_GROUP_CODE,
		DELIMITER,
		START_POSITION,
		NUM_CHARACTERS,
		CLASSIFICATION_TYPE_LEVEL_CODE,
		EFFECTIVE_FROM ,
		EFFECTIVE_TO  ,
		RECORD_TYPE_CODE,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER)
	VALUES (
		ZX_FC_TYPES_B_S.NEXTVAL,
		'HZ_CLASS_CATEGORY',
		'VENDOR TYPE',
		'SUPPLIER_TYPE',
		'PARTY_FISCAL_CLASS',
		NULL,
		NULL,
		NULL,
		NULL,
		1,
		SYSDATE,
		NULL,
		'MIGRATED',
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.conc_login_id,
		1)
	SELECT '1' from dual
	WHERE NOT EXISTS
		(SELECT NULL
		FROM ZX_FC_TYPES_B TYPE
		WHERE TYPE.CLASSIFICATION_TYPE_CODE =
			'SUPPLIER_TYPE' AND
		TYPE.CLASSIFICATION_TYPE_CATEG_CODE =
			'PARTY_FISCAL_CLASS');

	INSERT ALL
	INTO ZX_FC_TYPES_TL(
		CLASSIFICATION_TYPE_ID,
		CLASSIFICATION_TYPE_NAME,
		LANGUAGE,
		SOURCE_LANG,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
		)
	VALUES (CLASSIFICATION_TYPE_ID,
		'Supplier Type',
		LANGUAGE_CODE,
		userenv('LANG')			,
		fnd_global.user_id             	,
		SYSDATE                        	,
		fnd_global.user_id             	,
		SYSDATE                        	,
		fnd_global.conc_login_id)
	SELECT
		fc_types.CLASSIFICATION_TYPE_ID ,
		L.LANGUAGE_CODE
	FROM
		FND_LANGUAGES L,
		ZX_FC_TYPES_B fc_types
	WHERE
		L.INSTALLED_FLAG in ('I', 'B')
		AND  fc_types.RECORD_TYPE_CODE = 'MIGRATED'
		AND  fc_types.CLASSIFICATION_TYPE_CODE
				='SUPPLIER_TYPE'
		AND  fc_types.CLASSIFICATION_TYPE_CATEG_CODE
				='PARTY_FISCAL_CLASS'
		AND  not exists
		(select NULL
		from ZX_FC_TYPES_TL T
		where T.CLASSIFICATION_TYPE_ID =
			fc_types.CLASSIFICATION_TYPE_ID
		and T.LANGUAGE = L.LANGUAGE_CODE);


/*	arp_util_tax.debug(' Creating Fiscal classification codes .. (+) ' );

	INSERT ALL
	INTO ZX_FC_CODES_B (
		classification_type_code,
		classification_id,
		classification_code,
		effective_from,
		effective_to,
		parent_classification_code,
		Country_code,
		record_type_code ,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		OBJECT_VERSION_NUMBER)
	VALUES	('SUPPLIER_TYPE',
		zx_fc_codes_b_s.nextval,
		'SUPPLIER TYPE',
		sysdate,
		null,
		null,
		null,
		'MIGRATED',
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE,
		FND_GLOBAL.CONC_LOGIN_ID,
		1)
	SELECT '1' FROM DUAL
	WHERE NOT EXISTS
		(SELECT NULL
		FROM ZX_FC_CODES_B CODES
		WHERE CODES.CLASSIFICATION_TYPE_CODE =
			'SUPPLIER_TYPE' AND
		CODES.CLASSIFICATION_CODE =
			'SUPPLIER TYPE');

	INSERT ALL
	INTO ZX_FC_CODES_TL(
		CLASSIFICATION_ID,
		CLASSIFICATION_NAME,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		LANGUAGE,
		SOURCE_LANG)
	VALUES (CLASSIFICATION_ID,
		'Supplier Type',
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE,
		FND_GLOBAL.CONC_LOGIN_ID,
		LANGUAGE_CODE,
		userenv('LANG'))
	INTO ZX_FC_CODES_DENORM_B(
		CLASSIFICATION_TYPE_ID,
		CLASSIFICATION_TYPE_CODE,
		CLASSIFICATION_TYPE_NAME,
		CLASSIFICATION_TYPE_CATEG_CODE,
		CLASSIFICATION_ID,
		CLASSIFICATION_CODE,
		CLASSIFICATION_NAME,
		LANGUAGE,
		EFFECTIVE_FROM,
		EFFECTIVE_TO,
		ENABLED_FLAG,
		ANCESTOR_ID,
		ANCESTOR_CODE,
		ANCESTOR_NAME,
		CONCAT_CLASSIF_CODE,
		CONCAT_CLASSIF_NAME,
		CLASSIFICATION_CODE_LEVEL,
		COUNTRY_CODE,
		SEGMENT1,
		SEGMENT2,
		SEGMENT3,
		SEGMENT4,
		SEGMENT5,
		SEGMENT6,
		SEGMENT7,
		SEGMENT8,
		SEGMENT9,
		SEGMENT10,
		SEGMENT1_NAME,
		SEGMENT2_NAME,
		SEGMENT3_NAME,
		SEGMENT4_NAME,
		SEGMENT5_NAME,
		SEGMENT6_NAME,
		SEGMENT7_NAME,
		SEGMENT8_NAME,
		SEGMENT9_NAME,
		SEGMENT10_NAME,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		REQUEST_ID,
		PROGRAM_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_LOGIN_ID,
		RECORD_TYPE_CODE)
	VALUES (CLASSIFICATION_TYPE_ID,
		CLASSIFICATION_TYPE_CODE,
		CLASSIFICATION_TYPE_NAME,
		CLASSIFICATION_TYPE_CATEG_CODE,
		CLASSIFICATION_ID,
		'SUPPLIER TYPE',
		'Supplier Type',
		LANGUAGE_CODE,
		sysdate,
		null,
		null,
		null,
		null,
		null,
		'SUPPLIER TYPE',
		'Supplier Type',
		1,
		Null,
		'SUPPLIER TYPE',
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		'Supplier Type',
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		FND_GLOBAL.CONC_LOGIN_ID,
		sysdate,
		FND_GLOBAL.CONC_REQUEST_ID,
		fnd_global.CONC_PROGRAM_ID,
		235,
		FND_GLOBAL.CONC_LOGIN_ID,
		'MIGRATED')
	SELECT
		TYPE.CLASSIFICATION_TYPE_ID,
		TYPE.CLASSIFICATION_TYPE_CODE,
		TYPE.CLASSIFICATION_TYPE_NAME,
		TYPE.Classification_Type_Categ_Code,
		TYPE.DELIMITER,
		CODE.CLASSIFICATION_ID,
		L.LANGUAGE_CODE
	FROM	ZX_FC_TYPES_VL TYPE,
		ZX_FC_CODES_B CODE,
		FND_LANGUAGES L
	WHERE	TYPE.CLASSIFICATION_TYPE_CODE = 'SUPPLIER_TYPE'
		AND TYPE.CLASSIFICATION_TYPE_CATEG_CODE
				='PARTY_FISCAL_CLASS'
		AND TYPE.CLASSIFICATION_TYPE_CODE =
				CODE.CLASSIFICATION_TYPE_CODE
		AND TYPE.RECORD_TYPE_CODE = 'MIGRATED'
		AND L.INSTALLED_FLAG in ('I', 'B')
		AND  not exists
		(select NULL
		from ZX_FC_CODES_TL T
		where T.CLASSIFICATION_ID =
			CODE.CLASSIFICATION_ID
		and T.LANGUAGE = L.LANGUAGE_CODE);*/


	arp_util_tax.debug(' SUPPLIER_TYPE_EXTRACT .. (-) ' );

END;

/*===========================================================================+
|  Procedure:    SUPPLIER_ASSOC_EXTRACT					    |
|                                                                           |
|                                                                           |
|  Description:  This procedure creates associations for                   |
|                a party types and Fiscal classification |
|                                                                           |
|                                                                           |
|									    |
|  ARGUMENTS  :								    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|                                                                           |
|  NOTES								    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|  History								    |
|                                                                           |
|    zmohiudd	Wednesday, March 10, 2004		Created		    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
+===========================================================================*/


 PROCEDURE SUPPLIER_ASSOC_EXTRACT IS

 BEGIN

 arp_util_tax.debug(' SUPPLIER_ASSOC_EXTRACT .. (+) ' );
/*
 ---Migrate the association of Supplier Type to a Supplier.
 ---In PTP Extract
			INSERT INTO
				HZ_CODE_ASSIGNMENTS
				(CODE_ASSIGNMENT_ID,
				OWNER_TABLE_NAME,
				OWNER_TABLE_ID,
				CLASS_CATEGORY,
				CLASS_CODE,
				PRIMARY_FLAG,
				CONTENT_SOURCE_TYPE,
				ACTUAL_CONTENT_SOURCE,
				IMPORTANCE_RANKING,
				START_DATE_ACTIVE,
				END_DATE_ACTIVE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				STATUS,
				OBJECT_VERSION_NUMBER,
				CREATED_BY_MODULE,
				APPLICATION_ID,
				RANK,
				OWNER_TABLE_KEY_1,
				OWNER_TABLE_KEY_2,
				OWNER_TABLE_KEY_3,
				OWNER_TABLE_KEY_4,
				OWNER_TABLE_KEY_5,
				PROGRAM_APPLICATION_ID,
				PROGRAM_ID)

         Select
				HZ_CODE_ASSIGNMENTS_S.nextval,
				'ZX_PARTY_TAX_PROFILE',
				PTP.PARTY_TAX_PROFILE_ID party_tax_profile_id,
				'VENDOR TYPE',
				POV.VENDOR_TYPE_LOOKUP_CODE fiscal_classification_code,
				'N',
				'USER_ENTERED',
				'USER_ENTERED',
				Null,
				Sysdate,
				Null,
				fnd_global.user_id,
				Sysdate,
				FND_GLOBAL.CONC_LOGIN_ID,
				Sysdate,
				fnd_global.user_id,
				Null,
				1,
				'EBTAX MIGRATION',
				235,
				Null,
				Null,
				Null,
				Null,
				Null,
				NULL,
				fnd_global.PROG_APPL_ID,
				fnd_global.CONC_PROGRAM_ID
     FROM   ap_suppliers POV ,
	        ZX_PARTY_TAX_PROFILE PTP
    WHERE   POV.PARTY_ID = PTP.PARTY_ID
      AND   PTP.PARTY_TYPE_CODE = 'SUPPLIER'
      AND   POV.VENDOR_TYPE_LOOKUP_CODE is not null;
*/
  arp_util_tax.debug(' SUPPLIER_ASSOC_EXTRACT .. (-) ' );

 END ;

/*===========================================================================+
|  Procedure:    Party_Assoc_Extract					    |
|                                                                           |
|                                                                           |
|  Description:  This procedure  creates associations for                   |
|                a party types and Fiscal classification		    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|  ARGUMENTS  :								    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|                                                                           |
|  NOTES								    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|  History								    |
|                                                                           |
|    zmohiudd	Wednesday, March 10, 2004		Created		    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
+===========================================================================*/

PROCEDURE Party_Assoc_Extract
  (p_party_source IN VARCHAR2,
   p_party_tax_profile_id  IN NUMBER,
   p_fiscal_class_type_code IN VARCHAR2,
   p_fiscal_classification_code IN VARCHAR2 ,
   p_dml_type     IN VARCHAR2)
IS
   l_table_owner HZ_CODE_ASSIGNMENTS.OWNER_TABLE_NAME%TYPE := 'HZ_PARTIES';

BEGIN


  arp_util_tax.debug(' Party_Assoc_Extract .. (+) ' );

   IF p_party_source in ('ZX_PARTY_TAX_PROFILE' , 'PO_VENDOR' ,'PO_VENDOR_SITES') THEN
	      l_table_owner := 'ZX_PARTY_TAX_PROFILE';
   ELSIF p_party_source = 'HR_ORGANIZATIONS' or p_party_source = 'AP_REPORTING_ENTITIES' THEN
      	l_table_owner := 'HZ_PARTIES';
   END IF;

   IF p_dml_type= 'I' THEN
      BEGIN

			INSERT INTO
				HZ_CODE_ASSIGNMENTS
				(CODE_ASSIGNMENT_ID,
				OWNER_TABLE_NAME,
				OWNER_TABLE_ID,
				CLASS_CATEGORY,
				CLASS_CODE,
				PRIMARY_FLAG,
				CONTENT_SOURCE_TYPE,
				ACTUAL_CONTENT_SOURCE,
				IMPORTANCE_RANKING,
				START_DATE_ACTIVE,
				END_DATE_ACTIVE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				STATUS,
				OBJECT_VERSION_NUMBER,
				CREATED_BY_MODULE,
				APPLICATION_ID,
				RANK,
				OWNER_TABLE_KEY_1,
				OWNER_TABLE_KEY_2,
				OWNER_TABLE_KEY_3,
				OWNER_TABLE_KEY_4,
				OWNER_TABLE_KEY_5)
			values
				(HZ_CODE_ASSIGNMENTS_S.nextval,
				l_table_owner,
				p_party_tax_profile_id,
				p_fiscal_class_type_code,
				p_fiscal_classification_code,
				'N',
				'USER_ENTERED',
				'USER_ENTERED',
				Null,
				Sysdate,
				Null,
				fnd_global.user_id,
				Sysdate,
				FND_GLOBAL.CONC_LOGIN_ID,
				Sysdate,
				fnd_global.user_id,
				Null,
				Null,
				Null,
				235,
				Null,
				Null,
				Null,
				Null,
				Null,
				Null);


			EXCEPTION
				WHEN OTHERS THEN
			             arp_util_tax.debug('Error while Inserting data into
					HZ_CODE_ASSIGNMENTS for Party ID ' ||
					p_party_tax_profile_id );
			             arp_util_tax.debug('Error Code:  '||SQLCODE|| '. Error Message '|| SQLERRM);

			END ;

	ELSIF p_dml_type= 'U' THEN

	IF p_fiscal_classification_code is Not NULL THEN

        -- If Update fails it means that for this record
	  -- VENDOR_TYPE_LOOKUP_CODE was updated from Null to NOT Null
        -- In this case we create a new row.

	   arp_util_tax.debug('Updating the data , since the fiscal classification code is not null now ');




         BEGIN



            MERGE INTO HZ_CODE_ASSIGNMENTS pfa
            USING  	(SELECT
				p_party_tax_profile_id     	party_Tax_profile_id ,
				p_fiscal_class_type_code   	fiscal_class_type_code,
		                p_fiscal_classification_code 	fiscal_classification_code
			FROM DUAL) fc
            ON    	(pfa.OWNER_TABLE_ID     		= 	fc.PARTY_TAX_PROFILE_ID and
                   	pfa.CLASS_CATEGORY	   		= 	fc.fiscal_class_type_code  and
                   	pfa.class_code 		   		= 	fc.fiscal_classification_code)
           WHEN MATCHED THEN UPDATE SET
				OWNER_TABLE_NAME		=	l_table_owner ,
				OWNER_TABLE_ID			=	fc.PARTY_TAX_PROFILE_ID,
				CLASS_CATEGORY			=	fc.fiscal_class_type_code,
				CLASS_CODE			=	fc.fiscal_classification_code,
				PRIMARY_FLAG			=	'N',
				CONTENT_SOURCE_TYPE		=	'USER_ENTERED',
				ACTUAL_CONTENT_SOURCE		=	'USER_ENTERED',
				IMPORTANCE_RANKING		=	Null,
				START_DATE_ACTIVE		=	SYSDATE,
				END_DATE_ACTIVE			=	Null,
				CREATED_BY			=	fnd_global.user_id,
				CREATION_DATE			=	SYSDATE,
				LAST_UPDATE_LOGIN		=	FND_GLOBAL.CONC_LOGIN_ID,
				LAST_UPDATE_DATE		=	SYSDATE,
				LAST_UPDATED_BY			=	fnd_global.user_id,
				APPLICATION_ID			=	235
            WHEN NOT MATCHED THEN INSERT
           			(
				CODE_ASSIGNMENT_ID,
				OWNER_TABLE_NAME,
				OWNER_TABLE_ID,
				CLASS_CATEGORY,
				CLASS_CODE,
				PRIMARY_FLAG,
				CONTENT_SOURCE_TYPE,
				ACTUAL_CONTENT_SOURCE,
				IMPORTANCE_RANKING,
				START_DATE_ACTIVE,
				END_DATE_ACTIVE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				STATUS,
				OBJECT_VERSION_NUMBER,
				CREATED_BY_MODULE,
				APPLICATION_ID,
				RANK,
				OWNER_TABLE_KEY_1,
				OWNER_TABLE_KEY_2,
				OWNER_TABLE_KEY_3,
				OWNER_TABLE_KEY_4,
				OWNER_TABLE_KEY_5
				)
			values
				(
				HZ_CODE_ASSIGNMENTS_S.nextval,
				l_table_owner,
				p_party_tax_profile_id,
				p_fiscal_class_type_code,
				p_fiscal_classification_code,
				'N',
				'USER_ENTERED',
				'USER_ENTERED',
				Null,
				Sysdate,
				Null,
				fnd_global.user_id,
				Sysdate,
				FND_GLOBAL.CONC_LOGIN_ID,
				Sysdate,
				fnd_global.user_id,
				Null,
				Null,
				Null,
				235,
				Null,
				Null,
				Null,
				Null,
				Null,
				Null);


			EXCEPTION
        			WHEN OTHERS THEN
					arp_util_tax.debug('Error while merging data into
						HZ_CODE_ASSIGNMENTS for Party ID ' || p_party_tax_profile_id );
					arp_util_tax.debug('Error Code:  '||SQLCODE||'. Error Message '|| SQLERRM);
			END;


	ELSE


		arp_util_tax.debug('Updating the data in HZ_CODE_ASSIGNMENTS ');


         	UPDATE HZ_CODE_ASSIGNMENTS
            	SET
              		OWNER_TABLE_NAME		=	l_table_owner,
				OWNER_TABLE_ID		=	P_PARTY_TAX_PROFILE_ID,
				CLASS_CATEGORY		=	P_fiscal_class_type_code,
				CLASS_CODE		=	P_fiscal_classification_code,
				PRIMARY_FLAG		=	'N',
				CONTENT_SOURCE_TYPE	=	'USER_ENTERED',
				ACTUAL_CONTENT_SOURCE   =       'USER_ENTERED',
				IMPORTANCE_RANKING	=	Null,
				START_DATE_ACTIVE	=	SYSDATE,
				END_DATE_ACTIVE		=	Null,
				CREATED_BY		=	fnd_global.user_id,
				CREATION_DATE		=	SYSDATE,
				LAST_UPDATE_LOGIN	=	FND_GLOBAL.CONC_LOGIN_ID,
				LAST_UPDATE_DATE	=	SYSDATE,
				LAST_UPDATED_BY		=	fnd_global.user_id,
				APPLICATION_ID		=	235
	          WHERE
				OWNER_TABLE_ID		= 	p_party_tax_profile_id   and
            			CLASS_CATEGORY			= 	p_fiscal_class_type_code and
				CLASS_CODE			= 	p_fiscal_classification_code ;

        END IF; -- Classification Code not null

   END IF;


  arp_util_tax.debug(' Party_Assoc_Extract .. (-) ' );

END;


/*===========================================================================+
|  Procedure:    SUPPLIER_TYPE_MIGRATION				    |
|                                                                           |
|                                                                           |
|  Description:  This procedure  is used to carry out Supplier Type 	    |
|		 Extract after the Supplier Migration has occurred 	    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|  ARGUMENTS  :								    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|                                                                           |
|  NOTES								    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|  History								    |
|                                                                           |
|    Arnab Sengupta     Wednesday, May 4th , 2005		Created	    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
+===========================================================================*/


PROCEDURE SUPPLIER_TYPE_MIGRATION IS
   l_status fnd_module_installations.status%TYPE;
   l_db_status fnd_module_installations.DB_STATUS%TYPE;

BEGIN
-- Bug # 3594759
	-- Verify Argentina Installation
	SELECT STATUS, DB_STATUS
	INTO l_status, l_db_status
	FROM  fnd_module_installations
	WHERE APPLICATION_ID = '7004'
	   And MODULE_SHORT_NAME = 'jlarloc';

	IF (nvl(l_status,'N') in ('I','S') or
	 nvl(l_db_status,'N') in ('I','S')) THEN

		-- Code to migrate the lookup code for the Lookup Type
		-- JLZZ_AP_VAT_REG_STAT_CODE into
		-- ZX_REGISTRATIONS_STATUS lookup type
		insert into fnd_lookup_values(
			LOOKUP_TYPE,
			LANGUAGE,
			LOOKUP_CODE,
			MEANING,
			DESCRIPTION,
			ENABLED_FLAG,
			START_DATE_ACTIVE,
			END_DATE_ACTIVE,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			LAST_UPDATE_DATE,
			SOURCE_LANG,
			SECURITY_GROUP_ID,
			VIEW_APPLICATION_ID,
			TERRITORY_CODE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15)
		(select
			'ZX_REGISTRATIONS_STATUS',
			LANGUAGE,
			LOOKUP_CODE,
			MEANING,
			DESCRIPTION,
			ENABLED_FLAG,
			START_DATE_ACTIVE,
			END_DATE_ACTIVE,
			fnd_global.user_id,
			SYSDATE,
			fnd_global.user_id,
			fnd_global.conc_login_id,
			SYSDATE,
			SOURCE_LANG,
			SECURITY_GROUP_ID,
			VIEW_APPLICATION_ID,
			TERRITORY_CODE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		FROM
			FND_LOOKUP_VALUES fnd
		WHERE
			fnd.LOOKUP_TYPE = 'JLZZ_AP_VAT_REG_STAT_CODE'
		AND NOT EXISTS
		 	( select 1 from FND_LOOKUP_VALUES
			  where  lookup_type = 'JLZZ_AP_VAT_REG_STAT_CODE' and
			         lookup_code = fnd.lookup_code) );

     	END IF;
        arp_util_tax.debug(' Now calling SUPPLIER_TYPE_EXTRACT ' );

        ZX_PTP_MIGRATE_PKG.SUPPLIER_TYPE_EXTRACT;


        arp_util_tax.debug(' Now calling SUPPLIER_ASSOC_EXTRACT ' );

                ZX_PTP_MIGRATE_PKG.SUPPLIER_ASSOC_EXTRACT;


END SUPPLIER_TYPE_MIGRATION;


/*===========================================================================+
|  Procedure:    ZX_PTP_MAIN						    |
|                                                                           |
|                                                                           |
|  Description:  This procedure  is the main wrapper procedure		    |
|                for party tax profile migration			    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|  ARGUMENTS  :								    |
|									    |
|                                                                           |
|                                                                           |
|									    |
|                                                                           |
|  NOTES								    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|  History								    |
|                                                                           |
|    zmohiudd	Wednesday, March 10, 2004		Created		    |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
+===========================================================================*/

PROCEDURE ZX_PTP_MAIN IS

BEGIN

		arp_util_tax.debug(' ZX_PTP_MAIN .. (+) ' );

		arp_util_tax.debug(' Now calling FIRST_PARTY_EXTRACT..  ' );

		ZX_PTP_MIGRATE_PKG.FIRST_PARTY_EXTRACT(null);

		arp_util_tax.debug(' calling LEGAL_ESTABLISHMENT...  ' );

		ZX_PTP_MIGRATE_PKG.LEGAL_ESTABLISHMENT(null);

/* The following calls have been commented out on account of bug 4317072
   SQL scripts have been written to execute the code in these procedures .These scripts will get
   called in the appropriate phase .From now on these calls will be made explicitly for synchronization
   purpose only */


/*
		arp_util_tax.debug(' calling SUPPLIER_EXTRACT...  ' );

		ZX_PTP_MIGRATE_PKG.SUPPLIER_EXTRACT(null, null);

		arp_util_tax.debug(' calling SUPPLIER_SITE_EXTRACT...  ' );

		ZX_PTP_MIGRATE_PKG.SUPPLIER_SITE_EXTRACT(null, null) ;
*/
END;

BEGIN

   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
    FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN

       FND_PROFILE.GET('ORG_ID',L_ORG_ID);

       IF L_ORG_ID IS NULL THEN
          arp_util_tax.debug('MO: Operating Units site level profile option value not set,
                                resulted in Null Org Id');
       END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of P2P PTP '||sqlerrm);

END ZX_PTP_MIGRATE_PKG;

/
