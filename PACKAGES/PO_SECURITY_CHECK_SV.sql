--------------------------------------------------------
--  DDL for Package PO_SECURITY_CHECK_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SECURITY_CHECK_SV" AUTHID CURRENT_USER as
/* $Header: POXSCHKS.pls 115.2 2002/11/23 01:51:57 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_SECURITY_CHECK_SV

  DESCRIPTION:		This package contains the server side
		        security check for figuring out whether
                        the current user can update/delete/insert
                        in a document.

  CLIENT/SERVER:	Server

  OWNER:	        Rajaram Bhakta

  FUNCTION/PROCEDURE:	check_before_lock
===========================================================================*/



/*===========================================================================
  PROCEDURE NAME:       check_before_lock

  DESCRIPTION:		This procedure contains the necessary server side
                        checks to determine whether the current user can
                        update/delete/insert in a document


  PARAMETERS:	        x_type_lookup_code in varchar2,
                        x_object_id        in number,
                        x_logged_emp_id    in number,
                        x_modify_action    in out boolean



  DESIGN REFERENCES:	mchihaou, drstephe


  ALGORITHM:		Call the routines for PO/REQ/REL whenever the
                        on-lock, when-new-record-instance, key-delrec fires

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created     11/12/97
===========================================================================*/

PROCEDURE  check_before_lock (x_type_lookup_code in varchar2,
                              x_object_id        in number,
                              x_logged_emp_id in number,
                              x_modify_action in out NOCOPY boolean);

END PO_SECURITY_CHECK_SV;

 

/
