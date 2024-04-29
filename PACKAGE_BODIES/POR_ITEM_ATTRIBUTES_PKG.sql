--------------------------------------------------------
--  DDL for Package Body POR_ITEM_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_ITEM_ATTRIBUTES_PKG" AS
/* $Header: PORATTRB.pls 120.0.12010000.6 2014/07/25 05:49:13 fenyan ship $ */



PROCEDURE Create_Attach_Item_Attr(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_req_header_id                NUMBER:='';
  l_progress                     VARCHAR2(300) := '000';
  l_doc_string varchar2(200);
  l_org_id     number;

BEGIN

    IF (funcmode='RUN') THEN
      l_progress := 'Create_Attach_Item_Attr: 001';
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

      -- Set the multi-org context

      l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'ORG_ID');

      IF l_org_id is NOT NULL THEN

        fnd_client_info.set_org_context(to_char(l_org_id));

      END IF;

      l_req_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      l_progress := 'Create_Attach_Item_Attr: 002 - ' ||
                    to_char(l_req_header_id);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

      add_attribute_attachment(l_req_header_id,
                               'AD_HOC_LOCATION',
                               33,
                               itemtype,
                               itemkey);

      l_progress := 'Create_Attach_Item_Attr: 005 - add_attr_attachment';
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      return;

    END IF; -- run mode
    l_progress := 'Create_Attach_Item_Attr: 999';
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    wf_core.context('POR_ITEM_ATTRIBUTES_PKG',
                    'Create_Attach_Item_Attr',
                    l_progress,sqlerrm);
    /* the api for the send_error_notif has been changed to include
    username and hence commenting out since this is only in the exception
      block. in a hurry to release patch and no time to figure out*/

    /*PO_REQAPPROVAL_INIT1.send_error_notif(itemType,
                                          itemkey,
                                          l_doc_string,
                                          sqlerrm,
                                          'Create_Attach_Item_Attr');*/
   RAISE;

END Create_Attach_Item_Attr;


/******************************************************************
 * Gets Requisition Lines that have associated adhoc data         *
 ******************************************************************/
PROCEDURE add_attribute_attachment(p_req_header_id IN NUMBER,
                                   p_item_type IN VARCHAR2,
                                   p_category_id IN NUMBER DEFAULT 33,
                                   p_wf_item_type IN VARCHAR2,
                                   p_wf_item_key IN VARCHAR2)

IS

  l_requisition_header_id NUMBER;
  l_requisition_line_id   NUMBER;
  l_text                  LONG := NULL;
  l_seq_num               NUMBER :=0;
  l_profile_value         VARCHAR2(255) := fnd_profile.value('POR_ONE_TIME_LOCATION');
  --l_template_name         VARCHAR2(255);
  l_file_name	          VARCHAR2(255) := '';
  l_created_by            NUMBER;
  l_progress              LONG :=NULL;
  l_attachment_id VARCHAR2(255);

  CURSOR c_req_id IS
    SELECT requisition_header_id,
           requisition_line_id,
           created_by
      FROM po_requisition_lines_all
     WHERE requisition_header_id = p_req_header_id;

BEGIN

  l_progress := 'add_attribute_attachment: 000';
  PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

  -- Bug 19221231: Not using l_template_name anymore.
  /*
  select hrtl2.location_code into l_template_name
  from hr_locations_all_tl hrtl1, hr_locations_all_tl hrtl2
  where hrtl1.location_id = hrtl2.location_id
  and hrtl2.language = userenv('LANG')
  and hrtl1.location_code = l_profile_value
  and hrtl1.language in
      ( select language_code
        FROM fnd_languages
        WHERE installed_flag in ( 'B', 'I'))
  and rownum = 1 ;
  */

  OPEN c_req_id;
  FETCH c_req_id
   INTO l_requisition_header_id,
        l_requisition_line_id,
        l_created_by;

  l_progress := 'add_attribute_attachment: 001 - ' ||
                ' req_header_id = ' || l_requisition_header_id ||
                ' req_line_id = ' || l_requisition_line_id ||
                ' created_by = ' || l_created_by;
  PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

  WHILE c_req_id%FOUND LOOP
    -- Get Max Sequence Number and add 10
    l_seq_num := 0;

    SELECT NVL(MAX(seq_num), 0)
    INTO l_seq_num
    FROM fnd_attached_documents
    WHERE pk1_value = to_char(l_requisition_line_id)
      AND entity_name = 'REQ_LINES';

    l_seq_num := l_seq_num + 10;

    l_progress := 'add_attribute_attachment: 002 - ' ||
                  ' l_seq_num = ' || l_seq_num;
    PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

    -- Run procedure to get concatenated text string
    get_attach_text(p_requisition_line_id   => l_requisition_line_id,
	            p_requisition_header_id => l_requisition_header_id,
                    p_item_type             => p_item_type,
                    p_text                  => l_text);

    l_progress := 'add_attribute_attachment: 003 - ' ||
                  ' l_text = ' || l_text;
    PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

    IF (l_text IS NOT NULL) THEN
      -- Run add_attachment API to add the attachment to FND tables
      -- datatype_id is 2 because fnd doesn't support short text in 10.7
      l_progress := 'add_attribute_attachment: 006 - One Time Address' ||-- l_template_name ||
                    ' l_seq_num = ' || l_seq_num ||
                    ' p_category_id = ' || p_category_id ||
                    ' l_file_name = ' || l_file_name ||
                    ' line_id = ' || l_requisition_line_id ||
                    ' l_created_by = ' || l_created_by;

      PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);


     begin

       select attached_document_id
       into l_attachment_id
       -- for bug 14537896
       from fnd_attached_documents fad,
            fnd_documents_tl fdt
       where pk1_value=to_char(l_requisition_line_id)
       --  and pk2_value='ONE_TIME_LOCATION';
       and fad.document_id = fdt.document_id
       and fad.entity_name='REQ_LINES'
       and fad.category_id=33
       and fdt.language = USERENV('LANG')
       and fdt.description like 'POR:%'
       and rownum=1;
       -- end for bug 14537896
       -- prefix document_description with POR: for autocreate to identifer
       -- this attachment as one time location.

      -- Bug 19221231: No matter what value of profile POR: One Time Location is, set the
      -- one time location attachment 's description as static 'POR:One Time Address' when call fnd api.
      fnd_webattch.update_attachment(
		seq_num			=> l_seq_num		,
		category_id		=> p_category_id	,
		document_description	=> 'POR:One Time Address',
		datatype_id		=> 2			,
		text			=> l_text		,
		file_name		=> l_file_name		,
		url			=> NULL			,
		function_name		=> 'PO_POXRQERQ'	,
		entity_name		=> 'REQ_LINES'		,
		pk1_value		=> l_requisition_line_id	,
		pk2_value		=> 'ONE_TIME_LOCATION'		,
		pk3_value		=> NULL		,
		pk4_value		=> NULL		,
		pk5_value		=> NULL		,
		media_id		=> NULL		,
		user_id			=> l_created_by ,
		ATTACHED_DOCUMENT_ID    => l_attachment_id);

      EXCEPTION
      WHEN NO_DATA_FOUND THEN

      fnd_webattch.add_attachment(
		seq_num			=> l_seq_num		,
		category_id		=> p_category_id	,
		document_description	=> 'POR:One Time Address',
		datatype_id		=> 2			,
		text			=> l_text		,
		file_name		=> l_file_name		,
		url			=> NULL			,
		function_name		=> 'PO_POXRQERQ'	,
		entity_name		=> 'REQ_LINES'		,
		pk1_value		=> l_requisition_line_id	,
		pk2_value		=> 'ONE_TIME_LOCATION'		,
		pk3_value		=> NULL		,
		pk4_value		=> NULL		,
		pk5_value		=> NULL		,
		media_id		=> NULL		,
		user_id			=> l_created_by);
     end;

    END IF;

    FETCH c_req_id
     INTO l_requisition_header_id,
          l_requisition_line_id,
          l_created_by;

    l_progress := 'add_attribute_attachment: 004 - ' ||
                  ' req_header_id = ' || l_requisition_header_id ||
                  ' req_line_id = ' || l_requisition_line_id ||
                  ' created_by = ' || l_created_by;
    PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

  END LOOP;
  CLOSE c_req_id;

EXCEPTION
  when others then
    l_progress := 'add_attribute_attachment: 005 - ' ||
                  'exception';
    PO_WF_DEBUG_PKG.insert_debug(p_wf_item_type,p_wf_item_key,l_progress);

END add_attribute_attachment;


/******************************************************************
 * Concatenate all attribute codes and values into a text value   *
 * for an associated Requisition Line.                            *
 ******************************************************************/
PROCEDURE get_attach_text(p_requisition_line_id   IN NUMBER,
                          p_requisition_header_id IN NUMBER,
                          p_item_type             IN VARCHAR2,
                          p_text 		  OUT NOCOPY LONG)
IS

  l_text LONG := NULL;
  l_a1   VARCHAR2(240);
  l_a2   VARCHAR2(240);
  l_a3   VARCHAR2(240);
  l_a4   VARCHAR2(240);
  l_a5   VARCHAR2(240);
  l_a6   VARCHAR2(240);
  l_a7   VARCHAR2(240);
  l_a8   VARCHAR2(240);
  l_a9   VARCHAR2(240);
  l_a10   VARCHAR2(240);
  l_a11   VARCHAR2(240);
  l_a12   VARCHAR2(240);
  l_a13   VARCHAR2(240);
  l_a14   VARCHAR2(240);
  l_a15   VARCHAR2(240);

BEGIN

  SELECT attribute1,
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
         attribute15
    INTO l_a1, l_a2, l_a3, l_a4, l_a5,
         l_a6, l_a7, l_a8, l_a9, l_a10,
         l_a11, l_a12, l_a13, l_a14, l_a15
    FROM por_item_attribute_values
   WHERE item_type = p_item_type
     AND requisition_header_id = p_requisition_header_id
     AND requisition_line_id = p_requisition_line_id;

 /* 2977976. l_text should be appended only if the the variables
             l_a1 .. l_a15 is not null.
             This is done to avoid insertion of unnecessary
             line feeds in the attachments even when the values are
             null. These line feeds in the attachment was causing
             blank lines to be printed in Printed Purchase Order report
*/

 l_text := append_if_not_null(l_text,l_a1,l_a2,l_a3,l_a4,l_a5,
                                     l_a6,l_a7,l_a8,l_a9,l_a10,
                                     l_a11,l_a12,l_a13,l_a14,l_a15);

 p_text := l_text;

EXCEPTION

  when NO_DATA_FOUND then
    p_text := NULL;

END get_attach_text;

/* 2977976
   Appends the variables m_a1 to m_a15 to the existing text
   if  existing_text is not null */
function append_if_not_null(existing_text IN long,
                            m_a1 IN varchar2,
                            m_a2 IN varchar2,
                            m_a3 IN varchar2,
                            m_a4 IN varchar2,
                            m_a5 IN varchar2,
                            m_a6 IN varchar2,
                            m_a7 IN varchar2,
                            m_a8 IN varchar2,
                            m_a9 IN varchar2,
                            m_a10 IN varchar2,
                            m_a11 IN varchar2,
                            m_a12 IN varchar2,
                            m_a13 IN varchar2,
                            m_a14 IN varchar2,
                            m_a15 IN varchar2)
return long
IS
m_existing_text long :=existing_text;
begin
if (m_a1 is not null ) then
 m_existing_text := m_existing_text ||  m_a1 || fnd_global.local_chr(10);
end if;

if (m_a2 is not null ) then
 m_existing_text := m_existing_text ||  m_a2 || fnd_global.local_chr(10);
end if;

if (m_a3 is not null ) then
 m_existing_text := m_existing_text ||  m_a3 || fnd_global.local_chr(10);
end if;

if (m_a4 is not null ) then
 m_existing_text := m_existing_text ||  m_a4 || fnd_global.local_chr(10);
end if;

if (m_a5 is not null ) then
 m_existing_text :=m_existing_text ||  m_a5 || fnd_global.local_chr(10);
end if;

if (m_a6 is not null ) then
 m_existing_text :=m_existing_text ||  m_a6 || fnd_global.local_chr(10);
end if;

if (m_a7 is not null ) then
 m_existing_text :=m_existing_text ||  m_a7 || fnd_global.local_chr(10);
end if;

if (m_a8 is not null ) then
 m_existing_text :=m_existing_text ||  m_a8 || fnd_global.local_chr(10);
end if;

if (m_a9 is not null ) then
 m_existing_text :=m_existing_text ||  m_a9 || fnd_global.local_chr(10);
end if;

if (m_a10 is not null ) then
 m_existing_text :=m_existing_text ||  m_a10 || fnd_global.local_chr(10);
end if;

if (m_a11 is not null ) then
 m_existing_text :=m_existing_text ||  m_a11 || fnd_global.local_chr(10);
end if;

if (m_a12 is not null ) then
 m_existing_text :=m_existing_text ||  m_a12 || fnd_global.local_chr(10);
end if;

if (m_a13 is not null ) then
 m_existing_text :=m_existing_text ||  m_a13 || fnd_global.local_chr(10);
end if;

if (m_a14 is not null ) then
 m_existing_text :=m_existing_text ||  m_a14 || fnd_global.local_chr(10);
end if;

if (m_a15 is not null ) then
 m_existing_text :=m_existing_text ||  m_a15 || fnd_global.local_chr(10);
end if;

return m_existing_text;

end append_if_not_null;



END POR_ITEM_ATTRIBUTES_PKG;

/
