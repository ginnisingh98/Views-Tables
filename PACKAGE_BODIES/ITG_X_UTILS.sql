--------------------------------------------------------
--  DDL for Package Body ITG_X_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_X_UTILS" AS
/* $Header: itgxutlb.pls 120.6 2006/06/13 12:07:17 bsaratna noship $ */

   g_cbod_desc VARCHAR2(2000);


  /*
  ** Given an Address Style, return the Region with the
  ** County name or equivalent
  */
  FUNCTION getCounty (
    addrStyle IN  Varchar2,
    regionOne IN  Varchar2,
    regionTwo IN  Varchar2
  ) return varchar2 as
  BEGIN
    IF    addrStyle IS NULL THEN
      RETURN NULL;
    ELSIF addrStyle = 'GB'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'US'  THEN
      RETURN regionOne;
    ELSE
      RETURN NULL;
    END IF;
  END getCounty;

/* Checks  given poline has any approved schedule lines */

  FUNCTION isPoLineApproved(v_po_line_id in Number)
    RETURN NUMBER as
    CURSOR getPoLineApproval IS SELECT COUNT(*)
        FROM po_line_locations_all
                WHERE po_line_id=v_po_line_id and approved_flag='Y';

     returnvalue number(10);
  BEGIN
    open getPoLineApproval;
    fetch getPoLineApproval into returnvalue;
    close getPoLineApproval;
    return (returnvalue);
  END;
  /*
  ** Gets the fnd_id_flex_segments.application_column_name that is the
  ** qualifier provided for the chart structure provided.  This is used in
  ** the object view definitions (e.g., SYNC_COA and SYNC_PO) for outbound.
  */
  function getFlexQualifierSegment (
    p_idFlexNum         number,
    p_flexQualifierName varchar2
  ) return varchar2 as
    cursor getAppColName is
      SELECT s.application_column_name
        FROM fnd_id_flex_segments s,
             fnd_segment_attribute_values sav,
             fnd_segment_attribute_types sat
       WHERE s.application_id           = sav.application_id
         AND s.id_flex_code             = sav.id_flex_code
         AND s.id_flex_num              = sav.id_flex_num
         AND s.enabled_flag             = 'Y'
         AND s.application_column_name  = sav.application_column_name
         AND sav.application_id         = sat.application_id
         AND sav.id_flex_code           = sat.id_flex_code
         AND sav.id_flex_num            = p_idFlexNum
         AND sav.attribute_value        = 'Y'
         AND sav.segment_attribute_type = sat.segment_attribute_type
         AND sat.application_id         = 101
         AND sat.id_flex_code           = 'GL#'
         AND sat.unique_flag            = 'Y'
         AND sat.segment_attribute_type = p_flexQualifierName;
    returnValue varchar2(30);
  begin
    open getAppColName;
    fetch getAppColName into returnValue;
    close getAppColName;
    RETURN (returnValue);
  end getFlexQualifierSegment;

  /*
  ** get_inventory_org_id is used to get the inventory_organization_id
  ** given the org_id using the financials_system_params_all table
  */
  FUNCTION get_inventory_org_id (p_org_id NUMBER)
  RETURN NUMBER AS
    CURSOR cur_fin_system_params IS
      SELECT inventory_organization_id
        FROM financials_system_params_all
       WHERE org_id=p_org_id;
     v_inv_org  financials_system_params_all.inventory_organization_id%TYPE;
  BEGIN
    OPEN cur_fin_system_params;
    FETCH cur_fin_system_params INTO v_inv_org;
    CLOSE cur_fin_system_params;
    RETURN v_inv_org;
  END get_inventory_org_id;

  /*
  ** Return the distinct po_requisition_headers_all.segment1 for the
  ** po_distributions_all.po_req_distribution_id.  If segment1 is not
  ** distinct for the input value, the first value selected is returned.
  */
  FUNCTION getRequistnid ( poReqDistId IN Number )
    RETURN varchar2 AS
  returnValue po_requisition_headers_all.segment1%TYPE;
  CURSOR getSegment1 IS
    SELECT reqHead.segment1
      FROM po_requisition_headers_all reqHead,
           po_requisition_lines_all   reqLine,
           po_req_distributions_all   reqDist
     WHERE reqHead.requisition_header_id    = reqLine.requisition_header_id
       AND reqLine.requisition_line_id      = reqDist.requisition_line_id
       AND reqDist.distribution_id          = poReqDistId;
  BEGIN
    IF poReqDistId IS NOT NULL THEN
      OPEN getSegment1;
      FETCH getSegment1 Into returnValue;
      CLOSE getSegment1;
    END IF;
    RETURN returnValue;
  END getRequistnid;

  /*
  ** Given a po_req_distribution_id, return the line_num from po_requisition_lines_all
  */
  function getReqLineNum ( poReqDistId IN Number )
    RETURN varchar2 AS
  returnValue                         po_requisition_headers_all.segment1%TYPE;
  CURSOR getLineNum IS
    SELECT reqLine.line_num
     FROM po_requisition_lines_all    reqLine,
          po_req_distributions_all    reqDist
    WHERE reqLine.requisition_line_id = reqDist.requisition_line_id
      AND reqDist.distribution_id     = poReqDistId;
  BEGIN
    IF poReqDistId IS NOT NULL THEN
      OPEN getLineNum;
      FETCH getLineNum INTO returnValue;
      CLOSE getLineNum;
    END IF;
    RETURN returnValue;
  END getReqLineNum;

  /*
  ** Given an Address Style, return the Region with the
  ** State/Province name or equivalent
  */
  FUNCTION getState (
    addrStyle IN  VARCHAR2,
    regionOne IN  VARCHAR2,
    regionTwo IN  VARCHAR2
  ) RETURN VARCHAR2 AS
  BEGIN
    IF    addrStyle IS NULL THEN
      RETURN NULL;
    ELSIF addrStyle = 'AU'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'BR'  THEN
      RETURN regionTwo;
    ELSIF addrStyle = 'CA'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'IT'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'MX'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'PT'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'ES'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'CH'  THEN
      RETURN regionOne;
    ELSIF addrStyle = 'US'  THEN
      RETURN regionTwo;
    ELSE
      RETURN NULL;
    END IF;
  END getState;

  /*
  ** getTaxId looks up a TIN or VRN for a given US or non-US
  ** company.  Returns a NULL if no ID number found.
  */
  FUNCTION getTaxId (
    country    IN varchar2,
    orgId      IN number,
    orgName    IN varchar2,
    orgUnit    IN number,
    invOrg     IN number
  ) RETURN VARCHAR2 AS
    CURSOR getTIN IS
      SELECT ap.tax_identification_num, ap.entity_name
      FROM ap_reporting_entities_all    ap,
           hr_all_organization_units    unit
      WHERE ap.location_id              = unit.location_id
      AND   ap.org_id                   = orgId
      AND   unit.organization_id        = orgUnit;
    CURSOR getVRN IS
      SELECT fsp.vat_registration_num
      FROM financials_system_params_all fsp,
           inv_organization_info_v org -- Modified for performance bug#4941286
      WHERE fsp.set_of_books_id = org.set_of_books_id
      AND   org.organization_id = invOrg;
    taxId varchar2(100);
  BEGIN
    IF country IS NULL THEN
      taxId := null;
    ELSIF UPPER(country) = 'US' THEN
      FOR r IN getTIN LOOP
        IF upper(r.entity_name) = upper(orgName) THEN
          taxId := r.tax_identification_num;
          EXIT;
        ELSIF getTIN%ROWCOUNT = 1 THEN
          taxId := r.tax_identification_num;
        END IF;
      END LOOP;
    ELSE
      OPEN getVRN;
      FETCH getVRN INTO taxId;
      CLOSE getVRN;
    END IF;
    RETURN taxId;
  END getTaxId;

  /*
  ** Return a concatenated segment string with
  ** appropriate delimiter for the given flexfield
  */
  FUNCTION SegString (
    appId     IN NUMBER,
    flexCode  IN VARCHAR2,
    flexNum   IN NUMBER,
    segment1  IN VARCHAR2,         segment2  IN VARCHAR2,
    segment3  IN VARCHAR2,         segment4  IN VARCHAR2 := NULL,
    segment5  IN VARCHAR2 := NULL, segment6  IN VARCHAR2 := NULL,
    segment7  IN VARCHAR2 := NULL, segment8  IN VARCHAR2 := NULL,
    segment9  IN VARCHAR2 := NULL, segment10 IN VARCHAR2 := NULL,
    segment11 IN VARCHAR2 := NULL, segment12 IN VARCHAR2 := NULL,
    segment13 IN VARCHAR2 := NULL, segment14 IN VARCHAR2 := NULL,
    segment15 IN VARCHAR2 := NULL, segment16 IN VARCHAR2 := NULL,
    segment17 IN VARCHAR2 := NULL, segment18 IN VARCHAR2 := NULL,
    segment19 IN VARCHAR2 := NULL, segment20 IN VARCHAR2 := NULL,
    segment21 IN VARCHAR2 := NULL, segment22 IN VARCHAR2 := NULL,
    segment23 IN VARCHAR2 := NULL, segment24 IN VARCHAR2 := NULL,
    segment25 IN VARCHAR2 := NULL, segment26 IN VARCHAR2 := NULL,
    segment27 IN VARCHAR2 := NULL, segment28 IN VARCHAR2 := NULL,
    segment29 IN VARCHAR2 := NULL, segment30 IN VARCHAR2 := NULL
  ) RETURN varchar2 AS
    l_flexNum fnd_id_flex_structures.id_flex_num%TYPE := flexNum;
    CURSOR getFlexNum IS
      SELECT id_flex_num
      FROM fnd_id_flex_structures
      WHERE application_id = appId
      AND   id_flex_code   = flexCode
      AND   enabled_flag   = 'Y';
    delim fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
    CURSOR getFlexDelimiter is
      SELECT concatenated_segment_delimiter
      FROM fnd_id_flex_structures
      WHERE application_id = appId
      AND   id_flex_code   = flexCode
      AND   id_flex_num    = l_flexNum
      AND   enabled_flag   = 'Y';
    CURSOR getFlexSegs is
      SELECT application_column_name col
      FROM fnd_id_flex_segments s
      WHERE application_id = appId
      AND   id_flex_code   = flexCode
      AND   id_flex_num    = l_flexNum
      AND   enabled_flag   = 'Y'
      ORDER BY segment_num;
    segStr Varchar2(512);
  BEGIN
    /* If the flexNum is null look it up */
    IF l_flexNum IS NULL THEN
      FOR r IN getFlexNum LOOP
        IF getFlexNum%ROWCOUNT > 1 THEN
          /* Must be one and only one enabled
           * structure when the flexNum param is null
           */
          l_flexNum := NULL;
          EXIT;
        ELSE
          l_flexNum := r.id_flex_num;
        END IF;
      END LOOP;
    END IF;
    /* Get the concatenated segs */
    IF l_flexNum is not NULL THEN
      /* Get the flexfield delimiter */
      OPEN getFlexDelimiter;
      FETCH getFlexDelimiter INTO delim;
      CLOSE getFlexDelimiter;
      IF delim IS NOT NULL THEN
        /* Construct the contcatenated string */
        FOR s IN getFlexSegs LOOP
          IF    s.col = 'SEGMENT1'  THEN segStr := segStr||delim||segment1;
          ELSIF s.col = 'SEGMENT2'  THEN segStr := segStr||delim||segment2;
          ELSIF s.col = 'SEGMENT3'  THEN segStr := segStr||delim||segment3;
          ELSIF s.col = 'SEGMENT4'  THEN segStr := segStr||delim||segment4;
          ELSIF s.col = 'SEGMENT5'  THEN segStr := segStr||delim||segment5;
          ELSIF s.col = 'SEGMENT6'  THEN segStr := segStr||delim||segment6;
          ELSIF s.col = 'SEGMENT7'  THEN segStr := segStr||delim||segment7;
          ELSIF s.col = 'SEGMENT8'  THEN segStr := segStr||delim||segment8;
          ELSIF s.col = 'SEGMENT9'  THEN segStr := segStr||delim||segment9;
          ELSIF s.col = 'SEGMENT10' THEN segStr := segStr||delim||segment10;
          ELSIF s.col = 'SEGMENT11' THEN segStr := segStr||delim||segment11;
          ELSIF s.col = 'SEGMENT12' THEN segStr := segStr||delim||segment12;
          ELSIF s.col = 'SEGMENT13' THEN segStr := segStr||delim||segment13;
          ELSIF s.col = 'SEGMENT14' THEN segStr := segStr||delim||segment14;
          ELSIF s.col = 'SEGMENT15' THEN segStr := segStr||delim||segment15;
          ELSIF s.col = 'SEGMENT16' THEN segStr := segStr||delim||segment16;
          ELSIF s.col = 'SEGMENT17' THEN segStr := segStr||delim||segment17;
          ELSIF s.col = 'SEGMENT18' THEN segStr := segStr||delim||segment18;
          ELSIF s.col = 'SEGMENT19' THEN segStr := segStr||delim||segment19;
          ELSIF s.col = 'SEGMENT20' THEN segStr := segStr||delim||segment20;
          ELSIF s.col = 'SEGMENT21' THEN segStr := segStr||delim||segment21;
          ELSIF s.col = 'SEGMENT22' THEN segStr := segStr||delim||segment22;
          ELSIF s.col = 'SEGMENT23' THEN segStr := segStr||delim||segment23;
          ELSIF s.col = 'SEGMENT24' THEN segStr := segStr||delim||segment24;
          ELSIF s.col = 'SEGMENT25' THEN segStr := segStr||delim||segment25;
          ELSIF s.col = 'SEGMENT26' THEN segStr := segStr||delim||segment26;
          ELSIF s.col = 'SEGMENT27' THEN segStr := segStr||delim||segment27;
          ELSIF s.col = 'SEGMENT28' THEN segStr := segStr||delim||segment28;
          ELSIF s.col = 'SEGMENT29' THEN segStr := segStr||delim||segment29;
          ELSIF s.col = 'SEGMENT30' THEN segStr := segStr||delim||segment30;
          END IF;
        END LOOP;
        segStr := substr( segStr, 2 );
      END IF;
    END IF;
    RETURN segStr;
  END SegString;

  /*
  ** Returns the sign of a number
  */
  FUNCTION signOf ( anyNumber IN Number ) return varchar2 is
  BEGIN
    IF anyNumber IS NULL THEN
      RETURN '';
    ELSIF anyNumber < 0 THEN
      RETURN '-';
    ELSE
      RETURN '+';
    END IF;
  END signOf;

  /*
  ** sumPoLineLocs summarizes the quantity*price_override
  ** from po_line_locations_all for the given po_header_id
  **
  ** Taken from Po_Ip_Oagxml_Pkg.
  */
  FUNCTION sumPoLineLocs (
    poHeaderId IN NUMBER,
    poRelease  IN NUMBER := NULL
  ) RETURN NUMBER as
    returnValue NUMBER := 0;
    CURSOR sumValue IS
      SELECT sum( quantity * price_override )
        FROM po_line_locations_all
       WHERE po_header_id = poHeaderId;
    CURSOR sumValueRel IS
      SELECT sum( quantity * price_override )
        FROM po_line_locations_all
       WHERE po_header_id  = poHeaderId
         AND po_release_id = poRelease;
  BEGIN
    IF poHeaderId IS NOT NULL THEN
      IF poRelease IS NULL THEN
        Open sumValue;
        Fetch sumValue INTO returnValue;
        Close sumValue;
      ELSE
        OPEN sumValueRel;
        FETCH sumValueRel into returnValue;
        CLOSE sumValueRel;
      END IF;
    END IF;
    RETURN returnValue;
  END sumPoLineLocs;

  FUNCTION sumReqLines (
    reqHeaderId IN NUMBER
  ) RETURN NUMBER AS
    returnValue NUMBER := 0;
    CURSOR sumValue IS
      SELECT sum( quantity * unit_price )
      FROM po_requisition_lines_all
      WHERE requisition_header_id = reqHeaderId;
  BEGIN
    IF reqHeaderId IS NOT NULL THEN
      OPEN sumValue;
      FETCH sumValue INTO returnValue;
      CLOSE sumValue;
    END IF;
    RETURN returnValue;
  END sumReqLines;

  FUNCTION getAttachments(p_table_name VARCHAR2,
                          p_type       VARCHAR2,
                          p_id         NUMBER
  ) RETURN VARCHAR2 AS
    v_text fnd_documents_short_text.short_text%TYPE;
    CURSOR cur_short_text IS
      SELECT short.short_text FROM
        fnd_attached_documents fad,
        fnd_documents_vl fdv,
        fnd_document_entities fde,
        fnd_document_categories_vl fdcv,
        fnd_documents_short_text short
      WHERE
        fad.document_id = fdv.document_id AND
        short.media_id  = fdv.media_id AND
        fad.entity_name = fde.entity_name AND
        fdcv.category_id = fdv.category_id AND
        fde.data_object_code  = p_table_name  AND
        fad.pk1_value   = p_id          AND
        fdcv.name       = p_type
        order by short.media_id;
  BEGIN
    OPEN cur_short_text;
    LOOP
      FETCH cur_short_text INTO v_text;
      EXIT WHEN   cur_short_text%NOTFOUND;
    END LOOP;
    RETURN v_text;
  END;

  PROCEDURE getTextAttachments(p_table_name VARCHAR2,
                           p_id         NUMBER,
                                   x_pointernal OUT NOCOPY VARCHAR2,
                           x_misc       OUT NOCOPY VARCHAR2,
                           x_approver   OUT NOCOPY VARCHAR2,
                           x_buyer      OUT NOCOPY VARCHAR2,
                           x_payables   OUT NOCOPY VARCHAR2,
                           x_reciever   OUT NOCOPY VARCHAR2,
                           x_vendor     OUT NOCOPY VARCHAR2

  ) IS

     TYPE attch_tab_type IS TABLE OF VARCHAR2(4000) INDEX BY varchar2(30);

      attch_tab attch_tab_type;
        l_text VARCHAR2(4000);
        l_type VARCHAR2(60);

    CURSOR cur_short_text IS
      SELECT short.short_text, fdcv.name FROM
        fnd_attached_documents fad,
        fnd_documents_vl fdv,
        fnd_document_entities fde,
        fnd_document_categories_vl fdcv,
        fnd_documents_short_text short
      WHERE
        fad.document_id = fdv.document_id AND
        short.media_id  = fdv.media_id AND
        fad.entity_name = fde.entity_name AND
        fdcv.category_id = fdv.category_id AND
        fde.data_object_code  = p_table_name  AND
        fad.pk1_value   = p_id
          order by short.media_id; -- Check if removing this makes much performance difference
  BEGIN
        --  5185353
        attch_tab('PO Internal'):= '';
        attch_tab('MISC')       := '';
        attch_tab('Approver')   := '';
        attch_tab('Buyer')      := '';
        attch_tab('Payables')   := '';
        attch_tab('Reciever')   := '';
        attch_tab('Vendor')     := '';

    OPEN cur_short_text;
    LOOP
      FETCH cur_short_text INTO l_text,l_type;
      EXIT WHEN   cur_short_text%NOTFOUND;

        IF l_text IS NOT NULL THEN
                attch_tab(l_type) := l_text;
        END IF;
    END LOOP;
    CLOSE cur_short_text;

    x_pointernal := attch_tab('PO Internal');
    x_misc       := attch_tab('MISC');
    x_approver   := attch_tab('Approver');
    x_buyer      := attch_tab('Buyer');
    x_payables   := attch_tab('Payables');
    x_reciever   := attch_tab('Reciever');
    x_vendor     := attch_tab('Vendor');
  EXCEPTION
        WHEN OTHERS THEN
                null; -- do we want to fail the XGM?
  END;


  PROCEDURE addCBODDescMsg(p_msg_app      IN VARCHAR2,
                                   p_msg_code     IN VARCHAR2,
                           p_token_vals   IN VARCHAR2 := NULL,
                           p_translatable IN BOOLEAN  := TRUE,
                           p_reset        IN BOOLEAN  := FALSE)
  IS
    msg_code VARCHAR2(2000);
  BEGIN
        IF p_reset THEN
        g_cbod_desc := NULL;
      END IF;

      IF p_translatable THEN
          msg_code := 'T^^' ||p_msg_app || '^^' || p_msg_code || '^^' || p_token_vals || '^^' || '}}';
      ELSE
          msg_code := 'F^^' || p_msg_code || '}}';
      END IF;
      g_cbod_desc := g_cbod_desc || msg_code;
  END;

-- Todo :       Revisit and add comments.
--              Escape inputs/outputs containing delimiters
--              Add lenght checks for output(4000 bytes)
FUNCTION translateCBODDescMsg(p_msg_list IN VARCHAR2) RETURN VARCHAR2 AS
    msg_list VARCHAR2(4000);
    cur_msg  VARCHAR2(4000);
    ret_msg  VARCHAR2(4000);
    i        NUMBER;
    j        NUMBER;
    k        NUMBER;
    fnd_msg  VARCHAR2(200);
    fnd_app  VARCHAR2(200);
    fnd_token_val  VARCHAR2(200);
    fnd_token_nam  VARCHAR2(200);
  BEGIN
    msg_list := p_msg_list;
    i := INSTR(msg_list, '}}');
    WHILE i > 0
    LOOP
      cur_msg  := substr(msg_list,1,i-1);
      msg_list := substr(msg_list,i+2);




      IF substr(cur_msg,1,3) = 'F^^'  THEN
        cur_msg := substr(cur_msg,4);
        ret_msg := ret_msg || ' ' || cur_msg ;
      ELSE
        cur_msg := substr(cur_msg,4);


        j       := INSTR(cur_msg, '^^');
        fnd_app := SUBSTR(cur_msg,1,j-1);
        cur_msg := substr(cur_msg,j+2);


        j       := INSTR(cur_msg, '^^');
        fnd_msg := SUBSTR(cur_msg,1,j-1);
        cur_msg := substr(cur_msg,j+2);


          FND_MESSAGE.SET_NAME(fnd_app,fnd_msg);

          j :=  INSTR(cur_msg, '^^');

        WHILE j > 0
        LOOP
          k := INSTR(cur_msg,'::');
          fnd_token_nam := SUBSTR(cur_msg,1,k-1);

          fnd_token_val := SUBSTR(cur_msg,k+2,j-k-2);

            IF fnd_token_val IS NOT NULL OR fnd_token_nam IS NOT NULL THEN
                  FND_MESSAGE.SET_TOKEN(fnd_token_nam,fnd_token_val);
            END IF;
          cur_msg   := SUBSTR(cur_msg,j+2);
          j := INSTR(cur_msg, '^^');
        END LOOP;
        ret_msg := ret_msg || ' ' || FND_MESSAGE.GET;
      END IF;

      i := INSTR(msg_list, '}}');
    END LOOP;
    RETURN ret_msg;
  EXCEPTION
        WHEN OTHERS THEN
            itg_debug.msg('ITG_X_UTILS.translateCBODDescMsg ' || SQLCODE || ':' || SQLERRM);
                RETURN p_msg_list;
  END;


  FUNCTION getCBODDescMsg(p_reset IN BOOLEAN := FALSE) RETURN VARCHAR2 AS
    ret_mesg VARCHAR2(4000);
  BEGIN
    ret_mesg := g_cbod_desc;
    IF p_reset THEN
        g_cbod_desc := NULL;
    END IF;
    return ret_mesg;
  END;


BEGIN
  /* Package initialization. */
  SELECT to_char(e.party_id), to_char(e.party_site_id)
  INTO   g_party_id,          g_party_site_id
  FROM   hr_locations_all h,
         ecx_tp_headers   e
  WHERE  h.location_id   = e.party_id
  AND    e.party_type    = c_party_type
  AND    h.location_code = c_party_site_name;

  SELECT name
  INTO   g_local_system
  FROM   wf_systems
  WHERE  guid = wf_core.translate('WF_SYSTEM_GUID');

  g_event_key_pfx := 'ITG:' ;
  g_cbod_desc     := NULL;

  /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE
   * Indicate that package has been properly initialized.
   */
  g_initialized   := TRUE;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /* Indicate that package has NOT been properly initialized -
     * g_party_id and g_party_site_id are not valid for XMLG and CLN usage.
     */
    g_initialized := FALSE;
END;

/
