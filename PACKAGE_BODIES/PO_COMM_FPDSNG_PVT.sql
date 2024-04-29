--------------------------------------------------------
--  DDL for Package Body PO_COMM_FPDSNG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMM_FPDSNG_PVT" AS
/* $Header: POXFPDSNGB.pls 120.4 2008/03/06 07:26:30 lgoyal noship $ */

--Use proper debug logging
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_log_head CONSTANT VARCHAR2(100) := 'po.plsql.PO_COMM_FPDSNG_PVT.';

g_document_id   NUMBER;
g_revision_num	NUMBER;
g_release_id	NUMBER;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION getDocumentId RETURN NUMBER IS
BEGIN
	RETURN g_document_id;
END ;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION getReleaseId RETURN NUMBER IS
BEGIN
	RETURN  g_release_id ;
END ;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION getRevisionNum RETURN NUMBER IS
BEGIN
	RETURN g_revision_num;
END ;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION START_PROCESS( p_document_id NUMBER, p_release_num NUMBER, p_revision_num NUMBER) RETURN CLOB IS

--	x_return_status VARCHAR2(200);
	clob_result		CLOB;
	l_api_name		CONSTANT VARCHAR2(25):= 'START_PROCESS';
	l_progress		VARCHAR2(3);

BEGIN

	l_progress := '001';
	IF g_debug_stmt THEN
		PO_DEBUG.debug_begin(p_log_head => g_log_head || l_api_name);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id', p_document_id);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_release_num', p_release_num);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_revision_num', p_revision_num);
	END IF;

	l_progress := '002';
	-- Calling FPDSNGXMLGEN
	clob_result := FPDSNGXMLGEN(p_document_id, p_release_num, p_revision_num);

	l_progress := '003';
	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'clob_result', DBMS_LOB.GETLENGTH(clob_result) );
	END IF;

	RETURN clob_result;
	EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
		RAISE;

END start_process;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
PROCEDURE SUBMIT_REQUEST(itemtype IN VARCHAR2,
						 itemkey  IN VARCHAR2,
						 actid    IN NUMBER,
						 funcmode IN VARCHAR2,
						 resultout OUT NOCOPY VARCHAR2)
IS

	l_document_id	NUMBER;
	l_release_num	NUMBER;
	l_revision_num	NUMBER;
	l_document_type	VARCHAR2(20);
	l_document_subtype	VARCHAR2(20);
	l_fpdsng_flag	VARCHAR2(1);

	l_request_id	NUMBER;
	x_progress		VARCHAR2(100);

	g_po_wf_debug	VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

	l_api_name		CONSTANT VARCHAR2(25):= 'SUBMIT_REQUEST';
	l_progress		VARCHAR2(3);

BEGIN

	l_progress := '000';
	x_progress := 'PO_COMM_FPDSNG_PVT.SUBMIT_REQUEST';
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,x_progress);
	END IF;

	IF (funcmode <> wf_engine.eng_run) THEN
		resultout := wf_engine.eng_null;
		return;
	END IF;

	l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_TYPE');
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,'L_DOCUMENT_TYPE ::' || l_document_type);
	END IF;

	l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_SUBTYPE');
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,'L_DOCUMENT_SUBTYPE::' || l_document_subtype);
	END IF;


	l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_ID');
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,'L_DOCUMENT_ID::' || l_document_id);
	END IF;

	l_revision_num := PO_WF_UTIL_PKG.GetItemAttrNumber (	itemtype => itemtype,
														itemkey => itemkey,
														aname	=> 'REVISION_NUMBER');
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,'L_REVISION_NUM::' || l_revision_num);
	END IF;

	l_fpdsng_flag := PO_WF_UTIL_PKG.GetItemAttrText (	itemtype => itemtype,
														itemkey => itemkey,
														aname	=> 'FPDSNG_FLAG');
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,'L_FPDSNG_FLAG::' || l_fpdsng_flag);
	END IF;

	x_progress := 'In PO_COMM_FPDSNG_PVT.SUBMIT_REQUEST.';
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,x_progress);
	END IF;


	--<R12 MOAC START>
	po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
	--<R12 MOAC END>

	-- Checking if FPDSNG Checkbox is set from Forms front
	IF l_fpdsng_flag = 'Y' THEN

		IF l_document_type='RELEASE' AND l_document_subtype = 'BLANKET' THEN

			SELECT pr.po_header_id, pr.release_num INTO l_document_id, l_release_num
			FROM po_releases_all pr
			WHERE pr.po_release_id = l_document_id;

			IF g_debug_stmt THEN
				PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_document_id', l_document_id );
				PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_release_num', l_release_num );
			END IF;

		END IF;

		x_progress := 'PO_COMM_FPDSNG_PVT.SUBMIT_REQUEST :launching the java concurrent program ';
		IF (g_po_wf_debug = 'Y') THEN
			PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,x_progress);
		END IF;

		l_request_id := fnd_request.submit_request('PO',
				 'POFPDSNG',
				 null,
				 null,
				 false,

				 l_document_id,		-- PO_HEADER_ID
				 l_release_num,		-- RELEASE_NUM
				 l_revision_num,	-- REVISION_NUM

				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL,NULL, fnd_global.local_chr(0),
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				 NULL, NULL);

		x_progress := 'PO_COMM_FPDSNG_PVT.SUBMIT_REQUEST : Request id is  '|| l_request_id;
		IF (g_po_wf_debug = 'Y') THEN
			PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,x_progress);
		END IF;

	END IF;

EXCEPTION

  WHEN OTHERS THEN
  x_progress :=  'PO_COMM_FPDSNG_PVT.SUBMIT_REQUEST : In Exception handler';
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;
  wf_core.context('PO_COMM_FPDSNG_PVT','SUBMIT_REQUEST',x_progress);
  RAISE;

END submit_request;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION FPDSNGXMLGEN(p_document_id NUMBER, p_release_num NUMBER, p_revision_num NUMBER) RETURN clob IS

	l_xml_query			VARCHAR2(2000);
	l_api_name CONSTANT VARCHAR2(25):= 'FPDSNGXMLGEN';

	l_org_id			VARCHAR2(10);
	blob_result			BLOB;
	l_file_name			VARCHAR2(200);
	l_media_id			VARCHAR2(200);
	l_language			VARCHAR2(10);
	l_doc_type			VARCHAR2(25);
	context				DBMS_XMLGEN.ctxHandle;

	l_idvidQuery		VARCHAR2(1000);
	l_refidvidQuery		VARCHAR2(1000);

	l_ContractDatesQuery VARCHAR2(1000);
	l_dollarValueQuery	VARCHAR2(1000);

	l_contractMarketingQuery VARCHAR2(1000);
	l_contractDataQuery VARCHAR2(4000);
	l_ProductInfoQuery	VARCHAR2(3000);
	l_vendorHeaderQuery VARCHAR2(1000);
	l_vendorLocQuery	VARCHAR2(3000);

	l_xml_query			varchar2(32000);

	l_referencedidvid   CLOB;
	l_ContractDates		CLOB;
	l_contractMarketingData CLOB;
	l_dollarValues		CLOB;
	l_vendorHeader		CLOB;
	l_vendorLocation	CLOB;
	l_contractData		CLOB;
	l_productInfo		CLOB;
	l_xml_result		CLOB;
	l_tempXMLResult		CLOB;

	l_resultOffset		NUMBER; -- to store the offset
	l_variablePosition	NUMBER :=0;
	l_progress			VARCHAR2(30) := NULL;

BEGIN

	l_progress:='000';
	IF g_debug_stmt THEN
		PO_DEBUG.debug_begin(p_log_head => g_log_head || l_api_name);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id', p_document_id );
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_release_num', p_release_num );
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_revision_num', p_revision_num );
	END IF;

	PO_COMM_FPDSNG_PVT.g_document_id := p_document_id;

	l_progress:='001';
	SELECT TYPE_LOOKUP_CODE  into l_doc_type
	FROM  po_headers_all ph
	WHERE po_header_id = p_document_id ;

	IF p_revision_num < 0 THEN
		l_progress:='002';

		SELECT revision_num INTO PO_COMM_FPDSNG_PVT.g_revision_num
		FROM po_headers_all WHERE po_header_id = PO_COMM_FPDSNG_PVT.g_document_id;

	ELSE
		l_progress:='003';
		PO_COMM_FPDSNG_PVT.g_revision_num := p_revision_num;
	END IF;

	l_progress:='004';
	PO_COMM_FPDSNG_PVT.g_release_id  := null;

	IF l_doc_type <> 'STANDARD' THEN

		/* If Release Num is not Specified for a Blanket Purchase Agreement */
		IF p_release_num < 0 THEN
			-- Throw Exception
			raise_application_error (-20001,'Release Number Cannot be NULL for a Blanket Release.');
		END IF;

		BEGIN
			l_progress:='005';
			SELECT	po_release_id INTO PO_COMM_FPDSNG_PVT.g_release_id
			FROM	po_releases_all
			WHERE	po_header_id=p_document_id AND
					release_num=  p_release_num;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				/* If Release Num is INVALID for Blanket Purchase Agreement */
				raise_application_error (-20001,'Invalid Release Number.');
		END;

	ELSE
		PO_COMM_FPDSNG_PVT.g_release_id := NULL;
	END IF;

	l_progress:='006';
	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id::', PO_COMM_FPDSNG_PVT.getDocumentId() );
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_release_num', PO_COMM_FPDSNG_PVT.g_revision_num );
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_revision_num', PO_COMM_FPDSNG_PVT.getReleaseId() );
	END IF;

	l_progress:='007';
	l_idvidQuery:=' SELECT decode(PO_COMM_FPDSNG_PVT.getReleaseId(), null,
					PO_COMM_FPDSNG_PVT.getDocumentId(),PO_COMM_FPDSNG_PVT.getReleaseId()) PIID,
					PO_COMM_FPDSNG_PVT.getRevisionNum modNumber
					FROM dual';

	l_progress:='008';
	l_refidvidQuery := 'SELECT PO_COMM_FPDSNG_PVT.getDocumentId() PIID,
						PO_COMM_FPDSNG_PVT.getRevisionNum modNumber
						from dual';

	IF (PO_COMM_FPDSNG_PVT.getReleaseId()) IS NOT null THEN
		l_progress:='009';
		l_ContractDatesQuery :=' SELECT poh.start_date effectiveDate,
							poh.end_date lastDateToOrder
							FROM po_headers_all poh
							WHERE
							poh.po_header_id= PO_COMM_FPDSNG_PVT.getDocumentId()';
	END IF;

	--releases

	IF (PO_COMM_FPDSNG_PVT.getReleaseId()) IS NOT null THEN

		l_progress:='010';
		l_dollarValueQuery:='SELECT sum(NVL(encumbered_amount,0)) obligatedAmount,
                            po_core_s.get_total(''R'', PO_COMM_FPDSNG_PVT.getReleaseId()) baseAndExcercisedOptionsValue
							from po_distributions_all pod,
							po_releases_all por where por.po_release_id=pod.po_release_id
							and por.po_release_id =PO_COMM_FPDSNG_PVT.getReleaseId()';

	ELSE
		l_progress:='011';
		l_dollarValueQuery := '	SELECT sum(NVL(encumbered_amount,0)) obligatedAmount,
								po_core_s.get_total(''H'', PO_COMM_FPDSNG_PVT.getDocumentId()) baseAndExcercisedOptionsValue
								from po_distributions_all pod,
								po_headers_all poh where poh.po_header_id=pod.po_header_id
								and poh.po_header_id =PO_COMM_FPDSNG_PVT.getDocumentId()';

	END IF;

	l_progress:='012';
	l_contractMarketingQuery := 'SELECT pov.email_address emailAddress
							FROM po_vendor_sites_all pov, po_headers_all poh
							WHERE pov.vendor_site_id= poh.vendor_site_id
							AND poh.po_header_id=PO_COMM_FPDSNG_PVT.getDocumentId()';

	l_progress:='013';
	l_contractDataQuery := 'SELECT
							decode(PO_COMM_FPDSNG_PVT.getReleaseId(),null,PO_COMM_FPDSNG_PVT.getDocumentId(),
							PO_COMM_FPDSNG_PVT.getReleaseId()) solicitationID,
							poh.comments descOfContractRequirement,
							decode(PO_COMM_FPDSNG_PVT.getReleaseId(),NULL,
							Decode(
								Greatest((sysdate - poh.creation_date), 366),
								366,''false'',''true''),
								Decode(
									Greatest((poh.end_date - poh.start_date), 366),
									366,''false'',''true'')
							)  multiYearContract,
							decode(PO_COMM_FPDSNG_PVT.getReleaseId(),NULL,poh.pcard_id,por.pcard_id) purchaseCardAsPaymentMethod
							FROM po_headers_all poh, po_releases_all por
							WHERE poh.po_header_id = por.po_header_id (+)
							AND poh.po_header_id = PO_COMM_FPDSNG_PVT.getDocumentId()
							AND por.po_release_id (+)= PO_COMM_FPDSNG_PVT.getReleaseId()' ;

	IF (PO_COMM_FPDSNG_PVT.getReleaseId()) is not null then
	--for releases
	/*	Bug 6864044. Added Outer join condition so that query return
		the Category Detail even if duns_number does not match. */
		l_progress:='014';
		l_ProductInfoQuery := 'SELECT  mck.concatenated_segments productOrServiceCode,
						fcv.naics_code1 principalNAICSCode
						FROM fv_ccr_vendors  fcv, mtl_categories_kfv mck,
						po_vendor_sites_all pvs, po_headers_all poh,
						po_lines_all pol, po_releases_all por
						WHERE
						poh.vendor_site_id = pvs.vendor_site_id
						and pvs.duns_number =  fcv.duns (+)
						and mck.category_id = pol.category_id
						and poh.po_header_id = pol.po_header_id
						and por.po_release_id = PO_COMM_FPDSNG_PVT.getReleaseId()
						and  poh.po_header_id= PO_COMM_FPDSNG_PVT.getDocumentId()';

	ELSE
	--for standard PO
	/*	Bug 6864044. Added Outer join condition so that query return
		the Category Detail even if duns_number does not match. */
		l_progress:='015';
		l_ProductInfoQuery := 'SELECT  mck.concatenated_segments productOrServiceCode,
                      fcv.naics_code1 principalNAICSCode
                      FROM fv_ccr_vendors  fcv, mtl_categories_kfv mck,
                      po_vendor_sites_all pvs, po_headers_all poh, po_lines_all pol
                      WHERE poh.vendor_site_id = pvs.vendor_site_id
                      and pvs.duns_number =  fcv.duns (+)
                      and mck.category_id = pol.category_id
                      and poh.po_header_id = pol.po_header_id
                      and  poh.po_header_id= PO_COMM_FPDSNG_PVT.getDocumentId()';

	END IF;

	l_progress:='016';
	l_vendorHeaderQuery :=  'SELECT vendor_name vendorName
						FROM po_vendors pov, po_headers_all poh
						WHERE pov.vendor_id= poh.vendor_id
						AND poh.po_header_id=  PO_COMM_FPDSNG_PVT.getDocumentId()';

	l_progress:='017';
	l_vendorLocQuery := 'SELECT  vendor_site_code VendorSiteCode ,
						address_line1 streetAddress, address_line2 streetAddress2,
						address_line3 streetAddress3, city, state, zip ZIPCode,
						country countryCode, duns_number DUNSNumber,
						(area_code) || phone phoneNo, (fax_area_code) || pov.fax faxNo
						FROM po_vendor_sites_all pov, po_headers_all poh
						WHERE pov.vendor_site_id = poh.vendor_site_id
						AND poh.po_header_id=PO_COMM_FPDSNG_PVT.getDocumentId()';


	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'XML Queries Created after', l_progress);
	END IF;

	/*IDVID */
	l_progress:='018';
	context := dbms_xmlgen.newContext(l_idvidQuery);
	dbms_xmlgen.setRowsetTag(context,'IDVID');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_xml_result := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*REFERENCE IDVID */
	l_progress:='019';
	 context := dbms_xmlgen.newContext(l_refidvidQuery);
	dbms_xmlgen.setRowsetTag(context,'referencedIDVID');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_referencedidvid := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);


	IF (PO_COMM_FPDSNG_PVT.getReleaseId()) IS NOT null THEN
		/*relevantContractDates */
		l_progress:='020';
		context := dbms_xmlgen.newContext(l_ContractDatesQuery);
		dbms_xmlgen.setRowsetTag(context,'relevantContractDates');
		dbms_xmlgen.setRowTag(context,NULL);
		dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
		l_ContractDates := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
		dbms_xmlgen.closeContext(context);
	END IF;

	/*Dollarvalues */
	l_progress:='021';
	context := dbms_xmlgen.newContext(l_dollarValueQuery);
	dbms_xmlgen.setRowsetTag(context,'dollarValues');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_dollarValues := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*contract Marketing Data */
	l_progress:='022';
	context := dbms_xmlgen.newContext(l_contractMarketingQuery);
	dbms_xmlgen.setRowsetTag(context,'contractMarketingData');
	dbms_xmlgen.setRowTag(context,NULL);
	l_contractMarketingData := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*contract Data */
	l_progress:='023';
	context := dbms_xmlgen.newContext(l_contractDataQuery);
	dbms_xmlgen.setRowsetTag(context,'contractData');
	dbms_xmlgen.setRowTag(context,NULL);
	l_contractData := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*ProductOrserrvice */
	l_progress:='024';
	context := dbms_xmlgen.newContext(l_ProductInfoQuery);
	dbms_xmlgen.setRowsetTag(context,'productOrServiceInfromation');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_productInfo := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*Vendor Header*/
	l_progress:='025';
	context := dbms_xmlgen.newContext(l_vendorHeaderQuery);
	dbms_xmlgen.setRowsetTag(context,'vendorHeader');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_vendorHeader    := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	/*VendorLocation */
	l_progress:='026';
	context :=	dbms_xmlgen.newContext(l_vendorLocQuery);
	dbms_xmlgen.setRowsetTag(context,'vendorLocation');
	dbms_xmlgen.setRowTag(context,NULL);
	dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
	l_vendorLocation    := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
	dbms_xmlgen.closeContext(context);

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'XML Data Generated after', l_progress);
	END IF;

	-- Length of IDVD
	l_progress:='027';
	IF dbms_lob.getlength(l_xml_result) >0 THEN

		l_progress:='028';
		l_resultOffset := DBMS_LOB.INSTR(l_xml_result,'>');

		l_progress:='029';
		l_tempXMLResult := l_xml_result;

		l_progress:='030';
		dbms_lob.write(l_xml_result,length('<?xml version="1.0" encoding="UTF-8"?> <IDV version="1.2.1"> <contractID>'),1,'<?xml version="1.0" encoding="UTF-8"?> <IDV version="1.2.1"> <contractID>');
		dbms_lob.copy(l_xml_result,l_tempXMLResult,dbms_lob.getlength(l_tempXMLResult)-l_resultOffset,length('<?xml version="1.0" encoding="UTF-8"?> <IDV version="1.2.1"> <contractID>'),l_resultOffset);

		IF dbms_lob.getlength(l_referencedidvid) > 0 THEN
			l_progress:='031';
            l_variablePosition := DBMS_LOB.INSTR(l_referencedidvid,'>');
			dbms_lob.copy(l_xml_result, l_referencedidvid, dbms_lob.getlength(l_referencedidvid)- l_variablePosition, dbms_lob.getlength(l_xml_result)+1, l_variablePosition+1);
		END IF;
		l_progress:='032';
		dbms_lob.write(l_xml_result,length('</contractID>'),dbms_lob.getlength(l_xml_result) + 1,'</contractID>');


		IF (PO_COMM_FPDSNG_PVT.getReleaseId()) IS NOT null THEN
			l_progress:='033';
			IF dbms_lob.getlength(l_ContractDates) >0 THEN
				l_variablePosition := DBMS_LOB.INSTR(l_ContractDates,'>');
				dbms_lob.copy(l_xml_result, l_ContractDates, dbms_lob.getlength(l_ContractDates)- l_variablePosition, dbms_lob.getlength(l_xml_result) +1, l_variablePosition+1);
			END IF;
		END IF;

		IF dbms_lob.getlength(l_dollarValues) >0 THEN
			l_progress:='034';
			l_variablePosition := DBMS_LOB.INSTR(l_dollarValues,'>');
			dbms_lob.copy(l_xml_result, l_dollarValues, dbms_lob.getlength(l_dollarValues)- l_variablePosition, dbms_lob.getlength(l_xml_result)+1, l_variablePosition+1);
		END IF;


		IF dbms_lob.getlength(l_contractMarketingData) >0 THEN
			l_progress:='035';
			l_variablePosition := DBMS_LOB.INSTR(l_contractMarketingData,'>');
			dbms_lob.copy(l_xml_result, l_contractMarketingData, dbms_lob.getlength(l_contractMarketingData)- l_variablePosition, dbms_lob.getlength(l_xml_result), l_variablePosition+1);
		END IF;


		IF dbms_lob.getlength(l_contractData) >0 THEN
			l_progress:='036';
			l_variablePosition := DBMS_LOB.INSTR(l_contractData,'>');
			dbms_lob.copy(l_xml_result, l_contractData, dbms_lob.getlength(l_contractData)- l_variablePosition, dbms_lob.getlength(l_xml_result), l_variablePosition+1);
		END IF;

		IF dbms_lob.getlength(l_productInfo) >0 THEN
			l_progress:='037';
			l_variablePosition := DBMS_LOB.INSTR(l_productInfo,'>');
			dbms_lob.copy(l_xml_result, l_productInfo, dbms_lob.getlength(l_productInfo)- l_variablePosition, dbms_lob.getlength(l_xml_result), l_variablePosition+1);
		END IF;

		IF dbms_lob.getlength(l_vendorHeader) >0 THEN
			l_progress:='038';
			l_variablePosition := DBMS_LOB.INSTR(l_vendorHeader,'>');
			dbms_lob.copy(l_xml_result, l_vendorHeader, dbms_lob.getlength(l_vendorHeader)- l_variablePosition, dbms_lob.getlength(l_xml_result), l_variablePosition+1);
		END IF;

		IF dbms_lob.getlength(l_vendorLocation) >0 THEN
			l_progress:='039';
			l_variablePosition := DBMS_LOB.INSTR(l_vendorLocation,'>');
			dbms_lob.copy(l_xml_result, l_vendorLocation, dbms_lob.getlength(l_vendorLocation)- l_variablePosition, dbms_lob.getlength(l_xml_result), l_variablePosition+1);
		END IF;

		l_progress:='040';
		dbms_lob.write(l_xml_result,length('</IDV>'),dbms_lob.getlength(l_xml_result) + 1,'</IDV>');

	END IF;  -- Length of IDVD which is going to be for sure

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'XML CLOB Created after', l_progress);
	END IF;


	l_xml_result := Replace_Clob_String(l_xml_result,'DESCOFCONTRACTREQUIREMENT','DESCRIPTIONOFCONTRACTREQUIREMENT');

	l_progress:='041';
	--Get the ORG ID
	l_org_id := po_moac_utils_pvt.get_current_org_id;

	IF l_org_id is null THEN
		l_progress:='042';
		SELECT ph.org_id into l_org_id
		FROM  po_headers_all ph
		WHERE po_header_id = p_document_id;
	END IF;

	--Get the Language
	l_progress:='043';
	SELECT userenv('LANG') INTO l_language FROM dual;

	--Get the PDF Name
	l_progress:='044';
	l_file_name := getFPDSNGFileName(l_doc_type, --p_document_type
									l_org_id, --Org Id
									p_document_id, --Header_id
									PO_COMM_FPDSNG_PVT.g_revision_num, --Revision Num
									p_release_num, --Release Num
									l_language); --Language Code

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_file_name', l_file_name);
	END IF;

	-- Converting CLOB data to BLOB to store in DB
	l_progress:='045';
	blob_result := clob_to_blob( l_xml_result );

	--Store it as BLOB attachment in DB
	l_progress:='046';
	Store_Blob(	p_document_id,
				PO_COMM_FPDSNG_PVT.g_revision_num,
				l_doc_type, --p_document_type
				l_file_name,
				blob_result, --blob
				l_media_id);

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'CLOB DataStored. After', l_progress);
	END IF;

	--Getting back the CLOB from BLOB
	l_progress:='047';
	--l_xml_result := blob_to_clob(blob_result);

	RETURN l_xml_result;

	EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
		RAISE;
END; -- END FPDSNGXMLGEN

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION getFPDSNGFileName(	p_document_type varchar2,
							p_orgid number,
							p_document_id varchar2,
							p_revision_num number,
							p_release_num number,
							p_language_code varchar2) RETURN varchar2 IS

	l_api_name	CONSTANT  VARCHAR2(25):= 'getFPDSNGFileName';
	l_po_number	po_headers_all.segment1%type;
	l_file_name	fnd_lobs.file_name%type;
	l_extension	VARCHAR2(15);
	l_doc_type	VARCHAR2(10);
	l_progress	VARCHAR2(3);
	l_release_num number;

BEGIN

	l_progress := '000';

	IF g_debug_stmt THEN
		PO_DEBUG.debug_begin(p_log_head => g_log_head || l_api_name);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id', p_document_id);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_type', p_document_type);
	END IF;

	BEGIN
		l_progress := '001';
		-- Query for getting the PO number i.e segment1.
		l_progress := '002';
		SELECT ph.segment1 into l_po_number
		FROM  po_headers_all ph
		WHERE po_header_id = p_document_id;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_po_number', l_po_number);
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			raise_application_error (-20001,'Document Number Cannot be NULL or Invalid.');
	END;

	l_progress := '003';
	IF p_document_type = 'STANDARD' THEN
		l_doc_type := 'PO';
	ELSE
		IF p_release_num < 0 THEN
			l_progress := '004';
			SELECT release_num INTO l_release_num
			FROM po_releases_all
			WHERE po_release_id = PO_COMM_FPDSNG_PVT.getReleaseId();
		ELSE
			l_progress := '005';
			l_release_num := p_release_num;
		END IF;
		l_doc_type := 'REL_' || l_release_num ;
	END IF;

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_doc_type', l_doc_type);
	END IF;

	--If The Po Number Is Null Assign The Document Id To PO Number.
	l_progress := '006';
	IF l_po_number IS NULL THEN
		l_po_number := p_document_id;
	END IF;

	--Assigning XML to File Extension Type
	l_extension := '.xml';

	/* Creating the Filename here */
	l_file_name := l_doc_type||'_FPDSNG_'||p_orgid||'_'||l_po_number||'_'||p_revision_num||'_'||p_language_code||l_extension;

	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_file_name', l_file_name);
		PO_DEBUG.debug_end(g_log_head || l_api_name);
	END IF;

	RETURN  l_file_name;
EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
		RAISE;

END getFPDSNGFileName;


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
procedure Store_Blob(p_document_id IN NUMBER,
                    p_revision_number IN NUMBER ,
                    p_document_type IN VARCHAR2,
                    p_file_name IN VARCHAR2,
					p_result IN BLOB,
                    p_media_id OUT NOCOPY NUMBER)
IS
	l_Row_id_tmp		VARCHAR2(100);
	l_document_id_tmp	NUMBER;
	l_entity_name		VARCHAR2(30);
	Seq_num				NUMBER;
	l_category_id		NUMBER;

	l_file_content_type fnd_lobs.file_content_type%type;
	l_progress			VARCHAR2(3);
	l_api_name CONSTANT VARCHAR2(25):= 'Store_Blob';

Begin

    l_progress := '000';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => g_log_head||l_api_name);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id', p_document_id);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_revision_number', p_revision_number);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_type', p_document_type);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_file_name', p_file_name);
	END IF;

	l_file_content_type := 'text/xml';

    l_progress := '001';
	l_entity_name := 'PO_HEAD';

	BEGIN

		l_progress := '002';
		SELECT DISTINCT fl.file_id INTO p_media_id
		FROM fnd_lobs fl,fnd_attached_documents fad
		WHERE
			fad.pk1_value = TO_CHAR(p_document_id) and
			fad.pk2_value = TO_CHAR(p_revision_number) and
			fad.entity_name = l_entity_name AND
			fl.file_name = p_file_name;

	EXCEPTION
	WHEN NO_DATA_FOUND then
		p_media_id := NULL;
	END;

	l_progress := '003';
	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_media_id', p_media_id);
	END IF;

	IF p_media_id IS NULL THEN

		--Get the Category Id of 'PO Documents' Category
		l_progress := '004';
		SELECT category_id into l_category_id
		from fnd_document_categories
		where  name   = 'CUSTOM2446' ;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'l_category_id', l_category_id);
		END IF;

		l_progress := '005';
		FND_DOCUMENTS_PKG.Insert_Row(
			l_Row_id_tmp,
			l_document_id_tmp,
			SYSDATE,
			1,			--NVL(X_created_by,0),
			SYSDATE,
			1,          --NVL(X_created_by,0),
			1,          --X_last_update_login,
			6,
			l_category_id, --Get the value for the category id 'PO Documents'
			1,		--security_type,
			null,	--security_id,
			'Y',	--publish_flag,
			null,	--image_type,
			null,	--storage_type,
			'O',	--usage_type,
			sysdate,--start_date_active,
			null,	--end_date_active,
			null,	--X_request_id,
			null,	--X_program_application_id,
			null,	--X_program_id,
			SYSDATE,
			null,	--language,
			null,	--description,
			p_file_name,
			p_media_id);

		l_progress := '006';
		INSERT INTO fnd_lobs (
			file_id,
			File_name,
			file_content_type,
			upload_date,
			expiration_date,
			program_name,
			program_tag,
			file_data,
			language,
			oracle_charset,
			file_format)
			VALUES
			(p_media_id,
			p_file_name,
			l_file_content_type,
			sysdate,
			null,
			null,
			null,
			p_result,
			null,
			null,
			'binary');

		l_progress := '007';
		INSERT INTO fnd_attached_documents (
			attached_document_id,
			document_id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			seq_num,
			entity_name,
			pk1_value,
			pk2_value,
			pk3_value,
			pk4_value,
			pk5_value,
			automatically_added_flag,
			program_application_id,
			program_id,
			program_update_date,
			request_id,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			column1)
			VALUES
			(fnd_attached_documents_s.nextval,
			l_document_id_tmp,
			sysdate,
			1,--NVL(X_created_by,0),
			sysdate,
			1,--NVL(X_created_by,0),
			null,-- X_last_update_login,
			10,
			l_entity_name,
			to_char(p_document_id),
			to_char(p_revision_number),
			null, null, null,
			'N',
			null, null, sysdate,
			null, null, null, null, null,
			null, null, null, null, null,
			null, null, null, null, null,
			null, null, null);

		IF g_debug_stmt THEN
			PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'Data Inserted in Tables. After', l_progress);
		END IF;

	ELSE
		l_progress := '006';

		UPDATE fnd_lobs SET file_data = p_result, upload_date = sysdate
		WHERE file_id = p_media_id;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'Data Updated in Table. After', l_progress);
		END IF;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
       RAISE;
END Store_Blob;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION clob_to_blob(p_ClobData IN CLOB ) RETURN BLOB
-- typecasts CLOB to BLOB (binary conversion)
IS
	l_DataSize	PLS_INTEGER := 1;
	l_Buffer	RAW( 32767 );
	l_TempBLOB	BLOB;
	l_BLOBLength PLS_INTEGER := DBMS_LOB.getLength( p_ClobData );
	l_api_name	CONSTANT  VARCHAR2(25):= 'CLOB_TO_BLOB';
	l_progress	VARCHAR2(3);

BEGIN
	l_progress := '000';
	DBMS_LOB.createTemporary( l_TempBLOB, TRUE );

	l_progress := '001';
	DBMS_LOB.OPEN( l_TempBLOB, DBMS_LOB.LOB_ReadWrite );

	l_progress := '002';
	LOOP
		l_progress := '003';
		l_Buffer := UTL_RAW.cast_to_raw( DBMS_LOB.SUBSTR( p_ClobData, 16000, l_DataSize ) );

		IF UTL_RAW.LENGTH( l_Buffer ) > 0 THEN
			DBMS_LOB.writeAppend( l_TempBLOB, UTL_RAW.LENGTH( l_Buffer ), l_Buffer );
		END IF;

		l_DataSize := l_DataSize + 16000;
		EXIT WHEN l_DataSize > l_BLOBLength;
	END LOOP;
	l_progress := '004';
	RETURN l_TempBLOB; -- l_TempBLOB is OPEN here
EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
       RAISE;
END clob_to_blob;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION blob_to_clob(p_BlobData IN BLOB) RETURN CLOB
IS
	l_CLOBData    CLOB;
	l_TempChar VARCHAR2(32767);
	l_Start	 PLS_INTEGER := 1;
	l_Buffer  PLS_INTEGER := 32767;
	l_api_name CONSTANT  VARCHAR2(25):= 'BLOB_TO_CLOB';
	l_progress	VARCHAR2(3);

BEGIN

	l_progress := '000';
	DBMS_LOB.CREATETEMPORARY(l_CLOBData, TRUE);

	l_progress := '001';
	FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(p_BlobData) / l_Buffer)
	LOOP

		l_progress := '002';
		l_TempChar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(p_BlobData, l_Buffer, l_Start));

        DBMS_LOB.WRITEAPPEND(l_CLOBData, LENGTH(l_TempChar), l_TempChar);

		l_Start := l_Start + l_Buffer;
	END LOOP;

	l_progress := '003';

   RETURN l_CLOBData;
EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
       RAISE;
END blob_to_clob;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
FUNCTION Replace_Clob_String (
	p_ClobData IN CLOB,
	p_str_to_replace IN VARCHAR2,
	p_replace_with IN VARCHAR2)
RETURN CLOB IS

l_buffer    VARCHAR2 (32767);
l_amount   BINARY_INTEGER := 32767;
l_pos      PLS_INTEGER := 1;
l_clob_len PLS_INTEGER;
l_new_Clob    CLOB := EMPTY_CLOB;
l_api_name CONSTANT  VARCHAR2(25):= 'REPLACE_CLOB_STRING';
l_progress	VARCHAR2(3);

BEGIN
	l_progress := '000';
	-- initalize the new clob
	dbms_lob.createtemporary(l_new_Clob,TRUE);

	l_progress := '001';
	l_clob_len := dbms_lob.getlength(p_ClobData);

	l_progress := '002';
	WHILE l_pos < l_clob_len
	LOOP
		dbms_lob.read(p_ClobData, l_amount, l_pos, l_buffer);

		IF l_buffer IS NOT NULL THEN
			-- replace the text
			l_buffer := replace(l_buffer, p_str_to_replace, p_replace_with);
			-- write it to the new clob
			dbms_lob.writeappend(l_new_Clob, LENGTH(l_buffer), l_buffer);
		END IF;
		l_pos := l_pos + l_amount;
  END LOOP;
  l_progress := '003';

  RETURN l_new_Clob;
EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
       RAISE;
END;

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
PROCEDURE Communicate(	p_document_id IN NUMBER,
						p_revision_number IN VARCHAR2,
						p_document_type  IN VARCHAR2,
						p_request_id OUT NOCOPY NUMBER)
IS
	l_header_id NUMBER;
	l_release_num NUMBER;
	l_api_name CONSTANT  VARCHAR2(25):= 'COMMUNICATE';
	l_progress	VARCHAR2(3);

BEGIN
	l_progress := '000';

	IF g_debug_stmt THEN
		PO_DEBUG.debug_begin(p_log_head => g_log_head || l_api_name);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_id', p_document_id);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_revision_number', p_revision_number);
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_document_type', p_document_type);
	END IF;

    IF p_document_type = ('STANDARD') THEN

		l_progress := '001';
		l_header_id := p_document_id;
		l_release_num := NULL;

    ELSIF p_document_type in ('RELEASE') THEN
		l_progress := '002';
		select pr.po_header_id, pr.release_num into l_header_id, l_release_num
		from po_releases_all pr
        where pr.po_release_id = p_document_id;

    END IF;

	l_progress := '003';

	p_request_id := fnd_request.submit_request('PO',
	 'POFPDSNG',
	 null,
	 null,
	 false,

	 l_header_id,		--PO_HEADER_ID
	 l_release_num,		--PO_RELEASE_ID
	 p_revision_number,	--REVISION_NUM

	 fnd_global.local_chr(0),NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	 NULL, NULL);


	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(g_log_head || l_api_name, l_progress, 'p_request_id', p_request_id);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_unexp THEN
			PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name, p_progress => l_progress);
		END IF;
       RAISE;
END Communicate;

END PO_COMM_FPDSNG_PVT;

/
