--------------------------------------------------------
--  DDL for Package Body PO_REQS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQS_SV2" as
/* $Header: POXRQR2B.pls 115.2 2002/11/23 01:55:26 sbull ship $ */
/*===========================================================================

  PROCEDURE NAME:	get_reqs_auth_status

===========================================================================*/

 PROCEDURE get_reqs_auth_status
                  (X_req_header_id               IN     NUMBER,
                   X_req_header_auth_status      IN OUT NOCOPY VARCHAR2,
                   X_req_header_auth_status_dsp  IN OUT NOCOPY VARCHAR2,
                   X_req_control_error_rc        IN OUT NOCOPY VARCHAR2) IS

   X_progress                 VARCHAR2(3) := NULL;

 BEGIN
       X_progress := '010';

	-- WF change by Iali. 07/24/97 - modified 10/01/97

	select distinct polc.DISPLAYED_FIELD,  porh.AUTHORIZATION_STATUS
	INTO   X_req_header_auth_status_dsp, X_req_header_auth_status
	from PO_LOOKUP_CODES polc, PO_REQUISITION_HEADERS_ALL porh
	where
	porh.authorization_status = polc.LOOKUP_CODE
	and polc.LOOKUP_TYPE = 'AUTHORIZATION STATUS'
	and porh.requisition_header_id = X_req_header_id;

/*       SELECT authorization_status
       INTO   X_req_header_auth_status
       FROM   PO_REQUISITION_HEADERS
       WHERE  requisition_header_id = X_req_header_id;
*/

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('get_reqs_auth_status', X_progress, sqlcode);
      RAISE;
   WHEN OTHERS THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('get_reqs_auth_status', X_progress, sqlcode);
      RAISE;

 END get_reqs_auth_status;

/*===========================================================================

  PROCEDURE NAME:       WF_notifications_commit

===========================================================================*/

PROCEDURE WF_notifications_commit IS
BEGIN
        commit;
END WF_notifications_commit;

END PO_REQS_SV2;

/
