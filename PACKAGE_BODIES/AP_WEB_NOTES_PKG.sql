--------------------------------------------------------
--  DDL for Package Body AP_WEB_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_NOTES_PKG" AS
/* $Header: apwnoteb.pls 115.1 2004/06/14 23:08:00 rlangi noship $ */


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
)
IS

  l_debug_info          VARCHAR2(2000);

  l_return_status varchar2(1);
  l_msg_data varchar2(2000);
  l_msg_count number;

BEGIN

  if (p_report_header_id is not null and p_note is not null) then

    --------------------------------------------------
    l_debug_info := 'Create Preparer to Auditor Notes for ER';
    --------------------------------------------------
    AP_NOTES_PUB.Create_Note (
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_FALSE,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data,
      p_source_object_code     => c_ER_Object_Code,
      p_source_object_id       => p_report_header_id,
      p_note_type              => c_Prep_Aud_Note_Type,
      p_notes_detail           => p_note,
      p_source_lang            => p_lang,
      p_entered_by             => p_entered_by
    );


  end if;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_NOTES_PKG', 'CreateERPrepToAudNote',
                     null, to_char(p_report_header_id), null, l_debug_info);
    raise;


END CreateERPrepToAudNote;

-----------------------------------------------------------------------------
/*Written By : Ron Langi
  Purpose    : Deletes all Notes for an Expense Report object
*/
-----------------------------------------------------------------------------
procedure DeleteERNotes (
  p_src_report_header_id IN NUMBER
)
IS

  l_debug_info          VARCHAR2(2000);

  l_return_status varchar2(1);
  l_msg_data varchar2(2000);
  l_msg_count number;

BEGIN

  if (p_src_report_header_id is not null) then

    --------------------------------------------------
    l_debug_info := 'Delete Notes from ER';
    --------------------------------------------------

    AP_NOTES_PUB.Delete_Notes (
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_FALSE,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data,
      p_source_object_code     => c_ER_Object_Code,
      p_source_object_id       => p_src_report_header_id,
      p_note_type              => AP_NOTES_PUB.G_ALL_NOTE_TYPES
    );

  end if;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_NOTES_PKG', 'DeleteERNotes',
                     null, to_char(p_src_report_header_id), null, l_debug_info);
    raise;


END DeleteERNotes;


-----------------------------------------------------------------------------
/*Written By : Ron Langi
  Purpose    : Copies all Notes for an Expense Report object
*/
-----------------------------------------------------------------------------
procedure CopyERNotes (
  p_src_report_header_id IN NUMBER,
  p_tgt_report_header_id IN NUMBER
)
IS

  l_debug_info          VARCHAR2(2000);

  l_return_status varchar2(1);
  l_msg_data varchar2(2000);
  l_msg_count number;

BEGIN

  if (p_src_report_header_id is not null and p_tgt_report_header_id is not null) then

    --------------------------------------------------
    l_debug_info := 'Copy Notes from original ER';
    --------------------------------------------------

    AP_NOTES_PUB.Copy_Notes (
       p_api_version            => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       p_commit                 => FND_API.G_FALSE,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data,
       p_old_source_object_code => c_ER_Object_Code,
       p_old_source_object_id   => p_src_report_header_id,
       p_new_source_object_code => c_ER_Object_Code,
       p_new_source_object_id   => p_tgt_report_header_id
      );

  end if;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_NOTES_PKG', 'CopyERNotes',
                     null, to_char(p_src_report_header_id), null, l_debug_info);
    raise;


END CopyERNotes;



END AP_WEB_NOTES_PKG;

/
