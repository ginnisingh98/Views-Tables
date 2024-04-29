--------------------------------------------------------
--  DDL for Package Body ASF_OSI_DENORM_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_OSI_DENORM_REF" as
/* $Header: custom_asxosidb.pls 115.5.1157.2 2002/02/21 09:11:43 pkm ship      $ */

--
-- HISTORY
--
-- CHSIN 28-FEB-2000 CREATED


PROCEDURE Refresh_OSI_Denorm(ERRBUF OUT varchar2,
					RETCODE OUT varchar2) IS

    CURSOR c_osi_denorm IS
	SELECT
		 contractLeads.last_update_date last_update_date,
		 contractLeads.last_updated_by last_updated_by,
		 contractLeads.creation_date creation_date,
		 contractLeads.created_by created_by,
		 nvl(contractLeads.last_update_login,1) last_update_login,
		 contractLeads.osi_lead_id osi_lead_id,
		 contractLeads.lead_id lead_id,
		 contractNames.contr_name  contract_name,
		 contractLeads.cname_id contract_name_id,
		 contractVehicles.vehicle  contract_vehicle,
		 contractLeads.cvehicle contract_vhcl_id,
		 contractLeads.contr_type contract_type,
		 contractLeads.bom_person_id bom_person_id,
		 contractLeads.legal_person_id legal_person_id,
		 contractLeads.senior_contr_person_id senior_contr_person_id,
		 contractLeads.contr_spec_person_id cont_spec_person_id,
		 contractLeads.CONTR_DRAFTING_REQ CONTR_DRAFTING_REQ,
		 contractLeads.PRIORITY PRIORITY,
		 contractLeads.HIGHEST_APVL HIGHEST_APVL,
		 contractLeads.CURRENT_APVL_STATUS CURRENT_APVL_STATUS,
		 contractLeads.SUPPORT_APVL SUPPORT_APVL,
		 contractLeads.INTERNATIONAL_APVL INTERNATIONAL_APVL,
		 contractLeads.CREDIT_APVL CREDIT_APVL,
		 contractLeads.FIN_ESCROW_REQ FIN_ESCROW_REQ,
		 contractLeads.FIN_ESCROW_STATUS FIN_ESCROW_STATUS,
		 contractLeads.CSI_ROLLIN CSI_ROLLIN,
		 contractLeads.LICENCE_CREDIT_VER LICENCE_CREDIT_VER,
		 contractLeads.SUPPORT_CREDIT_VER SUPPORT_CREDIT_VER,
		 contractLeads.MD_DEAL_SUMMARY MD_DEAL_SUMMARY,
		 contractLeads.PROD_AVAIL_VER PROD_AVAIL_VER,
		 contractLeads.SHIP_LOCATION SHIP_LOCATION,
		 contractLeads.TAX_EXEMPT_CERT TAX_EXEMPT_CERT,
		 contractLeads.NL_REV_ALLOC_REQ NL_REV_ALLOC_REQ,
		 contractLeads.SENIOR_CONTR_NOTES SENIOR_CONTR_NOTES,
		 contractLeads.LEGAL_NOTES LEGAL_NOTES,
		 contractLeads.BOM_NOTES BOM_NOTES,
		 contractLeads.CONTR_NOTES CONTR_NOTES,
		 contractLeads.PO_FROM PO_FROM,
		 nvl(poFrom.lkp_value,contractLeads.PO_FROM) PO_FROM_DISP,
		 nvl(contrType.lkp_value,contractLeads.CONTR_TYPE) CONTRACT_TYPE_DISP,
		 contractLeads.CONSULTING_CC CONSULTING_CC,
		 nvl(consCcs.center_name,contractLeads.CONSULTING_CC) CONSULTING_CC_DISP,
		 contractLeads.CONTR_STATUS CONTR_STATUS,
		 contractLeads.RTS_ID RTS_ID,
		 contractLeads.EXTRA_DOCS EXTRA_DOCS
	FROM
		 AS_OSI_CONTR_NAMES_BASE contractNames,
		 AS_OSI_CONTR_VHCL_BASE  contractVehicles,
	       AS_OSI_LEADS_ALL        contractLeads
            ,AS_OSI_LOOKUP     poFrom
            ,AS_OSI_LOOKUP     contrType
            ,as_osi_cons_ccs_base     consCcs
      WHERE  contractNames.CNAME_ID(+)= contractLeads.CNAME_ID
	  AND  contractVehicles.CVEHICLE(+) = contractLeads.CVEHICLE
        AND poFrom.lkp_type(+)='PO_FROM'
        AND poFrom.lkp_code(+)=contractLeads.PO_FROM
        AND contrType.lkp_type(+)='CONTR_TYPE'
        AND contrType.lkp_code(+)=contractLeads.CONTR_TYPE
        AND consCcs.cc(+)=contractLeads.CONSULTING_CC
          ;

    curr_rec  c_osi_denorm%ROWTYPE;

    cursor c_osi_ovl_denorm (p_osi_lead_id in number) is
	SELECT
		 contractDetails.ovm_code ovm_code,
		 contractOverlay.ovm_value                     ovm_value
	FROM
		 AS_OSI_OVERLAY_BASE     contractOverlay,
		 AS_OSI_LEAD_OVL_ALL     contractDetails
     WHERE  contractDetails.OSI_LEAD_ID = p_osi_lead_id
	  AND  contractOverlay.OVM_CODE(+) = contractDetails.OVM_CODE
     order by 1;


    TYPE rOvmRecType is record (ovm_code varchar2(30),ovm_value varchar2(30));
    TYPE tOvmRecTabType is TABLE OF rOvmRecType INDEX BY BINARY_INTEGER;
    tOvmTab tOvmRecTabType;
    vOvmCount integer;
    vCombinedOvmCode varchar2(2000);
    vCombinedOvmValue varchar2(2000);
    vOvmDelimiter varchar2(1);
    v_CursorID        NUMBER;
    v_Stmt            VARCHAR2(500);
    v_Dummy           INTEGER;


BEGIN

--	LOCK TABLE as_sales_credits_denorm in EXCLUSIVE mode;
    RETCODE := '0';

    v_CursorID := DBMS_SQL.OPEN_CURSOR;
    v_Stmt := 'TRUNCATE TABLE OSM.AS_OSI_LEADS_DENORM reuse storage';
    dbms_sql.parse(v_CursorID,v_Stmt ,dbms_sql.native);
    v_Dummy := DBMS_SQL.EXECUTE(v_CursorID);
    DBMS_SQL.CLOSE_CURSOR(v_CursorID);


    OPEN c_osi_denorm;
    LOOP

        FETCH c_osi_denorm INTO curr_rec;
	EXIT when  c_osi_denorm%NOTFOUND;
--      vCombinedOvmCode := null;
      vCombinedOvmValue := null;
      vOvmDelimiter := null;
      vOvmCount := 0;
      for ovl in c_osi_ovl_denorm(curr_rec.osi_lead_id) loop
--        vCombinedOvmCode := vCombinedOvmCode || vOvmDelimiter || ovl.ovm_code;
        vCombinedOvmValue := vCombinedOvmValue || vOvmDelimiter || ovl.ovm_value;
        vOvmDelimiter := '\';
        vOvmCount := vOvmCount + 1;
        tOvmTab(vOvmCount).ovm_code := ovl.ovm_code;
        tOvmTab(vOvmCount).ovm_value := ovl.ovm_value;
      end loop;
      if vOvmCount = 0 then
        vOvmCount := 1;
        tOvmTab(vOvmCount).ovm_code := null;
        tOvmTab(vOvmCount).ovm_value := null;
      end if;
      BEGIN
      for i in 1..vOvmCount loop
  	  INSERT INTO AS_OSI_LEADS_DENORM
	     (last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login
		,OSI_LEAD_ID
		,LEAD_ID
		,CONTRACT_NAME
		,CONTRACT_NAME_ID
		,CONTRACT_VEHICLE
		,CONTRACT_VHCL_ID
		,CONTRACT_TYPE
		,OVM_CODE
		,OVM_VALUE
		,combined_OVM_VALUE
		,BOM_PERSON_ID
		,LEGAL_PERSON_ID
		,SENIOR_CONTR_PERSON_ID
		,CONT_SPEC_PERSON_ID
            ,CONTR_DRAFTING_REQ
            ,PRIORITY
            ,HIGHEST_APVL
            ,CURRENT_APVL_STATUS
            ,SUPPORT_APVL
            ,INTERNATIONAL_APVL
            ,CREDIT_APVL
            ,FIN_ESCROW_REQ
            ,FIN_ESCROW_STATUS
            ,CSI_ROLLIN
            ,LICENCE_CREDIT_VER
            ,SUPPORT_CREDIT_VER
            ,MD_DEAL_SUMMARY
            ,PROD_AVAIL_VER
            ,SHIP_LOCATION
            ,TAX_EXEMPT_CERT
            ,NL_REV_ALLOC_REQ
            ,SENIOR_CONTR_NOTES
            ,LEGAL_NOTES
            ,BOM_NOTES
            ,CONTR_NOTES
            ,PO_FROM
            ,PO_FROM_DISP
            ,CONTRACT_TYPE_DISP
            ,CONSULTING_CC
            ,CONSULTING_CC_DISP
            ,CONTR_STATUS
            ,RTS_ID
            ,EXTRA_DOCS
		)
	  VALUES
	     (curr_rec.last_update_date,
		 curr_rec.last_updated_by,
		 curr_rec.creation_date,
		 curr_rec.created_by,
		 curr_rec.last_update_login,
		 curr_rec.osi_lead_id,
		 curr_rec.lead_id,
		 curr_rec.contract_name,
		 curr_rec.contract_name_id,
		 curr_rec.contract_vehicle,
		 curr_rec.contract_vhcl_id,
		 curr_rec.contract_type,
             tOvmTab(i).ovm_code,
             tOvmTab(i).ovm_value,
		 vCombinedOvmValue,
		 curr_rec.bom_person_id,
		 curr_rec.legal_person_id,
		 curr_rec.senior_contr_person_id,
		 curr_rec.cont_spec_person_id
            ,curr_rec.CONTR_DRAFTING_REQ
            ,curr_rec.PRIORITY
            ,curr_rec.HIGHEST_APVL
            ,curr_rec.CURRENT_APVL_STATUS
            ,curr_rec.SUPPORT_APVL
            ,curr_rec.INTERNATIONAL_APVL
            ,curr_rec.CREDIT_APVL
            ,curr_rec.FIN_ESCROW_REQ
            ,curr_rec.FIN_ESCROW_STATUS
            ,curr_rec.CSI_ROLLIN
            ,curr_rec.LICENCE_CREDIT_VER
            ,curr_rec.SUPPORT_CREDIT_VER
            ,curr_rec.MD_DEAL_SUMMARY
            ,curr_rec.PROD_AVAIL_VER
            ,curr_rec.SHIP_LOCATION
            ,curr_rec.TAX_EXEMPT_CERT
            ,curr_rec.NL_REV_ALLOC_REQ
            ,curr_rec.SENIOR_CONTR_NOTES
            ,curr_rec.LEGAL_NOTES
            ,curr_rec.BOM_NOTES
            ,curr_rec.CONTR_NOTES
            ,curr_rec.PO_FROM
            ,curr_rec.PO_FROM_DISP
            ,curr_rec.CONTRACT_TYPE_DISP
            ,curr_rec.CONSULTING_CC
            ,curr_rec.CONSULTING_CC_DISP
            ,curr_rec.CONTR_STATUS
            ,curr_rec.RTS_ID
            ,curr_rec.EXTRA_DOCS
		);

      end loop;
      EXCEPTION
	  WHEN OTHERS THEN
		ERRBUF := sqlerrm;
		RETCODE := '1';
		--dbms_output.put_line(SQLERRM);
      END;
    END LOOP;
    COMMIT;
    CLOSE c_osi_denorm;
EXCEPTION
	WHEN OTHERS THEN
	ERRBUF := 'Error to refresh amount:'||to_char(sqlcode);
	--dbms_output.put_line(ERRBUF);
	--dbms_output.put_line(SQLERRM);
	RETCODE := '2';

END Refresh_OSI_Denorm;



END ASF_OSI_DENORM_REF;

/
