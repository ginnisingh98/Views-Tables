--------------------------------------------------------
--  DDL for Package PO_NOTES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTES_SV" AUTHID CURRENT_USER AS

/* $Header: poxcenh.pls 115.0 99/07/17 02:29:05 porting ship $ */


/* Declare global variables */

msgbuf                   varchar2(2000);

/*===========================================================================
  FUNCTION NAME:       copy_notes

  DESCRIPTION:	       Copy references from all standard notes under orig_id,
		       orig_column, orig_table to new_id, new_column,
		       new_table.

                       Copy One time notes associated with orig_id and
                       rename them with Name_extention and copy a refernece

  PARAMETERS:	     X_orig_id         IN NUMBER,
                     X_orig_column     IN VARCHAR2,
                     X_orig_table      IN VARCHAR2,
                     X_add_on_title    IN VARCHAR2,
		     X_new_id          IN NUMBER,
                     X_new_column      IN VARCHAR2,
                     X_new_table       IN VARCHAR2,
                     X_last_updated_by IN NUMBER


  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE copy_notes (X_orig_id          IN NUMBER,
                     X_orig_column       IN VARCHAR2,
                     X_orig_table        IN VARCHAR2,
                     X_add_on_title      IN VARCHAR2,
		     X_new_id            IN NUMBER,
                     X_new_column        IN VARCHAR2,
                     X_new_table         IN VARCHAR2,
                     X_last_updated_by   IN NUMBER,
                     X_last_update_login IN NUMBER);

END PO_NOTES_SV;


 

/
