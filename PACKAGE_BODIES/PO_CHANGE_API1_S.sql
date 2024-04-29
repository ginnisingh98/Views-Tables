--------------------------------------------------------
--  DDL for Package Body PO_CHANGE_API1_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHANGE_API1_S" AS
/* $Header: POXCHN1B.pls 120.7.12010000.5 2013/09/12 10:53:29 jemishra ship $*/

  g_pkg_name CONSTANT VARCHAR2(50) := 'PO_CHANGE_API1_S';

  g_sysdate	DATE := SYSDATE;
  g_user_id	NUMBER := fnd_global.user_id;
  g_login_id	NUMBER := fnd_global.login_id;

FUNCTION record_acceptance
(
  X_PO_NUMBER			VARCHAR2,
  X_RELEASE_NUMBER		NUMBER,
  X_REVISION_NUMBER		NUMBER,
  X_ACTION			VARCHAR2,
  X_ACTION_DATE			DATE,
  X_EMPLOYEE_ID			NUMBER,
  X_ACCEPTED_FLAG		VARCHAR2,
  X_ACCEPTANCE_LOOKUP_CODE	VARCHAR2,
  X_NOTE			LONG,
  X_INTERFACE_TYPE      	VARCHAR2,
  X_TRANSACTION_ID      	NUMBER,
  VERSION			VARCHAR2,
  p_org_id          IN NUMBER
) RETURN NUMBER IS

  l_po_header_id		NUMBER := NULL;
  l_po_release_id		NUMBER := NULL;
  l_current_revision		NUMBER := NULL;
  l_doc_type			VARCHAR2(30);
  l_doc_subtype			VARCHAR2(30);
  l_INTERFACE_TYPE		VARCHAR2(25);
  l_TRANSACTION_ID		NUMBER := NULL;
  l_count			NUMBER := NULL;
  l_result			NUMBER := 1;
  l_employee_id			NUMBER := NULL;

   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_Last_Updated_By    PO_ACCEPTANCES.last_updated_by%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   --  End of Bug 2850566
  l_org_id              PO_HEADERS_ALL.org_id%type := p_org_id;
  CURSOR c_po_header IS
    select  PO_HEADER_ID
      from  PO_HEADERS
     where  segment1 = X_PO_NUMBER
       and  type_lookup_code in ('STANDARD', 'BLANKET', 'CONTRACT', 'PLANNED');

  CURSOR c_po_release IS
    select po_release_id
      from po_releases
     where po_header_id = l_po_header_id
       and release_num = X_RELEASE_NUMBER;

BEGIN

    IF (X_TRANSACTION_ID is null) then
       select PO_INTERFACE_ERRORS_S.nextval
       into l_TRANSACTION_ID from sys.dual;
    else
       l_TRANSACTION_ID := X_TRANSACTION_ID;
    end if;

    l_INTERFACE_TYPE := nvl(X_INTERFACE_TYPE, 'CHANGEPO');

    --<Bug#4581621 Start>
    PO_MOAC_UTILS_PVT.validate_orgid_pub_api(x_org_id => l_org_id);
    PO_MOAC_UTILS_PVT.set_policy_context('S',l_org_id);
    --<Bug#4581621 End>

    l_result := PO_CHANGE_API1_S.check_mandatory_params(
					X_PO_NUMBER,
					X_REVISION_NUMBER,
					VERSION,
					l_INTERFACE_TYPE,
					l_transaction_id);
    if (l_result = 0) then
       return l_result;
    end if;

    if (X_ACCEPTED_FLAG not in ('Y','N') or
        X_ACCEPTED_FLAG is null) then
       PO_CHANGE_API1_S.insert_error(l_interface_type,
				     l_transaction_id,
                                     'X_ACCEPTED_FLAG',
				     NULL,
				     'PO_CHNG_INVALID_ACCEPTED_FLAG',
				     NULL,
				     NULL);
       return 0;
    end if;

    if (X_ACCEPTANCE_LOOKUP_CODE is null) then
       PO_CHANGE_API1_S.insert_error(l_interface_type,
				     l_transaction_id,
                                     'X_ACCEPTANCE_LOOKUP_CODE',
				     NULL,
				     'PO_ALL_CNL_PARAM_NULL',
				     NULL,
				     NULL);
       return 0;
    else
       select count(*)
         into l_count
         from PO_LOOKUP_CODES
        where lookup_type = 'ACCEPTANCE TYPE'
          and lookup_code = X_ACCEPTANCE_LOOKUP_CODE;

       if (l_count = 0) then
          PO_CHANGE_API1_S.insert_error(l_interface_type,
				        l_transaction_id,
                                        'X_ACCEPTANCE_LOOKUP_CODE',
				        NULL,
				        'PO_CHNG_INVALID_ACC_LK_CODE',
				        NULL,
				        NULL);
          return 0;
       end if;
    end if;

    OPEN c_po_header;
      FETCH c_po_header INTO l_po_header_id;

      if (c_po_header%NOTFOUND or l_po_header_id is null) then
         PO_CHANGE_API1_S.insert_error(l_interface_type,
                                     l_transaction_id,
                                     'PO_HEADER_ID',
				     'PO_HEADERS',
                                     'PO_NOPOFOUND',
				     NULL,
				     NULL);
         return 0;
      end if;
    CLOSE c_po_header;

    IF (X_RELEASE_NUMBER is not null) THEN
       OPEN c_po_release;
         FETCH c_po_release INTO l_po_release_id;

         if (c_po_release%NOTFOUND or
             l_po_release_id is null) then
            PO_CHANGE_API1_S.insert_error(l_interface_type,
                                        l_transaction_id,
                                        'PO_RELEASE_ID',
				        'PO_RELEASES',
                                        'PO_CHNG_INVALID_RELEASE_NUM',
				        NULL,
				        NULL);
            return 0;
         end if;
       CLOSE c_po_release;

       l_employee_id := X_employee_id;

       l_result := PO_CHANGE_API1_S.validate_acceptance(
						null,
						l_po_release_id,
						l_employee_id,
						X_REVISION_NUMBER,
						l_current_revision,
						l_interface_type,
						l_transaction_id);

    ELSE
       l_employee_id := X_employee_id;          --bug12638303

       l_result := PO_CHANGE_API1_S.validate_acceptance(
						l_po_header_id,
						null,
						l_employee_id,
						X_REVISION_NUMBER,
						l_current_revision,
						l_interface_type,
						l_transaction_id);
    END IF;

    if (l_result = 0) then
       return l_result;
    else

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF l_po_release_id IS NULL THEN
     l_acc_po_header_id := l_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                  =>  l_rowid,
			x_acceptance_id			 =>  l_acceptance_id,
            x_Last_Update_Date       =>  l_Last_Update_Date,
            x_Last_Updated_By        =>  l_Last_Updated_By,
            x_Last_Update_Login      =>  l_Last_Update_Login,
			p_creation_date			 =>  g_sysdate,
			p_created_by			 =>  g_user_id,
			p_po_header_id			 =>  l_acc_po_header_id,
			p_po_release_id			 =>  l_Po_Release_Id,
			p_action			     =>  nvl(X_ACTION, 'ACCPO'),
			p_action_date			 =>  nvl(X_ACTION_DATE, g_sysdate),
			p_employee_id			 =>  l_employee_id,
			p_revision_num			 =>  X_REVISION_NUMBER,
			p_accepted_flag			 =>  X_ACCEPTED_FLAG,
            p_acceptance_lookup_code =>  X_ACCEPTANCE_LOOKUP_CODE,
			p_note                   =>  X_NOTE);

   --  End of Bug 2850566 RBAIRRAJ

 /*Bug # 5597797 The below code is modified to update the acceptance required flag to 'N' only if the a_accepted_flag is 'Y'.
     This is in sync with the functionality of the Enter PO --> Tools --> Acceptances form.*/

      IF (X_REVISION_NUMBER = l_current_revision) then
        IF x_accepted_flag = 'Y' THEN
	  IF (l_po_release_id is null) then
              update PO_HEADERS
	       /* Changed ACCEPTANCE_REQUIRED_FLAG value from null to N*/
              set ACCEPTANCE_REQUIRED_FLAG = 'N', -- bug 4721255
         	   ACCEPTANCE_DUE_DATE = null,
         	   last_update_date = g_sysdate,
         	   last_updated_by = g_user_id
             where PO_HEADER_ID = l_po_header_id;
          ELSE
            update PO_RELEASES
            set ACCEPTANCE_REQUIRED_FLAG = 'N', -- bug 4721255
         	   ACCEPTANCE_DUE_DATE = null,
         	   last_update_date = g_sysdate,
         	   last_updated_by = g_user_id
            where PO_RELEASE_ID = l_po_release_id;
         END IF;
        END IF;
      END IF;

   END IF;
--  End Bug # 5597797
   return l_result;

   EXCEPTION
     WHEN OTHERS THEN
       return 0;
END record_acceptance;

FUNCTION validate_acceptance
( X_po_header_id 	IN	NUMBER,
  X_po_release_id 	IN	NUMBER,
  X_employee_id 	IN OUT	NOCOPY NUMBER,
  X_revision_num	IN	NUMBER,
  X_current_revision	IN OUT	NOCOPY NUMBER,
  X_interface_type	IN	VARCHAR2,
  X_transaction_id 	IN	NUMBER
) RETURN NUMBER IS

  l_cancel_flag		VARCHAR2(1);
  l_status		VARCHAR2(25);
  l_closed_code		VARCHAR2(25);
  l_count		NUMBER	:= 0;
  l_result		NUMBER	:= 1;

BEGIN

  IF (X_po_release_id is not null) then
     select nvl(closed_code, 'OPEN'),
            nvl(authorization_status, 'INCOMPLETE'),
            nvl(cancel_flag, 'N'),
            revision_num,
            nvl(X_employee_id, agent_id)
       into l_closed_code,
            l_status,
            l_cancel_flag,
            X_current_revision,
            X_employee_id
       from po_releases
      where po_release_id = X_po_release_id;

  ELSIF (X_po_header_id is not null) then
     select nvl(closed_code, 'OPEN'),
            nvl(authorization_status, 'INCOMPLETE'),
            nvl(cancel_flag, 'N'),
            revision_num,
            nvl(X_employee_id, agent_id)
       into l_closed_code,
            l_status,
            l_cancel_flag,
            X_current_revision,
            X_employee_id
       from po_headers
      where po_header_id = X_po_header_id;
  END IF;

  if (l_closed_code = 'FINALLY CLOSED') then
     l_result := 0;
     PO_CHANGE_API1_S.insert_error(X_interface_type,
                                   X_transaction_id,
                                   'CLOSED_CODE',
				   'PO_HEADERS',
                                   'PO_ALL_DOC_CANNOT_BE_OPENED',
				   NULL,
			           NULL);
  end if;

  -- Bug#4156064: allow changing of PO with incomplete status also
  if (l_status not in ('APPROVED', 'REQUIRES REAPPROVAL', 'INCOMPLETE','REJECTED')) then -- Bug 12765603 Included Rejected
     l_result := 0;
     PO_CHANGE_API1_S.insert_error(X_interface_type,
                                   X_transaction_id,
                                   'AUTHORIZATION_STATUS',
				   'PO_HEADERS',
                                   'PO_ALL_DOC_CANNOT_BE_OPENED',
				   NULL,
			           NULL);
  end if;

  if (l_cancel_flag = 'Y') then
     l_result := 0;
     PO_CHANGE_API1_S.insert_error(X_interface_type,
                                   X_transaction_id,
                                   'CANCEL_FLAG',
				   'PO_HEADERS',
                                   'PO_ALL_DOC_CANNOT_BE_OPENED',
				   NULL,
			           NULL);
  end if;

  -- Bug 9312384: 9029360 FORWARD PORT Accepting revisions of older versions should not be permitted.
  -- Changing condtion to check whether passed revision_num is not same as that of current_revision, then insert error
  if (X_revision_num <> X_current_revision) then
     l_result := 0;
     PO_CHANGE_API1_S.insert_error(X_interface_type,
                                   X_transaction_id,
                                   'X_REVISION_NUMBER',
				   NULL,
                                  'PO_CHNG_REVISION_NOT_MATCH',
				   NULL,
			           NULL);
  end if;

     select count(*)
       into l_count
       from per_people_f
      where person_id = X_employee_id
        and trunc(g_sysdate) between effective_start_date
            and nvl(effective_end_date, g_sysdate+1);

  if (l_count = 0) then
        l_result := 0;
        PO_CHANGE_API1_S.insert_error(	X_interface_type,
					X_transaction_id,
					'X_EMPLOYEE_ID',
					NULL,
					'PO_CHNG_NOT_VALID_EMPLOYEE',
				        NULL,
			                NULL);
  end if;

  return l_result;

  EXCEPTION
    WHEN OTHERS THEN
      return 0;
END validate_acceptance;

FUNCTION check_mandatory_params
(
  X_PO_NUMBER			VARCHAR2,
  X_REVISION_NUMBER		NUMBER,
  VERSION			VARCHAR2,
  X_INTERFACE_TYPE		VARCHAR2,
  X_TRANSACTION_ID		NUMBER
) RETURN NUMBER IS

BEGIN

  if (X_PO_NUMBER is null) then
     PO_CHANGE_API1_S.insert_error(X_INTERFACE_TYPE,
				   X_TRANSACTION_ID,
				   'PO_NUMBER',
				   NULL,
				   'PO_ALL_CNL_PARAM_NULL',
				   NULL,
				   NULL);
     return 0;
  end if;

  if (X_REVISION_NUMBER is null) then
     PO_CHANGE_API1_S.insert_error(X_INTERFACE_TYPE,
				   X_TRANSACTION_ID,
				   'REVISION_NUM',
				   NULL,
				   'PO_ALL_CNL_PARAM_NULL',
				   NULL,
				   NULL);
     return 0;
  end if;

  if (VERSION is null) then
     PO_CHANGE_API1_S.insert_error(X_INTERFACE_TYPE,
				   X_TRANSACTION_ID,
				   'VERSION',
				   NULL,
				   'PO_ALL_CNL_PARAM_NULL',
				   NULL,
				   NULL);
     return 0;
  elsif (VERSION <> '1.0') then
     PO_CHANGE_API1_S.insert_error(X_INTERFACE_TYPE,
				   X_TRANSACTION_ID,
				   'VERSION',
				   NULL,
				   'PO_CHNG_INVALID_VERSION',
				   NULL,
				   NULL);
     return 0;
  end if;

  return 1;

  EXCEPTION
     WHEN OTHERS THEN
       return 0;
END check_mandatory_params;

PROCEDURE insert_error
( X_INTERFACE_TYPE	IN	VARCHAR2,
  X_transaction_id	IN	NUMBER,
  X_column_name		IN	VARCHAR2,
  X_TABLE_NAME		IN	VARCHAR2,
  X_MESSAGE_NAME	IN	VARCHAR2,
  X_token_name		IN	VARCHAR2,
  X_token_value		IN	VARCHAR2
) IS

  pragma AUTONOMOUS_TRANSACTION;
  l_error_message	VARCHAR2(2000) := NULL;

BEGIN
  FND_MESSAGE.set_name('PO', X_MESSAGE_NAME);

  if (X_token_name is not null) then
     FND_MESSAGE.set_token(X_token_name, X_token_value);
  end if;

  l_error_message := FND_MESSAGE.get;

  insert into PO_INTERFACE_ERRORS (
		INTERFACE_TYPE,
		INTERFACE_TRANSACTION_ID,
		COLUMN_NAME,
		ERROR_MESSAGE,
		PROCESSING_DATE,
		ERROR_MESSAGE_NAME,
		TABLE_NAME,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		REQUEST_ID,
 		PROGRAM_APPLICATION_ID,
 		PROGRAM_ID,
 		PROGRAM_UPDATE_DATE	)
      values (
		X_INTERFACE_TYPE,
		X_transaction_id,
		X_column_name,
		l_error_message,
		g_sysdate,
		X_MESSAGE_NAME,
		X_TABLE_NAME,
		g_sysdate,
		g_user_id,
		g_sysdate,
		g_user_id,
		g_login_id,
		NULL,
		201,
		NULL,
		NULL			);

  commit;

  EXCEPTION
    WHEN OTHERS THEN
      raise;
END insert_error;

-- <PO_CHANGE_API FPJ>
-- In file version 115.10, removed the X_INTERFACE_TYPE and X_TRANSACTION_ID
-- parameters from UPDATE_PO and added an X_API_ERRORS parameter, because
-- the PO Change API will no longer write error messages to the
-- PO_INTERFACE_ERRORS table. Instead, it will return all of the errors
-- in the x_api_errors object.

FUNCTION update_po
(
  X_PO_NUMBER			VARCHAR2,
  X_RELEASE_NUMBER		NUMBER,
  X_REVISION_NUMBER		NUMBER,
  X_LINE_NUMBER			NUMBER,
  X_SHIPMENT_NUMBER		NUMBER,
  NEW_QUANTITY			NUMBER,
  NEW_PRICE			NUMBER,
  NEW_PROMISED_DATE		DATE,
  NEW_NEED_BY_DATE              DATE,
  LAUNCH_APPROVALS_FLAG		VARCHAR2,
  UPDATE_SOURCE			VARCHAR2,
  VERSION			VARCHAR2,
  X_OVERRIDE_DATE		DATE		:= NULL,
  X_API_ERRORS                  OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_BUYER_NAME                  VARCHAR2  default NULL, /* Bug:2986718 */
  -- <INVCONV R12 START>
  p_secondary_quantity          NUMBER    ,
  p_preferred_grade             VARCHAR2,
  -- <INVCONV R12 END>
  p_org_id          IN NUMBER
) RETURN NUMBER IS

  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name  CONSTANT VARCHAR2(50) := 'UPDATE_PO';

  l_error_message		PO_INTERFACE_ERRORS.ERROR_MESSAGE%TYPE;

  l_result	NUMBER := 1;
  l_return_status VARCHAR2(1);
  l_org_id PO_HEADERS_ALL.org_id%type := p_org_id;
BEGIN

  IF NOT FND_API.Compatible_API_CALL (	l_api_version,
					TO_NUMBER(VERSION,99.999),
					l_api_name,
					g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.initialize;

  --<Bug#4581621 Start>
  PO_MOAC_UTILS_PVT.validate_orgid_pub_api(x_org_id => l_org_id);
  PO_MOAC_UTILS_PVT.set_policy_context('S',l_org_id);
  --<Bug#4581621 End>

  PO_DOCUMENT_UPDATE_GRP.update_document(
    X_PO_NUMBER,
    X_RELEASE_NUMBER,
    X_REVISION_NUMBER,
    X_LINE_NUMBER,
    X_SHIPMENT_NUMBER,
    NEW_QUANTITY,
    NEW_PRICE,
    NEW_PROMISED_DATE,
    NEW_NEED_BY_DATE,
    LAUNCH_APPROVALS_FLAG,
    UPDATE_SOURCE,
    X_OVERRIDE_DATE,
    2.0,			-- Version <PO_CHANGE_API FPJ>
    l_result,
    x_api_errors, -- <PO_CHANGE_API FPJ>
    p_BUYER_NAME, /* Bug:2986718 */
    p_secondary_quantity,   -- <INVCONV R12>
    p_preferred_grade       -- <INVCONV R12>
  );

  RETURN l_result;

EXCEPTION
  -- <PO_CHANGE_API FPJ START>
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status
    );
    RETURN 0;
  WHEN OTHERS THEN
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => l_return_status
    );
    RETURN 0;
  -- <PO_CHANGE_API FPJ END>
END update_po;


/*=====================================================================
 * PROCEDURE update_po
 * API that validates and applies the requested changes and any derived
 * changes to the Purchase Order
 * Parameters:
 * - p_api_version:
 *  -- API version number expected by the caller
 * - p_init_msg_list:
 *  -- If FND_API.G_TRUE, the API will initialize the standard API message list.
 * - x_return_status:
 *  --  FND_API.G_RET_STS_SUCCESS if the API succeeded and the changes are applied.
 *  --  FND_API.G_RET_STS_ERROR if one or more validations failed.
 *  --  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
 * - p_changes:
 *  --  object with the changes to make to the document
 * - x_api_errors:
 *  --  If x_return_status is not FND_API.G_RET_STS_SUCCESS, this
 *  --  PL/SQL object will contain all the error messages, including field-level
 *  --  validation errors, submission checks errors, and unexpected errors.
 *======================================================================*/
PROCEDURE update_po (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY po_pub_update_rec_type,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
) IS

  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name  CONSTANT VARCHAR2(50) := 'UPDATE_PO';

  l_org_id PO_HEADERS_ALL.org_id%type := p_changes.org_id;
BEGIN

 IF NOT FND_API.Compatible_API_CALL (l_api_version,
					p_api_version,
					l_api_name,
					g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  PO_MOAC_UTILS_PVT.set_policy_context('S',l_org_id);


  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  PO_DOCUMENT_UPDATE_GRP.update_document(
    p_api_version => l_api_version,
    p_init_msg_list => p_init_msg_list,
    x_return_status => x_return_status,
    p_changes => p_changes,
    x_api_errors => x_api_errors
  );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END update_po;

END PO_CHANGE_API1_S;

/
