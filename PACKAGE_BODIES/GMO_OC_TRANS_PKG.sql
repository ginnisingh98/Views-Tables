--------------------------------------------------------
--  DDL for Package Body GMO_OC_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_OC_TRANS_PKG" AS
/*  $Header: GMOOCTRB.pls 120.1 2007/06/21 06:11:17 rvsingh noship $  */
PROCEDURE GENERATE_OC_TRANS_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                Object_type IN         NUMBER DEFAULT NULL,
                                Object_id        IN         NUMBER DEFAULT NULL,
                                Operator_id      IN        NUMBER DEFAULT NULL,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2) IS
TYPE refcur IS REF CURSOR;
l_refcur  refcur;
l_result XMLType;
l_final_clob CLOB ;
l_len number;
l_xml_data varchar2(10);
l_limit number;
l_argument_string  long ;
l_from_date varchar2(15);
l_to_date varchar2(15);
l_org_name  VARCHAR2(4000);
l_org_code  VARCHAR2(240);
l_object_type VARCHAR2(240);
l_object VARCHAR2(240);
l_operator_name VARCHAR2(240);
CURSOR GET_ORG_NAME IS
SELECT hou.name ORGANIZATION_NAME , mp.organization_code ORGANIZATION_CODE
FROM hr_all_organization_units hou,
     mtl_parameters mp
WHERE hou.organization_id = Plant
  AND NVL(hou.date_to, SYSDATE+1) >= SYSDATE
  and mp.organization_id = hou.organization_id;
CURSOR GET_OBJECT_TYPE(ob_type_id NUMBER) IS
SELECT meaning from fnd_lookups where lookup_type = 'GMO_OC_OBJECT_LOV' and lookup_code = ob_type_id;
CURSOR GET_OBJECT IS
select DECODE(object_type,1,
   (select concatenated_segments from mtl_system_items_kfv where inventory_item_id = OBJECT_ID and organization_id = Plant),2,
   (select resources from cr_rsrc_dtl where resource_id = OBJECT_ID),3,
   (select meaning from fnd_lookups where lookup_type = 'GMO_OC_TRANS_LOV' and lookup_code = OBJECT_ID),null)  from dual;
BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'CP : GENERATE_XML(OC) : START ');
FND_FILE.PUT_LINE (FND_FILE.LOG, 'Input Parameter - Plant :'||Plant||' and Object Type:'||Object_type||' and Object_id  :'||Object_id||' From Date :'||FromDate||' To Date :'||ToDate||' Operator_id:'||Operator_id);
   l_from_date := null;
   l_to_date := null;

   IF(FromDate  IS NOT  NULL) THEN
    l_from_date := substr(FromDate,0,10);
   END IF;
   IF(ToDate IS NOT  NULL) THEN
    l_to_date := substr(ToDate,0,10);
   END IF;
   FND_FILE.PUT_LINE (FND_FILE.LOG,'l_from_date :'||l_from_date||'l_to_date :'||l_to_date);

   OPEN GET_ORG_NAME;
     FETCH GET_ORG_NAME INTO l_org_name, l_org_code;
   CLOSE GET_ORG_NAME;
   OPEN GET_OBJECT_TYPE(Object_type);
     FETCH GET_OBJECT_TYPE INTO l_object_type;
   CLOSE GET_OBJECT_TYPE;
   OPEN GET_OBJECT;
     FETCH GET_OBJECT INTO l_object;
   CLOSE GET_OBJECT;
   IF operator_id IS NOT NULL THEN
   l_operator_name := GMO_UTILITIES.GET_USER_DISPLAY_NAME(operator_id);
   END IF;

l_argument_string := 'SELECT XMLELEMENT("OPERATORHISTORY", XMLCONCAT(XMLSEQUENCETYPE(
                                          XMLTYPE(''<ORGANIZATION>''||:x||''</ORGANIZATION>''),
                                          XMLTYPE(''<OBJECTTYPE>''||:y||''</OBJECTTYPE>''),
                                          XMLTYPE(''<OBJECT>''||:z||''</OBJECT>''),
                                          XMLTYPE(''<FROMDATE>''||:xx||''</FROMDATE>''),
                                          XMLTYPE(''<TODATE>''||:yy||''</TODATE>''),
                                          XMLTYPE(''<OPERATOR>''||:zz||''</OPERATOR>''))),
              XMLAGG(XMLELEMENT("OPERATORCERTHEADER",
	            XMLFOREST(:orgName as  OrganizationName ,
	                DECODE(oc_trans_hdr.TRANS_OBJECT_ID,1,
                  (select meaning from fnd_lookups where lookup_type = ''GMO_OC_OBJECT_LOV'' and lookup_code = 1),2,
                  (select meaning from fnd_lookups where lookup_type = ''GMO_OC_OBJECT_LOV'' and lookup_code = 2),3,
                  (select meaning from fnd_lookups where lookup_type = ''GMO_OC_OBJECT_LOV'' and lookup_code = 3),null) Transaction_Type,
                  DECODE(oc_trans_hdr.TRANS_OBJECT_ID,1,
                  (select concatenated_segments from mtl_system_items_kfv where inventory_item_id = oc_hdr.OBJECT_ID and organization_id = oc_hdr.ORGANIZATION_ID),2,
                  (select resources from cr_rsrc_dtl where resource_id = oc_hdr.OBJECT_ID),3,
                  (select meaning from fnd_lookups where lookup_type = ''GMO_OC_TRANS_LOV'' and lookup_code = oc_hdr.OBJECT_ID),null) Transaction_Object,
                  DECODE(oc_trans_hdr.TRANS_OBJECT_ID,1,
                  (select description from mtl_system_items_kfv where inventory_item_id = oc_hdr.OBJECT_ID and organization_id = oc_hdr.ORGANIZATION_ID),2,
                  (select resource_desc from cr_rsrc_mst where resources IN (select resources from cr_rsrc_dtl where resource_id = oc_hdr.OBJECT_ID)),3,
                  (select meaning from fnd_lookups where lookup_type = ''GMO_OC_TRANS_LOV'' and lookup_code = oc_hdr.OBJECT_ID),null) Object_Description,
                  FND_MESSAGE.GET_STRING(oc_trans_hdr.user_key_label_product,oc_trans_hdr.USER_KEY_LABEL_TOKEN) User_Key_Label,
                  oc_trans_hdr.USER_KEY_VALUE User_Key_Value,
                  oc_trans_hdr.CREATION_DATE Transaction_Date,
                  oc_trans_hdr.USER_ID User_Id,
                  GMO_UTILITIES.GET_USER_DISPLAY_NAME(oc_trans_hdr.USER_ID) Operator,
                  oc_trans_hdr.OVERRIDER_ID Overrider_Id,
                  GMO_UTILITIES.GET_USER_DISPLAY_NAME(oc_trans_hdr.OVERRIDER_ID) Overrider,
                  oc_trans_hdr.COMMENTS comments,
                  oc_trans_hdr.ERECORD_ID ERecord_Id,
                  ( SELECT  XMLAGG(XMLELEMENT("OPER_CERT_DTL",XMLFOREST(DECODE(oc_trans_dtl.QUALIFICATION_TYPE,1,
                  (select unique(name) from OTA_CERTIFICATIONS_VL where certification_id = oc_trans_dtl.QUALIFICATION_ID),2,
                  (select unique(name) from per_competences where competence_id = oc_trans_dtl.QUALIFICATION_ID),null) Qualification,
		                                                DECODE(oc_trans_dtl.QUALIFICATION_TYPE,1,
                                                    (select meaning from fnd_lookups where lookup_type = ''GMO_OC_QUAL_LOV'' and lookup_code =1),2,
                                                    (select meaning from fnd_lookups where lookup_type = ''GMO_OC_QUAL_LOV'' and lookup_code =2),null) Qualification_type,
                                                    DECODE(oc_trans_dtl.QUALIFICATION_TYPE,2,
                                                    (select step_value||''-''||name from per_rating_levels where rating_level_id = oc_trans_dtl.PROFICIENCY_LEVEL_ID),null) Proficiency_Level )))
								    FROM  GMO_OPERATOR_TRANS_DETAIL oc_trans_dtl
                    WHERE oc_trans_dtl.OPERATOR_CERTIFICATE_ID = oc_trans_hdr.OPERATOR_CERTIFICATE_ID
                   ) as OPER_CERT_DTL_LIST )
                   )   ORDER BY oc_trans_hdr.CREATION_DATE DESC )
                 )  FROM gmo_opert_cert_header oc_hdr,  gmo_operator_cert_trans oc_trans_hdr
                   WHERE oc_hdr.header_id = oc_trans_hdr.header_id
                   AND oc_hdr.organization_id = :a';
   IF (object_type IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and oc_hdr.object_type =:b';
   ELSE
      l_argument_string := l_argument_string || ' and 1 =:b';
   END IF;
   IF(Object_id  IS NOT  NULL ) THEN
      l_argument_string := l_argument_string || ' and oc_hdr.Object_id =:c';
   ELSE
      l_argument_string := l_argument_string || ' and 1 =:c';
   END IF;
      FND_FILE.put_line(FND_FILE.LOG,'SQL Query: '||l_argument_string);

   IF(l_from_date  IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and TRUNC(oc_trans_hdr.creation_date) >=TO_DATE( :d , ''YYYY/MM/DD'')';
   else
      l_argument_string := l_argument_string || ' and 1 = :d ';
   END IF;
   IF(l_to_date IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and TRUNC(oc_trans_hdr.creation_date) <=TO_DATE( :e  , ''YYYY/MM/DD'')';
   else
      l_argument_string := l_argument_string || ' and 1 = :e ';
   END IF;

   IF(Operator_id  IS NOT  NULL)  THEN
      l_argument_string := l_argument_string || ' and oc_trans_hdr.user_id = :f';
   ELSE
      l_argument_string := l_argument_string || ' and 1 = :f';
   END IF;

   FND_FILE.put_line(FND_FILE.LOG,'SQL Query'||l_argument_string);
    OPEN l_refcur FOR l_argument_string
    USING l_org_code, l_object_type, l_object, l_from_date, l_to_date,l_operator_name,l_org_name,Plant, nvl(object_type,1),nvl(object_id,1), nvl(l_from_date, 1), nvl(l_to_date,1),nvl(Operator_id,1);
   FETCH l_refcur INTO l_result;
   CLOSE l_refcur;

   l_limit:= 1;
   l_final_clob  := l_result.getClobVal();
   l_len := DBMS_LOB.GETLENGTH (l_final_clob);
   FND_FILE.PUT(FND_FILE.LOG, 'Size'||l_len);
   LOOP
        IF l_len > l_limit THEN
           l_xml_data := DBMS_LOB.SUBSTR (l_final_clob,10,l_limit);
           FND_FILE.PUT(FND_FILE.OUTPUT,l_xml_data);
           FND_FILE.PUT(FND_FILE.LOG,l_xml_data);
           l_xml_data := NULL;
           l_limit:= l_limit + 10;
        ELSE
           l_xml_data := DBMS_LOB.SUBSTR (l_final_clob,10,l_limit);
           FND_FILE.PUT(FND_FILE.OUTPUT, l_xml_data);
           FND_FILE.PUT(FND_FILE.LOG,l_xml_data);
           l_xml_data := NULL;
           EXIT;
        END IF;
   END LOOP;
   fnd_file.put_line(FND_FILE.LOG, 'CP : GENERATE_XML(OC) : FINISH ');
   EXCEPTION
    WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,SQLERRM);
            fnd_file.new_line(fnd_file.log,2);
            fnd_file.put_line(fnd_file.log, fnd_message.get_string('GMO', 'GMO_OPCERT_XML_ERR') );
            RETURN;
END GENERATE_OC_TRANS_XML;
END GMO_OC_TRANS_PKG;

/
