--------------------------------------------------------
--  DDL for Package Body POR_RCV_POST_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_RCV_POST_QUERY_PKG" AS
/* $Header: PORRCVQB.pls 120.0.12010000.2 2009/05/27 14:01:17 rohbansa ship $ */

procedure getDetails(pItemId		IN NUMBER,
		     pOrgId		IN NUMBER,
		     pRequestorId	IN NUMBER,
		     pDistributionId	IN NUMBER,
		     pOrderType		IN VARCHAR2,
		     pReqLineId		IN OUT NOCOPY NUMBER,
		     pItemNumber	OUT NOCOPY VARCHAR2,
		     pRequestorName	OUT NOCOPY VARCHAR2,
		     pReqNum		OUT NOCOPY VARCHAR2,
		     pReqHeaderId	OUT NOCOPY NUMBER,
		     pSPN		OUT NOCOPY VARCHAR2,
		     pDistributionNum	OUT NOCOPY NUMBER) IS
BEGIN

  if ( pItemId > 0 AND pOrgId > 0 ) then
    getItemNumber(pItemId, pOrgId, pItemNumber);
  end if;

  if ( pRequestorId > 0 ) then
    getRequestorName(pRequestorId, pRequestorName);
  end if;

  if ( pOrderType = 'REQ' ) then
    -- for Internal Requisition
    getReqInfoREQ(pReqLineId, pReqNum, pReqHeaderId);
  else
    -- for PO
    getReqInfo(pDistributionId, pReqNum, pReqHeaderId, pReqLineId);
    getSPN(pDistributionId, pSPN, pDistributionNum);
  end if;

END;

-- convenience function to get Requisition Number
function getReqNum(pOrderType 		IN VARCHAR2,
		   pReqLineId		IN Number,
		   pDistributionId	IN Number) RETURN VARCHAR2 IS
  xReqNum	VARCHAR2(200);
  xReqHeaderId	Number;
  xReqLineId	Number;
BEGIN
  if ( pOrderType = 'REQ' ) then
    getReqInfoREQ(pReqLineId, xReqNum, xReqHeaderId);
  else
    getReqInfo(pDistributionId, xReqNum, xReqHeaderId, xReqLineId);
  end if;

  return xReqNum;
END getReqNum;


-- get inventory item number
procedure getItemNumber(pItemId 	IN NUMBER,
			pOrgId		IN NUMBER,
			pItemNum	OUT NOCOPY VARCHAR2) IS
BEGIN

  begin
    select concatenated_segments
    into   pItemNum
    from   mtl_system_items_kfv
    where  inventory_item_id = pItemId
    and    organization_id = pOrgId;
  exception
    when no_data_found then
	null;
  end;

END;

-- get requestor name
procedure getRequestorName(pRequestorId 	IN NUMBER,
			   pName		OUT NOCOPY VARCHAR2) IS
BEGIN
  begin
    select full_name
    into   pName
    from   per_people_f
    where  person_id = pRequestorId
    and    nvl(effective_start_date, sysdate) <= sysdate
    and    nvl(effective_end_date, sysdate) >= sysdate;
  exception
    when no_data_found then
	null;
  end;

END;

-- Internal Req: get requisition number
procedure getReqInfoREQ(pReqLineId          IN NUMBER,
                        pReqNum             OUT NOCOPY VARCHAR2,
                        pReqHeaderId        OUT NOCOPY NUMBER) IS
BEGIN
  begin
    select a.segment1, a.requisition_header_id
    into   pReqNum, pReqHeaderId
    from   po_requisition_headers a,
           po_requisition_lines b
    where  a.requisition_header_id = b.requisition_header_id
    and    b.requisition_line_id = pReqLineId;
  exception
    when no_data_found then
	null;
  end;


END;


-- PO: get requisition number, req header id and line id
procedure getReqInfo(pDistributionId	IN NUMBER,
		     pReqNum		OUT NOCOPY VARCHAR2,
		     pReqHeaderId	OUT NOCOPY NUMBER,
		     pReqLineId		OUT NOCOPY NUMBER) IS
BEGIN
  begin
    select prh.segment1,prl.requisition_line_id,prh.requisition_header_id
    into   pReqNum, pReqLineId, pReqHeaderId
    from   po_requisition_headers prh,
  	   po_requisition_lines prl,
           po_distributions pod,
           po_req_distributions pord
    where  pod.po_distribution_id= pDistributionId
    and    pord.distribution_id = pod.req_distribution_id
    and    pord.requisition_line_id = prl.requisition_line_id
    and    prl.requisition_header_id = prh.requisition_header_id;
  exception
    when no_data_found then
	null;
  end;

END;

-- PO: get supplier item number and distribution number
procedure getSPN(pDistributionId 	IN NUMBER,
		 pSPN			OUT NOCOPY VARCHAR2,
		 pDistributionNum	OUT NOCOPY NUMBER) IS
BEGIN
  begin
    select pol.vendor_product_num, pod.distribution_num
    into   pSPN, pDistributionNum
    from   po_lines pol,
           po_distributions pod
    where  pod.po_line_id = pol.po_line_id
    and    pod.po_distribution_id = pDistributionId;
  exception
    when no_data_found then
	null;
  end;

END;

-- convenience function to get Order Type
function getOrderType(pOrderTypeCode IN VARCHAR2) RETURN VARCHAR2 IS
  xOrderType	VARCHAR2(200);
BEGIN
  select meaning
  into   xOrderType
  from   fnd_lookup_values
  where  lookup_type = 'POR_RCV_ORDER_TYPE'
  and    lookup_code = pOrderTypeCode
  and    language = 'US';

  return xOrderType;
END getOrderType;

function getOrderNumber(pReqHeaderId IN NUMBER) RETURN VARCHAR2 IS
  xOrderNumber  VARCHAR2(50);
BEGIN

  SELECT ORDER_NUM
  INTO xOrderNumber
  FROM (
  SELECT DISTINCT PH.SEGMENT1 || DECODE(PR.RELEASE_NUM, NULL, '', '-' || PR.RELEASE_NUM) ORDER_NUM
  FROM PO_REQUISITION_LINES_ALL PRL,
     PO_LINE_LOCATIONS_ALL PLL,
     PO_HEADERS_ALL PH,
     PO_RELEASES_ALL PR
  WHERE PRL.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID AND
     PLL.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PLL.PO_RELEASE_ID = PR.PO_RELEASE_ID(+) AND
     PRL.REQUISITION_HEADER_ID = pReqHeaderId
  UNION ALL
  SELECT DISTINCT  TO_CHAR(oe_order_import_interop_pub.Get_Order_Number(POSP.order_source_id,PORL.requisition_header_id,PORL.requisition_line_id)) ORDER_NUM
  FROM  PO_REQUISITION_HEADERS_ALL PORH,
     PO_REQUISITION_LINES_ALL PORL,
     PO_SYSTEM_PARAMETERS POSP
  WHERE  PORL.SOURCE_TYPE_CODE = 'INVENTORY' AND
    PORH.REQUISITION_HEADER_ID = PORL.REQUISITION_HEADER_ID AND
    PORH.REQUISITION_HEADER_ID = pReqHeaderId
  );

  return xOrderNumber;

exception
  when too_many_rows then
    return fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE');
  when others then
    return null;

END getOrderNumber;

function getSupplier(pReqHeaderId IN NUMBER) RETURN VARCHAR2 IS
  xSupplier VARCHAR2(240);
BEGIN

  SELECT SUPPLIER
  INTO xSupplier
  FROM (
  SELECT DISTINCT PV.VENDOR_NAME SUPPLIER
  FROM PO_REQUISITION_LINES_ALL PRL,
     PO_LINE_LOCATIONS_ALL PLL,
     PO_HEADERS_ALL PH,
     PO_VENDORS PV
  WHERE PRL.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID AND
     PLL.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PH.VENDOR_ID = PV.VENDOR_ID AND
     PRL.REQUISITION_HEADER_ID = pReqHeaderId
  UNION ALL
  SELECT DISTINCT HAOU.NAME SUPPLIER
  FROM PO_REQUISITION_LINES_ALL PRL,
     HR_ALL_ORGANIZATION_UNITS_TL HAOU
  WHERE  PRL.SOURCE_TYPE_CODE = 'INVENTORY' AND
    HAOU.ORGANIZATION_ID = PRL.SOURCE_ORGANIZATION_ID AND
    HAOU.LANGUAGE  = USERENV('LANG') AND
    PRL.REQUISITION_HEADER_ID = pReqHeaderId
  );

  return xSupplier;

exception
  when too_many_rows then
    return fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE');
  when others then
    return null;
END getSupplier;


END POR_RCV_POST_QUERY_PKG;

/
