--------------------------------------------------------
--  DDL for Package Body JG_ZZ_RGRH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_RGRH_PKG" 
-- $Header: jgzzrgrhb.pls 120.3 2008/01/21 10:56:47 spasupun ship $
AS

function BEFOREREPORT_006 return boolean is
org_id NUMBER;
site_id NUMBER;
x_return_status VARCHAR2(100);
x_msg_count NUMBER;
x_msg_data  VARCHAR2(100);
x_registration_number VARCHAR2(100);
x_me_party_id number;
begin
  org_id := MO_GLOBAL.get_current_org_id;

--  P_COUNTRY_CODE:= JG_ZZ_SHARED_PKG.GET_COUNTRY(org_id);
    P_COUNTRY_CODE:= JG_ZZ_COMMON_PKG.get_legal_entity_country_code(P_LEGAL_ENTITY_ID);

  IF (P_COUNTRY_CODE = 'IT') THEN
    P_ADDRESS1  := 'substr(address_line_1,1,60)';
    P_ADDRESS2  := 'nvl(substr(address_line_2,1,60),postal_code||'' ''||town_or_city||'' - ''||''Italy'')';
    P_ADDRESS3  := 'decode(substr(address_line_2,1,60),null,null,postal_code||'' ''||town_or_city||''- ''||''Italy'')';
    P_FISCAL_CODE      := 'registration_number';
    P_FISCAL_COMPANY_NAME := 'name';
    BEGIN
    SELECT etbp.party_id INTO x_me_party_id FROM XLE_ETB_PROFILES etbp
    WHERE etbp.main_establishment_flag = 'Y'
    AND etbp.legal_entity_id = P_LEGAL_ENTITY_ID;
    IF x_me_party_id is not null THEN
	 x_registration_number := ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_party_id => x_me_party_id,
                            p_party_type => 'LEGAL_ESTABLISHMENT',
                            p_effective_date =>sysdate);
    end IF;
    P_VAT_REG := x_registration_number ;
    IF P_TOTAL_PAGES_REQUIRED = 'Y' THEN
        C_TOTAL_PAGES := '/ ' || (P_START_PAGE_NUMBER + P_PAGES_REQUIRED -1);
    ELSE
       C_TOTAL_PAGES :=' ';
    END IF;
    P_REPORT_NAME := P_REPORT_NAME_LOV;
    Exception
    When NO_DATA_FOUND Then
         null;
    END;

 ELSIF (P_COUNTRY_CODE = 'GR') THEN
    P_GR_FISCAL_COMPANY_VALUE := 'name';
    P_GR_VAT_NUMBER  := 'registration_number';
   Begin
    Select legalauth_name into C_GR_TAX_OFFICE from xle_registrations_v
    where legal_entity_id= P_legal_entity_id and IDENTIFYING='Y';
    select activity_code into C_GR_COMPANY_ACTIVITY
    from xle_entity_profiles where legal_entity_id = P_legal_entity_id;
    select issuing_authority_site_id into site_id from xle_registrations
    where  source_id= P_LEGAL_ENTITY_ID and  source_table='XLE_ENTITY_PROFILES' and IDENTIFYING_FLAG='Y';
    select SUBSTR(address1,1,30) || country into C_GR_TAX_AREA from hz_locations
    where location_id = ( select location_id from hz_party_sites where party_site_id = site_id) ;
   Exception
    When NO_DATA_FOUND Then
         null;
   End;
    P_GR_ADDRESS  := 'substr(address_line_1,1,60) || '' '' || substr(address_line_2,1,60)';
    P_GR_CITY   := 'town_or_city';
    P_GR_POSTAL_CODE  := 'postal_code';
     IF (P_REPORT_NAME_FREE IS NOT NULL) THEN
         P_REPORT_NAME := P_REPORT_NAME_FREE;
     ELSE
         P_REPORT_NAME := P_REPORT_NAME_LOV;
     END IF;
 END IF;

  IF (P_DEBUG_FLAG = 'Y') THEN
   null;
  END IF;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  return (TRUE);
END ;
Function C_GR_TAX_OFFICE_formula return varchar2 is
 Begin
  return C_GR_TAX_OFFICE;
  END;
Function C_GR_COMPANY_ACTIVITY_formula return varchar2 is
  Begin
  return C_GR_COMPANY_ACTIVITY;
  END;
Function C_GR_TAX_AREA_formula return varchar2 is
 Begin
  return C_GR_TAX_AREA;
 END;
Function C_TOTAL_PAGES_formula return varchar2 is
 Begin
  return C_TOTAL_PAGES;
  END;
Function C_COUNTRY_NAME_formula return varchar2 is
 Begin
  return C_COUNTRY_NAME;
 END;
END JG_ZZ_RGRH_PKG ;

/
