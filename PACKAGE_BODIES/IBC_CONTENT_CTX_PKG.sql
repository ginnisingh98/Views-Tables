--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_CTX_PKG" as
/* $Header: ibcintxb.pls 120.4 2005/10/11 12:45:17 srrangar noship $ */
  -- *********************************
  -- Private Procedure Declarations
  -- *********************************

PROCEDURE Synthesize_Content_Attachments
  ( p_file_id	  IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);


PROCEDURE Synthesize_Attribute_Bundles
( p_attribute_bundle_id IN     NUMBER,
  p_clob		IN OUT NOCOPY CLOB);


PROCEDURE Synthesize_Content_Renditions
  ( p_citem_version_id	IN     NUMBER,
    p_clob		IN OUT NOCOPY CLOB);


PROCEDURE Synthesize_Content_Keywords
  ( p_citem_version_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);


--   PROCEDURE Synthesize_Content_metadata
--   ( p_solution_id IN     NUMBER,
--     p_clob        IN OUT NOCOPY CLOB);

l_newline CONSTANT VARCHAR2(4) := fnd_global.newline;

FUNCTION isValidForFilter(p_file_content_type IN VARCHAR2)
RETURN BOOLEAN IS
BEGIN

IF instr(UPPER(p_file_content_type),'IMAGE')=1 THEN
	RETURN FALSE;
ELSIF instr(UPPER(p_file_content_type),'VIDEO')=1 THEN
	RETURN FALSE;

ELSE
	RETURN TRUE;
END IF;

END isValidForFilter;

  -- ********************************
  -- Public Procedure Implementations
  -- ********************************




  Procedure Build_Content_Document
  (p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB)
  is

  l_citem_version_id	NUMBER;
  l_language		VARCHAR2(30);
  l_content_item_name	VARCHAR2(240);
  l_description		VARCHAR2(240);
  l_attachment_file_name VARCHAR2(240);
  l_attachment_file_id	NUMBER;
  l_attribute_bundle_id NUMBER;
  l_data	VARCHAR2(32000);
  l_amt		INTEGER;
CURSOR cur_name_desc(p_rowid ROWID) IS
SELECT
  ctl.citem_version_id,
  language,
  content_item_name,
  description,
  attachment_file_name,
  attachment_file_id,
  attribute_file_id
FROM IBC_CITEM_VERSIONS_TL ctl
where ctl.ROWID=p_rowid;

BEGIN

    -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    Open cur_name_desc(p_rowid);
    Fetch cur_name_desc Into l_citem_version_id,
                             l_language,
                             l_content_item_name,
                             l_description,
                             l_attachment_file_name,
			     l_attachment_file_id,
			     l_attribute_bundle_id;
    Close cur_name_desc;

   -- Add sections
   -- 1. Add NAME
   l_data := '<CONTENT_NAME>'||l_newline|| l_content_item_name||l_newline||'</CONTENT_NAME>';

   -- 2. Add LANG
    l_data := l_data||l_newline||'<LANG>a'||l_language||'a</LANG>';

   -- 3. Add DESCRIPTION
    l_data := l_data||l_newline||'<CONTENT_DESCRIPTION>'||l_description||'</CONTENT_DESCRIPTION>';

   -- 3. Add Attachment filename
    l_data := l_data||l_newline||'<ATTACHMENT_FILENAME>'||l_attachment_file_name||'</ATTACHMENT_FILENAME>';

    l_amt := length(l_data);

    dbms_lob.writeappend(p_clob, l_amt, l_data);

    Synthesize_Content_Attachments(l_attachment_file_id, p_clob);
    Synthesize_Attribute_Bundles(l_attribute_bundle_id,p_clob);
    Synthesize_Content_Keywords(l_citem_version_id,p_clob);
    Synthesize_Content_Renditions(l_citem_version_id,p_clob);

END Build_Content_Document;

  -- *********************************
  -- Private Procedure Implementations
  -- *********************************

PROCEDURE Synthesize_Content_Attachments
  ( p_file_id	  IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB) IS

CURSOR cur_attachment_file_data(p_file_id IN NUMBER) IS
SELECT
   file_data attachment_file_data,
   file_content_type
FROM
  fnd_lobs flob
WHERE
 flob.file_id = p_file_id;

restab		CTX_DOC.highlight_tab;
l_file_data	BLOB;
l_data		VARCHAR2(32000);
l_amt		INTEGER;
l_document	CLOB;
l_file_content_type	VARCHAR2(256);
BEGIN


Open cur_attachment_file_data(p_file_id);
Fetch cur_attachment_file_data Into l_file_data,l_file_content_type;
Close cur_attachment_file_data;

IF (l_file_data is NOT NULL) AND (isValidForFilter(l_file_content_type))  THEN

l_data := l_data || l_newline||'<CONTENT_ATTACHMENT>';
l_amt := LENGTH(l_data);
dbms_lob.writeappend(p_clob, l_amt, l_data);

  -- Binary files get filtered as text file
  -- msword,pdf etc is converted to text format
  ctx_doc.policy_filter(policy_name  =>'IBC_Binary2Text_Filter'
                      ,document       =>l_file_data  -- Binary in from FND_LOBS
                      ,restab         =>l_document   -- Text out from Filter
                      ,plaintext      =>TRUE);

p_clob := p_clob || l_document;

l_data := '</CONTENT_ATTACHMENT>';
l_amt := LENGTH(l_data);
dbms_lob.writeappend(p_clob, l_amt, l_data);

END IF;

END Synthesize_Content_Attachments;


PROCEDURE Synthesize_Attribute_Bundles
( p_attribute_bundle_id IN     NUMBER,
  p_clob		IN OUT NOCOPY CLOB) IS

CURSOR cur_attribute_bundle(p_attribute_bundle_id IN NUMBER) IS
SELECT
    attribute_bundle_data
FROM
  IBC_ATTRIBUTE_BUNDLES att
WHERE
att.attribute_bundle_id = p_attribute_bundle_id;

l_attribute_data CLOB;
l_data VARCHAR2(32000);
l_amt INTEGER;
l_clean_xml_doc  CLOB;
l_clean_html_doc CLOB;

BEGIN

Open cur_attribute_bundle(p_attribute_bundle_id);
Fetch cur_attribute_bundle Into l_attribute_data;
Close cur_attribute_bundle;

IF l_attribute_data is NOT NULL THEN

l_data := l_data || l_newline||'<CONTENT_ATTRIBUTE_BUNDLE>';
l_amt := LENGTH(l_data);
dbms_lob.writeappend(p_clob, l_amt, l_data);

ctx_doc.policy_filter(policy_name  =>'IBC_XML_Policy'
                      ,document       =>l_attribute_data --l_file_data varvhar2,clob,blob
                      ,restab         =>l_clean_xml_doc
                      ,plaintext      =>TRUE);

l_clean_xml_doc := '<html>' || l_clean_xml_doc;

ctx_doc.policy_filter(policy_name  =>'IBC_HTML_Policy'
                      ,document       =>l_clean_xml_doc --l_file_data varvhar2,clob,blob
                      ,restab         =>l_clean_html_doc
                      ,plaintext      =>TRUE);

p_clob := p_clob || l_clean_html_doc;

l_data := l_newline|| '</CONTENT_ATTRIBUTE_BUNDLE>';
l_amt := LENGTH(l_data);
dbms_lob.writeappend(p_clob, l_amt, l_data);

END IF;

END Synthesize_Attribute_Bundles;

PROCEDURE Synthesize_Content_Keywords
  ( p_citem_version_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB) IS

CURSOR cur_content_keywords(p_citem_version_id IN NUMBER) IS
SELECT
  keyword
FROM
  IBC_CITEM_VERSIONS_B  cb,
  IBC_CITEM_KEYWORDS k
WHERE
 cb.citem_version_id = p_citem_version_id
AND  k.content_item_id = cb.content_item_id;

l_data VARCHAR2(32000);
l_amt INTEGER;

BEGIN

FOR cur_content_keywords_rec IN cur_content_keywords(p_citem_version_id)
LOOP
l_data := l_data || l_newline || cur_content_keywords_rec.keyword;
      l_amt := LENGTH(l_data);
      IF l_amt >= 31000 THEN
      	-- flush l_data to the p_clob
	  dbms_lob.writeappend(p_clob, l_amt, l_data);
	  l_data := l_newline;
      END IF;
END LOOP;

IF l_data is NOT NULL THEN
  l_data := l_newline||'<CONTENT_KEYWORDS>'|| l_data || '</CONTENT_KEYWORDS>';
  dbms_lob.writeappend(p_clob, LENGTH(l_data), l_data);
END IF;

END  Synthesize_Content_Keywords;

PROCEDURE Synthesize_Content_Renditions
  ( p_citem_version_id  IN     NUMBER,
    p_clob		IN OUT NOCOPY CLOB) IS

CURSOR cur_rend_data(p_citem_version_id IN NUMBER) IS
SELECT
  ren.citem_version_id,
  flob.file_data rendition_file_data,
  flob.file_name rendition_file_name,
  flob.file_content_type file_content_type
FROM
  IBC_RENDiTIONS ren,
  fnd_lobs flob
WHERE
ren.citem_version_id = p_citem_version_id
AND ren.file_id = flob.file_id
AND ren.LANGUAGE = USERENV('LANG');

l_data VARCHAR2(32000);
l_amt INTEGER;
l_rendition_file_name VARCHAR2(32000);
l_document	CLOB;

BEGIN

l_rendition_file_name := NULL;

l_data := l_data || l_newline||'<CONTENT_RENDITION>';
l_amt := LENGTH(l_data);
dbms_lob.writeappend(p_clob, l_amt, l_data);

FOR cur_rend_data_rec IN cur_rend_data(p_citem_version_id)
LOOP

IF (cur_rend_data_rec.rendition_file_data is NOT NULL) AND (isValidForFilter(cur_rend_data_rec.file_content_type))  THEN

  -- Binary files get filtered as text file
  -- msword,pdf etc is converted to text format
  ctx_doc.policy_filter(policy_name  =>'IBC_Binary2Text_Filter'
                      ,document       =>cur_rend_data_rec.rendition_file_data  -- Binary in from FND_LOBS
                      ,restab         =>l_document   -- Text out from Filter
                      ,plaintext      =>TRUE);

p_clob := p_clob || l_document;

END IF;

l_rendition_file_name := l_rendition_file_name || l_newline || cur_rend_data_rec.rendition_file_name;
      l_amt := LENGTH(l_rendition_file_name);
      IF l_amt >= 31000 THEN
      	-- flush l_rendition_file_name to the p_clob
	  dbms_lob.writeappend(p_clob, l_amt, l_rendition_file_name);
	  l_rendition_file_name := l_newline;
      END IF;
END LOOP;

IF p_clob IS NOT NULL THEN
	l_data := '</CONTENT_RENDITION>' || l_newline;
	l_amt := LENGTH(l_data);
	dbms_lob.writeappend(p_clob, l_amt, l_data);
END IF;

If  l_rendition_file_name IS NOT NULL THEN
	l_rendition_file_name := '<RENDITION_FILE_NAME>' || l_newline||l_rendition_file_name  ||'</RENDITION_FILE_NAME>';
	dbms_lob.writeappend(p_clob, LENGTH(l_rendition_file_name), l_rendition_file_name);
END IF;

END  Synthesize_Content_Renditions;

end ibc_content_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."IBC_CONTENT_CTX_PKG" TO "CTXSYS";
