--------------------------------------------------------
--  DDL for Package Body WSH_ITM_PARTY_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_PARTY_SYNC" AS
/* $Header: WSHITPSB.pls 120.5.12010000.4 2010/04/16 08:59:47 gbhargav ship $ */

        G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_PARTY_SYNC';

        /*===========================================================================+
        | PROCEDURE                                                                 |
        |              POPULATE_DATA                                                |
        |                                                                           |
        | DESCRIPTION                                                               |
        |              This procedure is called when the Party Synchronization      |
        |              Concurrent Program is launched. It populates the data        |
        |              into WSH_ITM_REQUEST_CONTROL and WSH_ITM_PARTIES             |
        |              based on the parameters selected.                            |
        |                                                                           |
        +===========================================================================*/

        PROCEDURE POPULATE_DATA (
                               errbuf               OUT NOCOPY   VARCHAR2,
                                retcode              OUT NOCOPY   NUMBER,
                                p_party_type         IN VARCHAR2 ,
                                p_from_party_code    IN VARCHAR2 ,
                                p_to_party_code      IN VARCHAR2 ,
                                p_dummy              IN NUMBER DEFAULT NULL,
                                p_site_use_code      IN VARCHAR2 ,
                                p_created_n_days     IN NUMBER ,
                                p_updated_n_days     IN NUMBER
                                )IS
            l_SQLQuery          VARCHAR2(12000);

            l_CustSQLQuery      VARCHAR2(12000) := ' SELECT                      '||
                                                      'site_uses.site_use_id        source_id,'||
                                                      'party.party_id               party_id, '||
                                                      'party_site.party_site_id     party_site_id, '||
                                                      'acct_site.cust_account_id    custAcctId,'||
                                                      'site_uses.site_use_code      partnrtype,'||
                                                      'party.party_name             party_name,'||
                                                      'decode(party.party_type,''ORGANIZATION'',party.organization_name_phonetic,person_profile.person_name_phonetic) alternate_name,'||
                                                      'party.tax_reference         tax_reference,'||
                                                      'loc.address1                 address1,'||
                                                      'loc.address2                 address2,'||
                                                      'loc.address3                 address3,'||
                                                      'loc.address4                 address4,'||
                                                      'loc.city                      city,'||
                                                      'loc.state                     state,'||
                                                      'loc.country                   country,'||
                                                      'loc.postal_code               postal_code,'||
                                                      'acct.account_number           acct_number,'||
                                                      'acct.account_name             acct_name,'||
                                                      'party_site.party_site_number  site_number,'||
                                                      'acct.attribute1              acct_attribute1,'||
                                                      'acct.attribute2              acct_attribute2,'||
                                                      'acct.attribute3              acct_attribute3,'||
                                                      'acct.attribute4              acct_attribute4,'||
                                                      'acct.attribute5              acct_attribute5,'||
                                                      'acct.attribute6              acct_attribute6,'||
                                                      'acct.attribute7              acct_attribute7,'||
                                                      'acct.attribute8              acct_attribute8,'||
                                                      'acct.attribute9              acct_attribute9,'||
                                                      'acct.attribute10             acct_attribute10,'||
                                                      'acct.attribute11             acct_attribute11,'||
                                                      'acct.attribute12             acct_attribute12,'||
                                                      'acct.attribute13             acct_attribute13,'||
                                                      'acct.attribute14             acct_attribute14,'||
                                                      'acct.attribute15             acct_attribute15,'||
                                                      'acct_site.attribute1         acct_site_attribute1,'||
                                                      'acct_site.attribute2         acct_site_attribute2,'||
                                                      'acct_site.attribute3         acct_site_attribute3,'||
                                                      'acct_site.attribute4         acct_site_attribute4,'||
                                                      'acct_site.attribute5         acct_site_attribute5,'||
                                                      'acct_site.attribute6         acct_site_attribute6,'||
                                                      'acct_site.attribute7         acct_site_attribute7,'||
                                                      'acct_site.attribute8         acct_site_attribute8,'||
                                                      'acct_site.attribute9         acct_site_attribute9,'||
                                                      'acct_site.attribute10        acct_site_attribute10,'||
                                                      'acct_site.attribute11        acct_site_attribute11,'||
                                                      'acct_site.attribute12        acct_site_attribute12,'||
                                                      'acct_site.attribute13        acct_site_attribute13,'||
                                                      'acct_site.attribute14        acct_site_attribute14,'||
                                                      'acct_site.attribute15        acct_site_attribute15, ' ||
                                                      'acct_site.org_id             operating_unit,'  ||
                                                      'site_uses.primary_flag       address_type, ' ||
                                                      'party.party_number           hz_party_number, ' ||  -- gtm related v
                                                      'PARTY.PARTY_TYPE             HZ_PARTY_TYPE, '||
                                                      'PARTY.STATUS                 HZ_PARTY_STATUS, '||
                                                      'PARTY.HQ_BRANCH_IND          HZ_HQ_BRANCH_IND, '||
                                                      'PARTY.SIC_CODE               HZ_SIC_CODE, '||
                                                      'PARTY.SIC_CODE_TYPE          HZ_SIC_CODE_TYPE, '||
                                                      'PARTY.PERSON_FIRST_NAME         PERSON_FIRST_NAME, '||
                                                      'PARTY.PERSON_MIDDLE_NAME        PERSON_MIDDLE_NAME, '||
                                                      'PARTY.PERSON_LAST_NAME          PERSON_LAST_NAME, '||
                                                      'LOC.LOCATION_ID              HZ_LOCATION_ID, '||
                                                      'PARTY.COUNTRY                HZ_COUNTRY, '||
                                                      'PARTY.ADDRESS1               HZ_ADDRESS1, '||
                                                      'PARTY.ADDRESS2               HZ_ADDRESS2, '||
                                                      'PARTY.ADDRESS3               HZ_ADDRESS3, '||
                                                      'PARTY.ADDRESS4               HZ_ADDRESS4, '||
                                                      'PARTY.CITY                   HZ_CITY, '||
                                                      'PARTY.POSTAL_CODE            HZ_POSTAL_CODE, '||
                                                      'PARTY.STATE                  HZ_STATE, '||
                                                      'PARTY.PROVINCE               HZ_PROVINCE, '||
                                                      'PARTY.COUNTY                 HZ_COUNTY '||
                                                ' FROM '||
                                                    'hz_cust_site_uses_all   site_uses,'||
                                                    'hz_cust_acct_sites_all  acct_site,'||
                                                    'hz_cust_accounts        acct,'||
                                                    'hz_party_sites          party_site,'||
                                                    'hz_parties              party,'||
                                                    'hz_locations            loc ,'||
                                                    'hz_Person_profiles      person_profile '||
                                                'WHERE '||
                                                  ' site_uses.CUST_ACCT_SITE_ID     = acct_site.CUST_ACCT_SITE_ID'||
                                                    ' AND acct_site.PARTY_SITE_ID   = party_site.PARTY_SITE_ID'||
                                                    ' AND party_site.PARTY_ID       = party.PARTY_ID'||
                                                    ' AND loc.LOCATION_ID           = party_site.LOCATION_ID'||
                                                    ' AND acct.CUST_ACCOUNT_ID      = acct_site.CUST_ACCOUNT_ID'||
                                                    ' AND acct.STATUS               = ''A'' '||
                                                    ' AND party.PARTY_ID            = person_profile.PARTY_ID(+) ';

                l_ContactQuery  VARCHAR2(1000) :=  ' OR party.party_id IN' || --TCA view removal starts
                                                    '( SELECT hr.object_id  FROM hz_relationships hr,' ||
                                                    ' hz_Parties hp,' ||
                                                    'hz_contact_points hcp,' ||
                                                    ' hz_org_contacts hoc' ||
                                                    ' WHERE '||
                                                    ' hr.subject_table_name = ''HZ_PARTIES'' ' ||
                                                    ' AND hr.object_table_name =''HZ_PARTIES'' '  ||
                                                    ' AND hr.directional_flag = ''F'' '  ||
                                                    ' AND hr.relationship_type = ''CONTACT_OF'' '||
                                                    ' AND   hr.subject_id = hp.party_id '||
                                                    ' AND   hcp.owner_table_id = hr.party_id '||
                                                    ' AND   hoc.party_relationship_id = hr.relationship_id '; --TCA view removal ends




            l_CarrierSQLQuery      VARCHAR2(12000) := ' SELECT                      '||
                                                      'to_number(null)              source_id,'||
                                                      'party.party_id               party_id, '||
                                                      'party_site.party_site_id     party_site_id, '||
                                                      'to_number(null)              custAcctId,'||
                                                      '''CARRIER''                  partnrtype,'||
                                                      'party.party_name             party_name,'||
                                                      'party.organization_name_phonetic alternate_name,'||
                                                      'party.tax_reference         tax_reference,'||
                                                      'loc.address1                 address1,'||
                                                      'loc.address2                 address2,'||
                                                      'loc.address3                 address3,'||
                                                      'loc.address4                 address4,'||
                                                      'loc.city                      city,'||
                                                      'loc.state                     state,'||
                                                      'loc.country                   country,'||
                                                      'loc.postal_code               postal_code,'||
                                                      'to_char(null)                 acct_number,'||
                                                      'to_char(null)                 acct_name,'||
                                                      'party_site.party_site_number  site_number,'||
                                                      'party.attribute1             acct_attribute1,'||
                                                      'party.attribute2             acct_attribute2,'||
                                                      'party.attribute3             acct_attribute3,'||
                                                      'party.attribute4             acct_attribute4,'||
                                                      'party.attribute5             acct_attribute5,'||
                                                      'party.attribute6             acct_attribute6,'||
                                                      'party.attribute7             acct_attribute7,'||
                                                      'party.attribute8             acct_attribute8,'||
                                                      'party.attribute9             acct_attribute9,'||
                                                      'party.attribute10            acct_attribute10,'||
                                                      'party.attribute11            acct_attribute11,'||
                                                      'party.attribute12            acct_attribute12,'||
                                                      'party.attribute13            acct_attribute13,'||
                                                      'party.attribute14            acct_attribute14,'||
                                                      'party.attribute15            acct_attribute15,'||
                                                      'party_site.attribute1        acct_site_attribute1,'||
                                                      'party_site.attribute2        acct_site_attribute2,'||
                                                      'party_site.attribute3        acct_site_attribute3,'||
                                                      'party_site.attribute4        acct_site_attribute4,'||
                                                      'party_site.attribute5        acct_site_attribute5,'||
                                                      'party_site.attribute6        acct_site_attribute6,'||
                                                      'party_site.attribute7        acct_site_attribute7,'||
                                                      'party_site.attribute8        acct_site_attribute8,'||
                                                      'party_site.attribute9        acct_site_attribute9,'||
                                                      'party_site.attribute10       acct_site_attribute10,'||
                                                      'party_site.attribute11       acct_site_attribute11,'||
                                                      'party_site.attribute12       acct_site_attribute12,'||
                                                      'party_site.attribute13       acct_site_attribute13,'||
                                                      'party_site.attribute14       acct_site_attribute14,'||
                                                      'party_site.attribute15       acct_site_attribute15,' ||
                                                      ' null, ' ||
                                                      'party_site.identifying_address_flag  address_type,' ||
                                                      'party.party_number           hz_party_number, ' ||  -- gtm related v
                                                      'PARTY.PARTY_TYPE             HZ_PARTY_TYPE, '||
                                                      'PARTY.STATUS                 HZ_PARTY_STATUS, '||
                                                      'PARTY.HQ_BRANCH_IND          HZ_HQ_BRANCH_IND, '||
                                                      'PARTY.SIC_CODE               HZ_SIC_CODE, '||
                                                      'PARTY.SIC_CODE_TYPE          HZ_SIC_CODE_TYPE, '||
                                                      'PARTY.PERSON_FIRST_NAME         PERSON_FIRST_NAME, '||
                                                      'PARTY.PERSON_MIDDLE_NAME        PERSON_MIDDLE_NAME, '||
                                                      'PARTY.PERSON_LAST_NAME          PERSON_LAST_NAME, '||
                                                      'LOC.LOCATION_ID              HZ_LOCATION_ID, '||
                                                      'PARTY.COUNTRY                HZ_COUNTRY, '||
                                                      'PARTY.ADDRESS1               HZ_ADDRESS1, '||
                                                      'PARTY.ADDRESS2               HZ_ADDRESS2, '||
                                                      'PARTY.ADDRESS3               HZ_ADDRESS3, '||
                                                      'PARTY.ADDRESS4               HZ_ADDRESS4, '||
                                                      'PARTY.CITY                   HZ_CITY, '||
                                                      'PARTY.POSTAL_CODE            HZ_POSTAL_CODE, '||
                                                      'PARTY.STATE                  HZ_STATE, '||
                                                      'PARTY.PROVINCE               HZ_PROVINCE, '||
                                                      'PARTY.COUNTY                 HZ_COUNTY '||
                                                ' FROM '||
                                                      'hz_party_sites          party_site,'||
                                                      'hz_parties              party,'||
                                                      'hz_locations            loc ,'||
                                                      'wsh_carriers_v            wsh_car '||
                                                'WHERE '||
                                                    ' party_site.party_id   = party.party_id'||
                                                    ' AND wsh_car.ACTIVE          = ''A'' '||
                                                    ' AND party.party_id    = wsh_car.carrier_id'||
                                                    ' AND loc.location_id   = party_site.location_id';

            -- gtm : new Query
            l_GtmSQLQuery      VARCHAR2(12000) := ' SELECT                      '||
                                                      'site_uses.party_site_use_id   source_id,'||
                                                      'party.party_id               party_id, '||
                                                      'party_site.party_site_id     party_site_id, '||
                                                      'to_number(null)              custAcctId,'||
                                                      'site_uses.site_use_type      partnrtype,'||
                                                      'decode(party.party_type,''PERSON'',person_profile.person_name,party.party_name) party_name,'||
                                                      'decode(party.party_type,''ORGANIZATION'',party.organization_name_phonetic,''PERSON'',
person_profile.person_name_phonetic,party.organization_name_phonetic) alternate_name,'||
                                                      'party.tax_reference         tax_reference,'||
                                                      'loc.address1                 address1,'||
                                                      'loc.address2                 address2,'||
                                                      'loc.address3                 address3,'||
                                                      'loc.address4                 address4,'||
                                                      'loc.city                      city,'||
                                                      'loc.state                     state,'||
                                                      'loc.country                   country,'||
                                                      'loc.postal_code               postal_code,'||
                                                      'to_char(null)                 acct_number,'||
                                                      'to_char(null)                 acct_name,'||
                                                      'party_site.party_site_number  site_number,'||
                                                      'party.attribute1             acct_attribute1,'||
                                                      'party.attribute2             acct_attribute2,'||
                                                      'party.attribute3             acct_attribute3,'||
                                                      'party.attribute4             acct_attribute4,'||
                                                      'party.attribute5             acct_attribute5,'||
                                                      'party.attribute6             acct_attribute6,'||
                                                      'party.attribute7             acct_attribute7,'||
                                                      'party.attribute8             acct_attribute8,'||
                                                      'party.attribute9             acct_attribute9,'||
                                                      'party.attribute10            acct_attribute10,'||
                                                      'party.attribute11            acct_attribute11,'||
                                                      'party.attribute12            acct_attribute12,'||
                                                      'party.attribute13            acct_attribute13,'||
                                                      'party.attribute14            acct_attribute14,'||
                                                      'party.attribute15            acct_attribute15,'||
                                                      'party_site.attribute1        acct_site_attribute1,'||
                                                      'party_site.attribute2        acct_site_attribute2,'||
                                                      'party_site.attribute3        acct_site_attribute3,'||
                                                      'party_site.attribute4        acct_site_attribute4,'||
                                                      'party_site.attribute5        acct_site_attribute5,'||
                                                      'party_site.attribute6        acct_site_attribute6,'||
                                                      'party_site.attribute7        acct_site_attribute7,'||
                                                      'party_site.attribute8        acct_site_attribute8,'||
                                                      'party_site.attribute9        acct_site_attribute9,'||
                                                      'party_site.attribute10       acct_site_attribute10,'||
                                                      'party_site.attribute11       acct_site_attribute11,'||
                                                      'party_site.attribute12       acct_site_attribute12,'||
                                                      'party_site.attribute13       acct_site_attribute13,'||
                                                      'party_site.attribute14       acct_site_attribute14,'||
                                                      'party_site.attribute15       acct_site_attribute15,' ||
                                                      ' null, ' ||
                                                      'party_site.identifying_address_flag  address_type, ' ||
                                                      'party.party_number           hz_party_number, ' ||
                                                      'PARTY.PARTY_TYPE             HZ_PARTY_TYPE, '||
                                                      'PARTY.STATUS                 HZ_PARTY_STATUS, '||
                                                      'PARTY.HQ_BRANCH_IND          HZ_HQ_BRANCH_IND, '||
                                                      'PARTY.SIC_CODE               HZ_SIC_CODE, '||
                                                      'PARTY.SIC_CODE_TYPE          HZ_SIC_CODE_TYPE, '||
                                                      'PARTY.PERSON_FIRST_NAME         PERSON_FIRST_NAME, '||
                                                      'PARTY.PERSON_MIDDLE_NAME        PERSON_MIDDLE_NAME, '||
                                                      'PARTY.PERSON_LAST_NAME          PERSON_LAST_NAME, '||
                                                      'LOC.LOCATION_ID              HZ_LOCATION_ID, '||
                                                      'PARTY.COUNTRY                HZ_COUNTRY, '||
                                                      'PARTY.ADDRESS1               HZ_ADDRESS1, '||
                                                      'PARTY.ADDRESS2               HZ_ADDRESS2, '||
                                                      'PARTY.ADDRESS3               HZ_ADDRESS3, '||
                                                      'PARTY.ADDRESS4               HZ_ADDRESS4, '||
                                                      'PARTY.CITY                   HZ_CITY, '||
                                                      'PARTY.POSTAL_CODE            HZ_POSTAL_CODE, '||
                                                      'PARTY.STATE                  HZ_STATE, '||
                                                      'PARTY.PROVINCE               HZ_PROVINCE, '||
                                                      'PARTY.COUNTY                 HZ_COUNTY '||
                                                ' FROM '||
                                                      'hz_party_sites          party_site,'||
                                                      'hz_party_site_uses      site_uses,'||
                                                      'hz_parties              party,'||
                                                      'hz_locations            loc, '||
                                                      'hz_Person_profiles      person_profile '||
                                                'WHERE '||
                                                    ' party_site.party_id (+)   = party.party_id'||
                                                    ' AND party_site.party_site_id  = site_uses.party_site_id (+) '||
                                                    ' AND party.status      in  ( ''A'', ''M'', ''D'') '||
                                                    ' AND party.PARTY_ID    = person_profile.PARTY_ID(+) '||
                                                    ' AND loc.location_id (+)   = party_site.location_id';

             -- gtm: Cursor to Check for GTM Flows
            CURSOR cur_check_gtm_flows IS
             SELECT  decode (wits.value, 'FALSE', 'N', null, 'N', 'TRUE', 'Y', 'N')
                FROM wsh_itm_parameter_setups_b wits
            WHERE wits.PARAMETER_NAME = 'WSH_ITM_INTG_GTM';

            -- gtm
            l_itm_intg_gtm                VARCHAR2(1) := 'N';

            l_Party_Table                    WSH_ITM_QUERY_CUSTOM.g_CondnValTableType;

            l_Party_Condn1Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
	    l_Party_Condn11Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
            l_Party_Condn2Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
            l_Party_Condn3Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
            l_Party_Condn4Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;


            l_Carrier_Table                    WSH_ITM_QUERY_CUSTOM.g_CondnValTableType;

            l_Carrier_Condn1Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
	    l_Carrier_Condn11Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
            l_Carrier_Condn2Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
            l_Carrier_Condn3Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;

            -- gtm
            l_gtm_Condn1Tab                    WSH_ITM_QUERY_CUSTOM.g_ValueTableType;


            l_tempStr1       VARCHAR2(10000) := ' ';
            l_tempStr2       VARCHAR2(10000) := ' ';
            l_CursorID      NUMBER;
            l_ignore        NUMBER;

            --PL/SQL Table used for Bulk Select
            l_num_sourceID_tab         		DBMS_SQL.Number_Table;
            l_num_custAccountID_tab    		DBMS_SQL.Number_Table;
            l_num_hzpartyID_tab        		DBMS_SQL.Number_Table;

            l_num_hzpartySiteID_tab    		DBMS_SQL.Number_Table;
            l_num_itmpartyID_tab       		DBMS_SQL.Number_Table;

            l_num_partyrel_tab              DBMS_SQL.Number_Table;
            l_varchar_PartnrType_tab   		DBMS_SQL.Varchar2_Table;
            l_varchar_PartyName_tab    		DBMS_SQL.Varchar2_Table;
            l_varchar_AlternateName_tab	        DBMS_SQL.Varchar2_Table;
            l_varchar_Address1_tab     		DBMS_SQL.Varchar2_Table;
            l_varchar_Address2_tab     		DBMS_SQL.Varchar2_Table;
            l_varchar_Address3_tab     		DBMS_SQL.Varchar2_Table;
            l_varchar_Address4_tab     		DBMS_SQL.Varchar2_Table;
            l_varchar_City_tab         		DBMS_SQL.Varchar2_Table;
            l_varchar_State_tab        		DBMS_SQL.Varchar2_Table;
            l_varchar_Country_tab      		DBMS_SQL.Varchar2_Table;
            l_varchar_PostalCode_tab   		DBMS_SQL.Varchar2_Table;
            l_varchar_TaxRef_tab       		DBMS_SQL.Varchar2_Table;
            l_varchar_AcctNumber_tab   		DBMS_SQL.Varchar2_Table;
            l_varchar_AcctName_tab     		DBMS_SQL.Varchar2_Table;
            l_varchar_SiteNumber_tab   		DBMS_SQL.Varchar2_Table;

            -- gtm: contact start
            l_num_CtPartyId_tab            DBMS_SQL.Number_Table;
            l_varchar_CtPartyNum_tab       DBMS_SQL.Varchar2_Table;
            l_ct_alternate_name_tab        DBMS_SQL.Varchar2_Table;
            l_ct_party_type_tab            DBMS_SQL.Varchar2_Table;
            l_ct_status_tab                DBMS_SQL.Varchar2_Table;
            l_ct_first_name_tab            DBMS_SQL.Varchar2_Table;
            l_ct_middle_name_tab           DBMS_SQL.Varchar2_Table;
            l_ct_last_name_tab             DBMS_SQL.Varchar2_Table;
            l_ct_country_tab               DBMS_SQL.Varchar2_Table;
            l_ct_address1_tab              DBMS_SQL.Varchar2_Table;
            l_ct_address2_tab              DBMS_SQL.Varchar2_Table;
            l_ct_address3_tab              DBMS_SQL.Varchar2_Table;
            l_ct_address4_tab              DBMS_SQL.Varchar2_Table;
            l_ct_city_tab                  DBMS_SQL.Varchar2_Table;
            l_ct_postal_code_tab           DBMS_SQL.Varchar2_Table;
            l_ct_state_tab                 DBMS_SQL.Varchar2_Table;
            l_ct_province_tab              DBMS_SQL.Varchar2_Table;
            l_ct_county_tab                DBMS_SQL.Varchar2_Table;    -- gtm related: end

            l_varchar_CtPartyName_tab       DBMS_SQL.Varchar2_Table;
            l_varchar_CtPointType_tab       DBMS_SQL.Varchar2_Table;
            l_varchar_ctEmail_tab           DBMS_SQL.Varchar2_Table;
            l_varchar_ctPhone_tab           DBMS_SQL.Varchar2_Table;
            l_varchar_ctFax_tab             DBMS_SQL.Varchar2_Table;

            l_varchar_tempAttrib1_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib2_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib3_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib4_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib5_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib6_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib7_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib8_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib9_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib10_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib11_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib12_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib13_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib14_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_tempAttrib15_tab    DBMS_SQL.Varchar2_Table;


            l_varchar_rcAttrib1_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib2_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib3_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib4_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib5_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib6_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib7_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib8_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib9_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib10_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib11_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib12_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib13_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib14_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_rcAttrib15_tab    DBMS_SQL.Varchar2_Table;


            l_varchar_Attrib1_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib2_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib3_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib4_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib5_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib6_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib7_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib8_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib9_tab     DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib10_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib11_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib12_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib13_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib14_tab    DBMS_SQL.Varchar2_Table;
            l_varchar_Attrib15_tab    DBMS_SQL.Varchar2_Table;

	    --Bug 7297690 Added variable to store the party site id and Org contact id of the contacts who will be screened
 	     l_org_contact_id_tab      DBMS_SQL.Number_Table;
 	     Type l_org_contact_type  is table of Varchar2(1) index by BINARY_INTEGER;
 	     l_org_contact_cache l_org_contact_type;
             Type l_party_site_id_type  is table of Varchar2(1) index by BINARY_INTEGER;
 	     l_party_site_id_cache l_party_site_id_type;

            l_operating_unit           DBMS_SQL.Number_Table;
            l_address_type             DBMS_SQL.Varchar2_Table;  -- gtm related: start
            l_hz_party_num_tab         DBMS_SQL.Varchar2_Table;
            l_hz_party_type_tab        DBMS_SQL.Varchar2_Table;
            l_hz_status_tab            DBMS_SQL.Varchar2_Table;
            l_hz_hq_branch_ind_tab     DBMS_SQL.Varchar2_Table;
            l_hz_sic_code_tab          DBMS_SQL.Varchar2_Table;
            l_hz_sic_code_type_tab     DBMS_SQL.Varchar2_Table;
            l_person_first_name_tab    DBMS_SQL.Varchar2_Table;
            l_person_middle_name_tab   DBMS_SQL.Varchar2_Table;
            l_person_last_name_tab     DBMS_SQL.Varchar2_Table;
            l_hz_location_id_tab       DBMS_SQL.Number_Table;
            l_hz_country_tab           DBMS_SQL.Varchar2_Table;
            l_hz_address1_tab          DBMS_SQL.Varchar2_Table;
            l_hz_address2_tab          DBMS_SQL.Varchar2_Table;
            l_hz_address3_tab          DBMS_SQL.Varchar2_Table;
            l_hz_address4_tab          DBMS_SQL.Varchar2_Table;
            l_hz_city_tab              DBMS_SQL.Varchar2_Table;
            l_hz_postal_code_tab       DBMS_SQL.Varchar2_Table;
            l_hz_state_tab             DBMS_SQL.Varchar2_Table;
            l_hz_province_tab          DBMS_SQL.Varchar2_Table;
            l_hz_county_tab            DBMS_SQL.Varchar2_Table;    -- gtm related: end
            l_email                 VARCHAR2(100);
            l_phone                 VARCHAR2(100);
            l_fax                   VARCHAR2(100);

            --For Insert to ITM Inteface Tables
            l_num_ReqCtrl_tab       DBMS_SQL.Number_Table;
            l_num_PartyReqCtrl_tab  DBMS_SQL.Number_Table;
            l_tempSourceID          NUMBER := -999;
            j                       NUMBER;

            l_user_id               NUMBER;
            l_login_id              NUMBER;
            l_temp                  BOOLEAN;
       	    l_LanguageCode     	    VARCHAR2(4);

             --Party name
            l_from_party      VARCHAR2(360);
            l_to_party      VARCHAR2(360);


	   CURSOR cur_customer_party_name(c_account_id varchar2) IS
	   SELECT
	      HP.party_name
		FROM
		  hz_parties HP,
		  HZ_CUST_ACCOUNTS HC
		WHERE
		  HP.PARTY_ID = HC.PARTY_ID    AND
		  hc.cust_account_id = TO_NUMBER(c_account_id);



            CURSOR cur_carrier_party_name(c_freight_code varchar2) IS
            SELECT
		  HP.PARTY_NAME
		FROM
		  WSH_CARRIERS WC,
		  HZ_PARTIES HP
		WHERE
		  HP.PARTY_ID = WC.CARRIER_ID AND
		  wc.freight_code = c_freight_code;

            -- gtm : for parties other than Customer or Carrier
            CURSOR cur_other_party_name(c_party_code varchar2) IS
            SELECT
                  HP.PARTY_NAME
                FROM
                  HZ_PARTIES HP
                WHERE
                  HP.PARTY_ID = to_number(c_party_code);

            --
            l_debug_on BOOLEAN;
            --
            l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_DATA';
            --
        BEGIN
            --Frame draft SQL

            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.push(l_module_name);
                --
                WSH_DEBUG_SV.log(l_module_name,'P_PARTY_TYPE',P_PARTY_TYPE);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_CODE',P_FROM_PARTY_CODE);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_CODE',P_TO_PARTY_CODE);
	        WSH_DEBUG_SV.log(l_module_name,'P_DUMMY',P_DUMMY);
                WSH_DEBUG_SV.log(l_module_name,'P_SITE_USE_CODE',P_SITE_USE_CODE);
                WSH_DEBUG_SV.log(l_module_name,'P_CREATED_N_DAYS',P_CREATED_N_DAYS);
                WSH_DEBUG_SV.log(l_module_name,'P_UPDATED_N_DAYS',P_UPDATED_N_DAYS);
            END IF;
            --
            --gtm flow check
            OPEN cur_check_gtm_flows;
                  FETCH cur_check_gtm_flows into l_itm_intg_gtm;
            CLOSE cur_check_gtm_flows;

            -- Fetch user and login information
            l_user_id  := FND_GLOBAL.USER_ID;
            l_login_id := FND_GLOBAL.CONC_LOGIN_ID;

           -- {
           IF p_from_party_code IS NOT NULL THEN
             -- {
             IF p_party_type = 'CUSTOMER' THEN

                        OPEN cur_customer_party_name(p_from_party_code);
                        FETCH cur_customer_party_name  into l_from_party;
                        CLOSE cur_customer_party_name;

                        l_Party_Condn1Tab(1).g_varchar_val := l_from_party;
                        l_Party_Condn1Tab(1).g_Bind_Literal := ':b_from_party';
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' AND PARTY.PARTY_NAME >= :b_from_party', l_Party_Condn1Tab, 'VARCHAR');

             ELSIF (p_party_type = 'CARRIER' ) THEN

                       OPEN cur_carrier_party_name(p_from_party_code);
                       FETCH cur_carrier_party_name  into l_from_party;
                       CLOSE cur_carrier_party_name;

                        l_Carrier_Condn1Tab(1).g_varchar_val := l_from_party;
                        l_Carrier_Condn1Tab(1).g_Bind_Literal := ':b_from_party';
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND PARTY.PARTY_NAME >= :b_from_party', l_Carrier_Condn1Tab, 'VARCHAR');

             ELSE

                       OPEN cur_other_party_name(p_from_party_code);
                       FETCH cur_other_party_name  into l_from_party;
                       CLOSE cur_other_party_name;

                       l_Carrier_Condn1Tab(1).g_varchar_val := l_from_party;
                       l_Carrier_Condn1Tab(1).g_Bind_Literal := ':b_from_party';
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND PARTY.PARTY_NAME >= :b_from_party', l_Carrier_Condn1Tab, 'VARCHAR');

             END IF; -- } party_type
           END IF; -- } party_code not null

               -- { gtm: party code
               IF p_to_party_code IS NOT NULL THEN
                    -- { : party_type
                    IF p_party_type = 'CUSTOMER' THEN

                        OPEN cur_customer_party_name(p_to_party_code);
                        FETCH cur_customer_party_name  into l_to_party;
                        CLOSE cur_customer_party_name;

                        l_Party_Condn11Tab(1).g_varchar_val := l_to_party;
                        l_Party_Condn11Tab(1).g_Bind_Literal := ':b_to_party';
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' AND PARTY.PARTY_NAME <= :b_to_party', l_Party_Condn11Tab, 'VARCHAR');

                    ELSIF (p_party_type = 'CARRIER' ) THEN

                        OPEN cur_carrier_party_name(p_to_party_code);
                        FETCH cur_carrier_party_name  into l_to_party;
                        CLOSE cur_carrier_party_name;

                        l_Carrier_Condn11Tab(1).g_varchar_val := l_to_party;
                        l_Carrier_Condn11Tab(1).g_Bind_Literal := ':b_to_party';
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND PARTY.PARTY_NAME <= :b_to_party', l_Carrier_Condn11Tab, 'VARCHAR');

                     -- gtm
                     ELSE

                        OPEN cur_other_party_name(p_to_party_code);
                        FETCH cur_other_party_name  into l_to_party;
                        CLOSE cur_other_party_name;

                        l_Carrier_Condn11Tab(1).g_varchar_val := l_to_party;
                        l_Carrier_Condn11Tab(1).g_Bind_Literal := ':b_to_party';
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND PARTY.PARTY_NAME <= :b_to_party', l_Carrier_Condn11Tab, 'VARCHAR');

                     END IF; -- } party_type
             END IF;  -- } to party_code not null

             IF ( p_party_type IS NOT NULL AND p_party_type NOT IN ('CUSTOMER','CARRIER')) THEN
             --{
                  -- gtm  : to add the Party Type (org, person etc.)
                  l_gtm_Condn1Tab(1).g_varchar_val := p_party_type;
                  l_gtm_Condn1Tab(1).g_Bind_Literal := ':b_party_type';
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND PARTY.PARTY_TYPE  = :b_party_type', l_gtm_Condn1Tab, 'VARCHAR');
             END IF;
             --}
            --Adding Business Purpose Condn
            IF p_site_use_code IS NOT NULL THEN
                l_Party_Condn2Tab(1).g_varchar_val := p_site_use_code;
                l_Party_Condn2Tab(1).g_Bind_Literal := ':b_site_use_code';
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' AND SITE_USES.SITE_USE_CODE = :b_site_use_code', l_Party_Condn2Tab, 'VARCHAR');
            END IF;

            --Adding Creates Last N Days Condn
            IF p_created_n_days IS NOT NULL THEN
                IF p_party_type = 'CUSTOMER' OR p_party_type is NULL THEN
                    l_Party_Condn3Tab(1).g_number_val := p_created_n_days;
                    l_Party_Condn3Tab(1).g_Bind_Literal := ':b_created_n_days';
                END IF;
                -- gtm
                IF (p_party_type <> 'CUSTOMER'  OR p_party_type is NULL) THEN
                    l_Carrier_Condn2Tab(1).g_number_val := p_created_n_days;
                    l_Carrier_Condn2Tab(1).g_Bind_Literal := ':b_created_n_days';
                END IF;

                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF p_party_type = 'CUSTOMER' OR p_party_type is NULL THEN

                     WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' AND (SITE_USES.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR ACCT.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR ACCT_SITE.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR PARTY_SITE.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR LOC.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR PARTY.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, l_ContactQuery || ' and ( hoc.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Party_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' or hcp.CREATION_DATE >= SYSDATE - :b_created_n_days))) ', l_Party_Condn3Tab, 'NUMBER');
                END IF;
                -- gtm
                IF (p_party_type <> 'CUSTOMER' OR p_party_type is NULL) THEN
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND ( PARTY_SITE.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Carrier_Condn2Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' OR PARTY.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Carrier_Condn2Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' OR LOC.CREATION_DATE >= SYSDATE - :b_created_n_days ', l_Carrier_Condn2Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, l_ContactQuery || ' and ( hoc.CREATION_DATE >= SYSDATE - :b_created_n_days ',  l_Carrier_Condn2Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' or hcp.CREATION_DATE >= SYSDATE - :b_created_n_days))) ',  l_Carrier_Condn2Tab, 'NUMBER');

                END IF;
            END IF;

            --Adding Creates Last N Days Condn
            IF p_updated_n_days IS NOT NULL THEN
                IF p_party_type = 'CUSTOMER' OR p_party_type is NULL THEN
                    l_Party_Condn4Tab(1).g_number_val := p_updated_n_days;
                    l_Party_Condn4Tab(1).g_Bind_Literal := ':b_updated_n_days';
                END IF;
                -- gtm
                IF p_party_type <> 'CUSTOMER' OR p_party_type is NULL THEN
                    l_Carrier_Condn3Tab(1).g_number_val := p_updated_n_days;
                    l_Carrier_Condn3Tab(1).g_Bind_Literal := ':b_updated_n_days';
                END IF;


                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                IF p_party_type = 'CUSTOMER' OR p_party_type is NULL THEN
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' AND (SITE_USES.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR ACCT.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR ACCT_SITE.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR PARTY_SITE.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR LOC.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' OR PARTY.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, l_ContactQuery || ' and  ( hoc.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Party_Condn4Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Party_Table, ' or hcp.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days))) ', l_Party_Condn4Tab, 'NUMBER');

                END IF;
                -- gtm
                IF p_party_type <> 'CUSTOMER' OR p_party_type is NULL THEN
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' AND (PARTY_SITE.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Carrier_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' OR PARTY.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ', l_Carrier_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' OR LOC.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days  ', l_Carrier_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, l_ContactQuery || ' and  ( hoc.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days ',l_Carrier_Condn3Tab, 'NUMBER');
                    WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Carrier_Table, ' or hcp.LAST_UPDATE_DATE >= SYSDATE - :b_updated_n_days))) ', l_Carrier_Condn3Tab, 'NUMBER');
               END IF;
            END IF;


            --Call to custom Procedure which could be edited by the Customer.
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_CUSTOMIZE.ALTER_PARTY_SYNC for Customer',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_ITM_CUSTOMIZE.ALTER_PARTY_SYNC(l_Party_Table);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_CUSTOMIZE.ALTER_PARTY_SYNC for Carrier',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_ITM_CUSTOMIZE.ALTER_PARTY_SYNC(l_Carrier_Table);


            --Create SQL and bind parameters
            FOR I IN 1..l_Party_Table.COUNT
            LOOP
                l_tempStr1 := l_tempStr1 || ' ' || l_Party_table(i).g_Condn_Qry;
            END LOOP;

            FOR I IN 1..l_Carrier_Table.COUNT
            LOOP
                l_tempStr2 := l_tempStr2 || ' ' || l_Carrier_table(i).g_Condn_Qry;
            END LOOP;



            --Concatenating Main SQL with Condition SQL
            IF p_party_type = 'CUSTOMER' THEN
               l_SQLQuery := l_CustSQLQuery || l_tempStr1;
            END IF;
            IF p_party_type =  'CARRIER' THEN
               l_SQLQuery := l_CarrierSQLQuery || l_tempStr2;
            END IF;
            IF ( (p_party_type is NOT NULL) AND (p_party_type <> 'CARRIER' AND p_party_type <> 'CUSTOMER'))  THEN
               l_SQLQuery := l_GtmSQLQuery || l_tempStr2;
            END IF;


            -- gtm
            IF (p_party_type is NULL  and  l_itm_intg_gtm = 'Y' ) then
                l_SQLQuery := l_GtmSQLQuery || l_tempStr2;
            END IF;

            IF (p_party_type is NULL  and  l_itm_intg_gtm = 'N' ) then
                l_SQLQuery := l_CustSQLQuery || l_tempStr1 || ' UNION ' || l_CarrierSQLQuery || l_tempStr2;
            END IF;


            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Query ',  l_SQLQuery, WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;

            -- Parse cursor
            l_CursorID := DBMS_SQL.Open_Cursor;
            DBMS_SQL.PARSE(l_CursorID, l_SQLQuery,  DBMS_SQL.v7);



            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 1, l_num_sourceID_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 2, l_num_hzpartyID_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 3, l_num_hzpartySiteID_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 4, l_num_custAccountID_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 5, l_varchar_PartnrType_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 6, l_varchar_PartyName_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 7, l_varchar_AlternateName_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 8, l_varchar_TaxRef_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 9, l_varchar_Address1_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 10,l_varchar_Address2_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 11,l_varchar_Address3_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 12, l_varchar_Address4_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 13, l_varchar_City_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 14, l_varchar_State_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 15, l_varchar_Country_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 16, l_varchar_PostalCode_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 17, l_varchar_AcctNumber_tab ,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 18, l_varchar_AcctName_tab   ,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 19, l_varchar_SiteNumber_tab ,      100, 0);


            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 20, l_varchar_tempAttrib1_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 21, l_varchar_tempAttrib2_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 22, l_varchar_tempAttrib3_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 23, l_varchar_tempAttrib4_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 24, l_varchar_tempAttrib5_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 25, l_varchar_tempAttrib6_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 26, l_varchar_tempAttrib7_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 27, l_varchar_tempAttrib8_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 28, l_varchar_tempAttrib9_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 29, l_varchar_tempAttrib10_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 30, l_varchar_tempAttrib11_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 31, l_varchar_tempAttrib12_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 32, l_varchar_tempAttrib13_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 33, l_varchar_tempAttrib14_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 34, l_varchar_tempAttrib15_tab,     100, 0);



            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 35, l_varchar_Attrib1_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 36, l_varchar_Attrib2_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 37, l_varchar_Attrib3_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 38, l_varchar_Attrib4_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 39, l_varchar_Attrib5_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 40, l_varchar_Attrib6_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 41, l_varchar_Attrib7_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 42, l_varchar_Attrib8_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 43, l_varchar_Attrib9_tab,      100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 44, l_varchar_Attrib10_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 45, l_varchar_Attrib11_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 46, l_varchar_Attrib12_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 47, l_varchar_Attrib13_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 48, l_varchar_Attrib14_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 49, l_varchar_Attrib15_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 50, l_operating_unit,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 51, l_address_type,             100, 0);        -- gtm v Changes added below
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 52, l_hz_party_num_tab,         100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 53, l_hz_party_type_tab,        100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 54, l_hz_status_tab,            100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 55, l_hz_hq_branch_ind_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 56, l_hz_sic_code_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 57, l_hz_sic_code_type_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 58, l_person_first_name_tab,    100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 59, l_person_middle_name_tab,   100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 60, l_person_last_name_tab,     100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 61, l_hz_location_id_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 62, l_hz_country_tab,           100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 63, l_hz_address1_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 64, l_hz_address2_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 65, l_hz_address3_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 66, l_hz_address4_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 67, l_hz_city_tab,              100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 68, l_hz_postal_code_tab,       100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 69, l_hz_state_tab,             100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 70, l_hz_province_tab,          100, 0);
            DBMS_SQL.DEFINE_ARRAY(l_CursorID, 71, l_hz_county_tab,            100, 0);
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.BIND_VALUES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ITM_QUERY_CUSTOM.BIND_VALUES(l_Party_Table,l_CursorID);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.BIND_VALUES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_ITM_QUERY_CUSTOM.BIND_VALUES(l_Carrier_Table,l_CursorID);

            IF l_debug_on THEN
                WSH_DEBUG_SV.LOGMSG (l_module_name,'Successfull in binding values',WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;

            l_ignore := DBMS_SQL.EXECUTE(l_CursorID);


            --Bulk Collect customized SQL
            LOOP
                l_ignore := DBMS_SQL.FETCH_ROWS(l_CursorID);


                DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_num_sourceID_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, l_num_hzpartyID_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 3, l_num_hzpartySiteID_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 4, l_num_custAccountID_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 5, l_varchar_PartnrType_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 6, l_varchar_PartyName_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 7, l_varchar_AlternateName_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 8, l_varchar_TaxRef_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 9, l_varchar_Address1_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 10,l_varchar_Address2_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 11, l_varchar_Address3_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 12, l_varchar_Address4_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 13, l_varchar_City_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 14, l_varchar_State_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 15, l_varchar_Country_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 16, l_varchar_PostalCode_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 17, l_varchar_AcctNumber_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 18, l_varchar_AcctName_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 19, l_varchar_SiteNumber_tab);

                DBMS_SQL.COLUMN_VALUE(l_CursorID, 20, l_varchar_tempAttrib1_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 21, l_varchar_tempAttrib2_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 22, l_varchar_tempAttrib3_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 23, l_varchar_tempAttrib4_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 24, l_varchar_tempAttrib5_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 25, l_varchar_tempAttrib6_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 26, l_varchar_tempAttrib7_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 27, l_varchar_tempAttrib8_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 28, l_varchar_tempAttrib9_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 29, l_varchar_tempAttrib10_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 30, l_varchar_tempAttrib11_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 31, l_varchar_tempAttrib12_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 32, l_varchar_tempAttrib13_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 33, l_varchar_tempAttrib14_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 34, l_varchar_tempAttrib15_tab);

                DBMS_SQL.COLUMN_VALUE(l_CursorID, 35, l_varchar_Attrib1_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 36, l_varchar_Attrib2_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 37, l_varchar_Attrib3_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 38, l_varchar_Attrib4_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 39, l_varchar_Attrib5_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 40, l_varchar_Attrib6_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 41, l_varchar_Attrib7_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 42, l_varchar_Attrib8_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 43, l_varchar_Attrib9_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 44, l_varchar_Attrib10_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 45, l_varchar_Attrib11_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 46, l_varchar_Attrib12_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 47, l_varchar_Attrib13_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 48, l_varchar_Attrib14_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 49, l_varchar_Attrib15_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 50, l_operating_unit);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 51, l_address_type);       -- gtm New Ones added Below
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 52, l_hz_party_num_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 53, l_hz_party_type_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 54, l_hz_status_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 55, l_hz_hq_branch_ind_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 56, l_hz_sic_code_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 57, l_hz_sic_code_type_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 58, l_person_first_name_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 59, l_person_middle_name_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 60, l_person_last_name_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 61, l_hz_location_id_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 62, l_hz_country_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 63, l_hz_address1_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 64, l_hz_address2_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 65, l_hz_address3_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 66, l_hz_address4_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 67, l_hz_city_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 68, l_hz_postal_code_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 69, l_hz_state_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 70, l_hz_province_tab);
                DBMS_SQL.COLUMN_VALUE(l_CursorID, 71, l_hz_county_tab);

                EXIT WHEN l_ignore <> 100;

            END LOOP;
            DBMS_SQL.CLOSE_CURSOR(l_CursorID);

            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Number of parties queried : ' ,l_num_sourceID_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;

            --Bulk Insert into Interface Tables Appropriately
            IF l_num_hzpartyID_tab.COUNT <> 0 THEN
            FOR i in l_num_hzpartyID_tab.FIRST..l_num_hzpartyID_tab.LAST
            LOOP

                IF l_num_hzpartyID_tab(i) <> l_tempSourceID THEN
                    l_tempSourceID := l_num_hzpartyID_tab(i);
                    --Create a new Request Control Seq

                    j :=   l_num_ReqCtrl_tab.COUNT + 1;

                    select WSH_ITM_REQUEST_CONTROL_S.NEXTVAL
                    into
                    l_num_ReqCtrl_tab(j)
                    from dual;

                    l_varchar_rcAttrib1_tab(j) := l_varchar_tempAttrib1_tab(i);
                    l_varchar_rcAttrib2_tab(j) := l_varchar_tempAttrib2_tab(i);
                    l_varchar_rcAttrib3_tab(j) := l_varchar_tempAttrib3_tab(i);
                    l_varchar_rcAttrib4_tab(j) := l_varchar_tempAttrib4_tab(i);
                    l_varchar_rcAttrib5_tab(j) := l_varchar_tempAttrib5_tab(i);
                    l_varchar_rcAttrib6_tab(j) := l_varchar_tempAttrib6_tab(i);
                    l_varchar_rcAttrib7_tab(j) := l_varchar_tempAttrib7_tab(i);
                    l_varchar_rcAttrib8_tab(j) := l_varchar_tempAttrib8_tab(i);
                    l_varchar_rcAttrib9_tab(j) := l_varchar_tempAttrib9_tab(i);
                    l_varchar_rcAttrib10_tab(j) := l_varchar_tempAttrib10_tab(i);
                    l_varchar_rcAttrib11_tab(j) := l_varchar_tempAttrib11_tab(i);
                    l_varchar_rcAttrib12_tab(j) := l_varchar_tempAttrib12_tab(i);
                    l_varchar_rcAttrib13_tab(j) := l_varchar_tempAttrib13_tab(i);
                    l_varchar_rcAttrib14_tab(j) := l_varchar_tempAttrib14_tab(i);
                    l_varchar_rcAttrib15_tab(j) := l_varchar_tempAttrib15_tab(i);

                END IF;
                --Saving Request Control for Child WSH_ITM_PARTIES Table

                l_num_PartyReqCtrl_tab(i) := l_num_ReqCtrl_tab(l_num_ReqCtrl_tab.COUNT);
                select WSH_ITM_PARTIES_S.NEXTVAL
                into
                l_num_itmpartyID_tab(l_num_itmpartyID_tab.COUNT)
                from dual;
            END LOOP;
            END IF;

			--Getting the Base Language into the variable
			SELECT LANGUAGE_CODE INTO l_LanguageCode
			FROM FND_LANGUAGES
			WHERE INSTALLED_FLAG = 'B';
			IF l_debug_on THEN
				WSH_DEBUG_SV.LOG (l_module_name, 'Base Language : ', l_LanguageCode, WSH_DEBUG_SV.C_STMT_LEVEL);
			END IF;




            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Number of Request Controls to be inserted : ' , l_num_ReqCtrl_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;


            --Bulk Insert to Request Control Table
            IF l_num_ReqCtrl_tab.COUNT <> 0 THEN
            FORALL i IN l_num_ReqCtrl_tab.FIRST..l_num_ReqCtrl_tab.LAST
                INSERT INTO WSH_ITM_REQUEST_CONTROL(
                        REQUEST_CONTROL_ID,
                        APPLICATION_ID,
                        LANGUAGE_CODE,
                        PROCESS_FLAG,
                        SERVICE_TYPE_CODE,
                        ATTRIBUTE1_VALUE,
                        ATTRIBUTE2_VALUE,
                        ATTRIBUTE3_VALUE,
                        ATTRIBUTE4_VALUE,
                        ATTRIBUTE5_VALUE,
                        ATTRIBUTE6_VALUE,
                        ATTRIBUTE7_VALUE,
                        ATTRIBUTE8_VALUE,
                        ATTRIBUTE9_VALUE,
                        ATTRIBUTE10_VALUE,
                        ATTRIBUTE11_VALUE,
                        ATTRIBUTE12_VALUE,
                        ATTRIBUTE13_VALUE,
                        ATTRIBUTE14_VALUE,
                        ATTRIBUTE15_VALUE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN
                )
                VALUES(
                        l_num_ReqCtrl_tab(i),
                        222,
						l_LanguageCode,
                        0,
                        'PARTY_SYNC',
                        l_varchar_rcAttrib1_tab(i),
                        l_varchar_rcAttrib2_tab(i),
                        l_varchar_rcAttrib3_tab(i),
                        l_varchar_rcAttrib4_tab(i),
                        l_varchar_rcAttrib5_tab(i),
                        l_varchar_rcAttrib6_tab(i),
                        l_varchar_rcAttrib7_tab(i),
                        l_varchar_rcAttrib8_tab(i),
                        l_varchar_rcAttrib9_tab(i),
                        l_varchar_rcAttrib10_tab(i),
                        l_varchar_rcAttrib11_tab(i),
                        l_varchar_rcAttrib12_tab(i),
                        l_varchar_rcAttrib13_tab(i),
                        l_varchar_rcAttrib14_tab(i),
                        l_varchar_rcAttrib15_tab(i),
                        SYSDATE,
                        l_user_id,
                        SYSDATE,
                        l_user_id,
                        l_login_id
                );
            END IF;

            IF l_debug_on THEN
                WSH_DEBUG_SV.LOG (l_module_name, 'Number of Parties to be inserted : ' , l_num_PartyReqCtrl_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
            END IF;

            --Bulk Insert into Parties Table
            IF l_num_PartyReqCtrl_tab.COUNT <> 0 THEN
                FOR i IN l_num_PartyReqCtrl_tab.FIRST..l_num_PartyReqCtrl_tab.LAST LOOP
                    INSERT INTO WSH_ITM_PARTIES (
                            PARTY_ID,
                            CUST_SITE_USE_ID,
                            REQUEST_CONTROL_ID,
                            PARTY_NAME,
                            ALTERNATE_NAME,
                            TAX_REFERENCE,
                            PARTY_TYPE,
                            PARTY_ADDRESS1,
                            PARTY_ADDRESS2,
                            PARTY_ADDRESS3,
                            PARTY_ADDRESS4,
                            PARTY_CITY,
                            PARTY_STATE,
                            PARTY_COUNTRY_CODE,
                            POSTAL_CODE,
                            ORIGINAL_SYSTEM_REFERENCE,
                            ACCOUNT_NUMBER,
                            ACCOUNT_NAME,
                            PARTY_SITE_NUMBER,
                            ATTRIBUTE1_VALUE,
                            ATTRIBUTE2_VALUE,
                            ATTRIBUTE3_VALUE,
                            ATTRIBUTE4_VALUE,
                            ATTRIBUTE5_VALUE,
                            ATTRIBUTE6_VALUE,
                            ATTRIBUTE7_VALUE,
                            ATTRIBUTE8_VALUE,
                            ATTRIBUTE9_VALUE,
                            ATTRIBUTE10_VALUE,
                            ATTRIBUTE11_VALUE,
                            ATTRIBUTE12_VALUE,
                            ATTRIBUTE13_VALUE,
                            ATTRIBUTE14_VALUE,
                            ATTRIBUTE15_VALUE,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            OPERATING_UNIT,
                            ADDRTYPE,         -- gtm , new columns added below
                            HZ_PARTY_ID ,
                            HZ_PARTY_NUMBER,
                            HZ_PARTY_TYPE  ,
                            HZ_PARTY_STATUS      ,
                            HZ_HQ_BRANCH_IND ,
                            HZ_SIC_CODE    ,
                            HZ_SIC_CODE_TYPE ,
                            PERSON_FIRST_NAME ,
                            PERSON_MIDDLE_NAME ,
                            PERSON_LAST_NAME   ,
                            HZ_LOCATION_ID       ,
                            HZ_COUNTRY         ,
                            HZ_ADDRESS1        ,
                            HZ_ADDRESS2        ,
                            HZ_ADDRESS3        ,
                            HZ_ADDRESS4        ,
                            HZ_CITY            ,
                            HZ_POSTAL_CODE     ,
                            HZ_STATE           ,
                            HZ_PROVINCE        ,
                            HZ_COUNTY
                    )
                    VALUES(
                            l_num_itmpartyID_tab(i),
                            l_num_sourceID_tab(i),
                            l_num_PartyReqCtrl_tab(i),
                            l_varchar_PartyName_tab(i),
                            l_varchar_AlternateName_tab(i),
                            l_varchar_TaxRef_tab(i),
                            l_varchar_PartnrType_tab(i),
                            l_varchar_Address1_tab(i),
                            l_varchar_Address2_tab(i),
                            l_varchar_Address3_tab(i),
                            l_varchar_Address4_tab(i),
                            l_varchar_City_tab(i),
                            l_varchar_State_tab(i),
                             l_varchar_Country_tab(i),
                             l_varchar_PostalCode_tab(i),
                             l_num_hzpartySiteID_tab(i),
                             l_varchar_AcctNumber_tab(i),
                             l_varchar_AcctName_tab(i),
                             l_varchar_SiteNumber_tab(i),
                             l_varchar_Attrib1_tab(i),
                             l_varchar_Attrib2_tab(i),
                             l_varchar_Attrib3_tab(i),
                             l_varchar_Attrib4_tab(i),
                             l_varchar_Attrib5_tab(i),
                             l_varchar_Attrib6_tab(i),
                             l_varchar_Attrib7_tab(i),
                             l_varchar_Attrib8_tab(i),
                             l_varchar_Attrib9_tab(i),
                             l_varchar_Attrib10_tab(i),
                             l_varchar_Attrib11_tab(i),
                             l_varchar_Attrib12_tab(i),
                             l_varchar_Attrib13_tab(i),
                             l_varchar_Attrib14_tab(i),
                             l_varchar_Attrib15_tab(i),
                            --num_orgId_tab(i),
                            SYSDATE,
                            l_user_id,
                            SYSDATE,
                            l_user_id,
                            l_login_id,
                            l_operating_unit(i),
                            l_address_type(i),       -- gtm , new tabs added below
                            l_num_hzpartyID_tab(i),
                            l_hz_party_num_tab(i),
                            l_hz_party_type_tab(i)        ,
                            l_hz_status_tab(i)            ,
                            l_hz_hq_branch_ind_tab(i)     ,
                            l_hz_sic_code_tab(i)          ,
                            l_hz_sic_code_type_tab(i)     ,
                            l_person_first_name_tab(i)         ,
                            l_person_middle_name_tab(i)         ,
                            l_person_last_name_tab(i)         ,
                            l_hz_location_id_tab(i)         ,
                            l_hz_country_tab(i)         ,
                            l_hz_address1_tab(i)         ,
                            l_hz_address2_tab(i)         ,
                            l_hz_address3_tab(i)         ,
                            l_hz_address4_tab(i)         ,
                            l_hz_city_tab(i)         ,
                            l_hz_postal_code_tab(i)         ,
                            l_hz_state_tab(i)         ,
                            l_hz_province_tab(i)         ,
                            l_hz_county_tab(i)
                    );
                END LOOP;
            END IF;

            -- Selecting Contacts Data
            IF l_num_itmpartyID_tab.COUNT <> 0 THEN
                For i in l_num_itmpartyID_tab.FIRST..l_num_itmpartyID_tab.LAST LOOP


                 IF l_debug_on THEN
                        WSH_DEBUG_SV.LOG (l_module_name, 'Getting Contacts for Party : ' , l_varchar_PartyName_tab(i),WSH_DEBUG_SV.C_STMT_LEVEL);
                        WSH_DEBUG_SV.LOG (l_module_name, 'gtm :Getting Contacts for Party : ', l_num_hzpartySiteID_tab.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                 END IF;
             -- gtm {
                if (l_num_hzpartySiteID_tab.count <> 0 and l_num_hzpartySiteID_tab(i) is not NULL ) then

                 /* Bug 7297690 Added check to determine whether Contacts for this party site is already being inserted into wsh_itm_party_contacts
		    - For each party site this query will be fired n no of times, n is no of usage of this site (billto, shipto etc)
                    - This needs to be reduced to one, since when the party site is queried first time, contacts will be added
                      and for all other hits contact will not be inserted since it is inserted first time itself. */
		 IF NOT l_party_site_id_cache.Exists(l_num_hzpartySiteID_tab(i)) THEN

		   l_party_site_id_cache(l_num_hzpartySiteID_tab(i)) := 'Y';

                   --Bug 7297690 Added column hoc.org_contact_id to Store the Org Contact id of the contact that needs to be screened */
                   SELECT DISTINCT  hr.party_id,
                            hp.party_name,
                            nvl(hoc.job_title,hoc.job_title_code),
                	    hoc.org_contact_id,     -- Added in Bug 7297690
                            hcar.attribute1,
                            hcar.attribute2,
                            hcar.attribute3,
                            hcar.attribute4,
                            hcar.attribute5,
                            hcar.attribute6,
                            hcar.attribute7,
                            hcar.attribute8,
                            hcar.attribute9,
                            hcar.attribute10,
                            hcar.attribute11,
                            hcar.attribute12,
                            hcar.attribute13,
                            hcar.attribute14,
                            hcar.attribute15,
                            hp.party_id    ,    -- gtm related v
                            hp.party_number,
                            decode(hp.party_type,'ORGANIZATION',hp.organization_name_phonetic, hpp.person_name_phonetic),
                            hp.PARTY_TYPE ,
                            hp.STATUS      ,
                            hp.PERSON_FIRST_NAME ,
                            hp.PERSON_MIDDLE_NAME ,
                            hp.PERSON_LAST_NAME  ,
                            hp.COUNTRY        ,
                            hp.ADDRESS1       ,
                            hp.ADDRESS2       ,
                            hp.ADDRESS3       ,
                            hp.ADDRESS4       ,
                            hp.CITY           ,
                            hp.POSTAL_CODE    ,
                            hp.STATE          ,
                            hp.PROVINCE       ,
                            hp.COUNTY
                    BULK COLLECT INTO
                         l_num_partyrel_tab,
                         l_varchar_CtPartyName_tab,
                         l_varchar_CtPointType_tab,
			 l_org_contact_id_tab,       -- Added in Bug 7297690
                         l_varchar_Attrib1_tab,
                         l_varchar_Attrib2_tab,
                         l_varchar_Attrib3_tab,
                         l_varchar_Attrib4_tab,
                         l_varchar_Attrib5_tab,
                         l_varchar_Attrib6_tab,
                         l_varchar_Attrib7_tab,
                         l_varchar_Attrib8_tab,
                         l_varchar_Attrib9_tab,
                         l_varchar_Attrib10_tab,
                         l_varchar_Attrib11_tab,
                         l_varchar_Attrib12_tab,
                         l_varchar_Attrib13_tab,
                         l_varchar_Attrib14_tab,
                         l_varchar_Attrib15_tab,
                         l_num_CtPartyId_tab,
                         l_varchar_CtPartyNum_tab,
                         l_ct_alternate_name_tab,
                         l_ct_party_type_tab   ,
                         l_ct_status_tab       ,
                         l_ct_first_name_tab   ,
                         l_ct_middle_name_tab  ,
                         l_ct_last_name_tab    ,
                         l_ct_country_tab      ,
                         l_ct_address1_tab     ,
                         l_ct_address2_tab     ,
                         l_ct_address3_tab     ,
                         l_ct_address4_tab     ,
                         l_ct_city_tab         ,
                         l_ct_postal_code_tab  ,
                         l_ct_state_tab        ,
                         l_ct_province_tab     ,
                         l_ct_county_tab
                    from hz_relationships hr,		--TCA view removal Starts
                         hz_Parties hp,
                         hz_org_contacts hoc,
                         hz_cust_account_roles hcar,
                         hz_Person_profiles hpp
                    where hr.subject_table_name = 'HZ_PARTIES'
		    and  hr.object_table_name = 'HZ_PARTIES'
		    and  hr.Directional_flag = 'F'
		    and object_id = l_num_hzpartyID_tab(i)
                    and   hr.relationship_code = 'CONTACT_OF'
                    and   hr.subject_id = hp.party_id
                    and   hoc.party_relationship_id = hr.relationship_id
                    and   nvl(hoc.party_site_id,l_num_hzpartySiteID_tab(i)) =  l_num_hzpartySiteID_tab(i)
                    and   hcar.party_id(+) = hr.party_id
                    and   hp.PARTY_ID      = hpp.PARTY_ID(+); -- TCA view removal Ends


        -- Added for Bug 3420203
          IF l_num_partyrel_tab.COUNT <> 0 THEN
                 -- Bug 7297690 Added check to determine whether party contact is already being inserted into wsh_itm_party_contacts
                FOR j IN l_num_partyrel_tab.FIRST..l_num_partyrel_tab.LAST LOOP
                     BEGIN

		        IF (l_org_contact_cache(l_org_contact_id_tab(j)) = 'Y' ) THEN
                           IF l_debug_on THEN
 	                        WSH_DEBUG_SV.LOGMSG (l_module_name,'Party Contact Already inserted ',WSH_DEBUG_SV.C_STMT_LEVEL);
                           END IF;
 	                END IF;
 	                EXCEPTION
 	                 WHEN NO_DATA_FOUND THEN
 	                   BEGIN
                              SELECT email_address into  l_varchar_ctEmail_tab(j)  FROM
                              hz_contact_points where contact_point_type ='EMAIL'
                              and owner_table_id = l_num_partyrel_tab(j)
                              --added for bug 6391747
                              and owner_table_name = 'HZ_PARTIES'
                              and primary_flag ='Y';
                              EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                   l_varchar_ctEmail_tab(j) :=null;
                           END ;

                           BEGIN
                             SELECT  phone_number into  l_varchar_ctPhone_tab(j) FROM
                                hz_contact_points where contact_point_type ='PHONE'
                                AND owner_table_id = l_num_partyrel_tab(j)
                                --added for bug 6391747
                                AND owner_table_name = 'HZ_PARTIES'
                                AND phone_line_type= 'GEN'
                                and primary_flag ='Y';
                             EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                  l_varchar_ctPhone_tab(j) :=null;
                           END ;
                           BEGIN
                            SELECT  phone_number into l_varchar_ctFax_tab(j) FROM
                                hz_contact_points where contact_point_type ='PHONE'
                                AND owner_table_id = l_num_partyrel_tab(j)
                                --added for bug 6391747
                                AND owner_table_name = 'HZ_PARTIES'
                                and phone_line_type= 'FAX'
                                and primary_flag ='Y';
                             EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                 l_varchar_ctFax_tab(j) :=null;
                           END ;
                     END;

               END LOOP;
            END IF;

                    IF l_debug_on THEN
                            WSH_DEBUG_SV.LOG (l_module_name, 'Number of Contacts : ' , l_varchar_CtPartyName_tab.COUNT,WSH_DEBUG_SV.C_STMT_LEVEL);
                    END IF;
                    -- Bug 7297690 Inserting Party contact only if it is not already populated in wsh_itm_party_contacts
                    if l_varchar_CtPartyName_tab.COUNT <> 0 THEN

                         FOR j in l_varchar_CtPartyName_tab.FIRST..l_varchar_CtPartyName_tab.LAST LOOP
                           -- WSH_DEBUG_SV.LOG (l_module_name,'org contact : ',l_org_contact_id_tab(j),WSH_DEBUG_SV.C_STMT_LEVEL);
 	                    BEGIN
 	                      IF (l_org_contact_cache(l_org_contact_id_tab(j)) = 'Y' ) THEN
                                IF l_debug_on THEN
 	                           WSH_DEBUG_SV.LOGMSG (l_module_name,' Party Contact Already inserted ',WSH_DEBUG_SV.C_STMT_LEVEL);
                                END IF;
 	                      END IF;
 	                      EXCEPTION
 	                      WHEN NO_DATA_FOUND THEN
 	                           IF l_debug_on THEN
                                      WSH_DEBUG_SV.LOGMSG (l_module_name,'Party Contact being inserted ',WSH_DEBUG_SV.C_STMT_LEVEL);
                                   END IF;
                                   l_org_contact_cache(l_org_contact_id_tab(j))  := 'Y';
                                insert into wsh_itm_party_contacts
                                    (
                                     PARTY_ID ,
                                     NAME   ,
                                     JOB_TITLE      ,
                                     EMAIL          ,
                                     PHONE,
                                     FAX            ,
                                     ATTRIBUTE1_VALUE,
                                     ATTRIBUTE2_VALUE,
                                     ATTRIBUTE3_VALUE,
                                     ATTRIBUTE4_VALUE,
                                     ATTRIBUTE5_VALUE,
                                     ATTRIBUTE6_VALUE,
                                     ATTRIBUTE7_VALUE,
                                     ATTRIBUTE8_VALUE,
                                     ATTRIBUTE9_VALUE,
                                     ATTRIBUTE10_VALUE,
                                     ATTRIBUTE11_VALUE,
                                     ATTRIBUTE12_VALUE,
                                     ATTRIBUTE13_VALUE,
                                     ATTRIBUTE14_VALUE,
                                     ATTRIBUTE15_VALUE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_LOGIN,
                                     HZ_PARTY_ID,
                                     HZ_PARTY_NUMBER,
                                     ALTERNATE_NAME,
                                     HZ_PARTY_TYPE,
                                     HZ_PARTY_STATUS,
                                     PERSON_FIRST_NAME,
                                     PERSON_MIDDLE_NAME,
                                     PERSON_LAST_NAME,
                                     HZ_COUNTRY  ,
                                     HZ_ADDRESS1 ,
                                     HZ_ADDRESS2 ,
                                     HZ_ADDRESS3 ,
                                     HZ_ADDRESS4 ,
                                     HZ_CITY     ,
                                     HZ_POSTAL_CODE,
                                     HZ_STATE      ,
                                     HZ_PROVINCE   ,
                                     HZ_COUNTY
                                     )
                             VALUES
                                     (
                                            l_num_itmpartyID_tab(i),
                                            l_varchar_CtPartyName_tab(j),
                                            l_varchar_CtPointType_tab(j),
                                            l_varchar_ctEmail_tab(j),
                                            l_varchar_ctPhone_tab(j),
                                            l_varchar_ctFax_tab(j),
                                            l_varchar_Attrib1_tab(j),
                                            l_varchar_Attrib2_tab(j),
                                            l_varchar_Attrib3_tab(j),
                                            l_varchar_Attrib4_tab(j),
                                            l_varchar_Attrib5_tab(j),
                                            l_varchar_Attrib6_tab(j),
                                            l_varchar_Attrib7_tab(j),
                                            l_varchar_Attrib8_tab(j),
                                            l_varchar_Attrib9_tab(j),
                                            l_varchar_Attrib10_tab(j),
                                            l_varchar_Attrib11_tab(j),
                                            l_varchar_Attrib12_tab(j),
                                            l_varchar_Attrib13_tab(j),
                                            l_varchar_Attrib14_tab(j),
                                            l_varchar_Attrib15_tab(j),
                                            SYSDATE,
                                            l_user_id,
                                            SYSDATE,
                                            l_user_id,
                                            l_login_id,
                                            l_num_CtPartyId_tab(j),     -- gtm
                                            l_varchar_CtPartyNum_tab(j),
                                            l_ct_alternate_name_tab(j),
                                            l_ct_party_type_tab(j)   ,
                                            l_ct_status_tab(j)       ,
                                            l_ct_first_name_tab(j)   ,
                                            l_ct_middle_name_tab(j)  ,
                                            l_ct_last_name_tab(j)    ,
                                            l_ct_country_tab(j)      ,
                                            l_ct_address1_tab(j)     ,
                                            l_ct_address2_tab(j)     ,
                                            l_ct_address3_tab(j)     ,
                                            l_ct_address4_tab(j)     ,
                                            l_ct_city_tab(j)         ,
                                            l_ct_postal_code_tab(j)  ,
                                            l_ct_state_tab(j)        ,
                                            l_ct_province_tab(j)     ,
                                            l_ct_county_tab(j)
                                         );
                            END;
                         END LOOP;

                    END IF;
                  END IF; -- Party site cache if loop
                 end if; -- gtm }
                END LOOP;
            END IF;

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --


        EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
            END IF;
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
            errbuf := 'Procedure WSH_ITM_PARTY_SYNC.POPULATE_DATA failed with unexpected error';
            retcode := '2';
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;

        END POPULATE_DATA;

END WSH_ITM_PARTY_SYNC;

/
