--------------------------------------------------------
--  DDL for Package PO_REQS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQS_SV2" AUTHID CURRENT_USER as
/* $Header: POXRQR2S.pls 115.2 2002/11/23 01:55:10 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		po_reqs_sv2

  DESCRIPTION:		Contains all server side procedures that access the
			requisitions  entity for WF functionality.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		IALI

  PROCEDURE/FUNCTIONS:	get_reqs_auth_status(..); THIS PROCEDURE WAS MOVED HERE
						  AS PO_REQS_SV GOT TOO BIG.
			WF_notifications_commit;

===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	get_reqs_auth_status

  DESCRIPTION:          Gets requisition header's authorization_status


  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_header_auth_status  IN OUT VARCHAR2,
                        X_req_header_auth_status_dsp  IN OUT VARCHAR2,
			X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Get requisition authorization status from
                        the requisition header.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
			IALI	   7/25/97  Updated and moved to diff package
===========================================================================*/
  PROCEDURE get_reqs_auth_status
                       (X_req_header_id               IN     NUMBER,
                        X_req_header_auth_status      IN OUT NOCOPY VARCHAR2,
                        X_req_header_auth_status_dsp  IN OUT NOCOPY VARCHAR2,
                        X_req_control_error_rc        IN OUT NOCOPY VARCHAR2);

/* ========================================================================*/

/*
        Procedure to execute a server side commit after returning from
        approval WF to kickoff any notifications. Else the notifications
        would be suspended untill the form is exited or a forms commit
        is executed.
*/

PROCEDURE WF_notifications_commit;

END PO_REQS_SV2;

 

/
