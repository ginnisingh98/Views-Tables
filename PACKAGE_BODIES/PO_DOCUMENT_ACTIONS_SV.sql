--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTIONS_SV" AS
/* $Header: POXDORAB.pls 120.0.12010000.3 2008/09/30 14:11:39 grohit ship $*/

-- <HTMLAC BEGIN>
G_PKG_NAME CONSTANT varchar2(30) := 'po_document_actions_sv';

-- Start of comments
--	API name : po_request_action_bulk
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Calls po_request_action for each line that needs
--			      to have an action requsted.
--            Action is hard coded to requisition return!
--	Parameters	:
--	IN		:	p_api_version           	   IN NUMBER	Required
--          p_reason                      IN varchar2 Required
--            The reason needed to return this document if any
--          p_employee_id                 IN NUMBER Required
--            The employee_id to whom we will send a notification.
--          p_grouping_method             IN varchar2 Required
--            The req grouping selected from the UI
--          p_req_header_id_tbl           IN PO_TBL_NUMBER Required
--            The table containing the req_header_id column.
-- OUT   :  x_result                     OUT NUMBER
--          x_error_message              OUT VARCHAR2
--          x_online_report_id_tbl       OUT PO_TBL_NUMBER
--            The online report ids that have been generated.
--          x_req_header_id_succ_tbl     OUT PO_TBL_NUMBER
--            Contains all the header_ids of the successful reqs.
--	Version	: Current version	1.0
--			     Previous version 	1.0
--			     Initial version 	1.0
-- End of comments
PROCEDURE po_request_action_bulk (
   p_api_version             IN NUMBER,
   x_result                 OUT NOCOPY NUMBER,
   x_error_message          OUT NOCOPY VARCHAR2,
   p_reason                  IN VARCHAR2 := NULL,
   p_employee_id             IN NUMBER,
   p_req_header_id_tbl       IN PO_TBL_NUMBER,
   x_online_report_id_tbl   OUT NOCOPY PO_TBL_NUMBER,
   x_req_header_id_succ_tbl OUT NOCOPY PO_TBL_NUMBER
) IS
   -- Standard api variables
   l_api_name        CONSTANT VARCHAR2(30) := 'po_request_action_bulk';
   l_api_version     CONSTANT NUMBER       := 1.0;
   -- Count variables
   l_num_lines                NUMBER; -- num lines passed in
   l_out_online_count         NUMBER; -- count of the online report
   l_out_header_count         NUMBER; -- count of the succ header
   -- Bulk collect
   l_id_key    NUMBER;
   -- First their table types
   TYPE l_doc_sub_type_list_type IS TABLE OF
                          po_requisition_headers_all.type_lookup_code%TYPE;
   TYPE l_approval_id_list_type  IS TABLE OF
                          po_document_types_all.default_approval_path_id%TYPE;
   TYPE l_org_id_list_type  IS TABLE OF
                          po_requisition_headers_all.org_id%TYPE;

   TYPE l_rowid_char_tbl_type IS TABLE OF VARCHAR2(18);
   -- The local tables
   l_doc_sub_type_tbl         l_doc_sub_type_list_type;
   l_approval_id_tbl          l_approval_id_list_type;
   l_org_id_tbl               l_org_id_list_type;
   l_rowid_char_tbl           l_rowid_char_tbl_type;

   -- <Doc Manager Rewrite 11.5.11 Start>
   -- replace po_request_action call with po_document_action_pvt.do_return call
   l_ret_sts VARCHAR2(1);
   l_online_report_id NUMBER;
   l_return_code VARCHAR2(25);
   l_error_message VARCHAR2(2000);
   -- <Doc Manager Rewrite 11.5.11 End>

   -- original org context
   l_original_org_context     NUMBER := null;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT po_request_action_bulk_sp;
  -- Standard Call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version     ,
                    	    	    	    	 	p_api_version     ,
   	                   	    	 			l_api_name 	    	,
		    	    	    	                	G_PKG_NAME )
  	THEN
      x_error_message := 'API version check raised exception';
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

   -- API body
   -- First lets get the bulk collects for org_id, l_doc_sub_type,
   -- l_approval_id
   l_id_key := PO_CORE_S.get_session_gt_nextval();
   l_num_lines := p_req_header_id_tbl.COUNT;


   -- What we are trying to do is to insert these rows into the po_session_gt
   -- table and then do a bulk collect.
   -- For 8i compatibility, need to do 2 bulk collects.
   -- Need to have one to insert and then another one to update.
   FORALL i in 1..l_num_lines
     INSERT INTO PO_SESSION_GT(key, num1)
     VALUES (l_id_key, p_req_header_id_tbl(i))
     RETURNING ROWIDTOCHAR(rowid)
     BULK COLLECT INTO l_rowid_char_tbl
     ;

   FORALL i in 1..l_num_lines
     UPDATE PO_SESSION_GT SES
     SET
     ( char1, -- document sub type
       num2,  -- approval id
       num3   -- org_id
     )
     =
     ( SELECT prh.type_lookup_code,
              podc.default_approval_path_id,
              prh.org_id
       FROM po_requisition_headers_all prh,
            po_document_types_all podc
       WHERE prh.requisition_header_id = p_req_header_id_tbl(i)
       AND   podc.document_type_code = 'REQUISITION'
       AND   podc.document_subtype = prh.type_lookup_code
       AND   podc.org_id = prh.org_id      -- <R12 MOAC>
     )
     WHERE SES.rowid = CHARTOROWID(l_rowid_char_tbl(i))
     RETURNING
        char1,
        num2,
        num3
     BULK COLLECT INTO
        l_doc_sub_type_tbl,
        l_approval_id_tbl,
        l_org_id_tbl
     ;

   -- Initialise the count for the online report list and the header list
   -- to zero.
   l_out_online_count := 0;
   l_out_header_count := 0;

   -- Initialise the two tables
   x_online_report_id_tbl   := PO_TBL_NUMBER();
   x_req_header_id_succ_tbl := PO_TBL_NUMBER();


   -- <Doc Manager Rewrite 11.5.11 Start>
   -- Use PO_DOCUMENT_ACTION_PVT.do_return instead of po_request_action call

   FOR i IN 1..l_num_lines
   LOOP

      PO_DOCUMENT_ACTION_PVT.do_return(
         p_document_id      => p_req_header_id_tbl(i)
      ,  p_document_type    => 'REQUISITION'
      ,  p_document_subtype => l_doc_sub_type_tbl(i)
      ,  p_note             => p_reason
      ,  p_approval_path_id => l_approval_id_tbl(i)
      ,  x_return_status    => l_ret_sts
      ,  x_return_code      => l_return_code
      ,  x_exception_msg    => l_error_message
      ,  x_online_report_id => l_online_report_id
      );

      -- Information we need is: l_return_code,
      --                         l_error_message and l_online_report_id

      -- Check for unexpected errors. An unexpected error happens if for
      -- some reason l_return_code is not getting set.
      -- Doc Manager Rewrite: also check for STATE_FAILED return code
      IF(l_ret_sts <> 'S') THEN
         x_error_message := l_error_message;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_code = 'STATE_FAILED') THEN
         x_error_message := 'Document state check failed.';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         x_result := 1;
      END IF;

      -- <Doc Manager Rewrite 11.5.11 End>

      -- Now let us look for the expected errors
      IF (l_return_code IN ('F', 'P',  'T')) THEN
         l_out_online_count := l_out_online_count + 1;
         x_online_report_id_tbl.extend(1);
         x_online_report_id_tbl(l_out_online_count) :=
                                l_online_report_id;
      ELSE
         l_out_header_count := l_out_header_count + 1;
         x_req_header_id_succ_tbl.extend(1);
         x_req_header_id_succ_tbl(l_out_header_count) :=
                                  p_req_header_id_tbl(i);
         -- Set the org context
         IF(l_org_id_tbl(i) IS NOT NULL) THEN
            l_original_org_context := PO_MOAC_UTILS_PVT.get_current_org_id; -- <R12 MOAC>
            --IF(l_original_org_context <> l_org_id_tbl(i)) THEN  -- <R12 MOAC> commented as this is already handles in PO_MOAC_UTILS_PVT.set_org_context
               PO_MOAC_UTILS_PVT.set_org_context(l_org_id_tbl(i)) ; -- <R12 MOAC> Added
            --END IF;   -- <R12 MOAC>
         END IF;

         -- Send email notification of the success of the return
         PO_AUTOCREATE_DOC.send_return_notif(p_req_header_id_tbl(i),
                                             p_employee_id,
                                             p_reason);
         commit;
         -- Set back the org context
          --Commented out as code below. This is now handled
          --in PO_MOAC_UTILS.set_org_context
            PO_MOAC_UTILS_PVT.set_org_context(l_original_org_context) ; -- <R12 MOAC>
      END IF;
   END LOOP;

   -- End of API body
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO po_request_action_bulk_sp;
      IF(x_error_message is null) THEN
         x_error_message := 'In Expected error of po_request_action_bulk';
      END IF;
      x_result := -1;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO po_request_action_bulk_sp;
      IF(x_error_message is null) THEN
         x_error_message := 'In Unexpected error';
      END IF;
      x_result := -1;
	WHEN OTHERS THEN
		ROLLBACK TO po_request_action_bulk_sp;
      IF(x_error_message is null) THEN
         x_error_message := 'In other error: ' || fnd_message.get;
      END IF;
      x_result := -1;
END po_request_action_bulk;
-- <HTMLAC END>

/*
** The return values from this function and their definition
** are the following:
**
** E_SUCCESS constant number    := 0;           -- e_code is success
** E_TIMEOUT constant number    := 1;           -- e_code is timeout
** E_NOMGR   constant number    := 2;           -- e_code is no manager
** E_OTHER   constant number    := 3;           -- e_code is other
*/

-- <Doc Manager Rewrite R12>: Only actions that are still supported
-- through this package are:
-- 1.  CANCEL  - only from within PO
-- 2.  IGC YEAR END RESERVE/UNRESERVE - only from IGC
-- 3.  VERIFY_AUTHORITY_CHECK, UNRESERVE_DOCUMENT - only from ICX
-- Of the above, only CANCEL still goes through a Pro*C concurrent manager
-- This method should no longer be extended.
-- Please see replacements: PO_DOCUMENT_ACTIONS_PVT, PO_DOCUMENT_FUNDS_PVT/GRP

FUNCTION PO_REQUEST_ACTION  (
    Action              IN  VARCHAR2,
    Document_Type       IN  VARCHAR2,
    Document_Subtype    IN  VARCHAR2,
    Document_Id         IN  NUMBER,
    Line_Id             IN  NUMBER,
    Shipment_Id         IN  NUMBER,
    Distribution_Id     IN  NUMBER,
    Employee_id         IN  NUMBER,
    New_Document_Status IN  VARCHAR2,
    Offline_Code        IN  VARCHAR2,
    Note                IN  VARCHAR2,
    Approval_Path_Id    IN  NUMBER,
    Forward_To_Id       IN  NUMBER,
    Action_Date         IN  DATE,
    Override_Funds      IN  VARCHAR2,
    Info_Request        OUT NOCOPY VARCHAR2,
    Document_Status     OUT NOCOPY VARCHAR2,
    Online_Report_Id    OUT NOCOPY NUMBER,
    Return_Code         OUT NOCOPY VARCHAR2,
    Error_Msg           OUT NOCOPY VARCHAR2,
    --<CANCEL API FPI START>
    p_extra_arg1        IN  VARCHAR2,
    p_extra_arg2        IN  VARCHAR2,
    p_extra_arg3        IN  VARCHAR2,
    --<CANCEL API FPI END>
    p_extra_arg4        IN  VARCHAR2   -- <ENCUMBRANCE FPJ>
   )
RETURN NUMBER
IS

  rc_sync            NUMBER := 0;
  rc                 NUMBER := 0;
  outcome            varchar2(200) := NULL;
  message            varchar2(200) := NULL;

-- <APPROVAL TIMEOUT VALUE FPI START>
-- Enh. Request: 2535262
-- Details     : The timeout value to be read from the profile value
--               instead of defining a fixed value in this function.
--               Any new profile value may be set at site level.
--               By default, the site level profile value is 300 sec.
--               This is a change from earlier value of 180 sec.
   timeout   NUMBER := NVL(FND_PROFILE.value('PO_APPROVAL_TIMEOUT_VALUE'),180);
--
-- Commented for Enh.Request 2535262
-- timeout  number        := 180; /* Timeout to wait for the manager
--                                   to return is 180 Seconds */
-- <APPROVAL TIMEOUT VALUE FPI END>

  r_val1             varchar2(200) := NULL;
  r_val2             varchar2(200) := NULL;
  r_val3             varchar2(200) := NULL;
  r_val4             varchar2(200) := NULL;
  r_val5             varchar2(200) := NULL;
  r_val6             varchar2(200) := NULL;
  r_val7             varchar2(200) := NULL;
  r_val8             varchar2(200) := NULL;
  r_val9             varchar2(200) := NULL;
  r_val10            varchar2(200) := NULL;
  r_val11            varchar2(200) := NULL;
  r_val12            varchar2(200) := NULL;
  r_val13            varchar2(200) := NULL;
  r_val14            varchar2(200) := NULL;
  r_val15            varchar2(200) := NULL;
  r_val16            varchar2(200) := NULL;
  r_val17            varchar2(200) := NULL;
  r_val18            varchar2(200) := NULL;
  r_val19            varchar2(200) := NULL;
  r_val20            varchar2(200) := NULL;
  parm_location      NUMBER        := NULL;
  X_info_request     varchar2(25)  := NULL;
  X_document_status  varchar2(240) := NULL;
  X_online_report_id NUMBER        := NULL;
  X_return_code      varchar2(25)  := NULL;
  number_of_args     NUMBER        := 0;
  X_progress         varchar2(4)   := '000';

  --<ENCUMBRANCE FPJ>
  l_return_status   VARCHAR2(1);
  l_enc_return_code VARCHAR2(10);

  -- <Doc Manager Rewrite R12 Start>
  l_exc_msg VARCHAR2(2000);
  l_error_msg VARCHAR2(2000);
  -- <Doc Manager Rewrite R12 End>

   l_function_return_value          NUMBER := 0;
   l_return_exc                     EXCEPTION;

BEGIN

  /*
  ** Check if any of the last four in arguments are populated.  If so
  ** tell the server that there are extra arguments being passed in and
  ** to parse those args
  */
  number_of_args := 17;

  --<CANCEL API FPI START>
  -- Increment the number of args for each extra arg passed in
  IF p_extra_arg1 IS NOT NULL THEN
      number_of_args := number_of_args + 1;
  END IF;
  IF p_extra_arg2 IS NOT NULL THEN
      number_of_args := number_of_args + 1;
  END IF;
  IF p_extra_arg3 IS NOT NULL THEN
      number_of_args := number_of_args + 1;
  END IF;
  --<CANCEL API FPI END>

  -- <ENCUMBRANCE FPJ START>
  IF p_extra_arg4 IS NOT NULL THEN
      number_of_args := number_of_args + 1;
  END IF;
  -- <ENCUMBRANCE FPJ END>

  X_progress := '100';


  -- <ENCUMBRANCE FPJ START>
  IF action IN ('IGC YEAR END RESERVE', 'IGC YEAR END UNRESERVE', 'UNRESERVE_DOCUMENT') THEN
     -- these actions no longer go through the document manager
     -- call the encumbrance code directly instead

     IF action = 'IGC YEAR END RESERVE' THEN

	PO_DOCUMENT_FUNDS_PVT.do_cbc_yearend_reserve(
	   x_return_status    => l_return_status
	,  p_doc_type         => document_type
	,  p_doc_subtype      => document_subtype
	,  p_doc_level        => 'HEADER'
	,  p_doc_level_id     => document_id
	,  p_override_funds   => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
	,  p_employee_id      => employee_id
	,  x_po_return_code   => l_enc_return_code
	,  x_online_report_id => online_report_id
	);

  -- <Doc Manager Rewrite R12>: IDTools analysis revealed that
  -- UNRESERVE_DOCUMENT action may still be called in ICX code.  So, added
  -- call to do_unreserve.

     ELSIF (action = 'UNRESERVE_DOCUMENT') THEN

  -- for now, we assume that we do not commit.
  -- previously, there was a commit in the doc manager.
  -- if the commit is still necessary, then we can wrap this in
  -- an autonomous transaction

	PO_DOCUMENT_FUNDS_PVT.do_unreserve(
	   x_return_status     => l_return_status
	,  p_doc_type          => document_type
	,  p_doc_subtype       => document_subtype
	,  p_doc_level         => 'HEADER'
	,  p_doc_level_id      => document_id
  ,  p_use_enc_gt_flag   => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
  ,  p_validate_document => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
	,  p_override_funds    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
  ,  p_use_gl_date       => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
  ,  p_override_date     => SYSDATE
	,  p_employee_id       => employee_id
	,  x_po_return_code    => l_enc_return_code
	,  x_online_report_id  => online_report_id
	);

     ELSE
        -- Year End Unreserve
	PO_DOCUMENT_FUNDS_PVT.do_cbc_yearend_unreserve(
	   x_return_status    => l_return_status
	,  p_doc_type         => document_type
	,  p_doc_subtype      => document_subtype
	,  p_doc_level        => 'HEADER'
	,  p_doc_level_id     => document_id
	,  p_override_funds   => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
	,  p_use_gl_date      => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
	,  p_override_date    => action_date
	,  p_employee_id      => employee_id
	,  x_po_return_code   => l_enc_return_code
	,  x_online_report_id => online_report_id
	);

     END IF;

     IF (l_enc_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS) THEN
        return_code := 'S';
     ELSIF (l_enc_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_WARNING) THEN
        return_code := 'A';
     ELSIF (l_enc_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL) THEN
        return_code := 'P';
     ELSIF (l_enc_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE) THEN
        return_code := 'F';
     ELSE
        --fatal/SQL exception
        return_code := 'T';
     END IF;

     --these OUT parameters are only used by the doc manager
     Info_Request    := NULL;
     Document_Status := NULL;


     IF l_return_status IN (FND_API.g_ret_sts_SUCCESS,
                            FND_API.g_ret_sts_ERROR) THEN
       IF action IN ('IGC YEAR END RESERVE', 'IGC YEAR END UNRESERVE') THEN

          -- CBC expects the encumbrance code to commit, unless
          -- there was a SQL/fatal error
          COMMIT;
       END IF;
     ELSE

       IF (action = 'UNRESERVE_DOCUMENT') THEN
          -- ICX expects error
          l_function_return_value := 3;
       END IF;

     END IF;

  -- <Doc Manager Rewrite R12>: VERIFY_AUTHORITY_CHECK is still called by ICX

  ELSIF (action = 'VERIFY_AUTHORITY_CHECK') THEN

    PO_DOCUMENT_ACTION_PVT.verify_authority(
      p_document_id         => document_id
    , p_document_type       => document_type
    , p_document_subtype    => document_subtype
    , p_employee_id         => employee_id
    , x_return_status       => l_return_status
    , x_return_code         => return_code
    , x_exception_msg       => l_exc_msg
    , x_auth_failed_msg     => l_error_msg
    );

    IF (l_return_status <> 'S') THEN
      return_code := NULL;
      l_function_return_value := 3;
      error_msg := l_error_msg;
    END IF;


  ELSIF (action = 'CANCEL') THEN

     -- Because fnd_transaction.synchronous restricts the number of parameters
     -- to be less than 20, and for final close and cancel action we need
     -- to pass in the extra argument (p_extra_arg4), for Use GL Date, we need
     -- to remove one of the existing parameters.  Since OVERRIDE_FUNDS is
     -- currently always passed as NULL for these actions, and the backend
     -- reads the profile value, we removed that argument.  Additionally,
     -- this was the only non-used argument that is NOT one of the doc
     -- mngr's "standard parameters" (changing those requires greater impact)

	 number_of_args := number_of_args - 1;

	 rc_sync := FND_TRANSACTION.synchronous (
	       timeout             ,
	      outcome             ,
	      message             ,
	      'PO', 'POXCON'      ,
	      Action              ,
	      Document_Type       ,
	      Document_Subtype    ,
	      Document_Id         ,
	      Line_Id             ,
	      Shipment_Id         ,
	      Distribution_Id     ,
	      Employee_Id         ,
	      New_Document_Status ,
	      'ONLINE_MANAGER'   || ':' || 'Y',
	      'OFFLINE_CODE'     || ':' || Offline_Code,
	      'NOTE'             || ':' || Note,
	      'APPROVAL_PATH_ID' || ':' || to_char(Approval_Path_Id),
	      'FORWARD_TO_ID'    || ':' || to_char(Forward_To_Id),
	      'ACTION_DATE'      || ':' || to_char(Action_Date, 'DD-MM-YYYY'),
                                 /* Bug 7261397: Action_Date is now passed in the format of DD-MM-YYYY to avoid invalid
  	                            month issues for Cancel/finally close actions */
	      p_extra_arg1,
	      p_extra_arg2,
	      p_extra_arg3,
	      p_extra_arg4,
	      number_of_args);

      /*
      ** E_SUCCESS constant number    := 0;           -- e_code is success
      ** E_TIMEOUT constant number    := 1;           -- e_code is timeout
      ** E_NOMGR   constant number    := 2;           -- e_code is no manager
      ** E_OTHER   constant number    := 3;           -- e_code is other
      */
      /*  dbms_output.put_line ('Return From Sync  = ' || to_char(rc_sync)); */

      /*
      ** If the call to the Document Action Manager process was successful
      ** then get the return values and concatenate them together and then
      ** parse out the particular arguments that you are looking for.
      */
      X_progress := '200';

      IF (rc_sync = 0) THEN

	 rc := fnd_transaction.get_values (
		 r_val1, r_val2, r_val3, r_val4, r_val5,
		 r_val6, r_val7, r_val8, r_val9, r_val10,
		 r_val11, r_val12, r_val13, r_val14, r_val15,
		 r_val16, r_val17, r_val18, r_val19, r_val20);

	 /* dbms_output.put_line ('Return From Get Vals = ' || to_char(rc)); */

	 parm_location := INSTR(r_val1, 'ERROR-FAILURE');

	 IF (parm_location > 0) THEN

	     -- Bug 642346, lpo, 03/25/98
	     -- Added carriage returns to error_msg and use substr() to
	     -- make sure that we don't exceed the string size.

	     error_msg := substr(r_val2  || '
   ' ||
				 r_val3  || '
   ' ||
				 r_val4  || '
   ' ||
				 r_val5  || '
   ' ||
				 r_val6  || '
   ' ||
				 r_val7  || '
   ' ||
				 r_val8  || '
   ' ||
				 r_val9  || '
   ' ||
				 r_val10 || '
   ' ||
				 r_val11 || '
   ' ||
				 r_val12 || '
   ' ||
				 r_val13 || '
   ' ||
				 r_val14 || '
   ' ||
				 r_val15 || '
   ' ||
				 r_val16 || '
   ' ||
				 r_val17 || '
   ' ||
				 r_val18 || '
   ' ||
				 r_val19 || '
   ' ||
				 r_val20, 1, 2000);

	     -- End of fix. Bug 642346, lpo, 3/25/98

	     Info_Request        := NULL;
	     Document_Status     := NULL;
	     Online_Report_Id    := NULL;
	     Return_Code         := NULL;

      l_function_return_value := 3;
      RAISE l_return_exc;

	 END IF;

	 /*
	 ** r_val1 will contain a return value of either 'INFO_REQUEST_FIELD'
	 ** or 'STATUS_FIELD'.  Look for these strings in the return codes and
	 ** act on these accordingly.
	 ** Check to see if the info_request_parameter has been passed
	 ** back.  If so then you know that this should be the only
	 ** return parameter.  You can look at poxdmaction() in src/xit/poxdm.lpc
	 ** to see how the parameters are passed back to this process using
	 ** afptpput().
	 */
	 X_progress := '300';

	 parm_location := INSTR(r_val1, 'INFO_REQUEST_FIELD=');

	 IF (parm_location > 0) THEN

	    /*
	    ** If the parm_location is greater than 0 then the field was found
	    ** so go ahead and populate the info_request field
	    */
	    parm_location := INSTR(r_val1, '=');

	    X_info_request := SUBSTR(r_val1, parm_location + 1);

	 END IF;

	 /*
	 ** Now check for the status field.  If the status field is populated
	 ** in the parameter then look for the other parameters of
	 ** ONLINE_REPORT_ID and RETURN_CODE
	 */
	 parm_location := INSTR(r_val1, 'STATUS_FIELD=');

	 IF (parm_location > 0) THEN

	    parm_location := INSTR(r_val1, '=');

	    X_document_status := SUBSTR(r_val1, parm_location + 1);

	    /*
	    ** Now check for the online report id
	    */
	    parm_location := INSTR(r_val2, 'ONLINE_REPORT_ID=');

	    IF (parm_location > 0) THEN

	       parm_location := INSTR(r_val2, '=');

	       x_online_report_id := TO_NUMBER(SUBSTR(r_val2, parm_location + 1));

	    END IF;

	    /*
	    ** Now check for the return code
	    */
	    parm_location := INSTR(r_val3, 'RETURN_CODE=');

	    IF (parm_location > 0) THEN

	       parm_location := INSTR(r_val3, '=');

	       X_return_code := SUBSTR(r_val3, parm_location + 1);

	    END IF;

	 END IF;

	 /*
	 ** Now print out all the values you've found

	 dbms_output.put_line ('--------------------------------------------');

	 dbms_output.put_line ('Info Request = ' || X_info_request);
	 dbms_output.put_line ('Status       = ' || X_document_status);
	 dbms_output.put_line ('Report Id    = ' || to_char(x_online_report_id));
	 dbms_output.put_line ('Return Code  = ' || X_return_code);

	 dbms_output.put_line ('--------------------------------------------');
	 */

      ELSE  --rc_sync <> 0

	    /* dbms_output.put_line ('ERROR : Process exited with status: ' ||
	      to_char(rc_sync));
	    */
	    /*
	    ** Process timed out
	    */
	    IF (rc_sync = 1) THEN

	       Error_Msg := fnd_message.get_string('FND', 'TM-TIMEOUT');

	    ELSIF (rc_sync = 2) THEN

	       Error_Msg := fnd_message.get_string('PO', 'PO_APP_NO_MANAGER');

	    END IF;

	    /*
	    dbms_output.put_line (r_val1);
	    dbms_output.put_line (r_val2);
	    dbms_output.put_line (r_val3);
	    dbms_output.put_line (r_val4);
	    dbms_output.put_line (r_val5);
	    dbms_output.put_line (r_val6);
	    dbms_output.put_line (r_val7);
	    dbms_output.put_line (r_val8);
	    dbms_output.put_line (r_val9);
	    dbms_output.put_line (r_val10);
	    dbms_output.put_line (r_val11);
	    dbms_output.put_line (r_val12);
	    dbms_output.put_line (r_val13);
	    dbms_output.put_line (r_val14);
	    dbms_output.put_line (r_val15);
	    dbms_output.put_line (r_val16);
	    dbms_output.put_line (r_val17);
	    dbms_output.put_line (r_val18);
	    dbms_output.put_line (r_val19);
	    dbms_output.put_line (r_val20);
	    */

      END IF;  -- if rc_sync = 0

--      X_progress := '400';

      /*
      ** Set the return values and return control to the caller
      */
      Info_Request        := X_info_request;
      Document_Status     := X_document_status;
      Online_Report_Id    := X_online_report_id;
      Return_Code         := X_return_code;

      l_function_return_value := rc_sync;

   END IF;  -- IGC Year-End actions vs. other doc manager actions

   -- temp
   if(error_msg is null) then
      error_msg := r_val1 || ' ' || r_val2 || ' ' || r_val3;
   end if;

   RETURN(l_function_return_value);

EXCEPTION

   WHEN l_return_exc THEN
      RETURN(l_function_return_value);

   WHEN OTHERS THEN
      po_message_s.sql_error('PO_DOCUMENT_ACTIONS_SV.PO_REQUEST_ACTION',
	X_progress, sqlcode);
   RAISE;


END PO_REQUEST_ACTION;



FUNCTION PO_HOLD_DOCUMENT (
Po_Header_Id          IN              NUMBER  ,
Po_Release_Id         IN              NUMBER ,
Error_Msg             OUT NOCOPY             VARCHAR2) RETURN NUMBER
IS
  rc                 NUMBER := 0;

  X_return_code      varchar2(25)  := NULL;
  X_Document_Type    VARCHAR2(25)  := NULL;
  X_Document_Id      NUMBER        := 0;
  X_Document_Subtype VARCHAR2(25)  := NULL;
  X_progress         varchar2(4)   := '000';

  -- <Doc Manager Rewrite 11.5.11>
  l_ret_sts          VARCHAR2(1);
  l_exc_msg          VARCHAR2(2000);

BEGIN

   /*
   ** This function is used by Oracle Quality to set the document status of
   ** a po or a release to Unapproved and On Hold.  This function will call
   ** the document approval manager to perform this action.   Therefore the
   ** the Document Manager
   */

   /*
   ** Assumption: If po_release_id is populated with a non 0 and non null
   ** value then the document must be a release.  Otherwise it is a standard
   ** po.  This function does not currently support internal reqs
   */

   IF (NVL(Po_Release_Id,0) <> 0) THEN

        X_Document_Type := 'RELEASE';
        X_Document_Subtype := 'RELEASE';
        X_Document_Id := Po_Release_Id;

   ELSE

        /*
        ** Assume cannot be an agreement since you can't
        ** receive against an agreement header (must use a release)
        */

        X_Document_Id := Po_Header_Id;
        X_Document_Type := 'PO';
        X_Document_Subtype := 'STANDARD';

   END IF;

   /*
   ** Call the document manager with the HOLD_DOCUMENT action code
   */

   -- <Doc Manager Rewrite 11.5.11 Start>
   -- Use po_document_action_pvt.do_hold instead po_request_action

   PO_DOCUMENT_ACTION_PVT.do_hold(
      p_document_id      => X_Document_Id
   ,  p_document_type    => X_Document_Type
   ,  p_document_subtype => X_Document_Subtype
   ,  p_reason           => NULL
   ,  x_return_status    => l_ret_sts
   ,  x_return_code      => X_return_code
   ,  x_exception_msg    => l_exc_msg
   );

   IF ((l_ret_sts <> 'S') OR (X_return_code = 'STATE_FAILED'))
   THEN
     rc := 3;
     Error_Msg := substr(l_exc_msg, 1, 240);
   ELSE
     rc := 0;
     Error_Msg := NULL;
   END IF;

   -- <Doc Manager Rewrite 11.5.11 End>

   RETURN (rc);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('PO_DOCUMENT_ACTIONS_SV.HOLD_DOCUMENT',
	X_progress, sqlcode);
   RAISE;

END  PO_HOLD_DOCUMENT;

END PO_DOCUMENT_ACTIONS_SV;


/
