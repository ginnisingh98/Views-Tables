--------------------------------------------------------
--  DDL for Package Body XXAH_AP_SUPPL_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_SUPPL_EMAIL_PKG" 
IS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPL_EMAIL_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Email
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           Remarks
   * 30-Nov-2015        1.0       Sunil Thamke     Initial
   ****************************************************************************/
PROCEDURE P_MAIN (errbuf OUT VARCHAR2, retcode OUT NUMBER)
IS

V_SERVER  varchar2(500);
V_EMAIL varchar2(500);
V_TOEMAIL varchar2(500);
V_INSTANCE varchar2(1000);
v_top varchar2(500);
v_last_run_date   DATE;
v_flag BOOLEAN := FALSE;
v_filename         VARCHAR2 (100);
v_date             VARCHAR2 (50);
v_req_id     NUMBER;
v_profile_option_value varchar2(500);
v_sno NUMBER := 0;
l_full_name varchar2(500);
l_published_by  varchar2(500);
g_request_id                    NUMBER       := fnd_global.conc_request_id;

      CURSOR c_supplier(v_last_run_date IN DATE)
      IS
SELECT  Replace(A.PARTY_NAME, '&', '') SUPPLIER_NAME, A.SEGMENT1 SUPPLIER_NUMBER,A.PUBLICATION_DATE, A.PUBLISHED_BY, max(A.last_update_date)last_update_date, a.last_updated_by
FROM
(SELECT aps.party_id, HZP.PARTY_NAME
, APS.SEGMENT1 ,
           pub.publication_date,
           (SELECT   fu.user_name
              FROM   fnd_user fu
             WHERE   fu.user_id = pub.published_by)Published_by
,GREATEST(
NVL (HZP.last_update_date, (SYSDATE - 365 * 100))
,NVL (aps.last_update_date, (SYSDATE - 365 * 100))
,NVL (SITE_SUPP.last_update_date, (SYSDATE - 365 * 100))
,NVL (ASS.last_update_date, (SYSDATE - 365 * 100))
,NVL (IEP.last_update_date, (SYSDATE - 365 * 100))
,NVL (IPI.last_update_date, (SYSDATE - 365 * 100))
,NVL (IEB.last_update_date, (SYSDATE - 365 * 100))
,NVL (HZPBANK.last_update_date, (SYSDATE - 365 * 100))
,NVL (HZPBRANCH.last_update_date, (SYSDATE - 365 * 100))
,NVL (HOPBANK.last_update_date, (SYSDATE - 365 * 100))
,NVL (HOPBRANCH.last_update_date, (SYSDATE - 365 * 100))
,NVL (supplier_level.last_update_date, (SYSDATE - 365 * 100))
,NVL (SUPP_ADDR_SITE_LEVEL.last_update_date, (SYSDATE - 365 * 100))
,NVL (HCP.last_update_date, (SYSDATE - 365 * 100))
,NVL (pan.last_update_date, (SYSDATE - 365 * 100))
,NVL (HPSU.last_update_date, (SYSDATE - 365 * 100))
,NVL (hzl.last_update_date, (SYSDATE - 365 * 100))
)last_update_date,
decode(GREATEST(
NVL (HZP.last_update_date, (SYSDATE - 365 * 100))
,NVL (aps.last_update_date, (SYSDATE - 365 * 100))
,NVL (SITE_SUPP.last_update_date, (SYSDATE - 365 * 100))
,NVL (ASS.last_update_date, (SYSDATE - 365 * 100))
,NVL (IEP.last_update_date, (SYSDATE - 365 * 100))
,NVL (IPI.last_update_date, (SYSDATE - 365 * 100))
,NVL (IEB.last_update_date, (SYSDATE - 365 * 100))
,NVL (HZPBANK.last_update_date, (SYSDATE - 365 * 100))
,NVL (HZPBRANCH.last_update_date, (SYSDATE - 365 * 100))
,NVL (HOPBANK.last_update_date, (SYSDATE - 365 * 100))
,NVL (HOPBRANCH.last_update_date, (SYSDATE - 365 * 100))
,NVL (supplier_level.last_update_date, (SYSDATE - 365 * 100))
,NVL (SUPP_ADDR_SITE_LEVEL.last_update_date, (SYSDATE - 365 * 100))
,NVL (HCP.last_update_date, (SYSDATE - 365 * 100))
,NVL (pan.last_update_date, (SYSDATE - 365 * 100))
,NVL (HPSU.last_update_date, (SYSDATE - 365 * 100))
,NVL (hzl.last_update_date, (SYSDATE - 365 * 100))
),HZP.last_update_date, HZP.last_updated_by, aps.last_update_date,aps.last_updated_by,SITE_SUPP.last_update_date,SITE_SUPP.last_updated_by,ASS.last_update_date,ASS.last_updated_by,IEP.last_update_date, IEP.last_updated_by, IPI.last_update_date, IPI.last_updated_by, IEB.last_update_date, IEB.last_updated_by, HZPBANK.last_update_date, HZPBANK.last_updated_by, HZPBRANCH.last_update_date, HZPBRANCH.last_updated_by, HOPBANK.last_update_date, HOPBANK.last_updated_by, HOPBRANCH.last_update_date, HOPBRANCH.last_updated_by, supplier_level.last_update_date, supplier_level.last_updated_by, SUPP_ADDR_SITE_LEVEL.last_update_date, SUPP_ADDR_SITE_LEVEL.last_updated_by, HCP.last_update_date, HCP.last_updated_by, pan.last_update_date, pan.last_updated_by, HPSU.last_update_date, HPSU.last_updated_by, hzl.last_update_date, hzl.last_updated_by)
last_updated_by
FROM HZ_PARTIES HZP
, AP_SUPPLIERS APS
, HZ_PARTY_SITES SITE_SUPP
, AP_SUPPLIER_SITES_ALL ASS
, IBY_EXTERNAL_PAYEES_ALL IEP
, IBY_PMT_INSTR_USES_ALL IPI
, IBY_EXT_BANK_ACCOUNTS IEB
, HZ_PARTIES HZPBANK
, HZ_PARTIES HZPBRANCH
, HZ_ORGANIZATION_PROFILES HOPBANK
, HZ_ORGANIZATION_PROFILES HOPBRANCH,
POS_XXAH_SUPPLIER_TY_AGV XXSA, -- Modified by Vema send , notifictions only when supplier type NFR not for Trade and Contracts only
(SELECT   psp.party_id, psp.last_update_date, psp.last_updated_by
                 FROM   APPS.pos_supp_prof_ext_b psp,
                        APPS.ego_attr_groups_v egv,
                        EGO.EGO_DATA_LEVEL_B edl
                WHERE       c_ext_attr1 is not null
                        --and c_ext_attr2 is not null
                        and psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
                        AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
                        AND edl.DATA_LEVEL_NAME = 'SUPP_LEVEL'
                                    and psp.last_update_date is not null)supplier_level,
(SELECT   psp.party_id, psp.last_update_date , psp.last_updated_by
                 FROM   APPS.pos_supp_prof_ext_b psp,
                        APPS.ego_attr_groups_v egv,
                        EGO.EGO_DATA_LEVEL_B edl
                WHERE       c_ext_attr1 is not null
                        and psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
                        AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
                        AND edl.DATA_LEVEL_NAME = 'SUPP_ADDR_SITE_LEVEL'
                                    and psp.last_update_date is not null)SUPP_ADDR_SITE_LEVEL,
        (SELECT   publication_date, published_by, party_id
              FROM   pos_supp_pub_history pos
             WHERE   publication_date = (SELECT   MAX (publication_date)
                                           FROM   pos_supp_pub_history pos1
                                          WHERE   pos.party_id = pos1.party_id))
           pub,
        HZ_CONTACT_POINTS HCP,
            HZ_PARTY_SITES HPS,
			 pos_address_notes PAN,
			 hz_party_site_uses HPSU,
			 hz_locations hzl,
			  pos_supp_prof_ext_b pspe,
                        ego_attr_groups_v eagv,
                        EGO_DATA_LEVEL_B edlb
WHERE HZP.PARTY_ID = APS.PARTY_ID
AND HZP.PARTY_ID = SITE_SUPP.PARTY_ID
AND HZP.party_id=XXSA.party_id
and XXSA.XXAH_SUPPLIER_TYPE_ATT='NFR'  -- Modified by Vema, send notifictions only when supplier type NFR not for Trade and Contracts only
AND SITE_SUPP.PARTY_SITE_ID = ASS.PARTY_SITE_ID
AND ASS.VENDOR_ID = APS.VENDOR_ID
AND IEP.PAYEE_PARTY_ID = HZP.PARTY_ID
AND IEP.PARTY_SITE_ID = SITE_SUPP.PARTY_SITE_ID
AND IEP.SUPPLIER_SITE_ID(+) = ASS.VENDOR_SITE_ID
AND IEP.EXT_PAYEE_ID = IPI.EXT_PMT_PARTY_ID(+)
AND IPI.INSTRUMENT_ID = IEB.EXT_BANK_ACCOUNT_ID(+)
AND IEB.BANK_ID = HZPBANK.PARTY_ID(+)
AND IEB.BANK_ID = HZPBRANCH.PARTY_ID(+)
AND HZPBRANCH.PARTY_ID = HOPBRANCH.PARTY_ID(+)
AND HZPBANK.PARTY_ID = HOPBANK.PARTY_ID(+)
and aps.party_id = supplier_level.party_id(+)
and aps.party_id = SUPP_ADDR_SITE_LEVEL.party_id(+)
AND aps.party_id = pub.party_id(+)
AND     HPS.PARTY_ID=APS.PARTY_ID
AND     HCP.OWNER_TABLE_ID(+)=HPS.PARTY_SITE_ID
AND PAN.party_site_id(+) = hps.party_site_id
AND HPSU.party_site_id(+) = hps.party_site_id
AND hps.location_id =  hzl.location_id
AND pspe.c_ext_attr1 is not null
                        and pspe.ATTR_GROUP_ID = eagv.ATTR_GROUP_ID
                        AND pspe.DATA_LEVEL_ID = edlb.DATA_LEVEL_ID
                        AND edlb.DATA_LEVEL_NAME = 'SUPP_LEVEL'
						AND eagv.attr_group_name = 'XXAH_Supplier_Type'
						AND pspe.party_id = APS.PARTY_ID
						AND pspe.party_id = HZP.PARTY_ID
AND
(aps.last_update_date >= v_last_run_date
OR HZP.last_update_date >= v_last_run_date
OR SITE_SUPP.last_update_date >= v_last_run_date
OR ASS.last_update_date >= v_last_run_date
OR IEP.last_update_date >= v_last_run_date
OR IPI.last_update_date >= v_last_run_date
OR IEB.last_update_date >= v_last_run_date
OR HZPBANK.last_update_date >= v_last_run_date
OR HZPBRANCH.last_update_date >= v_last_run_date
OR HOPBANK.last_update_date >= v_last_run_date
OR HOPBRANCH.last_update_date >= v_last_run_date
OR supplier_level.last_update_date >= v_last_run_date
OR SUPP_ADDR_SITE_LEVEL.last_update_date >= v_last_run_date
OR HCP.last_update_date >= v_last_run_date
OR pub.publication_date >= v_last_run_date
OR PAN.last_update_date >= v_last_run_date
OR HPSU.last_update_date >= v_last_run_date
OR hzl.last_update_date >= v_last_run_date)
)a
GROUP BY A.PARTY_NAME, A.SEGMENT1 ,A.publication_date, A.Published_by, a.last_updated_by
ORDER BY 1 ;

BEGIN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0"?>');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER_INFO>');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering');
select parameter_value into V_SERVER
from fnd_svc_comp_param_vals fvcp,FND_SVC_COMP_PARAMS_B fpv,FND_SVC_COMPONENTS fpc
where fpv.parameter_name = 'OUTBOUND_SERVER'
and fpc.component_name = 'Workflow Notification Mailer'
and fvcp.component_id = fpc.component_id
and fvcp.parameter_id  = fpv.parameter_id;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Getting from email Address');
   select  fnd_profile.value('XXAH_FROM_EMAIL_ADDRESS')into V_EMAIL
      from dual;
FND_FILE.PUT_LINE(FND_FILE.LOG,'V_EMAIL'||V_EMAIL);

         select  fnd_profile.value('XXAH_TOP_DETAILS') into v_top
      from dual;

      V_INSTANCE := v_top||'/'||'XXAH_Supplier_deatils.rtf';
FND_FILE.PUT_LINE(FND_FILE.LOG,'Getting program last run');
          BEGIN
            SELECT pov.profile_option_value
        INTO v_profile_option_value
            FROM apps.fnd_profile_options po,
            apps.fnd_profile_option_values pov
            WHERE 1 = 1
            AND pov.application_id = po.application_id
            AND pov.profile_option_id = po.profile_option_id
            and po.profile_option_name like 'XXAH_SUPPLIER_EMAIL_NOTIFI_PROG_LAST_RUN_DATE'
            and pov.level_id = '10001';
          EXCEPTION
           WHEN NO_DATA_FOUND
                        THEN
                        fnd_file.put_line (fnd_file.LOG,' Profile Option is not defined. Please contact system Administrator.');
                        v_last_run_date := TO_DATE ('01-JAN-1951', 'DD-MON-RRRR');
                  WHEN OTHERS
                    THEN
                        fnd_file.put_line (fnd_file.LOG,' Unable to find profile option. Please contact system Administrator: '|| SQLERRM);
                            v_last_run_date := TO_DATE ('01-JAN-1951', 'DD-MON-RRRR');
        END;
            v_last_run_date := to_date(v_profile_option_value, 'DD-MM-YYYY HH24:MI:SS');
	FND_FILE.PUT_LINE(FND_FILE.LOG,'v_profile_option_value'||v_profile_option_value);
			SELECT Listagg(fu.email_address, ', ')
         within GROUP (ORDER BY fu.user_id ) AS email_address_list into V_TOEMAIL
FROM   fnd_user_resp_groups_direct fur,
       fnd_user fu,
       fnd_responsibility fr
WHERE  fur.user_id = fu.user_id
  AND fur.responsibility_id = fr.responsibility_id
  AND fr.responsibility_key = 'XXAHBRSDEA' -- AHDEAP51237  -- Supplier Data Entry Approval
  AND Trunc (SYSDATE) BETWEEN fur.start_date AND Nvl (fur.end_date, SYSDATE)
  AND Trunc (SYSDATE) BETWEEN fr.start_date AND Nvl (fr.end_date, SYSDATE);

   IF v_last_run_date IS NOT NULL
            THEN
                v_date := NULL;
                BEGIN
                   SELECT   TO_CHAR (TO_DATE (SYSDATE), 'RRRRMMDD') file_date
                  INTO   v_date
                  FROM   DUAL;
                EXCEPTION
                   WHEN OTHERS
                   THEN
                    v_date := NULL;
                END;
                fnd_file.put_line (fnd_file.LOG,' Supplier data extraction after last run date: '|| v_last_run_date);
                  v_filename := v_date; --'AH Supplier Email Notification' || v_date || '.pdf';
      END IF;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_SERVER>'||V_SERVER||'</V_SERVER>');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_EMAIL>'||V_EMAIL||'</V_EMAIL>');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_TOEMAIL>'||V_TOEMAIL||'</V_TOEMAIL>');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_INSTANCE>'||V_INSTANCE||'</V_INSTANCE>');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_FILENAME>'||V_FILENAME||'</V_FILENAME>');

FOR r_supplier IN c_supplier(v_last_run_date)
      LOOP
      NULL;
          v_sno := v_sno + 1;
		  l_full_name := null;
		  l_published_by := null;
		BEGIN
		SELECT  papf.full_name into l_full_name
		FROM fnd_user fu,
			per_all_people_f papf
			WHERE fu.employee_id(+) = papf.person_id
			AND SYSDATE BETWEEN papf.effective_start_date
			AND papf.effective_end_date
			and user_id = r_supplier.last_updated_by;

		  EXCEPTION
				WHEN OTHERS THEN
				l_full_name := null;
		END;

		BEGIN
		SELECT  papf.full_name into l_published_by
		FROM fnd_user fu,
			per_all_people_f papf
			WHERE fu.employee_id(+) = papf.person_id
			AND SYSDATE BETWEEN papf.effective_start_date
			AND papf.effective_end_date
			and user_name = r_supplier.PUBLISHED_BY;

		  EXCEPTION
				WHEN OTHERS THEN
				l_published_by := null;
		END;


            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER>');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<V_SNO>'||v_sno||'</V_SNO>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER_NAME>'||r_supplier.SUPPLIER_NAME||'</SUPPLIER_NAME>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SUPPLIER_NUMBER>'||r_supplier.SUPPLIER_NUMBER||'</SUPPLIER_NUMBER>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PUBLICATION_DATE>'||r_supplier.PUBLICATION_DATE||'</PUBLICATION_DATE>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PUBLISHED_BY>'||l_published_by||'</PUBLISHED_BY>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<LAST_UPDATE_DATE>'||r_supplier.last_update_date||'</LAST_UPDATE_DATE>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<LAST_UPDATED_BY>'||l_full_name||'</LAST_UPDATED_BY>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER>');
      END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SUPPLIER_INFO>');

      BEGIN
          v_flag := fnd_profile.SAVE('XXAH_SUPPLIER_EMAIL_NOTIFI_PROG_LAST_RUN_DATE',-- SYSDATE
            TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')
            ,'SITE');
          EXCEPTION
             WHEN OTHERS
             THEN
              fnd_file.put_line (fnd_file.LOG,'Unable to update profile value to current date.'|| SQLERRM);
              NULL;
        END;
		IF v_sno > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitting the XML Bursting');
            v_req_id := fnd_request.submit_request
                        ('XDO'
                        ,'XDOBURSTREP'
                        ,NULL
                        ,SYSDATE
                        ,FALSE
                        ,NULL --'Y'  ---xdo_cp_data_security_pkg.get_concurrent_request_ids
                        ,g_request_id
                        ,'Y');

IF v_req_id = 0
  THEN
    fnd_file.put_line(fnd_file.log,'Bursting program failed');
  END IF;  -- v_req_id = 0

  end IF;

END P_MAIN;

END XXAH_AP_SUPPL_EMAIL_PKG; 

/
