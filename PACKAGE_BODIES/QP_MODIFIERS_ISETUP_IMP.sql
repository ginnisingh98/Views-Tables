--------------------------------------------------------
--  DDL for Package Body QP_MODIFIERS_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIERS_ISETUP_IMP" AS
/* $Header: QPMODIMB.pls 120.8 2006/07/07 19:30:07 rbagri ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      QPMODIMB.pls
--
--  DESCRIPTION
--
--      Body of package QP_MODIFIERS_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  31-DEC-02   Anupam Jain    Initial Creation
--  12-Feb-03   M V M P Tilak  Modifications for bug#2797778
--  07-MAR-03   Anupam Jain,   removed NULL defaulted for global_flag
--                             and net_amount_flag, Bug# 2798830
--  31-MAR-03   Anupam Jain,   Added NULL check for input XML Clobs
--  04/21/2003  Anupam Jain,   Modified to change DATE and NUMBER
--                             fields to VARCHAR2(19) and VARCHAR2(150).
--                             Bug# 2915610
***************************************************************************/
FUNCTION get_product_code   (p_product_attr_context  varchar2,
                            p_product_attr  varchar2,
                            p_product_attr_val varchar2)
  RETURN VARCHAR2
  is
    item_id   varchar2(240) := null;
    c_name    varchar2(240) := null;
    l_org_id         number;
  begin
   if p_product_attr_context = 'ITEM' THEN
        IF p_product_attr = 'PRICING_ATTRIBUTE1'  THEN
            begin
                SELECT  KFV.concatenated_segments into item_id
                FROM MTL_SYSTEM_ITEMS_KFV KFV
                WHERE  inventory_item_id = p_product_attr_val
                AND rownum =1;
                RETURN item_id;
               EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
             End;
             ELSIF  (p_product_attr = 'PRICING_ATTRIBUTE2') THEN
              begin
               select category_name into c_name
               from qp_item_categories_v
               where category_id = p_product_attr_val
               and rownum = 1;
               return c_name;
               EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
              end;
             ELSE
               RETURN p_product_attr_val;
             End IF;
         END IF;
END get_product_code;

FUNCTION get_product_value   (p_product_attr_context  varchar2,
                              p_product_attr  varchar2,
                              p_product_attr_val varchar2)
  RETURN VARCHAR2
  is
    item_id   varchar2(240) := null;
    c_name_id varchar2(240) := null;
  begin
   if p_product_attr_context = 'ITEM' THEN
        IF (p_product_attr = 'PRICING_ATTRIBUTE1')  THEN
            begin
                SELECT  inventory_item_id into item_id
                FROM MTL_SYSTEM_ITEMS_KFV KFV
                WHERE  concatenated_segments = p_product_attr_val
                AND rownum =1;
                RETURN item_id;
               EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
             end;
             ELSIF  (p_product_attr = 'PRICING_ATTRIBUTE2') THEN
              begin
               select category_id into c_name_id
               from qp_item_categories_v
               where category_name = p_product_attr_val
               and rownum = 1;
               return c_name_id;
               EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
              end;
             ELSE
               RETURN p_product_attr_val;
             End IF;
         END IF;
END get_product_value;


FUNCTION get_qualifier_code   (p_qualifier_attr_context  varchar2,
                            p_qualifier_attr  varchar2,
                            p_qualifier_attr_val varchar2)
  RETURN VARCHAR2
  is
    item_id   varchar2(240) := null;
  begin

    IF  p_qualifier_attr_context = 'MODLIST' THEN
        IF p_qualifier_attr = 'QUALIFIER_ATTRIBUTE4'  THEN
            begin
       	        SELECT name into item_id
		FROM QP_LIST_HEADERS_TL
		WHERE list_header_id=p_qualifier_attr_val and language='US';
		RETURN item_id;--Conversion to code in case of pricelist.
	   EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
	    End;
	ELSE
            begin
 		RETURN p_qualifier_attr_val;
                EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
             End;
	End If;
  ELSE
     RETURN p_qualifier_attr_val;--else return the value qp_qualifier_attr_val  unchanged
  END IF;
END get_qualifier_code;

FUNCTION get_qualifier_value  (p_qualifier_attr_context  varchar2,
                            p_qualifier_attr  varchar2,
                            p_qualifier_attr_val varchar2)
  RETURN VARCHAR2
  is
    item_id   varchar2(240) := null;
  begin


    IF  p_qualifier_attr_context = 'MODLIST' THEN
        IF p_qualifier_attr = 'QUALIFIER_ATTRIBUTE4'  THEN
            begin
                SELECT list_header_id into item_id
                FROM QP_LIST_HEADERS_TL
                WHERE name=p_qualifier_attr_val and rownum=1;
                RETURN item_id;--Conversion to value in case of pricelist.
           EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
            End;
        ELSE
            begin
                RETURN p_qualifier_attr_val;
                EXCEPTION WHEN OTHERS THEN
                RETURN NULL;
             End;
        End If;
  ELSE
     RETURN p_qualifier_attr_val;--else return the value qp_qualifier_attr_val  unchanged
  END IF;
END get_qualifier_value;


PROCEDURE Import_Modifiers
                         (P_debug                      IN VARCHAR2 := 'N',
                          P_output_dir                 IN VARCHAR2 := NULL,
                          P_debug_filename             IN VARCHAR2 := 'QP_Modifiers_debug.log',
                          P_modifier_list_XML          IN CLOB,
                          P_modifier_list_lines_XML    IN CLOB,
                          P_pricing_attributes_XML     IN CLOB,
                          P_Qualifiers_XML             IN CLOB,
                          X_return_status              OUT NOCOPY VARCHAR2,
                          X_msg_count                  OUT NOCOPY NUMBER,
                          X_G_MSG_DATA 		       OUT NOCOPY Long ) IS

  insCtx           DBMS_XMLSave.ctxType;
  rows             NUMBER;
  i                NUMBER;
  j                NUMBER;
  l                NUMBER :=1;
  m                NUMBER;

  mListHeaderId    NUMBER;
  mListLineId      NUMBER;

  x_msg_data 		Varchar2(2000);
  p_value 		Varchar2(2000);
  q_value               Varchar2(2000);
  x_msg_index 		number;

 l_MODIFIER_LIST_rec		QP_Modifiers_PUB.Modifier_List_Rec_Type;
 l_MODIFIER_LIST_val_rec	QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 l_MODIFIERS_tbl		QP_Modifiers_PUB.Modifiers_Tbl_Type;
 l_MODIFIERS_val_tbl		QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
 l_QUALIFIERS_tbl		QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL;
 l_QUALIFIERS_val_tbl		QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 l_PRICING_ATTR_tbl		QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 l_PRICING_ATTR_val_tbl		QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
 l_x_MODIFIER_LIST_rec		QP_Modifiers_PUB.Modifier_List_Rec_Type;
 l_x_MODIFIER_LIST_val_rec	QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 l_x_MODIFIERS_tbl		QP_Modifiers_PUB.Modifiers_Tbl_Type;
 l_x_MODIFIERS_val_tbl		QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
 l_x_QUALIFIERS_tbl		QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
 l_x_QUALIFIERS_val_tbl		QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 l_x_PRICING_ATTR_tbl		QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 l_x_PRICING_ATTR_val_tbl	QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

CURSOR qp_modifier_list_CUR  IS
 SELECT B.attribute1
,      B.attribute10
,      B.attribute11
,      B.attribute12
,      B.attribute13
,      B.attribute14
,      B.attribute15
,      B.attribute2
,      B.attribute3
,      B.attribute4
,      B.attribute5
,      B.attribute6
,      B.attribute7
,      B.attribute8
,      B.attribute9
,      B.automaticflag
,      B.comments
,      B.context
,      B.createdby
,  NULL    creationdate
,      B.currencycode
,      B.discountlinesflag
,      TO_DATE(B.enddateactive,'YYYY-MM-DD HH24:MI:SS')
,      B.freighttermscode
,      B.gsaindicator
,  NULL    lastupdatedby
,  NULL    lastupdatedate
,  NULL    lastupdatelogin
,      B.listheaderid
,      B.listtypecode
,  NULL    programapplicationid
,  NULL    programid
,  NULL    programupdatedate
,      B.prorateflag
,  NULL    requestid
,      TO_NUMBER(B.roundingfactor)
,      B.shipmethodcode
,      TO_DATE(B.startdateactive,'YYYY-MM-DD HH24:MI:SS')
,       RA.term_id
--,      B.TERMSID
,      B.sourcesystemcode
,      B.activeflag
,  FND_API.G_MISS_NUM parentlistheaderid
,      TO_DATE(B.startdateactivefirst,'YYYY-MM-DD HH24:MI:SS')
,      TO_DATE(B.enddateactivefirst,'YYYY-MM-DD HH24:MI:SS')
,      B.activedatefirsttype
,      TO_DATE(B.startdateactivesecond,'YYYY-MM-DD HH24:MI:SS')
,      B.globalflag
,      TO_DATE(B.enddateactivesecond,'YYYY-MM-DD HH24:MI:SS')
,      B.activedatesecondtype
,      B.askforflag
,      B.name
,      B.description
,      B.versionno
, NULL     returnstatus
, NULL     dbflag
, 'CREATE'     operation
,      B.ptecode
,      B.listsourcecode
,      B.origsystemheaderref
,      B.shareableflag
,     FND_API.G_MISS_NUM org_id  -- added org_id for moac
FROM QP_LIST_HEADER_TEMP  B ,
     RA_TERMS_TL           RA
WHERE  B.TERMSNAME = RA.NAME(+)
AND   B.LANGUAGE = RA.LANGUAGE(+)
AND B.VERSIONNO IS NULL
AND
NOT EXISTS  (SELECT 1
                   FROM   QP_LIST_HEADERS_TL TL3
                   WHERE  B.NAME = TL3.NAME
			AND TL3.VERSION_NO IS NULL);

CURSOR qp_modifier_list_line_CUR (mListHeaderId Number) IS
  select LL.arithmeticoperator
 ,   LL.attribute1
 ,   LL.attribute10
 ,   LL.attribute11
 ,   LL.attribute12
 ,   LL.attribute13
 ,   LL.attribute14
 ,   LL.attribute15
 ,   LL.attribute2
 ,   LL.attribute3
 ,   LL.attribute4
 ,   LL.attribute5
 ,   LL.attribute6
 ,   LL.attribute7
 ,   LL.attribute8
 ,   LL.attribute9
 ,   LL.automaticflag
 ,   LL.comments
 ,   LL.context
 ,   LL.createdby
 , null  creationdate
 ,   LL.effectiveperioduom
 ,   TO_DATE(LL.enddateactive,'YYYY-MM-DD HH24:MI:SS')
 ,   TO_NUMBER(LL.estimaccrualrate)
 --,   LL.generateusingformulaid
 ,   TL3.PRICE_FORMULA_ID
 --, FND_API.G_MISS_NUM inventoryitemid
 ,   KFV1.INVENTORY_ITEM_ID
 ,   LL.lastupdatedby
 , null  lastupdatedate
 ,   LL.lastupdatelogin
 , FND_API.G_MISS_NUM  listheaderid
 ,   LL.listlineid
 ,   LL.listlinetypecode
 ,   TO_NUMBER(LL.listprice)
 ,   LL.modifierlevelcode
 ,   TO_NUMBER(LL.numbereffectiveperiods)
 ,   TO_NUMBER(LL.operand)
 --,   LL.organizationid
 ,   MTL.ORGANIZATION_ID
 ,   LL.overrideflag
 ,   TO_NUMBER(LL.percentprice)
 ,   LL.pricebreaktypecode
 --,   LL.pricebyformulaid
 ,   TL2.PRICE_FORMULA_ID
 ,   LL.primaryuomflag
 ,   LL.printoninvoiceflag
 , NULL  programapplicationid
 , NULL  programid
 , null  programupdatedate
 ,   LL.rebatetransactiontypecode
-- , FND_API.G_MISS_NUM  relateditemid
 ,   KFV2.INVENTORY_ITEM_ID
 ,   relationshiptypeid
 ,   LL.repriceflag
 , NULL  requestid
 ,   LL.revision
 ,   TO_DATE(LL.revisiondate,'YYYY-MM-DD HH24:MI:SS')
 ,   LL.revisionreasoncode
 ,   TO_DATE(LL.startdateactive,'YYYY-MM-DD HH24:MI:SS')
 ,   LL.substitutionattribute
 ,   LL.substitutioncontext
 ,   LL.substitutionvalue
 ,   LL.accrualflag
 ,   TO_NUMBER(LL.pricinggroupsequence)
 ,   LL.incompatibilitygrpcode
 ,   LL.listlineno
 ,  FND_API.G_MISS_NUM RltdModifierId
 ,  FND_API.G_MISS_NUM FromRltdModifierId
 ,  FND_API.G_MISS_NUM ToRltdModifierId
 ,  FND_API.G_MISS_NUM RltdModifierGrpNo
 ,  FND_API.G_MISS_CHAR RltdModifierGrpType
 ,   LL.pricingphaseid
 ,   TO_NUMBER(LL.productprecedence)
 ,   TO_DATE(LL.expirationperiodstartdate,'YYYY-MM-DD HH24:MI:SS')
 ,   TO_NUMBER(LL.numberexpirationperiods)
 ,   LL.expirationperioduom
 ,   TO_DATE(LL.expirationdate,'YYYY-MM-DD HH24:MI:SS')
 ,   TO_NUMBER(LL.estimglvalue)
 , FND_API.G_MISS_NUM  benefitpricelistlineid
 ,   TO_NUMBER(LL.benefitlimit)
 ,   LL.chargetypecode
 ,   LL.chargesubtypecode
 ,   TO_NUMBER(LL.benefitqty)
 ,   LL.benefituomcode
 ,   TO_NUMBER(LL.accrualconversionrate)
 ,   LL.prorationtypecode
 ,   LL.includeonreturnsflag
 , null  returnstatus
 , null  dbflag
 , 'CREATE'  operation
 , FND_API.G_MISS_NUM  modifierparentindex
 ,   LL.qualificationind
 ,   LL.netamountflag
 ,   LL.accumattribute
 ,   LL.continuouspricebreakflag
 FROM QP_LIST_LINES_TEMP     LL,
      QP_PRICE_FORMULAS_TL TL2,
      (SELECT concatenated_segments, inventory_item_id
        FROM   MTL_SYSTEM_ITEMS_KFV KFV group by concatenated_segments, inventory_item_id) KFV1,
      MTL_PARAMETERS       MTL,
      QP_PRICE_FORMULAS_TL TL3,
      (SELECT concatenated_segments, inventory_item_id
       FROM   MTL_SYSTEM_ITEMS_KFV KFV group by concatenated_segments, inventory_item_id) KFV2
 WHERE  LL.LISTHEADERID         = mListHeaderId
 AND LL.PRICEBYFORMULA          = TL2.NAME(+)
 AND LL.LANGUAGE                = TL2.LANGUAGE(+)
 AND LL.ORGANIZATIONCODE        = MTL.ORGANIZATION_CODE(+)
 AND LL.INVENTORYITEMCODE       = KFV1.CONCATENATED_SEGMENTS(+)
 AND LL.relateditemcode         = KFV2.CONCATENATED_SEGMENTS(+)
 AND LL.GENERATEUSINGFORMULA    = TL3.NAME(+)
 AND LL.LANGUAGE                = TL3.LANGUAGE(+);


CURSOR qp_pricing_attributes_CUR (mListLineId Number) IS
 select  Q.accumulateflag
,    Q.attribute1
,    Q.attribute10
,    Q.attribute11
,    Q.attribute12
,    Q.attribute13
,    Q.attribute14
,    Q.attribute15
,    Q.attribute2
,    Q.attribute3
,    Q.attribute4
,    Q.attribute5
,    Q.attribute6
,    Q.attribute7
,    Q.attribute8
,    Q.attribute9
,    TO_NUMBER(Q.attributegroupingno)
,    Q.context
,    Q.createdby
,  null creationdate
,    Q.excluderflag
,    Q.lastupdatedby
,  null lastupdatedate
,    Q.lastupdatelogin
,  FND_API.G_MISS_NUM listlineid
,    Q.pricingattribute
,    Q.pricingattributecontext
,  FND_API.G_MISS_NUM pricingattributeid
,    Q.pricingattrvaluefrom
,    Q.pricingattrvalueto
,    Q.productattribute
,    Q.productattributecontext
,    Q.productattrvalue
,    Q.productuomcode
,  null programapplicationid
,  null programid
,  null programupdatedate
,    Q.productattributedatatype
,    Q.pricingattributedatatype
,    Q.comparisonoperatorcode
,  FND_API.G_MISS_NUM listheaderid
--,    Q.pricingphaseid
,    PP.PRICING_PHASE_ID
,  null requestid
,    TO_NUMBER(Q.pricingattrvaluefromnumber)
,    TO_NUMBER(Q.pricingattrvaluetonumber)
,    Q.qualificationind
,  null return_status
,  null db_flag
,  'CREATE' operation
,  1 modifiers_index
FROM
   QP_PRICING_ATTRIBUTES_TEMP Q,
    QP_PRICING_PHASES PP
WHERE  Q.PRICINGPHASENAME = PP.NAME(+)
   AND Q.LISTLINEID = mListLineId;


CURSOR qp_qualifiers_CUR (mListHeaderId Number) IS
 SELECT  Q.attribute1
,   Q.attribute10
,   Q.attribute11
,   Q.attribute12
,   Q.attribute13
,   Q.attribute14
,   Q.attribute15
,   Q.attribute2
,   Q.attribute3
,   Q.attribute4
,   Q.attribute5
,   Q.attribute6
,   Q.attribute7
,   Q.attribute8
,   Q.attribute9
,   Q.comparisonoperatorcode
,   Q.context
,   Q.createdby
--,   createdfromruleid
,   QR1.QUALIFIER_RULE_ID
, null  creationdate
--,   TO_DATE(Q.enddateactive,'YYYY-MM-DD HH24:MI:SS')   bug no 5298343
,   Q.enddateactive
,   Q.excluderflag
,   Q.lastupdatedby
, null lastupdatedate
,   Q.lastupdatelogin
,  FND_API.G_MISS_NUM listheaderid
,   Q.listlineid
,   Q.programapplicationid
,   Q.programid
, null  programupdatedate
,   Q.qualifierattribute
,   Q.qualifierattrvalue
,   Q.qualifierattrvalueto
,   Q.qualifiercontext
,   Q.qualifierdatatype
,   TO_NUMBER(Q.qualifiergroupingno)
, FND_API.G_MISS_NUM  qualifierid
,   TO_NUMBER(Q.qualifierprecedence)
--,   qualifierruleid
,  QR2.QUALIFIER_RULE_ID
, NULL  requestid
--,   TO_DATE(Q.startdateactive,'YYYY-MM-DD HH24:MI:SS')     bug no 5298343
,   Q.startdateactive
,   Q.listtypecode
,   TO_NUMBER(Q.qualattrvaluefromnumber)
,   TO_NUMBER(Q.qualattrvaluetonumber)
,   Q.activeflag
,   TO_NUMBER(Q.searchind)
,   TO_NUMBER(Q.qualifiergroupcnt)
,   Q.headerqualsexistflag
,   TO_NUMBER(Q.distinctrowcount)
, null return_status
, NULL db_flag
, 'CREATE' operation
, FND_API.G_MISS_CHAR qualify_hier_descendents_flag
FROM
    QP_QUALIFIERS_TEMP Q,
    QP_QUALIFIER_RULES QR1,
    QP_QUALIFIER_RULES QR2

WHERE  Q.CREATEDFROMRULENAME = QR1.NAME(+)
 AND   Q.QUALIFIERFROMRULENAME = QR2.NAME(+)
 AND   Q.LISTHEADERID = mListHeaderId;



BEGIN
  IF (P_modifier_list_XML IS NOT NULL) THEN
   -- Modifier Header Record
   -- get the context handle

   insCtx := Dbms_Xmlsave.newContext('QP_LIST_HEADER_TEMP');
   Dbms_Xmlsave.setIgnoreCase(insCtx, 1);
   Dbms_Xmlsave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
   Dbms_Xmlsave.setRowTag(insCtx , 'ModifiersListHeadersVO');
   -- this inserts the document
   rows   := Dbms_Xmlsave.insertXML(insCtx, P_modifier_list_XML);
   -- this closes the handle
   Dbms_Xmlsave.closeContext(insCtx);

  END IF;



  IF (P_modifier_list_lines_XML IS NOT NULL) THEN
   -- Modifier List Line Record
   -- get the context handle
   insCtx := Dbms_Xmlsave.newContext('QP_LIST_LINES_TEMP');
   Dbms_Xmlsave.setIgnoreCase(insCtx, 1);
   Dbms_Xmlsave.setDateFormat(insCtx, 'YYYY-MM-dd HH:mm:ss');
   Dbms_Xmlsave.setRowTag(insCtx , 'ModifiersListLinesVO');
   -- this inserts the document
   rows   := Dbms_Xmlsave.insertXML(insCtx, P_modifier_list_lines_XML);
   -- this closes the handle
   Dbms_Xmlsave.closeContext(insCtx);
  END IF;


  IF (P_pricing_attributes_XML IS NOT NULL) THEN
   -- PricingAttributes Record
   -- get the context handle
   insCtx := Dbms_Xmlsave.newContext('QP_PRICING_ATTRIBUTES_TEMP');
   Dbms_Xmlsave.setIgnoreCase(insCtx, 1);
   Dbms_Xmlsave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
   Dbms_Xmlsave.setRowTag(insCtx , 'ModifiersPricingAttributesVO');
   -- this inserts the document
   rows   := Dbms_Xmlsave.insertXML(insCtx, P_pricing_attributes_XML);
   -- this closes the handle
   Dbms_Xmlsave.closeContext(insCtx);
  END IF;


  IF (P_Qualifiers_XML IS NOT NULL) THEN
   -- Qualifiers Record
   -- get the context handle
   insCtx := Dbms_Xmlsave.newContext('QP_QUALIFIERS_TEMP');
   Dbms_Xmlsave.setIgnoreCase(insCtx, 1);
   Dbms_Xmlsave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
   Dbms_Xmlsave.setRowTag(insCtx , 'ModifiersQualifiersVO');
   -- this inserts the document
   rows   := Dbms_Xmlsave.insertXML(insCtx, P_Qualifiers_XML);
   -- this closes the handle
   Dbms_Xmlsave.closeContext(insCtx);
  END IF;



  i := 1;
  OPEN qp_modifier_list_CUR;
  LOOP

    l_MODIFIER_LIST_rec := null;

    FETCH qp_modifier_list_CUR INTO  l_MODIFIER_LIST_rec;
    IF (qp_modifier_list_CUR%NOTFOUND) THEN
      EXIT;
    END IF;
    mListHeaderId :=  l_MODIFIER_LIST_rec.list_header_id;

	  j := 1;
	  OPEN qp_modifier_list_line_CUR(mListHeaderId);
	  LOOP
	    FETCH qp_modifier_list_line_CUR INTO  l_MODIFIERS_tbl(j);

	    IF (qp_modifier_list_line_CUR%NOTFOUND) THEN
	      EXIT;
	    END IF;

            mListLineId :=  l_MODIFIERS_tbl(j).list_line_id;

	--   l := 1;
		  OPEN qp_pricing_attributes_CUR(mListLineId);
		  LOOP
		    FETCH qp_pricing_attributes_CUR INTO  l_PRICING_ATTR_tbl(l);

		    IF (qp_pricing_attributes_CUR%NOTFOUND) THEN
		      EXIT;
		    END IF;
         p_value  := QP_MODIFIERS_ISETUP_IMP.get_product_value(l_PRICING_ATTR_tbl(l).product_attribute_context,l_PRICING_ATTR_tbl(l).product_attribute,l_PRICING_ATTR_tbl(l).product_attr_value);
                        l_PRICING_ATTR_tbl(l).product_attr_value := p_value;
		    l_PRICING_ATTR_tbl(l).modifiers_index := j;

		    l := l + 1;
		  END LOOP;
		  CLOSE qp_pricing_attributes_CUR;

		l_MODIFIERS_tbl(j).list_line_id := FND_API.G_MISS_NUM;

	    j := j + 1;
	  END LOOP;
	  CLOSE qp_modifier_list_line_CUR;

	  m := 1;
	  OPEN qp_qualifiers_CUR(mListHeaderId);
	  LOOP
	    FETCH qp_qualifiers_CUR INTO  l_QUALIFIERS_tbl(m);

	    IF (qp_qualifiers_CUR%NOTFOUND) THEN
	      EXIT;
	    END IF;

	q_value := QP_MODIFIERS_ISETUP_IMP.get_qualifier_value(l_QUALIFIERS_tbl(m).qualifier_context,l_QUALIFIERS_tbl(m).qualifier_attribute,l_QUALIFIERS_tbl(m).qualifier_attr_value);
                        l_QUALIFIERS_tbl(m).qualifier_attr_value := q_value;

	  m := m + 1;
	  END LOOP;
	  CLOSE qp_qualifiers_CUR;



     l_MODIFIER_LIST_rec.list_header_id := FND_API.G_MISS_NUM;

     i := i + 1;

     BEGIN

	     l_x_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
	     l_x_MODIFIERS_tbl     := l_MODIFIERS_tbl;
	     l_x_QUALIFIERS_tbl    := l_QUALIFIERS_tbl;
	     l_x_PRICING_ATTR_tbl  := l_PRICING_ATTR_tbl;

	     QP_Modifiers_PUB.Process_Modifiers(
        	 p_api_version_number=> 1.0
	 	, p_init_msg_list=> FND_API.G_FALSE
		, p_return_values=> FND_API.G_FALSE
		, p_commit=> FND_API.G_FALSE
		, x_return_status=> x_return_status
		, x_msg_count=>x_msg_count
		, x_msg_data=>x_msg_data
		,p_MODIFIER_LIST_rec=> l_MODIFIER_LIST_rec
		,p_MODIFIERS_tbl=> l_MODIFIERS_tbl
		,p_QUALIFIERS_tbl=> l_QUALIFIERS_tbl
		,p_PRICING_ATTR_tbl=> l_PRICING_ATTR_tbl
		,x_MODIFIER_LIST_rec=> l_x_MODIFIER_LIST_rec
		,x_MODIFIER_LIST_val_rec=> l_x_MODIFIER_LIST_val_rec
		,x_MODIFIERS_tbl=> l_x_MODIFIERS_tbl
		,x_MODIFIERS_val_tbl=> l_x_MODIFIERS_val_tbl
		,x_QUALIFIERS_tbl=> l_x_QUALIFIERS_tbl
		,x_QUALIFIERS_val_tbl=> l_x_QUALIFIERS_val_tbl
		,x_PRICING_ATTR_tbl=> l_x_PRICING_ATTR_tbl
		,x_PRICING_ATTR_val_tbl=> l_x_PRICING_ATTR_val_tbl
		);


	FOR t in 1..x_msg_count LOOP
		x_msg_data := oe_msg_pub.get( p_msg_index => t,	p_encoded => 'F');
		X_G_MSG_DATA := X_G_MSG_DATA || FND_GLOBAL.NewLine || FND_GLOBAL.NewLine ||  x_msg_data || ' :: ListHeaderId in the Input XML file is : ' || to_char(mListHeaderId);
        END LOOP;

     EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		X_return_status := FND_API.G_RET_STS_ERROR;
		--Get message count and data
		--dbms_output.put_line('err msg 1 is : ' || x_msg_data);
		X_G_MSG_DATA := X_G_MSG_DATA || FND_GLOBAL.NewLine || FND_GLOBAL.NewLine ||  x_msg_data || ' :: ListHeaderId in the Input XML file is : ' || mListHeaderId;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--dbms_output.put_line(' msg count 2 is : ' || x_msg_count);
		for k in 1 .. x_msg_count loop
			x_msg_data := oe_msg_pub.get( p_msg_index => k,
			p_encoded => 'F'
			);
		  --Get message count and data
     	          --dbms_output.put_line('err msg ' || k ||'is: ' || x_msg_data);
 		  X_G_MSG_DATA := X_G_MSG_DATA || FND_GLOBAL.NewLine || FND_GLOBAL.NewLine ||  x_msg_data || ' :: ListHeaderId in the Input XML file is : ' || mListHeaderId;
		end loop;


	WHEN OTHERS THEN

		X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		--dbms_output.put_line(' msg count 2 is : ' || x_msg_count);
		for k in 1 .. x_msg_count loop
			x_msg_data := oe_msg_pub.get( p_msg_index => k,
			p_encoded => 'F'
			);
		  --Get message count and data
		  --dbms_output.put_line('err msg ' || k ||'is: ' || x_msg_data);
 		  X_G_MSG_DATA := X_G_MSG_DATA || FND_GLOBAL.NewLine || FND_GLOBAL.NewLine ||  x_msg_data || ' :: ListHeaderId in the Input XML file is : ' || mListHeaderId;
		end loop;

    END;


  END LOOP;

  CLOSE qp_modifier_list_CUR;

END Import_Modifiers;

END QP_MODIFIERS_ISETUP_IMP;

/
