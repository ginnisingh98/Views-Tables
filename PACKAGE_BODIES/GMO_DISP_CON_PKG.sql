--------------------------------------------------------
--  DDL for Package Body GMO_DISP_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISP_CON_PKG" AS
/* $Header: GMOVDCPB.pls 120.8 2006/03/28 02:30 srpuri noship $ */
FUNCTION GET_HAZARD_CLASS_NAME(P_INVENTORY_ITEM_ID NUMBER,
                          P_ORGANIZATION_ID NUMBER)
RETURN VARCHAR2
IS
l_phc_hazard_class_name VARCHAR2(40);
CURSOR C_GET_PHC_CLASS IS
 SELECT PHC.HAZARD_CLASS
   FROM  PO_HAZARD_CLASSES  PHC, MTL_SYSTEM_ITEMS_VL MSI
  WHERE  MSI.INVENTORY_ITEM_ID=  P_INVENTORY_ITEM_ID
    and  MSI.ORGANIZATION_ID = P_ORGANIZATION_ID
    and MSI.HAZARD_CLASS_ID = PHC.HAZARD_CLASS_ID (+)
    and SYSDATE < (NVL(PHC.INACTIVE_DATE,sysdate));
BEGIN
  OPEN C_GET_PHC_CLASS;
    FETCH C_GET_PHC_CLASS INTO l_phc_hazard_class_name;
   CLOSE C_GET_PHC_CLASS;
  RETURN l_phc_hazard_class_name;
END GET_HAZARD_CLASS_NAME ;

PROCEDURE GENERATE_DISPDPCH_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                SubInventory IN         VARCHAR2,
                                Batch        IN         NUMBER,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2)
IS
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
CURSOR GET_ORG_NAME IS
SELECT hou.name ORGANIZATION_NAME , mp.organization_code ORGANIZATION_CODE
FROM hr_all_organization_units hou,
     mtl_parameters mp
WHERE hou.organization_id = Plant
  AND NVL(hou.date_to, SYSDATE+1) >= SYSDATE
  and mp.organization_id = hou.organization_id;

BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CP : GENERATE_XML(DISPDPCH) : START ');
   FND_FILE.PUT_LINE (FND_FILE.LOG, 'Input Parameter - Plant :'||Plant||' and Sub Inventory Code:'||SubInventory||' and Batch  :'||Batch||' From Date :'||FromDate||' To Date :'||ToDate);

   l_from_date := null;
   l_to_date := null;

   IF(FromDate  IS NOT  NULL) THEN
    l_from_date := substr(FromDate,0,10);
   END IF;

   IF(ToDate IS NOT  NULL) THEN
    l_to_date := substr(ToDate,0,10);
   END IF;
   OPEN GET_ORG_NAME;
     FETCH GET_ORG_NAME into l_org_name, l_org_code;
   CLOSE GET_ORG_NAME;

   l_argument_string := 'select XMLELEMENT("DispenseDispatch", XMLCONCAT(XMLSEQUENCETYPE(XMLTYPE(''<BatchNo>''||:x ||''</BatchNo>''),
                                            XMLTYPE(''<PlantCode>'' || :y||''</PlantCode>''),
                                            XMLTYPE(''<Subinventory_Code>'' || :z||''</Subinventory_Code>''),
                                            XMLTYPE(''<FromDate>'' ||:xx||''</FromDate>''),
                                            XMLTYPE(''<ToDate>''|| :yy ||''</ToDate>'')
                                              )),
                    XMLAGG(XMLELEMENT("DispatchDetails",
                    XMLFOREST(:orgName as  OrganizationName,
                    RES.subinventory_code as Location ,
                    RES.INVENTORY_ITEM_ID as ITEM_ID,
                    MSI.CONCATENATED_SEGMENTS as ITEM ,
                    MSI.description  as Description ,
                    flYesNo.meaning AS HAZARDOUS_MATERIAL_FLAG,
                    decode(nvl(MSI.HAZARD_CLASS_ID,-1),-1,null,
                               GMO_DISP_CON_PKG.GET_HAZARD_CLASS_NAME (GMDL.ORGANIZATION_ID,
                                                                       GMDL.INVENTORY_ITEM_ID)) AS HAZARD_CLASS,
                    RES.reservation_id as RESERVATION_ID ,
                    RES.LOT_NUMBER  as  LOT,
                    GBH.BATCH_NO as BatchNo,
                    GBSI.OPERATION  as Operation,
                    GMO_DISPENSE_PVT.GET_PENDING_DISPENSE_QTY(RES.reservation_id,RES.inventory_item_id,
                                RES.ORGANIZATION_ID,conf.recipe_id,GMDL.MATERIAL_DETAIL_ID,res.primary_uom_code,
                                res.primary_reservation_quantity,GMDL.plan_qty,GMDL.dtl_um,
                                RES.LOT_NUMBER) REQUIREDQUANTITY,
                    conf.DISPENSE_UOM UOM ,
                    GBSI.BATCHSTEP_NO as BatchStepNo,
                    RES.primary_uom_code as PRIMARY_UOM ,
                    FND_DATE.DATE_TO_DISPLAYDT(GMDL.MATERIAL_REQUIREMENT_DATE, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) as REQUIREMENT_DATE)
                                      )  order by GMDL.MATERIAL_REQUIREMENT_DATE desc
                          )
                    )
                    FROM
                      GME_BATCH_HEADER GBH,
                      GME_MATERIAL_DETAILS GMDL,
                      MTL_RESERVATIONS RES,
                      MTL_SYSTEM_ITEMS_VL MSI,
                      gmo_dispense_config conf,
                      gmo_dispense_config_inst conf_inst,
                      FND_LOOKUPS  flYesNo,
                     	(SELECT   GBSI.MATERIAL_DETAIL_ID, GBSI.BATCHSTEP_ID,
            		      GBS.BATCHSTEP_NO ,   GMO.OPRN_NO OPERATION
                	       FROM
            	           GME_BATCH_STEPS      GBS,
                             GME_BATCH_STEP_ITEMS GBSI,
                             GMD_OPERATIONS GMO
                        WHERE GBS.BATCHSTEP_ID = GBSI.BATCHSTEP_ID
                           AND GBS.OPRN_ID = GMO.OPRN_ID) GBSI
                   WHERE  RES.DEMAND_SOURCE_TYPE_ID=5
                   AND RES.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND RES.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND GBH.BATCH_ID = GMDL.BATCH_ID
                   AND GBH.BATCH_STATUS in (1,2)
                   AND RES.DEMAND_SOURCE_HEADER_ID = GBH.BATCH_ID
                   AND RES.DEMAND_SOURCE_LINE_ID = GMDL.MATERIAL_DETAIL_ID
                   AND conf_inst.ENTITY_KEY = GMDL.MATERIAL_DETAIL_ID
                   AND conf_inst.ENTITY_NAME = ''MATERIAL_DETAILS_ID''
                   AND conf_inst.DISPENSE_CONFIG_ID = conf.CONFIG_ID
                   AND GMDL.MATERIAL_DETAIL_ID = GBSI.MATERIAL_DETAIL_ID(+)
                   and flYesNo.LOOKUP_CODE = nvl(MSI.HAZARDOUS_MATERIAL_FLAG,''N'')
                   and flYesNo.LOOKUP_TYPE = ''GMO_YES_NO''
                   and gmdl.line_type = -1
                   and gme_api_grp.IS_RESERVATION_FULLY_SPECIFIED(res.reservation_id) = 1
                   and gmo_dispense_pvt.is_dispense_required(res.reservation_id, msi.inventory_item_id,
                       gbh.organization_id, null, GMDL.MATERIAL_DETAIL_ID, res.primary_reservation_quantity,
                       res.primary_uom_code,gmdl.plan_qty,gmdl.dtl_um, res.lot_number ) = ''T''
                   AND GBH.organization_id =:a ';

       -- Add 1=1 conditions if parameters are missing so that USING clause
       -- always has static number of parameters to bind.
       IF (Batch  IS NOT  NULL) THEN
          l_argument_string := l_argument_string || ' and GMDL.batch_id = :b ';
       ELSE
          l_argument_string := l_argument_string || ' and 1 = :b ';
       END IF;
       IF(SubInventory  IS NOT  NULL) THEN
          l_argument_string := l_argument_string || ' and RES.subinventory_code = :c ';
       ELSE
          l_argument_string := l_argument_string || ' and 1 = :c ';
       END IF;
       IF(l_from_date  IS NOT  NULL) THEN
          l_argument_string := l_argument_string || ' and TRUNC(RES.requirement_date) >=TO_DATE( :d , ''YYYY/MM/DD'')';
       ELSE
          l_argument_string := l_argument_string || ' and 1 = :d ';
       END IF;
       IF(l_to_date IS NOT  NULL) THEN
          l_argument_string := l_argument_string || ' and  TRUNC(RES.requirement_date) <=TO_DATE( :e  , ''YYYY/MM/DD'')';
       ELSE
           l_argument_string := l_argument_string || ' and 1 = :e ';
       END IF;

       FND_FILE.put_line(FND_FILE.LOG,'SQL Query'||l_argument_string);

            -- execute the Query
            -- instead of execute immediate, use cursor first and then fetch into result.
       open l_refcur FOR l_argument_string USING Batch, l_org_code, SubInventory, l_from_date, l_to_date,l_org_name,Plant, nvl(Batch,1), nvl(SubInventory,1), nvl(l_from_date, 1), nvl(l_to_date,1);
       fetch l_refcur INTO l_result;
       close l_refcur;

        --EXECUTE IMMEDIATE l_argument_string USING l_var_list  ;

        -- write the XML into out file
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
       fnd_file.put_line(FND_FILE.LOG, 'CP : GENERATE_XML(DISPDPCH) : FINISH ');
       EXCEPTION
       WHEN OTHERS THEN
                  fnd_file.put_line(fnd_file.log,SQLERRM);
                  fnd_file.new_line(fnd_file.log,2);
                  fnd_file.put_line(fnd_file.log, fnd_message.get_string('GMO', 'GMO_DISPENSE_DISPATCH_XML_ERR') );
  END GENERATE_DISPDPCH_XML;


--Generate Dispense History XML
PROCEDURE GENERATE_DISPHIST_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                SubInventory IN         VARCHAR2,
                                Batch        IN         NUMBER,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2,
                                OperatorID   IN         VARCHAR2)
IS
TYPE refcur IS REF CURSOR;
l_refcur  refcur;
l_result XMLType;
l_final_clob CLOB ;
l_len number;
l_xml_data varchar2(10);
l_limit number;
l_argument_string  long ;
l_from_date  varchar2(15);
l_to_date  varchar2(15);
l_org_name  VARCHAR2(4000);
l_org_code  VARCHAR2(240);
CURSOR GET_ORG_NAME IS
SELECT hou.name ORGANIZATION_NAME , mp.organization_code ORGANIZATION_CODE
FROM hr_all_organization_units hou,
     mtl_parameters mp
WHERE hou.organization_id = Plant
  AND NVL(hou.date_to, SYSDATE+1) >= SYSDATE
  and mp.organization_id = hou.organization_id;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'CP : GENERATE_XML(DISHIST) : START ');
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Input Parameter - Plant :'||Plant||' and Sub Inventory Code :'||SubInventory||' and Batch  :'||Batch||' From Date :'||FromDate||' To Date :'||ToDate||' Operation :'||OperatorID);
  l_from_date := null;
  l_to_date := null;

  IF(FromDate  IS NOT  NULL) THEN
    l_from_date := substr(FromDate,0,10);
  END IF;
  IF(ToDate IS NOT  NULL) THEN
    l_to_date := substr(ToDate,0,10);
  END IF;
   OPEN GET_ORG_NAME;
     FETCH GET_ORG_NAME into l_org_name, l_org_code;
   CLOSE GET_ORG_NAME;

  l_argument_string := 'select XMLELEMENT("DispenseHistory", XMLCONCAT(XMLSEQUENCETYPE(XMLTYPE(''<BatchNo>''||:x||''</BatchNo>''),
                                            XMLTYPE(''<PlantCode>''||:y||''</PlantCode>''),
                                            XMLTYPE(''<Subinventory_Code>''||:z||''</Subinventory_Code>''),
                                            XMLTYPE(''<FromDate>''||:xx||''</FromDate>''),
                                            XMLTYPE(''<ToDate>''||:yy||''</ToDate>''),
                                            XMLTYPE(''<Operator>''||:zz||''</Operator>'')
                                              )),
                    XMLAGG(XMLELEMENT("DispenseHistoryDetails",
                    XMLFOREST(:orgName as  OrganizationName ,
                    GMDL.subinventory_code as Location ,
                    GMDL.inventory_item_id as Item_id ,
                    MSI.CONCATENATED_SEGMENTS as Item ,
                    MSI.description  as Description ,
                    GMDL.dispense_number DISPENSE_NO ,
                    GMDL.lot_number as Lot,
                    gbh.batch_no as  BatchNo,
                    gbsi.batchstep_no as BatchStepNo ,
                    GMD.LINE_NO   as LINE_NO ,
                     gmo_dispense_pvt.get_net_disp_dispensed_qty(GMDL.dispense_id) as  NetDispensedQuantity ,
                     FND_DATE.DATE_TO_DISPLAYDT(GMDL.dispensed_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) as DispensedDate ,
                    GMDL.required_qty as RequiredQuantity ,
                    lkup.meaning    as DispensingMode,
                     GMDL.dispense_uom DispensedUOM ,
                     GMDL.erecord_id ErecordID,
                     gbsi.oprn_no as Operation,
                    (select nvl(sum(nvl(undispensed_qty,0)),0) from gmo_material_undispenses  where dispense_id = GMDL.dispense_id and GMDL.material_status <> ''REVDISPONLY'') as reverse_dispensed_qty ,
                    (select nvl(sum(material_loss),0)   from gmo_material_undispenses  where dispense_id = GMDL.dispense_id  and GMDL.material_status <> ''REVDISPONLY'') as Material_loss,
                     GMO_UTILITIES.GET_USER_DISPLAY_NAME(GMDL.created_by) Operator)
                                      )  order by GMDL.dispensed_date desc
                          )
                  )
                  from
                    GMO_MATERIAL_DISPENSES GMDL,
                    GME_BATCH_HEADER gbh ,
                    MTL_SYSTEM_ITEMS_VL MSI,
                    Gme_Material_details GMD,
                    fnd_lookups lkup,
                    (SELECT GBS.BATCHSTEP_ID,
                            GBS.BATCHSTEP_NO ,
                            GMDOP.OPRN_NO ,
                            GBSI.MATERIAL_DETAIL_ID
                    FROM
                        GME_BATCH_STEPS      GBS,
                        GME_BATCH_STEP_ITEMS GBSI,
                        GMD_OPERATIONS GMDOP
                    WHERE GBS.BATCHSTEP_ID = GBSI.BATCHSTEP_ID
                      AND GBS.OPRN_ID = GMDOP.OPRN_ID) GBSI
            where gbh.batch_id = GMDL.batch_id
            and gbh.organization_id = GMDL.organization_id
            and GMDL.batch_step_id = GBSI.BATCHSTEP_ID(+)
	      and GMDL.material_detail_id = gbsi.material_detail_id (+)
            and MSI.inventory_item_id = GMDL.inventory_item_id
            and MSI.organization_id = GMDL.organization_id
            and gmd.MATERIAL_DETAIL_ID = GMDL.MATERIAL_DETAIL_ID
            and lkup.lookup_type = ''GMO_DISPENSE_MODE''
            and lkup.lookup_code = GMDL.dispensing_mode
            AND   gbh.organization_id =:a';

       -- Add 1=1 conditions if parameters are missing so that USING clause
       -- always has static number of parameters to bind.

   IF (Batch IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and GMDL.batch_id =:b';
   ELSE
      l_argument_string := l_argument_string || ' and 1 =:b';
   END IF;
   IF(SubInventory  IS NOT  NULL ) THEN
      l_argument_string := l_argument_string || ' and GMDL.subinventory_code =:c';
   ELSE
      l_argument_string := l_argument_string || ' and 1 =:c';
   END IF;
   IF(l_from_date  IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and TRUNC(GMDL.dispensed_date) >=TO_DATE( :d , ''YYYY/MM/DD'')';
   else
      l_argument_string := l_argument_string || ' and 1 = :d ';
   END IF;
   IF(l_to_date IS NOT  NULL) THEN
      l_argument_string := l_argument_string || ' and  TRUNC(GMDL.dispensed_date) <=TO_DATE( :e  , ''YYYY/MM/DD'')';
   else
      l_argument_string := l_argument_string || ' and 1 = :e ';
   END IF;
   IF(OperatorID  IS NOT  NULL)  THEN
      l_argument_string := l_argument_string || ' and GMDL.created_by = :f';
   ELSE
      l_argument_string := l_argument_string || ' and 1 = :f';
   END IF;


   FND_FILE.put_line(FND_FILE.LOG,'SQL Query'||l_argument_string);

          -- execute the Query
          -- EXECUTE IMMEDIATE l_argument_string INTO l_result;
          -- execute the Query
          -- instead of execute immediate, use cursor first and then fetch into result.

   open l_refcur FOR l_argument_string USING Batch, l_org_code, SubInventory, l_from_date, l_to_date,OperatorID,l_org_name,Plant, nvl(Batch,1), nvl(SubInventory,1), nvl(l_from_date, 1), nvl(l_to_date,1),nvl(OperatorID,1);
   fetch l_refcur INTO l_result;
   close l_refcur;


              -- write the XML into out file
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
   fnd_file.put_line(FND_FILE.LOG, 'CP : GENERATE_XML(DISHIST) : FINISH ');
   EXCEPTION
    WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,SQLERRM);
            fnd_file.new_line(fnd_file.log,2);
            fnd_file.put_line(fnd_file.log, fnd_message.get_string('GMO', 'GMO_DISPENSE_HISTORY_XML_ERR') );
            RETURN;
END GENERATE_DISPHIST_XML;
END GMO_DISP_CON_PKG;

/
