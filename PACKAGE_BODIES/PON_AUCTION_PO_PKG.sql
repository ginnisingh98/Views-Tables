--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_PO_PKG" as
/* $Header: PONAUPOB.pls 120.6.12010000.8 2012/06/29 09:24:35 spapana ship $ */

g_fnd_debug 		CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name 		CONSTANT VARCHAR2(30) := 'PON_AUCTION_PO_PKG';
g_module_prefix 	CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';
g_module VARCHAR2(200) := 'PON.PLSQL.PON_AUCTION_PO_PKG';

PROCEDURE log_message(p_message  IN    VARCHAR2)

IS

BEGIN

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix,
                        message  => p_message);
      END IF;
   END IF;

END;


PROCEDURE check_unique(org_id      IN NUMBER,
                       po_number   IN VARCHAR2,
                       status      OUT NOCOPY VARCHAR2) IS


x_number_of_pos NUMBER;

BEGIN
       check_unique(org_id, po_number, null, status);

END check_unique;

/*-----------------------------------------------------------------
* check_unique: This procedure will check for the uniquesness of
* the po_number in pon_bid_headers table for a given org_id,po_number
* and bid_number. Added p_bid_number for bug 11895155 fix
*----------------------------------------------------------------*/

PROCEDURE check_unique(org_id      IN NUMBER,
                       po_number   IN VARCHAR2,
                       p_bid_number  IN NUMBER,
                       status      OUT NOCOPY VARCHAR2) IS


x_number_of_pos NUMBER;

BEGIN

       x_number_of_pos := 0;

       SELECT count(*)
       INTO   x_number_of_pos
       FROM   pon_bid_headers pbh, pon_auction_headers_all pah
       WHERE  pbh.order_number = po_number and
              nvl(pah.org_id, -9999) = nvl(org_id,-9999) and
              pbh.auction_header_id = pah.auction_header_id and
			  pbh.bid_number <> nvl(p_bid_number, -1);


       IF (x_number_of_pos = 0) THEN
           status := 'SUCCESS';
       ELSE
           status := 'FAILURE';
       END IF;

END check_unique;

PROCEDURE GET_ATTACHMENT(pk1                IN NUMBER,
                         pk2                IN NUMBER,
                         pk3                IN NUMBER,
                         attachmentType     IN VARCHAR2,
                         attachmentDesc     OUT NOCOPY	VARCHAR2,
                         attachment         OUT NOCOPY	LONG,
                         error_code         OUT NOCOPY	VARCHAR2,
                         error_msg          OUT NOCOPY	VARCHAR2) IS

x_progress VARCHAR2(4000);


BEGIN
     error_code := 'SUCCESS';
     error_msg := '';


     IF (attachmentType = 'PON_BID_ATTRIBUTES') THEN
        PON_AUCTION_PO_PKG.GET_ATTRIBUTE_ATTACHMENT(pk1, pk2, pk3, attachmentDesc, attachment, error_code, error_msg);
     ELSIF (attachmentType = 'PON_BID_HEADER_ATTRIBUTES') THEN
        PON_AUCTION_PO_PKG.GET_HDR_ATTRIBUTE_ATTACHMENT(pk1, pk2, pk3, attachmentDesc, attachment, error_code, error_msg);
     ELSIF (attachmentType = 'PON_BID_BUYER_NOTES') THEN
        PON_AUCTION_PO_PKG.GET_NOTE_TO_BUYER_ATTACHMENT(pk1, pk2, pk3, attachmentDesc, attachment, error_code, error_msg);
     ELSIF (attachmentType = 'PON_AUCTION_SUPPLIER_NOTES') THEN
        PON_AUCTION_PO_PKG.GET_NOTE_TO_SUPP_ATTACHMENT(pk1, pk3, attachmentDesc, attachment, error_code, error_msg, 'BOTH');
     ELSIF (attachmentType = 'PON_AUC_SUPPLIER_LINE_NOTES') THEN
        PON_AUCTION_PO_PKG.GET_NOTE_TO_SUPP_ATTACHMENT(pk1, pk3, attachmentDesc, attachment, error_code, error_msg, 'LINE');
     ELSIF (attachmentType = 'PON_AUC_SUPPLIER_HEADER_NOTES') THEN
        PON_AUCTION_PO_PKG.GET_NOTE_TO_SUPP_ATTACHMENT(pk1, pk3, attachmentDesc, attachment, error_code, error_msg, 'HEADER');
     ELSIF (attachmentType = 'PON_BID_TOTAL_COST') THEN
        PON_AUCTION_PO_PKG.GET_TOTAL_COST_ATTACHMENT(pk1, pk2, pk3, attachmentDesc, attachment, error_code, error_msg);
     ELSIF (attachmentType = 'PON_JOB_DETAILS') THEN
        PON_AUCTION_PO_PKG.GET_JOB_DETAILS_ATTACHMENT(pk1, pk3,
							    attachmentDesc, attachment,
							    error_code, error_msg);
     ELSIF(attachmentType = 'PON_AUC_PYMNT_SHIP_SUPP_NOTES') and (pk1 is not null)  THEN
	    GET_PAYMENT_NOTE_TO_SUPP(pk1, attachmentDesc, attachment, error_code, error_msg);


     END IF;

     IF (error_code = 'FAILURE') THEN
         x_progress := 'PON_AUCTION_PO_PKG: GET_ATTACHMENT: EXCEPTION handling pk1:' || pk1 || ' pk2: ' || pk2 || ' pk3: ' || pk3 || ' attachmentType: ' || attachmentType;
	log_message(x_progress);
     END IF;

EXCEPTION

     when others then
          error_code := 'FAILURE';
          error_msg := SQLERRM;
          x_progress := 'PON_AUCTION_PO_PKG: GET_ATTACHMENT: EXCEPTION handling pk1: ' || pk1 || ' pk2: ' || pk2 || ' pk3: ' || pk3 || ' attachmentType: ' || attachmentType;
	  log_message(x_progress);

END GET_ATTACHMENT;

PROCEDURE GET_ATTRIBUTE_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                   p_bid_number           IN NUMBER,
                                   p_line_number          IN NUMBER,
                                   p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                   p_attachment           OUT NOCOPY	LONG,
                                   p_error_code           OUT NOCOPY	VARCHAR2,
                                   p_error_msg            OUT NOCOPY	VARCHAR2) IS

x_item_description pon_auction_item_prices_all.item_description%TYPE;
x_attribute_name pon_bid_attribute_values.attribute_name%TYPE;
x_bidValue pon_bid_attribute_values.value%TYPE;
newline varchar2(256);
tab varchar2(256);
x_has_attributes_flag pon_auction_item_prices_all.has_attributes_flag%TYPE;
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
x_has_real_attr VARCHAR2(1);

CURSOR attribute_info IS

        SELECT     replace(pbav.attribute_name, fnd_global.local_chr(13)), pbav.value
        FROM       pon_bid_attribute_values pbav,
                   pon_auction_attributes paa
        WHERE      pbav.auction_header_id = p_auction_header_id and
                   pbav.bid_number = p_bid_number and
                   pbav.line_number = p_line_number and
                   pbav.sequence_number > 0 and
                   pbav.auction_header_id = paa.auction_header_id and
                   pbav.line_number = paa.line_number and
                   pbav.sequence_number = paa.sequence_number and
                   paa.ip_category_id is null
        ORDER BY   pbav.sequence_number;


BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;
p_error_code := 'SUCCESS';
p_error_msg := '';

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name
INTO   x_doctype_group_name
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_ATTR_ATTACH_DESC', x_msg_suffix);

SELECT item_description, has_attributes_flag
INTO   x_item_description, x_has_attributes_flag
FROM   pon_auction_item_prices_all
WHERE  auction_header_id = p_auction_header_id and
       line_number = p_line_number;

IF (x_has_attributes_flag = 'N') THEN
    p_attachment := null;
    return;
END IF;



x_has_real_attr := 'N';
OPEN attribute_info;
LOOP
      FETCH attribute_info INTO x_attribute_name, x_bidValue;
      EXIT WHEN attribute_info%NOTFOUND;
      x_has_real_attr := 'Y';
      p_attachment := p_attachment || x_attribute_name || ' = ' || x_bidValue
                                                        || newline || newline;
END LOOP;
CLOSE attribute_info;

-- commented for bug 13840042

/*
IF (x_has_real_attr = 'Y') THEN
   p_attachment := x_item_description || newline || newline || p_attachment;
ELSE
   p_attachment := null;
END IF;
*/

IF (x_has_real_attr = 'N') THEN
   p_attachment := null;
END IF;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;

          IF (attribute_info%ISOPEN) THEN
              close attribute_info;
          END IF;

END GET_ATTRIBUTE_ATTACHMENT;


PROCEDURE GET_HDR_ATTRIBUTE_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                       p_bid_number           IN NUMBER,
                                       p_line_number          IN NUMBER,
                                       p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                       p_attachment           OUT NOCOPY	LONG,
                                       p_error_code           OUT NOCOPY	VARCHAR2,
                                       p_error_msg            OUT NOCOPY	VARCHAR2) IS

x_auction_title pon_auction_headers_all.auction_title%TYPE;
x_attribute_name pon_bid_attribute_values.attribute_name%TYPE;
x_bidValue pon_bid_attribute_values.value%TYPE;
x_sequenceNumber pon_bid_attribute_values.sequence_number%TYPE;
x_attachment_title varchar2(256);
x_document_number varchar2(240);
newline varchar2(256);
tab varchar2(256);
x_has_attributes_flag pon_auction_headers_all.has_hdr_attr_flag%TYPE;
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
x_has_real_attr VARCHAR2(1);

/* have to retrieve display only attributes separately as they are only
   stored in pon_bid_attribute_values after scoring has happened */
CURSOR attribute_info IS

        SELECT     replace(pbav.attribute_name, fnd_global.local_chr(13)),
                   pbav.value, paa.sequence_number
        FROM       pon_bid_attribute_values pbav, pon_auction_attributes paa
        WHERE      pbav.auction_header_id = p_auction_header_id and
                   pbav.bid_number = p_bid_number and
                   pbav.line_number = -1 and
                   paa.auction_header_id = pbav.auction_header_id and
                   paa.line_number = -1 and
                   paa.sequence_number = pbav.sequence_number and
                   nvl(paa.internal_attr_flag, 'N') = 'N' and
                   nvl(paa.display_only_flag, 'N') = 'N'
        UNION
        SELECT     replace(paa.attribute_name, fnd_global.local_chr(13)),
                   paa.value, paa.sequence_number
        FROM       pon_auction_attributes paa
        WHERE      paa.auction_header_id = p_auction_header_id and
                   paa.line_number = -1 and
                   nvl(paa.display_only_flag, 'N') = 'Y'
        ORDER BY   3;


BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;
p_error_code := 'SUCCESS';
p_error_msg := '';

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name
INTO   x_doctype_group_name
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_HDR_ATTR_ATTACH_DESC', x_msg_suffix);

SELECT auction_title, document_number, has_hdr_attr_flag
INTO   x_auction_title, x_document_number, x_has_attributes_flag
FROM   pon_auction_headers_all
WHERE  auction_header_id = p_auction_header_id;

IF (x_has_attributes_flag = 'N') THEN
    p_attachment := null;
    return;
END IF;

x_has_real_attr := 'N';
OPEN attribute_info;
LOOP
      FETCH attribute_info INTO x_attribute_name, x_bidValue, x_sequenceNumber;
      EXIT WHEN attribute_info%NOTFOUND;
      x_has_real_attr := 'Y';
      p_attachment := p_attachment || x_attribute_name || ' = ' || x_bidValue
                                                        || newline || newline;
END LOOP;
CLOSE attribute_info;
x_attachment_title := PON_AUCTION_PKG.getMessage('PON_ATTR_ATTACH_TITLE',
                                                 x_msg_suffix,
                                                 'NUMBER', x_document_number,
                                                 'TITLE', PON_AUCTION_PKG.replaceHtmlChars(x_auction_title));
IF (x_has_real_attr = 'Y') THEN
   p_attachment := x_attachment_title || newline || newline || p_attachment;
   --p_attachment := dbms_xmlgen.Convert(p_attachment);
ELSE
   p_attachment := null;
END IF;
EXCEPTION
     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;
          IF (attribute_info%ISOPEN) THEN
              close attribute_info;
          END IF;
END GET_HDR_ATTRIBUTE_ATTACHMENT;
PROCEDURE GET_HDR_ATTRIBUTE_ATTACH_CLOB(p_auction_header_id    IN NUMBER,
                                       p_bid_number           IN NUMBER,
                                       p_line_number          IN NUMBER,
                                       p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                       p_attachment           OUT NOCOPY	CLOB,
                                       p_error_code           OUT NOCOPY	VARCHAR2,
                                       p_error_msg            OUT NOCOPY	VARCHAR2) IS
x_auction_title pon_auction_headers_all.auction_title%TYPE;
x_attribute_name pon_bid_attribute_values.attribute_name%TYPE;
x_bidValue pon_bid_attribute_values.value%TYPE;
x_sequenceNumber pon_bid_attribute_values.sequence_number%TYPE;
x_attachment_title varchar2(256);
x_document_number varchar2(240);
newline varchar2(256);
tab varchar2(256);
x_has_attributes_flag pon_auction_headers_all.has_hdr_attr_flag%TYPE;
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
x_has_real_attr VARCHAR2(1);
/* have to retrieve display only attributes separately as they are only
   stored in pon_bid_attribute_values after scoring has happened */
CURSOR attribute_info IS
        SELECT     replace(pbav.attribute_name, fnd_global.local_chr(13)),
                   pbav.value, paa.sequence_number
        FROM       pon_bid_attribute_values pbav, pon_auction_attributes paa
        WHERE      pbav.auction_header_id = p_auction_header_id and
                   pbav.bid_number = p_bid_number and
                   pbav.line_number = -1 and
                   paa.auction_header_id = pbav.auction_header_id and
                   paa.line_number = -1 and
                   paa.sequence_number = pbav.sequence_number and
                   nvl(paa.internal_attr_flag, 'N') = 'N' and
                   nvl(paa.display_only_flag, 'N') = 'N'
        UNION
        SELECT     replace(paa.attribute_name, fnd_global.local_chr(13)),
                   paa.value, paa.sequence_number
        FROM       pon_auction_attributes paa
        WHERE      paa.auction_header_id = p_auction_header_id and
                   paa.line_number = -1 and
                   nvl(paa.display_only_flag, 'N') = 'Y'
        ORDER BY   3;
BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;
p_error_code := 'SUCCESS';
p_error_msg := '';
-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name
INTO   x_doctype_group_name
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;
x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);
p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_HDR_ATTR_ATTACH_DESC', x_msg_suffix);
SELECT auction_title, document_number, has_hdr_attr_flag
INTO   x_auction_title, x_document_number, x_has_attributes_flag
FROM   pon_auction_headers_all
WHERE  auction_header_id = p_auction_header_id;
IF (x_has_attributes_flag = 'N') THEN
    p_attachment := null;
    return;
END IF;
x_has_real_attr := 'N';
OPEN attribute_info;
LOOP
      FETCH attribute_info INTO x_attribute_name, x_bidValue, x_sequenceNumber;
      EXIT WHEN attribute_info%NOTFOUND;
      x_has_real_attr := 'Y';
      p_attachment := p_attachment || x_attribute_name || ' = ' || x_bidValue
                                                        || newline || newline;
END LOOP;
CLOSE attribute_info;

x_attachment_title := PON_AUCTION_PKG.getMessage('PON_ATTR_ATTACH_TITLE',
                                                 x_msg_suffix,
                                                 'NUMBER', x_document_number,
                                                 'TITLE', PON_AUCTION_PKG.replaceHtmlChars(x_auction_title));

IF (x_has_real_attr = 'Y') THEN
   p_attachment := x_attachment_title || newline || newline || p_attachment;
ELSE
   p_attachment := null;
END IF;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;

          IF (attribute_info%ISOPEN) THEN
              close attribute_info;
          END IF;

END GET_HDR_ATTRIBUTE_ATTACH_CLOB;


PROCEDURE GET_NOTE_TO_BUYER_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                       p_bid_number           IN NUMBER,
                                       p_line_number          IN NUMBER,
                                       p_attachmentDesc       OUT NOCOPY 	VARCHAR2,
                                       p_attachment           OUT NOCOPY	LONG,
                                       p_error_code           OUT NOCOPY	VARCHAR2,
                                       p_error_msg            OUT NOCOPY	VARCHAR2) IS

newline varchar2(256);
tab varchar2(256);
header_note pon_bid_headers.note_to_auction_owner%TYPE;
line_note pon_bid_item_prices.note_to_auction_owner%TYPE;
msgBidHeaderNote varchar2(2000);
msgBidLineNote varchar2(2000);
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
l_contract_type    PON_AUCTION_HEADERS_ALL.contract_type%TYPE;
BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name, nvl(auh.contract_type,'NO_DATA_FOUND')
INTO   x_doctype_group_name, l_contract_type
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_NOTE_BUYER_DESC', x_msg_suffix);

msgBidHeaderNote := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BID_HEADER_NOTE', x_msg_suffix);
msgBidLineNote := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BID_LINE_NOTE', x_msg_suffix);
p_error_code := 'SUCCESS';
p_error_msg := '';

IF l_contract_type <> 'CONTRACT' THEN
  SELECT replace(pbh.note_to_auction_owner, fnd_global.local_chr(13)), replace(pbip.note_to_auction_owner, fnd_global.local_chr(13))
  INTO header_note, line_note
  FROM   pon_bid_headers pbh, pon_bid_item_prices pbip
  WHERE  pbh.auction_header_id = p_auction_header_id and
       pbh.bid_number = p_bid_number and
       pbip.bid_number = pbh.bid_number and
       pbip.line_number = p_line_number;
ELSE
  SELECT replace(pbh.note_to_auction_owner, fnd_global.local_chr(13))
  INTO header_note
  FROM   pon_bid_headers pbh
  WHERE  pbh.auction_header_id = p_auction_header_id and
       pbh.bid_number = p_bid_number;
END IF; -- if contractType <> 'CONTRACT

IF (header_note IS NOT null) THEN
    p_attachment  := msgBidHeaderNote || newline || newline || tab || header_note || newline || newline;
END IF;

IF (line_note IS NOT null) THEN
    p_attachment := p_attachment || msgBidLineNote   || newline || newline || tab || line_note;
END IF;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;

END GET_NOTE_TO_BUYER_ATTACHMENT;


PROCEDURE GET_NOTE_TO_SUPP_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                      p_line_number          IN NUMBER,
                                      p_attachmentDesc       OUT NOCOPY		VARCHAR2,
                                      p_attachment           OUT NOCOPY		LONG,
                                      p_error_code           OUT NOCOPY		VARCHAR2,
                                      p_error_msg            OUT NOCOPY		VARCHAR2,
				      p_line_or_header 	     IN  VARCHAR2)	IS

newline varchar2(256);
tab varchar2(256);
header_note pon_auction_headers_all.note_to_bidders%TYPE;
line_note pon_auction_item_prices_all.note_to_bidders%TYPE;
msgNegHeaderNote varchar2(2000);
msgNegLineNote varchar2(2000);
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
l_contract_type    PON_AUCTION_HEADERS_ALL.contract_type%TYPE;

BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;
msgNegHeaderNote := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NEG_HEADER_NOTE');
msgNegLineNote := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NEG_LINE_NOTE');
p_error_code := 'SUCCESS';
p_error_msg := '';

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name, nvl(auh.contract_type,'NO_DATA_FOUND')
INTO   x_doctype_group_name, l_contract_type
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_NOTE_SUPP_DESC', x_msg_suffix);

IF l_contract_type <> 'CONTRACT' THEN
  SELECT replace(pah.note_to_bidders, fnd_global.local_chr(13)), replace(paip.note_to_bidders, fnd_global.local_chr(13))
  INTO   header_note, line_note
  FROM   pon_auction_headers_all pah, pon_auction_item_prices_all paip
  WHERE  pah.auction_header_id = p_auction_header_id and
         paip.auction_header_id = pah.auction_header_id and
         paip.line_number = p_line_number;
ELSE

  SELECT replace(pah.note_to_bidders, fnd_global.local_chr(13))
  INTO   header_note
  FROM   pon_auction_headers_all pah
  WHERE  pah.auction_header_id = p_auction_header_id;

END IF;

IF (p_line_or_header = 'BOTH') THEN
   IF (header_note IS NOT null) THEN
      p_attachment  := msgNegHeaderNote || newline || newline || tab || header_note || newline || newline;
   END IF;

   IF (line_note IS NOT null) THEN
      p_attachment := p_attachment || msgNegLineNote   || newline || newline || tab || line_note;
   END IF;
ELSIF (p_line_or_header = 'LINE') THEN
   IF (line_note IS NOT null) THEN
      p_attachment := msgNegLineNote   || newline || newline || tab || line_note;
   END IF;
ELSIF (p_line_or_header = 'HEADER') THEN
   IF (header_note IS NOT null) THEN
      p_attachment  := msgNegHeaderNote || newline || newline || tab || header_note;
   END IF;
END IF;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;


END GET_NOTE_TO_SUPP_ATTACHMENT;


PROCEDURE GET_TOTAL_COST_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                    p_bid_number           IN NUMBER,
                                    p_line_number          IN NUMBER,
                                    p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                    p_attachment           OUT NOCOPY	LONG,
                                    p_error_code           OUT NOCOPY	VARCHAR2,
                                    p_error_msg            OUT NOCOPY	VARCHAR2) IS

newline varchar2(256);
tab varchar2(256);
x_item_description pon_auction_item_prices_all.item_description%TYPE;
x_has_price_elements_flag pon_auction_item_prices_all.has_price_elements_flag%TYPE;
x_price_element_name pon_price_element_types_tl.name%TYPE;
x_bidValue pon_bid_price_elements.bid_currency_value%TYPE;
x_pricing_basis_display varchar2(2000);
x_msg_suffix     VARCHAR2(3) := '';
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;

CURSOR total_cost_info IS

        SELECT     ppet.name,
                   flv.meaning,
                   pbpe.bid_currency_value
        FROM       pon_bid_price_elements pbpe, pon_price_element_types_tl ppet, fnd_lookup_values flv
        WHERE      pbpe.bid_number =  p_bid_number and
                   pbpe.auction_header_id = p_auction_header_id and
                   pbpe.line_number = p_line_number and
                   pbpe.price_element_type_id <> -10 and
                   pbpe.pf_type = 'SUPPLIER' and
                   pbpe.price_element_type_id = ppet.price_element_type_id and
                   ppet.language = PON_AUCTION_PKG.SessionLanguage and
                   flv.lookup_type = 'PON_PRICING_BASIS' and
                   flv.language = PON_AUCTION_PKG.SessionLanguage and
                   flv.view_application_id = 0 and
                   flv.security_group_id = 0 and
                   pbpe.pricing_basis = flv.lookup_code
        ORDER BY   sequence_number;

BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;

p_error_code := 'SUCCESS';
p_error_msg := '';

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name
INTO   x_doctype_group_name
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_TOTAL_COST_DESC', x_msg_suffix);

SELECT item_description, has_price_elements_flag
INTO   x_item_description, x_has_price_elements_flag
FROM   pon_auction_item_prices_all
WHERE  auction_header_id = p_auction_header_id and
       line_number = p_line_number;

IF (x_has_price_elements_flag = 'N') THEN
    p_attachment := null;
    return;
END IF;

-- commented for bug 13840042
-- p_attachment := x_item_description || newline || newline;

OPEN total_cost_info;
LOOP
      FETCH total_cost_info INTO x_price_element_name, x_pricing_basis_display, x_bidValue;
      EXIT WHEN total_cost_info%NOTFOUND;

      p_attachment := p_attachment || x_price_element_name || ' = ' || x_bidValue || ' (' || x_pricing_basis_display || ')' ||  newline || newline;
END LOOP;
CLOSE total_cost_info;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;

          IF (total_cost_info%ISOPEN) THEN
              close total_cost_info;
          END IF;

END GET_TOTAL_COST_ATTACHMENT;


PROCEDURE GET_JOB_DETAILS_ATTACHMENT (p_auction_header_id IN NUMBER,
                                      p_line_number IN NUMBER,
                                      p_attachmentDesc OUT NOCOPY VARCHAR2,
                                      p_attachment OUT NOCOPY LONG,
                                      p_error_code OUT NOCOPY VARCHAR2,
                                      p_error_msg OUT NOCOPY VARCHAR2) IS

newline varchar2(256);
tab varchar2(256);
job_details pon_auction_item_prices_all.additional_job_details%TYPE;
x_doctype_group_name pon_auc_doctypes.doctype_group_name%TYPE;
x_msg_suffix     VARCHAR2(3) := '';

BEGIN
p_attachment := null;
newline := fnd_global.newline;
tab := fnd_global.tab;

-- adding exception catching block for bug 8583848
BEGIN
SELECT dt.doctype_group_name
INTO   x_doctype_group_name
FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
WHERE  auh.auction_header_id = p_auction_header_id and
       auh.doctype_id = dt.doctype_id;
EXCEPTION
WHEN No_Data_Found THEN
RETURN;
END;

x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_JOB_DETAILS_DESC',
					       x_msg_suffix);

p_error_code := 'SUCCESS';
p_error_msg := '';

SELECT replace(paip.additional_job_details, fnd_global.local_chr(13))
INTO 	 job_details
FROM   pon_auction_item_prices_all paip
WHERE  paip.auction_header_id = p_auction_header_id and
       paip.line_number = p_line_number;

p_attachment := job_details;

EXCEPTION

     when others then
          p_error_code := 'FAILURE';
          p_error_msg := SQLERRM;

END GET_JOB_DETAILS_ATTACHMENT;

--Complex work- This method creates fnd attachments out of Buyer notes on Payments
-- These attachments are put on corresponding PO payments
PROCEDURE GET_PAYMENT_NOTE_TO_SUPP (      p_auction_payment_id       IN NUMBER,
	                                      p_attachmentDesc       OUT NOCOPY		VARCHAR2,
	                                      p_attachment           OUT NOCOPY		LONG,
	                                      p_error_code           OUT NOCOPY		VARCHAR2,
	                                      p_error_msg            OUT NOCOPY		VARCHAR2)
IS

newline varchar2(256);
tab varchar2(256);
pymt_note pon_auc_payments_shipments.note_to_bidders%TYPE;
msgNegPymntNote varchar2(2000);

BEGIN
	p_attachment := null;
	newline := fnd_global.newline;
	tab := fnd_global.tab;
	msgNegPymntNote := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NEG_PYMNT_NOTE');
	p_error_code := 'SUCCESS';
	p_error_msg := '';

	p_attachmentDesc := PON_AUCTION_PKG.getMessage('PON_AUC_PYMNT_NOTE_SUPP_DESC');

	  SELECT replace(pys.note_to_bidders, fnd_global.local_chr(13))
	  INTO   pymt_note
	  FROM   pon_auc_payments_shipments pys
	  WHERE  payment_id= p_auction_payment_id;


	   IF (pymt_note IS NOT null) THEN
	      p_attachment  := msgNegPymntNote || newline || newline || tab || pymt_note;
	   END IF;

	EXCEPTION

	     when others then
	          p_error_code := 'FAILURE';
	          p_error_msg := SQLERRM;


END GET_PAYMENT_NOTE_TO_SUPP;



END PON_AUCTION_PO_PKG;

/
