--------------------------------------------------------
--  DDL for Package Body POR_UTIL_PKG2_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_UTIL_PKG2_TEST" AS
/* $Header: PORUTL2B.pls 115.2 99/07/17 03:33:03 porting sh $ */

-- Private global variables
g_quote_char           CONSTANT VARCHAR2(1)     := '\';
g_field_delimiter      CONSTANT VARCHAR2(1)     := ';';
g_date_format_mask     CONSTANT VARCHAR2(50)    := 'DD-MON-YY HH24:MI:SS';

g_approval_list_string          VARCHAR2(32767) := NULL;

-- Private routine prototypes
PROCEDURE MarshalField(p_string     IN VARCHAR2,
                       p_quote_char IN VARCHAR2,
                       p_delimiter  IN VARCHAR2);

FUNCTION GetNextToken(p_start_pos     IN OUT NUMBER,
                      p_quote_char    IN     VARCHAR2,
                      p_delimiter     IN     VARCHAR2,
                      p_remove_quotes IN     BOOLEAN,
                      p_result        OUT    VARCHAR2) RETURN BOOLEAN;


-- Public routines
PROCEDURE get_approval_list(p_document_id             IN  NUMBER,
                            p_first_approver_id       IN  NUMBER DEFAULT NULL,
                            p_default_flag            IN  NUMBER DEFAULT NULL,
                            p_rebuild_flag            IN  NUMBER DEFAULT NULL,
                            p_approval_list_header_id OUT NUMBER,
                            p_last_update_date        OUT VARCHAR2,
                            p_approval_list_string    OUT VARCHAR2,
                            p_approval_list_count     OUT NUMBER,
                            p_quote_char              OUT VARCHAR2,
                            p_field_delimiter         OUT VARCHAR2,
                            p_return_code             OUT NUMBER,
                            p_error_stack_string      OUT VARCHAR2) IS
  l_approval_list           po_approvallist_s1.ApprovalListType;
  l_error_stack             po_approvallist_s1.ErrorStackType;
  l_return_code             NUMBER;
  l_last_update_date        DATE;
  l_approval_list_header_id NUMBER;
  l_index                   NUMBER;
BEGIN

  p_approval_list_string := NULL;

  IF (p_default_flag = 1) THEN
    po_approvallist_s1.get_default_approval_list(
      p_first_approver_id=>p_first_approver_id,
      p_approval_path_id=>NULL,
      p_document_id=>p_document_id,
      p_document_type=>g_document_type,
      p_document_subtype=>g_document_subtype,
      p_rebuild_code=>'INITIAL_BUILD',
      p_return_code=>l_return_code,
      p_error_stack=>l_error_stack,
      p_approval_list=>l_approval_list);
  ELSE
    IF (p_rebuild_flag = 1) THEN
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
    END IF;
    po_approvallist_s1.get_latest_approval_list(
      p_document_id=>p_document_id,
      p_document_type=>g_document_type,
      p_document_subtype=>g_document_subtype,
      p_return_code=>l_return_code,
      p_error_stack=>l_error_stack,
      p_approval_list_header_id=>l_approval_list_header_id,
      p_last_update_date=>l_last_update_date,
      p_approval_list=>l_approval_list);

    p_last_update_date := to_char(l_last_update_date, g_date_format_mask);
    p_approval_list_header_id := l_approval_list_header_id;
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
        l_index := l_approval_list.NEXT(l_index);
      END LOOP;
    END IF;

    p_approval_list_count := l_approval_list.COUNT;
    p_approval_list_string := g_approval_list_string;
    p_quote_char := g_quote_char;
    p_field_delimiter := g_field_delimiter;
    p_return_code := 0;
    RETURN;
  END IF;

<<HANDLE_ERROR>>

  IF (l_error_stack.COUNT > 0) THEN

    NULL; -- Handle the error stack;

  END IF;

  p_return_code := -1;

END get_approval_list;

PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_approval_list_string    IN     VARCHAR2,
                             p_approval_list_header_id IN OUT NUMBER,
                             p_first_approver_id       IN     NUMBER,
                             p_last_update_date        IN     VARCHAR2,
                             p_quote_char              IN     VARCHAR2,
                             p_field_delimiter         IN     VARCHAR2,
                             p_return_code             OUT    NUMBER,
                             p_error_stack_string      OUT    VARCHAR2) IS
  l_approval_list     po_approvallist_s1.ApprovalListType;
  l_approval_list_elt po_approvallist_s1.ApprovalListEltType;
  l_error_stack       po_approvallist_s1.ErrorStackType;
  l_index             NUMBER;
  l_pos               NUMBER;
  l_string            VARCHAR2(32767);
  l_last_update_date  DATE;
  l_return_code       NUMBER;
BEGIN

  -- Sanity check:
  IF (p_approval_list_header_id IS NULL) THEN
    l_last_update_date := NULL;
  ELSE
    IF (p_last_update_date IS NULL) THEN
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

    IF (NOT GetNextToken(l_pos, p_quote_char, p_field_delimiter, TRUE, l_string)) THEN
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

    l_index := l_index + 1;
    l_approval_list(l_index) := l_approval_list_elt;

  END LOOP;

-- debug: po_approvallist_s1.print_approval_list(l_approval_list);

  IF (l_approval_list.COUNT > 0) THEN
    po_approvallist_s1.save_approval_list(
      p_document_id=>p_document_id,
      p_document_type=>g_document_type,
      p_document_subtype=>g_document_subtype,
      p_first_approver_id=>p_first_approver_id,
      p_approval_path_id=>NULL,
      p_approval_list=>l_approval_list,
      p_last_update_date=>l_last_update_date,
      p_approval_list_header_id=>p_approval_list_header_id,
      p_return_code=>l_return_code,
      p_error_stack=>l_error_stack);

    IF (l_return_code = po_approvallist_s1.E_SUCCESS) THEN
      NULL;
    ELSE
      -- Deal with the specific error codes if needed
      -- Handle the error stack
      NULL;
    END IF;
  END IF;

END save_approval_list;




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

FUNCTION GetNextToken(p_start_pos     IN OUT NUMBER,
                      p_quote_char    IN     VARCHAR2,
                      p_delimiter     IN     VARCHAR2,
                      p_remove_quotes IN     BOOLEAN,
                      p_result        OUT    VARCHAR2) RETURN BOOLEAN IS
  l_pos       NUMBER;
  l_start_pos NUMBER;
  l_max_pos   NUMBER;
  l_string    VARCHAR2(32767);
BEGIN
  l_start_pos := p_start_pos;
  l_max_pos   := LENGTH(g_approval_list_string);
  l_pos       := p_start_pos;

  WHILE (l_start_pos < l_max_pos) LOOP
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

END por_util_pkg2_test;

/
