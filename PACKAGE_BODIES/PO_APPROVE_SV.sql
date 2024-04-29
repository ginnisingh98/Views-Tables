--------------------------------------------------------
--  DDL for Package Body PO_APPROVE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVE_SV" AS
/* $Header: POXAPAPB.pls 115.6 2004/06/24 23:27:26 zxzhang ship $*/

/*===========================================================================

  PROCEDURE NAME:       test_get_document_types

===========================================================================*/

  PROCEDURE test_get_document_types (x_document_type_code  IN   VARCHAR2,
                                    x_document_subtype    IN    VARCHAR2) IS
        x_can_change_forward_from_flag   VARCHAR2(30) := '';
        x_can_change_forward_to_flag     VARCHAR2(30) := '';
        x_can_change_approval_path       VARCHAR2(30) := '';
        x_default_approval_path_id       NUMBER  := '';
        x_can_preparer_approve_flag      VARCHAR2(30) := '';
	x_can_approver_modify_flag   VARCHAR2(30) := '';

  BEGIN

    --dbms_output.put_line('before call');

    po_approve_sv.get_document_types(x_document_type_code,
                                    x_document_subtype,
				    x_can_change_forward_from_flag,
       				    x_can_change_forward_to_flag,
       				    x_can_change_approval_path,
        			    x_default_approval_path_id,
        			    x_can_preparer_approve_flag,
				    x_can_approver_modify_flag);

    --dbms_output.put_line('after call');
    --dbms_output.put_line('Can Change Forward From ='||x_can_change_forward_from_flag);
    --dbms_output.put_line('Can Change Forward To ='||x_can_change_forward_to_flag);
    --dbms_output.put_line('Can Change Approval Path  ='||x_can_change_approval_path);
    --dbms_output.put_line('Can Preparer Approve ='||x_can_preparer_approve_flag);

  END test_get_document_types;


/*===========================================================================

  PROCEDURE NAME:	get_document_types

===========================================================================*/

PROCEDURE get_document_types (
	x_document_type_code		 IN	VARCHAR2,
	x_document_subtype		 IN	VARCHAR2,
	x_can_change_forward_from_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_change_forward_to_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_change_approval_path	 IN OUT	NOCOPY VARCHAR2,
	x_default_approval_path_id	 IN OUT	NOCOPY NUMBER,
	x_can_preparer_approve_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_approver_modify_flag       IN OUT NOCOPY VARCHAR2)
IS
    x_progress	  VARCHAR2(3);
BEGIN
    x_progress := '010';

    IF (x_document_type_code IS NOT NULL AND
	x_document_subtype IS NOT NULL) THEN

	x_progress := '020';

        SELECT podt.can_change_forward_from_flag,
	       podt.can_change_forward_to_flag,
	       podt.can_change_approval_path_flag,
 	       podt.can_preparer_approve_flag,
	       podt.default_approval_path_id,
	       podt.can_approver_modify_doc_flag
        INTO   x_can_change_forward_from_flag,
	       x_can_change_forward_to_flag,
	       x_can_change_approval_path,
	       x_can_preparer_approve_flag,
	       x_default_approval_path_id,
	       x_can_approver_modify_flag
        FROM   po_document_types podt
        WHERE  podt.document_type_code = x_document_type_code
        AND    podt.document_subtype = x_document_subtype;

        --dbms_output.put_line('Can Change Forward From ='||x_can_change_forward_from_flag);
        --dbms_output.put_line('Can Change Forward To ='||x_can_change_forward_to_flag);
        --dbms_output.put_line('Can Change Approval Path  ='||x_can_change_approval_path);
        --dbms_output.put_line('Can Preparer Approve ='||x_can_preparer_approve_flag);
	--dbms_output.put_line('Can Approver Modify Doc ='||x_can_approver_modify_flag);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('PO_APPROVE_SV.GET_DOCUMENT_TYPES', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       test_get_approval_path

===========================================================================*/

  PROCEDURE test_get_approval_path (	x_default_approval_path_id   IN NUMBER,
					x_forward_from_id	     IN	NUMBER,
					x_object_id	             IN	NUMBER,
					x_document_type_code	     IN	VARCHAR2,
					x_document_subtype	     IN VARCHAR2) IS
        x_approval_path		 VARCHAR2(30);
	x_approval_path_id       NUMBER;
  BEGIN

    --dbms_output.put_line('before call');

    po_approve_sv.get_approval_path (x_default_approval_path_id,
				   x_forward_from_id,
				   x_object_id,
				   x_document_type_code,
				   x_document_subtype,
				   x_approval_path,
				   x_approval_path_id) ;

    --dbms_output.put_line('after call');
    --dbms_output.put_line('Approval path ='||x_approval_path);
    --dbms_output.put_line('Approval path ID ='||TO_CHAR(x_approval_path_id));

  END;


/*===========================================================================

  PROCEDURE NAME:	get_approval_path()

===========================================================================*/

PROCEDURE get_approval_path (
	x_default_approval_path_id   IN 	NUMBER,
	x_forward_from_id	     IN		NUMBER,
	x_object_id	             IN		NUMBER,
	x_document_type_code	     IN		VARCHAR2,
	x_document_subtype	     IN 	VARCHAR2,
	x_approval_path		     OUT	NOCOPY VARCHAR2,
	x_approval_path_id           OUT	NOCOPY NUMBER)
IS
	x_progress			VARCHAR2(3);
	x_data_found_flag		BOOLEAN;
BEGIN
    IF (x_object_id IS NOT NULL
	AND x_document_type_code IS NOT NULL
	AND x_document_subtype IS NOT NULL) THEN

        BEGIN

	    -- If this is not the first action on this document, use the
	    -- same approval path as the previous action on this document.

	    SELECT  pps.name,
                    pah.approval_path_id
            INTO    x_approval_path,
                    x_approval_path_id
            FROM    per_position_structures pps,
                    po_action_history pah
            WHERE   pah.approval_path_id     = pps.position_structure_id
            AND     pah.object_id            = x_object_id
            AND     pah.object_type_code     = x_document_type_code
            AND     pah.object_sub_type_code = x_document_subtype
            AND     pah.sequence_num =
                        (SELECT max(sequence_num)
                        FROM   po_action_history PAH2
                        WHERE  PAH2.object_id            = x_object_id
                        AND    PAH2.object_type_code     = x_document_type_code
                        AND    PAH2.object_sub_type_code = x_document_subtype
                        AND    PAH2.action_code is not null);

  	    x_data_found_flag := TRUE;

	EXCEPTION
   	    when NO_DATA_FOUND then
	        x_data_found_flag := FALSE;
        END;

    ELSE
	x_data_found_flag := FALSE;
    END IF;

    -- If this is the first action on the document, use
    -- the default approval path only if the forward_from
    -- person belongs to the same path

    IF (x_data_found_flag = FALSE) THEN

        IF (x_default_approval_path_id IS NOT NULL
	    AND x_forward_from_id IS NOT NULL) THEN

	    BEGIN

  	        SELECT DISTINCT pps.name,
  	               pps.position_structure_id
   	        INTO    x_approval_path,
 	                x_approval_path_id
   	        FROM    po_employee_hierarchies peh,
         	        per_position_structures pps
  	        WHERE   peh.position_structure_id = pps.position_structure_id
 	        AND     pps.position_structure_id = x_default_approval_path_id
 	        AND     peh.employee_id           = x_forward_from_id;

	    EXCEPTION
   	        when NO_DATA_FOUND then
		    return;
            END;

        ELSE
	   return;
        END IF;
    END IF;

EXCEPTION
    -- If this is the first action on the document and the
    -- foward_from person does not belong to the default approval
    -- path, then do not default in approval path.

    WHEN NO_DATA_FOUND THEN
	RETURN;
    WHEN OTHERS THEN
	PO_MESSAGE_S.SQL_ERROR('PO_APPROVE_SV.GET_APPROVAL_PATH', x_progress, sqlcode);
	RAISE;
END;


/* RETROACTIVE FPI START */
PROCEDURE get_document_types (
        p_document_type_code             IN     VARCHAR2,
        p_document_subtype               IN     VARCHAR2,
        x_can_change_forward_from_flag      OUT NOCOPY VARCHAR2,
        x_can_change_forward_to_flag        OUT NOCOPY VARCHAR2,
        x_can_change_approval_path          OUT NOCOPY VARCHAR2,
        x_default_approval_path_id          OUT NOCOPY NUMBER,
        x_can_preparer_approve_flag         OUT NOCOPY VARCHAR2,
        x_can_approver_modify_flag          OUT NOCOPY VARCHAR2,
        x_forwarding_mode_code              OUT NOCOPY VARCHAR2,
        x_wf_approval_itemtype              OUT NOCOPY VARCHAR2,
        x_wf_approval_process               OUT NOCOPY VARCHAR2,
	x_type_name                         OUT NOCOPY VARCHAR2) IS

l_progress Varchar2(3);

begin
	l_progress := '000';

	If ((p_document_type_code is NOT NULL) AND
	    (p_document_subtype is NOT NULL)) THEN
		l_progress := '010';

		  SELECT podt.can_change_forward_from_flag,
		       podt.can_change_forward_to_flag,
		       podt.can_change_approval_path_flag,
		       podt.can_preparer_approve_flag,
		       podt.default_approval_path_id,
		       podt.can_approver_modify_doc_flag,
		       podt.forwarding_mode_code,
		       podt.wf_approval_itemtype,
		       podt.wf_approval_process,
		       podt.type_name
		  INTO   x_can_change_forward_from_flag,
		       x_can_change_forward_to_flag,
		       x_can_change_approval_path,
		       x_can_preparer_approve_flag,
		       x_default_approval_path_id,
		       x_can_approver_modify_flag,
		       x_forwarding_mode_code,
		       x_wf_approval_itemtype,
		       x_wf_approval_process,
		       x_type_name
		  FROM   po_document_types podt
		  WHERE  podt.document_type_code = p_document_type_code
		  AND    podt.document_subtype = p_document_subtype;

	end if;

EXCEPTION
    WHEN OTHERS THEN
	PO_MESSAGE_S.SQL_ERROR('PO_APPROVE_SV.GET_DOCUMENT_TYPES',
		l_progress, sqlcode);
	RAISE;
END get_document_types;
/* RETROACTIVE FPI END */


-- <FPJ Redesign Approval Window START>
/**
* Public Procedure: get_change_summary
* Requires:
*   IN PARAMETERS:
*     p_document_type_code: The document type code
*     p_document_header_id: The id of document header
*
* Modifies: None.
* Effects:  This procedure gets change summary
*
* Returns:
*  x_change_summary: Contains change summary
*/
PROCEDURE get_change_summary(p_document_type_code	IN	   VARCHAR2,
                             p_document_header_id	IN	   NUMBER,
                             x_change_summary		OUT NOCOPY VARCHAR2)
IS
  cursor po_reasons(p_po_header_id NUMBER) IS
  -- SQL What: Querying for response reasons for po change
  -- SQL Why:  Need to concatenate these reasons to default
  --           field change summary
  -- SQL Join: po_header_id
  select response_reason
  from   po_change_requests
  where  document_header_id = p_po_header_id
  -- Bug 3711787
  and    change_active_flag = 'Y'
  -- Bug 3326904
  and    po_release_id IS NULL;
  -- and    request_status = 'BUYER_APP';

  cursor release_reasons(p_po_release_id NUMBER) IS
  -- SQL What: Querying for response reasons for release change
  -- SQL Why:  Need to concatenate these reasons to default
  --           field change summary
  -- SQL Join: po_release_id
  select response_reason
  from   po_change_requests
  where  po_release_id = p_po_release_id
  -- Bug 3711787
  and    change_active_flag = 'Y';
  -- Bug 3326904
  -- and    request_status = 'BUYER_APP';

  l_progress		Varchar2(3);
  l_reasons		dbms_sql.varchar2_table;
  l_additional_changes	PO_CHANGE_REQUESTS.additional_changes%TYPE := NULL;
BEGIN

  l_progress := '000';
  x_change_summary := '';

  if (p_document_type_code in ('PO', 'PA')) then
    l_progress := '010';
    open po_reasons (p_document_header_id);
    fetch po_reasons bulk collect into l_reasons;
    for i in 1..l_reasons.COUNT loop
      x_change_summary := x_change_summary || l_reasons(i);
    end loop;

  elsif (p_document_type_code = 'RELEASE') then
    l_progress := '050';
    open release_reasons (p_document_header_id);
    fetch release_reasons bulk collect into l_reasons;
    for i in 1..l_reasons.COUNT loop
      x_change_summary := x_change_summary || l_reasons(i);
    end loop;

  else
    x_change_summary := '';
  end if; /* (p_document_type_code in ('PO', 'PA')) */

  l_progress := '100';
EXCEPTION
    WHEN OTHERS THEN
      -- PO_MESSAGE_S.SQL_ERROR('PO_APPROVE_SV.get_change_summary',
      --	             l_progress, sqlcode);
      -- RAISE;
      NULL;
END get_change_summary;
-- <FPJ Redesign Approval Window END>


END PO_APPROVE_SV;

/
