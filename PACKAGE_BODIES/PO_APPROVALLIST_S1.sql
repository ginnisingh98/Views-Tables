--------------------------------------------------------
--  DDL for Package Body PO_APPROVALLIST_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVALLIST_S1" AS
/* $Header: POXAPL1B.pls 120.12.12010000.15 2014/06/11 07:40:16 jaxin ship $*/

-- Private function prototypes:

--Changes Made For Bug 2605927. Declared a table to store the Superior/Supervisor id's.
TYPE SupervisorListType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--Changes Made For Bug 2605927. Changed variable and type passed to the procedure.
PROCEDURE GetMgrPOHier(p_employee_id      IN     NUMBER,
                       p_approval_path_id IN     NUMBER,
                       p_return_code      OUT NOCOPY    NUMBER,
                       p_error_stack      IN OUT NOCOPY ErrorStackType,
                       p_superior_list    OUT NOCOPY    SupervisorListType, -- 2605927
                       p_document_id      IN NUMBER,
                       p_document_type    IN VARCHAR2,
                       p_document_subtype IN VARCHAR2);

PROCEDURE GetMgrHRHier(p_employee_id       IN     NUMBER,
                       p_business_group_id IN     NUMBER,
                       p_return_code       OUT NOCOPY    NUMBER,
                       p_error_stack       IN OUT NOCOPY ErrorStackType,
                       p_supervisor_list   OUT NOCOPY    SupervisorListType); -- 2605927

PROCEDURE VerifyAuthority(p_document_id      IN     NUMBER,
                          p_document_type    IN     VARCHAR2,
                          p_document_subtype IN     VARCHAR2,
                          p_employee_id      IN     NUMBER,
                          p_return_code      OUT NOCOPY    NUMBER,
                          p_error_stack      IN OUT NOCOPY ErrorStackType,
                          p_has_authority    OUT NOCOPY    BOOLEAN);

PROCEDURE PushMessage(p_error_stack  IN OUT NOCOPY ErrorStackType,
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

PROCEDURE SetMessage(p_error_stack_elt IN ErrorStackEltType);

-- End of Private function prototypes

PROCEDURE SetMessage(p_error_stack_elt IN ErrorStackEltType) IS
  l_num_tokens NUMBER;
BEGIN
  fnd_message.set_name('PO', p_error_stack_elt.message_name);
  l_num_tokens := p_error_stack_elt.number_of_tokens;
  IF (l_num_tokens >= 1) THEN
    fnd_message.set_token(p_error_stack_elt.token1, p_error_stack_elt.value1);
    IF (l_num_tokens >= 2) THEN
      fnd_message.set_token(p_error_stack_elt.token2, p_error_stack_elt.value2);
      IF (l_num_tokens >= 3) THEN
        fnd_message.set_token(p_error_stack_elt.token3, p_error_stack_elt.value3);
        IF (l_num_tokens >= 4) THEN
          fnd_message.set_token(p_error_stack_elt.token4, p_error_stack_elt.value4);
          IF (l_num_tokens >= 5) THEN
            fnd_message.set_token(p_error_stack_elt.token5, p_error_stack_elt.value5);
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;
END SetMessage;


PROCEDURE PushMessage(p_error_stack  IN OUT NOCOPY ErrorStackType,
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


PROCEDURE get_default_approval_list(p_first_approver_id IN     NUMBER,
                                    p_approval_path_id  IN     NUMBER,
                                    p_document_id       IN     NUMBER,
                                    p_document_type     IN     VARCHAR2,
                                    p_document_subtype  IN     VARCHAR2,
                                    p_rebuild_code      IN     VARCHAR2 DEFAULT 'INITIAL_BUILD',
                                    p_return_code       OUT NOCOPY    NUMBER,
                                    p_error_stack       IN OUT NOCOPY ErrorStackType,
                                    p_approval_list     OUT NOCOPY    ApprovalListType,
                                    p_approver_id       IN     VARCHAR2 DEFAULT NULL) IS

  l_progress                  VARCHAR2(10) := '000';
  l_authorization_status      VARCHAR2(25);
  l_preparer_id               NUMBER;
  l_approval_path_id          NUMBER;
  l_forwarding_mode_code      VARCHAR2(25);
  l_can_preparer_approve_flag VARCHAR2(1);
  l_use_positions_flag        VARCHAR2(1);
--Bug 9362974
  l_is_prepare_not_terminated VARCHAR2(1);
  l_business_group_id         NUMBER;
  l_document_type_code        VARCHAR2(25);
  l_document_subtype          VARCHAR2(25);
  l_employee_id               NUMBER;
  l_mgr_id                    NUMBER;
  l_return_code               NUMBER;
  l_has_authority             BOOLEAN;
  l_count                     NUMBER := 0;
  l_index                     NUMBER := 0;
  l_username                  VARCHAR2(100);
  l_disp_name                 VARCHAR2(240);
  l_approval_list_elt         ApprovalListEltType;
  l_approver_type             VARCHAR2(30);
  l_mandatory_flag            VARCHAR2(1);
  l_get_next_approver         BOOLEAN := TRUE;
  l_include_first_approver    BOOLEAN := TRUE;
--Changes Made For Bug 2605927. Added New variables.
  l_superior_list             SupervisorListType;
  l_sup_index                 NUMBER;
  l_orig_preparer             NUMBER;
--Bug : 5728521
  l_saved_first_approver_id   NUMBER;
--Bug6853017
  l_approver_id               NUMBER;
BEGIN

  p_approval_list.DELETE;

  IF (p_rebuild_code = 'FORWARD_RESPONSE' AND
      p_first_approver_id IS NULL) THEN
    p_return_code := E_INVALID_FIRST_APPROVER_ID;
    RETURN;
  END IF;
  IF (p_document_type = 'REQUISITION') THEN
    BEGIN
      l_progress := '001';

      SELECT preparer_id,
             authorization_status
      INTO   l_preparer_id,
             l_authorization_status
      FROM   po_requisition_headers
      WHERE  requisition_header_id = p_document_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_return_code := E_INVALID_DOCUMENT_ID;
        PushMessage(p_error_stack, 'PO_ALIST_INVALID_DOC_ID', 'DOC_ID', p_document_id);
        RETURN;
    END;
  ELSE
    p_return_code := E_UNSUPPORTED_DOCUMENT_TYPE;
    PushMessage(p_error_stack, 'PO_ALIST_UNSUPPORTED_DOC_TYPE', 'DOC_TYPE', p_document_type, 'DOC_SUBTYPE', p_document_subtype);
    RETURN;
  END IF;



  -- Bug 3246530: The approver id should be considered, if provided.
  l_orig_preparer := l_preparer_id;
  l_preparer_id := nvl(p_approver_id,l_preparer_id);

  l_progress := '002';
  -- Bug 9362974
  if ( l_preparer_id is not null ) then
    begin
                          SELECT 'Y'
 	INTO   l_is_prepare_not_terminated
 	FROM   po_workforce_current_x
 	WHERE  person_id =  l_preparer_id ;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
       l_is_prepare_not_terminated := 'N';
    END;

  end if;
--Bug 9362974


  SELECT NVL(p_approval_path_id, default_approval_path_id),
         forwarding_mode_code,
         NVL(can_preparer_approve_flag, 'N')
  INTO   l_approval_path_id,
         l_forwarding_mode_code,
         l_can_preparer_approve_flag
  FROM   po_document_types podt
  WHERE  podt.document_type_code = p_document_type
  AND    podt.document_subtype = p_document_subtype;

  l_progress := '003';

  SELECT NVL(use_positions_flag, 'N'),
         business_group_id
  INTO   l_use_positions_flag,
         l_business_group_id
  FROM   financials_system_parameters;


  IF (l_authorization_status = 'PRE-APPROVED'
      AND p_rebuild_code = 'FORWARD_RESPONSE') THEN
    l_get_next_approver := FALSE;
  ELSE
    IF ( (  ( l_can_preparer_approve_flag = 'Y') OR
       (nvl(p_approver_id,l_orig_preparer) <> l_orig_preparer)  ) and l_is_prepare_not_terminated ='Y' )THEN -- Bug 3246530 ,  9362974

      l_progress := '004';
      VerifyAuthority(p_document_id=>p_document_id,
                      p_document_type=>p_document_type,
                      p_document_subtype=>p_document_subtype,
                      p_employee_id=>l_preparer_id,
                      p_return_code=>l_return_code,
                      p_error_stack=>p_error_stack,
                      p_has_authority=>l_has_authority);
      IF (l_return_code <> E_SUCCESS) THEN
        p_return_code := l_return_code;
        RETURN;
      END IF;
      IF (l_has_authority) THEN
        IF (p_first_approver_id IS NOT NULL) THEN
          l_get_next_approver := FALSE;
          l_include_first_approver := TRUE;
        ELSE
          p_return_code := E_SUCCESS;
          RETURN;
        END IF;
      ELSE
        l_get_next_approver := TRUE;
      END IF;
    ELSE
      l_get_next_approver := TRUE;
    END IF;
  END IF;
  --Begin bug 13843060
  IF (p_first_approver_id IS NOT NULL  AND p_first_approver_id<>l_orig_preparer ) THEN
  --End bug 13843060
    -- check if we are doing forward or the preparer, who has the authority to approve the
    -- document, forward the document to someone else
    IF (p_rebuild_code = 'FORWARD_RESPONSE' OR
        (p_rebuild_code = 'INITIAL_BUILD' AND
         p_first_approver_id IS NOT NULL AND
         l_get_next_approver = FALSE)) THEN
      l_approver_type := 'FORWARD';
    ELSE
         l_approver_type := 'SYSTEM';
    END IF;
    IF (is_approver_valid(p_document_id=>p_document_id,
                          p_document_type=>p_document_type,
                          p_document_subtype=>p_document_subtype,
                          p_approver_id=>p_first_approver_id,
                          p_approver_type=>l_approver_type) = FALSE) THEN
      p_return_code := E_INVALID_FIRST_APPROVER_ID;
      PushMessage(p_error_stack, 'PO_ALIST_INVALID_FIRST_APPR', 'APPROVER', l_saved_first_approver_id);
      RETURN;
    END IF;

    l_progress := '007';

    IF (l_get_next_approver = TRUE) THEN
      VerifyAuthority(p_document_id=>p_document_id,
                      p_document_type=>p_document_type,
                      p_document_subtype=>p_document_subtype,
                      p_employee_id=>p_first_approver_id,
                      p_return_code=>l_return_code,
                      p_error_stack=>p_error_stack,
                      p_has_authority=>l_has_authority);
      IF (l_return_code <> E_SUCCESS) THEN
        -- p_approval_list.DELETE;
        p_return_code := l_return_code;
        RETURN;
      END IF;

      IF (l_has_authority = TRUE  ) THEN
         l_get_next_approver := FALSE;
      ELSE
        IF (l_forwarding_mode_code = 'HIERARCHY') THEN
          l_include_first_approver := TRUE;
        ELSE
          l_include_first_approver := FALSE;
        END IF;
      END IF;
    END IF;

    -- Note that we check the rebuild_code prior to l_include_first_approver
    IF (p_rebuild_code = 'FORWARD_RESPONSE' OR
        l_include_first_approver = TRUE) THEN
      l_index := l_index + 1;
      l_approval_list_elt.id := NULL;
      l_approval_list_elt.sequence_num := l_index;

      wf_directory.getusername('PER', p_first_approver_id, l_username, l_disp_name);
      l_approval_list_elt.approver_id := p_first_approver_id;
      l_approval_list_elt.approver_disp_name := l_disp_name;

      l_approval_list_elt.responder_id := NULL;
      l_approval_list_elt.responder_disp_name := NULL;

      l_approval_list_elt.forward_to_id := NULL;
      l_approval_list_elt.forward_to_disp_name := NULL;

      l_approval_list_elt.status := NULL;
      l_approval_list_elt.approver_type := l_approver_type;

      IF (is_approver_mandatory(p_document_id=>p_document_id,
                                p_document_type=>p_document_type,
                                p_document_subtype=>p_document_subtype,
                                p_preparer_id=>l_preparer_id,
                                p_approver_id=>l_approval_list_elt.approver_id,
                                p_approver_type=>l_approval_list_elt.approver_type) = TRUE) THEN
        l_approval_list_elt.mandatory_flag := 'Y';
      ELSE
        l_approval_list_elt.mandatory_flag := 'N';
      END IF;

      p_approval_list(l_index) := l_approval_list_elt;
    END IF;
  END IF;

  IF (l_get_next_approver = FALSE) THEN
    p_return_code := E_SUCCESS;
    RETURN;
  END IF;

 l_progress := '010';

 l_employee_id := NVL(p_first_approver_id, l_preparer_id);

 IF (l_use_positions_flag = 'Y') THEN
      l_progress := '011.'||to_char(l_count);
      --Changes Made For Bug 2605927. Changed the calls and now getting TABLE in return.
      GetMgrPOHier(p_employee_id=>l_employee_id,
                   p_approval_path_id=>l_approval_path_id,
                   p_return_code=>l_return_code,
                   p_error_stack=>p_error_stack,
                   p_superior_list=>l_superior_list, -- 2605927
                   p_document_id=>p_document_id,
                   p_document_type=>p_document_type,
                   p_document_subtype=>p_document_subtype);
    ELSE
      l_progress := '012.'||to_char(l_count);
      GetMgrHRHier(p_employee_id=>l_employee_id,
                   p_business_group_id=>l_business_group_id,
                   p_return_code=>l_return_code,
                   p_error_stack=>p_error_stack,
                   p_supervisor_list=>l_superior_list); -- 2605927
    END IF;

    IF (l_return_code = E_NO_SUPERVISOR_FOUND) THEN
      p_return_code := E_NO_ONE_HAS_AUTHORITY;
      RETURN;
    ELSIF (l_return_code <> E_SUCCESS) THEN
      -- p_approval_list.DELETE;
      p_return_code := l_return_code;
      RETURN;
    END IF;
    --Changes Made For Bug 2605927. Loop thru the number of records in the table and access
    --the superior_id from the list.

  l_sup_index := l_superior_list.FIRST;
  WHILE (l_sup_index IS NOT NULL) LOOP
    l_progress := '013.'||to_char(l_count);
    IF (is_approver_valid(p_document_id=>p_document_id,
                          p_document_type=>p_document_type,
                          p_document_subtype=>p_document_subtype,
                          p_approver_id=>l_superior_list(l_sup_index), -- 2605927
                          p_approver_type=>'SYSTEM') = TRUE) THEN

      l_progress := '014.'||to_char(l_count);
      VerifyAuthority(p_document_id=>p_document_id,
                      p_document_type=>p_document_type,
                      p_document_subtype=>p_document_subtype,
                      p_employee_id=>l_superior_list(l_sup_index),  -- 2605927
                      p_return_code=>l_return_code,
                      p_error_stack=>p_error_stack,
                      p_has_authority=>l_has_authority);
      IF (l_return_code <> E_SUCCESS) THEN
        -- p_approval_list.DELETE;
        p_return_code := l_return_code;
        RETURN;
      END IF;

      IF (l_has_authority = TRUE OR
          l_forwarding_mode_code = 'HIERARCHY') THEN
        l_progress := '015.'||to_char(l_count);

        l_index := l_index + 1;

        --Changes Made For Bug 2605927. Passing superior_id using the table.
        wf_directory.getusername('PER',l_superior_list(l_sup_index), l_username, l_disp_name);
        -- Make sure every field is reset since we reuse the same record
        l_approval_list_elt.id := NULL;
        l_approval_list_elt.sequence_num := l_index;

        l_approval_list_elt.approver_id := l_superior_list(l_sup_index);
        l_approval_list_elt.approver_disp_name := l_disp_name;

        l_approval_list_elt.responder_id := NULL;
        l_approval_list_elt.responder_disp_name := NULL;

        l_approval_list_elt.forward_to_id := NULL;
        l_approval_list_elt.forward_to_disp_name := NULL;

        l_approval_list_elt.status := NULL;
        l_approval_list_elt.approver_type := 'SYSTEM';

        IF (is_approver_mandatory(p_document_id=>p_document_id,
                                  p_document_type=>p_document_type,
                                  p_document_subtype=>p_document_subtype,
                                  p_preparer_id=>l_preparer_id,
                                  p_approver_id=>l_approval_list_elt.approver_id,
                                  p_approver_type=>l_approval_list_elt.approver_type) = TRUE) THEN
          l_approval_list_elt.mandatory_flag := 'Y';
        ELSE
          l_approval_list_elt.mandatory_flag := 'N';
        END IF;

        p_approval_list(l_index) := l_approval_list_elt;
      END IF;
      IF (l_has_authority = TRUE) THEN
        p_return_code := E_SUCCESS;
        RETURN;
      END IF;
    END IF;
    l_count := l_count+1;
    --Changes Made For Bug 2605927. Increment the index.
    l_employee_id := l_superior_list(l_sup_index);
    l_sup_index := l_superior_list.NEXT(l_sup_index);
  END LOOP;

  p_return_code := E_NO_ONE_HAS_AUTHORITY;

EXCEPTION
  WHEN OTHERS THEN
    -- p_approval_list.DELETE;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'GET_DEFAULT_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END get_default_approval_list;


--Changes Made For Bug 2605927. Changed the parameter variable and the type.
PROCEDURE GetMgrPOHier(p_employee_id      IN     NUMBER,
                       p_approval_path_id IN     NUMBER,
                       p_return_code      OUT NOCOPY    NUMBER,
                       p_error_stack      IN OUT NOCOPY ErrorStackType,
                       p_superior_list    OUT NOCOPY    SupervisorListType, -- 2605927
                       p_document_id      IN NUMBER,
                       p_document_type    IN VARCHAR2,
                       p_document_subtype IN VARCHAR2) IS

   /* Bug 2437175
      Added the LEADING(POEH) hint to get better execution plan */

  CURSOR c_po_hier(p_employee_id NUMBER, p_approval_path_id NUMBER) IS
  SELECT /*+ LEADING(POEH) */ poeh.superior_id, poeh.superior_level, hrec.full_name
  FROM   hr_employees_current_v hrec,
         po_employee_hierarchies poeh
  WHERE  poeh.position_structure_id = p_approval_path_id
  AND    poeh.employee_id = p_employee_id
  AND    hrec.employee_id = poeh.superior_id
  AND    poeh.superior_level > 0
  UNION ALL
  SELECT /*+ LEADING(POEH) */ poeh.superior_id, poeh.superior_level, cwk.full_name
  FROM   per_cont_workers_current_x cwk,
         po_employee_hierarchies poeh
  WHERE  poeh.position_structure_id = p_approval_path_id
  AND    poeh.employee_id = p_employee_id
  AND    cwk.person_id = poeh.superior_id
  AND    poeh.superior_level > 0
  AND    nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N') = 'Y'
  ORDER BY superior_level, full_name;

--Changes Made For Bug 2605927. Added new variables.

  -- bug3608697: increased the size of l_progress
  l_progress       VARCHAR2(300) := '000';
  l_superior_id    NUMBER := NULL;
  l_superior_level NUMBER := NULL;
  l_full_name      VARCHAR2(240) := '000';

  l_previous_superior_level NUMBER := -1;
  l_count NUMBER := 0;
  l_ind   NUMBER := 1;

BEGIN

  l_progress := '001';
  p_superior_list.DELETE;

	OPEN c_po_hier(p_employee_id, p_approval_path_id);
  	LOOP
          FETCH c_po_hier INTO l_superior_id, l_superior_level, l_full_name;
    	EXIT WHEN c_po_hier%NOTFOUND;

      -- bug3608697
      -- removed the line that concatenates '002' and to_char(l_superior_id)

      l_progress := '003 ' || to_char(l_superior_level);
      IF (is_approver_valid(p_document_id=>p_document_id,
                                   p_document_type=>p_document_type,
                                   p_document_subtype=>p_document_subtype,
                                   p_approver_id=>l_superior_id,
                                   p_approver_type=>'SYSTEM') = TRUE) THEN
        l_progress := '004 ' || to_char(l_previous_superior_level);
        IF (l_superior_level > l_previous_superior_level) then
          p_superior_list(l_ind) := l_superior_id;
          l_previous_superior_level := l_superior_level;
          l_ind := l_ind+1;
          p_return_code := E_SUCCESS;
        END IF;
	  END IF;
	END LOOP;
  	l_progress := '005';
  	CLOSE c_po_hier;
	--check if all the superiors are not valid users then give error ???
--Changes Made For Bug 2605927. If no superior then........
    IF(p_superior_list.COUNT = 0) THEN
        l_progress := '006';
		p_return_code := E_NO_SUPERVISOR_FOUND;
		PushMessage(p_error_stack, 'PO_ALIST_NO_SUPERVISOR', 'EMP_ID', p_employee_id);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_po_hier%ISOPEN) THEN
      CLOSE c_po_hier;
    END IF;
    p_superior_list.DELETE;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'GetMgrPOHier', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END GetMgrPOHier;

PROCEDURE GetLoopHRHier(p_employee_id       IN     NUMBER,
                       p_business_group_id IN     NUMBER,
                       p_return_code       OUT NOCOPY    NUMBER,
                       p_error_stack       IN OUT NOCOPY ErrorStackType,
                       p_supervisor_list     OUT NOCOPY    SupervisorListType) IS
  CURSOR c_hr_hier(p_employee_id NUMBER, p_business_group_id NUMBER) IS
  SELECT pera.supervisor_id
  FROM   per_assignments_f pera
  WHERE  trunc(SYSDATE) BETWEEN pera.effective_start_date AND pera.effective_end_date
  AND    pera.person_id = p_employee_id
  AND    pera.primary_flag = 'Y'
  AND    pera.ASSIGNMENT_TYPE IN ('E','C')-- bug 12388225
  AND EXISTS
    (SELECT '1'
      FROM per_people_f PERF, per_assignments_f PERA1
      WHERE trunc(sysdate) BETWEEN PERF.effective_start_date
      AND PERF.effective_end_date
      AND PERF.person_id = PERA.supervisor_id
      AND PERA1.person_id = PERF.person_id
      AND trunc(SYSDATE) BETWEEN PERA1.effective_start_date
      AND PERA1.effective_end_date
      AND PERA1.primary_flag = 'Y'
      AND PERA1.ASSIGNMENT_TYPE IN ('E','C')-- bug 12388225
      AND EXISTS
               (SELECT '1'
                FROM per_person_types PPT
                WHERE PPT.system_person_type IN ('EMP','EMP_APL','CWK') --<R12 CWK Enhancemment>
                AND PPT.person_type_id = PERF.person_type_id));

  l_progress      VARCHAR2(10) := '000';
  l_supervisor_id NUMBER := NULL;
  l_employee_id NUMBER := p_employee_id;
  l_index NUMBER :=1;
  l_loop_index NUMBER :=1;
  l_found_loop BOOLEAN := false;

BEGIN

  l_progress := '001';

  p_supervisor_list.DELETE;

  LOOP
    OPEN c_hr_hier(l_employee_id, p_business_group_id);
    FETCH c_hr_hier INTO l_supervisor_id;
    EXIT WHEN c_hr_hier%NOTFOUND;
    l_progress := '002';

    IF c_hr_hier%FOUND AND l_supervisor_id IS NOT NULL THEN
      l_loop_index := p_supervisor_list.FIRST;

      WHILE (l_loop_index IS NOT NULL) LOOP

        IF (l_supervisor_id = p_supervisor_list(l_loop_index)) THEN
          l_found_loop := true;
          exit;
        END IF;
        l_loop_index := p_supervisor_list.NEXT(l_loop_index);

      END LOOP;

      IF l_found_loop  THEN
        exit;

      END IF;
      p_supervisor_list(l_index) := l_supervisor_id;
      l_employee_id := l_supervisor_id;

      l_index := l_index +1;
      p_return_code := E_SUCCESS;
    END IF;
    CLOSE c_hr_hier;
  END LOOP;

  IF l_index <= 1 THEN
    p_return_code := E_NO_SUPERVISOR_FOUND;
    PushMessage(p_error_stack, 'PO_ALIST_NO_SUPERVISOR', 'EMP_ID', p_employee_id);
  END IF;

  l_progress := '003';
  CLOSE c_hr_hier;

EXCEPTION

  WHEN OTHERS THEN
    IF (c_hr_hier%ISOPEN) THEN
      CLOSE c_hr_hier;
    END IF;
    p_supervisor_list.DELETE;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'GetMgrHRHier', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END GetLoopHRHier;


--Changes Made For Bug 2605927.Changed the parameter variable and the type.
PROCEDURE GetMgrHRHier(p_employee_id       IN     NUMBER,
                       p_business_group_id IN     NUMBER,
                       p_return_code       OUT NOCOPY    NUMBER,
                       p_error_stack       IN OUT NOCOPY ErrorStackType,
                       p_supervisor_list     OUT NOCOPY    SupervisorListType) IS -- 2605927

/* Bug# 1775520:
** Desc: Changed the cursor c_hr_hier to check that the primary
** assignment of the supervisor is valid and that the system_person_type
** is an 'EMP'
*/
/* Bug# 2460162: kagarwal
** Desc: When we get the supervisor of an employee, we should be choosing
** the supervisor from the currently active primary assignment.
**
** Added condition pera.person_id = p_employee_id to SQL
*/
/* Bug 2605927. Changed the SQL and to construct the list */

/* Bug 2794501. When selecting the records from per_assignments_f only the
records corresponding to assignment_type 'E' should be selected */

/* Bug 8934709: Contingent worker is skipped in approval list.
Hence added the per_person_type_usages_f for checking whether the
person is contractor or not*/

  CURSOR c_hr_hier(p_employee_id NUMBER, p_business_group_id NUMBER) IS
  SELECT pera.supervisor_id
  FROM   per_assignments_f pera
  WHERE
    EXISTS
    (SELECT '1'
      FROM per_people_f PERF, per_assignments_f PERA1
      WHERE trunc(sysdate) BETWEEN PERF.effective_start_date
      AND PERF.effective_end_date
      AND PERF.person_id = PERA.supervisor_id
      AND PERA1.person_id = PERF.person_id
      AND trunc(SYSDATE) BETWEEN PERA1.effective_start_date
      AND PERA1.effective_end_date
      AND PERA1.primary_flag = 'Y'
      AND PERA1.ASSIGNMENT_TYPE IN ('E','C')      --<R12 CWK Enhancemment>
      AND EXISTS
      (SELECT '1'
                FROM per_person_types PPT ,
                            per_person_type_usages_f pptu	     --BUG 8934709 -Contingent worker not selected as approver.
                WHERE PPT.system_person_type IN ('EMP','EMP_APL','CWK')  --<R12 CWK Enhancemment>
                AND ppt.person_type_id = pptu.person_type_id
                AND pptu.Person_Id = PERF.person_id
           ))
  START WITH pera.person_id = p_employee_id
             AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                                AND pera.effective_end_date
             AND    pera.primary_flag = 'Y'
             AND PERA.ASSIGNMENT_TYPE IN ('E','C')       --<R12 CWK Enhancemment>
  CONNECT BY PRIOR pera.supervisor_id = pera.person_id
             AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                                AND pera.effective_end_date
             AND    pera.primary_flag = 'Y'
             AND PERA.ASSIGNMENT_TYPE IN ('E','C'); --<R12 CWK Enhancemment>

  l_progress      VARCHAR2(10) := '000';
  l_supervisor_id NUMBER := NULL;
  l_index NUMBER :=1;

  --Handle exception
  --ORA-01436: CONNECT BY loop in user data
  loop_in_hierarchy EXCEPTION;
  PRAGMA EXCEPTION_INIT(loop_in_hierarchy, -01436);

BEGIN

  l_progress := '001';
  p_supervisor_list.DELETE;

  OPEN c_hr_hier(p_employee_id, p_business_group_id);
  LOOP
    FETCH c_hr_hier INTO l_supervisor_id;
    EXIT WHEN c_hr_hier%NOTFOUND;
    l_progress := '002';
    IF c_hr_hier%FOUND AND l_supervisor_id IS NOT NULL THEN
      p_supervisor_list(l_index) := l_supervisor_id;
      l_index := l_index +1;
      p_return_code := E_SUCCESS;
  END IF;
  END LOOP;

  IF l_index <= 1 THEN
    p_return_code := E_NO_SUPERVISOR_FOUND;
    PushMessage(p_error_stack, 'PO_ALIST_NO_SUPERVISOR', 'EMP_ID', p_employee_id);
  END IF;

  l_progress := '003';
  CLOSE c_hr_hier;

EXCEPTION
  WHEN loop_in_hierarchy THEN
    IF (c_hr_hier%ISOPEN) THEN
      CLOSE c_hr_hier;
    END IF;
    GetLoopHRHier(p_employee_id=>p_employee_id,
                   p_business_group_id=>p_business_group_id,
                   p_return_code=>p_return_code,
                   p_error_stack=>p_error_stack,
                   p_supervisor_list=>p_supervisor_list);
  WHEN OTHERS THEN
    IF (c_hr_hier%ISOPEN) THEN
      CLOSE c_hr_hier;
    END IF;
    p_supervisor_list.DELETE;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'GetMgrHRHier', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END GetMgrHRHier;

PROCEDURE VerifyAuthority(p_document_id      IN     NUMBER,
                          p_document_type    IN     VARCHAR2,
                          p_document_subtype IN     VARCHAR2,
                          p_employee_id      IN     NUMBER,
                          p_return_code      OUT NOCOPY    NUMBER,
                          p_error_stack      IN OUT NOCOPY ErrorStackType,
                          p_has_authority    OUT NOCOPY    BOOLEAN) IS

  l_progress         VARCHAR2(10) := '000';
  l_return_value     NUMBER;
  l_return_code      VARCHAR2(25);
  l_error_msg        VARCHAR2(2000);

  -- <Doc Manager Rewrite 11.5.11>
  l_ret_sts          VARCHAR2(1);
  l_exc_msg          VARCHAR2(2000);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>
  -- Use PO_DOCUMENT_ACTION_PVT method instead of po_document_actions_sv

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
      p_return_code := E_DOC_MGR_TIMEOUT;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    ELSIF (l_return_value = 2) THEN
      p_return_code := E_DOC_MGR_NOMGR;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    ELSE
      p_return_code := E_DOC_MGR_OTHER;
      PushMessage(p_error_stack, 'PO_ALIST_DOC_MGR_FAIL', 'ERR_CODE', l_return_value);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'VerifyAuthority', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END VerifyAuthority;


PROCEDURE get_latest_approval_list(p_document_id             IN  NUMBER,
                                   p_document_type           IN  VARCHAR2,
                                   p_document_subtype        IN  VARCHAR2,
                                   p_return_code             OUT NOCOPY NUMBER,
                                   p_error_stack             OUT NOCOPY ErrorStackType,
                                   p_approval_list_header_id OUT NOCOPY NUMBER,
                                   p_last_update_date        OUT NOCOPY DATE,
                                   p_approval_list           OUT NOCOPY ApprovalListType) IS

 CURSOR c_approval_list_lines (p_approval_list_header_id NUMBER) IS
   SELECT approval_list_line_id,
          sequence_num,
          approver_id,
          responder_id,
          forward_to_id,
          status,
          response_date,
          mandatory_flag,
          approver_type
   FROM   po_approval_list_lines
   WHERE  approval_list_header_id = p_approval_list_header_id
   ORDER BY sequence_num;

  l_progress                VARCHAR2(10) := '000';
  l_index                   NUMBER;
  l_approval_list_header_id NUMBER;
  l_current_sequence_num    NUMBER;
  l_last_update_date        DATE;
  l_approval_list_elt       ApprovalListEltType;
  l_username                VARCHAR2(100);

BEGIN

  l_progress := '001';

  SELECT approval_list_header_id,
         NVL(current_sequence_num, 0),
         last_update_date
  INTO   l_approval_list_header_id,
         l_current_sequence_num,
         l_last_update_date
  FROM   po_approval_list_headers
  WHERE  document_id = p_document_id
  AND    document_type = p_document_type
  AND    document_subtype = p_document_subtype
  AND    latest_revision = 'Y';

  p_approval_list.DELETE;
  l_index := 1;

  l_progress := '002';
  OPEN c_approval_list_lines(l_approval_list_header_id);
  LOOP

    l_progress := '003.'||to_char(l_index);

    FETCH c_approval_list_lines INTO
      l_approval_list_elt.id,
      l_approval_list_elt.sequence_num,
      l_approval_list_elt.approver_id,
      l_approval_list_elt.responder_id,
      l_approval_list_elt.forward_to_id,
      l_approval_list_elt.status,
      l_approval_list_elt.response_date,
      l_approval_list_elt.mandatory_flag,
      l_approval_list_elt.approver_type;
    EXIT WHEN c_approval_list_lines%NOTFOUND;

    IF (l_approval_list_elt.approver_id IS NOT NULL) THEN
      l_progress := '004.'||to_char(l_index);
      wf_directory.getusername('PER',
                               l_approval_list_elt.approver_id,
                               l_username,
                               l_approval_list_elt.approver_disp_name);
    END IF;
    IF (l_approval_list_elt.responder_id IS NOT NULL) THEN
      l_progress := '005.'||to_char(l_index);
      wf_directory.getusername('PER',
                               l_approval_list_elt.responder_id,
                               l_username,
                               l_approval_list_elt.responder_disp_name);
    END IF;
    IF (l_approval_list_elt.forward_to_id IS NOT NULL) THEN
      l_progress := '006.'||to_char(l_index);
      wf_directory.getusername('PER',
                               l_approval_list_elt.forward_to_id,
                               l_username,
                               l_approval_list_elt.forward_to_disp_name);
    END IF;
    IF (l_approval_list_elt.status IS NULL AND
        l_approval_list_elt.sequence_num = l_current_sequence_num) THEN
      l_approval_list_elt.status := 'PENDING';
    END IF;

    p_approval_list(l_index) := l_approval_list_elt;
    l_index := l_index + 1;

  END LOOP;

  CLOSE c_approval_list_lines;
  p_approval_list_header_id := l_approval_list_header_id;
  p_last_update_date := l_last_update_date;
  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_approval_list_lines%ISOPEN) THEN
      CLOSE c_approval_list_lines;
    END IF;
    p_approval_list.DELETE;
    p_approval_list_header_id := NULL;
    p_last_update_date := NULL;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'GET_LATEST_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END get_latest_approval_list;



PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_document_type           IN     VARCHAR2,
                             p_document_subtype        IN     VARCHAR2,
                             p_first_approver_id       IN     NUMBER,
                             p_approval_path_id        IN     NUMBER,
                             p_approval_list           IN     ApprovalListType,
                             p_last_update_date        IN     DATE,
                             p_approval_list_header_id IN OUT NOCOPY NUMBER,
                             p_return_code             OUT NOCOPY    NUMBER,
                             p_error_stack             OUT NOCOPY    ErrorStackType) IS

  CURSOR c_lock_approval_list_lines(p_approval_list_header_id NUMBER) IS
    SELECT approval_list_line_id
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    FOR UPDATE NOWAIT;

  l_progress                    VARCHAR2(10) := '000';
  l_return_code                 NUMBER;
  l_old_approval_list_header_id NUMBER := NULL;
  l_old_revision                NUMBER := NULL;
  l_old_current_sequence_num    NUMBER := NULL;
  l_old_first_approver_id       NUMBER := NULL;
  l_old_approval_path_id        NUMBER := NULL;
  l_old_wf_item_type            VARCHAR2(8) := NULL;
  l_old_wf_item_key             VARCHAR2(240) := NULL;
  l_old_last_update_date        DATE := NULL;
  l_new_approval_list_header_id NUMBER;
  l_index                       NUMBER;
  l_flag                        VARCHAR2(1);

BEGIN

  l_progress := '001';

  IF (p_approval_list_header_id IS NOT NULL) THEN
    BEGIN
      SELECT last_update_date
      INTO   l_old_last_update_date
      FROM   po_approval_list_headers
      WHERE  document_id = p_document_id
      AND    document_type = p_document_type
      AND    document_subtype = p_document_subtype
      AND    approval_list_header_id = p_approval_list_header_id
      AND    latest_revision = 'Y';

      IF (l_old_last_update_date <> p_last_update_date) THEN
        p_return_code := E_LIST_MODIFIED_SINCE_RETRIEVE;
        PushMessage(p_error_stack, 'PO_ALIST_LIST_MODIFIED', 'LIST_ID', p_approval_list_header_id);
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_return_code := E_INVALID_LIST_HEADER_ID;
        PushMessage(p_error_stack, 'PO_ALIST_INVALID_LIST_HDR_ID', 'LIST_ID', p_approval_list_header_id);
        RETURN;
    END;
  END IF;

  l_progress := '002';

  validate_approval_list(p_document_id=>p_document_id,
                         p_document_type=>p_document_type,
                         p_document_subtype=>p_document_subtype,
                         p_approval_list=>p_approval_list,
                         p_current_sequence_num=>NVL(l_old_current_sequence_num, 0),
                         p_return_code=>l_return_code,
                         p_error_stack=>p_error_stack);
  IF (l_return_code <> E_SUCCESS) THEN
    p_return_code := E_INVALID_APPROVAL_LIST;
    RETURN;
  END IF;

  BEGIN

    SAVEPOINT SAVE_APPROVAL_LIST;

    BEGIN
      l_progress := '010';

      SELECT approval_list_header_id,
             NVL(revision, 0),
             NVL(current_sequence_num, 0),
             first_approver_id,
             approval_path_id,
             last_update_date,
             wf_item_type,
             wf_item_key
      INTO   l_old_approval_list_header_id,
             l_old_revision,
             l_old_current_sequence_num,
             l_old_first_approver_id,
             l_old_approval_path_id,
             l_old_last_update_date,
             l_old_wf_item_type,
             l_old_wf_item_key
      FROM   po_approval_list_headers
      WHERE  document_id = p_document_id
      AND    document_type = p_document_type
      AND    document_subtype = p_document_subtype
      AND    latest_revision = 'Y'
      FOR UPDATE NOWAIT;

      -- Checking last_update_date again since validate_approval_list() might have taken
      -- a while.
      IF (p_approval_list_header_id IS NOT NULL) AND
         ((l_old_approval_list_header_id <> p_approval_list_header_id) OR
          (l_old_last_update_date <> p_last_update_date)) THEN
        p_return_code := E_LIST_MODIFIED_SINCE_RETRIEVE;
        PushMessage(p_error_stack, 'PO_ALIST_LIST_MODIFIED', 'LIST_ID', p_approval_list_header_id);
        ROLLBACK TO SAVE_APPROVAL_LIST;
        RETURN;
      END IF;

      l_progress := '011';
      OPEN c_lock_approval_list_lines(l_old_approval_list_header_id);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (p_approval_list_header_id IS NOT NULL) THEN
          ROLLBACK TO SAVE_APPROVAL_LIST;
          p_return_code := E_INVALID_LIST_HEADER_ID;
          PushMessage(p_error_stack, 'PO_ALIST_INVALID_LIST_HDR_ID', 'LIST_ID', p_approval_list_header_id);
          RETURN;
        ELSE
          l_old_approval_list_header_id := NULL;
          l_old_revision := NULL;
          l_old_current_sequence_num := NULL;
          l_old_first_approver_id := NULL;
          l_old_approval_path_id := NULL;
          l_old_last_update_date := NULL;
          l_old_wf_item_type := NULL;
          l_old_wf_item_key := NULL;
        END IF;
      WHEN OTHERS THEN
        IF (SQLCODE = -54) THEN
          p_return_code := E_FAIL_TO_ACQUIRE_LOCK;
          PushMessage(p_error_stack, 'PO_ALIST_LOCK_FAIL');
        ELSE
          p_return_code := SQLCODE;
          PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'SAVE_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
        END IF;
        ROLLBACK TO SAVE_APPROVAL_LIST;
        RETURN;
    END;

    l_progress := '012';

    SELECT po_approval_list_headers_s.nextval
    INTO   l_new_approval_list_header_id
    FROM   sys.dual;

    l_progress := '013';

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
    VALUES(
      l_new_approval_list_header_id,
      p_document_id,
      p_document_type,
      p_document_subtype,
      decode(p_approval_list_header_id, NULL, 1, l_old_revision+1),
      decode(p_approval_list_header_id, NULL, NULL, l_old_current_sequence_num),
      'Y',
      decode(p_approval_list_header_id, NULL, p_first_approver_id, l_old_first_approver_id),
      decode(p_approval_list_header_id, NULL, p_approval_path_id, l_old_approval_path_id),
      decode(p_approval_list_header_id, NULL, NULL, l_old_wf_item_type),
      decode(p_approval_list_header_id, NULL, NULL, l_old_wf_item_key),
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id,
      fnd_global.user_id,
      SYSDATE);

    IF (p_approval_list_header_id IS NOT NULL) THEN
      BEGIN
        l_progress := '014';

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
        SELECT l_new_approval_list_header_id,
               po_approval_list_lines_s.nextval,
               NULL,
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
               fnd_global.user_id,
               SYSDATE,
               fnd_global.login_id,
               fnd_global.user_id,
               SYSDATE
        FROM   po_approval_list_lines
        WHERE  approval_list_header_id = p_approval_list_header_id
        AND    sequence_num <= l_old_current_sequence_num;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    l_progress := '016';

    IF (p_approval_list.COUNT > 0) THEN
      l_index := p_approval_list.FIRST;
      WHILE (l_index IS NOT NULL) LOOP

        IF (p_approval_list_header_id IS NULL OR
            p_approval_list(l_index).sequence_num > NVL(l_old_current_sequence_num, 0)) THEN

          l_progress := '017.'||to_char(l_index);

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
          SELECT l_new_approval_list_header_id,
                 po_approval_list_lines_s.nextval,
                 NULL,
                 p_approval_list(l_index).approver_id,
                 p_approval_list(l_index).sequence_num,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 p_approval_list(l_index).mandatory_flag,
                 'N',
                 p_approval_list(l_index).approver_type,
                 NULL, -- status
                 NULL, -- response_date
                 NULL, -- comments
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.login_id,
                 fnd_global.user_id,
                 SYSDATE
          FROM   sys.dual;
        END IF;
        l_index := p_approval_list.NEXT(l_index);
      END LOOP;
    END IF;

    IF (l_old_approval_list_header_id IS NOT NULL) THEN
      l_progress := '020';
      UPDATE po_approval_list_headers
      SET    latest_revision = 'N',
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
      WHERE  document_id = p_document_id
      AND    document_type = p_document_type
      AND    document_subtype = p_document_subtype
      AND    approval_list_header_id = l_old_approval_list_header_id;
    END IF;

    COMMIT;
    IF (c_lock_approval_list_lines%ISOPEN) THEN
      CLOSE c_lock_approval_list_lines;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_code := SQLCODE;
      PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'SAVE_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
      ROLLBACK TO SAVE_APPROVAL_LIST;
      IF (c_lock_approval_list_lines%ISOPEN) THEN
        CLOSE c_lock_approval_list_lines;
      END IF;
      RETURN;
  END;

  p_approval_list_header_id := l_new_approval_list_header_id;

  p_return_code := E_SUCCESS;


EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'SAVE_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END save_approval_list;

PROCEDURE rebuild_approval_list(p_document_id             IN  NUMBER,
                                p_document_type           IN  VARCHAR2,
                                p_document_subtype        IN  VARCHAR2,
                                p_rebuild_code            IN  VARCHAR2,
                                p_return_code             OUT NOCOPY NUMBER,
                                p_error_stack             OUT NOCOPY ErrorStackType,
                                p_approval_list_header_id OUT NOCOPY NUMBER) IS

  CURSOR c_lock_approval_list_lines(p_approval_list_header_id NUMBER) IS
    SELECT approval_list_line_id
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    FOR UPDATE;

  CURSOR c_find_last_forward_to(p_approval_list_header_id NUMBER,
                                p_current_sequence_num    NUMBER) IS
    SELECT forward_to_id,
           sequence_num
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    AND    forward_to_id IS NOT NULL
    AND    sequence_num <= p_current_sequence_num
    ORDER BY sequence_num DESC;

  CURSOR c_find_last_sys_approver(p_approval_list_header_id NUMBER,
                                  p_current_sequence_num    NUMBER) IS
    SELECT approver_id,
           sequence_num,
           approver_type
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    AND    approver_type IN ('SYSTEM', 'FORWARD')
    AND    sequence_num <= p_current_sequence_num
    AND    approval_list_line_id <> (select min(l2.approval_list_line_id)
                                     from   po_approval_list_lines l2
                                     where  l2.approval_list_header_id = p_approval_list_header_id)
    ORDER BY sequence_num DESC;

  CURSOR c_future_approver(p_approval_list_header_id NUMBER,
                           p_current_sequence_num NUMBER) IS
    SELECT approval_list_line_id,
           approver_id,
           sequence_num,
           approver_type,
           status,
           mandatory_flag
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    AND    sequence_num > NVL(p_current_sequence_num, 0)
    ORDER BY sequence_num;

  l_progress                     VARCHAR2(10) := '000';
  l_old_approval_list_header_id1 NUMBER;
  l_old_approval_list_header_id2 NUMBER;
  l_old_first_approver_id        NUMBER;
  l_old_approval_path_id         NUMBER;
  l_old_current_sequence_num     NUMBER;
  l_old_revision                 NUMBER;
  l_old_wf_item_type1            VARCHAR2(8);
  l_old_wf_item_key1             VARCHAR2(240);
  l_old_wf_item_type2            VARCHAR2(8);
  l_old_wf_item_key2             VARCHAR2(240);
  l_old_last_update_date1        DATE;
  l_old_last_update_date2        DATE;
  l_new_approval_list_header_id  NUMBER;
  l_preparer_id                  NUMBER;
  l_authorization_status         VARCHAR2(25);
  l_start_approver_id            NUMBER;
  l_default_approval_list        ApprovalListType;
  l_complete_approval_list       ApprovalListType;
  l_return_code                  NUMBER;
  l_max_sequence_num             NUMBER;
  l_flag                         VARCHAR2(1);
  l_last_forward_to_id           NUMBER;
  l_last_forward_to_sequence     NUMBER;
  l_last_sys_approver_id         NUMBER;
  l_last_sys_approver_sequence   NUMBER;
  l_last_sys_approver_type       VARCHAR2(30);
  l_need_to_update_list          BOOLEAN;
  l_num_system_approvers         NUMBER;
  l_index1                       NUMBER;
  l_index2                       NUMBER;
  L_CONTINUE_LOOP                EXCEPTION;
  l_count                        NUMBER;
  l_id                           NUMBER;
  l_approver_id                  NUMBER;
  l_sequence_num                 NUMBER;
  l_mandatory_flag               VARCHAR2(1);
  l_status                       VARCHAR2(30);
  l_approver_type                VARCHAR2(30);
  L_MAX_TRIALS                   CONSTANT NUMBER := 5;
  l_trial                        NUMBER := 0;
  l_forwardto_dup                BOOLEAN;
  l_can_preparer_approve_flag VARCHAR2(1);
  l_last_update_date          date;
  l_is_request_change_order	 VARCHAR2(1);  /* Bug 3912354 */
  l_first_approver_type    VARCHAR2(100);
  l_increment number :=0; --bug 13843060
BEGIN

  IF (p_rebuild_code NOT IN ('FORWARD_RESPONSE', 'DOCUMENT_CHANGED', 'INVALID_APPROVER')) THEN
    p_return_code := E_INVALID_REBUILD_CODE;
    PushMessage(p_error_stack, 'PO_ALIST_INVALID_REB_CODE', 'REB_CODE', p_rebuild_code);
    RETURN;
  END IF;

  <<BEGINNING>>
  l_trial := l_trial + 1;
  l_default_approval_list.DELETE;
  l_complete_approval_list.DELETE;

  BEGIN
    IF (p_document_type = 'REQUISITION') THEN
      BEGIN
        l_progress := '001';

        SELECT preparer_id,
               NVL(authorization_status, 'INCOMPLETE'),
	           change_pending_flag,
               wf_item_type,
               wf_item_key
        INTO   l_preparer_id,
               l_authorization_status,
	       l_is_request_change_order,
               l_old_wf_item_type1,
               l_old_wf_item_key1
        FROM   po_requisition_headers
        WHERE  requisition_header_id = p_document_id;

	/**
	** Bug 3912354: add code to include RCOs as possible candidates for
	** a list rebuild
	*/
        IF (l_is_request_change_order = 'Y') THEN
          l_progress := '0012';

          SELECT max(wf_item_type),
                 max(wf_item_key)
          INTO	l_old_wf_item_type1,
                l_old_wf_item_key1
          FROM	po_change_requests
          WHERE	document_header_id = p_document_id
                AND  document_type = 'REQ'
                AND  action_type NOT IN ('DERIVED')
                AND  request_status NOT IN ('ACCEPTED', 'REJECTED');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_return_code := E_INVALID_DOCUMENT_ID;
          PushMessage(p_error_stack, 'PO_ALIST_INVALID_DOC_ID', 'DOC_ID', p_document_id);
          RETURN;
      END;

    ELSE
      p_return_code := E_UNSUPPORTED_DOCUMENT_TYPE;
      PushMessage(p_error_stack, 'PO_ALIST_UNSUPPORTED_DOC_TYPE', 'DOC_TYPE', p_document_type, 'DOC_SUBTYPE', p_document_subtype);
      RETURN;
    END IF;

    l_progress := '002';

    SELECT approval_list_header_id,
           first_approver_id,
           approval_path_id,
           current_sequence_num,
           last_update_date
    INTO   l_old_approval_list_header_id1,
           l_old_first_approver_id,
           l_old_approval_path_id,
           l_old_current_sequence_num,
           l_old_last_update_date1
    FROM   po_approval_list_headers
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    document_subtype = p_document_subtype
    AND    wf_item_key = l_old_wf_item_key1
    AND    wf_item_type = l_old_wf_item_type1
    AND    latest_revision = 'Y';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_return_code := E_NO_APPROVAL_LIST_FOUND;
      PushMessage(p_error_stack, 'PO_ALIST_NO_LIST_FOUND');
      RETURN;
  END;

  IF (p_rebuild_code = 'FORWARD_RESPONSE') THEN
    l_progress := '003';

    SELECT forward_to_id
    INTO   l_start_approver_id
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = l_old_approval_list_header_id1
    AND    sequence_num = l_old_current_sequence_num;

    IF (l_start_approver_id IS NULL OR
        is_approver_valid(p_document_id=>p_document_id,
                          p_document_type=>p_document_type,
                          p_document_subtype=>p_document_subtype,
                          p_approver_id=>l_start_approver_id,
                          p_approver_type=>'FORWARD') = FALSE) THEN
      p_return_code := E_INVALID_FORWARD_TO_ID;
      PushMessage(p_error_stack, 'PO_ALIST_INVALID_FORWARD_TO', 'FORWARD_ID', l_start_approver_id);
      RETURN;
    END IF;

    l_progress := '004';
    get_default_approval_list(p_first_approver_id=>l_start_approver_id,
                              p_approval_path_id=>l_old_approval_path_id,
                              p_document_id=>p_document_id,
                              p_document_type=>p_document_type,
                              p_document_subtype=>p_document_subtype,
                              p_rebuild_code=>p_rebuild_code,
                              p_return_code=>l_return_code,
                              p_error_stack=>p_error_stack,
                              p_approval_list=>l_default_approval_list);
    IF (l_return_code <> E_SUCCESS) THEN

	UPDATE  po_approval_list_lines
	SET     sequence_num = sequence_num + 1
	WHERE   sequence_num > l_old_current_sequence_num
	AND     approval_list_header_id = l_old_approval_list_header_id1;


      INSERT INTO po_approval_list_lines (
        approval_list_header_id,
        approval_list_line_id,
        next_element_id,
        approver_id,
        sequence_num,
        mandatory_flag,
        requires_reapproval_flag,
        approver_type,
        created_by,
        creation_date,
        last_update_login,
        last_updated_by,
        last_update_date)
      SELECT l_old_approval_list_header_id1,
             po_approval_list_lines_s.nextval,
             NULL, -- next_element_id
             l_start_approver_id,
             l_old_current_sequence_num+1,
             'N',
             'N',
             'FORWARD',
             fnd_global.user_id,
             SYSDATE,
             fnd_global.login_id,
             fnd_global.user_id,
             SYSDATE
      FROM   dual;


     get_latest_approval_list
   	(p_document_id=>p_document_id,
   	 p_document_type=>p_document_type,
   	 p_document_subtype=>p_document_subtype,
   	 p_return_code=>l_return_code,
   	 p_error_stack=>p_error_stack,
   	 p_approval_list_header_id=>l_old_approval_list_header_id1,
   	 p_last_update_date=>l_last_update_date,
   	 p_approval_list=>l_complete_approval_list);

    validate_approval_list(p_document_id=>p_document_id,
                         p_document_type=>p_document_type,
                         p_document_subtype=>p_document_subtype,
                         p_approval_list=>l_complete_approval_list,
                         p_current_sequence_num=>null,
                         p_return_code=>l_return_code,
                         p_error_stack=>p_error_stack);


      p_return_code := l_return_code;
      RETURN;
    END IF;

  ELSIF (p_rebuild_code <> 'INVALID_APPROVER' OR
         l_authorization_status <> 'PRE-APPROVED') THEN

    l_last_forward_to_id := NULL;
    l_last_forward_to_sequence := NULL;

    l_progress := '005';
    OPEN c_find_last_forward_to(l_old_approval_list_header_id1,
                                l_old_current_sequence_num);
    LOOP
      FETCH c_find_last_forward_to INTO l_last_forward_to_id, l_last_forward_to_sequence;
      EXIT WHEN c_find_last_forward_to%NOTFOUND;

      -- Could have incorporated this into the cursor
      IF (is_approver_valid(p_document_id=>p_document_id,
                            p_document_type=>p_document_type,
                            p_document_subtype=>p_document_subtype,
                            p_approver_id=>l_last_forward_to_id,
                            p_approver_type=>'FORWARD') = TRUE) THEN
        EXIT;
      ELSE
        l_last_forward_to_id := NULL;
        l_last_forward_to_sequence := NULL;
      END IF;
    END LOOP;
    CLOSE c_find_last_forward_to;

    l_last_sys_approver_id := NULL;
    l_last_sys_approver_sequence := NULL;
    l_last_sys_approver_type := NULL;

    l_progress := '006';
    OPEN c_find_last_sys_approver(l_old_approval_list_header_id1,
                                  l_old_current_sequence_num);
    LOOP
      FETCH c_find_last_sys_approver INTO l_last_sys_approver_id,
                                          l_last_sys_approver_sequence,
                                          l_last_sys_approver_type;
      EXIT WHEN c_find_last_sys_approver%NOTFOUND;

      IF (is_approver_valid(p_document_id=>p_document_id,
                            p_document_type=>p_document_type,
                            p_document_subtype=>p_document_subtype,
                            p_approver_id=>l_last_sys_approver_id,
                            p_approver_type=>l_last_sys_approver_type) = TRUE) THEN
        EXIT;
      ELSE
        l_last_sys_approver_id := NULL;
        l_last_sys_approver_sequence := NULL;
        l_last_sys_approver_type := NULL;
      END IF;
    END LOOP;
    CLOSE c_find_last_sys_approver;

    IF (l_last_forward_to_id IS NULL AND l_last_sys_approver_id IS NULL) THEN
                               --Bug:8793063 If the first approver is manuall added approver
 	      -- then build the list from preparer
 	begin

 	      SELECT APPROVER_TYPE
 	       INTO l_first_approver_type
 	       FROM   po_approval_list_lines
 	       WHERE  APPROVAL_LIST_HEADER_ID = l_old_approval_list_header_id1
 	       AND    SEQUENCE_NUM=1;

                     exception
                           when others then
                         l_first_approver_type := 'SYSTEM';
                     end;
 	       IF (l_first_approver_type <> 'SYSTEM') THEN
 	                    l_start_approver_id := l_preparer_id;
 	       ELSE
                                              l_start_approver_id := l_old_first_approver_id;
   	      END IF;
    ELSIF (l_last_forward_to_id IS NULL AND l_last_sys_approver_id IS NOT NULL) THEN
      l_start_approver_id := l_last_sys_approver_id;
    ELSIF (l_last_forward_to_id IS NOT NULL AND l_last_sys_approver_id IS NULL) THEN
      l_start_approver_id := l_last_forward_to_id;
    ELSIF (l_last_forward_to_id IS NOT NULL AND l_last_sys_approver_id IS NOT NULL) THEN
      IF (NVL(l_last_forward_to_sequence, -1) >= NVL(l_last_sys_approver_sequence, -2)) THEN
        l_start_approver_id := l_last_forward_to_id;
      ELSE
        l_start_approver_id := l_last_sys_approver_id;
      END IF;
    END IF;

    l_progress := '007';
    get_default_approval_list(p_first_approver_id=>l_start_approver_id,
                              p_approval_path_id=>l_old_approval_path_id,
                              p_document_id=>p_document_id,
                              p_document_type=>p_document_type,
                              p_document_subtype=>p_document_subtype,
                              p_rebuild_code=>p_rebuild_code,
                              p_return_code=>l_return_code,
                              p_error_stack=>p_error_stack,
                              p_approval_list=>l_default_approval_list);

    -- bug 18761355: call get_default_approval_list again using old first approver's id, in case preparer have no hierarchy
    IF (l_return_code = E_NO_ONE_HAS_AUTHORITY) THEN
      get_default_approval_list(p_first_approver_id=>l_old_first_approver_id,
                              p_approval_path_id=>l_old_approval_path_id,
                              p_document_id=>p_document_id,
                              p_document_type=>p_document_type,
                              p_document_subtype=>p_document_subtype,
                              p_rebuild_code=>p_rebuild_code,
                              p_return_code=>l_return_code,
                              p_error_stack=>p_error_stack,
                              p_approval_list=>l_default_approval_list);
    END IF;
    IF (l_return_code = E_NO_ONE_HAS_AUTHORITY) THEN

  	  SELECT NVL(can_preparer_approve_flag, 'N')
  	  INTO   l_can_preparer_approve_flag
  	  FROM   po_document_types podt
  	  WHERE  podt.document_type_code = p_document_type
  	  AND    podt.document_subtype = p_document_subtype;
	  IF (l_can_preparer_approve_flag <> 'N') THEN
            p_return_code := l_return_code;
	    RETURN;
	  END IF;
    ELSIF (l_return_code <> E_SUCCESS) THEN
      p_return_code := l_return_code;
      RETURN;
    END IF;
  END IF;

  -- Check to see if we need to remove persons from the new list
  IF (l_default_approval_list.COUNT > 0) THEN
    l_index1 := l_default_approval_list.FIRST;
    WHILE (l_index1 IS NOT NULL) LOOP
      BEGIN
        IF (l_default_approval_list(l_index1).approver_type = 'SYSTEM') THEN
          l_progress := '008.'||to_char(l_index1);

          IF (p_rebuild_code = 'FORWARD_RESPONSE') THEN
            -- We dont remove end approver who has the authority.
            IF (l_index1 = l_default_approval_list.LAST) THEN
              RAISE L_CONTINUE_LOOP;
            END IF;

            -- remove user add/forward approvers in the future
            SELECT COUNT(*)
            INTO   l_count
            FROM   po_approval_list_lines
            WHERE  approval_list_header_id = l_old_approval_list_header_id1
            AND    approver_id = l_default_approval_list(l_index1).approver_id
            AND    (sequence_num >= l_old_current_sequence_num  AND approver_type <> 'SYSTEM' AND approver_type <> 'FORWARD');

            IF (l_count > 0) THEN
              l_default_approval_list.DELETE(l_index1);
              RAISE L_CONTINUE_LOOP;
            END IF;

          ElSE
            SELECT COUNT(*)
            INTO   l_count
            FROM   po_approval_list_lines
            WHERE  approval_list_header_id = l_old_approval_list_header_id1
            AND    approver_id = l_default_approval_list(l_index1).approver_id
            AND    ((sequence_num = l_old_current_sequence_num) OR
                  (sequence_num >= l_old_current_sequence_num  AND approver_type <> 'SYSTEM'));

	  --Bug:8793063 When rebuilded from preparer the list contains preparer also
 	  -- Hence knock off preparer as he isnt present in po_approval_list_lines
             IF ((l_count > 0) OR  (l_default_approval_list(l_index1).approver_id=l_preparer_id)) THEN
              l_default_approval_list.DELETE(l_index1);
              RAISE L_CONTINUE_LOOP;
            END IF;

            -- We dont remove end approver who has the authority.
            IF (l_index1 = l_default_approval_list.LAST) THEN
              RAISE L_CONTINUE_LOOP;
            END IF;

          END IF;

          -- Find out whether or not the person has already responded
          l_progress := '009.'||to_char(l_index1);
          SELECT COUNT(*)
          INTO   l_count
          FROM   po_approval_list_lines
          WHERE  approval_list_header_id = l_old_approval_list_header_id1
          AND    approver_id = l_default_approval_list(l_index1).approver_id
          AND    sequence_num <= l_old_current_sequence_num;

          IF (l_count > 0) THEN
            l_progress := '010.'||to_char(l_index1);
            SELECT COUNT(*)
            INTO   l_count
            FROM   po_approval_list_lines
            WHERE  approval_list_header_id = l_old_approval_list_header_id1
            AND    approver_id = l_default_approval_list(l_index1).approver_id
            AND    sequence_num <= l_old_current_sequence_num
            AND    requires_reapproval_flag = 'Y';

            IF (l_count = 0) THEN
              IF (p_rebuild_code = 'DOCUMENT_CHANGED') THEN
                -- If approver responded
                -- and all requires_reapproval_flag <> 'Y'
                -- and all status not in ('APPROVE', 'APPROVE_AND_FORWARD')
                -- then we remove him.
                l_progress := '011.'||to_char(l_index1);
                SELECT COUNT(*)
                INTO   l_count
                FROM   po_approval_list_lines
                WHERE  approval_list_header_id = l_old_approval_list_header_id1
                AND    approver_id = l_default_approval_list(l_index1).approver_id
                AND    sequence_num <= l_old_current_sequence_num
                AND    status in ('APPROVE', 'APPROVE_AND_FORWARD');

                IF (l_count = 0) THEN
                  l_default_approval_list.DELETE(l_index1);
                  RAISE L_CONTINUE_LOOP;
                END IF;
              ELSIF (p_rebuild_code = 'FORWARD_RESPONSE') THEN
                -- If approver responded
                -- and all requires_reapproval_flag <> 'Y'
                -- and all status not in ('APPROVE', 'APPROVE_AND_FORWARD')
                -- then we remove him.

                SELECT COUNT(*)
                INTO   l_count
                FROM   po_approval_list_lines
                WHERE  approval_list_header_id = l_old_approval_list_header_id1
                AND    approver_id = l_default_approval_list(l_index1).approver_id
                AND    sequence_num <= l_old_current_sequence_num
                AND    status in ('FORWARD');

                IF (l_count = 0) THEN
                  l_default_approval_list.DELETE(l_index1);
                  RAISE L_CONTINUE_LOOP;
                END IF;

              ELSE
                -- So all the rows have requires_reapproval_flag <> Y
                l_default_approval_list.DELETE(l_index1);
                RAISE L_CONTINUE_LOOP;
              END IF;
            END IF;
          END IF;
        END IF;

      EXCEPTION
        WHEN L_CONTINUE_LOOP THEN
          NULL;
      END;
      l_index1 := l_default_approval_list.NEXT(l_index1);
    END LOOP;
  END IF;

  -- Need to build the entire list? FIXME!
  l_index1 := 1;
--begin bug 13843060
  l_index2 := l_default_approval_list.FIRST;
  WHILE (l_index2 IS NOT NULL) LOOP
      l_complete_approval_list(l_index1) := l_default_approval_list(l_index2);
      l_index1 := l_index1 + 1;
      l_increment := l_increment+1;
      l_index2 := l_default_approval_list.NEXT(l_index2);
  END LOOP;

  l_index1 := l_index1 + 1;
--end bug 13843060
  OPEN c_future_approver(l_old_approval_list_header_id1, l_old_current_sequence_num);
  LOOP
    FETCH c_future_approver INTO l_id, l_approver_id, l_sequence_num,
                                 l_approver_type, l_status, l_mandatory_flag;
    EXIT WHEN c_future_approver%NOTFOUND;

    IF (is_approver_valid(p_document_id=>p_document_id,
                          p_document_type=>p_document_type,
                          p_document_subtype=>p_document_subtype,
                          p_approver_id=>l_approver_id,
                          p_approver_type=>l_approver_type) = TRUE) THEN

-- if an user added approver happens to be the foward-to approver, then donot add this approver twice.

      l_forwardto_dup := FALSE;

      IF (l_default_approval_list.COUNT > 0) THEN
	IF ((l_default_approval_list(l_default_approval_list.FIRST).approver_id = l_approver_id) AND (l_default_approval_list(l_default_approval_list.FIRST).approver_type) = 'FORWARD') THEN
  		l_forwardto_dup := TRUE;
	END IF;
      END IF;

--    IF (l_approver_type <> 'SYSTEM' OR
      IF (((l_approver_type <> 'SYSTEM') AND (NOT (( l_approver_type ='USER') AND l_forwardto_dup))) OR

          (p_rebuild_code = 'INVALID_APPROVER' AND
           l_authorization_status = 'PRE-APPROVED' AND
           l_sequence_num = l_old_current_sequence_num)) THEN
        l_complete_approval_list(l_index1).id := l_id;
        l_sequence_num := l_sequence_num+l_increment; --bug 13843060
        l_complete_approval_list(l_index1).sequence_num := l_sequence_num;

        l_complete_approval_list(l_index1).approver_id := l_approver_id;
        l_complete_approval_list(l_index1).approver_disp_name := NULL;

        l_complete_approval_list(l_index1).responder_id := NULL;
        l_complete_approval_list(l_index1).responder_disp_name := NULL;

        l_complete_approval_list(l_index1).forward_to_id := NULL;
        l_complete_approval_list(l_index1).forward_to_disp_name := NULL;

        l_complete_approval_list(l_index1).status := l_status;
        l_complete_approval_list(l_index1).approver_type := l_approver_type;
        l_complete_approval_list(l_index1).mandatory_flag := l_mandatory_flag;

        l_index1 := l_index1 + 1;
      END IF;
    END IF;
  END LOOP;
  CLOSE c_future_approver;

--begin bug 13843060
/*
  l_index2 := l_default_approval_list.FIRST;
  WHILE (l_index2 IS NOT NULL) LOOP
    l_complete_approval_list(l_index1) := l_default_approval_list(l_index2);
    l_index1 := l_index1 + 1;
    l_index2 := l_default_approval_list.NEXT(l_index2);
  END LOOP;*/
--end bug 13843060

  validate_approval_list(p_document_id=>p_document_id,
                         p_document_type=>p_document_type,
                         p_document_subtype=>p_document_subtype,
                         p_approval_list=>l_complete_approval_list,
                         p_current_sequence_num=>null,
                         p_return_code=>l_return_code,
                         p_error_stack=>p_error_stack);
  IF (l_return_code <> E_SUCCESS) THEN
    p_return_code := l_return_code;
    RETURN;
  END IF;


  BEGIN

    SAVEPOINT REBUILD_APPROVAL_LIST;

    BEGIN
      l_progress := '013';

      SELECT approval_list_header_id,
             NVL(revision, 0),
             NVL(current_sequence_num, 0),
             first_approver_id,
             approval_path_id,
             last_update_date,
             wf_item_type,
             wf_item_key
      INTO   l_old_approval_list_header_id2,
             l_old_revision,
             l_old_current_sequence_num,
             l_old_first_approver_id,
             l_old_approval_path_id,
             l_old_last_update_date2,
             l_old_wf_item_type2,
             l_old_wf_item_key2
      FROM   po_approval_list_headers
      WHERE  document_id = p_document_id
      AND    document_type = p_document_type
      AND    document_subtype = p_document_subtype
      AND    wf_item_type = l_old_wf_item_type1
      AND    wf_item_key = l_old_wf_item_key1
      AND    latest_revision = 'Y'
      FOR UPDATE;

      IF (l_old_approval_list_header_id1 <> l_old_approval_list_header_id2) OR
         (l_old_last_update_date1 <> l_old_last_update_date2) THEN
        ROLLBACK TO REBUILD_APPROVAL_LIST;
        IF (l_trial >= L_MAX_TRIALS) THEN
          p_return_code := E_LIST_MODIFIED_SINCE_RETRIEVE;
          PushMessage(p_error_stack, 'PO_ALIST_LIST_MODIFIED', 'LIST_ID', l_old_approval_list_header_id1);
          RETURN;
        ELSE
          GOTO BEGINNING;
        END IF;
      END IF;

      l_progress := '014';
      OPEN c_lock_approval_list_lines(l_old_approval_list_header_id2);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ROLLBACK TO REBUILD_APPROVAL_LIST;
        IF (c_lock_approval_list_lines%ISOPEN) THEN
          CLOSE c_lock_approval_list_lines;
        END IF;
        p_return_code := E_NO_APPROVAL_LIST_FOUND;
        PushMessage(p_error_stack, 'PO_ALIST_NO_LIST_FOUND');
        RETURN;
      WHEN OTHERS THEN
        p_return_code := SQLCODE;
        PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'REBUILD_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
        ROLLBACK TO REBUILD_APPROVAL_LIST;
        IF (c_lock_approval_list_lines%ISOPEN) THEN
          CLOSE c_lock_approval_list_lines;
        END IF;
        RETURN;
    END;

    l_progress := '017';

    SELECT po_approval_list_headers_s.nextval
    INTO   l_new_approval_list_header_id
    FROM   sys.dual;

    l_progress := '018';

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
    VALUES(
      l_new_approval_list_header_id,
      p_document_id,
      p_document_type,
      p_document_subtype,
      l_old_revision+1,
      l_old_current_sequence_num,
      'Y',
      l_old_first_approver_id,
      l_old_approval_path_id,
      l_old_wf_item_type2,
      l_old_wf_item_key2,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id,
      fnd_global.user_id,
      SYSDATE);

    BEGIN
      l_progress := '019';

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
      SELECT l_new_approval_list_header_id,
             po_approval_list_lines_s.nextval,
             NULL, -- next_element_id
             approver_id,
             sequence_num,
             notification_id,
             notification_role,
             responder_id,
             forward_to_id,
             mandatory_flag,
             decode(p_rebuild_code, 'DOCUMENT_CHANGED',
                    decode(status, 'APPROVE', 'Y', 'APPROVE_AND_FORWARD', 'Y', requires_reapproval_flag),
                    requires_reapproval_flag),
             approver_type,
             status,
             response_date,
             comments,
             fnd_global.user_id,
             SYSDATE,
             fnd_global.login_id,
             fnd_global.user_id,
             SYSDATE
      FROM   po_approval_list_lines
      WHERE  approval_list_header_id = l_old_approval_list_header_id2
      AND    sequence_num <= l_old_current_sequence_num;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- Get the max sequence number in new lines
    l_progress := '020';

    SELECT NVL(max(sequence_num), 0)
    INTO   l_max_sequence_num
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = l_new_approval_list_header_id;

    IF (l_complete_approval_list.COUNT > 0) THEN
      l_index1 := l_complete_approval_list.FIRST;
      WHILE (l_index1 IS NOT NULL) LOOP
        l_progress := '021.'||to_char(l_index1);

        IF (l_complete_approval_list(l_index1).id IS NULL OR
            l_complete_approval_list(l_index1).sequence_num > l_old_current_sequence_num) THEN
          IF (l_complete_approval_list(l_index1).id IS NULL) THEN
            l_complete_approval_list(l_index1).sequence_num := l_max_sequence_num + 1;
          END IF;
          IF (l_complete_approval_list(l_index1).sequence_num > l_max_sequence_num) THEN
            l_max_sequence_num := l_complete_approval_list(l_index1).sequence_num;
          END IF;
          l_progress := '022.'||to_char(l_index1);
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
          SELECT l_new_approval_list_header_id,
                 po_approval_list_lines_s.nextval,
                 NULL, -- next_element_id
                 l_complete_approval_list(l_index1).approver_id,
                 l_complete_approval_list(l_index1).sequence_num,
                 NULL, -- notification_id
                 NULL, -- notification_role
                 NULL, -- responder_id
                 NULL, -- forward_to_id
                 l_complete_approval_list(l_index1).mandatory_flag,
                 'N',
                 l_complete_approval_list(l_index1).approver_type,
                 NULL, -- status
                 NULL, -- response_date
                 NULL, -- comments
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.login_id,
                 fnd_global.user_id,
                 SYSDATE
          FROM   sys.dual;
          l_index1 := l_complete_approval_list.NEXT(l_index1);
        END IF;
      END LOOP;
    END IF;

    l_progress := '023';

    UPDATE po_approval_list_headers
    SET    latest_revision = 'N',
           last_update_date = SYSDATE,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    document_subtype = p_document_subtype
    AND    approval_list_header_id = l_old_approval_list_header_id2;

    l_progress := '024';

    UPDATE po_approval_list_headers
    SET    last_update_date = SYSDATE
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    document_subtype = p_document_subtype
    AND    approval_list_header_id = l_new_approval_list_header_id;

    COMMIT;
    CLOSE c_lock_approval_list_lines;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_code := SQLCODE;
      PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'REBUILD_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
      ROLLBACK TO REBUILD_APPROVAL_LIST;
      IF (c_lock_approval_list_lines%ISOPEN) THEN
        CLOSE c_lock_approval_list_lines;
      END IF;
      RETURN;
  END;

  p_return_code := E_SUCCESS;
  p_approval_list_header_id := l_new_approval_list_header_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_find_last_forward_to%ISOPEN) THEN
      CLOSE c_find_last_forward_to;
    END IF;
    IF (c_find_last_sys_approver%ISOPEN) THEN
      CLOSE c_find_last_sys_approver;
    END IF;
    IF (c_future_approver%ISOPEN) THEN
      CLOSE c_future_approver;
    END IF;
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'REBUILD_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END rebuild_approval_list;




PROCEDURE validate_approval_list(p_document_id          IN     NUMBER,
                                 p_document_type        IN     VARCHAR2,
                                 p_document_subtype     IN     VARCHAR2,
                                 p_approval_list        IN     ApprovalListType,
                                 p_current_sequence_num IN     NUMBER,
                                 p_return_code          OUT NOCOPY    NUMBER,
                                 p_error_stack          IN OUT NOCOPY ErrorStackType) IS
  l_progress    VARCHAR2(10) := '000';
  l_index       NUMBER;
  l_return_code NUMBER := NULL;
BEGIN

  IF (p_approval_list.COUNT > 0) THEN
    l_index := p_approval_list.FIRST;
    WHILE (l_index IS NOT NULL) LOOP
      IF (NVL(p_approval_list(l_index).sequence_num, 1) > NVL(p_current_sequence_num, 0)) THEN
        l_progress := '001.'||to_char(l_index);
        IF (is_approver_valid(p_document_id=>p_document_id,
                              p_document_type=>p_document_type,
                              p_document_subtype=>p_document_subtype,
                              p_approver_id=>p_approval_list(l_index).approver_id,
                              p_approver_type=>p_approval_list(l_index).approver_type) = FALSE) THEN
          IF (p_approval_list(l_index).approver_disp_name IS NOT NULL) THEN
            PushMessage(p_error_stack, 'PO_ALIST_INVALID_APPR', 'APPROVER', p_approval_list(l_index).approver_disp_name);
          ELSE
            PushMessage(p_error_stack, 'PO_ALIST_INVALID_APPR', 'APPROVER', p_approval_list(l_index).approver_id);
          END IF;
          l_return_code := E_INVALID_APPROVAL_LIST;
        END IF;
        l_progress := '002.'||to_char(l_index);
        IF (p_approval_list(l_index).sequence_num IS NULL) THEN
          IF (p_approval_list(l_index).approver_disp_name IS NOT NULL) THEN
            PushMessage(p_error_stack, 'PO_ALIST_INVALID_SEQ', 'APPROVER', p_approval_list(l_index).approver_disp_name,
                        'SEQ_NUM', p_approval_list(l_index).sequence_num, 'CUR_NUM', NVL(p_current_sequence_num, 0));
          ELSE
            PushMessage(p_error_stack, 'PO_ALIST_INVALID_SEQ', 'APPROVER', p_approval_list(l_index).approver_id,
                        'SEQ_NUM', p_approval_list(l_index).sequence_num, 'CUR_NUM', NVL(p_current_sequence_num, 0));
          END IF;
          l_return_code := E_INVALID_APPROVAL_LIST;
        END IF;
      END IF;
      l_index := p_approval_list.NEXT(l_index);
    END LOOP;
  END IF;
  -- Dont want to default the code to E_SUCCESS at the beginning
  IF (l_return_code IS NULL) THEN
    p_return_code := E_SUCCESS;
  ELSE
    p_return_code := l_return_code;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    PushMessage(p_error_stack, 'PO_ALL_SQL_ERROR', 'ROUTINE', 'VALIDATE_APPROVAL_LIST', 'ERR_NUMBER', l_progress, 'SQL_ERR', SQLERRM(SQLCODE));
END validate_approval_list;




FUNCTION is_approver_valid(p_document_id      IN NUMBER,
                           p_document_type    IN VARCHAR2,
                           p_document_subtype IN VARCHAR2,
                           p_approver_id      IN NUMBER,
                           p_approver_type    IN VARCHAR2) return BOOLEAN IS

  l_flag VARCHAR2(1);

BEGIN

  IF (p_approver_type IS NULL) THEN
    RETURN FALSE;
  END IF;

  SELECT 'Y'
  INTO   l_flag
  FROM   wf_users
  WHERE  orig_system = 'PER' and orig_system_id = p_approver_id and rownum=1;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_approver_valid;


FUNCTION is_approver_mandatory(p_document_id      IN NUMBER,
                               p_document_type    IN VARCHAR2,
                               p_document_subtype IN VARCHAR2,
                               p_preparer_id      IN NUMBER,
                               p_approver_id      IN NUMBER,
                               p_approver_type    IN VARCHAR2) RETURN BOOLEAN IS
  l_profile_value VARCHAR2(240) := NULL;
BEGIN
  fnd_profile.get('POR_SYS_GENERATED_APPROVERS_MANDATORY', l_profile_value);
  RETURN (p_approver_type = 'SYSTEM' AND (l_profile_value IS NULL OR l_profile_value = 'Y'));
END is_approver_mandatory;



PROCEDURE get_next_approver(p_document_id      IN  NUMBER,
                            p_document_type    IN  VARCHAR2,
                            p_document_subtype IN  VARCHAR2,
                            p_return_code      OUT NOCOPY NUMBER,
                            p_next_approver_id OUT NOCOPY NUMBER,
                            p_sequence_num     OUT NOCOPY NUMBER,
                            p_approver_type    OUT NOCOPY VARCHAR2) IS

  CURSOR c_lock_approval_list_lines(p_approval_list_header_id NUMBER) IS
    SELECT approval_list_line_id
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    FOR UPDATE;

  CURSOR c_find_next_approver(p_approval_list_header_id NUMBER,
                              p_current_sequence_num    NUMBER) IS
    SELECT approver_id,
           sequence_num,
           approver_type
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = p_approval_list_header_id
    AND    sequence_num > p_current_sequence_num
    ORDER BY sequence_num;

  l_progress                    VARCHAR2(10) := '000';
  l_old_approval_list_header_id NUMBER;
  l_old_current_sequence_num    NUMBER;
  l_next_approver_id            NUMBER := NULL;
  l_sequence_num                NUMBER := NULL;
  l_approver_type               VARCHAR2(30) := NULL;

  l_current_approver_user_name     VARCHAR2(100);
  l_current_approver_disp_name     VARCHAR2(240);
  l_orig_system                    VARCHAR2(48):='PER';
  l_current_approver_id            NUMBER := NULL;
  l_old_wf_item_type               VARCHAR2(8) := NULL;
  l_old_wf_item_key                VARCHAR2(240) := NULL;

BEGIN

  SAVEPOINT GET_NEXT_APPROVER;
  BEGIN
    l_progress := '001';

    SELECT approval_list_header_id,
           NVL(current_sequence_num, 0),
           wf_item_type,
           wf_item_key
    INTO   l_old_approval_list_header_id,
           l_old_current_sequence_num,
           l_old_wf_item_type,
           l_old_wf_item_key
    FROM   po_approval_list_headers
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    document_subtype = p_document_subtype
    AND    latest_revision = 'Y'
    FOR UPDATE;

    /* bug#1639030: kagarwal
    ** set appropriate value for workflow attribute
    **    FORWARD_FROM_ID,
    **    FORWARD_FROM_USER_NAME,
    **    FORWARD_FROM_DISP_NAME
    ** before we update the po_approval_list_headers
    */

    IF (l_old_current_sequence_num > 0 )  THEN

       SELECT approver_id
         INTO l_current_approver_id
         FROM po_approval_list_lines
        WHERE approval_list_header_id = l_old_approval_list_header_id
          AND sequence_num = l_old_current_sequence_num;


        wf_engine.SetItemAttrNumber ( itemtype   => l_old_wf_item_type,
                                      itemkey    => l_old_wf_item_key,
                                      aname      => 'FORWARD_FROM_ID',
                                      avalue     => l_current_approver_id);

        WF_DIRECTORY.GetUserName(l_orig_system,
                                 l_current_approver_id,
                                 l_current_approver_user_name,
                                 l_current_approver_disp_name);

        wf_engine.SetItemAttrText( itemtype   => l_old_wf_item_type,
                                   itemkey    => l_old_wf_item_key,
                                   aname      => 'FORWARD_FROM_USER_NAME' ,
                                   avalue     => l_current_approver_user_name);


        wf_engine.SetItemAttrText( itemtype   => l_old_wf_item_type,
                                   itemkey    => l_old_wf_item_key,
                                   aname      => 'FORWARD_FROM_DISP_NAME' ,
                                   avalue     => l_current_approver_disp_name);

    END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO GET_NEXT_APPROVER;
      p_return_code := E_NO_APPROVAL_LIST_FOUND;
      RETURN;
  END;

  OPEN c_lock_approval_list_lines(l_old_approval_list_header_id);

  l_progress := '002';

  OPEN c_find_next_approver(l_old_approval_list_header_id, l_old_current_sequence_num);
  FETCH c_find_next_approver INTO l_next_approver_id, l_sequence_num, l_approver_type;

  IF (c_find_next_approver%NOTFOUND) THEN
    ROLLBACK TO GET_NEXT_APPROVER;
    CLOSE c_find_next_approver;
    p_next_approver_id := NULL;
    p_sequence_num := NULL;
    p_approver_type := NULL;
    p_return_code := E_NO_NEXT_APPROVER_FOUND;
    RETURN;
  END IF;

  CLOSE c_find_next_approver;

  IF (is_approver_valid(p_document_id=>p_document_id,
                        p_document_type=>p_document_type,
                        p_document_subtype=>p_document_subtype,
                        p_approver_id=>l_next_approver_id,
                        p_approver_type=>l_approver_type) = FALSE) THEN
    ROLLBACK TO GET_NEXT_APPROVER;
    p_next_approver_id := NULL;
    p_sequence_num := NULL;
    p_approver_type := NULL;
    p_return_code := E_INVALID_APPROVER;
    RETURN;
  END IF;

  l_progress := '003';

  UPDATE po_approval_list_headers
  SET    current_sequence_num = l_sequence_num,
         last_update_date = SYSDATE,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
  WHERE  document_id = p_document_id
  AND    document_type = p_document_type
  AND    document_subtype = p_document_subtype
  AND    approval_list_header_id = l_old_approval_list_header_id;

  COMMIT;
  CLOSE c_lock_approval_list_lines;

  p_next_approver_id := l_next_approver_id;
  p_sequence_num     := l_sequence_num;
  p_approver_type    := l_approver_type;
  p_return_code      := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    ROLLBACK TO GET_NEXT_APPROVER;
    IF (c_lock_approval_list_lines%ISOPEN) THEN
      CLOSE c_lock_approval_list_lines;
    END IF;
    IF (c_find_next_approver%ISOPEN) THEN
      CLOSE c_find_next_approver;
    END IF;
    p_next_approver_id := NULL;
    p_sequence_num := NULL;
    p_approver_type := NULL;
END get_next_approver;




PROCEDURE does_approval_list_exist(p_document_id             IN  NUMBER,
                                   p_document_type           IN  VARCHAR2,
                                   p_document_subtype        IN  VARCHAR2,
                                   p_itemtype                IN  VARCHAR2,
                                   p_itemkey                 IN  VARCHAR2,
                                   p_return_code             OUT NOCOPY NUMBER,
                                   p_approval_list_header_id OUT NOCOPY NUMBER) IS

  l_progress VARCHAR2(10) := '000';

BEGIN

  l_progress := '001';

  SELECT approval_list_header_id
  INTO   p_approval_list_header_id
  FROM   po_approval_list_headers
  WHERE  document_id = p_document_id
  AND    document_type = p_document_type
  AND    document_subtype = p_document_subtype
  AND    latest_revision = 'Y'
  AND    ((wf_item_type IS NULL AND p_itemtype IS NULL) OR
          (wf_item_type = p_itemtype))
  AND    ((wf_item_key IS NULL AND p_itemkey IS NULL) OR
          (wf_item_key = p_itemkey));

  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_approval_list_header_id := NULL;
    p_return_code := E_SUCCESS;
  WHEN OTHERS THEN
    p_approval_list_header_id := NULL;
    p_return_code := SQLCODE;
END does_approval_list_exist;

PROCEDURE update_approval_list_itemkey(p_approval_list_header_id IN  NUMBER,
                                       p_itemtype                IN  VARCHAR2,
                                       p_itemkey                 IN  VARCHAR2,
                                       p_return_code             OUT NOCOPY NUMBER) IS
  l_progress VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';

  UPDATE po_approval_list_headers
  SET    wf_item_type = p_itemtype,
         wf_item_key = p_itemkey,
         last_update_date = SYSDATE,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
  WHERE  approval_list_header_id = p_approval_list_header_id;

  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
END update_approval_list_itemkey;

PROCEDURE update_approval_list_response(p_document_id      IN  NUMBER,
                                        p_document_type    IN  VARCHAR2,
                                        p_document_subtype IN  VARCHAR2,
                                        p_itemtype         IN  VARCHAR2,
                                        p_itemkey          IN  VARCHAR2,
                                        p_approver_id      IN  NUMBER,
                                        p_responder_id     IN  NUMBER,
                                        p_forward_to_id    IN  NUMBER,
                                        p_response         IN  VARCHAR2,
                                        p_response_date    IN  DATE,
                                        p_comments         IN  VARCHAR2,
                                        p_return_code      OUT NOCOPY NUMBER) IS
pragma AUTONOMOUS_TRANSACTION;

  l_progress                VARCHAR2(10) := '000';
  l_approval_list_header_id NUMBER;
  l_current_sequence_num    NUMBER;
  l_approval_list_line_id   NUMBER;
  l_return_code             NUMBER;

  l_line_found              BOOLEAN;

BEGIN

  l_progress := '005';

  SELECT approval_list_header_id,
         NVL(current_sequence_num, 0)
  INTO   l_approval_list_header_id,
         l_current_sequence_num
  FROM   po_approval_list_headers
  WHERE  document_id = p_document_id
  AND    document_type = p_document_type
  AND    document_subtype = p_document_subtype
  AND    wf_item_type = p_itemtype
  AND    wf_item_key = p_itemkey
  AND    latest_revision = 'Y'
  FOR UPDATE;

  BEGIN
    l_progress := '006';

    SELECT approval_list_line_id
    INTO   l_approval_list_line_id
    FROM   po_approval_list_lines
    WHERE  approval_list_header_id = l_approval_list_header_id
    AND    approver_id = p_approver_id
    AND    sequence_num = l_current_sequence_num
    FOR UPDATE;

    l_line_found := TRUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      /* Bug 2092663 by dkfchan
       * If there is no line to update. Add a new one
       */

      l_line_found := FALSE;

  END;

  l_progress := '007';

  IF l_line_found THEN

        UPDATE po_approval_list_lines
        SET    status = p_response,
               forward_to_id = p_forward_to_id,
               responder_id = p_responder_id,
               response_date = p_response_date,
               comments = substrb(p_comments,1,480),
               last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  approval_list_line_id = l_approval_list_line_id;

        UPDATE po_approval_list_headers
        SET    last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  approval_list_header_id = l_approval_list_header_id;

  ELSE

        /* Bug 2092663: Add a new line if there is header but no line */

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
        VALUES
           (
               l_approval_list_header_id,
               po_approval_list_lines_s.nextval,
               NULL,
               p_responder_id,
               1,
               null,
               null,
               p_responder_id,
               p_forward_to_id,
               'N',
               'N',
               'FORWARD',
               'FORWARD',
               SYSDATE,
               '',
               fnd_global.user_id,
               SYSDATE,
               fnd_global.login_id,
               fnd_global.user_id,
               SYSDATE
           );

        UPDATE po_approval_list_headers
        SET    current_sequence_num = 1,
               last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  approval_list_header_id = l_approval_list_header_id;

  END IF;

  l_progress := '008';

  COMMIT;

  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    ROLLBACK TO UPDATE_RESPONSE;
END update_approval_list_response;



PROCEDURE is_approval_list_exhausted(p_document_id      IN  VARCHAR2,
                                     p_document_type    IN  VARCHAR2,
                                     p_document_subtype IN  VARCHAR2,
                                     p_itemtype         IN  VARCHAR2,
                                     p_itemkey          IN  VARCHAR2,
                                     p_return_code      OUT NOCOPY NUMBER,
                                     p_result           OUT NOCOPY BOOLEAN) IS
  l_progress                VARCHAR2(10) := '000';
  l_approval_list_header_id NUMBER;
  l_current_sequence_num    NUMBER;
  l_count                   NUMBER;

BEGIN

  l_progress := '001';

  SELECT approval_list_header_id,
         NVL(current_sequence_num, 0)
  INTO   l_approval_list_header_id,
         l_current_sequence_num
  FROM   po_approval_list_headers
  WHERE  document_id = p_document_id
  AND    document_type = p_document_type
  AND    document_subtype = p_document_subtype
  AND    wf_item_type = p_itemtype
  AND    wf_item_key = p_itemkey
  AND    latest_revision = 'Y';

  l_progress := '002';

  SELECT COUNT(*)
  INTO   l_count
  FROM   po_approval_list_lines
  WHERE  approval_list_header_id = l_approval_list_header_id
  AND    sequence_num > l_current_sequence_num;

  p_return_code := E_SUCCESS;
  IF (l_count > 0) THEN
    p_result := FALSE;
  ELSE
    p_result := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    p_result := NULL;
END is_approval_list_exhausted;


PROCEDURE print_approval_list(p_approval_list IN ApprovalListType) IS
  l_index NUMBER;
BEGIN
  IF (p_approval_list.COUNT > 0) THEN
    -- dbms_output.put_line('Count = '||to_char(p_approval_list.COUNT));
    -- dbms_output.put_line('-- Approval List: -------------------------------------');
    l_index := p_approval_list.FIRST;
    WHILE (l_index IS NOT NULL) LOOP
      -- dbms_output.put_line('id                   = ' || to_char(p_approval_list(l_index).id));
      -- dbms_output.put_line('sequence_num         = ' || to_char(p_approval_list(l_index).sequence_num));
      -- dbms_output.put_line('approver_id          = ' || to_char(p_approval_list(l_index).approver_id));
      -- dbms_output.put_line('approver_disp_name   = ' || p_approval_list(l_index).approver_disp_name);
      -- dbms_output.put_line('responder_id         = ' || to_char(p_approval_list(l_index).responder_id));
      -- dbms_output.put_line('responder_disp_name  = ' || p_approval_list(l_index).responder_disp_name);
      -- dbms_output.put_line('forward_to_id        = ' || to_char(p_approval_list(l_index).forward_to_id));
      -- dbms_output.put_line('forward_to_disp_name = ' || p_approval_list(l_index).forward_to_disp_name);
      -- dbms_output.put_line('status               = ' || p_approval_list(l_index).status);
      -- dbms_output.put_line('approver_type        = ' || p_approval_list(l_index).approver_type);
      -- dbms_output.put_line('mandatory_flag       = ' || p_approval_list(l_index).mandatory_flag);
      -- dbms_output.put_line('-------------------------------------------------------');
      l_index := p_approval_list.NEXT(l_index);
    END LOOP;
  ELSE
    NULL;
    -- dbms_output.put_line('-- Approval List is empty -----------------------------');
  END IF;
END print_approval_list;


PROCEDURE retrieve_messages(p_error_stack   IN  ErrorStackType,
                            p_return_code   OUT NOCOPY NUMBER,
                            p_message_stack OUT NOCOPY MessageStackType) IS
  l_progress   VARCHAR2(10) := '000';
  l_index      NUMBER;
  l_num_tokens NUMBER;
BEGIN

  IF (p_error_stack.COUNT <= 0) THEN
    p_return_code := E_EMPTY_ERROR_STACK;
    RETURN;
  END IF;

  l_index := p_error_stack.FIRST;
  WHILE (l_index IS NOT NULL) LOOP
    l_progress := '001.'||to_char(l_index);
    SetMessage(p_error_stack(l_index));
    l_progress := '002.'||to_char(l_index);
    p_message_stack(l_index) := fnd_message.get;
    l_index := p_error_stack.NEXT(l_index);
  END LOOP;
  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
END retrieve_messages;

PROCEDURE print_error_stack(p_error_stack IN ErrorStackType) IS
  l_index         NUMBER;
  l_return_code   NUMBER;
  l_message_stack MessageStackType;
BEGIN

  IF (p_error_stack.COUNT > 0) THEN
    retrieve_messages(p_error_stack=>p_error_stack,
                      p_return_code=>l_return_code,
                      p_message_stack=>l_message_stack);
    IF (l_return_code <> E_SUCCESS) THEN
      RETURN;
    END IF;
    -- dbms_output.put_line('-- Error Stack: ---------------------------------------');
    l_index := l_message_stack.FIRST;
    WHILE (l_index IS NOT NULL) LOOP
      -- dbms_output.put_line(substr(l_message_stack(l_index), 1, 250));
      -- dbms_output.put_line('-------------------------------------------------------');
      l_index := l_message_stack.NEXT(l_index);
    END LOOP;
  ELSE
    NULL;
    -- dbms_output.put_line('-- Error Stack is empty -------------------------------');
  END IF;
END print_error_stack;


PROCEDURE forms_rebuild_approval_list(p_document_id             IN  NUMBER,
                                      p_document_type           IN  VARCHAR2,
                                      p_document_subtype        IN  VARCHAR2,
                                      p_rebuild_code            IN  VARCHAR2,
                                      p_return_code             OUT NOCOPY NUMBER,
                                      p_approval_list_header_id OUT NOCOPY NUMBER) IS
  l_return_code   NUMBER;
  l_error_stack   ErrorStackType;
BEGIN

  rebuild_approval_list(p_document_id=>p_document_id,
                        p_document_type=>p_document_type,
                        p_document_subtype=>p_document_subtype,
                        p_rebuild_code=>p_rebuild_code,
                        p_return_code=>l_return_code,
                        p_error_stack=>l_error_stack,
                        p_approval_list_header_id=>p_approval_list_header_id);

  IF (l_return_code <> E_SUCCESS) THEN
    IF (l_error_stack.COUNT > 0) THEN
      SetMessage(l_error_stack(l_error_stack.FIRST));
    END IF;
  END IF;

  p_return_code := l_return_code;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
END forms_rebuild_approval_list;

END PO_APPROVALLIST_S1;

/
