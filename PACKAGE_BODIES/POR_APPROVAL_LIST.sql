--------------------------------------------------------
--  DDL for Package Body POR_APPROVAL_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_APPROVAL_LIST" AS
/* $Header: PORAPRLB.pls 120.3.12010000.4 2014/04/01 10:49:36 uchennam ship $ */

-- Private global variables
g_quote_char           CONSTANT VARCHAR2(1)     := '\';
g_field_delimiter      CONSTANT VARCHAR2(1)     := ';';
g_date_format_mask     CONSTANT VARCHAR2(50)    := 'DD-MON-YY HH24:MI:SS';

g_approval_list_string          VARCHAR2(32767) := NULL;

-- Private routine prototypes

--------------------------------------------------------------------------------
--Start of Comments
--Function:
--  If a document is a previously saved requisition,
--  append the user-added approvers to the current approver list.

--Parameters:
--IN:
--p_document_id  requisition header ID
--p_approval_list  approval list table
--OUT:
--p_approval_list  approval list table
--End of Comments
--------------------------------------------------------------------------------
procedure append_saved_adhoc_approver(
   p_document_id      IN     NUMBER,
   p_approval_list IN OUT NOCOPY po_approvallist_s1.ApprovalListType);

PROCEDURE PushMessage(p_error_stack  IN OUT NOCOPY /* file.sql.39 change */ po_approvallist_s1.ErrorStackType,
                      p_message_name IN     VARCHAR2,
                      p_token1       IN     VARCHAR2 DEFAULT NULL,
                      p_value1       IN     VARCHAR2 DEFAULT NULL,
                      p_token2       IN     VARCHAR2 DEFAULT NULL,
                      p_value2       IN     VARCHAR2 DEFAULT NULL,
                      p_token3       IN     VARCHAR2 DEFAULT NULL,
                      p_value3       IN     VARCHAR2 DEFAULT NULL,
                      p_token4       IN     VARCHAR2 DEFAULT NULL,
                      p_value4       IN     VARCHAR2 DEFAULT NULL,
                      p_token5       IN     VARCHAR2 DEFAULT NULL,
                      p_value5       IN     VARCHAR2 DEFAULT NULL);

PROCEDURE VerifyAuthority(p_document_id      IN     NUMBER,
                          p_document_type    IN     VARCHAR2,
                          p_document_subtype IN     VARCHAR2,
                          p_employee_id      IN     NUMBER,
                          p_return_code      OUT NOCOPY /* file.sql.39 change */    NUMBER,
                          p_error_stack      IN OUT NOCOPY /* file.sql.39 change */ po_approvallist_s1.ErrorStackType,
                          p_has_authority    OUT NOCOPY /* file.sql.39 change */    BOOLEAN);

PROCEDURE MarshalField(p_string     IN VARCHAR2,
                       p_quote_char IN VARCHAR2,
                       p_delimiter  IN VARCHAR2);

FUNCTION GetNextToken(p_start_pos     IN OUT NOCOPY NUMBER,
                      p_quote_char    IN     VARCHAR2,
                      p_delimiter     IN     VARCHAR2,
                      p_remove_quotes IN     BOOLEAN,
                      p_result        OUT NOCOPY    VARCHAR2) RETURN BOOLEAN;
--Begin bug 13843060
FUNCTION is_adhoc_approver_exists(
   p_approval_list IN po_approvallist_s1.ApprovalListType,
   p_approver_id IN NUMBER) RETURN BOOLEAN;
--End bug 13843060
procedure get_doc_subtype(p_document_id in number) is

begin

  select type_lookup_code
  into g_document_subtype
  from po_requisition_headers_all
  where requisition_header_id = p_document_id;

end;

-- Public routines
PROCEDURE get_approval_list(p_document_id             IN  NUMBER,
                            p_first_approver_id       IN  NUMBER DEFAULT NULL,
                            p_default_flag            IN  NUMBER DEFAULT NULL,
                            p_rebuild_flag            IN  NUMBER DEFAULT NULL,
                            p_approval_list_header_id OUT NOCOPY NUMBER,
                            p_last_update_date        OUT NOCOPY VARCHAR2,
                            p_approval_list_string    OUT NOCOPY VARCHAR2,
                            p_approval_list_count     OUT NOCOPY NUMBER,
                            p_quote_char              OUT NOCOPY VARCHAR2,
                            p_field_delimiter         OUT NOCOPY VARCHAR2,
                            p_return_code             OUT NOCOPY NUMBER,
                            p_error_stack_string      OUT NOCOPY VARCHAR2,
			    p_preparer_can_approve    OUT NOCOPY NUMBER,
                            p_append_saved_approver_flag  IN  NUMBER DEFAULT NULL,
                            p_checkout_flow_type      IN  VARCHAR2 DEFAULT NULL) IS

  l_approval_list           po_approvallist_s1.ApprovalListType;
  l_error_stack             po_approvallist_s1.ErrorStackType;
  l_return_code             NUMBER;
  l_last_update_date        DATE;
  l_approval_list_header_id NUMBER;
  l_index                   NUMBER;
  l_tmp_string              VARCHAR2(2000);
  l_initial_build           BOOLEAN := false;
  l_approval_return_code    NUMBER;
  l_has_authority	    BOOLEAN;
  l_preparer_id		    NUMBER;
  l_can_preparer_approve_flag VARCHAR2(1);
  l_first_approver_id number;--bug 13843060

  --add below 2 variables for Bug#18069029
  l_use_positions_flag        VARCHAR2(1);
  l_forwarding_mode_code      VARCHAR2(25);
  cursor c_getwf_item
  iS select 'Y'
  FROM po_approval_list_headers
  WHERE   document_id = p_document_id
  AND    document_type = g_document_type
  AND    document_subtype = g_document_subtype
  AND    latest_revision = 'Y'
  AND    wf_item_type is  null and wf_item_key is  null;

  l_check_wfflag varchar2(10);
BEGIN

   --Begin Bug#18069029, get the value of l_use_positions_flag, l_forwarding_mode_code
    SELECT  forwarding_mode_code
     INTO   l_forwarding_mode_code
     FROM   po_document_types podt
     WHERE  podt.document_type_code = g_document_type
     AND    podt.document_subtype = g_document_subtype;

	SELECT NVL(use_positions_flag, 'N')
    INTO   l_use_positions_flag
    FROM   financials_system_parameters;
   --End Bug#18069029

  PO_APPROVALLIST_S1.g_checkout_flow_type := p_checkout_flow_type;


  get_doc_subtype(p_document_id);

  p_approval_list_string := NULL;

  IF (p_default_flag = 1) THEN
     l_initial_build := true;
     open c_getwf_item;
     FETCH c_getwf_item INTO l_check_wfflag;
     IF l_check_wfflag = 'Y' THEN
--begin bug 13843060
     po_approvallist_s1.get_latest_approval_list
        (p_document_id=>p_document_id,
         p_document_type=>g_document_type,
         p_document_subtype=>g_document_subtype,
         p_return_code=>l_return_code,
         p_error_stack=>l_error_stack,
         p_approval_list_header_id=>l_approval_list_header_id,
         p_last_update_date=>l_last_update_date,
         p_approval_list=>l_approval_list);

     p_last_update_date := to_char(l_last_update_date, g_date_format_mask);
     p_approval_list_header_id := l_approval_list_header_id;

     IF (l_return_code <> po_approvallist_s1.E_SUCCESS) THEN

        IF (l_error_stack.COUNT > 0) THEN
           l_error_stack.delete;
        END IF;

        l_first_approver_id := null;

     ELSE
       begin
         select approver_id into  l_first_approver_id
         from (select approver_id from  po_approval_list_lines
               where approval_list_header_id=l_approval_list_header_id
               and approver_type in ('SYSTEM', 'FORWARD')
               order by sequence_num asc)
         where rownum=1;

       exception
         when others then
           l_first_approver_id := null;
       end;

     END IF;

  END IF;
     --l_first_approver_id := nvl(p_first_approver_id,l_first_approver_id);
     --Begin Bug#18069029
     IF(l_use_positions_flag = 'Y' and l_forwarding_mode_code = 'DIRECT') THEN
	 l_first_approver_id := p_first_approver_id;
     ELSE
	 l_first_approver_id := nvl(p_first_approver_id,l_first_approver_id);
     END IF;
     --End Bug#18069029

     po_approvallist_s1.get_default_approval_list(
      p_first_approver_id=>l_first_approver_id,
--End bug 13843060
      p_approval_path_id=>NULL,
      p_document_id=>p_document_id,
      p_document_type=>g_document_type,
      p_document_subtype=>g_document_subtype,
      p_rebuild_code=>'INITIAL_BUILD',
      p_return_code=>l_return_code,
      p_error_stack=>l_error_stack,
      p_approval_list=>l_approval_list);

    IF (p_append_saved_approver_flag = 1) THEN
      append_saved_adhoc_approver(
        p_document_id=>p_document_id,
        p_approval_list=>l_approval_list);
    END IF;

  ELSIF (p_rebuild_flag = 1) THEN
      po_approvallist_s1.rebuild_approval_list(
        p_document_id=>p_document_id,
        p_document_type=>g_document_type,
        p_document_subtype=>g_document_subtype,
        p_rebuild_code=>'DOCUMENT_CHANGED',
        p_return_code=>l_return_code,
        p_error_stack=>l_error_stack,
        p_approval_list_header_id=>l_approval_list_header_id);

      IF (l_return_code <> po_approvallist_s1.E_SUCCESS) THEN
        GOTO HANDLE_ERROR; -- bad style huh?
      END IF;
      po_approvallist_s1.get_latest_approval_list
	(p_document_id=>p_document_id,
	 p_document_type=>g_document_type,
	 p_document_subtype=>g_document_subtype,
	 p_return_code=>l_return_code,
	 p_error_stack=>l_error_stack,
	 p_approval_list_header_id=>l_approval_list_header_id,
	 p_last_update_date=>l_last_update_date,
	 p_approval_list=>l_approval_list);

      p_last_update_date := to_char(l_last_update_date, g_date_format_mask);
      p_approval_list_header_id := l_approval_list_header_id;
   ELSE
     po_approvallist_s1.get_latest_approval_list
	(p_document_id=>p_document_id,
	 p_document_type=>g_document_type,
	 p_document_subtype=>g_document_subtype,
	 p_return_code=>l_return_code,
	 p_error_stack=>l_error_stack,
	 p_approval_list_header_id=>l_approval_list_header_id,
	 p_last_update_date=>l_last_update_date,
	 p_approval_list=>l_approval_list);

      p_last_update_date := to_char(l_last_update_date, g_date_format_mask);
      p_approval_list_header_id := l_approval_list_header_id;

      IF (l_return_code <> po_approvallist_s1.E_SUCCESS) THEN

	 IF (l_error_stack.COUNT > 0) THEN
	    l_error_stack.delete;
	 END IF;

	 l_initial_build := true;
	 po_approvallist_s1.get_default_approval_list
	   ( p_first_approver_id=>p_first_approver_id,
	     p_approval_path_id=>NULL,
	     p_document_id=>p_document_id,
	     p_document_type=>g_document_type,
	     p_document_subtype=>g_document_subtype,
	     p_rebuild_code=>'INITIAL_BUILD',
	     p_return_code=>l_return_code,
	     p_error_stack=>l_error_stack,
	     p_approval_list=>l_approval_list);

      END IF;
  END IF;

  IF (l_return_code = po_approvallist_s1.E_SUCCESS) THEN

    g_approval_list_string := NULL;

    IF (l_approval_list.COUNT > 0) THEN
      l_index := l_approval_list.FIRST;
      WHILE (l_index IS NOT NULL) LOOP
        MarshalField(to_char(l_approval_list(l_index).id), g_quote_char, g_field_delimiter);
        MarshalField(to_char(l_approval_list(l_index).approver_id), g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).approver_disp_name, g_quote_char, g_field_delimiter);
        MarshalField(to_char(l_approval_list(l_index).responder_id), g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).responder_disp_name, g_quote_char, g_field_delimiter);
        MarshalField(to_char(l_approval_list(l_index).forward_to_id), g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).forward_to_disp_name, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).status, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).approver_type, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).mandatory_flag, g_quote_char, g_field_delimiter);
        MarshalField(to_char(l_approval_list(l_index).sequence_num), g_quote_char, g_field_delimiter);
        MarshalField(to_char(l_approval_list(l_index).response_date), g_quote_char, g_field_delimiter);

	/* Add this when POXAPL1B is modified
        MarshalField(l_approval_list(l_index).attribute_category, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute1, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute2, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute3, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute4, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute5, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute6, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute7, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute8, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute9, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute10, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute11, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute12, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute13, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute14, g_quote_char, g_field_delimiter);
        MarshalField(l_approval_list(l_index).attribute15, g_quote_char, g_field_delimiter);
*/
        l_index := l_approval_list.NEXT(l_index);
      END LOOP;
    END IF;

    p_approval_list_count := l_approval_list.COUNT;
    p_approval_list_string := g_approval_list_string;
    p_quote_char := g_quote_char;
    p_field_delimiter := g_field_delimiter;
    IF (NOT l_initial_build) THEN
      p_return_code := 0;
    ELSE
      /** Bug 1001039
       *  bgu, Sept. 27, 1999
       *  This code should not be 1, because 1 is used by the scenario
       *  when approval list is built for the first time, and with some
       *  error. buildApprovalList precedure in RealOrder.java will not
       *  show message of which the approver has authority to approve
       *  the req if return code is 1.
       */
      p_return_code := 2;
    END IF;

    -- This section is used solely to determine if the preparer of the requisition
    -- can approve the requisition.

    BEGIN

      SELECT preparer_id
      INTO   l_preparer_id
      FROM   po_requisition_headers
      WHERE  requisition_header_id = p_document_id;

      VerifyAuthority(p_document_id=>p_document_id,
                      p_document_type=>g_document_type,
                      p_document_subtype=>g_document_subtype,
                      p_employee_id=>l_preparer_id,
                      p_return_code=>l_approval_return_code,
                      p_error_stack=>l_error_stack,
                      p_has_authority=>l_has_authority);

      IF (l_approval_return_code <> po_approvallist_s1.E_SUCCESS) THEN
	p_preparer_can_approve := 0;
      ELSIF (l_has_authority) THEN
	p_preparer_can_approve := 1;
      ELSE
	p_preparer_can_approve := 0;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_preparer_can_approve := 0;
    END;

    RETURN;


  ELSIF (p_default_flag = 1 AND l_return_code = po_approvallist_s1.E_NO_ONE_HAS_AUTHORITY) THEN

    SELECT NVL(can_preparer_approve_flag, 'N')
    INTO   l_can_preparer_approve_flag
    FROM   po_document_types podt
    WHERE  podt.document_type_code = g_document_type
    AND    podt.document_subtype = g_document_subtype;

    IF (l_can_preparer_approve_flag = 'N') THEN


    BEGIN

      SELECT preparer_id
      INTO   l_preparer_id
      FROM   po_requisition_headers
      WHERE  requisition_header_id = p_document_id;

      VerifyAuthority(p_document_id=>p_document_id,
                      p_document_type=>g_document_type,
                      p_document_subtype=>g_document_subtype,
                      p_employee_id=>l_preparer_id,
                      p_return_code=>l_approval_return_code,
                      p_error_stack=>l_error_stack,
                      p_has_authority=>l_has_authority);

      IF (l_approval_return_code <> po_approvallist_s1.E_SUCCESS) THEN
	p_preparer_can_approve := 0;
      ELSIF (l_has_authority) THEN
	p_preparer_can_approve := 1;
      ELSE
	p_preparer_can_approve := 0;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_preparer_can_approve := 0;
    END;

--    RETURN;
   END IF; --approver_flag
  END IF;


<<HANDLE_ERROR>>

  IF (l_error_stack.COUNT > 0 and NOT l_initial_build ) THEN
      p_error_stack_string := '';
      l_index := l_error_stack.FIRST;
      WHILE (l_index IS NOT NULL) LOOP
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).message_name || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token1 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value1 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token2 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value2 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token3 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value3 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token4 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value4 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token5 || g_quote_char;
	p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value5 || g_field_delimiter;

        l_index := l_error_stack.NEXT(l_index);
      END LOOP;
      l_error_stack.delete;
  END IF;
    p_approval_list_count := 0;
    p_approval_list_string := null;
    p_quote_char := g_quote_char;
    p_field_delimiter := g_field_delimiter;
    p_preparer_can_approve := 0;

  IF (NOT l_initial_build) THEN
     p_return_code := -1;
   ELSE
     p_return_code := 1;
  END IF;

  PO_APPROVALLIST_S1.g_checkout_flow_type := '';

END get_approval_list;

PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_approval_list_string    IN     VARCHAR2,
                             p_approval_list_header_id IN OUT NOCOPY NUMBER,
                             p_first_approver_id       IN     NUMBER,
                             p_last_update_date        IN OUT NOCOPY VARCHAR2,
                             p_quote_char              IN     VARCHAR2,
                             p_field_delimiter         IN     VARCHAR2,
                             p_return_code             OUT NOCOPY    NUMBER,
                             p_error_stack_string      OUT NOCOPY    VARCHAR2) IS
  l_approval_list     po_approvallist_s1.ApprovalListType;
  l_approval_list_elt po_approvallist_s1.ApprovalListEltType;
  l_error_stack       po_approvallist_s1.ErrorStackType;
  l_index             NUMBER;
  l_pos               NUMBER;
  l_string            VARCHAR2(32767);
  l_last_update_date  DATE;
  l_return_code       NUMBER;
BEGIN

  get_doc_subtype(p_document_id);

  p_return_code := 0;
  p_error_stack_string := null;

  IF (p_approval_list_header_id = -9999) THEN
    p_approval_list_header_id := NULL;
  END IF;

  -- Sanity check:
  IF (p_approval_list_header_id = NULL) THEN
    l_last_update_date := NULL;
  ELSE
    IF (p_last_update_date = NULL) THEN
      RETURN;
    ELSE
      l_last_update_date := to_date(p_last_update_date, g_date_format_mask);
    END IF;
  END IF;

  g_approval_list_string := p_approval_list_string;
  l_index := 0;
  l_pos := 1;

  LOOP
    l_approval_list_elt := NULL;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE,
			 l_string)) THEN
      EXIT;
    END IF;
    l_approval_list_elt.id := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
       RETURN;
    END IF;
    l_approval_list_elt.approver_id := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.approver_disp_name := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.responder_id := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.responder_disp_name := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.forward_to_id := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.forward_to_disp_name := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.status := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.approver_type := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.mandatory_flag := l_string;

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.sequence_num := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN

      RETURN;
    END IF;
    --l_approval_list_elt.response_date := to_number(l_string);

/* Add this when POXAPL1B is modified

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute_category := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute1 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute2 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute3 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute4 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute5 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute6 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute7 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute8 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute9 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute10 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute11 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute12 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute13 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute14 := to_number(l_string);

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
--      handle datacorruption: set error code (?)
      RETURN;
    END IF;
    l_approval_list_elt.attribute15 := to_number(l_string);

*/

    l_index := l_index + 1;
    l_approval_list(l_index) := l_approval_list_elt;

  END LOOP;

-- debug: po_approvallist_s1.print_approval_list(l_approval_list);

    po_approvallist_s1.save_approval_list(
      p_document_id=>p_document_id,
      p_document_type=>g_document_type,
      p_document_subtype=>g_document_subtype,
      p_first_approver_id=>p_first_approver_id,
      p_approval_path_id=>NULL,
      p_approval_list=>l_approval_list,
      p_last_update_date=>l_last_update_date,
      p_approval_list_header_id=> p_approval_list_header_id,
      p_return_code=>l_return_code,
      p_error_stack=>l_error_stack);

    IF (l_return_code = po_approvallist_s1.E_SUCCESS) THEN
       p_return_code := 1;

       select to_char(last_update_date, g_date_format_mask) into p_last_update_date
	 from po_approval_list_headers
	 where approval_list_header_id = p_approval_list_header_id;
     ELSE
      -- Deal with the specific error codes if needed
      -- Handle the error stack
	  IF (l_error_stack.COUNT > 0) THEN
	      p_error_stack_string := '';
	      l_index := l_error_stack.FIRST;
	      WHILE (l_index IS NOT NULL) LOOP
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).message_name || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token1 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value1 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token2 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value2 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token3 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value3 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token4 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value4 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).token5 || g_quote_char;
		p_error_stack_string := p_error_stack_string || l_error_stack(l_index).value5 || g_field_delimiter;

        	l_index := l_error_stack.NEXT(l_index);
	      END LOOP;
	      l_error_stack.delete;
	  END IF;
    END IF;

END save_approval_list;





PROCEDURE temp_get_rebuild_to_work(p_document_id             IN  NUMBER) IS

l_wf_item_key VARCHAR2(32767) := to_char(p_document_id) || '-1';
l_return NUMBER := 0;
BEGIN

  UPDATE po_requisition_headers
  SET        wf_item_type = 'REQAPPRV',
             wf_item_key  = l_wf_item_key
  WHERE requisition_header_id = p_document_id;

  PO_APPROVALLIST_S1.UPDATE_APPROVAL_LIST_ITEMKEY(p_document_id,
                   'REQAPPRV',
                   l_wf_item_key,
                   l_return);

  COMMIT;

END temp_get_rebuild_to_work;




-- Private routines.

PROCEDURE MarshalField(p_string     IN VARCHAR2,
                       p_quote_char IN VARCHAR2,
                       p_delimiter  IN VARCHAR2) IS
  l_string VARCHAR2(32767) := NULL;
BEGIN
  l_string := p_string;
  l_string := REPLACE(l_string, p_quote_char, p_quote_char || p_quote_char);
  l_string := REPLACE(l_string, p_delimiter, p_quote_char || p_delimiter);
  g_approval_list_string := g_approval_list_string || l_string || p_delimiter;
END MarshalField;

FUNCTION GetNextToken(p_start_pos     IN OUT NOCOPY NUMBER,
                      p_quote_char    IN     VARCHAR2,
                      p_delimiter     IN     VARCHAR2,
                      p_remove_quotes IN     BOOLEAN,
                      p_result        OUT NOCOPY    VARCHAR2) RETURN BOOLEAN IS
  l_pos       NUMBER;
  l_start_pos NUMBER;
  l_max_pos   NUMBER;
  l_string    VARCHAR2(32767);
BEGIN
  l_start_pos := p_start_pos;
  l_max_pos   := LENGTH(g_approval_list_string);
  l_pos       := p_start_pos;

  WHILE (l_start_pos <= l_max_pos) LOOP
    l_pos := INSTR(g_approval_list_string, p_delimiter, l_start_pos);
    IF (l_pos > 0) THEN
      IF (l_pos = p_start_pos) THEN
        p_start_pos := l_pos + 1;
        p_result := NULL;
        RETURN TRUE;
      END IF;
      IF (substr(g_approval_list_string, l_pos-1, 1) <> p_quote_char) THEN
        IF (p_remove_quotes) THEN
          l_string := substr(g_approval_list_string, p_start_pos, l_pos-p_start_pos);
          l_string := REPLACE(l_string, p_quote_char, NULL);
          p_result := l_string;
        ELSE
          p_result := substr(g_approval_list_string, p_start_pos, l_pos-p_start_pos);
        END IF;

        p_start_pos := l_pos + 1;
        RETURN TRUE;
      ELSE
        l_start_pos := l_pos + 2;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END LOOP;

  p_start_pos := l_start_pos;
  RETURN FALSE;
END GetNextToken;

PROCEDURE VerifyAuthority(p_document_id      IN     NUMBER,
                          p_document_type    IN     VARCHAR2,
                          p_document_subtype IN     VARCHAR2,
                          p_employee_id      IN     NUMBER,
                          p_return_code      OUT NOCOPY    NUMBER,
                          p_error_stack      IN OUT NOCOPY po_approvallist_s1.ErrorStackType,
                          p_has_authority    OUT NOCOPY    BOOLEAN) IS

  l_progress         VARCHAR2(10) := '000';
  l_return_value     NUMBER;
  l_return_code      VARCHAR2(25);
  l_error_msg        VARCHAR2(2000);

  -- <Doc Manager Rewrite 11.5.11>
  l_ret_sts          VARCHAR2(1);
  l_exc_msg          VARCHAR2(2000);

BEGIN

  PO_DOCUMENT_ACTION_PVT.verify_authority(
     p_document_id       => p_document_id
  ,  p_document_type     => p_document_type
  ,  p_document_subtype  => p_document_subtype
  ,  p_employee_id       => p_employee_id
  ,  x_return_status     => l_ret_sts
  ,  x_return_code       => l_return_code
  ,  x_exception_msg     => l_exc_msg
  ,  x_auth_failed_msg   => l_error_msg
  );

  IF (l_ret_sts = 'S')
  THEN
    l_return_value := 0;
  ELSE
    l_return_value := 3;
  END IF;

  -- <Doc Manager Rewrite 11.5.11 End>

  IF (l_return_value = 0) THEN
    IF (l_return_code IS NULL) THEN
      p_has_authority := TRUE;
    ELSE
      p_has_authority := FALSE;
    END IF;
    p_return_code := 0;
  ELSE
    IF (l_return_value = 1) THEN
      p_return_code := po_approvallist_s1.E_DOC_MGR_TIMEOUT;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    ELSIF (l_return_value = 2) THEN
      p_return_code := po_approvallist_s1.E_DOC_MGR_NOMGR;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    ELSE
      p_return_code := po_approvallist_s1.E_DOC_MGR_OTHER;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'VerifyAuthority', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END VerifyAuthority;

PROCEDURE PushMessage(p_error_stack  IN OUT NOCOPY po_approvallist_s1.ErrorStackType,
                      p_message_name IN     VARCHAR2,
                      p_token1       IN     VARCHAR2 DEFAULT NULL,
                      p_value1       IN     VARCHAR2 DEFAULT NULL,
                      p_token2       IN     VARCHAR2 DEFAULT NULL,
                      p_value2       IN     VARCHAR2 DEFAULT NULL,
                      p_token3       IN     VARCHAR2 DEFAULT NULL,
                      p_value3       IN     VARCHAR2 DEFAULT NULL,
                      p_token4       IN     VARCHAR2 DEFAULT NULL,
                      p_value4       IN     VARCHAR2 DEFAULT NULL,
                      p_token5       IN     VARCHAR2 DEFAULT NULL,
                      p_value5       IN     VARCHAR2 DEFAULT NULL) IS

  l_index NUMBER;
  l_count NUMBER;

BEGIN
  IF (p_message_name IS NOT NULL) THEN
    l_index := p_error_stack.LAST;
    IF (l_index IS NULL) THEN
      l_index := 1;
    ELSE
      l_index := l_index + 1;
    END IF;
    l_count := 0;
    p_error_stack(l_index).message_name := p_message_name;
    IF (p_token1 IS NOT NULL) THEN
      p_error_stack(l_index).token1 := p_token1;
      p_error_stack(l_index).value1 := p_value1;
      l_count := l_count + 1;
      IF (p_token2 IS NOT NULL) THEN
        p_error_stack(l_index).token2 := p_token2;
        p_error_stack(l_index).value2 := p_value2;
        l_count := l_count + 1;
        IF (p_token3 IS NOT NULL) THEN
          p_error_stack(l_index).token3 := p_token3;
          p_error_stack(l_index).value3 := p_value3;
          l_count := l_count + 1;
          IF (p_token4 IS NOT NULL) THEN
            p_error_stack(l_index).token4 := p_token4;
            p_error_stack(l_index).value4 := p_value4;
            l_count := l_count + 1;
            IF (p_token5 IS NOT NULL) THEN
              p_error_stack(l_index).token5 := p_token5;
              p_error_stack(l_index).value5 := p_value5;
              l_count := l_count + 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    p_error_stack(l_index).number_of_tokens := l_count;
  END IF;

END PushMessage;


--------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Find the latest records in po_approval_list_headers and
--  po_approval_list_lines for p_existing_requisition_id and
--  copy into p_new_requisition_id
--  the attributes are not duplicated as they are currently not used in iP approval list
--  note, the approval list is re-sequenced if necessary
--  so that the sequence number is always starting from 1,2,3...

--Parameters:
--IN:
--p_existing_requisition_id
--  from requisition header ID
--p_new_requisition_id
--  to requisition header ID
--OUT:
--None
--End of Comments
--------------------------------------------------------------------------------
procedure copy_approval_list(p_existing_requisition_id IN  NUMBER,
                            p_new_requisition_id IN  NUMBER) IS

  l_old_approval_list_header_id NUMBER;
  l_new_approval_list_header_id NUMBER;
  l_progress VARCHAR2(100) := '000';
  l_sequence_number number := 0;
  l_old_current_sequence_num number := 0;
  l_new_current_sequence_num number := 0;

  cursor old_approver_c(p_approval_list_header_id NUMBER) IS
  select       approver_id,
               sequence_num,
               notification_id,
               notification_role,
               responder_id,
               forward_to_id,
               mandatory_flag,
               requires_reapproval_flag,
               approver_type,
               status,
               response_date,
               comments
   FROM   po_approval_list_lines
   WHERE  approval_list_header_id = p_approval_list_header_id
   order by approval_list_line_id;

begin

   l_progress := '001' || p_existing_requisition_id ||'; '|| p_new_requisition_id;

   if (p_new_requisition_id is null or p_existing_requisition_id is null) then
     return;
   end if;

   SELECT po_approval_list_headers_s.nextval
   INTO   l_new_approval_list_header_id
   FROM   sys.dual;

   SELECT approval_list_header_id, current_sequence_num
   INTO l_old_approval_list_header_id, l_old_current_sequence_num
   FROM po_approval_list_headers
   WHERE document_id = p_existing_requisition_id
      AND    document_type = 'REQUISITION'
      AND    latest_revision = 'Y';

   DELETE FROM po_approval_list_lines
   WHERE approval_list_header_id in
    (select approval_list_header_id
     FROM po_approval_list_headers
     WHERE document_id = p_new_requisition_id
      AND    document_type = 'REQUISITION');

   DELETE FROM po_approval_list_headers
   WHERE document_id = p_new_requisition_id
      AND    document_type = 'REQUISITION';

   l_progress := '002:'||l_old_approval_list_header_id ||';'|| l_old_current_sequence_num;

   SELECT COUNT(1)
   into l_new_current_sequence_num
   FROM po_approval_list_lines
   WHERE sequence_num <= l_old_current_sequence_num and
         approval_list_header_id = l_old_approval_list_header_id;

   l_progress := '003:'|| l_new_current_sequence_num;

   INSERT INTO po_approval_list_headers (
      approval_list_header_id,
      document_id,
      document_type,
      document_subtype,
      revision,
      current_sequence_num,
      latest_revision,
      first_approver_id,
      approval_path_id,
      wf_item_type,
      wf_item_key,
      created_by,
      creation_date,
      last_update_login,
      last_updated_by,
      last_update_date)
   SELECT l_new_approval_list_header_id,
      p_new_requisition_id,
      document_type,
      document_subtype,
      0, --revision,
      decode (l_new_current_sequence_num, 0, current_sequence_num, l_new_current_sequence_num),
      latest_revision,
      first_approver_id,
      approval_path_id,
      wf_item_type,
      wf_item_key,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id,
      fnd_global.user_id,
      SYSDATE
   FROM po_approval_list_headers
   WHERE document_id = p_existing_requisition_id
      AND    document_type = 'REQUISITION'
      AND    latest_revision = 'Y';

   l_progress := '004'|| l_new_approval_list_header_id;

   BEGIN
     FOR approver_rec IN old_approver_c(l_old_approval_list_header_id) LOOP
        l_sequence_number := l_sequence_number +1;
        INSERT INTO po_approval_list_lines (
          approval_list_header_id,
          approval_list_line_id,
          next_element_id,
          approver_id,
          sequence_num,
          notification_id,
          notification_role,
          responder_id,
          forward_to_id,
          mandatory_flag,
          requires_reapproval_flag,
          approver_type,
          status,
          response_date,
          comments,
          created_by,
          creation_date,
          last_update_login,
          last_updated_by,
          last_update_date)
        VALUES ( l_new_approval_list_header_id,
               po_approval_list_lines_s.nextval,
               null,
               approver_rec.approver_id,
               l_sequence_number,
               approver_rec.notification_id,
               approver_rec.notification_role,
               approver_rec.responder_id,
               approver_rec.forward_to_id,
               approver_rec.mandatory_flag,
               approver_rec.requires_reapproval_flag,
               approver_rec.approver_type,
               approver_rec.status,
               approver_rec.response_date,
               approver_rec.comments,
               fnd_global.user_id,
               SYSDATE,
               fnd_global.login_id,
               fnd_global.user_id,
               SYSDATE
          );
      END LOOP;
    commit;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
    END;
exception
  when others then
   l_progress := '005' || SQLERRM(SQLCODE);
    raise;
end;

procedure append_saved_adhoc_approver(
   p_document_id   IN     NUMBER,
   p_approval_list IN OUT NOCOPY po_approvallist_s1.ApprovalListType) IS

  l_approver_id number;

  cursor adhoc_approver_c IS
  select pal.approver_id
  from po_approval_list_lines pal, po_approval_list_headers pah,
    po_requisition_headers_all prh
  where pal.approval_list_header_id = pah.approval_list_header_id
    and pah.latest_revision = 'Y'
    and pal.mandatory_flag = 'N'
    and approver_type ='USER'
    and pal.status is null
    and pah.document_id = prh.requisition_header_id
    and pah.document_type = 'REQUISITION'
    and prh.requisition_header_id = p_document_id
    and prh.authorization_status = 'INCOMPLETE'
  order by pal.sequence_num asc;

  l_index NUMBER;
  l_username                  wf_users.name%TYPE;
  l_disp_name                 wf_users.display_name%TYPE;
  l_approval_list_elt         po_approvallist_s1.ApprovalListEltType;

BEGIN
  l_index := p_approval_list.LAST;
  IF (l_index IS NULL) THEN
    l_index := 1;
  ELSE
    l_index := l_index + 1;
  END IF;

  FOR approver_rec IN adhoc_approver_c LOOP

--Begin bug 13843060
    IF(NOT(is_adhoc_approver_exists(p_approval_list, approver_rec.approver_id))) THEN
--End bug 13843060
      l_approval_list_elt.id := NULL;
      l_approval_list_elt.sequence_num := l_index;

      l_approval_list_elt.approver_id := approver_rec.approver_id;
      wf_directory.getusername('PER', approver_rec.approver_id, l_username, l_disp_name);
      l_approval_list_elt.approver_disp_name := l_disp_name;
      l_approval_list_elt.responder_id := NULL;
      l_approval_list_elt.responder_disp_name := NULL;

      l_approval_list_elt.forward_to_id := NULL;
      l_approval_list_elt.forward_to_disp_name := NULL;

      l_approval_list_elt.status := NULL;
      l_approval_list_elt.approver_type := 'USER';
      l_approval_list_elt.mandatory_flag := 'N';

      p_approval_list(l_index) := l_approval_list_elt;
      l_index := l_index + 1;
--Begin bug 13843060
    END IF;
--End bug 13843060
  END LOOP;

END;

--Begin bug 13843060
FUNCTION is_adhoc_approver_exists(
   p_approval_list IN po_approvallist_s1.ApprovalListType,
   p_approver_id IN NUMBER) RETURN BOOLEAN IS
BEGIN
  for i in Nvl(p_approval_list.first,0) .. Nvl(p_approval_list.last,-1) loop
    if(p_approval_list(i).approver_id =  p_approver_id) then
      return true;
    end if;
  end loop;
  return false;
END is_adhoc_approver_exists;
--End bug 13843060

END por_approval_list;

/
