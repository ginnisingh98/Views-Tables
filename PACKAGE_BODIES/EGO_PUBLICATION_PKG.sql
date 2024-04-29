--------------------------------------------------------
--  DDL for Package Body EGO_PUBLICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_PUBLICATION_PKG" AS
/* $Header: EGOPBLCB.pls 120.14 2007/10/11 12:54:32 bramnan noship $ */

 PROCEDURE getUDAAttributes
      (
        extension_id    IN  NUMBER,
        p_language      IN  VARCHAR2,
        x_doc           OUT NOCOPY xmltype,
        x_error_message OUT NOCOPY VARCHAR2
        )
        IS

        --  language_clause       varchar2(2000);
        ext_id                NUMBER;
        x_query               varchar2(4000);
        no_extId_exception    EXCEPTION;
        x_temp                xmltype;

      CURSOR C1(p_ext_id NUMBER,p_lang VARCHAR2) IS
          Select xmlElement("Attribute",xmlElement("Id",attribute_id),
                                 xmlElement("Name",attribute_name),
                                 xmlAgg(xmlelement("ValueText",xmlattributes(language as "languageID"),attribute_translatable_value)))
                                 FROM EGO_ALL_ATTR_LANG_V
                                 WHERE extension_id =p_ext_id AND ATTRIBUTE_TRANSLATABLE_VALUE IS NOT NULL
                                 AND LANGUAGE = p_lang GROUP BY ATTRIBUTE_ID, ATTRIBUTE_NAME;


        CURSOR C2(p_ext_id NUMBER) IS
         Select xmlElement("Attribute",xmlElement("Id",attribute_id),
                                xmlElement("Name",attribute_name),
                                xmlAgg(xmlelement("ValueText",xmlattributes(language as "languageID"),attribute_translatable_value)))
                                FROM EGO_ALL_ATTR_LANG_V
                                WHERE extension_id =p_ext_id AND ATTRIBUTE_TRANSLATABLE_VALUE IS NOT NULL
                                GROUP BY ATTRIBUTE_ID, ATTRIBUTE_NAME;

        CURSOR C3(p_ext_id NUMBER) IS
          SELECT  xmlConcat(xmlElement("Id",attributegroup_id),
                        xmlElement("Name", attribute_group_name),
                        xmlagg(xmlelement("Attribute",
                        xmlelement("Id",attribute_id),
                        xmlelement("Name",attribute_name),
                        xmlForest(attribute_char_value AS "Value",
                          attribute_number_value AS "ValueNumeric",
                          attribute_uom_value AS "ValueQuantity",
                          attribute_date_value AS "ValueDate",
                          attribute_datetime_value AS "ValueDateTime")
                          )))
              FROM EGO_ALL_ATTR_BASE_V
              WHERE extension_id = p_ext_id
              GROUP BY attribute_group_name,attributegroup_id ;

      ---------------- SAMPLE XML ----------------------------------------------
      ---------------- <AttributeGroup>  --------------------------------------
      ---------------- <ID>1234</ID> -------------------------------------------
      ---------------- <NAME>INTERNAL_NAME_AG1</NAME> --------------------------
      ---------------- Numeric Attribute ---------------------------------------
      ---------------- <ATTRIBUTE> ---------------------------------------------
      ---------------- <ID>54544</ID> ------------------------------------------
      ---------------- <NAME>Attr1</NAME> --------------------------------------
      ---------------- <VALUENUMERIC>123</VALUENUMERIC> ------------------------
      ---------------- <VALUEQUANTITY>UOMVALUE </VALUEQUANTITY> ----------------
      ---------------- </ATTRIBUTE> --------------------------------------------
      ----------------  <ATTRIBUTE> --------------------------------------------
      ---------------- <ID>54545</ID> ------------------------------------------
      ---------------- <NAME>Attr2</NAME> --------------------------------------
      ---------------- <VALUE>San Francisco</VALUE> ----------------------------
      ----------------  </ATTRIBUTE> -------------------------------------------
      ----------------  Date Time Attribute ------------------------------------
      ----------------  <ATTRIBUTE> --------------------------------------------
      ---------------- <ID>54546</ID> ------------------------------------------
      ---------------- <NAME>Attr3</NAME> --------------------------------------
      --------------- <VALUEDATETIME>10-03-07:22:14:06</VALUEDATETIME> ---------
      --------------- </ATTRIBUTE> ---------------------------------------------
      --------------- Date Attribute -------------------------------------------
      --------------- <ATTRIBUTE> ----------------------------------------------
      ---------------- <ID>54547</ID> ------------------------------------------
      --------------- <NAME>Attr3</NAME> --------------------------------------
      --------------- <VALUEDATE>10-03-07</VALUEDATE> -------------------------
      --------------- </ATTRIBUTE> --------------------------------------------
      --------------- Translatable Attributes ---------------------------------
      --------------- <ATTRIBUTE> ---------------------------------------------
      ---------------- <ID>54548</ID> ------------------------------------------
      --------------- <NAME>Attr4</NAME> --------------------------------------
      --------------- <VALUETEXT LANGUAGEID = "US">LANGVALUE1</VALUETEXT> ------
      --------------- <VALUETEXT LANGUAGEID = "KR">LANGVALUE1</VALUETEXT> ------
      --------------- </ATTRIBUTE> ---------------------------------------------
      --------------- </ATTRIBUTE_GROUP> ---------------------------------------



        BEGIN


        --------- Assign extension_id from input parameteres -------------------

            IF extension_id IS NULL THEN

              x_error_message := 'Extension_id cannot be null';
              RAISE no_extId_exception;
            END IF;

            ext_id := extension_id;

     --------- Query Lang View for Translatable Attributes -------------------------------------------------


        IF (p_language is NOT NULL) THEN

          OPEN C1(ext_id,p_language);
            FETCH C1 INTO x_temp;
          CLOSE C1;

      ---------- Generate the Translatable Attributes for all Languages ------------------------------

        ELSE

          OPEN C2(ext_id);
            FETCH C2 INTO x_temp;
          CLOSE C2;

        END IF;


            ------------ Generate Non - Translatable Attributes ------------------------------------
        OPEN C3(ext_id);
          FETCH C3 INTO x_doc;
        CLOSE C3;

        ------------- Concatenate Translatable and Non- Translatable Attributes to Generate Attribute Group Element

               Select xmlElement("AttributeGroup",x_doc, x_temp)
                INTO  x_doc
                FROM DUAL;


            EXCEPTION
             WHEN no_data_found THEN
               x_error_message := 'unexpected_error';
               x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
             RETURN;
             WHEN no_extId_exception THEN
                x_error_message := 'USER ERROR: Extension Id cannot be Null';
              RETURN;
             WHEN others THEN
               x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
            RETURN;

        END getUDAAttributes;


PROCEDURE getItemIdentification
          (
          inventory_item_id IN NUMBER,
          organization_id   IN NUMBER,
          x_doc             OUT NOCOPY XMLTYPE,
          x_error_message   OUT NOCOPY VARCHAR2
          )

          IS
          ------ Sample xml ----------------------------------------------------
          ------ <ItemIdentification> ------------------------------------------
          ------ <Identification> ----------------------------------------------
          ------ <ID>155</ID> --------------------------------------------------
          ------ <ContextID schemeID = ORGID>204 </ContextID> --------------------
          ------ <Name>Abcd</Name> ---------------------------------------------
          ------ </Identification> ---------------------------------------------
          ------- </ItemIdentification> ----------------------------------------



itemId          number;
orgId           number;
orgIdStr        varchar2(2000);
x_temp          xmltype;
x_query         varchar2(2000);
no_pk_exception EXCEPTION;

BEGIN

        IF ((inventory_item_id IS NULL) OR (organization_id is NULL)) THEN

              RAISE no_pk_exception;

        END IF;

        itemId     := inventory_item_id;
        orgId      := organization_id;
        orgIdStr   := 'ORGID';


      ---------- Generate IDENTIFICATION ELEMENT -------------------------------

        SELECT
        XMLELEMENT("ItemIdentification",
        XMLELEMENT("Identification",
        XMLELEMENT("ID",itemId),
        XMLELEMENT("ContextID",XMLATTRIBUTES(orgIdStr AS "SchemeID"),orgId),
        XMLELEMENT("Name",kfv.concatenated_segments)))
        INTO   x_doc
        FROM  mtl_system_items_vl msiv, org_organization_definitions orgdef,mtl_system_items_b_kfv kfv
        WHERE msiv.inventory_item_id = kfv.inventory_item_id AND
              msiv.organization_id = kfv.organization_id AND
              msiv.organization_id = orgdef.organization_id AND
              msiv.inventory_item_id = itemId AND
              msiv.organization_id = orgId ;

  EXCEPTION
        WHEN no_data_found THEN
            x_error_message := 'unexpected_error';
            x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;
        WHEN no_PK_exception THEN
            x_error_message := 'USER ERROR: Inventory Item Id and Organization Id cannot be Null';
        RETURN;
        WHEN others THEN
            x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;

END getItemIdentification;

PROCEDURE getItemBase
          (
          inventory_item_id IN NUMBER,
          organization_id   IN NUMBER,
          p_language        IN VARCHAR2,
          x_doc             OUT NOCOPY XMLTYPE,
          x_error_message   OUT NOCOPY VARCHAR2
          )
          IS

itemId          NUMBER;
orgId           NUMBER;
x_temp          xmltype;
no_pk_exception EXCEPTION;
lifecycle       varchar2(2000);
lifecycle_phase varchar2(2000);
-- language_clause varchar2(2000);
x_query         varchar2(2000);

          ------ Sample XML ----------------------------------------------
          ------ <ItemBase> ---------------------------------------------
          ------ <Description LanguageID = KR>Itm Descp</Description>---
          ------ <Description LanguageID = US>Itm Descp</Description>---
          ------ <LONGDESCRIPTION>Abcd is an item </LONGDESCRIPTION> -----
          ------ <LIFECYCLE>LC1</ LIFECYCLE> -----------------------------
          ------ <LIFECYCLE_PHASE>LC Phase 1</ LIFECYCLE_PHASE> ----------
          ------ <APPROVAL_STATUS>Approved</APPROVAL_STATUS> -------------
          ------ <Status>Approved</Status> ------------------------------
          ------ <TypeCode>Engineering</TypeCode> ------------
          ------ <EngineeringItemIndicator>Yes</EngineeringItemIndicator> ------
          ------ <BaseUOMCode>Kgs</BaseUOMCode> --------------------------
          ------ <SecondaryUOMCode>Lbs</SecondaryUOMCode> ----------------------
          ------ <CREATION_DATE>01-DEC-2005</CREATION_DATE> --------------
          ------ </ItemBase> --------------------------------------------


CURSOR C1 IS
  SELECT
        lc.element_number,lcphase.element_number
  FROM mtl_system_items_vl itemvl,org_organization_definitions orgdef,
        pa_ego_lifecycles_v lc,pa_ego_phases_v lcphase
  WHERE itemvl.lifecycle_id = lc.proj_element_id AND
        itemvl.current_phase_id = lcphase.proj_element_id AND
        itemvl.organization_id = orgdef.organization_id AND
        itemvl.inventory_item_id = itemId AND itemvl.organization_id = orgId;


BEGIN

          IF ((inventory_item_id IS NULL) OR (organization_id is NULL)) THEN

              RAISE no_pk_exception;

          END IF;

          itemId := inventory_item_id;
          orgId  := organization_id;


          OPEN C1;
                FETCH C1 INTO lifecycle,lifecycle_phase;
          CLOSE C1;

         --------- Commented as langArray has been changed to Varchar to avoid wrapper objects in bpel ------------------------------------
        /*
            language_clause := ' (';

            IF ((langArray IS NOT NULL) AND (langArray.count>0)) THEN
              FOR icount in langArray.first .. langArray.last LOOP
                  language_clause := language_clause ||  '''' || langArray(icount) || ''',';
               END LOOP;
               language_clause := substr(language_clause,0, length(language_clause)-1);
               language_clause := language_clause  || ' ) ';
          */

           -------- Generate Description Elements with p_language where clause ---------------------------------

            IF (p_language IS NOT NULL) THEN

            x_query := 'SELECT XMLAGG(XMLCONCAT(XMLELEMENT("DESCRIPTION",XMLATTRIBUTES(MSIT.language AS "languageId"),
                       MSIT.description))) FROM MTL_SYSTEM_ITEMS_TL MSIT WHERE MSIT.INVENTORY_ITEM_ID = '|| itemId || 'AND MSIT.ORGANIZATION_ID = ' || orgId || '
                       AND MSIT.language = '|| '''' || p_language || '''' ;

            Execute Immediate x_query
            INTO x_temp;


            ELSE
              --- Generate Description Elements without Language clause--------
              SELECT XMLAGG(XMLCONCAT(XMLELEMENT("Description",XMLATTRIBUTES(MSIT.language AS "languageID"),
              MSIT.description)))
              INTO x_temp
              FROM MTL_SYSTEM_ITEMS_TL msit
              WHERE msit.INVENTORY_ITEM_ID = itemId
              AND msit.ORGANIZATION_ID = orgId;
          END IF;

        ------ Generate Primary Attributes of Item -------------

          SELECT
          XMLELEMENT("ItemBase",
          XMLCONCAT(x_temp,
          XMLELEMENT("LongDescription",itemvl.long_description),
          XMLELEMENT("LifeCycle", lifecycle),
          XMLELEMENT("LifeCyclePhase",lifecycle_phase),
          XMLELEMENT("ApprovalStatus",itemvl.approval_status),
          XMLELEMENT("Status",itemvl.inventory_item_status_code),
          XMLELEMENT("TypeCode",itemvl.item_type),
          XMLELEMENT("EngineeringItemFlag",itemvl.eng_item_flag),
          XMLELEMENT("BaseUOMCode",itemvl.primary_uom_code),
          XMLELEMENT("SecondaryUOMCode",itemvl.secondary_uom_code),
          XMLELEMENT("CreationDate",itemvl.creation_date)))
          INTO x_doc
          FROM mtl_system_items_vl itemvl,org_organization_definitions orgdef
          WHERE
          itemvl.organization_id = orgdef.organization_id AND
          itemvl.inventory_item_id = itemId AND itemvl.organization_id = orgId;


EXCEPTION
        WHEN no_data_found THEN
            x_error_message := 'unexpected_error';
            x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;
        WHEN no_PK_exception THEN
            x_error_message := 'USER ERROR: Inventory Item Id and Organization Id cannot be Null';
        RETURN;
        WHEN others THEN
            x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;

END getItemBase;

PROCEDURE getItemAttributes
          (
          inventory_item_id  IN NUMBER,
          organization_id    IN NUMBER,
          extension_id       IN NUMBER,
          p_language         IN VARCHAR2,
          x_doc              OUT NOCOPY xmltype,
          x_error_message    OUT NOCOPY VARCHAR2
          )
          IS

  x_temp            xmltype;
  itemId            number;
  orgId             number;
  x_uda             xmltype;
  no_pk_exception  EXCEPTION;



          --------- Sample XML -------------------------------------------------
          --------- <SyncItemPrimaryAttributeEBM>  ------------------------------------------------
          --------- <DataArea> -----------------------------------------------------
           --------- <SyncItemPrimaryAttribute> -----------------------------------------------------
          --------- ITEM IDENTIFICATION ----------------------------------------
          --------- ITEM BASE --------------------------------------------------
          --------- AttributeGroup - UDA ----------------------------------------
         --------- </SyncItemPrimaryAttribute> -----------------------------------------------------
          --------- </DataArea> -----------------------------------------------------
          -------- </SyncItemPrimaryAttributeEBM> ------------------------------------------------


  BEGIN

          IF ((inventory_item_id IS NULL) OR (organization_id is NULL)) THEN

              RAISE no_pk_exception;

          END IF;

          itemId := inventory_item_id;
          orgId  := organization_id;

  ------- Call getItemIdentification to capture ITEM_IDENTIFICATIION -----------------

         getItemIdentification(
                                inventory_item_id =>itemId,
                                organization_id =>orgId,
                                x_doc =>x_temp,
                                x_error_message =>x_error_message);

  ------  Call getItemBase to capture ITEM_BASE --------------------------------

        getItemBase(
                       inventory_item_id =>itemId,
                       organization_id =>orgId,
                       p_language => p_language,
                       x_doc =>x_doc,
                       x_error_message =>x_error_message);

  ------  Concatenate ITEM_IDENTIFICATION AND ITEM_BASE ------------------------

          SELECT XMLCONCAT(x_temp,x_doc)
          INTO x_doc
          FROM DUAL;

  ------  Call getUDAAttributes to capture UDA XML if itemAttrGroup is not null-

          If extension_id IS NOT NULL THEN

          getUDAAttributes(extension_id =>extension_id,
                           p_language => p_language,
                           x_doc =>x_uda,
                           x_error_message =>x_error_message);


          END IF;

 ------- Generate the SYNC_ITEM XML ------------------------------------------

          SELECT XMLELEMENT("SyncItemPrimaryAttributeEBM",
                 XMLELEMENT("DataArea",
                 XMLELEMENT("SyncItemPrimaryAttribute",
                XMLCONCAT(x_doc,
                 x_uda))))
          INTO   x_doc
          FROM   DUAL;



        EXCEPTION
            WHEN no_data_found THEN
                x_error_message := 'unexpected_error';
                x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
            RETURN;
            WHEN no_PK_exception THEN
                 x_error_message := 'USER ERROR: Inventory Item Id and Organization Id cannot be Null';
            RETURN;
            WHEN others THEN
                x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
            RETURN;


  END getItemAttributes;



PROCEDURE getCategoryAttributes
          (
           category_id           IN NUMBER,
           getFlexAttributesFlag IN CHAR,
           x_doc                 OUT NOCOPY XMLTYPE,
           x_error_message       OUT NOCOPY VARCHAR2
           )

            IS

           ----------------- SAMPLE XML ----------------------------------------
           ----------------- <SyncClassificationSchemeEBM> ---------------------
           ----------------- <DataArea> ----------------------------------------
           ----------------- <SyncClassificationScheme> -----------------------
           ----------------- <ClassificationSchemeIdentification> --------------
           ----------------- <Identification> ----------------------------------
           -----------------<Id></Id> ------------------------------------------
           -----------------</Identification> ----------------------------------
           -----------------</ClassificationSchemeIdentification>---------------
           -----------------<Classification>------------------------------------
           ----------------- <Code>MISC.MISC</Code> ----------------------------
           ------------------ <AttributeGroup> ---------------------------------
           ----------------- <Id></Id> -----------------------------------------
           -----------------  <Name languageId="String"></Name> ----------------
           -----------------  <Attribute> --------------------------------------
           -----------------  <Name languageId="String"></Name> ----------------
           -----------------  <ValueText langaugeId="String"></ValueText>-------
           -----------------  </Attribute> -------------------------------------
           ----------------- </AttributeGroup>----------------------------------
           -----------------  </Classification>---------------------------------
           ----------------- </SyncClassificationScheme>------------------------
           ----------------- </DataArea> ---------------------------------------
           ----------------- </SyncClassificationSchemeEBM> --------------------

    catId               number;
    x_prim              xmltype;
    x_desc              xmltype;
    x_temp              xmltype;
    -- language_clause     varchar2(2000);
    x_query             varchar2(2000);
    no_catId_exception  EXCEPTION;

    -- Remove Attribute Groups Elemenet from DFF ------------------------------
    BEGIN

          IF category_id is NULL THEN

              RAISE no_catId_exception;

          END IF;

    catId := category_id;

    -------- Generate SYNCCLASSIFICATIONSCHEME ELEMENT ---------------------------

    -------- Generate AttributeGroup Element IF flag is true -----------

          IF (getFlexAttributesFlag = 'Y') THEN

              SELECT XMLCONCAT(
                     XMLAGG(XMLELEMENT("AttributeGroup",
                     XMLELEMENT("Id",catId),
                     XMLELEMENT("Name", FND.DESCRIPTIVE_FLEX_CONTEXT_CODE),
                     XMLAGG(XMLELEMENT("Attribute",
                     XMLELEMENT("Name",FND.END_USER_COLUMN_NAME),
                     XMLELEMENT("Value",DECODE(APPLICATION_COLUMN_NAME,'ATTRIBUTE1',CAT.ATTRIBUTE1,'ATTRIBUTE2',CAT.ATTRIBUTE2,
                     'ATTRIBUTE3',CAT.ATTRIBUTE3,'ATTRIBUTE4',CAT.ATTRIBUTE4,'ATTRIBUTE5',CAT.ATTRIBUTE5,
                     'ATTRIBUTE6',CAT.ATTRIBUTE6,'ATTRIBUTE7',CAT.ATTRIBUTE7,'ATTRIBUTE8',CAT.ATTRIBUTE8,
                     'ATTRIBUTE9',CAT.ATTRIBUTE9,'ATTRIBUTE10',CAT.ATTRIBUTE10,'ATTRIBUTE11',CAT.ATTRIBUTE11,
                    'ATTRIBUTE12',CAT.ATTRIBUTE12,'ATTRIBUTE13',CAT.ATTRIBUTE13,'ATTRIBUTE14',CAT.ATTRIBUTE14)))))))
              INTO   x_temp
              FROM   MTL_CATEGORIES_B_KFV CAT,
                     FND_DESCR_FLEX_COL_USAGE_VL FND
              WHERE  (FND.APPLICATION_ID=401)
                     AND (FND.DESCRIPTIVE_FLEXFIELD_NAME LIKE 'MTL_CATEGORIES')
                     AND  FND.ENABLED_FLAG ='Y'
                     AND CAT.CATEGORY_ID =catId
                     GROUP BY FND.DESCRIPTIVE_FLEX_CONTEXT_CODE;
           END IF;

     ----------- Generate SyncClassificationSchemeEBM ELEMENT ------------------

              SELECT
                XMLELEMENT("SyncClassificationSchemeEBM",
                XMLELEMENT("DataArea",
                XMLELEMENT("SyncClassificationScheme",
                XMLELEMENT("ClassificationSchemeIdentification",
                XMLELEMENT("Identification",
                XMLELEMENT("ID",catId))),
                XMLELEMENT("Classification",
                XMLELEMENT("Code",CAT.CONCATENATED_SEGMENTS),x_temp))))
              INTO x_doc
              FROM MTL_CATEGORIES_B_KFV CAT
              WHERE CAT.CATEGORY_ID =catId;


    EXCEPTION
        WHEN no_data_found THEN
            x_error_message := 'unexpected_error';
            x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;
        WHEN no_catId_exception THEN
            x_error_message := 'USER ERROR: Category Id cannot be Null';
        RETURN;
        WHEN others THEN
            x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;


    END getCategoryAttributes;

PROCEDURE getCatalogAttributesInternal
          (
          catalogId        IN  NUMBER,
          parentCategoryId IN NUMBER,
          categoryId       IN NUMBER,
          p_language       IN VARCHAR2,
          x_doc            OUT NOCOPY xmltype,
          x_error_message  OUT NOCOPY VARCHAR2
          )
IS

   cat_set_id           number;
   x_iden               xmltype;
   x_desc               xmltype;
   x_temp1              xmltype;
   x_temp2              xmltype;
   x_temp2_child        xmltype;
   x_query              varchar2(2000);
   -- language_clause      varchar2(2000);
   no_calg_id_exception EXCEPTION;

BEGIN

    IF catalogId is NULL THEN

        RAISE no_calg_id_exception;
    END IF;



    cat_set_id := catalogId;


    ------ Generate CATALOGIDENTIFICATION ELEMENT ----------------------------

      SELECT XMLELEMENT("CatalogIdentification",
             XMLELEMENT("Identification",
             XMLELEMENT("ID",cat_set_id),
             XMLELEMENT("Name",CATEGORY_SET_NAME)))
      INTO x_iden
      FROM mtl_category_sets_vl
      WHERE CATEGORY_SET_ID = cat_set_id;

    ------ Generate DESCRIPTION ELEMENT ----------------------------------------

    --------- Commented as langArray has been changed to Varchar to avoid wrapper objects in bpel -----------------


            /*language_clause := ' (';

             IF ((langArray IS NOT NULL) AND (langArray.count>0)) THEN
               FOR icount in langArray.first .. langArray.last LOOP
                  language_clause := language_clause ||  '''' || langArray(icount) || ''',';
               END LOOP;
               language_clause := substr(language_clause,0, length(language_clause)-1);
               language_clause := language_clause  || ' ) ';
            */
    ------ Based on p_language, construct the DESCRIPTION ELEMENT --------------

            IF (p_language IS NOT NULL) THEN

               x_query := 'SELECT XMLAGG(XMLELEMENT("Description",XMLATTRIBUTES(LANGUAGE AS "LanguageID"),DESCRIPTION))
                  FROM  mtl_category_sets_tl
                  WHERE category_set_id = '|| cat_set_id || 'AND language = '|| '''' || p_language || '''' ;

              Execute Immediate x_query
              INTO x_desc;

            ELSE

              SELECT XMLAGG(XMLELEMENT("Description",XMLATTRIBUTES(LANGUAGE AS "LanguageID"),DESCRIPTION))
              INTO x_desc
              FROM  mtl_category_sets_tl
              WHERE category_set_id =cat_set_id;
          END IF;

        ----- Generate CATALOGBASE ELEMENT -------------------------------------

              SELECT XMLELEMENT("CatalogBase",x_desc)
              INTO x_desc
              FROM DUAL;


       ------ Generate ClassificationCode Element if parentCategory Id is not NULL ----

          IF (parentCategoryId is not Null) THEN

              SELECT
                    XMLELEMENT("ClassificationCode",
                    XMLATTRIBUTES(CAT.CONCATENATED_SEGMENTS AS "Name"),parentCategoryId)
                    INTO x_temp1
                    FROM MTL_CATEGORIES_B_KFV CAT
                    WHERE CAT.CATEGORY_ID = parentCategoryId;
        END IF;

       ----- Generate ChildClassificationCode Element if categoryId is not NULL -----

             IF (categoryId is not NUll) THEN

                  SELECT  XMLELEMENT("ChildClassificationCode",
                   XMLATTRIBUTES(CAT.CONCATENATED_SEGMENTS AS "Name"),categoryId)
                      INTO x_temp2
                      FROM MTL_CATEGORIES_B_KFV CAT
                      WHERE CAT.CATEGORY_ID = categoryId;
             END IF;

          ------------- Generate CatalogClassification ELEMENT -----------------

                      SELECT XMLELEMENT("CatalogClassification",
                             XMLELEMENT("CatalogClassificationStructure",
                                         x_temp1,x_temp2))
                      INTO x_temp1
                      FROM DUAL;

	 select XMLCONCAT(x_iden,x_desc,x_temp1) into x_doc from dual;

	EXCEPTION
		WHEN no_data_found THEN
		    x_error_message := 'unexpected_error';
		    x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
		RETURN;
		WHEN no_calg_id_exception THEN
		    x_error_message := 'USER ERROR: Catalog Id cannot be Null';
		RETURN;
		WHEN others THEN
		    x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
		RETURN;

END getCatalogAttributesInternal;

PROCEDURE getCatalogAttributes
          (
          catalogId        IN  NUMBER,
          parentCategoryId IN NUMBER,
          categoryId       IN NUMBER,
          p_language       IN VARCHAR2,
          x_doc            OUT NOCOPY xmltype,
          x_error_message  OUT NOCOPY VARCHAR2
          )
          -- Display Empty Description Tag
          IS

          ------------- SAMPLE XML ---------------------------------------------
          ------------- <SyncCatalogEBM> ---------------------------------------
          ------------- <DataArea> ---------------------------------------------
          ------------- <SyncCatalog> ------------------------------------------
          ------------- <CatalogIdentification> --------------------------------
          ------------- <Identification> ---------------------------------------
          ------------- <ID>200</ID> -------------------------------------------
          ------------- <Name>catalog1</NAME> ----------------------------------
          ------------- </Identification> --------------------------------------
          ------------- </CatalogIdentification> -------------------------------
          ------------- <CatalogBase> ------------------------------------------
          ------------- <Description languageID=US>Catalog1 Descp</Description>-
          ------------- </CatalogBase> -----------------------------------------
          ------------- <CatalogClassification> --------------------------------
	  ------------- <CatalogClassificationStructure> -----------------------
          ------------- <ClassificationCode Name=""></ClassificationCode> ------
          ------------- <ChildClassificationCode Name=""></ChildClassificationCode>---
          ------------- </CatalogClassificationStructure>-----------------------
          ------------- </CatalogClassification> -------------------------------
          ------------- </SyncCatalog ------------------------------------------
          ------------- </DataArea> ---------------------------------------------
          ------------- </SyncCatalogEBM> --------------------------------------

   cat_set_id           number;
   x_iden               xmltype;
   x_desc               xmltype;
   x_temp1              xmltype;
   x_temp2              xmltype;
   x_temp2_child        xmltype;
   x_cat		xmltype;
   x_query              varchar2(2000);
   -- language_clause      varchar2(2000);
   no_calg_id_exception EXCEPTION;


    BEGIN
	getCatalogAttributesInternal(
          catalogId,
          parentCategoryId,
          categoryId,
          p_language,
          x_cat,
          x_error_message
	);

        -------------- Generate SyncCatalogEBM Element -------------------------
                SELECT XMLELEMENT("SyncCatalogEBM",
                           XMLELEMENT("DataArea",
                           XMLELEMENT("SyncCatalog",
                           x_cat)))
                           INTO x_doc
                           FROM DUAL;


       EXCEPTION
        WHEN no_data_found THEN
            x_error_message := 'unexpected_error';
            x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;
        WHEN no_calg_id_exception THEN
            x_error_message := 'USER ERROR: Catalog Id cannot be Null';
        RETURN;
        WHEN others THEN
            x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
        RETURN;

    END getCatalogAttributes;



	---------------------------------------
        --  getDataLevelId

        --  input
        --  p_data_level_internal_name
        --  can take one of these values
	--      G_ITM_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_LEVEL';
	--      G_ITM_ORG_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_ORG';
	--      G_ITM_SUP_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP';
	--      G_ITM_SUP_SITE_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE';
	--      G_ITM_SUP_SITE_ORG_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE_ORG';

        --  output
        --  data_level_id of the Internal name
        --  0 (zero) if the Internal Name did not match any
        ---------------------------------------


	FUNCTION getDataLevelId	(p_data_level_internal_name IN VARCHAR2)
        RETURN NUMBER IS
                x_data_level_id		NUMBER := 0;

		CURSOR data_level_cursor (c_data_level_int_name VARCHAR2)	IS
			SELECT data_level_id
                        FROM ego_data_level_vl
                        WHERE data_level_name  = c_data_level_int_name;

	BEGIN
                --  TBD : Should we add null check for incomin param ?
		OPEN data_level_cursor(p_data_level_internal_name);
			FETCH data_level_cursor INTO x_data_level_id;
		CLOSE data_level_cursor;
                RETURN x_data_level_id;
	END getDataLevelId;


	---------------------------------------
        --  getSupplierAttributes
        ---------------------------------------
        --  sample output will be

		--				<SupplierPartyReference>
		--					<PartyIdentification>
		--						<Identification>
		--							<ID></ID>
		--							<Name></Name>
		--						</Identification>
		--					</PartyIdentification>
		--				</SupplierPartyReference>
		--				<TimePeriod>
		--					<StartDateTime></StartDateTime>
		--					<EndDateTime></EndDateTime>
		--				</TimePeriod>

        ---------------------------------------
        PROCEDURE getSupplierAttributes
        (
              p_api_version		IN NUMBER,
              p_supplier_id		IN NUMBER,
              p_language	  	IN VARCHAR2,	--	If none is passed all languages are returned back
              x_doc		        OUT NOCOPY XMLTYPE,
              x_error_message		OUT NOCOPY VARCHAR2
        )
        IS
        BEGIN
              --  TBD : add debug

              --	query Supplier for ID
              --        TBD : Ask Gopal what is the output format expected ?
              --              Is it the one mentioned above ?
              Select XMLCONCAT(XMLELEMENT("SupplierPartyReference",
		XMLELEMENT("PartyIdentification",
			XMLELEMENT("Identification",
                            XMLELEMENT("ID",  vendor_id),
			    XMLELEMENT("NAME", vendor_name)
			)
		)
	      ),
		XMLELEMENT("TimePeriod",
			XMLELEMENT("StartDateTime",start_date_active),
			XMLELEMENT("EndDateTime",end_date_active)
		)
	      )
              INTO  x_doc
              FROM	 ap_suppliers
              WHERE vendor_id = p_supplier_id;

        EXCEPTION
          WHEN no_data_found THEN
              x_error_message := 'No Data found';
              x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;
          WHEN others THEN
              x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;

        END getSupplierAttributes;

        ---------------------------------------
	--	Get Supplier Site Attributes
        ---------------------------------------
        ---------------------------------------
        --  sample output will be

		--				<SupplierPartyReference>
		--					<PartyIdentification>
		--						<Identification>
		--							<ID></ID>
		--							<Name></Name>
		--						</Identification>
		--					</PartyIdentification>
		--				</SupplierPartyReference>
		--				<TimePeriod>
		--					<StartDateTime></StartDateTime>
		--					<EndDateTime></EndDateTime>
		--				</TimePeriod>
		--				<AttributeGroup></AttributeGroup>
		--				<ItemSupplierLocation>
		--					<LocationReference>
		--						<LocationIdentification>
		--
		--						</LocationIdentification>
		--					</LocationReference>
		--				</ItemSupplierLocation>

        ---------------------------------------
        PROCEDURE getSupplierSiteAttributes(
              p_api_version		IN NUMBER,
              p_supplier_id		IN NUMBER,
              p_supplier_site_id        IN NUMBER,
              p_language		IN VARCHAR2,	--	If none is passed all languages are returned back
              x_doc		        OUT NOCOPY XMLTYPE,
              x_error_message		OUT NOCOPY VARCHAR2
        )
        IS
        BEGIN
          --  TBD : Add Debug here
            Select
                 XMLCONCAT(
                 XMLELEMENT("SupplierPartyReference",
                  XMLELEMENT("PartyIdentification",
                          XMLELEMENT("Identification",
                              XMLELEMENT("ID",  vendor_id),
                              XMLELEMENT("NAME", vendor_name)
                          )
                  )
                 ),
		 XMLELEMENT("TimePeriod",
			XMLELEMENT("StartDateTime",start_date_active),
			XMLELEMENT("EndDateTime",end_date_active)
		 ),
                 (select XMLELEMENT("ItemSupplierLocation",
				XMLELEMENT("LocationReference",
					XMLELEMENT("LocationIdentification",
						XMLELEMENT("Identification",
							XMLELEMENT("ID",  ss.vendor_site_id),
							XMLELEMENT("NAME", ss.VENDOR_SITE_CODE)
						)
					)
				)
			)
                 FROM ap_supplier_sites_all ss
                 WHERE ss.vendor_site_id = p_supplier_site_id
                 ))
		 INTO  x_doc
               FROM	 ap_suppliers
              WHERE vendor_id = p_supplier_id;

        EXCEPTION
          WHEN no_data_found THEN
              x_error_message := 'No Data found';
              x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
              RETURN;
          WHEN others THEN
              x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
              RETURN;
        END getSupplierSiteAttributes;

        ---------------------------------------
	--	Get Item Supplier Attributes

        --  Output
	--	<SyncItemSupplierEBM>
	--		<DataArea>
        --			<SyncItemSupplier>
        --			     ---ITEM IDENTIFICATION---
        --			     --- ITEM BASE ---
        --			    <ItemSupplier>
	--					<SupplierPartyReference>
	--						<PartyIdentification>
	--							<Identification>
	--								<ID></ID>
	--								<Name></Name>
	--							</Identification>
	--						</PartyIdentification>
	--					</SupplierPartyReference>
	--					<TimePeriod>
	--						<StartDateTime></StartDateTime>
	--						<EndDateTime></EndDateTime>
	--					</TimePeriod>
        --			          ---UDA XML---
        --			     </ItemSupplier>
        --			</SyncItemSupplier>
	--		</DataArea>
	--	</SyncItemSupplierEBM>
        ---------------------------------------
	PROCEDURE getItemSupplierAttributes
	(
            p_api_version	  IN  NUMBER,
            p_inventory_item_id	  IN  NUMBER,		--	Item Identifier1
            p_organization_id	  IN  NUMBER,		--	Item Identifier2
            p_supplierId	  IN  NUMBER,		--	Supplier Identifier
            p_extension_id        IN  NUMBER,	        --      pk for identifying the row in ext values table
            p_language		  IN  VARCHAR2,
            x_doc		  OUT NOCOPY XMLTYPE,
            x_error_message	  OUT NOCOPY VARCHAR2
	)
	IS
            l_data_level_id   NUMBER;
            l_item_base_info  XMLTYPE;
            l_item_id_info    XMLTYPE;
            l_supplier_info   XMLTYPE;
            l_uda_xml         XMLTYPE;

	BEGIN
          --	1.	get_data_level_id for the data_level_internal_name
          l_data_level_id := getDataLevelId(G_ITM_SUP_DATA_LVL);

          --  2.  get item id and base xml
          --  TBD : remove PIMDH_PUBLISH_PKGNEW
          getItemIdentification(
            p_inventory_item_id,
            p_organization_id,
            l_item_id_info,
            x_error_message
          );

          --  TBD : remove PIMDH_PUBLISH_PKGNEW
          getItemBase(
            p_inventory_item_id,
            p_organization_id,
            p_language,
            l_item_base_info,
            x_error_message
          );

          SELECT  xmlconcat(l_item_id_info, l_item_base_info)
          INTO    l_item_id_info
          FROM    dual;

          --  3.  get Supplier info
          getSupplierAttributes
          (
            p_api_version     =>  1.0,
            p_supplier_id     =>  p_supplierId,
            p_language	      =>  p_language,
            x_doc	      =>  l_supplier_info,
            x_error_message   =>  x_error_message
          );

          --	3.	get the attributes for this intersection
          getUDAAttributes
          (
            extension_id      =>  p_extension_id,
            p_language        =>  p_language,
            x_doc	      =>  l_uda_xml,
            x_error_message   =>  x_error_message
          );

          SELECT  XMLELEMENT("SyncItemSupplierEBM",
			XMLELEMENT("DataArea",
				XMLELEMENT("SyncItemSupplier",
				    l_item_id_info,
				    XMLELEMENT("ItemSupplier",
				      l_supplier_info,
				      l_uda_xml
				)
                  )))
          INTO x_doc
          FROM DUAL;

        EXCEPTION
          WHEN no_data_found THEN
              x_error_message := 'No Data found';
              x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;
          WHEN others THEN
              x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;
	END getItemSupplierAttributes;
	---------------------------------------

        --  sample output will be

	--	<SyncItemSupplierEBM>
	--		<DataArea>
        --			<SyncItemSupplier>
        --			     ---ITEM IDENTIFICATION---
        --			     --- ITEM BASE ---
        --			    <ItemSupplier>
        --			          <SupplierPartyReference>
	--					<PartyIdentification>
	--						<Identification>
	--					              <ID>200</ID>
	--						      <Name></Name>
	--						</Identification>
	--					<PartyIdentification>
        --			          </SupplierPartyReference>
	--				<TimePeriod>
	--					<StartDateTime></StartDateTime>
	--					<EndDateTime></EndDateTime>
	--				</TimePeriod>
	--				<AttributeGroup></AttributeGroup>
	--				<ItemSupplierLocation>
	--					<LocationReference>
	--						<LocationIdentification>
	--						</LocationIdentification>
	--					</LocationReference>
	--				</ItemSupplierLocation>
        --			        ---UDA XML---
        --			     </ItemSupplier>
        --			</SyncItemSupplier>
	--		</DataArea>
	--	</SyncItemSupplierEBM>
	---------------------------------------
	PROCEDURE getItemSupplierSiteAttributes
	(
		p_api_version		IN  NUMBER,
		p_inventory_item_id	IN  NUMBER,
		p_organization_id	IN  NUMBER,
		p_supplierId		IN  NUMBER,
		p_site_id	        IN  NUMBER,
		p_extension_id          IN  NUMBER,
		p_language		IN  VARCHAR2,	--	If none is passed all languages are returned back
		x_doc			OUT NOCOPY xmltype,
		x_error_message		OUT NOCOPY varchar2
	)
        IS
            l_data_level_id   NUMBER;
            l_item_base_info  XMLTYPE;
            l_item_id_info    XMLTYPE;
            l_supplier_site_info   XMLTYPE;
            l_uda_xml         XMLTYPE;

	BEGIN
          --	1.	get_data_level_id for the data_level_internal_name
          l_data_level_id := getDataLevelId(G_ITM_SUP_SITE_DATA_LVL);

          --  2.  get item id and base xml
          --  TBD : remove PIMDH_PUBLISH_PKGNEW
          getItemIdentification(
            p_inventory_item_id,
            p_organization_id,
            l_item_id_info,
            x_error_message
          );

          --  TBD : remove PIMDH_PUBLISH_PKGNEW
          getItemBase(
            p_inventory_item_id,
            p_organization_id,
            p_language,
            l_item_base_info,
            x_error_message
          );

          SELECT  xmlconcat(l_item_id_info, l_item_base_info)
          INTO    l_item_id_info
          FROM    dual;

          --  3.  get Supplier info
          getSupplierSiteAttributes
          (
            p_api_version   =>  1.0,
            p_supplier_id   =>  p_supplierId,
            p_supplier_site_id      =>  p_site_id,
            p_language	    =>  p_language,
            x_doc	    =>  l_supplier_site_info,
            x_error_message =>  x_error_message
          );

          --	3.	get the attributes for this intersection
          getUDAAttributes
          (
            extension_id      =>  p_extension_id,
            p_language        =>  p_language,
            x_doc	      =>  l_uda_xml,
            x_error_message   =>  x_error_message
          );

          SELECT  XMLELEMENT("SyncItemSupplierEBM",
  			XMLELEMENT("DataArea",
				XMLELEMENT("SyncItemSupplier",
		                    l_item_id_info,
			            XMLELEMENT("ItemSupplier",
					l_supplier_site_info,
					l_uda_xml)
                  ))
	  )
          INTO x_doc
          FROM DUAL;

        EXCEPTION
          WHEN no_data_found THEN
              x_error_message := 'No Data found';
              x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;
          WHEN others THEN
              x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
          RETURN;
	END getItemSupplierSiteAttributes;

       ---------------------------------------
        FUNCTION getItemIdentification
          (
            p_inventory_item_id  IN NUMBER,
            p_organization_id    IN NUMBER
          )
        RETURN XMLTYPE
        IS
          l_item_info_xml XMLTYPE;
          l_error_message VARCHAR2(4000);
        BEGIN
          getItemIdentification
          (
            inventory_item_id  => p_inventory_item_id,
            organization_id    => p_organization_id,
            x_doc              => l_item_info_xml,
            x_error_message    => l_error_message
          );

          if (l_error_message IS NULL) THEN
            return l_item_info_xml;
          else
            return null;
          end if;
        END getItemIdentification;
        ------------------------------------------------------
        --  getStructureAttributes

        --  input
        --    p_structure_id  - bill_sequence_id for the structure
        --    p_component_id  - component_sequence_id for the Component
        --  output
        --    the output structure definition will contain COMPONENT_ITEM in it only
        --    if p_component_id is specified then

        --  output sample
        --	<SyncItemStructure>
        --	   <ItemStructureIdentification>
        --	         <Identification>
        --	              <ID>200</ID>
        --	              <Name>PBOM</Name>
        --	         </Identification>
        --	   </ItemStructureIdentification>
        --	    ---ITEM IDENTIFICATION---
        --	   <ComponentItem>
        --	      ---ITEM IDENTIFICATION---
        --	      <Quantity>10</QUANTITY>
        --	   </ComponentItem>
        --	   <ComponentItem>
        --	      ---ITEM IDENTIFICATION---
        --	      <QUANTITY>10</QUANTITY>
        --	   </ComponentItem>
        --	   <ComponentItem>
        --	      ---ITEM IDENTIFICATION---
        --	      <QUANTITY>10</QUANTITY>
        --	   </ComponentItem>
        --	</SyncItemStructure>
        ------------------------------------------------------

        PROCEDURE getStructureAttributes
        (
          p_api_version		        IN NUMBER,
          p_structure_id	        IN NUMBER,
          p_component_id	        IN NUMBER,
          p_language		        IN VARCHAR2,  --	If none is passed all languages are returned back
          p_get_first_level_comps       IN VARCHAR2,
          x_doc		                OUT NOCOPY XMLTYPE,
          x_error_message	        OUT NOCOPY VARCHAR2
        )
        IS
          l_assly_item_id NUMBER;
          l_assly_item_org_id NUMBER;
          l_comp_item_id NUMBER;

          l_assly_item_info_xml XMLTYPE;
          l_comp_item_info_xml XMLTYPE;

        BEGIN
		--  TBD : debug :print input vars here

		SELECT assembly_item_id, organization_id INTO l_assly_item_id, l_assly_item_org_id
		FROM bom_structures_b
		WHERE bill_sequence_id = p_structure_id ;

		IF (p_component_id is not null) THEN
			SELECT component_item_id INTO l_comp_item_id
			FROM bom_components_b
			WHERE bill_sequence_id = p_structure_id
			AND component_sequence_id = p_component_id;
		END IF;

		  getItemIdentification(
		    l_assly_item_id,
		    l_assly_item_org_id,
		    l_assly_item_info_xml,
		    x_error_message
		  );

		  IF (p_component_id is not null) THEN
		    getItemIdentification(
		      l_comp_item_id,
		      l_assly_item_org_id,
		      l_comp_item_info_xml,
		      x_error_message
		    );
		  END IF;

		  IF (p_component_id is not null) THEN
		    SELECT  xmlelement("SyncItemStructureEBM",
		       xmlelement("DataArea",xmlelement("SyncItemStructure",
			XMLELEMENT("ItemStructureIdentification",
			 XMLELEMENT("Identification",
			  xmlforest(s.bill_sequence_id AS "ID",
				    nvl(s.alternate_bom_designator,'PRIMARY') AS "NAME")
			)),
			XMLELEMENT("ItemReference",l_assly_item_info_xml),
			(SELECT   XMLELEMENT("ComponentItem",
				   -- XMLELEMENT("COMPONENT_SEQUENCE_ID",c.COMPONENT_SEQUENCE_ID),
				    XMLELEMENT("ItemReference", l_comp_item_info_xml),
				    xmlelement("ComponentItemBase",
					    xmlelement("Quantity",   c.component_quantity),
					    xmlelement("EffectiveTimePeriod",
						    xmlelement("EndDateTime",   c.disable_date)
					    )
				    )
				  )
			 FROM bom_components_b c
			 where c.component_sequence_id  = p_component_id
			)
		      )))
		    INTO x_doc
		    FROM bom_structures_b s
		    WHERE s.bill_sequence_id = p_structure_id;
		  ELSE
                    BEGIN
                      IF ((p_get_first_level_comps IS NULL) OR (p_get_first_level_comps = 'N')) THEN
                        BEGIN
                            SELECT  xmlelement("SyncItemStructureEBM",
                                            xmlelement("DataArea",
                                                    xmlelement("SyncItemStructure",
                                                            XMLELEMENT("ItemStructureIdentification",
                                                                    XMLELEMENT("Identification",
                                                                            xmlforest(s.bill_sequence_id AS "ID",  nvl(s.alternate_bom_designator,'PRIMARY') AS "NAME")
                                                                    )
                                                            ),
                                                            XMLELEMENT("ItemReference",l_assly_item_info_xml)
                                                    )
                                            )
                                         )
                            INTO x_doc
                            FROM bom_structures_b s
                            WHERE s.bill_sequence_id = p_structure_id;
                        END;
                      ELSIF (p_get_first_level_comps = 'Y') THEN
                        BEGIN
                          SELECT  xmlelement("SyncItemStructureEBM",
                             xmlelement("DataArea",xmlelement("SyncItemStructure",
                              XMLELEMENT("ItemStructureIdentification",
                               XMLELEMENT("Identification",
                                xmlforest(s.bill_sequence_id AS "ID",
                                          nvl(s.alternate_bom_designator,'PRIMARY') AS "NAME")
                              )),
                              XMLELEMENT("ItemReference",l_assly_item_info_xml),
                              (SELECT   XMLAGG(
                                          XMLELEMENT("ComponentItem",
                                           -- XMLELEMENT("COMPONENT_SEQUENCE_ID",c.COMPONENT_SEQUENCE_ID),
                                            XMLELEMENT("ItemReference",getItemIdentification(c.component_item_id, l_assly_item_org_id)),
                                            xmlelement("ComponentItemBase",
                                                    xmlelement("Quantity",   c.component_quantity),
                                                    xmlelement("EffectiveTimePeriod",
                                                            xmlelement("EndDateTime",   c.disable_date)
                                                    )
                                            )
                                          )
                                        )
                               FROM bom_components_b c
                               where c.bill_sequence_id = s.common_bill_sequence_id
                              )
                            )))
                          INTO x_doc
                          FROM bom_structures_b s
                          WHERE s.bill_sequence_id = p_structure_id;
                        END;
                      END IF;
                    END;
                  END IF;

          EXCEPTION
            WHEN no_data_found THEN
                x_error_message := 'No Data found';
                x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
            RETURN;
            WHEN others THEN
                x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
            RETURN;
          END getStructureAttributes;


        --------------------------------------------------
        --  getItemCategoryAttributes

        --  sample output
        --	<SYNC_ITEM_CATALOG>
        --	   ---ITEM IDENTIFICATION---
        --	   ---ITEM BASE ---
        --	   <ITEM_CATALOG>
        --	         <CATALOG_IDENTIFICATION>
        --	               <PRIMARY_IDENTIFICATION>
        --	                    <ID>200</ID>
        --	                    <NAME>Catalog1</NAME>
        --	               <PRIMARY_IDENTIFICATION>
        --	               <DESCRIPTION>Catalog1 Descp</DESCRIPTION>
        --	           </CATALOG_IDENTIFICATION >
        --	          <CATALOG_CLASSIFICATION>
        --	               <ID>400</ID>
        --	               <CODE>MISC.MISC</CODE>
        --	          <CATALOG_CLASSIFICATION>
        --	   <ITEM_CATALOG>
        --	<SYNC_ITEM_CATALOG>
        --------------------------------------------------

        PROCEDURE getItemCategoryAttributes
        (
          p_api_version		IN  NUMBER,
          p_inventory_item_id	IN NUMBER,
          p_organization_id	IN NUMBER,
          p_catalog_id		IN NUMBER,
          p_category_id		IN NUMBER,
          p_language		IN VARCHAR2,	--	If none is passed all languages are returned back
          x_doc			OUT NOCOPY xmltype,
          x_error_message	OUT NOCOPY varchar2
        )
        IS
          l_item_id_info XMLTYPE;
          l_item_base_info XMLTYPE;
          l_catalog_info XMLTYPE;
          l_category_info XMLTYPE;
        BEGIN
          --  1.  fetch item id and base clauses

          getItemIdentification(
            p_inventory_item_id,
            p_organization_id,
            l_item_id_info,
            x_error_message
          );

          getItemBase(
            p_inventory_item_id,
            p_organization_id,
            p_language,
            l_item_base_info,
            x_error_message
          );

          SELECT  xmlconcat(l_item_id_info, l_item_base_info)
          INTO    l_item_id_info
          FROM    dual;

          --  2.  fetch the catalog informations for the given item from mtl_item_categories
          --      categories from this can be across multiple catalogs
          --      group all of the categories unders its own catalog
---

	  getCatalogAttributesInternal
          (
            p_catalog_id,
            null,
            p_category_id,
            p_language,
            l_catalog_info,
            x_error_message
          );
---


          IF l_catalog_info IS NOT NULL THEN
            SELECT  XMLELEMENT("ItemCatalog",
			XMLELEMENT("CatalogReference",l_catalog_info))
            INTO    l_catalog_info
            FROM    dual;
          END IF;

          IF (l_item_id_info IS NOT NULL)
              OR (l_catalog_info IS NOT NULL) THEN
            SELECT  XMLELEMENT("SyncItemCatalogEBM",
			XMLELEMENT("DataArea",
				XMLELEMENT("SyncItemCatalog",
					XMLCONCAT(l_item_id_info, l_catalog_info)
			)))
            INTO x_doc
            FROM dual;
          END IF;

        EXCEPTION
        WHEN OTHERS then
		x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm; -- TBD : Attend to this
          return;

        END getItemCategoryAttributes;

	PROCEDURE getEventPayload
        (
          p_sequence_id   IN NUMBER,
          p_event         OUT NOCOPY WF_EVENT_T,
          x_error_message OUT NOCOPY VARCHAR2
        )

        IS

        BEGIN


        ----------- Retrieve Event Payload based on Sequence_Id from Ego_business_events_tracking ---------

          SELECT EVENT_PAYLOAD
          INTO p_event
          FROM EGO_BUSINESS_EVENTS_TRACKING
          WHERE SEQUENCE_ID = p_sequence_id;

          EXCEPTION
              WHEN no_data_found THEN
                  x_error_message := 'No Data found';
                  x_error_message := x_error_message || ':' || SQLCODE || ':' || sqlerrm;
              RETURN;
              WHEN others THEN
                  x_error_message := 'errormessage' || ':' || SQLCODE || ':' || sqlerrm;
              RETURN;

        END getEventPayload;

END EGO_PUBLICATION_PKG;

/
