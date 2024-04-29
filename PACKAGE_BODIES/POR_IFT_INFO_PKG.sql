--------------------------------------------------------
--  DDL for Package Body POR_IFT_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_IFT_INFO_PKG" AS
/* $Header: PORIFTB.pls 120.1.12010000.2 2011/12/20 09:46:44 krsethur ship $ */

/******************************************************************
 * Concatenate all attribute codes and values into a text value for an associated *
 * Requisition Line.                                                                                              *
 ******************************************************************/
PROCEDURE get_attach_text(
		p_requisition_line_id 	IN NUMBER,
                p_preparer_language     IN VARCHAR2,
		p_to_supplier_text      OUT NOCOPY LONG,
                p_to_supplier_name      OUT NOCOPY VARCHAR2,
                p_to_buyer_text         OUT NOCOPY LONG,
                p_to_buyer_name         OUT NOCOPY VARCHAR2) IS

    l_to_supplier_text LONG := NULL;
    l_to_buyer_text LONG := NULL;
    l_to_supplier_name VARCHAR2(240) :=NULL;
    l_to_buyer_name VARCHAR2(240) :=NULL;
    l_newline varchar2(10) := '
';

    -- cursor to get all info template attribute information
    -- input parameter: attachment category id
    CURSOR c_attributes (p_category_id IN NUMBER) IS
      SELECT	ATT.DESCRIPTION,
               decode(ATB.FLEX_VALUE_SET_ID, null, INFO.ATTRIBUTE_VALUE,
                 (select VTL.FLEX_VALUE_MEANING
                  from FND_FLEX_VALUES VAL,
                       FND_FLEX_VALUES_TL VTL
                 where INFO.ATTRIBUTE_VALUE = VAL.FLEX_VALUE
                   AND VAL.FLEX_VALUE_SET_ID = ATB.FLEX_VALUE_SET_ID
                   AND VAL.FLEX_VALUE_ID = VTL.FLEX_VALUE_ID
                   AND VTL.LANGUAGE = NVL(p_preparer_language, USERENV('LANG')))) value,
              TMPT.TEMPLATE_NAME
      FROM 	  POR_TEMPLATE_INFO 		INFO,
              POR_TEMPLATES_ALL_B 		TMPB,
              POR_TEMPLATES_ALL_TL		TMPT,
              POR_TEMPLATE_ATTRIBUTES_B 	ATB,
              POR_TEMPLATE_ATTRIBUTES_TL 	ATT
      WHERE 	INFO.REQUISITION_LINE_ID = p_requisition_line_id
      AND	    INFO.ATTRIBUTE_CODE  = ATB.ATTRIBUTE_CODE
      AND	    TMPB.ATTACHMENT_CATEGORY_ID = p_category_id
      AND	    TMPB.TEMPLATE_CODE = TMPT.TEMPLATE_CODE
      AND	    TMPT.LANGUAGE = NVL(p_preparer_language, USERENV('LANG'))
      AND	    TMPB.TEMPLATE_CODE = ATB.TEMPLATE_CODE
      AND	    ATB.ATTRIBUTE_CODE = ATT.ATTRIBUTE_CODE
      AND	    ATT.LANGUAGE = NVL(p_preparer_language, USERENV('LANG'))
      ORDER BY
              TMPB.TEMPLATE_CODE, ATB.SEQUENCE;

BEGIN
  -- Get 'To Supplier' attachment text and name
  FOR c_att_cur IN c_attributes(33) LOOP
    IF l_to_supplier_text IS NULL then
      l_to_supplier_text := c_att_cur.description|| '=' || c_att_cur.value;
      l_to_supplier_name := c_att_cur.template_name;
    ELSE
      l_to_supplier_text := l_to_supplier_text || l_newline || c_att_cur.description|| '=' || c_att_cur.value;
      IF(l_to_supplier_name <> c_att_cur.template_name)
      THEN
        l_to_supplier_name := fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE_TEMPLATES');
      END IF;
    END IF;
  END LOOP;

  p_to_supplier_text := l_to_supplier_text;
  p_to_supplier_name := l_to_supplier_name;

  -- Get 'To Buyer' attachment text and name
  FOR c_att_cur IN c_attributes(34) LOOP
    IF l_to_buyer_text IS NULL then
      l_to_buyer_text := c_att_cur.description|| '=' || c_att_cur.value;
      l_to_buyer_name := c_att_cur.template_name;
    ELSE
      l_to_buyer_text := l_to_buyer_text || l_newline || c_att_cur.description|| '=' || c_att_cur.value;
      IF(l_to_buyer_name <> c_att_cur.template_name)
      THEN
        l_to_buyer_name := fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE_TEMPLATES');
      END IF;
    END IF;
  END LOOP;

  p_to_buyer_text := l_to_buyer_text;
  p_to_buyer_name := l_to_buyer_name;

END get_attach_text;

/******************************************************************
 * Gets Requisition Lines that have associated info template data *
 ******************************************************************/
PROCEDURE add_info_template_attachment(
		p_req_header_id	      IN NUMBER,
                p_category_id         IN NUMBER DEFAULT 33,
                p_preparer_language   IN VARCHAR2)

IS

  l_to_supplier_text LONG := NULL;
  l_to_buyer_text LONG := NULL;
  l_file_name	VARCHAR2(255) := '';
  l_seq_num NUMBER :=0;
  l_to_supplier_name VARCHAR2(255);
  l_to_buyer_name VARCHAR2(255);
  l_attachment_id VARCHAR2(255);
  l_datatype_id number;

  -- cursor to retrieve requisition line id for a particular req header
  CURSOR c_req_id IS
  SELECT porl.requisition_header_id,
         porl.requisition_line_id,
	 NVL(MAX(porl.created_by), 1) AS created_by
  FROM por_template_info pti,
       po_requisition_lines_all porl
  WHERE porl.requisition_header_id = p_req_header_id
  AND   porl.requisition_line_id = pti.requisition_line_id
  GROUP BY porl.requisition_header_id,
           porl.requisition_line_id;
BEGIN
  FOR c_req_id_cur in c_req_id
  LOOP

    -- Get 'To Supplier' attachment text and name
    get_attach_text(
		p_requisition_line_id  => c_req_id_cur.requisition_line_id,
 		p_preparer_language    => p_preparer_language,
		p_to_supplier_text     => l_to_supplier_text,
                p_to_supplier_name     => l_to_supplier_name,
                p_to_buyer_text        => l_to_buyer_text,
                p_to_buyer_name        => l_to_buyer_name);

    IF l_to_supplier_name is not null
    THEN
      BEGIN
        -- update existing attachment
        select  attach.attached_document_id,attach.seq_num
        into    l_attachment_id,l_seq_num      --Get l_seq_num to pass it to update_attachment 2451462.
        from    fnd_attached_documents attach, fnd_documents doc
        where   attach.document_id = doc.document_id
        and     doc.category_id = 33
        and     attach.entity_name = 'REQ_LINES'
        and     attach.pk1_value=to_char(c_req_id_cur.requisition_line_id)
        and     attach.pk2_value='INFO_TEMPLATE';

        if(lengthb(l_to_supplier_text) <4000) then
          l_datatype_id := 1;
        else
          l_datatype_id := 2;
        end if;

        fnd_webattch.update_attachment(
        seq_num			=> l_seq_num		,
        category_id		=> 33	, -- to supplier
        document_description	=> l_to_supplier_name	,
        datatype_id		=> l_datatype_id			,
        text			=> l_to_supplier_text		,
        file_name		=> l_file_name		,
        url			=> NULL			,
        function_name		=> 'PO_POXRQERQ'	,
        entity_name		=> 'REQ_LINES'		,
        pk1_value		=> to_char(c_req_id_cur.requisition_line_id)	,
        pk2_value		=> 'INFO_TEMPLATE'	,
        pk3_value		=> NULL		,
        pk4_value		=> NULL		,
        pk5_value		=> NULL		,
        media_id		=> NULL		,
        user_id			=> c_req_id_cur.created_by ,
        ATTACHED_DOCUMENT_ID    => l_attachment_id);

      EXCEPTION
        -- insert new attachment
        WHEN NO_DATA_FOUND THEN
          l_seq_num := 0;

          SELECT MAX(seq_num)
          INTO l_seq_num
          FROM fnd_attached_documents
          WHERE pk1_value = to_char(c_req_id_cur.requisition_line_id)
          AND   entity_name = 'REQ_LINES';

          IF l_seq_num is null THEN
            l_seq_num := 10;
          ELSE
            l_seq_num := l_seq_num + 10;
          END IF;

          if(lengthb(l_to_supplier_text) <4000) then
            l_datatype_id := 1;
          else
            l_datatype_id := 2;
          end if;


          fnd_webattch.add_attachment(
          seq_num			=> l_seq_num		,
          category_id		=> 33	,
          document_description	=> l_to_supplier_name	,
          datatype_id		=> l_datatype_id ,
          text			=> l_to_supplier_text		,
          file_name		=> l_file_name		,
          url			=> NULL			,
          function_name		=> 'PO_POXRQERQ'	,
          entity_name		=> 'REQ_LINES'		,
          pk1_value		=> to_char(c_req_id_cur.requisition_line_id)	,
          pk2_value		=> 'INFO_TEMPLATE'	,
          pk3_value		=> NULL		,
          pk4_value		=> NULL		,
          pk5_value		=> NULL		,
          media_id		=> NULL		,
          user_id			=> c_req_id_cur.created_by);
      END;
    END IF;

    IF l_to_buyer_name is not null
    THEN
      BEGIN
        -- update existing attachment
        select  attach.attached_document_id,attach.seq_num
        into    l_attachment_id,l_seq_num      --Get l_seq_num to pass it to update_attachment 2451462.
        from    fnd_attached_documents attach, fnd_documents doc
        where   attach.document_id = doc.document_id
        and     doc.category_id = 34 -- to buyer
        and     attach.entity_name = 'REQ_LINES'
        and     attach.pk1_value=to_char(c_req_id_cur.requisition_line_id)
        and     attach.pk2_value='INFO_TEMPLATE';

        if(lengthb(l_to_buyer_text) <4000) then
          l_datatype_id := 1;
        else
          l_datatype_id := 2;
        end if;

        fnd_webattch.update_attachment(
        seq_num			=> l_seq_num		,
        category_id		=> 34	,
        document_description	=> l_to_buyer_name	,
        datatype_id		=> l_datatype_id,
        text			=> l_to_buyer_text		,
        file_name		=> l_file_name		,
        url			=> NULL			,
        function_name		=> 'PO_POXRQERQ'	,
        entity_name		=> 'REQ_LINES'		,
        pk1_value		=> to_char(c_req_id_cur.requisition_line_id)	,
        pk2_value		=> 'INFO_TEMPLATE'	,
        pk3_value		=> NULL		,
        pk4_value		=> NULL		,
        pk5_value		=> NULL		,
        media_id		=> NULL		,
        user_id			=> c_req_id_cur.created_by ,
        ATTACHED_DOCUMENT_ID    => l_attachment_id);

      EXCEPTION
        -- insert new attachment
        WHEN NO_DATA_FOUND THEN
          l_seq_num := 0;

          SELECT MAX(seq_num)
          INTO l_seq_num
          FROM fnd_attached_documents
          WHERE pk1_value = to_char(c_req_id_cur.requisition_line_id)
          AND   entity_name = 'REQ_LINES';

          IF l_seq_num is null THEN
            l_seq_num := 10;
          ELSE
            l_seq_num := l_seq_num + 10;
          END IF;

          if(lengthb(l_to_buyer_text) <4000) then
            l_datatype_id := 1;
          else
            l_datatype_id := 2;
          end if;


          fnd_webattch.add_attachment(
          seq_num			=> l_seq_num		,
          category_id		=> 34	,
          document_description	=> l_to_buyer_name	,
          datatype_id		=> 	l_datatype_id		,
          text			=> l_to_buyer_text		,
          file_name		=> l_file_name		,
          url			=> NULL			,
          function_name		=> 'PO_POXRQERQ'	,
          entity_name		=> 'REQ_LINES'		,
          pk1_value		=> to_char(c_req_id_cur.requisition_line_id)	,
          pk2_value		=> 'INFO_TEMPLATE'	,
          pk3_value		=> NULL		,
          pk4_value		=> NULL		,
          pk5_value		=> NULL		,
          media_id		=> NULL		,
          user_id			=> c_req_id_cur.created_by);
      END;
    END IF;
  END LOOP;
END add_info_template_attachment;

END por_ift_info_pkg;

/
