--------------------------------------------------------
--  DDL for Package AP_WEB_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: apwnotes.pls 115.1 2004/06/14 23:07:50 rlangi noship $ */

-----------------------------------------------------------------------------
/* These are the source object codes used for OIE Notes */
-----------------------------------------------------------------------------
c_ER_Object_Code          CONSTANT AP_NOTES.SOURCE_OBJECT_CODE%TYPE := 'OIE_EXPENSE_REPORT';
c_CCTrxn_Object_Code      CONSTANT AP_NOTES.SOURCE_OBJECT_CODE%TYPE := 'OIE_CREDIT_CARD_TXN';

-----------------------------------------------------------------------------
/* These are the note types used for OIE Notes */
-----------------------------------------------------------------------------
c_Prep_Aud_Note_Type      CONSTANT AP_NOTES.NOTE_TYPE%TYPE := 'OIE_PREPARER_AUDITOR';
c_Aud_Aud_Note_Type       CONSTANT AP_NOTES.NOTE_TYPE%TYPE := 'OIE_AUDITOR_AUDITOR';
c_Dispute_Note_Type       CONSTANT AP_NOTES.NOTE_TYPE%TYPE := 'OIE_DISPUTE';


-----------------------------------------------------------------------------
/*Written By : Ron Langi
  Purpose    : Creates an Expense Report Preparer to Auditor Note
               used for Approval Communications.
*/
-----------------------------------------------------------------------------
procedure CreateERPrepToAudNote (
  p_report_header_id IN NUMBER,
  p_note IN VARCHAR2,
  p_lang IN VARCHAR2,
  p_entered_by                  IN         NUMBER   := fnd_global.user_id
);


-----------------------------------------------------------------------------
/*Written By : Ron Langi
  Purpose    : Deletes all Notes for an Expense Report object
*/
-----------------------------------------------------------------------------
procedure DeleteERNotes (
  p_src_report_header_id IN NUMBER
);


-----------------------------------------------------------------------------
/*Written By : Ron Langi
  Purpose    : Copies all Notes for an Expense Report object
*/
-----------------------------------------------------------------------------
procedure CopyERNotes (
  p_src_report_header_id IN NUMBER,
  p_tgt_report_header_id IN NUMBER
);



END AP_WEB_NOTES_PKG;

 

/
